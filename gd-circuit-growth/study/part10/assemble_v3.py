"""Assemble v3 = hyb_portfolio3 by the integration rule (PROTOCOL.md): the adopted image candidate's learner file (a copy of
v2 with one change in the image member) with its DFG member loaded from DFG v1.3 (the adopted toy component, copied
into part10/hyb_portfolio3/dfg13.py), the default name set to hyb_portfolio3; nothing else changes.  Then the identity
checks, each on development data only:
  toy      v3 == p10_sum (the toy candidate) on toy inputs: test predictions of eval_toy-style fits, inputs permuted
  image    v3 == the image candidate on images: predictions of one small qd_dev fit (n = 300)
  tabular  v3 == v2 on a tabular set where DFG does not run (optdigits, n = 300) and == p10_sum where it does
           (kr_vs_kp, n = 300)
usage: python assemble_v3.py <p10_hier|p10_codes>          writes hyb_portfolio3/ and hyb_portfolio3/ASSEMBLY.md"""
import os, sys, re, shutil, hashlib, json, importlib.util, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); STUDY = os.path.dirname(HERE)
img = sys.argv[1]; assert img in ("p10_hier", "p10_codes")
out = os.path.join(HERE, "hyb_portfolio3"); os.makedirs(out, exist_ok=True)
md5 = lambda p: hashlib.md5(open(p, "rb").read()).hexdigest()

src = open(os.path.join(HERE, img, "learner.py")).read()
old = 'os.path.join(STUDY, "part9", "p9_sum", "dfg12.py")'
assert src.count(old) == 1, "the image candidate must load v2's DFG v1.2 exactly once"
new_src = src.replace(old, 'os.path.join(STUDY, "part10", "hyb_portfolio3", "dfg13.py")')
new_src = new_src.replace('spec_from_file_location("hp_dfg12"', 'spec_from_file_location("hp_dfg13"')
assert new_src.count(f'name="{img}"') == 1
new_src = new_src.replace(f'name="{img}"', 'name="hyb_portfolio3"')
head = (f'"""hyb_portfolio3 (v3, Part 10): v2 (part9/hyb_portfolio2/learner.py, md5 e38af40493816ef1bc82e4f16428dcdf) with the\n'
        f'two components adopted by the Part 10 integration rule (part10/PROTOCOL.md): the image member of {img}\n'
        f'(part10/{img}/learner.py, md5 {md5(os.path.join(HERE, img, "learner.py"))}; this file is that file with the changes\n'
        f'below) and the DFG member DFG v1.3 of p10_sum (part10/p10_sum/dfg13.py, md5 {md5(os.path.join(HERE, "p10_sum", "dfg13.py"))},\n'
        f'copied here as dfg13.py).  Changes against {img}/learner.py: this header, the DFG module path (and its module\n'
        f'name), the default name.  Assembled by part10/assemble_v3.py.\n\n')
assert new_src.startswith('"""')
new_src = head + new_src[3:]
open(os.path.join(out, "learner.py"), "w").write(new_src)
shutil.copy(os.path.join(HERE, "p10_sum", "dfg13.py"), os.path.join(out, "dfg13.py"))
open(os.path.join(out, "__init__.py"), "w").close()
assert md5(os.path.join(out, "dfg13.py")) == md5(os.path.join(HERE, "p10_sum", "dfg13.py"))

# ---- identity checks
sys.path.insert(0, os.path.join(STUDY, "hybrid")); sys.path.insert(0, os.path.join(STUDY, "part9")); sys.path.insert(0, STUDY)
import common
DATA = common.SH.DATA
_ts = importlib.util.spec_from_file_location("toy_h", os.path.join(STUDY, "discrete_learner", "harness.py"))
TH = importlib.util.module_from_spec(_ts); _ts.loader.exec_module(TH)


def load(path, tag):
    sp = importlib.util.spec_from_file_location(tag, path); m = importlib.util.module_from_spec(sp); sp.loader.exec_module(m)
    return m.Learner()


V3 = load(os.path.join(out, "learner.py"), "v3_check"); T = load(os.path.join(HERE, "p10_sum", "learner.py"), "t_check")
I = load(os.path.join(HERE, img, "learner.py"), "i_check"); V2 = load(os.path.join(STUDY, "part9", "hyb_portfolio2", "learner.py"), "v2_check")
rep = dict(image_component=img, md5=dict(learner=md5(os.path.join(out, "learner.py")), dfg13=md5(os.path.join(out, "dfg13.py"))), checks=[])
import boolfuncs
toy = [("designed", "parmaj", boolfuncs.make_suite), ("dlsymdev", "sym7", boolfuncs.make_dl_symdev_suite),
       ("dlfamdev", "fd_09", boolfuncs.make_dl_famdev_suite), ("dlfamdev", "fd_06", boolfuncs.make_dl_famdev_suite)]
for su, fn, mk in toy:
    f = mk(30)[fn]["fn"]
    for n in (64, 256, 1024):
        X, y = TH.train_data(f, fn, 0, n, 30); Xte, _ = TH.test_data(f, fn, 30)
        P = []
        for L in (V3, T):
            rng = np.random.default_rng([TH.fn_seed(fn), 0, n, 77]); pi = rng.permutation(30)
            o = common.ToyAdapter(L).fit(np.asarray(X)[:, pi], y, rng); P.append(np.asarray(o["predict"](np.asarray(Xte)[:, pi])))
        rep["checks"].append(dict(kind="toy", target=f"{su}/{fn}", n=n, identical=bool(np.array_equal(*P))))


def real(ds, n, A, B, tag):
    D = DATA.load(ds); pool, te = DATA.splits(D, 0); tr = pool[:n]; P = []
    for L in (A, B):
        o = L.fit(D["X"][tr], D["y"][tr], list(D["types"]), D["C"], np.random.default_rng([0, n, 4242]))
        P.append(np.asarray(o["predict"](D["X"][te])))
    rep["checks"].append(dict(kind=tag, dataset=ds, n=n, identical=bool(np.array_equal(*P))))


real("qd_dev", 300, V3, I, "image (v3 vs " + img + ")")
real("optdigits", 300, V3, V2, "tabular without DFG (v3 vs v2)")
real("kr_vs_kp", 300, V3, T, "tabular with DFG (v3 vs p10_sum)")
ok = all(c["identical"] for c in rep["checks"])
rep["all_identical"] = ok
json.dump(rep, open(os.path.join(out, "assembly_checks.json"), "w"), indent=1)
L = [f"# hyb_portfolio3 (v3): assembly", "", f"Image component: `{img}`; toy component: `p10_sum` (DFG v1.3).", "",
     f"- `learner.py` md5 `{rep['md5']['learner']}`", f"- `dfg13.py` md5 `{rep['md5']['dfg13']}` (= p10_sum/dfg13.py)", "",
     "Identity checks (development data; predictions on the test inputs):", ""]
L += [f"- {c['kind']}: {c.get('target', c.get('dataset'))} n = {c['n']}: {'identical' if c['identical'] else 'DIFFERENT'}" for c in rep["checks"]]
L += ["", f"All identical: **{ok}**."]
open(os.path.join(out, "ASSEMBLY.md"), "w").write("\n".join(L) + "\n")
print("\n".join(L))
