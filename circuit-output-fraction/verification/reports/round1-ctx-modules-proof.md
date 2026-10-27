# Referee report: ctx-modules (proof lens)

**Verdict.** contains false statements. The construction and proof of Theorem thm:cw and the proof of Lemma lem:quotient are correct. The problem is the definition of context width: it says nested gates are flattened, and under that definition the Example's claim cw=O(w) is false, the NNF is not of size at most 2|C|, and the parameter no longer generalises dtrees. The implementation and experiments use the unflattened NNF. There are also some smaller missing hypotheses, and one empirical claim nothing supports. All of these are fixable in place.

**What was checked.** Re-derived every step of thm:cw.
- F1 holds: Up(h) contains Up(g), so kappa(g) ∩ sv(h) is contained in kappa(h).
- F2 holds, because S_g is contained in sv(g) and g is in Up(g).
- M-nodes are deterministic Shannon expansions, and pi ∪ tau covers kappa(h) by F1.
- Correctness follows by induction from g|σ = op_j h_j|σ.
- Decomposability holds. M[h,pi] mentions only sv(h) \ dom(pi), and N[h,σ] mentions only sv(h) \ kappa(h), so the children of an ∧ are on the sets sv(h_j) \ kappa(g), which F2 makes pairwise disjoint.
- Size: each wire adds at most 2^|kappa(h)| ∧-terms of at most cw+1 wires each.
- cw=0 iff DNNF, since S_g is contained in kappa(g).
- The d-DNNF claim holds: conditioning preserves disjointness.
- The FPRAS corollary follows: smoothing and comparators give #E' = (∏ b_i) D(E), then the #DNNF FPRAS applies.

Brute-force tests of code/rareprob/ctxwidth.py (scripts t1.py, t2.py and t7.py in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/):
- The code's kappa matches an independent implementation of the definition (reachability-based Up sets) on 600 random NNFs.
- cw=0 holds exactly when the NNF is decomposable.
- The compiled DNNF agrees with C on all inputs (phi>0 iff C=1) for 2,200 random circuits, including AND/OR/XOR/NOT/THR gates, both flatten modes and small-cone tabulation.
- The bottom-up mass equals brute-force E_D[phi] under random product distributions.
- Output wires are at most |N|(cw+1)2^cw (maximum ratio 1.0).
- In 530 random NNFs whose ORs are all decision nodes, phi takes only the values 0 and 1, confirming the d-DNNF claim.
- The project's own ctxwidth tests pass (9 tests).

Flattening (t2.py, t8.py, t6.py):
- A window CNF has cw = n−2 when flattened or written as a flat ∧, but cw = 3 as a left-deep chain in window order. A shuffled chain gives 27 (n=30) and 47 (n=60).
- Flattening grows the NNF from 237 to 3,318 wires on an OR of chain prefixes, i.e. quadratically.
- XOR of 6 inputs goes from 6 wires to 54 NNF wires.

Example (t3.py): the inclusion–exclusion reduction from vertex covers to ORs of matching (read-once) CNFs gives exact counts on 30 random graphs of maximum degree 3.

Lemma lem:quotient (t3.py, t5.py):
- Verified algebraically: multilinearity, A ≥ B in the monotone case, F(cq_j) in [F, cF] for c ≥ 1 and in [cF, F] for c ≤ 1, then the coordinate-by-coordinate (hybrid) argument.
- Numerically, the maximum of |log ratio| / Σξ is 1.0000 over 4,000 two-sided and 4,000 monotone (clipped) instances.
- Without q̂ in [0,1] the one-sided claim fails: an explicit counterexample is in finding 8.

Modules (t4.py): across 300 random circuits (792 modules), the module supports are laminar and C = Q_g(g, x_rest) holds as a function, with no violations. I also confirmed that the O(|C|n) dominator argument is correct.

Citations:
- I could not check the venue and pages of meel2026dnnf or dutuitrauzy1996 online, because this run's web-search budget was used up. To my knowledge, Meel–de Colnet's '#CFG and #DNNF admit FPRAS' (arXiv 2406.18224) is real, and DR96 is a linear-time DFS visit-date algorithm, not a dominator algorithm.
- darwiche2001dnnf (JACM 48(4)) is correct.

Outside my assignment: in experiments/results/speedup.json the 'threshold' row with 800 blocks has contains=False. The true p is 7.79e-27, outside the reported interval [6.89e-27, 7.55e-27]. Whoever referees tilting / prop:tilting should check it, either as a coverage failure or as a precision problem in the exact poisson_binomial_tail.

I did not edit any repository file.

## Findings

### 1. [critical] sec-part1.tex, Definition [context width] ('Work in the NNF of C (size ≤2|C|, nested gates flattened)') together with Example [∨'s are easy, ∧'s are hard] ('Then cw=O(w)') and the claim that cw 'generalises Darwiche's dtree conditioning'

**Problem.** Flattening merges a CNF's ∧-tree into a single ∧-gate. Its overlap S_g is then every variable that occurs in two clauses, so kappa(top) is almost all variables. For window CNFs the flattened definition gives cw = n−2, not O(w).

Measured with the project code:
- or_of_chain_cnfs(n,4,3) has cw 11/31/51 for n = 20/40/60 when flattened, against 3 unflattened.
- A single window CNF with n = 30/60 has cw 28/58 when flattened or written as a flat ∧. A left-deep chain in window order gives 3; a shuffled chain gives 27/47.

So the Example is false under the paper's own definition. The definition also contradicts:
- the implementation (exp_ctx.py, meta.py and the tests all call to_nnf(C, flatten=False), and the families.py docstring says the left-deep chain 'is what makes the context width small');
- sec-experiments, which says 'built as left-deep ∧-chains';
- the dtree analogy, since a flattened CNF has no dtree.

More generally, cw is not an invariant of the function. It depends on how the ∧'s are bracketed.

**Proposed fix.** Delete 'nested gates flattened'.

Define cw(N) for a given NNF N in which each ∧-gate is bracketed as given; a binary ∧-tree over a gate's children is a dtree. Optionally define cw(C) as the minimum over bracketings and note that any bracketing the algorithm chooses gives an upper bound.

Restate the Example: 'if each F_i is written as a left-deep ∧-chain of its clauses in window order, then kappa(chain prefix) has w−1 variables and kappa(clause) has w, so cw = w'.

For the intro's 'ORs of bounded-pathwidth CNFs', say that the bracketing comes from a path decomposition. That is computable in linear time for constant width (Bodlaender–Kloks), or it must be given.

### 2. [major] sec-part1.tex, Definition [context width] 'size ≤2|C|' and Theorem thm:cw 'Every circuit C is equivalent to a DNNF of size O(|C| cw 2^cw)'

**Problem.** An NNF of size at most 2|C| exists only for {∧,∨,¬}-circuits without flattening. The paper's gate basis (sec-setting) also has ⊕ and weighted thresholds.
- ⊕: a 6-input XOR has 6 wires but 54 NNF wires (measured).
- Weighted thresholds: no linear-size NNF is given. The code turns large-weight THR gates into opaque nodes, and compile_ctx then returns None.
- Flattening: it can square the size. An OR of the prefixes of an ∧-chain goes from 237 to 3,318 wires.

So a size bound in |C| 'for every circuit' does not follow.

**Proposed fix.** State the theorem for an NNF N of C: 'C is equivalent to a DNNF of size O(|N|(cw(N)+1)2^{cw(N)})'.

Add that |N| = O(|C|) for {∧,∨,¬,⊕}-circuits, where a fan-in-k ⊕ costs O(k) gates per polarity. A threshold gate with nonnegative integer weights of total W costs O(kW) by the sequential-counter DP. Other threshold gates must be frontier gates (see the frontier remark), or the class must be restricted.

### 3. [major] Paper text: sec-part1.tex, sec:modules-quotients, paragraph after Lemma lem:quotient: 'a threshold of 80 random modules with p≈10^{-15} is estimated to 0.1% in seconds'

**Problem.** Nothing in the repository supports this quantitative claim:
- code/rareprob has no module detection, module tree or quotient estimator (grep finds no module, quotient or dominator code in code/ or experiments/);
- no experiment script or results file reports it.

The closest experiment is the 'threshold' family in speedup.json. It uses exponential tilting, not modules, and reports interval ratios of about 1.08 (8%) at p≈2.5e-15 with 400 blocks, not 0.1%.

**Proposed fix.** Either remove the sentence, or add the experiment and its results file and name the method. If modules are tabulated exactly and the threshold DP is exact, the answer is exact, and the text should say so rather than '0.1%'.

### 4. [minor] sec-part1.tex, Lemma lem:quotient, the monotone/antitone clause

**Problem.** The one-sided monotone case silently assumes q̂ ∈ [0,1]^k. Without that, the A and B at intermediate points of the coordinate-by-coordinate argument can be negative, so A ≥ B fails.

Counterexample: Q = y1 ∧ (y2 ∨ y3), q = (0.870, 0.772, 0.830), q̂ = q·e^ξ = (2.46, 2.49, 3.34). Then F(q̂) = −6.11 while F(q) = 0.84.

In the two-sided case q̂ ∈ (0,1) follows automatically. With that hypothesis the proof is correct; I checked it algebraically and numerically.

**Proposed fix.** Add 'with q̂ ∈ [0,1]^k' to the lemma. Note that clipping an estimate to [0,1] keeps the one-sided condition true, because the true q_j lies between the clipped and unclipped values.

### 5. [minor] sec-part1.tex, paragraph after Lemma lem:quotient: 'gives a sound estimator whose relative error is the sum of the modules' errors'

**Problem.** Three things are missing.
- For coordinates where the quotient is neither monotone nor antitone (e.g. ⊕ of modules), the lemma needs relative accuracy on 1−q_j. A sound interval [L_j, U_j] for q_j gives 1−q_j only to relative error (U_j−L_j)/(1−U_j), which is useless when q_j ≈ 1.
- Confidence must be split across modules.
- When the quotient is estimated by DFSB or Monte Carlo under ⊗Bern(q̂), that interval is for F(q̂) and has to be moved to F(q) through the lemma.

**Proposed fix.** Spell out the composition rule.
- Given q_j ∈ [L_j, U_j], take any q̂_j in that interval and set ξ_j = max(log(U_j/L_j), log((1−L_j)/(1−U_j))). Monotone or antitone coordinates need only the relevant term. Then F(q) ∈ e^{±Σξ_j}·F(q̂).
- When the complement term is large, also estimate ¬g.
- Run each module and each quotient estimate at confidence δ/(number of estimates), and take a union bound.

### 6. [minor] sec-part1.tex, Theorem thm:cw size/time bound and proof sentence 'Each wire contributes O(cw 2^cw) nodes'

**Problem.** O(|C|·cw·2^cw) is zero when cw = 0. Each wire actually adds at most 2^|kappa(h)| nodes and O((cw+1)2^cw) wires. 'Computable in the same time' leaves out the O(|N|·n) bit operations needed to compute supports, overlaps and contexts, which dominates when n is much larger than cw·2^cw.

**Proposed fix.** Write: size O(|N|(cw+1)2^cw), computable in time O(|N|(n/wordsize + (cw+1)2^cw)). Numerically, output wires stay at most |N|(cw+1)2^cw on 600 random circuits.

### 7. [minor] sec-part1.tex, Theorem thm:cw 'If moreover every ∨-gate has semantically disjoint children, the result is a d-DNNF'

**Problem.** It is unclear whose ∨-gates are meant. The hypothesis has to hold for every ∨-gate of the NNF in the root's cone. That includes ∨'s created by De Morgan from ∧'s under a negation, and those from ⊕ or threshold expansions. Example: C = ¬(a ∧ b) has no ∨-gate, but its NNF ¬a ∨ ¬b is not deterministic. The proof itself is correct; I tested it on 530 NNFs with deterministic ∨'s, and phi only takes the values 0 and 1.

**Proposed fix.** Write 'if every ∨-gate of the NNF N is deterministic (h_i ∧ h_j ≡ 0)'. Optionally add the consequence: p is then computable exactly in time O(|N|(cw+1)2^cw) under any product distribution.

### 8. [minor] sec-part1.tex, Example: 'so an FPRAS exists' and 'counting vertex covers in graphs of degree ≥3 is #P-complete'

**Problem.** Two problems with the wording.
- The FPRAS time is poly(|C|·2^w), so it is polynomial only when w = O(log n).
- 'Degree ≥3' literally means minimum degree, which does not give a bounded Δ, and the claim has no citation.

The inclusion–exclusion reduction itself is correct. It is a Turing reduction with 2^{Δ+1}−1 oracle calls, and I verified it numerically on 30 random graphs of maximum degree 3. Any proper edge colouring with O(Δ) colours works (Vizing/Misra–Gries gives Δ+1).

**Proposed fix.** Write: 'Then cw = w (for the chain bracketing), so an FPRAS exists when w = O(log n)'. Write also: 'counting vertex covers (equivalently independent sets) is #P-complete already in graphs of maximum degree 3 [Greenhill 2000, Comput. Complexity 9:52–72]'.

### 9. [minor] sec-part1.tex, sec:ctxwidth, frontier remark: 'bounded treewidth by \cite{darwiche2009}'

**Problem.** darwiche2009 is a Bayesian-network textbook (CNF/jointree compilation). Compiling a circuit gate of bounded treewidth that way goes through a Tseitin CNF, and the gate variables then have to be projected out. Projection keeps the DNNF property but can destroy determinism, so the d-DNNF clause of thm:cw does not carry over to such frontiers. The size bound also has to include the frontier compilations, each multiplied by 2^|kappa(f)|.

**Proposed fix.** Cite Amarilli–Capelli–Monet–Senellart, 'Connecting knowledge compilation classes and width parameters' (Theory Comput. Syst. 2020), which gives d-SDNNFs of size 2^{O(k)}|C| for treewidth-k circuits.

Add: the size becomes Σ_f 2^{|kappa(f)|}·|DNNF(f)| plus the bound for the remaining gates. The result is a d-DNNF only if the frontier compilations are deterministic.

### 10. [minor] sec-part1.tex, sec:modules-quotients: 'Modules form a laminar family and can be found in O(|C| n) time with dominators, as in fault-tree analysis \cite{dutuitrauzy1996}'

**Problem.** The statements are true: I checked laminarity and the factorisation C = Q_g(g, x_rest) by brute force on 792 modules in 300 random circuits, with no violations.

Two things should change.
- 'Laminar family' should say of what: the supports, and hence the cones.
- To my knowledge, Dutuit–Rauzy give a linear-time algorithm based on DFS visit dates, not dominators, so the citation does not back the stated method, and the O(|C|n) bound is weaker than the cited result.

**Proposed fix.** Add the one-line proof: if v ∈ sv(g) ∩ sv(h), every path from x_v to the output passes through both g and h, so one is in the other's cone and the supports are nested.

Then write either 'found in linear time [DR96]' or 'in O(|C|n) time: g is a module iff every input of sv(g) lies in g's subtree of the post-dominator tree of C (dominator tree of the reversed DAG rooted at the output)'.
