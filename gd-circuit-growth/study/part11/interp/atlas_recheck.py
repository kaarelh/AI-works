"""Part 11 structure atlas: recomputes, from the stored files, the numbers that ATLAS.md changed after its independent
verification (VERIFY_ATLAS.md / .json; the 'Verification' section of ATLAS.md lists the changes).  Reads only files
(results/atlas, results/cv, the merged evaluation files, Part 10's v3 structure files, the draw log of
part9/heldout6/suite.py) and the 4096 test inputs of harness.test_data; no fits, except f7_11 at n = 128 with --refit
(about 10 s).  Output: atlas_recheck.txt.
usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python atlas_recheck.py [--refit]"""
import os, sys, json, ast, math, time, importlib.util, numpy as np
from collections import Counter
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import atlas_make as M                                                 # noqa: E402

H, TH, NS = M.H, M.TH, M.NS
R = M.load_atlas()
ORDER = [t for _, L in M.GROUPS for t in L]
P10V3 = os.path.join(M.P10, "results", "toy_final", "v3")


def cell(t, n):
    return next(c for c in R[t]["cells"] if c["n"] == n)


def complete(c):
    return any(rp.get("complete") for rp in c["summary"]["reps"])


def first_fit(t):
    return next((c["n"] for c in R[t]["cells"] if c["err"] <= 0.1), None)


def test_inputs(t, _cache={}):
    s = R[t]["suite"]
    T = _cache.setdefault(s, H.targets(s))
    Xte, yte = TH.test_data(T[t]["fn"], t, 30)
    return np.asarray(Xte, np.float64)


def main():
    print("== suites of the 37 atlas targets:", dict(Counter(R[t]["suite"] for t in ORDER)))
    pr = os.path.join(H.RESULTS, "toy__dfg13-perm__random.json")
    print("== random-suite merged file: seeds", M.merged("random")["seeds"], "(n*_3 of rf06 is their mean); written",
          time.strftime("%H:%M:%S UTC", time.gmtime(os.path.getmtime(pr))))
    print("== representations: verified by enumeration (chars), by functional dependence only (blocks), not at all")
    for t in ORDER:
        print(f"   {t:7s}", [("chars" if "chars" in r and "blocks" not in r else "blocks" if "blocks" in r else "quad")
                             + ("" if r.get("verified") else " (unverified)") for r in R[t]["spec"]["reps"]])

    print("== degree-1 characters at n = 16384: sd of their summed contribution / output sd (exact) and the tables' "
          "root-sum-square of term shares (absolute, and / output sd)")
    for t in ("maj9", "thrint", "thr30", "f7_01"):
        c = cell(t, 16384); X = test_inputs(t); v = np.zeros(len(X)); ss = []
        for x in c["terms"]:
            if x["kind"] == "chi" and x["deg"] == 1:
                col = x["w"] * np.prod(X[:, x["S"]], 1); v += col; ss.append(float(np.std(col)))
        rss = math.sqrt(sum(s * s for s in ss)); sd = c["summary"]["value_sd"]
        print(f"   {t:7s} exact {np.std(v) / sd:.3f} of the output sd ({np.std(v):.3f} absolute); "
              f"root-sum-square {rss:.3f} absolute, {rss / sd:.3f} of the output sd")

    print("== thrint: test error by n, degree-1 PTF complete, sum terms at 512")
    print("  ", [(c["n"], round(c["err"], 4), complete(c)) for c in R["thrint"]["cells"]])
    print("  ", [(x["desc"], x["cat"], round(x["share"], 2)) for x in cell("thrint", 512)["terms"] if x["kind"] == "sum"])
    print("   512:", M.rep_line(cell("thrint", 512)))
    print("   weighted blocks (sum terms with an inner term) by n:")
    for c in R["thrint"]["cells"]:
        if c["n"] >= 512:
            print(f"   {c['n']}:", [x["desc"] for x in c["terms"] if x["kind"] == "sum" and x["inner"]])

    print("== staircases: (n, relevant-block share R, complete, degrees of the missing prefix characters)")
    for t, k in (("stair5", 5), ("stair6", 6)):
        print(f"   {t}:", [(c["n"], round(c["summary"]["categories"]["R"]["share"], 2), complete(c),
                            [j + 1 for j in range(k) if not any(x["kind"] == "chi" and x["S"] == list(range(j + 1)) for x in c["terms"])])
                           for c in R[t]["cells"] if c["n"] >= 128])
    for n in (256, 512, 1024, 2048):
        print(f"   stair5@{n} sum terms (desc, category, share):",
              [(x["desc"], x["cat"], round(x["share"], 3)) for x in cell("stair5", n)["terms"] if x["kind"] == "sum"],
              "; S share", cell("stair5", n)["summary"]["categories"]["S"]["share"])
    print("== mux6 sum terms at 256 and 512:", [(n, [(x["desc"], x["cat"]) for x in cell("mux6", n)["terms"] if x["kind"] == "sum"]) for n in (256, 512)])
    print("   mux6, n with any sum term:", [c["n"] for c in R["mux6"]["cells"] if any(x["kind"] == "sum" for x in c["terms"])])

    print("== multiplexers: modulated address blocks (target terms with a modulator) by n")
    for t in ("mux6", "mux11"):
        print(f"   {t}:", [(c["n"], sum(1 for x in c["terms"] if x["kind"] == "sum" and x["mod"] and x["cat"] == "T"))
                           for c in R[t]["cells"]])
    c = cell("mux11", 512); ch = [x for x in c["terms"] if x["kind"] == "chi"]
    print(f"   mux11@512: {len(ch)} characters, {sum(1 for x in ch if x['cat'] == 'T')} of them Fourier characters, "
          f"S-lin {c['S_lin']['n']} characters share {c['S_lin']['share']:.3f}")

    print("== parmaj / majxor: cross-pair characters, folded blocks, spectral features")
    for t in ("parmaj", "majxor"):
        for c in R[t]["cells"]:
            if c["n"] < 128:
                continue
            q = [(round(x["share"], 2), x["mass_rel"], x.get("quad_match")) for x in c["terms"] if x["kind"] == "quad"]
            fb = [round(x["share"], 2) for x in c["terms"] if x["kind"] == "sum" and x["fold"] and x["cat"] == "T"]
            print(f"   {t}@{c['n']}: {M.rep_line(c)}; folded target blocks {fb}; quad {q}")
    print("   parmaj's folded target blocks from 1024 on:",
          sorted({x["desc"] for c in R["parmaj"]["cells"] if c["n"] >= 1024 for x in c["terms"]
                  if x["kind"] == "sum" and x["fold"] and x["cat"] == "T"}))
    for n in (512, 1024):
        for x in cell("majxor", n)["terms"]:
            if x["kind"] == "quad":
                u = np.asarray(x["u"]); cs = []
                for sg in (1, -1):
                    w = np.zeros(30); w[:5] = 1; w[5:10] = sg; cs.append(abs(u @ w) / np.linalg.norm(u) / np.linalg.norm(w))
                print(f"   majxor@{n} quad w {x['w']:+.3f} share {x['share']:.4f} mass {x['mass_rel']}: cos with 1_A+1_B "
                      f"{cs[0]:.3f}, with 1_A-1_B {cs[1]:.3f}; error {cell('majxor', n)['err']:.4f}")

    print("== thr30@16384 sum terms (start of desc, category, share, product, modulated):",
          [(x["desc"][:28] + "...", x["cat"], round(x["share"], 3), x["product"], bool(x["mod"]))
           for x in cell("thr30", 16384)["terms"] if x["kind"] == "sum"])
    print("== f7_06@2048 sum terms:", [(x["desc"], x["cat"]) for x in cell("f7_06", 2048)["terms"] if x["kind"] == "sum"],
          M.rep_line(cell("f7_06", 2048)))
    print("== rf06 / hrf0 test error at 128, 256:", [(t, n, round(cell(t, n)["err"], 4)) for t in ("rf06", "hrf0") for n in (128, 256)])
    print("   rf06 S share (fraction of the output sd) at 128, 256:",
          [cell("rf06", n)["summary"]["categories"]["S"]["share"] for n in (128, 256)])
    print("== dlist8: compact representation and error by n:", [(c["n"], M.rep_line(c), round(c["err"], 4)) for c in R["dlist8"]["cells"]])
    print("== f7_03: test error by n:", [(c["n"], round(c["err"], 4)) for c in R["f7_03"]["cells"]])
    print("== cnf3@256 sum terms (clauses: x1|x2|x3, ~x4|x5|x6, x7|~x8|x9):",
          [(x["desc"], x["cat"]) for x in cell("cnf3", 256)["terms"] if x["kind"] == "sum"])
    print("== sym9 characters by degree, 4096-16384:", [(n, cell("sym9", n)["summary"]["chars_by_degree"]) for n in (4096, 8192, 16384)])
    print("== majmaj5 characters by degree, 2048-16384:", [(n, cell("majmaj5", n)["summary"]["chars_by_degree"]) for n in (2048, 4096, 8192, 16384)])
    print("== weighted target blocks at 16384:")
    for t in ("f7_07", "f7_09", "symand", "f7_03", "f7_11", "f7_00"):
        print(f"   {t}:", [x["desc"] for x in cell(t, 16384)["terms"] if x["kind"] == "sum" and x["inner"]])
    print("   f7_00 (s1 = x1+x2-x3-x4, s2 = -x5-x6-x7+x8+x9+x10+x11), weighted block category and share:",
          [(x["desc"], x["cat"], round(x["share"], 3)) for x in cell("f7_00", 16384)["terms"] if x["kind"] == "sum" and x["inner"]])

    print("== first fit: DFG error - oracle error, largest five (err, oracle, err without background)")
    gaps = []
    for t in ORDER:
        n = first_fit(t)
        if n is not None:
            c = cell(t, n); s = c["summary"]
            gaps.append((c["err"] - s["oracle_err"], t, n, c["err"], s["oracle_err"], s["err_parts"]["no_bg"]))
    gaps.sort(reverse=True)
    print(f"   median gap {np.median([g[0] for g in gaps]):.5f}")
    for g in gaps[:5]:
        print("   %.4f %s@%d err %.4f oracle %.4f no_bg %.4f" % g)

    print("== cells with test error > 0.1: dictionary-limited (oracle > 0.1) where DFG's own error is > 0.05 below the oracle")
    dic = [(t, c["n"], c["err"], c["summary"]["oracle_err"], c["summary"]["err_parts"]["no_bg"])
           for t in ORDER for c in R[t]["cells"] if c["err"] > 0.1 and c["summary"]["oracle_err"] > 0.1]
    below = [d for d in dic if d[2] < d[3] - 0.05]
    print(f"   {len(below)} of {len(dic)}; without the background still > 0.05 below: "
          f"{sum(1 for d in below if d[4] < d[3] - 0.05)}")
    print("   the cells:", [f"{d[0]}@{d[1]}" for d in below])

    print("== spurious terms at the first fit")
    S = [(cell(t, first_fit(t))["summary"]["categories"]["S"]["share"], t) for t in ORDER if first_fit(t)]
    ch = max((abs(cell(t, first_fit(t))["summary"]["err_parts"]["no_S"] - cell(t, first_fit(t))["err"]), t) for t in ORDER if first_fit(t))
    print(f"   S share > 0.1 in {sum(v > 0.1 for v, _ in S)} of {len(S)}; at 16384 in "
          f"{sum(cell(t, 16384)['summary']['categories']['S']['share'] > 0.1 for t in ORDER)} of {len(ORDER)}; "
          f"largest change of the error when removed: {ch[0]:.4f} ({ch[0] * 4096:.0f}/4096, {ch[1]})")

    print("== spurious sum terms at the first n of a block (shares)")
    for t, n in (("f7_06", 128), ("f7_03", 256), ("symand", 128), ("rf06", 128), ("rf06", 256)):
        print(f"   {t}@{n}:", [(x["desc"], round(x["share"], 2)) for x in cell(t, n)["terms"] if x["kind"] == "sum" and x["cat"] == "S"])
    lin64 = [t for t in ORDER if cell(t, 64)["summary"]["linear_block_round"] is not None]
    print(f"== linear block in the n = 64 model: {lin64}; S-lin there:", {t: round(cell(t, 64)["S_lin"]["share"], 2) for t in lin64})
    print("== linear_uncertain cells:", sum(c["linear_uncertain"] for t in ORDER for c in R[t]["cells"]),
          "; h5s7@16384:", cell("h5s7", 16384)["linear_uncertain"], round(cell("h5s7", 16384)["S_lin"]["share"], 4))
    print("== background at the mod-3 counts, n = 16-32 (err with, without):",
          [(t, n, round(cell(t, n)["err"], 3), round(cell(t, n)["summary"]["err_parts"]["no_bg"], 3)) for t in ("f7_05", "h6_00") for n in (16, 32)])
    B = M.below_structure(R)
    print(f"== below the first complete n: {len(B)} cells, a true character in {sum(b['true_chars'] > 0 for b in B)}")

    d = json.load(open(os.path.join(HERE, "results", "cv", "forced_vs_default.json")))
    ce = np.array([x[x["chosen"]]["err"] for x in d]); de = np.array([x["default"]["err"] for x in d])
    fe = np.array([x["forced"]["err"] for x in d])
    print(f"== CV means: chosen {ce.mean():.4f}, forced {fe.mean():.4f}, better of the two {np.minimum(de, fe).mean():.4f}"
          f" (chosen - better {ce.mean() - np.minimum(de, fe).mean():.4f})")

    print("== completeness by n (C = a compact representation complete) and test-error rises after the first fit")
    for t in ORDER:
        pat = "".join("C" if complete(c) else "." for c in R[t]["cells"])
        if "C" in pat and "." in pat[pat.index("C"):]:
            print(f"   {t:7s} {pat}")
    for t in ORDER:
        cs, f = R[t]["cells"], first_fit(t)
        for a, b in zip(cs, cs[1:]):
            if f is not None and a["n"] >= f and b["err"] > a["err"]:
                print(f"   {t} {a['n']} -> {b['n']}: {a['err']:.4f} -> {b['err']:.4f}")

    print("== f7_09: (n, model size, chi[x11,x12] present, block modulated by chi[x11,x12] present)")
    print("  ", [(c["n"], c["size"], any(x["kind"] == "chi" and x["S"] == [10, 11] for x in c["terms"]),
                 any(x["kind"] == "sum" and x["mod"] == [10, 11] for x in c["terms"])) for c in R["f7_09"]["cells"][:6]])

    print("== DFG alone against v3's DFG member (Part 10)")
    rows = []
    for t in ORDER:
        s = json.load(open(os.path.join(P10V3, f"{R[t]['suite']}__{t}__s0.json"))); mine = {c["n"]: c for c in R[t]["cells"]}
        for c10 in s["cells"]:
            n = c10["n"]
            if n not in mine or "terms" not in c10:
                continue
            w = c10["weights"]; w = ast.literal_eval(w) if isinstance(w, str) else w
            rows.append(dict(t=t, n=n, a=mine[n]["err"], v=c10.get("err_dfg"), oof=not c10["dfg_source"].startswith("final"),
                             kf=w.get("dfg_forced", 0) > 0, var=mine[n]["variant"]))
    dif = [r for r in rows if r["a"] != r["v"]]
    kind = lambda r: "out-of-fold" if r["oof"] else "variant" if (r["kf"] and r["var"] == 0) else "same variant"
    print(f"   common {len(rows)}, differing {len(dif)} (alone lower in {sum(r['a'] < r['v'] for r in dif)}):",
          dict(Counter(kind(r) for r in dif)), "; n <= 64:", dict(Counter(kind(r) for r in dif if r["n"] <= 64)),
          "; out-of-fold by n:", dict(Counter("<=64" if r["n"] <= 64 else "128-512" if r["n"] <= 512 else ">512" for r in dif if r["oof"])))
    fin = [r for r in dif if not r["oof"]]
    print(f"   against a final v3 member: alone lower in {sum(r['a'] < r['v'] for r in fin)} of {len(fin)}")
    print("   'variant' cells by n:", dict(sorted(Counter(r["n"] for r in dif if kind(r) == "variant").items())),
          "; 'same variant' cells (alone's variant, v3 kept forced):",
          [(r["t"], r["n"], "forced" if r["var"] else "default", r["kf"]) for r in dif if kind(r) == "same variant"])
    for suite, t, n in (("dlheld7", "f7_06", 64), ("dlheld", "mux6", 128), ("designed", "maj9", 64)):
        c10 = next(c for c in json.load(open(os.path.join(P10V3, f"{suite}__{t}__s0.json")))["cells"] if c["n"] == n)
        print(f"   v3 {t}@{n}: {c10['dfg_source'][:40]}, err {c10['err_dfg']:.4f}, terms {c10['n_terms']}, blocks",
              [x.get("desc") for x in c10["terms"] if x["kind"] == "sum"], ", characters (top terms)",
              [H.chi_desc(x["S"]) for x in c10["terms"] if x["kind"] == "chi" and x["S"]])
    s = json.load(open(os.path.join(P10V3, "dlheld__majmaj5__s0.json")))
    print("   majmaj5 in v3 (n, err, [(class, matched exactly)]):",
          [(c["n"], c.get("err_dfg"), [("x%d..x%d" % (x["S"][0] + 1, x["S"][-1] + 1), x["exact"]) for x in c["classes"]])
           for c in s["cells"] if c["n"] >= 1024])
    for suite, t in (("dlheld7", "f7_05"), ("dlheld6", "h6_00")):
        s = json.load(open(os.path.join(P10V3, f"{suite}__{t}__s0.json")))
        print(f"   {t} in v3 (n, final or out-of-fold, kinds of the non-constant terms besides the background):",
              [(c["n"], "final" if c["dfg_source"].startswith("final") else "oof",
                [x["kind"] for x in c["terms"] if x["kind"] not in ("const", "background")]) for c in s["cells"]])
    sp6 = importlib.util.spec_from_file_location("heldout6_suite", os.path.join(H.STUDY, "part9", "heldout6", "suite.py"))
    S6 = importlib.util.module_from_spec(sp6); sp6.loader.exec_module(S6)
    print("== h6_10 (identity sample only):", next(d["form"] for d in S6.heldout6_draw_log() if d["name"] == "h6_10"))

    if "--refit" in sys.argv:
        rec = H.fit_toy_dfg("dlheld7", "f7_11", 128, 0)
        X = test_inputs("f7_11"); wrong = np.where(rec["value_te"] > 0, 1.0, -1.0) != rec["yte"]
        s2 = -X[:, 4] - X[:, 5] + X[:, 6] - X[:, 7] - X[:, 8] + X[:, 9]
        m = (X[:, 10] > 0) & (np.abs(s2) == 6)           # branch 2 selected (-x11 = -1) and |s2| = 6
        print(f"== f7_11@128 refit: error {rec['err']}, {int(wrong.sum())} test errors, {int((wrong & m).sum())} of them where "
              f"branch 2 is selected and |s2| = 6 ({int(m.sum())} such inputs, {m.mean():.4f}); identity {H.check_identity(rec)}")


if __name__ == "__main__":
    main()
