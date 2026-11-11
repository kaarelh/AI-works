#!/bin/bash
# usage: publish_revision_checks.sh <X> <mode>   (X in A B C E; mode for rewrite_paths2: N, A1 or A2)
set -e
S=/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic
R=/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning
X=$1; MODE=${2:-N}
for f in $S/stage/check-$X-r*.md; do
  [ -f "$f" ] || continue
  k=$(basename $f .md | sed "s/check-$X-r//")
  python3 $S/tools/rewrite_paths2.py verification $MODE $f $R/verification/$X-revision-check-$k.md
  python3 - "$R/verification/$X-revision-check-$k.md" <<'PY'
import sys
p=sys.argv[1]; t=open(p).read()
note="*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed. This check's scripts and outputs are in the `../checks/revision-check-*` folder named below.*\n\n"
lines=t.split('\n',1)
t=lines[0]+'\n\n'+note+(lines[1].lstrip('\n') if len(lines)>1 else '')
open(p,'w').write(t)
PY
  d=$S/stage/check-$X-r$k
  if [ -d "$d" ]; then
    mkdir -p $R/checks/revision-check-$X-$k
    find $d -maxdepth 1 -type f \( -name '*.py' -o -name '*.out' -o -name '*.txt' \) -exec cp {} $R/checks/revision-check-$X-$k/ \;
  fi
done
grep -rl "/tmp/claude\|scratchpad" $R/verification/$X-revision-check-*.md $R/checks/revision-check-$X-* 2>/dev/null || true
