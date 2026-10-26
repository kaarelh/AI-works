"""Part 8 held-out job runner: a pool of P workers; image jobs hold a global lock (memory); resumable via done markers.
usage: python run_jobs.py P design [design ...]"""
import os, sys, subprocess, threading, time, fcntl
H = "/home/user/AI-works/gd-circuit-growth/study/hybrid"
J = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/jobs"
sys.path.insert(0, H)
import common
DATA = common.SH.DATA
SUITES = {"random": [f"rf{i:02d}" for i in range(20)],
          "dlheld": ['maj15', 'thr30', 'majxor', 'majmaj5', 'par5', 'mux6', 'stair6', 'inter2', 'majpar5', 'hrf0', 'hrf1', 'hrf2'],
          "dlheld2": ['thr20', 'maj21', 'xmaj', 'dnf4x2', 'sym8', 'h2rf0', 'h2rf1'],
          "dlheld3": ['cnf3', 'sym9', 'dlist8', 'thrint', 'par3or', 'poly4', 'mixmaj', 'mux11', 'h3rf0', 'h3rf1']}
BIG = ["sleep", "connect_4", "adult", "krkopt", "letter", "nursery", "mushroom", "ring", "twonorm", "magic"]
P = int(sys.argv[1]); designs = sys.argv[2:]
jobs = []
for d in designs:
    spec = f"{d}.learner:Learner"
    jobs += [(f"{d}__img_{ds}", ["python3", "run_heldout.py", spec, f"img:{ds}"], True) for ds in ("mnist", "fashion_mnist")]
    tab = [x for x in DATA.HELDOUT + DATA.HELDOUT2 if x not in ("mnist", "fashion_mnist")]
    tab = sorted(tab, key=lambda x: (x not in BIG, BIG.index(x) if x in BIG else 0))
    jobs += [(f"{d}__tab_{ds}", ["python3", "eval_real.py", spec, ds], False) for ds in tab]
    for suite, fns in SUITES.items():
        for k in range(0, len(fns), 2):
            jobs.append((f"{d}__toy_{suite}_{k // 2}", ["python3", "eval_toy.py", spec, suite, ",".join(fns[k:k + 2]), f"--part={k // 2:02d}"], False))
lock = threading.Lock(); img_lock = threading.Lock(); queue = list(jobs)
env = dict(os.environ, OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", MKL_NUM_THREADS="1")


def worker():
    while True:
        with lock:
            # take the first pending job; skip image jobs while another image job runs
            pick = None
            for i, (name, cmd, img) in enumerate(queue):
                if os.path.exists(f"{J}/{name}.done"):
                    queue.pop(i); pick = "skip"; break
                if img and img_lock.locked():
                    continue
                pick = queue.pop(i); break
            if pick is None:
                if not queue:
                    return
        if pick is None:
            time.sleep(5); continue
        if pick == "skip":
            continue
        name, cmd, img = pick
        if img:
            img_lock.acquire()
        t0 = time.time()
        with open(f"{J}/{name}.log", "w") as f:
            rc = subprocess.run(["nice", "-n", "5"] + cmd, cwd=H, env=env, stdout=f, stderr=subprocess.STDOUT).returncode
        if img:
            img_lock.release()
        open(f"{J}/{name}." + ("done" if rc == 0 else "failed"), "w").write(f"{time.time() - t0:.0f}s rc={rc}\n")
        print(f"{name} rc={rc} {time.time() - t0:.0f}s", flush=True)


T = [threading.Thread(target=worker) for _ in range(P)]
[t.start() for t in T]; [t.join() for t in T]
print("ALL DONE", flush=True)
