#!/usr/bin/env bash
set -euo pipefail
task_lean_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
task_project="${1:-$task_lean_dir}"
task_lake="${2:-lake}"
task_build_dir="$task_lean_dir/.build"
mkdir -p "$task_build_dir"
cd "$task_project"
export LEAN_PATH="$task_build_dir${LEAN_PATH:+:$LEAN_PATH}"
"$task_lake" build Mathlib.Analysis.InnerProductSpace.SingularValues \
  Mathlib.Analysis.InnerProductSpace.Trace \
  Mathlib.Analysis.SpecialFunctions.Trigonometric.Series \
  Mathlib.Analysis.Convex.SpecificFunctions.Basic
for task_module in TwoBallGeometry NetworkBallCover FiniteConcentration FiniteMaurey \
  MaureyLayerCompression SequentialMaurey AnalyticPrefixReduction PolynomialPrefix \
  FreezeSigns BooleanRelevant; do
  "$task_lake" env lean -R "$task_lean_dir" \
    -o "$task_build_dir/$task_module.olean" "$task_lean_dir/$task_module.lean"
done
