# Purpose-sensitivity coverage

Updated: 2026-10-12.
Branch: `codex/purpose-sensitivity-astra-2026-10-11`.
Base: `claude/friendly-sagan-hngxoz` at `d43096becd224f03f0d3e76554d76491e15a7708`.
All ten handoff manifest entries passed again. Only `purpose-sensitivity/astra_out/` changed in the repository.

## Writable-home retry and outcome

As authorized, a private `/tmp/codex-home` directory (mode 0700) received copies of the original `auth.json` and available `config.toml` (mode 0600). The original CLI home was left unchanged. No authentication/configuration file was printed or added to Git. The private home was deleted after the probe stopped; copied authentication secrets were checked for accidental presence in the output files and none were found.

One `gpt-6-astra` probe ran through the unchanged supplied runner using `s2_smoke.jsonl`, `--cmd-stdin prompt --ordered --workers 2 --max-calls 2600 --limit 1 --retries 1`. Temperature, reasoning effort and output length remained at their defaults.

The writable home fixed local initialization, but the CLI then failed before receiving a model answer:

```
URL error: Proxy connection failed: HTTP CONNECT failed with status 403
```

The CLI attempted automatic reconnects and a WebSocket-to-HTTPS fallback, then continued waiting for network. After the CONNECT denial was confirmed, its process group was terminated (SIGTERM); the wrapper preserved this failure and the runner recorded an error. The single probe did not complete a model turn, emit an agent answer, or create an answer file. No additional model probe, full smoke suite, main batch, or rung batch was started, following the user's instruction to stop after another failure before generation. No usage/rate-limit or account-level warning was observed. The CLI emitted a non-account deprecation warning for `features.memory_tool`; the requested flags were retained.

The previous `gpt-6.1-sol` attempt failed locally in the original read-only CLI home. Its report and command are retained in `_coverage_2026-10-11.md` and `_command_original.txt`. API-key variables were previously checked and absent; no API route or orchestration-subagent fallback was used.

## Final command template

Backend: `cmd`; stdin: `prompt`. The capture wrapper launches the unchanged CLI flags, forwards the prompt without rewriting it, retains complete stdout/stderr, and counts event metadata. It never evaluates answer content.

```sh
CODEX_HOME=/tmp/codex-home python3 /workspace/AI-works/purpose-sensitivity/astra_out/_capture_cli.py {workdir} {model} {out_file} /opt/codex/bin/codex --no-daemon -a never exec --ignore-user-config --ignore-rules --ephemeral --skip-git-repo-check --sandbox read-only -C {workdir} -m {model} -c 'model_instructions_file="{system_file}"' -c 'project_doc_max_bytes=0' -c 'skills.include_instructions=false' -c 'skills.bundled.enabled=false' -c 'web_search="disabled"' -c 'features.shell_tool=false' -c 'features.unified_exec=false' -c 'features.apply_patch_freeform=false' -c 'features.view_image=false' -c 'features.apps=false' -c 'features.plugins=false' -c 'features.memories=false' -c 'features.memory_tool=false' -c 'features.multi_agent=false' -c 'features.multi_agent_v2=false' -c 'features.js_repl=false' -c 'features.code_mode=false' -c 'tools.update_plan.enabled=false' --color never --json -o {out_file} -
```

## Models and observed tool counts

| Model ID | Display name | Developer | Counted attempts | Audited CLI streams | Observed tool items | Answers |
|---|---|---|---:|---:|---:|---:|
| gpt-6-astra | GPT-6 Astra | OpenAI | 1 | 1 | 0 | 0 |
| gpt-6.1-sol | GPT-6.1 Sol | OpenAI | 1 (prior run) | 0 | Not available | 0 |
| gpt-6-luna | GPT-6 Luna | OpenAI | 0 | 0 | Not run | 0 |
| gpt-5.6-sol | GPT-5.6 Sol | OpenAI | 0 | 0 | Not run | 0 |

The Astra stream contained no observed tool-related items, no unknown item types, and no malformed JSON lines. Its only item type was `error`. Event files and count-only audits are under `_events/gpt-6-astra/`.

Tools were disabled as far as the recorded CLI flags permit, with a read-only sandbox. **The CLI's JSON stream cannot prove a zero-tool configuration:** version 0.159.2 omits some tool kinds, including clock, from this output. Counts above are observed tool items, deduplicated by item ID, not verified totals of every possible tool call. No successful model generation occurred in either probe.

## Ledger and compliance

Cumulative `_ledger.json`: **2 counted command attempts; 0 successful answers; 2 errors; 0 API blocks**. Each attempted model has one error. These are local/transport failures, not confirmed completed model API calls. The command backend supplies no token/cost telemetry; zero token counts and the `$0.00` estimate are not usage/cost measurements. CLI transport reconnects are internal to the single runner attempt.

No Claude model was invoked. Study prompts and outputs were not answered, rewritten, summarized or evaluated. Orchestration subagents inspected only CLI implementation details and the event schema. No study answer was generated by this agent or a subagent.
