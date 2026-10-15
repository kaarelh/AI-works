# Sub-track "kink": adversarial referee A (proofs)

*Report on `notes.md` of this folder and its scripts `checks/k1`–`k5`. Written 2026-10-13.*

* **Read.**
  * The brief `../00-brief.md`.
  * Paper 2:
    * `setup.tex` and `app-setup.tex` (hull lemma, coding bound);
    * `split.tex` and `app-split.tex`;
    * `algstat.tex` and `app-algstat.tex`;
    * `teacher.tex` and `app-teacher.tex` (lemmas, the main theorem, the full table);
    * `computable.tex` and the (Dom) passages of `absorb.tex`.
  * `paper/NOTATION.md`, and Paper 1's `setting.tex` for the input set.
  * The sibling notes `../iid/notes.md` (Remark 1.4, §7.5) for the treatment of repeated inputs.
* **Code.**
  * All five scripts were re-run in a scratch directory. Each reproduced its saved output byte for byte.
  * My own probes are in `referee_code/rA_checks.py`, with output in `referee_code/rA_checks.out` (deterministic or seeded, Python 3.11.15).
  * Below, "rA(k)" means part (k) of that output.

**Status tags in this report.**
* **[proved]**: argued here in full.
* **[computed: rA(k)]**: checked by my script.
* **[checked]**: I re-derived the notes' proof line by line and found it correct.

---

## Verdict

**Accept after one major revision and several minor ones. No fatal issue.**

* **§2 and §3.** Every proof is correct. Two statements lack a hypothesis that the proof uses:
  * Thm 3.2(d) needs τ < σ.
  * The sentence after Prop 3.5 is false for λ ∈ (1, 1+ε).
* **§4.** Correct. One constant is rounded up (0.0188), and Prop 4.2's "range" is not proved to be an interval.
* **§5.**
  * The fixed-n results hold under the without-replacement scheme (wor): Lemmas 5.1–5.3, Thm 5.4, Cor 5.5, Thm 5.6 and Prop 5.8.
  * The i.i.d. scheme (iid) assumes a non-atomic input law μ. No such law exists on Paper 2's input set X = {0,1}*, which is countable. So (iid) is empty.
  * Cor 5.7 needs an infinite sample, which (wor) cannot give, so Cor 5.7 is vacuous as stated.
  * Its natural repair to atomic μ with frozen noise is false (Issue 1).
  * The repair is to state §5 for the per-query object, as the sibling iid sub-track does.

---

## Issues

### Major

**1. The (iid) scheme is empty, Cor 5.7 is vacuous, and its frozen-noise reading is false.**

*Where.*
* §0 item 4 (line 43).
* §5 "Setting", scheme (iid) (line 376).
* Cor 5.7 (line 449).
* Remark 5.9.
* §6 last bullet (line 506).
* §7 "New".
* Verification log, cross-check of Cor 5.7(c) (line 589).

*Problem.*
* Paper 2 fixes the input set as X = {0,1}* (`def:setup:data`). `NOTATION.md` §1 and Paper 1's `setting.tex` allow any infinite decidable X ⊆ {0,1}*. In every case X is countable.
* Every probability law on a countable set is purely atomic. So "i.i.d. from a non-atomic law μ on X" is never satisfied.
* Scheme (wor) has n ≤ |X₀| < ∞, so it has no infinite sample.
* Cor 5.7 ("Under (iid) with an infinite sample …") therefore has no instance. It is vacuously true.
* The following claims rest on it:
  * §0 "Every fixed λ > 1 eventually selects a shortest equivalent program";
  * §6 "Every fixed λ > 1 eventually lies inside it (Cor 5.7)";
  * §7's listing of Cor 5.7 as new;
  * the Verification-log claim that Cor 5.7(c) strengthens `thm:split:private`(iv) "under i.i.d. inputs".

  None of them has content as written.
* The proofs themselves are fine. If a non-atomic μ existed on a standard Borel X, with x ↦ ν_π(y|x) measurable for every π, each step would go through:
  * Borel–Cantelli with ε_n = n⁻²;
  * the all-n Ville bound;
  * the finitely many candidates below ℓ̄*.

  Neither condition is stated, and both lie outside the papers' framework.

*The natural repair fails* [proved; computed: rA(1)].
* Keep frozen noise (one label per distinct input, as in Paper 2's data sets) and let μ be atomic.
* Take the class of two programs of length 1 (Kraft sum 1):
  * π* is the fair coin, so ν = ν_{π*};
  * π′ is the fair coin except that it gives label 0 probability 1 at the heaviest atom x₁.
* π′ is not μ-a.e. equivalent: Hel_μ(π′) = μ(x₁)(1 − 1/√2) > 0.
* Almost surely x₁ appears, and its frozen label is 0 with probability 1/2. On that event, Λ_n(π′) = 2 from then on, so π′ is the unique λ-MAP for every λ and all large n.
* So Cor 5.7(c) fails with probability 1/2. The simulation gives 0.505 over 2000 runs of n = 4000.
* This is the two-program case of `../iid/notes.md` Prop 7.5 and Prop 7.6(d).

*Fix.* State §5 for the per-query object, as `../iid/notes.md` Remark 1.4 does.
* Draw (x_i, y_i) i.i.d. from μ ⊗ ν, with a fresh label at every query, repeats included.
* Let L^pq(π) := −Σ_{i≤n} log ν_π(y_i | x_i). This is π's term in Paper 1's M_pq, or π's product law on the stamped data set with a stamp-ignoring program.
* Then every step of §5 goes through verbatim. With computed: rA(1)(b):
  * *Lemma 5.1.* E[√Λ_n | x_{1:n}] = ∏_i a(x_i), with repeats included, and E ∏_i a(x_i) = (E_μ a)ⁿ.
  * *Lemma 5.2.* Unchanged.
  * *Lemma 5.3 and its all-n form.* This is `../iid/notes.md` Lemma 2.2: the one-step supermartingale inequality holds at repeated inputs, because the per-query mixture is a product mixture.
  * *Equivalence.* "μ-a.e. equivalent" means equal on every atom, so equivalent programs have L^pq(π) = L^pq(π*) surely on the support.
  * *Cor 5.7.* It holds as stated, with D_n replaced by the query sequence. The counterexample above dies at the first label 1 at x₁.
* §2–§3 apply because they concern any point family. But the "structure function" is then that of the point set {(ℓ(π), L^pq(π))}, not ρ^×_D of a Paper 2 data set. Say so in §0 item 4 and in §6.
* Keep (wor) for the fixed-n statements. It is the frozen scheme on a finite domain.
* Replace (iid) by "per-query i.i.d. (repeats allowed)". Mention non-atomic μ only as a remark: it needs an uncountable standard Borel X and measurable ν_π, outside both papers.
* For frozen noise on an atomic μ, state that a.s. identification is not available: only "equivalent on the run" survives, by `thm:split:private`(iv) and `../iid/notes.md` Prop 7.6. Cite the two-program counterexample.
* Correct the Verification-log cross-check and the §7 entry accordingly.

### Minor

**2. Thm 3.2(d), forward direction, needs τ < σ. So does §0 item 2's "zero-window kinks at one point are exactly the hull vertices."**
* Def 3.1 does not require τ < σ.
* *Counterexample* [computed: rA(2)].
  * Take the points (0,2), (1,1), (2,0).
  * The middle point is a zero-window kink with σ = τ = 1.
  * It is a MAP point only at λ = 1, together with both ends, so it is not a vertex.
* The proof uses "the MAP point is the same on an open interval", and with τ ≥ σ that interval (τ, σ) is empty.
* *Fix.* Add "with τ < σ" to (d) and to §0 item 2.
* Also allow σ = +∞ in Def 3.1. The converse in (d) uses σ₀ = +∞ at the first vertex, and Thm 3.4 allows σ = ∞.

**3. The sentence after Prop 3.5 (line 208) cites the wrong result, and its claim is false for λ ∈ (1, 1+ε).**
* The text says: "By Cor 3.3(b), λ-MAPs for λ > 1 stay below that length", namely ℓ_U + (ℓ_U+κ₀)/ε.
* Cor 3.3(b) gives lower bounds on MAP length, not upper bounds.
* The correct upper bound is the absorption bound (λℓ_U + κ₀)/(λ−1) of `thm:absorb:absorption`(a). It is a right kink of flatness τ at π_U, Cor 3.3(a)'s argument with the class's best two-part code in place of K. It is at most ℓ_U + (ℓ_U+κ₀)/ε only for λ ≥ 1+ε.
* *Counterexample* [computed: rA(3)].
  * Take U = (2, 15) and A = (5, 10). (Dom) holds with κ₀ = 0, and with ε = 1 the stated cap is 4.
  * At λ = 3/2, J(U) = 18 and J(A) = 17.5, so the MAP has length 5.
* The first sentence of that paragraph also needs Prop 3.5's hypothesis α₀ − w > ℓ_U ("kinks … with α₀ − w > ℓ_U").
* *Fix.* "For λ ≥ 1+ε, every λ-MAP has length at most ℓ_U + (ℓ_U+κ₀)/ε, by `thm:absorb:absorption`(a)."

**4. The constant 0.0188 in Cor 4.3, §4(d) and §0 item 3 is rounded up.**
* f₂(1/4) − H(1/4) = 0.0187969 [computed: rA(4)]. The minimum over (0, 1/4] is attained at p = 1/4.
* The cell bound of k4(d) is 0.0187953. k4 prints it with `{:+.5f}`, as +0.01880.
* So "≥ 0.0188" is false in the fourth significant digit. Only positivity is used, so no conclusion changes.
* *Fix.*
  * Write "≥ 0.0187".
  * In k4, print lower bounds rounded down (for example `math.floor(x*1e5)/1e5`).

**5. Cor 3.3's hypothesis "a data-set class whose programs satisfy (F1)" is not what the coding bound needs.**
* `lem:setup:coding` needs P_π to be lsc uniformly in π, so that (F2) applies with one fixed program. A hypothesis class in the sense of `def:setup:class` provides this: c.e., prefix-free, uniformly lsc.
* (F1) alone does not. A countable class whose program "0" carries the deterministic table of an incompressible string has ℓ + L = 1, far below K(y_D | dom D).
* *Fix.* "Work in a hypothesis class (`def:setup:class`) of data-set hypotheses." Make the same change in §1 "Sufficiency".

**6. Prop 4.2: the class must contain a good model, and the "λ-range" is not proved to be an interval.**
* (a) "any c.e. prefix-free product class (with its own constants)": the proof uses π_g in two places:
  * b₀-sufficiency, for the upper length bound;
  * J_λ(π_g), for the level exclusion.
  * A class without a short good model has no b₀. *Fix:* require, as `prop:related:computable`(a) does, that the class contains a good model π′_g, with κ_g := ℓ(π′_g) − d.
* (b) C_{t₀}(λ) has λ on both sides: Ψ_t(λ) depends on λ through the budget ℓ̄_λ.
  * Ψ_t is nondecreasing in λ but a step function, so the set {λ : C_{t₀}(λ)} need not be an interval.
  * k4 reports it as an interval after checking a grid of 4 points per decade.
  * A finer scan (6000 points) of five instances, using k4's own code, found a single interval each time [computed: rA(6)]. So the reported numbers stand.
  * *Fix:* replace "the range" by a statement that is an interval by construction. If λ_hi(κ_g + min{d, s(t+1)+Λ₁}) < N(Ψ_t(λ_lo) − H(p)) for t₀ ≤ t ≤ max(t₀,T), then C_{t₀}(λ) holds for every λ ∈ [λ_lo, λ_hi], by monotonicity of Ψ_t.
  * Also drop "of the form λ < σ" in §0 item 3, or say "of the form λ < σ(λ), with σ nondecreasing in λ".
* (c) §0 item 3 quotes 9.98·10⁶ against 9.79·10⁶ at d = 30. That is the range with the G floors only. With Prop 4.2's own Ψ, the range is 1.0048·10⁷ (k4(a)). Say which is meant.

**7. Several §0 summaries are stronger than the theorems they summarise.**
* *Item 2 (Thm 3.2).* "two-part length ≤ α₋ + L₋ + (λ−1)w₋" holds for λ ≥ 1. The theorem says so; the summary drops it.
* *Item 4 (Thm 5.4), steepness bound.* "steepness at least (2 log e·nγ₋ − 2 log(1/ε))/ℓ₀" needs A := 2 log e·nγ₋ − 2 log(1/ε) ≥ 2ℓ₀, as Thm 5.4(i) states.
  * Without it the profile minimum can be far smaller.
  * Example [computed: rA(5)]: ℓ₀ = 10 and A = 10 give −8, against the formula's 1.
* *Item 4, right kink.* "a right kink of flatness 1 with window (ℓ₀ + log(1/ε))/(τ−1) for every τ > 1" should read "flatness τ".

**8. The remark after Prop 5.8 (line 471) claims more than Prop 5.8 shows.**
* The remark says: "so the order λℓ₀/γ in Cor 5.5 cannot be improved beyond constants and the dependence on ℓ̄_λ".
* What Prop 5.8 shows is narrower:
  * Prop 5.8 bounds the sample size below by about λΔ/K̄ for one shorter competitor at distance Δ.
  * Cor 5.5's sufficient size is about (λℓ₀ + (2−λ)⁺ℓ̄_λ)/γ_{ℓ̄_λ}, where γ_{ℓ̄_λ} is a minimum over all programs up to ℓ̄_λ, longer ones included.
* The two match only on instances with Δ ≍ ℓ₀ and K̄ ≍ γ_{ℓ̄_λ}, and with bounded likelihood ratios. The comparison constants for the last are marked unverified.
* *Fix.* Mark the sentence [proof sketch] and restrict it: "on instances where the closest competitor is a shorter program with Δ ≍ ℓ₀ and K̄ ≍ γ, the dependence on λΔ/γ is necessary up to the KL/Hellinger ratio."
* Prop 5.8 itself is correct. The exact binomial check found no violation in 540 cases [computed: rA(8)].

**9. Reporting of k3's numbers in §5 (lines 444–445) omits λ = 1.5.**
* With γ = γ₀, the near/far guarantee at λ = 1.5 is negative (W_near = 1.47), so Thm 5.6 is vacuous there.
* With γ = 10⁻³ it is 0.789, outside the quoted "0.87–0.90".
* *Fix.* Add the λ = 1.5 entries, or say that the ranges are for λ ∈ {2, 4, 8}.

**10. Status and notation details.**
* *Lemma 5.1 (wor).* Hoeffding (1963) Thm 4 is cited as known without saying whether it was checked against the source. The convention asks for "(unverified)" otherwise.
  * The inequality used, E ∏ a(x_i) without replacement ≤ (mean a)ⁿ, holds in 1340 exactly enumerated cases, zeros of a included [computed: rA(7)].
* *Lemma 5.3, all-n form.* `lem:split:ville` gives L(π) ≥ L₀ − ℓ(π) − δ*, non-strict, not ">".
* *Overloaded symbols.*
  * α₀ is the least length with finite fit (§1), and also a generic kink point (Def 3.1, Thm 3.2(d), Prop 3.5).
  * (ℓ₀, L₀) is a sufficient program in Cor 3.3, and the shortest equivalent program with L₀ = −log ν(D_n) in §5.
  * Rename the generic ones, for example (α_k, L_k).
* *The remark after Def 3.1.* "implies a left kink of steepness σ − b₁/w with window w, for every w > 0" needs b₁ ≥ 0 and σ − b₁/w > 0.

---

## What was checked and found correct

Each proof below was re-derived line by line [checked], unless marked otherwise.

* **Thm 2.1.** Checked:
  * attainment of the suprema;
  * slopes bounded by ρ_i because lengths are integers;
  * the induction ρ_i = ρ_D(α_i);
  * strict decrease, with the equality case through maximality of α_i;
  * σ_i → 0 from Σσ_i(α_i − α_{i−1}) ≤ ρ₀ with L ≥ 0, which holds because ν_π(D) ≤ 1;
  * P = ρ̆_D, including the region beyond α_q and the region left of α₀;
  * the epigraph identity.
* **Thm 2.2 and Prop 2.3.** Checked:
  * the index i* = min{i : σ_{i+1} ≤ λ};
  * the argmin of φ;
  * the edge and tie description;
  * finiteness;
  * non-attainment of inf L for infinitely many vertices;
  * the Fenchel recovery, including α ≥ α_q (sup not attained) and α < α₀.
* **Remark 2.5, Thm 3.2(a)–(c), Cor 3.3, Thm 3.4, Prop 3.5.**
  * The arithmetic of every bound is correct.
  * In Thm 3.4 I checked:
    * the choice of i and j;
    * j ≥ i;
    * nonemptiness of (max(τ,σ_{i+1}), σ) and (τ, min(σ,σ_j));
    * the extremes;
    * the τ = 0, q = ∞ edge case.
  * An independent brute force with my own hull code (not k1's) agrees with Thm 3.4's extreme MAP lengths in 11,225 cases [computed: rA(9)].
* **Prop 4.1.**
  * Correct, including the level-∞ term. It is covered because t ranges over [1,∞] and Ψ°_t → Ψ°_∞.
  * The sign condition σ^{(t₀)} > 0 is needed, because it makes every numerator positive, and it is stated.
* **Prop 4.2.**
  * Correct (with Issue 6(a)), including:
    * the reduction to t ≤ max(t₀,T);
    * the use of the budget ℓ̄_λ + κ in the sharp floor, which is monotone in the budget;
    * the containment of the window (1, Nc_hi), which follows because s(t+1) ≤ 4(t+1).
  * The constants check out: b₀ against `prop:algstat:parity`(ii), and the two κ's in j.
* **Cor 4.3.**
  * The uniformity in t of F_t ≥ f_t − O(ε_d) holds.
  * The derivative bound for f₁ − H is correct.
  * The crossover 0.12331 is correct (f₁ − H = −5·10⁻⁶ there).
* **Prop 4.4.** Correct.
* **Lemmas 5.1–5.3, Thm 5.4, Cor 5.5, Thm 5.6, Prop 5.8.** Correct under (wor), and under the per-query object of Issue 1. Checked:
  * the Markov exponents (2^{a/2}·2^{−nHel log e} = ε2^{−ℓ});
  * the condition A ≥ 2ℓ₀ in Thm 5.4(i);
  * the strictness of the right secants beyond ℓ̄;
  * the Ville length bound ℓ < ℓ̄_λ;
  * the (2−λ)⁺ℓ̄_λ term;
  * the near/far split, with no near programs of length ≤ ℓ₀;
  * E X⁻ ≤ log e/e.

**The brief's checklist.**

| item | finding |
|---|---|
| hidden hypotheses | τ < σ in Thm 3.2(d) (Issue 2); uniform lsc for the coding bound (Issue 5); a good model in the class (Issue 6(a)) |
| quantifier order | Cor 5.7(c) is "a.s., for every λ > 1, from some n(λ, ω) on". The a.s. event does not depend on λ, so the order is right. Not uniform in λ, and not claimed to be. |
| measurability | trivial on a countable X; needed but unstated for a non-atomic μ (Issue 1) |
| semimeasure versus measure | Hel, KL ≥ 0 and E Λ ≤ 1 are handled correctly for defective ν_π. Defective programs are non-equivalent. |
| ties and non-uniqueness of MAPs | handled exactly by Thm 2.2(ii)–(iii). Cor 5.5 correctly says "every λ-MAP is *a* shortest equivalent program". |
| finitely many candidates | yes: at most 2^j programs of length j. In Cor 5.7(c), ℓ̄* is random but a.s. finite and independent of n. |
| μ-a.e. equivalent ⇒ equal likelihood | yes under (wor), where it means equal on X₀. Under frozen noise with atomic μ the theorem built on it fails (Issue 1). |
| Kraft sums | used only in §5, correctly. k3 does not print its class's Kraft sum. From k3's code lengths it is 0.2526 [computed: rA(10)]. |
| additive log terms | none dropped beyond κ (K(d) ≤ 2 log(d+1) + κ is written 2 log d + κ, which is absorbed) |
| repeated inputs on atomic μ | not handled (Issue 1) |

---

## Verification log

* **Environment.** Python 3.11.15, numpy 2.4.6, scipy 1.17.1, 2026-10-13.
* **Re-runs.** k1–k5 were copied to the scratch directory and re-run there (k1 42 s, k2 18 s, k3 43 s, k4 2 s, k5 12 s). All five outputs are byte-identical to the saved `.out` files.
* **`referee_code/rA_checks.py`** (output `rA_checks.out`, about 31 s). Seeded with `numpy.default_rng(7)`, `random.Random(7)` and `random.Random(11)`. Parts:
  * (1) frozen versus fresh noise on a geometric μ, in the two-program class: 2000 runs, n = 4000;
  * (2) the τ = σ kink;
  * (3) the shared-class configuration;
  * (4) the 0.0188 constant;
  * (5) the steepness example;
  * (6) the interval scans, executing k4's own definitions;
  * (7) exact enumeration for Lemma 5.1 (wor);
  * (8) exact binomial check of Prop 5.8;
  * (9) independent brute force for Thm 3.4;
  * (10) the Kraft sum of k3's class.
* **Not done.**
  * Hoeffding (1963) Thm 4 was not checked against the source.
  * I did not re-derive the paper's lemmas (`lem:teacher:list`, `lem:teacher:sharpfloor`, `lem:teacher:twopart`) beyond checking that they are used with their stated hypotheses.
* **Repository.** No git command was run. Files were written only in this sub-track folder: this report and `referee_code/`.
