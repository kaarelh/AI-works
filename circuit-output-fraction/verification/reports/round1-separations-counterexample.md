# Round 1 referee report: separations (counterexample lens)

**Verdict.** contains false statements. The core constructions are correct: V_T soundness, the Valiant-Vazirani and Goldreich-Levin lower-bound separations, the canonical-pair equivalence for the [0,0] task, pad_a, the Corollary, UP cap coNP, both orientations of the NP-hardness barrier, and prSBP vs prMA. Two claims are stated more strongly than what is proved: (1) uniquely satisfiable circuits are 'certified exactly by one witness', which read literally implies coNP in MA; (2) 'the prover helps exactly when P is not weakly automatable' (also in the abstract, intro and README), whose 'only if' direction is proved only for the specific [0,0] task. The rest are minor precision fixes.

**What was checked.** I read sec-part2.tex in full (focus: sec:separations, lines 265-344), plus sec-setting.tex, sec-envelopes.tex, sec-limits.tex (thm:blackbox, thm:ma, the SBP remark), the abstract, the intro results paragraph, discussion open problem 4, refs.bib and the project README. I wrote a brute-force script, /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/sep_check.py, with exact Fraction arithmetic. It checks:
(i) pad_a: p = 2^{-n-a-1} for unsatisfiable C, and p >= 2^{-n-1} + 2^{-n-a-1} (ratio >= 1+2^a) for satisfiable C. Tested for n<=4, a<=3 on random solution sets; all pass.
(ii) C_u: p = 2^{-k-1}(1+[u in L]) for k<=5. This holds even when 0^k is a witness, so that hypothesis is redundant.
(iii) the gadget C(x,z) = (x=0^n and z=0) or (z=1 and psi(x)): unique solution iff psi is unsatisfiable, otherwise p >= 2x.
(iv) the Goldreich-Levin instance: (x,r) -> (pi(x), r, <x,r>) is injective and hits exactly half of {0,1}^{2n+1}, so p is in {0, 2^{-2n}}.
Arguments checked by hand and found correct:
- V_T soundness: a false bounded sentence has a true bounded negation, which T proves by Sigma_1-completeness; T would then be inconsistent.
- The Valiant-Vazirani step gives NP in RP, with delta amplified by the log(1/delta) efficiency.
- The Goldreich-Levin step: a predictor with advantage about 1/2 - delta.
- Both directions of the [0,0]-on-Z_P^m <-> randomized canonical-pair separator equivalence, including amplification and soundness on off-promise inputs.
- The pad_a separator: threshold U <= 2^{-n-1}; on Z, completeness within 2^a plus L <= p gives U <= 2^{-n-1}; on SAT, soundness gives U >= p > 2^{-n-1}.
- The PCIS certificate for pad_a: split on beta, exact subcube on one branch, refute on the other.
- UP cap coNP: deciding L needs completeness with eps < 1; the T-proof via uniqueness or disjointness instantiation.
- NP-hardness barrier orientation 1 is an AMA = AM protocol with success fractions >= (2/3)(1-delta) vs <= 1/3 + delta. Orientation 2 is Goldwasser-Sipser with tensoring for small gaps. Boppana-Hastad-Zachos gives the collapse.
- Universality 'iff prSBP in prMA'. Forward: the gap-gamma problem with gamma > c is in prMA. Backward: Merlin names j, Arthur runs the prMA protocol for (p >= 2^{-j}) vs (p <= 2^{-j}/gamma) and outputs L = 2^{-j}/gamma; this stays sound off-promise because there 2^{-j}/gamma <= p.
I could not re-read the cited abstracts: the web-search budget was exhausted and drops.dagstuhl.de did not resolve. The statements of Bonet-Pitassi-Raz 2000 (factoring Blum integers; no feasible interpolation and non-automatizability of TC0-Frege and of everything that p-simulates it), Krajicek-Pudlak 1998 (RSA, EF), Arteche-Carenini-Gray 2024 (LWE, no quantum weak automation of TC0-Frege), Pudlak 2003 (canonical pair p-separable iff weakly automatizable, deterministic), Atserias-Muller 2020 and Bohler-Glasser-Meister 2006 (oracle with SBP not in Sigma_2^p) are therefore checked from memory, and the findings flag where the paper's use differs from those statements. I did not edit any repository file.

## Findings

### 1. [major] sec-part2.tex, sec:separations, paragraph title 'Upper bounds: the prover helps exactly when P is not weakly automatable'; also main.tex abstract ('the prover's advantage for upper bounds is exactly the non-weak-automatability of its proof system'), sec-intro.tex l.106-108 ('exactly to the extent that...'), README 'Limits'

**Problem.** What is proved: for the single task 'output [0,0] on every C in Z_P^m' (and its padded version), a sound prover-free procedure exists iff (Z_P^m, SAT) is randomized-separable. The headline claims more, namely that if P is weakly automatable then the prover gives no upper-bound advantage at all. That direction is not argued and does not follow. The PCIS verifier gets more from the prover than refutations: it also gets the envelope E_j, the SUM/MONO decomposition and the SPLIT tree. Weak automatability only lets a procedure decide whether a given formula has a short P-refutation. It does not let the procedure find a hidden envelope. For example, given C => (x_A=a) or (x_B=b) with unknown blocks A, B, self-reduction by restriction blows up when the blocks are unknown. So a weakly automatable P does not obviously make the class K_P(m,K) of thm:certenv prover-free tractable.

**Proposed fix.** State the one-directional theorem. 'For the task of certifying p=0 on circuits with size-m P-refutations, a prover-free procedure exists iff (Z_P^m,SAT) is randomized-separable. Hence if P is not (randomized) weakly automatable, the prover strictly helps, even for positive, exactly certified p (pad_a).' Then say explicitly that whether weak automatability of P removes the prover's advantage on general envelope classes is open, because the prover also supplies the envelope. Change 'exactly' to 'at least' (or 'whenever') in the abstract, intro and README.

### 2. [major] sec-part2.tex, 'Lower bounds' paragraph: 'Uniquely satisfiable circuits have p=2^{-n}, certified exactly by one witness' and '...gives an average-case version with (1+eps)-tight certificates'

**Problem.** A witness certifies only the lower bound p >= 2^{-n}. The upper bound needs a proof of uniqueness, which is a coNP statement. Read literally, 'certified exactly' on all uniquely satisfiable circuits is false unless coNP is in MA. Counterexample: map a 3-CNF psi to C(x,z) = (x=0^n and z=0) or (z=1 and psi(x)), which is pad_0. If psi is unsatisfiable, C is uniquely satisfiable with p = 2^{-n-1}. If psi is satisfiable, p >= 2^{-n}. A sound MA system that certified p exactly (or within 1+eps, eps<1) on all uniquely satisfiable circuits would therefore put UNSAT in MA, as in thm:ma; brute force confirms the gadget. The same applies to the one-way-permutation instances. A two-sided certificate there needs a proof that pi is injective; this is available through V_T with T proving that pi is a permutation, but not from the witness alone. Also, 'p=2^{-n}' holds only under the uniform distribution. The lower-bound separation itself is unaffected.

**Proposed fix.** Write: 'Uniquely satisfiable circuits have p=2^{-n} under the uniform distribution, and one witness certifies the tight lower bound L=p.' For the OWP sentence write: '...an average-case version in which the witness certifies L=p exactly; two-sided certificates additionally need a proof that pi is injective (e.g. V_T with T proving pi is a permutation).' Optionally note that exact two-sided certification on all uniquely satisfiable circuits would give coNP in MA, via pad_0.

### 3. [minor] sec-part2.tex, Corollary cor:automatability and the sentence 'separability of the canonical pair is weak automatability of P [pudlak2003pairs]'

**Problem.** The corollary is true, but the chain of citations does not deliver it as written.
(a) Bonet-Pitassi-Raz's (BPR's) stated corollary is non-AUTOMATIZABILITY, which is weaker than non-WEAK-automatizability; it is not enough on its own. What is actually needed is BPR's failure of feasible interpolation: a disjoint NP pair with polynomial-size TC0-Frege proofs of disjointness that no polynomial-size circuit separates unless Blum integers can be factored. That fact, plus P's closure under restrictions (substitute x and the B-witness z into the refutation of A_n(x,y) and B_n(x,z)), reduces the pair to the canonical pair. It also directly gives the circuit family {pad_a(A_n(x0,.)) : x0 in B}.
(b) The paper uses RANDOMIZED separators. Pudlak's equivalence (separable iff weakly automatizable) is for deterministic polynomial time, and it uses the pair {(phi,1^m)} with m given in unary rather than a fixed polynomial m. Randomized procedures are covered only via Adleman's argument (fix the coins after amplification), which works because the hardness assumptions are against polynomial-size circuits.
(c) For the LWE part, the claim depends on Arteche-Carenini-Gray (ACG) giving an LWE-based pair with short TC0-Frege disjointness proofs that no quantum polynomial-time algorithm separates, together with the same restriction step.

**Proposed fix.** After 'Known results then give', add the chain. 'BPR (resp. KP98, ACG) construct a disjoint NP pair (A,B) with poly-size P-proofs of disjointness that is not separable by polynomial-size circuits (resp. quantum polynomial-time algorithms) under the stated assumption. Since P is closed under restrictions, x0 in B gives a size-m refutation of A_n(x0,.), and x0 in A makes A_n(x0,.) satisfiable. A randomized separator of (Z_P^m,SAT) can be fixed to a circuit (Adleman), so it would separate (A,B).' Replace 'is weak automatability' with 'is (a randomized analogue of) weak automatability [Pudlak 2003, deterministic version]', and note that only the easy direction is used.

### 4. [minor] sec-part2.tex, Corollary cor:automatability: '...and for extended Frege if RSA is secure [kp1998]'

**Problem.** The clause is redundant and uses a stronger assumption than needed. The separating family depends only on the pair, not on P. Extended Frege p-simulates Frege, which p-simulates TC0-Frege, so under the factoring-Blum-integers assumption the PCIS verifier with EF already certifies the same padded BPR family exactly. BPR state their result for every system that p-simulates TC0-Frege. RSA security is a stronger hypothesis than that factoring assumption.

**Proposed fix.** State: 'for every P that p-simulates TC0-Frege (Frege, extended Frege, ...) [bpr2000]'. Keep [kp1998] only as an alternative route to EF under RSA, if wanted. Also make 'RSA is secure' precise: 'against polynomial-size circuits'.

### 5. [minor] sec-part2.tex, 'A universal verifier' paragraph (V_T)

**Problem.** Three hypotheses are missing.
(1) 'Fix a consistent theory T' is not sufficient. Soundness uses Sigma_1-completeness and the provable equivalence of the formalised counting sentence with a bounded one. That needs T to contain enough arithmetic, e.g. IDelta_0+exp, or at least Q plus a Delta_0(exp) formalisation. Otherwise a consistent T, for instance one with no arithmetic axioms, can prove a false instance. 'Sound whenever T is' should say 'consistent'.
(2) V_T is polynomial-time only if the time bound t is bounded by the argument length (written in unary or capped).
(3) The p-simulation needs T to prove a runtime bound for the simulated verifier V'. If V' samples rational-marginal D by Las Vegas rejection sampling, its run truncated at t steps fails with extra probability. The instantiated sentence must then use delta_A = delta' + Pr[truncation], with a T-provable bound on that truncation probability.

**Proposed fix.** Write 'a consistent theory T extending IDelta_0+exp (e.g. ZFC)'. Require t <= |pi| (unary). Add: 'V_T p-simulates every argument system V' that T proves sound and clocked: with a T-provable time bound, or with a T-provable truncation-failure bound folded into delta_A.' Note that numerals are taken in binary, so that instantiated Sigma_1 facts have polynomial-size T-proofs (this also matters for the UP cap coNP paragraph).

### 6. [minor] sec-part2.tex, 'And for preimage circuits [G(x)=y] of pseudorandom generators ... so there the verifier cannot beat sampling for upper bounds either'

**Problem.** The proof-complexity-generator conjecture (Alekhnovich-Ben-Sasson-Razborov-Wigderson; Krajicek) says only that for y not in range(G) there are no short P-REFUTATIONS of C_y. That rules out the PCIS verifier certifying [0,0]. It does not rule out certifying a small but positive upper bound through an envelope, i.e. a short P-proof that C_y implies E for a tractable E with D(E) = n^{-omega(1)}, such as fixing j seed-related bits. 'Cannot beat sampling' needs exactly that stronger statement, which the cited works do not conjecture as such.

**Proposed fix.** Weaken to: '...short refutations of C_y (y not in range G) are conjectured not to exist in strong proof systems, so the verifier cannot certify p=0 there.' Or state the stronger hypothesis explicitly: 'no poly-size P-proof that C_y implies any envelope of mass n^{-omega(1)}'.

### 7. [minor] sec-part2.tex, 'Finding the short proofs is the hard part: even for resolution, finding a refutation of size polynomial in the shortest one is NP-hard [atserias2020automating]'

**Problem.** The paraphrase of Atserias-Muller is fair, but in context it suggests more than it gives. Their reduction maps formulas to formulas that are all unsatisfiable, separating short from long refutations. It says nothing about (Z_Res^m, SAT), so it does not imply that resolution fails to be weakly automatable. As the preceding paragraph shows, a prover-free procedure needs only weak automatability, not proof search. So no separation for PCIS with resolution follows. Weak automatability of resolution is open (Atserias-Maneva link it to mean-payoff games).

**Proposed fix.** Add: 'This concerns automatability. Whether resolution is weakly automatable, which is what the canonical-pair criterion requires, is open, so no prover/no-prover separation for resolution follows.'

### 8. [minor] sec-part2.tex, 'Why not NP-hardness?' paragraph, final sentence ('So upper-bound and two-sided separations must come from structured, non-NP-hard assumptions'); also sec-intro.tex l.108-109

**Problem.** Both orientations are argued correctly for RANDOMISED MANY-ONE reductions: orientation 1 gives an AMA = AM protocol, orientation 2 gives coNP in AM via Goldwasser-Sipser, and either way PH collapses by Boppana-Hastad-Zachos. The conclusion 'must' is unconditional, however. For promise problems, NP-hardness under adaptive Turing reductions does not give such collapses: Even-Selman-Yacobi give an NP-hard promise problem in prNP cap prcoNP. So the barrier does not exclude a separation derived from NP not in BPP through a Turing reduction.

**Proposed fix.** Write 'must, as far as (randomised) many-one or non-adaptive reductions go, come from...', and in the intro write 'cannot be based on NP-hardness under many-one reductions unless coNP in AM'.

### 9. [minor] sec-part2.tex, 'Two-sided, exact' paragraph

**Problem.** The identity p(C_u) = 2^{-k-1}(1+[u in L]) is correct (brute-force verified). The hypothesis '0^k never a witness' is unnecessary, because the two disjuncts are separated by beta. 'A Task-1 procedure complete on {C_u} decides L' needs completeness for some eps < 1, because the two values differ by a factor of 2. The decision rule is 'L_out > 2^{-k-1}', and it errs with probability at most 2*delta. The factoring instance needs ZFC to prove AKS correctness and unique factorisation, which it does, and the V_T proof to be polynomial-size, which holds with binary numerals.

**Proposed fix.** Drop '0^k never a witness' (or explain it). Add 'complete with some eps<1 (output u in L iff the lower end exceeds 2^{-k-1})'. Optionally note that the pad_a family of cor:automatability already gives exactly certified two-sided values on the unsatisfiable side, so the UP cap coNP construction is needed for completeness on BOTH sides of the promise.

### 10. [minor] sec-part2.tex, 'Universality' paragraph; inconsistency with sec-limits.tex (paragraph after thm:ma: 'is exactly a proof that the class SBP ... is contained in MA')

**Problem.** The 'iff prSBP in prMA' claim in Part 2 is correct. Forward: the gap problem with gap > c is in prMA. Backward: Merlin names j, Arthur runs the prMA protocol for p >= 2^{-j} vs p <= 2^{-j}/gamma and outputs L = 2^{-j}/gamma, which stays sound off-promise. sec-limits, however, states the equivalence for the language classes (SBP in MA); that inclusion is implied by, but not known to imply, the promise version. The oracle claim is stated without justification. It follows from Bohler-Glasser-Meister's oracle with SBP not in Sigma_2^p (recalled from memory), together with MA in Sigma_2^p, which relativizes.

**Proposed fix.** In sec-limits replace 'SBP is contained in MA' with 'prSBP in prMA (which implies SBP in MA)'. In Part 2 add: 'this fails relative to an oracle (Bohler-Glasser-Meister construct one with SBP not in Sigma_2^p, while MA in Sigma_2^p relativizes)'.

### 11. [minor] sec-part2.tex, canonical-pair sentence '(if it outputs [0,0], the circuit cannot be satisfiable, by soundness; conversely run the separator)' and the definition of Z_P^m

**Problem.** (a) 'Cannot be satisfiable' holds only with probability 1-delta, and only if the procedure is run with a full-support D (e.g. uniform). Under a product D with some q_i in {0,1}, a satisfiable C can have p_D(C)=0, so [0,0] is then correct. (b) Z_P^m should read 'a P-refutation of size at most m(|C|)'. The canonical pair with a fixed polynomial m differs from Pudlak's pair {(phi,1^m)}; they are equivalent only for P that tolerates padding with small overhead. (c) The PCIS certificate for pad_a(C) refutes the beta=0 restriction of pad_a(C), whose Tseitin encoding is not literally that of C. P must be closed under restrictions and weakening for C's refutation to transfer. (d) 'Task-1 procedure' is never defined; it means a prover-free procedure in the sense of Def. def:sound.

**Proposed fix.** Write 'the separator runs the procedure under the uniform distribution and answers SAT unless U=0; by soundness it errs on satisfiable C with probability at most delta'. Write 'of size at most m(|C|)'. Add 'P closed under restrictions (true for resolution, cutting planes, (TC0-)Frege, EF)'. Replace 'Task-1 procedure' with 'prover-free procedure (Def. def:sound)'.

