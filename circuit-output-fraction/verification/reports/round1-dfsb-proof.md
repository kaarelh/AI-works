# Referee report: dfsb (proof lens)

**Verdict.** contains false statements. The core of Theorem thm:dfsb holds: soundness, the pilot constants, ratio propagation and the cost formula under its hypothesis. Three side claims are false as written: the 2^{o(log(1/p))} remark in sec:part1-limits, the read-once-composition clause of Cor. cor:dfsb(a), and the degree-2 algebraic module. The algorithm is also underspecified in a way that breaks the polynomial-time claim of Thm thm:meta: Phase 2 has no sample caps and loose leaves have no rule.

**What was checked.** Read sec-part1.tex in full: sec:dfsb, sec:rules, prop:dnnf-env, sec:modules, thm:meta and sec:part1-limits. Also read the dependencies sec-setting.tex, sec-envelopes.tex, prop:worstcase in sec-limits.tex and thm:sis in sec-part2.tex. All scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad.

Verified correct:
(1) (F), (D)-and, (D)-or and (B) are exact identities under a product distribution. D(h)=D(h AND F)=D(F)D(h|_F) because h|_F is independent of F's variables.
(2) Pilot constants. Lower tail: the exponent (mu-t)^2/(2mu) increases in mu for mu>=t; at mu=N0/K it equals 18*ceil(ln(2m/delta)). Upper tail: e^{-mu}(e mu/t)^t increases for mu<t, giving (e/4)^{16 ceil(ln(2m/delta))} <= (delta/2m)^6. A union bound over at most 2m adaptively chosen pilots is fine. I also checked the bounds against exact binomial tails for K in {1,2,4,16,64}, m in {1,10,1000}, delta in {0.5,0.05,0.001}; all pass (chern.py).
(3) The pruning argument (actual tree is a pruning of T*_K, at most m nodes, leaves 16K-dense or envelope looseness at most 16K) is correct, given deterministic tie-breaking in (B).
(4) Ratio propagation:
- products multiply ratios;
- exact convex or scaled combinations do not increase them;
- for f(x)=1-prod(1-x_j), U<=bL implies f(U)<=b f(L). g(t)=f(tx) has g''=-e^h[(sum y_j)^2-sum y_j^2]<=0 on [0,1/max x_j]. When some b x_j>=1, f(x)>=x_j>=1/b directly. So 'concave along rays' needs only this domain caveat. Random trials (2e5) give max f(U)/(b f(L)) = 1+4e-16 (orratio.py).
(5) (1+eps/(3d))^d <= e^{eps/3} <= 1+eps for eps<=1. d<=n because leaves on one derivation have pairwise disjoint nonempty supports.
(6) The Phase-2 cost O~(l K d^2 eps^-2 log(l/delta)) follows from thm:envelope(iv) with looseness 16K and eta=eps/(3d). The example cost O(t^3 eps^-2 log(t/delta)) in (a) matches.
(7) Cor (c): any variable shared by two children after restriction and flattening is in Conf(C). Two flattened children reach the gate by paths that diverge at some gate with two distinct children both containing the variable. Every (B) variable is therefore in Conf, and fully assigned Conf makes every gate decomposable. The count O(s 3^r) holds; see the minor finding on the injectivity wording.
(8) R1-R7 each give phi >= 1_h with supp(phi_c) inside sv(c), so Prod gates stay decomposable.
(9) prop:dnnf-env: the DNNF's own circuit has support C^{-1}(1), so K=E[phi|C=1], and K<=m for a DNF.
(10) thm:meta: the union bound and the claim that the intersection of intervals is no looser than its tightest member are correct.
(11) The distributed-surprise arithmetic (at most n/3 disjoint 3-clauses, K>=(8/7)^{m-n/3}) is correct up to the expectation issue noted below.

Citations:
- Bodlaender et al. 2016: 5-approximation in 2^{O(tw)}n, correct.
- Ehrenfeucht-Karpinski: one quadratic polynomial is in P, degree 3 is #P-complete.
- The 4.82 constant matches a search-result summary of an exponent 2+phi(q) -> 2 as q grows, about 4.82 for Boolean domains. But the snippets found did not show 4.82 in the cited Wang-Yin paper (arXiv:2307.14872), and they linked the figure to a newer arXiv:2609.18712. The abstracts could not be opened (arxiv.org unreachable), so the attribution is unconfirmed. I did not file a finding.

Experiments using rareprob.DFSB, envelopes off, K=4:
(a) C = y OR mu, with mu a planted system of k/2 random XOR equations of weight k/2 (cora2.py). Tree sizes:
- k=12: 225 nodes against 48 wires (NNF 189 nodes);
- k=16: 1537 nodes against 78 wires;
- k=20: hits the 3000-node budget (117 wires), 8 loose leaves.
Growth is about 2^{0.7k}, although C is 1/2-dense. The output is still tight ([0.50036, 0.50075] at k=20), which shows the tree-size condition is sufficient but not necessary.
(b) A read-once AND of 8 blocks (a AND b) OR (c AND d) (ro.py). With the default small-cone (R8) rewriting: 8 MC leaves and interval [0.951, 1.035]*p. With R8 off: exact, 41 nodes, no leaves.

## Findings

### 1. [critical] sec-part1.tex, sec:part1-limits, sentence 'so no general procedure beats sampling by more than a factor 2^{o(log(1/p))} on the satisfiable ones' (and the preceding 'under the exponential-time hypothesis')

**Problem.** The conclusion does not follow from ETH and is false. ETH only says 3-SAT needs time 2^{cn} for some unspecified c>0. That bounds the cost from below by p^{-c}, not by p^{-1+o(1)}. Known algorithms refute the claim outright: plain clause branching (x1=1 | x1=0,x2=1 | x1=0,x2=0,x3=1) counts 3-SAT models exactly in O*(1.8393^n), and published #3SAT algorithms reach about 1.64^n. That is a sound procedure, complete on all 3-CNFs. On a uniquely satisfiable 3-CNF (p=2^{-n}) Monte Carlo costs about 2^n eps^-2 log(1/delta), so the speed-up is (2/1.8393)^n = p^{-0.12}, which is 2^{Theta(log 1/p)}, not 2^{o(log 1/p)}. Separately, the procedures are randomized, so the hypothesis needed is randomized ETH, not ETH as defined by Impagliazzo-Paturi.

**Proposed fix.** Replace with: 'Under randomized ETH, no sound procedure that is complete on satisfiable 3-CNFs runs in time 2^{o(n)}poly(|C|). In particular none has cost 2^{o(log(1/p))}poly(|C|), i.e. subexponential in the surprise. (Run it with a time cut-off and answer SAT iff L>0.)' If an 'at most a 2^{o(n)} speed-up' statement is wanted, it needs randomized SETH and CNFs of unbounded width. Even then it bounds the speed-up by 2^{o(n)}, not by 2^{o(log 1/p)}.

### 2. [major] sec-part1.tex, Corollary cor:dfsb(a), 'This includes ... read-once compositions F(lambda_1,...,lambda_t) of arbitrary K-dense circuits'; also (b) 'm_K(C)=O(1)' and the AND-of-blocks example

**Problem.** The rules run in the order T,F,D,S,E,B, so (D) is applied before the density test (S). A K-dense lambda_i whose top gate is a decomposable OR gets split, and its component-tree leaves can be arbitrarily rare. Then the hypothesis of (a) fails and m_K is not O(s). Counterexample: C = y OR mu (t=1, F = identity, lambda = y OR mu is 1/2-dense), with mu a rare non-decomposable circuit. The component tree has leaf mu with D(mu) tiny, and T*_K contains the whole branching tree of mu. Measured with the repository's DFSB (K=4, envelopes off), mu = planted system of k/2 XOR equations of weight k/2: 225 nodes at k=12 (48 wires), 1537 at k=16 (78 wires), and over 3000 at k=20 (117 wires), about 2^{0.7k}. With mu a PRG-preimage circuit, a polynomial m_K(mu) would contradict prop:worstcase(b). The same issue breaks (b): if C|_F is (D)-decomposable, the tree is not O(1). With j AND-parts the cost picks up d=j. With OR-parts it can be exponential.

**Proposed fix.** Either (i) restrict the claim: '...of K-dense circuits lambda_i whose own component trees have all leaves of probability >= 1/K (e.g. lambda_i not decomposable after forcing)', and in (b) assume C|_F is not (D)-decomposable. Or (ii) change the algorithm: apply (S) before (D) at OR nodes, with (D)-AND still first, and re-prove (a). Option (ii) keeps exactness for read-once formulas only if (S) is skipped at nodes all of whose children are exactly computable.

### 3. [major] sec-part1.tex, sec:dfsb Phase 1/Phase 2 description and Theorem thm:dfsb (cost); used by Theorem thm:meta ('runs in polynomial time')

**Problem.** Phase 2 is said to estimate 'every leaf' to relative accuracy eps/(3d), but nothing is specified for the 'loose' leaves created when the node budget is exceeded. It also puts no cap on the sequential stopping rule. A loose leaf, or a leaf wrongly accepted on the pilot-failure event, can have density about p, so Phase 2 runs for about 1/p samples. As written, DFSB is therefore not 'efficient' in the sense of Def. def:sound on every circuit, and thm:meta's polynomial-time claim does not follow. The code does cap (max_leaf_samples, and 10^5 for loose leaves), but the paper does not say so. Separately, for envelope leaves with boxes (R7), Phase 2 re-estimates the box masses. The pilot's acceptance therefore does not certify looseness at most 16K for the proposal actually used.

**Proposed fix.** Add to the algorithm: each leaf runs the doubling stopping rule of thm:envelope(iv) up to a cap N_max = c*16K*(3d/eps)^2*(log(l/delta)+loglog K). If it has not stopped by then, it outputs its current KL interval, which is valid because the stage-wise intervals are simultaneously valid. Loose leaves get a KL interval from N_max Monte Carlo samples, or [0,1]. Then state the total running time as polynomial on every circuit. For box envelopes, either reuse the pilot's box estimates in Phase 2 or include the box-estimation error in the looseness bound (rho_max/rho_min).

### 4. [major] sec-part1.tex, rule (R8) 'replaced, before anything else, ... This makes every class above closed under local rewriting' versus Cor. cor:dfsb(a) 'read-once formulas (exactly)' and (c)

**Problem.** The scope of R8 is ambiguous: it is listed as an envelope rule but is said to apply 'before anything else' to make the DFSB classes closed. If it rewrites the circuit DFSB works on, it conflicts with the corollary. The reduced OBDD's NNF ((NOT v AND f0) OR (v AND f1), with f0 and f1 sharing variables and sub-diagrams) is non-decomposable, so DFSB turns such nodes into Monte Carlo leaves or branches on them. The OBDD variables also enter Conf(C). Measured with the repository code (small_cone=10, i.e. R8): the read-once formula AND_{j<=8}((a_j AND b_j) OR (c_j AND d_j)) gives 8 MC leaves and the interval [0.951, 1.035]*p, not an exact value. With R8 off it is exact. The blanket closure claim is also unproved and false for rewrites whose gadgets touch large-support sub-circuits. For example, A AND B -> (A AND B) AND (A OR B) destroys decomposability, and R8 cannot repair it.

**Proposed fix.** Make R8-OBDDs atomic: add to (T) 'h is an OBDD produced by (R8): exact value by one bottom-up pass'. Compute Conf(C) and the component tree with these gates as leaves. Then (a) and (c) survive with s counting the rewritten circuit. Restrict the closure claim to 'rewritings confined to cones of at most c log|C| variables'.

### 5. [major] sec-part1.tex, sec:modules, item 'Algebraic. Affine and degree-2 constraints over F_2 ... exact counting and sampling by Gaussian elimination and Dickson's normal form [ek1990]'

**Problem.** For a conjunction of several quadratic equations over F_2, even satisfiability is NP-complete (the MQ problem), and counting is #P-hard. Ehrenfeucht-Karpinski gives polynomial-time counting for a single degree-2 polynomial; affine constraints can be substituted into it. Read literally as 'systems of affine and degree-2 constraints', the module would make thm:meta complete on an NP-hard class. That contradicts prop:worstcase(a) unless NP is in BPP.

**Proposed fix.** State: 'an affine system together with at most one quadratic equation (equivalently, one quadratic form restricted to an affine subspace) under the uniform distribution: exact counting and sampling by Gaussian elimination and Dickson's normal form; products of such pieces on disjoint supports are usable as envelope pieces.'

### 6. [minor] sec-part1.tex, Corollary cor:dfsb(c) 'with K=1 DFSB is exact cutset conditioning: no sampling at all' and its proof 'two distinct tree nodes cannot carry the same NNF node and the same partial assignment'

**Problem.** (1) With K=1 the actual pilot accepts every node of density at least 1/(16K)=1/16. For example, (x OR y) AND (x OR z) has density 5/8 and can become an MC leaf. Even the ideal predicate D(h)>=1 turns non-literal tautological nodes into MC leaves. So DFSB with K=1 does sample. (2) Injectivity fails literally: an (F) node and its child h|_F carry the same original gate with the same Conf-assignment when F has no Conf variables. The map is at most 2-to-1 (unit propagation is idempotent), so O(s 3^r) still holds.

**Proposed fix.** Say 'DFSB with (S) and (E) disabled is exact cutset conditioning', or let (S) accept only nodes with D(h)=1 recognised syntactically. In the proof, map tree nodes to (gate or child-group, Conf-assignment, flag for force-wrapper) and note that the map is at most 2-to-1.

### 7. [minor] sec-part1.tex, Theorem thm:dfsb cost '... each costing O(|C|); the non-sampling work is O(m|C|)'; sec-setting.tex 'with at most two copies of every gate'

**Problem.** Several costs are not counted. Envelope leaves cost O(|C|+|Phi|) per sample, and |Phi| can be 2^r|C| after R4 Shannon expansions. Box envelopes cost O(LR max|B_j|) in expectation, plus box estimation. Building Phi_h at every node reaching (E) is extra non-sampling work. So is R8 tabulation (about |C|^{c+1}), as are failed-literal probing (O(n|C|) or more) and Gaussian elimination at the root. Also, the NNF of a circuit with XOR or threshold gates is not a two-copies-per-gate {AND,OR}-circuit. A fan-in-k XOR needs O(k) gates per polarity, and weighted thresholds need a DP over partial sums: pseudo-polynomial, or no small NNF at all (the code uses opaque nodes). DFSB, Conf(C) and the O(|C|) bounds all depend on this.

**Proposed fix.** State per-sample cost as O(|C|+|Phi_h|) (plus box costs). State non-sampling work as O(m(|C|+max_h|Phi_h|)) + O(|C|^{c+1}) + root preprocessing. In sec:setting, say the NNF has size O(|C|) for AND/OR/NOT/XOR circuits, and that threshold gates are expanded by a sum DP or treated as opaque leaves.

### 8. [minor] sec-part1.tex, sentence after thm:dfsb 'The class on which DFSB beats sampling is therefore {C: m_K(C) <= poly(|C|) for some K <= poly(|C|)}' and sec:part1 intro 'characterised by the size of a canonical explanation tree'

**Problem.** thm:dfsb gives only a sufficient condition. DFSB is tight on circuits with superpolynomial m_K, e.g. y OR mu above, where loose leaves under a rare OR-branch do not matter: at k=20 the output was [0.50036, 0.50075] with the budget exhausted. So the class is not 'characterised' by the tree. Also, a single polynomial-time procedure must fix K and m in advance (or double them with a split delta), so 'for some polynomial' needs fixed polynomials.

**Proposed fix.** 'DFSB with parameters K=K(|C|), m=m(|C|) (fixed polynomials) beats sampling on {C: m_K(C) <= m}; this tree-size condition is sufficient, not necessary.' Replace 'characterised by' with 'guaranteed by'. Optionally note that m_K is nonincreasing in K, so one large K suffices at cost proportional to K.

### 9. [minor] sec-part1.tex, Proposition prop:dnnf-env

**Problem.** (1) If (R6) fires on a sub-node (union-bound mass >1 inside the DNNF), the envelope is no longer the DNNF's own circuit. Then K is at most the expected ambiguity, not equal to it. (2) 'All DNNFs admit polynomial-time relative-error estimation' depends on thm:sis, which requires rational marginals and runs in time polynomial in their bit-length. That is not stated. (3) 'Circuits that (R1)-(R8) turn into a DNNF envelope E with D(E) <= Kp' needs K polynomial and no (R7) box leaves, since boxes are not DNNF.

**Proposed fix.** Write 'K <= E_D[phi | C=1] (equality if (R6) is not used)'. Add 'under product distributions with rational marginals, in time poly(|C|, n, max_i log b_i, 1/eps, log(1/delta))'. Add 'with K <= poly(|C|) and no box leaves'.

### 10. [minor] sec-part1.tex, Theorem thm:meta and its proof

**Problem.** (1) M is undefined. (2) If the intersection is empty (some interval invalid, probability at most delta), the output is unspecified. (3) DFSB's parameters K and m must be fixed polynomials for 'polynomial time' and for completeness on a fixed class. (4) The completeness probability is 1-delta/M-delta, not 1-delta. (5) Tightness of the intersection only follows if each module is complete in the Def. def:sound sense, U<=(1+eps)L. The unate module (thm:janson-general) outputs ratio e^{eps}>1+eps, so it must be run at eps'=ln(1+eps). (6) In the local-lemma item, 'the condition is syntactic' holds only under the uniform distribution. Under a general product D the LLL condition involves the clause violation probabilities.

**Proposed fix.** Define M as the number of procedures run. Output [0,1] on an empty intersection. Fix K=|C|^a and m=|C|^b. Run every module at a parameter guaranteeing U<=(1+eps)L. State completeness probability >= 1-delta-delta/M. In the LLL item add 'under the uniform distribution (in general: max violation probability times Delta^{c} <~ 1)'.

### 11. [minor] sec-part1.tex, sec:part1-limits, 'Distributed surprise' and 'Pseudorandom rarity' bullets

**Problem.** (1) 'p <= (7/8)^m' holds only in expectation (E p = (7/8)^m). For a given random formula, Markov gives p <= n(7/8)^m with probability 1-1/n, so K >= (8/7)^{m-n/3}/n w.h.p. (2) 'mixing ... that no polynomial-time test certifies' is unproved; it should be 'no known'. Exact Las Vegas samplers also exist beyond unate circuits, e.g. partial rejection sampling for extremal instances, so thm:cftp is one example, not the only one. (3) Prop. prop:worstcase(b) is about PRGs with 2^{(1-o(1))k} security. It says nothing about hash-function preimages.

**Proposed fix.** State the K bound w.h.p. with the Markov factor. Write 'no known polynomial-time test'. Drop 'hash functions', or state the needed assumption for them separately.

### 12. [minor] sec-part1.tex, sec:dfsb rule (F) and Definition of T*_K; sec:modules 'Bounded treewidth'

**Problem.** (1) The pruning argument ('continues identically') needs T*_K to be well defined. That requires deterministic tie-breaking in (B) and a rule for when unit propagation refutes h; in that case D(h)=0 and it should be a (T) leaf. Neither is stated. (2) The treewidth module uses a greedy elimination order, which carries no width guarantee. Completeness on tw=O(log|C|) needs the Bodlaender et al. 5-approximation actually to be run.

**Proposed fix.** Add: '(B) breaks ties by smallest index; if propagation derives a conflict, h is the constant 0.' In the treewidth item: 'use the order of the 5-approximate tree decomposition [bodlaender2016] (width <= 5tw+4), or the greedy order if it is narrower'.
