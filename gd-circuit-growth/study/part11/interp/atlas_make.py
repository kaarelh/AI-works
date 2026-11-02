"""Part 11 structure atlas, step 2: tables, figures and the identity check, from results/atlas/*.json (atlas_run.py) and
results/identity/*.json (identity_run.py).  Reads only files; no fits.

Writes
  tables/atlas_cells.csv        every (target, n) cell of the atlas fits (seed 0, n = 16 ... 16384)
  tables/atlas_targets.csv      one row per target: its representation, n* (DFG alone, seed 0 and 3 seeds), first n with
                                the target's compact representation complete, Part 10's v3 numbers for the same target
  tables/atlas.json             per target: spec summary and the selected cells with their model descriptions
  tables/atlas.md               per family: per target the selected cells (n just below / above n*_0, ~4 n*_0, 16384;
                                256, 1024, 4096, 16384 where n*_0 is never) with a one-line model description
  tables/p10_compare.csv/.md    DFG alone against v3's DFG member (Part 10, part10/interp/results/toy_final/v3), per cell
  tables/identity.json/.md      refits (atlas + identity sample) against the merged evaluation files
  figures/fig_atlas_grid.pdf    test error by (target, n), with the cells where a compact representation is complete
  figures/fig_atlas_p10.pdf     DFG alone vs v3's DFG member: test error per cell, first n with the exact structure
Model description key (atlas.md): T = target term, R = relevant non-target term, S = spurious (reads an irrelevant
input), S-lin = irrelevant degree-1 characters that entered through the linear block; '~' = class-exact block with a
coupling term the truth does not have (an inner term or modulator on relevant inputs); 'inner!' = weighted target's
block without the right inner term; numbers = share (sd of the term's contribution over the test inputs; for a group
of characters sqrt of the sum of their squared shares, the sd of their sum since distinct characters are orthogonal)."""
import os, sys, json, glob, csv, math, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import dfg_hooks as H                                                  # noqa: E402
import atlas_truth as A                                                # noqa: E402

TH = H.TH; NS = TH.NS; STUDY = H.STUDY
ATL = os.path.join(HERE, "results", "atlas"); IDN = os.path.join(HERE, "results", "identity")
TAB = os.path.join(HERE, "tables"); FIG = os.path.join(HERE, "figures")
P10 = os.path.join(STUDY, "part10", "interp")
SCR = TH.SCR
GROUPS = [
    ("Parities", ["par2", "par4", "par5"]),
    ("Staircases", ["stair5", "stair6"]),
    ("Multiplexers (address and data bits)", ["mux6", "mux11"]),
    ("Majorities and halfspaces", ["maj9", "thrint", "thr30", "f7_01"]),
    ("Compositions", ["majpar", "majpar5", "parmaj", "majxor", "majmaj5", "andxor"]),
    ("DNF, CNF, decision lists, read-once formulas", ["cnf3", "f7_02", "dlist8", "f7_04", "f7_06"]),
    ("Random formulas", ["rf06", "hrf0"]),
    ("Symmetric and pure signed-sum targets", ["sym9", "band11", "f7_08", "h5s7", "f7_05", "h6_00"]),
    ("Signed-sum mixtures", ["f7_07", "f7_09", "symand", "f7_10", "f7_00", "f7_03", "f7_11"]),
]


def fx(i):
    return f"x{i + 1}"


def load_atlas():
    R = {}
    for p in sorted(glob.glob(os.path.join(ATL, "*.json"))):
        r = json.load(open(p)); R[r["target"]] = r
        for c in r["cells"]:
            fix_linear_flags(c); fix_coupled(c, r["spec"]); c["summary"]["reps"] = rep_status(c, r["spec"])
    return R


def fix_linear_flags(c):
    """Degree-1 characters of irrelevant inputs present after the linear block was accepted (it adds every input not yet
    in the model) and not in any round's list of individually accepted characters are attributed to the linear block.
    DFG's log lists the first 20 accepted characters per round, so with more than 20 in a round an individually
    accepted irrelevant input could hide among them ('linear_uncertain')."""
    lin = any("linear" in e["blocks"] for e in c["log"]); listed = {d_ for e in c["log"] for d_ in e["new"]}
    c["linear_uncertain"] = lin and any(e["n_new"] > 20 for e in c["log"])
    sh = []
    for t in c["terms"]:
        if t["kind"] == "chi" and t["deg"] == 1:
            t["via_linear"] = bool(lin and t["desc"] not in listed)
            if t["cat"] == "S" and t["via_linear"]:
                sh.append(t["share"])
    tot = c["summary"]["categories"]
    c["S_lin"] = dict(n=len(sh), share=math.sqrt(sum(v * v for v in sh)) / max(_model_sd(c), 1e-12))


def _model_sd(c):
    """sd of the model value over the test inputs (stored by atlas_run as summary.value_sd)."""
    return c["summary"]["value_sd"]


def _fvs(fac, tb):
    """atlas_run.factor_vs: a block factor against a true block (None if the input sets differ)."""
    if fac["S"] != tb["S"]:
        return None
    sig = [v * fac["signs"][0] for v in fac["signs"]] == [v * tb["signs"][0] for v in tb["signs"]]
    flip = fac["signs"][0] * tb["signs"][0]; fold_ok = (not fac["fold"]) or tb["even"]
    ti, fi = tb["inner"], fac.get("inner")
    if ti is None:
        inner_ok, extra = fi is None, fi is not None
    elif fi is None:
        inner_ok, extra = False, False
    else:
        same = fi["kind"] == ti["kind"] and (sorted(zip(fi["inputs"], fi["signs"])) == sorted(zip(ti["inputs"], ti["signs"]))
                                             if fi["kind"] == "and" else sorted(fi["inputs"]) == sorted(ti["inputs"]))
        inner_ok, extra = bool(same and fi["a"] * flip == ti["a"]), False
    return dict(exact=bool(sig and fold_ok), inner_ok=inner_ok, extra_inner=extra)


def fix_coupled(c, spec):
    """Recompute the 'coupled' flag of every sum term against ALL true blocks with its set and signs (a multiplexer's
    address blocks come in pairs that are global sign flips of each other, told apart by their modulators)."""
    tb = [b for r in spec["reps"] for b in r.get("blocks", [])]
    for t in c["terms"]:
        if t["kind"] != "sum" or not t.get("exact_factor"):
            continue
        extra = False; mod_ok = not t["mod"]
        for q, fac in enumerate(t["factors"]):
            cands = [(b, _fvs(fac, b)) for b in tb]
            cands = [(b, v) for b, v in cands if v is not None and v["exact"]]
            if cands and all(v["extra_inner"] for _, v in cands):
                extra = True
            if q == 0 and t["mod"] and any(b["mod"] == t["mod"] for b, _ in cands):
                mod_ok = True
        t["coupled"] = bool(extra or not mod_ok)


def rep_status(c, spec):
    """Which compact representations of the target are complete in the model (recomputed from the stored terms):
    characters: present, with the sign of the representation's coefficient; blocks: a factor of some sum term
    (additive, modulated, or one factor of a product) has the true block's set and signs (up to a global flip; folded
    only for an even accept set), the true inner term for a weighted target and NO inner term otherwise (u = t + a tau
    is a different statistic), and the true modulator for a modulated target; or a product's unfolded factors partition
    the true block.  found_in: the category of the term that holds it (T; R = inside a product with a non-exact
    relevant factor; S = inside a product with an irrelevant factor)."""
    out = []
    chars = {tuple(t["S"]): t for t in c["terms"] if t["kind"] == "chi"}
    tb = [b for r in spec["reps"] for b in r.get("blocks", [])]
    for r in spec["reps"]:
        o = dict(name=r["name"], aux=bool(r.get("aux")))
        ok = []
        if r.get("chars"):
            C = {tuple(S): v for S, v in r["chars"] if S}
            pres = [S for S in C if S in chars]
            o.update(n=len(C), present=len(pres), sign_ok=sum(1 for S in pres if np.sign(chars[S]["w"]) == np.sign(C[S])),
                     weight=round(sum(C[S] ** 2 for S in pres) / max(sum(v * v for v in C.values()), 1e-12), 4))
            ok.append(o["present"] == o["n"])
        if r.get("blocks"):
            found = []
            for b in r["blocks"]:
                j = tb.index(b); where = None
                for t in c["terms"]:
                    if t["kind"] != "sum":
                        continue
                    if t.get("partition") == j and b["inner"] is None and not b["mod"]:
                        where = t["cat"] if where is None else where
                    for q, fac in enumerate(t["factors"]):
                        m = _fvs(fac, b)                              # the factor's own statistic must be the true
                        if m is not None and m["exact"] and m["inner_ok"] and \
                                (not b["mod"] or (q == 0 and t["mod"] == b["mod"])):   # one: inner term right or absent
                            rank = {"T": 0, "R": 1, "S": 2}[t["cat"]]
                            if where is None or rank < {"T": 0, "R": 1, "S": 2}[where]:
                                where = t["cat"]
                found.append(where)
            o.update(blocks=len(found), found=sum(f is not None for f in found), found_in=found)
            ok.append(all(f is not None for f in found))
        if r.get("quad"):
            ok.append(sum(1 for t in c["terms"] if t.get("quad_match")) >= 2)
            o["quad"] = True
        o["complete"] = bool(ok) and all(ok) and not o["aux"]               # auxiliary representations never count
        out.append(o)
    return out


# ------------------------------------------------------------------------------------------------ n* and references
def nstar0(r):
    e = {c["n"]: c["err"] for c in r["cells"]}
    return TH.nstar(NS, [e.get(n, np.nan) for n in NS]) if all(n in e for n in NS) else float("nan")


def merged(suite, name="dfg13-perm"):
    p = os.path.join(H.RESULTS, f"toy__{name}__{suite}.json")
    return json.load(open(p)) if os.path.exists(p) else None


def nstar3(suite, target):
    R = merged(suite)
    if R is None or target not in R["fns"]:
        return None
    return TH.nstar(R["ns"], np.nanmean(np.array(R["fns"][target]["err"], float), 1))


NET_SUF = [("nets", ""), ("nets_wd", "_wd0.1"), ("nets_cewd", "_cewd0.1"), ("nets_cewd0.3", "_cewd0.3"), ("nets_cewd1.0", "_cewd1.0")]


def nets_best(suite, target):
    """compare_hybrid.toy_nstars's nets_best (the per-target smallest n* of the network variants present), recomputed
    from the networks' result files; also over dlheld7's variants (it has no plain 'nets' run)."""
    out = {}
    for nm, suf in NET_SUF:
        d = os.path.join(SCR, ("results" if suite == "designed" else "results_" + suite) + suf)
        p = os.path.join(d, f"fixed_adam_{target}.npz")
        if os.path.exists(p):
            e = TH.nn_reference(target, d); out[nm] = TH.nstar(NS, np.nanmean(e, 1))
    return (min(out.values()) if out else None), sorted(out)


def p10_rows():
    rows = {}
    for f in ("toy_recovery_v3.csv", "toy_nonsum_v3.csv"):
        for r in csv.DictReader(open(os.path.join(P10, "tables", f))):
            rows[r["target"]] = r
    return rows


def _num(v):
    """A number from Part 10's CSV tables ('' or '–' = none, 'inf' / 'never' = never)."""
    if v in (None, "", "–", "-"):
        return None
    if v in ("never",):
        return float("inf")
    try:
        return float(v)
    except ValueError:
        return None


def p10_struct(suite, target):
    p = os.path.join(P10, "results", "toy_final", "v3", f"{suite}__{target}__s0.json")
    return json.load(open(p)) if os.path.exists(p) else None


# ------------------------------------------------------------------------------------------------ cell selection
def select_ns(r):
    e = {c["n"]: c["err"] for c in r["cells"]}
    first = next((n for n in NS if e.get(n, 1) <= 0.1), None)
    if first is None:
        return [256, 1024, 4096, 16384], None
    ns = []
    i = NS.index(first)
    if i > 0:
        ns.append(NS[i - 1])
    ns.append(first)
    s0 = nstar0(r); q = int(round(math.log2(4 * s0))) if np.isfinite(s0) else None
    if q is not None:
        n4 = 2 ** min(max(q, 4), 14)
        if n4 not in ns:
            ns.append(n4)
    if 16384 not in ns:
        ns.append(16384)
    return sorted(set(ns)), first


# ------------------------------------------------------------------------------------------------ model description
def term_str(t, spec):
    fl = ""
    if t["kind"] == "sum":
        if t.get("coupled"):
            fl += "~"
        tb = [b for rp in spec["reps"] for b in rp.get("blocks", [])]
        if t.get("exact_factor") and any(b["inner"] for b in tb) and not t.get("inner_ok"):
            fl += " inner!"
        d = t["desc"]
    elif t["kind"] == "quad":
        d = f"quad[{len(t['S'])} inputs, {t['mass_rel']:.2f} on rel]" + (f" ~{t['quad_match']}" if t.get("quad_match") else "")
    else:
        rc = {tuple(S) for r in spec["reps"] if r.get("chars") and not r.get("fourier") for S, _ in r["chars"]}
        d = t["desc"] + (" (sign!)" if t.get("sign_ok") is False and tuple(t["S"]) in rc else "")
    cat = t["cat"] if t["cat"] != "S" or not t.get("exact_factor") else "S(true block x irrelevant)"
    return f"{cat}{fl} {d} {t['share']:.2f}"


def model_line(c, spec, kmax=6):
    """One line: every block and spectral feature, characters by (category, degree) group, the largest characters."""
    terms = c["terms"]; out = []
    big = [t for t in terms if t["kind"] in ("sum", "quad")]
    for t in big[:kmax]:
        out.append(term_str(t, spec))
    if len(big) > kmax:
        out.append(f"+{len(big) - kmax} more blocks/quad (largest {big[kmax]['share']:.2f})")
    G = {}
    for t in terms:
        if t["kind"] != "chi":
            continue
        cat = "S-lin" if (t["cat"] == "S" and t.get("via_linear")) else t["cat"]
        G.setdefault((cat, t["deg"]), []).append(t)
    for (cat, dg), L in sorted(G.items(), key=lambda kv: -math.sqrt(sum(t["share"] ** 2 for t in kv[1]))):
        sh = math.sqrt(sum(t["share"] ** 2 for t in L))
        if len(L) <= 3 and cat != "S-lin":
            out.append("; ".join(term_str(t, spec) for t in L))
        else:
            top = max(L, key=lambda t: t["share"])
            rc = {tuple(S) for r in spec["reps"] if r.get("chars") and not r.get("fourier") for S, _ in r["chars"]}
            bad = sum(1 for t in L if t.get("sign_ok") is False and tuple(t["S"]) in rc)
            out.append(f"{cat} {len(L)} deg-{dg} chars {sh:.2f} (largest {top['desc']} {top['share']:.2f}"
                       + (f"; {bad} with the wrong sign" if bad else "") + ")")
    bg = [t for t in terms if t["kind"] == "background"][0]
    if bg["share"] >= 0.05:
        out.append(f"background {bg['share']:.2f}")
    return "; ".join(out) if out else "constant only"


def model_short(c, spec, k=3):
    """The k largest terms (category, description, share) and a count of the rest."""
    T = [t for t in c["terms"] if t["kind"] not in ("const", "background")]
    out = [term_str(t, spec) for t in T[:k]]
    rest = T[k:]
    if rest:
        nc = sum(t["kind"] == "chi" for t in rest); nb = len(rest) - nc
        out.append(f"+{nc} chars" + (f", +{nb} blocks/quad" if nb else ""))
    return "; ".join(out) if out else "constant only"


def rep_line(c):
    o = []
    for rp in c["summary"]["reps"]:
        part = []
        if "present" in rp:
            part.append(f"{rp['present']}/{rp['n']} chars" + (f" ({rp['sign_ok']} right sign)" if rp["sign_ok"] != rp["present"] else ""))
        if "found" in rp:
            w = [f for f in rp["found_in"] if f]
            part.append(f"{rp['found']}/{rp['blocks']} {'class ' if rp['aux'] else ''}blocks" +
                        ("" if all(f == "T" for f in w) else " (" + ",".join(f or "-" for f in rp["found_in"]) + ")"))
        if rp.get("quad"):
            part.append("quad pair" if rp.get("complete") else "no quad pair")
        o.append(" + ".join(part))
    return ", ".join(o)


def cv_str(c):
    if c["cv_errs"] is None:
        return "default (no CV, n > 512)"
    return ("forced" if c["variant"] == 1 else "default") + f" (CV errors {c['cv_errs'][0]} / {c['cv_errs'][1]})"


def spec_line(sp):
    W = sp.get("W"); o = []
    for rp in sp["reps"]:
        s = rp["name"]
        if rp.get("blocks"):
            bs = []
            for b in rp["blocks"]:
                t = "".join(("+" if v > 0 else "-") + fx(i) for i, v in zip(b["S"], b["signs"])).lstrip("+")
                if b["inner"]:
                    inn = b["inner"]
                    tau = fx(inn["inputs"][0]) if inn["kind"] == "lit" else "".join(fx(i) for i in inn["inputs"]) if inn["kind"] != "and" else \
                        "AND(" + ",".join(("" if sg > 0 else "-") + fx(i) for i, sg in zip(inn["inputs"], inn["signs"])) + ")"
                    t += f" {inn['a']:+d}*{tau}"
                m = (f"chi[{','.join(fx(i) for i in b['mod'])}]*" if b["mod"] else "")
                acc = b["accept"]
                bs.append(f"{m}({t}) accept {{{','.join(str(v) for v in acc)}}}" + (" [even]" if b["even"] else ""))
            s += ": " + " ; ".join(bs)
        if rp.get("chars") and not rp.get("fourier"):
            C = [S for S, v in rp["chars"] if S]
            if len(C) <= 8:
                s += ": " + ", ".join(("chi[" + ",".join(fx(i) for i in S) + "]") for S in C)
            else:
                dg = {}
                for S in C:
                    dg[len(S)] = dg.get(len(S), 0) + 1
                s += f": {len(C)} characters (by degree {dict(sorted(dg.items()))})"
        if rp.get("fourier"):
            s += f": {sp['n_fourier']} characters"
        o.append(s)
    w = "" if W is None else " | Fourier weight by degree " + " ".join(f"{v:.2f}" for v in W[1:min(len(W), 8)])
    cp = "" if not sp["couple"] else f" | coupling inputs {', '.join(fx(i) for i in sp['couple'])}"
    return " || ".join(o) + cp + w


# ------------------------------------------------------------------------------------------------ Part 10 comparison
def term_key(t):
    if t["kind"] == "chi":
        return ("chi", tuple(sorted(t["S"])))
    if t["kind"] == "sum":
        facs = tuple((tuple(f["S"]), tuple(int(s * f["signs"][0]) for s in f["signs"])) for f in t["factors"])
        inn = t.get("inner"); s0 = t["factors"][0]["signs"][0] if t["factors"][0]["signs"] else 1
        # the inner coefficient relative to the block's global sign (u = t + a tau and -t - a tau are the same block)
        ik = None if not inn else (inn["kind"], tuple(sorted(inn["inputs"])), int(inn["a"]) * int(s0))
        return ("sum", facs, bool(t["fold"]), tuple(t.get("mod") or ()), ik)
    return None


def p10_compare(R):
    rows, per = [], {}
    for name, r in R.items():
        s = p10_struct(r["suite"], name)
        if s is None:
            continue
        mine = {c["n"]: c for c in r["cells"]}
        for c10 in s["cells"]:
            n = c10["n"]; c = mine.get(n)
            if c is None or "terms" not in c10:
                continue
            k10 = [term_key(t) for t in c10["terms"] if t["kind"] in ("chi", "sum")]
            topn = len(c10["terms"])
            km = [term_key(t) for t in c["terms"][:topn] if t["kind"] in ("chi", "sum")]
            a, b = set(k10), set(km)
            ex10 = [x["exact"] for x in c10.get("classes", [])]
            rows.append(dict(suite=r["suite"], target=name, n=n, err_alone=c["err"], err_v3_dfg=c10.get("err_dfg"),
                             err_v3=c10["err"], v3_source=c10.get("dfg_source"), w_dfg=c10.get("w_dfg"),
                             jaccard_top=round(len(a & b) / len(a | b), 3) if (a | b) else 1.0,
                             same_err=c10.get("err_dfg") == c["err"],
                             struct_alone=all(c["summary"]["p10_classes"]) if c["summary"]["p10_classes"] else None,
                             struct_v3=all(ex10) if ex10 else None, variant_alone=c["variant"]))
        st = [c["n"] for c in r["cells"] if c["summary"]["p10_classes"] and all(c["summary"]["p10_classes"])]
        st10 = [c["n"] for c in s["cells"] if c.get("classes") and all(x["exact"] for x in c["classes"] if len(x["S"]) >= 3)
                and any(len(x["S"]) >= 3 for x in c["classes"])]
        per[name] = dict(n_struct_alone=st[0] if st else None, n_struct_v3=st10[0] if st10 else None,
                         n_max_v3=max(c["n"] for c in s["cells"]))
    return rows, per


# ------------------------------------------------------------------------------------------------ identity
def identity_all(R):
    """Every refit cell (atlas + identity sample) against the merged evaluation file of its suite, where it exists."""
    cells = []
    for name, r in R.items():
        for c in r["cells"]:
            cells.append((r["suite"], name, c["n"], c["err"], c["flops"]))
    for p in sorted(glob.glob(os.path.join(IDN, "*.json"))):
        r = json.load(open(p))
        for c in r["cells"]:
            cells.append((r["suite"], r["target"], c["n"], c["err"], c["flops"]))
    out = {}
    for suite in sorted(set(s for s, *_ in cells)):
        Rm = merged(suite)
        sc = [x for x in cells if x[0] == suite]
        o = dict(file=Rm is not None, targets=sorted(set(x[1] for x in sc)), cells=len(sc))
        if Rm is not None:
            eq_e = eq_f = cmp_ = 0; bad = []
            for _, t, n, e, f in sc:
                rr = Rm["fns"].get(t)
                if rr is None:
                    continue
                a = Rm["ns"].index(n); b = Rm["seeds"].index(0); cmp_ += 1
                eq_e += rr["err"][a][b] == e; eq_f += rr["flops"][a][b] == f
                if rr["err"][a][b] != e or rr["flops"][a][b] != f:
                    bad.append([t, n, rr["err"][a][b], e])
            o.update(compared=cmp_, err_equal=eq_e, flops_equal=eq_f, mismatches=bad,
                     suite_targets=len(Rm["fns"]))
        out[suite] = o
    return out


# ------------------------------------------------------------------------------------------------ below the structure
def below_structure(R):
    """Cells below the first n with a complete compact representation (n_rep_first; targets that never get one: every
    cell): which variant DFG's own cross-validation chose and what the model holds."""
    rows = []
    for name, r in R.items():
        comp = [c["n"] for c in r["cells"] if any(rp.get("complete") for rp in c["summary"]["reps"])]
        nf = comp[0] if comp else None
        for c in r["cells"]:
            if nf is not None and c["n"] >= nf:
                continue
            cat = c["summary"]["categories"]
            chis = [t for t in c["terms"] if t["kind"] == "chi"]
            rows.append(dict(target=name, n=c["n"], err=c["err"], variant=c["variant"], cv=c["cv_errs"] is not None,
                             empty=c["size"] == 1, linear=c["summary"]["linear_block_round"] is not None,
                             n_T=cat["T"]["n"], n_S=cat["S"]["n"] - c["S_lin"]["n"], n_Slin=c["S_lin"]["n"],
                             blocks=c["summary"]["n_blocks"], true_chars=sum(t["cat"] == "T" for t in chis),
                             spur_chars=sum(t["cat"] == "S" and not t.get("via_linear") for t in chis),
                             T_share=cat["T"]["share"], S_share=cat["S"]["share"], never=nf is None))
    return rows


# ------------------------------------------------------------------------------------------------ family counts
def family_counts(R, J):
    """Per family group: the counts quoted in ATLAS.md's family summaries."""
    out = []
    for g, names in GROUPS:
        L = [t for t in names if t in R]
        if not L:
            continue
        o = dict(group=g, targets=len(L))
        s0 = [J[t]["nstar0_alone"] for t in L]
        o["nstar0"] = [None if not np.isfinite(v) else round(v) for v in s0]
        o["nstar3"] = [None if J[t]["nstar3_alone"] is None or not np.isfinite(J[t]["nstar3_alone"]) else round(J[t]["nstar3_alone"]) for t in L]
        o["never"] = [t for t, v in zip(L, s0) if not np.isfinite(v)]
        o["rep_first"] = {t: J[t]["n_rep_first"] for t in L}
        o["rep_stable"] = {t: J[t]["n_rep_stable"] for t in L}
        # at the first n with error <= 0.1 and at n = 16384
        at = {}
        for t in L:
            r = R[t]; e = {c["n"]: c for c in r["cells"]}
            first = next((n for n in NS if n in e and e[n]["err"] <= 0.1), None)
            for key, n in (("first", first), ("16384", 16384)):
                if n is None or n not in e:
                    continue
                c = e[n]; cat = c["summary"]["categories"]
                lead = next((x for x in c["terms"] if x["kind"] not in ("const", "background")), None)
                at.setdefault(key, {})[t] = dict(n=n, err=c["err"], complete=any(rp.get("complete") for rp in c["summary"]["reps"]),
                                                 T=cat["T"]["share"], R=cat["R"]["share"], S=cat["S"]["share"],
                                                 S_lin=round(c["S_lin"]["share"], 3), size=c["size"],
                                                 lead=None if lead is None else (lead["kind"], lead["desc"], lead["cat"], round(lead["share"], 2)),
                                                 blocks=c["summary"]["n_blocks"], quad=c["summary"]["n_quad"],
                                                 kinds=c["summary"]["block_kinds"], variant=c["variant"],
                                                 err_T=c["summary"]["err_parts"]["T_only"], err_noS=c["summary"]["err_parts"]["no_S"],
                                                 r2=c["summary"]["span_r2"], oracle=c["summary"]["oracle_err"])
        o["at"] = at
        # what limits the model where its test error is above 10%: the dictionary (the learned features cannot express
        # f: oracle sign error of the feature set > 0.1) or the readout (oracle error <= 0.02: the features suffice,
        # DFG's own weights do not), or in between
        lim = dict(readout=[], dictionary=[], between=[])
        for t in L:
            for c in R[t]["cells"]:
                if c["err"] > 0.1:
                    oe = c["summary"]["oracle_err"]
                    lim["readout" if oe <= 0.02 else "dictionary" if oe > 0.1 else "between"].append(f"{t}@{c['n']}")
        o["limits"] = lim
        cvc = [(c["n"], c["variant"]) for t in L for c in R[t]["cells"] if c["cv_errs"] is not None]
        o["cv_cells"] = len(cvc); o["forced_cells"] = sum(v for _, v in cvc)
        out.append(o)
    return out


# ------------------------------------------------------------------------------------------------ quirks
def quirks(R):
    """(a) duplicate blocks: two sum terms with the same set, signs (up to a global flip), fold, modulator, inner term and
    factors (DFG's block key keeps the input ORDER, so one block found twice in different orders is admitted twice);
    (b) spurious products: a product term one factor of which is a true block and another reads only irrelevant inputs."""
    dup, sprod = [], []
    for name, r in R.items():
        rel = set(r["spec"]["rel"])
        for c in r["cells"]:
            keys = {}
            for t in c["terms"]:
                if t["kind"] == "sum":
                    k = term_key(t); keys.setdefault(k, []).append(t["share"])
                    if t["product"] and any(m["exact"] for m in t["factor_match"]) and \
                            any(not (set(f["S"]) & rel) for f in t["factors"]):
                        sprod.append(dict(target=name, n=c["n"], desc=t["desc"], share=round(t["share"], 3), err=c["err"]))
            for k, v in keys.items():
                if len(v) > 1:
                    dup.append(dict(target=name, n=c["n"], copies=len(v), shares=[round(x, 3) for x in v]))
    return dup, sprod


# ------------------------------------------------------------------------------------------------ main
def write_csv(path, rows, cols):
    with open(path, "w", newline="") as f:
        w = csv.writer(f); w.writerow(cols)
        for r in rows:
            w.writerow([r.get(c, "") if not isinstance(r.get(c), (list, dict)) else json.dumps(r.get(c)) for c in cols])


def fmt(v, d=0):
    if v is None or (isinstance(v, float) and not np.isfinite(v)):
        return "never" if (isinstance(v, float) and v == float("inf")) else "–"
    return f"{v:.{d}f}"


def main():
    R = load_atlas(); P10R = p10_rows()
    order = [t for _, L in GROUPS for t in L]
    missing = [t for _, t in A.ATLAS if t not in R]
    # ---- per cell CSV
    crow = []
    for name in order:
        if name not in R:
            continue
        r = R[name]
        for c in r["cells"]:
            s = c["summary"]; cat = s["categories"]
            crow.append(dict(suite=r["suite"], target=name, family=r["spec"]["family"], n=c["n"], err=c["err"],
                             train_err=c["train_err"], variant=c["variant"], cv_err_default=(c["cv_errs"] or [None, None])[0],
                             cv_err_forced=(c["cv_errs"] or [None, None])[1], size=c["size"], rounds=c["rounds"],
                             flops_ratio=round(c["flops_ratio"], 4), chars_by_degree=s["chars_by_degree"],
                             n_blocks=s["n_blocks"], n_quad=s["n_quad"], block_kinds=s["block_kinds"],
                             linear_block_round=s["linear_block_round"],
                             **{f"{k}_n": cat[k]["n"] for k in ("T", "R", "S")},
                             **{f"{k}_share": cat[k]["share"] for k in ("T", "R", "S", "background")},
                             S_lin_n=c["S_lin"]["n"], S_lin_share=round(c["S_lin"]["share"], 4), linear_uncertain=c["linear_uncertain"],
                             err_T_only=s["err_parts"]["T_only"], err_no_S=s["err_parts"]["no_S"], err_no_bg=s["err_parts"]["no_bg"],
                             reps_complete=[rp.get("complete") for rp in s["reps"]], reps=rep_line(c),
                             fourier_weight=s["fourier_weight"], span_r2=s["span_r2"], oracle_err=s["oracle_err"],
                             p10_classes=s["p10_classes"], err_equal_file=c["identity"].get("err_equal"),
                             model=model_line(c, r["spec"])))
    write_csv(os.path.join(TAB, "atlas_cells.csv"), crow, list(crow[0].keys()))
    # ---- per target
    cmp_rows, cmp_per = p10_compare(R)
    trow, J = [], {}
    for g, L in GROUPS:
        for name in L:
            if name not in R:
                continue
            r = R[name]; sp = r["spec"]; cells = {c["n"]: c for c in r["cells"]}
            sel, first = select_ns(r)
            s0, s3 = nstar0(r), nstar3(r["suite"], name)
            nb, nbv = nets_best(r["suite"], name)
            comp = [c["n"] for c in r["cells"] if any(rp.get("complete") for rp in c["summary"]["reps"])]
            stab = None
            for n in NS:
                if n in cells and all(any(rp.get("complete") for rp in cells[m]["summary"]["reps"]) for m in NS if m >= n and m in cells):
                    stab = n; break
            p = P10R.get(name, {})
            W = sp["W"]
            row = dict(group=g, suite=r["suite"], target=name, family=sp["family"], k=sp["k"], desc=sp["desc"],
                       representation=spec_line(sp), W1=W[1] if W else None, W2=W[2] if W and len(W) > 2 else None,
                       nstar0_alone=s0, nstar3_alone=s3, nets_best=nb, nets_variants="+".join(nbv),
                       n_rep_first=comp[0] if comp else None, n_rep_stable=stab,
                       n_struct_p10rule_alone=cmp_per.get(name, {}).get("n_struct_alone"),
                       n_struct_p10rule_v3=cmp_per.get(name, {}).get("n_struct_v3"),
                       n_struct_v3_table=p.get("n_struct") or None, nstar3_v3=_num(p.get("nstar3")),
                       nstar_s0_v3=_num(p.get("nstar_s0")),
                       n_detect_p10=p.get("n_detect") or None, selected_ns=sel,
                       forced_cells=sum(1 for c in r["cells"] if c["variant"] == 1),
                       cv_cells=sum(1 for c in r["cells"] if c["cv_errs"] is not None))
            trow.append(row)
            J[name] = dict(row, cells=[dict(n=n, err=cells[n]["err"], train_err=cells[n]["train_err"], cv=cv_str(cells[n]),
                                            S_lin=cells[n]["S_lin"], linear_uncertain=cells[n]["linear_uncertain"],
                                            n_terms=sum(1 for t in cells[n]["terms"] if t["kind"] not in ("const", "background")),
                                            size=cells[n]["size"], rounds=cells[n]["rounds"],
                                            categories=cells[n]["summary"]["categories"], err_parts=cells[n]["summary"]["err_parts"],
                                            reps=rep_line(cells[n]), span_r2=cells[n]["summary"]["span_r2"],
                                            oracle_err=cells[n]["summary"]["oracle_err"],
                                            fourier_weight=cells[n]["summary"]["fourier_weight"],
                                            model=model_line(cells[n], sp), log=cells[n]["log"])
                                       for n in sel if n in cells])
    write_csv(os.path.join(TAB, "atlas_targets.csv"), trow, list(trow[0].keys()))
    json.dump(J, open(os.path.join(TAB, "atlas.json"), "w"), indent=1)
    # ---- markdown
    L = ["# Structure atlas: what DFG v1.3 alone learns (seed 0)", "",
         "Generated by `atlas_make.py` from `results/atlas/`. Key: see the docstring of `atlas_make.py` and ATLAS.md §0.", ""]
    for g, names in GROUPS:
        L += [f"## {g}", ""]
        for name in names:
            if name not in J:
                continue
            j = J[name]
            L += [f"### {name} ({j['suite']}): {j['desc']}", "",
                  f"*Representation in DFG's dictionary:* {j['representation']}", "",
                  f"n\\* DFG alone: seed 0 {fmt(j['nstar0_alone'])}, 3 seeds {fmt(j['nstar3_alone'])}; v3 (Part 10) 3 seeds "
                  f"{fmt(j['nstar3_v3'])}; networks (nets_best) {fmt(j['nets_best'])}. First n with a compact representation "
                  f"complete in the model: {fmt(j['n_rep_first'])} (from then on at every n: {fmt(j['n_rep_stable'])}). "
                  f"Exact structure by Part 10's rule: alone {fmt(j['n_struct_p10rule_alone'])}, v3 {fmt(j['n_struct_p10rule_v3'])}.", "",
                  "| n | err | train | variant (CV) | size (terms) | share T / R / S (S-lin) | complete | model |", "|---|---|---|---|---|---|---|---|"]
            for c in j["cells"]:
                cat = c["categories"]
                L.append(f"| {c['n']} | {c['err']:.4f} | {c['train_err']:.3f} | {c['cv']} | {c['size']} ({c['n_terms']}) | "
                         f"{cat['T']['share']:.2f} / {cat['R']['share']:.2f} / {cat['S']['share']:.2f} ({c['S_lin']['share']:.2f}) | "
                         f"{c['reps']} | {c['model']} |")
            L.append("")
    open(os.path.join(TAB, "atlas.md"), "w").write("\n".join(L) + "\n")
    # ---- compact per-family summary table
    F_ = ["# Atlas summary by family (seed 0): the model at the first n with test error <= 0.1 and at n = 16384", "",
          "Generated by `atlas_make.py`. Shares: sd of the term's contribution over the test inputs; T / R / S = target, "
          "relevant non-target, spurious terms (S-lin: irrelevant degree-1 characters from the linear block). "
          "`complete`: first n at which a compact representation is complete (and from which it stays complete).", ""]
    for g, names in GROUPS:
        F_ += [f"## {g}", "", "| target | n\\*_0 (n\\*_3) | complete from (stays) | first n <= 10%: err, variant, size, T/R/S (S-lin) | its leading terms | n = 16384: err, size, T/R/S | its leading terms |",
               "|---|---|---|---|---|---|---|"]
        for name in names:
            if name not in J:
                continue
            j = J[name]; r = R[name]; e = {c["n"]: c for c in r["cells"]}
            if 16384 not in e:
                continue
            first = next((n for n in NS if n in e and e[n]["err"] <= 0.1), None)
            def cs(c):
                k = c["summary"]["categories"]
                return f"{k['T']['share']:.2f}/{k['R']['share']:.2f}/{k['S']['share']:.2f} ({c['S_lin']['share']:.2f})"
            a = e.get(first); z = e[16384]
            F_.append(f"| {name} ({r['suite']}) | {fmt(j['nstar0_alone'])} ({fmt(j['nstar3_alone'])}) | {fmt(j['n_rep_first'])} ({fmt(j['n_rep_stable'])}) | "
                      + (f"n={first}: {a['err']:.3f}, {'forced' if a['variant'] else 'default'}, {a['size']}, {cs(a)} | {model_short(a, r['spec'])} | " if a else "never | – | ")
                      + f"{z['err']:.4f}, {z['size']}, {cs(z)} | {model_short(z, r['spec'])} |")
        F_.append("")
    open(os.path.join(TAB, "atlas_summary.md"), "w").write("\n".join(F_) + "\n")
    # ---- Part 10 comparison
    write_csv(os.path.join(TAB, "p10_compare.csv"), cmp_rows, list(cmp_rows[0].keys()) if cmp_rows else ["none"])
    M = ["# DFG alone against v3's DFG member (Part 10), seed 0, same (target, n)", "",
         "Cells: the (target, n) cells of Part 10's v3 structure runs (part10/interp/results/toy_final/v3/; those runs stop "
         "after two consecutive n with portfolio error <= 0.005, so they rarely reach n >= 4096). 'v3 member': the DFG "
         "model Part 10 summarised (the final DFG member; the forced variant when the stacker kept both; the last "
         "out-of-fold fit when it kept neither). Top-term Jaccard: overlap of the character and block terms among the "
         "terms Part 10 stored (its top 10) and as many of DFG alone's leading terms.", "",
         "| target | cells | same DFG test error | alone lower | v3 member lower | mean top-term Jaccard | n_struct (Part 10 rule) alone / v3 (v3's largest analysed n) |",
         "|---|---|---|---|---|---|---|"]
    for name in order:
        rr = [x for x in cmp_rows if x["target"] == name]
        if not rr:
            continue
        same = sum(x["same_err"] for x in rr); lo = sum(1 for x in rr if x["err_v3_dfg"] is not None and x["err_alone"] < x["err_v3_dfg"])
        hi = sum(1 for x in rr if x["err_v3_dfg"] is not None and x["err_alone"] > x["err_v3_dfg"])
        pc = cmp_per.get(name, {})
        M.append(f"| {name} | {len(rr)} | {same} | {lo} | {hi} | {np.mean([x['jaccard_top'] for x in rr]):.2f} | "
                 f"{fmt(pc.get('n_struct_alone'))} / {fmt(pc.get('n_struct_v3'))} ({pc.get('n_max_v3')}) |")
    open(os.path.join(TAB, "p10_compare.md"), "w").write("\n".join(M) + "\n")
    # ---- identity
    idt = identity_all(R)
    json.dump(idt, open(os.path.join(TAB, "identity.json"), "w"), indent=1)
    I = ["# Identity check: refits against the merged evaluation files (seed 0)", "",
         "| suite | merged file | targets refitted | cells compared | test error equal | FLOPs equal | targets in suite |", "|---|---|---|---|---|---|---|"]
    for s, o in idt.items():
        I.append(f"| {s} | {'yes' if o['file'] else 'not yet'} | {len(o['targets'])} | {o.get('compared', 0)} | {o.get('err_equal', '–')} | "
                 f"{o.get('flops_equal', '–')} | {o.get('suite_targets', '–')} |")
    open(os.path.join(TAB, "identity.md"), "w").write("\n".join(I) + "\n")
    json.dump(family_counts(R, J), open(os.path.join(TAB, "atlas_family.json"), "w"), indent=1)
    dq, sq = quirks(R)
    json.dump(dict(duplicate_blocks=dq, spurious_products=sq), open(os.path.join(TAB, "atlas_quirks.json"), "w"), indent=1)
    B = below_structure(R)
    write_csv(os.path.join(TAB, "atlas_below.csv"), B, list(B[0].keys()) if B else ["none"])
    figures(R, order, cmp_rows, cmp_per)
    print("missing targets:", missing)
    print(open(os.path.join(TAB, "identity.md")).read())


def figures(R, order, cmp_rows, cmp_per):
    import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
    names = [t for t in order if t in R]
    E = np.array([[next((c["err"] for c in R[t]["cells"] if c["n"] == n), np.nan) for n in NS] for t in names])
    fig, ax = plt.subplots(figsize=(8.2, 0.24 * len(names) + 1.6))
    im = ax.imshow(np.clip(E, 0, 0.5), aspect="auto", cmap="Greys", vmin=0, vmax=0.5)
    for i, t in enumerate(names):
        for j, n in enumerate(NS):
            c = next((c for c in R[t]["cells"] if c["n"] == n), None)
            if c is None:
                continue
            reps = c["summary"]["reps"]
            if any(rp.get("complete") for rp in reps):
                ax.plot(j, i, "o", color="tab:blue", ms=4.5)
            elif c["summary"]["span_r2"] >= 0.999:
                ax.plot(j, i, "s", color="tab:purple", ms=4)
            elif any((rp.get("found") or 0) > 0 or (rp.get("present") or 0) > 0 for rp in reps):
                ax.plot(j, i, "o", mfc="none", mec="tab:blue", ms=4.5)
            if c["variant"] == 1:
                ax.plot(j + 0.3, i - 0.3, "x", color="tab:red", ms=3.5)
        s0 = nstar0(R[t])
        if np.isfinite(s0):
            ax.plot(math.log2(s0) - 4, i, "|", color="tab:orange", ms=9, mew=2)
    ax.set_xticks(range(len(NS))); ax.set_xticklabels([str(n) for n in NS], rotation=45, fontsize=7)
    ax.set_yticks(range(len(names))); ax.set_yticklabels([f"{t} ({R[t]['suite']})" for t in names], fontsize=7)
    y = 0
    for g, L in GROUPS:
        k = sum(1 for t in L if t in R); y += k
        if y < len(names):
            ax.axhline(y - 0.5, color="tab:green", lw=0.6)
    ax.set_xlabel("training set size n"); cb = fig.colorbar(im, ax=ax, fraction=0.03, pad=0.02); cb.set_label("test error (clipped at 0.5)")
    ax.set_title("DFG v1.3 alone, seed 0: test error (grey). Blue dot: a compact representation of the target is complete in\n"
                 "the model; purple square: none is, but f is in the span of the model's features (span R$^2\\geq$0.999); open dot:\n"
                 "part of a compact representation; red x: the forced variant was chosen; orange bar: n* (10% test error)", fontsize=7.5)
    fig.tight_layout(); fig.savefig(os.path.join(FIG, "fig_atlas_grid.pdf")); fig.savefig(os.path.join(FIG, "fig_atlas_grid.png"), dpi=130)
    plt.close(fig)
    if not cmp_rows:
        return
    fig, axs = plt.subplots(1, 2, figsize=(9, 4.2))
    a = np.array([[x["err_alone"], x["err_v3_dfg"]] for x in cmp_rows if x["err_v3_dfg"] is not None], float)
    jit = lambda v: v + 0.004
    axs[0].scatter(jit(a[:, 1]), jit(a[:, 0]), s=8, alpha=0.5)
    axs[0].plot([0.003, 0.6], [0.003, 0.6], "k--", lw=0.7); axs[0].set_xscale("log"); axs[0].set_yscale("log")
    axs[0].set_xlabel("v3's DFG member test error (+0.004)"); axs[0].set_ylabel("DFG alone test error (+0.004)")
    axs[0].set_title(f"same (target, n), seed 0: {len(a)} cells; identical {int(np.sum(a[:, 0] == a[:, 1]))}", fontsize=8)
    P = [(t, v["n_struct_alone"], v["n_struct_v3"]) for t, v in cmp_per.items() if v["n_struct_alone"] or v["n_struct_v3"]]
    big = 2 ** 15
    for t, x, y_ in P:
        xv, yv = (y_ or big), (x or big)
        axs[1].scatter(xv, yv, s=12, color="tab:blue" if x and y_ else "tab:red")
        axs[1].annotate(t, (xv, yv), fontsize=6, xytext=(2, 2), textcoords="offset points")
    axs[1].plot([16, big], [16, big], "k--", lw=0.7); axs[1].set_xscale("log", base=2); axs[1].set_yscale("log", base=2)
    axs[1].set_xlabel("v3: first analysed n with the exact structure"); axs[1].set_ylabel("DFG alone: first n")
    axs[1].set_title("Part 10's exact-structure rule (2^15 = never / not analysed)", fontsize=8)
    fig.tight_layout(); fig.savefig(os.path.join(FIG, "fig_atlas_p10.pdf")); fig.savefig(os.path.join(FIG, "fig_atlas_p10.png"), dpi=130)
    plt.close(fig)


if __name__ == "__main__":
    main()
