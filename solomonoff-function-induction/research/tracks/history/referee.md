# Referee report: track "history" (H3, H4)

**Object refereed.** `notes.md` (455 lines) and `checks/c1`–`c6`. I did not edit the notes.

**Method.**
* I checked every proof marked **proved** line by line.
* I re-ran all six check scripts in a scratch directory and compared outputs.
* I wrote four new scripts, `referee_code/s1`–`s4` (seeded; outputs `*.out` next to them).
* I re-ran three scripts left by an earlier referee run of this workflow, `referee_code/r1`, `r4` and `r5`, and cite them where they bear on a claim. Their outputs reproduce byte for byte.
* I checked references by WebSearch. arxiv.org, hutter1.net and the other mirrors do not resolve from here, so I had snippets only.

This report replaces the earlier `referee.md`. It keeps the earlier report's valid points, re-derived independently, adds three new major issues (M3–M5), and extends the literature issue (M6). A partial revision, `notes-final.md`, exists. It ends at `<!-- PART2 -->` after §3.7. Its status on each issue is listed at the end, for the reviser.

---

## Verdict

**No fatal error.** All proofs marked "proved" are correct under the hypotheses actually written into the theorems. All "computed" claims reproduce.

There are **six major issues**:
* **M1.** The verdict that Hänni's Thm 1 is false rests on a reading (B) that his own text rules out. Under the reading his text supports (C), the notes already contain a proof of Thm 1 up to K(n).
* **M2.** The summary and §7 drop the hypotheses of Thm 3.8 (rational-valued P and Δ, finite alphabets, a hidden K(A_·) term, memoryless kernels). Hänni's class is computable samplers.
* **M3 (new).** Open question Q2 is **refuted by the notes' own Prop. 4.5(i)**, with a gap linear in n.
* **M4 (new).** For computable deterministic input policies, the gap between ξ and SI's conditional label loss equals M's loss on the input blocks, up to K(δ). Taking inputs that copy the previous label puts LHG's selected-bit pattern on the inputs. So under the transfer hypothesis the notes already use for one direction, **the other direction (Q3) fails too**. The H4 verdict needs rewriting.
* **M5 (new).** The §7 remark that prefix-free deterministic programs pay "≈ K(n)" extra on random labels is **false** for the program mixture. The extra is at most −log Σ_{N≥n} 2^{−K(N)} + c, which grows more slowly than every computable unbounded function.
* **M6.** The known-results check for H4 is incomplete. It misses Hutter's own "Supervised Learning from Examples (EX)" section for AIXI, Solomonoff's operator induction, and the literature status of Thm 4.2.

---

## Major issues

### M1. Reading B is presented as Hänni's literal reading, and his Thm 1 is declared false

**Claims.**
* Summary row 3.7 (line 22): "Hänni's Thm 1 read with a reveal law that may depend on f (his wording) is false".
* §3 (line 148): Reading B "is the literal reading of 'simple to sample from conditional on f'".
* The heading of Thm 3.7 (line 208): "reading B of Thm 1 is false … refutes Thm 1 in reading B".
* §5.3 (line 386): "a second refutation of reading B".
* §7 (line 421): "reading B is false".

**Problem.**

*Hänni's own text.* The sentence just before Thm 1 is in `prior/hanni-sfi-notes.md` line 26 and in the draft text at lines 117–129. (The draft says "easy to sample"; the notes say "simple to sample".) It says that a simple-Δ version fails "if the data-generating process is allowed to have the reveal sequence choice provide information about the function — actually, one can just use the random string example above, except now putting the randomization inside the reveal sequence distribution, and letting the function depend on the chosen reveal sequence". It then restricts to the case "the reveal sequence distribution is simple to sample from conditional on any particular choice of function f".

*Why Reading B cannot be his.* The randomized chain is his own example of failure, so his restriction must exclude it. Under Reading B it is not excluded: the conditional sampler has C_Δ = O(1) given an oracle for f. Reading B therefore contradicts the sentence it is meant to formalise.

*Reading C.* The reading consistent with both sentences is this. For each f, the conditional reveal law Δ_f(x ∣ h) is a standalone computable sampler that sees only the revealed history. C_Δ is K(Δ_f), or a bound on it uniform in f. His proof sketch presupposes the same reading: the function machine simulates Δ and has no access to f. Under Reading C, Δ_f for the randomized chain is the point mass on the chain, so K(Δ_f) ≈ n(n+1)/2 at horizon n, and the example is excluded.

**Consequences.**
1. **Thm 3.7 does not refute Hänni.** It makes his own remark rigorous, and the notes should credit him for the example.
2. **The notes already prove his Thm 1 under Reading C, up to K(n).**
   * Thm 3.8's proof uses only that, for the fixed f, the kernel does not see f. Applied to Δ_f it gives E_{x∣f}[L_F] ≤ E_{x∣f}[L_P] + K(P) + K(Δ_f) + K(n) + c, under the hypotheses of M2.
   * Cor. 3.3 gives the pathwise version with no K(n) for deterministic Δ_f.
   * So the notes contain a proof of the theorem they call false. Only the proof sketch is wrong.
3. **Hänni's mutual-information question is not answered under Reading C.** There the question is whether K(Δ_f) can be replaced by I(Δ_f : f). Thm 3.7 does not decide it: both quantities are ≈ n(n+1)/2 in the chain. The notes do not state this question.

**Evidence.** The quoted source lines. Thm 3.8's proof: the statement "for every f", and Step 1 uses only the non-peeking kernel. The construction of Thm 3.7.

**Fix.**
* Introduce Reading C as the reading the text supports, and keep Reading B as a stronger variant that fails.
* Rewrite summary rows 3.7 and 3.8, the heading of Thm 3.7, §5.3's last paragraph and §7.
* State Thm 1 under Reading C as proved under the hypotheses of Thm 3.8, and pathwise for deterministic Δ_f.
* State the Reading-C mutual-information question as open or as a conjecture. It is not tested here.

### M2. Thm 3.8 is quoted without its hypotheses

**Claims.**
* Summary row 3.8 (line 23).
* The last sentence of Thm 3.8 (line 224): "So in reading A, Hänni's Thm 1 holds up to an additive K(n)".
* §7 (line 422): "reading A is true up to K(n) for finite settings".

**Problem.** The proof (lines 226–236) needs four things that the summary and §7 drop.

1. **Rational values.** P and Δ must have rational values computable from their arguments. The proof needs F_fin to be decidable and each Φ_f to be computable. Hänni's class C is computable *samplers*, whose probabilities are only lower semicomputable in general. They are computable reals when the sampler halts almost surely, since then P(y) = 1 − Σ_{y′≠y} P(y′) is also upper semicomputable. The notes flag this only in "Assumptions to flag" (iii), line 455.
2. **Finite alphabets.** A_n and Y must be finite.
3. **A hidden K(A_·) term.** "A_n computable from n" is used by the grid search. The program for n ↦ A_n therefore belongs in K(G), unless A_n is a fixed family such as {0,1}^{≤g(n)} with g fixed.
4. **Memoryless kernels.** Δ is a kernel Δ(x ∣ h) without memory. Hänni's Δ is a law on input sequences and may use private memory R, for example "draw a random permutation, then reveal in that order". The reduction is easy but is not stated:
   * The joint law factorises as [π(f) Π_j 1[y_j = f(x_j)]] · [p(R) Π_j 1[x_j = sel(R, h_{j−1})]].
   * Hence f ⊥ R given h_n, and so I(f ; x_i ∣ h_{i−1}) = 0.
   * The effective kernel Δ̄(x_i ∣ h_{i−1}) = Pr[x_i ∣ h_{i−1}] depends neither on f nor on π.
   * Δ̄ is rational and computable when the selector has finite memory and rational probabilities.

**Fix.**
* Put (1)–(3) and the K(A_·) term into row 3.8 and §7.
* Add the private-memory reduction.
* Mark the sampler version open, or prove it. The partial `notes-final.md` claims a proof for almost surely halting samplers (Thm 3.8(b)). I read it quickly and found no error, but I have not refereed it in full.
* Note that Thm 3.5 and Thm 3.2 / Cor. 3.3 have no such restriction.

### M3 (new). Q2 is refuted by Prop. 4.5(i) of the same notes

**Claim (Q2, line 407).** "Is there an individual-sequence analogue of Thm 3.6, e.g. L_F(D) ≤ L_ξ(D_σ) + I(x_σ : y_σ) + O(log) … The chain and the GF(2^m) example are consistent with such a bound. [conjecture, not tested]".

**Problem.** The construction of Prop. 4.5(i) refutes it.

*Construction.* Let S be any n distinct strings. Let A ⊆ S with |A| = ⌊n/2⌋ and K(A ∣ S) ≥ log C(n, ⌊n/2⌋) − 1. Let σ put the elements of A at the even positions. Let y_i = [i even].

*Three facts.*
* L_F(D) ≥ K(A ∣ S) − c ≥ n − log(n+1) − 1 − c, by Lemma 1.1.
* L_ξ(D_σ) ≤ c, from the predictor "y_i = [i even]".
* I(x_σ : y_σ) ≤ K(y_σ) + c ≤ K(n) + c, because y_σ = 0101… is computable from n.

*Conclusion.* L_F − L_ξ − I(x_σ : y_σ) ≥ n − log(n+1) − K(n) − c, which is linear in n.

*A constant-free version.* Draw A uniformly. The events {U^ω ⊇ D_A} are disjoint, so Σ_A M_F(D_A) ≤ 1, and Gibbs' inequality gives E_A[L_F] ≥ log₂ C(n, ⌊n/2⌋) exactly, while L_ξ ≤ c and I ≤ K(n) + c on every instance.

**Evidence.** `s1_q2_counterexample.py/.out`. It checks the disjointness and Gibbs steps exactly for n ≤ 14 and the binomial bound for n ≤ 4096. With Elias-δ as a computable upper bound on K(n), it tabulates the gap lower bound: for example ≥ 1 048 536 − c bits at n = 2^20.

**Fix.**
* Mark Q2 refuted, with this counterexample.
* A correct individual-sequence statement is available, though weak. **L_F(D) ≤ L_ξ(D_σ) + I(x_σ : D) + c**, with I(a : b) := K(b) − K(b ∣ a).
  * *Proof.* L_F(D) ≤ K(D) + c, by (F3) applied to the lookup-table program. And K(D ∣ x_σ) ≤ K(y_σ ∣ x_σ) + c ≤ L_ξ(D_σ) + c, by the conditional coding theorem applied to y_{1:n} ↦ ξ(y_{1:n} ‖ x_{1:n}). That is a semimeasure in y_{1:n}, by iterating the chronological inequality, and it is lower semicomputable uniformly in x_{1:n}.
  * *Why it is weak.* I(x_σ : D) also counts what x_σ says about dom D, for example K(S) when the labels are constant.
* So the right individual-sequence quantity is still open. Thm 5.4 shows that order information alone is not it.

### M4 (new). The comparison with SI's conditional label loss misses a two-line reduction, and Q3 follows under the notes' own hypothesis

**Claims.**
* Row 4.7 (line 28) and §4.4 (lines 329–332).
* Q3 (line 408): "Whether L_ξ ≤ L_M^y + O(1) on every sequence is open".
* The verdict on H4 (line 334): "It fails in one direction for unnormalised SI if LHG's failure means unbounded loss, and it is open in the other".

**Problem.**

*The reduction.* Let x_i = δ(h_{i−1}) for a computable deterministic δ. Put ν(x_1 y_1 …) := 1[x_i = δ(h_{i−1}) ∀i] · ξ(y ‖ x), defined also on sequences that end with an input block. ν is a lower-semicomputable semimeasure on block sequences:
* summing over the next input leaves only δ(h);
* summing over the next label uses ξ's chronological inequality.

Lemma B then gives M(code(h_n)) ≥ 2^{−K(δ)−c} ξ(y‖x). Together with Thm 4.6(a), on every δ-consistent sequence:

  **L_M^x − K(δ) − c ≤ L_ξ − L_M^y ≤ L_M^x + c.**

So for computable deterministic input policies, "L_ξ ≤ L_M^y + O(1)" is *equivalent* to "unnormalised M has bounded loss on the δ-determined input blocks".

*Applying LHG.* Take δ(h) := the last label, so x_{i+1} = y_i. The joint sequence is x_1 y_1 y_1 y_2 y_2 …, in which every input repeats the preceding label. That is exactly the Lattimore–Hutter–Gavane pattern ("each even bit equals the preceding odd bit"), with the inputs as the copied bits. The notes use LHG with the roles exchanged, labels copying inputs, to disprove L_M^y ≤ L_ξ + O(1). Under the same transfer hypothesis, L_M^x is unbounded on some label sequence, so L_ξ − L_M^y ≥ L_M^x − K(δ) − c is unbounded. That answers Q3 negatively for unnormalised M.

*The hedge.* "If LHG's failure means unbounded loss" is the wrong condition. Non-convergence to 1 on infinitely many selected bits, by a fixed margin, already forces unbounded cumulative log loss. The one genuinely unverified step is the transfer from raw bits to the code(·) block format, which adds framing bits.

*By-products.*
* Thm 4.6(d) strengthens to L_M^joint ≤ L_ξ + K(δ) + c.
* Q5 holds for computable deterministic δ: L_M^joint ≥ L_ξ − c ≥ L_ξ + L_ξ′^x − K(δ) − c′.

**Evidence.**
* The proof above. Each step uses only Lemma B and Thm 4.6(a) of the notes.
* `s3_defect_transfer_toy.py/.out`, an exact toy. It is a two-component mixture M satisfying both domination facts used above: M ≥ ½·1[δ]·ξ_toy, and M(h) ≤ ξ_toy(y‖x). In it, L_M^x = L_ξ − L_M^y = n log₂(4/3) (16.601 bits at n = 40), and L_M^x + L_M^y = L_ξ.
* So nothing structural keeps L_M^x bounded. Whether the universal M behaves like this is LHG's question; the toy is not universal.

**Fix.**
* Add the identity as a proposition.
* Rewrite row 4.7, Q3, Q5 and the H4 verdict. Suggested wording: "For unnormalised M, and conditional on LHG's failure transferring to the block format, neither L_M^y ≤ L_ξ + O(1) nor L_ξ ≤ L_M^y + O(1) holds on all sequences. For computable deterministic input policies the difference L_ξ − L_M^y equals M's loss on the inputs up to K(δ) + O(1)."
* The normalised-M versions stay open.

### M5 (new). §7: the prefix-free program mixture does not pay ≈ K(n)

**Claim (line 427).** "With prefix-free deterministic programs, labels that are random bits cost an extra ≈ K(n) [proof sketch: a prefix-free program that outputs n random labels must encode n]."

**Problem.** The claim is false for the program mixture W_hist that the sentence is about. The sketch's premise is wrong: a consistent program need not stop after n labels, so it need not encode n.

*The bound.* For every N ≥ n, the program ⟨N⟩w, with w ∈ {0,1}^N extending y, is consistent. It answers the i-th query with w_i. Summing over these programs, for every y ∈ {0,1}^n and every input list,

  W_hist(y‖x) ≥ 2^{−n−c} Σ_{N≥n} 2^{−K(N)}.

*How small the extra is.* The extra over 2^{−n} is at most τ(n) := −log Σ_{N≥n} 2^{−K(N)} + c ≤ min_{N≥n} K(N) + c ≤ K(⌈log₂ n⌉) + c. Moreover τ(n) ≤ g(n) + K(g) + c for every computable nondecreasing unbounded g. The reason: the discrete universal semimeasure dominates the computable measure with tail 2^{−g(n)}. So τ grows more slowly than every computable unbounded function, whereas K(n) ≥ log n for most n.

**Evidence.** `s2_prefix_mixture_extra.py/.out`. In a toy program language ⟨N⟩_δ w, with Elias-δ, for which K(N) ≤ len_δ(N) + c:
* For n ≤ 6, brute force gives W(y)·2^n = T(n) := Σ_{N≥n} 2^{−len_δ(N)} exactly, for every one of the 2^n label strings.
* The extra −log₂T(n) stays ≤ log₂(log₂ n + 1) + 2 up to n = 2^200, where it is 7.48 bits. At that n, len_δ(n) = 215.

**Fix.**
* Replace the remark by the bound above and mark it proved.
* State that the single-shortest-program (Kolmogorov) version is not settled by the sketch.
* Severity: this is a side remark, but it is a false quantitative claim on the Kolmogorov-versus-semimeasure question that Hänni asked for. The partial `notes-final.md` (Prop. 4.10) already corrects it to κ(n) = min_{L≥n} K(L). The tail form above is slightly sharper and shows why no K(n) appears.

### M6. The literature check for H4 is incomplete

The brief asks: "Check what is known (Hutter 2005 book; papers on universal prediction with side information or actions)".

1. **Hutter's "Supervised Learning from Examples (EX)".**
   * Search snippets show that Hutter's *Universal Algorithmic Intelligence: A mathematical top→down approach* (IDSIA-01-03, arXiv cs/0701125) has a section "Supervised Learning from Examples (EX)", with a subsection "Supervised learning with the AIµ/XI model". One snippet lists it as §5.4.
   * An abstract in the same search results lists "sequence prediction, strategic games, function minimization, reinforcement and supervised learning" as problem classes the AIXI model can formally solve. I believe, unverified, that the same section is in arXiv cs/0004001 and in the 2005 book, ch. 6.
   * This is the closest prior use of the universal chronological mixture ξ for learning a function or relation from presented examples, so it is prior work for SFI^hist and Cor. 4.3. Content **unverified**.
   * The notes must check and cite it, and hedge any novelty claim for Cor. 4.3.
2. **Solomonoff's operator induction.**
   * R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008, doi:10.1093/comjnl/bxm120.
   * The third kind extrapolates "an unordered set of ordered pairs": given the first element of a new pair, predict the second. Title, venue, DOI and abstract are confirmed by snippets; the content is **unverified**.
   * It is the historical precursor of SFI, and it bears on Prop. 5.1 and on the x-only versus history-aware distinction.
   * The foundations track identifies its M_prod with operator induction. Its `notes.md` line 157 says "The history track should confirm the match". The history notes do not mention operator induction.
3. **The literature status of Thm 4.2.**
   * From memory (unverified), Hutter defines his AI prior both through chronological programs and as a mixture over enumerable chronological semimeasures. A snippet of cs/0004001 confirms only that he proves the class of enumerable chronological semimeasures is enumerable.
   * The exact identity between machine-generated and lower-semicomputable priors in the *sequence* case is the subject of I. Wood, P. Sunehag, M. Hutter, "(Non-)Equivalence of Universal Priors" (arXiv 1111.3854; Solomonoff 85th Memorial Conference, LNAI, doi:10.1007/978-3-642-44958-1_33). The snippet says "the constructions of Solomonoff and Levin define an identical class of priors".
   * Thm 4.2 is the chronological analogue. Mark it "known in substance? (unverified)" until checked. Cite WSH as context.
4. **The LHG venue.** The volume is *Lecture Notes in Artificial Intelligence* 6925, a subseries of LNCS, pp. 262–276, doi:10.1007/978-3-642-24412-4_22. These were confirmed by snippets.

---

## Minor issues

I checked each of these myself. m1–m17 coincide in substance with the earlier report.

| # | Where | Problem | Fix |
|---|---|---|---|
| m1 | §3.5, remark "A pathwise version … is false" (line 243) | "Take f fixed" is not enough. For a generic f the chain paths need not exist. If f is computable, K(x_{1:n−1} ∣ x_n) = O(1) by iterating f. The counterexample needs f to be the chain function of an ML-random ω. | Specify that f. |
| m2 | Cor. 3.4 (line 173) | With repeated inputs, the actual sequence is not one of the "orders σ of D_n", so the second ≤ does not follow from the first. Each inequality holds separately by the same construction. | Prove the two separately, or assume distinct inputs. |
| m3 | Thm 5.2, proof (line 350) | "It costs \|p\| + c bits (F1)": (F1) gives K(T_p) ≤ K(p) + c. The \|p\| bound is true by another argument. A fixed machine runs U(·, x) on the tape; for x ∈ dom D it reads exactly p, because the program is self-delimiting given x. It then hands the rest of the tape to U_H. | Replace the appeal to (F1). |
| m4 | Thm 4.2, line 271 | The displayed "λ(S_t(z)) = min(…)" is not an equality when a sibling processed later in the same stage grows. Only ≥ holds, with the siblings' values at z's processing time, and only ≥ is used. | Write ≥. |
| m5 | Thm 4.2, statement | "M^hist_{T_ρ} = ρ exactly" fails at the root when ρ(ε‖ε) < 1. | Say "at every non-root node". |
| m6 | Row 4.7 and §4.4 (LHG) | The hedge is misplaced (see M4): non-convergence already gives unbounded loss. The real gap is the raw-bit versus code(·) format. | Rephrase. |
| m7 | Rows 2.1 and 2.2 | The O(1) in the lower bounds depends on ω (c_ω, from Levin–Schnorr). | Write c_ω. |
| m8 | (F6) and Thm 3.7 | (F6) is stated for a fixed condition w. Thm 3.7 needs E[K(Z ∣ W)] ≥ H(Z ∣ W) with W = x_n random. It holds by the same Kraft argument applied conditionally. | State (F6) in the conditional form. |
| m9 | Thm 3.6, proof ("replace f by f\|_A") | If the peeking kernel depends on f outside A, the reduction loses information. The identity still holds on the general space, since the x_i are finite-valued. | Drop the reduction, or assume Δ depends on f\|_A only. |
| m10 | Thm 5.6; the "Answer to item 3" paragraph | "Attained up to lower-order terms" holds only in the randomized chain. In the GF process, I(f→x) ≈ 2m, while E[L_F] − E[L_ξ] ≤ m + c: E[L_F] ≤ 2m + c, and E[L_ξ] ≥ E[L_B] = m (r1(E)). | Say "attained in the randomized chain". |
| m11 | Prop. 5.1, second sentence; §5.3 interpretation; item-3 paragraph | "It also cannot use the identity of the other inputs" is informal but labelled proved. It is also partly misleading: shared randomness lets SFI correlate with a guess of the other inputs. The exact optimum over all random functions on the GF triples is 4.35 bits at m = 3 (r3, from the earlier run; not re-run), against 6 bits for independent labels and m = 3 for ξ. | Reword, and drop "proved" from the informal part. |
| m12 | Thm 3.8 | The hidden K(A_·) term. | See M2. |
| m13 | §1.3, ξ | Hutter's setting has finite alphabets (from memory, unverified). Here X = Y = {0,1}*. | Define the universal chronological semimeasure as M_H, using Lemma 4.1 and Thm 4.2, and cite Hutter only for the identification. |
| m14 | Scripts versus notes | The current docstrings of c2, c3, c5 and c6 match the notes' theorem numbers. They were edited (21:15) after the outputs were saved (19:26–19:41). I re-ran all six scripts and the outputs are **byte-identical**. | Record the re-run in the verification log. |
| m15 | c2 (B) | The "private simulator" in c2 is normalised and truncated at horizon 3. Hänni's is unnormalised with unbounded horizon. The docstring now says so; c1 alone proves Prop. 3.1. | Say so in the verification log as well. |
| m16 | Q6 | "True growth about 2^{1.35m}" rests on local-search lower estimates for m ≤ 7. s4 proves only m ≤ 3 optimal; at m = 4 it finds no G better than 56 but cannot certify it. | Keep it as an observation, not a claim. |
| m17 | Row 4.4–4.5, "each gap unbounded" | For (i) and (iii), the separations are families of finite sequences indexed by n; only (ii) is a single infinite sequence. | Say "the supremum over finite sequences is infinite", or give single-sequence versions. |
| m18 (new) | Prop. 4.5(ii) | The K(n) term is superfluous. n is computable from x_n because ℓ is computable and injective, so K(x_{1:n−1} ∣ x_n, n) = K(x_{1:n−1} ∣ x_n) ± c. | Drop it. |
| m19 (new) | c4 | c4 processes every node at every stage, not the prefix z_1,…,z_t of the proof's enumeration. That is fine for a finite instance but is not the literal construction. r5 implements the literal one (0 mismatches). | Note it in the log. |
| m20 (new) | §1.4 (F9); Thm 3.8 | Sion is cited for the compact, continuous, convex/affine case. That is correct, but the +1 slack from the ½U mixture is a device for continuity only. c3 shows V ≤ 0 without it in all non-peeking instances. | Optional: remark that the slack is a technicality. |
| m21 (new) | Q4; rows 2.1, 2.2 | All the lower bounds that support Hänni's "SFI gets unbounded loss" are for −log M_F, not for the per-step normalised predictor one would actually use. The notes say this in one line (line 34). | The paper must state it next to each lower bound, not only in a footnote. |

---

## Claims I confirmed

I checked each of these line by line. Scripts are cited where they apply.

* **Lemma 1.1 and Lemma 1.2.** The labellings of a fixed domain give disjoint events, and the conditional coding theorem applies uniformly in S. ρ_F is chronological and lower semicomputable, so L_ξ ≤ L_F + c in every order.
* **Lemma 2.0 and Thm 2.1 (chain).**
  * Disjointness covers the first-difference, proper-prefix and cycle cases.
  * The upper-bound program is consistent at x_n, since the inputs are distinct.
  * The rate is L_{n−1} − K(ℓ_n) − c_ω ≤ L_F ≤ L_{n−1} + K(n) + c. The upper bound encodes n and then L_{n−1} raw bits.
  * The chain predictor has loss 0.
* **Thm 2.2 (skipped strings).** Hänni's predictor has loss 0, including at ℓ = 1. The tape-block machine gives 2^{−ℓ(ℓ+1)/2}. The counting and ML-random bounds hold.
* **Prop. 3.1.** I reproduced it by hand: g(a) and g(b) are independent uniform bits, so the loss is 2 bits against P's 1. c1 reproduces.
* **Thm 3.2.** Sequential sampler calls on fresh tape segments multiply. Distinct orders give disjoint trajectory prefixes of equal length. The machine is a function machine. Cor. 3.3 and Cor. 3.4 hold, apart from m2.
* **Thm 3.5.** The posterior given (h_{i−1}, x_i) is π restricted to {f ⊇ D_{i−1}}, because the selector term factors out. Telescoping and Gibbs (for semimeasure predictors too) give the rest. r1(A) re-runs it with private-memory selectors, in exact rationals.
* **Thm 3.6.** I re-derived the identity: μ(h_n) = π(D_n)Δ_D(x), the chain rule with I(f; y_i ∣ h_{i−1}, x_i) = E[−log μ(y_i ∣ ·)], and the KL term. r1(C) gives an identity error ≤ 3·10⁻⁶⁰.
* **Thm 3.7.** I recomputed I(f→x) = Σ_i i = n(n+1)/2 and E[−log π(D_n)] = n(n+1)/2 (r1(D) brute force for n ≤ 4). See M1 for the framing.
* **Thm 3.8 (the mathematics, under its stated hypotheses).**
  * The Sion setting is correct: compact simplices, Φ continuous because G ≥ ½|Y|^{−n}, convex in G, affine in π.
  * V ≤ 1 + C_dir is correct.
  * The Lipschitz constant is |Y|^n / ln 2, and the grid search finds a G with max_f Φ_f ≤ V + 1 uniformly.
  * c3 reproduces. The earlier referee run's r2 gives certified brackets with V ≤ 1.8·10⁻¹⁵ on 72 non-peeking instances (not re-run here).
* **Lemma 4.1, Thm 4.2 and Cor. 4.3.**
  * The invariants (I1)–(I4) hold.
  * The limit argument is correct by induction along the parent-first enumeration (m4 and m5 aside).
  * The machine's event equals S(z) by (I1) and (I2).
  * c4 and r5 reproduce (0 mismatches).
* **Prop. 4.4 and Prop. 4.5.** The recursion in (a) holds. In (i) there is a balanced subset with K(A ∣ S) ≥ log C − 1, and C(n, ⌊n/2⌋) ≥ 2^n/(n+1) (s1 checks n ≤ 4096). In (ii) the time-stamped chain is determined by iteration. In (iii) backward reconstruction gives at most n consistent orders (c6 for n ≤ 5, r4 for n = 6, 7).
* **Lemma B and Thm 4.6 (a)–(d).** I checked the case split in Lemma B. A block of B(z0) either lies in B(z) with code ≠ z, or is a one-block extension of a b′ with code(b′) = z, using that codes are nonempty and prefix-free. The four inequalities follow. r4(b) reproduces.
* **Thm 5.2 and Cor. 5.3.** Correct (m3 concerns only the proof's wording). KH(e-order) ≤ K(e) + c because e is injective.
* **Lemma 5.5 and Thm 5.4.**
  * H Hᵀ = 2^m I.
  * The partial-G and a = b reductions hold.
  * Ordered pairs are counted on both sides of Σ_{a≠b,r} M_F(D_abr) = E_ω N(U^ω).
  * The Jensen bound 3m/2 − 2 is constant-free and correct. D_{abr} = D_{b,a,r+ab} is harmless, since both sides count ordered pairs.
* **Thm 5.6.** Correct (m10 aside).
* **Computed claims.** c1–c6 re-run with byte-identical outputs. Python 3.11.15, numpy 2.4.6 and scipy 1.17.1, as the log says.

---

## Important questions the track missed or left thin

1. **Reading C and its mutual-information question** (M1). This is the central open item for H3.
2. **Thm 1 for computable samplers** (M2), Hänni's actual class. Also the private-memory selectors that his "distribution over reveal sequences" allows.
3. **The H4 comparison with SI** (M4). The notes left the main open direction where two lines of their own lemmas, plus LHG, settle it conditionally.
4. **Literature for H4** (M6). Hutter's EX section, operator induction, and WSH as context for Thm 4.2.
5. **H5 cross-reference.** The brief says "SFI^hist also does well" on the cyclic permutation. By Cor. 4.3(b), the predictor "0^{|x|} first, then the previous input" gives L_H ≤ c on every instance. The notes give only SFI's side (Cor. 5.3).
6. **A correct individual-sequence characterisation** after Q2 falls (M3). The notes have the sandwich of Thm 5.2. The weak information form L_F ≤ L_ξ + I(x_σ : D) + c given in M3 is new here. Which quantity is tight remains open.
7. **Q1 (the K(n) term).** It is open. The earlier run's r6 and r7 give a certified positive horizon-free cost (≥ 0.026 bits in one instance) and no growth up to horizon 6. That is weak evidence that the K(n) is an artefact.
8. **Q4 (normalised SFI).** It is open, and it matters for how Hänni's "unbounded loss" claims are stated (m21). The normalised conditionals are ratios of left-c.e. reals, hence 0′-computable. That suggests a relativised coding argument, but Lemma 2.0's disjointness does not obviously survive conditioning on halting. I did not settle it.

---

## References checked (snippets only)

| Reference | What I could confirm |
|---|---|
| Lattimore–Hutter–Gavane, "Universal Prediction of Selected Bits", ALT 2011, LNAI 6925, pp. 262–276, doi:10.1007/978-3-642-24412-4_22, arXiv:1107.5531 | Bibliographic data and abstract wording: normalised M "can detect any recursive sub-pattern", unnormalised "can fail to predict very simple recursive sub-patterns"; the even-bit pattern. Theorem numbers and the counterexample's form are **unverified**. |
| Hutter, arXiv cs/0004001 (2000) | Chronological semimeasures; enumerability of the enumerable ones. The notes' "eq. (27)" is **unverified**. |
| Hutter, arXiv cs/0701125 (IDSIA-01-03), "Supervised Learning from Examples (EX)" | Existence of the section (§5.4 per one snippet's table of contents). Content **unverified** (M6). |
| Hutter, *Universal Artificial Intelligence*, Springer 2005 | Not reachable. Chapter and section numbers **unverified**, as the notes say. |
| Solomonoff, *Comput. J.* 51(5):566–570, 2008, doi:10.1093/comjnl/bxm120 | Title, venue, DOI and the three kinds of induction. Content **unverified**. |
| Wood–Sunehag–Hutter, "(Non-)Equivalence of Universal Priors", arXiv 1111.3854; doi:10.1007/978-3-642-44958-1_33 | Authors and venue; the abstract's "identical class of priors" for Solomonoff's and Levin's constructions. |
| Sion 1958; Levin–Schnorr; the coding theorem; Zvonkin–Levin 1970 | Standard. Theorem numbers **unverified**, as the notes say. |

---

## Referee code (`referee_code/`)

| Script | Seed | Tests | Result |
|---|---|---|---|
| `s1_q2_counterexample.py` (new) | 31415 | M3. Disjointness and Gibbs steps over all labellings for n ≤ 14; C(n, ⌊n/2⌋) ≥ 2^n/(n+1) for n ≤ 4096; a gap table using Elias-δ as a computable upper bound on K(n). | All pass. The gap lower bound grows linearly (≥ 1 048 536 − c bits at n = 2^20). |
| `s2_prefix_mixture_extra.py` (new) | 0 (exact) | M5. In a toy prefix-free program language with Elias-δ: W(y)·2^n = T(n) for every y with n ≤ 6 (brute force), and the closed form of T up to n = 2^200. | Exact equality for all y. Extra −log₂T(n) ≤ log₂(log₂ n + 1) + 2 (7.48 bits at n = 2^200), against len_δ(n) = 215. |
| `s3_defect_transfer_toy.py` (new) | 2718 | M4. An exact two-component toy mixture satisfying both domination facts. | L_M^x = L_ξ − L_M^y = n log₂(4/3), and L_M^x + L_M^y = L_ξ. |
| `s4_gf_maxN_milp.py` (new) | 0 | m16 and Q6. max_G N(G) by MILP (HiGHS), with G(0) = 0 fixed by the constant-shift symmetry; independent recount of the optimiser. | m = 2, 3: proved optimal, max N = 8 and 22, which confirms c5 by a different method. Jensen bound E[L_F] ≥ 2.585 and 4.348 bits. m = 4: not closed within 600 s. The incumbent is 56, equal to c5's local-search value, and HiGHS's dual bound (186) is weaker than the analytic 80. So max N at m = 4 lies in [56, 80], and the exponent in Q6 stays undetermined. |
| `r1`, `r4`, `r5` (earlier run, re-run now) | 101, 4242, 55 | Exact Bayes and directed-information identities; the combinatorial lemmas; the literal Thm 4.2 construction. | Outputs byte-identical to the saved ones. |
| `r2`, `r3`, `r6`, `r7` (earlier run) | — | Minimax brackets; exact GF optimum for m = 2, 3; horizon-free value. | Not re-run (long). Cited only as the earlier run's evidence. |

---

## Status of these issues in the partial `notes-final.md` (for the reviser)

`notes-final.md` stops at `<!-- PART2 -->` after §3.7. Sections 4–9, the open questions and the verification log are missing.

* **M1:** handled (Reading C; Cor. 3.9; Conjecture 3.11).
* **M2:** handled in §3.5 (K(A), and the new case (b) for computable real-valued P and Δ). I read case (b) quickly and found no error, but I did not referee it in full. The private-memory reduction is not stated; add it.
* **M3:** not visible yet. **Do not carry Q2 into the new open-questions list.** Mark it refuted, with the Prop. 4.5(i) counterexample.
* **M4:** **not handled.** Summary row 4.7 of `notes-final.md` still says "Whether L_ξ ≤ L_M^y + O(1) on every sequence is open". Add the identity, and the conditional negative answer via inputs that copy labels.
* **M5:** handled by Prop. 4.10 (κ(n)). Optionally use the tail form.
* **M6:** operator induction is in row 4.9. Hutter's EX section is not mentioned anywhere; add it as unverified prior work, and also WSH as context for Thm 4.2.
* **Minors:** the summary of `notes-final.md` says m1–m17 are handled in a §9 that does not exist yet. m18–m21 are new.
