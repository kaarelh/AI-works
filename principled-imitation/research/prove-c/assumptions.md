# The framing, attacked: A1, A2, A3, closed systems, the seven tests, the budget and the bets (key: assumptions)

Part `assumptions` of the third proving round for `research/candidate-theory.md` (version 2 and its Section 13) and for the draft `note.md`. This part is the sceptic's. It asks what each assumption of the framing does, what is true without it, where the note and the candidate theory say more than is proved, and which objections to the claim "rehearsal is a human-imitation protocol that works exactly as far as any protocol can" stand. All proofs below are mine and unrefereed. Two scripts, `research/prove-c/code/assumptions_checks.py` and `research/prove-c/code/assumptions_episodes.py`; their outputs (`.out` files beside them) are quoted in Section 9.

## Summary of the statements

Tags: **PROVED** (a statement of the candidate theory, of the note or of a digest, proved here as stated or in the stated precise form); **MODIFIED** (a statement that needed a change, which is named); **REFUTED** (with the counterexample); **NEW** (not in the candidate theory or the note; proved here); **OPEN**.

| no. | statement | tag |
|---|---|---|
| Lemma 0.1 | Regret of the mixture against any member, for answers produced in any way: no assumption on the human, the class or the questions | PROVED (L3 generalised) |
| Lemma 0.2 | R1 for a human who may change from round to round, against any member; R1 is the case of a fixed human in the class | PROVED |
| Example 1.1 | A human with memory inside a run: R1, R3, V1 hold for the system of cold humans, which is at total variation 1/2 from the real one; the protocol's data cannot show it | NEW |
| Lemma 1.3 | A human who is reset between episodes is, for the law of every run, a sampler on the visible histories of episodes | NEW |
| Lemma 1.6 | The mixture that conditions on the earlier answers of the current episode is one posterior draw per episode | NEW |
| Theorem 1.7 | R1 with whole episodes as the unit asked: Σ_t E Σ_i KL(Q_{M̄^(t)[i←P]} ‖ Q_{M̄^(t)}) ≤ L_e·K ln 2; for a deterministic human R1 holds verbatim with episodes for calls, nested episodes included | NEW (R1 MODIFIED for an episodic human) |
| Theorem 1.8 | V1(a) and R3 with episodes for calls, deterministic human | NEW |
| Theorem 1.9 | Whole runs for an episodic human who is not deterministic: E H² ≤ 2L_e·K ln 2/n for sequential episodes, ≤ 4m_e·L_e·K ln 2/n for nested ones | NEW; the factor m_e: OPEN |
| Example 1.10 | Single messages asked in mid-episode yield the kernel of a reader, not of the human who lived the episode; total variation 1 | NEW |
| Theorem 1.11 | A human who changes during rehearsal: the deployed mixture is close to the human of its own round, up to the regret against the best fixed sampler | NEW |
| Corollary 1.12 | Drift bounded in total variation: explicit bound with a smoothed class; for linear drift the bound is smallest at n* = √(2K° ln 2/(γ(1 + ln(s/η)))) | NEW |
| Example 1.13 | Without smoothing one changed answer leaves a class of functions with no member | NEW |
| Proposition 1.14 | The date is a guard: no protocol whose questions end at time n is right at time n + 1 for two humans that part ways then | PROVED |
| Proposition 1.15 | A human who knows that no run depends on the answer: the theorems hold for the human of rehearsal; no other human is reachable; a variant in which every answer continues its run satisfies R1 | NEW |
| Proposition 1.16 | The expected number of rounds in which the human reads a question that the human system would not have asked is at most L·K ln 2 (deterministic human) | PROVED (observation of a digest) |
| Theorem 2.1 | (a) L3 and R1 without A2: complexity of any member plus its divergence from the human along the mixtures' runs. (b) With A2 the price is exactly K ln 2 − E ln(1/w_{D_n}(P)), the information gained about the human | (a) PROVED, (b) NEW |
| Proposition 2.2 | A2 is needed only on the inputs the scaffold can produce: K may be replaced by K_Π | NEW (A2 weakened) |
| Example 2.3 | Without A2 the member whose runs are exactly the human system's is refuted with probability 0.4435 on an input that only the mixture reaches, and the protocol ends at a member that fails half of the time | NEW |
| Proposition 2.4 | At most 2^k members have K ≤ k under any prior; with the lower bound of `lower-bounds.md`, Theorem 3.1, the factor K cannot be avoided; what a prior built from knowledge changes | PROVED |
| Proposition 2.5 | V1(a) holds without A2 and without a deterministic human: no mismatch in m rounds certifies β(A) ≤ L·ln(1/δ)/m | MODIFIED (a hypothesis of V1(a) removed) |
| Remark 2.6 | With repeated questions the mean squared L₂ distance between imitator and human on the imitator's inputs is 2ρ_AP − ρ_AA − ρ_PP | NEW |
| Theorem 3.2 | The referent test under A3: (a) for every set Q, the deployed run meets Q before any question did with probability at most L/n; (b) a fixed hypothesis loses weight at the rate of its Hellinger deviation on the mixtures' runs; (c) a prior fixed first gives the hypothesis that knows the coins at most the probability of guessing them | NEW |
| Example 3.3 | The asked call computed from the run by a k-bit seed: at least (L − 1)/(2^k + 1) unfaithful calls per run for every n | NEW (R1 REFUTED without A3(i)) |
| Example 3.4 | A real task of rehearsal probability p: error η(1 − (1 − p)^n)/(np) on it | NEW |
| Example 3.5 | A date in the inputs: harmless under one prior, an error of constant probability under another | NEW |
| Example 3.6 | A prior that has seen the rehearsal data memorises | NEW |
| Definition 4.1 | Closed deployment: (C1) one more sample, (C2) sampling in advance, (C3) nothing else gets in | MODIFIED (the note's definition is (C2) only) |
| Proposition 4.2 | A stock of exchangeable top-level inputs, each used once, suffices for R1 | NEW |
| Proposition 4.3 | An open system with the human asked at rate q: summed divergence at most K ln 2/q on any sequence of calls | PROVED (observation of a digest) |
| Proposition 4.4 | The complete list of what is offered when the deployment is not closed | PROVED (collects) |
| Section 5 | The seven tests: verdicts with arguments; where Section 10 of the candidate theory overclaims (tests 1, 3, 4, 5, 6) | MODIFIED (candidate's Section 10) |
| Theorem 6.1 | The factor K under fault tolerance: for a class of 2^K functions on a scaffold that tolerates m faults, every protocol needs (1 − 10δ)·K·B/(8δ·log₂(B/(2δ))) questions, B = L/(2m + 1); R3 is within 16 ln 2·log₂(B/(2δ))/(1 − 10δ) of this | NEW |
| Corollary 6.2, Remark 6.2a | "Whatever the horizon L" means: the cost depends on the number B of independent critical units, and replication does not lower the cost per unit; with a proposition of the referee of `lower-bounds.md` the order is K·B/(δ·log₂(B/δ)) | NEW |
| Proposition 6.3 | Rehearsal in batches: Σ_s E Λ(M^[s]) ≤ L·K ln 2 over the S batches; parallel answers are not credited | NEW |
| Sections 6.2, 6.3 | The budget in hours and years, and where it is hopeless | computed |
| Proposition 7.1 | On a set of inputs met with probability q ≪ 1/n the imitator does what the prior says, and R1 holds for both priors | PROVED |
| Lemma 7.3 | In a closed system with run distance, two isolated members are run-equivalent or at distance at least δ | NEW |
| Theorem 7.4 | Patch-free rehearsal: if the human is δ-separated in the class, the posterior weight off its run class is at most 2^K·(1 − δ/(2L))^n after n single-call questions, and 2^K·(1 − δ)^N after N recorded runs | NEW (Theorem 9 of `ultranatural/note.md` for the present setting) |
| Proposition 7.5, Example 7.6 | The price of the bet: a patch of the human is never learned; the loss shows in the marginal likelihood only after a question lands on the patch; universality costs log₂(1/κ) bits | NEW |
| Proposition 7.7 | Averaged over the prior, one posterior draw per run has exactly the law of the human system, with any number of questions | PROVED |
| Propositions 7.8, 7.9, 7.10 | Copy or predictor: the data fix the kernel on the inputs of the closed system only; under A1 no predictor beats the sampler; a sampler and its frozen version differ on repeated questions only | PROVED |
| Section 8 | Seventeen objections to "rehearsal is a human-imitation protocol that works exactly as far as any protocol can", classed: five fatal to a part of the claim, seven answerable, four answered, one outside the theorems | assessment |
| Section 10.1 | Eight open questions (and one settled by a referee's addition) | OPEN |

**In brief.** (1) A1 does three jobs (data, target, identity) and its failure is invisible in the protocol's data. If the human is reset between episodes and remembers inside them, the theorems hold with episodes as the unit asked, exactly for a deterministic human. A human who changes is tracked only as well as the best fixed sampler, and longer rehearsal can be worse. (2) Without A2 the bound is an oracle inequality measured on the mixtures' runs, and the mixture can destroy a member that is perfect on the human system; with A2 the price is exactly the information gained about the human. The factor K is forced, also under low stakes (Theorem 6.1). The certificate needs neither A2 nor a deterministic human. (3) A3 as the proofs use it has four parts; under them every guard and every hypothesis about the experiment is covered, and each part has an explicit failure. (4) A deployment is closed if it is a rehearsal run that happens to count. (5) Of the seven tests, guard and referent are passed inside a closed deployment, rock is passed at the price of silent failures, machine is passed only by the certificate, and copy, budget and horizon are not passed. (6) With an hour per answer one working life pays for about 1.4·10³ bits of K; with a year per answer, for less than one bit. (7) What happens in rare situations is the prior's choice; a patch-free prior gives an exponential rate if its bet is right and a silent, certain error if it is wrong. (8) What survives of the claim is stated at the end of Section 8.

**Labels.** The statements here carry section numbers. Labels of the note's series (R, V, N, …) are left to the finaliser; natural candidates are Theorem 6.1 (a limit, series N), Theorems 1.7 and 7.4 (series R) and Proposition 2.5 (a revision of V1).

## 0. Setting, conventions, and two lemmas used throughout

### 0.1 Notation

The notation is that of `research/outline.md`. Logarithms: ln is natural, log₂ is binary. E denotes expectation.

* **Samplers, class, mixture.** X and Y are countable sets of strings. A *sampler* is a probability kernel S(·|x) on Y; a *function* f: X → Y is the sampler that answers f(x) with probability one. The human is a sampler P. H is a countable class of *hypotheses* ν, each a conditional semimeasure (ν(y|x) ≥ 0, Σ_y ν(y|x) ≤ 1; the missing mass stands for "no answer"), with weights w(ν) > 0 and W := Σ_ν w(ν) ≤ 1. When P ∈ H, K := log₂(1/w(P)). A *data list* D is a finite sequence of pairs (x_i, y_i); ν(D) := Π_i ν(y_i|x_i); ξ(D) := Σ_ν w(ν)·ν(D), so ξ(∅) = W. If ξ(D) > 0 the *posterior* is w_D(ν) := w(ν)ν(D)/ξ(D) and the *mixture* is M_D(y|x) := Σ_ν w_D(ν)ν(y|x) = ξ(D + (x, y))/ξ(D), where D + (x, y) is D with one pair appended. If ξ(D) = 0 put M_D := M_∅.
* **Divergences.** For a probability p and a sub-probability q on Y: KL(p ‖ q) := Σ_y p(y) ln(p(y)/q(y)) ∈ [0, ∞] (it is at least ln(1/q(Y)) ≥ 0); TV is total variation; H²(p, q) := 1 − Σ_y √(p(y)q(y)). For kernels, KL(S ‖ S′)(x) abbreviates KL(S(·|x) ‖ S′(·|x)), and likewise for TV and H².
* **Scaffold, runs.** A scaffold Π of horizon L draws a top-level input z ~ D₀ and its own randomness ρ ~ λ, then for j = 1, 2, … computes the input x_j := next_j(z, ρ, y_1, …, y_{j−1}) ∈ X of the j-th *call* or stops; it makes at most L calls; out(·) is its outcome. A *run* is τ = (z, ρ, y_1, …, y_len(τ)), where len(τ) ≤ L is its number of calls; h_j := (z, ρ, y_1, …, y_{j−1}) is the history before call j. An *answerer* A is a family of distributions A_j(·|h_j) on Y together with the symbol "no answer", which the scaffold treats as one more answer; a sampler S is the answerer that looks only at x_j. Q_A is the law of the run answered by A, and Q_P is the *human system*. For a function g, run_g(z, ρ) is the run in which g answers every call.
* **Protocol R (rehearsal).** For t = 1, …, n: (1) M^(t) := M_{D_{t−1}}; (2) a run τ_t of Π is generated with M^(t) answering every call (a fresh draw at every call), its inputs being x_{t,1}, …, x_{t,len(τ_t)}; (3) J_t is drawn from {1, …, L}; if J_t ≤ len(τ_t) the question x_t := x_{t,J_t} is put to the human, the answer y_t is received and D_t := D_{t−1} + (x_t, y_t); otherwise D_t := D_{t−1}. We write a_t := 1[J_t ≤ len(τ_t)]. *Deployment:* T is drawn uniformly from {1, …, n}, and Π is run with M^(T).
* **σ-fields.** 𝓕_t is generated by everything realised up to the end of round t; 𝓖_t by everything realised before the human's answer of round t (so 𝓕_{t−1}, τ_t and J_t are 𝓖_t-measurable).
* **Two functionals.** For a kernel C and a sampler P: Λ(C) := E_{Q_C} Σ_{j ≤ len} KL(P ‖ C)(x_j) and β(C) := E_{Q_C} Σ_{j ≤ len} TV(P, C)(x_j), both along C's own runs. β(C) is the least expected number of *unfaithful calls* of a run of C over all ways of coupling C's answers with shadow answers of the human (`research/prove/rehearsal-core.md`, Lemma 3.2).

### 0.2 The assumptions, as the proofs use them

The note states A1 to A3 in words. The proofs use the following.

* **A1 (stateless human, fresh coins).** There is one sampler P such that, whenever a question x is put to the human, Pr[answer = · | everything realised before the answer] = P(·|x). The object to be imitated is Q_P for the same P.
* **A2 (the human is in the class).** P ∈ H.
* **A3 (the protocol's coins), in four parts.**
  (i) *The asked call is uniform given the run:* J_t is uniform on {1, …, L} conditionally on 𝓕_{t−1}, the run τ_t and the state of the human before round t.
  (ii) *Deployment is a further sample:* T is uniform on {1, …, n} and independent of everything else, and the deployed run uses a pair (z, ρ) ~ D₀ ⊗ λ and coins of the imitator that are independent of everything before.
  (iii) *The class is fixed first:* H and w are chosen before any coin of the protocol or of the human is drawn (they are not random).
  (iv) *The human is shown what the imitator was shown:* the question put to the human is the string x_{t,J_t}, and nothing that the human sees distinguishes a rehearsal question from the same string inside a run.

The note's wording of A3 ("independent of the human's coins and not predictable by any hypothesis") is discussed in Section 3: the second clause is not used by any proof, and parts (i) to (iv) are what a proof needs. Each statement below says which assumptions it uses.

### 0.3 Results of other parts that are quoted

Quoted, with their places, and marked where used. While this file was being written, referee reports appeared for two of the files quoted: `research/verify/lower-bounds-check.md` gives the verdict CORRECT to every statement of `lower-bounds.md` that is used here (its Lemma 1.5, Theorems 1.6, 2.1, 3.1, 4.1, 5.3, Corollaries 1.7, 2.2, Proposition 3.2; Theorem 3.3 with clarifications of its statement), and `research/verify/hellinger-runs-check.md` does the same for `hellinger-runs.md` (Theorem 2.1, Corollary 2.3, Proposition 2.5, Theorems 3.1 and 5.1). I read the verdicts and the referee's additions A1 and A2 of the first report, not the reports in full. R1, R3 and R4 have no report yet.

* **R1** (`note.md`, Theorem R1; proof also in `research/prove-b/hellinger-runs.md`, Appendix A): under A1, A2, A3, Σ_{t ≤ n} E Λ(M^(t)) ≤ L·K ln 2; for a function f, the expected number of unfaithful calls of the run of M^(T) is at most L·K ln 2/n. It is re-proved here as the case ν = P of Lemma 0.2.
* **R3** (`note.md`, Theorem R3): if the run of an imitator has β unfaithful calls in expectation and the human system tolerates m faults with failure δ₀, the run is good with probability at least 1 − δ₀ − β/(m + 1).
* **R4** (`research/candidate-theory.md`, Theorem R4, for functions; its proof is repeated inside the proof of Theorem 7.4 below).
* **L4 and R2** (`research/prove-b/hellinger-runs.md`, Theorem 2.1, Corollary 2.3, Theorem 3.1): for sequential experiments with kernels p_i, q_i, H²(P, Q) ≤ 4·E_P Σ_i H²(p_i, q_i); hence E H²(Q_{M^(T)}, Q_P) ≤ 2L·K ln 2/n.
* **N1, N2, N3, N5 and the factor K** (`research/prove/lower-bounds.md`, Lemma 1.5, Theorems 1.6, 2.1, 3.1, 4.1, 5.3). Their statements are repeated where they are used.

### 0.4 Two lemmas

**Lemma 0.1 (regret against any member, for any way of producing the answers). PROVED.** Let rounds t = 1, …, n be given with: an indicator a_t ∈ {0, 1} ("a question is asked") and an input x_t ∈ X, both 𝓖_t-measurable; if a_t = 1 an answer y_t ∈ Y is produced in any way, and D_t := D_{t−1} + (x_t, y_t); otherwise D_t := D_{t−1}. Let p_t := Pr[y_t = · | 𝓖_t] be the conditional law of the answer (a random distribution on Y, defined on {a_t = 1}). Let H, w be any class with weights. Then for every ν ∈ H,

  Σ_{t ≤ n} E[a_t·KL(p_t ‖ M_{D_{t−1}}(·|x_t))] ≤ ln(W/w(ν)) + Σ_{t ≤ n} E[a_t·KL(p_t ‖ ν(·|x_t))].  (0.1)

If the right side is finite then almost surely ξ(D_t) > 0 for all t ≤ n, and

  Σ_{t ≤ n} a_t·ln(p_t(y_t)/M_{D_{t−1}}(y_t|x_t)) = ln(W·Π_{t: a_t = 1} p_t(y_t)/ξ(D_n))  almost surely.  (0.2)

Nothing is assumed about the human (no A1), about the class (no A2) or about how the questions are chosen.

*Proof.* If the right side of (0.1) is infinite there is nothing to prove. Otherwise E[a_t·KL(p_t ‖ ν(·|x_t))] < ∞ for every t, so almost surely on {a_t = 1} the distribution p_t gives no mass to {y : ν(y|x_t) = 0}, and Pr[a_t = 1, ν(y_t|x_t) = 0] = E[a_t·p_t({y : ν(y|x_t) = 0})] = 0. In the same way Pr[a_t = 1, p_t(y_t) = 0] = 0. Hence almost surely ν(D_n) > 0, so ξ(D_t) ≥ w(ν)ν(D_t) > 0 for all t ≤ n, and on {a_t = 1} we have M_{D_{t−1}}(y_t|x_t) = ξ(D_t)/ξ(D_{t−1}). The product of these factors over the asked rounds telescopes to ξ(D_n)/W, which is (0.2), and ξ(D_n) ≥ w(ν)ν(D_n). With Z_t := a_t ln(p_t(y_t)/M_{D_{t−1}}(y_t|x_t)) and V_t := a_t ln(p_t(y_t)/ν(y_t|x_t)) this gives, almost surely,

  Σ_t Z_t ≤ ln(W/w(ν)) + Σ_t V_t.  (0.3)

For a probability p and a sub-probability q on Y, Σ_y p(y)·(ln(q(y)/p(y)))⁺ ≤ Σ_y p(y)·q(y)/(e·p(y)) ≤ 1/e, because (ln u)⁺ ≤ u/e. So the negative parts of Z_t and V_t have conditional expectation at most 1/e given 𝓖_t, the conditional expectations are E[Z_t | 𝓖_t] = a_t KL(p_t ‖ M_{D_{t−1}}(·|x_t)) and E[V_t | 𝓖_t] = a_t KL(p_t ‖ ν(·|x_t)), and V_t is integrable. By (0.3), Z_t ≤ ln(W/w(ν)) + Σ_s V_s + Σ_{s ≠ t} Z_s⁻, an integrable bound, so Z_t is integrable too. Taking expectations in (0.3) gives (0.1). ∎

**Lemma 0.2 (R1 in general form: a moving human, no A2). PROVED.** Run Protocol R. Assume A3(i) and A3(iv), and assume that for every round t there is a random kernel P_t, measurable with respect to 𝓕_{t−1}, τ_t and the state of the human before round t, such that Pr[y_t = · | 𝓖_t] = P_t(·|x_t) on {a_t = 1}. (P_t is "the human of round t": how the human would answer whichever call is chosen. Under A1, P_t = P.) Then for every ν ∈ H,

  Σ_{t ≤ n} E[Σ_{j ≤ len(τ_t)} KL(P_t ‖ M^(t))(x_{t,j})] ≤ L·ln(W/w(ν)) + Σ_{t ≤ n} E[Σ_{j ≤ len(τ_t)} KL(P_t ‖ ν)(x_{t,j})].  (0.4)

Under A1 and A2, the choice ν = P gives Theorem R1: Σ_t E Λ(M^(t)) ≤ L·ln(W/w(P)) ≤ L·K ln 2.

*Proof.* For a nonnegative function g_t(x) that is measurable with respect to 𝓕_{t−1}, τ_t and the state of the human, A3(i) gives

  E[a_t·g_t(x_{t,J_t}) | 𝓕_{t−1}, τ_t, state] = (1/L)·Σ_{j ≤ len(τ_t)} g_t(x_{t,j}).  (0.5)

Apply Lemma 0.1 with p_t = P_t(·|x_t), then (0.5) with g_t = KL(P_t ‖ M^(t)) and with g_t = KL(P_t ‖ ν), and multiply by L. ∎

Identity (0.5) is the whole content of A3(i): the asked call is an unbiased sample of the calls of the run, for every quantity that is fixed before the call is chosen.

## 1. A1: the stateless human

### 1.1 What A1 does, and that its failure is silent

A1 does three things at once. (a) *Data:* every recorded answer is a draw from P at the asked input, whatever was asked before. (b) *Target:* the human system is the law of runs in which every call is answered by a fresh draw from the same P, so that "the answer the human would give at the imitator's input" is defined. (c) *Identity:* the P of rehearsal, the P of validation and the P of the target are one kernel. A human with memory can break each of the three, and the protocol's own data do not show it.

**Example 1.1 (memory inside a run: every theorem holds, for the wrong system). NEW.** The scaffold has two calls and no randomness: call 1 has the input "a", call 2 the input "b", answers are bits, and the outcome is 1[y_1 = y_2]. The human answers "a" with a fair bit U. Asked "b" later *in the same sitting*, the human repeats U. Asked "b" in a sitting that did not contain "a", the human answers with a fresh fair bit. In the real human system one human does both calls, the run is (U, U), and the outcome is 1 with probability one. In rehearsal and in validation the human answers single calls, each in a new sitting. Then:

1. The recorded answers are independent fair bits at both inputs. A1 holds for the sampler P_cold with P_cold(·|a) = P_cold(·|b) = Bernoulli(1/2), and R1, R3 and V1 are true statements about the system Q_{P_cold}, in which the two answers are independent.
2. Validation passes: for every set B of pairs (question, answer) the frequencies of B under the imitator and under the human's recorded answers agree in expectation, so V1(b) certifies the imitator.
3. The deployed run of the exact imitator P_cold has outcome 1 with probability 1/2: its law is at total variation 1/2 from the real human system.
4. No function of the data of any protocol that asks single calls in separate sittings distinguishes this human from a human who is P_cold in every sitting: the two produce the same law of data.

So A1 cannot be tested from inside the protocol, and what the theorems guarantee when it fails is the imitation of the system of *cold* humans. The repair that the note names (the input carries what must be remembered: call 2 gets the input ("b", "a", y_1)) works when reading a record puts the human in the state that living through it would have produced. Subsection 1.2 treats the case in which it does not.

### 1.2 Episodes: the human is reset between units, and remembers inside a unit

In this subsection hypotheses are samplers (probability kernels), to avoid bookkeeping for unanswered calls.

**Definition 1.2 (episodic human).** An *episodic human* consists of a probability space of private coins ζ and maps φ_k(ζ; o_1, …, o_k) ∈ Y, k = 1, 2, …. An *episode* is one use: fresh coins ζ are drawn (the human is *reset*), messages o_1, o_2, … arrive one at a time, and the human answers y_k := φ_k(ζ; o_1, …, o_k). Whatever the human remembers or learns inside the episode is a function of ζ and of the messages so far. The *visible history* before the k-th answer is v_k := (o_1, y_1, …, o_{k−1}, y_{k−1}, o_k). An environment is *blind* if each message o_k is a function of the earlier answers y_1, …, y_{k−1} of this episode and of a random element e that is independent of ζ.

For a sequence (o_1, η_1, …, o_k, η_k) let g(o_1, η_1, …, o_k, η_k) := Pr_ζ[φ_i(ζ; o_1, …, o_i) = η_i for all i ≤ k] (with g of the empty sequence equal to 1), and for a visible history v = (o_1, η_1, …, o_{k−1}, η_{k−1}, o_k) with g(o_1, η_1, …, o_{k−1}, η_{k−1}) > 0 let

  P^vis(η | v) := g(o_1, η_1, …, o_k, η)/g(o_1, η_1, …, o_{k−1}, η_{k−1}),

and let P^vis(·|v) be an arbitrary fixed distribution for the other v. P^vis depends on the human alone.

**Lemma 1.3 (an episodic human is a sampler on visible histories). NEW.** In an episode with a blind environment, Pr[y_k = η | e, y_1, …, y_{k−1}] = P^vis(η | v_k) almost surely, for every k.

*Proof.* Fix a value of e. Then o_i = ψ_i(e; y_1, …, y_{i−1}) for some functions ψ_i, and for every sequence η_1, …, η_k the event {y_i = η_i for all i ≤ k} is the event {φ_i(ζ; o_1, …, o_i) = η_i for all i ≤ k} with o_i := ψ_i(e; η_1, …, η_{i−1}). Because ζ is independent of e, its probability given e is g(o_1, η_1, …, o_k, η_k). Divide the value for k by the value for k − 1. ∎

So for an episodic human inside a scaffold (which is blind: it sees answers only, and different episodes use independent coins), the law of every run is the law of the run answered by the sampler P^vis. *The target is still a human system Q_{P^vis} of a sampler.* What A1 loses is access.

**Definition 1.4 (episodic scaffold; episodic access).** An *episodic scaffold* is a scaffold Π with a rule that gives every call j of every run an *episode number* e_j ∈ {1, …, L_e}, a function of the history h_j, such that (a) numbers are given in order of first appearance, and (b) the input of a call is the visible history of its episode: x_j = (o) for the first call of an episode, and x_j = (x_{j′}, y_{j′}, o) otherwise, where j′ is the preceding call of the same episode and o is the scaffold's next message. L_e is the *episodic horizon* (the largest number of episodes of a run) and m_e the largest number of calls of one episode. The episodes are *sequential* if the calls of each episode are consecutive; in general they may be nested (an episode waits for sub-episodes) or interleaved. In the human system every episode is carried out by the human after a reset, and by Lemma 1.3 the human system is Q_{P^vis}.

**A1′ (episodic access).** The protocol can open an episode and feed it messages one at a time; the k-th answer of an episode with visible history v is a draw from P^vis(·|v), given everything realised before it. The protocol has no other access to the human. In particular it can show a visible history v to a freshly reset human only as the text of an opening message; the answer is then a draw from P^read(·|v) := P^vis(·|(v)), the reaction to *reading* v. A human has *transparent memory* if P^read(·|v) = P^vis(·|v) for every visible history v that the scaffold can produce. Under transparent memory A1′ is A1 with visible histories as inputs, which is the note's "whatever must be remembered travels in the input".

**Definition 1.5 (episodic mixture).** For a visible history v = (o_1, y_1, …, o_k) let pairs(v) be the list of the k − 1 question–answer pairs ((o_1), y_1), ((o_1, y_1, o_2), y_2), … that v contains. The *episodic mixture* after data D is M̄_D(·|v) := M_{D + pairs(v)}(·|v).

**Lemma 1.6 (the episodic mixture is one posterior draw per episode). NEW.** M̄_D is a kernel on visible histories, and the run of Π answered by M̄_D has the law of the run in which, at the first call of every episode, a hypothesis is drawn from the posterior w_D independently of everything else and answers all calls of that episode.

*Proof.* In the second procedure let ν_e be the hypothesis of episode e, and let j be the k-th call of episode e, with visible history v = x_j. The history h_j depends on ν_e only through the earlier answers y_1, …, y_{k−1} of episode e, whose joint probability given ν_e = ν and everything else is Π_{i<k} ν(y_i|v_i). So the conditional law of ν_e given h_j is proportional to w_D(ν)·Π_{i<k} ν(y_i|v_i), which is the posterior w_{D + pairs(v)}, and the conditional law of y_j given h_j is Σ_ν w_{D+pairs(v)}(ν)·ν(·|v) = M̄_D(·|v). A run whose answers have these conditional laws has the law Q_{M̄_D}. ∎

**Protocol R^ep (rehearsal with whole episodes).** For t = 1, …, n: M̄^(t) := M̄_{D_{t−1}}; an index I_t is drawn uniformly from {1, …, L_e}; a run of Π is generated in which the calls of episode number I_t are put to the human, in order and as one episode, and every other call is answered by M̄^(t); the pairs (x_j, y_j) of the human's episode are appended to the data. Deployment: T uniform on {1, …, n}, and Π is run with M̄^(T). The human carries out n episodes and no run.

For a sampler C on visible histories and i ≤ L_e, C[i←P] denotes the answerer that answers the calls of episode i by P^vis and all other calls by C. For a function f, an episode of a run of C is *unfaithful* if at one of its calls C's answer differs from f; N_ep(C) is the number of unfaithful episodes of a run of C.

**Theorem 1.7 (R1 with episodes in place of calls). NEW.** Assume A1′, that P^vis ∈ H with K := log₂(1/w(P^vis)), and A3 with I_t in place of J_t. Then

  Σ_{t ≤ n} E[Σ_{i ≤ L_e} KL(Q_{M̄^(t)[i←P]} ‖ Q_{M̄^(t)})] ≤ L_e·K ln 2.

Consequently:

(a) E[Σ_{i ≤ L_e} KL(Q_{M̄^(T)[i←P]} ‖ Q_{M̄^(T)})] ≤ L_e·K ln 2/n. Handing one episode of the deployed imitator's run to the human changes the law of the run by a total variation that is, on average over the L_e episodes and in expectation, at most √(K ln 2/(2n)).

(b) If the human is deterministic (P^vis is a function f), then E[N_ep(C)] ≤ Σ_i KL(Q_{C[i←f]} ‖ Q_C) for every sampler C; hence E[N_ep(M̄^(T))] ≤ L_e·K ln 2/n, and the deployed run equals the human system's run on the same (z, ρ) with probability at least 1 − L_e·K ln 2/n.

With one call per episode this is Theorem R1.

*Proof.* Order the answers that the human gives during rehearsal: the rounds in order and, inside a round, the messages of the human's episode in order. This is a sequence of at most n·m_e questions and answers as in Lemma 0.1 (a_s = 1 for the messages that occur; whether a message occurs is known before it is answered). The question of a message with visible history v is the string v; by A1′ the conditional law of the answer given everything before it is P^vis(·|v); the data list before it is D_{t−1} + pairs(v), so the mixture of Lemma 0.1 at this question is M̄^(t)(·|v). Lemma 0.1 with ν = P^vis gives

  Σ_t E[Σ_{calls j of the human's episode in round t} KL(P^vis ‖ M̄^(t))(x_j)] ≤ ln(W/w(P^vis)) ≤ K ln 2.

Given 𝓕_{t−1} and I_t = i, the run of round t has the law Q_{M̄^(t)[i←P]}. By the chain rule for runs (L1: KL(Q_A ‖ Q_B) = E_{Q_A} Σ_j KL(A_j(·|h_j) ‖ B_j(·|h_j)); `research/prove/rehearsal-core.md`, Lemma 2.1), applied to the answerers M̄^(t)[i←P] and M̄^(t), which differ at the calls of episode i only, the conditional expectation of the inner sum is KL(Q_{M̄^(t)[i←P]} ‖ Q_{M̄^(t)}) (zero if the run has fewer than i episodes). I_t is uniform given 𝓕_{t−1}; multiply by L_e.

(a) Average over t. For the last sentence, TV ≤ √(KL/2) and the concavity of the square root: E[(1/L_e)Σ_i TV_i] ≤ √(E[(1/L_e)Σ_i KL_i]/2).

(b) Let U = (U_{e,k}) be independent uniform variables, one for every episode number e and position k, independent of (z, ρ), and let F_C(x, u) be a quantile map of C(·|x). Answering the k-th call of episode e, with input x, by F_C(x, U_{e,k}) gives a run of law Q_C. Fix i, and let the *hybrid run* use the same (z, ρ, U) but answer the calls of episode i by f. Let j* be the first call of episode i of the hybrid run, say its k-th, with F_C(x_{j*}, U_{i,k}) ≠ f(x_{j*}); j* := ∞ if there is none. Before j* the two runs make the same calls with the same answers: by induction, a call outside episode i has the same input and the same coin in both, and a call of episode i is answered f(x) in the hybrid run and F_C(x, U) = f(x) in the run of C. So episode i of the run of C is unfaithful exactly if j* < ∞. The hybrid run does not use the coins U_{i,·}, so U_{i,k} is independent of the history of the hybrid run before the k-th call of episode i, and

  Pr[j* < ∞] ≤ E_{Q_{C[i←f]}}[Σ_{j in episode i} (1 − C(f(x_j)|x_j))] ≤ E_{Q_{C[i←f]}}[Σ_{j in episode i} −ln C(f(x_j)|x_j)] = KL(Q_{C[i←f]} ‖ Q_C).

Sum over i. A run of C without an unfaithful episode has no call at which C's answer differs from f, so it is run_f(z, ρ). ∎

**Theorem 1.8 (the certificate and low stakes with episodes; deterministic human). NEW.** Let the human be an episodic human whose kernel P^vis is a function f, and let C be any sampler on visible histories, however obtained (no A2).

(a) *Certificate.* In a validation round draw I uniformly from {1, …, L_e}, generate the run in which episode I is carried out by the human and the other calls are answered by C, and at each message of the human's episode draw alongside the answer that C would give at the same visible history; record a *mismatch* if one of these differs from the human's answer. The rounds are independent and each has a mismatch with probability ρ_e := E[N_ep(C)]/L_e. If m rounds show no mismatch, then with confidence 1 − δ, E[N_ep(C)] ≤ L_e·ln(1/δ)/m.

(b) *Low stakes.* Say that the human system *tolerates m faulty episodes with failure δ₀* (for a set G of good runs) if for every rule that at each call sees the history and the human's answer and may replace the answer, and that in every run replaces answers in at most m episodes, the run is in G with probability at least 1 − δ₀. Then the run of C is in G with probability at least 1 − δ₀ − E[N_ep(C)]/(m + 1). For C = M̄^(T) under the assumptions of Theorem 1.7 this is at least 1 − δ₀ − L_e·K ln 2/((m + 1)·n).

*Proof.* (a) With the coins of the proof of Theorem 1.7(b), the answer that C would give at the k-th message is F_C(x, U_{I,k}), and a mismatch is the event {j* < ∞} for i = I. It was shown there that this is the event that episode i of the run of C (same coins) is unfaithful. So the probability of a mismatch is (1/L_e)·Σ_i Pr[episode i of a run of C is unfaithful] = ρ_e. If ρ_e > ln(1/δ)/m, the probability of no mismatch in m rounds is (1 − ρ_e)^m < δ. (b) With the same coins, the run of C is the run of f under the rule "replace f(x) at the k-th call of episode e by F_C(x, U_{e,k})". Change the rule so that, once m episodes contain a replacement, it replaces nothing in any other episode. The changed rule is admissible, and its run coincides with the run of C unless N_ep(C) > m, which has probability at most E[N_ep(C)]/(m + 1) by Markov's inequality. ∎

**Theorem 1.9 (whole runs for an episodic human who is not deterministic). NEW.** Under the assumptions of Theorem 1.7:

(a) if the episodes are sequential, E[H²(Q_{M̄^(T)}, Q_{P^vis})] ≤ 2L_e·K ln 2/n, hence E[TV(Q_{M̄^(T)}, Q_{P^vis})] ≤ 2·√(L_e·K ln 2/n);

(b) for arbitrary (nested, interleaved) episodes, E[H²(Q_{M̄^(T)}, Q_{P^vis})] ≤ 4m_e·L_e·K ln 2/n, hence E[TV] ≤ √(8m_e·L_e·K ln 2/n).

*Proof.* Let C be a sampler on visible histories and P := P^vis. It suffices to show H²(Q_C, Q_P) ≤ c·Σ_i KL(Q_{C[i←P]} ‖ Q_C) with c = 2 in case (a) and c = 4m_e in case (b); then take C = M̄^(t), use Theorem 1.7 and average over t; the bound for TV is TV ≤ √(2H²) and Jensen's inequality.

(a) Let X_0 := (z, ρ) and let X_i be the sequence of answers of episode i (the empty sequence if the run has fewer than i episodes). The run and (X_0, …, X_{L_e}) determine each other. Given X_0, …, X_{i−1}, the opening message of episode i and the scaffold's reply to every sequence of answers inside it are determined, because no call of another episode intervenes. So there are kernels c_i(·|X_<i) and p_i(·|X_<i), the laws of X_i when the episode is answered by C and by P; under Q_C the X_i are generated by the c_i and under Q_P by the p_i. By Theorem 2.1(c) of `research/prove-b/hellinger-runs.md` (sequential experiments with arbitrary kernels on countable sets) and H² ≤ KL/2,

  H²(Q_C, Q_P) ≤ 4·E_{Q_C} Σ_i H²(c_i, p_i)(X_<i) ≤ 2·E_{Q_C} Σ_i KL(p_i ‖ c_i)(X_<i).

Under Q_{C[i←P]} and under Q_C the variables X_<i have the same law, X_i then has the kernel p_i or c_i, and the later kernels are equal; by the chain rule E_{Q_C}[KL(p_i ‖ c_i)(X_<i)] = KL(Q_{C[i←P]} ‖ Q_C).

(b) Fix i and take the coins U of the proof of Theorem 1.7(b). Let X_0 := (z, ρ, (U_{e,k})_{e ≠ i}) and, for k = 1, …, m_e, let X_k be the k-th answer of episode i (a padding symbol if there is none). Given X_0 and X_<k the input v_k of the k-th call of episode i, if it exists, is determined, since every other call is a function of X_0 and of the answers of episode i so far. In the run of C, X_k = F_C(v_k, U_{i,k}) has the conditional law C(·|v_k); in the hybrid run it has the law P(·|v_k). Let 𝐂 and 𝐏 be the laws of (X_0, …, X_{m_e}) in the two runs, 𝐂_k and 𝐏_k the laws of X_≤k, and h_k := H²(P, C)(v_k). Writing densities with respect to a common dominating measure,

  1 − H²(𝐏_k, 𝐂_k) = ∫ √(d𝐏_{k−1}·d𝐂_{k−1})·(1 − h_k) ≤ ∫ ½(d𝐏_{k−1} + d𝐂_{k−1})·(1 − h_k) = 1 − ½E_𝐏[h_k] − ½E_𝐂[h_k],

so E_𝐂[h_k] ≤ 2H²(𝐏_k, 𝐂_k) ≤ 2H²(𝐏, 𝐂) ≤ KL(𝐏 ‖ 𝐂), and KL(𝐏 ‖ 𝐂) = E_𝐏 Σ_k KL(P ‖ C)(v_k) = KL(Q_{C[i←P]} ‖ Q_C) by the chain rule. Hence E_{Q_C}[Σ_{j in episode i} H²(P, C)(x_j)] ≤ m_e·KL(Q_{C[i←P]} ‖ Q_C). Sum over i and apply L4 at the level of calls (Corollary 2.3 of `research/prove-b/hellinger-runs.md`): H²(Q_C, Q_P) ≤ 4·E_{Q_C} Σ_j H²(C, P)(x_j). ∎

**Which of R1, R3, V1 hold with "call" replaced by "episode".** For a deterministic human all three hold verbatim, for sequential and for nested episodes, with L replaced by L_e, with K the weight of the human as a function on visible histories, with n and m counting human *episodes*, and with one posterior draw per episode in place of one per call (Theorems 1.7(b), 1.8). For a human who is not deterministic, R1 holds in the form of Theorem 1.7: the divergence is measured along the episode as the *human* plays it inside the imitator's run, not along the imitator's own messages. Whole-run closeness holds with L_e for sequential episodes and with an extra factor 2m_e for nested ones (Theorem 1.9); whether the factor m_e is needed is open (Section 10). V1(b) holds for tests of whole episodes (sets of pairs (environment, transcript)), by the proof of V1(b) with episodes as calls; I do not state it separately.

**Example 1.10 (single messages asked in mid-episode: reading is not living). NEW.** Let the scaffold consist of one episode of two messages. The human of the human system answers the first message with "done" and privately draws a fair bit b; the second message asks for the bit, and the human answers b. A freshly reset human who is shown the text (o_1, "done", o_2) answers "?", having drawn no bit. So P^vis(·|(o_1, "done", o_2)) is uniform on {0, 1} and P^read(·|(o_1, "done", o_2)) is the point mass at "?". If rehearsal puts single calls to the human (Protocol R on the scaffold with calls as units), every answer to a second message is a draw from P^read. A1 holds for the sampler P_cold that equals P^vis on opening messages and P^read on longer histories; R1, R3 and V1 are true of Q_{P_cold}; and TV(Q_{P_cold}, Q_{P^vis}) = 1. The data of single cold calls are the same for this human and for a human with transparent memory and the kernel P_cold. Protocol R^ep, which asks the episode as a whole, learns P^vis. The same happens whenever work done during an earlier message is not on the page: a human who answered "I have a proof" after long thought can write the proof down; a reader of that sentence cannot.

### 1.3 A human who changes during rehearsal

**Theorem 1.11 (a moving human: regret against the best fixed sampler). NEW.** Under the hypotheses of Lemma 0.2 (no A1, no A2; the human of round t is a random kernel P_t that may depend on everything that happened in earlier rounds), for every ν ∈ H and for T uniform on {1, …, n},

  E[Σ_{j ≤ len(τ_T)} KL(P_T ‖ M^(T))(x_{T,j})] ≤ L·ln(W/w(ν))/n + (1/n)·Σ_{t ≤ n} E[Σ_{j ≤ len(τ_t)} KL(P_t ‖ ν)(x_{t,j})].

*Proof.* Lemma 0.2 divided by n. ∎

*What it says.* The mixture of a uniformly random round is, along its own run, close to *the human of that round*, up to the complexity of ν over n and the average divergence of the best fixed sampler ν from the moving human along the same runs. A human with memory across rehearsal questions is covered (P_t may depend on the earlier questions and answers). *What it does not say.* Nothing about the human of any other date, in particular not the human of the day of deployment; and the second term does not shrink with n when the human keeps moving.

**Corollary 1.12 (bounded drift; rehearsing longer can make the guarantee worse). NEW.** Let Y be finite with s elements. For η ∈ (0, 1) and a sampler ν let ν^η := (1 − η)·ν + η·(uniform distribution on Y), and let H^η := {ν^η : ν ∈ H} with w(ν^η) := w(ν). Let P° ∈ H be a sampler (the human at a reference date), K° := log₂(1/w(P°)), and suppose TV(P_t(·|x), P°(·|x)) ≤ γ_t for all x and t, almost surely; γ̄ := (1/n)Σ_t γ_t. Run Protocol R with the class H^η under the hypotheses of Lemma 0.2. Then, with κ := K° ln 2/n + ln(1/(1 − η)) + γ̄·(1 + ln(s/η)),

  E[Σ_{j ≤ len(τ_T)} KL(P_T ‖ M^(T))(x_{T,j})] ≤ L·κ  and  E[Σ_{j ≤ len(τ_T)} TV(P°, M^(T))(x_{T,j})] ≤ L·(γ̄ + √(κ/2)).

For a drift that is linear in time, γ_t = γ·t, we have γ̄ = γ(n + 1)/2, and κ is decreasing in n up to n* := √(2K° ln 2/(γ·(1 + ln(s/η)))) and increasing afterwards.

*Proof.* Let p, ν be distributions on Y, a := TV(p, ν) and q := ν^η. Write p = (1 − a)·r + a·r′ with r := min(p, ν)/(1 − a) and r′ := (p − ν)⁺/a (if a ∈ {0, 1} only one part is present). KL(· ‖ q) is convex, r/q ≤ 1/((1 − a)(1 − η)) on the support of r because r ≤ ν/(1 − a) and q ≥ (1 − η)ν, and r′/q ≤ s/η because q ≥ η/s. So KL(p ‖ q) ≤ (1 − a)·ln(1/((1 − a)(1 − η))) + a·ln(s/η) ≤ ln(1/(1 − η)) + a·(1 + ln(s/η)), using (1 − a)·ln(1/(1 − a)) ≤ a. Hence KL(P_t ‖ (P°)^η)(x) ≤ ln(1/(1 − η)) + γ_t(1 + ln(s/η)) for all x, and Theorem 1.11 with ν = (P°)^η gives the first bound. For the second, TV(P°, M^(T)) ≤ TV(P°, P_T) + TV(P_T, M^(T)) ≤ γ_T + √(KL(P_T ‖ M^(T))/2) at every input, and E Σ_{j ≤ len} √(k_j/2) ≤ √(L·E Σ_j k_j/2) ≤ L·√(κ/2) by the Cauchy–Schwarz and Jensen inequalities. The last claim is the derivative of K° ln 2/n + γ(n + 1)(1 + ln(s/η))/2. ∎

A bound that grows with n does not prove that the error grows. Section 9, part 7, shows that it does in an example: the distance between the deployed mixture and the human of the first round falls until n ≈ 300 and then rises.

**Example 1.13 (without smoothing, one changed answer destroys a class of functions). NEW.** Let H = {f, g} be two functions with f(x₀) ≠ g(x₀), and let the human answer like f in rounds t < t₀ and like g afterwards. If x₀ is asked once before t₀ and once after, both members have likelihood 0, ξ(D) = 0 and the posterior is undefined. In (0.4) the right side is infinite for both members, so nothing is contradicted. A class meant for a human who may change has to give every answer positive probability, as H^η does.

**Proposition 1.14 (the date is a guard). PROVED.** Let a *moving human* be a sequence (P_t)_{t ≥ 1} of samplers, a question at time t being answered by a fresh draw from P_t. Let two moving humans (P_t) and (P′_t) satisfy P_t = P′_t for t ≤ n, while P_{n+1}(·|x) and P′_{n+1}(·|x) have disjoint supports for some x. Then for every protocol whose questions are asked at times 1, …, n and every way of answering x at time n + 1, for one of the two humans the answer lies in the support of that human's P_{n+1}(·|x) with probability at most 1/2.

*Proof.* All questions are answered by the same kernels under both humans, so the law of the data, and of the answer at x, is the same. The two supports are disjoint, so the two probabilities of landing in the respective support sum to at most 1. ∎

So what a protocol can promise about the human *after* the last question rests on an assumption about how the human moves; the theorems promise something only about the humans who answered.

### 1.4 A human who knows that no run depends on the answer; a human who reads what the imitator wrote

**Proposition 1.15 (the human of rehearsal is the only human the protocol sees). NEW.** Let the human's answer depend on the input x and on a *context* c that the human perceives and that is not part of x: the answer to x in context c is a fresh draw from P(·|x, c). Let all questions of rehearsal and validation be answered in one context c_reh.

(a) Every theorem that assumes A1 holds with P := P(·|·, c_reh), and the human system it is about is Q_{P(·|·, c_reh)}: the system of humans who answer as in rehearsal.

(b) Let c′ ≠ c_reh, and let P, P′ be two humans with P(·|·, c_reh) = P′(·|·, c_reh). For every protocol whose questions are answered in context c_reh, the law of the deployed run is the same for both; so it is at total variation at least TV(Q_{P(·|·,c′)}, Q_{P′(·|·,c′)})/2 from one of the two systems of humans in context c′.

(c) Consider the variant of Protocol R in which the human's answer to call J_t is put into the run in place of the mixture's answer and the run continues from it. The bound (0.4), and with it R1, holds for this variant unchanged.

*Proof.* (a) A1 holds for P(·|·, c_reh). (b) The data have the same law under P and P′; then the triangle inequality. (c) The question of round t is the input of call J_t of a run whose calls before J_t were answered by M^(t). For every j, the pair (1[j ≤ len], x_j) is a function of (z, ρ) and of the answers to calls 1, …, j − 1, so it has the same joint law with 𝓕_{t−1} as in a run answered by M^(t) throughout. Hence E[a_t·g(x_t) | 𝓕_{t−1}] = (1/L)·E_{Q_{M^(t)}}[Σ_{j ≤ len} g(x_j)] for every nonnegative g fixed by 𝓕_{t−1}, which is (0.5) after conditioning on 𝓕_{t−1}; the proof of Lemma 0.2 goes through, with the sums taken along runs of M^(t). ∎

*Reading.* If the human answers a rehearsal question differently because no run depends on it, the object that the protocol imitates is still well defined: it is the system in which every call is answered by the human of rehearsal. No other human system is available to any protocol that takes the human out of the loop, because the human "whose answer is used" never answers once deployment has begun; by (b) that human is a counterfactual that the data do not reach. So the human system of the theorems is the right object by construction, and the open question is one of design: what the human is told. Part (c) shows one honest design in which a run does depend on every answer. Whether the outcome of a rehearsal run should ever be used is another matter (the early mixtures are the prior).

**Proposition 1.16 (the human reads questions that the imitator helped to write). PROVED (observation of `research/understand/alignment-proposals.md`, Section 6.1).** Under A1, A2, A3 and for a deterministic human, call the question of round t *tainted* if an earlier call of the run τ_t was unfaithful (an untainted question is the question that the human system would have asked at that position on the same (z, ρ)). The expected number of rounds with a tainted question, over the whole of rehearsal, is at most L·K ln 2.

*Proof.* The question of round t is tainted only if τ_t has an unfaithful call, which has probability at most the expected number of unfaithful calls of τ_t; by R1 these expectations sum to at most L·K ln 2. ∎

The bound does not grow with n, but it is of the size of the whole error budget, and the first rounds are driven by the prior. A1 assumes that reading such a question does not change the human. If it does, P_t moves and Theorem 1.11 is what remains.

## 2. A2: the human is in the class

### 2.1 The theorems without A2

**Theorem 2.1 (L3 and R1 without A2; the exact price with A2). PROVED ((a) is the form recorded in `research/prove/rehearsal-core.md`, Remark 4.4(c), and `research/prove-b/hellinger-runs.md`, Appendix A; (b) is NEW).** Assume A1.

(a) For questions chosen as in Lemma 0.1 and every ν ∈ H,

  Σ_{t ≤ n} E[a_t·KL(P ‖ M_{D_{t−1}})(x_t)] ≤ ln(W/w(ν)) + Σ_{t ≤ n} E[a_t·KL(P ‖ ν)(x_t)].

Under Protocol R with A3(i) and A3(iv), for every ν ∈ H,

  Σ_{t ≤ n} E Λ(M^(t)) ≤ L·ln(W/w(ν)) + Σ_{t ≤ n} E[E_{Q_{M^(t)}} Σ_j KL(P ‖ ν)(x_j)],

so E Λ(M^(T)) ≤ inf_{ν ∈ H} {L·ln(W/w(ν))/n + ā_n(ν)}, where ā_n(ν) := (1/n)·Σ_t E[E_{Q_{M^(t)}} Σ_j KL(P ‖ ν)(x_j)] is the divergence of ν from the human summed along the runs of the mixtures, averaged over the rounds.

(b) If also A2 holds, then for questions chosen as in Lemma 0.1,

  Σ_{t ≤ n} E[a_t·KL(P ‖ M_{D_{t−1}})(x_t)] = ln(W/w(P)) − E[ln(1/w_{D_n}(P))],

and, if the members of H are samplers, this number is the divergence KL(ℙ_P ‖ ℙ_w) between the law ℙ_P of everything the protocol sees when the human is P and its law ℙ_w when the human is drawn from w/W before the first question. Under Protocol R, Σ_t E Λ(M^(t)) = L·(ln(W/w(P)) − E[ln(1/w_{D_n}(P))]).

*Proof.* (a) Lemma 0.1 with p_t = P(·|x_t) (A1), and Lemma 0.2 with P_t = P. (b) By (0.2), Σ_t a_t ln(P(y_t|x_t)/M_{D_{t−1}}(y_t|x_t)) = ln(W·P(D_n)/ξ(D_n)) = ln(W/w(P)) + ln w_{D_n}(P) almost surely; the summands are integrable with conditional expectations a_t·KL(P ‖ M_{D_{t−1}})(x_t) (proof of Lemma 0.1). For the second description: the protocol chooses its questions by the same rule whoever the human is, so the density of (coins of the protocol, D_n) under a human ν′ is a factor that does not depend on ν′ times ν′(D_n); under a human drawn from w/W it is the same factor times ξ(D_n)/W. The logarithm of the ratio is ln(W·P(D_n)/ξ(D_n)). For Protocol R use (0.5). ∎

*What (a) gives.* An oracle inequality: the deployed imitator does, on its own runs, as well as the best trade-off between the complexity of a member and its divergence from the human. This is the form of the guarantee of Ross, Gordon and Bagnell for training on the learner's own distribution: their bound is relative to "the true loss of the best policy in hindsight", ε_N := min_π (1/N)Σ_i E_{s∼d_{π_i}}[ℓ(s, π)], an average over the state distributions d_{π_i} of the learner's iterates (S. Ross, G. J. Gordon, J. A. Bagnell, "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning", AISTATS 2011, PMLR 15:627–635; quoted from the digest `research/understand/imitation-theory.md`, Section 3.2, whose author read the arXiv source; not read by me).

*What (a) does not give.* (1) The approximation term ā_n(ν) is measured where the *mixtures* go, not where the human system goes. A member that is exact on every input of the human system can have ā_n(ν) = ∞, and then the bound says nothing about it; Example 2.3 shows that this is how the protocol behaves, not a defect of the proof. (2) The term does not shrink with n. (3) If every member gives probability zero to some answer that the human gives at an input the mixtures reach, the right side is infinite for every ν and the posterior can become undefined.

*What (b) says.* The price paid by rehearsal is exactly L times the information that the answers carry about which member the human is: the prior surprise K ln 2 minus the expected surprise ln(1/w_{D_n}(P)) that remains. The bound L·K ln 2 is attained in the limit exactly when the posterior weight of P tends to 1. For a deterministic human the amount spent so far, ln(W/ξ(D_n)) = Σ_t a_t·(−ln M^(t)(y_t|x_t)), is the cumulative log loss of the mixture and can be read off the data; the amount that remains cannot.

**Proposition 2.2 (A2 is needed only on the inputs the scaffold can produce). NEW.** Let X_Π ⊆ X contain every input that occurs in some run of Π under some answers. Let [P]_Π := {ν ∈ H : ν(·|x) = P(·|x) for all x ∈ X_Π}, w_Π := w([P]_Π) and K_Π := log₂(1/w_Π). If w_Π > 0 (P itself need not be in H), then Theorem R1 holds with K_Π in place of K, and so does every statement derived from R1 through the bound Σ_t E Λ(M^(t)) ≤ L·K ln 2.

*Proof.* Every question of Protocol R lies in X_Π, so ξ(D_n) ≥ Σ_{ν ∈ [P]_Π} w(ν)ν(D_n) = w_Π·P(D_n). The proof of Lemma 0.1 uses the member ν only through the inequality ξ(D_n) ≥ w(ν)ν(D_n); replace it by this one. ∎

K_Π ≤ K, and it can be far smaller: in the class of all programs, K_Π is at most the length of the shortest program whose kernel agrees with the human on X_Π, whatever the human does elsewhere. The quantity that the theorems charge for is the complexity of the human's behaviour *inside the closed system*.

**Example 2.3 (without A2, the member that imitates the human system exactly is destroyed where only the mixture goes). NEW.** X = {a, b}, Y = {0, 1}. The scaffold asks a; if the answer is 1 it asks b; then it stops (L = 2). The human is the function f ≡ 0, so the human system makes one call, at a, with answer 0. H = {ν₁, ν₂} with w(ν₁) = w(ν₂) = 1/2, where ν₁ answers 0 at a and 1 at b, and ν₂ answers a fair bit at a and 0 at b. The human is not in H. The run law of ν₁ *is* the human system: Q_{ν₁} = Q_f. The run law of ν₂ is at total variation 1/2 from it. Under Protocol R:

* While ν₁ is alive and a has been asked k times, the posterior weight of ν₂ is ω_k := 1/(1 + 2^k). In a round, with probability 1/2 the call a is asked (k grows by one); with probability ω_k/4 the mixture answers 1 at a and the call b is asked: the human answers 0 and ν₁ has likelihood zero from then on; otherwise nothing is asked.
* Hence Pr[ν₁ is never refuted] = Π_{k ≥ 0} 2/(2 + ω_k) = 0.556481, and Pr[ν₁ is refuted] = 0.443519 (Section 9, part 1: exact product, exact recursion, simulation 0.4432 ± 0.0011).
* After ν₁ is refuted the imitator is ν₂ for ever. So the run of the mixture after n rounds differs from the human system with probability tending to 0.2218, not to 0, although H contains a member whose runs are exactly the human system's.
* Theorem 2.1(a) is not violated: for ν₁ the right side is infinite (KL(f ‖ ν₁)(b) = ∞, and the mixtures reach b with positive probability); for ν₂ it is 2 ln 2 + n ln 2.

So without A2 the protocol can end, with probability bounded away from zero, at the worst member of the class while the best is perfect on the human system. Proposition 2.2 shows what would have saved ν₁: agreement with the human on *all* of X_Π, the inputs that wrong answers lead to included.

### 2.2 Why the factor K cannot be avoided, and what a prior built from knowledge changes

**Proposition 2.4 (K is the number of candidates the prior takes seriously). PROVED; (c) quotes `research/prove/lower-bounds.md`, Theorem 3.1.**

(a) For every class with weights and every k, at most 2^k members have log₂(1/w(ν)) ≤ k.

(b) For every finite set S of members, (1/|S|)·Σ_{ν ∈ S} log₂(1/w(ν)) ≥ log₂|S|.

(c) For all integers m_b ≥ 1 and L ≥ 1 and every δ ≤ 1/20 with N := L/(2δ) an integer there are a set S of 2^K functions, K = m_b·log₂N, and a scaffold with L calls such that every protocol (any way of choosing questions, any computation, any deployed answerer, any prior) whose deployed outcome is right with probability at least 1 − δ for every member of S asks at least (1 − 10δ)·K·L/(8δ·log₂(L/(2δ))) questions in expectation when the human is drawn uniformly from S.

(d) All theorems of the note hold for every prior that satisfies A3(iii). If the prior is the posterior w_{D′} of a prior w after earlier answers D′ of the same human, obtained under A1, then its K is K′ = K − log₂(w_{D′}(P)/w(P)).

*Proof.* (a) Σ_ν w(ν) ≤ 1. (b) By Jensen's inequality the left side is at least log₂(|S|/Σ_{ν ∈ S} w(ν)). (c) is the cited theorem. (d) The proofs use nothing about w but Σ w ≤ 1 and that it is not random; the second sentence is the definition of the posterior. ∎

*Reading.* A prior built from existing knowledge can make K small for the humans it favours. It cannot do so for many: by (a) and (b) the average of K over any 2^k candidates is at least k under every prior. And (c) says that this is not a weakness of the Bayes mixture: when 2^K candidates remain possible, some of them cost of the order of K·L/(δ·log(L/δ)) questions under every protocol. So "K" in the theorems can be replaced by "the logarithm of the number of humans that the prior, with all knowledge built in, still cannot tell apart on the inputs of the closed system" (Proposition 2.2 for the last clause), and by nothing smaller in the worst case. Theorem 6.1 below gives the corresponding lower bound under low stakes.

### 2.3 The certificate needs neither A2 nor a deterministic human

**Proposition 2.5 (V1(a) without its hypotheses). MODIFIED (the hypothesis "deterministic human" of V1(a) is removed; A2 is not used, as the note says).** Let A be any answerer, frozen. Let the human satisfy A1 during validation, for some sampler P that need not belong to any class. In each of m validation rounds a run of A is generated, J is drawn uniformly from {1, …, L} (A3(i)), and if the run has a J-th call the human answers its input; let V = 1 if this happened and the human's answer differs from the answer A gave at that call, and V = 0 otherwise. Then V_1, …, V_m are independent with one mean ρ′, and

  β(A)/L ≤ ρ′ = (1/L)·E_{Q_A} Σ_j (1 − Σ_y A_j(y|h_j)·P(y|x_j)),

where β(A) = E_{Q_A} Σ_j TV(A_j(·|h_j), P(·|x_j)) is the expected number of unfaithful calls of a run of A. Hence:

(a) if no mismatch occurs, then with confidence 1 − δ, β(A) ≤ L·ln(1/δ)/m, and Theorem R3 applies with this β;

(b) in general, with confidence 1 − δ, β(A)/L ≤ V̄ + √(ln(1/δ)/(2m)), where V̄ is the observed frequency of mismatches;

(c) ρ′ = β(A)/L if the human is deterministic; for every human ρ′ ≥ (1/L)·E_{Q_A} Σ_j (1 − max_y P(y|x_j)), whatever A is.

*Proof.* A is frozen and the human answers with fresh coins, so the rounds are independent and identically distributed. Given the run, the human's answer to x_j is a draw from P(·|x_j) that is independent of the answer y_j ~ A_j(·|h_j) used in the run; the two differ with probability 1 − Σ_y A_j(y|h_j)P(y|x_j) ≥ 1 − Σ_y min(A_j(y|h_j), P(y|x_j)) = TV(A_j(·|h_j), P(·|x_j)). Average over the uniform J. (a) If β(A) > L ln(1/δ)/m then ρ′ > ln(1/δ)/m and Pr[no mismatch] = (1 − ρ′)^m < δ. (b) Hoeffding's inequality. (c) For a deterministic human P(·|x) is a point mass and the two expressions coincide; in general Σ_y A(y)P(y) ≤ max_y P(y). ∎

So the certificate with no mismatch is valid without assuming that the human is deterministic. Determinism is needed only for the certificate to be *attainable*: by (c) the mismatch rate cannot be small unless the human's answers are nearly determined on the inputs that A visits.

**Remark 2.6 (what repeated questions certify for a human who is not deterministic). NEW.** The note says of such a human that "each input is seen once, so P(·|x) is not observable at any single x" and that only frequencies of tests can be estimated. Under A1 the human can be asked the same input twice, and this gives more. For a frozen sampler A and the input x of a uniformly chosen call of a run of A, let ρ_AP be the probability that A's answer differs from a human answer, ρ_PP the probability that two independent human answers to x differ, and ρ_AA the probability that two independent answers of A to x differ (computable without the human). Then

  E_x[Σ_y (A(y|x) − P(y|x))²] = 2ρ_AP − ρ_AA − ρ_PP,

because for a fixed x the three probabilities are 1 − Σ_y A·P, 1 − Σ_y P² and 1 − Σ_y A². So 2m human answers (two per chosen call) estimate the mean squared L₂ distance between A and the human on A's own inputs to within O(1/√m), with no family of tests. The L₂ distance is weak for answers spread over many values, and repeated questions need A1 in full: a human who remembers the first answer repeats it.

## 3. A3: the protocol's coins, and the referent test

### 3.1 What a hypothesis about the making of the data set can and cannot do

The referent test asks whether a hypothesis that models how the data set was made does as well as the intended one. The researcher's form of the worry: "if the shortest program looks at you having made the data set, then you are probably screwed" (`research/understand/notes.md`, F9). Two kinds of object must be kept apart.

**Definition 3.1.** (a) A *guard* is a member of H of the form "the human on X ∖ Q, something else on Q", for a set Q ⊆ X. A hypothesis that models the making of the data set and wants to fit the data and deviate elsewhere is a guard whose Q is the set of inputs that, by its model, are not put to the human. As a member of H it is a kernel in x alone: whatever it computes about the world or the experiment, its answer at a call depends on the string x. (b) A *family indexed by the coins* is a map c ↦ ν_c from the possible values of some random element c* of the experiment (for example the sequence of asked indices J_1, …, J_n, or the whole data set) into H; ν_{c*} is "the hypothesis that knows how this data set was made".

**Theorem 3.2 (the referent test under A3). NEW.**

(a) *No property is new at deployment.* Assume A3(i) and A3(ii); the human may be any process. For every set Q ⊆ X,

  Pr[the run of round T has a call with input in Q, and no question of rounds 1, …, T − 1 lay in Q] ≤ L/n,

and the same holds for the deployed run of M^(T) in place of the run of round T. In particular, for a deterministic human f and a function g ∈ H, the probability that g is still unrefuted before round T and the deployed run reaches an input at which g differs from f is at most L/n, whatever the weight of g.

(b) *A fixed hypothesis loses weight at the rate at which it deviates on the mixtures' runs.* Assume A1, A3(i), A3(iv). For ν ∈ H let d_t(ν) := (1/L)·E_{Q_{M^(t)}}[Σ_j H²(P, ν)(x_j)], an 𝓕_{t−1}-measurable number. For every δ ∈ (0, 1), with probability at least 1 − δ, simultaneously for all n,

  ν(D_n)/P(D_n) ≤ δ^(−2)·exp(−2·Σ_{t ≤ n} d_t(ν)),

so the posterior odds of ν against P are at most (w(ν)/w(P))·δ^(−2)·exp(−2Σ_{t ≤ n} d_t(ν)) when P ∈ H.

(c) *A prior fixed in advance cannot anticipate fresh coins.* Assume A3(iii). For every family c ↦ ν_c indexed by a random element c*, E[w(ν_{c*})] ≤ max_ν Pr[ν_{c*} = ν].

*Proof.* (a) Let A_t be the event that no question of rounds 1, …, t − 1 lay in Q; A_t ∈ 𝓕_{t−1}. Let v_t := Pr[τ_t has a call with input in Q | 𝓕_{t−1}] and p_t := Pr[a_t = 1, x_t ∈ Q | 𝓕_{t−1}]. By (0.5) with g = 1_Q, p_t is 1/L times the conditional expected number of calls of τ_t with input in Q, so p_t ≥ v_t/L. Since 1_{A_{t+1}} = 1_{A_t}·(1 − 1[a_t = 1, x_t ∈ Q]), E[1_{A_t}·p_t] = Pr[A_t] − Pr[A_{t+1}]. Hence Σ_{t ≤ n} E[1_{A_t}·v_t] ≤ L·Σ_t (Pr[A_t] − Pr[A_{t+1}]) ≤ L. T is uniform and independent, so the probability in question is (1/n)·Σ_t E[1_{A_t}·v_t] ≤ L/n. Given 𝓕_{T−1} the deployed run has the law of τ_T (A3(ii)), so the same computation applies to it. For the last sentence take Q := {x : g(x) ≠ f(x)}: the first question in Q refutes g.

(b) Let R_n := √(ν(D_n)/P(D_n)) (defined almost surely). On {a_t = 1}, E[√(ν(y_t|x_t)/P(y_t|x_t)) | 𝓖_t] = Σ_y √(ν(y|x_t)P(y|x_t)) = 1 − H²(P, ν)(x_t), so by (0.5), E[R_t | 𝓕_{t−1}] = R_{t−1}·(1 − d_t(ν)) ≤ R_{t−1}·e^(−d_t(ν)). Thus G_n := R_n·exp(Σ_{t ≤ n} d_t(ν)) is a nonnegative supermartingale with G_0 = 1, and Pr[sup_n G_n ≥ 1/δ] ≤ δ by Ville's inequality. Square.

(c) E[w(ν_{c*})] = Σ_ν w(ν)·Pr[ν_{c*} = ν] ≤ max_ν Pr[ν_{c*} = ν]·Σ_ν w(ν), because w is not random. ∎

*Reading.* (a) is the guard test in its sharpest form, and it uses the coins of the protocol only: any property that a hypothesis could key on, simple or not, known to us or not, has either been met by a question, or is met by the deployed run with probability at most L/n in total. It is the random-stopping argument of the researcher's notes (`research/understand/notes.md`, Q14) applied to the round T. Section 9, part 3, shows that L/n is attained up to a factor close to 1. (b) says that modelling the experiment buys a hypothesis nothing on the asked calls: by (0.5) its deviation at the asked call is its average deviation over the calls of the run. With R1 this is "covered by R1": the total effect of all such hypotheses on the mixture is bounded by K ln 2 whatever their weights. (c) is about the other kind of object. The hypothesis that knows the realised coins exists in the class of all programs, but a prior chosen before the coins were drawn gives it, on average, at most the probability of guessing them: L^(−n) for the sequence J_1, …, J_n of full-length runs. If all the coins come from a uniformly drawn seed of k bits the same bound is only 2^(−k), however large n is.

**What the note's wording of A3 adds, and what it leaves out.** "Not predictable by any hypothesis" is not used by any proof: a hypothesis is a kernel in x, and by A3(iv) the string x does not show whether the call is the asked one. What the proofs use, and the note does not say, is A3(i) (uniform *given the run*, which fails for a call index computed from the run), A3(ii) (the deployed run is a further sample), A3(iii) (the prior is fixed first) and A3(iv). The four examples that follow show that each is needed.

### 3.2 Failures

**Example 3.3 (the asked call is computed from the run by a short seed: R1 fails). NEW; R1 is REFUTED without A3(i).** Let k ≥ 1 and L ≥ 2. The top-level input is z = (z_σ)_{σ ∈ {0,1}^k}, a list of 2^k independent uniform elements of {1, …, L}; a run has exactly L calls, with inputs (z, 1), …, (z, L). The human is f ≡ 0. H consists of f with weight 1/2 and, for every σ ∈ {0,1}^k, of the function ν_σ with ν_σ(z, j) := 0 if j = z_σ and 1 otherwise, with weight 2^(−k−1). So A1 and A2 hold and K = 1. Fix a seed s ∈ {0,1}^k and let the protocol ask the call J_t := z_{t,s}: a function of the run and of the seed. Marginally J_t is uniform; given the run it is determined, so A3(i) fails.

* ν_s agrees with the human at every asked call and is never refuted. A seed σ ≠ s survives a round exactly if z_{t,σ} = z_{t,s}, which has probability 1/L, independently over rounds and seeds.
* If A_t is the set of seeds alive before round t, the posterior weight of each is 1/(2^k + |A_t|), and the expected number of unfaithful calls of the run of round t is (L − 1)·E[|A_t|/(2^k + |A_t|)] ≥ (L − 1)/(2^k + 1), because s ∈ A_t.
* So the deployed run has at least (L − 1)/(2^k + 1) unfaithful calls in expectation for every n, while the conclusion of R1 would be at most L·ln 2/n.
* With fresh coins (J_t uniform and independent of z_t) every seed, s included, survives a round with probability 1/L, and the expected number of unfaithful calls of round t is (L − 1)·E[|A_t|/(2^k + |A_t|)] with |A_t| binomial (2^k, L^(−(t−1))), which tends to 0.

Numbers for k = 3, L = 4 (Section 9, part 2): with the seed the expected number of unfaithful calls per run is 0.3506 at n = 100 and 0.3351 at n = 1000 (limit 1/3); with fresh coins it is 0.0228 and 0.0023, below the bounds 0.0277 and 0.0028 of R1.

The floor 2^(−k) is negligible for a long seed *under this prior*. It is not negligible under a prior that favours ν_s, and Theorem 3.2(c) says that no prior fixed in advance can favour the hypothesis that knows fresh coins. That is the difference between a seed and physical randomness. The example needs the inputs of a run to identify the run (here through z); inputs that quote their task do.

**Example 3.4 (the top-level task of the real run is not a draw from the rehearsed law). NEW.** Let every input contain its top-level input z, let every run have L calls, and let the real run be on a task z* with D₀(z*) = p. Let H = {f, g} with f the human, g := b ≠ f on the inputs that contain z* and g := f elsewhere, and w(g) = η = 1 − w(f). The guard g is refuted exactly when a rehearsal run is on z*, so it is alive before round t with probability (1 − p)^(t−1), and

  E[fraction of unfaithful calls of the deployed run | it is on z*] = η·(1 − (1 − p)^n)/(n·p) for p > 0, and = η for p = 0.

For p ≪ 1/n this is about η, whatever n: the answers of the human on other tasks say nothing about z*. For η = 1/2 and n = 10⁴ the value is 0.4975 at p = 10⁻⁶, 0.3161 at p = 1/n and 0.0005 at p = 0.1 (Section 9, part 4). This is A3(ii) failing: the real run was not one more sample. The remedy inside the framing is to rehearse the real task itself (D₀ the point mass at z*, the runs differing in ρ and in the imitator's coins), or to *draw* the real task from D₀.

**Example 3.5 (a time stamp). NEW.** Let every input carry the date, let every run have L calls, let rehearsal round t take place at date t, and let the imitator be used at a date d > n. Let H contain the human f with weight 1/2 and, for every θ ≥ 1, the guard g_θ that answers like f before date θ and differently from date θ on, with weight (1/2)/(θ(θ + 1)). After n rounds the guards with θ ≤ n are refuted and those with θ > n are untouched, with total weight (1/2)/(n + 1). At date d a call is unfaithful with probability

  (1/(n + 1) − 1/(d + 1))/(1 + 1/(n + 1)),

which is about 1/n² for d = n + 1, about 1/(2n) for d = 2n + 1 and about 1/n for large d; all L calls of a run fail together. Under this prior the damage is of the order of the bound of R1. But R1 does not apply (the deployed inputs have a property that no rehearsed input had), and the outcome is a fact about the prior: add one guard of weight 0.01 at a special date θ₀ > n, and every call at a date d ≥ θ₀ is unfaithful with probability at least 0.0194, for every n < θ₀ (Section 9, part 4). The first computation is the researcher's remark on the exception clause for "the next moment" (`notes.md`, F4): the clause for date n + 1 costs about 2 log₂ n bits here, which is why it is harmless; nothing forces a prior to charge that much for a date that is simple to name.

**Example 3.6 (a prior that has seen the rehearsal data). NEW.** Let the inputs of the scaffold never repeat, and let w′ := (1/2)·w + (1/2)·(point mass at mem_D), where D is the data of rehearsal and mem_D answers as recorded at the inputs of D and gives a fixed answer b elsewhere. This prior violates A3(iii). The likelihood of D under mem_D is 1, so the posterior of w′ given D gives mem_D weight at least 1/2, and the imitator answers b at a fresh input with probability at least 1/2. A learned prior whose training material contains the rehearsal transcripts is an instance. "Existing knowledge" in Proposition 2.4(d) has to mean: existing before the coins of the protocol were drawn.

## 4. Closed systems

### 4.1 The definition

**Definition 4.1 (closed deployment).** Fix a scaffold Π with its laws D₀ and λ, and a protocol that ends by freezing an answerer A (which may depend on everything the protocol saw) and then *deploys* it: the deployed run is the run of Π answered by A on a pair (z*, ρ*). The deployment is **closed** if:

* **(C1) one more sample:** conditionally on everything the protocol saw and did before deployment, (z*, ρ*) has the law D₀ ⊗ λ, and the coins of A in the deployed run are fresh;
* **(C2) sampling in advance:** before deployment the protocol can generate, for every answerer B that it can run and as often as it likes, runs of Π answered by B on fresh pairs (z, ρ) with the law D₀ ⊗ λ, independent of (z*, ρ*);
* **(C3) nothing else gets in:** the inputs of the deployed run are the strings next_j(z*, ρ*, y_1, …, y_{j−1}), and the answers depend on them and on A's coins alone: no clock, no mark that this run is the real one, no state of the world.

In one sentence: *the deployment is a rehearsal run that happens to count.*

The note's definition ("we can sample z and ρ ourselves, so that we can run it with any answerer we have, as often as we like, before the run that counts") is (C2) for sampling by computation. (C1) and (C3) are A3(ii); the note does not state them, and Examples 3.4 and 3.5 are what happens without them. The proofs use the three parts as follows. R1, R2 and R3 use (C2) with B = M^(t), to produce the runs of rehearsal, and (C1), (C3) to conclude that the deployed run of M^(T) has the law Q_{M^(T)} given the data. V1 uses (C2) with B = A and (C1), (C3). The lower bounds N1 and N2 are stated for closed deployments and hold a fortiori without closure.

(C2) asks neither for a computation nor for knowledge of D₀:

**Proposition 4.2 (a stock of exchangeable top-level inputs suffices). NEW.** Let z_1, …, z_{n+1} be exchangeable random elements that come from outside (their law may be unknown), independent of the coins of the protocol and of the human; let the protocol compute next_j and out and draw ρ itself. Run Protocol R with z_t as the top-level input of round t, and deploy M^(T), T uniform on {1, …, n}, on z_{n+1}. Under A1, A2, A3(i), A3(iv) the deployed run satisfies E[Σ_j KL(P ‖ M^(T))(x_j)] ≤ L·K ln 2/n, as in Theorem R1.

*Proof.* D_{t−1} is a function of z_1, …, z_{t−1} and of coins that are independent of all the z's. By exchangeability (D_{t−1}, z_t) and (D_{t−1}, z_{n+1}) have the same law. So the run of M^(t) on z_{n+1} with fresh ρ and fresh coins has the same joint law with D_{t−1} as τ_t, and the expected sum of KL(P ‖ M^(t)) along it equals E[Σ_j KL(P ‖ M^(t))(x_{t,j})]. Lemma 0.2 does not use the law of the top-level inputs; sum its conclusion over t and divide by n. ∎

So in Definition 4.1 the known law D₀ may be replaced by exchangeability of the top-level inputs of rehearsal, validation and deployment. Each input of the stock is used once. If the stock is finite and is sampled with replacement, the guarantee is for a top-level input drawn from the stock, not for a new one from its source.

### 4.2 Examples on both sides

| deployment | closed? | why |
|---|---|---|
| one fixed research question z*, worked on by a tree of calls with its own randomness; rehearsal runs are on z* itself | yes | D₀ is the point mass at z*; the run that counts differs from the others in ρ and in the imitator's coins only |
| a problem drawn from a generator that we run (theorems to prove, puzzles), the real problem being a further draw | yes | (C1), (C2) by computation |
| a scaffold acting in a simulated environment whose dynamics we compute and can reset | yes | the environment is part of ρ and next |
| tasks from a recorded stock of exchangeable tasks, each used once | yes | Proposition 4.2 |
| a scaffold that calls an outside resource which is stationary, can be reset, and is also called during rehearsal (a laboratory that repeats an experiment afresh) | yes, as far as stationarity and reset hold | the resource then supplies part of ρ; this is an assumption about the world |
| the same research question, rehearsed on other, easier questions | no | (C1) fails: Example 3.4 with p = 0 |
| a service that answers questions arriving from users | no | the top-level inputs have an unknown and moving law |
| any scaffold whose inputs contain the date, news, or the results of the system's earlier real runs | no | (C3) fails: Example 3.5; earlier real runs change later inputs |
| a scaffold that reads the world as it is on the day (the literature, markets, an experiment that cannot be repeated) | no | the world's answer cannot be sampled in advance |
| an imitator that is kept and used for new purposes after the rehearsed computation | no | each new use is a new scaffold; nothing was rehearsed |

The last row is the case the motivation has in mind ("run the upload at a thousand times speed"). A closed system is a computation fixed in advance, not a person to be consulted at will.

### 4.3 What the theory offers when the deployment is not closed

**Proposition 4.3 (an open system with the human on call). PROVED (Observation A of `research/understand/notes.md`, Section 6.2).** Let calls x_1, x_2, … arrive in any way; they may depend on the past, on the world and on the system's own answers. At each call, after x_t is fixed, a coin c_t with Pr[c_t = 1] = q is flipped independently of the past and of x_t. If c_t = 1 the human answers (A1) and the pair is added to the data; if c_t = 0 the mixture of the data so far answers. Under A2, for every number 𝒯 of calls,

  E Σ_{t ≤ 𝒯} KL(P ‖ M_{D_{t−1}})(x_t) ≤ K ln 2/q,

the sum running over all calls, asked or not; for a deterministic human the expected number of calls at which the mixture answers wrongly is at most (1 − q)·K ln 2/q.

*Proof.* Lemma 0.1 with a_t = c_t and ν = P gives Σ_t E[c_t·κ_t] ≤ K ln 2 for κ_t := KL(P ‖ M_{D_{t−1}})(x_t). κ_t is fixed before the coin, so E[c_t κ_t] = q·E[κ_t]. For a function f the mixture's draw at x_t is wrong with probability 1 − M_{D_{t−1}}(f(x_t)|x_t) ≤ κ_t, and E[(1 − c_t)·κ_t] = (1 − q)·E[κ_t]. ∎

**Proposition 4.4 (the complete list). PROVED (each item is a statement proved here or quoted with its place).** For a deployment that is not closed the theory offers the following and nothing else.

1. *Where no question was asked, nothing.* If two members P, P′ of the class agree on a set A of inputs and the protocol asks outside A with probability γ, then for disjoint events G, G′ ("good for P", "good for P′") of the deployed run, the two failure probabilities sum to at least 1 − γ (`research/prove/lower-bounds.md`, Theorem 1.6). No amount of computation changes this.
2. *A bounded likelihood ratio.* If (C2) and (C3) hold and the top-level input of the deployed run has a law D′ with D′ ≤ B·D₀, then every guarantee of the form E_{z ~ D₀}[Φ(z)] ≤ ε for a function Φ ≥ 0 of the top-level input (the expected number of unfaithful calls given z, the probability of failure given z) becomes E_{z ~ D′}[Φ(z)] ≤ B·ε, since Σ_z D′(z)Φ(z) ≤ B·Σ_z D₀(z)Φ(z). Being ready for N task laws with disjoint supports costs a factor N in the number of questions, and this is necessary: an advantage η over a fair guess under each of N such laws needs n ≥ 2ηN questions (same file, Theorem 4.1).
3. *The human on call* (Proposition 4.3). An average divergence ε per call over 𝒯 calls costs K ln 2/ε questions in expectation, with q = K ln 2/(ε𝒯). The questions are spread over the whole period of use. The human never leaves: after the last possible question, item 1 and Proposition 1.14 apply to every later input of a new kind. This breaks the requirement that the human does not stay in the loop for ever; what the theory adds is that the human's load per call may fall as fast as the tolerated average error allows.
4. *Refusing at the top level.* The protocol knows what it rehearsed, so a top-level input outside the support of D₀ can be recognised by computation and refused. This is the one failure that the framing makes obvious without the human. Inside the support nothing separates the top-level inputs on which the imitator is good from the others: by Markov's inequality the set {z : Φ(z) > ε/η} has D₀-probability at most η, and an outside law may sit on it.
5. *The certificate certifies the rehearsed law only.* V1 is a statement about runs drawn as in validation.

## 5. The seven tests

The tests are those of `research/understand/notes.md`, Section 5, applied to the protocol "rehearse, validate, deploy" with Theorems R1, R3, V1 and the limits N1, N2. "Candidate" refers to Section 10 of `research/candidate-theory.md`.

| test | verdict | by |
|---|---|---|
| 1 guard | passed for a closed deployment of M^(T), for every property at once, with probability 1 − L/n; nothing is said about what happens at an input no question resembled; not passed for the last mixture, and not outside a closed deployment | Theorem 3.2(a); N1; Examples 3.4, 3.5 |
| 2 machine | passed by the certificate V1 and by Theorem 3.2(a), which contain no machine; R1 depends on the machine through K only, but K for a person is unknown on every machine; behaviour at inputs of rehearsal frequency below about 1/n is the machine's alone | Propositions 2.4, 2.5, 7.1; Theorem 3.2(a) |
| 3 referent | passed under A3(i) to (iv); each part is needed | Theorem 3.2; Examples 3.3 to 3.6 |
| 4 copy | not passed: the theorems are about a committee; a better predictor is assumed away by A1, and the mechanism is not decidable from question–answer data | Propositions 7.8 to 7.10 |
| 5 budget | not passed by the learning theorems for any prior under which K is of the size of a description of a person; passed by the certificate when calls are short and stakes are low | Section 6 |
| 6 rock | passed: no abstention inside the closed system; the price is that failures there are silent | Section 8, O5 |
| 7 horizon | outside the theorems; R3 and the budget make it harder | Corollary 6.2; Section 6.3 |

**1. Guard.** *Name an input property that no training input has, in particular one that task decomposition creates. What does the scheme do there, and with what probability?* For a closed deployment of the mixture of a uniformly random round the answer is Theorem 3.2(a): for every set Q of inputs, the probability that the deployed run meets Q before any question met Q is at most L/n. Task decomposition creates no property that is new at deployment, because the rehearsal run of round T is a decomposition carried out by the same imitator to the same depth. What the scheme *does* at an input with a property that no question had is whatever the prior says: with a universal prior a deviant behaviour b on Q keeps posterior weight at least 2^(−K(Q,b)−c) (`research/understand/repo.md`, D1), and R1 bounds only the expected number of such calls in a run. *Where the candidate overclaims.* (i) "A guard on a property of per-call frequency ρ survives n questions with probability (1 − ρ)^n" assumes one frequency for all rounds. The frequencies change as the mixture changes; the statement that holds for every history is Theorem 3.2(a). (ii) "No property separates deployment inputs from asked inputs in distribution" is true of the deployed run of M^(T) and the run of round T. It is false across rounds: inputs that only a good imitator produces are absent from the early rounds. The uniform choice of T is what covers this. For the last mixture M^(n+1) nothing of the kind is proved, and the summary table of `research/prove/rehearsal-core.md` announces (as its statement 6.2; the proof was not in the file when I read it) an example in which the last round is worse than the bound by a factor of order L. (iii) Outside a closed deployment the test is failed outright (Examples 3.4 and 3.5), as N1 requires.

**2. Machine.** *Is the answer to test 1 a fact about the scheme, or about the reference machine?* Two answers of the protocol are facts about the scheme: Theorem 3.2(a) and the certificate V1 hold for every class and every prior and do not mention a machine. R1 depends on the machine through K. A change of machine by a bits changes K by at most a, which is harmless as a statement and useless as a number: for a person K is not known to within any factor on any machine, and by Proposition 2.4 a prior can make K small only for the few humans it favours. What the scheme does on inputs that rehearsal meets with frequency below about 1/n is a fact about the machine alone: by D2 of `repo.md` some machine at distance K(Q, b) + c makes the deviant behaviour on such a Q more likely than not, and both machines satisfy R1 (Proposition 7.1). *The candidate* says "the machine enters R1–R4 only through K". This is true, and it is the place where the machine matters.

**3. Referent.** *Does a hypothesis that models how the data set was made do as well as the intended one?* On the asked calls it does at best as well, and it then agrees with the human on the calls of the mixtures' runs at large: Theorem 3.2(b). The reason is identity (0.5): the asked call is an unbiased sample of the run for every quantity fixed before the choice. The hypothesis that "knows" the realised coins has negligible prior weight if the prior was fixed first (Theorem 3.2(c)). Each of the four parts of A3 is needed: a call index computed from the run with a seed gives a floor of 2^(−k) that no amount of data lowers (Example 3.3); a real task outside the rehearsed law or a date in the input makes the guard unrefuted (Examples 3.4, 3.5); a prior that has seen the data memorises (Example 3.6). *The candidate's sentence* ("under A3 a hypothesis about how the data were made cannot tell an asked call from an unasked one") is right, for a reason other than the one given in its A3: not because the coins are "not computable by any hypothesis" but because a hypothesis sees x only and x is the same string in both cases. The test does not cover the human's own knowledge of the experiment (Proposition 1.15).

**4. Copy.** *Does anything in the theorem distinguish the sampler from a better predictor of it, or from the sampler with coins filled in?* No. R1 and R3 are about a mixture that is redrawn at every call; V1 is about any answerer whatever. Under A1 no predictor is better than the sampler on the asked calls (Proposition 7.9), so the first distinction is assumed away, not proved. The second is a fact about repeated questions (Proposition 7.10). Behaviour off the rehearsed law, which is where a copy and a predictor would differ, is not constrained by any data (Proposition 7.8). *The candidate's Section 9 overclaims twice.* "R4 and R6 give a single coherent program": R4 gives one posterior draw per run, a different program in each run, and is proved for functions; R6 is a sketch. "The selected program is a shortest program for the kernel on the rehearsal law (record, E5)": E5 of `repo.md` is for inputs drawn independently from one fixed law. In rehearsal the inputs come from mixtures that change from round to round, and the statement of the record that covers arbitrary input rules (E9(iv)) gives equivalence along the run only, without a rate.

**5. Budget.** *How many human answers, of what length, on which questions?* The answers are n single calls on the inputs of the imitator's runs, garbage of the early rounds included. With R3 and a deterministic human, n = K ln 2/(θδ); for a human who is not deterministic, n = K ln 2/(2θ²δ²) (`research/prove-b/hellinger-runs.md`, Section 8.2, item 3); without low stakes, n = L·K ln 2/δ, and for some simple classes no protocol manages with fewer than L/(4δ) − L (N2, in the form of `research/prove/lower-bounds.md`, Corollary 2.2). Section 6 puts numbers in: with one hour per answer a whole career pays for about 1.4·10³ bits of K at θ = δ = 0.1; with one year per answer, for less than one bit. Theorem 6.1 shows that the factor K remains under low stakes for every protocol. The certificate costs ln(1/δ_c)/(θδ) answers whatever K is: 300 for θ = δ = 0.1 at confidence 95%. *The candidate* gives the formula of the deterministic case only, calls the answers "single calls" without their length, and cites N2, which is the bound for critical calls; the bound that matches R3 is Theorem 6.1.

**6. Rock.** *Does the scheme still act on the inputs that matter, or does it abstain everywhere new?* It acts everywhere: Protocol R has no abstention. The price is the other desideratum. Inside the closed system the unfaithful calls are not marked, and since the class may contain hypotheses that place their deviations where they hurt, the unfaithful calls have to be taken as placed and written by an adversary; the fault model of R3 does this. What is obvious is a failed validation, while the human is still there, and a top-level input outside the rehearsed support (Proposition 4.4, item 4). *The candidate's* "no abstention is needed inside the closed system" is true of the average guarantee and is not an answer to "fails only obviously".

**7. Horizon.** *Granting perfect per-call imitation, does the scaffold do anything?* No theorem about the learner can say. Two results bear on it, both against. R3 asks the scaffold to survive answers replaced *arbitrarily*; a scaffold that gets this by replication has fewer than 1/(2θ) independent critical units, and in the family of Definition 6.0 the human answers needed per unit are the same as without replication (Corollary 6.2). And the budget of Section 6 can be met only with short calls, while the researcher's own estimate is that a research-capable episode may have to last a year (`notes.md`, Section 2.13). The scaffolds for which the protocol is affordable are the ones whose usefulness is in doubt.

## 6. The budget

### 6.1 The factor K under low stakes: a lower bound for every protocol

`research/prove/lower-bounds.md` proves the factor K for critical calls (its Theorem 3.1) and the factor 1/((2m + 1)δ) under fault tolerance for a class with K ≈ log₂(L/δ) (its Theorem 5.3); it leaves the factor K under fault tolerance open (its Section 5.3, item (i)). The two constructions combine.

**Definition 6.0 (replicated block class).** Let m_b, N, B ≥ 1 and m ≥ 0 be integers. X := [m_b] × [N] × [2m + 1], Y := {0, 1}. For a ∈ [N]^(m_b) let f_a(j, i, u) := 1[a_j = i]. The class is {f_a}, with 2^K members, K := m_b·log₂N, and uniform weights. The scaffold draws z = (J, R_1, …, R_B), J uniform on [m_b] and R_1, …, R_B independent and uniform on [N], and makes the L := B·(2m + 1) calls (J, R_b, u), b = 1, …, B, u = 1, …, 2m + 1, whatever the answers. Unit b has value 1 if at least m + 1 of its 2m + 1 answers equal 1; the outcome is the largest unit value. So the human system of f_a has outcome 1[a_J ∈ {R_1, …, R_B}]. A deployed system fails if its outcome (which may be "silent") differs from this.

**Theorem 6.1 (the factor K under fault tolerance). NEW.**

1. For every a, the human system of f_a tolerates m faults with failure 0: a rule that replaces at most m answers of a run, by anything and seeing everything, does not change the outcome.
2. For every protocol (questions anywhere in X, adaptive, randomised; any deployed system, which may see z and may be silent), with n the expected number of questions when a is uniform on [N]^(m_b), and p := 1 − (1 − 1/N)^B:

  N^(−m_b)·Σ_a Pr[failure when the human is f_a] ≥ p·(1 − 2B/N − 2n/(m_b·N)).

3. If the failure probability is at most δ for every member and N = B/(2δ) is an integer, then

  n ≥ (1 − 10δ)·m_b·B/(8δ) = (1 − 10δ)·K·B/(8δ·log₂(B/(2δ))),  where B = L/(2m + 1).

4. Protocol R with the uniform prior has failure probability at most L·K ln 2/((m + 1)·n) for every member, so n = ⌈L·K ln 2/((m + 1)δ)⌉ ≤ 2B·K ln 2/δ + 1 questions suffice. The sufficient number exceeds the necessary one by at most the factor 16 ln 2·log₂(B/(2δ))/(1 − 10δ) (up to the rounding).

*Proof.* (1) The 2m + 1 calls of a unit have inputs in one cell (J, R_b), on which f_a is constant, so the human's 2m + 1 answers in a unit are equal. After at most m replacements a unit whose human answers are 1 still has at least m + 1 ones, and a unit whose human answers are 0 has at most m ones. The inputs do not depend on the answers.

(2) This is the argument of Theorem 3.1 of `research/prove/lower-bounds.md` with cells in place of inputs; it is repeated in full. Let a be uniform and independent of the protocol's seed r, of z and of the deployed system's coins. Fix a block j, r and the coordinates a_{−j}. The *j-silent interaction* is the interaction of the protocol on seed r in which inputs of the other blocks are answered according to a_{−j} and every input of block j is answered 0. Let c_1, …, c_k be the distinct cells of block j at which it asks (at any replica u), in the order of first appearance, S := {c_1, …, c_k} and κ_j := k/N.

*Questions.* Let N_j be the number of questions the real interaction puts to block j. If a_j = c_i, the real interaction coincides with the j-silent one until the cell c_i is first asked, and by then c_1, …, c_i have been asked, so N_j ≥ i. If a_j ∉ S the real interaction is the j-silent one and N_j ≥ k. As a_j is uniform and independent of (r, a_{−j}), E[N_j | r, a_{−j}] ≥ (1/N)·(Σ_{i ≤ k} i + (N − k)k) = k − k(k − 1)/(2N) ≥ N·κ_j/2. Summing over j, Σ_j E[κ_j] ≤ 2n/N.

*Failure.* Condition on J = j, r and a_{−j}. For every value a_j = i ∉ S the data are those of the j-silent interaction, so the deployed outcome ô is the same function g₀ of (z, coins) for all these i, while the right outcome is 1[i ∈ set(z)], set(z) := {R_1, …, R_B}. For fixed (z, coins) the number of i ∉ S with g₀ ≠ 1[i ∈ set(z)] is |set(z) ∖ S| if g₀ = 0, N − k − |set(z) ∖ S| if g₀ = 1, and N − k otherwise; if N − k ≥ 2B each of these is at least |set(z) ∖ S|, because |set(z) ∖ S| ≤ B. Each cell lies in set(z) with probability p, and z is independent of (r, a). So Pr[failure | J = j, r, a_{−j}] ≥ (1/N)·(N − k)·p·1[N − k ≥ 2B] ≥ p·(1 − κ_j − 2B/N).

*Average.* J is uniform on [m_b]; so the average failure is at least p·(1 − 2B/N − (1/m_b)·Σ_j E[κ_j]) ≥ p·(1 − 2B/N − 2n/(m_b·N)).

(3) If all failure probabilities are at most δ, then n ≥ (m_b·N/2)·(1 − 2B/N − δ/p). With N = B/(2δ): 2B/N = 4δ, and p ≥ (B/N)·(1 − B/(2N)) = 2δ(1 − δ) gives δ/p ≤ 1/(2(1 − δ)) ≤ 1/2 + δ. So n ≥ (m_b·N/2)·(1/2 − 5δ) = (1 − 10δ)·m_b·B/(8δ), and m_b = K/log₂N.

(4) By (1) and Theorem R3 with δ₀ = 0, the failure probability of the run of M^(T) is at most β/(m + 1), and β ≤ L·K ln 2/n by R1 for a function. L/(m + 1) = B(2m + 1)/(m + 1) < 2B. The ratio is (2B·K ln 2/δ)/((1 − 10δ)·K·B/(8δ·log₂(B/(2δ)))). ∎

**Corollary 6.2 (what "whatever the horizon L" means). NEW.** In the family of Definition 6.0 the number of questions that is necessary and sufficient for failure δ is K·B/δ, up to the factor 16 ln 2·log₂(B/(2δ))/(1 − 10δ): it depends on L and m only through B = L/(2m + 1), the number of independent critical units of a run. Hence:

(a) with m = θL faults tolerated, B = L/(2θL + 1) < 1/(2θ), and the bound L·K ln 2/((m + 1)δ) of R3, which is at most K ln 2/(θδ), lies between B·K ln 2/δ and 2B·K ln 2/δ: it does not grow with L because B does not;

(b) the same B units without replication (m = 0, a run of B calls) cost B·K ln 2/δ questions by R1, and at least (1 − 10δ)·K·B/(8δ·log₂(B/(2δ))) by Theorem 6.1(3) with m = 0. Replication changes the sufficient number by the factor (2m + 1)/(m + 1) < 2 and the necessary number not at all;

(c) the human system without replication needs B answers for one run. So for work of this kind fault tolerance does not reduce the number of human answers per critical unit below about K/(8δ·log₂(B/(2δ))); it makes the comparison with the L answers of the *replicated* human system favourable.

*Proof.* Theorem 6.1(3), (4), and R1 for the scaffold with m = 0. ∎

**Remark 6.2a (the logarithm).** The referee report `research/verify/lower-bounds-check.md` contains a fault-tolerant version of the targeted-question protocol of `lower-bounds.md` (its Proposition A2, proved there and not refereed): if the human system tolerates m faults with failure δ₀ and L/((m + 1)δ) ≥ 16, then 1 + 2.7·K·L/((m + 1)δ·log₂(L/((m + 1)δ))) questions give failure at most δ₀ + δ. For the family of Definition 6.0, L/(m + 1) lies between B and 2B, so at most 1 + 5.4·K·B/(δ·log₂(B/δ)) questions suffice. With Theorem 6.1(3) the number of questions that this family needs is therefore K·B/(δ·log₂(B/δ)) up to a constant factor (at most 44/(1 − 10δ)), and the bound of R3 is larger than necessary by a factor of order log₂(B/δ).

The lower bound is for work in which a unit can decide the outcome. For work whose value is additive, as in Proposition R3a of the note (every call adds a little, no call can do much damage), the proof technique gives nothing, and I know of no lower bound that grows with the amount of work; there the independence of L is not an artefact of replication. So the honest reading of R3 is: imitation amplifies human work inside one run for work in which no single step matters, and for work in which wrong steps are caught and redone at bounded cost (a verifier with retries is of this kind); it does not amplify chains of steps each of which can decide the result, replicated or not.

### 6.2 Numbers

All numbers are from Section 9, part 8. One human-year is 8765.82 hours, the figure of the researcher's notes (`notes.md`, D6).

**Questions required by the bounds.** θ is the fraction of faults tolerated, δ the failure probability; the certificate is V1(a) at confidence 95% for the same θ and δ.

| K (bits) | θ, δ | deterministic human, low stakes: K ln 2/(θδ) | not deterministic, low stakes: K ln 2/(2θ²δ²) | critical, L = 10³: L·K ln 2/δ | certificate: ln 20/(θδ) |
|---|---|---|---|---|---|
| 30 | 0.1, 0.1 | 2.1·10³ | 1.0·10⁵ | 2.1·10⁵ | 300 |
| 10³ | 0.1, 0.1 | 6.9·10⁴ | 3.5·10⁶ | 6.9·10⁶ | 300 |
| 10⁶ | 0.1, 0.1 | 6.9·10⁷ | 3.5·10⁹ | 6.9·10⁹ | 300 |
| 10⁹ | 0.1, 0.1 | 6.9·10¹⁰ | 3.5·10¹² | 6.9·10¹² | 300 |
| 10⁶ | 0.01, 0.01 | 6.9·10⁹ | 3.5·10¹³ | 6.9·10¹⁰ | 3.0·10⁴ |

**Human time.** 6.9·10⁴ answers are 7.9 human-years at one hour each and 6.9·10⁴ human-years at one year each; 6.9·10¹⁰ answers are 7.9·10⁶ human-years at one hour each. The 300 answers of the certificate are 12.5 days at one hour each and 300 human-years at one year each.

**What a given amount of human time pays for** (largest K with K ln 2/(θδ) ≤ n):

| human time | n | K at θ = δ = 0.1 | K at θ = δ = 0.5 |
|---|---|---|---|
| one career of 10⁵ working hours, one hour per answer | 10⁵ | 1443 bits | 3.6·10⁴ bits |
| one career of 50 years, one year per answer | 50 | 0.72 bits | 18 bits |
| 10⁴ people for one year, one year per answer | 10⁴ | 144 bits | 3.6·10³ bits |
| 10⁶ people for one year, one hour per answer | 2·10⁹ | 2.9·10⁷ bits | 7.2·10⁸ bits |

In the last two rows the answers come from many people. The sampler that A1 then describes is "a member of the pool, drawn afresh at every call", its human system is a system of strangers, and K is the complexity of the pool's kernel, not of a person. If the input says which person is to answer, the questions per person are divided by the size of the pool.

**The lower bound in the same units.** Theorem 6.1 with B = 5 units, δ = 0.05 and any tolerance m gives n ≥ 1.107·K for the worst member of a class of 2^K humans, for every protocol. With 50 answers no protocol can meet these parameters for a class of more than 2^45 humans; with 10⁴ answers, for more than 2^9033.

### 6.3 Where the bound is hopeless, and what is known about K for a person

* **A year per answer.** With the researcher's estimate that a research-capable episode may have to last a year, K ln 2/(θδ) is out of reach for every K above a few bits and every useful θ, δ, and Theorem 6.1 shows that for the worst humans of a class of 2^K the order K cannot be improved by any protocol. The certificate alone costs hundreds of human-years.
* **An hour per answer.** The bound is within reach of one person's working life for K up to about 10³ to 10⁴ bits, and of a large organisation for K up to about 10⁷ bits if the pool objection above is accepted.
* **K for a person.** The notes do not estimate it. Two published figures bound it loosely from above when the prior knows nothing of the individual: Landauer estimated the learned content of a person's long-term memory at about 10⁹ bits (T. K. Landauer, "How Much Do People Remember? Some Estimates of the Quantity of Learned Information in Long-term Memory", *Cognitive Science* 10(4):477–493, 1986); Bartol and co-authors estimated at least 4.7 bits per synapse (T. M. Bartol, C. Bromer, J. Kinney, M. A. Chirillo, J. N. Bourne, K. M. Harris, T. J. Sejnowski, "Nanoconnectomic upper bound on the variability of synaptic plasticity", *eLife* 4:e10778, 2015), which with the usual count of 10¹⁴ to 10¹⁵ synapses is 10¹⁵ bits or so. (Both: bibliographic data and the headline figure seen in web search results in this session; neither paper was read; the synapse count is from memory.) At K = 10⁹ and one hour per answer, K ln 2/(θδ) with θ = δ = 0.1 is 7.9·10⁶ human-years.
* **What could make K small.** Only the prior. By Proposition 2.2 the relevant quantity is the complexity of the human's behaviour on the inputs of the closed system given everything the prior knows, and by Proposition 2.4 a prior can make it small only by excluding candidates. The theorems hold for every prior fixed in advance, so a prior built from all existing knowledge of people may be used; then the claim "K is small" is an empirical bet about that prior, and R1 turns into a promise only if the bet is right. The certificate tests the outcome of the bet at a cost that does not depend on K.

### 6.4 Rounds are sequential

**Proposition 6.3 (rehearsal in batches: the bound counts sequential rounds, not answers). NEW.** Let Protocol R be run in S batches of b rounds each (n = S·b): all rounds of batch s use the mixture M^[s] of the data of the batches before s, and the answers of a batch are added at its end. Under A1, A2, A3,

  Σ_{s ≤ S} E Λ(M^[s]) ≤ L·K ln 2,  so for a uniformly random batch s, E Λ(M^[s]) ≤ L·K ln 2/S = b·L·K ln 2/n.

*Proof.* Order the n questions, batch by batch and in any order inside a batch. Each question is a function of earlier data and of coins, and by A1 its answer is a draw from P given everything before, the earlier answers of the same batch included. Lemma 0.1 with ν = P bounds by K ln 2 the sum of E[a·KL(P ‖ M)(x)] over all questions, where M is the mixture of *all* earlier answers. All terms are nonnegative; keep the term of the first round of every batch, for which M = M^[s]. By (0.5) this term is E Λ(M^[s])/L. ∎

*Reading.* Answers given in parallel are not credited by the bound, and in the worst case they are worth nothing: let the scaffold be a chain in which the input of call j + 1 is the list of the answers to calls 1, …, j, and let the human answer a correct list of length j with a long string c_{j+1} and every other list with a fixed symbol. The input of link j + 1 cannot be written down before c_j has been seen, except by guessing a long string, so every batch, of any size, learns at most one new link. (This remark is not proved here beyond what is said; for strings so long that a guess never succeeds it is immediate.) A chain of L calls therefore needs L sequential batches, as it needs L sequential answers from the human. With a year per answer, a programme of 20 years has at most 20 sequential batches whatever the number of people, and the bound of R3 with S in place of n pays for K ≤ 20·θδ/ln 2 = 0.29 bits at θ = δ = 0.1.

### 6.5 The budget, in sum

The budget test splits. *Learning* by rehearsal with a guarantee that covers a class of 2^K candidate humans costs of the order of K/(θδ) answers, the order K is forced, and for a person under a generic prior this is hopeless at any length of answer. *Checking* a given imitator costs ln(1/δ_c)/(θδ) answers whatever the imitator and whatever K. The affordable protocol is therefore: obtain an imitator by any means, rehearsal with an informed prior among them, and certify it; the theorem that carries the weight is V1 with R3, not R1.

## 7. What remains a bet

Section 13 of the candidate theory (V2, V3) says: rare situations are never sampled; what the imitator does there is fixed by the prior; a prior restricted to isolated hypotheses bets on the simplest continuation and is exact if the human is isolated; no data decide. This section makes each clause exact, and then treats "copy or predictor".

### 7.1 Rare situations

**Proposition 7.1 (on a set that the runs seldom meet, the imitator does what the prior says, and R1 is silent). PROVED.** Let Q ⊆ X, and let q be the supremum, over all answerers B, of the probability that a run answered by B has a call with input in Q.

(a) Under Protocol R the probability that some question of rounds 1, …, n lies in Q is at most n·q.

(b) Let the human be a function f ∈ H and let f_Q ∈ H be a function with f_Q = f outside Q and f_Q(x) ≠ f(x) for x ∈ Q. On the event that no question lies in Q, w_{D_n}(f_Q)/w_{D_n}(f) = w(f_Q)/w(f); the data would have been the same, with the same probability, had the human been f_Q; and at every x ∈ Q the draw of the mixture M_{D_n} differs from f(x) with probability at least w_{D_n}(f_Q) and from f_Q(x) with probability at least w_{D_n}(f).

(c) Let w′ be w with the weights of f and f_Q exchanged. R1 holds under w and under w′ for both humans. On the event of (b), the mixture under w sides with f on Q with odds w(f) : w(f_Q), and the mixture under w′ with the inverse odds.

*Proof.* (a) The question of round t lies in Q only if the run τ_t meets Q. (b) Both functions give every recorded answer probability 1. (c) R1 holds for every prior. ∎

So for q ≪ 1/n what happens on Q is the prior's opinion, and the theorems, which hold for every prior, cannot have one. In the class of all programs with a universal prior, the members that agree with the data and behave like a computable b on Q have posterior weight at least 2^(−K(Q, b) − c), the floor of `repo.md`, D1; the candidate's "wrong there with probability about 2^(−sep)" should read "at least", and on another machine it is one half (D2). The stake of the bet on one set Q is small: the human system meets Q with probability at most q. But bets on disjoint sets add up, and nothing limits their number: in the needle class of N2 every input is such a Q, and the sum of the stakes is the whole failure probability (`research/prove/lower-bounds.md`, Theorem 2.1). A protocol that chooses its questions freely can put one into a rare Q; then the limit is the number of such sets (same file, Theorem 4.1), not their rarity.

### 7.2 Isolation and patch-free induction in a closed system

`ultranatural/note.md` (Section 5, Theorem 9; read in this session) is for a deterministic function, inputs drawn independently from one law μ, and the distance d(f, g) = μ{f ≠ g}: f is δ-isolated if every other function within distance δ is more complex, patch-free induction puts the prior on isolated functions only, and after n samples the expected posterior mass off an isolated f is at most 2^(K(f))·(1 − δ)^n. In the present setting the questions are single calls of runs of the imitator, not independent samples, and what matters is the run, not the single input.

**Definition 7.2.** Hypotheses are functions; H′ is a countable class of functions with weights w. The *run distance* of two functions is D(g, g′) := Pr_{(z,ρ)}[run_g(z, ρ) ≠ run_{g′}(z, ρ)]. (The two runs differ exactly if g′ differs from g at an input of run_g(z, ρ).) A function f ∈ H′ is *δ-separated in H′* if every h ∈ H′ has D(f, h) = 0 or D(f, h) ≥ δ; [f] := {h ∈ H′ : D(f, h) = 0} is its *run class*. A member h of a class H is *δ-isolated in H* if w(h′) < w(h) for every h′ ∈ H with 0 < D(h, h′) < δ; H_δ is the set of δ-isolated members, and the *patch-free prior at scale δ* is w restricted to H_δ.

**Lemma 7.3. NEW.** Every member of H_δ is δ-separated in H_δ.

*Proof.* If h, h′ ∈ H_δ and 0 < D(h, h′) < δ, then w(h′) < w(h) and w(h) < w(h′). ∎

**Protocol R′** (the candidate's variant of R4, one posterior draw per run). In round t a function g is drawn from the posterior (the weights w on the members consistent with the answers so far, normalised); a run of Π is generated with g answering every call; J_t is uniform on {1, …, L}; if the run has a J_t-th call, its input is put to the human and the members that disagree with the answer are removed.

**Theorem 7.4 (patch-free rehearsal: exponential rate, the last posterior, all of the closed system). NEW.** Let the human be a function f ∈ H′ that is δ-separated in H′, and K := log₂(1/w(f)). Assume A1, A3(i), A3(iv).

(a) Under Protocol R′ with the class H′, for every n,

  E[posterior weight of H′ ∖ [f] after n rounds] ≤ 2^K·(1 − δ/(2L))^n ≤ 2^K·e^(−δn/(2L)).

Hence a run answered by one draw from the posterior after n rounds is the human system's run on the same (z, ρ) with probability at least 1 − 2^K·e^(−δn/(2L)); n ≥ (2L/δ)·(K ln 2 + ln(1/η)) questions make this at least 1 − η.

(b) If instead N independent runs of the human system are recorded, E[posterior weight of H′ ∖ [f]] ≤ 2^K·(1 − δ)^N.

By Lemma 7.3 both apply to the patch-free prior at scale δ whenever the human is δ-isolated.

*Proof.* (a) For a function h and a pair (z, ρ) let j*(h) be the index of the first call of run_f(z, ρ) at whose input h differs from f, and j*(h) := ∞ if there is none; D(f, h) = Pr[j*(h) < ∞], and the runs of h and of f have the same inputs at the calls 1, …, j*(h). Let S_t be the set of members consistent with the answers before round t, W_t := w(S_t), R_t := w(S_t ∖ [f]), and w_t := w/W_t on S_t the posterior. Let g′ be a second draw from w_t, independent of g, (z, ρ) and J_t. On the event E := {j*(g′) < ∞, j*(g′) ≤ j*(g), J_t = j*(g′)}, the run of g has a call number J_t, its input is the input of call j*(g′) of run_f, and g′ differs from f there; moreover g′ ∉ [f] up to an event of probability 0. So the expected weight removed from S_t ∖ [f] in round t is at least W_t·Pr[E | 𝓕_{t−1}]. Since J_t is uniform and independent of the rest, and (g, g′) is exchangeable,

  Pr[E | 𝓕_{t−1}] = (1/L)·Pr[j*(g′) < ∞, j*(g′) ≤ j*(g)] ≥ (1/(2L))·Pr[j*(g′) < ∞] = (1/(2L))·Σ_{h ∈ S_t} w_t(h)·D(f, h) ≥ δ·R_t/(2L·W_t),

the last step because D(f, h) ≥ δ for h ∉ [f]. Hence E[R_{t+1} | 𝓕_{t−1}] ≤ R_t·(1 − δ/(2L)), and E[R_{n+1}] ≤ (1 − δ/(2L))^n. The human f is never removed, so the posterior weight of H′ ∖ [f] after n rounds is R_{n+1}/W_{n+1} ≤ R_{n+1}/w(f). A draw from [f] has the run of f on almost every (z, ρ).

(b) A member h ∉ [f] is consistent with a recorded run exactly if that run does not meet {h ≠ f}, which has probability 1 − D(f, h) ≤ 1 − δ; so the expected weight of the members of H′ ∖ [f] consistent with N runs is at most (1 − δ)^N. Divide by w(f). ∎

*What it says.* For a separated human the 1/n law of R1 and R4 becomes exponential, the last posterior may be deployed (no random round), and the guarantee covers every run of the closed system, the rare ones included: with probability at least 1 − 2^K·e^(−δn/(2L))/η over the rehearsal, every later run fails with probability at most η. The law "more questions than critical calls over ε" of N2 is a property of classes closed under patches; a class in which the human is separated escapes it, with ln(1/ε) in place of 1/ε. Section 9, part 5, shows the two regimes in a toy class. For a human who is not deterministic there is a statement of the same kind for recorded runs (`research/prove-b/hellinger-runs.md`, Theorem 5.1, with H²(Q_ν, Q_P) in place of D and steeper weights); for single-call rehearsal I have none.

*What it does not say.* That a human is separated or isolated. Isolation is relative to the weights: by `ultranatural/note.md`, Proposition 8(5) and the remarks after Theorem 9 (read in this session; they rest on its Theorem 3, which I know from the digest `repo.md`, G4), a machine about sep(x; A) bits away regards a patch of f as the isolated function and f as its near-miss. And the bet has a price:

**Proposition 7.5 (the price of the bet when the human is not in the separated class). NEW.** Let H′ be a class of functions with weights, let the human be a function f† (in H′ or not), and ε† := inf_{h ∈ H′} D(f†, h).

(a) *Never learned.* An imitator that answers each run with one member of H′, chosen in any way that does not depend on (z, ρ), has a run that differs from the human system's with probability at least ε†, for every number of questions. With a prior that gives f† positive weight, Protocol R′ makes this probability tend to 0 (R4).

(b) *Visible in the end.* Under Protocol R′ with the class H′, the weight W_t of the members consistent with the answers before round t, which is the marginal likelihood ξ(D_{t−1}) of the data, satisfies E[W_{n+1}] ≤ (1 − ε†/(2L))^n.

(c) *Universality can be bought back.* For κ ∈ (0, 1) and any class H ⊇ H′ with weights w, the prior w″ := (1 − κ)·(w restricted to H′) + κ·w has w″(h) ≥ κ·w(h) for every h ∈ H, so every theorem that holds for the prior w with K holds for w″ with K + log₂(1/κ).

*Proof.* (a) Given the chosen member h, the runs differ with probability D(f†, h) ≥ ε†. (b) In the proof of Theorem 7.4(a) replace f by f† throughout and do not restrict to S_t ∖ [f]: the expected fraction of W_t removed in round t is at least (1/(2L))·Σ_h w_t(h)·D(f†, h) ≥ ε†/(2L). (c) Immediate. ∎

**Example 7.6 (the bet lost: silent, certain, then visible). NEW.** One call per run at an input uniform on [N]. H′ = {f ≡ 0, g ≡ 1} with weights 1/2; both are 1-separated. The human is the needle f† = 1[x = x₀], so ε† = 1/N. The first question outside x₀ refutes g; from then on the posterior gives f the weight 1, and the imitator fails with probability 1/N per run, with no doubt left in the posterior. Each round has probability 1/N of asking x₀; when that happens f is refuted, the class is empty, and the failure of the bet is plain. So for n ≪ N the price of the lost bet is a silent error at the rate of the patch, and for n ≫ N a learner with no hypothesis. The mixture over the class with all needles added (weights 1/4, 1/4 and 1/(2N) each) is also wrong at x₀ with probability more than 1 − 2/N while x₀ is unasked: at an unasked patch the two do equally badly, as N1 requires. They differ in three ways: the mixture keeps a weight of about 2^(−sep) on the patch, which is what the abstention rules Ab1 and Ab2 of the candidate theory work with; the mixture is exact once x₀ has been asked; and if the human is f ≡ 0 after all, the restricted class is exact after one question, while a run of the mixture still fails with probability about 2/(3N) until a number of questions of the order of N has been asked.

**Proposition 7.7 (the guarantee on average over the prior is free). PROVED.** Let the human be drawn from the normalised prior w/W, and then let any protocol produce data D. Conditionally on D, a run of Π answered throughout by one draw from the posterior w_D has the same law as a run of the human system. So for every protocol, every event G of runs and every n ≥ 0, Pr[the imitator's run is in G] = Pr[the human system's run is in G], the probabilities being over the prior as well.

*Proof.* Conditionally on D the human has the law w_D, as the draw has; the run is the same function of the answerer and of fresh (z, ρ) and coins. ∎

This is the exact sense in which rare situations are a bet. A reader who believes that the human is a draw from the prior needs no theorem and no questions. Every statement of the note that is not this one (R1, R3, the limits N1 and N2) is about a fixed human, and its content is what happens when the human is not typical of the prior. N1 says that on unasked inputs nothing but the prior speaks. Whether to let a universal prior speak there (doubt 2^(−sep) at every new kind of input, slow learning, never certain) or a patch-free one (no doubt, fast, wrong for ever on a patch) is not decided by any data that either protocol collects: for every set Q that the questions miss, the two humans of Proposition 7.1(b) produce the same data.

**The candidate's V2** ("with a worst-case guarantee over a class closed under patches, the number of human answers must exceed the number of critical call types in a run over ε … low stakes is the only exception") needs three qualifications. The law is conditional on closure under patches (Theorem 7.4 is the case without it). "Low stakes" by replication is not an exception to the count per critical unit (Corollary 6.2). And the guarantee on average over the prior is another exception, which is why it should never be confused with the theorems (Proposition 7.7).

### 7.3 Copy or predictor: what the data can and cannot decide

**Proposition 7.8 (the data fix the kernel on the inputs of the closed system, and nothing else). PROVED.** Let P and P′ be samplers that agree on X_Π, the set of inputs that Π can produce. Then Q_P = Q_{P′}, and for every protocol all of whose questions lie in X_Π (rehearsal, validation, recorded runs) the joint law of the data and of the deployed imitator is the same whether the human is P or P′.

*Proof.* Every question is answered by the same kernel in both cases; induct over the questions. ∎

So no theorem about such data separates two humans who differ outside X_Π, or two mechanisms with one kernel. This is "one data law, at most one copy" and "behaviour, not mechanism" of this repository's second paper (`repo.md`, F5(a) and F8, quoted from the digest).

**Proposition 7.9 (under A1 no predictor beats the sampler). PROVED.** Under A1, for questions chosen as in Lemma 0.1 and every hypothesis ν,

  E[ln(ν(D_n)/P(D_n))] = −Σ_{t ≤ n} E[a_t·KL(P ‖ ν)(x_t)] ≤ 0  and  Pr[sup_n ν(D_n)/P(D_n) ≥ c] ≤ 1/c for every c > 1.

*Proof.* On {a_t = 1}, E[ν(y_t|x_t)/P(y_t|x_t) | 𝓖_t] = Σ_{y: P(y|x_t) > 0} ν(y|x_t) ≤ 1, so the likelihood ratio is a nonnegative supermartingale started at 1; Ville's inequality gives the second claim. The first is the conditional expectation of the logarithm, with integrability as in Lemma 0.1 (if a term is −∞ with positive probability both sides are −∞). ∎

A hypothesis that thinks about the human from outside and predicts as well as P has P's kernel at the asked inputs, and then Proposition 7.8 applies to it. A hypothesis that predicts *better* than P exists exactly when A1 fails: when the conditional law of the answer, given x and something else that the hypothesis can compute, is not P(·|x). Then the data identify the kernel of the data, not the person (`repo.md`, F2 to F6: environment-driven coins). So the first half of the copy test is not passed by the theorems; it is assumed away by A1, and inside a closed deployment only the kernel matters in any case.

**Proposition 7.10 (the sampler and the sampler with its coins filled in). PROVED.** Let P be a sampler, and let the *frozen human* G be a random function with G(x) drawn from P(·|x) independently for every x, once and for all.

(a) For every protocol that never asks the same input twice, the law of the data is the same for the human P with fresh coins and for the frozen human. For a scaffold whose runs never contain an input twice, Q_P is the law of a run of the frozen human.

(b) If an input x with P(·|x) not a point mass is asked twice, the two answers differ with probability 1 − Σ_y P(y|x)² > 0 for the fresh human and with probability 0 for the frozen one.

*Proof.* (a) Induct over the questions: given the earlier questions, which were at other inputs, and their answers, G(x) at a new input x is independent of them with the law P(·|x). (b) Immediate. ∎

So whether the human is a sampler or a fixed table of answers is a fact about repeated questions, and it can be put to the test only by asking twice, which needs A1 in full. A scaffold whose inputs never repeat does not care. As for the *imitator*: the mixture of R1 has fresh coins by construction, so the question does not arise for it; it arises for a single selected program, and at weights 2^(−length) nothing in the data favours the sampler over its fill-ins (`repo.md`, E11); a steeper prior does, for answers drawn afresh at inputs sampled independently from one law (E5, E8), which is not the regime of rehearsal.

**Summary (copy or predictor).** The data decide: the human's kernel on the inputs of the closed system, to the accuracy of R1; with repeated questions, whether answers are drawn afresh. The data do not decide: the mechanism; the behaviour off the rehearsed law; which part of a dependence on context belongs to the person, if A1 fails. The deployed object of the theorems is a committee that is redrawn at every call (R1), every episode (Theorem 1.7) or every run (R4, Theorem 7.4); in no theorem is it a program that resembles the human inside. For a closed deployment this costs nothing, since only the law of the run enters. Everything that the word "upload" promises beyond a closed deployment (consulting the imitator on new matters, running it on, trusting it where it was never rehearsed) lies in the part that no data decide, and there the only instruments are priors: the universal one, with its floor, or a restricted one, with its bet.

## 8. The objections

The claim under attack: *rehearsal is a human-imitation protocol that works exactly as far as any protocol can.* It has three parts: that what is imitated is a human; that the protocol works, that is, gives a usable guarantee from a reasonable number of answers; and that no protocol does better. Each objection is classed as **answered** (the theory as it stands contains the reply), **answerable** (the objection is right against the claim as worded, and a stated change of the protocol or of the wording meets it) or **fatal** (no change inside the framing meets it; the part of the claim that has to go is named).

| no. | objection | class |
|---|---|---|
| O1 | K for a person makes every learning bound empty, and the factor K is forced | fatal to "works from a reasonable number of answers", as a theorem about a human |
| O2 | work whose single steps can decide the result is not amplified, with or without replication | fatal to amplification of such work; answered as mathematics |
| O3 | affordable only with short calls, in few sequential rounds; research may need long episodes | fatal on the researcher's own numbers, unless short-episode scaffolds do research |
| O4 | only a computation fixed in advance is imitated, not a person | fatal to "upload" |
| O5 | the failures are silent | fatal to "fails only obviously" inside the closed system; answerable in two weak forms |
| O6 | A1 is false of people | answerable, at a cost that feeds O1 and O3 |
| O7 | "exactly as far as any protocol can" is false as worded | answerable by rewording |
| O8 | the human reads what the prior wrote | answerable by variants, each at a price; open in general |
| O9 | A2 fails silently, and then the protocol can settle on the worst member | answerable: the certificate |
| O10 | A3 fails in practice (seeds, dates, a special real task, a prior that saw the data) | answerable by design |
| O11 | hypotheses that model the experiment, or act with intent | answered |
| O12 | the deployed imitator is that of a random round | answered |
| O13 | the human of rehearsal is not the human who matters | answerable by design |
| O14 | the guarantee is weakest on the runs that matter most | answered, and it multiplies O1 |
| O15 | with the class of all programs the protocol is not a computation | answerable; A2 then becomes stronger |
| O16 | the slack of an additive guarantee goes to the worst event | answered |
| O17 | the human system may be worthless or harmful | outside the theorems |

**O1. K.** R1 is a regret bound whose constant is K = log₂(1/w(P)). For a person under any prior that does not already contain the person, K is of the order of a description of the person, perhaps 10⁹ bits (Section 6.3), and the number of answers is K ln 2/(θδ) at best. This is not a weakness of the Bayes mixture: for a class of 2^K candidates some member needs of the order of K·L/(δ log(L/δ)) answers under every protocol, and of the order of K·B/(δ log(B/δ)) under low stakes (`research/prove/lower-bounds.md`, Theorem 3.1; Theorem 6.1 here); and no prior makes K small for more than 2^k candidates (Proposition 2.4). The researcher's own remark applies: a constant "could of course be very large" (`notes.md`, end of Section 5). *Fatal* to the claim that the protocol works from a reasonable number of answers, read as a theorem about a human. What survives: (i) the bound with K replaced by K_Π under a prior built from prior knowledge, which is a bet about that prior (Propositions 2.2, 2.4); (ii) the certificate, whose cost does not contain K (Proposition 2.5).

**O2. Critical steps.** For a scaffold in which each of L calls can decide the outcome, every protocol needs at least L/(4δ) − L answers for simple classes (N2), which for δ ≤ 1/8 is more than the L answers with which the human does the run. R3 removes L only for scaffolds that tolerate θL arbitrary faults. Where this tolerance comes from replication, the scaffold has fewer than 1/(2θ) independent critical units, and in the family for which this is proved the answers needed per unit are unchanged (Corollary 6.2). So rehearsal with a worst-case guarantee amplifies human work inside one run only for work in which no single step matters, or in which wrong steps are caught and redone at bounded cost. A proof whose every lemma is needed is not such work unless each lemma is checked mechanically. *Fatal* to the hope that imitation plus decomposition yields long chains of critical reasoning at a cost below the human's own; *answered* as mathematics, since N2, N5 and Theorem 6.1 are part of the theory. What survives: reuse (the same answers serve every later run of the same closed system), and verifiable or additive work.

**O3. Short calls, few rounds, long episodes.** With an hour per answer one working life pays for about 1.4·10³ bits of K at θ = δ = 0.1; with a year per answer, for 0.7 bits (Section 6.2). Rehearsal is sequential, and the bound counts sequential rounds, not answers (Proposition 6.3): with a year per answer, twenty years give twenty rounds whatever the number of people. The researcher's estimate is that an episode able to do research may have to last a year, and that trees of short episodes may be a "bureaucracy" that does nothing (`notes.md`, Section 2.13). On these numbers the protocol is affordable exactly for the scaffolds whose value is in doubt. *Fatal on those numbers*; it stops being fatal only if scaffolds of short episodes do research, which no theorem about the learner can show.

**O4. Not a person.** The guarantee is for a closed deployment (Definition 4.1): a computation fixed in advance, whose real run is one more sample. An imitator certified for one such computation is not certified for the next use; on inputs that rehearsal did not meet, no protocol has a guarantee (N1), and what the imitator does there is the prior's choice (Proposition 7.1). The picture that motivates the problem, a copy that can be run on and consulted, is an open system. For it the theory offers the list of Proposition 4.4, whose only assumption-free item keeps the human on call for ever. *Fatal* to the reading "upload". What survives: imitation of the human *inside one computation that we can run in advance*.

**O5. Silent failures.** The researcher asked for an imitator that "basically only fails obviously". Inside the closed system the unfaithful calls of the deployed run are not marked, and they must be taken as adversarial. A rule that is never silently wrong for every member of a class closed under patches abstains at every new input (`research/prove/lower-bounds.md`, Corollary 1.7), or pays exponentially (N4). *Fatal* to the desideratum in its strong form. Two weak forms hold: the protocol as a whole fails obviously, while the human is still there, when validation shows mismatches (Proposition 2.5); and top-level inputs outside the rehearsed support can be refused without the human (Proposition 4.4, item 4). A restricted prior that is losing its bet also shows it, in the marginal likelihood, but only after a question has landed on the patch (Proposition 7.5(b)).

**O6. A1 is false of people.** People remember, learn, tire and know what they are taking part in, and Example 1.1 shows that the protocol's data cannot reveal a failure of A1. Memory inside a unit of work is repaired by rehearsing whole episodes (Theorems 1.7 to 1.9): the theorems then hold with episodes as calls, exactly for a deterministic human and in a weaker form otherwise. A human who changes over the weeks of rehearsal is covered only by a bound against the best fixed sampler, with a term that grows with the drift, and nothing is promised about the human after the last question (Theorem 1.11, Corollary 1.12, Proposition 1.14). *Answerable*, but the repair replaces short questions by whole episodes, each of which is a datum; this feeds O1 and O3.

**O7. "Exactly as far as any protocol can."** False as worded, in four ways. (i) Rehearsal with the mixture is not optimal: a protocol with targeted questions saves a factor of order log(L/δ) for functions (`research/prove/lower-bounds.md`, Theorem 3.3; that Protocol R itself, and not only its bound, needs the larger number on some class is Proposition A1 of the referee report `research/verify/lower-bounds-check.md`). (ii) The matching lower bounds are worst cases over classes of 2^K candidates with uniform weights; for a particular human and prior far fewer answers can suffice (Theorem 7.4; the researcher's own remark that K well-chosen examples teach a function, `notes.md`, Q7). (iii) Under low stakes the bound of R3 and the lower bound differ by the factor 16 ln 2·log₂(B/(2δ))/(1 − 10δ), which is at least 62 in the examples of Section 9 (Theorem 6.1); the logarithm can be saved by targeted questions (Remark 6.2a); and for additive work there is no lower bound at all. (iv) For a human who is not deterministic the constants differ by three to four orders of magnitude (`research/prove-b/hellinger-runs.md`, Section 3.3). *Answerable* by saying what is true: in the worst case over classes of 2^K candidate humans, the number of answers that rehearsal needs is within a factor of order log(L/δ) of what every protocol needs, for critical calls and for tolerance by replication, and within a constant for whole-run closeness to a human who is not deterministic.

**O8. The human reads what the prior wrote.** In the early rounds the runs are driven by the prior, and the questions put to the human are built from its answers. For a deterministic human the expected number of such tainted questions is at most L·K ln 2 (Proposition 1.16), which with K of the size of O1 means nearly all questions of any affordable rehearsal. If reading such text can change the human, A1 fails; if it can harm the reader, the protocol is not safe, and with a class that contains every program its worst members write the text. Variants in which the human sees no such text exist: recorded runs of the human system (the candidate's Theorem A; whole runs, so small scaffolds only), runs driven by a rule that answers only where all weighty hypotheses agree (at the price of a number of questions polynomial in 1/w(P), according to the digest `research/understand/alignment-proposals.md`, Sections 1 and 6.1), a class restricted to hypotheses that cannot write such text. *Answerable* by one of these at its price; whether an ordering of rehearsal reduces the number of tainted questions to order K is open.

**O9. A2 fails silently.** If the human is not in the class, or has weight zero, R1 says nothing, and Example 2.3 shows the protocol settling, with probability 0.44, on a member whose runs differ from the human system's half of the time, although another member is exact on the human system. *Answerable*: never rely on R1 alone; the certificate needs no A2 (Proposition 2.5), and it shows a failure of this kind at any rate above about 1/m.

**O10. A3 in practice.** A call index computed from the run by a seed leaves a floor that no amount of data lowers (Example 3.3); a real task that is not a draw from the rehearsed law, or a date in the inputs, leaves the guard unrefuted (Examples 3.4, 3.5); a prior that has seen the rehearsal data memorises (Example 3.6). *Answerable* by design, and each remedy can be checked by the designer: physical randomness for J_t; inputs that carry nothing a rehearsal input could not carry; the real task rehearsed itself or drawn from D₀; the prior fixed before the first coin.

**O11. Hypotheses that model the experiment or act with intent.** They cannot break R1, which holds for every class and prior; they cannot aim at unasked calls (Theorem 3.2(a), (b)); and the one that knows the realised coins has negligible weight under a prior fixed first (Theorem 3.2(c)). What they change is that the remaining unfaithful calls must be assumed to be placed and written by an adversary, which the definition of tolerance in R3 already does. *Answered.*

**O12. A random round.** The imitator of R1 is the mixture of a uniformly random round, half of the time one from the first half of rehearsal. With probability 1 − η over the rehearsal and T its bound is 1/η times the average (Markov), and any single imitator, the last one included, can be certified by validation. *Answered.*

**O13. The human of rehearsal.** A human who answers differently because no run depends on the answer is imitated as such, and the human whose answer would be used is not sampled by any protocol that removes the human (Proposition 1.15). *Answerable* by what the human is told and by the variant in which every answer is used in its run (Proposition 1.15(c)); what the right instruction is, is not mathematics.

**O14. The runs that matter.** If the valuable runs are a set S of probability q under the deployed imitator, the guarantee conditional on that set is weaker by 1/q (for the number N of unfaithful calls, E[N | S] ≤ E[N]/q, and nothing better holds in general): after a rare success, what the imitator does with it is constrained by 1/q times fewer questions. The human system pays the same factor, since it too needs 1/q runs per success, so the comparison between the two is unchanged. *Answered*, and it multiplies every number of O1.

**O15. Not a computation.** For the class of all lower semicomputable samplers the conditionals of the mixture are limit-computable and not computable (`repo.md`, A9(iv)), so "run the scaffold with the mixture: this uses computation only" is false of ordinary computation, however long. *Answerable*: the theorems hold for every class; take one whose members are uniformly computable (programs with a time bound). Then A2 says that the human is in that class, a stronger assumption, and K is relative to it.

**O16. Additive slack.** A guarantee in total variation leaves a slack that an adversary can put on the worst event. R1 bounds KL(P ‖ M), the direction that makes M cover P, not the one that keeps M inside P. *Answered*, as far as it goes: R3 assumes the worst content for the unfaithful calls; for an event that the human system never produces, the deployed run produces it with probability at most 4L·K ln 2/n, a linear rate (`research/prove-b/hellinger-runs.md`, Theorem 3.1(c)); a multiplicative guarantee needs abstention and a number of questions polynomial in 1/w(P) (the candidate's Ab2).

**O17. The human system.** Whether a tree of calls answered by the human does anything useful, and whether a faithful imitation of it is safe, are questions about the human and the scaffold. The theorems transfer whatever the human system does, including its failures. *Outside the theorems.*

**What survives of the claim.** *For a computation that we can run in advance and a human who answers its calls without memory, n answers to single calls drawn from the imitator's own runs give an imitator whose run has at most L·K ln 2/n unfaithful calls in expectation; in the worst case over 2^K candidate humans no protocol needs fewer answers by more than a logarithmic factor; a given imitator can be certified at a cost that does not depend on K; and nothing is offered outside that computation, at rates below about 1/n, or for a human who is not the one that answered.* The three parts of the original claim fare as follows. "Human-imitation": of a stateless answerer of single calls inside a fixed computation, not of a person (O4, O6). "Works": as a certificate, yes; as a learning guarantee from a reasonable number of answers, only as a bet on the prior (O1, O3). "As far as any protocol can": up to a logarithmic factor and in the worst case, yes, including the uncomfortable half of it, that no protocol amplifies work whose steps are critical (O2, O7).

## 9. Numerical checks

Script for parts 1 to 9: `research/prove-c/code/assumptions_checks.py` (Python 3.13, numpy 2.5.3; about 25 seconds; seed 20261115). Its complete output is `research/prove-c/code/assumptions_checks.out`; the lines below are copied from it. Every bound that is printed next to a computed value holds.

**Part 1 (Example 2.3).**

```
  Pr[nu1 is never refuted] = prod_k 2/(2+omega_k) = 0.556481;  Pr[nu1 is refuted at some time] = 0.443519
  n = 100: Pr[nu1 refuted] = 0.443519;  Pr[run of the mixture after n rounds differs from the human system] = 0.221759
  simulation, 200000 trials, n = 60: Pr[nu1 refuted] = 0.4432 +- 0.0011
```

**Part 2 (Example 3.3 and Proposition 6.3).** Exact values from the binomial law of the number of surviving seeds; k = 3, L = 4, K = 1 bit.

```
    t   seeded J   fresh J
      1   1.500000   1.500e+00
      5   0.340609   1.039e-02
    100   0.333333   6.638e-60
  limit for seeded J: (L-1)/(2^k+1) = 0.333333
    n =  100: seeded 0.35061   fresh 0.02279   R1 bound 0.02773
    n = 1000: seeded 0.33506   fresh 0.00228   R1 bound 0.00277
  batches of  1 rounds, fresh J: sum over 200 batches of E[unfaithful calls] = 2.2791  (bound L K ln2 = 2.7726)
  batches of  5 rounds, fresh J: sum over  40 batches of E[unfaithful calls] = 1.5026  (bound L K ln2 = 2.7726)
  batches of 20 rounds, fresh J: sum over  10 batches of E[unfaithful calls] = 1.5000  (bound L K ln2 = 2.7726)
```

With fresh coins the sum over all rounds of the expected number of unfaithful calls is 2.28, below L·K ln 2 = 2.77, as R1 requires; with the seed the sum grows linearly in n.

**Part 3 (Theorem 3.2(a)).** Each run meets Q with probability q at one call; the probability of the theorem is (1/n)Σ_t (1 − q/L)^(t−1)·q.

```
    L =   4, n =   100: max = 0.04000 at q = 1.00;  min(1, L/n) = 0.04000
    L =  20, n =   100: max = 0.19882 at q = 1.00;  min(1, L/n) = 0.20000
    L =  20, n = 10000: max = 0.00200 at q = 0.23;  min(1, L/n) = 0.00200
```

So the bound L/n is attained to the digits shown when n is large compared with L.

**Part 4 (Examples 3.4, 3.5).**

```
    n = 10000, p =  1.0e-06: at most 0.49751
    n = 10000, p =  1.0e-04: at most 0.31607
    n = 10000, p =  1.0e-01: at most 0.00050
    n =   100, d =        101: 9.612e-05
    n =   100, d =        201: 4.902e-03
    n =   100, d = 1000000000: 9.804e-03
    n =   100, any d >= theta0: at least 0.0194
    n = 10000, any d >= theta0: at least 0.0196
```

**Part 5 (Theorem 7.4).** X = [16]; an adaptive scaffold with L = 3 calls (x_1 uniform, x_{j+1} = x_j + 1 + 3y_j mod 16); f ≡ 0 and 15 random members at Hamming distance 8, whose run distances to f lie between 0.625 and 1, so δ = 0.625 and K = 4 bits; Protocol R′; 4000 trials. "Class with patches" adds the 16 one-point patches of f (run distance 0.1875) with total weight 1/2.

```
    n   separated class   bound 2^K(1-delta/(2L))^n   class with patches
    0   0.93750           1.00000                     0.96875
    5   0.18257           1.00000                     0.92290
   10   0.00883           1.00000                     0.89202
   20   0.00000           1.00000                     0.80122
   40   0.00000           0.19643                     0.45545
   60   0.00000           0.02176                     0.16265
```

The bound holds and is far from tight in this small class (the factor 2^K and the factor 2 in the rate are lost in the proof). The patches are removed at the rate at which runs meet them.

**Part 6 (Theorem 1.7(b)).** Three sequential episodes per run, two messages per episode, the second message of the scaffold depending on the first answer and a coin; 40 functions on visible histories, K = 7.47 bits; Protocol R^ep; 3000 trials.

```
  sum over 150 rounds of E[number of unfaithful episodes of a run of the round's
  episodic mixture] = 4.2870;  bound L_e K ln2 = 15.5327
```

**Part 7 (Corollary 1.12).** One call per run at one input; the human of round t answers 1 with probability 0.5 + 0.0002·t; 19 Bernoulli samplers with uniform weights; 4000 trials for each n.

```
    n =    10: to the human of round 1: 0.1119;  to the human of round T: 0.1120
    n =   100: to the human of round 1: 0.0631;  to the human of round T: 0.0632
    n =   300: to the human of round 1: 0.0433;  to the human of round T: 0.0439
    n =  1000: to the human of round 1: 0.0593;  to the human of round T: 0.0586
    n =  2000: to the human of round 1: 0.1035;  to the human of round T: 0.1033
```

The distance of the deployed mixture to the human of the first round is smallest near n = 300 and then grows: more rehearsal of a drifting human gives a worse imitation of the human of any fixed date.

**Part 8 (Theorem 6.1; the budget).**

```
    m_b    B    m   delta      L     K bits   lower bound   scan     R3 upper   upper/lower
       10    5       0  0.05          5      56.44         62.5      127.4       3912     62.6
       10    5      50  0.05        505      56.44         62.5      127.4       7747    124.0
     1000    5      50  0.05        505       5644         6250  1.274e+04  7.747e+05    124.0
     1000   50       5  0.01        550  1.129e+04    5.625e+05  6.252e+05  7.172e+07    127.5
  1000000    5 1000000  0.05      1e+07  5.644e+06     6.25e+06  1.274e+07  7.824e+08    125.2
    c/m_b   expected questions n   failure (1-c/m_b) p   lower bound p(1-2B/N-2n/(m_b N))
    0.00             0.0           0.09608               0.07686
    0.50         12740.0           0.04804               0.02790
    1.00         25480.0           0.00000               -0.02106
```

"Scan" is the protocol that asks the cells of half of the blocks in turn until the needle is found and deploys the function it has learned (failure at most δ; `research/prove/lower-bounds.md`, Proposition 3.2): its number of questions is about twice the lower bound (the factor is 1/(1 − 10δ) with a small correction), so Theorem 6.1(3) is tight up to that factor, and the bound of R3 exceeds the scan protocol by about 16 ln 2·log₂(B/(2δ))·(2m + 1)/(2m + 2). The lower bound and the scan protocol do not change with m (rows 1 and 2), as Corollary 6.2 says. The budget tables of Section 6.2 are the remaining lines of this part.

**Part 9 (Proposition 2.5, Remark 2.6).** On 100000 random pairs of distributions on 2 to 7 answers, the smallest value of (mismatch probability − TV) is −1.1·10⁻¹⁶ (zero up to rounding), and the identity for Σ_y (A − P)² holds to 6.7·10⁻¹⁶.

**Part 10 (Theorem 1.9; script `assumptions_episodes.py`, 12 seconds).** Two small scaffolds with binary answers, enumerated exactly: two sequential episodes of two messages each, and a parent episode of two messages with a child episode of one message between them. For random pairs (C, P) of samplers on visible histories, followed by a local search for a large ratio:

```
sequential episodes: largest H^2/sum_i KL_i  random 0.2910, after local search 0.4964   (proved bound 2)
nested episodes:     largest H^2/sum_i KL_i  random 0.3789, after local search 0.4978   (proved bound 4 m_e = 8)
```

Both bounds hold with room. In these scaffolds the search found no ratio above 1/2 (the value of H²/KL for two close distributions), for the nested scaffold either; this is weak evidence, from runs of three and four calls, that the factor m_e of Theorem 1.9(b) is not needed.

## 10. What remains open in this part, and what I noticed elsewhere

### 10.1 Open

1. **Nested episodes and a human who is not deterministic.** Theorem 1.9(b) has the factor 4m_e where the sequential case has 2. Is H²(Q_C, Q_P) ≤ c·Σ_i KL(Q_{C[i←P]} ‖ Q_C) true with an absolute c for nested episodes? (A search in a small nested scaffold found no ratio above 1/2: Section 9, part 10.) A version of R3 for a stochastic episodic human is also missing.
2. **Drift.** Corollary 1.12 is an upper bound. A lower bound that shows a best achievable error of positive order in K°·γ for a human drifting at rate γ, and the right exponent, are open.
3. **Without A2.** Example 2.3 shows that the Bayes mixture can destroy the member that is exact on the human system. Is there a protocol with single-call questions whose guarantee is relative to the best member measured on the *human system's* inputs? (With recorded runs the candidate's Pr4 aims at this.)
4. **Low stakes for additive work.** Theorem 6.1 is for tolerance by replication. For scaffolds as in Proposition R3a of the note I have no lower bound that contains K.
5. **The logarithm in Theorem 6.1** is settled by Proposition A2 of the referee report on `lower-bounds.md` (Remark 6.2a), if that proposition stands; it has no referee of its own.
6. **Batches.** Proposition 6.3 is an upper bound; the remark that a chain needs as many sequential batches as it has links is proved only in the limit of answers that cannot be guessed.
7. **Patch-free rehearsal.** Theorem 7.4 for a human who is not deterministic under single-call rehearsal; whether the exponential rate survives the fall-back prior of Proposition 7.5(c); how the scale δ should be chosen.
8. **Tainted questions.** Whether an ordering of rehearsal brings the expected number of tainted questions (Proposition 1.16) from L·K ln 2 down to order K.
9. **Closure through an outside resource.** A formal statement of "stationary and resettable" for a resource that is called during rehearsal (Section 4.2).

### 10.2 Noticed in other files

1. **`note.md`, first remark after Theorem R1:** "each question lowers its weight relative to the human's by an expected factor that depends on ρ only". For a deterministic human and a hypothesis that gives another answer with certainty at a fraction ρ of the calls the expected factor is 1 − ρ. In general the expected factor of the likelihood ratio is Σ_{y: P(y|x) > 0} ν(y|x), which is 1 when the human's answers have full support, however much ν deviates. What decreases is the square root of the ratio, by the factor 1 − H² per question (Theorem 3.2(b)).
2. **`note.md`, A3, and `candidate-theory.md`, A3:** the clause "not predictable (computable) by any hypothesis" is not used by any proof; the parts that are used, A3(i) to (iv) of Section 0.2, are not stated. `research/prove/rehearsal-core.md` (remark on A3) and `research/prove-b/hellinger-runs.md` (Section 8.2, item 8) already say the first half.
3. **`note.md`, Section 1, closed systems:** the definition has (C2) only; (C1) and (C3) of Definition 4.1 are needed (Examples 3.4, 3.5).
4. **`note.md`, Section 1, A1:** "One question may also stand for a long episode of work; nothing below depends on its length." True if the episode is one call. An episode with several exchanges, or with sub-calls inside it, is not one call, and its single messages cannot be rehearsed (Example 1.10); Theorems 1.7 to 1.9 are what holds.
5. **`note.md`, Theorem V1(a):** the hypothesis "let the human be deterministic" is not needed for the validity of the certificate (Proposition 2.5). **Section 3.3 and Section 8.2:** "each input is seen once, so P(·|x) is not observable at any single x … only frequencies of tests can be estimated" overstates: under A1 an input can be asked twice (Remark 2.6).
6. **`note.md`, Section 2:** "Validate. Freeze an imitator A (the last mixture, or anything else)". R1 is about M^(T) and says nothing about the last mixture; and if several candidates are validated and one that passes is deployed, the confidence of V1 has to be divided among them. The protocol does not say what is done when validation fails.
7. **`note.md`, Proposition R3a:** the term √(8L ln(1/δ)) can be √(2L ln(1/δ)): the increments Δ′_j minus their conditional means lie in an interval of length 2, and the Azuma–Hoeffding inequality with ranges gives Pr[Σ ≤ −t] ≤ exp(−2t²/(4L)).
8. **`candidate-theory.md`, Section 10:** items 1, 2, 3, 5, 6 as detailed in Section 5 above. **Section 9:** "R4 and R6 give a single coherent program" and the appeal to E5 of the record (Section 5, test 4). **Section 13, V3:** "wrong there with probability about 2^(−sep)" is a lower bound and is machine-relative; "exact if the human is isolated" holds with high probability and at an exponential rate (Theorem 7.4). **V2:** "low stakes is the only exception" (end of Section 7.2).
9. **`candidate-theory.md`, Section 0, item 3, and R3:** "about K/(θδ) questions suffice, whatever L" is true and should not be read as amplification for replicated work (Corollary 6.2).
10. **`research/prove/lower-bounds.md`, Section 5.3, item (i)** ("the factor K ln 2 … partly real … when m = 0"): Theorem 6.1 shows that the linear growth in K is forced for every m.

## 11. Literature and sources, and how they were used

No result from outside the project is used as a black box in a proof except the standard inequalities named in the first item.

* **Standard inequalities** (from memory; standard): Pinsker's inequality TV ≤ √(KL/2); H² ≤ KL/2; Markov's inequality; Hoeffding's inequality for independent variables with values in [0, 1], Pr[mean − E ≥ t] ≤ exp(−2mt²) (W. Hoeffding, "Probability inequalities for sums of bounded random variables", *Journal of the American Statistical Association* 58:13–30, 1963); Ville's inequality for a nonnegative supermartingale G with G_0 = 1, Pr[sup_n G_n ≥ c] ≤ 1/c (J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars, 1939).
* **S. Ross, G. J. Gordon, J. A. Bagnell,** "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning", AISTATS 2011, PMLR 15:627–635. Quoted from the digest `research/understand/imitation-theory.md`, Section 3.2 (whose author read the arXiv source): the definition of ε_N and the form of Theorems 3.1 and 4.1. Not read by me. Used after Theorem 2.1 for comparison only. The variant of Proposition 1.15(c), in which the human's answer continues the run, is related to the mixed roll-outs of that paper.
* **Equivalence of a mixture of strategies and a strategy that updates along the play** (H. W. Kuhn, "Extensive games and the problem of information", in *Contributions to the Theory of Games II*, Princeton University Press, 1953; from memory). Lemma 1.6 is this fact in the present setting and is proved directly.
* **T. K. Landauer (1986)** and **T. M. Bartol et al. (2015)**, full citations in Section 6.3: bibliographic data and headline figures (about 10⁹ bits; at least 4.7 bits per synapse) from web search results of this session; the papers were not read. Used only as orders of magnitude for K.
* **This repository.** `ultranatural/note.md`, Sections 4 and 5 (Propositions 7 and 8, Theorem 9 and the remarks after it): read in this session; Theorem 7.4(b) is its Theorem 9 with run distance. Results of the two papers on Solomonoff operator induction (floor D1, machine dependence D2, E5, E9, E11, F2 to F8, A9): quoted from the digest `research/understand/repo.md`, not from the papers.
* **This project.** Read in this session: `research/outline.md`, `research/candidate-theory.md`, `note.md` (all); `research/prove/lower-bounds.md` (Sections 0 to 7 and 9 to 11); `research/prove-b/hellinger-runs.md` (summary, Sections 2.1 to 2.3, 3, 4, 6, 8, Appendix A); `research/prove/rehearsal-core.md` (all that existed: Sections 0 to 4); `research/understand/notes.md` (summary, Sections 1 to 6); `research/understand/repo.md` (Sections 0, 1, 3, 4, 5 and, of Section 2, groups A and D to G and the end of C); `research/understand/alignment-proposals.md` (Sections 0, 1, 2.9 to 2.12, 3, 4, 6); `research/understand/imitation-theory.md` (Section 3.2). Proposition 1.16 is an observation of `alignment-proposals.md`, Section 6.1; Proposition 4.3 is Observation A of `notes.md`, Section 6.2; Theorem 3.2(a) is the random-stopping lemma of `notes.md` (Q14) applied to the protocol. The proof of Theorem 6.1(2) repeats that of Theorem 3.1 of `lower-bounds.md`; the proof of Theorem 7.4(a) uses the symmetrisation of the candidate's R4.
* **Referee reports.** `research/verify/lower-bounds-check.md` (the verdict of each statement; its Sections 4.1 and 4.2 with Propositions A1 and A2) and `research/verify/hellinger-runs-check.md` (the table of verdicts) were read at the end of this session; they appeared while this file was being written. Remark 6.2a quotes Proposition A2.
* **Statements about the alignment literature** in Section 8 (the number of questions of rules that answer only where the weighty hypotheses agree) are taken from the digest `alignment-proposals.md`, which refers to the digest `research/understand/ask-for-help.md`; I opened neither the latter nor any source.

