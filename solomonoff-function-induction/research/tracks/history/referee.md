# Referee report: track "history" (H3, H4)

Referee: adversarial check of `notes.md` and `checks/c1`–`c6`. I did not edit the notes.
Independent code is in `referee_code/` (seeded; outputs saved next to each script as `*.out`).

## Verdict

I found no fatal error. I checked every proof marked **proved** line by line. The mathematics is sound under the hypotheses actually stated in the theorems. There are three major problems, and all three are about framing, scope or credit rather than the proofs:

* **M1.** The verdict "Hänni's Thm 1 is false in his wording" rests on a reading that Hänni's own text rules out.
* **M2.** The summary overstates how much of Thm 1 the minimax theorem establishes.
* **M3.** The known-results check for H4 is incomplete.

There are also a number of minor issues. The six check scripts do what they claim. Five independent referee scripts reproduce or sharpen every computed claim I could test. A sixth, exploratory script bears on the open question Q1.

---

## Major issues

### M1. Reading B is not Hänni's reading, and Thm 3.7's example is Hänni's own

**Claims.**
* Summary row 3.7: "Hänni's Thm 1 read with a reveal law that may depend on f (his wording) is false".
* §3 (line 148): Reading B "is the literal reading of 'simple to sample from conditional on f'".
* Thm 3.7 is headed "reading B of Thm 1 is false … refutes Thm 1 in reading B".
* §7: "reading B is false".
* §5.3: "a second refutation of reading B".

**Problem.**
* **Hänni already gives the example and rejects this reading.** In the sentence before Thm 1, Hänni writes (`prior/hanni-sfi-notes.md` line 26; draft PDF text lines 253–261): "One could hope that there would at least be a version for simple reveal sequence distributions, but I think this will also fail if … the reveal sequence choice provide[s] information about the function — actually, one can just use the random string example above, except now putting the randomization inside the reveal sequence distribution, and letting the function depend on the chosen reveal sequence". That is exactly Thm 3.7's randomized chain.
* **His fix is chosen to exclude that example.** He then says: "However, we can get a version of Thm 1 in case … the reveal sequence distribution is simple to sample from conditional on any particular choice of function f".
* **So his condition must exclude the randomized chain.** Under Reading B, the chain's conditional sampler has complexity O(1) (it uses oracle access to f), so the condition would not exclude it.
* **The reading consistent with his text is Reading C.** For each fixed f, the conditional reveal law Δ_f(x | h) is a standalone computable sampler. It sees only the revealed history. Its complexity is C_Δ = K(Δ_f), or a bound on it uniform in f.
  * For the randomized chain, Δ_f is the point mass on the chain, so K(Δ_f) ≈ Σ ℓ_i. The example is excluded.
  * His proof sketch also presupposes Reading C: the function machine simulates Δ, which it can only do without access to f.

**Consequences.**
1. **Thm 3.7 does not refute Hänni.** It proves rigorously a failure he stated himself, and he should be credited for it.
2. **Reading C is Reading A applied pointwise in f.** Thm 3.8 is stated "for every f" with a non-peeking kernel. Applied to the kernel Δ_f, it gives, for every f:

   E_{x|f}[L_F] ≤ E_{x|f}[L_P] + K(P) + K(Δ_f) + K(n) + c.

   Thm 3.2 gives L_F ≤ L_P + L_{Δ_f} + K(Δ_f) + K(P) + c pathwise. So under the reading his text supports, **Thm 1 is true up to K(n)**, with the hypotheses of Thm 3.8. It holds pathwise, with no K(n), when Δ_f is deterministic. Only the proof sketch is wrong.
3. **Hänni's mutual-information question is not answered under Reading C.** Thm 3.7 answers it only under Reading B; the track's "for that reading" hedge is correct there. Under Reading C, the question is whether K(Δ_f) can be replaced by I(Δ_f : f). Thm 3.7 does not answer it: there K(Δ_f) and I(Δ_f : f) are both ≈ Σ ℓ_i. The question is open, and the track does not state it.

**Evidence.** The quoted source lines. Thm 3.8's statement ("for every f", non-peeking Δ). Thm 3.7's own construction.

**Fix.**
* Introduce Reading C and say it is the reading consistent with Hänni's preceding sentence and with his proof sketch.
* Rewrite summary rows 3.7 and 3.8, §3.4's heading, the Thm 3.7 heading, §5.3's last paragraph and §7. Suggested wording:
  * "Hänni's remark that simple-Δ versions fail when the reveal choice carries information about f is correct; Thm 3.7 makes his randomized-chain example rigorous."
  * "Thm 1 under Reading C holds up to K(n) (Thm 3.8 applied to Δ_f), pathwise for deterministic Δ_f (Thm 3.2)."
* Keep Reading B, labelled as a stronger hypothetical variant that fails.
* State the Reading-C mutual-information question as open. A reasonable conjecture is K(Δ_f) → I(Δ_f : f) + O(log). Label it as a conjecture; I have not tested it.

### M2. The summary and §7 overstate how much of Thm 1 is established

**Claims.**
* Summary row 3.8: "Hänni's Thm 1 read with a reveal policy that does not see f … E[L_SFI] ≤ E[L_P] + K(P) + K(Δ) + K(n) + O(1)".
* Thm 3.8's last line: "So in reading A, Hänni's Thm 1 holds up to an additive K(n)".
* §7: "reading A is true up to K(n) for finite settings".

**Problem.** Thm 3.8 is proved only under the following hypotheses:
* (i) P and Δ have **rational values computable from their arguments**. This is needed for the decidability of F_fin and for the grid search.
* (ii) the input set A_n and the label set Y are finite.
* (iii) A_n is "computable from n". The complexity of the map n ↦ A_n is silently absorbed into c. It belongs in the bound unless A_n is a fixed universal family such as {0,1}^{≤g(n)} with g fixed.

Hänni's class C is **computable samplers**, whose probabilities are only lower semicomputable. The track flags (i) in "Assumptions to flag" (iii), but the summary table and §7 do not. A reader of the table would believe that Thm 1 is proved for samplers. It is not. For lower-semicomputable P, E[L_P] is only upper semicomputable, so the search cannot certify a G. No argument is given that K(P) + K(Δ) still suffices.

**Fix.**
* Put the hypotheses into summary row 3.8 and into §7: "for P, Δ with rational values computable from their arguments, finite A_n, Y; +K(A_·)".
* State the sampler version as **open**.
* Note that Thm 3.5 (computable prior) and Cor. 3.3 / Thm 3.2 (pathwise) have no such restriction.

### M3. The known-results check for H4 is incomplete

**Claims.**
* §1.3 and Cor. 4.3: Hutter's ξ, known but unverified.
* §4.4: only Lattimore–Hutter–Gavane is checked.
* The verification log lists the literature checks.

**Problem.** The brief asks for H4: "Check what is known (Hutter 2005 book; papers on universal prediction with side information or actions)". Three gaps remain.

1. **Solomonoff's operator induction is not discussed.** Solomonoff's third kind of induction concerns an *unordered set of ordered pairs* with a universal distribution and a convergence theorem: "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008. I confirmed the title, venue and the abstract's "unordered set of ordered pairs" via search snippets; I did not check the full text, so it is unverified. This is the historical precursor of SFI. It bears directly on Prop. 5.1 (order-independence) and on the x-only versus history-aware distinction. The foundations track explicitly asked the history track to confirm the match (foundations `notes.md` line 157: "The history track should confirm the match"). The history notes do not mention it.
2. **Thm 4.2 may already be in the literature, in substance.**
   * Hutter defines his universal AI prior both by chronological machines (Σ_{q: q(y_{1:k}) = x_{1:k}} 2^{−ℓ(q)}) and as a mixture over enumerable chronological semimeasures. The equivalence of the two is the chronological analogue of Zvonkin–Levin, which is what Thm 4.2 proves.
   * Search snippets confirm that Hutter (arXiv cs/0004001) works with chronological semimeasures, and that the set of enumerable chronological semimeasures is enumerable. They do not show the equivalence statement itself.
   * Sunehag–Hutter state, for the related environment priors, an equivalence "up to a multiplicative factor in [LV08] and exact identity in [WSH11]". That is a snippet only, and it is not specific to the chronological case.
   * The notes should say whether Thm 4.2 is new or a written-out version of a known equivalence. Until that is checked, it should be marked "known in substance? (unverified)".
   * The foundations track proves the same interval-allocation lemma for countable alphabets (foundations Lemma 3.1). The paper should state it once.
3. **A further reference for Thm 4.6 is unchecked.** Snippets describe arXiv 2505.17882 ("Formalizing Embeddedness Failures in Universal Artificial Intelligence") as contrasting the monotone-machine "joint" distribution, which is "not action-contextual", with chronological semimeasures, and as converting between the two. That is the subject of Thm 4.6. I have not checked it (unverified). Hutter's book is also not checked; the track says so.

**Fix.**
* Add operator induction to §1.3 or §4.4, marked unverified, and answer the foundations track's question. My reading, unverified: operator induction is the private-randomness product mixture, an x-only class, not a history-aware one.
* Mark Thm 4.2's novelty status.
* Add the unchecked references, marked unverified.
* A self-contained alternative: Lemma 4.1 and Thm 4.2 together show that M_H is itself a universal LSC chronological semimeasure. The paper can therefore *define* the universal chronological semimeasure as M_H and cite Hutter only for the identification with ξ. Cor. 4.3 then no longer depends on an unverified enumeration of all LSC chronological semimeasures.

---

## Minor issues

| # | Where | Problem | Fix |
|---|---|---|---|
| m1 | §3.5, remark "A pathwise version … is false" (line 243) | "Take f fixed" is not enough. For a generic fixed f, the chain paths may not exist, or K(x_{1:n−1}∣x_n) may be small, since x_{i} = f(x_{i+1}) is computable from x_n given f. The counterexample needs f to be the chain function of an ML-random ω, with x_i its blocks. | Specify f = the chain function of Thm 2.1(b). |
| m2 | Cor. 3.4 (line 173) | With repeated inputs, the actual sequence x_1y_1…x_ny_n is not one of the "orders σ of D_n" (D_n is a set), so the second "≤" does not follow from the first as written. Each inequality is true separately, by the same construction. | Prove the two inequalities separately, or assume distinct inputs. |
| m3 | Thm 5.2, proof (line 350) | "It costs \|p\| + c bits (F1)". (F1) gives K(T_p) ≤ K(p) + c, not \|p\| + c. The \|p\| bound is true, but by a different argument. Use a fixed machine that runs U(·,x) on the tape. For x ∈ dom D it reads exactly p, because the program tape is one-way and self-delimiting given x. It then hands the rest of the tape to U_H. The tape starts with p with probability 2^{−\|p\|}. | Replace the (F1) appeal by this argument. |
| m4 | Thm 4.2, proof (line 271) | The displayed "λ(S_t(z)) = min(ρ_t(z), λ(S_t(p)) − Σ λ(S_t(z′)))" is not an equality when a sibling is processed after z in the same stage, because S(z′) can grow after z is processed. Only "≥", with the sibling values at z's processing time, is valid, and that is all the proof uses. | Write "≥" and use the siblings' values at the time z is processed. |
| m5 | Thm 4.2 statement | "M^hist_{T_ρ} = ρ exactly" fails at the root when ρ(ε‖ε) < 1, because M^hist(ε‖ε) = 1. | Say "on all non-root nodes". |
| m6 | §4.4, LHG bullet; summary row 4.7 | The hedge is misplaced. If unnormalised M fails to converge to 1 on infinitely many selected bits (liminf < 1), the cumulative loss on those bits is unbounded automatically. The real gap is format. LHG's example is on raw bits (even bit = previous odd bit), while L_M^y here is defined on prefix-coded blocks code(x)=1^{\|x\|}0x. LHG's result does not transfer to that format without proof. | Rephrase the condition as "if LHG's failure transfers to the code(·) format". |
| m7 | Summary rows 2.1, 2.2 | The "−O(1)" in the lower bounds depends on ω (c_ω, Levin–Schnorr). | Write c_ω in the table. |
| m8 | (F6) and Thm 3.7 | (F6) is stated as E[K(Z∣w)] ≥ H(Z) for a fixed w. Thm 3.7 needs E[K(Z∣W)] ≥ H(Z∣W) for a random condition W = x_n. This is true by the same Kraft argument conditional on W = w. | State (F6) in the conditional form. |
| m9 | Thm 3.6, proof ("replace f by f\|_A") | If the peeking kernel Δ(·∣f,h) depends on values of f outside A, then replacing f by f\|_A loses information. The identity still holds by the same computation on the general probability space, with I(f; x_i∣h) finite because x_i is finite-valued. | Drop the reduction, or assume that Δ depends only on f\|_A, as Thm 3.8 does. |
| m10 | Thm 5.6 and the "Answer to item 3" paragraph | "That bound is attained up to lower-order terms" is shown only for the randomized chain. In the GF(2^m) process, I(f→x) ≈ 2m while the gap E[L_F] − E[L_ξ] ≤ m + O(1) (E[L_F] ≤ 2m + c from uniform labels; E[L_ξ] ≥ E[L_B] = m by Gibbs, r1(E)), so it is not attained there. | Say "attained in the randomized chain". |
| m11 | Prop. 5.1, second sentence; §5.3 interpretation | "It also cannot use the identity of the other inputs" is informal and labelled **proved**. It is also partly misleading. Shared randomness lets SFI correlate labels with a *guess* of the other inputs, and this pays off. r3 below: for m = 3, the best random function has expected loss 4.35 bits on the GF triples (so SFI's is 4.35 bits up to K(m) + O(1)), against 6 bits for independent uniform labels and ≤ 3 + O(1) bits for ξ. | Say "a hypothesis's answer at x cannot condition on which other inputs are queried; correlations through shared randomness can partly substitute, at a cost". Drop "proved" from the informal part. |
| m12 | Thm 3.8 | The hidden K(A_·) term; see M2(iii). | See M2. |
| m13 | §1.3 ξ | Hutter's setting has finite action and percept alphabets (unverified, from memory). Here X = Y = {0,1}*. | Say that ξ is used over countable alphabets, or define it as M_H (M3 fix). |
| m14 | `checks/` docstrings | The theorem numbers do not match the notes. c2 says Thm 3.1/3.2/3.3 for the notes' Thm 3.2/3.5/3.6. c3 says Thm 3.4 for Thm 3.8. c5 says Thm 5.3 for Thm 5.4. c6 says Prop 4.6(iii) for Prop 4.5(iii). | Renumber. |
| m15 | c2 (B) | The "private simulator" in c2 is the *normalised* (conditional on visiting x), 3-step-horizon version. Hänni's is unnormalised and unbounded-horizon. Normalisation only lowers its loss, so violations transfer, but the horizon truncation is a different object. c1 alone already proves Prop. 3.1. | Say so in the verification log. |
| m16 | Q6 | "True growth about 2^{1.35m}" rests on local-search lower estimates for m ≤ 7. | Keep it labelled as a numerical observation. r3 adds exact values for m = 2, 3 (below). |
| m17 | Summary row 4.4–4.5, "each gap unbounded" | For (i) and (iii), the separations are families of finite sequences indexed by n. No single infinite sequence is shown to have an unbounded gap. Only (ii) is a single infinite sequence. | Say "sup over finite sequences is infinite". |

---

## Claims I confirmed

I checked every one of these line by line. Where a referee script applies, it is cited.

* **Lemma 1.1** (domain lower bound) and **Lemma 1.2** (ρ_F is chronological; L_ξ ≤ L_F + c in every order).
* **Lemma 2.0 and Thm 2.1** (chain).
  * The disjointness argument covers first-difference, prefix and cycle cases.
  * The upper-bound program is consistent.
  * The rate L_{n−1} − K(ℓ_n) − c_ω ≤ L_F ≤ L_{n−1} + K(n) + c is correct. A sharper lower bound is not obtained by symmetry of information (same bound).
* **Thm 2.2** (skipped strings). Hänni's predictor has loss 0, including at ℓ = 1. The tape-block machine gives the upper bound. The counting and ML-random lower bounds hold.
* **Prop. 3.1** (the private simulator in the brief's example: 2 bits against 1). Reproduced by hand.
* **Thm 3.2, Cor. 3.3, Cor. 3.4.** These hold apart from m2.
* **Thm 3.5** (Bayes form). r1(A): with a non-peeking selector that has **private memory** (not tested in c2), the true conditional law of y_i equals π(D∪(x,y))/π(D) exactly, in rational arithmetic, at every reachable (h, x) in 25 instances. r1(B): Gibbs holds.
* **Thm 3.6** (directed-information identity).
  * r1(C): peeking kernels with private memory, alphabet size 3, exact rationals with 60-digit logs. Identity error ≤ 3·10⁻⁶⁰ in 25 instances; inequality slack ≥ 0.198 bits.
* **Thm 3.7** (the mathematics; see M1 for the framing). r1(D): for the randomized chain with n = 2, 3, 4, brute force gives E[−log π(D_n)] = I(f→x) = n(n+1)/2 and Bayes loss 0, exactly as claimed.
* **§5.3 directed information.** r1(E): I(f→x) = m − 1 + log₂(2^m − 1) exactly for m = 2, 3; E[L_B] = m.
* **Thm 3.8** (the minimax argument under its stated hypotheses).
  * The Sion application is correct: both sets are compact convex, Φ is continuous since G ≥ ½|Y|^{−n}, convex in G and affine in π.
  * The bound V ≤ 1 + C_dir is correct.
  * The grid-search computability step is correct.
  * r2 gives certified brackets with a different algorithm from c3: fictitious play for the upper bound; EM with a Frank–Wolfe gap for the lower bound.
  * Non-peeking, over 72 instances in three worlds ((\|X\|,\|Y\|,n) = (3,2,3), (2,3,3), (3,3,2)) with six predictor kinds, plus a hill-climb over predictors: the largest upper bound on V is 1.8·10⁻¹⁵. In 12 of the instances (the deterministic 'det_order' predictor) F_fin is empty, so they are trivial. For Bayes predictors V = 0, attained by G = the predictor's own prior. Every other instance has V < 0.
  * Peeking: V ≤ 0.006 against C_dir ≥ 0.81.
* **Lemma 4.1, Thm 4.2, Cor. 4.3.**
  * The invariants (I1)–(I3) hold, and the limit argument is correct (m4, m5 aside).
  * r5 implements the proof **literally**: stage t processes z_1..z_t of a random parent-first enumeration, with adversarial approximations (3800 stage-node pairs where a child is ahead of its parent). It computes the machine's generated probability **exactly**, as a Lebesgue measure of an intersection of interval unions, instead of by Monte Carlo. Result: 258 nodes, 0 mismatches, 0 violations of (I1)–(I3).
* **Prop. 4.4, Prop. 4.5.**
  * r4(a): for n = 6, 7, no two distinct orders with the same last element are compatible with one set-hypothesis (42 840 and 1 811 880 pairs checked). This extends c6 (n ≤ 5) and directly checks the backward-reconstruction step.
  * r4(c) checks the binomial bound used in (i) for 2 ≤ n ≤ 400.
* **Lemma B and Thm 4.6.**
  * r4(b): on 6 random instances, ν = ρ′·ρ is a block semimeasure, ν_bin(z0) + ν_bin(z1) ≤ ν_bin(z) on all binary z up to length 14, and ν_bin(code(b)) = ν(b) exactly.
  * The inequalities in (a)–(d) follow as stated.
* **Thm 5.2 and Cor. 5.3.** Correct; m3 concerns only the proof's wording.
* **Lemma 5.5, Thm 5.4.**
  * The character-sum argument is correct, including the a = b and partial-G reductions and the ordered-pair counting.
  * r4(d) checks the arithmetic of 5.4(c) for m ≤ 60.
  * r3 computes the exact optimum over *all* random functions on GF(2^m) for m = 2, 3. It gives a constant-free lower bound on E[L_F], which equals E[L_F] up to K(m) + O(1).

    | m | optimum, E[L_F] lower bound (bits) | notes' bound 3m/2 − 2 | log₂(#triples / max N) | ξ's loss |
    |---|---|---|---|---|
    | 2 | 2.708 | 1 | 2.585 | 2 |
    | 3 | 4.348 | 2.5 | 4.348 | 3 |

    At m = 3 the optimum meets the Jensen bound log₂(#triples / max N) exactly, with max N = 22 (c5's value is confirmed). The notes' bounds are valid but loose at small m.
* **Thm 5.6.** Confirmed, apart from m10.

---

## Important questions the track missed or left thin

1. **Reading C and its mutual-information variant** (M1). This is the main open item for H3.
2. **Thm 1 for computable samplers** (M2), Hänni's actual class. Even a partial result is missing, for example for samplers with a computable rate of convergence.
3. **Q1 (the K(n) term).**
   * r6 shows that the horizon-specific minimax random functions are genuinely incompatible. In one small instance, the horizon-free value over horizons 1–4 is certified ≥ 0.026 bits, while every single-horizon value V_n is ≤ 0 (theorem; numerically ≤ 0.005).
   * So a horizon-free version needs a positive constant.
   * r7 finds no growth of that constant up to horizon 6 in three instances (upper bounds stay at 0.007, 0.013 and 0.022 bits).
   * Weak evidence that the K(n) is an artefact of the proof. Not a resolution.
4. **Known literature for H4** (M3): operator induction, Hutter's own equivalence, side-information prediction.
5. **H5 cross-reference.** The brief says "SFI^hist also does well" on the cyclic permutation. This follows in one line from Cor. 4.3(b): "predict 0^{\|x\|}, then the previous input" has loss O(1), so L_H ≤ O(1). It is not stated. The notes cover only SFI's side, via Cor. 5.3.
6. **Q4 (normalised convention).** Correctly flagged as open. The paper should say clearly that every SFI lower bound in this track is for the semimeasure convention. The normalised predictor is not lower semicomputable, so the coding-theorem method does not apply.

---

## References checked

Snippets only. arxiv.org, ar5iv, hutter1.net, the ANU repository and researchgate did not resolve or were refused from here.

* Lattimore–Hutter–Gavane, ALT 2011, LNCS 6925, pp. 262–276, arXiv:1107.5531. Bibliographic data and abstract wording are confirmed. The unnormalised counterexample and the theorem numbers are **not** confirmed. Hutter's open-problems list (arXiv 0907.0746) describes the selected-bits question as previously open, which is consistent.
* Hutter, arXiv cs/0004001. Chronological semimeasures and their enumerability are confirmed in snippets. The universality statement and equation numbers are unverified, as the track says.
* Solomonoff 2008, *Comput. J.* 51(5):566–570. Title, venue and the "unordered set of ordered pairs" kind are confirmed in snippets. The content is unverified (M3).
* Wood–Sunehag–Hutter, arXiv:1111.3854. Existence confirmed by the track; I did not recheck it.
* Sion 1958, Pacific J. Math. 8:171–176. Standard; not rechecked.

---

## Referee code (all in `referee_code/`, outputs `*.out`)

| Script | Seed | Tests | Result |
|---|---|---|---|
| `r1_exact_bayes_directed.py` | 101 | Thm 3.5 with a private-memory selector (exact rationals); Gibbs; Thm 3.6 identity with peeking private-memory kernels (60-digit logs); exact I(f→x) and E[−log π(D_n)] for the randomized chain (n ≤ 4) and the GF process (m = 2, 3). | 0 mismatches; identity error 2.7·10⁻⁶⁰; all claimed values reproduced exactly. |
| `r2_minimax_bracket.py` | 2027 | Certified brackets for the minimax value V of Thm 3.8 by a different algorithm; 72 non-peeking instances in three worlds, a hill-climb over predictors, 4 peeking instances. | Non-peeking: largest upper bound on V is 1.8·10⁻¹⁵ (V ≤ 0 confirmed). Peeking: V ≤ 0.006 against C_dir ≥ 0.81. |
| `r3_gf_optimal_mixture.py` | 0 (deterministic) | Exact optimum over all random functions on GF(2^m) for m = 2, 3, via shift symmetry and EM over the maximal "masks" (sets of pairs a function satisfies), with a certified Frank–Wolfe gap. | OPT₂ = 2.708 and OPT₃ = 4.348 bits (lower bounds on E[L_F]); max N = 8 and 22 confirmed. Runs about 8 minutes. |
| `r4_combinatorial_lemmas.py` | 4242 | Set-order lemma for n = 6, 7; Lemma B on random block semimeasures; the binomial bound of Prop. 4.5(i); the arithmetic of 5.4(c). | All pass. |
| `r5_chrono_literal.py` | 55 | Thm 4.2 construction implemented literally, with adversarial approximations; exact generated measure. | 258 nodes exact; 0 invariant violations. |
| `r6_horizon_free.py`, `r7_horizon_growth.py` | 606, 707 | Exploratory work on Q1: the horizon-free minimax value against the horizon-specific values. | A single G pays a certified ≥ 0.021 bits more in one instance; no growth up to horizon 6. |
