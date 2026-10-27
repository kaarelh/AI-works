# Round 1 referee report: dfsb (counterexample lens)

**Verdict.** contains false statements. Theorem thm:dfsb (soundness, the pilot thresholds, the pruning argument, the interval-ratio propagation) is correct. Several claims around it are false as written: the "read-once compositions" inclusion in cor:dfsb(a), the O(1) tree size and cost in cor:dfsb(b), "no sampling at all" with K=1 in cor:dfsb(c), "read-once formulas (exactly)" once (R8) is applied, and the speed-up bound drawn from ETH in sec:part1-limits. Each has a short fix, given below.

**What was checked.** Read sec-part1.tex in full, plus sec-setting, sec-envelopes and sec-limits (for prop:worstcase), thm:sis in sec-part2, the appendix, and the refs.bib entries cited in my sections. Read code/rareprob/dfsb.py, nnf.py, cnf.py, compile.py and envelope.py to fix the rule order and the (R8) behaviour. All scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad.

Checked and correct:
(1) (T), (F), (D) and (B) are exact identities under product D. Phase-2 validity follows by a union bound conditional on the Phase-1 tree. All node operations are monotone.
(2) The pilot tail bounds. Exact binomial tails, for K in {1,2,4,64,1000}, m in {1,10,1000} and delta in {0.5,0.05,1e-6}, never exceed (delta/2m)^18 for density >= 1/K or (delta/2m)^6 for density < 1/(16K) (exp1_pilot.py).
(3) The (D)-OR ratio lemma: f(x') <= b f(x) for x' <= bx in [0,1]^k with b >= 1, and f(x') >= a f(x) for x' >= ax. I proved it by induction on k and checked 20000 random instances in exact rational arithmetic (exp1b.py). A float version shows spurious violations up to 1.11 from cancellation in 1-prod(1-x), so implementations need log1p/expm1, which dfsb._combine already uses.
(4) (1+eps/(3d))^d <= e^{eps/3} <= 1+eps holds for eps <= 1.
(5) Pruning: on the good pilot event the actual tree is a pruning of T*_K. It also contains T*_{16K} as a pruning when (E) is off, so |T*_{16K}| <= |actual tree| <= |T*_K|.
(6) cor(c)'s O(s 3^r) bound. I built an exact ideal-tree builder (ideal.py: the repo's DFSB with exact densities and no (E)) and ran it on 300 random formulas with |Conf| <= 5 and random product D, including q near 0 and 1. Nodes never exceeded s*3^r, and when every leaf was exact the combined value matched exact_prob (exp6_cutset.py).
(7) Soundness of the full DFSB on random small circuits with repeated children, XOR and NOT, and some q_i in {0,1}, at delta=0.1: 398 misses in 110842 runs. That is consistent with soundness. One crash appeared (see findings) (exp8_sound.py, exp9b.py).
(8) Citations I could check offline (Pearl 1988, Impagliazzo-Paturi 2001, Bodlaender et al. 2016, Ehrenfeucht-Karpinski 1990, Gopalan-Klivans-Meka 2010) match their use. I could not check the 2^{k/4.82} constant attributed to wangyin2024, because this run's web-search budget was used up.

## Findings

### 1. [critical] sec-part1.tex, cor:dfsb(a): "This includes read-once formulas (exactly) and read-once compositions F(lambda_1,...,lambda_t) of arbitrary K-dense circuits on disjoint variable sets"

**Problem.** The inclusion claim is false, for two separate reasons.
(i) Negation. Read-once F may negate an input. Take F(y) = NOT y and lambda = NOT C. Then lambda is K-dense for any circuit C with p <= 1-1/K, and F(lambda) = C. The claim would then give m_K(C) = O(s) for every such C, so DFSB would be complete on all 3-CNFs. By prop:worstcase(a) that implies NP is contained in BPP.
(ii) Rule order, even for monotone F. (D) is tried before (S), in the paper's list and in dfsb.py build(). So a dense lambda that is an OR of variable-disjoint rare parts gets split, and the rare parts must be branched. Example: lambda = OR over i <= t of a_i, where a_i is a cycle CNF on L fresh variables, q = 1/2, and t ~ 1/D(a_i), so D(lambda) ~ 0.64 >= 1/K with K = 4. Exact ideal trees for L = 12, 14, 16, 18 give |C| = 170, 286, 511, 856 and m_K = 209, 590, 1651, 4366. The ratio m_K/|C| = 1.23, 2.06, 3.23, 5.10 keeps growing, so m_K is not O(s) (exp5_or.py).

**Proposed fix.** Restrict the example to monotone F, or require each lambda_i to be K-dense in the polarity in which it occurs. Also require each lambda_i to satisfy the hypothesis of (a) itself, i.e. be force-free and non-decomposable, or have K-dense component-tree leaves. Alternatively, test (S) before splitting at (D)-OR nodes; then re-check the exactness claim for read-once formulas under that order.

### 2. [major] sec-part1.tex, cor:dfsb(b): "then m_K(C)=O(1) and the cost is O(K eps^-2 log(1/delta))"

**Problem.** This is false whenever C|_F is decomposable, because (D) precedes (S). Counterexample: C = [x_A = 1^20] AND (AND over i <= t of B_i), where B_i is an OR of r = ceil(log2 t)+1 disjoint maj3 gates. D(C|F) ~ 0.60 >= 1/K with K = 4. The exact ideal tree T*_4 has m_K = 41, 97, 225, 513 for t = 8, 16, 32, 64, with 32 to 448 MC leaves and d = t (exp4b.py). Phase-2 cost grows like l*K*d^2/eps^2, roughly t^3 log t, not O(K eps^-2 log(1/delta)).

**Proposed fix.** State m_K(C) = 1 + m_K(C|_F), with the cost given by thm:dfsb applied to that tree. The O(1) claim holds only if C|_F is not decomposable, or if (S) is tested on the (F)-child before (D).

### 3. [major] sec-part1.tex, cor:dfsb(c): "with K=1 DFSB is exact cutset conditioning: no sampling at all"; proof: "two distinct tree nodes cannot carry the same NNF node and the same partial assignment"

**Problem.** (i) DFSB with K=1 still samples. It runs a pilot of N_0 = 64*ceil(ln(2m/delta)) samples at every non-decomposable node, and the completeness analysis allows it to accept any node of density >= 1/16 as an MC leaf. Repo run: an AND of 8 multiplexers (x_i ? y_i : z_i), so Conf = {x_1..x_8} and r = 8, gives 8 MC leaves and the interval [0.00384, 0.00409] around p = 2^-8. It is not exact (exp3b_mux.py).
(ii) Even the ideal tree T*_1 accepts non-syntactic tautologies (D(h) = 1) as (S)-leaves, e.g. (x AND y) OR NOT x OR NOT y. Three of 300 random small-Conf formulas had such leaves.
(iii) The injectivity sentence is false as written: an (F) wrapper and its child carry the same NNF gate and the same Conf-assignment, and so can several virtual child-group nodes. The O(s 3^r) bound itself holds; numerically nodes <= s*3^r in all 300 trials.

**Proposed fix.** Say: 'with (S) and (E) disabled (never accept), DFSB is exact cutset conditioning with O(s 3^r) nodes; pilots then cost nothing'. Replace the injectivity claim with: 'each pair (gate g, Conf-assignment) is carried by at most O(fan-in(g)+1) tree nodes (g, its (F)-child, and child groups of g)', which still gives O(s 3^r) since s counts wires.

### 4. [major] sec-part1.tex, (R8) "replaced, before anything else, by its exact reduced OBDD ... This makes every class above closed under local rewriting"; interaction with cor:dfsb(a) "read-once formulas (exactly)" and Conf in (c)

**Problem.** (R8) turns each small-support gate into an OBDD-NNF of the form (x AND f1) OR (NOT x AND f0). The two OR children share x, so (D) no longer applies at these gates and Conf(C) grows.
Repo run: the read-once formula AND over i <= 30 of (x_i OR y_i), with (R8) as implemented in nnf.to_nnf, gives a tree of 30 MC leaves and the interval [1.64e-4, 1.95e-4] around p = 1.786e-4, at both K=1 and K=4. It is not exact (exp3_readonce.py).
The closure claim is also unproved, and it fails for local rewrites at large-support gates. Absorption C' = AND(B_1..B_t, OR(AND_i B_i, y)) equals C = AND_i B_i and adds O(1) gates. But it puts every variable in Conf and makes the root non-decomposable, so without (E) the ideal tree must branch through the B_i, giving an exponential m_K.

**Proposed fix.** Treat an (R8)-canonicalised gate as an exact leaf (T'): its probability is read off the OBDD in linear time, and its internal nodes are hidden from (D), (B) and Conf. Restrict the closure claim to rewrites confined to cones of support <= c log|C|, and state it for the procedure with (T').

### 5. [major] sec-part1.tex, sec:part1-limits: "under the exponential-time hypothesis ... so no general procedure beats sampling by more than a factor 2^{o(log(1/p))} on the satisfiable ones"

**Problem.** The conclusion does not follow from ETH, and in its natural reading it is false. ETH gives only a 2^{cn} lower bound for some unspecified c > 0. Exact #3-SAT by branching on an unsatisfied clause (T(n) = T(n-1)+T(n-2)+T(n-3)) runs in O*(1.8393^n). On 3-CNFs with a unique solution (p = 2^-n), where sampling costs about 2^n/eps^2, this is a speed-up of 2^{0.12 log(1/p)}. That is not 2^{o(log 1/p)}. Also, the procedures are randomized, so randomized ETH is needed. The parallel conclusion in sec:limits for PRGs is correct only because there T(k) = 2^{(1-o(1))k}.

**Proposed fix.** Replace with: 'under randomized ETH, no sound procedure complete on all 3-CNFs runs in time 2^{o(log(1/p))}*poly(|C|) on satisfiable instances. Otherwise, with a time-out, it would decide 3-SAT in 2^{o(n)}. So the cost must be (1/p)^{Omega(1)} on some instances.' Drop the 'beats sampling by at most 2^{o(log 1/p)}' phrasing.

### 6. [minor] sec-part1.tex, sec:part1-limits, distributed surprise: "p <= (7/8)^m", "1/3 < alpha < alpha_sat", "except where exact Las Vegas samplers exist (thm:cftp, for unate circuits)"

**Problem.** (i) p <= (7/8)^m is not a per-instance fact; only E[p] = (7/8)^m holds. With n = 20, alpha in {1, 2, 3} and 100 random instances each, 42-48% of instances have p > (7/8)^m, with a maximum ratio of 4.2 (exp7_3cnf.py).
(ii) For k = 3, a constant threshold alpha_sat is not known to exist; Friedgut's sharp threshold is non-uniform.
(iii) Exact Las Vegas samplers are not limited to unate circuits: partial rejection sampling (Guo-Jerrum-Liu) is exact for general CNFs, though fast only in restricted regimes. 'No polynomial-time test certifies' is an assertion, not a result.

**Proposed fix.** Write: by Markov, with probability >= 1-1/n, p <= n(7/8)^m, so K >= (8/7)^{m-n/3}/n w.h.p. Replace alpha_sat with 'alpha below the (non-uniform) satisfiability threshold', or a proven range. Soften the certification sentence and mention partial rejection sampling.

### 7. [minor] sec-part1.tex, sec:part1-limits, pseudorandom rarity: "Preimages [G(x)=y] of hash functions or PRGs ... nothing beats sampling by more than a subexponential factor unless the primitive is broken"

**Problem.** prop:worstcase(b) covers only length-doubling PRGs. It gives 'at most subexponential speed-up' only when the security is T(k) = 2^{(1-o(1))k} against advantage-1/2 distinguishers. A PRG with 2^{k/2} security is not 'broken', yet it leaves room for a 2^{k/2} speed-up. Hash-function preimages (compressing H) are not covered by (b) at all.

**Proposed fix.** Say 'unless G has less than 2^{(1-o(1))k} security', and either drop hash functions or prove the analogous statement for them.

### 8. [minor] sec-part1.tex, thm:dfsb: "the non-sampling work is O(m*|C|)" and "each costing O(|C|)"

**Problem.** This omits several costs. Root failed-literal probing is O(n|C|) per round (dfsb/cnf code runs 3 rounds). Gaussian elimination is O(n^3). (R8) tabulation needs |C|^c evaluations for each small-support gate, up to |C|^{c+2} work in total. Envelope construction for (E), with Shannon expansions per (R4), costs up to 2^r|C| per node. Each (E) pilot or Phase-2 sample costs O(|C|+|Phi|), not O(|C|).

**Proposed fix.** List these terms, e.g. O(m|C| + n^2|C| + n^3 + |C|^{c+2} + m*|Phi_max|), and charge envelope samples O(|C|+|Phi|).

### 9. [minor] sec-part1.tex, thm:dfsb statement and "The class on which DFSB beats sampling is therefore {C: m_K(C) <= poly(|C|) for some K <= poly(|C|)}"

**Problem.** (i) K and m are inputs of the procedure. Completeness on this class needs a search over (K, m), and caps on Phase-2 samples for loose or wrongly accepted leaves; otherwise the procedure is not 'efficient' on all inputs in the sense of Def. def:sound. (ii) 'Therefore' overstates: the condition is sufficient only, since (E) leaves enlarge the class. (iii) With (R7) boxes, the (E) pilot measures E_{Q-hat}[W], which is distorted by rho in [rho_min, rho_max], so 'looseness at most 16K' holds only up to that factor.

**Proposed fix.** Add a doubling search: K = m = 2^j with delta_j = delta/(2j^2), stop at the first tight output and intersect the intervals; add explicit per-leaf sample caps. State the two-sided characterisation |T*_{16K}| <= |tree| <= |T*_K| (without (E)). Include the rho distortion in the (E) acceptance analysis.

### 10. [minor] sec-part1.tex, rule (F) and (R2); thm:envelope / rule (E) when Z = 0

**Problem.** Edge cases are undefined. If unit propagation reaches a conflict, F contains complementary literals: D(F) read as a product of marginals is positive, and (R2)'s product [x][NOT x] is not decomposable. An envelope with mass Z = 0, possible when some q_i is 0 or 1, has no Q_phi. The implementation crashes on this case: dfsb._pilot_env -> envelope.py:242 'assert m[self.root] > 0', reproduced on a 3-variable circuit with q = (0, 0.306, 1) and p = 0 (exp9b.py).

**Proposed fix.** Add: 'if propagation refutes h, D(h) = 0 (phi = 0)'; and 'if Z_Phi = 0 then D(h) = 0 exactly (phi >= 1_h), so h is an exact zero leaf'. In code, return a const-0 leaf when the envelope mass is 0.

### 11. [minor] sec-part1.tex, prop:dnnf-env

**Problem.** (i) If (R6) is active ('used whenever the rules give mass > 1'), sub-envelopes can be replaced by 1, so K <= E[phi | C=1], not equality. (ii) A DNF's NNF is a DNNF only if no term contains x and NOT x or a repeated literal. (iii) The FPRAS route via thm:sis needs rational marginals, with time polynomial in their bit size; the proposition states no such restriction. (iv) (R7) boxes are not DNNF leaves, so '(R1)-(R8) turn into a DNNF envelope' should exclude (R7).

**Proposed fix.** State K <= E_D[phi | C=1], with equality when only (R1)-(R3) are used. Require consistent, duplicate-free terms. Add 'product D with rational marginals'. Write '(R1)-(R6), (R8)'.

### 12. [minor] sec-part1.tex, sec:modules: "Algebraic. Affine and degree-2 constraints over F_2 ... exact counting ... by Gaussian elimination and Dickson's normal form"

**Problem.** Systems of several quadratic equations over F_2 are NP-hard even to decide (MQ). Exact counting is polynomial only for an affine system plus O(log n) quadratic constraints: substitute the affine part, then use #{f_1 = ... = f_c = 0} = 2^-c * sum over S of sum over x of (-1)^{sum_{i in S} f_i}, with each sum evaluated via Dickson.

**Proposed fix.** Say 'affine constraints together with O(log n) degree-2 constraints'.

### 13. [minor] sec-part1.tex, sec:modules, bounded-treewidth and local-lemma bullets

**Problem.** (i) 'Along a greedy elimination order' gives no width guarantee, so completeness on bounded-treewidth circuits needs the Bodlaender et al. decomposition that the text cites but does not use. (ii) d <= 2^{ck} is the LLL condition for the uniform distribution; for a biased product D it must be stated via clause-violation probabilities. (iii) I could not verify the 2^{k/4.82} constant attributed to wangyin2024 (no web access in this run).

**Proposed fix.** Use the 5-approximate decomposition, or the better of it and greedy. State the LLL condition for product D. Double-check the cited constant.

### 14. [minor] sec-part1.tex, thm:meta

**Problem.** (i) 'Runs in polynomial time' needs fixed polynomial bounds on DFSB's K and m, and per-module caps. (ii) The output when the intersection is empty (the bad event) is undefined. (iii) DFSB's tightness probability is 1-2delta/M, not 1-delta/M. (iv) Membership in some 'classes above' depends on eps (e.g. Delta <= eps/64 in thm:janson-general). (v) The 'exact' modules must use log-space or exact arithmetic: in doubles, p < 2^-1074 underflows to [0,0], and an intersection with it gives a false verdict p = 0.

**Proposed fix.** Fix the polynomials and caps; output [0,1] on an empty intersection; adjust the confidence accounting; state class membership for a given eps; require overflow-safe arithmetic in exact modules.

### 15. [minor] sec-setting.tex NNF definition (used by all DFSB rules); cor:dfsb(a) "read-once formulas"

**Problem.** (i) 'At most two copies of every gate' fails for large-weight threshold gates; the code makes them opaque nodes (nnf.py), and DFSB's description never says how (F), (D) and (B) treat opaque nodes. (ii) Flattening can create repeated children, e.g. AND(A, AND(A, B)). The code deduplicates them; the paper does not, and without deduplication sv(A) enters Conf and (D) fails. (iii) Read-once formulas containing XOR (allowed by the setting) are not handled exactly: x XOR y becomes the non-decomposable (x AND NOT y) OR (NOT x AND y).

**Proposed fix.** Define opaque nodes and their treatment; add 'deduplicate children after flattening'; write 'read-once {AND, OR, NOT}-formulas'.

