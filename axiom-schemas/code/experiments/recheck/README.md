# recheck: the referee's independent checks, re-run against the v2 code

These scripts were written by the adversarial referee of the experiments track
(`research/tracks/experiments/referee_checks/`, report `referee.md`) and are copied here unchanged, so that
they can be re-run against the v2 oracle (PA case split, constant propagation), refuter and Min^al without
touching the referee's own directory and outputs. Outputs `*.out` in this directory are v2 results.

    sh run_recheck.sh     # about 10 minutes
