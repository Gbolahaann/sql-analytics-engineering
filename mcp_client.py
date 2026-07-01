"""Direct client for the Stratascratch MCP server (no LLM in the loop).

OAuth2 authorization-code flow with PKCE (public client, dynamically
registered). Tokens live in .oauth.json next to this file.
The CloudFront WAF in front of api.stratascratch.com blocks the strings
"localhost" and "127.0.0.1" in request bodies, so the redirect URI uses
the IPv6 loopback [::1] — Flask must listen on it.
"""

import base64
import hashlib
import json
import os
import secrets
import threading
import time
import urllib.error
import urllib.parse
import urllib.request

BASE = "https://api.stratascratch.com"
MCP_URL = f"{BASE}/mcp"
AUTH_URL = f"{BASE}/o/authorize/"
TOKEN_URL = f"{BASE}/o/token/"
CLIENT_ID = "HxSRX8fysMKpLvac0VapvkApCcB5nKLE5ceKxEo3"
REDIRECT_URI = "http://[::1]:3456/oauth/callback"
SCOPE = "mcp:read mcp:execute mcp:user-data"
TOKEN_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".oauth.json")

_store_lock = threading.Lock()


class NotAuthenticated(Exception):
    pass


class MCPHTTPError(Exception):
    def __init__(self, code, body):
        super().__init__(f"HTTP {code}: {body[:200]}")
        self.code = code
        self.body = body


# ---------------------------------------------------------------- token store

def _load_store():
    try:
        with open(TOKEN_FILE) as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def _save_store(d):
    with open(TOKEN_FILE, "w") as f:
        json.dump(d, f, indent=2)
    os.chmod(TOKEN_FILE, 0o600)


# ---------------------------------------------------------------------- oauth

def auth_url():
    """Build the authorization URL and stash the PKCE verifier + state."""
    verifier = secrets.token_urlsafe(64)
    challenge = base64.urlsafe_b64encode(
        hashlib.sha256(verifier.encode()).digest()
    ).rstrip(b"=").decode()
    state = secrets.token_urlsafe(16)
    with _store_lock:
        store = _load_store()
        store["pkce_verifier"] = verifier
        store["state"] = state
        _save_store(store)
    return AUTH_URL + "?" + urllib.parse.urlencode({
        "response_type": "code",
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "scope": SCOPE,
        "state": state,
        "code_challenge": challenge,
        "code_challenge_method": "S256",
    })


def _token_request(data):
    body = urllib.parse.urlencode(data).encode()
    req = urllib.request.Request(TOKEN_URL, data=body, headers={
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        raise MCPHTTPError(e.code, e.read().decode())


def _store_tokens(store, tok):
    store["access_token"] = tok["access_token"]
    if tok.get("refresh_token"):
        store["refresh_token"] = tok["refresh_token"]
    store["expires_at"] = time.time() + tok.get("expires_in", 3600)
    _save_store(store)


def exchange_code(code, state):
    with _store_lock:
        store = _load_store()
        if state != store.get("state"):
            raise ValueError("OAuth state mismatch — try /oauth/login again")
        tok = _token_request({
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": REDIRECT_URI,
            "client_id": CLIENT_ID,
            "code_verifier": store.get("pkce_verifier", ""),
        })
        store.pop("pkce_verifier", None)
        store.pop("state", None)
        _store_tokens(store, tok)


def _refresh_locked(store):
    tok = _token_request({
        "grant_type": "refresh_token",
        "refresh_token": store["refresh_token"],
        "client_id": CLIENT_ID,
    })
    _store_tokens(store, tok)
    return store["access_token"]


def get_token(force_refresh=False):
    with _store_lock:
        store = _load_store()
        if not store.get("access_token"):
            return None
        expired = time.time() > store.get("expires_at", 0) - 60
        if (force_refresh or expired) and store.get("refresh_token"):
            try:
                return _refresh_locked(store)
            except MCPHTTPError:
                return None if force_refresh or expired else store["access_token"]
        return store["access_token"]


def is_authenticated():
    return get_token() is not None


# ----------------------------------------------------------------- mcp client

class MCPClient:
    """Minimal streamable-HTTP MCP client; only what tools/call needs."""

    def __init__(self):
        self._lock = threading.Lock()
        self._session_id = None
        self._rpc_id = 0

    def _next_id(self):
        self._rpc_id += 1
        return self._rpc_id

    def _post(self, payload, token):
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream",
            "Authorization": f"Bearer {token}",
        }
        if self._session_id:
            headers["Mcp-Session-Id"] = self._session_id
        req = urllib.request.Request(MCP_URL, data=json.dumps(payload).encode(),
                                     headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                sid = r.headers.get("Mcp-Session-Id")
                if sid:
                    self._session_id = sid
                ctype = r.headers.get("Content-Type", "")
                raw = r.read().decode()
        except urllib.error.HTTPError as e:
            raise MCPHTTPError(e.code, e.read().decode())
        if not raw.strip():
            return None
        if "text/event-stream" in ctype:
            return self._parse_sse(raw)
        return json.loads(raw)

    @staticmethod
    def _parse_sse(raw):
        result = None
        for line in raw.splitlines():
            if line.startswith("data:"):
                chunk = line[5:].strip()
                try:
                    msg = json.loads(chunk)
                except ValueError:
                    continue
                if isinstance(msg, dict) and ("result" in msg or "error" in msg):
                    result = msg
        return result

    def _initialize(self, token):
        self._session_id = None
        self._post({
            "jsonrpc": "2.0", "id": self._next_id(), "method": "initialize",
            "params": {
                "protocolVersion": "2025-03-26",
                "capabilities": {},
                "clientInfo": {"name": "sql-practice", "version": "1.0"},
            },
        }, token)
        self._post({"jsonrpc": "2.0", "method": "notifications/initialized"}, token)

    def call_tool(self, name, arguments):
        token = get_token()
        if token is None:
            raise NotAuthenticated()
        with self._lock:
            last_err = None
            for attempt in (1, 2):
                try:
                    if self._session_id is None:
                        self._initialize(token)
                    resp = self._post({
                        "jsonrpc": "2.0", "id": self._next_id(),
                        "method": "tools/call",
                        "params": {"name": name, "arguments": arguments},
                    }, token)
                    if resp is None:
                        raise RuntimeError("Empty response from MCP server")
                    if resp.get("error"):
                        raise RuntimeError(resp["error"].get("message", str(resp["error"])))
                    content = resp["result"].get("content", [])
                    text = content[0].get("text", "") if content else ""
                    try:
                        return json.loads(text)
                    except ValueError:
                        return {"raw": text}
                except MCPHTTPError as e:
                    last_err = e
                    self._session_id = None
                    if attempt == 1 and e.code in (401, 403):
                        token = get_token(force_refresh=True)
                        if token is None:
                            raise NotAuthenticated()
                        continue
                    if attempt == 1 and e.code == 404:
                        continue  # stale session — re-init and retry
                    raise
            raise last_err


client = MCPClient()
