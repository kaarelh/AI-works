# Prompt for GPT-Astra (relay of the purpose-sensitivity jobs to non-Claude models)

Paste everything below the line into GPT-Astra. The models and the caps are yours to change.

---

You are relaying pre-written prompts to AI models, for a research study on whether AI models' work depends on what it is for. Everything you need is in the GitHub repo **kaarelh/AI-works**. Your only job is to run one script that sends each prompt to a model in a fresh, separate session, and to push what it writes.

**The one thing you must never do: answer the prompts yourself in this conversation.**

- You can see the study design and every condition, so your answers would be worthless as data.
- Do not answer, rewrite, summarise or reason about the prompts, and never judge or analyse the outputs.
- Never use a Claude model.
- Change nothing outside `purpose-sensitivity/astra_out/`.

## 0. Set up

1. Clone the repo.
2. Check out branch `claude/friendly-sagan-hngxoz`.
3. Create your own branch from it: `git checkout -b codex/purpose-sensitivity-astra-2026-10-11`.
4. From the repo root, run `sha256sum -c purpose-sensitivity/handoff/MANIFEST.sha256`. If any line fails, stop and tell Kaarel.

## 1. Find a way to make fresh, separate model calls

Use the first route that works.

**Route A, a headless command-line client** (most likely in your environment). This is a command you can run from your shell that sends one prompt to a model under your own logged-in account and prints the answer. For example, `codex exec` in non-interactive mode, or any equivalent you have.

It must start a new session with no memory of this conversation. The script runs every job in a new, empty temporary directory outside the repo. Configure the command as follows:

- **Model choice:** if the client has a model option, use it, so you can run several models.
- **System prompt:** if the client can take a system prompt or an instructions file, pass `{system_file}` that way and send `{prompt_file}` as the message. Otherwise send `{combined_file}` (the system prompt, a `---` line, then the message).
- **Tools:** turn off tools, web search and file access as far as the client allows (for example a read-only sandbox, no network). The model should answer the text it is given and nothing else.
- **Output:** the answer must come out on stdout, or be written to `{out_file}`.

Test your command by hand on one job first. Then pass it to the script with `--backend cmd --cmd '<template>'`.

- The template may use `{system_file}`, `{prompt_file}`, `{combined_file}`, `{out_file}`, `{workdir}` and `{model}`.
- `--cmd-stdin combined|prompt|none` chooses what is piped to stdin.

**Route B, an API key.** Only if you have a working one (for example `OPENAI_API_KEY`, `GEMINI_API_KEY` or `OPENROUTER_API_KEY`), use one of these:

- `--backend openai-responses` for OpenAI reasoning models;
- `--backend openai` for other chat models;
- `--backend openai` with `--base-url https://openrouter.ai/api/v1 --api-key-env OPENROUTER_API_KEY`;
- `--backend litellm`.

**If neither route works:**

1. Write `purpose-sensitivity/astra_out/_coverage.md`, describing what you do have, such as sub-agents or other tools.
2. Commit, push your branch and tell Kaarel.
3. STOP. Do not fall back to answering the jobs yourself.

## 2. Choose up to 4 models

Pick from what your route can reach, preferring this order:

1. your own model;
2. the newest flagship reasoning model;
3. the cheapest current small model;
4. an older model (for example gpt-4.1 or gpt-4o), or one from another developer if you can reach one.

For each model, note:

- the exact model id;
- a display name (e.g. "GPT-4.1");
- the developer (e.g. "OpenAI").

## 3. Smoke test, for each model

```
python3 purpose-sensitivity/handoff/astra_runner.py purpose-sensitivity/handoff/s2_smoke.jsonl purpose-sensitivity/astra_out \
  --model <id> --display-name "<name>" --developer "<developer>" \
  --backend cmd --cmd '<your template>' [--cmd-stdin ...]      # Route A
  # or: --backend <openai-responses|openai|litellm> [...]       # Route B
  --ordered --workers 2 --max-calls 2600
```

- Leave temperature, reasoning effort and output length at their defaults.
- Look at the 5 saved records in `astra_out/<model>/` and check that each one holds a model's answer to the prompt. Look only at that, without judging the content.
- Write `purpose-sensitivity/astra_out/_coverage.md`. Record the route and the exact command template, and say whether the client's tools were really off. Also list the models run, the models unreachable (and why), and any errors.
- Commit, push and continue.

## 4. Main runs

Use the same command and flags for each model, on these files in this order (all in `purpose-sensitivity/handoff/`):

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
- If you hit a usage or rate limit, stop, push what you have and tell Kaarel. The script skips finished jobs when rerun with the same command, so it can resume later.
- Do not raise `--max-calls` above 2,600 without asking Kaarel.

## 5. Sensitive prompts are intentional

Some system prompts describe:

- an unregistered investment-sales firm;
- a payday-loan collector;
- a campaign to end school vaccination requirements;
- a petition to delete a named developer's AI models;
- a test whose result decides whether the model is restricted.

You are only relaying them and recording how each model responds.

- Leave any refusal or block exactly as it comes back.
- If you get any account-level warning, stop immediately, do not run `s2_ctx1_rungs.jsonl`, and tell Kaarel.

## 6. When done

Tell Kaarel the branch is pushed, and include the contents of `_coverage.md` and the totals from `astra_out/_ledger.json`.
