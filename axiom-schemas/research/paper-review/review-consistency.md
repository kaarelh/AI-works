# Review: cross-section consistency and fidelity of presentation

Lens: consistency across `setting`, `single`, `universal`, `zfc`, `many`, `experiments` and their appendices
(intro, discussion and app-verification not reviewed). Every item was checked against the sources: the
section files, `NOTATION.md`, `writer-notes.txt`, the research records (`research/tracks/*/notes-final.md`,
`referee.md`, `research/prior/`), `code/results/*.md` and the code (`code/dtrc/datasets.py`). The build is
clean (0 undefined references), so all problems below are textual. Helper script:
`research/paper-review/scratch/check_status.py` (lists every theorem-like environment with its `\status`
and `\src`).

Severity: **fatal** = false statement / invalid proof; **major** = overclaim, missing hypothesis, misleading
presentation, wrong number; **minor** = local fix.

No fatal issues found. 10 major, 22 minor.

---------------------------------------------------------------------------------------------------------

## MAJOR

### M1. The E1 figure is in neither section; the two sections point at each other
* Files: `experiments.tex` (E1 paragraph, "Details and curves are in \cref{sec:univ}"),
  `universal.tex` (E1 paragraph, "The experiments section (\cref{sec:exp}) plots the curves.").
* Problem: `grep includegraphics` finds only `figures/e5_curves.png`. `figures/e1_anchor_cdf.png` is
  included nowhere. Each writer assumed the other kept it (writer-notes: univ "removed ... sec:exp should
  include"; exp "already in universal.tex (fig:univ:e1)"; `fig:univ:e1` does not exist). The reader is sent
  in a circle. The figure is informative (observed vs predicted $1-\sum_h p_h^N$, two regimes; the numerals
  curve visibly sits slightly below prediction, which is the 8.42 vs 8.11 discussed in the text).
* Fix: in `experiments.tex`, directly after the E1 paragraph, insert
  ```latex
  \begin{figure}[t]
  \centering
  \includegraphics[width=0.62\textwidth]{figures/e1_anchor_cdf.png}
  \caption{E1: probability that the $\DTF$ learner is exact after $N$ instances of $x+0=x$, observed in
  $2000$ runs (circles) against the prediction $1-\sum_hp_h^N$ of \cref{thm:univ:rates}(a) and
  \cref{prop:exp:numerals} (lines), for the mixed and the numerals-only regime \src{experiments E1}.}
  \label{fig:exp:e1}
  \end{figure}
  ```
  replace "Details and curves are in \cref{sec:univ}" by "\Cref{fig:exp:e1} shows the curves, and
  \cref{sec:univ:rates} discusses the numbers"; in `universal.tex` replace "The experiments section
  (\cref{sec:exp}) plots the curves." by "\Cref{fig:exp:e1} plots the curves."

### M2. Q-axiom numbering in §6 and its appendix follows the untagged record, not §2
* Files/locations: `many.tex` `cor:many:paslots` (list "($\neg Sp=0$; $Sp=Sp'\to p=p'$; $p+0=p$; ...;
  $\neg p=0\to\exists y\,p=Sy$)", "$F_0\to F_1$ for Q2 and Q7", "Q3--Q6 share $z_0=z_1$; Q1, Q2, Q7 stay
  alone"); `many.tex` after `prop:many:qf`-block, "numeral instances of Q3--Q5"; `app-many.tex` proof of
  `cor:many:paslots` ("Q2 and Q7 have root $\to$", "two of Q1, Q2, Q7, or one of them and one of Q3--Q6",
  "for Q2--Q7", "Q1, Q2 and Q7 need a slot each and Q3--Q6", "Q3 and Q4 have the lgg $p+z_0=z_1$",
  "Q5 and Q6 have $p\cdot z_0=z_1$", "the other pairs among Q3--Q6", "Q3--Q6 need a slot each",
  "$\{$Q1, Q2, Q7, $z_0=z_1\}$"); `app-many.tex` `tab:many:pacross` rows.
* Problem: §2 (`sec:setting:examples`) fixes Q1 $\neg Sx=0$, Q2 injectivity, Q3 $\neg x=0\to\exists y\,x=Sy$,
  Q4 $x+0=x$, Q5 $x+Sy=S(x+y)$, Q6 $x\cdot0=0$, Q7 $x\cdot Sy=x\cdot y+x$; §4, §7 and app-universal use it
  (e.g. "Q4, then Q5", "lumps Q4 and Q6"). §6 silently re-numbers (its list puts the predecessor axiom
  last). Read with §2's numbering, `cor:many:paslots` is false ("$F_0\to F_1$ for Q2 and Q7": Q7 has root
  $=$; "Q1, Q2, Q7 stay alone": Q7 shares $z_0=z_1$), and "numeral instances of Q3--Q5" names the wrong
  axioms (the templates listed are those of Q4, Q6, Q5).
* Fix (all in §2's numbering):
  - `cor:many:paslots`: list as "($\neg Sp=0$; $Sp=Sp'\to p=p'$; $\neg p=0\to\exists y\,p=Sy$; $p+0=p$;
    $p+Sp'=S(p+p')$; $p\cdot0=0$; $p\cdot Sp'=p\cdot p'+p$)", and write "for Q2 and Q3", "(Q4--Q7 share
    $z_0=z_1$; Q1, Q2, Q3 stay alone)". Add "(numbered as in \cref{sec:setting:examples})" after "Q1--Q7".
  - "numeral instances of Q3--Q5" → "numeral instances of Q4--Q6".
  - app-many proof: "Q2 and Q7" → "Q2 and Q3"; "two of Q1, Q2, Q7, or one of them and one of Q3--Q6" → "two
    of Q1, Q2, Q3, or one of them and one of Q4--Q7"; "for Q2--Q7" → "for Q2 and Q3"; "Q1, Q2 and Q7 need a
    slot each and Q3--Q6 at least one; $z_0=z_1$ covers Q3--Q6" → "Q1, Q2 and Q3 need a slot each and Q4--Q7
    at least one; $z_0=z_1$ covers Q4--Q7"; "Q3 and Q4 have the lgg" → "Q4 and Q5 have the lgg"; "Q5 and Q6
    have" → "Q6 and Q7 have"; "the other pairs among Q3--Q6" → "among Q4--Q7"; "so Q3--Q6 need a slot each"
    → "so Q4--Q7 need a slot each"; "$\{$Q1, Q2, Q7, $z_0=z_1\}$" → "$\{$Q1, Q2, Q3, $z_0=z_1\}$".
  - `tab:many:pacross`: "(Q1--Q3 etc.)" → "(Q1--Q4 etc.)"; "Q2--Q7, Q2--Ind, Q7--Ind" → "Q2--Q3, Q2--Ind,
    Q3--Ind"; "Q3--Q5, Q3--Q6, Q4--Q5, Q4--Q6" → "Q4--Q6, Q4--Q7, Q5--Q6, Q5--Q7"; "Q3--Q4" → "Q4--Q5";
    "Q5--Q6" → "Q6--Q7".

### M3. "The descent through Q3" (K0 paragraph, app-many) names the wrong axiom in every numbering
* File: `app-many.tex`, paragraph "$K_0$.", last sentence: "(a derivation found in the prior work: the
  descent through Q3 is unblocked once Q3 is designated)".
* Problem: the phrase is copied from `prior/induction/raw-impossibility-notes.md` B5(d), where
  "Q3 = AxAy(x+Sy = S(x+y))" (a third numbering). In §2's numbering Q3 is the predecessor axiom, in §6's own
  list Q3 is $p+0=p$; designating either does not unblock the refutation. `zfc.tex` (after
  `thm:zf:K0`) states it correctly with the formula.
* Fix: replace by "(the refutation through the recursion axiom Q5, $\forall x\forall y\,(x+Sy=S(x+y))$,
  goes through once Q5 is designated; see the remark after \cref{thm:zf:K0})".

### M4. Experiments call the three questions "Q1, Q2, Q3", colliding with the axioms Q1--Q7
* File: `experiments.tex`: "In brief: on Q1 and Q2 the implemented learner behaves as the theory predicts,
  and on Q2 it accepted no non-instance in $927$ probes"; headings "E1: universal axioms (Q1)", "E2: each
  schema from tagged instances (Q2)", "E3: \DTRC{} on untagged mixtures (Q3)".
* Problem: the intro fixes "Questions 1--3 (not to be confused with the axioms Q1--Q7)". The same section
  uses "Q4", "Q6" for axioms two paragraphs later ("the axiom Q4 is the datum $\forall x(x+0=x)$", "lumps Q4
  and Q6"), so "on Q2 it accepted no non-instance" reads as a statement about the injectivity axiom.
* Fix: "on Questions 1 and 2 the implemented learner behaves as the theory predicts, and on Question 2 it
  accepted ..."; headings "(Question 1)", "(Question 2)", "(Question 3)".

### M5. `\ReplS` in the experiments denotes a different schema than in §5
* Files: `experiments.tex` (PA/ZF data sets: "$10$ of Replacement $\ReplS$ ($\exists!$ spelled out, image
  consequent)"; `prop:exp:mixsep` target list; `tab:exp:cases`; `tab:exp:e2` row "$\ReplS$");
  `app-experiments.tex` ("$\ReplS=\forall x(\forall y(y\in x\to\exists z(P(y,z,x)\wedge\forall u(P(y,u,x)\to
  u=z)))\to\exists y\forall z(z\in y\leftrightarrow\exists u(u\in x\wedge P(u,z,x))))$").
* Problem: NOTATION and `tab:zf:forms` define $\ReplS$ as Kunen-style with the Collection-shaped consequent
  $\exists Y\forall x(x\in A\to\exists y(y\in Y\wedge P))$. The implemented schema has Jech's image
  consequent, i.e. it is neither $\ReplS$ nor $\ReplJ$ (`zfc.tex` says so explicitly: "Replacement
  ($\exists!$ spelled out, image consequent)"). With the shared macro the paper contradicts itself:
  `prop:zf:coll` says the named first-order lgg of $\ReplS$ is truth-sound and never refuted, while E2 says
  "First-order $\lgg$s were unsound on ... Replacement ... in both encodings" for the row labelled $\ReplS$.
* Fix: give the implemented schema its own name, e.g. $\mathrm{Repl}_{\mathrm{E}}$ (local macro
  `\expReplE`), defined at its first use: "$10$ of Replacement $\mathrm{Repl}_{\mathrm{E}}$ ($\exists!$ spelled
  out as in $\ReplS$, with the image consequent of $\ReplJ$; neither formulation of \cref{tab:zf:forms})", and
  replace $\ReplS$ by $\mathrm{Repl}_{\mathrm{E}}$ throughout `experiments.tex` and `app-experiments.tex`.
  After "First-order $\lgg$s were unsound on Separation ..., Replacement and induction in both encodings" add
  "(for $\ReplS$ itself the named first-order lgg is truth-sound, \cref{prop:zf:coll}; it is the image
  consequent that yields false instances, as remarked after \cref{prop:zf:coll})". In `many.tex`
  (`sec:many:examples`, "Replacement with $\exists!$ spelled out") add "and image consequent".

### M6. §2 says the implementation is read as a fixed finite oracle; §7 says it is not
* Files: `setting.tex` `def:setting:oracle`: "A fixed finite set of false sentences, used at every $d$, is an
  oracle; this is how the implementation is read (\cref{sec:exp})." vs `experiments.tex` (Template
  refuter): "It is sound, budgeted, and history-dependent ..., so it is not a fixed oracle $\Ref_d$
  (\cref{sec:setting}); the guarantees below are stated for it directly."
* Problem: direct contradiction. The fixed-oracle reading is the *audit* of the untagged prototype
  (`prop:many:audit`), not the package of §7.
* Fix: in `setting.tex` replace "this is how the implementation is read (\cref{sec:exp})" by "this is how
  the audited prototype of \cref{sec:many:examples} is read (\cref{prop:many:audit}); the budgeted,
  history-dependent refuter of \cref{sec:exp} is treated directly there".

### M7. "not in ... a nonstandard model of $\PA$" contradicts `prop:univ:tv`
* File: `universal.tex`, opening list item (2): "...is truth-safe for all $\varphi$ in $M$ iff the
  closed-term substructure of $M$ is elementary (\cref{prop:univ:tv}): in $\N$, not in $\R$, $V$ or a
  nonstandard model of $\PA$."
* Problem: `prop:univ:tv` (same section) proves that (i) holds "for every model of true arithmetic", and
  such models can be nonstandard. The counterexample `ex:univ:fail`(c) is specifically a model of
  $\PA+\neg\Con(\PA)$. (The overstatement is inherited from cases notes-final, line 49/423, which contradict
  its own line 369.)
* Fix: "...: in $\N$ and in every model of true arithmetic, but not in $\R$, in $V$, or in a model of
  $\PA+\neg\Con(\PA)$."

### M8. `\Min_F` (experiments) is the *aligned* set, `\Min_{\DTF}` (setting) the *literal* one
* Files: `experiments.tex` ("the learner uses $\Min_F(D)$, the minimal elements of the union of
  $\Min^{\mathrm{lit}}_F(\alpha(D))$ over all alignments"), used throughout §7 and app-experiments;
  `app-setting.tex` (`app:setting:align`, `ex:setting:align`: "Literally, $\Min_{\DTF}(D)=\{\dots\}$",
  $\Min^{\mathrm{al}}_{\mathcal C}$ for the aligned set); `setting.tex` `sec:setting:params` ("they use
  $\Min^{\mathrm{al}}$ throughout (\cref{sec:exp})").
* Problem: the same object is $\Min^{\mathrm{al}}_{\DTF}$ in §2/App. A and $\Min_F$ in §7, while
  $\Min_{\DTF}$ in App. A means the literal set (§7's $\Min^{\mathrm{lit}}_F$). NOTATION prescribes
  $\Min^{\mathrm{al}}$. §2 tells the reader §7 uses $\Min^{\mathrm{al}}$, which never appears there.
* Fix: in `experiments.tex` at the definition write "the learner uses
  $\Min_F(D):=\Min^{\mathrm{al}}_{\DTF}(D)$ of \cref{app:setting:align}, the minimal elements of the union of
  $\Min^{\mathrm{lit}}_F(\alpha(D))=\Min_{\DTF}(\alpha(D))$ over all alignments $\alpha$". (Or globally
  replace $\Min_F$ by $\Min^{\mathrm{al}}_F$ in `experiments.tex`/`app-experiments.tex`.)

### M9. The same results are stated and proved twice in §4 and §6, with differing wording
* Files: `universal.tex` `prop:univ:merge` (+ "Computed" paragraph), `app-universal.tex`
  `app:univ:merge`, `lem:univ:qf`, `lem:univ:identity`; `many.tex` `prop:many:forall` (+ "Computed"
  paragraph), `lem:many:twopoint`, `prop:many:qf`; `app-many.tex` proofs of `lem:many:twopoint`,
  `prop:many:forall`.
* Problem: `prop:univ:merge` = `prop:many:forall` (both untagged Prop 5.6); `lem:univ:qf` = `prop:many:qf`
  (untagged Prop 5.13); `lem:many:twopoint` is the one-metavariable case of `prop:univ:dt`(a), and both
  appendices prove the identity lemma. The copies agree in substance but not exactly: hypotheses are phrased
  differently ("$\varphi$ have one variable" vs "$z$ a term metavariable"); the real-field example uses
  $\R$ with $0,1,+,-,\cdot,<$ where closed terms denote integers (`ex:univ:fail`(a)) in §4, but "$\R$ with
  $0,1,+,\cdot$, where closed terms denote natural numbers" in §6; §4 says "Soundness for the $n$ ground
  targets fails", §6 "Target-soundness ... fails"; the two "Computed" paragraphs repeat the same u6 numbers.
  About 1.5 pages of duplication.
* Fix: keep the statements in §6 (where \DTRC{} is defined) and make §4 point to them:
  - In `universal.tex` replace `prop:univ:merge` and the paragraph after it by: "Regard each instance
    $\varphi(t_j)$ as its own ground target; learning $\forall x\varphi$ then means merging them. By
    \cref{prop:univ:dt}(a), instances of a one-variable $\varphi$ with two different heads have the single
    minimal template $\sigma_\varphi$, so \DTRC{} merges them iff $\sigma_\varphi$ is unrefuted, and the merged
    cluster accepts $\varphi(a)$, i.e.\ $\forall x\varphi$. The merge is truth-sound iff $\forall x\varphi$ is
    true, and R-$\Delta_0$ refutes every false quantifier-free one (\cref{prop:many:forall,prop:many:qf})."
  - Move the (more detailed) proof of `lem:univ:qf` into `app-many.tex` as the proof of `prop:many:qf`,
    delete `app:univ:merge`, and re-point `intro.tex` (line 173, `prop:univ:merge`) and
    `app-verification.tex` (line 241, `lem:univ:qf`) to `prop:many:forall` / `prop:many:qf`.
  - In `many.tex`, replace the proof idea of `lem:many:twopoint` by "This is the one-metavariable case of
    \cref{prop:univ:dt}(a), proved in \cref{app:univ:anchor}; in \cref{thm:single:anchor} it is the case in
    which \evU{} holds automatically." and delete its proof in `app-many.tex`.
  - In `prop:many:forall`(e) use the signature of `ex:univ:fail`(a): "in $\R$ as an ordered field
    (\cref{ex:univ:fail}(a)), $\neg(z\cdot z=1+1)$ is an unsound unrefuted merge".

### M10. `\mathcal T(D)` is never defined, and `C(D)` means different things in §3 and §7
* File: `experiments.tex` (Minimal covering templates): "Let $C(D)$ be the \emph{common-prefix tree} ...:
  the positions $p$ such that all data carry the same label ... at $p$ and above it ..., and the
  \emph{slots}, the maximal positions at which they disagree. ... In $\mathcal T(D)$, each common atom node
  ... is cut to a leaf slot (an \emph{F-slot})". `def:exp:normal`, `prop:exp:normal`, `lem:exp:heads` and
  their proofs all work in $\mathcal T(D)$.
* Problem: $\mathcal T(D)$ is used but never introduced (the central object of the normal form). Also
  §7's $C(D)$ includes the slots, while `def:single:features` (and app-many, app-zfc, app-universal) define
  $C(D)$ *without* slots and $A(D)=C(D)\cup\mathrm{slots}(D)$.
* Fix: replace the two sentences by "Let $A(D)$ be the common-prefix tree of $D$ with its slots, as in
  \cref{def:single:features} (positions where all data carry the same label and arity at and above $p$,
  parameters compared by name, together with the slots). Let $\mathcal T(D)$ be $A(D)$ with each common atom
  node whose subtree contains a slot with an open column cut to a leaf slot (an \emph{F-slot}); so every term
  slot of $\mathcal T(D)$ has a closed column." Then write "the common part of $A(D)$" for "the common part
  of $C(D)$" in `app-experiments.tex` Step 0.

---------------------------------------------------------------------------------------------------------

## MINOR

### m1. Word-only cross-references where labels exist (the "alignment proposition" pattern)
Replace (file: quoted text → replacement):
* app-experiments: "the alignment proposition of \cref{app:setting}" → "\cref{prop:setting:align}";
  "the substitution facts of \cref{app:setting}" → "\cref{lem:setting:subst}"; "By the preservation lemma of
  \cref{sec:setting}" → "By \cref{lem:setting:preservation}"; "is proved in \cref{sec:many}" (HF$\cup\{u\}$)
  → "is \cref{prop:many:univset}".
* experiments: "\cref{app:setting} proves (a)--(c) for it" → "\cref{prop:setting:align} proves (a)--(c) for
  it"; "found a counterexample with a rigid parameter (\cref{app:setting})" → "(\cref{ex:setting:align})";
  "($\inst^\sim$, $\gen^\sim$ of \cref{app:setting})" → "(of \cref{app:setting:align})"; "not a fixed oracle
  $\Ref_d$ (\cref{sec:setting})" → "(\cref{def:setting:oracle})"; "This is $\DTRC$ of \cref{sec:many}" →
  "of \cref{def:many:dtrc}"; "analogues of the theorems of \cref{sec:many}" → "of
  \cref{thm:many:dtrc,thm:many:residue}"; "Plotkin's \evR{} for the implemented class (\cref{sec:univ})" →
  "(\cref{thm:univ:anchor})"; "which has false instances (\cref{sec:zf})" → "(\cref{prop:zf:indpat})";
  "a first-order pattern there (\cref{sec:zf})" → "(\cref{thm:zf:classify}, \cref{tab:zf:classify})";
  "exponential lower bound of \cref{sec:single}" → "of \cref{prop:single:blowup}"; "$\mathrm{Power}_W$ of
  \cref{sec:many}" → "of \cref{sec:many:examples}"; "refutes any instance (\cref{sec:many})" →
  "(\cref{prop:many:univset})"; Limitations (2) "(\cref{sec:many})" → "(\cref{lem:setting:onesided}(a),
  \cref{thm:many:residue}(b))"; (6) "the feature test of \cref{sec:single}" → "of \cref{thm:single:feat}".
* app-setting: "(F) is the finiteness theorem ... in \cref{sec:single} (Theorem B of the single track). For
  $\mathcal C=\DTF$ it is Proposition E1-lit of the experiments track, proved there through a normal form for
  literal covering." → "(F) is \cref{thm:single:min}(c). For $\mathcal C=\DTF$ it is
  \cref{prop:exp:normal}(c)."; "For $\DTF$ this is Proposition E1-al of the experiments track (computed check:
  E0b, below). The same proof gives it for $\DT$, with (F) supplied by the finiteness theorem of
  \cref{sec:single} instead of its $\DTF$ analogue." → "For $\DTF$ this is the experiments' alignment result
  (computed check: E0b, below); the same proof gives it for $\DT$, with (F) supplied by \cref{thm:single:min}
  instead of \cref{prop:exp:normal}."; `rem:setting:nested` "(\cref{sec:single}); for this $D$ it has exactly
  four elements (computed by the single track, ...)" → "(\cref{thm:single:min}); for this $D$ it has exactly
  four elements (\cref{ex:single:c82})".
* setting: "In $\DT$ it is finite (\cref{sec:single})" → "(\cref{thm:single:min})"; "\Cref{sec:single} gives
  the analogue for $\DT$" → "\Cref{thm:single:anchor,cor:single:special} give the analogue for $\DT$";
  `sec:setting:learning` three "(\cref{sec:single})" → "(\cref{thm:single:min}(c))", "\cref{thm:single:feat}
  and \cref{cor:single:poly} decide", "(\cref{sec:single:esc})"; "see \cref{sec:many}" (Gold) →
  "see \cref{prop:many:bound}"; "These two data anchor $z+0=z$ in $\DT$ (\cref{sec:univ})" →
  "(\cref{prop:univ:dt})"; "sound in the same sense (\cref{sec:exp})" → "(\cref{prop:exp:oracle})";
  "never refuted by evaluating closed instances (\cref{sec:univ})" → "(\cref{prop:univ:refute}(a))";
  "...with textbook variable names is one (\cref{sec:zf})" → "(\cref{prop:zf:coll})".
* single: "By the matching theorem of \Cref{sec:setting}" → "By \Cref{thm:setting:matching}"; "the
  clustering method of \Cref{sec:many}" → "of \Cref{thm:many:dtrc}"; "(\Cref{sec:univ}), two instances" →
  "(\Cref{thm:univ:anchor})"; "In the protocol of \Cref{sec:setting}" → "of \Cref{def:setting:protocol}";
  "the failure family of the earlier untagged PA analysis (\Cref{sec:many})" → "(\Cref{cor:many:failure})";
  "\Cref{sec:many} shows that this is polynomial for $k\le2$" and the intro's "is in \Cref{sec:many}" →
  "\Cref{thm:many:complexity}"; caveat (3) "(\Cref{sec:setting,sec:exp})" →
  "(\Cref{sec:setting:params,prop:setting:align})"; app-single last line "the complexity results of track
  single, Theorem H, which are presented in \Cref{sec:many}" → "\Cref{thm:many:complexity}".
* universal: "Plotkin's events (\cref{sec:setting})" and "the classical facts recalled in
  \cref{sec:setting}" → "(\cref{lem:setting:recover})"; "(rigid-prefix lemma, \cref{sec:single})" →
  "(\cref{lem:single:basic}(c))"; "the \emph{two-point lemma} used in \cref{sec:many}" →
  "\cref{lem:many:twopoint}"; "the anchor theorem of \cref{sec:single}" → "\cref{cor:single:special}(a)";
  "makes $\SO$ anchors for induction stronger (\cref{sec:zf})" and "the shielding condition for induction
  (\cref{sec:zf})" → "(\cref{prop:zf:indso})"; "matters for unlabelled mixtures (\cref{sec:many})" →
  "(\cref{rem:many:numerals})"; "sound iff the target is closed in the class (\cref{sec:setting})" →
  "(\cref{lem:setting:closed})"; "most-specific-guard rule (\cref{sec:setting})" →
  "(\cref{sec:setting:fo})"; "the residue of \cref{sec:many}" → "of \cref{thm:many:residue}". app-universal:
  rigid-prefix → \cref{lem:single:basic}(c); "By the matching theorem (\cref{sec:setting})" →
  "(\cref{thm:setting:matching})"; "By preservation (\cref{sec:setting})" →
  "(\cref{lem:setting:preservation})"; "accepts the closure (\cref{sec:setting})" (twice) →
  "(\cref{lem:setting:closed}(b))"; "the finitariness theorem of \cref{sec:single}" →
  "\cref{thm:single:min}"; "the first-order corollary of the anchor theorem of \cref{sec:single}" →
  "\cref{cor:single:special}(a)".
* zfc / app-zfc: "closed in $H$ (\Cref{sec:setting})" and "the closure criterion of \Cref{sec:setting}" (main
  text and proof of `prop:zf:indgen`) → "\Cref{lem:setting:closed}"; "the general anchor theorem of
  \Cref{sec:single}" (three places) → "\Cref{cor:single:special}(c)"; "for universal axioms over arithmetic
  (\Cref{sec:univ})" → "(\Cref{prop:univ:dt}(c))".
* many / app-many: "finitariness theorem of \cref{sec:single}" → "\cref{thm:single:min}"; "\Cref{sec:single}
  characterizes anchors" → "\Cref{thm:single:anchor,cor:single:special} characterize anchors"; "bounded
  explicitly in \cref{sec:single}" → "in \cref{thm:single:rates}(c)"; "see \cref{sec:zf}" (rate for
  $T_{\Ind}$) → "see \cref{thm:zf:indanchor,prop:zf:sub}"; "$4^n$ ... (\cref{sec:single})" →
  "(\cref{prop:single:blowup})"; "the feature verifier of \cref{sec:single}" → "\cref{thm:single:feat}";
  "(a result of the prior work's referee)" → "(\cref{thm:zf:K0})"; "\Cref{sec:exp} reports a budget effect"
  → "\Cref{prop:exp:qF} reports a budget effect"; app-many "the anchor-determines-template result of
  \cref{sec:single} (single Cor G.4)" → "\cref{cor:single:anchor-lgg}"; "(single Thm C)" (twice) →
  "(\cref{thm:single:feat})"; "(single Prop G.3)" → "(\cref{prop:single:lgg})"; "(single Cor G.4)" →
  "(\cref{cor:single:anchor-lgg})"; "By the rigid-prefix lemma of \cref{sec:single}" →
  "\cref{lem:single:basic}(c)"; "(minimal templates are saturated, \cref{sec:single})" →
  "(\cref{thm:single:min}(c))"; "is shown in \cref{sec:univ}" → "is \cref{ex:univ:q}".

### m2. $K_0$ restated in §6 and App. F without pointing to `thm:zf:K0`
* Files: `many.tex` (`sec:many:examples`, "$K_0$: the first-order lgg $K_0$ ... (a result of the prior work's
  referee)"); `app-many.tex` paragraph "$K_0$." ("The prior work's referee proved that ... (by building, for
  each instance, a model ... and amalgamating)").
* Problem: the statement agrees with `thm:zf:K0` but is re-derived in words three times without a
  cross-reference.
* Fix: `many.tex`: "...has only instances that are jointly consistent with the true quantifier-free
  sentences of $\N$ (\cref{thm:zf:K0}), so ...". `app-many.tex`: replace the first two sentences after the
  displayed $K_0$ by "By \cref{thm:zf:K0}, no sound refutation from quantifier-free truths exists, so
  R-$\Delta_0$ and logic refute none of its instances, among them the false $J^*_0$."

### m3. Basic lemmas stated and proved twice (§2 and §3)
* Files: `single.tex` `lem:single:basic`(a),(b),(e); `app-single.tex` proofs of (a),(b),(e); `setting.tex`
  `lem:setting:preservation`, `lem:setting:renaming`; `app-setting.tex` `lem:setting:subst` and proofs.
  Also `single.tex` (after `thm:single:min`) re-describes the antichain $T_k$ of `rem:setting:nested`, and
  `app-zfc.tex` `lem:zf:rigid` restates `lem:single:basic`(c).
* Fix: in `lem:single:basic` replace (a), (b), (e) by "(a), (b), (e): \Cref{lem:setting:preservation},
  \cref{lem:setting:subst} and \cref{lem:setting:renaming}" (or drop them and renumber), and delete the
  duplicate proofs in `app-single.tex`; in single after `thm:single:min` replace "its referee found the
  infinite antichain $(0=0\wedge\dots)$, $k\ge1$, of minimal covering templates of ..." by "it fails there
  (\cref{rem:setting:nested})"; in `lem:zf:rigid` add "(this is \cref{lem:single:basic}(c) for $\SO$)".

### m4. Internal provenance jargon in running text
* Track result IDs and record history outside `\src`:
  - `single.tex`: "conjectured finiteness (``C8.3'')", "and C8.3 holds", "conjectured (``C11'')", "So
    \emph{C11 is false}"; `tab:single:summary` "earlier C8.3", "earlier C11"; "So the candidate events of the
    brief are right in spirit" ("the brief" is `research/00-brief.md`, unknown to readers); "Nonemptiness was
    missing in the first version"; app-single "This is the failure of the first version of the proposition".
    Fix: "the earlier analysis conjectured that $\Min(D)$ is finite also with nested arguments \src{prior
    induction C8.3}"; "The earlier analysis conjectured that escalations are at most linear ... \src{prior
    induction C11}. ... So this conjecture is false"; table: "(the earlier finiteness conjecture: true for
    $\DT$, false with nested arguments)", "(the earlier linear conjecture refuted)"; "So the events one would
    first try (root variation and distinctness, as for first-order patterns) are right in spirit ..."; drop
    "Nonemptiness was missing in the first version and" (keep "Nonemptiness matters for ...") and the
    app-single sentence (move to app:ver).
  - `experiments.tex` uses "the first record" 8 times (intro, `sec:exp:impl` twice, Baselines, Data sets,
    after `thm:exp:dtrc`, after E2, E3 reading, after `prop:exp:qF`), and app-experiments says "the record
    says", "The record's statement", "not covered by the record's statement". Fix: keep one sentence in the
    intro ("Withdrawn claims of an earlier version are listed in \cref{app:ver}") and replace each later
    occurrence by a neutral statement plus "(withdrawn; \cref{app:ver})", e.g. "The claim that the pattern
    $\lgg$ equals $\DTF$ on the ZF schemas was an artifact of the formula-level baseline (withdrawn;
    \cref{app:ver})"; move the app-experiments remarks to `%` comments or app:ver.
  - `universal.tex`: "the record calls this (H)" → delete; "The record corrected (b) and (e) after the
    referee: ..." → delete (it is verification history). `app-universal.tex` "The record remarks", "The
    record's example" → "We note", "An example".
  - `app-setting.tex`: "Version~1 of the experiments record stated the last property ... the referee's
    counterexample above refutes it" → move to app:ver; "(single, \texttt{e1\_matching.out})" and "The
    single-track referee's independent matcher" → put in `\src{single e1; referee A}`.
  - `many.tex`/`app-many.tex`: "(An earlier version of the record claimed the contrary ...)", "The first
    version of the research record added ...", "The first version of this construction used Kleene's $T$
    ...", "(untagged Prop 6.1)", "Every \DTRC{} run of the record", "As far as the record knows" → move the
    history to app:ver, the IDs into `\src{}`, and write "our" for "the record's".
* Inconsistent names for the earlier induction work: "the prior session" (`setting.tex` twice,
  `app-setting.tex` twice, incl. "Part (d) was proved in the prior session"), "the earlier analysis"
  (`single.tex`), "the prior work" / "the prior work of this project" (`many.tex`, `app-many.tex`), "the prior
  record" (`zfc.tex`: "The results are from the prior record"; `app-zfc.tex`: "as in the prior record"),
  "the prior track" (`app-zfc.tex`: "checked locally by the prior track"). Fix: define once in §2
  ("the earlier analysis of PA induction, \citealp{claude2026whatfollows} and its follow-up notes") and use
  "the earlier analysis" everywhere, with the item ID in `\src{prior induction ...}`.

### m5. Status markers: definitions are handled three ways; several non-standard status strings
* Definitions: no `\status` in setting, single, universal (`def:setting:*`, `def:single:*`,
  `def:univ:target`); `\status{definition}` in many (`def:many:setting`, `def:many:dtrc`) and experiments
  (`def:exp:normal`); `\status{known}` on `def:zf:enc`. Non-standard strings: "proved; known in substance"
  (`lem:many:cautious`, `prop:univ:tv`), "proved; known (Gold)", "proved; computed (consistency check)",
  "computed; reproduced by the referee", "computed; independently confirmed by the referee", "proved, using
  standard coding facts cited from memory".
* Fix: adopt the majority convention (definitions carry `\src` only) and add it to NOTATION.md: delete
  `\status{definition}` in `many.tex` (2×), `experiments.tex` (1×) and `\status{known}` on `def:zf:enc`.
  Normalize the strings to the NOTATION list plus a plain-text remark, e.g. `\status{proved; known}` and put
  "(Gold)", "(consistency check)", "reproduced by the referee", "coding facts cited from memory" into the
  statement or `\src`.

### m6. $\chi$ undefined in the proof of `cor:many:paslots`
* File: `app-many.tex`, "The four-slot criterion": "If $\chi\le4$, ... If $\chi>4$, ...".
* Fix: before "If $\chi\le4$" insert "Let $\chi$ be the least number of blocks in a partition of the
  induction data into blocks that are root-homogeneous or all-vacuous (without vacuous motives: the number of
  main connectives occurring)."

### m7. "(N)" denotes both the named encoding and the non-vacuity event
* Files: `setting.tex` §2.3 ("In the \emph{named} encoding (N)") and eight lines later "\evN{} (every argument
  place is used)"; `universal.tex` uses "(N)" for the syntax throughout (`prop:univ:capture`,
  `tab:univ:learner`); §3, §5, §6 use \evN for non-vacuity.
* Fix: rename the encoding to "(Nm)" in `setting.tex`, `universal.tex`, `app-universal.tex` (e.g.
  "the \emph{named} encoding (Nm)", "Work in syntax (Nm) or (dB)").

### m8. Size-bounded class written $\mathrm{DT}_s$ in §2 (the nested-argument class), $\DT_s$ in §5; bounds stated differently
* Files: `setting.tex` after `lem:setting:closed`: "PA induction is closed in the size-bounded class
  $\mathrm{DT}_s$ iff $s\ge12$"; `single.tex` Open problems: "templates of size $\le11$ make the cautious
  verifier accept a false induction-shaped sentence after any anchor"; `zfc.tex` `thm:zf:indanchor` uses
  $\DT_s$ before size is defined ("Here $|T|$ counts symbols ..." comes after it).
* Problem: in §2 $\mathrm{DT}$ (no $^\circ$) is the nested-argument class of `rem:setting:nested`; the result
  (prior C6.2, `prop:zf:indgen`) is for $\DT$. The single text omits the lower bound $7$ (below $7$ there is
  no anchor in $\DT_s$).
* Fix: setting: "closed in the class $\DT_s$ of templates of size at most $s$ (size as in
  \cref{prop:zf:indgen})"; single: "templates of size $7$ to $11$ make ..."; zfc: move "Here $|T|$ counts
  symbols, ...; so $|T_{\Ind}|=14$." before `thm:zf:indanchor`.

### m9. Separation and spelled-out Replacement written with other variable names in §3
* File: `single.tex` `cor:single:special`(c): "Separation $\forall a\exists b\forall x(x\in b\leftrightarrow
  x\in a\wedge P(x,a))$ iff \evR, \evN$_x$, \evN$_a$"; "three occurrences $P(x,y,a)$, $P(x,z,a)$,
  $P(x,y,a)$".
* Problem: §2 (`T_{\Sep}`) and §5 (`tab:zf:forms`, `tab:zf:summary`: "\zfN{x}, \zfN{z}"; $\ReplS$ with
  $P(x,y,A),P(x,u,A),P(x,y,A)$) use $z,y,x$ and $u,A$; also "\evN$_x$" renders as "(N)$_x$" vs §5's
  "(N$_x$)".
* Fix: "Separation $T_{\Sep}$ (\cref{tab:setting:classes}) iff \evR, (N$_x$), (N$_z$) ($y$ cannot occur in
  $P$: ...)"; "spelled-out Replacement $\ReplS$ (\cref{tab:zf:forms}), whose occurrences $P(x,y,A)$,
  $P(x,u,A)$, $P(x,y,A)$ ... iff \evR, (N$_x$), (N$_y$), (N$_A$)". (Moving `\zfN` to the preamble lets §3 use
  it.)

### m10. §5's coincidence events are not related to §3's
* File: `zfc.tex` "Several metavariables" and `thm:zf:multi`; also "Whether \zfDroot{} is necessary in $\SO$
  is open; we conjecture that it is not."
* Problem: for $H=\DT$, (D$^{\mathrm{DT}}$) is the event (D$^+$) of `cor:single:special`(b) (i.e. \evU{} for
  formula metavariables), but the text never says so, and a reader meets two names for one event. The
  conjecture sits in running text without an environment/status.
* Fix: after the definition of the events add "For $H=\DT$, \zfDdt{P\to Q} for all ordered pairs is the event
  (D$^+$) of \cref{cor:single:special}(b), so the $\DT$ case of \cref{thm:zf:multi} is also a case of
  \cref{thm:single:anchor}." Turn the last sentence into `\begin{conjecture}\status{conjecture}\src{cases
  \S6}\label{conj:zf:root} \zfDroot{} is not necessary for anchors in $\SO$.\end{conjecture}` and cite it in
  app-zfc ("suggests \cref{conj:zf:root}").

### m11. "sound" locally redefined as truth-sound in §5
* File: `zfc.tex` "First-order learners": "A first-order schema is \emph{sound} if its sentence instances are
  true in $\N$." and `thm:zf:indunion` "$k$ sound first-order schemas"; app-zfc "A union of $k$ sound
  schemas".
* Fix: "is \emph{truth-sound}" and "$k$ truth-sound first-order schemas", "$k$ truth-sound schemas"
  (matching `def:setting:protocol`).

### m12. "an instance of Q1" should be "a consequence of Q1"
* File: `app-many.tex` proof of `prop:many:forall`(e): "the universal premise $\forall x(\neg x=0\to\neg
  Sx=0)$, an instance of Q1".
* Problem: Q1 is a ground template; the premise is not an instance of it (the untagged record says "whose
  antecedent needs Q1").
* Fix: "..., which follows from Q1".

### m13. "parameter-free data sets" contradicts the next clause
* File: `app-experiments.tex`, after the E0b table: "The aligned set also differs from the literal one on
  $38/200$ (PA) and $72/200$ (ZF) parameter-free data sets: the data's bodies carry parameters, ...".
* Problem: by `app:setting:align` ("If some datum has no parameter there is one alignment, and
  $\Min^{\mathrm{al}}$ is $\Min$ up to $\equiv^\sim$") the two sets cannot differ on a data set with a
  parameter-free datum; the rows meant are those whose generating $T^*$ has no rigid parameter.
* Fix: "... on $38/200$ (PA) and $72/200$ (ZF) data sets whose generating template has no rigid parameter:
  the data's bodies carry parameters, ...".

### m14. `prop:exp:numerals`: "form an anchor iff they include $0$" ignores the all-zero draw
* File: `experiments.tex` `prop:exp:numerals` ("numerals uniform in $0..7$ form an anchor iff they include
  $0$") and the E3 reading ("$n$ numerals form an anchor with probability $1-(7/8)^n$").
* Problem: draws are with replacement (`dtrc/datasets.py`: `rng.randrange(8)`); if all draws are $0$ the data
  set is the single datum $0+0=0$, not an anchor. Exact probability $1-(7/8)^n-(1/8)^n$ (the E1 prediction
  already uses both heads).
* Fix: "form an anchor iff they include $0$ and a nonzero numeral" and "with probability
  $1-(7/8)^n-(1/8)^n$".

### m15. Implemented \DTRC{} step (4) differs from `def:many:dtrc` step (3)
* File: `experiments.tex` "\DTRC{} as implemented: ... (4)~per cluster, $\Acc(C)=\bigcap\{\dots\}$, or $C$ if
  all are refuted; ... This is $\DTRC$ of \cref{sec:many} with the class $\DTF$, a fixed merge order and a
  budgeted refuter."
* Problem: `def:many:dtrc` sets $\Acc_d(C)=\emptyset$ when no minimal template is unrefuted.
* Fix: "... a fixed merge order, a budgeted refuter, and the convention that a cluster whose minimal
  templates are all refuted asserts its own data (\cref{def:many:dtrc} asserts nothing)."

### m16. E6 "reproduces the prior untagged result (\cref{sec:many})" without saying why the slot count differs
* File: `experiments.tex` E6: "one slot $\forall x\,P(x)$ takes all of $\Q$ ... This reproduces the prior
  untagged result (\cref{sec:many})".
* Problem: §6 (`cor:many:paslots`) computes $c=4$ on positive data for $\Q$ in parameter form; E6 keeps
  leading quantifiers, so all of $\Q$ fits in one slot ($c=1$). The source (experiments notes) means the
  `prior/pa-untagged` result, not §6.
* Fix: "This is the slot accounting of \cref{thm:many:slots}: with leading quantifiers kept, all of $\Q$'s
  axioms are instances of $\forall x\,P(x)$, so $c=1$ on positive data (against $c=4$ for the parameter form
  of \cref{cor:many:paslots}), and $c=7$ with negatives in both presentations."

### m17. "as \cref{prop:exp:share} predicts" overstates the proposition
* File: `experiments.tex` E3 "Reading": "with sharing it matches the membership-labelled learner target by
  target and seed by seed, as \cref{prop:exp:share} predicts."
* Problem: the equality in `prop:exp:share` needs (H-ref), which "the implemented refuter violates" (text
  after `thm:exp:dtrc`); the proposition only predicts anchor-exactness.
* Fix: "... seed by seed; \cref{prop:exp:share} predicts this where exactness comes from anchors (the
  equality in general needs (H-ref), which the implemented refuter does not satisfy)."

### m18. "for these mixtures we prove refutation separation" (ideal refuter)
* File: `experiments.tex` intro paragraph.
* Problem: `cor:exp:mixsep` proves (S) "with an ideal refuter"; for the budgeted refuter it is observed
  (E9).
* Fix: "for these mixtures we prove refutation separation for an ideal refuter, and the budgeted refuter
  found every needed refutation (E9)".

### m19. "the method first proposed" has no antecedent in the paper
* File: `many.tex` `sec:many:summary`: "\DTRC{} answers the third question, with four amendments to the
  method first proposed".
* Problem: the first proposal lives in `research/00-brief.md` §5; the intro only says "We propose \DTRC{}".
* Fix: "\DTRC{} answers the third question. Four features of it are forced by results above, and a naive
  version without them fails: ...".

### m20. $\mathrm{Union}_W$, $\mathrm{Power}_W$ and the universal-set schema $U$ are written differently in §6 and §7 under the same names
* Files: `many.tex` ($\mathrm{Union}_W=\exists b\forall c(\exists d(d\in p\wedge c\in d)\to c\in b)$,
  $U(F)=\exists x\forall y(F(y)\to y\in x)$) vs `experiments.tex` `prop:exp:hard`(a)
  ($\mathrm{Union}_W=\forall a\exists b\forall x(\dots)$, $U=\forall a\exists b\forall x(P(x,a)\to x\in b)$),
  which refers to "the bounding forms $\mathrm{Union}_W$, $\mathrm{Power}_W$ of \cref{sec:many}".
* Fix: in `experiments.tex` before `prop:exp:hard` add "(here with the leading $\forall a$ kept, as
  everywhere in this section, so $U$ has the binary metavariable $P(x,a)$ instead of the parameter form
  $U(F)$ of \cref{prop:many:univset})".

### m21. The $\DT$ extension of the alignment proposition is not marked as new in its tag
* File: `app-setting.tex` `prop:setting:align`: `\src{experiments Prop E1-al}` for $\mathcal C\in\{\DT,\DTF\}$.
* Problem: the record proves only $\DTF$ (writer-notes, setting item 3); the text says so afterwards but the
  provenance tag does not.
* Fix: `\src{experiments Prop E1-al ($\DTF$); $\DT$ case new here}`.

### m22. "truth-safe" is a fifth, undefined soundness word
* File: `universal.tex` (list item (2), after `ex:univ:fail`(c), `prop:univ:learner`(2), after
  `prop:univ:refute`, summary).
* Fix: define it once at first use: "is \emph{truth-safe} in $M$ (it never leads from true closed instances
  to a false universal)", or replace by "truth-preserving in $M$" throughout.
