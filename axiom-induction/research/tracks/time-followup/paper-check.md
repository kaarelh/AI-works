# Fresh check of the paper against the two follow-ups

*Checker: a fresh instance, after the paper update. Sources: `notes-final.md` (this track, "TF") and `../short-derivations/notes-final.md` ("SD"). Checked: `paper/sections/time.tex`, `app-time.tex`, `intro.tex`, `abstract.tex`, `discussion.tex`, `app-verification.tex`, and `README.md`, plus a grep of every file in `paper/sections/`. No git command that changes repository state was run.*

## 1. Verdict

The new material in §6.6 (`sec:time:free`) and Appendix E.7 (`app:time:free`) matches the notes in scope and status, with the exceptions below. The exceptions are now fixed. One place still stated the collapse result without a direction: the abstract. The verification appendix said it had been corrected, but it had not been. It is now fixed.

## 2. Mismatches found and fixed

| # | where | problem | fix |
|---|---|---|---|
| 1 | `abstract.tex` | "penalising the time to check or generate axioms leaves Hänni's collapse intact": no direction. `app:ver:followups` claimed the abstract had been corrected. | "time-penalising axiom checking or generation leaves Hänni's collapse intact from function to axiom induction; penalising consistent function induction, not deduction, makes axiom induction strictly stronger; written derivation length prices the collapse". 249 words, within the 250-word limit. |
| 2 | `time.tex`, `rem:time:summary`(1) | "once function induction is penalised, axiom induction dominates it and beats it by n − O(1) bits". This is the overbroad form that TF refutes (§0, Prop 3.4): S and FIall_τ are time-bounded and not dominated. Domination is proved for consistent FI (TF Thm 3.1). The n − O(1) gap is proved for FIcons_τ, S and FIall_τ (Cor 3.3), not for every penalised consistent FI. | "once consistent function induction is clocked (FIcons^τ), axiom induction dominates it and beats it …". |
| 3 | `time.tex`, `rem:time:summary` status | (1) now rests on `thm:time:diagonal`, which is proved given the recursion and MRDP theorems. The status named only the self-simulation assumption. | Status adds "given the recursion and MRDP theorems (known)". |
| 4 | `time.tex`, `rem:time:summary`(4) | "(when B ∪ Γ_{f_X} is consistent)" had been dropped while the item was compressed. | Restored. |
| 5 | `time.tex`, `cor:time:separations` | (a) and (b) did not say that the fit classes NP ∩ coNP and EXPTIME are at polynomial budgets (SD Cor 3.2(a), Cor 4.4(i)). The last clause of (a), the separation from FIcons^τ, needs (S) (SD Cor 3.2(e), TF Cor 4.3(a)), and its status did not say so. In (b), "so some decidable X defeats it at any computable budgets" presented SD Cor 4.4(ii) as a consequence of (i), which it is not. | Added "at polynomial budgets" to both. (a)'s status adds "the last clause under a self-simulation assumption on U". (b) now reads "…; at any computable budgets some decidable X defeats it", and its status is spelled out instead of "likewise". |
| 6 | `intro.tex`, short answer 9 | (i) "Penalising function induction but not proof search makes axiom induction strictly stronger": "consistent" was missing (TF Prop 3.4, §11). (ii) "at constant cost" is wrong for a Kt penalty, which costs log₂(\|f\|+1)+O(1) (TF Prop 2.3). (iii) "with derivations from axioms of bounded total size" naturally reads as reading (b2), the theory's own axioms only. That reading is *not* time-limited (SD Prop 4.12). Certificate induction needs logical instances counted (SD Thm 3.1). | (i) "consistent" added. (ii) "(a Kt penalty: log₂(\|f\|+1)+O(1) bits)" added. (iii) Now "if the axiom instances of each derivation, logical ones included, have bounded total size". The short answer still ends on PDF page 4, as it did before the update. |
| 7 | `intro.tex`, A5 | "consistent" was missing, as in 6(i). Also, "Hard decidable assigners force every theory with polynomial membership …" dropped the earlier "for each polynomial bound on membership time". `cor:time:hard`(b) proves one X per exponent e. A single X for all e is only a proof sketch. | "consistent" added. Restored: "For each polynomial bound on membership time, a hard decidable assigner forces every theory within that bound …". |
| 8 | `discussion.tex`, "A time penalty" | "consistent" was missing, as in 6(i). "Axiom material" did not say that logical instances count (see 6(iii)). | Added "consistent" and "logical instances included". |
| 9 | `app-time.tex`, `cor:time:tight`(ii) | "a finite template theory derives each φ_w" was missing "consistent with Γ_{f_X}" (SD Cor 6.2(iv)). Without it the tightness claim is trivial. | Added. |
| 10 | `app-time.tex`, `prop:time:evaluator` status | (c) rests on Hänni's construction *and his theorem* for S (TF Prop 4.1(c), §8). The status named only the construction. | "… resting on Hänni's construction of S and his theorem for it". |
| 11 | `app-verification.tex`, corrections table, row "our summary to Hänni" | "once function induction is penalised the equivalence is one-sided and axiom induction strictly stronger". Against FIall^τ the two are incomparable, not one-sided. | "once consistent function induction is penalised …". |
| 12 | `app-verification.tex`, corrections table, row "brief H6" | "a Kt penalty prices it … Refuted": a direction-free statement about the collapse. | "Refuted for the direction from function to axiom induction; the other direction is `thm:time:onesided`(b)". |
| 13 | `app-verification.tex`, `tab:ver:followups` | (i) Row 1, "axiom-side penalties vacuous", has no direction and overstates the scope. TF Thm 2.2 covers P1a and P2. P3 is not vacuous in general (TF Prop 2.4(a), Rem 5.2). (ii) TF Lemma 1.6 (`lem:time:bounded`) was added in revision but is not listed. (iii) TF Prop 2.5 changed to the Diophantine form in revision (RL-m16), and the row said only "reframed". (iv) SD Thm 3.1(iii)(b): the θ_c construction with linear budgets is new in revision (SD §12.4 item 5), and the row did not say so. | (i) "checking and generation penalties vacuous from FI to AI". (ii) Row added: "added in revision". (iii) "Diophantine form and reframing in revision (RL-m10, m16)". (iv) "… the linear budgets of (c) added in revision". |
| 14 | `README.md`, answer 5 | (i) "at constant cost" is wrong for Kt, as in 6(ii). (ii) "the axiom-side penalties do not make the posterior prefer genuine axiom systems" is broader than TF Prop 5.1, which covers P1a, P2 and two-sorted P3. TF Rem 5.2 (proof sketch) gives a content-relative penalty that does separate in decidable logics. | (i) "(under a Kt-style penalty, log₂(\|f\| + 1) + O(1) bits)" added. (ii) Now "penalties on checking or generating axioms do not make …". |

## 3. Checked and consistent (no change)

**§6.6, main text.**

| paper | matches |
|---|---|
| `thm:time:onesided`(a), (b) | TF Lemma 2.1, Thm 2.2 (t ≥ m^{a*}, all three forms of P2), Thm 3.1 for FIcons_τ, with a constant depending on τ |
| `thm:time:diagonal` | TF Thm 3.2(c) bound n − 1/(4 ln 2); H_0 = Q ∪ {DET}; Cor 3.3(a), (b): n − 1.37 and n − 1.37 − c_⊥; Prop 3.4: incomparability on fair-coin literals; status: recursion and MRDP theorems |
| The paragraph after `thm:time:diagonal` | strictly stronger than time-penalised **consistent** FI and incomparable with possibly inconsistent time-bounded predictors (TF §11); evaluator proved, hierarchy effect a proof sketch (Prop 4.1); disguised assigners (Prop 5.1(a)) |
| `thm:time:sandwich` | SD Lemma 2.2 (bound (M+\|φ\|)(M+\|φ\|+1)/2, constant ½ attained, Prop 2.4(b)); SD Thm 3.1(ii), (iii) under (F1) |
| `cor:time:separations` (after fixes) | SD Cor 3.2(a)–(c), (e), Prop 3.4, Cor 4.4(i)–(ii), Prop 4.5, Prop 4.12; TF Cor 4.3(c)–(e) |
| Soft charges | SD Thm 5.2 and Prop 5.3: correspondence only up to a rate factor; no pair of rates gives two-sided constant regret |
| Templates | SD Prop 6.1, Cor 6.2 (BGW, known, not checked); non-literal data open |

**Appendix E.7.** Every proof was compared with its source item:

| paper | source |
|---|---|
| `def:time:penalties`, `lem:time:bounded` | TF Defs 1.1, 1.2, Lemma 1.6 |
| `lem:time:padded` | TF Lemma 2.1: the constants α(\|q\|+1)+3α(\|χ\|+1)^{a'}, 2α\|a_i\|^a, 5α\|a_i\|^{a*}, 2α(Σ\|a_j\|)^a |
| `prop:time:kt` | TF Prop 2.3: W(∅) ≤ t(m_0), two-sided bound |
| `lem:time:qfacts` | TF Lemma 1.4 |
| Proof of `thm:time:diagonal` | TF Thm 3.2, Cor 3.3, Prop 3.4. The mixture P(D) = (W_{FIall^τ}(D) + 2^{−\|D\|})/2 agrees with TF's (W + 2^{−\|D\|})/(W(∅) + 1), because W_{FIall^τ}(∅) = Σ_f w(f) = 1. |
| `prop:time:evaluator`, `prop:time:disguised`, `prop:time:bounded` | TF Prop 4.1, Prop 5.1(a), Prop 2.5 |
| `def:time:short` | SD Defs 1.2, 1.3, 1.6, with (F1); TF Def 1.3 |
| `lem:time:subformula`, `lem:time:renaming` | SD Lemmas 1.1, 2.1, 2.2, Cor 2.3, Prop 2.4(b); SD Lemma 4.1 |
| `prop:time:budgets` | SD Thm 3.1. The budgets 2d'+m+31 and d'+m+16, and the derivation size 2\|c\|+29+2\|φ^b\| ≤ 2d'+2m+31 for AI[t, d], all recomputed from the three-line derivation. |
| `lem:time:clocked` | TF Cor 4.3(a) |
| Proof of `cor:time:separations`(a) | SD Cor 3.2, Prop 3.4. The tail Σ_{k≥K} 2^{−2⌈log₂(k+1)⌉−1} ≤ 1/(2K) was rechecked. |
| `prop:time:aone`, proof of (b) | SD Thm 4.2, Prop 4.3, Cor 4.4, Prop 4.5 |
| `prop:time:horn` | SD Prop 6.1, Rem 6.4(3) |
| Proof of (c) | SD Prop 4.12 |
| `cor:time:tight` | SD Cor 6.2(iii), (iv) |
| `prop:time:soft` | SD Def 5.1, Thm 5.2(a), (b), Prop 5.3; e_1 = 31b_s+24, r = 31b_s+26 |
| `prop:time:channel` | SD Prop 7.1(a)–(d): sizes 9\|ψ\|+54, 5\|ψ\|+40, 3\|ψ\|+13 |
| `lem:time:truncate` | SD Lemma 7.2, Thm 7.4(a), (b) |
| Proof of `thm:time:ntime` | Now bounds parameter numbers via `lem:time:truncate` (SD Thm 7.4(a), Rem 7.5); the statement is unchanged, with membership time in symbols |

**Verification appendix.**
* Referee issue counts: TF 2+18 and 5+20; SD 1+12 and 3 (one shared)+14. They match TF §10 and SD §12.
* The list of unchecked references matches the notes' tags.
* The open-problem list (10) matches TF §7 and SD §9 for the items the paper reproduces.

**Page claims.** README's "147 pages" and "main text about 43 pages" match the build (§3 below).

**Grep of all sections.** The patterns covered "collapse", "time penalt", "does not (stop|block|bite|price)", "doesn't", "survive", "intact", "vacuous", "Kt", "speed prior" and "penalis". After the fixes, every statement that a penalty leaves the collapse alone names the direction.

The remaining hits are of four kinds:
* about templates, not time penalties: `intro.tex` A3, `discussion.tex` "Templates";
* about what an experiment does not test: `app-experiments.tex` E7;
* the quoted summary sentence itself, in `time.tex` §6.6 and `app-verification.tex`;
* a historical log entry: `app-verification.tex` `tab:ver:writing`, row "time", "no time-penalised prior is defined". It records an earlier review edit and is now superseded by §6.6, but it is left unchanged as a record.

## 4. Build

`cd paper && flock /tmp/claude-0/paper-build-ai.lock ./build.sh`, run after all fixes:

| item | result |
|---|---|
| LaTeX errors | 0 |
| undefined references | 0 |
| undefined citations | 0 |
| multiply defined labels | 0 |
| overfull hboxes > 10pt | 0 (one of 0.57pt, `app-verification.tex` line 164) |
| other warnings | the existing font-shape substitution (T1/lmr/bx/sc); bibtex: empty publisher in `zarach1996replacement` (already listed as unchecked) |
| total pages | 147 |
| front matter (title, abstract, contents) | pp. 1–2 |
| main text §§1–9 | pp. 3–45 (43 pages; References begin on p. 45) |
| §6 | pp. 27–33 |
| References | pp. 45–49 |
| Appendices A–H | pp. 49–147 (Appendix E pp. 86–107; H pp. 132–147) |

For comparison, the committed PDF before the follow-up update had 127 pages, main text pp. 3–44, and §6 at pp. 27–32. The main text grew by about one page.

## 5. Not changed, for the record

* `time.tex` after `prop:time:cheap` says that a Kt or speed-prior penalty on checking "neither prices the direction of the collapse from function to axiom induction". Under Kt this is a charge of log₂(\|f\|+1)+O(1) bits, which `rem:time:summary`(1) states. TF Rem 2.6(1) also counts that as not blocking that direction, so the sentence was left as is.
* `cor:time:separations`(b) paraphrases SD Prop 4.5's hypothesis ("approximable within 2^{−k} in time polynomial in j + k") as "computable in time polynomial in the number of data". The appendix proof states the exact hypothesis.
* The status of `cor:time:tight`(ii) does not repeat that its lower half is `cor:time:hard`(a), which is proved given the NTIME hierarchy theorem.
* `app:ver:repro` lists the four main tracks' scripts only. The follow-ups' scripts are named in `app:ver:followups` and Appendix E.7.
* The paper says that each follow-up reran its scripts with byte-identical outputs, following the notes. The notes compare against their own first-session outputs. In git, `short-derivations/checks/c1_subformula.{py,out}` differ from HEAD, which holds an earlier archived prototype (seed 20261009). The notes cite the working-tree version (seed 20261010). This checker did not rerun the scripts.
