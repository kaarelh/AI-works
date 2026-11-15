# An imitator built from tests alone: the online property imitator (key: property-online)

Prover's file for Sections 8.3 and 8.4 of the note (label Pr5). Everything below was derived or checked in this session; the scripts are in `research/prove-c/code/property-online_*.py` and their outputs are quoted in Section 9. Tags: **PROVED** (a statement of the lead's draft, with a complete proof here), **MODIFIED** (the lead's statement is changed, and the change is stated), **REFUTED** (with the counterexample), **NEW** (not in the lead's draft; complete proof here), **OPEN**.

## Summary table

(This table lists what the file contains at the time of the last save. Sections 3 to 10 are being written; their rows are added as they are finished.)

| No. | Statement | Tag |
|---|---|---|
| Lemma 1.3 | Balancing lemma: if each test has a potential whose growth in a round is linear in that round's increment, the answer that minimises the slope-weighted score keeps the weighted sum of potentials from growing | NEW |
| Lemma 1.4 | Six potentials that qualify (hyperbolic cosine with either clock, normal mixture, halving, products, mixtures) | NEW |
| Theorem 2.1 | Pr5 as the lead states it: \|S_n(B)\| ≤ ln(2/π(B))/η + nη/2 | PROVED |
| Example 2.3 | For a test the human never satisfies, the rule of Pr5 with η = 1/√n gives at least ½·√n·ln n answers in the test (π(B) = 1/(2n)) | NEW |
| Proposition 2.4 | Decreasing rate η_t = c/√t: all n at once, \|S_n(B)\| ≤ (√n/c)(ln(2/π(B)) + (c²/2)(1 + ln n)) | NEW |

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

(b) *Hyperbolic cosine, clock v.* For η > 0: u(γ) = cosh(ηs)·e^(−vη²/2), c(γ) = e^(−(v+1)η²/2)·sinh(η)·sinh(ηs), on 𝔾 = [−1, 1].

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

(b) If g = 0 both sides of (1.1) equal u(γ). If g ≠ 0 then v(γg) = v + 1, and by (1.3) and cosh(η)·e^(−η²/2) ≤ 1, u(γg) = cosh(η(s + g))·e^(−(v+1)η²/2) ≤ cosh(ηs)·e^(−vη²/2) + g·e^(−(v+1)η²/2)·sinh(η)·sinh(ηs). C_k ≤ sinh(η)·sinh(ηk).

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
3. *The potential and the argument are those of Spencer's balancing games* (Section 5.1): with two answers and a human who always gives the other answer, the game is a vector balancing game, and the bound √(2n·ln(2d)) for d tests of weight 1/d at the best η is Spencer's bound for that game.
4. *The answer set.* The rule must be allowed every answer the human can give. If the human may fail to answer and this is recorded as an answer ⊥, then ⊥ must be available to the imitator, or tests that contain pairs (x, ⊥) cannot be matched: with the single test B = X × {⊥} and a human who never answers, an imitator that is not allowed ⊥ has S_n(B) = −n.

**Example 2.3 (for a test that the human never satisfies, the rule of Theorem 2.1 really gives about √n·ln(1/π(B)) answers in B). NEW.** Questions are the integers ≥ 2 and the answers are 0, 1, 2. The human is the function f(x) = 0 for odd x and f(x) = 2 for even x; so the human never answers 1. There are two tests,

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

So for a deterministic human the "price" K of the human and the price K(B) of a property are paid in one imitator, each for what it buys: K + 3 rounds of disagreement if the human is in the class, and K(B) + 3 violations of a property that the human always has, whatever the human is. (Section 8 shows that the Bayes mixture does not have the second property.)

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

*Definitions and statements* (from Perchet's survey, Section 3.2, read). A *checking rule* is a pair (U, T): given the history, U names the set of (prediction, outcome) pairs for which the next stage is *active* and T ⊆ U the *tested* pairs. A strategy is calibrated with respect to (U, T) if, along active stages, the frequency of tested events and the average predicted conditional probability of tested events differ by o(n)/n. Perchet's Theorem 3.2: "Let λ be a probability distribution on the set of checking-rules independent of current predictions. Then there exists a deterministic strategy σ that is calibrated with λ-almost every checking rules", with the remark that "a weaker version first appeared in Lehrer" (E. Lehrer, "Any inspection is manipulable", Econometrica 69 (2001) 1333–1347; not read). Of A. Sandroni, R. Smorodinsky and R. Vohra, "Calibration with many checking rules", Math. Oper. Res. 28 (2003) 141–153 (not read), Perchet says that it "deals with checking rules depending on current predictions", of the form "predictions in a given set F, on stages that are active according to the past history", and states as Proposition 3.2: for countably many such rules there is a strategy (randomised) that is calibrated with every one of them. The abstract of the paper, as quoted in the digest from a search result: "Given any countable partition of [0,1] and any countable collection of subsequences, we construct a forecasting scheme such that for all infinite strings of data, the long run average forecast for a matches the long run frequency of realized a's."

*Exact relation.* Read the human's answer y_t as the outcome and the imitator's answer as the point prediction δ_{a_t(x_t)}, and treat the question as part of the history. A test B is then a checking rule that does not depend on the current prediction: every stage is active and the tested event is B_{x_t}. The frequency of tested events minus the average predicted probability is (h_n(B) − N_n(B))/n = −S_n(B)/n. So "S_n(B)/n tends to 0 for every B" says exactly that the deterministic strategy "predict δ_{a_t(x_t)}" is calibrated, in both directions, with respect to all these checking rules. Hence:

* the statement in the literature that Theorem Pr5 quantifies is the one about checking rules *independent of the current prediction* (Lehrer; Perchet's Theorem 3.2), for which deterministic strategies exist. Theorems 2.1 and 3.1 add: a point prediction suffices, an explicit rule, weights in place of "almost every", and the rate √(Λ(B)/n);
* the theorem of Sandroni, Smorodinsky and Vohra concerns rules that look at the current forecast (the partition of [0, 1]), for which randomisation is necessary (the impossibility for deterministic forecasts is attributed to Oakes and Dawid in Perchet's text). It is analogous, not the same: tests of pairs (question, answer) never look at the imitator's distribution, and this is why a deterministic rule works here. The note's sentence "the argument is the one behind ... forecasting that passes countably many checking rules" should name the first statement, not the second.

Rates for finitely many checking rules: V. Gupta et al. (below, Section 1.2, read) describe D. Foster, A. Rakhlin, K. Sridharan and A. Tewari, "Complexity-based approach to calibration with checking rules" (COLT 2011; not read) as "a non-constructive argument establishing that it is possible to obtain mean calibration loss Õ(√(log K/T)) with respect to a set of K checking rules", and D. Foster and S. Kakade, "Calibration via regression" (IEEE Information Theory Workshop 2006; not read) as "an efficient algorithm based on ridge-regression" achieving multiaccuracy on a collection G of sets "with error rates converging as Õ(√(|G|/T))" which "is deterministic". The second is the rate of Proposition 5.1; the first is the rate of Theorem 2.1.

### 5.5 Defensive forecasting

V. Vovk, A. Takemura and G. Shafer, "Defensive forecasting", arXiv:cs/0505083 (AISTATS 2005, pp. 365–372), Theorem 1 (read): in the game where in each round Reality announces x_n, Skeptic announces a continuous S_n: [0, 1] → R, Forecaster announces p_n ∈ [0, 1], Reality announces y_n ∈ {0, 1}, and Skeptic's capital changes by S_n(p_n)·(y_n − p_n), "Forecaster has a strategy ... that ensures K_0 ≥ K_1 ≥ K_2 ≥ ⋯". Its proof takes a zero of S_n if there is one, p_n := 1 if S_n is always positive and p_n := 0 if always negative; the authors note that if S_n does not depend on p the forecast is 0 or 1 according to the sign of S_n.

*Exact relation.* Lemma 1.3 is defensive forecasting in a different game: Forecaster's move is an answer a ∈ Y, not a probability; Skeptic's capital is the weighted sum of potentials Ψ_t; its change in a round is at most (score of Forecaster's answer) − (score of Reality's answer); and the defensive move is the minimiser of the score. Where Vovk, Takemura and Shafer need continuity in p and the intermediate value theorem, the present game needs nothing, because the tests do not look at the forecast. For Y = {0, 1} and tests of the form C × {1} the rule of Theorem 2.1 is the one they describe for S_n independent of p, with S_n = −Σ_C π(C)·1[x_n ∈ C]·sinh(η·S_{n−1}(C × {1})). Their closing section lists as open directions "extending Theorem 1 to other forecasting protocols (such as multi-label classification)" and "exploring forecasting strategies corresponding to: (a) Hoeffding's inequality, (b) the central limit theorem, (c) the law of the iterated logarithm"; Theorem 2.1 is of kind (a) and Theorem 3.1 and Proposition 3.7 of kind (c), for the present game.

V. Vovk, "Non-asymptotic calibration and resolution", arXiv:cs/0506004v4 (Theoret. Comput. Sci. 387 (2007) 77–89 per memory), Theorems 1 and 2 (read): for a kernel on [0, 1] × X with feature map Φ, continuous in the forecast, the deterministic algorithm K29* ensures ‖Σ_{n≤N} (y_n − p_n)·Φ(p_n, x_n)‖² ≤ Σ_{n≤N} p_n(1 − p_n)·‖Φ(p_n, x_n)‖² for all N, hence |Σ_n (y_n − p_n)·f(p_n, x_n)| ≤ ‖f‖·√(Σ_n p_n(1 − p_n)·K((p_n, x_n), (p_n, x_n))) for every f of the reproducing-kernel Hilbert space; Theorems 3 and 4 show that this cannot be improved. This is the quadratic potential. For binary answers, a randomised imitator with q_t(1|x) = p_t, and tests C × {1}, take Φ(p, x) := (√π(C)·1[x ∈ C])_C; then Vovk's inequality reads Σ_C π(C)·(Σ_{n≤N} 1[x_n ∈ C]·(y_n − p_n))² ≤ Σ_n p_n(1 − p_n) ≤ N/4. It is the counterpart of Proposition 5.1 for the *expected* books of a randomised imitator (Section 7.4), sharper by the factor p_n(1 − p_n), and it has the weight outside the logarithm as Proposition 5.1 has.

### 5.6 Online multiaccuracy and multivalid prediction; online outcome indistinguishability

V. Gupta, C. Jung, G. Noarov, M. Pai and A. Roth, "Online multivalid learning: means, moments, and prediction intervals", arXiv:2101.01739v1 (ITCS 2022), Definitions 3.1 and 3.2, Observation 3.2, Lemma 3.1 and Theorem 3.2 (read). For a finite collection G of groups and n buckets of the forecast, V_s^{G,i} := Σ_{t≤s} 1[μ_t ∈ B(i), x_t ∈ G]·(y_t − μ_t), and the surrogate loss is L_s := Σ_{G,i} (exp(η·V_s^{G,i}) + exp(−η·V_s^{G,i})); Theorem 3.2: with η = √(ln(2|G|n)/(2T)) their randomised Algorithm 1 has E[α] ≤ 1/(rn) + 2·√(2·ln(2|G|n)/T), α the largest |V_T^{G,i}|/T. Their footnote 4 identifies the case without buckets with multiaccuracy.

*Exact relation.* L_s is twice the lead's potential Σ cosh(η·V) with equal weights; the analysis of the increase in one round is the same up to the form of the second-order term (they use e^x ≤ 1 + x + x², the lead uses the addition formula for cosh). The difference is the tests: theirs depend on the forecast through its bucket, which is what calibration means, and this forces a randomised forecast found by a minimax argument (their Lemma 3.2); tests of pairs (question, answer) do not look at the forecast, and the minimax step degenerates to a minimisation. (By their Lemma 3.1, with a single bucket the bound on the expected increase is linear in the forecast and is made non-positive by μ ∈ {0, 1}; this is my reading and is not a statement of theirs.) For binary answers and tests of the form G × {1}, Theorem 2.1 is online multiaccuracy with forecasts in {0, 1}, with weights for countably many groups, and with a deterministic bound.

G. Farina and J. C. Perdomo, "Defensive generation", arXiv:2602.21390v1 (February 2026), Definition 1 and Theorem 1 (informal) (read). Definition 1: an algorithm "satisfies online outcome indistinguishability with respect to a class of distinguishers F if it produces distributions μ_t over Y and statistics p_t such that for any f ∈ F, OIGap_T(f) := |Σ_t E_{p_t}[f(x_t, p_t, y_t)] − Σ_t E_{p_t, ỹ_t∼μ_t}[f(x_t, p_t, ỹ_t)]| is o(T) regardless of Nature's choices of (x_t, y_t)"; Theorem 1 (informal): for multiclass, scalar and vector outcomes and distinguishers in a reproducing-kernel Hilbert space, their procedure "has OIGap_T ≤ O(√T)" in time polynomial in the dimension. Their gap is the *expected* book S̄_n of Section 7.4 for tests f that may also look at statistics p_t of the generated distribution. Compared with it, Theorems 2.1 to 3.3 treat only tests that do not look at the generator, and for these give: realised (not expected) books, a deterministic answer, countable weighted families with the weight inside the logarithm (a kernel bound has the norm of the test, which for the kernel Σ_B π(B)·b_B⊗b_B is 1/√π(B), outside), bounds for all n, and the one-sided rates. They say of their guarantee, as must be said of the present one, that it "does not guarantee closeness in statistical distance".

The digest (`understand/indistinguishability.md`, §4, item 3) reports having found "no published statement of exactly Pr5 (a deterministic rule, countably many weighted tests of pairs)". I found none either; it is a simple case of the statements above.

