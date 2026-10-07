import sys, pickle, random, time
sys.path.insert(0, '.')
from indep_eval import Struct, PABounded, qdepth
which = sys.argv[1]
uniq = pickle.load(open('log_%s.pkl' % which, 'rb'))
bad = 0; checked = 0; skipped = 0; agree_def = 0
t0 = time.time()
if which == 'PA':
    E = PABounded(B=10)
    for (lang, s), r in uniq.items():
        if r is None: continue
        try:
            m = E.truth(s)
        except Exception as e:
            skipped += 1; continue
        checked += 1
        if m is not None and m != r:
            bad += 1
            if bad <= 5:
                from dtrc_pp import pp
        if m is not None and m == r: agree_def += 1
    print('PA verdicts checked', checked, 'skipped', skipped, 'definitive agreements', agree_def, 'CONTRADICTIONS', bad)
else:
    rng = random.Random(3)
    structs = [Struct(rng, n_extra=6, p_hf_in_extra=p, p_extra_in_extra=q) for p, q in ((0.0, 0.0), (0.3, 0.3), (0.7, 0.5), (1.0, 0.0))]
    for (lang, s), r in uniq.items():
        if r is None: continue
        from indep_eval import strip_close
        if qdepth(strip_close(s)) > 4:
            skipped += 1; continue
        checked += 1
        for M in structs:
            if M.truth(s) != r:
                bad += 1
                if bad <= 5:
                    sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
                    from dtrc.syntax import pp
                    print('CONTRADICTION oracle', r, 'in M', not r, pp(s))
                break
    print('ZF verdicts checked', checked, 'skipped (qdepth>4)', skipped, 'CONTRADICTIONS', bad, '%.0fs' % (time.time() - t0))
