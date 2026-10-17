# Referee A (proofs) on thread `fundamentals`

*Adversarial referee report, 2026-10-16, on `notes.md` (dated 2026-10-15, 743 lines) and its scripts in `checks/`. Referee A checks proofs. Referee B checks code; its scripts `referee_code/rb*` are not mine and I did not change them. My one script is `referee_code/ra1_order_demski.py`, with its output `ra1_order_demski.out`. No earlier version of this report existed when I started (restart check, §5).*

---

## 1. Verdict

**Sound, with one major and seventeen minor issues. No fatal issue.**

I tried to refute every claim marked [proved], line by line (§2). None fails. The mathematics of §1–§11 survives the check:
* the new results Thm 11.1 (the normalised loss is order dependent, with a linear gap), Prop 11.2 (graded CR against PR) and Thm 11.3 (the Kolmogorov predictor fails exponentially often);
* the direct proofs that replace citations: Lemma 3.3, Lemma 8.0, and Props 8.6 and 8.7;
* the coding and no-coding results, Prop 6.1 and Thm 6.2.

What has to change:
* **One major issue (M1): a missed antecedent.** It bears on the novelty of the central object and on the Demski comparison in §10. The "modified Demski prior" samples a universal Turing machine fed random bits and reads its output as a (possibly infinite) list of sentences. That is the sampling stage of $G_U$. Neither this record nor the literature scout's record mentions it.
* **Seventeen minor issues.**
  * Missing hypotheses: B∪T consistent; B = ∅ in Prop 8.5(b); a well-order in Thm 11.3; literals on distinct words.
  * A false side remark in Prop 1.8(c).
  * Statuses that are stronger than their support: Q1's answer, and some novelty labels.
  * References I could verify by web search, which the record lists as unverified. One of them restores scout F's factor 2 at abstract level.

The record is honest about its limits:
* Prop 9.1(i) and (iv) are proof sketches.
* Prop 1.8(b) holds under TF's (S).
* Remark 6.3 and Prop 11.4(c) depend on `sfi` T5.

I agree with these statuses.

---

## 2. Claim-by-claim check of everything marked [proved]

"OK" means: I re-derived the proof, found no gap, and the statement is no stronger than the proof. Issue numbers refer to §3.

| claim | result of the check |
|---|---|
| Lemma 1.3 (measurability, basic form) | OK. Compactness and the linear order of prefixes give $O^G_\chi$ open; the c.e. pairs give effectiveness. |
| Prop 1.8(a) (deciders = enumerators, Craig) | OK. A sentence $\theta$ has at most one reading $\chi^{\wedge m}$ with $m\ge2$ (left conjunct, then $m$ is fixed by length), plus $(\theta,1)$. The decider halts when $\mathsf W_e$ is finite. Both maps are injective and add a constant. |
| Prop 1.8(b) | OK given TF Thm 2.2(b) under (S). Hypotheses on $t$ incomplete: **m8**. |
| Prop 1.8(c) | Inequalities OK. Side remark false: **m1**. |
| Prop 1.8(d) ($K_{\rm fin}-K_A$ unbounded) | OK. The theorem on constants applies because $B=\emptyset$ and $c_j$ does not occur in $\psi$. The upper bound uses an $N\ge n$ minimising $K(N)$. Credit: **m16**. |
| Def 1.9, Thm 4.1(i) | Inequalities between $\Unif_A[T]$, $\mm_\equiv(T)$ and $\mm(\Ext T)$ need $B\cup T$ consistent: **m2**. |
| Prop 2.1(a)–(g) | OK. (b): on $E_D$ the three events partition, since the theory is consistent. (d): monotonicity handles the first zero factor. (e): the empty machine and $\{(\epsilon,\bot)\}$ give both inequalities. |
| Prop 2.2(a)–(c) | OK. (b): $\bigcap_IO_{\chi_i}=O_{\bigwedge_I\chi_i}$ for one tape, and $\bigcup_iO_{\chi_i}\subseteq O_{\bigvee\chi_i}$. (c): a maximal consistent extension is deductively closed, and Borel measurability follows from finitely many open-set memberships per step. |
| Prop 2.3 (Dempster) | OK. On $C$, $O_{\neg\psi}\subseteq O_{\varphi\vee\neg\psi}$, and the deduction theorem applies to sentences. |
| Prop 3.1, Thm 3.2(a),(b) | OK. $G_\alpha$ has inconsistency probability exactly $\alpha$. The binary expansion of $\sum_{n\in K_0}2^{-n-1}$ is unique ($K_0$ infinite and co-infinite). In the Solovay reduction, $\alpha-\alpha_s\le2^{|p_\alpha|}(\beta-\beta_s)$ uses $\gamma-\gamma_s\ge0$. Novelty: **m9**. |
| Lemma 3.3 | OK. The interval $[\alpha_s,\alpha_s+2^{k+1-n})$ meets at most $2^{k+1}+1$ dyadic intervals of length $2^{-n}$. The constant depends on $\alpha,\gamma,k$: **m15**. Known result: **m9**. |
| Prop 3.4 | OK. Consistency of $B\cup D^\pm$ is $\Pi^0_1$. The three-valued events are Boolean combinations of $O_\chi$'s, with $O_a\cap O_b=O_{a\wedge b}$. |
| Thm 4.1, (ii)–(iv) | OK. (iii): the image of an lsc semimeasure under a computable map is lsc. |
| Props 4.2, 4.3 | OK. $G_U$ does not depend on $B$, so the same machine serves both backgrounds. |
| Thm 4.4, Cor 4.5 | OK. Checked: the preliminary fact $B'\vdash\neg\tau(\bot)$; consistency transfer in both directions; the (T2) step for $b=0$; compactness for $G^*$. For Cor 4.5, every $\mathcal L$-structure expands. $c$ depends on both settings (stated). |
| Thm 5.1, Prop 5.2 | OK. Thm 5.1 uses $[T]\subseteq\Ext T$, which needs $T$ consistent (assumed). Prop 5.2(c): "consistent for every $x$" forces $T$ to decide no $\alpha_j$. Small slip: "$T\vdash$" should read "$B\cup T\vdash$". |
| Prop 5.3(a),(b) | OK. (a): a mistake implies a conditional $\le\frac12$. (b): an eliminated program never returns, and Kraft gives at most $2^k$ programs of length $\le k$. |
| Thm 5.4 (three-valued merging) | OK. Step 1: $\{h_{t-1}=h\}$ is an event in $\xi_{<t}$ intersected with $\{f^G_\omega\supseteq D_h\}$, and $\xi$ is independent of $\omega$. Step 3: $S_n\le K(G)+\log M_A(\emptyset)$ pointwise, and $\Ex[-\log\nu^3_G(D_n)]\le n\log3$ by Tonelli. Step 4: $M^3_A$'s conditionals are probabilities (Prop 2.1(f)), so the KL is nonnegative. Pinsker in bits is $\|\cdot\|_1^2\le2\ln2\cdot\KL$. |
| Cor 5.5, Prop 5.6 | OK. For 5.6 I checked the Gibbs step $\sum_b2^{-K(b\mid\dom D)}\le1\Rightarrow\Ex K\ge n$. With logically dependent sentences, inconsistent labellings give $L_A=\infty$, so the bound still holds. |
| Prop 6.1(a)–(c) | OK. The output events of $Q_S$ are disjoint and effectively open. A consistent theory proves at most one member of $S$. (c) uses $K(x)\le K(y)+K(x\mid y)+c$ (unstarred, correct direction). |
| Lemma 6.2a, Thm 6.2 | OK. I checked $\ell_d<\log(d/\log3)\Rightarrow3^{2^{\ell_d}}<2^d$, and that fewer than $2^\ell$ programs have length $<\ell$. (ii): $L=2^{2^s}\ge2^{d+1}$, and the programs $rqu$ are prefix-free because $q$ fixes $L$. The final inequality $K_A+\log W_A\ge\log d-K(s)-c-4$ is right. |
| Rem 6.3 | OK given `sfi` Thm 5.1. I read it: it is for binary labels on $R(t_x)$, the case used here. The direct part ("no computable witnesses") is OK. |
| Prop 6.4(a),(b) | OK. (b) is valid under both readings of Solovay's $I$, because $I_{\rm prob}\le I_{\rm det}+c$. Factor 2: **m10**. |
| Prop 7.1, Prop 7.2(a),(b) | OK. The explicit law in 7.2(b) gives $\frac12$ and $\frac14$, which I re-derived by hand. Wording in §7.5: **m13**. |
| Prop 7.3, Prop 7.4 | OK. In 7.3(a) the inequality holds also when $A$ does not prove $\varphi$ but $A$ plus the data does (factor $\frac12$, one consistent label). Citation detail: **m17**. Attribution of the graded score: **m7**. |
| Lemma 8.0 (majority vote) | OK. Outer regularity gives a cylinder with $\Unif(\mathcal G\cap[u])>\frac34 2^{-\lvert u\rvert}$. The stage exists for every $\sigma\in Z$. The wrong set has measure $<\frac14 2^{-\lvert u\rvert}$. |
| Prop 8.1, 8.2 | OK. The total-variation algebra checks out ($\lvert y_na-x(a_n-a)\rvert\le\max$ of the two terms). |
| Prop 8.3(a)–(c) | OK. (b): to call the most probable class a strict extension, add one line: **m11**. |
| Prop 8.4 (Gold) | OK. This is the standard locking-sequence construction on an ascending chain and its union. |
| Prop 8.5 | (a) OK. (b): the nonstandard model is now fully specified and correct, but a hypothesis on $B$ is missing: **m5**. |
| Prop 8.6, 8.7 | OK. In 8.6(a), on $E_\infty$ the theory is consistent and contains a complete $X$, so equals it. In 8.7, the inseparability argument via strong representability and the diagonal lemma is correct; a separator for $T\supseteq\Q$ restricts to one for $\Q$. Remark (iii) after 8.7: **m14**. |
| Prop 9.1(ii),(iii) | OK given (i), as labelled. |
| Prop 10.1(a)–(c) | Mathematically OK; confirmed exactly on a finite stand-in by ra1 Part B. Framing and novelty: **M1**. Reference: **m12**. |
| Thm 11.1(a),(b) | OK. I re-derived the closed form and the zero cells. The per-pair bound (ratio $\ge1+p_{0\iota}$, since the cell masses sum to 1), $\log_2(1+v)\ge v$ on $[0,1]$, the $G_{ca}$ tapes in $E_{D_{i-1}}$, and Jensen with $\sum_{y_{<i}}M_A\le1$ all check. Wording: **m4**. Confirmed exactly by ra1 Part A. |
| Prop 11.2 | OK. The pairwise incompatibility of the $m^k$ conjunctions and the "within $2\lvert D\rvert+K(k,m)+c$" arithmetic both check. Wording: **m4**. |
| Thm 11.3 | OK under a well-order: **m3**. I checked loop steps (1)–(4) and the Kraft argument for $K_A(D)\ge m$. The summary's "$\le k+c$ Bayes mistakes" follows from Prop 5.3(a) with $T:=\mathsf W_{V(p)}$ for a shortest compatible $p$. That is a different route from the statement's $m+K(m)+c$; both are correct. |
| Prop 11.4(a)–(c) | OK. (a) uses the record's convention that "consistent" means consistent with $B$, so a random consistent theory holds at most one member of $S$. (c) holds given `sfi` T5. |
| Prop 11.5(a)–(c) | OK. In (b)(⇒), the image-measure argument needs no injectivity. The PA corollary at the end of §11.5 follows from (c), and the $O(\log)$ term can even be taken as $O(\log K_\equiv(\PA))$. |

---

## 3. Issues

### Fatal

None.

### Major

**M1. A missed antecedent: the modified Demski prior samples a universal machine's output on random bits. This bears on §1.8, §10 and §12.2.**

*Where:* §1.8 (row "theory machines, …, universal $G_U$ … new here"); §12.2 (rows "one-tape theory machines, $G_U$, … new", "Thm 4.1–Cor 4.5 … new for theories", "Prop 10.1 … new comparison"); §10, "What this says"; Prop 10.1(d).

*What the record says:* Demski's prior and $M_A$ differ "in what a hypothesis is (a program enumerating axioms, against a sequence of sentences)". Under Demski "an infinite theory enters only through infinitely many draws".

*What the literature says (web search, 2026-10-16, snippet level; WebFetch could not resolve any host).*
* The **modified Demski prior** (Fallenstein, Demski and Garrabrant, Intelligent Agent Foundations Forum / LessWrong posts, c. 2015) samples Turing machines instead of sentences: "fix a universal Turing machine, feed it random bits, and read its output as a sequence of sentences". Each sampled sequence is kept if it is consistent with the base theory and with what has been kept so far.
* The posts state:
  * that it "assigns positive probability to certain computable infinite sequences of sentences", with first-order PA and its schema as the prototypical example;
  * a dominance property: for every machine $M'$ there is $C>0$ with the prior's value on an output sequence at least $C$ times the probability that $M'$ outputs it.
* Garrabrant, Fallenstein, Demski and Soares, *Inductive Coherence* (arXiv:1604.05288, 2016), build their approximation scheme on this variant. They describe it as "a random complete, consistent extension … by sampling Turing machines from a simplicity prior and keeping only the claims that agree with what has been accepted so far".
* The literature scout's `refs.bib` has the Inductive Coherence entry but not this construction, and `notes.md` (scout L, §3.2, Obs. L2) does not mention it.

*Consequences:*
* (i) The sampling stage of $G_U$ (a universal machine on a random tape whose output is read as a set of sentences) is not new. Neither is "program-length credit for schemas" as such.
* (ii) §10's stated first difference fails against the modified prior, and so does Prop 10.1(d)'s remark.
* (iii) What remains distinctive, as far as the snippets show:
  * $M_A$ uses **one** draw, whereas the modified prior iterates draws until the theory is complete;
  * the random theory is therefore incomplete with positive probability, and $M_A$ keeps the independent outcome (a belief function of provability, not a probability of truth);
  * $M_A$ conditions by **proof-requiring** compatibility;
  * the learning theorems of §5–§8 and §11.
* (iv) Thm 4.1's dominance for $\nu_G$ is the standard mixture argument. The new part is the object it is applied to, the proof-requiring law of a single draw, not the dominance technique.

*Fix:*
* (a) Obtain a readable copy of the modified-prior definition. Candidates: the Inductive Coherence paper (arXiv:1604.05288, its section on the Demski prior), or a mirror of the forum post "Asymptotic logical uncertainty: a modification to the Demski prior". Record it in `refs.bib` with its verification level.
* (b) Rewrite §1.8 and §12.2 to read: "new: the single-draw proof-requiring law $M_A$, its trichotomy and the results about it; the universal-machine-on-random-tape sampling of sentences appears in the modified Demski prior".
* (c) Add to Prop 10.1:

  > (e) [proved] Under the modified prior the final theory is also complete with probability 1.

  The proof is that of (a): every single-sentence machine is drawn with positive probability at each step. ra1 Part B′ confirms this exactly on a finite stand-in. Then state the three remaining differences.
* (d) Replace §10's "they differ in what a hypothesis is" with "they differ in whether the random theory is completed, and in what is conditioned on".
* (e) Pass the finding to scout L and the synthesis. The related-work section must cite the modified prior next to Demski (2012).

*Sources:*
* [Asymptotic logical uncertainty: a modification to the Demski prior](https://www.lesswrong.com/posts/5bd75cc58225bf067037500a/asymptotic-logical-uncertainty-a-modification-to-the-demski-prior)
* [A problem with the modified Demski prior](https://alignmentforum.org/posts/5bd75cc58225bf0670375012/a-problem-with-the-modified-demski-prior)
* [Why the modified Demski prior is better than the original](https://www.alignmentforum.org/posts/5bd75cc58225bf0670375035/why-the-modified-demski-prior-is-better-than-the-original)
* [Further progress on a Bayesian version of logical uncertainty](https://alignmentforum.org/posts/5bd75cc58225bf067037553d/further-progress-on-a-bayesian-version-of-logical-uncertainty)
* [Inductive Coherence, arXiv:1604.05288](https://arxiv.org/abs/1604.05288v3)

### Minor

**m1. Prop 1.8(c): "all three are $\infty$ otherwise" is false.** $K(\psi_D)$ is finite for every $D$, consistent or not. *Fix:* "$K_A(D)=K_{\rm fin}(D)=\infty$ if $D$ is inconsistent".

**m2. A consistency hypothesis is missing for $T$** in Def 1.9 ("always $\mm_\equiv(T)\le\mm(\Ext T)$" and "$\Unif_A[T]\ge2^{-c}\mm_\equiv(T)$"), and in Thm 4.1(i) ("consequently $\Unif_A[T]\ge2^{-c}\mm_\equiv(T)\ge2^{-K_\equiv(T)-c}$").
* *Counterexample:* $T=\{\bot\}$. Then $\Unif_A[T]=0$ (the event requires consistency) and $\Ext T=\emptyset$, while $\mm_\equiv(T)\ge2^{-K_\equiv(T)}>0$.
* *Fix:* state "for $T$ with $B\cup T$ consistent" in Def 1.9 and Thm 4.1(i). Thm 5.1, Prop 8.2 and Prop 11.5 already assume it.

**m3. Thm 11.3: "Fix any total order $\prec$ on $\dom V$" is too weak.**
* The predictor needs a $\prec$-first compatible program, and $\pi(w)$ is defined as a $\prec$-first element. With a non-well-founded order of type $\mathbb Q$, neither need exist.
* *Fix:* "any well-order $\prec$ of $\dom V$". An order refining length, as in Prop 5.3(b), is one. The proof is unchanged.

**m4. "Distinct literals of a fresh predicate" must mean literals on pairwise distinct words.** This affects Thm 11.1(b), Prop 11.2(b), Prop 7.3(c),(d) and Thm 11.3.
* $R(t_w)$ and $\neg R(t_w)$ are distinct literals.
* *Counterexample (Thm 11.1(b)):* $c_1:=\neg a_1$ and $y_1=1$. Then $\beta_1=a_1\vee\neg a_1$ is valid, so every consistent theory decides it, and $p_{0\iota}=0$ at pair 1. The step "the $G_{ca}$ tapes … do not decide $c_i$ (L2)" fails there.
* *Fix:* say "atoms $R(t_w)$ for pairwise distinct words $w$", as NOTATION-draft §3.4 and Lemma 6.2a intend.

**m5. Prop 8.5(b) needs a hypothesis on $B$.** The proof uses $B=\emptyset$, which is the default, but the statement does not say so. If $\Q\subseteq\Cn(B)$, then $B\vdash\theta$ and $\lim\Bel_{D_n}(\theta)=1$. *Fix:* "for $B=\emptyset$, or any $B$ true in $\mathbb N$ and in the model $\mathbb N\sqcup\{a\}$ of the proof".

**m6. Q1's answer ("in general no", §8 and the §0 table) is stated as established, but its source is unrefereed.** It comes from scout N1's Thm E1 (the lottery), marked [proved; computed] there and not yet refereed. `logic` T1, to which it is attributed, has no record yet: `tracks/logic/` contains only its brief. *Fix:* "answered negatively by scout N1 Thm E1 (proved there, unrefereed); to be re-proved in `logic` T1".

**m7. Def 1.10: the graded weight is not exactly AI-paper $S_g$.**
* AI-paper Def 2.12 grades only the true-labelled data: $S_g=S_{\rm nc}\prod_{s\in D_+}g(\ell_T(s))$.
* $\nu^{1/2}_A$ multiplies over all of $\dom D$, grading false-labelled data through $\varphi^{D(\varphi)}$.
* Props 7.3 and 11.2 use only true-labelled data, so their results are unaffected.
* *Fix:* "the symmetric form of AI-paper $S_g$ (which grades only $D_+$)".

**m8. Prop 1.8(b) leaves out TF's standing assumptions on $t$.** TF Def 1.1 requires $t$ to be time-constructible, nondecreasing and superadditive with $t(m)\ge m$; TF Thm 2.2 adds $t\ge m^{a^*}$. The record states only "time-constructible $t\ge m^{a^*}$". *Fix:* add "nondecreasing and superadditive (TF Def 1.1)".

**m9. Some novelty claims are overstated; the literature scout's verdicts are more cautious.**
* §12.2 lists "Thm 3.2, Lemma 3.3 … new". Scout L's §5.3 verdict for this item (its F8) is "new application" of Solovay completeness.
* Lemma 3.3 is a known theorem. Demuth (1975): if $\alpha,\beta$ are left-c.e. and one of them is Martin-Löf random, then $\alpha+\beta$ is random. Downey, Hirschfeldt and Nies (2002) proved the converse. I verified this through secondary sources that cite both, e.g. arXiv 1604.05192 and arXiv 1605.05838.
* Thm 3.2(b) is the standard proof that $\Omega$ is Solovay complete, applied to a new event.
* Becher, Figueira, Grigorieff and Miller ("Randomness and halting probabilities", *JSL* 71(4):1411–1430, 2006) and Barmpalias, Cenzer and Porter ("Random numbers as probabilities of machine behaviour", *TCS* 673, 2017) study exactly this kind of real: the probability of a machine behaviour.
* Prop 8.7 likewise follows from the Jockusch–Soare fact that the PA degrees form a null class. Lemma 8.0 makes the proof self-contained, which is good, but the result is a new application, not a new theorem.
* *Fix:*
  * Lemma 3.3: "[known: Demuth 1975; proved here for completeness]";
  * Thm 3.2: "new application of the standard Solovay-completeness argument";
  * Prop 8.7: "new application";
  * cite BFGM 2006 and BCP 2017 as related work on halting-type probabilities.

**m10. Prop 6.4(b) and the F12 downgrade: the factor 2 can now be cited at abstract level.**
* Search-result abstracts confirm the following:
  * Vereshchagin (*IPL* 103(1):34–39, 2007) improves Solovay's constant 3 to 2 for finite sets.
  * Shekhovtsov and Zakharov ("Enumerating complexity revisited", arXiv:2312.04187, ECCC TR23-201) show that any bound for finite sets transfers to infinite sets "modulo logarithmic factors". Hence the constant 2 holds for every set.
* *Fix:* keep the factor-3 statement as the [proved, given Solovay] item. Add a remark: "$K_\equiv(T)\le2(-\log\mm_\equiv(T))+O(\log)$ [known, abstract-level: Vereshchagin 2007 + Shekhovtsov–Zakharov 2023; exact error term unverified]".
* The same applies to Prop 11.5(c), provided these papers use the probabilistic reading of $I$. Their abstracts say "a random program/randomized algorithm enumerates S", which supports it, but check before relying on it.

**m11. Prop 8.3(b): one line is missing for the heading's claim.**
* The proof shows that $[U]$ beats $[T_j]$. "The most probable class is a strict extension" also needs the maximum to exist.
* It does: only finitely many classes have limit probability above $\Unif_A[U]/\Unif_A(\Ext T_j)>0$. So a most probable class exists, lies in the extensions of $T_j$, and is not $[T_j]$.
* *Fix:* add this sentence.

**m12. Prop 10.1(c): undecidability with a single binary relation symbol is not Church 1936 alone.** It is Church's theorem combined with Kalmár's reduction ("Zurückführung des Entscheidungsproblems auf den Fall von Formeln mit einer einzigen, binären, Funktionsvariablen", *Compositio Math.* 4:137–144, 1936). *Fix:* cite both.

**m13. §7.5, item 3: "linearly many bits where PR pays $O(1)$" overgeneralises.** PR pays $O(1)$ only on streams decided by a simple consistent theory, as in the example of Prop 7.2(a). The Dempster lower bound is general. *Fix:* "on streams decided by a simple theory".

**m14. Remark (iii) after Prop 8.7 is stated without proof and has an interpretive "this is why".**
* The claim that "a theory plus a fair coin on every undecided sentence is not a theory-machine law above $\Q$" needs one line. A law with zero local defect at every sentence comes from a theory that is almost surely complete on the consistency event: apply Prop 2.1(b) at $D=\emptyset$ and take the countable union. Prop 8.7(a) then excludes it, provided the theory proves $\Q$.
* "This is why graded CR can exceed PR (Prop 11.2)" is interpretive. Prop 11.2's gap comes from the empty theory's grading.
* *Fix:* add the line and label the second sentence a remark.

**m15. Lemma 3.3's constant $c$ depends on $\alpha$, $\gamma$ and $k$**, through their approximating programs. The record's convention (line 14) says constants depend only on the fixed machines, the coding and $B$. The application has $\alpha=\Omega_V$, $k=\lvert p_\alpha\rvert$ and $\gamma=\gamma_\alpha$, all fixed by $V$, so nothing breaks. *Fix:* say so in the lemma.

**m16. Prop 1.8(d) has a sibling in scout N1 that should be credited.** Scout N1's result 3 ("there are at least $n$ things": $K_{\rm fin}=\min_{m\ge n}K(m)\pm c$ in monadic languages) is the same $K^{\rm pad}$ phenomenon. *Fix:* one clause crediting it, and coordination with `terms` T5 so that the paper states the separation once.

**m17. Small citation and terminology slips.**
* (a) Prop 7.3(a) cites P1 Prop 3.3 for the order-independent predictor, but P1 Prop 3.3 assumes $\nu(\emptyset)=1$, whereas $M_A^{1/2}(\emptyset)=1-\Inc_0$. Divide by $M^{1/2}_A(\emptyset)$.
* (b) Prop 2.1(b) calls $\nu_G$ "a semimeasure (P1 Def 3.2)", and Prop 7.3(a) calls $\nu^{1/2}$ "a weak semimeasure (P1 Def 3.2)". These are the same definition. The distinction the record means is containment functional (P1 Def 3.4) against merely weak. Use one word and cite Def 3.4 for the stronger property, which Prop 2.1(g) proves for $M_A$.
* (c) $\Bel_0$ is unnormalised, while $\Bel_\emptyset=\Bel_0/(1-\Inc_0)$. The proof of Thm 11.1 and Prop 7.2(b) use $\Bel_\emptyset$, harmlessly because ratios cancel. A distinct symbol (e.g. $\Bel_0$ against $\widehat\Bel_0$, which already exists) would prevent errors in the paper.
* (d) Thm 5.1: "$T\vdash\varphi_t^{b_t}$" should read "$B\cup T\vdash$".
* (e) Def 1.1's remark ("decidability only makes proof search from $B$ effective"): an r.e. $B$ already makes proof search effective. Decidability is a convenience, available without loss by Craig.

---

## 4. References I could verify (the record could not search)

Levels follow the project's convention. "Snippet" means search-result text only; WebFetch failed on every host (DNS).

| reference | what I verified | suggested level |
|---|---|---|
| Suppes–Zanotti 1977 (geometric rule) | Secondary sources state the rule $\mathrm{bel}(B\cap A)/\mathrm{bel}(A)$ and attribute it to Suppes and Zanotti (1977) as an alternative to Dempster's rule. Sources: [Cuzzolin, arXiv:2104.10651](https://arxiv.org/pdf/2104.10651); [Smets, "About updating", arXiv:1303.5752](https://arxiv.org/pdf/1303.5752). | known (secondary) |
| Demuth 1975; Downey–Hirschfeldt–Nies, *SIAM J. Comput.* 31:1169–1183, 2002 | Sum of left-c.e. reals is random iff at least one summand is random. Demuth proved the forward direction (= Lemma 3.3), DHN the converse. Sources: [arXiv:1604.05192](https://arxiv.org/pdf/1604.05192); [arXiv:1605.05838](https://arxiv.org/pdf/1605.05838); [DHN paper page](https://math.uchicago.edu/~drh/Papers/randomness.html). | known (secondary) |
| Vereshchagin 2007; Shekhovtsov–Zakharov 2023 | As in m10. Sources: [arXiv:2312.04187](https://arxiv.org/abs/2312.04187v2); [CWI record of Vereshchagin](https://ir.cwi.nl/pub/12114). | known (abstract) |
| Becher–Figueira–Grigorieff–Miller 2006 | *JSL* 71(4):1411–1430; studies the randomness of $\Omega_U[X]$. Source: [preprint](https://people.math.wisc.edu/~jsmiller8/Papers/randomnessAndHalting.pdf). | related work (abstract) |
| Barmpalias–Cenzer–Porter 2017 | *TCS* 673; probabilities of machine behaviours as random reals. Source: [arXiv:1605.05838](https://arxiv.org/pdf/1605.05838). | related work (abstract) |
| Kalmár 1936 | *Compositio Math.* 4:137–144; reduction of the decision problem to one binary predicate. Source: [JSL citation](https://unpaywall.org/10.2307%2F2267689). | known (bibliographic) |
| Modified Demski prior; Garrabrant et al. 2016 | As in M1. | snippet; must be read before the paper cites it |
| Gold 1967 | Text versus informant, and non-identifiability of classes with an infinite language from text, in secondary form. Theorem number not found. Source: [Wikipedia, "Language identification in the limit"](https://en.wikipedia.org/wiki/Language_identification_in_the_limit). | known in substance (unchanged) |

---

## 5. Verification log

**Restart check.** I looked for my own outputs in the folder before starting:
* `referee-A.md` did not exist.
* `referee_code/` held only referee B's `rb*` files, being written concurrently. I left them untouched.

I saved this file three times: a skeleton, a draft issue list, and the final report.

**Read in full:**
* the project brief `../../00-brief.md`;
* the thread brief `00-brief.md`;
* `notes.md` (all 743 lines; every proof re-derived, §2);
* NOTATION-draft §3.1–§3.4 and §4.1–§4.2;
* the literature scout's summary (§0), §3.7 and the novelty tables (§5.2–§5.3), plus grep checks of its notes and `refs.bib` for every reference the record cites;
* the saved outputs `c2_separations.out`, `c3_kolmogorov.out` and `c4_coloring.out`.

**Read in part, to check the cited statements and their hypotheses:**
* P1: Defs 3.1, 3.2, 3.4, 3.6; Props 3.3, 3.7, 3.16, 3.17; Thms 3.8, 3.12; Question 3.14; Prop A.7; Question A.8; Prop A.10; the label table in `main.aux` for 4.4–4.10, 5.1–5.4, 9.10, A.6.
* AI-paper: Defs 2.12, 6.2; Thm 6.3; Lemma 2.21; Props 2.18, 2.19, 2.22, B.8; its label table.
* TF: Defs 1.1, 1.2; Lemma 2.1; Thm 2.2.
* `sfi` Thm 5.1, Cor 5.2 and the transfer table.
* Scout N1: the lottery E1 and its result 3.

All cited numbers match the labels they name.

**Computation.** `referee_code/ra1_order_demski.py`, seed 20261016, exact rationals, run time about 1.5 s. Its output `ra1_order_demski.out` was produced by two runs with identical output (md5 `4e41a973…`).
* *Part A* (Thm 11.1). 600 random laws on the 15 consistent theory types over two atoms, half with every type positive. Normalised probabilities in both orders were computed from the definitions (entailment as inclusion of model sets), not from the closed form.
  * The closed form holds with error $0$.
  * The probability is strictly larger in order $(a\vee c,a)$ in all 525 laws with a positive numerator, and equal in all 75 with a zero numerator.
  * There are 0 violations of the per-pair bound "ratio $\ge1+p_{0\iota}$" used in Thm 11.1(b).
* *Part B* (Prop 10.1(a)). Demski's process on 3 atoms (all 256 sentences, full-support $\mu$), with the exact law of the final theory computed by recursion over model sets: mass $0$ on incomplete theories, and $\max\lvert P(\varphi)+P(\neg\varphi)-1\rvert=0$.
* *Part B′* (for M1).
  * The theory-drawing (modified-prior) form also ends complete with probability 1.
  * A single draw, the $M_A$ form, keeps independent mass $0.8674$ for an atom.

This is a finite stand-in. It illustrates the claims and does not check the universal statements.

**Web.** WebSearch: 16 queries, listed in §3 M1 and §4. WebFetch failed on every host tried (ECCC, CWI, greaterwrong: DNS).

**Not checked:**
* TF's assumption (S);
* the internals of `sfi` Thm 5.1 (only its statement and hypotheses, against their use in Rem 6.3 and Prop 11.4(c));
* scout N1's proof of E1;
* the full texts of Solovay 1977, Demski 2012 and the modified-prior posts.

The scripts `c1`–`c4` were not re-run; that is referee B's remit.

**Epistemic policy.** This record is mathematical, and I found no philosophical claim of the author's in it to assess, so there is no "Possible error in the author's view" note.

**Git.** No git command was run.
