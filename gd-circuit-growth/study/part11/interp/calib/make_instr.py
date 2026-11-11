"""Build dfg13_instr.py: the frozen DFG v1.3 (part10/hyb_portfolio3/dfg13.py, md5 69cabe5c...) with instrumentation
lines ADDED (calls into calib_rec.REC, which only read) and no line changed or removed.  Run once; calib.py re-checks the
result (difflib: every difference is an inserted line that is the import of the recorder or a call `_P.<hook>(...)`).

usage: python make_instr.py
"""
import os, hashlib

HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
SRC = os.path.join(STUDY, "part10", "hyb_portfolio3", "dfg13.py"); MD5 = "69cabe5c50345cb24079198ed52b562f"
DST = os.path.join(HERE, "dfg13_instr.py")

# (anchor line exactly as in dfg13.py incl. indentation, occurrence (0-based), 'before' | 'after', inserted line)
INS = [
    ("from harness import gd_flops", 0, "after", "from calib_rec import REC as _P"),
    ("        info = dict(rounds=0, log=[], blocks=[])", 0, "after", "        _P.start(fl, n, d, force, hi, scale, GD)"),
    ("        w, r = lsfit()", 0, "before", '        _P.enter("ls")'),
    ("        for rnd in range(self.rounds):", 0, "after", '            _P.round_start(rnd); _P.enter("misc")'),
    ("            if fl[0] > 0.75 * GD:                                        # hard cap: stay within one network run", 0,
     "before", '            _P.stage("fitcheck_ok", s)'),
    ('            if self.noise == "label":                                   # ablation: noise taken as that of the labels', 0,
     "before", '            _P.stage("budget_ok")'),
    ("            def offer(S, v, t):", 0, "after", "                _P.offer(S, v, t, have)"),
    ("            K = self.K if rnd == 0 else self.K_later", 0, "before", '            _P.enter("g1")'),
    ("            M = (X * r[:, None]).T @ X / n; fl[0] += 2 * n * d * d + n * d", 0, "before", '            _P.enter("g2")'),
    ("            if K >= 3:", 0, "before", '            _P.enter("g3")'),
    ("                m = min(n, int(self.budget[1] * GD / (d * (2 * d * d + 2 * d))))", 0, "after", '                _P.sub("g3", m, n)'),
    ("            if K >= 4:", 0, "before", '            _P.enter("g4")'),
    ("                m = min(n, int(self.budget[0] * GD / (math.comb(d, 2) * (2 * d * d + 3 * d))))", 0, "after",
     '                _P.sub("g4", m, n)'),
    ("                for k in range(self.K + 1, self.K_hi + 1):", 0, "after", '                    _P.enter("g%d" % k)'),
    ("                    m = min(n, int(self.budget_hi * GD / (2 * N1 * N2 + m_tab_cost(d, k1, k2))))", 0, "after",
     '                    _P.sub("g%d" % k, m, n)'),
    ("                    t = thr_m(math.comb(d, k), m)", 0, "after", "                    _P.hi_max(k, G, T1, T2, t)"),
    ('            base = [(k, abs(wi)) for (kind, k), wi in zip(feats, w) if kind == "chi" and k]', 0, "before",
     '            _P.enter("ext1")'),
    ("                m = min(n, int(self.budget[2] * GD / (len(base) * (2 * d * d + 3 * d))))", 0, "after",
     '                _P.sub("ext2", m, n)'),
    ("                for S in base:", 0, "after", '                    _P.enter("ext1")'),
    ("                    e1 = X.T @ rs / n; fl[0] += 2 * n * d", 0, "after", "                    _P.ext1(e1, S, t1, have)"),
    ("                    E2 = np.triu((Xm * rs[:m, None]).T @ Xm / m, 1); fl[0] += 2 * m * d * d + m * d", 0, "before",
     '                    _P.enter("ext2")'),
    ("                    E2 = np.triu((Xm * rs[:m, None]).T @ Xm / m, 1); fl[0] += 2 * m * d * d + m * d", 0, "after",
     "                    _P.ext2(E2, S, t2, have)"),
    ('            V = sorted(set(v for kind, k in feats if kind == "chi" for v in k))', 0, "before", '            _P.enter("local")'),
    ("                tl = {k: thr(math.comb(L, k)) for k in range(1, L + 1)}", 0, "after", "                _P.local(h, tl, V, have)"),
    ("            blk = []", 0, "before", '            _P.enter("lin")'),
    ("                    T1 = n * float(np.sum(c1[lin] ** 2)) / s ** 2; k = len(lin); tt = math.log(1 / self.delta)", 0,
     "after", "                    _P.lin(T1, k, tt, n >= 2 * (len(feats) + k), lin0 and rnd == 0)"),
    ('                        blk.append(("linear", lin))                       # (else the background carries it)', 0,
     "after", '                        _P.acc("linear")'),
    ("                Ms = (M + M.T) / 2; np.fill_diagonal(Ms, 0.0)", 0, "before", '                _P.enter("quad")'),
    ("                qs = [q for q in np.argsort(-np.abs(lam)) if abs(lam[q]) > edge][:4] if n >= 4 * d else []", 0, "after",
     "                _P.quad(lam, edge, n >= 4 * d, qs)"),
    ('                    blk.append(("quad", [U[:, q].copy() for q in qs]))', 0, "after", '                    _P.acc("quad")'),
    ("            sum_top = [0.0, None]                                       # best additive candidate (T / threshold)", 0,
     "before", '            _P.enter("sum_setup")'),
    ("                rr, rrS, Mc, cands, mg0 = r, rS, M, [], -np.inf", 0, "before", '                _P.enter("sum_add")'),
    ("                    TS = tS(b_, rrS); ok = ok and TS > th_", 0, "after", '                    _P.bs("add%d" % it, b_, T_, th_, ok, TS)'),
    ('                        blk.append(("sum", b_)); have_blk.add(b_.key())', 0, "after", '                        _P.acc("sum_add", b_)'),
    ("                okb, prods = False, []                      # product candidates (margin, block)", 0, "before",
     '                _P.enter("sum_prod")'),
    ("                                                     init=[(c.S, c.sg, c.fold) for c in cands[1:]], **kw)", 0, "after",
     '                    _P.bs("prod", b2, Tb, thb, ok2)'),
    ("                            prods.append((TS - thb, P))", 0, "after", '                            _P.tag(P, "sum_prod")'),
    ("                if self.sum_prod and cands:                 # split move: a block with mixed signs may be |t_A - t_B|", 0,
     "before", '                _P.enter("sum_split")'),
    ("                                                         init=[(neg, [1.0] * len(neg), c0.fold)], **kw)", 0, "after",
     '                        _P.bs("split", b2, Tb, thb, ok2)'),
    ("                                prods.append((TS - thb, P))", 0, "after", '                                _P.tag(P, "sum_split")'),
    ('                        blk.append(("sum", P)); have_blk.add(P.key())', 0, "after", '                        _P.acc("sum_prodsplit", P)'),
    ("                if self.sum_prod and live:", 0, "before", '                _P.enter("sum_cpair")'),
    ('                            blk.append(("sum", P)); have_blk.add(P.key())', 0, "after", '                            _P.acc("sum_cpair", P)'),
    ("                for T in (nb if live else []):", 0, "before", '                _P.enter("sum_mod")'),
    ("                    b_, T_, th_, ok = _block_search(X, rt, s2, Mt, set(T), tk, mc, **kw)", 0, "after",
     '                    _P.bs("mod", b_, T_, th_, ok)'),
    ('                            blk.append(("sum", b_)); have_blk.add(b_.key())', 0, "after", '                            _P.acc("sum_mod", b_)'),
    ("                if self.sum_prod and live:", 1, "before", '                _P.enter("sum_prev")'),
    ('                            blk.append(("sum", P)); have_blk.add(P.key())', 1, "after", '                            _P.acc("sum_prev", P)'),
    ("            new = sorted(cand.items(), key=lambda kv: -kv[1][0])[: self.max_new]", 0, "before", '            _P.enter("select")'),
    ('                    blk = [("sum", sum_top[1])]; have_blk.add(sum_top[1].key()); forced[0] += 1   # v1.2: a block', 0,
     "after", '                    _P.forced("block", sum_top[1])'),
    ("                    new = [(top[1], (top[0], top[2]))]; forced[0] += 1", 0, "after", '                    _P.forced("char", top[1])'),
    ("            room = min(self.max_feats, n // 2) - len(feats)          # least squares with p <= n / 2", 0, "after",
     "            _P.sel(new, blk, room)"),
    ("            for S, _ in new[:room]:", 0, "before", '            _P.enter("add")'),
    ('                feats.append(("chi", S)); cols.append(_chi(X, S)); have.add(S); fl[0] += n * len(S)', 0, "after",
     "                _P.feat_chi(S)"),
    ('                            feats.append(("chi", (i,))); cols.append(X[:, i].copy()); have.add((i,))', 0, "after",
     '                            _P.feat("lin", (i,))'),
    ('                    bid = len(blocks); blocks.append(obj); info["blocks"].append(obj.desc())', 0, "after",
     "                    _P.block_added(obj, len(use))"),
    ('                        feats.append(("sum", (bid, v))); cols.append((g == v) * cm)', 0, "after", '                        _P.feat("sum", obj)'),
    ('                        feats.append(("quad", u)); cols.append((X @ u) ** 2 - u @ u); fl[0] += 2 * n * d', 0, "after",
     '                        _P.feat("quad")'),
    ('            w, r = lsfit(); info["rounds"] = rnd + 1', 0, "before", '            _P.enter("ls")'),
    ('            w, r = lsfit(); info["rounds"] = rnd + 1', 0, "after", "            _P.round_end()"),
    ("        F, W = list(feats), np.array(w)", 0, "before", '        _P.enter("logit")'),
    ("        bg = X.T @ r / n if self.background else np.zeros(d); fl[0] += 2 * n * d   # kernel background on the residual", 0,
     "before", '        _P.enter("bg")'),
    ('        info["size"] = len(F); info["train_err"] = float(np.mean(np.where(value(X) > 0, 1, -1) != y))', 0, "before",
     '        _P.enter("trainerr")'),
    ('        info["size"] = len(F); info["train_err"] = float(np.mean(np.where(value(X) > 0, 1, -1) != y))', 0, "after",
     "        _P.finish(info)"),
]


def build():
    raw = open(SRC, "rb").read(); assert hashlib.md5(raw).hexdigest() == MD5, "dfg13.py is not the frozen DFG v1.3"
    lines = raw.decode().split("\n")
    before, after = {}, {}
    for anchor, occ, where, new in INS:
        idx = [i for i, L in enumerate(lines) if L == anchor]
        assert len(idx) > occ, (anchor, occ, len(idx))
        if occ == 0 and anchor not in ("                if self.sum_prod and live:",
                                       '                            blk.append(("sum", P)); have_blk.add(P.key())'):
            assert len(idx) == 1, ("anchor not unique", anchor, idx)
        i = idx[occ]
        (before if where == "before" else after).setdefault(i, []).append(new)
    out = []
    for i, L in enumerate(lines):
        out += before.get(i, []); out.append(L); out += after.get(i, [])
    open(DST, "w").write("\n".join(out))
    return len(INS)


if __name__ == "__main__":
    k = build()
    print(f"wrote {DST}: {k} lines inserted")
