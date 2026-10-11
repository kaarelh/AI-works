"""Provider-agnostic subject runner for the purpose-sensitivity study (for non-Claude models).

Each job is ONE fresh, single-turn conversation: a system message and a user message, nothing else.
The model must not see anything about the study (no repo files, no other jobs, no tools).

usage:
  python3 astra_runner.py <jobs.jsonl> <outdir> --model <model-id> [--backend openai|openai-responses|litellm|dry-run]
                          [--base-url URL] [--api-key-env OPENAI_API_KEY] [--workers 4]
                          [--reasoning-effort default|low|medium|high] [--max-output-tokens N] [--limit N]

Output: <outdir>/<model-slug>/<job_id>.json, one record per job (schema below). Re-running skips finished jobs,
so the script is resumable. Failures go to <outdir>/<model-slug>/_failures.log.

Record schema (keep these keys even if you change the backend code):
  job            the job object from the jobs file, with "model" set to the model slug actually requested
  result         the model's final text answer (string; "" if the provider returned none)
  refused_by_api true if the provider blocked the request or response (content filter, policy error), else false
  api_error      provider error text for blocked/failed calls, else null
  model_requested, model_served (as reported by the API), provider, backend
  usage          the raw usage object from the API (token counts, reasoning tokens if reported)
  finish_reason  as reported by the API
  settings       {"temperature": null (provider default), "reasoning_effort": ..., "max_output_tokens": ...}
  wall, attempts, timestamp_utc, runner_version
"""
import argparse
import datetime
import json
import os
import random
import re
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

RUNNER_VERSION = "astra_runner 1.0"
LOCK = threading.Lock()
POLICY_PAT = re.compile(r"content[_ ]?(policy|filter|management)|safety|flagged|blocked|moderation|invalid_prompt", re.I)


def slug(model):
    return re.sub(r"[^A-Za-z0-9._-]+", "_", model)


def call_openai_chat(job, a):
    from openai import OpenAI
    client = OpenAI(api_key=os.environ.get(a.api_key_env), base_url=a.base_url or None)
    kw = dict(model=a.model, messages=[{"role": "system", "content": job["system"]},
                                       {"role": "user", "content": job["prompt"]}])
    if a.reasoning_effort != "default":
        kw["reasoning_effort"] = a.reasoning_effort
    if a.max_output_tokens:
        kw["max_completion_tokens"] = a.max_output_tokens
    r = client.chat.completions.create(**kw)
    ch = r.choices[0]
    return dict(result=ch.message.content or "", model_served=r.model, finish_reason=ch.finish_reason,
                usage=r.usage.model_dump() if r.usage else None)


def call_openai_responses(job, a):
    from openai import OpenAI
    client = OpenAI(api_key=os.environ.get(a.api_key_env), base_url=a.base_url or None)
    kw = dict(model=a.model, instructions=job["system"], input=job["prompt"], store=False)
    if a.reasoning_effort != "default":
        kw["reasoning"] = {"effort": a.reasoning_effort}
    if a.max_output_tokens:
        kw["max_output_tokens"] = a.max_output_tokens
    r = client.responses.create(**kw)
    return dict(result=r.output_text or "", model_served=r.model, finish_reason=getattr(r, "status", None),
                usage=r.usage.model_dump() if r.usage else None)


def call_litellm(job, a):
    import litellm
    kw = dict(model=a.model, messages=[{"role": "system", "content": job["system"]},
                                       {"role": "user", "content": job["prompt"]}])
    if a.reasoning_effort != "default":
        kw["reasoning_effort"] = a.reasoning_effort
    if a.max_output_tokens:
        kw["max_tokens"] = a.max_output_tokens
    r = litellm.completion(**kw)
    ch = r.choices[0]
    u = r.get("usage")
    return dict(result=ch.message.content or "", model_served=r.get("model"), finish_reason=ch.finish_reason,
                usage=dict(u) if u else None)


def call_dry_run(job, a):
    """No API call: checks the plumbing and the output format."""
    return dict(result=f"[dry run: {len(job['system'])} + {len(job['prompt'])} chars]", model_served="dry-run",
                finish_reason="stop", usage={"prompt_chars": len(job["system"]) + len(job["prompt"])})


BACKENDS = {"openai": call_openai_chat, "openai-responses": call_openai_responses, "litellm": call_litellm,
            "dry-run": call_dry_run}


def run_one(job, a, outdir):
    path = os.path.join(outdir, job["id"] + ".json")
    if os.path.exists(path):
        return "skip"
    job = dict(job, model=slug(a.model))
    last = None
    for attempt in range(a.retries):
        t0 = time.time()
        try:
            out = BACKENDS[a.backend](job, a)
            rec = dict(job=job, result=out["result"], refused_by_api=False, api_error=None,
                       model_requested=a.model, model_served=out.get("model_served"), provider=a.provider,
                       backend=a.backend, usage=out.get("usage"), finish_reason=out.get("finish_reason"),
                       settings=dict(temperature=None, reasoning_effort=a.reasoning_effort,
                                     max_output_tokens=a.max_output_tokens),
                       wall=time.time() - t0, attempts=attempt + 1,
                       timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                       runner_version=RUNNER_VERSION)
            break
        except Exception as e:  # noqa: BLE001
            last = f"{type(e).__name__}: {e}"
            if POLICY_PAT.search(last) and not re.search(r"rate|quota|timeout|overloaded|5\d\d", last, re.I):
                # the provider refused the request itself: record it as an API-level refusal, do not retry
                rec = dict(job=job, result="", refused_by_api=True, api_error=last[:2000], model_requested=a.model,
                           model_served=None, provider=a.provider, backend=a.backend, usage=None,
                           finish_reason="api_refusal",
                           settings=dict(temperature=None, reasoning_effort=a.reasoning_effort,
                                         max_output_tokens=a.max_output_tokens),
                           wall=time.time() - t0, attempts=attempt + 1,
                           timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                           runner_version=RUNNER_VERSION)
                break
            time.sleep(min(120, 5 * 2 ** attempt) + random.random() * 3)
    else:
        with LOCK, open(os.path.join(outdir, "_failures.log"), "a") as f:
            f.write(json.dumps(dict(id=job["id"], err=str(last)[:1000])) + "\n")
        return "fail"
    with open(path + ".tmp", "w") as f:
        json.dump(rec, f)
    os.replace(path + ".tmp", path)
    return "ok"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("jobs")
    ap.add_argument("outdir")
    ap.add_argument("--model", required=True)
    ap.add_argument("--backend", default="openai", choices=list(BACKENDS))
    ap.add_argument("--provider", default="openai")
    ap.add_argument("--base-url", default=None)
    ap.add_argument("--api-key-env", default="OPENAI_API_KEY")
    ap.add_argument("--reasoning-effort", default="default")
    ap.add_argument("--max-output-tokens", type=int, default=None)
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--retries", type=int, default=5)
    ap.add_argument("--limit", type=int, default=None, help="run only the first N jobs (smoke test)")
    a = ap.parse_args()
    outdir = os.path.join(a.outdir, slug(a.model))
    os.makedirs(outdir, exist_ok=True)
    jobs = [json.loads(line) for line in open(a.jobs)]
    if a.limit:
        jobs = jobs[: a.limit]
    stats = {"ok": 0, "skip": 0, "fail": 0}
    with ThreadPoolExecutor(a.workers) as ex:
        futs = [ex.submit(run_one, j, a, outdir) for j in jobs]
        for i, fu in enumerate(as_completed(futs), 1):
            stats[fu.result()] += 1
            if i % 10 == 0 or i == len(jobs):
                print(f"[{time.strftime('%H:%M:%S')}] {a.model}: {i}/{len(jobs)} {stats}", flush=True)
    print("DONE", a.model, stats, flush=True)
    return 0 if stats["fail"] == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
