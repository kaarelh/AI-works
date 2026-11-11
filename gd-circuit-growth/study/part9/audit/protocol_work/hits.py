import json, sys, re
# For each record matching pattern, show the record index, kind, and for tool_use the full command (truncated); for results, show matching lines only
f = sys.argv[1]; pat = re.compile(sys.argv[2]); W = int(sys.argv[3]) if len(sys.argv) > 3 else 400
lines = open(f).readlines()
# map tool_use id -> (idx, input)
uses = {}
for i, l in enumerate(lines):
    d = json.loads(l)
    if d.get('type') == 'assistant':
        for c in d['message']['content']:
            if c.get('type') == 'tool_use': uses[c['id']] = (i, c['input'])
for i, l in enumerate(lines):
    d = json.loads(l); t = d.get('type'); m = d.get('message'); ts = d.get('timestamp', '')[11:19]
    if t == 'assistant':
        for c in m['content']:
            if c.get('type') == 'tool_use':
                s = json.dumps(c['input'])
                if pat.search(s): print(f"[{i}] {ts} TOOL_USE {c['name']}: {s[:W]}")
            elif c.get('type') == 'text' and pat.search(c['text']):
                print(f"[{i}] {ts} TEXT: " + ' | '.join(x for x in c['text'].split('\n') if pat.search(x))[:W])
    elif t == 'user' and isinstance(m.get('content'), list):
        for c in m['content']:
            if c.get('type') == 'tool_result':
                r = c.get('content')
                if isinstance(r, list): r = '\n'.join(x.get('text', '') for x in r if isinstance(x, dict))
                r = str(r)
                ml = [x for x in r.split('\n') if pat.search(x)]
                if ml:
                    ui = uses.get(c['tool_use_id'], (None, {}))
                    cmd = json.dumps(ui[1])[:200]
                    print(f"[{i}] {ts} RESULT (of [{ui[0]}] {cmd}): " + ' || '.join(ml)[:W])
