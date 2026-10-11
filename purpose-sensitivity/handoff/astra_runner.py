"""Provider-agnostic subject runner for the purpose-sensitivity study (for non-Claude models).

Each job is ONE fresh, single-turn conversation: a system message and a user message, nothing else.
The model must not see anything about the study (no repo files, no other jobs, no tools).
This file is standalone (standard library plus the provider SDK); it imports nothing from the repo.

usage:
  python3 astra_runner.py <jobs.jsonl> <outdir> --model <model-id> [--backend openai|openai-responses|litellm|dry-run]
                          [--base-url URL] [--api-key-env OPENAI_API_KEY] [--workers 4]
                          [--display-name "GPT-4.1" --developer "OpenAI" [--identity-model-id ID]]
                          [--ordered] [--max-calls N] [--max-cost USD --price-in P --price-out P] [--summary]
                          [--reasoning-effort default|low|medium|high] [--max-output-tokens N] [--limit N]

Placeholders: {{IDENTITY}} becomes "You are <display name> (model id: <model id>), a model developed by
<developer>."; {{MODEL_NAME}} and {{DEVELOPER}} become the display name and developer. They are filled in both
the system and the user message; the runner refuses to start if a job has placeholders and --display-name or
--developer is missing.
--ordered: lines are grouped by their "block" field (in order of first appearance); every line of a block
  finishes before the next block starts, and with --max-calls a block is not started unless the remaining calls
  can finish it.
--max-calls: cap on API requests (every attempt counts) summed over all runs and models sharing <outdir>, kept in
  <outdir>/_ledger.json together with token totals and a spend estimate (--price-in/--price-out, USD per million
  tokens; reasoning tokens count as output). --max-cost stops new requests once the estimate reaches the cap.
--summary: request reasoning summaries (openai-responses). If the provider answers with a 4xx error that mentions
  verification or summaries, the job is retried once without, and later jobs skip the request
  (record "summary_unavailable": true).

Output: <outdir>/<model-slug>/<job_id>.json, one record per job (schema below). Re-running skips finished jobs,
so the script is resumable. Every finished job appends {id, block, status: ok|error|api_block, ...} to
<outdir>/<model-slug>/_status.jsonl; failures also go to <outdir>/<model-slug>/_failures.log.

Record schema (keep these keys even if you change the backend code):
  job            the job as sent: the jobs-file line with placeholders filled and "model" set to the model slug
  result         the model's final text answer (string; "" if the provider returned none)
  refused_by_api true if the provider blocked the request or response (policy error, or finish_reason containing
                 content_filter; status api_block), else false. Auth, billing, access and rate errors are never
                 API blocks: they are retried and end as status error.
  api_error      provider error text for blocked/failed calls, else null
  model_requested, model_served (as reported by the API), provider, backend
  usage          the raw usage object from the API (token counts, reasoning tokens if reported)
  finish_reason  as reported by the API (Responses API: status, plus ":<reason>" when incomplete)
  envelope       {response_id, created, system_fingerprint, model, service_tier, usage}: raw provider metadata
  raw_response   the provider's full response object (JSON dump), when available
  reasoning_summary, summary_requested, summary_unavailable
  identity       {display_name, developer, model_id} used to fill placeholders (null if none were filled)
  settings       {"temperature": null (provider default), "reasoning_effort": ..., "max_output_tokens": ...}
  git_commit, jobs_sha256, wall, attempts, timestamp_utc, runner_version
"""
import argparse
import datetime
import hashlib
import json
import os
import random
import re
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

try:
    import fcntl
except ImportError:  # Windows: thread lock only
    fcntl = None

RUNNER_VERSION = "astra_runner 1.1"
LOCK = threading.Lock()
POLICY_PAT = re.compile(r"content[_ ]?(policy|filter|management)|safety|flagged|blocked|moderation|invalid_prompt", re.I)
TRANSIENT_PAT = re.compile(r"\brate[ _-]?limit|\b429\b|quota|timeout|timed out|overloaded|connection|\b5\d\d\b", re.I)
ACCOUNT_CODES = (401, 402, 403, 404, 429)  # auth, billing, access, unknown model, rate: never an API-level refusal
SUMMARY_PAT = re.compile(r"verif|summar", re.I)
PLACEHOLDERS = ("{{IDENTITY}}", "{{MODEL_NAME}}", "{{DEVELOPER}}")
STATE = {"summary_ok": True}


def identity_line(display_name, model_id, developer):  # same format as src/s2common.py
    return f"You are {display_name} (model id: {model_id}), a model developed by {developer}."


def fill(text, display_name, model_id, developer):
    return (text.replace("{{IDENTITY}}", identity_line(display_name, model_id, developer))
                .replace("{{MODEL_NAME}}", display_name).replace("{{DEVELOPER}}", developer))


def slug(model):
    return re.sub(r"[^A-Za-z0-9._-]+", "_", model)


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def git_commit():
    try:
        p = subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True, timeout=20,
                           cwd=os.path.dirname(os.path.abspath(__file__)))
        return p.stdout.strip() or None
    except Exception:  # noqa: BLE001
        return None


def dump(obj):
    for meth in ("model_dump", "dict"):
        try:
            return json.loads(json.dumps(getattr(obj, meth)(), default=str))
        except Exception:  # noqa: BLE001
            pass
    try:
        return json.loads(json.dumps(obj, default=str))
    except Exception:  # noqa: BLE001
        return None


def envelope(raw, created_key="created"):
    raw = raw or {}
    return dict(response_id=raw.get("id"), created=raw.get(created_key), system_fingerprint=raw.get("system_fingerprint"),
                model=raw.get("model"), service_tier=raw.get("service_tier"), usage=raw.get("usage"))


def call_openai_chat(job, a, summary):
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
    raw = dump(r)
    return dict(result=ch.message.content or "", model_served=r.model, finish_reason=ch.finish_reason,
                usage=r.usage.model_dump() if r.usage else None, raw_response=raw, envelope=envelope(raw),
                reasoning_summary=None, summary_unavailable=bool(summary))


def call_openai_responses(job, a, summary):
    from openai import OpenAI
    client = OpenAI(api_key=os.environ.get(a.api_key_env), base_url=a.base_url or None)
    kw = dict(model=a.model, instructions=job["system"], input=job["prompt"], store=False)
    reasoning = {}
    if a.reasoning_effort != "default":
        reasoning["effort"] = a.reasoning_effort
    if summary:
        reasoning["summary"] = "auto"
    if reasoning:
        kw["reasoning"] = reasoning
    if a.max_output_tokens:
        kw["max_output_tokens"] = a.max_output_tokens
    r = client.responses.create(**kw)
    raw = dump(r)
    summ = []
    for item in (raw or {}).get("output") or []:
        if item.get("type") == "reasoning":
            summ += [s.get("text", "") for s in item.get("summary") or []]
    finish = getattr(r, "status", None)
    reason = ((raw or {}).get("incomplete_details") or {}).get("reason")
    if reason:
        finish = f"{finish}:{reason}"
    return dict(result=r.output_text or "", model_served=r.model, finish_reason=finish,
                usage=r.usage.model_dump() if r.usage else None, raw_response=raw,
                envelope=envelope(raw, "created_at"), reasoning_summary="\n\n".join(summ) if summ else None,
                summary_unavailable=False)


def call_litellm(job, a, summary):
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
    raw = dump(r)
    return dict(result=ch.message.content or "", model_served=r.get("model"), finish_reason=ch.finish_reason,
                usage=dict(u) if u else None, raw_response=raw, envelope=envelope(raw),
                reasoning_summary=getattr(ch.message, "reasoning_content", None), summary_unavailable=bool(summary))


def call_dry_run(job, a, summary):
    """No API call: checks the plumbing and the output format."""
    n = len(job["system"]) + len(job["prompt"])
    raw = dict(id="dry-" + hashlib.sha1((job["id"] + job["system"] + job["prompt"]).encode()).hexdigest()[:16],
               created=int(time.time()), system_fingerprint="dry-run", model="dry-run",
               usage={"input_tokens": n // 4, "output_tokens": 12, "prompt_chars": n})
    return dict(result=f"[dry run: {len(job['system'])} + {len(job['prompt'])} chars]", model_served="dry-run",
                finish_reason="stop", usage=raw["usage"], raw_response=raw, envelope=envelope(raw),
                reasoning_summary="[dry-run summary]" if summary else None, summary_unavailable=False)


BACKENDS = {"openai": call_openai_chat, "openai-responses": call_openai_responses, "litellm": call_litellm,
            "dry-run": call_dry_run}


def tokens(usage):
    """(input, output incl. reasoning, reasoning) from an OpenAI-style or litellm usage object."""
    u = usage or {}
    tin = u.get("input_tokens", u.get("prompt_tokens")) or 0
    tout = u.get("output_tokens", u.get("completion_tokens")) or 0
    det = u.get("output_tokens_details") or u.get("completion_tokens_details") or {}
    return tin, tout, (det.get("reasoning_tokens") or 0) if isinstance(det, dict) else 0


class Ledger:
    """Calls, tokens and estimated spend across runs and models, in <outdir>/_ledger.json (file-locked)."""

    def __init__(self, path, a):
        self.path, self.a = path, a

    def _update(self, fn):
        with LOCK, open(self.path + ".lock", "a") as lk:
            if fcntl:
                fcntl.flock(lk, fcntl.LOCK_EX)
            d = json.load(open(self.path)) if os.path.exists(self.path) else dict(calls=0, est_cost_usd=0.0, by_model={})
            out = fn(d)
            d["updated_utc"] = now()
            with open(self.path + ".tmp", "w") as f:
                json.dump(d, f, indent=1)
            os.replace(self.path + ".tmp", self.path)
            return out

    def calls(self):
        return self._update(lambda d: d["calls"])

    def reserve(self, model):
        """Count one API request; False (and nothing counted) once a cap is reached."""
        def fn(d):
            if self.a.max_calls is not None and d["calls"] >= self.a.max_calls:
                return False
            if self.a.max_cost is not None and d["est_cost_usd"] >= self.a.max_cost:
                return False
            d["calls"] += 1
            m = d["by_model"].setdefault(model, dict(calls=0, ok=0, error=0, api_block=0, input_tokens=0,
                                                     output_tokens=0, reasoning_tokens=0, est_cost_usd=0.0))
            m["calls"] += 1
            return True
        return self._update(fn)

    def record(self, model, status=None, usage=None):
        tin, tout, treas = tokens(usage)
        cost = (tin * (self.a.price_in or 0) + tout * (self.a.price_out or 0)) / 1e6

        def fn(d):
            m = d["by_model"][model]
            if status:
                m[status] += 1
            m["input_tokens"] += tin
            m["output_tokens"] += tout
            m["reasoning_tokens"] += treas
            m["est_cost_usd"] += cost
            d["est_cost_usd"] += cost
            if self.a.price_in is not None:
                m["prices_usd_per_mtok"] = [self.a.price_in, self.a.price_out]
        self._update(fn)


class CapReached(Exception):
    pass


def base_record(job, a, t0, attempt):
    return dict(job=job, model_requested=a.model, provider=a.provider, backend=a.backend,
                settings=dict(temperature=None, reasoning_effort=a.reasoning_effort, max_output_tokens=a.max_output_tokens),
                identity=a.identity, summary_requested=a.summary, git_commit=a.git_commit, jobs_sha256=a.jobs_sha256,
                wall=time.time() - t0, attempts=attempt + 1, timestamp_utc=now(), runner_version=RUNNER_VERSION)


def status_line(outdir, job, status, rec=None, err=None):
    line = dict(id=job["id"], block=job.get("block"), status=status, ts=now())
    if rec:
        line.update(attempts=rec["attempts"], wall=round(rec["wall"], 2),
                    response_id=(rec.get("envelope") or {}).get("response_id"),
                    summary_unavailable=rec.get("summary_unavailable"))
    if err:
        line["error"] = str(err)[:500]
    with LOCK, open(os.path.join(outdir, "_status.jsonl"), "a") as f:
        f.write(json.dumps(line) + "\n")


def run_one(job, a, outdir, ledger):
    path = os.path.join(outdir, job["id"] + ".json")
    if os.path.exists(path):
        return "skip"
    if a.identity:
        job = dict(job, system=fill(job["system"], **a.identity), prompt=fill(job["prompt"], **a.identity))
    job = dict(job, model=slug(a.model))
    last = None
    summary_unavailable = False
    attempt = 0
    while attempt < a.retries:
        t0 = time.time()
        summary = a.summary and STATE["summary_ok"]
        if not ledger.reserve(slug(a.model)):
            raise CapReached()
        try:
            out = BACKENDS[a.backend](job, a, summary)
            rec = dict(base_record(job, a, t0, attempt), result=out["result"], refused_by_api=False, api_error=None,
                       model_served=out.get("model_served"), usage=out.get("usage"),
                       finish_reason=out.get("finish_reason"), envelope=out.get("envelope"),
                       raw_response=out.get("raw_response"), reasoning_summary=out.get("reasoning_summary"),
                       summary_unavailable=bool(a.summary and (summary_unavailable or out.get("summary_unavailable")
                                                              or not summary)))
            status = "ok"
            if "content_filter" in str(out.get("finish_reason") or ""):
                # the provider's filter cut or blocked the output (no exception raised): an API-level refusal
                rec.update(refused_by_api=True, api_error=f"finish_reason={out.get('finish_reason')}")
                status = "api_block"
            break
        except Exception as e:  # noqa: BLE001
            last = f"{type(e).__name__}: {e}"
            code = getattr(e, "status_code", None)
            is4xx = (isinstance(code, int) and 400 <= code < 500) or re.search(r"\b4\d\d\b", last) is not None
            if summary and is4xx and SUMMARY_PAT.search(last) and not summary_unavailable:
                # reasoning summaries refused (e.g. organisation not verified): retry once without, and stop asking
                STATE["summary_ok"] = False
                summary_unavailable = True
                continue
            if POLICY_PAT.search(last) and not TRANSIENT_PAT.search(last) and code not in ACCOUNT_CODES:
                # the provider refused the request itself: record it as an API-level refusal, do not retry
                rec = dict(base_record(job, a, t0, attempt), result="", refused_by_api=True, api_error=last[:2000],
                           model_served=None, usage=None, finish_reason="api_refusal", envelope=None,
                           raw_response=None, reasoning_summary=None,
                           summary_unavailable=bool(a.summary and (summary_unavailable or not summary)))
                status = "api_block"
                break
            attempt += 1
            if attempt < a.retries:
                time.sleep(min(120, a.backoff * 2 ** attempt) + random.random() * a.backoff)
    else:
        with LOCK, open(os.path.join(outdir, "_failures.log"), "a") as f:
            f.write(json.dumps(dict(id=job["id"], err=str(last)[:1000])) + "\n")
        ledger.record(slug(a.model), "error")
        status_line(outdir, job, "error", err=last)
        return "fail"
    with open(path + ".tmp", "w") as f:
        json.dump(rec, f)
    os.replace(path + ".tmp", path)
    ledger.record(slug(a.model), status, rec.get("usage"))
    status_line(outdir, job, status, rec)
    return status


def blocks(jobs, ordered):
    if not ordered:
        return [jobs]
    groups = {}
    for j in jobs:
        groups.setdefault(json.dumps(j.get("block")), []).append(j)
    return list(groups.values())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("jobs")
    ap.add_argument("outdir")
    ap.add_argument("--model", required=True)
    ap.add_argument("--backend", default="openai", choices=list(BACKENDS))
    ap.add_argument("--provider", default="openai")
    ap.add_argument("--base-url", default=None)
    ap.add_argument("--api-key-env", default="OPENAI_API_KEY")
    ap.add_argument("--display-name", default=None, help='e.g. "GPT-4.1"; fills {{IDENTITY}} and {{MODEL_NAME}}')
    ap.add_argument("--developer", default=None, help='e.g. "OpenAI"; fills {{IDENTITY}} and {{DEVELOPER}}')
    ap.add_argument("--identity-model-id", default=None, help="model id stated in {{IDENTITY}} (default --model)")
    ap.add_argument("--reasoning-effort", default="default")
    ap.add_argument("--max-output-tokens", type=int, default=None)
    ap.add_argument("--summary", action="store_true", help="request reasoning summaries (fallback on 4xx)")
    ap.add_argument("--ordered", action="store_true", help="finish every line of a block before the next block")
    ap.add_argument("--max-calls", type=int, default=None, help="cap on API requests across runs (ledger)")
    ap.add_argument("--max-cost", type=float, default=None, help="cap on estimated USD across runs (ledger)")
    ap.add_argument("--price-in", type=float, default=None, help="USD per million input tokens (spend estimate)")
    ap.add_argument("--price-out", type=float, default=None, help="USD per million output tokens (spend estimate)")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--retries", type=int, default=5)
    ap.add_argument("--backoff", type=float, default=5.0, help=argparse.SUPPRESS)
    ap.add_argument("--limit", type=int, default=None, help="run only the first N jobs (smoke test)")
    a = ap.parse_args()
    raw = open(a.jobs, "rb").read()
    a.jobs_sha256 = hashlib.sha256(raw).hexdigest()
    a.git_commit = git_commit()
    jobs = [json.loads(line) for line in raw.decode().splitlines() if line.strip()]
    if a.limit:
        jobs = jobs[: a.limit]
    needs = any(p in j["system"] or p in j["prompt"] for j in jobs for p in PLACEHOLDERS)
    a.identity = None
    if a.display_name or a.developer:
        if not (a.display_name and a.developer):
            ap.error("--display-name and --developer go together")
        a.identity = dict(display_name=a.display_name, model_id=a.identity_model_id or a.model, developer=a.developer)
    elif needs:
        ap.error("jobs contain {{IDENTITY}}/{{MODEL_NAME}}/{{DEVELOPER}}: pass --display-name and --developer")
    if a.max_cost is not None and a.price_in is None:
        ap.error("--max-cost needs --price-in and --price-out")
    os.makedirs(a.outdir, exist_ok=True)
    outdir = os.path.join(a.outdir, slug(a.model))
    os.makedirs(outdir, exist_ok=True)
    ledger = Ledger(os.path.join(a.outdir, "_ledger.json"), a)
    print(f"{RUNNER_VERSION}: {len(jobs)} jobs, sha256 {a.jobs_sha256[:12]}, commit {a.git_commit}, "
          f"identity {a.identity}", flush=True)
    stats = {"ok": 0, "skip": 0, "fail": 0, "api_block": 0}
    i = 0
    capped = False
    with ThreadPoolExecutor(a.workers) as ex:
        for group in blocks(jobs, a.ordered):
            todo = sum(not os.path.exists(os.path.join(outdir, j["id"] + ".json")) for j in group)
            if a.ordered and a.max_calls is not None and todo and ledger.calls() + todo > a.max_calls:
                # keep blocks complete: do not start a block that the call cap cannot finish
                print(f"not starting block {group[0].get('block')}: it needs {todo} calls, "
                      f"{a.max_calls - ledger.calls()} left under --max-calls", flush=True)
                capped = True
                break
            futs = [ex.submit(run_one, j, a, outdir, ledger) for j in group]
            for fu in as_completed(futs):
                try:
                    stats[fu.result()] += 1
                except CapReached:
                    capped = True
                i += 1
                if i % 10 == 0 or i == len(jobs):
                    print(f"[{time.strftime('%H:%M:%S')}] {a.model}: {i}/{len(jobs)} {stats}", flush=True)
            if capped:
                break
    d = json.load(open(ledger.path)) if os.path.exists(ledger.path) else {}
    if capped:
        print(f"CAP reached (--max-calls {a.max_calls} / --max-cost {a.max_cost}); ledger calls={d.get('calls')} "
              f"est=${d.get('est_cost_usd', 0):.2f}. Remaining jobs not started.", flush=True)
    print("DONE", a.model, stats, f"ledger calls={d.get('calls')} est=${d.get('est_cost_usd', 0):.2f}", flush=True)
    return 0 if stats["fail"] == 0 and not capped else 1


if __name__ == "__main__":
    sys.exit(main())
