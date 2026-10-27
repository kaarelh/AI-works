# Final referee report: ctx-modules

**Verdict.** sound with minor fixes

**What was checked.** Files read in full: paper/p1-ctx.tex, sec-setting.tex, sec-envelopes.tex, thm:sis in p2-pcis.tex, the sec-intro and abstract statements about cw and modules, the bib entries, code/rareprob/nnf.py, ctxwidth.py, circuit.py, envelope.py (the parts the ctx route uses), meta.py:162-199 and code/tests/test_fix_ctx.py. The ctx tests pass (18/18).

Lens A: every step re-derived.
- thm:cw: F1, F2 and the correctness induction.
- Decomposability: supp N[h,.] ⊆ sv(h)\kappa(h); supp M[h,pi] ⊆ sv(h)\dom pi.
- Size: |N|2^cw wires from N-nodes plus (t+2)2^t <= (cw+2)2^cw per wire and for the root, total <= (|N|+1)(cw+3)2^cw.
- Time: O(n) bit operations per wire for supports, overlaps and contexts.
- cw=0 iff DNNF (S_g ⊆ kappa(g)).
- The d-DNNF claim, the FPRAS route through thm:sis(a) (smoothing and the [y<a], [a<=y<b] replacements give #E' = prod b_i D(E)), and the frontier size sum_f 2^{|kappa(f)|}|D_f|.
- XOR expansion: 12 wires per binary step, so <= 12(k-1).
- Negative threshold weights: w h = |w| not-h - |w|.
- cw is at most Darwiche's dtree width: the cluster of an internal dtree node equals kappa.
- lem:pathcw: the interval property, Helly for l(c), Up(a_j) ⊆ {a_j..a_m}, S_{a_j'} ⊆ sv(c_j'), and O(k|F|) edges.
- Example: greedy uses 2Δ-1 = 5 colours; colour classes are matchings, hence read-once with cw=0; the dual inclusion-exclusion identity holds.
- Modules: the quotient identity, laminarity, disjointness of maximal submodules, and "g_j is not above g".
- lem:quotient: the multilinear and monotone steps, and the algebra (r-1)(1-L-qhat) and (r-1)(1-U-qhat).
- The three composition rules and their xi formulas; the union bound at δ/M; "2xi <= rho" under rules 1-2, and 2xi <= (1+O(rho))rho when the interval straddles 1/2.

Citations: meel2026dnnf (SODA 2026, pp. 5978-6010) confirmed by web search. acms2020 confirmed (ToCS 2020, singly exponential d-SDNNF compilation of bounded-treewidth circuits). The rest from memory and consistent: Greenhill 2000 (max degree 3), Bodlaender 1996, Bodlaender-Kloks 1996, Dutuit-Rauzy 1996 (linear-time modules; their module notion matches the path definition up to variable-free gates), Darwiche 2001.

Lens B: scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/final_ctx/.
- t_compile.py: 9000 compilations of random circuits with AND/OR/NOT/XOR/THR (negative weights, fractional thresholds), CONST gates, repeated children, flatten on and off, small_cone 0/2/10. In every case phi>0 equals C on all inputs, the output is a DNNF, phi is integer-valued, cw=0 iff decomposable, phi<=1 whenever all ORs are deterministic, and the mass equals brute force E_D[phi] for marginals in {0, 1, 1e-9, ...}. Maximum ratio of wires to the bound: 0.33.
- t_cover.py: compile_ctx + envelope_estimate against exact p, with marginals in {0, 1, 1e-300, 1-1e-16, 1e-12}: 0 misses in 400 runs.
- t_window.py: chain cw = w and flat cw = n-2 for 2<=w<=n-2 (n<=9). The negative-polarity cone of an OR of window CNFs has cw = n (30 at n=30).
- t_path.py / t_path2.py: on 3000 adversarial path-bracketed CNFs and ORs of them (tautologies, duplicate clauses, unit clauses), the code's cw equals an independent reachability-based kappa. The gate-by-gate N never exceeds k+1; the hash-consed code NNF exceeds it in 3 cases.
- t_hashcons.py: explicit instance with code cw 4 > k+1 = 3.
- t_quot.py: the three rules on 20000 instances: no violation, worst |log ratio|/sum xi = 0.99993. U<=1/2 is needed.
- t_mod.py: 520 modules in 300 random circuits: laminarity holds and g = R_g(g_1..g_k, x').
- t_ie.py: the inclusion-exclusion identity holds on 60 random max-degree-3 graphs.
- Infinite and NaN thresholds crash to_nnf and meta_estimate.

p1-ctx.tex contains no experiment-dependent numbers; the "80 modules / 0.1%" sentence is gone. tab:ctx and the K≈1 / 1,024-sample statements live in sec-experiments.tex and were not judged. No repository file was edited.

## Audit of earlier findings

resolved: 17, superseded (text removed): 2

- [resolved] (critical) proof#1 flattening in cw definition falsifies Example cw=O(w): Definition now says 'nested gates are not merged' and the children of a gate form a set.
- Lines 8-9 and 30-39 state that cw depends on the bracketing (chain gives w, single AND gives n-2) and define cw*.
- The Example now brackets each F_i as a left-deep chain in window order and gets cw<=w from lem:pathcw.
- meta.py:162 uses to_nnf(flatten=False).
- Verified chain cw=w and flat cw=n-2 for 2<=w<=n-2 (t_window.py); test_window_cnf_cw_depends_on_bracketing passes.
- [resolved] (major) proof#2 NNF size <=2|C| / 'every circuit' / XOR / thresholds: thm:cw is now stated for an NNF N with bound (|N|+1)(cw+3)2^cw.
- Lines 24-30: |N|<=2|C| for {AND,OR,NOT}; <=12|C| with XOR (12(k-1) wires per gate, which I re-derived); O(kW) for integer-weight thresholds; other thresholds only as frontier gates.
- test_nnf_size and test_xor_chain_wires pass; over 9000 compilations the size ratio is at most 0.33 of the bound.
- [superseded (text removed)] (major) proof#3 unsupported '80 random modules, p~1e-15, 0.1% in seconds': The sentence is gone from p1-ctx.tex. grep finds no such claim anywhere in the paper.
- [resolved] (minor) proof#4 lem:quotient one-sided case needs qhat in [0,1]: The lemma now assumes q, qhat in [0,1]^k. The walk clips at 1 and explains why (lines 190-192). The rules keep qhat=sqrt(LU)<=U<=1.
- [resolved] (minor) proof#5 composition rule: complement accuracy, union bound, transfer through the lemma: Lines 177-195 give three explicit rules: q-side if U<=1/2 or monotone; (1-q)-side if L>=1/2 or antitone; otherwise the two-sided max formula.
- They also give the transferred interval [e^{-sum xi}L_F, min(1, e^{sum xi}U_F)] and confidence δ/M per estimate with a union bound.
- t_quot.py: 20000 instances, no violation.
- [resolved] (minor) proof#6 O(|C|cw2^cw) vanishes at cw=0; time omits n: The bound is now (|N|+1)(cw+3)2^cw and the time O(|N|(n+(cw+1)2^cw)). The proof counts (t+2)2^t wires per M-node and O(n) bit operations per wire.
- [resolved] (minor) proof#7 d-DNNF hypothesis: whose OR-gates: Now reads 'every OR-gate of N is deterministic', with a parenthetical: the XOR and threshold expansions produce deterministic ORs; ANDs of C under a negation need not. A residual ambiguity remains about whether N contains unreachable polarity copies (new finding 1).
- [resolved] (minor) proof#8 FPRAS only for w=O(log n); 'degree >=3' uncited: Now reads 'an FPRAS exists when w=O(log n)' and '#P-complete in graphs of maximum degree 3 [greenhill2000]'. The edge colouring is greedy with 5 = 2Δ-1 colours, which is correct.
- [resolved] (minor) proof#9 frontier citation darwiche2009, determinism lost under projection, size: Now cites acms2020 (d-SDNNFs of size 2^{O(k)} times the cone; confirmed by web search). The size is sum_f 2^{|kappa(f)|}|D_f| plus the thm:cw bound, and the result is a d-DNNF only if every D_f is.
- [resolved] (minor) proof#10 'laminar family' of what; DR96 is not a dominator algorithm: Now reads 'the supports of modules form a laminar family', with the one-line path proof. It says 'Modules are found in linear time [DR96]', which matches the cited linear-time algorithm; no dominator claim remains.
- [resolved] (critical) cex#1 flattening makes cw Theta(n/t) for ORs of window CNFs: Same fix as proof#1. Measured: OR of 3 chain-bracketed window CNFs at n=30 has code cw 3 (t_window.py).
- [resolved] (major) cex#2 NNF blow-up under flattening, XOR/THR, cw=0 bound, time: No merging in the definition; the bound is in |N|; XOR and integer thresholds are expanded with stated wire counts; other thresholds are frontier gates; the time includes O(|N|n).
- test_no_quadratic_blowup_on_shared_chains passes.
- The code falls back to an unmerged build within the bound.
- [resolved] (major) cex#3 cw not invariant under re-association; class claim needs re-bracketing: The text says cw is a parameter of the bracketing and defines cw*.
- New lem:pathcw: chain ordered by the first bag containing each clause, cw<=k+1, with Bodlaender/Bodlaender-Kloks for linear time; the intro and README say 'each bracketed along a path decomposition'.
- Proof checked. 0 violations on 3000 adversarial instances with the gate-by-gate N; the code's hash-consing caveat is new finding 2.
- [resolved] (major) cex#4 lemma needs relative accuracy on both q and 1-q; completeness claim: Soundness: the third rule computes xi two-sidedly from the interval.
- Completeness: each module estimates the polarity its parent's rule uses; the claims are restated as additive log-ratios under rules 1-2 and e^{O(dS)}S in general.
- Verified 2xi<=rho under rules 1-2 and the straddling-1/2 bound.
- Residual gap: how the 'rarer' polarity is identified (new finding 3).
- [superseded (text removed)] (major) cex#5 unsupported 80-module experiment claim: The sentence was deleted. No module code exists in rareprob, and the paper no longer claims any module experiment.
- [resolved] (minor) cex#6 Greenhill wording, colouring algorithm, cw=0 hardness: The text now states:
- maximum degree 3 [greenhill2000];
- greedy 5-edge-colouring into matchings;
- the identity #AND_c phi_c = sum_S (-1)^{|S|+1} #OR_{c in S} phi_c;
- 'Exact computation is #P-hard already for cw=0, for ORs of at most 5 read-once CNFs'.
t_ie.py confirms the identity on 60 random graphs.
- [resolved] (minor) cex#7 repeated children / S_g over distinct nodes: The definition says 'the children of a gate form a set (h AND h = h)'. The code de-duplicates (nnf.py AND/OR via set). Random tests with repeated children pass.
- [resolved] (minor) cex#8 modules outside output cone non-laminar; DR96 method: Modules are now defined only for gates in the cone of the output, and the DR96 claim is 'linear time'. t_mod.py: 520 modules in 300 circuits, laminarity and the module-tree factorisation hold.
- [resolved] (minor) cex#9 b_i undefined, comparator preimages, smoothing, d-DNNF OR-gates: thm:cw writes q_i=a_i/b_i. thm:sis(a) now smooths over all variables and replaces x_i by [y_i<a_i] and NOT x_i by [a_i<=y_i<b_i], so #E' = (prod b_i)D(E) holds. The d-DNNF hypothesis is explicit (see proof#7).

## New findings

### 1. [minor] paper/p1-ctx.tex lines 12-21 (Definition of context width: 'each AND- or OR-gate of C gives one gate per polarity'), together with thm:cw's d-DNNF hypothesis 'every OR-gate of N', lem:pathcw's OR clause and ex:or-cnf

**Problem.** Read literally, N contains both polarity copies of every gate, including copies that cannot be reached from the root, such as the negative copy of the output. cw(N) is a max over all gates h of N, so these copies count.
- For C = OR_i F_i, the negative copy is AND_i not-F_i. Its overlap is every variable shared by two F_i, so cw(N) ~ n. Measured: the cone of not-C for 3 window CNFs at n=30 has cw 30, while the positive cone has cw 3. Under that reading, the cw<=w claim of the Example and of the OR clause of lem:pathcw is false.
- Under the same reading, 'every OR-gate of N is deterministic' fails for any C with a non-trivial AND gate, because the AND's negated copy is a non-deterministic OR.
- sec-setting ('at most two copies'), the theorem's intent and the code (contexts() works on N.cone(root)) all mean the cone of the root.

**Proposed fix.** In the definition, write: 'N consists of the gates reachable from the root (a gate of C gets one copy for each polarity in which it occurs below the output)'. Equivalently, define Up, kappa and cw over the cone of the root. Make the d-DNNF hypothesis 'every OR-gate in the cone of the root of N'.

### 2. [minor] code/rareprob/nnf.py NNF._mk (hash-consing) vs paper/p1-ctx.tex lem:pathcw ('The same bound holds for an OR of such CNFs whose chains share no AND-gate') and ctxwidth.py docstring

**Problem.** to_nnf hash-conses nodes. Structurally equal AND-gates in different chains (e.g. two CNFs whose first clauses coincide) become one NNF node even when the circuit's chains share no gate. That node's Up set is then the union of both chains, so the code's cw can exceed the lemma's k+1.
- Explicit instance (t_hashcons.py): two width-2 path-bracketed CNFs sharing the clauses (x1 OR x2), (x3 OR x4). Each chain alone has cw 3 or 2; their OR has code cw 4 > k+1 = 3.
- In 3000 random ORs of path-bracketed CNFs (t_path2.py), the code exceeded k+1 in 3 cases. The gate-by-gate N (the paper's definition) never did.
- This does not affect soundness, since the compiled DNNF is still equivalent. It can make compile_ctx decline at max_cw or build a larger DNNF than the theorem's bound for the paper's N.

**Proposed fix.** Do one of the following:
- With flatten=False, key AND-nodes by (circuit gate, polarity), not by structure, so the NNF is the paper's gate-by-gate N.
- Note in nnf.py/ctxwidth.py, and in the lemma's OR clause, that merging structurally equal gates can raise cw, and that the bound applies to chains that share no AND-gate in the NNF actually used.

### 3. [minor] paper/p1-ctx.tex lines 197-205 ('Now let each module estimate the polarity its parent's rule uses: ... otherwise the rarer one'); code/tests/test_fix_ctx.py _walk (chooses the polarity using the exact probability c['pp'][0] <= 0.5)

**Problem.** The completeness claim (2xi_j <= rho_j, or (1+O(rho_j))rho_j) needs the module to estimate the rarer polarity, which is not known before estimating. If the wrong polarity is estimated for a non-unate input with q_j near 0 or 1, completeness fails. Example: q_j = 1 - 1e-9 estimated as q_j gives a tight interval for q_j but a useless one for 1-q_j, and the parent's xi_j is large. Soundness is unaffected.

The repository's test of the walk chooses the polarity with the exact probability (an oracle), so it does not exercise this step.

**Proposed fix.** Specify the choice. Either:
- estimate both polarities of each non-unate submodule (each at its own share of δ, so M counts them) and use whichever interval gives the smaller xi_j; or
- first run a crude estimate (O(log(1/δ)) samples separate q_j <= 2/3 from q_j >= 1/3) and estimate the polarity of probability at most 2/3.
In the second case the additivity constant becomes at most 2 for q_j in [1/3, 2/3], so the text should say so.

### 4. [minor] paper/p1-ctx.tex lines 179-186 (the rules for qhat_j and xi_j) and lem:quotient's last claim

**Problem.** Two edge cases fall outside the stated rules.
(a) Exact intervals: a submodule whose probability is computed exactly as 0 has L_j=U_j=0. The rule gives xi_j = ½log(0/0), and the parenthetical then sets xi_j=∞ and the parent interval to [0,1]. This is sound, but it throws away an exact zero. The same happens for exact intervals [1,1] in the complement rules.
(b) qhat_j = sqrt(L_jU_j) is irrational in general. Any method run at a rounded qhat_j satisfies the lemma's hypotheses only for a slightly larger xi_j than the formula gives. The paper is careful about rounding elsewhere (sec-envelopes).

**Proposed fix.** Add:
- 'If L_j=U_j, take qhat_j=L_j and xi_j=0.'
- 'For the qhat_j actually used, take xi_j = max{log(U_j/qhat_j), log(qhat_j/L_j)}, plus the complement terms log((1-L_j)/(1-qhat_j)) and log((1-qhat_j)/(1-U_j)) where the rule needs them, rounded upward.' This reduces to ½log(U_j/L_j) when qhat_j = sqrt(L_jU_j) exactly.

### 5. [minor] paper/p1-ctx.tex lines 32-35 ('has cw=w as a left-deep AND-chain in window order, and cw=n-2 (for 2<=w<=n-2) as a single AND-gate')

**Problem.** The equality cw=w for the chain also needs 2<=w<=n-2. Measured for n<=9 (t_window.py): w=1 gives cw 0, w=n-1 gives n-2 = w-1, and w=n gives 0. As placed, the parenthetical seems to qualify only the second claim.

**Proposed fix.** Write: 'for 2<=w<=n-2, such a CNF has cw=w as a left-deep AND-chain in window order and cw=n-2 as a single AND-gate over its clauses' (in general cw<=w for the chain).

### 6. [minor] code/rareprob/nnf.py line 350 (need = math.ceil(t - 1e-12) + shift) and code/rareprob/meta.py line 162 (ctx route not guarded)

**Problem.** A THR gate with integer weights and a non-finite threshold crashes the NNF expansion:
- t = ±inf raises OverflowError;
- t = NaN raises ValueError.
The circuit evaluator accepts such gates (constant false or true). meta_estimate then raises instead of declining. Measured: a 12- or 30-input THR with t=inf and ve_width=4 raises OverflowError at nnf.py:350. With the default small_cone=10, gates of support at most 10 are tabulated first and avoid it.

This is not a soundness violation, since no wrong interval is returned. But the procedure is meant to return an interval or no verdict on every input.

**Proposed fix.** In Circuit.add, reject NaN weights and thresholds. In to_nnf, map t=+inf to FALSE and t=-inf to TRUE, or make such gates opaque. Alternatively, wrap the ctx route in meta_estimate in try/except and decline, as the other routes do.

