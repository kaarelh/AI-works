### 5.1 One program or a committee

The imitator of Section 2 is a *committee*: a fresh posterior draw at every call. The human is one program. Can a single *member* of H answer a whole run, or all runs? Every upper bound below is linear in K, hence empty for a person (K of the order of 10⁹ bits, Section 9); the content is the comparison.

**Theorem R4 (one posterior draw per run). Proved here.** Let the human be a function f ∈ H. Rehearse as in Section 2, but in each round let one hypothesis drawn from the posterior answer the whole run. Then

  Σ_t Pr[the run of round t is not the human system's run on the same (z, ρ)] ≤ (2L²/(L + 1))·K ln 2.

So the draw of a uniformly chosen round T ≤ n, taken afresh for each run, fails to reproduce the human system's run with probability at most 2L²·K ln 2/((L + 1)·n).

*Idea.* A run follows the human system's run up to its first wrong answer. If the draw's run has one with probability u, the round's question removes posterior mass at least u·(L + 1)/(2L²) in expectation, and at most K ln 2 can be removed in all. Proof: `proofs/one-mind.md`, Theorem 2.1. For K > 1 a very large class shows that the constant is exact up to the factor (1 − 1/L)(1 − 1/K) (Proposition 2.5).

*What it does not say.* Nothing about how many calls of a failed run are unfaithful (R5), and nothing for a human who is not deterministic, where no such bound exists. Let the scaffold draw one of N questions and put it three times (L = 3) to a human who errs with probability ε each time; let H contain the human with weight ½ (K = 1) and every function s of the question with weight ½·Π_z P(s(z)|z), the human with coins filled in. A question not asked before never moves the posterior. So until questions recur, after about √N rounds, a posterior draw's run stays at total variation close to (3/2)·ε(1 − ε) from the human system's, while the committee's is nearly exact (Example 3.1). Asking every call of the rehearsal runs does not help (Proposition 3.2); recorded runs of the human system do (H1).

**Proposition R5 (low stakes: a member against the committee or its vote). Proved here, by examples.** Take L calls on independent rare inputs and 0/1-valued "traps" that answer 1 at one input and at every later call. After n questions:

(a) K = 1, n ≥ 100, L ≤ √n: a posterior draw's run has at least L/4 unfaithful calls with probability at least 0.11·L/n; the committee's has more than k with probability at most (L/n)^(k+1)/(k + 1)!;

(b) K = log₂(2n), n ≥ 16, L ≤ n: for every protocol that deploys a member chosen without seeing the run's input, some human of the class gives at least L/4 unfaithful calls with probability at least L/(8n); the committee, and its plurality vote (one program, not a member), have more than k with probability at most L/(2n²) + (3L/(2n))^(k+1)/(k + 1)!, for every human of the class.

In (a), with the runs that have fewer than L/4 answers 1 as the good ones, the human system tolerates ⌈L/4⌉ − 1 faults; so the draw needs 0.11·L/δ questions for failure δ, where R3 gives the committee K ln 2/(θδ). With traps slightly heavier than the human (K about log₂(2n)) the highest-weight consistent member fails likewise, with probability at least (9/32)·L/n. Proof: `proofs/one-mind.md`, Propositions 4.2, 4.3, 4.6.

*What it does not say.* Nothing about classes in general. In (b) "unfaithful" means different from the human's answer: against good runs defined without reference to the human, a deployed member fails exactly as often as the human system of that member would. Whether the vote uses fault tolerance in general is open.

**Proposition R6 (which program, and when). Proved here; (c) not independently checked.** Let H be a class of functions and f ∈ H the human.

(a) *Not as the driver.* If each rehearsal run is answered by the highest-weight hypothesis consistent with the answers so far, at most L·(2^K − 1) of the rehearsal runs differ from the human system's in expectation, and exactly L² in a class of L + 1 functions, where the committee has at most L·ln(L + 1).

(b) *At the end.* After the n rounds of Section 2, with probability at least 1 − 2δ, every consistent g with w(g) ≥ w(f), and likewise one draw from the final posterior, has Pr[its own run is not the human system's] < 2L·(K ln 2 + ln(1/δ))/n.

(c) *A human who is not deterministic* (any class, P ∈ H). After the n rounds of Section 2 let ν̂ maximise w(ν)²·ν(D). With probability at least 1 − 2δ, H²(Q_ν̂, Q_P) < L·(28·K ln 2 + 40·ln(1/δ))/n.

*Ideas.* (a) A wrong driver hides the others' errors and is removed with probability 1/L per failed run. Without a scaffold this is the standard gap between an arbitrary consistent learner (up to |H| − 1 mistakes) and the halving algorithm (log₂|H|; Littlestone 1988). (b) An Occam bound in martingale form. (c) The same in Hellinger distance, the standard analysis of selection by description length with a doubled penalty (Barron and Cover 1991; Zhang 2006), with the subadditivity of H² along runs (Section 3). Proof: `proofs/one-mind.md`, Proposition 5.1, Example 5.2, Theorem 5.5, Corollary 5.6, Theorem 3.8.

*What it does not say.* Which member is selected (Section 9). In (c) the square is needed: a final posterior draw fails by the example above, and the member of largest posterior weight is, in a class with K = 4, a function at total variation 7/8 with probability about 0.98 (Example 3.6, after Zhang 2006). For such a human the committee must also answer the rehearsal runs: with posterior draws in its place, even the committee's runs are controlled only up to a factor 2^K (Proposition 3.5).

| | committee | member per run | member for good |
|---|---|---|---|
| deterministic human: Pr[a run is not the human system's] | L·K ln 2/n (R1) | 2L²·K ln 2/((L+1)n) (R4) | 2L·(K ln 2 + ln(1/δ))/n (R6b) |
| deterministic human, low stakes | K ln 2/(θn) (R3) | no gain in the examples (R5) | the same (R5) |
| human not deterministic | E TV ≤ 2√(L·K ln 2/n) (R2) | no bound; with recorded runs, H1 | squared weights: R6c; otherwise no bound; with recorded runs, H2 |

---

*Everything below this line is for the lead and for the reference list. It is not part of the text of Section 5.1.*

#### Sources cited in the section, with how each was read

* **Barron, A. R. and Cover, T. M. (1991).** "Minimum complexity density estimation." *IEEE Transactions on Information Theory* 37(4):1034–1054. Theorem 4, as described by Zhang (2006): for the minimiser of the negative log-likelihood plus λ times the description length, λ > 1, the Hellinger-type loss is of the order of the index of resolvability. Quoted from `verification/hellinger-runs-attack.md`, finding M2(c); not opened by the editor of this part.
* **Littlestone, N. (1988).** "Learning quickly when irrelevant attributes abound: a new linear-threshold algorithm." *Machine Learning* 2(4):285–318. The halving algorithm makes at most log₂|C| mistakes on a finite class C. Bibliographic data and this bound confirmed by web search, from abstracts, by the adversarial verifier and again by the editor; the paper was not opened. That an arbitrary consistent learner can make |C| − 1 mistakes is elementary and quoted from memory.
* **Zhang, T. (2006).** "From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation." *Annals of Statistics* 34(5):2180–2210 (arXiv:math/0702653). Theorem 4.1: for the same minimiser with λ > 1, the expected Hellinger-type risk is at most a constant times inf_k [D_KL(q ‖ p_k) + (λ/n)·ln(1/π_k)]. Section 4.4: a counterexample for λ = 1 (a truth with prior ¼ and 2^n random densities, each uniform on half of the points; the estimate of largest posterior weight is wrong with probability at least 1 − e^(−1/2) for every n). Read in the arXiv text by the adversarial verifier of part hellinger-runs; quoted from that report (findings M2(c), M2(d)); not opened by the editor of this part.
* In this repository the same two facts for inputs drawn independently are in Paper 2 (the steeper-prior paper), Theorems 6.7 and 6.11 and Proposition 6.6, according to the digest `research/understand/repo.md`, items E6, E7, E11; not opened by the editor of this part.
* Not cited in the text, for the related-work section: one posterior draw per run is posterior sampling per episode (M. Strens, "A Bayesian framework for reinforcement learning", ICML 2000, pp. 943–950; I. Osband, D. Russo and B. Van Roy, "(More) efficient reinforcement learning via posterior sampling", NeurIPS 26, 2013, pp. 3003–3011, arXiv:1306.0940; bibliographic data confirmed by the adversarial verifier's web search, papers not opened). In the terms of Li and Zhang (arXiv:2412.07057, read by the lead) the committee is an each-step mixture and a draw per run a first-step mixture over the class. The Occam bound of R6(b) is, for independent examples, that of A. Blumer, A. Ehrenfeucht, D. Haussler and M. K. Warmuth, "Occam's razor", *Information Processing Letters* 24(6):377–380, 1987 (bibliographic data confirmed by the editor's web search; statement from memory).

#### Notes to the lead

1. **Length.** The text above the line has 828 words of two or more letters. Counted as whitespace-separated tokens, with every symbol of a formula, every single-letter variable and every mark of the table as a token, it has 1098. So the limit of 900 words is met for words and not for tokens. If tokens are what counts, the first thing to cut is the table (94 tokens): each of its cells restates a result that the text gives.
2. **A label that the outline does not list: R6(c).** It is Theorem 3.8 of `proofs/one-mind.md`: one program for a human who is not deterministic, selected with the weights squared. It was added in editing, because the adversarial report (finding F1) showed that the prover's claim "for a human who is not deterministic no single program is supported by rehearsal data" did not follow from its examples, and asked that selection by penalised likelihood be marked open. The editor proved it; no verifier has checked it; `proofs/code/one-mind_editor_checks.py`, part E5, tests its steps numerically. If the note is not to carry a statement that no verifier has checked, remove item (c), the words "(c) not independently checked", item (c) of "Ideas", and write "open" for "squared weights: R6c" in the table; the first half of the last "What it does not say" (posterior draw and largest posterior weight fail) then stands as the statement that R6(b) has no version at the prior's own weights.
3. **Who checked what.** R4, R5(a), R5(b), R6(a), R6(b) and the example after R4 were verified by both reports. The sentence on traps slightly heavier than the human (Proposition 4.6), the codebook class (Example 3.6) and the factor 2^K (Proposition 3.5) come from the check report and were re-derived and tested by the editor; the adversary did not see them. Details: `proofs/one-mind.md`, Section 10.
4. **Cross-references assumed.** Section 2 (the protocol, its n rounds, T); Section 3 (R1, R2, R3 with θ and k, the subadditivity of H²); Section 5.2 (H1, H2); Section 9 (K for a person; copy or predictor).
5. **Other parts of the note that this part touches.** (i) `research/sections/toy.md` says of the simplest-consistent driver "which no theorem covers": Proposition 5.1 bounds its number of unfaithful runs by L times the number of heavier hypotheses, 2L = 6, 30, 126 in the toy's class (observed: 3.28, 21.07, 27.20). The same section quotes the bound of R4 as 2·L·K ln 2 (15.7, 78.6, 330); it is now (2L²/(L + 1))·K ln 2 = 11.8, 73.7, 325. (ii) The candidate theory's sentence "R4 and R6 give a single coherent program" (its Section 9) holds as stated for a deterministic human only; for a human who is not deterministic the statement is R6(c) with its caveats. (iii) `proofs/one-mind.md`, Proposition 5.7, gives R6(b) with 3 in place of 2 when the rehearsal runs are answered by posterior draws (statement and exact tests in the first referee's script; the proof is the editor's and is in no written report); it is not mentioned in the text.
