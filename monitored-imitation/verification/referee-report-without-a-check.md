# Referee report: *Without a check: where in a run to ask*

Version reviewed: `without-a-check.md` at commit `ac9df93b` (line numbers below refer to it), with `code/end_weighted.py` and `results/end_weighted*` at the same commit. Background read: `note.md` (Section 1, Lemma 1, the first-divergence observation, Proposition 2, Theorem 3 and its proof, the §5.2 example, Theorem 7, Proposition 8, the table of item 5) and `../ultranatural/note.md` (Sections 1, 4, 5: Proposition 7, the Definition, Proposition 8, Theorem 9 and "What it costs").

**What I ran** (all in this folder):

* `referee2_theory_checks.py` → `referee2_theory_checks.out` (about 10 s):
  1. the weights q_EW, for n = 1…3000; the code's sampler, by 4·10⁵ draws at n = 16 and 64 and 3 × 2·10⁶ vectorised draws at n = 16, 64 and 1024;
  2. Lemma 2, by brute force on 20,000 random small systems;
  3. both hidden-insight classes, with the exact class posterior and the majority decoder, over every probe set for n ≤ 6 (q = 2, 3, η from 0.05 to 0.9, both tie-breaking orders): whether (C_1) holds, whether the code's `decoder_write_step` is the exact majority decoder, and whether the mistake set is an up-set;
  4. an exact computation, by recursion over the consistent set, of the expected number of failed runs of CI, EW and LAST on a three-hypothesis human (the counterexample in A4), together with the sums in Theorems 1 and 3;
  5. the variants in Theorem 3(c) and the remark that doubling loses "about log r".
* `referee2_e3_checks.py` → `referee2_e3_checks.out` (about 2.5 min):
  1. a full re-run of E3 from the unmodified code, into `referee2_rerun/`. `end_weighted_summary.json`, `end_weighted.out` and `end_weighted_curves.json` are byte-identical to `results/`;
  2. the per-human numbers behind every catch-up entry;
  3. LAST on silent humans;
  4. 200 fresh humans per catch-up setting;
  5. a coupon-collector prediction for LAST, and the ratios quoted in the note.

## Statements checked and found correct

These are correct, sometimes with a remark in (B)–(D):

* **The weights q_EW** (l.107–109). They sum to 1, and q_EW(k) ≥ 1/(2n). The step at distance d gets (1/2)/(d+1)H_n + 1/(2n) ≥ 1/(2(d+1)H_n). Numerically: |Σq − 1| ≤ 2·10⁻¹⁶ for n ≤ 3000, and both ratios have minimum exactly 1.
* **Theorem 1** (l.85–89). It holds with an adaptive adversary and with q_t depending on the past and on the run.
  * M_t is a function of G_t and x₀ᵗ, so it is fixed by (past, x₀ᵗ). Hence E[1(k_t ∈ M_t) | past, x₀ᵗ, q_t] = q_t(M_t), and the tower property with Tonelli gives E Σ q_t(M_t) = E #(hits) ≤ ⌊K(P)⌋ by Lemma 1.
  * The only requirement is that k_t is drawn after x₀ᵗ and q_t are fixed. "Seen the past" should say that explicitly, as the first note's Protocol CI does (D2).
* **Lemma 2** (l.93–95). The discrete intermediate-value step is right. So is the identity H_{k+1} = H_k as whole sequences when x′_{k+1} = P(x′_k).
  * It holds for *any* deterministic success predicate of the run, not only for predicates of the final state. Brute force: 6,577 cases, no violation.
  * "Succeeds" must be a deterministic function of the run (D1).
* **Lemma 2 ⇒ "under (C_r) every failed run has a mistake among its last r steps"** (l.99).
* **Theorem 3**, given the assumption that the human's own runs succeed (A1):
  * the per-round inequality, and the use of the *last* mistake, which has the largest weight;
  * (a);
  * (b), including the i.i.d. random-stopping step: E[1(run t fails) | D_t] = F_t, so E F_τ = (1/N) E Σ_{t≤N} 1(fail_t);
  * both claims of (c). Under (C_1), LAST's query lands on a mistake in *every* failed run, so the bound ⌊K(P)⌋ even holds pathwise.

  On the toy of A4 the sums of Theorems 1 and 3 come out at 0.45–0.97 against K(P) = 1.74.
* **Proposition 4** (l.136–138), if the decoder is held fixed during the search (A6).
  * The count is right: knowing n−1 ∈ M leaves n candidates, so ⌈log₂ n⌉ queries.
  * The monotonicity argument is trivially right.
  * The decoder that has not learned k_p has an up-set mistake set [t_p, n−1] in the catch-up class: 1,230 of 1,230 cases.
* **The silent class violates (C_1)** whenever an insight with t_p < n−1 is unfound.
* **The catch-up class satisfies (C_1)**, for the class-prior majority decoder when η(n−1)/n ≤ q/(q+1). That covers E3 (η = 1/2) and Theorem 3's regime (η = 8ε ≤ 1/2). See A2 for why this must be stated as a lemma.
* **The first-divergence step in Section 1** (l.75), given that the human's own run succeeds.
* **The citation of the ultranatural note.**
  * Theorem 9 and Proposition 8 say what item 7 attributes to them.
  * O((K + log(1/η))/δ) is the right count, if η is the failure probability: posterior threshold 1/2 and Markov give failure ≤ 2^{K+1}(1−δ)^N.
  * The hidden-insight humans are not isolated beyond the measure of one insight state: removing one insight gives a simpler function that differs at one state.
* **The code implements what the note describes.** Details in (C), first item.
* **The numbers.** All 32 entries of the E3 table match `end_weighted_summary.json`, and so do most numbers in the prose (exceptions in C2–C4).

## (A) Errors in statements or proofs

**A1. A standing assumption is missing: the human's own run succeeds on every problem.**

*Location:* l.75 ("Whatever the notion, if the decoder's run fails and the human's own run succeeds…"), used in the proof of Theorem 3 (l.120: "On a failed run t, q_EW(M_t) ≥ (1/2)·|M_t|/n ≥ 1/(2n)").

*Problem:*
* Section 1 allows any notion of success. The inequality |M_t| ≥ 1 on failed runs needs the human's own run from x₀ᵗ to succeed, and nothing in the note assumes that.
* With a success predicate that some human run fails, an exact decoder fails on that problem in every round with no mistake. Then Theorem 3(a) ("for every sequence of problems … at most 2n·K(P)") is false: the number of failed runs is unbounded.
* The brute force found 5,191 failed decoder runs with M = ∅, all on problems where the human's own run fails (`referee2_theory_checks.out` §2).
* Under (C_r), Lemma 2 supplies the mistake, so (b) and (c) are unaffected. (a), and the item-4 bullet "Always: at most 2n·K", are not.

*Fix:* in Section 1, state as an assumption that success is a deterministic predicate of the run (or of the problem and the final state) that the human's own run satisfies on every problem. Cite it in the proof of Theorem 3(a).

**A2. "The catch-up class satisfies (C₁)" is stated as a property of the class. It is a property of the class together with the learner, and no proof is given.**

*Location:* l.152, used in item 8, l.48–53, and in the K/ε claim of l.152.

*Problem:*
* (C_r) quantifies over the decoder's states (l.97–99).
* Take a state that carries a wrong insight value (p, n−1, k′ ≠ k_p), or an insight on a problem with t_p = ∞. The catch-up human keeps it at the last step and the run fails. So (C_1) holds only for decoders that never write an insight value the data have not confirmed.
* For the class-prior majority decoder this holds exactly when η(n−1)/n ≤ q/(q+1).
  * With t_p > lo known, writing an unconfirmed k at step j needs η(j−lo)/(nq) > 1 − η(j+1)/n. That is hardest to avoid with no data and j = n−2.
  * Exhaustive check for n ≤ 6: no failure for η < 0.8 (q = 2) and η < 0.9 (q = 3); at equality the outcome depends on the tie-breaking order.
  * At n = 50 and η = 0.7, q = 2, (C_1) fails for 51 of 101 truths already with no data (`.out` §3).
* Under the Solomonoff prior of Section 1 nothing is shown. A decoder that guesses insights breaks (C_1).

*Fix:* state it as a lemma.

> For the class prior with η ≤ q/(q+1)·n/(n−1) (in particular η ≤ 2/3), the majority decoder writes no unconfirmed insight, so (C_1) holds in every round.

The proof is two lines: data only ever raise lo, and ⊥ beats each single k. Then make l.152 and the K/ε claim conditional on it.

**A3. The first note's lower bound is used for a different failure event without comment.**

*Location:* item 1 (l.14), item 4 ("on silent humans it never learns", l.30), Section 5 (l.151 "The silent class needs Ω(n·K/(ε log(n/ε))) task queries"), table row 1 (l.59).

*Problem:*
* The first note's Theorem 3 bounds Pr[the run of Ĝ *differs* from the human's]. This note's failure is "the final state is not good", which is a weaker event. A lower bound on a weaker failure event does not follow from one on a stronger event.
* The transfer happens to be valid, because step 4 of the first note's proof actually bounds Pr[Ĝ's run ends in (p, n, k_p)].
* But it is valid only for success = "the final state is the human's", or a test that rejects every final state other than (p, n, k_p). It is not valid for the general "passes some test that the human's own runs pass" of l.75. A test that passes (p, n, ⊥) makes the class trivial.

*Fix:* say that the lower bound is for success = "final state equals the human's", and that it follows from step 4 of the first note's proof, not from that theorem's statement.

**A4. "Never worse than chained imitation by more than a factor 2" is false for particular humans. Only the upper bounds compare.**

*Location:* abstract (l.3); also l.160 ("Theorem 3(a) still bounds the damage at twice chained imitation's cost").

*Problem:*
* Theorem 3(a) gives 2n·K against chained imitation's n·K. Both are worst-case upper bounds. On a given human, the extra queries EW makes at the end can *change* the decoder for the worse: the majority vote is not monotone in the data.
* Exact counterexample, in the note's own setting (`.out` §4):
  * States s₀…s_N (the human's chain), z₁…z_N and y. Hypotheses: P; A = P except A(s_{N−1}) = y; B = P except B(s₀) = z₁. Weights 3/10, 2/10, 4/10, so K(P) = 1.74. Success means ending in s_N.
  * Initially P+A outvote B at s₀, and the decoder is exact.
  * A query at s_{N−1} refutes A. After that B outvotes P at s₀, and every run fails until s₀ itself is queried.
  * Expected failed runs:

    | N | CI | EW | EW / CI |
    |---|---|---|---|
    | 4 | 2.0 | 3.6 | 1.79 |
    | 16 | 8.0 | 20.1 | 2.52 |
    | 64 | 32.0 | 97.6 | 3.05 |
    | 256 | 128.0 | 428.5 | 3.35 |

  * The ratio tends to 4 as N grows: EW almost surely queries s_{N−1} first, then hits s₀ at rate about 1/(2N).
* The first note makes exactly this distinction for MB+A ("That is a statement about upper bounds. It does not say that the combined protocol does at least as well as chained imitation on every human"). This note drops it.

*Fix:* "and its guarantee is never worse than chained imitation's by more than a factor 2". Likewise "cost" → "bound" at l.160. Item 6 (l.41) already says "bound".

**A5. "Any better protocol has to assume that the human is not silent in this sense, or that it has no rare knowledge at all" is false.**

*Location:* item 1, l.16.

*Problem:*
* The lower-bound class combines silence with *unpredictable insight steps* (uniform t_p) and rare, problem-specific content. Item 1 itself says "at an unpredictable step", then drops it from the conclusion.
* Counterexample: a silent class whose insights, when present, are always at step 0 (t_p ∈ {0, ∞}). It has the same rare, problem-specific knowledge and the same silence. Asking at step 0 lands on a mistake in every failed run, so at most K(P) failed runs and K/ε task queries.
* More generally, any known prior on t_p concentrated on s steps gives about s·K/ε. Insights shared across problems are another escape, and a check (the first note) is another again.

*Fix:* "has to assume something that excludes this class: for example persistence (this note), predictable insight steps, a check (the first note), or isolation (item 7)".

**A6. Proposition 4 needs the decoder to be held fixed during the search. The statement does not say so.**

*Location:* l.136, and item 5 (l.32–33).

*Problem:*
* The up-set condition is a property of one decoder's run. In the setting where Proposition 4 is used, the last-step answer reveals k_p.
* If the decoder is updated with it (or with any answer of the search), the new decoder writes k_p at the posterior median. Its mistake set is then [t_p, w) or {w}, which is not an up-set: 2,610 of 6,450 cases with k_p known (`.out` §3).
* Searching the new run is then wrong. The code does it right: it probes the *old* run's states, l.127–134.

*Fix:* add "for a fixed G (the answers are added to the data after the search)" to Proposition 4 and to item 5.

## (B) Overclaims and unclear statements

**B1. "What decides the cost is whether the human's later work still reflects what an imitator's state lacks"** (abstract), and "what makes chained imitation's factor n necessary is not that the knowledge is rare or problem-specific. It is that a deficit, once the run is past it, leaves no trace" (l.154).

* The pair of classes shows that silence is *necessary* for this construction to be hard. It does not show that silence *decides* the cost.
  * Silence is not sufficient: see the predictable-step counterexample in A5.
  * Persistence is not sufficient either. It must come with a small r, and EW still pays 2r·H_n.
  * Chained imitation on persistent (catch-up) humans still pays a heavy-tailed cost, 1,400–2,500 task queries against 300 for LAST (C2).
* *Fix:* "In the hidden-insight class, what separates the hard version from an easy one is whether …".

**B2. "No protocol that asks the human only for task steps beats chained imitation in the worst case"** (abstract).

* Add "by more than a factor O(log(n/ε))", as the first note does.
* Add that the worst-case class depends on ε (η = 8ε).

**B3. (C_r) "asks nothing new of the human", "is a property of the human's ordinary task steps on the imitator's states, which chained imitation has to learn anyway"** (item 3, l.23–24).

* (C_r) is a joint property of the human and the learner (prior, data, protocol): see A2. Whether it holds can differ between protocols that face the same human.
* It requires the human to *notice and repair* a deficit within r steps. That is a substantive behavioural assumption, and it cannot be tested without r task queries per state.
* Chained imitation neither learns nor needs this property. It learns single steps at the states it queries.
* The human-only sufficient condition of l.100 is very strong, as the note admits.
* *Fix:* say that it asks no new *kind of query*, and that it is an assumption about the human's behaviour on imitator states, relative to the learner.

**B4. Persistence as "the same kind of capability [as the check] exercised in a weaker form"** (item 6, l.43).

* Formally the two are incomparable.
  * The first note's §5.2 example is a silent human with a preserved check. It violates (C_r) for every r < n − t_p.
  * Persistence demands *repair* within r steps, which a check does not. A check demands consistent verdicts and preservation, which persistence does not.
* What each buys also differs. With a check, MB needs K task queries plus K·log(K/δ)/ε looks. With persistence, LAST needs K/ε task queries, so the 1/ε stays on the expensive query.
* *Fix:* "a related capability (noticing a deficit), used through work rather than through a verdict, and needing repair as well".

**B5. Empirical claims stated as fact.**

* "Deficits that cost the run its success are usually of this kind" (l.37).
* "Insights that change the direction of the work are of this kind" (l.157). This is in tension with l.40, where deficits whose repair takes much work make r large. A change of direction noticed late requires redoing the work done since, which is the large-r case.
* "Real humans' rarely used knowledge is of exactly that kind" (l.45).

None is argued. Mark them as conjectures, or drop them; open item 3 (l.195) is the right place for them.

**B6. "For real humans" (l.157–158).**

* "Then the n factor is not needed, and end-weighting removes it" holds only if r ≪ n/(2H_n).
* "An error the human would build on without noticing … needs n queries per failure. No protocol avoids that without a check" overgeneralizes Theorem 3. That theorem is up to a log factor, and it is about a class with unpredictable steps and rare, problem-specific content. It is not about every silent deficit (A5).

**B7. The table of item 9 (l.57–64) mixes incomparable guarantees, and omits the first note's caveat paragraph.**

* *Failure events.*
  * Row 1: the run differs. Its lower bound, for the final-state event, needs A3.
  * Rows 2–3: the final state fails.
  * Rows 4–5: the check fails.
  * Row 6: every input right, on a high-probability event.
* *Kinds of guarantee.* Some rows bound an expectation with a random stopping round; others hold with probability 1 − δ.
* *Learners.* Row 6 uses a different learner (B8).
* "K/ε" for LAST next to "n·K/ε" for CI reads as a like-for-like gain. It is not: LAST's runs still differ from the human's about half the time in E3 (0.48–0.51), against 0.02 for CI on silent humans.
* *Fix:* restore a sentence saying which failure each row bounds and in what sense.

**B8. Item 7 and table row 6 (isolation). The citation is correct, but the claim built on it hides four assumptions.**

* *The learner.* Theorem 9 is about patch-free induction, a prior restricted to δ-isolated hypotheses. It is not the Section 1 majority decoder under the note's prior w. If the human is *not* isolated, that learner can end with no consistent hypothesis (ultranatural, "What it costs"). The failure is catastrophic, not graceful as in the other rows.
* *The queries.* They must be i.i.d. from the fixed μ that defines isolation's distance d(f,g). Theorem 9's proof goes through Proposition 7, whose survival bound (1−δ)ⁿ needs independent samples from that μ. Queries from the run-induced or an adaptive distribution are not covered.
* *Where it pins the human.* "Every input" means the support of μ (ultranatural §5: "X denotes that support"). Runs are right only if every state a run reaches lies in it.
  * If μ is the distribution of states on human runs, drawing one sample costs up to n human task steps. The O((K + log(1/η))/δ) count omits that cost.
  * If μ has full support, isolation at a useful scale is a very strong assumption.
* *Notation.*
  * η is undefined in item 7. It must be the failure probability.
  * It clashes with the class parameter η, and with Theorem 9's own η, a posterior threshold.
  * δ is an isolation scale, not ε, so the row's count is not comparable to the others.
  * "No simpler function agrees with it except on a set of small measure" should read "no function at most as complex differs from it only on a set of measure < δ". The definition requires K(g) > K(f).

**B9. Theorem 3(c), "the uniform half can be replaced by the last r steps".**

* This gives 2r·K under (C_r), but it *loses* (a): the minimum weight drops to 1/(2nH_n), so the worst case becomes 2n·H_n·K. At n = 1024 that is 15,379·K, against 2,048·K (`.out` §5).
* Replacing the *harmonic* half by the last r steps keeps both: 2n·K always, and 2r·K under (C_r).
* Using the last r steps alone gives r·K under (C_r).
* Probably a slip. Fix the sentence and state the trade-off.

**B10. l.122: "The answer depends on where the remaining mistakes sit, not on how many there are."**

* Theorem 3's own proof uses the count: q_EW(M) ≥ |M|/(2n).
* Whether 99.9% per step suffices for a run to succeed depends on the count. What depends on the location is the cost of *finding* the mistakes.

**B11. l.123–124.**

* "With end-weighting they cost about ln n each" should be "about 2 ln n per failed run, as an upper-bound charge".
* "Isolated mistakes … cost n each, and Theorem 3 of the first note shows they must" should add "up to log(n/ε), when their location is unpredictable".
* "Isolated" here clashes with item 7's technical term.

**B12. Scaffold design (l.42, l.160).**

* Adding the instruction changes P. That changes K(P), the human's own runs, and so the imitation target.
* "Add anything this draft lacks that you would have contributed by now" asks the human to detect deficits, which is what a check asks for.
* Nothing in the note or the experiment tests that such an instruction produces (C_r) with small r.

**B13. Small items.**

* *Item 2* (l.19): "a failed run costs it 1/(fraction …)". This is the charge in an upper bound, not a cost. The README's "which is n only for isolated mistakes" has the same issue.
* *Section 5* (l.152): "K/ε overall, independent of n". K itself contains log₂ n, since E[K] = m(h(η) + η·log₂(nq)). What is independent of n is the actual count, one task query per insight met.

## (C) Experiment and code

**C0. What was verified in the code.**

* `decoder_write_step` equals the exact class-prior majority decoder, with ties to ⊥: 7,680 cases per class, no mismatch. The note should say that its decision for an unknown k_p ("small mass") is valid for every q ≥ 2 at η = 1/2 (A2). E3 never fixes q, and the code never models k.
* The EW sampler draws from q_EW. With 4·10⁵ draws, χ² = 16.4 on 15 d.o.f. at n = 16 and 86 on 63 at n = 64. Three further runs of 2·10⁶ vectorised draws give 6–10 on 15, 58–64 on 63 and 1,003–1,049 on 1,023 d.o.f.
* `query` returns exactly the mistake indicator, and updates (lo, hi) or the excluded set correctly. It skips uninformative states, which carry the insight after the write step.
* `run_ok` computes final-state failure and run-differs exactly.
* BIS probes the *old* run's states (p, j, ⊥) in exactly log₂ n task queries per insight. The measured (BIS − LAST)/insights is 4.00, 6.00, 8.00 and 10.00.
* The caps are as stated.
* The re-run is byte-identical.

**C1. "The last step is never a mistake, so failure stays at the fraction of problems with an insight" is false.**

*Location:* l.184; also "never learns" at l.30 and l.48.

*Problem:*
* On a silent human the last step *is* a mistake when t_p = n−1. LAST learns exactly those insights.
* Mistakes queried per human: 4.4, 1.1, 0.1 and 0.1, equal to the number of problems with t_p = n−1 in every human (`referee2_e3_checks.out` §3).
* Failure at the cap is 0.462 against 0.506 problems with an insight at n = 16.

*Fix:* "learns only the insights at the last step; failure stays at the fraction with an insight before step n−1".

**C2. The CI column for catch-up humans (1,640 to 3,370) is dominated by single humans. Ten humans are too few for a heavy-tailed quantity.**

*Per-human values* (`.out` §2):
* at n = 1024, one human needs 15,059 task queries: it has two insights at t_p = n−4, where CI hits with probability 1/256 per visit. That human alone contributes 1,506 to the mean of 3,370;
* at n = 64, one human needs 5,372 against a median of 1,244.

*With 200 fresh humans* (`.out` §4), mean ± s.e.:

| n | CI | EW | LAST | BIS |
|---|---|---|---|---|
| 16 | 1,366 ± 39 | 659 | 302 | 493 |
| 64 | 1,938 ± 76 | 645 | 300 | 588 |
| 256 | 2,229 ± 118 | 570 | 298 | 674 |
| 1024 | 2,503 ± 151 | 523 | 303 | 784 |

* CI rises mildly with n. The truncation u = (n − t_p)/n ≥ 1/n of the tail is lifted as n grows. The jump to 3,370 is noise: a 10-human mean reaches 3,370 with probability 0.11 at n = 1024.
* LAST is about 300 at every n, as the coupon-collector prediction Σ_{i=3}^{k} m/i ≈ 300 says. The table's 334 and 348 are high by chance.

The *explanation* at l.188 (late insights set the cost, by the heavy tail and the all-but-two stopping rule) is right; the per-human data confirm it.

*Fix:* use more humans or report medians, and drop the reading of 1,640–3,370 as a range.

**C3. "End-weighting needs about 1.5 to 2.5 times as many" (l.187).**

The table's own ratios are 2.58, 2.34, 1.54 and 1.61. With 200 humans they are 2.18, 2.15, 1.91 and 1.73.

**C4. "About 300 to 350 runs are needed to meet all but two of the problems" (l.186).**

It is all but two of the roughly 50 problems *that have an insight*. That is what makes it about 300 (coupon collector: 301, 302, 300 and 297 predicted).

**C5. "Leave most runs differing from the human's" (l.142, l.189).**

At most the fraction with an insight, about η = 1/2, can differ. CI at n = 16 leaves 0.21. Say "most runs on problems with an insight".

**C6. "These are the failed runs with few mistakes, which Theorem 3 charges at (d+1)·H_n instead of n" (l.188).**

On catch-up humans every failed run with k_p unknown has M = [t_p, n−1], so its last mistake is at d = 0. Theorem 3 charges it 2H_n, whatever t_p. The sentence has no d to refer to, and it drops the factor 2.

**C7. The stopping rule is an oracle.**

The run stops the first time the exactly computed failure on the *true* human is ≤ 2%. The E3 numbers are therefore not instances of Theorem 3(b)'s random-stopping guarantee, nor of the K/ε bound. The same holds for E1. Say so once in the setup.

**C8. "The same at every n as in E1" (l.167).**

The humans differ with n (seed 1000·n + s). They are E1's humans at each n. Reword.

**C9. Numbers that check out.**

* "1.2 to 1.5 times" for EW against CI on silent humans: 1.196–1.482. Forty fresh humans give 1.32 at n = 16 and 1.34 at n = 64.
* "510 to 820" for BIS: 506–817.
* "300 to 350" for LAST: 300–348.
* "510 to 800" for EW: 514–805.

## (D) Minor

* **D1. Lemma 2 and (C_r).**
  * Lemma 2 holds for any deterministic predicate of the run, so l.75 need not restrict success to final states. A stochastic test would break it.
  * Lemma 2 only needs some k₀ ≥ n − r with H_{k₀} succeeding, which is weaker than (C_r).
  * (C_r) is not monotone in r. The conclusion, a mistake in the last r steps, is.
* **D2. Theorem 1.**
  * "At most K(P)": Lemma 1 gives ⌊K(P)⌋, pathwise.
  * State that k_t is drawn after x₀ᵗ is fixed (the adversary does not see k_t).
* **D3. Theorem 3(b) and (c).** Choosing N = 2rH_nK/ε needs K(P), or a bound on it, and r. The first note says this for Proposition 2.
* **D4. The catch-up definition** (l.148) should read "t_p < j < n". At j = n the state stays put.
* **D5. "Every failed run has a single mistake"** (l.15, l.91) holds for decoders that never write an unconfirmed insight. A decoder that writes a wrong k after t_p has two mistakes.
* **D6. "About log r" when r is unknown** (l.129 and open item 1). A guarantee C·r·log₂ r for all r ≤ n needs C ≥ Σ_{d<n} 1/((d+1)log₂(d+2)), which grows like log log n (`.out` §5). So "about log r" holds only up to a log log factor.
* **D7. Open item 2.** "With probability ρ" needs a probability space: conditional on the past, over the problem draw. Otherwise the 1/ρ claim is undefined for adversarial sequences.
* **D8. Notation.** η is used for three things: the class parameter, item 7's confidence, and the cited theorem's posterior threshold. "Isolated" is used in two senses (l.45, l.124).
* **D9. The DAgger analogy** (l.99) is loose. DAgger's recoverability constant bounds the expert's increase in cost-to-go after one deviation; it is not a success guarantee. I did not check the paper's exact quantifier.
* **D10. README.** The note says "see the README for its verification status", but the README's status paragraph describes only the first note's verification.
* **D11. Item 4** says "2r·H_n·K/ε" and the abstract says "2r·ln(n)·K/ε". These are consistent up to H_n ≈ ln n + 0.58. Fine.
