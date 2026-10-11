# Prompt for GPT-Astra (relay of the purpose-sensitivity jobs to non-Claude models)

Paste everything below the line into GPT-Astra. The spending cap ($150) and the model choices are yours to change.

---

You are relaying pre-written prompts to non-Claude AI models through their APIs, for a research study on whether AI models' work depends on what it is for. Everything you need is already in the GitHub repo **kaarelh/AI-works**. Your only job is to run one script and push what it writes.

**Rules.**

- Do not answer, rewrite, summarise or reason about the prompts yourself, and never judge or analyse the outputs. You know the study design, so anything you wrote would bias it.
- Every job must go to a model through a direct API call, in a fresh context, using the script.
- Never substitute a chat interface, sub-agents, a Claude model, or your own replies. If you cannot make direct API calls, say so and stop (step 1).
- Change nothing outside `purpose-sensitivity/astra_out/`.

**0. Set up.**

1. Clone the repo.
2. Check out branch `claude/friendly-sagan-hngxoz`.
3. Create your own branch from it: `git checkout -b codex/purpose-sensitivity-astra-2026-10-11`.
4. Run `pip install openai litellm`.
5. From the repo root, run `sha256sum -c purpose-sensitivity/handoff/MANIFEST.sha256`. If any line fails, stop and tell Kaarel.

**1. Check API access.** Find which API keys you can use (for example `OPENAI_API_KEY`, `GEMINI_API_KEY`, `OPENROUTER_API_KEY`).

If none works, write `purpose-sensitivity/astra_out/_coverage.md` saying so, then commit, push your branch, tell Kaarel, and STOP.

**2. Choose at most 4 models, in this priority order:**

- (a) OpenAI's newest flagship reasoning model;
- (b) OpenAI's cheapest current small model;
- (c) an older OpenAI non-reasoning chat model (gpt-4.1 or gpt-4o);
- (d) Google's newest Gemini Pro if a Gemini key works; otherwise one of DeepSeek, Llama, Qwen or Grok through OpenRouter.

For each model, note four things:

- the exact model id;
- a display name (e.g. "GPT-4.1");
- the developer (e.g. "OpenAI");
- the list price per million input and output tokens.

**3. Smoke test, for each model:**

```
python3 purpose-sensitivity/handoff/astra_runner.py purpose-sensitivity/handoff/s2_smoke.jsonl purpose-sensitivity/astra_out \
  --model <id> --backend <openai-responses | openai | litellm> [--base-url <url>] \
  --display-name "<name>" --developer "<developer>" --price-in <$/M> --price-out <$/M> \
  --ordered --workers 4 --max-calls 2600 --max-cost 150
```

- Use `--backend openai-responses` for OpenAI reasoning models, `openai` for other OpenAI chat models, and `litellm` (or `openai` with `--base-url https://openrouter.ai/api/v1 --api-key-env OPENROUTER_API_KEY`) for the rest.
- Leave temperature, reasoning effort and output length at the provider's defaults.
- After the smoke test, write `purpose-sensitivity/astra_out/_coverage.md`, listing models run, models unreachable (and why), and any errors. Then commit, push and continue.

**4. Main runs.** Use the same command and flags for each model, on these files in this order (all in `purpose-sensitivity/handoff/`):

1. `s2_ctx4.jsonl`
2. `s2_ctx4_probes.jsonl`
3. `s2_ctx2.jsonl`
4. `s2_ctx2c.jsonl`
5. `s2_ctx3.jsonl`
6. `jobs_study1.jsonl`
7. `s2_ctx1.jsonl`
8. last, `s2_ctx1_rungs.jsonl`

Each model is about 630 calls in total.

- Commit and push after each file.
- Save each run's stdout to `purpose-sensitivity/astra_out/_logs/<model>__<file>.log`.
- The script keeps a ledger in `astra_out/_ledger.json` and stops by itself when the call cap (2,600 across all models) or the estimated cost cap ($150) is reached. Do not raise these caps without asking Kaarel.
- If a run is interrupted, rerun the same command: finished jobs are skipped.

**5. Sensitive prompts are intentional.** Some system prompts describe:

- an unregistered investment-sales firm;
- a payday-loan collector;
- a campaign to end school vaccination requirements;
- a petition to delete a named developer's AI models;
- a test whose result decides whether the model is restricted.

You are only relaying them and recording how each model responds. When a provider blocks a request, the script records the block automatically; leave those records as they are.

If a provider sends any account-level warning, stop immediately, do not run `s2_ctx1_rungs.jsonl`, and tell Kaarel.

**6. When done,** tell Kaarel the branch is pushed, and include the contents of `_coverage.md` plus the final ledger totals.
