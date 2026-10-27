# New results: local-thresholds

## Integration report

I added local threshold circuits (LTCs) to Part 1, a Gibbs-envelope rule to Part 2, the code, tests and experiments. Every result in the source draft was re-derived; the changes are below.

What changed relative to the source:
- **Normaliser rebuilt.** The source's annealing estimator (Chebyshev plus median, about θ0²m² samples) was replaced by thermodynamic integration with a monotone bracket: ln Z(θ) is the integral of s(θ) = E_θ S, and s is nondecreasing. One sample is drawn per grid point. A Bernstein interval uses a variance bound computed from the data (Maurer's lower-tail inequality on pairs of neighbouring grid points), so soundness needs no variance bound at all. Optional clipping windows are paid for by a KL bound on the exceedances, and S is Rao–Blackwellised over colour classes (3–4.4× lower variance).
- **Sampler.** Systematic chromatic heat-bath scan. Its certificate is a weighted Dobrushin row-sum bound with explicit verification, using an influence bound κ that is monotone in θ, so one check at θ* covers every θ ≤ θ*. The crude bound θ0 = 2(1−γ)/(d(k−1)) was verified for arbitrary g_j (tested).
- **Completeness.** Re-proved for the new procedure, with a pilot grid of spacing O(√n). The source's lemmas were checked line by line and kept: the Poisson-binomial local bound, anticoncentration via private pivots (constants c1 and m0), and rarity.
- **Prop C (CFTP).** Re-proved. Soundness for every θ ≥ 0 now comes from a stated coupling with the uncapped sampler under an abort-on-any-timeout rule, and the normaliser needs no variance bound.
- **Prop E corrected.** (a) is restated for sound interval procedures: E N ≥ (1−3δ)K/(3ε). (b) uses integer weights. The source claimed that a gap certificate C ⇒ S ≥ 1 gives a certified ratio ≤ 2.07; that is false (numerically about 2^{n/4+0.8}). The correct fix is the deduction C ⇒ g, which gives K = 1. I verified (b) numerically: relative second moment 2.06, min over θ of log2 K = n/2 + 1.02.
- **Thm B2.** Reduced to a PCIS statistical node (`prop:gibbs`) plus remarks: block certificates (not implemented) and an annealed-importance-sampling lower bound that needs no certificate.
- **Prop D.** Reduced to a remark with only the new points.
- **Prop F.** Not used.

Paper builds cleanly in a scratch copy: no overfull boxes and no undefined references from my files. The undefined citations that do appear come from other agents' concurrent edits. I fetched none of the papers' full texts: bibliographic data (journal, volume, pages) for 11 of the 13 new refs.bib entries was confirmed by web search, Dobrushin 1970 is from memory, and the FOCS 1997 pages are omitted because I could not confirm them. Lemma statements were checked only from secondary descriptions (for Maurer 2003 I give the short proof myself). Further limits: the completeness constant e^{c1} is astronomically pessimistic; the block-certificate remark is a sketch and is not implemented; meta.py integration is offered only as an external edit.

- Thm local(i): TG is sound on every LTC C=[S>=t] AND H (any k, d, g_j, t, any H, any product D with q in (0,1)), for every choice of tilt, grid, window and budgets (proved here): New normaliser (TI + monotone bracket + Maurer/Bernstein), systematic-scan sampler with verified weighted Dobrushin certificate, delta split in five, floating-point term included in eta. Replaces the source's annealing/DKLR version; proof in p1-local.tex.
- Lemma local-mix (certified sampler): (a) monotone hull bound kappa >= sup influence, crude bound theta n_il/2, theta0=2(1-gamma)/(d(k-1)) for arbitrary g_j; (b) weighted row-sum certificate => TV <= (sum w/min w) alpha^tau for systematic scan from any start; (c) column sums => Var <= sum osc_i^2/(4 gamma) (proved here (c uses known: path coupling [Bubley-Dyer], contraction=>gap [LPW Sec 13.1])): Source Lemma A1/A2 checked; influence bound verified; random-scan used only for the Poincare inequality (completeness).
- Lemma local-ti / local-ti-window (normaliser interval) and Maurer's inequality (proved here (Maurer 2003 and Bernstein known, cited; Maurer re-proved in 3 lines)): New; no a priori variance bound needed; windows reduce the range term; tested for coverage with exact samples.
- Thm local(ii): completeness under (H1) marginals in [beta,1-beta], (H2) nu-private pivots, (H3) t <= s(theta0), m >= m0: ratio <= 1+eps w.p. 1-3delta with O((n + e^{c1} sqrt n) eps^-2 log(n/delta)) samples + O(d^3 sqrt n log(n/delta)/(gamma^2(k-1))) pilot samples, O(gamma^-1 log(n/(eps delta))) sweeps each (proved here): Source's anticoncentration Lemma A3/A4 verified with its constants; pilot redesigned (grid spacing from V_max, no k^2 d^5 condition); e^{c1} is very pessimistic (experiments: v(theta) sqrt m ~ 2.2).
- Thm local(iii): rarity p <= exp(theta0 - theta0^2 beta nu^2 m/(4e^4)) at t=floor(s(theta0)) (proved here): Unchanged from source, verified.
- Cor local-side (source Thm B1): C=[S>=t] AND H with arbitrary H; sound; complete with cost x 1/pi_H when P_theta(H|S=t)>=pi_H (proved here): Tested by brute force with a nontrivial H.
- Prop local-cftp (source Prop C): monotone CFTP for supermodular S, abort on any timeout; sound for every theta>=0 without certificate (proved here): Soundness argument made explicit (coupling with uncapped CFTP); related to thm:cftp/prop:truncation in the text; experiment at Dobrushin row sums 1.5 and 2.5.
- Remark local-blocks (source Prop D): K <= e^{theta(s'-t)}/P_theta(S=s'); O(sqrt k) tight by Bahadur-Rao; K->1 at t=k_+; log-concave blocks (weakened (remark; Bahadur-Rao known, cited)): Does not duplicate prop:tilting; only the new points.
- Prop certgap (source Prop E): (a) any sound black-box interval procedure tight on P0 needs E N >= (1-3delta)B/(3 eps p); (b) integer-weight instance with K >= 2^{n/2} for all theta but relative 2nd moment <= 2.07 (proved here (corrected)): Source's claim that the gap certificate t'=1 gives ratio <= 2.07 is false (~2^{n/4+0.8}, checked numerically); fix is the deduction C => g (K=1).
- Prop gibbs (source Thm B2): Gibbs-envelope node for PCIS (statistic, t', theta, weights, P-proof of C => S>=t'); sound against every argument, lower bound on proof failure; complete with L=O(theta^2 m^2 log/eps^2) (proved here (block certificates: sketch, not implemented)): In p2-gibbs.tex with remarks on block certificates and AIS lower bounds without certificate (Neal 2001, cited).
- Source Prop F (sequential IS with super-consistent lookahead), Prop G, known-results list (dropped): Outside this topic; overlaps thm:sis/thm:envelope.

## Referee report

**Verdict.** The core mathematics holds up under a line-by-line check, but the code has one soundness bug. I re-derived every step of: soundness (i); Lemma local-mix (a)–(c); Lemma local-ti and Lemma local-ti-window (the Maurer and Bernstein steps, and the clipping term); the Maurer proof; the Poisson-binomial local bound; the anticoncentration lemma and the constants c1 and m0; the pilot and normaliser completeness; rarity (iii); certgap (a)/(b); and the annealed-importance-sampling unbiasedness in p2-gibbs. Each step is correct, apart from minor constant slips. The code bug is in syntactic recognition: `ltc_from_circuit` rounds the threshold with a different tolerance than the circuit evaluator. On a valid circuit it then estimates the wrong function, and the interval misses p with probability about 1. The other findings are minor: one example in a corollary contradicts its own hypotheses, a few hypotheses are missing from theorem statements, and several numbers or parameter descriptions in the experiments text differ from what the code and logs show.

### 1. [major] code/rareprob/localthr.py:213 (ltc_from_circuit)

**Problem.** The recognised threshold is t = ceil(thr - 1e-9), but Circuit evaluates a THR gate as sum >= thr - 1e-12 (circuit.py, eval_packed). For any threshold in (k + 1e-12, k + 1e-9], the circuit computes [S >= k+1] while the recognised LTC computes [S >= k]. TG then returns a confident interval for the wrong function. Reproduced: a THR gate over 6 inputs with threshold 3 + 5e-10, q = 1/2. True p = 0.34375, recognised p = 0.65625, TG interval [0.620, 0.679] misses p deterministically. This breaks the claim 'sound on every input' for the recognition path (def:ltc says LTCs are recognised syntactically).

**Proposed fix.** Compute t exactly as the evaluator does: t = ceil(thr - 1e-12), with the same constant shared from circuit.py. Better, define t as the smallest integer s with s >= thr - TOL, using one TOL for both. Then assert on random points that ltc.C agrees with C.eval_bits. Add a regression test with a threshold of 3 + 5e-10.

### 2. [minor] paper/p1-local.tex:206-212 (cor:local-side) vs line 151 (H1)

**Problem.** The corollary assumes (H1), whose second clause says every variable lies in some scope. Its example, pi_H = D(H) 'when H reads only variables outside all scopes', is therefore vacuous under its own hypotheses (H could only be constant). The proof of thm:local(ii) also uses n <= km, which fails once such variables exist.

**Proposed fix.** Restrict (H1) to the variables in scopes and let n_S be their number. Replace n by n_S in lem:local-anti, the pilot and thm:local(ii). Variables outside all scopes have Delta_i = 0, are resampled exactly from q_i, and do not affect S. Alternatively, drop the example.

### 3. [minor] paper/p1-local.tex:121-124

**Problem.** 'cut the variance by factors 2.8–4.4 in our instances': no recorded output supports this, and my re-measurement disagrees at the low end. At the experiment tilts the ratio Var(S)/Var(S_RB) is 4.36 (chain, theta = 0.49), 2.75 (cubic N = 1500, theta = 0.447) and 2.66 (cubic N = 100, theta = 0.457). On the CFTP monomial chain, which also runs with rb = True, it is only about 1.5 at theta = 1.5 and 2.5.

**Proposed fix.** Report the measured range, e.g. 'factors 2.7–4.4 on the Glauber instances and about 1.5 on the CFTP chain'. Log these numbers in exp_local.py and local.json.

### 4. [minor] paper/p1-local.tex:253-255 and 307-308

**Problem.** 'where the Dobrushin row sums are 1.5 and 2.5': these are row sums of the hull bound kappa, not of the Dobrushin influences c_il. For the monomial chain at q = 1/2 the exact max row sums of c_il are 1.27 (theta = 1.5) and 1.70 (theta = 2.5), checked with influence_exact. The 'unweighted row sums' 0.98 and 1.34 are also kappa-based. The qualitative point (outside the Dobrushin regime) still holds.

**Proposed fix.** Write 'the row sums of the influence bound kappa are 1.5 and 2.5 (exact Dobrushin row sums 1.27 and 1.70)', and say 'kappa row sums' for 0.98 and 1.34.

### 5. [minor] paper/p1-local.tex:298-320 and table caption line 334; experiments/exp_local.py:126

**Problem.** Several experiment details differ from the code and logs:
- Text and caption state eps = 0.3 for all runs, but the N = 100 run used eps = 0.2.
- '23–29 ns per site update' holds only for the two large Glauber runs. The data give 15 ns for N = 100 and 35–60 ns for the CFTP runs.
- The caption says every sample, pilot included, is a chain run for 'sweeps' sweeps. Pilot chains use certificate.sweeps(1e-3), about 51 instead of 80 for the chain instance.
- The text gives the CFTP ratio as '2.8'; the table and log give 2.85.

**Proposed fix.** Either rerun N = 100 with eps = 0.3 or state eps = 0.2 for that row. Restrict the ns-per-update claim to instances (1) and (2), or give the full range. Say that pilot chains run fewer sweeps. Write 2.85 (or 2.9).

### 6. [minor] paper/p1-local.tex:165-173 (thm:local(ii) statement)

**Problem.** Three hypotheses the proof uses are missing from the statement:
- The final ratio step (app-local.tex:204-205) requires eps <= 1.
- The sample cap N_IS must be at least the importance-sampling sample count.
- L is written with ln(1/delta), which tends to 0 as delta -> 1, whereas the proof needs ln(5/delta), since the Maurer and Bernstein levels are delta/5.

**Proposed fix.** Add 'for 0 < eps <= 1' and 'N_IS >= C K(log(1/delta) + log log K)/eps^2' to the statement, and write L = Theta((...) ln(5/delta)).

### 7. [minor] paper/app-local.tex:194-195

**Problem.** Constant slip. The Bernstein step runs at level delta_1 = delta/5, so ell = ln(2/delta_1) = ln(10/delta). The displayed bound u <= 2 theta sqrt(8 V_max ell'/L) + 6 theta R ell'/L instead uses ell' = ln(5/delta), so the first term is too small by a factor sqrt(ell/ell'). This has no effect on the Theta(.) choice of L.

**Proposed fix.** Write u <= 2 theta sqrt(8 V_max ell/L) + 6 theta R ell/L with ell = ln(10/delta), since ell >= ell'. Alternatively, state both ell and ell' and bound them by ln(10/delta).

### 8. [minor] paper/p2-gibbs.tex:22-27 (prop:gibbs completeness)

**Problem.** Three issues in the completeness clause:
- '(and L as in thm:local(ii) when the column sums of kappa(theta) are also at most 1-gamma)' is not right as stated: the L of thm:local(ii) uses theta <= theta_0 (so theta^2 V_max <= n/(gamma(k-1)^2) and theta R <= theta_0 m), but a supplied tilt can exceed theta_0.
- The importance-sampling count O(log(1/delta_v)/(eps^2 v_C)) omits the log log K term of thm:envelope(iv).
- 'L = O(theta^2 m^2 log/eps^2) always suffices' fails when theta m < eps, where the linear term theta R ell/L dominates.

**Proposed fix.** Use L = O((theta^2 n d^2/(gamma eps^2) + theta m/eps + 1) log(1/delta_v)) under column sums <= 1-gamma, and L = O((theta^2 m^2/eps^2 + 1) log(1/delta_v)) in general. Write the importance-sampling count as O((log(1/delta_v) + log log(1/v_C))/(eps^2 v_C)).

### 9. [minor] paper/app-local.tex:169-173 vs p1-local.tex:136 and localthr.py:736 (_pilot)

**Problem.** (T1) defines N_tot = L + N_IS, and the code excludes pilot samples from N_tot. The appendix instead says the pilot samples are included in N_tot. The implemented pilot (10 points x 256 chains, linear interpolation, chains at TV 1e-3) is not the analysed pilot either (median of means on a grid of spacing O(sqrt n)). Soundness is unaffected, but thm:local(ii) is not a statement about the procedure that was run.

**Proposed fix.** Define N_tot in (T1) as including pilot samples when the pilot's exactness is needed (completeness only). State in the experiments paragraph that the implementation uses a heuristic pilot, which affects only width, not soundness. Alternatively, implement the analysed pilot as an option.

### 10. [minor] paper/p1-local.tex:87-89

**Problem.** 'Part (b) is Dobrushin's uniqueness condition ... proved by path coupling [bubleydyer1997]': the appendix proof of (b) is a direct identical-uniform coupling with a weighted max-ratio induction, not path coupling. Path coupling is used only in (c).

**Proposed fix.** Write 'part (b) ... in the weighted (matrix-norm) form of [dgj2009], proved here by a direct coupling; part (c) uses path coupling [bubleydyer1997] and contraction of the random-scan chain [LPW, Sec. 13.1]'.

### 11. [minor] paper/p1-local.tex:262-264 (rem:local-blocks (b))

**Problem.** 'for k i.i.d. blocks and t = ak with a above the mean, K = Theta(sqrt k)' omits the upper bound on a. At a = max (t = k_+), K -> 1 as theta -> infinity, as part (c) itself states, so Theta(sqrt k) fails there. Bahadur–Rao needs a strictly inside the support's convex hull.

**Proposed fix.** State the hypothesis as E g < a < max g, with t = ak an integer, and with the lattice form of Bahadur–Rao for integer-valued blocks.

### 12. [minor] paper/p1-local.tex:197-199

**Problem.** 'By (iii), p = e^{-Omega(m)} at the reachable thresholds' overstates (iii), which bounds p only for t = floor(s(theta_0)). Thresholds near s(0) also satisfy (H3) but have p = Omega(1/sqrt n), so the claimed separation from Monte Carlo is only shown for the top reachable thresholds.

**Proposed fix.** Write 'at the largest certified-reachable thresholds t ~ s(theta_0) (and any t >= s(0) + c m)', or state the bound from (iii) for every t in [s(0), s(theta_0)].


## Referee report

**Verdict.** The core results hold up. I re-derived Thm local(i), Lemmas local-mix (a)-(c), local-ti and local-ti-window, Maurer's inequality, Lemmas pb-local and local-anti, Thm local(ii) and (iii), Prop local-cftp, Prop certgap (a) and (b), Prop gibbs and the AIS remark, and found no gaps. The numerical checks agree:
- the Dobrushin TV bound against the exact law of the scan;
- the variance bound (c) against brute force;
- CFTP exactness at theta up to 8;
- the certgap(b) constants.

On LTC objects the estimator never failed: 1446 adversarial brute-force runs at delta=0.5 gave 1 miss. There are two substantive problems:
1. **Unsound circuit recognition (code).** `ltc_from_circuit` rounds the THR threshold with a different tolerance from the circuit evaluator. On a crafted circuit TG is then confidently wrong: 20 of 20 intervals missed p.
2. **False completeness claim (paper).** Cor local-side claims completeness with cost x 1/pi_H, which is false in the theta=0 branch: an H that forces S down to t far below s(0) makes p exponentially small while Pr[H|S=t]=1.

The rest are minor: inconsistencies between the text and the experiment numbers, between the implemented and the analysed pilot, one citation of a proof technique, and missing factors in Prop gibbs.

### 1. [major] code/rareprob/localthr.py:213 (ltc_from_circuit), also :83 (LTC.__post_init__)

**Problem.** `ltc_from_circuit` can recognise a circuit with the wrong threshold, so TG becomes unsound on some circuits. Recognition sets t = ceil(T − 1e-9), but `Circuit.eval_packed` evaluates a THR gate as `s >= T − 1e-12`. For a threshold T in (k + 1e-12, k + 1e-9], the circuit computes [S ≥ k+1] while the recognised LTC computes [S ≥ k]. Counterexample (recog.py): 7 AND-pair detectors on 8 uniform bits with THR threshold 3 + 5e-10. The recognised t is 3; the LTC disagrees with the circuit on 39 of 256 inputs (true p = 0.121, recognised p = 0.273). All 20 TG runs at delta = 0.05 returned intervals that missed the true p. This breaks the claim that TG is sound on every circuit of this syntactic form. Relatedly, `LTC.__post_init__` silently truncates a non-integer t with `int()` (t = 2.5 becomes 2, i.e. [S ≥ 2] instead of [S ≥ 3]).

**Proposed fix.** Compute the integer threshold with the evaluator's own expression: `thr_val = T - 1e-12; t = math.ceil(thr_val)`. For integer S, float(s) >= thr_val holds exactly when s ≥ ceil(thr_val). Better still, check it: evaluate the THR gate at sums t−1 and t and assert that it switches between them. In `LTC.__post_init__`, reject non-integer t (or use `math.ceil`) instead of truncating. Add a regression test with thresholds k + 5e-10 and k − 5e-10.

### 2. [major] paper/p1-local.tex:206-218 (Cor. local-side)

**Problem.** The completeness half of the corollary is false. TG sets theta = 0 whenever s(0) ≥ t. In that branch the proof of Thm local(ii) uses p ≥ Pr[S = ⌈s(0)⌉], not Pr[S = t]. The corollary's condition Pr_{D_θ}[H | S = t] ≥ π_H says nothing about mass near s(0). Counterexample: take H = [S ≤ t] (an arbitrary circuit, as the corollary allows) with t ≤ s(0) − c·m. Then π_H = 1, (H1)–(H3) hold, and p = Pr_D[S = t] = e^{−Ω(m)}. TG at theta = 0 is plain Monte Carlo and needs about 1/p samples, not poly(n)·1/π_H. Numerically (corside.py, chain m = 60, s(0) = 29.9, t = 11, p = 1.0e-7): after 4·10^5 samples the certified ratio was 1.26·10^6.

**Proposed fix.** Restate the condition at the integer the anticoncentration step actually uses. For example: 'whenever Pr_{D_θ}[H | S = s'] ≥ π_H at the chosen θ, for some integer s' ≥ t with |s' − s(θ)| ≤ 2√n' (s' = t when s(0) < t, s' = ⌈s(0)⌉ when θ = 0). Alternatively, restrict the corollary to s(0) < t ≤ s(θ0). The proof then uses v(θ) ≥ Pr[S = s']·π_H together with Lemma local-anti.

### 3. [minor] paper/p1-local.tex:151 vs 210-211 (Cor. local-side example)

**Problem.** The corollary's example 'π_H = D(H) when H reads only variables outside all scopes' contradicts (H1), which requires every variable to lie in some scope. The completeness proof also uses n ≤ km, which (H1) supplies and extra unscoped variables can break.

**Proposed fix.** Apply (H1)–(H3), and the n of the bounds, to the scoped variables only. Note that unscoped variables are independent of S under D_θ, are drawn exactly, and add only to the evaluation cost of H.

### 4. [minor] paper/p1-local.tex:298-334 (Experiments paragraph and tab:local)

**Problem.** Several numbers do not match `exp_local.py` or the caption's definitions.
(i) The text and caption say every row ran at ε = 0.3, but the cubic N = 100 row was run with eps = 0.2 (`task_regular_small`).
(ii) The caption defines the MC column as the samples a Monte Carlo KL interval needs for the same ratio. For the N = 100 row it shows 10^7, which is the number of MC samples drawn; that interval has ratio 1.056. Matching TG's ratio 1.234 at p ≈ 10^-3 needs only about 6.7·10^5 samples (`mc_samples_needed`).
(iii) Line 200 says v(θ)√m ≈ 2 while line 316 says ≈ 2.2. The CFTP ratio 2.85 is given as '2.8' in the text but '2.85' in the table.
(iv) 'Every interval contained p or overlapped the Monte Carlo interval' is vacuous for the N = 1500 cubic row, which has no reference value.

**Proposed fix.** State ε = 0.2 for the N = 100 row, or rerun it at ε = 0.3. Put 6.7·10^5 in its MC column, or mark the cell as 'MC samples used'. Use one value for v(θ)√m: 2.1–2.25 on the Glauber rows, 0.8–1.05 on the CFTP rows. Write 2.85 (or 2.9). Say 'every interval with a reference value'.

### 5. [minor] paper/p1-local.tex:123-124 (Rao–Blackwell variance factors); author report

**Problem.** The claim that Rao–Blackwellisation 'cut the variance by factors 2.8–4.4 in our instances' is not produced or logged by `exp_local.py`, and the author's report gives a different range (3–4.4×). Re-measuring on the three Glauber instances with 1500 samples per tilt gave 4.3–4.7 for the chain and 2.7–3.1 for the two cubic instances. So the stated range is roughly right but unsupported, and its upper end is exceeded.

**Proposed fix.** Have `exp_local.py` record Var(S)/Var(S_RB) at a few grid points for each instance, and quote the logged range (about 2.7–4.7).

### 6. [minor] paper/p1-local.tex:134-136 (T1) vs paper/app-local.tex:166-175 (pilot) and code/rareprob/localthr.py:814 (_pilot)

**Problem.** (T1) defines N_tot = L + N_IS, so the pilot samples are outside the coupling budget, and the code does the same. The appendix says 'The pilot samples are included in N_tot', and the completeness proof needs this: its first line couples all samples, pilot included, at total cost δ/5. Separately, Thm local(ii) is proved for the median-of-means pilot on L_p = ⌈2θ0V_max/√n⌉ grid points. The implementation instead uses 10 points, one mean of 256 chains with no median, linear interpolation, and per-sample TV 1e-3. So no experiment exercises the procedure that Thm local(ii) analyses. Soundness is unaffected.

**Proposed fix.** In (T1), say that for completeness N_tot also counts the pilot samples (soundness does not need them counted). Add a sentence that the implementation uses a heuristic pilot, which affects only the choice of θ and the window, and that Thm local(ii) refers to the pilot of app:local.

### 7. [minor] paper/p1-local.tex:87-88 (attribution of Lemma local-mix(b))

**Problem.** Part (b) is said to be 'proved by path coupling [bubleydyer1997]'. The appendix proof of (b) is the classical Dobrushin argument: identity coupling with shared uniforms, tracking per-site disagreement probabilities. Path coupling appears only in the proof of (c).

**Proposed fix.** Change to 'proved by the standard Dobrushin coupling (see the appendix); part (c) uses path coupling [bubleydyer1997] and [LPW, Section 13.1]'.

### 8. [minor] paper/p2-gibbs.tex:22-28 (Prop. gibbs, completeness clause)

**Problem.** (i) The importance-sampling cost O(log(1/δ_v)/(ε²·v_C)) leaves out the log log K term that Thm envelope(iv) carries: O(K(log(1/δ) + log log K)/ε²). (ii) 'L as in thm:local(ii) when the column sums of κ(θ) are also at most 1−γ' does not follow as written. That L was derived using θ ≤ θ0 (θ²V_max ≤ n/(γ(k−1)²) and θR ≤ θ0·m). A Gibbs node may supply θ > θ0 whenever its κ(θ) has small column sums, and then the L bound grows by (θ/θ0)².

**Proposed fix.** Write the importance-sampling cost as O((log(1/δ_v) + log log(1/v_C))/(ε²·v_C)). Replace the parenthetical with 'L = O((θ²·n·d²/γ + θ·m)·log(1/δ_v)/ε²) when the column sums of κ(θ) are at most 1−γ' (from V_max = nd²/(4γ) and Lemma local-mix(c)). This equals the L of thm:local(ii) when θ ≤ θ0.


## Fixes

I checked every referee finding myself and found all of them correct. All are fixed in the files I own; nothing is left open.

**Code (the major soundness bug):**
- `ltc_from_circuit` used to round the threshold as ceil(T - 1e-9), while the evaluator fires at sum >= T - 1e-12. It now takes the integer t from the evaluator itself (`_thr_count_threshold`): a copy of the THR gate is evaluated on every count of true children. Above fan-in 4096 it bisects instead and checks both sides of the result. The function returns None (no recognition) if the gate is not a threshold of the count. As an extra guard, it compares the recognised LTC with C on 256 random inputs and also returns None if they disagree.
- `LTC.__post_init__` now rounds a non-integer t up instead of truncating it, and raises on nan or inf.
- On the referee's counterexample (threshold 3 + 5e-10), the recognised LTC now agrees with C on all 256 inputs and 0 of 20 TG runs missed p (previously 20 of 20).

**Paper:**
- **(H1)** now applies only to variables that lie in some scope. Their number, n_S <= km, replaces n throughout Lemma local-mix(c), Lemma local-anti, the pilot, and Thm local(ii) and (iii).
- **Cor local-side** is restated. The condition on H must hold at S = t (for every tilt in [0, theta_0]) when s(0) < t, and at S = ceil(s(0)) when s(0) >= t. A short remark gives the referee's H = [S <= t] counterexample. The example "H reads only variables outside all scopes" is now consistent with (H1).
- **Thm local(ii)** now states 0 < eps <= 1, the cap N_IS (at least the importance-sampling count for K_0 = 16 e^{c_1} sqrt(n_S)) and ln(10/delta). The constants are in displays, which also fixes a 122 pt overfull box.
- **Thm local(iii)** gains a new proved bound for every integer t in [s(0), s(theta_0)]: p <= exp(-(t - s(0))^2 v_min / (2 V_max^2)). The text now claims p = e^{-Omega(m)} only for t >= s(0) + cm, and notes that thresholds near s(0) are not rare.
- **Appendix constant slip:** the bound now uses ell = ln(10/delta), and the derivation of the u bound is spelled out.
- **Pilot and N_tot:** the analysed pilot counts its samples in N_tot; soundness does not need this. The text and the code docstring now say the implementation uses a heuristic pilot, which affects only the width.
- **Attribution:** part (b) of Lemma local-mix is now credited to the shared-uniform Dobrushin coupling, and path coupling only to part (c).
- **Remark local-blocks (b):** now assumes E g < a < max g, integer t = ak, span 1, and the lattice form of Bahadur–Rao.
- **Prop gibbs:** the importance-sampling count now includes the log log K term. L is O((theta^2 m^2/eps^2 + 1) log(1/delta_v)) in general, and O((theta^2 n_S d^2/(gamma eps^2) + theta m/eps + 1) log(1/delta_v)) when the column sums of kappa are at most 1 - gamma. The proof is given.
- I also added the log log term to the count in the proof of Prop local-cftp; no referee raised it.

**Experiments:** every task in `exp_local.py` now runs at eps = 0.3 and logs extra diagnostics:
- the row sums of kappa and the exact Dobrushin row sums;
- the Rao–Blackwell variance factors at four tilts;
- ns per site update, with the pilot included;
- for the N = 100 row, the Monte Carlo sample count needed for the same ratio (6.7e5).

I reran the full experiment, so `local.json` and `local_log.txt` are consistent and the stale log entries are gone. Results:
- The chain, cubic N = 1500, N = 100, CFTP theta = 1.5 and coverage rows reproduce exactly. The N = 100 row is identical at eps = 0.3 because importance sampling hit its 50,000 cap either way.
- CFTP theta = 2.5 changed slightly, because the new diagnostics draw from the shared random generator between the two CFTP runs: ratio 2.88, interval [-170.00, -169.54].

All numbers in the text and table now match the logs:
- Rao–Blackwell factors 2.7–4.8 (Glauber instances) and 1.5–2.4 (CFTP chain).
- Exact Dobrushin row sums 1.27 and 1.70 against kappa row sums 1.5 and 2.5.
- 15–22 ns per site update.
- v(theta) sqrt(m) between 1.7 and 2.3; caption corrected.

**Build:** the paper builds in a scratch copy (with the external edits below applied) with no overfull boxes, undefined references or undefined citations from my files. The citation warnings that remain belong to other agents' files.

**Bibliography:** web search confirmed Dobrushin 1970 (Theory Probab. Appl. 15(3):458–486, DOI 10.1137/1115049) and Bubley–Dyer FOCS 1997 (pp. 223–231, DOI 10.1109/SFCS.1997.646111). These were the two entries the earlier round could not confirm.

Files: /home/user/AI-works/circuit-output-fraction/paper/p1-local.tex, /home/user/AI-works/circuit-output-fraction/paper/app-local.tex, /home/user/AI-works/circuit-output-fraction/paper/p2-gibbs.tex, /home/user/AI-works/circuit-output-fraction/code/rareprob/localthr.py, /home/user/AI-works/circuit-output-fraction/code/tests/test_localthr.py, /home/user/AI-works/circuit-output-fraction/experiments/exp_local.py, /home/user/AI-works/circuit-output-fraction/experiments/results/local.json, /home/user/AI-works/circuit-output-fraction/experiments/results/local_log.txt.
