"""Thread Q2: checks for research/threadQ2-freshlook.md.

Run:  python3 -B threadQ2_blindspot.py   (about 1 minute, fixed seeds)

Part A. Theorem Q2.1 (blind-spot ratio). A "kinds" model of VSI's learning loop:
        each problem needs one kind of knowledge; a missing kind makes the first run fail;
        a failed run carries a wrong claimed solution w.p. w_k, which V passes w.p. f_k
        (fresh per problem); every rejection is a hit that teaches the kind (b = 1 hit per
        kind, so K/b = number of kinds). We count wrong outputs against the bound
        c * (rejections), c = max_k w_k f_k / (1 - w_k f_k).
Part B. Theorem Q2.3 (falsification by use). A pure blind spot of V (w = f = 1) on some
        kinds; outputs are cited by later problems; each citation of a false output exposes
        it w.p. e (a located, machine-checkable counterexample), which is a hit; the library
        is the current decoder's outputs. We count uses of false outputs against K/(b e).
Part C. Thread U's P(works) model (threadU_verify.py, imported unchanged) with the
        rejection budget of Theorem 5(b) imposed: over T problems at most K rejections
        (b = 1), so the first-run failure rate p cannot stay above 1/(TK (1 - w f)).
"""
import math
import numpy as np

import threadU_verify as U


# ---------------------------------------------------------------- Part A
def kinds_run(T, freqs, w, f, rng, fresh_rate=0.0, mask=None):
    """One deployment of T i.i.d. problems.
    freqs: probabilities of the kinds (sum <= 1; the rest are routine problems).
    w, f: per-kind claim share and V's miss rate on that kind's wrong claims.
    fresh_rate: probability that a problem needs a brand-new kind (problem-specific insight,
                w and f drawn as for kind 0).
    mask: optional (w2, f2): each kind has a second, masked layer that shows only after the
          first is learned (thread S's unmasking); the second layer also costs one hit.
    Returns cumulative arrays: wrong outputs, rejections, and kinds learned (= hits)."""
    m = len(freqs)
    known = np.zeros(m, dtype=np.int8)          # 0 none, 1 first layer, 2 both (mask)
    full = 2 if mask else 1
    cum = np.concatenate([[0.0], np.cumsum(freqs)])
    u_kind = rng.random(T)
    u_claim = rng.random(T)
    u_miss = rng.random(T)
    u_fresh = rng.random(T)
    wrong = np.zeros(T, dtype=np.int32)
    rej = np.zeros(T, dtype=np.int32)
    hits = 0
    for t in range(T):
        if fresh_rate and u_fresh[t] < fresh_rate:
            wk, fk = w[0], f[0]                  # a new kind, never seen again
            if u_claim[t] < wk and u_miss[t] < fk:
                wrong[t] = 1
            else:
                rej[t] = 1
                hits += 1
            continue
        k = np.searchsorted(cum, u_kind[t], side="right") - 1
        if k >= m or known[k] >= full:
            continue                              # routine, or kind fully known: correct run
        if mask and known[k] == 1:
            wk, fk = mask
        else:
            wk, fk = w[k], f[k]
        if u_claim[t] < wk and u_miss[t] < fk:
            wrong[t] = 1                          # wrong claim passed: output, nothing learned
        else:
            rej[t] = 1                            # rejected: search, hit, learn, rerun succeeds
            known[k] += 1
            hits += 1
    return np.cumsum(wrong), np.cumsum(rej), hits


def part_a():
    print("A. Theorem Q2.1: wrong outputs stay O(K) when V has no total blind spot")
    print("   m = 400 kinds, Zipf(1.1) frequencies over 70% of problems (30% routine); 20 seeds;")
    print("   'bound' is c * rejections (reruns succeed here, so the +1 term is 0).")
    m = 400
    z = 1.0 / np.arange(1, m + 1) ** 1.1
    freqs = 0.7 * z / z.sum()
    Ts = [1000, 10000, 100000]
    scen = []
    scen.append(("uniform: w = 0.5, f = 0.4", np.full(m, 0.5), np.full(m, 0.4), 0.0, None))
    rngp = np.random.default_rng(7)
    wh, fh = rngp.uniform(0.3, 0.9, m), rngp.uniform(0.2, 0.95, m)
    scen.append(("heterogeneous: w ~ U[.3,.9], f ~ U[.2,.95]", wh, fh, 0.0, None))
    fb = np.full(m, 0.4); wb = np.full(m, 0.5)
    fb[5] = 1.0; wb[5] = 1.0                       # one pure blind spot, ~1.7% of problems
    scen.append(("one pure blind spot (kind 6: w = f = 1)", wb, fb, 0.0, None))
    scen.append(("unmasking: hidden 2nd layer w = 1, f = 0.9", np.full(m, 0.5), np.full(m, 0.2), 0.0,
                 (1.0, 0.9)))
    scen.append(("30% problem-specific (fresh) kinds, w = 0.5, f = 0.4", np.full(m, 0.5),
                 np.full(m, 0.4), 0.3, None))
    out = {}
    for name, w, f, fr, mask in scen:
        wf = w * f
        c = float(np.max(np.where(wf < 1, wf / np.maximum(1e-12, 1 - wf), np.inf)))
        if mask:
            c = max(c, mask[0] * mask[1] / (1 - mask[0] * mask[1]))
        rows = []
        for T in Ts:
            W, R, H = [], [], []
            for s in range(20):
                rng = np.random.default_rng(1000 * s + 17)
                cw, cr, h = kinds_run(T, freqs, w, f, rng, fr, mask)
                W.append(cw[-1]); R.append(cr[-1]); H.append(h)
                if T == Ts[-1] and s == 0:
                    # late window: failure rate vs (c+1) * rejection rate, last 10% of rounds
                    a = int(0.9 * T)
                    out[name] = ((cw[-1] - cw[a]) / (T - a), (cr[-1] - cr[a]) / (T - a))
            W, R = np.mean(W), np.mean(R)
            rows.append((T, W, R, W / T))
        cs = "inf" if math.isinf(c) else "%.2f" % c
        ck = np.where(wf < 1, wf / np.maximum(1e-12, 1 - wf), np.inf)
        if mask:
            ck = ck + mask[0] * mask[1] / (1 - mask[0] * mask[1])
        sum_ck = float(np.sum(ck)) + (fr > 0) * 0.0
        print("   %-55s c = %s; product-class bound sum_k c_k = %s" % (
            name, cs, "inf" if math.isinf(sum_ck) else "%.0f" % sum_ck))
        for T, W, R, F in rows:
            b = "inf" if math.isinf(c) else "%.0f" % (c * R)
            print("      T = %6d: wrong outputs %8.1f (rate %.4f), rejections %7.1f, bound c*R = %s"
                  % (T, W, F, R, b))
        Fw, Rw = out[name]
        print("      last 10%% of T = 1e5 (seed 0): failure rate %.4f, rejection rate %.4f, "
              "(c+1) x rejection rate %s" % (Fw, Rw, "inf" if math.isinf(c) else "%.4f" % ((c + 1) * Rw)))
    print("   Reading: with no total blind spot the total stays near c*m whatever T, so the rate")
    print("   falls like K/T; a pure blind spot or problem-specific kinds make it linear in T.")
    print()


# ---------------------------------------------------------------- Part B
def part_b():
    print("B. Theorem Q2.3: falsification by use bounds reliance on false outputs by K/(b e)")
    print("   m = 200 kinds over all problems (Zipf 1.1); V passes every wrong claim of the first")
    print("   50 kinds (w = f = 1: a pure blind spot) and catches the rest (f = 0); each problem")
    print("   cites u = 3 uniform earlier outputs; a cited false output is exposed w.p. e, which is")
    print("   a hit; the library is recomputed (outputs of a learned kind become correct). 20 seeds.")
    m = 200
    z = 1.0 / np.arange(1, m + 1) ** 1.1
    freqs = z / z.sum()
    blind = np.zeros(m, dtype=bool); blind[:50] = True
    T, u = 20000, 3
    for e in [0.05, 0.2, 0.5]:
        FU, EX, WO = [], [], []
        for s in range(20):
            rng = np.random.default_rng(500 + s)
            known = np.zeros(m, dtype=bool)
            kinds = rng.choice(m, size=T, p=freqs)
            lib_kind = np.empty(T, dtype=np.int32)
            false_uses = 0; exposures = 0; wrong_out = 0
            for t in range(T):
                k = kinds[t]
                if t > 0:
                    cites = rng.integers(0, t, size=u)
                    for j in cites:
                        kj = lib_kind[j]
                        if blind[kj] and not known[kj]:      # current output of j is false
                            false_uses += 1
                            if rng.random() < e:
                                exposures += 1
                                known[kj] = True              # search on the current run, hit
                if not known[k]:
                    if blind[k]:
                        wrong_out += 1                        # passes V; output, nothing learned
                    else:
                        known[k] = True                       # rejected; hit; rerun succeeds
                lib_kind[t] = k
            FU.append(false_uses); EX.append(exposures); WO.append(wrong_out)
        print("   e = %.2f: uses of false outputs %7.1f (bound K/(b e) with 50 blind kinds: %5.0f), "
              "exposures %.1f, wrong outputs released %.1f" % (e, np.mean(FU), 50 / e, np.mean(EX), np.mean(WO)))
    print("   Without uses (e = 0) every blind-kind problem is a wrong output for ever: about")
    print("   %.0f%% of problems." % (100 * freqs[:50].sum()))
    print()


# ---------------------------------------------------------------- Part C
def p_works_variants(dom, fm, ft, cost, fr, located, iota, feas, n=200000, seed=3):
    """Same draws, in the same order, as threadU_verify.p_works (h = 0), then F three ways:
    orig : thread U's F = p w rbar f (p independent of T/K)
    cap  : p capped by the rejection budget, p <= 1/(TK (1 - w f)), f = the mixed f_V
    worst: the same with f = the worst type's f_V (all residual errors of the hardest type)
    thmA : Theorem Q2.1's bound F <= (c+1)/TK, c = w f_worst / (1 - w f_worst)."""
    D = U.DOMAINS[dom]
    rng = np.random.default_rng(seed)
    u = np.exp(rng.normal(0.0, 0.55, n))
    f = np.interp(np.log(u), np.log(U.U_GRID), fm)
    fw = np.max(np.stack([np.interp(np.log(u), np.log(U.U_GRID), v) for v in ft.values()]), axis=0)
    p = rng.uniform(0.10, 0.50, n)
    w = rng.uniform(*D["w"], n)
    rbar = rng.uniform(1.0, 1.6, n)
    _h = rng.uniform(*D["h"], n) * 0.0
    transfer = rng.random(n) < D["pi_t"]
    n0 = rng.uniform(20, 40, n)
    s = rng.uniform(0.5, 2.0, n)
    TK = np.exp(rng.uniform(math.log(3), math.log(30), n))
    per_rej = U.COST_LOCATED if located else U.N_OVER_N0 * n0
    c_p = 1.0 + cost * n0 + fr * per_rej
    ok_eff = TK * c_p <= (4 - (1 + iota) * s) * n0
    ok_other = rng.random(n) < D["p_rest_other"] * feas
    p0 = np.where(transfer, 0.0, p)
    # per-kind accounting (Theorem Q2.1(b)): each kind of type tau contributes at most
    # c_tau = w f_tau / (1 - w f_tau) wrong outputs per rejection; kinds split by type shares
    shares = D["types"]
    cbar = np.zeros(n)
    for tname, v in ft.items():
        ftau = np.interp(np.log(u), np.log(U.U_GRID), v)
        cbar += shares[tname] * w * ftau / (1 - w * ftau)
    F = {}
    F["orig"] = p0 * w * rbar * f
    F["cap"] = np.minimum(p0, 1.0 / (TK * (1 - w * f))) * w * rbar * f
    F["kinds"] = np.minimum(F["orig"], rbar * cbar / TK)
    F["worst"] = np.minimum(p0, 1.0 / (TK * (1 - w * fw))) * w * rbar * fw
    res = {k: float(np.mean((v <= 0.05) & ok_eff & ok_other)) for k, v in F.items()}
    res["out_orig"] = float(np.mean(F["orig"] <= 0.05))
    res["out_kinds"] = float(np.mean(F["kinds"] <= 0.05))
    res["eff"] = float(np.mean(ok_eff))
    return res, float(np.median(fw)), float(np.median(f)), float(np.median(cbar))


def part_c():
    print("C. Thread U's P(works) with the rejection budget of Theorem 5(b) imposed")
    print("   (same draws as threadU_verify.p_works; 'orig' must reproduce its model figures).")
    print("   orig : F = p w rbar f with p ~ U[.1,.5] independent of T/K ~ logU[3,30]")
    print("   cap  : p <= 1/(T/K (1 - w f)), since rejections <= K (b = 1) under (A2), (A3');")
    print("          mixed f, i.e. learning does not shift the error mix (no allocation)")
    print("   kinds: F <= rbar * cbar / (T/K), cbar = sum_tau share_tau w f_tau/(1 - w f_tau):")
    print("          Theorem Q2.1(b), each kind of error bounded separately (allocation allowed)")
    print("   worst: as cap, with every error of the protocol's hardest type from the start")
    picks = [
        ("math", "V-human: one expert reads (unlocated verdict)"),
        ("math", "read + AI critics (3)"),
        ("math", U.BEST["math"]),
        ("software", "fixed acceptance tests only (folder's test-suite row)"),
        ("software", U.BEST["software"]),
        ("empirical", "V-human: one expert reads (unlocated)"),
        ("empirical", U.BEST["empirical"]),
        ("empirical-analysis", U.BEST["empirical-analysis"]),
        ("judgment", U.BEST["judgment"]),
    ]
    comps = {(d, nm): c for d in U.PROTOCOLS for nm, c in U.PROTOCOLS[d]}
    for dom, name in picks:
        fm, ft = U.f_protocol(dom, comps[(dom, name)])
        cost, fr, loc, iota, feas = U.protocol_cost(dom, comps[(dom, name)])
        ref = U.p_works(dom, fm, cost, fr, loc, iota, feas)[0]
        res, fwmed, fmed, cbmed = p_works_variants(dom, fm, ft, cost, fr, loc, iota, feas)
        print("   %-9s %-52s orig %2.0f%% (threadU %2.0f%%) cap %2.0f%% kinds %2.0f%% worst %2.0f%%"
              " | output ok %2.0f%%->%2.0f%%, effort ok %2.0f%% | f %.2f, worst f %.2f, cbar %.2f" % (
                  dom[:9], name[:52], 100 * res["orig"], 100 * ref, 100 * res["cap"],
                  100 * res["kinds"], 100 * res["worst"], 100 * res["out_orig"],
                  100 * res["out_kinds"], 100 * res["eff"], fmed, fwmed, cbmed))
    # how many of thread U's no-transfer draws violate the rejection budget (b = 1)
    rng = np.random.default_rng(11)
    p = rng.uniform(0.1, 0.5, 200000)
    TK = np.exp(rng.uniform(math.log(3), math.log(30), 200000))
    for wf in (0.19, 0.45):
        print("   share of no-transfer draws with p (1 - wf) T > K, at wf = %.2f: %.0f%%" % (
            wf, 100 * np.mean(p * (1 - wf) * TK > 1)))
    print("   Reading: thread U samples p and T/K independently, so most of its no-transfer draws")
    print("   need more rejections than Theorem 5(b) allows. Imposing the budget raises every row")
    print("   whose binding constraint was output failure. Counting errors kind by kind keeps most")
    print("   of the gain; only the extreme 'all errors of the hardest type' reading erases it.")
    print()


if __name__ == "__main__":
    part_a()
    part_b()
    part_c()
