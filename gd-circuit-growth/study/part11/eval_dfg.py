"""Part 11: score DFG v1.3 ALONE (or an ablation of it, or the low-degree baseline) on a toy suite.

usage: python eval_dfg.py <learner> <suite> [--kw=<json>] [--fns=a,b] [--part=K] [--seeds=0,1] [--name=<tag>]
  learner  dfg13     DFG v1.3 as frozen in Part 10 (part10/hyb_portfolio3/dfg13.py, md5 69cabe5c...), run alone:
                     DFG(readout="logit").fit, i.e. its own small-n cross-validation between the default and the forced
                     variant (n <= 512), its own kernel background and its own budget (shares of one network run);
                     --kw passes constructor arguments (the ablations; the name gets the tag given by --name)
           lowdeg    the thresholded low-degree algorithm (discrete_learner/sparse_fourier.py, Part 6's feasibility
                     check, unchanged): every Fourier character of degree <= 4, kept if |mean(y chi_S)| passes a union
                     bound over its degree, products of kept characters, readout sign(sum of the kept coefficients)
  suite    designed | random | dlheld..dlheld7 | dlsymdev | dlfamdev | designed_d15 | designed_d60 | designed_d120
Every fit sees its input columns in a fresh random order (discrete_learner/harness.Permuted, name + '-perm'), as the
Part 8-10 portfolios did.  Writes part11/results/toy__<name>__<suite>[__partK].json and .md (the harness's own report).
"""
import os, sys, json, hashlib, importlib.util
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(STUDY, "discrete_learner"))          # 'harness' = the toy harness (dfg13 imports it)
sys.path.append(STUDY)                                                # boolfuncs
import harness as TH                                                  # noqa: E402
import boolfuncs                                                      # noqa: E402

DFG13 = os.path.join(STUDY, "part10", "hyb_portfolio3", "dfg13.py")
MD5 = "69cabe5c50345cb24079198ed52b562f"


def load_dfg13():
    assert hashlib.md5(open(DFG13, "rb").read()).hexdigest() == MD5, "dfg13.py is not the frozen DFG v1.3"
    sp = importlib.util.spec_from_file_location("dfg13_frozen", DFG13)
    m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
    return m


def make_learner(kind, kw, name=None):
    if kind == "dfg13":
        L = load_dfg13().DFG(**{"readout": "logit", **kw})
        L.name = "dfg13" + (f"-{name}" if name else "")
    elif kind == "lowdeg":
        import sparse_fourier
        L = sparse_fourier.SparseFourier(**kw); L.name = "lowdeg" + (f"-{name}" if name else "")
    else:
        raise ValueError(kind)
    return TH.Permuted(L)


DL = {"dlheld": "make_dl_heldout_suite", "dlheld2": "make_dl_heldout2_suite", "dlheld3": "make_dl_heldout3_suite",
      "dlsymdev": "make_dl_symdev_suite", "dlheld4": "make_dl_heldout4_suite", "dlheld5": "make_dl_heldout5_suite",
      "dlheld6": "make_dl_heldout6_suite", "dlfamdev": "make_dl_famdev_suite", "dlheld7": "make_dl_heldout7_suite"}


def run(kind, suite, kw=None, fns=None, part=None, seeds=None, name=None):
    kw = dict(kw or {})
    if "sum_seeds" in kw:
        kw["sum_seeds"] = tuple(kw["sum_seeds"])
    L = make_learner(kind, kw, name)
    if suite in DL:
        res = TH.evaluate(L, suite=suite, fns=fns, seeds=seeds, targets=getattr(boolfuncs, DL[suite])(30),
                          results_dir=os.path.join(TH.SCR, "results_" + suite))
    elif suite.startswith("designed_d"):
        d = int(suite[len("designed_d"):]); rdir = os.path.join(TH.SCR, f"results_d{d}")
        fns = fns or sorted(f[len("fixed_adam_"):-4] for f in os.listdir(rdir) if f.startswith("fixed_adam_"))
        res = TH.evaluate(L, suite="designed", fns=fns, d=d, seeds=seeds or [0, 1]); res["suite"] = suite
    else:
        res = TH.evaluate(L, suite=suite, fns=fns, seeds=seeds)
    res["kw"] = kw or {}
    tag = os.path.join(HERE, "results", f"toy__{L.name}__{suite}" + (f"__part{part}" if part else ""))
    json.dump(res, open(tag + ".json", "w"))
    open(tag + ".md", "w").close(); TH.report(res, file=tag + ".md")
    return res


if __name__ == "__main__":
    a = sys.argv[1:]; opt = {k[2:].split("=", 1)[0]: k.split("=", 1)[1] for k in a if k.startswith("--")}
    pos = [x for x in a if not x.startswith("--")]
    run(pos[0], pos[1], kw=json.loads(opt["kw"]) if "kw" in opt else None,
        fns=opt["fns"].split(",") if "fns" in opt else None, part=opt.get("part"),
        seeds=[int(s) for s in opt["seeds"].split(",")] if "seeds" in opt else None, name=opt.get("name"))
