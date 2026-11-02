"""Part 11, Q7 'order': the order in which DFG v1.3 ALONE admits a target's structure, recorded round by round.

A fit is part11/interp/dfg_hooks.fit_toy_dfg (bit for bit the fit eval_dfg.py makes for `dfg13-perm`: harness training
rows, rng default_rng([fn_seed(target), seed, n, 77]), harness.Permuted's column order, md5-checked dfg13.py, readout
"logit"), with ONE addition: numpy.linalg.solve is wrapped for the duration of the fit and every solution is kept.
DFG solves exactly one linear system per least-squares fit (lsfit: once before round 0, once after every round) and one
per Newton step of the logistic refinement (15, when n >= 8 p).  Splitting the recorded solves by the _fit calls that
dfg_hooks records (n, rounds, size) gives, for every round j of the final fit, the number of features after it
(p_{j+1} = len(w_{j+1})) and its least-squares weights w_{j+1}.  Nothing in the learner changes; the wrapper returns
what solve returned.

Per fit (one target, seed, n) this records, in ORIGINAL input coordinates (x1 = input 0):
  rounds      per round j: residual rms s (replayed, checked against DFG's own log), the features admitted in round j
              (explicit characters, linear block, spectral features, sum blocks with their support), the stop reason
  phi         the learned fraction of every target character S (Part 5's measure): c_S(f) / yhat_S, where c_S(f) is the
              Fourier coefficient of E[f | x_R] on the target's relevant inputs R, estimated on all 2^|R| patterns of x_R
              times M random completions of the other inputs (M = max(32, 32768 / 2^|R|)).  f is
                ls[k]  the least-squares function after round k-1 (k = 0: the constant alone), the model DFG holds then;
                final  the predictor's real-valued output (logistic weights + kernel background), whose sign predicts;
                final_ls the final least-squares function plus the kernel background (readout 'ls').
  explicit    for every target character: the round in which chi_S itself became a feature (None if never), and how
              (a character admitted by the tests, a forced character, or one of the linear block's inputs)
  replay      for every target character not yet a feature, at the start of every round j (and at the stopping round):
              v = mean(r chi_S) and the z-score |v| / threshold in each candidate class it belongs to, with the class's
              own union-bound count N and subsample m, exactly as DFG._fit computes them:
                global  |S| <= K (K = 4 in round 0, 3 after), N = C(d, |S|); degrees 5, 6 in round 0 on m points
                ext1    S = T u {j} for a current character T (top 32 by |w|), N = (#bases) d
                ext2    S = T u {j, l}, N = (#bases) C(d, 2), on m points
                local   S inside V = inputs of the current characters, 2 <= |V| <= 12, N = C(|V|, |S|)
              DFG accepts S when its best z exceeds 1 (then the 64 best by z, within the room p <= n / 2).
Writes order/results/cells/<target>__n<n>__s<seed>.json.gz.

usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python order_fit.py [targets] [--seeds=0,1,2] [--ns=16,...]
"""
import os, sys, json, gzip, math, time, itertools, numpy as np

HERE = os.path.dirname(os.path.abspath(__file__)); INTERP = os.path.dirname(HERE)
sys.path.insert(0, INTERP)
import dfg_hooks as H                                                 # noqa: E402  (sets the runner's sys.path)
TH = H.TH

OUT = os.path.join(HERE, "results", "cells"); os.makedirs(OUT, exist_ok=True)
TARGETS = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9", "andxor", "dlist5", "parmaj", "dnf3", "rand1", "rand3"]
NS = [2 ** k for k in range(4, 15)]


class SolveRec:
    """Keeps every numpy.linalg.solve solution made while active (DFG's least-squares and Newton steps)."""

    def __enter__(self):
        self._orig = np.linalg.solve; self.sols = []; rec = self; orig = self._orig

        def solve(a, b, *args, **kw):
            out = orig(a, b, *args, **kw)
            rec.sols.append(np.array(out, dtype=np.float64, copy=True))
            return out
        np.linalg.solve = solve
        return self

    def __exit__(self, *exc):
        np.linalg.solve = self._orig
        return False


def split_solves(sols, calls, logit=True):
    """The recorded solves, per _fit call: 1 + rounds least-squares solutions, then 15 Newton steps if n >= 8 size."""
    out, i = [], 0
    for c in calls:
        k = 1 + c["rounds"]; ls = sols[i:i + k]; i += k
        nl = 15 if (logit and c["n"] >= 8 * c["size"]) else 0; i += nl
        assert len(ls[-1]) == c["size"], ("solve split", len(ls[-1]), c["size"])
        assert all(len(ls[a]) <= len(ls[a + 1]) for a in range(len(ls) - 1))
        out.append(ls)
    assert i == len(sols), ("unparsed solves", i, len(sols))
    return out


def subsets(r):
    return [T for k in range(r + 1) for T in itertools.combinations(range(r), k)]


def target_support(fn, R, d=30):
    """Exact Fourier support of f on its relevant inputs R: list of (name, original subset, yhat), constant included."""
    r = len(R); pats = np.array(list(itertools.product([-1.0, 1.0], repeat=r)))
    X = np.ones((len(pats), d)); X[:, R] = pats; y = fn(X).astype(np.float64)
    sup = []
    for T in subsets(r):
        c = float(np.mean(y * (np.prod(pats[:, list(T)], 1) if T else 1.0)))
        if abs(c) > 1e-9:
            S = tuple(R[i] for i in T)
            sup.append(("".join(f"x{i + 1}" for i in S) or "1", S, c))
    return sup, pats


def probe(fn_name, R, d=30):
    """All 2^r patterns of x_R (itertools.product order, as Part 5's run_traj.probe_set) times M random completions."""
    r = len(R); pats = np.array(list(itertools.product([-1.0, 1.0], repeat=r)))
    M = max(32, 32768 // len(pats))
    rng = np.random.default_rng([TH.fn_seed(fn_name), 4321, 11])
    Z = rng.choice(np.array([-1.0, 1.0]), size=(len(pats), M, d)); Z[:, :, R] = pats[:, None, :]
    return pats, M, Z.reshape(-1, d)


def columns(F, B, Z):
    """Feature columns of F at Z (learner coordinates), exactly as DFG._fit builds them."""
    cols, cache = [], {}
    for kind, k in F:
        if kind == "chi":
            cols.append(np.prod(Z[:, list(k)], axis=1) if k else np.ones(len(Z)))
        elif kind == "sum":
            bid, v = k
            if bid not in cache:
                b = B[bid]; cache[bid] = (b.group(Z), np.prod(Z[:, list(b.mod)], axis=1) if b.mod else np.ones(len(Z)))
            g, cm = cache[bid]; cols.append((g == v) * cm)
        else:
            u = np.asarray(k, dtype=np.float64); cols.append((Z @ u) ** 2 - u @ u)
    return np.stack(cols, 1)


def fourier_on_R(fvals, npat, M, sup_idx, Cm):
    """Fourier coefficients (on the target's support) of E[f | x_R] from probe values f (npat * M)."""
    fR = fvals.reshape(npat, M).mean(1)
    return Cm.T @ fR / npat


def replay_round(X, y, r, s, n, d, j, Fp, wp, S_l, hi, scale, dfg, DM):
    """z-scores of one candidate S_l (learner coordinates, sorted tuple) at the start of round j, per class, exactly as
    DFG._fit's tests compute them (see the module docstring).  Fp: features so far, wp: their least-squares weights."""
    c, K, delta, budget, budget_hi = dfg.c, dfg.K, dfg.delta, dfg.budget, dfg.budget_hi
    GD = TH.gd_flops(d) * scale
    thr = lambda N: c * s * math.sqrt(2 * math.log(4 * K * max(N, 1) / delta) / n)

    def thr_m(N, m):
        return thr(N) * math.sqrt(n / m) * (math.sqrt(np.mean(r[:m] ** 2)) / s if m < n else 1.0)
    chi = np.prod(X[:, list(S_l)], axis=1)
    v_full = float(np.mean(r * chi)); k = len(S_l); out = dict(v=v_full)
    Kj = dfg.K if j == 0 else dfg.K_later
    if k == 1:
        out["global"] = dict(z=abs(v_full) / thr(d), N=d, m=n)
    elif k == 2 and Kj >= 2:
        out["global"] = dict(z=abs(v_full) / thr(math.comb(d, 2)), N=math.comb(d, 2), m=n)
    elif k == 3 and Kj >= 3:
        m = min(n, int(budget[1] * GD / (d * (2 * d * d + 2 * d))))
        if m >= 32:
            vm = float(np.mean(r[:m] * chi[:m])); out["global"] = dict(z=abs(vm) / thr_m(math.comb(d, 3), max(m, 1)), N=math.comb(d, 3), m=m)
    elif k == 4 and Kj >= 4:
        m = min(n, int(budget[0] * GD / (math.comb(d, 2) * (2 * d * d + 3 * d))))
        if m >= 32:
            vm = float(np.mean(r[:m] * chi[:m])); out["global"] = dict(z=abs(vm) / thr_m(math.comb(d, 4), max(m, 1)), N=math.comb(d, 4), m=m)
    elif k in range(dfg.K + 1, dfg.K_hi + 1) and j == 0 and hi:
        k1, k2 = (k + 1) // 2, k // 2; N1, N2 = math.comb(d, k1), math.comb(d, k2)
        m = min(n, int(budget_hi * GD / (2 * N1 * N2 + DM.m_tab_cost(d, k1, k2))))
        if m >= 64:
            vm = float(np.mean(r[:m] * chi[:m]))
            out["global"] = dict(z=abs(vm) / thr_m(math.comb(d, k), m), N=math.comb(d, k), m=m, offered_only_if_pass=True)
    base = [(kk, abs(wi)) for (kind, kk), wi in zip(Fp, wp) if kind == "chi" and kk]
    base = [kk for kk, _ in sorted(base, key=lambda kv: -kv[1])][: dfg.max_ext_bases]
    if base:
        m = min(n, int(budget[2] * GD / (len(base) * (2 * d * d + 3 * d))))
        t1, t2 = thr(len(base) * d), thr_m(len(base) * math.comb(d, 2), max(m, 1))
        Ss = set(S_l)
        b1 = [T for T in base if set(T) < Ss and len(Ss - set(T)) == 1]
        b2 = [T for T in base if set(T) < Ss and len(Ss - set(T)) == 2]
        if b1:
            out["ext1"] = dict(z=abs(v_full) / t1, N=len(base) * d, m=n)
        if b2 and m >= 32:
            vm = float(np.mean(r[:m] * chi[:m]))
            out["ext2"] = dict(z=abs(vm) / t2, N=len(base) * math.comb(d, 2), m=m)
    V = sorted(set(v for kind, kk in Fp if kind == "chi" for v in kk))
    if 2 <= len(V) <= dfg.local_max and set(S_l) <= set(V):
        out["local"] = dict(z=abs(v_full) / thr(math.comb(len(V), k)), N=math.comb(len(V), k), m=n, V=len(V))
    zs = {kk: vv["z"] for kk, vv in out.items() if isinstance(vv, dict)}
    out["best"] = max(zs, key=zs.get) if zs else None
    out["zbest"] = max(zs.values()) if zs else 0.0
    return out


_DM = []


def frozen():
    """The md5-checked frozen module (eval_dfg.load_dfg13) and a DFG with the fit's constructor arguments."""
    if not _DM:
        DM = H.E.load_dfg13(); _DM.extend([DM, DM.DFG(readout="logit")])
    return _DM


def analyse_cell(target, seed, n, T, d=30):
    DM, dfg = frozen()
    with SolveRec() as SR:
        rec = H.fit_toy_dfg("designed", target, n, seed, T=T)
    fin = rec["final"]; pi = np.asarray(rec["pi"]); pinv = np.argsort(pi)          # pinv[original i] = learner column
    per_call = split_solves(SR.sols, rec["calls"])
    LS = per_call[-1]                                                               # w_0 .. w_R of the final fit
    p = [len(w) for w in LS]; R_ = rec["rounds"]
    F, B, X, y = fin["F"], fin["B"], fin["X"], np.asarray(fin["y"], np.float64)
    fn = T[target]["fn"]; Rr = list(T[target]["relevant"])
    sup, _ = target_support(fn, Rr, d)
    chars = [(nm, S, c) for nm, S, c in sup if S]                                   # non-constant characters
    # ---- feature columns on the training rows and on the probe
    A = columns(F, B, X)
    pats, M, Zp = probe(target, Rr, d); Zl = Zp[:, pi]                              # learner coordinates of the probe
    Phi = columns(F, B, Zl)
    Cm = np.stack([np.prod(pats[:, [Rr.index(i) for i in S]], 1) for _, S, _ in chars], 1)
    yh = np.array([c for _, _, c in chars])
    phi_ls = []
    for k, w in enumerate(LS):
        fv = np.ascontiguousarray(Phi[:, :p[k]]) @ w
        phi_ls.append((fourier_on_R(fv, len(pats), M, None, Cm) / yh).tolist())
    fv_final = Phi @ fin["W"] + Zl @ fin["bg"]
    fv_final_ls = np.ascontiguousarray(Phi[:, :p[-1]]) @ LS[-1] + Zl @ fin["bg"]
    phi_final = (fourier_on_R(fv_final, len(pats), M, None, Cm) / yh).tolist()
    phi_final_ls = (fourier_on_R(fv_final_ls, len(pats), M, None, Cm) / yh).tolist()
    # same quantity on the 4096 test inputs (the estimator the fixed-n network files use: mean of f chi_S over the test set)
    Zte = rec["Zte"]; Cte = np.stack([np.prod(Zte[:, [int(pinv[i]) for i in S]], 1) for _, S, _ in chars], 1)
    phi_final_test = ((rec["value_te"] @ Cte / len(Zte)) / yh).tolist()
    # ---- what each round admitted, in original coordinates
    descs = {id(b): H.block_desc(b, pi) for b in B}
    rounds = []
    for j in range(R_):
        lo, hi_ = p[j], p[j + 1]; add = F[lo:hi_]; e = fin["info"]["log"][j]
        ch = [tuple(sorted(int(pi[i]) for i in kk)) for kind, kk in add if kind == "chi"]
        nnew = e["n_new"]
        bl = []
        for kind, kk in add:
            if kind == "sum" and kk[0] not in [b_["bid"] for b_ in bl]:
                b = B[kk[0]]
                bl.append(dict(bid=int(kk[0]), desc=H.block_desc(b, pi), support=sorted(H.block_support(b, pi)),
                               fold=bool(b.fold), product=b.other is not None, inner=b.inner is not None, mod=len(b.mod) > 0))
        nquad = sum(1 for kind, _ in add if kind == "quad")
        rounds.append(dict(round=j, s_log=e["s"], n_new=nnew, new=[list(S) for S in ch[:nnew]],
                           linear=("linear" in e["blocks"]), linear_inputs=[list(S) for S in ch[nnew:]], quad=nquad,
                           sum_blocks=bl, log_blocks=e["blocks"], p_after=hi_))
    # ---- residual replay: s check, z-scores of every target character by class, at the start of each round 0..R
    hi_flag, scale = rec["calls"][-1]["hi"], rec["calls"][-1]["scale"]
    replay = {nm: [] for nm, _, _ in chars}; s_rep = []
    Fkeys = {}
    for idx, (kind, kk) in enumerate(F):
        if kind == "chi":
            Fkeys.setdefault(tuple(kk), idx)
    for j in range(R_ + 1):
        w = LS[j]; r = y - np.ascontiguousarray(A[:, :p[j]]) @ w; s = math.sqrt(max(float(np.mean(r * r)), 1e-12))
        s_rep.append(s)
        Fp = F[:p[j]]
        for nm, S, c in chars:
            S_l = tuple(sorted(int(pinv[i]) for i in S))
            if S_l in Fkeys and Fkeys[S_l] < p[j]:
                replay[nm].append(None); continue                                 # already a feature
            o = replay_round(X, y, r, s, n, d, j, Fp, w, S_l, hi_flag, scale, dfg, DM)
            o = {kk: (dict((a, (round(b, 5) if isinstance(b, float) else b)) for a, b in vv.items()) if isinstance(vv, dict) else
                      (round(vv, 6) if isinstance(vv, float) else vv)) for kk, vv in o.items()}
            replay[nm].append(o)
    s_check = [abs(round(s_rep[j], 4) - fin["info"]["log"][j]["s"]) <= 1.5e-4 for j in range(R_)]
    # ---- explicit admission round of each target character, and how
    explicit = {}
    for nm, S, c in chars:
        S_l = tuple(sorted(int(pinv[i]) for i in S)); idx = Fkeys.get(S_l)
        if idx is None:
            explicit[nm] = None; continue
        j = max(k for k in range(R_) if p[k] <= idx)
        how = "test" if idx < p[j] + rounds[j]["n_new"] else "linear-block"
        if how == "test":
            z = replay[nm][j]["zbest"] if replay[nm][j] else None
            if z is not None and z <= 1.0:
                how = "forced"
        explicit[nm] = dict(round=j, how=how, cls=(replay[nm][j]["best"] if replay[nm][j] else None),
                            z=(replay[nm][j]["zbest"] if replay[nm][j] else None))
    # ---- stop reason at round R
    rR = y - np.ascontiguousarray(A[:, :p[-1]]) @ LS[-1]
    signs_right = bool(np.all(np.sign(y - rR) == y))
    if R_ == dfg.rounds:
        stop = "max-rounds"
    elif R_ > 0 and signs_right:
        stop = "all-training-signs-right"
    elif s_rep[-1] < 1e-6:
        stop = "exact-fit"
    else:
        stop = "nothing-passed-or-budget-or-room"
    ident = H.check_identity(rec)
    out = dict(target=target, seed=seed, n=n, d=d, err=rec["err"], flops=rec["flops"], flops_ratio=rec["flops"] / rec["gd_flops"],
               variant=rec["variant"], cv_errs=rec["cv_errs"], rounds_n=R_, size=rec["size"], train_err=rec["train_err"],
               pi=[int(v) for v in pi], stop=stop, s_replay=[round(v, 6) for v in s_rep], s_check=s_check,
               chars=[nm for nm, _, _ in chars], yhat=[c for _, _, c in chars], deg=[len(S) for _, S, _ in chars],
               phi_ls=phi_ls, phi_final=phi_final, phi_final_ls=phi_final_ls, phi_final_test=phi_final_test, probe_M=M,
               rounds=rounds, explicit=explicit, replay=replay, identity=ident, p=p,
               terms=[dict(kind=t["kind"], desc=t["desc"], share=round(t["share"], 4), S=t.get("S"))
                      for t in H._clean(rec["terms"])[:12]])
    return out


def main():
    a = sys.argv[1:]; opt = {k[2:].split("=", 1)[0]: k.split("=", 1)[1] for k in a if k.startswith("--")}
    fns = [x for x in a if not x.startswith("--")] or TARGETS
    seeds = [int(s) for s in opt.get("seeds", "0,1,2").split(",")]
    ns = [int(v) for v in opt.get("ns", ",".join(map(str, NS))).split(",")]
    T = H.targets("designed")
    for fn in fns:
        for seed in seeds:
            for n in ns:
                path = os.path.join(OUT, f"{fn}__n{n}__s{seed}.json.gz")
                if os.path.exists(path):
                    continue
                t0 = time.process_time()
                o = analyse_cell(fn, seed, n, T); o["cpu_seconds"] = time.process_time() - t0
                with gzip.open(path + ".tmp", "wt") as fh:
                    json.dump(o, fh)
                os.replace(path + ".tmp", path)
                ex = {k: (v["round"] if v else None) for k, v in o["explicit"].items()}
                print(f"{fn} s{seed} n={n}: err {o['err']:.4f} rounds {o['rounds_n']} var {o['variant']} stop {o['stop']} "
                      f"s_ok {all(o['s_check'])} id {o['identity'].get('err_equal')} cpu {o['cpu_seconds']:.1f}s", flush=True)


if __name__ == "__main__":
    main()
