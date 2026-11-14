# Candidate theory, version 2 (working draft by the lead; to be attacked)

Status. Derived by the lead while the background digests were being written, after reading `understand/repo.md` and `understand/notes.md`. Nothing here has been checked by anyone else. Each statement carries a tag: **[P]** proof written out below or in a few lines, believed correct; **[S]** sketch, details to be supplied; **[?]** conjecture or plan. Version 1 contained one false claim, recorded in Section 12.

## 0. The shape of the answer

1. **Closed systems.** If everything the imitator will ever be asked is produced by a fixed computation (a scaffold, for example a task decomposition) that we can run in advance, then the training questions can be drawn from that computation's own inputs. There is then no distribution shift, and the Bayes mixture works whatever the prior contains. This is the researcher's suggestion "requery the human with some probability on the induced deployment distribution", made into a protocol (*rehearsal*) with theorems.
2. **What it costs.** With n single-call questions to the human, the imitator's calls differ from the human's at a rate of about K/n per call on its own deployment distribution (K = bits to specify the human in the class). A run of L calls is entirely faithful with probability 1 − O(LK/n). This is optimal up to the factor K: no protocol gets a faithful L-call run from fewer than about L/ε questions for every member of a class that is closed under patches. So sound imitation does not amplify human work on tasks in which every step is critical.
3. **Low stakes.** If the human system survives the arbitrary corruption of a fraction θ of its calls, about K/(θδ) questions suffice, whatever L. The right deployed object is then the per-call mixture, not one hypothesis per run.
4. **Outside the closed system** nothing can be guaranteed without the human or an assumption on the human: every unqueried input has two members of the class that differ there. Robustness to all shifts of description length k costs a factor 2^k, and this is necessary.
5. **Failing obviously.** Abstention trades silent errors against abstentions at an exponential rate; a rule that is never silently wrong for every member of the class abstains at every new input.
6. **The property idea.** Closeness in total variation of whole runs is the preservation of all properties at once, at price K(human). There is a different, assumption-free guarantee whose price is the complexity of the property: match the frequencies of all simple tests. The Bayes mixture does not give it in general; a minimum-distance imitator and an online "property inductor" do.

## 1. Setting

* X, Y countable sets of strings. A **sampler** is a probability kernel S(·|x) on Y (a semimeasure is completed by an outcome ⊥).
* **A1 (stateless human).** The human is a sampler P; each question x is answered by an independent draw from P(·|x).
* **A2 (class).** H is a countable class of samplers with weights w(ν) > 0, Σ w ≤ 1, and P ∈ H. K := log₂(1/w(P)). For the class of all lsc samplers with w = 2^(−K(ν)) this is K(P).
* **A3 (fresh coins).** The protocol's own random choices (which run, which call is put to the human) are independent of the human's coins and are not computable by any hypothesis. (Physical randomness. Without A3 a hypothesis that models the data collection could tell asked from unasked inputs.)
* Posterior after data D: w_D(ν) ∝ w(ν)·Π ν(y_i|x_i). **Mixture** M_D(y|x) = Σ_ν w_D(ν) ν(y|x).
* A **scaffold** Π of horizon L: a top-level input z ~ D₀, internal randomness ρ, and maps next_j(z, ρ, y_1..y_{j−1}) ∈ X ∪ {STOP} for j ≤ L, and an outcome out(z, ρ, y_1..y_T). An **answerer** A gives the law of y_j given the history; a sampler is an answerer that looks only at x_j. Q_A is the law of the run τ = (z, ρ, x_1, y_1, …, x_T, y_T). The **human system** is Q_P.
* The **visit measure** of A: d_A(x) = E_{Q_A} #{j : x_j = x} (total mass ≤ L).
* A **closed system** is a scaffold whose z and ρ we can sample ourselves. Deployment means: run Π with the imitator.

## 2. Lemmas

**L1 (chain rule) [P].** For samplers S, S′: KL(Q_S ‖ Q_S′) = E_{Q_S} Σ_j KL(S(·|x_j) ‖ S′(·|x_j)).

**L2 (coupling) [P].** For answerers A, B there is a joint construction of a run of A in which, at each call, the answer y_j ~ A and a shadow answer y′_j ~ B(·|history) are drawn from a maximal coupling. Call j is **unfaithful** if y_j ≠ y′_j. Then E[number of unfaithful calls] = E_{Q_A} Σ_j TV(A, B)(history_j), and TV(Q_A, Q_B) ≤ that expectation. So the run of A is a run of B in which the unfaithful calls have been replaced.

**L3 (Bayes regret on any adaptive questions) [P].** Let x_1, x_2, … be chosen as any function of the earlier pairs and of randomness independent of the human's coins, and y_t ~ P(·|x_t). Then Σ_t E KL(P(·|x_t) ‖ M_{D_{t−1}}(·|x_t)) ≤ ln(1/w(P)) = K ln 2. If P is a function f, then with e_t := 1 − M_{D_{t−1}}(f(x_t)|x_t): Π_t (1 − e_t) ≥ w(f) on every path, so Σ_t e_t ≤ K ln 2. (This is the record's A6(b), A7, C2.)

**L4 (Hellinger subadditivity) [S].** With H² := 1 − Σ√(pq): for samplers S, S′, H²(Q_S, Q_S′) ≤ c₀·E_{Q_S} Σ_j H²(S, S′)(x_j) for an absolute constant c₀ (7 in the convention of Foster, Kakade, Qian and Rakhlin; to be checked, or replaced by a self-contained proof: stop the run when the predictable sum of H² first exceeds 1/4, use E_Q g ≤ (5/3) E_P g + (16/3) R·H²(P,Q) for 0 ≤ g ≤ R). Consequence: TV(Q_S, Q_S′) ≤ √(2c₀·E_{Q_S} Σ_j H²_j), and H² ≤ KL/2.

## 3. The rehearsal protocol

**Protocol R (rehearsal with one question per run).** For t = 1, …, n:
1. freeze the mixture M^(t) := M_{D_{t−1}};
2. run Π to the end with M^(t) answering every call (a fresh draw at each call); this uses compute only;
3. draw J uniformly from {1..L}; if the run made at least J calls, put x_J to the human, receive y ~ P(·|x_J), and add (x_J, y) to the data.

Deployment: draw T uniformly from {1..n} and run Π with M^(T) (per run, or once for good).

**Theorem R1 (per-call closeness on the imitator's own inputs) [P].**
(1/n) Σ_t E E_{Q_{M^(t)}} Σ_j KL(P ‖ M^(t))(x_j) ≤ L·K ln 2 / n. Equivalently the deployed imitator M^(T) satisfies E Σ_j KL(P‖M^(T))(x_j) ≤ LK ln 2/n along its own run. For a function f: E[number of calls of the deployed run at which the mixture's draw differs from f] ≤ LK ln 2/n.
*Proof.* The asked input is a function of the past data and fresh randomness, so L3 applies to the sequence of asked inputs: Σ_t E[1{J_t ≤ T_t}·KL(P‖M^(t))(x_{t,J_t})] ≤ K ln 2, and the summand has conditional mean (1/L)·E_{Q_{M^(t)}} Σ_j KL_j. ∎
The statement holds for every class and every prior: hypotheses that model the world, the data collection or the reader are samplers like any other.

**Theorem R2 (whole runs) [P for functions, S in general].** For a function f, the deployed run coincides with the human system's run on the same (z, ρ) with probability ≥ 1 − LK ln 2/n. In general, with L4 and H² ≤ KL/2: E TV(Q_{M^(T)}, Q_P) ≤ √(c₀·L·K ln 2/n).

**Theorem R3 (low stakes) [P].** Let G be a set of good runs. Say the human system **tolerates m faults** with failure δ if for every rule that, at each call, sees the history and the human's answer and may replace it, and that replaces at most m answers, the run is in G with probability ≥ 1 − δ. Then the deployed run is in G with probability ≥ 1 − δ − β/(m+1), where β is the expected number of unfaithful calls: β ≤ LK ln 2/n for a function, β ≤ L√(K ln 2/(2n)) in general. With m = θL: failure ≤ δ + K ln 2/(θn) for a function, independent of L.
*Proof.* By L2 the deployed run is a run of the human system with replacements at the unfaithful calls. Truncate the replacement rule after m replacements; the truncated rule is admissible, and the two runs agree unless more than m calls are unfaithful, which has probability ≤ β/(m+1). ∎
Sharper form [?]: define the robustness curve δ_Π(β) := sup over samplers C with E_{Q_C} Σ_j TV(C,P)(x_j) ≤ β of Q_C(not G). Then failure ≤ (concave majorant of δ_Π)(LK ln 2/n), and for classes closed under patches about L/β questions are needed to get below δ_Π(β): the number of questions a scaffold needs is the inverse of its fault tolerance, up to the factor K.

**Theorem R4 (one hypothesis per run; functions) [P].** Variant R′: in round t draw one g ~ w_{D_{t−1}} and let it answer the whole run; ask the human one uniformly chosen call. Then Σ_t Pr[the run of round t differs from the human system's run] ≤ 2L·K ln 2.
*Proof.* Let j*(h) be the first index on the f-run at which h differs from f (∞ if none); the h-run agrees with the f-run on inputs up to index j*(h). For independent g, g′ ~ w_t, on the event {j*(g′) ≤ j*(g), j*(g′) < ∞, J = j*(g′)} the asked input is x^f_J and g′ is wrong there. By symmetry this event has probability ≥ u_t/(2L), u_t the probability that the g-run is unfaithful. So the expected posterior mass removed in round t is ≥ u_t/(2L), and the total of −ln(1 − removed mass) is ≤ ln(1/w(f)). ∎

**Proposition R5 (a committee per call beats one mind per run when stakes are low) [S].** There are classes in which, after n questions, the per-call mixture has O(K/n) unfaithful calls per call made while every rule that deploys a single hypothesis per run has runs with Ω(L) unfaithful calls with probability Ω(L/n) (a hypothesis that deviates at a rare input and then stays in a region only it visits). So for a scaffold that tolerates θL faults the single hypothesis needs about L/δ questions and the mixture K/(θδ).

**Proposition R6 (selection: sample or mixture, not MAP, inside the loop) [S].** If the rehearsal runs are driven by the current simplest consistent hypothesis, each simpler wrong hypothesis is refuted only on its own runs and costs up to L unfaithful rounds: up to L·2^K in total. If the runs are driven by the mixture and a single consistent program is selected only at the end, a martingale Occam bound gives it error ≤ (K ln 2 + ln(1/δ))/n on the mixture-driven visit distribution, hence an unfaithful own run with probability O(L(K + ln(1/δ))/n).

**Remarks.** (i) One question per rehearsal run is what the proof uses; more questions per run are harmless extra data. (ii) The human only ever answers single calls: short tasks. No run of the human system is needed. (iii) "Random round" cannot be replaced by "last round" in general (learning curves are not monotone).

## 4. Variants that need runs of the human system (small scaffolds only)

The researcher's notes say that one human episode may have to last a year, so runs of the human system are affordable only for scaffolds of a few calls. For those:

**Theorem A (posterior draw per run) [P].** Record N independent runs of the human system. To imitate: draw t uniformly from {1..N}, draw ν from the posterior given the first t − 1 runs, let ν answer every call. The law Q̂ of an imitation run satisfies E KL(Q_P ‖ Q̂) ≤ K ln 2/N and E TV(Q̂, Q_P) ≤ √(K ln 2/(2N)). (Bayes over whole runs, convexity, Pinsker. No factor L in the number of runs; N·L questions in total.)

**Theorem B (one fixed program) [S].** With weights 2^(−2ℓ(ν)) (ℓ prefix-free lengths): E[posterior mass of {ν : H²(Q_ν, Q_P) ≥ ε²}] ≤ 2^(ℓ(P))·exp(−Nε²). (E√(likelihood ratio) = (1 − H²)^N; min(1, a) ≤ √a.) So one posterior draw, used for good, is ε-close in Hellinger with probability ≥ 1 − δ once N ≥ (ℓ(P) ln 2 + ln(1/δ))/ε². For weights 2^(−λℓ), λ > 1, the exponent is 2·min(1/λ, 1 − 1/λ)·Nε². At λ = 1 the argument fails (the record's finding that explicit rates need λ > 1).

## 5. Lower bounds

**N1 (no coverage, no guarantee) [P].** Let a protocol's questions lie in a set A and let x ∉ A. If the class contains P and a sampler P_x that equals P on A and has P_x(·|x) ⟂ P(·|x), the protocol's behaviour at x has the same law under both, so for one of them it is wrong or silent at x with probability ≥ 1/2. In the universal class P_x exists with K(P_x) ≤ K(P) + sep(x; A) + c.

**N2 (critical steps are not amplified) [P].** For every L and ε ≤ 1/2 there are a scaffold (L calls on independent uniform inputs, outcome = OR of the answers) and a class of N₀ + 1 functions, N₀ = L/ε, each of complexity ≤ log N₀ + c (the zero function and the indicators of N₀ disjoint cells of mass 1/N₀), such that every protocol with n questions, adaptive or not, with any deployed answerer, fails (wrong or silent outcome) with probability ≥ (ε/2)(1 − nε/L)(1 − o(1)) for some member. So failure ≤ ε/4 for all members needs n ≥ L/(2ε) (up to the o(1)), although K ≤ log(L/ε) + c. Protocol R needs 4LK ln 2/ε.
*Proof idea.* If all answers so far are 0, at least N₀ − n cells are untested; the deployed system behaves the same under the zero function and under the indicator of an untested cell; average over the prior that puts 1/2 on zero and 1/2 uniformly on the cells.

**N3 (simple shifts cost 2^k) [P].** For 2^k disjoint decidable regions Q_i of complexity ≤ k + c and the class {zero function, indicators of Q_i}: being right with probability > 1/2 under each of the 2^k deployment laws "uniform on Q_i" for every member needs a question in each Q_i.

**N4 (never silently wrong is exponential) [record, C3(2) and X2].** On the point functions of {0,1}^d a rule that is never wrong must ask at every new input: 2^d − 1 questions at complexity d + O(log d).

**N5 (fault tolerance is necessary and sufficient) [S].** Variant of N2 with outcome 1[at least m + 1 answers equal 1]: about L/((m+1)ε^{1/(m+1)})… to be worked out; the aim is a lower bound matching R3 up to K and constants.

## 6. Shift outside the closed system

**S1 (density ratio) [P].** If the deployment visit measure satisfies d′ ≤ B·d̄ for the average rehearsal visit measure d̄, every per-call bound above holds under d′ with a factor B.
**S2 (all simple shifts at once) [S].** If the top-level inputs of rehearsal are drawn from Σ_i 2^(−K(i)) D_i over all samplable task laws, every D_i has B ≤ 2^(K(i)+c). By N3 the factor cannot be improved in general.
**S3 (open tasks).** A scaffold run on tasks from outside is a closed system only for the task law used in rehearsal. A property of tasks with rehearsal probability β costs 1/β.

## 7. Abstention

**Ab1 (threshold rule, functions) [P].** Rule: answer y if M(y|x) ≥ 1 − η, else abstain. On any sequence of questions put to the human: at most K/log₂(1/η) are ones where the rule would have answered wrongly, and at most K ln 2/η are ones where it would have abstained. Under Protocol R (driver = this rule, halting at the first abstention): per run, E[silent errors] ≤ LK/(n log₂(1/η)) and Pr[abstain] ≤ LK ln 2/(nη). Reducing silent errors by a factor j costs a factor about 2^j in questions, in line with N4.
**Ab2 (pessimism and dominance) [P].** For a set C of hypotheses containing P, S_C(y|x) := min_{ν∈C} ν(y|x), abstaining with the rest, satisfies S_C(·|x) ≤ P(·|x) at every x, so for every scaffold and every event B: Pr[B and no abstention] ≤ Q_P(B). With C = {posterior weight ≥ α·max}, P ∈ C at all times with probability ≥ 1 − α/w(P) (Ville). For α ≤ δ·w(P) every patch of the leading hypotheses of complexity up to K + log(1/δ) is in C: the rule abstains at every input that a test of that complexity separates from the asked inputs. This is the "rock" the researcher rejects; with moderate α it is a whitelist, sound only under the assumption that P is within log(1/α) bits of the best explanation of the data.
**Ab3 (novelty rule) [digest of the notes, Observation B].** Ask (or abstain) iff sep(x; A) < s: at most 2^s − 1 asks ever; never wrong for functions once s > 2K + c.

## 8. The property idea

**Pr1 (all properties at once) [P].** TV(Q̂, Q_P) ≤ ε says every property of runs has probability within ε of its probability in the human system. Theorems A and R2 give this at price K.

**Pr2 (the Bayes mixture does not preserve simple properties at the rate of their own complexity) [S].** Hindsight bound (digest): on data that abide by a decidable property R, E_posterior[1/(probability the hypothesis gave to abiding so far)] ≤ 2^(K(R)+c). But the *predictive* probability of violating R at the next on-distribution input is not bounded in terms of K(R): in a class with weights where memorisers ("table of the data, a fixed bad output elsewhere") outweigh the human while n·(bits per pair) < K, the mixture violates "y ≠ bad" with probability near 1 at fresh inputs for all such n. To be made exact.

**Pr3 (test matching in batch; assumption-free) [S].** Let 𝓣 be a countable family of events of runs with weights π. From N independent runs of the human system (any process, stateful or not, computable or not): with probability ≥ 1 − δ, every R ∈ 𝓣 has |Q̂_N(R) − Q_P(R)| ≤ tol_N(R) := √(ln(2/(π(R)δ))/(2N)), and Q_P(R) ≤ ln(1/(π(R)δ))/N if R never occurred. Any imitator whose run law matches the empirical frequencies within tol_N is within 2·tol_N(R) of the human system on every R: the price of a property is its own complexity.

**Pr4 (simplest test-matched sampler) [S].** Add to 𝓣 the sets {Q_ν > Q_ν′} for pairs of hypotheses, with weight w(ν)w(ν′). Then the highest-weight sampler that matches all tests has TV(Q_{P′}, Q_P) ≤ √((4K ln 2 + 2 ln(2/δ))/N) when P ∈ H, and (to be proved, after Yatracos and Devroye–Lugosi) an oracle inequality TV(Q_{P′}, Q_P) ≤ 3·TV(Q_ν, Q_P) + C√((K(ν) + ln(1/δ))/N) for every ν ∈ H when P is not in H. One learner, no prior belief needed, both regimes; and robust when the human is not a stateless sampler.

**Pr5 (an online property inductor on the imitator's own inputs) [?].** Per-call tests B ⊆ X × Y with weights π. Keep S_t(B) = Σ_{s<t} (1[imitator's answer at x_s in B] − 1[human's answer in B]) over the asked inputs and answer x with a y minimising Σ_B π(B)·sinh(η S_t(B))·1[(x,y) ∈ B] ("produce what the human has produced more often than I have"). Aim: for every sequence of asked inputs, |S_n(B)| ≤ O(√(n·ln(1/π(B)))) for all B simultaneously (Blackwell approachability; calibration with checking rules), hence under rehearsal: for every simple B, the deployed imitator emits B-answers on its own inputs at most as often as the human would on those inputs, plus O(√(K(B)/n)). No assumption on the human. To be proved or corrected; fast rate O(K(B)/n) for properties the human never violates?

## 9. Copy or predictor

Behaviour on the closed system is all the data can fix (record, F5, F8). Within it: R4 and R6 give a single coherent program; R5 says the robust object under low stakes is the committee. With private coins and a steeper prior the selected program is a shortest program for the kernel on the rehearsal law (record, E5), not the sampler with coins filled in.

## 10. The researcher's seven tests (from the digest of his notes)

1. *Guard.* In a closed system no property separates deployment inputs from asked inputs in distribution: a guard on a property of per-call frequency ρ survives n questions with probability (1 − ρ)^n. Depth of the tree is not a guard, since rehearsal runs are full-depth.
2. *Machine.* The machine enters R1–R4 only through K.
3. *Referent.* Under A3 a hypothesis about how the data were made cannot tell an asked call from an unasked one.
4. *Copy.* Section 9.
5. *Budget.* n = K ln 2/(θδ) single calls under low stakes, LK ln 2/δ without; lower bound N2.
6. *Rock.* No abstention is needed inside the closed system; Section 7 prices it.
7. *Horizon.* Outside a theorem about the learner; R3 adds a design requirement (fault tolerance).

## 11. Not covered, or open

Stateful humans (episodes); K for a person; stochastic versions of R4–R6 and Ab1; whether Pr5 holds; a matching lower bound N5; computable versions; which scaffolds tolerate faults.

## 12. Errors found in version 1

Version 1 used "KL(⊗P_j ‖ R) ≥ Σ_j KL(P_j ‖ R_j) for a product first argument". False: P₁ = δ_b, P₂ = Bern(1/2), R = (1 − ε)·δ_a ⊗ Bern(0.01) + ε·δ_b ⊗ Bern(1/2). So freezing the per-call mixture during a run of the human system and summing per-call divergences is not bounded by the regret; Theorem A (one hypothesis per run) and Theorem R1 (one asked call per run) avoid this.

## 13. Additions after version 2 (lead, unchecked)

**V1 (validation certificate; no assumption on the human or on how the imitator was made) [P].** Freeze any answerer A. Repeat m times: run Π with A, choose a call J uniformly from {1..L}, and if the run has a J-th call put its input to the human; record A's answer y^A used in the run and the human's answer y^P.
(a) *Deterministic human and deterministic A.* Let ρ := (1/L)·E[number of calls of a run of A at which A's answer differs from the human's]. The recorded mismatches are m independent Bernoulli(ρ) variables. If none occurs, ρ ≤ ln(1/δ)/m with confidence 1 − δ; in general the usual binomial bound. Then E[unfaithful calls per run] = Lρ, the run is entirely faithful with probability ≥ 1 − Lρ, and with tolerance of m_f faults the failure is ≤ δ_f + Lρ/(m_f + 1).
(b) *In general.* For a countable family of tests B ⊆ X × Y with weights π: with confidence 1 − δ, simultaneously for all B, the difference between the frequencies of B among A's answers and among the human's answers to A's own inputs is within √(2 ln(2/(π(B)δ))/m) of its empirical value.
So in a closed system the quality of an imitator on its own deployment distribution can be measured; the learning theorems say when the measurement will come out well, and the certificate does not depend on them. The lower bound N2 says that m questions cannot certify a rate below about 1/m.

**V2 (what imitation amplifies) [reading of N2 and R3].** With a worst-case guarantee over a class closed under patches, the number of human answers must exceed (number of critical call types in a run)/ε. Imitation therefore multiplies human work across many runs of a rehearsed computation, not within one run whose critical steps outnumber the answers. Low stakes in the sense of R3 is the only exception; a sufficient condition to examine: bounded damage (any single call sets a progress measure back by at most D calls' worth of faithful work, and there is slack), which tolerates a fault rate of about slack/(D + 1).

**V3 (what remains a bet).** Rare situations (per-call frequency below about 1/n) are never sampled; what the imitator does there is fixed by the prior. The mixture is wrong there with probability about 2^(−sep); a prior restricted to isolated hypotheses (patch-free induction, `ultranatural/note.md`, Theorem 9) bets on the simplest continuation and is exact if the human is isolated. No data decide between these.
