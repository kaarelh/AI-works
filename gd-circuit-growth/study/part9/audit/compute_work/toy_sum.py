"""Compute audit (Part 9): DFG v1.2 sum-block FLOP share and CPU share inside hyb_portfolio2 toy fits (dev targets only).
Uses an instrumented COPY of p9_sum/dfg12.py (counters only; arithmetic unchanged)."""
import os, sys, time, json, importlib.util, numpy as np
STUDY = "/home/user/AI-works/gd-circuit-growth/study"
sys.path.insert(0, os.path.join(STUDY, "part9")); sys.path.insert(0, os.path.join(STUDY, "hybrid")); sys.path.append(STUDY)
import common
HERE = os.path.dirname(os.path.abspath(__file__))
sp = importlib.util.spec_from_file_location("toy_h", os.path.join(STUDY, "discrete_learner", "harness.py"))
TH = importlib.util.module_from_spec(sp); sp.loader.exec_module(TH)
saved = sys.modules.get("harness"); sys.modules["harness"] = TH
sp2 = importlib.util.spec_from_file_location("dfg12_instr", os.path.join(HERE, "dfg12_instr.py"))
DI = importlib.util.module_from_spec(sp2); sp2.loader.exec_module(DI)
if saved is not None: sys.modules["harness"] = saved
else: del sys.modules["harness"]
import hyb_portfolio2.learner as LM
LM._DFG = (DI, TH)
import boolfuncs
suites = {"designed": None, "dlsymdev": boolfuncs.make_dl_symdev_suite(30)}
cells = [a.split(":") for a in sys.argv[1:]]          # suite:target:n:seed
for suite, nm, n, s in cells:
    n, s = int(n), int(s)
    tg = TH.suite_targets("designed", 30)[0] if suite == "designed" else suites[suite]
    fn = tg[nm]["fn"]
    X, y = TH.train_data(fn, nm, s, n, 30)
    for k in DI.AUD: DI.AUD[k] = 0.0
    L = TH.Permuted(common.ToyAdapter(LM.Learner()))
    t0 = time.process_time(); fit = L.fit(X, y, np.random.default_rng([TH.fn_seed(nm), s, n, 77])); cpu = time.process_time() - t0
    A = dict(DI.AUD); gd = TH.gd_flops(30)
    print(json.dumps(dict(cell=f"{suite}:{nm}:{n}:{s}", total_over_GD=round(fit["flops"] / gd, 4), cpu=round(cpu, 1),
        dfg_over_GD=round(A["tot_fl"] / gd, 4), sum_over_GD=round(A["sum_fl"] / gd, 5), sum_share_of_total=round(A["sum_fl"] / fit["flops"], 4),
        sum_cpu=round(A["sum_cpu"], 1), dfg_fits=int(A["fits"]), rounds=int(A["rounds"]), max_round_sum_rel_fitGD=round(A["max_round_sum_rel"], 3),
        max_endloop_over_fitGD=round(A["overshoot"], 3), readout_over_GD=round(A["readout_fl"] / gd, 4),
        mt_elems=f"{A['mt_elems']:.3g}", stat_fl_over_GD=round(A["stat_fl"] / gd, 5),
        members=fit.get("info", {}).get("flops") and {k: round(v / gd, 4) for k, v in fit["info"]["flops"].items()})), flush=True)
