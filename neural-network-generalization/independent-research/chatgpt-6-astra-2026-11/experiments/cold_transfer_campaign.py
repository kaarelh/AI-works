"""Long paired-initialization diagnostics; no MCMC mixing certificate.

The scales and sample sizes are exploratory and are not claimed to lie
inside the conservative sufficient regime of the transfer theorem.
"""
from pathlib import Path
import concurrent.futures
import datetime
import hashlib
import json
import os
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "results/cold_transfer"
OUT.mkdir(exist_ok=True)
START = time.monotonic()
DEADLINE = START + 8.4 * 3600
SWEEPS = 300000
JOBS = [
    (scale, draws, data, mode)
    for scale in (1.0, 0.3, 0.1)
    for draws in (256, 512)
    for data in (71, 72)
    for mode in ("condensed", "prior_fit")
]
manifest = dict(
    start_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    dimension=8, width=1024, sweeps=SWEEPS, record_every=1000,
    parallel_processes=2, wall_budget_hours=8.4,
    scope="Exploratory Markov-chain diagnostics; no certified posterior approximation.",
    source_sha256=hashlib.sha256(
        (ROOT / "experiments/parity_relu_cold_transfer.cpp").read_bytes()
    ).hexdigest(),
    jobs=[dict(scale=s, draws=m, data_seed=d, initialization=i) for s, m, d, i in JOBS],
)
(OUT / "campaign.json").write_text(json.dumps(manifest, indent=2) + "\n")


def run(index, job):
    scale, draws, data, mode = job
    name = f"d8_N1024_tau{scale:g}_m{draws}_data{data}_{mode}"
    seed = 7000 + index
    command = [
        str(ROOT / "tools/parity_relu_cold_transfer"), "8", "1024", str(seed),
        mode, str(SWEEPS), "1000", str(OUT / (name + ".jsonl")),
        "0.5", f"cold-{scale}", str(draws), str(data),
    ]
    remaining = DEADLINE - time.monotonic()
    if remaining <= 0:
        return dict(name=name, status="not_started_deadline", command=command)
    begin = time.monotonic()
    print(json.dumps(dict(name=name, status="started")), flush=True)
    with (OUT / (name + ".log")).open("w") as log:
        try:
            result = subprocess.run(
                command, stdout=log, stderr=subprocess.STDOUT,
                timeout=min(remaining, 4200), env={**os.environ, "OMP_NUM_THREADS": "1"}
            )
            status = "complete" if result.returncode == 0 else f"exit_{result.returncode}"
        except subprocess.TimeoutExpired:
            status = "timeout"
    return dict(name=name, status=status, seconds=time.monotonic() - begin,
                command=command)


with (OUT / "job_status.jsonl").open("w") as status:
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        futures = [pool.submit(run, index, job) for index, job in enumerate(JOBS)]
        for future in concurrent.futures.as_completed(futures):
            row = future.result()
            status.write(json.dumps(row) + "\n")
            status.flush()
            print(json.dumps(row), flush=True)
print(json.dumps(dict(status="campaign_finished", seconds=time.monotonic() - START)), flush=True)
