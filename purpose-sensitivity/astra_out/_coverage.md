# Purpose-sensitivity coverage

Updated: 2026-10-12.
Branch: `codex/purpose-sensitivity-astra-2026-10-11`.
All ten handoff manifest checks pass. Repository changes are confined to `purpose-sensitivity/astra_out/`.

## Current blocker and sign-in route

The user authorized fresh sign-in and broader wrapper changes. Created a new private persistent CLI home at `/workspace/purpose-sensitivity-private/codex-home` (directory and parent mode 0700), without copying the old authentication. The original CLI home remains unchanged. No token is currently stored in the new home. It will be retained for the study and removed only after all files are done, as instructed.

Attempted:

```sh
CODEX_HOME=/workspace/purpose-sensitivity-private/codex-home /opt/codex/bin/codex login --device-auth
```

The first device-code sign-in attempt could not reach `https://auth.openai.com/api/accounts/deviceauth/usercode`. An independent HEAD request to `https://auth.openai.com/` confirmed HTTP CONNECT 403 from the egress proxy. That attempt issued no device code or credential.

Saved an environment configuration draft adding only `auth.openai.com`, preserving `chatgpt.com` and the package-manager presets. After Kaarel requested continuation and the environment became ready, the same login command successfully obtained a device-code sign-in request. Its URL and temporary code were supplied directly to Kaarel and are not saved in the repository. The CLI is waiting for human sign-in approval; this is the current blocker. No study/model call was attempted during this sign-in repair.

## Exact model command

Backend: `cmd`; stdin: `prompt`. Planned runner flags remain `--ordered --workers 2 --max-calls 2600 --retries 1`; generation temperature, reasoning effort and output length stay at defaults.

```sh
CODEX_HOME=/workspace/purpose-sensitivity-private/codex-home python3 /workspace/AI-works/purpose-sensitivity/astra_out/_capture_cli.py {workdir} {model} {out_file} /opt/codex/bin/codex --no-daemon -a never exec --ignore-user-config --ignore-rules --ephemeral --skip-git-repo-check --sandbox read-only -C {workdir} -m {model} -c 'model_instructions_file="{system_file}"' -c 'project_doc_max_bytes=0' -c 'skills.include_instructions=false' -c 'skills.bundled.enabled=false' -c 'web_search="disabled"' -c 'features.shell_tool=false' -c 'features.unified_exec=false' -c 'features.apply_patch_freeform=false' -c 'features.view_image=false' -c 'features.apps=false' -c 'features.plugins=false' -c 'features.memories=false' -c 'features.memory_tool=false' -c 'features.multi_agent=false' -c 'features.multi_agent_v2=false' -c 'features.js_repl=false' -c 'features.code_mode=false' -c 'tools.update_plan.enabled=false' --color never --json -o {out_file} -
```

The runner creates a fresh temporary directory and CLI session per job, passes the job's system file as model instructions, and sends its user message on stdin. No parent conversation or repository documentation is provided. The protected handoff runner and job files are unchanged.

## Mechanics changes and checks

The capture wrapper now reads partial streams without blocking, detects operational warnings in both stderr and error items, propagates shared stop markers to active workers, and distinguishes account/provider stops, human-authentication requirements, and usage/rate pauses. It never inspects agent-answer text for operational warnings.

It terminates its own CLI process group and kills it after two seconds if necessary. An internal timeout defaults to 1,150 seconds (`ASTRA_CLI_TIMEOUT_SECONDS`), below the supplied runner's 1,200-second timeout. Individual failures/timeouts remain retryable and do not set a global stop. Rate-pause markers include an explicit reset time when supplied; a supervisor must publish progress and resume after the reset, clearing only the resolved rate pause.

Success requires exactly one completed turn, a nonempty answer file, and exact byte equality with the final agent-message event. This prevents JSON logs being mistaken for an answer. Answer bytes and full traces are unchanged; audits include file links and hashes. The supplied runner still performs its original outer-whitespace trimming (`out.strip()`) when writing command-backend records, and reports the requested model ID as served without independent service attestation. These inherited limitations were not changed.

All 16 synthetic helper tests passed, including exact-byte preservation, partial-stream stopping, concurrent stop propagation, rate reset parsing, forced termination, timeout, missing answers, and malformed events. `git diff --check` passed. These tests used a fake CLI, no study prompts, no credentials and no model calls. Live generation remains unverified pending authentication.

## Models and cumulative observed tool counts

| Model ID | Display name | Developer | Counted attempts | Audited CLI streams | Observed tool items | Answers |
|---|---|---|---:|---:|---:|---:|
| gpt-6-astra | GPT-6 Astra | OpenAI | 2 | 2 | 0 | 0 |
| gpt-6.1-sol | GPT-6.1 Sol | OpenAI | 1 | 0 | Not available | 0 |
| gpt-6-luna | GPT-6 Luna | OpenAI | 0 | 0 | Not run | 0 |
| gpt-5.6-sol | GPT-5.6 Sol | OpenAI | 0 | 0 | Not run | 0 |

The CLI flags disable tools as far as previously verified, with a read-only sandbox. Codex 0.159.2 omits some tool kinds, including clock, from JSON output: observed counts do not prove all tools are absent. The two audited streams contain no observed tool items and no answers.

The subagent fallback was not used. The available orchestration launcher exposes no control to remove tools or filesystem access, so its required isolation cannot currently be confirmed. Subagents assisted only with CLI mechanics and synthetic helper checks; they never received study jobs.

## Ledger and preserved history

Ledger unchanged: **3 counted command attempts, 0 successful answers, 3 errors, 0 API blocks**. Astra has two errors; Sol has one. Token counters and estimated cost remain zero because the command backend supplies no token/cost telemetry, not because usage/cost was measured. Login and synthetic helper checks do not count as model attempts.

No complete smoke suite, main file or rung file has run. Prior coverage reports and failure logs remain under this directory. No Claude model was invoked. No study prompt or answer was authored, rewritten, summarized or evaluated by this agent or a session with access to the repository/conversation. Credentials are neither printed nor committed. Exceptions to the original mechanics are the explicitly authorized persistent private home and wrapper changes, plus the necessary saved network-draft addition described above.
