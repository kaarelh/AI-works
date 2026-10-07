# E9: refutation separation between targets

Command: `python3 experiments/e9_separation.py`.

## PA-mix targets

55 target pairs, 2190 random cross-target merges tested, 2190 refuted (100.0%). Pairs with an unrefuted merge:

none

Refuter: {'oracle_calls': 21, 'templates_tested': 12, 'oracle_time': 0.004, 'refuter_time': 0.028}

## ZF-mix targets

36 target pairs, 540 random cross-target merges tested, 540 refuted (100.0%). Pairs with an unrefuted merge:

none

Refuter: {'oracle_calls': 16, 'templates_tested': 5, 'oracle_time': 0.001, 'refuter_time': 0.013}

## PA near-miss targets

28 target pairs, 1052 random cross-target merges tested, 1051 refuted (99.9%). Pairs with an unrefuted merge:

| target a | target b | separated | tested |
|---|---|---|---|
| U_0add | U_add00 | 39 | 40 |

Examples of unrefuted cross-target merges (data; surviving minimal templates):

* U_0add / U_add00: data `0+0=0 ; 0+0+0=0+0`; surviving `?f0+0=?f0`

Refuter: {'oracle_calls': 124, 'templates_tested': 42, 'oracle_time': 0.007, 'refuter_time': 0.028}

## ZF near-miss targets

15 target pairs, 223 random cross-target merges tested, 223 refuted (100.0%). Pairs with an unrefuted merge:

none

Refuter: {'oracle_calls': 20, 'templates_tested': 5, 'oracle_time': 0.001, 'refuter_time': 0.004}

Wall time: 1.9s
