p='/home/user/AI-works/axiom-schemas/research/tracks/single/e4_anchor_random.py'
src=open(p).read()
old="""    if enum is not None and pred != enum:
        examples.setdefault('pred!=enum', (T, ths))
"""
new="""    if enum is not None and pred != enum:
        # is the disagreement an artifact of the enumeration bounds?  (some feature template that is
        # not >= T* would have to fit the bounds: size, arities, argument size)
        fits = []
        for U in bad:
            occU = occurrences(U)
            ok = size(U) <= smax and all(len(o[2]) in (arT if msort(o[1]) == 'T' else arF) for o in occU) \\
                and all(size(a) <= min(amax, 2) for o in occU for a in o[2])
            fits.append(ok)
        outside_rich = any(not P.accepts(q) for q in pool)
        if pred is False and enum is True and not any(fits) and (bad or outside_rich):
            bump('pred!=enum: bound artifact (no witnessing feature template fits the bounds)')
        else:
            bump('pred!=enum: UNEXPLAINED')
            examples.setdefault('pred!=enum', (T, ths))
"""
assert old in src
src=src.replace(old,new)
open(p,'w').write(src)
