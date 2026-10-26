#!/usr/bin/env bash
set -euo pipefail
task_source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
task_project="${1:-$task_source/../../../lean}"
task_lake="${2:-lake}"
task_output="$task_source/.build/release"
mkdir -p "$task_output"

# Compile local files anew. Imported collection modules are built by Lake from
# the selected project's sources, with its pinned Lean/mathlib dependencies.
python3 - "$task_source" "$task_output" <<'PY'
from pathlib import Path
import json, re, sys
source, output = map(Path, sys.argv[1:])
files = {p.stem: p for p in source.glob('*.lean')}
imports = {name: [m for line in p.read_text().splitlines()
                 if re.match(r'^import\s+', line)
                 for m in line.split('--', 1)[0].split()[1:]]
           for name, p in files.items()}
external = sorted({m for ms in imports.values() for m in ms if m not in files})
ordered, visiting = [], set()
def visit(name):
    if name in ordered: return
    if name in visiting: raise RuntimeError('cyclic local imports: ' + name)
    visiting.add(name)
    for dep in imports[name]:
        if dep in files: visit(dep)
    visiting.remove(name)
    ordered.append(name)
for name in sorted(files): visit(name)
(output/'external-targets.txt').write_text('\n'.join(external)+'\n')
(output/'local-order.txt').write_text('\n'.join(ordered)+'\n')
(output/'imports.json').write_text(json.dumps(imports, indent=2)+'\n')
PY

cd "$task_project"
mapfile -t task_external < "$task_output/external-targets.txt"
if ((${#task_external[@]})); then "$task_lake" build "${task_external[@]}"; fi
export LEAN_PATH="$task_output${LEAN_PATH:+:$LEAN_PATH}"
while IFS= read -r task_module; do
  echo "Checking $task_module"
  "$task_lake" env lean -R "$task_source" \
    -o "$task_output/$task_module.olean" "$task_source/$task_module.lean"
done < "$task_output/local-order.txt"

