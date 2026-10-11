"""Run jobs through the Claude Code CLI in headless mode, with no tools.

usage: python3 run.py <jobs.jsonl> <outdir> [--workers N] [--timeout SEC] [--budget USD] [--ledger PATH]
                      [--retry-timeouts]

Each job: {id, model, system, prompt, ...} (study 1: cond, task, rep; study 2: unit, context, arm, rep, meta;
optional "timeout" overrides --timeout for that job). Output: <outdir>/<id>.json holding the job plus the CLI's
JSON result and "served_model" (the modelUsage key that produced the output). Existing outputs are skipped, so
runs are resumable. Jobs start in file order.

Timeouts: a job that times out is retried once; a second timeout is an outcome, logged to <outdir>/_timeouts.log
(no record file) and not retried on resume unless --retry-timeouts. Other failures go to _failures.log.

--budget: cumulative cost (all attempts that returned a CLI result) is kept in a ledger (default
<outdir>/_ledger.json, shared across runs); no new job starts once it reaches the cap. Without --budget no ledger
is written, as in study 1.
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
CLI = "claude"


def call(job, timeout=900):
    cmd = [CLI, "-p", "--model", job["model"], "--tools", "", "--system-prompt", job["system"],
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


def served_model(model_usage):
    """The modelUsage key that produced the output (most output tokens), plus every key seen."""
    if not model_usage:
        return None, []
    keys = sorted(model_usage)
    best = max(keys, key=lambda k: ((model_usage[k] or {}).get("outputTokens") or 0,
                                    (model_usage[k] or {}).get("costUSD") or 0))
    return best, keys


class Ledger:
    """Cumulative cost across runs, in one JSON file; inactive (never written) when cap is None."""

    def __init__(self, path, cap):
        self.path, self.cap = path, cap
        self.d = dict(cost_usd=0.0, calls=0, ok=0, timeouts=0, failures=0, by_model={})
        if cap is not None and os.path.exists(path):
            self.d.update(json.load(open(path)))

    def exhausted(self):
        with LOCK:
            return self.cap is not None and self.d["cost_usd"] >= self.cap

    def add(self, model, cost=0.0, outcome=None):
        if self.cap is None:
            return
        with LOCK:
            m = self.d["by_model"].setdefault(model, dict(cost_usd=0.0, calls=0, ok=0))
            self.d["cost_usd"] += cost or 0.0
            m["cost_usd"] += cost or 0.0
            if outcome == "call":
                self.d["calls"] += 1
                m["calls"] += 1
            elif outcome == "ok":
                self.d["ok"] += 1
                m["ok"] += 1
            elif outcome in ("timeouts", "failures"):
                self.d[outcome] += 1
            self.d["cap_usd"] = self.cap
            self.d["updated_utc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
            with open(self.path + ".tmp", "w") as f:
                json.dump(self.d, f, indent=1)
            os.replace(self.path + ".tmp", self.path)


def log_line(outdir, name, obj):
    with LOCK:
        with open(os.path.join(outdir, name), "a") as f:
            f.write(json.dumps(obj) + "\n")


def timed_out_ids(outdir):
    path = os.path.join(outdir, "_timeouts.log")
    if not os.path.exists(path):
        return set()
    return {json.loads(line)["id"] for line in open(path) if line.strip()}


def job_tags(job):
    return {k: job[k] for k in ("model", "context", "arm", "rep", "unit", "cond", "task") if k in job}


def run_one(job, outdir, timeout=900, ledger=None, retries=4):
    path = os.path.join(outdir, job["id"] + ".json")
    if os.path.exists(path):
        return "skip", 0.0
    if ledger is not None and ledger.exhausted():
        return "budget", 0.0
    timeout = job.get("timeout") or timeout
    last_err = None
    n_timeouts = 0
    walls = []
    for attempt in range(retries):
        try:
            res, wall, err = call(job, timeout)
        except subprocess.TimeoutExpired:
            res, wall, err = None, None, "timeout"
            n_timeouts += 1
            walls.append(timeout)
            if n_timeouts >= 2:  # a timeout is retried once; the second one is the outcome
                log_line(outdir, "_timeouts.log", dict(id=job["id"], **job_tags(job), timeout=timeout,
                                                       attempts=attempt + 1, walls=walls,
                                                       ts=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())))
                if ledger is not None:
                    ledger.add(job["model"], 0.0, "timeouts")
                return "timeout", 0.0
            continue
        if ledger is not None:
            ledger.add(job["model"], (res or {}).get("total_cost_usd") or 0.0, "call")
        if res is not None and not res.get("is_error") and res.get("result") is not None:
            served, served_all = served_model(res.get("modelUsage"))
            rec = dict(job=job, result=res["result"], usage=res.get("usage"), cost=res.get("total_cost_usd"),
                       model_usage=res.get("modelUsage"), duration_ms=res.get("duration_ms"), wall=wall,
                       stop_reason=res.get("stop_reason"), attempts=attempt + 1, served_model=served,
                       served_models=served_all, timeouts=n_timeouts)
            with open(path + ".tmp", "w") as f:
                json.dump(rec, f)
            os.replace(path + ".tmp", path)
            if ledger is not None:
                ledger.add(job["model"], 0.0, "ok")
            return "ok", res.get("total_cost_usd") or 0.0
        last_err = (res or {}).get("result") if res else err
        time.sleep(5 * 2 ** attempt + random.random() * 3)
    log_line(outdir, "_failures.log", dict(id=job["id"], err=str(last_err)[:1000]))
    if ledger is not None:
        ledger.add(job["model"], 0.0, "failures")
    return "fail", 0.0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("jobs")
    ap.add_argument("outdir")
    ap.add_argument("--workers", type=int, default=6)
    ap.add_argument("--timeout", type=int, default=900, help="seconds per call; a job's 'timeout' field overrides")
    ap.add_argument("--budget", type=float, default=None, help="USD cap on the cumulative ledger cost")
    ap.add_argument("--ledger", default=None, help="ledger path (default <outdir>/_ledger.json)")
    ap.add_argument("--retry-timeouts", action="store_true", help="rerun jobs already logged as timeouts")
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    jobs = [json.loads(l) for l in open(a.jobs)]
    ledger = Ledger(a.ledger or os.path.join(a.outdir, "_ledger.json"), a.budget) if a.budget is not None else None
    stats = {"ok": 0, "skip": 0, "fail": 0, "timeout": 0, "budget": 0}
    if not a.retry_timeouts:
        old = timed_out_ids(a.outdir)
        stats["timeout"] = sum(j["id"] in old for j in jobs)
        jobs = [j for j in jobs if j["id"] not in old]
    if ledger is not None:
        print(f"ledger {ledger.path}: ${ledger.d['cost_usd']:.2f} of ${a.budget:.2f}", flush=True)
    done = cost = 0.0
    n = len(jobs)
    t0 = time.time()
    with ThreadPoolExecutor(a.workers) as ex:
        futs = {ex.submit(run_one, j, a.outdir, a.timeout, ledger): j for j in jobs}
        for fu in as_completed(futs):
            st, c = fu.result()
            stats[st] += 1
            cost += c
            done += 1
            if done % 10 == 0 or done == n:
                print(f"[{time.strftime('%H:%M:%S')}] {int(done)}/{n} {stats} cost=${cost:.2f} "
                      f"elapsed={time.time() - t0:.0f}s", flush=True)
    if stats["budget"]:
        print(f"BUDGET reached: {stats['budget']} jobs not started (ledger ${ledger.d['cost_usd']:.2f})", flush=True)
    print("DONE", stats, f"cost=${cost:.2f}", flush=True)


if __name__ == "__main__":
    sys.exit(main())
