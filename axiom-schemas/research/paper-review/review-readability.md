# Review: readability, structure and length (sections 2–7)

Reviewer lens: a mathematically sophisticated reader who asked three questions (research/00-brief.md §1). Scope: `setting.tex`, `single.tex`, `universal.tex`, `zfc.tex`, `many.tex`, `experiments.tex`, plus the appendix files where material is to be moved. I did not review `intro.tex`, `discussion.tex` or `app-verification.tex`. I made no edits to paper files.

How I checked:
- I read all six main-text sections in full and the structure of every appendix.
- I measured each block with `research/paper-review/scratch/blocksize.py`, which counts non-comment source characters. The calibration is 215k characters for 51.3 pages, about 4,200 characters per printed page in the current build (pdftotext gives about 630 words per page).
- I found long sentences with `scratch/longsent.py`.
- I checked every claimed duplicate by reading both copies side by side, and every claimed undefined symbol by grepping all sections.
- I checked the two worked examples proposed below (I3, I4) by hand against the definitions of `def:single:features`, `cor:single:special` and `def:many:dtrc`.

Severity follows the brief:
- **major**: a misleading presentation, or a structural problem that blocks the 40-page target.
- **minor**: a local fix.

No item here is fatal. Correctness is the other reviews' lens.

---

## 0. Budget

The main text currently runs 51.3 pages: the TOC gives §2 at pp. 10–16 and §7 ending at p. 61. The target is about 40 pages, so about 11.3 pages must go. The plan below cuts about 12 pages and keeps every result statement as a one-line pointer. Optional extra cuts give about 1.3 more pages of margin.

| section | now (pp) | cut (pp) | after (pp) | main items |
|---|---|---|---|---|
| §2 Setting | 6.6 | −0.35 (net, incl. +0.4 for the glossary table F1) | 6.2 | C1, A7, F1 |
| §3 One schema | 9.4 | −3.0 | 6.4 | A1, A2, C2–C9, I3 |
| §4 Universal | 7.3 | −1.7 | 5.6 | B1, B3, C10–C13, D1 |
| §5 ZF(C) | 8.8 | −2.1 | 6.7 | A3, A4, C14–C18 |
| §6 Many | 10.3 | −2.3 (net, incl. +0.15 for I4) | 8.0 | A5, A6, C19–C24, G1 |
| §7 Experiments | 9.0 | −2.6 (net, incl. +0.3 for the E1 figure) | 6.4 | C25–C29, D1, E1 |
| **total** | **51.3** | **−12.0** | **≈39.3** | |

Optional extra cuts, worth about −1.3 pp:
- O1: move `tab:zf:classify` to the appendix, −0.35.
- O2: trim §6.10 MDL, −0.25.
- O3: move `prop:univ:capture`(a),(b), −0.15.
- O4: shorten E6/E7, −0.1.
- O5: global sweep of provenance sentences, −0.3.
- O6: trim the ZF paragraph of §6.11, −0.15.

The appendices grow by about 10 pages. About 2 pages of appendix duplication can be removed to offset this (item H1).

Section openings and endings:
- **§2**: opens with a contents sentence. That is fine for a setting section.
- **§3**: opens with a 93-word sentence; make it a list (I1). It ends with a summary and a table, but caveats and open problems trail after them (C9).
- **§4**: opens with a clear four-part answer. The answer is then restated three more times: `prop:univ:learner`, Table 4 and §4.8 (B3).
- **§5**: good opening and good summary table.
- **§6**: good bullet opening. The summary's first sentence states the answer, but it then refers to "the method first proposed", which is never introduced in the paper (G1).
- **§7**: has an "In brief" opening and ends with Limitations. That is acceptable.

---

## A. Definitions and recalls stated two or three times

**A1 (minor). `single.tex` §3.1, line 26.** The paragraph from "We recall the notation of \Cref{sec:setting}. Positions are ordered…" to "…$\beta^d_M:=\theta_d(M)$." restates §2 (positions, skeleton, plugging, $\gen$, the matching theorem), about 0.35 pp.

*Fix:* replace the whole paragraph with:

> Notation is that of \Cref{sec:setting}. In addition, $\singlebd(p)$ is the number of binders strictly above $p$ (so the bound variables in scope at $p$ are the indices $0,\dots,\singlebd(p)-1$), $|s|$ is the number of positions, and for a map $\bar u$ on free indices, $s[\bar u]$ substitutes $u_y$ for each free index $y$ of $s$. If $T$ covers $D$, $\theta_d$ is the unique matcher of $d\in D$ (\Cref{thm:setting:matching}) and $\beta^d_M:=\theta_d(M)$.

**A2 (minor). `single.tex` `lem:single:basic`, lines 39–50.** Three of its five parts are already stated elsewhere:
- (a) Preservation is `lem:setting:preservation`.
- (b) Substitution is `lem:setting:subst` (in `app-setting.tex`).
- (e) Equivalence is renaming is `lem:setting:renaming`.

Their proofs also appear twice: in `app-single.tex` B.1 and in `app:setting:lemmas` / `app:setting:renaming`.

*Fix:*
1. Keep only (c) Rigid prefix and (d) Forcing, renamed (a) and (b). Retitle the lemma "Rigid prefix; forcing".
2. After the lemma, add: "Preservation, the substitution facts and equivalence-as-renaming are \Cref{lem:setting:preservation,lem:setting:subst,lem:setting:renaming}."
3. In `app-single.tex` B.1, delete the proofs of the old (a), (b), (e).
4. Repoint every reference by this rule:
   - old (a) → `\Cref{lem:setting:preservation}`
   - old (b)(i/ii/iii) → `\Cref{lem:setting:subst}`(i/ii/iii)
   - old (c) → new (a)
   - old (d) → new (b)
   - old (e) → `\Cref{lem:setting:renaming}`
5. The references to repoint are at `single.tex` l.68 and `app-single.tex` ll.41, 43, 45, 47, 60, 66, 70, 77, 81, 85, 95, 125, 156, 160.

Saves about 0.17 pp in the main text and about 0.3 pp in the appendix.

**A3 (minor). `zfc.tex` "Conventions" paragraph, lines 35–45.** The block from "Data are instances in closure-normal form" to "…every such guard that all data satisfy \citep{claude2026whatfollows}." redefines four things already in §2: anchor in a class, the lgg facts, guarded schemas, and the most-specific-guard rule.

*Fix:* replace with:

> \paragraph{Conventions.} Data are instances in closure-normal form (\Cref{sec:setting:syntax}); anchors, first-order lggs, guards and the most-specific-guard rule are as in \Cref{sec:setting:fo,sec:setting:learning}. Since every first-order schema covering $P$ is at least as general as $\lgg(P)$, ``every covering schema has a false instance'' means ``$\lgg(P)$ has one''.

Saves about 0.22 pp.

**A4 (minor). `zfc.tex` `def:zf:enc`, lines 91–100.** This definition restates the encodings of §2.3 (`sec:setting:fo`).

*Fix:*
1. Delete the definition.
2. After `prop:zf:ground`, add: "Bound variables are encoded as in \Cref{sec:setting:fo}: named (N), de Bruijn first-order (dB), or by $\lambda$-templates. Named data use the textbook names of \Cref{tab:zf:forms} unless said otherwise; under \emph{$\alpha$-variation} the frame's binders get arbitrary distinct names."
3. In `setting.tex` line 88, change "in the \emph{de Bruijn} encoding (dB), bound variables are indices treated as constants, and only well-formed results count" to "…indices treated as constants; a metavariable at binder depth $d$ may take a formula with loose indices $<d$, and only well-formed results count."

Saves about 0.2 pp.

**A5 (minor). `many.tex` `def:many:setting` (lines 53–60) and the oracle paragraph (lines 63–70).** Two parts are already defined in §2:
- the refutation oracle with (OS) and (Dec) (`def:setting:oracle`);
- $\Acc_k(D,N)$ (`def:setting:protocol`).

The R-$\Delta_0$/R-HF/R-logic/R-coh paragraph repeats `setting.tex` line 172.

*Fix:*
1. In `def:many:setting`, replace "A \emph{refutation oracle} is a family … is an oracle." with "Refutation oracles are as in \cref{def:setting:oracle}."
2. Replace "For a finite set $N$ of negatives, $\manyVS_k(D,N):=…$ accepts $\Acc_k(D,N):=\bigcap\manyVS_k(D,N)$." with "$\manyVS_k(D,N)$ and the cautious $k$-union learner $\Acc_k(D,N)$ are as in \cref{def:setting:protocol}."
3. Delete lines 63–70 ("The oracles are the refutation channels…" to "…designated true sentences.").
4. Move its only new details into `setting.tex` line 172, after "evaluates within depth $d$": "(numerals and sentence size $\le d$; it verifies $\forall$, and refutes $\exists$, only by equality reasoning from the true closed equations of $\N$). All oracles are \emph{target-blind}: their answers are a fixed function of the query."

Net saving about 0.3 pp.

**A6 (minor). `many.tex` lines 79–82 and `lem:many:cautious`(a).**
- "A finite $A\subseteq\inst(\sigma)$ is an \emph{anchor}…" redefines the anchor from §2.
- `lem:many:cautious`(a) is `thm:setting:vs`(a) plus `lem:setting:onesided`(b).

*Fix:*
1. Replace lines 79–82 with "Anchors are as in \cref{def:setting:protocol}; \cref{sec:single} characterizes them by witness events, and a ground $\sigma$ has the anchor $\{\sigma\}$."
2. Reduce `lem:many:cautious` to its part (b).
3. Before it, write "(Soundness for $k\ge k'$ and sound $N$, and monotonicity, are \cref{thm:setting:vs} and \cref{lem:setting:onesided}(b).)"
4. Merge `prop:single:union-verifier` into it (see C7).

Saves about 0.1 pp.

**A7 (minor). The instance schema is defined three times:**
- `setting.tex` lines 199–200 ("\paragraph{Universal axioms.} …capture instances $\Cap(\varphi)$ \src{…}");
- `universal.tex` `def:univ:target`;
- `universal.tex` line 37, the sentence "Under the $\lambda$ convention, the default, … capture instances (\cref{sec:univ:capture})".

*Fix:*
1. Replace `setting.tex` lines 199–200 with: "\paragraph{Universal axioms.} The instance schema $\sigma_\varphi$ of $\forall\bar x\varphi$, with its closed and open instances, is defined in \cref{def:univ:target}."
2. Keep the definition in §4.
3. In `universal.tex` line 37, keep the sentence, since it is the only copy once §2's is gone.

Saves about 0.13 pp.

**A8 (minor). `universal.tex` line 46.** The text "We use the classical facts recalled in \cref{sec:setting} … $\Hk1(\FO)$ denotes…" re-proves nothing and repeats `lem:setting:recover`.

*Fix:* replace with "We use \cref{lem:setting:recover}; every first-order schema covering $D$ is $\gen\lgg(D)$. $\Hk1(\FO)$ denotes the single first-order schemas of the syntax at hand ($\lambda$, N or dB)."

**A9 (minor). One failure-probability formula is printed four times.** $\sum_fp_f^N+(1-q)^N-\sum_fr_f^N$ appears at:
- `single.tex` line 178;
- `thm:zf:rates`;
- `prop:zf:sub`;
- `thm:many:dtrc`(iv), at `many.tex` lines 224–226.

*Fix:*
1. Keep it in `thm:zf:rates`, the general form.
2. In `single.tex` line 178, replace "for induction this is the earlier exact rate $\sum_fp_f^N+(1-q)^N-\sum_fr_f^N$ up to its inclusion--exclusion term" with "its exact inclusion–exclusion form is \Cref{thm:zf:rates}".
3. In `thm:many:dtrc`(iv), replace the parenthesis "(For $T_{\Ind}$ with $n$ induction data … see \cref{sec:zf}.)" with "(for $T_{\Ind}$ and the ZF schemas see \cref{thm:zf:rates})".

---

## B. Results stated twice

**B1 (major). `universal.tex` §4.7 (`sec:univ:merge`, lines 200–213) restates `many.tex` §6.6.**
- `prop:univ:merge`(a)–(e) is the same statement as `prop:many:forall`(a)–(e), with `lem:many:twopoint` covering (a).
- The "Computed (untagged u6)" paragraph is repeated at `many.tex` lines 318–321.
- `lem:univ:qf` (`app-universal.tex` C.6) is `prop:many:qf`, and `many.tex` lines 330–335 prove it a second time.
- §4.7 also has to preview \DTRC{} (line 202) before §6 defines it.

*Fix:*
1. Replace `universal.tex` lines 202–213, from "In the untagged setting of \cref{sec:many}, unlabelled data…" to "…not a derivation.", with:

   > In the untagged setting of \cref{sec:many}, each closed instance $\varphi(t)$ can be read as its own ground target, and learning $\forall x\varphi$ then means merging instances across ``targets''. \Cref{prop:many:forall} shows that \DTRC{} does this soundly. If $\forall x\varphi$ is true, any closed instances, two with different heads, form one cluster whose only minimal template is $\sigma_\varphi$, and \DTRC{} accepts $\varphi(a)$, i.e.\ $\forall x\varphi$ (\cref{prop:univ:gen}). If $\forall x\varphi$ is false and an instance of $\sigma_\varphi$ is refuted, the merge is refused. With R-$\Delta_0$, ``never refuted'' means ``true'' for quantifier-free $\varphi$ (\cref{prop:many:qf}); an oracle that only evaluates closed instances certifies truth at every closed term, which in $\N$ is the $\omega$-rule and in $\R$ leaves the false $\forall x\,\neg(x\cdot x=1+1)$ unrefuted (\cref{ex:univ:fail}).

2. Move into `prop:many:forall`(e) the clause that `prop:many:forall` lacks: "(R-$\Delta_0$ verifies universals only by equational derivations from true closed equations; a decision procedure for RCF would refute the $\R$ example)".
3. Delete `app-universal.tex` C.6 (lines 131–153). Move the proof of `prop:many:qf` from `many.tex` lines 330–335 to `app-many.tex` `app:many:dtrc`.
4. Editor: `intro.tex` l.173 cites `prop:univ:merge`. Replace that citation with `prop:many:forall`.

Saves about 0.65 pp in the main text and about 0.5 pp in the appendix.

**B2 (minor). The SO° counterexample appears twice.** `universal.tex` `prop:univ:dt`(c) (data $0+0=0$, $S0+0=S0$; template $f(S0)+f(0)=f(S0)$) repeats `setting.tex` `ex:setting:classes`(4).

*Fix:* replace (c) with "\item In $\SO$ this fails (\cref{ex:setting:classes}(4)): a metavariable without a pattern occurrence can use different arguments on different data." Delete "(c) A body with $\beta[0]=0$ is $h$ or $0$…" from the proof idea.

**B3 (major). The answer to Question 1 is stated four times in §4:**
1. the opening list (lines 20–25);
2. Table 4 (`tab:univ:learner`);
3. `prop:univ:learner`, a corollary that only collects earlier propositions;
4. §4.8 Summary (lines 216–218).

*Fix:*
1. Keep the opening list, Table 4 and `prop:univ:learner`.
2. Replace §4.8 (line 218) with:

   > \emph{Answer to the first question.} The instance schema $\varphi(z)$ is learned, by first-order anti-unification and by the $\DT$ learner alike, from two instances with different roots (plus \evD\ for several variables), at exact rates. The axiom $\forall\bar x\varphi$ follows from all closed instances only by an $\omega$-step, which is truth-safe iff $M_0\preceq M$ and is not derivable in general; a cautious learner takes it silently when parameters are admissible, a closedness guard prevents it, and data at parameters make it ordinary generalization (\cref{tab:univ:learner}). In a first-order syntax, capture makes the unguarded learner unsound outright; a learned $\mathrm{nocap}$ guard repairs it. Without labels, $\forall x\varphi$ is a sound merge (\cref{sec:many:forall}). Open problems: \cref{sec:disc:open}.

**B4 (minor). The "four minimal templates" correction appears three times:**
- `ex:single:c82` (`single.tex` 73–79);
- `zfc.tex` lines 427–429 ("Before an anchor the $\DT$ verifier is sound, but … corrects prior C8.2");
- the row in `tab:single:summary`.

*Fix:*
1. Move the environment `ex:single:c82` to `app:single:min`, merged with the existing paragraph "\Cref{ex:single:c82} in detail".
2. In `single.tex`, after `thm:single:min`, add one line: "Before an anchor $\Min(D)$ need not have a least element: $\{\Ind(x=x),\Ind(0=x)\}$ has exactly four minimal covering templates, one of them below $T_{\Ind}$ (\cref{ex:single:c82})."
3. Delete `zfc.tex` lines 427–429.

**B5 (minor). Experiments are reported twice.**
- E1 appears at `universal.tex` line 101 and `experiments.tex` line 155.
- E2 appears at `zfc.tex` lines 472–478 ("\paragraph{Experiment.}…") and `experiments.tex` §7.3 with Table 9.

*Fix:*
1. E1: see D1.
2. E2: replace `zfc.tex` lines 472–478 with "\paragraph{Experiment.} The implemented $\DTF$ learner was exact from $2$–$3$ tagged instances in most runs on all three ZF schemas and on induction and accepted no non-instance in $927$ probes; the pattern $\lgg$ was never exact on induction, and first-order lggs were unsound except on $\EInd$ in de Bruijn form, as \cref{tab:zf:classify} predicts (\cref{tab:exp:e2})."

**B6 (minor). Open problems at section ends repeat `sec:disc:open` (O1–O18).** The repeats are:
- `single.tex` line 298 ("\paragraph{Open problems.} …"). This copy also carries the wrong bound "templates of size $\le11$" (correct: $7\le s\le11$).
- `many.tex` lines 528–531 ("Open: spare-slot thresholds … bootstrapped coherence.").
- `universal.tex` line 218, last sentence.
- `experiments.tex` §7.4 items (1), (3), (8) (the parts phrased as open questions).

*Fix:*
1. Replace each with "Open problems: \cref{sec:disc:open}."
2. In §7.4 keep the limitation statements and delete their "…is open" clauses.

Saves about 0.4 pp.

---

## C. Moves to the appendix: secondary results, long examples, computational detail

Each move keeps the environment and its label, so all `\cref`s still resolve. The main text gets the pointer sentence given.

### §2 `setting.tex`

**C1 (minor). Two side paragraphs.**
- Line 119, the paragraph "Part (a) is the special case of Miller's pattern unification … proved in the prior session." Move it to the end of `app:setting:matching`.
- Line 161, the sentences "Identification in the limit is due to \citet{gold1967language} … applied to sentences." These are literature notes inside the protocol section. Move them to `sec:disc:lit`, paragraph "learning from positive data" (editor: discussion is in flux).
- Also in line 161, write $\DT_s$ instead of $\mathrm{DT}_s$, and point the C6.2 example to `\cref{prop:zf:indgen}` rather than repeating the record tag.

Saves about 0.2 pp.

### §3 `single.tex`

**C2 (minor). Evidence paragraphs** are moved verbatim to `app:single:computations`, which currently lacks these numbers:
- line 103: from "\emph{Evidence.} $\Min(D)$ from saturated templates…" to "…(\Cref{app:single:computations}).";
- line 140: from "\emph{Evidence:} \Cref{thm:single:anchor} agreed…" to the end. Keep "\Cref{sec:zf} treats the ZF schemas in all formulations, encodings and classes.";
- line 153: the first sentence, "On random data … needs special structure.";
- line 267: the last two sentences, "The referee's brute force agreed … Proofs in \Cref{app:single:complexity}."

Main text: add one sentence to the section intro (line 21): "Every result below was also checked by computation, most by an independent implementation (\Cref{app:single:computations})." Saves about 0.3 pp.

**C3 (major). `prop:single:weaker` with line 153** ("Weaker events do not suffice", plus "\Rich\ cannot be dropped") goes to `app:single:anchor`, which already holds its verification. Keep its part (a) as the intuition for (U) (see I3). Pointer after `cor:single:special`:

> The events cannot be weakened: \evR+\evN+\evD, and \evU\ checked only at pattern occurrences, both admit non-anchors, even for one metavariable; and \Rich\ cannot be dropped (\cref{prop:single:weaker}). The exact anchor condition without \Rich\ is open.

Saves about 0.4 pp.

**C4 (minor). `prop:single:kappa` and the numeric paragraph at line 184** go to `app:single:rates`. The numbers at line 184 (0.057714, 0.059942…) are already in `app-single.tex` "Two worked laws", so delete that paragraph rather than move it. Pointer, replacing "The coincidence terms need not be tight:" and everything through line 184:

> The coincidence terms need not be tight: their exact rate is $\chi_{\sigma,r}$, which can be smaller than $\sqrt{1-\kappa_{\sigma,r}}$ (\cref{prop:single:kappa}).

Saves about 0.33 pp.

**C5 (major). Escalations, §3.6 (lines 187–223).**

*Keep:*
- the definition of $\singleEsc$ (line 189), with the fix of J1;
- `thm:single:esc` with a one-line proof idea: "Each escalation shrinks the common prefix, enlarges a scope, or removes an equation for good (\Cref{app:single:esc}).".

*Move to `app:single:esc`:*
- the $\Pi(D)$ paragraph (line 191);
- the long proof idea;
- the lower-bound chain sentence (line 205);
- `prop:single:quadratic` and the C11 paragraph (line 213);
- `prop:single:binderfree`;
- `conj:single:kill`;
- the evidence paragraph (line 223).

*Pointer after the theorem:*

> The bound is tight: $\singleEsc(\DT;N)=\Theta(N^2)$, by an explicit chain of scope-growing data that also lies in $\inst(T_{\Ind})$ (\cref{prop:single:quadratic}). This refutes the earlier conjecture that escalations are linear in the size of the first escalated datum. Without binders at most $2N$ escalations occur (\cref{prop:single:binderfree}); whether equation kills alone are linear is open (\cref{conj:single:kill}).

Saves about 0.65 pp.

**C6 (minor). §3.7, finite elasticity and unions (lines 226–248).**

*Keep:*
- the definition of finite elasticity;
- `cor:single:unions`(i),(ii).

*Move to `app:single:unions`:*
- `cor:single:unions`(iii);
- `prop:single:untagged-anchor` with the paragraph at line 242;
- the computed sentence at line 248.

*Pointer:*

> Explicit anchors for unions, in terms of the failure sets of the three events, are \cref{prop:single:untagged-anchor}; the union verifier and its complexity are in \cref{sec:many}.

Saves about 0.5 pp.

**C7 (minor). `prop:single:union-verifier` (lines 244–246) is `lem:many:cautious`(b) with $N=\emptyset$.**

*Fix:*
1. Delete it from §3.
2. In `lem:many:cautious`(b), add "In particular, with $N=\emptyset$: $q\in\Acc_k(D)$ iff every partition of $D$ into at most $k$ nonempty blocks has a block $B$ with $q\in\Acc(B)$."
3. Keep the label `prop:single:union-verifier` as a second `\label` inside `lem:many:cautious` so that `tab:single:summary` and the appendix still resolve.

**C8 (minor). `prop:single:lgg` (lines 259–261)** is a technical criterion (a graph on slots with sources). Move it to `app:single:complexity` and keep `cor:single:anchor-lgg` in the main text. Replace line 267 with:

> So $\Min(D)$ cannot be listed in polynomial time and the verifier must not enumerate it; but whether $D$ has a least covering template is decidable, and the lgg computable, in polynomial time (\cref{prop:single:lgg}), and an anchor always has one. This extends the earlier result ``$T_{\Ind}$ is the lgg of every induction anchor'' to all of $\DT$.

Saves about 0.2 pp.

**C9 (minor). §3.9 Caveats (line 296).**
- Caveat (2) duplicates `setting.tex` line 57.
- Caveat (3) duplicates `sec:setting:params`.
- Caveat (4) duplicates `prop:single:untagged-anchor`.
- Caveat (5) is listed in `app:ver` G.3.

*Fix:* delete the Caveats paragraph. Append to the caption of `tab:single:summary`: "The `only if' half of \Cref{thm:single:anchor} needs \Rich, which always holds with parameters." For Open problems see B6. Saves about 0.25 pp.

### §4 `universal.tex`

**C10 (minor). "Corner cases" and "Evidence", lines 68–69.** Replace with:

> \emph{Corner cases.} Several variables need \evD: on diagonal data $\varphi(t,t)$ the lgg for $x+y=y+x$ is the sound specialization $z+z=z+z$. One datum is never an anchor; two with componentwise different roots and pairwise distinct components are. From numerals (roots $0$ and $S$ only) every anchor of $z+0=z$ contains $0+0=0$, which is also an instance of $0+z=z$; this slows the rates and matters for unlabelled mixtures (\cref{sec:many}). Further corner cases and the computational checks are in \cref{app:univ:anchor,app:univ:comp}.

Move the rest verbatim. Saves about 0.18 pp.

**C11 (minor). The paragraph after `prop:univ:dt`, line 86** ("Part (c) has analogues with binders … the statement is proved."), goes to `app:univ:anchor`. Keep only: "For one variable, (a) is the two-point lemma used in \cref{sec:many}." Saves about 0.18 pp.

**C12 (minor). `thm:univ:rates`(b) and the Galton–Watson paragraph (lines 95, 99).**
- Move (b), the exact $k=2$ formula, to `app:univ:rates`. Replace it in the theorem with "\textup{(b)} For $k=2$ an exact inclusion–exclusion formula holds (\cref{app:univ:rates}).".
- Replace line 99 with: "The proof is inclusion--exclusion and a union bound (\cref{app:univ:rates}). For a Galton--Watson term law the exact failure probability drops below $0.01$ at $N=6$, while bound (c) needs $N=11$ ($k=1$) and $13$ ($k=2$)."

Saves about 0.18 pp.

**C13 (minor). Computed paragraphs at lines 114 and 129** go to `app:univ:capture` / `app:univ:comp`.
- At line 114, keep: "Proof in \cref{app:univ:capture}; the key point of (b) is that every class member containing $\instc(\varphi)$ contains two closed instances forming an anchor. The class $\DT$ has no guards, so the $\DT$ learner on closed data takes the $\omega$-step after the first anchor whenever parameters are admissible."
- At line 129, keep: "Under the $\lambda$ convention $\Cap(\varphi)$ does not arise; the de Bruijn \emph{first-order} encoding does not prevent capture ($\exists\neg(\#0=z)$ with $z:=\#0$). Computed checks: \cref{app:univ:comp}."

Optional O3: also move `prop:univ:capture`(a),(b) and keep (c)–(e). Saves about 0.2 pp (O3 adds about 0.15).

### §5 `zfc.tex`

**C14 (major). "Several metavariables": the paragraph at lines 269–278, `thm:zf:multi` with its proof idea, and the $T_A$/$T_B$ examples at lines 292–297.** This is not needed for ZF, which has one metavariable. It was added in revision and not independently refereed. Move all of it to `app:zf:anchor`, where `lem:zf:facing` and the proof already are. Pointer:

> \paragraph{Several metavariables.} ZF needs one metavariable. With several, as in the untagged mixtures of \cref{sec:many}, a Plotkin-(D)-type event appears, and it differs between $\PAT$, $\DT$ and $\SO$: an anchor in a smaller class need not be one in a larger class (\cref{thm:zf:multi}).

`cor:zf:patlgg` keeps its reference to `thm:zf:multi`. Saves about 0.45 pp.

**C15 (minor). Proof ideas in §5.5** go to `app:zf:pa`, which already has full proofs:
- `thm:zf:indunion`: move lines 358–362. Keep line 363 shortened to: "The occurrence and freshness guards learnable from $F'$ do not help; a guard ``is an induction instance'' would, which is what the Sub encoding below implements."
- `thm:zf:K0`: lines 373–377.
- `thm:zf:indanchor`: lines 398–404.
- `prop:zf:indeq`: lines 459–464.

Shorten `thm:zf:anchor`'s proof idea (lines 254–261) to:

> \emph{Intuition.} \evR{} pins the rigid part of every covering template to a prefix of the frame, and \zfN{i} lets every variable bound above an occurrence be recovered as a hole of the body; so a covering template, with a suitable body for each metavariable, gives back $T^*$. ``Only if'': a root-specialized or argument-dropping pattern covers non-anchor data (\Cref{app:zf:anchor}).

Saves about 0.45 pp.

**C16 (minor). `prop:zf:indgen` (lines 407–419)** goes to `app:zf:pa`. Pointer, replacing lines 407–419 and keeping the label:

> Up to renaming exactly $26$ templates of $\DT$ contain $\inst(T_{\Ind})$; on every anchor they are exactly the covering templates, so $\lgg_{\DT}(D)=T_{\Ind}$, and $T_{\mathrm{pat}}$ is the least of them without non-pattern occurrences. In the size-bounded classes $\DT_s$, $T_{\Ind}$ is closed iff $s\ge12$; for $7\le s\le11$ the verifier accepts a false sentence on every anchor (\cref{prop:zf:indgen}).

Also move line 405 ("Here $|T|$ counts symbols…") to just before `thm:zf:indanchor`, which uses $\DT_s$ first. Prefix it with "For the size-bounded classes $\DT_s$ (templates of size $\le s$),". Saves about 0.2 pp.

**C17 (minor). `prop:zf:sub` with its proof and line 448 (lines 433–448)** go to `app:zf:pa`. Pointer:

> Recording each step with the decidable judgment $\mathrm{Sub}(\varphi,x,t,\psi)$ (``$\psi=\varphi[t/x]$'') makes induction a first-order pattern whose lgg recovers it under the same events \evR+\evN\ (\cref{prop:zf:sub}); so the second-order learner on raw sentences loses nothing against a first-order learner on Sub-annotated data.

Saves about 0.25 pp.

**C18 (minor). Lean/Metamath, lines 465–470.** Replace with:

> So the obstruction in \Cref{thm:zf:indunion} is the meta-level substitution in $\varphi(0)$ and $\varphi(Sx)$, not induction. Proof assistants record or recompute the motive (Lean, Metamath: \Cref{app:zf:pa}); in $\DT$ the motive is the unique matcher of $T_{\Ind}$.

Saves about 0.1 pp.

### §6 `many.tex`

**C19 (major). `thm:many:slots`, `cor:many:paslots` and lines 150–151, i.e. lines 127–151** ("In general a target's slots may be shared…" to "…not independent evidence (as the referee noted)."), go to `app:many:bound`, where their proofs are. Pointer:

> When targets share slots, a slot-accounting refinement gives exact thresholds (\cref{thm:many:slots}). For $\Q$ plus induction at $k=8$, positive data leave induction four slots, so an induction instance on an unseen main connective (with $x$ free) is accepted iff the induction data cannot be split into four blocks each root-homogeneous or all-vacuous; three sound negatives leave it one slot and restore the tagged anchor condition \evR+\evN\ (\cref{cor:many:paslots}).

This also removes the main-text instance of the Q-numbering clash flagged by other reviewers. Saves about 0.4 pp.

**C20 (minor). `rem:many:numerals` (lines 153–166)** goes to `app:many:bound`. Pointer:

> Spare slots cost diversity even for $\forall x\varphi$: numeral-only data never make the cautious $k$-union learner accept $\forall x\varphi$ with one spare slot, because $\{\varphi(0)\}\cup\inst(\varphi(Su))$ is a sound split (\cref{rem:many:numerals}); beyond one-variable schemas the threshold is open.

Saves about 0.27 pp.

**C21 (minor). `thm:many:depth`, proof idea (lines 356–364)** goes to `app:many:dtrc`. Replace it with:

> \emph{Idea:} via MRDP, whether a two-instance merge of a true-looking arithmetic schema is ever refuted encodes the halting problem, so ``this merge is never refuted'' is $\Pi_1$-complete (\cref{app:many:dtrc}).

Also move the inline definition of $\Res_\infty(\mathcal P)$ out of the 101-word statement into a sentence before the theorem (see I2). Saves about 0.2 pp.

**C22 (major). §6.8, whole-cluster tests and noise (lines 372–404).**
- Move to `app:many:dtrc`, which has their proofs: `prop:many:linkage` with its example (lines 382–384), `prop:many:noise`, and the robust-\DTRC{} paragraph (lines 397–404).
- Replace the body of §6.8 (keep the heading and label) with:

  > Coherence is downward closed but not transitive, so \DTRC{} must test whole clusters: single linkage on the pairwise-coherence graph can build clusters with no unrefuted minimal template, although under $\RS_d(D)$ single linkage, complete linkage and \DTRC{} agree (\cref{prop:many:linkage}). Mistakes $E$ ($E\cap\manyRstar=\emptyset$) behave as follows (\cref{prop:many:noise}): a refutable mistake stays an incoherent singleton; under separation of the clean data, mistakes never bridge targets; an unrefutable mistake can be absorbed into a target's cluster, making it unsound, or fragment it. \emph{Robust} \DTRC{} asserts only clusters of multiplicity $\ge s>e$ and verifies them with a trimmed verifier that tolerates $e$ mistakes. Suppose the clean data are separated, every mistake is refutable or noise-separated, and every coherent set of mistakes has multiplicity $<s$. Then the asserted clusters are exactly the $D_i$ of multiplicity $\ge s$; they are verified soundly, and exactly once every subset of $D_i$ of size $\ge|D_i|-e$ contains an anchor. A frequent coherent family of mistakes is a systematic error that no positive-data method can tell from a rule (computed PA example: \cref{ex:many:noise}).

Saves about 0.5 pp.

**C23 (minor). §6.11, natural examples (lines 451–515).**
- Lines 451–455 (the audit story): replace with "The computations use the untagged track's prototype; each run is audited so that it \emph{is} $\DTRC_d$ with a fixed finite oracle (\cref{prop:many:audit}), and every run passed."
- Lines 457–479: delete the referee-count clauses "(computed; the referee's independent enumeration of all 68 …)" at line 191 and "(…the referee's independent enumeration of 598 covering templates agrees)" at line 472. Their place is `app:many:examples`.
- K0 paragraph (lines 504–510, "\emph{$K_0$}: the first-order lgg…" to "…refutes it."): shorten to "\emph{$K_0$} (\cref{thm:zf:K0}) has no instance refuted by R-$\Delta_0$ or logic. In $\DT$ its data have, besides the $K_0$-shaped template, a $T_{\Ind}$-specialization, and the verifier intersects both, so the false $J^*_0$ is rejected; the $K_0$-shaped template harms only when a mistake removes the sound alternative (\cref{ex:many:noise})."

Saves about 0.3 pp.

**C24 (minor). Provenance sentences, `many.tex` lines 17–21.** The block from "The results come from the research record…" to "…so we state the results without it." is process detail. Delete it; the `\src` tags carry the provenance. Do the same for:
- `single.tex` line 21, its first sentence;
- `universal.tex` line 26, its first sentence;
- `experiments.tex` line 14: "An adversarial referee re-ran … listed in \cref{app:ver}" becomes "An adversarial referee re-ran every experiment with independent checks; the corrections that followed are listed in \cref{app:ver}."

Saves about 0.2 pp.

### §7 `experiments.tex`

**C25 (major). Normal form, lines 26–44** (from "\paragraph{Minimal covering templates.}" to "…had a rigid parameter (\cref{app:exp:normal}).").
- Move `def:exp:normal` with the preceding definition of $C(D)$, F-slots and columns, `prop:exp:normal` with its proof idea, and the alignment paragraph to `app:exp:normal`. This also removes the undefined $\mathcal T(D)$ from the main text (J5).
- Replace them with:

  > \paragraph{Minimal covering templates.} The learner computes $\Min_F(D)$, the minimal covering templates in $\DTF$ up to parameter renaming, from the finitely many \emph{normal configurations} of the data's common-prefix tree (\cref{def:exp:normal,prop:exp:normal}): every covering template of $\DTF$ lies above one, and for a parameter-free target one lies below the target. Parameters are aligned as in \cref{app:setting:align}. The aligned and literal sets differed on none of the $720$ data sets of E2 and in one call of all \DTRC{} runs of E3.

Saves about 0.75 pp.

**C26 (minor). Oracles, lines 53–57.**
- Move the proof idea of `prop:exp:oracle` to `app:exp:oracle`.
- Keep the incompleteness sentences ("Neither oracle is complete: …").
- Move the parenthetical in line 22, "(With leading quantifiers stripped, … \src{referee R13}.)", to `app:exp:numbers`.

Saves about 0.37 pp.

**C27 (major). §7.2, guarantees (lines 73–149).**

*Keep in the main text:*
- `thm:exp:dtrc`, with hypotheses renamed (E1 below) and no proof idea;
- `prop:exp:mixsep` with `tab:exp:cases`;
- `cor:exp:mixsep`.

*Move to `app:exp:dtrc`, with their proofs:*
- `prop:exp:mono`;
- `prop:exp:budget` and the paragraph after it (line 102);
- `prop:exp:share`;
- `prop:exp:numerals` and line 114;
- the proof ideas of `prop:exp:mixsep` and `cor:exp:mixsep`;
- the sentence at line 92, "The first record claimed exactness \emph{exactly}…" (`app:ver` row 22 already has it). Keep "The implemented refuter violates (H-ref)".

*New text before `thm:exp:dtrc`:*

> The theorems of \cref{sec:many} carry over to $\DTF$, $\Min_F$ and the budgeted, history-dependent refuter (proofs in \cref{app:exp:dtrc}). Within-target merges always succeed, and per-cluster soundness does not depend on the budget, because a pure cluster always intersects a never-refuted template below its target (\cref{prop:exp:mono,prop:exp:budget}). So a budgeted refuter harms \DTRC{} only through clustering.

*New text after it:*

> With overlapping instance sets the per-cluster statement is the right one. Under hypotheses (H4$^+$) and (H5), the sharing pass gives each target's cluster every datum that instantiates it; it is target-sound, exact with an anchor, and, if verdicts do not depend on the call history, it matches the tagged learner with membership labels (\cref{prop:exp:share}). In the numerals regime every anchor of $U_{\mathrm{add0}}$ or $U_{\mathrm{0add}}$ contains $0+0=0$ (\cref{prop:exp:numerals}, Plotkin's \evR{} for $\DTF$), so a partition gives this datum to at most one of them, the sharing pass to both.

Saves about 1.1 pp.

**C28 (minor). E9, hard pairs (lines 239–248).** Move `prop:exp:hard` with its proof idea and the constant-propagation paragraph (line 248) to `app:exp:stress`. Pointer:

> Two hard ZF pairs mark the limits (\cref{prop:exp:hard}). $\mathrm{Union}_W$ and $\mathrm{Power}_W$ have the universal-set schema of \cref{sec:many} as their unique minimal covering template; the ZF oracle refutes it, but no oracle sound for $\HF$ plus a universal element does. A merge of $\in$-induction with $\in$-induction along $z\in y\in x$ is typically false but was refuted only at budget $400$, and only with constant propagation; other merges of that pair are valid, so (H4) fails for these pairs in general.

Saves about 0.4 pp.

**C29 (minor). `lem:exp:valid` and its proof (lines 269–275)** go to `app:exp:stress`. Line 267 ends "…the remaining residual merges are valid (\cref{lem:exp:valid})."

In line 267, also delete "The first record's claim that PA mistakes merge only into valid templates is withdrawn; the referee found this exhibit." (`app:ver` row 19 has it). Change "the first record's oracle returns unknown, the revised one False" to "an earlier version of the oracle returned unknown, the current one False".

In line 204, delete "The first record's headline $54/55$ and $45/45$ counted ground axioms ($35$ and $30$ of them) \src{referee F4}." (`app:ver` row 21). In line 179, replace "The first record's claim … is withdrawn \src{referee F6}." with "(The formula-level variant is the baseline of an earlier version; \cref{app:ver}, row 20.)"

Saves about 0.35 pp.

---

## D. Dangling cross-reference

**D1 (major). The E1 figure is promised but never shown.**
- `universal.tex` line 101 says "The experiments section (\cref{sec:exp}) plots the curves."
- `experiments.tex` line 155 says "Details and curves are in \cref{sec:univ}."
- Neither section includes a figure, and `figures/e1_anchor_cdf.png` is never used. (The consistency review, M1, found the same.)

I viewed the figure. It is the single most direct picture of the Question 1 answer: observed versus predicted $\Pr[\text{exact after }N]$, mixed versus numerals.

*Fix:*
1. In `experiments.tex` line 155, replace "Details and curves are in \cref{sec:univ}" with "\Cref{fig:exp:e1} compares observed and predicted curves; for $x+y=y+x$ the means are $4.18$ and $11.85$. On $0+0=0$, $1+0=1$ the learned $z+0=z$ accepts $w_0+0=w_0$, the axiom in parameter form, but not the different datum $\forall x\,(x+0=x)$."
2. Add after that paragraph:

   ```latex
   \begin{figure}[t]\centering
   \includegraphics[width=0.6\textwidth]{figures/e1_anchor_cdf.png}
   \caption{E1: probability that the learner is exact after $N$ instances of $x+0=x$, observed
   ($2000$ runs) and predicted by \cref{thm:univ:rates}(a), for mixed terms and for numerals only
   \src{experiments E1}.}\label{fig:exp:e1}
   \end{figure}
   ```

3. Replace `universal.tex` line 101 with: "\emph{Experiment E1} (\cref{sec:exp:results}, \cref{fig:exp:e1}) confirms (a): the implemented $\DTF$ verifier and the first-order $\lgg$ became exact at the same $N$ in every run, at the predicted mean ($3.27$ observed against $3.25$ predicted with mixed terms; $8.42$ against $8.11$ with numerals only, one correlated sample)."

Net effect: about +0.1 pp.

---

## E. Names that collide

**E1 (major). The hypotheses of `thm:exp:dtrc` and `prop:exp:share` are printed exactly like the witness events.**
- `\evR` and `\evD` typeset as "(R)" and "(D)".
- `thm:exp:dtrc` names its hypotheses "(T) targets…; (D) data…; (R) a sound refuter; (S)…".
- `prop:exp:share` adds "(S$^+$)" and "(P)".

A reader of §7 meets "(R)" and "(D)" with a second meaning in the same paper. (Similarly, `single.tex` uses "(S1), (S2)" for saturation.)

*Fix:*
1. Rename as follows: (T)→(H1), (D)→(H2), (R)→(H3), (S)→(H4), (S$^+$)→(H4$^+$), (P)→(H5). Keep (H-ref).
2. The occurrences are at `experiments.tex` ll.85, 89, 105, 142, 248, 282 (Limitations (3), (7)) and in `app-experiments.tex` §F.3, ll.88–112.

**E2 (minor). Two more collisions.**
- "(N)" names the named encoding (`setting.tex` l.88; `universal.tex` throughout, e.g. "Work in syntax (N) or (dB)") and also the non-vacuity event `\evN`. §4 uses both near \evR{} and \evD{}.
- Experiments call the three questions "Q1, Q2, Q3" (`experiments.tex` ll.16, 154, 157, 181), which also name Robinson's axioms (consistency review M4).

*Fix:*
1. Write the named encoding as "(Nm)" everywhere. The literal "(N)" occurs at `setting.tex` ll.88, 200 and `universal.tex` ll.37, 110, 116, 119, 122, 172, 173, 181, 184; "N or dB" without parentheses occurs at `universal.tex` l.46.
2. Replace "(Q1)/(Q2)/(Q3)" and "on Q1 and Q2" with "(Question 1)" etc., as in the intro.

---

## F. A table that would help: glossary of named conditions

**F1 (major).** The main text uses more than 25 parenthesized condition names, defined in six places. Among them:
- events: (R), (R$^*$), (N), (N$_i$), (D), (D$_{ii'}$), (U), (D$^+$), (D$^{\rm PAT}$), (D$^{\rm DT}$), (D$^{\rm root}$), (B);
- richness and saturation: (Rich), (Rich$_{\rm c}$), (S1), (S2);
- oracles: (OS), (Dec);
- untagged learning: (X), (Abs), cross-separation, anchor-pair separation, $\RS_d(D)$, global separation, noise-separation;
- experiments: (H1)–(H5) after E1, (H-ref).

Several are closely related, for example the four separation notions. A reader of §6 who has forgotten whether (X) or $\RS_d$ is the stronger has no single place to look.

*Fix:* add, at the end of §2 (about +0.4 pp, already in the budget) or as Table A.1 in `app:setting` with a pointer from §2:

| name | meaning (one line) | defined in |
|---|---|---|
| (R) | the values of each metavariable do not all have the same root symbol | `lem:setting:recover`; §5 for bodies |
| (R$^*$) | root variation at every occurrence, derived ones included | `def:single:events` |
| (N), (N$_i$) | every argument place (place $i$) is used by some value | `def:single:events`; §5 |
| (D), (D$_{ii'}$) | distinct 0-ary metavariables differ in some datum (Plotkin) | `lem:setting:recover`; `def:univ:target` |
| (U) | no equation between a slot and another position holds in all data unless the target imposes it | `def:single:events` |
| (D$^+$), (D$^{\rm PAT}$), (D$^{\rm DT}$), (D$^{\rm root}$) | (U) specialized to formula metavariables / several metavariables, per class | `cor:single:special`(b); `thm:zf:multi` |
| (B) | some motive has an unshielded free $x$ (anchors in $\SO$) | `prop:zf:indso` |
| (Rich) | a relation symbol; two root symbols for closed terms (term metavariables) | `def:single:events` |
| (Rich$_{\rm c}$) | arbitrarily many pairwise distinct closed terms with pairwise different roots | §4.1 |
| (S1), (S2) | saturation: argument places used; roots not all equal | §3.2 |
| (OS), (Dec) | oracle one-sided sound; refutation decidable | `def:setting:oracle` |
| cross-separation of $D$ by $N$ | every template covering data of two targets meets $N$ | `thm:many:splits` |
| (X) | same, for anchor data only | `thm:many:pigeonhole` |
| anchor-pair separation | every minimal template of every cross pair of anchor data is $d$-refuted | §6.3 |
| $\RS_d(D)$; global separation | every template covering data (resp.\ instances) of two targets is $d$-refuted | `def:many:dtrc` |
| (Abs) | every $N$-avoiding template covering data of target $i$ and of another contains $\inst(\sigma_i)$ | `thm:many:slots` |
| noise-separated | every template covering the mistake and a clean datum is refuted | `prop:many:noise` |
| (H1)–(H5), (H-ref) | hypotheses of the implemented-learner theorems (§7) | `thm:exp:dtrc`, `prop:exp:share` |

---

## G. §6 summary and a results table

**G1 (minor).** `many.tex` §6.12 (lines 520–531) refers to "the method first proposed", which the paper never introduces; it is the brief's §5 (also consistency m19). The 124-word list of amendments and opens follows the opening answer.

*Fix:* replace §6.12 with the paragraph below and the table after it (net about +0.05 pp):

> \DTRC{} answers the third question (\cref{tab:many:summary}). Under refutation separation it recovers the hidden labels without being told their number, is target-sound at all times, and is exact once every target's data contain an anchor, with the failure probability of the tagged learner (\cref{thm:many:dtrc}); PA, ZF and ZFC are separated at small depth (\cref{sec:many:examples}). Without separation it is truth-sound when every residual merge is sound, and otherwise sound only relative to a residue, which no computable learner can avoid in general (\cref{thm:many:residue,thm:many:depth}). The results force four design choices: test whole clusters and intersect all unrefuted minimal templates (coherence is not transitive, and a $K_0$-shaped template can sit next to the sound one); keep the refutation depth as a parameter and re-cluster as it grows; when a bound $k\ge k'$ is known, intersect with the $k$-union learner fed with \DTRC's own negatives, which restores target-soundness without separation and, at $k=k'$ under separation, loses no exactness once anchors are present; and implement refutation as a growing set of refuted sentences, audited after each run (\cref{prop:many:audit}). Open problems: \cref{sec:disc:open}.

`tab:many:summary`:

| learner and evidence | assumption | guarantee | result |
|---|---|---|---|
| cautious union, positive data, no bound | — | accepts only the data | `prop:many:bound` |
| cautious $k$-union, $k\ge k'$, sound negatives | — | target-sound; sound splits never excluded | `thm:many:splits`(a) |
| same, cross-separating negatives | disjoint instance sets | exact for target $i$ iff no $m=k-k'+1$ templates cover $D_i$ and miss an instance | `thm:many:splits`(b) |
| $k'$-union with self-generated negatives $N(D,d)$ | anchor-pair separation, $k=k'$ | sound always; exact once anchors present | `thm:many:pigeonhole` |
| \DTRC$_d$ | $\RS_d(D)$ | labels recovered; target-sound; exact from anchors; tagged rates (global separation) | `thm:many:dtrc` |
| \DTRC$_d$ | none | sound relative to $\Res_d(D)$; truth-sound if residual merges are sound; fragmentation possible | `thm:many:residue`, `prop:many:ambiguity` |
| any computable learner | — | cannot be both residue-sound and eventually exact on all separated practices | `thm:many:depth` |
| \DTRC{} $\cap$ $k$-union learner | bound $k\ge k'$ known | target-sound always; exact under $\RS_d$, $k=k'$, anchors | `rem:many:combine` |
| robust \DTRC | $\le e$ mistakes per cluster, mistakes refutable or noise-separated | sound; exact if every $(\lvert D_i\rvert-e)$-subset has an anchor | `prop:many:noise` |

---

## H. Appendix duplication, to offset the moves

**H1 (minor).**
1. `app-single.tex` B.1: the proofs of `lem:single:basic` (a), (b), (e) duplicate `app:setting:lemmas` and `app:setting:renaming` (see A2).
2. `app-universal.tex` C.6, lines 131–153, duplicates the `app-many.tex` proofs of `lem:many:twopoint`, `prop:many:forall` and `prop:many:qf` (see B1).
3. `app-many.tex` lines 438–447, "\paragraph{Features (recalled from \cref{sec:single})}…", restates `def:single:features` and forcing. Replace with "Common prefix, slots, scopes, forcing and features are as in \cref{def:single:features,lem:single:basic}; $\Acc(B)=\Feat(B)$ (\cref{thm:single:feat})." Keep the coNP remark.

Together these save about 1.5 appendix pages.

---

## I. Long sentences and missing examples

**I1 (minor). `single.tex` line 19.** The single 93-word sentence "We show that the version space is finitary … in \Cref{sec:many}." should become a list:

```latex
The questions are about completeness and cost. We show:
\begin{itemize}
\item the version space is finitary, and some minimal covering template lies below the target (\Cref{sec:single:min});
\item $\Acc(D)$ is a polynomial-time test of ``features'' of the data (\Cref{sec:single:feat});
\item $D$ is an anchor iff three witness events hold; for first-order targets they are Plotkin's, for PA induction and every ZF schema root variation plus non-vacuity (\Cref{sec:single:anchor});
\item exponential rates for random and tagged data (\Cref{sec:single:rates});
\item a tight quadratic escalation bound, refuting an earlier linear conjecture (\Cref{sec:single:esc});
\item finite elasticity, so unions have anchors (\Cref{sec:single:unions}), and the complexity of the version space (\Cref{sec:single:complexity}).
\end{itemize}
The union verifier and the refutation test of \DTRC\ are in \Cref{sec:many}.
```

**I2 (minor). Four more long sentences.**
- `many.tex` `def:many:dtrc` step list (80 words, l.201–206) and `experiments.tex` l.62, "\DTRC{} as implemented: (1)~… (5)~…" (92 words): typeset both as `enumerate` lists, steps (1)–(4) and (1)–(5).
- `thm:many:depth` (101 words): before the theorem, define "For a practice $\mathcal P$ let $\Res_\infty(\mathcal P)$ be the union of the instance sets of templates that cover instances (in the support of the data law) of two different targets of $\mathcal P$ and have no refutable instance." In (a), replace the inline definition with $\Res_\infty(\mathcal P)$.
- `cor:single:special`(c) (72 words): replace with:

  > \item \emph{PA induction and ZF.} In closure-normal form, $T_{\Ind}$ is anchored iff the motives' main symbols are not all equal and some motive has $x$ free (the earlier anchor theorem for induction); each ZF schema of \Cref{tab:zf:forms} iff the bodies' main symbols are not all equal and every argument place of $P$ is used by some body (freshness is built in). Single axioms are ground templates. One datum is never an anchor of a schema; two can be.

  This also removes the undefined (N$_x$), (N$_a$) (J2), and the second variable naming of Separation and Replacement (consistency m9).

**I3 (minor). §3 defines features and (U) abstractly with no example.** A reader needs one small computation to see what a feature or a coincidence is. I checked both examples below by hand.
1. After `thm:single:feat`, add:

   > \begin{example}[Features]\label{ex:single:features}\status{proved} For $D=\{0+0=0,\ S0+0=S0\}$ the common prefix is $\cdot+0=\cdot$, with two slots: the left summand $\sigma$ and the right-hand side $r$. The $D$-features are Sym at the three common positions and $\singleEq(\sigma,r,\emptyset)$ with its converse: in both data the right-hand side equals the left summand. So $T_0(D)=z_1+0=z_2$, $T_\varphi=z_1+0=z_1$ for the Eq feature, and $\Feat(D)=\Acc(D)=\inst(z+0=z)$: $D$ is an anchor. \end{example}

2. After the definition of (U) in `def:single:events`, add:

   > For example, $T^*=\forall x(0=f(x))$ with data $\forall x(0=0)$, $\forall x(0=x)$ satisfies \evRs\ and \evN, but in both data the content at the rigid $0$ is the content at the slot of $f(x)$ under $x\mapsto0$, a coincidence at a non-valid pair; indeed $\forall x(f(0)=f(x))$ covers $D$ and misses $\forall x(0=Sx)$.

   This is `prop:single:weaker`(a), kept in the main text when C3 moves the proposition.

**I4 (minor). §6 defines \DTRC{} without a run.** After `thm:many:dtrc`, add (about +0.15 pp):

> \begin{example}[A small run]\label{ex:many:run}\status{proved} Let the practice be $\{z+0=z,\ T_{\Ind}\}$ and $D=\{0+0=0,\ S0+0=S0,\ \Ind(x+0=x),\ \Ind(\neg x=0)\}$. A set containing an equation and an induction instance has a single minimal covering template, the $0$-ary formula metavariable $F_0$ (the roots $=$ and $\to$ differ), and $F_0$ is refuted by $0=S0$. The two equations have the single minimal template $z+0=z$, and the two inductions have $T_{\Ind}$ (both pairs are anchors, \cref{cor:single:special,cor:single:anchor-lgg}); all their instances are true, so they are never refuted. So $\RS_d(D)$ holds once $d$ reaches $0=S0$, and by \cref{thm:many:dtrc} \DTRC{} returns the two pure clusters under every merge policy and accepts $\inst(z+0=z)\cup\inst(T_{\Ind})$. \end{example}

I verified each step: the roots differ, so the root is the only slot and no binder is in scope, which forces $F_0$. $\{0+0=0,S0+0=S0\}$ satisfies \evR{} for one variable. The motives have roots $=$ and $\neg$, and $x$ is free in $x+0=x$.

**I5 (minor). `setting.tex` `ex:setting:classes`(4) says "These two data anchor $z+0=z$ in $\DT$", but anchors are defined only in §2.5.** Add "(anchors: \cref{def:setting:protocol})".

---

## J. Undefined or ambiguous symbols

**J1 (minor).** `single.tex` l.189: "$\singleEsc(H_1;N)\le N+1$" uses $H_1$, which is never defined; the paper's notation is $\Hk1(\mathcal C)$. Replace with $\singleEsc(\Hk1(\FO);N)$.

**J2 (minor).** `single.tex` `cor:single:special`(c) uses "\evN$_x$, \evN$_a$, \evN$_y$" before §5 defines them. Fixed by I2.

**J3 (minor).** `many.tex` l.190 uses $F_0$ and $F_0\to F_1$ undefined in the main text. The same holds at l.143 (moved by C19). Write "($F_0$ and $F_0\to F_1$, with $0$-ary formula metavariables $F_0,F_1$; $z_0=z_1$; $p+z_0=z_1$; $p\cdot z_0=z_1$)".

**J4 (minor).** `many.tex` l.463, "every template covering a $\Q$-axiom and an induction instance is absorbing and refuted": "absorbing" is defined nowhere in the main text. Replace with "contains all of $\inst(T_{\Ind})$ and is refuted".

**J5 (minor).** `experiments.tex` l.27 uses "In $\mathcal T(D)$…" without defining $\mathcal T(D)$ (consistency M10). It moves to the appendix with C25; there, add "Let $\mathcal T(D)$ be $C(D)$ with each common atom node … cut to a leaf slot (an F-slot)".

**J6 (minor).** `zfc.tex`: $|T|$ is defined at l.405, after `thm:zf:indanchor` (l.394) already uses $\DT_s$. Fixed by C16.

**J7 (minor).** `universal.tex` ll.39–41. Delete "; the record calls this (H)", which is internal provenance. Add "(Rich$_{\mathrm c}$) concerns closed terms only and differs from \Rich{} of \cref{sec:single}." The two names are otherwise easily confused.

**J8 (minor).** `single.tex` ll.71, 213, 280, 286 use the internal codes "C8.3" and "C11". Write "the earlier finiteness conjecture" and "the earlier linear-escalation conjecture", and keep the codes only in `\src` tags.

**J9 (minor).** `setting.tex` l.88, "(its lem:setting:guard)", prints a label of another document as text. Replace with "(the most-specific-guard rule of the parent report)".

---

## K. Notation before Theorem 3.11 (rates)

**K1 (minor).** `single.tex` l.158 defines $\rho_\sigma$, $\nu_{M,m}$, $A_{\sigma,r,\bar u}$, $\kappa_{\sigma,r}$, $\chi_{\sigma,r}$, $U(T^*)$, $c(T^*)$, $\lambda$ and $\bar c$ in one paragraph, without words. After it, add:

> In words: $\rho_\sigma$ is the probability that the root at occurrence $\sigma$ differs from its most likely value; $\nu_{M,m}$ the probability that a body of $M$ uses hole $m$; $\kappa_{\sigma,r}$ the probability that two independent draws admit no common map $\bar u$ making the content at $r$ a copy of the content at $\sigma$; and $\chi_{\sigma,r}$ the largest probability of a single such coincidence. $\lambda$ is the smallest of the first three kinds.

---

## L. Experiments: order and figure labels

**L1 (minor).** `experiments.tex` §7.3 presents E1, E2, E3, E5, E6/E7, E9, E4, while E0, E0b, E8 and E10 appear only in text or `\src` tags. A reader expects E4 before E5. Use content headings without E-numbers ("Universal axioms", "Single schemas", "Untagged mixtures", "Learning curves", "The $k$-union verifier; why $\DTF$", "Separation evidence", "Stress tests"), and keep the record numbers only in `\src` tags.

**L2 (minor).** `figures/e5_curves.png`: the middle panel is titled "PA, v1 instance distribution" and the left one "…(main)". The caption says "middle: PA, mixed regime", and "v1" is internal jargon. In `code/experiments/e5_curves.py` l.25, set TITLES to 'PA, numerals only' and 'PA, mixed regime', then regenerate the figure.

---

## M. Order of §2

**M1 (minor).** §2.3, "First-order encodings, capture and guards", sits between the class definitions and matching/protocol. Only §4 and §5 use it, and the reader must cross it to reach the cautious verifier and anchors, the core of every later section.

*Fix:*
1. Move `\subsection{First-order encodings…}` (lines 86–96, with `lem:setting:recover`) to after §2.6 "Refutation oracles", unchanged.
2. Optionally end §2 with three lines: "The rest of the paper uses three facts: the cautious verifier is sound iff the target is closed in the class (\cref{lem:setting:closed}), exact iff the data contain an anchor, and refutation is one-sided (\cref{lem:setting:onesided})."

---

## Optional extra cuts (margin, about −1.3 pp)

- **O1.** `zfc.tex` `tab:zf:classify` overlaps the first three columns of `tab:zf:summary`. Move it to `app:zf:enc` and add guard names to the "g" cells' caption of `tab:zf:summary`. The intro's `\cref`s still resolve.
- **O2.** `many.tex` §6.10 MDL (lines 433–446): keep the first two and the bold sentence; move the rest to `app:many:mdl`.
- **O3.** `prop:univ:capture`(a),(b) to `app:univ:capture` (see C13).
- **O4.** `experiments.tex` E6/E7 paragraph (l.217): one sentence each.
- **O5.** A global sweep of "the referee's independent … agreed" clauses (50 occurrences of "referee" in the main text) into `\src` tags and the appendices.
- **O6.** `many.tex` ZF/ZFC paragraph (ll.466–479): move per-seed counts to `ex:many:zf`.
