"""Thread U: verification protocols for research without a machine verifier.

Run:  python3 -B threadU_verify.py > threadU_verify.out    (fixed seeds; about 12 seconds)

What it computes (all inputs are stated below; most are judgments, marked as such
in research/threadU-nonformal.md, anchored on the evidence cited there):

A. Correlation of verifier misses. A one-factor probit model (each wrong claim has a
   latent "plausibility" z shared by verifiers; verifier j misses it when
   sqrt(r) z + sqrt(1-r) e_j < Phi^-1(f)). r is fitted to three data sets:
   Panko's spreadsheet triads, mammography double reading, and Ulery's
   same-examiner retest. Then: joint miss of k independent readers.
B. Per-domain models. Each domain has a mixture of error types for the imitator's
   wrong claimed solutions, and each verification method a miss probability per
   type. Misses are correlated through a common factor (lam_c), a method factor
   shared by verifiers using the same kind of method (lam_m), and a person factor
   (lam_p) when one person runs several methods. A protocol rejects a wrong claim
   if any component catches it. f_V is computed by Monte Carlo with common random
   numbers, on a grid of a global multiplier u on every miss probability (our
   uncertainty about the levels).
C. Decomposed (cone) verification: composition over m invalid entries, same vs
   different verifier per entry, and false flags against cone size.
D. Cost per problem (task-step equivalents, one step = three months) and
   P(works) = Pr(F <= 0.05 and effort met) * P_other * feasibility, with
   F = (p * w * rbar + h) * f_V (p -> 0 when learning transfers; h = 0 by default, as the
   folder conditions on the human's chain succeeding) and the effort criterion
   (1 + iota) * s * n0 * K + T * c_p <= 4 * n0 * K. Calibration check against verified-slack.md.
E. Sensitivity: which uncertain input explains most of the variance of the
   per-world success indicator.
"""
import math
import statistics

import numpy as np

ND = statistics.NormalDist()
RNG = np.random.default_rng(20261121)
U_GRID = np.exp(np.linspace(math.log(0.4), math.log(2.5), 25))


def phi_inv(p):
    p = min(max(p, 1e-12), 1 - 1e-12)
    return ND.inv_cdf(p)


def ncdf(x):
    return 0.5 * (1.0 + np.vectorize(math.erf)(np.asarray(x) / math.sqrt(2.0)))


# ---------------------------------------------------------------- part A
def joint_miss_one_factor(f, r, k, nodes=80):
    """P(all k verifiers miss) under the one-factor probit model."""
    z, w = np.polynomial.hermite_e.hermegauss(nodes)
    w = w / w.sum()
    tau = phi_inv(f)
    if r <= 0:
        return f ** k
    pm = ncdf((tau - math.sqrt(r) * z) / math.sqrt(1 - r))
    return float(np.sum(w * pm ** k))


def fit_r(f, k, target):
    lo, hi = 0.0, 0.98
    for _ in range(60):
        mid = (lo + hi) / 2
        if joint_miss_one_factor(f, mid, k) < target:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def part_a():
    print("A. Correlation of verifier misses (one-factor probit; r = latent correlation)")
    data = [
        ("Panko 1999 spreadsheet triads, pooled (individual miss 0.37; triad miss 0.17)", 0.37, 3, 0.17),
        ("   same, nominal-group estimate (triad miss 0.19)", 0.37, 3, 0.19),
        ("Mammography pairing (single miss ~0.20; pair miss ~0.12, low end of gain)", 0.20, 2, 0.12),
        ("   same, high end of gain (pair miss ~0.08)", 0.20, 2, 0.08),
        ("Ulery 2012 same examiner retest (FN 0.075; 30% of FNs repeat)", 0.075, 2, 0.30 * 0.075),
    ]
    for name, f, k, tgt in data:
        r = fit_r(f, k, tgt)
        print("   %-80s independent %.3f  observed %.3f  ->  r = %.2f" % (name, f ** k, tgt, r))
    print("   Joint miss of k independent readers at f = 0.40 (imitator-style errors, thread S centre):")
    for r in [0.0, 0.3, 0.5, 0.65]:
        cells = ["k=%d: %.3f" % (k, joint_miss_one_factor(0.40, r, k)) for k in (1, 2, 3, 5)]
        print("     r = %.2f  %s" % (r, "  ".join(cells)))
    print("   So the second reader removes about a third of the remaining misses at r = 0.5,")
    print("   not 60% as independence would say, and the fifth reader adds little.\n")


# ---------------------------------------------------------------- part B
LAM_C, LAM_M, LAM_P = 0.20, 0.30, 0.15  # common, same-method, same-person loadings
LAM_C_DEEP = 0.60                        # "deep" errors are missed together
COST_LOCATED = 1.05                      # route (i) query + second judge, per upheld false objection
N_OVER_N0 = 1.5                          # n / n0: an unlocated false rejection costs a full scan

# Domain models. types: name -> share (the last type, "deep", gets LAM_C_DEEP).
# methods: name -> (family, miss per type, human cost per verification as a FRACTION OF n0,
# false objections upheld per verification of a correct result, located?).
# Family "machine" has no latent loading (its misses depend on the type only).
# h: the human's own chain ends in a wrong claimed solution (range).
# feas: probability that the instruction a method needs is feasible within the n0 budget
# (thread F's row (ii)); iota: the n0 inflation it causes.
# All entries are judgments; see threadU-nonformal.md section 2 for the anchors.
DOMAINS = {
    "math": {
        "types": {"checkable claim false": 0.15, "local inference slip": 0.30,
                  "gap at the hard step": 0.30, "global mismatch with the goal": 0.12,
                  "record or citation": 0.05, "deep": 0.08},
        "methods": {
            "R":     ("read", [0.45, 0.35, 0.35, 0.40, 0.65, 0.92], 0.04, 0.06, False),
            "Rloc":  ("read", [0.45, 0.35, 0.35, 0.40, 0.65, 0.92], 0.04, 0.06, True),
            "Radv":  ("read", [0.38, 0.30, 0.30, 0.34, 0.55, 0.90], 0.04, 0.10, True),
            "Rown":  ("read", [0.56, 0.44, 0.44, 0.50, 0.81, 0.95], 0.04, 0.05, True),
            "Rownc": ("read", [0.50, 0.39, 0.39, 0.45, 0.73, 0.94], 0.04, 0.05, True),
            "U":     ("use", [0.12, 0.55, 0.65, 0.30, 0.85, 0.92], 0.04, 0.02, True),
            "M":     ("machine", [0.15, 1.0, 1.0, 0.90, 0.10, 1.0], 0.002, 0.01, True),
            "K":     ("machine", [0.55, 0.65, 0.60, 0.95, 1.0, 0.85], 0.01, 0.03, True),
            "C":     ("read", [0.30, 0.20, 0.25, 0.45, 0.40, 0.92], 0.08, 0.12, True),
            "A":     ("ai", [0.46, 0.46, 0.55, 0.64, 0.19, 0.95], 0.004, 0.10, True),
            # debate: an AI defender rebuts each objection; the judge accepts valid objections
            # 0.8 instead of 0.9 (persuasive or obfuscated rebuttals), and upholds fewer false ones
            "Adeb":  ("ai", [0.52, 0.52, 0.60, 0.68, 0.28, 0.955], 0.006, 0.04, True),
            # the imitated human in critic mode: blind where the imitator is (problem-specific gaps)
            "Aimit": ("imit", [0.55, 0.55, 0.80, 0.70, 0.60, 0.98], 0.004, 0.05, True),
        },
        "w": (0.3, 0.6), "h": (0.03, 0.10), "pi_t": 0.30, "p_rest_other": 0.87,
        "iota": {"C": 0.3, "M": 0.08, "K": 0.05}, "feas": {"C": 0.70, "M": 0.95},
    },
    "software": {
        "types": {"common-path bug": 0.33, "edge-case bug": 0.25, "intent misread": 0.20,
                  "non-functional (security, concurrency)": 0.17, "deep": 0.05},
        "methods": {
            "Tfix":  ("machine", [0.15, 0.60, 0.30, 0.80, 1.0], 0.0, 0.01, True),
            "R":     ("read", [0.45, 0.60, 0.40, 0.55, 0.92], 0.03, 0.05, True),
            "U":     ("use", [0.08, 0.30, 0.35, 0.60, 0.90], 0.04, 0.03, True),
            "UD":    ("deploy", [0.05, 0.40, 0.12, 0.60, 0.85], 0.02, 0.02, True),
            "M":     ("machine", [0.60, 0.50, 1.0, 0.50, 0.95], 0.002, 0.02, True),
            "A":     ("ai", [0.40, 0.45, 0.60, 0.45, 0.95], 0.003, 0.08, True),
        },
        "w": (0.4, 0.7), "h": (0.05, 0.15), "pi_t": 0.30, "p_rest_other": 0.87,
        "iota": {}, "feas": {},
    },
    "empirical": {
        "types": {"computational or reporting error": 0.18, "fragile analysis choice": 0.27,
                  "design or inference error": 0.22, "false in the world, sound analysis": 0.25,
                  "deep": 0.08},
        "methods": {
            "R":     ("read", [0.75, 0.65, 0.45, 0.85, 0.95], 0.03, 0.08, False),
            "Rloc":  ("read", [0.75, 0.65, 0.45, 0.85, 0.95], 0.03, 0.08, True),
            "M":     ("machine", [0.15, 1.0, 1.0, 1.0, 1.0], 0.002, 0.02, True),
            "U":     ("use", [0.20, 0.35, 0.60, 0.80, 0.92], 0.05, 0.08, True),
            "A":     ("ai", [0.50, 0.60, 0.50, 0.90, 0.95], 0.004, 0.10, True),
            "C":     ("read", [0.40, 0.55, 0.40, 1.0, 0.95], 0.08, 0.12, True),
            "D":     ("world", [0.30, 0.30, 0.50, 0.35, 0.70], 0.15, 0.15, True),
        },
        "w": (0.6, 0.9), "h": (0.10, 0.35), "pi_t": 0.15, "p_rest_other": 0.70,
        "iota": {"M": 0.15, "C": 0.5}, "feas": {"C": 0.45, "M": 0.85},
    },
    "judgment": {
        "types": {"factual or internal inconsistency": 0.18, "omitted consideration": 0.30,
                  "wrong forecast or assumption": 0.27, "misread goals or values": 0.13,
                  "deep": 0.12},
        "methods": {
            "R":     ("read", [0.50, 0.60, 0.70, 0.50, 0.95], 0.03, 0.10, False),
            "Rloc":  ("read", [0.50, 0.60, 0.70, 0.50, 0.95], 0.03, 0.10, True),
            "A":     ("ai", [0.35, 0.45, 0.70, 0.60, 0.95], 0.004, 0.12, True),
            "U":     ("use", [0.50, 0.40, 0.55, 0.45, 0.92], 0.04, 0.08, True),
            "M":     ("machine", [0.30, 1.0, 1.0, 1.0, 1.0], 0.002, 0.02, True),
            "D":     ("world", [0.60, 0.60, 0.45, 0.40, 0.75], 0.01, 0.20, True),
        },
        "w": (0.7, 0.95), "h": (0.15, 0.35), "pi_t": 0.15, "p_rest_other": 0.65,
        "iota": {}, "feas": {},
    },
}

def _drop_type(dom, tname, new):
    D = DOMAINS[dom]
    names = list(D["types"])
    i = names.index(tname)
    tot = 1 - D["types"][tname]
    d2 = dict(D)
    d2["types"] = {k: v / tot for k, v in D["types"].items() if k != tname}
    d2["methods"] = {m: (v[0], v[1][:i] + v[1][i + 1:], *v[2:]) for m, v in D["methods"].items()}
    DOMAINS[new] = d2


_drop_type("empirical", "false in the world, sound analysis", "empirical-analysis")

# Protocols: lists of (method, person id). Distinct person ids are distinct people;
# AI critics of different model families get distinct ids (11, 12, 13).
A3 = [("A", 11), ("A", 12), ("A", 13)]
PROTOCOLS = {
    "math": [
        ("V-human: one expert reads (unlocated verdict)", [("R", 1)]),
        ("one expert reads, located objections", [("Rloc", 1)]),
        ("two independent experts read", [("Rloc", 1), ("Rloc", 2)]),
        ("one expert, adversarial framing", [("Radv", 1)]),
        ("the imitated human verifies its own-style result (x1.25 miss)", [("Rown", 1)]),
        ("the same, framed as a colleague's (x1.12 miss)", [("Rownc", 1)]),
        ("use only (examples, consequences, application)", [("U", 1)]),
        ("read + use, same person", [("Rloc", 1), ("U", 1)]),
        ("read + use, different people", [("Rloc", 1), ("U", 2)]),
        ("machine checks (computations, citations) + read", [("M", 0), ("Rloc", 1)]),
        ("AI critics (3 families) judged by an expert", A3),
        ("read + AI critics (3)", [("Rloc", 1)] + A3),
        ("debate: AI critics (3) + AI defender, expert judge", [("Adeb", 11), ("Adeb", 12), ("Adeb", 13)]),
        ("the imitated human as critic, expert judge", [("Aimit", 21)]),
        ("read + imitated critic", [("Rloc", 1), ("Aimit", 21)]),
        ("V-cone: one referee checks the cone", [("C", 1)]),
        ("cone split over 2 referees + final-statement check", [("C", 1), ("C", 2)]),
        ("LEAN: machine + AI critics (3) + adversarial read",
         [("M", 0)] + A3 + [("Radv", 1)]),
        ("LEAN with debate instead of one-sided criticism",
         [("M", 0), ("Adeb", 11), ("Adeb", 12), ("Adeb", 13), ("Radv", 1)]),
        ("FULL: machine + AI critics (3) + adversarial read + use by a 2nd expert",
         [("M", 0)] + A3 + [("Radv", 1), ("U", 2)]),
        ("FULL + key lemmas formalized", [("M", 0), ("K", 0)] + A3 + [("Radv", 1), ("U", 2)]),
        ("FULL + cone check (1 referee)", [("M", 0)] + A3 + [("Radv", 1), ("U", 2), ("C", 3)]),
    ],
    "software": [
        ("fixed acceptance tests only (folder's test-suite row)", [("Tfix", 0)]),
        ("fixed tests + code review", [("Tfix", 0), ("R", 1)]),
        ("fixed tests + independent tests and fuzzing", [("Tfix", 0), ("U", 2), ("M", 0)]),
        ("LEAN: tests + independent tests + fuzzing + AI critics (3)",
         [("Tfix", 0), ("U", 2), ("M", 0)] + A3),
        ("FULL: LEAN + code review", [("Tfix", 0), ("U", 2), ("M", 0)] + A3 + [("R", 1)]),
        ("FULL + staged use by the requester", [("Tfix", 0), ("U", 2), ("M", 0)] + A3 +
         [("R", 1), ("UD", 3)]),
    ],
    "empirical": [
        ("V-human: one expert reads (unlocated)", [("R", 1)]),
        ("rerun code + read", [("M", 0), ("Rloc", 1)]),
        ("rerun + independent re-analysis (robustness, holdout)", [("M", 0), ("U", 2)]),
        ("FAST: rerun + re-analysis + AI critics (3) + read", [("M", 0), ("U", 2)] + A3 + [("Rloc", 1)]),
        ("FAST + cone check of the analysis chain", [("M", 0), ("U", 2)] + A3 + [("Rloc", 1), ("C", 3)]),
        ("FAST + delayed consequence check (held until checked)",
         [("M", 0), ("U", 2)] + A3 + [("Rloc", 1), ("D", 4)]),
    ],
    "empirical-analysis": [
        ("V-human: one expert reads (unlocated)", [("R", 1)]),
        ("FAST: rerun + re-analysis + AI critics (3) + read", [("M", 0), ("U", 2)] + A3 + [("Rloc", 1)]),
    ],
    "judgment": [
        ("V-human: one expert reads (unlocated)", [("R", 1)]),
        ("AI red team (3) + expert judge + pre-mortem by a 2nd expert", A3 + [("Rloc", 1), ("U", 2)]),
        ("the same + fact checks", [("M", 0)] + A3 + [("Rloc", 1), ("U", 2)]),
        ("the same + outcome check later (held)", [("M", 0)] + A3 + [("Rloc", 1), ("U", 2), ("D", 4)]),
    ],
}
BEST = {
    "math": "LEAN: machine + AI critics (3) + adversarial read",
    "software": "LEAN: tests + independent tests + fuzzing + AI critics (3)",
    "empirical": "FAST: rerun + re-analysis + AI critics (3) + read",
    "empirical-analysis": "FAST: rerun + re-analysis + AI critics (3) + read",
    "judgment": "the same + fact checks",
}

N_MC = 120000


def f_protocol(dom, comps, n=N_MC, seed=1):
    """f_V(u) on U_GRID, per type and mixed. Common random numbers across protocols."""
    D = DOMAINS[dom]
    types = list(D["types"].items())
    rng = np.random.default_rng(seed)
    fams = sorted({D["methods"][m][0] for m, _ in comps})
    persons = sorted({p for _, p in comps})
    out_mixed = np.zeros(len(U_GRID))
    out_type = {}
    for ti, (tname, share) in enumerate(types):
        zc = rng.standard_normal(n)
        zf = {fa: rng.standard_normal(n) for fa in fams}
        zp = {p: rng.standard_normal(n) for p in persons}
        latent = []
        for m, p in comps:
            fam = D["methods"][m][0]
            if fam == "machine":
                latent.append(None)
                continue
            e = rng.standard_normal(n)
            lc = LAM_C_DEEP if tname == "deep" else LAM_C
            lm = min(LAM_M, 0.95 - lc)
            lp = LAM_P if sum(1 for _, q in comps if q == p) > 1 else 0.0
            lp = min(lp, max(0.0, 0.98 - lc - lm))
            le = 1 - lc - lm - lp
            s = math.sqrt(lc) * zc + math.sqrt(lm) * zf[fam] + math.sqrt(le) * e
            if lp:
                s = s + math.sqrt(lp) * zp[p]
            latent.append(s)
        unif = rng.random((len(comps), n))
        fu = np.zeros(len(U_GRID))
        for ui, u in enumerate(U_GRID):
            allmiss = np.ones(n, dtype=bool)
            for ci, (m, p) in enumerate(comps):
                fbase = D["methods"][m][1][ti]
                fm = min(1.0, fbase * u) if fbase < 1.0 else 1.0
                if fm >= 1.0:
                    continue
                if latent[ci] is None:
                    miss = unif[ci] < fm
                else:
                    miss = latent[ci] < phi_inv(fm)
                allmiss &= miss
            fu[ui] = allmiss.mean()
        out_type[tname] = fu
        out_mixed += share * fu
    return out_mixed, out_type


def protocol_cost(dom, comps):
    """Human effort per problem beyond search (task steps), n0 inflation, false rejections."""
    D = DOMAINS[dom]
    cost, fr_sum, iota, located, feas = 0.0, 0.0, 0.0, True, 1.0
    seen = set()
    for m, p in comps:
        fam, _, c, fr, loc = D["methods"][m]
        cost += c
        fr_sum += fr
        located &= loc
        if m not in seen:
            iota += D["iota"].get(m, 0.0)
            feas *= D["feas"].get(m, 1.0)
            seen.add(m)
    return cost, fr_sum, located, iota, feas


def u_index(u):
    return int(np.argmin(np.abs(U_GRID - u)))


def part_b():
    print("B. Miss rate f_V of each protocol on the imitator's wrong claimed solutions")
    print("   (lam_c = %.2f, deep %.2f, lam_m = %.2f, lam_p = %.2f; f at u = 0.6 / 1.0 / 1.6, i.e. every miss"
          % (LAM_C, LAM_C_DEEP, LAM_M, LAM_P))
    print("   probability x0.6, x1, x1.6). Human cost is per problem, as a fraction of n0; 'false obj' is the")
    print("   expected number of upheld false objections per verification of a correct result.")
    res = {}
    i06, i1, i16 = u_index(0.6), u_index(1.0), u_index(1.6)
    for dom in PROTOCOLS:
        print("   --- %s: types %s" % (dom, ", ".join("%s %.2f" % kv for kv in DOMAINS[dom]["types"].items())))
        for name, comps in PROTOCOLS[dom]:
            fm, ft = f_protocol(dom, comps)
            cost, fr, loc, iota, feas = protocol_cost(dom, comps)
            res[(dom, name)] = (fm, ft, cost, fr, loc, iota, feas)
            top = sorted(ft.items(), key=lambda kv: -DOMAINS[dom]["types"][kv[0]] * kv[1][i1])[:2]
            print("   %-70s f = %.3f / %.3f / %.3f | cost %.3f n0, false obj %.2f%s, n0 +%d%%, feas %.2f"
                  % (name, fm[i06], fm[i1], fm[i16], cost, fr, "" if loc else " (unlocated)",
                     round(100 * iota), feas))
            print("   %-70s   residual f by type: %s" % ("", ", ".join(
                "%s %.3f" % (k, DOMAINS[dom]["types"][k] * v[i1]) for k, v in top)))
        print()
    return res


# ---------------------------------------------------------------- part C
def part_c():
    print("C. Decomposed verification: a cone with m invalid entries, each checked locally")
    print("   per-entry miss f_e; same verifier for all entries (person factor shared, lam_p = 0.30)")
    print("   against a different verifier per entry (common factor only, lam_c = 0.20)")
    n = 400000
    rng = np.random.default_rng(7)
    for fe in [0.15, 0.25, 0.35]:
        row = []
        for m in [1, 2, 3]:
            zc = rng.standard_normal(n)
            zp = rng.standard_normal(n)
            same = np.ones(n, bool)
            diff = np.ones(n, bool)
            for _ in range(m):
                e1, e2 = rng.standard_normal(n), rng.standard_normal(n)
                s_same = math.sqrt(0.2) * zc + math.sqrt(0.3) * zp + math.sqrt(0.5) * e1
                s_diff = math.sqrt(0.2) * zc + math.sqrt(0.8) * e2
                same &= s_same < phi_inv(fe)
                diff &= s_diff < phi_inv(fe)
            row.append("m=%d: same %.3f, different %.3f, indep %.3f" % (m, same.mean(), diff.mean(), fe ** m))
        print("   f_e = %.2f  %s" % (fe, " | ".join(row)))
    print("   A single plausible slip (m = 1) gets no compounding: f_cone = f_e. The gain from")
    print("   decomposition is the lower local f_e and the location of the error (one task query).")
    print("   False flags on a correct cone of c entries, per-entry false-flag rate e; an adjudicator")
    print("   (a second referee shown the flag) upholds a spurious flag with probability 0.25:")
    for e in [0.002, 0.005, 0.01]:
        cells = []
        for c in [30, 100, 300]:
            raw = 1 - (1 - e) ** c
            adj = 1 - (1 - 0.25 * e) ** c
            cells.append("c=%d: %.2f -> %.2f" % (c, raw, adj))
        print("     e = %.3f  %s" % (e, "  ".join(cells)))
    print("   Without adjudication (or route (i) with excusal), large cones are rarely accepted.\n")


# ---------------------------------------------------------------- part D
def p_works(dom, fm, cost, fr, located, iota, feas, n=200000, seed=3, return_samples=False,
            h_on=False):
    D = DOMAINS[dom]
    rng = np.random.default_rng(seed)
    u = np.exp(rng.normal(0.0, 0.55, n))             # uncertainty in all miss levels
    f = np.interp(np.log(u), np.log(U_GRID), fm)
    p = rng.uniform(0.10, 0.50, n)                   # first-run failure on a new problem, no transfer
    w = rng.uniform(*D["w"], n)                      # share of failures with a claimed solution
    rbar = rng.uniform(1.0, 1.6, n)                  # distinct wrong claims verified per failing problem
    h = rng.uniform(*D["h"], n) * (1.0 if h_on else 0.0)  # human's own chain wrong (folder: h = 0)
    transfer = rng.random(n) < D["pi_t"]             # learning transfers: p small
    F = (np.where(transfer, 0.0, p * w * rbar) + h) * f
    ok_out = F <= 0.05
    # effort: (1+iota)*s*n0*K + T*c_p <= 4*n0*K, with T/K unknown
    n0 = rng.uniform(20, 40, n)
    s = rng.uniform(0.5, 2.0, n)
    TK = np.exp(rng.uniform(math.log(3), math.log(30), n))
    beta = 1.0
    per_rej = COST_LOCATED if located else N_OVER_N0 * n0     # resolving one rejection of a correct
    c_fr = fr * per_rej                                       # or human-own claim
    c_own = h * (1 - f) * (2.0 if located else N_OVER_N0 * n0)
    c_p = beta + cost * n0 + c_fr + c_own
    ok_eff = TK * c_p <= (4 - (1 + iota) * s) * n0
    ok_other = rng.random(n) < D["p_rest_other"] * feas
    ok = ok_out & ok_eff & ok_other
    abst = h * (1 - f) + 0.25 * fr                            # yield loss (abstentions)
    if return_samples:
        return ok, dict(u=u, p=p, w=w, rbar=rbar, h=h, transfer=transfer.astype(float),
                        n0=n0, s=s, TK=TK), ok_out
    return (ok.mean(), ok_out.mean(), ok_eff.mean(), float(np.median(F)),
            float(np.mean(c_p / n0)), float(abst.mean()))


def part_d(res):
    print("D. P(works): output failure <= 5% and effort <= a fifth of chained imitation's")
    print("   F = (p*w*rbar + h)*f_V; p~U[.1,.5], rbar~U[1,1.6], u~logN(0,.55); h = 0 here (the folder")
    print("   conditions on the human's own chain succeeding; h > 0 is reported at the end);")
    print("   T/K log-uniform on [3,30]; beta = 1 audit per output; a located rejection of a correct")
    print("   result costs 1.05 steps, an unlocated one a full scan of n = 1.5 n0 steps.")
    print("   Calibration against verified-slack.md (its f ranges; spread over the range by u):")
    for dom, label, lo, hi, cost, fr, loc, iota, feas, folder in [
        ("math", "V-human, f in [0.2, 0.5]", 0.2, 0.5, 0.04, 0.06, False, 0.0, 1.0, "40%"),
        ("math", "V-cone, f in [0.1, 0.35], typed entries", 0.1, 0.35, 0.08, 0.12, True, 0.3, 0.7, "45%"),
        ("math", "proof assistant, f ~ 0.02, iota 0.4", 0.02, 0.02, 0.002, 0.01, True, 0.4, 1.0,
         "70% (thread T adds misformalization)"),
        ("empirical", "V-human, f in [0.5, 0.8]", 0.5, 0.8, 0.03, 0.08, False, 0.0, 1.0, "10%"),
    ]:
        fm = np.linspace(lo, hi, len(U_GRID))
        pw, po, pe, med, cp, ab = p_works(dom, fm, cost, fr, loc, iota, feas)
        print("     %-10s %-42s model %.0f%% (output %.0f%%, effort %.0f%%)  folder %s" % (
            dom, label, 100 * pw, 100 * po, 100 * pe, folder))
    print()
    table = {}
    for dom in PROTOCOLS:
        print("   --- %s" % dom)
        for name, comps in PROTOCOLS[dom]:
            fm, ft, cost, fr, loc, iota, feas = res[(dom, name)]
            pw, po, pe, med, cp, ab = p_works(dom, fm, cost, fr, loc, iota, feas)
            table[(dom, name)] = pw
            c_p = 1.0 + 30 * cost + fr * (COST_LOCATED if loc else N_OVER_N0 * 30)
            tk = (4 - (1 + iota) * 1.25) * 30 / c_p
            print("   %-70s P(works) %2.0f%% [output %2.0f%%, effort %3.0f%%, median F %4.1f%%, "
                  "cost/problem %.2f n0, T/K max %3.0f, abstain %2.0f%%]" % (
                      name, 100 * pw, 100 * po, 100 * pe, 100 * med, cp, tk, 100 * ab))
        print()
    print("   Unconditional on the human's own chain being right (h > 0: the human's own claimed")
    print("   solution is wrong at rate h; math 3-10%, software 5-15%, empirical 10-35%, judgment 15-35%):")
    for dom in PROTOCOLS:
        for name in [PROTOCOLS[dom][0][0], BEST[dom]]:
            fm, ft, cost, fr, loc, iota, feas = res[(dom, name)]
            pw, po, pe, med, cp, ab = p_works(dom, fm, cost, fr, loc, iota, feas, h_on=True)
            print("     %-9s %-68s P(works) %2.0f%% [output %2.0f%%, effort %3.0f%%, median F %4.1f%%, "
                  "abstain %2.0f%%]" % (dom, name, 100 * pw, 100 * po, 100 * pe, 100 * med, 100 * ab))
    print()
    return table


# ---------------------------------------------------------------- part E
def part_e(res):
    print("E. Sensitivity (first-order variance shares of the success indicator, 10 quantile bins)")
    for dom, name in [("math", BEST["math"]), ("software", BEST["software"]),
                      ("empirical", BEST["empirical"]), ("judgment", BEST["judgment"])]:
        fm, ft, cost, fr, loc, iota, feas = res[(dom, name)]
        ok, smp, ok_out = p_works(dom, fm, cost, fr, loc, iota, feas, return_samples=True)
        for label, y in (("works", ok.astype(float)), ("output", ok_out.astype(float))):
            _shares(dom, name, label, y, smp)
    _rest_e()


def _shares(dom, name, label, y, smp):
    if True:
        var = y.var()
        shares = []
        for k, x in smp.items():
            if np.ptp(x) == 0:
                continue
            if k == "transfer":
                s = sum((x == v).mean() * (y[x == v].mean() - y.mean()) ** 2 for v in (0.0, 1.0)) / var
            else:
                qs = np.quantile(x, np.linspace(0, 1, 11))
                b = np.clip(np.searchsorted(qs, x, side="right") - 1, 0, 9)
                s = sum(((b == i).mean()) * (y[b == i].mean() - y.mean()) ** 2 for i in range(10)) / var
            shares.append((s, k))
        shares.sort(reverse=True)
        print("   %-9s %-6s %-6s P = %.2f; " % (dom, name.split(":")[0][:6], label, y.mean()) +
              ", ".join("%s %.2f" % (k, s) for s, k in shares[:6]))


def _rest_e():
    global LAM_C, LAM_C_DEEP
    comps = dict(PROTOCOLS["math"])[BEST["math"]]
    cost, fr, loc, iota, feas = protocol_cost("math", comps)
    print("   math best: correlation of misses (lam_c for ordinary errors / deep errors):")
    keep = (LAM_C, LAM_C_DEEP)
    for lc, ld in [(0.05, 0.4), (0.20, 0.60), (0.35, 0.75), (0.50, 0.85)]:
        LAM_C, LAM_C_DEEP = lc, ld
        fm, _ = f_protocol("math", comps)
        pw = p_works("math", fm, cost, fr, loc, iota, feas)[0]
        print("     lam_c = %.2f / %.2f: f_V = %.3f, P(works) = %.0f%%" % (lc, ld, fm[u_index(1.0)], 100 * pw))
    LAM_C, LAM_C_DEEP = keep
    print("   math best: share of deep errors (taken from the slips and gaps):")
    T = DOMAINS["math"]["types"]
    keep_t = dict(T)
    for d in [0.04, 0.08, 0.15, 0.25]:
        extra = d - keep_t["deep"]
        T["deep"] = d
        T["local inference slip"] = keep_t["local inference slip"] - extra / 2
        T["gap at the hard step"] = keep_t["gap at the hard step"] - extra / 2
        fm, _ = f_protocol("math", comps)
        pw = p_works("math", fm, cost, fr, loc, iota, feas)[0]
        print("     deep share %.2f: f_V = %.3f, P(works) = %.0f%%" % (d, fm[u_index(1.0)], 100 * pw))
    T.clear()
    T.update(keep_t)
    print("   math best: AI-critic recall (every miss probability of A scaled):")
    base = DOMAINS["math"]["methods"]["A"]
    for scale, lab in [(0.7, "miss x0.7"), (1.0, "as assumed"), (1.4, "miss x1.4"), (99, "no AI critics")]:
        DOMAINS["math"]["methods"]["A"] = (base[0], [min(1.0, x * scale) for x in base[1]], *base[2:])
        fm, _ = f_protocol("math", comps)
        pw = p_works("math", fm, cost, fr, loc, iota, feas)[0]
        print("     %-14s f_V = %.3f, P(works) = %.0f%%" % (lab, fm[u_index(1.0)], 100 * pw))
    DOMAINS["math"]["methods"]["A"] = base
    print()


if __name__ == "__main__":
    part_a()
    res = part_b()
    part_c()
    part_d(res)
    part_e(res)
