# Referee report: ctx-modules (counterexample lens)

**Verdict.** contains false statements. The core results are correct: the Theorem thm:cw construction, F1/F2, decomposability, the d-DNNF claim, cw=0 iff DNNF, Lemma lem:quotient and laminarity inside the output cone. Two statements are false as written, though: (1) because the definition says "nested gates flattened", the Example's cw=O(w) claim fails; (2) the NNF size bound fails under flattening. The module-walk paragraph also claims more than the lemma proves.

**What was checked.** I read sec-setting.tex, sec-envelopes.tex, sec-part1.tex (all of sec:ctxwidth and sec:modules-quotients), thm:sis in sec-part2.tex, the relevant bib entries, code/rareprob/ctxwidth.py, nnf.py, envelope.py, meta.py and families.py. I re-derived F1 and F2, the induction behind M[h,pi] = h|_pi and N[g,sigma] = g|_sigma, the support invariants (supp N[h,.] is contained in sv(h)\kappa(h); supp M[h,pi] in sv(h)\dom pi), decomposability, the per-wire count of (|kappa(h)\dom pi|+1)2^{|kappa(h)|}, determinism, and the multilinear and monotone steps of the lemma. Experiments, all in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad:
- t_cw.py: 400 random AND/OR/XOR/NOT circuits with n=1..8, including constants, fan-in-1 gates, repeated children, and marginals q_i in {0,1} or random. Each was compiled with flatten on and off and small_cone 0 and 3, then checked against brute force. Results: phi>0 equals C on every input, the mass equals the brute-force E_D[phi], and the cw=0 iff DNNF test passed in all cases. Where all NNF ORs were semantically disjoint (1350 cases), phi stayed in {0,1}. Edges never exceeded 1.03*(|NNF|+1)(cw+1)2^cw.
- t_big.py: 300 circuits with n=10..19 and cw<=10, sampled inputs: 0 mismatches. XOR/NOT circuits: always a d-DNNF.
- t_flat.py: context width with and without flattening (finding 1, the critical one).
- t_blow.py: quadratic NNF blow-up from flattening (finding 2).
- t_ie.py: the inclusion-exclusion vertex-cover reduction on the Petersen graph with a 4-edge-colouring (#VC = 76 both ways; each colour class is read-once).
- t_quot.py: 3000 random quotients, including thresholds with one-sided perturbations and q in {0,1}. No violation of e^{+-sum xi}; the bound is attained with ratio 1.0.
- t_mod.py: brute-force modules on 300 random circuits. The quotient identity C = Q_g(g, x_rest) held for all 1243 in-cone modules, and laminarity held inside the cone.
The existing pytest ctxwidth tests pass (9/9). Not verified: the Meel-de Colnet venue (SODA 2026, pp. 5978-6010). The web-search budget for this turn was used up, so I could only rely on memory, which recalls the arXiv paper '#CFG and #DNNF admit FPRAS' by Meel and de Colnet. No repository file was modified.

## Findings

### 1. [critical] sec-part1.tex, Definition (context width): 'Work in the NNF of C (size <=2|C|, nested gates flattened)'; Example: 'Then cw=O(w), so an FPRAS exists'; same claim in sec-intro.tex lines 72-77

**Problem.** Under the stated definition, flattening merges each window-CNF's AND-tree into a single AND gate. That gate's overlap S_g is every variable occurring in two clauses, so cw = Theta(n/t), not O(w). The Example's claim, and the FPRAS conclusion drawn from it, are false as written. Measured with to_nnf(flatten=True, small_cone=0) on or_of_chain_cnfs(n,3,3): cw = 10, 18, 28, 38 for n = 12, 20, 30, 40. With flatten=False it is 3 each time. A single left-deep window CNF with n=40 also gives cw 38 flattened against 3 unflattened. The code knows this: meta.py, exp_ctx.py and test_ctxwidth_or_of_chains all call to_nnf(flatten=False). The nnf.py docstring says flattening is 'off when the AND-tree shape matters', and families.or_of_chain_cnfs says the left-deep chain 'is what makes the context width small'. So the paper's definition contradicts both the implementation and the experiments, and sec-experiments.tex mentions 'left-deep AND-chains' without the definition allowing them to survive.

**Proposed fix.** Define cw on the unflattened NNF and never merge AND-gates. Merging OR-gates is harmless for cw, since OR-gates contribute no overlap and do not change Up sets; restrict it to fan-out-1 gates to avoid blow-up. In the Example, say that each F_i is bracketed as a left-deep chain of binary ANDs in window order. Then S(acc_k) is the (w-1)-variable overlap of window k with earlier windows, kappa(acc_k) is contained in the window, kappa(c_k) is contained in vars(c_k), and so cw <= w.

### 2. [major] sec-part1.tex, Definition (context width) '(size <=2|C|, nested gates flattened)' and Theorem thm:cw 'equivalent to a DNNF of size O(|C| cw 2^cw), computable in the same time'

**Problem.** (a) Flattening shared gates blows the NNF up quadratically. Example: g_1 = x1 AND x2, g_i = g_{i-1} AND x_{i+1}, output = OR of all g_i. Measured NNF wires: 150 to 1375, 300 to 5250, 600 to 20500, 1200 to 81000 for k = 50..400 flattened, against 150..1200 unflattened. (b) sec-setting allows XOR gates and threshold gates with arbitrary weights. The NNF of XOR is O(|C|) but not <= 2|C|. For arbitrary-weight thresholds no NNF expansion is specified: the code makes them opaque 'X' nodes, and compile_ctx returns None. So 'Every circuit C' is neither proved nor implemented. (c) For cw=0 the bound O(|C| cw 2^cw) evaluates to 0. (d) 'Same time' omits the O(|N| n / wordsize) cost of computing supports and contexts.

**Proposed fix.** State thm:cw for circuits over AND, OR, NOT and XOR, plus thresholds handled either by a fixed NNF expansion (e.g. the sequential-counter DP for small integer weights, size O(k*W)) or as frontier gates. Give the bound as O(|N|(cw+1)2^cw), where |N| is the size of the unflattened NNF: at most 2|C| for AND/OR/NOT circuits and O(|C|) with XOR. Running time O(|N|(n + (cw+1)2^cw)). Measured edges never exceeded 1.03*(|N|+1)(cw+1)2^cw.

### 3. [major] sec-part1.tex, sec:ctxwidth intro 'generalises Darwiche's dtree conditioning ... to arbitrary circuits'; sec-intro.tex 'e.g. for ORs of bounded-pathwidth CNFs'; README 'covers, e.g., ORs of bounded-pathwidth CNFs'

**Problem.** cw is a syntactic parameter of the given AND-bracketing and is not invariant under re-association. For the same window CNF (n=40, w=3) cw is 3 as a left-deep chain in window order, 6 balanced, 31 under a random bracketing, and 38 as the standard flat AND of clauses. Darwiche's bound applies to a chosen dtree, normally built from a decomposition. Theorem thm:cw only uses the bracketing it is handed. A bounded-pathwidth CNF given in the usual flat form therefore has huge cw, and the class claim needs a re-bracketing step that is neither in the theorem nor in the code.

**Proposed fix.** Either restrict the claims to CNFs given in path-dtree form, or add a lemma. Lemma: order the clauses by a bag that contains each clause's variables, in a path decomposition of width k, and bracket them as a left-deep chain; then cw <= k+1, since S(acc_k) and kappa(acc_k) lie inside the separator between consecutive bags. Note that such a decomposition is found in linear time for fixed k (Bodlaender-Kloks), while for pathwidth Theta(log n) only approximations exist, giving quasi-polynomial bounds. Optionally define cw* as the minimum over re-associations.

### 4. [major] sec-part1.tex, paragraph after Lemma lem:quotient: 'estimating each module's probability with any sound method ... gives a sound estimator whose relative error is the sum of the modules' errors'

**Problem.** The lemma needs relative accuracy on both q_j and 1-q_j, unless Q is monotone or antitone in y_j. The listed methods (DFSB, Monte Carlo, envelopes, threshold DP) give relative accuracy on Pr[g=1] only. Propagating up the module tree also needs relative accuracy on 1-F, i.e. the lemma applied to NOT Q, which flips the one-sided conditions. Counterexample: C = y AND NOT g2 with g2 an OR of 40 variables, so q2 = 1-2^-40. Monte Carlo estimates q2 to tiny relative error trivially, but 1-q2 is uncontrolled. Numerically, a log-error of 1e-10 on q2 (q2 = 1-1e-10, q2hat = 1-1e-12) changes F = 1-q2 by a factor of 100. Soundness survives if xi_j is computed two-sidedly from the intervals, but the claimed relative error (completeness) does not follow.

**Proposed fix.** Require, for each module, relative accuracy on min(D(g), D(NOT g)), i.e. run the method on the rarer polarity of g, which the NNF has anyway. Then both sides hold within about a factor 2 of xi_j. Alternatively, require each quotient to be monotone or antitone in each module input and estimate the matching polarity; for thresholds and majorities with positive weights the one-sided condition suffices at every level. Say that the module estimates come from intervals valid jointly under a union bound.

### 5. [major] sec-part1.tex, sec:modules-quotients: 'a threshold of 80 random modules with p≈10^{-15} is estimated to 0.1% in seconds'

**Problem.** Nothing in the repository supports this numerical claim. code/rareprob contains no module, dominator or quotient code; grep for 'module|dominator|quotient' finds nothing. No experiment or results file matches it. The closest result, the tilting run in experiments/results/speedup.json (threshold of 400 blocks, p = 2.5e-15), has interval ratio 1.079, about 8%, not 0.1%. Under the paper's own error accounting, 0.1% over 80 sampled modules needs per-module log-accuracy of about 1.25e-5, roughly 10^10/q_j samples each. 'Seconds' is therefore possible only if the module probabilities are computed exactly, e.g. by tabulation, which the text does not say.

**Proposed fix.** Either add an experiment (module detection, exact module probabilities by tabulation, the threshold DP on the quotient) with a table and script, and state that the modules are evaluated exactly, or delete the sentence.

### 6. [minor] sec-part1.tex, Example: 'counting vertex covers in graphs of degree >=3 is #P-complete'

**Problem.** The wording is wrong and the claim is uncited. The reduction needs bounded maximum degree so that t = Delta+1 = O(1), and the known result is #P-completeness for maximum degree 3 (Greenhill 2000; also Vadhan 2001), not 'degree >= 3'. The (Delta+1)-edge-colouring step also needs a polynomial-time algorithm (Vizing via Misra-Gries). The hard instances (ORs of matching CNFs) have cw=0. They belong to the low-cw class but are not literally sliding-window CNFs. I checked the identity on the Petersen graph with a 4-edge-colouring: #VC = 76 directly and by inclusion-exclusion, and each colour class is read-once.

**Proposed fix.** Write 'graphs of maximum degree 3 [Greenhill 2000]'. State the identity #AND_c phi_c = sum over nonempty S of (-1)^{|S|+1} #OR_{c in S} phi_c, which uses 2^{Delta+1}-1 oracle calls. Cite Misra-Gries for the colouring. Say that hardness holds already in the cw=0 subclass.

### 7. [minor] sec-part1.tex, Definition of S_g ('a != b children of g') and claim 'cw(C)=0 iff the NNF of C is already a DNNF'

**Problem.** Circuits may have repeated children; the circuit model allows AND(h,h), and the repo's random tests generate them. If children form a multiset and 'a != b' means distinct nodes, S_g misses the self-overlap and the construction emits PROD(M[h,pi], M[h,pi]), which is not decomposable. The iff then depends on an unstated convention. The code avoids this by de-duplicating children in NNF.AND/OR via set(out).

**Proposed fix.** State that NNF gates have de-duplicated child sets (h AND h = h, h OR h = h), or define S_g over pairs of distinct child positions.

### 8. [minor] sec-part1.tex, sec:modules-quotients: 'Modules form a laminar family and can be found in O(|C| n) time with dominators, as in fault-tree analysis [dutuitrauzy1996]'

**Problem.** (a) A gate outside the output's cone whose support variables do not reach the output is vacuously a module, and such gates can overlap non-laminarly. Brute force found non-laminar pairs in 20 of 300 random circuits, all among gates outside the cone; inside the cone laminarity always held, consistent with the DAG-ordering argument. (b) Dutuit-Rauzy's algorithm is linear-time and based on DFS visit dates, not dominators. The citation supports a better bound than O(|C| n) by a different method.

**Proposed fix.** Restrict modules to gates in the cone of the output. Write: 'g is a module iff it is an ancestor of every x in sv(g) in the post-dominator tree of the output, so all modules are found in near-linear time; Dutuit-Rauzy give a linear-time DFS algorithm.'

### 9. [minor] sec-part1.tex, Theorem thm:cw FPRAS sentence ('rational marginals ... max_i log b_i') and the d-DNNF hypothesis; sec-part2.tex thm:sis(a) on which it relies

**Problem.** b_i is never defined in thm:cw. thm:sis(a)'s 'comparator on ceil(log2 b_i) fresh bits' gives #E' = (prod b_i) D(E) only if the negative literal becomes the range test [a_i <= u_i < b_i]; the test [u_i >= a_i] gives 2^{ceil(log b_i)} - a_i preimages. The identity also needs smoothing with respect to all n variables, otherwise the product runs only over vars(E). The d-DNNF hypothesis 'every OR-gate has semantically disjoint children' must refer to the OR-gates of the NNF in the root's cone, which include De Morgan duals of negated AND-gates. That is much more restrictive than the wording suggests. With these readings the corollary is correct.

**Proposed fix.** Write q_i = a_i/b_i. Specify the literal replacements as x_i -> [u_i < a_i] and NOT x_i -> [a_i <= u_i < b_i], each an O(log b_i)-size OBDD. Smooth over all n variables. Say 'every OR-gate of the NNF (in the root's cone)'.
