# Final whole-paper check (after the section edits and the intro/abstract/discussion/app:ver alignment)

Checker: a fresh session that wrote none of the paper. Input: `paper/main.pdf` (read in full via `pdftotext`,
135 pp.), all `paper/sections/*.tex`, `edits/E1-results.txt`, `edits/E2-results.txt`, `edits/DECISIONS.md`,
the five `review-*.md`, `paper/NOTATION.md`, the four `research/tracks/*/notes-final.md`, `research/prior/induction/*`
and `code/results/*.md`.

## Build

Final build: `cd paper && flock /tmp/claude-0/paper-build.lock ./build.sh`
- 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels;
- 0 overfull hboxes (none at all in `build3.log`), 4 underfull (badness ≤ 3302, app-single computations list);
- 135 pages;
- the only warnings are 7 "Font shape T1/lmr/{bx/sc, m/scit} undefined" substitutions. They come from `\DTRC`
  (small caps) inside bold headings and italic theorem bodies in many.tex and app-many.tex. They are harmless:
  slanted small caps are used instead.

## Changes made (32 minimal edits, 14 files)

### Consistency of restated results

1. `universal.tex`, §4 overview item (3): "a datum at a parameter licenses it" became "data with a parameter at
   every variable license it as ordinary generalization (\cref{prop:univ:gen})". This matches Prop 4.5(c),
   Prop 4.6(e), Table 5 row 4, the intro and the discussion (for k ≥ 2 one datum is not enough).
2. `universal.tex`, §4.7 summary: "data at parameters license" became "data with a parameter at every variable
   license".
3. `intro.tex`, Question 1 answer bullet: "data at parameters license it" became "data with a parameter at every
   variable license it" (same reason; the detailed Q1 paragraph already said this).
4. `zfc.tex`, §5 opening: the ReplS exception now reads "whose first-order lgg *of anchor data* is a truth-sound
   over-generalization" (prop:zf:coll is restricted to anchor data, app:zf:fofail).
5. `experiments.tex`, E2 paragraph: "for Repl_sp the named first-order lgg *of anchor data* is truth-sound" (same
   restriction; the zf editor asked for it, but it had not been applied).
6. `setting.tex`, after lem:setting:onesided: "such as *the named lgg of anchor data* of spelled-out Replacement"
   (same; also requested by the zf editor and not yet applied).
7. `setting.tex`, §2.7: "they use Min^al throughout" contradicted App A.7, §7.1 and App F.3, where the
   implementation uses the literal set when some datum is parameter-free. It now reads "they use Min^al (written
   Min_F in §7), or the literal set when some datum is parameter-free (App A.7)".
8. `many.tex`, prop:many:forall(e): "the ω-rule, sound but not derivable" became "sound but in general not
   derivable" (Example 4.9 shows only that it need not be derivable; matches §4, the abstract, the intro, the
   discussion and app:ver row 34).
9. `intro.tex` (Q3 details): the universal-set schema "that only a coherence refutation catches" became "that
   neither logic nor hereditarily finite counterexamples refute, only coherence". The implemented ZF oracle of §7
   (truth in V with generics) does refute it (prop:exp:hard(a)). The discussion already had this qualifier ("when
   only logic and HF counterexamples are used").
10. `many.tex`, §6 opening bullet: the same statement became "that, of these channels, only coherence refutes".
11. `experiments.tex`, limitation (8): "Separation is proved for the mixtures only, *and for an ideal refuter*"
    (cor:exp:mixsep; matches the intro, discussion and G.4).
12. `app-verification.tex`, G.4: ZF/ZFC separation "verified on every sampled cross pair (one sampled instance per
    schema)" became "(one or two sampled instances per schema)". The AC cross pairs used two samples per schema
    (untagged §7.2(b), Example E.20).

### Wrong cross-reference reading

13. `app-verification.tex`, Table 18 row 18, "Now" column: `\cref{prop:exp:normal,prop:setting:align}, the
    latter only for templates whose parameters ...`. cleveref sorts this into "Propositions A.5 and F.2", so "the
    latter" pointed at F.2 (the literal normal form, which needs no restriction) instead of A.5. It now prints
    "Proposition F.2 and Proposition A.5, the latter only for ...".

### Glossary (Table 3) wording

14. "(R), (D) — Plotkin's events: the values' roots vary; metavariables differ" became "...; values of distinct
    metavariables differ" (Lemma A.4's (D)).
15. "(F) — Min(X) is finite and below every covering template" (which reads as "a least element") became "Min(X)
    is finite; every covering template lies above a member" (Theorem 3.3(c), App A.7 (F)).

### Discussion

16. `discussion.tex` 8.1: "an anchor is always an anchor *in a class*" (tautological as printed) became "whether
    data are an anchor depends on the class".

### Internal jargon in running text (moved into `\src` or reworded)

17. `many.tex` §6.11: "the untagged track's prototype implementation" became "a separate prototype implementation
    of dtrc (not the package of §7)".
18. `single.tex` §3 intro: "Gray tags name results of the research track ``single'' ..." became "Gray tags name
    the source of each result in the research notes on single templates or in the earlier analysis of PA induction
    (§2; App G)".
19. `app-single.tex` B.9: "(track single, Theorem H)" became `\src{single Thm H}`.
20. `app-universal.tex` C.6: "scripts of the track ``cases'' (directory ...)" became "scripts (directory ...)".
21. `app-experiments.tex` F.1: "the prior referee's bounded enumerator" became "a bounded enumerator ... written by
    a referee of the earlier analysis".
22. `experiments.tex`, proof of prop:exp:qF: "(E4(b); recheck R15)" became "(E4(b))\src{recheck R15}".
23. to 32. `app-many.tex`: ten running-text IDs, "(untagged u2)", "(untagged u12(a))", "(untagged u12)", "in
    untagged u9 (Example B)", "(untagged u6)", "(untagged u3, u5, u0)", "(single e11)", "(single e11, e14)",
    "(untagged u7)" and Table 13's caption "(computed, untagged u1; ...)", were turned into `\src{...}` tags.

One extra fix: my first version of edit 20 caused a 12.6 pt overfull box. I re-worded it to keep the original
"(directory ...)" form, and the final build has no overfull box.

Files touched: abstract.tex is unchanged. Changed: intro, setting, single, universal, zfc, many, experiments,
discussion, app-single, app-universal, app-many, app-experiments, app-verification. No preamble, bib or label
changes. Nothing is committed.

## Fidelity spot checks (claim → source → verdict)

| # | claim (where) | checked against | verdict |
|---|---|---|---|
| 1 | Two closed instances with different heads anchor the instance schema; (R)+(D) for k vars (abstract, intro, Thm 4.2) | cases Thm A2, §0 item 1 | ✓ |
| 2 | ω-step truth-safe for all φ iff M0 ⪯ M; holds in N and every model of TA; fails in R, V, PA+¬Con(PA) (abstract, intro, Prop 4.7, Ex 4.8) | cases Prop A5. The record still says "nonstandard models of PA"; the paper's correction (row 34) is right: in a model of TA, M0 ≅ N and numerals make M0 ⪯ M | ✓ (corrected claim is correct) |
| 3 | Q ⊢ 0+n=n for each n, Q ⊬ ∀x(0+x=x); model on N∪{a,b} (Ex 4.9, App C.4) | cases Ex A8; hand-checked Q4/Q5 use under §2 numbering | ✓ |
| 4 | Cautious learner takes the ω-step after an anchor when parameters are admissible; closedness guard stops it (Prop 4.5) | cases Prop A4, §0 item 3 | ✓ |
| 5 | Capture: ∃y¬(y=x) → ∃y¬(y=y), false in every structure; corrected criterion (Prop 4.6, Lem C.3) | cases Prop A4′; E1 report | ✓ |
| 6 | Every ZF schema is a pattern; anchors iff (R)+(N_i) in every class PAT…SO° (abstract, intro, Thm 5.9) | cases Thm E | ✓ |
| 7 | FO anti-unification works iff same argument tuple; Table 11 verdicts (Thm 5.2, Prop 5.3) | cases Thm B1, B1α, §0 items 6–7 | ✓ |
| 8 | No finite union of guarded FO schemas for the listed cases (Thm 5.6) | cases Lemma C1, Thm C2 | ✓ |
| 9 | ReplS named lgg of anchor data truth-sound; over B iff B ⊢ Collection (Prop 5.7) | cases C3, C3′; E2-results (anchor-data restriction) | ✓ (now stated with the restriction everywhere) |
| 10 | 26 DT° templates contain inst(T_Ind); closed in DT°_s iff s ≥ 12 (Prop D.6, §2.4) | prior second-order-notes l.70, 433–466 | ✓ |
| 11 | Two raw instances suffice for an unsound FO lgg; K0 never refuted by closed QF truths (Prop 5.12, Thm 5.14) | prior B1/B3, referee R1 | ✓ |
| 12 | Min(D) finite, one member below the target; Acc = Feat, polynomial (Thm 3.3, 3.4) | single Thm B, C, §0 table | ✓ |
| 13 | Anchor iff (R*),(N),(U); "only if" under (Rich) (Thm 3.8) | single Thm D, Ex D.7 | ✓ |
| 14 | Esc(DT°;N) = Θ(N²), C11 refuted; |Min| = 4^n (Thm 3.11, Prop B.6, 3.13) | single Thm F, Prop F.8, G.2 | ✓ |
| 15 | k-union verifier polynomial for k ≤ 2, coNP-complete for fixed k ≥ 3; refutation test NP-complete (Thm 6.16) | single Thm H, §0 (d′) | ✓ |
| 16 | Worked rate laws in App B.5 (0.057714, 0.057648, 0.059942; 1.54·10⁻⁴, 7.7·10⁻⁴) | recomputed by hand | ✓ |
| 17 | Bound necessary; pigeonhole; four sentences refute all PA cross templates (Prop 6.4, Thm 6.6, Table 13) | untagged §§2, 7.1. The record uses another Q order; every Table 13 row was converted to §2 numbering and checked (e.g. record Q3–Q4 = paper Q4–Q5) | ✓ |
| 18 | PA run: 7–8 pure clusters, 200/200 held-out, 0/91 non-instances; ZF: 36 pairs (22 HF, 14 logic, 3 Russell), 9 clusters, 180/180, 0/30; ZFC: 12 AC templates, 10 clusters (§6.11) | untagged §7.1–7.2, u3/u4/u5/u10 rows | ✓ |
| 19 | E1: mean N 3.27 vs 3.25 (mixed), 8.42 vs 8.11 (numerals); FO lgg and DT°_F exact at the same N in all 2000 runs; x+y=y+x 4.18/11.85 | code/results/e1_universal.md | ✓ |
| 20 | E2: Table 9; 0 non-instances in 927 DT°_F probes; pattern lgg 224/229 (58 refuted), formula-level 213/220 (46); EInd dB 0/182 | e2_schemas.md (98+134+130+157+80+120+85+123 = 927; 84+98 = 182) | ✓ |
| 21 | E3: Table 10 (13/20, 17/20, 13/20, 17/20, 9/20, 8/20; 451/474/425/453; probes); seed 3 has no 0+0=0; sharing matches membership learner per seed | e3_mix.md | ✓ |
| 22 | E4: q_F accepted at budgets 80 and 400 (seed 0, both regimes), not at 2000; clean targets 11/11, 9–10/11, 9/9 | e4_stress.md | ✓ |
| 23 | E5: dtrc+share = membership learner per target and seed; U0add beyond 120 in 4/5 streams | e5_curves.md | ✓ |
| 24 | E9/E10: 2200 PA and 540 ZF merges all refuted; 15/5 distinct templates; 1073/1080 near-miss (7 unrefuted); hard 431/430 of 432; E10 9100 pairs, no mismatch | e9_separation.md, e10_pairtable.md, Table 16 | ✓ |
| 25 | Ex F.6 (sharing counterexample): cross pairs, their minimal templates, (H4+), (H5), rejection of 2+0=2, anchor for U_add0 | hand-checked membership of every datum and the three lggs | ✓ |
| 26 | Rem A.7 (alignment counterexample): T covers D up to renaming, one alignment, unique member, T above no member; valid-target variant has a false member instance | hand-checked | ✓ |

## The two fatal fixes

**prop:setting:align (Prop A.5) with rem:setting:alignfail (Rem A.7).**
- The statement restricts (b) and (c) to templates all of whose parameters occur in their skeleton.
- The false "one alignment ⇒ Min^al = Min" sentence is replaced by a correct paragraph (App A.7), which shows the
  difference with an example and explains why (b) is unaffected.
- Every use agrees: §2.7; §7.1 (Min_F paragraph); App F.1 (Alignment paragraph); App F.3 (Prop F.3(b), whose
  proof states the hypothesis, plus "the literal set" paragraph); Prop F.8's proof (single alignment, no appeal to
  the false claim); Thm 7.2 (H1); discussion O2 and 8.4; Table 18 rows 18 (now pointing to the right
  proposition, change 13) and 31; G.3.
- The only inconsistency was §2.7's "Min^al throughout" (change 7).

**prop:exp:share (Prop F.5) with ex:exp:share (Ex F.6).**
- The statement needs (H1), (H3), (H4+) and (H5), and its conclusion is only for targets that label a phase-one
  cluster. Ex F.6 shows a target that labels none.
- I re-derived the example by hand (see #25).
- Every use agrees: §7.2 paragraph; §7.3 E3 "Reading" (computed: every target labels a cluster, (H5) holds;
  agreement predicted where exactness comes from an anchor); §7.4 (3); intro ("guaranteed only for targets that
  label a cluster of the first phase, as all did here"); discussion O11 and 8.4; Table 3; Table 18 rows 29 and
  32; G.3 and G.4.

## Other consistency checks (no change needed)

- **Q-axiom numbering.** Every Qn in many, app-many, experiments, app-experiments, universal, app-universal, zfc
  and app-zfc follows §2.6. Examples: Table 13 rows; Cor E.3; "Q4–Q6 numeral instances"; "Q5 and Q7 into
  ∀x∀y P(x,y)"; Q5 as the recursion axiom; the Q-model check. "Question 1/2/3" is used throughout, never "Q1/Q2/Q3".
- **Terminology.** "The earlier analysis" is used uniformly; no "prior record/work/track/session" is left in
  running text. "(Nm)" is used for the named encoding.
- **Statuses.** Every theorem-like environment has `\status` and `\src`, and definitions have `\src` only. The
  status values are proved, computed, known, conjecture and their combinations.
- **Restatements across intro, sections, discussion and app:ver.** I checked the ω-gap, derivability, capture,
  R-Δ0 ("never refuted means true" only for QF φ and unbounded depth), separation (PA proved; ZF/ZFC computed;
  mixtures for an ideal refuter), the sharing pass, the ReplS restriction, (Rich)/(Rich_c) on the "only if"
  directions, the root-specialization count (nine), the escalation and complexity bounds, and 4^n.
- **Cross-references.** Every `\cref` in discussion.tex was resolved through main.aux and read in context. The
  intro and abstract were checked by their editor. I spot-checked the intro's refs to D.6, D.7, B.6, E.2, E.12,
  F.11 and C.5. Thm 6.8(iv)'s pointer to Prop D.7 for the induction rate is right, because D.7 states the
  inclusion–exclusion rate of the (R)+(N) events.
- **Presentation.** No TODO, NOTE or ?? appears in the PDF. Figures 1 (E1) and 2 (E5) are present (pp. 46, 128)
  and referenced. I rendered Tables 1, 3, 9 and 16 and they are legible. The doubled-word scan found only
  legitimate cases.

## Not fixed / for the author's attention

1. **Font substitutions.** The `\DTRC` small caps inside italic/bold contexts give slanted small caps (7 font
   warnings). This is cosmetic. Removing the warnings would mean editing many statements (DECISIONS 9) and changes
   nothing in substance.
2. **Figure 1 is small.** It is set at 0.42\textwidth, and its axis labels are small in print, but legible.
3. **Meta-mentions of the research records remain.** Some running text names the research records where it
   explains the gray tags or lists scripts: the reader's guide, §3 intro, App D intro, the D.6/B.9/C.6/E.8
   computations sections, and discussion 8.3/8.4. I judged these to be explanation of the provenance apparatus,
   not jargon, and left them. App E still has two "(the prototype's first version ...)" remarks with pointers to
   App G.2. They are history, but short and pointed.
4. **Literature claims.** The literature claims marked unchecked in the text stay unchecked. Examples: the
   deterministic higher-order patterns described "as we read them" from abstracts; Lévy's location of Collection;
   Baxter's thesis; the regret bound. I did not re-verify the bibliography.
5. **No mathematical reviewer read the new prose.** The intro, discussion and app:ver were not read by the
   mathematical reviewers in the review round (G.1 says so). This check is a consistency and fidelity pass over
   them, not an independent mathematical review.
6. **Intro and discussion length.** The intro runs about 5.4 pp and the discussion about 4.5 pp (editors'
   estimates). My edits added a few words in the intro (two qualifiers) and did not shorten anything.
