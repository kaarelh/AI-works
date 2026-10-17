# Mathematics review B: §5 (logic), §8 (terms), Appendices C (app-logic) and F (app-terms)

*Reviewer B, 2026-10-17. Scope: `paper/sections/logic.tex`, `terms.tex`, `app-logic.tex`, `app-terms.tex`, against the final records `research/tracks/logic/notes-final.md` and `research/tracks/terms/notes-final.md` (with their referee-driven corrections), the synthesis `research/notes-final.md` (§1 H2, H4, H5, H9, H14; §2.8; §3) and `research/final-check.md` (items 5, 7, 8, 11, 18 bear on these sections). Every statement, hypothesis, quantifier, constant and status line in the four files was compared with the record item named in its `\src`. Each proof in Appendices C and F was re-read against the record's proof, and several were checked independently (see the verification log).*

**Build.** Full build under the lock (`flock /tmp/claude-0/paper-build-sai.lock ./build.sh`): 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels, 0 overfull boxes over 10pt, 230 pages.

**Overall.** Section 5 and Appendix C are faithful to the logic record. I found no wrong statement, hypothesis or status there, only four minor wording points. Section 8 and Appendix F are faithful to the terms record item by item, but they have two major problems:
* **Issue B1.** The fit-class results for finite and observational theories need $B=\emptyset$, or at least a background true in the models the proofs build. The paper's own conventions allow any decidable literal-setting $B$, including one with theoretical symbols. Under them, parts (iii)–(v) of the dilemma theorem and several appendix statements are false as written. Concrete counterexamples are given below.
* **Issue B2.** A main-text sentence turns the record's "no finite theory in $\{=\}$ or a monadic extension" into "no finite first-order theory without a function symbol". That is false: a binary relation is enough. It also cuts against the section's own thesis that relations pay.

No issue is fatal. Counts: 0 fatal, 2 major, 9 minor.

Process-vocabulary grep on the four files: clean. "synthesis" occurs only inside `\src{...}`, which prints nothing. Every theorem-like environment carries `\status` and `\src`. No model names. Credit to Hänni's working notes appears only in two neutral footnotes.

---

## Issues

### B1. [major] The fit-class results for finite and observational theories silently need $B=\emptyset$

**Location.**
* `terms.tex`, `thm:terms:dilemma` (iii), (iv), (v), with `def:terms:obs` and `def:terms:literal`, and the prose of `sec:terms:craig` (l. 81) and `sec:terms:ontology` (l. 94).
* `app-terms.tex`:
  * `cor:terms:table`, rows 3 and 4;
  * `prop:terms:a1fit`, the consistency claim and the fit class;
  * `thm:terms:binary` (i), (ii) "consistent with $\Gamma_{f_{\mathcal V}}$", and (iv);
  * `prop:terms:ontology`(a);
  * `cor:terms:freededuction`.

**Problem.** These statements are made for the general background of the section. `def:terms:obs` says "$B$ may contain theoretical symbols". `def:terms:literal` and the preamble of `app:terms` assume only the literal setting: $R\notin B$, and the $t_w$ are distinct in some model of $B$. The preamble also says "'consistent' means consistent with $B$, and $\Cn$ has $B$ built in", and `setting.tex` l. 11 says "'$\Gamma$ proves $\varphi$' means $B\cup\Gamma\vdash\varphi$".

Every proof, however, establishes consistency by exhibiting a model without $B$: $(\mathfrak T,\mathsf C^{\mathfrak T},R)$ for the relation version and $\mathfrak U$ for the observational one. The regularity theorem is likewise applied to $T$ alone. With a nonempty admissible $B$, the statements fail:
* **$B_1:=\{\forall z\,\neg\,\mathtt s_1\mathtt s_1z=z\}$.** This is observational, $R$-free and decidable, and true in $\mathfrak T$, so it is admissible. Under $B_1$, $\mathrm{Std}$ holds everywhere and every $\theta_2(a,b)$ holds vacuously. This is exactly the argument of `prop:terms:ontology`(b).
  * $T^O_{\mathcal V}\cup B_1$ proves $\forall x\,R(x)$ and $\forall x\,\neg R(x)$, so it is inconsistent. So `thm:terms:binary`(ii) ("$T^O_{\mathcal V}$ … consistent with $\Gamma_{f_{\mathcal V}}$", with $B$ built in) and the observational half of (iv) fail.
  * The translated output axioms of $A^O_{\mathcal M}$ in `prop:terms:a1fit`, $\theta_2(t_w,\mathtt s_0t_{\varsigma_0})\to R(t_w)$ and its twin, also become $R(t_w)$ and $\neg R(t_w)$. So "$A^O_{\mathcal M}\cup\Gamma_{f_X}$ is consistent" fails, and the paper's proof of the (a1) fit class of observational hypotheses no longer applies.
  * So the sentence "Observational hypotheses, and already finite observational theories, fit what all hypotheses fit" in `thm:terms:dilemma`(iii) is not proved for such $B$.
* **$B_2$:= the $R$-free part of $T^{\mathsf C}_{\mathcal V}$** (its rules and halting axioms, with binary $\mathsf C$), together with $\forall x\,(P_1x\leftrightarrow\exists z\,\mathsf C(x,0\,\mathrm{st}(\mathrm{start})\,z))$ and the tag-1 twin for $P_2$. This is finite, decidable, consistent (it holds in $(\mathfrak T,\mathsf C^{\mathfrak T})$ with $P_1,P_2$ so defined) and $R$-free, and the $t_w$ are distinct in that model, so it is admissible.
  * The theory $T:=\{\forall x\,(P_1x\to Rx),\ \forall x\,(P_2x\to\neg Rx)\}$ is finite, uses only $\LO$ and unary predicates, and is compatible with the named structure. Yet $B_2\cup T$ proves exactly the literals of a decidable, possibly non-regular, $X$ (the derivations of `thm:terms:binary`(iii)).
  * $B_2\cup T$ has the model $(\mathfrak T,\mathsf C^{\mathfrak T},P_1,P_2,R:=X_{\rm acc})$, so it proves no $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$-sentence false in $\mathfrak T$.
  * This refutes, as written, `thm:terms:dilemma`(iv) ("fits exactly the regular regularities … also with free deduction"), `cor:terms:table` row 4 under its standing assumptions, and `prop:terms:ontology`(a), which says "proves", that is, with $B$.
* **$B_4:=\{\exists z\,\mathtt s_1\mathtt s_1z=z\}$.** This background shares no symbol with the hypothesis except $\mathtt e,\mathtt s_0,\mathtt s_1$. It is observational, $R$-free and decidable, and $\mathfrak U$ is a model of it with distinct $t_w$, so it is admissible.
  * $T'':=\{(\exists z\,\mathtt s_1\mathtt s_1z=z)\to\varphi:\varphi\in T^O_{\mathcal V}\}$ is a finite observational theory. It is compatible with the named structure: $\ThT$ refutes the antecedent, so $T''\cup\ThT$ holds in $\mathfrak T$.
  * Yet $B_4\cup T''\vdash T^O_{\mathcal V}$, and $B_4\cup T''$ is consistent ($\mathfrak U$ as in `thm:terms:binary`(ii)). So $T''$ fits every decidable $X$.
  * So (iv) fails even if $B$ is required to avoid the hypothesis's own symbols.

**Evidence.**
* The record states the restriction only where it tabulates. `terms` Cor 5.4: "the fit classes of **finite** theories ($B=\emptyset$; …)". `terms` §6: "In this section $B=\emptyset$". The proofs of Prop 4.3, Thm 4.6 and Prop 4.7 (record §4) build models of the hypothesis alone.
* `cor:terms:ontology` in the paper does say "with $B=\emptyset$". `cor:terms:table`, `thm:terms:binary`, `prop:terms:a1fit`, `prop:terms:ontology` and the dilemma theorem do not.
* A finite sanity check of the $B_1$ mechanism (seeded script, scratchpad `mathb/b1_counter.py`): in 128 random structures satisfying $B_1$, $\theta_2(a,b)$ was true for all $a,b$, with 0 exceptions.

**Fix.** State $B=\emptyset$ wherever fit classes of finite or observational theories are claimed:
* in `thm:terms:dilemma` (iii)–(v), for example "in (iii)–(v), $B=\emptyset$";
* in `cor:terms:table` rows 3–4;
* in `prop:terms:a1fit`, `thm:terms:binary` and `cor:terms:freededuction`;
* in `prop:terms:ontology`(a), or write "$T\vdash$" there instead of "proves";
* in the prose of `sec:terms:craig` and `sec:terms:ontology`.

Alternatively, state the weaker sufficient conditions. For the constructions (`prop:terms:a1fit`, `thm:terms:binary`): $B$ is true in the model used ($\mathfrak T$ expanded, respectively $\mathfrak U$) and uses none of the hypothesis's own symbols. For (iv) and `prop:terms:ontology`(a): $B$ is in $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$ and $B\subseteq\ThT$. $B_4$ shows that symbol-disjointness alone is not enough. `thm:terms:horn`, `thm:terms:padded` and `thm:terms:KCV` handle a general $B$ correctly and need no change.

### B2. [major] False strengthening: "no finite first-order theory without a function symbol has the same consequences"

**Location.** `terms.tex`, `sec:terms:finite`, l. 99, the sentence introducing `prop:terms:ramsey`.

**Problem.** The main text says that no finite first-order theory without a function symbol has the same $\{=\}$-consequences as $\{\Infn m:m\ge1\}$. This is false. Take the language $\{=,<\}$, which has no function symbol, and the finite theory "$<$ is irreflexive and transitive and $\forall x\exists y\,x<y$".
* It has no finite model, so it proves every $\Infn m$.
* It has the model $(\mathbb N,<)$, and all infinite sets are elementarily equivalent in $\{=\}$, so its $\{=\}$-consequences are exactly those of $\{\Infn m\}$.

The claim also undercuts the section's conclusion that polyadic relations (not only functions) are what pay.

**Evidence.**
* `terms` Prop 7.1(c): "no finite first-order theory in $\{=\}$, nor in any monadic extension, has them". `app-terms.tex`, `prop:terms:ramsey`(c), has the correct wording.
* Brute force (scratchpad `mathb/t1_order.py`): the three axioms have 0 models of every size 1–4.

**Fix.** Replace the clause with "and no finite first-order theory in pure equality, or with unary predicates added, has the same consequences". Optionally add that a finite theory with a binary relation (a strict order without a greatest element) also does, in line with the section's thesis.

### B3. [minor] "more slowly than every computable unbounded function" is false without "nondecreasing"

**Location.** `terms.tex`, `sec:terms:finite`, l. 99 ("$\Kpad(n)\pm c$, which tends to infinity, though more slowly than every computable unbounded function").

**Problem.** Let $u$ be computable and unbounded but $0$ on the odd numbers. Then $\Kpad(n)>u(n)$ for all large odd $n$. This is the same defect as the logic record's referee issue m3, which §5 fixed ("computable unbounded nondecreasing", `logic.tex` l. 50).

**Evidence.** `terms` Thm 6.2(b): "$o(G(n))$ for every computable unbounded nondecreasing $G$". `app-terms.tex`, `thm:terms:infinity`(b), says "nondecreasing".

**Fix.** Insert "nondecreasing".

### B4. [minor] The proof line of `thm:terms:dilemma`(iii) omits the inputs of its status

**Location.** `terms.tex`, proof of `thm:terms:dilemma`, "(iii) is \cref{prop:terms:eliminate,prop:terms:a1fit,thm:terms:binary}."

**Problem.** Part (iii) rests on:
* (F1);
* $\cplx{APSPACE}=\cplx{EXPTIME}$, through `prop:terms:a1fit` and the (a1) part of `thm:terms:binary`;
* the one-tape simulation, through `lem:terms:twostack`;
* the earlier report's Props E.21 and E.23.

The proof lines for (ii) and (iv) list their "given" results; the one for (iii) lists none.

**Evidence.** `terms` §8, Statuses: "(iii) proved under (F1), given SD Thm 3.1, Prop 4.3, Cor 4.4, the one-tape simulation and CKS".

**Fix.** Append ", under \cref{ass:soi:F1}, given the one-tape simulation and $\cplx{APSPACE}=\cplx{EXPTIME}$" to the (iii) clause.

### B5. [minor] Derivation length for the binary-relation theories: the certificate length is dropped

**Location.** `terms.tex`, `sec:terms:craig`, l. 81: "with derivations whose length and line size are linear in the time and space of a one-tape simulation of $\mathcal V$ plus the input length".

**Problem.** The derivation from certificate $z$ has $O(N_{\rm run})$ lines (observational: $O(N_{\rm run}+\ell)$). Here $N_{\rm run}=O(T_1+|x|+|z|)$, and the line size is $O(\ell+1)$ with $\ell=O(S_1+|x|+|z|)$. The certificate length enters both bounds.

**Evidence.** `terms` Lemma 4.5(iii) and Thm 4.6(iii); `app-terms.tex`, `lem:terms:twostack`(iii) and `thm:terms:binary`(iii).

**Fix.** Write "plus the lengths of the input and the certificate".

### B6. [minor] $\theta_2$ in the main text uses a bound variable that is not marked fresh

**Location.** `terms.tex`, `sec:terms:craig`, l. 81: "$\theta_2(a,b):=\forall y\,(\mathtt s_1\mathtt s_1y=y\to\cdots)$ … with quantifiers relativised to $\mathrm{Std}(y)$".

**Problem.** The record corrected exactly this. A bound variable that coincides with a variable of the formula into which $\theta_2$ is substituted captures it. With $\theta_2$'s variable named like the output rule's certificate variable, the derivation of $R(t_{0011})$ broke. The appendix uses $y_\theta$ and states the freshness requirement; the main text writes $y$, and the same sentence reuses $y$ in $\mathrm{Std}(y)$.

**Evidence.** `terms` §4.2 and §11 item 14 (referee B2; `rb1_two_stack.out` Part D); `app-terms.tex` l. 101–105.

**Fix.** Write $\forall y_\theta$ in the main text and add "(with a fresh bound variable)", or point to the appendix definition.

### B7. [minor] A computed claim overstates its coverage: "five regular languages on all data with $|w|\le9$"

**Location.** `app-terms.tex`, the paragraph after `thm:terms:everyregular` (l. 256).

**Problem.** The checks cover two languages ($X_A$, $X_B$) on all 1023 data with $|w|\le9$, and three further languages (MOD3, END01 and a random 10-residual language) in an independent implementation on all 511 data with $|w|\le8$.

**Evidence.** `terms` §5.2, Computed: `t4_regular.out` Part A, "all 1023 data with $|w|\le9$"; `rb4` Part B, "all 511 data $|w|\le8$".

**Fix.** Write "two regular languages on all data with $|w|\le9$, and three more, independently, with $|w|\le8$", or "on all data with $|w|\le8$".

### B8. [minor] Two different quantities with near-identical names in one paragraph (§5.3)

**Location.** `logic.tex`, `sec:logic:pi1`, l. 87.

**Problem.** The paragraph uses two phrases for two different quantities:
* "every $\Pi_1^*$ sentence whose prior probability of being proved exceeds a uniformly random level" means $\Unif(O_\pi)>r$, which includes the inconsistent tapes;
* "every $\Pi_1^*$ sentence of prior probability of provability at least $2^{-k}$" means $\Bel_0(\pi)\ge2^{-k}$, the term defined in `setting.tex` l. 46.

The two quantities differ by $\Inc_0$. If the second phrase is read as $\Unif(O_\pi)$, the claim about $T_k$ becomes false whenever $2^{-k}\le\Inc_0$, since then every $\Pi_1^*$ sentence, false ones included, would qualify.

**Evidence.**
* Logic record Thm 3.1(ii): "contains every $\pi\in\Pi_1^*$ with $\Bel_0(\pi)\ge2^{-k}$".
* Thm 3.2: $A^{G_{\rm thr}}_r=\{\pi:\Unif(O_\pi)>r\}$.
* The record's own reading (l. 320) writes "probability of being proved" for $\Unif(O_\pi)$.

**Fix.** In the first sentence write "every $\Pi_1^*$ sentence $\pi$ with $\Unif(O_\pi)$ above a uniformly random level". In the last sentence write "with $\Bel_0(\pi)\ge2^{-k}$".

### B9. [minor] "the diagonal reports a different, unrefuted ticket" holds only in one case

**Location.** `logic.tex`, after `thm:logic:arith`, l. 68.

**Problem.** In the definition, $j^*_k$ is the least $j\ne j^\circ_k$ that $B\cup\re k$ does not refute *if $B\cup\re k$ is consistent and proves $\Lot^{\rm ar}_k$*. Otherwise it is simply the least $j\ne j^\circ_k$, which may be refuted; if $\re k$ is inconsistent with $B$, every ticket is. The sentence also says "the least ticket that $\re k$ refutes" where the definition has $B\cup\re k$.

**Evidence.** Logic record Thm 2.9(b); `app-logic.tex`, proof of `thm:logic:arith`, "The tickets".

**Fix.** "the true winner of lottery $k$ is the least ticket that $B\cup\re k$ refutes ($0$ if none); the diagonal reports as the loser a different ticket, one that $B\cup\re k$ does not refute whenever $B\cup\re k$ is consistent and proves $\Lot^{\rm ar}_k$, and that report is true."

### B10. [minor] The modified Demski prior: the main text drops "for the process as described"

**Location.** `logic.tex`, `sec:logic:lottery`, paragraph "Relatives", l. 56: "the modified Demski prior samples them …, and it too gives the lottery stream positive probability."

**Problem.** The claim holds only for the process as described in the secondary sources; the definition text of the original post was never read. The appendix keeps the qualifier ("for the process as described in those works"); the main text states it outright.

**Evidence.**
* Logic record §7: "[proved, for the process as described in `fundamentals` §10]".
* `bib/bib-report.md` §3 item 7: the post's own definition is unverified, and related-work sentences "must stay at the level of items 1–5".
* `app-logic.tex` l. 76.

**Fix.** Write "and, for the process as described in those works, it too gives the lottery stream positive probability (\cref{app:logic:lottery})".

### B11. [minor] Probabilistic learners: the success-probability threshold is missing

**Location.** `logic.tex`, l. 56: "randomised learners can succeed where deterministic ones cannot \citep{pitt1989probabilistic,ambainis1999probabilistic}".

**Problem.** For learners this holds only below a success-probability threshold. Above it, a probabilistic learner can be made deterministic, which is Pitt's result as recorded. The bibliography report's suggested sentence kept that qualifier. The qualifier also fits the mathematics here: the lottery's survival probability, $0.2888$, is below $1/2$, and `prop:logic:arity` is a derandomisation at high conditional probability.

**Evidence.** `bib/bib-report.md` l. 285–297: "that randomisation can succeed where determinism cannot, below a success-probability threshold, is familiar for learners …; keep the sentence qualitative".

**Fix.** Write "randomised learners can succeed where deterministic ones cannot, below a success-probability threshold \citep{…}".

---

## Items checked and found correct (no action)

**Section 5 and Appendix C, against the logic record.**
* `thm:logic:lottery` (a)–(d), including the computable-syntax clause and $0.288788$, which is outside the statement.
* `prop:logic:arity`, with the threshold $1/(r+1)$; the critical value was checked for $s\le12$ (`c6_revision.out` R6) and on 166 antichains.
* `cor:logic:Q1`, `prop:logic:true`, `prop:logic:core` and the instances, `prop:logic:horizon`, and `cor:logic:rate` (with "nondecreasing").
* `lem:logic:flexible`, `thm:logic:arith` (a), (b), and `cor:logic:false` (i)–(iii), including the $\prod_k1/N_k=0$ step.
* `thm:logic:thresholdtheories`, `thm:logic:threshold` (constant $2^{K(\Gthr)+c}$), `cor:logic:coding`, and `rem:logic:Wbound` (the repaired pair-indexed count).
* `cor:logic:onetrue`; `cor:logic:chaitin`, whose convention is named and whose three-valued identity is right; `prop:logic:normalised`, with the Markov count $2^{2m+K(m)+j+c}+2^{m+1}$ and the constant $1.45\ge1/\ln2$.
* `prop:logic:falsesigma` and `prop:logic:boundary`.
* `prop:logic:shape`, `thm:logic:soundness`, `prop:logic:unsound` and `thm:logic:soundnessPi1`, whose proof's consistency case analysis was re-done.
* `prop:logic:con`, with the corrected truth hypothesis and the counterexample $B=\PA+\neg\Con(\PA)$.
* `prop:logic:oldevidence`, `prop:logic:omega`, `prop:logic:gaifman`, `thm:logic:goedelomega` (normalisation by $1-\Inc_0$) and `rem:logic:closures`; part (c) quotes the earlier report's Thm 3.9(c1), (d1) correctly.
* `prop:logic:lines`, with its nonemptiness hypothesis, and `ex:logic:lines` (nine lines: 1+1+1+5+1).
* `thm:logic:thn` (a)–(c), `cor:logic:undecided`, `prop:logic:generic` and the open questions.

A check of my own: $\Cn$ has $B$ built in (`setting.tex` l. 11). So the class $\mathcal U$ of `thm:logic:soundness` and `thm:logic:soundnessPi1` is the class of $\Sigma_1$-unsoundness of $B\cup A_\omega$, as in the record's $M_A(D;X)$. The $\Sigma_1$-unsoundness claims for the arithmetic lotteries are consistent with it.

**Section 8 and Appendix F, against the terms record** (apart from issues B1–B7).
* `thm:terms:horn` (a)–(d) and its status; `lem:terms:recheck`, `lem:terms:unary` and `thm:terms:padded`.
* `cor:terms:table`'s table and separations, and `prop:terms:eliminate` (budgets $2\bar g'+m+31$ and $\bar g'+m+16$).
* `lem:terms:pairing`; the two-stack compile, both the certificate version and the corrected alternating version (start rule onto $l$, exact output rules); the Claim of Step 3.
* `lem:terms:EF`, `thm:terms:regular` (residual bound $\mathrm{ncl}_q+|\mathrm{Suf}_{\rm c}|$), `thm:terms:everyregular` (window $\max(k_X-1,1)$), and `prop:terms:conservativity`.
* `prop:terms:binaryobs`: 13 sentences, with truth and the case reduction checked by hand.
* `prop:terms:a1hard`; `lem:terms:monadic`; `thm:terms:infinity`; `rem:terms:named`, against fundamentals Prop 1.8(d); `prop:terms:bits`.
* `thm:terms:PA`, with `rem:terms:PAtruth` kept as a proof sketch; `thm:terms:KCV`, including (Ar) with the defining axiom for $<$; `rem:terms:onetape`; `prop:terms:ramsey`; and `prop:terms:factoring` ((d)'s corner argument).
* The earlier report's label numbers cited in §8 and Appendix F match its `main.aux`: Def E.18, Lemmas E.11, E.12, E.22, Props E.21, E.23, Thm 6.14, Cor 6.17, Thm 3.9, Prop 3.12, Prop B.10.

---

## Verification log

* **Restart check.** At the start `paper/review/` did not exist, so there was no partial output to recover. A stub of this file was written first and extended after each part.
* **Read in full.**
  * `research/00-brief.md`.
  * `research/final-check.md`.
  * The synthesis `research/notes-final.md`: §0, §1 H1–H15, §2.8, §3, §5.3 (the plan for §5, §8 and Appendices C, F), §6.3–§6.4.
  * The logic record `notes-final.md`: §0–§7, §12, and the §9 tables.
  * The terms record `notes-final.md`: §0–§11.
  * `paper/sections/logic.tex`, `terms.tex`, `app-logic.tex`, `app-terms.tex`, in full.
  * `bib/bib-report.md` §3.
* **Read in part.**
  * `setting.tex` (definitions of $\Cn$, "proves", $\Bel_0$, $\UA(\mathcal C;D)$, $\Exts$).
  * fundamentals Prop 1.8.
  * `CLAIMS.md` (rows flagged with stating constraints).
  * The earlier report's `main.aux` (label numbers).
  * `logic/checks/c6_revision.out` (R6).
* **Run** (scratchpad `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/mathb/`):
  * `checks.py` reproduces the quoted numbers:
    * $\prod_k(1-2^{-(k+1)})=0.2887881$;
    * $1/(5\log_214)=0.05253$ and $1/(5\log_25.385)=0.08234$;
    * $10^{6\cdot0.0823}\approx3.12$;
    * the Craig example at $n=24$: $N_{\rm cand}=134217724$, $L^*=26$, $\mathrm{ds}_T=376$, $\log_{10}$ of the Craig axiom size $\ge204.61$, the certificate axiom 795, the fast labeller 702;
    * the factoring minima, and $1/\ln2=1.4427\le1.45$.
  * `t1_order.py` (issue B2) and `b1_counter.py` (issue B1, seed 20261017).
* **Not done.** The thread scripts were not re-run; the record's computed claims were compared with its text and the one saved output named above. No literature was searched. No git command that changes repository state was run.
