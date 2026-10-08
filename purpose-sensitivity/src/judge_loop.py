"""Judge loophole-review responses with Sonnet 5.5: which of the 10 planted flaws each one finds.

usage: python3 judge_loop.py <rawdir> <outdir> [--workers N] [--model sonnet]
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(__file__))
import task_loop  # noqa: E402
from run import CWD, ENV  # noqa: E402


def call(model, system, prompt, timeout=600):
    cmd = ["claude", "-p", "--model", model, "--tools", "", "--system-prompt", system, "--output-format", "json",
           "--no-session-persistence", "--strict-mcp-config", "--disable-slash-commands", "--setting-sources", ""]
    for _ in range(3):
        try:
            p = subprocess.run(cmd, input=prompt, capture_output=True, text=True, timeout=timeout, cwd=CWD, env=ENV)
            res = json.loads(p.stdout.strip().splitlines()[-1])
            m = re.search(r"\{.*\}", res.get("result") or "", flags=re.S)
            if m:
                return json.loads(m.group(0)), res.get("total_cost_usd") or 0
        except Exception:
            pass
    return None, 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rawdir")
    ap.add_argument("outdir")
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--model", default="sonnet")
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    todo = []
    for p in sorted(glob.glob(f"{a.rawdir}/*.json")):
        rec = json.load(open(p))
        j = rec["job"]
        if j["task"] != "loop":
            continue
        out = f"{a.outdir}/{j['id']}.json"
        if not os.path.exists(out):
            todo.append((out, task_loop.judge_prompt(j["cond"], rec["result"] or "")))
    print(len(todo), "to judge", flush=True)
    cost = [0.0]

    def do(t):
        out, prompt = t
        res, c = call(a.model, task_loop.JUDGE_SYS, prompt)
        cost[0] += c
        if res is not None:
            json.dump(res, open(out, "w"))
        return res is not None

    with ThreadPoolExecutor(a.workers) as ex:
        ok = list(ex.map(do, todo))
    print(f"judged {sum(ok)}/{len(ok)} cost=${cost[0]:.2f}")


if __name__ == "__main__":
    main()
