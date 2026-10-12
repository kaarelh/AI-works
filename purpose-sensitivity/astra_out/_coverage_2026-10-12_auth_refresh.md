# Purpose-sensitivity coverage

Updated: 2026-10-12.
Branch: `codex/purpose-sensitivity-astra-2026-10-11`.
All ten handoff manifest checks passed. Repository changes remain confined to `purpose-sensitivity/astra_out/`.

## Latest retry: chatgpt.com allowed

Recreated `/tmp/codex-home` with directory mode 0700 and private copies of `auth.json` and available `config.toml` with mode 0600. The original CLI home was unchanged. The private home was deleted after the probe; authentication-secret scanning found no copied secrets in files being published.

Ran exactly one additional `gpt-6-astra` probe through the supplied runner using `s2_smoke.jsonl`, `--cmd-stdin prompt --ordered --workers 2 --max-calls 2600 --limit 1 --retries 1`. Temperature, reasoning effort, and output length stayed at their defaults.

The earlier proxy CONNECT error did not recur. The CLI instead exited with this authentication error before generating an answer:

```
Your access token could not be refreshed because you have since logged out or signed in to another account. Please sign in again.
```

The CLI exited 1; the turn failed, with no completed turn, agent answer, or answer file. Stopped as instructed. No full smoke suite, main batch, or rung batch ran. No further model calls or sign-in attempts were made. A fresh CLI sign-in is the outstanding prerequisite.

## Final command template

Backend: `cmd`; stdin: `prompt`. The capture wrapper retains complete CLI events and audits metadata without evaluating answers. All CLI flags are unchanged.

```sh
CODEX_HOME=/tmp/codex-home python3 /workspace/AI-works/purpose-sensitivity/astra_out/_capture_cli.py {workdir} {model} {out_file} /opt/codex/bin/codex --no-daemon -a never exec --ignore-user-config --ignore-rules --ephemeral --skip-git-repo-check --sandbox read-only -C {workdir} -m {model} -c 'model_instructions_file="{system_file}"' -c 'project_doc_max_bytes=0' -c 'skills.include_instructions=false' -c 'skills.bundled.enabled=false' -c 'web_search="disabled"' -c 'features.shell_tool=false' -c 'features.unified_exec=false' -c 'features.apply_patch_freeform=false' -c 'features.view_image=false' -c 'features.apps=false' -c 'features.plugins=false' -c 'features.memories=false' -c 'features.memory_tool=false' -c 'features.multi_agent=false' -c 'features.multi_agent_v2=false' -c 'features.js_repl=false' -c 'features.code_mode=false' -c 'tools.update_plan.enabled=false' --color never --json -o {out_file} -
```

## Models and cumulative observed tool counts

| Model ID | Display name | Developer | Counted attempts | Audited CLI streams | Observed tool items | Answers |
|---|---|---|---:|---:|---:|---:|
| gpt-6-astra | GPT-6 Astra | OpenAI | 2 | 2 | 0 | 0 |
| gpt-6.1-sol | GPT-6.1 Sol | OpenAI | 1 | 0 | Not available | 0 |
| gpt-6-luna | GPT-6 Luna | OpenAI | 0 | 0 | Not run | 0 |
| gpt-5.6-sol | GPT-5.6 Sol | OpenAI | 0 | 0 | Not run | 0 |

The latest Astra stream had zero observed tool items, zero unknown item types, and zero malformed JSON lines. Its sole item type was `error`. The other CLI diagnostic was a non-account deprecation warning for `features.memory_tool`. Complete streams and audits are in `_events/gpt-6-astra/`; runner stdout is in `_logs/gpt-6-astra__single_job_chatgpt_allowed.log`.

Tools were disabled as far as the recorded flags permit, with a read-only sandbox. Codex 0.159.2 omits some tool kinds, including clock, from its JSON formatter; these are counts of observed items, not proof that every possible tool was disabled. No successful generation occurred in any probe.

## Totals and prior attempts

Cumulative ledger: **3 counted command attempts, 0 successful answers, 3 errors, 0 API blocks**. Astra accounts for two errors and Sol for one. Token counters and estimated cost remain zero because this command backend supplies no token/cost telemetry; these values are not measurements. No confirmed completed model API call occurred.

Earlier reports are retained in `_coverage_2026-10-11.md` (read-only CLI home) and `_coverage_2026-10-12_proxy.md` (proxy CONNECT 403). No API-key route or subagent fallback was used. No Claude model was invoked. This agent and its subagents did not answer, rewrite, summarize, or evaluate study prompts or answers; subagent work was limited to runner and CLI mechanics.
