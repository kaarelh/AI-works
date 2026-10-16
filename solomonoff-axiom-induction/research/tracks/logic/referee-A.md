# Referee A (proofs) for thread `logic`

*Referee record, 2026-10-16. Subject: `research/tracks/logic/notes.md` (development round, 636 lines, §0–§10) and its scripts `checks/c0`–`c5`. The family studied has the working name "Solomonoff axiom induction" (SAI); nothing below depends on the name. Notation as in `../../NOTATION-draft.md` and the record's §1.*

## Verdict

**Sound in substance. Minor revision, with two major corrections. No fatal issue.**

I tried to refute every claim marked [proved] or [proved, given X] by checking it line by line. All of the core results survive:
* the lottery (Thm 2.2) and its arithmetic versions with false or true data (Lemma 2.8, Thm 2.9, Cor 2.10);
* the majority-vote boundary (Props 2.3, 2.4, 2.7);
* the horizon bound (Prop 2.6, Cor 2.6′);
* the threshold theories and the threshold machine (Thms 3.1, 3.2);
* the coding theorem for $\Pi_1$ data and its failure one level up (Cors 3.3, 3.5, 3.6; Props 3.8, 3.9);
* the Gödel phenomena (Prop 4.1, Thms 4.2, 4.4, Prop 4.3);
* the ω-gap (Props 5.1, 5.2, Thm 5.3);
* the $\Th(\mathbb N)$ bounds (Thm 6.1, Cor 6.2, Prop 6.3).

The quantifier order and the constants are right throughout: every $c$ is independent of the data, of $k$ and of $d$ where the statement requires it. The normalisation is handled correctly, including the correction of scout N1's C2. The uses of `fundamentals`, `sfi` and the SOI papers respect their hypotheses, with one exception (M2).

Two issues need a change of statement or status:
* **M1.** Prop 4.5 is false as stated. It is missing a truth hypothesis on the background $B$; a counterexample is given below.
* **M2.** §5.4(c) cites the earlier report's ω-gap theorem with status "known" for a conclusion that the cited part (Thm 3.9(d)) contradicts.

The remaining issues (m1–m17) are wording, missing side conditions, a double count in one auxiliary proof (Remark 3.4) whose fix is immediate, and related-work and novelty points.

**Re-runs.** I re-ran `c1`–`c5` on scratch copies; the outputs are byte-identical to the saved ones. I read `c3_threshold.py` in full: its T4 check counts all multiples of $2^{-L}$ at each level, which is the double count in m6.

---

## 1. Claims checked and found correct

Each entry was re-derived independently. Points where I first suspected a gap and then convinced myself that the proof holds are noted.

| item | outcome | notes from the line-by-line check |
|---|---|---|
| Lemma 2.1 | correct | outer regularity plus a prefix-free decomposition of $O$ |
| Thm 2.2 (a)–(d) | correct | existence of $j^*_e$ uses the second conjunct of $\mathrm{Lot}_e$ and the equality axioms; consistency of $G_{\rm lot}$ uses distinct numerals and a $\mathrm{Win}$-free $B$; (c)'s finite-theory clause uses that the $\mathcal L$-content of $\psi$ is r.e. (see m1); (d) uses dominated convergence and the lower bound from (a); the product is $(1/2;1/2)_\infty=0.288788\ldots$ |
| §2.3 remarks | correct | an r.e. stream is its own theory; the CR remark holds because $\{\mathrm{Lot}_k\}$ is consistent with all of $D_\infty$ |
| Prop 2.3 (a) | correct | $1-j\varepsilon\ge\varepsilon$ for $j\le r$, $\varepsilon=1/(r+1)$; strictness comes from the union bound with strict inequalities |
| Prop 2.3 (b) | correct | the events $\{f_\omega(x)=y\}$ are effectively open and disjoint in $y$, so "the $y$ with probability $>\frac12$" is partial computable |
| Prop 2.4 | correct | $\Pr_w(O_\varphi)+\Pr_w(X)>1$ gives $O_\varphi\cap X\ne\emptyset$; $X$ is Borel |
| Prop 2.6 | correct | $\mathrm{Good}_m$ needs a consistent continuation, as the record says; the injectivity of $u\mapsto e(G,u)$ is needed and present |
| Cor 2.6′ | correct (see m4) | $\eta(g(n)+1)>n$; the reformulation of $j^*_k$ by $\Sigma_1$ facts is equivalent to the definition (an inconsistent $\mathsf W_k$ refutes every ticket); fewer than $2^{K+1}+K$ facts |
| batch lottery | correct | at most $2^k$ reported tickets among $2^{2k+1}$; horizon $\le(n+1)^2$ |
| Prop 2.7 | correct | $C^s_k\supseteq D^\pm_\infty\cap S_k$ for every $s$; first consistent stage computable by (ii); consistency by compactness and (i). For instance (1) I checked the combinatorial consistency criterion for a block, by building the $\mathrm{Win}$-row of $\underline k$ in a model with distinct numerals |
| Lemma 2.8 | correct | the diagonal lemma with a free variable in $\Q$ (the strong form $\Q\vdash\forall x(\Phi(x)\leftrightarrow\Theta(\ulcorner\Phi\urcorner,x))$ is standard); the contradiction uses the truth of $B$; (i) needs "$y\in F$" to be literally $\mathrm{In}(y,\underline{e_F})$, which it is by definition |
| Thm 2.9 (a), (b) | correct | (b): $t_k$ is computed from the same refutation facts that $\Psi$ reads; $j^*_e$ exists in both sub-cases; every datum is true because $j^*_k\ne t_k$; the reduction to Boolean combinations needs bounded quantifiers in $\Psi$ ("for some $k$" should be written $\exists k\le x$), which $\Q$ unfolds for a numeral |
| Cor 2.10 (i)–(iii) | correct | (iii): the three cases ($J>t_k$; $J<t_k$, including $J=0$; no ticket refuted) are exhaustive, and each yields a false $\Sigma_1$ theorem $\mathcal A_{k,J}$ or $\mathcal A_{k,J}\vee R_J$; conditional independence given survival holds because survival is a product event |
| Thm 3.1 | correct | the floor truncation needs no irrationality; (iii) needs $B$ true for "$B\cup T_k$ true" (it is assumed) |
| Thm 3.2 | correct | the thresholds $0.r_{1:s}+2^{-s}$ decrease strictly to $r$ for non-dyadic $r$; the case $D=\emptyset$ gives equality $1-\Inc_0$ on both sides; $\pi_D\in\Pi_1^*$ because $\Pi_1^*$ is closed under conjunction |
| Cor 3.3, Cor 3.5 | correct | |
| Rem 3.4 | correct after a one-line fix | see m6 |
| Cor 3.6 | correct | $h_m\le2^m$ by Kraft (each halting program of length $\le m$ contributes $\ge2^{-m}$); the derivation of $\mathrm{Kgt}_m(x)$ from $\beta_m$ and the true $\Delta_0$ sentence is pure logic; the $\log$ terms are kept |
| Prop 3.7 | correct | $T\subseteq T_k$ gives $e_k\in\Ext T$; the "+1" from the ceiling is absorbed into $c$ |
| Prop 3.8 | correct (see m7) | $2^\ell<d/\log3$, so $3^{2^\ell-1}<2^d$ colours; a program shorter than $\ell$ that is compatible with $D$ would give the two strings different colours |
| Prop 3.9 | correct (see m7) | the colour entries can be written as Boolean combinations of $\Sigma_1$ facts. "$V(p)\downarrow\wedge\Con(B\cup\mathsf W_{V(p)})$" must be written as "$\exists t\,\exists e\,T(p,t,e)\ \wedge\ \forall t\,\forall e\,(T(p,t,e)\to\Con(B\cup\mathsf W_e))$", not with an existential over $e$ in front of $\Con$, which would be $\Sigma_2$. The truth of the data does not depend on which form is chosen. The record should fix the form, since the complexity claim does depend on it |
| Prop 4.1 | correct | (c) uses the deduction theorem for finite $D^\pm$; the "extreme case" uses $\PA\vdash\Con(T)\to\Con(\PA)$ for $T\supseteq\PA$ |
| Thm 4.2 | correct | $g$ is injective; the image of $\mm$ under $g$ is dominated; G2 is applied to the presentation $B\cup\mathsf W_e\supseteq\PA$ |
| Prop 4.3 | correct | |
| Thm 4.4 | correct | the derivation of $U_w=\{\pi:\Unif(O_\pi)>0.w\}$ also covers emissions under *shorter* prefixes $u\sqsubseteq w$ (their thresholds are $\ge0.w+2^{-|w|}$). The inclusion $U_{w'}\subseteq U_w$ is provable in $\PA$ for any natural presentation (every prefix of $w'$ is comparable with $w$). The longest-prefix argument covers both $0.w^*<\Inc_0$ and $0.w^*>\Inc_0$; irrationality of $\Inc_0$ excludes equality. This is the strongest new result of §4 and it holds |
| §4.4, Win-lottery bullet | correct | a model of $B+\neg\Con(B)$ has distinct numerals (any model of $\Q$ does) |
| Prop 4.6 | correct | |
| Prop 5.1 | correct (see m10, m11) | |
| Prop 5.2 | correct (see m9) | a theory proving $\forall x\varphi$ proves every instance, so the events are nested |
| Thm 5.3 | correct (see m12) | no circularity: $T_k$ is fixed before $\delta_k$ is defined from $e_k$; the lower bound uses the one-sentence theory with an index computable from $e_k$ |
| §5.4 (a), (b) | correct | (b) is trivially true for $\Bel$, because every sentence is a datum; the content is the loss bound |
| Prop 5.4 and Example | correct (see m13) | five lines for $n\ge1$, three for $n=0$ |
| Thm 6.1 | correct | `fundamentals` Prop 8.6(b)'s lower bound $K(b_{1:n}\mid n)-c\le L_A(D_n)$ is proved there via Prop 6.1(a), whose procedure $Q_S$ outputs the first member of $S$ found. It is therefore a semimeasure even though $M_A$ is not lower semicomputable, so the use is legitimate. $|\beta_k|=|\beta|-1+|\underline k^{\rm b}|$; $\gamma^{c_1\log_2k}=k^{1/\delta}$; $|\underline k^{\rm b}|\le5\lfloor\log_2k\rfloor+2$ checked (c5) |
| Cor 6.2 | correct (see m14) | $\log\binom nu\le u\log(en/u)$, $K(u\mid n)\le\log n+c$ |
| Prop 6.3 | correct | |

---

## 2. Major issues

**M1. Prop 4.5 is false without a truth hypothesis on $B$ (hidden hypothesis).**

*Where.* Prop 4.5 assumes only "$T$ a true r.e. theory with $\PA\subseteq\Cn(B\cup T)$". The proof of (a) uses "$T+\gamma$ (true)". That requires $B\cup T\cup\{\Con(B\cup T)\}$ to be consistent, so $B$ must be true, or at least $B\cup T\nvdash\neg\Con(B\cup T)$. Nothing in §4 assumes $B$ true globally: Prop 4.1 and Thm 4.2 assume only consistency.

*Counterexample.* Take:
* $B:=\PA+\neg\Con(\PA)$, which is decidable and consistent by G2;
* $T:=\emptyset$, which is true;
* $\gamma=\Con(B)$.

Then $B\vdash\neg\Con(\PA)$, and $\PA\vdash\Con(B)\to\Con(\PA)$, so $B\vdash\neg\gamma$. Hence $\lim\Bel(\gamma)=0$ and $\lim\Dis(\gamma)=1$, contradicting (a). Part (b) then says nothing, and (c) fails because no choice of $V'$ can give $\gamma$ positive belief.

*Fix.* Add "$B$ true" (or "$B\cup T$ true") to the hypotheses. With $B\cup T$ true:
* $T+\gamma$ is true;
* $T+\neg\gamma$ is consistent by G2;
* $T$ decides neither $\gamma$ nor $\neg\gamma$.

So the proof goes through unchanged. Also update the §0.2 table entry, and the "Answer to the brief's question" paragraph, which speaks of "data from a true $T$".

**M2. §5.4(c) misquotes the earlier report's ω-gap theorem under status "known".**

*Where.* §5.4(c) reads: "[known: AI-paper Thm 3.9(c),(d)] With $\forall x\varphi$ in the data space under a faithful likelihood, or with a selection-aware likelihood for filtered data, the posterior of 'proves $\forall x\varphi$' converges to the truth value." The same theorem is relied on, through the summary's "closures (ω-rule, second order, generative)".

*What the source says* (`../../../../axiom-induction/paper/sections/universal.tex`, Thm `thm:univ:omega`, lines 102–113):
* **(c1).** With $\forall x\varphi\in X$ and a faithful likelihood, $P(T\vdash_{\mathsf C}\forall x\varphi\mid D_n)\to\ind[T^*\vdash_{\mathsf C}\forall x\varphi]$. This is whether the *generator* proves the universal, not its truth value.
* **(d1).** For filtered data with quantifier-free $\varphi$ in $\Cmin$, the limit is $0$ under $\Lone$ and **"the prior share under $\Lsel$"**. So under the selection-aware likelihood the gap stays open.
* **The only "$\to1$" under $\Lsel$** is `prop:univ:noguard`(c). That is a *proof sketch*, for unfiltered closed data from $\Qnum$ in a specific class with finitely many splits $R_k$, in pure logic.

*Fix.* Replace (c) with the following:
* "(c) The generative variant [known: AI-paper Thm 3.9(c1)]: with $\forall x\varphi$ in the data space under a faithful likelihood, the posterior of 'proves $\forall x\varphi$' converges to $\ind[T^*\vdash_{\mathsf C}\forall x\varphi]$.
* For filtered data the gap stays open: the limit is the prior share under $\Lsel$ (Thm 3.9(d1)), or a filter-prior mixture (Thm 3.9(e)).
* AI-paper Prop `prop:univ:noguard`(c) [proof sketch there] reports convergence to $1$ under $\Lsel$ in one unfiltered class without a guard."

Then:
* drop "generative" from the list of closures in §0.1, or qualify it as "with the universal sentence among the data";
* in §5.1's "Relation to the AI-paper's ω-gap theorem", replace "it tends to the truth value" by "it tends to $\ind[T^*\vdash_{\mathsf C}\forall x\varphi]$".

---

## 3. Minor issues

**m1. Thm 2.2(c), the finite-theory clause.** "$X_\psi$ is r.e." needs $\mathcal L'$ to have computable syntax, as in `fundamentals` Def 1.1. *Fix:* write "for every language $\mathcal L'\supseteq\mathcal L$ with computable syntax".

**m2. §2.6, "every stream of the lottery kinds that answers Q1 negatively is properly $\Delta_2$".** This is overstated. §2.3 and Prop 2.7 show that such a stream is neither r.e. nor co-r.e. They do not show that it is $\Delta_2$: an arbitrary stream of lottery data with a positive survival event can be of any complexity, for example a diagonal against a non-arithmetical list. *Fix:* "is neither r.e. nor co-r.e.; the streams constructed here are $\Delta_2$."

**m3. Cor 2.6′ and §0.1: "slower than any computable unbounded function".** The proof is for computable unbounded **nondecreasing** $G$, and the claim fails for non-monotone $G$ (take $G=0$ on odd $n$). *Fix:* add "nondecreasing" in the bullet, in §0.1, and in the E-Q2 paragraph, where the bound on horizons by a computable function also needs a monotone bound, or "$\max$" of one.

**m4. Prop 4.5(c), proof wording.** "So $\lim\Bel\ge1-2^{-j}$ and $\lim\Dis\le2^{-j}$" mixes normalised and unnormalised quantities. The masses are $\ge1-2^{-j}$ and $\le2^{-j}$, and the normalised $\lim\Dis$ is $\le2^{-j}/\Unif(E_\infty)\le2^{-j}/(1-2^{-j})$. The ratio claim, which is what (c) states, is right. *Fix:* "the masses of the two events are $\ge1-2^{-j}$ and $\le2^{-j}$; dividing by the common normaliser $\Unif(E_\infty)$ gives the ratio."

**m5. §4.4, bullet "machines with a tape prefix $w$ whose continuation-union $U_w$ is consistent: yes".** D-Q1 asks for a bound uniform over all data. N1's companion (N1 lines 847–852) shows something narrower: the posterior mass of such machines' tapes extending $w$ is matched, at $+c$ bits, by unsound mass. That does not answer D-Q1 for any class of data. *Fix:* state exactly that, for example "for every machine $G$ and prefix $w$ with $B\cup U^G_w$ consistent: $M_A(D;\text{unsound})\ge2^{-K(G)-c}\nu_G(D;[w])$."

**m6. Remark 3.4, double count across levels.** For each level $L$ the proof counts "dyadic rationals of level $L$" in the interval, and sums $\mm$ over the indices of $Z_q$, "injective in $q$". A rational $j/2^L$ is also $2j/2^{L+1}$, so the same index is counted at every finer level, and the sum $\sum_{L\ge k+1}2^{L-k-1}2^{-L-K(L)-c}$ is not a lower bound on $W_A$ as written. `c3` T4 checks the per-level count only (all multiples of $2^{-L}$), so it does not detect this. *Fix (either):*
* index $Z$ by the pair $(j,L)$ rather than by the rational. Each pair has its own index, of complexity $\le L+K(L)+c$, and the r.e. set is the same, so the count $2^{L-k}-1\ge2^{L-k-1}$ is right as it stands;
* or count odd numerators only, which costs a constant factor and starts at $L\ge k+2$.

The stated bound survives with an adjusted constant.

**m7. Props 3.8, 3.9: coding of strings and syntactic classes.**

(a) "Strings read as numbers" must be injective across lengths, and in Prop 3.9 $\Psi$ must recover $d$ from $x$. Binary reading identifies $01$ with $1$. *Fix:* use the length-lexicographic rank (as in Cor 3.6) throughout.

(b) NOTATION §1 and the record's §1.2 define $\Pi_1^*$ syntactically. $\Phi_0(\underline{x_2})$ is only $\Q$-*equivalent* to a false $\Sigma_1$ sentence, and $\neg\Phi_0(\underline{x_1})$ to a true $\Pi_1^*$ sentence; the same holds for the data of Thm 2.9 and Table 3.10.

Nothing breaks, because $O_\chi$ depends only on the $B$-equivalence class of $\chi$ and $B\supseteq\Q$. But a reader comparing Prop 3.8 with Cor 3.3 needs to see that the classes are closed under $\Q$-equivalence. *Fix:*
* write "$\Q$-equivalent to" in Props 3.8, 3.9, Thm 2.9 and Table 3.10;
* add one sentence in §3.1: "Being of $\Pi_1$ type is invariant under $B$-equivalence of literals, since $M_A$ depends on $D$ only through $\Cn(D^\pm)$ (Old)."

**m8. Prop 3.9: the form of $\Psi$** (see the table in §1). Specify that the consistency entry of a colour is written as $\Sigma_1\wedge\Pi_1$, using the uniqueness of $V(p)$'s output through a universally quantified $\Pi_1$ conjunct. Otherwise the "Boolean combination of $\Sigma_1$" claim depends on $\Q$ proving the uniqueness of outputs, which is a $\Pi_1$ fact that $\Q$ need not prove.

**m9. "Settle" in Prop 5.2, §0.1 and §7.** The proposition proves that the Gaifman gap is $0$ iff $I\vdash\forall x\varphi$. In the ω-inconsistent case, $I\vdash\neg\forall x\varphi$, the instances "settle" the universal in the ordinary sense, yet the gap equals $\Unif\{\text{consistent extensions of }I\}>0$. *Fix:* replace "deductively settle" by "deductively prove" in §0.1, the §0.2 table, Prop 5.2's reading and §7.

**m10. §5.1, remark "case (iii) holding iff $B\nvdash\forall x\varphi$".** This needs $B$ to be $\Sigma_1$-sound.

*Counterexample.* Take $B=\PA+\neg\Con(\PA)$ and $\varphi(x)$ the $\Delta_0$ formula "$x$ is not a $\PA$-proof of $\bot$". Every instance is true and $\Q$-provable, so $I=\Cn(B)$. And $B\vdash\neg\forall x\varphi$, so case (ii) holds although $B\nvdash\forall x\varphi$.

*Fix:* "case (iii) holding iff $B$ decides $\forall x\varphi$ neither way; for $\Sigma_1$-sound $B$, iff $B\nvdash\forall x\varphi$."

**m11. Prop 5.1 cites `fundamentals` Prop 8.3(a) for $P_\infty$, but 8.3 is stated for incomplete $B\cup T^*$.** In cases (i), (ii) $I$ may be complete. The identification "$P_\infty$ = prior restricted to the consistent extensions of $I$" needs only Prop 8.1 and the definition of $E_\infty$. *Fix:* cite Prop 8.1 together with $E_\infty=\{\omega:B\cup A_\omega$ consistent, $\Cn(A_\omega)\supseteq I\}$.

**m12. Thm 5.3: G2 is applied to a rewritten sentence.** $\forall x\,\delta_k$ is a rewriting of the canonical $\Con(B\cup T_k)$, with a single quantifier, a $\Delta_0$ matrix and computation witnesses for membership in $B$ and $T_k$. (G2) as stated in §1.2 concerns the canonical sentence. *Fix:* add "$\PA\vdash\forall x\,\delta_k\leftrightarrow\Con(B\cup T_k)$ (standard)". G2 then applies, because $B\cup T_k\vdash\forall x\delta_k$ would give $B\cup T_k\vdash\Con(B\cup T_k)$.

**m13. Prop 5.4 and its Example.**

(a) The statement presupposes that the limit set (the $\psi$ that $\ell$-prove every instance) is nonempty, since otherwise there is no limit posterior. *Fix:* move "nonempty when $B\cup\{\forall x\varphi\}$ is consistent and $\ell\ge$ the instantiation length" into the hypotheses.

(b) In the Example every instance is logically valid. The data are therefore old evidence (Prop 4.6): the posterior never moves, and the line budget plays no role, since $\ell=5$ admits every consistent $\psi$. The Example is a correct counterexample to the Kreisel property with $B=\emptyset$, but it says less than it appears to. *Fix:* say so in one sentence. Optionally add an example in which the instances are not logically valid (for instance over $B=\emptyset$ with a fresh predicate) and some $\psi$ proves all of them in boundedly many lines without proving the universal. If none is found, say that the Example is of the degenerate, old-evidence kind.

**m14. Cor 6.2 and Thm 6.1 Remark (ii).**

(a) Cor 6.2 needs the intermediate inequality $K(b_{1:n}\mid n)\ge\lfloor(n/C')^\delta\rfloor-K(n)-c$ from the *proof* of Thm 6.1, not the theorem's statement about $L_A$. *Fix:* state that inequality as part of Thm 6.1, or as a lemma.

(b) Remark (ii) ("with unary numerals ... only a logarithmic bound") is vacuous as the bound is written. With unary numerals $m\approx\log_\gamma n<\log_2n$, while the subtracted $K(n)$ can be $\approx\log_2n$. A logarithmic bound needs the monotonicity of $L_A(D_n)$ in $n$: apply the bound at some $n'\le n$ with small $K(n')$, for example $n'=2^{2^j}\ge\sqrt n$. *Fix:* say so. The same trick removes $K(n)$ from Thm 6.1 at the cost of a constant factor in $n$; this is optional.

**m15. §3.4, novelty against Bienvenu et al. (2014) and Shen (2011): the claim is stronger than the evidence.** The record's verification level for these papers is abstract and snippets. The full text could not be fetched in this round either: arXiv, ar5iv, HAL, lirmm.fr and ECCC are all blocked or unresolved through the proxy. Two points:
* "Neither is a counting argument over a fixed axiom scheme" asserts something about how Bienvenu et al. prove their results. The record has not seen that.
* The soundness corollary the record does cite ("a statement proved with probability above the capital is true") already contains the *threshold idea*: the statements proved with probability above a known error level form an r.e. set of true statements.

What is plausibly new here:
* the threshold just above an *unknown* error level $\Inc_0$, paid for by its $k+2$ bits;
* the universal mixture over all theory machines;
* the single random threshold theory $G^*$ (Thm 3.2);
* the coding theorem as a statement about an inductive rule.

*Fix:*
* rewrite (2) of "What is new here" to say this;
* add "the threshold device itself is the soundness argument of Bienvenu et al. and the averaging argument of de Leeuw et al.";
* keep "full text not read; to be checked against their §2 and Shen's Prop 2" in the open list.

This agrees with scout L's record (§3.7), which describes Bienvenu et al. only as "random axioms add no deductive power" at the abstract level and makes no claim about their proof technique.

**m16. §7, related work for the lottery: the computability-theoretic ancestor is missing.** The record compares the lottery with de Leeuw et al. (1956) and Kyburg (1961). The closer formal ancestor is the classical fact that randomness helps for *mass problems*: a positive-measure class can have no computable member. In particular:
* Kučera's argument that random sequences compute diagonally non-computable (DNC) functions;
* the dichotomy for $q$-bounded DNC functions, according to whether $\sum_n1/q(n)$ converges (search snippet of Bienvenu and Porter, "Deep $\Pi^0_1$ classes", arXiv:1403.0450: "not tt-negligible when $\sum1/q(n)<\infty$, deep when it diverges"; not read in full).

The lottery's survival condition $\sum_k1/(N_k+1)<\infty$ is exactly this convergence condition. Its diagonal ticket $j^*_k$ plays the role of the diagonal value, computed from $\emptyset'$ against r.e. theories instead of partial computable functions. The de Leeuw et al. theorem concerns single-valued outputs; the lottery is a mass problem. The new content is:
* that consistency constraints of unbounded arity turn the inducer's compatibility event into such a mass problem;
* the arity boundary (Props 2.3, 2.7);
* the arithmetic versions with true data (Thm 2.9, Cor 2.10).

*Fix:* add this paragraph to §7 and to the paper's related work, after verifying the DNC references (Kučera 1985; Bienvenu–Porter 2016). Phrase the "no analogue in SOI on strings" claim of §0.1 as "no analogue in plain SOI", which Prop 2.3(b) proves.

**m17. §6.1 and §6.2: the description of Calude–Jürgensen (2005).**
* The abstract says that "the probability that a true sentence of length $n$" (arXiv listing: "an $n$-bit statement") "is provable ... tends to zero", and that the probability that a sentence of length $n$ is true is positive. The probability space is the $n$-bit Gödel codes; δ-complexity is their measure of complexity, not the probability measure.
* The reason their theorem does not transfer should therefore be stated as a property of the encoding: their density of sentences among $n$-bit codes, against the sparse sentence counts of a natural syntax (c5: about $5.38^L$ formulas against $14^L$ strings).
* The record says the theorem "says nothing decisive" about Q3. That is right for Q3 itself, but understates the relation to Prop 6.3. If the Calude–Jürgensen statement held in the length enumeration of §6, then every true r.e. $T$ would leave a positive fraction of sentences undecided, so $u_n(T)\ge\rho n$, and Prop 6.3's sufficient condition would fail for every $T$.

*Fix:* describe their probability space precisely, and say that a natural-syntax version would refute Prop 6.3's route, though not Q3, since $K(b_{1:n}\mid n)$ could still be $o(n)$.

---

## 4. Points checked that need no change

* **Novelty claims against scout L's record.** I checked the following against `../../scouts/literature/notes.md` §3.2 and §3.7; the descriptions agree with scout L's record and with the search results seen in this round:
  * Gaifman;
  * Scott–Krauss;
  * Hutter et al. (they impose the Gaifman condition);
  * Demski (a complete random theory);
  * logical induction (not Gaifman-inductive, because of Sawin–Demski);
  * Sawin–Demski ("arbitrarily low limiting probabilities to some short true $\Pi_2$ statements", confirmed from the MIRI abstract via search);
  * Chaitin and Raatikainen;
  * Levin (2013).

  The Observation L1 sharpening (Prop 5.2) is consistent with scout L.
* **Kreisel's conjecture literature (§5.5).** Hrubeš (2007) lists $\PA(-)$, the integers, $\PA(q)$ and $\PA(N)$; his preprint credits Yukami (1978) with the failure when all true multiplication equations are added; Hrubeš (2009) proves the conjecture for $\PA$ axiomatised with the minimality principle. These are confirmed at abstract level by search; the record's descriptions match.
* **Uses of `sfi` and `fundamentals`.** `sfi` Thm 2.1 and Thm 3.1 (for §2.3) hold for any decidable consistent $B$, as needed. `fundamentals` Thm 4.1 (Dom), Prop 6.1(c) (Chain), Prop 8.1 (Lim), Prop 2.1(c) (Old), Lemma 1.3, Thm 3.2(a) and Prop 8.6(b) are all used within their hypotheses (but see m11).
* **The correction to scout N1's C2.** It is right: $\Bel_0$ is unnormalised.
* **Withdrawn claim 10.** Withdrawing "the limit posterior lives on $\Sigma_1$-unsound theories" was right. Prop 2.4's argument does not transfer, because $\Sigma_1$-soundness is not a constraint of arity one.
* **Possible error in the author's view.** None was raised, and I see none to raise from the proofs.

---

## 5. Summary of required changes

| # | severity | where | change |
|---|---|---|---|
| M1 | major | Prop 4.5 | add "$B$ true" (or "$B\cup T$ true"); counterexample $B=\PA+\neg\Con(\PA)$, $T=\emptyset$ |
| M2 | major | §5.4(c), §5.1, §0.1 | correct the citation of AI-paper Thm 3.9: (c1) gives $\ind[T^*\vdash_{\mathsf C}\forall x\varphi]$; (d1) under $\Lsel$ gives the prior share; only `prop:univ:noguard`(c), a proof sketch, gives $\to1$ |
| m1 | minor | Thm 2.2(c) | $\mathcal L'$ with computable syntax |
| m2 | minor | §2.6 | "properly $\Delta_2$" → "neither r.e. nor co-r.e." |
| m3 | minor | Cor 2.6′, §0.1, E-Q2 | add "nondecreasing" |
| m4 | minor | Prop 4.5(c) proof | masses against normalised limits |
| m5 | minor | §4.4 | restate the partial D-Q1 case precisely |
| m6 | minor | Rem 3.4 | index by $(j,L)$, or count odd numerators |
| m7 | minor | Props 3.8, 3.9, Thm 2.9, Table 3.10 | length-lex coding; "$\Q$-equivalent to" |
| m8 | minor | Prop 3.9 | specify the $\Sigma_1\wedge\Pi_1$ form of the colour entries |
| m9 | minor | Prop 5.2, §0.1, §7 | "settle" → "prove" |
| m10 | minor | §5.1 remark | needs $\Sigma_1$-soundness of $B$; counterexample |
| m11 | minor | Prop 5.1 | cite Prop 8.1, not 8.3(a) |
| m12 | minor | Thm 5.3 | $\PA$-provable equivalence with the canonical $\Con$ |
| m13 | minor | Prop 5.4, Example | nonemptiness hypothesis; valid instances, so old evidence |
| m14 | minor | Cor 6.2, Rem 6.1(ii) | state the $K(b\mid n)$ inequality; the unary remark needs monotonicity |
| m15 | minor | §3.4 | soften the novelty of the threshold device; say what is new |
| m16 | minor | §7, §0.1 | add the DNC and mass-problem ancestry of the lottery; "plain SOI" |
| m17 | minor | §6.1, §6.2 | Calude–Jürgensen's probability space, and its bearing on Prop 6.3 |

---

## Verification log

**Read in full:**
* the thread record `research/tracks/logic/notes.md` (all 636 lines);
* its brief `tracks/logic/00-brief.md`;
* the project brief `research/00-brief.md`.

**Read in the parts the record uses:**
* `tracks/fundamentals/notes.md`:
  * Defs 1.1–1.10, Lemma 1.3, Prop 1.8;
  * §3 (Prop 3.1, Thm 3.2, Prop 3.4);
  * §4 (Thm 4.1, Props 4.2, 4.3);
  * §5 (Thm 5.1, Prop 5.6);
  * §6 (Prop 6.1, Thm 6.2);
  * §8 (Lemma 8.0, Props 8.1–8.7).
* `tracks/sfi/notes.md`: Thm 2.1, Thm 3.1, Cor 4.2.
* Scout N1's record `scouts/novel-logic/notes.md`: D2′ and the companion construction, lines 834–854.
* Scout L's record `scouts/literature/notes.md`: §3.2, §3.7, Observation L1.
* The AI-paper `../axiom-induction/paper/sections/universal.tex`: Thm `thm:univ:omega` (lines 100–113) and Prop `prop:univ:noguard` (lines 132–136).
* `NOTATION-draft.md`, for the definitions of $\Pi_1^*$, $\mathrm{Lot}_k$, $\mathrm{Kgt}_m$ and $\Inc_0$.

**Proof checks.** Every item marked [proved] or [proved, given X] in §2–§6 was re-derived by hand, line by line. §1 above lists the points that needed care. I constructed counterexamples for M1 and m10, and checked them against G2 and the $\Sigma_1$-completeness of $\Q$.

**Computations.** I copied `c1_lottery.py`, `c2_majority.py`, `c3_threshold.py`, `c4_trichotomy.py` and `c5_syntax.py` to a scratch directory and re-ran each with `python3 -I`. Every output is byte-identical to the saved `.out` file, and each run took under a minute. I read `c3_threshold.py` in full; its T4 check counts all multiples of $2^{-L}$ per level, which is consistent with m6. I did not review the code beyond that; the code is referee B's task. No new scripts were written: no claim needed a computation to refute or confirm it beyond the re-runs.

**Literature (WebSearch only).** Page fetching failed in this round:
* arxiv.org, ar5iv, HAL, lirmm.fr, ECCC, semanticscholar.org: `curl` returned 403 from the proxy, and `WebFetch` failed with "getaddrinfo ENOTFOUND".

Searched in this round:
* Bienvenu et al. 2014: abstract only; their §2 statements were not seen (m15).
* Shen 2011: abstract only.
* Calude–Jürgensen 2005: two abstract versions, "true sentence of length $n$" and "$n$-bit statement" (m17).
* Sawin–Demski 2013: MIRI abstract, which confirms "short true $\Pi_2$".
* Hrubeš 2007 and 2009, and Yukami 1978 via Hrubeš's preprint (§4 above).
* Bounded DNC and the $\sum1/q$ dichotomy: Bienvenu–Porter, "Deep $\Pi^0_1$ classes", search snippet only (m16).

**Not done:**
* full texts of Bienvenu et al., Shen, Calude–Jürgensen and Bienvenu–Porter;
* no proof assistant.

No git command that changes repository state was run. I wrote only this file in the thread folder; scratch copies are under the session scratchpad.
