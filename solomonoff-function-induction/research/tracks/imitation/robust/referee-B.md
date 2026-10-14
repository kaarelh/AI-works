# Sub-track "robust": report of adversarial referee B (code and counterexamples)

*Referee B, 2026-10-14. Subject: `notes.md` of this sub-track (target I1 of `../00-brief.md`) and its scripts `checks/r1`–`r6`.*

* **What I read.**
  * The brief, in full.
  * `notes.md`, in full.
  * The prover's six scripts and their saved outputs.
  * The Paper 2 statements that the notes use:
    * `setup.tex` and `app-setup.tex`: the data objects, the hull lemma, (F1)–(F5);
    * `recovery.tex` and `app-recovery.tex`: `lem:split:ville`, Theorem A, `thm:split:private`, `prop:recovery:frozen`, `prop:recovery:beyond`;
    * `kinks.tex` and `app-kinks.tex`: `def:kink:kinks`, `lem:kink:main`, `lem:kink:secant`;
    * `parity.tex`: the instance and the four lemmas;
    * `teacher.tex`: `prop:teacher:schedules`, `thm:teacher:main`, `rem:teacher:selected`;
    * `limits.tex` and `app-limits.tex`.
  * I did not read referee A's material, so as to stay independent.
* **My code.** `referee_code/rb1`–`rb6`.
  * Python 3.11.15 with NumPy 2.4.6. The standard library supplies `fractions`, `hashlib` and `itertools`.
  * Each script is either exact (enumeration, exact rationals or exact integer binomials) or seeded. The seed is named in its docstring.
  * Each output is saved next to its script as a `.out` file.
  * None of it shares code with `checks/`.
* **Status markers** used here:
  * **[confirmed: rbN]**: my independent code agrees with the claim.
  * **[confirmed: proof re-derived]**: I re-derived the proof.
  * **[counterexample: rbN]**: my code refutes the claim as worded.
  * **[gap]**: the claim may be true, but the proof given does not establish it.
  * **[scope]**: the statement is true, but a reading in the notes goes beyond it.
  * **[bug: rbN]**: an error in the prover's code.
  * **[evidence: rbN]**: numerical evidence on an open question; not a proof.
  * **[remark]**: as named.
* **Repository.** No git command was run. Files written:
  * this report;
  * `referee_code/`.

---

## 0. Verdict

**No proved statement of the notes is refuted.** Every formal claim I could test survives an independent exact or seeded check. The following hold, each confirmed by exact computation:
* Lemma 2.1 (Ville with side information);
* Lemma 4.4 (the alien coding lemma), its semimeasure and Jensen steps;
* Proposition 4.3 (the window as a rate condition);
* Remark 3.4 (the per-query bound on partial fill-ins).

I also confirmed, in an exact class over **all** couplings of a type class, the counting mechanism behind Lemma 4.5 and Theorem 4.6: an alien can beat the right line of slope 2^-m by j bits only on at most a Kraft · 2^-j fraction of the couplings, and the couplings on which the window closes are exactly the structured ones. All six prover scripts reproduce byte for byte.

**Three issues need changes before any of this goes into the paper.**
* **B1 [scope; substantive]: as written, the latent-cause reading of Theorem 4.6 is weak or inapplicable whenever the input channel is complex.**
  * Setting 4.1 puts the environment's input mechanism μ(·|·) into the "human's model" h*. So the human's program must encode the environment.
  * A shorter copy of the human that does not encode μ then violates the left condition.
  * Alternatively, every offset grows by K(μ | h, ρ).
  * A repair is available: condition every complexity on μ. See §2.
* **B2 [counterexample: rb4(C)]: "the set of aliens a procedure is robust against is the set of humans it cannot copy" is false as a general statement.** It appears after Proposition 4.9(a) and in §6.2 item 2.
  * Proposition 4.9(a) is correct, but it concerns only the alien whose kernel is the data law P*.
  * I give a procedure that, in the same toy class, is robust against a partial memoriser and also copies that memoriser when it *is* the human. Its two success probabilities sum to 1.98.
* **B3 [scope; rb5(A)]: §6.1 item 1 says the in-context learner "is not a single hypothesis when randomness is private to each query". This is not so.**
  * The learner is excluded by restricting the *hypothesis class* to product (or episodic) hypotheses, not by any property of the data.
  * With i.i.d. private-coin data and a history-aware class, the learner is the λ-MAP in 20 of 20 runs at every printed checkpoint from n = 1000 to 10^5, and the human's program is never selected.

**Smaller items.**
* B4: Corollary 4.7(a), "unconditional", needs a precise reading of what it solves.
* B5: Proposition 4.9(b) has a proof gap at the boundary, and its condition is not sufficient.
* B6: Corollary 4.8 is stated for "any countable Kraft class", but needs a class in the sense of `def:setup:class`.
* B7: three summary sentences drop the offsets.
* B8: Remark 4.12 is a sketch.
* B9: a floating-point code-length bug in r2, r3 and r4.
* B10: two "computed" statuses rest on identities.
* B11: wording.

**Open questions (§5).** I have numerical evidence on two of them:
* Non-uniform cells: the lower end of the window tracks the heaviest coin-1 cell, as the notes conjecture.
* A single hidden-Markov trajectory without a dominating member: the MAP settles on the human in every run.

---

## 1. Re-run of the prover's scripts

**[confirmed]**
* **Method.** The six scripts were copied to a scratch directory and run with `python3 -I`.
* **Outputs.** All six are **byte-identical** to the saved `.out` files.
* **stderr.** Empty for all six.
* **Times.** r1 5 s, r2 1 s, r3 6 s, r4 36 s, r5 354 s, r6 2 s.

SHA-256 of the scripts run:

| script | SHA-256 |
|---|---|
| r1 | `84d0e1104107a010e5c63bc8c6ffaebf849f31814d82ce019ba547882d45d215` |
| r2 | `8636ec7b916443b65a4338cb3e329b40ee166c6bb8c440fde379541ca7fa3818` |
| r3 | `fe0987bf508375dbfb4da79b7023a27bb90eabccbe8ed84ef72942f762f470e8` |
| r4 | `10c659ad82a34d3252e388f6c675467c8662aac93292995460692250eede0d18` |
| r5 | `01a5e707bd162103830420ae4261ea2941bc5e950736ba1222583d9cea6cd45c` |
| r6 | `ddede76dd02f331fe5ee84318cc6d3912871b96e46a6f6086d087ace323b2fd0` |

Two of the prover's numerical statements were checked against sharper references:
* **The Ville tails in r1(A) and r5(A).** They are compared in the notes with 2^-j. The sharper bound is M_0 2^-j, with M_0 the Kraft sum (0.125 in r1, 0.258 in r5).
  * r1(A) is below the sharper bound at every j.
  * r5(A) at j = 1 gives 0.1375 against 0.129, within one standard error of 0.017.
  * My rb5(C), with 4000 runs, gives 0.105 ± 0.005 against 0.1275, and is below M_0 2^-j at every j. So nothing is wrong there.
* **r4(C), "close to the frozen value".** The simulated fraction 0.1465 is the probability that some cell's *first* label is 1. Exactly, this is 1 − (1 − (1 − 0.9^400)/64)^10 = 0.145709, the frozen value to six digits [confirmed: rb6(A)].

---

## 2. Findings that need changes

### B1. The latent-cause reading of Lemma 4.5 and Theorem 4.6 makes the human's program encode the environment [scope; substantive]

**What Setting 4.1 says.** "h* denotes a finite description of (h, ρ, μ(·|·)): the human's model together with the input mechanism. π_H is a program for ν_H … built from a description of h*, so that t_0 := K(h*|π_H) is a constant and K(h*) − t_0 − κ ≤ ℓ_H."

So ℓ_H ≥ K(μ(·|·) | h, ρ) + K(h, ρ) − O(log) − t_0. Yet the human's kernel ν_H(y|x) = ρ(b) at y = h(x, b) does not depend on μ.

**Consequence.** In the latent-cause reading, μ(·|w) is the environment's channel from the coupling variable to the observed input, typically a complex object. Write π_0 for the natural copy, a program for ν_H built from (h, ρ) alone. Then:
* ℓ(π_0) ≤ K(h, ρ) + κ < ℓ_H, once K(μ | h, ρ) exceeds t_0 plus logarithmic terms.
* J_c(π_0) = c ℓ(π_0) + H(ρ) < J_c(π_H).
* K(h* | π_0) ≈ K(μ | h, ρ).

This leaves only two possibilities, and both are bad:
* **The left condition (L_{t,c,ε}) fails** for every t below K(h* | π_0) ≈ K(μ | h, ρ), since π_0 does not "know" h* and beats π_H. Theorem 4.6 then does not apply.
* **t ≥ K(μ | h, ρ).** Then the theorem applies, but the offset G_t ≥ t inflates every conclusion by the complexity of the environment's channel:
  * (ii): ℓ(π) ≤ ℓ_H + G_t/(c2^m − 1);
  * (iv): I_β(π) ≤ … + t;
  * the lower end of the window.

The same applies in the feature case whenever the law μ′ of the rest of the input is complex. It also applies to Corollary 4.7(a), where h* = (ρ, μ(·|·)) for a human that ignores its input altogether. In Paper 2's parity instance μ′ is uniform, so nothing there is affected.

**Repair** [proved here; a re-derivation, not checked by code]. Condition every complexity on μ, and let h_0 := (h, ρ).
1. **Lemma 4.4.** Its proof gives K(β | π, h_0, μ) ≤ 2^m R(π) + O(1), unchanged: the semimeasure Q is lower semicomputable from (π, h_0, μ).
2. **Upper bound.** (F3) and (F1), conditionally on μ, give K(h_0, β | μ) ≤ ℓ(π) + K(h_0 | π, μ) + K(β | h_0, π, μ) + κ.
3. **Lower bound.** Symmetry of information conditional on μ gives K(h_0, β | μ) ≥ K(h_0 | μ) + K(β | h_0, μ, K(h_0|μ)) − κ.
4. **The line.** Hence, for π with K(h_0 | π, μ) ≤ t,
   ℓ(π) − ℓ_0 ≥ 2^m(H(ρ) − R(π)) − [t + δ′_β + |B| log(2^m + 1) + (ℓ_0 − K(h_0 | μ)) + O(log m) + κ].
   * ℓ_0 is the length of the natural copy.
   * δ′_β := L_β − K(β | h_0, μ, K(h_0|μ)).
   * ℓ_0 − K(h_0|μ) ≤ I(h_0 : μ) + κ.

The offset then involves the information shared by the human's model and the environment's channel, which is small in the intended reading. It no longer involves the complexity of the channel. The reference point becomes the natural copy (ℓ_0, H(ρ)), and M_t := {π : K(h_0 | π, μ) ≤ t}.

The explicit-class analogue of the repaired lemma is the counting bound of rb2(B). That bound holds for every fixed μ, whether or not a program "knows" μ: for each fixed μ, Σ_β Σ_π 2^{-ℓ(π)} Q_{π,μ}(β) ≤ Kraft.

**Requested change.**
* State Setting 4.1, Lemma 4.5, Theorem 4.6 and Corollary 4.7(a) with μ in the condition, as above.
* Alternatively, restrict the claims for the latent-cause reading to inputs whose law is simple relative to the human's model.
* As written, §0 item 3 and §6.1 item 3 present the latent-cause case as covered on the same footing as the feature case. It is not.

### B2. "Robustness is blindness" holds for the twin with the same data law, not for aliens in general [counterexample: rb4(C)]

**Proposition 4.9(a) is correct** [confirmed: proof re-derived]: Pr_W[Ψ_n ∈ E(ν_H)] + Pr_{W′}[Ψ_n ∈ E(P*)] ≤ 1.

**The two sentences that do not follow:**
* After 4.9(a): "The set of aliens a procedure is robust against is the set of humans it cannot copy."
* §6.2 item 2: "Being robust against an alien is the same as being unable to copy a human who behaves like that alien."

Both generalise from the single alien P*, the kernel of the data law, to all aliens. For an alien A whose kernel is not P*, the world W_A whose human *is* A has a different data law, so no twin argument applies.

**Counterexample [rb4(C)].**
* *Class K.* Sixteen cells; the human says Bern(3/16); in world W the coin is 1_S(z) with S = {0, 1, 2}.
* *The alien A_1.* "y = 1 on cell 0; Bern(2/15) elsewhere", a partial memoriser with the same marginal rate.
* *World W_A.* The human is A_1, with fresh private coins off cell 0.
* *The procedure Ψ_var.*
  * If every queried cell's labels are constant, it outputs the fresh-coin human, with the empirical rate rounded to {j/240}.
  * Otherwise it outputs "y = 1 on the cells whose ≥ 5 labels were all 1, Bern(rounded rate) elsewhere".
* *Results* (n = 200,000, 200 runs, seed 405):
  * Pr_W[Ψ_var copies W's human] = 0.985.
  * Pr_{W_A}[Ψ_var copies A_1] = 0.995.
  * The sum is 1.98.

So Ψ_var is robust against A_1 in W and also copies a human who behaves like A_1. For comparison, the cn-MAP at c = 0.0594, inside W's window, copies W's human with probability 1.000 and A_1 with probability 0.000. A_1's advantage per bit is 0.0236, below c. So the sentence is true *for cn-procedures*, by the hull lemma, but not for procedures in general.

**What this means for the author's question.**
* With per-query data, and the environment variable observed (the feature case), the data *do* tell environment-driven coins from private coins, for every alien except P*. The labels are a deterministic function of the input in one case and not in the other.
* What imitation data cannot settle is narrower. The data identify P*; whether the difference between P* and the human's fresh-coin kernel ν_H belongs to "the human" or to "the environment" is not identifiable.
* Every procedure must adopt a convention for that one choice. Penalised likelihood with λ = cn adopts it by rate.

**Requested change.**
* Restrict both sentences to the alien with kernel P* (and its behavioural equivalents), or to penalised-likelihood procedures.
* Add the positive statement above. It is cleaner, and it is what the twin argument actually proves.
* §0 item 3 states 4.9(a) correctly ("the twin world with the same data law"). Only the slogans need fixing.

### B3. The in-context learner is excluded by the hypothesis class, not by private randomness [scope; rb5(A)]

**The notes' formal statements are right** [confirmed]:
* Remark 2.4: "a single hypothesis only if hypotheses can carry information across queries; under private randomness per query no hypothesis of H_× can";
* the refuted (a)-brief in the claims table;
* Propositions 5.2 and 5.3.

**The sentence that does not follow.** §6.1 item 1 reads: "A learner that 'just thinks about what the human would say' is not a single hypothesis when randomness is private to each query (Remark 2.4) or to each episode (Proposition 5.3)." This attributes the exclusion to the data. It comes from restricting hypotheses to product (or restart-at-episode) predictors.

**Counterexample [rb5(A)].** Seed 505.
* *Data.* An i.i.d. human with genuinely private per-query coins: x uniform on four values, θ* = (1/8, 3/8, 5/8, 7/8).
* *Class.* A history-aware class with:
  * the 2401 product kernels θ ∈ {1/8, …, 7/8}^4, each of length 20 (an 8-bit family prefix and a 12-bit index);
  * the Bayes mixture U = Σ_θ 2^-12 P_θ, of length 10;
  * a coin.
* *Bound.* Proposition 5.2 gives J_2(U) − J_2(θ*) ≤ −8 for every data set. The observed maximum over 20 runs and all checkpoints up to n = 10^5 is −8.00. The bound is approached because no label switching doubles the human's weight here, unlike in the prover's r5(B).
* *Selection with U.* The λ = 2 MAP is U in 20 of 20 runs at n = 10^3, 10^4 and 10^5, and the human's program is never selected.
* *Selection without U.* In the same class without U (a product class), the MAP is θ* in 19 of 20 runs at n = 10^3 and in 20 of 20 from 10^4 on, as Theorem A says.

**Requested change.** Rephrase §6.1 item 1:
* The learner is excluded when hypotheses cannot carry information across queries (the product class) or across episodes (episodic predictors).
* This is a choice of hypothesis class, a structural assumption about the copy. The data do not force it.
* It belongs with the "restricted class" route of Proposition 3.3(d), and the paper should say so.

---

## 3. Smaller findings

### B4. Corollary 4.7(a), "a coin-flipping human, unconditionally": what exactly is solved [scope; rb4(A)]

With t = K(h*) + κ the left condition is vacuous. But so is conclusion (i), "it knows the human's model". What remains:
* (ii) a length bound;
* (iii) a lower bound on the risk;
* (iv) little information about β;
* (v) J_c(π_H) ≤ Φ(c) + g_t + (c − 2^-m)(ℓ_H − ℓ_fl).

With ℓ_fl ≈ 0, the slack in (v) at c near s_-(H) ≈ (log|Y| − H(ρ))/(ℓ_H − ℓ_u) is about c ℓ_H ≥ log|Y| − H(ρ). That is the whole gap between the human and the uniform predictor. So (v) cannot tell the human from the coin.

What Corollary 4.7(a) gives unconditionally is that *no near-optimal program learns the coupling*. It does not give that a copy is selected:
* above s_-(H) the coin is selected (rb4(A): c = 0.12, coin with probability 1.000 at n = 512);
* in H_× a nearby coin law may be selected (`rem:teacher:selected`).

**Requested change.** In §6.1 item 3, replace "a coin-flipping human, unconditionally" with: "for a coin-flipping human, for every c > 2^-m, every near-optimal program holds at most [bound] bits about the coupling; the human itself is selected only for c below its left steepness, and in H_× possibly only up to its coin law". B1 applies here too.

### B5. Proposition 4.9(b) at the boundary; Corollary 4.8 at c = s_± [gap; rb4(A), rb4(B)]

**What the proof shows.** It covers λ_n/n ≤ c′ < r(π) on an infinite set, that is, it gives the conditions liminf λ_n/n ≥ s_+ and limsup λ_n/n ≤ s_-. The stated conclusion is "a schedule keeps the human only if λ_n/n eventually stays in [s_+, s_-]". That is a different statement.
* **The stated condition is necessary, but needs another argument.**
  * Take the alien π_+ that attains s_+, which exists by Proposition 4.3, and write λ_n/n = s_+ + ε_n. Then J(π_+) − J(π_H) = ε_n n Δ − W_n, where Δ is π_+'s extra length and W_n is a centred random walk.
  * If ε_n < 0 for infinitely many n, then π_+ beats the human infinitely often:
    * trivially if W has zero variance;
    * otherwise because the event {W_n > ε_n n Δ for infinitely many such n} is exchangeable and has probability at least liminf P(W_n > 0) = 1/2, hence probability 1 by the Hewitt–Savage 0–1 law.
  * The upper end is symmetric.
  * The proof in the notes does not contain this argument.
* **The stated condition is not sufficient.** rb4(B): the human H(3/16) against the full memoriser (the rate maximiser), 400 runs, exact through the binomial count of coin-1 queries, checkpoints up to n = 10^8.

  | λ_n/n − s_+ | position of λ_n/n | memoriser beats the human (average over checkpoints in [10^6, 10^8]) |
  |---|---|---|
  | n^-0.3 | inside the window from n ≥ 125,893 | 0.000 |
  | n^-0.9 | inside the window for every n ≥ 51 | 0.485 |
  | 0 | at s_+ | 0.499 |
  | −n^-0.9 | below s_+ for every n | 0.514; the human wins at some late checkpoint in 0.948 of the runs |

**Corollary 4.8** excludes c = s_±, and rightly. In exact enumeration (rb4(A)) the human is among the MAPs with probability 0.496 at c = s_+ and 0.499 at c = s_-, at n = 512. It is not driven to 0 or to 1.

**Requested change.**
* State what is proved (the liminf/limsup form).
* Either add the recurrence argument or drop "eventually stays".
* By the law of the iterated logarithm, a sufficient condition for i.i.d. samples is (λ_n/n − s_+) n / √(n log log n) → ∞, with the symmetric condition at s_-. This assumes the confinement of `prop:recovery:beyond`(c), which leaves finitely many competing programs.

### B6. Corollary 4.8 is stated for "any countable Kraft class containing π_H" [scope]

Conclusions (i)–(iv) come from Lemma 4.5, which needs two things:
* Lemma 4.4, for which Q must be lower semicomputable from π;
* (F1).

Both hold for H_× and for any class in the sense of `def:setup:class` (c.e., uniformly lsc). They do not hold for an arbitrary countable Kraft class, such as one with non-computable kernels. The left condition must also be verified in that class.

**Requested change.** "Any hypothesis class (`def:setup:class`) containing π_H in which (L_{t,c,0}) holds."

### B7. Summary sentences that drop offsets [scope; rb2(B), r6(C)]

* **§0 item 3, "its advantage per bit is at most the reuse factor 2^-m".**
  * Lemma 4.5 gives r(π) ≤ 2^-m + G_t/(2^m x) for an alien x bits longer than the human.
  * For aliens a few bits longer, the bound is weak.
  * Requested change: add the offset term.
* **"An offset of order m + δ_β".**
  * G_t = t + δ_β + |B| log(2^m + 1) + 2 log(m + 1) + (ℓ_H − K(h*)) + κ, which is of order |B| m + t + δ_β.
  * Requested change: say so.
* **"In an explicit class … its lower end is 2^-m(1 − o(1))" (§0 item 3).**
  * This is specific to r2's class. In r2's class the memoriser pays a rate code and γ(t).
  * In rb2(B) the deterministic full memoriser needs no rate code. The lower end is then 1.023 · 2^-m.
  * The prover's own r6(C) prints 1.0105 · 2^-m for ρ = (1/2, 1/4, 1/4).
  * The general form is 2^-m(1 ± o(1)), with the sign set by the code.
  * Theorem 4.6 is unaffected: it claims nothing between 2^-m and the memoriser's rate.

### B8. Remark 4.12 (several environments) is marked "proved"; it is a sketch [gap; numbers confirmed by rb3(B)]

The argument uses "about" and (1 ± o(1)). It also needs two conditions it does not state:
* the left condition in W_E;
* that, in W″, the program "h* plus β" is not beaten by a shorter program at the relevant c.

The numbers support it. With 2^m = 256 cells per environment and s0 = 16:

| E | largest alien rate in W_E | shared memoriser in W″ |
|---|---|---|
| 1 | 0.899 · 2^-m | 0.928 · 2^-m |
| 2 | 0.457 · 2^-m | 0.928 · 2^-m |
| 4 | 0.229 · 2^-m | 0.928 · 2^-m |
| 8 | 0.115 · 2^-m | 0.928 · 2^-m |

A set shared across environments has rate below 7.4 · 10^-4 in W_E for every E ≥ 2.

**Requested change.** Mark the remark as a sketch, or state the conditions.

### B9. Code: ceil of a floating-point lgamma gives a code length one bit too long [bug: rb6(B)]

**Where.** r2, r3 and r4 compute ⌈log₂ C(N, t)⌉ as `ceil` of an lgamma difference.

**What goes wrong.** When C(N, t) is a power of two, the float exceeds the integer by about 10^-12, and the length is one bit too long. That happens at t = 1 or t = N − 1 with N a power of two, which covers N = 16, 256 and 1024. For example, the t = 1 alien of r4(B) has length 13 instead of 12.

**Effect.**
* The Kraft sums are only made smaller, so the classes remain valid.
* No window changes, because s_+ is attained by the full memoriser in every case.
* Some small-n entries of r4(B) change. With exact lengths:

  | c | n | prover's value | exact value |
  |---|---|---|---|
  | 1.05 s_+ | 64 | human 0.5891 | human 0.5797 |
  | geometric middle | 16 | H(other q) 0.3108, coin 0.1302 | H(other q) 0.2626, coin 0.1168, t = 1 alien 0.0616 |
  | geometric middle | 64 | human 0.9025 | human 0.9024 |
  | 0.03 | 64 | human 0.0058 | human 0.0040 |

* The values quoted in the notes are unchanged at the precision quoted: 0.559, 0.903, 0.9955 and 1.0000 at the middle; 0.816 at n = 1024; and the memoriser's 0.964.
* My rb6 reproduces r4(B)'s printed table exactly with the prover's lengths, which also confirms that I re-implemented it correctly.

**Fix.** Use exact integers, for example `(comb(N, t) - 1).bit_length()`.

**Cosmetic.** r4(B)'s docstrings say "the four S-cells" and "k1 ≥ k2 ≥ k3 ≥ k4", but |S| = 2.

### B10. Two "computed" statuses rest on identities [scope]

* **Example 3.2, "[computed: r4(A)]".** The script asserts equality of two expressions that are identical on the support. The lengths 40 and 20 are assigned. The example is correct, but it is an illustration, not a computation. Status should be [example].
* **r1(A), "no program's gain ever exceeded its length plus δ\*".**
  * This holds pathwise by the definition of δ* from the same mixture. My rb1 finds the same identity, with margin −0.142 on every path.
  * The evidence for Lemma 2.1 is the tail of δ*, which should be compared with the sharper M_0 2^-j (§1).

### B11. Wording

* **§0 item 1, on Proposition 2.3(b).** "Every λ_n = o(n) eventually selects it." Proposition 2.3(b) shows only that every copy of the human is eventually rejected, not that π* is selected. In r1(B) a second alien also gains linearly: the history-aware KT learner gains 1414–1425 bits by n = 2000, against 1665–1676 for π*. Which alien is selected is not settled by 2.3(b).
* **The refuted "(a)-brief" row.** The learner of Proposition 5.2 is ν_H-equivalent on the run, which is Theorem 2.2(4)'s conclusion. What fails is "is a copy", not "is eventually equivalent in law" in the weak sense. Say which.
* **Lemma 4.4.** The K(m) term is unnecessary, since m is computable from h* (μ(·|·) is indexed by {0,1}^m). Also δ_β ≥ −1 − κ, not merely ≥ −2 log(m+1) − κ, because the index in the type class has a length that is computable from h*. Both are harmless.

---

## 4. Independent checks of the claims, and counterexample searches that found nothing

| claim (notes) | my check | result |
|---|---|---|
| Lemma 2.1, Ville with side information | rb1(P): exact enumeration of all 524,288 paths (n = 6, plus the next environment value), with 9 predictors, M_0 = 0.84375. They include product kernels on (x, z), a KT learner, a predictor that reads the *future* environment value z_{i+1}, a momentum predictor, a fill-in, and a Bayes mixture over 25 humans | E[M_n] = 0.843750 at every n (a martingale); max_a a·P[sup M ≥ a]/M_0 = 0.460 ≤ 1 **[confirmed]** |
| (Priv) is the right condition, Proposition 2.3 | rb1(L): a variable u_i equal to y_i with probability 0.8 is visible to one predictor. rb1(X): y = x XOR z, with z independent of y and x independent of y | (L): E[M_n] = 0.929, 0.959, 1.001, 1.058 > M_0; in simulation, P[δ* ≥ 64] = 0.875 at n = 1000. (X): gain n log₂ 1.98 − 4, deterministically. So independence of the coin from each variable separately is not enough, as (Priv) states **[confirmed]** |
| Theorem 2.2(1), fill-in length ≥ L_n(ν_H) − δ* | rb1(P), pathwise on the 1.56% of paths where the fill-in is consistent | minimum slack 0.936 ≥ 0 **[confirmed]**; an identity given δ* |
| Lemma 4.4, semimeasure and Jensen steps | rb2(A): a latent cause; 16 cells; ρ = (3/4, 1/4); Y = {0, …, 3}; h(x, b) = (g(x) + 2b) mod 4; 2000 random programs (sub-probabilities, zeros); brute-force mass of Q over all 2^16 couplings; 3000 adversarial programs near the human | max Σ_b q_w(b) = 0.979; Jensen gap ≤ −0.337 for random programs and → 0⁻ near the human; tight at the human (q_w = ρ) **[confirmed]** |
| Lemma 4.5 and Theorem 4.6, "robust against every alien that knows the model" | rb2(B), a machine-free analogue, all C(32,4) = 35,960 couplings (m = 5, p = 1/8). 7144 structured sets (subcubes, cyclic intervals, affine subspaces of codimension 1–3, 256 dictionary sets, PRG outputs with 4-, 8- and 12-bit seeds) plus all T-memorisers, each deterministic or with two rates; extra-part Kraft sum 0.408 | the class deficiency D(β) := L_β − min_π[extra + 2^m R_β] obeys P[D ≥ j] ≤ Kraft · 2^-j at every j (P[D ≥ 0] = 0.0174, P[D ≥ 2] = 0.0098, P[D ≥ 4] = 0.00045, P[D ≥ 6] = 0) **[confirmed]**. Window (1.023, 1.328) · 2^-m for typical couplings; **empty for 12.3% of couplings, all of them structured**: PRG 12-bit 3802, PRG 8-bit 251, PRG 4-bit 16, dictionary 256, subcube 80, interval 23. None is a "typical" coupling |
| Proposition 4.9(c), cheap couplings close the window | rb2(C), couplings produced by the PRG | seed 4 bits: s_+ = 8.70 · 2^-m; 8 bits: 2.90 · 2^-m; 12 bits: 1.74 · 2^-m; all above s_- = 1.33 · 2^-m **[confirmed]** |
| Proposition 4.9(d), a window needs 2^m ≳ (ℓ_H − ℓ_u)/(log\|Y\| − H(ρ)) | rb2(B): the human's model costs L_G = 6, 8, 9 or 10 bits, so (ℓ_H − ℓ_coin)/(1 − H(1/8)) = 24.1, 28.5, 30.7 or 32.9, against 2^m = 32 | the fraction of couplings with an empty window is 0.123, 0.152, 0.152, then **1.000** at L_G = 10, exactly where the quantity passes 2^m, as (d) predicts **[confirmed]** |
| Proposition 4.3 and Corollary 4.8, the window from samples | rb4(A): a new class (16 cells, \|S\| = 3, exact integer code lengths), exact enumeration of count vectors; window (0.0464, 0.0760) | inside the window, P[human] at n = 512: 0.80 (1.05 s_+), 0.93 (middle), 0.63 (0.95 s_-), and rising. Below: the full memoriser with probability 1.000 from n = 256. Above: the coin with 1.000 at n = 512 **[confirmed]**. At the ends see B5 |
| Remark 4.11, partially private coins | rb3(C): four new instances (m = 8 or 11) | s_+ · 2^m = 0.585, 0.529, 0.785, 0.387, against the full-knowledge rates 0.698, 0.597, 0.808, 0.394: below them, as the notes say **[confirmed]** |
| Remark 3.4, per-query bound | rb6(A): exact by inclusion–exclusion with rationals | exact/union bound = 0.973 (n = 10), 0.9986 (50), 0.999992 (100), 1.000000 (200, 400): the bound is essentially tight **[confirmed]** |
| Proposition 5.1, Ville on one hidden-Markov trajectory | rb5(C): 4000 runs of n = 300; 343 HMMs, a mixture, 15 memoryless samplers and a coin; M_0 = 0.255 | P[δ* ≥ j] = 0.105, 0.054, 0.025, 0.0145, 0.0032 for j = 1, 2, 3, 4, 6, each below M_0 2^-j **[confirmed]** |
| Proposition 5.2, the learner absorbs | rb5(A), in the i.i.d. setting | see B3 **[confirmed, and extended]** |

**Searches for counterexamples that found none.** For each I list what I tried and what I expected to see.
* **Lemma 2.1.** I let predictors read the next environment value, the history, and a mixture over humans, and enumerated every path. A failure would show as an increase of E[M_n]. None appeared.
* **Lemma 4.4.** I searched adversarially near the human, where Jensen's inequality is closest to equality. The gap approached 0 from below and never crossed it.
* **Lemma 4.5, explicit form.** I gave the aliens every cheap description of a 4-subset of 32 cells that I could code: subcubes, intervals, affine subspaces, a dictionary, and PRGs. A family can beat the line only on the couplings it describes cheaply, and the fraction of such couplings obeys the Kraft bound exactly.
* **Covering-code aliens**, which declare a superset T ⊇ S with rate s0/|T| on T, are a natural candidate for beating the memoriser's rate. Each T of size t covers C(t, s0) of the C(N, s0) possible S, so their extra length is at least log C(N, s0) − log C(t, s0); a covering design comes within log(1 + ln C(t, s0)) bits of this. Even with the lower bound as length, and the overheads of r2's class, their rate at N = 1024, s0 = 64 stays below the full memoriser's 0.973 · 2^-m for every t tried (65, 80, 96, 128, 192, 256, 512): it is at most 0.954 · 2^-m (t = 65) and falls with t (0.914 at t = 128, 0.729 at t = 512). This is a one-line computation, not a saved script.
* **Hedged aliens**, which predict coin 1 with probability 1 − η on T, are dominated in deterministic worlds. In rb2(B) the rated versions never set s_+.

---

## 5. Evidence on the open questions

* **Open question 2, non-uniform cell masses** [evidence: rb3(A)]. Setting: N = 1024; masses ∝ k^-a; a random S with s0 = 64; the human's rate calibrated to mass(S); T-memorisers keep the heaviest S-cells.
  * The lower end s_+ is set by memorising one or two of the heaviest coin-1 cells (t* = 1 or 2).
  * s_+/(largest S-cell mass) = 0.31–0.50 in all 15 non-uniform draws. Roughly, s_+ ≈ π_max^S log₂(1/p)/log₂ N.
  * Relative to 2^-m, s_+ reaches 5.0 · 2^-m at a = 0.5, 14.4 · 2^-m at a = 1, and 2.9 · 2^-m at a = 1.5.
  * The windows still exist in all draws, because s_- ≈ 0.1.
  * This supports the notes' conjecture ("the largest cell mass, possibly up to logarithmic factors"). The relevant mass is the largest among the *coin-1* cells.
* **Remark 5.4(3), one trajectory without a dominating member** [evidence: rb5(B)]. Setting: 343 HMMs (length 20), 15 memoryless samplers (length 12), a coin (length 2), λ = 2, human θ* = (1/8, 7/8, stay 7/8).
  * In 10 of 10 runs the λ-MAP is θ* or its mirror image at every checkpoint from n = 1000 to n = 20,000.
  * The coin is the MAP at n = 100, as expected.
  * This is consistent with the notes' expectation, which they draw by analogy with maximum-likelihood consistency for hidden Markov models.

---

## 6. Assessment against the target I1

**What is established, in my reading.**
1. **Private coins.** Lemma 2.1 is clean, fully general over predictors, and correct. With Theorem 2.2 in the product class, the "ideal theorem" holds in the sense the author asked for, against every program. No alien predicts better in population, and luck on a sample is paid for in length.
2. **Environment-driven coins, feature case.** Lemma 4.5 is the real robustness result: a counting/information bound that holds whatever an alien's internal structure. Theorem 4.6 turns it into a window, given the left condition. My rb2 shows this mechanism exactly in a finite class. Robustness holds for all but a Kraft · 2^-j fraction of couplings, and fails exactly on the couplings that have short descriptions. This is the toy instance of "we robustly pick out the sampler anyway" that the author hoped for, with an honest exception set.
3. **Necessity.** Proposition 4.9(a) is correct for the twin with the same data law. Proposition 4.9(c),(d) give real limits.

**What must be said more carefully.**
* **B1.** The latent-cause reading needs the conditioning repair.
* **B2.** The obstruction from data alone is the single twin with kernel P*, not "aliens with large advantage per bit". Rate is the right quantity only for penalised-likelihood procedures. The brief asked for lower bounds showing that no procedure can robustly pick the human against aliens with a large advantage per bit. The notes do not prove such a rate-based lower bound for general procedures, and rb4(C) shows that none can hold in that generality.
* **B3.** The exclusion of in-context learners is a choice of hypothesis class.
* These three points belong in the caveats of target I3 alongside the notes' own list in §6.2. That list is otherwise accurate, and I agree with it item by item.

---

## 7. Claims table: referee B's verdicts

| notes claim | verdict |
|---|---|
| 2.1 Ville with side information | confirmed (rb1, exact; rb5(C)) |
| 2.2(1)–(4) | confirmed (proof re-derived; (1) pathwise in rb1) |
| 2.3 privacy dichotomy | confirmed (rb1 L, X); summary wording B11 |
| (a)-brief refuted for classes with a learner | confirmed and extended to i.i.d. private coins (rb5(A)); nuance B11 |
| 2.4 two halves | confirmed |
| 3.1, 3.3 | confirmed (elementary) |
| 3.2 Example | correct; status should be [example] (B10) |
| 3.4 partial fill-ins | confirmed exactly (rb6(A)) |
| 4.2 | confirmed |
| 4.3 window as rate condition | confirmed (rb4(A)) |
| 4.4 alien coding lemma | confirmed (rb2(A); proof re-derived); minor slack B11 |
| 4.5 right line of slope 2^-m | proof re-derived; class analogue confirmed (rb2(B)); summary B7; latent reading B1 |
| 4.6(i)–(v) | correct as an assembly; latent reading **B1**; "a few bits longer" means G_t/(c2^m − 1) bits |
| 4.6(vi) | confirmed; the lower end can sit on either side of 2^-m in explicit classes (B7) |
| 4.6-strong refuted | agreed |
| 4.7(a) | formally correct; reading **B4**; B1 |
| 4.7(b) | agreed (Paper 2) |
| 4.8 | confirmed (rb4(A)); class scope B6; ends B5 |
| 4.9(a) | confirmed; **slogan refuted (B2, rb4(C))** |
| 4.9(b) | **gap at the boundary; condition not sufficient (B5, rb4(B))** |
| 4.9(c),(d) | confirmed (rb2(B),(C)) |
| 4.10 | confirmed; "1 − o(1)" is class-specific (B7); length bug B9 does not affect it |
| 4.11 | confirmed (rb3(C)) |
| 4.12 | numbers confirmed (rb3(B)); a sketch, not a proof (B8) |
| 5.1–5.3 | confirmed |
| 5.4(3) open | evidence for the expected answer (rb5(B)) |
| §6.1 item 1 | **needs rephrasing (B3)** |
| §6.1 item 3, "coin-flipping human, unconditionally" | **needs rephrasing (B4)**; latent-cause cover B1 |
| §6.2 item 2 | **needs restricting (B2)** |

---

## Verification log

*Run 2026-10-14 with Python 3.11.15 and NumPy 2.4.6. Every script is in `referee_code/`, and each output is the `.out` file of the same name.*

| script | method | time | what it checks |
|---|---|---|---|
| `rb1_ville_exact` | exact enumeration; (L′) seeded 101 | 8 s (first run) | Lemma 2.1, Theorem 2.2(1), Proposition 2.3: worlds P, L, L′, X |
| `rb2_coding_all_couplings` | seeds 202 and 203; sha256 PRG | 26 s | Lemma 4.4 (A); the class analogue of Lemma 4.5 over all 35,960 couplings (B); Proposition 4.9(c),(d) (C) |
| `rb3_windows_population` | seed 303 | 4 s | non-uniform cells (A); several environments (B); partially private coins (C) |
| `rb4_finite_n_schedules_twins` | (A) exact; (B) seed 404; (C) seed 405 | 145 s | Corollary 4.8 and the ends of the window (A); Proposition 4.9(b) at the boundary (B); the twin slogan (C) |
| `rb5_learners_latent` | seeds 505, 506, 507 | 70 s | Proposition 5.2 with i.i.d. private coins (A); Remark 5.4(3) (B); Proposition 5.1 tails (C) |
| `rb6_misc_exact` | exact rationals and integers | 5 s | Remark 3.4 exactly (A); the code-length bug and its effect on r4(B) (B) |

**Internal assertions.** Each script checks its own claims as it runs:
* rb1: E[M_n] ≤ M_0, and the Ville ratio ≤ 1.
* rb2: Kraft ≤ 1, and P[D ≥ j] ≤ Kraft · 2^-j for j from −10 to 13.
* rb1, rb4: the enumerated path or count-vector probabilities sum to 1.000000.
* rb6: its prover-length rows reproduce r4(B)'s printed table exactly.

**Reproducibility.**
* *My scripts.* All six were copied to a scratch directory and re-run with `python3 -I`.
  * Every output is **byte-identical** to the saved one, and stderr is empty.
  * Re-run times: rb1 10 s, rb2 32 s, rb3 4 s, rb4 185 s, rb5 71 s, rb6 23 s.
  * rb2 was then extended with the Proposition 4.9(d) scan. It was run again in a fresh scratch directory, and is byte-identical to the saved output.
* *The prover's scripts.* They were re-run likewise and are byte-identical to the saved outputs (§1).

SHA-256 of the final referee scripts:

| script | SHA-256 |
|---|---|
| rb1 | `be79cc24034a38eaf6bfb8014d538b57aea2991372935df0d2e8cedf26b43337` |
| rb2 | `fcc620360285e434b4dfadf9eb3f3286e3700f3e1f6157bf7c12dea7f66b1da2` |
| rb3 | `f4452c3013129b6ddc9d8d25d14ca7bb238eb64c266f3afc312d3c3ba9f7787f` |
| rb4 | `299d072500976030ffd2e26c5e76db95ab9e35344ba708b456ddd23d620251b0` |
| rb5 | `ffa1c48f923c4ab6b5855deeaae96667546dcbd0141d889ba77787c3bb8d4391` |
| rb6 | `e924600d9c64c4cec9d68e27162f02a1066487d22c54a22c89bb2dc15ca42423` |

**Proof checks done by hand.**
* Lemma 2.1: measurability and the conditional expectation under a larger filtration.
* Lemma 4.4: injectivity, the semimeasure property, lower semicomputability and Jensen.
* Lemma 4.5: the chain (F4), (F3), (F1), and the type-class bound.
* Theorem 4.6: each hypothesis of `lem:kink:main` matched.
* Proposition 4.3.
* Proposition 4.9(a),(c),(d), and (b) up to the gap B5.
* Proposition 5.2, and the family-coding condition (λ − 1)ℓ_idx > λκ_U.
* Proposition 5.3: the backward induction.
* The repair in B1: the conditional symmetry of information and the conditional coding theorem. This was re-derived here, not taken from a source.

**Not checked.**
* Anything involving K directly, which is uncomputable. The explicit-class analogues stand in for it.
* The finite-sample route of open question 4.
* Paper 2's own lemmas, beyond reading their statements and proofs as used here.

