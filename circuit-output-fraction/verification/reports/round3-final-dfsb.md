# Final referee report: dfsb

**Verdict.** contains false statements. Two side claims are false: the read-once-composition clause of cor:dfsb(a), and the (R8) claim that a small-cone rewrite changes neither DFSB's tree nor class membership. Both have easy fixes. thm:dfsb is correct: soundness, the pilot constants, the pruning argument, the box-looseness bound and the 2δ accounting. So are cor:dfsb(b)-(d), prop:dnnf-env, thm:meta and the limits paragraph, up to minor fixes. No soundness violation was found in 290,000 randomized runs against exact rational p.

**What was checked.** Read p1-dfsb.tex and p1-tail.tex line by line, plus their dependencies: sec-setting.tex, sec-envelopes.tex (lem:envmass, thm:envelope, thm:boxes), thm:sis in p2-pcis.tex, prop:fourier in p1-affine.tex and refs.bib. Read the code: dfsb.py, nnf.py, compile.py, envelope.py, stats.py, cnf.py, dist.py, circuit.py, meta.py. Scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/final_dfsb_ref/.

LENS A (re-derived):
- (F), (D)-and, (D)-or and (B) are exact identities.
- Pilot tails. Lower: exp(-(3/4)^2 mu/2) <= (delta/2m)^18 at mu = N0/K. Upper: (e/4)^{16 ceil ln(2m/delta)} <= (delta/2m)^6, and 3m(delta/2m)^6 <= delta/8.
- Pruning of T*_K. The proof covers the zero-mass (E) leaf and failed or truncated (E) tests.
- (E) with boxes. Pilot box intervals with u <= (1+1/(2L))l give rho_max/rho_min <= e, so K_h <= 16eK. In Phase 2, e^{-eta/4}/(16eK) >= 1/(64K).
- Truncation: (1-1/(16K))^{T_f} <= delta/(8N_f). The failure sum delta/8+delta/4+delta/2+delta/8+delta = 2delta.
- Ratio propagation, including concavity of 1-prod(1-x) on rays (the domain caveat is harmless). (1+eps/(3d))^d <= e^{eps/3}.
- Cost terms: R8 is O(2^a|C|^2); (F), (T'), Phi_h and root probing/elimination as stated. The exception is the |N| bound (finding 3).
- Code matches the text: N0, sample_cap stage alignment (first = 1024, doubling), the eps_is = 0.999 eta slack, caps for box leaves (64K, eta/4, delta/2l) and (16K, eta/(8L), delta/(2lr)), T_f, loose cap, outward rounding in _combine.
- cor(c) proof: leaves count as terminal vacuously, so the count is complete. Checked on 400 random formulas with (S) and (E) off: nodes <= 0.75 s 3^r, all exact and containing p.
- cor(a): read-once exactness verified. cor(b) and (d) are correct.
- prop:dnnf-env: R2 on a decomposable AND gives the same function as the product of children; R6 and R7 only lower the mass; the DNF claim and the thm:sis route are as stated.
- thm:meta proof and meta.py: delta/(3M) per method (code counts one extra method, which is conservative); [0,1] on an empty intersection; skipping is safe.
- Limits paragraph: rETH argument, O*(1.84^n) clause branching, Markov bound K >= (8/7)^{m-n/3}/n.

Citations (web):
- meel2026dnnf: '#CFG and #DNNF admit FPRAS', SODA 2026, pp. 5978-6010, confirmed.
- gopalan2011fptas: the FOCS'11 text states counting for all product distributions via small-space sources, which supports the product-distribution claim.
- The 4.82 constant: arXiv 2409.03951 cites d <~ 2^{k/4.82} as the state of the art for k-CNF sampling, and arXiv 2609.18712 attributes exponent ~4.82 (Boolean) to Wang-Yin's condition. Consistent with wangyin2024, but the full text was not reachable.
- Bodlaender et al. 5k+4 in 2^{O(k)}n, and Ehrenfeucht-Karpinski: consistent.

LENS B:
- sound_rand.py: 200,000 random circuits with AND/OR/NOT/XOR, integer and opaque THR, repeated children, q in {0, 1, 1e-200, 1-2^-53, 1e-3, ...}, atom size 0-3, budgets 2-300, K in {1,2,8}, envelopes and dense test on/off, leaf caps 30-3000. delta = 0.2; exact Fraction p. 509 true misses (0.25%), no crashes. 118 runs returned U > 1 (finding 4).
- sound_box.py: 90,000 runs with about 25,600 accepted envelopes, about 5,460 with boxes. 391 misses (0.43%; 0.6% among runs with E-leaves).
- extreme.py: subnormal and underflow cases are valid (U > 0 kept); tightness is lost (finding 5).
- resol*.py: re-checks of all earlier counterexamples.
- compo.py / compo_run.py and r8inv*.py / r8run.py: the two new counterexamples, with an exact-density ideal-tree builder.
- nsize.py: |N| growth.

Experiment numbers: p1-dfsb.tex and p1-tail.tex contain no experiment-derived numbers, only implementation parameters (a=12, s7=512, tau=0.05, B=2e5, 3 Shannon splits, VE w<=18), all matching the code. The dependency sec-envelopes.tex has the Janson example ([4.33,5.07]e-7, 30 s), not judged.

Cosmetic, not filed: M means both 'number of procedures' and the presolve factor ('M <= 1/2') in p1-tail line 83.

## Audit of earlier findings

resolved: 25, partially resolved: 2

- [resolved] (critical) proof#1 ETH / 2^{o(log 1/p)} speed-up bound (sec:part1-limits): p1-tail.tex 88-96 now uses randomized ETH. The claim is that no sound procedure complete on satisfiable 3-CNFs costs 2^{o(log 1/p)}poly(|C|), via a time cut-off and 'SAT iff L>0'. The text also notes the O*(1.84^n) clause-branching speed-up. Re-derived; correct.
- [partially resolved] (major) proof#2 cor(a) read-once compositions of arbitrary K-dense circuits; cor(b) O(1): (b) now reads m_K(C)=1+m_K(C|_F), equal to 2 when C|_F is an atom or not decomposable; correct. (a) now requires each lambda_i, in its polarity, to satisfy the hypothesis itself, which excludes y OR mu (mu is a rare non-decomposable leaf). The clause is still false by a different mechanism: probing and elimination run only at the root (new finding 1).
- [resolved] (major) proof#3 Phase 2 uncapped, loose leaves unspecified, box re-estimation breaks looseness: Text lines 55-76 define the caps N(K',eta',delta'), the loose-leaf cap, fill truncation T_f and the poly-time bound. (E) now re-estimates boxes to ratio 1+1/(2L), and the proof gives K_h <= 16eK and a Phase-2 IS mean >= 1/(64K). Constants checked; dfsb.py sample_cap, _pilot_boxes and _fill_cap implement exactly this.
- [resolved] (major) proof#4 (R8) OBDDs are non-decomposable; closure-under-rewriting claim: Atoms (support <= a) are now (T') exact leaves and are never merged into larger parents. AND_{j<=8}((a&b)|(c&d)) and AND_{i<=30}(x|y) are now exact (ratio 1 +- 2e-15, 0 samples). The closure claim is restricted to cones of <= a variables. A residual problem with root elimination is new finding 2.
- [resolved] (major) proof#5 degree-2 algebraic module (MQ is NP-hard): p1-tail 45-51: 'an affine system with at most one quadratic equation' under the uniform distribution, plus the remark that several quadratics are NP-hard. Correct (Ehrenfeucht-Karpinski).
- [resolved] (minor) proof#6 K=1 still samples; injectivity sentence in cor(c) proof: cor(c) now has '(S) and (E) disabled'. The proof was rewritten with sigma-classes, terminal nodes and (D)-LCAs. Valid; leaves are terminal vacuously. Checked empirically (400 random formulas, nodes <= 0.75 s 3^r, exact).
- [resolved] (minor) proof#7 uncounted costs (|Phi|, boxes, R8, probing, Gauss, XOR/THR NNF size): thm:dfsb now lists O(|N|+|Phi_h|), box costs, s7 B, O(2^a|C|^2) for R8, and probing/elimination O(n^2(|C|+|N|)+n^3). sec:setting gives the XOR and threshold expansions and opaque gates. Residual: the bound |N|=O(2^a|C|) ignores flattening (new finding 3).
- [resolved] (minor) proof#8 'characterised by' / 'class is therefore': Text now says 'guaranteed by', 'With K=K(|C|) and m=m(|C|) fixed polynomials', and 'sufficient, not necessary'.
- [resolved] (minor) proof#9 prop:dnnf-env equality, rational marginals, (R7): Now 'K <= E[phi|C=1] ... with equality unless (R6)'. Rational marginals with a poly(|C|,n,max log b_i,...) time bound; '(R1)-(R6) and (R8)'. A small residual (R7 also breaks equality) is new finding 9.
- [resolved] (minor) proof#10 thm:meta (M undefined, empty intersection, fixed polys, probability, eps', LLL syntactic): All six points fixed in p1-tail 54-77. Proof re-checked: delta/3 validity, 2delta/(3M) tightness, nested intervals. meta.py matches (outputs [0,1] on an empty intersection).
- [resolved] (minor) proof#11 distributed-surprise expectation; 'no test certifies'; PRG/hash: Markov bound p <= n(7/8)^m w.p. 1-1/n and K >= (8/7)^{m-n/3}/n. Now 'no polynomial-time certificate is known'; partial rejection sampling cited; hash functions dropped; security 2^{(1-o(1))k} stated.
- [resolved] (minor) proof#12 T*_K well-definedness (ties, conflicts); greedy treewidth order: (B) ties go to the smallest index; a conflict gives D(h)=0. The treewidth module uses the Bodlaender et al. order or greedy if narrower, and discloses that the implementation is greedy-only.
- [partially resolved] (critical) cex#1 cor(a) compositions: negation (F=NOT) and (D)-before-(S) rule order: The polarity requirement kills the NOT C example. 'lambda_i satisfies the hypothesis itself' kills the dense OR of disjoint rare cycle-CNFs. The composition clause is still false via root-only probing (new finding 1).
- [resolved] (major) cex#2 cor(b) O(1) when C|_F decomposable: Replaced by m_K(C)=1+m_K(C|_F), equal to 2 only for an atom or a non-decomposable C|_F; the cost is stated for that case.
- [resolved] (major) cex#3 cor(c) K=1 samples; tautology leaves; injectivity: Now '(S) and (E) disabled', so tautologies are moot. The new counting proof is correct. Mux example (8 multiplexers, atom size 2, S and E off): exact, 25 nodes, 0 samples.
- [resolved] (major) cex#4 (R8) breaks read-once exactness and Conf; closure claim false for large cones: Verified exact via (T') atoms. The closure claim is restricted to cones <= a and cites the absorption counterexample. New finding 2 is a separate residual.
- [resolved] (major) cex#5 ETH conclusion: See proof#1.
- [resolved] (minor) cex#6 distributed surprise: per-instance p, alpha_sat, PRS: Now 'alpha > 1/3 small enough that it is satisfiable whp', with the Markov bound and gjl2019 cited.
- [resolved] (minor) cex#7 pseudorandom rarity: security level, hash functions: Now 'if G has security 2^{(1-o(1))k} ... factor 2^{o(k)}'; hash functions removed.
- [resolved] (minor) cex#8 non-sampling work omitted: See proof#7; the |N| residual is new finding 3.
- [resolved] (minor) cex#9 K/m search, 'therefore', rho distortion in (E) acceptance: Fixed polynomials; sufficient-not-necessary; the T*_{16K} pruning remark is correct; the rho distortion is folded into K_h <= 16eK.
- [resolved] (minor) cex#10 conflict / Z=0 edge cases and crash in _pilot_env: Text: a conflict gives D(h)=0, and a box-free envelope of mass 0 gives D(h)=0. Code returns a const-0 leaf. OR(AND(x0,x1),AND(x0,x2)) with q0=0, atom size 0 and no probing now gives [0,0] without a crash. No crashes in 290k random runs with 0/1 marginals.
- [resolved] (minor) cex#11 prop:dnnf-env (R6 equality, DNF terms, rational marginals, R7): All four points addressed; see proof#9.
- [resolved] (minor) cex#12 degree-2 constraints: Narrowed to one quadratic equation. The O(log n)-quadratics extension was not adopted, but the stated claim is correct.
- [resolved] (minor) cex#13 greedy treewidth; LLL for biased D; 2^{k/4.82}: Bodlaender order used; LLL item restricted to the uniform distribution. 4.82: web sources (arXiv 2409.03951, 2609.18712) tie d <~ 2^{k/4.82} for k-CNF sampling to the Wang-Yin coupling condition. Consistent; full text unreachable.
- [resolved] (minor) cex#14 thm:meta polynomials, empty intersection, probability, eps-dependence, underflow: All addressed; 'for these parameters and the given eps'; exact modules use rational or certified floating-point arithmetic, rounded outwards.
- [resolved] (minor) cex#15 opaque nodes, duplicate children, XOR in read-once formulas: Opaque gates are defined (sec:setting) and their treatment in (F) and (B) is stated; 'duplicate children removed'; 'read-once {AND,OR,NOT}-formulas'.

## New findings

### 1. [major] paper/p1-dfsb.tex cor:dfsb(a) lines 167-172 ('read-once compositions ... in which each lambda_i ... satisfies the hypothesis itself') and its proof lines 218-220 ('(F) and (D) act on each lambda_i as on lambda_i alone')

**Problem.** (F) does failed-literal probing and Gaussian elimination only at the root (line 33). A lambda_i that satisfies (a) as its own circuit can rely on root probing, but inside a composition it is not at the root and gets unit propagation only.

Counterexample under the uniform distribution, K=4, M=14:
lambda = (z|u)&(z|~u)&AND_{j<=t}[(z|v_j|b_j)&AND_{i<=M}(v_j|a_{ji})].
- Alone: root probing forces z=1, and lambda|_{z=1} splits into t groups of probability 1/2+2^-15. So m_K(lambda)=t+1 and (a) holds.
- C = lambda OR lambda' on disjoint copies (F=OR, monotone): C does not imply z, and UP at the lambda node derives nothing. lambda is a rare non-decomposable node, and (B) branches on the v_j (M+1 occurrences each, z only t+2) before z.

Ideal trees with exact densities, t=4,6,8,10,12:
- lambda alone: m_K = 5, 7, 9, 11, 13;
- C: m_K = 45, 189, 765, 3069, 12285, with |C| = 384..1120 wires. Exponential in |C|.

The real DFSB (t=12, m=2000) without (E) exhausts the budget: 4 loose leaves, U/L = 8.1. With (E) it is tight (U/L 1.08), so this is a false class-membership claim, not a soundness issue. Scripts: compo.py, compo_run.py.

**Proposed fix.** Either (i) state (a)'s hypothesis on lambda_i for the component tree built with (F) restricted to unit propagation (no probing or elimination), i.e. for lambda_i as a non-root node, and correct the proof sentence accordingly. Or (ii) make probing (and elimination) part of (F) at every node: the identity then holds, and the theorem's cost gains an O(n^2|N|) term per node.

### 2. [major] paper/p1-dfsb.tex rule (R8) lines 247-252 ('changes neither the canonicalised NNF nor, hence, the tree of DFSB and membership in the classes above') with (F) lines 33-34; code dfsb.py estimate() lines 481-490 (cnf.forced_input_literals(self.C))

**Problem.** The root's Gaussian elimination (and the first probing/UP pass) act on the circuit C, where affine conjuncts are recognised syntactically (cnf.affine_conjuncts). They do not act on the canonicalised NNF. Rewriting an atom-sized gate therefore changes the tree although the NNF is unchanged.

Instance:
C = A & B & AND_{j<=t}[(x1|v_j|b_j)&AND_{i<=14}(v_j|a_{ji})], with A = XOR(g, x3..x15) and B = NOT XOR(x2..x15).
Compare g = x1 XOR x2 with the equivalent g' = (x1&~x2)|(~x1&x2): same support of 2 <= a, and identical canonicalised NNF (equal structural hash).
- With g: elimination forces x1=1, and m_K = 8, 10, 12 for t = 6, 8, 10.
- With g': nothing is forced, and m_K = 190, 766, 3070.

Real DFSB at t=12, K=4, m=2000:
- g: 14 nodes;
- g' without (E): 2008 nodes, 8 loose leaves, U/L = 70.7;
- g' with (E): tight (U/L = 1.07).
Scripts: r8inv.py, r8inv2.py, r8run.py.

**Proposed fix.** Detect affine conjuncts after (R8): treat each atom as a black box and call it affine when its truth table is a parity (checkable in O(2^a)). Run root probing on N only (it already runs there in build(root=True)). Alternatively, weaken the claim to 'changes neither the canonicalised NNF nor the tree below the root's elimination step'.

### 3. [minor] paper/p1-dfsb.tex thm:dfsb line 96 ('|N| = O(2^a|C|) for {AND,OR,NOT,XOR}-circuits') and proof lines 144-146

**Problem.** Flattening copies the children of shared same-kind non-atom gates into every parent, so |N| is not O(2^a|C|).

Example: g_i = AND(g_{i-1}, x_i), output OR(g_1..g_{n-1}).
- |C| = 147, 297, 597, 1197 wires;
- atom_nnf has 905, 4180, 18230, 76330 wires.
The ratio grows linearly, so |N| = Theta(|C|^2) (nsize.py). The bound feeds the per-evaluation and remaining-work costs, which stay polynomial but are understated.

**Proposed fix.** State |N| = O((2^a|C|)^2) in general, or flatten only gates of fan-out 1, for which O(2^a|C|) holds. Propagate the change to the evaluation-cost and remaining-work bounds.

### 4. [minor] code/rareprob/envelope.py envelope_estimate lines 444-455 and dfsb.py _combine line 644-645 (leaf intervals returned unclipped)

**Problem.** An (E)-leaf interval is not clipped to [0,1], and DFSB passes a root E-leaf through unchanged. This contradicts def:sound ([L,U] subset of [0,1]) and thm:envelope(ii) (min(Zu,1)).

Reproduced: seed 11, run 2842 of sound_rand.py (replay.py), a 5-input circuit with p = 1, outputs [0.9109, 1.0000000000009912]. 118 of 200,000 random runs returned U > 1. Validity is unaffected.

**Proposed fix.** At the end of envelope_estimate set hi = min(hi, 1.0) and lo = min(lo, hi). Or clip leaf intervals in DFSB._combine.

### 5. [minor] code/rareprob/dfsb.py _combine (lines 635-680) and module docstring lines 61-64 (tightness claim); paper p1-dfsb.tex lines 152-153 (class contains p = 2^{-Omega(n)})

**Problem.** DFSB combines leaf intervals in linear-domain doubles. Results below about 2^-1022 lose relative precision and flush to [0, 5e-324], so the implementation is not complete on members of {m_K <= m} with small p, although the docstring claims tightness.

Example: AND_{i<60}(x_{2i} | x_{2i+1}) with q = 1e-10 has m_K = 61 exact leaves and p ~ 10^-581.9; DFSB returns [0, 5e-324] (valid, not tight; extreme.py). The envelope and VE code keep log-domain bounds; DFSB does not.

**Proposed fix.** Carry log-domain intervals in _combine: sums of logs for (F) and AND; log1p/expm1 on log-probabilities for OR; log-sum-exp with outward rounding for (B). Or state in the docstring and the paper that the implementation's completeness needs p above the normal double range.

### 6. [minor] code/rareprob/dist.py Product.sample line 33-34, used by dfsb.py _mc_leaf (471-474), _pilot_boxes (314-350) and envelope.estimate_boxes

**Problem.** rng.random() < q sets x_i = 1 with probability ceil(q 2^53)/2^53, not q. For example, q = 1e-20 is sampled as 1.1e-16. MC leaves and box intervals in DFSB are computed for this sampler's law and are not widened. envelope_estimate does widen the IS mean by an absolute tau for exactly this discreteness. So the implemented coverage is strictly delta + N n 2^-53 (by coupling), not delta. The excess is negligible at feasible N (no misses attributable to it in 290k runs), but the guarantee as coded is not the stated one.

**Proposed fix.** Widen every MC-leaf and box KL interval by an absolute n*2^-53 on the mean, as envelope_estimate does with tau. Or draw Bernoulli(q) exactly, for example by comparing more random bits with q's binary expansion.

### 7. [minor] paper/p1-tail.tex Local-lemma bullet lines 30-34 ('k-CNFs (more generally, local CSPs) whose variables lie in at most d <= 2^{c'k} constraints ... admit FPRASs')

**Problem.** For general local CSPs, arity k does not control the violation probability. A k-ary constraint can be violated with probability 1/2, so 'd <= 2^{c'k}' is not a sufficient condition. The cited results (fhy2021, jpv2021, hwy2022) are stated as p*Delta^{c} <~ 1, with p the maximal violation probability and Delta the dependency degree.

**Proposed fix.** Write 'k-CNFs with d <= 2^{c'k}; more generally, local CSPs whose maximal violation probability p and dependency degree Delta satisfy p Delta^{c} <~ 1 [fhy2021, jpv2021, hwy2022]'.

### 8. [minor] paper/p1-tail.tex Affine bullet lines 49-50 ('the quadric changes the probability inside the affine space by at most a factor 4 (prop:fourier)')

**Problem.** prop:fourier(c) gives Pr_{x in V}[Q=0] in {0} union [1/4, 1]. The quadric can make the probability 0, a change by more than any factor.

**Proposed fix.** '... by at most a factor 4 unless the system is inconsistent (probability 0)'.

### 9. [minor] paper/p1-dfsb.tex prop:dnnf-env lines 262-263 ('K <= E_D[phi | C=1] ... with equality unless (R6) replaces a sub-envelope')

**Problem.** (R7) also replaces sub-envelopes, by boxes. It is on by default (tau = 0.05, applied when the rule mass exceeds twice the pilot density), and it can fire inside a DNNF whose local ambiguity exceeds 2. Equality then fails, although the inequality still holds because a box has mass at most that of the sub-envelope it replaces.

**Proposed fix.** 'with equality unless (R6) or (R7) replaces a sub-envelope'.

