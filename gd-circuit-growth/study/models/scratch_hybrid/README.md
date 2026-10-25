# Calibration record for models/hybrid.py (see ../../HYBRID.md, section 2)

Scripts as run in the session (paths point into the session scratchpad; kept for the record, not maintained).

| file | what |
|---|---|
| `harness.py`, `static1.py` → `static1.log` | cached race fits + NNGP grams on the networks' partial cells; static readout variants (score mixing, race + kernel ridge on the race's residual, joint kernel ridge with gate weight cg) |
| `diag1.py` | first signal / sample-noise decomposition on maj9 and mux |
| `hybrid_static.py` | the first, static-background implementation (Cholesky + Woodbury, exact kernel up to n = 4096) used by `try_specs.py` and `grid_calib.py` |
| `partial_eval.py`, `try_specs.py` → `try_rho_static_partial.log`, `try_specs1.log` | per-example agreement on the partial cells only, static background |
| `try_specs2.py` → `try_specs_flow.log` (flow, sign stop, no end-of-training interpolation), `try_specs_flow2.log` (with it), `try_specs_flow3.log` (beta = 0, 0.5) | the same for the flow background (models/hybrid.py as it stood at each point) |
| `grid_calib.py` → `grid_calib1.log` | CALIB grid (n <= 4096), static background |
| `grid_flow.py` → `grid_flow2.log` (sign stop), `grid_flow3.log`, `grid_flow4.log` (MSE stop and more sign-stop points) | CALIB grid (n <= 4096), flow background |
| `kernels.py` → `kernels.log` | which kernel agrees best with the networks' mistakes (NNGP, NTK and its layer terms, one-layer NNGP) |
| `deg1.py` | first look at the degree-1 sample-noise direction |
| `test_flow.py`, `test_mse.py`, `check_none.py` | spot checks (mode 'none' reproduces the race: same gates and clock, predictions equal up to rounding; MSE stop on MAJ3 etc.) |
| `specparse.py` | parses the `key=value;...` setting strings |

The constants were chosen from the CALIB grid (`grid_*.log`). The partial-cell scripts also printed the HELDOUT agreement,
which was visible during the exploration of designs; it moved in parallel with the CALIB column throughout.

Final runs (study/HYBRID.md sections 1-3): `eval_hybrid*.log` (full-grid evaluations, models/run_hybrid_eval.py),
`diagnose_summary.log` (hybrid_diagnose.py), `ceiling.log` (hybrid_diagnose.py ceiling), `width.log` (hybrid_width.py),
`report.log` (hybrid_report.py), `dscale15.log`, `dscale60.log` (hybrid_dscale.py).
`timecourse.py` (first version of `hybrid_diagnose.py timecourse`); `test_memo.py` → `test_memo.log`: spot check of the
'memorise first' variant (static background with beta = 0, scale-free utilities, fixed growth time) on 8 cells.
