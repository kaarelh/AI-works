import sys, os, numpy as np
sys.path.insert(0, '/home/user/AI-works/gd-circuit-growth/study')
import common as C
EV = '/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/model_evals'
M = {m: C.load_eval(f'{EV}/{m}.npz') for m in ('race', 'nngp-kernel', 'hybrid')}
def score(cells):
    num = den = 0.0
    for en, em, ag in cells:
        ind = (1 - en) * (1 - em) + en * em; num += ag - ind; den += 1 - ind
    return num / den
for regime, sel in (('n<=128', lambda n: n <= 128), ('n in 256..2048', lambda n: n >= 256)):
    acc = {}
    for fn in C.FNS:
        z = np.load(os.path.join(C.RESULTS, f'fixed_adam_{fn}.npz')); nn = C.nn_fixed(fn)
        I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z['net_n'], z['net_s']))}
        yte = C.test_data(fn)[1]
        for a, n in enumerate(nn['ns']):
            if not (0.05 <= nn['test_err'][a].mean() <= 0.45 and sel(n)): continue
            for c, step in enumerate(z['step']):
                P = np.array([z['pred'][c, I[(int(n), s)]] for s in range(3)])
                en = np.mean(P != yte[None]); tr = np.mean([z['train_err'][c, I[(int(n), s)]] for s in range(3)])
                for m, r in M.items():
                    Q = r['pred'][fn][a]; em = np.mean(Q != yte[None]); ag = np.mean(P == Q)
                    acc.setdefault((int(step), m), []).append((en, em, ag))
                Pf = np.array([z['pred'][-1, I[(int(n), s)]] for s in range(3)])
                acc.setdefault((int(step), 'final net'), []).append((en, np.mean(Pf != yte[None]), np.mean(P == Pf)))
                acc.setdefault((int(step), 'train_err'), []).append(tr); acc.setdefault((int(step), 'test_err'), []).append(en)
    print(f'--- {regime}: per-example agreement of the network at step t with ...')
    print(f"{'step':>6s} {'train err':>9s} {'test err':>9s} " + ' '.join(f'{m:>12s}' for m in ('race', 'nngp-kernel', 'hybrid', 'final net')))
    for step in sorted({k[0] for k in acc}):
        if step == 0: continue
        print(f"{step:6d} {np.mean(acc[(step,'train_err')]):9.3f} {np.mean(acc[(step,'test_err')]):9.3f} " + ' '.join(f'{score(acc[(step, m)]):12.3f}' for m in ('race', 'nngp-kernel', 'hybrid', 'final net')))
