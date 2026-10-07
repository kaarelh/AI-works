# E9b: EInd/EInd2 merges with and without constant propagation

Command: `python3 experiments/e9b_nosimplify.py`; refuter budget 80; 12 random data pairs (seed 1234).

| constant propagation | pair merges | refuted | oracle calls |
|---|---|---|---|
| off (v1 oracle) | 12 | 0 | 282 |
| on (v2) | 12 | 10 | 149 |
