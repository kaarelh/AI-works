#!/bin/sh
# Re-run every check of annotated-notes.md; outputs go to <script>.out
cd "$(dirname "$0")"
for s in a1_anchor a2_coupon a3_realizability a4_cost a4b_chain_bigger a4c_chain_size8 a4d_chain_formula a5_metamath a6_noise_fallacy a6b_bag_only a7_redex; do
  echo "== $s"; python3 $s.py > $s.out 2>&1 || echo "FAILED: $s"
done
python3 -c "exec(open(\"a5_metamath.py\").read().split(\"# motives over x\")[0]); s=mm_canon(eq(add(x,Z),x)); print(\"MM: mu(sigma)=\",mu(SIG_MM),\" |s|=\",size(s),\" paper bound=\",mu(s)-mu(SIG_MM),\" tuple bound=\", sum(size(t) for t in (eq(add(x,Z),x), eq(add(Z,Z),Z), eq(add(y,Z),y), eq(add(S(y),Z),S(y)))))" > a5b_mm_cost.out
