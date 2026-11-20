# Referee report: "Slack imitation", version 2

*Fifth independent AI referee (referee 5). I reviewed `slack-imitation.md` version 2 as last modified at 23:27 on 20 November, together with `verification/response-slack-imitation.md`, referee 4's report, `research/threadE-redteam.md` and the new parts of `code/slack_imitation.py`. I did not edit any existing file and ran no git commands. My scripts and outputs, all in `verification/`:*
* *`referee5_rerun.py` → `referee5_rerun.out`: re-runs every SI-V-ABC cell at n = 16 and 64 (both α, all kinds, 40 humans) and every same-humans CI cell at n = 16 and 64. It also regenerates the table from the saved JSON files.*
* *`referee5_abc_checks.py` → `referee5_abc_checks.out`: replays SI-V-ABC with every run instrumented, and checks each step of Proposition 5's proof on 116,612 actual runs (n = 16, 32, 64; α = 0.1, 0.3).*
* *`referee5_abc_mechanism.py` → `referee5_abc_mechanism.out`: why the fooled humans' SI-V-ABC cost hardly grows with n.*
* *`referee5_si_abc_online.py` → `referee5_si_abc_online.out`: SI-ABC without a verifier, which E6 does not run.*
* *`referee5_theory_checks.py` → `referee5_theory_checks.out`: the ask budget arithmetic, Corollary 3's growth, Remark 1's gain condition, and Proposition 5's accounting on random hypothesis classes with a check.*

## Verdict

**Proposition 5 is correct, and its proof is complete in substance.**
* *The order-independence argument is valid.* W is a function of the data set, and asks enter the data at once, so the decision committed at step k used exactly D_t ∪ A_{<k}. Listing A_{<k}, then the hit, then the rest gives the hit at least log₂(1/α) bits and every other term ≥ 0.
* *(a)* holds on every path, for SI-ABC and SI-V-ABC alike.
* *(b)* follows from the *proof* of Theorem 1 of `without-a-check.md`, which the note in effect reproduces, not from its statement. That statement concerns a run of one fixed decoder, and its count of hits comes from Lemma 1's ⌊K⌋.
* *The flip* of a run that fails the check is always a committed mistake.
* *α ≤ ½ is not needed* (D2).
* *(c)* is right.
* *"About 0.69K/α"* is a valid upper bound: (ln 2)·K/α ≥ K/log₂(1/(1−α)) for every α. It is tight only as α → 0, and overstates the bound by 19% at α = 0.3.
* *On E6's actual runs* every step of the proof checks: 116,612 runs, 327,327 asks, 78,720 committed mistakes and 16,612 rejections, with no violation. The same holds on random hypothesis classes with a "nothing bizarre" check (368 flips), including α > ½.

**The other numbered statements are correct after their edits:** Lemma S with max{1, ·}, Theorem 2 with min{n, ·}, Corollary 3 with its added hypotheses and fallback, Proposition 4 with its notes, and Remarks 2, 4 and 5. Remark 3's bound is right given (R), with a wording slip (D7). Remark 1 needs a condition (B4).

**E6 reproduces exactly.** All 20 SI-V-ABC cells at n = 16 and 64 match to every digit, and so do all 10 same-humans CI cells. The table regenerates byte-identical, and every row of it appears verbatim in the note. SI-V-ABC implements the protocol as described. Every number quoted in Answer 8 and in the Section 6 reading matches the saved outputs.

**Two errors, neither in a proof:**
* Answer 2's "O(K) reasonable queries for fixed ε, δ, D and ρ" is O(K log K) (A1).
* Proposition 5's deployment note says that a *frozen* imitator that keeps asking stays within the lifetime budget. It does not (A2).

**The main overclaims:**
* *The E6 reading of ask-before-committing.* "Makes fooled humans flat" and "removes the fooled humans' growth" are not quite true. Where the flattening happens, it is an artifact of E6's prior, not something Proposition 5 predicts. Every confident wrong commitment in E6 occurs when t_p = n₀ − 1, the last possible idea time, so rejections fall like 1/n₀ (B1, C5).
* *Cost with a verifier.* Answer 2 and the Section 7 table omit the asks (B2). The note recommends adding asks to the verifier version without stating the trade-off, which in E6 multiplies the cost for bounded-setback humans by 6–23 (B3).

**The response file** is accurate item by item, with three small exceptions (B6, D8, D9) and one fix that is itself wrong (A1).

---

## A. Errors

### A1. Corollary 3 is O(K log K) for fixed ε, δ, D and ρ, not O(K) (Answer 2)

**Where.** Answer 2 says "So this is 'O(K) reasonable queries' for fixed ε, δ, D and ρ". The wording came from referee 4's B8, which missed the problem.

**The problem.** Corollary 3's count is (⌊K⌋+1)·⌈(D+1)·ln((⌊K⌋+1)(⌊K⌋+2)/δ)/(ρε)⌉, which Answer 2 itself writes as O((D+1)K·log(K/δ)/(ρε)). The logarithm contains K, so the count divided by K grows like 2 ln K. `referee5_theory_checks.out`, Part 2: with ε = 0.01, δ = 0.05, D = 1 and ρ = ½, rounds/K is 3,467 at K = 10 and 12,251 at K = 10⁶.

**Fix.** "So this is O(K log K) reasonable queries for fixed ε, δ, D and ρ, and truly O(K) task queries with a verifier." Alternatively, use a PAC conversion without a per-epoch union bound if O(K) is wanted.

### A2. Proposition 5's deployment note: a frozen imitator that keeps asking is not within the budget

**The claim** (Notes on Proposition 5): "A frozen imitator deployed after a PAC phase must either keep asking, which stays within that budget, or abstain at unconfident steps."

**Why it fails.**
* *The budget in (a)* holds because each ask's answer is added to the data, which lowers Φ. A *frozen* imitator does not add answers. It asks again at the same uncertain states on every run, and nothing bounds its asks over a deployment.
* *If the deployed imitator does add the answers,* it is not frozen. No result in the note then gives a PAC guarantee: Corollary 3 is for SI with a frozen imitator, and adding data can change the decoder's runs either way.
* *E6 shows the size of the problem.* There, almost all of K is problem-specific, and SI-V-ABC asks about 2.2, 2.8 and 3.2 times *per problem* at α = 0.3 for n₀ = 8, 32 and 128 (4.3, 7.1 and 8.7 at α = 0.1). A deployed asker would pay that on every new problem.

**Fix.**
* *Replace the note with:* "A frozen imitator must abstain at unconfident steps, which costs the factor of about 1/α of Section 9. An imitator that keeps asking and learns from the answers stays within the budget, but no PAC theorem for that version is proved here."
* *Answer 1 and Section 7* should then state that the recommended scheme without a verifier has an online guarantee (Proposition 5(b)), and no i.i.d. or deployment guarantee beyond Corollary 3 for plain SI.

---

## B. Overclaims and inconsistencies

### B1. "Makes fooled humans flat" and "removes the fooled humans' growth" (Answer 8; Section 6 reading)

**What the numbers say.**

| fooled humans | n₀ = 8 | 32 | 128 |
|---|---|---|---|
| SI-V-ABC, α = 0.3 (total queries) | 236 | 318 | 360 |
| of which search queries | 14.4 | 33.9 | 41.8 |
| SI-V | 181 | 750 | 2,636 |
| noticing humans under SI-V-ABC, α = 0.3 | 223 | 285 | 319 |

* *Not flat.* The total grows by 53% over a 16-fold increase in n₀, and the fooled-specific search part triples (14 → 34 → 42). The asks also grow, like log n₀, for every kind.
* *At n₀ = 8,* SI-V-ABC costs fooled humans *more* than SI-V (236 against 181). The note does not say so.

**The mechanism is a class artifact** (`referee5_abc_mechanism.out`).
* *Every confident wrong commitment occurs at t_p = n₀ − 1* (44, 19 and 6 cases out of 44, 19 and 6). By then asks have ruled out every other idea time, and the decoder commits the default value with mass exactly 0.9. Before the end of the horizon, the asks always fire first.
* *So the cost stays roughly constant.* Rejections occur at about 0.1/n₀ per problem (observed: 1.1, 0.475 and 0.15 per 100 problems), and each one costs a search of about n = 2n₀. That product does not grow with n₀.
* *Proposition 5 predicts no such thing.* For a fooled human its bound is (K/log₂(1/α))·n search queries, which grows with n, as Section 5 says ("single-mistake runs found at rate 1/n").
* *The note already applies this caveat to SI* ("nothing in the theorem gives this"), but not to SI-V-ABC.

**Fix.**
* *Answer 8:* "Adding ask-before-committing (α = 0.3) makes fooled humans grow much more slowly: 240 → 320 → 360, against 180 → 750 → 2,600 with the verifier alone."
* *Section 6:* add "In this class, the only confident wrong commitment comes when t_p is the last possible step, so rejections fall like 1/n₀. Nothing in Proposition 5 gives this."

### B2. Cost with a verifier omits the asks (Answer 2, Section 7 table)

* *Answer 2* says "With a verifier (Propositions 4 and 5): … the expected number of task queries is at most min{n, (D+1)n/(σ+1)}·K". For SI-V-ABC, Proposition 5(c) bounds only the *search* queries. The asks, up to K/log₂(1/(1−α)), are task queries too: in E6 they are 94–100% of SI-V-ABC's cost for bounded-setback humans.
* *The Section 7 row* "+ a verifier (Propositions 4 and 5)" says "≤ n·K task queries in the worst case". Section 4's "What does not move" correctly says "n₀K/(1−ρ) task queries plus 0.69K/α asks".

**Fix.** Add "plus at most K/log₂(1/(1−α)) ≈ 0.69K/α asks with ask-before-committing" in both places.

### B3. Ask-before-committing with a verifier is recommended without the trade-off (Answer 1, Section 7)

**With a verifier, asking changes only the cost.**
* *SI-V* needs at most min{n, (D+1)n/(σ+1)}·K search queries.
* *SI-V-ABC* divides the search part by log₂(1/α) and adds up to 0.69K/α asks. The asks pay off only if failures with unbounded setback (confident or fooled commissions) would otherwise dominate the searches.

**In E6** SI-V-ABC costs bounded-setback humans 6–18 times as much as SI-V at n₀ = 8 (223–236 against 13–38), and 23 times as much at n₀ = 128 (319 against 14). It is cheaper only for fooled humans with n₀ ≥ 32.

**Fix.** State the trade-off in Answer 1 and in the "+ a verifier" row: "With a verifier, add asks only if unbounded-setback commissions are expected to be common; otherwise SI-V alone is cheaper."

### B4. Remark 1: "Slack replaces its factor n₀ by (D+1)/ρ when D < σ"

**The problem.** The factor is min{n, (D+1)n/(σ+1)}. It beats chained imitation's n₀ only when (D+1)n/(σ+1) < n₀, that is, D + 1 < (1−ρ)(σ+1), which is about D < σ/2 for ρ = ½. For D between about σ/2 and σ, the guarantee is *worse* than chained imitation's. `referee5_theory_checks.out`, Part 3: at n₀ = 8 and D = 4, the factor is 8.9 against 8.

**Fix.** "… by (D+1)n/(σ+1) ≈ (D+1)/ρ, which is a gain over chained imitation only when D + 1 < (1−ρ)(σ+1)."

### B5. "Thread E showed that these include most of the imitator's commissions" (Answer 4)

Thread E *argued* this from thread C's Proposition 2. Section 4 of the note itself says that proposition is exact only for product posteriors and a heuristic otherwise.

**Fix.** "showed" → "argued".

### B6. "The theorems, which two independent checks found correct" (Section 4, "What does not move")

Referee 4 and thread E checked Lemma S, Theorem 2, Corollary 3 and Proposition 4. Proposition 5 is new: thread E gave only a sketch, and the author checked it. The same sentence relies on Proposition 5 for "plus 0.69K/α asks".

**Fix.** "Lemma S, Theorem 2, Corollary 3 and Proposition 4, which two independent checks found correct, and Proposition 5 (checked in [this report])".

### B7. Asks are "a lifetime budget", but in E6 they are a per-problem cost

The note reads the 220–320 queries as "the price of asking at every uncertain step". The bound is a lifetime budget in units of K. In E6, though, K is almost all problem-specific (100 independent (t_p, k_p)), so the asks come to about 2–3 per problem and never amortize. Whether ask-before-committing is cheap in practice depends on how much of K(human) is problem-specific, the same question as in Section 5.

**Fix.** Say so in the Section 6 reading and in the Cost note on Proposition 5.

---

## C. Experiment E6

### C1. Re-run: exact reproduction (`referee5_rerun.out`)

* *SI-V-ABC:* all 20 cells at n = 16 and 64, α ∈ {0.1, 0.3}, five kinds and 40 humans. They match `results/slack_imitation_verifier_abc.json` in task_mean, task_sem, asked_mean and rejected_mean.
* *Same-humans CI:* all 10 cells at n = 16 and 64 (n₀ = 8, 32). They match `results/slack_imitation_same.json` in every field, including the median, final failure and hits. The seeds give the same (t_p, k_p) as the slack cells, so these really are the same humans.
* *The table:* `table()` run on copies of the saved JSON files reproduces `results/slack_imitation_table.md` byte for byte, and all 40 of its data rows appear verbatim in the note.
* *Not re-run:* n = 256, which uses the same code path.

### C2. The code against Protocol SI-V-ABC

`run_abc` and `one_human_verifier_abc` implement the protocol as described:
* *asks:* μ is computed under all data so far, including this run's asks; an ask happens iff μ < 1 − α; its answer is added at once and appended;
* *otherwise* the decoder's label is committed;
* *V* is the exact success predicate;
* *on a rejection,* independent uniform queries on the fixed run continue until one lands on a committed mistake; the hit's answer goes first, then the others, then the run is rebuilt with asks;
* *every ask and every search query is counted;*
* *my instrumented replay* reproduces `one_human_verifier_abc`'s (queries, asks, rejections) exactly for all 1,000 humans it covers.

Points worth knowing:
* *Search samples all n steps, asked ones included.* Asked steps can never be hits, so sampling only committed steps would replace n by n − |A|. This is allowed by the protocol's wording, but wasteful.
* *The α = 0.1 results for fooled, misled-8 and silent humans rest on a tie.* The only confident wrong commitment has μ = 0.9 = 1 − α exactly (C5). The code commits on the tie, as the protocol's strict "<" says, with a 10⁻¹² tolerance. For any α slightly below 0.1 the decoder would ask instead, and these kinds would have no rejections at all.
* *Rounding.* The table prints the n = 256 rejection rate 0.15 as "0.1", because `.1f` rounds the binary 0.1499…. Use two decimals.

### C3. Proposition 5's proof steps on the runs E6 makes (`referee5_abc_checks.out`)

On n = 16, 32 (40 humans each) and 64 (20 humans), α ∈ {0.1, 0.3} and all five kinds: 116,612 runs, 327,327 asks, 78,720 committed mistakes and 16,612 rejections.
* *Committed steps:* every one has μ ≥ 1 − α under D ∪ A_{<k}.
* *Asks:* every one has ξ(P) < 1 − α. The smallest ratio of an ask's bits to log₂(1/(1−α)) is 1.05.
* *Committed mistakes:* every one has ξ(P) ≤ α, with equality at α = 0.1, so the bound is tight.
* *Rounds:* every round that ends in a hit pays at least [bits of A_{<k}] + log₂(1/α), with equality in some rounds at α = 0.1.
* *Per human:* asks reach at most 0.37 of K/log₂(1/(1−α)), and rejections stay far below K/log₂(1/α). K per human is 325–569 bits.
* *Setbacks:*
  * on bounded-setback humans, committed omissions have setback ≤ 0 and committed commissions ≤ 0, 2 and 8, as claimed;
  * there are no overwrites of a correct value, and no run reaches S and then loses it;
  * (T1) holds at every asked step;
  * every failed run satisfies Lemma S with asked steps counted as correct. Noticing humans have exactly σ+1 committed mistakes per failed run, so Lemma S is tight;
  * (B_D) fails only for silent humans, as expected.

  So referee 4's run-level setback check, which the note cites, also holds on the runs SI-V-ABC makes.
* *Rejected problems:* only k_p = 2 problems are rejected for the persistent kinds, as the note says for SI-V.

### C4. Numbers quoted in the note against the saved outputs

| claim | saved value | status |
|---|---|---|
| CI without slack, same humans, bounded kinds: 2,900 → 12,700 → 51,300 | 2,915–2,919 → 12,724 → 51,340–51,365 | correct (51,365 would round to 51,400) |
| SI: 160–490 → 200–230 → about 205; fooled 1,600 → 2,800 → 4,300 | 160–485 → 204–227 → 204–205; 1,631 → 2,811 → 4,296 | correct |
| silent: 2,249 → 4,467; "twice" | ratios 1.99, 2.02, 1.97 | correct |
| gains 18× → 62× → 250× | 18.3, 62.4, 252.3 | correct |
| misled-8 at n₀ = 8: 485, σ = D | 484.85 | correct |
| SI-V: 13–16 (38 for misled-8 at n₀ = 8) | 12.75–15.53; 38.42 | correct |
| rejected run: about n (silent); 0.56n–0.77n (fooled) | 16.1, 64.5, 261; 0.77n, 0.61n, 0.56n | correct |
| SI-V-ABC α = 0.3, fooled: 236 → 318 → 360, "almost no rejections" | 235.65 → 317.90 → 360.27; 1.1, 0.475, 0.15 per human | numbers correct; "flat" and "removes growth" overclaim (B1) |
| bounded kinds with asks: 220–320 instead of 14 | 222.9–319 | correct |
| α = 0.1: 430–870 | 434–874 | correct |
| silent: no asks at n₀ ≥ 32; at n₀ = 8, α = 0.1, every step asked | 0 asks; 447 against 1,610 | correct |
| LAST stalls at 10% and 100%; MIX about twice SI on the others | 9.7–10.4%, 100%; 1.75–2.5× | correct |

### C5. Why fooled humans' cost under SI-V-ABC barely grows (`referee5_abc_mechanism.out`)

**Where the commitment happens.** In E6's prior, t_p is uniform on [0, n₀). On an empty notebook at step j, the masses are:
* "nothing": Pr[t > j];
* value 1: 0.9·Pr[t ≤ j];
* value 2: 0.1·Pr[t ≤ j].

As j advances, the mass of "nothing" falls below 1 − α before the mass of value 1 rises above it, so the decoder asks. Each "nothing" answer leaves a uniform posterior on the remaining steps. The value 1 is committed without an ask only when a single idea time is left, which is necessarily n₀ − 1, where it has mass 0.9.

**What follows.**
* *For both α:* every committed wrong value in the fooled cells is at t_p = n₀ − 1, with one possible idea time left (69 of 69 cases at α = 0.3, and the same at α = 0.1).
* *The costs:* rejections occur at about 0.1/n₀ per problem, and each one costs a search of about 2n₀, so the search part is roughly constant in n₀.

**Fix.** The reading should say that this flattening comes from E6's prior (B1). A class with confident problem-specific deviations away from the horizon's end would show the growth that Section 5 predicts.

### C6. SI-ABC without a verifier, the recommended scheme, is not tested (`referee5_si_abc_online.out`)

**Why I ran it.** Answer 1 and Section 7 recommend SI-ABC where no verifier is available, but E6 tests ask-before-committing only with a verifier.

**Why with a fixed number of rounds.** E6's oracle stopping rule is not meaningful for SI-ABC. The run whose failure it measures itself asks the human, so an untrained imitator already passes if those asks are free. I found this in a first attempt and discarded it.

**Results.** The same humans, seeds and problem draws as E6's SI cells, over 3,000 rounds (about 30 visits per problem). The first column is the number of failed runs during learning, the quantity Proposition 5(b) bounds.

| n | human | SI: failed runs | SI-ABC α = 0.3: failed runs / asks | SI-ABC α = 0.1: failed runs / asks |
|---|---|---|---|---|
| 16 | noticing | 12.5 | 1.7 / 304 | 1.7 / 432 |
| 16 | misled-2 | 14.4 | 2.3 / 304 | 2.3 / 432 |
| 16 | misled-8 | 42.8 | 14.4 / 304 | 14.4 / 432 |
| 16 | fooled | 104.0 | 14.4 / 304 | 14.4 / 432 |
| 16 | silent | 1,319.7 | 1,017.5 / 61 | 14.4 / 432 |
| 64 | noticing | 14.8 | 0.8 / 517 | 0.8 / 800 |
| 64 | misled-8 | 16.5 | 0.9 / 517 | 0.9 / 800 |
| 64 | fooled | 136.2 | 8.8 / 517 | 8.8 / 800 |

**What it shows.**
* *Fewer failures.* SI-ABC cuts failed runs by 3–18 times (7–16 times for fooled humans) at the price of about 3–8 asks per problem.
* *More asks than with a verifier.* The online protocol asks more than SI-V-ABC does (304 against 221 at n = 16, and 517 against 284 at n = 64), because uniform queries reshape the posterior and create new uncertain steps. All counts are within (a)'s bound.
* *Silent humans.* Asking helps only where every step is uncertain (n₀ = 8, α = 0.1).

**Fix.** A table like this would support the recommendation directly. Report SI-ABC online failures and asks, not an oracle-stopped cost.

---

## D. Minor points

1. **Define M_t for SI-ABC.** It is the set of committed steps whose appended label differs from P(x′_k). The decoder that matters is the one in use at that step, G_{D_t ∪ A_{<k}}, not a single "G" as in Section 1. The proof uses this definition implicitly.
2. **α ≤ ½ is unnecessary.**
   * Every step of the proof holds for α ∈ (0, 1). For α > ½, K/log₂(1/α) exceeds K, and Lemma 1's ⌊K⌋ is better, since a decoder mistake always has ξ(P) ≤ ½.
   * The clean statement is K/max{1, log₂(1/α)}.
   * `referee5_theory_checks.out`, Part 4, includes α = 0.7: no violation.
   * Either drop the hypothesis or say it only makes the bound improve on Theorem 2's.
3. **"0.69K/α" versus ln 2.** K/log₂(1/(1−α)) ≤ (ln 2)K/α for every α, but 0.69 < ln 2. So "bounded by 0.69K/α" (Answer 7) fails for α < 0.009, for example 692.8K against 690K at α = 0.001. Write "≤ (ln 2)·K/α ≈ 0.69K/α".
4. **Answer 2, Proposition 5 bullet.** "Failed runs are at most …" should be "the expected number of failed runs is at most …", as in the slack bullet above it.
5. **Answer 2, i.i.d. bullet.** "Chained imitation needs n·K/ε" should be n₀K/ε, as in the Section 7 table, since n here means n₀ + σ.
6. **(b) cites the proof of Theorem 1, not its statement.** Section 1 states Theorem 1 for one task query per round on a fixed decoder's run, with bound ⌊K⌋. Proposition 5's proof gives the needed variant itself; say "by the argument of Theorem 1".
7. **Remark 3.**
   * *The wrong design is a mistake.* "Can be read out wrongly with no mistake anywhere" holds only if the human's *own* chain writes the plausible wrong design, for example its own "v2" during the slack. Then the reference chain itself fails. When the imitator writes it, that is a commission, but S still holds, so Lemma S does not multiply it, and it is charged at the 1/n rate. Say this instead.
   * *With the check,* runs that fail it need the flip query, not the read-out query.
8. **`robust-runs.md` is never named or linked.** The note says "the third note" (Answer 9, Section 3). The response (B5) says "the note now cites `robust-runs.md`". Link it at the first mention.
9. **Oracle stopping.** The response (C7) says Proposition 4's notes state that E6's SI uses an oracle stopping rule. The statement is in Section 6 (Measurement), not in those notes. Answer 8 still compares SI's 160–490 with SI-V's 13–16 without saying so, which was referee 4's D11. Add "(oracle stopping)" to Answer 8's SI line.
10. **SI-V-ABC search.** Note that sampling only committed steps is allowed and cheaper (C2).
11. **The "≥ 5×" row of the probability table.** Its thread E entry, 50%, is thread E's figure *with* ask-before-committing, while version 1's 75% was without it. Carry "(with ask-before-committing)" over from the row above.

---

## Appendix 1: the response file, item by item

| item | claimed fix | present in v2? | correct? |
|---|---|---|---|
| A1 read-out (R) | Remark 3 states (R), the counterexample, slack makes it harder | yes | yes (wording, D7) |
| A2 confident/unconfident | Section 4 opens with the axis; "two optimizations" removed | yes | yes |
| A3 fallback | Answer 7, Remark 2: n₀K/(1−ρ); Theorem 2 min; Lemma S max; factor 2 in E6 | yes | yes |
| B1 | confidence axis, "plurality", paraphrase in (B-commit) | yes | yes |
| B2 | in the model by definition; stated deadlines only; dates stripped; Remark 4 | yes | yes |
| B3 | hedges as a second exception, with V5 | yes | yes |
| B4 | "How learner-relative this is"; table rows | yes | yes |
| B5 | thread C Corollary; third note's Theorem 1 and answer 4 | yes | `robust-runs.md` is not named or linked (D8) |
| B6 | restricted to unpredictable insights; enlarged defect | yes | yes |
| B7 | graded probabilities, 75% replaced, link | yes | "two independent checks" now also covers Proposition 5 (B6) |
| B8 | "O(K) for fixed ε, δ, D, ρ" | yes | no: O(K log K) (A1) |
| B9, B10, B11 | ancestors; check cost; located probes, (K+1)(c+1), class-prior | yes | yes |
| C2 | tie-breaking, silent never corrects, generosity, never missing; docstring | yes | yes |
| C3 | `--same` mode, numbers, labels | yes | yes; reproduced (C1) |
| C4, C5 | setbacks on the decoder's runs; S not append-preserved | yes | yes; also holds on SI-V-ABC runs (C3) |
| C6 | 142; about n and 0.56n–0.77n; 38 | yes | yes |
| C7 | uncounted oracle; verified problems only; oracle stopping | partly | oracle stopping is in Section 6, not Proposition 4's notes; missing from Answer 8 (D9) |
| C8 | `setback_check.py` as an arithmetic check | yes (note, README) | yes |
| D1–D8, D10–D12 | as listed | yes | yes |
| Red team | proof gaps; Proposition 2 reading; V2, V3, V4, V5, V9, V12, V14, V15; graded reading; design law; SI-ABC as Proposition 5; Section 5; probabilities; Section 8 premises | yes | yes, except "removes the fooled humans' growth" (B1) |

## Appendix 2: commands run

```
cd verification
python3 referee5_rerun.py <scratch dir>     # 20 SI-V-ABC + 10 same-humans cells, all MATCH; table identical (91 s)
python3 referee5_abc_checks.py              # 116,612 instrumented runs, no violation (96 s)
python3 referee5_abc_mechanism.py           # fooled: every wrong commitment at t_p = n0 - 1
python3 referee5_si_abc_online.py           # SI vs SI-ABC online, 3,000 rounds (290 s)
python3 referee5_theory_checks.py           # arithmetic; random classes with a check
```

The scripts import `code/slack_imitation.py` with bytecode writing disabled, and write nothing under `code/` or `results/`.
