#!/bin/bash
# usage: check.sh Module name...
cd /home/user/AI-works/inferential-learning/lean
mod=$1; shift
f=InfLearn/$mod.lean
for n in "$@"; do
  # source: declaration of the (possibly dotted) name
  base="$n"
  src=$(grep -cE "^(@\[[^]]*\] )?(private )?(noncomputable )?(theorem|lemma|def|abbrev|structure|inductive|class) $(printf '%s' "$base" | sed "s/'/\\\\'/g; s/\./\\\\./g")( |$)" $f)
  aud=$(grep -cE "^#print axioms InfLearn\.$mod\.$(printf '%s' "$n" | sed 's/\./\\./g')\s*$" Audit.lean)
  echo "$mod.$n src=$src audit=$aud"
done
