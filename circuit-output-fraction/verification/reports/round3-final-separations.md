# Final referee report: separations

**Verdict.** sound with minor fixes

**What was checked.** Scope. I read p2-sep.tex (l.1-266) in full, line by line, together with the material it depends on: sec-setting.tex (def:sound, def:argument), sec-limits.tex (prop:worstcase, thm:blackbox, thm:ma, the prSBP remark), p2-pcis.tex (def:pcis, thm:pcis-sound, thm:certenv), p2-lower.tex (witness lists), the abstract, the intro results paragraph (l.146-156), the discussion (l.17-19, open problems 4-5), the README Limits paragraph and l.56, and the refs.bib entries for every key cited in p2-sep. I also read verification/raw/round1_fixes_and_rereviews.json['separations'] for context.

Re-derivations (Lens A).
(1) V_T. If T is consistent and proves every true Delta0(exp) sentence, any Delta0(exp) sentence it proves is true, so V_T is sound. The [0,1] output on timeout is harmless. The unary t makes the run polynomial. p-simulation works by instantiating a T-proof of the clocked soundness of V'. The kp1989 analogy is apt.
(2) Valiant-Vazirani. O(n) restrictions give a uniquely satisfiable one with probability at least 3/4. With delta = c/n, a union bound bounds the false positives, which gives a BPP gap. The pad_0 argument gives coNP in MA for any certification factor below 2.
(3) One-way permutation. p(C_y) = 2^{-2k}[b = <x0,r0>]. The predictor succeeds with probability 1/2 + (alpha - beta)/2 with beta <= delta, so alpha <= delta + negl.
(4) pad_a. p = q + D(beta=0) p_D(C) holds for every product D. Under the uniform distribution p = 2^{-n-a-1} + s 2^{-n-1}. The bound (1+eps)p < tau holds iff eps < 2^a, and p >= tau on SAT.
(5) prop:canonical. (a) and (b) hold in both directions, including soundness off the promise and on 0/1 marginals. For (c), I rebuilt the SPLIT/EXACT/REFUTE certificate in resolution: O(n+a) steps for the two subcube implications, and O(1) steps to reach [C=1] on the beta=0 branch.
(6) Pudlak's deterministic equivalence. Separator to Q: a Q-proof of F is 1^m with S(F,1^m)=REF, which needs deterministic checking, as the text says. The slice reduces to the pair and back for the systems of (c). If prBPP=prP the 'exactly when' claim follows.
(7) Hard slices. Restriction by (u,z0), the short proof of the closed formula psi(u,z0), the Tseitin transfer and Adleman all check out.
(8) The cor:automatability proof chain checks out.
(9) Two-sided. p(C_u) = 2^{-k-1}(1+[u in Lambda]). The rule L > 2^{-k-1} with eps < 1 errs with probability at most 2 delta. Both T-theorems are needed and are used correctly.
(10) NP-hardness. Orientation 1 is AMA = AM. Orientation 2 is Goldwasser-Sipser after k = O(1/(gamma-1)) copies. Both lead to the BHZ collapse.
(11) Universality. Forward direction: 2^{-k(j+1)} <= 2^{-kj}/c. Backward direction: j = floor(log2(1/p)) + 1 gives 2^{-j} < p <= 2^{1-j}, so the factor is 4. Taking the root of a conjunction of O(1/eps) copies brings this to 1+eps.

Citations (web search; direct fetches failed DNS).
- Pudlak 2003, Corollary 2 (weak automatability iff p-separability of the canonical pair) is confirmed via Atserias-Mueller's citation.
- BGM's oracle with SBP not in Sigma_2^p is confirmed.
- ACG: no quantum weak automation of TC0-Frege under LWE is confirmed. The paper's non-claim of the quantum corollary is accurate as stated: separator-to-automation needs deterministic checking.
- The BPR abstract matches: no feasible interpolation for TC0-Frege/Frege unless Blum integers can be factored.
- The Atserias-Mueller statement matches.

Brute force (Lens B). /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/sepfinal/check_math.py uses exact Fractions to check:
- the pad_a identities for n<=3, a<=2 under uniform, random and 0/1 marginals;
- pad_0;
- the one-way-permutation values for k=2,3 with random permutations;
- the j-choice for about 1000 rationals;
- the VV repetition count, the tensoring count and the Goldreich-Levin algebra.
All pass, except that it confirms the k=0 degeneracy for c=1 (finding 3).

Code. The code implements only the ENVELOPE rule; there is no REFUTE, SPLIT or EXACT, and sec-experiments says only 'envelope arguments'. I emulated prop:canonical(c) through it with /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/sepfinal/check_code.py. It covers pad_a of random dense CNFs (mostly unsatisfiable, some satisfiable) under uniform, biased and extreme {0, 1, 1e-3, .5} marginals, each with a subcube envelope plus an honest DRUP proof, a forged proof or a garbage proof, and a ZERO envelope as REFUTE. Result: 480 verifier runs, 0 intervals missing the brute-force p. Honest intervals are tight (for example [7.598e-6, 7.629e-6] for p = 2^-17). For n+a+1 = 1111 the interval degrades to [0, 2e-323]: sound, but not the exact [q,q] of the rational-arithmetic verifier in the paper, and the paper does not claim the code does this.

Experiment numbers. p2-sep.tex contains none.

No repository file was edited.

## Audit of earlier findings

resolved: 21

- [resolved] (major) proof#0: 'prover helps exactly when P is not weakly automatable' (header, abstract, intro): The header is now 'Upper bounds on refutable circuits' (p2-sep l.53). prop:canonical proves the one-directional statements. l.117-138 states Pudlak's equivalence as deterministic, proves the slice<->pair reduction for the systems of (c), and asserts 'exactly when' only under prBPP=prP. The K_P(m,K) case is stated as open (l.139-143; open problem 5). The abstract (l.36-38: 'strictly helps ... whenever slices ... are not separable in randomized polynomial time'), the intro (l.146-154) and README l.23 no longer say 'exactly'.
- [resolved] (major) proof#1: citation chain behind cor:automatability missing (BPR/KP98/ACG, restriction, Adleman, Tseitin): The 'Hard slices' paragraph (l.145-167) supplies every link: the disjoint NP pair with short P-refutations of phi AND psi, closure under restrictions, the formula-to-Tseitin transfer, the reduction u -> F_u (citing razborov1994pairs and pudlak2003pairs), Adleman's argument, and BPR's failure of feasible interpolation for polynomial-size circuits. EF and Frege are covered via p-simulation of TC0-Frege, with KP98 kept only as the historical route. The ACG quantum clause is withdrawn with an accurate reason (l.186-191). The corollary proof is written out (l.179-184).
- [resolved] (minor) proof#2: V_T hypotheses (unary t, Sigma1-completeness, Delta0(exp), clocked p-simulation): l.3-20: t is written in unary; T proves every true Delta0(exp) sentence (consistent extensions of IDelta0+exp, ZFC); the sentence is Delta0(exp); soundness goes through consistency. p-simulation is defined by an explicit polynomial-time map for V' whose clocked soundness T proves as one universal sentence, with binary numerals. A remaining gap about the polynomial-time axiomatization of T is new finding 1.
- [resolved] (minor) proof#3: uniquely satisfiable circuits 'certified exactly by one witness': l.26-28 now reads: under the uniform distribution p=2^{-n} and one witness certifies the tight lower bound L=p. l.34-38 adds that certification within a factor below 2 would put coNP in MA via pad_0, and I re-derived that argument.
- [resolved] (minor) proof#4: one-way-permutation sentence imprecise: l.40-51: the permutation is renamed f; the instance distribution and p(C_y)=2^{-2k}[b=<x0,r0>] are stated (brute-force confirmed for k=2,3); the Goldreich-Levin predictor and the bound delta+negl(k) are given; two-sided certificates need a proof that f^{-1}(f(x0))={x0}.
- [resolved] (minor) proof#5: canonical-pair paragraph (Task-1 undefined, uniform D, 'at most', strict threshold, slice vs Pudlak pair): 'Task-1' is gone. Both converses run the procedure under the uniform distribution (l.94, l.104). Z_P^m uses 'size at most m(|C|)' (l.55). The threshold is the strict tau=2^{-n-1}(1+2^{-a}) with eps<2^a (l.105-107). The slice reduces to Pudlak's pair (l.123-124), and the converse via C_F padded to size >= k is proved for the systems of (c) (l.124-130).
- [resolved] (minor) proof#6: two-sided exact paragraph (0^k hypothesis, eps<1, canonical encoding): l.207-222: the 0^k hypothesis is dropped (p value brute-force checked for every witness position). The rule 'u in Lambda iff L>2^{-k-1}' with eps<1 has error at most 2 delta. The canonical, sorted, padded factorisation with AKS primality makes the witness unique.
- [resolved] (minor) proof#7: NP-hardness barrier too broad (many-one vs Turing, non-monotone): l.224-242 is restricted to randomized many-one reductions with gamma >= 1+1/poly. It cites AMA=AM (babai1985), describes the tensoring for orientation 2 and the middle-band case, and says adaptive reductions are not covered. The intro (l.154-156) and the README match. A small residual gap in the case enumeration is new finding 4.
- [resolved] (minor) proof#8: Atserias-Mueller paraphrase; proof-complexity-generator conclusion: l.193-198 states the time bound (polynomial in |F| and the shortest refutation, unless P=NP), notes that this concerns automatability, and says weak automatability of resolution is open, so no separation follows. l.199-205 weakens the conclusion to 'cannot certify p=0 by REFUTE' and states the stronger envelope hypothesis as a necessary condition.
- [resolved] (minor) proof#9: universality paragraph (proof, oracle, derandomisation, sec-limits prSBP): l.248-266 gives both directions: the conjunction amplification, and the scale j with an MA proof (factor 4), then 1+eps via roots. It gives the oracle (BGM SBP not in Sigma_2^p, which I confirmed; MA in Sigma_2^p relativizes) and MV2005 for prAM=prNP. sec-limits l.125-133 now uses prSBP in prMA. A trivial k>=1 edge case is new finding 3.
- [resolved] (major) cex#0: 'exactly' overclaim (section, abstract, intro, README): Same as proof#0: the section, abstract, intro, discussion and README all now state 'strictly helps whenever slices are not separable'. 'Exactly' appears only conditionally on prBPP=prP, with the converse proved (l.130-138).
- [resolved] (major) cex#1: 'certified exactly' for uniquely satisfiable circuits; OWP two-sided needs injectivity: l.26-38 restricts the claim to the tight lower bound and adds the coNP in MA consequence via pad_0. l.49-51 requires a proof that f^{-1}(f(x0))={x0} (for example the instance of a T-proof of injectivity). p=2^{-n} is stated under the uniform distribution.
- [resolved] (minor) cex#2: corollary chain (non-automatizability vs non-weak-automatizability; randomized vs deterministic Pudlak; LWE): The text uses BPR's failure of feasible interpolation, not non-automatizability (l.162-165). Pudlak's equivalence is explicitly deterministic (l.120-122, l.137-138). Randomized separators go through Adleman (l.159-161). The LWE/quantum analogue is explicitly not claimed (l.186-191).
- [resolved] (minor) cex#3: EF clause under RSA redundant / stronger assumption: cor:automatability (l.169-177) covers TC0-Frege, Frege and EF under the Blum-integer assumption alone, via p-simulation (l.166-167). KP98 appears only as the earlier construction. README l.56 still credits KP for EF; this is wording only and is noted in new finding 6.
- [resolved] (minor) cex#4: V_T missing hypotheses (theory strength, unary t, T-provable truncation): (1) T proves all true Delta0(exp) sentences. (2) t is in unary. (3) Truncation is covered because T must prove soundness of V' clocked at t' (l.14-20). The polynomial-time axiomatization of T is still missing; see new finding 1.
- [resolved] (minor) cex#5: PRG preimage circuits 'cannot beat sampling for upper bounds': l.199-205 now claims only that PCIS cannot certify p=0 by REFUTE under the generator conjecture. It states that excluding small positive upper bounds needs the stronger hypothesis 'no short C_y |-_P G for envelope circuits G of mass n^{-omega(1)}', and I checked that this is necessary.
- [resolved] (minor) cex#6: Atserias-Mueller does not give weak-automatability separation: l.196-198: 'This concerns automatability; prop:canonical needs only separability of the slices ... whether resolution is weakly automatable is ... open, so no separation for resolution follows.'
- [resolved] (minor) cex#7: NP-hardness barrier unconditional 'must' (Turing reductions): l.239-242: 'cannot be derived from NP-hardness by randomized many-one reductions (adaptive reductions to the gap problem are not covered)'. The intro (l.154-156) has the same qualification.
- [resolved] (minor) cex#8: two-sided paragraph (0^k, eps<1 rule, factoring proof needs): l.207-222 drops 0^k, gives the eps<1 threshold rule with error 2 delta, and specifies the canonical encoding, AKS and that ZFC proves both theorems. The optional pad_a remark was not added, which is acceptable.
- [resolved] (minor) cex#9: universality / sec-limits language-class mismatch, oracle justification: sec-limits l.126-130 says prSBP in prMA ('in particular it would give SBP in MA'). p2-sep l.259-261 justifies the oracle by BGM's SBP not in Sigma_2^p plus the relativizing MA in Sigma_2^p.
- [resolved] (minor) cex#10: canonical sentence (uniform D for procedure->separator, 'at most', fixed m vs Pudlak pair, transfer to pad_a, Task-1): (a) Both converses use the uniform distribution (l.94, l.104). (b) The text says 'at most m(|C|)', and the fixed-m slice is related to Pudlak's {(phi,1^k)} pair in both directions (l.123-130). (c) prop:canonical(c) is restricted to resolution, CP and the Frege-type systems, and its proof derives [C=1] in O(1) steps before reusing C's refutation (l.109-114). (d) 'Task-1' is replaced by 'sound efficient procedure without a prover'.

## New findings

### 1. [minor] paper/p2-sep.tex l.3-6 and l.10-11 (universal verifier V_T)

**Problem.** V_T must check a T-proof in time polynomial in the argument length. That needs T's axiom set (or proof relation) to be decidable in polynomial time. The text allows 'any consistent extension of IDelta_0+exp'. This includes non-recursively-axiomatized extensions, such as true arithmetic, whose proofs V_T cannot check at all. For those the claims 'in time polynomial in the length of the argument' and 'p-simulates' fail. (ZFC is also an extension only via its interpretation of arithmetic.)

**Proposed fix.** Write: 'Fix a consistent theory T, with a polynomial-time decidable set of axioms, that proves every true Delta_0(exp) sentence; for instance any such extension of IDelta_0+exp, or ZFC via its standard interpretation of arithmetic.'

### 2. [minor] paper/p2-sep.tex l.149-152 (Hard slices: 'passes from a refutation of a formula to one of its Tseitin encoding ... as TC^0-Frege ... do'), l.79-84 (prop:canonical(c)); the definition of F |-_P bot in p2-pcis.tex l.16-19

**Problem.** Tseitin(C) is never defined for threshold (or XOR) gates. The TC^0-Frege case of cor:automatability uses BPR formulas whose F_u contain threshold connectives. It relies on 'deriving the equivalence of each gate variable with its subformula', which presupposes an encoding that defines threshold gate variables. The implementation's cnf.tseitin leaves THR gates unconstrained ('a relaxation'). Under that encoding, a circuit whose unsatisfiability rests on a threshold gate has no refutation at all, so F_u would not lie in Z_P^m. The parenthetical claim for TC^0-Frege therefore depends on an unstated choice of encoding.

**Proposed fix.** In sec:pcis, define Tseitin for threshold gates. For TC^0-Frege, use either the equivalence g <-> Th_k(children) in P's language, or a counter CNF whose correctness TC^0-Frege proves in polynomial size. Alternatively, say in 'Hard slices' that for Frege and EF, F_u is the {and,or,not}-circuit of the translated formula, with threshold connectives replaced by polynomial-size NC^1 formulas, and state which encoding is used for TC^0-Frege. Add one sentence noting that the code's relaxed encoding is not the one meant here.

### 3. [minor] paper/p2-sep.tex l.250-253 and l.257-259 (Universality)

**Problem.** (i) 'k >= log_2 c runs' allows k=0 when c=1, i.e. lower-bound completeness with no loss. The empty conjunction then has p(C)=1 on both yes- and no-instances, and the yes-condition p(C) > 2^{-kj} = 1 fails. My brute-force check confirms the degenerate case. (ii) 'taking the corresponding root of L' produces an irrational number in general, while the verifier must output a rational bound.

**Proposed fix.** Write 'k >= max(1, ceil(log_2 c))'. Write 'the k-th root of L, rounded down to a rational of polynomial bit length (still at most p, since L_k <= p^k)'.

### 4. [minor] paper/p2-sep.tex l.224-238 ('Why not NP-hardness?')

**Problem.** The case analysis covers three shapes: unsatisfiable to the small side, to the large side, and to a middle band. It omits the complementary non-monotone shape: satisfiable to a band, unsatisfiable to either side of it. That shape is also handled: Merlin names the side, and Arthur runs either the MA upper-bound certificate or the set-lower-bound protocol. The parameterisation 'p >= gamma t versus p <= t' also excludes t=0, the most natural NP-hard gap: p=0 versus p >= 2^{-n}, i.e. SAT itself, where 'U < gamma t = 0' is impossible. That case is covered by thm:ma with the threshold U < 2^{-n}, but the paragraph as written does not cover it. 'In each case' therefore reads as more complete than the enumeration.

**Proposed fix.** Parameterise as 'p >= t_1 versus p <= t_0 with t_1 >= gamma t_0 (t_0 = 0 allowed)' and require the MA system to certify U < t_1. Add: 'or one side to a band and the other outside it, with Merlin naming which side of the band applies'.

### 5. [minor] paper/sec-discussion.tex l.68-71 (open problem 4), relative to p2-sep.tex l.212-214

**Problem.** The two-sided construction needs T-proofs of two theorems: R has at most one witness, and no u has witnesses for both R and R'. The second is what certifies p=2^{-k-1} when u is not in Lambda: PCIS must refute R(u,.) using the R'-witness. Open problem 4 asks only for polynomial-size EF proofs of the 'unique-witness property'. For a general UP cap coUP problem this does not give the refutation needed on the negative side. (It does when R and R' come from one unique-witness relation, as for factorisation.)

**Proposed fix.** Write: '... whose unique-witness property and the disjointness of its two witness relations have polynomial-size extended Frege proofs (automatic when both relations come from one unique-witness relation, as for factorisation) ...'.

### 6. [minor] paper/main.tex abstract l.37-40; paper/sec-intro.tex l.147-149; README.md l.23 and l.56

**Problem.** Small statement-level imprecisions against what p2-sep.tex proves. (a) The abstract says 'if Blum integers are hard to factor', but cor:automatability needs hardness against polynomial-size circuits; the intro and README say so. The abstract also says 'with gap 1+1/poly' where the section has 'gamma >= 1+1/poly'. (b) The intro and README say the prover helps 'on padded versions with exactly certified p>0' for 'the verifier's proof system P' in general. Exact certification of pad_a(Z) is proved only for the systems of prop:canonical(c) (resolution, CP, Frege-type); the unpadded statement holds for every P via REFUTE. (c) README l.56 credits Krajicek-Pudlak for the extended Frege separation, but cor:automatability now obtains EF from BPR via p-simulation and mentions KP98 only historically.

**Proposed fix.** (a) Abstract: '(e.g. for Frege, if Blum integers cannot be factored by polynomial-size circuits)' and 'with gap at least 1+1/poly'. (b) Intro and README: '(and, for resolution, cutting planes and Frege-type systems, on padded versions with exactly certified p>0)'. (c) README l.56: '(Bonet-Pitassi-Raz, which covers TC0-Frege, Frege and extended Frege; Krajicek-Pudlak gave an earlier extended Frege route from RSA)'.

