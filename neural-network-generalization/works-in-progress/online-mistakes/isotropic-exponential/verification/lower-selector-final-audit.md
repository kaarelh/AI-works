# Independent full-source audit

Reviewed source: `/workspace/isotropic-online-2026-11-05/selector-paper.tex`
Reviewer role: isotropic_lower; 5 November 2026.

**Mathematical verdict: PASS.** No unresolved proof gap was found in the
short-calibration construction, scalar Gaussian transfer, finite-scale
probability statement, or teacher-resource claims.

Checked directly from the final six-page source:

1. The diagonal list supplies `u>=1` and both absolute-value inequalities,
   hence `|s_i|<=u-1` with only O(k) examples. The two carry examples average
   to the recurrence without assuming that a candidate function is symmetric.
2. The query bound `v<=-(2t+1)+(k-t)U` uses only necessary training inequalities.
   It is valid for `t>=k`. Every norm term is then minimized separately at
   the displayed candidate, giving uniqueness. Its odd integer scores verify
   the mandatory full-cube absolute margin, including all unqueried points.
3. The proposed permutation contains distinct calibration and subsequent
   query points after duplicate removal. The specified forced count is
   exactly `2^k-k-1`; the stated `>=2^(k-1)` holds for every k>=3, including
   equality at k=3. The prelude uses at most `4k+3` inputs.
4. At every scalar depth, odd monotone compositions preserve the threshold
   class. The constrained scalar energy minimum is attained by coercivity;
   all factors at a feasible minimizer are positive. Strict increase in Q
   follows by evaluating at the larger-Q minimizer. Strict and weak margin
   energy infima coincide by readout scaling. Standard finite-dimensional
   Gaussian large deviations therefore give the stated exact exponential
   rates, and the finite function class supplies a positive energy gap after
   each relevant history. No equal-energy uniformity claim is needed.
5. The finite list of histories admits one sufficiently small positive scale.
   Error probabilities tending to one imply simultaneous sampled mistakes
   by a union bound; no independence claim is needed. The same scale makes
   posterior majority and the strict-confidence criterion fail on every
   designated round.
6. The teacher construction has exactly `1+2k` hidden layers and one readout,
   hence depth `2k+2`. Concavity of tanh gives the stated amplification and
   strict final margin. The exact affine squared norm and the neural energy
   bound `(40k+11)/3` check algebraically.
7. The C_L=1 exclusion is valid: the first affine margin exceeds 1/2 under
   unit-bounded downstream weights; normalization and the carry recurrence
   force an original pair difference w above 1. Zero-padding the explicit
   scalar teacher gives C_L<=2, so C_L=2. The learner N=1<C_L caveat is
   stated prominently and correctly. No claim for N>=C_L follows.
8. The O(k)-gate Boolean comparison recurrence is correct when processed
   from least significant to most significant bit. The arrangement count
   and iid finite-class union bound apply to all consistent posteriors,
   independently of prior probabilities or depth.

Two optional presentation edits:
- Replace the abstract's “with that probability's complement” by “with
  arbitrarily high probability” (the theorem gives the precise quantifiers).
- In the iid section, say “All represented Boolean functions, including
  constants, are affine threshold functions.” The current restriction to
  nonconstant functions is unnecessary; the displayed arrangement bound
  already includes constants.

The earlier scratch audit of the full-slice calibration is superseded by
this audit of the shorter O(k)-example calibration in the actual source.
