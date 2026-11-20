# Response to the referee report on the second note

The report ([`referee-report-without-a-check.md`](referee-report-without-a-check.md)) reviewed `without-a-check.md` at commit `ac9df93b`. It found:
* the core mathematics correct;
* six errors or gaps (A1–A6);
* overclaims (B1–B13);
* experiment issues (C1–C8);
* minor points (D1–D11).

All were addressed; the note was rewritten.

## A. Errors

* **A1.** Accepted. Standing assumption (S) in Section 1: success is a deterministic predicate of the run, and the human's own run succeeds on every problem. Theorem 3 assumes (S), and its proof cites it.
* **A2.** Accepted. New Lemma 5 states and proves (C₁) for the catch-up class, for the class-prior majority decoder when η(n−1)/n ≤ q/(q+1), with ties broken towards "no insight". The proof makes the referee's computation explicit. A write at the last step does not affect (C₁), which is why the condition has n−1. The E3 setup cites Lemma 5 for the code's treatment of q. The K/ε claim is now conditional on it.
* **A3.** Accepted. Section 5 says that the first note's lower bound transfers to final-state failure through step 4 of its proof, for success = "the final state is the human's" only. The table caption says the same for row 2.
* **A4.** Accepted. The abstract and items 4 and 6 now say "its guarantee is never worse … by more than a factor 2". A new paragraph, "Comparisons are between guarantees, not humans", gives the referee's three-hypothesis example (EW/CI from 1.8 to 3.4, tending to 4) and the reason: the majority vote is not monotone in the data.
* **A5.** Accepted. Item 1 now lists what a better protocol must assume to exclude the hard class:
  * predictable insight steps, with the referee's step-0 example;
  * shared knowledge;
  * a check;
  * isolation;
  * persistence.
* **A6.** Accepted. Proposition 4 now fixes the decoder and adds answers only after the search. A "Conditions" paragraph explains why: after the update the mistake set is an interval or a single step.

## B. Overclaims

* **B1.** Accepted. "Within the hidden-insight class, what separates the hard version from an easy one is …". Section 5 adds that this does not show persistence decides the cost in general (predictable steps; large r).
* **B2.** Accepted. The abstract adds "by more than a factor O(log(n/ε))", and item 1 adds that the class depends on ε.
* **B3.** Accepted. Item 3 says: no new *kind* of query, but a substantive assumption about how the human works on the imitator's states, and a joint property of human and learner (Lemma 5). Section 2 says the same.
* **B4.** Accepted. Item 6 now says that persistence and checks are different assumptions, with the referee's examples in both directions.
* **B5.** Accepted. The empirical statements are marked as conjectures (item 6, Section 5). The "insights that change the direction of the work" sentence was removed; a direction noticed late is now given as a large-r case.
* **B6.** Accepted. Section 5 now limits the cost-n statement to deficits at unpredictable steps, of rare problem-specific kinds.
* **B7.** Accepted. Item 9's table now has a caption saying, for each row, the failure event, the kind of guarantee and the learner. It notes that row 3's runs still differ from the human's on about half the problems.
* **B8.** Accepted. Item 7 now names all four costs of the isolation route:
  * a different learner, which fails outright if the human is not isolated;
  * i.i.d. queries from a fixed μ, each costing up to n task queries if μ is the human's run distribution;
  * correctness only on μ's support;
  * the correct definition.

  Its failure probability is called β, to avoid the clash with the class parameter η.
* **B9.** Accepted; it was a slip. Theorem 3(c) now replaces the *harmonic* half, which keeps both 2n·K and 2r·K. It lists "last r alone: r·K under (C_r), no worst case" separately.
* **B10.** Accepted. "Whether a run succeeds depends on how many mistakes it contains; what it costs to find them depends also on where they sit."
* **B11.** Accepted. "Charged about 2·ln n". The cost-n statement is up to log(n/ε), for unpredictable locations. "Isolated mistakes" became "single mistakes".
* **B12.** Accepted. The scaffold-design paragraph now says the instruction changes P, is close to asking for a check, and is untested.
* **B13.** Accepted.
  * Item 2 and Section 2 speak of the *charge in an upper bound*.
  * "Independent of n" was removed from the K/ε statement. K contains log₂ n; the actual count is one task query per insight met.

## C. Experiment

* **C1.** Accepted. LAST on silent humans learns exactly the insights with t_p = n−1 (4.4, 1.1, 0.1, 0.1 per human); failure stays near the fraction with an insight before step n−1.
* **C2.** Accepted. Catch-up humans are now 200 per n, and the table reports mean ± s.e. and median. CI is 1,318 to 2,496, rising with n, with medians 1,216 to 1,848. These match the referee's 200-human run within noise.
* **C3.** Ratios recomputed: EW/LAST is 2.2, 2.1, 1.9 and 1.8.
* **C4.** Accepted: "all but two of the roughly 50 problems with an insight", with the coupon-collector prediction.
* **C5.** Accepted: "the runs on problems with an insight".
* **C6.** Accepted. The sentence now says every such failed run has its last mistake at the last step, so end-weighting charges it 2H_n. Chained imitation's heavy tail comes from the (n−t)/n hit rate.
* **C7.** Accepted. The setup says the stopping rule is an oracle that measures cost, not Theorem 3(b)'s random stopping.
* **C8.** Accepted: "at each n they are E1's humans: seed 1000·n + s".

## D. Minor

* **D1.**
  * Lemma 2 is now stated for any deterministic predicate of the run, with the weaker hypothesis "some H_{k₀} with k₀ ≥ n − r succeeds".
  * (S) asks for a deterministic predicate.
* **D2.** ⌊K(P)⌋, and "k_t drawn after x₀ᵗ is fixed".
* **D3.** "Choosing N this way needs bounds on K(P) and r."
* **D4.** The catch-up definition now has t_p < j < n.
* **D5.** "Every failed run of the class-prior decoder has a single mistake."
* **D6.** The "about log r" claim was removed. The note says that an adaptive schedule with a C·r·log₂ r guarantee would need C growing like log log n, and leaves the question open.
* **D7.** Open item 2 now says "conditional on the past, … over the draw of the problem".
* **D8.** The isolation failure probability is β; "isolated mistakes" became "single mistakes".
* **D9.** The DAgger analogy is now "in the spirit of", with the difference stated.
* **D10.** The README's status paragraph now covers both notes.
* **D11.** No change needed.
