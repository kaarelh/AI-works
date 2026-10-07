p='/home/user/AI-works/axiom-schemas/research/tracks/single/e4_anchor_random.py'
src=open(p).read()
src=src.replace("import sys, random, time, itertools","import sys, random, time, itertools, signal\n\nclass Timeout(Exception):\n    pass\ndef _alarm(sig, frm):\n    raise Timeout()\nsignal.signal(signal.SIGALRM, _alarm)",1)
old="""        t1 = time.time()
        E = enumerate_covering(D, smax, amax=min(amax, 2), arities_T=arT, arities_F=arF,
                               consts=('0', 'pa'), funcs=(('S', 1), ('add', 2)))
"""
new="""        t1 = time.time()
        signal.alarm(25)
        try:
            E = enumerate_covering(D, smax, amax=min(amax, 2), arities_T=arT, arities_F=arF,
                                   consts=('0', 'pa'), funcs=(('S', 1), ('add', 2)))
            signal.alarm(0)
        except Timeout:
            E = None
            bump('enum_timeout')
    if smax <= 22 and E is not None:
"""
assert old in src
src=src.replace(old,new)
src=src.replace("    enum = None\n    if smax <= 22:\n","    enum = None\n    E = None\n    if smax <= 22:\n")
open(p,'w').write(src)
