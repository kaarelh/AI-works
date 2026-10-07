import sys, itertools
def height_of_family(m, blocks):
    # C = intersection closure of blocks plus universe. compute max elasticity (single class).
    U=(1<<m)-1
    fam=set(blocks)|{U}
    # closure under intersection
    changed=True
    while changed:
        changed=False
        L=list(fam)
        for a in L:
            for b in L:
                c=a&b
                if c not in fam: fam.add(c); changed=True
    fam=list(fam)
    def cl(T):
        r=U
        for c in fam:
            if T & ~c ==0: r&=c
        return r
    memo={}
    def R(T):
        if T in memo: return memo[T]
        c=cl(T); best=0
        for s in range(m):
            if not (c>>s)&1:
                best=max(best,1+R(T|1<<s))
        memo[T]=best; return best
    return R(0), len(fam)
def parse(lines):
    parts=[]
    for ln in lines:
        i,rest=ln.split(' ',1)
        parts.append(eval(rest))
    return parts
lines=[l.rstrip('\n') for l in open(sys.argv[1]) if l[0].isdigit() and ' (' in l]
parts=parse(lines); m=len(parts); k=2
blocks=[]
for i,lab in enumerate(parts):
    for b in range(k):
        B=0
        for j,x in enumerate(lab):
            if x==b: B|=1<<j
        blocks.append(B)
print('m',m,'height of intersection-closure family', height_of_family(m,blocks))
