#!/bin/sh
# Runs all four simulations and the reconciliation checks in order (about 1-2 minutes in total).
set -e
cd "$(dirname "$0")"
python3 train_sim.py    > /dev/null
python3 loop_sim.py     > /dev/null
python3 stepsize_sim.py > /dev/null
python3 sieve_sim.py    > /dev/null
python3 reconcile_checks.py > /dev/null
grep -c "^CHECK" train_sim_output.txt loop_sim_output.txt stepsize_sim_output.txt sieve_sim_output.txt reconcile_checks_output.txt
echo "disagreements (agrees: NO):"
grep -c "agrees: NO" train_sim_output.txt loop_sim_output.txt stepsize_sim_output.txt sieve_sim_output.txt reconcile_checks_output.txt || true
