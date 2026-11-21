# Referee report on `verified-slack.md`, final pass (the fifth note, "Verified slack imitation")

*Referee 8, an independent AI referee (Claude). 21 November 2026. I read the note as it now stands against:*
* *the response file (its "Referee 7" section item by item) and referee 7's report;*
* *`slack-imitation.md` §2–3 (the check, (M1), (M2), (M-prefix), Lemma S, Proposition 5);*
* *thread R (`research/threadR-compose.md`, `threadR_compose.out`, `.json` and `.py`);*
* *thread T (`research/threadT-formal.md`), thread S §7, and thread L §1 for Answer 7.*

*I did not read `research/threadU_*`.*

*Scripts and outputs (all in `verification/`):*
* [`referee8_e7_default.py`](referee8_e7_default.py) → [`referee8_e7_default.out`](referee8_e7_default.out). It re-runs E7's VSI column with thread R's own code, humans and seeds, under three settings: thread R's equal round robin (which reproduces all 27 published cells exactly), the note's schedule S, U, S, H with thread R's list, and S, U, S, H with the list H exactly as §2.3 defines it. It also records the largest single search against 2n₀ − 1 and the position of the first mistake. It writes nothing into `research/`.
* [`referee8_theory.py`](referee8_theory.py) → [`referee8_theory.out`](referee8_theory.out). The script has four parts:
  * Part 1: Lemma 3 on every periodic schedule of period 4 with frequencies (½, ¼, ¼), and on one of period 8.
  * Part 2: (A4′) stated on notebooks, against the output rule "first passing claim".
  * Part 3: an exact-Bayes toy of a formalizer inside V that fails on the human's own blueprint.
  * Part 4: the effort arithmetic for the resulting abstentions, thread T's statement-writing cap, and thread T's products.

## Verdict

**Nearly final. Referee 7's fixes are all present, and all but two minor ones are complete. Theorem 5 is right in substance, but two statements need repair:**
* **(A4′) is stated on notebooks, so it no longer implies that the *output artifact* is correct.** Referee 7's B6 fix made the output the first passing claim, which opened this gap (A1).
* **Lemma 3's claim for "a fixed periodic schedule" is false in general.** It is true for the default S, U, S, H, the only schedule Theorem 5 uses (A2).

**Every E7 number matches thread R. But E7's VSI is not §2.3's protocol, in a way the note does not state.** Its list holds verdict and claim entries, which stand in for a perfect post-mortem. With §2.3's own list and the default schedule, VSI on M2 and M8 grows with n₀: to 1,442 and 2,350 task queries at n₀ = 128, against E7's 54 and 31 (B4).

**Thread T is integrated in the right direction, with three gaps:**
* the formalizer inside V is under-specified against Theorem 5's assumptions (B1, B2);
* the statement-defect rule is misplaced (B3);
* several 2026 facts that rest on search summaries are used without saying so (B5).

**None of this touches the headline.** Correctness rests on (A4′) alone, once (A4′) is stated per claim. The 2n₀K worst case holds under (A2) and (A3′).

**What I confirmed.**
* *Theorem 5(a)–(f)* are correct with b = 1 or b_α as now defined, apart from the artifact gap A1:
  * the hit-value argument, including audits and the flips of failed checks;
  * the bound "asks K/log₂(1/(1−α))";
  * termination, given (M1) as well as (M2) (D1);
  * the default-schedule constants 2j − 1, 4k − 2 and 4i;
  * the per-rejection bounds 2n₀ − 1 (surely), 4Λ, 4, 4(1 + d) and 4(1 + d + i);
  * the abstention costs 2n and n;
  * the hypotheses of (f).
* *Lemmas 1, 2 and 4* are correct.
* *The sure bound and Lemma 1 in E7's classes.* Under S, U, S, H, with either list, no search in any of E7's 27 classes exceeded 2n₀ − 1, and every first mistake lay below n₀ (`referee8_e7_default.out`).
* *E7's table* matches thread R in all 96 cells. So do the 1.2–1.4×, the 5–35×, the 0.8n₀ and the 120 of 120 reproduced numbers (but see C1 and C2 for what two of these ratios measure).
* *EQ's default-schedule figures* (53 → 73 → 72; 559 → 2,103 → 8,238; 2.3×; 25–44 against 13–38) match `referee7_eq_default.out`.
* *Thread T's own arithmetic* reproduces: 0.590, 0.726 and 0.771, and effort factors 0.761 and 0.834.
* *The §7 table* matches thread S §7 cell for cell. Answer 7's "30–60%" matches thread L §1.

---

## A. Errors

**A1. (A4′) is stated on notebooks, so it does not give a correct output once the output is "the first passing claim". Theorem 5(a) and the first sentence of 5(f) fail as written.**
* *Where.*
  * (A4′): "On the final notebooks of the imitator's runs, S_V implies S\*."
  * 5(a): "under (A4′) it [every output] satisfies S\*."
  * 5(f): "The failed outputs are exactly the accepted runs that fail S\*."
  * §2.3 step 2 outputs "the first [claimed solution] that passes".
* *The gap.* S_V and S\* are predicates on notebooks, but the output is one claim. A final notebook can satisfy S\* because of a later correct claim while the first passing claim is wrong. Then (A4′) holds, V accepts, and the output is wrong. For V-machine this cannot happen, since a kernel-checked proof of a faithful statement is correct claim by claim. It can happen for V-human and V-cone, for example when the human's own chain writes a flawed v1 and later a corrected v2, and the verifier passes v1.
* *Counterexample* (`referee8_theory.out`, Part 2).
  * *The setup.* Take the class {P}, so K = 0. P writes c1 (wrong, but V passes it), then c2 (correct).
  * *What happens.* Notebook-level (A4′) holds on every run, and every accepted run satisfies S\*, yet all 10 outputs are wrong.
  * *Against 5(f).* There are 10 wrong outputs against its bound of 0, and no "accepted run fails S\*".
* *Fix.*
  * State (A4′) per claim: "every claimed solution that V passes, in the final notebooks of the imitator's runs, satisfies the goal." Then 5(a) is immediate.
  * In 5(f), use S\*(x) = "the first claim in x that V passes satisfies the goal". This is preserved by appending when V's verdict on a claim depends only on the claim and what precedes it. τ\*(x₀) ≤ n₀ then also says that the human's own chain writes no V-passing wrong claim before its correct one.
  * Note in §6 that for V-human this asks the verifier to reject claims that the human itself later retracts.

**A2. Lemma 3's displayed bound does not hold for every periodic schedule with frequencies w_i, and the proof's reason is off by one.**
* *Where.* Lemma 3: "streams served by a fixed periodic schedule in which stream i has frequency w_i … E[queries] ≤ min{(n/|M|)/w_U, (j_S+1)/w_S, (j_H+1)/w_H}." The proof says: "A periodic schedule with frequencies w_i serves stream i for the j-th time by position (j+1)/w_i, since its discrepancy is bounded."
* *Counterexamples* (Part 1). Two of the twelve period-4 schedules with frequencies (½, ¼, ¼), H, U, S, S and U, H, S, S, break the displayed bound.
  * Take a single mistake at scan position 0 (j_S = 0) and an adversarial list. Then E[queries] = 2.97–2.98, against the claimed (0+1)/w_S = 2.
  * The period-8 schedule U, U, H, H, S, S, S, S has the same frequencies and gives 4.89. It also breaks the proof's own sentence: S's first service comes at query 5, after (1+1)/½ = 4.
* *Why.*
  * Bounded discrepancy gives only k/w_i + O(period).
  * The displayed bound needs the (j_i+1)-th service by (j_i+1)/w_i, which the proof's "(j+1)/w_i" does not give.
  * What is needed is that each stream is served k times by position ⌈k/w_i⌉ from the start, that is, c_i(t) ≥ ⌊w_i t⌋ for all t. Ten of the twelve period-4 orders have this property, S, U, S, H among them. Of those ten, only S, U, S, H, S, H, S, U, S, S, H, U and S, S, U, H also give the scan bound 2n₀ − 1, not 2n₀.
* *Effect.* None on Theorem 5, which uses only S, U, S, H, whose constants the note states correctly. With the scan skipping steps already queried, or with H exhausted, the positions only move earlier, so "exact" there means "at most".
* *Fix.* State Lemma 3 for schedules with c_i(t) ≥ ⌊w_i t⌋, and give the reason in the proof. Or state it for S, U, S, H only. For a general periodic schedule of period p, add + p to each term.

---

## B. Overclaims and inconsistencies

**B1. The formalizer inside V: what (A2) and (A3′) now require, and what "a formalizer failure becomes an abstention" costs.**
* *What completeness requires.* With V = "an AI formalizer F, within budget B, produces a kernel-accepted proof of the fixed statement", (A2) and (A3′) need three things:
  * F is deterministic: a fixed seed, a pinned model and a pinned toolchain. Otherwise V is not a function of the notebook.
  * F's verdict on a claim depends only on that claim and what precedes it, or on its cited cone. Otherwise appending can change it, and S_V is not preserved.
  * F succeeds, within B, on the human's own blueprint by step n₀, on every problem.

  Thread T §5.3(4) states the first two ("fixed seed … S_V stays preserved by appending"). §2.1 states none of them.
* *How often it fails.* Thread T puts F's false-rejection rate on correct human blueprints at about 5–30% by field (§5.1). On those problems (A2) fails, and with it (A3′) and Lemma 1.
* *What a failure costs.* The note's sentence is right for correctness: no formalizer failure becomes an output. But each one costs a full scan. Rejected runs are searched (any hits are real mistakes, so they are valid). The problem ends only when a run is the human's own chain, and that last search must scan every committed step.
  * In Part 3 (exact Bayes, E6 humans, S, U, S, H, the abstain rule), every abstaining search cost exactly n = 2n₀ distinct task queries with caching, and 2.3n₀ without. That is twice the human's own chain, for a problem left unsolved.
  * At φ = 0.1, noticing humans' total for 100 problems rises from 29–32 queries to 231 → 1,079 → 4,471 (cached, n₀ = 8 → 32 → 128).
  * The same holds for the fail-safe half of misformalizations (§6): a false statement costs an abstention at about 2n₀.
* *Effect on "works"* (Part 4).
  * Abstentions at rate φ add about 2n₀·φ·T task queries, which grow with T. Against the one-fifth bar, VSI then fits only for T ≤ K/φ, which is 20K at φ = 0.05 and 3.3K at φ = 0.3.
  * Together with the human-does-it baseline (T > 2K/(1 − 2φ)), no window remains once φ ≥ ¼. That is within thread T's 5–30%.
  * Thread T's own 75–78% does not assume abstention. Its §5.3(4) falls back to the human formalizing ("rather than abstaining"), and its effort factor 0.82 is "less a little for fallback formalizations by the human".
* *Fix.*
  * In §2.1, state the three requirements, and say that a false rejection of the human's blueprint is an (A2) violation.
  * Either adopt thread T's fallback and count its cost, or keep abstention and say that each one costs about n task queries. In the second case, tie the 75% to a low false-rejection rate.
  * In Theorem 5(d) and (e), and in §6's (A2) paragraph, list formalizer false rejections next to heavy tails as a source of (A2) failures.
  * Add F's false-rejection rate to §10 (thread T §5.4).

**B2. The formalizer is an optimizer, and §5 and §6 do not say what that changes.**
* *What §5 says.* "VSI does not optimize against V" rests on the decoder being deterministic given the data. With F inside V, a search for *any* accepted proof runs inside V, against the statement and the checker, which is exactly where soundness lives. The consequences:
  * Loopholes of a weaker statement are hunted actively, not merely selected. Thread T raises the exploitation rate x from 0.3–0.5 (imitator) to 0.5–0.9.
  * Checker exploits become reachable.
  * Each re-verification under a new seed is a fresh search. Fixed seeds and §5's cached verdicts close this.
  * §5's enrichment bound of log₂(1 + R_p) bits per problem does not cover F's internal search, whose size is set by B.
* *What follows.* §5's "With V-machine on a formally stated goal, none of this matters for correctness" is true of the imitator's selection. With F inside V, the rate at which (A4′) failures are exploited goes up.
* *Missing figures in §6.* §6 quotes only the in-chain contributions (0.5–1% with review, "up to 5%" without). Thread T §1.3 gives 0.7–1.3% and 5–9% for the formalizer inside V.
* *The wording "only on the statement and the kernel" (§2.1).* It should be "the statement and the checking pipeline". Thread T §3 calls statement substitution and environment tampering "the commoner exploit", and with F inside V the pipeline must check F's artifact against the fixed statement.
* *What is verified.* The verified artifact is F's formal proof, not the human-style blueprint. The blueprint can be wrong even when the proof is accepted, if F proved the statement another way.
* *Fix.* Add a bullet "The formalizer inside V" to §5's "What happens anyway", with the four points above. Give thread T's formalizer-in-V figures in §6. Reword §2.1 as above, and say that the output is the formal proof.

**B3. The statement-defect rule in §2.1 is misplaced, and it is not part of the protocol.**
* *The text.* "If an accepted proof reveals a defect in the statement … halt the problem; do not rerun."
* *Why it does not work.* After acceptance the protocol outputs, so "do not rerun" does nothing. And nothing in the protocol reveals a defect. Thread T has two different rules:
  * §5.3(2): a STATEMENT-DEFECT entry in *any* run, rejected runs included, halts the problem for review. "Otherwise rerun-until-accepted selects *against* the runs that noticed the loophole."
  * §5.3(3): an anomaly trigger at acceptance routes a proof that is far shorter or faster than expected, or that bypasses the blueprint's milestones, to statement review *before output*.

  Neither is in §2.3, and Theorem 5(c) knows only "an output or an abstention".
* *Fix.*
  * Put both rules in §2.3. The STATEMENT-DEFECT entry belongs in the instruction, so the human's own chain writes it too, as the design law requires.
  * Add "a halt for statement review" to 5(c)'s outcomes.
  * If the rules are left out, say that thread T's 75–78% assumed them.

**B4. E7's VSI is not §2.3's VSI in a second way: its list holds verdict and claim entries, which stand in for a perfect post-mortem. Without them, M2 and M8 are not flat.**
* *What thread R's list holds* (`threadR_compose.py`, `pointer_list`):
  * E6's value entries (verdicts), for M1–M3;
  * the G insight entry, for M4 and M5;
  * F1's claim and obstruction-record entries, for M7 and M8;
  * HEDGE's decision and its A entry, for M6.

  §2.3's H holds only the last review step, the labelled decisions and the second researcher's post-mortem entries. So on M2 and M8 the pointer exists only if a post-mortem names the verdict or the obstruction record. The note states the equal weights, but not this.
* *The re-run* (`referee8_e7_default.out`; same humans, seeds and code; mean task queries for 100 problems, n₀ = 8 → 32 → 128, or N for M4 and M5):

  | mechanism | E7 (equal weights, thread R's list) | S, U, S, H, thread R's list | S, U, S, H, §2.3's H (no post-mortems) |
  |---|---|---|---|
  | M1 | 15 → 20 → 20 | 25 → 32 → 32 | 26 → 32 → 32 |
  | M2 | 40 → 55 → 54 | 53 → 73 → 72 | **89 → 427 → 1,442** |
  | M3 | 663 → 2,497 → 9,734 | 559 → 2,103 → 8,238 | the same |
  | M4 | 122 → 129 → 137 | 158 → 174 → 187 | the same |
  | M5 | 424 → 1,528 → 6,246 | 355 → 1,301 → 5,316 | the same |
  | M6 | 24 → 29 → 31 | 34 → 39 → 41 | the same |
  | M7 | 10 → 11 → 10 | the same | the same |
  | M8 | 34 → 33 → 31 | 45 → 46 → 42 | **51 → 452 → 2,350** |

* *Reading.*
  * With the default schedule, every mechanism costs 1.3–1.6× E7 except M3 and M5 (0.84×) and M7.
  * Without post-mortems, M2 and M8 grow roughly in proportion to n₀, at about 0.5–0.7n₀ per rejection, though still within the sure 2n₀. On M8 the rejections also rise, from 15 at n₀ = 8 to 35 at n₀ = 128, where E7 has 13 and 11. That is still below SI-V's 2,636 and 2,868.
  * So "M8: only the verifier's pointer" means only *a perfect post-mortem* pointer with a verifier. This is §4's "hindsight", and it is exactly what Theorem F3 says one needs.
  * M6's decision step is in §2.3's H, so M6 is genuinely covered.
* *Fix.*
  * In §8, say that thread R's list adds verdict and claim entries as a stand-in for a perfect second-researcher post-mortem.
  * Sharpen the caveat. M6's pointer is in the protocol. M2's and M8's exist only through post-mortems. Without them VSI costs 89 → 427 → 1,442 and 51 → 452 → 2,350.
  * Better, add the default-schedule column.

**B5. Thread T's 2026 facts: sourcing and strength.**
* *Facts that rest only on search summaries* (thread T's [S]), used in §6 and §7 without saying so:
  * the Aletheia figure "50 of 63";
  * "several Lean and Rocq soundness bugs in 2026", all [S];
  * the upper end of "5–60% unfaithful", from Ground False and ProofNet;
  * "about half of misformalizations fail safe", from Ground False;
  * the sphere-packing timings.

  §7's parenthesis covers only FLT and sphere packing, and FLT is in fact [F].
* *Aletheia does not show what the note says it shows.* "Rerunning until accepted hunts for the weaker statement's loophole: in one AI run on Erdős problems …" But Aletheia is an optimizing prover on *informal* transcriptions of Erdős problems (thread T §1.1, "informal"). It shows that an optimizer exploits misreadings. It does not show that an imitator's rerun-until-accepted does on formal statements, and thread T gives a faithful imitator a lower x.
* *"Ending the chain with a formal proof has become cheap" (§7).* This is stronger than thread T. Thread T discounts the landmark cases for selection bias ("self-reported successes by well-resourced teams"), and lists counter-signals: 42% of about 720 manuscripts Lean-checked, and 17% on ArXivLean. The cases themselves also qualify the claim:
  * Sphere packing was the *completion* of a human project begun in 2024, the rest of dimension 8 in 5 days and dimension 24 in 2 weeks [S].
  * FLT was done "with occasional human direction", and its source is Anthropic's own announcement.
  * Both formalize decades-polished proofs, not new research.
* *Thread T's own status.* It is an unrefereed draft, and so is thread R. §12 does not say so.
* *Fix.*
  * Add "(search summaries only)" at the Aletheia, kernel-bug and fail-safe sentences.
  * Recast Aletheia: "An optimizing prover does: in DeepMind's Aletheia run on informal Erdős statements …".
  * Replace "has become cheap" with "thread T estimates … for goals already statable", and mention the counter-signals.
  * Mark threads R and T as unrefereed drafts in §12.

**B6. V-human is still "the human's own verification", but §2.2 now asks that every reader of a run be someone else.**
* *Where.* Answer 3 ("with the human's own verification: 40% and 10%"), §2.1 ("the human's verification of the finished result"), Theorem 6 ("Let V_H be the human's verification"), §6 ("The human, checking a finished result") and the §7 table ("the human's soundness").
* *The conflict.* §2.2 says a human verifier "should … be someone other than the imitated human". So either V-human is a second person's verification, or its cost theory carries §2.2's "answers unchanged" assumption. The note says neither in these places.
* *Fix.* Define V-human as a human verifier other than the imitated human, with the imitated human allowed only under the contamination assumption. Reword Answer 3 to "a human verifier's check of the finished result".

**B7. §7's conditioning against its reasons, and how abstentions count in "works".**
* *Referee 7's unanswered point.* Referee 7 noted in its "Sections 5–7: consistency" that "heavy tails" is listed among the reasons for thread S's lower figures, while §7 conditions on "a cold-start chain that succeeds within n₀". The response does not address this, and both sentences are unchanged.
* *What "works" leaves out.* "Works" counts output failures and effort, but says nothing about abstentions. A scheme that abstains often would "work" with no failures and little effort.
* *Why this matters for the formalizer-in-V figure.* If "succeeds within n₀" means reaching S_V, F's success included, then the conditioning assumes away formalizer false rejections, and the 75% does not use thread T's 5–30%. If it means reaching the informal goal, abstentions must be costed (B1).
* *Fix.* Say that heavy tails lower the unconditioned figure. Define "works" to count abstentions, either as failures or as effort at about n per abstention. Say which reading of "succeeds within n₀" the formalizer-in-V figure uses.

**B8. Per-problem human effort for V-machine and V-human is undercounted.**
* *Statement writing and review* (thread T §5.3(6)) is a per-problem cost s, and it caps T at about (4 − 2ι)·n₀K/s. Thread T gives "days per statement" with AI drafting; AnnalsChallenge's pace was about 1.4 person-months each. With n₀ = 30 the cap is about 600–1,200K at the first pace, but only 60–120K at the second (Part 4). Thread T's effort factor includes it ("writing statements"). Theorem 5(e) and §7 do not mention it, and §7's "a factor 2 below the one-fifth bar … with V-machine and no audits" omits it.
* *The ι margin.* §7 does not say that the factor 2 is consumed at ι = 2. Thread T: "ι ≤ 2 is exactly the margin".
* *Verifications per run.* Theorem 5(e) says "one verification per run with a human verifier". Since V now checks claims in order until one passes (referee 7's B6, whose request "count the verifications per run" the response does not take up), it should be one per claim checked.
* *Fix.* Add statement writing to 5(e)'s "Other human effort" and to §7. State the ι ≤ 2 condition. Count verifications per claim.

**B9. "V-machine rests correctness on no human judgment" (§6).**
* *Why it is too strong.* With the statement protocol, (A4′) for V-machine is the fidelity of a statement written by an expert and reviewed. Thread T adds human sign-off on the elaborated statement. That is a judgment, but of the goal and before any run, not of a run's state. So the letter and the spirit of the user's constraint are kept, but "no human judgment" is too strong.
* *Fix.* "V-machine rests correctness on no judgment of the runs; it rests on the fidelity of a statement fixed before any run, which experts and AI audits review."

**B10. §2.1's statement protocol is a subset of the one behind thread T's 4% and 1.5%.**
* *What is missing.* Thread T §5.3(1) also has:
  * a machine-checked equivalence of the two formalizations;
  * audits from different model families;
  * non-vacuity witnesses, aimed at the dangerous weaker case;
  * human sign-off on the elaborated statement.
* *Fix.* List them, or say that the 4% and 1.5% assume them.

---

## C. Numbers

Checked against `threadR_compose.out` and `.json`, `threadT-formal.md`, `threadS-redteam2.md` §7, `referee7_eq_default.out` and my re-runs. Unless listed here, they are correct, including:
* every cell of the E7 table (96 of 96);
* EQ's default-schedule figures;
* §7's probabilities against thread S;
* §6's 22%, 25%, 10%, 4%, 1.5%, 0.5–1%, 99.5% and 5–60%;
* §7's 65%, 80% and 90%;
* §11's 24%, 5–15% and 80 of 161.

**C1. E7, "the last-review query costs doing-only humans (M5) 1.7–2.1×".**
* *What the figure measures.* It is thread R's figure *without a verifier*: SI+D against SI, with 1.70–1.83 in failed runs and 1.9–2.1 in oracle cost.
* *Inside VSI.* Thread R §3.3 says the review entry costs "nothing measurable" there (at most one query per search), and the 424/337 ratio is the scaffold's 1.25.
* *Fix.* Write "without a verifier (SI+D)".

**C2. E7's interference and per-rejection figures are for equal weights.**
* *What the note says.* "VSI's extra streams cost M1 humans 1.2–1.4×", and VSI cuts M3 and M5 "at about 0.8n₀ per rejection".
* *Under the default schedule.* The first becomes 2.0–2.3× (25.4/12.75 to 32.4/14.1), as §8's own EQ bullet already says ("up to 2.3×"). The second becomes 0.64–0.70n₀ (`referee8_e7_default.out`).
* *Fix.* Add "(equal weights)", or quote the default.

**C3. E7, "M2: … or asking without a verifier".**
* *What thread R says.* That help is "E6's artifact (referee 5)": every confident wrong commitment comes at t_p = n₀ − 1. Thread R's Answer 2 says "asking, which E6's prior flatters".
* *Fix.* Add the qualifier.

**C4. §6, "about 25% of statements are unfaithful without independent review, and about 10% have an exploitable weaker form".**
* *What thread T says.* The figures are "for goals needing new definitions". Thread T gives 8% and 3% in vetted Mathlib vocabulary.
* *Fix.* Add the qualifier and the second pair.

**C5. §6, "AI audits still found mistakes in 22%".** Thread T notes that the severity of the 11 mistakes is not given. Since the note uses the figure to support "25% unfaithful", say so.

**C6. Answer 4 and §11, "only 24% of recent Annals main theorems could even be *stated*".**
* *What happened.* The team stated 50 of 207 in 10 months, working *easiest first*, and none of the 74 hardest. Some areas were judged "essentially impossible to state right now".
* *Why "can be stated" overstates.* It reads as a property of the other 76%. What the evidence shows is that they were not stated in that effort.
* *Fix.* "Experts stated 24%, easiest first, in 10 months."

**C7. §7, 65%, 80% and 90%.** Thread T conditions these on "a goal already statable" and on "mathematics, weighted by where goals are statable", and calls them its own estimates. Add both conditions.

**C8. Answer 3, "75% if an AI formalizer sits inside the verifier"; §7, "75–78%".** Thread T's table gives 77%, its Answers 75–78% and its verdict "about 75%". Use one figure, tied to B1's fallback and B3's rules.

**C9. §6, "thread T finds it far commoner than my earlier guess of 2%".**
* *What thread T says.* The 2% "is about right as an *effective* rate after review", and it is too low by 5–10 times as a rate of defective statements *without* review.
* *Fix.* "Far commoner unless independently reviewed." Also, "my earlier guess" refers to a draft the reader cannot see.

**C10. The §7 row for Proposition 7, "about max{d_max, n/c_r}·K/b_α failed runs".** Proposition 7's inequality gives 3·max{d_max, n/c_r}·K/b_α. Write the 3, or "O(…)".

---

## D. Minor

1. **The check's assumptions in Theorem 5.**
   * 5(c) says termination needs "(M2) if the check is used". Without (M1) there may be no flip (referee 7, A2), so write "(M1) and (M2)".
   * (f)'s proof uses (M-prefix), which neither the preamble nor (f) lists.
   * "Without the check, assume (B_D) in τ\* for bizarre entries too" is in (f)'s proof but not in its statement.
2. **Theorem 5(d) and (e): "violates (A2)".** Lemma 1 uses (A3′), so write "(A2) or (A3′)" (see also B1).
3. **Theorem 5(b): "final-answer asks".** With b = b_α (SI-ABC), all asks obey the same bound, so write "asks".
4. **Answer 2: "with the recommended search weights".** Write "with the schedule S, U, S, H".
   * §2.3's "S, U, S, H gives the scan half the queries; that is what keeps the worst case at 2n₀" is half right. U, H, S, S also gives the scan half the queries, but yields 2n₀ + 1 (A2). It is the order that matters.
5. **Answer 8 against §10.** Answer 8's contamination item is only "after a post-mortem", while §10 item 4 also covers verifications and checks. Answer 8 also omits §10's item 5. §10 lacks thread T's measurements: planted-defect trials, the formalizer's false-rejection rate and ι.
6. **The §7 table, V-cone row.** "Correctness rests on" gives only "L's soundness", while §6 now lists three conditions (referee 7, B10).
7. **Answer 3's "O(K) … 25%"** appears nowhere in the body. Thread S's §7 has the row; add it to §7 or cite thread S.
8. **E7 leaves terms undefined.**
   * "SI-ABC+D" (the design elements: the L-first query, then the review or decision query with probability ½) and "M" (100 problems) are not defined.
   * "Asking on top of VSI" in E7 asks at every unconfident step. It does not test §2.2's final-answer asking.
9. **The status line.** It says "revised three times", but E7 and thread T were added after referee 7. Say so.
10. **(M2) with a second person doing the check.** It becomes a condition on that person's verdicts about P's steps (referee 7, B1's fix). Say so in §3.
11. **§9 reuses Φ** for the tree bound "Φ·K failed runs", while §1 uses Φ for the potential. Rename one of them.
12. **Formalizer-inside-V detail.** If F reads the claim's cited cone, thread F's typed citations are needed. If F reads the prefix up to the claim, they are not, and S_V is still preserved. Say which.

---

## Referee 7's items, as fixed

| item | claimed fix | status |
|---|---|---|
| A1, b = 1 or b_α | b = 1 with final-answer asks or none, b_α with asks at every unconfident step | **Present and correct**, in the statement and in the proof of (b). |
| A2, (M1) and (M2) | assumed when the check is used; termination needs (M2) | Present. 5(c) should say (M1) and (M2), and (M-prefix) should be listed (D1). |
| A3, (f) and S\* | S\* preserved, τ\*(x₀) ≤ n₀, (B_D) in τ\* | Present and correct as far as it goes. Notebook-level S\* leaves the artifact gap (A1). |
| A4, the schedule | fixed S, U, S, H; Lemma 3 for periodic schedules; random schedules in expectation | The protocol and the constants are correct. Lemma 3's general periodic claim is false (A2). |
| A5, Proposition 7 | "bizarre entries included" | **Present and correct.** |
| B1, contamination | every reader is someone else | Present in §2.2, §10 and §11. V-human is still "the human's own verification" (B6). |
| B2, the check is optional | §2.1 and §6 | **Present and correct.** But see B9 on "no human judgment". |
| B3, heavy tails | a quarter fail (A2); 6–11% unfinished within 2n₀; 2n per search | **Present and correct.** |
| B4, the effort margin | factor 2 with V-machine and β = 0; T up to 40–55K; formalization cost a condition of the 70% row | The first two are present. The third is replaced by thread T's estimates, with "has become cheap" overstated (B5), and statement writing and ι ≤ 2 are not stated (B8). |
| B5, Proposition 7's guarantee | max{d_max, n/c_r}·K/b_α | Present. The factor 3 is missing (C10). |
| B6, which claim | some claim passes; the first is output; §5 | Present. It opens the notebook/claim gap (A1), and verifications per claim are not counted (B8). |
| B7, B8, B9, B11 | | **Present and correct.** |
| B10, V-cone's (A4′) | three conditions in §6 | Present in §6. The §7 table still says "L's soundness" (D6). |
| C1–C8 | | **Present and correct.** C8's distinction is not carried into Answer 3 (B6). |
| D1 | "bounded discrepancy" | Present, but the reason does not suffice (A2). |
| D2–D18 | | **Present and correct.** D16: (M1) is missing (D1). |
| §7 consistency (referee 7's last section) | not in the response | **Not addressed** (B7). |

## Global consistency

* **The answers in brief against the body.** They agree, except:
  * Answer 3's "the human's own verification" (B6);
  * Answer 3's 75% against §7's 75–78% (C8);
  * Answer 3's 25%, which has no counterpart in the body (D7);
  * Answer 4's "can even be stated" (C6);
  * Answer 8's narrower contamination item (D5).
* **§7 against §6 and threads S and T.**
  * The probabilities match thread S's, and the 60%, 70% and 75–78% match thread T's.
  * But the 75–78% assumes thread T's fallback and its halt and anomaly rules (B1, B3), which the note does not adopt.
  * The V-cone row's "rests on" is narrower than §6 (D6).
* **Leftovers from earlier drafts:**
  * §7's "heavy tails" under a conditioning that excludes them (B7);
  * "my earlier guess of 2%" (C9);
  * "recommended search weights" (D4);
  * "the human's verification" in Theorem 6 and the V-human bullet (B6).
