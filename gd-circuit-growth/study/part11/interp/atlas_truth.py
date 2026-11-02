"""The target's own representation in DFG's dictionary, derived from its definition (study/boolfuncs.py and
part9/heldout6/suite.py), for the Part 11 structure atlas.  Descriptive bookkeeping; no learner code.

DFG's model is sign(sum_t w_t phi_t(x) + bg . x) with phi_t a Fourier character chi_S, a spectral feature
(u . x)^2 - |u|^2, or the level indicators of a sum block t(x) = sum_{i in S} s_i x_i (folded |t|, modulated chi_M * [..],
weighted t + a tau, or the joint cells of two blocks).  A target is EXACTLY representable when some short list of such
features has a linear combination whose sign is f.  For each atlas target, spec() returns:
  rel        the relevant inputs (0-indexed, original coordinates)
  family     a family label
  reps       the compact exact representations, each a dict(name, chars={S: coef} and / or blocks=[block spec], note):
             chars  a polynomial threshold representation sign(sum_S coef_S chi_S) (verified on all 2^k inputs of rel),
                    or the exact Fourier expansion when that is the representation
             blocks block specs dict(S, signs, accept (values of t), even (accept set symmetric under t -> -t, so a
                    folded block also represents it), mod (modulator inputs), inner (a, kind, inputs, signs)), all
                    needed together (products / modulated / weighted forms are recorded in `combine`)
  combine    how the blocks combine ('single', 'product', 'modulated', 'weighted', 'gate', 'mux', 'majority of 3')
  couple     relevant inputs outside every block (gate literals, multiplexer selector, parity partners)
  fourier    {S: fhat(S)} exact (2^k evaluations, k <= 22), or None (thr30); W = Fourier weight by degree
  classes    signed-symmetry classes (Part 10's rule, hooks.symmetry_classes, copied here) for the n_struct comparison
"""
import itertools, math, numpy as np

ATLAS = [  # (suite, target): 37 targets, every family of the 11 suites (seed 0 fits on the full n grid)
    ("designed", "par2"), ("designed", "par4"), ("dlheld", "par5"),
    ("designed", "stair5"), ("dlheld", "stair6"),
    ("dlheld", "mux6"), ("dlheld3", "mux11"),
    ("designed", "maj9"), ("dlheld3", "thrint"), ("dlheld", "thr30"),
    ("designed", "majpar"), ("dlheld", "majpar5"), ("designed", "parmaj"), ("dlheld", "majxor"), ("dlheld", "majmaj5"),
    ("designed", "andxor"),
    ("dlheld3", "cnf3"), ("dlheld3", "dlist8"),
    ("random", "rf06"), ("dlheld", "hrf0"),
    ("dlheld3", "sym9"), ("dlsymdev", "band11"), ("dlheld5", "h5s7"), ("dlheld4", "symand"), ("dlheld6", "h6_00"),
] + [("dlheld7", f"f7_{i:02d}") for i in range(12)]


def _closure(fn):
    return dict(zip(fn.__code__.co_freevars, [c.cell_contents for c in (fn.__closure__ or ())]))


# ------------------------------------------------------------------------------------------------ Fourier
def all_inputs(rel, d=30):
    k = len(rel); N = 1 << k
    B = (np.arange(N)[:, None] >> np.arange(k)[None, :]) & 1
    X = np.ones((N, d)); X[:, rel] = 1 - 2 * B
    return X


def fwht(a):
    a = np.array(a, dtype=np.float64); N = len(a); h = 1
    while h < N:
        a = a.reshape(-1, 2, h); a = np.stack([a[:, 0] + a[:, 1], a[:, 0] - a[:, 1]], 1).reshape(-1); h *= 2
    return a / N


def fourier(fn, rel, d=30, kmax=22, vals=None):
    """Exact Fourier coefficients {S (sorted original inputs): fhat} over the relevant inputs (bit q <-> rel[q]); vals:
    the function's values on all_inputs(rel) if already computed.  None when k > kmax."""
    rel = list(rel); k = len(rel)
    if k > kmax:
        return None
    if vals is None:
        vals = np.concatenate([fn(all_inputs(rel, d)[i:i + 65536]) for i in range(0, 1 << k, 65536)]) \
            if k > 16 else fn(all_inputs(rel, d))
    a = fwht(vals)
    nz = np.where(np.abs(a) > 1e-12)[0]
    return {tuple(sorted(rel[q] for q in range(k) if (m >> q) & 1)): float(a[m]) for m in nz}


def by_degree(F, k):
    W = np.zeros(k + 1)
    for S, v in F.items():
        W[len(S)] += v * v
    return [round(float(w), 5) for w in W]


def ptf_from_poly(pvals, rel):
    """The characters of a real polynomial given by its values on all_inputs(rel): {S: coef}."""
    a = fwht(pvals); k = len(rel)
    return {tuple(sorted(rel[q] for q in range(k) if (m >> q) & 1)): float(a[m]) for m in np.where(np.abs(a) > 1e-12)[0]}


# ------------------------------------------------------------------------------------------------ symmetry classes
def symmetry_classes(fn, rel, d=30, m=4096, seed=5):
    """part10/interp/hooks.symmetry_classes, copied: i ~ j if f is invariant under swapping x_i, x_j ('+') or under
    x_i -> -x_j, x_j -> -x_i ('-'); classes of size >= 2 with relative signs (None where only '+-' relations)."""
    X = np.random.default_rng(seed).choice([-1.0, 1.0], size=(m, d)); f0 = fn(X); rel = list(rel)
    par = {i: i for i in rel}; E = {}

    def find(i):
        while par[i] != i:
            par[i] = par[par[i]]; i = par[i]
        return i
    for a in range(len(rel)):
        for b in range(a + 1, len(rel)):
            i, j = rel[a], rel[b]; Xs = X.copy(); Xs[:, [i, j]] = X[:, [j, i]]; sym = np.array_equal(fn(Xs), f0)
            Xa = X.copy(); Xa[:, i], Xa[:, j] = -X[:, j], -X[:, i]; anti = np.array_equal(fn(Xa), f0)
            if sym or anti:
                E[(i, j)] = "+-" if sym and anti else "+" if sym else "-"; par[find(i)] = find(j)
    groups = {}
    for i in rel:
        groups.setdefault(find(i), []).append(i)
    out = []
    for g in groups.values():
        if len(g) < 2:
            continue
        sg = {g[0]: 1}; todo = [g[0]]
        while todo:
            i = todo.pop()
            for (a, b), r in E.items():
                if r == "+-" or i not in (a, b):
                    continue
                j = b if a == i else a
                if j not in sg:
                    sg[j] = sg[i] * (1 if r == "+" else -1); todo.append(j)
        out.append(dict(S=sorted(g), signs=[sg.get(i) for i in sorted(g)]))
    return out


# ------------------------------------------------------------------------------------------------ block specs
def block(S, signs, accept, even, mod=(), inner=None):
    o = sorted(zip(S, signs))
    return dict(S=[int(i) for i, _ in o], signs=[int(s) for _, s in o], accept=[int(v) for v in accept], even=bool(even),
                mod=sorted(int(i) for i in mod), inner=inner)


def _blk_node(nd):
    _, c0, m, eps, tab = nd
    Bv = np.arange(m + 1); tv = 2 * Bv - m
    return block(range(c0, c0 + m), eps, tv[np.asarray(tab)], all(tab[b] == tab[m - b] for b in range(m + 1)))


def _lit(nd):
    return int(nd[1]), int(nd[2])                                      # ('lit', col, sign)


def _inner_node(nd):
    _, c0, m, eps, tau, a, tab, off = nd
    uall = np.arange(-off, off + 1); tab = np.asarray(tab)
    even = all(tab[u + off] == tab[-u + off] for u in range(-off, off + 1))
    if tau[0] == "lit":
        c, s = _lit(tau); inn = dict(a=int(a * s), kind="lit", inputs=[c], signs=[1])
    elif tau[0] == "prod":
        (c1, s1), (c2, s2) = _lit(tau[1][0]), _lit(tau[1][1]); inn = dict(a=int(a * s1 * s2), kind="par", inputs=sorted([c1, c2]), signs=[1, 1])
    else:
        (c1, s1), (c2, s2) = _lit(tau[1][0]), _lit(tau[1][1]); inn = dict(a=int(a), kind="and", inputs=[c1, c2], signs=[s1, s2])
    return block(range(c0, c0 + m), eps, uall[tab], even, inner=inn)


def _lits_of(nd):
    if nd[0] == "lit":
        return [int(nd[1])]
    out = []
    for c in nd[1]:
        out += _lits_of(c)
    return out


def family_spec(fn, desc):
    """heldout6-family targets (dlheld6, dlfamdev, dlheld7): read the expression tree from the target's closure."""
    nd = _closure(fn)["node"]; t = nd[0]
    if t == "blk":
        return dict(family="pure signed-sum", combine="single", blocks=[_blk_node(nd)], couple=[])
    if t == "inner":
        return dict(family="weighted sum", combine="weighted", blocks=[_inner_node(nd)], couple=[])
    if t == "prod":
        b = _blk_node(nd[1][0]); P = [_lit(c)[0] for c in nd[1][1:]]; b["mod"] = sorted(P)
        return dict(family="signed sum x parity", combine="modulated", blocks=[b], couple=sorted(P))
    if t == "mux":
        return dict(family="multiplexer of two sums", combine="mux", blocks=[_blk_node(nd[2]), _blk_node(nd[3])],
                    couple=[_lit(nd[1])[0]])
    if t in ("and", "or", "xor", "maj") and nd[1][0][0] == "blk":
        kids = nd[1]
        if all(c[0] == "blk" for c in kids):
            return dict(family=f"two sums ({t.upper()})", combine="product" if t == "xor" else "additive (sign readout)",
                        blocks=[_blk_node(c) for c in kids], couple=[])
        g = []
        for c in kids[1:]:
            g += _lits_of(c)
        return dict(family=f"signed sum + gate ({t.upper()})", combine="gate (additive + gate characters)",
                    blocks=[_blk_node(kids[0])], couple=sorted(g))
    if t == "dl":
        return dict(family="decision list (C3)", combine=None, blocks=[], couple=[], dl=nd)
    if t == "or" and all(c[0] == "and" and all(l[0] == "lit" for l in c[1]) for c in nd[1]):
        return dict(family="DNF (C2)", combine=None, blocks=[], couple=[], dnf=nd)
    return dict(family="read-once formula (C1)", combine=None, blocks=[], couple=[])


def dnf_ptf(nd, rel, X):
    """OR of t AND-terms T_i: f = sign(sum_i T_i + t - 1), T_i = 2 prod_j (1 + l_j)/2 - 1 (characters inside each term)."""
    terms = nd[1]; p = np.full(len(X), float(len(terms) - 1))
    for tm in terms:
        pr = np.ones(len(X))
        for l in tm[1]:
            pr = pr * (1 + l[2] * X[:, l[1]]) / 2
        p += 2 * pr - 1
    return p


def dl_ptf(rules, default, X, lits=None):
    """Decision list (rules = [(literal list, out)], default): f = sign(sum_i o_i 2^(L+1-i) [rule i] + o_default)."""
    L = len(rules); p = np.full(len(X), float(default))
    for i, (ls, o) in enumerate(rules):
        pr = np.ones(len(X))
        for col, sg in ls:
            pr = pr * (1 + sg * X[:, col]) / 2
        p += o * 2.0 ** (L - i) * pr
    return p


# ------------------------------------------------------------------------------------------------ hand specs
def hand_spec(name, t):
    rel = list(t["relevant"]); R = lambda *a: list(a)
    P = lambda *S: {tuple(S): 1.0}
    if name in ("par2", "par4", "par5"):
        return dict(family="parity", reps=[dict(name="character", chars={tuple(rel): 1.0})])
    if name == "stair5":
        return dict(family="staircase", reps=[dict(name="PTF sign(x1 + x1x2 + ... + x1..x5)",
                                                   chars={tuple(range(j + 1)): 1.0 for j in range(5)})])
    if name == "stair6":
        return dict(family="staircase", reps=[dict(name="PTF sign(x1 + x1x2 + ... + x1..x6 + 1/2)",
                                                   chars={**{(): 0.5}, **{tuple(range(j + 1)): 1.0 for j in range(6)}})])
    if name == "maj9":
        return dict(family="majority", combine="single",
                    reps=[dict(name="block (x1+...+x9), t > 0", blocks=[block(range(9), [1] * 9, [1, 3, 5, 7, 9], False)]),
                          dict(name="PTF sign(x1 + ... + x9)", chars={(i,): 1.0 for i in range(9)})])
    if name == "thrint":
        w = [3, 2, 2, 1, 1, 1, 1, 1, 1]
        return dict(family="integer-weight halfspace", combine=None,
                    reps=[dict(name="PTF sign(3x1 + 2x2 + 2x3 + x4 + ... + x9)", chars={(i,): float(w[i]) for i in range(9)})])
    if name == "thr30":
        wv = np.random.default_rng(4242).standard_normal(30)                       # make_dl_heldout_suite(seed=4242)
        return dict(family="Gaussian halfspace (30 inputs)", combine=None,
                    reps=[dict(name="PTF sign(w . x), Gaussian w", chars={(i,): float(wv[i]) for i in range(30)})])
    if name == "majpar":
        return dict(family="majority of parities", reps=[dict(name="PTF sign(x1x2 + x3x4 + x5x6)",
                                                              chars={(0, 1): 1.0, (2, 3): 1.0, (4, 5): 1.0})])
    if name == "majpar5":
        return dict(family="majority of parities", reps=[dict(name="PTF sign(x1x2 + ... + x9x10)",
                                                              chars={(2 * i, 2 * i + 1): 1.0 for i in range(5)})])
    if name in ("parmaj", "majxor"):
        h = 3 if name == "parmaj" else 5
        return dict(family="parity of majorities", combine="product",
                    reps=[dict(name=f"product block (x1+..+x{h}) x (x{h + 1}+..+x{2 * h})",
                               blocks=[block(range(h), [1] * h, list(range(-h, h + 1, 2)), False),
                                       block(range(h, 2 * h), [1] * h, list(range(-h, h + 1, 2)), False)]),
                          dict(name=f"PTF sign((x1+..+x{h})(x{h + 1}+..+x{2 * h})): {h * h} degree-2 characters",
                               chars={(i, j): 1.0 for i in range(h) for j in range(h, 2 * h)}),
                          dict(name="two spectral features: sign((u+.x)^2 - (u-.x)^2), u+- = 1_A +- 1_B", quad=True),
                          dict(name=f"two folded blocks |t_A + t_B|, |t_A - t_B| over all {2 * h} inputs: "
                                    "sign(|t_A+t_B|^2 - |t_A-t_B|^2) = sign(t_A t_B)",
                               blocks=[block(range(2 * h), [1] * (2 * h), [], True),
                                       block(range(2 * h), [1] * h + [-1] * h, [], True)], couple=[])])
    if name == "majmaj5":
        return dict(family="majority of majorities", combine="additive (sign readout)",
                    reps=[dict(name="three additive 5-input blocks: sign(g1(t1) + g2(t2) + g3(t3)), g = sign",
                               blocks=[block(range(5 * j, 5 * j + 5), [1] * 5, [1, 3, 5], False) for j in range(3)])])
    if name == "andxor":
        return dict(family="AND of parities", reps=[dict(name="Fourier: (x1x2 + x3x4 + x1x2x3x4 - 1)/2",
                                                         chars={(0, 1): 0.5, (2, 3): 0.5, (0, 1, 2, 3): 0.5, (): -0.5})])
    if name in ("mux6", "mux11"):
        a = 2 if name == "mux6" else 3                                   # address bits x1..xa, data x(a+1)..
        bl = []
        for idx in range(2 ** a):                                         # data bit a + idx is read when the address
            pat = [1 if (idx >> (a - 1 - q)) & 1 else -1 for q in range(a)]   # bits have these signs (np.choose index)
            bl.append(block(range(a), pat, [a], False, mod=[a + idx]))
        return dict(family="multiplexer (address + data)",
                    reps=[dict(name="Fourier expansion", fourier=True),
                          dict(name=f"{2 ** a} address blocks, each modulated by its data bit: sum_d x_d [address = a_d]",
                               blocks=bl, couple=[])])
    if name == "cnf3":
        cl = [[(0, 1), (1, 1), (2, 1)], [(3, -1), (4, 1), (5, 1)], [(6, 1), (7, -1), (8, 1)]]

        def p(X):
            out = np.full(len(X), -2.0)
            for c in cl:
                pr = np.ones(len(X))
                for col, sg in c:
                    pr = pr * (1 - sg * X[:, col]) / 2
                out += 1 - 2 * pr
            return out
        return dict(family="CNF (3 clauses of 3 literals)", ptf=p,
                    reps=[dict(name="PTF sign(c1 + c2 + c3 - 2), clause characters (degree <= 3, within a clause)"),
                          dict(name="one additive block per clause (the clause is false iff t = -3), sign readout",
                               blocks=[block([q for q, _ in c], [g for _, g in c], [-1, 1, 3], False) for c in cl], couple=[])])
    if name == "dlist8":
        vals = [-1, 1, 1, -1, 1, -1, -1, 1]
        rules = [([(i, 1 if i % 3 != 1 else -1)], vals[i]) for i in range(8)]
        return dict(family="decision list (8 single literals)", ptf=lambda X: dl_ptf(rules, 1, X),
                    reps=[dict(name="PTF: a halfspace in the 8 literals with weights halving")])
    if name in ("rf06", "hrf0"):
        return dict(family="random formula", reps=[dict(name="Fourier expansion", fourier=True)])
    if name == "sym9":
        return dict(family="symmetric (even)", combine="single",
                    reps=[dict(name="block |x1+...+x9| <= 1", blocks=[block(range(9), [1] * 9, [-1, 1], True)])])
    if name == "band11":
        return dict(family="symmetric (even)", combine="single",
                    reps=[dict(name="block |x1+...+x11| in {3, 5}", blocks=[block(range(11), [1] * 11, [-5, -3, 3, 5], True)])])
    if name == "symand":
        return dict(family="signed sum + gate (AND with OR(x7,x8))", combine="gate (additive + gate characters)", couple=[6, 7],
                    reps=[dict(name="block |x1+...+x6| <= 2, gated by OR(x7, x8)",
                               blocks=[block(range(6), [1] * 6, [-2, 0, 2], True)])])
    raise KeyError(name)


def h5_spec(name, fn):
    dv = fn.__defaults__
    if name.startswith("h5t"):
        k, sg, T, w = dv
        inn = dict(a=int(w), kind="par" if len(T) == 2 else "chi", inputs=sorted(int(i) for i in T), signs=[1] * len(T))
        return dict(family="weighted sum (threshold)", combine="weighted",
                    reps=[dict(name="weighted block", blocks=[block(range(k), sg, [], False, inner=inn)])])
    if len(dv) == 3 and isinstance(dv[0], (int, np.integer)):              # mode 'none': (k, sg, A)
        k, sg, A = dv
        even = sorted(int(a) for a in A) == sorted(-int(a) for a in A)
        return dict(family="pure signed-sum (arbitrary accept set)", combine="single",
                    reps=[dict(name=f"block, accept set {sorted(int(a) for a in A)}", blocks=[block(range(k), sg, A, even)])])
    raise KeyError(name)


def spec(suite, name, t, d=30):
    """Full spec for one atlas target (t = the targets-dict entry)."""
    fn, rel = t["fn"], list(t["relevant"])
    if suite in ("dlheld6", "dlfamdev", "dlheld7"):
        fs = family_spec(fn, t["desc"]); reps = []
        if fs["blocks"]:
            reps.append(dict(name="blocks (" + fs["combine"] + ")", blocks=fs["blocks"]))
        sp = dict(family=fs["family"], combine=fs["combine"], couple=fs["couple"], reps=reps)
        if "dnf" in fs:
            sp["ptf"] = lambda X, nd=fs["dnf"]: dnf_ptf(nd, rel, X)
            sp["reps"].append(dict(name="PTF sign(sum of terms + t - 1), term characters"))
            tb = [block([l[1] for l in tm[1]], [l[2] for l in tm[1]], [len(tm[1])], False) for tm in fs["dnf"][1] if len(tm[1]) >= 2]
            sp["reps"].append(dict(name="one additive block per AND term (all its literals true: t = m), sign readout",
                                   blocks=tb, couple=[]))
        if "dl" in fs:
            nd = fs["dl"]; rules = [([_lit(l) for l in ls], o) for ls, o in nd[1]]
            sp["ptf"] = lambda X, rules=rules, dft=nd[2]: dl_ptf(rules, dft, X)
            sp["reps"].append(dict(name="PTF sign(sum_i o_i 2^(L+1-i) [rule i] + default), rule characters (degree <= 2)"))
        if fs["family"].startswith("read-once"):
            sp["reps"].append(dict(name="Fourier expansion", fourier=True))
            if name == "f7_06":                                          # OR(T1, T2), T1 = AND of 5 literals
                X3 = all_inputs([5, 6, 7], d)
                T2 = np.where(((-X3[:, 5] > 0) | (X3[:, 6] > 0)) & (X3[:, 7] > 0), 1.0, -1.0)
                ch = {S: c for S, c in ptf_from_poly(T2, [5, 6, 7]).items() if S}
                sp["reps"].append(dict(name="sign(T1 + T2 + 1): additive block on the AND of 5 literals (t = 5) + the "
                                            "characters of T2 = AND(OR(-x6,x7),x8)",
                                       blocks=[block(range(5), [-1, 1, -1, 1, -1], [5], False)], chars=ch, couple=[5, 6, 7]))
        if fs["family"].startswith("pure") and fs["blocks"][0]["accept"]:
            b = fs["blocks"][0]; m = len(b["S"])
            acc = set(b["accept"]); tv = list(range(-m, m + 1, 2))
            # threshold accept sets are halfspaces: sign(+-(t - c)) is also a degree-1 PTF
            ins = [v in acc for v in tv]
            if ins == sorted(ins) or ins == sorted(ins, reverse=True):
                c = [v for v in tv if (v in acc) != ins[0]][0]
                sgn = 1.0 if not ins[0] else -1.0
                sp["reps"].append(dict(name=f"PTF sign({'+' if sgn > 0 else '-'}(t - {c - 1}))",
                                       chars={**{(i,): sgn * s for i, s in zip(b["S"], b["signs"])}, **{(): -sgn * (c - 1)}}))
    elif suite == "dlheld5":
        sp = h5_spec(name, fn)
    else:
        sp = hand_spec(name, t)
    sp.setdefault("combine", None); sp.setdefault("couple", [])
    sp["rel"] = rel; sp["k"] = len(rel); sp["desc"] = t["desc"]
    sp["classes"] = symmetry_classes(fn, rel, d)
    # Fourier table and verification of every representation
    if len(rel) <= 22:
        X = all_inputs(rel, d)
        vals = np.concatenate([fn(X[i:i + 65536]) for i in range(0, len(X), 65536)])
        sp["fourier"] = fourier(fn, rel, d, vals=vals); sp["W"] = by_degree(sp["fourier"], len(rel))
    else:
        X, vals = None, None; sp["fourier"] = None; sp["W"] = None
    if "ptf" in sp:
        pv = sp["ptf"](X); assert np.all(np.sign(pv) == vals) and np.all(pv != 0), name
        sp["reps"][-1]["chars"] = ptf_from_poly(pv, rel)
        del sp["ptf"]
    # every signed-symmetry class of size >= 3 is a block f depends on only through its signed sum (a target that is
    # symmetric in those signed inputs is a function of their sum and of the other inputs): an AUXILIARY representation,
    # used to recognise block terms on such classes as target terms, never counted as 'complete' (the other inputs may
    # enter in any way)
    have = {(tuple(b["S"]), tuple(v * b["signs"][0] for v in b["signs"])) for r in sp["reps"] for b in r.get("blocks", [])}
    aux = []
    for c in sp["classes"]:
        if X is None or len(c["S"]) < 3 or any(v is None for v in c["signs"]):   # (classes found on samples only are
            continue                                                             #  not used when f cannot be enumerated)
        key = (tuple(c["S"]), tuple(v * c["signs"][0] for v in c["signs"]))
        if key in have:
            continue
        ev = None
        if X is not None:
            Xf = X.copy(); Xf[:, c["S"]] = -Xf[:, c["S"]]
            ev = bool(np.array_equal(np.concatenate([fn(Xf[i:i + 65536]) for i in range(0, len(Xf), 65536)]), vals))
        aux.append(block(c["S"], c["signs"], [], bool(ev)))
    if aux:
        cov = sorted(set(rel) - {i for b in aux for i in b["S"]})
        sp["reps"].append(dict(name="symmetry-class blocks (auxiliary: f is a function of each class's signed sum and the "
                                    "other inputs)", blocks=aux, couple=cov, aux=True))
    for r in sp["reps"]:
        if r.get("fourier"):
            r["chars"] = dict(sp["fourier"])
        ok = []
        if "chars" in r and X is not None and "blocks" not in r:              # verify sign(sum coef chi_S) == f
            pv = sum(c * (np.prod(X[:, list(S)], 1) if S else 1.0) for S, c in r["chars"].items())
            ok.append(bool(np.all(np.sign(pv) == vals) and np.all(pv != 0)))
        if "blocks" in r and X is not None:
            ok.append(verify_blocks(r["blocks"], sp["combine"], r.get("couple", sp["couple"]), X, vals))
        if ok:
            r["verified"] = all(ok)
    return sp


def verify_blocks(blocks, combine, couple, X, vals):
    """The block representation is exact if f is a function of the blocks' statistics (|t| for a block marked even, so
    that a folded block suffices) and of the coupling inputs: no two inputs with the same (t_1, ..., couple, modulator)
    values have different labels."""
    keys = []
    for b in blocks:
        t = X[:, b["S"]] @ np.asarray(b["signs"], float)
        if b["inner"] is not None:
            inn = b["inner"]
            if inn["kind"] == "lit":
                tau = X[:, inn["inputs"][0]]
            elif inn["kind"] == "par":
                tau = X[:, inn["inputs"][0]] * X[:, inn["inputs"][1]]
            elif inn["kind"] == "and":
                tau = np.where((inn["signs"][0] * X[:, inn["inputs"][0]] > 0) & (inn["signs"][1] * X[:, inn["inputs"][1]] > 0), 1.0, -1.0)
            else:
                tau = np.prod(X[:, inn["inputs"]], 1)
            t = t + inn["a"] * tau
        keys.append(np.abs(t) if b["even"] else t)                         # an even block: f depends on |t| only
        if b["mod"]:
            keys.append(np.prod(X[:, b["mod"]], 1))
    for c in couple:
        keys.append(X[:, c])
    K = np.stack(keys, 1); seen = {}
    for row, v in zip(map(tuple, K), vals):
        if seen.setdefault(row, v) != v:
            return False
    return True
