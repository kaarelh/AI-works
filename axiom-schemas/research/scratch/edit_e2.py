p='/home/user/AI-works/axiom-schemas/research/tracks/single/e2_examples.py'
src=open(p).read()
src=src.replace("E = enumerate_covering(D, 23, amax=2,","E = enumerate_covering(D, 24, amax=2,")
old="print('    brute force (size<=23, args<=2): %d covering DT° templates, %d minimal, same set: %s  (%.0fs)' % (\n    len(E), len(m2), len(m2) == len(mins) and all(any(equivalent(a, b) for b in mins) for a in m2), time.time() - t))"
assert old in src
src=src.replace(old,
"print('    brute force (size<=24, args<=2): %d covering DT° templates, %d minimal, same set: %s, every enumerated template above a Sat-minimal one: %s  (%.0fs)' % (\n    len(E), len(m2), len(m2) == len(mins) and all(any(equivalent(a, b) for b in mins) for a in m2),\n    all(any(subsumes(U, mm) for mm in mins) for U in E), time.time() - t))\nE23 = [U for U in E if size(U) <= 23]\nm23, _ = minimal_elements(E23)\nprint('    restricted to size<=23 (the prior bound): %d minimal (prior C8.2 reported 8); bound artifacts above the size-24 template: %d' % (len(m23), sum(1 for U in m23 if subsumes(U, mins[0]) and size(mins[0]) > 23)))")
src=src.replace("for n in range(1, 6):","for n in range(1, 7):")
src=src.replace("    if n <= 4:\n","    if n <= 3:\n")
open(p,'w').write(src)
