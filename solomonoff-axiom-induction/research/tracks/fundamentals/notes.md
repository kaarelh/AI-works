# Thread `fundamentals`: definitions and basic theorems of Solomonoff axiom induction

*Thread record, 2026-10-15. The family studied here has the working name "Solomonoff axiom induction" (SAI); the final name is undecided and nothing below depends on it. Folder: `research/tracks/fundamentals/`; scripts in `checks/`, each seeded (20261016) with its output saved next to it. Notation: `../../NOTATION-draft.md` (binding); deviations and local symbols are listed in §13.*

**Statuses.** Every claim carries one of:
* **[proved]**: a full proof is given here;
* **[proved, given X]**: proved here from a cited result X, whose verification status is in §14;
* **[known: ref]** (verified reference) or **[known, unverified: ref]** (the reference could not be checked in this round; see §14);
* **[proof sketch]**, with the missing steps named;
* **[computed: script, item]**;
* **[conjecture]**, **[open]**;
* **[refuted]**: kept with its counterexample.

**Pointers.** "AI-paper" is `../axiom-induction/paper/main.pdf`, cited by printed numbers (read from its `main.aux`); its records are cited as model, universal, pa, TF (time-followup), SD. "P1" is SOI Paper 1 (`../solomonoff-function-induction/paper`, identical to `../solomonoff-operator-induction/paper`), cited by printed numbers read from its `main.aux`. Scout records are cited as scout F, S, L, N1 with their item numbers; other threads as `sfi` T3, `logic` T1, etc. Logarithms are base 2; $c, c', c''$ are constants depending only on the fixed universal machines, the coding of syntax and the background $B$.

**Web access.** The session's shared web-search budget was exhausted before this thread started, and WebFetch could not resolve any host. No reference was re-verified in this round; every citation carries the verification level recorded by the scouts (§14), and I designed the proofs so that few results depend on literature: the randomness of $\Inc_0$, the a.s. incompleteness of random theories above $\Q$, and the non-identifiability results are proved here from textbook facts only.

---

## 0. Summary

**What this record contains.**
* §1: the definitions in paper order, including a proof that deciders, enumerators and polynomial-delay enumerators give the same coin-free and Kolmogorov versions (Prop 1.8), and a new separation of finite axiomatisations from r.e. ones ($K_{\rm fin}-K_A$ unbounded).
* §2–§10: scout F's F1–F7, F10–F25, F26(a)(b), F27, N1's N10 and scout L's Observation L2, each re-verified line by line and rewritten. Changes against scout F: several proofs no longer depend on literature (Thm 3.2, Prop 8.6, Prop 8.7 via a majority-vote lemma, Lemma 8.0); F24(a)'s "strict extension" claim is now proved (it was a proof sketch); F12 is downgraded to Solovay's factor 3; F16's integrability step is written out; the CR order dependence is proved on an explicit law.
* §11: four of scout F's five open questions are settled or reduced:
  * **Q5 (answered: yes).** The normalised cumulative loss of $M_A$ depends on the reveal order, already on two data $\{(a,1),(a\vee c,1)\}$; and two orders of the same $2n$ data can differ by at least $2^{-c}n$ bits (Thm 11.1).
  * **Q4 (answered).** $\log(M_A^{1/2}(D)/M_A(D))$ can be $k\log(m/2)-c$ on $k$ data, which is linear in $|D|$ and within $2|D|+O(\log)$ of the upper bound $K(\dom D)+|D|+c$ (Prop 11.2).
  * **Q7 (answered).** The Kolmogorov predictor can err or abstain $2^{k-K(m)-c}-1$ times on data with $K_A=k$, against $\le k+c$ mistakes for the Bayes predictor; the upper bound is $2^{k}$ (Thm 11.3).
  * **Q6, Q2 (open, reduced).** Q6 for random literal sets is P1 Question 3.14 for binary labels; Q2 is equivalent to a question about probabilistic versus deterministic enumeration of r.e. sets (Props 11.4, 11.5).

**Claims and statuses** (numbers are this record's; scout F's item in brackets).

| item | statement (short) | status |
|---|---|---|
| Prop 1.8 | deciders, enumerators, polynomial-delay enumerators: same $W_A$, $K_A$ up to $O(1)$; $K_A\le K_{\rm fin}+c\le K(\psi_D)+c$; $K_{\rm fin}(D_n)-K_A(D_n)\ge\Kpad(n)-c$ on an explicit family | proved; (b) given TF Lemma 2.1 under TF's (S) |
| Prop 2.1 [F1] | measurability; semimeasure inequality with defect $=\Indep$; entailed data free; order independence; $0<M_A(\emptyset)=1-\Inc_0<1$; $M_A^3$ additive; containment functional | proved; computed (c1 A1–A4) |
| Prop 2.2 [F2] | PR updating = geometric conditioning of $\Bel_0$; total monotonicity; coherent bracketing | proved; computed (c1 A5–A7); rule names known, unverified |
| Prop 2.3 [F18] | CR updating = Dempster conditioning | proved; computed (c1 A8) |
| Prop 3.1, Thm 3.2 [F3] | $M_A(D)=\Unif(O_{\psi_D})-\Inc_0$; $\Inc_0$ not computable, Solovay complete, Martin-Löf random; $M_A$ not lsc | proved; randomness given Chaitin's theorem and the Levin–Schnorr characterisation (known, unverified) |
| Prop 3.4 [F3(d)] | values and conditionals $\emptyset'$-computable; lsc relative to $\Inc_0$ | proved |
| Thm 4.1 [F4] | mixture identity; $M_A\ge2^{-K(\nu)}\nu$; instances (deterministic theories, consistent labellers, lsc mixtures, coin facts) | proved |
| Props 4.2, 4.3 [F5, F6] | machine invariance; background as prior shift | proved |
| Thm 4.4, Cor 4.5 [F7, F7′] | faithful translations change $M_A,W_A$ by $2^{\pm(K(\tau)+c)}$; new vocabulary changes old-vocabulary weights by $O(1)$ | proved |
| Thm 5.1 [F13] | loss $\le-\log\Unif_A(\Ext T)\le-\log\mm(\Ext T)+c\le K_\equiv(T)+c$ on any sequence $T$ decides | proved |
| Prop 5.2 [F14] | laws plus exceptions; theory-machine laws; coin facts | proved |
| Prop 5.3 [F15] | Bayes argmax: $\le K_\equiv(T)+c$ mistakes; Kolmogorov predictor: $\le2^{k}$ errors or abstentions | proved; computed (c3) |
| Thm 5.4 [F16] | three-valued merging $\sum_t\Ex d_t\le K(G)+\log M_A(\emptyset)$, integrability written out | proved; computed (c1 A15) |
| Cor 5.5 | three-valued loss $\le-\log\Unif_A[T]\le K_\equiv(T)+c$ on the trichotomy of $T$ | proved |
| Prop 5.6 [F17] | $L_A(D)\ge K(\text{labels}\mid\dom D)-c$; fair coins cost $n-c$ | proved |
| Prop 6.1 [F10] | coding lower bound; chain $2^{-K_A}\le W_A\le2^cM_A\le2^{K(S)+c}2^{-K_A}$ | proved |
| Thm 6.2 [F11] | no coding theorem: $\log d$ gap on two literals; $M_A/W_A$ unbounded; (ii), (iii) proved directly | proved; computed (c4) |
| Rem 6.3 | P1 Cor 4.10, Prop 4.7 transfer to literal data; no computable witnesses of large gaps | proved (transfers given `sfi` T5) |
| Prop 6.4 [F12] | $K_\equiv=K_{\rm enum}(\Cn T)\pm c$; $K_\equiv\le3(-\log\mm_\equiv)+O(\log)$ | (a) proved; (b) given Solovay 1977 (known, unverified); downgraded from factor 2 |
| Prop 7.1 [F19] | $M_A^{\rm nc}$ is a plausibility, $\ge2^{-c}$ on consistent data | proved; computed (c1 A9, A10) |
| Prop 7.2 [F20] | Dempster predictor loses $\ge\log\frac1{1-\varepsilon_\emptyset}$ per non-entailed datum; order dependence on an explicit law | proved; computed (c2 B1, B2); order dependence for $M_A$ itself open |
| Prop 7.3 [F21] | graded CR: weak semimeasure, $\ge M_A$, charges entailed data, not invariant under splitting a conjunction | proved; computed (c1 A12) |
| Prop 7.4 [N1 N10] | CR predictor = mixture of PR and a weak-theory component | proved; computed (c1 A11) |
| Lemma 8.0 | majority vote: positive-measure randomised separation gives a computable one | proved |
| Prop 8.1 [F22] | limit posterior in total variation, rate $\delta_n/a_n$ | proved; computed (c1 A13) |
| Prop 8.2 [F23] | complete decidable truths identified up to equivalence; uniform trichotomy | proved |
| Prop 8.3 [F24] | incomplete truths: two-valued limit = prior on extensions, three positive shares; the most probable class can be a strict extension (for all but finitely many $T^*$ of a family); three-valued data identify $[T^*]$ | proved; computed (c1 A14) |
| Prop 8.4 [N1 N12] | no learner identifies consistent r.e. theories from text (Gold's argument) | proved; known in substance (Gold 1967, unverified) |
| Prop 8.5 [F25] | computable structures: loss $\le K(\mathfrak M)+c$; basic one-tape ω-gap | proved |
| Prop 8.6 [F26(a)(b)] | non-decidable complete truths: unbounded loss; $K(\text{labels}_n\mid n)-c\le L_A(D_n)\le n+K(n)+c$ | proved |
| Prop 8.7 [F27] | random theories above $\Q$ a.s. incomplete; random labellers a.s. fail consistent guessing | proved, given the representability of computable sets in $\Q$ and the diagonal lemma (standard) |
| Prop 9.1 [§2.9] | generative variant: supports; reweighting; question conditioning; identification of $\Th(T^*)$ | (ii), (iii) proved; (i), (iv) proof sketch |
| Prop 10.1 [L2] | Demski's process: complete a.s., no independent outcome, oracle needed; $M_A$ keeps independent mass and gives incomplete r.e. theories positive class probability | proved for the process as described in secondary sources; attribution known, unverified |
| Thm 11.1 [Q5] | normalised loss of $M_A$ is order dependent; linear gap | proved; computed (c2 B3, B4) |
| Prop 11.2 [Q4] | graded/PR gap $\ge k\log(m/2)-c$; upper bound $K(\dom D)+|D|+c$ | proved; computed (c2 B5) |
| Thm 11.3 [Q7] | Kolmogorov predictor: $2^{m}-1$ errors or abstentions with $K_A\le m+K(m)+c$ | proved; computed (c3) |
| Prop 11.4 [Q6] | partial domination with slack $K(S)$; Q6 for literal sets ⟺ P1 Q3.14 (binary labels) | proved (equivalence given `sfi` T5); Q6 open |
| Prop 11.5 [Q2] | $\Unif_A[T]\ge2^{-c}\mm_\equiv(T)$; Q2 ⟺ an enumeration question for r.e. sets; factor-3 chain | proved; chain given Solovay (known, unverified); Q2 open |
| Q1 | does $\Unif(E_\infty)>0$ imply an r.e. theory proves $D_\infty$? | answered in `logic` T1 (no in general) |
| refuted (scout F's self-checks, re-checked; §12) | "$M_A$ is lsc"; "$M_A^{\rm nc}$ is a semimeasure"; "graded CR is a reweighting of PR"; "a coding theorem holds for single sentences"; "the most probable limit class is $[T^*]$" | refuted, with counterexamples (Thm 3.2, Prop 7.1(a), Prop 7.3, Thm 6.2, Prop 8.3(b)) |

---

## 1. Definitions

### 1.1 Language, background, data

**Definition 1.1 (setting).**
* $\mathcal L$ is a countable first-order language with equality and computable syntax; $\Sent:=\Sent_{\mathcal L}$; $\vdash$ is classical first-order derivability in a fixed sound and complete calculus (derivation size plays no role in this record).
* The **background** $B\subseteq\Sent$ is decidable and consistent; default $B=\emptyset$. (An r.e. background is equivalent to a decidable one by Craig's trick; decidability only makes proof search from $B$ effective.)
* $\Cn(\Gamma):=\{\varphi:B\cup\Gamma\vdash\varphi\}$. $\Gamma$ is *consistent* if $B\cup\Gamma$ is. $\varphi^1:=\varphi$, $\varphi^0:=\neg\varphi$. $\Gamma$ *decides* $\varphi$ if $B\cup\Gamma$ proves $\varphi$ or $\neg\varphi$.
* A **data set** is a finite partial function $D:\Sent\rightharpoonup\{0,1\}$ (label 1 = true); a **three-valued** data set maps into $Y_3=\{1,0,\iota\}$ ($\iota$ = independent). $D^\pm:=\{\varphi^{D(\varphi)}:D(\varphi)\in\{0,1\}\}$; $\psi_D:=\bigwedge D^\pm$ in a fixed canonical order ($\top$ if empty). $D$ is *consistent* if $B\cup D^\pm$ is. $D+(\varphi,y)$ is defined for $\varphi\notin\dom D$.
* A **reveal sequence** $(\varphi_t,y_t)_{t\le n}$ is *consistent* if $D_n:=\{(\varphi_t,y_t):t\le n\}$ is a partial function; $D_t$ are its prefixes. An infinite stream $D_\infty$ has $D_\infty^\pm:=\bigcup_nD_n^\pm$.
* **Conditionals.** For $\nu$ from data sets to $[0,1]$: $\nu(y\mid D,\varphi):=\nu(D+(\varphi,y))/\nu(D)$ for $\varphi\notin\dom D$ ($0$ if $\nu(D)=0$), and $\nu(y\mid D,\varphi):=\ind[y=D(\varphi)]$ for $\varphi\in\dom D$ (P1's repeated-input convention, P1 Def 3.1).

*Remark.* This is P1's data format with inputs $X=\Sent$. The data $(\varphi,1)$ and $(\neg\varphi,0)$ are different (different sentences) with the same content; Prop 2.1(c) shows that weights depend only on content. Scout F allowed non-functional data sets; with partial functions, a sentence with two labels is excluded by format rather than by weight $0$, and nothing else changes.

### 1.2 Theory machines

**Definition 1.2 (theory machine).** A **theory machine** is a c.e. set $G\subseteq\{0,1\}^*\times\Sent$ ("after reading $w$ from the tape, emit $\chi$"). For a finite $w$ put $A^G_w:=\{\chi:(v,\chi)\in G,\ v\sqsubseteq w\}$, and for a tape $\omega\in\{0,1\}^\infty$ put $A^G_\omega:=\bigcup_nA^G_{\omega_{1:n}}$, the axioms emitted on $\omega$. Let
$$O^G_\chi:=\{\omega:B\cup A^G_\omega\vdash\chi\},\qquad C^G:=\{0,1\}^\infty\setminus O^G_\bot,\qquad E^G_D:=O^G_{\psi_D}\cap C^G .$$
* The **law** of $G$ is $\nu_G(D):=\Unif(E^G_D)$: the probability that the random theory is consistent and proves every datum.
* The **three-valued law** is $\nu^3_G(D):=\Unif(E^{3,G}_D)$ with $E^{3,G}_D:=E^G_D\cap\bigcap_{D(\varphi)=\iota}\big(\{0,1\}^\infty\setminus(O^G_\varphi\cup O^G_{\neg\varphi})\big)$: in addition it decides no $\iota$-labelled sentence.
* $(G_i)$ is a fixed effective enumeration of the c.e. subsets of $\{0,1\}^*\times\Sent$; $K(G):=\min\{K(i):G_i=G\}$ and, for a law $\nu$, $K(\nu):=\min\{K(i):\nu_{G_i}=\nu\}$.

No consistency condition is imposed on $G$: emitting more axioms is always allowed, and consistency is a property of the output, a random event. This is the difference from P1's function machines (P1 Def 3.6), whose triples must be consistent.

**Lemma 1.3 (measurability and the basic form) [proved].**
(a) $O^G_\chi=\bigcup\{[w]:B\cup A^G_w\vdash\chi\}$ is an effectively open class, uniformly in an index of $G$ and in $\chi$; hence $\Unif(O^G_\chi)$ is left-c.e., uniformly.
(b) $C^G$ is closed (a $\Pi^0_1$ class) and $O^G_\bot\subseteq O^G_\chi$ for every $\chi$.
(c) $\nu_G(D)=\Unif(O^G_{\psi_D})-\Unif(O^G_\bot)$, and $E^{3,G}_D$ is Borel.

*Proof.* (a) If $B\cup A^G_\omega\vdash\chi$, a derivation uses finitely many axioms $\chi_1,\dots,\chi_r\in A^G_\omega$, each emitted under some prefix of $\omega$. The prefixes of $\omega$ are linearly ordered, so the longest of them, $w$, has $\chi_1,\dots,\chi_r\in A^G_w$, and every $\omega'\sqsupseteq w$ has $B\cup A^G_{\omega'}\vdash\chi$. Conversely $[w]\subseteq O^G_\chi$ whenever $B\cup A^G_w\vdash\chi$. The set of pairs $(w,\chi)$ with $B\cup A^G_w\vdash\chi$ is c.e. (enumerate $G$ and all derivations; $B$ is decidable). (b) $C^G$ is the complement of an effectively open class. An inconsistent set proves everything. (c) $E^G_D=O^G_{\psi_D}\setminus O^G_\bot$ with $O^G_\bot\subseteq O^G_{\psi_D}$; $E^{3,G}_D$ is $E^G_D$ intersected with finitely many closed classes. ∎

**Examples.** (i) A deterministic r.e. theory $\mathsf W_e$: $G=\{(\epsilon,\chi):\chi\in\mathsf W_e\}$, with $\nu_G(D)=\ind[B\cup\mathsf W_e\text{ consistent and }\vdash\psi_D]$. (ii) Fair-coin facts on an atom family $(\alpha_j)_{j\ge1}$: $G=\{(w,\alpha_j^{w_j}):|w|=j\}$. (iii) A theory plus coin facts: the union of (i) and (ii). (iv) A finite mixture of finite theories $T_1,\dots,T_r$ with dyadic weights: $G=\{(w_j,\chi):\chi\in T_j\}$ for a prefix-free set $\{w_1,\dots,w_r\}$ with $2^{-|w_j|}$ the weights. The finite stand-ins of `checks/` are laws of this kind.

### 1.3 The universal theory machine and SAI

**Definition 1.4 (proof-requiring SAI).**
* $G_U:=\{(pw,\chi):p\in\dom V,\ (w,\chi)\in G_{V(p)}\}$: read a self-delimiting program, then run that machine on the rest of the tape. It is c.e. Write $A_\omega:=A^{G_U}_\omega$, $O_\chi:=O^{G_U}_\chi$, $E_D:=E^{G_U}_D$, $E^3_D:=E^{3,G_U}_D$.
  * If $\omega=p\omega'$ with $p\in\dom V$, then $A_\omega=A^{G_{V(p)}}_{\omega'}$: a pair $(p'w,\chi)\in G_U$ with $p'w\sqsubseteq\omega$ has $p'\in\dom V$ comparable with $p$, so $p'=p$ by prefix-freeness, and $w\sqsubseteq\omega'$. If $\omega$ has no prefix in $\dom V$, $A_\omega=\emptyset$.
* **SAI** (unqualified) is $M_A:=\nu_{G_U}$; $M_A^3:=\nu^3_{G_U}$; $L_A:=-\log M_A$; $\Inc_0:=\Unif(O_\bot)$, the probability that the random theory is inconsistent.
* The **posterior** after $D$ with $M_A(D)>0$ is the law of $A_\omega$ under $\Unif(\cdot\mid E_D)$ (three-valued: under $\Unif(\cdot\mid E^3_D)$).
* **Trichotomy.** $\Bel_D(\chi):=\Unif(E_D\cap O_\chi)/\Unif(E_D)$, the posterior probability that the random theory proves $\chi$; $\Dis_D(\chi):=\Bel_D(\neg\chi)$; $\Indep_D(\chi):=1-\Bel_D(\chi)-\Dis_D(\chi)$. The prior **probability of provability** is $\Bel_0(\chi):=M_A(\{(\chi,1)\})=\Unif(O_\chi)-\Inc_0$ (not normalised: $\Bel_0(\top)=1-\Inc_0$), and $\Pl_0(\chi):=\Bel_0(\top)-\Bel_0(\neg\chi)$.
* **Class probabilities.** For a theory $T$: $\Unif_A[T]:=\Unif\{\omega:B\cup A_\omega\text{ consistent},\ \Cn(A_\omega)=\Cn(T)\}$ and $\Unif_A(\Ext T):=\Unif\{\omega:B\cup A_\omega\text{ consistent},\ \Cn(A_\omega)\supseteq\Cn(T)\}$.

By Prop 2.1: $M_A(D)=\Bel_0(\psi_D)$, $M_A(b\mid D,\varphi)=\Bel_D(\varphi^b)$ and $M_A^3(\iota\mid D,\varphi)=\Indep_D(\varphi)$ for $\varphi\notin\dom D$.

### 1.4 Conventions and the two defects

**Definition 1.5 (loss conventions).**
* *Semimeasure convention* (primary): the cumulative loss of a consistent reveal sequence is $\sum_{t\le n}-\log M_A(y_t\mid D_{t-1},\varphi_t)=L_A(D_n)-L_A(\emptyset)$ (Prop 2.1(d)).
* *Normalised convention*: each conditional is divided by $\Bel_D(\varphi)+\Dis_D(\varphi)$. Upper bounds proved in the semimeasure convention hold here too (each normalised conditional is at least the raw one); lower bounds do not transfer, and the loss depends on the order (Thm 11.1).
* *Three-valued convention*: labels in $Y_3$, scored by $M_A^3$, whose conditionals sum to $1$ (Prop 2.1(f)).

**Remark 1.6 (two defects).** $M_A$ has a *global* defect $1-M_A(\emptyset)=\Inc_0>0$ and a *local* defect $\Indep_D(\varphi)$ at each query. P1's $M_F$ has only the local one ($M_F(\emptyset)=1$), because function machines are consistent by definition. The correspondence with P1 is: "proves $\varphi$" is $\Sigma_1$ in the tape, like "halts with output 1"; "independent" is $\Pi_1$, like "diverges"; "inconsistent" corresponds to "halts with both outputs", which a function machine cannot do. Hänni's working notes considered keeping the semimeasure (rather than renormalising or splitting 50/50); the AI-paper (Exs 2.15, 2.16, Prop 2.17) shows the two alternatives are incoherent, and this record follows the semimeasure convention.

### 1.5 Coin-free and Kolmogorov versions

**Definition 1.7.** For a data set $D$:
* $W_A(D):=\sum_{p\in\dom V}2^{-|p|}\ind[B\cup\mathsf W_{V(p)}\text{ consistent and }\vdash\psi_D]=\sum_e\mm(e)\,\ind[\cdots]$ (enumerators; coin-free);
* $K_A(D):=\min\{|p|:p\in\dom V,\ B\cup\mathsf W_{V(p)}\text{ consistent},\ \vdash\psi_D\}$ ($\infty$ if none; Kolmogorov version);
* $W_A^{\rm dec}$, $K_A^{\rm dec}$: the same over *deciders*, $p\in\dom V$ such that $V(p)$ is an index of a total $\{0,1\}$-valued function $d$, read as the axiom set $\{\chi:d(\chi)=1\}$ (AI-paper Def 6.2, there written $W_{\rm AI}$);
* $W_A^{{\rm gen},t}$: the same over enumerators that meet the delay form of TF Def 1.1 (P2) for a time-constructible $t\ge m^{a^*}$;
* $K_{\rm fin}(D):=\min\{K(\psi):\psi\in\Sent,\ B\cup\{\psi\}\text{ consistent},\ B\cup\{\psi\}\vdash\psi_D\}$ and $W_{\rm fin}(D):=\sum_\psi\mm(\psi)\ind[\cdots]$ (finite axiomatisations).

**Proposition 1.8 (versions agree; finite axiomatisations do not).** There is $c$ such that for every $D$:
(a) **[proved]** $2^{-c}W_A^{\rm dec}(D)\le W_A(D)\le2^{c}W_A^{\rm dec}(D)$ and $|K_A(D)-K_A^{\rm dec}(D)|\le c$;
(b) **[proved, given TF Lemma 2.1 and Thm 2.2(b), under TF's assumption (S)]** $2^{-c}W_A(D)\le W_A^{{\rm gen},t}(D)\le2^cW_A(D)$, and likewise for the Kolmogorov versions;
(c) **[proved]** $K_A(D)\le K_{\rm fin}(D)+c\le K(\psi_D)+c$ if $D$ is consistent; all three are $\infty$ otherwise;
(d) **[proved]** $K_{\rm fin}-K_A$ is unbounded: in the language $\{R\}\cup\{c_j:j\in\mathbb N\}$ ($R$ unary, $c_j$ constants), $B=\emptyset$, the data sets $D_n:=\{(R(c_j),1):j<n\}\cup\{(\exists x\neg R(x),1)\}$ have $K_A(D_n)\le c$ and $K_{\rm fin}(D_n)=\Kpad(n)\pm c$, where $\Kpad(n):=\min_{N\ge n}K(N)$ is nondecreasing and unbounded.

*Proof.* (a) *Deciders to enumerators.* By universality of $V$ there is $r_1$ with $V(r_1p)$ an index of the r.e. set $\{\chi:\{V(p)\}(\chi)=1\}$ whenever $p$ is a decider. The map $p\mapsto r_1p$ is injective, adds $|r_1|$ to the length and preserves the axiom set. *Enumerators to deciders (Craig's trick).* Write $\chi^{\wedge1}:=\chi$, $\chi^{\wedge(m+1)}:=\chi\wedge\chi^{\wedge m}$. For an index $e$ fix the step-by-step enumeration of $\mathsf W_e$ and let $A^C_e:=\{\chi^{\wedge(s+1)}:\chi\text{ is enumerated at step }s\}$. A sentence $\theta$ has at most two readings $\theta=\chi^{\wedge m}$: $(\chi,m)=(\theta,1)$, and, if $\theta$ is a conjunction, $\chi$ its left conjunct with $m$ the number of times $\chi$ can be stripped off. So $A^C_e$ is decided by: find the readings, and for each run the enumeration for exactly $m-1$ steps and check whether $\chi$ appears at step $m-1$. This halts on every input, also when $\mathsf W_e$ is finite. $\chi^{\wedge m}$ is logically equivalent to $\chi$, so $\Cn(A^C_e)=\Cn(\mathsf W_e)$. A fixed $r_2$ gives $V(r_2p)$ = an index of this decider for $e=V(p)$; the map is injective and adds $|r_2|$. Both maps preserve consistency and what is proved, so summing over programs and taking shortest programs gives (a) with $c:=\max(|r_1|,|r_2|)$. This is the argument of AI-paper Thm 6.3 (proof in its App. E.1), here between two kinds of axiom hypotheses rather than between axiom and labeller hypotheses.
(b) TF Thm 2.2(b) proves $2^{-c}W_{\rm FI}\le W_{{\rm AI}^{\rm gen}_t}\le2^cW_{\rm FI}$ with $W_{\rm FI}$ the coin-free consistent-labeller mixture ($W^{\rm cons}$ here), and AI-paper Thm 6.3 proves $W_{\rm FI}\asymp W_{\rm AI}=W_A^{\rm dec}$; combine with (a). Directly: an enumerator $p$ of $A$ is mapped to TF's padded enumerator $e_q$ of the semi-decider $q$ of $A$ ("yes on $\chi$ iff $\chi$ is enumerated"); TF Lemma 2.1(a),(c),(d) give $\Cn(\mathrm{Pad}(q))=\Cn(A)$, the delay form, and $|e_q|\le|p|+c$ injectively. The converse inclusion is trivial (a polynomial-delay enumerator is an enumerator). The translation between TF's $U$-programs and our $V$-programs printing indices costs a constant. TF proves Lemma 2.1 under its assumption (S) on efficient self-simulation; I did not re-derive (S).
(c) If $\psi$ witnesses $K_{\rm fin}(D)$, a fixed prefix $r_3$ turns a shortest program for $\psi$ into a program for an index of $\{\psi\}$, consistent with $B$ and proving $\psi_D$; so $K_A\le K_{\rm fin}+|r_3|$. For consistent $D$, $\psi:=\psi_D$ is a candidate for $K_{\rm fin}$. If $D$ is inconsistent no consistent set proves $\psi_D$.
(d) $T:=\{R(c_j):j\in\mathbb N\}\cup\{\exists x\neg R(x)\}$ is r.e. with an index of complexity $O(1)$ and is consistent (domain $\mathbb N\cup\{*\}$, $c_j\mapsto j$, $R:=\mathbb N$), so $K_A(D_n)\le c$. Upper bound on $K_{\rm fin}$: for $N\ge n$ with $K(N)=\Kpad(n)$, the sentence $\bigwedge_{j<N}R(c_j)\wedge\exists x\neg R(x)$ is consistent, proves $\psi_{D_n}$, and has complexity $\le K(N)+c$. Lower bound: let $\psi$ be consistent with $\psi\vdash\psi_{D_n}$. If some $c_j$, $j<n$, does not occur in $\psi$, then $\psi\vdash R(c_j)$ and the theorem on constants give $\psi\vdash\forall xR(x)$, which contradicts $\psi\vdash\exists x\neg R(x)$ and the consistency of $\psi$. So $\psi$ mentions $c_0,\dots,c_{n-1}$, and $N(\psi):=1+\max\{j:c_j\text{ occurs in }\psi\}\ge n$ is computable from $\psi$; hence $K(\psi)\ge K(N(\psi))-c\ge\Kpad(n)-c$. $\Kpad$ is nondecreasing by definition and unbounded because only finitely many $N$ have $K(N)\le k$. ∎

So finite axiomatisability is a genuinely different simplicity measure: a schema-free r.e. theory can be simple while every single sentence that does its job on the first $n$ data must name $n$ objects. (`terms` T5 studies when finite theories gain from theoretical vocabulary.)

### 1.6 Complexities of theories

**Definition 1.9.** For an r.e. theory $T$ (Notation §3.3): $[T]:=\{e:\Cn(\mathsf W_e)=\Cn(T)\}$; $K_\equiv(T):=\min_{e\in[T]}K(e)$ (complexity up to deductive equivalence); $\mm_\equiv(T):=\sum_{e\in[T]}\mm(e)$; $\Ext(T):=\{e:B\cup\mathsf W_e\text{ consistent},\ \Cn(\mathsf W_e)\supseteq\Cn(T)\}$ and $\mm(\Ext T):=\sum_{e\in\Ext T}\mm(e)$. The one-tape versions $\Unif_A[T]$, $\Unif_A(\Ext T)$ are in Def 1.4. Always $2^{-K_\equiv(T)}\le\mm_\equiv(T)\le\mm(\Ext T)$, and $\Unif_A[T]\ge2^{-c}\mm_\equiv(T)$, $\Unif_A(\Ext T)\ge2^{-c}\mm(\Ext T)$ (Thm 4.1(i)).

### 1.7 Variants

**Definition 1.10.**
* **Consistency-requiring (CR), 0/1** (Hänni's "do not contradict"; AI-paper $S_{\rm nc}$): $M_A^{\rm nc}(D):=\Unif\{\omega:B\cup A_\omega\cup D^\pm\text{ consistent}\}$. Its posterior is the law of $A_\omega$ given that event; its predictor uses the hypothesis plus the data: $\Bel^{\rm nc}_D(\varphi):=\Unif\{B\cup A_\omega\cup D^\pm\text{ consistent and }\vdash\varphi\}/M_A^{\rm nc}(D)$, $\Dis^{\rm nc}_D(\varphi):=\Bel^{\rm nc}_D(\neg\varphi)$.
* **Graded CR, grade ½** (AI-paper $S_g$ with $g\equiv1$ on proved data and $g_\infty=\frac12$): for a consistent $A$, $\nu^{1/2}_A(D):=\ind[B\cup A\cup D^\pm\text{ consistent}]\prod_{\varphi\in\dom D}g_A(\varphi)$ with $g_A(\varphi):=1$ if $B\cup A\vdash\varphi^{D(\varphi)}$ and $\frac12$ otherwise; $M_A^{1/2}(D):=\int_{C}\nu^{1/2}_{A_\omega}(D)\,d\Unif(\omega)$, $C$ the consistency event.
* **Generative** (AI-paper L1, Def 2.9): a theory $A$ has a law $P_A$ on sentences (derivation grammar with citation weights on the axioms); data are unlabelled sentences $X_1,X_2,\dots$; the universal law of data streams is $\Xi(X_{1:n}):=\int\prod_iP_{A_\omega}(X_i)\,d\Unif(\omega)$, with the sampling coins read from separate parts of the tape. Details and results in §9.

### 1.8 What is new in these definitions

| object | source |
|---|---|
| theory machines, laws $\nu_G$, $\nu^3_G$; universal $G_U$; $M_A$, $M_A^3$; $\Inc_0$, $O_\chi$; one-tape class probabilities $\Unif_A$ | new here (scout F, scout S); parallel to P1's function machines (P1 Defs 3.6, 3.15) |
| Kolmogorov version $K_A$; $K_\equiv$, $\mm_\equiv$, $\Ext$ as loss parameters; $K_{\rm fin}$ separation (Prop 1.8(d)) | new here |
| coin-free deciders $W_A^{\rm dec}$ (AI-paper $W_{\rm AI}$), semimeasure convention | AI-paper Def 6.2 |
| polynomial-delay enumerators | TF Def 1.1 (P2), Thm 2.2(b) |
| scores $S_{\rm prove}$, $S_{\rm nc}$, $S_g$ (here the 0/1, CR and graded weights in one-tape form) | AI-paper Def 2.12 |
| trichotomy $\Bel,\Dis,\Indep,\Inc,\Pl$ for a posterior over theories | AI-paper Def 2.13 (for countable classes); here for the one-tape law |
| generative L1 and its support lemma | AI-paper Def 2.9, Lemma 2.10 |

---

## 2. Structure (target T2)

**Proposition 2.1 (structure) [proved; computed: c1 A1–A4].** Let $G$ be a theory machine (in particular $G_U$).
(a) $\nu_G(D)>0$ implies that $D$ is consistent. $M_A(D)>0$ iff $D$ is consistent; $M_A^3(D)>0$ iff $D$ is consistent and $B\cup D^\pm$ decides no $\iota$-labelled sentence.
(b) For a two-valued $D$ and $\varphi\notin\dom D$:
$$\nu_G(D+(\varphi,1))+\nu_G(D+(\varphi,0))+\nu^3_G(D+(\varphi,\iota))=\nu_G(D).$$
So $\nu_G$ is a semimeasure on data sets (P1 Def 3.2), and for $M_A$ the defect at $\varphi$ divided by $M_A(D)$ is $\Indep_D(\varphi)$.
(c) $\nu_G(D)$ depends on $D$ only through $\Cn(D^\pm)$. If $B\cup D^\pm\vdash\varphi^b$ and $\varphi\notin\dom D$, then $\nu_G(D+(\varphi,b))=\nu_G(D)$ and $\nu_G(D+(\varphi,1-b))=0$: entailed data cost nothing and contradicting data are fatal.
(d) *Order independence.* For every consistent reveal sequence, in any order and with repeats, $\sum_{t\le n}-\log M_A(y_t\mid D_{t-1},\varphi_t)=L_A(D_n)-L_A(\emptyset)$, which depends only on $\Cn(D_n^\pm)$.
(e) $0<M_A(\emptyset)=1-\Inc_0<1$.
(f) For a three-valued $D$ and $\varphi\notin\dom D$, $\sum_{y\in Y_3}\nu^3_G(D+(\varphi,y))=\nu^3_G(D)$, and $\nu^3_G(\emptyset)=\nu_G(\emptyset)$. So the conditionals of $M_A^3$ are probability distributions on $Y_3$.
(g) On the consistency event $C:=C^{G_U}$ put $f_\omega(\varphi):=1$ if $B\cup A_\omega\vdash\varphi$, $0$ if $B\cup A_\omega\vdash\neg\varphi$, and $\iota$ otherwise. Then $M_A^3(D)=\Unif\{\omega\in C:f_\omega\supseteq D\}$ and, for two-valued $D$, $M_A(D)=\Unif\{\omega\in C:f_\omega\supseteq D\}$: $M_A^3$ is the containment functional (P1 Def 3.4) of the random total function $f_\omega:\Sent\to Y_3$ under the sub-probability $\Unif|_C$, and $M_A$ is that of the random partial function obtained by reading $\iota$ as "undefined".

*Proof.* (a) If $D$ is inconsistent, a set proving $\psi_D$ is inconsistent, so $E^G_D=\emptyset$. If $D$ is consistent, the deterministic machine $G_D:=\{(\epsilon,\psi_D)\}$ has $\nu_{G_D}(D)=1$, so $M_A(D)\ge2^{-K(G_D)}>0$ by Thm 4.1. Three-valued: $B\cup\{\psi_D\}$ decides exactly what $B\cup D^\pm$ decides, so if $B\cup D^\pm$ decides no $\iota$-labelled sentence then $\nu^3_{G_D}(D)=1$; conversely, if $B\cup D^\pm$ decides an $\iota$-labelled sentence, so does every set proving $\psi_D$.
(b) $O^G_\chi$ depends only on the $B$-equivalence class of $\chi$, and $\psi_{D+(\varphi,b)}$ is equivalent to $\psi_D\wedge\varphi^b$. On $E^G_D$ the random theory is consistent, so exactly one of three things happens: it proves $\varphi$, it proves $\neg\varphi$, it decides neither. The three events are $E^G_{D+(\varphi,1)}$, $E^G_{D+(\varphi,0)}$ and $E^{3,G}_{D+(\varphi,\iota)}$. For $G_U$, divide by $\Unif(E_D)$: the third term is $1-\Bel_D(\varphi)-\Dis_D(\varphi)$.
(c) $B\cup A\vdash\psi_D$ iff $\Cn(D^\pm)\subseteq\Cn(A)$. If $B\cup D^\pm\vdash\varphi^b$, then $\Cn(D^\pm\cup\{\varphi^b\})=\Cn(D^\pm)$, and $D+(\varphi,1-b)$ is inconsistent, so (a) applies.
(d) At a step with $\varphi_t\notin\dom D_{t-1}$ the factor is $M_A(D_t)/M_A(D_{t-1})$; at a repeat (necessarily with the stored label, the sequence being consistent) it is $1$ and $D_t=D_{t-1}$. The product telescopes to $M_A(D_n)/M_A(\emptyset)$. If some $M_A(D_t)=0$, the first such step has factor $0$ and both sides are $+\infty$, by the monotonicity in (b). Dependence only on $\Cn(D_n^\pm)$ is (c).
(e) $M_A(\emptyset)=\Unif(C)$. Tapes beginning with a $V$-program for an index of the empty machine have $A_\omega=\emptyset$, consistent since $B$ is. Tapes beginning with a program for $\{(\epsilon,\bot)\}$, with $\bot:=\neg\forall x\,x=x$, are inconsistent. Both sets have positive measure.
(f) As (b), with $E^{3,G}_D$ in place of $E^G_D$; $\nu^3_G(\emptyset)=\Unif(C^G)=\nu_G(\emptyset)$.
(g) By definition, $E^3_D=\{\omega\in C:f_\omega\supseteq D\}$. ∎

**Proposition 2.2 (proof-requiring updating is geometric conditioning) [proved; computed: c1 A5–A7; the names of the rules: known, unverified].**
(a) For every $D$ with $M_A(D)>0$ and every $\chi$: $\Bel_D(\chi)=\Bel_0(\psi_D\wedge\chi)/\Bel_0(\psi_D)$. With $\widehat{\Bel}_0:=\Bel_0/(1-\Inc_0)$, the normalised belief function, this is $\widehat{\Bel}_0(\psi_D\wedge\chi)/\widehat{\Bel}_0(\psi_D)$: the *geometric rule of conditioning* (attributed to Suppes and Zanotti 1977; see §14).
(b) $\Bel_0$ and every $\Bel_D$ are totally monotone on the Lindenbaum algebra of $B$: for all $\chi_1,\dots,\chi_k$,
$$\Bel_D\Big(\bigvee_{i\le k}\chi_i\Big)\ \ge\ \sum_{\emptyset\ne I\subseteq[k]}(-1)^{|I|+1}\Bel_D\Big(\bigwedge_{i\in I}\chi_i\Big).$$
So $\Bel_D$ is a belief function in Shafer's sense, with random focal set $\mathrm{Mod}(B\cup A_\omega)$ and plausibility $\Pl_D(\chi)=1-\Bel_D(\neg\chi)$; $\Bel_0$ is the "probability of provability" reading of a belief function (attributed to Pearl 1988; see §14).
(c) There is a probability $P_D$ on the complete consistent extensions of $B$ (a Borel probability on the Stone space) with $\Bel_D(\chi)\le P_D(\chi)\le\Pl_D(\chi)$ for every $\chi$.

*Proof.* (a) A theory proves $\psi_D$ and $\chi$ iff it proves $\psi_D\wedge\chi$, so $E_D\cap O_\chi=O_{\psi_D\wedge\chi}\setminus O_\bot$ and both sides equal $\Unif(O_{\psi_D\wedge\chi}\setminus O_\bot)/\Unif(O_{\psi_D}\setminus O_\bot)$. The normalising constant cancels.
(b) Let $P$ be $\Unif(\cdot\mid E_D)$ and $Q_i:=O_{\chi_i}$. Then $\bigcap_{i\in I}Q_i=O_{\bigwedge_{I}\chi_i}$ and $\bigcup_iQ_i\subseteq O_{\bigvee_i\chi_i}$. Inclusion–exclusion for $P(\bigcup_iQ_i)$ gives the inequality. $\Bel_0$ is the unnormalised case ($P=\Unif|_C$).
(c) Fix an enumeration $(\sigma_k)$ of $\Sent$. For $\omega\in C$ let $T_0(\omega):=B\cup A_\omega$ and $T_{k+1}:=T_k\cup\{\sigma_k\}$ if that is consistent, $T_k\cup\{\neg\sigma_k\}$ otherwise; $T_\infty(\omega):=\bigcup_kT_k$ is a complete consistent extension. Each choice depends on whether $B\cup A_\omega\cup F$ is consistent for a finite $F$, i.e. on membership of $\omega$ in the open class $O_{\neg\bigwedge F}$, so $\omega\mapsto T_\infty(\omega)$ is Borel. Let $P_D$ be its law under $\Unif(\cdot\mid E_D)$. If $B\cup A_\omega\vdash\chi$ then $\chi\in T_\infty$; if $\chi\in T_\infty$ then $B\cup A_\omega\nvdash\neg\chi$. So $\Bel_D\le P_D\le\Pl_D$. ∎

(b) and (c) are the one-tape forms of AI-paper Props 2.18 and 2.19, which are stated there for countable classes; the proofs above do not need countability.

**Proposition 2.3 (consistency-requiring updating is Dempster conditioning) [proved; computed: c1 A8; the name of the rule: known, unverified].** Let $\psi:=\psi_D$ and $M_A^{\rm nc}(D)>0$. Then $M_A^{\rm nc}(D)=\Pl_0(\psi)$ and
$$\Bel^{\rm nc}_D(\varphi)=\frac{\Bel_0(\varphi\vee\neg\psi)-\Bel_0(\neg\psi)}{\Bel_0(\top)-\Bel_0(\neg\psi)},$$
which, written with $\widehat{\Bel}_0$, is Dempster's rule of conditioning $\widehat{\Bel}(\varphi\mid\psi)=[\widehat{\Bel}(\varphi\vee\neg\psi)-\widehat{\Bel}(\neg\psi)]/[1-\widehat{\Bel}(\neg\psi)]$ (Dempster 1967; Shafer 1976; see §14).

*Proof.* For consistent $B\cup A$: $B\cup A\cup\{\psi\}$ is consistent iff $B\cup A\nvdash\neg\psi$, and $B\cup A\cup\{\psi\}\vdash\varphi$ iff $B\cup A\vdash\varphi\vee\neg\psi$. So $M_A^{\rm nc}(D)=\Unif(C)-\Unif(C\cap O_{\neg\psi})=\Bel_0(\top)-\Bel_0(\neg\psi)$. Since $B\cup A\vdash\neg\psi$ implies $B\cup A\vdash\varphi\vee\neg\psi$, the numerator is $\Unif(C\cap O_{\varphi\vee\neg\psi})-\Unif(C\cap O_{\neg\psi})$. ∎

*Random-set reading.* With focal set $F_\omega:=\mathrm{Mod}(B\cup A_\omega)$: proof-requiring updating keeps the focal sets contained in $\mathrm{Mod}(\psi)$ and renormalises; Dempster updating replaces each $F_\omega$ by $F_\omega\cap\mathrm{Mod}(\psi)$, drops the empty ones and renormalises. In the first, a datum must be *explained* by the hypothesis; in the second it is *added* to the hypothesis.

---

## 3. Computability (target T3)

**Proposition 3.1 [proved].** $M_A(D)=\Unif(O_{\psi_D})-\Inc_0$, where $\Unif(O_{\psi_D})$ is left-c.e. uniformly in $D$ and $\Inc_0=\Unif(O_\bot)$ is left-c.e. (Lemma 1.3). The correction that turns the lsc function $D\mapsto\Unif(O_{\psi_D})$ (which is not a semimeasure: it gives an inconsistent theory credit for every datum) into $M_A$ is one real number.

**Theorem 3.2 (the consistency probability is an Ω-like real).**
(a) **[proved]** $\Inc_0$ is not computable. Hence $M_A(\emptyset)=1-\Inc_0$ is right-c.e. and not left-c.e., and $D\mapsto M_A(D)$ is not lower semicomputable.
(b) **[proved]** For every left-c.e. $\alpha\in[0,1]$ there are a $V$-program $p_\alpha$ and a left-c.e. real $\gamma_\alpha$ with $\Inc_0=2^{-|p_\alpha|}\alpha+\gamma_\alpha$. Consequently $\alpha\le_S\Inc_0$ for every left-c.e. $\alpha$: $\Inc_0$ is Solovay complete.
(c) **[proved, given Chaitin's theorem that $\Omega_V$ is Martin-Löf random and the Levin–Schnorr characterisation of randomness by prefix complexity (known, unverified; §14)]** $\Inc_0$ is Martin-Löf random.

*Proof.* *The machine $G_\alpha$.* Let $\alpha_s\uparrow\alpha$ be a computable nondecreasing sequence of rationals and $G_\alpha:=\{(w,\bot):\exists s\ 0.w+2^{-|w|}\le\alpha_s\}$, with $0.w$ the dyadic rational with binary digits $w$. Then $A^{G_\alpha}_\omega\subseteq\{\bot\}$, and $\bot\in A^{G_\alpha}_\omega$ iff some prefix $w$ of $\omega$ has $[w]\subseteq[0,\alpha_s]$ for some $s$, read as reals. This holds for every $\omega$ with $0.\omega<\alpha$ (take $s$ with $\alpha_s>0.\omega$ and a long prefix) and fails for every $\omega$ with $0.\omega>\alpha$. So the inconsistency probability of $G_\alpha$ is $\alpha$.
*The decomposition.* Let $p_\alpha$ be a $V$-program for an index of $G_\alpha$. Splitting tapes by their first block in $\dom V$ (tapes with no block have $A_\omega=\emptyset$, consistent),
$$\Inc_0=2^{-|p_\alpha|}\alpha+\gamma_\alpha,\qquad \gamma_\alpha:=\sum_{p\in\dom V\setminus\{p_\alpha\}}2^{-|p|}\Unif(O^{G_{V(p)}}_\bot),$$
and $\gamma_\alpha$ is left-c.e. because $\dom V\setminus\{p_\alpha\}$ is c.e. and each term is left-c.e. uniformly.
(a) Let $K_0$ be the halting set and $\alpha:=\sum_{n\in K_0}2^{-n-1}$, left-c.e.; its binary expansion is the characteristic sequence of $K_0$ (unique, since $K_0$ is co-infinite), so $\alpha$ is not computable. If $\Inc_0$ were computable, $\alpha=2^{|p_\alpha|}(\Inc_0-\gamma_\alpha)$ would be right-c.e.; being also left-c.e. it would be computable. A real that is left-c.e. and right-c.e. is computable, so $1-\Inc_0$ (right-c.e.) is not left-c.e.; as $M_A(\emptyset)$ is a value of $M_A$, $M_A$ is not lsc.
(b) *Solovay reducibility* (Solovay 1975; definition as in Downey–Hirschfeldt 2010, known, unverified): $\alpha\le_S\beta$ iff there are a constant $k$ and a partial computable $f$ on rationals such that for every rational $q<\beta$, $f(q)$ is defined, $f(q)<\alpha$ and $\alpha-f(q)\le2^k(\beta-q)$. Let $\beta:=\Inc_0$, with approximations $\beta_s:=2^{-|p_\alpha|}\alpha_s+\gamma_{\alpha,s}\uparrow\beta$. If $\alpha$ is computable, the reduction is trivial (given $q<\beta$, find $s$ with $\beta_s>q$ and output a rational in $(\alpha-(\beta_s-q),\alpha)$). Otherwise $\alpha_s<\alpha$ for all $s$; let $f(q):=\alpha_s$ for the first $s$ with $\beta_s>q$. Then
$$\alpha-\alpha_s=2^{|p_\alpha|}\big[(\beta-\beta_s)-(\gamma_\alpha-\gamma_{\alpha,s})\big]\le2^{|p_\alpha|}(\beta-\beta_s)<2^{|p_\alpha|}(\beta-q).$$
(c) Apply (b) with $\alpha:=\Omega_V$ and Lemma 3.3 with $k=|p_\alpha|$. ∎

**Lemma 3.3 (randomness passes up) [proved, given the Levin–Schnorr characterisation].** Let $\alpha,\gamma$ be left-c.e., $\alpha$ Martin-Löf random, $k\ge0$, and $\beta:=2^{-k}\alpha+\gamma<1$. Then $K(\alpha_{1:n})\le K(\beta_{1:n})+k+c$ for all $n$, so $\beta$ is Martin-Löf random.

*Proof.* Let $\alpha_s\uparrow\alpha$, $\gamma_s\uparrow\gamma$ be computable rational approximations and $\beta_s:=2^{-k}\alpha_s+\gamma_s$. Given the string $u:=\beta_{1:n}$ (which also gives $n$), put $q:=0.u-2^{-n}<\beta$ and find the first $s$ with $\beta_s>q$. Then $\beta-\beta_s<\beta-q\le2^{1-n}$, hence $\alpha-\alpha_s\le2^k(\beta-\beta_s)<2^{k+1-n}$. $\alpha$ is irrational (random), so $\alpha_{1:n}$ is the index of the dyadic interval of length $2^{-n}$ containing $\alpha$, one of the at most $2^{k+1}+1$ such intervals meeting $[\alpha_s,\alpha_s+2^{k+1-n})$. So $\alpha_{1:n}$ is determined by $u$ and a $(k+2)$-bit index: $K(\alpha_{1:n})\le K(\beta_{1:n})+k+c$. By Levin–Schnorr, $K(\alpha_{1:n})\ge n-c'$ for all $n$, hence $K(\beta_{1:n})\ge n-k-c-c'$ for all $n$, and $\beta$ is random by Levin–Schnorr again. ∎

*Remark.* By Calude–Hertling–Khoussainov–Wang (2001) and Kučera–Slaman (2001), the Solovay-complete left-c.e. reals are exactly the random left-c.e. reals and the halting probabilities of universal prefix machines (known, unverified). So $\Inc_0$ is an Ω-number; the proof above does not use this. Scout F's F3(c) derived randomness from Kučera–Slaman; Lemma 3.3 replaces that citation by a five-line argument from textbook facts.

**Proposition 3.4 [proved].** (a) $M_A(D)$ and the conditionals $M_A(b\mid D,\varphi)$, $M_A^3(y\mid D,\varphi)$, $\Bel_D(\chi)$ are computable relative to $\emptyset'$, uniformly. (b) $D\mapsto M_A(D)+\Inc_0$ is lsc; so $M_A$ is lsc relative to the single real $\Inc_0$ (given as an oracle).

*Proof.* (a) Every left-c.e. real is $\emptyset'$-computable (decide "$\exists s\,a_s>q$" for rationals $q$), and differences and ratios of $\emptyset'$-computable reals are $\emptyset'$-computable once the denominator is known to be positive; $M_A(D)>0$ iff $D$ is consistent (Prop 2.1(a)), a $\Pi^0_1$ question, decidable in $\emptyset'$. The three-valued events are Boolean combinations of effectively open classes, whose measures are differences of left-c.e. reals by inclusion–exclusion. (b) Prop 3.1. ∎

*Contrast with P1.* Every machine law of P1 is lsc (P1 Prop 3.7) and $M_F$ is lsc with $\emptyset'$-computable conditionals (P1 Prop A.10). $M_A$ shares the second property and loses the first, by exactly one real: the probability of inconsistency. The reason is that P1's function machines are consistent by construction, while a theory machine's consistency is a $\Pi^0_1$ property of its output.

---

## 4. Universality and invariance (target T4)

**Theorem 4.1 (mixture identity and dominance) [proved].** For every two-valued $D$,
$$M_A(D)=\sum_{p\in\dom V}2^{-|p|}\nu_{G_{V(p)}}(D)+(1-\Omega_V)\ind[B\vdash\psi_D]=\sum_i\mm(i)\,\nu_{G_i}(D)+(1-\Omega_V)\ind[B\vdash\psi_D],$$
with $\Omega_V:=\sum_{p\in\dom V}2^{-|p|}$, and the same holds for $M_A^3$, $\nu^3_{G_i}$ and the indicator that $B$ proves $\psi_D$ and decides no $\iota$-labelled sentence. Hence $M_A\ge2^{-K(\nu)}\nu$ for every theory-machine law $\nu$, and $M_A^3\ge2^{-K(G)}\nu^3_G$ for every theory machine $G$. In particular:
(i) $M_A(D)\ge2^{-K(e)-c}\ind[B\cup\mathsf W_e\text{ consistent},\ \vdash\psi_D]$ for every index $e$; consequently $\Unif_A[T]\ge2^{-c}\mm_\equiv(T)\ge2^{-K_\equiv(T)-c}$ and $\Unif_A(\Ext T)\ge2^{-c}\mm(\Ext T)$;
(ii) $M_A(D)\ge2^{-K(f)-c}\ind[f\supseteq D]$ for every partial computable labeller $f:\Sent\rightharpoonup\{0,1\}$ with $B\cup\Gamma_f$ consistent;
(iii) for every lsc semimeasure $v$ on indices, $M_A(D)\ge2^{-K(v)-c}\sum_ev(e)\ind[B\cup\mathsf W_e\text{ consistent},\ \vdash\psi_D]$; in particular $M_A\ge2^{-c}W_A$;
(iv) for an r.e. $T$ and a computable family $(\alpha_j)$ of sentences, the law of "$T$ plus fair-coin facts $\alpha_j^{\omega_j}$" (Example (iii) of §1.2) is dominated with constant $2^{-K(T,(\alpha_j))-c}$.

*Proof.* $\dom V$ is prefix-free, so the cylinders $[p]$, $p\in\dom V$, are disjoint, and for $\omega=p\omega'$ we have $A_\omega=A^{G_{V(p)}}_{\omega'}$ with $\omega'$ uniform given $[p]$. Hence $\Unif(E_D\cap[p])=2^{-|p|}\nu_{G_{V(p)}}(D)$. The tapes with no prefix in $\dom V$ have measure $1-\Omega_V$ and $A_\omega=\emptyset$. Grouping the $p$ with $V(p)=i$ gives weight $\mm(i)\ge2^{-K(i)}$. The three-valued case is identical.
(i) The deterministic machine $G'_e:=\{(\epsilon,\chi):\chi\in\mathsf W_e\}$ has an index $g(e)$ with $g$ computable and injective, so $\mm(g(e))\ge2^{-c}\mm(e)$ (the image of $\mm$ under $g$ is an lsc semimeasure, dominated by $\mm$). The tapes beginning with programs for distinct $g(e)$, $e\in[T]$, are disjoint and all lie in the event $\{\Cn(A_\omega)=\Cn(T)\}$; sum. Likewise for $\Ext T$.
(ii) $G_f:=\{(\epsilon,\varphi^b):f(\varphi)=b\}$ enumerates $\Gamma_f$, which is consistent with $B$ and proves $\psi_D$ when $f\supseteq D$; $K(G_f)\le K(f)+c$.
(iii) The map $i\mapsto\sum_{g(e)=i}v(e)$ is an lsc semimeasure of complexity $\le K(v)+c$, so $\mm(g(e))\ge2^{-K(v)-c}v(e)$. With $v=\mm$: $M_A\ge2^{-c}W_A$.
(iv) The machine of Example (iii) has an index computable from indices of $T$ and of the family. ∎

**Proposition 4.2 (choice of the universal machine) [proved].** Call a theory machine $G'$ *universal* if for every theory machine $G$ there is a string $p_G$ with $A^{G'}_{p_G\omega}=A^G_\omega$ for all $\omega$ ($G_U$ is universal, with $p_G$ a $V$-program for an index of $G$). If $G'$ is universal, then $2^{-c}M_A\le\nu_{G'}\le2^cM_A$ and the same for the three-valued laws, with $c$ depending only on $G_U$ and $G'$. So posteriors change by at most a constant factor and semimeasure-convention losses by an additive constant.

*Proof.* $M_A\ge2^{-K(G')}\nu_{G'}$ by Thm 4.1. Conversely, the tapes $p_{G_U}\omega'$ give $G'$ the axiom set $A_{\omega'}$, so $\nu_{G'}(D)\ge2^{-|p_{G_U}|}M_A(D)$. ∎

**Proposition 4.3 (the background is a prior shift) [proved].** Let $B,B'$ be decidable and consistent with $B\subseteq\Cn_\emptyset(B')$ (plain logical consequence), and write $M_A^B$, $M_A^{B'}$ for SAI with these backgrounds. Then $M_A^B(D)\ge2^{-K(B')-c}M_A^{B'}(D)$ for every $D$, with $K(B')$ the complexity of an index of $B'$; likewise $W_A^B\ge2^{-K(B')-c}W_A^{B'}$ and $K_A^B\le K_A^{B'}+K(B')+c$. The converse fails: a $D$ consistent with $B$ and inconsistent with $B'$ has $M_A^{B'}(D)=0<M_A^B(D)$.

*Proof.* The machine $G_{B'}:=\{(\epsilon,\chi):\chi\in B'\}\cup G_U$ emits $B'\cup A_\omega$ on $\omega$. Under background $B$, $B\cup B'\cup A_\omega$ is equivalent to $B'\cup A_\omega$, so $\nu^B_{G_{B'}}(D)=M_A^{B'}(D)$; apply Thm 4.1. The same map on single programs gives the other two. ∎

So building knowledge into the background gains at most $K(B')+c$ bits on any data.

**Theorem 4.4 (faithful translations) [proved].** Let $(\mathcal L,B)$ and $(\mathcal L',B')$ be two settings and $\tau:\Sent_{\mathcal L}\to\Sent_{\mathcal L'}$ computable with
* (T1) for all $\Gamma\subseteq\Sent_{\mathcal L}$ and $\varphi$: $B\cup\Gamma\vdash\varphi$ iff $B'\cup\tau[\Gamma]\vdash\tau(\varphi)$;
* (T2) $B'\vdash\tau(\neg\varphi)\leftrightarrow\neg\tau(\varphi)$ for all $\varphi$.

For a data set $D$ on $\mathcal L$ let $M'_A(\tau D):=\Unif\{\omega:B'\cup A'_\omega\text{ consistent and }\vdash\tau(\varphi)^{D(\varphi)}\ \forall\varphi\in\dom D\}$, with $A'$ the universal theory machine of $\mathcal L'$. Then for every $D$
$$2^{-K(\tau)-c}M_A(D)\le M'_A(\tau D)\le2^{K(\tau)+c}M_A(D),$$
the same holds for $W_A$, and $|K'_A(\tau D)-K_A(D)|\le K(\tau)+c$.

*Proof.* *A preliminary fact:* $B'\vdash\neg\tau(\bot)$. By (T1) with $\Gamma=\emptyset$, $B\vdash\neg\bot$ gives $B'\vdash\tau(\neg\bot)$, and (T2) converts this.
*Push forward.* The machine "run $G_U$ and emit $\tau(\chi)$ for every emitted $\chi$" emits $\tau[A_\omega]$. By (T1), $B'\cup\tau[A]\vdash\tau(\bot)$ iff $B\cup A\vdash\bot$; with the preliminary fact, $B'\cup\tau[A]$ is consistent iff $B\cup A$ is. By (T1) and (T2), $B'\cup\tau[A]\vdash\tau(\varphi)^b$ iff $B\cup A\vdash\varphi^b$ (for $b=0$: $B'\cup\tau[A]\vdash\neg\tau(\varphi)$ iff $\vdash\tau(\neg\varphi)$ iff $B\cup A\vdash\neg\varphi$). So this machine's event for $\tau D$ is exactly $E_D$, and Thm 4.1 in $\mathcal L'$ gives $M'_A(\tau D)\ge2^{-K(\tau)-c}M_A(D)$.
*Pull back.* For $A'\subseteq\Sent_{\mathcal L'}$ let $\tau^*(A'):=\{\varphi\in\Sent_{\mathcal L}:B'\cup A'\vdash\tau(\varphi)\}$. The set $G^*:=\{(w,\varphi):B'\cup A'_w\vdash\tau(\varphi)\}$ is c.e. and, by compactness as in Lemma 1.3, $A^{G^*}_\omega=\tau^*(A'_\omega)$. If $B'\cup A'$ is consistent, so is $B\cup\tau^*(A')$: if $B\cup\Gamma\vdash\bot$ for a finite $\Gamma\subseteq\tau^*(A')$, then $B'\cup\tau[\Gamma]\vdash\tau(\bot)$ by (T1), and $B'\cup A'$ proves every member of $\tau[\Gamma]$, so $B'\cup A'\vdash\tau(\bot)\wedge\neg\tau(\bot)$. If $B'\cup A'\vdash\tau(\varphi)^b$, then $\varphi^b\in\tau^*(A')$ (for $b=0$ via (T2)). So $G^*$'s event for $D$ contains the event for $\tau D$, and $M_A(D)\ge2^{-K(\tau)-c}M'_A(\tau D)$.
The same two maps act on single enumerator programs with a prefix of length $K(\tau)+c$, which gives the statements for $W_A$ and $K_A$. ∎

**Corollary 4.5 (adding vocabulary) [proved].** Let $\mathcal L\subseteq\mathcal L'$, $B'=B$ and $\tau$ the inclusion. (T1) holds because every $\mathcal L$-structure expands to an $\mathcal L'$-structure (with completeness, $B\cup\Gamma\vdash_{\mathcal L'}\varphi$ iff $B\cup\Gamma\vdash_{\mathcal L}\varphi$ for $\mathcal L$-sentences), and (T2) is trivial. Hence for data in the old vocabulary, $M_A^{\mathcal L'}(D)$ and $M_A^{\mathcal L}(D)$ agree up to a factor $2^{\pm c}$, $W_A$ likewise, $K_A^{\mathcal L'}(D)=K_A^{\mathcal L}(D)\pm c$, and predictive probabilities of $\mathcal L$-sentences agree up to $2^{\pm2c}$.

*Reading.* In the unbounded, universal setting, theoretical vocabulary buys at most a constant: the pull-back of a theory is its set of observational consequences, an r.e. set, and the universal machine enumerates it. This is the effective content of Craig's theorem inside the prior (Hempel's horn of the theoretician's dilemma). Class-level and penalised versions, and where vocabulary does pay (finite theories, resource bounds), are `terms` T1 and T5; Prop 1.8(d) shows that $K_{\rm fin}$ is not invariant in this way.

---

## 5. Loss bounds (target T5)

**Theorem 5.1 (loss against a theory that decides the data) [proved].** Let $(\varphi_t,b_t)_{t\le n}$ be any consistent reveal sequence, chosen in any way (in advance, adaptively, adversarially, non-computably; any order; repeats allowed), and let $T$ be an r.e. theory with $B\cup T$ consistent and $T\vdash\varphi_t^{b_t}$ for all $t\le n$. Then the cumulative loss in the semimeasure convention satisfies
$$L_A(D_n)-L_A(\emptyset)\ \le\ L_A(D_n)\ \le\ -\log\Unif_A(\Ext T)\ \le\ -\log\mm(\Ext T)+c\ \le\ -\log\mm_\equiv(T)+c\ \le\ K_\equiv(T)+c,$$
and also $L_A(D_n)\le-\log W_A(D_n)+c\le K_A(D_n)+c$.

*Proof.* Every consistent extension of $T$ proves every datum, so $E_{D_n}\supseteq\{\omega:B\cup A_\omega\text{ consistent},\ \Cn(A_\omega)\supseteq\Cn(T)\}$. Then Thm 4.1(i), $[T]\subseteq\Ext T$ and $\mm_\equiv(T)\ge2^{-K_\equiv(T)}$. $L_A(\emptyset)\ge0$; the left side is the cumulative loss by Prop 2.1(d). The last chain is Thm 4.1(iii) and $W_A\ge2^{-K_A}$. ∎

*Which complexity appears.* Not the complexity of an axiom set, and not a property of the data's syntax, but the algorithmic probability of the class of all consistent extensions of $T$, bounded by $K_\equiv(T)$, the complexity of $T$ *up to deductive equivalence*. Three consequences:
* the bound favours the *weakest* theory that decides the data ($\Cn T\subseteq\Cn T'$ implies $\Ext T'\subseteq\Ext T$);
* a non-finitely-axiomatisable theory such as $\PA$ has small $K_\equiv$ although every axiomatisation is infinite;
* if a theory has a complicated finite axiomatisation and a simple equivalent one, the simple one counts.

Compared with P1 Thm 5.1(b), where the loss on data from a partial computable $\varphi$ is at most $K(\varphi)+c$: a program is replaced by a theory up to equivalence, and the theory need not be complete, only decide the sentences asked.

**Proposition 5.2 (laws plus exceptions) [proved].**
(a) For every theory-machine law $\nu$: $L_A(D_n)\le-\log\nu(D_n)+K(\nu)$.
(b) For every r.e. $T$ and every $E\subseteq D_n$ (a sub-data-set) with $B\cup T\cup E^\pm$ consistent and $T\cup E^\pm\vdash\psi_{D_n}$: $L_A(D_n)\le K_\equiv(T)+K(E)+c$. Taking for $E$ the data $T$ does not prove gives a two-part, law-plus-exceptions bound.
(c) Let $(\alpha_j)_{j\ge1}$ be a computable family of sentences and $T$ r.e. such that $B\cup T\cup\{\alpha_j^{x_j}:j\ge1\}$ is consistent for every $x\in\{0,1\}^{\mathbb N}$. If every datum of $D_n$ is proved by $T$ or is one of the sentences $\alpha_j$ with some label, and $m$ distinct $j$ occur, then $L_A(D_n)\le K(T,(\alpha_j))+m+c$.

*Proof.* (a) Thm 4.1. (b) For $e\in[T]$, the set $\mathsf W_e\cup\{\psi_E\}$ has an index computable from $(e,E)$, is consistent with $B$ and proves $\psi_{D_n}$; $K(e,E)\le K(e)+K(E)+c$; minimise over $e$. (c) The machine "emit $T$ and $\alpha_j^{\omega_j}$ for all $j$" always has a consistent theory, which proves $D_n$ whenever $\omega$ agrees with the $m$ labels of the $\alpha_j$-data: probability $2^{-m}$. Apply (a). ∎

In (c) the exceptions cost one bit each, without paying for *which* atoms were exceptional; in (b) one pays $K(E)$, which includes their positions. (c) is the setting of `laws` (laws versus initial conditions).

**Proposition 5.3 (mistake bounds).**
(a) **[proved]** Under the hypotheses of Thm 5.1, the predictor that outputs the most probable of $1,0,\iota$ under $(\Bel,\Dis,\Indep)_{D_{t-1}}(\varphi_t)$ (ties broken arbitrarily; the stored label at a repeat) makes at most $-\log\big(\Unif_A(\Ext T)/M_A(\emptyset)\big)\le K_\equiv(T)+c$ mistakes, a mistake being any output other than $b_t$ ($\iota$ included).
(b) **[proved; computed: c3]** *The Kolmogorov predictor.* Fix a total order on $\dom V$ refining length. At step $t$ let $p_t$ be the first program $p$ with $B\cup\mathsf W_{V(p)}$ consistent and $\vdash\psi_{D_{t-1}}$; predict $1$ (resp. $0$) if $\mathsf W_{V(p_t)}$ proves $\varphi_t$ (resp. $\neg\varphi_t$), and abstain otherwise. If $k:=\sup_nK_A(D_n)<\infty$ (for instance $k\le K_\equiv(T)+c$ under Thm 5.1's hypotheses), it errs or abstains at most $2^k$ times.

*Proof.* (a) The posterior trichotomy sums to $1$, so if $M_A(b_t\mid D_{t-1},\varphi_t)=\Bel_{D_{t-1}}(\varphi_t^{b_t})>\frac12$ then $b_t$ is the unique maximiser. Each mistake therefore costs at least one bit of cumulative loss, which Thm 5.1 bounds by $L_A(D_n)-L_A(\emptyset)\le-\log\Unif_A(\Ext T)+\log M_A(\emptyset)$.
(b) At an error or abstention, $p_t$ does not prove $\varphi_t^{b_t}$, so it is incompatible with $D_t$ and with every later $D_{t'}$, and is never chosen again. Each $p_t$ has length $K_A(D_{t-1})\le k$. Kraft's inequality for the prefix-free set $\dom V$ gives at most $2^k$ programs of length $\le k$. ∎

The bound in (b) is essentially attained (Thm 11.3): the single shortest theory can be exponentially worse than the Bayes predictor of (a). This is the logical analogue of P1 Thm 9.10 (the conjunction ladder), and, as there, it is the selection rule that fails, not the prior.

**Theorem 5.4 (merging for three-valued data) [proved; computed: c1 A15].** Let $G$ be a theory machine with $\nu_G(\emptyset)=1$, $\omega\sim\Unif$ and $A:=A^G_\omega$. Let $(\xi_t)$ be random variables independent of $\omega$ (any joint law), and let the questions be $\varphi_t:=s_t(h_{t-1},\xi_t)$ for arbitrary measurable rules $s_t$, where $h_{t-1}=(\varphi_1,y_1,\dots,\varphi_{t-1},y_{t-1})$ and $y_t\in Y_3$ is $A$'s trichotomy label of $\varphi_t$. Let $D_t:=\{(\varphi_s,y_s):s\le t\}$ and
$$d_t:=\KL\big(\nu^3_G(\cdot\mid D_{t-1},\varphi_t)\,\big\|\,M_A^3(\cdot\mid D_{t-1},\varphi_t)\big)\ \text{bits}\qquad(d_t:=0\text{ at a repeat}).$$
Then for every $n$
$$\sum_{t\le n}\Ex d_t=\Ex\log\frac{\nu^3_G(D_n)}{M_A^3(D_n)}+\log M_A(\emptyset)\ \le\ K(G)+\log M_A(\emptyset)\ <\ K(G).$$
Hence $\sum_t\Ex d_t\le K(G)$, $d_t\to0$ almost surely, and $\sum_t\Ex\|\nu^3_G(\cdot\mid D_{t-1},\varphi_t)-M^3_A(\cdot\mid D_{t-1},\varphi_t)\|_1^2\le2\ln2\cdot K(G)$.

*Proof.* *Step 1 (the conditional law of the next label).* Histories take countably many values. For a history value $h$ and a value of $\xi_{<t}$, the event $\{h_{t-1}=h\}$ is the intersection of an event in $\xi_{<t}$ (the rules produce $h$'s questions from $h$'s labels) with the event $\{f^G_\omega\supseteq D_h\}$, where $f^G_\omega$ is the trichotomy function of $A^G_\omega$ (Prop 2.1(g), for $G$). Since $\xi$ is independent of $\omega$, given $(h_{t-1},\xi_{\le t})$ the tape has law $\Unif(\cdot\mid f^G\supseteq D_{t-1})$, and $y_t=f^G_\omega(\varphi_t)$ has law $\nu^3_G(\cdot\mid D_{t-1},\varphi_t)$. (Almost surely $\nu^3_G(D_{t-1})>0$.)
*Step 2 (telescoping).* Let $Z_t:=\log\nu^3_G(y_t\mid D_{t-1},\varphi_t)-\log M_A^3(y_t\mid D_{t-1},\varphi_t)$ ($0$ at a repeat) and $S_n:=\sum_{t\le n}Z_t$. Since $\nu^3_G(\emptyset)=1$ and $M_A^3(\emptyset)=M_A(\emptyset)$, $S_n=\log\nu^3_G(D_n)-\log M_A^3(D_n)+\log M_A(\emptyset)$.
*Step 3 (integrability).* By Thm 4.1, $M^3_A\ge2^{-K(G)}\nu^3_G$, so $S_n\le K(G)+\log M_A(\emptyset)$ pointwise. Since $-\log M^3_A(D_n)\ge0$, $S_n\ge\log\nu^3_G(D_n)+\log M_A(\emptyset)$. And $\Ex[-\log\nu^3_G(D_n)]=\sum_{t\le n}\Ex[H_t]\le n\log3$, where $H_t$ is the entropy of $\nu^3_G(\cdot\mid D_{t-1},\varphi_t)$, a distribution on three points: the summands $-\log\nu^3_G(y_t\mid\cdots)$ are nonnegative, so the tower property applies by Step 1 without further conditions. Hence $S_n$ is integrable, and so is each $Z_t=S_t-S_{t-1}$.
*Step 4.* By Step 1, $\Ex[Z_t\mid h_{t-1},\xi_{\le t}]=d_t$. Taking expectations and summing, $\sum_{t\le n}\Ex d_t=\Ex S_n$, which is the displayed identity and bound. Pinsker's inequality in bits, $\KL\ge\|P-Q\|_1^2/(2\ln2)$, gives the last claim, and $\Ex\sum_td_t<\infty$ gives $d_t\to0$ a.s. ∎

With two-valued data the rule would have to see $A$ (ask only questions $A$ decides) for the two-valued conditionals to be the data law, and the expected bound can fail, as in P1's remark after its Thm 5.3. The pathwise bound Prop 5.2(a) still holds.

**Corollary 5.5 (three-valued loss bound) [proved].** If $D_n$ is three-valued and labelled by the trichotomy of a consistent r.e. theory $T$, then in any reveal order the three-valued cumulative loss is $-\log M_A^3(D_n)+\log M_A(\emptyset)\le-\log\Unif_A[T]\le K_\equiv(T)+c$.

*Proof.* Tapes with $\Cn(A_\omega)=\Cn(T)$ lie in $E^3_{D_n}$; order independence is Prop 2.1(d) for $M_A^3$, with the same proof; then Thm 4.1(i). ∎

Here $[T]$ replaces $\Ext T$: three-valued data penalise theories that decide more than $T$.

**Proposition 5.6 (lower bound) [proved].** For every data set $D$, $L_A(D)\ge K(b_D\mid\dom D)-c$, where $b_D$ is the vector of two-valued labels in canonical order. So on fair-coin labels of any fixed $n$ sentences, $\Ex L_A\ge n-c$, whatever the sentences.

*Proof.* Prop 6.1(b). For the expectation: $\sum_b2^{-K(b\mid\dom D)}\le1$, so Gibbs' inequality gives $\Ex_bK(b\mid\dom D)\ge n$ for uniform $b\in\{0,1\}^n$. ∎

---

## 6. Versions: coding bounds and no coding theorem (target T6)

**Proposition 6.1 (coding lower bound and the chain) [proved].**
(a) Let $S$ be a finite set of pairwise $B$-incompatible sentences and $\sigma\in S$. Then $-\log\Bel_0(\sigma)=-\log M_A(\{(\sigma,1)\})\ge K(\sigma\mid S)-c$.
(b) For every data set $D$, $L_A(D)\ge K(b_D\mid\dom D)-c$.
(c) For every consistent $D$ and every finite set $S$ of pairwise $B$-incompatible sentences with $\psi_D\in S$,
$$2^{-K_A(D)}\le W_A(D)\le2^cM_A(D)\le2^{K(S)+c}\,2^{-K_A(D)} .$$
With $S$ the $2^{|\dom D|}$ label conjunctions on $\dom D$ (two-valued part), $K(S)\le K(\dom D)+c$.

*Proof.* (a) Let $Q_S(\sigma)$ be the probability, over $\omega$, that the following procedure outputs $\sigma$: at stage $s$, read $\omega_{1:s}$, run $s$ steps of the enumeration of $G_U$ on it, and test all derivations of size $\le s$ from $B$ and the axioms emitted so far, for every member of $S$ in a fixed order; output the first member found. The output events are disjoint open sets, so $\sum_{\sigma\in S}Q_S(\sigma)\le1$, and $Q_S(\sigma)$ is lsc uniformly in $(S,\sigma)$. If $B\cup A_\omega$ is consistent and proves $\sigma$, it proves no other member of $S$, so the procedure outputs $\sigma$: $\Bel_0(\sigma)\le Q_S(\sigma)$. The conditional coding theorem (P1 §3.1: $K(a\mid z)\le-\log P(a\mid z)+K(P)+c$ for uniformly lsc $P$ with $\sum_aP(a\mid z)\le1$) gives $K(\sigma\mid S)\le-\log Q_S(\sigma)+c$.
(b) Apply (a) with $S$ the label conjunctions on $\dom D$ (pairwise logically incompatible, computable from $\dom D$) and $\sigma:=\psi_D$, so that $M_A(D)=\Bel_0(\psi_D)$ (Prop 2.1(c)); from $\dom D$ and $\psi_D$ one computes $b_D$, so $K(b_D\mid\dom D)\le K(\psi_D\mid S)+c$.
(c) First inequality: one term of $W_A$. Second: Thm 4.1(iii). Third: $K_A(D)\le K(\psi_D)+c$ (Prop 1.8(c)) $\le K(S)+K(\psi_D\mid S)+c'$, and (a) bounds $K(\psi_D\mid S)$ by $L_A(D)+c$. ∎

The slack $K(S)$ is the complexity of a *question* containing the data's conjunction, in place of P1's $K(\dom D)$ (P1 Thm 4.4); it can be much smaller (e.g. $S=\{\psi_D,\neg\psi_D\}$ gives slack $K(\psi_D)$, useless, but a simple question such as "which of these $m$ incompatible laws holds" gives slack $K(m)$).

**Theorem 6.2 (no coding theorem for axiom systems) [proved; computed: c4].** Work in the literal language of Notation §3.4 ($t_w$, $R$), with $B$ decidable, $R$-free, and having a model in which the closed terms $t_w$ are pairwise distinct (e.g. $B=\emptyset$). For every $d\ge2$ there are distinct $x_1,x_2\in\{0,1\}^d$ such that $D:=\{(R(t_{x_1}),0),(R(t_{x_2}),1)\}$ satisfies
(i) $K_A(D)\ge\ell_d>\log d-2$, with $\ell_d:=\lceil\log(d/\log3)\rceil-1$, and $W_A(D)\le\Omega_V^{\ge\ell_d}:=\sum\{2^{-|p|}:p\in\dom V,\ |p|\ge\ell_d\}$;
(ii) $-\log W_A(D)\le2+K(\lceil\log(d+1)\rceil)+c$;
(iii) $-\log M_A(D)\le2+c$.
Parts (ii) and (iii) hold for every data set of two literals on distinct words of length $\le d$. Hence $K_A(D)+\log W_A(D)\ge\log d-K(\lceil\log(d+1)\rceil)-c-4\to\infty$, and $M_A(D)/W_A(D)\ge2^{-c-2}/\Omega_V^{\ge\ell_d}\to\infty$: no two of $2^{-K_A}$, $W_A$, $M_A$ agree up to a constant factor.

**Lemma 6.2a (literals of a fresh predicate) [proved].** Under the hypothesis on $B$: (L1) every set $\Lambda$ of literals $R(t_w)^{b}$ with at most one literal per word is consistent with $B$; (L2) if $B\cup\Lambda$ is consistent, then $B\cup\Lambda\vdash R(t_y)^b$ only if $R(t_y)^b\in\Lambda$.

*Proof.* (L1) Expand the model of $B$ in which the $t_w$ are distinct by $R:=\{t_w^{\mathfrak M}:R(t_w)\in\Lambda\}$; $B$ is $R$-free, so it stays true. (L2) If $R(t_y)^{1-b}\in\Lambda$, proving $R(t_y)^b$ would make $B\cup\Lambda$ inconsistent. If neither literal of $t_y$ is in $\Lambda$, then $\Lambda\cup\{R(t_y)^{1-b}\}$ is consistent by (L1). ∎

*Proof of Theorem 6.2.* (i) Let $\ell:=\ell_d$, so $2^\ell<d/\log3$ and $3^{2^\ell}<2^d$. There are fewer than $2^\ell$ programs of length $<\ell$. Colour each $x\in\{0,1\}^d$ by the vector, over these programs $p$, of: "+" if $B\cup\mathsf W_{V(p)}$ is consistent and proves $R(t_x)$; "−" if it is consistent and proves $\neg R(t_x)$; "∗" otherwise. There are at most $3^{2^\ell-1}<2^d$ colours, so two distinct words $x_1,x_2$ share a colour. A program $p$ with $|p|<\ell$ compatible with $D$ would colour $x_1$ "−" and $x_2$ "+". So every compatible program has length $\ge\ell$, which gives both claims of (i); and $\ell\ge\log(d/\log3)-1>\log d-2$ since $\log\log3<0.67$.
(ii) Let $j(x)$ be the position of $x$ in the length-lexicographic order ($j(\epsilon)=0$), so $j(x)\le2^{d+1}-2$ for $|x|\le d$. Let $s:=\lceil\log(d+1)\rceil$ and $L:=2^{2^s}\ge2^{d+1}$. For $u\in\{0,1\}^L$ let $\Lambda_u:=\{R(t_x)^{u_{j(x)+1}}:j(x)<L\}$, consistent by (L1), and proving $R(t_x)^b$ iff $u_{j(x)+1}=b$ by (L2). A fixed prefix machine reads a $V$-program for $s$, computes $L$, reads $L$ further bits $u$ and outputs an index of $\Lambda_u$; by universality of $V$ a fixed string $r$ makes $r\,q\,u\in\dom V$ a program for that index, for $q$ a shortest program for $s$. These $2^L$ programs are distinct and have length $|r|+K(s)+L$. For a two-point $D$ on distinct words of length $\le d$, exactly a quarter of the $u$ give a compatible $\Lambda_u$. So $W_A(D)\ge2^L\cdot\frac14\cdot2^{-|r|-K(s)-L}$.
(iii) The theory machine $G_{\rm coin}:=\{(w,R(t_x)^{w_{j(x)+1}}):|w|=j(x)+1\}$ emits $\{R(t_x)^{\omega_{j(x)+1}}:x\in\{0,1\}^*\}$, consistent by (L1); it proves $D$ iff $\omega$ agrees with $D$'s labels at two positions (L2), with probability $\frac14$. Apply Thm 4.1.
The consequences: $K_A+\log W_A\ge\ell_d-2-K(s)-c$; $\Omega_V^{\ge\ell}$ is the tail of a convergent series and $\ell_d\to\infty$. ∎

This is P1 Thm 4.9 for axiom systems, proved directly with theory machines, so it does not depend on the transfer theorem of `sfi` T5. The mechanism is the same as in P1: deterministic programs (here r.e. axiom sets) cannot separate atoms cheaply, while a coin can.

**Remark 6.3 (what else transfers) [proved, given `sfi` T5 and P1].** By `sfi` T5 (SAI agrees with SOI up to constants on positive literals of a fresh predicate; scout S Thm 2.7, scout F's F9), P1 Cor 4.10 (two-point rate: $\log d-O(1)\le\max(K_A-L_A)\le\log d+O(\log\log d)$) and P1 Prop 4.7 (shared randomness is not a mixture of private coin facts) hold for $M_A$, $W_A$, $K_A$ on literal data. *Large gaps have no computable witnesses* [proved directly]: along a computable family $k\mapsto D_k$ of consistent data sets, $K_A(D_k)\le K(\psi_{D_k})+c\le K(k)+c'$ while $L_A\ge0$, so $2^{-K_A}$, $W_A$ and $M_A$ agree up to $K(k)+c'$ bits.

**Proposition 6.4 (coding for whole theories).** For an r.e. set $X\subseteq\Sent$ let $K_{\rm enum}(X):=\min\{|p|:p\in\dom V,\ \mathsf W_{V(p)}=X\}$ and $\mm_{\rm enum}(X):=\sum\{2^{-|p|}:p\in\dom V,\ \mathsf W_{V(p)}=X\}$.
(a) **[proved]** For every r.e. $T$: $K_\equiv(T)=K_{\rm enum}(\Cn T)\pm c$ and $2^{-c}\mm_{\rm enum}(\Cn T)\le\mm_\equiv(T)\le2^c\mm_{\rm enum}(\Cn T)$.
(b) **[proved, given Solovay 1977 (known, unverified)]** $-\log\mm_\equiv(T)\le K_\equiv(T)\le3\,(-\log\mm_\equiv(T))+O\big(\log(-\log\mm_\equiv(T))\big)+c$.

*Proof.* (a) Let $\kappa$ be computable and injective with $\mathsf W_{\kappa(e)}=\Cn(\mathsf W_e)$ (s-m-n with padding). Every $e'$ with $\mathsf W_{e'}=\Cn T$ lies in $[T]$, so $K_\equiv(T)\le K_{\rm enum}(\Cn T)$ and $\mm_\equiv(T)\ge\mm_{\rm enum}(\Cn T)$. Conversely $\kappa$ maps $[T]$ into $\{e':\mathsf W_{e'}=\Cn T\}$, with $K(\kappa(e))\le K(e)+c$ and $\mm(\kappa(e))\ge2^{-c}\mm(e)$ (the image of $\mm$ under $\kappa$ is an lsc semimeasure). (b) The left inequality is one term of the sum. For the right one, Solovay's theorem (as recorded by scout F from Vereshchagin's abstract) is $K_{\rm enum}(X)\le3I(X)+O(\log I(X))$ for every r.e. $X$, with $I(X)$ the negative logarithm of the probability that a randomised algorithm enumerates exactly $X$. That probability is at least $2^{-c}\mm_{\rm enum}(X)$ (a deterministic program is a randomised algorithm), so the inequality also holds with $I(X):=-\log\mm_{\rm enum}(X)$; apply it to $X=\Cn T$ and use (a). ∎

*Status change.* Scout F's F12 claimed the factor 2, via Vereshchagin (2007, finite sets) and Shekhovtsov–Zakharov (2023, transfer to all sets). Neither could be checked in this round, so, as the brief prescribes, the statement is downgraded to Solovay's factor 3. The one-tape form, with $\Unif_A[T]$ in place of $\mm_\equiv(T)$, is in Prop 11.5.

---

## 7. The consistency-requiring variants (target T7)

Let $H_\omega:=B\cup A_\omega\cup D^\pm$ (the hypothesis plus the data) and $\varepsilon_\emptyset:=\Unif\{\omega:A_\omega=\emptyset\}\ge2^{-|p_\emptyset|}>0$, with $p_\emptyset$ a $V$-program for an index of the empty machine.

**Proposition 7.1 (the 0/1 CR weight is a plausibility and does not discriminate) [proved; computed: c1 A9, A10].**
(a) For $\varphi\notin\dom D$: $M_A^{\rm nc}(D+(\varphi,1))+M_A^{\rm nc}(D+(\varphi,0))=M_A^{\rm nc}(D)+\Unif\{H_\omega\text{ consistent and decides neither }\varphi\text{ nor }\neg\varphi\}\ge M_A^{\rm nc}(D)$. So $M_A^{\rm nc}$ is not a semimeasure; it is the plausibility $\Pl_0(\psi_D)$ (Prop 2.3), the dual of a belief function.
(b) $M_A^{\rm nc}(D)\ge\varepsilon_\emptyset$ for every consistent $D$: $-\log M_A^{\rm nc}\le\log(1/\varepsilon_\emptyset)$ on all consistent data. The coin-free CR weight is $\ge2^{-|p_\emptyset|}$, and the Kolmogorov CR version $K_A^{\rm nc}(D):=\min\{|p|:B\cup\mathsf W_{V(p)}\cup D^\pm\text{ consistent}\}$ is $\le|p_\emptyset|$ on all consistent $D$.
(c) The CR posterior after $D$ is the prior restricted to the tapes whose theory is consistent with $D$: data eliminate hypotheses but never change the odds between survivors (one-tape form of AI-paper Prop 2.22(b) and pa Prop 5.2).

*Proof.* (a) For consistent $H$, $H\cup\{\varphi^b\}$ is consistent iff $H\nvdash\varphi^{1-b}$, so both labels are possible iff $H$ decides neither, and exactly one otherwise; for inconsistent $H$ neither. (b) If $A_\omega=\emptyset$, $H_\omega=B\cup D^\pm$ is consistent. (c) By definition. ∎

**Proposition 7.2 (the CR predictor).**
(a) **[proved; computed: c2 B1]** For every consistent $D$ and $\varphi\notin\dom D$ with $B\cup D^\pm\nvdash\varphi^b$: $\Bel^{\rm nc}_D(\varphi^b)\le1-\varepsilon_\emptyset/M_A^{\rm nc}(D)\le1-\varepsilon_\emptyset$. So on every consistent reveal sequence the CR cumulative loss $\sum_t-\log\Bel^{\rm nc}_{D_{t-1}}(\varphi_t^{b_t})$ is at least $\log\frac1{1-\varepsilon_\emptyset}$ times the number of steps whose datum is not entailed by the earlier data. Example: with distinct literals of a fresh predicate (Lemma 6.2a), the stream $(R(t_{w_j}),1)_{j\ge1}$ has no entailed datum (L2), so CR loses at least $n\log\frac1{1-\varepsilon_\emptyset}$ on $n$ data; $T:=\{\forall x\,R(x)\}$ decides the stream, so proof-requiring SAI loses at most $K_\equiv(T)+c=O(1)$ (Thm 5.1).
(b) **[proved; computed: c2 B2]** For some theory-machine laws the CR cumulative loss depends on the reveal order. Example: $G:=\{(1,a)\}$ (theory $\{a\}$ on tapes beginning with 1, $\emptyset$ otherwise), with $a,c$ distinct literals of a fresh predicate, and $D:=\{(a,1),(a\vee c,1)\}$: the order $(a,a\vee c)$ has CR probability $\frac12$, the order $(a\vee c,a)$ has $\frac14$. Whether the CR loss of $M_A$ itself is order dependent is **[open]**.

*Proof.* (a) The tapes with $A_\omega=\emptyset$ are in the denominator of $\Bel^{\rm nc}_D$ and not in its numerator. (b) Order $(a,a\vee c)$: $\Bel^{\rm nc}_\emptyset(a)=\frac12$ (only $\{a\}$ proves $a$), and then $a\vee c$ is entailed. Order $(a\vee c,a)$: $\Bel^{\rm nc}_\emptyset(a\vee c)=\frac12$; given $a\vee c$, both theories remain consistent and only $\{a\}\cup\{a\vee c\}$ proves $a$, so the second factor is $\frac12$. ∎

The CR *posterior* is order independent (it depends on $D$ as a set); its predictive probabilities do not chain, because $\Bel^{\rm nc}_D(\varphi)\ne M_A^{\rm nc}(D+(\varphi,1))/M_A^{\rm nc}(D)$. For $M_A$ the difference between the two orders in (b) is a signed combination of the masses of the theory types on $\{a,c\}$, which universality does not sign; the normalised proof-requiring case (Thm 11.1) is different because there the difference is a sum of nonnegative terms.

**Proposition 7.3 (graded CR) [proved; computed: c1 A12].**
(a) For consistent $A$, $\nu^{1/2}_A$ is a weak semimeasure on data sets (P1 Def 3.2) with $\nu^{1/2}_A(\emptyset)=1$, and is order independent (a product over the set). Hence $M_A^{1/2}$ is a weak semimeasure with $M_A^{1/2}(\emptyset)=1-\Inc_0$, and its conditionals form an order-independent predictor (P1 Prop 3.3).
(b) $M_A^{1/2}\ge M_A$.
(c) It charges for entailed data: for distinct literals $p,q$ of a fresh predicate and $D:=\{(p,1)\}$, $M_A^{1/2}(D+(p\vee q,1))\le M_A^{1/2}(D)-\varepsilon_\emptyset/4$, although $B\cup D^\pm\vdash p\vee q$. So $M_A^{1/2}$ is not the law of any theory machine (Prop 2.1(c)).
(d) It depends on how the data are packaged: $M_A(\{(p\wedge q,1)\})=M_A(\{(p,1),(q,1)\})$ (Prop 2.1(c)), but $M_A^{1/2}(\{(p\wedge q,1)\})-M_A^{1/2}(\{(p,1),(q,1)\})\ge\varepsilon_\emptyset/4$.

*Proof.* (a) Let $B\cup A\cup D^\pm$ be consistent (otherwise every term is $0$). If $B\cup A\vdash\varphi^{b^*}$, then $D+(\varphi,b^*)$ keeps the value (consistent, factor $1$) and $D+(\varphi,1-b^*)$ is inconsistent with $A$. If $A$ decides neither, each extension has factor at most $\frac12$. (b) For consistent $A$ proving $\psi_D$, $\nu^{1/2}_A(D)=1$. (c) For each consistent $A$ the new datum keeps consistency (it is entailed) and multiplies by $1$ or $\frac12$; for $A=\emptyset$ the value drops from $\frac12$ to $\frac14$. (d) Per consistent theory: if it proves $p\wedge q$, both values are $1$; if it proves exactly one of $p,q$ and is consistent with the other, both are $\frac12$; if it proves neither and is consistent with $p\wedge q$, they are $\frac12$ and $\frac14$; otherwise both are $0$. Integrate; the empty theory contributes $\varepsilon_\emptyset/4$. ∎

**Proposition 7.4 (the CR predictor decomposes; N1's N10) [proved; computed: c1 A11].** For every $D$ with $M_A^{\rm nc}(D)>0$ and every $\varphi$,
$$M_A^{\rm nc}(D)\,\Bel^{\rm nc}_D(\varphi)=M_A(D)\,\Bel_D(\varphi)+\Unif\{\omega:H_\omega\text{ consistent},\ B\cup A_\omega\nvdash\psi_D,\ H_\omega\vdash\varphi\}.$$
So the CR predictor is the mixture, with weight $\lambda_D:=M_A(D)/M_A^{\rm nc}(D)$, of the proof-requiring predictor and a "weak theory plus the data" predictor.

*Proof.* Split the CR event by whether $B\cup A_\omega\vdash\psi_D$. If it does, $H_\omega$ is equivalent to $B\cup A_\omega$: consistency of $H_\omega$ is that of $B\cup A_\omega$ and $H_\omega\vdash\varphi$ iff $B\cup A_\omega\vdash\varphi$, which gives $\Unif(E_D\cap O_\varphi)=M_A(D)\Bel_D(\varphi)$. ∎

The weak component contains the empty theory (mass $\ge\varepsilon_\emptyset$), which predicts from the data alone; that is the source of Prop 7.2(a).

### 7.5 Why the proof-requiring variant is primary

The precise reasons, each a result above:
1. **It is the law of a random object.** $M_A$ is the probability that a random consistent theory proves the data. Its weights form a semimeasure (Prop 2.1(b)), its cumulative loss is order independent and depends only on the content $\Cn(D^\pm)$ of the data (Prop 2.1(c),(d)), and its predictions are posterior averages of what individual theories prove.
2. **It has the learning guarantees.** Dominance over every theory-machine law (Thm 4.1), loss at most $K_\equiv(T)+c$ against every consistent r.e. theory deciding the data (Thm 5.1), mistake bounds and merging (Prop 5.3, Thm 5.4).
3. **The 0/1 CR weight does not discriminate.** It is bounded below by $\varepsilon_\emptyset$ on all consistent data (Prop 7.1(b)): data only eliminate theories and never reweight the survivors, so the inductive work is done by adding the data to the hypothesis. Its proper predictor (Dempster) pays a constant on every datum not entailed by earlier data, linearly many bits where PR pays $O(1)$ (Prop 7.2(a)), and its cumulative loss can depend on the order (Prop 7.2(b)).
4. **Graded CR is not a law of theories.** It dominates PR, but it charges for entailed data and depends on how the data are packaged (Prop 7.3(c),(d)); its advantage over PR can come within $2|D|+O(\log)$ bits of $K(\dom D)+|D|$ (Prop 11.2), which measures packaging, not better induction.

In one sentence: under PR a theory must *explain* every datum; under CR it need only *tolerate* it, and toleration is too weak to discriminate between theories.

---

## 8. Limits and identification (target T8)

**Lemma 8.0 (majority vote) [proved].** Let $Z$ be a decidable set of sentences, $\Phi$ an oracle machine that on tape $\omega$ and input $\sigma\in Z$ outputs $\Phi^\omega(\sigma)\in\{0,1\}$ or diverges, $S\subseteq Z$, $g:S\to\{0,1\}$, and $\mathcal G$ a Borel set of tapes with $\Unif(\mathcal G)>0$ such that for every $\omega\in\mathcal G$, $\Phi^\omega(\sigma)$ is defined for all $\sigma\in Z$ and equals $g(\sigma)$ for $\sigma\in S$. Then some total computable $h:Z\to\{0,1\}$ extends $g$.

*Proof.* By outer regularity there is an open $U\supseteq\mathcal G$ with $\Unif(U)<\frac43\Unif(\mathcal G)$; writing $U$ as a disjoint union of cylinders, some cylinder $[u]$ has $\Unif(\mathcal G\cap[u])>\frac34\,2^{-|u|}$. For $b\in\{0,1\}$ let $O_b(\sigma):=\{\omega\in[u]:\Phi^\omega(\sigma)=b\}$: effectively open uniformly in $\sigma$ (a halting computation reads a finite prefix), and disjoint for $b=0,1$; their measures are left-c.e., with computable approximations from below. Let $h(\sigma)$ be the $b$ with the larger approximated measure at the first stage where the two approximations sum to more than $\frac12\,2^{-|u|}$. That stage exists because $\Unif(O_0(\sigma)\cup O_1(\sigma))\ge\Unif(\mathcal G\cap[u])>\frac34\,2^{-|u|}$. For $\sigma\in S$ the wrong set $O_{1-g(\sigma)}(\sigma)$ lies in $[u]\setminus\mathcal G$, of measure $<\frac14\,2^{-|u|}$; so at that stage the right set has measure $>\frac14\,2^{-|u|}$, more than the wrong one. ∎

This is the averaging argument behind de Leeuw, Moore, Shannon and Shapiro (1956) (known, unverified as to its exact form), in the form needed below. It replaces scout F's use of that theorem (F26(a)) and of the PA-degree facts (F27).

Throughout, $D_\infty$ is a consistent infinite stream, $E_n:=E_{D_n}$ (decreasing), $E_\infty:=\bigcap_nE_n=\{\omega:B\cup A_\omega\text{ consistent},\ \Cn(A_\omega)\supseteq D_\infty^\pm\}$, $a_n:=\Unif(E_n)$, $a:=\Unif(E_\infty)$, $P_n:=\Unif(\cdot\mid E_n)$.

**Proposition 8.1 (limit posterior) [proved; computed: c1 A13].**
(a) If $a>0$, then $\sup_{\mathcal X}|P_n(\mathcal X)-P_\infty(\mathcal X)|\le(a_n-a)/a_n\to0$ with $P_\infty:=\Unif(\cdot\mid E_\infty)$. Hence $\sup_\chi|\Bel_{D_n}(\chi)-\Bel_\infty(\chi)|\to0$ with $\Bel_\infty(\chi):=P_\infty(O_\chi)$, likewise for $\Dis$ and $\Indep$, and the cumulative loss converges to $-\log(a/M_A(\emptyset))$.
(b) If $a=0$, then $M_A(D_n)\to0$ and the cumulative loss tends to $\infty$.
(c) $a\ge\Unif_A(\Ext T)\ge2^{-K_\equiv(T)-c}$ whenever some consistent r.e. $T$ proves every datum of $D_\infty$.

*Proof.* (a) For a Borel $\mathcal X$ let $x:=\Unif(\mathcal X\cap E_\infty)\le a$ and $y_n:=\Unif(\mathcal X\cap(E_n\setminus E_\infty))\le a_n-a$. Then $|(x+y_n)/a_n-x/a|=|y_na-x(a_n-a)|/(a\,a_n)\le\max(y_na,\,x(a_n-a))/(a\,a_n)\le(a_n-a)/a_n$, and $a_n\downarrow a$ by continuity from above. (b) Continuity from above. (c) As in Thm 5.1. ∎

**Question Q1** (scout F). Does $a>0$ imply that some consistent r.e. theory proves $D_\infty^\pm$? By Prop 8.6(a) below, yes when $\Cn(D_\infty^\pm)$ is complete (then it is decidable and is itself such a theory). In general **no**: `logic` T1 (N1's lottery) gives a stream with $a>0$ and no such theory; the answer is yes for bounded inconsistency arity and for $\Pi_1$ streams (`logic` T1, T2).

**Proposition 8.2 (complete decidable truths are identified up to equivalence) [proved].** Let $T^*$ be consistent and r.e. with $B\cup T^*$ complete (hence decidable), and $\Cn(D_\infty^\pm)=\Cn(T^*)$ (for instance, every sentence appears with its $T^*$-label, or $T^*$'s axioms appear labelled true). Then $P_n(\{\omega:\Cn(A_\omega)=\Cn(T^*)\})\to1$, $\sup_\chi|\Bel_{D_n}(\chi)-\ind[T^*\vdash\chi]|\to0$, $\sup_\chi\Indep_{D_n}(\chi)\to0$, and the cumulative loss converges to $-\log(\Unif_A[T^*]/M_A(\emptyset))\le K_\equiv(T^*)+c$. If $T^*$ is axiomatised by one sentence $\tau$ and $(\tau,1)\in D_n$, then $P_n([T^*])=1$ from then on.

*Proof.* A complete consistent theory has no proper consistent extension, so $E_\infty=\{\omega:\Cn(A_\omega)=\Cn(T^*)\}$, of positive measure by Thm 4.1(i); on it the trichotomy is $\ind[T^*\vdash\chi]$ for all $\chi$ at once. Apply Prop 8.1. If $\psi_{D_n}\vdash\tau$, then $E_n=E_\infty$. ∎

*Examples* (completeness and decidability known; standard, references not re-verified): Presburger arithmetic, dense linear orders without endpoints, real closed fields, algebraically closed fields of fixed characteristic.

**Proposition 8.3 (incomplete r.e. truths: two-valued against three-valued data) [proved; computed: c1 A14].** Let $T^*$ be consistent and r.e. with $B\cup T^*$ incomplete.
(a) *Two-valued data.* If $\Cn(D_\infty^\pm)=\Cn(T^*)$, then $P_\infty=\Unif(\cdot\mid\{\omega:B\cup A_\omega\text{ consistent},\ \Cn(A_\omega)\supseteq\Cn(T^*)\})$, the prior restricted to the consistent extensions of $T^*$; this is not identification. For every $\psi$ independent of $B\cup T^*$:
$$\lim_n\Bel_{D_n}(\psi)=\frac{\Unif_A(\Ext(T^*+\psi))}{\Unif_A(\Ext T^*)}\in(0,1),\quad\lim_n\Dis_{D_n}(\psi)=\frac{\Unif_A(\Ext(T^*+\neg\psi))}{\Unif_A(\Ext T^*)}\in(0,1),\quad\lim_n\Indep_{D_n}(\psi)\ge\frac{\Unif_A[T^*]}{\Unif_A(\Ext T^*)}>0 .$$
(b) *The most probable class can be a strict extension.* In the setting of Lemma 6.2a with pairwise distinct closed terms $t_i$ ($i\in\mathbb N$), let $U:=\{R(t_i):i\in\mathbb N\}$ and $T_j:=U\setminus\{R(t_j)\}$. Then $\sum_j\Unif_A[T_j]\le1$, so $\Unif_A[T_j]\to0$, while $\Unif_A[U]\ge2^{-c}$. Hence for all but finitely many $j$, on data presenting $T_j$ (e.g. $R(t_i)$ labelled true for all $i\ne j$) the limit posterior gives the class $[U]$, a strict extension asserting $R(t_j)$, which $T_j$ leaves undecided, more probability than $[T_j]$.
(c) *Three-valued data.* If every sentence appears with its $T^*$-trichotomy label, then $\Unif(\{\Cn(A_\omega)=\Cn(T^*)\}\mid E^3_{D_n})\to1$. A three-valued presentation of $T^*$ on a set $S$ of sentences leaves the prior restricted to the theories whose trichotomy agrees with $T^*$'s on $S$.

*Proof.* (a) $E_\infty$ is the event of the display. $T^*+\psi$, $T^*+\neg\psi$ and $T^*$ are consistent r.e. theories, so all three ratios are positive by Thm 4.1(i); each of the first two is $<1$ because the other is positive; the classes $\{\Cn(A)=\Cn(T^*)\}$ lie in the independent part. (b) $T_j\nvdash R(t_j)$ by (L2) while $T_{j'}\vdash R(t_j)$ for $j'\ne j$, so the classes $[T_j]$ are pairwise distinct and their events disjoint. $U$ is r.e. with an index of complexity $O(1)$. The limit posterior odds of $[U]$ against $[T_j]$ are $\Unif_A[U]/\Unif_A[T_j]$ by (a). (c) A consistent theory that proves every $T^*$-theorem and decides no $T^*$-independent sentence has $\Cn(A)=\Cn(T^*)$: a theorem $\sigma\notin\Cn(T^*)$ of $A$ would be $T^*$-refutable (then $A$ is inconsistent) or $T^*$-independent (then labelled $\iota$ and decided). The class has positive measure by Thm 4.1(i); apply Prop 8.1 to $M_A^3$, whose proof is the same. ∎

(b) settles scout F's F24(a) remark, which was a proof sketch: it needed an upper bound on $\Unif_A[T^*]$ for a complicated subtheory $T^*$ of $\PA$. The disjointness argument above gives such bounds for all but finitely many members of any infinite family of pairwise inequivalent theories with a common simple extension. The $\PA$ version (every r.e. $T^*$ with $\Q\subseteq T^*\subseteq\PA$ and $K_\equiv(T^*)$ large) follows from Prop 11.5(c), given Solovay's theorem in its probabilistic reading.

**Proposition 8.4 (text versus informant) [proved; known in substance: Gold 1967 (unverified)].** In the setting of Lemma 6.2a, let $\Lambda_k:=\{R(t_i):i<k\}$ and $\Lambda_\infty:=\{R(t_i):i\in\mathbb N\}$. Call a sequence $(\sigma_t)$ of sentences a *text* for $T$ if $\Cn(\{\sigma_t:t\})=\Cn(T)$ (two-valued data $(\sigma_t,1)$; a datum $(\varphi,0)$ is the datum $(\neg\varphi,1)$). No function $F$ from finite sequences of sentences to deductive classes (computable or not) identifies in the limit, on every text, every member of $\{[\Lambda_k]:k\ge1\}\cup\{[\Lambda_\infty]\}$. In particular no learner identifies all consistent r.e. theories from two-valued data, while three-valued data (an informant) identify every consistent r.e. $T^*$ in the limit posterior (Prop 8.3(c)), non-computably.

*Proof.* Build a text for $\Lambda_\infty$ in stages. Stage $k\ge1$ appends $R(t_{k-1})$ repeatedly until $F$ outputs $[\Lambda_k]$; this happens, because the sequence built so far continued by $R(t_{k-1})$ forever is a text for $\Lambda_k$, on which $F$ converges to $[\Lambda_k]$. The resulting infinite sequence contains every $R(t_i)$, so it is a text for $\Lambda_\infty$, and $F$ outputs $[\Lambda_k]\ne[\Lambda_\infty]$ for infinitely many $k$ (by (L2), $\Lambda_k\nvdash R(t_k)$). ∎

So the failure of two-valued SAI to identify incomplete truths (Prop 8.3(a)) is not an artefact of its prior: no learner can do it. This is Gold's text/informant distinction (N1's N12; the paper should cite it as the learning-theoretic shadow of Prop 8.3, not as new).

**Proposition 8.5 (computable structures; the basic one-tape ω-gap) [proved].** Let $\mathfrak M$ be a computable structure in which every element is the value of a closed term, $\mathrm{Diag}(\mathfrak M)$ its atomic diagram (closed atomic sentences and their negations true in $\mathfrak M$; decidable), and let the data list $\mathrm{Diag}(\mathfrak M)$ in a computable order, labelled true.
(a) $L_A(D_n)\le K_\equiv(\mathrm{Diag}\,\mathfrak M)+c\le K(\mathfrak M)+c$, with $K(\mathfrak M)$ the complexity of an index of $\mathfrak M$.
(b) $P_\infty$ is the prior restricted to the consistent extensions of $\mathrm{Diag}(\mathfrak M)$. For $\mathfrak M=(\mathbb N,0,S,+,\cdot,<)$ and $\theta:=\forall x\,(x+0=x)$, $\lim_n\Bel_{D_n}(\theta)$ and $\lim_n\Dis_{D_n}(\theta)$ both lie in $(0,1)$: instances never settle the universal sentence.
(c) If $\Th(\mathfrak M)$ is decidable and the data present it, Prop 8.2 applies.

*Proof.* (a) Thm 5.1 with $T=\mathrm{Diag}(\mathfrak M)$. (b) Prop 8.3(a). $\Q\cup\mathrm{Diag}(\mathbb N)$ is consistent and proves $\theta$ (axiom Q4). $\mathrm{Diag}(\mathbb N)\cup\{\neg\theta\}$ is consistent: take $\mathbb N\sqcup\{a\}$ with $S(a):=a$, $a+y:=0$ for every $y$ (including $y=a$), $y+a:=a$ for $y\in\mathbb N$, $a\cdot y=y\cdot a:=a$, and $a$ $<$-incomparable with everything; closed terms take values in $\mathbb N$, which is closed under the operations, so the diagram holds, and $a+0=0\ne a$. ∎

This is the one-tape form of AI-paper Prop B.8 and of the Bayesian ω-gap (AI-paper Thm 3.9). Its anatomy and a uniform Gödelian form are `logic` T4.

**Proposition 8.6 (non-decidable complete truths) [proved].**
(a) If $X:=\Cn(D_\infty^\pm)$ is complete and not decidable (for example $\mathcal L=\mathcal L_{\rm ar}$, $B\subseteq\Th(\mathbb N)$ decidable, and every sentence labelled by truth in $\mathbb N$), then $a=0$: $M_A(D_n)\to0$ and the loss is unbounded.
(b) If $(\sigma_t)$ is a computable enumeration of all sentences and $D_n$ labels $\sigma_1,\dots,\sigma_n$ by a complete consistent $X$, then $K(b_{1:n}\mid n)-c\le L_A(D_n)\le n+K(n)+c$.

*Proof.* (a) On $E_\infty$ the theory is consistent and contains the complete $X$, so $\Cn(A_\omega)=X$. Let $\Phi^\omega(\sigma)$ be the first of $\sigma,\neg\sigma$ found provable from $B\cup A_\omega$. On $E_\infty$ it is total and decides $X$. If $a>0$, Lemma 8.0 with $Z=S:=\Sent$ and $g$ the characteristic function of $X$ gives a computable decision procedure for $X$, a contradiction. That $\Th(\mathbb N)$ is undecidable follows, for instance, from Prop 8.7's inseparability step. (b) Lower bound: Prop 6.1(b), as $\dom D_n$ is computable from $n$. Upper bound: $K_A(D_n)\le K(\psi_{D_n})+c\le K(n)+n+c'$ (given $n$, the labels are $n$ bits), and Thm 5.1's last chain. ∎

The coin-free versions are AI-paper Prop 7.11 and TF Lemma 1.6. The growth rate on $\Th(\mathbb N)$ in natural enumerations (scout F's F26(c), N1's N7) is `logic` T5.

**Proposition 8.7 (random theories above $\Q$ are almost surely incomplete) [proved, given that $\Q$ strongly represents every computable set and the diagonal lemma for $\Q$ (standard textbook facts; known, unverified)].** Let $\mathcal L\supseteq\mathcal L_{\rm ar}$.
(a) For every theory machine $G$: $\Unif\{\omega:B\cup A^G_\omega\text{ is consistent, proves every axiom of }\Q,\text{ and decides every }\mathcal L_{\rm ar}\text{-sentence}\}=0$. In particular, if $\Q\subseteq\Cn(B)$, the consistent random theory of $M_A$ is almost surely incomplete, and every posterior gives probability $0$ to complete theories.
(b) For every function machine $F$ over $X=\Sent_{\mathcal L_{\rm ar}}$ with labels $\{0,1\}$ (P1 Def 3.6): $\Unif\{\omega:f^F_\omega\text{ is total, labels every }\Q\text{-provable sentence }1\text{ and every }\Q\text{-refutable sentence }0\}=0$; likewise with $\PA$ or any consistent r.e. extension of $\Q$ in place of $\Q$.

*Proof.* *Inseparability.* No total computable $h:\Sent_{\mathcal L_{\rm ar}}\to\{0,1\}$ is $1$ on the theorems of $\Q$ and $0$ on its refutable sentences. Otherwise $\{n:h(n)=1\}$ (via Gödel numbers) is strongly represented in $\Q$ by some $R_h(x)$, and the diagonal lemma gives $\sigma$ with $\Q\vdash\sigma\leftrightarrow\neg R_h(\ulcorner\sigma\urcorner)$. If $h(\ulcorner\sigma\urcorner)=1$, then $\Q\vdash R_h(\ulcorner\sigma\urcorner)$, so $\Q\vdash\neg\sigma$ and $h$ is $1$ on a refutable sentence. If $h(\ulcorner\sigma\urcorner)=0$, then $\Q\vdash\neg R_h(\ulcorner\sigma\urcorner)$, so $\Q\vdash\sigma$ and $h$ is $0$ on a theorem. A separator for a consistent r.e. $T\supseteq\Q$ separates $\Q$'s pair too.
(a) On the event, $\Phi^\omega(\sigma):=$ the first of $\sigma,\neg\sigma$ found provable from $B\cup A^G_\omega$ is total on $\mathcal L_{\rm ar}$-sentences and separates $\Q$'s theorems from its refutable sentences. Lemma 8.0 would give a computable separator. (b) $\Phi^\omega(\sigma):=f^F_\omega(\sigma)$, computed by running $F$ on $\sigma$ with tape $\omega$. ∎

*Consequences.* (i) With $\Q\subseteq\Cn(B)$, the trichotomy of a sentence can tend to $(1,0,0)$ or $(0,1,0)$, sentence by sentence, but never through a complete random theory. (ii) (b) is the random-labeller form of the observation in Hänni's working notes that no total computable labeller gets every $\PA$-provable and $\PA$-refutable sentence right: a random tape does not help, almost surely. (iii) "A theory plus a fair coin on every sentence it leaves undecided" is not a theory-machine law above $\Q$; this is why graded CR can exceed PR (Prop 11.2) and why Q6 is not trivial. Scout F's proof used the facts that separators of effectively inseparable pairs have PA degree and that the PA degrees form a null class (Jockusch–Soare); Lemma 8.0 replaces both.

---

## 9. The generative variant (target T9)

*Setting.* Fix AI-paper L1 (Def 2.9): a derivation grammar with positive rule probabilities, a full-support instantiation grammar and admissible parameters. For a set $A$ of axioms with an enumeration $(\chi_1,\chi_2,\dots)$, let the citation weights be $\propto2^{-j}$ on $\chi_j$ (normalised; none if $A=\emptyset$), and let $P_A$ be the resulting law on sentences. One-tape form: split the tape into $\omega^{(0)},\omega^{(1)},\dots$ by a computable interleaving; $A_\omega:=A^{G_U}_{\omega^{(0)}}$ in emission order; the $i$-th datum $X_i$ is sampled from $P_{A_\omega}$ with the coins $\omega^{(i)}$. The universal law of unlabelled data streams is $\Xi(X_{1:n}):=\int\prod_{i\le n}P_{A_\omega}(X_i)\,d\Unif(\omega)$, and the generative posterior has density $\propto\prod_iP_{A_\omega}(X_i)$ with respect to $\Unif$.

**Proposition 9.1.**
(i) **[proof sketch]** *Supports.* With $B=\emptyset$ (or $B$ included among the axioms), $\operatorname{supp}P_A=\Th(A)$ for every $A$. AI-paper Lemma 2.10(c) proves this for finite template theories; for an axiom set in which every axiom has positive citation weight the same argument applies (each derivation tree citing finitely many axioms has positive probability). Not written out.
(ii) **[proved, given (i)]** *Reweighting.* On data $X_1,\dots,X_n$, a consistent $A$ has positive likelihood iff $A\vdash X_i$ for all $i$, the proof-requiring compatibility condition for $D:=\{(X_i,1)\}$. So on consistent theories the generative posterior is the PR posterior reweighted by $\prod_iP_A(X_i)\le1$. Inconsistent theories have positive likelihood (their support is everything) and pay the size principle: a theory with mass $\varepsilon$ outside the support of the data law loses at least $\log\frac1{1-\varepsilon}$ bits per datum in expectation (AI-paper Lemma 2.21).
(iii) **[proved, given (i)]** *Question conditioning.* For a yes/no question $q=\{\varphi,\neg\varphi\}$ and consistent $A$: $P_A(q)>0$ iff $A$ decides $\varphi$, and then $P_A(\varphi^b\mid X\in q)=\ind[A\vdash\varphi^b]$. Hence the generative predictive probability that the next datum answers $q$ with $\varphi^b$, given that it answers $q$, is $\int\pi_n(d\omega)P_{A_\omega}(q)\ind[A_\omega\vdash\varphi^b]\big/\int\pi_n(d\omega)P_{A_\omega}(q)$ over consistent theories (inconsistent theories, which pay the size principle, contribute their own $P_A(\varphi^b\mid X\in q)$): PR's $\Bel$ under a posterior reweighted by how likely each theory was to have *asked* $q$. "Independent" gets probability $0$: the model presupposes that asked questions are answered.
(iv) **[proof sketch, given Doob's consistency theorem (known; AI-paper Thm 4.2)]** *Identification.* If $X_1,X_2,\dots$ are i.i.d. from $P_{T^*}$, the law of the deterministic machine emitting a consistent r.e. $T^*$, the generative posterior probability of $\{\omega:\Th(A_\omega)=\Th(T^*)\}$ tends to $1$ almost surely; the PR posterior on two-valued data presenting $T^*$ only reaches the prior on $\Ext(T^*)$ (Prop 8.3(a)). Sketch: $\theta(\omega):=\operatorname{supp}P_{A_\omega}=\Th(A_\omega)$ is almost surely a function of the infinite sample (the set of sentences that occur), so Doob's theorem gives posterior consistency for $\theta$ at $\Unif$-almost every $\omega$; the tapes whose theory has law exactly $P_{T^*}$ form a set of positive measure, so the statement holds under $P_{T^*}^\infty$. Missing: measurability of $\omega\mapsto P_{A_\omega}$ and (i) for r.e. axiom sets.

*Proof of (iii).* $\operatorname{supp}P_A=\Th(A)$ contains at most one of $\varphi,\neg\varphi$ (consistency) and contains one iff $A$ decides $\varphi$; Bayes' rule. ∎

*Reading.* The generative variant buys identification of the theorem set with a model of which sentences get stated, the size principle. This is the bridge to the AI-paper's inducer (its §4).

---

## 10. Comparison with Demski's prior (target T10)

The construction attributed to Demski (2012) by the secondary descriptions recorded by scout L (Sawin–Demski; Hahn): draw sentences i.i.d. from a measure $\mu$ with full support on $\Sent$, and keep a drawn sentence iff it is consistent with $B$ and the sentences kept so far (one description also skips sentences already implied, which does not change the outcome). Let $S_t$ be the kept set after $t$ draws, $T_\infty:=\Cn(\bigcup_tS_t)$ and $P_\mu(\varphi):=\Pr[\varphi\in T_\infty]$. No readable copy of the paper could be fetched in this round, so the attribution is **known, unverified**; the proposition is about the process as described.

**Proposition 10.1.**
(a) **[proved]** $T_\infty$ is consistent and complete with probability $1$. Hence $P_\mu$ is a probability on the Lindenbaum algebra of $B$ (coherent; $P_\mu(\varphi)+P_\mu(\neg\varphi)=1$), and $\Pr[\Cn(T_\infty)=\Cn(T)]=0$ for every incomplete $T$.
(b) **[proved]** Under $M_A$: for every $\varphi$ undecided by $B$, the prior independent mass $\Bel_0(\top)-\Bel_0(\varphi)-\Bel_0(\neg\varphi)$ is at least $\varepsilon_\emptyset>0$; every consistent r.e. $T$, complete or not, has $\Unif_A[T]\ge2^{-K_\equiv(T)-c}>0$; and above $\Q$ the random theory is almost surely incomplete (Prop 8.7).
(c) **[proved, given Church's theorem (known)]** For $B=\emptyset$ and a language with a binary relation symbol, the map $(\sigma_1,\dots,\sigma_t)\mapsto S_t$ is not computable (already $t=1$ asks whether $\sigma_1$ is satisfiable), and it is computable relative to $\emptyset'$ (consistency of a finite set is $\Pi^0_1$). A theory machine emits sentences unconditionally; consistency enters $M_A$ only as the event measured, so $M_A$ is defined without an oracle (though not lsc, Thm 3.2).
(d) *Remark, not a theorem.* $P_\mu(\varphi)\ge\mu(\varphi)$ for every $B$-consistent $\varphi$ (first draw), so finite theories get weight from the sentence measure, while an infinite theory enters only through infinitely many draws, and by (a) an incomplete one is never the outcome. Under $M_A$ an infinite decidable schema costs the length of its generator (Thm 4.1(i)). No quantitative comparison of the weights of complete theories is claimed.

*Proof.* (a) Fix $\varphi$. With probability $1$ it is drawn at some step, since $\mu(\varphi)>0$. At the first such step $t$, either $S_{t-1}\cup\{\varphi\}$ is consistent and $\varphi$ is kept, or $S_{t-1}\vdash\neg\varphi$. Either way $T_\infty$ decides $\varphi$. There are countably many $\varphi$. Every $S_t$ is consistent, so their union is (compactness). (b) Thm 4.1 and $\varepsilon_\emptyset$ (Prop 7.1). (c) Church's theorem: validity, hence satisfiability, of first-order sentences in a language with a binary relation symbol is undecidable. ∎

*What this says.* Both are "algorithmic-probability-like priors over first-order theories". They differ in what a hypothesis is (a program enumerating axioms, against a sequence of sentences), and in what a prediction is (a belief function keeping the independent outcome, against a coherent probability over completions). Demski's prior is a prior on *truth* (a random complete theory); $M_A$'s is a prior on *provability* (a random r.e. theory).

---

## 11. Scout F's open questions (target T11)

### 11.1 Q5: the normalised loss of $M_A$ is order dependent

**Theorem 11.1 (order dependence in the normalised convention) [proved; computed: c2 B3, B4].**
(a) Let $a,c$ be sentences with $B\cup\{a\}$ consistent and $B\cup\{\neg a\}$ consistent and deciding neither $c$ nor $\neg c$. Let $D:=\{(a,1),(a\vee c,1)\}$, and for $x,y\in Y_3$ let $p_{xy}:=\Unif\{\omega\in C:f_\omega(a)=x,\ f_\omega(a\vee c)=y\}$ (Prop 2.1(g)). Then $p_{10}=p_{1\iota}=p_{\iota0}=0$, and the normalised probabilities of $D$ in the orders $(a,a\vee c)$ and $(a\vee c,a)$, $N_{a\to b}$ and $N_{b\to a}$, satisfy
$$\frac{N_{b\to a}}{N_{a\to b}}=1+\frac{(p_{11}+p_{01})\,p_{0\iota}+p_{\iota1}\,(p_{00}+p_{0\iota})}{(p_{11}+p_{01}+p_{\iota1}+p_{00})\,(p_{11}+p_{01})}\ >\ 1 .$$
So the normalised cumulative loss of $M_A$ on $D$ is strictly smaller in the order $(a\vee c,a)$, while the semimeasure-convention loss is the same in both orders.
(b) *A linear gap.* Let $a_i,c_i$ ($i\ge1$) be distinct literals of a fresh predicate (Lemma 6.2a). For $y\in\{0,1\}^n$ put $\alpha_i:=a_i^{y_i}$, $\beta_i:=\alpha_i\vee c_i$ and $D_n(y):=\{(\alpha_i,1),(\beta_i,1):i\le n\}$. Compare the orders $\mathrm A=(\alpha_1,\beta_1,\alpha_2,\beta_2,\dots)$ and $\mathrm B=(\beta_1,\alpha_1,\beta_2,\alpha_2,\dots)$. For every $y$ the normalised loss of order A exceeds that of order B by at least $\sum_{i\le n}\log(1+v_i(y))\ge0$, where $v_i(y)$ is the posterior probability, after the first $i-1$ pairs, that the random theory refutes $\alpha_i$ and does not decide $c_i$. The average of this difference over $y\in\{0,1\}^n$ is at least $2^{-c_1-1}n$, with $c_1$ the length of a $V$-program for the machine $G_{ca}:=\{(w,a_j^{w_j}):|w|=j\}$ (fair coins on the $a$'s). So for every $n$ some data set with $2n$ data has two reveal orders whose normalised losses differ by at least $2^{-c_1-1}n$ bits.

*Proof.* (a) If the random theory proves $a$, it proves $a\vee c$; if it refutes $a\vee c$, it refutes $a$. This gives the three zero cells. In the order $(a,a\vee c)$, the first normalised factor is $\Bel_\emptyset(a)/(\Bel_\emptyset(a)+\Dis_\emptyset(a))=p_{11}/(p_{11}+p_{01}+p_{00}+p_{0\iota})$, and the second is $1$, since $a\vee c$ is then entailed (Prop 2.1(c)). In the order $(a\vee c,a)$, the first factor is $(p_{11}+p_{01}+p_{\iota1})/(p_{11}+p_{01}+p_{\iota1}+p_{00})$; given $(a\vee c,1)$ the posterior is $\Unif|_C$ restricted to $f(a\vee c)=1$, on which $\Bel(a)\propto p_{11}$ and $\Dis(a)\propto p_{01}$, so the second factor is $p_{11}/(p_{11}+p_{01})$. Dividing,
$$\frac{N_{b\to a}}{N_{a\to b}}=\frac{(p_{11}+p_{01}+p_{\iota1})(p_{11}+p_{01}+p_{00}+p_{0\iota})}{(p_{11}+p_{01}+p_{\iota1}+p_{00})(p_{11}+p_{01})},$$
and expanding, numerator minus denominator is $(p_{11}+p_{01})p_{0\iota}+p_{\iota1}(p_{00}+p_{0\iota})$. Strictness: $p_{11}>0$ (the tapes beginning with a program for $\{a\}$), and $p_{0\iota}>0$ (the tapes beginning with a program for $\{\neg a\}$: consistent, refuting $a$, and not deciding $a\vee c$, because $B\cup\{\neg a\}\vdash a\vee c$ iff $B\cup\{\neg a\}\vdash c$, and $B\cup\{\neg a\}\vdash\neg(a\vee c)$ iff $B\cup\{\neg a\}\vdash\neg c$).
(b) After the first $i-1$ pairs both orders have revealed the same set $D_{i-1}(y)$, and the normalised conditionals depend only on the current set and the queried sentence. So the difference is the sum over $i$ of $\log(N^{(i)}_{b\to a}/N^{(i)}_{a\to b})$, computed as in (a) under the posterior $P_{i-1}:=\Unif(\cdot\mid E_{D_{i-1}})$; the constraints of (a) hold for every consistent theory, and the cell masses of a probability sum to $\le1$, so the ratio is at least $1+p_{0\iota}=1+v_i(y)$. (The formula needs $p_{11}>0$ under $P_{i-1}$; the $G_{ca}$-tapes with $\omega'_{\le i}=y_{\le i}$ provide it.) Next, $\log(1+v)\ge v$ for $v\in[0,1]$. The tapes $p\,\omega'$, with $p$ the program for $G_{ca}$, $\omega'_{<i}=y_{<i}$ and $\omega'_i\ne y_i$, lie in $E_{D_{i-1}(y)}$ (their theory proves $\alpha_j$, hence $\beta_j$, for $j<i$), refute $\alpha_i$, and do not decide $c_i$ (L2); they have measure $2^{-c_1-i}$. So $v_i(y)\ge2^{-c_1-i}/M_A(D_{i-1}(y))$. Over uniform $y$, Jensen's inequality gives $\Ex[1/M_A(D_{i-1})]\ge1/\Ex[M_A(D_{i-1})]$. Moreover $M_A(D_{i-1}(y))=\Bel_0(\bigwedge_{j<i}\alpha_j(y))$, and these conjunctions are pairwise incompatible for distinct $y_{<i}$, so $\sum_{y_{<i}}M_A(D_{i-1}(y))\le1$ and $\Ex[M_A(D_{i-1})]\le2^{-(i-1)}$. Hence $\Ex\,v_i\ge2^{-c_1-1}$; sum over $i\le n$. ∎

*Remarks.*
* This answers scout F's Q5 positively for $M_A$, with an explicit two-datum witness and a linear-gap family. The mechanism is the failure of P1's two-point criterion $(\star)$ (P1 Prop A.7): whether the random theory decides $a\vee c$ depends on its answer to $a$ (a theory proving $a$ always decides $a\vee c$; one refuting $a$ need not).
* The witnesses use logical structure: in one order the second datum is entailed. Whether the normalised loss is order dependent on *logically independent* data (positive literals of a fresh predicate, where $M_A\asymp M_F$) is equivalent in spirit to P1's Question A.8 and remains **[open]**; the transfer of `sfi` T5 holds only up to constant factors, which do not control normalised conditionals. So the result cannot be reported to the SOI papers as an answer to their question; it shows only that for sentence data the answer is yes.
* Consequence for the paper: of the normalised convention's lower bounds, none transfer from the semimeasure convention automatically (as in P1), and its losses are not functions of the data set.

### 11.2 Q4: how much graded CR can exceed PR

**Proposition 11.2 [proved; computed: c2 B5].**
(a) For every consistent $D$: $0\le\log\big(M_A^{1/2}(D)/M_A(D)\big)\le K(\dom D)+|D|+c$.
(b) Let $m\ge3$ and $k\ge1$, let $a_{j,i}$ ($j\le k$, $i<m$) be distinct literals of a fresh predicate, and put $\chi^{(j)}_i:=\neg a_{j,1}\wedge\dots\wedge\neg a_{j,i-1}\wedge a_{j,i}$ for $1\le i<m$ and $\chi^{(j)}_m:=\neg a_{j,1}\wedge\dots\wedge\neg a_{j,m-1}$. For $\vec\imath\in[m]^k$ let $E_{\vec\imath}:=\{(\chi^{(j)}_{i_j},1):j\le k\}$. Then some $\vec\imath$ has
$$\log\frac{M_A^{1/2}(E_{\vec\imath})}{M_A(E_{\vec\imath})}\ \ge\ k\log\frac m2-c,\qquad |E_{\vec\imath}|=k,\qquad K(\dom E_{\vec\imath})\le k\log m+K(k,m)+c .$$
For $m=3$ the gap is $k\log\frac32-c$, linear in $|D|$; for $k=1$ it is $\log m-1-c$ on a single datum. The lower bound is within $2|D|+K(k,m)+c$ of the upper bound (a).

*Proof.* (a) The lower bound is Prop 7.3(b). For the upper bound, $M_A^{1/2}\le1$ and $M_A(D)\ge2^{-K(\psi_D)-c}$ (the one-axiom theory $\{\psi_D\}$), with $K(\psi_D)\le K(\dom D)+|D|+c$ (the labels are $|D|$ bits given $\dom D$).
(b) Each $E_{\vec\imath}$ is consistent (each $\chi$ is a consistent conjunction of literals, and the blocks use disjoint atoms; L1), and $B$ proves none of its data (L2 applied to $\Lambda=\emptyset$). The empty theory gives $\nu^{1/2}_\emptyset(E_{\vec\imath})=2^{-k}$, so $M_A^{1/2}(E_{\vec\imath})\ge\varepsilon_\emptyset2^{-k}$. Two different $\vec\imath$ differ in some block, where their sentences are incompatible; so the $m^k$ conjunctions $\psi_{E_{\vec\imath}}$ are pairwise incompatible, $\sum_{\vec\imath}M_A(E_{\vec\imath})\le1$, and some $\vec\imath$ has $M_A(E_{\vec\imath})\le m^{-k}$. Its gap is at least $\log(\varepsilon_\emptyset2^{-k}m^k)$. $\dom E_{\vec\imath}$ is computable from $(k,m)$ and the index of $\vec\imath$ among $m^k$ values. ∎

This confirms scout F's conjecture (linear gap, as in P1 Thm 3.12(iii)), and more: the gap can come close to the maximum $K(\dom D)+|D|$. The source is the per-datum grading of Prop 7.3(d): a datum whose content is a long conjunction costs one bit under the graded weight and its full content under PR. The construction is the logical counterpart of P1's three-input weak semimeasure (P1 Ex 3.5(b)): $m$ pairwise incompatible single data, each worth $\frac12$ to the empty theory, total mass $m/2>1$.

### 11.3 Q7: the Kolmogorov predictor can be exponentially worse than Bayes

**Theorem 11.3 [proved; computed: c3].** Work with distinct literals $a_1,\dots,a_m$ of a fresh predicate (Lemma 6.2a), and for $w\in\{0,1\}^m$ let $\mathrm{desc}(w):=\bigwedge_{i\le m}a_i^{w_i}$. Fix any total order $\prec$ on $\dom V$, and let the Kolmogorov predictor of Prop 5.3(b) use the $\prec$-first compatible program. There are a data set $D$ of $2^m-1$ sentences, all of the form $\neg\mathrm{desc}(v)$ labelled true, and a reveal order of $D$, such that:
(i) the Kolmogorov predictor errs or abstains at every one of the $2^m-1$ steps;
(ii) $K_A(D)\le m+K(m)+c$, and the Bayes predictor of Prop 5.3(a) makes at most $m+K(m)+c$ mistakes on the same sequence.
If $\prec$ refines length, then $m\le K_A(D)\le m+K(m)+c$, so with $k:=K_A(D)$ the number of errors or abstentions is at least $2^{k-K(m)-c}-1\ge2^{k-2\log k-c'}-1$; the upper bound of Prop 5.3(b) is $2^k$.

*Proof.* For each $w$ let $\pi(w)$ be the $\prec$-first $p\in\dom V$ with $B\cup\mathsf W_{V(p)}$ consistent and proving $\mathrm{desc}(w)$; it exists, since $\{\mathrm{desc}(w)\}$ is consistent (L1). A consistent theory proves at most one $\mathrm{desc}(w)$, so $\pi$ is injective. Let $w^*$ be the $w$ whose $\pi(w)$ is $\prec$-last. The adversary repeats the following, starting from $D=\emptyset$, as long as the $\prec$-first program $p$ compatible with the current data does not prove $\mathrm{desc}(w^*)$:
* $p$ is consistent and $B\vdash\bigvee_v\mathrm{desc}(v)$, so the set $\mathrm{Open}(p)$ of $v$ with $B\cup\mathsf W_{V(p)}\cup\{\mathrm{desc}(v)\}$ consistent is nonempty. It contains some $v\ne w^*$: otherwise $p$ proves $\neg\mathrm{desc}(v)$ for all $v\ne w^*$, hence $\mathrm{desc}(w^*)$.
* Present $(\neg\mathrm{desc}(v),1)$ for such a $v$.

Then: (1) every presented sentence is true in the valuation $w^*$, so the data stay consistent and $\{\mathrm{desc}(w^*)\}$ proves them all. (2) $p$ does not prove $\neg\mathrm{desc}(v)$ ($v$ is open for $p$), so the predictor errs (if $p$ proves $\mathrm{desc}(v)$) or abstains. (3) The sentence $\neg\mathrm{desc}(v)$ was not presented before, since $p$ is compatible with the earlier data. (4) For $w\ne w^*$, $\pi(w)$ proves $\neg\mathrm{desc}(v)$ for every $v\ne w$, so it stays compatible until $\neg\mathrm{desc}(w)$ is presented. While some $\pi(w)$ with $w\ne w^*$ is compatible, the $\prec$-first compatible program is $\preceq\pi(w)\prec\pi(w^*)$, and, being consistent and $\prec$-before $\pi(w^*)$, does not prove $\mathrm{desc}(w^*)$; so the loop continues. By (3) the loop runs at most $2^m-1$ times, and by (4) it does not stop before all $\neg\mathrm{desc}(w)$, $w\ne w^*$, have been presented. So it runs exactly $2^m-1$ times, and by (2) every step is an error or abstention.
(ii) $\bigwedge_{v\ne w^*}\neg\mathrm{desc}(v)$ is equivalent to $\mathrm{desc}(w^*)$, so $K_A(D)\le K(\mathrm{desc}(w^*))+c\le m+K(m)+c'$. Prop 5.3(a) with $T:=\{\mathrm{desc}(w^*)\}$ bounds the Bayes mistakes by $K_\equiv(T)+c\le m+K(m)+c''$.
If $\prec$ refines length, every program compatible with $D$ proves $\mathrm{desc}(w^*)$, so $K_A(D)=|\pi(w^*)|$; the $2^m$ distinct programs $\pi(w)$ all have length $\le|\pi(w^*)|$, and Kraft's inequality gives $2^m\le2^{|\pi(w^*)|}$. Finally $K(m)\le2\log m+c\le2\log k+c$. ∎

*Remarks.* The stream is not computable (it depends on $\pi$). The construction is logical: in SOI on strings the analogous decoys would be beaten by the constant labeller "true", which here is unavailable because $\{\neg\mathrm{desc}(v):v\in\{0,1\}^m\}$ is inconsistent. As in P1's conjunction ladder (P1 Thm 9.10, with the remark that it is the selection rule, not the prior, that fails), the single simplest theory compatible with the data is a poor predictor although the Bayes mixture over the same hypotheses is good.

### 11.4 Q6: does $M_A$ dominate every lsc probability of provability?

Call a Borel random variable $\Theta$ with values in the consistent, deductively closed sets of sentences a *random consistent theory*, and $\beta(\chi):=\Pr[\chi\in\Theta]$ its provability function. Q6 asks whether $\Bel_0\ge2^{-c_\beta}\beta$ whenever $\beta$ is lsc.

**Proposition 11.4.**
(a) **[proved]** For every lsc $\beta$ of this kind, every finite set $S$ of pairwise $B$-incompatible sentences and every $\sigma\in S$: $\Bel_0(\sigma)\ge2^{-K(\beta)-K(S)-c}\beta(\sigma)$. In particular $M_A(D)\ge2^{-K(\beta)-K(\dom D)-c}\beta(\psi_D)$.
(b) **[proved]** If $\Theta$ is the closure of the output of a theory machine $G$ (almost surely consistent), then $\Bel_0\ge2^{-K(G)}\beta$ (Thm 4.1).
(c) **[proved, given `sfi` T5]** Q6 restricted to random sets of literals of a fresh predicate (with lsc containment functional on literal data, and domination required on literal data) is equivalent to P1 Question 3.14 for labels $\{0,1\}$.

*Proof.* (a) $\Theta$ contains at most one member of $S$, so $\sum_{\sigma\in S}\beta(\sigma)\le1$ and $\beta|_S$ is a semimeasure, lsc uniformly in $S$; the conditional coding theorem gives $K(\sigma\mid S)\le-\log\beta(\sigma)+K(\beta)+c$. If $\beta(\sigma)>0$, $\sigma$ is consistent with $B$, and the one-axiom theory gives $\Bel_0(\sigma)\ge2^{-K(\sigma)-c}\ge2^{-K(S)-K(\sigma\mid S)-c'}$. For $D$ take $S$ the label conjunctions on $\dom D$. (c) A random literal set $\Lambda$ with at most one literal per word corresponds to the random partial function $F(x):=b$ iff $R(t_x)^b\in\Lambda$, with $\Pr[\Lambda\supseteq D^\pm]=\Pr[F\supseteq D^{\rm str}]$ ($D^{\rm str}$ the string data set of $D$); and $M_A(D)\asymp M_F(D^{\rm str})$ on literal data (`sfi` T5; scout S Thm 2.7). ∎

So Q6 is at least as hard as the binary case of P1's question, and for general sentences it is **[open]**. The obstacle is P1's: an lsc law of a random object need not be realisable by a machine reading one tape (P1 App A.6). Note that $\Bel_0$ itself is not lsc (Thm 3.2), while $\Bel_0+\Inc_0$ is.

### 11.5 Q2: does the random tape help for whole theories?

For an r.e. set $X$ of sentences let $\Unif_{\rm enum}(X):=\Unif\{\omega:A_\omega=X\}$, the probability that the universal theory machine emits exactly $X$ (a universal probabilistic enumerator), and recall $K_{\rm enum}$, $\mm_{\rm enum}$ from Prop 6.4. Q2 asks whether $\Unif_A[T]\asymp\mm_\equiv(T)$ for consistent r.e. $T$, and whether $K_\equiv(T)\le-\log\mm_\equiv(T)+O(1)$.

**Proposition 11.5.**
(a) **[proved]** For consistent r.e. $T$: $2^{-c}\Unif_{\rm enum}(\Cn T)\le\Unif_A[T]\le2^c\Unif_{\rm enum}(\Cn T)$, and $\Unif_A[T]\ge2^{-c}\mm_\equiv(T)$.
(b) **[proved]** Suppose $\mathcal L$ contains a unary predicate not occurring in $B$ and closed terms as in Lemma 6.2a. Then $\Unif_A[T]\asymp\mm_\equiv(T)$ for all consistent r.e. $T$ iff $\Unif^{\rm str}_{\rm enum}(X)\asymp\mm^{\rm str}_{\rm enum}(X)$ for all r.e. $X\subseteq\{0,1\}^*$ (the same quantities for a universal probabilistic enumerator of sets of strings); and $K_\equiv\le-\log\mm_\equiv+O(1)$ iff $K^{\rm str}_{\rm enum}\le-\log\mm^{\rm str}_{\rm enum}+O(1)$.
(c) **[proved, given Solovay 1977 in the probabilistic reading (known, unverified)]** $-\log\Unif_A[T]\le-\log\mm_\equiv(T)+c\le K_\equiv(T)+c\le3\,(-\log\Unif_A[T])+O\big(\log(-\log\Unif_A[T])\big)+c$.

*Proof.* (a) $\{A_\omega=\Cn T\}\subseteq\{\Cn(A_\omega)=\Cn T\}$, so $\Unif_A[T]\ge\Unif_{\rm enum}(\Cn T)$. Conversely the machine $G_{\rm cl}$ ("run $G_U$, emit $\Cn(A_\omega)$") emits exactly $\Cn T$ on $\{\Cn(A_\omega)=\Cn T\}$, and the tapes $p_{G_{\rm cl}}\omega'$ show $\Unif_{\rm enum}(\Cn T)\ge2^{-|p_{G_{\rm cl}}|}\Unif_A[T]$. The last claim is Thm 4.1(i).
(b) (⇐) By (a) and Prop 6.4(a), $\Unif_A[T]\asymp\Unif_{\rm enum}(\Cn T)$ and $\mm_\equiv(T)\asymp\mm_{\rm enum}(\Cn T)$, and coding sentences as strings changes the enumeration quantities by constant factors. (⇒) For $X\subseteq\{0,1\}^*$ let $T_X:=\{R(t_x):x\in X\}$. By (L2), $X=\{x:R(t_x)\in\Cn(T_X)\}$. A probabilistic enumerator of exactly $X$ yields one of exactly $\Cn(T_X)$ (close under $\Cn$) and conversely (extract the $x$), with constant overhead, on probabilistic and on deterministic programs alike; distinct $X$ give distinct $\Cn(T_X)$. So $\Unif^{\rm str}_{\rm enum}(X)\asymp\Unif_{\rm enum}(\Cn T_X)\asymp\Unif_A[T_X]$ and $\mm^{\rm str}_{\rm enum}(X)\asymp\mm_\equiv(T_X)$; likewise for $K$.
(c) The first two inequalities are (a) and Prop 6.4. Solovay's theorem bounds $K_{\rm enum}(X)$ by $3I(X)+O(\log I(X))$ with $I(X)$ the negative logarithm of the probability that a randomised algorithm enumerates exactly $X$, i.e. $-\log\Unif_{\rm enum}(X)\pm c$; apply it to $X=\Cn T$ and use (a) and Prop 6.4(a). ∎

So Q2 is exactly the question whether randomness helps to enumerate a set, which Solovay (1977) and Vereshchagin (2007) studied; its current status could not be checked in this round, and Q2 stays **[open]**. Its relevance: the limit loss on a complete presentation is $-\log\Unif_A[T^*]+\log M_A(\emptyset)$ (Prop 8.2), and Q2 asks whether this equals $-\log\mm_\equiv(T^*)$ up to $O(1)$. For true $\Pi_1$-axiomatised theories the extension version is answered up to $K(\lceil\cdot\rceil)$ by N1's N11 (`logic` T2). (c) also gives the PA version of Prop 8.3(b): every r.e. $T^*$ with $\Q\subseteq T^*\subseteq\PA$ and $K_\equiv(T^*)>3K_\equiv(\PA)+O(\log K_\equiv(T^*))$ has $\Unif_A[T^*]<\Unif_A[\PA]$, so on data presenting $T^*$ the limit posterior prefers $[\PA]$ to $[T^*]$ (given Solovay).

---

## 12. Refuted claims, and what is new

### 12.1 Refuted claims (kept with their counterexamples)

| claim | counterexample |
|---|---|
| "$M_A$ is lower semicomputable, like $M_F$" (scout F's first assumption) | $M_A(\emptyset)=1-\Inc_0$ is right-c.e. and not computable (Thm 3.2) |
| "The 0/1 consistency-requiring weight is a semimeasure" | $M_A^{\rm nc}(D+(\varphi,1))+M_A^{\rm nc}(D+(\varphi,0))>M_A^{\rm nc}(D)$ whenever some consistent hypothesis-plus-data leaves $\varphi$ undecided, e.g. the empty theory (Prop 7.1(a); strict in 166 of 173 random instances, c1 A9) |
| "Graded CR is a reweighting of PR" | it charges for entailed data: with the empty theory, $\nu^{1/2}(\{(p,1)\})=\frac12$ but $\nu^{1/2}(\{(p,1),(p\vee q,1)\})=\frac14$ (Prop 7.3(c)); and it is not invariant under splitting a conjunction: $\frac34$ against $\frac58$ in c1 A12 |
| "A coding theorem holds for single sentences" | the two-literal data set of Thm 6.2 is the single sentence $\psi_D$; $K_A-L_A\ge\log d-O(1)$ on it |
| "The most probable class in the limit posterior is $[T^*]$" | for all but finitely many $j$, data presenting $T_j=\{R(t_i):i\ne j\}$ give $[U]$, $U=\{R(t_i):i\in\mathbb N\}$, more limit probability than $[T_j]$ (Prop 8.3(b)) |

No new refutations arose in this round. Corrections to scout F's record that are not refutations: F12 downgraded from factor 2 to 3 (unverified reference); F15(b)'s count sharpened from $2^{k+1}$ to $2^k$ (Kraft); F22's total-variation bound sharpened from $2\delta_n/a_n$ to $\delta_n/a_n$; F25(b)'s nonstandard model completed (all operations on the new element specified); F24(a)'s strict-extension remark turned from a sketch into Prop 8.3(b) with a different example.

### 12.2 What is new against the AI-paper, P1 and the literature

| result | status against earlier work |
|---|---|
| one-tape theory machines, $G_U$, $M_A$, $M_A^3$, $K_A$ (§1) | new; parallel to P1's function machines; the AI-paper has only coin-free deciders |
| Prop 1.8(a),(b): deciders = enumerators = polynomial-delay enumerators | the decider/labeller form is AI-paper Thm 6.3 and TF Thm 2.2(b); the enumerator/decider form stated here is a direct Craig argument |
| Prop 1.8(d): $K_{\rm fin}-K_A\ge\Kpad(n)-c$ | new |
| Prop 2.1: structure, two defects, order independence | new for $M_A$; the coin-free analogues are AI-paper Def 6.2 and its semimeasure convention; P1 Props 3.16, 3.3 are the SOI analogues |
| Props 2.2, 2.3: PR = geometric conditioning, CR = Dempster conditioning | new framing; total monotonicity and bracketing are AI-paper Props 2.18, 2.19 (countable classes); the rules themselves are known (§14) |
| Thm 3.2, Lemma 3.3: $\Inc_0$ Solovay complete and random; $M_A$ not lsc | new; contrasts with P1 Props 3.7, A.10 |
| Thm 4.1–Cor 4.5: dominance, invariance, background, translations, vocabulary | new for theories; parallel to P1 Thms 3.8, 3.20; Cor 4.5 is the Bayesian form of Craig's observation (known in substance) |
| Thm 5.1: loss $\le-\log\Unif_A(\Ext T)\le K_\equiv(T)+c$ | new; P1 Thm 5.1(b) is the program analogue |
| Prop 5.3, Thm 11.3: mistakes; Kolmogorov predictor $2^{k-O(\log k)}$ | (a) is the halving argument (P1 Cor 5.4); (b) and Thm 11.3 new; P1 Thm 9.10 is the circuit analogue |
| Thm 5.4: three-valued merging | new; P1 Thm 5.3 is the analogue for random total functions |
| Prop 6.1, Thm 6.2: chain with $K(S)$ slack; no coding theorem | new for axioms; P1 Thms 4.4, 4.9 for programs |
| Prop 6.4, Prop 11.5: theory-level coding | new connection to Solovay's enumeration complexity |
| Props 7.1–7.4: CR variants | "does not contradict learns nothing" is AI-paper Prop 2.22(b) and pa Prop 5.2; the Dempster reading, linear loss, order dependence and the decomposition are new |
| Lemma 8.0, Props 8.6, 8.7 | the majority-vote argument is classical (de Leeuw et al. 1956); the applications to random theories are new |
| Props 8.1–8.5: limits, text versus informant, ω-gap | new for $M_A$; Gold (1967) for the text/informant distinction; AI-paper Thm 3.9, Prop B.8 for the coin-free ω-gap |
| Prop 9.1: generative variant | (ii), (iii) new; (i), (iv) adapt AI-paper Lemma 2.10, Thm 4.2 |
| Prop 10.1: Demski | new comparison; scout L's Observation L2 made precise |
| Thm 11.1: normalised loss order dependent, linear gap | new; P1 leaves the $M_F$ case open (P1 Question A.8) |
| Prop 11.2: graded CR gap | new; P1 Thm 3.12(iii) is the weak-semimeasure analogue |

---

## 13. Notation requests

* **Local symbols** (defined where used, not in NOTATION-draft): $C^G$, $C$ (consistency events); $\widehat{\Bel}_0$ (normalised belief function); $\varepsilon_\emptyset$ (mass of the empty theory); $K_{\rm enum}$, $\mm_{\rm enum}$, $\Unif_{\rm enum}$ (enumeration complexity and probabilities of r.e. sets; Prop 6.4, §11.5); $\Kpad$ (as in SOI-N); $\mathrm{desc}(w)$, $\pi(w)$, $\prec$ (§11.3); $p_{xy}$ (cell masses, §11.1); $\Lambda_u$, $G_{\rm coin}$, $G_{ca}$, $G_{\rm cl}$ (specific machines); $\Phi$ (an oracle machine, Lemma 8.0).
* **Request 1.** NOTATION-draft §4.1 writes $\Unif_A(\Ext T)$ for "a set of deductive classes", but §3.3 defines $\Ext(T)$ as a set of *indices*. I used the explicit definition $\Unif_A(\Ext T):=\Unif\{\omega:B\cup A_\omega$ consistent, $\Cn(A_\omega)\supseteq\Cn(T)\}$ (Def 1.4). Please add it in this form.
* **Request 2.** Scout F wrote $Q(D)$ for $\Unif(O_{\psi_D})$; this clashes with Robinson's $\Q$. I avoided a symbol and wrote $\Unif(O_{\psi_D})$.
* **Request 3.** A symbol for the universal probabilistic enumeration probability of a set, if the synthesis keeps Q2 (proposed: $\Unif_{\rm enum}(X)$).
* **Request 4.** Scout F's $H(X)$, $I(X)$ for enumeration complexity clash with entropy $H$ (P1 Prop A.9); I wrote $K_{\rm enum}$, $-\log\mm_{\rm enum}$.
* Data sets are partial functions here (NOTATION-draft §3.2), not scout F's sets of labelled sentences; nothing depends on the difference (§1.1 remark).

---

## 14. References and their verification status

The web-search budget was exhausted before this thread ran and WebFetch could not resolve any host, so **no reference was re-verified in this round**. Levels below are those recorded by the scouts (scout F §8, scout L `refs.bib`) or by the SFI papers' bibliographies.

| reference | used for | level |
|---|---|---|
| AI-paper (Defs 2.9, 2.12, 2.13, 6.2; Lemma 2.10, 2.21; Props 2.17–2.19, 2.22, 7.11, B.8; Thms 3.9, 4.2, 4.7, 6.3; Exs 2.15, 2.16) and records TF (Def 1.1, Lemma 1.6, Lemma 2.1, Thm 2.2), pa (Prop 5.2) | §1, §2, §7–§9 | read in this repository; printed numbers from `main.aux` |
| P1 (Defs 3.1, 3.2, 3.4, 3.6, 3.15; Props 3.3, 3.7, 3.9, 3.16, 3.17, 4.6, 4.7, A.7, A.10; Thms 3.8, 3.12, 3.20, 4.4, 4.9, 5.1, 5.3, 9.10; Cor 4.10, 5.4; Question 3.14, A.8; App A.6) | throughout | read in this repository; printed numbers from `main.aux` |
| P. Suppes, M. Zanotti, "On using random relations to generate upper and lower probabilities", *Synthese* 36(4):427–440, 1977 | name of the geometric rule (Prop 2.2(a)) | bibliographic data checked by scout F; attribution of the rule from secondary sources: **known, unverified** |
| G. Shafer, *A Mathematical Theory of Evidence*, Princeton UP, 1976 | belief functions, Dempster's rule (Props 2.2, 2.3) | bibliographic data in the SFI bibliography; content standard: **known, unverified** |
| A. P. Dempster, "Upper and lower probabilities induced by a multivalued mapping", *Ann. Math. Statist.* 38:325–339, 1967 | Dempster's rule (Prop 2.3) | recalled: **known, unverified** |
| J. Pearl, *Probabilistic Reasoning in Intelligent Systems*, Morgan Kaufmann, 1988 | "probability of provability" reading (Prop 2.2(b)) | secondary sources (scout F): **known, unverified** |
| G. J. Chaitin, "A theory of program size formally identical to information theory", *J. ACM* 22(3):329–340, 1975 | $\Omega_V$ is random (Thm 3.2(c)) | bibliographic data confirmed in the SFI bibliography; the theorem is standard: **known, unverified** (theorem number) |
| Levin–Schnorr characterisation ($x$ random iff $K(x_{1:n})\ge n-O(1)$); conditional coding theorem; domination of lsc semimeasures by $\mm$ | Lemma 3.3; Props 6.1, 11.4; Thm 4.1 | standard (Li–Vitányi 2008, as cited in P1 §3.1): **known**, section numbers unverified |
| R. Solovay, "Draft of a paper on Chaitin's work", 1975 (manuscript); R. Downey, D. Hirschfeldt, *Algorithmic Randomness and Complexity*, Springer, 2010 | definition of $\le_S$ (Thm 3.2(b)) | recalled: **known, unverified** |
| A. Kučera, T. Slaman, "Randomness and recursive enumerability", *SIAM J. Comput.* 31:199–211, 2001; C. Calude, P. Hertling, B. Khoussainov, Y. Wang, "Recursively enumerable reals and Chaitin Ω numbers", *Theoret. Comput. Sci.* 255:125–149, 2001 | remark after Lemma 3.3 only | statement via secondary sources (scout F): **known, unverified** |
| R. Solovay, "On random r.e. sets", in *Non-Classical Logics, Model Theory and Computability*, North-Holland, 1977, 283–307 | Props 6.4(b), 11.5(c) | bibliographic data checked by scout L; statement from Vereshchagin's abstract (scout F): **known, unverified**; which probability Solovay's $I$ denotes is recalled, not checked (both readings handled in Prop 6.4(b)) |
| N. Vereshchagin, "Kolmogorov complexity of enumerating finite sets", *IPL* 103(1):34–39, 2007; A. Shekhovtsov, G. Zakharov, "Enumerating complexity revisited", 2023 | scout F's factor 2 (not used) | abstract-level (scout F); not re-checked; **not relied on** |
| K. de Leeuw, E. F. Moore, C. E. Shannon, N. Shapiro, "Computability by probabilistic machines", *Automata Studies*, Princeton, 1956, 183–212 | attribution of the averaging argument (Lemma 8.0, which is proved here) | bibliographic data checked by scout L; content secondary: **known, unverified** |
| E. M. Gold, "Language identification in the limit", *Information and Control* 10(5):447–474, 1967 | text vs informant (Prop 8.4, proved here) | bibliographic data as in the AI-paper bibliography; theorem number not checked |
| Representability of computable sets in $\Q$; the diagonal lemma; Church's theorem (A. Church 1936) | Props 8.7, 10.1(c) | standard textbook facts: **known**, references not re-verified |
| J. L. Doob, "Application of the theory of martingales", 1949 (as cited in AI-paper Thm 4.2) | Prop 9.1(iv) | as in the AI-paper: **known** |
| A. Demski, "Logical prior probability", *AGI 2012*, LNCS 7716, 50–59 | §10 | bibliographic data and abstract checked by scout L; the construction from secondary descriptions: **known, unverified** |
| Completeness and decidability of Presburger arithmetic, DLO, RCF, ACF$_p$ | examples after Prop 8.2 | standard: **known**, references not re-verified |

---

## 15. Verification log

**Sources read in this round.** The project brief `../../00-brief.md` in full (including the epistemic policy); this thread's brief; `../../NOTATION-draft.md`; `../../select.md`; scout F's record `../../scouts/fundamentals/notes.md` in full and its `c1_toy.out`; scout S §2 (`../../scouts/sfi/notes.md`, §2.1–§2.7); scout N1's header, §1, N10–N13 and §8; scout L §3.2, §4 and its `refs.bib` entries for the references above; the AI-paper's `sections/model.tex` (§2.5–§2.8), `time.tex` (§6.1–§6.2), `ident.tex` (§4.1–§4.3) and its label table; TF's record §1–§2 (Lemma 1.6, Lemma 2.1, Thm 2.2, Prop 2.3); P1's `sections/setting.tex`, `versions.tex`, `learn.tex` (§5.1–§5.2), `app-setting.tex` (§A.5–§A.8), `comp.tex` (Thm 9.10) and its label table; the other threads' briefs (`logic`, `sfi`, `terms`) for the interfaces.

**Each of scout F's items was re-derived line by line** before being rewritten; the changes are listed in §12.1. Points where the scout's proof needed more than rewording:
* F3(c): randomness now proved from Chaitin and Levin–Schnorr (Lemma 3.3) instead of Kučera–Slaman; the non-computability proof now uses the halting set's characteristic real, so it does not need the non-computability of $\Omega_V$ either.
* F7: the preliminary fact $B'\vdash\neg\tau(\bot)$ and the c.e.-ness of the pull-back machine are written out.
* F16: the conditional-law step and the integrability step are written out (Thm 5.4, Steps 1 and 3).
* F25(b): the nonstandard model was underspecified ("add $a$ with $a+0:=0$"); all operations are now defined, including $a+a$.
* F26(a), F27: replaced the citations (de Leeuw et al.; Jockusch–Soare on PA degrees) by Lemma 8.0 and a recalled-in-full inseparability argument.

**Computations.** Scripts in `checks/`, seed 20261016, outputs next to them. Each was run twice and the outputs compared byte for byte (`diff` empty for all four). Total running time under 1 s.
* `c1_structure.py` → `c1_structure.out`: an independent finite stand-in written from the definitions here (not from scout F's `c1_toy.py`). Exact rational arithmetic. Results: 400 random instances (173 with $M(D)>0$). The semimeasure inequality, defect = three-valued mass = $M\cdot\Indep$, $M^3$ additivity, geometric conditioning, Dempster conditioning, the plausibility identity, the N10 decomposition: all exact (error $0$). Order independence over all permutations: max error $8.9\cdot10^{-16}$ (floats). Total monotonicity and bracketing: no violation. Graded CR: weak semimeasure and $\ge M$ in all trials, strictly charges an entailed datum in 61 trials, splitting non-invariance $\frac34$ vs $\frac58$. Limit posterior: total variation never exceeds $(a_n-a)/a_n$ (300 streams). Incomplete truth with two models: the two-valued limit leaves $T^*$ and its two completions with independent-sentence trichotomy equal to the prior shares $(0.30,0.45,0.25)$; three-valued data leave only $T^*$. Merging identity: max error $6.7\cdot10^{-16}$ over 60 instances, and the bound held with margin $\ge0.24$ bits. Agreement with scout F's `c1_toy.out` is qualitative for the random parts (same identities, different random instances) and numerical for its Part B (see c2 B1b).
* `c2_separations.py` → `c2_separations.out`: (B1) PR loss converges to $2.7004=-\log(w_{\rm all}/\text{consistent mass})$ while the Dempster loss grows at $1.17$ bits/step, above the proved per-step floor $0.38$; closed form vs brute force (up to 8 atoms) agree exactly. (B1b) Scout F's c1 Part B, recomputed by brute force with its weights on 7 atoms, reproduces its printed PR and CR losses at $t=1,2,3,5$ to the printed 4 decimals (max difference $4.7\cdot10^{-5}$, rounding). (B2) the explicit law gives CR losses 1 and 2 bits in the two orders, PR $\frac12$ in both. (B3) on 406 random laws the closed form of Thm 11.1(a) holds exactly; strict inequality in all 191 laws with positive numerator, equality in all 215 with zero numerator. (B4) for $n=2,\dots,5$ the mean order gap is $2.24,3.36,4.47,5.54$ bits against the proved floor $n\,w_{\rm coin}/2=0.25n$, and the per-pair bound holds for every $y$. (B5) graded/PR gaps exceed the proved lower bounds in every case.
* `c3_kolmogorov.py` → `c3_kolmogorov.out`: for $m=2,\dots,5$ atoms and 24 random program lists (random orders and "decoys first"), the Kolmogorov predictor fails exactly $2^m-1$ times, as Thm 11.3 says; the Bayes predictor makes 1–5 mistakes, always below its bound.
* `c4_coloring.py` → `c4_coloring.out`: $3^{2^{\ell_d}}<2^d$ and $\ell_d>\log d-2$ for all $d=2,\dots,200$ (exact integers); toy lists of short theories for $d=10,16$ have colliding atom pairs that no listed consistent theory separates.

The scripts check finite identities and the finite stand-ins of the constructions; they do not check the statements about universal machines.

**Self-checks that changed claims during this round.**
1. *Thm 11.1 first attempt*: I expected the normalised order question to be as hard as P1's. Computing the two orders on $\{(a,1),(a\vee c,1)\}$ symbolically showed the difference is a sum of nonnegative cell products with a term ($p_{0\iota}$) that universality makes positive; then the averaging argument gave a linear gap.
2. *Prop 7.2(b)*: I first tried to prove CR order dependence for $M_A$ itself on the same pair; the difference there is a signed combination of type masses, so I kept the explicit-law result and marked the $M_A$ case open.
3. *Thm 11.3*: an early version claimed the stream needed a target of complexity about $m$ chosen in advance; choosing $w^*$ as the $w$ with the last $\pi(w)$ removes that, and Kraft's inequality then shows $K_A(D)\ge m$ automatically (so a simple $w^*$ cannot occur, which resolved an apparent conflict with the $2^k$ upper bound).
4. *Prop 11.4(c)*: I first wanted "Q6 implies P1 Q3.14 (binary)" for the unrestricted Q6; but the provability function of an lsc random literal set need not be lsc on all sentences (unions of containment events), so the equivalence is stated only for the literal restriction.
5. *Prop 6.4(b)*: scout F stated Solovay's theorem with the coin-free $I$; I recalled the probabilistic version. The proof now works under both readings for the coin-free statement, and the one-tape statement (Prop 11.5(c)) is marked as needing the probabilistic reading.
6. *Prop 8.3(b)*: the scout's PA example needs an unverified theorem; replaced by a disjointness argument that needs none.

**Epistemic policy.** This thread is mathematical; nothing in it bears on a philosophical claim of the author's in a way that makes a disagreement probable, so there is no "possible error" note.

**Not done.**
* No reference was re-verified (web access unavailable); see §14.
* Prop 9.1(i), (iv) remain proof sketches (the support lemma for r.e. axiom sets with citation weights; measurability of $\omega\mapsto P_{A_\omega}$).
* The CR order dependence for $M_A$ itself, Q6 and Q2 remain open; the normalised order question on logically independent data (P1 Question A.8) is untouched.
* TF's assumption (S), used in Prop 1.8(b), was not re-derived.
* No referee has read this record; nothing was checked in a proof assistant.
* No git command that changes repository state was run.
