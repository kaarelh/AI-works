import re, sys
t = open(sys.argv[1]).read()
defs = set()
for line in t.splitlines():
    m = re.match(r'^\*\*(Lemma|Proposition|Theorem|Corollary|Remark) ([0-9]+\.[0-9]+[a-z′]*)', line)
    if m: defs.add((m.group(1), m.group(2)))
canon = {'Lemma':'Lemma','Lemmas':'Lemma','Proposition':'Proposition','Propositions':'Proposition','Prop':'Proposition',
         'Theorem':'Theorem','Theorems':'Theorem','Thm':'Theorem','Corollary':'Corollary','Corollaries':'Corollary',
         'Cor':'Corollary','Remark':'Remark','Rem':'Remark'}
bad = []
for m in re.finditer(r'\b(Lemmas?|Propositions?|Prop|Theorems?|Thm|Corollary|Corollaries|Cor|Remark|Rem)\.? ((?:[0-9]+\.[0-9]+[a-z′]?(?:\([a-z0-9,]+\))?(?:–|, | and )?)+)', t):
    kind = canon[m.group(1)]
    for num in re.findall(r'[0-9]+\.[0-9]+[a-z′]?', m.group(2)):
        if (kind, num) not in defs:
            line = t[:m.start()].count('\n') + 1
            bad.append((line, kind, num, t[max(0, m.start()-60):m.end()+20].replace('\n', ' ')))
for b in bad: print(b)
print(len(bad), "unresolved typed references")
