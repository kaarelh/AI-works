# An imitator built from tests alone: the online property imitator (key: property-online)

Prover's file for Sections 8.3 and 8.4 of the note (label Pr5). Everything below was derived or checked in this session; the scripts are in `research/prove-c/code/property-online_*.py` and their outputs are quoted in Section 9. Tags: **PROVED** (a statement of the lead's draft, with a complete proof here), **MODIFIED** (the lead's statement is changed, and the change is stated), **REFUTED** (with the counterexample), **NEW** (not in the lead's draft; complete proof here), **OPEN**.

## Summary table

**In one paragraph.** The lead's Theorem Pr5 and its rehearsal corollary are correct as stated. The rule can be improved in four ways at once by changing the potential (Rules N and NH of Section 3): no parameter and all n at once; the complexity of the test under the root, |S_n(B)| ≤ √((n + 1)(2·ln(1/π(B)) + ln(n + 1))); the number of rounds replaced by the number of rounds in which the test tells the two answers apart; and, for a test that the human never (or always) satisfies, at most log₂(1/π(B)) + 2 rounds, in total, at which the imitator's answer lies in (outside) the test. The last is optimal up to the 2, and it fails for the rule of Pr5, which can give about ½·√n·ln n such answers. Under rehearsal the deployed imitator gives a kind of answer the human never gives at a rate of at most (log₂(1/π(B)) + 2)/n per call slot; given the rehearsal, two-sided rates are of order 1/√n whatever the rule (the sampling error of n answers), although in expectation over the rehearsal they can be of order 1/n (Proposition 6.6). The limits are real: nothing for tests outside the family, nothing for the joint behaviour of the calls of a run, a fresh rule is needed for each run, and with an unbounded answer set the rule cannot be computed by a terminating algorithm. Against the Bayes mixture: the mixture can violate a property of constant complexity about K/(bits per pair) times in a class that contains the human, where the imitator from tests violates it at most 3 times; the mixture is far better for tests outside the family, for whole runs, and against the rule of Pr5.

| No. | Statement | Tag |
|---|---|---|
| Lemma 1.3 | Balancing lemma: if each test has a potential whose growth in a round is at most linear in that round's increment, the answer that minimises the slope-weighted score keeps the weighted sum of potentials from growing | NEW |
| Lemma 1.4 | Potentials that qualify: hyperbolic cosine with either clock, normal mixture, halving, products, mixtures | NEW |
| Theorem 2.1 | Pr5 as the lead states it: \|S_n(B)\| ≤ ln(2/π(B))/η + nη/2 on every sequence; the lead's proof is correct | PROVED |
| Example 2.3 | "The rule of Pr5 has a fast rate for tests the human never satisfies": no. With η = 1/√n and π(B) = 1/(2n) it gives at least ½·√n·ln n answers in such a test (stateless deterministic human) | NEW; the fast rate is REFUTED for the rule of Pr5 |
| Proposition 2.4 | Decreasing rate η_t = c/√t: all n at once, \|S_n(B)\| ≤ (√n/c)(ln(2/π(B)) + (c²/2)(1 + ln n)) | NEW |
| Theorem 3.1 | Rule N (no parameter; tests with values in [0, 1]): S_n(B)² ≤ (V_n(B) + 1)(2·ln(1/π(B)) + ln(V_n(B) + 1)) for all n and B, V_n(B) ≤ n the number of active rounds of B | NEW (replaces Pr5) |
| Corollary 3.2 | Readable forms: Bernstein-type bound for rare tests; a test the human never (always) satisfies is satisfied (violated) at most 2Λ(B) + ln(2Λ(B) + 4) + 2 times in total | NEW |
| Theorem 3.3 | Rule NH (set tests): the two-sided bound with 2·ln 2 added, and at most log₂(1/π(B)) + 2 rounds for one-sided tests | NEW |
| Corollary 3.4 | Deterministic human in a weighted class, tests "the answer is not ν's": at most K + 3 disagreements in total, together with the bounds for all other tests | NEW |
| Proposition 3.5 | Lower bound log₂(1/π(B)) for the one-sided count (2^m table tests) | NEW |
| Proposition 3.6 | Lower bound (√2 − 1)·√n for the two-sided books with √n tests, also (0.36·√n in root mean square) against a stateless fair-coin human with adaptively chosen questions | NEW |
| Proposition 3.7 | Grid of rates: \|S_n(B)\| ≤ (3/√2)·√(V·Λ₂) + 2√2·√(V/Λ₂)·ln(3 + ½·log₂ V), Λ₂ = ln(2/π(B)), V = V_n(B) | NEW |
| Proposition 3.8 | Tests with values in [0, 1]: bound in the sum of squared increments; one-sided total at most 4·ln(4/π(B)) | NEW |
| Proposition 4.1 | Infinite answer sets: near-minimisers cost one bit; answers from known finite sets | NEW |
| Proposition 4.2 | Convergence of the sums is automatic; the rule is computable given decidable tests, computable weights with a computable tail bound, and finite candidate sets | NEW |
| Proposition 4.3 | Truncation to finitely many tests per round, at an additive cost t_k − 1 ≤ log₂(1/π(B_k)) + 1 | NEW |
| Proposition 4.4 | With an unbounded answer set and one decidable test, every total computable rule has S_n(B) = −n on some sequence with a stateless deterministic human | NEW |
| Proposition 5.1 | Quadratic potential (Blackwell's strategy): \|S_n(B)\| ≤ √(n/π(B)) | NEW |
| Proposition 5.2 | Reduction: any algorithm for prediction with expert advice over the signed tests gives a rule with \|S_n(B)\| ≤ its regret | NEW |
| Lemma 6.1 | In rehearsal, E[g_t(B) \| past] = d_B(a_t)/L | PROVED (step of the lead's proof) |
| Theorem 6.2 | Rehearsal corollary in expectation: (a) the lead's statement, with the bounds of Section 3; (b) rare tests; (c) one-sided: at most L(K(B) + 2)/n calls per deployed run; (d) deterministic human in a class: L(K + 3)/n | MODIFIED ((a) with the bound of Pr5 is the lead's corollary, PROVED; (b)–(d) NEW) |
| Theorem 6.3 | High probability: \|Δ_n(B)\| ≤ (L/n)(\|S_n(B)\| + √(2n·ln(2/(π(B)δ)))) for all B at once; one-sided version | NEW |
| Example 6.5 | One rule kept for good: error 1/2 for every n | NEW |
| Proposition 6.6 | Quadratic rule in rehearsal under an interior condition on the human's rates: E‖S_n‖_π ≤ C(μ₀) for all n, so the expected discrepancy is of order 1/n | NEW |
| Example 7.1 | A simple property outside the family is violated in every round | NEW |
| Example 7.2 | A test of m bits is not matched within m rounds | NEW |
| Proposition 7.3 | Tests of single calls do not control runs: total variation at least 1/2 for every n | NEW |
| Proposition 7.4 | Outcomes whose human continuation value is a test of the family are matched in expectation (Theorem C2 of the digest, with Rule N) | NEW |
| Lemma 7.5, Theorem 7.6, Corollary 7.7 | Randomised version: a tilt of a base sampler driven by exponential weights; on any sequence (price: the base's logarithmic loss) and for answers drawn from P (price: the base's divergence from P); closeness to the base | NEW |
| Theorem 7.8 | Tilt driven by gradient steps: an exact identity linking the books and the divergences | NEW |
| Remark 7.9(5) | One randomised imitator with the mixture's bound under A2 and the test bound without any assumption | OPEN |
| Proposition 8.1 | Memorisers: in a class that contains the human, the mixture gives a never-given answer with probability at least (1 − p)/2 at each of the first (K − 1)/log₂(A/p) new questions; Rule NH gives it at most 3 times | NEW |
| Proposition 8.2 | Where the mixture is far better: against the rule of Pr5 (K·ln 2/n against ln n/(2√n)); for tests outside the family; for whole runs | NEW |
| Section 8.2, paragraph "What remains" | The lead's bullet "The rate" (1/√n against K/n) | MODIFIED |
| Section 10.1 | Seven open points (the logarithm in the lower bound; constants; bounded books for Rules N and NH in rehearsal; enumerable weights; and others) | OPEN |

---

## 0. Notation and conventions

The notation is that of `research/outline.md`. X and Y are countable sets of strings; x is a question and y an answer. A **test** is a set B of pairs (question, answer). The family of tests 𝓑 is countable, and every B ∈ 𝓑 has a weight π(B) > 0, with Σ_B π(B) ≤ 1. The weights need not sum to 1.

Three additions, used throughout.

* **Tests with values in [0, 1].** A test may be a function b_B: X × Y → [0, 1]; a set B is identified with its indicator, b_B(x, y) = 1[(x, y) ∈ B]. Statements that hold only for sets say "set tests". The name B is kept for the test in both cases.
* **Complexity of a test.** Λ(B) := ln(1/π(B)) (in nats) and K(B) := log₂(1/π(B)) (in bits). With π(B) = 2^(−(length of a description of B)) the number K(B) is the description length of the property.
* **The human's rate.** For a sampler P, (Pb_B)(x) := Σ_y P(y|x)·b_B(x, y). For a set test this is P(B_x | x), the probability that the human's answer to x lies in the section B_x := {y : (x, y) ∈ B}.

ln is the natural logarithm, log₂ the binary one. cosh, sinh, tanh, arcsinh are the hyperbolic functions. "Increasing" means non-decreasing unless "strictly" is added.

---

## 1. The game, balancing potentials, and one lemma

### 1.1 The game

**Definition 1.1 (the game).** Rounds are numbered t = 1, 2, …. In round t:

1. the imitator fixes a **rule** a_t: X → Y, a function of what happened in rounds 1, …, t − 1;
2. a question x_t ∈ X and an answer y_t ∈ Y (the human's) are produced. They may depend in any way on the past and on a_t. A round may also be **void**: no question is put.

For a test B the **increment** of round t is

  g_t(B) := b_B(x_t, a_t(x_t)) − b_B(x_t, y_t) ∈ [−1, 1], and g_t(B) := 0 in a void round.

For a set test, g_t(B) is +1 if the imitator's answer is in B and the human's is not, −1 in the opposite case, and 0 otherwise. The **book** of B after n rounds, its **number of active rounds**, and its **history** are

  S_n(B) := Σ_{t≤n} g_t(B),  V_n(B) := #{t ≤ n : g_t(B) ≠ 0},  γ_n(B) := (g_1(B), …, g_n(B)).

So |S_n(B)| ≤ V_n(B) ≤ n. For a set test write N_n(B) := #{t ≤ n : (x_t, a_t(x_t)) ∈ B} (the imitator's count) and h_n(B) := #{t ≤ n : (x_t, y_t) ∈ B} (the human's count). Then S_n(B) = N_n(B) − h_n(B) and V_n(B) ≤ N_n(B) + h_n(B).

Nothing is assumed about how questions and answers arise: no A1, no A2, no computability. The imitator uses no randomness, so the "adversary" who picks x_t and y_t may know a_t.

### 1.2 Balancing potentials

Let 𝔾 be the set of values an increment can take: 𝔾 = {−1, 0, 1} for set tests and 𝔾 = [−1, 1] in general. 𝔾* is the set of finite sequences γ = (g_1, …, g_k) of elements of 𝔾, including the empty sequence ∅; γg denotes γ extended by g. For γ ∈ 𝔾* write s(γ) for the sum of its entries, v(γ) for the number of its non-zero entries and |γ| for its length.

**Definition 1.2 (balancing potential).** A *balancing potential* on 𝔾 is a pair (u, c) of functions 𝔾* → ℝ with u ≥ 0, u(∅) = 1, and

  u(γg) ≤ u(γ) + g·c(γ)  for all γ ∈ 𝔾* and all g ∈ 𝔾,  (1.1)

such that c is bounded on the sequences of each length: C_k := sup{|c(γ)| : |γ| = k} < ∞ for every k. The function c is the *slope*.

The condition says that the potential of one test can grow in a round only by a term that is linear in that round's increment, with a coefficient known before the round.

**Lemma 1.3 (balancing lemma). NEW.** Let (u, c) be a balancing potential on 𝔾, and let all increments take values in 𝔾. In round t put

  F_t(x, y) := Σ_B π(B)·c(γ_{t−1}(B))·b_B(x, y)  (the *score* of answering y to x),

and let the rule satisfy, for a number ε_t ≥ 0 fixed before the round,

  F_t(x, a_t(x)) ≤ inf_{y∈Y} F_t(x, y) + ε_t  for every x ∈ X.  (1.2)

Then for every n, with E_n := ε_1 + ⋯ + ε_n,

  Σ_B π(B)·u(γ_n(B)) ≤ Σ_B π(B) + E_n ≤ 1 + E_n,  hence  u(γ_n(B)) ≤ (1 + E_n)/π(B) for every B ∈ 𝓑.

If Y is finite, or if for every x only finitely many values F_t(x, y) occur, (1.2) can be met with ε_t = 0 (an exact minimiser exists).

*Proof.* Put Ψ_t := Σ_B π(B)·u(γ_t(B)), so Ψ_0 = Σ_B π(B) ≤ 1. The series defining F_t converges absolutely and |F_t| ≤ C_{t−1}, because |c(γ_{t−1}(B))| ≤ C_{t−1}, 0 ≤ b_B ≤ 1 and Σ_B π(B) ≤ 1; in particular the infimum in (1.2) is finite. Assume Ψ_{t−1} < ∞ (true for t = 1). By (1.1), for every B, u(γ_t(B)) ≤ u(γ_{t−1}(B)) + g_t(B)·c(γ_{t−1}(B)), in a void round with g_t(B) = 0. Multiply by π(B) and sum over B; all three series converge absolutely, so

  Ψ_t ≤ Ψ_{t−1} + Σ_B π(B)·c(γ_{t−1}(B))·g_t(B).

In a void round the last sum is 0. Otherwise, by the definition of g_t and absolute convergence, it equals F_t(x_t, a_t(x_t)) − F_t(x_t, y_t), which is at most ε_t by (1.2) applied to x = x_t and y = y_t. Hence Ψ_t ≤ Ψ_{t−1} + ε_t, and by induction Ψ_n ≤ Ψ_0 + E_n. Every term of Ψ_n is non-negative, so π(B)·u(γ_n(B)) ≤ Ψ_n. ∎

The rule depends on the potential only through the slopes. The human's answer enters the proof in one place: the imitator's answer scores at most ε_t more than the human's, because the human's answer is one of the answers over which the imitator minimises. This is the only property of the answer set that is used; Section 4 returns to it.

**Lemma 1.4 (a catalogue of balancing potentials). NEW** (each item is elementary; (a) is the potential of the lead's proof). In each case s = s(γ), v = v(γ), k = |γ|.

(a) *Hyperbolic cosine, clock k.* For η > 0: u(γ) = cosh(ηs)/cosh(η)^k, c(γ) = tanh(η)·sinh(ηs)/cosh(η)^k, on 𝔾 = [−1, 1].

(b) *Hyperbolic cosine, clock v.* For η > 0: u(γ) = cosh(ηs)·e^(−vη²/2), c(γ) = e^(−(v+1)η²/2)·sinh(η)·sinh(ηs), on 𝔾 = [−1, 1]. On 𝔾 = {−1, 0, 1} also u(γ) = cosh(ηs)/cosh(η)^v with c(γ) = tanh(η)·sinh(ηs)/cosh(η)^v, and then (1.1) holds with equality.

(c) *Normal mixture.* With

  G_v(s) := (v + 1)^(−1/2)·exp(s²/(2(v + 1)))  (v = 0, 1, 2, …; s real),

u(γ) = G_v(s) and c(γ) = c^N(s, v) := (G_{v+1}(s + 1) − G_{v+1}(s − 1))/2, on 𝔾 = [−1, 1].

(d) *Halving.* Call γ *pure* if all its non-zero entries have the same sign. On 𝔾 = {−1, 0, 1}: u^H(γ) := 1 if v = 0; u^H(γ) := 2^(v−1) if v ≥ 1 and γ is pure; u^H(γ) := 0 otherwise. c^H(γ) := σ·2^(v−1) if v ≥ 1 and γ is pure with sign σ; c^H(γ) := 0 otherwise. Here (1.1) holds with equality.

(e) *Products.* For 0 < η < 1: u(γ) = (Π_i (1 + ηg_i) + Π_i (1 − ηg_i))/2 and c(γ) = η·(Π_i (1 + ηg_i) − Π_i (1 − ηg_i))/2, the products over the entries of γ, on 𝔾 = [−1, 1]. Here (1.1) holds with equality.

(f) *Mixtures.* If (u_θ, c_θ) are balancing potentials on 𝔾 for θ in a measurable space, measurable in θ, and ρ is a probability measure with sup_{|γ|=k} ∫ |c_θ(γ)| ρ(dθ) < ∞ and ∫ u_θ(γ) ρ(dθ) < ∞ for all k and γ, then (∫ u_θ ρ(dθ), ∫ c_θ ρ(dθ)) is a balancing potential on 𝔾.

*Proof.* In all cases u ≥ 0 and u(∅) = 1 are immediate. Two elementary facts are used: cosh η ≤ e^(η²/2) for real η (compare the power series: (2j)! ≥ 2^j·j!), and, for |g| ≤ 1 and real η, S,

  cosh(η(S + g)) ≤ cosh(η)·cosh(ηS) + g·sinh(η)·sinh(ηS).  (1.3)

For (1.3): the function g ↦ cosh(η(S + g)) is convex, so on [−1, 1] it lies below its chord, which is ((1 + g)/2)·cosh(η(S + 1)) + ((1 − g)/2)·cosh(η(S − 1)) = cosh(η)cosh(ηS) + g·sinh(η)sinh(ηS) by the addition formula. For g ∈ {−1, 1} it is an equality.

(a) Divide (1.3), with S = s, by cosh(η)^(k+1): u(γg) ≤ u(γ) + g·tanh(η)·sinh(ηs)/cosh(η)^k. C_k ≤ sinh(ηk).

(b) If g = 0 both sides of (1.1) equal u(γ). If g ≠ 0 then v(γg) = v + 1, and by (1.3) and cosh(η)·e^(−η²/2) ≤ 1, u(γg) = cosh(η(s + g))·e^(−(v+1)η²/2) ≤ cosh(ηs)·e^(−vη²/2) + g·e^(−(v+1)η²/2)·sinh(η)·sinh(ηs). C_k ≤ sinh(η)·sinh(ηk). For g ∈ {−1, 1}, (1.3) is an equality; dividing it by cosh(η)^(v+1) gives the second form.

(c) Let φ be the standard normal density. Completing the square, ∫ e^(ηs − (v+1)η²/2)·(2π)^(−1/2) dη = (v + 1)^(−1/2)·e^(s²/(2(v+1))), that is

  G_v(s) = ∫ e^(ηs − vη²/2) φ(η) dη = ∫ cosh(ηs)·e^(−vη²/2) φ(η) dη  (1.4)

(the second form because φ is even). So (c) is the mixture of the potentials (b) over η ∼ N(0, 1), the potential (b) being even in η: by (f), which is proved below, it is a balancing potential with slope ∫ e^(−(v+1)η²/2)·sinh(η)·sinh(ηs) φ(η) dη = ½∫ e^(−(v+1)η²/2)·(cosh(η(s + 1)) − cosh(η(s − 1))) φ(η) dη = (G_{v+1}(s + 1) − G_{v+1}(s − 1))/2. The integrability conditions of (f) hold: |s| ≤ k, and ∫ e^(|η|(k+1)) φ(η) dη < ∞. Explicitly C_k ≤ sup{G_{v+1}(|s| + 1) : |s| ≤ v ≤ k} ≤ e^((k+1)/2).

A direct check of (c) without (f): for g ≠ 0, convexity of s ↦ G_{v+1}(s) gives G_{v+1}(s + g) ≤ A + g·c^N(s, v) with A := (G_{v+1}(s + 1) + G_{v+1}(s − 1))/2 = ∫ e^(ηs)·cosh(η)·e^(−(v+1)η²/2) φ(η) dη ≤ ∫ e^(ηs)·e^(−vη²/2) φ(η) dη = G_v(s).

(d) Let γ have v non-zero entries. If v = 0: u^H(γ) = 1, c^H(γ) = 0, and γg has at most one non-zero entry, so u^H(γg) = 1 = u^H(γ) + g·0. If v ≥ 1 and γ is pure with sign σ: for g = 0, u^H(γg) = 2^(v−1); for g = σ, γg is pure with v + 1 non-zero entries, u^H(γg) = 2^v = 2^(v−1) + σ·σ·2^(v−1); for g = −σ, γg is not pure, u^H(γg) = 0 = 2^(v−1) − σ·σ·2^(v−1). If γ is not pure, neither is γg, and both sides are 0. C_k ≤ 2^(k−1).

(e) Π(1 ± ηg_i) over the entries of γg is the product over γ times (1 ± ηg); add the two and halve. Every factor is at least 1 − η > 0, so u > 0. C_k ≤ (1 + η)^k.

(f) Integrate (1.1) with respect to ρ. ∎

---

## 2. Theorem Pr5 as the lead states it

**Theorem 2.1 (Pr5: matching all tests on any sequence, one rate). PROVED** (the lead's statement and proof in `note.md`, Section 8.3, are correct). Let Y be finite and η > 0. Let a_t(x) be an answer y that minimises Σ_B π(B)·sinh(η·S_{t−1}(B))·b_B(x, y). Then for every n and every test B,

  |S_n(B)| ≤ (ln(2/π(B)) + n·ln cosh η)/η ≤ ln(2/π(B))/η + n·η/2,

which is at most √n·(ln(2/π(B)) + 1/2) for η = 1/√n. The same holds for tests with values in [0, 1], and for any Y if a minimiser exists.

*Proof.* The rule minimises the score F_t of Lemma 1.3 for the potential (a) of Lemma 1.4, because the slopes of (a) are sinh(η·S_{t−1}(B)) times the positive number tanh(η)/cosh(η)^(t−1), which is the same for all B. By Lemma 1.3 with ε_t = 0, cosh(η·S_n(B))/cosh(η)^n ≤ 1/π(B). Now e^(η|S|)/2 ≤ cosh(ηS) and cosh η ≤ e^(η²/2). ∎

*Check of the lead's proof, line by line.* (i) The potential Φ_t = Σ_B π(B)·cosh(η·S_t(B)) starts at Φ_0 = Σ_B π(B) ≤ 1. Correct. (ii) "cosh(η(S + g)) ≤ cosh(η)·cosh(ηS) + sinh(η)·sinh(ηS)·g for g ∈ {−1, 0, 1}": correct; it is (1.3). (iii) The sum Σ_B π(B)·sinh(η·S_{t−1}(B))·g_t(B) converges absolutely because |S_{t−1}(B)| ≤ t − 1; the lead does not say this, and it is needed when 𝓑 is infinite. (iv) "The last sum is the minimised quantity at (x_t, a_t(x_t)) minus the same quantity at (x_t, y_t), so it is at most 0": correct. (v) Φ_n ≤ cosh(η)^n ≤ e^(nη²/2) and π(B)·e^(η|S_n(B)|)/2 ≤ Φ_n: correct.

**Remarks 2.2 (what the statement does and does not contain).**

1. *The rate must be chosen before the game, and with it the horizon.* The bound holds for every n, but it is of order √n only for n near 1/η². For the rule with η = 1/√n₀ the bound at time n is √n₀·ln(2/π(B)) + n/(2√n₀), which is linear in n for n ≫ n₀. Section 3 removes the parameter.
2. *The complexity enters linearly.* For η = 1/√n the bound is √n·(Λ(B) + ln 2 + 1/2). The rate that is best for one test, η = √(2·ln(2/π(B))/n), gives √(2n·ln(2/π(B))), but η is common to all tests. So the lead's sentence "a property of complexity k is matched to within about k/√n" describes this rule correctly; the rules of Section 3 reach √(k/n).
3. *The clock of the test.* With the slopes of Lemma 1.4(b) in place of those of (a), that is with the rule that minimises Σ_B π(B)·e^(−V_{t−1}(B)·η²/2)·sinh(η·S_{t−1}(B))·b_B(x, y), Lemma 1.3 gives |S_n(B)| ≤ ln(2/π(B))/η + η·V_n(B)/2: the number of rounds is replaced by the number of active rounds of the test (for set tests, by (ln(2/π(B)) + V_n(B)·ln cosh η)/η with the second form of (b)). This does not remove the dependence on the horizon through η, and by itself it does not give fast one-sided rates: for a test that the human never satisfies it gives N_n(B)·(1 − η/2) ≤ ln(2/π(B))/η, which for η = 1/√n is again of order √n·Λ(B).
4. *The potential and the argument are those of Spencer's balancing games* (Section 5.1): with two answers and a human who always gives the other answer, the game is a vector balancing game, and the bound √(2n·ln(2d)) for d tests of weight 1/d at the best η is Spencer's bound for that game.
5. *The answer set.* The rule must be allowed every answer the human can give. If the human may fail to answer and this is recorded as an answer ⊥, then ⊥ must be available to the imitator, or tests that contain pairs (x, ⊥) cannot be matched: with the single test B = X × {⊥} and a human who never answers, an imitator that is not allowed ⊥ has S_n(B) = −n.
6. *The family and the weights must be fixed before the game, and the weight is a real price.* For a test chosen afterwards nothing holds: the set B := {(x_t, y_t) : t ≤ n} of the human's own pairs has h_n(B) = n, and in Example 7.1 below the imitator's count is N_n(B) = 0, so S_n(B) = −n. That the price Λ(B) cannot be dropped for a family fixed in advance is Proposition 3.5: among 2^m tests of weight 2^(−m) one has |S_m(B)| = m.

**Example 2.3 (for a test that the human never satisfies, the rule of Theorem 2.1 really gives about √n·ln(1/π(B)) answers in B). NEW** (it refutes a fast one-sided rate for the rule of Pr5; the question is raised in `research/candidate-theory.md`, Pr5). Questions are the integers ≥ 2 and the answers are 0, 1, 2. The human is the function f(x) = 0 for odd x and f(x) = 2 for even x; so the human never answers 1. There are two tests,

  B := {(x, 1) : x ∈ X} with π(B) = β,  D := {(x, 1) : x odd} ∪ {(x, 2) : x even} with π(D) = δ,

β + δ ≤ 1. The questions arrive in the order x_t = t + 1. Take the rule of Theorem 2.1 with rate η, choosing the least answer among the minimisers. Let N* be the least integer N ≥ 0 with β·sinh(ηN) ≥ δ·sinh(η). Then for every n,

  N_n(B) = min(⌊n/2⌋, N*),  and  N* ≥ (1/η)·arcsinh(η·δ/β).

For η = 1/√n, δ = 1/2 and β = 1/(2n) this is N* ≥ √n·arcsinh(√n) ≥ ½·√n·ln n. The bound of Theorem 2.1 for this test is √n·(ln(4n) + 1/2). So for this rule the order √n·ln(1/π(B)) is attained, by a deterministic stateless human and a fixed order of questions, for a test that the human never satisfies.

*Proof.* The scores of the answers 0, 1, 2 at a question x are: 0 for the answer 0 (the pair is in neither test); β·sinh(η·S(B)) + 1[x odd]·δ·sinh(η·S(D)) for the answer 1; 1[x even]·δ·sinh(η·S(D)) for the answer 2. Claim: before each odd-numbered round 2k − 1 with k − 1 < N*, the books are (S(B), S(D)) = (k − 1, 0), and the imitator has answered 1 exactly k − 1 times. This holds for k = 1. Round 2k − 1 has an even question; the scores are 0, β·sinh(η(k − 1)) ≥ 0 and 0; the least minimiser is the answer 0; the human answers 2; so g(B) = 0, g(D) = −1 and the books are (k − 1, −1). Round 2k has an odd question; the scores are 0, β·sinh(η(k − 1)) − δ·sinh(η) and 0. The middle score is negative exactly if k − 1 < N*, by the definition of N* and monotonicity of sinh. Then the imitator answers 1, the human answers 0, g(B) = g(D) = 1, and the books are (k, 0), which proves the claim for k + 1. So the imitator answers 1 in the rounds 2, 4, …, 2N* and, by the claim, in no other round up to 2N*. After round 2N* the books are (N*, 0), and N* ≥ 1 because δ·sinh(η) > 0. The next round has an even question and makes the books (N*, −1), as before. At every later odd question the scores are 0, β·sinh(ηN*) − δ·sinh(η) ≥ 0 and 0, so the imitator answers 0, as the human does; at every later even question they are 0, β·sinh(ηN*) > 0 and −δ·sinh(η) < 0, so the imitator answers 2, as the human does. All later increments are 0. This gives N_n(B) = min(⌊n/2⌋, N*). Finally β·sinh(η·N*) ≥ δ·sinh(η) ≥ δ·η gives N* ≥ arcsinh(ηδ/β)/η, and arcsinh(u) = ln(u + √(u² + 1)) ≥ ln(2u) ≥ ½·ln n for u = √n. ∎

The simulation of Section 9.2 reproduces the formula (for n = 10⁵ and β = 5·10⁻⁶: 2040 answers in B; the rule of Theorem 3.3 gives 11).

**Proposition 2.4 (a rate that decreases with time: all n at once, but with the complexity linear). NEW.** Let c > 0, η_t := c/√t, and let a_t(x) minimise Σ_B π(B)·sinh(η_t·S_{t−1}(B))·b_B(x, y) (exact minimisers). Then for every n and B,

  |S_n(B)| ≤ (√n/c)·(ln(2/π(B)) + (c²/2)·(1 + ln n)).

*Proof.* Put A_t := Σ_B π(B)·cosh(η_t·S_t(B)) for t ≥ 1 and A_0 := Σ_B π(B). By (1.3) and the choice of a_t, A_t ≤ cosh(η_t)·Σ_B π(B)·cosh(η_t·S_{t−1}(B)). Since η_t ≤ η_{t−1} and cosh is even and increasing on [0, ∞), cosh(η_t·S) ≤ cosh(η_{t−1}·S); so A_t ≤ cosh(η_t)·A_{t−1} for t ≥ 2, and A_1 ≤ cosh(η_1)·A_0 directly. Hence A_n ≤ Π_t cosh(η_t) ≤ exp(Σ_t η_t²/2) ≤ exp((c²/2)(1 + ln n)), and π(B)·e^(η_n|S_n(B)|)/2 ≤ A_n. ∎

So a time-varying rate removes the horizon at the price of a factor of order ln n on the term that does not depend on the test, and keeps the linear dependence on Λ(B). Mixing over rates (Section 3) is better in both respects.

---

## 3. The best version: one rule for all n, with the complexity under the root, and fast one-sided rates

### 3.1 The rule and the main theorem

**Rule N (normal mixture).** With G_v(s) = (v + 1)^(−1/2)·exp(s²/(2(v + 1))) as in Lemma 1.4(c), the rule of round t answers x with a y that minimises, up to ε_t in the sense of (1.2),

  F_t(x, y) = Σ_B π(B)·c^N(S_{t−1}(B), V_{t−1}(B))·b_B(x, y),  c^N(s, v) = (G_{v+1}(s + 1) − G_{v+1}(s − 1))/2.

The slope c^N(s, v) has the sign of s: an answer is penalised for lying in tests that the imitator has satisfied more often than the human, and rewarded for lying in tests it has satisfied less often. The rule has no parameter.

**Theorem 3.1 (all n at once, the complexity under the root, the clock of the test). NEW** (replaces Theorem Pr5 in the note). Let the tests have values in [0, 1] and let the imitator use Rule N. Then on every sequence of questions and answers, for every n and every test B,

  S_n(B)² ≤ (V_n(B) + 1)·(2·ln((1 + E_n)/π(B)) + ln(V_n(B) + 1)).  (3.1)

In particular, with exact minimisers (E_n = 0), for all n and all B at once,

  |S_n(B)| ≤ √((n + 1)·(2Λ(B) + ln(n + 1))).  (3.2)

*Proof.* Lemma 1.3 with the potential of Lemma 1.4(c): G_{V_n(B)}(S_n(B)) ≤ (1 + E_n)/π(B). Taking logarithms, S_n(B)²/(2(V_n(B) + 1)) − ½·ln(V_n(B) + 1) ≤ ln((1 + E_n)/π(B)), which is (3.1). The right side of (3.1) increases with V_n(B), and V_n(B) ≤ n. ∎

*Comparison with Theorem 2.1.* For η = 1/√n, Theorem 2.1 gives √n·(Λ(B) + 1.19) at the single time n. Bound (3.2) is √(n + 1)·√(2Λ(B) + ln(n + 1)), at all times. It is smaller exactly when 2Λ(B) + ln(n + 1) is below about (Λ(B) + 1.19)²; this fails only for the few tests of largest weight when n is large (for n = 10⁶ it fails when π(B) > 0.036), and there the two bounds differ by a factor of at most √(ln(n + 1))/1.19. The term ln(n + 1) is the price of not knowing n; Proposition 3.7 reduces it to order ln ln n at the cost of the constant.

**Corollary 3.2 (readable forms for set tests). NEW.** Let the tests be sets, let the imitator use Rule N with exact minimisers, and put W := 2Λ(B) + ln(V_n(B) + 1) ≤ 2Λ(B) + ln(n + 1). Write N = N_n(B) and h = h_n(B) for the imitator's and the human's counts. Then for every n and B:

(a) (*a test that is rare for the human is rare for the imitator*) h − √((2h + 1)·W) ≤ N ≤ h + √((2h + 1)·W) + W.

(b) (*a test the human never satisfies*) If h_n(B) = 0, then N_n(B) ≤ 2Λ(B) + ln(2Λ(B) + 4) + 2.

(c) (*a test the human always satisfies*) If (x_t, y_t) ∈ B in every non-void round t ≤ n, the number of rounds t ≤ n with (x_t, a_t(x_t)) ∉ B is at most 2Λ(B) + ln(2Λ(B) + 4) + 2.

*Proof.* By (3.1), S² ≤ (V + 1)·W with S = N − h and V = V_n(B) ≤ N + h. (a) If N ≥ h put D := N − h; then D² ≤ (2h + D + 1)·W, so D ≤ (W + √(W² + 4(2h + 1)W))/2 ≤ W + √((2h + 1)W). If N < h put D′ := h − N; then N + h + 1 ≤ 2h and D′² ≤ (2h + 1)·W. (b) Here S = N = V, so N² ≤ (N + 1)·(2Λ + ln(N + 1)) with Λ = Λ(B). Since N²/(N + 1) ≥ N − 1, the function ψ(N) := N − 1 − ln(N + 1), which is increasing on [0, ∞), satisfies ψ(N) ≤ 2Λ. Put N₀ := 2Λ + ln(2Λ + 4) + 2. Then ψ(N₀) − 2Λ = ln(2Λ + 4) + 1 − ln(2Λ + 3 + ln(2Λ + 4)) > 0, because e·(2Λ + 4) > 2Λ + 3 + ln(2Λ + 4). So N ≤ N₀. (c) Now every non-zero increment is −1, the number M of rounds in question equals V = −S, and M² ≤ (M + 1)·(2Λ + ln(M + 1)) as in (b). ∎

Part (a) is a bound of Bernstein type: the error for a test of count h is of order √(h·Λ(B)) + Λ(B), not √(n·Λ(B)). Parts (b) and (c) answer the question of item 2 of the task: **yes**. For a test that the human never satisfies, the imitator's answer lies in the test at most 2Λ(B) + O(ln Λ(B)) times in total, for all n, together with the two-sided guarantee (3.2) for all tests. In bits this is 1.39·K(B) + O(ln K(B)). The next theorem brings the constant down to 1.

### 3.2 The sharp one-sided bound

**Rule NH (normal mixture and halving).** For set tests: as Rule N, with the slopes

  c^NH(γ) := ½·c^N(s(γ), v(γ)) + ½·c^H(γ),

c^H the slope of the halving potential of Lemma 1.4(d): c^H(γ_{t−1}(B)) is σ·2^(V_{t−1}(B)−1) if V_{t−1}(B) ≥ 1 and all non-zero increments of B so far had the sign σ, and 0 otherwise.

**Theorem 3.3 (the two-sided bound and the halving bound together). NEW.** Let the tests be sets and let the imitator use Rule NH with exact minimisers. Then on every sequence, for every n and every test B:

(i) S_n(B)² ≤ (V_n(B) + 1)·(2Λ(B) + 2·ln 2 + ln(V_n(B) + 1)), hence |S_n(B)| ≤ √((n + 1)·(2Λ(B) + 1.39 + ln(n + 1)));

(ii) if all non-zero increments of B up to round n have the same sign, then V_n(B) ≤ K(B) + 2. In particular: if the human's answer was never in B, the imitator's answer was in B in at most K(B) + 2 rounds; if the human's answer was always in B, the imitator's answer was outside B in at most K(B) + 2 rounds.

With ε_t-minimisers the same holds with π(B) replaced by π(B)/(1 + E_n).

*Proof.* By Lemma 1.4(c), (d) and (f), (½·G_v(s) + ½·u^H, c^NH) is a balancing potential on {−1, 0, 1}. Lemma 1.3 gives ½·G_{V_n(B)}(S_n(B)) + ½·u^H(γ_n(B)) ≤ 1/π(B), and both terms are non-negative. From G_{V_n(B)}(S_n(B)) ≤ 2/π(B) follows (i) as in Theorem 3.1. If γ_n(B) is pure and V_n(B) ≥ 1 then u^H(γ_n(B)) = 2^(V_n(B)−1) ≤ 2/π(B), which is (ii). If the human's answer is never in B, every non-zero increment is +1 and V_n(B) = N_n(B); if it is always in B, every non-zero increment is −1 and V_n(B) counts the rounds in which the imitator's answer is outside B. ∎

**Corollary 3.4 (a deterministic human in a weighted class: tests alone give the halving bound). NEW.** Let H be a countable class of functions ν: X → Y with weights w(ν) > 0, Σ_ν w(ν) ≤ 1, and for ν ∈ H let B_ν := {(x, y) : y ≠ ν(x)} ("the answer is not the one ν gives"). Let 𝓑₀ be any countable family of set tests with weights π₀, Σ π₀ ≤ 1. Run Rule NH on the family 𝓑₀ ∪ {B_ν : ν ∈ H} with weights π₀(B)/2 and w(ν)/2. If the human is a function f ∈ H, that is y_t = f(x_t) in every round, then on every sequence of questions the imitator's answer differs from the human's in at most K + 3 rounds in total, K = log₂(1/w(f)); and (i) and (ii) of Theorem 3.3 hold for every B ∈ 𝓑₀ with K(B) = log₂(1/π₀(B)) + 1, whether or not the human is in H.

*Proof.* The test B_f is never satisfied by the human and has weight w(f)/2; apply Theorem 3.3(ii). ∎

So for a deterministic human the "price" K of the human and the price K(B) of a property are paid in one imitator, each for what it buys: at most K + 3 rounds of disagreement if the human is in the class, and at most log₂(1/π₀(B)) + 3 violations of a property B ∈ 𝓑₀ that the human always has, whatever the human is. (Section 8 shows that the Bayes mixture does not have the second property.)

**Proposition 3.5 (the one-sided bound is optimal up to the additive 2). NEW** (the argument is the standard lower bound of the mistake-bound model). Let m ≥ 1, X = {1, …, m}, Y = {0, 1}, and let the family consist of the 2^m tests B_c := {(x, y) : y ≠ c(x)}, c ∈ {0, 1}^X, each of weight 2^(−m). For every imitator (any rules a_t, each a function of the past) take the questions x_t = t and the answers y_t := 1 − a_t(t), t = 1, …, m, and put c*(t) := y_t. Then the human is the function c*, the test B_{c*} is never satisfied by the human, and N_m(B_{c*}) = m = K(B_{c*}).

*Proof.* (t, y_t) ∉ B_{c*} because y_t = c*(t); (t, a_t(t)) ∈ B_{c*} because a_t(t) = 1 − y_t ≠ c*(t). ∎

### 3.3 The two-sided rate cannot be improved beyond the logarithm

**Proposition 3.6 (√n is forced once there are about √n tests). NEW** (the argument is the lower bound for vector balancing games; see Section 5.1). Let d, n ≥ 1, X = {−1, 1}^d, Y = {0, 1}, and B_k := {(x, y) : y = 1[x_k = 1]} for k = 1, …, d, each of weight 1/d.

(a) For every imitator there are questions and answers (x_t, y_t), t ≤ n, such that D := max_{t≤n} max_k |S_t(B_k)| ≥ √n/(√(1 + n/d²) + √n/d). So D ≥ (√2 − 1)·√n if d ≥ √n.

(b) If the human answers every question with a fair coin (y_t uniform on {0, 1} and independent of everything before it), there are questions x_t, functions of the past and of a_t, such that D₂ := max_{t≤n} (E max_k S_t(B_k)²)^(1/2) ≥ √n/(√(2 + n/d²) + √n/d). So D₂ ≥ 0.36·√n if d ≥ √n.

For this family (3.2) gives max_k |S_n(B_k)| ≤ √((n + 1)(2·ln d + ln(n + 1))). So the order √n cannot be improved, on arbitrary sequences, for families of √n tests, even against a stateless human; what remains open is the logarithm.

*Proof.* If the human's answer is y = 1 − a, where a = a_t(x) is the imitator's, then for every k the increment is g(B_k) = 1[a = 1[x_k = 1]] − 1[1 − a = 1[x_k = 1]] = (2a − 1)·x_k. So the vector of increments is ε·x with ε := 2a − 1 ∈ {−1, 1}; if y = a it is 0. Write S_t for the vector (S_t(B_k))_k, ‖·‖₂ and ‖·‖_∞ for the Euclidean and the maximum norm. For every vector S there is x ∈ X with |⟨x, S⟩| ≤ ‖S‖_∞: choose x_1 arbitrarily and then x_k so that x_k·S(k) does not have the sign of the partial sum Σ_{j<k} x_j·S(j); the partial sums then stay in [−‖S‖_∞, ‖S‖_∞] by induction.

(a) Let x_t be such an x for S = S_{t−1} and y_t := 1 − a_t(x_t). Then ‖S_t‖₂² = ‖S_{t−1}‖₂² + 2ε_t⟨x_t, S_{t−1}⟩ + d ≥ ‖S_{t−1}‖₂² + d − 2D. Hence d·D² ≥ ‖S_n‖₂² ≥ n·(d − 2D), that is D² + (2n/d)·D − n ≥ 0, and D ≥ √(n²/d² + n) − n/d = √n/(√(1 + n/d²) + √n/d).

(b) With the same questions, the indicator m_t of the event y_t ≠ a_t(x_t) is a fair coin independent of the past and of x_t, and the vector of increments is m_t·ε_t·x_t. So E[‖S_t‖₂² | past, x_t] = ‖S_{t−1}‖₂² + ½·(2ε_t⟨x_t, S_{t−1}⟩ + d) ≥ ‖S_{t−1}‖₂² + d/2 − ‖S_{t−1}‖_∞. Taking expectations, and using E‖S_t‖_∞ ≤ D₂ and E‖S_n‖₂² ≤ d·E‖S_n‖_∞² ≤ d·D₂²: d·D₂² ≥ n·d/2 − n·D₂, so D₂ ≥ (√(n²/d² + 2n) − n/d)/2 = √n/(√(2 + n/d²) + √n/d). For d ≥ √n this is at least √n/(√3 + 1). ∎

### 3.4 Two variants

**Proposition 3.7 (iterated-logarithm form: a grid of rates). NEW** (the mixture over rates is the device of the digest `understand/indistinguishability.md`, §3.7, Remark; here with the clock of the test and a complete calculation). Let η_i := 2^(−i) and ρ_i := 1/((i + 1)(i + 2)) for i = 0, 1, 2, …, and let the imitator use the slopes

  c^G(γ) := Σ_{i≥0} ρ_i·e^(−(v+1)η_i²/2)·sinh(η_i)·sinh(η_i·s)  (s = s(γ), v = v(γ))

with exact minimisers; the tests may have values in [0, 1]. Then for every n, B and i ≥ 0,

  |S_n(B)| ≤ (ln(2/π(B)) + ln((i + 1)(i + 2)))/η_i + η_i·V_n(B)/2.  (3.3)

Consequently, with Λ₂ := ln(2/π(B)) and V := V_n(B): if V ≥ 2Λ₂ then

  |S_n(B)| ≤ (3/√2)·√(V·Λ₂) + 2√2·√(V/Λ₂)·ln(3 + ½·log₂ V),

and if V < 2Λ₂ then trivially |S_n(B)| ≤ V < 2Λ₂.

*Proof.* Σ_i ρ_i = 1, and by Lemma 1.4(b) and (f) the mixture is a balancing potential (the integrability condition holds because Σ_i ρ_i·sinh(η_i)·sinh(η_i·k) ≤ sinh(1)·sinh(k)). Lemma 1.3 gives Σ_i ρ_i·cosh(η_i·S_n(B))·e^(−V_n(B)·η_i²/2) ≤ 1/π(B); each term is non-negative and cosh(u) ≥ e^(|u|)/2, which gives (3.3). Let V ≥ 2Λ₂, put η* := √(2Λ₂/V) ≤ 1 and let i be the least integer with 2^(−i) ≤ η*. Then η*/2 < η_i ≤ η*, so Λ₂/η_i < 2Λ₂/η* = √(2Λ₂V) and η_i·V/2 ≤ η*·V/2 = √(Λ₂V/2); their sum is (3/√2)·√(VΛ₂). Also i < log₂(1/η*) + 1 = ½·log₂(V/(2Λ₂)) + 1 ≤ ½·log₂ V + 1, because 2Λ₂ ≥ 2·ln 2 > 1; hence ln((i + 1)(i + 2))/η_i < 2·ln(i + 2)·(2/η*) ≤ 2√2·√(V/Λ₂)·ln(3 + ½·log₂ V). ∎

*Remark (the constant).* With the mixing measure dη/(η·ln²(1/η)) on (0, 1/e] in place of the grid, Lemma 1.3 gives ∫ e^(η|S_n(B)| − V_n(B)η²/2) dη/(η·ln²(1/η)) ≤ 2/π(B). This is inequality (12) of Chernov and Vovk (2010; Section 5.3 below) with their regret replaced by |S_n(B)|, their T by V_n(B) and their 1/ε by 2/π(B); they deduce from it the bound (1 + 1/ln T)·√(2T·ln(1/ε) + 5T·ln ln T) + O(ln(1/ε)) (their (14)). I have not re-derived that deduction; nothing below uses it.

**Proposition 3.8 (tests with values in [0, 1]: a bound in the sum of squares, and the one-sided rate). NEW** (the potential is that of Koolen and van Erven's iProd; Section 5.3). Let η_i := 2^(−i) and ρ′_i := 1/(i(i + 1)) for i = 1, 2, …, and let the imitator use the slopes c(γ) := Σ_{i≥1} ρ′_i·η_i·(Π_j (1 + η_i·g_j) − Π_j (1 − η_i·g_j))/2, the products over the entries g_j of γ, with exact minimisers. Put Q_n(B) := Σ_{t≤n} g_t(B)². Then for every n, B and i ≥ 1,

  |S_n(B)| ≤ ln(2i(i + 1)/π(B))/η_i + η_i·Q_n(B).

In particular (i = 1): |S_n(B)| ≤ 2·ln(4/π(B)) + Q_n(B)/2; and if the human's answers always have value 0 under B (b_B(x_t, y_t) = 0 for all t ≤ n), then Σ_{t≤n} b_B(x_t, a_t(x_t)) ≤ 4·ln(4/π(B)).

*Proof.* Σ_{i≥1} ρ′_i = 1. By Lemma 1.4(e), (f) and Lemma 1.3, Σ_i ρ′_i·(Π_t (1 + η_i·g_t(B)) + Π_t (1 − η_i·g_t(B)))/2 ≤ 1/π(B), all factors being positive. So for each sign σ and each i, Σ_t ln(1 + σ·η_i·g_t(B)) ≤ ln(2/(π(B)·ρ′_i)). Since η_i ≤ 1/2 and ln(1 + u) ≥ u − u² for u ≥ −1/2 (the function ln(1 + u) − u + u² vanishes at 0 and has the derivative u(2u + 1)/(1 + u), which has the sign of u on (−1/2, ∞)), the left side is at least σ·η_i·S_n(B) − η_i²·Q_n(B). For the last claim, g_t(B) = b_B(x_t, a_t(x_t)) ∈ [0, 1], so Q_n(B) ≤ S_n(B) and S_n(B) ≤ 2·ln(4/π(B)) + S_n(B)/2. ∎

---

## 4. Infinite answer sets, infinitely many tests, and what must be computable

**Proposition 4.1 (near-minimisers; answers from a known finite set). NEW.**

(a) For any Y and any balancing potential, a rule with (1.2) exists for every ε_t > 0, and with ε_t := 2^(−t) all bounds of Sections 2 and 3 hold with π(B) replaced by π(B)/2, that is with Λ(B) + ln 2 in place of Λ(B) and K(B) + 1 in place of K(B).

(b) Suppose that for every x a finite set Y(x) ⊆ Y is given and the human's answer always lies in it: y_t ∈ Y(x_t). Then the rule may minimise over Y(x) only: all results hold for a rule with F_t(x, a_t(x)) = min_{y∈Y(x)} F_t(x, y). An instance is Y(x) = the strings of length at most ℓ(x).

(c) If in (b) the human's answer may fall outside Y(x_t), let such rounds count as void (the books are not changed). Then all results hold for the books so defined, with n the number of all rounds.

*Proof.* (a) |F_t| ≤ C_{t−1} < ∞, so the infimum over y is finite and is approached; E_n = Σ_{t≤n} 2^(−t) < 1, and the bounds of Lemma 1.3, Theorems 3.1 and 3.3 and their corollaries depend on E_n only through the factor 1 + E_n ≤ 2 dividing π(B). (b), (c) The proof of Lemma 1.3 uses the rule only through F_t(x_t, a_t(x_t)) ≤ F_t(x_t, y_t) + ε_t in the rounds that are not void. ∎

**Proposition 4.2 (convergence and computability with finitely many candidate answers). NEW.** The series F_t(x, y) converges absolutely for every balancing potential (proof of Lemma 1.3); nothing has to be assumed about the tests for this. Let the tests be enumerated as B_1, B_2, …, and assume:

(i) (k, x, y) ↦ b_{B_k}(x, y) is computable (for set tests: membership is decidable uniformly in k);
(ii) the weights π(B_k) are computable real numbers, uniformly in k;
(iii) there is a computable function j ↦ N(j) with Σ_{k>N(j)} π(B_k) ≤ 2^(−j);
(iv) the finite candidate sets Y(x) of Proposition 4.1(b) are computable from x.

Then for each potential of Lemma 1.4(a) to (e), and for Rules N and NH, a rule that satisfies F_t(x, a_t(x)) ≤ min_{y∈Y(x)} F_t(x, y) + 2^(−t) is computable from x and the record of rounds 1, …, t − 1.

*Proof.* From the record and (i) one computes the histories γ_{t−1}(B_k). The slopes c(γ) of Lemma 1.4(a) to (e) are computable real functions of γ, bounded by the computable number C_{t−1}. Choose j with C_{t−1}·2^(−j) ≤ 2^(−t)/6; by (iii) the terms with k > N(j) change F_t by at most 2^(−t)/6. Compute the remaining finite sum to within 2^(−t)/6 for each y ∈ Y(x), and output a y whose approximate value is least. Its true value exceeds the true minimum by at most 4·2^(−t)/6. ∎

**Proposition 4.3 (truncation: finitely many tests per round, no tail bound). NEW.** Let (u, c) be a balancing potential with c(∅) = 0 (true for all potentials of Lemma 1.4), let B_1, B_2, … enumerate the tests, and let 0 = M_0 ≤ M_1 ≤ M_2 ≤ ⋯ be integers. Say that B_k *enters* in round t_k := min{t ≥ 1 : M_t ≥ k}, and let γ′_t(B_k) := (g_{t_k}(B_k), …, g_t(B_k)) be its history from then on. If the rule of round t satisfies (1.2) for the finite score

  F′_t(x, y) := Σ_{k ≤ M_{t−1}} π(B_k)·c(γ′_{t−1}(B_k))·b_{B_k}(x, y),

then u(γ′_n(B_k)) ≤ (1 + E_n)/π(B_k) for every k and every n ≥ t_k. Consequently every bound of Sections 2 and 3 holds for the books counted from round t_k, and |S_n(B_k)| exceeds the corresponding bound by at most t_k − 1. With M_t = 2^t − 1 and weights in non-increasing order, t_k − 1 ≤ log₂(k + 1) ≤ K(B_k) + 1.

*Proof.* Put Ψ′_t := Σ_{k≤M_t} π(B_k)·u(γ′_t(B_k)). For a test that enters in round t, u(γ′_t(B_k)) = u((g_t(B_k))) ≤ u(∅) + g_t(B_k)·c(∅) = 1. For the others (1.1) applies as in Lemma 1.3. Hence Ψ′_t ≤ Ψ′_{t−1} + Σ_{M_{t−1}<k≤M_t} π(B_k) + ε_t, and Ψ′_n ≤ Σ_{k≤M_n} π(B_k) + E_n ≤ 1 + E_n. Before it enters, a test's book changes by at most 1 per round. If the weights are non-increasing, k·π(B_k) ≤ Σ_{j≤k} π(B_j) ≤ 1, so log₂ k ≤ K(B_k); and t_k = ⌈log₂(k + 1)⌉ for M_t = 2^t − 1. ∎

With truncation, hypotheses (ii) and (iii) of Proposition 4.2 reduce to: each π(B_k) is a computable real. For weights that are only enumerable from below, such as 2^(−(prefix complexity of B)), the rule is not computable; it is the limit of the computable rules obtained from the lower approximations of the weights. I have not examined whether the bounds survive that limit.

**Proposition 4.4 (infinite answer sets: near-minimisers exist but cannot in general be computed). NEW.** Let X be the set of (codes of) Turing machines, Y the set of all strings, and

  B := {(x, y) : y is the record of a halting computation of the machine x on the empty input},

a decidable set; let 𝓑 = {B} with π(B) = 1. Let the human be the function f with f(x) := the record of the halting computation of x if x halts, and the empty string otherwise (a stateless deterministic human, not a computable one).

(a) Rule N with exact minimisers has |S_n(B)| ≤ 1 for all n on every sequence of questions.

(b) For every imitator whose rule a_t(x) is a total computable function of x and of the record of rounds 1, …, t − 1, there is a sequence of questions on which S_n(B) = −n for every n.

So the theorems for infinite Y are statements about rules that search the answer set without a bound; with a single decidable test they cannot be realised by an algorithm that always terminates. They can be realised relative to the halting problem: for finitely many decidable set tests (Proposition 4.3), whether some answer y has a given pattern of memberships at x is a question of the form "there is y such that (decidable)", and once the realisable patterns are known a minimiser is found by search.

*Proof.* (a) With one set test the score of an answer y is c·1[(x, y) ∈ B], where c has the sign of S_{t−1}(B). If S_{t−1}(B) < 0, an exact minimiser answers inside B_x whenever B_x is not empty, and then g_t(B) ≥ 0; if B_x is empty, the imitator's and the human's answers are both outside B and g_t(B) = 0. If S_{t−1}(B) > 0, the minimiser answers outside B_x (possible because the empty string is not a record), and g_t(B) ≤ 0. If S_{t−1}(B) = 0 then |g_t(B)| ≤ 1. So the book never leaves {−1, 0, 1}. (b) Fix the record before round t. The function x ↦ a_t(x) is total and computable. If (x, a_t(x)) ∈ B held for every halting machine x, then "x halts" would be equivalent to "(x, a_t(x)) ∈ B", which is decidable; this contradicts the undecidability of the halting problem. So there is a halting machine x_t with (x_t, a_t(x_t)) ∉ B. The human's answer f(x_t) is in B, so g_t(B) = −1. ∎

*What this says for the note.* "Unlimited compute" suffices in the usual sense (a terminating computation, however long) when the human's answers come from a known finite set for each question, for instance answers of bounded length. If the answer set is unbounded, the property imitator needs to decide whether an answer with given properties exists, which is a search that need not terminate; the example shows that no terminating substitute exists, even for one test and a stateless human.

---

## 5. Relation to the literature

Every proof in this file is self-contained; no theorem of the literature is *used*. This section says which published arguments are the *same* argument and which are only analogous. For each source I say whether I read it in this session. "Read" means: I read the cited statement in the paper's text (arXiv version) during this session. "Digest" means: quoted from `research/understand/indistinguishability.md`. "Memory" means: bibliographic data or statement from memory, not checked in this session.

### 5.1 Balancing games: the lead's potential argument is Spencer's

In a *balancing game* (J. Spencer, "Balancing games", J. Combin. Theory Ser. B 23 (1977) 68–74; not read) a Pusher names a vector v_t and a Chooser a sign ε_t, and the Chooser wants the signed sum Σ ε_t·v_t to stay small. I. Bárány, "A special balancing game, Victor Grinberg's question", arXiv:2412.08238v1 (2024), Section 1 (read) reports: "Balancing games were introduced by Joel Spencer", and for vectors and norm given by the unit ball of the maximum norm in R^d Spencer "showed that the value of this game is between" √(1 − 1/d)·√n and √(2·log 2d)·√n (the typesetting of the lower constant did not survive the extraction of the text; I read it as √(1 − 1/d)). N. Bansal, H. Jiang, S. Singla and M. Sinha, "Online vector balancing and geometric discrepancy", arXiv:1912.03350 (STOC 2020 per memory), Section 1 (read) state the online vector balancing question as "originally proposed by Spencer", and mention "Bárány's lower bound for online discrepancy" (I. Bárány, J. Combin. Theory Ser. A 26 (1979) 115–126; not read).

*Exact relation.* Take Y = {0, 1} and a human who always gives the answer the imitator does not give. Then the vector of increments is ε_t·v_t with ε_t = 2a_t(x_t) − 1 and v_t(B) = b_B(x_t, 1) − b_B(x_t, 0) ∈ [−1, 1] (proof of Proposition 3.6). So this special case of the game of Definition 1.1 *is* the balancing game for the maximum norm, with the tests as coordinates and the questions as the Pusher's vectors. For d tests of weight 1/d, Theorem 2.1 at the rate η = √(2·ln(2d)/n) gives √(2n·ln(2d)), which is the upper bound that Bárány attributes to Spencer; I take it (from memory of Spencer's method of weight functions, not checked) that the proof is the same hyperbolic-cosine potential. Theorem 2.1 extends that statement in three directions: more than two answers, a reference answer (the human's) that need not be the opposite one, and weighted countable families. Proposition 3.6 is the Pusher's strategy "play a vector nearly orthogonal to the current sum".

### 5.2 Blackwell approachability

*Statement* (D. Blackwell, "An analog of the minimax theorem for vector payoffs", Pacific J. Math. 6 (1956) 1–8; not read. I quote the statements from V. Perchet, "Approachability, regret and calibration; implications and equivalences", arXiv:1301.2663v1 (2013), Definition 1.2, Theorems 1.1 and 1.3 (read), and from J. Abernethy, P. Bartlett and E. Hazan, "Blackwell approachability and low-regret learning are equivalent", arXiv:1011.1936v1 (COLT 2011 per memory), Theorem 3 (read).) In a repeated game with vector payoffs g(a, b) ∈ R^d, a closed set E is approachable by the player if for every point z there are a nearest point π of E and a mixed action x such that ⟨g(x, y) − π, z − π⟩ ≤ 0 for all mixed actions y of Nature; the strategy that plays this x at z = the current average payoff ensures that the expected Euclidean distance of the average payoff to E is at most 2·√(κ₀/n), κ₀ = sup ‖g(a, b)‖₂² (Perchet, Theorem 1.1). A closed convex set C is approachable if and only if for every mixed y there is a mixed x with g(x, y) ∈ C (Perchet, Theorem 1.3; Abernethy, Bartlett and Hazan, Theorem 3, where the condition is called response-satisfiability).

*Exact relation.* In the game of Definition 1.1 the payoff vector is (g_t(B))_B and the target is C = {0}. The condition holds trivially: if the imitator knew the human's answer it could give the same answer. Blackwell's own strategy uses the squared Euclidean distance as potential. With tests in place of coordinates it reads "minimise Σ_B π(B)·S_{t−1}(B)·b_B(x, y)", and its guarantee is the following.

**Proposition 5.1 (the quadratic potential: Blackwell's strategy for this game). NEW** (routine). If a_t(x) minimises Σ_B π(B)·S_{t−1}(B)·b_B(x, y), then Σ_B π(B)·S_n(B)² ≤ Σ_{t≤n} Σ_B π(B)·g_t(B)² ≤ n, hence |S_n(B)| ≤ √(n/π(B)) for every n and B.

*Proof.* S_t(B)² = S_{t−1}(B)² + 2·S_{t−1}(B)·g_t(B) + g_t(B)². Multiply by π(B) and sum: the middle terms sum to 2·(score of the imitator's answer − score of the human's answer) ≤ 0. ∎

So Blackwell's theorem as stated (finite dimension, Euclidean distance) gives the rate 1/√n with the weight of the test *outside* the logarithm: √(1/π(B)) in place of √(ln(1/π(B))). The step from the first to the second is the replacement of the quadratic potential by an exponential one. That step is "potential-based approachability" (S. Hart and A. Mas-Colell, "A general class of adaptive strategies", J. Econom. Theory 98 (2001) 26–54; N. Cesa-Bianchi and G. Lugosi, "Potential-based algorithms in on-line prediction and game theory", Machine Learning 51 (2003) 239–261; neither read; both as described in Perchet's Section 1.4.3, read, which states that approachability "with respect to the supremum norm can be achieved using some potential minimization, generalizing the exponential weight algorithm"). Two published statements contain the finite, unweighted case of Theorem 2.1 up to the constant:

* D. Lee, G. Noarov, M. Pai and A. Roth, "Online minimax multiobjective optimization: multicalibeating and other applications", arXiv:2108.03837v3 (NeurIPS 2022), Theorem 2.1 (read): in a game with a d-dimensional loss in [−C, C]^d, convex in the learner's action and concave in the adversary's, their Algorithm 1 "obtains, against any Adversary, AMF regret bounded by R^T ≤ 4C·√(T·ln d)", where the AMF regret is the largest coordinate of the cumulative loss minus the sum of the values the learner could secure if the adversary moved first. In our game with finitely many tests and a finite Y, take the 2|𝓑| coordinates ±g_t(B) and mixed answers; the adversary-moves-first value is 0, the minimax action of their Algorithm 1 is a pure answer (the minimiser of a linear score), and the theorem gives max_B |S_n(B)| ≤ 4·√(n·ln(2|𝓑|)) for n ≥ ln(2|𝓑|). Their Theorem 5.1 (read) is the corresponding statement for approaching a polytope with |H| facets: for t ≥ 64·ln|H|/ε² the average payoff violates no facet by more than ε in expectation; they note that it "is equivalent to the results of Perchet [2015]" (V. Perchet, "Exponential weight approachability, applications to calibration and regret minimization", Dynamic Games and Applications 5 (2015) 136–153; not read).
* Abernethy, Bartlett and Hazan, Algorithm 2 and Proposition 2 (read): an algorithm for online linear optimisation is converted into an approachability algorithm by playing, in each round, an action that satisfies the halfspace named by the optimisation algorithm's current point. All rules of this file are instances: the "halfspace oracle" is the minimisation over answers, and the optimisation algorithm is an algorithm for prediction with expert advice over the signed tests. The next proposition states this.

**Proposition 5.2 (reduction to prediction with expert advice). NEW** (an instance of the conversion of Abernethy, Bartlett and Hazan). Let 𝔄 be an algorithm for prediction with expert advice over the experts (B, σ), B ∈ 𝓑, σ ∈ {+1, −1}: in each round it outputs weights w_t(B, σ) ≥ 0 with finite sum, then receives losses ℓ_t(B, σ) ∈ [−1, 1], and it guarantees Σ_{t≤n} (Σ_{B′,σ′} w_t(B′, σ′)·ℓ_t(B′, σ′))/(Σ_{B′,σ′} w_t(B′, σ′)) − Σ_{t≤n} ℓ_t(B, σ) ≤ R_n(B, σ) on every sequence of losses. Let the imitator answer x with a minimiser of Σ_{B,σ} w_t(B, σ)·σ·b_B(x, y) and feed 𝔄 the losses ℓ_t(B, σ) := −σ·g_t(B). Then |S_n(B)| ≤ max_σ R_n(B, σ) for every n and B.

*Proof.* Σ_{B,σ} w_t(B, σ)·ℓ_t(B, σ) = −(score of the imitator's answer − score of the human's answer) ≥ 0. So the algorithm's loss is non-negative in every round, and R_n(B, σ) ≥ −Σ_t ℓ_t(B, σ) = σ·S_n(B). ∎

Theorem 2.1 is this reduction for exponential weights with prior π(B)/2 on each signed test; Theorem 3.1, Proposition 3.7 and Proposition 3.8 correspond to the parameter-free algorithms of Section 5.3.

### 5.3 Prediction with expert advice without a learning rate

* A. Chernov and V. Vovk, "Prediction with advice of unknown number of experts", arXiv:1006.0475v1 (UAI 2010 per memory), Theorems 7 to 9 (read). Theorem 8 mixes the supermartingales exp((L_T − L_T^n)·η − T·η²/2) over η with the measure dη/(η·ln²(1/η)) on [0, 1/e] and obtains, for all T and ε, a regret to the ε-quantile of experts of at most (1 + 1/ln T)·√(2T·ln(1/ε) + 5T·ln ln T) + O(ln(1/ε)); Theorem 9 gives 2·√(T·ln(1/ε)) + 7·√T; both hold "if each of finitely or infinitely many Experts is assigned some positive weight p_n, the sum of all weights being not greater than 1". The potentials (b) and (c) of Lemma 1.4 are of this kind (a mixture over η of exp(ηS − clock·η²/2)); the normal mixing measure of (c) is chosen here because it gives a closed form. The method of mixing over η to obtain bounds that hold at all times goes back to H. Robbins, "Statistical methods related to the law of the iterated logarithm", Ann. Math. Statist. 41 (1970) 1397–1409 (memory).
* H. Luo and R. Schapire, "Achieving all with no parameters: adaptive NormalHedge", arXiv:1502.05934v1 (COLT 2015 per memory), Section 3 and Lemma 1 of the appendix (read). Their potential is Φ(R, C) = exp([R]₊²/(3C)) and their weights are w(R, C) = ½·(Φ(R + 1, C + 1) − Φ(R − 1, C + 1)), with C the sum of the absolute values of the instantaneous regrets; Theorem 1 bounds the regret to a competitor u by √(3·(u·C_T)·(RE(u‖q) + ln B + ln(1 + ln N))) with B ≤ 5/2 + (3/2)·ln(1 + T). Rule N has the same form of weights, a difference of the potential at s + 1 and s − 1 with the clock advanced by one. Its potential (v + 1)^(−1/2)·exp(s²/(2(v + 1))) has the factor 2 in place of 3 and the prefactor (v + 1)^(−1/2); with these the weighted sum of potentials does not increase at all (Lemma 1.4(c)), where their Lemma 1 has an additive error 3|r|/(2(C + 1)). For set tests the clock V_n(B) is their C. The resulting bound (3.1) has the constant 2 where theirs has 3, and the term ln(V + 1) where theirs has a term of order ln ln T.
* W. Koolen and T. van Erven, "Second-order quantile methods for experts and combinatorial games", arXiv:1502.08009v1 (COLT 2015 per memory), Section 2, equations (5), (8), (9) and Lemma 1 (read). Their iProd potential is the average over a prior on experts k and on rates η of Π_t (1 + η·r_t^k) − 1, r_t^k the instantaneous regret to expert k, and their Squint potential is the average of exp(η·R_T^k − η²·V_T^k) − 1 with V_T^k = Σ_t (r_t^k)², which is smaller by e^(x−x²) − 1 ≤ x for x ≥ −1/2; the resulting regret to a set K of experts is of order √(V_T^K·(C_lr − ln π(K))) (their (2)), where the cost C_lr of learning the rate is ln V_T^K, ln ln V_T^K or ln ln T for their three priors on η. Proposition 3.8 is their iProd potential with the signed tests as experts, g_t(B) as the instantaneous regret, and a grid in place of their priors on η. Where their weights make the potential constant (their Lemma 1), the minimising answer makes it non-increasing.
* The halving bound of Theorem 3.3(ii) and Corollary 3.4 is that of the halving algorithm, and Lemma 1.4(d) is its potential (N. Littlestone, "Learning quickly when irrelevant attributes abound", Machine Learning 2 (1988) 285–318; N. Littlestone and M. Warmuth, "The weighted majority algorithm", Inform. and Comput. 108 (1994) 212–261; both from memory).

### 5.4 Calibration with checking rules

*Definitions and statements* (from Perchet's survey, Section 3.2, read). A *checking rule* is a pair (U, T): given the history, U names the set of (prediction, outcome) pairs for which the next stage is *active* and T ⊆ U the *tested* pairs. A strategy is calibrated with respect to (U, T) if, along active stages, the frequency of tested events and the average predicted conditional probability of tested events differ by o(n)/n. Perchet's Theorem 3.2: "Let λ be a probability distribution on the set of checking-rules independent of current predictions. Then there exists a deterministic strategy σ that is calibrated with λ-almost every checking rules", with the remark that "a weaker version first appeared in Lehrer" (E. Lehrer, "Any inspection is manipulable", Econometrica 69 (2001) 1333–1347; not read). Of A. Sandroni, R. Smorodinsky and R. Vohra, "Calibration with many checking rules", Math. Oper. Res. 28 (2003) 141–153 (not read), Perchet says that it "deals with checking rules depending on current predictions", under the assumption that "the calibration test compares the empirical distribution of outcomes with the average prediction on the set of active stages where predictions were in some given set F ⊂ ∆(Ω); activeness of stages might depend on past histories", and states as Proposition 3.2: "Consider a countable number of such checking rules. Then there exists a strategy of the player that is calibrated with every one of them." (The strategy is randomised.) The abstract of the paper, as quoted in the digest from a search result: "Given any countable partition of [0,1] and any countable collection of subsequences, we construct a forecasting scheme such that for all infinite strings of data, the long run average forecast for a matches the long run frequency of realized a's."

*Exact relation.* Read the human's answer y_t as the outcome and the imitator's answer as the point prediction δ_{a_t(x_t)}, and treat the question as part of the history. A test B is then a checking rule that does not depend on the current prediction: every stage is active and the tested event is B_{x_t}. The frequency of tested events minus the average predicted probability is (h_n(B) − N_n(B))/n = −S_n(B)/n. So "S_n(B)/n tends to 0 for every B" says exactly that the deterministic strategy "predict δ_{a_t(x_t)}" is calibrated, in both directions, with respect to all these checking rules. Hence:

* the statement in the literature that Theorem Pr5 quantifies is the one about checking rules *independent of the current prediction* (Lehrer; Perchet's Theorem 3.2), for which deterministic strategies exist. Theorems 2.1 and 3.1 add: a point prediction suffices, an explicit rule, weights in place of "almost every", and the rate √(Λ(B)/n);
* the theorem of Sandroni, Smorodinsky and Vohra concerns rules that look at the current forecast (the partition of [0, 1]), for which randomisation is necessary (the impossibility for deterministic forecasts is attributed to Oakes and Dawid in Perchet's text). It is analogous, not the same: tests of pairs (question, answer) never look at the imitator's distribution, and this is why a deterministic rule works here. The note's sentence "the argument is the one behind ... forecasting that passes countably many checking rules" should name the first statement, not the second.

Rates for finitely many checking rules: V. Gupta et al. (below, Section 1.2, read) describe D. Foster, A. Rakhlin, K. Sridharan and A. Tewari, "Complexity-based approach to calibration with checking rules" (COLT 2011; not read) as "a non-constructive argument establishing that it is possible to obtain mean calibration loss Õ(√(log K/T)) with respect to a set of K checking rules", and D. Foster and S. Kakade, "Calibration via regression" (IEEE Information Theory Workshop 2006; not read) as "an efficient algorithm based on ridge-regression" achieving multiaccuracy on a collection G of sets "with error rates converging as Õ(√(|G|/T))" which "is deterministic". The second is the rate of Proposition 5.1; the first is the rate of Theorem 2.1.

### 5.5 Defensive forecasting

V. Vovk, A. Takemura and G. Shafer, "Defensive forecasting", arXiv:cs/0505083 (AISTATS 2005, pp. 365–372), Theorem 1 (read): in the game where in each round Reality announces x_n, Skeptic announces a continuous S_n: [0, 1] → R, Forecaster announces p_n ∈ [0, 1], Reality announces y_n ∈ {0, 1}, and Skeptic's capital changes by S_n(p_n)·(y_n − p_n), "Forecaster has a strategy ... that ensures K_0 ≥ K_1 ≥ K_2 ≥ ⋯". Its proof takes a zero of S_n if there is one, p_n := 1 if S_n is always positive and p_n := 0 if always negative; the authors note that if S_n does not depend on p the forecast is 0 or 1 according to the sign of S_n.

*Exact relation.* Lemma 1.3 is defensive forecasting in a different game: Forecaster's move is an answer a ∈ Y, not a probability; Skeptic's capital is the weighted sum of potentials Ψ_t; its change in a round is at most (score of Forecaster's answer) − (score of Reality's answer); and the defensive move is the minimiser of the score. Where Vovk, Takemura and Shafer need continuity in p and the intermediate value theorem, the present game needs nothing, because the tests do not look at the forecast. For Y = {0, 1} and tests of the form C × {1} the rule of Theorem 2.1 is the one they describe for S_n independent of p, with S_n = −Σ_C π(C)·1[x_n ∈ C]·sinh(η·S_{n−1}(C × {1})). Their closing section lists as open directions "extending Theorem 1 to other forecasting protocols (such as multi-label classification)" and "exploring forecasting strategies corresponding to: (a) Hoeffding's inequality, (b) the central limit theorem, (c) the law of the iterated logarithm"; Theorem 2.1 is of kind (a) and Theorem 3.1 and Proposition 3.7 of kind (c), for the present game.

V. Vovk, "Non-asymptotic calibration and resolution", arXiv:cs/0506004v4 (Theoret. Comput. Sci. 387 (2007) 77–89 per memory), Theorems 1 and 2 (read): for a kernel on [0, 1] × X with feature map Φ, continuous in the forecast, the deterministic algorithm K29* ensures ‖Σ_{n≤N} (y_n − p_n)·Φ(p_n, x_n)‖² ≤ Σ_{n≤N} p_n(1 − p_n)·‖Φ(p_n, x_n)‖² for all N, hence |Σ_n (y_n − p_n)·f(p_n, x_n)| ≤ ‖f‖·√(Σ_n p_n(1 − p_n)·K((p_n, x_n), (p_n, x_n))) for every f of the reproducing-kernel Hilbert space; Theorems 3 and 4 show that this cannot be improved. This is the quadratic potential. For binary answers, a randomised imitator with q_t(1|x) = p_t, and tests C × {1}, take Φ(p, x) := (√π(C)·1[x ∈ C])_C; then Vovk's inequality reads Σ_C π(C)·(Σ_{n≤N} 1[x_n ∈ C]·(y_n − p_n))² ≤ Σ_n p_n(1 − p_n) ≤ N/4. It is the counterpart of Proposition 5.1 for the *expected* books of a randomised imitator (Section 7.4), sharper by the factor p_n(1 − p_n), and it has the weight outside the logarithm as Proposition 5.1 has.

### 5.6 Online multiaccuracy and multivalid prediction; online outcome indistinguishability

V. Gupta, C. Jung, G. Noarov, M. Pai and A. Roth, "Online multivalid learning: means, moments, and prediction intervals", arXiv:2101.01739v1 (ITCS 2022), Definitions 3.1 and 3.2, Observation 3.2, Lemma 3.1 and Theorem 3.2 (read). For a finite collection G of groups and n buckets of the forecast, V_s^{G,i} := Σ_{t≤s} 1[μ_t ∈ B(i), x_t ∈ G]·(y_t − μ_t), and the surrogate loss is L_s := Σ_{G,i} (exp(η·V_s^{G,i}) + exp(−η·V_s^{G,i})); Theorem 3.2: with η = √(ln(2|G|n)/(2T)) their randomised Algorithm 1 has E[α] ≤ 1/(rn) + 2·√(2·ln(2|G|n)/T), α the largest |V_T^{G,i}|/T. Their footnote 4 identifies mean consistency on a collection of sets (no buckets) with multiaccuracy.

*Exact relation.* L_s is twice the lead's potential Σ cosh(η·V) with equal weights; the analysis of the increase in one round is the same up to the form of the second-order term (their Lemma 3.1 bounds the expected increase by a term linear in the forecast plus 2η²·L_s; the lead uses the addition formula for cosh). The difference is the tests: theirs depend on the forecast through its bucket, which is what calibration means, and this forces a randomised forecast found by a minimax argument (their Lemma 3.2); tests of pairs (question, answer) do not look at the forecast, and the minimax step degenerates to a minimisation. (By their Lemma 3.1, with a single bucket the bound on the expected increase is linear in the forecast and is made non-positive by μ ∈ {0, 1}; this is my reading and is not a statement of theirs.) For binary answers and tests of the form G × {1}, Theorem 2.1 is online multiaccuracy with forecasts in {0, 1}, with weights for countably many groups, and with a deterministic bound.

G. Farina and J. C. Perdomo, "Defensive generation", arXiv:2602.21390v1 (February 2026), Definition 1 and Theorem 1 (informal) (read). Definition 1: an algorithm "satisfies online outcome indistinguishability with respect to a class of distinguishers F if it produces distributions μ_t over Y and statistics p_t such that for any f ∈ F, OIGap_T(f) := |Σ_t E_{p_t}[f(x_t, p_t, y_t)] − Σ_t E_{p_t, ỹ_t∼μ_t}[f(x_t, p_t, ỹ_t)]| is o(T) regardless of Nature's choices of (x_t, y_t)"; Theorem 1 (informal): for multiclass, scalar and vector outcomes and distinguishers in a reproducing-kernel Hilbert space, their procedure "has OIGap_T ≤ O(√T)" in time polynomial in the dimension. Their gap is the *expected* book S̄_n of Section 7.4 for tests f that may also look at statistics p_t of the generated distribution. Compared with it, Theorems 2.1 to 3.3 treat only tests that do not look at the generator, and for these give: realised (not expected) books, a deterministic answer, countable weighted families with the weight inside the logarithm (a kernel bound has the norm of the test, which for the kernel Σ_B π(B)·b_B⊗b_B is 1/√π(B), outside), bounds for all n, and the one-sided rates. They say of their guarantee, as must be said of the present one, that it "does not guarantee closeness in statistical distance".

The digest (`understand/indistinguishability.md`, §5, item 3) reports having found "no published statement of exactly Pr5 (a deterministic rule, countably many weighted tests of pairs)". I found none either; it is a simple case of the statements above.

---

## 6. The rehearsal corollary

### 6.1 Protocol, assumptions, notation

A scaffold Π of horizon L is as in Section 1 of the note: it draws a top-level input z ∼ D₀ and its own randomness ρ, computes the question of call j from z, ρ and the earlier answers, and makes at most L calls. If a rule a: X → Y answers every call, the run is a function of (z, ρ): its calls are x_1, …, x_T with T = T(a; z, ρ) ≤ L, and its answers are a(x_j).

**Property rehearsal.** For t = 1, …, n:

1. compute the rule a_t from the books of rounds 1, …, t − 1 (Rule N or NH, or the rule of Theorem 2.1; the choice among minimisers is made in a fixed way, for instance the least answer, so that a_t is a function of the record);
2. draw (z_t, ρ_t) and run the scaffold with a_t answering every call; this uses computation only;
3. draw J_t uniformly from {1, …, L}. If the run made at least J_t calls, put its J_t-th question, x_t, to the human, receive y_t, and enter g_t(B) = b_B(x_t, a_t(x_t)) − b_B(x_t, y_t) in the books. Otherwise the round is void.

**Deployment.** For each run, draw T uniformly from {1, …, n}, afresh, and let a_T answer every call of that run.

**Assumptions.** Let 𝔉_{t−1} be the σ-algebra generated by everything that happened in rounds 1, …, t − 1.

* (H1) (*the protocol's coins are fresh*; A3 of the note) (z_t, ρ_t) and J_t are independent of each other and of 𝔉_{t−1}; z_t ∼ D₀, ρ_t has the scaffold's law, J_t is uniform; the same for the coins of deployment.
* (H2) (*the human answers the asked call as a sampler*; A1 of the note for the asked calls) given 𝔉_{t−1}, z_t, ρ_t and J_t, the answer y_t has the law P(·|x_t), for a fixed sampler P.

Nothing else is assumed: P need not belong to any class (no A2), need not be computable, and need not be deterministic. The human answers n single calls at most and never carries out a run.

**Notation.** For a rule a and a test B put

  n_B(a) := E[Σ_{j≤T} b_B(x_j, a(x_j))],  m_B(a) := E[Σ_{j≤T} (Pb_B)(x_j)],  d_B(a) := n_B(a) − m_B(a),

the expectations over (z, ρ) for the run of a. For a set test, n_B(a) is the expected number of calls of a run of a whose answer lies in B, and m_B(a) is the expected number of those calls at which the human's answer would lie in B; 0 ≤ n_B, m_B ≤ L. The *deployed discrepancy* is

  Δ_n(B) := (1/n)·Σ_{t≤n} d_B(a_t).

It is a function of the rehearsal record. By (H1), given the record, the expected number of calls of one deployed run whose answer lies in B, minus the expected number of those calls at which the human's answer would lie in B, is Δ_n(B).

**Lemma 6.1. PROVED** (a step of the lead's proof of his corollary). Under (H1) and (H2), E[g_t(B) | 𝔉_{t−1}] = d_B(a_t)/L, and for a set test E[g_t(B)² | 𝔉_{t−1}] ≤ (n_B(a_t) + m_B(a_t))/L.

*Proof.* The rule a_t is 𝔉_{t−1}-measurable. Given 𝔉_{t−1}, z_t, ρ_t, J_t, the run of round t and the asked question are determined, and by (H2) the conditional expectation of g_t(B) is 1[J_t ≤ T_t]·(b_B(x_{J_t}, a_t(x_{J_t})) − (Pb_B)(x_{J_t})), where x_1, …, x_{T_t} are the calls of that run. J_t is uniform and independent of (𝔉_{t−1}, z_t, ρ_t), so averaging over J_t gives (1/L)·Σ_{j≤T_t} (b_B(x_j, a_t(x_j)) − (Pb_B)(x_j)). (z_t, ρ_t) is independent of 𝔉_{t−1}, so averaging over it gives d_B(a_t)/L. All variables are bounded by 1, so the expectations exist; the run is a measurable function of (a_t, z_t, ρ_t), the set Y^X of rules carrying the product σ-algebra. For the second claim, g_t(B)² is the indicator that exactly one of the two answers to the asked call lies in B, which is at most b_B(x_t, a_t(x_t)) + b_B(x_t, y_t); proceed as before. ∎

### 6.2 In expectation

**Theorem 6.2 (rehearsal with the property imitator: expectation). MODIFIED** (the lead's corollary is part (a) with the bound of Theorem 2.1; its proof is correct. Parts (b) to (d) and the bounds of Section 3 are new). Assume (H1) and (H2) and let the tests be sets. Run property rehearsal with Rule NH and exact minimisers (for an infinite answer set, with the changes of Proposition 4.1). Then for every test B:

(a) (*two-sided*) E Δ_n(B) = (L/n)·E S_n(B), hence

  |E Δ_n(B)| ≤ (L/n)·E|S_n(B)| ≤ L·√((1 + 1/n)·(2Λ(B) + 1.39 + ln(n + 1))/n).

With the rule of Theorem 2.1 and η = 1/√n the right side is L·(ln(2/π(B)) + 1/2)/√n (the lead's corollary).

(b) (*rare tests*) Let p̄ := E[(1/n)·Σ_t n_B(a_t)]/L and q̄ := E[(1/n)·Σ_t m_B(a_t)]/L be the expected rates, per call slot (that is, the expected numbers per run divided by L), of answers in B for the deployed imitator and for the human on the imitator's calls. With W := 2Λ(B) + 1.39 + ln(n + 1),

  |p̄ − q̄| ≤ √((p̄ + q̄ + 1/n)·W/n).

(c) (*one-sided*) If the human never gives an answer in B, that is (Pb_B)(x) = 0 for all x, then the expected number of calls of a deployed run whose answer lies in B is at most L·(K(B) + 2)/n. If the human's answer always lies in B, (Pb_B)(x) = 1 for all x, then the expected number of calls of a deployed run whose answer is outside B is at most L·(K(B) + 2)/n.

(d) (*a deterministic human in a weighted class*) With the family and weights of Corollary 3.4, if the human is a function f ∈ H, then the expected number of calls of a deployed run whose answer differs from the human's is at most L·(K + 3)/n; so the deployed run is a run of the human system with probability at least 1 − L·(K + 3)/n. Parts (a) to (c) hold for the tests of 𝓑₀ with K(B) and Λ(B) computed from π₀(B)/2, whether or not the human is in H.

For Rule N the same holds with 2Λ(B) + ln(n + 1) in (a) and (b), and with 2Λ(B) + ln(2Λ(B) + 4) + 2 in place of K(B) + 2 in (c). For tests with values in [0, 1], (a) holds with Rule N.

*Proof.* (a) By Lemma 6.1, E S_n(B) = Σ_t E[d_B(a_t)]/L = (n/L)·E Δ_n(B). The bound on |S_n(B)| is Theorem 3.3(i) with V_n(B) ≤ n; for the rule of Theorem 2.1 it is that theorem. (b) By Theorem 3.3(i) and the concavity of the square root, E|S_n(B)| ≤ E√((V_n(B) + 1)·W) ≤ √((E V_n(B) + 1)·W). By Lemma 6.1, E V_n(B) = Σ_t E g_t(B)² ≤ Σ_t E[n_B(a_t) + m_B(a_t)]/L = n·(p̄ + q̄). And |p̄ − q̄| = |E Δ_n(B)|/L = |E S_n(B)|/n. (c) In the first case (x_t, y_t) ∉ B almost surely in every round, so every increment is 0 or 1 and, by Theorem 3.3(ii), N_n(B) = S_n(B) ≤ K(B) + 2 almost surely. By Lemma 6.1 with m_B = 0, E N_n(B) = Σ_t E[n_B(a_t)]/L, and the expected number of calls of a deployed run with answer in B is E[(1/n)·Σ_t n_B(a_t)] = (L/n)·E N_n(B). The second case is the same with −g_t(B), which is the indicator that the asked call's answer is outside B. (d) A call's answer differs from f exactly if the pair lies in B_f; apply (c) to B_f, whose weight is w(f)/2. ∎

*What (c) and (d) say.* For a kind of answer that the human never gives, the lead's corollary bounds the imitator's rate by (ln(2/π(B)) + 1/2)/√n per call, and Example 2.3 shows that his rule can come within a factor 2 of this. Rule NH gives (K(B) + 2)/n per call slot. With the tests "the answer is not ν's" for the functions of a class, (d) is the analogue of Theorem R1 for a deterministic human, with K + 3 in place of K·ln 2, obtained without a posterior.

### 6.3 With high probability

**Theorem 6.3 (rehearsal with the property imitator: high probability). NEW.** Assume (H1) and (H2), and let the rule be any rule of Sections 2 and 3. Let 0 < δ < 1. With probability at least 1 − δ over the rehearsal, for all tests B ∈ 𝓑 at once,

  |Δ_n(B)| ≤ (L/n)·(|S_n(B)| + √(2n·ln(2/(π(B)·δ)))).  (6.1)

The right side can be read off the rehearsal record. With Rule NH and exact minimisers it is at most

  (L/√n)·(√((1 + 1/n)·(2Λ(B) + 1.39 + ln(n + 1))) + √(2Λ(B) + 2·ln(2/δ))).

Moreover, for set tests and Rule NH, with probability at least 1 − δ, for all tests B with (Pb_B)(x) = 0 for all x at once,

  (1/n)·Σ_{t≤n} n_B(a_t) ≤ 1.582·L·(K(B) + 2 + Λ(B) + ln(1/δ))/n.  (6.2)

The left side of (6.2) is the expected number, given the rehearsal, of calls of a deployed run whose answer lies in B.

*Proof.* Fix B. M_k := Σ_{t≤k} (g_t(B) − d_B(a_t)/L) is a martingale with respect to (𝔉_k) by Lemma 6.1, and given 𝔉_{t−1} its increment lies in an interval of length 2 (g_t(B) ∈ [−1, 1], and d_B(a_t)/L is 𝔉_{t−1}-measurable). By Hoeffding's lemma (a variable with conditional mean 0 and values in an interval of length c has conditional moment generating function at most e^(θ²c²/8); W. Hoeffding, "Probability inequalities for sums of bounded random variables", J. Amer. Statist. Assoc. 58 (1963) 13–30, from memory; a complete proof is in Lemma 12.1 of `research/prove-c/rehearsal-core.md`, written in parallel), E[e^(θ(M_t − M_{t−1})) | 𝔉_{t−1}] ≤ e^(θ²/2) for real θ, so E e^(θM_n) ≤ e^(nθ²/2), and Markov's inequality with θ = ±λ/n gives Pr[|M_n| ≥ λ] ≤ 2e^(−λ²/(2n)) (the Azuma–Hoeffding inequality). With λ = √(2n·ln(2/(π(B)δ))) the probability is at most π(B)·δ; sum over B. On the complement, (n/L)·|Δ_n(B)| = |S_n(B) − M_n| ≤ |S_n(B)| + λ.

For (6.2): X_t := g_t(B) ∈ {0, 1} almost surely, with conditional mean μ_t := n_B(a_t)/L. Since e^(−x) ≤ 1 − (1 − e^(−1))·x on [0, 1] (convexity) and 1 − u ≤ e^(−u), E[e^(−X_t) | 𝔉_{t−1}] ≤ exp(−(1 − e^(−1))·μ_t). So Z_k := exp(Σ_{t≤k} ((1 − e^(−1))·μ_t − X_t)) is a non-negative supermartingale with Z_0 = 1, and Pr[Z_n ≥ 1/(π(B)δ)] ≤ π(B)·δ. On the complement, (1 − e^(−1))·Σ_t μ_t ≤ N_n(B) + Λ(B) + ln(1/δ), and N_n(B) ≤ K(B) + 2 by Theorem 3.3(ii). Sum the failure probabilities over B, and note e/(e − 1) < 1.582. ∎

The second term of (6.1) is the sampling error of n answers and does not depend on the rule; a term of this order is unavoidable, because the deployed imitator's rates are computed from n answers of the human (for a single test and a human who satisfies it with an unknown probability, no imitator built from n answers has an error below order 1/√n with high probability; this standard fact is not proved here). So given the rehearsal the rate is 1/√n for two-sided tests whatever the rule, and Theorems 3.1 and 3.3 matter in (6.1) through |S_n(B)|, and in the one-sided bound (6.2).

### 6.4 What is assumed, and what fails without it

**Remarks 6.4.**

1. *About the human* only (H2) is assumed. If the human is not stateless, suppose that there are kernels P_t, each determined by the past of round t, such that given 𝔉_{t−1}, z_t, ρ_t and J_t the answer y_t has the law P_t(·|x_t) (the human remembers, but in round t sees only the question). Lemma 6.1 and Theorems 6.2(a), (b) and 6.3 remain true with m_B and d_B computed, for the rule of round t, from P_t: the rule of round t is compared with the human as the human was in round t. For a human who changes, this says nothing about the human after rehearsal; a statement about a later human needs an assumption about the change.
2. *The human's rate is the rate on the imitator's own questions.* m_B(a_t) is computed along the run of a_t. It is not the rate of B in the human system, whose runs may ask other questions (Proposition 7.3).
3. *One asked call per run* is what the proof uses; a round in which the run is shorter than J_t is void and counts in n.
4. *A fresh round for each run.* The bounds concern the average of d_B(a_t) over the rounds. Example 6.5 shows that no single rule need be good. Drawing a fresh round for every *call* is not covered either: in rehearsal all calls of a run were answered by one rule, and the questions of later calls depend on the answers to earlier ones.
5. *The top-level law.* The two-sided bounds imply nothing for another law D′ of the top-level input, not even one with a bounded density dD′/dD₀, because errors on different inputs may cancel under D₀ and not under D′. Example: L = 1, the question is u, v or w with probability 1/3 each, the human answers with a fair coin, and the tests are B = X × {1} and C = {(u, 1), (w, 1)}. If the rules alternate between (a(u), a(v), a(w)) = (1, 1, 0) and (1, 0, 0), then d_B and d_C average to 0 over the rounds, so the conclusions of Theorems 6.2(a) and 6.3 hold with room; under D′ = the point mass at u, whose density is 3, the deployed imitator always answers 1. (I do not claim that Rule N produces these rules; the point is that the guarantee does not exclude them.) The family must contain the tests restricted to the inputs concerned. The one-sided bounds (c), (d) and (6.2) concern non-negative quantities and hold under D′ with the factor sup dD′/dD₀, when the scaffold's randomness is unchanged.
6. *The asked call must be drawn uniformly over the call positions* (used in Lemma 6.1). If, for instance, always the first call were put to the human, the calls at later positions would never be audited. Example: L = 2, the second question is always a fixed x′ that never occurs as a first question, the family is {B} with B = {(x′, 1)}, and the human always answers 0 to x′. Then no book ever changes, every answer to x′ has score 0, and a rule that breaks ties in favour of the answer 1 gives an answer in B in every run, for every n.

**Example 6.5 (one rule kept for good fails). NEW.** Let L = 1, let the scaffold always ask the same question x₀, Y = {0, 1}, and let the human answer with a fair coin. Let 𝓑 = {B}, B = {(x₀, 1)}, π(B) = 1. Every rule answers x₀ with 0 or with 1, so d_B(a) = ±1/2 for every rule a: whichever round's rule is kept for all runs, and however it is chosen, its frequency of the answer 1 is 0 or 1 where the human's is 1/2. The deployed imitator of Section 6.1 has |E Δ_n(B)| ≤ 1/n and, with probability at least 1 − δ, |Δ_n(B)| ≤ (1 + √(2n·ln(2/δ)))/n.

*Proof.* The first claim is immediate. With one set test and exact minimisers the book stays in {−1, 0, 1} (as in the proof of Proposition 4.4(a)); now use Theorem 6.2(a) in the form |E Δ_n(B)| ≤ (L/n)·E|S_n(B)| and (6.1). ∎

In the tree of additions (Section 9.4) the same is seen for a test of rate 0.1 per call: the rules of single rounds give between 0 and 5.5 such answers per run where the human gives 0.7, and more than 80 per cent of the rounds have a rule that is off by more than half the human's rate, while the average over the rounds is within 0.08.

### 6.5 In rehearsal the books can stay bounded

The bounds of Sections 2 and 3 are for arbitrary sequences, and Proposition 3.6 shows that they cannot be improved much there. In rehearsal the questions come from the scaffold and the human is a fixed sampler, and the books can be far smaller. For the quadratic rule this can be proved under a condition that says that the human's rates are not extreme in any direction.

**Proposition 6.6 (the quadratic rule under an interior condition: books bounded in n, expected discrepancy of order 1/n). NEW.** Assume (H1) and (H2), let Y be finite, and run property rehearsal with the quadratic rule of Proposition 5.1: a_t(x) minimises Σ_B π(B)·S_{t−1}(B)·b_B(x, y). For a vector S = (S(B))_B put ‖S‖_π := (Σ_B π(B)·S(B)²)^(1/2) and, for a question x,

  m_x(S) := Σ_B π(B)·S(B)·(Pb_B)(x) − min_y Σ_B π(B)·S(B)·b_B(x, y) ≥ 0

(by how much the human's average answer at x is worse than the best answer, for the score with the slopes S). Suppose there is μ₀ > 0 such that for every rule a and every S with ‖S‖_π < ∞, with the expectation over the run of a,

  E[Σ_{j≤T} m_{x_j}(S)] ≥ μ₀·L·‖S‖_π.  (I)

Then for every n,

  E‖S_n‖_π ≤ C(μ₀) := (2/μ₀)·(1 + e·ln(8e/μ₀²)),  and  |E Δ_n(B)| ≤ (L/n)·E|S_n(B)| ≤ L·C(μ₀)/(n·√π(B)) for every test B.

*Proof.* Write ⟨S, g⟩_π := Σ_B π(B)·S(B)·g(B) and r_t := ‖S_t‖_π, where S_t is the vector of the books. (1) r_t² = r_{t−1}² + 2⟨S_{t−1}, g_t⟩_π + ‖g_t‖_π², and ‖g_t‖_π² ≤ Σ_B π(B) ≤ 1; by the triangle inequality |r_t − r_{t−1}| ≤ ‖g_t‖_π ≤ 1. (2) By Lemma 6.1, applied to each B and summed with the weights π(B)·S_{t−1}(B), E[⟨S_{t−1}, g_t⟩_π | 𝔉_{t−1}] = (1/L)·E Σ_{j≤T} (Σ_B π(B)·S_{t−1}(B)·(b_B(x_j, a_t(x_j)) − (Pb_B)(x_j))), the expectation over the run of a_t; since a_t(x_j) minimises the score with the slopes S_{t−1}, this is −(1/L)·E Σ_j m_{x_j}(S_{t−1}) ≤ −μ₀·r_{t−1} by (I). Hence E[r_t² | 𝔉_{t−1}] ≤ r_{t−1}² − 2μ₀·r_{t−1} + 1. (3) Note μ₀ ≤ 1, because m_x(S) ≤ Σ_B π(B)·|S(B)| ≤ ‖S‖_π. On the event {r_{t−1} ≥ 1/μ₀}, by Jensen's inequality and √(1 + u) ≤ 1 + u/2, E[r_t | 𝔉_{t−1}] ≤ √(r_{t−1}² − 2μ₀·r_{t−1} + 1) ≤ r_{t−1} − μ₀ + 1/(2r_{t−1}) ≤ r_{t−1} − μ₀/2. (4) Put λ := μ₀/(2e) ≤ 1. For |u| ≤ 1, e^u ≤ 1 + u + (e/2)·u² (the series of e^u − 1 − u is at most u²·(e − 2)). With u = λ·(r_t − r_{t−1}): on {r_{t−1} ≥ 1/μ₀}, E[e^(λ(r_t − r_{t−1})) | 𝔉_{t−1}] ≤ 1 − λμ₀/2 + λ²·e/2 = 1 − μ₀²/(8e) =: ϱ. On the complement, r_t < 1/μ₀ + 1 and e^(λ·r_t) ≤ e^((1+μ₀)/(2e)) ≤ e^(1/e). So in all cases E[e^(λ·r_t) | 𝔉_{t−1}] ≤ ϱ·e^(λ·r_{t−1}) + e^(1/e), and by induction E e^(λ·r_n) ≤ e^(1/e)/(1 − ϱ) = 8e·e^(1/e)/μ₀² (the bound holds at n = 0, where the left side is 1). (5) By Jensen's inequality E r_n ≤ (1/λ)·ln E e^(λ·r_n) ≤ (2e/μ₀)·(1/e + ln(8e/μ₀²)) = C(μ₀). Finally |S_n(B)| ≤ ‖S_n‖_π/√π(B), and E Δ_n(B) = (L/n)·E S_n(B) by Lemma 6.1. ∎

*Reading.* (i) Condition (I) holds in Example 6.5 with μ₀ = 1/2. It fails whenever the family contains a test that is one-sided for the human (take for S the unit vector of that test, with the sign for which the human's answers are the best ones: then m_x(S) = 0); for those tests Theorem 3.3(ii) gives a total of K(B) + 2, which is again a rate 1/n in expectation. I have no statement for families that mix the two kinds, and none for Rules N and NH, whose books behave in the same way in the simulation of Section 9.9. (ii) The proposition concerns the expectation over the rehearsal. Given the rehearsal, the error of the deployed imitator is of order 1/√n whatever the books do (Section 6.3). So the two statements "the rate is 1/n" and "the rate is 1/√n" are both true: the first of the average over rehearsals, the second of the imitator one has after one rehearsal. (iii) The constant C(μ₀) is crude; in the simulation with μ₀ ≈ 0.08 the mean of ‖S_n‖_π is 0.94 where C(μ₀) = 559.

---

## 7. Limits, each with an example; and a randomised version

### 7.1 Tests outside the family

**Example 7.1 (a property that is not in the family is not kept, however simple). NEW.** Let X be the positive integers, Y = {0, 1}, and let the human be f(x) = x mod 2. Let the family consist of the one test B = X × {1} ("the answer is 1"), and let the questions be x_t = t. Under Rule N (or NH, or the rule of Theorem 2.1), with the least answer among the minimisers, |S_n(B)| ≤ 1 for all n, and the imitator's answer differs from f(x_t) in *every* round. The property "y = x mod 2" holds for the human always and for the imitator never.

*Proof.* The score of the answer y is c·1[y = 1] with c of the sign of S_{t−1}(B); it does not depend on x. Round 1: S_0 = 0, both scores are 0, the imitator answers 0; f(1) = 1; g_1(B) = −1. Round 2: S_1 = −1, the imitator answers 1; f(2) = 0; g_2(B) = +1 and S_2 = 0. The situation before round 3 is that before round 1, and f(3) = f(1). ∎

More generally, if no test of the family distinguishes two answers y, y′ at a question x, the rule has no reason to prefer the one the human gives. What the imitator keeps is the family, and nothing else. (With the test B′ = {(x, y) : y = x mod 2} in the family the imitator would violate it at most K(B′) + 2 times, by Theorem 3.3.)

### 7.2 Tests too complex for n

**Example 7.2 (a test is matched only when n is large compared with its complexity). NEW.** In Proposition 3.5 the test B_{c*} has K(B_{c*}) = m bits, the human never satisfies it, and after n = m rounds the imitator has satisfied it in every round: |S_n(B)|/n = 1. In general the two-sided frequency error of Theorem 3.1, √((1 + 1/n)(2Λ(B) + ln(n + 1))/n), is below ε only when n exceeds about 2Λ(B)/ε², and a one-sided property is violated up to K(B) + 2 times.

For the property "the answer is the one this human gives" this reads as follows. For a deterministic human f it is the test with complexity about K, the description length of f; if it is in the family, Corollary 3.4 gives K + 3 disagreements, which is of the same order as the K·ln 2 of the Bayes mixture. For a human who is not deterministic there is no such test of single pairs: tests of pairs constrain the rates at which answers with given properties are given, and many kernels have the same rates (Section 7.3 and Section 8).

### 7.3 Joint behaviour across the calls of a run

**Proposition 7.3 (tests of single calls do not control runs). NEW.** Let the scaffold make two calls, both with the same question x₀ (L = 2), let Y = {0, 1}, and let the human answer with a fair coin. In the human system the two answers of a run agree with probability 1/2. Under any imitator that answers all calls of a run by one deterministic rule, in particular under the deployed imitator of Section 6 for every family of tests of single calls and every potential, the two answers agree with probability 1. So the law of the deployed run is at total variation distance at least 1/2 from the human system for every n, while the frequency of every test of the family {{(x₀, 0)}, {(x₀, 1)}} is matched as in Theorem 6.2.

*Proof.* Under A1 the human's two answers are independent fair coins. A rule gives the same answer to the same question. ∎

The same effect is in the lead's toy (`results/toy_property.out`, and Section 9.4 here): in the tree of additions the same question occurs several times in a run, a rule errs on a fixed set of questions, and so the errors of a run are positively dependent; the rate of exact sums per call matches the human's (0.90), but the root is exact with probability about 0.6 against 0.478 = 0.9⁷ in the human system. Also by Remark 6.4(2) the comparison is made on the imitator's own questions: nothing is said about how often the imitator's runs reach a given question compared with the human system's.

A test of single pairs cannot express "two calls of this run got the same answer". Tests that see the run so far can, and for them there is a positive statement. It needs the family to contain the right test, as follows.

**Proposition 7.4 (outcomes whose continuation value is a test of the family). NEW** (this is Theorem C2 of the digest `understand/indistinguishability.md`, §3.7, with Rule N in place of the rule of Pr5; the proof is written out). Let Y be finite. Let the *state* before call j be s_j = (z, ρ, y_1, …, y_{j−1}), let tests be measurable functions b(s, y) ∈ [0, 1] of a state and an answer, and let a rule be a function from states to answers (the least minimiser of the score, which is measurable). Let u be an outcome of runs with values in [0, 1], Q_a(u) and Q_P(u) its expectations when a rule a, respectively the human P, answers every call, and

  V^u(s, y) := E[u | the state before call j is s, the answer to call j is y, and all later calls are answered by P].

Run property rehearsal (Section 6.1) with states in place of questions, the human being shown only the question of the asked call, and with Rule N and exact minimisers. Assume (H1) and (H2). If the family contains a test B with |b_B − V^u| ≤ ξ everywhere, then

  |E[(1/n)·Σ_{t≤n} Q_{a_t}(u)] − Q_P(u)| ≤ L·√((1 + 1/n)·(2Λ(B) + ln(n + 1))/n) + 2Lξ.

*Proof.* Step 1 (the performance difference lemma; S. Kakade and J. Langford, "Approximately optimal approximate reinforcement learning", ICML 2002, as cited in the digest; the proof is complete here). For k = 0, …, L let H_k be the law of the run in which calls 1, …, k are answered by a and later calls by P; H_0 = Q_P and H_L = Q_a. Under H_k and under H_{k−1} the state s_k (when the run has a k-th call) has the same law, namely its law under Q_a, since in both the first k − 1 calls are answered by a. Given s_k, the expected outcome is V^u(s_k, a(s_k)) under H_k and (PV^u)(s_k) := Σ_y P(y|x_k)·V^u(s_k, y) under H_{k−1}, where x_k is the question of s_k; if the run has no k-th call the outcome is the same under both. Summing over k, Q_a(u) − Q_P(u) = E_{Q_a} Σ_{j≤T} (V^u(s_j, a(s_j)) − (PV^u)(s_j)). Step 2. As in Lemma 6.1, E[g_t(V^u) | 𝔉_{t−1}] = (1/L)·E_{Q_{a_t}} Σ_j (V^u(s_j, a_t(s_j)) − (PV^u)(s_j)), which by Step 1 is (Q_{a_t}(u) − Q_P(u))/L. Step 3. |g_t(V^u) − g_t(B)| ≤ 2ξ, so |Σ_t E(Q_{a_t}(u) − Q_P(u))| = L·|E S_n(V^u)| ≤ L·E|S_n(B)| + 2Lξn, and Theorem 3.1 bounds |S_n(B)|. (Lemma 1.3 does not use that the set of questions is countable.) ∎

So the deployed system succeeds as often as the human system, for every outcome u whose human continuation value V^u is (close to) a test of the family; in the example of Proposition 7.3 with u = "the two answers agree", V^u(s_2, y) = 1[y = y_1] and V^u(s_1, y) = 1/2, a simple test of states with values in [0, 1]. The price is Λ(V^u), the complexity of "how the human system's chance of success depends on the work so far". It is not known in advance whether a given outcome has a simple continuation value, and the imitator must be shown the state. The guarantee is two-sided and concerns only u.

### 7.4 The rule is a book-balancing choice, not a sample from a model of the human; a randomised version

The rule of a round is a deterministic function chosen to repay the debts of the books. Even where the human's answers are random, the imitator's answer at a question is a point: at each x the deployed imitator's answer has the law (1/n)·Σ_t δ_{a_t(x)}, which matches the rates of the tests on the imitator's inputs and need not resemble P(·|x) (in Example 7.1 with a human f(x) = x mod 2 it is close to the fair coin at every x).

A randomised imitator announces in round t a kernel q_t(·|x) and draws its answers from it. Its *expected increment* and *expected book* are

  ḡ_t(B) := (q_t b_B)(x_t) − b_B(x_t, y_t) ∈ [−1, 1],  S̄_n(B) := Σ_{t≤n} ḡ_t(B),

where (q_t b_B)(x) := Σ_y q_t(y|x)·b_B(x, y). The kernel q_t may depend on the past questions and answers of the human. A *base* is a kernel R_t(·|x) ≥ 0 with 0 < Σ_y R_t(y|x) ≤ 1, fixed before round t; it may be a semimeasure, and it may change with t (for instance the Bayes mixture of the data so far). KL(q‖R)(x) := Σ_y q(y|x)·ln(q(y|x)/R(y|x)), which is ≥ 0 for a probability q and a semimeasure R. A *tilt* of R_t by a bounded function Λ_t(x, y) is the kernel

  q_t(y|x) := R_t(y|x)·e^(−Λ_t(x, y))/Z_t(x),  Z_t(x) := Σ_y R_t(y|x)·e^(−Λ_t(x, y)).

**Lemma 7.5 (the tilt identity). NEW** (elementary). For a tilt q of R by Λ, every x, and every y with R(y|x) > 0:

  (qΛ)(x) − Λ(x, y) = ln(q(y|x)/R(y|x)) − KL(q‖R)(x) ≤ ln(1/R(y|x)).

For every probability P(·|x) with KL(P‖R)(x) < ∞:

  (qΛ)(x) − (PΛ)(x) = KL(P‖R)(x) − KL(P‖q)(x) − KL(q‖R)(x) ≤ KL(P‖R)(x).

Moreover, with osc(Λ)(x) := sup_y Λ(x, y) − inf_y Λ(x, y): if R(·|x) is a probability then KL(q‖R)(x) ≤ osc(Λ)(x); and in all cases KL(P‖q)(x) ≤ 2·KL(P‖R)(x) + osc(Λ)(x)².

*Proof.* By definition Λ(x, y) = ln(R(y|x)/q(y|x)) − ln Z(x) where R(y|x) > 0. Averaging over q gives (qΛ)(x) = −KL(q‖R)(x) − ln Z(x); subtracting gives the first identity, and q ≤ 1, KL(q‖R) ≥ 0 give the inequality. Averaging over P gives (PΛ)(x) = KL(P‖q)(x) − KL(P‖R)(x) − ln Z(x), all terms finite because Λ is bounded; subtract. Next, Z(x) ≥ Σ_y R(y|x)·e^(−sup Λ), so −ln Z ≤ sup Λ − ln Σ_y R(y|x), and KL(q‖R) = −(qΛ) − ln Z ≤ sup Λ − inf Λ − ln Σ_y R(y|x); for a probability R the last term is 0 (for a semimeasure the bound holds with this term added). Finally, from the second identity, KL(P‖q) ≤ KL(P‖R) + (PΛ) − (qΛ) ≤ KL(P‖R) + osc(Λ)·TV(P, q), and TV(P, q) ≤ √(KL(P‖q)/2); with r := √(KL(P‖q)) this is r² ≤ KL(P‖R) + (osc(Λ)/√2)·r, so r ≤ osc(Λ)/√2 + √(KL(P‖R)) and r² ≤ 2·KL(P‖R) + osc(Λ)². ∎

**Theorem 7.6 (a tilt driven by exponential weights on the tests). NEW.** Let η > 0 and β > 0. In round t put Φ_{t−1} := Σ_B π(B)·cosh(η·S̄_{t−1}(B)), ω_t(B) := π(B)·sinh(η·S̄_{t−1}(B))/Φ_{t−1}, and let q_t be the tilt of the base R_t by

  Λ_t(x, y) := β·sinh(η)·Σ_B ω_t(B)·b_B(x, y).

Then Σ_B |ω_t(B)| ≤ tanh(η·max_B |S̄_{t−1}(B)|) < 1, so osc(Λ_t) ≤ β·sinh(η), and:

(i) (*any sequence*) For all n and B, with ℓ_t := ln(1/R_t(y_t|x_t)) ∈ [0, ∞],

  |S̄_n(B)| ≤ (ln(2/π(B)) + n·η²/2 + (1/β)·Σ_{t≤n} ℓ_t)/η.

(ii) (*answers drawn from P*) Suppose that, given the past and x_t, the answer y_t has the law P(·|x_t), and put κ_t := KL(P‖R_t)(x_t). Then for every n and B,

  E|S̄_n(B)| ≤ (ln(2/π(B)) + n·η²/2 + (1/β)·E Σ_{t≤n} κ_t)/η,

and for 0 < δ < 1, with probability at least 1 − δ, for all n and all B at once, |S̄_n(B)| ≤ (ln(2/(π(B)·δ)) + n·η²/2 + (1/β)·Σ_{t≤n} κ_t)/η.

(iii) (*closeness to the base*) For a base that is a probability kernel, KL(q_t‖R_t)(x) ≤ β·sinh(η) and, for every sampler P and every x, KL(P‖q_t)(x) ≤ 2·KL(P‖R_t)(x) + β²·sinh²(η).

*Proof.* Σ_B π(B)·|sinh(η·S̄_{t−1}(B))| ≤ max_B tanh(η|S̄_{t−1}(B)|)·Φ_{t−1}, and b_B has values in [0, 1]; this gives the bound on osc(Λ_t). By (1.3) with g = ḡ_t(B), multiplied by π(B) and summed,

  Φ_t ≤ cosh(η)·Φ_{t−1} + sinh(η)·Σ_B π(B)·sinh(η·S̄_{t−1}(B))·ḡ_t(B) = cosh(η)·Φ_{t−1} + (Φ_{t−1}/β)·((q_tΛ_t)(x_t) − Λ_t(x_t, y_t)).  (7.1)

(i) By Lemma 7.5 the bracket is at most ℓ_t (if R_t(y_t|x_t) = 0 the claim is empty). So Φ_t ≤ Φ_{t−1}·(cosh η + ℓ_t/β) ≤ Φ_{t−1}·exp(η²/2 + ℓ_t/β), using cosh η ≤ e^(η²/2) and e^a + r ≤ e^(a+r) for a, r ≥ 0. Hence Φ_n ≤ exp(nη²/2 + Σ_t ℓ_t/β), and π(B)·e^(η|S̄_n(B)|)/2 ≤ Φ_n.

(ii) Let ℌ_t be generated by the past and x_t. Then E[ḡ_t(B) | ℌ_t] = (q_t b_B)(x_t) − (Pb_B)(x_t), so taking the conditional expectation in the first line of (7.1), E[Φ_t | ℌ_t] ≤ cosh(η)·Φ_{t−1} + (Φ_{t−1}/β)·((q_tΛ_t)(x_t) − (PΛ_t)(x_t)) ≤ Φ_{t−1}·(cosh η + κ_t/β) by Lemma 7.5. Therefore M_t := Φ_t·exp(−t·η²/2 − (1/β)·Σ_{s≤t} κ_s) (with M_t := 0 where some κ_s is infinite) satisfies E[M_t | ℌ_t] ≤ M_{t−1}; since M_{t−1} is determined by the past of round t, it is a non-negative supermartingale (with respect to the σ-algebras ℌ_{t+1}, t ≥ 0) with M_0 ≤ 1. By Jensen's inequality E ln M_n ≤ ln E M_n ≤ 0, that is E ln Φ_n ≤ n·η²/2 + (1/β)·E Σ_t κ_t, and η·|S̄_n(B)| ≤ ln(2/π(B)) + ln Φ_n. By Ville's inequality, Pr[sup_n M_n ≥ 1/δ] ≤ δ (the maximal inequality for non-negative supermartingales, standard: if τ is the first n with M_n ≥ 1/δ, then E M_{min(τ,m)} ≤ M_0 ≤ 1 by optional stopping, so Pr[τ ≤ m] ≤ δ for every m).

(iii) Lemma 7.5 with osc(Λ_t) ≤ β·sinh(η). ∎

**Corollary 7.7 (rehearsal with the tilted sampler; the Bayes mixture as base). NEW.**

(a) Under (H1) and (H2), run rehearsal with the kernel q_t answering every call of the run of round t by a fresh draw, enter ḡ_t(B) for the asked call in the books, and deploy, for each run, the kernel of a uniformly chosen round. Then E[ḡ_t(B) | 𝔉_{t−1}] = d_B(q_t)/L, with n_B, m_B and d_B defined for the run of the kernel q_t as in Section 6.1; so the expected number of calls of a deployed run whose answer lies in B differs from the expected number of those calls at which the human's answer would lie in B by at most (L/n)·E|S̄_n(B)|, which Theorem 7.6(ii) bounds.

(b) Let the base be the Bayes mixture, R_t = M^(t), of a class with weights w, trained on the asked pairs. Under A1 and A2 (the human P is in the class, K = log₂(1/w(P))), with η = 1/√n: E|S̄_n(B)| ≤ √n·(ln(2/π(B)) + 1/2 + K·ln 2/β), and Σ_{t≤n} E KL(P‖q_t)(x_t) ≤ 2K·ln 2 + 1.39·β². Without A2, (i) holds with Σ_t ℓ_t the cumulative logarithmic loss of the mixture on the human's answers.

(c) Let the base be the uniform distribution on a finite Y, β = 2·ln|Y|/η² and η = 1/√n. Then on every sequence |S̄_n(B)| ≤ √n·(ln(2/π(B)) + 1) for every B.

*Proof.* (a) As Lemma 6.1: given the run of round t and J_t, the conditional expectation of ḡ_t(B) is (q_t b_B)(x_{J_t}) − (Pb_B)(x_{J_t}) on {J_t ≤ T_t}, and E[b_B(x_j, y_j) | x_j] = (q_t b_B)(x_j) for the answers y_j of the run. (b) For questions that are functions of the past and of randomness independent of the human's coins, Σ_t E κ_t ≤ K·ln 2 (the regret bound of the Bayes mixture; proof of Theorem R1 in the note). Use (ii) and (iii), with n·sinh²(1/√n) ≤ sinh²(1) < 1.39 (sinh is convex and vanishes at 0, so sinh(r) ≤ r·sinh(1) on [0, 1]). (c) ℓ_t = ln|Y|, so (i) gives ln(2/π(B))/η + n·η/2 + n·ln|Y|/(β·η) = ln(2/π(B))/η + n·η. ∎

**Theorem 7.8 (a tilt driven by gradient steps: an exact identity). NEW.** Let γ > 0, and let q_t be the tilt of the base R_t by

  Λ_t(x, y) := γ·Σ_B π(B)·S̄_{t−1}(B)·b_B(x, y)

(the tilt parameter of B is γ·π(B)·S̄_{t−1}(B): it moves by γ·π(B)·ḡ_t(B) in round t, a gradient step on the logarithmic loss of the tilted family). Then on every sequence with R_t(y_t|x_t) > 0 for all t,

  Σ_B π(B)·S̄_n(B)² = Σ_{t≤n} Σ_B π(B)·ḡ_t(B)² + (2/γ)·Σ_{t≤n} (ln(q_t(y_t|x_t)/R_t(y_t|x_t)) − KL(q_t‖R_t)(x_t)).

Consequently:

(i) on every sequence, Σ_B π(B)·S̄_n(B)² ≤ n + (2/γ)·Σ_{t≤n} ln(1/R_t(y_t|x_t)), so |S̄_n(B)| ≤ √((n + (2/γ)·Σ_t ℓ_t)/π(B));

(ii) if, given the past and x_t, the answer y_t has the law P(·|x_t), and E Σ_t KL(P‖R_t)(x_t) < ∞, then

  E Σ_B π(B)·S̄_n(B)² + (2/γ)·E Σ_{t≤n} (KL(P‖q_t)(x_t) + KL(q_t‖R_t)(x_t)) = E Σ_{t≤n} Σ_B π(B)·ḡ_t(B)² + (2/γ)·E Σ_{t≤n} KL(P‖R_t)(x_t) ≤ n + (2/γ)·E Σ_{t≤n} KL(P‖R_t)(x_t).

*Proof.* S̄_t(B)² = S̄_{t−1}(B)² + 2·S̄_{t−1}(B)·ḡ_t(B) + ḡ_t(B)². Multiply by π(B) and sum over B (|S̄_{t−1}(B)| ≤ t − 1, so all series converge): the middle terms sum to (2/γ)·((q_tΛ_t)(x_t) − Λ_t(x_t, y_t)), which by Lemma 7.5 is (2/γ)·(ln(q_t(y_t|x_t)/R_t(y_t|x_t)) − KL(q_t‖R_t)(x_t)). Sum over t. (i) follows from q_t ≤ 1, KL ≥ 0 and ḡ_t(B)² ≤ 1. (ii) Given the past and x_t, the expectation of ln(q_t(y_t|x_t)/R_t(y_t|x_t)) is KL(P‖R_t)(x_t) − KL(P‖q_t)(x_t). ∎

**Remarks 7.9 (what the randomised version gives, and what it does not).**

1. *The same guarantee against answers drawn from P.* Yes, in expectation and with high probability, for a base that is not too far from the human: by Theorem 7.6(ii) the price of a base R is its cumulative divergence Σ_t KL(P‖R_t)(x_t) from the human, divided by β; by (i) it is the base's cumulative logarithmic loss on any sequence. A base that gives probability 0 to an answer the human gives cannot be tilted to match: with R(y*|x) = 0, a human who always answers y*, and the test {(x, y*)}, S̄_n = −n for every tilt.
2. *Books in expectation.* The theorems bound the expected books S̄_n. The books of the answers actually drawn differ from them by a martingale with increments in [−1, 1], so by at most √(2n·ln(2/δ)) with probability 1 − δ; in rehearsal only expectations are needed (Corollary 7.7(a)).
3. *The deterministic rule is the limit β → ∞* of Theorem 7.6: the tilt concentrates on the minimisers of the score within the support of the base.
4. *Both tilts are online mirror descent on the tilt parameters.* Write the tilted family as q_λ(y|x) ∝ R(y|x)·exp(−Σ_B λ(B)·b_B(x, y)). The derivative of its logarithmic loss −ln q_λ(y_t|x_t) with respect to λ(B) is b_B(x_t, y_t) − (q_λ b_B)(x_t) = −ḡ_t(B): the expected increments are the negative gradient. Theorem 7.8 is gradient descent on λ with the step γ·π(B) for the coordinate B (the Euclidean mirror map); it is the quadratic potential (Blackwell's strategy; Proposition 5.1; for binary answers Vovk's K29*), with the weight of the test outside the logarithm, √(n/π(B)). Theorem 7.6 is mirror descent with the entropic mirror map: λ_t is β·sinh(η) times the difference of the exponentiated-gradient weights π(B)·e^(±η·S̄_{t−1}(B))/(2Φ_{t−1}) of the signed tests (the algorithm EG± of J. Kivinen and M. Warmuth, "Exponentiated gradient versus gradient descent for linear predictors", Inform. and Comput. 132 (1997) 1–63; from memory); it is the exponential potential, with ln(1/π(B)). In batch form, the tilt of a reference by a few tests is the construction of C. Dwork, M. Kim, O. Reingold, G. Rothblum and G. Yona, "Beyond Bernoulli: generating random outcomes that cannot be distinguished from Nature", ALT 2022 (PMLR 167), Proposition 17, for outcome indistinguishability (digest, §3.2, Lemma I1a; not read by me).
5. *A trade-off that is not resolved.* Identity (ii) of Theorem 7.8 is a balance: the tilted sampler's cumulative divergence from the human plus (γ/2) times its squared books equals that of the base plus at most γn/2. With γ of order 1 the books are of order √n for every base with bounded divergence per call, but the tilted sampler may be worse than a good base by γn/2 in cumulative divergence; with γ of order K/n the tilted mixture keeps the mixture's bound 2K·ln 2 under A2, but then the books are only bounded when the base is good. Theorem 7.6 with β = 1 has the same character (Corollary 7.7(b): the test bound then contains K). The reason is that the tilt reacts to the realised books, which fluctuate by order √n even when the base is exactly the human. **OPEN:** is there a randomised imitator with Σ_t E KL(P‖q_t)(x_t) = O(K) whenever A2 holds and |S̄_n(B)| = O(√(n·(Λ(B) + ln n))) for every test with no assumption? A candidate is a tilt that is switched on only for tests whose books leave the band √(2(n + 1)(Λ(B) + ln(1/δ) + ½·ln(n + 1))) that the books of the human's own kernel leave with probability at most π(B)·δ; I have no proof.
6. *What randomisation repairs and what it does not.* A kernel answers the same question twice with independent draws, so the degenerate failure of Proposition 7.3 disappears when the base is spread out; but tests of single calls still do not control joint behaviour, for the tilted sampler as for the rule (the deployed imitator is a mixture over rounds of kernels, and Proposition 7.4 is the remedy in both cases).

---

## 8. Two comparisons with the Bayes mixture

The mixture is that of the note: a class H of samplers with weights w, the posterior given the asked pairs, and M^(t) the mixture before round t; it answers by drawing a hypothesis from the posterior and letting it answer. Hypotheses are indices: two indices may name the same sampler, and K := log₂(1/w(P)) refers to the index named P.

### 8.1 The imitator from tests keeps a simple property that the mixture does not keep

**Proposition 8.1 (memorisers). NEW** (the batch form of this phenomenon, with a slightly different class, is Theorem 4.5 of `research/prove-c/property-batch.md`, written in parallel by another worker and not checked by me; the statement and proof here are self-contained). Let N ≥ 1 and A ≥ 1 be integers, 0 < p < 1 and K ≥ 1. Let X = {1, …, N} and Y = {0, 1, …, A}; call 0 *the bad answer* and let R := {(x, y) : y ≠ 0}. Let the human be any function f: X → {1, …, A}; it never gives the bad answer. For a set D ⊆ X and a table τ: D → {1, …, A} the *memoriser* m_{D,τ} answers τ(x) for x ∈ D and 0 for x ∉ D. The class H consists of the index f with weight w(f) := 2^(−K) and of the memorisers with weights

  w(m_{D,τ}) := ½·p^(|D|)·(1 − p)^(N−|D|)·A^(−|D|),

whose sum is ½. So A2 holds, and the human has description length K in this class. Put μ_k := ½·(p/A)^k/(½·(p/A)^k + 2^(−K)) and k* := ⌊(K − 1)/log₂(A/p)⌋.

(a) After the human has answered k distinct questions, the mixture answers every question it has seen as the human does, and answers every other question with the bad answer with probability (1 − p)·μ_k; and μ_k ≥ 1/2 if k ≤ k*.

(b) On every sequence of n distinct questions (N ≥ n) the expected number of rounds in which the mixture's answer is bad is (1 − p)·Σ_{t≤n} μ_{t−1} ≥ (1 − p)·min(n, k* + 1)/2. In particular a mixture that has seen at most k* questions violates R at a new question with probability at least (1 − p)/2; this covers M^(T) for every round T ≤ k* + 1. The expected number of bad answers before the mixture has learned R is therefore at least (1 − p)·(K − 1)/(2·log₂(A/p)): it grows in proportion to the description length of the human, although R is a property of constant complexity.

(c) In rehearsal with L = 1 and questions drawn independently and uniformly from X, the expected number of bad answers of the mixture among the first n ≤ k* + 1 rounds is at least (1 − p)·(n/2)·(1 − n/(2N)).

(d) Rule NH with any family that contains R gives the bad answer in at most K(R) + 2 rounds in total, on every sequence of questions, for every human who never gives the bad answer, whatever the human's description length and whether or not the human belongs to any class; under rehearsal the deployed imitator gives it at an expected rate of at most (K(R) + 2)/n per call slot (Theorem 6.2(c)). With π(R) = 1/2: at most 3 rounds.

*Proof.* (a) All hypotheses are functions, so the posterior weight of a hypothesis is its prior weight if it agrees with the human on the questions asked, and 0 otherwise. Let Q be the set of the k questions asked. The memoriser m_{D,τ} agrees with f on Q exactly if Q ⊆ D and τ = f on Q (for x ∈ Q∖D it answers 0 ≠ f(x)). The total weight of these memorisers is ½·Σ_{D⊇Q} p^(|D|)·(1 − p)^(N−|D|)·A^(−|D|)·A^(|D|−k) = ½·(p/A)^k·Σ_{D′⊆X∖Q} p^(|D′|)·(1 − p)^(N−k−|D′|) = ½·(p/A)^k, and for x ∉ Q the weight of those among them with x ∉ D is ½·(p/A)^k·(1 − p). The index f has weight 2^(−K) and never answers 0. So the posterior probability of the answer 0 at x ∉ Q is (1 − p)·μ_k. At x ∈ Q every hypothesis of positive posterior weight answers f(x). Finally μ_k ≥ 1/2 iff ½·(p/A)^k ≥ 2^(−K) iff k·log₂(A/p) ≤ K − 1. (b) Before round t the human has answered t − 1 distinct questions and the question of round t is new; μ_k decreases in k; and k* + 1 ≥ (K − 1)/log₂(A/p). (c) The question of round t is new with probability at least 1 − (t − 1)/N, the number of distinct earlier questions is at most t − 1 ≤ k*, and Σ_{t≤n} (t − 1) ≤ n²/2. (d) Theorem 3.3(ii): the human's answer always lies in R. ∎

*Remarks.* (1) The mixture does what Theorem R1 says: its expected number of unfaithful answers is at most K·ln 2 on every sequence. The example shows that it may spend this whole budget on violations of one simple property; (1 − p)/(2·log₂(A/p)) ≤ ln 2 as it must be. (2) The weights "favour memorisers" in this sense: a table of k pairs costs k·log₂(A/p) + 1 bits where the human costs K bits, so the tables outweigh the human until about K/log₂(A/p) pairs have been seen; and a memoriser says nothing sensible off its table. (3) With the test family of Corollary 3.4 (R with weight 1/4, the tests B_ν of the class with weights w(ν)/2, and anything else with the remaining weight) Rule NH has both guarantees on this class: at most 4 bad answers, and at most K + 3 answers that differ from the human's. (4) *A human outside the class.* If the class consists of a single sampler ν that gives the bad answer with probability 1/2 at every question, the mixture is ν for ever and violates R half of the time, whatever the human does; Rule NH with R in its family is not affected. In general, when A2 fails nothing is known about the mixture's rates of tests, while Theorems 3.1 and 3.3 do not mention a class.

### 8.2 Where the mixture is far better

**Proposition 8.2. NEW.**

(a) (*A deterministic human in the class, against the rule of Theorem Pr5: K·ln 2/n against ln n/(2√n).*) In Example 2.3 let the class be {f, f′} with weights 1/2 each, f′ any other function; so K = 1. On every sequence of questions the Bayes mixture gives an answer different from the human's in at most ln 2 rounds in expectation, for all n together. The rule of Theorem 2.1 with η = 1/√n, on the family of Example 2.3 with π(B) = 1/(2n) and π(D) = 1/2, gives an answer that the human never gives in min(⌊n/2⌋, N*) ≥ min(⌊n/2⌋, ½·√n·ln n) rounds. Per round: at most 0.7/n against at least ln n/(2√n), for n ≥ 400.

(b) (*A deterministic human in the class, against every rule built from a family that lacks the right test.*) In Example 7.1 let the class be {f, 1 − f} with weights 1/2. The mixture's answer differs from the human's in 1/2 round in expectation (the first), and never afterwards. The imitator built from the family {X × {1}} differs in every round.

(c) (*A human who is not deterministic: closeness of runs.*) In Proposition 7.3 let the class be {P}, the fair coin. The mixture is P, its runs have the law of the human system, and every property of runs has exactly the human system's probability. The deployed imitator from tests is at total variation distance at least 1/2 from the human system for every n, for every family of tests of single calls.

*Proof.* (a) For a deterministic human in the class, Σ_t (1 − M^(t)(f(x_t)|x_t)) ≤ ln(1/w(f)) = K·ln 2 on every sequence (proof of Theorem R1 in the note: Π_t M^(t)(f(x_t)|x_t) ≥ w(f) and −ln(1 − e) ≥ e). The second claim is Example 2.3; for n ≥ 400, ½·√n·ln n ≤ n/2. (b) Before the first answer the mixture answers f(x_1) with probability 1/2; afterwards the hypothesis 1 − f has posterior weight 0. The rest is Example 7.1. (c) Proposition 7.3. ∎

**What remains of "K·ln 2/n against 1/√n" (the lead's bullet "The rate" in Section 8.4 of the note). MODIFIED.** The comparison is correct for the rule of Theorem Pr5 and a deterministic human ((a) above). It does not describe the imitator from tests in general:

1. *Deterministic human, one-sided tests.* With Rule NH a property that the human always has is violated at most K(B) + 2 times, a rate of (K(B) + 2)/n per round, where the mixture under A2 has K·ln 2/n for all such properties together. If the tests "the answer is not ν's" of the class are in the family, the imitator from tests errs at most K + 3 times (Corollary 3.4). So for a deterministic human the two rates are of the same order in n, and what differs is the price: the complexity of the property against the complexity of the human, 1/ln 2 = 1.44 times more per bit, and no assumption against A2.
2. *A human who is not deterministic, two-sided tests.* Under A1 and A2, Theorem R1 and Pinsker's inequality give for the mixture: the average over the rounds of the expected total variation distance between P(·|x_t) and M^(t)(·|x_t) is at most √(K·ln 2/(2n)). So the mixture's rates of all tests at once are within √(K·ln 2/(2n)) of the human's on average. The imitator from tests has about √((2Λ(B) + ln(n + 1))/n) per call slot, in expectation, for the tests of its family (Theorem 6.2(a)). Both are of order 1/√n; the rate K·ln 2/n of the mixture is a rate for the divergence, not for the frequencies of tests. Given the rehearsal, the order 1/√n cannot be improved for either (Section 6.3).
3. *What the mixture has and tests of single calls cannot give:* all tests at once, including those nobody thought of (Proposition 8.2(b)); closeness of whole runs (Proposition 8.2(c); Theorem R2 of the note); and a sampler, not a book-keeping rule. *What it lacks:* any guarantee when A2 fails, and the price of the property (Proposition 8.1).

| | Bayes mixture, a draw from the posterior at each call | Rule NH on a weighted family of tests |
|---|---|---|
| assumed about the human | A1 and A2 (the human is in the class) | nothing for the bounds on the books; A1 at the asked calls for the rehearsal corollary |
| a property B the human always has: violations in n rounds | at most K·ln 2 in expectation for all such B together; can be of order K for one simple B (Proposition 8.1) | at most K(B) + 2 for each B of the family (Theorem 3.3) |
| deterministic human of the class: rounds with a different answer | at most K·ln 2 in expectation | at most K + 3 if the tests B_ν of the class are in the family (Corollary 3.4); otherwise no bound (Example 7.1) |
| rate of a test B per call slot, human not deterministic | within √(K·ln 2/(2n)) on average, for all tests at once | within √((1 + 1/n)·(2Λ(B) + 1.39 + ln(n + 1))/n) in expectation, for the tests of the family |
| whole runs | E TV ≤ 2·√(L·K·ln 2/n) (Theorem R2, `research/prove-b/hellinger-runs.md`) | none from tests of single calls (Proposition 7.3); outcomes with a simple continuation value (Proposition 7.4) |
| deployed object | one mixture, or the mixture of a random round | the rule of a random round, drawn afresh for each run (Example 6.5) |
| computation | a posterior over the class | a search over answers; needs a bound on the answers or a halting oracle (Section 4) |

---

## 9. Numerical checks

All scripts are in `research/prove-c/code/`; each prints to the file of the same name with the extension `.out`. They use numpy and scipy only and fixed seeds. They check statements proved above; nothing in the proofs depends on them.

**9.1 `property-online_potentials.py`: the one-step inequalities of Lemma 1.4** on grids of rates, books, clocks and increments (and for the halving potential on all sequences in {−1, 0, 1}^t, t ≤ 9). The gap (right side − left side) of (1.1), relative to the right side, must be ≥ 0; for the identities it must be 0. Output (E1 to E7 are the script's labels; the items of Lemma 1.4 are in its docstring):

```
E1 (cosh, clock t), g in [-1,1]:        min relative gap RHS-LHS = -1.327e-14
E2 (cosh, clock v, exp(-v eta^2/2)):    min relative gap RHS-LHS = 1.826e-44
E3 (cosh/cosh(eta)^v), g in {-1,1}:     max |RHS-LHS| (identity) = 4.607e-14
E4 (halving), all sequences, t <= 9:    max |RHS-LHS| (identity) = 0.000e+00
E6 (normal mixture G_v), g in [-1,1]:   min relative gap RHS-LHS = 2.499e-11
E6 integral representation of G_v:      max relative error       = 4.764e-16
E7 (products), g in [-1,1]:             max |RHS-LHS| (identity) = 4.036e-16
```

(The value −1.3·10⁻¹⁴ in the first line is rounding at g = ±1, where (1.3) is an equality.) The script also confirms cosh η ≤ e^(η²/2), ln(1 + u) ≥ u − u² on [−1/2, 5] and e^(−x) ≤ 1 − (1 − e^(−1))x on [0, 1] on grids.

**9.2 `property-online_fastrate.py`: Example 2.3 and Proposition 3.5.** Number of rounds, out of n, in which the imitator gives the answer that the human never gives (δ = 1/2; columns: the rule of Theorem 2.1 with η = 1/√n, the formula min(⌊n/2⌋, N*), the bound of Theorem 2.1; Rule N and the bound of Corollary 3.2(b); Rule NH and the bound K(B) + 2):

```
       n       beta  lead: count   formula  Pr5 bound  N: count   bound  NH: count   bound
     100   5.00e-03           30        30       64.9         6    15.3          3     9.6
    1000   5.00e-04          132       132      278.1         9    20.2          6    13.0
   10000   5.00e-05          530       530     1109.7        13    25.0          8    16.3
  100000   5.00e-06         2040      2040     4237.2        17    29.8         11    19.6
  100000   5.00e-11         5681      5681     7877.9        39    53.4         26    36.2
```

(five of the twelve rows of the output; the count of the rule of Theorem 2.1 equals the formula in all twelve). For Proposition 3.5 the script runs Rule NH on the 2^m table tests against the human who answers the opposite: the never-satisfied test is satisfied by the imitator m times for m = 1, 2, 4, 8, 12, against the bound m + 2.

**9.3 `property-online_rules.py`: the bounds on arbitrary sequences.** Five rules (Theorem 2.1; its variant with the clock of the test, Remark 2.2(3); Rule N; Rule NH; the grid of Proposition 3.7) on three families (30 and 200 random tests of equal weight; 40 random tests with weights proportional to 2^(−k)) against three humans (a random stateless sampler; a human who always gives an answer different from the imitator's; a sampler that avoids a random set of pairs), n = 4000. For every rule the largest value of (left side)/(bound) over all rounds t ≤ n and all tests is at most 1; the largest values seen are 0.46 (Theorem 2.1 and its variant), 0.65 (Rule N), 0.65 (Rule NH, including the halving bound for pure tests) and 0.83 (grid). On the family with weights 2^(−k) the largest book at n = 4000 is 7.6·√n for the rule of Theorem 2.1 and 3.1·√n for Rule N (random human).

**9.4 `property-online_rehearsal.py`: the rehearsal corollary on the tree of additions** of the lead's toy (805 tests, of which 246 are never satisfied by the human; L = 7; the human adds 1 too much with probability 0.1 at each call). The per-run discrepancies d_B(a_t) of every round's rule are computed exactly by enumerating the 256 vectors of leaves.

```
n = 8000, rule NH
    max ratio (1): 0.2186                         largest |Delta_n(B)| / right side of (6.1), delta = 0.05
    max |Delta|: 0.0793                           largest |Delta_n(B)| (calls per run)
    max (L/n)|S|: 0.0201
    never: max N_n(B): 2.0000                     against K(B) + 2 >= 9.08
    y=sum+1: mean, min, max of n_B(a_t): 0.7690, 0.0000, 5.0312      (the human: 0.7)
    y=sum+1: share of rounds with |d_B(a_t)| > 0.35: 0.8175
    root exact, deployed: 0.5710                  (the human system: 0.4783)
```

(the comments on the right are added here). The same quantities for n = 1000 and for the rule of Theorem 2.1 are in the output file; (6.1) holds in all four runs with ratios between 0.08 and 0.22, and the root is exact with probability between 0.57 and 0.63.

**9.5 `property-online_lower.py`: Proposition 3.6.** Rule N against the adversary of the proof:

```
     d       n  D (rule N)  lower bound  upper bound  D/sqrt(n)
    32    1000          39         13.2        117.7       1.23
   100   10000         121         41.4        429.2       1.21
  1000   10000         162         90.5        479.9       1.62
```

With a fair-coin human and the same questions, the root mean square of max_k |S_n(B_k)| over 200 repetitions is 29.0 for d = 32, n = 1000 (lower bound for the maximum over t: 11.7).

**9.6 `property-online_mixture.py`: Section 8.** The formula of Proposition 8.1(a) agrees with a brute-force sum over all 243 memorisers for N = 5, A = 2 (largest difference 2·10⁻¹⁵). Expected number of bad answers of the mixture on n distinct questions, and the number of bad answers of Rule NH (family: R with weight 1/2 and the tests "the answer is c"):

```
     K    A      p      n    k*  mixture: bad answers  lower bound   K ln 2  rule NH: bad answers  bound
    50    4   0.50    170    16                  8.42         4.25     34.7                     1      3
   200    4   0.50    670    66                 33.42        16.75    138.6                     1      3
  1000    4   0.50   3340   333                166.75        83.50    693.1                     1      3
  1000   16   0.05   1210   120                114.54        57.47    693.1                     1      3
```

Example 2.3 with β = 1/(2n): 74, 530 and 3454 answers that the human never gives for n = 400, 10⁴ and 250000 (½·√n·ln n: 59.9, 460.5, 3107.3). Example 7.1: 1000 wrong answers in 1000 rounds with final book 0.

**9.7 `property-online_tilt.py`: Section 7.4.** For three bases (uniform; a fixed kernel different from the human; the Bayes mixture of a class of 8 kernels that contains the human) and β ∈ {1, 644, 6438} (n = 2000, η = 1/√n, 12 tests, 40 repetitions each): the pathwise bound (i) of Theorem 7.6 and the two inequalities (iii) hold in every round of every repetition; the ratio of max_B E|S̄_n(B)| (estimated) to the bound (ii) is between 0.005 and 0.56. The identity of Theorem 7.8 holds on single paths to all printed digits, for example for the uniform base and γ = 1: both sides 257.157332.

**9.8 `property-online_variants.py`: Propositions 2.4, 3.8, 4.3, 5.1 and Theorem 3.1 for tests with values in [0, 1].** 24 tests with values in [0, 1] (every second one a set), weights proportional to 2^(−k), n = 3000; largest (left side)/(bound) over all rounds and tests:

```
human              N      decr      quad      prod     trunc
random         0.357     0.306     1.000     0.508     0.618
opposite       0.202     0.198     1.000     0.444     0.486
constant       0.103     0.416     1.000     0.196     0.404
    prod, test 'zero' (human value always 0): sum of the imitator's values = 0.849, bound 4 ln(4/pi) = 8.318
```

(N: Theorem 3.1; decr: Proposition 2.4 with c = 1; quad: Proposition 5.1, where the value 1.000 is the equality in round 1; prod: Proposition 3.8; trunc: Proposition 4.3 with M_t = 2^t − 1.)

**9.9 `property-online_interior.py`: Proposition 6.6.** L = 1, 8 questions drawn uniformly, 4 answers, 6 random set tests of weight 1/6, a human kernel with full support; μ₀ estimated from above as 0.082 (minimum of E_x m_x(S)/‖S‖_π over 200000 random directions and the coordinate directions), C(μ₀) = 559. Means over 300 repetitions:

```
rule quad:
    n =    100:  mean ||S_n||_pi =  0.943,  mean max_B |S_n(B)| =  1.523,  mean max_B |S_n(B)| / n = 0.01523
    n =   1000:  mean ||S_n||_pi =  0.947,  mean max_B |S_n(B)| =  1.543,  mean max_B |S_n(B)| / n = 0.00154
    n =  10000:  mean ||S_n||_pi =  0.936,  mean max_B |S_n(B)| =  1.547,  mean max_B |S_n(B)| / n = 0.00015
rule N:
    n =    100:  mean ||S_n||_pi =  0.937,  mean max_B |S_n(B)| =  1.587,  mean max_B |S_n(B)| / n = 0.01587
    n =   1000:  mean ||S_n||_pi =  0.946,  mean max_B |S_n(B)| =  1.557,  mean max_B |S_n(B)| / n = 0.00156
    n =  10000:  mean ||S_n||_pi =  0.929,  mean max_B |S_n(B)| =  1.527,  mean max_B |S_n(B)| / n = 0.00015
```

The books do not grow with n for either rule; the proposition covers the first.

---

## 10. What remains open; what I noticed elsewhere

### 10.1 Open in this part

1. **The logarithm in the two-sided rate.** Upper bound √((n + 1)(2Λ(B) + ln(n + 1))) (Theorem 3.1), lower bound of order √n for families of √n tests (Proposition 3.6). For d = n tests of equal weight the true order is √(n·ln n) if the value of Spencer's game has that order, which I believe (memory) but have not checked; for general weighted families the dependence on Λ(B) is not matched by a lower bound here.
2. **The best constant with ln ln n.** Proposition 3.7 has the constant 3/√2 with a term of order ln ln n; Theorem 3.1 has √2 with ln n. The constant √2 with ln ln n should follow from the mixing measure of Chernov and Vovk (Remark after Proposition 3.7); not derived here.
3. **Rehearsal is not adversarial.** In rehearsal the questions come from the scaffold and the human is a fixed sampler. In the toy the books stay far below the worst-case bounds (|S_n(B)| ≤ 23 at n = 8000 under Rule NH, where the bounds of Theorem 3.3(i) lie between 373 and 466). Proposition 6.6 proves bounded books for the quadratic rule under the interior condition (I). Open: the same for Rules N and NH (the simulation of Section 9.9 suggests it); families that contain both one-sided tests and tests with interior rates; and a rule that has bounded books in this sense together with the worst-case bound √(n·Λ(B)) of Theorem 3.1 (the quadratic rule has only √(n/π(B)) in the worst case). None of this changes the rate given the rehearsal (Section 6.3).
4. **One imitator with both prices for a human who is not deterministic** (Remark 7.9(5)): cumulative divergence O(K) under A2 and books O(√(n(Λ(B) + ln n))) without any assumption. For a deterministic human Corollary 3.4 does this.
5. **Weights that are only enumerable** (for instance 2^(−prefix complexity)): do the bounds hold for the limit of the rules computed from lower approximations of the weights (Section 4)?
6. **Fast one-sided rates for tests with values in [0, 1]** are proved only for the product potential (Proposition 3.8, constant 4·ln(4/π(B))); whether the sharp constant of Theorem 3.3(ii) has an analogue is open.
7. **Per-call redraw of the round** in deployment (Remark 6.4(4)) is not covered; I expect it to fail in general for tests that conflict across calls, and have no worked example with Rule N.

### 10.2 Noticed elsewhere in the project's files

1. `note.md`, Section 8.3, statement of Theorem Pr5: correct. The sentence after the proof, "the argument is the one behind Blackwell's approachability theorem and behind forecasting that passes countably many checking rules", should be made exact as in Section 5: the potential argument is Spencer's (1977) for balancing games and potential-based approachability; the calibration statement that fits is the one for checking rules that do not depend on the current prediction (Lehrer 2001; Perchet's survey, Theorem 3.2), not the theorem of Sandroni, Smorodinsky and Vohra, whose checking rules depend on the forecast and need randomisation.
2. `note.md`, Section 8.3, last paragraph: "for a bad kind of answer that the human never gives, the imitator gives it at most (ln(2/π(B)) + 1/2)/√n of the time per call". True for the rule of Pr5, and Example 2.3 shows that this rule can really give about half of that. With Rule NH the bound is (K(B) + 2)/n. The note should state the second.
3. `note.md`, Section 8.4, first bullet: "A property of complexity k is matched to within about k/√n." With Rule N: √((2k·ln 2 + ln n)/n). Same bullet: "Being the answers of this particular human is a property of complexity about K": true for a deterministic human (and then Corollary 3.4 gives K + 3 errors); for a human who is not deterministic it is not a property of single pairs at all.
4. `note.md`, Section 8.4, bullet "The rate": see the paragraph "What remains of 'K·ln 2/n against 1/√n'" in Section 8.2. K/n is the mixture's rate for the divergence; for the rates of tests of a human who is not deterministic both imitators have 1/√n; for one-sided tests and a deterministic human Rule NH has (K(B) + 2)/n.
5. `note.md`, Section 8.4, bullet "Single calls, not runs": correct; the sharp form is Proposition 7.3 (total variation at least 1/2 for every n), and the reason in the toy is that a rule repeats its answer when a question repeats within a run.
6. `note.md`, corollary of Section 8.3: correct as stated (Theorem 6.2(a)). It should say what is assumed (A1 for the asked calls and A3; not A2) and that the comparison is with the human's rate *on the imitator's own questions*.
7. `research/candidate-theory.md`, Pr5: the stated aim "|S_n(B)| ≤ O(√(n·ln(1/π(B))))" is not what the single-rate rule gives (it gives √n·ln(1/π(B))); it is what Rule N gives, up to ln n. The question at the end, "fast rate O(K(B)/n) for properties the human never violates?", has the answer yes (Theorems 3.3 and 6.2(c)), and the answer no for the rule of Pr5 (Example 2.3).
8. `research/understand/indistinguishability.md`, §3.7, Remark: the bound (3/√2)·√(n·Λ_b) with Λ_b = ln(2/π(b)) + 2·ln(log₂ n + 2) for Λ_b ≤ n/2, n ≥ 4, is correct (I re-derived it; Proposition 3.7 is the same calculation with the clock of the test). Its Theorem C2 is correct; Proposition 7.4 restates it with Rule N. Its item 3 of §5 attributes "countably many checking rules, asymptotically" to Sandroni, Smorodinsky and Vohra; see item 1 above.
9. `code/toy_property.py`: the bound printed in the column "bound for that B" is that of Theorem 2.1 divided by n; correct. The script breaks ties by the least answer (numpy's argmin), which is one of the admissible choices.

### 10.3 What Sections 8.3 and 8.4 of the note should say (for the editor)

* State the rule as Rule NH (or Rule N for tests with values in [0, 1]) and Theorem 3.3 in place of the single-rate statement; keep Theorem Pr5 as the simple case with its short proof.
* State the rehearsal corollary as Theorem 6.2(a), (c) and Theorem 6.3, with the assumptions (H1), (H2), and Example 6.5 for "a fresh rule for each run".
* For the limits: Example 7.1 (outside the family), Proposition 7.3 (runs), Proposition 4.4 (the search over answers), and Remarks 7.9 for the randomised version.
* For the comparison with the mixture: Proposition 8.1 and the table of Section 8.2.
* Labels: Theorem 2.1 keeps the label Pr5. Theorems 3.1 and 3.3 (the rule for all n with the one-sided rates), Theorems 6.2 and 6.3 (rehearsal), and Theorem 7.6 (randomised version) need the next free numbers of the letter Pr; I have not assigned them, because the part property-batch may also add statements with this letter.

