import difflib, sys
a = open(sys.argv[1]).read().splitlines()
b = open(sys.argv[2]).read().splitlines()
sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
for tag, i1, i2, j1, j2 in sm.get_opcodes():
    if tag == 'equal':
        continue
    print(f'=== {tag} old {i1+1}-{i2} new {j1+1}-{j2}')
    if tag == 'replace' and (i2 - i1) == (j2 - j1):
        for k in range(i2 - i1):
            wa, wb = a[i1+k].split(' '), b[j1+k].split(' ')
            s2 = difflib.SequenceMatcher(None, wa, wb, autojunk=False)
            for t, x1, x2, y1, y2 in s2.get_opcodes():
                if t != 'equal':
                    print(f'  [{t}] OLD: {" ".join(wa[x1:x2])!r}')
                    print(f'        NEW: {" ".join(wb[y1:y2])!r}')
    elif tag == 'insert':
        print('  (pure insertion of', j2 - j1, 'lines)')
    else:
        print('  (block change)')
