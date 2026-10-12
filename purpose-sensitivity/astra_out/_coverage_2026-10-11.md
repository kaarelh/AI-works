# Purpose-sensitivity coverage

Date: 2026-10-11 UTC
Branch: `codex/purpose-sensitivity-astra-2026-10-11`
Base: `claude/friendly-sagan-hngxoz` at `d43096becd224f03f0d3e76554d76491e15a7708`.
All ten handoff manifest checks passed. The existing checkout was reused.

## Outcome

Stopped under the requested “neither route works” fallback. No study answers were produced; no complete smoke suite or main batch ran.

Route A: `codex-cli 0.159.2` is installed and reports ChatGPT authentication. One single-job probe through the supplied runner failed before model generation:

```
Error: failed to initialize in-process app-server client: Read-only file system (os error 30)
```

The CLI requires creating/opening `$CODEX_HOME/installation_id` for writing, including in ephemeral mode. This environment's CLI home is read-only and that file is absent. Version-matched source confirms cache/log directory overrides cannot redirect this write; `codex exec` always starts the in-process server, so omitting `--no-daemon` cannot avoid it. Authentication and the CLI home were left unchanged. The separate PATH-alias warning also concerned the read-only filesystem. No rate limit, usage limit, or account-level warning was observed.

Route B: `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GOOGLE_API_KEY`, and `OPENROUTER_API_KEY` were absent. Only presence was checked; no secret values were read or printed. No alternative model CLI was found.

## Models

The CLI catalog lists these candidates; listing is not proof of generation access.

| Exact model ID | Display name | Developer | Run status |
|---|---|---|---|
| gpt-6.1-sol | GPT-6.1 Sol | OpenAI | One failed initialization probe; zero answers |
| gpt-6-astra | GPT-6 Astra | OpenAI | Not called; same CLI prerequisite unavailable |
| gpt-6-luna | GPT-6 Luna | OpenAI | Not called; same CLI prerequisite unavailable |
| gpt-5.6-sol | GPT-5.6 Sol | OpenAI | Not called; same CLI prerequisite unavailable |

## Exact attempted command

Backend: `cmd`; stdin: `prompt`.

```sh
/opt/codex/bin/codex --no-daemon -a never exec --ignore-user-config --ignore-rules --ephemeral --skip-git-repo-check --sandbox read-only -C {workdir} -m {model} -c 'model_instructions_file="{system_file}"' -c 'project_doc_max_bytes=0' -c 'skills.include_instructions=false' -c 'skills.bundled.enabled=false' -c 'web_search="disabled"' -c 'features.shell_tool=false' -c 'features.unified_exec=false' -c 'features.apply_patch_freeform=false' -c 'features.view_image=false' -c 'features.apps=false' -c 'features.plugins=false' -c 'features.memories=false' -c 'features.memory_tool=false' -c 'features.multi_agent=false' -c 'features.multi_agent_v2=false' -c 'features.js_repl=false' -c 'features.code_mode=false' -c 'tools.update_plan.enabled=false' --color never --json -o {out_file} -
```

The runner invocation used `s2_smoke.jsonl`, `--ordered --workers 2 --max-calls 2600`, and `--limit 1 --retries 1` for the initial probe. Temperature, reasoning effort, and output length remained unspecified/default. The failure log and runner stdout are retained under this directory.

Each command was configured for a fresh ephemeral session in the runner's temporary directory, with the system file passed as model instructions and the user prompt sent on stdin. Repository documentation, user configuration, skills, memory, subagents, shell access, web search, image viewing, apps/plugins, code mode and planning were disabled by the recorded flags, with a read-only sandbox. **Tools were not verified fully off:** initialization failed, and the version's catalog/source indicates `apply_patch` may remain advertised despite its feature flag; some models also advertise a clock tool. No model tool use occurred.

## Other capabilities and totals

Orchestration subagents are available. They were used only to inspect CLI capabilities and public implementation details, never to answer study jobs. No Claude model was invoked. This agent did not answer, rewrite, summarize, or evaluate any study prompt or output.

Ledger totals: **1 counted command attempt, 0 successful answers, 1 error, 0 API blocks**. The attempt failed locally before generation; it is not a confirmed API request. The command backend supplies no token/cost telemetry, so the ledger's zero token counts and `$0.00` estimate are not measurements of usage or cost. No calls were made outside the supplied runner.
