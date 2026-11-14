# Response to the referee report on the second note

The report ([`referee-report-equational.md`](referee-report-equational.md)) is on the first complete draft of `equational.md` (commit `ultranatural: complete draft of the equational-inductor note`). It found no fatal error, two major findings, fifteen minor ones and sixteen points of wording, and it added a result of its own. Every finding was checked before acting on it, and all were accepted, with one adjustment (m1 below).

## Major

| finding | change |
|---|---|
| M1. Proposition 7(3) was false as stated: the bound on the belief in the true label needs the data to agree with plus, so that the two laws of addition fit them. | The statement now assumes data on which g agrees with plus, "so that x is the first exception to be seen", and the proof says where this is used. The loss is stated as "at least", and the text no longer says the inductor is "confident of the wrong answer": the theorems do not divide the remaining belief between plus's value and "undetermined". |
| M2. Section 6.2 gave the number of search nodes (200,093) as the number of identity sets, and the number of pruned nodes as the number of inconsistent sets. | The section now gives 476,610 sets, of which 114,635 / 114,465 / 114,416 are found consistent with proof bounds 14 / 16 / 18, and says that the enumerated sets carry prior weight 0.3529 of 0.3810. |

## Minor

| finding | change |
|---|---|
| m1. "Checked for n ≤ 3000" is not a proof. | Corollary 4's proof now has the closed forms: T = 4z + zT + zT² at z = 1/5, ε(n+1) ≤ 1.2845·(5/7)^n, and (48/49)·3^(−n) for successor. *Adjustment:* the report's closing inequality for successor, 2^(12.9 − 1.585n), fails for n above about 125 (1.585 exceeds log₂ 3); the note keeps 2^(13 − 1.58n), which the closed form implies for all n. |
| m2. Proposition 7(2) needs g computable for the claim about SOI. | Inserted. |
| m3. Proposition 8(2): the Herbrand–Gödel–Kleene theorem does not give consistency under full equational logic. | Restated for total computable functions, with the construction (normal form, conditional, a total search function) and a note on what Kleene's sections do and do not give. |
| m4. "More than log₂ n" for the doubling vocabulary was not derived. | Derived after Proposition 9. |
| m5. "n² + 8n + 36" was only asserted by a script. | Now Proposition 5(4), with the set and the count. |
| m6. Stale strings "lower bound N + 2" in `theories.py`. | Fixed; `results/theories.out` regenerated. |
| m7. Undecidability was asserted without proof. | The bullet now says what is semi-decidable from which side, and cites the report's reduction without reproducing it. |
| m8. The proof bound was described in one direction only. | Section 6.2 now says both: a set may be inconsistent only by a longer proof, and may prove a datum or value only by a longer proof. The report's figure for the second effect is quoted. |
| m9. The recheck covered only sets that already deviated. | The report's recheck of all 2,498 fitting sets, and its bound-free check that the fitting sets of successor have successor as a standard model, are quoted and linked. |
| m10. `eq_unary.c` performs some unions through an over-length term. | Described in the program's header and in Section 6.2. |
| m11. `test_radius.py` overflowed for squaring. | The script uses exact integers for squaring; the row now also shows 2³² + 1 and 2⁶⁴ + 1. All other rows of the output are unchanged. |
| m12. Missing bounds checks in `eq_unary.c`. | Three guards added (number of identities, L ≤ 30, depth). |
| m13. "Computed exactly". | "To machine precision from exact partial sums". |
| m14. The comparison with SOI assumed the data are the square. | Said so. |
| m15. Theorem 3 is tight for every m. | The report's two families of identities are given after the theorem, with credit; the summary now says "exactly m − 1". |

## Wording

w1 (N − 9 in place of N), w2 ("at least about N/2 bits"), w3 ("its loss grows without bound" in place of "declines to predict"), w4 ("at least what it costs to name x, and in our examples at most about the square of that"), w5 (the statement of Theorem 2 in the summary), w6 ("a set of 36 symbols fits it; none of at most 12 was found"), w7 (both theorems cited; "the side of the data square"; where the bound starts to say something), w8 (Lemma 1 and Theorem 2 only with background symbols), w9 ("like SOI up to a constant factor in description length", and that no prior was fixed), w10 ("at every scale n ≥ 10", and what closeness means there), w11 (clause dropped), w12, w13 (a data set is a finite function), w14, w15, w16 ("mostly of one kind"): all applied.

## The report's additions

| addition | change |
|---|---|
| 4.4. For doubling there is a deviating set of 1.5j² + 8.5j + 7 symbols for n = 2^j. | Now Proposition 10, credited to the referee, with the proof written out. We verified it independently for j ≤ 6 (model, truth of the identities, derivations, sizes). The summary, the naming principle, Section 7 and the open questions were changed accordingly: the strong pinning is specific to targets that cannot name large numbers by their own values. The former open question about doubling is replaced by the question which targets are pinned linearly. |
| 4.5. Nothing bounds from below the belief in the right sum. | New paragraph "What is not bounded" in Section 3, a sentence in the summary, a bullet in Section 7 and a new open question. |
| 4.3. The bounds say nothing for small n. | Stated after the table of Section 3 and in the summary (n = 59, 76 and 9). |

## Added after the report

* **Proposition 4a** (a few missing pairs), with a brute-force check (`code/holes_check.py`). It was not in the draft the report covers.

A second pass by the same referee, on Proposition 4a, on Proposition 10 as written up, and on the other changed passages, is recorded in Section 6 of the report; what was changed in response to it is listed below.

## Second pass

The second pass (Section 6 of the report) is on the revised note. It found no fatal error; Proposition 4a, Proposition 10 as written up, the corrected Proposition 7(3), the closed forms of Corollary 4, and Propositions 5(4) and 8(2) are confirmed, and every saved output regenerates byte for byte. It confirmed our rejection of the first report's constant for successor (its e1). Changes made:

| finding | change |
|---|---|
| S1 (major). Proposition 4a is correct but too weak to support the sentences that cited it: its bound says nothing below n = 7200. The sentences are true by a simpler argument. | The referee's Proposition 4b (the pairs that matter) is now the main statement, with its consequences: half the square is enough, and a missing pair matters only through its sum a + b. Proposition 4a is kept for its description of the surviving false identities, with a plain statement of how weak its bound is. The summary, Section 7, open question 1 and the README were reworded. |
| s1. The successor row n = 3 does change between L = 16 and L = 18. | Sentence corrected. |
| s2. For identity the statement holds only after the recheck. | Said so. |
| s3. The test radius of doubling was used beyond where it had been computed. | One-line proof added after Proposition 10. |
| s4. T = 2 at z = 1/5 presumed convergence. | Replaced by the induction on partial sums. |
| s5. The paragraph after Proposition 7 lacked "once the square below N has been seen". | Added. |
| s6. "About as strongly as in SOI". | "Only polylogarithmically". |
| s7. The header comment of `eq_unary.c` named one of two cases. | Both named. |
| s8. No command for `holes_check.py` in the README. | Added. |
| 6.5. Max and min have linear test radius. | Added as a remark after Theorem 3, credited, and open question 2 updated (monus and multiplication remain). |

The note has not been refereed after these last changes.
