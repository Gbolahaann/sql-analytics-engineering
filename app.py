import json
import os
import threading
import uuid

from flask import Flask, jsonify, redirect, request, send_from_directory

import mcp_client
from mcp_client import NotAuthenticated, client as mcp

app = Flask(__name__, static_folder='static')

# In-memory job store  {job_id: {"status": "pending"|"done", "result": {...}}}
jobs = {}

QCACHE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".qcache.json")
try:
    with open(QCACHE_FILE) as f:
        question_cache = json.load(f)
except (OSError, ValueError):
    question_cache = {}

AUTH_HELP = ("Not connected to Stratascratch. Open http://[::1]:3456/oauth/login "
             "in your browser, approve access, then retry.")


def run_async(job_id, fn, *args):
    def work():
        try:
            result = fn(*args)
        except NotAuthenticated:
            result = {"columns": [], "data": [], "error": AUTH_HELP}
        except Exception as e:
            result = {"columns": [], "data": [], "error": str(e)}
        jobs[job_id] = {"status": "done", "result": result}
    jobs[job_id] = {"status": "pending", "result": None}
    threading.Thread(target=work, daemon=True).start()
    return jsonify({"job_id": job_id})


def do_run(qid, sql, ct):
    r = mcp.call_tool("run_code", {"question_id": qid, "code": sql, "code_type": ct})
    res = r.get("results") or {}
    return {"columns": res.get("columns", []),
            "data": res.get("data", []),
            "error": r.get("error")}


def do_submit(qid, sql, ct):
    r = mcp.call_tool("check_solution",
                      {"question_id": qid, "code": sql, "code_type": ct})
    ur = (r.get("user_results") or {}).get("results") or {}
    diff = r.get("results_diff")
    return {"correct": bool(r.get("is_correct")),
            "diff": json.dumps(diff) if diff not in (None, "", {}) else None,
            "columns": ur.get("columns", []),
            "data": ur.get("data", []),
            "error": (r.get("user_results") or {}).get("error")}


def do_question(qid):
    cached = question_cache.get(str(qid))
    if cached:
        return cached
    q = mcp.call_tool("get_question", {"question_id": qid})
    schema = mcp.call_tool("get_dataset_schema", {"question_id": qid, "code_type": 1})
    tables = []
    for ds in schema.get("datasets", []):
        sample = mcp.call_tool("run_code", {
            "question_id": qid,
            "code": f'SELECT * FROM {ds["name"]} LIMIT 5',
            "code_type": 1,
        })
        res = sample.get("results") or {}
        tables.append({
            "name": ds["name"],
            "columns": ds.get("columns", []),
            "sample_columns": res.get("columns", []),
            "sample_rows": res.get("data", []),
        })
    result = {
        "title": q.get("question_short", f"Question {qid}"),
        "difficulty": q.get("difficulty", 1),
        "question_text": q.get("question", ""),
        "tables": tables,
    }
    question_cache[str(qid)] = result
    try:
        with open(QCACHE_FILE, "w") as f:
            json.dump(question_cache, f)
    except OSError:
        pass
    return result


@app.route("/")
def index():
    return send_from_directory("static", "index.html")


@app.route("/oauth/login")
def oauth_login():
    return redirect(mcp_client.auth_url())


@app.route("/oauth/callback")
def oauth_callback():
    if request.args.get("error"):
        return f"Authorization failed: {request.args['error']}", 400
    try:
        mcp_client.exchange_code(request.args.get("code", ""),
                                 request.args.get("state", ""))
    except Exception as e:
        return f"Token exchange failed: {e}", 400
    return ('<body style="font-family:sans-serif;background:#282a36;color:#f8f8f2;'
            'display:flex;align-items:center;justify-content:center;height:90vh">'
            '<div style="text-align:center"><h2>✅ Connected to Stratascratch</h2>'
            '<p>You can close this tab and go back to the practice UI.</p>'
            '<a href="/" style="color:#bd93f9">Open SQL Practice</a></div></body>')


@app.route("/api/auth")
def auth_status():
    return jsonify({"authenticated": mcp_client.is_authenticated(),
                    "login_url": "/oauth/login"})


@app.route("/api/run", methods=["POST"])
def run_query():
    body = request.json
    return run_async(str(uuid.uuid4()), do_run,
                     body["question_id"], body["sql"], body.get("code_type", 1))


@app.route("/api/submit", methods=["POST"])
def submit_query():
    body = request.json
    return run_async(str(uuid.uuid4()), do_submit,
                     body["question_id"], body["sql"], body.get("code_type", 1))


@app.route("/api/question/<int:qid>")
def get_question(qid):
    return run_async(str(uuid.uuid4()), do_question, qid)


@app.route("/api/status/<job_id>")
def job_status(job_id):
    return jsonify(jobs.get(job_id, {"status": "not_found"}))


def warm_session():
    """Open the MCP session at startup so the first real call is instant."""
    try:
        if mcp_client.is_authenticated():
            mcp.call_tool("whoami", {})
    except Exception:
        pass


threading.Thread(target=warm_session, daemon=True).start()


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 3456))
    # host="::" binds IPv6 loopback (required for the OAuth callback on [::1])
    # and accepts IPv4 too on macOS dual-stack.
    app.run(host="::", port=port, debug=False)
