#!/usr/bin/env bash
# Re-download the raw data used by the analyses into data/raw/, pinned to the exact commits
# used on 20 Nov 2026. Usage: bash fetch_data.sh [target_dir]   (default: data/raw)
# Only GitHub was reachable from the original session; ourworldindata.org, epoch.ai and
# metr.org were blocked, so every file comes from a GitHub repository.
set -euo pipefail
T="${1:-$(dirname "$0")/data/raw}"
GH=https://raw.githubusercontent.com
get() { mkdir -p "$(dirname "$2")"; curl -sSfL --retry 3 -o "$2" "$1"; echo "ok  $2"; }

# Roodman (2020) code-and-data archive: GWP.xlsx (population and GWP compilations)
R=$GH/droodman/Modeling-Human-Trajectory/5b7d41a352dffc232bee1bc0aad3c9a23d39f01b
get "$R/GWP.xlsx" "$T/roodman_gwp/GWP.xlsx"
get "$R/README.md" "$T/roodman_gwp/README.md"

# Our World in Data legacy dataset repository (owid/owid-datasets)
O=$GH/owid/owid-datasets/6155d4ca1ea14ef30e753010a25521eeb416e8a2/datasets
H="Global%20Population%20by%20Region%20with%20projections%20-%20HYDE%20%282016%29%20%26%20UN%20%282017%29"
get "$O/$H/$H.csv" "$T/owid_datasets/pop_hyde_un/data.csv"
get "$O/$H/README.md" "$T/owid_datasets/pop_hyde_un/README.md"
M="Maddison%20Project%20Database%202020%20%28Bolt%20and%20van%20Zanden%20%282020%29%29"
get "$O/$M/$M.csv" "$T/owid_datasets/maddison2020/data.csv"
get "$O/$M/README.md" "$T/owid_datasets/maddison2020/README.md"

# METR eval-analysis-public: raw runs for Time Horizon 1.0 and 1.1, release dates
E=$GH/METR/eval-analysis-public/52cb829c7a2efb2d659285c4b1768d191d97f8d2
get "$E/data/external/release_dates.yaml" "$T/metr_eval_analysis_public/release_dates.yaml"
for v in 0 1; do
  get "$E/reports/time-horizon-1-$v/data/raw/runs.jsonl" "$T/metr_eval_analysis_public/th1_$v/runs.jsonl"
  get "$E/reports/time-horizon-1-$v/params.yaml" "$T/metr_eval_analysis_public/th1_$v/params.yaml"
done

# Epoch AI 'Notable AI Models' CSV (CC BY 4.0), third-party GitHub snapshot (models to Sep 2024)
P=$GH/ManoHarshaSappa/Tracking_State_of_the_Art_AI-Models_and_Performance-/6ee90a8bf2dce67d09e7e13827b1fa8f396e65bb
get "$P/notable_ai_models.csv" "$T/epoch_notable_models_mirror/notable_ai_models.csv"
