# Track "imitation": final check of the synthesis (2026-10-14)

*A fresh check of `notes-final.md` (this folder) and its drafts against the two sub-track records and their referee reports. Written by the final checker. Nothing here is new mathematics: each entry says whether a statement or a sentence of the drafts matches what the records prove, with the record's hypotheses, quantifiers and constants, and what was changed where it did not.*

* **Sources read.**
  * The brief `00-brief.md`, in full, including the author's message.
  * `notes-final.md`, in full: every table, every LaTeX block and the Verification log.
  * `robust/notes-final.md`, in full. `robust/referee-A.md`: §§2, 4 (A1, R1, A3, A4), 5, 6. `robust/referee-B.md`: the section list and the B1–B3 headings; its verdicts are those recorded in the robust record's revision table.
  * `decay/notes-final.md`, in full. `decay/referee.md`: §3 (literature, every entry) and the M/m items that the drafts use.
  * Paper 2 (`paper-steeper/sections/`), at the statements the drafts cite or rest on: `lem:kink:main` and `def:kink:kinks`; `thm:recovery:main`; `prop:recovery:beyond`; `prop:recovery:necessity`; `prop:recovery:frozen`; `def:teacher:instance`; `prop:parity:range`; `prop:limits:noident`; `rem:teacher:numbers`; `prop:related:computability`; `q:related:open`; the Hellinger gap in `recovery.tex` and `\Hel` in `preamble.tex`; the abstract.
  * `research/paper-review/DECISIONS.md` §A5 (process vocabulary).
* **Scripts re-run.** `checks/s1_synthesis.py` and `robust/checks-final/f7_closeness.py` (§7).
* **Build.** A fresh scratch copy of `paper-steeper/` with every draft applied (§8).
* **Status tags.**
  * **[match]**: the draft or record says what the cited result proves.
  * **[fixed: Fn]** or **[fixed: Rn]**: it did not; the edit is listed in §6.
  * **[note]**: correct as written, but worth knowing; or a point in a sub-track record, which this check does not edit.
  * **[computed]**: re-run here.
* **Repository.** No git command was run. Files written: this file. Files edited, minimally: `notes-final.md` and seven files of `drafts/` (`imit.tex`, `wd-remark.tex`, `wd-appendix.tex`, `intro.diff`, `discussion.diff`, `teacher.diff`, `app-teacher.diff`). Scratch files (the edit scripts, the copies of the two scripts, the build) are in the session scratchpad only. The sub-track folders and `paper-steeper/` are unchanged.

---

## 0. Verdict

* The synthesis is accurate on the mathematics. The bounds, constants and proofs of every theorem, lemma and proposition of the drafts match their sources in the robust or decay record [match, §1, §2]. Three formal statements had a gap and were fixed [fixed, §6]:
  * the near-imitation theorem named the wrong distance (F2);
  * `prop:imit:limits`(a) lacked the hypothesis $|\Sigma|\ge2$ (F4);
  * the weight-decay example lacked $0<q$ and $\varepsilon>0$ (F12).

  Two places in the drafts improve on the records, and both were checked:
  * the right side of `thm:imit:main`(ii) is $c\ell_0+\epsilon$, from `lem:kink:main`(iv) with $\ell_{\mathcal M}=0$, where the robust record wrote $c(\Gamma+\kappa)+\epsilon$;
  * $B_\beta:=K(\beta\mid h_0,\mu)$ without the extra condition $K(h_0\mid\mu)$; the three facts it is used through are re-derived in §1.
* Twelve sentences of the draft LaTeX said more than is proved, or less precisely. Each was fixed by a minimal edit (F1–F12, §6.1). The six of substance:
  * **F1.** The range of $c$ on which near-optimal hypotheses are close to the person, measured on the scale of the best predictor's $H(\rho)$, is about $(2^{-m},H(\rho)/\ell_0)$, not $(2^{-m},1/\ell_0)$. The old text contradicted the draft's own example: for the parity person the bound already exceeds $H(\rho)$ at $c=10^{-4}<1/\ell_0$.
  * **F2.** "Hellinger gap ${\Hel}_{\bar\mu}(\pi)$" would be read, by Paper 2's definition, as the gap from the data's sampler $P^*$. The bound is for the gap from the person.
  * **F3.** "No hypothesis predicts better in population" was stated without its hypotheses: product hypotheses and i.i.d. pairs.
  * **F5.** "Persons whose kernels agree $\bar\mu$-a.e. share a data law" is false with environment-driven coins when ρ has ties; the draft's fair-coin person is such a case.
  * **F10.** "The learners are not computable" is proved for the steeper predictor; for the λ-MAPs it is an open question of Paper 2.
  * **F11.** The weight-decay remark dropped the differentiability that its limit statement needs; the appendix's own $|\theta-1|$ example refutes it without that hypothesis.
* Nine further edits to the record outside the LaTeX (R1–R9, §6.2) keep its tables consistent with the drafts.
* **Citations.** Every work that the weight-decay drafts cite was verified by the decay referee, with the attributions the drafts make [match, §3]. The imitation drafts also cite three works outside the referee's list; they are already in Paper 2's bibliography and cited there for the same facts [note, §3].
* **Caveats.** Each claim of the caveat drafts is supported by a proved result or is marked as a remark. After F8–F10, the toy cases are named with their hypotheses and the open problems with their exact status [match, §4].
* **Scripts.** Both re-runs are byte-identical to the saved outputs [computed, §7].
* **Build.** The build is clean after the edits: 84 pages, with the same page positions as before [computed, §8].

---

## 1. The imitation drafts (`sec:imit`, `app:imit`) against `robust/notes-final.md`

| draft item | source | check | status |
|---|---|---|---|
| `rem:imit:private` and `app:imit:private` | robust Lemma 2.1; Thm 2.2(2),(3) | Filtration, (Priv), supermartingale, Ville, "keeping one term": as in Lemma 2.1. The population claim and Theorem A need product hypotheses, i.i.d. pairs and countable $z$ (Thm 2.2(2),(3), Def 2.0). The remark stated the population claim before these hypotheses | [fixed: F3] |
| `def:imit:setting` (a)–(c) | Setting 4.1 | Channel, exact type, injectivity, copies on $\supp\mu$, $P^*$: as in the record, with $B$ renamed $\Sigma$ | [match] |
| `def:imit:setting` (d), $D_{1/2}$ | Setting 4.1; Paper 2's $\Hel(P,Q):=1-\sum_y\sqrt{PQ}$ (`recovery.tex`) | $-2\log(1-\Hel)=-2\log\sum\sqrt{PQ}$ | [match] |
| $B_\beta:=K(\beta\mid h_0,\mu)$ (synthesis §2.2) | Setting 4.1 conditions also on $K(h_0\mid\mu)$ | Re-derived here. (1) $K(\beta\mid h_0,\pi,\mu)=B_\beta-I_\beta$ is the definition. (2) $B_\beta\le\ell(\pi)+K(\beta\mid h_0,\pi,\mu)+\kappa$ is subadditivity relative to $(h_0,\mu)$ with (F1). (3) $\Prob[\delta_\beta>j]<2^{-j}$: a prefix-free set has fewer than $2^x$ programs shorter than $x$. And $\delta_\beta\ge-1-\kappa$: the index of β in its type class has the length $\lceil L_\beta\rceil$, computable from $(\rho,m)$. Case (L), which needs the extra condition, is not in the drafts. Prop 4.11(a) also holds with the simpler definition | [match] |
| text after the definition | Setting 4.1 (three readings); `def:teacher:instance` | The teacher is the feature case: $w$ is the first $m$ bits, $|S|=s_0=p2^m$, so β has exact type. Type-class bounds are as in Cover and Thomas | [match] |
| `lem:imit:coding` | Lemma 4.4 | Same statement and proof | [match] |
| `lem:imit:closeness` | Lemma 4.6 | Same statement, with $E(\pi)=E_m(\pi)$ and $|\Sigma|=|B|$. Each step re-derived: Hölder; AM–GM; Cauchy–Schwarz; $k=\lfloor-\log Z\rfloor$ with $-k<\log Z+1$; $K(k)\le2\log(k+1)+\kappa$; $k\le-\log Q(\beta)$. The last division leaves a $+1$, absorbed in κ | [match] |
| `thm:imit:main`(i) | Thm 4.7(U)(ii) | `lem:kink:main`(ii) with $\mathcal N=\emptyset$, $\tau=2^{-m}$, $g=G/2^m$: $\ell_0+(G+2^m\epsilon)/(a-1)$ | [match] |
| `thm:imit:main`(ii) | Thm 4.7(U)(iii) | Left side: $(cg+\tau\epsilon)/(c-\tau)=(aG+2^m\epsilon)/((a-1)2^m)$. Right side: `lem:kink:main`(iv) (read in Paper 2) gives $H+\epsilon+c(\alpha_{\rm r}-\ell_{\mathcal M})=H+\epsilon+c\ell_0$. This is sharper than the record's $c(\Gamma+\kappa)+\epsilon$, and correct | [match] |
| `thm:imit:main`(iii) | Thm 4.7(U)(iv) | $I_\beta\le\ell(\pi)+\kappa$ with (i) | [match] |
| `thm:imit:main`(iv) | Thm 4.7(U)(vi) | The algebra was redone: bracket $=\frac a{a-1}G+\frac{2^m\epsilon}{a-1}+E+\kappa$, so the bound is $c\ell_0+\frac{2a}{a-1}\frac{G+E+\kappa}{2^m}+\frac{a+1}{a-1}\epsilon$; and $E(\pi)\le E$ by (ii). The Hellinger form was named "${\Hel}_{\bar\mu}(\pi)$". Paper 2 defines that as the gap from the data's sampler, here $P^*$, and the bound is for the gap from $\nu_H$ | [fixed: F2] |
| bound on Φ | Thm 4.7(U)(v) | $\Delta(c)=G/2^m+(c-2^{-m})\ell_0\le G/2^m+c\ell_0$ | [match] |
| last sentence (memoriser) | Thm 4.7(vii); Prop 4.10(c) proof | Length $\ell_0+\lceil L_\beta\rceil+a_\rho+\kappa$, $a_\rho$ as in the record; threshold $\ge2^{-m}(1+(a_\rho+1+\kappa)/(2^mH))^{-1}$ from $\lceil L_\beta\rceil\le2^mH+1$. The exact-recovery step was checked: values are multiples of $2^{-m}$, a sum above $1-2^{-m}$, rounding up | [match] |
| text after the theorem: informative range | Thm 4.7(vi); record §4.4 "What the theorem says"; synthesis §1.3 | The bound must be compared with the best predictor's $H(\rho)$, so it is informative for $c\ll H(\rho)/\ell_0$ and $\ell_0+\delta_\beta+|\Sigma|m\ll2^mH(\rho)$. The draft said $c$ up to "about $1/\ell_0$", which its own parity example ($c=10^{-4}$) contradicts. The robust record has the same wording [note, §5] | [fixed: F1] |
| text after the theorem: numbers | s1(A) | $6.139\cdot10^{-4}\to6.2\cdot10^{-4}$; $9.421\cdot10^{-4}\to9.5\cdot10^{-4}$; $1.2356\cdot10^{-2}>0.011174$. Re-run identical (§7) | [match] |
| text after the theorem: $cn$-MAPs | Cor 4.9; `prop:recovery:beyond`(c) (read) | Every $cn$-MAP eventually lies in $\arg\min J_c$, hence (i)–(iv) with $\epsilon=0$ | [match] |
| `prop:imit:limits`(a) | Prop 4.10(a2),(a1) | The bound matches. The twin with person $P^*$ differs from the person only when $|\Sigma|\ge2$, which the appendix proof uses and the statement omitted | [fixed: F4] |
| `prop:imit:limits`(b) | Prop 4.11(a),(b) | $m\ge2$ is implied by $1\le s_0<2^{m-1}$; the bound is $2^{-L_\beta}$; the bijection argument is unchanged | [match] |
| "No window in (b)" (appendix) | Prop 4.11(c) | Both thresholds were recomputed; the constant $4\log(m+1)$ is as corrected in the record | [match] |
| `prop:imit:limits`(c) | Prop 4.10(c) | The two cases $c\le H/(K+\kappa)$ and the reverse were redone; neither program is a copy | [match] |
| the cell count | Prop 4.10(d) | $H(\ell_0-\ell_{\rm u})<(\log|Y|-H)(\lceil L_\beta\rceil+a_\rho+\kappa)$, then $\lceil L_\beta\rceil\le2^mH+1$ | [match] |
| text after the proposition: behaviour, not mechanism | Prop 3.1 (private coins) | With environment-driven coins the data law is $\bar\mu\otimes P^*$, and $P^*$ depends on $h$, not only on the kernel. Counterexample: the fair-coin person with $h(x,b)=b$ against $h'(x,b)=1-b$, which have equal kernels but data laws with $P^*=\ind[y=\beta(w)]$ and $\ind[y=1-\beta(w)]$ | [fixed: F5] |
| section introduction: in-context learner | Prop 5.2 | $J_\lambda(\pi_U)-J_\lambda(\pi_H)\le\lambda(\ell_U-\ell_H)+\log(1/w)$ | [match] |
| `q:imit:open` | §8 items 1, 2, 4, 6, 7 | Item by item | [match] |

---

## 2. The weight-decay drafts against `decay/notes-final.md`

| draft item | source | check | status |
|---|---|---|---|
| remark, paragraph 1 | Remark 1.2, 1.4; Props 2.1, 2.2(i)–(iii), 2.3; Prop 3.2 | Full support, summability, "charges $\mathcal E$", "outside a thin band": all as proved | [match] |
| remark, paragraph 2, Gaussian prior | Prop 4.1(b) | It holds only for $f=-\ln p_\theta$; the remark did not say so | [fixed: F11a] |
| remark, paragraph 2, the limit | Prop 4.2(i) | It needs a differentiable $L$. Without that it is false: $L=|\theta-1|$, $\omega\le1$ (Prop 4.2's own example, quoted in the appendix) | [fixed: F11b] |
| remark, paragraph 3 | §4.4; decay referee §3.1 | Each attribution is the one the referee confirmed at abstract level, including the referee's suggested wording for Hinton and van Camp (m8 placement for MacKay) | [match] |
| `prop:teacher:nofixedprior`(i)–(iv) and proof | Props 2.1, 2.2(i)–(iii),(v), 2.3, 3.2 | Hypotheses and thresholds line by line | [match] |
| paragraph after the proof | Examples 2.4, 2.6; d3(C) | $c_+/2^{-m}\in[1.00447,1.01141]$, printed as "between 1.0044 and 1.0115" | [match] |
| weight-decay paragraph | Props 4.1, 4.2; §4.4 item 4 | Stationary points; the $|\theta-1|$ example; the SGDW fixed points | [match] |
| `ex:teacher:weightdecay` | Example 4.3 | Setting: Example 4.3 assumes $\varepsilon>0$ and $0<q<\frac12$. The draft gave only $q<\frac12$, but the formula for $a^*$ needs $q>0$ and the box threshold $2\varepsilon/\ln((2-3q)/q)$ needs $\varepsilon>0$. Claims (c)–(e), ω*, the finite-$n$ counts and the thresholds $0.1028$, $0.8222$ (s1(E): $0.102780$, $0.822237$) all match | [fixed: F12] |
| related-work sentence | §6.3; decay referee on `zhu2026overfitting` | Verb "read", as the referee advised | [match] |
| discussion sentence | Props 4.1, 4.2; Example 4.3 | Summary | [match] |
| BibTeX `drafts/imit.bib` | `decay/refs.bib` | All eleven entries are field-for-field identical to `refs.bib` (compared by script, whitespace-normalised); no key collides with `paper-steeper/bib/*.bib` | [match] |

---

## 3. Citations in the drafts

| key | where | verified by the decay referee | status |
|---|---|---|---|
| `krogh1992simple`, `mackay1992practical`, `hinton1993keeping`, `vanlaarhoven2017l2`, `mandt2017stochastic`, `loshchilov2019decoupled`, `xie2024implicit`, `power2022grokking`, `liu2022towards`, `liu2023omnigrok`, `nanda2023progress` | weight-decay remark and example | yes, §3.1, each with the attribution used | [match] |
| `zhu2026overfitting` | related-work sentence | yes, §3.2 (paraphrase level, verb "read") | [match] |
| `zhang2006epsilon`, `bissiri2016general`, `bhattacharya2019fractional`, `grunwald2012safe`, `grunwald2017inconsistency`, `wenzel2020good`, `barron1991minimum`, `grunwald2007suboptimal`, `zhu2025quantifying` | unchanged context lines of `related.diff` | yes, §3.2 | [match] |
| `cover2006elements`, `li2008introduction`, `ville1939etude` | `imit.tex`, `app-imit.tex` | **no**: outside the decay referee's scope. All three are in `paper-steeper/bib/` and cited in Paper 2 for the same facts (type-class bounds in `def:teacher:instance`; the facts (F1)–(F5) in `app:setup:facts`; Ville's inequality in `lem:split:ville`) | [note; recorded in `notes-final.md` §3.4 (R6)] |
| `claudeSFI2026fundamentals`, `hanni2026grokking`, `hanni2026notes`, `vaintrobhanni2026nnbayes` | unchanged context lines of `intro.diff`, `discussion.diff` | not new citations | [note] |

`notes-final.md` §3.4 said "every work cited by the drafts" was confirmed three times; that is true of the weight-decay drafts only (R5).

---

## 4. The caveats against the results

| caveat claim (draft) | support | status |
|---|---|---|
| neither motivating problem is solved; tools offered | the author's message; the list of open gaps | [match; remark] |
| toy case 1, exact recovery per query | `thm:recovery:main`(a) | [match] |
| toy case 2, the full table of a noisy parity | `prop:parity:range`(iii): dyadic $p<\frac14$, large $d$. The draft now names the flip-rate condition | [fixed: F8a] |
| toy case 3, the teacher | `thm:teacher:main`, `rem:teacher:hypotheses`, `prop:teacher:rates` | [match] |
| toy case 4, environment-driven coins | `thm:imit:main` gives near-copies only. The draft now says "up to near-copies", as the table row already did | [fixed: F8b] |
| "the last two for the population objective; from samples only asymptotically or with large constants" | `prop:teacher:schedules`(c), `cor:teacher:sampled`; `prop:recovery:beyond`(c) | [match] |
| contributions bullet, "other hypotheses predict better" | true only when the input carries information about the cell (Prop 4.2(b); latent-cause case with $x$ independent of $w$ has $P^*=\nu_H$) | [fixed: F6a, "can predict better"] |
| "no procedure copies a sampler / person entangled with its coupling" (bullet, table row, discussion (3)) | `prop:imit:limits`(b) bounds the probability by $2^{-L_\beta}$; it does not exclude copying | [fixed: F6b, F7, F9, "reliably"] |
| (1) behaviour, not mechanism | Prop 3.1; a minimiser of $J_c$ is shortest for its own kernel | [match] |
| (2) split and complexity weight are conventions | `prop:limits:noident`; `prop:imit:limits`(a); referee A §5.6(ii) for the deterministic-state remark | [match] |
| (3) structured errors and couplings; rate, not validity | `prop:limits:rateblind`, `prop:limits:separable`, `prop:imit:limits`(c) ("cheap" relative to the person's length, as in their hypotheses) | [match] |
| (4) frozen labels | `prop:recovery:frozen`(a) | [match] |
| (5) memory; in-context learners excluded by the class | `thm:split:shared`, `prop:absorb:history`, robust Prop 5.2 | [match] |
| (6) "the learners are not computable" | `prop:related:computability`(b) proves it for the steeper predictor's conditionals. Whether a computable map from data sets to λ-MAPs exists is `q:related:open`(b), open | [fixed: F10] |
| (6) no computable sample size; class and machine dependence | `prop:recovery:necessity`(e) (margins below every computable function); `rem:teacher:numbers` (windows at κ = 0 and 30) | [match] |
| the brief's list of philosophical problems | all six present: behavioural equivalence (1); λ or $c$ not choosable (2); structured errors (3); frozen labels (4); uncomputability (6); class and reference machine (5), (6) | [match] |

---

## 5. Notes: correct as written, or outside this check's remit

1. **The robust record** writes the informative range as "$c$ between $2^{-m}$ and about $1/\ell_0$" (§0 item 3, §4.4, §6.1 item 3). F1 explains why the scale is $H(\rho)/\ell_0$. The record also writes "$\ell_0\ll2^m$" and "$\delta_\beta\ll2^m$" where the bound needs $\ll2^mH(\rho)$. The robust record was not edited.
2. **The robust record**, §6.2 item 9, says "$\Hcl{\times}$, the λ-MAP and the power posterior are not computable". For the λ-MAP, Paper 2 lists this as open (`q:related:open`(b)). Not edited here; the drafts no longer say it (F10).
3. **"On many more cells than it has bits"** (contributions bullet, table row, scope paragraph) is an informal summary. The precise condition is $\ell_0+\delta_\beta+|\Sigma|m\ll2^mH(\rho)$, about the coupling's length $L_\beta$, and `sec:imit` now states it (F1). The summary is exact up to the factor $H(\rho)$, and "close in behaviour" holds in absolute terms whenever $c\ell_0$ and $G/2^m$ are small. Left unchanged, to keep the edits minimal and the table row short (§8).
4. **"Cheap couplings defeat every $c$"** is shorthand for the inequality of `prop:imit:limits`(c), which compares the coupling's description with the person's. It is the same shorthand Paper 2 uses for cheap error rules. Left unchanged.
5. **`notes-final.md` §2.1, row "other classes".** It maps a sentence that is no longer in the draft; it was dropped when the section was shortened. The row is kept and marked (R2). The §2.5 list of cited labels named two labels the drafts do not cite (R4).
6. **Abstract length.** The abstract's source between the environment lines is 1920 characters (stripped), not 1921 (R8). Either way it is at the cap.
7. **Not re-proved here.** The decay record's proofs, which its referee re-derived, were checked against the drafts' statements only. Paper 2's lemmas used by citation were read for their hypotheses, not re-proved. No WebSearch was run: the citation check compares the drafts with the decay referee's verified list.

---

## 6. Edits made

### 6.1 Draft LaTeX (in `notes-final.md` and in `drafts/`)

Each edit was applied by a script that asserts exactly one occurrence per file. The same edit was made in the LaTeX block of `notes-final.md` and in the corresponding draft file or diff.

| id | file(s) | old | new | reason |
|---|---|---|---|---|
| F1 | `imit.tex` | "incompressible ($\delta_\beta\ll2^m$) … ($\ell_0+|\Sigma|m\ll2^m$), for every $c$ between … and about $1/\ell_0$ … close to the person in behaviour … above about $1/\ell_0$ the bound is vacuous and a simpler, worse program can win" | "($\delta_\beta\ll2^mH(\rho)$) … ($\ell_0+|\Sigma|m\ll2^mH(\rho)$, about the coupling's $L_\beta$ bits), … about $H(\rho)/\ell_0$ … close to the person in behaviour, on the scale $H(\rho)$, … above about $H(\rho)/\ell_0$ the bound exceeds $H(\rho)$, and above about $(\log|Y|-H(\rho))/\ell_0$ a simpler, worse program can win" | §1, informative range; the last threshold is the comparison with $\pi_{\rm u}$ of `prop:imit:limits`(c) |
| F2 | `imit.tex` | "its Hellinger gap ${\Hel}_{\bar\mu}(\pi)$" | "its Hellinger gap from the person, $\Ex_{x\sim\bar\mu}\Hel(\nu_H(\cdot\mid x),\nu_\pi(\cdot\mid x))$," | §1, Paper 2's ${\Hel}_\mu$ is relative to the data's sampler |
| F3 | `imit.tex` | "Then no hypothesis predicts better in population, and for product hypotheses that also see …, with i.i.d. pairs, Theorem A returns the person." | "For product hypotheses that also see …, with i.i.d. pairs, none then predicts better in population, and Theorem A returns the person." | robust Thm 2.2(2) |
| F4 | `imit.tex` | "In the feature case one such world" | "In the feature case with $|\Sigma|\ge2$, one such world" | robust Prop 4.10(a1) needs $\nu_H\ne P^*$ |
| F5 | `imit.tex` | "persons whose kernels agree $\bar\mu$-almost everywhere share a data law" | "persons with the same response function and coin law share a data law, however they compute them" | §1, counterexample with ties in ρ |
| F6a | `intro.diff` | "other hypotheses predict better, yet" | "other hypotheses can predict better, yet" | §4 |
| F6b | `intro.diff` | "no procedure copies a sampler entangled" | "no procedure reliably copies a sampler entangled" | probability bound $2^{-L_\beta}$ |
| F7 | `intro.diff` | "nor, by any procedure, when it is entangled" | "nor reliably by any procedure when it is entangled" | the same; one word longer, the row still fits (§8) |
| F8a | `intro.diff` | "a noisy random parity, for large $d$" | "a noisy random parity with a dyadic flip rate below $\frac14$, for large $d$" | `prop:parity:range`(iii) |
| F8b | `intro.diff` | "and a sampler whose coins are" | "and, up to near-copies, a sampler whose coins are" | `thm:imit:main` gives near-copies |
| F9 | `discussion.diff` | "no procedure copies a person entangled" | "no procedure reliably copies a person entangled" | as F6b |
| F10 | `discussion.diff` | "(6) The learners are not computable, the margin form … (\cref{prop:recovery:necessity}), and which program" | "(6) The steeper predictors are not computable, and whether the $\lambda$-MAPs are is open (\cref{prop:related:computability,q:related:open}); the margin form … (\cref{prop:recovery:necessity}); and which program" | §4 |
| F11a | `wd-remark.tex`, `teacher.diff` | "and $n$ times this is" | "and, for the log loss, $n$ times this is" | decay Prop 4.1(b) |
| F11b | `wd-remark.tex`, `teacher.diff` | "In the limit the minimiser of $L(\theta)+\frac\omega2\|\theta\|^2$ minimises the population loss $L$ only if" | "In the limit, for a differentiable population loss $L$, the minimiser of $L(\theta)+\frac\omega2\|\theta\|^2$ minimises $L$ only if" | decay Prop 4.2(i); the $|\theta-1|$ counterexample |
| F12 | `wd-appendix.tex`, `app-teacher.diff` | "independently, $q<\frac12$," | "independently, $0<q<\frac12$, $\varepsilon>0$," | decay Example 4.3 |

### 6.2 The rest of `notes-final.md`

| id | where | change |
|---|---|---|
| R1 | §0 item 1 | "about $1/\ell_0$" → "about $H(\rho)/\ell_0$" (as F1) |
| R2 | §2.1, row "other classes" | marked as not in the final draft |
| R3 | §2.1, row "behaviour, not mechanism" | restated as F5, with the cases in which equal kernels suffice |
| R4 | §2.5, list of cited labels | removed `prop:related:computable` and `def:setup:class`, which the drafts do not cite |
| R5 | §3.4, first sentence | "the drafts" → "the weight-decay drafts" |
| R6 | §3.4 | one paragraph on the three existing Paper 2 citations of the imitation drafts |
| R7 | §4.3, row (6) | as F10, with `q:related:open`(b) |
| R8 | §5.3 | abstract length 1921 → 1920 characters of source |
| R9 | header, "Repository" | one sentence on this check |

Also added:
* claims row S16, listing the six statements that were refuted as worded and fixed;
* "again after the final check" in row S15;
* a Verification log entry with the new SHA-256 prefixes of the edited draft files.

New SHA-256 prefixes:

| file | prefix |
|---|---|
| `app-teacher.diff` | `4ff0c664e7077d6a` |
| `discussion.diff` | `8f28565d663e2518` |
| `imit.tex` | `0ca8b079ac33cec7` |
| `intro.diff` | `7c784206e83d8292` |
| `teacher.diff` | `9fb939f0029c7fc6` |
| `wd-appendix.tex` | `26a8230041df0f4d` |
| `wd-remark.tex` | `e4cf399c9f491022` |

`app-imit.tex`, `imit.bib`, `main.diff` and `related.diff` are unchanged.

---

## 7. Scripts re-run

Both scripts were copied to fresh directories in the session scratchpad and run with `python3 -I` (Python 3.11.15, NumPy 2.4.6).

| script | SHA-256 prefix (unchanged) | time | stdout against the saved `.out` | stderr |
|---|---|---|---|---|
| `checks/s1_synthesis.py` | `9fb6b59bd0b8a802` | 30.0 s | byte-identical | empty |
| `robust/checks-final/f7_closeness.py` | `56c088f0c7c55ebf` | 9.9 s | byte-identical | empty |

The numbers the drafts quote were read off these outputs:
* s1(A): $6.1391\cdot10^{-4}$, $9.4208\cdot10^{-4}$, $1.2356\cdot10^{-2}$ against $H(\rho)=0.011174$, and $2^m>1.9998\cdot10^6$;
* s1(E): ω*, $0.102780$, $0.822237$, $c_+/2^{-m}=1.00447$–$1.01141$;
* f7(D): $8.924\cdot10^{-4}$ for the tighter intermediate form (synthesis §2.2 item 4).

---

## 8. Build

A fresh scratch copy of `paper-steeper/` was made (`main.tex`, `preamble.tex`, `sections/`, `bib/`, `build.sh`, `merge_bib.py`, `figures/`). The six edited diffs were applied with `patch -p1` (all clean, also as a dry run on a second fresh copy), and `imit.tex`, `app-imit.tex` and `imit.bib` were copied in. The copy was then built with its own `build.sh`.

* **Counts.** 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes over 10 pt, 84 pages.
* **Page positions (from `main.aux`), as in synthesis §5.1:**

  | item | page |
  |---|---|
  | `tab:intro:claims` | 5 |
  | `rem:teacher:weightdecay` | 26 |
  | `sec:limits` | 31 |
  | `sec:imit` | 33 (theorem p. 34, proposition p. 35) |
  | `sec:computable` | 36 |
  | `sec:discussion` | 37, its new paragraph p. 38 |
  | appendices | from p. 43 |
  | `app:teacher:weightdecay` | 71 |
  | `app:imit` | 80, with `app:related` from p. 83 |

  So the longer table row did not move the floats.
* **Blocks.** Every LaTeX block of `notes-final.md` is byte-identical to its draft file, or contained verbatim in the patched source.
* **Vocabulary.** The DECISIONS §A5 word grep on `pdftotext main.pdf` finds only the title footnote's "independent AI referees".

---

## Verification log

* **2026-10-14, reading.** As listed under "Sources read". Paper 2 statements were read at the labels listed; the hypotheses of `lem:kink:main`(i),(ii),(iv) were matched against the appendix proof of `thm:imit:main`.
* **Checks by hand.** Done for the following:
  * the three facts behind $B_\beta:=K(\beta\mid h_0,\mu)$;
  * the closeness lemma step by step;
  * the algebra of `thm:imit:main`(iv) and of the bound on Φ;
  * the right side $c\ell_0+\epsilon$ of (ii) from `lem:kink:main`(iv);
  * the memoriser's threshold;
  * `prop:imit:limits`(a)–(c), the no-window inequality and the cell count;
  * decay Props 2.2, 2.3, 3.2, 4.1, 4.2 and Example 4.3 against the drafts' wording;
  * $2p(1-p)$ as the best predictor's mean total variation (synthesis §1.3).

  The counterexamples behind F5 (the fair-coin person with $h$ and $1-h$) and F11b ($L=|\theta-1|$) were worked out by hand.
* **Citation check.** Every `\cite` in the eleven draft files was extracted by script and compared with the decay referee's §3.1–§3.2 (§3). The BibTeX entries were compared with `decay/refs.bib` and with `paper-steeper/bib/*.bib` by script.
* **Edits.** Made with two scripts in the session scratchpad that assert one occurrence per file. The pre-edit files were copied to the scratchpad first. `diff` against them shows exactly the edits of §6.
* **Scripts and build.** As in §7 and §8.
* **Not done.**
  * No WebSearch.
  * No adversarial referee of the closeness lemma beyond the line-by-line check above; synthesis §7 item 4 still applies.
  * No edit to the sub-track records (§5 items 1, 2) or to `paper-steeper/`.
