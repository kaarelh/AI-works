# Check of the finalized red-team.md (round 1)

*Published record of the first independent check of the finalized red-team note, made during finalization. `stage/red-team.md` is the red-team pass as the referees read it, published as [`red-team-first-version.md`](red-team-first-version.md).*

Checked: `research-notes/red-team.md` (626 lines) against the source `stage/red-team.md` (592 lines), the instructions, and the sources of every change.

**Verdict: minor fixes.** Every required change was made, and nothing outside the record table changed. All 14 replacements marked "verbatim" match their sources exactly. The two restated results, Proposition 4.1 and Remark 6.2, match their referee reports, and the status table checks out against every report and note it cites. Four small inaccuracies remain, plus some nits.

## What was checked

- **(a) Required changes.** All 11 instructions were carried out.
  - A script compared the 14 verbatim replacements with their source text: small-learner-width.md §7.3 (6 entries) and depth-two.md §6 (8 entries, the §5 heading included). All match exactly.
  - Proposition 4.1 (a)–(c), its proof and "Limits" were compared with RT-tube-logic §§2–4 (issues 1–9) and RT-tube-computation Q1–Q3, Issues 1–7 and §4.
  - Remark 6.2 was compared with RT-aggregate-logic issues 1–7 and §6 (a)–(d).
  - The "At finalization" notes were compared with their sources: item 1 with A §0.1–0.2 and §7; items 3–4 with B §0, Theorems 6.3, 6.4 and 7.4, and §7.5; item 8 and §8 with E §0 items 2 and 6 and with C §C.0.
- **(b) Strengthening.** None found. A paragraph-level diff by section found no change that the record table leaves out.
- **(c) Status table.** Each claim was checked in the cited report:
  - Lemma 1.0: RT-aggregate §3.6.
  - Lemma 1.1: RT-width-logic §2.9 and RT-depth2-logic §2.1.
  - Lemmas 1.2–1.3: RT-depth2-logic §§2.2–2.3, including the V>0 caveat.
  - Lemma 2.1(2): RT-depth2-logic §2.4.
  - Lemma 3.1 = B Lemma 5.2: RT-aggregate §3.3.
  - Theorem 3.2, first paragraph of the proof: RT-width-logic §2.2.
  - The verdicts, the report lists for the depth-two rounds and the width rounds, and the γ=1 treatment in E are as stated.
- **(d) Citations from other notes.** Every cited number still exists, either as text or as a pointer line. Mismatches are listed below.
- **(e) Paths.** All 27 Markdown link targets resolve from research-notes/, and there are no absolute paths. The scripts constants.py, bounds_table.py, memorize_opt.py and memorize_opt2.py exist, along with six run_*.txt files and no .out files for these scripts. Re-running constants.py and bounds_table.py reproduces every value in Appendix A.
- **(f) Record table.** It has one row for every changed hunk.

## Issues

1. **(minor) §4.3 "Limits of the statement", "Range and sample size".**
   - **Problem.** "about 2.9·10^26 for (b)" is the sample size of the *computation* referee's version of (b): cover H_{K,ε/24}, n ≥ 72ε^-2[...] (v_sample_size.py). The note states (b) in the *logic* referee's version: cover H_{E_*+2,ε/32}, n ≥ 32ε^-2[...]. With the script's own log_cover, that version needs about 4.4·10^26 at d=C=1, B=1.05, L=2 (and 7.4·10^55 against 1.6·10^55 at L=3).
   - **Fix.** Say "2.9·10^26 for the computation referee's variant of (b)", or give about 4·10^26.
2. **(minor) §4.3, paragraph after the proof.**
   - **Problem.** "For noise-like residuals (ρ_0≥1 for fair signs) Proposition 4.1 is vacuous". The referee verified this for the original bound, which then exceeds 9. Part (b) has now been adopted, and the sentence is not accurate for it. For fair signs with g≡0, ρ_0=1 and ρ slightly above 1, (b) gives risk ≤ ρ^2+ε against OPT=1.
   - **Fix.** "Part (a) is then vacuous (its bound exceeds 9), and the bound ρ^2+ε of (b) exceeds 1 ≥ L_D(0), so neither shows TUBE beating the zero predictor; consistent with A."
3. **(minor) §6.3, Proposition 6.1 pointer.**
   - **Problem.** "small-learner-width.md, which corrects it and keeps the number: Proposition 6.1 is its Theorem 1" contradicts itself. That note renumbers the result as Theorem 1.
   - **Fix.** "This line keeps the number; small-learner-width.md corrects the proposition, which is its Theorem 1, ...".
4. **(minor) §5 pointer summary.**
   - **Problem.** The "+o(1)" formulation is named without the qualifiers that depth-two.md §0 attaches to it: the o(1) is uniform over d ≤ log_2 n + O(1), and the bound is required at every learner width N ≥ n^α. §0 item 6 has these qualifiers; §5 does not.
   - **Fix.** Add them at the first mention.
5. **(nit) §2.2, last paragraph.** "The numerics in §5.4" now points to a section that no longer exists here; the runs are in depth-two.md §7.1. A bracketed pointer would be optional.
6. **(nit) §2.1 and §3.1.** The short form `noisy-interpolation/README.md` does not resolve from research-notes/. It is inherited from the source and is not a link; the full form `NNG/works-in-progress/noisy-interpolation/README.md` is used in §0 item 3 and §4.1.
7. **(nit) Status table, §3 row.** The first paragraph of the proof of Theorem 3.2 was also checked in RT-width-computation §1, and RT-depth2-computation Issue 6 checked the (3.1) arithmetic for g≡0. The row is incomplete, not wrong.
8. **(nit) §0 item 1 note.** "That note corrects the sentence ..." is an editorial attribution. A does not address the red-team sentence; it states the correction in its §0.1.

## Citation mismatches in other notes (not edited)

- **depth-two.md header (line 3).** It quotes the old §5 title, "Depth two ($L=2$) with $c=1$". red-team.md §5 now has the title that depth-two.md §6 prescribes.
- **depth-two.md Remark 5.5 (line 641) and §8 (line 840).** They cite "the display of RT Proposition 6.1", which no longer stands in red-team.md. The pointer line and depth-two.md itself both name small-learner-width.md Theorem 1(c), so the citation can still be followed.
- **E-finite-prior-scale.md §0 "Earlier sketches" (line 25) and §7 item 6 (line 691).** They credit the red-team §8 sketch with the positive range θ<(γ−1)/(2(L−2)). Finalized §8 now marks that range open, because it would need an energy bound on the finite-scale posterior.
- **A-tight-conditioning-fails.md Remark 6.6b (line 783).** It refers to red-team's "statement that such conditioning never memorizes". That sentence has been reworded to the energy statement, so the two agree in substance. The bound A quotes, (τ+ρ_0)^2+4ε/3, is still Proposition 4.1(a).
- **A §5.4 and §10 item 4.** A was edited at 19:24, after this edit (19:15). These places now match: Remark 6.2 with probability 1−2δ, and depth-two.md as the repair of §5.
- **All other citations resolve and say what is cited:** Lemmas 1.0–1.3 and 2.1, Theorem 2.2, Proposition 2.4, Lemma 3.1, Theorem 3.2, Corollaries 3.3–3.4, Remark 3.5, Proposition 4.1, Theorem 5.1, Corollary 5.2 and Proposition 5.3 (pointer lines), Proposition 6.1 (pointer line), Remark 6.2, §2.3 A2/A3, §3, §6.2, §6.4 and §8.
