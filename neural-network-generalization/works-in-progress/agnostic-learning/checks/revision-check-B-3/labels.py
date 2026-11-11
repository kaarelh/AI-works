import re, sys
def labels(path):
    t = open(path).read()
    defs = []
    for line in t.splitlines():
        m = re.match(r'^## (\d+)\.', line)
        if m: defs.append('Section ' + m.group(1)); continue
        m = re.match(r'^\*\*(Lemma|Proposition|Theorem|Corollary|Remark) ([0-9]+\.[0-9]+[a-z′\']*)', line)
        if m: defs.append(m.group(1) + ' ' + m.group(2)); continue
        m = re.match(r'^\*\*(\d+\.\d+) ', line)
        if m: defs.append('Subsection ' + m.group(1))
    refs = set()
    for m in re.finditer(r'(Lemma|Lemmas|Proposition|Propositions|Theorem|Theorems|Corollary|Corollaries|Remark|Prop|Thm|Cor|Rem)\.? ([0-9]+\.[0-9]+[a-z′]?)', t):
        refs.add(m.group(2))
    return defs, refs, t
old, oref, ot = labels(sys.argv[1]); new, nref, nt = labels(sys.argv[2])
print("old labels:", len(old), " new labels:", len(new))
print("old order kept in new:", [x for x in new if x in old] == old)
print("added:", [x for x in new if x not in old])
print("removed:", [x for x in old if x not in new])
nums = {re.sub(r'^\D+ ', '', x) for x in new}
print("refs in new text without a defined label:", sorted(r for r in nref if r not in nums))
