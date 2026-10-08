# Earlier forecast calculations

This directory preserves the September analysis used by the later research. Its scenario probabilities are historical; the current forecast is in `research_oct2026/synthesis/` and the current standalone text is [report.md](../report.md).

From the project root, after installing `requirements.txt`:

```sh
python forecast_revision/math_model.py
python forecast_revision/audit_math.py
python forecast_revision/make_forecast.py
```

The exact shared-feedback solver in `math_model.py` is also used by the current forecast. `MATH.md` gives the equations and global-optimum reasoning. The September prior, saved draws, reports and results are retained to reproduce historical comparisons and calibration propagation. The old document builder, which targeted a private local destination, is omitted; use the root `scripts/` for the current report.
