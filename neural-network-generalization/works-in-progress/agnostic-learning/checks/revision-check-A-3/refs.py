import re, sys
t = open(sys.argv[1], encoding='utf-8').read()
defined = set(re.findall(r'^\*\*((?:Lemma|Theorem|Proposition|Corollary|Remark) [0-9]+\.[0-9]+[a-z′]*)', t, re.M))
secs = set(m.group(1) for m in re.finditer(r'^#{2,3} ([0-9]+(?:\.[0-9]+)?)[. ]', t, re.M))
tags = set(re.findall(r'\\tag\{([^}]*)\}', t))
# Strip text that cites other notes: phrases like "B-tempered-likelihood.md Theorem 6.3" or "red-team.md` Proposition 4.1" etc.
other = re.compile(r'(B-tempered-likelihood\.md|E-finite-prior-scale\.md|C-fixed-temperature-bayes\.md|red-team\.md`?|paper\.tex`?|Theorem `strong`|\bits\b|\bthe note\b|note\'s)\s*(?:,\s*)?((?:Lemma|Theorem|Proposition|Corollary|Remark|Corollaries|Theorems|Propositions|Remarks|Lemmas)\s+[0-9C][^\s,;.)]*)')
bad = []
for m in re.finditer(r'\b(Lemma|Theorem|Proposition|Corollary|Remark)s?\s+([0-9]+\.[0-9]+[a-z′]*)', t):
    kind, num = m.group(1), m.group(2)
    pre = t[max(0,m.start()-60):m.start()]
    if re.search(r'(B-tempered-likelihood\.md|E-finite-prior-scale\.md|C-fixed-temperature-bayes\.md|red-team\.md`?|referee\'s|Observation)\s*$', pre): continue
    key = f'{kind} {num}'
    if key not in defined:
        bad.append((key, t[max(0,m.start()-80):m.end()+20].replace('\n',' ')))
for k, ctx in bad:
    print('UNDEF?', k, '|', ctx)
for m in re.finditer(r'§([0-9]+(?:\.[0-9]+)?)', t):
    s = m.group(1)
    pre = t[max(0,m.start()-60):m.start()]
    if re.search(r'(\.md`?|paper\.tex`?|README\.md`?|brief|its|Brief|red-team\.md`)\s*$', pre): continue
    if s not in secs and s.split('.')[0] not in secs:
        print('SEC?', s, '|', t[max(0,m.start()-80):m.end()+20].replace('\n',' '))
for m in re.finditer(r'\((\d\.\d)\)', t):
    if m.group(1) not in tags:
        pass
print('defined:', sorted(defined))
