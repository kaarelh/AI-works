"""Part 11, Q7 'order': compare the order in which DFG v1.3 alone acquires a target's characters with the order in
which the study's networks do (Part 5, study/trajectories).

Inputs (read only)
  networks, time axis   study/trajectories/results/<fn>_{online,fixed}.json (Part 5, analyze_traj.py): per network
                        (condition online / 16384 / 2048 / 512, seeds 0-2) and target character S the learned fraction
                        phi_S(t) = c_S(t) / yhat_S at 65 checkpoints and its onset (first step with phi >= 1/2 for good).
                        Here: per-seed onsets as stored; the seed-mean onset = first_cross of the seed-mean phi curve
                        (the convention of trajectories/stages.py, threshold 1/2, staying >= 0.4 after).
  networks, n axis      the fixed-training-set study (study/nn_train.py, results in $SCR/results/fixed_adam_<fn>.npz):
                        the same network and training sets at n = 16..16384, seeds 0-2; coef = mean over the 4096 test
                        inputs of f(x) chi_S(x) for |S| <= 4 (nn_train.char_sets, kmax = 4); phi_S(n) at step 20000.
  DFG                   order/results/cells/<fn>__n<n>__s<seed>.json.gz (order_fit.py).
Definitions
  DFG round onset       the first round j whose least-squares function has phi_S >= 1/2 and keeps phi_S >= 0.4 in every
                        later round (the network's 'for good' rule on DFG's round axis); inf if never.
  DFG explicit round    the round in which chi_S itself became a feature.
  n onset               the smallest grid n whose FINAL model has phi_S >= 1/2 with phi_S >= 0.4 at every larger grid n
                        (DFG: final least-squares function; networks: the network at step 20000); inf if none.
  Kendall tau-b         between two orders over the target's characters; 'never' = tied last.  Undefined (reported as
                        'all tied') when one order puts every character at the same rank.
  inverted pair         S before S' in one order (networks: onsets more than a factor 1.35 apart, Part 5's stage
                        clustering) and strictly after it in the other.
Writes order/results/order_summary.json, order/tables/order_*.md|csv, order/figures/fig_order.{pdf,png}.
"""
import os, sys, json, gzip, math, itertools, numpy as np
from scipy.stats import kendalltau

HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))
TRAJ = os.path.join(STUDY, "trajectories", "results")
SCR = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad"
FIXED = os.path.join(SCR, "results")
CELLS = os.path.join(HERE, "results", "cells")
TAB = os.path.join(HERE, "tables"); FIG = os.path.join(HERE, "figures"); RES = os.path.join(HERE, "results")
for p in (TAB, FIG, RES):
    os.makedirs(p, exist_ok=True)
CAL = ["sparsepoly", "stair5", "mux", "majpar", "rmaj9"]
HELD = ["andxor", "dlist5", "parmaj", "dnf3", "rand1", "rand3"]
TARGETS = CAL + HELD
CONDS = {"online": ("online", "online"), "16384": ("fixed", "16384"), "2048": ("fixed", "2048"), "512": ("fixed", "512")}
NS = [2 ** k for k in range(4, 15)]
SEEDS = [0, 1, 2]
INF = float("inf")


def first_cross(steps, curve, thr=0.5):
    """trajectories/analyze_traj.first_cross (copied): first checkpoint step (log-interpolated) at which curve >= thr
    and stays >= 0.8 thr afterwards; None if never."""
    for i in range(len(curve)):
        if curve[i] >= thr and np.all(curve[i:] >= 0.8 * thr):
            if i == 0 or steps[i - 1] <= 0:
                return float(steps[i])
            lo, hi = curve[i - 1], curve[i]; f = (thr - lo) / max(hi - lo, 1e-9)
            return float(np.exp(np.log(steps[i - 1]) + f * (np.log(steps[i]) - np.log(steps[i - 1]))))
    return None


def first_good(vals, thr=0.5, keep=0.4):
    """Index of the first entry >= thr after which every entry is >= keep; None if none."""
    for i in range(len(vals)):
        if vals[i] >= thr and all(v >= keep for v in vals[i:]):
            return i
    return None


# ------------------------------------------------------------------------------------------------ networks
def net_time(fn):
    """{cond: {char: dict(mean=seed-mean onset, seeds=[...], final_mean=phi at the last step)}}, support yhat."""
    out, sup = {}, None
    for cond, (tag, prefix) in CONDS.items():
        r = json.load(open(os.path.join(TRAJ, f"{fn}_{tag}.json")))
        sup = {k: v for k, v in r["support"].items() if k != "1"}; steps = np.array(r["steps"], float)
        keys = [f"{prefix}/s{s}" for s in SEEDS]
        d = {}
        for ch in sup:
            ph = np.array([r["nets"][k]["phi"][ch] for k in keys])
            ons = [r["nets"][k]["onset"][ch] for k in keys]
            m = first_cross(steps, ph.mean(0))
            d[ch] = dict(mean=INF if m is None else m, seeds=[INF if o is None else float(o) for o in ons],
                         final_mean=float(ph.mean(0)[-1]), final_seeds=[float(v) for v in ph[:, -1]])
        out[cond] = d
    return out, sup


def net_n(fn, sup):
    """Networks' n onset from the fixed-n study (|S| <= 4): {char: dict(seeds=[n onset per seed], mean=n onset of the
    seed-mean phi, phi=[[phi(n, s)]])}; None if the file is missing."""
    p = os.path.join(FIXED, f"fixed_adam_{fn}.npz")
    if not os.path.exists(p):
        return None
    z = np.load(p); sets = [tuple(S) for S in json.loads(str(z["sets"]))]
    assert int(z["step"][-1]) == 20000
    name = lambda S: "".join(f"x{i + 1}" for i in S)
    idx = {name(S): j for j, S in enumerate(sets) if S}
    I = {(int(n), int(s)): j for j, (n, s) in enumerate(zip(z["net_n"], z["net_s"]))}
    out = {}
    for ch, yh in sup.items():
        if ch not in idx:
            continue
        ph = np.array([[float(z["coef"][-1, I[(n, s)], idx[ch]]) / yh for s in range(3)] for n in NS])   # [n, seed]
        on = [first_good(list(ph[:, s])) for s in range(3)]; om = first_good(list(ph.mean(1)))
        out[ch] = dict(seeds=[INF if o is None else NS[o] for o in on], mean=INF if om is None else NS[om],
                       phi=ph.round(3).tolist())
    return out


# ------------------------------------------------------------------------------------------------ DFG
def load_cell(fn, n, s):
    p = os.path.join(CELLS, f"{fn}__n{n}__s{s}.json.gz")
    if not os.path.exists(p):
        return None
    with gzip.open(p, "rt") as fh:
        return json.load(fh)


def dfg_rounds(c):
    """{char: (round onset by phi of the least-squares function, explicit round, how, class)}."""
    out = {}
    PL = np.array(c["phi_ls"])                                             # [R + 1, chars]
    for q, ch in enumerate(c["chars"]):
        i = first_good(list(PL[:, q]))
        ro = INF if i is None else i - 1                                    # index k = after round k - 1
        if ro == -1:
            ro = 0                                                          # (cannot happen: k = 0 is the constant)
        e = c["explicit"].get(ch)
        # half-rounds: within round j the characters (and the linear / spectral blocks) are tested on r, the sum blocks
        # on r deflated by the round's characters; a character carried in round j only by a block -> 2 j + 1
        half = INF
        if np.isfinite(ro):
            half = 2 * ro if (e is not None and e["round"] == ro) else 2 * ro + 1
        z0 = c["replay"][ch][0]
        out[ch] = dict(round=ro, half=half, explicit=INF if e is None else e["round"], how=None if e is None else e["how"],
                       cls=None if e is None else e["cls"], z=None if e is None else e["z"],
                       z0=0.0 if z0 is None else float(z0["zbest"]), cls0=None if z0 is None else z0["best"],
                       phi_final_ls=float(PL[-1, q]), phi_final=float(c["phi_final"][q]))
    return out


def dfg_n(fn, chars, s, key="phi_ls"):
    """DFG n onset per character for seed s: the smallest grid n whose final model has phi >= 1/2 (for good)."""
    ph = {ch: [] for ch in chars}; avail = []
    for n in NS:
        c = load_cell(fn, n, s)
        if c is None:
            for ch in chars:
                ph[ch].append(np.nan)
            continue
        avail.append(n)
        v = np.array(c["phi_ls"])[-1] if key == "phi_ls" else np.array(c[key])
        for q, ch in enumerate(c["chars"]):
            ph[ch].append(float(v[q]))
    out = {}
    for ch in chars:
        vals = ph[ch]
        if any(np.isnan(vals)):
            out[ch] = dict(n=None, phi=vals); continue
        i = first_good(vals); out[ch] = dict(n=INF if i is None else NS[i], phi=[round(v, 3) for v in vals])
    return out


def dfg_n_explicit(fn, chars, s):
    """The smallest grid n from which chi_S is an explicit feature of the final model at every larger n."""
    has = {ch: [] for ch in chars}
    for n in NS:
        c = load_cell(fn, n, s)
        for ch in chars:
            has[ch].append(None if c is None else (c["explicit"].get(ch) is not None))
    out = {}
    for ch in chars:
        v = has[ch]
        if None in v:
            out[ch] = None; continue
        i = next((k for k in range(len(v)) if all(v[k:])), None); out[ch] = INF if i is None else NS[i]
    return out


# ------------------------------------------------------------------------------------------------ comparison
def tau(a, b):
    a = np.array([1e12 if not np.isfinite(v) else v for v in a], float)
    b = np.array([1e12 if not np.isfinite(v) else v for v in b], float)
    if len(set(a)) < 2 or len(set(b)) < 2:
        return None
    t = kendalltau(a, b).statistic                                          # tau-b (ties corrected)
    return None if not np.isfinite(t) else float(t)


def pair_counts(chars, net, dfg, sep=1.35):
    """Pairs ordered by the networks (onsets > sep apart, or one never): concordant / tied in DFG / inverted; and pairs
    in one network stage (within sep) that DFG separates."""
    conc, tied, inv, same_net_split, same_net_same, inv_list = 0, 0, 0, 0, 0, []
    for a, b in itertools.combinations(chars, 2):
        na, nb = net[a], net[b]; da, db = dfg[a], dfg[b]
        if not np.isfinite(na) and not np.isfinite(nb):
            continue
        if np.isfinite(na) and np.isfinite(nb) and max(na, nb) <= sep * min(na, nb):
            if da == db:
                same_net_same += 1
            else:
                same_net_split += 1
            continue
        first, second = (a, b) if na < nb else (b, a)
        df, dsec = dfg[first], dfg[second]
        if df < dsec:
            conc += 1
        elif df == dsec:
            tied += 1
        else:
            inv += 1; inv_list.append((first, second))
    return dict(concordant=conc, tied=tied, inverted=inv, inverted_pairs=inv_list, net_bundle_same=same_net_same,
                net_bundle_split=same_net_split)


def net_stages(onsets, sep=1.35):
    """Part 5's clustering: sorted finite onsets, a new stage when the next onset is more than sep x the last one."""
    o = sorted((v, ch) for ch, v in onsets.items() if np.isfinite(v)); st = []
    for v, ch in o:
        if st and v <= sep * st[-1][-1][0]:
            st[-1].append((v, ch))
        else:
            st.append([(v, ch)])
    return [[ch for _, ch in g] for g in st], [ch for ch, v in onsets.items() if not np.isfinite(v)]


def nglob(yh, deg, yconst, d=30, K=4, delta=0.1):
    """Round-0 global-class detection size: the n at which |yhat_S| = s sqrt(2 ln(4 K N / delta) / n), N = C(d, |S|),
    s^2 = 1 - yhat_0^2 (the residual after the constant); None for degrees with no round-0 global test on all rows
    (degree > 4: degrees 5, 6 are searched on a subsample, higher degrees not at all)."""
    if deg > 4:
        return None
    N = math.comb(d, deg); s2 = 1 - yconst ** 2
    return 2 * math.log(4 * K * N / delta) * s2 / yh ** 2


def fmt(v):
    if v is None:
        return "–"
    if isinstance(v, float) and not np.isfinite(v):
        return "never"
    if isinstance(v, float):
        return f"{v:.0f}" if v >= 10 else f"{v:.2f}"
    return str(v)


def med(vals):
    """Median of the per-seed values (inf allowed); None if any is missing."""
    if any(x is None for x in vals):
        return None
    v = sorted(vals)
    if len(v) % 2:
        return v[len(v) // 2]
    a, b = v[len(v) // 2 - 1], v[len(v) // 2]
    return math.sqrt(a * b) if np.isfinite(a) and np.isfinite(b) else b


def clean(o):
    if isinstance(o, dict):
        return {str(k): clean(v) for k, v in o.items()}
    if isinstance(o, (list, tuple)):
        return [clean(v) for v in o]
    if isinstance(o, (float, np.floating)):
        return float(o) if np.isfinite(o) else ("inf" if o > 0 else "-inf") if not np.isnan(o) else None
    if isinstance(o, (np.integer,)):
        return int(o)
    return o


def main():
    S = dict(targets={}, notes=[])
    for fn in TARGETS:
        nt, sup = net_time(fn)
        chars = list(sup); yh = {ch: sup[ch] for ch in chars}
        deg = {ch: ch.count("x") for ch in chars}
        r0 = json.load(open(os.path.join(TRAJ, f"{fn}_online.json")))["support"].get("1", 0.0)
        nn = net_n(fn, sup)
        T = dict(chars=chars, yhat=yh, deg=deg, yconst=r0, net_time=nt, net_n=nn,
                 nglob={ch: nglob(yh[ch], deg[ch], r0) for ch in chars}, dfg={}, cmp={})
        # DFG at the fixed n of Part 5, per seed
        for n in (16384, 2048, 512):
            T["dfg"][str(n)] = {}
            for s in SEEDS:
                c = load_cell(fn, n, s)
                if c is None:
                    continue
                assert c["chars"] == chars, (fn, c["chars"][:5], chars[:5])
                T["dfg"][str(n)][s] = dict(rounds=dfg_rounds(c), err=c["err"], nrounds=c["rounds_n"], stop=c["stop"],
                                           variant=c["variant"], s_check=all(c["s_check"]), identity=c["identity"],
                                           round_summary=[dict(round=rr["round"], n_new=rr["n_new"], linear=rr["linear"],
                                                               quad=rr["quad"], blocks=[b["desc"] for b in rr["sum_blocks"]])
                                                          for rr in c["rounds"]])
        # DFG at every grid n: rounds used, round onsets, and tau against the online network order
        netm_on = {ch: nt["online"][ch]["mean"] for ch in chars}
        T["dfg_grid"] = {}
        for n in NS:
            row = []
            for s in SEEDS:
                c = load_cell(fn, n, s)
                if c is None:
                    continue
                dr = dfg_rounds(c)
                ro = {ch: dr[ch]["round"] for ch in chars}; hr = {ch: dr[ch]["half"] for ch in chars}
                row.append(dict(seed=s, err=c["err"], nrounds=c["rounds_n"], variant=c["variant"],
                                distinct_rounds=len(set(v for v in ro.values() if np.isfinite(v))),
                                distinct_half=len(set(v for v in hr.values() if np.isfinite(v))),
                                learned=sum(1 for v in ro.values() if np.isfinite(v)),
                                tau_round=tau([netm_on[ch] for ch in chars], [ro[ch] for ch in chars]),
                                tau_half=tau([netm_on[ch] for ch in chars], [hr[ch] for ch in chars]),
                                tau_z0=tau([netm_on[ch] for ch in chars], [-dr[ch]["z0"] for ch in chars]),
                                pairs_half=pair_counts(chars, netm_on, hr)))
            T["dfg_grid"][n] = row
        # DFG n onset per seed
        T["dfg_n"] = {s: dfg_n(fn, chars, s) for s in SEEDS}
        T["dfg_n_explicit"] = {s: dfg_n_explicit(fn, chars, s) for s in SEEDS}
        # comparisons
        cmpd = {}
        for cond in CONDS:
            n_dfg = "16384" if cond == "online" else cond
            netm = {ch: nt[cond][ch]["mean"] for ch in chars}
            per_seed = []
            for s in SEEDS:
                D = T["dfg"][n_dfg].get(s)
                if D is None:
                    continue
                dr = {ch: D["rounds"][ch]["round"] for ch in chars}
                nets = {ch: nt[cond][ch]["seeds"][s] for ch in chars} if cond != "online" else netm
                hr = {ch: D["rounds"][ch]["half"] for ch in chars}; zz = {ch: -D["rounds"][ch]["z0"] for ch in chars}
                per_seed.append(dict(seed=s, tau=tau([nets[ch] for ch in chars], [dr[ch] for ch in chars]),
                                     tau_half=tau([nets[ch] for ch in chars], [hr[ch] for ch in chars]),
                                     tau_z0=tau([nets[ch] for ch in chars], [zz[ch] for ch in chars]),
                                     pairs_half=pair_counts(chars, nets, hr),
                                     pairs_z0=pair_counts(chars, nets, zz),
                                     tau_vs_mean=tau([netm[ch] for ch in chars], [dr[ch] for ch in chars]),
                                     pairs=pair_counts(chars, nets, dr),
                                     n_rounds_used=len(set(v for v in dr.values() if np.isfinite(v))),
                                     never_dfg=sum(1 for v in dr.values() if not np.isfinite(v)),
                                     never_net=sum(1 for v in nets.values() if not np.isfinite(v))))
            # DFG n order (median over seeds) against this condition's network time order
            dn = {ch: med([T["dfg_n"][s][ch]["n"] for s in SEEDS]) for ch in chars}
            cmpd[cond] = dict(per_seed=per_seed,
                              tau_n=tau([netm[ch] for ch in chars], [dn[ch] if dn[ch] is not None else INF for ch in chars])
                              if all(dn[ch] is not None for ch in chars) else None,
                              pairs_n=pair_counts(chars, netm, {ch: dn[ch] if dn[ch] is not None else INF for ch in chars})
                              if all(dn[ch] is not None for ch in chars) else None,
                              stages=net_stages(netm))
        # like for like on the n axis: networks' n onset (fixed-n study, |S| <= 4) against DFG's
        if nn:
            c4 = [ch for ch in chars if ch in nn]
            netn = {ch: med(nn[ch]["seeds"]) for ch in c4}
            dn = {ch: med([T["dfg_n"][s][ch]["n"] for s in SEEDS]) for ch in c4}
            ok = all(dn[ch] is not None for ch in c4)
            cmpd["n_axis"] = dict(chars=c4, tau=tau([netn[ch] for ch in c4], [dn[ch] for ch in c4]) if ok else None,
                                  pairs=pair_counts(c4, netn, dn, sep=1.0) if ok else None,
                                  per_seed=[dict(seed=s, tau=tau([nn[ch]["seeds"][s] for ch in c4],
                                                                 [T["dfg_n"][s][ch]["n"] if T["dfg_n"][s][ch]["n"] is not None else np.nan for ch in c4]))
                                            for s in SEEDS] if ok else None,
                                  net_time_vs_net_n=tau([nt["online"][ch]["mean"] for ch in c4], [netn[ch] for ch in c4]))
            # the networks' n order against their own time order, and DFG's glob prediction against DFG's n order
        cmpd["nglob_vs_dfg_n"] = tau([T["nglob"][ch] if T["nglob"][ch] is not None else INF for ch in chars],
                                     [med([T["dfg_n"][s][ch]["n"] for s in SEEDS]) or INF for ch in chars])
        cmpd["nglob_vs_net_online"] = tau([T["nglob"][ch] if T["nglob"][ch] is not None else INF for ch in chars],
                                          [nt["online"][ch]["mean"] for ch in chars])
        T["cmp"] = cmpd
        S["targets"][fn] = T
    json.dump(clean(S), open(os.path.join(RES, "order_summary.json"), "w"), indent=0)
    return S


if __name__ == "__main__":
    S = main()
    for fn, T in S["targets"].items():
        print(fn)
        for cond, c in T["cmp"].items():
            if cond in CONDS:
                print(f"  {cond:6s} tau/seed", [None if p["tau"] is None else round(p["tau"], 2) for p in c["per_seed"]],
                      "tau_n", None if c["tau_n"] is None else round(c["tau_n"], 2),
                      "pairs", [(p["pairs"]["concordant"], p["pairs"]["tied"], p["pairs"]["inverted"]) for p in c["per_seed"]])
            elif cond == "n_axis":
                print("  n-axis tau", c["tau"], "net time vs net n", c["net_time_vs_net_n"])
