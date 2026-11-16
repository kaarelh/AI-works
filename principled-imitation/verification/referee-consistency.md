# Referee report: consistency of note.md

Role: referee for consistency. A mechanical pass over `note.md` (719 lines, as assembled on branch `claude/eager-lamport-lo512k`, 16 Nov 2026) for labels, cross-references, quoted bounds, letters, the numbers of Section 11, and leftovers. Line numbers refer to `note.md`. Corrections are given for the section sources in `research/sections/` (note.md is generated and is not edited).

Method. I read note.md in full. Pointers to the proof files were extracted and checked by the script `verification/code/referee-consistency_pointers.py` (output `verification/code/referee-consistency_pointers.out`); the subject of each pointer was then checked by reading the statement in the proof file. Numbers of Section 11 were compared by hand with `results/*.out` (I did not rerun the scripts). Arithmetic was checked by hand or with one-line Python. I did not read any literature source in this session; the report makes no claim about the literature.


Where the fix goes. Section 0: `research/sections/intro.md`; Sections 1, 2, 3.1, 3.3 to 3.6: `rehearsal-core.md`; 3.2 and 5.2: `hellinger-runs.md`; 4 and the N3 / "What S2 needs" block of 6.1: `lower-bounds.md`; 5.1: `one-mind.md`; 6, 7: `shift-abstain.md`; 8.1 to 8.3, 8.6, 8.7: `property-batch.md`; 8.4, 8.5: `property-online.md`; 9, 10 and the caveats of 1: `assumptions.md`; 11: `toy.md`; 12: `related-work.md`; 13: `open.md`; the reference list: `research/orchestration/assemble.py` / `research/sections/references-short.md`.

Grades: MAJOR (a reader is told something false or is left without what the text promises), MINOR (inconsistent or misleading, but the correct reading is recoverable), NIT (wording).

## 1. Labels

Every label used in the note is stated in it. Where each is stated:

| label | section | label | section |
|---|---|---|---|
| A1, A2, A3 (and C1-C3) | 1 | N5 | 4.4 |
| R1 | 3.1 | N6 | 4.5 (and a second, different statement in 3.2, see F1) |
| L4, R2 | 3.2 | N2d | 4.6 |
| R7 | 3.3 | R4, R5, R6 | 5.1 |
| R3, R3a | 3.4 | H1, H2 | 5.2 |
| V1 | 3.5 | S4, S1, S3, N3 | 6.1 |
| N1 | 4.1 | S2 | 6.1, as the paragraph "What S2 needs" |
| N2, N2a | 4.2 | S5, N7 | 6.2 |
| N2b, N2c | 4.3 | Ab1, Ab2, Ab3 | 7.1, 7.2, 7.3 |
| N4, Ab4 | 7.4 | Pr1, Pr3, Pr4 | 8.1, 8.2, 8.3 |
| Pr5, Pr6 | 8.4 | Pr2 (a), (b), (c) | 8.6, as paragraphs |
| Pr7 | 8.7 | N8 | 9.1 |
| I1 | 9.2 | E1, E2 | 9.3 |

Counted with a regular expression over note.md: no label occurs that is not stated (all 49 distinct tokens of the forms R*, V*, L4, N*, H*, S*, Ab*, Pr*, E*, I*, A*, C* resolve). No label is stated twice except **N6** (F1). Labels cited with a section number: "(N6, Section 4)" in 3.2 points to the right section but to a different statement (F1); "(S5, Section 6.2)", "(Pr7, Section 8.7)", "(Pr7, Section 8)", "(E1, Section 9)", "N2b in Section 4, N8 in Section 9", "Ab2(a)" in 7.5, "Corollary 3.4" in 8.4: all correct.

S2 and Pr2. Pr2 is cited at line 26 (memorisers: Pr2(b), fits) and line 711 (Pr2(c), fits). S2 is cited in S4(ii) (line 332) for "all laws of ℓ bits cost about 2^ℓ", and in Section 0 within "S1 to S3". The paragraph "What S2 needs" (line 356) gives the price 2^(2|p_D|+1), not 2^ℓ; see F4. The labels S4 and S5 are not in the outline's list of new labels (Addendum 3) but are used consistently.

## 2. Cross-references

Script: `verification/code/referee-consistency_pointers.py`, output `verification/code/referee-consistency_pointers.out`. It finds every "Theorem/Proposition/Lemma/Example/Corollary/Remark x.y" in note.md, resolves the proof file (explicit `proofs/KEY.md` in the sentence; "there" in Section 4; otherwise the default declared by the note for that section, or, where the note declares none, the file named by the nearest explicit pointer), and checks that the number exists as a bold statement title in that file. It also checks every "Section x.y" against the note's headings. Result: 115 pointer phrases to proof files, carrying 198 statement numbers; every number exists as a bold statement title in the resolved file (the four entries marked NOFILE in the output are citations of Paper 1, Ross et al. and Foster et al. in Section 12, that is, literature); every "Section x.y" exists. I then read the title and first lines of each cited statement (and the full statement for about 40 of them) to check the subject. All subjects fit, with the exceptions listed as findings F1, F10, F11, F12, F23. Pointers to the literature (19, marked LIT or NOFILE in the output) were not checked; I did not open any source.

Two declarations mislead the reader about where bare numbers point (F10): Section 8.2 says "numbers cited below refer to" property-batch.md, but the bare numbers of Sections 8.4 and 8.5 (Propositions 3.5, 3.6, 3.9, Corollary 3.4, Theorem 2.1, Examples 2.3, 2.5, 6.5, 7.1, Theorems 6.2, 6.3, 7.6, Propositions 4.2, 4.4, 6.7, 7.3, 8.1) are statements of property-online.md; and Section 5.1 and Section 7 declare no file for their bare numbers.

## 3. The same quantity everywhere

For each bound: where it is quoted (line numbers of note.md), and whether constant, hypothesis and quantifier agree with the statement. "Agrees" means I compared the text with the statement in the note and recomputed any arithmetic.

| bound (stated at) | quoted at | verdict |
|---|---|---|
| R1, L·K ln 2/n (84) | 13, 90, 94, 100, 288, 454, 547, 621, 657, 659 (table) | agrees |
| R2 TV, √(2·L·K ln 2/n) (113) | 13, 120 (r runs: √(2r·L·K ln 2/n), consistent with horizon rL), 290, 454 | agrees; (1+ε)·L·K ln 2/ε² (113, 236) recomputed from s + √(s²+2s) ≤ ε |
| R2(c), 2Q_P(G) + 2LK ln 2/n (114) | from L4(c) with 4σ ≤ 4s | agrees |
| R3, δ + K ln 2/(θn) (136) | 17, 289 (table), 567, 667 (0.82%), 645 (K/(θδ)) | agrees |
| R3 for samplers, √(K ln 2/(2n))/θ (144) | 17, 567 (K ln 2/(2θ²δ²)), 621 (L·√(K ln 2/(2n))), 703 | agrees |
| R4, 2L²K ln 2/((L+1)n) (256-258) | 288, 665 (11.8, 73.7, 325 recomputed) | agrees |
| R6(b), 2L(K ln 2 + ln(1/δ))/n with probability 1 − 2δ (278) | 28, 288 | line 28 drops "with probability at least 1 − 2δ" (F6) |
| R6(a), L·(2^K − 1) (276) | 665 (toy: "L times the number of functions heavier than f") | the toy quotes a sharper form that the note does not state (F11) |
| R7, L/n and N·L/n (126) | 15, 637 | agrees, both "fixed in advance" / "each property fixed in advance" |
| V1(a), L·ln(1/δ)/m (158) | 15, 168 (300 rounds), 639, 645, 669 (ln 20/1000) | agrees; 300 rounds: L·ln 20/300 = 0.00999·L, divided by θL = 0.0999 |
| N2, L/(4δ) − 3L/2, or L/(4δ) − L if L/(2δ) integer; δ ≤ 1/6 (196) | 21, 242, 350 (S3), 354 | line 21 quotes L/(4δ) − L without the integrality condition and gives the class size as log₂(L/2δ) bits (F5); 350 omits integrality (F26) |
| N2b (212) | 30, 216, 243, 246, 621, 645, 701 | agrees |
| N5 (228) | 230 (R3 side), 685 | agrees |
| N6 (234) | 122 (a different statement under the same label), 320, 715 | F1 |
| N7, 3N/16 for Q ≤ N/2 − 1 (366) | 24, 372, 424 | 24 and 424 omit "at most 2^(K−1) − 1 questions" (F30) |
| N8 (579) | 30, 612, 645, 649 | agrees; 2g·K ln 2/δ + 1 matches Theorem 6.1(4) of assumptions.md |
| Pr5(i), (ii) (502-504) | 26, 699 | agrees |
| Pr6 (518-520) | 26, 526 | agrees ((a) recomputed from Pr5(i) and E S_n = (n/L)·E Δ_n) |
| H1 (298-300) | 290, 454, 476 | agrees |
| H2 (310-312) | 290 (table), 316 | agrees; λ = 2, s = ½ arithmetic recomputed |
| I1, 2^K·(1 − δ/(2L))^n (589) | 30, 639, 697 | agrees; but δ there is the separation, not a failure probability (F15) |
| E1 (595) | 50, 713 | 713 drops "deterministic" and says "R1 and V1" for "R1, R3 and V1(a)" (F9) |
| 1443 bits, 0.72 bits (571-572) | 30 ("about 1.4·10³ bits", "less than one bit") | agrees: 10⁵·0.01/ln 2 = 1442.7; 50·0.01/ln 2 = 0.721; 2·10⁹·0.01/ln 2 = 2.89·10⁷; 10⁹·ln 2/0.01 h = 3.47·10⁷ years of 2000 h |
| L4 constant 2.9642 (108) | 689 ("c₀ = 2.9641"), 715 ("between 2.9639 and 2.9642") | 689 disagrees (F7) |
| S2 / shifts of ℓ bits | 22, 332 ("2^ℓ") against 356 ("2^(2|p_D|+1)") | F4 |
| last round | 94 ((L − 1)/8, divergence), 705 ("between a constant and about L·ln n") | F13 |
| R6(c) status | 274 ("not independently checked") against 707 ("checked by one reader besides its author") | F8 |

Also checked and consistent: Section 3.1, "350 years" for L = 10, K = 10⁴, 0.1 unfaithful calls per run (6.93·10⁵ hours, i.e. 347 years of 2000 hours; F22 for the unit); Section 3.4, Example 8.5(d) numbers 399, 0.0007, 0.021 against rehearsal-core.md; Theorem 9.2 constant 0.088 and Proposition 9.3 constant K(1 − 2γ)²/(32θ²) against the summary table of rehearsal-core.md; Pr2(b) bound 0.51 recomputed at u = 5; Pr3 and Pr4 constants against property-batch.md, Theorem 2.3 and its summary; N2d(c) arithmetic; N8 against Theorem 6.1 of assumptions.md; N6 (Section 4.5) constants 512, 8192, 1/64 against Theorems 6.1 and 6.3 of lower-bounds.md; the Section 3.2 constants 8·10⁴, 1/65, 740, 1/12 against Propositions 3.4 and 3.5 of hellinger-runs.md; Section 1 caveat numbers 0.44 and 1/2 against assumptions.md.

Not checked: the constants of R5, Ab2(c), Ab2(d), N2a, N2c, N3, S5's factor 2 ln 2, Pr2(a) numbers 0.71/0.18/0.11, Pr7(b), I1's price, E2, and the claim in 13.10 that the whole-run bound for nested episodes carries "the smaller of four times the largest number of calls in one episode and half the number of episodes" (Theorem 1.9(b) of assumptions.md, which I read, has the factor 4m_e only; I did not find the second term and did not search further).

## 4. Letters (outline, Addendum 3)

The fixed letters k, m, ℓ, η, α, Λ(B), δ, θ, ε are used in their fixed meaning almost everywhere. Clashes and misleading uses:

* **ρ** (MINOR, F14). Section 1 fixes ρ as the scaffold's random bits, used throughout Section 3 ("the same (z, ρ)"). V1(a) (line 158) uses ρ for "the probability that a round records a disagreement" and ρ̂ for its estimate.
* **δ** (MINOR, F15). Section 9.2, I1 (line 589): "δ-separated", "(1 − δ/(2L))^n"; in the same Section 9, δ is the failure probability (9.1, N8: "δ < 1/10", "failure at most δ") as Addendum 3 fixes.
* **σ** (NIT, F16). L4 (3.2) σ := E Σ h_j; R3a (3.4) σ is the fraction of the drift; Ab4 (7.4) σ is the silent failure; Rule NH (8.4) σ is a sign.
* **s** (NIT, F16). R2 (3.2) s := L·K ln 2/(2n); V1(a) (3.5) s := expected sum of 1 − Σ_y P(y|x)², divided by L. Both in Section 3.
* **η, β** (NIT, F17). Section 8.4 uses η as the learning rate of the rule with one rate (line 514) and 8.5 uses β as "the strength of the tilt" and η again (line 532), while η is the threshold of Thr_η and β(A) the expected number of unfaithful calls.
* **K(·)** (MINOR, F18). K is the human's bits; K(Q) (line 188), K(R) (line 543), K(U), K(E) (line 683) are a complexity never defined in the note, and K(ν) := log₂(1/w(ν)) (line 480) is a third meaning.
* **k** (NIT). Ab4 table row 3 (line 426) "at most k wrong" uses k for permitted silent mistakes, not tolerated faults; acceptable, as the row defines it.
* **B, H** (NIT, F28). Section 12, Li and Zhang: "a finite class of size B, horizon H": B is the density ratio or a test elsewhere, H the class and H² the Hellinger distance.
* **ℓ** (no finding). Section 1, A3 caveat: "a seed of ℓ bits": a description length, compatible with the fixed meaning.

## 5. Section 11 against results/*.out

Compared every number of Section 11 (and the toy numbers quoted in Sections 0 and 8.5) with `results/toy.out`, `results/toy_stakes.out`, `results/toy_property.out` and, for the 57%, `proofs/code/property-online_rehearsal.out`. I did not rerun the scripts. All OK:

| claim in note | output | |
|---|---|---|
| 1117 functions, K = 3.78 | "1117 functions", "K = 3.78 bits" | OK |
| weights 0.59 / 0.30 / 0.07 after 100 and 10,000 | same | OK |
| unfaithful run 35%, 98%, 100% (depth 2, 4, 6; also line 28 "35% to 100%") | 0.347, 0.981, 1.000 | OK |
| summed unfaithful calls 2.3, 21.7, 91.8 at n = 6400 | 2.28, 21.70, 91.78 | OK |
| bounds 7.9, 39.3, 165.0 | same | OK |
| average Pr[run unfaithful] 0.0004, 0.0025, 0.0043 (line 28 "below half a percent") | same | OK |
| one-mind 1.6, 15.4, 22.3; bounds 11.8, 73.7, 325 | 1.57, 15.37, 22.30; 11.8, 73.7, 324.8 | OK |
| map 3.3, 21.1, 27.2; bounds 6, 30, 126 | 3.28, 21.07, 27.20; 6, 30, 126 | OK (but see F11 for which statement the bound is) |
| stakes: 0.1%, 1.2%, 11.9% / 0.11%, 0.03%, 0.03%; bound 0.82% | 0.0011, 0.0117, 0.1187 / 0.0011, 0.0003, 0.0003; 0.0082 | OK |
| certificate: n = 400, L = 256, m = 1000, 160 repetitions, 140 passed, ln(20)/1000 = 0.003, true rate 0.00014, never above | 0.875 of 4·40 = 160 (toy_stakes.py: reps = 4·trials, trials = 40), 0/140, 0.00300, 0.00014 | OK |
| property: 805 tests, mod 8, depth 3; exact sums 1.0 (deterministic), 0.90 (noisy); max |S_n|/n 0.0003, bound 0.024 at 64,000; root 62% vs 48% | 805, L = 7; 1.0000; 0.8995; 0.0003, 0.0241; 0.6197 vs 0.4773 | OK |
| Rule NH root 57% after 8000 rounds | property-online_rehearsal.out: "n = 8000, rule NH ... root exact, deployed: 0.5710" | OK |
| toy_property.py is "the rule with one rate" | code/toy_property.py lines 5-10, 90-96: sinh(η·S), η = 1/√n | OK |

## 6. Leftovers

* Line 719: "## References / (The list is being consolidated.)" is a placeholder (F2). It comes from `research/orchestration/assemble.py`, line 98, which prints it when `research/sections/references-short.md` does not exist; `related-work.md` has a reference list (its lines 19-73) that assemble.py cuts away. Without it the note's author-year citations, "Paper 1", "Paper 2", "`ultranatural/note.md`" and "the companion note on isolation" (lines 88, 188, 587, 639, 677, 683, 697) cannot be resolved by a reader. I did not check that the list in related-work.md covers every citation of the note.
* Line 679: "Theorem B is Proposition 2.1 for a countable class, and Theorem A its Bayes form" uses the provers' names, renamed H2 and H1 by Addendum 3 (F3).
* Line 108: "Parts (b) and (c), added during verification and checked by the editor" describes the production process (F24).
* Lines 412, 543, 625: "Observation B of the researcher's notes", "as the researcher's notes claim", "the tests are those that the researcher's notes apply" cite an unpublished document (F24). Line 220 "found and checked by the two verifiers" is acceptable given the status paragraph.
* No occurrence of "the lead", "candidate theory", "the draft", "prover", "TODO", word counts or paths under `research/` in note.md (searched with grep).
* Statements that only one checker or only the editor has seen are marked in some places ("not independently checked" for R6(c), Pr7(b)) and not in others (F25).

## 7. Findings, with corrections

**F1 (MAJOR). N6 is stated twice, with different classes, scaffolds and constants.** Line 122 (Section 3.2, source `hellinger-runs.md`): "(N6, Section 4; proved here). Let K ≥ 8, L a multiple of K with L ≥ 4K, and ε ≤ 1/65 ... more than L·K/(8·10⁴·ε²) answers ... Proof: `proofs/hellinger-runs.md`, Propositions 3.4 and 3.5." Line 234 (Section 4.5, source `lower-bounds.md`): "Theorem N6 ... n ≥ L·K/(8192·ε²) for runs of L calls at one uniform input (b = 16ε/√L, ε ≤ 1/64) ... Theorems 6.1, 6.3 there." Both are correct statements of their files, but one label carries two. Correction for line 122: "**The factor L under the root is necessary** (N6, Section 4.5). For the 2^K samplers of N6 and a scaffold that asks one uniform input L times, every protocol needs at least L·K/(8192·ε²) answers before the run law of its imitator is within ε of Q_P in expected total variation for every member (ε ≤ 1/64); two samplers already need more than L/(740·ε²) (L odd, ε ≤ 1/12; `proofs/hellinger-runs.md`, Proposition 3.5, which with Proposition 3.4 gives a version with weaker constants on a scaffold that asks each of K inputs L/K times)." Keep the next sentence ("A run of L calls is a sample ...").

**F2 (MAJOR). The reference list is a placeholder.** Line 719 "(The list is being consolidated.)". Correction: write `research/sections/references-short.md` (read by assemble.py, line 98) with the entries of `research/sections/related-work.md`, lines 19-73, add entries for every work cited only outside Section 12 (at least Paper 1 and Paper 2 of the repository with their paths, `ultranatural/note.md`, Landauer 1986, Thompson 1933, Ville 1939, Hoeffding 1963, Littlestone 1988, Langford 2005, Barron and Cover 1991, Zhang 2006, Catoni 1997, Yang 2000, Juditsky, Rigollet and Tsybakov 2008, Grünwald and Kotłowski 2011, Foster, Han, Qian and Rakhlin 2024, Mahalanabis and Štefankovič 2008, Hegedűs 1995, Moshkov 1983, Bshouty 2017, Li, Littman and Walsh 2008, Sayedi et al. 2010, Zhang and Chaudhuri 2016, El-Yaniv and Wiener 2010; I did not check which of these are already in the list), and reassemble.

**F3 (MINOR). Section 12 uses the old labels Theorem A and Theorem B.** Line 679: "Theorem B is Proposition 2.1 for a countable class, and Theorem A its Bayes form." Correction: "Theorem H2 is Proposition 2.1 for a countable class, and Theorem H1 its Bayes form."

**F4 (MINOR). The price of all shifts of ℓ bits is quoted as 2^ℓ; the note's own upper bound is 2^(2ℓ+1).** Line 22: "all shifts describable in ℓ bits cost 2^ℓ (S1 to S3, N3)"; line 332: "all laws of ℓ bits cost about 2^ℓ (N3, S2)". The paragraph "What S2 needs" (line 356) gives the factor 2^(2|p_D|+1) (weights π_p = 2^(−2|p|−1)), and N3 (line 354) gives the lower bound 2a·2^ℓ up to a factor polynomial in ℓ. Correction, line 22: "all shifts describable in ℓ bits cost at least about 2^ℓ and at most 2^(2ℓ+1) (S1 to S3, N3)"; line 332: "all laws of ℓ bits cost at least about 2^ℓ (N3) and at most 2^(2ℓ+1) (S2)".

**F5 (MINOR). Section 0 quotes N2 without its conditions.** Line 21: "there is a class of candidates of log₂(L/2δ) bits for which every protocol needs at least L/(4δ) − L questions". N2 (line 196) has n ≥ L/(4δ) − 3L/2 for δ ≤ 1/6, and L/(4δ) − L only if L/(2δ) is an integer; K ≤ log₂(L/(2δ) + 2) (line 202). Correction: "there is a class of candidates of at most log₂(L/(2δ) + 2) bits for which every protocol needs at least L/(4δ) − 3L/2 questions, and L/(4δ) − L when L/(2δ) is an integer, to keep the failure probability of a run below δ ≤ 1/6 (N2)".

**F6 (MINOR). Section 0 quotes R6(b) without its confidence.** Line 28: "a single posterior draw at the end has an unfaithful run with probability below 2L(K ln 2 + ln(1/δ))/n (R6)". Correction: "with probability at least 1 − 2δ over the rehearsal and the draw, a single posterior draw at the end has an unfaithful run with probability below 2L(K ln 2 + ln(1/δ))/n (R6(b))".

**F7 (MINOR). Section 12 gives the constant of L4 as 2.9641.** Line 689: "The note proves c₀ = 4 and, by a longer argument, c₀ = 2.9641, and gives an example with ratio 2.9639, computed in floating point." Section 3.2 (line 108) and Section 13 (line 715) say 2.9642; the proof file has c* = 2.964147… < 2.9642, and its Checking section records "c₀* ≤ c* = 2.9641" as an error corrected everywhere (hellinger-runs.md, line 768); the example was computed in 30-digit arithmetic (line 24 there). The editor of hellinger-runs asked for this change (research/sections/hellinger-runs.md, line 98). Correction: "The note proves c₀ = 4 and, by a longer argument, c₀ = 2.96415 (below 2.9642), and gives an example with ratio 2.9639, computed in 30-digit arithmetic."

**F8 (MINOR). Section 13 misstates the status of R6(c).** Line 707: "(R6(c), checked by one reader besides its author)". Section 5.1 (line 274): "(c) not independently checked"; one-mind.md, Theorem 3.8: "proved by the editor; no verifier has checked the proof", and its Checking table: "no verifier". Correction (open.md): "(R6(c), proved by the editor of that part and not checked by a verifier)".

**F9 (MINOR). Section 13 overstates E1.** Line 713: "R1 and V1 hold with episodes for calls (E1)". E1 (line 595) and Section 1 (line 50): for a deterministic human, R1, R3 and V1(a). Correction: "for a deterministic human, R1, R3 and V1(a) hold with episodes for calls (E1)". The rest of item 10 (the extra factor for nested episodes) was not checked.

**F10 (MINOR). Bare numbers in Sections 8.4 and 8.5 point to the wrong file by the note's own declaration; Sections 5.1 and 7 declare none.** Line 464 says numbers cited below refer to property-batch.md; Sections 8.4-8.5 cite property-online.md by bare number (17 numbers, Section 2 above). Corrections: at the start of Section 8.4 (property-online.md) add "In Sections 8.4 and 8.5 numbers refer to `proofs/property-online.md`."; at the start of Section 8.6 (property-batch.md) add "Numbers in Sections 8.6 and 8.7 refer to `proofs/property-batch.md`."; at the start of Section 5.1 (one-mind.md) add "Numbers refer to `proofs/one-mind.md`."; in the first paragraph of Section 7 (shift-abstain.md) add "Numbers refer to `proofs/shift-abstain.md`."

**F11 (MINOR). The toy quotes a form of R6(a) that the note does not state.** Line 665: "against the bound of Proposition R6(a), L times the number of functions heavier than f (6, 30, 126)". R6(a) at line 276 states L·(2^K − 1) (here 38, 191, 801). The proof (one-mind.md, Proposition 5.1) has L·(i₀ − 1) ≤ L·(2^K − 1). Correction in R6(a) (one-mind.md): "at most L·(i₀ − 1) ≤ L·(2^K − 1) of the rehearsal runs differ from the human system's in expectation, i₀ − 1 being the number of hypotheses ranked before f in an order by non-increasing weight".

**F12 (NIT). Pointer for L4.** Line 108: "Proof: `proofs/hellinger-runs.md`, Theorem 2.1 and Lemma 2.10." The scaffold forms stated as L4 are Corollaries 2.3 and 2.11 of that file (its line 7). Correction: "Proof: `proofs/hellinger-runs.md`, Corollaries 2.3 and 2.11, from Theorem 2.1 and Lemma 2.10."

**F13 (MINOR; the comparison rests on the summary table of rehearsal-core.md, I did not read Propositions 6.3 and 6.4 in full). The loss of the last round is quoted inconsistently.** Line 705: "the mixture after all n answers is known to lose a factor between a constant and about L·ln n in the probability of an unfaithful run". Line 94 quotes a factor (L − 1)/8 (for the divergence), and rehearsal-core.md, Proposition 6.3, gives a factor (L − 1)/(40√L) for the expected number of unfaithful calls of a deterministic human (in a class with samplers that are not functions). Correction: "is known to lose a factor of at least (L − 1)/(40√L) in the expected number of unfaithful calls, in an example whose class contains samplers that are not functions, and at most about 2L·ln n in the probability of an unfaithful run (`proofs/rehearsal-core.md`, Propositions 6.3 and 6.4)".

**F14 (MINOR). ρ has two meanings in Section 3.** Line 158: "Let ρ be the probability that a round records a disagreement ... With ρ̂ the recorded rate". Correction (rehearsal-core.md, V1(a)): replace ρ by r and ρ̂ by r̂ throughout V1(a).

**F15 (MINOR). δ has two meanings in Section 9.** Line 589 (I1): "the human f be δ-*separated*: D(f, g) is 0 or at least δ ... 2^K·(1−δ/(2L))^n"; line 591 "within distance δ". Correction (assumptions.md): use another letter, e.g. "γ-separated", "at least γ", "2^K·(1 − γ/(2L))^n", "within distance γ".

**F16 (NIT). σ and s are overloaded in Section 3.** L4 σ (line 102) and R3a σ (line 146); R2 s (line 110) and V1(a) s (line 158). Correction: in R3a write "(1 − ϕ)·a·L" and "ϕ·a·L" for σ (and adapt "(Proposition 12.2, where a and ϕ are μ and η)" and the next sentence); in V1(a) write "s′" or "v" for s.

**F17 (NIT). η and β are reused in Sections 8.4-8.5.** Line 514 "sinh(η·S_{t−1}(B))", "ln(2/π(B))/η + n·η/2", "η = 1/√n"; line 532 "divided by β·η, β being the strength of the tilt". Correction (property-online.md): write λ for the rate (λ = 1/√n) and κ for the strength of the tilt.

**F18 (MINOR). K(·) is used for three things and its complexity meaning is never defined.** Lines 188 ("K(Q)+c bits"), 543 ("C_R = 2^(K(R)+c)"), 683 ("K(Q,b)", "K(U) + K(E)") use prefix complexity; line 480 defines K(ν) := log₂(1/w(ν)). Correction: at line 188 (lower-bounds.md) add "where K(Q) is the length of the shortest program that decides Q"; at line 480 (property-batch.md) write K_ν := log₂(1/w(ν)) and use K_ν in r(ν) and Pr4.

**F19 (MINOR). sep(x; A) is used but never defined.** First use line 400 (Ab2(c)); also 412, 431-442, 587. Correction: in the first paragraph of Section 7 (shift-abstain.md) add "sep(x; A) denotes the least complexity of a decidable set that contains x and no element of A".

**F20 (NIT). "Protocol R" is used (lines 328, 402, 679) but never named.** Correction: Section 2 (rehearsal-core.md), first line: "**Rehearse** (Protocol R). For t = 1, …, n:".

**F21 (NIT). E1 calls K a weight.** Line 595: "K the weight of that function". Correction: "K := log₂(1/w) for the weight w of that function".

**F22 (NIT). Unit of "350 years".** Line 90: "cost 350 years already for K = 10⁴". The number is 6.93·10⁵ hours divided by 2000 hours per year; Section 9.1 uses working years. Correction: "cost 350 working years already for K = 10⁴".

**F23 (NIT). Pointer and quotation in 9.5.** Line 609: "Section 8 of the proof file classes twenty-two objections to "rehearsal is a human-imitation protocol that works as far as any protocol can"". Correction: "Section 8 of `proofs/assumptions.md` classes twenty-two objections to "rehearsal is a human-imitation protocol that works exactly as far as any protocol can"".

**F24 (MINOR). Remarks about the production of the note, and an unpublished source.** Line 108: "Parts (b) and (c), added during verification and checked by the editor, have the constants of a single call." Correction: "Parts (b) and (c) have the constants of a single call (proved here; checked by one reader only)". Lines 412, 543, 625: "Observation B of the researcher's notes", "as the researcher's notes claim", "The tests are those that the researcher's notes apply to any proposal". Correction: either add the researcher's notes to the reference list as an unpublished manuscript, or write "proved here" at 412, delete "as the researcher's notes claim" at 543, and at 625 "The seven tests below are those that the researcher who posed the problem applies to any proposal."

**F25 (MINOR). Statements seen by one checker only are not marked uniformly.** The note marks R6(c) and Pr7(b) as "not independently checked" but cites without a mark: `proofs/lower-bounds.md`, Proposition 3.10 (line 220; "not seen by the verifiers"); `proofs/rehearsal-core.md`, Proposition 13.4 (line 166), Example 8.5(d) (line 140) and Remark 4.4(d) (line 38; "no second verifier checked them", rehearsal-core.md line 882). Correction: add "(not independently checked)" after each of these four pointers.

**F26 (NIT). S3 omits a hypothesis.** Line 350: "failure probability at most δ ≤ 1/4 on Γ for every member needs n ≥ (L/(4δ) − L)/p". shift-abstain.md, Proposition 2.4(c) requires L/(2δ) to be an integer. Correction: "... at most δ ≤ 1/4, with L/(2δ) an integer, on Γ ...".

**F27 (NIT). Additive work quoted in two forms.** Line 701: "Under low stakes with bounded damage the only lower bound that contains K is n ≥ (1 − 2θ − 2δ)·K"; line 583 and assumptions.md, Proposition 6.4: "additive work ... (1−2k/L−2δ)·K". Correction (open.md): "For additive work (Section 9.1) the only lower bound that contains K is n ≥ (1 − 2k/L − 2δ)·K".

**F28 (NIT). Letters in the Li and Zhang paragraph.** Line 679: "For a deterministic expert in a finite class of size B, horizon H and cost μ of one deviation, the performance gap after N queries is at most μH·(log B + 2 log(1/δ))/N". Correction: "in a finite class of N_c members, horizon L and cost μ ... at most μL·(log N_c + 2 log(1/δ))/N".

**F29 (NIT). "With one check".** Line 701: "is in the proof file with one check (`proofs/lower-bounds.md`, Proposition 3.9)". lower-bounds.md: "from the check report; proof followed in the attack report, re-derived by the editor". Correction: "is in the proof file (`proofs/lower-bounds.md`, Proposition 3.9; from one referee's report, followed by the other)".

**F30 (MINOR). N7 quoted without its bound on the number of questions.** Line 24: "on a class of 2^K thresholds, the expected number of silent errors and abstentions, multiplied by the number of questions plus one, is at least 3·2^K/16"; line 424 (Ab4 table) likewise. N7(a) (line 366) holds for learners with at most Q ≤ N/2 − 1 questions (without it, a learner that asks every input has product 0). Correction: line 24 "... for every learner that asks at most 2^(K−1) − 1 questions, the expected number of silent errors and abstentions, multiplied by the number of questions plus one, is at least 3·2^K/16"; line 424 "2^K thresholds, at most 2^(K−1) − 1 questions: E[Sil + Abs]·(questions + 1) ≥ 3·2^K/16 (N7)".


## 8. Summary

Labels: all stated; N6 stated twice with different content (F1). Cross-references: every numbered pointer exists in its proof file and every "Section x.y" exists; subjects fit except the misdeclared files of Sections 8.4-8.5 (F10) and the L4 pointer (F12). Bounds: Section 0 drops conditions of N2, R6(b) and N7 (F5, F6, F30); the price of ℓ-bit shifts is quoted as 2^ℓ against the note's own 2^(2ℓ+1) (F4); Sections 12 and 13 disagree with the body on the L4 constant, the status of R6(c), E1 and the last round (F7, F8, F9, F13). Letters: ρ and δ clash inside one section (F14, F15); sep and K(·) are undefined (F18, F19). Section 11: every number matches the saved outputs. Leftovers: the reference list is a placeholder (F2), and the old labels Theorem A/B survive in Section 12 (F3).
