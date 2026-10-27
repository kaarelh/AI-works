# Fix round: ctx-modules

## Fixer's summary

I addressed every finding from both ctx-modules referees in paper/p1-ctx.tex and code/rareprob/ctxwidth.py, and added code/tests/test_fix_ctx.py. Three files I don't own need edits (refs.bib, plus the intro, abstract, README and experiments wording); they are listed in external_edits. The paper builds with latexmk in a scratch copy (/tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/ctxfix/build/paper) with no undefined references, once the four refs.bib entries below are added. None of the overfull boxes are in p1-ctx.tex.

Paper:
(1) Context width is now defined on the NNF N built gate by gate, with nested gates not merged and children forming a set. A remark explains why the bracketing matters: merging OR gates never increases cw, but a window CNF has cw = w as a left-deep chain and cw = n-2 as one flat AND. It also defines cw*(C) as the minimum over re-bracketings.
(2) thm:cw now reads: a DNNF with at most (|N|+1)(cw+3)2^cw wires, computable in time O(|N|(n+(cw+1)2^cw)). The size count is in the proof. The text states |N| <= 2|C| for AND/OR/NOT circuits, |N| <= 12|C| with XOR (12(k-1) wires per fan-in-k XOR, both polarities together), O(kW) for thresholds with nonnegative integer weights of total W, and other thresholds only as frontier gates. cw(N)=0 iff N is a DNNF. The d-DNNF hypothesis now concerns the OR gates of N, with the exact-p consequence, and b_i is defined by q_i = a_i/b_i.
(3) New Lemma lem:pathcw with proof: clauses ordered by the first bag that contains them, bracketed as a left-deep chain, give kappa inside a bag, so cw <= k+1. The bound is tight: it is attained for every k from 0 to 4. It extends to an OR of such chains that share no AND gate. The decomposition is found in linear time for constant k (Bodlaender 1996; Bodlaender-Kloks 1996).
(4) The Example now uses the window-order bracketing and says cw <= w, with an FPRAS when w = O(log n). The #P-hardness argument is re-checked: it holds already at cw = 0, for ORs of at most 5 read-once CNFs, via a greedy 5-edge-colouring and the inclusion-exclusion identity, citing Greenhill 2000. I checked the identity on 30 random graphs of maximum degree 3.
(5) Frontier remark: cites Amarilli-Capelli-Monet-Senellart 2020, states the frontier's size contribution sum_f 2^|kappa(f)| |D_f|, and says the result is a d-DNNF only if every D_f is.
(6) Modules: restricted to gates in the output's cone, with a one-line laminarity proof, 'found in linear time [DR96]', and the module tree.
(7) lem:quotient: adds q, q-hat in [0,1]^k and a new part with proof: if U_j <= 1/2, q-hat_j = sqrt(L_j U_j) meets both conditions with xi_j = (1/2)log(U_j/L_j). Without this, the log-error would double at every level of the module tree.
(8) The module-walk paragraph is restated at the strength the lemma proves. Q is Q_g or not-Q_g, matching the polarity wanted, with explicit rules for choosing q-hat and xi. Each estimate is made at confidence delta/M (union bound), and log-ratios add when the rarer polarity, or the polarity matching a monotone or antitone input, is estimated. Completeness needs relative accuracy on the rarer polarity of every quotient.
(9) The unsupported '80 modules ... 0.1%' sentence is deleted.

Code: compile_ctx used the Envelope's SUM/PROD flattening, which broke the theorem's size bound. On the OR of all prefixes of an OR- or AND-chain (cw = 0, |N| = 600) it produced 20,500 wires. compile_ctx now builds with merging and switches to a non-merging build if the wire count would exceed (|N|+1)(cw+3)2^cw. That family now gives exactly |N| wires, and the measured maximum ratio to the bound is 0.33. The default output is unchanged wherever the bound held: rerunning exp_ctx.py in scratch reproduces results/ctx.json (same circuits, cw and DNNF sizes; interval ends agree to 3e-10 relative, the same as the unmodified code). I added path_order(clauses, bags) for the lemma's clause order, and updated the docstring (cw depends on the bracketing; use to_nnf(C, flatten=False)). Every function the compiled DNNF represents is unchanged, so every interval the code returns stays valid.

Outside my topic: the proof referee noticed that the 'threshold' row with 800 blocks in experiments/results/speedup.json has contains=False. That belongs to the tilting topic.

## Findings resolved

- proof+counterexample CRITICAL: definition flattens nested gates, so the Example's cw=O(w) is false (cw = n-2 flattened), contradicting code, experiments and the dtree analogy: Definition now uses the NNF built gate by gate: nested gates are not merged and children form a set. A remark shows that merging OR gates does not increase cw, while a window CNF has cw=w as a window-order left-deep chain and n-2 as one flat AND (both checked by test). The dtree analogy is kept as 'a binary AND-tree over clauses is a dtree; like a dtree's width, cw depends on the bracketing'. cw*(C) is defined as the minimum over re-bracketings.
- proof+counterexample MAJOR: 'size <=2|C|' and 'every circuit C ... O(|C| cw 2^cw)' false with XOR, weighted thresholds, flattening; zero at cw=0; time omits supports: thm:cw restated for N: at most (|N|+1)(cw+3)2^cw wires (the count is in the proof), time O(|N|(n+(cw+1)2^cw)). Stated: |N|<=2|C| for AND/OR/NOT; |N|<=12|C| with XOR (12(k-1) wires per fan-in-k XOR, both polarities); O(kW) for thresholds with nonnegative integer weights of total W; other thresholds only as frontier gates. All checked against the code: max |N|/|C| = 1.33 (AND/OR/NOT) and 7.5 (with XOR); XOR chains exactly 12k-18 per polarity; threshold |N|/(kW) <= 1.5; DNNF wires / bound <= 0.33.
- counterexample MAJOR: cw not invariant under re-association; 'ORs of bounded-pathwidth CNFs' needs a re-bracketing step: Added Lemma lem:pathcw with full proof: clauses ordered by the first bag containing them and bracketed as a left-deep chain give kappa(a_j), kappa(c_j) inside B_{l(c_j)}, so cw <= k+1, also for ORs of chains that share no AND gate. The decomposition is found in linear time for constant k [bodlaender1996, bodlaenderkloks1996], and the order in linear time. Added ctxwidth.path_order; tests show the bound k+1 is attained and that a shuffled chain reaches cw 21-29.
- proof+counterexample MAJOR: '80 random modules with p~1e-15 ... 0.1% in seconds' unsupported: Sentence deleted.
- counterexample MAJOR + proof minor: module walk needs two-sided accuracy (1-q_j), the complement flips one-sided conditions, union bound, transfer from F(q-hat) to F(q): Rewrote the paragraph. Q is Q_g or not-Q_g according to the polarity wanted. q-hat_j and xi_j are chosen by the new sqrt(L_j U_j) rule (U_j<=1/2, or Q monotone in y_j), its mirror for 1-q_j, or the general two-sided max rule. An interval for Pr[Q=1] under Bern(q-hat) is transferred by e^{+-sum xi}. Each estimate is made at confidence delta/M with a union bound, valid conditionally on earlier ones. Log-ratios add when each module estimates the polarity its parent's rule uses. Completeness needs relative accuracy on the rarer polarity, or monotone/antitone quotients with the matching polarity. The sqrt rule is proved in lem:quotient and checked numerically (200k intervals; 2000 random quotients in the test).
- proof minor: one-sided monotone case needs q-hat in [0,1]^k (counterexample y1 and (y2 or y3)): lem:quotient now assumes q, q-hat in [0,1]^k, and the proof notes A,B>=0 and that all intermediate points stay in [0,1]^k. The rule q-hat = sqrt(LU) always lies in [0,1] for sound intervals.
- proof minor: O(|C| cw 2^cw) is zero at cw=0; 'each wire contributes O(cw 2^cw) nodes'; time leaves out O(|N| n): Explicit count in the proof: |N|2^cw wires for the N-nodes, (cw+2)2^cw per wire for the M-nodes, the root adds as much, total (|N|+1)(cw+3)2^cw. Time per child/term is O(cw+1), plus O(n) bit operations per wire for supports and contexts.
- proof minor + counterexample minor: d-DNNF hypothesis ambiguous (De Morgan ORs); b_i undefined: Hypothesis is now 'every OR gate of N is deterministic', noting that the XOR/threshold expansion ORs are deterministic and De Morgan ORs need not be. Added that p is then exact in time linear in the size. FPRAS sentence now defines q_i=a_i/b_i and uses poly(|N|2^cw,...), polynomial for cw=O(log|N|). The comparator fix in thm:sis(a) is in external_edits.
- proof minor + counterexample minor: FPRAS only for w=O(log n); 'degree >=3' wrong and uncited; identity, oracle calls, colouring algorithm; hardness in cw=0 subclass: Example: cw<=w by lem:pathcw (window-order chain), FPRAS when w=O(log n). Hardness 'already for cw=0, for ORs of at most 5 read-once CNFs' via greedy 5-edge-colouring of a maximum-degree-3 graph (needs no Misra-Gries) and the identity sum over nonempty S of [5] (31 calls). Cites Greenhill 2000 for #P-completeness at maximum degree 3. Identity verified on 30 random max-degree-3 graphs.
- proof minor: frontier 'bounded treewidth by darwiche2009' (projection breaks determinism; size accounting): Cites Amarilli-Capelli-Monet-Senellart 2020 (d-SDNNF of size 2^{O(k)} times the cone's size). Added the size sum_f 2^|kappa(f)| |D_f| plus the theorem's bound for the other gates; d-DNNF only if every D_f is one; frontier gates are taken one per polarity.
- proof minor + counterexample minor: modules laminar 'of what'; gates outside the cone; DR96 is a linear-time DFS algorithm, not dominators: Modules restricted to gates in the output's cone. Added the one-line proof that supports are laminar. Text now says 'Modules are found in linear time [DR96]'. Added the module-tree construction with its justification (every path from sv(g_j) to g passes g_j).
- counterexample minor: repeated children make S_g miss self-overlap: Definition states that the children of a gate form a set (h AND h = h), as the code's hash-consing does.
- measurement found while checking numbers: code's DNNF wire count could exceed the theorem's bound (Envelope SUM/PROD flattening of shared nodes: 20,500 wires for |N|=600 at cw=0): ctxwidth.compile_ctx now builds with merging and, if the created wires exceed (|N|+1)(cw+3)2^cw, rebuilds without merging, which provably stays within the bound. Output is unchanged on all experiment instances: a scratch rerun of exp_ctx.py reproduces results/ctx.json. Tested in test_no_quadratic_blowup_on_shared_chains and test_dnnf_size_bound_and_equivalence.

## Not changed, with reasons

- proof referee, finding 1 fix text: 'kappa(chain prefix) has w-1 variables and kappa(clause) has w': This detail is wrong. Measured with the code, an interior prefix a_j of a window chain has kappa = {v_j,...,v_{j+w-1}}, which is w variables, because its own overlap and the next one both contribute. The paper therefore states only kappa inside the bag (|bag| <= k+1 = w), which gives the correct bound cw <= w (attained).
- counterexample referee, major 3 fix text: 'for pathwidth Theta(log n) only approximations exist, giving quasi-polynomial bounds': Omitted. The lemma is stated for constant k, where the linear-time algorithm applies. The claimed approximation consequence would need its own citation and argument and is not needed for any statement in the paper. For logarithmic pathwidth the lemma still applies when the decomposition is given.
- counterexample referee, minor: cite Misra-Gries for the (Delta+1)-edge-colouring: No longer needed: the reduction now uses a greedy edge-colouring with 2*Delta-1 = 5 colours (31 oracle calls instead of 15), which is trivially polynomial.

## Independent re-review

**Verdict.** Almost every finding is fixed correctly in p1-ctx.tex and ctxwidth.py. What remains: stale copies of the old theorem bound in other files, and a few smaller gaps in the module walk.

**Checks of the revised parts**
- Definition and remark: I recomputed by hand that a window CNF has cw = w as a left-deep chain in window order and n−2 as one flat AND. The code confirms this for every n ≤ 25 and 2 ≤ w ≤ n−2. Merging OR gates never raised cw in 3,000 random circuits.
- thm:cw size count: |N|·2^cw + |N|(cw+2)2^cw + (cw+2)2^cw ≤ (|N|+1)(cw+3)2^cw is correct.
- Code against the bound: 6,000 compilations of random AND/OR/NOT/XOR/THR circuits (both flatten modes, small_cone 0 and 3). Wires/bound is at most 0.333. phi>0 equals C on all inputs. The mass matches brute force. cw=0 iff decomposable. phi ∈ {0,1} in all 4,750 cases where every OR is deterministic.
- lem:pathcw: the proof is correct (interval property plus S_{a_j'} ⊆ sv(c_j'); ℓ(c) = max_v first(v)). It held for k = 0..5 on 1,800 random ORs of up to 3 chains, with maximum cw exactly k+1.
- Example: the 2Δ−1 = 5 greedy edge-colouring and the dual inclusion–exclusion identity are correct. I checked the identity on 20 random max-degree-3 graphs, with cw = 0 for every OR.
- lem:quotient: the new sqrt(L·U) part is re-derived and correct. The q-hat ∈ [0,1]^k hypothesis is now present.
- Modules: the laminarity proof and the module-tree argument are correct.
- Module walk: soundness verified by simulating 2,288 random module trees (no coverage failure). Log-ratios add exactly under the stated conditions.
- Code fallback: the non-merging rebuild is provably within the bound. On the shared-chain family it gives exactly |N| wires. The envelope sampler handles nested SUM/PROD nodes.
- Reproduction: rerunning exp_ctx.py in scratch reproduces results/ctx.json (same circuit sizes, cw, DNNF sizes; interval ends within 3.4e-10 relative).
- Tests: test_fix_ctx, test_core and test_fix_code pass (63 tests).

**The fixer's not_fixed items**
- They were right that interior chain prefixes have |kappa| = w, not w−1.
- They were right that Misra–Gries is unnecessary.

**Still open**
- The four refs.bib entries are not yet in the repository, so their citations are currently undefined.
- The intro (sec-intro.tex lines 72–79), the abstract and the README still carry the old 'every circuit … O(|C| cw 2^cw)' and 'errors that add' wording. These are pending external edits.
- The new p1-affine.tex and app-affine.tex (not yet included in the build) still quote the deleted O(|C| cw 2^cw) bound.
- The module-walk paragraph has three smaller gaps: intervals must be clipped to [0,1]; the completeness sentence reads as sufficient but fails near q = 1/2 for non-unate quotients; and Q_g is defined twice with different meanings.

Scratch scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/ctxreview/ (c1.py–c9.py).

- [resolved] referee:ctx-modules:proof #1 (critical): definition says nested gates are flattened, so the Example's cw=O(w) is false; contradicts code, experiments and the dtree analogy: The definition now uses the gate-by-gate NNF with no merging and set-valued children. The Example uses the window-order chain and lem:pathcw. cw* is defined over re-bracketings. Verified: chain gives cw = w and flat AND gives n−2 for every n ≤ 25 and 2 ≤ w ≤ n−2. The referee's suggested text ('kappa(chain prefix) has w−1 variables') was itself wrong: interior prefixes a_j have kappa = {j..j+w−1}. The fixer was right to state only cw ≤ w (attained).
- [partially] referee:ctx-modules:proof #2 (major): 'size ≤ 2|C|' and 'every circuit … O(|C| cw 2^cw)' false with XOR, thresholds and flattening: Correct in p1-ctx.tex. thm:cw is stated for N with (|N|+1)(cw+3)2^cw wires, and the count in the proof is right. The |N| ≤ 2|C| / 12|C| / O(kW) statements are correct, with the XOR chain at 12(k−1) wires for both polarities. Code ratio is at most 0.333 over 6,000 random compilations. However, sec-intro.tex lines 72–73 still state 'every circuit compiles … O(|C| cw 2^cw)' (pending external edit). p1-affine.tex cor:barrier-methods(iii) and app-affine.tex proof (iii) also still quote the deleted bound (see new findings).
- [resolved] referee:ctx-modules:proof #3 (major): unsupported '80 random modules with p≈1e-15 … 0.1% in seconds': Sentence deleted. No other copy remains in paper/*.tex or README.
- [resolved] referee:ctx-modules:proof #4 (minor): one-sided monotone case of lem:quotient needs q-hat ∈ [0,1]^k: Hypothesis q, q-hat ∈ [0,1]^k added. The proof notes A, B ≥ 0 and that intermediate points stay in [0,1]^k. The walk paragraph's rules can still produce q-hat > 1 if a child's upper end exceeds 1 (new finding).
- [resolved] referee:ctx-modules:proof #5 (minor): composition needs 1−q_j accuracy, a confidence split and the F(q-hat)→F(q) transfer: Paragraph rewritten: polarity-dependent Q, sqrt rule, mirror rule and two-sided max rule; transfer by e^{±Σξ}; δ/M per estimate with a union bound, valid conditionally. Simulation of 2,288 random module trees with these rules: no coverage failures. With consistent polarities, the final log-ratio equals the sum of the quotient log-ratios exactly. Residual completeness gap near 1/2 reported separately.
- [resolved] referee:ctx-modules:proof #6 (minor): O(|C| cw 2^cw) is zero at cw=0; 'each wire contributes'; time omits O(|N|n): Explicit count (|N|+1)(cw+3)2^cw and time O(|N|(n+(cw+1)2^cw)); both re-derived and correct.
- [resolved] referee:ctx-modules:proof #7 (minor): d-DNNF hypothesis ambiguous (De Morgan ORs): Now 'every ∨-gate of N is deterministic'. It notes that XOR and threshold expansion ORs are deterministic and De Morgan ORs need not be, and adds the exact-p consequence. phi ∈ {0,1} in all 4,750 random cases where every N-OR is deterministic.
- [resolved] referee:ctx-modules:proof #8 (minor): FPRAS only for w=O(log n); 'degree ≥3' wrong and uncited: Now 'cw ≤ w … FPRAS when w=O(log n)', 'maximum degree 3 [greenhill2000]', a greedy 5-edge-colouring (2Δ−1, correct) and the explicit dual inclusion–exclusion identity. Identity and cw=0 checked on 20 random max-degree-3 graphs. The greenhill2000 bib entry is not yet in the repository refs.bib (pending).
- [resolved] referee:ctx-modules:proof #9 (minor): frontier 'bounded treewidth by darwiche2009' (projection breaks determinism; size accounting): Now cites acms2020 (d-SDNNF, 2^{O(k)} times the cone), states the size Σ_f 2^{|kappa(f)|}|D_f| plus the thm:cw bound, and gives a d-DNNF caveat. The caveat is worded as 'only if' where 'if, in addition' is meant (minor wording, below). The bib entry is pending.
- [resolved] referee:ctx-modules:proof #10 (minor): 'laminar family' of what; DR96 is DFS-based and linear-time, not dominators: Modules are restricted to the output cone. The one-line laminarity proof is correct (the path x_v→g→output meets h). 'found in linear time [DR96]' is right: inside the cone the path definition coincides with DR96's. The module-tree justification (g_j cannot lie above g) is correct.
- [resolved] referee:ctx-modules:counterexample #1 (critical): flattening makes cw = Θ(n/t); the Example is false; contradicts implementation: Same as proof #1. The Example is now true under the definition. The experiments wording 'finds context width w' is consistent (cw=3 for w=3 and cw=5 for w=5 in ctx.json, reproduced).
- [partially] referee:ctx-modules:counterexample #2 (major): flattening blow-up, XOR, arbitrary thresholds, zero bound at cw=0, time: Theorem, text and code are fixed. compile_ctx now falls back to a non-merging build that provably meets the bound; the OR-of-prefix-chains family gives exactly |N| wires (fallback triggered) and runs in under 0.1 s at k=3000. Experiment outputs are unchanged. As for proof #2, stale O(|C| cw 2^cw) statements remain in sec-intro.tex and in p1-affine.tex / app-affine.tex.
- [resolved] referee:ctx-modules:counterexample #3 (major): cw not invariant under re-association; the bounded-pathwidth claim needs re-bracketing: New lem:pathcw. I re-derived the proof: if v ∈ sv(c_i) ∩ sv(c_j') with ℓ_i ≤ ℓ_j ≤ ℓ_j', then v ∈ B_{ℓ_j}. The OR extension (no shared AND gate) is correct, since shared clauses and literals have kappa inside their own ≤ k+1 variables. Bodlaender/Bodlaender–Kloks support linear time for constant k. Tested k=0..5, 1,800 instances: max cw = k+1, no violation. Omitting the Θ(log n) remark is fine.
- [partially] referee:ctx-modules:counterexample #4 (major): module walk needs two-sided accuracy; complement flips one-sided conditions; completeness does not follow: Soundness is now correct. The additivity claim, restricted to 'when the first two rules apply throughout', is correct (verified numerically). But the closing sentence 'Completeness thus needs … two-sided relative accuracy' reads as sufficient. That fails when module probabilities are near 1/2 and the quotient is non-unate: intervals straddle 1/2, the third rule applies, and the error doubles at each level (new finding). The intro's 'with errors that add' is still unconditional (pending external edit).
- [resolved] referee:ctx-modules:counterexample #5 (major): unsupported 80-module 0.1% claim: Deleted.
- [resolved] referee:ctx-modules:counterexample #6 (minor): 'degree ≥3' wording, citation, Misra–Gries, hardness in the cw=0 subclass: Maximum degree 3 with Greenhill 2000 cited, the identity stated, and 'already for cw=0' stated. The fixer was right that Misra–Gries is unnecessary: greedy colouring with 2Δ−1=5 colours is trivially polynomial, at the cost of 31 instead of 15 oracle calls.
- [resolved] referee:ctx-modules:counterexample #7 (minor): repeated children make S_g miss self-overlap: The definition now says children form a set (h∧h=h), matching the code's set(out) de-duplication.
- [resolved] referee:ctx-modules:counterexample #8 (minor): modules outside the cone are not laminar; DR96 is not dominators: Modules are defined only for gates in the output's cone, and the laminarity proof uses that. The citation is reworded to 'found in linear time'.
- [resolved] referee:ctx-modules:counterexample #9 (minor): b_i undefined; comparator literal; smoothing over all n; d-DNNF hypothesis wording: thm:cw now writes q_i=a_i/b_i and puts the hypothesis on the OR gates of N. The current p2-pcis.tex thm:sis(a) already smooths over all variables and uses x_i→[y_i<a_i], ¬x_i→[a_i≤y_i<b_i], so #E'=(∏b_i)D(E) holds.

### New findings of the re-review

### 1. [minor] paper/p1-affine.tex, cor:barrier-methods (iii) (lines 238–240), and paper/app-affine.tex, proof (iii) (line 160)

**Problem.** Both still quote thm:cw as 'the DNNF of thm:cw … has O(|C| cw 2^cw) wires', which is the bound this revision deleted.
- That bound is zero at cw=0, so the derived lower bound 'cw ≥ m−12−log2(n|C|cw/c)−O(1)' is meaningless at cw=0.
- It is stated 'for every circuit C with C^{-1}(1) ⊆ V', but thm:cw now applies only to an NNF N of C. |N| can be O(kW)·|C| for integer thresholds, and general thresholds are not covered at all.
- The files are not yet included by sec-part1.tex or appendix.tex, but they will be inconsistent once integrated. The fixer's external_edits do not list them.

**Proposed fix.** In (iii) write: 'the DNNF of thm:cw has S ≤ (|N|+1)(cw+3)2^cw wires (|N| ≤ 12|C| for {∧,∨,¬,⊕}-circuits), so cw ≥ m−12−log2(n|N|(cw+3)/c)−O(1)'. In app-affine (iii) use the same S. Restrict (iii) to circuits whose NNF N is defined (no threshold gates other than nonnegative-integer-weight ones).

### 2. [minor] paper/p1-ctx.tex, module-walk paragraph after lem:quotient ('Take q-hat_j = sqrt(L_jU_j) … if U_j ≤ 1/2 or Q is monotone in y_j; symmetrically with 1−q_j …; otherwise … ξ_j = max{log(U_j/L_j), log((1−L_j)/(1−U_j))}')

**Problem.** The rules assume [L_j,U_j] ⊆ [0,1], but the walk's own output for a submodule, [e^{−Σξ}L_F, e^{Σξ}U_F], can have upper end above 1.
- Monotone case: sqrt(L_jU_j) > 1 whenever L_jU_j > 1 (e.g. [0.98, 1.1] gives q-hat = 1.04). This violates the lemma's new hypothesis q-hat ∈ [0,1]^k, and Bern(q-hat) is undefined.
- Antitone/mirror rule: sqrt((1−L_j)(1−U_j)) is the square root of a negative number.
- Third rule: log((1−L_j)/(1−U_j)) is undefined.
- In my simulation of random module trees without clipping, these cases occurred in most deep trees (1,865 math-domain errors and 118 trees with q-hat ∉ [0,1]). With clipping, every rule is sound.

**Proposed fix.** Add: 'intervals are first intersected with [0,1] (U_j ← min(U_j,1)), which keeps them valid since q_j ∈ [0,1]'. Alternatively, state that the walk outputs [e^{−Σξ}L_F, min(1, e^{Σξ}U_F)].

### 3. [minor] paper/p1-ctx.tex, module-walk paragraph: third rule and 'Completeness thus needs every quotient to be estimated to small relative error on its rarer polarity (two-sided relative accuracy)'

**Problem.** The sentence reads as a sufficient condition, but it is not sufficient under the stated rules.
- When a module's probability is near 1/2, its interval straddles 1/2 even at small relative error. If the parent quotient is not unate in that input, neither of the first two rules applies.
- The third rule then sets ξ_j to the full log(U_j/L_j), so the parent's log-ratio picks up 2·log-ratio(child): the error doubles at every such level.
- Example: a chain g_{i+1} = XOR(g_i, z_i) with Pr[z_i] = 0.3 and a leaf at 1/2 ± relative 1e-3, quotients computed exactly. After 10 levels the paper's rules give a final log-ratio of 1.14. Using q-hat = sqrt(LU) with an honestly computed ξ gives 0.001005.
- So two-sided relative accuracy per quotient does not by itself give completeness. The rule as written needs per-estimate accuracy of about 2^{−depth}.

**Proposed fix.** Replace the third rule by: q-hat_j = sqrt(L_jU_j) (or its mirror) and ξ_j = max{½log(U_j/L_j), log((1−L_j)/(1−q-hat_j)), log((1−q-hat_j)/(1−U_j))}. This is sound by the lemma's first part and equals ½log(U_j/L_j)·(1+O((U_j−½)_+)) for narrow intervals, so log-ratios stay additive up to a 1+O(width) factor per level. Or keep the rule and add to the completeness sentence: 'and every interval lies on one side of 1/2 or the parent quotient is unate in that input'.

### 4. [minor] paper/p1-ctx.tex, sec:modules-quotients: 'C(x)=Q_g(g(x_{sv(g)}),x_rest)' versus 'so g=Q_g(g_1,…,g_k,x')', and 'let Q be Q_g or ¬Q_g'

**Problem.** Q_g is defined twice with different meanings. First it is C as a function of g and the inputs outside sv(g). Then it is g as a function of its maximal submodules and x'. The walk paragraph uses the second meaning.

**Proposed fix.** Use a different symbol for the module-tree quotient (e.g. R_g for g = R_g(g_1,…,g_k,x')) and use it in the walk paragraph.

### 5. [minor] paper/p1-ctx.tex, frontier remark: 'and the result is a d-DNNF only if every D_f is one'

**Problem.** The sufficient direction is the one needed, and it is not stated. The result is a d-DNNF if every OR of N is deterministic and every D_f is a d-DNNF. The 'only if' direction is not true in general: a nondeterministic OR of D_f may vanish after conditioning, or D_f may be unused.

**Proposed fix.** Write 'and the result is a d-DNNF if, in addition to the hypothesis of thm:cw, every D_f is one'.

### 6. [minor] paper/p1-ctx.tex, after the definition: 'a threshold gate … with nonnegative integer weights of total W becomes a sequential counter …; other threshold gates are covered only as frontier gates'

**Problem.** This disagrees with sec-setting.tex ('threshold gates with polynomially bounded integer weights expand by a counter'). It also understates the reach: an integer weight w_i < 0 reduces to |w_i| on the complemented input (w·h = |w|·¬h − |w|), so every integer-weight threshold has an O(k·Σ|w_i|) counter. Only non-integer (or exponentially large) weights need frontier treatment.

**Proposed fix.** Say 'integer weights with W = Σ_i|w_i| (negative weights by complementing the input)' and align sec-setting.tex. Or state the nonnegative restriction in both places.

