import json, sys
# dump transcript: tool calls (input) and tool results (truncated), with timestamps and indices
f = sys.argv[1]; out = sys.argv[2]; maxres = int(sys.argv[3]) if len(sys.argv) > 3 else 3000
with open(out, 'w') as o:
    for i, line in enumerate(open(f)):
        d = json.loads(line)
        t = d.get('type'); ts = d.get('timestamp', '')
        m = d.get('message')
        if t == 'assistant' and m:
            for c in m.get('content', []):
                if c.get('type') == 'text':
                    o.write(f"\n### [{i}] {ts} ASSISTANT TEXT\n{c['text']}\n")
                elif c.get('type') == 'tool_use':
                    o.write(f"\n### [{i}] {ts} TOOL_USE {c['name']} id={c['id'][-8:]}\n{json.dumps(c['input'], indent=1)[:20000]}\n")
        elif t == 'user' and m:
            cont = m.get('content')
            if isinstance(cont, str):
                o.write(f"\n### [{i}] {ts} USER\n{cont[:maxres*3]}\n")
            else:
                for c in cont:
                    if c.get('type') == 'tool_result':
                        r = c.get('content')
                        if isinstance(r, list):
                            r = '\n'.join(x.get('text', '') for x in r if isinstance(x, dict))
                        r = str(r)
                        o.write(f"\n### [{i}] {ts} RESULT id={c['tool_use_id'][-8:]} len={len(r)}\n{r[:maxres]}\n" + ("...[TRUNC]\n" if len(r) > maxres else ""))
                    elif c.get('type') == 'text':
                        o.write(f"\n### [{i}] {ts} USER TEXT\n{c['text'][:maxres*3]}\n")
