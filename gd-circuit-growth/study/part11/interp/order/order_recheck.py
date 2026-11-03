"""Part 11, Q7 'order': the numbers of ORDER.md that come from single fits or single characters rather than from
tables/order_numbers.json, recomputed from the stored files.  Written for the verification of ORDER.md
(VERIFY_ORDER.md / .json; the 'Verification' section of ORDER.md lists the changes): every number quoted in ORDER.md is
either in tables/order_numbers.json or tables/order_validation.json (order_report.py, order_validate.py) or printed here.
Sections follow ORDER.md.  Reads only: results/cells/*.json.gz and results/order_summary.json.gz (order_fit.py,
order_analysis.py), trajectories/results/*.json (Part 5), the frozen dfg13.py's constructor defaults and budget caps
(through dfg_hooks), and the 4096 test inputs of harness.test_data (for one character).  No fits.
Writes tables/order_recheck.txt (the same text as it prints).
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python order_recheck.py"""
import os, sys, json, gzip, math, itertools, numpy as np
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import order_analysis as A                                                      # noqa: E402

INF = math.inf
OUT = []


def F(v):
    return INF if v == "inf" else -INF if v == "-inf" else v


def say(*a):
    s = " ".join(str(x) for x in a); OUT.append(s); print(s, flush=True)


def r2(v, nd=2):
    return None if v is None else (round(v, nd) if np.isfinite(v) else v)


with gzip.open(os.path.join(A.RES, "order_summary.json.gz"), "rt") as fh:
    S = json.load(fh)
T = S["targets"]
CELL = {}


def cell(fn, n, s):
    k = (fn, n, s)
    if k not in CELL:
        CELL[k] = A.load_cell(fn, n, s)
    return CELL[k]


def name(Sx):
    return "".join(f"x{i + 1}" for i in Sx)


def dn(fn, ch, s):
    return F(T[fn]["dfg_n"][str(s)][ch]["n"])


def how(fn, ch, s):
    """How chi_S is carried at seed s's DFG n onset (as order_report.char_rows): class, linear-block, forced, block, never."""
    n0 = dn(fn, ch, s)
    if not np.isfinite(n0):
        return "never"
    e = cell(fn, int(n0), s)["explicit"].get(ch)
    return "block" if e is None else (e["how"] if e["how"] != "test" else (e["cls"] or "test"))


def med_dn(fn, ch):
    return A.med([dn(fn, ch, s) for s in A.SEEDS])


def entries(c):
    """Explicit admissions of target characters in a fit: sorted (round, char, how-or-class)."""
    return sorted((e["round"], ch, e["cls"] if e["how"] == "test" else e["how"]) for ch, e in c["explicit"].items() if e)


def blocks(c):
    return [[(b["desc"], "mod" if b["mod"] else "plain") for b in r["sum_blocks"]] for r in c["rounds"]]


def net_on(fn, ch):
    return F(T[fn]["net_time"]["online"][ch]["mean"])


def sec_1_2():
    say("== sec. 1.2  onset conventions of the online networks")
    ch9 = "x1x2x3x4x5x6x7x8x9"; e = T["dnf3"]["net_time"]["online"][ch9]
    sd = [F(x) for x in e["seeds"]]
    say("dnf3 x1..x9: per-seed onsets", [r2(x, 1) for x in sd], "geometric mean", r2(math.exp(np.mean(np.log(sd))), 1),
        "(of the rounded seeds", r2(math.exp(np.mean(np.log([round(x) for x in sd]))), 1), ") seed-mean curve", r2(F(e["mean"]), 1))
    dif = []
    for fn in A.TARGETS:
        for ch in T[fn]["chars"]:
            a = net_on(fn, ch); g = [F(x) for x in T[fn]["net_time"]["online"][ch]["seeds"]]
            g = math.exp(np.mean(np.log(g))) if all(np.isfinite(g)) else INF
            if np.isfinite(a) and np.isfinite(g) and max(a, g) / min(a, g) > 1.1:
                dif.append((fn, ch, a, g))
    say("conventions more than 10% apart (larger / smaller > 1.1):", len(dif), "of", sum(len(T[f]["chars"]) for f in A.TARGETS),
        dict(Counter(x[0] for x in dif)))
    for fn, ch in (("dnf3", "x2x7"), ("dnf3", "x1x4x7"), ("stair5", "x1x2x4")):
        x = next(v for v in dif if v[:2] == (fn, ch)); say(f"   {fn} {ch}: seed-mean {x[2]:.1f}, geometric mean {x[3]:.1f}")
    big = max(dif, key=lambda v: max(v[2], v[3]) / min(v[2], v[3])); ab = max(dif, key=lambda v: abs(v[2] - v[3]))
    say(f"   largest ratio: {big[0]} {big[1]} {big[2]:.0f} / {big[3]:.0f} = {max(big[2:]) / min(big[2:]):.2f}; largest difference "
        f"in steps: {ab[0]} {ab[1]} {ab[2]:.0f} / {ab[3]:.0f} ({abs(ab[2] - ab[3]):.0f} steps, ratio {max(ab[2:]) / min(ab[2:]):.2f})")
    say("mux seed-mean onsets:", {ch: r2(net_on("mux", ch), 1) for ch in T["mux"]["chars"]})


def sec_1_5():
    say("== sec. 1.5  compute")
    cpu = []
    for fn in A.TARGETS:
        for n in A.NS:
            for s in A.SEEDS:
                cpu.append((cell(fn, n, s)["cpu_seconds"], fn, n, s))
    m = max(cpu)
    say(f"CPU time of the 363 fits: {sum(x[0] for x in cpu) / 60:.2f} min; longest {m[0]:.2f} s ({m[1]} n = {m[2]} seed {m[3]})")


def sec_2():
    say("== sec. 2  round order")
    multi = {}
    for fn in A.TARGETS:
        for n in A.NS:
            for e in T[fn]["dfg_grid"][str(n)]:
                multi[(fn, n, e["seed"])] = e
    v128 = [(k, e) for k, e in multi.items() if k[1] == 128]
    say("n = 128: forced variant in", sum(1 for _, e in v128 if e["variant"] == 1), "of", len(v128), "fits;",
        sum(1 for _, e in v128 if e["variant"] == 1 and e["distinct_rounds"] >= 2), "of the",
        sum(1 for _, e in v128 if e["distinct_rounds"] >= 2), "multi-round ones")
    for n in (512, 2048, 16384):
        L = sorted((fn, s) for (fn, n_, s), e in multi.items() if n_ == n and e["distinct_rounds"] >= 2)
        say(f"multi-round fits at n = {n}:", L)
    st = Counter(); err0 = 0; bad = []
    for n in (512, 2048, 16384):
        for fn in A.TARGETS:
            for s in A.SEEDS:
                c = cell(fn, n, s); st[c["stop"]] += 1
                if c["err"] == 0:
                    err0 += 1
                else:
                    bad.append((fn, n, s, round(c["err"], 5)))
    say("fits at n = 512 / 2048 / 16384: stops", dict(st), "; test error 0 in", err0, "; the others", bad)
    for fn, n, s in (("rmaj9", 512, 0), ("parmaj", 512, 1)):
        c = cell(fn, n, s)
        say(f"{fn} n = {n} seed {s}: rounds {c['rounds_n']}")
        for r in c["rounds"]:
            say(f"   round {r['round']}: new {[name(x) for x in r['new']]} linear-block {r['linear']} blocks "
                f"{[(b['desc'], 'mod' if b['mod'] else 'plain') for b in r['sum_blocks']]}")
        say("   explicit target characters by (round, class):", dict(Counter((e[0], e[2]) for e in entries(c))))
        PL = np.array(c["phi_ls"]); ch9 = [q for q, ch in enumerate(c["chars"]) if c["deg"][q] >= 6]
        say("   characters with phi >= 1/2 after each round:", [int(np.sum(PL[k] >= 0.5)) for k in range(len(PL))], "of",
            len(c["chars"]), "; of degree >= 6:", [int(np.sum(PL[k, ch9] >= 0.5)) for k in range(len(PL))], "of", len(ch9),
            "; those after round 0:", [c["chars"][q] for q in ch9 if PL[1, q] >= 0.5])
    say("rmaj9 round-order tau (online seed-mean onsets) at n = 16384, per seed:",
        [r2(x) for x in [p["tau"] for p in T["rmaj9"]["cmp"]["online"]["per_seed"]]])


def sec_3(DM, dfg):
    say("== sec. 3  round-0 priority")
    top = Counter(); z16 = defaultdict(list)
    for n in A.NS:
        for s in A.SEEDS:
            c = cell("mux", n, s); z = {ch: (o["zbest"] if o else 0.0) for ch, o in zip(c["chars"], [c["replay"][ch][0] for ch in c["chars"]])}
            best = max(z.values()); strict = sum(1 for v in z.values() if v == best) == 1
            if z["x1x2x3x4"] == best and strict:
                top[n] += 1
            if n == 16384:
                z16["x1x2x3x4"].append(z["x1x2x3x4"]); z16["others"] += [v for ch, v in z.items() if ch != "x1x2x3x4"]
    n64 = [n for n in A.NS if n >= 64]
    say(f"mux: x1x2x3x4 has the strictly highest round-0 z in {sum(top[n] for n in n64)} of the {3 * len(n64)} fits at n >= 64 "
        f"(n = {n64[0]}..{n64[-1]}, {len(n64)} grid values x 3 seeds) and in {top[32]} of 3 at n = 32, {top[16]} of 3 at n = 16; per n "
        f"{dict(sorted(top.items()))}; at n = 16384 its z0 {[r2(v) for v in z16['x1x2x3x4']]}, the others "
        f"{r2(min(z16['others']))}-{r2(max(z16['others']))}")
    chars = T["mux"]["chars"]; on = {ch: net_on("mux", ch) for ch in chars}
    for s in A.SEEDS:
        D = T["mux"]["dfg"]["16384"][str(s)]["rounds"]; zz = {ch: -D[ch]["z0"] for ch in chars}
        p = A.pair_counts(chars, on, zz, keep=50)
        say(f"   seed {s}, online network order vs DFG z0 at n = 16384: network-ordered pairs {p['concordant'] + p['tied'] + p['inverted']}, "
            f"inverted {p['inverted']}, all with x1x2x3x4: {all('x1x2x3x4' in q for q in p['inverted_pairs'])}")
    d = 30
    for scale, lab in ((1.0, "n > 512 (full budget)"), (0.5, "n <= 512 (final fit after CV, half the budget)")):
        GD = DM.gd_flops(d) * scale                                             # dfg13's own budget unit (harness.gd_flops)
        caps = []
        for k in (5, 6):
            k1, k2 = (k + 1) // 2, k // 2; N1, N2 = math.comb(d, k1), math.comb(d, k2)
            caps.append(int(dfg.budget_hi * GD / (2 * N1 * N2 + DM.m_tab_cost(d, k1, k2))))
        c3 = int(dfg.budget[1] * GD / (d * (2 * d * d + 2 * d))); c4 = int(dfg.budget[0] * GD / (math.comb(d, 2) * (2 * d * d + 3 * d)))
        say(f"subsample caps at {lab}: degree 5 {caps[0]}, degree 6 {caps[1]} rows; degree 3 {c3}, degree 4 {c4} rows")
    say(f"DFG constants: K {dfg.K}, K_later {dfg.K_later}, K_hi {dfg.K_hi}, c {dfg.c}, delta {dfg.delta}, cv_n {dfg.cv_n}, "
        f"local_max {dfg.local_max}")
    need = lambda fn, ch: (2 * math.log(4 * dfg.K * math.comb(d, T[fn]["deg"][ch]) / dfg.delta) * (1 - T[fn]["yconst"] ** 2)
                           / T[fn]["yhat"][ch] ** 2)
    say("rows the round-0 global test needs, before the subsample caps (sec. 4.3 majpar, sec. 6 step 3):",
        {f"{fn} {ch}": round(need(fn, ch), 1) for fn, ch in (("majpar", "x1x2x3x4x5x6"), ("parmaj", "x1x2x3x4x5x6"),
                                                              ("sparsepoly", "x1x2x3x4x5x6"), ("sparsepoly", "x2x3x4x5x6"))},
        "; n_glob in the tables:", {f"{fn} {ch}": r2(F(T[fn]["nglob"][ch]), 1) for fn, ch in (("majpar", "x1x2x3x4x5x6"),
                                                                                          ("parmaj", "x1x2x3x4x5x6"))})


def sec_4_2():
    say("== sec. 4.2  data cost: the per-target examples (DFG per seed and median; networks' n onset, median of seeds)")
    for fn, chs in (("mux", ["x1x2x3x4"]), ("majpar", ["x1x2", "x3x4", "x5x6"]), ("andxor", T["andxor"]["chars"]),
                    ("parmaj", [c for c in T["parmaj"]["chars"] if T["parmaj"]["deg"][c] <= 4])):
        dm = sorted(set(med_dn(fn, ch) for ch in chs)); ds = sorted(set(dn(fn, ch, s) for ch in chs for s in A.SEEDS))
        nm = sorted(set(A.med([F(x) for x in T[fn]["net_n"][ch]["seeds"]]) for ch in chs))
        say(f"   {fn} {chs if len(chs) < 4 else str(len(chs)) + ' characters of degree <= 4'}: DFG median {dm} (per seed {ds}); networks' median {nm}")
    say("== sec. 4.2  data cost: rmaj9's cross-block degree-3 characters")
    fn = "rmaj9"; yh = T[fn]["yhat"]; dg = T[fn]["deg"]
    cb = [ch for ch in T[fn]["chars"] if dg[ch] == 3 and abs(yh[ch]) < 0.1]
    fin = lambda v: [x for x in v if np.isfinite(x)]
    dps = [dn(fn, ch, s) for ch in cb for s in A.SEEDS]; dm = [med_dn(fn, ch) for ch in cb]
    nps = [F(x) for ch in cb for x in T[fn]["net_n"][ch]["seeds"]]; nm = [A.med([F(x) for x in T[fn]["net_n"][ch]["seeds"]]) for ch in cb]
    say(f"{len(cb)} characters; DFG per seed {min(fin(dps))}-{max(fin(dps))} (never {len(dps) - len(fin(dps))}), by median "
        f"{min(fin(dm))}-{max(fin(dm))}; networks per seed {min(fin(nps))}-{max(fin(nps))} (never {len(nps) - len(fin(nps))}), "
        f"by median {min(fin(nm))}-{max(fin(nm))}, never by median: {[ch for ch, v in zip(cb, nm) if not np.isfinite(v)]}")
    sys.path.insert(0, os.path.join(A.STUDY, "discrete_learner")); sys.path.insert(1, A.STUDY)
    import harness as TH                                                        # noqa: E402
    from boolfuncs import make_suite                                            # noqa: E402
    Xte, yte = TH.test_data(make_suite(30)[fn]["fn"], fn, 30); Xte = Xte.astype(np.float64); yte = yte.astype(np.float64)
    ph = {ch: float(np.mean(yte * np.prod(Xte[:, [int(p) - 1 for p in ch.split("x")[1:]]], 1))) / yh[ch] for ch in cb}
    lo = min(ph, key=ph.get)
    say(f"phi that the exact target scores on the 4096 test inputs: lowest {lo} {ph[lo]:.3f}, range {min(ph.values()):.2f}-{max(ph.values()):.2f}")


def sec_4_3():
    say("== sec. 4.3  stages, target by target (single fits)")
    # sparsepoly
    fn = "sparsepoly"
    say("sparsepoly: x1x2x3 at its onset per seed", [how(fn, "x1x2x3", s) for s in A.SEEDS], "; x2x3x4x5x6",
        [how(fn, "x2x3x4x5x6", s) for s in A.SEEDS], "; x1..x6 onsets", [dn(fn, "x1x2x3x4x5x6", s) for s in A.SEEDS])
    for s in A.SEEDS:
        n0 = dn(fn, "x1x2x3x4x5x6", s)
        if np.isfinite(n0):
            say(f"   x1..x6 seed {s} at n = {int(n0)}: product blocks {[b['desc'] for r in cell(fn, int(n0), s)['rounds'] for b in r['sum_blocks'] if b['product']]}")
    # stair5
    fn = "stair5"
    for s in A.SEEDS:
        say(f"stair5 n = 128 seed {s}: variant {cell(fn, 128, s)['variant']}, explicit {entries(cell(fn, 128, s))}, blocks {blocks(cell(fn, 128, s))}")
    P = T[fn]["cmp"]["online"]["pairs_n"]; yh = T[fn]["yhat"]
    k = Counter(("network-first -0.125, DFG-first 0.375" if abs(yh[a]) < 0.2 and abs(yh[b]) > 0.2 else
                 "both -0.125" if abs(yh[a]) < 0.2 and abs(yh[b]) < 0.2 else "other") for a, b in P["inverted_pairs"])
    say(f"   inverted pairs {P['inverted']}: {dict(k)}; n_glob x1x2 {T[fn]['nglob']['x1x2']:.1f}, x1x3 {T[fn]['nglob']['x1x3']:.1f}, "
        f"ratio {T[fn]['nglob']['x1x3'] / T[fn]['nglob']['x1x2']:.2f}")
    say("   network onsets online:", sorted((round(net_on(fn, ch)), T[fn]["deg"][ch], ch) for ch in T[fn]["chars"]))
    # mux
    fn = "mux"
    for ch in T[fn]["chars"]:
        L = []
        for s in A.SEEDS:
            n0 = dn(fn, ch, s); e = cell(fn, int(n0), s)["explicit"].get(ch)
            L.append((int(n0), "block" if e is None else (e["how"], e["cls"], e["round"], round(e["z"], 3))))
        say(f"mux {ch}: (n onset, how) per seed {L}")
    say("   blocks at n = 64:", {s: blocks(cell(fn, 64, s)) for s in A.SEEDS})
    # majpar
    fn = "majpar"
    for s in A.SEEDS:
        say(f"majpar n = 256 seed {s}: blocks {blocks(cell(fn, 256, s))}")
    z = [(n, s, cell(fn, n, s)["replay"]["x1x2x3x4x5x6"][0]["global"]) for n in A.NS for s in A.SEEDS
         if cell(fn, n, s)["replay"]["x1x2x3x4x5x6"][0] and "global" in cell(fn, n, s)["replay"]["x1x2x3x4x5x6"][0]]
    for lo, hi in ((64, 512), (1024, 16384)):
        zz = [x for x in z if lo <= x[0] <= hi]
        say(f"   x1..x6 round-0 global test at n = {lo}-{hi}: rows m {sorted(set(x[2]['m'] for x in zz))}, z {min(x[2]['z'] for x in zz):.3f}-"
            f"{max(x[2]['z'] for x in zz):.3f}")
    say(f"   n_glob of x1..x6: {T[fn]['nglob']['x1x2x3x4x5x6']}; explicit at any n: "
        f"{[(n, s) for n in A.NS for s in A.SEEDS if cell(fn, n, s)['explicit'].get('x1x2x3x4x5x6')]}")
    # andxor
    fn = "andxor"
    for s in A.SEEDS:
        for n in (32, 64, 128):
            c = cell(fn, n, s)
            say(f"andxor seed {s} n = {n}: variant {c['variant']}, explicit {entries(c)}, blocks {blocks(c)}")
        say(f"   n onsets seed {s}:", {ch: dn(fn, ch, s) for ch in T[fn]["chars"]})
    say("   network onsets online:", {ch: round(net_on(fn, ch)) for ch in T[fn]["chars"]})
    # dlist5
    fn = "dlist5"; P = T[fn]["cmp"]["online"]["pairs_n"]; yh = T[fn]["yhat"]; dg = T[fn]["deg"]
    early = Counter((dg[a], round(abs(yh[a]), 4)) for a, b in P["inverted_pairs"])
    small = [(a, b) for a, b in P["inverted_pairs"] if round(abs(yh[b]), 4) == 0.0625]
    say(f"dlist5: inverted pairs {P['inverted']}; the networks' earlier character by (degree, |yhat|) {dict(early)}")
    say(f"   DFG-first character also 0.0625 in {len(small)}: higher degree {sum(1 for a, b in small if dg[b] > dg[a])}, same "
        f"{sum(1 for a, b in small if dg[b] == dg[a])} ({dict(Counter((dg[a], dg[b]) for a, b in small if dg[b] == dg[a]))}); larger in "
        f"{len(P['inverted_pairs']) - len(small)}: {sorted(set(b for a, b in P['inverted_pairs'] if round(abs(yh[b]), 4) != 0.0625))}")
    hw = [tuple(how(fn, b, s) for s in A.SEEDS) for a, b in small]
    say("   how the 0.0625 DFG-first character is carried at each seed's onset (s0, s1, s2):", dict(Counter(hw)))
    for s in A.SEEDS:
        say(f"     seed {s}:", dict(Counter(h[s] for h in hw)))
    att = []
    for a, b in small:
        ns = [dn(fn, b, s) for s in A.SEEDS]; m = A.med(ns)
        att.append((m, any(ns[s] == m and how(fn, b, s) == "block" for s in A.SEEDS)))
    say("   median-seed onsets:", dict(Counter(x[0] for x in att)), "; a block-carried seed attains the median in",
        sum(1 for x in att if x[1]), "of", len(att))
    lin = {ch: [dn(fn, ch, s) for s in A.SEEDS] for ch in ("x4", "x5")}
    say("   x4, x5 n onsets per seed", lin, "how", {ch: [how(fn, ch, s) for s in A.SEEDS] for ch in lin})
    # parmaj
    fn = "parmaj"
    for s in A.SEEDS:
        c = cell(fn, 128, s)
        say(f"parmaj n = 128 seed {s}: per round (n_new, linear block, blocks) "
            f"{[(r['n_new'], r['linear'], [b['desc'] for b in r['sum_blocks']]) for r in c['rounds']]}")
    pq = Counter((int(dn(fn, ch, s)), how(fn, ch, s), s if dn(fn, ch, s) != 128 else "-") for ch in T[fn]["chars"] if T[fn]["deg"][ch] in (2, 4) for s in A.SEEDS)
    say("   pairs and degree-4 terms, (n onset, how, seed if not 128):", dict(pq))
    say("   first n with phi >= 1/2 (n_first), all 16 characters, per seed:",
        [sorted(set(F(T[fn]["dfg_n"][str(s)][ch]["n_first"]) for ch in T[fn]["chars"])) for s in A.SEEDS],
        "; n onset (for good) not 128:", [(s, ch, dn(fn, ch, s)) for s in A.SEEDS for ch in T[fn]["chars"] if dn(fn, ch, s) != 128])
    say("   n = 512 seed 1: explicit by (round, class)", dict(Counter((e[0], e[2]) for e in entries(cell(fn, 512, 1)))))
    ln = lambda k: math.log(4 * 4 * math.comb(30, k) / 0.1)
    say(f"   ln(4 K N / delta): degree 2 {ln(2):.2f} (4KN/delta = {4 * 4 * math.comb(30, 2) / 0.1:.3g}), degree 4 {ln(4):.2f} "
        f"({4 * 4 * math.comb(30, 4) / 0.1:.3g}); threshold ratio sqrt = {math.sqrt(ln(4) / ln(2)):.3f}")
    # dnf3
    fn = "dnf3"; yh = T[fn]["yhat"]; dg = T[fn]["deg"]; G = defaultdict(Counter)
    for ch in T[fn]["chars"]:
        G[(dg[ch], round(abs(yh[ch]), 4))][med_dn(fn, ch)] += 1
    say("dnf3: DFG median-seed n onsets by (degree, |yhat|):")
    for k in sorted(G):
        say("  ", k, dict(sorted(G[k].items())))
    sm = [ch for ch in T[fn]["chars"] if round(abs(yh[ch]), 4) == 0.0039]
    mid = [ch for ch in sm if 1024 <= med_dn(fn, ch) <= 4096]
    say(f"   0.0039-characters: {len(sm)}; median onset 1024-4096: {len(mid)}, by degree {dict(sorted(Counter(dg[ch] for ch in mid).items()))}, "
        f"how per seed {dict(Counter(how(fn, ch, s) for ch in mid for s in A.SEEDS))}")
    st = A.net_stages({ch: net_on(fn, ch) for ch in T[fn]["chars"]})[0]
    say("   network stages online (start, count, degrees):", [(round(net_on(fn, g[0])), len(g), sorted(set(dg[c] for c in g))) for g in st])
    # rand3
    fn = "rand3"
    for s in A.SEEDS:
        c = cell(fn, 128, s)
        say(f"rand3 n = 128 seed {s}: explicit {entries(c)}; blocks {[(b, m) for r in blocks(c) for b, m in r]}")
    for s in A.SEEDS:
        say(f"rand3 n = 256 seed {s}: blocks {[(b, m) for r in blocks(cell(fn, 256, s)) for b, m in r]}")
    hw = Counter(how(fn, ch, s) for ch in T[fn]["chars"] for s in A.SEEDS)
    say(f"   how at the onset, {sum(hw.values())} character-seeds: {dict(hw)}; block-carried by onset n "
        f"{dict(Counter(int(dn(fn, ch, s)) for ch in T[fn]['chars'] for s in A.SEEDS if how(fn, ch, s) == 'block'))}")
    yh = T[fn]["yhat"]; by = defaultdict(list); has6 = lambda c: "6" in c.split("x")
    for ch in T[fn]["chars"]:
        by[med_dn(fn, ch)].append(ch)
    for n0, chs in sorted(by.items()):
        say(f"   median n {n0}: {len(chs)} characters; |yhat| {dict(Counter(round(abs(yh[c]), 3) for c in chs))}; on x1..x5 containing "
            f"x5: {sum(1 for c in chs if not has6(c) and '5' in c.split('x'))}; containing x6: {sorted(c for c in chs if has6(c)) if len(chs) < 18 else sum(1 for c in chs if has6(c))}; "
            f"0.125-characters with / without x6: {sum(1 for c in chs if has6(c) and abs(yh[c]) < 0.2)} / {sum(1 for c in chs if not has6(c) and abs(yh[c]) < 0.2)}")
    say("networks' stages online, for the targets whose text quotes them (start = stage start; Part 5's stages.py chains: a new "
        "stage when an onset exceeds 1.35 x the previous one; order_stages.md: when it exceeds 1.35 x the stage's first onset)")
    for fn in ("stair5", "rmaj9", "dlist5", "dnf3", "rand1", "rand3", "sparsepoly", "mux", "majpar", "andxor", "parmaj"):
        on = {ch: net_on(fn, ch) for ch in T[fn]["chars"]}; dg = T[fn]["deg"]
        chain = A.net_stages(on)[0]
        o = sorted((v, ch) for ch, v in on.items() if np.isfinite(v)); start = []
        for v, ch in o:
            if start and v <= 1.35 * start[-1][0]:
                start[-1][1].append(ch)
            else:
                start.append((v, [ch]))
        fmt = lambda g: f"{round(on[g[0]])}-{round(on[g[-1]])} ({len(g)} chars, degrees {min(dg[c] for c in g)}-{max(dg[c] for c in g)})"
        say(f"   {fn:10s} chaining: {' | '.join(fmt(g) for g in chain)}")
        say(f"   {'':10s} from the stage start: {' | '.join(fmt(g) for _, g in start)}")


def sec_5_1(dfg):
    say("== sec. 5.1  the union bound by degree (round 0, global class, d = 30)")
    ln = {k: math.log(4 * dfg.K * math.comb(30, k) / dfg.delta) for k in range(1, 7)}
    say("ln(4 K C(30,k) / delta), k = 1..6:", {k: round(v, 2) for k, v in ln.items()}, f"; sqrt(ln_4 / ln_1) = {math.sqrt(ln[4] / ln[1]):.3f}")
    ng = T["mux"]["nglob"]
    say(f"mux: coefficient ratio {0.75 / 0.25:.1f}; z-score ratio (0.75 / sqrt(ln_4)) / (0.25 / sqrt(ln_1)) = "
        f"{(0.75 / math.sqrt(ln[4])) / (0.25 / math.sqrt(ln[1])):.2f}; n_glob x1x2x3x4 {ng['x1x2x3x4']:.1f}, x1 {ng['x1']:.1f}, ratio "
        f"{ng['x1'] / ng['x1x2x3x4']:.2f}")


def sec_5_3():
    say("== sec. 5.3  rmaj9's degree-5 and degree-7 characters (36): carried (phi_ls >= 1/2) per fit, and how")
    fn = "rmaj9"
    for n in A.NS:
        for s in A.SEEDS:
            c = cell(fn, n, s); hi = [q for q, d in enumerate(c["deg"]) if d in (5, 7)]
            car = [q for q in hi if c["phi_ls"][-1][q] >= 0.5]
            if car:
                hw = Counter("block" if c["explicit"].get(c["chars"][q]) is None else
                             (c["explicit"][c["chars"][q]]["cls"], "round", c["explicit"][c["chars"][q]]["round"]) for q in car)
                PL = np.array(c["phi_ls"])
                say(f"   n = {n} seed {s}: {len(car)} of {len(hi)}; how {dict(hw)}; carried after each round "
                    f"{[int(np.sum(PL[k, hi] >= 0.5)) for k in range(len(PL))]}; blocks by round {blocks(c)}")
    hi = [ch for ch in T[fn]["chars"] if T[fn]["deg"][ch] in (5, 7)]
    say("   n onsets for good:", dict(Counter(dn(fn, ch, s) for ch in hi for s in A.SEEDS)), "; carried at some n:",
        sum(1 for ch in hi for s in A.SEEDS if np.isfinite(F(T[fn]["dfg_n"][str(s)][ch]["n_first"]))), "of", 3 * len(hi),
        "; dropped at a larger n:", sum(1 for ch in hi for s in A.SEEDS if T[fn]["dfg_n"][str(s)][ch]["dropped_after"]))


def sec_5_4():
    say("== sec. 5.4  endpoints")
    ov = []
    for fn in A.TARGETS:
        r = json.load(open(os.path.join(A.TRAJ, f"{fn}_fixed.json")))
        for s in A.SEEDS:
            ph = np.array([r["nets"][f"512/s{s}"]["phi"][ch][-1] for ch in T[fn]["chars"]])
            ov.append(float(np.mean((ph >= 0.5) & (ph < 0.75))))
    say(f"networks at n = 512: share both 'learned' (phi >= 1/2) and 'partial' (0.25 <= phi < 0.75), mean over 33 cells: {np.mean(ov):.3f}")
    for fn in ("rmaj9", "dnf3", "sparsepoly"):
        for n in (16384, 2048):
            L = [(int(np.sum(np.array(cell(fn, n, s)["phi_ls"][-1]) >= 0.5)), cell(fn, n, s)["err"]) for s in A.SEEDS]
            say(f"   DFG {fn} n = {n}: carried (phi_ls >= 1/2) and test error per seed {L} of {len(T[fn]['chars'])}")
    c = cell("rmaj9", 512, 0)
    say(f"   rmaj9 seed 0: n = 512 {c['rounds_n']} rounds carry {int(np.sum(np.array(c['phi_ls'][-1]) >= 0.5))}; n = 16384 "
        f"{cell('rmaj9', 16384, 0)['rounds_n']} round carries {int(np.sum(np.array(cell('rmaj9', 16384, 0)['phi_ls'][-1]) >= 0.5))}")


def sec_7():
    say("== sec. 7  the final predictor against the least-squares function")
    c = cell("mux", 128, 0); q = [c["chars"].index(ch) for ch in ("x1x4", "x2x4", "x3x4")]
    say("mux n = 128 seed 0, x_i x4: phi_final", [r2(c["phi_final"][i]) for i in q], "least-squares", [r2(c["phi_ls"][-1][i]) for i in q])


def main():
    sys.path.insert(0, os.path.dirname(HERE))
    import dfg_hooks as H                                                       # noqa: E402  (sets the runner's sys.path)
    DM = H.E.load_dfg13(); dfg = DM.DFG(readout="logit")                         # md5-checked frozen dfg13.py
    sec_1_2(); sec_1_5(); sec_2(); sec_3(DM, dfg); sec_4_2(); sec_4_3(); sec_5_1(dfg); sec_5_3(); sec_5_4(); sec_7()
    open(os.path.join(A.TAB, "order_recheck.txt"), "w").write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
