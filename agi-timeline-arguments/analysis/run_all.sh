#!/usr/bin/env bash
# Reproduce every analysis. Run from this directory: bash run_all.sh
# Python runs in isolated mode (-I) because the scripts read downloaded files.
set -euo pipefail
cd "$(dirname "$0")"
R=data/raw
M=$R/metr_eval_analysis_public
python3 -I c_metr_horizons.py --runs-th10 $M/th1_0/runs.jsonl --runs-th11 $M/th1_1/runs.jsonl \
    --release-dates $M/release_dates.yaml                     > outputs/c_log.txt
python3 -I a_hyperbolic_fits.py --roodman $R/roodman_gwp/GWP.xlsx --hyde $R/owid_datasets/pop_hyde_un/data.csv \
    --maddison $R/owid_datasets/maddison2020/data.csv \
    --epoch $R/epoch_notable_models_mirror/notable_ai_models.csv --metr outputs/c_agent_horizons.csv > outputs/a_log.txt
python3 -I b_brain_compute.py --epoch $R/epoch_notable_models_mirror/notable_ai_models.csv \
    --forecasts data/manual/brain_compute_forecasts.csv       > outputs/b_log.txt
python3 -I d_prediction_base_rates.py --predictions data/manual/ai_predictions.csv > outputs/d_log.txt
python3 -I e_luck_model.py --predictions data/manual/ai_predictions.csv --famous data/manual/famous_forecasts.csv \
    --fits outputs/a_hyperbolic_fits_all.csv                  > outputs/e_log.txt
echo "done: outputs/*.txt|csv, figures/*.png"
