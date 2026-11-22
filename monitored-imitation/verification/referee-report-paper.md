# Referee report on the paper `paper/verified-slack-imitation.tex` (referee 9)

## About this review

* **Version reviewed.** The paper changed twice while I reviewed it.
  * 07:33: 61,444 bytes.
  * 07:51: 69,384 bytes. This added Definition 4.12 (no total blind spot), Theorem 4.13 (thread Q2), VSI-R, falsification by use, new rows in Table 1 and a new abstract.
  * 07:52:05: 69,864 bytes, md5 `1797b8cb…`. This added two sentences to the introduction.

  I reviewed all three versions. **Numbers in this report refer to the current version:**
  * Proposition 4.10, the safety net for any learner;
  * Proposition 4.11, the unsound verifier;
  * Definition 4.12 and Theorem 4.13, no total blind spot;
  * Theorem 4.14, the imitated verifier (4.12 in the brief);
  * Corollary 4.15, "works" in the worst case (4.13 in the brief).
* **Build.** The paper compiles cleanly in a scratch directory: 20 pages, no undefined references. There are three overfull boxes (D7).
* **Scripts.**
  * [`referee9_checks.py`](referee9_checks.py) → [`referee9_checks.out`](referee9_checks.out). Fixed seeds, about 2 s. It covers:
    * the schedule constants;
    * Lemma 4.4 by simulation;
    * a stress test of Proposition 4.10 with adversarial learners;
    * the B_T inequality of Theorem 6.2;
    * every number below that can be recomputed;
    * checks of Theorem 4.13 and the VSI-R figures.
  * [`referee9_figure.py`](referee9_figure.py) → [`referee9_figure.out`](referee9_figure.out). It runs `paper/make_paper_figures.py` unchanged, writing to a scratch directory, and compares the output with the committed `fig_e6.pdf` pixel by pixel.
* **Files.** No existing file was edited. Nothing was written into `paper/`.

## Verdict

**Major revision.** The core is sound. The two newest results have errors, and the headline claims need qualifying.

* **What holds.**
  * The mathematics of Sections 2–4 checks out, apart from Propositions 4.10 and 4.13 below:
    * Lemmas 2.1, 2.2, 4.2, 4.3, 4.4 and 4.6;
    * Definition 4.5 (a single-inequality form of the note's (B-omit)/(B-commit), which is exactly what Lemma 4.6 uses);
    * Theorem 4.7 (a)–(e), Proposition 4.11, Theorem 4.14 and Corollary 4.15.
  * The constants are right:
    * In S, U, S, H the scan's j-th step is query 2j−1, the U stream's k-th draw is query 4k−2, and the list's i-th entry is query 4i.
    * So the sure cost is 2n₀−1 ≤ 2n₀. U, H, S, S gives 2n₀ or 2n₀+1.
    * Lemma 4.6 gives 4n/|M| ≤ 4Λ ≤ 4(D+1)/ρ.
    * b = max{1, log₂(1/α)} is the value of a hit, and K′ = ⌊K/b⌋.
  * Lemma 4.4's bound held in all 120,000 simulated searches.
  * Sections 5 and 6.3 match their sources, with the exceptions listed in B.
  * Every experimental number in the paper reproduces exactly from the saved outputs. Figure 2 regenerates pixel-identically.
* **What is wrong.**
  * **Proposition 4.10(b) (the safety net) is false as stated.** With a local check (route (i)) or the "nothing bizarre" check, an arbitrary learner can force unboundedly many task queries on a single problem (A1). It holds for route (ii) searches.
  * **Theorem 4.13(b) is false for notebooks with several claims**, which the protocol allows (A2).
  * VSI-R, the new recommendation, applies Theorem 4.13 under (A3′). By the paper's own source (thread U), the critic-heavy pool it uses violates (A3′) on about 10% of problems. That breaks the rejection budget and makes VSI-R's monitoring rule unable ever to certify (B1).
* **Where the headline claims overreach.** The abstract and the introduction present conditional results as unconditional:
  * the 70% is conditional on determinism and realizability;
  * "whatever the human" needs (A2) and (A3′);
  * "independent of the number of problems" ignores audits and heavy tails;
  * "correctness needs only that every kind of error is caught sometimes" overstates an expected-count bound under i.i.d. problems.
* **Provenance.** The statement that every main claim was refereed is false for threads U, V, W and Q2 and for Propositions 4.10 and 4.13 (B6).

---

## A. Errors

### A1. Proposition 4.10(b) is false when the local check or the "nothing bizarre" check is used; (c) omits audits

*What is claimed.* "Run VSI with cache-first decoding … Assume (A3′) and no asks. Then, whatever the learner, … (b) on any single problem, VSI makes at most 2n₀ task queries in total, over all its reruns."

*The gap.* The proof counts searches by "each search's first query is such a scan query", that is, a query at a fresh chain notebook c_i with i < n₀. Two parts of VSI's protocol make rejections whose query is not a scan query:
* *route (i):* "task-query the flagged steps in turn";
* *a failed bizarre check:* bisect, then query the flip.

Their queries can land off the chain, after the first mistake, so they never use up a chain notebook.

*A counterexample (Part C of the output).* Take n₀ = 8, a local check satisfying (L0)–(L1), and the following learner:
* at c₀ it writes a fresh, wrong but valid entry on every rerun;
* at step 1 it writes an entry that L flags.

Route (i) queries step 1. That notebook is new on every rerun, and the query is a hit. c₀ is never queried, so it is never cached. The result: 200 task queries in 200 reruns of one problem, against 2n₀ = 16.

The same happens with the bizarre check, (M1)–(M2) holding: a fresh wrong entry at c₀, then a bizarre entry, then the claim, gives 200 queries in 200 reruns. With an adversarial learner the count has no bound. Under (c)'s mistake bound M the count is at most M, so (c)'s count of rejections survives.

*A second gap.* The proof needs the scan to skip notebooks already asked about *within its own turn*. If a cached scan step used up the S turn (no query, but the turn passed to U and H), the prefix argument ("non-scan queries are at most as many as scan queries") would fail. I measured 204 task queries on one problem at n₀ = 16, against 2n₀ = 32. The protocol does not say which reading is meant.

*Audits.* With one audit per output, (b) still holds. A sharper count shows the searches alone cost at most 2n₀−1:
* a search that ends with a scan hit has one fewer non-scan query than scan queries;
* c_{n₀−1} can be scanned only as a mistake.

I measured at most 2n₀ with β = 1. But (c)'s "at most 2n₀M task queries in all" omits the audits. A perfect learner (M = 0) with β = 1 makes 0 rejections and 50 task queries on 50 problems.

*Fix.*
* State (b) for route (ii) searches only. Alternatively, put a scan query before each route-(i) or flip query, which restores the count. Then the bound is 2n₀ in total, with one audit included.
* Add "the scan skips notebooks already asked about, without using up its turn" to the protocol.
* In (c), write "at most 2n₀M + (number of audits)".
* Optionally add the robust form: with caching, every problem costs at most 2n task queries even without (A3′). The scan touches only chain notebooks c_i with i < n.
* Section 10's "Unchanged: … the cap of 2n₀ task queries per problem" and the remark after Proposition 4.10 ("never exceeds about twice the human's own effort on any problem") inherit these conditions.
* The same flaw is in `verified-slack.md`, Proposition 5′, which has the same statement and proof.

### A2. Theorem 4.13(b) is false when a final notebook carries several claims

*What is claimed.* If each fresh verification passes any wrong claim with probability at most f̄, the expected number of distinct wrong claims output is at most f̄K/((1−f̄)b). The proof: "at most f̄N pass and at least (1−f̄)N are rejections".

*The gap.* A rejection of one *claim* is not a rejection of the *run*. Section 3.1 says "V accepts if some claimed solution in the final notebook passes". If a run carries k wrong claims and one of them passes, the run is output wrong, with no hit. The run is rejected, and the search ends in a hit, only if all k are rejected.

*A counterexample (Part F1).* Take f̄ = 0.2 and 200 kinds, each learned by one hit. Wrong outputs per rejection:

| claims per failed run, k | measured | exact, (1−(1−f̄)^k)/(1−f̄)^k | the paper's bound, f̄/(1−f̄) |
|---|---|---|---|
| 1 | 0.26 | 0.25 | 0.25 |
| 2 | 0.56 | 0.56 | 0.25 |
| 3 | 0.93 | 0.95 | 0.25 |
| 5 | 1.91 | 2.05 | 0.25 |

*Fix.* State (b) for the "first claim" variant of Section 6.3 (one verified claim per run, its failure a rejection). Alternatively, define f̄ as the probability that a run's verification passes *some* wrong claim. Part (a) is fine, because Definition 4.12 is stated at the level of runs. Thread Q2's Theorem Q2.1(c) has the same flaw.

### A3. Theorem 6.2(b): "B_T ≤ log₂ C(T+K′, K′)" holds only for one of thread V's two references

The paper compares VSI with "content-blind verdicts" without saying which. Thread V proves two bounds:
* against a coin VSI[coin_q] with q = K′/(K′+T), with exponent B_coin = T·log₂(1+K′/T) + K′·log₂(1+T/K′);
* against the uniform mixture of the C(T+K′, K′) verdict scripts, with exponent exactly log₂ C(T+K′, K′).

By the entropy bound on binomial coefficients, B_coin ≥ log₂ C. Part D shows this at every (K′, T) tried; for example K′ = 10 and T = 100 give 48.3 against 45.4. So for the coin reference, the displayed "B_T ≤ log₂ C" is false.

*Fix.* Name the reference: "the same scheme with verdicts read from a script drawn uniformly from the C(T+K′,K′) possible verdict strings, independent of the runs". Or use the coin, and write B_T = T·log₂(1+K′/T) + K′·log₂(1+T/K′). Both are at most K′·log₂ e + K′·log₂(1+T/K′). Breaking the display also removes the 85 pt overfull line.

### A4. "A resampling learner inflates c by up to its number of samples" (after Theorem 4.13) is unsupported, and false for independent resamples

Consider a learner that resamples on rejection, up to k times, before a search. Wrong outputs can occur at any of the k samples, but a rejection, and so a hit, needs all k to be rejected. With independent samples, c_k = a(1−x^k)/((1−x)x^k), where:
* x is the probability that a run is rejected;
* a is the probability that it passes wrong.

At p = 0.3 and wf = 0.2, c₁ = 0.25 and c₃ = 5.6, which is 22× c₁ against the claimed 3× (Part F2). The factor is roughly x^−(k−1), and it is k only when x is close to 1. Thread Q2 states the remark without proof.

*Fix.* Drop the remark, or replace it with "a resampling learner can inflate c without bound (by about x^−(k−1) for k independent samples)".

---

## B. Overclaims and inconsistencies

### B1. VSI-R applies Theorem 4.13 under (A3′), which its own pool violates by the paper's source (major)

Theorem 4.13 assumes (A3′): V never rejects the human's own claim. Its whole budget, R ≤ K/b, comes from "every rejection ends in a hit".

VSI-R's pool is thread U's combination: machine checks, three AI critics, and a reader who judges objections. Thread U says of it: "Upheld false objections make VSI abstain on about 10% of problems under the critic-heavy protocols" (thread U §4, "Lost problems"; §3.6 models 0.10 upheld false objections per family per verification). Each such rejection ends in a full scan and an abstention, with no hit. So:
* R grows like 0.1·T, and the bound (c+1)·E[R] is no longer at most (c+1)K/b;
* VSI-R's monitoring rule, "(ĉ+1) × windowed rejection rate ≤ 5%", can never be met. At c = 0.24, false rejections alone give (c+1) × 0.10 = 12.4% (Part F5).

*Fix.* Do one of the following:
* State (A3′) for the pool as an explicit assumption, and estimate how often it fails.
* Restate Theorem 4.13 with abstentions, and count only rejections that end in a hit in the monitoring rule. That needs the definition restated with hit-ending rejections in place of all rejections.

Also say that thread Q2's "worst" reading (every error of its kind's hardest type) gives 45% for theory and 48% for software (`threadQ2_blindspot.out`, Part C). That is below the fixed-verifier rows.

### B2. The abstract's and the introduction's glosses of Theorem 4.13

* *The abstract.* "a randomized pool …, whose correctness needs only that every kind of the imitator's error is caught sometimes (no total blind spot), with an output failure rate bounded by an observable multiple of the rejection rate". The introduction says the same.
* *What Theorem 4.13 gives.* An *expected count* of wrong outputs, not correctness. It holds under:
  * i.i.d. problems;
  * (A1)–(A3′);
  * Definition 4.12 at *every reachable state*, a uniform ratio bound.

  "Every kind caught sometimes" implies that only in a product class, and only with catch rates bounded away from 0. The paper's own "Selection" paragraph says so.
* *The multiple is not observable.* c has to be estimated, as ĉ, from planted-error tests.
* *The 58–66% figures* weight the fallback ("a small miss rate") by 1−q = 30–35%. The table's own entry reads "no total blind spot, or a small miss rate". So "needs only" contradicts the paper's own estimate.

*Fix.* Write, for example: "…whose expected number of wrong outputs, under i.i.d. problems, is at most (c+1) times the number of rejections, provided the verifier has no total blind spot at any state the learner reaches (Theorem 4.13)".

### B3. The headline 70% is presented unconditionally

* *The abstract.* "our calibrated probability that the scheme works on a real careful researcher: about 70% …".
* *The conditioning.* Section 7 and thread T condition it on determinism, realizability and a chain that succeeds. Thread T (§5.2) puts the unconditional figure at about 40%, citing thread S. Thread L finds about 90% repeatability, even on categorical decisions.
* *The word "calibrated".* It claims more than subjective estimates built from unrefereed, judgment-heavy threads support.

*Fix.* Write "our subjective probability, conditional on the framework's idealizations (a deterministic human whom the learner's class contains), …", and give the unconditional figure.

### B4. "Whatever the human"

* *Where it appears:* the abstract, the introduction, Theorem 4.7(d) and Corollary 4.15.
* *Correctness* indeed needs no property of the human's task steps.
* *The cost bound 2n₀* needs (A1)–(A3′): a deterministic human in the class, whose own chain reaches a verifiable solution within n₀. The last is a property of the human's task behaviour. By Section 6.2's own estimate it fails on a quarter of problems when n₀ is at the 75th percentile.

*Fix.* Write "for every deterministic human in the class whose own chain reaches a verifiable solution within n₀". The sentence after Corollary 4.15 already says this ("the only properties of the human it needs are those of the framework itself"), and the headline should too.

### B5. "At most 2n₀K in all … independent of the number of problems"

* *Where it appears:* the abstract and the introduction.
* *What Theorem 4.7(e) actually gives:*
  * plus βT audits (Proposition 4.11 recommends β = 1 with a fallible verifier; VSI-R uses β ≈ 0.1);
  * plus asks;
  * plus up to 2n per rejection or abstention on problems that violate (A2)/(A3′).
* *Heavy tails.* Section 6.2 estimates abstentions on 6–11% of problems and searches of up to 2n on a quarter. That makes the total linear in T.
* *What survives.* The T-free statement holds for the search queries of rejections that end in a hit.

*Fix.* Say "at most 2n₀K search queries for rejections that end in a hit, plus βT audits, plus about n per abstention on problems the human's own chain does not finish within n".

### B6. Provenance overclaims refereeing

* *What the introduction says:* "every main claim was checked by at least one independent AI referee".
* *What the files say:*
  * threads U, V, W and Q2 are marked "Draft; not refereed";
  * referee 8 says: "I did not read `research/threadU_*`";
  * Proposition 4.10 (5′ in the note) and Theorem 4.13 appear in no referee report.
* *What is unrefereed as a result:*
  * Section 6.3 (Theorems 6.1–6.2);
  * Theorem 4.13 and VSI-R;
  * Section 9's verifier figures and w;
  * Table 1's VSI-R and human-verifier rows.

*Fix.* Correct the sentence, and mark these as unrefereed where they are stated.

### B7. Theorem 5.4 is misquoted

* *The paper:* "must have the human process about a quarter of all the routine work **per such insight**".
* *Thread G, Theorem G3:* failure ≤ ε needs κQ ≥ Nm/(4w), that is, the human processes at least a share 1/(4w) of the routine work of *all* m problems. With w = 1 that is a quarter in total, not a quarter per insight. `verified-slack.md` §4 quotes it correctly.

*Fix.* Delete "per such insight".

### B8. Section 6.3, "The formalizer inside V", states a sketch as proved

The paragraph's last sentence says that with a fixed statement, a pinned and seeded formalizer and the proof archived and checked rather than read, "the only optimized information that reaches the world is the verdict". That is thread V's Proposition 4(e), marked **[sketch]**. The section opens with "The following results are proved in [threadV]".

*Fix.* Mark it as a sketch. Note too that, with the formalizer inside V, the note's output *is* the formal proof π, which thread V's Proposition 4(b) shows is optimized.

### B9. Falsification by use omits a hypothesis

* *What the paper states:* "Then every exposure ends in a hit…".
* *What thread Q2's Theorem Q2.3 assumes:* (A1) and **(E2)**: "the human's own chain reaches within n₀ a claim that V passes and that is never exposed". Without (E2), an exposure can fall on a run with no committed mistake below n₀, so Lemma 4.2 does not apply.
* *What the paper leaves implicit:* the library must be recomputed after every hit, so that an exposed claim is the *current* decoder's output.

*Fix.* Add (E2), (A1) and "recomputed after every hit".

### B10. Halts for statement review are not counted

Step 4 halts a problem whenever *any* run contains a statement-defect entry. Theorem 4.7(c) lists a halt as one way a problem ends. But:
* an imitator's spurious defect entry is a committed mistake;
* it halts the problem with no hit and no output;
* Theorem 4.7(b) and (e) bound neither the number of halts nor their cost in reviews.

*Fix.* After a review that finds the statement sound, treat the run as rejected and task-query the step that wrote the entry. If the human would not have written it, that is a hit. Otherwise count halts explicitly, as thread V's Remark 2 does: K′ + Z.

### B11. The formalizer inside V: the conditions that (A2)/(A3′) need are missing

The note (§2.1) requires three things, after referee 8's B1–B2:
* F is deterministic (a fixed seed, a pinned model and a pinned toolchain);
* F reads only the claim and what precedes it, so that S_V is preserved by appending;
* F succeeds within B on the human's own blueprint.

Section 3 of the paper drops all three. Section 6.3 mentions only "a pinned and seeded formalizer".

*Fix.* Restore the three conditions in the definition of V-machine.

### B12. Smaller points of fidelity

1. *Theorem 5.5(i)* drops thread F's conditions: q ≥ 4n/n₀, an output imitator that appends at most one entry per step, and fixed ρ.
2. *Appendix B, trees* (thread N), drops two things:
   * the condition b(D+1) ≥ 2ρ on Ψ < 2((D+1)/ρ)^{d+1}b^d;
   * the status of "the b^d is necessary": proved by reduction, but written out only in outline.
3. *Theorem 6.2(a).* "Given the history" should be "given the history and the search randomness". The path depends on the U-stream draws. With the bizarre check a rejection comes in two kinds, which adds up to K′ bits (thread V, Remark 2).
4. *Section 9, the evidence on w:*
   * "models 'prove' false variants … 43–84% of the time" is the rate *on problems the model cannot solve*; overall rates are 29–70%;
   * "about 0.3 of failed projects … 0.8 among failures written up" comes from one set of 36 antidepressant trials, tagged [S] and partly from memory in thread W. Say so.
5. *Section 6.1* drops two "search summaries only" tags from the note: the one on the upper end of "5–60% unfaithful", and the one on "about half of misformalizations fail safe".
6. *Theorem 5.2's sketch.* VSI uses about one verification per *problem*, which is about 1/η per *insight problem*. The comparison with "fewer than q/16 per insight problem" therefore needs q ≳ 16/η. That keeps the log at O(log(n/ε)), but it should be said.

---

## C. Numbers

### What matches (exactly, or as rounded)

* **E6** (`results/*.json`):
  * chained imitation 2,915 → 12,724 → 51,365;
  * slack imitation 160 → 204 → 204 (159.65, 203.8, 203.6).
* **Table 2.** All 32 cells match thread R's `threadR_compose.out` (the SI-V columns) and `referee8_e7_default.out` (the SUSH column).
* **Figure 2.** `make_paper_figures.py` parses the right column, and the regenerated figure is pixel-identical to the committed one.
* **Figure 2's caption:**
  * "about 30" is 25.9 / 31.7 / 32.1;
  * "about threefold" is 2.88 / 3.07 / 3.17;
  * "fooled humans grow" is 88.5 → 1,442.
* **Remark 4.9.** "5–35-fold" matches VSI+ABC/VSI in thread R: 5.2–35.0 on M1, M2, M7 and M8.
* **Section 6.1, thread T:** 22% (11 of 50); 5–60%; 25%/10% and 4%/1.5%; 0.5–1%; 99.5%; 65/80/90%; 24% (50 of 207); 5–15%; and the table's 60% and 77%.
* **Section 6.2:** 6–11% (thread S, Part E).
* **Section 9:**
  * thread U: 0.43, 0.45, 0.70 and 0.64; 38%; 0.45 → 0.13; 20%; 0.43 → 0.18; 46/60/15(25)/20%;
  * thread W: 0.6/0.6/0.85/0.9, and 3.5/1.6/9/7%. I recomputed the four failure rates as p·w·r̄·f_V: 3.5, 1.6, 9.0 and 7.4%;
  * thread Q2: 65/70/25/30%.
* **Section 10:** 2n₀ = 48; 4Λ = 15.4 ≈ 16; 20n₀ = 480.
* **Corollary 4.15:** ι < 2.
* **Appendix A:** (ln 2)K/α.
* **Theorem 6.2(c):** the two logarithm bounds.

### C1. Section 9's thresholds use a w the paper has replaced

"the 5% bar needs f_V ≤ 0.29 in theory, 0.23 in software, 0.17 in empirical and 0.16 in judgment work" is thread U's arithmetic, with w = 0.45, 0.55, 0.75 and 0.825. Two paragraphs later the paper adopts thread W's w = 0.6, 0.6, 0.85 and 0.9. With those, the thresholds are **0.21, 0.21, 0.15 and 0.14** (Part E). Thread W itself says theory's tightens "from 0.28 to 0.21".

*Fix.* Update the thresholds, or say which w they use.

### C2. The worked example of c

"c = wf/(1−wf), which is about 0.24 even for one careful reader in theory (w = 0.45, f = 0.43)" uses the old w. With the paper's w = 0.6, c = **0.35** (Part F3). The example also ignores r̄, the several wrong claims per failing problem: with more than one claim, f is compounded.

### C3. The VSI-R figures do not trace exactly

* Thread Q2 gives 59% for theory. The paper's 58% matches thread Q2's formula with thread W's lowered fallback, 46% instead of 50%: 0.65·64 + 0.35·46 = 57.7. Meanwhile the "kinds" term (76%) is still computed with thread U's w.
* "35% (43% as in VSI-R)" for one reader matches neither thread Q2's 45% (fallback 40%) nor its formula with the 35% fallback, 42.0% (Part F4).

*Fix.* Document the adjustment, or use the source's figures.

### C4. Table 2's caption uses the other schedule

"M2 and M8 stay flat only with a post-mortem … (40–55 and 31–34 task queries in that case)". These are the *equal-weight* figures (USL: M2 40.3/54.8/53.7, M8 34.0/33.4/31.2). The table itself is for the default schedule S, U, S, H. With the same post-mortem under that schedule (SUSL), the costs are **53–73** (M2: 52.7/73.4/72.0) and **42–46** (M8: 45.3/46.1/41.5) (`referee8_e7_default.out`).

### C5. Figure 2(a): "doubles the cost of silent ones"

Against chained imitation *on silent humans*, slack imitation costs 1.99, 2.02 and 1.97×. That line is not plotted. The only chained-imitation line is for bounded-setback humans, against which the silent line's ratio is 1.53–1.81×. Plot the silent chained-imitation line, or reword the caption.

### C6. "About n queries" per abstention

Sections 6.2 and 7 say "about n queries", while Theorem 4.7(e) says "at most 2n". It is about n only with cached answers, counting distinct steps (as the note says). Say so, or use 2n.

### C7. The second reader

"so a second reader leaves 0.24, not 0.16" is thread U's figure at f = 0.4 and r = 0.5, not at the 0.43 quoted in the same paragraph. State the parameters.

### C8. Table 1 against the text and the sources

* *"Slack imitation, no verifier: 30%".* In the note that is Proposition 7 (slack imitation plus the local check, reviews, decisions and the retry rule). Plain slack imitation with asking is 25%. Label the row accordingly.
* *The caption.* It says the human-verifier rows were "lowered by" thread W. But the cone row stays at 45%, while thread W lowers it to 42%.
* *The abstract.* "Empirical and judgment-heavy work remains at 15–20%", but the VSI-R row gives 18% and 22%.
* *"Why the other rows are low"* (Section 7) argues that human-verifier rows are low. It now sits under a VSI-R row at 58%/66%, and should mention it.

---

## D. Exposition and minor points

1. **Self-containedness.** A reader who knows Solomonoff induction can follow Sections 2–4. But several terms carry Theorem 4.7(d) and its proof without being defined:
   * *reviews, labelled decisions, by-product insights, ripe failures, hedge failures:* give each one sentence, from thread G;
   * *the "nothing bizarre" check:* the protocol box never says what happens when it fails (bisect to the flip, task-query it, rerun), yet Theorem 4.7(b)–(c) count failed checks;
   * *(M-prefix):* listed among the assumptions, never used;
   * *route (i):* it lacks the source's fall-through, "if every flag is excused, go on to (ii)".
2. **Definitions before use.**
   * The abstract and introduction use n₀, D and ρ without defining them.
   * μ first appears in Definition 4.12.
   * (A3′) and (A4′) carry primes with no (A3) or (A4) in the paper. Rename them (A3) and (A4).
   * "Bits of selection" (Theorem 6.2) needs its reference measure stated (see A3).
   * "Asking at the step that writes the claimed solution, if the imitator is unsure there" should give the note's definition of a final-answer slot.
3. **Overloaded symbols.**
   * D: a data set, and the setback bound.
   * M: a mistake set, the learner's mistake bound, the mechanisms M1–M8, and the assumptions (M1)–(M2).
   * w: prior weight, and the claim share.
   * L: the local check, and the location number.
   * b: the value of a hit, and the branching factor of trees.
   * c: the constant of Definition 4.12, the chain notebooks c_i, and c_p.
4. **Wording in Theorem 4.7 and Lemma 2.2.**
   * In 4.7(b), "almost surely" can be "on every path".
   * In 4.7(d), "plus one per flagged step that turns out to be the human's own" cannot happen under (L1), which is assumed. Call it a robustness remark.
   * In 4.7(e), write 4Λ "under bounded setback".
   * In Lemma 2.2, "the answer is added, before any other data of the round" conflicts with asks added during the run. Use the reordering argument of Theorem 4.7(b).
5. **Proposition 4.10's proof** should:
   * mention audits (the searches cost at most 2n₀−1, so one audit fits);
   * state the rule that the scan skips cached notebooks;
   * say that determinism of P is used, both for caching and for Lemma 4.2.
6. **Corollary 4.15 and Section 7.** "Works" is defined by effort, but the corollary compares guarantees, as its parenthesis admits. The argument for the 70% row should say that the step from the ratio of bounds to the ratio of efforts is a judgment.
7. **Layout.**
   * Overfull lines: Theorem 6.2(b), 85 pt into the margin; Table 1, 63 pt, so its last column runs past the text block; Definition 4.12, 4 pt.
   * Figure 2 floats into Section 7, ahead of Section 8.
   * `\paragraph{What makes a verifier good.}` is followed by a blank line.
8. **Citations.**
   * `\bibitem{ross}` is never cited; cite it at "DAgger".
   * Section 8, Table 2 and Figure 2(b) cite neither thread R nor referee 8's re-run, `verification/referee8_e7_default.out`, which is the source of the S, U, S, H column. The provenance appendix does not mention `verification/`.
9. **Other learners.** Section 10 says the learner's mistake count "has no guarantee". Appendix B (thread H) gives one, regret R, for learners with bounded log-loss regret. Reconcile the two.
10. **Definition 4.12's left-hand side.** "Ends with a claim that V passes and that fails the goal" is a superset of "the output (the first passing claim) is wrong". That is harmless, since it makes the condition stronger, but say "the verified artifact fails the goal" if that is what is meant.
