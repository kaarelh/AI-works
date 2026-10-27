# Final referee report: local

**Verdict.** sound with minor fixes

**What was checked.** Final-round review of local thresholds: p1-local.tex, app-local.tex and p2-gibbs.tex, plus the parts of sec-setting.tex and sec-envelopes.tex they use (thm:envelope(iv), prop:tilting, def:sound/def:argument), and the PCIS rule definitions in p2-pcis.tex. Code: code/rareprob/localthr.py, stats.py, circuit.py (THR evaluation), and the TG call in meta.py.

PROOFS RE-DERIVED BY HAND (all hold):
- lem:local-mix (a)-(c):
  - (a) The hull/MVT bound; monotonicity in theta; kappa <= theta n_il/2; the crude certificate.
  - (b) The identical-uniform coupling with the weighted max-ratio induction, F = sum w / min w.
  - (c) Path coupling gives contraction 1 - gamma/n from the column sums; LPW Thm 13.1 then gives gap >= gamma/n; Poincaré gives Var <= (1/gamma) sum E Var(f | x_-i) <= sum osc^2/(4 gamma).
- The Riemann bracket.
- lem:local-ti: E D_r >= mean of the two variances; Maurer with tau = a sqrt(E Sigma) and a = R sqrt(ln 1/delta2); the Bernstein root u(v); the monotone-event union.
- lem:local-ti-window: bias <= E E_l <= M; non-identically distributed Hoeffding-KL; a = sqrt(2 (2w^2) ln).
- lem:maurer.
- lem:pb-local: the tilt to a mode via log-concavity; Chebyshev window giving 3/(8 sqrt N + 4); Lambda'' >= v/e on [-1, 1].
- lem:local-anti: eta0 = beta e^-2; (E1)-(E3); b = 3 + d/sqrt(gamma); both m0 terms; c1 = 4 e^5 b^2 k/(nu^2 beta).
- Pilot: the median-of-means union bound, |s(theta) - t| <= 5/4 sqrt(n_S), and the theta = 0 branch at ceil(s(0)).
- Normaliser completeness: Sigma <= 2 E Sigma + (4/3) R^2 ln(5/delta); E Sigma <= L Vmax/2 + h Vmax R/2; Vbar <= 2a^2 + 4 Sigma; u <= 2 theta sqrt(8 Vmax ell/L) + 6 theta R ell/L, with coefficients sqrt(20) + 2/3 <= 6 and the sqrt(theta R)/L <= 1 step.
- Final ratio: e^{3 eps/10}(1 + eps/3) <= 1 + eps by convexity. Failure budget: about 2.2 delta, within the stated 3 delta.
- thm:local(iii): Var >= E N eta0(1 - eta0) >= v_min; integration by parts; the new third bound via t - s(0) <= theta Vmax.
- cor:local-side and its counterexample remark.
- prop:local-cftp: monotonicity of the class updates; coupling with the uncapped run; Pr[no coalescence] <= F alpha^tau.
- rem:local-blocks (a)-(c), including the lattice Bahadur-Rao constant (1 - e^{-theta_a}) sigma sqrt(2 pi k).
- prop:certgap (a) and (b): lambda <= 3 eps p/B <= 1/2; the mixture coupling; Z e^{-theta t} >= 2 sqrt(q(1-q)); E W^2 = q^2(2 - q) cosh^{2M}(theta/2) <= 2.07 q^2.
- prop:gibbs: both L values, the log log term, and the lower-bound downgrade.
- The AIS unbiasedness and the (4/c)^{r/2} median bound.

CITATIONS: Checked LPW 13.1 (Chen's contraction theorem), Bubley-Dyer, Dobrushin 1970, DGJ 2009, Maurer 2003, Hoeffding 1963 (non-identical case), Bahadur-Rao 1960 (lattice case), Friedman 2008, Davies-Perkins, JPSS, Neal 2001, GW 1997 and Gelman-Meng. All 15 keys are in refs.bib. A scratch build has no undefined references or citations and no overfull boxes from these three files; tab:local renders correctly.

RUNS (scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/final_local/):
- pytest tests/test_localthr.py: 48 passed.
- recog.py and recog2.py from the earlier round: 0 mismatches, 0/20 misses.
- recog_edge.py: thresholds nan, ±inf, ±1e308, ±0, ±1e-13, k ± 1e-12 / 2e-12 / 1e-11, 2.0000000001; repeated, constant, bare, NOT and XOR children; AND with a non-unit THR first; AND(THR) alone; AND(THR, THR, ·); a nested THR; H on unscoped variables; extreme q. All gave 0 mismatches over all 2^7 inputs and 0 TG misses.
- cover.py: 1264 adversarial random LTCs (n <= 11) against brute force at delta = 0.5. Settings included both samplers; q in {1e-12, 1e-6, 1e-3, ...}; H unsatisfiable, OR, XOR or AND; constant factors; forced theta up to 20 with caps up to 30; L in {2, 4, 10, 50}; max_is from 20 up; windows 0 to 8; rb on and off; gamma in {0, 0.01, 0.25, 0.6}. Result: 0 errors and 3 misses among 1216 verdicts. All three are importance-sampling KL misses with 200 to 2000 samples. Rerunning the two non-trivial cases 60 times each gave 0/60 and 1/60, consistent with the delta/5 level.
- ticheck.py: lem:local-ti and lem:local-ti-window with exact samples, L in {2, 4, 20}, theta in {0.5, 3}, tiny on- and off-centre windows: 0 misses in 36000 trials.
- notypes.py: the more-than-16-distinct-marginals sampler path. TV of the S-law matches noise, and 0/48 misses.
- overflow.py: huge and invalid theta.
- floaterr.py: rounding of update probabilities against 60-digit Decimal.
- Numerical checks: the Poisson-binomial bound has min ratio 2.55 over 3000 laws; certgap(b) gives log2 K_min - n/2 of about 1 and second moment 2.00-2.06.

EXPERIMENT-DEPENDENT CLAIMS: compared with experiments/results/local_log.txt (regenerated today 11:45); details in the last finding.

## Audit of earlier findings

resolved: 19, partially resolved: 1

- [resolved] (major) R1-1 (referee 1, major) ltc_from_circuit threshold tolerance 1e-9 vs evaluator 1e-12: localthr.py:_thr_count_threshold now reads the integer t off a copy of the THR gate evaluated by Circuit itself, at every count, or by bisection plus side checks when fan-in >= 4096. ltc_from_circuit also checks 256 random points. Re-ran recog.py: t=4, 0 mismatches, 0/20 misses. My recog_edge.py (nan, ±inf, ±1e308, k±1e-12/2e-12/1e-11, repeated/constant/nested children, AND variants) gave 0 mismatches on all inputs and 0 TG misses. def:ltc (p1-local.tex:18-20) now states the rule.
- [resolved] (minor) R1-2 (referee 1) cor:local-side example 'H reads only unscoped variables' contradicts (H1); proof used n <= km: (H1) is now restricted to variables in some scope (p1-local.tex:158), and n_S <= km is defined at lines 55-57. n_S replaces n in lem:local-mix(c), lem:local-anti (app-local.tex:146-166), the pilot, and thm:local(ii)/(iii). The example at lines 233-234 is now consistent, and the corollary's proof notes that unscoped variables are independent of S under D_theta.
- [resolved] (minor) R1-3 (referee 1) RB variance factors '2.8-4.4' unsupported: Text (lines 127-129) now reads 2.7-4.8 on the Glauber instances and 1.5-2.4 on the CFTP chain, measured at four tilts. local_log.txt diag.rb_factor gives 4.35-4.76, 2.76-3.04 and 2.66-2.92 (Glauber) and 1.47-2.42 (CFTP), so the text matches.
- [resolved] (minor) R1-4 (referee 1) 'Dobrushin row sums 1.5 and 2.5' are kappa row sums: Lines 284-287 and 342-345 now give kappa row sums 1.5/2.5 with exact sums 1.27/1.70, and Glauber kappa sums 0.98/1.34/1.37 with exact 0.97/1.32/1.35. All match diag.kappa_row_sum and exact_row_sum in the log.
- [partially resolved] (minor) R1-5 (referee 1) experiment details: eps=0.2 for N=100, ns per update, pilot sweeps, 2.8 vs 2.85: Resolved: every log row has eps=0.3; the caption says pilot chains run to TV 1e-3; the CFTP ratio is 2.88 in both text and table. Still open: the timing figures do not match the current local_log.txt (regenerated 11:45 today). The text says '15-22 ns per site update', the log has 14.6, 37.9, 32.7, 26.1 and 23.3. The table 's' column says 332/480/24/32/36, the log has 687/824/23/38/40. The caption says '(72 s)', the log has mc_seconds 77.2. These need refreshing after the regeneration (see the new finding).
- [resolved] (minor) R1-6 (referee 1) thm:local(ii) misses eps<=1, the N_IS cap and ln(5/delta): p1-local.tex:172-185 now states 0<eps<=1, b, c1, m0 and K0 in a display, L with ln(10/delta), and N_IS of at least the thm:envelope(iv) count for K0, eps/3 and delta/5. The proof uses all of them (app-local.tex:209-214).
- [resolved] (minor) R1-7 (referee 1) app-local Bernstein constant slip, ell should be ln(10/delta): app-local.tex:194-207 now sets ell = ln(10/delta) and spells out each step: Sigma <= 2 E Sigma + (4/3) R^2 ln(5/delta); Vbar <= 4 L Vmax + 4 h Vmax R + 10 R^2 ell; u <= (2/3) h R ell + h sqrt(2 Vbar ell). I re-derived u <= 2 theta sqrt(8 Vmax ell/L) + 6 theta R ell/L for L >= sqrt(theta R).
- [resolved] (minor) R1-8 (referee 1) prop:gibbs completeness: L parenthetical for theta>theta0, missing log log K, theta m < eps: p2-gibbs.tex:24-29 now gives the IS count with log log(1/v_C), L = O((theta^2 m^2/eps^2 + 1) log(1/delta_v)) in general, and O((theta^2 n_S d^2/(gamma eps^2) + theta m/eps + 1) log) under column sums <= 1-gamma. I checked the proof at lines 39-47, including that the u bound does not use theta <= theta0.
- [resolved] (minor) R1-9 (referee 1) (T1) excludes pilot from N_tot while the appendix includes it; implemented pilot is not the analysed one: (T1) at p1-local.tex:142-143 and app-local.tex:175-178 now agree: the analysed pilot is counted in N_tot, and soundness does not need it. The experiments paragraph (lines 346-350) and the _pilot docstring describe the heuristic pilot and say it affects only the width.
- [resolved] (minor) R1-10 (referee 1) lem:local-mix(b) attributed to path coupling: p1-local.tex:91-94 credits (b) to the shared-uniform Dobrushin coupling, in the weighted form of DGJ, and path coupling plus LPW 13.1 only to (c), matching the appendix proofs.
- [resolved] (minor) R1-11 (referee 1) rem:local-blocks(b) omits a < max g and lattice Bahadur-Rao: Lines 293-298 now assume integer-valued blocks with span 1, integer t=ak and E g < a < max g, and cite the lattice Bahadur-Rao theorem. I checked that K(theta_a) is about (1-e^{-theta_a}) sigma_a sqrt(2 pi k).
- [resolved] (minor) R1-12 (referee 1) 'By (iii), p=e^{-Omega(m)} at the reachable thresholds' overclaims: thm:local(iii) (line 193) adds p <= exp(-(t-s(0))^2 v_min/(2 Vmax^2)) for every integer t in [s(0), s(theta0)], proved at app-local.tex:228-231 (verified). The text (lines 215-219) now claims e^{-Omega(m)} only for t in [s(0)+cm, s(theta0)] and notes that thresholds t <= s(0)+2 sqrt(n_S) are not rare.
- [resolved] (major) R2-1 (referee 2, major) recognition tolerance mismatch, and LTC.__post_init__ truncating non-integer t: The recognition part is as in R1-1. threshold_to_int (localthr.py:62-67) now keeps integers and rounds other reals up, raising on nan/inf; I checked 2.5->3, -0.5->0, 1e-300->1. test_ltc_threshold_is_rounded_up_not_truncated passes.
- [resolved] (major) R2-2 (referee 2, major) cor:local-side completeness false in the theta=0 branch (H=[S<=t], t << s(0)): p1-local.tex:227-235 now requires Pr_{D_vartheta}[H|S=t] >= pi_H for all vartheta in [0,theta0] when s(0)<t, and Pr_D[H|S=ceil(s(0))] >= pi_H when s(0)>=t. The proof (lines 237-243) uses exactly the s' of thm:local(ii)'s proof, including the case where the pilot picks theta=0 with s(0)<t. Lines 245-247 give the counterexample with H=[S<=t], justified by (iii) applied to the tables 1-g_j.
- [resolved] (minor) R2-3 (referee 2) cor:local-side example contradicts (H1); n <= km: Same fix as R1-2.
- [resolved] (minor) R2-4 (referee 2) experiment mismatches: eps=0.2 for N=100, MC column, v sqrt(m) 2 vs 2.2, 2.8 vs 2.85, vacuous overlap claim: Each item checked against the log:
- eps is 0.3 in every row.
- The N=100 MC column is 6.7e5, equal to mc_samples_same_ratio = 673792, and the caption explains it.
- v(theta) sqrt(m) is '1.7 to 2.3' and '2.1 and 2.2'; the log gives 1.73, 2.14 and 2.25.
- The CFTP ratio is 2.88 in both text and table.
- The text now says 'every interval with a reference value'.
Timing figures are stale; see R1-5.
- [resolved] (minor) R2-5 (referee 2) RB factors not logged: exp_local.py logs diag.rb_factor at four tilts per instance, and the text matches (see R1-3).
- [resolved] (minor) R2-6 (referee 2) (T1) vs appendix on pilot samples in N_tot; analysed vs implemented pilot: Same fix as R1-9.
- [resolved] (minor) R2-7 (referee 2) lem:local-mix(b) attributed to path coupling: Same fix as R1-10.
- [resolved] (minor) R2-8 (referee 2) prop:gibbs: missing log log K; L parenthetical invalid for theta > theta0: Same fix as R1-8.

## New findings

### 1. [minor] paper/p1-local.tex:252-275 (prop:local-cftp, completeness clause and proof)

**Problem.** Completeness is claimed 'whenever coalescence takes poly(n) sweeps with high probability ... and v(theta) >= 1/poly(n)', with theta >= 0 unrestricted, and the proof says 'L = poly(n)/eps^2 suffices'. The width of lem:local-ti always contains the term (2/3)theta R ell/L plus the gap h(S_max - s(0)) = theta(S_max - s(0))/L, so L must be at least Omega(theta m/eps). For superpolynomial theta, L is superpolynomial. The hypotheses can hold at such theta: at t = S_max, v(theta) -> 1 as theta -> infinity (rem:local-blocks(c)).

**Proposed fix.** Add 'and theta <= poly(n)' to the completeness clause, or state the bound explicitly as in prop:gibbs: L = O((theta^2 m^2/eps^2 + 1) log(1/delta)) samples suffice.

### 2. [minor] paper/p1-local.tex:172-189 (thm:local(ii) statement) and app-local.tex:180-219 (its proof)

**Problem.** (T3) allows the optional clipping windows of lem:local-ti-window, which add 2 theta M zbar to the width of ln Z. The proof of (ii) bounds only u and h(S_max - s(0)), so it controls the window term only if no window is used. The statement does not say this; it fixes only the pilot, L and N_IS. A badly placed window, which (T1) permits, can make the interval loose.

**Proposed fix.** Add 'without windows (T3 applies lem:local-ti only)' to the hypotheses of thm:local(ii). Alternatively, require the window term to be at most eps/10 and include it in the ratio bound.

### 3. [minor] paper/p2-gibbs.tex:8-17 (def:gibbs-node) and prop:gibbs

**Problem.** The verifier recomputes kappa(theta), or checks supermodularity, by enumerating the 2^{|N(i)|} <= 2^{d(k-1)} configurations of each neighbourhood. Nothing in the node bounds d(k-1). The truth tables in the argument bound only k, since each table has 2^{|A_j|} entries, not the degree d. Example: k = 2 with scopes {0,j} for j = 1..n-1 gives an argument of size O(n) but |N(0)| = n-1, so verification takes 2^{n-1} steps. A prover can therefore make the verifier run in exponential time, contradicting the polynomial-time verifier of def:argument and the claim in p2-pcis that 'the verifier runs in time polynomial in |pi| and |C|'.

**Proposed fix.** In def:gibbs-node, have the verifier return [0,1] for the node unless d(k-1) <= c log(|pi| + |C_v|), as p1-tail does for Part 1 ('declining if dk > c log|C|'). Alternatively, let it use the cheap bound sigma' <= 1/4 (kappa_il <= theta max|Delta_i(x) - Delta_i(x^l)|/4, computable per factor pair) when the neighbourhood is large.

### 4. [minor] code/rareprob/localthr.py:780 (theta clamp) and 846-848 (log interval assembly); ti_interval line 677

**Problem.** For an overflowing tilt, TG returns a NaN lower end. tg_estimate accepts any theta <= theta_cap. With singleton scopes kappa is 0, so every theta is certified; and sampler='cftp' needs no certificate. At theta = 1e308, ti_interval computes That = inf and zlo = nan, so log_lo = nan. LocalEstimate.contains_log(log p) is then False. overflow.py reproduces this with m = 6 singleton scopes x_j, t = 6, q = 0.3, for both samplers: '[nan, 0] ok=False'. This is not reachable from meta_estimate (theta=None, theta_cap=4), and LocalEstimate.lo maps nan to 0. But the theorem allows every choice of theta in (T1), and the returned log interval breaks the class's own contract. theta = nan with sampler='cftp' raises AssertionError, which is acceptable.

**Proposed fix.** In tg_estimate, return no verdict (log_lo = -inf, log_hi = 0) when theta is not finite or when theta * max(|S_hi|, |S_lo|, |t|, 1) is not well below the float range (e.g. above 1e300). Also add a final guard: if any of zlo, zhi, log_lo or log_hi is nan, return no verdict. Add a regression test at theta = 1e308.

### 5. [minor] code/rareprob/localthr.py:59 (FLOAT_TV_PER_UPDATE = 2^-48) and paper/p1-local.tex:144-146 ((T2): 'half of eta is reserved for floating-point rounding')

**Problem.** The per-update floating-point allowance of 2^-48 is asserted, not derived, and it fails for extreme logits. The rounding error of a_i + theta*Delta in LocalModel._rt grows with |a_i| and theta*Delta. Against 60-digit Decimal arithmetic, |rho_float - rho_true| reaches 3.7 x 2^-48 at q = 1e-300, Delta = 3, theta = 230 (floaterr.py). Such a site with constant Delta_i has kappa = 0, so any theta is certified (theta_cap is user-set). The practical effect is nil: the excess matters only after about 5e11 site updates at delta = 0.05, against 1.8e10 in the largest experiment. Still, the stated budget is not a valid bound on every input.

**Proposed fix.** Use a per-update allowance that depends on the inputs, e.g. (|a_i| + theta*dmax + 2) * 2^-53 / 4 + 2^-53 per update (maximised over sites) in Certificate.sweeps, or reject theta*dmax + max|a_i| > 50. State the allowance in the paper's (T2), or in a footnote of thm:local(i).

### 6. [minor] paper/sec-intro.tex:103-110 (summary of thm:local) and p1-local.tex:164-165

**Problem.** The intro says: 'if every g_j has a private pivotal input, it is complete with poly(n)/eps^2 samples at every threshold reachable by a certified tilt'. thm:local(ii) also needs:
- (H1): marginals of scoped variables in [beta, 1-beta];
- m >= m0;
- fixed k, d, gamma, beta, nu;
- reachability by the crude tilt theta0 = 2(1-gamma)/(d(k-1)), not by any tilt that has a (weighted) certificate.
lem:local-anti, (E1) and (E2) use theta <= theta0 (the e^{±2} density bound and the column sums). In the experiments the weighted certificate reaches beyond theta0. p1-local.tex:164-165 likewise says '(H3) says that the threshold is reachable by a certified tilt'.

**Proposed fix.** In the intro: 'if the marginals are bounded away from 0 and 1 and a constant fraction of the g_j have private pivotal inputs, it is complete for m >= m0 with poly(n)/eps^2 samples (constants depending on k, d, beta, nu, gamma) at every threshold up to s(theta0), the mean under the crude certified tilt theta0, a range that contains thresholds with p = e^{-Omega(m)}'. In p1-local.tex:165, write 'reachable by the crude certified tilt theta0'.

### 7. [minor] paper/p1-local.tex:333-375 (Experiments paragraph and tab:local); also lines 127-129, 220-221 and 284-287 (experiment-dependent numbers)

**Problem.** These claims depend on experiment output that is being regenerated. Against experiments/results/local_log.txt (written 11:45 today), every number matches except the timings:
- every certified interval, ratio, sample count and sweep count;
- the MC counts 1.8e22, 3.3e25 and 6.7e5;
- the RB factors and the kappa/exact row sums;
- ln Z ±0.15/0.19 with window terms 0.06/0.07;
- the IS ratio of about 1.25 and v sqrt(m) of 1.73 to 2.25;
- the coverage run: 16 runs, 0 misses, median 2.05, error 2.2%.
The timings that differ:
- line 334 says '15-22 ns per site update', but ns_per_site_update is 37.9, 32.7, 14.6, 26.1 and 23.3;
- the table's 's' column says 332/480/24/32/36, but the log's seconds are 687/824/23/38/40;
- the caption says '(72 s)', but mc_seconds is 77.2.

**Proposed fix.** After the regeneration finishes, refresh the ns-per-update range, the 's' column and the Monte Carlo seconds from local.json. Alternatively, drop the wall-clock figures or give them as a range with 'on a shared machine, varying with load'. Recheck every other number listed above against the new local.json.

