"""Part 8 post-hoc ablation runner (same mechanics as run_jobs2.py), multi-process safe: jobs claimed with O_EXCL claim files; image jobs serialized by a flock.
usage: python run_jobs2.py P   (job list built below; several runners may run at once)"""
import os, sys, subprocess, threading, time, fcntl
H = "/home/user/AI-works/gd-circuit-growth/study/hybrid"
J = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/jobs"
sys.path.insert(0, H)
import common
DATA = common.SH.DATA
SUITES = {"designed": ['dict', 'and3', 'maj3', 'maj9', 'thr10', 'par2', 'par3', 'par4', 'stair5', 'majpar', 'parmaj', 'mux',
                       'dnf3', 'dlist5', 'rmaj9', 'andxor', 'sparsepoly', 'rand0', 'rand1', 'rand2', 'rand3'],
          "random": [f"rf{i:02d}" for i in range(20)],
          "dlheld": ['maj15', 'thr30', 'majxor', 'majmaj5', 'par5', 'mux6', 'stair6', 'inter2', 'majpar5', 'hrf0', 'hrf1', 'hrf2'],
          "dlheld2": ['thr20', 'maj21', 'xmaj', 'dnf4x2', 'sym8', 'h2rf0', 'h2rf1'],
          "dlheld3": ['cnf3', 'sym9', 'dlist8', 'thrint', 'par3or', 'poly4', 'mixmaj', 'mux11', 'h3rf0', 'h3rf1']}
BIG = ["sleep", "connect_4", "adult", "krkopt", "letter", "nursery", "mushroom", "ring", "twonorm"]
jobs = []
# POST-HOC attribution ablations of the frozen primary design (constructor's `members` argument; code unchanged)
def spec(members, name):
    import json
    return "hyb_portfolio.learner:Learner:" + json.dumps(dict(members=members, name=name))
for suite in ("dlheld3", "designed"):
    jobs.append((f"abl_noDFG__toy_{suite}", ["python3", "eval_toy.py", spec(["gbt", "et", "knn", "lin"], "abl_noDFG"), suite, "--perm"], False))
    jobs.append((f"abl_dfg__toy_{suite}", ["python3", "eval_toy.py", spec(["dfg"], "abl_dfg"), suite, "--perm"], False))
real = list(DATA.HELDOUT2) + ["mnist", "fashion_mnist"]
for fam in ("gbt", "knn", "et", "lin"):
    for ds in real:
        jobs.append((f"abl_{fam}__quick_{ds}", ["python3", "eval_real.py", spec([fam], f"abl_{fam}"), ds, "--quick"], ds in ("mnist", "fashion_mnist")))
for ds in real:
    jobs.append((f"abl_noKNN__quick_{ds}", ["python3", "eval_real.py", spec(["gbt", "et", "lin", "dfg"], "abl_noKNN"), ds, "--quick"], ds in ("mnist", "fashion_mnist")))
env = dict(os.environ, OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", MKL_NUM_THREADS="1")
lock = threading.Lock(); pending = list(jobs)


def claim(name):
    try:
        os.close(os.open(f"{J}/{name}.claim", os.O_CREAT | os.O_EXCL)); return True
    except FileExistsError:
        return False


def worker():
    while True:
        with lock:
            pick = None
            while pending:
                name, cmd, img = pending.pop(0)
                if os.path.exists(f"{J}/{name}.done") or not claim(name):
                    continue
                pick = (name, cmd, img); break
        if pick is None:
            return
        name, cmd, img = pick
        lf = open(f"{J}/image.lock", "w") if img else None
        if lf:
            fcntl.flock(lf, fcntl.LOCK_EX)
        t0 = time.time()
        with open(f"{J}/{name}.log", "w") as f:
            rc = subprocess.run(["nice", "-n", "10"] + cmd, cwd=H, env=env, stdout=f, stderr=subprocess.STDOUT).returncode
        if lf:
            fcntl.flock(lf, fcntl.LOCK_UN); lf.close()
        open(f"{J}/{name}." + ("done" if rc == 0 else "failed"), "w").write(f"{time.time() - t0:.0f}s rc={rc}\n")
        if rc != 0:
            os.remove(f"{J}/{name}.claim")
        print(f"{name} rc={rc} {time.time() - t0:.0f}s", flush=True)


T = [threading.Thread(target=worker) for _ in range(int(sys.argv[1]))]
[t.start() for t in T]; [t.join() for t in T]
print("ALL DONE", flush=True)
