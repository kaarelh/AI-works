
---------------------------------------------------------------------------------------------------------------

## 3. Relation to the brief's proposed answers (§5)

* **Q1: confirmed, with precision.** Anchor = Plotkin's events specialized (Thm A2), the same in DT° but not in SO° (A2′);
  the ω-gap is characterized exactly by M₀ ≼ M (A5); the hidden ω-step occurs in the *cautious* learner whenever
  parameters are instances and no closedness guard is in the class (A4(b)) — a point the brief does not make.
  **[revised]** The brief's claim "φ(z) is a first-order pattern: plain lgg works" needs the brief's own λ convention
  (§3 of the brief: metavariable values have no bound variables): in the named or de Bruijn first-order syntax the
  instance schema is not H₁-closed when some free x lies under a binder, because of capture instances (A4′); a
  "nocap" guard learned from data repairs it.
* **Q2: confirmed** — all ZF schemas are in the pattern fragment, pattern anti-unification and the DT° learner work,
  anchors are (R) + argument-use events (Thm E, Cor F); every ground ZFC axiom is its own anchor.
* **Q2: corrected** (Thm B1, Prop B2, C2, C3): ∈-induction is a first-order pattern in de Bruijn syntax; freshness is not
  automatic in the de Bruijn *first-order* encoding (Separation; Collection without A); Collection/∃!-Replacement with A
  in φ are first-order only in the named encoding *with textbook names* (B1α); spelled-out Replacement yields a
  truth-sound first-order lgg in the named encoding with textbook names (exactly as sound as Collection, C3′) and false
  lgg instances in de Bruijn and under α-variation; Jech's Replacement yields false instances in both. The robust
  statement is Thm B1/B1α: *first-order iff P's argument tuple is literally the same at every occurrence in the chosen
  syntax* (same names, same indices, or — when names vary — same binders).
* **For the method question (Q3, not this track):** ZF and Q1 data are pattern targets, so any learner whose class
  contains PAT and whose anchors are Thm E's applies to single schemas; DT° is needed only for PA-style schemas.
  **[new]** For targets with several metavariables — and an untagged mixture of schemas behaves like one — the anchor
  condition acquires a Plotkin-(D)-type event that *depends on the hypothesis class* (Thm E′): a learner using DT°
  needs more data diversity (D^DT) than one using PAT (D^PAT), and SO° needs still more in some cases. A method track
  should state its anchor theorem relative to its class.

## 4. Files, commands, outputs

All commands: `cd research/tracks/cases && python3 <script> [args]`. "Re-run" = re-run in this revision with output
identical to the recorded one (diff empty).

| script | claims | output | time |
|---|---|---|---|
| `q1_lgg.py` | A1, A2 (computed), A4(c), A3 rates vs MC, A2′ SO° counterexample | `q1_lgg.out` (re-run) | ~85 s |
| `q1_qmodel.py` | Ex. A8 model of Q | `q1_qmodel.out` (re-run) | <1 s |
| `q1_capture.py` **[new]** | A4′: capture examples, decomposition of inst(σ_φ) with the predicted criterion asserted, guard learning, de Bruijn capture | `q1_capture.out` | <1 s |
| `q1_dt.py` **[new]** (uses `dt_search.py`) | A2′ DT° half (99/99) and SO° non-anchors with binders | `q1_dt.out` | 7 s |
| `z1_encodings.py` | B1 criterion, B2 blocks, §2.4 false instances, (3b) dB capture, (4) EInd-dB, (5) only-if | `z1_encodings.out` (re-run) | ~5 s |
| `z2_anchors.py` | Thm E (reduced DT°; full DT°/SO° on small frames) | `z2_anchors.out` | ~7 min (4 cores) |
| `z2b_fullcheck.py` | Thm E, full DT° on the large frames (5 of 8 pairs finished) | `z2b_fullcheck.out` | 20 min budget |
| `z3_pattern_lgg.py` | Cor F; PA contrast | `z3_pattern_lgg.out` (re-run) | ~10 s |
| `z4_guards.py` | Prop D1 | `z4_guards.out` (re-run) | ~2 s |
| `z5_deepleaf.py` | Lemma C1 hypotheses and conclusion on random τ | `z5_deepleaf.out` (re-run) | ~5 s |
| `z6_rates.py` | Thm G | `z6_rates.out` | ~3 min |
| `z7_multi.py` **[new]** | Thm E′: PAT via pattern lgg (4500 data sets), DT° via bounded search (300 pairs), separating examples, SO° | `z7_multi.out` | 12 s |
| `z8_alpha.py` **[new]** | Prop B1α, §2.4(8), Thm C2(iv) | `z8_alpha.out` | 1 s |
| `z9_anchor_search.py S 10 3 2 1` **[new]** | Thm E, bounded single-group search, 7 schemas × 20 pairs, DT° and SO° | `z9_<S>.out` | 2–186 s each |
| `z9_anchor_search.py ReplJ 3 3 2 2` **[new]** | Thm E on ReplJ including the 3-slot groups of arity 2 | `z9_ReplJ_deep.out` | see below |

`z9` summary (DT° agreement with (R) ∧ (N); SO° verdict = DT° verdict on every pair; covering single-group templates
examined DT° / SO°): Sep 20/20 (2034 / 2722); SepJ 20/20 (2090 / 2820); EInd 20/20 (515 / 1155); Coll 20/20 (4548 / 6010);
ReplU 20/20 (4548 / 6010); ReplS 20/20 (9458 / 11890); ReplJ 20/20 (5450 / 6834). ReplJ deep run: RESULT_DEEP.

## 5. Caveats and uncertain citations

* Computations cover pools of 16 bodies per arity (atoms, connectives, one internal quantifier, parameters) and random
  bodies for Thm E′; the theorems are proved for all bodies. The SO° enumeration is bounded to arity ≤ 3 (DT° needs no
  bound by E3). The new searches (`dt_search.py`) are bounded (group size, arity, argument pool); "no covering template
  misses a probe" is evidence, not proof, and the probes are finitely many genuine instances.
* "False" claims are proved by short ZF arguments or by Δ₀-absoluteness from HF witnesses; no general truth evaluator for
  set theory is used. The finite-structure checks (sizes ≤ 3, or ≤ 5 for pure equality) only test the pure-logic steps.
* The named encoding of Part 2 assumes textbook names unless §2.2a (α-variation) is invoked. Data that α-rename only
  *some* binders lie between the two analyses; Prop B1α's "only if" needs data in which the two binders at a differing
  argument position get different names.
* Citations: Kunen 1980 axiom wording and numbering, and that Kunen treats ∃! as an abbreviation (I believe); Jech 2003
  axiom wording (1.3, 1.7, 1.8; unverified); the location in Boolos–Burgess–Jeffrey of "Q ⊬ ∀x(0+x=x)" (unverified); the
  provability of Collection in ZF is standard (via ranks, e.g. Lévy 1979, *Basic Set Theory* — I believe); Tarski–Vaught
  1957 (Compositio Math. 13) for the elementary-substructure test; Pfenning 1991 (LICS) and Baumgartner–Kutsia–Levy–
  Villaret 2017 (J. Autom. Reasoning 58(2), as far as I know) for pattern anti-unification — I have not run their
  implementation; mine is n-ary with a permutation merge.

## 6. Open problems (for the paper / other tracks)

* **SO° anchors with several metavariables.** Thm E′ gives the exact condition in PAT and DT° and a sandwich in SO°
  ((D⁺) sufficient, (D^DT) necessary, the latter not sufficient). The exact SO° condition is data-dependent (example (ii)
  of §2.9); whether (D⁺) is necessary is open (conjecture: no).
* **SO° anchors for Q1 in languages with closed terms** (an analogue of prior C7's condition (B)); only counterexamples
  are given (A2′).
* Escalation counts of the DT° verifier on ZF data before an anchor (prior C11 is open for PA as well).
* **Prop C3′:** does ZF − Foundation prove Collection? By C3′ this decides whether the named spelled-out-Replacement lgg
  (textbook names) is truth-sound without Foundation. Status unknown to me.
* α-variation: Prop B1α settles the full-renaming case; communities that rename only some frame variables, or rename
  inconsistently across a corpus, are not analysed beyond the remark in §5.
* Untagged mixtures of ZF schemas and of instance schemas φ(z) (Q3) belong to the method tracks; this track supplies the
  per-schema anchors, the several-metavariable anchor theorem (E′), the encoding classification and the capture analysis.

---------------------------------------------------------------------------------------------------------------

## Verification log

Each referee verdict, finding and "missing" item, with its resolution. "Re-run" means the script was run again in this
revision and its output is identical to the recorded one.

### Verdicts

| id | referee verdict | resolution |
|---|---|---|
| A1 | holds | Kept. Added the remark that A1 uses closed instances only, so it holds in all three syntaxes (§1.2). `q1_lgg.py` re-run. |
| A2 | holds | Kept (§1.3). Added: anchor-hood concerns only inst(τ) ⊇ inst_c(φ), so A2 is convention-independent; the claim inst_c(φ) = inst(σ_φ) is now made only under the λ convention (§1.1), as the referee required. Referee's 36 000/36 000 cited. |
| A2′ | holds (DT° half not computed) | DT° half now computed: `q1_dt.py` → `q1_dt.out`, anchor ⟺ prediction on 99/99 pairs over 5 formulas (3 with binders, 1 two-variable). SO° non-anchors with binders exhibited (§1.3). The proof text was made explicit for hole positions that receive closed-term arguments at non-pattern occurrences (the case the referee checked). |
| A3 | holds (ρ undefined) | ρ defined in the statement (ρ_i = best root split, r_{ii′} = P[t_i ≠ t_{i′}], ρ = min), and the (1−ρ)^N → e^{−Nρ} step written out (§1.4). "Match the bound" replaced by "lie below the bound (about a factor 2 in N)". |
| A4 | holds-with-fix | Fixed. A4(b) now says cl = inst(σ_φ) = inst_o(φ) *under the λ convention*; in the named/de Bruijn first-order syntax cl = inst(σ_φ) ⊋ inst_c ∪ inst_o (capture). New Prop A4′ characterizes capture exactly (when it occurs in each syntax; examples false in every structure, or false in ℕ although ∀xφ is valid), shows that the unguarded verifier is unsound outright, and shows that the guard nocap(z) is learned from data and restores exactness. Computed: `q1_capture.out`. |
| A5 | holds | Kept; citation Tarski–Vaught 1957 added. |
| A6-A7 | holds | Kept unchanged. |
| A8 | holds | Kept; `q1_qmodel.py` re-run; referee's {0..60} check cited; BBJ location still marked unverified. |
| A10-A11 | holds-with-fix | Fixed: A10.1 and A10.4 now name capture alongside the ω-step and require the nocap guard or the λ convention in the named/de Bruijn syntax; §0 items 1 and 3 likewise. A10.2 now says it *is* Prop A5. New A11(d): the world channel does not protect against capture (∃y(y=Sy) is refutable from PA, not from Q). |
| ZF-form | holds (∃! attribution) | Fixed: "ReplU (Kunen, ∃! primitive)" now reads "∃! as a primitive binder — our encoding choice; Kunen treats ∃! as an abbreviation (I believe)". Hedges kept (§2.1). |
| B1 | holds | Kept; `z1_encodings.py` re-run. Extended by Prop B1α (α-variation, §2.2a). |
| B2 | holds | Kept; referee's 2417 random pairs cited. |
| C-ex | holds | Kept; new item 8 (α-varied named encoding) added, computed in `z8_alpha.out` (2). |
| C2 | holds | Kept; `z5_deepleaf.py` re-run. Extended by case (iv) (Coll, ReplU, ReplS under α-variation), with a different designated leaf because the de Bruijn leaf is not unique in the named encoding; hypothesis and pure-logic steps computed in `z8_alpha.out` (4). Lemma C1 now also covers name metavariables and distinct-guards. |
| C3 | holds | Kept, with the learned guards listed. Sharpened by Prop C3′: truth-soundness over a base B ⟺ B ⊢ Collection, so the open question is exactly "ZF − Foundation ⊢ Collection?". Noted that C3 depends on textbook names (fails under α-variation). |
| D1 | holds | Kept; `z4_guards.py` re-run; referee's 1537/1537 cited. |
| E | holds (one inaccurate sentence) | Fixed: Step 2 rewritten (2a–2c) for arguments that are bound variables *or parameters*, possibly repeated; it records holes only at frame variables and shows that each recorded u^s_m is a bound variable; the old sentence is quoted and retracted. New evidence `z9_*` (7 schemas × 20 pairs, DT° and SO°, all agree), including ReplJ anchor pairs; the referee's 35 ReplJ anchors cited. |
| F | holds | Kept; `z3_pattern_lgg.py` re-run; referee's BKLV-style check cited. Extended by Cor F′ (several metavariables). |
| G | holds | Kept; referee's check cited. |

### Findings

| finding | resolution |
|---|---|
| F1 (capture in Q1) | Accepted. Variable convention fixed explicitly (§1, §1.1); A4(b) corrected; Prop A4′ added (proof + `q1_capture.out`); §0 items 1, 3, A10, A11(d), §3 revised. |
| F2 (de Bruijn capture, Part 1 vs Part 2) | Accepted. The Part 1 sentence now restricts "no capture" to the λ/locally-nameless convention and points to de Bruijn index capture (§1.1, A4′(b), §2.4(7)). |
| F3 (Thm E argument sentence) | Accepted; Step 2 rewritten (§2.8). |
| F4 (coverage of evidence) | ReplJ: own bounded search on 10 anchor + 10 non-anchor pairs, plus the deep run with 3-slot groups (`z9_ReplJ*.out`); referee's 35 anchors cited. A2′: DT° half computed (`q1_dt.out`); SO° failures with binders shown. |
| F5 (hygiene) | ρ defined (A3(c)); "match the bound" → "lie below the bound"; A10.2 cites A5 as its proof. |
| F6 (citations) | Kunen ∃! attribution corrected; Tarski–Vaught 1957, BKLV 2017 (JAR 58(2)), Pfenning 1991 kept as cited; Jech, BBJ, Lévy remain marked unverified/"I believe". |

### Missing or under-treated

| item | resolution |
|---|---|
| 1. Capture for Q1 | Done (F1): §1.1, Prop A4′, A10, A11(d). |
| 2. DT° half of A2′ not computed | Done: `q1_dt.out`, 99/99. |
| 3. Several metavariables only sketched | Done: Thm E′ (proved) with the facing lemma; exact anchor conditions in PAT and DT°, sandwich in SO°, separating examples showing that the three classes have different anchors; Cor F′; computed in `z7_multi.out`. The old "Remark (several metavariables)" is superseded (its (D)-type event is now D^PAT / D^DT, and it is class-dependent). |
| 4. Ground axioms | Done: §2.1 remark and the per-schema table (§2.8). |
| 5. Renaming of frame variables (named encoding) | Done for full α-variation: Prop B1α (proved), consequences for Coll/ReplU/ReplS, C2(iv), C3; computed in `z8_alpha.out`. Partial renaming remains a caveat (§5). |
| 6. C3 without Foundation | Reduced exactly to "ZF − Foundation ⊢ Collection?" (Prop C3′, proved); the latter remains open here (§6). |

Nothing from `notes.md` was withdrawn; every statement there is restated above, corrected where indicated.
