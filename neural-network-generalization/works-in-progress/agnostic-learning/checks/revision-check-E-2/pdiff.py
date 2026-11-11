import difflib, sys
old = open(sys.argv[1]).read().split('\n')
new = open(sys.argv[2]).read().split('\n')
sm = difflib.SequenceMatcher(None, old, new, autojunk=False)
for tag, i1, i2, j1, j2 in sm.get_opcodes():
    if tag == 'equal': continue
    print(f"@@ {tag} old {i1+1}-{i2} new {j1+1}-{j2}")
    if tag in ('replace',) and (i2-i1)==(j2-j1):
        for a, b in zip(old[i1:i2], new[j1:j2]):
            # word-level diff
            aw, bw = a.split(' '), b.split(' ')
            s2 = difflib.SequenceMatcher(None, aw, bw, autojunk=False)
            out = []
            for t, x1, x2, y1, y2 in s2.get_opcodes():
                if t == 'equal':
                    seg = aw[x1:x2]
                    if len(seg) > 12: seg = seg[:5] + ['...'] + seg[-5:]
                    out.append(' '.join(seg))
                else:
                    if x2 > x1: out.append('[-' + ' '.join(aw[x1:x2]) + '-]')
                    if y2 > y1: out.append('{+' + ' '.join(bw[y1:y2]) + '+}')
            print('  ~ ' + ' '.join(out))
    else:
        for l in old[i1:i2]: print('  - ' + l)
        for l in new[j1:j2]: print('  + ' + l)
