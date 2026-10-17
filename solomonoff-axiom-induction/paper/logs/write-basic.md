# Writer log: group "basic" (§2 Setting, §3 Basic theorems, Appendix A)

*Files: `sections/setting.tex`, `sections/basic.tex`, `sections/app-basic.tex`. Source: `research/tracks/fundamentals/notes-final.md` (all statements and proofs), with `laws` Props 1.8–1.9 (pointers only), `shape` §1.3 and `philosophy` Def 2.0 (questions), `logic` §1.3 (conventions); `OUTLINE.md`, `CLAIMS.md` §1–§2, `NOTATION.md`, `bib/bib-report.md`. No git command was run.*

## 1. Restart check

An earlier interrupted run had written `setting.tex` (complete) and `basic.tex` (complete in draft) and left `app-basic.tex` as the planning stub. Both drafts were read in full and checked statement by statement against the `fundamentals` record (hypotheses, quantifiers, constants, statuses); they were kept, with the corrections in §4. `app-basic.tex` was written in this run, in four saved parts.

## 2. What was written

* **§2 Setting** (`setting.tex`): language, background, data, conditionals; algorithmic notation and the two standard coding facts; fresh atoms and the literal language; theory machines, their laws and examples; $G_U$, $\MA$, $\MAthree$, $\Inc_0$, the trichotomy, $\Bel_0$ vs $\Belhat_0$, class probabilities; loss conventions (with the transfer rule for upper bounds only); the two defects; versions and their agreement; complexities of theories; variants (consistency-requiring, graded, generative); questions and (E3). Credit footnote F1 is attached to the sentence before `rem:setting:defects`.
* **§3 Basic theorems** (`basic.tex`): structure; geometric and Dempster updating; computability ($\Inc_0$ theorem); dominance, invariance, background, translations, vocabulary; loss bounds (loss against a theory, exceptions, mistakes, three-valued merging, three-valued loss, lower bound); coding chain and no coding theorem; why proof-requiring is primary (CR weight, CR predictor, graded weight in prose, PR = CR for complete theories); limits and identification (prose summary); order dependence and the Kolmogorov predictor (prose); `q:basic:domination`.
* **Appendix A** (`app-basic.tex`), subsections `app:setting`, `app:basic:structure`, `app:basic:computability`, `app:basic:dominance`, `app:basic:loss`, `app:basic:coding`, `app:basic:cr`, `app:basic:limits`, `app:basic:order`, `app:basic:generative`, `app:basic:demski`, `app:basic:domination`: every proof of §2–§3, and the statements and proofs of the appendix rows.

All 58 rows of CLAIMS.md §1–§2 appear with their labels, `\status{}` and `\src{}` (checked by script). Definitions carry `\status{definition}` (prints nothing; `def:setting:complexities` has `\status{definition; the inequalities proved}`).

## 3. Page counts (isolated builds, `./test-section.sh`)

| file | pages | budget |
|---|---|---|
| `setting.tex` (§2) | about 4.7 | 3 |
| `basic.tex` (§3) | about 7.0 | 4.5 |
| **main text, group total** | **about 11.7** | **7.5** |
| `app-basic.tex` (App. A) | about 19.9 | — |

`./test-section.sh setting app-basic` and `./test-section.sh basic app-basic`: 0 errors, 0 undefined citations, 0 overfull boxes above 10pt. The three files compiled together (a private copy of the harness in the scratchpad) give 0 errors, 0 multiply defined labels, and undefined references only to other groups' labels (all in CLAIMS.md): `ass:soi:S`, `cor:soi:transfer`, `thm:soi:transfer`, `prop:laws:randomised`, `prop:laws:twopart`, `prop:logic:normalised`, `prop:shape:E2`, `rem:terms:named`, `thm:terms:horn`, `sec:laws`, `sec:logic`, `sec:terms`. `merge_bib.py`: no cited key supplied only by the fallback.

**The group is about 4 pages over budget.** Every row OUTLINE §E names for shortening §3 is already in the appendix (below). The remaining main-text rows are printed with their full statements, as CLAIMS.md §0 requires, and those statements are long. Further cuts would need the planning editor's decision on which further "main" rows may move: the natural candidates are `prop:basic:crorder` (its part (b) is about 8 lines), `thm:basic:merging`, `prop:basic:mistakes` and `rem:setting:versions`.

## 4. Deviations from OUTLINE / CLAIMS, with reasons

* **Rows moved from the main text to Appendix A for the page budget** (B.3; statement and proof in the appendix, a faithful prose summary with `\cref` in §3): `prop:basic:limits`, `prop:basic:textinformant`, `prop:basic:incomplete`, `thm:basic:order`, `thm:basic:kolmogorov` (the five rows OUTLINE §E lists), and `prop:basic:graded`. For `prop:basic:graded` ("main ((e) stated)") the §3 prose states the content of (b)–(e) precisely, (e) with its value ($-\frac12$ times the undecided mass, against $+1$ times it for $\MA$).
* **`rem:basic:factortwo`** placed in the appendix (CLAIMS allows "main (one line) or app"), worded at the level of `bib-report.md`: Vereshchagin (constant 2 for finite sets), Shekhovtsov–Zakharov (transfer to all sets up to logarithmic terms); the error term is not stated.
* **`prop:basic:crorder`(c)** (the explicit law, `fundamentals` Prop 7.2(c)) is an unnumbered `\paragraph{An explicit law.}` with its own `\status`/`\src` after the proof, since CLAIMS gives it no label.
* **`prop:basic:demski`** prints the parts the CLAIMS row names: (a) Process 1 complete a.s., (b) Process 2 complete a.s. (with the one-by-one variant), (c) $\MA$'s independent mass $\ge\epsempty$, class probabilities, almost-sure incompleteness above $\Q$, (d) PR = CR via `prop:basic:prcr`. `fundamentals` Prop 10.1(c) (consistency test needs $\emptyset'$; Church–Kalmár) is a sentence after the proof; 10.1(d) (a remark in the record) is left out. The processes are defined explicitly; the identification with Demski's prior and the modified prior is stated as a reading ("as it is usually described"; "at the level of the published descriptions"), citing `demski2012logical`, `garrabrant2015modification` (attribution only) and `garrabrant2016inductive`, per bib-report §3.
* **`prop:basic:generative` / `rem:basic:generative`** (P/S split): the proposition states (ii), (iii) under the explicit hypothesis "support condition" ($\supp P_A=\Cn(A)$); the remark states (i), (iv) and gives a proof sketch, first sentence naming what is not written out.
* **Symbol renames** (NOTATION rule 2, local symbols must not be global ones): the sentence $c$ of `fundamentals` Thm 11.1 → $\chi$ (and $c_i$ → $a'_i$); $e_{i,j}$ (Prop 7.2) → $\zeta_{i,j}$; generative data $X_i$ → $\sigma_i$; record's $\Pr$-quantities $\Pl(b),T,\rho,\delta,N$ → $\kappa,\theta,r,q,z$; $N_{a\to b}$ → $q_1,q_2$; cell masses $X,Y,Z,W$ → $m_1,\dots,m_4$; oracle machine $\Phi$ → $\mathsf M$; $g$ (Lemma 8.0) → $\kappa$; $O_b(\sigma)$ → $Q_b(\sigma)$; $E_{\vec\imath}$ (Prop 11.2) → $D_{\vec\imath}$; $\pi(w)$ (Thm 11.3) → $p_w$; the halting set $K_0$ → $\mathcal H$; the extra element $a$ of the nonstandard model → $\star$, and $\theta$ there → $\vartheta$; $\lambda_D$ (Prop 7.4) written out as $\MA(D)/\MAnc(D)$; generative posterior $\pi_n$ → $\varrho_n$; Th$(A)$ → $\Cn(A)$.
* **Corrections to the earlier draft of the main text:**
  * `def:setting:questions`: "a compatible theory must leave every antecedent open" (from the `shape` record's reading) is not exact under (E3), which only forbids refuting the antecedent; now "a compatible theory may not refute an antecedent, so no single world fits question data with two incompatible antecedents".
  * `thm:basic:inc`: the novelty wording now follows CLAIMS ("a new application of the standard argument that $\Omega_V$ is Solovay complete").
  * citation phrasing "as \citet{pearl1988probabilistic} puts it", "usually attributed to \citet{suppes1977using}" (bib-report §2.1 hedges kept).
* **Printed numbers of the earlier report** used for the `fundamentals` record's TF/AI-paper items (read from `../axiom-induction/paper/main.aux`): TF Lemma 2.1 → Lemma E.12; TF Thm 2.2(b) → Theorem 6.14(a); TF Def 1.1 → Definition E.10; TF Lemma 1.6 → Lemma E.11; AI-paper Def 6.2, Thm 6.3, Defs 2.9, 2.12, Lemma 2.10, Lemma 2.21, Exs 2.15–2.16, Props 2.17–2.19, 2.22, 7.11, B.8, Thms 3.9, 4.2 unchanged. Companion-paper numbers (Defs 3.2, 3.4, 3.6; Props 3.3, 3.7, A.2, A.7, A.10; Ex 3.5; Thms 3.8, 4.4, 4.9, 5.1, 5.3, 9.10; Cor 5.4; Questions 3.14, A.8) checked against its `main.aux`.

## 5. Statuses rendered (non-plain)

| label | status | rendered as |
|---|---|---|
| `rem:setting:versions` (b) | proved, given Lemma E.12 and Thm 6.14(a) of the earlier report, under (S) | "under \cref{ass:soi:S}" in the statement; the text and the appendix proof cite the two results and say (S) is not re-derived |
| `prop:basic:geometric`, `prop:basic:dempster` | proved; computed; rule names known | names cited after the statements at bib-report's levels |
| `thm:basic:inc` (c) | proved, given Chaitin and Levin–Schnorr | Chaitin cited where used; Levin–Schnorr "(standard; see Li–Vitányi)" in App. A.3 |
| `lem:basic:demuth` | known + proved for completeness | "a form of a theorem of Demuth, as it is attributed in the literature … we prove the form we need, for completeness" |
| `prop:basic:wholetheory` (b), `prop:basic:tape` (c) | proved, given Solovay 1977 | Solovay's theorem stated before, "in the form stated by Vereshchagin" |
| `rem:basic:factortwo` | known | cited, error term not stated |
| `prop:basic:textinformant` | proved; known in substance (Gold) | "This is Gold's distinction … (cf. Gold 1967)" |
| `prop:basic:incomplete` | proved, given standard facts on $\Q$ | "two standard facts about $\Q$ (see Boolos–Burgess–Jeffrey)"; "a new application of …" |
| `prop:basic:demski` | proved for the processes as described | processes defined explicitly; identification stated as a reading |
| `prop:basic:generative` / `rem:basic:generative` | (ii),(iii) proved given (i); (i),(iv) proof sketch | P/S split as above |
| `prop:basic:domination` (c) | proved, given `thm:soi:transfer` | cited in the proof |
| `q:basic:domination`, `q:basic:tape`, `q:basic:indeporder` | open | `question` environments |
| computed parts | proved; computed | no numbers quoted, nothing added |

## 6. Citations used

`claudeSFI2026fundamentals`, `claude2026axiominduction`, `hanni2026notes` (footnote F1 only), `li2008introduction`, `belnap1976logic`, `shafer1976mathematical`, `pearl1988probabilistic`, `suppes1977using`, `dempster1967upper`, `chaitin1975theory`, `solovay1975draft`, `downey2010algorithmic`, `becher2006randomness`, `barmpalias2016random`, `kucera2001randomness`, `calude2001recursively`, `zvonkin1970complexity`, `craig1953axiomatizability`, `gold1967language`, `demuth1975constructive`, `downey2002randomness`, `solovay1977random`, `vereshchagin2007kolmogorov`, `shekhovtsov2023enumerating`, `deleeuw1956computability`, `boolos2007computability`, `smullyan1961theory`, `doob1949application`, `demski2012logical`, `garrabrant2015modification`, `garrabrant2016inductive`, `church1936note`, `kalmar1937zuruckfuhrung`. All are "citable" in bib-report §5, used for the content recorded there. Not cited: Jockusch–Soare (not citable; Prop 8.7 does not need it), Levin 2013 (optional related work, left out).

## 7. Final greps

`grep -n -i -E 'thread|track|scout|referee|workflow|agent|record|synthesis|ledger|brief|notes-final|verdict|revision|snippet|unverified|abstract level|not checked|AI-paper|\bP[12]\b|\bH(1[0-5]|[1-9])\b|\bTF\b|\bSD\b'` on the three files outside comments and `\src`/`\status` arguments: no hits. The only mention of Hänni's notes in printed text is footnote F1. No model names.

## 8. Items for other groups

* **laws:** `prop:laws:randomised` is labelled twice (`laws.tex` line 66 and `app-laws.tex` line 44); the full build will report a multiply defined label. `setting.tex` cites `prop:laws:randomised`, `basic.tex` cites `prop:laws:twopart`.
* **logic:** `setting.tex` cites `prop:logic:normalised` (not yet written). Appendix A provides `lem:basic:majority`, `prop:basic:limitpost`, `prop:basic:structures`, `prop:basic:noncomplete`, `prop:basic:incomplete`, `cor:basic:localdefect` for §5.
* **terms:** `setting.tex` cites `rem:terms:named` (the $\Kfin-\KA$ separation, `fundamentals` Prop 1.8(d)); `basic.tex` cites `thm:terms:horn`. Neither is written yet.
* **soi / shape:** `ass:soi:S`, `thm:soi:transfer`, `cor:soi:transfer`, `prop:shape:E2` are used and exist.
* **front (related work, intro):** `prop:basic:demski` (App. A.11) defines both completing processes explicitly and states what the modified prior and $\MA$ share (the sampling stage, not new) and where they differ; related work can cite it. The $\Inc_0$ theorem is worded as "a new application of the standard argument". `thm:basic:order` and `thm:basic:kolmogorov` are now in the appendix; intro pointers to `thm:basic:loss`, `thm:basic:inc` resolve to §3.
* **planning editor:** the page overrun (§3 above); the six moved rows (§4); `\status{definition}` on definitions (not in NOTATION §10's list; prints nothing).
