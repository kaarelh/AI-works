import itertools
from collections import defaultdict
atoms = 'abcd'
triples = ['abc', 'abd', 'acd', 'bcd']
pts3 = list(itertools.product([0,1], repeat=3))
def proj(mask, tri, pair):
    idx = [tri.index(x) for x in pair]
    out = 0
    for k, p in enumerate(pts3):
        if mask >> k & 1:
            q = (p[idx[0]], p[idx[1]]); out |= 1 << (2*q[0] + q[1])
    return out
by = {}
for tri in triples:
    for pair in itertools.combinations(tri, 2):
        pair = ''.join(pair)
        d = defaultdict(list)
        for m in range(1, 256): d[proj(m, tri, pair)].append(m)
        by[(tri, pair)] = d
def members(mask, tri):
    return [p for k, p in enumerate(pts3) if mask >> k & 1]
found = None; count = 0
for R1 in range(1, 256):
    for R2 in by[('abd','ab')][proj(R1,'abc','ab')]:
        c3 = set(by[('acd','ac')][proj(R1,'abc','ac')]) & set(by[('acd','ad')][proj(R2,'abd','ad')])
        for R3 in c3:
            c4 = set(by[('bcd','bc')][proj(R1,'abc','bc')]) & set(by[('bcd','bd')][proj(R2,'abd','bd')]) & set(by[('bcd','cd')][proj(R3,'acd','cd')])
            for R4 in c4:
                count += 1
                ok = False
                for g in itertools.product([0,1], repeat=4):
                    gv = dict(zip(atoms, g))
                    if all(tuple(gv[x] for x in tri) in members(R, tri) for tri, R in zip(triples, (R1,R2,R3,R4))):
                        ok = True; break
                if not ok:
                    found = (members(R1,'abc'), members(R2,'abd'), members(R3,'acd'), members(R4,'bcd')); break
            if found: break
        if found: break
    if found: break
print("pairwise-consistent Boolean systems examined:", count, "| globally inconsistent example:", found)
