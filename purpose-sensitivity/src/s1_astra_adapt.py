"""Convert the GPT study-1 records from the Astra handoff into study-1 record format, so the study-1 scorers,
coders and analysis run on them unchanged.

usage: python3 src/s1_astra_adapt.py runs/gpt_raw astra_out/gpt-6-astra astra_out/gpt-6.1-sol ...

Each astra_out/<model>/s1_<task>__<cond>__rNN.json becomes <outdir>/<task>__<cond>__<model>__rNN.json with
job = {id, model, cond, task, rep, system, prompt} and result = the saved answer. Provenance (route, requested
and reported model, attempts, timestamps) is kept under "astra". Token usage comes from the Codex event stream of
the saved call (astra_out/_events/<model>/<capture>.jsonl, turn.completed): output tokens, with reasoning tokens as
thinking tokens. Before writing, the system prompt and user message are checked byte for byte against a fresh build
of the study-1 prompts.
"""
import glob
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from conditions import system_prompt  # noqa: E402
from make_jobs import BUILD  # noqa: E402

CAPTURE = re.compile(r'"capture_id": "(ps_job_[A-Za-z0-9_\-]+)"')


def usage(src, rec):
    caps = CAPTURE.findall((rec.get("raw_response") or {}).get("stdout_tail") or "")
    if not caps:
        return None, None
    ev = os.path.join(os.path.dirname(os.path.abspath(src)), "_events", os.path.basename(os.path.abspath(src)), caps[-1] + ".jsonl")
    u = None
    if os.path.exists(ev):
        for line in open(ev):
            try:
                e = json.loads(line)
            except ValueError:
                continue
            if e.get("type") == "turn.completed":
                u = e.get("usage")
    if not u:
        return None, caps[-1]
    return dict(input_tokens=u.get("input_tokens"), cached_input_tokens=u.get("cached_input_tokens"),
                output_tokens=u.get("output_tokens"),
                output_tokens_details=dict(thinking_tokens=u.get("reasoning_output_tokens") or 0)), caps[-1]

def main():
    outdir, srcs = sys.argv[1], sys.argv[2:]
    os.makedirs(outdir, exist_ok=True)
    n = bad = 0
    for src in srcs:
        for p in sorted(glob.glob(os.path.join(src, "s1_*.json"))):
            rec = json.load(open(p))
            j = rec["job"]
            t, c, r, m = j["task"], j["cond"], j["rep"], j["model"]
            if j["system"] != system_prompt(c) or j["prompt"] != BUILD[t](c, 1000 + r):
                print("PROMPT MISMATCH", p)
                bad += 1
                continue
            jid = f"{t}__{c}__{m}__r{r:02d}"
            u, cap = usage(src, rec)
            out = dict(job=dict(id=jid, model=m, cond=c, task=t, rep=r, system=j["system"], prompt=j["prompt"]),
                       result=rec.get("result"), usage=u, cost=None, model_usage=None, duration_ms=None,
                       wall=rec.get("wall"), stop_reason=rec.get("finish_reason"), attempts=rec.get("attempts"),
                       astra=dict(source=os.path.relpath(p), handoff_id=j["id"], model_requested=rec.get("model_requested"),
                                  model_served=rec.get("model_served"), backend=rec.get("backend"),
                                  refused_by_api=rec.get("refused_by_api"), api_error=rec.get("api_error"),
                                  timestamp_utc=rec.get("timestamp_utc"), capture_id=cap))
            json.dump(out, open(os.path.join(outdir, jid + ".json"), "w"), indent=1)
            n += 1
    print(f"{n} records -> {outdir}; {bad} prompt mismatches")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
