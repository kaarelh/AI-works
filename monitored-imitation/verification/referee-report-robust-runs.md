# Referee report: *Which properties of the human's runs does chained imitation keep?*

I reviewed `robust-runs.md` at commit `a75822a4`; line numbers below refer to that version. I also reviewed `code/robust_runs.py` (which uses `code/property_rules.py`) and `results/robust_runs.out` / `results/robust_runs_summary.json` at the same commit. For background I read `note.md` §1 (setting, Remark 1.1, Lemma 1, Remark 1.2), §2 (Protocol CI, the first-divergence observation, Proposition 2), §3 (Theorem 3 and its proof) and §10 E2, and `without-a-check.md` §1–§5 ((S), Theorem 1, Lemma 2, (C_r), Proposition 4, the catch-up class, Lemma 5).

**What I ran.** Everything is in this folder.

* `referee3_rerun/`: a full re-run of `code/robust_runs.py`, unmodified, in 2 min 8 s. `robust_runs_summary.json` and `robust_runs.out` are byte-identical to `results/`.
* `referee3_e4_checks.py` → `referee3_e4_checks.out`, `referee3_e4_checks.json`, `referee3_e4_independent_seeds.json` (about 50 s):
  * (1) an independent per-human recomputation of every table entry, using the same seeds and RNG calls;
  * (2) explicit state sequences with notes, to check that the code's "wrong steps" are the decoder's replaced steps;
  * (3) Theorem 1's own quantity E Σ_t 1[B_t], and K(P);
  * (4) the per-step error at the stopping time;
  * (5) paired comparisons across n;
  * (6) the exact expected cost of the fragile target, by inclusion–exclusion;
  * (8) the same 40 humans with 10 fresh query seeds each (400 runs per n).
* `referee3_theory_checks.py` → `referee3_theory_checks.out` (about 15 s):
  * (1) the sharp form of Theorem 1 on random finite classes, with i.i.d. problems and with an adaptive adversary;
  * (2) a counterexample showing that the per-run posterior sampler of Proposition 2 does not satisfy Theorem 1;
  * (3) Proposition 2's second claim, by exact enumeration with adaptive queries, and what goes wrong when the test problem depends on the human;
  * (4) the slide-30 sentence;
  * (5) the fewest replaced steps that destroy "ends with the right insight" in the silent and catch-up hidden-insight classes, under arbitrary and under omission-only replacements.

**Overall.** The mathematics of §1–§2 is correct for the majority decoder. The Observation, Theorem 1 with its adaptive adversary and floor, the i.i.d. corollary and the graded version all check out. The note's problems are in what it says the theorem buys:

1. Under the note's own definition (a replaced step outputs an arbitrary state), no non-trivial property read from the final state is ρ-robust for any ρ ≥ 1/n. So "solves the problem", read the usual way, is fragile for every task (A1).
2. "Theorem 1 holds for every decoder" is false. It fails, by a factor of order n, for the per-run posterior sampler of Proposition 2, so no imitator in the note has both guarantees (A2).
3. The slide-30 sentence is wrong (A3).
4. The persistence paragraph inverts a conditional and adds nothing for robust properties (A5).
5. In E4, "the fragile property gets more expensive with n" is a seed artefact. By construction the fragile cost has the same expectation, about 852 queries, at n = 16, 64 and 256 (C1).

Every number in the note's table and text matches the saved outputs.

---

## Statements checked and found correct

* **Observation (l.57–61).** The decoder's run is the corrupted run whose pattern replaces exactly at M = {k : G_D(x′_k) ≠ P(x′_k)}, with output G_D(x′_k). That pattern depends only on the current state, so it is an admissible adaptive pattern. At every other step x′_{k+1} = P(x′_k).
  * The definition says nothing about whether a replaced output may equal P(x). That does not matter, because counts only go down.
  * In E2 I checked it on explicit states (c₀, j, notes). The number of k with x′_{k+1} ≠ P(x′_k) equals the code's count of steps at which an unknown rule fires in all 400 test runs (n = 16 and 64). Script `referee3_e4_checks.py` §2.
* **"The first note's Proposition 2 used only that a failed run has |M| ≥ 1"** (l.61). Correct: note.md l.137–139.
* **Definition of ρ-robust; closure under conjunction (l.65).** Correct.
  * They are in fact closed under arbitrary conjunctions *and* disjunctions. For a disjunction: if the human's run has Φ₁, every corrupted run has Φ₁.
  * Let Ψ_ρ = "at most ⌊ρn⌋ steps at which the run's next state differs from P(current state)". Ψ_ρ is ρ-robust and implies every ρ-robust property that the human's run has. Hence B_t ⇔ ¬Ψ_ρ(decoder's run) ⇔ |M_t| > ⌊ρn⌋, and "simultaneously for all ρ-robust properties" (l.21) is automatic. The note could say this (D2).
* **Theorem 1 and its proof (l.67–73), for the majority decoder.**
  * B_t is a function of (D_t, x₀ᵗ), and on B_t, |M_t| ≥ ⌊ρn⌋ + 1 > ρn. That uses the floor correctly: an integer greater than ⌊ρn⌋ is greater than ρn.
  * Given the past and x₀ᵗ, the uniform step k_t lands in M_t with probability |M_t|/n. Lemma 1 holds pathwise for adaptively and randomly chosen queries, so E Σ_t |M_t|/n = E #(mistake queries) ≤ ⌊K(P)⌋. The infinite sum is handled by Tonelli.
  * Adaptive problem choice by an adversary is covered, provided it does not see the coin of round t. note.md's Protocol CI says this; this note says only "seen the past" (D3).
  * The requirement that the human's run have Φ is handled consistently. The definition constrains only problems on which the human's run has Φ, and B_t counts only such properties.
  * The proof gives the sharper bound E Σ 1[B_t] ≤ n⌊K⌋/(⌊ρn⌋+1) ≤ K/ρ (A4).
  * Numerical check on random finite classes, with i.i.d. problems and with an adversary that picks, among bad runs, the one with the fewest mistakes: the largest ratio of observed to sharp bound is 0.069 (`referee3_theory_checks.out` §1).
* **The i.i.d. random-stopping claim (l.71).** Correct. With F_t = Pr_{x₀∼μ}[B(D_t, x₀)], we have E[1[B_t] | D_t] = F_t because x₀ᵗ is fresh. So E F_τ = (1/N) E Σ_{t≤N} 1[B_t] ≤ K/(ρN).
* **Graded version (l.75–77).** Correct. Its hypothesis is sufficient, and weaker than item 2's phrase "loses at most c/n per replaced step":
  * it only compares corrupted runs with the human's own run;
  * it needs c ≥ 0;
  * it holds whether "score lost" means S(human) − S(decoder) or its positive part;
  * the range [0, 1] is not used.
  * The indicator S = 1[Φ] of a ρ-robust Φ satisfies it with c = n/(⌊ρn⌋+1), which recovers the sharp form of Theorem 1.
* **Proposition 2, first claim (l.112–116).** Correct by definition of per-run posterior sampling.
* **Proposition 2, second claim, with adaptive queries.** Correct.
  * The query rule's probabilities, given the past transcript, do not depend on the hypothesis. So the likelihood of a transcript under ν is (a factor common to all ν) × 1[ν consistent], and the posterior is w restricted to H_D.
  * Exact enumeration, with 200 random classes, an entropy-maximising adaptive query rule and random Φ: the largest |Pr[imitator has Φ] − Pr[human has Φ]| is 1.1·10⁻¹⁶ (`referee3_theory_checks.out` §3).
  * It needs Φ and x₀ to be fixed independently of the human (B7).
* **Hidden-insight fragility (l.81, l.141).** Correct.
  * For silent humans one replaced step always destroys "ends with the right insight": replace step t_p by (p, t_p+1, ⊥).
  * The same is true for catch-up humans under arbitrary replacements: one step writing a wrong insight, or one replaced last step, is enough.
  * Brute force for n = 8: the fewest destructive replacements is 1 for every t (`referee3_theory_checks.out` §5).
* **Relation to (C_r) (l.82, l.9).** Correct.
  * Under (C_r), Lemma 2 of the second note puts a mistake among the last r steps: *where*. Robustness forces more than ⌊ρn⌋ mistakes: *how many*.
  * (C_r) quantifies over the decoder's states, so it is relative to the learner (without-a-check.md l.122). ρ-robustness quantifies over all patterns.
  * Plain CI exploits robustness, while (C_r) needs end-weighted queries to pay off. So "needs no change to the protocol" is right.
* **Lemma 1 citation (l.55).** Correct: at most ⌊K(P)⌋ queries ever land on a mistake, on every path.
* **E4 implementation (§5).** The code computes what the note says:
  * the exact failure fraction over all 4,096 problems of "more than ⌊ρn⌋ wrong steps";
  * chained imitation with one uniform-step query per run;
  * 40 humans per n, target 2%, cap 20,000, oracle first passage.
  * The decoder ("append the tokens of known rules") is the posterior-majority decoder of E2's product prior, because every unresolved property has prior probability 1/N_r < 1/2.
  * The failure probabilities are non-increasing in t, since the known rules only grow. So oracle first passage equals "stays below thereafter".
  * The ρ = 0 row reproduces E2's CI row (810, 843; note.md l.494).
* **All numbers in the table and in items 3 and §5** match `results/robust_runs_summary.json`:
  * 810.25 ± 67.27 (median 702.5);
  * 842.8 ± 89.9 (649);
  * 1,104.2 ± 106.5 (994.5);
  * 141.8 ± 10.6 (145.5);
  * 92.6 ± 7.5 (82);
  * 37.5 ± 2.75 (34.5);
  * 21.7 ± 1.65 (20.5);
  * 17.1 ± 1.37 (15).
  * Medians are rounded half up, and ± is the s.e.m. over 40 humans (D7). My independent recomputation matches to machine precision (`referee3_e4_checks.out` §1).
* **"At n = 16, 5% of a run is less than one step"** (l.29, l.135). Correct: ⌊0.8⌋ = 0. The ρ = 0.05 row at n = 16 is identical to the fragile row.
* **"Robust properties get cheaper as runs get longer, because the fraction of wrong steps concentrates"** (l.30, l.140). The direction is confirmed with 400 runs per n:
  * ρ = 0.2: 38.7 ± 1.0, 25.0 ± 0.6, 16.6 ± 0.4;
  * ρ = 0.05: 145.6 ± 3.8 at n = 64 and 93.3 ± 2.5 at n = 256.
  * The explanation fits. The mean per-step error at the stopping time rises towards ρ as n grows: 0.054, 0.081 and 0.118 for ρ = 0.2, and 0.011 and 0.020 for ρ = 0.05. See B8 for what this does and does not show.
* **"A failed run has a single mistake"** (l.139), for the rarest rules. Roughly right: a run in which a size-9 rule fires has 1.02, 1.06 and 1.27 such steps on average at n = 16, 64 and 256. But see C1.

---

## (A) Errors in statements or proofs

### A1. Under the note's definition, properties read from the final state are never ρ-robust for ρ ≥ 1/n

**Where.** Abstract (l.3: "'Is a nice run that solves the problem' is such a property for some tasks and not for others"); item 2 definition (l.20, "replaced by arbitrary outputs"); §1 (l.57); item 4 (l.32); §3 (l.86–102).

**Problem.** A replaced step outputs an arbitrary state. Take any property Φ(x₀, run) that depends on the final state x_n through a non-trivial test S. Replacing step n−1 by any x_n ∉ S destroys Φ with one replaced step. So no such Φ is ρ-robust for any ρ ≥ 1/n, for every task and every human. "Solves the problem", read off the final draft, is fragile in the note's own model.

The append-only scaffold of §3 does not rescue it either. That scaffold is not in the formal model (see the fix below). A replaced step in the last ⌊ρn⌋ positions can append a plausible but wrong conclusion ("Correction: the answer is 7"). That is kind (c), adversarially placed where no later work can catch it. The table's own criterion for (c), "only if later work catches it", fails there by construction. So under adversarial placement and arbitrary content, the robust properties are essentially:

* counting properties like Ψ_ρ;
* properties that are monotone under appends, such as "the log contains a correct solution somewhere". These are useful only to a reader who can tell the human's content from replaced content, which is a check, and this note excludes checks.

The note treats the placement problem as uncertain ("the part I cannot vouch for"). For the final steps it is not uncertain: it is a counterexample. Consequences:

* the abstract's existence claim ("for some tasks") is unsupported;
* item 4's claim that the question is "now" about the human alone loses most of its force, since the useful version is the restricted robustness of the Remark at l.80, which depends on the learner again, like (C_r).

**Fix.**

* Make the replacement alphabet explicit. For example: the scaffold appends the step's output to a log, so both P and the decoder output increments, and Theorem 1 goes through unchanged for any such restricted alphabet.
* State how the run's result is read.
* Then either exhibit one natural task and reading under which "solves the problem" is ρ-robust for a constant ρ, or weaken the abstract and items 2 and 4 to: "Theorem 1 applies to properties robust to arbitrary replaced content; 'solves the problem' read from the run's end is not one of them without redundancy or a check."
  * Redundancy could mean the answer is restated at many steps and read by majority.
* Say explicitly that adversarial placement includes the last steps.

### A2. "Theorem 1 holds for every decoder" is false; the per-run sampler of Proposition 2 breaks it

**Where.** l.80 ("Robustness is required against every replacement pattern, because Theorem 1 holds for every decoder"). Related: items 2 and 8, and §4, which present the two results side by side.

**Problem.** The proof uses Lemma 1, which needs a decoder for which a mistake at x implies ξ_D(P(x)|x) ≤ 1/2: the majority decoder, or greedy decoding (note.md Remark 1.1).

* *Per-step sampler.* For the talk's sampler, which draws each step from ξ_D(·|x), Theorem 1 holds with an extra factor ln 2. Given the states, E|M_t| = E Σ_k (1 − ξ(P(x′_k)|x′_k)), and 1 − ξ ≤ ln 2 · log₂(1/ξ).
* *Per-run sampler.* It fails for Proposition 2's per-run posterior sampler. Counterexample (`referee3_theory_checks.py` §2):
  * H = {P, ν₁, …, ν_m} with w(P) = 1/2 and w(ν_j) = 1/(2m), so K(P) = 1 bit.
  * ν_j agrees with P except at the start state a₀, where it enters its own branch, and on that branch, where it keeps going while P and every other hypothesis send the branch to a sink. So ν_j's run has a mistake at every step: |M| = n.
  * A query at a₀ refutes every ν. A query on ν_j's branch refutes ν_j only.
  * The majority decoder never errs. The per-step sampler has 0 bad rounds at ρ = 1/2 in simulation.
  * The per-run sampler, with m = n, has expected number of bad rounds 0.368·n for every ρ < 1, by an exact DP: 5.97, 23.6, 94.3 and 376.8 at n = 16, 64, 256 and 1024. Theorem 1 would give K/ρ = 2 at ρ = 1/2.
  * The reason: once a rare hypothesis is sampled, its errors are correlated along the whole run. Catching it removes only its own mass, so the halving argument fails.

Consequence: Theorem 1 holds for the majority decoder, and Proposition 2's identity holds for the per-run sampler, but neither holds for the other imitator. Items 2 and 8 describe two different imitators, and no imitator in the note has both properties. If l.80 means "for some prior, the majority decoder's replacements can be any pattern", that is a different and true statement.

**Fix.**

* Replace l.80 with: "Robustness is required against every pattern, because for a suitable prior the majority decoder can produce any pattern."
* State for which decoders Theorem 1 holds: the majority and greedy decoders, and the per-step sampler with a factor ln 2.
* Add to §4 and item 8 that the per-run sampler does not inherit Theorem 1 (the counterexample above), or prove a weaker bound for it.

### A3. The slide-30 sentence is wrong

**Where.** Item 2, l.24: "It is enough for exactly the properties that survive 0.1% of replaced steps."

**Problem.** A per-step error rate e means E|M|/n = e. For a ρ-robust property, Markov's inequality gives failure ≤ e·n/(⌊ρn⌋+1) ≤ e/ρ. That is useless at ρ = e.

* Example: n = 1000, e = ρ = 0.001, so ⌊ρn⌋ = 1. Take |M| = 2 with probability 1/2 and 0 otherwise. The per-step error is 0.001 and the run fails half the time (`referee3_theory_checks.out` §4).
* There is also no converse. Nothing shows that 99.9% per step fails for every property that is not robust at 0.1%.

**Fix.** "99.9% per step bounds the failure of ρ-robust properties by 0.1%/ρ. For example, it is at most 1% for properties that survive 10% of replaced steps."

### A4. The fragile case does not give "the familiar n·K" from K/ρ; state the sharp bound

**Where.** l.23, l.81; Theorem 1 (l.69).

**Problem.** For ρ < 1/n, K/ρ > nK, and K/ρ → ∞ as ρ → 0. ρ = 0, which is E4's first row, is not covered at all. The proof actually gives E Σ 1[B_t] ≤ n·⌊K⌋/(⌊ρn⌋+1). That is exactly nK in the fragile case, and up to a factor 1/(ρn)·(⌊ρn⌋+1) better than K/ρ. For example:

* n = 16, ρ = 0.05: 16K instead of 20K;
* n = 16, ρ = 0.2: 4K instead of 5K.

**Fix.** State Theorem 1 as E Σ 1[B_t] ≤ n⌊K(P)⌋/(⌊ρn⌋+1) ≤ K(P)/ρ, and say that the left-hand bound gives nK at ρ < 1/n.

### A5. The persistence argument (item 7, l.46; §3 l.106) inverts a conditional and does not need Theorem 1

**Problems.**

1. "A ρ-robust property survives *only if* the deficit starts in the last ρn steps." Robustness gives *if*: a persisting deficit from step s gives |M| ≥ n − s, and if n − s ≤ ⌊ρn⌋ the property survives. It does not give *only if*, since a robust property may survive more replacements.
2. For ρ-robust properties persistence adds nothing. Theorem 1 already says that every round losing such a property has more than ⌊ρn⌋ mistakes, wherever they come from.
3. Where persistence helps is with properties that are *not* robust, and there the relevant result is the proof of Theorem 1, not its statement.
   * "Ends with the right insight" for catch-up humans is destroyed by one arbitrary replaced step.
   * It survives omission-only replacements unless all n − t_p steps from t_p on are replaced. That is robustness against the class-prior decoder's actual mistakes (Lemma 5 of the second note), with a problem-dependent ρ = (n − t_p − 1)/n (`referee3_theory_checks.out` §5: [8, 7, …, 1] at n = 8).
   * This is the second note's argument, and the restricted robustness of l.80.
4. "Theorem 1 charges them at most 1/ρ each" uses the second note's word "charge", which this note never defines. Here it means that each such round is caught with probability at least ρ.
5. The paragraph says "|M_t| ≥ ρn"; Theorem 1's condition is |M_t| > ⌊ρn⌋.

**Fix.** Rewrite as: "For *any* property, a failure caused by a deficit that persists from step s has |M| ≥ n − s, so a uniform query catches it with probability at least (n−s)/n. By the proof of Theorem 1, at most K/ρ rounds in expectation fail through deficits that start before step (1−ρ)n. Only failures from deficits that are silent, or that start late, can have few mistakes. For catch-up humans this is robustness against omissions only, with a problem-dependent ρ."

---

## (B) Overclaims and unclear statements

* **B1. "No factor n" assumes that ρ is fixed as n grows** (abstract; l.19; README l.79).
  * For a property that survives a fixed *number* j of adversarial replacements, ρ = j/n and the bound is nK/(j+1): the factor n is back.
  * Item 1 (l.17) says "survives *a few* replaced steps", which is exactly that case.
  * Whether the tolerable number of adversarially placed botched steps grows linearly with the length of a project is the substantive question. It should be stated as the hypothesis, not hidden in the definition of ρ.
* **B2. "Measured" and "exactly what Theorem 1 needs"** (item 4, l.32; §3 "Measuring it", l.108).
  * An experiment that replaces some steps by competent work, subtly wrong work or blanks measures robustness against those replacements at those places. ρ-robustness is a universal statement over adversarially chosen positions and arbitrary content (see A1 for the last steps).
  * "Would this project survive if 2% of its work packages were botched?" understates the condition. The adversary chooses which packages and what they contain.
  * "The question is now about the human and the task, not the learner" holds only for this sufficient condition. The version one could believe (l.80, Open 1) depends on the learner again.
* **B3. The confidence about kind (b) is inconsistent and not supported under adversarial placement.**
  * Item 5 says "fairly confident", the table says "very likely", and §3 lists (b) under "What I am confident of".
  * A "different but fine" step placed at the step of the key idea *is* a (d) step, so the kinds are not independent of placement. Yet l.99 says "the difficulty is not the kinds of replacement but where they fall", and (b) is still listed as confident.
  * An adversary can also inject a reasonable alternative approach every 1/ρ steps, and a human who takes up reasonable suggestions then thrashes.
  * "Collaborators supply them all the time" is evidence about benign, non-adversarial placement only.
  * "For a ρ well below the slack" compares a fraction with a number of steps (D6).
* **B4. The account of where a decoder's mistakes come from (item 6, l.41–43; §3 l.100–102) does not fit the note's model.**
  * In the model the human is deterministic and the decoder is exact Bayes. There is no noise and no overfitting, and every mistake is "missing knowledge": the posterior does not determine P at that state. So "those come from noise and superficial overfitting" describes some other learner.
  * The majority decoder outputs the most probable continuation, so junk (a) is its least likely kind of mistake. The kind the note is confident about is the one that matters least for the decoder it analyses.
  * "They fall *exactly* where the human knows something that the data have not shown, which is where (c) and (d) live" conflates "not implied by the data" with "decisive". Idiosyncratic but inconsequential choices, kind (b), are also unimplied by the data.
  * "Robustness to (a) and (b) buys the theorem only for mistakes of those kinds" should say: only if *all* of a run's mistakes are of those kinds. A run that mixes kinds gets nothing.
  * README l.89 repeats "exactly where".
* **B5. "Robustness against randomly placed replacements *of any kind* is much more plausible"** (l.101). "Any kind" includes arbitrary content: a step that deletes the draft (unless the scaffold is append-only), or convincing fabricated results. At a random 2% of steps that would derail many projects. Restrict the sentence to kinds (a)–(c).
* **B6. Missing qualifiers.**
  * The abstract's "lack it in at most K/ρ rounds in total" needs "in expectation" and "on problems where the human's run has it".
  * Item 2's "failure probability at most K/(ρN) after N queries" holds for a uniformly random stopping round among the first N, not for the decoder after exactly N queries. Failure need not be monotone in t: see without-a-check.md l.149–151.
* **B7. Proposition 2's second claim needs Φ and x₀ independent of the human** (l.116, item 8 l.50).
  * The equality is over P ∼ w. It fails for properties that mention P, such as Ψ_ρ, E4's properties, "the run is the human's run", or a "nice" judged by the human's own standards. For example, Pr[imitator's run = P's run] < 1 = Pr[P's run = P's run].
  * It also fails when the test problem is chosen using the human. In my enumeration, picking x₀ by the human's run opens a gap of 0.078 (`referee3_theory_checks.out` §3).
  * The prior must also be normalised, whereas note.md allows Σw ≤ 1.
  * "For a particular human it falls short *exactly when*…" (l.51) is a gloss, not a result.
* **B8. "E4 shows the mechanism of Theorem 1"** (l.130).
  * E4 measures oracle first passage to 2%, not Theorem 1's quantity E Σ_t 1[B_t].
  * In E2 the content sequence does not depend on the notes. So mistakes never compound, the decoder's run visits exactly the human's contents, and chained imitation's queries are i.i.d. uniform over the 4,096 contents at every n.
  * So the per-run mistake count is a sum of nearly independent indicators placed by π, independently of the decoder. That is the "random placement" regime that §3 says is *not* the concern, and its concentration effect is not Theorem 1's worst-case accounting.
  * Theorem 1's own quantity is easy to compute and shows the claim directly (`referee3_e4_checks.out` §3, §8). E Σ_t F_t:
    * fragile: 124, 285, 552 at n = 16, 64, 256, growing roughly like n^0.6;
    * ρ = 0.2: 13.6, 13.7, 12.5, flat;
    * ρ = 0.05 at n = 64 and 256: 54.8, 54.8, flat.
    * All are far below K/ρ ≈ 1,236 and 4,946.
  * Positive remark: because Ψ_ρ is the strongest ρ-robust property, E4's ρ rows measure Pr[B] exactly, the union over all ρ-robust properties, not just one example property. The note could say so.
  * The E4 caveat (l.141) should add that mistakes do not change the trajectory and are not placed by the decoder.

---

## (C) Experiment and code issues; number mismatches

* **C1. "The fragile property gets more expensive with n" (l.139; item 3, l.27; README l.82, "810–1,104 … growing with n") is a seed artefact.**
  * The 40 humans are the same at every n: World(seed) draws π and the rules independently of n. The queried content π^j(c₀) is uniform and i.i.d. across rounds at every n.
  * At n ≥ 16 each single rule on its own makes more than 2% of runs fail. The smallest single-rule failure is 2.44% at n = 16, 8.2% at n = 64 and 26.9% at n = 256. So the fragile target is met exactly when all 18 rules are known.
  * The number of queries until all 18 rules are known has the same distribution at every n. Its exact expectation, by inclusion–exclusion over the 2¹⁸ rule subsets, is 851.8. It is nearly identical across humans (sd 2.0), and its within-human sd is 535, so the s.e.m. of a 40-human mean is about 85.
  * The saved means 810, 843 and 1,104 have z = −0.49, −0.11 and +2.99 against this expectation.
  * With 10 fresh query seeds per human (400 runs per n), the means are 856 ± 25, 838 ± 26 and 837 ± 28: flat.
  * In the saved seeds, n = 64 versus n = 16 is more expensive for 20 of 40 humans, and the medians go 703 → 649 → 995.
  * The sentence "a failed run has a single mistake" is right (C-check above) but cannot produce growth with n here, because the 2% target already requires every rule at n = 16. E2's own n = 4 value (370) is below the saturation point.
  * The fragile-versus-robust contrast with n should instead be shown with E Σ_t F_t (B8), or with a target that does not saturate. Item 3, §5 and the README must drop "growing with n".
* **C2. The saved robust numbers are within noise of the 400-run values:**
  * ρ = 0.2: 38 / 22 / 17 against 38.7 / 25.0 / 16.6;
  * ρ = 0.05: 142 / 93 against 145.6 / 93.3.
  * The saved n = 64 → 256 decrease at ρ = 0.2 is weak (−4.6 ± 2.2, with 24 of 40 humans cheaper), but the larger run confirms it.
* **C3. The Theorem 1 bound against E4.**
  * K(P) = 247.3 bits for every E2 human under E2's product prior: 2 rules of each size, plus about 13 bits for the absent rules.
  * The number of queries that land on a mistake is about 15, at most 18, because every such query reveals a rule. The identity E Σ_t (per-step error) = E[# mistake queries] holds: 15.4 vs 15.1, 14.7 vs 14.9, 16.1 vs 15.2, each within one s.e.
  * So the effective "K" in E2 is the number of rules, and K/ρ is loose by about 100×. Nothing in the note claims tightness, but the note should not suggest that E4 tests the size of the bound.
* **C4. Undocumented details.**
  * The same 40 humans appear at every n: the E2 text says so, but E4 does not.
  * "±" is the s.e.m.
  * The stopping rule is a first passage of a non-increasing quantity.
* **No code bugs found.**
  * `math.floor(rho*n)` is never at an integer boundary for these (ρ, n), so floating point cannot change it.
  * `traj_hold & ~known` with a Python int is correct for 18 rules.
  * The RNG calls are the same as E2's CI, which is why the ρ = 0 row equals E2's.

---

## (D) Minor

* **D1.** "Chosen adaptively" (l.20, l.57) is vacuous for a deterministic P. A corrupted run with at most j replaced steps is any sequence from x₀ with at most j transitions that are not P-transitions. That is harmless, but the emphasis suggests extra strength.
* **D2.** Say that Ψ_ρ is the strongest ρ-robust property, so B_t = {|M_t| > ⌊ρn⌋}. This makes "for every such property at once" obvious, and it explains what E4 measures.
* **D3.** Theorem 1: the adversary must not see round t's coin, as in note.md's Protocol CI. Lemma 1 gives ⌊K⌋, which could replace K.
* **D4.** §4 uses ξ_D for the posterior over hypotheses. note.md defines ξ_D(y|x) as the predictive distribution. Write w(· | H_D). Under the program mixture (note.md Remark 1.2) a sampled program may not halt, so its "run" may not exist.
* **D5.** "The rarest rules fire at about one step per run" (l.139) reads as a rate. Write "fire at about one step in a run in which they fire at all" (1.02 to 1.27 measured).
* **D6.** "For a ρ well below the slack" (l.97): write "ρn well below the slack".
* **D7.** Medians in the table are rounded half up (702.5 → 703, and so on). Say that ± is the s.e.m. over 40 humans.
* **D8.** Item 5(a): "each such step costs at most one step of the budget". A replaced output can be arbitrarily long, and visible junk can still cost reading effort. Say "costs about one step if junk is cheap to recognise".
* **D9.** Item 2's graded version is paraphrased as "loses at most c/n per replaced step". Write "loses at most c·j/n relative to the human's run, after j replaced steps", which is the hypothesis actually used and is weaker.
* **D10.** "As Theorem 3 of the first note shows" (l.44). Theorem 3 is a lower bound for the fragile property on the hidden-insight class. It illustrates the obstacle; it does not show that robust properties fail there. "Illustrates" would be more accurate.

---

## Summary of requested fixes, by priority

1. **A1.** State the replacement alphabet and how the result is read. Acknowledge that final-state properties are fragile under arbitrary replacements. Weaken the abstract's "for some tasks", or give an example.
2. **A2.** Correct "Theorem 1 holds for every decoder". Say that Proposition 2's per-run sampler does not satisfy Theorem 1 (counterexample, 0.37n bad rounds with K = 1).
3. **C1.** Remove "the fragile property gets more expensive with n" from §5, item 3 and the README. Report E Σ_t F_t instead or as well.
4. **A3.** Rewrite the slide-30 sentence.
5. **A5.** Rewrite the persistence paragraph and item 7.
6. **A4.** State Theorem 1 in the sharp form n⌊K⌋/(⌊ρn⌋+1).
7. **B1–B8.** Qualify the confidence claims, the "measured" claim, the "no factor n" claim, and Proposition 2's hypotheses.
