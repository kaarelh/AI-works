"""Validate transport/record equality and report counts, never answer contents."""
import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parent
HANDOFF = ROOT.parent / 'handoff'
MODELS = [('gpt-6-astra', 'GPT-6 Astra'), ('gpt-6.1-sol', 'GPT-6.1 Sol'),
          ('gpt-6-luna', 'GPT-6 Luna'), ('gpt-5.6-sol', 'GPT-5.6 Sol')]
FILES = ['s2_smoke', 's2_ctx4', 's2_ctx4_probes', 's2_ctx2', 's2_ctx2c',
         's2_ctx3', 'jobs_study1', 's2_ctx1', 's2_ctx1_rungs']


def require(condition, label):
    if not condition:
        raise RuntimeError('Record transport check failed: ' + label)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--status', required=True)
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location('supplied_runner', HANDOFF / 'astra_runner.py')
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    by_hash = {}
    expected = {}
    for name in FILES:
        raw = (HANDOFF / (name + '.jsonl')).read_bytes()
        jobs = [json.loads(line) for line in raw.splitlines() if line.strip()]
        digest = hashlib.sha256(raw).hexdigest()
        by_hash[digest] = (name, {job['id']: job for job in jobs})
        expected[name] = len(jobs)
    counts = Counter()
    thread_ids = set()
    for model, display in MODELS:
        identity = dict(display_name=display, model_id=model, developer='OpenAI')
        for path in (ROOT / model).glob('*.json'):
            if path.name.startswith('_'):
                continue
            record = json.loads(path.read_text())
            require(record.get('jobs_sha256') in by_hash, 'handoff hash')
            name, jobs = by_hash[record['jobs_sha256']]
            job_id = record.get('job', {}).get('id')
            require(job_id in jobs, 'job id')
            require(path.stem == job_id, 'record filename')
            job = jobs[job_id]
            expected_job = dict(job, system=runner.fill(job['system'], **identity),
                                prompt=runner.fill(job['prompt'], **identity), model=model)
            require(record['job'] == expected_job, 'exact runner identity substitution')
            require(record.get('identity') == identity, 'identity')
            require(record.get('model_requested') == model and record.get('backend') == 'cmd', 'model/backend')
            require(record.get('settings') == dict(temperature=None, reasoning_effort='default', max_output_tokens=None), 'settings')
            if record.get('refused_by_api'):
                require(record.get('result') == '' and record.get('finish_reason') == 'api_refusal'
                        and bool(record.get('api_error')), 'API block record')
                counts[(model, name, 'api_block')] += 1
                continue
            raw_response = record.get('raw_response') or {}
            require(raw_response.get('cmd_template') == (ROOT / '_command.txt').read_text().strip(), 'command')
            audits = []
            for line in raw_response.get('stdout_tail', '').splitlines():
                try:
                    event = json.loads(line)
                except ValueError:
                    continue
                if event.get('type') == 'capture.audit':
                    audits.append(event)
            require(len(audits) == 1, 'one capture audit')
            audit = audits[0]
            event_path = Path(audit['events_path']).resolve()
            require(event_path.parent == ROOT / '_events' / model, 'event path scope')
            require(Path(audit['audit_path']).resolve() == event_path.with_suffix('.audit.json'), 'audit path')
            saved_audit = json.loads(event_path.with_suffix('.audit.json').read_text())
            require(saved_audit == {k:v for k,v in audit.items() if k != 'type'}, 'saved audit equality')
            require(audit.get('model') == model, 'audit model')
            events = [json.loads(line) for line in event_path.read_text().splitlines() if line.strip()]
            event_counts = Counter(e.get('type') for e in events)
            require(dict(event_counts) == audit.get('event_types'), 'full event counts')
            terminal = [e.get('type') for e in events if e.get('type') in ('turn.completed', 'turn.failed')]
            require(terminal == ['turn.completed'], 'exactly one completed model turn')
            sessions = [e.get('thread_id') for e in events if e.get('type') == 'thread.started']
            require(len(sessions) == 1 and isinstance(sessions[0], str) and sessions[0] not in thread_ids, 'fresh session')
            require(sessions == audit.get('thread_ids'), 'session audit equality')
            thread_ids.update(sessions)
            tool_types = {'command_execution', 'file_change', 'mcp_tool_call',
                          'collab_tool_call', 'web_search', 'todo_list'}
            observed = {}
            for index, event in enumerate(events, 1):
                item = event.get('item') or {}
                if item.get('type') in tool_types:
                    item_id = item.get('id')
                    if not isinstance(item_id, str):
                        item_id = f'<missing-id-event-{index}>'
                    observed[item_id] = item['type']
            require(len(observed) == audit.get('observed_tool_items'), 'tool count')
            require(dict(Counter(observed.values())) == audit.get('observed_tool_items_by_type'), 'tool types')
            messages = [e['item']['text'] for e in events if e.get('type') == 'item.completed'
                        and e.get('item', {}).get('type') == 'agent_message']
            require(messages and messages[-1].strip(), 'nonempty model answer')
            answer = messages[-1]
            require(record.get('result') == answer.strip(), 'saved answer matches runner result')
            require(hashlib.sha256(answer.encode()).hexdigest() == audit.get('answer_sha256'), 'answer hash')
            require(audit.get('cli_exit_code') == 0 and audit.get('capture_exit_code') == 0
                    and not audit.get('validation_errors'), 'successful capture')
            counts[(model, name, 'ok')] += 1
    ledger = json.loads((ROOT / '_ledger.json').read_text())
    lines = ['## Current run status', '', args.status, '', '## Models and cumulative observed tool counts', '',
             '| Model | Attempts | Audited streams | Streams with tool items | Observed tool items | Answers | API blocks |',
             '|---|---:|---:|---:|---:|---:|---:|']
    for model, display in MODELS:
        audits = [json.loads(p.read_text()) for p in (ROOT / '_events' / model).glob('*.audit.json')]
        model_ledger = ledger.get('by_model', {}).get(model, {})
        tools = sum(a.get('observed_tool_items', 0) for a in audits)
        with_tools = sum(bool(a.get('observed_tool_items')) for a in audits)
        answers = sum(counts[(model, name, 'ok')] for name in FILES)
        blocks = sum(counts[(model, name, 'api_block')] for name in FILES)
        lines.append(f'| {display} (`{model}`; OpenAI) | {model_ledger.get("calls", 0)} | {len(audits)} | {with_tools} | {tools} | {answers} | {blocks} |')
    lines += ['', 'Counts describe the event streams actually captured. The original Sol startup failure has no full stream. Codex 0.159.2 omits some tool kinds, including clock, from JSON output; zero observed items does not verify that all tools are absent.', '',
              '## File coverage', '', '| File | Jobs per model | Astra | 6.1 Sol | Luna | 5.6 Sol |', '|---|---:|---:|---:|---:|---:|']
    for name in FILES:
        values = [str(counts[(model, name, 'ok')] + counts[(model, name, 'api_block')]) for model, _ in MODELS]
        lines.append(f'| `{name}.jsonl` | {expected[name]} | ' + ' | '.join(values) + ' |')
    totals = {key: sum(m.get(key, 0) for m in ledger.get('by_model', {}).values()) for key in ('ok', 'error', 'api_block')}
    lines += ['', 'File counts include saved API-block records, if any; the model table separates those from answers.', '', '## Ledger and limitations', '',
              f'Ledger: **{ledger.get("calls", 0)} counted command attempts, {totals["ok"]} successful answers, {totals["error"]} errors, {totals["api_block"]} API blocks**. The shared cap remains 2,600. Token/cost counters are unmeasured for this command backend, even when the ledger reports zero.', '',
              'Saved answer records were mechanically checked against the final model event, the handoff hash, model identity, default settings and command template. No prompt or answer content was interpreted, summarized or evaluated.', '',
              'The subagent fallback was not used: the available launcher cannot confirm removal of tools and filesystem access. Subagents assisted only with mechanics and synthetic checks. No Claude model was used.', '',
              'Credentials remain outside Git. Publication checks inspect staged paths and compare staged bytes against local authentication values without printing those values. This conversation transcript and the device login code are not committed.', '',
              'Deviations from the initial mechanics: the authorized persistent private CLI home, capture wrapper, guarded runner launcher, necessary network allowlist draft, and metadata/credential publication checks. The handoff runner and job files remain unchanged. Prior failure reports/logs are preserved.', '']
    path = ROOT / '_coverage.md'
    prior = path.read_text()
    prefix = prior.split('## Models and cumulative observed tool counts')[0].split('## Current run status')[0]
    path.write_text(prefix + '\n'.join(lines))
    print(json.dumps({'validated_answer_records':sum(v for k, v in counts.items() if k[2] == 'ok'),
                      'calls':ledger.get('calls', 0), **totals}))


if __name__ == '__main__':
    main()
