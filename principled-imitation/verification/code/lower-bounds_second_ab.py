"""Second check of proofs/lower-bounds.md: Protocol AB (Theorem 3.3), its fault count (Proposition 3.8)
and the rehearsal-only variant (Proposition 3.9), implemented from the statements in the proof file,
on random small classes of functions with scaffolds whose inputs DEPEND on the answers.

For each instance: X = {0..nx-1}, Y = {0,1}; a class of random functions with random weights summing
to 1; the human f is a member; the scaffold has top-level input z uniform on [Z], no internal
randomness, and next_j = a fixed random table of (z, answers so far) -> input or STOP; the run
records all answers. Failure u_t (run of h_t differs from run of f) and faults v_t (calls of the
run of h_t at whose input h_t != f) are computed exactly by enumerating z; the training is
simulated R times. Checked:
  Theorem 3.3(1): a ln(1/(1-g)) + b ln(1/g) <= K ln 2 on every path (b at inputs of X0);
  Theorem 3.3(2): mean deployed failure <= L K /(n_B log2(1/g)) (for X0 = X and X0 = X1);
  Proposition 3.8(1): mean deployed faults <= L K /(n_B log2(1/g)) (X0 = X);
  Proposition 3.9: per-path potential inequality, and mean failure <= K L/(n log2(L/ln L)).
"""
import math, random

def make_instance(seed, nx=10, nH=30, Z=8, L=4, stop_p=0.15):
    rnd = random.Random(seed)
    H = [tuple(rnd.randint(0, 1) for _ in range(nx)) for _ in range(nH)]
    H = list(dict.fromkeys(H))  # distinct
    w = [rnd.random() ** 3 + 1e-3 for _ in H]
    s = sum(w); w = [x / s for x in w]
    table = {}
    def nxt(z, ans):
        key = (z, ans)
        if key not in table:
            r = random.Random(hash((seed, z, ans)) & 0xffffffff)
            table[key] = None if (len(ans) > 0 and r.random() < stop_p) else r.randrange(nx)
        return table[key]
    fi = rnd.randrange(len(H))
    return H, w, nxt, Z, L, nx, fi

def make_sparse(seed, nx=14, nH=25, Z=10, L=5):
    # members have at most one 1 on inputs 0..nx-4; inputs nx-3..nx-1 are reached only after two answers 1,
    # so X1 is a proper subset of X and runs of the vote may leave X1.
    rnd = random.Random(seed)
    core = nx - 3
    H = []
    for _ in range(nH):
        g = [0] * nx
        if rnd.random() < 0.8: g[rnd.randrange(core)] = 1
        for x in range(core, nx): g[x] = rnd.randint(0, 1)
        H.append(tuple(g))
    H = list(dict.fromkeys(H))
    w = [rnd.random() + 0.05 for _ in H]; s = sum(w); w = [x / s for x in w]
    table = {}
    def nxt(z, ans):
        key = (z, ans)
        if key not in table:
            r = random.Random(hash((seed, z, ans)) & 0xffffffff)
            if sum(ans) >= 2: table[key] = core + r.randrange(3)
            else: table[key] = r.randrange(core)
        return table[key]
    return H, w, nxt, Z, L, nx, rnd.randrange(len(H))

def run(h, z, nxt, L):
    ans = (); calls = []
    for j in range(L):
        x = nxt(z, ans)
        if x is None: break
        y = h[x]; calls.append((x, y)); ans = ans + (y,)
    return calls

def stats(h, f, nxt, Z, L):
    u = 0; v = 0
    for z in range(Z):
        rh = run(h, z, nxt, L); rf = run(f, z, nxt, L)
        u += (rh != rf)
        v += sum(1 for (x, y) in rh if f[x] != y)
    return u / Z, v / Z

def posterior_vote(H, w, V, nx):
    W = sum(w[i] for i in V)
    M1 = [sum(w[i] for i in V if H[i][x] == 1) / W for x in range(nx)]
    return W, M1

def protocol_AB(H, w, nxt, Z, L, nx, fi, gamma, nB, X0, rnd):
    f = H[fi]; V = set(range(len(H)))
    a = b = 0; us = []; vs = []
    K = math.log2(1 / w[fi])
    nbsteps = 0
    while nbsteps < nB:
        W, M1 = posterior_vote(H, w, V, nx)
        split = [x for x in sorted(X0) if max(M1[x], 1 - M1[x]) <= 1 - gamma]
        if split:
            x = split[0]; a += 1
            V = {i for i in V if H[i][x] == f[x]}
            continue
        h = tuple(1 if M1[x] > 0.5 else 0 for x in range(nx))  # unique on X0; ties outside: 0 first
        for x in range(nx):
            if x not in X0 and M1[x] == 0.5: h = h[:x] + (0,) + h[x+1:]
        u, v = stats(h, f, nxt, Z, L); us.append(u); vs.append(v)
        z = rnd.randrange(Z); J = rnd.randrange(1, L + 1)
        calls = run(h, z, nxt, L)
        if len(calls) >= J:
            x = calls[J - 1][0]
            if x in X0 and h[x] != f[x]: b += 1
            V = {i for i in V if H[i][x] == f[x]}
        nbsteps += 1
    pot = a * math.log(1 / (1 - gamma)) + b * math.log(1 / gamma)
    return pot, K * math.log(2), sum(us) / nB, sum(vs) / nB, K, sum(us), sum(vs), b

def variant_39(H, w, nxt, Z, L, nx, fi, n, rnd):
    f = H[fi]; V = set(range(len(H))); gamma = math.log(L) / L
    a = b = 0; us = []
    for t in range(n):
        W, M1 = posterior_vote(H, w, V, nx)
        h = tuple(1 if M1[x] > 0.5 else 0 for x in range(nx))
        splitset = {x for x in range(nx) if max(M1[x], 1 - M1[x]) <= 1 - gamma}
        us.append(stats(h, f, nxt, Z, L)[0])
        z = rnd.randrange(Z); calls = run(h, z, nxt, L)
        sp = [c for c in calls if c[0] in splitset]
        if sp:
            x = sp[0][0]; a += 1
        else:
            J = rnd.randrange(1, L + 1)
            if len(calls) < J: continue
            x = calls[J - 1][0]
            if h[x] != f[x]: b += 1
        V = {i for i in V if H[i][x] == f[x]}
    K = math.log2(1 / w[fi])
    pot = a * math.log(1 / (1 - gamma)) + b * math.log(1 / gamma)
    return pot, K * math.log(2), sum(us) / n, K

R = 300
allok = True
print("Theorem 3.3 and Proposition 3.8: mean over R training runs (exact failure/faults per step)")
summary = []
for seed in range(16):
    H, w, nxt, Z, L, nx, fi = make_instance(seed) if seed < 12 else make_sparse(seed)
    # X1: inputs occurring in runs of members
    X1 = set()
    for h in H:
        for z in range(Z):
            X1 |= {x for (x, y) in run(h, z, nxt, L)}
    for gamma in (0.1, 0.3):
        for nB in (3, 10):
            for name, X0 in (("X", set(range(nx))), ("X1", X1)):
                rnd = random.Random(1000 + seed)
                fails = []; faults = []; worst_pot = -1e9; dU = []; dV = []
                for r in range(R):
                    pot, cap, fl, ft, K, su, sv, bb = protocol_AB(H, w, nxt, Z, L, nx, fi, gamma, nB, X0, rnd)
                    worst_pot = max(worst_pot, pot - cap)
                    fails.append(fl); faults.append(ft); dU.append(su - L * bb); dV.append(sv - L * bb)
                bound = L * K / (nB * math.log2(1 / gamma))
                mf = sum(fails) / R; mft = sum(faults) / R
                se = (sum((x - mf) ** 2 for x in fails) / R) ** 0.5 / R ** 0.5
                ok1 = worst_pot <= 1e-9
                ok2 = mf <= bound + 3 * se + 1e-12
                ok3 = (name != "X") or (mft <= bound + 3 * se + 1e-12 + 0.05 * bound)
                # sharp forms: E[sum u_t] <= L E[b] (Thm 3.3(2) proof); E[sum v_t] = L E[b] when X0 = X (Prop 3.8(1))
                mdU = sum(dU) / R; sdU = (sum((x - mdU) ** 2 for x in dU) / R) ** 0.5 / R ** 0.5
                mdV = sum(dV) / R; sdV = (sum((x - mdV) ** 2 for x in dV) / R) ** 0.5 / R ** 0.5
                ok4 = mdU <= 3 * sdU + 1e-12
                ok5 = (name != "X") or abs(mdV) <= 3.5 * sdV + 1e-12
                ok3 = ok3 and ok4 and ok5
                allok &= ok1 and ok2 and ok3
                summary.append((name, mdU, sdU, mdV, sdV, ok4, ok5))
                if nB == 10 and gamma == 0.3 or not (ok1 and ok2 and ok3):
                    print(f"  seed={seed:2d} |X1|={len(X1):2d} K={K:5.2f} gamma={gamma} nB={nB:2d} X0={name:2s}: max(pot-K ln2)={worst_pot:+.3f};"
                          f" mean fail={mf:.4f} (se {se:.4f}); mean faults={mft:.4f}; bound LK/(nB log(1/g))={bound:.3f}  {'ok' if ok1 and ok2 and ok3 else 'FAIL'}")
print("  sharp forms over all cases: E[sum u - L b] (must be <= 0 up to noise), E[sum v - L b] (must be 0 when X0 = X):")
for nm in ("X", "X1"):
    rows = [t for t in summary if t[0] == nm]
    print(f"    X0={nm}: {len(rows)} cases; max z-score of E[sum u - L b] = {max(t[1]/max(t[2],1e-12) for t in rows):+.2f};"
          + (f" max |z-score| of E[sum v - L b] = {max(abs(t[3])/max(t[4],1e-12) for t in rows):.2f}" if nm == 'X' else "")
          + f"; all ok: {all(t[5] and t[6] for t in rows)}")
print("\nProposition 3.9 (rehearsal-only variant, gamma = ln L / L)")
for seed in range(12):
    H, w, nxt, Z, L, nx, fi = make_instance(seed, L=5)
    for n in (5, 20):
        rnd = random.Random(2000 + seed)
        fails = []; worst = -1e9
        for r in range(R):
            pot, cap, fl, K = variant_39(H, w, nxt, Z, L, nx, fi, n, rnd)
            worst = max(worst, pot - cap); fails.append(fl)
        mf = sum(fails) / R
        se = (sum((x - mf) ** 2 for x in fails) / R) ** 0.5 / R ** 0.5
        bound = K * L / (n * math.log2(L / math.log(L)))
        ok = worst <= 1e-9 and mf <= bound + 3 * se
        allok &= ok
        if n == 20 or not ok:
            print(f"  seed={seed:2d} K={K:5.2f} n={n:2d}: max(pot-K ln2)={worst:+.3f}; mean fail={mf:.4f} (se {se:.4f}); bound={bound:.3f} {'ok' if ok else 'FAIL'}")
print("\nall checks passed" if allok else "\nSOME CHECK FAILED")
