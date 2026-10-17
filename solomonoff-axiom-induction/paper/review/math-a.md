# Mathematics review A: §2 (setting), §3 (basic), §4 (soi), Appendix A (app-basic), Appendix B (app-soi)

*Reviewer A, 2026-10-17. Scope: `sections/setting.tex`, `basic.tex`, `soi.tex`, `app-basic.tex`, `app-soi.tex`. Every numbered statement was compared with its source item in `research/tracks/fundamentals/notes-final.md` and `research/tracks/sfi/notes-final.md` (statement, hypotheses, quantifiers, constants, and the status in each record's claims table: fundamentals §0.3, sfi §15), with the `CLAIMS.md` rows §1–§3, and with `research/final-check.md` §4. Every proof in Appendices A and B was read line by line against the record's proof.*

**Summary.** No fatal issue. One major issue: a quantifier in `thm:soi:diagonal` (repeated in `prop:soi:incomparable`) makes the theorem false as literally read; the proof is fine and the fix is one phrase. Twelve minor issues: one sentence cites a bound that does not exist, one proof refers to a symbol the statement no longer uses, several prose sentences overstate slightly, and two symbols appear in theorem statements without a definition in the main text. Apart from these, the mathematics matches the records exactly. That covers hypotheses, quantifiers, constants and statuses, the corrections of `final-check.md` §4 that concern these sections (items 1, 3, 4, 9, 10), and the CLAIMS "how to state" lines.

---

## How the review was done

* **Build.** I ran a full build under the lock (`flock /tmp/claude-0/paper-build-sai.lock ./build.sh`): 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt, 230 pages.
* **Statements against records.** All 112 theorem-like environments in the five files were checked: definitions, propositions, lemmas, corollaries, remarks, questions and assumptions. A script confirmed that each of them carries both `\status{}` and `\src{}`.
* **Statuses.** Each `\status{}` was compared with the record's claims table.
  * Three discrepancies I noted at first turned out to be supported by sfi §15, where the claims table lists the referee computations `rb3` and `rA1`/`rb4`:
    * "proved; computed" on `thm:soi:transfer` and `rem:soi:encoding`;
    * "(d) computed" on `prop:soi:closure`;
    * "computed" on `cor:soi:circuitBayes`.

    They are therefore **not** issues.
  * No status is stronger than its source.
  * Proof sketches (`rem:basic:generative`, `rem:soi:freededuction`, `rem:soi:onetapesandwich`, `rem:soi:axiomsetprior`, the (S_tape) remark) are Remarks headed "Proof sketch." and are never stated as theorems.
* **Citations by printed number.** Every "Definition/Theorem/… X.Y of the earlier report / the companion paper" in the five files was resolved against `../axiom-induction/paper/main.aux` and `../solomonoff-operator-induction/paper/main.aux`. All of them exist and have the cited content:
  * earlier report: Defs 2.9, 2.12, 6.2, E.10, E.18; Lemmas 2.10, 2.21, E.11, E.12, E.14, E.19, E.28; Props 2.17–2.19, 2.22, 6.4–6.7, 7.11, B.8, E.1, E.13, E.15–E.17, E.21, E.23, E.26, E.27; Thms 3.9, 6.3, 6.9, 6.14–6.16; Cor 6.17; App. E.6 (which contains the "Machines" paragraph with (S));
  * companion paper: Defs 3.2, 3.4, 3.6, 9.1, 9.7; Ex 3.5; Props 3.3, 3.7, 3.9, 3.24, 4.5–4.7, 9.4, A.2, A.7, A.10; Thms 3.8, 3.21, 4.4, 4.9, 5.1, 5.3, 9.8, 9.10 (the conjunction ladder); Cor 4.5, 4.10, 5.4; Questions 3.14, A.8.
  * The text of AI-paper Thm 6.14(a), Def E.10, Lemma E.12 and the assumption (S) was compared with `ass:soi:S`, `def:soi:penalised` and the proof of `thm:soi:penalty`; they match.
* **Cross-references inside the paper.** Every `\cref` with a part, such as `\cref{x}(c)`, was checked by script for the existence of that part. The content of the targets in other sections was compared with what my sections claim about them:
  * `prop:laws:randomised`, `prop:shape:E2`, `rem:terms:named`, `prop:logic:normalised`, `thm:terms:horn`, `prop:laws:twopart`, `lem:logic:density`, `thm:logic:lottery`;
  * `cor:logic:versions`, `cor:logic:coding`, `thm:shape:knowhow`, `thm:terms:KCV`, `thm:terms:padded`, `cor:terms:table`, `prop:terms:a1fit`, `thm:terms:binary`, `thm:terms:regular`.

  No broken or wrong target was found.
* **Numeric constants.** A script in the scratchpad (`mathA/numchecks.py`, output `numchecks.out`) checked the following, with no violations:
  * $3^{2^{\ell_d}}<2^d$ and $\ell_d>\log d-2$ for $d=2..200000$ (`thm:basic:nocoding`);
  * $\sum_j\log(1+2^{-j-2})=0.3466\le1/(4\ln2)=0.3607<0.361$, and $1.361\le1.37$ (`thm:soi:diagonal`);
  * $\log_2(1+v)\ge v$ on $[0,1]$ (`thm:basic:order`(b));
  * the padding increments 4 and 5 reach every $m\ge12$ (`rem:soi:lengths`);
  * $|p|+c+1\le(c+2)|p|$ (`prop:soi:kt`);
  * the closed form of `thm:basic:order`(a) on 20000 random cell vectors;
  * the identity of Step 1 in the proof of `prop:basic:crorder` on 20000 random values.

---

## Issues

### 1. [major] The lower bounds for clocked SOI in the diagonal theorem are stated for every diagonal sequence but proved for one

* **Location.** `sections/soi.tex`, `thm:soi:diagonal`, last sentence: "Moreover $W^{\mathrm{all},\tau}$ loses at least $n-1.37$ and $W^{\mathrm{cons},\tau}$ at least $n-1.37-c_\bot$ on such sequences." The same reading recurs in `sections/app-soi.tex`, `prop:soi:incomparable`: "on the sequences of \cref{thm:soi:diagonal}, $W^{\mathrm{all},\tau}$ loses at least $n-1.37$".
* **Problem.** "Such sequences" naturally reads as *every* sequence produced by the theorem, one for each computable predictor $P$. Under that reading the statement is false.
  * Take $P$ that always predicts $(\frac12,\frac12)$. The tie rule of the construction (`app-soi.tex`, proof of `thm:soi:diagonal`: $\beta_j:=0$ if $a_0\le a_1$) gives $e(n)=0$ for all $n$, so every $s_n$ is labelled $0$.
  * Then the clocked string "label everything $0$" is compatible with every $D_n$, so $W^{\mathrm{all},\tau}$ has bounded loss.
  * The same holds for $W^{\mathrm{cons},\tau}$: the labels $\neg s_n$ are true, hence consistent with $B$.
* **Evidence.** The proof proves the bound only for the sequence built against the particular predictor $P^\ast(D):=(W^{\mathrm{all},\tau}(D)+2^{-|D|})/2$ ("Put $P(D):=\dots$; … On $P$'s sequence …"). The source is `sfi` Thm 7.4 ("$W^{{\rm all},\tau}$ loses $\ge n-1.37$ …"), and its proof re-check ("$W^{{\rm all},\tau}$ is turned into a computable predictor by mixing in $2^{-|D|}$") does the same. The record's phrasing is equally ambiguous. The existential reading is the one used correctly elsewhere: in `thm:soi:onetapetime`(b) ("On a computable sequence of arithmetic sentences"), in the main text after the theorem ("on a computable sequence on which $\MA$ loses at most …") and in Table 1 ("reverse $\ge n-1.37-c_\bot$").
* **Fix.**
  * In `thm:soi:diagonal`, replace the last sentence by: "Moreover, on the sequence built in this way against the computable predictor $P^\ast(D):=(W^{\mathrm{all},\tau}(D)+2^{-\lvert D\rvert})/2$, $W^{\mathrm{all},\tau}$ loses at least $n-1.37$ and $W^{\mathrm{cons},\tau}$ at least $n-1.37-c_\bot$, while $\WA$, $\WAchk{t}$ and $\WAgen{t}$ lose at most $\log(1/\omega_0)$."
  * In `prop:soi:incomparable`, write "on a computable sequence (\cref{thm:soi:diagonal}, applied to $P^\ast$), $W^{\mathrm{all},\tau}$ loses at least $n-1.37$ while \SAIabbr loses $O(1)$".

### 2. [minor] A sentence cites a bound that `thm:basic:loss` does not contain

* **Location.** `sections/app-basic.tex`, the paragraph before `prop:basic:wholetheory`: "The bound $\Keq(T)\le\KA(D)+c$ of \cref{thm:basic:loss} is about single theories; …"
* **Problem.** `thm:basic:loss` has no such inequality. It proves $\LA(D_n)\le\dots\le\Keq(T)+c$ and $\LA(D_n)\le-\log\WA(D_n)+c\le\KA(D_n)+c$. An inequality $\Keq(T)\le\KA(D)+c$ appears only inside the proof of `thm:basic:kolmogorov`(ii), for $T$ the theory of a shortest compatible program.
* **Evidence.** `fundamentals` Thm 5.1 (the source of `thm:basic:loss`) contains only the chain quoted above.
* **Fix.** "The bounds of \cref{thm:basic:loss} are stated with $\Keq(T)$, the length of a single shortest index of a theory equivalent to $T$; for whole theories the question is how $\Keq$ compares with the mixture weight $\mmeq$."

### 3. [minor] The proof of `prop:basic:crorder` refers to a symbol $e_{i,j}$ that the statement no longer uses

* **Location.** `sections/app-basic.tex`, proof of `prop:basic:crorder`(b), first sentence: "Write $\zeta_{i,j}$ for the sentence $e_{i,j}$ of the statement, so that $b_{i,j}=a_i\vee\zeta_{i,j}$ (this avoids a clash with indices $e$)."
* **Problem.** The statement in `basic.tex` already defines $\zeta_{i,j}:=\neg s_{i,1}\wedge\dots\wedge\neg s_{i,j-1}\wedge s_{i,j}$ and $b_{i,j}:=a_i\vee\zeta_{i,j}$. No $e_{i,j}$ appears in the paper, so the sentence points to nothing. It is a leftover from the record (`fundamentals` Prop 7.2(b) writes $e_{i,j}$).
* **Fix.** Delete the sentence.

### 4. [minor] The lead-in to two propositions says the background does not matter beyond a constant factor; one of them says the converse fails

* **Location.** `sections/basic.tex`, the paragraph before `prop:basic:invariance`: "Neither the universal machine nor the background matters beyond a constant factor:"
* **Problem.** This holds for the universal machine (`prop:basic:invariance` is two-sided). For the background, `prop:basic:background` gives only $\MA^B\ge2^{-K(B')-c}\MA^{B'}$ for $B\subseteq\Cn_\emptyset(B')$, and it says itself that "the converse fails: a $D$ consistent with $B$ and inconsistent with $B'$ has $\MA^{B'}(D)=0<\MA^B(D)$". So the background can matter by an unbounded factor.
* **Evidence.** `fundamentals` Prop 4.3 and the sentence after it: "So building knowledge into the background gains at most $K(B')+c$ bits on any data."
* **Fix.** "The universal machine matters only up to a constant factor, and building knowledge into the background gains at most a constant number of bits:"

### 5. [minor] The citation for "(Bel_D, Pl_D) is a coherent lower and upper probability" proves less than the claim

* **Location.** `sections/setting.tex`, `rem:setting:defects`, last sentence: "keeping it, the pair $(\Bel_D,\Pl_D)$ is a coherent lower and upper probability (\cref{prop:basic:geometric})."
* **Problem.** `prop:basic:geometric`(c) proves only that *some* probability $P_D$ on completions satisfies $\Bel_D\le P_D\le\Pl_D$. That is "avoiding sure loss". In the usual sense, coherence requires $\Bel_D$ to be the lower envelope of such probabilities.
  * The stronger statement is true. In the proof of (c), enumerate $\neg\chi$ first, so that it is added whenever $B\cup A_\omega\cup\{\neg\chi\}$ is consistent. The resulting $P_D^\chi$ has $P_D^\chi(\chi)=\Bel_D(\chi)$, so the envelope is attained at every $\chi$.
  * But neither the paper nor `fundamentals` Prop 2.2 states this. The record's Rem 1.6 does not use the word. The phrase comes from the earlier report's "Coherent bracketing", which also proves only existence.
* **Fix.** Either write "there is a probability on the complete extensions lying between $\Bel_D$ and $\Pl_D$ (\cref{prop:basic:geometric}(c))", or add to the proof of (c) the sentence: "Enumerating $\neg\chi$ first gives a $P_D$ with $P_D(\chi)=\Bel_D(\chi)$, so $\Bel_D$ is the lower envelope of these probabilities."

### 6. [minor] "SAI meets the same bound" does not name the reading of charged deduction

* **Location.** `sections/soi.tex`, `sec:soi:presburger`, last sentence before `prop:soi:presburgerCharged`: "With deduction charged, \SAIabbr meets the same bound:"
* **Problem.** The sentence names no reading. The doubly exponential (Fischer–Rabin) bound is proved only for the size and material readings. Under (a1) only exponential instance sizes are proved (doubly exponential is open). For (a2) and (b2) nothing is settled.
* **Evidence.**
  * `sfi` Props 9.4, 9.4′, the remark after 9.4′, and §16 M1. The development round had generalised the bound to every charged reading; both referees rated this major, and the claim was withdrawn.
  * CLAIMS global rule 4: "any sentence … names the reading ((a1), (a2), (b), (b2))".
  * `prop:soi:presburgerCharged` and the following sentence state it correctly, so this is a lead-in overstatement.
* **Fix.** "With derivation size or material charged, \SAIabbr needs doubly exponential budgets as well, and under (a1) at least exponential instance sizes:"

### 7. [minor] The table discussion presents the known separations as the only ones

* **Location.** `sections/soi.tex`, paragraph "How to read the table": "On literals \SAIabbr and \SOIabbr coincide; they separate only through logical closure, observed independence, consistency constraints of unbounded arity, or deduction that is free."
* **Problem.** "Only through" claims an exhaustive list. No such characterisation is proved. The record's statement is "the content of SAI beyond SOI lies in logically structured data" (`sfi` §5.5), and the four items are the separations actually proved.
* **Evidence.** `sfi` §5.5 last paragraph; synthesis H1 "How to state it" and §3.5. For a precedent, `final-check.md` §4 item 5 corrected the analogous list in synthesis H2 (`logic` Cor 2.5) to "that they are the only ones is not claimed".
* **Fix.** "On literals \SAIabbr and \SOIabbr coincide; the separations we know come from logical closure, observed independence, consistency constraints of unbounded arity, or deduction that is free."

### 8. [minor] A row of Table 1 suggests that the Levin-type penalised version is also within a constant of the unpenalised one

* **Location.** `sections/soi.tex`, `tab:soi`, row "axiom-side penalties $\MAchk{t},\MAgen{t}$; $\WAchk{t},\WAgen{t}$; $\WAKt{t}$ — $\asymp$ unpenalised, also class by class; a Levin penalty costs a labeller $\log(\lvert f\rvert+1)+O(1)$ bits".
* **Problem.** The pair column lists $\WAKt{t}$ together with versions that are $\asymp$ the unpenalised ones, and the relation column begins with "$\asymp$ unpenalised". But $\WAKt{t}$ is not $\asymp\Wcons$:
  * it is within $2^{c}$ and $2^ct(m_0)$ of $W^1$, whose weights are $2^{-|f|}/(|f|+1)$;
  * the factor $|f|+1$ is unbounded.
* **Evidence.** `prop:soi:kt`; `sfi` Prop 7.2, and §11 row 19 (a separate row there).
* **Fix.** Split the row:
  * "$\MAchk{t},\MAgen{t}$; $\WAchk{t},\WAgen{t}$ — $\asymp$ unpenalised, also class by class ($t\ge m^{a^*}$; (S$_{\rm tape}$), (S))";
  * "$\WAKt{t}$ — within $2^{\pm c}$ and $t(m_0)$ of $W^1$: a labeller pays $\log(\lvert f\rvert+1)+O(1)$ bits ((S))".

### 9. [minor] The constant for clocks measured in bit length should be $c'<c/\kappa_0$, not $c'<c$

* **Location.** `sections/app-soi.tex`, `rem:soi:lengths`(ii): "For clocks in bit length the results hold with $\tau(b)\le2^{2^{c'b/\log(b+2)}}$ in place of $\tau(m)\le2^{2^{c'm}}$, …, since $b/\log(b+2)\le\kappa_0\lvert\varphi\rvert$."
* **Problem.** The substitution gives $\tau\le2^{2^{c'\kappa_0m}}$. The arguments of `prop:soi:presburger` need the exponent constant below $c$, so the condition becomes $c'\kappa_0<c$, not the $c'<c$ of the propositions. The same applies to the singly exponential clocks. The record (`sfi` Rem 9.0(ii)) has the same looseness.
* **Fix.** Add "with $c'<c/\kappa_0$ (and likewise for the singly exponential clocks)".

### 10. [minor] Process 2 is said to be computable relative to the halting set, but its draws are infinite theories

* **Location.** `sections/app-basic.tex`, paragraph after `prop:basic:demski`: "the processes are computable relative to $\emptyset'$, since consistency of a finite set is $\Pi^0_1$ (a single draw of Process 2 can output one sentence)."
* **Problem.** For Process 1, $(\sigma_1,\dots,\sigma_t)\mapsto S_t$ is indeed $\emptyset'$-computable. Process 2 is different:
  * it keeps or discards possibly *infinite* theories $A_{\omega^{(t)}}$, r.e. in the tapes;
  * "$B\cup$ kept $\cup A_{\omega^{(t)}}$ is consistent" is $\Pi^0_1$ relative to the tapes, so deciding it needs the jump of the tapes, not $\emptyset'$;
  * the parenthesis justifies only the *non*-computability claim.

  The statement in `fundamentals` Prop 10.1(c) ("the same holds for the modified process") carries the same imprecision. It is not a numbered claim of the paper.
* **Fix.** "Process 1 is computable relative to $\emptyset'$, since consistency of a finite set is $\Pi^0_1$. Process 2 needs a consistency test relative to the tapes, which is $\Pi^0_1$ in them. Neither is computable, since a single draw of Process 2 can output one sentence."

### 11. [minor] The definition of the literal language lists $R$ among the unary function symbols

* **Location.** `sections/setting.tex`, `def:setting:fresh`: "The standard instance is the \emph{literal language}: a constant $\mathtt e$, unary function symbols $\mathtt s_0,\mathtt s_1$ and $R$, …"
* **Problem.** As written, $R$ reads as a third unary function symbol. It is the unary *relation* symbol of the literal setting (`terms` Def 1.2: $\mathcal L_O=\{\mathtt e,\mathtt s_0,\mathtt s_1,R\}$).
* **Fix.** "…: a constant $\mathtt e$, unary function symbols $\mathtt s_0,\mathtt s_1$, and the unary relation symbol $R$, …"

### 12. [minor] "Likewise for the Kolmogorov versions" refers to a Kolmogorov version that is never defined

* **Location.** `sections/setting.tex`, `rem:setting:versions`(b): "…$2^{-c}\WA(D)\le\WAgen t(D)\le2^c\WA(D)$, and likewise for the Kolmogorov versions". The proof in `app-basic.tex` (proof of `rem:setting:versions`(b)) also treats "the Kolmogorov versions".
* **Problem.** `def:setting:versions` defines $\WAgen t$ but no Kolmogorov counterpart, so the second claim has no defined object. The source has the same gap (`fundamentals` Prop 1.8(b), Def 1.7).
* **Fix.** In `def:setting:versions`, add "and $\KA^{\mathrm{gen},t}$, the least length of such an enumerator compatible with $D$", or reword (b) as "$\lvert\KA(D)-\min\{\lvert p\rvert:p\text{ a compatible enumerator of the delay form}\}\rvert\le c$".

### 13. [minor] Two symbols appear in statements of §3 and §4 but are defined only in the notation appendix

* **Location.**
  * `sections/basic.tex`, `thm:basic:nocoding` ($\Omtail{\ell_d}$);
  * `sections/soi.tex`, `prop:soi:independent`(b) and `prop:soi:noRE`(b) ($\Omtail{n+1}$, $\Omtail{n(\sigma)}$);
  * `cor:soi:transfer`(b) and Table 1 ($\Kpad$).
* **Problem.** Neither $\Omega_V^{\ge\ell}$ (the halting mass of the $V$-programs of length at least $\ell$) nor $\Kpad(n)=\min_{n'\ge n}K(n')$ is defined in §2–§4. The paragraph "Algorithmic notation" of `setting.tex` defines only $\Omega_V$.
  * `app-notation.tex` says that they are "used in the body without a displayed definition".
  * Its table points the reader to `sec:setting:data` and `thm:basic:nocoding` for $\Omtail{\ell}$, and to `sec:soi:literals` for $\Kpad$. Neither symbol is defined at any of these places.
  * $\Kpad$ is defined in the appendix only (`rem:terms:named` uses it too).
* **Fix.** Add to the paragraph "Algorithmic notation" of `setting.tex`: "$\Omtail{\ell}:=\sum\{2^{-\lvert p\rvert}:p\in\dom V,\ \lvert p\rvert\ge\ell\}$, the tail of $\Omega_V$, and $\Kpad(n):=\min_{n'\ge n}K(n')$, which is nondecreasing and unbounded".

---

## Candidate issues checked and withdrawn

* **Statuses on `thm:soi:transfer`, `rem:soi:encoding`, `prop:soi:closure`(d) and `cor:soi:circuitBayes`.** The item headers in the `sfi` record omit "computed", but its claims table (§15) lists the computations: `rb3` for Thm 5.1 and Rem 5.4; `c1`, `rb1` for Prop 6.1(a), (b), (d); `rA1`, `rb4` for Cor 10.2. The paper's statuses match §15.
* **`thm:soi:circuit`(ii) cites an $O(T\log T)$ simulation (Pippenger–Fischer) where the record recalls $O(T^2)$.** Both are standard. `bib/bib-report.md` lists `pippenger1979relations` as "citable for the $O(T\log T)$ circuit simulation", and only the existence of a polynomial is used.
* **`thm:soi:sandwich` adds "with time-constructible nondecreasing budgets".** This is a hypothesis taken from the earlier report's Lemma E.19 and Prop E.21. It weakens the claim and does not strengthen it.
* **`prop:soi:presburgerCharged`(a) omits the record's "for arbitrary $s$ under reading (short)".** This also weakens the statement. The (short) variant is kept, correctly marked, in the proof.
* **The numbering of the earlier report and the companion paper.** All cited numbers resolve to the intended items (see "How the review was done").

## Proofs checked line by line (no issue beyond those above)

* **Appendix A.**
  * `lem:setting:measurable`; the proof of `rem:setting:versions` (Craig's two-reading parse, padding by Lemma E.12);
  * `prop:basic:structure`(a)–(g), `prop:basic:geometric`, `prop:basic:dempster`;
  * `lem:basic:demuth` (the $(k+2)$-bit index), `thm:basic:inc` (the machine $G_\alpha$, the decomposition, Solovay reducibility, and $\Inc_0<1$ for the lemma), `prop:basic:oracle`;
  * `thm:basic:dominance`(i)–(iv), `prop:basic:invariance`, `prop:basic:background`, `thm:basic:translation` (push-forward and pull-back), `cor:basic:vocabulary`;
  * `prop:basic:exceptions`, `prop:basic:mistakes`(a)–(c), `thm:basic:merging` (Steps 1–4, Tonelli, Pinsker in bits), `cor:basic:threeloss`, `prop:basic:lower`;
  * `lem:basic:fresh`, `prop:basic:chain` (the auxiliary semimeasure $Q_S$), `thm:basic:nocoding` (colouring and coin constructions), `prop:basic:wholetheory`, `prop:basic:tape`;
  * `prop:basic:cr`, `prop:basic:crorder`(a), (b) (the identities of Step 1, disjointness, the two lower bounds, the choice of $j_i\le J$, additivity over pairs), `prop:basic:graded`(a)–(e) (the Möbius sums $0$, $-\frac12$, $+1$), `prop:basic:crmix`, `prop:basic:gradedgap`;
  * `lem:basic:majority`, `prop:basic:limitpost`, `prop:basic:limits`, `prop:basic:textinformant`, `prop:basic:structures` (the model $\mathbb N\sqcup\{\star\}$), `prop:basic:noncomplete`, `prop:basic:incomplete` (the diagonal argument), `cor:basic:localdefect`;
  * `thm:basic:order`(a), (b) (cells $m_1,\dots,m_4$, Jensen), `thm:basic:kolmogorov` and the proof of `prop:basic:mistakes`(c);
  * `prop:basic:generative`, `prop:basic:demski`(a)–(d), `prop:basic:domination`(a)–(c).
* **Appendix B.**
  * `lem:soi:mixture`, `lem:soi:maps`(i)–(iv);
  * the proofs of `thm:soi:coinfree`, `thm:soi:onetape` (the constant $2^{|r_{\rm ps}|}+2^{c_B}$, the case $D=\emptyset$) and `cor:soi:closed`;
  * `thm:soi:penalty` (membership bound via $(\lvert\chi\rvert+1)^{a'}\le2^{a'}t(\lvert\chi\rvert)$, the empty $D$), `prop:soi:classes`, `prop:soi:chain`;
  * `thm:soi:transfer`, `cor:soi:transfer`, `prop:soi:price`, `rem:soi:encoding`, `prop:soi:closure`;
  * `lem:soi:productive` (Rosser relative to $S$, both cases via (O)), `prop:soi:independent` (coin-free diagonal; one-tape density argument with the summed bound $\le2\varepsilon$), `prop:soi:noRE`, `rem:soi:product`;
  * `prop:soi:computability`(a)–(c′), `prop:soi:pathwise` (global-schedule filter);
  * `prop:soi:kt`, `thm:soi:domination`, the proof of `cor:soi:onesided` ($c_\tau=c+c_1+c_\bot$), `thm:soi:diagonal` (fixed point, tie rule, $H_0$ decides $s_n$, $P^\ast$ a computable predictor), `prop:soi:freededuction`, `thm:soi:onetapetime`;
  * `thm:soi:sandwich` (constants $\lvert\zeta\rvert+14$, $2\lvert\zeta\rvert+29+\lvert\varphi^b\rvert$), `rem:soi:lengths`(iii) (exact-length form, $c<c_{\rm FR}/\kappa$);
  * `prop:soi:presburger`(a)–(c), `prop:soi:presburgerCond`, `prop:soi:presburgerCharged`(a)–(c) (thresholds $\log(c_k)/(c-c'')$, readings (max)/(short), $H>2^{c''m}$);
  * `thm:soi:circuit`, `cor:soi:circuitBayes`.

## Files written

* `paper/review/math-a.md` (this file) and `paper/review/math-a.json`.
* The scratch scripts are `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/mathA/numchecks.py`, with output `numchecks.out`, and the label tables `AI_labels.txt` and `P1_labels.txt` in the same folder.
* No section file was edited. No git command that changes repository state was run.
