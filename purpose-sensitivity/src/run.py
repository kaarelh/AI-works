"""Run jobs through the Claude Code CLI in headless mode, with no tools.

usage: python3 run.py <jobs.jsonl> <outdir> [--workers N]

Each job: {id, model, cond, task, rep, system, prompt}. Output: <outdir>/<id>.json
holding the job plus the CLI's JSON result. Existing outputs are skipped, so
runs are resumable.
"""
import argparse
import json
import os
import random
import subprocess
import sys
import tempfile
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

LOCK = threading.Lock()
CWD = tempfile.mkdtemp(prefix="ps_cwd_")  # empty working directory for every call

# In the cloud session that runs this experiment, these (non-credential) variables make the
# child CLI inject the parent session's agent context (scratchpad, git attribution, proxy and
# CLI notes) into the subject model's prompt. Unsetting them leaves only the CLI's fixed headless
# preamble (SDK identity line, date, model id, cwd and platform, the account email, an
# untrusted-files note; roughly 300-620 tokens depending on the tokenizer), constant across
# conditions.
DROP_ENV = ["CLAUDE_CODE_USER_EMAIL", "CLAUDE_CODE_REMOTE", "CLAUDE_CODE_REMOTE_ENVIRONMENT_TYPE",
            "CLAUDE_CODE_REMOTE_SESSION_ID", "CLAUDE_CODE_SESSION_ID", "CLAUDE_CODE_CHILD_SESSION",
            "CLAUDECODE", "CLAUDE_CODE_ENTRYPOINT", "CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD",
            "CLAUDE_ADDITIONAL_DIRECTORIES", "CLAUDE_CODE_REMOTE_TOOLS_FORWARD", "CLAUDE_CODE_SESSION_ATTENDED"]
ENV = {k: v for k, v in os.environ.items() if k not in DROP_ENV}


def call(job, timeout=900):
    cmd = ["claude", "-p", "--model", job["model"], "--tools", "", "--system-prompt", job["system"],
           "--output-format", "json", "--no-session-persistence", "--strict-mcp-config",
           "--disable-slash-commands", "--setting-sources", ""]
    t0 = time.time()
    p = subprocess.run(cmd, input=job["prompt"], capture_output=True, text=True, timeout=timeout, cwd=CWD, env=ENV)
    wall = time.time() - t0
    out = p.stdout.strip()
    try:
        res = json.loads(out.splitlines()[-1]) if out else None
    except json.JSONDecodeError:
        res = None
    return res, wall, p.stderr[-2000:]


def run_one(job, outdir, retries=4):
    path = os.path.join(outdir, job["id"] + ".json")
    if os.path.exists(path):
        return "skip", 0.0
    last_err = None
    for attempt in range(retries):
        try:
            res, wall, err = call(job)
        except subprocess.TimeoutExpired:
            res, wall, err = None, None, "timeout"
        if res is not None and not res.get("is_error") and res.get("result") is not None:
            rec = dict(job=job, result=res["result"], usage=res.get("usage"), cost=res.get("total_cost_usd"),
                       model_usage=res.get("modelUsage"), duration_ms=res.get("duration_ms"), wall=wall,
                       stop_reason=res.get("stop_reason"), attempts=attempt + 1)
            with open(path + ".tmp", "w") as f:
                json.dump(rec, f)
            os.replace(path + ".tmp", path)
            return "ok", res.get("total_cost_usd") or 0.0
        last_err = (res or {}).get("result") if res else err
        time.sleep(5 * 2 ** attempt + random.random() * 3)
    with LOCK:
        with open(os.path.join(outdir, "_failures.log"), "a") as f:
            f.write(json.dumps(dict(id=job["id"], err=str(last_err)[:1000])) + "\n")
    return "fail", 0.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("jobs")
    ap.add_argument("outdir")
    ap.add_argument("--workers", type=int, default=6)
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    jobs = [json.loads(l) for l in open(a.jobs)]
    done = cost = 0.0
    stats = {"ok": 0, "skip": 0, "fail": 0}
    t0 = time.time()
    with ThreadPoolExecutor(a.workers) as ex:
        futs = {ex.submit(run_one, j, a.outdir): j for j in jobs}
        for fu in as_completed(futs):
            st, c = fu.result()
            stats[st] += 1
            cost += c
            done += 1
            if done % 10 == 0 or done == len(jobs):
                print(f"[{time.strftime('%H:%M:%S')}] {int(done)}/{len(jobs)} {stats} cost=${cost:.2f} "
                      f"elapsed={time.time() - t0:.0f}s", flush=True)
    print("DONE", stats, f"cost=${cost:.2f}", flush=True)


if __name__ == "__main__":
    sys.exit(main())
