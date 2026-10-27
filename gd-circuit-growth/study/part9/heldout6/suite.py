"""Held-out suite 6: 12 Boolean targets on {-1,+1}^30 drawn from the family
stated in FAMILY.md (9 symmetric / signed-sum targets in strata S1-S4 and
3 non-symmetric controls C1-C3) with one fixed seed.

Conventions: +1 = true; a literal is x_j or -x_j (-x_j = NOT x_j); a signed
block on columns c0..c0+m-1 with signs eps has signed sum s = sum eps_i x_i and
count B = #{i : eps_i x_i = +1} = (s + m) / 2.  Every target uses columns
0..k-1 only.  The only rejection is on balance: P(f = +1) must lie in
[0.25, 0.75], computed exactly by enumerating the 2^k relevant assignments.
"""
import numpy as np

SEED = 52817

_STRATA = ["S1"] * 3 + ["S2"] * 2 + ["S3"] * 2 + ["S4"] * 2 + ["C1", "C2", "C3"]


# ----------------------------------------------------------------------------
# +-1 helpers (+1 = true)

def _pm(b):
    return np.where(b, 1.0, -1.0)


def _AND(*a):
    out = a[0] > 0
    for v in a[1:]:
        out = out & (v > 0)
    return _pm(out)


def _OR(*a):
    out = a[0] > 0
    for v in a[1:]:
        out = out | (v > 0)
    return _pm(out)


def _XOR(a, b):
    # logical XOR of two +-1 truth values: true iff exactly one is true
    return -a * b


def _MAJ(*a):
    return _pm(np.sum(a, axis=0) > 0)  # odd number of inputs


# ----------------------------------------------------------------------------
# expression trees and their evaluation

def _ev(nd, x):
    t = nd[0]
    if t == "lit":
        return nd[2] * x[:, nd[1]]
    if t == "blk":
        _, c0, m, eps, tab = nd
        B = ((x[:, c0:c0 + m] * eps) > 0).sum(1)
        return _pm(tab[B])
    if t == "inner":
        _, c0, m, eps, tau, a, tab, off = nd
        B = ((x[:, c0:c0 + m] * eps) > 0).sum(1)
        u = 2 * B - m + a * np.rint(_ev(tau, x)).astype(np.int64)
        return _pm(tab[u + off])
    if t == "and":
        return _AND(*[_ev(c, x) for c in nd[1]])
    if t == "or":
        return _OR(*[_ev(c, x) for c in nd[1]])
    if t == "xor":
        return _XOR(_ev(nd[1][0], x), _ev(nd[1][1], x))
    if t == "maj":
        return _MAJ(*[_ev(c, x) for c in nd[1]])
    if t == "prod":
        out = np.ones(x.shape[0])
        for c in nd[1]:
            out = out * _ev(c, x)
        return out
    if t == "mux":
        return np.where(_ev(nd[1], x) > 0, _ev(nd[2], x), _ev(nd[3], x))
    if t == "dl":
        _, rules, default = nd
        out = np.full(x.shape[0], float(default))
        for lits, o in reversed(rules):
            out = np.where(_AND(*[_ev(l, x) for l in lits]) > 0, float(o), out)
        return out
    raise ValueError(t)


def _mkfn(node):
    def fn(x):
        return _ev(node, np.asarray(x))
    return fn


def _all_inputs(k, d):
    X = np.ones((2 ** k, d))
    X[:, :k] = ((np.arange(2 ** k)[:, None] >> np.arange(k)) & 1) * 2.0 - 1.0
    return X


def _exact_balance(node, k, d):
    return float((_ev(node, _all_inputs(k, d)) > 0).mean())


# ----------------------------------------------------------------------------
# primitive draws

def _signs(rng, m):
    if rng.integers(2) == 0:
        return np.ones(m)
    return np.where(rng.integers(2, size=m) == 1, 1.0, -1.0)


def _lit(rng, col):
    sg = 1.0 if rng.integers(2) == 1 else -1.0
    return ("lit", int(col), sg), ("" if sg > 0 else "-") + f"x{col + 1}"


def _sum_str(c0, m, eps):
    if np.all(eps > 0):
        return f"x{c0 + 1}+...+x{c0 + m}"
    out = []
    for i in range(m):
        nm = f"x{c0 + i + 1}"
        out.append(("" if eps[i] > 0 else "-") + nm if i == 0 else ("+" if eps[i] > 0 else "-") + nm)
    return "".join(out)


def _fmt_set(vals):
    return "{" + ",".join(str(int(v)) for v in vals) + "}"


def _accept(rng, m, sym):
    """ACCEPT(m): non-constant accept set on the count B in {0..m} of a block."""
    Bv = np.arange(m + 1)
    sv = 2 * Bv - m
    typ = int(rng.integers(5))
    if typ == 0:  # threshold
        if rng.integers(2) == 0:
            t = int(rng.integers(1, m + 1))
            tab, d = Bv >= t, f"[{sym} >= {2 * t - m}]"
        else:
            t = int(rng.integers(0, m))
            tab, d = Bv <= t, f"[{sym} <= {2 * t - m}]"
    elif typ == 1:  # centered band
        ws = np.arange(m % 2, m - 1, 2)
        w = int(ws[rng.integers(len(ws))])
        if rng.integers(2) == 0:
            tab, d = np.abs(sv) <= w, f"[|{sym}| <= {w}]"
        else:
            tab, d = np.abs(sv) > w, f"[|{sym}| > {w}]"
    elif typ == 2:  # interval
        pairs = [(lo, hi) for lo in range(m + 1) for hi in range(lo, m + 1) if (lo, hi) != (0, m)]
        lo, hi = pairs[int(rng.integers(len(pairs)))]
        tab = (Bv >= lo) & (Bv <= hi)
        d = f"[{sym} == {2 * lo - m}]" if lo == hi else f"[{2 * lo - m} <= {sym} <= {2 * hi - m}]"
    elif typ == 3:  # modular on the count
        q = int(rng.integers(3, 5))
        r = int(rng.integers(q))
        if rng.integers(2) == 0:
            tab, d = Bv % q == r, f"[(({sym}+{m})/2) mod {q} == {r}]"
        else:
            tab, d = Bv % q != r, f"[(({sym}+{m})/2) mod {q} != {r}]"
    else:  # arbitrary non-constant symmetric
        code = int(rng.integers(1, 2 ** (m + 1) - 1))
        tab = ((code >> Bv) & 1).astype(bool)
        d = f"[{sym} in {_fmt_set(sv[tab])}]"
    return np.asarray(tab, dtype=bool), d


def _block(rng, c0, m, sym):
    eps = _signs(rng, m)
    tab, gd = _accept(rng, m, sym)
    return ("blk", int(c0), int(m), eps, tab), gd, f"{sym} = {_sum_str(c0, m, eps)}"


# ----------------------------------------------------------------------------
# strata

def _draw_S1(rng):
    m = int(rng.integers(5, 15))
    node, gd, sd = _block(rng, 0, m, "s")
    return node, m, f"{gd}, {sd}", "S1 pure"


def _draw_S2(rng):
    p = int(rng.integers(1, 4))
    m = int(rng.integers(5, 15 - p))
    blk, gd, sd = _block(rng, 0, m, "s")
    par = [("lit", m + j, 1.0) for j in range(p)]
    node = ("prod", [blk] + par)
    pd = " * ".join(f"x{m + j + 1}" for j in range(p))
    return node, m + p, f"{gd} * {pd}, {sd}", f"S2 sym*parity(p={p})"


def _draw_S3(rng):
    form = int(rng.integers(3))
    if form == 0:  # OP(g(s), h)
        q = int(rng.integers(1, 3))
        m = int(rng.integers(5, 15 - q))
        blk, gd, sd = _block(rng, 0, m, "s")
        if q == 1:
            h, hd = _lit(rng, m)
        else:
            l1, n1 = _lit(rng, m)
            l2, n2 = _lit(rng, m + 1)
            if rng.integers(2) == 0:
                h, hd = ("and", [l1, l2]), f"AND({n1},{n2})"
            else:
                h, hd = ("or", [l1, l2]), f"OR({n1},{n2})"
        if rng.integers(2) == 0:
            node, op = ("and", [blk, h]), "AND"
        else:
            node, op = ("or", [blk, h]), "OR"
        return node, m + q, f"{op}({gd}, {hd}), {sd}", f"S3a gate {op}"
    if form == 1:  # MAJ(g(s), l1, l2)
        m = int(rng.integers(5, 13))
        blk, gd, sd = _block(rng, 0, m, "s")
        l1, n1 = _lit(rng, m)
        l2, n2 = _lit(rng, m + 1)
        return ("maj", [blk, l1, l2]), m + 2, f"MAJ({gd}, {n1}, {n2}), {sd}", "S3b majority gate"
    # mux between two blocks
    m1 = int(rng.integers(4, 7))
    m2 = int(rng.integers(4, 7))
    b1, g1, s1 = _block(rng, 0, m1, "s1")
    b2, g2, s2 = _block(rng, m1, m2, "s2")
    sel, nsel = _lit(rng, m1 + m2)
    node = ("mux", sel, b1, b2)
    return node, m1 + m2 + 1, f"{nsel} ? {g1} : {g2}, {s1}, {s2}", "S3c multiplexer"


def _draw_S4(rng):
    form = int(rng.integers(2))
    if form == 0:  # A(s + a*tau)
        tt = int(rng.integers(3))
        r = 1 if tt == 0 else 2
        a = int(rng.integers(2, 4))
        m = int(rng.integers(5, 15 - r))
        eps = _signs(rng, m)
        if tt == 0:
            tau, td = _lit(rng, m)
            td = f"({td})"
        elif tt == 1:
            l1, n1 = _lit(rng, m)
            l2, n2 = _lit(rng, m + 1)
            tau, td = ("prod", [l1, l2]), f"({n1})*({n2})"
        else:
            l1, n1 = _lit(rng, m)
            l2, n2 = _lit(rng, m + 1)
            tau, td = ("and", [l1, l2]), f"AND({n1},{n2})"
        svals = np.arange(-m, m + 1, 2)
        U = np.unique(np.concatenate([svals + a, svals - a]))
        off = m + a
        uall = np.arange(-off, off + 1)
        if rng.integers(2) == 0:  # threshold
            if rng.integers(2) == 0:
                t = int(U[1:][rng.integers(len(U) - 1)])
                tab, ad = uall >= t, f"[u >= {t}]"
            else:
                t = int(U[:-1][rng.integers(len(U) - 1)])
                tab, ad = uall <= t, f"[u <= {t}]"
        else:  # centered band
            W = np.unique(np.abs(U))[:-1]
            w = int(W[rng.integers(len(W))])
            if rng.integers(2) == 0:
                tab, ad = np.abs(uall) <= w, f"[|u| <= {w}]"
            else:
                tab, ad = np.abs(uall) > w, f"[|u| > {w}]"
        node = ("inner", 0, m, eps, tau, a, np.asarray(tab, dtype=bool), off)
        kind = ["literal", "parity2", "AND2"][tt]
        return (node, m + r, f"{ad}, u = s + {a}*{td}, s = {_sum_str(0, m, eps)}",
                f"S4a inner {kind}, a={a}")
    # OP(g1(s1), g2(s2))
    m1 = int(rng.integers(4, 8))
    m2 = int(rng.integers(4, 8))
    b1, g1, s1 = _block(rng, 0, m1, "s1")
    b2, g2, s2 = _block(rng, m1, m2, "s2")
    op = int(rng.integers(3))
    opn = ["XOR", "AND", "OR"][op]
    node = (["xor", "and", "or"][op], [b1, b2])
    return node, m1 + m2, f"{opn}({g1}, {g2}), {s1}, {s2}", f"S4b two sums {opn}"


def _draw_C1(rng):
    k = int(rng.integers(5, 11))

    def build(cols):
        if len(cols) == 1:
            return _lit(rng, cols[0])
        sp = int(rng.integers(1, len(cols)))
        g = int(rng.integers(2))
        L, Ld = build(cols[:sp])
        R, Rd = build(cols[sp:])
        return (("and", [L, R]), f"AND({Ld},{Rd})") if g == 0 else (("or", [L, R]), f"OR({Ld},{Rd})")

    node, d = build(list(range(k)))
    return node, k, d, "C1 read-once formula"


def _draw_C2(rng):
    k = int(rng.integers(5, 11))
    t = int(rng.integers(2, min(4, k // 2) + 1))
    perm = rng.permutation(k)
    sizes = 2 + np.bincount(rng.integers(t, size=k - 2 * t), minlength=t)
    cuts = np.concatenate([[0], np.cumsum(sizes)])
    terms, tds = [], []
    for j in range(t):
        core = [int(v) for v in perm[cuts[j]:cuts[j + 1]]]
        lits = [_lit(rng, v) for v in core]
        if rng.integers(2) == 1:
            outside = sorted(set(range(k)) - set(core))
            v = outside[int(rng.integers(len(outside)))]
            lits.append(_lit(rng, v))
        lits.sort(key=lambda ln: ln[0][1])
        terms.append(("and", [l for l, _ in lits]))
        tds.append("AND(" + ",".join(n for _, n in lits) + ")")
    return ("or", terms), k, "OR(" + ", ".join(tds) + ")", f"C2 DNF t={t}"


def _draw_C3(rng):
    k = int(rng.integers(5, 11))
    perm = [int(v) for v in rng.permutation(k)]
    rules, parts, i = [], [], 0
    while i < k:
        c = int(rng.integers(1, 3))
        chunk = perm[i:i + c]
        i += c
        lits = [_lit(rng, v) for v in chunk]
        o = 1 if rng.integers(2) == 1 else -1
        rules.append(([l for l, _ in lits], o))
        cd = lits[0][1] if len(lits) == 1 else "AND(" + ",".join(n for _, n in lits) + ")"
        parts.append(f"{cd} -> {o:+d}")
    default = -rules[-1][1]
    d = "if " + "; elif ".join(parts) + f"; else {default:+d}"
    return ("dl", rules, default), k, d, f"C3 decision list L={len(rules)}"


_DRAW = {"S1": _draw_S1, "S2": _draw_S2, "S3": _draw_S3, "S4": _draw_S4,
         "C1": _draw_C1, "C2": _draw_C2, "C3": _draw_C3}


# ----------------------------------------------------------------------------
# suite

def _generate(d=30, seed=SEED):
    rng = np.random.default_rng(seed)
    order = [_STRATA[i] for i in rng.permutation(len(_STRATA))]
    S, log = {}, []
    for idx, stratum in enumerate(order):
        redraws = 0
        while True:
            node, k, desc, form = _DRAW[stratum](rng)
            assert 5 <= k <= 14 and k <= d
            p = _exact_balance(node, k, d)
            if 0.25 <= p <= 0.75:
                break
            redraws += 1
        name = f"h6_{idx:02d}"
        S[name] = dict(fn=_mkfn(node), relevant=list(range(k)), desc=desc)
        log.append(dict(name=name, stratum=stratum, form=form, k=k, balance=p, redraws=redraws))
    return S, log


def make_dl_heldout6_suite(d=30, seed=SEED):
    S, _ = _generate(d, seed)
    return S


def heldout6_draw_log(d=30, seed=SEED):
    """Per-target stratum, form, k, exact P(f=+1) and number of balance redraws."""
    return _generate(d, seed)[1]
