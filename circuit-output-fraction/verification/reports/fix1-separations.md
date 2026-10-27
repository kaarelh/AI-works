# Fix round: separations

## Fixer's summary

I rewrote /home/user/AI-works/circuit-output-fraction/paper/p2-sep.tex to address every finding of both separations referees. I also added five verified entries to /home/user/AI-works/circuit-output-fraction/paper/refs.bib: razborov1994pairs, adleman1978, babai1985, mv2005, aks2004.

**Upper bounds.** The claim "the prover helps exactly when P is not weakly automatable" is gone. It is replaced by a new Proposition (label prop:canonical), proved in full, for any set Z of unsatisfiable circuits:
- (a) A sound, efficient procedure without a prover that is complete on Z exists iff (Z, SAT) is separable in randomized polynomial time.
- (b) The same holds for pad_a(Z), with completeness for ε<2^a under the uniform distribution. The threshold is the strict τ = 2^{-n-1}(1+2^{-a}).
- (c) For resolution, cutting planes and the Frege-type systems, PCIS outputs [p,p] on Z ⊆ Z_P^m and on pad_a(Z).

A following paragraph covers weak automatability:
- Pudlák's equivalence is for deterministic separability, and the slice (Z_P^m, SAT) reduces to his canonical pair. So weak automatability of P removes the prover's advantage on these tasks.
- The prover strictly helps whenever a slice is not separable in randomized polynomial time.
- The two conditions differ only by derandomisation.
- Whether weak automatability removes the advantage on general envelope classes K_P(m,K) is stated as open.

**Chain before the corollary.** A new "Hard slices" paragraph supplies the missing steps:
- a disjoint NP pair with short P-refutations of its disjointness;
- closure under restrictions and the step from a formula to its Tseitin encoding, giving the reduction u ↦ α(u,·) into Z_P^m (citing Razborov 1994 and Pudlák 2003);
- Adleman's argument, turning a randomized separator into polynomial-size circuits;
- the result of Bonet, Pitassi and Raz: no feasible interpolation for TC0-Frege unless Blum integers can be factored by polynomial-size circuits.

**The corollary** now covers TC0-Frege, Frege and extended Frege under the factoring assumption, and its proof is written out. The Krajíček–Pudlák RSA result is mentioned only as the earlier route to extended Frege. The quantum clause is no longer claimed: I could only confirm that Arteche, Carenini and Gray rule out quantum weak automation of TC0-Frege, not quantum separators of a slice, and the text now says exactly that.

**Minor fixes.**
- The universal verifier V_T: t is in unary; T is consistent and proves every true Δ0(exp) sentence; the soundness argument is stated correctly; p-simulation is defined through T-provable soundness of the clocked verifier, which also covers truncation, with binary numerals.
- Uniquely satisfiable circuits: one witness certifies only the tight lower bound L=p. Two-sided certification within a factor below 2 would give coNP ⊆ MA via pad_0.
- One-way permutations: renamed f; the instance distribution is stated, and so is the Goldreich–Levin bound δ+negl(k). A two-sided certificate needs a proof that f is injective.
- "Task-1" is replaced by "sound efficient procedure without a prover".
- UP∩coNP construction: dropped the 0^k hypothesis, required ε<1 with a threshold, specified a canonical encoding of the factorisation, and cited AKS.
- NP-hardness barrier: restricted to randomized many-one reductions. It now says that non-monotone reductions are covered and adaptive ones are not, cites AMA=AM (Babai 1985), and notes the tensoring step.
- Atserias–Müller: concerns automatability, not weak automatability, so no separation for resolution follows (as far as I could find, weak automatability of resolution is still open).
- Proof-complexity generators: weakened to "cannot certify p=0 by REFUTE".
- Universality: added the two-line proof of "iff prSBP ⊆ prMA", the oracle (Böhler–Glaßer–Meister construct one with SBP not in Σ2^p, and MA ⊆ Σ2^p relativizes), and the derandomisation via Miltersen–Vinodchandran.

**Checks.**
- The paper compiles in a scratch copy, with no warnings from this section.
- I re-verified pad_a, the C_u values, the τ threshold and the choice of j by brute force: /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/sepfix/check.py.
- I made no code changes.

**Other agents' undefined citations.** The current build has undefined citations from other agents' files: bodlaender1996, bodlaenderkloks1996, greenhill2000, acms2020, finner1992, gjl2019. They need refs.bib entries, which I own, but I did not add them because their intended sources belong to other topics.

## Findings resolved

- separations:proof #0 (major) / counterexample #0 (major): 'the prover helps exactly when P is not weakly automatable' overclaims: Removed the claim. New Proposition prop:canonical proves the one-directional statement with a full proof: (a) complete prover-free procedure on Z iff (Z,SAT) is separable in randomized polynomial time; (b) the padded version for pad_a(Z) with eps<2^a; (c) exact PCIS certification. A following paragraph states Pudlák's deterministic equivalence, reduces the slice to his canonical pair, says the prover strictly helps whenever a slice is not BPP-separable, notes that the two conditions differ by derandomisation, and states that whether weak automatability removes the prover's advantage on K_P(m,K) is open because the prover also supplies envelopes and structure. Matching abstract/intro/README edits are listed under external_edits.
- separations:proof #1 (major) / counterexample #2 (minor): citation chain behind Corollary cor:automatability is missing: Added a 'Hard slices' paragraph before the corollary: disjoint NP pair with short P-refutations of its disjointness; closure under restrictions plus formula-to-Tseitin conversion gives u -> C_u = alpha(u,.) into Z_P^m (cf. Razborov 1994, Pudlák 2003); a randomized separator gives polynomial-size circuits by Adleman's argument; Bonet–Pitassi–Raz's failure of feasible interpolation (factoring Blum integers by polynomial-size circuits). The corollary is restated at exactly that strength and its proof written out. Added razborov1994pairs and adleman1978 to refs.bib.
- separations:counterexample #3 (minor): EF clause under RSA is redundant: The corollary now covers TC0-Frege, Frege and extended Frege under the factoring assumption, since Frege and EF p-simulate TC0-Frege. Krajíček–Pudlák is mentioned only as the earlier EF construction from RSA.
- separations:proof #1, ACG2024 quantum clause: Removed it from the corollary. The text now states what ACG prove (if LWE is hard for quantum polynomial-time algorithms, no polynomial-time quantum algorithm weakly automates TC0-Frege), and says explicitly that the quantum analogue is not claimed, because it would need ACG's argument to exclude bounded-error quantum separators of a slice.
- separations:proof #2 / counterexample #4 (minor): V_T hypotheses (unary t, Sigma_1-completeness, Delta_0(exp), p-simulation, truncation): T is now a consistent theory proving every true Delta_0(exp) sentence (e.g. consistent extensions of IDelta_0+exp such as ZFC); t is in unary; the sentence is Delta_0(exp); soundness is argued via consistency. p-simulation is defined for V' whose soundness clocked at its polynomial time bound T proves; this also covers truncation failures. Instantiation uses binary numerals and gives V' clocked at t' as output law.
- separations:proof #3 / counterexample #1 (major): uniquely satisfiable circuits 'certified exactly by one witness': Now: under the uniform distribution p=2^{-n}, and one witness certifies the tight lower bound L=p. Certifying within a factor below 2 on all uniquely satisfiable circuits would put coNP in MA via pad_0. The Valiant–Vazirani step is spelled out.
- separations:proof #4 / counterexample #1: one-way-permutation sentence imprecise: Renamed the permutation to f. Stated the instance distribution and p(C_y)=2^{-2k}[b=<x0,r0>]. The preimage certifies L=p, and any sound polynomial-time procedure without a prover gives L>0 on a random positive instance with probability at most delta+negl(k), with the Goldreich–Levin predictor given. Two-sided certificates need a proof that f is injective.
- separations:proof #5 / counterexample #10 (minor): Task-1 undefined, uniform D, 'at most m', strict threshold, slice vs Pudlák pair, transfer of the refutation to pad_a: Replaced 'Task-1' by 'sound efficient procedure without a prover'. The separator runs the procedure under the uniform distribution. Z_P^m uses size at most m(|C|). The threshold is the strict tau=2^{-n-1}(1+2^{-a}) with eps<2^a. The slice is related to Pudlák's pair by an explicit reduction. Prop. prop:canonical(c) and its proof state how C's refutation transfers to pad_a(C)|_{beta=0} for the listed systems.
- separations:proof #6 / counterexample #8 (minor): Two-sided exact paragraph: Dropped the '0^k never a witness' hypothesis. Required eps<1 with the rule 'u in Lambda iff L>2^{-k-1}' (error at most 2 delta). Renamed the language to Lambda to avoid a clash with L. Specified the canonical encoding of the factorisation, with AKS (aks2004 added) so the witness is unique, and noted the worst-case assumption.
- separations:proof #7 / counterexample #7 (minor): NP-hardness barrier stated too broadly: Qualified to randomised many-one reductions. Stated that the MA completeness ratio must satisfy 1+eps<gamma; that orientation 1 is an AMA protocol and AMA=AM (babai1985 added); that orientation 2 uses tensoring to make gamma constant; that non-monotone middle-band reductions are handled by combining the two protocols; and that adaptive reductions are not covered. The matching intro change is listed under external_edits.
- separations:proof #8 / counterexample #5, #6 (minor): Atserias–Müller paraphrase and proof-complexity-generator conclusion: Now: no polynomial-time algorithm finds a resolution refutation in time polynomial in |F| and the shortest refutation size unless P=NP. This concerns automatability; weak automatability of resolution is open as far as we know, so no separation for resolution follows. The generator conjecture is weakened to 'cannot certify p=0 by REFUTE', and the stronger hypothesis needed to rule out small positive upper bounds is stated.
- separations:proof #9 / counterexample #9 (minor): Universality paragraph: Added the two-direction proof of 'complete for lower bounds within a constant factor iff prSBP in prMA' (gap amplification by conjunction; scale j plus an MA proof, giving factor 4), and the improvement to 1+eps by conjunctions of O(1/eps) copies. Cited the oracle precisely (BGM's SBP not in Sigma_2^p, while MA in Sigma_2^p relativizes) and the derandomisation via Miltersen–Vinodchandran (mv2005 added). Checked that sec-limits.tex already uses the promise classes, so no edit is needed there.

## Not changed, with reasons

- separations:proof #1: 'ACG's proof goes through the same pair-reduction pattern, so the quantum clause also follows': I could not access the full text of arXiv 2402.10351 or ECCC TR24-029; direct fetches were blocked. Search results confirm only that a polynomial-time quantum weak automation of TC0-Frege would break LWE. The authors also remark that feasible interpolation alone does not seem to break LWE immediately, which is why their proof starts from an automating algorithm. Our procedures yield only a bounded-error quantum separator of a slice, so the paper now says explicitly that the quantum analogue is not claimed, instead of asserting it.
- separations:proof #1 (optional): add AC0-Frege under subexponential Diffie–Hellman hardness (Bonet–Domingo–Gavaldà–Maciel–Pitassi 2004): Optional, and it needs different (subexponential) parameters and a further citation. Left out to avoid padding.
- separations:proof #5(v): show that the fixed-m slice is equivalent to Pudlák's pair {(phi,1^m)} by padding: Only the direction the argument uses is stated: the slice reduces to the canonical pair via C -> (Tseitin(C) and [C=1], 1^{m(|C|)}). The converse needs a statement about how each P handles Tseitin encodings of padded formulas, and no claim depends on it.
- separations:counterexample #8 (optional): note that the pad_a family already gives exact two-sided values on one side: Optional. The corollary already states exact certification on pad_a(Z), and the two-sided paragraph now notes it needs only a worst-case assumption with V_T complete on both sides.

## Independent re-review

**Verdict.** The revision of p2-sep.tex fixes every finding of both separations referees inside the section. I re-derived each step and found no false statement there.
- Prop. prop:canonical (a)-(c) is correct, including the strict threshold tau=2^{-n-1}(1+2^{-a}), soundness off the promise, and the PCIS certificate for pad_a.
- The "Hard slices" chain and Corollary cor:automatability are correct: restriction, Tseitin transfer, Adleman, and BPR's failure of feasible interpolation. The paragraph relating the result to weak automatability is also correct.
- So are the V_T hypotheses, the VV/pad_0 lower-bound statements, the Goldreich-Levin predictor bound delta+negl(k), the UP∩coNP rule (eps<1, error 2*delta), the qualified NP-hardness barrier, and both directions of the prSBP/prMA equivalence (factor 4, then 1+eps).

Brute-force checks with exact fractions in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/sepreview/check.py all pass. They cover:
- the pad_a values and the tau separation for every eps<2^a;
- the choice j=floor(log2(1/p))+1, giving 2^{-j}<p<=2^{-j+1} and factor 4;
- k>=log2 c;
- the C_u values and the decision rule;
- the one-way-permutation instance values;
- the VV repetition count.

The paper compiles in a scratch copy with no warnings from p2-sep.tex. All cited keys resolve, and refs.bib has no duplicate keys.

The five new bib entries are accurate:
- razborov1994pairs (BRICS RS-94-36, confirmed online);
- adleman1978, babai1985 and aks2004;
- mv2005 (Comput. Complexity 14:256-279, confirmed online).

The descriptions of BPR, ACG (no quantum weak automation of TC0-Frege under LWE), BGM (oracle with SBP not in Sigma_2^p) and MV (NE∩coNE hardness against nondeterministic circuits gives AM=NP) match the abstracts.

What remains:
- **Major, outside the revised files.** The abstract, the intro and the README still make the retracted "exactly" claim and the unqualified NP-hardness barrier. The fixer deferred these edits and they have not been applied.
- **Minor.** The orientation-2 tensoring step needs gamma>=1+1/poly. There are also a few notation and wording issues.

No code was changed for this topic, so code soundness is not affected.

- [partially] separations:proof #0 (major): 'the prover helps exactly when P is not weakly automatable' overclaims (header, abstract, intro): Resolved inside p2-sep.tex. The header is gone, and Prop. prop:canonical proves the one-directional statements correctly. The next paragraph correctly separates Pudlák's deterministic equivalence from randomized separability of slices, and states that the K_P(m,K) case is open. However, the abstract (main.tex l.43-44: 'is exactly the non-weak-automatability of its proof system'), the intro (sec-intro.tex l.111-112: 'exactly to the extent that the verifier's proof system is not weakly automatable') and README l.21 still carry the retracted claim. The fixer listed these as external edits, and they have not been applied.
- [resolved] separations:proof #1 (major): citation chain behind Corollary cor:automatability missing; EF clause redundant; ACG quantum clause: The 'Hard slices' paragraph supplies every link, and I checked each one. (1) A disjoint NP pair with polynomial-size P-refutations of alpha(u,y) AND beta(u,z). (2) Restriction by (u,z0) plus a short proof of the closed true beta(u,z0) puts C_u=alpha(u,.) in Z_P^m. (3) For u in A, C_u is satisfiable. (4) Adleman's argument works for promise problems. (5) BPR's failure of feasible interpolation, which I confirmed against the abstract. EF and Frege are now covered under the factoring assumption, and KP98 is mentioned only as the earlier route. The quantum clause is withdrawn, with a correct reason: Pudlák's separator-to-automation direction needs deterministic checking, so ACG's stated theorem does not give non-separability by BQP. The optional AC0-Frege addition is omitted, which is acceptable.
- [resolved] separations:proof #2 (minor): V_T hypotheses (unary t, Sigma_1-completeness, Delta_0(exp), p-simulation/truncation): The text now says: T is consistent and proves all true Delta_0(exp) sentences (true for any consistent extension of IDelta_0+exp); t is in unary; V_T outputs [0,1] on timeout. The soundness argument is now correct. p-simulation is restricted to V' whose clocked soundness T proves uniformly, with binary numerals, and the output law is that of V' clocked at t'. One formal detail is left: the instance should also fix (eps,delta). That is cosmetic.
- [resolved] separations:proof #3 (minor): uniquely satisfiable circuits 'certified exactly by one witness': The text now says that under uniform D one witness certifies the tight lower bound L=p. The pad_0 remark is correct: unsatisfiable C gives a uniquely satisfiable circuit with p=2^{-n-1}, and satisfiable C gives p>=2^{-n}, so certification within a factor below 2 would give coNP in MA. I verified the VV argument with delta=Theta(1/n) and O(n) restrictions.
- [resolved] separations:proof #4 (minor): one-way-permutation sentence imprecise: The permutation is renamed f and the instance distribution is stated. p(C_y)=2^{-2k}[b=<x0,r0>] holds by brute force. The predictor bound Pr[correct] >= 1/2+(alpha-delta)/2 gives alpha <= delta+negl(k), which is correct.
- [resolved] separations:proof #5 (minor): Task-1 undefined, uniform D, 'at most', strict threshold, slice vs Pudlák pair: All the requested items are fixed: 'Task-1' is gone; the separator uses uniform D; Z_P^m uses 'at most m(|C|)'; tau=2^{-n-1}(1+2^{-a}) is strict (I checked (1+eps)2^{-n-a-1}<tau for eps<2^a, and p>=tau on SAT). The reduction from slice to pair, C -> (Tseitin(C) AND [C=1], 1^{m(|C|)}), is stated. The converse padding remark is not given; see the new findings.
- [resolved] separations:proof #6 (minor): Two-sided exact paragraph (0^k hypothesis, eps<1, canonical encoding): The 0^k hypothesis is dropped, and brute force confirms p=2^{-k-1}(1+[u in Lambda]) for every witness position. The rule L>2^{-k-1} with eps<1 has error at most 2*delta. The canonical encoding of the factorisation and the use of AKS are stated. Renaming the language to Lambda removes the clash with L.
- [partially] separations:proof #7 (minor): NP-hardness barrier stated too broadly: Resolved in the section: it is restricted to randomized many-one reductions, cites AMA=AM (Babai), describes tensoring and the middle-band case, and says adaptive reductions are not covered. The intro (sec-intro.tex l.113-114) is unchanged: 'Such separations cannot be based on NP-hardness alone unless coNP ⊆ AM'. That is unqualified, and 'such separations' grammatically includes the lower-bound separation, which the section says may come from NP not in BPP (VV is exactly such a reduction). Also see the new finding about gamma.
- [resolved] separations:proof #8 (minor): Atserias–Müller paraphrase and proof-complexity-generator conclusion: The text now concerns automatability and says no separation for resolution follows, because weak automatability of resolution is open. The generator conjecture is weakened to 'cannot certify p=0 by REFUTE', and the stronger hypothesis needed for small positive upper bounds is stated as a necessary condition, which is correct. A wording slip remains; see the new findings.
- [resolved] separations:proof #9 (minor): Universality paragraph: Both directions are now proved, and I re-derived them. Forward: k>=log2 c copies take the no-case below 2^{-kf}/c. Backward: j=floor(log2(1/p))+1 gives 2^{-j}<p<=2^{-j+1}, and L=2^{-j-1} is within factor 4. Taking a root of an O(1/eps)-fold conjunction gives 1+eps. The oracle citation is precise (BGM: SBP not in Sigma_2^p, confirmed in their abstract; MA ⊆ Sigma_2^p relativizes). MV2005 is cited correctly for prAM=prNP. sec-limits.tex l.127 already uses prSBP ⊆ prMA.
- [partially] separations:counterexample #0 (major): 'exactly' overclaim (section, abstract, intro, README): Same as proof #0. Correct in p2-sep.tex, but main.tex l.43-44, sec-intro.tex l.111-112 and README l.21 still say 'exactly'.
- [resolved] separations:counterexample #1 (major): uniquely satisfiable 'certified exactly'; OWP two-sided needs injectivity: Both sentences are corrected as suggested, and the pad_0 consequence (coNP ⊆ MA) is added. The OWP paragraph says two-sided certificates need an injectivity proof. That is slightly strong, since a proof that f^{-1}(f(x0))={x0} for this instance suffices; this is cosmetic.
- [resolved] separations:counterexample #2 (minor): corollary chain (non-automatizability vs non-weak-automatizability; randomized vs deterministic; LWE): The text now uses BPR's failure of feasible interpolation, not non-automatizability. Randomized separators are handled through Adleman's argument. Pudlák's equivalence is stated as deterministic, and only the slice-to-pair direction is used. The LWE clause is withdrawn.
- [resolved] separations:counterexample #3 (minor): EF under RSA redundant: The corollary covers TC0-Frege, Frege and EF under the factoring assumption, via p-simulation (BPR's abstract states the result for any system that p-simulates TC0-Frege). KP98 is mentioned only historically.
- [resolved] separations:counterexample #4 (minor): V_T missing hypotheses (arithmetic in T, unary t, truncation): See proof #2. The theory hypothesis, unary t, truncation through the clocked V', and binary numerals are all present.
- [resolved] separations:counterexample #5 (minor): proof-complexity generators only exclude REFUTE: Weakened as requested, and the stronger envelope hypothesis is stated. The symbol G now clashes (generator vs envelope circuit); see the new findings.
- [resolved] separations:counterexample #6 (minor): Atserias–Müller gives no separation for resolution: Says explicitly that the result concerns automatability, that weak automatability of resolution is open, and that no separation for resolution follows.
- [partially] separations:counterexample #7 (minor): 'must come from non-NP-hard assumptions' too broad (adaptive reductions): The section is qualified to randomized many-one reductions and says adaptive reductions are not covered. The intro sentence (sec-intro.tex l.113-114) is still unqualified.
- [resolved] separations:counterexample #8 (minor): Two-sided paragraph (0^k, eps<1, decision rule, binary numerals): All points are addressed. The error bound 2*delta and the rule L>2^{-k-1} are correct.
- [resolved] separations:counterexample #9 (minor): Universality and sec-limits language vs promise classes; oracle source: sec-limits.tex l.127-129 uses prSBP ⊆ prMA and notes that this implies SBP ⊆ MA. The oracle is attributed correctly to BGM, with the remark that MA ⊆ Sigma_2^p relativizes.
- [resolved] separations:counterexample #10 (minor): canonical-pair sentence (full-support D, 'at most', refutation transfer to pad_a, Task-1): Prop. prop:canonical(a) runs under uniform D (p>=2^{-n} on SAT). Z_P^m says 'at most'. Part (c) explains the transfer to pad_a(C)|_{beta=0}: the gadget derives [C=1], then C's refutation is reused. 'Task-1' is gone. PCIS SPLIT forms restrictions itself, and the EXACT node on the beta=1 branch is a checked-deterministic subcube with O(n+a)-step implication proofs, which is consistent with def:pcis.

### New findings of the re-review

### 1. [major] main.tex l.43-44 (abstract); sec-intro.tex l.110-114; README.md l.21 and l.52

**Problem.** The headline overclaim that the section now retracts is still in the abstract, intro and README: 'the prover's advantage for upper bounds is exactly the non-weak-automatability of its proof system' / 'exactly to the extent that the verifier's proof system is not weakly automatable'. The intro sentence 'Such separations cannot be based on NP-hardness alone unless coNP ⊆ AM' is also unqualified. Read literally it also covers the lower-bound separation, which the section derives from NP not in BPP through a Valiant–Vazirani reduction. So the abstract and intro now contradict Prop. prop:canonical, the paragraph after it, and the 'Why not NP-hardness?' paragraph. README l.52 still says the separations rely on 'non-automatability results'. The corollary now rests on BPR's failure of feasible interpolation, a different property.

**Proposed fix.** Abstract: replace with 'the prover strictly helps for upper bounds whenever slices of its proof system's canonical pair are not separable in randomized polynomial time (e.g. for TC0-Frege, Frege and extended Frege if Blum integers are hard to factor)'. Intro: change 'exactly to the extent that ... is not weakly automatable' to 'whenever the verifier's proof system has hard slices of its canonical pair (in particular, under the factoring assumption, for Frege-type systems)'. Change 'Such separations cannot be based on NP-hardness alone' to 'Upper-bound and two-sided separations cannot be based on NP-hardness under randomized many-one reductions'. Make the same two edits in README l.21. In README l.52, write 'failure of feasible interpolation (Bonet–Pitassi–Raz, Krajíček–Pudlák)'.

### 2. [minor] p2-sep.tex l.211-220 ('Why not NP-hardness?'), orientation 2

**Problem.** The hypothesis is only 'gamma>1'. Orientation 2 says that replacing the circuit by a conjunction of independent copies makes gamma a constant, so that the set lower bound protocol applies. That needs O(1/(gamma-1)) copies, so it only works for gamma >= 1+1/poly. For gamma = 1+2^{-poly}, nothing in the paragraph puts coNP in AM. The conclusion survives: an efficient procedure, with time poly(1/eps), would need eps < gamma-1 to solve such a gap problem, so only gamma-1 >= 1/poly can yield a separation. But the step as written lacks this hypothesis.

**Proposed fix.** Write '(gamma >= 1+1/poly(n); smaller gaps are irrelevant, since a procedure deciding the gap needs eps<gamma-1 and is efficient only if 1/eps is polynomial)'.

### 3. [minor] p2-sep.tex l.125-127 ('The two conditions differ by derandomisation')

**Problem.** Only the reduction from slice to Pudlák's pair is given. The claim that weak automatability and randomized separability of all slices differ only by derandomisation also needs the converse: Pudlák's pair, with arbitrary k in unary, reduces to a fixed slice with linear m. That takes padding: map (F,1^k) to a circuit for F padded to size >= k, using that P's refutation of F transfers to Tseitin(C_F) AND [C_F=1] with linear overhead. Without this step the reader cannot check the remark. It is true for the systems of Prop. prop:canonical(c).

**Proposed fix.** Add: '(conversely, padding F to size at least k reduces Pudlák's pair to a slice with linear m, for the systems of Prop. prop:canonical(c))'.

### 4. [minor] p2-sep.tex l.61/134/197-198 (beta, B, C_u); l.187-193 (G); l.181-183; l.48-49

**Problem.** Notation and wording.
(i) beta is the pad variable in pad_a and in the two-sided C_u, and also the NP formula beta_ell in 'Hard slices'.
(ii) B is the second NP set in 'Hard slices' and the complement verifier in 'Two-sided'.
(iii) C_u is defined twice: as alpha(u,.) at l.143 and as the UP gadget at l.198.
(iv) G is the generator in C_y=[G(x)=y] and, in the same sentence, the envelope circuit in 'C_y ⊢_P G for envelope circuits G'.
(v) 'No polynomial-time algorithm finds ... in time polynomial in |F| and the size of its shortest refutation' contradicts itself. Atserias–Müller rule out any algorithm running in time poly(|F|, s(F)).
(vi) 'Two-sided certificates ... also need a proof that f is injective' overstates: a proof that f(x)=f(x0) has only the solution x0 suffices.

**Proposed fix.** (i)-(iii) Rename beta_ell to gamma_ell, rename the complement verifier to A', and call the Hard-slices circuits D_u or alpha_u. (iv) Call the envelope circuit E or H. (v) Write 'No algorithm finds a resolution refutation of F in time polynomial in |F| and the size of its shortest refutation unless P=NP'. (vi) Write 'need a proof that f^{-1}(f(x0))={x0} (e.g. a T-proof that f is injective)'.

