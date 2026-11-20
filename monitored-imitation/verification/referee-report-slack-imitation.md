# Referee report: "Slack imitation: the scheme I am most sure of"

*Fourth independent AI referee (referee 4). I reviewed `slack-imitation.md` as last modified at 23:03 on 20 November, including Proposition 4, the SI-V experiment, the paragraph on thread D's Scheme B, the new rows of the Section 7 table, and Remark 1's citation of thread B's Theorems 3 and 4. I did not edit any existing file. My scripts and outputs:*
* *`verification/referee4_rerun.py` → `referee4_rerun.out`, `referee4_rerun/rerun_n16_n64.json`: re-runs every n = 16 and n = 64 cell of E6 (CI without slack, SI, LAST, MIX, SI-V).*
* *`verification/referee4_setback_e6.py` → `referee4_setback_e6.out`: the setback claim of Section 6, for the human alone and on every run the protocols actually produce.*
* *`verification/referee4_extra.py` → `referee4_extra.out`, `referee4_rerun/ci_same_humans.json`: chained imitation without slack on the same humans as the slack cells, and which problems SI-V rejects.*
* *`verification/referee4_rerun/setback_check_rerun.out`: re-run of `code/setback_check.py`.*

## Verdict

**The core mathematics is correct.** Lemma S, Theorem 2, Corollary 3, Proposition 4, (T1), (T2) and Remarks 1, 2, 4 and 5 hold as stated. The constants check. The dependencies are used correctly:
* Theorem 1 of `without-a-check.md` applies, including when the query sits at the bisection flip.
* Lemma 1 of `note.md` applies in SI-PAC and SI-V with the stated order of adding data.

**E6 reproduces exactly.** All 50 re-run cells at n = 16 and 64 match the saved outputs to every digit, and so does `setback_check.py`. The setback claim of Section 6 holds on every run the protocols produced: about 91,000 runs, 22,579 of them failed. It does not hold for the human alone (C4).

**Three errors, none in the main theorems:**
1. Remark 3 (read-out) needs an assumption it does not state (A1).
2. The claim that "omissions are uncertain steps" is false in the lower-bound class (A2).
3. "Falls back to chained imitation's guarantee" is off by the factor 1/(1−ρ), which is 2 for ρ = ½, and E6 shows this factor (A3).

**Two factual errors in the description of E6:**
* The "same humans without slack" are not the same humans. On the same humans, chained imitation without slack costs about half the quoted numbers (C3).
* SI-V's cost per rejected run is about n for silent humans, not n/2 (C6).

**The main overclaims:**
* (B_D) is as learner-relative as (C_r), which the comparison table holds against end-weighting (B4).
* The D = 0 case of the theorem is already thread C's Corollary (slack), and the counting is `robust-runs.md`'s Theorem 1. Neither is cited, and `robust-runs.md` is not cited anywhere (B5).
* The decoder's mistakes are sorted into omissions, predictable commissions and junk on the basis of a product-posterior proposition. "Predictable" there means only "plurality" (B1).
* "The one exception I can find" to (B-omit) overlooks thread C's hedge counterexample (B3).
* "Every way round the factor n uses a human signal that a contribution is missing" is false by the threads' own lists (B6).

---

## A. Errors

### A1. Remark 3 (read-out) needs read-out soundness on the imitator's notebooks

**The claim.** "Read-out failures are charged ½ each and the others ρ/(2(D+1)), so all failures together are at most 2(D+1)K/ρ in expectation."

**The gap.** A read-out failure is charged ½ only if it is a *mistake* at the read-out step. That needs the human's read-out from the imitator's final notebook to be correct whenever S holds. Nothing in the note says so.

**Counterexample.** The imitator's notebook contains the correct design (so S holds) and also a plausible wrong design, appended as a predictable commission. The human, asked "which entry is the solution?", picks the wrong one. The imitator's read-out copies the human's exactly, so there is no mistake at the read-out step, and earlier steps need not contain one either. The failure is charged 0 and can recur on every such run. So the bound 2(D+1)K/ρ does not follow.

**Fix.** State an assumption, for example: "(R) for every notebook y on an imitator run with S(y), the human's read-out from y is correct." Alternatively, put the confusion into the setback accounting: define S as "the human's read-out is correct" and require that to be preserved by appending. That is a strong condition, since appending a plausible wrong answer can break it. Then say that (R) is a further condition on commissions, in the same class as (B-commit).

### A2. "Omissions are uncertain steps, so the uncertain half finds them faster" (end of Section 4) is false in general

**Why it fails.**
* In the hidden-insight class, the note's own "typical" omission is a confident one. At every unprobed step the posterior probability of an insight is in [η/n, 2η/n], the same at every such step (`note.md` §4.1, "What it does not buy").
* Thread C's Proposition 2 says the decoder omits whenever π·p_max ≤ 1 − π, and that includes tiny π.
* So the uncertainty-weighted half is no better than uniform at finding rare-insight omissions, and `note.md` §4.1 says exactly this.

**What is true.** The bound part of the claim is correct: with at least half of each round's distribution uniform, Theorem 2 holds with ρ/(2(D+1)), by Theorem 1 of the second note.

**Fix.** "Omissions *near the decoder's writing threshold* (π·p_max close to 1 − π, such as E6's late ideas) are uncertain steps. Omissions of rare content (small π) are confident, and only the uniform half finds them."

### A3. The fallback is chained imitation's guarantee times 1/(1−ρ), not chained imitation's guarantee

**Where.** Answer 7, Remark 2, and the 75% figure in Section 4.

**The claim.** "Its worst-case guarantee is chained imitation's n·K failed runs." But slack imitation's n is n₀ + σ = n₀/(1−ρ). Chained imitation runs on the human's own horizon n₀, and its guarantee is n₀·K (Remark 1 itself says "chained imitation is the case σ = 0"). So without (B_D), slack imitation's guarantee is n₀K/(1−ρ), which is 2n₀K for ρ = ½.

**E6 shows the factor 2 at fixed n₀** (`referee4_extra.out`). On the same silent humans:

| n₀ | CI without slack (n = n₀) | SI (n = 2n₀) |
|---|---|---|
| 8 | 2,249 | 4,467 |
| 32 | 10,873 | 21,964 |

**A related point in Theorem 2.** The bound (D+1)·n/(σ+1)·K is weaker than the fallback n·K when D ≥ σ. The tight statement is E[#failed] ≤ min{n, (D+1)n/(σ+1)}·⌊K⌋. Lemma S gives |M| ≥ max{1, (σ+1)/(D+1)}, and |M| ≥ 1 follows from its own inequality.

**Fix.**
* Answer 7: "When the assumption fails, the guarantee is chained imitation's on a run of n = n₀/(1−ρ) steps, that is, n₀K/(1−ρ), twice chained imitation's for ρ = ½."
* Theorem 2: state the min.
* "Loses nothing on the others" (Section 4, confidence list) should become "loses a factor 1/(1−ρ) on failures with unbounded setback."

---

## B. Overclaims, and cross-references

### B1. The three kinds of decoder mistake (Section 4, Answer 4)

**Rests on a special case.** The classification is drawn from thread C's Proposition 2, which needs a posterior that is a product over items. The note says so, but then generalizes ("So its mistakes are of three kinds"). A Solomonoff posterior over notebooks is not a product, and for long text outputs the mode of a diffuse distribution need not be any of the three kinds.

**"Predictable" means only "plurality".** The rule π·p_max > 1 − π allows the decoder to write content that is more likely wrong than right. In E6 the decoder writes value 1 once Pr[due] > 1/1.9 ≈ 0.53. At that point Pr[the write is right] = 0.9·0.53 ≈ 0.47. "Predictable continuation" and "the obvious idea" suggest high confidence, which Proposition 2 does not give.

**"Omissions are the typical mistake" and "junk is rare" are unsupported.** The note's own paraphrase paragraph says that "formally, almost every step is a commission". That undercuts both "most of the imitator's mistakes are omissions" (the basis of the 75% figure) and the 90% given to (B-omit): paraphrases are covered by (B-commit) with D = 0, not by (B-omit). A paraphrase that subtly changes meaning is a "fooled" commission.

**Fix.**
* Present the three kinds as a heuristic for product-like posteriors.
* Give "predictable" its exact meaning.
* Fold the paraphrase case into the (B-commit) confidence, not the (B-omit) one.

### B2. "Certain by determinism and the hidden clock" (Answer 4, Section 4)

**In the model it is a tautology.** With g = ∅, y ∪ g = y, so τ(y ∪ ∅) ≤ τ(y) holds by definition. As evidence about humans it adds nothing: it is the assumption that the human is a stateless function of the notebook, with no outside clock, memory or calendar.

**"Certain by construction: hidden clock" overclaims.**
* The scaffold can withhold the step number, but an append-only notebook that grows every step reveals it approximately (entries per step, dates written in entries).
* So Remark 4's "it removes deadline effects" is not guaranteed.
* The empty-step argument survives, because the notebook is identical. The claims about the reference chain (the human's n₀-step success without a known deadline) and about deadline effects do not.

**Fix.** "True in the model by definition, given that P is a deterministic function of the notebook alone. For a real person this requires that nothing outside the notebook tells it the date." Weaken "removes deadline effects" to "removes stated deadlines".

### B3. "The one exception I can find" to (B-omit)

Thread C §6 already gives a second exception, which is a partial step with unbounded setback. The human writes its idea A together with a hedge B; on a draft that contains B it never writes A. The decoder that knows B but not A writes B and omits A, and from then on A is never due. In the note's terms this is g = {B} ⊊ P(y)∖y with τ(y ∪ g) = ∞.

Thread C §7 adds stage-specific contributions on own-work drafts. Section 4 lists that one among commissions, but a partial step can trigger it too.

**Fix.** List substitutes and hedges as a second exception, citing thread C §6.

### B4. (B_D) is learner-relative, like (C_r), and the comparison should say so

**What the note says.** It states that "(B_D) mentions the imitator only through which notebooks and entries occur", and that the human-alone version is "too strong to believe". Yet:
* the Section 7 table marks end-weighting down because "(C_r) is a condition on the imitator's states, hard to assess (the user's objection)";
* the new Scheme B paragraph says Proposition 4 "replaces (C_r), a condition on the imitator's states, with … a one-step condition on the human's remaining time".

**Why that is inconsistent.** (B_D) is quantified over exactly the imitator's states and entries. `robust-runs.md` (answer 4, Lemma 2) anticipated this: a usable outcome condition must restrict to the imitator's guesses, "and that brings the learner back in".

The genuine advantage of (B_D) is that it is *local*. It is one step at a time, and it is measurable by the planted-entry tests of Section 4, while (C_r) asks for a repair within r steps. It is not more independent of the learner.

**Fix.**
* Say this in Section 3 and in the table.
* Either apply the same "condition on the imitator's states" caveat to the slack rows, or remove it from the end-weighting row.
* In the Scheme B paragraph, write "a one-step condition on the human's remaining time, on the imitator's notebooks".

### B5. Uncredited prior results in the folder

**The D = 0 case is thread C's.** Thread C's Theorem B and its Corollary (slack) already prove the D = 0 case under persistence (P₁) for all items: each mistake delays a persistent human by at most one step.
* With chained imitation and the check: E[#bizarre] + (σ+1)/n·E[#failed non-bizarre] ≤ K.
* With the mixed query: 2·max(1, n/(σ+1))·K.

That is Theorem 2 with D = 0. The note cites thread C only for Proposition 2, CHAIN and "ripe" failures, and its table row for thread C says "late ideas not caught without slack" without mentioning that thread C already treated slack.

**The counting is `robust-runs.md`'s.** Theorem 1 there bounds by n⌊K⌋/(⌊ρn⌋+1) ≤ K/ρ the rounds that lose a property surviving ⌊ρn⌋ replaced steps. Lemma S says exactly that, under (B_D), S survives up to ⌈(σ+1)/(D+1)⌉ − 1 of the decoder's replacements. The header says the note synthesizes "the three earlier notes", but `robust-runs.md` is not cited anywhere.

**Fix.** Cite both. Present Lemma S as extending thread C's Corollary from persistent humans (D = 0) to bounded commissions, and Theorem 2 as `robust-runs.md` Theorem 1 with robustness against the decoder's replacements. That answers `robust-runs.md`'s answer 4.

### B6. "Every way round the factor n … uses some human signal that a contribution is missing" (Answer 5), and the thread D frame (Section 5)

**The threads' own lists contradict it.** Other ways round the factor n in the folder:
* insights at predictable steps, shared knowledge and δ-isolation (`without-a-check.md`, answer 1);
* complete elicitation and diagnostic probes (thread B, Theorem 5(a), (c));
* a concentrated position law (thread D, Scheme D).

**The thread D frame is narrowed.** Section 5 paraphrases it as "every n-free route found uses a *human* signal that is a threshold or group test". Thread D's list includes an honest party (debate) and white-box structure.

**Slack's mechanism is a different one.** Slack does not use a threshold or group test. Its queries are point queries, uniform task queries. What changes is the *size* of the defect set, at least (σ+1)/(D+1) mistakes, so that point queries suffice. That is the "mistake mass" frame of `without-a-check.md` Theorem 1, and it is not "the cheapest such signal" in thread D's sense.

**Fix.**
* "Every way round the factor n *for unpredictable, problem-specific insights* …"
* Describe slack as turning a point defect into a large one, not as a threshold test.

### B7. The confidence numbers (Section 4)

* *"The theorem as stated: high; it is short and refereed below."* Nothing in the note is "below". Link this report instead.
* *(B-omit), 90%.* (B_D) is used as a universal condition: one notebook on one run with unbounded setback voids Theorem 2 as stated. A 90% credence that it holds at every mistake of every run is not plausible given B3. The defensible statement is about most mistakes. Remark 5 (average setback) and Remark 2 (the actual setbacks D_k) carry that version, so attach the confidence numbers to those.
* *"I would vouch for D of one or two steps" for mathematics and code.* This also needs to be per-mistake on average, not a maximum.
* *"Beating chained imitation by a large factor on a real deterministic human: about 75%."* Answer 7 itself warns that comparisons are between guarantees, not humans. The reason given ("most mistakes are omissions and the scheme loses nothing on the others") is wrong twice: see B1 for the first half and A3 for the factor 1/(1−ρ).

**Fix.** Restate the confidences for the average-setback version, and drop or justify the 75%.

### B8. "This is the 'O(K) reasonable queries' result asked for" (Answer 2)

Corollary 3 gives O((D+1)K·log(K/δ)/(ρε)): it has a 1/ε and a log K. Only Proposition 4, with a verifier, is O(K) in task queries.

**Fix.** "O(K) for fixed ε, δ, D and ρ. Truly O(K) task queries with a verifier (Proposition 4)."

### B9. Attribution of Proposition 4

"This is the first note's monitored bisection with the 'on track' check replaced by a verifier of the result" is not the right ancestor. With a check of final results only, the first note's protocol is check-and-scan (`note.md` §5.4, Proposition 8), whose bound n·K is exactly Proposition 4(c) without (B_D).

The new Scheme B paragraph says "It is the same protocol, with the search in the last r steps". Thread D's Scheme B scans x′_{n−r}, x′_{n−r+1}, … *in order* (thread D §3(B), step 3), not uniformly.

**Fix.** "Proposition 4 is the first note's check-and-scan (Proposition 8) with the in-order scan replaced by uniform search, which slack makes cheap. It is thread D's Scheme B with slack and (B_D) in place of (C_r), and uniform search in place of the windowed scan."

### B10. Answer 1, "four changes to the scaffold that cost no queries"

The optional check costs human checks: one per round, plus ⌈log₂ n⌉ per run that fails it. Slack costs compute and, without (B_D), the factor 1/(1−ρ) of A3.

**Fix.** "Three changes that cost no queries, and an optional check that costs one look per round."

### B11. Cross-references checked

| reference | status |
|---|---|
| Lemma 1 of `note.md` ("halves", "adding further data never hurts") | correct ("at least halves") |
| Theorem 1 of `without-a-check.md` | correct, including point-mass q_t at the flip |
| `note.md` §5, (M1), (M2), MB-PAC epochs | correct. (M3) here is a different condition from `note.md`'s batch (M3); see D1 |
| `note.md` Theorem 3: bound, silent humans, single mistake | correct, but "a failed run has a single mistake" holds for the class-prior decoder (`without-a-check.md` §2); "attained by" should be "proved on" |
| Thread C, Proposition 2 | correctly qualified ("product over items"), but over-generalized (B1) |
| Thread C, CHAIN, ripe failures, BIS | correct |
| Thread C, Theorem B and Corollary (slack) | not cited (B5) |
| `robust-runs.md` | never cited (B5) |
| Thread B, "Theorems 3 and 4", reduces K not n | correct now. Section 5 also counts thread B's *located* probes (Theorem 5(b)) as n-free, so the table row "probes … reduces K, not n" should add "located probes remove n (Theorem 5(b))" |
| Thread D, point versus threshold | narrowed (B6) |
| Thread D, Scheme A row | consistent with thread D §3(A) and §4 (≤ K, lenient vs strict endorsement) |
| Thread D, Scheme B row and paragraph | bounds correct (≤ K rejected runs, ≤ r·K task queries); the three reasons are quoted accurately; "same protocol" needs "in-order scan" (B9) |
| Thread D, Scheme C row | correct (≤ K+1 requests). The human's effort (K+1)(c+1), with c possibly about a run's cost, is worth adding |
| Thread A row | consistent with thread A §2's V_bizarre ("most believable and nearly useless for quality") |
| Table: chained imitation, end-weighted, monitored bisection | match `note.md` Proposition 2 and Theorem 6, and `without-a-check.md` Theorem 3 |
| "The second note's referee showed …" | correct |

---

## C. Experiment E6

### C1. Re-run: exact reproduction

`referee4_rerun.py` calls `one_human` and `one_human_verifier` with the seeds, caps and configurations of `main()` and `main_verifier()`.
* All 50 cells at n = 16 and 64 match the saved JSON in every field: CI without slack, SI, LAST, MIX and SI-V, for five kinds each.
* `setback_check.py` reproduces `results/setback_check.out` byte for byte.
* I did not re-run n = 256, which takes about 20 minutes and uses the same code path.

### C2. Code against Section 6

Matches:
* the five kinds (persistent flag and D);
* the human's step (`outputs`);
* success (a = k_p and u ≥ n₀ − t_p − 1);
* the protocols (`pick_step`);
* the caps (LAST 400·M = 40,000; the others 40·M·n = 4,000·n);
* the oracle stopping rule.

The scalar replica in `referee4_setback_e6.py` agrees with `Problem.outputs` on every input tested (Part 0).

Not stated in the note, and worth stating:
* **Tie-breaking.** Section 6 says nothing. The code prefers NOTHING > SET1 > SET2 > INC on an empty draft, and INC > NOTHING > SET1 > SET2 otherwise. So ties go to not writing (as in thread C's Proposition 2) and to not correcting. The docstring calls INC "keep the draft unchanged", but INC changes the draft; say "continue the current draft".
* **Silent humans also never correct a wrong value** (`KINDS["silent"] = (False, INF)`). This matters. Once queries have eliminated every t ≠ t_p, the silent decoder writes value 1 at t_p even when k_p = 2. Part 2 of my check finds commissions with infinite setback in the silent cells. So "for silent humans it never writes anything until queries locate t_p" is true, but it can then write the wrong value.
* **Humans add work to their own value before it is available to them** (k = a gives INC whatever j is). So a premature correct write by the decoder is always a gain. This is generous to the bounded-setback kinds; say so.
* **"It makes all three kinds of mistake: late, wrong and missing ideas."** The prior decoder of the persistent kinds always writes 1 by about 0.53·n₀, so it never misses the idea altogether. "Missing" happens only for silent humans.

### C3. "The same 40 humans for every protocol" is false for the no-slack row, and Answer 8's "the same humans without slack" are different humans

**What the code does.** `one_human` draws t_p uniformly on [0, n₀) with n₀ = n − σ.
* In the "CI, no slack" row, n₀ = n: t_p ∈ [0, 16) at n = 16.
* In the slack rows, n₀ = n/2: t_p ∈ [0, 8).

The k_p agree but the t_p do not (`referee4_extra.out`, item 0). The no-slack humans have twice the horizon and about one more bit per problem.

**On the same humans** (same seeds, n₀ = 8 and 32, chained imitation at n = n₀), from `referee4_extra.out`:

| n₀ | CI without slack, same humans | SI with slack | note's "CI, no slack" row |
|---|---|---|---|
| 8 | 2,915 (noticing); 2,919 (misled-2, misled-8, fooled); 2,249 (silent) | 160–485 (bounded); 1,631 (fooled); 4,467 (silent) | 6,012–6,022; 5,088 |
| 32 | 12,724 (bounded); 12,729 (fooled); 10,873 (silent) | 204–227 (bounded); 2,811 (fooled); 21,964 (silent) | 25,208–25,256; 22,845 |

So the improvement from slack for the noticing kind is about 18 at n₀ = 8 and about 62 at n₀ = 32, not about 38 and 124 as the quoted rows suggest. It still grows with n, so the qualitative conclusion stands. For silent humans slack *doubles* the cost at a fixed horizon (A3).

**Fix.**
* Either add a "CI, no slack, same humans (n = n₀)" row, or relabel the row "CI, no slack, n₀ = n (different humans)".
* Correct Answer 8 and Section 6 ("the same 40 for every protocol at a given n" holds only for the slack rows).
* Replace "Slack does not help them at all" (silent humans) with "slack doubles their cost at a fixed n₀: the uniform query is spread over 2n₀ steps."

### C4. The setback claim holds on the decoder's runs, not for the human alone

**The claim** (Section 6, "Setbacks"): in the time-indexed sense of Remark 4, the noticing kind has setback ≤ 0 at every mistake and misled-D at most D.

**Part 1: the human alone.** All drafts (a, u, j), all imitator outputs c, at n₀ = 4 and 8.
* The claim fails in exactly one case: the imitator writes a value, right or wrong, on a notebook that already builds on k_p. The dependent work restarts at u = 0.
* At n₀ = 8 the setback reaches 8 for noticing, 10 for misled-2 and 16 for misled-8.
* Every other case satisfies the claimed bounds.
* Silent humans have infinite setback at an omitted idea, and fooled humans at a wrong value, as claimed.

**Part 2: reachable runs.** I replayed SI, MIX, LAST and CI without slack at n = 8, 16 and 32, with the code's own `Problem` class (10, 10 and 5 humans), and checked every run any problem took during learning: over 91,000 runs of the non-silent kinds, 22,579 of them failed.
* Largest commission setback: 0 (noticing), 2 (misled-2), 8 (misled-8).
* Largest omission setback: 0 for every persistent kind.
* τ(x₀) = n₀ on every run.
* No Lemma S violation, that is, no failed run with fewer than (σ+1)/(D+1) mistakes.
* No overwrite of a correct value, and no run that reaches S and then loses it.

The decoder never overwrites because it never favours a value the data contradict. Any answer that reveals a value kills every hypothesis with the other value.

**Fix.** Say: "On the decoder's runs (which is what (B_D) quantifies over); not for all notebooks. Overwriting a notebook that already builds on k_p would cost up to its whole dependent work, but the decoder never does it." Cite `referee4_setback_e6.out`.

### C5. E6's success criterion is not preserved by appending

Section 2 requires that S be preserved by appending. In E6, a correction resets the dependent work, so appending a value to a notebook that satisfies S destroys S. So (T2) fails for E6 as a model.

It is harmless on the runs that occur: Part 2 found no run that reached S and lost it. But it should be stated. Alternatively, define E6's S as "has, at some point, built at least the target number of units on k_p", which is append-preserved.

### C6. Numbers quoted in the note against the saved outputs

Every number in Section 6's main table, in Answer 8, and in the Reading bullets matches `results/slack_imitation_summary.json` and `results/slack_imitation_mix.json`. That includes ×2.6, 120–160, "about 20 hits", the 10% and 100% stalls, and "about twice" for MIX (1.75–2.5×). The exceptions are in the new verifier text:
* **Verifier table, fooled at n = 256, "(143)".** The saved value is 142.49, so print 142.
* **"Fooled and silent humans cost about n/2 task queries per rejected run".** Wrong for silent humans: 16.1, 64.5 and 261 at n = 16, 64 and 256, which is about n. Each rejected run has a single mistake, so the expected search is n. Fooled humans cost 12.4, 39.0 and 143, which is 0.77n, 0.61n and 0.56n. Fix: "about n for silent humans (one mistake per rejected run), between n/2 and 0.8n for fooled ones".
* **Answer 8, "about 14 task queries for all 100 problems at every n".** True for noticing and misled-2 at every n and for misled-8 at n = 64 and 256 (13–16). Misled-8 at n = 16 needs 38. Add the exception.
* **"Only the ten or so problems whose idea is the specific one are ever rejected."** Verified: every rejection of a bounded-setback human is on a k_p = 2 problem. A few problems are rejected more than once: per human, 0.23 (noticing and misled-2) and 0.97 (misled-8) at n = 16, and 0.07 for all three at n = 64 (`referee4_extra.out`).

### C7. SI-V code against Proposition 4

`one_human_verifier` implements SI-V as stated:
* the verifier is the exact success predicate;
* on a rejection, uniform queries with replacement are made on the fixed run, because `pr.run` is not recomputed during the search;
* the hit's answer is applied first, then the held answers, then one recompute.

With exact elimination the final posterior does not depend on the order; the order matters only for Lemma 1's bookkeeping, and the code follows it. Problems are processed once each, in order, each with its own posterior. That is right for this product class.

**On the comparison with SI** ("about 200 versus 14: the verifier removes the cost of detecting failures"). The comparison is fair as far as it goes, but say that:
* the verifier is a perfect success oracle, called 100 + K-ish times and not counted;
* SI-V's guarantee covers the verified problems only. It does not give an imitator with a failure bound off the verified set.

### C8. `setback_check.py` tests an identity, not Lemma S's content

**Why it cannot fail.** τ is computed from a deterministic P, so (T1) holds by construction, and τ(x₀) = n₀ by the choice of x₀. The script's quantity Σ_{k∈M}(1 + D_k) then equals τ_n − τ_0 + n = τ_n + σ identically. With S monotone ("contains T"), failure is equivalent to τ_n ≥ 1. So "Σ(1 + D_k) ≥ σ + 1 on failed runs" is an algebraic identity that fails only if the code is wrong, and the smallest margin of 0 just means some failed run has τ_n = 1.

**What it does not test.**
* (B_D), the substantive assumption. Its random humans mostly violate it: 1,587 of 2,042 failed runs have an infinite setback, and 1,387 have a single mistake.
* Any decoder behaviour.
* Any edge case of (T2).

**Where it is cited.** The note does not cite it; `README.md` describes it as a "brute-force check of the fourth note's Lemma S".

**Fix.** Describe it as an arithmetic sanity check of Lemma S's bookkeeping. If a substantive check is wanted, use the approach of `referee4_setback_e6.py`, Part 2: measure setbacks on runs the learner actually produces.

---

## D. Minor points and clarity

1. **(M3) changes meaning.** In `note.md`, (M3) is batch checking. Here it is prefix-closure. Rename it, for example (M3′) or (M-prefix), and note that thread C's (M3) is the ⪯-version. Section 4 also equates (M3) with "bizarreness is a property of entries", which is only a sufficient condition (Section 2 says so correctly).
2. **Sets or lists, and what a label is.** The note writes y ∪ g and P(y) ⊇ y, as for sets, but also "deleting entries from its end", as for lists. Say which. Also say whether a label is the whole next notebook or the list of appended entries. Under a Solomonoff prior most hypotheses are not append-only, and "the scaffold appends whatever a step outputs" leaves G(y) ≠ P(y) but y ∪ G(y) = P(y) possible. That is harmless for Lemma S, since τ falls there, but confusing. Defining labels as appended entries, as thread C's assumption (Y) does, removes the issue.
3. **Corollary 3 hypotheses.** Restate τ(x₀) ≤ n₀ and, with the check, (M1)–(M3). Note that SI-PAC needs D and ρ to set m_i. If (B_D) fails, the stopping rule is miscalibrated: the output's failure bound becomes n·ρ·ε/(D+1) with probability 1 − δ, which is chained imitation's rate up to logs. One sentence would make the fallback explicit for the PAC version too.
4. **Theorem 2 for D ≥ σ.** State min{n, (D+1)n/(σ+1)} (A3). Also: "the factor n is replaced by (D+1)/ρ" only when D < σ.
5. **Proposition 4.**
   * (b) and (d) hold almost surely: a search ends with probability 1, not on every path.
   * SI-V has no bizarreness check, so (c) needs (B_D) without the non-bizarre proviso.
   * Sampling steps without replacement would give at most (n+1)/(|M|+1) queries per search.
6. **The hidden-clock edge case.** Under the hidden clock, P(y) = y forces P(P(y)) = y, so τ(y) ∈ {0, ∞}. Consequences:
   * "The imitator writes something where the human writes nothing" cannot occur on a failed run with finite τ. It occurs only with a visible step, as in E6, where it is the main kind of commission: premature writes.
   * A hidden-clock human must write something every step until done, because an idea cannot "arrive" without a trace in the notebook.
   * E6's humans, whose idea arrives at t_p, are therefore not hidden-clock humans. The note says E6 uses a visible step, but not why it has to.
   * Remark 4's "verbatim": with a visible step, (B-omit) for g = ∅ becomes τ(y, k+1) ≤ τ(y, k). That is a real assumption, that the human is not deadline-driven, no longer a tautology. Say so.
7. **D = 0 versus (B-omit).** With D = 0 the two parts of (B_D) coincide. Answer 2's wording ("costs it at most D steps of extra work") is right only if one reads D as extra *beyond the wasted step*, since each mistake costs D + 1 steps of slack. Say so once.
8. **Section 5.** "In that class a failed run has a single mistake" should say "for the class-prior decoder", and "attained by silent humans" (Answer 5) should be "proved on silent humans".
9. **Remark 3's other assumption.** Besides A1: the read-out uses a different instruction from "continue for three months", so it reveals that the run is over. That is harmless, but say it, since the hidden clock is otherwise maintained.
10. **"Thread B … (Theorems 3 and 4 there)" in Remark 1** is now accurate. The Section 7 thread B row should still mention located probes (B11).
11. **Answer 8 and Section 6, SI versus SI-V.** Say that E6's SI uses an oracle stopping rule. In effect it also has a success oracle, used only to decide when to stop, which makes the 200-versus-14 comparison less lopsided than it looks.
12. **Section 9, item 4 (trees).** The new text is fine. One more point: running a tree depth-first in one notebook makes later subcalls see earlier subcalls' commissions, so (B_D) must then hold across subcalls.

---

## Appendix: commands run

```
cd code && python3 setback_check.py                      # identical to results/setback_check.out
cd verification && python3 referee4_rerun.py             # 50 cells, all MATCH (276 s)
cd verification && python3 referee4_setback_e6.py        # Parts 0-2
cd verification && python3 referee4_extra.py             # same-humans CI; SI-V rejections
```
