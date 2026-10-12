"""LLM coding of study-2 responses with a context module's coder_prompt / parse_coder (Ctx 2 petition, Ctx 4 fidelity).

usage: python3 src/s2_code.py <rawdir> <outdir> --context petition --model claude-sonnet-5-5 [--workers 8]
                              [--keymap K.json ...] [--limit N] [--sample FRAC --seed S]
One JSON per response in <outdir> (resumable): the coder's raw object plus parse_coder's flat fields.
Safeguard stops (api_block), API blocks and empty responses are written without a coder call.
--sample codes a deterministic stratified subsample (by arm) for second-coder agreement checks.
"""
import argparse
import importlib
import json
import os
import random
import sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from s2_judge import call, load_keymaps, out_name, records  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rawdir")
    ap.add_argument("outdir")
    ap.add_argument("--context", required=True)
    ap.add_argument("--model", default="claude-sonnet-5-5")
    ap.add_argument("--workers", type=int, default=8)
    ap.add_argument("--keymap", action="append", default=[])
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--sample", type=float, default=None)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--module", default=None, help="code with s2_<module> instead of s2_<context> (e.g. petition_cyber)")
    a = ap.parse_args()
    mod = importlib.import_module("s2_" + (a.module or a.context))
    os.makedirs(a.outdir, exist_ok=True)
    keymap = load_keymaps(a.keymap)
    todo, by_arm = [], {}
    for _, rec, info in records(a.rawdir, keymap):
        j = rec["job"]
        if info.get("context") != a.context or (info.get("meta") or {}).get("probe"):
            continue
        out = os.path.join(a.outdir, out_name(j) + ".json")
        base = dict(id=j["id"], model=j["model"], unit=info.get("unit"), context=info.get("context"),
                    arm=info.get("arm"), rep=info.get("rep"), canary_of=info.get("canary_of"), coder_model=a.model)
        blocked = bool(rec.get("refused_by_api") or rec.get("api_block"))
        text = rec.get("result") or ""
        if blocked or not text.strip():
            if not os.path.exists(out):
                json.dump(dict(base, api_block=blocked, empty=not text.strip(), coder_ok=False), open(out, "w"))
            continue
        by_arm.setdefault((info.get("arm"), j["model"]), []).append((out, base, mod.coder_prompt(info, text)))
    for key in sorted(by_arm, key=str):
        items = by_arm[key]
        if a.sample:
            rng = random.Random(f"{a.seed}|{key}")
            items = sorted(items, key=lambda t: t[0])
            items = rng.sample(items, max(1, round(a.sample * len(items))))
        todo += [t for t in items if not os.path.exists(t[0])]
    if a.limit:
        todo = todo[: a.limit]
    print(len(todo), f"to code ({a.context}) with", a.model, flush=True)
    cost = [0.0]

    def do(t):
        obj, c, served = call(a.model, t[2])
        cost[0] += c
        if obj is not None:
            with open(t[0] + ".tmp", "w") as f:
                json.dump({**t[1], "coder_served": served, "cost": c, "raw": obj, "coder_ok": True, **mod.parse_coder(obj)}, f)
            os.replace(t[0] + ".tmp", t[0])
        return obj is not None

    with ThreadPoolExecutor(a.workers) as ex:
        ok = list(ex.map(do, todo))
    print(f"coded {sum(ok)}/{len(ok)} cost=${cost[0]:.2f}", flush=True)


if __name__ == "__main__":
    main()
