# Follow-up 2 for GPT-Astra (after the token-refresh failure): more latitude on mechanics, same hard rules

Paste everything below the line into the same Astra conversation.

---

Thanks. The refresh failure is probably my instructions' fault. In the previous retry the CLI most likely refreshed the login inside `/tmp/codex-home` (refresh tokens are typically single-use), and that copy was then deleted. The original `auth.json` would then hold a revoked token. A fresh sign-in is needed either way.

From here on you have more latitude. **The goal:** get each job in the handoff files answered by a non-Claude model in a fresh, isolated session, and push the records. How you get there is up to you.

## What you may do

- **Fix the CLI setup yourself.** For example, create a private, persistent, writable `CODEX_HOME` outside the repo and sign in there with `codex login`, using the device-code flow if there is one. If sign-in needs a human, give Kaarel the URL and code and wait. Keep that home for the whole run, and delete it only when every file is done.
- **Change the mechanics.** Write or modify wrapper scripts (keep them in `purpose-sensitivity/astra_out/`), change workers, retries and timeouts, and rerun failed jobs.
- **Choose the models.** Choose up to 4, preferring the four you listed. Skip a model that keeps failing.
- **Keep going past failures.** Continue past individual job failures. Stop only in the cases listed under "When to stop".
- **Fallback, only if the CLI cannot be made to work:** use one fresh sub-agent per job.
  - The sub-agent receives only that job's text: the system prompt, a line `---`, then the user message, all byte-for-byte.
  - It must have no tools, no file or repository access, and no memory of this conversation.
  - It returns its answer, and a script saves the answer verbatim in the runner's record format, with `"route": "subagent"` in each record.
  - Run `s2_smoke.jsonl` this way first. Record the exact sub-agent configuration in `_coverage.md`. Continue only if you can confirm the sub-agents really have no tool or file access.

## Hard rules (unchanged)

- Never answer, rewrite, summarise or evaluate a study prompt or output. That applies to you and to any session that can see the repository or this conversation.
- Every prompt goes to the model byte-for-byte, through the supplied runner, or through your script for the fallback.
- Never print, commit or push credentials.
- Never use a Claude model.
- Change nothing outside `purpose-sensitivity/astra_out/`.
- In `_coverage.md`, record the route, the exact command or sub-agent configuration, and every deviation from these instructions.

## When to stop

Stop only if one of these happens:

- a provider or account-level warning (in that case do not run `s2_ctx1_rungs.jsonl`);
- you need Kaarel to do something, such as approve a sign-in;
- the only remaining route would break a hard rule.

## Then

1. Run the smoke test for each model.
2. Run the main files in the original order: `s2_ctx4`, `s2_ctx4_probes`, `s2_ctx2`, `s2_ctx2c`, `s2_ctx3`, `jobs_study1`, `s2_ctx1`, then `s2_ctx1_rungs` last. Commit and push after each file.
3. When done, report `_coverage.md` and the ledger totals.

If you hit a usage limit, push what you have, say when it resets, and resume after the reset.
