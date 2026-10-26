# Part 8 orchestration scripts (working branch only; not published to `main`)

The job queues that ran Part 8's held-out evaluation and references on a 4-core machine, kept for the record. They
hard-code scratch paths of the session that ran them. Order of use: `queue.sh` and `refs.sh` (baselines, references),
`run_jobs.py` (held-out runs, natural input order), `jax_lane.sh` → `jax_lane2.sh`, `jax_laneB.sh`, `jax_lane3.sh`
(network variants, strong MLP), `img_l2unit.sh` (image MLP at n = 60000, per seed), `run_jobs2.py` (permuted toy runs),
`run_jobs3.py` (post-hoc ablations). The commands they run are listed in `../HYBRID.md`, "Reproduce".
