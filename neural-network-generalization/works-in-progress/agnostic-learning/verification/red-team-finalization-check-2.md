# Check of the finalized red-team.md (round 2)

*Published record of the second independent check of the finalized red-team note, made during finalization. `stage/red-team.md` is the red-team pass as the referees read it, published as [`red-team-first-version.md`](red-team-first-version.md). The check's scripts are in [`../checks/red-team-finalization-check-2/`](../checks/red-team-finalization-check-2/); the copies of the two texts it compared are not published.*

Checked: `research-notes/red-team.md` (652 lines, 19:44) against the source `stage/red-team.md` (592 lines), the 11 instructions, the round-1 check (`red-team-finalization-check-1.md`) and the source of every change. Working files: `../checks/red-team-finalization-check-2/` (diff, `verbatim.py`, re-runs).

**Verdict: minor fixes.** No change is wrong or misleading, and no statement is strengthened beyond its source. Every round-1 point is fixed correctly. What is left: two departures from the instructions, both small and both recorded, and some nits.

## What was checked

- **(a) Required changes.** All 11 instructions were carried out.
  - A script (`verbatim.py`) compared the 14 verbatim replacements with their sources: small-learner-width.md §7.3 (6 entries) and depth-two.md §6 (7 entries and the §5 heading). All 14 match exactly.
  - Proposition 4.1 (a)–(c), the example, the proof, the paragraph after the proof and "Limits" were compared with RT-tube-logic issues 1–9 and §4 (Prop. 4.1′), and with RT-tube-computation Q1–Q3, Issues 1–7 and §4. All match.
  - Remark 6.2 (a)–(b), its header, its proof and the paragraph after it were compared with RT-aggregate-logic issues 1–7 and §6. They match. (c)–(d) appear only as the referee's observations.
  - The "At finalization" notes were compared with their sources and are accurate:
    - item 1 with A §0.1–0.2, Thm 4.4 and Cor. 4.5/4.5a;
    - item 2 with A §7.1, Thm 7.2 and Prop. 7.4;
    - item 3 with B §0 and Thms 6.3–6.4;
    - item 4 with B Thm 7.4 and §7.5 items 1–2;
    - item 8 and §8 with E §0 rows 2 and 6, and with C §C.0.
  - The §5 and Prop. 6.1 summaries match depth-two.md §0/§0.1 and small-learner-width.md §0, with every qualifier the instructions name.
- **(b) Strengthening.** None found. Every diff hunk (38) maps to a row of the record table.
- **(c) Status table.** Every cited section was opened and says what the table claims:
  - RT-aggregate §3.3 and §3.6;
  - RT-width-logic §2.2 and §2.9;
  - RT-width-computation §1;
  - RT-depth2-logic §§2.1–2.4, including the V>0 caveat;
  - RT-depth2-computation Issue 6;
  - the depth-two and width report lists, and both verdicts of the tube reports.
- **(d) Numbered results.** All 18 numbered results and the tags (1.1), (3.1), (3.2) are still in the note. So are all section numbers. Theorem 5.1, Corollary 5.2, Proposition 5.3 and Proposition 6.1 stay as pointer lines.
- **(e) Paths.** All 27 link targets resolve from research-notes/, and so do the backticked `../` paths and the `NNG/` targets. There are no absolute paths. constants.py, bounds_table.py, memorize_opt.py, memorize_opt2.py and the six run_*.txt files exist in `../checks/red-team-and-literature/`.
  - Re-running constants.py and bounds_table.py reproduces Appendix A.
  - bounds_table.py gives 0.4824596 for H=3, d=40, so 0.482 is the correct rounding.
  - The cover formula of v_sample_size.py gives 4.431e26 against 2.922e26 at L=2, and 7.398e55 against 1.601e55 at L=3, as the note states.
- **(f) Record.** It has one row per changed hunk. The new "Check of the finalization" section has no row of its own (issue 1).

## Issues

1. **(minor) The note does not end with the record.** Instruction 11 says the note ends with "Record of the finalization". A further section, "Check of the finalization", now follows the record.
   - Its last sentence ("have not been checked again") goes stale with this check.
   - It links no published check report; verification/README.md still has a PENDING placeholder.
   - *Fix.* Make it a subsection of the record. Link the published report(s). Update the last sentence. Add a record row for it.
2. **(minor) §2.2 table changed from 0.483 to 0.482.** The new value is correct (0.48246) and the record lists the change. But instruction 8 says §2 and §3 are not otherwise rewritten. The change is also silent in the text, while the header says that corrections carry an "At finalization" note.
   - *Fix.* Mark it inline, e.g. "0.482 [At finalization: 0.483 in the red-team pass; the script gives 0.48246]", or revert it and leave the erratum to the record.
3. **(nit) The header promises an "At finalization" note wherever a later note settled or corrected a statement.** Three places lack such a note at the spot:
   - §6.4 still lists "E at γ=1" as open; E treats it (the negative direction is proved, the positive direction rests on an imported cover). Only the status table and the §8 note say so.
   - §6.1's unseen-atom figures (0.37–0.46 and 0.14–0.16) come from the runs of the former §5.4 but give no pointer to depth-two.md §7.1, unlike §2.2.
   - §0 item 8 credits "the positive direction for small θ" to §8, whose second bullet now marks m≤N<T open.

   *Fix.* Add short inline pointers, or narrow the header sentence.
4. **(nit) Status table.**
   - The rows for §0, the §6.3 list, §7 and §8 say "Not refereed". The referees of Prop. 4.1, Remark 6.2, Prop. 6.1 and §5 did examine the items that cite those results (§0 items 1, 6 and 7, §6.3 items 2–4, §7 items 5–6, the second bullet of §8). The §1 and §3 rows already record checks of this kind.
   - The §5 row omits `../verification/depth-two-revision-check.md`, while the Prop. 6.1 row lists the two revision checks of small-learner-width.md.
   - Nothing points to the preserved original, `../verification/red-team-first-version.md`. The referee reports cite its line numbers, and §5 and Prop. 6.1 now exist only there.
5. **(nit) Precision.**
   - "Limits", first bullet: the TUBE risk limit holds on samples that contain a label −c_0, which have probability 1−p^n.
   - §7 item 5: "part (a) gives 25ρ_0²+4/3ε there" also needs τ=4ρ_0.
   - The §6.3 heading "(proved here)" is kept as instructed, but §0 item 7 now says "proved here or in the note cited".

## Citation mismatches in other notes (not edited)

- **E-finite-prior-scale.md**, §0 "Earlier sketches" (line 25) and §7 item 6 (line 696). Both still credit the §8 sketch with the positive range θ<(γ−1)/(2(L−2)), including "the red-team sketch gives 0.25, 0.125, 0.083". The finalized §8 marks that range open, since it needs an energy bound that is not proved. This was reported in round 1 and is still unresolved.
- **depth-two.md** §8 (line 840): "the display of RT Prop. 6.1". It can be followed, since the same parenthesis names small-learner-width.md Thm 1(c). Known.
- **small-learner-width.md** Theorem 1(c) (line 169) and Remark 5 (line 250) cite "the display of `red-team.md` Proposition 6.1", which no longer stands there. Thm 1(c) reproduces the display, and the red-team pointer says so, so the reader can follow it. Not listed in round 1.
- **A-tight-conditioning-fails.md** Remark 6.6b (line 783): "Its statement that such conditioning never memorizes". That sentence is now the energy statement. The two agree in substance. Known.
- **depth-two.md** line 403 ("recovers RT's statement") and the §9 rows that quote removed RT §5 text are historical. That text survives only in red-team-first-version.md.
- **Everything else resolves and says what it is cited for.** This covers the citations in A, B, E, depth-two.md and small-learner-width.md of:
  - Lemma 2.1(2), Theorem 3.2, Proposition 4.1 and Remark 6.2;
  - Theorem 5.1 and Proposition 6.1 (pointer lines);
  - §§2.3 A2/A3, 3, 5, 6.1, 6.2, 6.3, 6.4, 7 and 8, and Appendix A.

  The README rows for Proposition 4.1 and Remark 6.2 match as well.
