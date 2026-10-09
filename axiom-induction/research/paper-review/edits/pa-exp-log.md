# pa-exp: resolution log

Group files: `paper/sections/pa.tex`, `app-pa.tex`, `experiments.tex`, `app-experiments.tex`. No other file was edited: no `\cref` target in another group's file had to change, because every moved item kept its label.

This log is the group's changelog in the sense of DECISIONS.md §1 rule 9.

The work was done in two sessions:
* The first editor edited pa.tex and part of app-pa.tex, then stopped at a usage limit and wrote no log.
* The second editor checked that work against the issue list and corrected it (see "Checked and corrected" below). The second editor then finished app-pa.tex, restructured experiments.tex and app-experiments.tex, made further cuts for length, and wrote this log.

## 1. Issues

All 47 issues are done. Labels are cited by name; "App F" is app-pa.tex and "App G" is app-experiments.tex.

| id | sev | status | what changed (file, label) |
|---|---|---|---|
| P-01 | fatal | done | `prop:pa:must` (now in App F, `app:pa:theorems`):<br>• (c) is the binding text of §10.P1. The inconsistent-theory example now says "shortest refutation of a datum (and shortest derivation of a negative datum) is longer than d". It also has the parenthetical on why R_d refutes F_0.<br>• (b) reads "β_ax Σ\|s_i\| > β_ax\|T_Ind\| (72 bits at the default β_ax = β; one or two library theorems suffice, associativity alone: 17 log₂23 = 76.9 > 72)" (C24).<br>• Proof: the F_0 clause and "either has score 1 unless refuted within d" are deleted; only the inconsistent-theory case is argued.<br>• The pa.tex pointer before "Answer" keeps the conclusions and the qualifiers. |
| P-02 | fatal | done | `prop:pa:wellspec`:<br>• last sentence is the binding text of §10.P2 (exponential decay at rate KL under W with generic fixed weights; polynomial decay only with Dirichlet weights, proof sketch);<br>• status "proved, given Thm 4.2 and known facts; proof sketch (Dirichlet weights)";<br>• App F proof rewritten to match. |
| P-03 | major | done | §10.P3 applied:<br>• `def:pa:lsch` has the prior 2^(−β_ax Σ\|τ\|) with β_ax bits per axiom symbol, default β_ax = β;<br>• `prop:pa:memo` is the binding text;<br>• `tab:pa:theorems` caption: "memorising wins at the first occurrence for every theorem at the default β_ax = β";<br>• Answer item (3) reads "β_ax ≥ β*(s), here 30–123 bits per symbol against β = 4.52";<br>• `prop:pa:must`(b) uses β_ax;<br>• the App F proof of `prop:pa:memo` and `prop:pa:regret` use β_ax. |
| P-04 | major | done | `ex:pa:skel` (now in App F) has the binding text of §10.P4 after its first sentence. The App F "Details" paragraph separates the two theories:<br>• the 119-template theory: 42838.5 bits behind, slope −20.5 while it covers the data, dies at the first unseen skeleton;<br>• the 164-template covering theory: +2.0 bits per doubling, code length not computed.<br>The pa.tex pointer states both. |
| P-05 | major | done | `rem:pa:e3b`: binding text of §10.P5. `tab:exp:e3b` caption gains "Equiv.: mass on T*-equivalents within the pool; see rem:pa:e3b". The reviewer's re-run numbers are not quoted (REJ-09). |
| P-06 | major | done | `tab:pa:failures` row F3, column "fixable?": binding text of §10.P6. |
| P-07 | major | done | `rem:pa:zf`: last sentence is the binding text of §10.P7. The remark later moved to App F for length (§2). The pa.tex pointer keeps "the reverse overheads, not formalised, are conjectured to be much larger" and the conclusion with its qualifier "and of nothing they derive only at a cost". |
| P-08 | major | done | "Answer." paragraph of §7.4: binding text of §10.P8; the rest is kept. |
| P-09 | major | done | §10.P9:<br>• the paragraph after `def:pa:lsch` (decodable variant 4.8–7.3%, Kraft for β ≥ log₂ alphabet size ≈ log₂25, 3% under-charge) is in App F, `app:pa:checker`, "The code L1^sch in detail";<br>• pa.tex keeps the Kraft condition with `\status{proved for β ≥ log₂(alphabet size)}`, as decided in §3;<br>• `prop:pa:gibbs` example reads "ℓ(s) = β\|s\| for a Polish-notation code with β ≥ log₂ of the alphabet size", and the consequence uses ℓ = β_ax\|s\| with the same condition. |
| P-10 | major | done | `rem:pa:pointwise` (App F): binding text of §10.P10, status "proved; open". pa.tex: "memorisation alone eventually decides every sentence correctly in every surviving consistent theory". `rem:pa:shift`: status "proved; computed; open". |
| P-11 | major | done | `sec:pa:answer`: binding text of §10.P11 (§9.7 wording). The last sentence (the refuted first version) is deleted. |
| P-12 | major | done | `prop:exp:exact`(d): the binding text of §10.P12 is appended, with the \cref adapted to "(d3) in App G.2". Status: "(a)–(c) proved; (d) proved under the hypothesis of (d3), computed otherwise". |
| P-13 | major | done | `prop:pa:occam` (now in App F) status: "(a) proved; (b), (c) proved under the growth condition of (b); computed". The pa.tex pointer keeps "when all nonzero counts grow linearly". |
| P-14 | major | done | App F, "The theorems in other axiomatisations": "Decodable-code costs are 3.4–7.5% higher". |
| P-15 | major | done | App F, Euler paragraph: "mass 0.0049 (ρ = 0.9) and 0.0727 (ρ = 0.97), summed over false k < 200". The reviewer's tail sum is not used (REJ-14). |
| P-16 | major | done | experiments.tex §8.2, the paragraph after `tab:exp:summary`:<br>• one-component generators in fixed hand pools (E1, E4, E6) are prior atoms, and Doob's argument in the (T,w) form applies (`rem:ident:x5`, in `app:ident:gold`);<br>• data-dependent members (Mem(D_n), causal theories) are covered only by the pool versions of `thm:sound:avg` and `thm:sound:shrink`;<br>• E2, E3(b), E5(b) and E8 are a yardstick, not an instance of a theorem.<br>The E1 setup in App G says the same; the old "Every generator has one component, so thm:ident:doob applies" is gone. E5(b) in App G cites `rem:ident:x5`. |
| P-17 | major | done | §8 restructured as in DECISIONS §3:<br>• §8 keeps a two-sentence framing ("a small exact laboratory" only), the implementation (`sec:exp:impl`), `prop:exp:exact`, the new `tab:exp:summary` (experiment \| setup \| result tested \| finding \| where) with the coverage paragraph (`sec:exp:results`), and `rem:exp:limits`;<br>• the E1–E8 paragraphs and `tab:exp:e1`, `tab:exp:e2`, `tab:exp:e3a` and `tab:exp:e3b` moved to the new `app:exp:results`, which now also holds `tab:exp:e2seen`, `tab:exp:e3afam` and `tab:exp:e4`–`tab:exp:e8`;<br>• App G does not restate what those tables or the canonical remarks show; each paragraph gives the setup, points to the canonical remark and adds only details not stated there;<br>• `prop:exp:comm` moved to pa.tex just before `rem:pa:e6`, with its proof still in `app:exp:comm`;<br>• canonical homes `rem:pa:e2`, `rem:pa:e3b` and `rem:pa:e6` are kept, and `rem:pa:e2` only points to `rem:sound:lumps` for the false acceptances;<br>• the AS MDL re-quotation in §7.3 is replaced by one clause with a pointer to `rem:ident:mdl`. |
| P-18 | major | done | The main text distinguishes only:<br>• a fixed symbol code;<br>• per-template learned codes;<br>• a shared grammar with one context per sort;<br>• SDPC, defined in place as "a learned positional grammar shared by all templates".<br>NAIVE, PC, DPC, RDPC, CF, u7, G2, G3, nd.size and dtlib are only in App F (`app:pa:checker`, `app:pa:mdl` "Grammars and usage laws"). G1 is defined where it is first used. |
| P-19 | major | done, partly | Lengths: §7 is within its cap but above its target; §8 is on target. See §4. |
| P-20 | major | done | Refuted material:<br>• pa l.57 ("The first version's argument … was wrong") deleted;<br>• the constant-margin remark is now `rem:pa:sdpcrefuted` in App F (new label), with a pointer in §7.3;<br>• last sentence of `sec:pa:answer` deleted;<br>• `rem:exp:refuted` moved to App G (end of `app:exp:results`);<br>• `rem:pa:merge` cites `tab:pa:merge` (C-28). |
| P-21 | major | done | No "track …", "referee …", "first version" or "the brief's H…" in the running text of pa.tex or experiments.tex. They remain only in `\src`, in captions and in the appendices.<br>• "does not test the brief's H6" became "does not test whether a time penalty prices Hänni's collapse" (App G, E7).<br>• One exception is binding: the text of §10.P12 in `prop:exp:exact`(d) says "the referee's 904 triples" and is kept verbatim. |
| P-22 | major | done | Terms defined where first used:<br>• motive: in `def:pa:lsch`;<br>• DTRC: first sentence of `sec:pa:dtrc`;<br>• T_{\mathcal L_∞}: in `sec:pa:dtrc`, `tab:pa:dtrc` (caption) and `prop:pa:isigma`(c);<br>• Q⁻ = "any set of axioms among Q1–Q7": in the pointer to `prop:pa:fragments` and in its statement;<br>• T_E, T_N: in `ex:pa:narrow`;<br>• Q_e = "the elimination-term law": §8.1;<br>• SeenQ and Trim: §8.1, and SeenQ also in `rem:pa:e2`.<br>Pool names (skel k@b, DTRC@b, frag-*, IndSwap) are explained in the caption of `tab:exp:summary` and of `tab:exp:e2` in App G. |
| P-23 | minor | done | E2 (App G): "the applicable soundness statement is the pool version of thm:sound:shrink". The δ_n bound with \Rreg(n,8) is in its canonical home `rem:sound:lumps`. In E4 and `tab:exp:e4` no constant is written w* any more:<br>• (A) uses π(T*), with δ = π(T*)δ′, and the table column is headed π(T*);<br>• (B, C) use W*_pool := 2^(−bits(T*))/(Σ_{T∈H}2^(−bits(T))+1) = 7·10⁻⁶ from the pool version of `thm:sound:avg`. |
| P-24 | minor | done | App F opening: the sentence on what the referee re-checked is kept. The list of unrefereed additions is replaced by "the complete list is in app:ver:process". App G has no such list. |
| P-25 | minor | done | E2 item (2) (App G): "an unsound lump … Q-lumped (by up to 12.7 bits) or its trim, or, in one seed (seed 1, n = 16), a data-derived skeleton cluster, skel4@16, with mass 0.999". Source: e2_pa.md. |
| P-26 | minor | done | E8 (App G) quotes "mean gain per datum at n = 4096: 0.1995 bits (L1), 0.0731 (L0)", as in e8_split_l1.md. The marginal rates for n = 1024…4096 are left to the canonical `rem:ident:e8`, which already names that window. |
| P-27 | minor | done | `rem:exp:limits`(v): "5 in E1, E3 and E6; E4 100–400 streams". Status: "(i), (v) computed; (ii)–(iv) properties of the code". |
| P-28 | minor | done | E1 setup (App G): "15–28 theories at n = 256". |
| P-29 | minor | done | App F `app:pa:equiv`: "their proofs use bounded collection (BΣ_n, provable in IΣ_n; known) because θ_φ adds a bounded quantifier". |
| P-30 | minor | done | `rem:pa:streams` (App F)(iii): "theorems of a library fixed in advance … from n = 10 (the first checkpoint after n = 1)". The pa.tex pointer keeps "fixed in advance" and "from n = 10". |
| P-31 | minor | done | E5(b) (App G): "the posterior is over {L_1,…,L_40,L_∞}; on data uniform on the five sentences of L_5". |
| P-32 | minor | done | `rem:pa:e6` points to `tab:exp:e6`. Its caption now gives the redundant pairs under L1 from e6_equivalent.md: A_xy∪A_yx at most 9·10⁻¹¹ and A_xy∪S_ab at most 4·10⁻¹⁰ (means, every n and source).<br>The reviewer's "≤ 10⁻¹¹" for A_xy∪A_yx is the n = 256 value only. The source shows 9·10⁻¹¹ at n = 4, so the source value is used. |
| P-33 | minor | done | `app:exp:pools`: "in E3 and E4(B, C), where the largest possible mass is recorded per run, 0 in every run; in E6, checked in seed 0 only, for Mem(D_n) in two cases, 0". This was verified in the `bounded` fields of e3_misspec.json and e4_ville.json (all 0.0) and in check_bounded.out.<br>The §8.1 sentence is restricted the same way: "never exceeded 8·10⁻¹⁴ in E1–E4, where it is recorded for every run, and was 0 in the one E6 seed checked". |
| P-34 | minor | done | App F, after the proof of `prop:pa:atomic`: "any theory of Q axioms and term-only induction-type templates: by the argument of prop:pa:readonce(b), which needs only a fixed formula skeleton, it lies in some IΣ_k ⊊ PA". |
| P-35 | minor | done | The sentence with "the minimal model" had been deleted in pa.tex. It is restored in App F after the proofs of `prop:pa:nc` and `prop:pa:incons`, as "L_ε is a simple model that credits derivations without killing gaps, as Hänni asks; the plain 'does not contradict' score has no size principle (prop:model:whichsize(b))". |
| P-36 | minor | done | Proof of `prop:pa:readonce`(a) (App F): the induction over the structure of a read-once subformula (⊤ and ⊥ by constant instantiation; ↔ via (⊤,⊤), (⊤,⊥); quantifiers vacuous) is added. |
| P-37 | minor | done | Proof of `prop:pa:lower`, step 2 (App F): "an Ind instance, even after removing a ∀-prefix, is an implication whose antecedent is a conjunction". |
| P-38 | minor | done | E1 item (3) (App G): "≤ 2.5·10⁻¹²". |
| P-39 | minor | done | E2 item (3) (App G): "trails T* by about the prior difference (698.9 bits; 696.9 at n = 8), and the gap grows by 4.2 bits per doubling from n = 64 to 512". |
| P-40 | minor | done | `rem:pa:usage`(iii): "for this library … (with only the lower bounds of prop:pa:lower, the threshold is at most about 7·10⁻³)". |
| P-41 | minor | done | `tab:exp:e1` caption: "Means over 5 seeds and over the three formulas (per-formula values in code/results/e1_universal.md …)". It adds the per-formula L1sel generator masses at n = 256 (0.516, 0.516, 0.731), read from e1_universal.md. |
| P-42 | minor | done | `rem:pa:merge` (App F): "linearly (2 bits per datum at n = 10⁶) under a learned rule law shared across depths" (tab:pa:rulecode). |
| P-43 | minor | done | E7 (App G): "favours small unsound lumps, slightly at τ = 1 and markedly at τ = 4". `tab:exp:summary` says "slightly" only for the time factor in general; the canonical `rem:time:e7` carries both qualifiers. |
| P-44 | minor | done | E3(a) (App G): "On heavy tails a depth-2 nesting (C_2, or {φ(z),φ(SSz)}) wins"; "On numerals the winner keeps changing as n grows". |
| P-45 | minor | done | Proof of `prop:pa:refl` (App F): "As for prop:time:notemplate (app:time:templates), with Prv_T for Acc_f." |
| P-46 | minor | done | Every main-text use of a statement that is only in App F gives its conclusion and "… in \cref{app:pa:…}". This covers the 16 items listed under §2 "moved for length", plus `lem:pa:motive`, `prop:pa:fragments`, `prop:pa:redundant`, `rem:pa:overlap` and `tab:pa:mdl`. `rem:exp:limits`(iii) also points to App F for `prop:pa:occam`. |
| P-47 | minor | done | §7.3 no longer re-quotes AS's MDL sentence. It gives one clause with a pointer to `rem:ident:mdl`, and the qualifications are cited as `rem:ident:mdl`(i), (ii). |

### Checked and corrected from the first session

* The pointer to `prop:pa:must` in pa.tex said "Q+T_Ind beats Q plus one or two library theorems". That is false for a single short theorem (∀x 0+x=x costs 31.7 bits, less than 72 bits). It now reads "once they cost more prior bits than T_Ind (72 bits at β_ax = β; associativity alone suffices)".
* Pointers that had lost a qualifier were restored:
  * `rem:pa:streams`: the library is fixed in advance; from n = 10; the u = 0 case.
  * `rem:pa:e2`: the DTRC candidates were scored on other data.
* Numbers that had dropped out of the paper were put back in App F:
  * Q+T_Ind's masses at n = 10 and 30 in the DTRC run;
  * the full ex:pa:narrow sequence;
  * the note that AS Thm 5.16 holds with parameters.

## 2. Labels

* **Added** (DECISIONS §13): `rem:pa:sdpcrefuted`, `tab:exp:summary`, `app:exp:results`.
* **Deleted or renamed:** none. The label sets of the four files before (91adf1a) and after are identical apart from the three additions: 96 labels, no duplicates.

**Moved as decided (DECISIONS §3):**
* §7 → App F: `tab:pa:costs`, `prop:pa:recursion`, `prop:pa:chain`, the details of `def:pa:lsch` (no label), the code names, and the refuted constant-margin remark (now `rem:pa:sdpcrefuted`).
* §8 → §7: `prop:exp:comm`, just before `rem:pa:e6`. Its proof stays in `app:exp:comm`.
* §8 → App G (`app:exp:results`): `tab:exp:e1`, `tab:exp:e2`, `tab:exp:e3a`, `tab:exp:e3b`, the E1–E8 paragraphs and `rem:exp:refuted`.
* §8 → App G (`app:exp:impl`, `app:exp:exact`): the pool-construction details and the proof idea of `prop:exp:exact`.

**Moved for length under DECISIONS §2.** Each move left a pointer that states the conclusion with its qualifiers and says "in \cref{app:pa:…}".
* By the first session: `rem:pa:pat`, `prop:pa:lower`, `prop:pa:occam`, `rem:pa:streams`, `prop:pa:must`, `prop:pa:refl`, `prop:pa:regret`, `ex:pa:skel`, `prop:pa:spare`, `tab:pa:dtrc`, `rem:pa:lumps`, `rem:pa:merge`, `prop:pa:nc`, `ex:pa:euler`.
* By the second session, after prose tightening alone left §7 over its cap: `rem:pa:zf`, `prop:pa:gibbs`, `prop:pa:readonce`.

None of these answers the question directly. The answers stay in §7: `prop:pa:usage`, `rem:pa:usage`, `prop:pa:detour`, `prop:pa:memo`, `prop:pa:wellspec`, `prop:pa:thn`, `prop:pa:refute`, `prop:pa:isigma` with its refuted (c), `ex:pa:narrow`, `conj:pa:broad`, `prop:pa:atomic`, `prop:pa:incons`, `tab:pa:failures` and the answer itself.

**For the CLAIMS.md sync (front):**
* Section column "app" for all items moved for length, and for `tab:pa:costs`, `prop:pa:recursion`, `prop:pa:chain` and `rem:pa:sdpcrefuted`.
* Section column "pa" for `prop:exp:comm`.
* Changed statements: `def:pa:lsch` (β_ax), `prop:pa:memo`, `prop:pa:must`, `prop:pa:wellspec`, `prop:pa:gibbs`, `rem:pa:pointwise`, `rem:pa:zf`, `rem:pa:streams`(iii), `rem:pa:usage`(iii), `rem:pa:merge`, `rem:pa:e3b`, `ex:pa:skel`, `prop:pa:isigma`(c) (\mathcal L_∞), `prop:exp:exact`(d), `rem:exp:limits`.
* Status changes:

  | item | new status |
  |---|---|
  | `prop:pa:wellspec` | proved, given Thm 4.2 and known facts; proof sketch (Dirichlet weights) |
  | `prop:pa:occam` | (a) proved; (b), (c) proved under the growth condition of (b); computed |
  | `rem:pa:pointwise` | proved; open |
  | `rem:pa:shift` | proved; computed; open |
  | Kraft claim after `def:pa:lsch` | proved for β ≥ log₂(alphabet size) |
  | `prop:exp:exact` | (a)–(c) proved; (d) proved under the hypothesis of (d3), computed otherwise |
  | `rem:exp:limits` | (i), (v) computed; (ii)–(iv) properties of the code |

## 3. Follow-ups from the other groups' logs, and cross-group notes

**Requested of pa-exp by model-ident-sound-log.md §3:**
* The deleted App C paragraph "E8 windows" is now in App G, E8: "the split loses 1.60 bits per doubling of n under L1 and 1.76 under L0 on n = 1024…4096" and "the prior … adds 76.4 bits in favour of whole".
* Gold's languages are written \mathcal L_k, \mathcal L_∞ in `tab:exp:summary` (E5 row), the E5 paragraph and `tab:exp:e5`.
* experiments.tex cites `rem:ident:x5` (in `app:ident:gold`) where it says which theorem covers the experiments' posteriors (P-16).

**Requested of pa-exp by univ-time-log.md:**
* pa.tex's citation of `prop:time:codelength` (now App E) needs no change.
* The "where" column of `tab:exp:summary` uses `sec:univ:never` for E1 and `rem:time:e7` for E7.

**Notes for other groups:**
* front, `app-verification.tex`:
  * `tab:ver:corrections` can now cite `rem:pa:sdpcrefuted` for the constant SDPC margin.
  * The bounded-mass sentence changed (P-33).
  * `rem:pa:zf` is now in App F; app-verification l.181 cites it by label, so no change is needed.
* front, discussion F3: `prop:exp:exact` is unchanged in place, and its status now carries the (d3) qualification.
* model-ident-sound, `rem:ident:mdl`(ii): repeats pa's SDPC formula and the 762-bit value. Under DECISIONS §4 the canonical home of these numbers is `prop:pa:occam` and `tab:pa:mdl`, both now in App F. No action is needed if the duplication is accepted.
* All `\cref`s from other files to the moved labels still resolve. None of the citing sentences says "below" or "in this section". This was checked with `grep -n '<label>[},]' paper/sections/*.tex` for every moved label.

## 4. Page spans (main text, section start to the next section's start)

| section | before | target | cap | full build, binding preamble of §7 (scratch copy) | intrinsic (one tall page, binding preamble) | isolated `test-section.sh` (current preamble) | official `build.sh` (current preamble) |
|---|---|---|---|---|---|---|---|
| 7 pa | 8.4 | 6.5 | 6.75 | **6.67** (p. 33.00–39.67) | 6.61 | 6.74 | 6.80 |
| 8 experiments | 6.6 | 2.75 | 3.0 | **2.71** (p. 39.67–42.38) | — | 2.65 | 2.69 |

**How each column was measured:**
* "Full build, binding preamble" is a scratch copy of main.tex with tocdepth 1 and the §7 preamble code (front has not landed it yet), built from all current section files. It had 0 errors, 0 undefined references or citations, 0 multiply defined labels and 0 overfull boxes. Spans come from heading positions found with pdftotext -bbox (text block 640.8 pt from y = 75.6 pt). It is the measure DECISIONS §2 asks for.
* "Intrinsic" sets §7 on one tall page, so page-break effects drop out. For §8 it cannot be measured this way, because the summary table is a float held back by `\suppressfloats`.
* The isolated and official builds still use the superscript `\src` of the current preamble. In the official full build all 10 overfull boxes above 10 pt are in model.tex, ident.tex, sound.tex, app-model.tex and app-sound.tex, none in these files.

**Result:**
* §7 is under its cap in the binding measure, but 0.1–0.17 pp above its 6.5 target. Reaching 6.5 would need moving one of the results that answer the question (e.g. `prop:pa:isigma`, `ex:pa:narrow`, or `tab:pa:failures`), which §2 does not allow under the cap.
* §8 is on target.
* Appendices in the binding build: App F pp. 93–105 (13 pp), App G pp. 106–116 (11 pp).

**Builds:**
* `./test-section.sh pa app-pa` (21 pp) and `./test-section.sh experiments app-experiments` (14 pp) compile: 0 errors, 0 undefined citations, 0 overfull boxes. Every undefined reference is a label defined in another section file.
* The official `flock … ./build.sh`: 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels; the 10 overfull boxes are in other groups' files.

## 5. Deviations from DECISIONS, with reasons

1. **Moves beyond §3 for length.** See §2. Without them §7 was 7.2 pp after the fixes, and tightening alone did not bring it under the cap. The binding texts of the moved items (P1, P4, P13) were applied in their new place.
2. **`tab:exp:summary` placement.** It is placed with `[!t]` inside §8.1, and `\suppressfloats[t]` follows the §8 heading. Two other placements failed:
   * as a `[t]` float after §8.2's first sentence it drifted past the §9 heading;
   * as `[b]` it exceeded the bottom fraction and went to the end of the document.

   It now appears at the top of the second page of §8.
3. **P-32.** The caption quotes the source maxima (9·10⁻¹¹, 4·10⁻¹⁰), not the reviewer's "≤ 10⁻¹¹".
4. **P-26.** App G gives the mean gain at n = 4096 from the results file. The marginal rate for n = 1024…4096 stays only in the canonical `rem:ident:e8`, so that its numbers are not repeated (§4).
5. **§10.P12** is kept verbatim, including "the referee's 904 triples" (binding text). Only the \cref for (d3) was adapted.
