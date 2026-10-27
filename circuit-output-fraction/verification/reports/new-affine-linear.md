# New results: affine-linear

## Integration report

I added the affine and linear-threshold topic as three new paper files (a Part-1 subsection, a Part-2 subsection, an appendix), a code module with 26 brute-force tests, and an experiment (about 90 s on one core).

Paper:
- **Part 1** (`p1-affine.tex`, label `sec:affine`):
  - certified affine gates (sparse ANF with a cap; solved form x_i XOR G(x_{-i}) certified through a symbolic ANF over opaque sub-circuits);
  - the exact affine/triangular presolve (Prop. `prop:presolve`), including biased pivots. It is compared with DFSB's rule (F), which keeps only the forced literals, so a rank-r system with no unit rows explains 0 bits there and r bits here;
  - affine-union envelopes by abstract interpretation (Thm. `thm:affenv`) and XOR-DNNF envelopes (Prop. `prop:xordnnf`);
  - the parity barrier (Thm. `thm:parity-barrier`) with corollaries for generalised Hamming weights and random parity checks (`cor:random-parity`), and `cor:barrier-methods`, which states what this means for the envelope estimator, the #DNNF route, context width and DFSB;
  - the bounded-width dynamic program for any product distribution (Prop. `prop:bw-dp`);
  - NP-hardness and MA-incompleteness of tiny parity circuits under Bern(1/3) (Thm. `thm:biased-hard`);
  - linear thresholds: the known product-measure FPTAS (Prop. `prop:ltf`), Karp-Luby-Madras unions, affine AND one threshold at bounded width (Prop. `prop:affine-ltf`), and non-closure (Prop. `prop:nonclosure`);
  - Fourier and degree facts (Prop. `prop:fourier`), an experiments table (`tab:affine`), and open questions.
- **Part 2** (`p2-xpt.tex`, label `sec:xpt`): XOR-propagation-tree arguments (Thm. `thm:xpt`), presented as an instance of the PCIS certified-envelope rule with a parity-capable proof system. They add something over PCIS in two ways: affine pieces under product distributions, and splits on gates that expose affine structure hidden behind threshold gates (experiment E5).
- **Appendix** (`app-affine.tex`, label `app:affine`): full proofs.

I re-derived every included result and corrected several constants and statements from the source drafts. The check of what Gopalan, Klivans, Meka, Štefankovič, Vempala and Vigoda cover was done against the paper's own text, which states they count knapsack solutions under all symmetric and product distributions (Sec. 3.2).

Code (`rareprob/affine.py`): GF(2) affine subspaces in echelon form, ANF certification, the AND-spine, the presolve, the abstract interpretation, a Karp-Luby-Madras estimator with outward rounding, the linear-order dynamic program for product distributions with an exact sampler, the XPT verifier and an honest prover, and connectivity utilities. Every returned interval is valid on every circuit:
- a subspace whose dynamic program exceeds the width cap is replaced by its implied constraints on uniform coordinates (a superset);
- malformed or unrefuted closed XPT leaves become open leaves;
- when the sample budget runs out the result is [0, U] with a certified U.

Not done, or done differently:
- I made no edits to shared files; everything needed elsewhere is in `external_edits`.
- I made no git changes. An orchestrator snapshot commit (07:02) already contains early versions of my code files, so `git status` shows them as modified.
- The scratch build used other agents' current files, which have 6 undefined citations of their own (`bodlaender1996`, `greenhill2000`, ...). My files have no errors, no undefined references and no overfull boxes.

- Certified affine gates (sparse ANF with a cap on nonlinear monomials) and solved-form certificates (symbolic ANF with opaque sub-circuits as symbols); testing-is-unsound remark (proved here): The ANF is exact by uniqueness, and substitution is a Boolean-ring homomorphism. The remark is an instance of thm:blackbox.
- Prop. prop:presolve: exact affine/triangular presolve, p = M E_D[W] with W in [0,1]; p = 2^-k D(R~) for uniform pivots; rho^-k bound for near-uniform pivots (proved here): Unifies affine RREF rows and solved-form conjuncts as triangular constraints, and is compared with DFSB's rule (F). Gaussian elimination and definability-based elimination are cited as known ingredients (Lagniez-Lonca-Marquis 2016). The measure-preserving-flip remark is stated only under uniform D, because coordinate permutations need equal marginals; the code detects only the one-round case.
- Thm. thm:affenv: affine-union envelopes by abstract interpretation, with the Karp-Luby-Madras estimator, sound on every circuit (proved here): The bound K <= L/min_j Pr[R_j | V_j] is stated only when the R_j are opaque; with coarsening, the general case has no guarantee. Product distributions are handled through prop:bw-dp, or by relaxing to the constraints on uniform coordinates.
- Prop. prop:xordnnf: XOR-DNNF envelopes (decomposability replaced by linear independence of form spaces) with exact mass and exact sampler under uniform D (proved here): Implemented only through its special case, affine unions. Related work cited: affine decision trees (Koriche et al. 2013).
- Thm. thm:parity-barrier: (a) |G| K >= c 2^lambda_bal for smooth DNNF-structured envelopes with leaves of support <= 2n/3; (b) |G|^2 D(E)/p >= c 2^lambda_bal for Boolean DNNFs, and |G| >= c 2^lambda_bal when E implies V; smoothing to at most (n+2)(S+2) nodes (proved here): The rectangle-cover case (E = C) is known (Duris et al. 2004; Bova et al. 2016). New here: the envelope tradeoff, the Boolean-envelope version and the connectivity parametrisation. The smoothing bound replaces the draft's 3nS+O(n).
- Cor. cor:parity-ghw (lambda_bal >= m - 2j* via generalised Hamming weights) and Cor. cor:random-parity (random H with m <= n/6: probability >= 1-2^{1-n/6} that lambda_bal >= m-12) (proved here): Union bound over 7-dimensional subspaces and sets T, re-derived; shown not to need full rank, which is used only for p = c 2^-m.
- Cor. cor:barrier-methods: consequences for the envelope estimator, the #DNNF route, context width and DFSB (weakened): Constants now carry a factor n from smoothing, and the results are stated with Omega. Within a polynomial factor of Monte Carlo only for (i) the per-sample-evaluating estimator, (iii) context width and (iv) DFSB; for any use of a DNNF envelope only the square-root bound holds. The DFSB part applies to trees built with (T),(F),(D),(B) whose leaves have density >= 1/K' with K' < 2^{m-6} (including the ideal tree), using a new lemma that dense leaves of support > 2n/3 are impossible. Trees with (E) leaves are not covered. The Omega(K log(1/delta)/eps^2) sample lower bound for the KL procedure is proved.
- Prop. prop:bw-dp: smooth deterministic DNNF with at most 2n(4^w+1) gates; exact D(V) and sampler under any product D; lambda_bal <= w (proved here): The gate count is corrected from the draft's 2n 4^w. The dynamic program is folklore-level, and Hlineny-Oum is cited for finding decompositions. Implemented for linear orders, with live states checked to be <= 2^lambda_t in the tests.
- Thm. thm:biased-hard: under Bern(q), q != 1/2, the copies gadget makes factor-2^g approximation NP-hard (coset weight); factor 2^{N^{1-gamma}} gives NP in BPP; complete MA arguments give coNP in MA (proved here): The gap is stated with explicit k >= (n+2g+3)/log2((1-q)/q), and the MA protocol with an explicit threshold theta/2. The reduction is from Berlekamp-McEliece-van Tilborg 1978. For s = 0 the ferromagnetic-Ising landscape is cited: Jerrum-Sinclair 1993 (graphic), Goldberg-Jerrum 2013 (regular matroids), and Goldberg-Jerrum JCSS 2013 for binary matroids, quoted only as 'no FPRAS under a complexity-theoretic assumption'.
- Prop. prop:ltf: deterministic FPTAS for a single LTF under any product D, with an exact rejection-corrected sampler (known (Gopalan-Klivans-Meka-Stefankovic-Vempala-Vigoda, FOCS 2011, Sec. 3.2)): Checked against the paper's text, which says they count knapsack solutions under all symmetric and product distributions. A self-contained dynamic program and the exact sampler are proved in the appendix.
- Karp-Luby-Madras estimator with certified lower masses: mean in [e^{-eps'}p, p], looseness <= e^{eps'}T for unions of LTF-and-subcube pieces (proved here): Folklore given prop:ltf. A prototype number from the design record (OR of 5 LTFs) was not reported because it is not reproducible from the published code.
- Prop. prop:affine-ltf: [Ax=b] AND [w.x <= theta] at linear width w0: FPTAS in O(n^3 2^{w0} b/eps) under any product D, plus an exact sampler (proved here): New as far as we know (simple). Not implemented.
- Prop. prop:nonclosure: two LTFs, affine AND LTF, threshold of parities (NP-complete to decide p > 0); [|Hx|<=t] (factor below 2 is NP-hard); hence no complete sound procedure or complete upper-bound MA system (known (standard reductions; Berlekamp-McEliece-van Tilborg 1978, Vardy 1997)): Assembled as a non-closure map, together with the list of tractable compositions.
- Prop. prop:fourier: (a) sparsity k gives p >= 1/k; (b) F2 or real degree d gives p >= 2^-d; (c) one quadric inside an affine space has Pr in {0} U [1/4,1]; plus the dual-estimator remark (proved here): Textbook facts. (c) is proved by squaring the bias rather than through Dickson's normal form. Green-Sanders 2008 is cited for bounded spectral norm.
- Thm. thm:xpt: XPT arguments are sound for every circuit, product D and argument; complete with time poly(|pi|) + O(K eps^-2 log(1/delta))(|C| + t n^2) (proved here): Presented as an instance of PCIS's certified-envelope rule. Closed leaves whose refutation fails are downgraded to open, and malformed nodes become open leaves. Threshold gates get a sound backward-propagation rule.
- Draft Result 6.3 (packing intersections of k LTFs, Dyer-type) (dropped): Not needed for the narrative and probably known (Dyer 2003 extension).
- Draft Result 8 (Fourier cross-rank lemma and XOR-DNNF lower-bound conjecture), and the product-measure version of the barrier (dropped): Kept only as open question (1) in the section. The product-measure barrier is not stated, so the paper relies only on what is proved for uniform D.

## Referee report

**Verdict.** I re-derived the mathematics and it largely holds. That covers the presolve identity and the rho bound, Thm affenv(a)-(c), the XOR-DNNF mass and sampler, the coset lemma, Thm parity-barrier(a),(b) with the (n+2)(S+2) smoothing bound, Cor parity-ghw and Cor random-parity (the 2^{n+7m-7n/3} union bound), the constants in Cor barrier-methods, Prop bw-dp (2n(4^w+1)), Thm biased-hard (the k threshold, the 2^{-2g-3} gap, the BPP/MA reductions and the q>1/2 complement), the LTF dynamic program and rejection sampler, the nonclosure reductions and the Fourier facts. Every number in tab:affine and in the text matches affine_log.txt, and a fresh run reproduces them (67 s on this machine).

The implementation, however, does not meet the claim that every interval is valid on every circuit and every argument. Four failures reproduce:
- **Critical:** a malicious XPT argument makes the verifier output [0,0] for p=1/8.
- A threshold gate with real weights makes XPT propagation infer a false value.
- A malformed linear order crashes the verifier, and under python -O gives a wrong interval.
- Floating-point underflow makes the presolve return [0,0] for p=2^-1100, and makes subnormal masses miss p for a 650-literal AND under Bern(1/3).

On the paper side, the novelty claim for prop:affine-ltf is an immediate instance of Theorem 3.6 of the cited GKMSVV paper. There are also several smaller wording and hypothesis problems, listed below.

### 1. [critical] code/rareprob/affine.py:1064-1079 (_well_formed) and 1047-1053 (_apply); paper p2-xpt.tex Thm xpt(a)

**Problem.** An XPT form split accepts any integer constant c. _well_formed only checks that int(sp[2]) parses, and _apply then calls S.add(mask, branch ^ c), which stores rhs in {2,3} or a negative value. Propagation then yields gate 'values' such as 2 and -1 and declares false contradictions; packed membership treats any nonzero rhs as 1. Reproduced: for C = NOT x0 AND x1 AND x2 (p = 1/8, uniform), the argument {"split":["form",[0],2],"children":[{"leaf":"open"},{"leaf":"open"}]} closes both children, and xpt_verify returns [0,0] in 20 of 20 runs. The same happens under Bern(0.3) and with c = -1. A malicious prover therefore defeats soundness deterministically, contradicting Thm xpt(a) ('for every ... string pi') and the module docstring.

**Proposed fix.** In _well_formed, require sp[2] to be the integer 0 or 1 and sp[1] to be a list of ints; otherwise treat the node as an open leaf. Defensively, use c & 1 in _apply. Make Affine.add raise on rhs not in {0,1}. Add regression tests with c=2 and c=-1.

### 2. [major] code/rareprob/affine.py:1032-1039 (Propagator, THR backward rule)

**Problem.** The backward threshold inference compares hi - |w_i| < t and lo + |w_i| >= t. These are recomputed floating-point expressions, not the float sum that Circuit.eval evaluates, and floating-point addition is not associative. With real weights this infers false values. Reproduced: C = THR([x0,x1],[1.0,1e-17], t=1e-12+5e-18) AND x2 has p = 3/8. Here fl(1+1e-17)-1 = 0 < t', so propagation forces x0 = 1 at the root and drops the satisfying inputs with x0 = 0. xpt_verify returns [0.249, 0.250]. Circuits allow real threshold weights (circuit.py: 'real weights'; sec-setting does not restrict them), so the verifier is unsound on such circuits for every argument, including the trivial one. The forward rule is sound because rounded addition is monotone.

**Proposed fix.** Compute each backward bound as a fresh sum in child order with the child fixed at its bad or good value, exactly as Circuit.eval sums (this is monotone, hence sound). Alternatively use fractions.Fraction for weights and thresholds, or enable THR inference only for integer weights whose sums are below 2^53. Add the counterexample as a test.

### 3. [major] code/rareprob/affine.py:637 (LinearOrderDP assert), 768-782 (make_pieces), 1109 (orders taken from pi); p2-xpt.tex lines 78-80

**Problem.** Prover-supplied linear orders are not validated. A non-permutation order (duplicates, missing coordinates, or non-integers) raises AssertionError, IndexError or ValueError, so the verifier outputs no interval. This contradicts the docstring ('malformed parts only loosen the envelope') and the text ('a bad order costs time but never soundness'). Under python -O the assert disappears: with C = [x0+x1=1] AND [x2+x3=1], q = 0.3 and order [0,0,2,3], the DP processes coordinate 0 twice and never sets x1. The verifier returns [0.0863, 0.0935] while p = 0.1764. stats.py explicitly avoids relying on asserts for this reason. A non-dict root or an argument deeper than Python's recursion limit also crashes xpt_check.

**Proposed fix.** In make_pieces (or Piece), validate that the order is a permutation of range(n) given as ints, and otherwise use the identity order or relax the piece. Replace the assert with an explicit check that raises TooWide. Wrap the processing of prover data in xpt_verify so that any exception downgrades to an open leaf or a relaxed piece. Make walk iterative, and treat a non-dict root as an open leaf.

### 4. [major] code/rareprob/affine.py:595-597 (presolve_estimate M), 747 (Piece closed-form mass), 716 (LinearOrderDP mass), 802 (klm eta)

**Problem.** Floating-point underflow breaks the claim 'every interval valid on every circuit' on natural circuits, deterministically. (1) presolve_estimate on the AND of 1100 literals under the uniform distribution (p = 2^-1100 > 0, a 2^-Omega(n) instance in the paper's own scope) computes 2.0**log2_M = 0 and returns [0,0]; the 'certified' bound p <= M becomes p <= 0. (2) When a mass is subnormal, the relative error far exceeds eta = 8(n+T+4)2^-53. For the AND of k literals under Bern(1/3), affine_envelope_estimate misses p for k = 650, 660 and 675 (e.g. k = 650: interval [7.3914e-311, 7.43334743490e-311] against p = 7.43334743497e-311). The log-domain sums for log2_M and log_scale also carry errors proportional to |log M| that rel and eta do not account for.

**Proposed fix.** Carry M and the piece masses as log2 values in Estimate, or detect values below sys.float_info.min. In Piece and LinearOrderDP raise TooWide (and so relax), and in presolve_estimate return [0, 2^-1022] or the bound in log2 form instead of 0. Widen intervals by the absolute subnormal error of 2^-1074, and scale the rounding allowance with |log2 M| and |log_scale|. Add tests at ranks 1100 and 650.

### 5. [major] paper/p1-affine.tex lines 341-351 (prop:affine-ltf, 'As far as we know this combination has not been stated before')

**Problem.** The novelty claim is contradicted by the cited GKMSVV paper. Its Theorem 3.6 approximates Pr_D[M=1] for any monotone ROBP M (such as a knapsack/LTF) under any small-space source D of width S, in time O(n^3 S(S+log W) log(n/delta)/delta). Under a product distribution, D conditioned on {Ax=b} with lambda_t <= w_0 along the order is a width-2^{w_0} small-space source: the states are the live syndromes, and the transitions are proportional to D_t times the suffix masses. So D(C) = D(V) * Pr_{D|V}[w.x <= theta] has a deterministic FPTAS immediately, with D(V) from Claim 3.4. Their proof of Thm 1.2 (multidimensional knapsack, using a uniform-over-ROBP-set source by Claim 3.5) has exactly this form.

**Proposed fix.** Attribute the result: 'follows from [gopalan2011fptas, Thm 3.6 with Claims 3.4-3.5], since D|V is a width-2^{w_0} small-space source'. Present the direct DP as giving 2^{w_0} rather than 4^{w_0} dependence plus an exact sampler, and drop the novelty sentence.

### 6. [minor] paper/p1-affine.tex lines 241-245 (cor:barrier-methods(iv)); app-affine.tex lines 162-177

**Problem.** The hypothesis 'leaves h all have D(h) >= 1/K'' with 'in particular the ideal tree T*_{K'}(C)' is inconsistent. The ideal tree has constant-0 leaves (from (F) conflicts and refutations, D = 0) and (T') atom leaves of arbitrary density, and the theorem's rule list (T),(F),(D),(B) omits (T'). The proof only needs density for leaves with more than 2n/3 variables.

**Proposed fix.** State: 'every tree built with (T),(T'),(F),(D),(B) in which every leaf with more than 2n/3 variables has D(h) >= 1/K' (K' < 2^{m-6}), in particular T*_{K'}(C) when a <= 2n/3'. Mention (T') atoms in the DNNF conversion.

### 7. [minor] paper/p1-affine.tex lines 5-9 and 249-251

**Problem.** The opening claim that 'every DNNF-type envelope, and with it DFSB ... costs at least the square root of what Monte Carlo costs' and that DFSB costs 'Monte Carlo's price up to a polynomial factor' goes beyond (iv). Part (iv) covers only trees without (E) leaves (the author's own note) and only DFSB's completeness guarantee via thm:dfsb. It says nothing about DFSB runs with (E) leaves whose envelopes have large boxes. Every statement also carries a factor c (or c^2) that the opening paragraph omits.

**Proposed fix.** Rephrase as 'DFSB's completeness guarantee (trees with (T),(T'),(F),(D),(B) and dense large leaves) needs ...'. Add 'for c = Pr[C|V] bounded below' or keep the c factors explicit.

### 8. [minor] paper/p1-affine.tex lines 162-165

**Problem.** '1_{Hx=s} ... while DNNFs need size 2^{lambda_bal}' drops the smoothing loss. Thm parity-barrier(b) bounds |G| for smooth fan-in-two DNNFs; a general DNNF with S wires only needs (n+2)(S+2) >= 2^{lambda_bal}, i.e. S >= 2^{lambda_bal}/(n+2) - 2. The bound also assumes literal (small-support) leaves.

**Proposed fix.** Write 'DNNFs with literal leaves need at least 2^{lambda_bal}/(n+2) - 2 wires', or say 'size 2^{lambda_bal}/poly(n)'.

### 9. [minor] paper/p1-affine.tex lines 323-328 (prop:ltf) and app-affine.tex lines 233-245

**Problem.** The claim of 'O(n^3 b/eps) operations on numbers of poly(n,b,log(1/eps)) bits' is not supported by the proof. G_i takes exact values Q^j with Q = 1+eps/(2n) and j up to O(n(nb+1)/eps), and such rationals have Theta((n^2 b/eps) log(n/eps)) bits, i.e. polynomial in 1/eps. Exactness of the rejection step also uses these exact values.

**Proposed fix.** Either state poly(n,b,1/eps)-bit numbers (still an FPTAS), or add a rounding analysis: represent H_i in floating point with O(log(nb/eps))-bit mantissas, round down onto a (1+eps/(4n)) grid, and absorb the arithmetic error into Q.

### 10. [minor] paper/p1-affine.tex lines 422-428 ('E3 shows the barrier')

**Problem.** E3 has n=36 and m=12 > n/6, so the event of cor:random-parity, on which cor:barrier-methods is stated, does not apply. Even using Thm parity-barrier directly with lambda_bal <= 12, the DFSB bound c 2^{lambda_bal}/(n+6)^2 <= 0.36*4096/1764 < 1 is vacuous. The DFSB failure at a 400-node budget is an illustration, not an instance of the theorem.

**Proposed fix.** Say 'E3 illustrates the behaviour predicted by the barrier at a size where DFSB can run', and avoid implying that the theorem's bound is attained.

### 11. [minor] paper/p1-affine.tex lines 419-421; experiments/exp_affine.py lines 281-299, 340-356, 390

**Problem.** The text says 'Exact values come from closed forms checked independently of the code', but only E1, E2 and E4 have such closed forms. E5's truth uses certified_affine and Affine.meet from the module under test. E6a's truth is a sum of LinearOrderDP masses, and E6b's 'exact p' is LinearOrderDP itself, the same DP that the evaluated 'affine envelope + DP' rows use. 'Every interval contained the exact p' is therefore not an independent check for E6, since the DP is brute-force tested only at n=11.

**Proposed fix.** State which ground truths come from the module, or add an independent check: a separate Fraction-based transfer-matrix implementation, or a scaled-down E6 instance verified by brute force.

### 12. [minor] paper/p2-xpt.tex lines 10-12 and 44-49 (Def xpt, Thm xpt(b))

**Problem.** The ANF cap T is part of the argument and the verifier's time is poly(|pi|,|C|,n,T). If T is written in binary, a prover can force verifier time exponential in |pi|. The bound also drops the log log K term of thm:envelope(iv), whose sample count is O(K(log(1/delta)+log log K)/eps^2).

**Proposed fix.** Require T in unary or cap it at a fixed poly(|C|) (the code already uses a verifier-side anf_cap), and restore the log log K term.

### 13. [minor] paper/p1-affine.tex lines 117-121 (thm:affenv(b)); code affine.py:923-930

**Problem.** 'prop:bw-dp gives D(V) and exact samples when V has a narrow linear order' reads as if the procedure finds such an order. affine_envelope_estimate only tries the input order (orders=None) and otherwise relaxes the piece. Finding a narrow linear order (matroid path-width) is not known to be efficient in general; Hlineny-Oum finds branch decompositions, which are trees.

**Proposed fix.** Say 'when the input order (or a prover- or heuristic-supplied order) has width <= the cap', and note that the implementation uses the input order.


## Referee report

**Verdict.** The mathematics mostly holds up. I re-derived the coset lemma, the parity barrier (a)/(b) with the smoothing count, the GHW and random-parity corollaries, the constants in cor:barrier-methods, prop:bw-dp, thm:biased-hard, prop:nonclosure, prop:fourier, the LTF dynamic program with its rejection sampler, and the union-with-approximate-masses lemma, and found no false theorem. The code does not meet its stated guarantee that every returned interval contains p on every circuit. There are three concrete failures. (1) The XPT propagator reasons about threshold gates in floating point. The trivial one-leaf argument on THR([x0..x3],[1e17,3,3,-1],5) returns [0.497,0.500] although p=0.625. (2) Leaf orders supplied by the prover are checked only by an assert. A malformed order crashes the verifier, and under `python -O` it yields an interval that misses p. (3) presolve_estimate's factor M underflows to an interval of [0,0] once log2 M < -1074. Smaller floating-point margins (rel, eta) are not proven bounds and are exceeded on natural instances, by about 1e-11 relative. The text has several minor overclaims: gadget certification, the 'smallest DNNF' sandwich, the c-dependence of the barrier consequences, E3 presented as showing the barrier, and ground truths described as 'independent of the code'. Every number in tab:affine and in the text matches affine_log.txt and affine.json, and the E6 ground truths are correct, which I checked with an independent implementation.

### 1. [major] code/rareprob/affine.py:1018-1039 (Propagator.run, THR branch); claim in xpt_verify docstring and thm:xpt(a)

**Problem.** Threshold propagation is done in floating point and does not match the evaluator. The backward rules `hi - abs(wi) < t` and `lo + abs(wi) >= t` lose precision when weights differ widely in magnitude. As a result the propagator forces children to values that some satisfying inputs do not take, and the pieces stop dominating C. No adversarial prover is needed: the trivial argument {"leaf":"open"} fails. Counterexamples: C=THR([x0,x1,x2,x3],[1e17,3,3,-1],5) has exact p=0.625, but xpt_verify returns [0.4972,0.5000] because x0 is forced to 1, although (0,1,1,0) and (0,1,1,1) satisfy C even in exact integer arithmetic. C=THR([x0,x1,x2],[1e6+0.1,0.3,0.3],0.6) has p=0.625; XPT returns [0.4972,0.5000]. With random real weights of mixed magnitude, 1 in 3000 random circuits loses satisfying points. Separately, the forward rule uses Python 3.13's compensated `sum`, while Circuit.eval adds sequentially in numpy. For NOT(THR([x0,x1,x2],[1e16,1,-1e16],0.5)) with form splits on x0, x1, x2, XPT refutes x=(1,1,1) and returns [0.490,0.512], while the evaluator, exact_prob and the KLM sampler all use p=0.625. The tests use only small integer weights, so none of this is caught.

**Proposed fix.** Define THR semantics exactly: convert each float weight and the float t-1e-12 to fractions.Fraction, or use integer weights, and use the same exact arithmetic in both Circuit.eval and the propagator's lo/hi and backward rules. Alternatively, make an inference only when it holds with a rigorous rounding margin, e.g. require hi - |w_i| < t - (k+2)*ulp(sum|w|), and never use Python's sum where the evaluator sums sequentially. Add tests with real weights of mixed magnitude (1e6 + 0.1, 1e17) and with the trivial one-leaf argument.

### 2. [major] code/rareprob/affine.py:636-637 (LinearOrderDP order check), 1106-1109 (xpt_check passes node.get('order') through unchecked), 768-782 (make_pieces catches only TooWide); p2-xpt.tex:78-80

**Problem.** The order supplied by the prover is validated only by `assert sorted(order) == list(range(n))`. In normal runs a malformed order ([0]*n, n+1 entries, 'abc') crashes xpt_verify with AssertionError or ValueError instead of being treated as a malformed part. Under `python -O` the assert disappears and the DP is run on a non-permutation. Example: C=[x0+x1+x2=1] AND [x3+x4+x5=0] under q=(.3,.2,.25,.1,.4,.35), argument {"leaf":"open","order":[0,0,0,0,0,0]}: the interval is [0.1485,0.1541], but p=0.2306. stats.py explicitly guards against -O for this reason. Further crashes: a non-dict root ([], None, a string) raises AttributeError at node.get, and arguments deeper than about 1000 levels raise RecursionError. The text says 'a bad order costs time but never soundness'. In fact a malformed order crashes or is unsound under -O, and a merely wide order costs tightness, through relaxation, not time.

**Proposed fix.** In xpt_check, accept an order only if it is a list of exactly n distinct ints in range(n), and otherwise set it to None. Replace the assert with an explicit check that raises TooWide, which is caught. Treat a non-dict node as an open leaf (check isinstance(node, dict) before .get). Make walk iterative. Reword p2-xpt to say a bad order costs tightness or time, and add a test with malformed orders and malformed roots.

### 3. [major] code/rareprob/affine.py:594-618 (presolve_estimate: M_lo/M_hi = 2.0**P.log2_M*(1±rel), and the inner path)

**Problem.** M is formed as 2**log2_M with no protection against underflow. When log2_M < -1074, M_hi becomes 0 and the estimator returns [0,0], a false certificate that p=0. Examples: C = AND of 1100 positive literals under uniform D (p=2^-1100>0) gives presolve_estimate [0.0, 0.0]; C = AND of 2000 negative literals under Bern(0.45) also gives [0,0]. The affine-envelope path handles this case (rank >= 1020 is relaxed to FULL), but the presolve path does not.

**Proposed fix.** Keep M as a (mantissa, exponent) pair or in log2 domain, and return log-domain bounds. At least never output hi=0 unless the presolve is infeasible: clamp hi to max(hi, math.ulp(0.0)) when log2_M is finite, or return [0, 2**max(log2_M,-1074)] with a note. Apply the same fix to the `inner` path.

### 4. [minor] code/rareprob/affine.py:595-597 (rel = 4(n+2)2^-53 for M), 677-716 (LinearOrderDP log_scale via math.log/exp), 802 (eta = 8(n+T+4)2^-53 in klm_estimate)

**Problem.** The floating-point widening constants are not proven bounds and are exceeded on natural instances, so intervals miss p deterministically, though only by about 1e-13 to 1e-11 relative. (a) Biased presolve: C = AND of 1000 literals NOT x_i under Bern(0.3) gives [1.24618e-155, 1.2532566400e-155], while p = 0.7^1000 exactly, so hi/p - 1 = -7.9e-12. The cause is summing 1000 log2 terms near -514 and exponentiating, which gives error around 1e-11 against rel around 4.4e-13. (b) LinearOrderDP mass: on banded parity events (n=400, m=150, Bern(0.002-0.004)) the DP's relative error is 1.2 times eta (checked with exact Fractions). affine_envelope_estimate, whose upper end is Z(1+eta) when K=1, returned hi below p by 1.9e-13 to 2.7e-13 relative in 3 of 5 instances, e.g. [8.5527e-139, 8.601294184489e-139] against p=8.601294e-139.

**Proposed fix.** Normalise the DP by exact powers of two (math.frexp/ldexp), so that rescaling introduces no error, and derive a per-state relative bound such as (2t+1)u at position t; then set eta from it. Compute M as a product with exact exponent tracking, with error at most (k+1)u, or in Fraction or interval arithmetic. Alternatively widen by a deliberately generous margin (e.g. 1e-9 relative), which costs nothing statistically. Add a regression test using the AND-of-literals and banded-DP instances, with exact Fraction ground truth.

### 5. [minor] paper/p1-affine.tex:23-24 ("XOR gadgets of ∧,∨,¬ on k inputs are certified with T=O(k)")

**Problem.** This holds only for chain (left-deep) gadget trees, where OR(a,b) produces k-1 nonlinear monomials. For a balanced gadget tree the root's OR(a,b) contains about (k/2)^2 cross monomials, so T = Θ(k^2) is needed. With the defaults (T=64, work=8192), balanced gadgets on 32 or 64 inputs are not certified while chains are. Chains on 128 inputs also fail, because of T and because of the undocumented `work` cap on |a|·|b|.

**Proposed fix.** State: 'chained XOR gadgets on k inputs are certified with T = k-1; balanced gadget trees need T = Θ(k^2)'. Also mention the work cap on products, and that sub-ANF caps are the limitation (open question 4).

### 6. [minor] paper/p1-affine.tex:272-275 (sandwich bound after prop:bw-dp)

**Problem.** 'The smallest smooth DNNF for 1_V with fan-in-two ∧-gates has between 2^{λ_bal(V)} and 2n(4^{bw}+1) gates' is false as written. The paper's definition of a smooth DNNF allows leaves that are arbitrary functions of their declared supports, so the single leaf 1_V is a smooth DNNF of size 1. The lower bound from thm:parity-barrier(b) needs leaves of support at most 2n/3. In addition, λ_V here lacks the +1 of the usual matroid connectivity function, so 'branch-width' is off by one relative to the standard convention (Hliněný–Oum).

**Proposed fix.** Add 'with literal leaves (or leaves of support at most 2n/3)'. Define bw(V) := min over rooted binary trees with leaf set [n] of max_t λ_V(X_t), and note that this is the matroid branch-width minus 1.

### 7. [minor] paper/p1-affine.tex:5-9 and 249-251 (summary of the barrier); cor:barrier-methods

**Problem.** The informal summaries say DNNF-type methods cost 'at least the square root of Monte Carlo' and 'Monte Carlo's price up to a polynomial factor', and that the cost 'stays exponential in the surprise'. The proved bounds are Ω(c^2/(np)), Ω(c/(n√p)) and similar, with c = Pr[C|V]. They match these summaries only when c ≥ 1/poly(n). For c = 2^{-m/2}, for example, c^2/p = p^{-1/3} and c/√p = p^{-1/6}, and the surprise log(1/p) = m + log(1/c) is not captured. The summaries also omit that the statement holds with high probability over H and needs m ≤ n/6.

**Proposed fix.** Add the hypotheses to both summaries: 'for random H with m ≤ n/6 (w.h.p.) and events C ⊆ {Hx=s} with Pr[C|V] ≥ 1/poly(n)'. Replace 'exponential in the surprise' with 'exponential in m'.

### 8. [minor] paper/p1-affine.tex:423-427 (E3 'shows the barrier'); tab:affine E3 rows

**Problem.** E3 has n=36 and m=12, which violates cor:random-parity's hypothesis m ≤ n/6 (= 6). The corollary's bound c·2^{m-12} = c is then vacuous, and part (iv) for DFSB relies on that corollary's event. DFSB's poor result on E3 is therefore not an instance of the theorem. DFSB was also slower than plain Monte Carlo there (3.7e7 bit-parallel evaluations at about 2e8 per second is 0.17 s, against DFSB's 71 s), so the experiment reflects overhead as much as any barrier.

**Proposed fix.** Rephrase to 'E3 illustrates DFSB on a dense parity event'. Alternatively compute λ_bal(V) for E3's H (or a lower bound via cor:parity-ghw) and quote the resulting bound from thm:parity-barrier(a)/(b), or choose parameters with m ≤ n/6 and m > 12.

### 9. [minor] paper/p1-affine.tex:419-421 ('Exact values come from closed forms checked independently of the code'); experiments/exp_affine.py e5/e6

**Problem.** Only E1, E2 and E4 have ground truths independent of affine.py. E5's exact p uses the module's own certified_affine and Affine.meet. E6a's p and E6b's 'truth' are computed with LinearOrderDP, the same dynamic program the affine envelope uses to get its masses. My independent computations, an exact-rational sweep DP for E6a and coset enumeration for E6b, agree to 7e-17 and 7e-14 respectively, so the numbers are right, but the sentence overstates the independence.

**Proposed fix.** Compute the E5 and E6 ground truths with independent code: GF(2) rank with gf2_rank on the raw rows for E5, a Fraction sweep DP for E6a, and coset enumeration via p=(1-q)^N Σ λ^{|y|} for E6b. Otherwise restrict the sentence to E1, E2 and E4.

### 10. [minor] paper/p1-affine.tex:323-328 (prop:ltf, 'operations on numbers of poly(n,b,log(1/ε)) bits'); app-affine.tex:233-254

**Problem.** The appendix's construction rounds to G_i = Q^{⌊log_Q H_i⌋} with Q = 1+ε/(2n), and its sampler is made exact by accepting with probability Q^{-(n-1)}/∏ r_i, where r_i = G_i/H_i. Exponents reach O(n^2 b/ε). Computing ⌊log_Q H⌋ and r_i exactly therefore involves rationals of poly(n,b,1/ε) bits, not poly(n,b,log(1/ε)) bits. The stated bit-length bound is not justified by the given proof, although it may be achievable with directed rounding and lazy comparisons.

**Proposed fix.** Either state 'numbers of poly(n,b,1/ε) bits', or add the argument: keep G_i as integer exponents, compute H_i with downward-rounded O(log(nb/ε))-bit floats, so that G ≤ H ≤ Q^2 G and the error budget is adjusted, and implement the exact rejection step by lazily refined comparisons.

### 11. [minor] paper/p1-affine.tex:238-240 (cor:barrier-methods (iii)); app-affine.tex:160-161; also (iv) at 241-245

**Problem.** (iii) uses O(|C|·cw·2^cw) wires, but thm:cw bounds the DNNF in terms of |N|, the size of the NNF. |N| = O(|C|) only for {∧,∨,¬,⊕} circuits. Threshold gates expand to O(kW) wires or become frontier leaves, possibly of large support, which (b) does not allow. In (iv), the ideal tree T*_{K'} also contains (T') atom leaves and (S) leaves, which are not among the rules (T), (F), (D), (B) listed in the statement.

**Proposed fix.** In (iii) write |N| and require the DNNF of thm:cw to have literal leaves (no frontier gates). In (iv) add (T') to the list of rules, noting that atom leaves have support a ≤ 2n/3, and say explicitly that (S) leaves fall under the density hypothesis.

### 12. [minor] paper/p1-affine.tex:395-398 (proof of prop:fourier(b))

**Problem.** The induction applies the claim to G = C(·,1) - C(·,0). G is not Boolean: over R it takes values in {-1,0,1}. So the hypothesis 'p ≥ 2^{-d}' for Boolean C is applied to a non-Boolean polynomial. The argument is correct only if the inductive statement is Pr[f ≠ 0] ≥ 2^{-deg f} for every nonzero multilinear polynomial f.

**Proposed fix.** State and prove the general claim, 'for every nonzero multilinear f over F_2 or R, Pr_x[f(x) ≠ 0] ≥ 2^{-deg f}', and deduce (b) with f = C.


## Fixes

I fixed every finding from both referees. All four code failures (one critical) now return valid intervals. The paper overclaims, the novelty claim and the hypothesis problems are corrected. Experiment ground truths are now computed independently of affine.py, and the experiment was rerun: every number is unchanged and only the timings moved.

**Code: `code/rareprob/affine.py`**
- **XPT split parsing.** A new `parse_split` checks every field the prover sends. A form split's constant must be the integer 0 or 1, and its indices must be integers in range; anything else makes the node an open leaf, which is always sound. `Affine.add` now raises on a right-hand side outside {0, 1}.
- **Threshold propagation.** It now uses `thr_sum`, which adds in the same left-to-right floating-point order as `Circuit.eval_packed` and compares with t - 1e-12. Rounded addition is monotone, so with finite weights the forward and backward rules hold for the function the evaluator actually computes. A child that appears twice is handled by a relaxation, and infinite or NaN weights only allow forward evaluation with all children known.
- **Malformed arguments.** Orders are validated by `valid_order`, and the assert is gone; an invalid order is ignored and the identity order is used. The tree walk no longer recurses, a root that is not a dict becomes an open leaf, and `xpt_verify` falls back to the whole cube if anything unexpected happens.
- **Floating point.**
  - The presolve factor M is now a renormalised product carried as mantissa and binary exponent, with error at most gamma_{2k}; logarithms are no longer used.
  - The dynamic program renormalises each level by an exact power of two, carries the mass as mantissa and exponent, and has a proved error bound of gamma_{5n+5}. It raises `TooWide` (so the piece is relaxed) if any state leaves the normal range.
  - The KLM estimator scales masses by a common power of two and computes the cumulative selection sums exactly. A piece more than 2^1000 times lighter than the largest is not sampled; its mass is added to the upper end.
  - The widening terms tau and eta are now proved bounds, and every interval is rounded outward. An upper end below 2^-1074 becomes the smallest positive double, with log2 bounds in the note, instead of 0.
- I also made a small speed fix: a singleton list no longer computes the canonical key, which cut a 1100-literal AND from 30 s to 0.03 s.

**Paper**
- **`p1-affine.tex`:**
  - The barrier summaries now carry their conditions: m <= n/6, high probability over the checks, c >= 1/poly(n), plus an example of how the bounds weaken for smaller c.
  - Gadget certification is stated precisely: chains need T = k-1, balanced trees need floor(k/2)ceil(k/2).
  - thm:affenv(b) now describes how orders are used.
  - The DNNF lower bound now includes the smoothing loss and the leaf-support condition.
  - cor:barrier-methods (iii) uses |N|, requires no frontier gates, and gives the explicit constant. Part (iv) has the corrected hypothesis (rules (T), (T'), (F), (D), (B); density only for leaves with more than 2n/3 variables; the ideal tree when the atom size a <= 2n/3), and its wording says it is about the completeness guarantee only.
  - The branch-width sandwich now has the leaf condition and a definition of bw (matroid branch-width minus one).
  - prop:ltf now says rationals of poly(n, b, 1/eps) bits.
  - prop:affine-ltf is attributed to GKMSVV Thm. 3.6 with Claim 3.4 (checked against the paper's text), and the novelty sentence is gone.
  - prop:fourier(b) is now proved for every nonzero multilinear polynomial.
  - E3 is described as an illustration, not an instance of the theorem. The experiments paragraph says how each ground truth is computed, adds a paragraph on floating-point soundness, and the table timings are updated.
- **`p2-xpt.tex`:** T is a verifier parameter given in unary; affine forms carry a constant bit; malformed nodes and bad orders are described accurately; the log log K term is restored.
- **`app-affine.tex`:** the proofs of (iii) and (iv) are adjusted, and the bit lengths in the LTF proof are justified.

The scratch build (`affine_build2`) has no LaTeX errors, and nothing from my files is overfull or undefined. The 6 undefined citations and the 3 overfull boxes come from other agents' files and `sec-envelopes.tex`.
