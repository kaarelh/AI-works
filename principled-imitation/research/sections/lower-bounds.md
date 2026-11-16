## 4. What no protocol can do

A *protocol* is any adaptive, randomised way of choosing questions, followed by any deployed system, which may see the whole run and may decline. Questions come before the z and ρ of the deployed run; n is their expected number. A run *fails* if its outcome is declined or differs from the human system's on the same z and ρ. "There" means `proofs/lower-bounds.md`.

### 4.1 No coverage, no guarantee

**Theorem N1** (proved here; the standard two-point argument). Let samplers P and P′ agree outside a set Q, into which the protocol asks with probability γ (the same for both). Let R and R′ be the laws of the deployed answer at an input x, "declined" included, under P and P′. Then

  TV(R, P(·|x)) + TV(R′, P′(·|x)) ≥ TV(P(·|x), P′(·|x)) − γ.

For functions with f(x) ≠ f′(x), the probabilities of a wrong or declined answer at x under f and f′ sum to at least 1−γ. Whole deployed runs under P and P′ are within γ in total variation.

*Proof.* With the same coins the two interactions coincide until the first question in Q. So the data, and the deployed answer or run computed from them with fresh randomness, differ with probability at most γ; hence TV(R, R′) ≤ γ. The display is the triangle inequality; for functions use R(f(x)) + R(f′(x)) ≤ 1 and R′(f′(x)) ≤ R(f′(x)) + γ. ∎

Among all programs, P′ exists for every decidable Q containing x and no asked input, at K(Q)+c bits more for a deterministic human. A human who may answer any string at x has no partner with a disjoint answer law, only partners at total variation 1−1/N, for a further log₂N + 2·log₂log₂N bits (N ≥ 2). The mixture's weight on such partners was known (Paper 2, Proposition G.5; Cohen, Hutter, Bengio and Russell 2025); N1 covers every protocol.

N1 needs the pair in the class and concerns one input, which by R1 and R7 deployed runs rarely meet.

### 4.2 Critical calls are not amplified

**Theorem N2** (proved here). Let δ ≤ 1/6 and N := ⌈L/(2δ)⌉. The inputs are 1, …, N; the class is the zero function f₀ and the functions f_i that are 1 at i only. The scaffold draws L uniform inputs, asks each, and outputs 1 if some answer was 1. If the deployed run fails with probability at most δ for every member, then, counting n under f₀,

  n ≥ L/(4δ) − 3L/2, and n ≥ L/(4δ) − L if L/(2δ) is an integer.

A random half of the inputs suffices.

*Proof.* Weight f₀ by L/(N+L) and each f_i by 1/(N+L); fix the protocol's coins. Under f₀ it asks a set A; under f_i with i ∉ A it gets the same answers and deploys the same system. Let U count the distinct inputs of the deployed run outside A. If the output is not 0 the run fails under f₀; if it is 0 it fails under the U functions f_i met. As U ≤ L, the weighted average failure is at least E[U]/(N+L), and E[U] ≥ (N−n)·p, where p := 1−(1−1/N)^L is the chance that the run meets a given input. So n ≥ N−δ·(N+L)/p; the bounds follow (Corollary 2.2 there). For the converse deploy the function seen, else f₀: failure at most p/2 ≤ δ. ∎

Here K ≤ log₂(L/(2δ)+2); rehearsal reaches failure δ with L·K ln 2/δ questions (R1): the factor L/δ is forced, the factor 4·K ln 2 is left. For one call this is the star-number bound of active learning, with the same argument (Hanneke and Yang 2015, Theorem 3, crediting Dasgupta).

N2 does not bound a Bayes risk: if the prior gives the f_i together under half the weight, deploying f₀ unasked fails with probability below δ. Nor does it count critical calls: it counts the places they fall on that the class can change one at a time. Asking one input L times costs one question.

**Proposition N2a** (proved here: Proposition 2.5 there). With ⌈L/√(2δ)⌉ cells, even a protocol that sees z before asking needs n ≥ L·(1−√(2δ)−δ)−δ. N2's factor 1/(4δ) pays for preparing before the task is known.

### 4.3 The factor K; targeted questions

**Theorem N2b** (proved here: Theorem 3.1 there). Let δ ≤ 1/20 and N := L/(2δ) an integer. The inputs form d blocks of N cells; a member is 1 at one cell per block: 2^K members, K = d·log₂N, of VC dimension d. The scaffold draws a block and L uniform cells of it and outputs 1 if some answer was 1. Failure at most δ for every member needs, in expectation over a uniform member,

  n ≥ (1−10δ)·d·L/(8δ) = (1−10δ)·K·L/(8δ·log₂(L/(2δ))),

and ⌈d/2⌉·(L/(4δ)+1/2) suffice. The blocks are d separate searches; covering a fraction κ of one costs at least κ·N/2 questions.

So questions grow linearly in d; in bits like K·L/(δ·log₂(L/δ)), and no faster:

**Proposition N2c** (proved here: Theorem 3.3 there; a known algorithm). Let the human be a function in a class of functions, and L/ε ≥ 16. *Protocol AB:* while some input occurring in a run answered by a member has no answer of posterior weight above 1−ε·log₂(L/ε)/L, ask it. Otherwise let the weighted vote of the unrefuted members answer a rehearsal run, and ask one random call of it. Deploy the vote of a random such run. With their number chosen from K, the deployed run is unfaithful with probability at most ε after at most 1 + 2.7·K·L/(ε·log₂(L/ε)) questions. It is the membership-query algorithm of Hegedűs (1995) and Moshkov (1983), as in Bshouty (2017, Lemma 3), with prior weights and with audits of runs.

Random questions cannot match this everywhere: on a class with K rare informative inputs, random calls of runs need n ≥ 0.1·K·L/ε−0.4 for failure ε, a seventh of what R1 guarantees, where K chosen questions suffice (Proposition 3.7 there; found and checked by the two verifiers). On the classes of N2b rehearsal is within a constant factor of optimal (Proposition 3.10 there).

N2c has no version for a human who is not deterministic, and its chosen questions follow answers that the human perhaps never gives; A2 is used there.

### 4.4 What low stakes requires

**Theorem N5** (proved here: Proposition 5.6 there). Let N := g/(2δ) be an integer. There are N regions of 2k+1 inputs; the class is f₀ and the indicators of regions. The scaffold draws g regions, asks each region's inputs in turn until k+1 answers agree, and outputs 1 if some region gave 1; L = g·(k+1)+k. Each member's human system tolerates k faults with failure 0, yet failure at most δ for every member needs

  n ≥ (1−4δ)·(L−k)/(4·(k+1)·δ).

By R3, L·K ln 2/((k+1)·δ) questions suffice: tolerance divides the price by k+1 on both sides. What remains is the factor K (see N8) and constants. The example repeats one question to a deterministic human; that guards against the imitator's errors only.

### 4.5 A human who is not deterministic

**Theorem N6** (proved here by Assouad's method: Theorems 6.1, 6.3 there). Take the 2^K samplers on K inputs that answer 1 with probability 1/2±b at each input, and an imitator trained with n questions and then used; its error is the expected total variation between its law and the human's. Error at most ε for every member needs n ≥ K/(512·ε²) for one call at a uniform input (b = 4ε ≤ 1/4), and n ≥ L·K/(8192·ε²) for runs of L calls at one uniform input (b = 16ε/√L, ε ≤ 1/64).

By R1 and R2 rehearsal achieves these errors with K ln 2/(2ε²) and 4·L·K ln 2/ε² questions: the rates are right, with no logarithm to save. For a single use, replaying a recorded answer is exact.

### 4.6 What imitation amplifies

**Corollary N2d** (proved here: Proposition 7.2 there). For a deterministic human, a protocol asks n questions, then answers r runs of horizon L; F bounds, for every member, the expected number of failed runs; δ := F/r. The *amplification* r·L/n is answers replaced per answer spent.

(a) Class of N2 with L/(2δ) cells, every protocol: r·L/n ≤ 4F/(1−4δ).
(b) Class of N2b, every protocol: r·L/n ≤ 8F·log₂(L/(2δ))/((1−10δ)·K).
(c) Rehearsal, every class, scaffold and member: r·L/n ≥ F/(K ln 2 + δ/L); under tolerance of k faults K ln 2 becomes K ln 2/(k+1).

(a) and (b) are worst cases over classes matched to L and δ = F/r: the class grows with r, and a fixed class never needs more questions than it has cells. By (a), a guarantee for every member saves no human work unless failed runs are allowed: F < 1/4−δ gives amplification below 1. Imitation saves work across runs, at a price: by (c) rehearsal breaks even once K ln 2 failed runs are allowed, and by (b) no protocol does before (1−10δ)·K/(8·log₂(L/(2δ))). For a person (K near 10⁹ bits under a generic prior) that is millions of failed runs: (c) is then empty.

---

## For Section 6: lower bounds for inputs from outside

**Theorem N3** (proved here: `proofs/lower-bounds.md`, Theorem 4.1). Let Q₁, …, Q_N be disjoint sets of inputs; the class is the zero function and the indicators. Under *shift i* the task is one call at an input drawn from a law on Q_i. If the deployed answer is right with probability at least 1/2+a under every shift for every member, then n ≥ 2aN, counting n under the zero function; 2aN questions suffice.

One question in a random region gives 1/2 + 1/(2N) everywhere, so only protocols without coins need a question in every Q_i. There are 2^ℓ disjoint decidable sets of complexity at most ℓ+2·log₂ℓ+c, so robustness to all shifts of ℓ bits costs 2a·2^ℓ questions up to a factor polynomial in ℓ. With L critical calls per shift it is N·(L/(4δ)−3L/2) (Theorem 4.3 there).

**What S2 needs** (proved here: Propositions 4.4 and 4.6 there). If rehearsal draws z from a mixture Σ_i π_i·D_i of task laws, a bound β on the expectation over z of a nonnegative quantity becomes β/π_i under D_i (standard domination); for N disjoint laws the factor N is necessary (N3). The mixture must be sampled, which is possible for samplers given uniformly that halt, such as all programs p under a fixed time bound (π_p = 2^(−2|p|−1)). No sampler that halts with probability one dominates every law that such samplers produce; the universal mixture does, but no halting program samples it (a halting oracle suffices). With time bounds growing with the round, ordinary computation gives, for a deterministic human, every such law D, sampled by p_D, the factor 2^(2|p_D|+1) plus the average over rounds of the probability that p_D exceeds the bound; this tends to 0 at a rate depending on D, never uniformly.

---

## Notes for the lead (not part of the note's text)

**Length.** Counted with `wc -w`, headings and formulas included: Section 4 has 1,500 tokens, of which 56 are operator signs standing alone in formulas; the block for Section 6 has 299, of which 4 are such signs. To fit, inline formulas are written without spaces inside brackets, and pointers use "there" for `proofs/lower-bounds.md` (defined in the first paragraph of Section 4; the block names the file once).

**Labels.** N1, N2, N5, N6 as assigned; N3 and "what S2 needs" in the block. Sub-labels introduced here, on the model of R3a: N2a (the human stays available during the run), N2b (the factor K), N2c (targeted questions: Protocol AB, with the lower bound for rehearsal on the rare-points class), N2d (the corollary on amplification). Renumber as needed.

**Letters.** k tolerated faults; d number of blocks in N2b (its VC dimension); g number of regions drawn in N5; b the bias in N6 (θ is kept for the tolerated fraction); a the advantage in N3 (η is kept for the threshold); ℓ bits in N3; γ in N1 is the probability of a question in Q (the draft used γ for the failure probability of N2, which is now δ); κ a fraction of a block in the remark on N2b. The proof file keeps its own letters and lists the correspondence at the end of its Section 0.

**What changed relative to the draft of Section 4 in `note.md`.** N1 is stated in its total-variation form, which covers answer laws that overlap, with whole runs added. The sentence on the class of all programs is corrected (a partner with a disjoint answer law does not exist for a human with full support at x). The attribution of the earlier finding follows the outline's Addendum 2, item 3; it was not checked by the editor. N2 has the class with ⌈L/(2δ)⌉ cells and the constant 1/4 instead of 1/16, with tightness; "16·K ln 2" is now 4·K ln 2. The bracketed sentence on the factor K is replaced by N2b and N2c. The last paragraph ("read as a statement about work") is replaced by N2d, which names the classes, says that the class grows with r, and says where the positive half is empty.

**Left out for length; all in the proof file.** (1) Abstention: a system that is never silently wrong for either human declines at x with probability at least 1 − γ, and under a shift that was not paid for it declines with probability at least 1 − π_i − 2σ (Corollary 1.7, Remark 4.5). This belongs with N4 and Ab4 in Section 7. (2) The limit of the method under tolerance: for no scaffold does the argument of N2 give more than L/(4(k + 1)δ) (Proposition 5.6(a)); the version of N5 that asks all 2k + 1 copies has 2k + 1 in place of k + 1 (Theorem 5.3). (3) With targeted questions, 1 + 2.7·K·L/((k + 1)δ·log₂(L/((k + 1)δ))) questions suffice under tolerance of k faults (Proposition 3.8). (4) A variant of rehearsal that asks only calls of its own runs and saves the factor ln(L/ln L) (Proposition 3.9). (5) A protocol without coins is defeated by one hypothesis of K(f₀) + K(protocol) + c bits (Remark 1.11): the lower-bound side of A3. (6) Theorem G.1 of Foster, Block and Misra uses the class of N2 (the related-work section says so). (7) The exact numbers for a person in N2d: for L = 1000, δ = 0.01, K = 10⁹, rehearsal needs 6.9·10¹³ questions and breaks even after 6.9·10⁸ allowed failed runs; no protocol breaks even on the classes of N2b before 7.2·10⁶ (table at the end of Section 7 of the proof file). These fit Section 9.

**For other sections.** (a) Section 3 on low stakes: the candidate's "sharper form" of R3 holds for a deterministic human as failure ≤ δ̄_Π(min{L, L·K ln 2/n}) (Proposition 5.2), for a human who is not deterministic only with L·√(K ln 2/(2n)) (Proposition 5.7, with an exact counterexample to the other form), and its converse half is false (Example 5.5). (b) The draft's sentence in Section 3.2, "Section 4 shows that no protocol avoids this when every call is critical", should say "for classes that can change many places one at a time". (c) Section 5.1: by Proposition 3.8 one deterministic function per run can match the per-call mixture in the number of unfaithful calls, so R5 must be about members of the class drawn from the posterior, as the outline already words it. (d) Section 0: "optimal up to the factor K" should become: the least number of questions over classes of K bits is of order K·L/(δ·log₂(L/δ)); rehearsal's own worst case is of order K·L/δ, within a factor 7 of R1. (e) Section 6: in S2 the factor is exactly 1/π_i; Proposition 4.6 is for a deterministic human.

**Not checked in this part.** R1 for a general human, R3, R7, the constant in R2 (the comparison in N6 uses E TV ≤ 2·√(L·K ln 2/n) from the outline), N8, and the reference "Paper 2, Proposition G.5".

**Who checked what.** Section 12 of the proof file. In short: every statement above was checked by a verifier who is not its author or re-derived by the editor. Proposition 3.10 there (rehearsal needs at most 2·d·L/δ rounds on the classes of N2b), on which the last sentence of the paragraph after N2c rests, is the editor's own and was not seen by a verifier; it agrees with the exact computations of both verifiers.

**References to add to the note's list** (full data and what was read: Section 11 of the proof file). N. H. Bshouty, arXiv:1706.03935 (2017), Lemma 3; T. Hegedűs, COLT 1995, pp. 108–117; M. Y. Moshkov, Problemy Kibernetiki 40, pp. 131–170 (1983); S. Hanneke and L. Yang, arXiv:1410.0996 (JMLR 2015), Theorem 3; S. Dasgupta, NIPS 17 (2004) and NIPS 18 (2005). Bshouty and Hanneke and Yang were read in the source by the second verifier and by the editor; Hegedűs, Moshkov and Dasgupta were not opened by anyone.
