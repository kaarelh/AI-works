# Follow-up for GPT-Astra (after its first attempt: codex exec failed on a read-only CODEX_HOME)

Paste everything below the line into the same Astra conversation.

---

Thanks, that was exactly right. Please retry Route A with a writable Codex home. I authorise the following steps:

1. **Make a writable home.** Create a private directory outside the repo, e.g. `mkdir -m 700 /tmp/codex-home`. Copy into it the files the CLI needs from the current `CODEX_HOME`: at least `auth.json`, plus `config.toml` if it exists. Use a copy rather than a symlink, so a token refresh can write.
   - Leave the original `CODEX_HOME` unchanged.
   - Never print, commit or push these files.
   - Delete `/tmp/codex-home` when the runs are finished.
2. **Point the CLI at it.** Prefix your command template with `CODEX_HOME=/tmp/codex-home ` and keep every other flag you recorded: `--ephemeral`, read-only sandbox, `-a never`, `model_instructions_file`, tools off, `-o {out_file}`, prompt on stdin.
3. **Probe once.** Rerun the one-job probe (`--limit 1 --retries 1`) for `gpt-6-astra`.
   - If it still fails before generation, update `_coverage.md` with the error, push, and stop.
   - If it produces an answer, check only that the saved record holds a model's answer to the prompt, and that the stdout events (the `--json` stream) show no tool calls. Do not judge the answer's content.
4. **Run.** If the probe works, continue from step 3 of the original instructions (the smoke test for each model), then step 4 (the main runs in the listed order). Use these four models:

   | `--model` | `--display-name` | `--developer` |
   |---|---|---|
   | `gpt-6-astra` | GPT-6 Astra | OpenAI |
   | `gpt-6.1-sol` | GPT-6.1 Sol | OpenAI |
   | `gpt-6-luna` | GPT-6 Luna | OpenAI |
   | `gpt-5.6-sol` | GPT-5.6 Sol | OpenAI |

   Use the same command template for all four (only `{model}` changes), `--cmd-stdin prompt`, `--ordered`, `--workers 2`, and `--max-calls 2600` across all models. If you hit a usage or rate limit, push what you have and tell Kaarel; reruns skip finished jobs.
5. **Report tool use.** In `_coverage.md`, record the final command template (with the `CODEX_HOME` prefix) and, for each model, whether any job's event stream shows a tool call (for example `apply_patch` or a clock tool). Report counts, not the content of any answer.

All the original rules still apply. Never answer, rewrite, summarise or evaluate any study prompt or output yourself. Never use a Claude model. Change nothing outside `purpose-sensitivity/astra_out/`. If you get any account-level warning, stop immediately, do not run `s2_ctx1_rungs.jsonl`, and tell Kaarel.
