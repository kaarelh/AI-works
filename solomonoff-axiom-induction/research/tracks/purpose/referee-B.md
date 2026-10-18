# Track `purpose`: adversarial referee B (computation, counterexamples, references), 2026-10-18

*Status: IN PROGRESS (skeleton written first for restart safety). Code in `referee_code/`, outputs saved next to each script.*

## Progress log
* started; nothing from an earlier run existed (no `referee_code/`, no `referee-B.md`).
* reruns on scratch copies: p1, p2, p3, p4_toy, p4_kepler (two fits), p5 byte-identical to saved outputs; p4_allfits + p4_kepler --all running.
* rb1_locality (T1 exact atom model), rb2_scores (T2), rb3_errormodels (T3) written and run; outputs saved.
  Findings so far: (i) p1 part E comment "which a fixed question family cannot do" is false (rb1 D4: fixed width-5 grid,
  near 0 vs scattered 2.32 bits; every offset ranks near better); (ii) "never like squared error" in Summary 1 / T6.2 6a
  is false beyond near-point forecasts (rb1 D5: Gaussian-shaped forecasts graded by miss^2/(2 ln 2) at every Delta).
