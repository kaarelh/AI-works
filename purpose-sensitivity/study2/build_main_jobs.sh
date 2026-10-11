#!/bin/bash
# Build the study-2 main job files for the Claude side (allocation: DESIGN2.md, "Pilot results and decisions" §9).
set -e
cd "$(dirname "$0")/.."
CORE=claude-haiku-4-5,claude-sonnet-4-5,claude-opus-4-5,claude-haiku-5-5,claude-sonnet-5-5,claude-opus-5-5
EXT=claude-sonnet-4-6,claude-opus-4-6,claude-opus-4-7,claude-opus-4-8,claude-sonnet-5,claude-opus-5,claude-fable-5,claude-fable-5-1
EXT7=claude-sonnet-4-6,claude-opus-4-6,claude-opus-4-7,claude-opus-4-8,claude-sonnet-5,claude-opus-5,claude-fable-5
RUNGS5=survey,ai_ban,ai_accel,mining_ban,disfavoured_adv
J=runs2/main/jobs; mkdir -p $J
M="python3 src/make_jobs2.py --stage main"
# Ctx 1
$M --context analysis --arms $RUNGS5 --models $CORE --timeout 1800 --out $J/c1_core.jsonl
$M --context analysis --arms ai_ban_s1 --models claude-haiku-5-5,claude-opus-5-5 --timeout 1800 --out $J/c1_bridge.jsonl
$M --context analysis --arms $RUNGS5 --per-arm 3 --models $EXT --timeout 1800 --out $J/c1_ext.jsonl
$M --context analysis --arms disreputable_legal,fraud_illegal --models $CORE --timeout 1800 --out $J/z_c1_rungs_core.jsonl
$M --context analysis --arms disreputable_legal,fraud_illegal --per-arm 3 --models $EXT --timeout 1800 --out $J/z_c1_rungs_ext.jsonl
# Ctx 2a / 2b / 2c
V=$(echo $CORE | tr ',' '\n' | sed 's/^/del_v__/' | paste -sd,)
$M --context petition --arms $V --reps 0-9 --models $CORE --out $J/c2a.jsonl
$M --context petition --arms del_Anthropic,del_OpenAI,del_Google --models $CORE --out $J/c2b_core.jsonl
$M --context petition --arms del_Anthropic,del_OpenAI,del_Google --per-arm 3 --models $EXT --out $J/c2b_ext.jsonl
$M --context petition_cyber --arms del_Anthropic,del_OpenAI,del_Google,del_v__claude-opus-4-7,del_v__claude-opus-5-5 --reps 0-7 --models claude-opus-5-5 --out $J/z_c2c_opus55.jsonl
$M --context petition_cyber --arms del_Anthropic,del_OpenAI,del_Google --reps 0-3 --models claude-opus-5,claude-opus-4-8,claude-fable-5-1,claude-sonnet-5-5 --out $J/z_c2c_others.jsonl
# Ctx 3
$M --context quant --models $CORE --timeout 1800 --out $J/c3_core.jsonl
$M --context quant --arms neutral,deploy,self_restrict,ai_pause,ai_ban,instructed --per-arm 3 --models $EXT --timeout 1800 --out $J/c3_ext.jsonl
# Ctx 4
$M --context fidelity --models $CORE,claude-fable-5-1 --out $J/c4_core.jsonl
$M --context fidelity --probes --models $CORE,claude-fable-5-1 --out $J/c4_probes.jsonl
$M --context fidelity --arms agency --reps 0 --models $EXT7 --out $J/c4_ext_all.jsonl
python3 - <<'PY'
import json, re
src='runs2/main/jobs/c4_ext_all.jsonl'; out='runs2/main/jobs/c4_ext.jsonl'
keep=[l for l in open(src) if re.fullmatch(r'[RO]\d+', json.loads(l)['meta'].get('claim_id',''))]
open(out,'w').writelines(keep); print(len(keep), 'jobs ->', out)
PY
rm $J/c4_ext_all.jsonl
# probes
for c in analysis quant fidelity; do $M --context $c --realism --n-realism 2 --models $CORE --out $J/p_realism_$c.jsonl; done
$M --context petition --realism --n-realism 2 --arms del_Anthropic,del_OpenAI,del_Google,$V --models $CORE --out $J/p_realism_petition.jsonl
for c in analysis quant petition fidelity; do $M --context $c --identity --n-identity 1 --models $EXT --out $J/p_identity_$c.jsonl; done
# batches: everything except the z_ files first; the fraud/payday rungs and the cyber side probe last
ls $J/[cp]*.jsonl | xargs cat > runs2/main/batch1.jsonl
ls $J/z_*.jsonl | xargs cat > runs2/main/batch2.jsonl
wc -l runs2/main/batch1.jsonl runs2/main/batch2.jsonl
