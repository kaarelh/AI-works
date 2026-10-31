#!/usr/bin/env bash
set -euo pipefail
task_source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
task_project="${1:-$task_source/../../../lean}"
task_lake="${2:-lake}"
task_output="$task_source/.build/release"

# Never inherit scratch or earlier local object directories. Lake supplies the
# pinned project's own build and dependency paths to its `env lean` commands.
unset LEAN_PATH

# All local modules use bare import names, including sources in analytic/.
# Validate the complete source graph before replacing the generated output.
python3 - "$task_source" "$task_output" <<'PY'
from pathlib import Path
import hashlib
import json
import re
import shutil
import sys

source, output = map(Path, sys.argv[1:])
files = {}
for path in sorted(source.rglob('*.lean')):
    relative = path.relative_to(source)
    if any(part.startswith('.') for part in relative.parts):
        continue
    name = path.stem
    if name in files:
        raise SystemExit(
            f'Local module basename collision: {files[name]} and {path}')
    files[name] = path
if not files:
    raise SystemExit('No local Lean sources found')


def strip_comments(text):
    # Preserve newlines so import commands are still parsed by line. Lean
    # supports nested block comments; none of their contents are imports.
    result, depth, index, in_string = [], 0, 0, False
    while index < len(text):
        pair = text[index:index + 2]
        if depth:
            if pair == '/-':
                depth += 1
                index += 2
            elif pair == '-/':
                depth -= 1
                index += 2
            else:
                result.append('\n' if text[index] == '\n' else ' ')
                index += 1
        elif in_string:
            result.append(text[index])
            if text[index] == '\\' and index + 1 < len(text):
                result.append(text[index + 1])
                index += 2
            else:
                if text[index] == '"':
                    in_string = False
                index += 1
        elif text[index] == '"':
            in_string = True
            result.append(text[index])
            index += 1
        elif pair == '/-':
            depth = 1
            result.append(' ')
            index += 2
        elif pair == '--':
            end = text.find('\n', index)
            index = len(text) if end < 0 else end
        else:
            result.append(text[index])
            index += 1
    if depth:
        raise ValueError('Unclosed block comment')
    return ''.join(result)


def module_imports(path):
    imports = []
    for line in strip_comments(path.read_text()).splitlines():
        match = re.match(r'^\s*(?:public\s+)?import\s+(.+?)\s*$', line)
        if match:
            imports.extend(match.group(1).split())
    return imports


imports = {name: module_imports(path) for name, path in files.items()}
external = sorted({module for dependencies in imports.values()
                   for module in dependencies if module not in files})
ordered, active, complete = [], [], set()


def visit(name):
    if name in complete:
        return
    if name in active:
        cycle = active[active.index(name):] + [name]
        raise SystemExit('Cyclic local imports: ' + ' -> '.join(cycle))
    active.append(name)
    for dependency in imports[name]:
        if dependency in files:
            visit(dependency)
    active.pop()
    complete.add(name)
    ordered.append(name)


for name in sorted(files):
    visit(name)

if output.is_symlink():
    output.unlink()
elif output.exists():
    shutil.rmtree(output)
output.mkdir(parents=True)
(output / 'external-targets.txt').write_text(''.join(m + '\n' for m in external))
(output / 'local-order.txt').write_text(''.join(m + '\n' for m in ordered))
(output / 'local-sources.tsv').write_text(''.join(
    f'{name}\t{files[name]}\n' for name in ordered))
(output / 'imports.json').write_text(json.dumps(imports, indent=2) + '\n')
(output / 'source-hashes.json').write_text(json.dumps({
    name: {'path': str(files[name].relative_to(source)),
           'sha256': hashlib.sha256(files[name].read_bytes()).hexdigest()}
    for name in ordered
}, indent=2) + '\n')
print(f'Fresh build: {len(ordered)} local modules; '
      f'{len(external)} external Lake targets', flush=True)
PY

cd "$task_project"
task_external=()
while IFS= read -r task_target; do
  task_external+=("$task_target")
done < "$task_output/external-targets.txt"
if ((${#task_external[@]})); then
  "$task_lake" build "${task_external[@]}"
fi
export LEAN_PATH="$task_output"
while IFS=$'\t' read -r task_module task_file; do
  echo "Checking $task_module"
  "$task_lake" env lean -R "$(dirname -- "$task_file")" \
    -o "$task_output/$task_module.olean" "$task_file"
done < "$task_output/local-sources.tsv"
