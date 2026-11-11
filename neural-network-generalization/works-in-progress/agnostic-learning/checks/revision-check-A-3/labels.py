import re, sys
def labels(path):
    t = open(path, encoding='utf-8').read()
    heads = re.findall(r'^(#{1,4} .*)$', t, re.M)
    res = re.findall(r'^\*\*((?:Lemma|Theorem|Proposition|Corollary|Remark|Observation|Claim) [0-9]+\.[0-9]+[a-z′]*)', t, re.M)
    tags = re.findall(r'\\tag\{([^}]*)\}', t)
    tables = re.findall(r'Table ([0-9]+\.[0-9]+)', t)
    return heads, res, tags, sorted(set(tables))
o = labels(sys.argv[1]); n = labels(sys.argv[2])
for name, a, b in zip(['headers','results','tags','tables'], o, n):
    sa, sb = list(a), list(b)
    print('==', name, 'old', len(sa), 'new', len(sb))
    print('  removed:', [x for x in sa if x not in sb])
    print('  added:  ', [x for x in sb if x not in sa])
    # order check of common
    common_old = [x for x in sa if x in sb]; common_new = [x for x in sb if x in sa]
    print('  same order of common items:', common_old == common_new)
