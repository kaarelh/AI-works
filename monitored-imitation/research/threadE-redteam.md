# Thread E: red-teaming bounded setback

*Red-team note by Claude (Anthropic) on [`../slack-imitation.md`](../slack-imitation.md), mainly Sections 3 and 4, in the version with Lemma S and Proposition 4. Draft; not refereed. No experiments were run. The E6 code and its output were read.*

## Answers in brief

1. **The proofs are right.** Lemma S, Theorem 2, Corollary 3 and Proposition 4 are correct as stated. There are three small gaps (§3.5):
   * Corollary 3 does not state τ(x₀) ≤ n₀;
   * Proposition 4(c) needs (B_D) for bizarre entries too, since SI-V has no check;
   * Remark 3 (read-out) needs an extra premise (R), and slack makes (R) harder to meet, not easier.
2. **Section 4 misreads Proposition 2.** The decoder writes an item when π·p_max > 1 − π. As π → 1, any p_max will do. So wherever the human would *certainly* write something, the decoder writes its plurality guess, even at posterior 0.1. That covers a result, a plan, a verdict and the outcome of an attempt. Commissions are therefore not confined to "the obvious idea", and they are mostly *unconfident*. Omissions of rare content are mostly *confident*. The note's remark on "the two optimizations" has this backwards (§1).
3. **The most damaging violations follow from item 2 and from base rates.**
   * Negative results (V2). "Tried A; it fails" is the plurality outcome of an attempt, and nobody re-verifies a recorded dead end.
   * Fabricated values in slots that are certainly due (V1).
   * Plans and directions, kept by sunk cost (V3).
   * Anchoring on a weaker obvious result, the Einstellung effect (V4).
   * By-product insights (V5).
4. **Determinism backs (B-omit) only for literally empty steps,** and the decoder almost never writes those for a real human. Dates, headers and restated goals are its most confident content.
   * *Silent humans exist under a hidden clock.* An insight can be tied to a *stage* of the notebook ("while doing unit j of the routine work") rather than to the date.
   * *Theorem 3 of note.md transfers verbatim.* The decoder's typical step writes the routine work and leaves out the insight. That is exactly the step that violates (B-omit) for such a human.
5. **(B_D) only makes sense graded.** Quantified over every run of a long training process, it is almost surely false for any real human.
   * *What matters* is the share β of the learner's hits that concern behaviour whose mistakes sink a run on their own. Heuristically, the realized gain over chained imitation is at most about (1−ρ)/β, whatever D is.
   * *The guaranteed gain* is ρn₀/(D+1). That is 3 to 10 for projects of 4 to 10 years in three-month steps (§3.6).
6. **Most variants are weak.** A variant must keep "a correct step yields exactly P(y)".
   * *Provenance tags from the scaffold* either break (T1) or carry no information.
   * *Self-written confidence tags and "✓ verified" records* are imitated, so they launder fabrications.
   * *The verify instruction, quarantine and the abstaining decoder* are valid, and each helps only partly.
7. **The best variant: ask before committing (SI-ABC, §4).** At any step whose top output has posterior mass below 1 − α, task-query that step and continue the run from the human's answer.
   * *Cost:* it changes nothing the human sees, and costs at most K/log₂(1/(1−α)) extra task queries on every path.
   * *What remains:* (B_D) is needed only at committed steps, which are all confident, and each hit on one of those is worth log₂(1/α) bits.
   * *Effect:* it removes the commissions of item 3 at their source. It composes with slack, which handles the confident omissions.
   * *Verifiable domains:* add machine-checked entries.
8. **(B-commit) cannot be dropped for free without a check.** A mistake can be located by the decoder's own doubt (SI-ABC), by the human's later work ((B_D)), or by a human judgment (a check). A confident commission that a fooled human accepts escapes the first two. What remains after SI-ABC is the first surprise of each new kind of decision, found at rate 1/n.
9. **The classification is a tautology for a mode decoder,** since every output is the plurality one. "Predictable" should read "plurality". The classification also merges kinds with very different setbacks: low-confidence slot fills, base-rate negatives, lossy paraphrase, premature content, and commissions after success that spoil read-out (§5).
10. **My probabilities** (§6), on a graded reading, with the note's figures in brackets:
    * (B-omit): 70% for theory [90%], 50% for empirical or judgment work;
    * (B-commit) with D ≤ 2: 35% for mathematics and 40% for software [70%], 15% for empirical or judgment work [40%];
    * with SI-ABC, (B-commit) rises to 55%, 60% and 30%;
    * a gain of at least 5× over chained imitation: 40% [75%];
    * with a verifier (Proposition 4), failures are never output, and all of this affects only cost.

## 1. What the majority decoder writes

Consider one item. Let π = Pr[due], and let p_max be the conditional mass of its plurality value. Proposition 2 of thread C then says:
* the decoder writes the item iff π·p_max > 1 − π;
* the output's posterior mass is π·p_max if it writes, and 1 − π if it omits;
* so an omission is confident (mass ≥ 1 − α) iff π ≤ α, and a commission is confident iff π·p_max ≥ 1 − α.

Four consequences follow.
* **Slots that are certainly due get filled with guesses.**
  * At π = 0.95 the decoder writes any value with p_max > 0.053.
  * Research notebooks are full of slots the human certainly fills: the result of a computation just set up, the outcome of an attempt just described, a "next steps" list, a verdict on a hypothesis, what a literature search found.
  * The note's gloss, "only when it is the predictable continuation", is true of the slot, not of its content.
* **Rare insights are omitted confidently; commissions are typically unconfident.**
  * In the hidden-insight class π ≈ η/n, so the omission has mass ≈ 1 − η/n.
  * A commission has mass π·p_max, which can be as low as about 1 − π.
  * This inverts Section 4's "omissions are uncertain steps, so the uncertain half finds them faster": uncertainty finds commissions, and omissions need slack. §4 builds on this.
* **Empty steps essentially never occur.**
  * A real human always writes something: a date, a header, a restated goal, a plan. Those slots have π ≈ 1 and p_max ≈ 1, so the decoder writes them even when it omits all substance.
  * "Certain by determinism" therefore covers a case that does not arise.
  * The case that does arise, a step with boilerplate only, is a partial step under (B-omit). Its boilerplate carries signals of elapsed time (V12).
* **Paraphrase.**
  * The note treats faithful paraphrase as (B-commit) with D = 0, and I accept that.
  * The risk is *lossy* paraphrase. The plurality wording drops what is idiosyncratic. In a researcher's notes the idiosyncratic parts are often hedges and conditions: "only for odd n", "if the 2019 data are clean".
* **Caveats.**
  * Proposition 2 assumes a product posterior and exact decoding of the mode.
  * Greedy or item-by-item decoding of a non-product posterior commits more often: after "The key lemma is", some lemma must follow. It can also mix incoherent modes.
  * In neural machine translation the exact mode is often atypical, frequently the empty output (Stahlberg and Byrne 2019). Whether the Solomonoff mode of a three-month entry is bland in this way is unknown.

## 2. Violations

The frequency columns give how often each mechanism occurs among the decoder's mistakes once it is moderately trained:
* fields: M = mathematics and theory, S = software, E = empirical science, J = judgment work such as strategy or design;
* codes: C = common, O = occasional, R = rare.

D is in steps of three months; ∞ means never recovered.

| # | mechanism | M S E J | typical D | does the decoder write the trigger? | scaffold fix |
|---|---|---|---|---|---|
| V1 | slot-filling guess (a fabricated value) | O O C C | 0–1 if re-derived on use (M, S); ∞ (E, J) | yes: π ≈ 1, so any p_max | SI-ABC; machine-checked entries |
| V2 | negative result chosen by base rate | C O C O | ∞; a few steps if every alternative fails and A is retried | yes: failure is the plurality outcome of an attempt | SI-ABC; record where an attempt got stuck, not a verdict |
| V3 | plan or direction commitment, kept by sunk cost | C C C C | a sizeable fraction of n₀; ∞ if B never visibly fails | yes: "next steps" has π ≈ 1 | SI-ABC; weakly, "plans are suggestions" |
| V4 | anchoring on a weaker obvious result | C O O C | B's extra time; ∞ if S needs the better result | yes: the canonical case of Proposition 2 | SI-ABC if O has mass < 1 − α; nothing if O is confident |
| V5 | by-product insight lost (violates B-omit) | O O C O | ∞ unless there is another route | yes: routine work confident, insight confidently omitted | record raw intermediate data (partial); no full fix |
| V6 | plausible unverified claim, fabricated citation | O O C C | ∞ when load-bearing | yes: "searched the literature" makes a finding due | SI-ABC; citations with quoted statements |
| V7 | wrong retraction | R R O O | ≤ 1 if the reason is a checkable counterexample; ∞ otherwise | sometimes: only for error-prone kinds of claim | retractions must carry a checkable reason |
| V8 | distraction, generic to-do list | O C O C | 1–3; occasionally ∞ (no deadline pulls back) | yes: boilerplate | partial |
| V9 | lossy paraphrase (a hedge or condition dropped) | O O C C | 0 usually; ∞ when the condition becomes load-bearing | always, until the wording is learned | structured entries; SI-ABC at the level of content |
| V10 | notebook too long to read | O O O O | small per entry, cumulative (Remark 5) | yes: verbosity, entries written during the slack | an index built by the scaffold (not summaries) |
| V11 | morale: dead ends lead to a pivot, "already done" to complacency | O O O C | ∞ on abandonment; small otherwise | indirectly, through V2 | no clean fix |
| V12 | leaked progress signals: headers, entry count, perceived lateness, wrapping up | O O O C | ∞ if the human settles for a weaker result | yes: the most predictable content | the scaffold strips dates and step markers |
| V13 | premature "proof complete" or "design final" | O O O O | 1–2 in M (writing up finds gaps); ∞ in E, J | yes, near the posterior median of completion (E6's decoder writes its idea at 0.53·n₀) | SI-ABC; a read-out that verifies |
| V14 | commission after success (specific to slack): "design v2 supersedes v1" | O O O O | none for S; the read-out fails | yes: slack adds σ steps of opportunity | (R); a read-out that verifies |
| V15 | laundered verification: "✓ checked numerically" next to a guess | O O O O | as V1 or V6, with more trust | yes: the human always records its checks | only records that certify themselves |

Notes on the table.
* **V2 is, I think, the single most damaging mechanism.**
  * A positive claim can be checked by reading its proof. A negative claim ("tried induction on k; the inductive step fails") can be checked only by redoing the attempt. Researchers almost never redo their own recorded dead ends.
  * Base rates make "fails" the plurality outcome of most attempts. So for the one attempt that would have worked, the decoder writes the dead end, and a careful human trusts it.
  * This is the silent class, reached through a commission.
* **V5: the hidden clock does not exclude silent humans.**
  * *Construction.* Let a state be (p, j routine units, insight or ⊥). The human writes one routine unit per step, and adds k_p when it sees j = t_p and ⊥. This human is a function of the notebook alone.
  * *Theorem 3 still applies.* A probe at (p, j, ⊥) reveals only whether t_p = j. So Theorem 3's proof goes through with the routine count in place of the step.
  * *Where Section 4's argument fails.* Section 4 argues that otherwise "the idea depends on the date". That is right for empty steps only. With partial work, the idea can depend on the *activity* the notebook calls for.
  * *Real cases:* a confound noticed while setting up the third run, or a pattern noticed while computing small cases by hand.
* **V3 and V4: how large D is.**
  * *For a direction,* D ≤ 2 (six months) is optimistic, since switching directions costs a sizeable share of a project. The theorem really needs D_k ≪ σ, though, and with ρ = ½ the slack σ = n₀ absorbs a single detour of 30% of the project. The danger is ∞, not a large finite D.
  * *The Einstellung effect is robust in experts.* Chess masters shown a familiar mate miss a shorter one, and keep looking at the familiar solution (Bilalić, McLeod and Gobet 2008; Luchins 1942).
* **Trust in one's own notebook.**
  * The cold-start human sees every entry as its own past work, and the design hides provenance on purpose. A careful researcher re-verifies its own notes only when something breaks.
  * Section 4's "wrong claims lead to contradictions" covers only claims that are later used in a checkable way. It misses negative results (V2), results that are weaker but true (V4), and gaps that surface only in the final proof.

## 3. Premises outside (B_D), and the proofs

### 3.1 The hidden clock
* **It leaks through content.**
  * P can still infer time from the notebook's length, its number of entries or written dates. That is harmless for (T1), but it brings deadline effects back.
  * The decoder also advances this content clock faster than real progress, through boilerplate, verbose paraphrase and commissions (V12).
  * *Fix:* the scaffold strips dates and step markers, and the instruction, which is part of the reference chain, forbids per-step headers.
* **Humans who finish because of a deadline.** Parkinson's law and the student syndrome are real. Without a known deadline, the reference human may widen the scope and never consolidate.
  * If S is weak ("contains a correct design"), this mostly raises n₀, which costs only compute.
  * If consolidation is what creates S, such as a complete proof assembled from pieces, τ(x₀) can be ∞.
* **The human's own chain has no empty steps.**
  * If P(y) = y for some notebook y that does not succeed, then τ(y) = ∞. Real humans are fine here.
  * But E6's humans write nothing before t_p, so they are not hidden-clock humans. Remark 4 says so.
  * Under a hidden clock, "the idea becomes available" has to be triggered by content, and that is where V5 lives.
* **The human does not stop at n₀.** Its own chain keeps working for σ more steps and may supersede its answer with a "v2". This matters for the read-out even with no imitator (§3.2).

### 3.2 Success and read-out
* **S works only because it is weak.** S must be preserved by appending, so it cannot say which entry is the answer. That job falls to the read-out step, which (T2) does not protect.
* **Remark 3 has a gap.** It charges each read-out failure ½. That holds only for read-out failures that are mistakes of the imitator.
  * *Counterexample.* Suppose the final notebook satisfies S, contains a correct design, and then contains an entry written by the imitator: "design 2 supersedes it", or a wrong retraction (V7, V14).
  * *Then* the human's own read-out may pick the wrong entry. The imitator, copying the human, makes no mistake, and nothing is charged.
  * *What Remark 3 needs:* **(R)** on every non-bizarre final notebook of the imitator's runs that satisfies S, the human's read-out is correct.
* **Slack makes (R) harder, not easier.** (R) is a condition of the same type as (B-commit), and the σ steps after success are extra chances for V14.
  * A read-out that is instructed to *verify* its candidate makes (R) plausible in M and S.
  * A machine verifier that extracts the answer (Proposition 4) removes the issue.

### 3.3 τ(x₀) ≤ n₀
* **Cold-start chains.** P is a function of the notebook, so the reference chain is a chain of *cold starts*: a human who reads its notebook afresh every three months and keeps nothing unrecorded.
  * For projects that rest on tacit, accumulated skill, τ(x₀) of that chain may be much larger than the human's normal time for the project, or ∞.
  * This is shared with all chained imitation, so it does not separate slack imitation from chained imitation.
* **Heavy tails.** Research times are heavy-tailed.
  * A fixed n₀ leaves a floor of failures, Pr[τ(x₀) > n₀], that no theorem charges.
  * Corollary 3 should state the hypothesis (§3.5).
  * For each problem, the effective slack is n − τ(x₀ᵗ).

### 3.4 Determinism
Beyond the noise mentioned in Section 8:
* **Drift.** The human who answers query 5,000 is older and has read new papers.
* **Learning across queries.** After hundreds of imitator notebooks, the human knows the imitator's style.
  * It may come to distrust that style, which is good for (B-commit).
  * But P has then changed, and Lemma 1 of note.md needs one P consistent with all the data.
* **Fatigue.**
* **Many humans.** Using many interchangeable humans breaks the single-program premise in another way.

All of this lies outside (B_D) and is common to the whole series. It is still where a real deployment would fail first.

### 3.5 The proofs, checked
* **Lemma S is correct.** It uses exactly the following:
  * (T1), which needs P to be a function of the notebook alone. That requires determinism, a cold start, and a scaffold that adds nothing per step: with step separators, an "empty" step is not empty;
  * (T2);
  * τ(x₀) ≤ n₀;
  * (B_D) at the mistakes, with non-bizarreness used only to invoke (B_D).

  The arithmetic, 1 ≤ τ_n ≤ n₀ − (n − |M|) + D|M| = (D+1)|M| − σ, is right. One convention should be made explicit: a mistake (G(y) ≠ P(y)) and "g ≠ P(y) ∖ y" coincide only if hypotheses predict the list of appended entries.
* **Theorem 2 is correct.**
  * The first failing step is a mistake, by (M1)–(M3).
  * Failed runs that pass the check are non-bizarre, so Lemma S applies to them.
  * Theorem 1 of without-a-check.md then applies, with q_t a function of the run.
  * The "in particular" holds because (σ+1)/n > ρ and the term for runs that fail the check has coefficient 1.
* **Corollary 3 is correct, but omits the hypothesis τ(x₀) ≤ n₀** (almost surely), which it uses through Lemma S.
  * With "fail" including failing the check, each round is a hit with probability at least γp.
  * Adding the hit first and the other answers after it is exactly what Lemma 1 needs, since only one term per epoch must be at least 1.
  * The union bound Σ δ/(i(i+1)) = δ is right.
* **Proposition 4 is correct.**
  * A run with no mistake is the human's own run, which satisfies S.
  * Each rejection ends in exactly one hit on the frozen decoder, so there are at most ⌊K⌋ rejections.
  * Wald's identity gives (c), since the number of searches is bounded on every path.
  * *The gap:* SI-V has no check, and (B_D) is stated only for non-bizarre notebooks. So the bound (D+1)K/ρ in (c) needs (B_D) for bizarre entries too, or a check with bisection. Otherwise a rejected bizarre run can cost up to n task queries.
* **Section 4's "two optimizations".** Mixing in uncertainty queries keeps Theorem 2 at half the rate, which is correct. The gloss, that omissions are the uncertain steps, is inverted (§1).

### 3.6 Reading the theorem graded
(B_D) is quantified over all runs of every imitator that occurs, so one by-product insight lost anywhere falsifies it. The note's percentages can therefore only mean a graded claim. Remark 2 supports one: a failed run is charged |M_t|/n.
* **The guaranteed gain.** Over chained imitation run for n₀ steps, the guarantee improves by ρn₀/(D+1).
  * For n₀ = 16 to 40 (projects of 4 to 10 years) and D = 1 or 2, that is 2.7 to 10.
  * Realized gains can be far larger. In E6, noticing humans at n = 16 gain 37×.
* **The realized gain: a heuristic.**
  * Let β be the share of the learner's hits that concern behaviour whose mistakes sink a run alone: V2, V4, V5, and V6 with a fooled human. Both schemes find such failures at rate 1/n.
  * If chained imitation's failures mostly have few mistakes, the realized gain is at most about (1−ρ)/β. Lateness makes this the case, as in E6 and in thread C's CHAIN experiment.
  * For ρ = ½ the cap is about 1/(2β): β = 5% caps the gain at 10, and β = 20% at 2.5.
  * So "is β small?" matters more than "is D small?".
* **E6 is kinder than this heuristic.** Fooled humans still gain 4 to 23×, because their failed runs usually carry omission mistakes before the decoder's guess.

## 4. Design variants

**The design law.**
* (T1) needs a correct imitator step to produce exactly P(y).
* Anything the scaffold adds to imitator entries but not to the human's own (tags, markers, confidence scores) turns correct steps into setbacks that are never charged.
* Anything the human itself writes (a confidence level, "verified") gets imitated.

| variant | theorem still valid? | does it reduce D? |
|---|---|---|
| standing instruction "verify before relying" | yes: it is part of P, so the reference chain verifies too (n₀ grows) | for checkable positive claims: wrong lemmas, failing code, retractions with a stated reason. Not for V2, V4 or V5, nor for V6 in E or J. Verification *records* get laundered (V15), so a cold-start human must redo the check at every use, which grows with the notebook |
| provenance tags written by the scaffold | no, or empty: every entry of a run is the imitator's. Tag the reference chain "human" and (T1) fails; tag everything the same and the tags say nothing | – |
| confidence tags written by the human | yes | no: the decoder writes the human's usual tag ("high confidence") next to its guess, which raises trust |
| confidence tags from the posterior, written by the scaffold | only if tagged correct steps cost the human nothing, which cannot be guaranteed; otherwise this is the quarantine below | – |
| quarantine section for content of mass < 1 − α | yes, if the instruction is in the reference chain, where the quarantine stays empty. Lemma S needs quarantined correct content to cost nothing, as in (B-omit). A quarantining step pays at least log₂(1/(1−α)) bits when queried, not 1 | moves most commissions to the quarantine. Anchoring by a flagged hint is weaker, but not gone |
| abstaining decoder (writes only content of mass ≥ 1 − α) | yes: the bound becomes (D+1)K/(ρ·log₂(1/(1−α))), the factor 1/α of Open 2. A frozen abstainer can stall on an item, but such runs have many abstention mistakes | (B-commit) is needed only for confident commissions; more exposure to (B-omit) (V5) |
| querying the read-out step separately | yes, given (R) | no, but it protects the read-out once (R) holds |
| **ask before committing (SI-ABC)** | **yes: the human sees only notebooks made of decoder outputs and its own steps** | **(B-commit) is needed only for confident commissions. V1–V4, V6 and V13 are removed whenever the decoder is unsure** |
| machine-checked entries: the scaffold runs code and the proof checker, and appends their outputs | yes, if applied in the reference chain too: the step is then y ↦ P(y) ∪ exec(y, P(y)), still a function of y | removes V1, V6 and V15 for executable claims, and V2 when attempts are code; D ≈ 0 for them. Nothing for J |
| audits triggered by content ("when 8 entries have been added since the last audit, audit the load-bearing claims") | yes: the trigger is content, so the clock stays hidden | caps D for checkable claims at the audit interval; n₀ grows by the share of audit steps |

**Protocol SI-ABC.** At step k of round t, let μ_k be the posterior mass of the decoder's top output.
* If μ_k < 1 − α, task-query x′_k, append the human's answer as the step, and add it to the data at once.
* Otherwise, append the decoder's output.
* After the run, do the check or the uniform query, as in Protocol SI.

**Proposition E.** Let α ≤ ½. Assume (M1)–(M3), τ(x₀) ≤ n₀, and (B_D) at committed steps. Then:
* on every path, SI-ABC makes at most K/log₂(1/(1−α)) queries of its own;
* E[#runs that fail the check] + ((σ+1)/((D+1)n))·E[#failed runs that pass the check] ≤ K/log₂(1/α).

*Proof sketch.*
* *SI-ABC steps.* These steps are the human's own. So they are correct steps in Lemma S, and by (M2) never the first bizarre step.
* *Committed mistakes.* A mistake at a committed step has ξ(P(x)) ≤ 1 − μ ≤ α.
* *Bits per round.* The bits a round pays, log₂ W(D_t)/W(D_{t+1}), do not depend on the order in which its data points are listed.
  * Listing the uniform query at the position of its step gives at least [hit]·log₂(1/α).
  * Listing it last gives at least #ABC·log₂(1/(1−α)).
  * Each of these lower bounds sums over rounds to at most K.
* *Hits.* The run does not depend on the query's coin, so a hit has probability at least |M|/n, as in Theorem 1. ∎

Remarks on Proposition E.
* **Cost.** Online, the cost is additive: about 0.69K/α queries over the protocol's whole life, not per run.
  * A frozen PAC output must abstain instead, and then pays Open 2's factor 1/α. The exception is a deployed system that may still ask the human, within the same lifetime budget.
* **Practice.** In practice μ must measure confidence about content regardless of wording. Otherwise SI-ABC fires at every step until the human's style is learned. In the theory, that cost is part of K.
* **How it differs from the note's mixed-in uncertainty queries.** Those leave the commission in the run, so (B-commit) is still needed for it. SI-ABC prevents the commission.
* **Prior work.** This is expert intervention gated by uncertainty, as in interactive imitation learning (for example SafeDAgger and ThriftyDAgger). Slack makes it safe against the mistakes that uncertainty cannot see.

**Can (B-commit) be dropped?** Not for free, and not for a fixed human without a check.
* **Where a protocol learns where a mistake is.** A protocol that asks only for task steps can locate a mistake by:
  * the decoder's own doubt (SI-ABC), which works exactly for unconfident steps;
  * the human's later work ((B_D) or persistence), which works if the human is not fooled;
  * random position, at rate 1/n.

  A human judgment, such as a check or an endorsement, would be a fourth source; it is excluded here.
* **What escapes.** A confident commission that a fooled human accepts escapes the first two.
  * *Example:* the fooled class, with problem-specific deviations of probability η < α at a decision point.
  * There SI-ABC commits to the default, and the failures are runs with a single mistake, found at rate 1/n.
* **What lowering α buys.**
  * Lowering α below η costs about one query per problem, about K/(η log(1/η)), with no factor n. So the honest trade is (B-commit) for confident commissions against a query cost of 1/α.
  * Once a few deviations of one *kind* of decision have been seen, the posterior's deviation rate for that kind exceeds α, and SI-ABC fires on it. What remains is the first surprise of each new kind.
* **Omissions.** On the omission side, nothing can be traded: confident omissions by a silent human are exactly Theorem 3's case.

## 5. The classification

The note says the decoder's mistakes are omissions, predictable commissions, or junk.
* **True but tautological.** Every output of a mode decoder is the plurality output, so every commission is "predictable" in that sense. The content of the claim lies in what the plurality output looks like.
* **Mislabelled.** "Predictable" suggests high confidence, but by Proposition 2 a plurality commission can have posterior about 0.1 (§1). "Plurality commission" is the honest name. Split by how much setback they cause:
  * (a) obvious-idea substitutions: the note's case, mostly bounded;
  * (b) guessed results and verdicts in slots that are certainly due (V1, V6, V13): unbounded in E and J;
  * (c) negative results chosen by base rate (V2): unbounded almost everywhere;
  * (d) plans and directions (V3): large or unbounded.
* **Missing or merged kinds.**
  * *Mixed steps.* Most real steps both omit the insight and commit something (a paraphrase, a plan), so (B-omit) rarely applies on its own.
  * *Correct but premature content.* It helps, unless it is "done" (V13).
  * *Lossy paraphrase* (V9).
  * *Commissions after success* that spoil the read-out (V14).
  * *Incoherent mixtures* under greedy or item-by-item decoding (caveat in §1).
* **Junk is rare and caught.** I agree with the note here.
* **The axis that matters for design is confident against unconfident,** not omission against commission:
  * the decoder itself can find unconfident mistakes (SI-ABC);
  * confident omissions need slack and (B-omit);
  * confident commissions that the human accepts need a check or a verifier.

## 6. Probabilities, and where I disagree

**How to read the figures.** They are for a careful researcher, on the graded reading: the assumption fails at no more than 5% of the decoder's mistakes of that type, so that β in §3.6 is small. On the literal reading, over all runs, I give it below 5% for any real human in any field.

| claim | note | mine | mine with SI-ABC |
|---|---|---|---|
| (B-omit), theory and mathematics | 90% | 70% | 70% |
| (B-omit), empirical or judgment work | – | 50% | 50% |
| (B-commit) with D ≤ 2, mathematics | 70% | 35% | 55% |
| (B-commit) with D ≤ 2, software | 70% | 40% | 60% |
| (B-commit) with D ≤ 2, empirical or judgment work | 40% | 15% | 30% |
| slack imitation beats chained imitation by ≥ 2× (real human, n₀ ≈ 20–40) | – | 65% | 70% |
| by ≥ 5× ("a large factor") | 75% | 40% | 50% |

Where I disagree:
* **(B-omit), 90% → 70%.**
  * Determinism and the hidden clock certify only empty steps, which do not occur (§1).
  * The decoder's actual partial step, with the routine written and the insight omitted, is exactly what loses a by-product insight (V5).
  * In mathematics many insights come from working examples and attempts. Reading a complete record often recovers them, which is why I do not go lower.
  * In empirical work, anomalies noticed while setting up or running are a classic source of discovery, and the world is outside the notebook.
* **(B-commit) with D ≤ 2, 70% / 40% → 35% / 15%.**
  * The note expects the typical commission to be "the obvious idea", and wrong claims to be caught.
  * Proposition 2 instead produces guesses in every slot that is certainly due. These include negative results (V2) and plans (V3), whose setbacks are ∞ or well above 2 steps, even for careful mathematicians.
  * In empirical and judgment work, fabricated outcomes cannot be checked inside the notebook model.
  * SI-ABC removes most unconfident commissions, hence the third column.
* **A large factor, 75% → 40%.**
  * "Most mistakes are omissions" is doubtful (§1).
  * The guaranteed ratio ρn₀/(D+1) is only 3 to 10 for realistic n₀.
  * The small-ε regime is governed by the failures that are slowest to find: single unbounded setbacks, charged at rate n.
  * On the other side, slack also removes lateness, which dominates the early failures, and E6 shows gains even for fooled humans. Hence 40% and not lower.
* **Where I agree with the note.**
  * The theorem is right.
  * Some assumption of this kind is necessary.
  * Junk is handled by the check.
  * With a verifier (Proposition 4), everything above affects only the cost, which is bounded by n·K task queries with no wrong output. For mathematics and software, I think this is the strongest result in the note.

## 7. Tests that would settle it

Extend Section 4's tests with entries planted in researchers' *own* notebooks and presented as their own:
* "tried A; it fails", where A is the step that actually worked (V2);
* a plausible wrong value for a computation the researcher had set up (V1);
* a plausible plan that differs from the researcher's own (V3).

The quantity to measure is the fraction of planted entries never recovered within the project. That fraction, compared with (D+1)/(ρn₀), decides whether slack imitation gains a large factor. The size of the finite setbacks matters less.
