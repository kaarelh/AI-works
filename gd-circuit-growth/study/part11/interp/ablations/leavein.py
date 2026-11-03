"""Part 11, Q5b (post hoc): 'leave one in' runs from the core DFG, to attribute its losses and gains (ABLATIONS.md section 6).

The core (PROTOCOL.md addendum) removes nine parts of DFG v1.3 at once.  Each run here puts ONE of them back: the core's
constructor arguments with one argument returned to DFG's default, run as the evaluation runs (harness.evaluate: the same
training sets, test sets, fit rng default_rng([fn_seed(t), seed, n, 77]) and column permutation; the frozen dfg13.py,
md5-checked, DFG(readout="logit", **kw) inside harness.Permuted; seeds 0 and 1; every grid n), on the targets where the
core moved most (chosen after reading the core's results: post hoc).  With every argument back, the learner is DFG alone.

usage: OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python leavein.py [<config> ...]     (default: every config below)
writes results/leavein/toy__dfg13-core+<config>-perm__<suite>.json (harness format, plus 'kw' and 'config')
"""
import os, sys, json
HERE = os.path.dirname(os.path.abspath(__file__)); P11 = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, P11)
import eval_dfg as E                                                   # noqa: E402
TH, boolfuncs = E.TH, E.boolfuncs
OUT = os.path.join(HERE, "results", "leavein"); os.makedirs(OUT, exist_ok=True)
CORE = {"readout": "ls", "sum_inner": False, "sum_seeds": [0, 3, 2], "blocks": False, "max_ext_bases": 0, "local_max": 0,
        "K": 3, "K_hi": 3, "background": False}                       # = the core's kw in its result files (checked below)
GAIN = ["dlheld3/h3rf0", "dlheld3/h3rf1", "dlheld4/h4rf1", "designed/and3", "dlheld7/f7_11", "random/rf06", "dlheld3/dlist8",
        "dlfamdev/fd_02", "dlfamdev/fd_11", "dlheld5/h5rf0", "designed/rand0", "designed/rand1"]      # the core's 12 largest gains
HALF = ["dlheld/thr30", "dlheld2/thr20", "dlheld/maj15", "dlheld2/maj21", "designed/maj9", "designed/thr10", "dlheld7/f7_01"]
CONFIGS = {   # name: (the argument(s) put back, targets)
    "deg46": ({"K": 4, "K_hi": 6}, ["designed/par4", "random/rf17", "dlheld3/poly4", "dlheld/par5"]),
    "comp": ({"max_ext_bases": 32, "local_max": 12}, ["designed/par4", "random/rf17", "dlheld3/poly4", "dlheld/par5"]),
    "blocks": ({"blocks": True}, HALF + ["dlheld2/sym8"] + GAIN),
    "logit": ({"readout": "logit"}, HALF + GAIN),
    "bg": ({"background": True}, HALF + GAIN),
    "weighted": ({"sum_inner": True}, ["dlheld6/h6_10", "dlheld5/h5t0", "dlheld5/h5s2", "dlheld7/f7_09", "dlheld2/sym8"]),
    "eig": ({"sum_seeds": [2, 3, 2]}, ["dlheld6/h6_10", "dlheld5/h5t0", "dlheld5/h5s2", "dlheld7/f7_09", "dlheld2/sym8"]),
    # added after reading the first leave-one-in results (the background, for the sum targets the core loses on): the same
    # change as "bg", on other targets, in files of their own
    "bg2": ({"background": True}, ["dlheld6/h6_10", "dlheld5/h5t0", "dlheld5/h5s2", "dlheld7/f7_09", "dlheld2/sym8"]),
    # two parts at once, after neither alone restored h6_10 (DFG alone without either loses it: noeig, noweighted)
    "weighted_eig": ({"sum_inner": True, "sum_seeds": [2, 3, 2]}, ["dlheld6/h6_10", "dlheld5/h5t0", "dlheld5/h5s2", "dlheld7/f7_09"]),
    # K back to 4 on the core's gains (K also sets every test's union bound, 4 K N): the same change as "deg46", other targets
    "deg46g": ({"K": 4, "K_hi": 6}, GAIN),
    # the gains no single part explained: composition back, and the background and the linear / spectral blocks together
    "compg": ({"max_ext_bases": 32, "local_max": 12}, ["dlheld3/h3rf0", "dlheld3/h3rf1", "dlheld3/dlist8", "dlheld4/h4rf1",
                                                       "dlheld5/h5rf0", "dlfamdev/fd_02"]),
    "bg_blocks": ({"background": True, "blocks": True}, ["dlheld3/h3rf0", "dlheld3/h3rf1", "dlheld3/dlist8", "dlheld4/h4rf1",
                                                         "dlheld5/h5rf0", "dlfamdev/fd_02"]),
}


def targets(suite):
    return getattr(boolfuncs, E.DL[suite])(30) if suite in E.DL else TH.suite_targets(suite, 30)[0]


def run(cfg):
    put, tl = CONFIGS[cfg]; kw = dict(CORE, **put)
    by = {}
    for x in tl:
        su, t = x.split("/"); by.setdefault(su, []).append(t)
    for su, fns in by.items():
        p = os.path.join(OUT, f"toy__dfg13-core+{cfg}-perm__{su}.json")
        if os.path.exists(p) and set(json.load(open(p))["fns"]) >= set(fns):
            continue
        kk = dict(kw); kk["sum_seeds"] = tuple(kk["sum_seeds"])
        L = E.make_learner("dfg13", kk, f"core+{cfg}")
        if su in E.DL:
            res = TH.evaluate(L, suite=su, fns=fns, seeds=[0, 1], targets=targets(su), results_dir=None, verbose=False)
        else:
            res = TH.evaluate(L, suite=su, fns=fns, seeds=[0, 1], verbose=False)
        res.update(kw=kw, config=cfg, put_back=put)
        json.dump(res, open(p, "w"))
        print(f"core+{cfg} {su}: {', '.join(fns)}", flush=True)


if __name__ == "__main__":
    ref = json.load(open(os.path.join(P11, "results", "toy__dfg13-core-perm__designed.json")))["kw"]
    assert ref == CORE, (ref, CORE)
    for cfg in (sys.argv[1:] or list(CONFIGS)):
        run(cfg)
