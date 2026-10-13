#!/bin/sh
# Study-1 coders and judges on the GPT replication (records converted by src/s1_astra_adapt.py), same scripts and
# coder aliases as study 1 (sonnet/opus/haiku resolve to the 5.5 models). Two passes: the second retries failures.
cd "$(dirname "$0")/.." || exit 1
for pass in 1 2; do
  (cd src && python3 score.py ../runs/gpt_raw ../results/scored_gpt.jsonl)
  python3 src/code_loop_v2.py runs/gpt_loop_v2_sonnet runs/gpt_raw --model sonnet --workers 4 &
  python3 src/code_loop_v2.py runs/gpt_loop_v2_opus   runs/gpt_raw --model opus   --workers 4 &
  python3 src/judge_loop.py   runs/gpt_raw runs/gpt_loop_judge --workers 4 &
  python3 src/judge.py        runs/gpt_raw results/scored_gpt.jsonl runs/gpt_judge --workers 6 &
  wait
done
(cd src && python3 score.py ../runs/gpt_raw ../results/scored_gpt.jsonl ../runs/gpt_loop_judge sonnet=../runs/gpt_loop_v2_sonnet opus=../runs/gpt_loop_v2_opus)
echo ALLDONE
