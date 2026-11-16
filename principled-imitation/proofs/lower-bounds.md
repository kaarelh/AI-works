# Lower bounds: what no imitation protocol can do (N1, N2, N3, N5, N6, the dependence on K, what S2 needs)

Proofs for Section 4 of the note and for the lower bounds of its Section 6. This file is the proof file `research/prove/lower-bounds.md` of the first worker ("the prover"), corrected by the editor of this part after two verification reports: `verification/lower-bounds-check.md` ("the check report", a line-by-line check) and `verification/lower-bounds-attack.md` ("the attack report", an adversarial reading). Statements that the two reports added (Propositions 3.7 to 3.9, 4.6, 5.6, 5.7 and 7.2, Remark 1.11) are marked with their origin; Proposition 3.10 is the editor's. Section 12 lists every finding of the two reports with what was done about it, and says for each statement used in the note who checked its proof. Scripts and their saved outputs are in `proofs/code/` (`lower-bounds_*.py`, `lower-bounds_*.out`); Section 8 says what each one does.

"The candidate theory" is the lead's list of claims `research/candidate-theory.md` (version 2), which the prover was asked to check. Where a statement below corrects it, this is said.

## 0. Summary

The column "note" gives the label under which the statement appears in the note (Section 4, or the block for Section 6). The column "status" says whether the statement is as the prover wrote it or was changed, and where it corrects the candidate theory. Who checked each proof is in Section 12.2.

| # | statement | note | status |
|---|---|---|---|
| Lemma 1.5 | Two samplers that agree on a set A give the same transcript law up to the probability γ that the protocol asks outside A | tool | proved |
| Theorem 1.6 | N1 for randomised adaptive protocols and randomised, history-dependent, abstaining deployed systems: failure sum ≥ 1 − γ; run laws differ by at most γ; for one call, TV(R, P) + TV(R′, P′) ≥ TV(P, P′) − γ | N1 | proved; sharpens the candidate's N1 (quantitative in γ, overlapping answer laws, whole runs). The argument is the standard two-point argument |
| Corollary 1.7 | Sum of the two silent-error probabilities ≥ 1 − γ − (abstention probability); never silently wrong on both ⇒ silent with probability ≥ 1 − γ | N1, remark on abstention | proved; a known fact in selective classification (Section 11) |
| Proposition 1.8 | Universal class: for a function f, a patch f_x with K(f_x) ≤ K(f) + sep(x; A) + c. For a sampler P whose answer at x has full support no sampler (probability kernel on Y) has P_x(·\|x) ⟂ P(·\|x); replacement: TV ≥ 1 − 1/N at K(P) + sep(x; A) + log N + 2 log log N + c. If members may give no answer, the patch of sep(x; A) + c bits exists for every human who always answers | N1, sentence on the class of all programs | proved; part (4) added after the attack report (the verdict on the candidate's sentence depends on the convention for samplers) |
| Lemma 1.10 | Patch-family lemma: N disjoint patches of influence ≥ Δ force failure ≥ (N − n)Δ/(N + M) | tool for N2, N3, N5 | proved; for one call it is the star-number argument of active learning (Section 11) |
| Remark 1.11 | A protocol that chooses its questions without coins is defeated by one member of complexity K(f₀) + K(protocol) + c | remark | from the attack report; proved |
| Theorem 2.1 | N2 exact: needle class with N₀ cells, L calls: every protocol has max failure ≥ (N₀ − n)p/(N₀ + L), p = 1 − (1 − 1/N₀)^L | N2 | proved |
| Corollary 2.2 | Failure ≤ δ for all members needs n ≥ L/(4δ) − L (N₀ = L/(2δ) an integer) and n ≥ L/(4δ) − 3L/2 (N₀ = ⌈L/(2δ)⌉, δ ≤ 1/6); the candidate's class N₀ = L/ε with failure ε/4 needs n ≥ (3/4)(1 − ε)L/ε | N2 | proved; improves the candidate's L/(2ε) |
| Proposition 2.3 | Tightness: a protocol with max failure (1 − n/N₀)p; for N₀ = L/(2δ), ⌈L/(4δ)⌉ questions suffice | N2 | proved |
| Proposition 2.5 | Even if the human may be asked after z is seen, during the run: n ≥ L(1 − √(2δ) − δ) − δ | N2a | proved |
| Theorem 3.1 | Factor K: block class of 2^K functions, K = m·log N, VC dimension m: average failure ≥ p(1 − 2L/N − 2n/(mN)); failure ≤ δ needs n ≥ (1 − 10δ)·m·L/(8δ) = (1 − 10δ)·K·L/(8δ·log(L/(2δ))) | N2b | proved |
| Proposition 3.2 | Tightness of Theorem 3.1 up to the factor (1 + O(δ))(1 + 1/m) in expected questions | N2b | proved |
| Theorem 3.3 | Protocol AB (plurality answers, targeted questions, random audits of runs): for every class of functions with weights and every scaffold, with L/ε ≥ 16, a deployed run is faithful with probability ≥ 1 − ε after at most 1 + 2.7·K·L/(ε·log(L/ε)) questions. Deterministic human; K is needed to choose the number of audits | N2c | proved; statement corrected (the set X₀, the count b, n_B ≥ 1). The algorithm is that of Hegedűs and Moshkov for exact learning with membership queries, with audits of runs (Section 11) |
| Corollary 3.4 | In terms of the VC dimension d: every protocol needs (1 − 10δ)·d·L/(8δ) questions for some class and scaffold. In terms of bits K = log(1/w): "every protocol needs c·K·L/ε" is false; the worst case over classes of K bits is of order K·L/(ε·log(L/ε)) (constants 1/8 and 2.7) | N2b, N2c | proved; item 5 reworded (what is and is not shown about Protocol R) |
| Proposition 3.7 | Rare-points class: rehearsal with random questions needs n ≥ 0.1·K·L/ε − 0.4 rounds where K chosen questions suffice; so R1 is sharp for Protocol R up to a factor 7 | N2c | from the check report; re-derived in the attack report and by the editor |
| Proposition 3.8 | Protocol AB bounds the expected number of faults; with tolerance of m faults, 1 + 2.7·K·L/((m+1)δ·log(L/((m+1)δ))) questions suffice | N5, sufficient side | from the check report; proof followed in the attack report, re-derived by the editor |
| Proposition 3.9 | A variant that asks only calls of its own rehearsal runs and does not need K: failure ≤ K·L/(n·log(L/ln L)) | remark to N2c | from the check report; proof followed in the attack report, re-derived by the editor |
| Proposition 3.10 | On the block class Protocol R reaches failure δ with 4·m·N = 2·m·L/δ rounds: within the factor 16/(1 − 10δ) of Theorem 3.1 | N2c | added by the editor; not seen by the verifiers; agrees with their exact computation and simulation (3.4 to 3.8 times m·N) |
| Theorem 4.1 | N3 exact: with N disjointly supported shifts, advantages over 1/2 satisfy Σ_i 2η_i ≤ n; right with probability ≥ 1/2 + η everywhere needs n ≥ 2ηN, and n = 2ηN suffices | N3 | proved; corrects the candidate's N3 (false as stated for randomised protocols: one question gives probability > 1/2 everywhere) |
| Corollary 4.2 | 2^k disjoint decidable regions of complexity k + K(k) + c; the largest number of disjoint decidable regions of complexity ≤ k is 2^(k − K(k) + O(1)) | N3 | proved (the count rests on the coding theorem, quoted from memory) |
| Theorem 4.3 | N shifts and an L-call scaffold: n ≥ N·(L/(4δ) − 3L/2) | N3 | proved |
| Proposition 4.4 | S2: (a) the domination inequality with B_i ≤ 1/π_i; (b) it is a protocol when the family of task laws is uniformly samplable; (c) no almost surely halting sampler dominates all samplable laws; the universal mixture does and needs an oracle | S2 | proved; makes "samplable" in the candidate's S2 exact |
| Proposition 4.6 | S2 with ordinary compute: time bounds that grow with the round give every samplable law the factor 2^(2\|p\|+1) plus an additive term that tends to 0 | S2 | from the attack report; re-derived by the editor |
| Proposition 5.2 | Upper bound through the robustness curve, deterministic human: failure ≤ (concave majorant of δ_Π)(min{L, L·K ln 2/n}); contains R3 | remark to N5 | proved (first half of the candidate's "sharper form" of R3, for a deterministic human only) |
| Theorem 5.3 | N5: block-majority scaffold tolerating m faults with failure 0: n ≥ (1 − 4δ)·L/(4(2m+1)δ) | N5 | proved |
| Proposition 5.4 | Packing: n ≥ N_Π(Δ)(1 − 2δ/Δ); on scaffolds whose inputs do not depend on the answers, members that all tolerate m faults allow at most L/((2m+1)Δ) disjoint patches of influence Δ | N5 | proved |
| Example 5.5 | "For classes closed under patches about L/β questions are needed to get below δ_Π(β)" fails for a scaffold that repeats one input | remark to N5 | refutes the second half of the candidate's "sharper form" of R3; replacement: Proposition 5.4(a) |
| Proposition 5.6 | Sequential-majority scaffold tolerating m faults: n ≥ (1 − 4δ)·(L − m)/(4(m+1)δ); for every scaffold, a family that tolerates m faults has patches of total influence ≤ L/(m+1). The factor is m + 1 on both sides | N5 | from the attack report (brute-force check there); re-derived by the editor |
| Proposition 5.7 | Robustness curve for a human who is not deterministic: failure ≤ δ̄_Π(min{L, L·√(K ln 2/(2n))}); the form with L·K ln 2/n is false for such a human | remark to N5 | from the attack report (exact counterexample there); re-derived by the editor; uses Theorem R1 of the part rehearsal-core |
| Theorem 6.1 | Human who is not deterministic, per call: class of 2^K samplers, E TV per call ≥ √(K/n)/(16√2); per-call TV ε′ needs n ≥ K/(512ε′²) | N6 | proved |
| Lemma 6.2 | TV(Bern(½+θ)^L, Bern(½−θ)^L) ≥ θ√L(1 − 2Lθ²) | tool | proved |
| Theorem 6.3 | Human who is not deterministic, whole runs: E TV(run laws) ≥ √(LK/n)/(64√2) for n ≥ max{K/2, LK/8}; TV ≤ ε needs n ≥ L·K/(8192ε²) | N6 | proved; display corrected (its second inequality needs θ√(8n/K) ≤ 1) |
| Theorem 7.1 | Conclusion, part by part, each for a named class and scaffold: one run of the OR scaffold on a needle class matched to L and δ (in advance: ≥ L/(4δ) − L answers; during the run: ≥ L(1 − √(2δ) − δ) − δ); r runs under one budget, for a class that grows with r; a per-run failure rate δ bought once for all later runs, with break-even after K ln 2 allowed failed runs | N2d | proved; wording corrected in (A), (B), (D), (E), (F) and in the paragraph "In words" |
| Proposition 7.2 | The conclusion as one inequality between amplification and failure budget F: at most 4F/(1 − 4δ) for the needle classes, at most 8F·log(L/(2δ))/((1 − 10δ)K) for the block classes, at least F/(K ln 2 + δ/L) by rehearsal | N2d | from the attack report; re-derived by the editor |
| Section 9 | Open questions | | open |

Conventions. log is log₂, ln the natural logarithm. [N] := {1, …, N}. TV is total variation distance (half the L₁ distance). "Function" means a sampler whose answers are deterministic.

**Letters here and in the note.** The note writes k for the number of tolerated faults (m in Section 5 here), d for the number of blocks of the block class (m in Section 3 here; it is the VC dimension), ℓ for the description length of a shift (k in Corollary 4.2 here), and a for the advantage over 1/2 (η in Theorem 4.1 here; the note keeps η for the threshold of the threshold rule). The note's N in N2 and N5 is N₀ here, its g in N5 is the number B of blocks, its b in N6 is θ of Section 6 (the note keeps θ for the tolerated fraction of faults), and the fraction κ in its remark on N2b is κ_j of Theorem 3.1. The sub-labels N2a to N2d are the editor's; the lead may renumber them.

**Changes of notation.** (1) The candidate uses the letter A both for an answerer and, in N1, for a set of inputs. Here A is always a set of inputs (as in sep(x; A)); what is deployed is called a *deployed system* (Definition 1.3). (2) The candidate states N2 with one parameter ε that fixes the class (N₀ = L/ε) and the failure level (ε/4). Here the failure level is δ and the class parameter N₀ is free; this is what allows the constants to be optimised. (3) n may be a bound on the *expected* number of questions; this is weaker than a worst-case bound, so the lower bounds are stronger.

## 1. Setting, and N1

### 1.1 Protocols and deployed systems

X and Y are countable sets, samplers and the class H with weights w are as in Section 1 of the candidate theory (A1, A2), K := log(1/w(P)).

**Definition 1.1 (protocol).** A *protocol* Λ consists of a seed r drawn from a probability space (R, λ₀), maps q_t(r, y_1, …, y_{t−1}) ∈ X ∪ {∅} for t = 1, 2, …, and a stopping rule: a number of steps T = T(r, y_1, y_2, …) that is finite on every path and such that whether T ≥ t is determined by r and y_1, …, y_{t−1}. (The prover's version fixed T in advance. Protocol AB of Section 3.2 stops at a time that depends on the answers, so the definition is widened; every proof below is an induction over the steps, or uses only the path on which one fixed function answers, and holds unchanged. Both reports asked for this.) In the interaction of Λ with a sampler P, at step t the protocol puts the question x_t := q_t(r, y_1, …, y_{t−1}) to the human if x_t ∈ X and receives y_t ~ P(·|x_t), drawn with coins independent of r and of all earlier draws (A1, A3); if x_t = ∅ nothing is asked and y_t := ∅. The *transcript* is D := (x_t, y_t)_{t ≤ T}. The number of questions is N_Λ := #{t : x_t ∈ X}. The protocol is adaptive and randomised; it may do any computation, in particular rehearsal runs of a scaffold. Pr_P and E_P refer to the interaction with P.

**Definition 1.2 (scaffold, runs).** As in the candidate theory: z ~ D₀, internal randomness ρ, next_j(z, ρ, y_1, …, y_{j−1}) ∈ X ∪ {STOP} for j ≤ L, and out(z, ρ, y_1, …, y_T′) ∈ O, where T′ ≤ L is the number of calls of the run. For a function f, run_f(z, ρ) is the run in which f answers every call, and out_f(z, ρ) its outcome. (z, ρ) is drawn after the interaction and independently of (r, D).

**Definition 1.3 (deployed system).** A *deployed system* is a measurable map g that assigns to (r, D, z, ρ, s), where s is fresh randomness independent of everything else, an outcome ô ∈ O ∪ {⊥}; ⊥ means that the system is silent (it abstained). The case of the candidate theory is a *deployed answerer*: a rule that produces the answer to call j, or ⊥, from (r, D, s) and the history of the run so far; Π is run with it, and ô is the outcome of that run, or ⊥ if some call was answered ⊥. A deployed answerer may be history-dependent and randomised. Every lower bound below is proved for deployed systems, which may in addition see z and ρ in full; the bounds therefore hold for deployed answerers.

**Definition 1.4 (failure).** For a function f the *failure probability* of (Λ, g) is Fail(f) := Pr_f[ô ≠ out_f(z, ρ)]: the outcome is wrong or silent. A deployed answerer's run is *faithful* if it equals run_f(z, ρ); a faithful run has the right outcome, so Pr_f[run not faithful] ≥ Fail(f), and every lower bound on Fail is a lower bound on the probability of an unfaithful run.

### 1.2 Indistinguishability

**Lemma 1.5.** Let P, P′ be samplers and A ⊆ X with P(·|a) = P′(·|a) for all a ∈ A. For a protocol Λ let τ be the first step t with x_t ∈ X ∖ A (τ := ∞ if there is none). Then the interactions of Λ with P and with P′ can be defined on one probability space, with the same seed, so that τ is the same in both and the two transcripts agree up to (not including) the answer at step τ. In particular γ := Pr_P[τ < ∞] = Pr_{P′}[τ < ∞], and the laws of (r, D) under P and under P′ are within total variation γ.

*Proof.* Fix an enumeration of Y. For a sampler ν let F_ν(x, u) be the quantile map of ν(·|x) with respect to this enumeration, so that F_ν(x, U) ~ ν(·|x) for U uniform on [0, 1]; then F_P(a, ·) = F_{P′}(a, ·) for a ∈ A. Take r ~ λ₀ and independent uniform U_1, U_2, …, and let both interactions use y_t := F_ν(x_t, U_t), with ν = P and ν = P′. By induction on t, for t < τ (τ defined by the interaction with P) the questions and answers of the two interactions coincide, and so do the decisions of the stopping rule: the question at step t is a function of r and of the earlier answers, hence equal, it lies in A ∪ {∅}, and so the answers are equal. The question at step τ is again a function of r and equal earlier answers, so it is the same in both interactions and lies outside A; hence τ is the same. On {τ = ∞} the transcripts are equal, which gives the total variation bound. ∎

The hypotheses used are A1 (each answer is a fresh draw from P(·|x_t)) and A3 (the seed is independent of the human's coins). If members of the class may give no answer (Proposition 1.8(4)), the outcome ⊥ is added to the enumeration of Y and nothing else changes.

**Theorem 1.6 (N1).** Let P, P′ ∈ H agree on A ⊆ X, let Λ be a protocol, g a deployed system, and γ := Pr_P[Λ asks a question outside A] (by Lemma 1.5 the same under P′). Let Q̂_P, Q̂_{P′} be the laws of (z, ρ, ô) under P and P′.
1. TV(Q̂_P, Q̂_{P′}) ≤ γ. For a deployed answerer the same holds for the law of the whole deployed run.
2. For any two disjoint events G, G′ of (z, ρ, ô) ("good for P", "good for P′"): Q̂_P(not G) + Q̂_{P′}(not G′) ≥ 1 − γ.
3. For any two target laws Q, Q′ of (z, ρ, o) (for example the human systems Q_P, Q_{P′}): TV(Q̂_P, Q) + TV(Q̂_{P′}, Q′) ≥ TV(Q, Q′) − γ.
4. (Single call.) Let the task be one call at an input x ∉ A, and let R, R′ be the laws of the deployed answer in Y ∪ {⊥} under P and P′. Then TV(R, P(·|x)) + TV(R′, P′(·|x)) ≥ TV(P(·|x), P′(·|x)) − γ. If P = f and P′ = f′ are functions with f(x) ≠ f′(x): Pr_f[answer ≠ f(x)] + Pr_{f′}[answer ≠ f′(x)] ≥ 1 − γ, where a silent answer counts as ≠.

In particular, if all questions lie in A with probability one (γ = 0): for functions with f(x) ≠ f′(x), the deployed answer at x is wrong or silent with probability at least 1/2 for one of the two members; and in general no deployed system has a run law closer than TV(Q_P, Q_{P′})/2 to both human systems.

*Proof.* (1) (z, ρ, s) is independent of (r, D) and has the same law under P and P′, and ô is a function of (r, D, z, ρ, s); so the total variation between the laws of (z, ρ, ô) is at most that between the laws of (r, D), which is at most γ by Lemma 1.5. The run of a deployed answerer is likewise a function of (r, D, z, ρ, s). (2) Q̂_P(G) + Q̂_{P′}(G′) ≤ Q̂_P(G) + Q̂_P(G′) + γ ≤ 1 + γ. (3) Triangle inequality: TV(Q, Q′) ≤ TV(Q, Q̂_P) + TV(Q̂_P, Q̂_{P′}) + TV(Q̂_{P′}, Q′). (4) The first claim is (3) for the scaffold with one call at x and outcome = answer; the second is (2) with G = {ô = f(x)} and G′ = {ô = f′(x)}. ∎

Two remarks from the check report. The proof does not use that P and P′ belong to H; membership is what turns the conclusion into a statement about "every member of H". The hypothesis x ∉ A in (4) is not needed (for x ∈ A the first claim is empty and the second has no instance). The argument is the standard two-point argument of statistics (Le Cam's method; Section 11).

**Corollary 1.7 (abstention does not help; it only makes the failure visible).** In the situation of Theorem 1.6(4) with functions f, f′, f(x) ≠ f′(x), let s_f := Pr_f[answer ∉ {f(x), ⊥}] be the probability of a *silent error* under f, and similarly s_{f′}. Then

  s_f + s_{f′} ≥ 1 − γ − min{R(⊥), R′(⊥)}.

So if γ = 0 and the deployed system is never silently wrong for both members, it abstains at x with probability one under both. More generally, if the questions lie in a set A with probability one and H contains, for every x′ ∉ A, a member that equals f on A and differs from f at x′, then a rule that is never silently wrong for every member of H abstains with probability one at every input outside A when the human is f.

*Proof.* s_f + s_{f′} = 2 − R(f(x)) − R(⊥) − R′(f′(x)) − R′(⊥). By Theorem 1.6(1), R′(f′(x)) ≤ R(f′(x)) + γ, and R(f(x)) + R(f′(x)) + R(⊥) ≤ 1. Hence s_f + s_{f′} ≥ 2 − (1 − R(⊥)) − γ − R(⊥) − R′(⊥) = 1 − γ − R′(⊥); by symmetry the same with R(⊥). ∎

**Proposition 1.8 (the universal class).** Let Y = {0, 1}*, let H be the class of all lower semicomputable samplers with w(ν) = 2^(−K(ν)), K(ν) the prefix complexity of a program for ν on the reference machine, and let sep(x; A) be the least K(Q) over decidable Q ⊆ X with x ∈ Q and Q ∩ A = ∅ (`understand/repo.md`, Section 1). A *sampler* is, as in the note, a probability kernel on Y: it answers every input with probability one. There is a constant c, depending only on the reference machine, such that for every A ⊆ X and every x ∉ A with sep(x; A) < ∞:
1. for every computable function f there is a computable function f_x with f_x = f on A, f_x(x) ≠ f(x) and K(f_x) ≤ K(f) + sep(x; A) + c;
2. for every P ∈ H and every integer N ≥ 2 there is P_x ∈ H with P_x = P on A, TV(P_x(·|x), P(·|x)) ≥ 1 − 1/N and K(P_x) ≤ K(P) + sep(x; A) + log N + 2 log log N + c;
3. if P(y|x) > 0 for all y ∈ Y, no sampler P_x has P_x(·|x) ⟂ P(·|x). So, for samplers in this sense, the last sentence of the candidate's N1 ("P_x(·|x) ⟂ P(·|x) with K(P_x) ≤ K(P) + sep(x; A) + c") is false for such P, and (2) is its replacement;
4. if instead the class consists of the lower semicomputable conditional semimeasures (programs that may fail to halt; "no answer" is recorded as the outcome ⊥, as in the candidate theory's own convention and in the repository's earlier papers), then for every member P there is a member P_x with P_x = P on A, P_x(⊥|x) = 1 and K(P_x) ≤ K(P) + sep(x; A) + c. Its answer law at x is at total variation 1 − P(⊥|x) from P(·|x), and is mutually singular to it exactly when the human answers x with probability one.

Consequently (Theorem 1.6): a protocol whose questions lie in A is, at x, wrong or silent with probability ≥ 1/2 for f or for f_x; for samplers its answer law at x is at total variation ≥ (1 − 1/N)/2 from the truth for P or for P_x; and under the convention of (4), for a human who always answers, the candidate's sentence holds as it stands.

*Proof.* Let Q be a decidable set of complexity sep(x; A) that separates x from A. (1) Let f_x(x′) := f(x′) followed by the symbol 1 if x′ ∈ Q, and f(x′) otherwise (this is where Y = {0, 1}* is used). A program for f_x consists of a program for f, a program deciding Q and a fixed piece of code, so K(f_x) ≤ K(f) + K(Q) + c. (2) Among the first N strings y_1, …, y_N of Y some y_i has P(y_i|x) ≤ 1/N. Let P_x answer y_i with probability one on inputs in Q and as P elsewhere. Then TV(P_x(·|x), P(·|x)) = 1 − P(y_i|x) ≥ 1 − 1/N, and a program for P_x consists of programs for P and Q, a self-delimiting code of the index i ≤ N (at most log N + 2 log log N + O(1) bits) and fixed code. The index has to be coded: an answer of small probability cannot in general be computed from programs for P and x. (3) Two laws on a countable set are mutually singular only if one of them gives probability 0 to a set of probability 1 under the other; with P(·|x) positive everywhere the only null set is empty. (4) Let P_x run the program of P on inputs outside Q and not halt on inputs in Q. A program for it consists of programs for P and Q and fixed code. At x it gives ⊥ probability one, and P(·|x) gives ⊥ probability P(⊥|x). ∎

*Which convention the note uses.* The note defines a sampler as a probability kernel on Y, so (2) and (3) are the statements for the note, and the sentence of its Section 4.1 on the class of all programs is worded accordingly. The attack report (finding m3) pointed out that the prover's verdict "refuted as stated" holds for that convention only; part (4) is its addition.

**Remark 1.9 (which hypotheses N1 needs).** (a) *The class must contain the patch.* For H = {f, f′} with f(x′) ≠ f′(x′) at every input, one question anywhere identifies the human; N1 is a statement about classes that contain, with P, a member that agrees with P on the asked set and differs at x. (b) *γ matters and the bound 1 − γ is attained.* A protocol that asks x with probability γ and otherwise answers f(x) fails with probability 0 under f and 1 − γ under f′. (c) Nothing is assumed about how questions are chosen or about the deployed system; in particular a history-dependent deployed answerer inside a scaffold is covered by parts 1–3, because its whole run has the same law under P and P′ up to γ.

### 1.3 The patch-family lemma

This lemma is the common core of N2, N3 and N5 for functions.

**Lemma 1.10 (patch family).** Let Π be a scaffold, f₀ ∈ H a function, B_1, …, B_N disjoint subsets of X, and f_1, …, f_N ∈ H functions with f_i = f₀ on X ∖ B_i. Put o_i := out_{f_i}(z, ρ), Δ_i := Pr[o_i ≠ o₀], and let M be a number with #{i ≥ 1 : o_i ≠ o₀} ≤ M for all (z, ρ). Let Λ be a protocol and g a deployed system, S(r) the set of questions that Λ asks on seed r when all answers are given by f₀, π_i := Pr[S(r) ∩ B_i ≠ ∅], and n := E_{f₀}[N_Λ]. Then Σ_i π_i ≤ n, and
1. Fail(f₀) + Fail(f_i) ≥ (1 − π_i)·Δ_i for every i;
2. (M/(N+M))·Fail(f₀) + (1/(N+M))·Σ_{i≥1} Fail(f_i) ≥ (1/(N+M))·Σ_i (1 − π_i)Δ_i ≥ (N − n)·min_i Δ_i/(N + M).
The left side of (2) is an average over the class, so max_i Fail(f_i) is at least the right side.

*Proof.* The sets B_i are disjoint, so the number of i with S(r) ∩ B_i ≠ ∅ is at most |S(r)| ≤ N_Λ on the f₀-path; taking expectations, Σ_i π_i ≤ n. Fix r and let D⁰(r) be the transcript when f₀ answers. If S(r) ∩ B_i = ∅, then by induction over the steps the interaction with f_i asks the same questions and receives the same answers (each asked input lies outside B_i, where f_i = f₀), so its transcript is D⁰(r) and the deployed outcome is g₀ := g(r, D⁰(r), z, ρ, s) under both f₀ and f_i. Write hit(r) := {i : S(r) ∩ B_i ≠ ∅}. Then Fail(f₀) = Pr[g₀ ≠ o₀] and, for i ≥ 1, Fail(f_i) ≥ Pr[i ∉ hit(r), g₀ ≠ o_i] ≥ Pr[i ∉ hit(r), o_i ≠ o₀, g₀ = o₀]. (1) On the event {i ∉ hit(r), o_i ≠ o₀}, g₀ differs from o₀ or from o_i; the event has probability (1 − π_i)Δ_i because r is independent of (z, ρ). (2) With V := #{i ∉ hit(r) : o_i ≠ o₀} ≤ M, the left side is at least
E[ (M/(N+M))·1[g₀ ≠ o₀] + (V/(N+M))·1[g₀ = o₀] ] ≥ E min{M, V}/(N+M) = E[V]/(N+M),
and E[V] = Σ_i (1 − π_i)Δ_i ≥ (N − Σ_i π_i)·min_i Δ_i. ∎

The independence of r and (z, ρ), used for Pr[i ∉ hit(r), o_i ≠ o₀] = (1 − π_i)Δ_i, is part of Definition 1.2: the questions are asked before the run is drawn (Remark 2.4(1)). A refinement used in Theorem 4.3: if n′ is the expected number of questions that the f₀-path puts to inputs of ∪_i B_i, then Σ_i π_i ≤ n′, by the same argument.

*Source of the argument.* For a task of one call, part (2) is the lower bound of active learning for a class with a large star number, with the same proof (the learner's output under f_i is its output under f₀ unless B_i was asked): Hanneke and Yang, Theorem 3 and its proof, who credit the bound to Dasgupta (Section 11; read in the source by the attack report's author and by the editor). What is added here is the scaffold (influence Δ_i of a patch on the outcome of a run), deployed systems that see the whole run, and the count in expected questions.

**Remark 1.11 (a protocol without coins; the lower-bound side of A3).** (From the attack report, Section 4, test 3; re-derived by the editor.) Let Y = {0, 1}*, let Λ be a computable protocol that uses no seed, f₀ a computable function, and S the set of questions that Λ asks when f₀ answers; S is finite. Let f′ := f₀ on S, and f′(x) := f₀(x) followed by the symbol 1 for x ∉ S. Then f′ is computable with K(f′) ≤ K(f₀) + K(Λ) + c (a program for f′ runs Λ against f₀ to find S), and the transcript of Λ is the same under f₀ and f′. By Lemma 1.10(1) with the single patch B := X ∖ S, for which π = 0,

  Fail(f₀) + Fail(f′) ≥ Pr[out_{f′}(z, ρ) ≠ out_{f₀}(z, ρ)],

and for a scaffold whose outcome is the list of the answers of the run the right side is the probability that the run of f₀ makes a call outside S (the first such call is answered differently by f′). So against a protocol whose choice of questions a hypothesis can compute, one hypothesis of K(f₀) + K(Λ) + c bits does what the N₀ needles of Section 2 do together. Assumption A3 (the protocol's coins are not computable by any hypothesis) is what forces the hard class to spread over many patches.

## 2. Critical steps are not amplified (N2)

### 2.1 The needle class

**Definition 2.0.** Let N₀, L ≥ 1 be integers, X := [N₀], Y := {0, 1}. The *needle class* is 𝒩(N₀) := {f₀, f_1, …, f_{N₀}} with f₀ ≡ 0 and f_i(x) := 1[x = i]. The *OR scaffold* Π_{L,N₀} has z = (x_1, …, x_L) independent and uniform on [N₀], no internal randomness, next_j := x_j, and out := max_j y_j. Write set(z) for the set of distinct cells among x_1, …, x_L and

  p := p(L, N₀) := 1 − (1 − 1/N₀)^L = Pr[i ∈ set(z)]  for each cell i;  (L/N₀)(1 − L/(2N₀)) ≤ p ≤ L/N₀

(the lower bound is 1 − (1 − a)^L ≥ La − (L(L−1)/2)a²). Under f₀ the outcome is 0 and every call is critical: one changed answer changes the outcome. With uniform weights every member has K = log(N₀ + 1); in the universal class K(f_i) ≤ log N₀ + 2 log log N₀ + c.

**Theorem 2.1 (N2, exact form).** Let Λ be any protocol (adaptive, randomised), g any deployed system (in particular any deployed answerer, history-dependent, randomised, abstaining), and n := E_{f₀}[N_Λ] the expected number of questions when the human is f₀. Then

  (L/(N₀+L))·Fail(f₀) + (1/(N₀+L))·Σ_{i=1}^{N₀} Fail(f_i) ≥ (N₀ − n)·p/(N₀ + L).

Hence some member of 𝒩(N₀) has failure probability, and probability of an unfaithful run, at least (N₀ − n)p/(N₀ + L).

*Proof.* Lemma 1.10 with B_i := {i}, o₀ = 0, o_i = 1[i ∈ set(z)], Δ_i = p and M := L (at most L cells are visited). ∎

**Corollary 2.2 (constants).** Suppose Fail(f) ≤ δ for every f ∈ 𝒩(N₀). Then n ≥ N₀ − δ(N₀ + L)/p. In particular:
1. if N₀ = L/(2δ) is an integer, n ≥ L/(4δ) − L;
2. for every δ ∈ (0, 1/6] and N₀ := ⌈L/(2δ)⌉, n ≥ L/(4δ) − 3L/2;
3. for the parameters of the candidate theory (N₀ = L/ε, δ = ε/4), n ≥ (3/4)·((1 − ε)/(1 − ε/2))·L/ε ≥ (3/4)(1 − ε)·L/ε.
In (1) and (2) every member has K ≤ log(L/(2δ) + 2) with uniform weights.

*Proof.* The first claim is Theorem 2.1 rearranged. (1) p ≥ 2δ(1 − δ) and N₀ + L = N₀(1 + 2δ), so δ(N₀+L)/p ≤ N₀(1 + 2δ)/(2(1 − δ)) and n ≥ N₀(1 − 4δ)/(2(1 − δ)); for δ ≤ 1/4 this is at least N₀(1 − 4δ)/2 = L/(4δ) − L, and for δ > 1/4 the claim is trivial. (2) Now L/(2δ) ≤ N₀ < L/(2δ) + 1, so p ≥ (L/N₀)(1 − δ) and δ(N₀+L)/L < 1/2 + δ/L + δ ≤ 1/2 + 2δ; hence n ≥ N₀[1 − (1/2 + 2δ)/(1 − δ)] = N₀(1/2 − 3δ)/(1 − δ) ≥ N₀(1/2 − 3δ) ≥ L/(4δ) − 3L/2. (3) p ≥ ε(1 − ε/2), so δ(N₀+L)/(N₀p) ≤ (1 + ε)/(4 − 2ε) and n ≥ N₀(3 − 3ε)/(4 − 2ε). ∎

The candidate theory states the bound (ε/2)(1 − nε/L)(1 − o(1)) and the consequence n ≥ L/(2ε). Theorem 2.1 with N₀ = L/ε gives the larger bound ε(1 − ε/2)(1 − nε/L)/(1 + ε) (the prior is chosen better), and the free choice of N₀ gives n ≥ (1 − ε)L/ε for failure ε/4 (item 1 with δ = ε/4).

The lead's draft of the note (`note.md`, Theorem N2) takes N = ⌈L/(8γ)⌉ cells and proves n > L/(16γ) for failure γ ≤ 1/16. Both reports checked that proof and found it correct. For that class about 7N/8 questions are in fact necessary (Theorem 2.1; by exact computation 22 questions for L = 5 and γ = 1/40, where the draft claims more than 12.5: `proofs/code/lower-bounds_needle_exact.out`, table 4). The class N₀ = L/(2δ) of Corollary 2.2 gives the constant 1/4, four times the draft's 1/16, and by Proposition 2.3 this constant is exact for that class.

**Proposition 2.3 (tightness).** For every integer 0 ≤ n ≤ N₀ there is a non-adaptive protocol with exactly n questions, deploying a function, with Fail(f₀) = 0 and Fail(f_i) = (1 − n/N₀)·p for i ≥ 1. So the minimax failure v(n) over protocols with at most n questions satisfies

  (N₀ − n)p/(N₀ + L) ≤ v(n) ≤ (N₀ − n)p/N₀,

and for N₀ = L/(2δ) the least number n*(δ) of questions with which failure ≤ δ is possible for all members satisfies L/(4δ) − L ≤ n*(δ) ≤ ⌈L/(4δ)⌉.

*Proof.* Ask the cells of a uniformly random n-subset S. If an answer is 1 the human is identified and is deployed. Otherwise deploy f₀. Under f₀ there is no failure; under f_i the deployed run fails iff i ∉ S and i ∈ set(z), which are independent events. For the last claim, n ≥ N₀(1 − δ/p) suffices, and δ/p ≥ δN₀/L = 1/2. ∎

For N₀ = ⌈L/(2δ)⌉ the same protocol with ⌈N₀/2⌉ questions has failure at most p/2 ≤ L/(2N₀) ≤ δ. The exact least expected number of questions, computed by the check report with a linear programme that uses the symmetry of the class (`proofs/code/lower-bounds_needle_exact.out`, tables 3 and 3b), lies between the two bounds in all cases computed:

| L | δ | L/(4δ) − L | exact | ⌈L/(4δ)⌉ |
|---|---|---|---|---|
| 1 | 0.05 | 4 | 4.50 | 5 |
| 2 | 0.025 | 18 | 19.25 | 20 |
| 4 | 0.05 | 16 | 18.75 | 20 |
| 4 | 0.02 | 46 | 48.75 | 50 |
| 8 | 0.05 | 32 | 37.74 | 40 |
| 2 | 0.005 | 98 | 99.25 | 100 |

**Remark 2.4 (what the hypotheses do).**
1. *Order of events.* The questions are asked before z is drawn. If the human can be asked after z is known, L questions give failure 0; Proposition 2.5 shows that nearly L are then still needed. In the language of the note: in a closed system we draw z and ρ ourselves. For one task whose z and ρ are fixed before the questions are chosen, the calls of that run can be put to the human one after another, and the number of questions is at most L. The factor 1/(4δ) of Corollary 2.2 is the price of preparing an imitator for a task that is drawn afterwards. (Attack report, finding m8.)
2. *Closure under patches.* The class must contain, with f₀, its one-cell patches. For a class of two functions that differ everywhere one question suffices.
3. *Many distinct inputs.* The bound is at most N₀: a scaffold that can only produce N₀ inputs is learned exactly with N₀ questions. So the theorem is not about the number of critical calls of a run. It is about the number of places that a critical call can fall on and that the class can patch one by one. A run whose L calls are all critical but fall on one input costs one question (Example 5.5).
4. *Worst case over the class.* The left side of Theorem 2.1 is the Bayes risk for the prior with weights L/(N₀+L) on f₀ and 1/(N₀+L) on each needle. A guarantee on average over a prior that favours f₀ is cheap: if the prior gives the N₀ needles together the weight η′ and f₀ the rest, the protocol that asks nothing and deploys f₀ has Bayes failure η′·p, which for N₀ = L/(2δ) is at most 2η′δ and so below δ for every η′ < 1/2 (`proofs/code/lower-bounds_attack_budget.out`, part C). In a universal class the total weight of the one-cell patches relative to the weight of f₀ depends on the reference machine (each patch costs at most log N₀ + 2 log log N₀ + c bits more than f₀, with c a constant of the machine), so whether the theorem bites for a reader who trusts the prior depends on the machine; for a guarantee that covers every member it does not. (Attack report, finding m7; the report calls the ratio "a constant of the reference machine", which is more than this argument shows.) The bound is not about complexity: every member has K ≈ log(L/δ) bits. It is about search: an answer 0 excludes one cell.
5. *Abstention.* A silent outcome counts as a failure. If only silent errors counted, the system that always abstains would have none (Corollary 1.7).
6. *Comparison.* For this class the bound of Protocol R is L·K ln 2/δ questions for failure δ (candidate R2; Lemma 5.1′ below), with K = log(L/(2δ) + 1): the ratio to L/(4δ) − L is about 4 ln 2·K.

### 2.2 The human in the loop during the run

**Proposition 2.5.** Consider protocols that first see z, then ask the human questions adaptively, and then output ô; let n := E_{f₀}[N_Λ]. For the needle class and the OR scaffold,

  (L/(N₀+L))·Fail(f₀) + (1/(N₀+L))·Σ_i Fail(f_i) ≥ (N₀·p − n)/(N₀ + L).

Hence failure ≤ δ for all members requires n ≥ N₀p − δ(N₀ + L), and with N₀ := ⌈L/√(2δ)⌉:

  n ≥ L·(1 − √(2δ) − δ) − δ.

Asking every call of the run (L questions) gives failure 0, so this is tight up to the factor 1 − √(2δ) − δ.

*Proof.* Fix (r, z) and let S(r, z) be the set of cells asked when all answers are 0. If i ∉ S(r, z), the transcript under f_i is the all-zero transcript, so the output is the same g₀(r, z, s) as under f₀. With V := |set(z) ∖ S(r, z)| ≤ L, the left side is at least E[(L/(N₀+L))·1[g₀ ≠ 0] + (V/(N₀+L))·1[g₀ = 0]] ≥ E[V]/(N₀+L), and E[V] ≥ E|set(z)| − E|S(r, z)| ≥ N₀p − n. For the last display, N₀p ≥ L − L²/(2N₀) ≥ L − L√(2δ)/2 and δN₀ ≤ L√(2δ)/2 + δ. ∎

So, for these needle classes, a run of the OR scaffold costs about L human answers whatever is done, and an imitator prepared before the task is drawn costs about 1/(4δ) times more (Corollary 2.2). Both statements are about classes with at least L/√(2δ), respectively L/(2δ), cells that can be patched one by one; a run whose critical calls fall on few places is cheap (Remark 2.4(3)). Section 7 states this as one theorem.

## 3. The dependence on K

Section 2 gives L/(4δ) for a class with K ≈ log(L/δ). This section shows that the number of questions grows linearly in K for fixed L/δ (Theorem 3.1), and that the growth is K·L/(δ·log(L/δ)), not K·L/δ (Theorem 3.3). Section 3.3 shows that rehearsal with random questions does need of order K·L/δ questions on some classes (Proposition 3.7), and Section 3.4 gives two extensions of Protocol AB.

### 3.1 Lower bound: many needles

**Definition 3.0.** Let m, N, L ≥ 1, X := [m] × [N], Y := {0, 1}. For a ∈ [N]^m let f_a(j, i) := 1[a_j = i]: block j contains exactly one needle, at cell a_j. The *block class* is 𝒩^m(N) := {f_a : a ∈ [N]^m}; it has 2^K members with K := m·log N, which is the complexity of every member under uniform weights. The *block scaffold* Π^m_{L,N} has z = (J, u_1, …, u_L) with J uniform on [m] and u_1, …, u_L independent and uniform on [N], no internal randomness, next_l := (J, u_l), out := max_l y_l. Write set(z) := {u_1, …, u_L} and p := p(L, N) as in Definition 2.0.

**Theorem 3.1 (the factor K).** Let Λ be any protocol, g any deployed system, and n the expected number of questions of Λ when a is uniform on [N]^m (n is at most the worst-case number of questions). Then

  N^(−m)·Σ_a Fail(f_a) ≥ p·(1 − 2L/N − 2n/(mN)).

Consequently, if Fail(f_a) ≤ δ for all a, then n ≥ (mN/2)·(1 − 2L/N − δ/p); and if N = L/(2δ) is an integer,

  n ≥ (1 − 10δ)·m·L/(8δ) = (1 − 10δ)·K·L/(8δ·log(L/(2δ))).

*Proof.* Let a be uniform on [N]^m and independent of (r, z, s). Fix a block j, a seed r and the coordinates a_{−j} of a other than j. The *j-silent interaction* is the interaction of Λ on seed r in which inputs of the other blocks are answered according to a_{−j} and every input of block j is answered 0. Let c_1, …, c_k be the distinct cells of block j that it asks, in the order of first appearance, S := {c_1, …, c_k}, k = k_j(r, a_{−j}) ≤ N, κ_j := k/N ∈ [0, 1].

*Step 1 (questions).* Let N_j be the number of questions put to inputs of block j in the real interaction. If a_j = c_i, the real interaction coincides with the j-silent one until c_i is asked for the first time, and by then c_1, …, c_i have been asked: N_j ≥ i. If a_j ∉ S the real interaction is the j-silent one: N_j ≥ k. Since a_j is uniform and independent of (r, a_{−j}),

  E[N_j | r, a_{−j}] ≥ (1/N)·(Σ_{i=1}^{k} i + (N − k)·k) = k − k(k − 1)/(2N) ≥ N·(κ_j − κ_j²/2) ≥ N·κ_j/2.

Summing over j and taking expectations, Σ_j E[κ_j] ≤ (2/N)·Σ_j E[N_j] ≤ 2n/N.  (∗)

*Step 2 (failure).* Condition on J = j, r and a_{−j}. For every value a_j = i ∉ S the transcript is the j-silent transcript, so the outcome ô = g₀(z, s) does not depend on i, while the right outcome is 1[i ∈ set(z)]. For fixed (z, s) the number of i ∈ [N] ∖ S with g₀ ≠ 1[i ∈ set(z)] is |set(z) ∖ S| if g₀ = 0, N − k − |set(z) ∖ S| if g₀ = 1, and N − k otherwise. If N − k ≥ 2L, then |set(z) ∖ S| ≤ L ≤ N − k − L, so this number is at least |set(z) ∖ S|. As z is independent of (r, a) and each cell of block j lies in set(z) with probability p,

  Pr[failure | J = j, r, a_{−j}] ≥ (1/N)·(N − k)·p·1[N − k ≥ 2L] = p·(1 − κ_j)·1[1 − κ_j ≥ 2L/N] ≥ p·(1 − κ_j − 2L/N).

*Step 3.* Averaging over J (uniform on [m]), r and a, and using (∗): the average failure is at least p·(1 − 2L/N − (1/m)Σ_j E[κ_j]) ≥ p·(1 − 2L/N − 2n/(mN)).

*Step 4 (numbers).* If all failures are ≤ δ the average is ≤ δ, which gives the bound on n. For N = L/(2δ): 2L/N = 4δ, p ≥ 2δ(1 − δ), δ/p ≤ 1/(2(1 − δ)) ≤ 1/2 + δ, so n ≥ (mN/2)(1/2 − 5δ) = (mL/(8δ))(1 − 10δ). ∎

**Proposition 3.2 (tightness).** Let N = L/(2δ). The following protocol has Fail(f_a) ≤ δ for every a, asks at most ⌈m/2⌉(N − 1) questions, and asks at most ⌈m/2⌉·(L/(4δ) + 1/2) in expectation when a is uniform: choose ⌈m/2⌉ blocks uniformly at random; in each, ask the cells 1, 2, …, N − 1 in turn until an answer is 1 (if there is none the needle is at N); deploy the function that equals f_a on the chosen blocks and 0 elsewhere.

*Proof.* A run fails iff its block was not chosen and the needle of that block is in set(z): probability (1 − ⌈m/2⌉/m)·p ≤ p/2 ≤ L/(2N) = δ. The number of questions in a chosen block is min(a_j, N − 1), with mean (N − 1)(N + 2)/(2N) ≤ (N + 1)/2 for uniform a_j. ∎

So Theorem 3.1 is sharp up to the factor (1 + O(δ))(1 + 1/m) in the expected number of questions. Scanning half of the blocks completely is better than scanning all blocks half-way: the search for one needle is all or nothing.

### 3.2 Upper bound: plurality answers and targeted questions

**Theorem 3.3 (Protocol AB).** Let H be a countable class of total functions X → Y with weights w, and let the human be a function f ∈ H (a deterministic human; A2), K := log(1/w(f)). Let Π be any scaffold of horizon L, let X₁ be the set of inputs that occur in a run of Π answered by a member of H, for some (z, ρ), and let X₀ be any set with X₁ ⊆ X₀ ⊆ X (X₀ = X is allowed). Let γ ∈ (0, 1/2) and n_B ≥ 1. Write V_t for the set of members consistent with the answers received before step t, W_t := w(V_t), and M_t(y|x) := w({g ∈ V_t : g(x) = y})/W_t.

*Protocol AB(γ, n_B).* At step t:
* **(A)** if some x ∈ X₀ has max_y M_t(y|x) ≤ 1 − γ, ask the human the first such x in a fixed enumeration of X₀;
* **(B)** otherwise every x ∈ X₀ has a unique answer of weight above 1 − γ. Let h_t(x) be this answer for x ∈ X₀ and, for x ∉ X₀, an answer of largest weight M_t(·|x) (the first in a fixed order of Y in case of a tie). Draw (z, ρ), run Π with h_t answering every call (this uses compute only), draw J uniformly from [L], and if the run made at least J calls ask the human the input of call J (the *audited* call).

Stop when n_B steps of type (B) have been made. *Deployment:* draw I uniformly from [n_B] and let the function h := h_t of the I-th step of type (B) answer every call, in this and all later runs.

Every question is one input put to the human; the human never carries out a run. Then:
1. Let a be the number of steps of type (A) and b the number of steps of type (B) at which the audited input lies in X₀ and the human's answer differs from h_t's. On every path a·ln(1/(1 − γ)) + b·ln(1/γ) ≤ K ln 2. Hence a ≤ K ln 2/γ, b ≤ K/log(1/γ), the protocol stops, and the number of questions is at most n_B + K ln 2/γ.
2. Pr[the deployed run differs from run_f(z, ρ)] ≤ L·K/(n_B·log(1/γ)).
3. Let ε ∈ (0, 1) with L/ε ≥ 16, u := log(L/ε), γ := u·ε/L and n_B := max{1, ⌈L·K/(ε·(u − log u))⌉}. Then the deployed run is faithful with probability ≥ 1 − ε, and the number of questions is at most

  1 + (u/(u − log u) + ln 2)·K·L/(ε·u) ≤ 1 + 2.7·K·L/(ε·log(L/ε)).

4. If X₀ contains every input that Π can produce when its calls are answered by arbitrary elements of Y (in particular if X₀ = X), or if L·γ < 1, then every audited input lies in X₀, so b counts all disagreements. If L·γ < 1, every run of h_t at a step of type (B) is moreover the run of a consistent member of H.
5. For X₀ = X₁ and L·γ ≥ 1 the inequality of (1) can fail if b is taken to count all disagreements (the example after the proof).

*Proof.* The protocol is well defined: W_t ≥ w(f) > 0 because f is consistent with its own answers; the members are total functions, so M_t(·|x) is a probability distribution on Y and a largest weight is attained; for γ < 1/2 an answer of weight above 1 − γ is unique.

(1) A question x answered f(x) multiplies W by M_t(f(x)|x) ≤ 1. At a step of type (A) the factor is at most max_y M_t(y|x) ≤ 1 − γ. At a step of type (B) with an audited input x ∈ X₀ and f(x) ≠ h_t(x) the factor is at most 1 − M_t(h_t(x)|x) < γ, because at such a step every input of X₀ has an answer of weight above 1 − γ. Since W_1 ≤ 1 and W_t ≥ w(f) for all t, (1 − γ)^a·γ^b ≥ w(f). Use ln(1/(1 − γ)) ≥ γ. Each step asks at most one question and there are a + n_B steps.

(2) At a step t of type (B) let u_t be the probability, over (z, ρ) and given the data so far, that the run of h_t differs from run_f(z, ρ). If the two runs differ, let j* be the first call of the h_t-run at whose input h_t and f differ; it exists, because otherwise both runs make the same calls with the same answers, by induction over the calls; and the inputs of calls 1, …, j* are the same in both runs. So the input of call j* occurs in the run of f and lies in X₁ ⊆ X₀. With probability 1/L, independently of the run, J = j*; then the human is asked an input of X₀ at which f and h_t differ, and the step adds one to b. So the conditional probability that step t adds one to b is at least u_t/L. Whether step t is one of the first n_B steps of type (B) is determined by the data before step t; summing over these steps, E Σ u_t ≤ L·E[b] ≤ L·K/log(1/γ). The deployed h is that of a uniformly chosen one of these n_B steps, and (z, ρ) at deployment has the same law as in rehearsal, so the probability in (2) is (1/n_B)·E Σ u_t.

(3) u ≥ 4 gives γ = u·2^(−u) ≤ 1/4 and log(1/γ) = u − log u ≥ u/2. By (2) the failure is at most ε (for K = 0 the bound of (2) is 0). By (1) the number of questions is at most n_B + K ln 2·L/(u·ε) ≤ 1 + (K·L/(ε·u))·(u/(u − log u) + ln 2), and u/(u − log u) ≤ 2, so the factor is at most 2 + ln 2 < 2.7. (The maximum with 1 matters only for K = 0, that is H = {f}, where the prover's n_B was 0; check report.)

(4) If X₀ contains all inputs that Π produces under arbitrary answers, every input of every run of h_t lies in X₀. Now let L·γ < 1 and consider a step of type (B). For each input of X₀ the consistent members that agree with h_t there have posterior weight above 1 − γ. Suppose that the first j ≤ L − 1 calls of a run of h_t have inputs in X₀. The consistent members that agree with h_t at all j inputs have weight above 1 − jγ > 0; let g be one of them. The run of g has the same first j calls and therefore the same input at call j + 1, which thus lies in X₁. The first input of a run lies in X₁. By induction over j all inputs of the run lie in X₁ ⊆ X₀, and the same argument with all its (at most L) inputs gives a consistent member whose run is the whole run of h_t. ∎

*The example for (5)* (attack report, finding m1; verified by hand by the editor and by `proofs/code/lower-bounds_attack_ab.py`, function `designed_example`). Inputs 0, 1, …, 9, answers {0, 1}. Nine members g_0, …, g_8 of weight 1/9 each: g_i is 1 at input i, it is 1 at input 9 if i < 4, and it is 0 elsewhere. The scaffold has no randomness. It asks the inputs 0, 1, …, 8 in turn as long as all answers are 0 and stops at the first answer 1; if all nine answers are 0 it asks input 9 as its tenth call (L = 10). The run of g_i stops at input i, so X₁ = {0, …, 8}; take X₀ := X₁, γ := 1/8 and the human g_0. At the start every input of X₀ has the answer 0 with weight 8/9 > 7/8, so the first step is of type (B), with h_1 = 0 on X₀ and h_1(9) = 0 (weight 5/9). The run of h_1 makes all ten calls. With probability 1/10 the audited call is the tenth: the human answers 1 at input 9, a disagreement at an input outside X₀, which leaves the four members g_0, …, g_3 and multiplies the weight by 4/9 only. Input 0 is then split (weights 1/4 and 3/4), a step of type (A) follows, and g_0 is identified. With a = 1 and one disagreement counted, (1 − γ)^a·γ^b = (7/8)·(1/8) = 7/64 < 1/9 = w(f). With b as defined in the theorem (disagreements at inputs of X₀) this path has b = 0 and the inequality holds; claims (2) and (3) hold in the example, as they must.

**Remarks on Theorem 3.3.**
1. *Where the algorithm comes from.* Protocol AB is not a new algorithm. It is the algorithm by which exact identification of a member of a finite class C of Boolean functions with membership queries is shown to need at most (ETD(C)/log ETD(C))·log|C| + ETD(C) queries, ETD being the extended teaching dimension: a result of Hegedűs (1995) and Moshkov (1983), stated with this algorithm as its proof in Bshouty (2017, Lemma 3; read in the source, see Section 11). That algorithm keeps the set of consistent members; if some input splits it so that both sides keep at least a fraction ε, it asks that input; otherwise it forms the majority function of the consistent members and asks a specifying set for it, and a refuted majority leaves at most a fraction ε. Steps of type (A) are the first case with γ in the place of ε. Steps of type (B) are the second case, in which the specifying set is replaced by audits of random runs, one call per run, as in Protocol R. Weights replace counts. The choice γ = log(L/ε)/(L/ε) of (3) is the survey's "ε is roughly log ETD(C)/ETD(C)" with L/ε in the place of ETD(C), and the bound (L/ε)·K/log(L/ε) is the bound (ETD/log ETD)·log|C| with the same replacement. What this file adds is the transfer to runs of a scaffold, with a prior and with random audits. Both reports pointed out the source (the attack report with the correspondence of the threshold and of the bound).
2. *Difference from Protocol R.* Steps of type (B) are rehearsal with one audited call, driven by the plurality function instead of the mixture. A disagreement at an input of X₀ removes all but a fraction γ of the posterior weight, that is log(1/γ) ≈ log(L/ε) bits. In Protocol R the weight is updated by the human's answer whether or not the mixture's draw disagreed, and what its analysis uses is that the expected number of disagreements is at most the weight removed in nats (1 − M ≤ −ln M): one nat, 1.44 bits, per expected disagreement. Steps of type (A) are needed so that the plurality function is nearly unanimous on X₀.
3. *Which questions are asked.* At a step of type (A) the human is asked an input that the protocol has found by searching X₀ for a split posterior. With X₀ = X₁ such an input is a call in a run answered by some member of the class: a call that would occur if the earlier calls had been answered as that member answers them. In general it is not an input of any run of the human system. Assumption A2 is used there in a way in which Protocol R uses it only with the frequency of its own runs: f must be a member as a function on all of X₀. If the class describes the human correctly only on inputs that follow answers like the human's, Protocol AB seeks out the misdescribed inputs first, and once the true member is refuted the weight argument is void. Assumption A3 (fresh coins) is used only at steps of type (B).
4. *The deployed object* is one deterministic function per run and for all runs (in general not a member of H: it is the pointwise plurality vote of the surviving members).
5. *What must be known.* The threshold γ of (3) depends on L/ε only. K enters through n_B alone, and claims (1) and (2) hold for every n_B, as Theorem R1 holds for every n: both protocols need K only to say when the failure is below a given ε. So "K must be known" is no disadvantage against Protocol R.
6. *Compute.* A step of type (A) needs the exact posterior at every input of X₀. For a finite class and a finite X₀ this is a finite computation (with X₀ = X₁ and a scaffold with finitely many values of (z, ρ), X₁ is finite for a finite class). For an infinite X₀ the statement "no input is split" is a universal statement and is not decidable in general. For the universal class the posterior is not computable, as everywhere in the candidate theory.
7. *Functions only.* The proof uses that one answer refutes a hypothesis. There is no version for a human who is not deterministic; there the rate L·K/ε² has no logarithm to save (Theorem 6.3).
8. *What the count is not.* It is an upper bound valid for every class, not the number of questions Protocol AB needs on a given class. On the rare-points class of Proposition 3.7 the steps of type (A) identify the human with K questions, and the n_B audits follow although none can fail. On the block class Protocol R needs fewer rounds than this count (the paragraph after Corollary 3.4). Against the guarantee L·K ln 2/ε of Protocol R the count saves the factor ln 2·log(L/ε)/2.7 = log(L/ε)/3.9: 1.03 at L/ε = 16, 5.1 at L/ε = 10⁶, 7.7 at L/ε = 10⁹.
9. *Not a way around N1.* The steps of type (A) remove every alternative whose posterior weight at some input of X₀ exceeds γ. A member of smaller weight at an input is still unrefuted; if it is the human, the deployed vote is wrong at that input with certainty. The theorem bounds how often a run meets such inputs and says nothing about any one input (attack report, Section 4, test 1).

**Corollary 3.4 (the right dependence on the complexity of the class).**
1. *Upper bound in bits.* For every class of functions with weights, every member f, every scaffold with L calls and every ε with L/ε ≥ 16, 1 + 2.7·K·L/(ε·log(L/ε)) questions suffice for a deployed run that is faithful with probability ≥ 1 − ε (K = log(1/w(f)) is needed to choose the number of audits; the human is deterministic and a member on all of X₀).
2. *Lower bound.* For all m ≥ 1, L ≥ 1 and δ ≤ 1/20 with N := L/(2δ) an integer, the block class 𝒩^m(N) with the block scaffold needs at least (1 − 10δ)·m·L/(8δ) questions, in expectation over a uniform member, to make the deployed outcome right with probability ≥ 1 − δ for every member. The class has 2^K members with K = m·log(L/(2δ)) and VC dimension d = m (for N ≥ 2: the m inputs (j, 1), j ∈ [m], are shattered, and of two inputs in one block at most one is answered 1).
3. *In terms of the VC dimension d* the statement asked for holds with c = (1 − 10δ)/8: there are classes of VC dimension d and scaffolds with L calls for which every protocol, however it chooses its questions, needs at least c·d·L/δ questions. This is the bound d/ε′ of passive learning at ε′ = δ/L; for this class 1 + 2.7·d·L/δ questions suffice by (1), since K ≤ d·log(L/δ).
4. *In terms of description length* (the K = log(1/w(f)) of the candidate theory) the statement "for some absolute c > 0 there are classes of functions of complexity K and scaffolds with L calls for which every protocol needs c·K·L/ε questions" is **false**: by (1) it fails as soon as log(L/ε) > 2.7/c (and K·L/ε is large enough to absorb the additive 1). The refutation is for the reading "for all K, L and ε there is a class all of whose members have complexity K", in which K is known to the protocol. The worst case over classes of weight-complexity K ≥ log(L/(2δ)) is of order K·L/(δ·log(L/δ)), with constants 1/8 from below (2) and 2.7 from above (1).
5. *For the candidate theory.* The sentence "this is optimal up to the factor K" (Section 0, item 2) can be sharpened in two ways, which are different statements. (i) *The minimax number of questions* over classes of K bits is of order K·L/(δ·log(L/δ)), by (2) and (1). So the guarantee L·K ln 2/δ of Protocol R exceeds the minimax number by a factor of order log(L/δ); on the block classes the factor is at most 8 ln 2·log(L/(2δ))/(1 − 10δ). (ii) *That Protocol R itself needs of order K·L/δ questions* on some class of K bits does not follow from (i) and is not shown by the block classes. It is Proposition 3.7 below, on a class whose informative inputs are rare in runs.

**What the block class does not show** (both reports; exact computation in the attack report, `proofs/code/lower-bounds_attack_budget.out`, part D). On the block class with N = L/(2δ) the question of a round of Protocol R is a uniformly chosen cell among the m·N cells, independent of the past, because the inputs of the block scaffold do not depend on the answers. The least number of rounds after which the deployed mixture has failure at most δ is 3.59, 3.65, 3.80 and 3.69 times m·N in four cases computed exactly; the check report's simulation gave 3.4 to 3.8. That is about 1.9·m·L/δ: of the order of the lower bound (1 − 10δ)·m·L/(8δ) of Theorem 3.1, and in all four cases below the number 1 + 2.7·K·L/(δ·log(L/δ)) that Theorem 3.3 guarantees for Protocol AB on the same class (for example 7 480 rounds against 9 678 for m = 16, N = 128, L = 4). So on the classes that are hardest for every protocol, rehearsal with random questions is within a constant factor of optimal, and the logarithm that Theorem 3.3 removes is, there, a slack of the bound R1 and not of the protocol. The next statement proves this for all parameters.

**Proposition 3.10 (rehearsal on the block class; added last by the editor, hence its number; not seen by the verifiers).** Let N = L/(2δ) be an integer. On the block class 𝒩^m(N) with equal weights and the block scaffold, Protocol R with n ≥ 4·m·N = 2·m·L/δ rounds, deploying M^(T) with T uniform on [n], has Fail(f_a) ≤ δ for every a. So on these classes rehearsal is within the factor 16/(1 − 10δ) of the lower bound of Theorem 3.1.

*Proof.* Every run of the block scaffold has exactly L calls and its inputs do not depend on the answers, so the question of each round is a uniformly chosen cell among the m·N cells, independent of the past. The prior is a product over the blocks and each answer concerns one block, so the posterior is a product over the blocks. Fix a and a deployed run in block j. If the needle a_j was asked before round t, the posterior of block j is the point mass at a_j, the mixture answers every call as f_a does, and the run does not fail. Otherwise the posterior of a_j is uniform on the N − k cells of the block that were not asked, k being the number of asked ones. The run can fail only if it visits the needle, which has probability p ≤ L/N, or if the mixture answers 1 at some call; at each call the cell is one of the N − k unasked ones with probability (N − k)/N and the mixture then answers 1 with probability 1/(N − k), so this has probability at most L/N. Hence the failure of M^(t), given the data, is at most 2L/N = 4δ when a_j was not asked before round t, an event of probability (1 − 1/(mN))^(t−1). Averaging over t ≤ n gives Fail(f_a) ≤ 4δ·(1/n)·Σ_{t ≤ n} (1 − 1/(mN))^(t−1) ≤ 4δ·m·N/n ≤ δ. Finally 4·m·N = 2·m·L/δ, and the lower bound of Theorem 3.1 is (1 − 10δ)·m·L/(8δ). ∎

The exact least numbers of rounds quoted above (3.59 to 3.80 times m·N) lie just below this bound of 4·m·N, as they must.

**Remark 3.5 (small K).** If K < log(L/(2δ)), a class with at most 2^K members is identified on X₀ with at most 2^K − 1 questions (ask an input at which two surviving members differ; each answer refutes at least one). The needle class with N₀ = 2^K − 1 cells needs n ≥ N₀ − δ(N₀ + L)/p(L, N₀) questions (Corollary 2.2); this is at least N₀/2 when L ≤ N₀ ≤ L/(8δ) (then p ≥ L/(2N₀)). When N₀ ≤ L, use Lemma 1.10(1) instead (this is Proposition 5.4(a)): failure ≤ δ for f₀ and for f_i gives π_i ≥ 1 − 2δ/p for every i, hence n ≥ Σ_i π_i ≥ N₀·(1 − 2δ/p) ≥ N₀·(1 − 3.2δ), because p ≥ 1 − 1/e. So for every K with 2^K − 1 ≤ L/(8δ) the worst case lies between (2^K − 1)·min{1 − 3.2δ, 1/2} and 2^K − 1, and for larger K it is of order K·L/(δ·log(L/δ)) (Corollary 3.4). (The prover's version had an exceptional range 2^K = O(δL); the check report removed it by the argument just given.)

**Remark 3.6 (relation to the literature).** The standard lower bound for learning a class of VC dimension d from random examples to error ε′ is of order d/ε′ (Ehrenfeucht, Haussler, Kearns and Valiant 1989). Its proof does not apply here: its hard instance (a shattered set of d inputs, most of them rare) is learned with d well-chosen questions when the learner may choose its questions. What makes questions expensive for every protocol is search: in the block class the d shattered inputs are hidden among d·N cells. A search over N cells yields log N bits, which is why the bound in bits carries K/log(L/δ) and not K. The hard instance of passive learning is, on the other hand, exactly where rehearsal with random questions has to pay: Proposition 3.7 is the bound d/ε′ at the per-call error ε′ = 4ε/L. The saving of a logarithm by chosen questions is known for exact learning with membership queries (Hegedűs 1995; Moshkov 1983), and Protocol AB is that algorithm (Remark 1 on Theorem 3.3). For that problem the upper bound (ETD/log ETD)·log|C| is attained up to a constant by a class of Moshkov, according to Bshouty (2017); Theorem 3.1 is the counterpart of that statement for runs. (Moshkov's class was not seen by anyone in this project, and it is not claimed that it is the block class.) See Section 11 for the citations and for what was read.

### 3.3 A lower bound for rehearsal with random questions

The prover's file said that Protocol R "is not optimal" and proved only that its guarantee is not the minimax number. The check report supplied the missing lower bound; the attack report re-derived it; the editor re-derived it again. It is stated here as the check report gives it.

**Proposition 3.7 (the rare-points class; check report, Proposition A1).** Let d ≥ 1, L ≥ 1, 0 < ε ≤ 1/8 and q := 4ε/L. Let X := {x₀} ∪ [d] and Y := {0, 1}. Let H be the set of the 2^d functions g: X → {0, 1} with g(x₀) = 0, with equal weights, so that K = d for every member. Let the scaffold make exactly L calls whose inputs are independent draws from the law μ that gives x₀ probability 1 − q and each point of [d] probability q/d; the inputs are internal randomness of the scaffold and do not depend on the answers. The outcome is the list of the L answers.

(a) Let a protocol put to the human n inputs drawn independently from μ and independently of the human's answers, and then deploy any system (Definition 1.3). Then the average of Fail(f) over the 2^d members is at least 2ε(1 − 2ε)·(1 − q/d)^n. Hence failure at most ε for every member requires

  n ≥ ln(2(1 − 2ε))·(L·d/(4ε) − 1) ≥ 0.1·K·L/ε − 0.4.

(b) Protocol R with n rounds is such a protocol, whatever it deploys: the question of a round is the input of call J of the rehearsal run, and since the inputs of a run do not depend on the answers and J is independent of the run, this is one draw from μ, independent of the past.

(c) The protocol that asks the inputs 1, …, d and deploys the function it has seen has failure 0 with d = K questions.

*Proof.* (a) Let f be uniform on H and independent of the questions, of the seed and of (z, ρ, s). Let U be the set of points of [d] that are not among the n questions; each point is in U with probability (1 − q/d)^n, so E|U| = d·(1 − q/d)^n. The transcript is a function of the questions and of the values of f at the asked points. Hence, given the seed, the transcript and the inputs of the run, the values of f on U are independent fair bits, and the deployed outcome does not depend on them. If the run has a call with input in U, the true outcome contains such a bit, so the deployed outcome is wrong with conditional probability at least 1/2. Given U, the run has a call in U with probability 1 − (1 − q|U|/d)^L ≥ (L·q·|U|/d)·(1 − L·q·|U|/(2d)) ≥ (4ε|U|/d)·(1 − 2ε), by 1 − (1 − x)^L ≥ Lx − (Lx)²/2 and L·q = 4ε. Taking expectations, the average failure is at least (1/2)·4ε(1 − 2ε)·E|U|/d = 2ε(1 − 2ε)(1 − q/d)^n. If every member has failure at most ε, then (1 − q/d)^n ≤ 1/(2(1 − 2ε)), so n ≥ ln(2(1 − 2ε))/ln(1/(1 − q/d)) ≥ ln(2(1 − 2ε))·(d/q − 1), because ln(1/(1 − x)) ≤ x/(1 − x). For ε ≤ 1/8, ln(2(1 − 2ε)) ≥ ln 1.5 > 0.4, and d/q = L·d/(4ε). (b) and (c) are immediate. ∎

*Consequences.* (i) By Lemma 5.1′ below (Theorem R1 for a function), Protocol R reaches failure ε on this class with ⌈L·K ln 2/ε⌉ rounds. So R1 is sharp for Protocol R up to the factor ln 2/0.1 < 7. By exact computation Protocol R needs between 0.35 and 0.39 times K·L/ε rounds in six cases (`proofs/code/lower-bounds_ab_sim.out`, part C). (ii) On this class Protocol R needs at least L/(10ε) − 0.4/K times the K questions of the protocol of (c). (iii) Protocol AB needs at most 1 + 2.7·K·L/(ε·log(L/ε)) questions on every class of K bits. So the worst case of Protocol R over classes of K bits exceeds the minimax number of questions by a factor that is at least log(L/ε)/27 in the limit of large K·L/ε. With these constants that factor exceeds 1 only for L/ε > 2^27; on the rare-points class itself the gap is the plain factor of (ii). This, and not Corollary 3.4, is the proof that rehearsal with random questions is not optimal for a deterministic human. The cause is the random choice of the question, not the mixture: (a) holds for every deployed system. (iv) The separation is on a class whose informative inputs are rare in runs. On the block classes there is none (the paragraph after Corollary 3.4).

### 3.4 Protocol AB and fault tolerance; a variant with rehearsal questions only

**Proposition 3.8 (Protocol AB bounds the number of faults; check report, Proposition A2).** In the setting of Theorem 3.3 assume that X₀ contains every input that Π can produce when its calls are answered by arbitrary elements of Y, or that L·γ < 1; by Theorem 3.3(4) every audited input then lies in X₀. Call a call of a run of a function h a *fault* if h differs from f at the input of that call (for a deterministic human these are the unfaithful calls of the note). For a step t of type (B) let v_t be the expected number of faults of the run of h_t, over (z, ρ), given the data before the step.

1. E[Σ v_t over the n_B steps of type (B)] = L·E[b] ≤ L·K/log(1/γ). So the run of the deployed function h has at most L·K/(n_B·log(1/γ)) faults in expectation.
2. If the human system of f tolerates m faults with failure δ₀ for a set G of runs (Definition 5.1; rules that see only the history suffice), then Pr[deployed run ∉ G] ≤ δ₀ + L·K/((m + 1)·n_B·log(1/γ)).
3. Let X₀ contain every input that Π can produce under arbitrary answers. Let β > 0 with L/β ≥ 16, u := log(L/β), γ := u·β/L and n_B := max{1, ⌈L·K/(β·(u − log u))⌉}. Then the deployed run has at most β faults in expectation and at most 1 + 2.7·K·L/(β·log(L/β)) questions are asked. With β := (m + 1)·δ′ the failure is at most δ₀ + δ′.

*Proof.* (1) At a step of type (B) the audited call is call J of the run of h_t, with J uniform on [L] and independent of the run. The human's answer differs from that of h_t exactly when the run has a J-th call and that call is a fault; by the hypothesis the audited input lies in X₀, so the step then adds one to b. So the conditional probability that the step adds one to b is v_t/L. Whether a step is the i-th step of type (B) is determined by the data before it; summing over these steps gives E Σ v_t = L·E[b], and b ≤ K/log(1/γ) by Theorem 3.3(1). The deployed h is that of a uniformly chosen step of type (B). (2) The run of h is the run of the human system under the rule that replaces the human's answer f(x_j) by h(x_j) at every call where the two differ; the rule sees only the input of the call. The rule that does the same for its first m replacements and then replaces nothing is admissible, so its run is in G with probability at least 1 − δ₀. The two runs coincide unless the run of h has at least m + 1 faults, which by Markov's inequality has probability at most the expected number of faults divided by m + 1. (3) is the arithmetic of Theorem 3.3(3) with β in place of ε; that arithmetic does not use ε < 1. (Here L·γ = u·β may exceed 1, which is why (3) asks for the larger X₀.) ∎

*Consequences.* The prover's file said that Theorem 3.3 "gains nothing from m > 0" and listed a fault-tolerant version as open. It is not open: by (3), for the region class and the block-majority scaffold of Theorem 5.3 with L/((m + 1)δ) ≥ 16, where K = log(L/(2(2m + 1)δ) + 1) ≤ log(L/((m + 1)δ)), at most 1 + 2.7·L/((m + 1)δ) questions suffice (β = (m + 1)δ, δ₀ = 0), against the necessary (1 − 4δ)·L/(4(2m + 1)δ). Second, a single deterministic function per run can be as good as the per-call mixture also for the number of unfaithful calls; this bears on the candidate's R5 (Section 10, item 7). Check: in the simulation of the check report the average number of faults of the deployed run was below the bound in all 15 instances, and the averages of Σ v_t/L and of b agreed within sampling error (`proofs/code/lower-bounds_ab_sim.out`, part A).

**Proposition 3.9 (a variant whose questions are all calls of its own rehearsal runs; check report, Remark A3).** Setting of Theorem 3.3, L ≥ 3. Fix γ := ln L/L. In round t = 1, …, n: let h_t(x) be an answer of largest posterior weight M_t(·|x) (the first one in a fixed order in case of a tie); call an input x *split* if max_y M_t(y|x) ≤ 1 − γ; draw (z, ρ) and run Π with h_t answering every call; if the run has a call with a split input, put the first such call to the human; otherwise draw J uniformly from [L] and, if the run has a J-th call, put it to the human. Deploy h_T for T uniform on [n]. Then, for every n,

  Pr[the deployed run differs from run_f(z, ρ)] ≤ K·L/(n·log(L/ln L)).

*Proof.* Let a be the number of rounds in which a split call was asked and b the number of other rounds in which the human's answer differed from h_t's. A split input multiplies the consistent weight by at most 1 − γ whatever the answer; a disagreement at an input that is not split multiplies it by less than γ, because h_t's answer has weight above 1 − γ there. So a·ln(1/(1 − γ)) + b·ln(1/γ) ≤ K ln 2 on every path, and therefore a + L·b ≤ K ln 2·max{1/ln(1/(1 − γ)), L/ln(1/γ)}. Given the data before round t let α_t be the probability that the run of h_t has a split call and u_t the probability that it differs from the run of f. A split call is asked with probability α_t. On the event that the run has no split call and differs from the run of f, the first call at whose input h_t and f differ is audited with probability 1/L; so a disagreement of the second kind has probability at least (u_t − α_t)/L. Hence u_t ≤ E[1{split call asked in round t} + L·1{disagreement of the second kind in round t} | data], and E Σ_t u_t ≤ E[a + L·b]. The deployed failure is (1/n)·E Σ_t u_t. For γ = ln L/L and L ≥ 3: 1/ln(1/(1 − γ)) ≤ 1/γ = L/ln L ≤ L/(ln L − ln ln L) = L/ln(1/γ), so the maximum is L/ln(L/ln L), and K ln 2·L/ln(L/ln L) = K·L/log(L/ln L). ∎

What this gives: the bound L·K ln 2/n of Theorem R2 for a function is improved by the factor ln(L/ln L) (which exceeds 1 for every L ≥ 3 and is about 5 for L = 1000), by a protocol that asks only calls of its own rehearsal runs, examines only the inputs of the current run, and does not need K. It saves log L and not log(1/ε): the larger saving of Protocol AB comes from the questions outside the runs. On the rare-points class of Proposition 3.7 this variant needs about 0.4·K/ε rounds where Protocol R needs about 0.37·K·L/ε (exact computation, `proofs/code/lower-bounds_ab_sim.out`, part C). The guarantee is for the probability of a fully faithful run only; for the expected number of faults the same argument gives nothing better than Protocol R. Check: `proofs/code/lower-bounds_ab_sim.out`, part E (ten instances). The check report asked for a second check of this statement; the attack report followed the proof and the editor re-derived it.

## 4. Shift outside the closed system (N3 and S2)

### 4.1 N3: each alternative shift must be paid for

**Theorem 4.1 (N3, exact form).** Let Q_1, …, Q_N ⊆ X be disjoint and nonempty, D_i a probability law on X with D_i(Q_i) = 1, and 𝒮 := {f₀, f_1, …, f_N} with f₀ ≡ 0 and f_i := 1_{Q_i}. Under *shift i* the task is one call at x ~ D_i. For a protocol Λ with a deployed system let s_i(f) := Pr_f[the deployed answer at x ~ D_i equals f(x)], π_i := Pr[Λ asks an input of Q_i when the human is f₀], and n := E_{f₀}[N_Λ].
1. s_i(f₀) + s_i(f_i) ≤ 1 + π_i for every i, and Σ_i π_i ≤ n. Hence Σ_i (s_i(f₀) + s_i(f_i) − 1) ≤ n: the advantages over 1/2 are paid from a budget of n.
2. If s_i(f) ≥ 1/2 + η for all i and all f ∈ 𝒮, then n ≥ 2ηN. In particular success probability ≥ 1 − δ under every shift needs n ≥ (1 − 2δ)·N.
3. For every integer 0 ≤ n ≤ N there is a protocol with n questions and s_i(f) ≥ 1/2 + n/(2N) for all i and all f ∈ 𝒮. So the best uniform advantage with n questions is exactly n/(2N).
4. For a *deterministic* protocol π_i ∈ {0, 1}, so s_i(f) > 1/2 for all i and f forces a question in every Q_i and n ≥ N: this is N3 as stated in the candidate theory. For *randomised* protocols N3 as stated is false: by (3) one question gives success probability ≥ 1/2 + 1/(2N) > 1/2 for every member under every shift. The correct statement is (2).

*Proof.* (1) Apply Lemma 1.10(1) to the scaffold "one call at x ~ D_i, outcome = answer" with the single patch B := Q_i: f_i ≠ f₀ at D_i-almost every x, so Δ = 1 and Fail(f₀) + Fail(f_i) ≥ 1 − π_i. The Q_i are disjoint, so Σ_i π_i ≤ n as in Lemma 1.10. (2) follows from (1). (3) Fix a point q_i ∈ Q_i for each i. Draw a uniformly random n-subset I of [N] and ask q_i for i ∈ I. If an answer is 1, say at q_j, the human is f_j; deploy it. Otherwise the human is f₀ or f_j with j ∉ I; deploy the rule that answers 0 on Q_i for i ∈ I and outside ∪Q_i, and a fair coin on Q_i for i ∉ I. Under shift i, for f₀ and for f_i the answer is right with probability Pr[i ∈ I] + (1/2)·Pr[i ∉ I] = 1/2 + n/(2N). For f_j with j ≠ i it is right if j ∈ I or i ∈ I, and with probability 1/2 otherwise; Pr[i ∈ I or j ∈ I] ≥ n/N. (4) is immediate. ∎

The value n/(2N) of (3) was confirmed as the exact optimum by linear programming for N ≤ 5 (Section 8).

**Corollary 4.2 (description length).** Let X = {0, 1}* and k ≥ 1. The 2^k sets Q_i := {x : x begins with i}, i ∈ {0,1}^k, are disjoint and decidable with K(Q_i) ≤ k + K(k) + c ≤ k + 2 log k + c′; the indicators f_i and the laws D_i := uniform on Q_i ∩ {0,1}^(2k) have complexity at most k + 2 log k + c″. By Theorem 4.1, being right with probability ≥ 1/2 + η under each of these 2^k shifts, for the zero function and each f_i, needs n ≥ 2η·2^k questions.

*Remark on the constant.* The candidate theory writes "complexity ≤ k + c". This holds for the complexity conditional on k. For prefix complexity the bound for all 2^k regions is k + K(k) + c; the number of objects of prefix complexity at most j is 2^(j − K(j) + O(1)) [from memory: a counting theorem of Chaitin, see Section 11], so the term K(k) cannot be dropped for a family of 2^k sets in general (it can for those k that are themselves simple). This changes "2^k" to "2^k up to a factor polynomial in k" and nothing else.

*The count, in full* (check report, Section 4.4; the prover had listed the question as open). The largest number of disjoint decidable regions of complexity at most k is 2^(k − K(k) + O(1)). Upper bound: let N_j be the number of programs of length at most j in the domain of the prefix machine. Then Σ_j 2^(−j)·N_j = Σ_p Σ_{j ≥ |p|} 2^(−j) ≤ 2·Σ_p 2^(−|p|) ≤ 2, and N_j is lower semicomputable uniformly in j; so j ↦ 2^(−j)·N_j/2 is a lower semicomputable semimeasure on the integers and is at most 2^(−K(j) + O(1)) by the coding theorem (Section 11; quoted from memory). Hence at most 2^(j − K(j) + O(1)) different sets have a decider of complexity at most j, and a family of 2^k different sets of complexity at most k + c forces K(k) ≤ c + O(1). Lower bound: for a constant c′ the 2^(k − K(k) − c′) sets of strings that begin with a given word of length k − K(k) − c′ are disjoint and decidable, and each has complexity at most (k − K(k) − c′) + K(k − K(k) − c′) + O(1) ≤ k − c′ + O(1), because k − K(k) − c′ is computed from a shortest program for k, which also gives K(k); this is at most k when c′ is large enough.

**Theorem 4.3 (N shifts and L critical calls).** Let X := [N] × [N₀], let the class consist of f₀ ≡ 0 and the N·N₀ point indicators f_{i,c} := 1[· = (i, c)], and let shift i be the OR scaffold with L calls that are independent and uniform on {i} × [N₀]. If under every shift every member has failure ≤ δ, then

  n := E_{f₀}[N_Λ] ≥ N·(N₀ − δ(N₀ + L)/p(L, N₀)),  and for N₀ = ⌈L/(2δ)⌉, δ ≤ 1/6:  n ≥ N·(L/(4δ) − 3L/2).

Every member has K = log(N·N₀ + 1) with uniform weights.

*Proof.* For each i apply Lemma 1.10(2) to the scaffold of shift i with the patches B_c := {(i, c)}, c ∈ [N₀]: with n_i the expected number of questions in {i} × [N₀] on the f₀-path, Σ_c π_{i,c} ≤ n_i (the refinement of Lemma 1.10 noted after its proof: the number of cells of region i that are hit is at most the number of questions in region i) and some member fails with probability ≥ (N₀ − n_i)p/(N₀ + L). So n_i ≥ N₀ − δ(N₀+L)/p for every i, and Σ_i n_i ≤ n. The numbers are those of Corollary 2.2(2). ∎

### 4.2 S2: the matching upper bound, and what "samplable" has to mean

**Proposition 4.4 (S2).**

(a) *Domination.* Let (D_i)_{i ∈ I} be a countable family of laws of the top-level input z, π_i > 0 with Σ_i π_i ≤ 1, and ξ := Σ_i π_i D_i/Σ_i π_i. For every measurable Φ ≥ 0 and every i,

  E_{z~D_i} Φ(z) ≤ E_{z~ξ} Φ(z)/π_i.

Consequently, if a protocol is run with top-level inputs z ~ ξ in rehearsal and its guarantee has the form E_{z~ξ} Φ(z) ≤ β for one of the functionals Φ(z) := E[number of unfaithful calls of the deployed run | z], Pr[deployed run unfaithful | z], Pr[failure | z], then under deployment with z ~ D_i the same quantity is at most β/π_i. With the candidate's R2 for a function: Pr[deployed run unfaithful under D_i] ≤ L·K ln 2/(π_i·n).

(b) *When this is a protocol.* Rehearsal has to draw z ~ ξ. This is possible by an almost surely halting randomised procedure if the family is *uniformly samplable*: i ↦ (a probabilistic program that halts with probability one and outputs z ~ D_i) is computable, and the index i can be drawn with probabilities proportional to π_i by a halting procedure (for example π_i = 2^(−ℓ(i)) for the code lengths ℓ of a complete prefix code). Examples: a finite list of task laws; all laws sampled by programs p of a fixed machine within a fixed computable time bound, with the index p drawn by choosing its length ℓ with probability 2^(−ℓ−1) and then ℓ fair bits, which gives π_p = 2^(−2|p|−1) and B ≤ 2^(2|p|+1) for a law with such a program p.

(c) *What is not possible.* Let 𝒟 be the set of all laws on Z = {0,1}* that are sampled by a probabilistic program that halts with probability one. For every ξ ∈ 𝒟 there is D ∈ 𝒟 with sup_z D(z)/ξ(z) = ∞. Hence no almost surely halting rehearsal sampler has a finite factor B for every samplable task law. The universal mixture does: with ξ_U(z) := Σ_p 2^(−|p|)·Pr[U(p) outputs z] over all programs p of a universal prefix machine with access to coins, the normalised law ξ̄_U := ξ_U/ξ_U(Z) satisfies D ≤ 2^(K(D))·ξ̄_U for every D ∈ 𝒟, where K(D) is the length of a shortest program sampling D. ξ̄_U is not in 𝒟; it is computable relative to the halting problem and can therefore be sampled exactly by a procedure with an oracle for the halting problem.

(d) *Optimality.* For N disjointly supported task laws and π_i = 1/N, (a) costs a factor N, and Theorem 4.3 shows that a factor N is necessary: N·(L/(4δ) − 3L/2) questions against N·L·K ln 2/δ.

*Proof.* (a) Σ_i π_i ≤ 1 gives ξ ≥ π_i·D_i pointwise; integrate Φ ≥ 0. (b) Draw i, then run the sampler of D_i. (c) Let ξ ∈ 𝒟. Then ξ(z), the probability that the sampler halts with output z, is lower semicomputable, and because Σ_z ξ(z) = 1 it is also upper semicomputable (ξ(z) = 1 − Σ_{z′≠z} ξ(z′)); so ξ is computable. Define z_1, z_2, … recursively: z_j is the first string found, by a dovetailed search through all strings and all upper approximations of ξ, that differs from z_1, …, z_{j−1} and has ξ(z_j) < 4^(−j). The search halts because all but finitely many strings have ξ(z) < 4^(−j). Let D(z_j) := 2^(−j). D is sampled by drawing j with probability 2^(−j) and computing z_j, so D ∈ 𝒟, and D(z_j)/ξ(z_j) > 2^j. For the universal mixture: if p samples D then ξ_U ≥ 2^(−|p|)·D and ξ̄_U ≥ ξ_U. ξ̄_U ∉ 𝒟 by the first part. Each ξ_U(z) and the normaliser are limits of computable nondecreasing sequences of rationals, hence computable to any precision with an oracle for the halting problem; a law that is computable relative to an oracle is sampled exactly, with fair coins and that oracle, by comparing a uniform random real with the cumulative sums to increasing precision, which halts with probability one. (d) is Theorem 4.3 and (a) with R2. ∎

**What S2 should say.** "Samplable" must be read as *uniformly samplable family with a samplable prior on indices* (for example a time bound on the samplers). Then B_i ≤ 1/π_i exactly (the candidate's constant c is 0 when π_i is the weight used in the mixture). For the family of all samplable laws with weights 2^(−K(i)) the statement is true as an inequality, but a protocol that is to have a finite factor for every samplable law at every n needs an oracle for the halting problem to draw its rehearsal inputs. What ordinary compute gives is this (the prover's sentence "unlimited ordinary compute is not enough" said too much; attack report, finding m4, and check report on Proposition 4.4): a rehearsal sampler that runs programs under a fixed time bound dominates the laws sampled within that bound and no others; and with time bounds that grow with the round, every samplable law gets the same factor up to an additive term that tends to 0 at a rate depending on the law's own sampler (Proposition 4.6 below). The term is not uniform over the samplable laws, and by (c) it cannot be. Second, S1 and S2 are cleanest at the level of the top-level law, as in (a): the per-call visit measure at deployment depends on the imitator, the top-level law does not.

**Remark 4.5 (abstention under a shift).** Let the deployed system be allowed to abstain, and count only silent errors. For shift i, the members f₀ and f_i agree outside Q_i, so in Lemma 1.5 γ = π_i. The proof of Corollary 1.7, applied to the pair (x, answer) with x ~ D_i, gives: the silent-error probabilities of f₀ and f_i under shift i sum to at least 1 − π_i − a_i, where a_i is the smaller of the two abstention probabilities under shift i. So a system whose silent-error probability is at most σ for both members abstains with probability at least 1 − π_i − 2σ under shift i: on every shift that was not paid for it abstains almost always.

**Proposition 4.6 (S2 with ordinary compute, at the price of an additive term; attack report, Proposition X4).** Fix a machine with fair coins, let the programs p be the binary strings with weights π_p := 2^(−2|p|−1) (the weights of Proposition 4.4(b); they sum to 1), and let b(1) ≤ b(2) ≤ … be time bounds. Modify Protocol R: in round t draw p with probability π_p and run it for at most b(t) steps; if it has stopped with an output z, carry out the round with top-level input z; otherwise the round asks nothing. Deploy M^(T), T uniform on [n]. Let the human be a function f ∈ H with K = log(1/w(f)). Then for every task law D that is sampled by a program p_D halting with probability one,

  Pr[the deployed run with z ~ D is unfaithful] ≤ 2^(2|p_D|+1)·L·K ln 2/n + (1/n)·Σ_{t ≤ n} τ_D(b(t)),

where τ_D(b) is the probability that p_D runs for more than b steps. If b(t) → ∞ the second term tends to 0 for every such D.

*Proof.* Let D^(t)(z) be the probability that p_D outputs z within b(t) steps; then D^(t) ≤ D and D − D^(t) has total mass τ_D(b(t)). The top-level input of round t has the sub-probability law ξ^(t) ≥ π_{p_D}·D^(t). Given the data before round t let β_t(z) be the expected number of unfaithful calls of the run of M^(t) on z, and u_t(z) ≤ min{1, β_t(z)} the probability that there is one. As in Lemma 5.1′, the audited call is a uniformly chosen call of the rehearsal run, and the sum over the asked inputs of −ln M^(t)(f(x)|x) is at most K ln 2 on every path; so Σ_t E Σ_z ξ^(t)(z)·β_t(z) ≤ L·K ln 2. Hence E Σ_z D(z)·u_t(z) ≤ E Σ_z D^(t)(z)·β_t(z) + τ_D(b(t)) ≤ E Σ_z ξ^(t)(z)·β_t(z)/π_{p_D} + τ_D(b(t)); average over t ≤ n. The second term tends to 0 because p_D halts with probability one. ∎

The rounds in which no program stops cost compute and no question. So what the candidate's S2 needs is this: an oracle, for the inequality with a finite factor for every samplable law at every n; nothing beyond ordinary compute, for the same factor with a term that vanishes at a rate depending on the law's sampler; and a fixed time bound, for a factor valid for the laws sampled within that bound. (This statement was not seen by the check report; the editor re-derived it.)

## 5. Fault tolerance (N5)

### 5.1 Definitions and the upper bound

**Definition 5.1.** Let f be a function, Π a scaffold and G a set of runs. A *replacement rule with at most m replacements* sees, at each call, (z, ρ), the history of the run and the human's answer f(x_j), and may replace the answer by any element of Y ∪ {⊥}; it replaces at most m answers in a run. (The candidate's rule sees only the history and the answer; giving it (z, ρ) makes tolerance a stronger property, so the lower bound below is stronger. In the upper bound only rules of the candidate's kind are used.) The human system of f *tolerates m faults with failure δ₀* (for G) if for every such rule, deterministic or randomised with coins independent of (z, ρ), the run is in G with probability ≥ 1 − δ₀. In the lower bounds G is G_f := {the outcome equals out_f(z, ρ)}, so that "the deployed run is not in G_f" is the event Fail of Definition 1.4.
The *robustness curve* of (Π, f, G) is

  δ_Π(β) := sup{ Q_C(not G) : C a sampler with E_{Q_C} Σ_j (1 − C(f(x_j)|x_j)) ≤ β },  0 ≤ β ≤ L;

1 − C(f(x)|x) is the total variation between C(·|x) and the answer f(x), so this is the curve of the candidate's R3 for a function. δ_Π is nondecreasing and bounded by 1; let δ̄_Π be its least concave majorant on [0, L], which is again nondecreasing.

**Lemma 5.1′ (the candidate's R1 for a function; proof reproduced for completeness).** In Protocol R (candidate theory, Section 3) with a function f ∈ H as the human, let β_t := E_{Q_{M^(t)}} Σ_j (1 − M^(t)(f(x_j)|x_j)) be the expected number of calls of a run driven by the round-t mixture at which its draw differs from f, given the data before round t. Then Σ_{t=1}^{n} E[β_t] ≤ L·K ln 2, so E[β_T] ≤ L·K ln 2/n for T uniform on [n].

*Proof.* Let W_t be the prior mass of the hypotheses weighted by the likelihood of the answers before round t: W_1 ≤ 1, W_{t+1} = W_t·M^(t)(f(x)|x) if x is asked in round t and W_{t+1} = W_t otherwise, and W_{n+1} ≥ w(f). Hence the sum over the asked inputs of −ln M^(t)(f(x)|x) is at most ln(1/w(f)) = K ln 2 on every path, and 1 − M ≤ −ln M. In round t the asked input is that of call J of the rehearsal run when the run has at least J calls, with J uniform on [L] and independent of the run; so the conditional expectation of 1 − M^(t)(f(x_J)|x_J) on that event, given the past, is β_t/L. ∎

**Proposition 5.2 (upper bound through the robustness curve).** Let f ∈ H be a function and G any set of runs. After Protocol R with n rounds, the run deployed with M^(T), T uniform on [n], satisfies

  Pr[deployed run ∉ G] ≤ δ̄_Π(min{L, L·K ln 2/n}).

If the human system tolerates m faults with failure δ₀, then δ_Π(β) ≤ δ₀ + β/(m + 1) for all β, and therefore Pr[deployed run ∉ G] ≤ δ₀ + L·K ln 2/((m + 1)·n). This is the candidate's R3 for a function. The statement is for a deterministic human and for a deployed imitator that draws afresh at every call (the supremum in δ_Π runs over samplers); for a human who is not deterministic see Proposition 5.7.

*Proof.* Given T and the data, the deployed imitator C := M^(T) is a sampler with E_{Q_C} Σ_j (1 − C(f(x_j)|x_j)) = β_T ≤ L. So Q_C(not G) ≤ δ_Π(β_T) ≤ δ̄_Π(β_T), and by Jensen's inequality, monotonicity and Lemma 5.1′, E δ̄_Π(β_T) ≤ δ̄_Π(E β_T) ≤ δ̄_Π(min{L, L·K ln 2/n}) (the minimum because β_T ≤ L always; for n < K ln 2 the number L·K ln 2/n lies outside the domain [0, L] of the majorant, as the check report noted).
For the second claim let C be a sampler with expected number of faults at most β, where a call of a run of C is a *fault* if the draw y_j ~ C(·|x_j) differs from f(x_j). A run of C is a run of f under the randomised replacement rule "draw y_j ~ C(·|x_j) and replace f(x_j) by it if it differs". Let the truncated rule do the same until it has made m replacements and then replace nothing. It makes at most m replacements, so its run is in G with probability ≥ 1 − δ₀. With the same coins the two runs coincide unless the run of C has at least m + 1 faults, which has probability at most β/(m + 1) by Markov's inequality. ∎

### 5.2 The lower bound

**Definition 5.2′ (block-majority scaffold).** Let m ≥ 0, B ≥ 1, N₀ ≥ 1 be integers and L := B·(2m + 1). X := [N₀] × [2m + 1], Y := {0, 1}. The *region class* is {f₀, f_1, …, f_{N₀}} with f₀ ≡ 0 and f_i(i′, u) := 1[i′ = i]. The scaffold Π^maj has z = (R_1, …, R_B) independent and uniform on [N₀] and no internal randomness; block b consists of the 2m + 1 calls at the inputs (R_b, 1), …, (R_b, 2m + 1); the value of a block is 1 if at least m + 1 of its answers equal 1, and 0 otherwise (an answer ⊥ is not equal to 1); out is the maximum of the block values.

**Theorem 5.3 (N5).**
1. For every member f of the region class, the human system of f tolerates m faults with failure 0 for G_f, against all replacement rules of Definition 5.1.
2. For every protocol Λ and deployed system, with n := E_{f₀}[N_Λ], some member has Fail ≥ (N₀ − n)·p(B, N₀)/(N₀ + B).
3. Hence failure ≤ δ for all members needs n ≥ N₀ − δ(N₀ + B)/p(B, N₀); if N₀ = B/(2δ) is an integer,

  n ≥ B/(4δ) − B = (1 − 4δ)·L/(4·(2m + 1)·δ).

4. Protocol R achieves failure ≤ δ for every member with n = ⌈L·K ln 2/((m + 1)δ)⌉ questions, where K = log(N₀ + 1) = log(L/(2(2m + 1)δ) + 1) with uniform weights.
With m = θL (so B = 1/(2θ + 1/L)): at least about (1 − 4δ)/(8θδ) questions are needed and K ln 2/(θδ) suffice, whatever L.

*Proof.* (1) The inputs of a block lie in one region, and every member is constant on a region, so the 2m + 1 human answers of a block are equal. The inputs of the scaffold do not depend on the answers. A rule with at most m replacements changes at most m answers of a block: a block whose human answers are all 1 keeps at least m + 1 ones, and a block whose human answers are all 0 gets at most m ones. So every block value, and the outcome, is that of the run of f. (2) Lemma 1.10(2) with B_i := {i} × [2m + 1], o₀ = 0, o_i = 1[i ∈ {R_1, …, R_B}], Δ_i = p(B, N₀) and M := B. (3) is the computation of Corollary 2.2(1) with B in place of L. (4) Proposition 5.2 with δ₀ = 0, by (1). ∎

The tolerance claim (1) was also checked by brute force for small cases (Section 8).

*What the redundancy is* (both reports). Every member is constant on a region, so the 2m + 1 calls of a block are one question put 2m + 1 times in different words, and a question anywhere in a region reveals the member on the whole region. For this class the problem is therefore exactly the needle problem with B calls. The redundancy protects against errors of the imitator and against nothing else: the human, being deterministic and stateless, gives the same answer every time. Nothing here says that a fault-tolerant human system achieves anything; the scaffold is an instrument for a lower bound.

### 5.3 The right pair of statements, and the gap

**Proposition 5.4.** Let Π be a scaffold and H a class of functions.
(a) *Lower bound by packing.* For f₀ ∈ H and Δ > 0 let N_Π(Δ) be the largest N such that H contains functions f_1, …, f_N that equal f₀ outside disjoint sets B_1, …, B_N and have Pr[out_{f_i} ≠ out_{f₀}] ≥ Δ. If Fail(f) ≤ δ for all f ∈ H, then n := E_{f₀}[N_Λ] ≥ N_Π(Δ)·(1 − 2δ/Δ) for every Δ; in particular n ≥ N_Π(4δ)/2.
(b) *Packing is limited by tolerance.* Suppose the scaffold is non-adaptive (its inputs do not depend on the answers) and f₀, f_1, …, f_N all tolerate m faults with failure 0, each for its own G_f. Then Pr[out_{f_i} ≠ out_{f₀}] ≤ E[number of calls with input in B_i]/(2m + 1), and therefore N·min_i Δ_i ≤ L/(2m + 1): N_Π(Δ) ≤ L/((2m + 1)Δ) when all members are required to tolerate m faults.
(c) *Consequence.* On non-adaptive scaffolds, for classes whose members all tolerate m faults with failure 0, no lower bound obtained from Lemma 1.10 exceeds L/(4(2m + 1)δ); Theorem 5.3 attains this up to the term −B.

*Proof.* (a) By Lemma 1.10(1), max{Fail(f₀), Fail(f_i)} ≥ (1 − π_i)Δ/2; averaging over i and using Σ_i π_i ≤ n, δ ≥ (Δ/2)(1 − n/N). (b) On (z, ρ) let v and v′ be the vectors of answers of f₀ and f_i along the common sequence of inputs; they differ only at calls with input in B_i. Suppose their Hamming distance d is at most 2m. Changing ⌊d/2⌋ of the differing coordinates of v into those of v′ gives a vector w at distance at most m from both. The rule that turns v into w, and the rule that turns v′ into w, each make at most m replacements (they may see (z, ρ)), so by tolerance the outcome of w equals out_{f₀} and equals out_{f_i}, almost surely. Hence, up to a null event, out_{f_i} ≠ out_{f₀} implies at least 2m + 1 calls in B_i, and Markov's inequality gives the bound on Δ_i. The B_i are disjoint and the input sequence is the same for all members, so the expected numbers of calls in the B_i sum to at most L. (c) In Lemma 1.10(2) the requirement (N − n)Δ/(N + M) ≤ δ gives n ≥ N − δ(N + M)/Δ ≤ N − δN/Δ, and with N·Δ ≤ L/(2m + 1) =: B′ this is at most N(1 − δN/B′) ≤ B′/(4δ). ∎

**The pair of statements.** For a function f in a class with weights:
* *Upper bound (Proposition 5.2):* n = L·K ln 2/β questions suffice for failure ≤ δ̄_Π(β).
* *Lower bound (Proposition 5.4(a), Lemma 1.10(2)):* failure ≤ δ for all members needs n ≥ N_Π(Δ)·(1 − 2δ/Δ) for every Δ, where N_Π counts disjoint patches in the class.

They match, up to the factor K and constants, when the class contains about L/β disjoint patches whose influence is a constant fraction of δ_Π(β). For human systems that tolerate m faults with failure 0 (deterministic human):

| | questions | for what |
|---|---|---|
| sufficient, random questions (R3; Proposition 5.2) | L·K ln 2/((m + 1)·δ) | every class and scaffold, every member whose human system tolerates m faults |
| sufficient, targeted questions (Proposition 3.8) | 1 + 2.7·K·L/((m + 1)·δ·log(L/((m + 1)δ))) | the same, under the hypotheses of Proposition 3.8(3) |
| necessary (Theorem 5.3) | (1 − 4δ)·L/(4·(2m + 1)·δ) | block-majority scaffold, region class |
| necessary (Proposition 5.6(b)) | (1 − 4δ)·(L − m)/(4·(m + 1)·δ) | sequential-majority scaffold, region class |
| the most the patch method can give (Propositions 5.4(b), 5.6(a)) | L/(4·(2m + 1)·δ) when the inputs do not depend on the answers; L/(4·(m + 1)·δ) for every scaffold | families whose members tolerate m faults |

What separates the sufficient from the necessary numbers. (i) The factor K ln 2. By Section 3 it is partly real (linear growth in K for fixed L/δ is forced when m = 0) and partly the price of random questions: with targeted questions a logarithm can be saved for every m (Proposition 3.8; the prover had listed this as open). For the region class, where K is about log(L/((m + 1)δ)), about 2.7·L/((m + 1)δ) questions suffice and (1 − 4δ)(L − m)/(4(m + 1)δ) are necessary on the sequential-majority scaffold, so the number of questions is known up to the constant factor 11·L/((L − m)(1 − 4δ)). (ii) The constant 4, as in Section 2. (iii) The factor (2m + 1)/(m + 1) < 2 between Theorem 5.3 and R3, which the prover listed as open, is settled by Proposition 5.6 (attack report): the block-majority scaffold pays 2m + 1 calls for each protected decision because it asks all copies before it looks at the answers; a scaffold that stops a block as soon as m + 1 answers agree pays m + 1, and no family that tolerates m faults allows the patch method more than L/(4(m + 1)δ). The factor that tolerance of m faults buys is therefore m + 1, in an example of a necessary number, as the limit of the method, and in the sufficient numbers. That tolerance never lowers the price by more than m + 1 for a given scaffold is not claimed: a tolerant scaffold with few possible inputs is cheap for the reason of Remark 2.4(3).

*A remark on Proposition 5.4(b)* (check report). It also holds for tolerance in the weaker sense of the candidate theory (rules that see only the history): let one rule replace, in the run of f₀, the answers at the 2nd, 4th, 6th, … call at which f₀ and f_i differ, and let the other replace, in the run of f_i, the answers at the 1st, 3rd, 5th, … such call, each stopping after m replacements. The input sequence is the same for both members and does not depend on the answers, so each rule can tell from the input whether the members differ there. When the two answer vectors differ in d ≤ 2m places both rules produce the same vector, with ⌊d/2⌋ and ⌈d/2⌉ replacements.

**Example 5.5 (the curve alone gives no lower bound).** Let Π make L calls at one input x₀, with out := max_j y_j, f₀ ≡ 0 and G = {out = 0}. The sampler C with C(1|x₀) = β/L has expected number of faults β and Q_C(not G) = 1 − (1 − β/L)^L ≥ β − β²/2, so δ_Π(β) ≥ β(1 − β/2) for β ≤ 1. But for every class of functions, one question at x₀ gives failure 0 for every member. So the second half of the candidate's "sharper form" of R3 ("for classes closed under patches about L/β questions are needed to get below δ_Π(β)") is false as stated: here the class of all functions is closed under patches, and one question suffices. Two things are missing in that statement. The supremum in δ_Π runs over stochastic samplers, which can spread β faults thinly over repeated visits to one input, and a function cannot. And a lower bound needs many disjoint places where a patch has influence, which is what N_Π(Δ) counts. The example also shows that the upper bound of Proposition 5.2 can be far from the truth: it bounds Protocol R by L·K ln 2/n here, while after the first rehearsal round with a question the mixture is exact at x₀.

The check report adds that the second half of the candidate's sentence fails without repetition too: a scaffold that can produce only N₀ different inputs is learned exactly with N₀ questions (Remark 2.4(3)), so the sentence fails for every scaffold with fewer than L/β possible inputs whenever δ_Π(β) exceeds the failure probability of the human system itself.

### 5.4 Scaffolds whose inputs depend on the answers: the factor is m + 1

**Proposition 5.6 (attack report, Proposition X1; re-derived by the editor).** Notation of Definition 5.1, tolerance with failure 0 for G_f.

(a) *Packing.* Let Π be any scaffold of horizon L, f₀ a function, B_1, …, B_N disjoint sets of inputs, and f_i functions with f_i = f₀ outside B_i whose human systems tolerate m faults with failure 0 (rules that see only the history suffice). Then, almost surely, out_{f_i} ≠ out_{f₀} implies that the run of f₀ has at least m + 1 calls with input in B_i. Hence Σ_i Pr[out_{f_i} ≠ out_{f₀}] ≤ L/(m + 1), and no lower bound obtained from Lemma 1.10 for such a family exceeds L/(4(m + 1)δ).

(b) *Attained.* Let m ≥ 0, B ≥ 1, N₀ ≥ 1, X := [N₀] × [2m + 1], Y := {0, 1}, and take the region class of Definition 5.2′ (f₀ ≡ 0, and f_i equal to 1 on region i and 0 elsewhere). The *sequential-majority scaffold* has z = (R_1, …, R_B) independent and uniform on [N₀] and no internal randomness. Block b asks the inputs (R_b, 1), (R_b, 2), … one after another and ends as soon as m + 1 of its answers are equal to the same element of {0, 1}; that element is the value of the block. The outcome is the largest block value. The horizon is L := B(m + 1) + m; a run that would need a further call, or a call beyond (R_b, 2m + 1), stops with the outcome 0. Then:
1. the human system of every member tolerates m faults with failure 0, and it makes exactly m + 1 calls in each block;
2. for every protocol and deployed system some member has failure at least (N₀ − n)·p(B, N₀)/(N₀ + B), with n the expected number of questions when the human is f₀;
3. if N₀ = B/(2δ) is an integer, failure at most δ for every member needs

  n ≥ B/(4δ) − B = (1 − 4δ)·(L − m)/(4·(m + 1)·δ).

*Proof.* (a) Let D_i be the set of inputs of B_i at which f_i and f₀ differ, and fix (z, ρ). Apply to the human system of f_i the rule "if the input of the call lies in D_i and fewer than m answers have been replaced, replace the answer by f₀'s". It replaces at most m answers and sees only the input of the call and its own count. If the run of f₀ has at most m calls with input in D_i, the run under this rule is the run of f₀, by induction over the calls: as long as the two runs agree, the rule has made at most as many replacements as the run of f₀ has had calls in D_i, so at every call the answer given is that of f₀. Its outcome is then out_{f₀}(z, ρ), and by the tolerance of f_i it is almost surely out_{f_i}(z, ρ). So out_{f_i} ≠ out_{f₀} implies, almost surely, at least m + 1 calls of the run of f₀ in D_i ⊆ B_i. With c_i the number of calls of the run of f₀ with input in B_i, Markov's inequality gives Pr[out_{f_i} ≠ out_{f₀}] ≤ E[c_i]/(m + 1), and Σ_i c_i ≤ L because the sets are disjoint. The last claim is the computation of Proposition 5.4(c) with B′ := L/(m + 1) in the place of L/(2m + 1): the bound that Lemma 1.10(2) gives is n ≥ N − δ(N + M)/min_i Δ_i, and this number is at most N − δN²/B′ ≤ B′/(4δ), because N·min_i Δ_i ≤ B′. (For unequal Δ_i the first inequality of Lemma 1.10(2) gives no more: a protocol may put its questions on the patches of largest influence, and the remaining ones have at most the average influence.)

(b) (1) Let the human be a member; it is constant on every region, with value v_b on the region of block b. Let a rule replace k_b answers in block b, with Σ_b k_b ≤ m. In block b every answer that is not replaced equals v_b, and at most k_b ≤ m answers differ from v_b; so the block cannot end with another value, and among its first m + 1 + k_b calls at least m + 1 answers equal v_b. The block therefore ends with the value v_b after at most m + 1 + k_b ≤ 2m + 1 calls, the run has at most B(m + 1) + m calls and is not cut off, and the outcome is the largest v_b, which is the outcome of the human system. With no replacement each block has exactly m + 1 calls. (2) Lemma 1.10(2), which holds for every scaffold, with B_i := {i} × [2m + 1], o₀ = 0, o_i = 1[i ∈ {R_1, …, R_B}], Δ_i = p(B, N₀) and M := B, exactly as in Theorem 5.3(2). (3) Corollary 2.2(1) with B in the place of L, and B = (L − m)/(m + 1). ∎

*Check.* Brute force over all replacement rules, with replaced answers in {0, 1, ⊥}, all members and all z, for ten triples (m, B, N₀) with m ≤ 3: tolerant to m faults in every case, never more than B(m + 1) + m calls, and m + 1 faults can change the outcome (`proofs/code/lower-bounds_attack_tolerance.out`). At equal horizon the sequential scaffold has about (2m + 1)/(m + 1) times as many protected decisions as the block-majority scaffold and needs that many times more questions:

| m | δ | L | block-majority (Theorem 5.3): blocks, questions | sequential majority: blocks, questions | ratio | R3 suffices with |
|---|---|---|---|---|---|---|
| 1 | 1/20 | 61 | 20, 84.7 | 30, 126.9 | 1.50 | 3 481 |
| 2 | 1/20 | 62 | 12, 50.9 | 20, 84.7 | 1.66 | 2 192 |
| 5 | 1/40 | 137 | 12, 111.1 | 22, 203.4 | 1.83 | 5 561 |
| 10 | 1/100 | 472 | 22, 533.6 | 42, 1 018.5 | 1.91 | 32 826 |
| 50 | 1/100 | 5 252 | 52, 1 261.0 | 102, 2 473.2 | 1.96 | 87 916 |

(Exact values of N₀ − δ(N₀ + B)/p(B, N₀) with N₀ = B/(2δ); the last column is L·K ln 2/((m + 1)δ) with K = log(N₀ + 1) for the sequential scaffold.)

### 5.5 The robustness curve for a human who is not deterministic

The prover's Section 10 said, without qualification, that the first half of the candidate's "sharper form" of R3 is correct. Proposition 5.2 proves it for a deterministic human. For a human who is not deterministic it is false as the candidate states it; the attack report found the counterexample and the correct form.

**Proposition 5.7 (attack report, Proposition X2 and finding M4; re-derived by the editor).** Let P ∈ H be any sampler, G a set of runs, δ_Π(β) the supremum of Q_C(not G) over samplers C with E_{Q_C} Σ_j TV(C(·|x_j), P(·|x_j)) ≤ β, and δ̄_Π its least concave majorant on [0, L]. After Protocol R with n rounds the run deployed with M^(T), T uniform on [n], satisfies

  Pr[deployed run ∉ G] ≤ δ̄_Π(min{L, L·√(K ln 2/(2n))}).

For a human who is not deterministic the argument cannot be replaced by L·K ln 2/n: there are a class of two samplers (K = 1), a scaffold with one call and a set G for which the failure exceeds δ̄_Π(K ln 2/n) by a factor that is unbounded in n.

*Proof.* Given T and the data, C := M^(T) is a sampler with β_T := E_{Q_C} Σ_j TV(C, P)(x_j) ≤ L, so Q_C(not G) ≤ δ_Π(β_T) ≤ δ̄_Π(β_T). A run has at most L calls, so by Pinsker's inequality and the Cauchy–Schwarz inequality Σ_j TV_j ≤ Σ_j √(KL_j/2) ≤ √(L·Σ_j KL_j/2), where KL_j := KL(P(·|x_j) ‖ C(·|x_j)). By Jensen's inequality and Theorem R1 of the note (E E_{Q_C} Σ_j KL_j ≤ L·K ln 2/n; proved in the part rehearsal-core, not here), E[β_T] ≤ L·√(K ln 2/(2n)). Since δ̄_Π is concave and nondecreasing, E δ̄_Π(β_T) ≤ δ̄_Π(E β_T).

*The counterexample.* One input, answers {0, 1}, the class {P₊, P₋} with P_±(1) = 1/2 ± θ and weights 1/2 (K = 1), the human P₋, the scaffold with one call (L = 1), and G = {the answer is 0}. Then δ_Π(β) = min{1, 1/2 − θ + β}, which is concave, and the candidate's sentence claims that the deployed answer is 1 with probability at most 1/2 − θ + ln 2/n. The mixture of round t answers 1 with probability 1/2 − θ + 2θ·w_t, where w_t is the posterior weight of P₊ after t − 1 answers. So the excess of the failure over that of the human system is 2θ·(1/n)·Σ_t E[w_t]. While n is below about 1/θ² the posterior has hardly moved and the excess is about θ, so the ratio to ln 2/n is about θ·n/ln 2; for θ of the order 1/√n it is of the order √n, hence unbounded. Exact values (`proofs/code/lower-bounds_attack_sharper.out`; the first three rows in exact rational arithmetic):

| θ | n | excess failure (exact) | ln 2/n (the candidate's sentence) | ratio | √(ln 2/(2n)) (this proposition) |
|---|---|---|---|---|---|
| 1/20 | 20 | 0.0457 | 0.0347 | 1.3 | 0.132 |
| 1/20 | 60 | 0.0389 | 0.0116 | 3.4 | 0.076 |
| 1/10 | 60 | 0.0451 | 0.0116 | 3.9 | 0.076 |
| 0.02 | 5000 | 0.00343 | 0.000139 | 25 | 0.0083 |
| 0.01 | 5000 | 0.00500 | 0.000139 | 36 | 0.0083 |

The bound of the proposition holds in every row. ∎

## 6. Stochastic humans

### 6.1 The criterion

For a stochastic human, let Q̂_{r,D} be the law of the deployed run given the seed and the transcript (for a deployed answerer: the law of the run of Π with it, over (z, ρ) and its own coins; an abstention is recorded in the run). The error of a protocol against P is

  Err(P) := E_P[ TV(Q̂_{r,D}, Q_P) ],

the expected distance between the run law of the *trained* imitator and the human system. This is the quantity bounded from above in the candidate's R2 and Theorem A.

**Remark 6.0 (why not the law averaged over the training).** The weaker criterion TV(E_P[Q̂_{r,D}], Q_P) admits no lower bound of the kind below: for a task with one call at a fixed input, the protocol "ask the human once and replay the answer" has averaged law exactly Q_P with one question. Replay cannot serve two runs, and its Q̂_{r,D} is a point mass. Err is the right criterion whenever the trained imitator is used more than once. (`understand/imitation-theory.md`, Section 5.8, discusses the two criteria.)

### 6.2 Per call

**Theorem 6.1.** Let K ≥ 1, X := [K], Y := {0, 1}, θ ∈ (0, 1/4], and for σ ∈ {−1, +1}^K let P_σ be the sampler with P_σ(1|i) := 1/2 + σ_i·θ. The class 𝒞_θ := {P_σ} has 2^K members, each of K bits under uniform weights. The task is one call at an input uniform on [K]. Let Λ be a protocol whose expected number of questions is at most n under every member, and let R_{r,D}(·|i) be the law on Y ∪ {⊥} of the deployed answer at input i. Then

  2^(−K)·Σ_σ E_σ[(1/K)·Σ_i TV(R_{r,D}(·|i), P_σ(·|i))] ≥ (θ/2)·(1 − θ·√(8n/K)).

Consequently:
1. for n ≥ K/2 and θ := √(K/(32n)), some member of 𝒞_θ has Err ≥ √(K/n)/(16√2) ≈ 0.044·√(K/n);
2. for ε′ ∈ (0, 1/16], if Err(P) ≤ ε′ for every member of 𝒞_{4ε′}, then n ≥ K/(512·ε′²).
For comparison, the candidate's R1 with L = 1 and Pinsker's inequality give E TV ≤ √(K ln 2/(2n)) ≈ 0.59·√(K/n) for every class. So the per-call total variation ε′ costs between K/(512ε′²) and K ln 2/(2ε′²) questions in the worst case over classes of K bits.

*Proof.* Write R(1|i) for R_{r,D}(1|i) and let σ̂_i := +1 if R(1|i) ≥ 1/2 and −1 otherwise; σ̂_i is a function of (r, D).

(i) TV(R(·|i), P_σ(·|i)) ≥ |R(1|i) − 1/2 − σ_iθ|, and if σ̂_i ≠ σ_i the right side is at least θ. Hence E_σ TV(R(·|i), P_σ(·|i)) ≥ θ·Pr_σ[σ̂_i ≠ σ_i].

(ii) Let σ^(i) be σ with coordinate i flipped, and 𝐏_σ the law of (r, D) under P_σ. The events {σ̂_i = σ_i} and {σ̂_i = σ^(i)_i} are complementary, so Pr_σ[σ̂_i ≠ σ_i] + Pr_{σ^(i)}[σ̂_i ≠ σ^(i)_i] ≥ 1 − TV(𝐏_σ, 𝐏_{σ^(i)}).

(iii) Given the seed, the likelihood ratio of a transcript under P_σ and P_{σ^(i)} is the product over the question steps of P_σ(y_t|x_t)/P_{σ^(i)}(y_t|x_t); the factors with x_t ≠ i are 1, and the logarithm of a factor with x_t = i is bounded by ln 3 and has conditional mean kl(θ) := KL(Bern(1/2 + θ) ‖ Bern(1/2 − θ)) given the past, for either sign of σ_i. The number of steps is finite on every path and E_σ[N_i] ≤ n < ∞, so (the increments being bounded) KL(𝐏_σ ‖ 𝐏_{σ^(i)}) = E_σ[N_i]·kl(θ), with N_i the number of questions at input i. Now kl(θ) = 2θ·ln((1 + 2θ)/(1 − 2θ)) ≤ 2θ·4θ/(1 − 2θ) ≤ 16θ² for θ ≤ 1/4 (using ln(1 + v) ≤ v with v = 4θ/(1 − 2θ)). By Pinsker's inequality TV(𝐏_σ, 𝐏_{σ^(i)}) ≤ √(KL/2) ≤ θ·√(8·E_σ[N_i]).

(iv) Average (ii) over σ uniform (each pair {σ, σ^(i)} is counted twice) and over i, and use the concavity of the square root and Σ_i E_σ[N_i] ≤ n:

  (1/K)·Σ_i 2^(−K)·Σ_σ Pr_σ[σ̂_i ≠ σ_i] ≥ (1/2)·(1 − θ·(1/K)·Σ_i 2^(−K)·Σ_σ √(8·E_σ[N_i])) ≥ (1/2)·(1 − θ·√(8n/K)).

With (i) this is the displayed bound. (1) For θ = √(K/(32n)) ≤ 1/4 the bound is θ/4. (2) With θ = 4ε′ ≤ 1/4 the bound 2ε′(1 − 4ε′√(8n/K)) ≤ ε′ gives √(8n/K) ≥ 1/(8ε′). ∎

### 6.3 Whole runs

**Lemma 6.2.** For L ≥ 1 and θ ∈ [0, 1/2] let τ_L(θ) := TV(Bern(1/2 + θ)^{⊗L}, Bern(1/2 − θ)^{⊗L}). Then τ_L(θ) ≥ θ·√L·(1 − 2Lθ²), and for odd L even τ_L(θ) ≥ θ·√(2L)·(1 − 2Lθ²).

*Proof.* Let L = 2j + 1 be odd and g(p) := Pr[Bin(L, p) ≥ j + 1]. Since Pr[Bin(L, p) ≥ k] is the probability that the k-th smallest of L independent uniform variables is at most p, g′(p) = L·C(2j, j)·(p(1 − p))^j. With p = 1/2 + t this is L·C(2j, j)·4^(−j)·(1 − 4t²)^j. For j ≥ 1, C(2j, j)·4^(−j) ≥ 1/(2√j): equality at j = 1, and the ratio of consecutive terms (2j + 1)/(2j + 2) is at least √(j/(j + 1)) because (2j + 1)² ≥ 4j(j + 1). If 1 − 2Lθ² < 0 there is nothing to prove; assume 1 − 2Lθ² ≥ 0. Then for j ≥ 1 and |t| ≤ θ, g′(1/2 + t) ≥ (L/(2√j))·(1 − 4jt²) ≥ √(L/2)·(1 − 2Lθ²), using (1 − 4t²)^j ≥ 1 − 4jt² ≥ 1 − 2Lθ² ≥ 0 and L/(2√j) = L/√(2(L − 1)) ≥ √(L/2). Therefore τ_L(θ) ≥ g(1/2 + θ) − g(1/2 − θ) ≥ 2θ·√(L/2)·(1 − 2Lθ²). For L = 1, τ_1 = 2θ. For even L ≥ 2 the first L − 1 coordinates give τ_L ≥ τ_{L−1} ≥ θ·√(2(L − 1))·(1 − 2(L − 1)θ²) ≥ θ·√L·(1 − 2Lθ²). ∎

**Theorem 6.3.** Let 𝒞_θ be the class of Theorem 6.1 and let the scaffold Π^rep_L have z = I uniform on [K] and L calls, all at the input I; the run records all answers. For every protocol whose expected number of questions is at most n under every member,

  2^(−K)·Σ_σ Err(P_σ) ≥ (τ_L(θ)/4)·(1 − θ·√(8n/K)),

and if θ·√(8n/K) ≤ 1 the right side is at least (θ·√L/4)·(1 − 2Lθ²)·(1 − θ·√(8n/K)). (The prover's display chained the two inequalities without the condition. Without it the second one can fail: when both brackets are negative the last expression is positive and is not a lower bound. Example of the check report, recomputed in the attack report: K = 1, θ = 1/4, L = 16, n = 8 gives 0.25 for the last expression, while the protocol that asks the one input eight times and deploys the more likely sign has Err = 0.068.)

Consequently:
1. for n ≥ max{K/2, L·K/8} and θ := √(K/(32n)), some member of 𝒞_θ has Err ≥ √(L·K/n)/(64√2) ≈ 0.011·√(L·K/n);
2. for ε ∈ (0, 1/64] and θ := 16ε/√L, if Err(P) ≤ ε for every member of 𝒞_θ, then n ≥ L·K/(8192·ε²).
The candidate's R2 gives Err ≤ √(c₀·L·K ln 2/n) for every class; the part hellinger-runs of this project proves it with c₀ = 4, that is Err ≤ 2·√(L·K ln 2/n) (according to the outline; not checked here). So whole-run total variation ε for a stochastic human costs between L·K/(8192·ε²) and 4·L·K ln 2/ε² questions in the worst case over classes of K bits: of order L·K/ε², with no logarithm to save, in contrast to Corollary 3.4.

*Proof.* Let R_i be the law, given (r, D), of the vector of deployed answers in a run with I = i, and B_± := Bern(1/2 ± θ). Both run laws have I uniform, so TV(Q̂_{r,D}, Q_{P_σ}) = (1/K)·Σ_i TV(R_i, B_{σ_i}^{⊗L}). Let σ̂_i := +1 if TV(R_i, B_+^{⊗L}) ≤ TV(R_i, B_−^{⊗L}) and −1 otherwise. If σ̂_i ≠ σ_i, the triangle inequality gives τ_L(θ) ≤ 2·TV(R_i, B_{σ_i}^{⊗L}). Hence E_σ TV(Q̂_{r,D}, Q_{P_σ}) ≥ (τ_L(θ)/2)·(1/K)·Σ_i Pr_σ[σ̂_i ≠ σ_i], and steps (ii)–(iv) of the proof of Theorem 6.1 bound the average of the last sum from below by (1/2)(1 − θ√(8n/K)). The second claim of the display is Lemma 6.2 multiplied by the factor 1 − θ√(8n/K), which is where that factor must be nonnegative. (1) θ ≤ 1/4 because n ≥ K/2; 2Lθ² = L·K/(16n) ≤ 1/2; 1 − θ√(8n/K) = 1/2; so the bound is θ√L/16. (2) θ ≤ 1/4 and 2Lθ² = 512ε² ≤ 1/2. If θ√(8n/K) > 1 then n > K/(8θ²) and the claim holds. Otherwise the bound is at least 2ε·(1 − θ√(8n/K)); if this is ≤ ε then θ√(8n/K) ≥ 1/2, that is n ≥ K/(32θ²) = L·K/(8192·ε²). ∎

Abstention is covered in both theorems: the deployed answer law may give mass to ⊥, and the inequalities used hold for laws on Y ∪ {⊥}. By Remark 6.0 the two theorems are statements about an imitator that is trained once and then used; for a single use, replaying one recorded answer is exact.

## 7. The conclusion as one theorem

**Theorem 7.1 (what imitation with a guarantee for every member of a class does and does not amplify).** Each part names the class and the scaffold for which it is proved; the human is deterministic throughout. Let L ≥ 1 and δ ∈ (0, 1/20] with L/(2δ) an integer.

(A) *One run, questions asked in advance.* There are a scaffold with L calls (the OR scaffold) and a class of L/(2δ) + 1 functions (the needle class), each of at most log(L/δ) bits, such that every protocol that asks its questions before the top-level input of the run is drawn, and whose deployed outcome is right with probability ≥ 1 − δ for every member, asks at least

  L/(4δ) − L

questions in expectation when the human is the zero function. The human does the same run with L answers and failure 0. So for this class and scaffold the imitator costs at least 1/(4δ) − 1 ≥ 4 times the human work it replaces, although the class is as simple as a class with L/(2δ) + 1 members can be.

(B) *With complexity.* For every m ≥ 1 there are a scaffold with L calls (the block scaffold) and a class of 2^K functions, K = m·log(L/(2δ)), of VC dimension m (the block class), for which the same requirement needs at least (1 − 10δ)·m·L/(8δ) = (1 − 10δ)·K·L/(8δ·log(L/(2δ))) questions in expectation over a uniformly chosen member. Since m is arbitrary, no number of questions that depends on L and δ alone suffices for all classes: in the worst case over classes the number grows linearly in the VC dimension, and as K·L/(δ·log(L/δ)) in bits, and no faster (Theorem 3.3, when L/δ ≥ 16).

(C) *One run, the human available during the run.* For the OR scaffold and the needle class with ⌈L/√(2δ)⌉ cells: even if the protocol sees z before it asks, it needs at least L·(1 − √(2δ) − δ) − δ answers in expectation when the human is the zero function. For this class a guarantee for every member therefore saves at most the fraction √(2δ) + δ + δ/L of the human's work on one run.

(D) *Many runs under one failure budget.* Let r ≥ 1 and ε ∈ (0, 1/20] with rL/(2ε) an integer. If r independent runs of the OR scaffold must all have the right outcome with probability ≥ 1 − ε for every member, then for the needle class 𝒩(rL/(2ε)) at least rL/(4ε) − rL questions are needed in advance, and for the needle class with ⌈rL/√(2ε)⌉ cells at least rL·(1 − √(2ε) − ε) − ε are needed even with the human available throughout. The human does the r runs with rL answers. So for every r there is a class, of about log(rL/ε) bits, for which nothing is gained. The class depends on r: for a fixed needle class with N₀ cells, N₀ questions identify the human and every later run is right, so no statement of this kind holds for one class and all r.

(E) *Many runs at a failure rate.* For every class of functions with weights, every member f with K = log(1/w(f)) and every scaffold with L calls, ⌈L·K ln 2/δ⌉ questions (Protocol R; Lemma 5.1′) or, when L/δ ≥ 16, 1 + 2.7·K·L/(δ·log(L/δ)) questions (Protocol AB; K used to choose the number of audits) give an imitator each of whose runs is unfaithful with probability at most δ, the probability being over the training and the run. The runs share one trained imitator and are not independent; what is claimed for r later runs is that the expected number of unfaithful runs is at most δr. The human would spend rL answers. The ratio of human answers replaced to human answers spent is therefore at least rL/(L·K ln 2/δ + 1), about r·δ/(K ln 2), and for the classes of (A) and (B) it is at most 4rδ/(1 − 4δ) and 8rδ·log(L/(2δ))/((1 − 10δ)·K). The ratio passes 1 after about K ln 2/δ runs of Protocol R, and by then the guarantee has allowed δ·(K ln 2/δ) = K ln 2 unfaithful runs in expectation (about 2.7·K/log(L/δ) for Protocol AB; at least (1 − 10δ)·K/(8·log(L/(2δ))) for any protocol on the block classes; 1/4 − δ on the needle classes).

(F) *Fault tolerance.* For the block-majority scaffold and the region class, whose human systems tolerate m faults, (A) becomes (1 − 4δ)·L/(4(2m + 1)δ) (Theorem 5.3); for the sequential-majority scaffold it becomes (1 − 4δ)·(L − m)/(4(m + 1)δ) (Proposition 5.6). For every human system that tolerates m faults with failure 0, L·K ln 2/((m + 1)δ) questions suffice (R3; Proposition 5.2), and so do 1 + 2.7·K·L/((m + 1)δ·log(L/((m + 1)δ))) under the hypotheses of Proposition 3.8(3). One run is then amplified by Protocol R once (m + 1)·δ > K ln 2, and, on the block-majority scaffold with the region class, by no protocol unless 4(2m + 1)δ > 1 − 4δ.

*Proof.* (A) Corollary 2.2(1); log(L/(2δ) + 1) ≤ log(L/δ). (B) Theorem 3.1; for any n choose m with (1 − 10δ)·m·L/(8δ) > n; the upper bound is Corollary 3.4(1). (C) Proposition 2.5. (D) The r runs of the OR scaffold with N₀ cells are one run of the OR scaffold with rL calls, cut into r pieces; if all r outcomes are right, so is their maximum, which is the outcome of the long run. A deployed system for the long run may see all rL inputs, so a system that answers the r runs one after another is covered. Apply Corollary 2.2(1) and Proposition 2.5 with rL and ε in place of L and δ. (E) By Lemma 5.1′ the expected number of calls at which the draw of M^(T) differs from f in a run is at most L·K ln 2/n, and a run without such a call is faithful; Theorem 3.3(3) for Protocol AB. The imitator is trained once; each later run uses a fresh (z, ρ), so each is unfaithful with probability at most δ. The upper limits on the ratio are (A) and (B). The numbers of allowed unfaithful runs at break-even are δ·n/L for the respective numbers n of questions. (F) Theorem 5.3, Proposition 5.6(b), Proposition 5.2 and Proposition 3.8(3). ∎

**In words** (rewritten; both reports found that the prover's paragraph said more than the theorem in three places). Questions do not buy runs; they buy coverage of the scaffold's input distribution. A protocol whose failure is at most δ for every member has asked, with probability at least 1 − 2δ/p, every place whose patch is in the class and changes the outcome with probability p (Lemma 1.10(1)). In the OR scaffold with L/(2δ) cells every cell is such a place, with p close to 2δ, and about half of the cells must be asked: nothing is gained over letting the human do the run. This concerns runs whose critical calls fall on many different places that the class can patch one by one. A run whose critical calls fall on few places is cheap (Example 5.5: L critical calls, one question), and so is a guarantee on average over a prior that favours the unpatched member (Remark 2.4(4)). The same holds per unit of failure probability, so for every number r of runs under one budget there is a class, growing with r, for which nothing is gained (D). What imitation buys is *reuse*: the same L·K ln 2/δ answers (less a logarithm with targeted questions) serve every later run at failure rate δ per run (E); the price is that K ln 2 unfaithful runs are allowed before the answers saved equal the answers spent. And it buys *tolerance*: if the human system survives m faults, the sufficient number of questions drops by the factor m + 1 (R3), and in the examples of Theorem 5.3 and Proposition 5.6 the necessary number drops by the factor 2m + 1, respectively m + 1 (F).

**Proposition 7.2 (the conclusion in terms of a failure budget; attack report, Proposition X5; re-derived by the editor).** Let a protocol ask its questions in advance and then answer r successive runs of a scaffold with fresh, independent top-level inputs; the deployed system may use its earlier runs. Its *failure budget* F is a bound, valid for every member of the class, on the expected number of runs among the r with a wrong or silent outcome. Its *amplification* is A := r·L/n: human answers replaced per answer spent. Let L, r ≥ 1 and F > 0, and put δ := F/r. The human is deterministic.

(a) *Simplest classes.* If δ ≤ 1/4 and N₀ := rL/(2F) = L/(2δ) is an integer, every protocol with failure budget F for the needle class with N₀ cells and the OR scaffold has n ≥ L/(4δ) − L in expectation when the human is the zero function. Hence A ≤ 4F/(1 − 4δ).

(b) *Classes of K bits.* If δ ≤ 1/20 and N := L/(2δ) is an integer, every protocol with failure budget F for the block class 𝒩^m(N) and the block scaffold has n ≥ (1 − 10δ)·m·L/(8δ) in expectation over a uniformly chosen member. Hence A ≤ 8F·log(L/(2δ))/((1 − 10δ)·K) with K = m·log(L/(2δ)).

(c) *Sufficiency.* For every class of functions with weights, every scaffold of horizon L and every member of K bits, Protocol R with n = ⌈L·K ln 2/δ⌉ rounds has failure budget F, so A ≥ F/(K ln 2 + δ/L); and, if L/δ ≥ 16, Protocol AB with the parameters of Theorem 3.3(3) for ε = δ has failure budget F with n ≤ 1 + 2.7·K·L/(δ·log(L/δ)), so A is at least about F·log(L/δ)/(2.7·K).

(d) *Tolerance.* If the human system tolerates m faults with failure 0, the sufficient numbers of (c) divide by m + 1 (Proposition 5.2; Proposition 3.8(3) under its hypotheses, with log(L/((m + 1)δ)) in the place of log(L/δ)); for the sequential-majority scaffold of Proposition 5.6 and the region class, A ≤ 4(m + 1)·F·L/((L − m)(1 − 4δ)).

*Proof.* (a) From the deployed system for r runs build one for a single run with top-level input z: draw k uniformly from [r], draw z_1, …, z_{k−1} independently from the law of the top-level input, let the given system answer the runs z_1, …, z_{k−1}, z in this order, and output its outcome for the last. This is a deployed system in the sense of Definition 1.3 (k and the z_i are part of its fresh randomness s). For every member its failure probability is the average over k of the failure probabilities of the k-th run, which is at most F/r = δ. Corollary 2.2(1) gives n ≥ L/(4δ) − L, and A = rL/n. (b) The same reduction and Theorem 3.1. (c) Lemma 5.1′ and Theorem 3.3(3) with ε = δ; each run is unfaithful with probability at most δ, so the expected number among r is at most rδ = F; and rL/(L·K ln 2/δ + 1) = F/(K ln 2 + δ/L). (d) Proposition 5.2 with δ₀ = 0, Proposition 3.8, and Proposition 5.6(b)(3). ∎

*Reading.* For a deterministic human and a guarantee that covers every member of the class, the number of human answers that imitation replaces per answer it costs is, in the worst case over classes of K bits, between F·log(L/δ)/(2.7·K) and 8F·log(L/(2δ))/((1 − 10δ)·K): of order (failure budget)·log(L/δ)/K. For the simplest classes it is at most 4F/(1 − 4δ). A budget below 1/4 − δ of a failed run buys no amplification (A < 1), for any number of runs; this is parts (A) and (D) of Theorem 7.1. The class depends on the per-run rate δ = F/r and on nothing else: for a fixed class and δ tending to 0 the number of questions stays bounded (by the number of cells), which is why "no amplification for any r" cannot be said of one class. Amplification by the factor A has to be paid for with a budget of about A·K/(8·log(L/(2δ))) failed runs on the block classes; this is part (E) with its price. Tolerance of m faults divides the sufficient number of questions by m + 1, so that in (c) the term K ln 2 becomes K ln 2/(m + 1). Part B of `proofs/code/lower-bounds_attack_budget.out` checks (a) exactly against the protocol of Proposition 2.3, whose amplification is 4F.

**Where the conclusion is empty.** From the bounds above (`proofs/code/lower-bounds_attack_budget.out`, part A), for L = 1000 and δ = 0.01:

| | questions n | n for K = 10⁹ | allowed failed runs at break-even, δ·n/L | for K = 10⁹ |
|---|---|---|---|---|
| Protocol R (sufficient) | L·K ln 2/δ | 6.9·10¹³ | K ln 2 | 6.9·10⁸ |
| Protocol AB (sufficient) | 1 + 2.7·K·L/(δ·log(L/δ)) | 1.6·10¹³ | about 2.7·K/log(L/δ) | 1.6·10⁸ |
| block class (necessary) | (1 − 10δ)·K·L/(8δ·log(L/(2δ))) | 7.2·10¹¹ | (1 − 10δ)·K/(8·log(L/(2δ))) | 7.2·10⁶ |
| needle class (necessary) | L/(4δ) − L | 24 000 | 1/4 − δ | 0.24 |

For a human of about 10⁹ bits under a generic prior the sufficient numbers are out of reach, and reuse begins to pay only after the guarantee has allowed hundreds of millions of failed runs. Part (E) and Proposition 7.2(c) are correct and, for such a K, empty unless failed runs by the million are acceptable; and (b) says that for some classes of that size this cannot be helped by any protocol. The counts are in answers: an answer that takes a year counts as one.

## 8. Numerical checks

All scripts are in `proofs/code/`, each with its saved output in the file `.out` of the same name. Each stops at the first failed assertion. The editor reran the ten scripts of the prover and the verifiers on 16 November 2026 (Python 3.13 with numpy 2.5.3 and scipy 1.18.1); every one ran without a failed assertion and reproduced its saved output (the outputs of the attack report's scripts end with the timing lines of their original run; the outputs of the prover's two scripts were saved at this rerun and agree with what Sections 8.1 and 8.2 quote). The eleventh script is the editor's own.

| script | by | what it does | time |
|---|---|---|---|
| `lower-bounds_lp.py` | prover | exact minimax values by linear programming for the needle class (N₀ ≤ 5), for Proposition 2.5 and for Theorem 4.1 (Section 8.1) | 30 s |
| `lower-bounds_sim.py` | prover | block class, Protocol AB on the block class, tolerance of the block-majority scaffold, Lemma 6.2, Theorem 6.1 (Section 8.2) | 3 s |
| `lower-bounds_needle_exact.py` | check report | exact minimax for an expected number of questions by a linear programme that uses the symmetry of the needle class (N₀ up to 200); Corollary 2.2, Proposition 2.3, Theorem N2 of the lead's draft, Theorem 3.1 per block | 2 s |
| `lower-bounds_constants.py` | check report | every chain of simplifications of this file in exact form on grids, and the counterexample to the prover's display of Theorem 6.3 | 2 s |
| `lower-bounds_ab_sim.py` | check report | Protocol AB implemented literally on 15 random instances (Theorem 3.3, Proposition 3.8); the rare-points class (Proposition 3.7); Protocol R on the block class by simulation; Proposition 3.9 | 18 s |
| `lower-bounds_attack_patch.py` | attack report | Lemma 1.10 on 24 000 random triples of scaffold, class and protocol, by exact computation; Lemma 1.5, Theorem 1.6(4), Corollary 1.7 on 3 000 instances | 5 s |
| `lower-bounds_attack_ab.py` | attack report | Theorem 3.3 evaluated exactly (the law of the whole execution of Protocol AB) in 6 300 cases for three choices of X₀, and the example for Theorem 3.3(5) | 30 s |
| `lower-bounds_attack_tolerance.py` | attack report | Proposition 5.6: brute force over all replacement rules for the sequential-majority and block-majority scaffolds; necessary numbers at equal horizon | 0.2 s |
| `lower-bounds_attack_sharper.py` | attack report | the counterexample of Proposition 5.7 | 15 s |
| `lower-bounds_attack_budget.py` | attack report | numbers for Theorem 7.1(E) and Proposition 7.2; Bayes failure without questions (Remark 2.4(4)); Protocol R on the block class, exactly | 8 s |
| `lower-bounds_editor_checks.py` | editor | Proposition 3.10 (exact failure of Protocol R on the block class at n = 4·m·N, seven cases); the counterexample of Proposition 5.7, computed independently of the attack report's script; arithmetic of the corrected statements | 13 s |

Sections 8.1 and 8.2 quote the output of the prover's two scripts.

**8.1 Exact minimax values by linear programming** (`lower-bounds_lp.py`). A randomised protocol for the needle class is a mixture of pairs (set S of cells asked while the answers are 0; outcome deployed after the all-zero transcript as a function of the set of visited cells). The linear programme minimises the largest failure probability over the class, so its value is the exact minimax v(n) over all protocols with at most n questions.

```
Theorem 2.1: lower bound (N0-n)p/(N0+L) <= minimax <= (N0-n)p/N0
 N0  L  n   lower      minimax(LP)  upper
  3  2  0   0.333333   0.416667     0.555556
  3  2  1   0.222222   0.222222     0.370370
  3  2  2   0.111111   0.138889     0.185185
  4  2  0   0.291667   0.437500     0.437500
  4  2  1   0.218750   0.262500     0.328125
  4  2  2   0.145833   0.156250     0.218750
  4  2  3   0.072917   0.087500     0.109375
  5  2  0   0.257143   0.360000     0.360000
  5  2  1   0.205714   0.288000     0.288000
  5  2  2   0.154286   0.180000     0.216000
  5  2  3   0.102857   0.112000     0.144000
  5  2  4   0.051429   0.060000     0.072000
  4  3  0   0.330357   0.390625     0.578125
  4  3  1   0.247768   0.309375     0.433594
  4  3  2   0.165179   0.192708     0.289062
  4  3  3   0.082589   0.115625     0.144531

Proposition 2.5: lower bound (N0*p-n)/(N0+L) <= minimax (questions during the run)
 N0  L  n   lower      minimax(LP)
  5  3  0   0.305000   0.406667
  5  3  1   0.180000   0.288000
  5  3  2   0.055000   0.096000
  5  3  3   0.000000   0.000000
  8  4  0   0.275879   0.413818
  8  4  1   0.192546   0.288818
  8  4  2   0.109212   0.164062
  8  4  3   0.025879   0.051270
  8  4  4   0.000000   0.000000

Theorem 4.1: best advantage eta over 1/2 with n questions and N shifts; claim eta = n/(2N)
  N  n   eta(LP)    n/(2N)
  4  1   0.125000   0.125000
  4  2   0.250000   0.250000
  5  1   0.100000   0.100000
  5  3   0.300000   0.300000
```

(The tables for Proposition 2.5 and Theorem 4.1 are excerpts; the script prints all rows, N ≤ 5 for Theorem 4.1, and asserts equality with n/(2N) in every row.) The lower bound of Theorem 2.1 is attained exactly at (N₀, L, n) = (3, 2, 1). For these small N₀ the upper bound of Proposition 2.3 is not attained in general, because guessing outcome 1 is sometimes better when p is large; the two bounds differ by the factor 1 + L/N₀, which tends to 1 in the regime N₀ = L/(2δ) of Corollary 2.2.

**8.2 Simulations and exact evaluations** (`lower-bounds_sim.py`).

```
(a) block class: lower bound of Theorem 3.1 vs. the all-or-nothing protocol
   m     N    L   rho  E[questions]  failure(protocol)  lower bound at that n
  16   200    5  0.50        804.0   0.012376           0.011077
  64  1000   10  0.25       8008.0   0.007466           0.007265
  64  1000   10  0.50      16016.0   0.004978           0.004773
  64  1000   10  0.75      24024.0   0.002489           0.002282
  64  1000   50  0.50      16016.0   0.024397           0.019493

(b) protocol AB on the block class with N = L/(2 eps) (scaffold: L uniform calls in one random block)
   m=16, N=128, L=4, eps=0.01562, K=112 bits, log2(L/eps)=8, gamma=0.0312, n_B=5735
      questions asked: mean 1045, max 1307; proved bound n_B + K ln2/gamma = 8219; 2.7 K L/(eps log2(L/eps)) = 9677
      failure of the deployed h: mean 0.00837; proved bound 0.01562 (<= eps)
      Theorem 3.1: failure <= eps for all members needs n >= 442; Protocol R's bound L K ln2/eps = 19874
   m=32, N=512, L=8, eps=0.00781, K=288 bits, log2(L/eps)=10, gamma=0.0098, n_B=44162
      questions asked: mean 8108, max 9311; proved bound n_B + K ln2/gamma = 64604; 2.7 K L/(eps log2(L/eps)) = 79626
      failure of the deployed h: mean 0.00453; proved bound 0.00781 (<= eps)
      Theorem 3.1: failure <= eps for all members needs n >= 3812; Protocol R's bound L K ln2/eps = 204417
   m=32, N=2048, L=16, eps=0.00391, K=352 bits, log2(L/eps)=12, gamma=0.0029, n_B=171336
      questions asked: mean 31661, max 36908; proved bound n_B + K ln2/gamma = 254617; 2.7 K L/(eps log2(L/eps)) = 324403
      failure of the deployed h: mean 0.00236; proved bound 0.00391 (<= eps)
      Theorem 3.1: failure <= eps for all members needs n >= 15812; Protocol R's bound L K ln2/eps = 999374

(c) block-majority scaffold: outcome unchanged by <= m replaced answers (brute force)
   m=1, blocks G=2, block size 3, regions N0=3: tolerant = True
   m=2, blocks G=1, block size 5, regions N0=3: tolerant = True
   m=1, blocks G=3, block size 3, regions N0=2: tolerant = True

(d) Lemma 6.2: min over a grid of TV / (t sqrt(L) (1 - 2 L t^2)); must be >= 1
   smallest ratio found: 1.4142

(e) Theorem 6.1: lower bound (t/2)(1 - t sqrt(8 q)) vs exact Bayes risk 2 t Pr[MAP sign wrong]
    q     t        lower bound   exact (equal allocation)
     1  0.17678   0.044194      0.114277
    16  0.04419   0.011049      0.032141
   256  0.01105   0.002762      0.007998
```

Notes. (a) is exact arithmetic, not simulation; rows are excerpts. In (b) a question whose answer is already known is not asked, so the simulated protocol asks fewer questions than the bound counts; "mean" and "max" are over 20 runs with a uniformly random member; the failure is the average over the n_B rehearsal steps of the exact failure probability of the function deployed at that step. In (b) the number of questions the simulated protocol used lies between the lower bound of Theorem 3.1 and the bound of Theorem 3.3, and is far below Protocol R's bound. In (c) the replaced answers range over {0, 1, ⊥} and all members, all z and all sets of at most m positions are enumerated; the script's letter G is the number B of blocks. In (d) the grid is L ∈ {1, …, 59, 101, 200, 401} and 199 values of t in (0, 1/√(2L)); the smallest ratio is √2, attained as t → 0 for L = 2 (for L = 1 the total variation is 2t and the ratio tends to 2; for L = 2 it is again 2t and the ratio to t·√2·(1 − 4t²) tends to √2; the prover wrote L = 1, both reports corrected it). So on the grid the bound with √(2L) holds for even L too; it is proved only for odd L. In (e) "exact" is the Bayes risk of the protocol that asks each of the K inputs q times, for the loss |R(1|i) − P_σ(1|i)|.

## 9. What remains open in this part

1. **Constants.** (i) For the needle class the minimax number of questions for failure δ is between L/(4δ) − L and ⌈L/(4δ)⌉ (Proposition 2.3). Whether some class with K = O(log(L/δ)) needs more than L/(4δ)·(1 + o(1)) is open. (ii) In Corollary 3.4 the constants are 1/8 below and 2.7 above (1 + ln 2 asymptotically).
2. **Protocol AB beyond its theorem.** A version for a human who is not deterministic (none is known). A computable version. Whether a protocol that asks only calls of its own rehearsal runs can save log(1/ε) and not only log L (Proposition 3.9 saves ln(L/ln L)). Whether the constant 0.1 of Proposition 3.7 can be brought to the ln 2 of R1 (the exact values are near 0.37). Settled since the prover's file: the fault-tolerant version (Proposition 3.8), and the question of K (Remark 5 on Theorem 3.3: K enters through the number of audits only; Proposition 3.9 needs no K at all).
3. **N5.** Settled since the prover's file: the factor (2m + 1)/(m + 1) (Proposition 5.6: the factor is m + 1 when the inputs may depend on the answers). Still open: Propositions 5.4(b) and 5.6(a) are for tolerance with failure 0; tolerance with failure δ₀ > 0 is not treated. The factor K under fault tolerance (a class of K bits, K arbitrary, whose members tolerate m faults and which needs of order K·L/((m + 1)δ) questions up to a logarithm) is not proved here; the outline assigns it to the part assumptions (label N8).
4. **A characterisation.** For a given class with weights and a given scaffold, the minimax number of questions lies between the packing bound of Proposition 5.4(a) and the bounds of Theorem 3.3 and Proposition 5.2. A combinatorial parameter that determines it up to constants (an analogue, for chosen single-call questions inside a scaffold, of the teaching-dimension parameters of query learning) is not known to the prover, the verifiers or the editor.
5. **Stochastic humans.** The constants in Theorems 6.1 and 6.3 (512 and 8192 against ln 2/2 and c₀ ln 2). Lower bounds for the averaged criterion of Remark 6.0 when the imitator is used for r runs. A stochastic class with critical calls for which both ε^(−2) and a needle-type factor appear together.
6. **N3.** Nothing is open. The prover asked whether 2^k disjoint decidable regions of prefix complexity at most k + c exist; they do not for all k, and the largest number is 2^(k − K(k) + O(1)) (the count after Corollary 4.2, which rests on the coding theorem, quoted from memory).
7. **N1 for samplers with full support.** Proposition 1.8(2) pays log N + 2 log log N bits for total variation 1 − 1/N; nobody looked for a matching lower bound on the complexity of such a patch.
8. **Lemma 6.2 for even L.** The bound θ·√(2L)·(1 − 2Lθ²) is proved for odd L and holds on the grid of Section 8.2(d) for even L; a proof for even L is missing. Nothing in this file uses it.

## 10. Remarks on other parts of the candidate theory

Found by the prover while working on this part and revised after the two reports; the other parts were not checked systematically here.

1. **N1, last sentence** is false for a class of probability kernels when P(·|x) has full support (Proposition 1.8(3)). It is correct for functions, and it is correct for every human who always answers if members of the class may give no answer (Proposition 1.8(4)).
2. **N2.** The factor (1 − o(1)) is (1 − ε/2); the consequence n ≥ L/(2ε) can be replaced by n ≥ (1 − ε)·L/ε (Corollary 2.2). "Protocol R needs 4LK ln 2/ε" is right for failure ε/4.
3. **N3** is false as stated for randomised protocols (Theorem 4.1(4)); "regions of complexity ≤ k + c" needs k + K(k) + c for prefix complexity.
4. **Section 0, item 2** ("optimal up to the factor K") and **Section 10, item 5** (budget): the minimax number of questions over classes of K bits is of order K·L/(ε·log(L/ε)) (Theorems 3.1 and 3.3); the worst case of Protocol R is of order K·L/ε (R1 from above, Proposition 3.7 from below). The two are separated on classes whose informative inputs are rare in runs, not on the block classes (the paragraph after Corollary 3.4). The prover's sentence "Protocol R is not optimal for functions (Corollary 3.4)" was unproved in the prover's file; with Proposition 3.7 it is proved.
5. **R3, "sharper form".** The upper half is correct for a deterministic human (Proposition 5.2). For a human who is not deterministic it is false as stated, and holds with L·√(K ln 2/(2n)) in the place of L·K ln 2/n (Proposition 5.7; the prover's unqualified "the upper half is correct" was wrong). The lower half is false as stated (Example 5.5).
6. **S2.** The mixture over all samplable laws is not samplable by a halting procedure (Proposition 4.4(c)). The constant c is unnecessary. **S1** should be stated for the top-level law (or it must say whose visit measure d′ is: the visit measure of the deployed imitator depends on the imitator).
7. **R5** says that every rule deploying a single hypothesis per run has, in some classes, runs with Ω(L) unfaithful calls with probability Ω(L/n). Theorem 3.3 deploys one function per run with probability at most L·K/(n_B·log(1/γ)) of any unfaithful call; this is consistent with R5 but shows that "single hypothesis" is not worse than the mixture for the probability of a fully faithful run. By Proposition 3.8 the same function has at most L·K/(n_B·log(1/γ)) unfaithful calls per run in expectation, so one deterministic function per run can match the per-call mixture for the number of unfaithful calls too. R5 can therefore hold only for rules that deploy a member of H drawn from the posterior; it should not say "every rule that deploys a single hypothesis per run" (check report; the prover's proposal to restate R5 for the number of unfaithful calls does not rescue it).
8. **`understand/imitation-theory.md`, Section 5.5** ("active selection helps on classes with few patches and not in the worst case"): the digest's sentence is close to right. On the block classes, which are hardest for every protocol, random questions are within a constant factor of optimal. Chosen questions save a factor of order log(L/ε) in the worst-case number over classes of functions with weights (Theorem 3.3 against Proposition 3.7), and a factor of order L/ε on classes whose informative inputs are rare in runs. The same digest's LB1–LB3 are lower bounds of the same family as Theorems 2.1, 3.1 and 6.3 (derived independently there; its LB2 is given as a sketch). The differences here: exact constants and tightness for N2, bounds in terms of the expected number of questions, deployed systems that see (z, ρ), a complete proof of the factor K with the matching upper bound, and the per-call stochastic bound with the factor K.

## 11. Literature used, and how

No result from the literature is used as a black box in a proof, except Pinsker's inequality (Theorems 6.1 and 6.3, Proposition 5.7) and the coding theorem (the count after Corollary 4.2). For each item it is said who read what: "prover" is the author of the first version of this file, "check" and "attack" are the two verification reports, "editor" is this revision (16 November 2026). Statements marked [memory] were not read in a source by anyone in this project. In all sessions only arxiv.org could be opened; journal and proceedings sites were refused by the network settings.

**Sources of the two attributions that the note makes** (both read in the source by the author of the attack report and again by the editor, in the arXiv texts named):

* **N. H. Bshouty,** "Exact Learning from an Honest Teacher That Answers Membership Queries", arXiv:1706.03935v1 (13 June 2017), Section 2.1, Lemma 3 with its proof. The lemma, which the survey attributes to its references [158, 208], that is Hegedűs (1995) and Moshkov (1983): "Let C be any class of Boolean functions. Then OPT_AD(C) ≤ (ETD(C)/log ETD(C))·log|C| + ETD(C) ≤ (2·ETD(C)/log ETD(C))·log|C| and OPT_AD(C) ≥ max(ETD(C), log|C|)", where OPT_AD is the least worst-case number of membership queries of an adaptive algorithm that identifies every member, and ETD the extended teaching dimension (the largest, over all functions h, of the least size of a set on which at most one member of C agrees with h). The proof given there is the algorithm: with C_i the members consistent with the answers so far and 0 < ε < 1/2, "the algorithm searches for an assignment a ∈ X such that ε|C_i| ≤ |{f ∈ C_i | f(a) = 0}| ≤ (1 − ε)|C_i|. If such a ∈ X exists, then it asks the membership queries MQ(a)"; "If no such a ∈ X exists, then the algorithm finds a specifying set T_h for h := Majority(C_i)" and asks it; if an answer differs from h, then |C_{i+1}| ≤ ε|C_i|; "ε is roughly log ETD(C)/ETD(C)". (The survey's symbol for the threshold is lost in the text extraction of the PDF; it is written ε here.) The survey continues: "Moshkov gives, for any two integers t and ℓ, an example of a class C_{t,ℓ} where OPT_AD(C_{t,ℓ}) = Ω((ETD(C_{t,ℓ})/log ETD(C_{t,ℓ}))·log|C_{t,ℓ}|). So the upper bound in the above lemma is the best possible." Used for Remark 1 on Theorem 3.3 and Remark 3.6. References as the survey gives them: T. Hegedüs, "Generalized teaching dimensions and the query complexity of learning", Proceedings of the Eighth Annual Conference on Computational Learning Theory (COLT), pp. 108–117, 1995; M. Y. Moshkov, "On conditional tests", Problemy Kibernetiki 40, pp. 131–170, 1983 (also Sov. Phys. Dokl. 27(7), pp. 528–530, 1982). Neither Hegedűs nor Moshkov was read by anyone in this project, and the survey does not describe the class C_{t,ℓ}.
* **S. Hanneke and L. Yang,** "Minimax Analysis of Active Learning", arXiv:1410.0996v1 (3 October 2014); the attack report gives the journal version as Journal of Machine Learning Research 16(109):3487–3602, 2015 (not verified by the editor). Definition 2: the star number s is the largest number of points x₁, …, x_s for which the class contains h₀, h₁, …, h_s such that h_i differs from h₀ at x_i and at no other x_j. Theorem 3: for ε ∈ (0, 1/9) and δ ∈ (0, 1/3), max{min{s, 1/ε}, d, Log(min{1/ε, |C|})} ≲ Λ_RE(ε, δ) ≲ min{s, d/ε, s·d/Log(s)}·Log(1/ε), with d the VC dimension and Λ_RE the minimax number of label requests in the realizable case. Proof of the term min{s, 1/ε} (Appendix B.1): "a lower bound proportional to s ∧ 1/ε may be credited to Dasgupta (2005, 2004). It can be proven as follows"; take the uniform law on x₁, …, x_t and the targets h₀, …, h_t, with t = s ∧ (1 − ε)/ε rounded down; "ĥ_i = ĥ₀ whenever x_i ∉ Q₀, since x_i ∉ Q₀ implies that all of the labels observed by the algorithm are identical to those that would be observed if f* = h₀ instead of f* = h_i"; conclusion Λ_RE(ε, δ) > t/2. This is the step of Lemma 1.10, and the needle class is a centre with N₀ one-point changes. Used for the attribution of the core of N2. The works of Dasgupta, as that paper lists them: S. Dasgupta, "Analysis of a greedy active learning strategy", Advances in Neural Information Processing Systems 17, 2004; S. Dasgupta, "Coarse sample complexity bounds for active learning", Advances in Neural Information Processing Systems 18, 2005. Neither was opened.
* **Related, from the project's own literature section** (`research/sections/related-work.md`, which read the source): Theorem G.1 of Foster, Block and Misra (2024, arXiv:2407.15007) uses one policy that never deviates and m policies that each deviate at one of m states, which is the needle class; fewer than c·m queried episodes leave an expected gap of c·H/m. Li and Zhang (2025, arXiv:2412.07057) call lower bounds for single-state queries open. Not read by the editor.

**Other items.**

* **Pinsker's inequality:** TV(P, Q) ≤ √(KL(P‖Q)/2), KL in nats. [memory; standard; for example A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Lemma 2.5.] Used in Theorems 6.1 and 6.3.
* **The two-point and hypercube method** (Le Cam; Assouad): B. Yu, "Assouad, Fano, and Le Cam", in *Festschrift for Lucien Le Cam*, Springer 1997, pp. 423–435 [memory]. The proofs of Theorems 6.1 and 6.3 are an instance of Assouad's method with adaptive sampling, written out in full; the divergence decomposition KL = E[N_i]·kl in step (iii) is the standard one for adaptively collected samples.
* **A. Ehrenfeucht, D. Haussler, M. Kearns and L. Valiant,** "A general lower bound on the number of examples needed for learning", *Information and Computation* 82(3):247–261, 1989. Statement as the prover gave it from memory: a class of VC dimension d ≥ 2 cannot be learned to error ε ≤ 1/8 with confidence 99% from fewer than (d − 1)/(32ε) random examples. The original was not read by anyone (its hosts could not be opened). Confirmed through a secondary source, read by the author of the attack report and by the editor: S. Hanneke, "The Optimal Sample Complexity of PAC Learning", arXiv:1507.00473 (Journal of Machine Learning Research 17(38):1–15, 2016, according to the arXiv record), Section 3: "A second lower bound of (d − 1)/(32ε) was supplied by Ehrenfeucht, Haussler, Kearns, and Valiant (1989), for 0 < ε ≤ 1/8 and 0 < δ ≤ 1/100" (the condition d ≥ 2 and the issue number are not in that restatement). Used only in Remark 3.6, for the order d/ε of the bound that does *not* apply to protocols that choose their questions, and that does apply to rehearsal with random questions (Proposition 3.7).
* **T. Hegedűs,** "Generalized teaching dimensions and the query complexity of learning", *Proceedings of COLT 1995*, pp. 108–117. Statement as the prover gave it from memory: a finite class C is identified exactly with a number of membership queries of order XTD(C)·log|C|/log XTD(C), where XTD is the extended teaching dimension. The paper was not read by anyone. The statement is confirmed through Bshouty (2017, Lemma 3; above) and through Hanneke and Yang (Appendix B.1: "Hegedüs (1995) proves that … if n ≥ 2·(XTD(C[U], U)/(1 ∨ log₂(XTD(C[U], U))))·log₂(|C[U]|), then the classifier ĥ_n returned by MEMB-HALVING-2 satisfies ĥ_n = h*"; read by both verifiers and by the editor). The prover cited it only as a precedent for the saved logarithm. That understated the debt: Protocol AB is that algorithm with audits of runs (Remark 1 on Theorem 3.3). The proof of Theorem 3.3 is self-contained all the same.
* **R. El-Yaniv and Y. Wiener,** "On the foundations of noise-free selective classification", Journal of Machine Learning Research 11:1605–1641, 2010, Theorem 7: a classifier that is never wrong may answer only where all consistent hypotheses agree. Not opened by anyone in this part; as restated in `research/sections/related-work.md` (which checked the restatement in Balsubramani, arXiv:1512.08133, Proposition 3.2). It is the known form of Corollary 1.7 and Remark 4.5 (attack report, Section 5).
* **Coding theorem** (used in the count after Corollary 4.2): every lower semicomputable semimeasure μ on the integers satisfies μ(j) ≤ 2^(−K(j) + c_μ). [memory, by the author of the check report: L. A. Levin, "Laws of information conservation (non-growth) and aspects of the foundation of probability theory", Problems of Information Transmission 10(3):206–210, 1974; M. Li and P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, Springer.]
* **Query learning, further.** That equivalence queries can be replaced by random examples, and that the N singletons need N − 1 membership queries: D. Angluin (1988) [memory, through the digest `understand/active-queries.md`]. That membership queries save at most a logarithm against counterexamples alone: W. Maass and G. Turán, "Lower bound methods and separation results for on-line learning models", Machine Learning 9:107–145, 1992 [from a search summary seen by the author of the attack report; not read]. None is used in a proof.
* **Majority organs.** The block-majority scaffold of Definition 5.2′ is the simplest instance of von Neumann's construction of reliable networks from unreliable components (J. von Neumann, 1956, as cited in `research/sections/related-work.md`, which did not open it either). Nothing of that work is used.
* **Counting of strings of small prefix complexity** (Remark after Corollary 4.2): the number of strings x with K(x) ≤ j is 2^(j − K(j) + O(1)). [memory: G. J. Chaitin, "A theory of program size formally identical to information theory", *Journal of the ACM* 22:329–340, 1975; M. Li and P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, Springer.] Used only in that remark.
* **No computable measure dominates all computable measures** [memory: standard, Li and Vitányi, the chapter on universal semimeasures]. Proposition 4.4(c) proves the version needed here directly.
* **Exact sampling from a computable discrete law with fair coins** [memory: D. Knuth and A. Yao, "The complexity of nonuniform random number generation", 1976]. Proposition 4.4(c) gives the elementary argument.
* **Lower bounds for imitation learning** (Foster, Block and Misra 2024; Rajaraman, Yang, Jiao and Ramchandran 2020): not read by the prover or the editor; quoted in `understand/imitation-theory.md`, Section 5.4, and, for Theorem G.1 of the first, in `research/sections/related-work.md` (see above). None of them is used in a proof here.
* **From the candidate theory and the other parts:** R1 for functions is re-proved as Lemma 5.1′ and is what Theorem 7.1(E), Propositions 5.2, 4.6 and 7.2(c) use. Proposition 5.7 uses Theorem R1 for a general human, which is proved in the part rehearsal-core and was not checked here beyond a reading of its proof in `note.md`. R2 for stochastic humans (the constant c₀) and R3 for stochastic humans are quoted for comparison only and were not checked here.
* **From the repository digest** (`understand/repo.md`): the definition of sep(x; A) (Section 1 there); the patch construction of Proposition 1.8 is that of items D1 and D5 there.

## 12. Checking

The prover's file was examined by two verifiers. The check report (`verification/lower-bounds-check.md`, cited as C) read every proof line by line, recomputed every constant and wrote three scripts. The attack report (`verification/lower-bounds-attack.md`, cited as A) looked for counterexamples by exact computation, for hidden assumptions, for prose that says more than the theorems, and for what is not new; it wrote five scripts and read three sources. The editor decided every finding after verifying it: by re-deriving the mathematics, by rerunning all ten scripts (Section 8), by an independent computation for the counterexample of Proposition 5.7, and, for the two attributions, by reading the sources (Section 11).

Result. No numbered theorem of the prover's file was false in the form in which the note uses it. One statement of a theorem was not well defined as written (Theorem 3.3: the set X₀), one display was false in part of its range (Theorem 6.3), one claim made in words had no proof (that Protocol R is not optimal), one verdict on the candidate theory was wrong for a human who is not deterministic (the first half of the "sharper form" of R3), and the concluding paragraph said more than its theorem. Two items listed as open were settled by the verifiers. No finding was rejected. Three were accepted in a changed form (rows 5, 9 and 31 of the table).

### 12.1 The findings of the two reports and what was done

| # | finding | report | decision | what was done |
|---|---|---|---|---|
| 1 | "Rehearsal with random questions is not optimal" is asserted and not proved; the block class does not separate the two protocols | C, correction 1; A, M2 | accepted | Proposition 3.7 added (the rare-points class; re-derived by the editor). Corollary 3.4(5) reworded. Paragraph "What the block class does not show" added after Corollary 3.4, and Proposition 3.10 (the editor's own: rehearsal needs at most 4·m·N rounds on the block class, for all parameters). Section 10, items 4 and 8; summary table |
| 2 | The conclusion says more than is proved: "one run of L critical calls", the probability 1 − δ/p, "no amplification for any r", "a factor between m + 1 and 2m + 1" | C, correction 2; A, M3(a), (b), (d) | accepted | Theorem 7.1: title and parts (A) to (F) reworded; "In words" rewritten on the basis of the check report's replacement text; the sentence after Proposition 2.5; Remark 2.4(3) |
| 3 | The conclusion does not say where it is empty: break-even only after K ln 2 allowed failed runs | A, M3(c) | accepted | Theorem 7.1(E) states the break-even numbers; paragraph "Where the conclusion is empty" with a table; Proposition 7.2 |
| 4 | Theorem 6.3: the second inequality of the display fails when 1 − θ√(8n/K) < 0 | C, correction 3; A, m2 | accepted (example recomputed) | Display split, with the condition θ√(8n/K) ≤ 1; the proof of consequence (2) treats the other case |
| 5 | Theorem 3.3: the set X₀ is not specified well enough for the vote h_t to be defined on its own runs; with X₀ the inputs of members' runs, claim (1) fails if b counts all disagreements | C, correction 4(a); A, m1 | accepted, in the form of A's Proposition X3, which contains the check report's fix as a special case | Theorem 3.3 restated (X₁ ⊆ X₀, h_t outside X₀, b counted at inputs of X₀), with new parts (4) and (5); proof rewritten; the example verified by hand |
| 6 | Theorem 3.3(3) gives n_B = 0 for K = 0 | C, correction 4(b); A, m1 | accepted | n_B := max{1, ⌈·⌉} |
| 7 | Theorem 3.3 must say what the human is asked, where A2 and A3 are used, what must be computed; deterministic humans only | C, correction 4(c); A, m6 | accepted | Sentence in the statement; Remarks 3, 6 and 7 |
| 8 | "K must be known" is no disadvantage against Protocol R | A, m1 | accepted | Remark 5; Corollary 3.4(1) |
| 9 | Protocol AB with fault tolerance is not open (Proposition A2) | C, correction 5 | accepted, with one added hypothesis: after row 5, faults at inputs outside X₀ are not counted by b, so the larger X₀ (or L·γ < 1) is assumed | Proposition 3.8; Sections 5.3, 9 and 10 (item 7); Theorem 7.1(F) |
| 10 | Section 9, item 6 (2^k regions of complexity k + c) is settled by the counting theorem | C, correction 5 | accepted (re-derived; it rests on the coding theorem, quoted from memory) | The count after Corollary 4.2; Section 9, item 6 |
| 11 | A variant in which every question is a call of the protocol's own rehearsal run (Remark A3); "needs a second check" | C, correction 5 | accepted (proof followed by A; re-derived by the editor) | Proposition 3.9 |
| 12 | The core of N2 is the star-number lower bound of active learning; the prover cited nothing | A, M1(a) | accepted after reading Hanneke and Yang, Theorem 3 and Appendix B.1, in the source | Note after Lemma 1.10; summary table; Section 11 |
| 13 | Protocol AB is the algorithm of Hegedűs and Moshkov; the prover called it new | A, M1(b); C, Section 2.1 | accepted after reading Bshouty, Lemma 3 with its proof, in the source | Remark 1 on Theorem 3.3; Remark 3.6; summary table; Section 11 |
| 14 | The sentence after N1 in the note is false for a human with full support at x | C, correction 6 | accepted | Proposition 1.8 (hypothesis Y = {0, 1}*); the section text |
| 15 | The verdict "refuted for samplers" depends on the convention: with programs that may give no answer the candidate's sentence holds for every human who always answers | A, m3 | accepted | Proposition 1.8(4) and the paragraph after its proof; Section 10, item 1 |
| 16 | State N2 in the note with the class N₀ = L/(2δ) and the constant 1/4; replace "16·K ln 2" | C, correction 7; A, Section 2.4 | accepted | The section text; the paragraph on the lead's draft after Corollary 2.2; exact values after Proposition 2.3 |
| 17 | Definition 1.1 fixes the number of steps; Protocol AB stops at a data-dependent time | C, correction 8; A, m9 | accepted | Definition 1.1 (a stopping rule); proof of Lemma 1.5; step (iii) of Theorem 6.1 |
| 18 | Remark 3.5: the exceptional range is unnecessary | C, correction 8 | accepted (2/(1 − 1/e) < 3.2 checked) | Remark 3.5 |
| 19 | Theorem 4.3 uses a refinement of Lemma 1.10 that the lemma does not state | C, correction 8 | accepted | Stated after the proof of Lemma 1.10 and in the proof of Theorem 4.3 |
| 20 | Proposition 5.2: the argument L·K ln 2/n can lie outside [0, L] | C, correction 8 | accepted | min{L, L·K ln 2/n} |
| 21 | Section 8, note to check (d): the smallest ratio is at L = 2, not L = 1 | C, correction 8; A, w5 | accepted (both limits computed) | Section 8.2, notes |
| 22 | The bound of Ehrenfeucht, Haussler, Kearns and Valiant is quoted from memory | C, correction 9 | accepted | Section 11: confirmed through Hanneke (2016), read by A and by the editor; the note cites only the order d/ε |
| 23 | Summary table: conditions of Theorem 3.3 missing; "new upper bound" | C, Section 1; A, w1 | accepted | Summary table rewritten |
| 24 | Section 10, item 7: a single function per run can match the mixture also in the number of unfaithful calls; R5 must not say "every rule that deploys a single hypothesis" | C, Section 1 | accepted | Section 10, item 7 |
| 25 | Theorem 7.1(A), (B): the numbers are expected numbers of questions | C, Section 2.3; A, w3 | accepted | Theorem 7.1(A), (B), (C) |
| 26 | Theorem 7.1: "for every member of a class" in the title; "for this scaffold" in (F) | A, w4 | accepted | Theorem 7.1 |
| 27 | Proposition 5.4(b) also holds for rules that see only the history | C, Section 1 | accepted (construction verified) | Remark at the end of Section 5.3 |
| 28 | "Unlimited ordinary compute is not enough" says too much; with growing time bounds an additive term suffices (Proposition X4); a fixed time bound dominates the laws sampled within it | A, m4; C, Section 1 | accepted (re-derived) | Proposition 4.6; the paragraph "What S2 should say" |
| 29 | The first half of the "sharper form" of R3 is false for a human who is not deterministic (Proposition X2 is the correct form) | A, M4 | accepted; the counterexample was recomputed by the editor with a separate programme (0.0457, 0.0389 and 0.0451 reproduced; the ratio grows like √n for θ = 1/(2√n)) | Proposition 5.7; Proposition 5.2 qualified; Section 10, item 5 |
| 30 | The gap (2m + 1)/(m + 1) is not open (Proposition X1) | A, m5 | accepted (re-derived; brute-force script rerun) | Proposition 5.6; Section 5.3; Section 9, item 3; Theorem 7.1(F) |
| 31 | N2 is about a guarantee for every member, not about a Bayes risk | A, m7 | accepted, with "depends on the reference machine" in place of "is a constant of the reference machine", which the argument given does not show | Remark 2.4(4); the section text |
| 32 | Order of events: N2 prices preparation for a task that is not yet known | A, m8 | accepted | Remark 2.4(1); the section text |
| 33 | "A disagreement of the mixture removes about one bit on average" is not what R1 uses | A, w2 | accepted | Remark 2 on Theorem 3.3 |
| 34 | Theorem 5.3: the 2m + 1 calls of a block are one question asked 2m + 1 times | A, w6; C, Section 1 | accepted | Paragraph after Theorem 5.3 |
| 35 | The conclusion as an inequality between amplification and failure budget (Proposition X5) | A, Section 3 | accepted (re-derived) | Proposition 7.2; the note states the conclusion in this form |
| 36 | The seven tests: Protocol AB is no guard against N1; a protocol without coins is defeated by one hypothesis; the stochastic bounds are for an imitator used more than once | A, Section 4 | accepted | Remark 9 on Theorem 3.3; Remark 1.11; the paragraph after Theorem 6.3 |
| 37 | What is not new (the table of A's Section 5) | A, Section 5 | accepted | Status column of the summary table; Section 11 |
| 38 | Theorem 1.6: membership in H is not used in the proof; x ∉ A is not needed in (4). Lemma 1.5 with semimeasures | C, Section 1 | accepted | Remarks after Lemma 1.5 and Theorem 1.6 |
| 39 | Corollary 3.4(4): the refutation is for classes all of whose members have the same K | C, Section 1 | accepted | Corollary 3.4(4) |
| 40 | The second half of the "sharper form" fails without repetition too | C, Section 2.2 | accepted | Sentence after Example 5.5 |
| 41 | Exact minimax values for the needle and block classes | C, Section 4.5 | accepted (script rerun) | Table after Proposition 2.3 |

### 12.2 Who checked the statements that the note uses

"Checked by C" means that the check report examined the proof and gave the verdict correct, or correct after a fix that has been applied. "Checked by A" means that the attack report followed the proof and could not break the statement. "Editor" means that the editor re-derived the proof for this revision. Every statement of this part that the note uses was checked by at least one verifier who is not its author, or re-derived by the editor; none is left "not independently checked".

| in the note | statement here | checked by |
|---|---|---|
| N1 | Lemma 1.5, Theorem 1.6 | C; A (also exact computation on 3 000 instances) |
| N1, abstention | Corollary 1.7, Remark 4.5 | C; A |
| N1, class of all programs | Proposition 1.8(1) to (3) | C; A |
| N1, class of all programs, members that give no answer | Proposition 1.8(4) | stated by A; not seen by C; editor |
| N2 | Lemma 1.10, Theorem 2.1, Corollary 2.2, Proposition 2.3 | C (with an independent linear programme); A (Lemma 1.10 by exact computation on 24 000 instances; the rest by hand) |
| N2, remarks on the Bayes risk and on the order of events | Remark 2.4(1), (4) | raised by A; arithmetic checked by the editor |
| N2a | Proposition 2.5 | C; A |
| N2b | Theorem 3.1, Proposition 3.2 | C (with an independent exact computation per block); A |
| N2c, Protocol AB | Theorem 3.3 in the corrected form | corrected form due to A (exact evaluation in 6 300 cases); C checked the proof for the larger X₀ (literal simulation); editor |
| N2c, rehearsal on the rare-points class | Proposition 3.7 | stated and proved by C; re-derived by A; editor |
| N2c, the variant with rehearsal questions only | Proposition 3.9 | stated and proved by C; proof followed by A; editor |
| N2c, the block class does not separate | paragraph after Corollary 3.4; Proposition 3.10 | simulation by C; exact computation by A; the formula of A's computation checked by the editor. Proposition 3.10 (the bound 4·m·N for all parameters) is the editor's own and was not seen by a verifier; it is checked numerically in `proofs/code/lower-bounds_editor_checks.out`, part A, and agrees with the numbers of C and A |
| N3 | Theorem 4.1, Corollary 4.2, Theorem 4.3 | C; A. The count 2^(k − K(k) + O(1)): proved by C; editor; rests on the coding theorem, from memory |
| what S2 needs | Proposition 4.4 | C; A |
| what S2 needs, ordinary compute | Proposition 4.6 | stated and proved by A; not seen by C; editor |
| N5 | Theorem 5.3, Proposition 5.4 | C; A |
| N5, the factor k + 1 | Proposition 5.6 | stated and proved by A (with a brute-force check); not seen by C; editor |
| N5, sufficient numbers | Proposition 5.2; Proposition 3.8 | Proposition 5.2: C; A. Proposition 3.8: stated and proved by C; proof followed by A; editor |
| remark to N5, the robustness curve | Example 5.5; Proposition 5.7 | Example 5.5: C; A. Proposition 5.7: stated and proved by A; not seen by C; editor (with an independent computation of the counterexample) |
| N6 | Theorems 6.1 and 6.3, Lemma 6.2 | C (constants recomputed, grids); A (by hand only) |
| N2d | Theorem 7.1; Proposition 7.2 | Theorem 7.1: C; A (parts follow from the results cited). Proposition 7.2: stated and proved by A; not seen by C; editor |

Results of other parts that the note's Section 4 quotes and that were not checked in this part: Theorem R1 (per-call closeness; for a deterministic human it is re-proved here as Lemma 5.1′, for a general human it is used in Proposition 5.7 as proved in the part rehearsal-core), Theorem R3 (low stakes; the deterministic case is Proposition 5.2), and the general form of R2 with the constant 2 (part hellinger-runs; quoted for comparison with Theorem 6.3).

### 12.3 The lead's draft of Section 4 (`note.md`)

Both reports checked the two theorems of the draft and found their proofs correct. The section text keeps the draft's structure and replaces: Theorem N1 by its total-variation form (Theorem 1.6(4)), which covers answer laws that overlap; the sentence on the class of all programs (rows 14 and 15); the attribution of the floor 2^(−sep) (the outline's Addendum 2, item 3); Theorem N2 by the form with N₀ = L/(2δ) cells and the constant 1/4 (row 16); "16·K ln 2" by 4·K ln 2; the bracketed sentence on the factor K by the results of Section 3; and the last paragraph ("read as a statement about work") by the conclusion of Section 7 with its quantifiers (rows 2 and 3).

