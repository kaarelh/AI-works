p='/home/user/AI-works/axiom-schemas/research/tracks/single/e3_finitary.py'
s=open(p).read()
s=s.replace("""    if len(E) > 2500:""","""    if len(E) > 1500:""")
old="""    agree = 0
    for q in pool:"""
new="""    rng.shuffle(pool)
    pool = pool[:300]
    agree = 0
    for q in pool:"""
assert old in s; s=s.replace(old,new)
old="""for case in range(NC):
    T = rand_template(rng)"""
new="""for case in range(NC):
    if case % 10 == 0:
        print('progress', case, dict(stats), '%.0fs' % (time.time() - t0), flush=True)
    T = rand_template(rng)"""
assert old in s; s=s.replace(old,new)
s=s.replace("""    if case % 10 == 9:
        print('progress', case + 1, dict(stats), flush=True)
""","")
open(p,'w').write(s)
print('edited')
