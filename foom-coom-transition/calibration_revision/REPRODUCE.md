# Research-compute calibration

From the project root, after installing `requirements.txt`:

```sh
python calibration_revision/compute_calibration.py
python calibration_revision/propagate_calibration.py
```

The first script reconstructs the research-compute normalization from the frozen public chip-capacity CSV. The second is a historical September sensitivity calculation using `forecast_revision/`; it does not replace the current October mixture. The saved calibration draws are also inputs to the theory investigation. No network is required. See `COMPUTE.md`, `HUMAN.md`, `OUTPUT.md` and `AUDIT.md` for the assumptions and checks.
