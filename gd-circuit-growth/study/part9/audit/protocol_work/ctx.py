import json, sys, re
# print contexts of pattern in a transcript, for tool_use inputs and tool_result contents and texts
f = sys.argv[1]; pat = re.compile(sys.argv[2]); w = int(sys.argv[3]) if len(sys.argv) > 3 else 300
kinds = sys.argv[4].split(',') if len(sys.argv) > 4 else None
for i, line in enumerate(open(f)):
    d = json.loads(line)
    t = d.get('type'); ts = d.get('timestamp', '')
    m = d.get('message')
    items = []
    if t == 'assistant' and m:
        for c in m.get('content', []):
            if c.get('type') == 'text': items.append(('atext', c['text']))
            elif c.get('type') == 'tool_use': items.append(('tool_use', json.dumps(c['input'])))
    elif t == 'user' and m:
        cont = m.get('content')
        if isinstance(cont, str): items.append(('user', cont))
        else:
            for c in cont:
                if c.get('type') == 'tool_result':
                    r = c.get('content')
                    if isinstance(r, list): r = '\n'.join(x.get('text', '') for x in r if isinstance(x, dict))
                    items.append(('result', str(r)))
                elif c.get('type') == 'text': items.append(('utext', c['text']))
    elif t == 'attachment':
        items.append(('attach', json.dumps(d.get('attachment', d))[:200000]))
    for k, s in items:
        if kinds and k not in kinds: continue
        for mm in pat.finditer(s):
            a = max(0, mm.start() - w); b = min(len(s), mm.end() + w)
            print(f"--- [{i}] {ts} {k}: ...{s[a:b]}...")
