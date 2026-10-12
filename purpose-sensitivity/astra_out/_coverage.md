# Purpose-sensitivity coverage

Updated: 2026-10-12.
Branch: `codex/purpose-sensitivity-astra-2026-10-11`.
All ten handoff manifest checks pass. Repository changes are confined to `purpose-sensitivity/astra_out/`.

## Sign-in route

The user authorized fresh sign-in and broader wrapper changes. Created a new private persistent CLI home at `/workspace/purpose-sensitivity-private/codex-home` (directory and parent mode 0700), without copying the old authentication. The original CLI home remains unchanged. Fresh ChatGPT sign-in is now confirmed. The private home will be retained for the study and removed only after all files are done, as instructed.

Attempted:

```sh
CODEX_HOME=/workspace/purpose-sensitivity-private/codex-home /opt/codex/bin/codex login --device-auth
```

The first device-code sign-in attempt could not reach `https://auth.openai.com/api/accounts/deviceauth/usercode`. An independent HEAD request to `https://auth.openai.com/` confirmed HTTP CONNECT 403 from the egress proxy. That attempt issued no device code or credential.

Saved an environment configuration draft adding only `auth.openai.com`, preserving `chatgpt.com` and the package-manager presets. After Kaarel requested continuation and the environment became ready, the same login command successfully obtained a device-code sign-in request. Its URL and temporary code were supplied directly to Kaarel and are not saved in the repository. Kaarel completed sign-in; `codex login status` confirms ChatGPT authentication. The one-job Astra probe then produced a mechanically verified answer with no observed tool items.

## Exact model command

Backend: `cmd`; stdin: `prompt`. Runner flags are `--ordered --workers 4 --max-calls 2600 --retries 1` from `s2_ctx2c` onward. Earlier invocations used `--workers 2`. Generation temperature, reasoning effort and output length stay at defaults.

```sh
CODEX_HOME=/workspace/purpose-sensitivity-private/codex-home python3 /workspace/AI-works/purpose-sensitivity/astra_out/_capture_cli.py {workdir} {model} {out_file} /opt/codex/bin/codex --no-daemon -a never exec --ignore-user-config --ignore-rules --ephemeral --skip-git-repo-check --sandbox read-only -C {workdir} -m {model} -c 'model_instructions_file="{system_file}"' -c 'project_doc_max_bytes=0' -c 'skills.include_instructions=false' -c 'skills.bundled.enabled=false' -c 'web_search="disabled"' -c 'features.shell_tool=false' -c 'features.unified_exec=false' -c 'features.apply_patch_freeform=false' -c 'features.view_image=false' -c 'features.apps=false' -c 'features.plugins=false' -c 'features.memories=false' -c 'features.memory_tool=false' -c 'features.multi_agent=false' -c 'features.multi_agent_v2=false' -c 'features.js_repl=false' -c 'features.code_mode=false' -c 'tools.update_plan.enabled=false' --color never --json -o {out_file} -
```

The runner creates a fresh temporary directory and CLI session per job, passes the job's system file as model instructions, and sends its user message on stdin. No parent conversation or repository documentation is provided. The protected handoff runner and job files are unchanged.

## Mechanics changes and checks

The capture wrapper now reads partial streams without blocking, detects operational warnings in both stderr and error items, propagates shared stop markers to active workers, and distinguishes account/provider stops, human-authentication requirements, and usage/rate pauses. It never inspects agent-answer text for operational warnings.

It terminates its own CLI process group and kills it after two seconds if necessary. An internal timeout defaults to 1,150 seconds (`ASTRA_CLI_TIMEOUT_SECONDS`), below the supplied runner's 1,200-second timeout. Individual failures/timeouts remain retryable and do not set a global stop. Rate-pause markers include an explicit reset time when supplied; a supervisor must publish progress and resume after the reset, clearing only the resolved rate pause.

Batch invocations use `_run_guarded.py` with the supplied runner's same arguments. It imports the unchanged runner, checks the shared stop marker before queued jobs and under the ledger reservation lock, and permits active jobs to save their results. This prevents a stopped batch from consuming its remaining call budget. All 10 synthetic launcher tests passed, including a six-job queue where only the active job reserved a call and saved its result after a pause. No study prompts or credentials were used in these tests.

The invocation template is `python3 -B purpose-sensitivity/astra_out/_run_guarded.py purpose-sensitivity/handoff/{file}.jsonl purpose-sensitivity/astra_out --model {model} --display-name "{display_name}" --developer OpenAI --backend cmd --cmd "$(cat purpose-sensitivity/astra_out/_command.txt)" --cmd-stdin prompt --ordered --workers 4 --max-calls 2600 --retries 1 --reasoning-effort default`. Logs append to `_logs/{model}__{file}.log`.

After smoke tests, `python3 -B purpose-sensitivity/astra_out/_run_study.py` supervises the run with a private creation umask (`077`). It processes files in the requested order and models in the table order, validates and pushes after each invocation, and retries unfinished jobs within the unchanged cumulative cap. Additional repair passes run in the original file order before the final rung file, reserving budget for all unattempted jobs. A usage pause is published before waiting for an explicitly supplied reset time; an unknown reset or an account/provider/authentication stop requires resolution. All 16 mocked controller tests passed without model calls or credentials. Controller state contains only execution metadata.

Publication after Luna's `s2_ctx4_probes` briefly paused because a captured stderr log contains a blank line at EOF. That log remains byte-for-byte unchanged. Whitespace checks now apply to authored source, documentation and command/configuration files; generated records and captured streams retain their original formatting. Credential and scope checks still inspect every staged file. The expanded controller suite has 18 passing synthetic tests, including a Git regression confirming that raw-log formatting is preserved while authored-source whitespace errors still block publication. This was a publication-check failure, not a model failure or provider/account warning.

Under the user's authorization to adjust workers, the controller increases concurrency to four starting with `s2_ctx2c`. The existing two-worker GPT-5.6 Sol `s2_ctx2` invocation was allowed to drain before replacing the orchestration process. Fresh per-job sessions, sequential block/file ordering, the shared call cap and warning gates remain unchanged. Up to four already-reserved calls can be active when a warning arrives; subsequent reservations are blocked. The updated controller still passes all 18 synthetic tests. The model command template is unchanged.

The publication checker now checks both source and destination paths for renames and handles confirmed staged deletions without trying to read nonexistent blobs. All remaining staged blobs receive the same credential checks. Ten synthetic Git tests cover deletion and rename scope, credential matching, and staged-versus-worktree bytes; no study content or real credentials were used in those tests.

Success requires exactly one completed turn, a nonempty answer file, and exact byte equality with the final agent-message event. This prevents JSON logs being mistaken for an answer. Answer bytes and full traces are unchanged; audits include file links and hashes. The supplied runner still performs its original outer-whitespace trimming (`out.strip()`) when writing command-backend records, and reports the requested model ID as served without independent service attestation. These inherited limitations were not changed.

All 16 synthetic helper tests passed, including exact-byte preservation, partial-stream stopping, concurrent stop propagation, rate reset parsing, forced termination, timeout, missing answers, and malformed events. These tests used a fake CLI, no study prompts, no credentials and no model calls. The fresh-sign-in Astra probe verified live answer delivery and equality between the saved record and the runner's trimmed final model message. Its CLI configuration deprecation notice is preserved; it is not an account/provider warning.

## Current run status

Initial invocation completed for s2_ctx1.jsonl / gpt-6-luna; individual failures remain recorded.

## Models and cumulative observed tool counts

| Model | Attempts | Audited streams | Streams with tool items | Observed tool items | Answers | API blocks |
|---|---:|---:|---:|---:|---:|---:|
| GPT-6 Astra (`gpt-6-astra`; OpenAI) | 625 | 625 | 0 | 0 | 623 | 0 |
| GPT-6.1 Sol (`gpt-6.1-sol`; OpenAI) | 625 | 624 | 0 | 0 | 623 | 0 |
| GPT-6 Luna (`gpt-6-luna`; OpenAI) | 623 | 623 | 0 | 0 | 623 | 0 |
| GPT-5.6 Sol (`gpt-5.6-sol`; OpenAI) | 562 | 562 | 0 | 0 | 562 | 0 |

Counts describe the event streams actually captured. The original Sol startup failure has no full stream. Codex 0.159.2 omits some tool kinds, including clock, from JSON output; zero observed items does not verify that all tools are absent.

## File coverage

| File | Jobs per model | Astra | 6.1 Sol | Luna | 5.6 Sol |
|---|---:|---:|---:|---:|---:|
| `s2_smoke.jsonl` | 5 | 5 | 5 | 5 | 5 |
| `s2_ctx4.jsonl` | 104 | 104 | 104 | 104 | 104 |
| `s2_ctx4_probes.jsonl` | 120 | 120 | 120 | 120 | 120 |
| `s2_ctx2.jsonl` | 49 | 49 | 49 | 49 | 49 |
| `s2_ctx2c.jsonl` | 12 | 12 | 12 | 12 | 12 |
| `s2_ctx3.jsonl` | 62 | 62 | 62 | 62 | 62 |
| `jobs_study1.jsonl` | 210 | 210 | 210 | 210 | 210 |
| `s2_ctx1.jsonl` | 61 | 61 | 61 | 61 | 0 |
| `s2_ctx1_rungs.jsonl` | 6 | 0 | 0 | 0 | 0 |

File counts include saved API-block records, if any; the model table separates those from answers.

## Ledger and limitations

Ledger: **2435 counted command attempts, 2431 successful answers, 4 errors, 0 API blocks**. The shared cap remains 2,600. Token/cost counters are unmeasured for this command backend, even when the ledger reports zero.

Saved answer records were mechanically checked against the final model event, the handoff hash, model identity, default settings and command template. No prompt or answer content was interpreted, summarized or evaluated.

The subagent fallback was not used: the available launcher cannot confirm removal of tools and filesystem access. Subagents assisted only with mechanics and synthetic checks. No Claude model was used.

Credentials remain outside Git. Publication checks inspect staged paths and compare staged bytes against local authentication values without printing those values. This conversation transcript and the device login code are not committed.

Deviations from the initial mechanics: the authorized persistent private CLI home, capture wrapper, guarded runner launcher, necessary network allowlist draft, metadata/credential publication checks, and four workers from s2_ctx2c onward under the later authorization to adjust concurrency. The handoff runner and job files remain unchanged. Prior failure reports/logs are preserved.
