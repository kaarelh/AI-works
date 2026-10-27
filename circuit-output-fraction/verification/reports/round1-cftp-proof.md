# Round 1 referee report: cftp (proof lens)

**Verdict.** needs major fixes. The proofs in sec:cftp hold up: Prop. prop:truncation, the anti-monotonicity and Häggström–Nelander exactness claim, the bias accounting and the gamma coalescence bound are all correct. But Thm. thm:cftp is missing a hypothesis: every event must have b_i ≤ 1/2, and for general unate circuits b_i must also be certified. Without it the staging step "Harris-guaranteed r_k ≥ 1/2" can fail. telescoping_estimate in code/rareprob/cftp.py does not check this hypothesis, and on valid unate CNFs it returns intervals that miss p far more often than delta allows. It also has an input-handling soundness bug: a clause that repeats a variable gets the wrong D(B_c).

**What was checked.** Paper (sec-part1.tex, subsection sec:cftp, plus sec:independence for the unateness definition and Harris):
(1) Prop. prop:truncation is correct. pi = (1-theta) pi_T + theta pi_{>T} gives d_TV(pi_T, pi) = theta * d_TV(pi_T, pi_{>T}) ≤ theta. The Chernoff step is also right: if theta > eta then X ~ Bin(R, theta) has mean mu > eta R and the threshold eta R/2 ≤ mu/2, so Pr[X ≤ eta R/2] ≤ exp(-mu/8) ≤ exp(-eta R/8) ≤ delta.
(2) The heat-bath update on D|F, with F a down-set, is x_v <- [u<q_v] AND [x^{v->1} in F]. This is the exact heat-bath conditional for states in F, and it is decreasing in x_{-v} on all of {0,1}^n, so the chain is anti-monotone in the HN sense. The cross-over bounding chain (L_v = f(u, U), U_v = f(u, L)) keeps L ≤ X ≤ U for every chain started in F. It also preserves interval inclusion, so coalescence from -T implies coalescence from -2T at the same value, and CFTP with doubling and reused randomness is valid. Coalescence happens almost surely whenever D(F) > 0, by a positive-probability sweep, so the sampler is Las Vegas.
(3) Bias in Thm. thm:cftp is correct: |r'_k - r_k| ≤ theta_k, relative shift ≤ 2 eta when r_k ≥ 1/2, and (1 + eps/(8m))^m ≤ e^{eps/8} ≤ 1 + eps/4.
(4) The coalescence bound is correct, including for general increasing events. A site can newly disagree only if u < q_v and some event containing v has a disagreeing co-member. That gives E|D_{t+1}| ≤ (1 - gamma/n)|D_t| with gamma = 1 - q_max r (k_max - 1), so Pr[no coalescence by T] ≤ n e^{-gamma T/n} and T = O((n/gamma) log(nm/eps)). Simulation on the 2x10 ladder confirms the bound holds (it is conservative).
(5) Variance by product of independent ratio estimates and Chebyshev plus median: correct given r'_k ≥ 1/2 - eta.
(6) Citations hn1998 and pw1996 are correctly attributed and cited.

Code (cftp.py):
(1) CFTP mechanics are correct. Randomness for times -1..-T is reused when T doubles, and new randomness is appended for the older times. The L/U updates use each other's old values. Padding columns n (always 1) and n+1 (always 0) handle short and absent clauses, and unit clauses fire correctly.
(2) The sampler matches the target: on a 2x3 hard-core ladder with 200k samples, TV to the exact D|F is 0.003, which is noise level.
(3) Truncation TV ≤ failure fraction holds empirically at several T_max settings.
(4) The repetition count is right: _reps_for(0.025) = 13 with binomial tail 0.0243, and Chebyshev with eps0 = 2 sqrt(v) gives ≤ 1/4 per repetition conditional on the halted counts.
(5) The union bound is right: delta/2 for the median plus K x delta/(2K) for the KL truncation certificates.
(6) Relative variance ≤ 1.5/n_k per stage when r' ≥ 0.4.
(7) The upper end hi = med e^b/(1-eps0) is valid.
(8) The lower end lo = med/((1+eps0)e^b) is valid, but only by an argument the docstring does not give (see findings).
(9) The Harris clamp is deductive.
(10) Coverage in the valid regime is fine: 30/30 runs contain p on a 14-variable 2-CNF.

Scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/cftp/: exp1.py, exp1b.py, exp2.py, exp3.py, exp4.py, exp5.py, exp6.py, exp7.py.

## Findings

### 1. [critical] code/rareprob/cftp.py, UnateSystem.stages (lines 54-65) together with telescoping_estimate (lines 184-191: bias += th/(0.5-th); v = (1+1.5/nmin)**K - 1)

**Problem.** stages() always opens a new stage with the next clause, even when 1 - D(B_c) < 1/2. Such a clause becomes a singleton stage whose guaranteed ratio is only 1 - D(B_c) < 1/2. But the variance bound 1.5/n_k and the bias factor th/(0.5 - th) both assume r_k ≥ 1/2, so the returned interval is invalid. The input is a legitimate unate CNF and is_unate accepts it. Reproduction: 10 unit clauses [(i,1)] with q_i = 0.02, so p = 1.02e-17 and every stage ratio is 0.02. With N=200, hi < p in 16 of 20 runs; with the default N=2000, hi < p in 5 of 20 runs. Nominal delta is 0.05 (exp1.py, exp1b.py).

**Proposed fix.** Use a per-stage Harris guarantee h_k = prod_{c in stage k}(1 - pb_c) instead of the constant 1/2. Require th_k < h_k, otherwise return no verdict. Set the bias term to a_k = th_k/(h_k - th_k). Set the variance bound to v = prod_k (1 + (1 - h_k + th_k)/((h_k - th_k) n_k)) - 1. Alternatively, return 'no verdict' whenever max_c pb_c > 1/2.

### 2. [major] sec-part1.tex, Theorem thm:cftp ('group the events into stages with Harris-guaranteed ratios r_k ≥ 1/2 ... for every unate circuit')

**Problem.** The staging step needs every b_i ≤ 1/2: an event with b_i > 1/2 cannot be placed in any stage with guaranteed ratio ≥ 1/2. The bias argument (relative shift 2 eta) and the variance argument both rely on r_k ≥ 1/2, and nothing in the statement guarantees it. The coalescence condition gamma > 0 does not imply it either. For unit clauses k_max = 1, so gamma = 1 for any q. For a perfect matching with q = 0.9, gamma = 1 - 0.9 > 0 but b = 0.81. Second gap: for general unate circuits, as opposed to unate CNFs, b_i = D(not A_i) is not computable. Staging on point estimates can produce a stage whose true Harris product is below 1/2. The proof sketch and the code only treat CNFs, where b_i is a product of marginals.

**Proposed fix.** Add the hypothesis max_i b_i ≤ 1/2, or state the general version. With per-stage guarantee rho_k = prod_{i in stage}(1 - b_i), the relative shift is eta/rho_k, the per-stage relative variance is ≤ (1 - rho_k + eta)/((rho_k - eta)N), and one needs eta ≤ eps rho_min/(16m). For general unate circuits, first estimate each b_i additively, e.g. to ±0.05 with O(log(m/delta)) samples each, union-bounded over the m events. Then stage using the upper confidence bounds b_i^+ and charge their failure probability to delta.

### 3. [major] code/rareprob/cftp.py, UnateSystem.__init__ (line 51-52: self.vars, self.pb = prod r[i] for i in vars)

**Problem.** If a clause repeats a variable, pb multiplies r_v once per occurrence. is_unate accepts this, since the sign is consistent. So D(B_c) is underestimated: r_v^2 instead of r_v. The Harris clamp lo = max(lo, prod(1 - pb)) then exceeds p, and the stage guarantees are wrong too. Reproduction: clauses [(0,0),(0,0)] and [(1,0),(1,0),(2,0)] with q = 0.5. Then p = 0.375, but the code returns lo = 0.656 and hi = 0.419, an empty interval that excludes p (exp7.py). janson_interval in janson.py computes P(B_i) the same way and probably has the same issue.

**Proposed fix.** Deduplicate the variables of each clause before computing vars and pb, e.g. self.vars = [sorted({i for i, _ in c}) for c in clauses], and compute pb from the deduplicated lists. Do the same in janson.py. Alternatively, reject clauses with repeated variables.

### 4. [minor] sec-part1.tex, Theorem thm:cftp: 'estimate each r_k with O((mu+1)/eps^2) truncated exact samples'

**Problem.** mu is never defined. It appears undefined in thm:janson-general too, and from context it is the expected number of violated events, sum_i b_i. The proof sketch also never links the number of stages K to mu, yet that link is what makes N = O(K/eps^2) equal O((mu+1)/eps^2).

**Proposed fix.** Define mu = sum_i b_i. Add: with b_i ≤ 1/2, greedy staging closes a stage only when the stage plus the next event has sum of -ln(1 - b) > ln 2. Summing, K < 1 + 2 sum_i(-ln(1 - b_i))/ln 2 ≤ 1 + 4 mu, using -ln(1 - b) ≤ 2 ln2 b on [0, 1/2]. Hence N = O(K/eps^2) = O((mu+1)/eps^2) samples per stage and O((mu+1)^2 log(1/delta)/eps^2) in total.

### 5. [minor] sec-part1.tex, Theorem thm:cftp: 'certify each stage's truncation at level eta = eps/(16m) by prop:truncation' and 'The output is within (1±eps)p with probability 1-delta'

**Problem.** The delta bookkeeping is missing: each of the m certificates must run at level delta/(2m), which requires R = ceil(8 ln(2m/delta)/eta) = O(m log(m/delta)/eps) runs per stage. That certification cost is not stated, and when m >> mu/eps it dominates the O((mu+1)/eps^2) estimation budget. It is also wasteful to use m where the number of stages K ≤ 4mu + 1 suffices. Two smaller points. First, 'within (1±eps)p' only holds when the output is not 'fail'; under def:sound the output should be the interval [p_hat/(1+eps), p_hat/(1-eps)]. Second, the completeness claim needs Pr[tau > T] well below eta for the threshold test to pass with probability 1 - delta. Example: with theta ≤ eta/16, Pr[X > eta R/2] ≤ (e/8)^{eta R/2} ≤ (delta/m)^{4}. This is where T ≥ (n/gamma) ln(256 n m/eps) comes from.

**Proposed fix.** State eta = eps/(16K), certify at level delta/(2K) with R = ceil(8 ln(2K/delta)/eta) runs per stage, and give the total cost: O(K^2 log(K/delta)/eps + K(mu+1) log(1/delta)/eps^2) CFTP runs, each of at most T = O((n/gamma) log(nm/eps)) updates. Rephrase the conclusion as a sound interval, or 'fail'.

### 6. [minor] code/rareprob/cftp.py, telescoping_estimate line 175 (math.log(max(rk, 1e-300))) and line 190

**Problem.** When p = 0 the returned lower bound is positive. p = 0 happens when some clause has pb = 1, e.g. a literal with marginal 0. The observed r_hat_k = 0 is replaced by 1e-300, so lo comes out around 7e-301 > 0 = p. Reproduction: clause [(0,1)] with q_0 = 0, giving lo = 7.3e-301 (exp5.py). Also, for later stages D(F_{<k}) = 0, so the conditional target is undefined.

**Proposed fix.** If any pb_c == 1, return the exact interval [0, 0]. Otherwise allow lo = 0: when the median repetition contains a zero ratio, set lo = 0 instead of flooring at 1e-300.

### 7. [minor] code/rareprob/cftp.py, module docstring (lines 15-23) and telescoping_estimate docstring (lines 149-156)

**Problem.** The module docstring states relative variance '(1 + 1/N)^K - 1', but the code uses 1.5/N. The 1.5 is the correct constant, since r' ≥ 0.4 after truncation. The function docstring says the mean is 'within prod(1 ± theta_k/(1/2 - theta_k)) of p'. That justification does not give the lower end lo = med/((1+eps0)e^b) used at line 190, because prod(1 - a_k) < e^{-sum a_k}. The code's lo is still valid, by a different argument: r'_k ≤ r_k + theta_k and r_k ≥ 1/2 give r_k/r'_k ≥ 1/(1 + 2theta_k) ≥ e^{-2theta_k} ≥ e^{-a_k}. Separately, the code is not the paper's procedure. It uses a data-driven KL upper bound on the failure rate and widens the interval, rather than the fixed-eta threshold test of prop:truncation, and it takes N as input rather than eps.

**Proposed fix.** Correct the constant to 1.5/N. Replace the justification with the r'_k ≤ r_k + theta_k argument above. Add one sentence in sec:cftp or sec:experiments saying the implementation certifies truncation with a KL upper bound and inflates the interval by e^{sum a_k}, which is an equally valid variant of prop:truncation.

### 8. [minor] sec-part1.tex, sec:cftp paragraph before thm:cftp: 'is then an exact Las Vegas sampler for D|F_{<k}, whatever the events are'

**Problem.** The claim is correct, but two hypotheses are left implicit, and the almost-sure termination that 'Las Vegas' requires is not argued. 'Anti-monotone' holds in the Häggström–Nelander site-wise sense (Pr[x_v=1 | x_{-v}] is decreasing in x_{-v}), not for the update map as a whole. The events must be increasing, which is what makes F a down-set. CFTP halts almost surely only if D(F_{<k}) > 0.

**Proposed fix.** Add: 'for increasing events B_i with D(F_{<k}) > 0 (guaranteed by Harris when all b_i < 1)'. Add a one-line termination argument. With positive probability within a window of n steps, every site with q_v < 1 is updated with u ≥ q_v, and then every site with q_v = 1 is updated. After that window L = U, because 1_{q=1} lies in F when D(F) > 0. Disjoint windows are independent, so coalescence happens almost surely.

### 9. [minor] sec-part1.tex, sec:independence definition of 'unate' ('every path from x_v to the output has the same parity of negations'), used as the hypothesis of thm:cftp

**Problem.** sec:setting allows ⊕ gates and threshold gates with arbitrary weights. A path through an ⊕ gate, or through a negative-weight threshold input, can contain no ¬ gates and still be non-monotone. For example, x ⊕ y passes the parity test but is not unate. So the syntactic test as worded does not guarantee that the B_i are increasing, and the Harris and anti-monotone arguments in thm:cftp need them to be.

**Proposed fix.** Define unateness on the NNF instead, with ⊕ expanded and thresholds rewritten: each input variable occurs as a literal of only one polarity. Equivalently, count a negative-weight threshold input as a negation and treat ⊕ inputs as occurring with both polarities.

### 10. [minor] sec-part1.tex, end of sec:cftp: 'By Karp--Luby--Madras, ORs of unate ∧-circuits (with different polarities) follow.'

**Problem.** This is stated as a consequence but not proved. KLM needs (1) relative-error estimates of each D(A_j), with the bias they induce in the index-sampling step bounded as in thm:boxes, and (2) conditional samplers for D|A_j whose truncation TV error is budgeted. KLM's per-sample mean is ≥ 1/t, so each sampler needs eta = O(eps/t). None of this is shown.

**Proposed fix.** Either add these two conditions and the parameter choice eta ≤ eps/(c t) and per-disjunct relative accuracy eps/c, with a two-line argument, or downgrade the sentence to a remark ('should extend, via KLM, to ...').

