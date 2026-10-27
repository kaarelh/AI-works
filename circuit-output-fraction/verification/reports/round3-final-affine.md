# Final referee report: affine

**Verdict.** Sound with minor fixes. The mathematics holds, and all 25 earlier findings are resolved. One new code soundness hole needs a one-line fix. I labelled it critical because it violates soundness, but it only arises from malformed input: a CONST gate whose parameter is not 0 or 1, built with Circuit.add. The remaining findings are minor wording and precision issues.

**What was checked.** FILES READ IN FULL: p1-affine.tex, app-affine.tex, p2-xpt.tex and code/rareprob/affine.py. Also read the dependencies: sec-setting, sec-envelopes (lem:envmass, thm:envelope), p1-dfsb (rules T, T', F, D, S, E, B; the ideal tree; thm:dfsb), p1-ctx (the NNF size and thm:cw), p2-pcis (def:pcis, thm:sis, thm:certenv), circuit.py, dist.py, stats.py, the affine part of meta.py, exp_affine.py (ground truths) and test_affine.py. Also checked the summaries of this topic in sec-intro, sec-discussion, p1-tail and the abstract.

LENS A (proofs re-derived):
- Certificates: the ANF and solved-form arguments (Boolean-ring homomorphism). Gadget thresholds checked by code: chains need exactly T=k-1, and a balanced root split needs exactly floor(k/2)ceil(k/2) (k=5, 8, 12, 16).
- Presolve: the spine identity; prop:presolve (p = M E[W], W in [0,1], the rho bound); the code's pivot order (affine pivots, then solved pivots that avoid aff_sup and solved_sup) and the construction of R~.
- Affine envelopes: thm:affenv (a)-(c), with the meet, join, XOR and cap rules matched against the code.
- prop:xordnnf: independence along derivations, the mass and the sampler.
- Barrier: the smoothing count (n+2)(S+2); the walk and decomposition; the coset lemma (block count 2^lambda, Cauchy-Schwarz); parity-barrier (a) and (b), including the E => V case; the 2^lambda_bal/(n+2)-2 wire bound.
- Corollaries: cor:parity-ghw; cor:random-parity (the union bound 2^{n+7m-7n/3} <= 2^{-n/6} and the rank bound); cor:barrier-methods (i)-(iv) with the constants 12288, 3(n+2), (n+6)^2 and m-14. Also the KL sample lower bound and the (iv) argument that a dense leaf with more than 2n/3 variables lies in a coset of ker H_Y with mass <= 2^{6-m}.
- prop:bw-dp: the live set, the coset dimension, 2n(4^w+1) gates, lambda_bal <= w, and that bw equals matroid branch-width minus one.
- thm:biased-hard: the p formula, the threshold k, the gap 2^{-2g-3}, the choice a = ceil(2/gamma), the BPP and MA thresholds (theta/16 against theta/2, delta <= 1/6), and the complement case q > 1/2.
- Thresholds: prop:ltf (the rounding induction G <= F <= Q^i G, value and breakpoint counts, the telescoping rejection sampler); unions with approximate masses; prop:affine-ltf (the recurrence closes on live states).
- prop:nonclosure (a)-(d) and prop:fourier (a)-(c), including the new general-f induction.
- Citations: the GKMSVV FOCS'11 text, downloaded. Its Sec. 3.2 says knapsack solutions can be counted approximately under all symmetric and product distributions. Thm 3.6 has construction time O(n^3 S(S+log W) log(n/delta)/delta), quadratic in S, and Claim 3.4 is as cited. The bibliography keys exist. Not re-fetched this round (from memory only, consistent with the text and with earlier referees): BMvT (coset weights), Vardy, Goldberg-Jerrum (binary matroids #RHPi1-hard; regular matroids FPRAS), Jerrum-Sinclair, Green-Sanders, Hlineny-Oum and BHZ.

LENS B (code against brute force; scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/final_affine/):
- Test suite: 32 of 32 tests pass.
- fuzz.py: 2400 random circuits (n <= 7; AND, OR, XOR, NOT, gadget XORs, THR with mixed-magnitude real weights, constants, repeated children). Product distributions included q in {0, 1, 1e-300, 5e-324, 2^-60, 1-2^-53} and random values. Every x with C(x)=1 was checked against the affine envelope (caps 1, 2, 16) and against xpt_check on 7200 random or malformed arguments; there were 0 domination failures. Presolve never declared infeasibility wrongly. Of 7200 estimates at delta=0.1 there were 6 statistical misses, consistent with delta.
- repro_old.py: every earlier referee counterexample now passes, with and without python -O.
- edge2.py: the dropped-negligible-piece path of the KLM estimator (pieces 2^1049 apart); DP masses under extreme marginals against exact Fractions, all within rel or TooWide; 1100 near-uniform biased pivots, which give a valid [0, 5e-324].
- klcheck.py: the shared KL-interval endpoints against 60-digit Decimal arithmetic.
- const_param*.py and const_meta.py: the CONST-parameter hole reported below.

EXPERIMENT-DEPENDENT CLAIMS (noted, not judged):
- p1-affine 151-152: E1 has six pieces and K=1.39.
- p1-affine 333-336: E6a, "4%", "0.2 seconds", "1.3e-22".
- p1-affine 445-462: E3's 52 s, 1.5e6 samples, ratio 29, 1.6e4 samples, 0.04 s, 3.7e7 evaluations, 0.15 s; E7's 600 estimates with no misses; "about 75 seconds"; "2e-14" agreement.
- tab:affine, all rows.
- p2-xpt 82-83: E5 with p=4.9e-9, "6-node argument", ratio 1.04, 6.6e4 samples. The "6 nodes" counts nodes the verifier visits. The honest argument as a tree also has one closed leaf, so 7 nodes; recheck the wording when the experiments are regenerated.

## Audit of earlier findings

resolved: 25

- [resolved] (critical) R1-1 XPT form split accepted any constant c ([0,0] for p=1/8): parse_split (affine.py:1254-1282) accepts a form only with c an int in {0,1} and integer indices in range; anything else becomes an open leaf. Affine.add raises on rhs not in {0,1} or row<0 (177-182). I reran the referee instance C = NOT x0 AND x1 AND x2 with c in {2, -1, 3, 1.0, '1', None, [1], True}, under the uniform distribution and Bern(0.3). Every interval contains p=1/8, also under python -O. Regression test test_xpt_form_constant_must_be_a_bit is present.
- [resolved] (major) R1-2 THR backward rule recomputed float sums (THR([1,1e-17]) AND x2): Propagator now uses thr_sum (1116-1122), which adds w_i*float(b_i) left to right exactly like Circuit.eval_packed and compares with t-1e-12. Each unknown occurrence is set to its extreme (1147-1157, 1226-1246); non-finite weights allow only forward evaluation with all children known. I checked the argument: with finite weights no partial sum can become NaN, and rounded addition is monotone, so the bounds are valid. I reran the referee instance with the trivial argument and with a full split tree; the interval contains p=3/8.
- [resolved] (major) R1-3 prover orders checked only by assert; crash or -O unsoundness: valid_order (725-737) checks explicitly. LinearOrderDP raises TooWide instead of asserting (758-765), and the caller relaxes the piece. xpt_check is iterative and treats non-dict nodes as open leaves (1300-1339); xpt_verify falls back to the whole cube on any exception (1349-1354). p2-xpt 39-42 and 84-87 now describe this behaviour. Rerun on orders [0,0,2,3], [0]*4, a length-5 list, 'abc', floats, bools and a reversed order, plus 6 malformed roots and a 5000-level argument, with and without -O: every interval is valid.
- [resolved] (major) R1-4 underflow: presolve [0,0] for 2^-1100; subnormal masses missed p (AND of 650-675 literals, Bern(1/3)): M is now a renormalised mantissa/exponent product with error gamma_{2k} (639-651). _scaled_interval and _ldexp_up/_ldexp_down round outward and never give 0 for a positive value (86-107). The DP renormalises by exact powers of two and raises TooWide below the normal range (828-844). Reruns: the AND of 1100 literals gives [0, 5e-324] with log2 bounds in the note; k = 650, 660 and 675 under Bern(1/3) contain the exact rational p for both the presolve and the envelope.
- [resolved] (major) R1-5 novelty claim for prop:affine-ltf contradicted by GKMSVV Thm 3.6: The proposition title now cites gopalan2011fptas, and lines 369-377 call it an instance of Thm 3.6 with Claim 3.4; the novelty sentence is gone. I checked the FOCS text: Sec. 3.2 covers symmetric and product distributions, Thm 3.6 has construction time O(n^3 S(S+log W) log(n/delta)/delta), quadratic in S as the paper says, and Claim 3.4 matches.
- [resolved] (minor) R1-6 (iv) hypothesis inconsistent with the ideal tree; (T') missing: Lines 253-260 now list (T),(T'),(F),(D),(B), require D(h) >= 1/K' only for leaves with more than 2n/3 variables, and apply to T*_{K'} when a <= 2n/3. The proof at app 164-181 is re-derived and correct. A residual nit about refuted leaves is filed as a new minor finding.
- [resolved] (minor) R1-7 opening and closing summaries overclaimed DFSB and dropped the c factors: Lines 5-11 now state m <= n/6, events filling a 1/poly(n) fraction, high probability over H, and 'the node budget behind DFSB's completeness guarantee'. Lines 259-260 exclude (E)-leaf runs. A residual missing qualifier ('decomposable envelopes' without the small-leaf condition) is filed as a new minor finding.
- [resolved] (minor) R1-8 'DNNFs need size 2^lambda_bal' dropped the smoothing loss and the leaf-support condition: Lines 171-173 now say DNNFs with leaves on at most 2n/3 variables need at least 2^{lambda_bal}/(n+2)-2 wires. Re-derived from (n+2)(S+2) >= |G| >= 2^{lambda_bal}.
- [resolved] (minor) R1-9 prop:ltf 'poly(n,b,log 1/eps)-bit numbers' unsupported: Line 346 now says 'rationals of poly(n,b,1/eps) bits', and app 249-253 justifies the sizes of Q^j, H_i, the exponents and the acceptance probability.
- [resolved] (minor) R1-10 E3 presented as showing the barrier (m=12 > n/6): Lines 454-460 now say E3 illustrates DFSB on a dense parity event and is not an instance of the barrier, because m=12 > n/6.
- [resolved] (minor) R1-11 'exact values independent of the code' false for E5 and E6: Lines 447-453 describe each ground truth. exp_affine.py uses the local gf2_solve and rank_gf2, window_sweep (exact rational sweep, E6a) and coset_probability (E6b). LinearOrderDP appears only as a logged cross-check (exp_affine.py around lines 445-453 and 491-493).
- [resolved] (minor) R1-12 ANF cap T could be given in binary; log log K term dropped: p2-xpt 13-14 make T a verifier parameter given in unary, and line 53 restores the (log(1/delta) + log log K) term.
- [resolved] (minor) R1-13 thm:affenv(b) read as if a narrow order is found: Lines 124-127 now say 'along a given linear order'. The implementation uses the input order there and prover orders in sec:xpt, and relaxes above the cap; this matches make_pieces and affine_envelope_estimate.
- [resolved] (major) R2-1 floating-point THR propagation and Python's compensated sum (THR([1e17,3,3,-1],5), THR([1e6+0.1,0.3,0.3],0.6), NOT THR([1e16,1,-1e16],0.5)): thr_sum is a plain left-to-right loop with no sum or fsum, identical to eval_packed. All three instances pass with the trivial argument and with full form-split trees (repro_old.py). My fuzz with mixed-magnitude real weights found 0 domination failures in 7200 arguments.
- [resolved] (major) R2-2 malformed orders, non-dict roots and deep arguments crashed or were unsound under -O: Same code changes as R1-3; verified under -O. The text at p2-xpt 84-87 now says a bad order 'costs tightness or time, never soundness'.
- [resolved] (major) R2-3 presolve factor M underflowed to [0,0]: Same as R1-4. The inner-estimator path also goes through _scaled_interval (689-694). The AND of 1100 literals gives [0, 5e-324], and 1100 biased pivots with q = 1/2 + 2^-40 also give a valid interval (edge2.py).
- [resolved] (minor) R2-4 widening constants rel and eta not proved and exceeded: Current bounds: presolve tau = gamma_{3k+2} + (n+2)u (701), M_rel = gamma_{2k} (650), DP rel = gamma_{5n+5} (849), KLM eta = 2(rel+2u) and tau = (2T+16n+32)2^-52 (967-970). I re-derived the DP bound: (1+u)^4 per level, including a subnormal product, since every stored value is >= 2^-1022. I also re-derived the telescoping of sampler path probabilities over stored values, which gives a TV error linear in n. The AND of 1000 negated literals under Bern(0.3) contains the exact p. On 200 random subspaces with random orders and marginals in {5e-324, 1-2^-53, 1e-300, 2^-1022, 0.3, 0.5, ...}, the DP mass was always within rel of the exact Fraction value, or TooWide was raised.
- [resolved] (minor) R2-5 gadget certification 'T=O(k)' holds only for chains: Lines 25-29 now give T = k-1 for chains with O(k^2) work, and floor(k/2)ceil(k/2) for a balanced tree. My script confirms that both values are exact thresholds (T-1 fails) for k=8 and 16.
- [resolved] (minor) R2-6 'smallest smooth DNNF' sandwich false as written; bw off by one: Lines 289-295 now define bw(V), note that it equals matroid branch-width minus one for n >= 2 (checked: lambda_M = lambda_V + 1 on rooted binary trees versus subcubic trees), and require fan-in-two AND gates with leaves on at most 2n/3 variables. A residual 'tight' wording nit is filed as a new minor finding.
- [resolved] (minor) R2-7 summaries ignored the c-dependence, the m <= n/6 condition and the high-probability event: Lines 5-11 and 264-267 carry the conditions. The example c = 2^{-m/2} gives c^2/p = p^{-1/3}, which I verified.
- [resolved] (minor) R2-8 E3 vs cor:random-parity; DFSB slower than Monte Carlo: Same as R1-10; the text also says plain Monte Carlo is cheap at this size.
- [resolved] (minor) R2-9 E5/E6 ground truths came from the module: Same as R1-11.
- [resolved] (minor) R2-10 prop:ltf bit length: Same as R1-9.
- [resolved] (minor) R2-11 (iii) should use |N| and exclude frontier gates; (iv) missing (T') and (S): Lines 246-252 now require no frontier gates (|N| <= 12|C| for AND/OR/NOT/XOR circuits, consistent with sec:ctxwidth), use thm:cw's bound (|N|+1)(cw+3)2^cw, and give cw >= m - 14 - log2((n+2)(|N|+1)(cw+3)/c). I re-derived this using log2 3 < 2. Part (iv) lists (T') and treats (S) leaves under the density hypothesis.
- [resolved] (minor) R2-12 prop:fourier(b) applied the Boolean claim to a non-Boolean G: Lines 421-426 now prove Pr[f != 0] >= 2^{-deg f} for every nonzero multilinear f over F_2 or R, by induction on the number of variables, and apply it with f = C. Checked.

## New findings

### 1. [critical] code/rareprob/affine.py:540-544 (presolve, CONST on the spine) and 1193-1194 (Propagator CONST rule); root cause code/rareprob/circuit.py:44-60 (Circuit.add does not normalise CONST parameters)

**Problem.** Circuit.eval_packed treats a CONST parameter as true whenever it is nonzero, but presolve and the XPT propagator use int(param). A CONST built with C.add('CONST', (), 2) (or 0.5, or -1) evaluates to 1, while the affine code reads it as 2 or 0. Reproduced: for C = AND(add('CONST',(),2), THR([x0,x1,x2],[1,1,1],2)), p = 1/2 under the uniform distribution, yet presolve_estimate returns [0,0] with the note 'inconsistent affine spine'. For C = AND(add('CONST',(),2), x0), xpt_verify with the trivial argument {leaf: open} returns [0,0]; the propagator first sets the constant to 1, then the CONST rule sets it to 2, and the contradiction closes the root. meta_estimate also returns [0,0] on the first circuit; variable elimination misreads the constant there too. These are deterministic soundness violations on a Circuit object the API accepts. Circuit.const() normalises the parameter, and the documented model has b in {0,1}, so only raw add() calls are affected.

**Proposed fix.** In Circuit.add, for op == 'CONST', set param = int(bool(param)), or raise unless param is in {0, 1, True, False}. Defensively use int(bool(C.params[g])) at affine.py:541 and :1194 (cnf.py:158 has the same pattern). Add a regression test with CONST parameters 2, 0.5 and -1.

### 2. [minor] paper/p1-affine.tex:464-470 ('The implementation is sound in floating point as well'); shared code code/rareprob/stats.py kl_interval

**Problem.** The sentence claims floating-point soundness, but the Hoeffding-KL interval that every estimator here relies on is computed by floating-point bisection. Against 60-digit Decimal arithmetic, 2257 of 7526 returned endpoints lie strictly inside the exact KL interval, with relative KL deficit up to 2.5e-9. The empirical mean is also a float sum. Coverage is therefore at most delta(1 + O(1e-8)) rather than at most delta. The excess is negligible, but the stated proofs do not cover it. Separately, '(X1) ... is exact for the function the circuit computes' overstates the rule: with repeated children it is a relaxation. It is a valid (sound) inference, not an exact one.

**Proposed fix.** In kl_interval, bisect against c' = c(1+1e-6) (or compute KL with log1p and xlogy and step each endpoint one ulp outward), and mention this in the paragraph; alternatively, qualify the sentence. Replace 'is exact for' with 'is a valid inference about'.

### 3. [minor] paper/p1-affine.tex:7-8 (opening: 'the envelope estimator with decomposable envelopes') and 236-238 (cor:barrier-methods (i) parenthetical)

**Problem.** The barrier needs every envelope leaf to have support of at most 2n/3. The opening paragraph says only 'decomposable envelopes'. A decomposable envelope with one large leaf, such as an affine atom 1_V (K = 1/c), escapes the bound. The parenthetical in (i), '(literal, constant and small box leaves, as produced by (R1)-(R8) ...)', suggests that every envelope (R1)-(R8) produces qualifies, but (R7) boxes can have any support. The intro and abstract already say 'with small leaves'.

**Proposed fix.** Opening: 'the envelope estimator with decomposable envelopes whose leaves have at most 2n/3 variables'. In (i): '(literal and constant leaves, (R8) atoms with a <= 2n/3, and (R7) boxes on at most 2n/3 variables)'.

### 4. [minor] paper/p2-xpt.tex:27-28 (rule (X3))

**Problem.** 'If g is certified affine and a_g.x is constant on V(S), set sigma(g) to that constant.' Since g = a_g.x + c_g, the value must be that constant plus c_g. The code does this correctly: form_value(f[0], f[1]) includes c.

**Proposed fix.** Write: 'set sigma(g) to that constant plus c_g'.

### 5. [minor] paper/p1-affine.tex:88-90 (CRC and Feistel examples) and 298 ('Linear bijections preserve only the uniform measure')

**Problem.** Two statements are true only under the uniform distribution or with uniform pivot coordinates, but are stated without that hypothesis. First, p = 2^{-r} D(R~) for [CRC(x)=0] AND R, and 'a Feistel round [L xor f(R) = t] has probability 2^{-|L|} for every round function f'. The Feistel claim is false when the L-coordinates are biased. Second, coordinate permutations are linear bijections that preserve every i.i.d. product measure, so 'linear bijections preserve only the uniform measure' is false as stated.

**Proposed fix.** Add 'under the uniform distribution (more generally, when the pivots, e.g. the L-coordinates, are uniform)' to the examples. Change the second sentence to 'Linear bijections other than coordinate permutations preserve, among product measures, essentially only the uniform one'.

### 6. [minor] paper/p1-affine.tex:270-271 ('The bound is tight in the following sense') and 292-295 (the sandwich)

**Problem.** The two ends of the sandwich, 2^{lambda_bal(V)} and 2n(4^{bw(V)}+1), can be exponentially far apart. Take V = V1 x V2 on the two halves of [n]: the halves cut gives lambda_bal(V) = 0, while bw(V) = max(bw(V1), bw(V2)) can be Theta(n) for random V_i. 'Tight' is therefore justified only when lambda_bal and bw are comparable.

**Proposed fix.** Replace 'The bound is tight in the following sense' with 'Conversely, bounded connectivity along a whole tree suffices', and add 'the two ends match up to poly(n) when bw(V) = lambda_bal(V) + O(1)' after the sandwich.

### 7. [minor] paper/app-affine.tex:164-168 (proof of cor:barrier-methods (iv)); p1-affine.tex:253-257

**Problem.** The proof converts every non-(T) leaf, including 'a refuted node, which is the constant 0', into 'a leaf with the function of the restricted node h on its support'. A refuted node can have more than 2n/3 declared variables and D(h) = 0. That formally violates the hypothesis of (iv), which asks for D(h) >= 1/K' on every leaf with more than 2n/3 variables, although the main text treats refuted nodes as constants. The argument itself is unaffected, because it uses density only for leaves whose term is nonempty.

**Proposed fix.** In the appendix, make refuted nodes the constant-0 leaf with empty support. Alternatively, state the hypothesis of (iv) only for leaves h with more than 2n/3 variables and D(h) > 0, which is all the proof uses.

### 8. [minor] paper/p1-affine.tex:343-366 (prop:ltf, prop:affine-ltf); app-affine.tex:279-287

**Problem.** There are notation clashes. In prop:affine-ltf, b is both the right-hand side of Ax = b and the bit length of the marginals ('O(n^3 2^{w_0} b/eps) ... with b-bit marginals'), and the appendix then says complementing 'changes b by the columns ...'. Similarly, w is the weight vector of the threshold and, in prop:bw-dp, the width.

**Proposed fix.** Rename the bit length (for example to beta or ell) in prop:ltf, prop:affine-ltf and their proofs, or rename the right-hand side to s, as in sec:affine elsewhere.

