#!/bin/bash
# Copy orchestration files (workflow scripts, path tools, the original brief) into working/ (stays on the working branch).
set -e
S=/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic
R=/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning
W=$R/working
mkdir -p $W/workflows $W/tools
cp /root/.claude/projects/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/workflows/scripts/*.js $W/workflows/
cp $S/wf/*.js $W/workflows/ 2>/dev/null || true
cp $S/tools/*.py $S/tools/*.sh $W/tools/
cp $S/BRIEF.md $W/original-brief.md
cat > $W/README.md <<'MD'
# Working files

*This folder stays on the working branch and is not published to `main`. It records how the notes of the [agnostic-learning note](../README.md) were produced.*

- `workflows/`: the orchestration scripts that ran the AI agents (provers, referees, revisers and checkers), with their prompts. Paths in them point to the session's scratch folder, which no longer exists.
- `tools/`: the scripts that rewrote scratch paths to the repository layout and published the reports.
- `original-brief.md`: the brief as the agents received it, before the operational instructions were removed ([`../research-notes/problem-brief.md`](../research-notes/problem-brief.md) is the published version).
MD
ls -R $W | head -40
