"""Job queue: at most NSLOT training processes at once. Re-reads jobs.txt whenever a slot frees,
so jobs can be appended/reordered while it runs.  jobs.txt lines:  name | gd_train2.py args
A job is skipped if runs/<name>.json exists (done) or it is running.  Slot 2 waits for the
PIDs given on the command line (earlier jobs) to exit."""
import os, subprocess, sys, time
HERE = os.path.dirname(os.path.abspath(__file__))
NSLOT = 2
wait_pids = [int(x) for x in sys.argv[1:]]

def alive(pid):
    try:
        os.kill(pid, 0); return True
    except OSError:
        return False

def jobs():
    out = []
    for ln in open(os.path.join(HERE, "jobs.txt")):
        ln = ln.strip()
        if not ln or ln.startswith("#"):
            continue
        name, args = [s.strip() for s in ln.split("|", 1)]
        out.append((name, args))
    return out

running = {}
while True:
    for n, pr in list(running.items()):
        if pr.poll() is not None:
            print(time.strftime("%H:%M:%S"), "finished", n, pr.returncode, flush=True); del running[n]
            if not os.path.exists(os.path.join(HERE, "runs", n + ".json")):
                open(os.path.join(HERE, "runs", n + ".skip"), "w").write("failed\n")
    limit = NSLOT if not any(alive(p) for p in wait_pids) else 1
    if len(running) < limit:
        todo = [(n, a) for n, a in jobs() if n not in running
                and not os.path.exists(os.path.join(HERE, "runs", n + ".json"))
                and not os.path.exists(os.path.join(HERE, "runs", n + ".skip"))]
        if os.path.exists(os.path.join(HERE, "STOP")):
            todo = []
        if todo:
            n, args = todo[0]
            cmd = f"exec python3 -I {HERE}/gd_train2.py {args} --json {HERE}/runs/{n}.json > {HERE}/runs/{n}.txt 2>&1"
            running[n] = subprocess.Popen(cmd, shell=True)
            print(time.strftime("%H:%M:%S"), "started", n, args, flush=True)
            continue
        if not running:
            break
    time.sleep(10)
print("all done", flush=True)
