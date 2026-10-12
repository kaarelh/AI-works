# Foundations track: definitions and basic theorems of Solomonoff function induction (final notes)

*Track "foundations" of the SFI project: brief items H1, H2, H7, invariance, and Hänni's later request on the Kolmogorov and universal-semimeasure versions. Read `../../00-brief.md` first.*

This is the revised version of `notes.md`, written after the referee report `referee.md` (second pass). It is self-contained: every result used is stated here, and every result marked **[proved]** is proved here. Results keep their `notes.md` numbers wherever they survived, so that the other tracks' references stay valid. New results have new numbers. §0.1 lists every referee item and what was done about it. `notes.md` is kept unchanged for the record.

Scripts: `checks/c1`–`c11` (this track; `c7` was written during an interrupted earlier revision and is now cited, `c8`–`c11` are new) and `referee_code/r1`–`r13` (the referee's). All are deterministic or seeded, run with `python3`, and save their output next to themselves (`*.out.txt`, `*_output.txt`).

**Status tags.** **[proved]**: full proof here. **[computed]**: checked by a script with saved output. **[known]**: published result with reference; **(unverified)** means I could not check it against the source (arxiv.org, journal sites and lesswrong.com do not resolve here; WebSearch gives snippets only). **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]** (kept with its counterexample). Hänni's statements are treated as hypotheses.

---

## 0. Summary

Section numbers point to the statements and proofs.

1. **Three notions of "function semimeasure" differ, and only one has the generative meaning Hänni intends** (§2).
   * The brief's one-point inequality $\nu(D)\ge\sum_y\nu(D+(x,y))$ defines a *weak* function semimeasure. With $\nu(\emptyset)=1$, weak semimeasures are exactly the order-independent online predictors (Prop 2.1a) **[proved]**. They need not come from any random function (Example 2.4) **[proved]**.
   * Laws of random partial functions are characterised by a Möbius condition (Prop 2.3) **[proved]**.
   * Function machines (one shared random tape, value at $x$ fixed by a finite prefix) give lower-semicomputable laws of random partial functions (Prop 2.6) **[proved]**. Every computable "filling-in" process gives a machine law (Remark 2.7) **[proved]**.
2. **Universality** (§3).
   * There is a universal function machine. Its law $M_F$ satisfies $M_F(D)=\sum_i\mathbf m(i)\nu_{T_i}(D)$ for $D\ne\emptyset$, so $M_F\ge2^{-K(\nu)}\nu$ for every machine law $\nu$ (Thm 3.2) **[proved]**. Machine laws include all lower-semicomputable product laws, partial computable functions, computable laws of random functions, and lower-semicomputable mixtures of these (Prop 3.3) **[proved]**.
   * A universal weak semimeasure $M^w$ exists (Thm 3.4) **[proved]**. It is **not** within a constant factor of $M_F$. The ratio $M^w/M_F$ is at most $2^{K(\mathrm{dom}\,D)+O(1)}$ and at least $2^{k\log_2(3/2)-K(k)-O(1)}$ on some data sets with $2k$ points (Thm 3.5) **[proved]**. On that family $K(\mathrm{dom}\,D)\le k\log_23+K(k)+O(1)$, so at least a fraction $\log(3/2)/\log3\approx0.37$ of the $K(\mathrm{dom}\,D)$ term is needed there. The constant $(2/3)^k$ in the construction is exact for every $k$ **[proved; computed: c9, r1]**.
   * Whether every lower-semicomputable law of a random partial function is dominated by $M_F$ is **[open]** (Problem 3.6).
3. **The program mixture, the Kolmogorov version, the product mixture and the per-query mixture** (§4).
   * Definitions: $W(D)=\sum_e\mathbf m(e)[\varphi_e\supseteq D]$ (deterministic programs), $K_F(D)$ (length of the shortest program consistent with $D$), $M_{\rm prod}$ (universal mixture of product laws on data sets), $M_{\rm pq}$ (the same mixture applied *per query*, Solomonoff's operator induction as secondary sources describe it).
   * $2^{-K_F}\le W\lesssim M_{\rm prod}\lesssim M_F\lesssim M^w\le2^{K(\mathrm{dom}\,D)+O(1)}2^{-K_F}$ (Thm 4.2) **[proved]**.
   * **No coding theorem for function programs** (Thm 4.7) **[proved]**. On some two-point data sets with binary labels and $n$-bit inputs, $K_F(D)\ge\log_2n-2$ while $-\log W(D)\le2+K(\lceil\log_2(n+1)\rceil)+O(1)$ and $-\log M_F(D)\le2+O(1)$. So $-\log W\ne K_F+O(1)$, and not even within a constant factor. The largest two-point gap between $K_F$ and $-\log M_F$ on $n$-bit inputs is $\log_2n\pm O(\log\log n)$ (Cor 4.8) **[proved]**. For binary labels the single shortest program pays at most $|D|+\log_2(|D|(n+2))+K(\lceil\log_2(n+2)\rceil,|D|)+O(1)$ (Prop 4.9, a covering argument) **[proved; computed: c8]**. This settles the open Problem 4.6(a) of `notes.md`, whose conjecture was correct.
   * **The program mixture loses only the cost of naming a padded tape length** (Prop 4.4) **[proved]**. For every machine law $\nu$ and every $L$, $W(D)\ge2^{-K(\nu)-\kappa(L)-O(1)}\nu^{(L)}(D)$, where $\nu^{(L)}$ counts only certificates within the first $L$ tape bits and $\kappa(L):=\min_{L'\ge L}K(L')$. For fair-coin labels on inputs of length at most $n$ this gives $W(D)\ge2^{-|D|-K(\lceil\log_2(n+1)\rceil)-O(1)}$, independent of $|D|$. This supersedes the hashing bound of `notes.md` (kept as Remark 4.4a). So $W$, $M_{\rm prod}$ and $M_F$ differ by unbounded amounts (Props 4.3, 4.5; one-point data: context Prop 5.4), but on the two-point and shared-coin witnesses only by $\kappa$-type amounts, which are at most $2\log_2(g+2)+O_g(1)$ for every computable, nondecreasing, unbounded $g$ (Prop 4.4(c)).
   * Witnesses for gaps larger than $K(k)+O(1)$ cannot be computable families (Remark 4.10) **[proved]**.
   * §4 ends with the comparison table that Hänni's later request asks for, and with what the gaps mean for prediction.
4. **Which object to call SFI** (§5). I recommend $M_F$. Its cumulative loss in the semimeasure convention is $-\log_2M_F(D_n)$, which depends only on the set $D_n$ (Prop 5.2) **[proved]**. The per-step normalised predictor has loss at most this, and for random partial functions it can depend on the order (Prop 5.3) **[proved; computed: c3]**; for $M_F$ itself this is **[open]**. For two-point data sets the exact condition for order independence is Prop 5.4 **[proved; computed: c10, r13]**. Lower bounds proved in the semimeasure convention do not transfer automatically to the normalised predictor; Prop 5.5 lists what does **[proved]**.
5. **Basic theorems** (§6).
   * (i) Dominance (H2), pathwise on every consistent input sequence, adversarial or not: $-\log M_F(D_n)\le-\log\nu(D_n)+K(\nu)$ for every machine law $\nu$ (Thm 6.1) **[proved]**. Corrections to H2 as stated: the label sequence must be consistent (randomness per input, not per query); for weak comparators an extra term is needed, which cannot be $O(1)$ and is at most $K(\mathrm{dom}\,D_n)+O(1)$.
   * (ii) Invariance under the universal machine and under computable injective re-encodings, with constant $K(\alpha,\beta)+O(1)$ (Thm 6.2) **[proved]**.
   * (iii) Coding-theorem bounds: $\max_TK(D|_T\mid T)-O(1)\le-\log M_F(D)\le\min\{K_F(D),\sum_{(x,y)\in D}K(y\mid x)\}+O(1)$ (Thm 6.3) **[proved]**. The "swap" data set of Example 6.4 has $K(D\mid\mathrm{dom}\,D)=O(1)$ but $-\log M_F(D)=n\pm O(1)$ **[proved; computed: c9]**.
   * (iv) Merging for computable random total functions and any input rule that sees only the past (Thm 6.5), and the mistake bound $K(\varphi)+O(1)$ (Cor 6.6) **[proved]**. Lower-semicomputable laws of random total functions are computable for every countable $Y$.
   * (v) H7. For deterministic labels and any input distribution, the averaged predictor has expected log and 0–1 risk at most $(K(\varphi)+O(1))/n$ (Thm 6.7(a)) **[proved]**. With fresh label noise, H7 is **refuted for random-function SFI** ($M_F$, $W$, $M_{\rm prod}$): a repeated input with another label gives infinite loss (Prop 6.8) **[proved; computed: c5]**. It **holds for the per-query mixture** $M_{\rm pq}$, with no stamps (Prop 6.9) **[proved; computed: c7, r7]**, for $M_F$ on time-stamped inputs, and for frozen noise (Thm 6.7(b,c)) **[proved]**. The expected risk of the posterior predictive itself need not decrease with $n$ (Prop 6.10) **[proved; computed: c11, r12]**; whether it is $O(K/n)$ is **[open]** (Remark 6.11).
6. **Other foundational points** (§7). Solomonoff's sequence induction is SFI on initial segments of $\mathbb N$, up to $O(1)$ (Prop 7.1) **[proved]**. A universal lower-semicomputable chronological semimeasure exists (proved here by trimming) and dominates SFI (Prop 7.2) **[proved]**. $M_F$ and its conditionals are not computable (Prop 7.3) **[proved]**.

### 0.1 Response to the referee

The referee found no fatal issues and four major ones. I agree with all four and fixed them. Each new argument below was re-derived before it was written down; where I differ from the referee's version I say so.

| item | what the referee said | what I did | where |
|---|---|---|---|
| M1 | Problem 4.6(a) can be settled; $K_F$ and $W$ differ unboundedly on two points | Agreed. Thm 4.7 (referee's Prop A). The upper bound of Cor A2 is sharpened from $K(n)+\log_2n$ to $\log_2n+O(\log\log n)$ by padding $n$ (Prop 4.9, Cor 4.8). The remark on non-computable witnesses is Remark 4.10, with an averaged explicit version of Thm 3.5(iii) added. Problem 4.6(a) and F17 now say "refuted, with rates". Answer to §2.2 rewritten with the three-way distinction | §4, Thm 4.7–Remark 4.10, Table 4.12; c8 |
| M2 | $W$ loses only $\kappa$ of a padded tape length; supersedes hashing | Agreed. Prop 4.4 is now the tape-length bound, with the fair-coin corollary and the growth lemma for $\kappa$. Hashing is kept as Remark 4.4a, because the steeper track cites it. Remarks after Props 4.3 and 4.5, Problem 4.6(b,c), Summary 3 and the H1(b) verdict updated | Prop 4.4, Remarks 4.3a, 4.5a; c9(a), r5 |
| M3 | Per-input versus per-query randomness; operator induction is the per-query mixture | Agreed. $M_{\rm pq}$ added to Def 4.1; F36 corrected; Prop 6.8 restated for random-function SFI; Prop 6.9 gives the per-query H7 bound; §6.6 says the resolvability bound needs stamps or per-query mixing; `c7` cited. I also agree with the referee (against the first pass) that F23 stands once its hypothesis is stated | Def 4.1, Props 6.8, 6.9, §6.6; c7, r7 |
| M4(a) | "necessary" overclaims | Now "cannot be replaced by $O(1)$; about 0.37 of $K(\mathrm{dom}\,D)$ is needed on some data" | Thm 6.1(c), Summary 5(i) |
| M4(b) | "and no better" | Now "and not up to a constant" | Answer to H1(a) |
| M4(c) | normalisation "lowers" and "makes order-dependent" | Now "does not increase; can make it order-dependent for random partial functions; open for $M_F$" | Summary 4, Prop 5.3 |
| M4(d) | hashing verdict in Summary 3 | Removed; replaced by Prop 4.4 and Prop 4.9 | Summary 3 |
| M4(e) | stated reason for the §2.2 gap | Rewritten: the reason applies to $K_F$, not to $W$ | Answer to §2.2 |
| m1 | Thm 6.5 parenthetical holds for every countable $Y$ | Agreed and proved | Thm 6.5, Lemma 6.5a |
| m2 | Example 6.4 is tight and was cited for the wrong conclusion | Agreed. Tightness added; §6.7 now cites the history track's chain and skipped strings | Ex 6.4, §6.7; c9(c), r8 |
| m3 | $(2/3)^k$ exact for every $k$ | Agreed and proved by an explicit law | Thm 3.5 remark; c9(b), r1 |
| m4 | integrability step in Thm 6.5 | Added | Thm 6.5 proof; c11(c) |
| m5 | "Ramsey" | Now "pigeonhole" | Summary, Prop 4.3 |
| m6 | one-point gap for $Y=\{0,1\}^*$ | Stated, citing context Prop 5.4(2), with the proof | Prop 4.3(b) |
| m7 | "machine laws weighted by $2^{-K}$" | Fixed | §6.7 |
| m8 | predictor reading needs $\nu(\emptyset)=1$ | Stated precisely as Prop 2.1a | Prop 2.1a |
| m9 | convention for repeated inputs | Stated in §1 and Prop 5.2 | §1, Prop 5.2 |
| m10 | stale labels "(iii)", "(iv)" | Replaced by theorem numbers | §6.3, §11 |
| m11 | Prop 7.2 rests on an unverified citation | Universal chronological semimeasure now proved here by trimming; history track's $M_H$ cited | Prop 7.2 |
| m12 | "changes losses by that much" | Now "can change losses by up to that much" | Thm 6.2 remark |
| m13 | per-input randomness is a choice | Said | Prop 3.3(a) remark |
| m14 | F23 needs its hypothesis | Added ("data from a function") | Thm 6.1(a), F23 |
| m15 | `c7` not referenced | Cited; docstring updated to the numbering here (no change to its output) | Prop 6.9, §11 |
| m16 | why $W$ uses input-independent self-delimitation | One paragraph added | Def 4.1 remark |
| m17 | bibliographic gaps | Filled from search snippets, marked accordingly | §11 |
| Q1 | lower bounds under the normalised convention | Prop 5.4 (two-point criterion), Prop 5.5 (what transfers), Remark 5.6 (which bounds in the tracks are semimeasure-only) | §5; c10, r13 |
| Q2 | comparison table | Table 4.12 | end of §4 |
| Q3 | what the gaps mean for prediction | Added | end of §4 |
| Q4 | last iterate | Prop 6.10 (a two-input example where the risk increases) and Remark 6.11 (identity with leave-one-out; bound open) | §6.5; c11, r12 |
| Q5 | uncited prior work | Added, marked unverified, with no claim resting on it | §6.6, §11 |
| Q6 | Problem 3.6 framing | Remark 2.7 and the reformulation in Problem 3.6 | §2, §3 |

---

## 1. Setting and notation

* **Inputs and outputs.** $X=Y=\{0,1\}^*$, identified with $\mathbb N$ by the length-lexicographic bijection $j$ when convenient ($j(x)\le2^{n+1}-2$ for $|x|\le n$). All results hold for any infinite decidable $X$ and any countable $Y$ with $|Y|\ge2$, unless a statement says otherwise. $\bot$ means "undefined", and $Y_\bot:=Y\cup\{\bot\}$.
* **Data.** A *data set* is a finite partial function $D$ from $X$ to $Y$, written as a finite set of pairs with distinct first coordinates. $\mathrm{dom}\,D$ is its domain. For $x\notin\mathrm{dom}\,D$, $D+(x,y):=D\cup\{(x,y)\}$. For $T\subseteq\mathrm{dom}\,D$, $D|_T$ is the restriction. A partial function $f$ *extends* $D$, written $f\supseteq D$, if $f(x)=y$ for all $(x,y)\in D$. A sequence $(x_t,y_t)_{t\le n}$ is *consistent* if $D_n:=\{(x_t,y_t):t\le n\}$ is a partial function (repeated inputs carry equal labels).
* **Repeated inputs (convention).** For a map $\nu$ on data sets, $x\in\mathrm{dom}\,D$ and $y\in Y$, the one-step conditional is $\nu(y\mid D,x):=1$ if $y=D(x)$ and $0$ otherwise. For $x\notin\mathrm{dom}\,D$ it is $\nu(D+(x,y))/\nu(D)$ (and $0$ if $\nu(D)=0$).
* **Complexity.** $V$ is a fixed universal prefix machine: $\mathrm{dom}\,V$ is prefix-free, and for every prefix machine $V'$ there is a string $r$ with $V(rs)=V'(s)$ for all $s$. $K(a)$ and $K(a\mid b)$ are prefix complexity and conditional prefix complexity. Finite sets and finite partial functions are encoded canonically (sorted lists). $\mathbf m(i):=\sum_{p:V(p)=i}2^{-|p|}$; trivially $\mathbf m(i)\ge2^{-K(i)}$. (`notes.md` wrote $m(i)$; the bold letter avoids a clash with other tracks' $m$.)
* **Coding theorem** **[known: L. A. Levin, "Laws of information conservation (nongrowth) and aspects of the foundation of probability theory", *Problems Inform. Transmission* 10(3):206–210, 1974; P. Gács, "On the symmetry of algorithmic information", *Soviet Math. Dokl.* 15:1477–1480, 1974; G. J. Chaitin, "A theory of program size formally identical to information theory", *J. ACM* 22(3):329–340, 1975; M. Li, P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., Springer 2008, §4.3. Bibliographic data confirmed by search snippets; contents and section number unverified]**. I use the conditional form: if $P(a\mid z)\ge0$ is lower semicomputable uniformly in $(a,z)$ and $\sum_aP(a\mid z)\le1$ for every $z$, then $K(a\mid z)\le-\log P(a\mid z)+K(P)+O(1)$. It relativises to any oracle (same references).
* **Complexity of a law.** For a class with an effective enumeration $(\nu_i)$ (machine laws, weak semimeasures, conditional semimeasures, chronological semimeasures), $K(\nu):=\min\{K(i):\nu_i=\nu\}$. Changing the enumeration changes $K(\nu)$ by at most an additive constant when each enumeration translates computably into the other.
* **Padded lengths.** $\kappa(N):=\min_{L\ge N}K(L)$. It is nondecreasing and unbounded, and $\kappa(N)\le K(N)$. (The history track uses the same symbol for the same function; the steeper track uses κ for a machine constant, see §9.)
* **Logs and losses.** $\log=\log_2$, $\ln$ is natural. Losses and KL divergences are in bits unless marked. $\lambda$ is the uniform (fair-coin) measure on $\{0,1\}^\infty$, and $[w]$ is the cylinder of sequences extending the finite string $w$. (The steeper track uses λ for its steepness exponent; see §9.)

---

## 2. Three notions of function semimeasure

**Definition 2.1 (weak function semimeasure).** A map $\nu$ from data sets to $[0,1]$ with $\nu(\emptyset)\le1$ and, for every $D$ and every $x\notin\mathrm{dom}\,D$,
$$\textstyle\nu(D)\ \ge\ \sum_{y\in Y}\nu(D+(x,y)).$$
This is the definition in the brief.

*Two consequences* **[proved]**. (a) Monotonicity: $\nu(D+(x,y))\le\nu(D)$. (b) For every finite $S\subseteq X$, $\sum_{D:\,\mathrm{dom}\,D=S}\nu(D)\le\nu(\emptyset)$. For (b), list $S=\{s_1,\dots,s_k\}$ and sum out $y_k$, then $y_{k-1}$, and so on, using the inequality at each step.

**Proposition 2.1a (predictor reading)** **[proved]**. Call a predictor $q$ (sub-probabilities $q(\cdot\mid D,x)$ on $Y$ for every data set $D$ and $x\notin\mathrm{dom}\,D$, with the convention of §1 at $x\in\mathrm{dom}\,D$) *order-independent* if for every $D$ the product of its conditionals along a reveal order of $D$ is the same for all orders; call that product $\nu_q(D)$.
* (a) If $\nu$ is a weak semimeasure with $\nu(\emptyset)=1$, then $q_\nu(y\mid D,x):=\nu(D+(x,y))/\nu(D)$ (and $0$ if $\nu(D)=0$) is order-independent, with $\nu_{q_\nu}=\nu$.
* (b) If $q$ is order-independent, then $\nu_q$ is a weak semimeasure with $\nu_q(\emptyset)=1$, and $q(y\mid D,x)=\nu_q(D+(x,y))/\nu_q(D)$ whenever $\nu_q(D)>0$.

So weak semimeasures with $\nu(\emptyset)=1$ correspond one-to-one to order-independent predictors, where two predictors are identified when they agree at every $(D,x)$ with $\nu(D)>0$. A weak semimeasure with $\nu(\emptyset)<1$ gives the same predictor as $\nu/\nu(\emptyset)$, and its telescoped product is $\nu(D)/\nu(\emptyset)$.

*Proof.* (a) Along any order the product of the conditionals telescopes to $\nu(D)/\nu(\emptyset)=\nu(D)$. If some intermediate $\nu(D_t)=0$, monotonicity gives $\nu(D)=0$ and the product is $0$ too. The sum of the conditionals is at most $1$ by the weak inequality. (b) The empty product is $1$. Enumerating $D$ first and then $x$ gives $\nu_q(D+(x,y))=\nu_q(D)\,q(y\mid D,x)$. Summing over $y$ gives the weak inequality, and dividing gives the formula for $q$. $\square$

(The context track states the same fact as its Prop 5.1(a).)

**Definition 2.2 (law of a random partial function).** A *random partial function* is a random element $F$ of $(Y_\bot)^X$ (product σ-algebra, $Y_\bot$ discrete) with law $P$. Its *containment functional* is $\nu_P(D):=P(F\supseteq D)$.

Every containment functional is a weak semimeasure, because the events $\{F\supseteq D+(x,y)\}$, $y\in Y$, are disjoint subsets of $\{F\supseteq D\}$.

**Proposition 2.3 (Möbius characterisation)** **[proved]**. Let $\nu$ be a weak semimeasure with $\nu(\emptyset)=1$. Then $\nu=\nu_P$ for some law $P$ of a random partial function if and only if, for every data set $D$ and every finite $T\subseteq X\setminus\mathrm{dom}\,D$,
$$\textstyle \Delta(D,T):=\sum_{E:\ \mathrm{dom}\,E\subseteq T}(-1)^{|E|}\,\nu(D\cup E)\ \ge\ 0 .$$
$P$ is then unique, and $\Delta(D,T)=P(F\supseteq D,\ F(t)=\bot\text{ for all }t\in T)$.

*Proof.* The series converges absolutely: by consequence (b) applied below $D$, $\sum_{E:\,\mathrm{dom}\,E\subseteq T}\nu(D\cup E)\le2^{|T|}\nu(D)$.

*Necessity.* For $t\in T$ let $A_t=\{F(t)\ne\bot\}$. By inclusion–exclusion, $P(F\supseteq D,\ \bigcap_tA_t^c)=\sum_{R\subseteq T}(-1)^{|R|}P(F\supseteq D,\ \bigcap_{t\in R}A_t)$, and $P(F\supseteq D,\bigcap_{t\in R}A_t)=\sum_{E:\,\mathrm{dom}\,E=R}\nu(D\cup E)$. Collecting terms gives $\Delta(D,T)$, which is therefore a probability and $\ge0$.

*Sufficiency.* For finite $S\subseteq X$ and $v\in(Y_\bot)^S$, let $v^{\rm def}$ be the partial function given by the defined entries of $v$ and $S_\bot(v)$ the set where $v=\bot$. Put $q_S(v):=\Delta(v^{\rm def},S_\bot(v))\ge0$. Consistency: for $x\notin S$, splitting the sum defining $q_{S\cup\{x\}}(v,\bot)$ according to whether $x\in\mathrm{dom}\,E$ gives $q_{S\cup\{x\}}(v,\bot)=q_S(v)-\sum_{a\in Y}q_{S\cup\{x\}}(v,a)$. (Rearranging is allowed by absolute convergence.) So $\sum_{a\in Y_\bot}q_{S\cup\{x\}}(v,a)=q_S(v)$, and $q_\emptyset=\nu(\emptyset)=1$. The $q_S$ are a consistent family of probability distributions on the countable sets $(Y_\bot)^S$. The Kolmogorov extension theorem gives a law $P$ on $(Y_\bot)^X$ with these marginals. Then $P(F\supseteq D)=q_{\mathrm{dom}\,D}(D)=\Delta(D,\emptyset)=\nu(D)$. Uniqueness: the cylinder probabilities $q_S$ are determined by $\nu$. $\square$

*Remark.* This is the function-space analogue of the correspondence between completely monotone set functions and random sets (Choquet; Matheron; in finite form, Shafer's belief functions) **[known as an analogy; not checked against the sources (unverified)]**. The weak condition is the case $|T|=1$ only.

**Example 2.4 (weak but not a random function)** **[proved; computed: c1, c6, r1, r4]**.
* *Two inputs.* $\nu(\emptyset)=\nu(\{(a,0)\})=\nu(\{(b,0)\})=1$, all other values $0$. Every one-point inequality holds. But $\Delta(\emptyset,\{a,b\})=1-1-1+0=-1<0$: "$F(a)=0$ surely and $F(b)=0$ surely, but never both" is not the law of any random function.
* *Three inputs, $\tau$.* Inputs $a,b,c$, labels $\{0,1\}$. $\tau(\emptyset)=1$; $\tau(\{(x,y)\})=\tfrac12$ for all six singletons; $\tau(E_1)=\tau(E_2)=\tau(E_3)=\tfrac12$ for $E_1=\{(a,0),(b,1)\}$, $E_2=\{(b,0),(c,1)\}$, $E_3=\{(c,0),(a,1)\}$; all other values $0$. All 27 one-point inequalities hold (c1). $E_1,E_2,E_3$ are pairwise inconsistent, yet $\sum_i\tau(E_i)=\tfrac32>1$. For any random partial function the events $\{F\supseteq E_i\}$ are disjoint, so $\sum_iP(F\supseteq E_i)\le1$. Hence no law $P$ satisfies $P(F\supseteq D)\ge c\,\tau(D)$ for all $D$ with $c>\tfrac23$. The value $c=\tfrac23$ is attained: the uniform law on the three total functions $(F(a),F(b),F(c))=(0,1,0),(1,0,1),(1,0,0)$ gives probability $\tfrac13$ to each $E_i$ and to the singletons $(a,0),(b,1),(c,1)$, and $\tfrac23$ to the other three singletons, so it is at least $\tfrac23\tau$ everywhere (c9(b) checks all ten data sets of the support of $\tau$).

**Definition 2.5 (function machine).** A *function machine* is a computably enumerable set $T\subseteq X\times\{0,1\}^*\times Y$ of triples that is *consistent*: if $(x,w,y),(x,w',y')\in T$ and $w,w'$ are comparable (one a prefix of the other), then $y=y'$. For $\omega\in\{0,1\}^\infty$ put $f^T_\omega(x):=y$ if some prefix $w$ of $\omega$ has $(x,w,y)\in T$, and $f^T_\omega(x):=\bot$ otherwise; consistency makes this well defined. The *machine law* of $T$ is the law of $f^T_\omega$ under $\omega\sim\lambda$:
$$\nu_T(D):=\lambda\{\omega:\ f^T_\omega\supseteq D\}.$$
This formalises "the value at $x$ depends on a finite prefix of a random tape $\omega$ that is shared by all inputs". Equivalently (by the standard uniform conversion, which the history track's §1.2 also uses), it is a Turing machine with a one-way read-only random tape, which on query $x$ reads finitely many tape bits and halts with a label or diverges; all queries read the same tape.

**Proposition 2.6** **[proved]**. Every machine law is the containment functional of a random partial function, with $\nu_T(\emptyset)=1$, and $D\mapsto\nu_T(D)$ is lower semicomputable uniformly in $D$ and in an index of $T$.

*Proof.* $f^T_\omega$ is a measurable function of $\omega$ into $(Y_\bot)^X$, since each coordinate is determined by countably many cylinders. $\{\omega:f_\omega(x)=y\}=\bigcup_{(x,w,y)\in T}[w]$ is an effectively open set, uniformly in $(x,y)$. A finite intersection of effectively open sets is effectively open uniformly, and the measure of an effectively open set is lower semicomputable uniformly in its description. $\square$

*Effective enumeration of function machines* **[proved]**. Let $(W_i)$ enumerate all c.e. sets of triples. Let $T_i$ be obtained by enumerating $W_i$ and adding each triple unless it conflicts with a triple already added. Each $T_i$ is consistent, and $T_i=W_i$ whenever $W_i$ is consistent. So $(T_i)$ lists all function machines (and only them), and $K(\nu)$ for machine laws is defined from this list.

**Remark 2.7 (computable filling-in processes give machine laws)** **[proved]**. A *computable filling-in process* is a Markov chain $F_0=\emptyset\subseteq F_1\subseteq F_2\subseteq\cdots$ of finite partial functions whose transition kernel $\Pr[F_{t+1}=g\mid F_t=f]$ is supported on finitely many extensions $g\supseteq f$, given as an explicit list with rational probabilities computable from $(t,f)$. Its limit $F_\infty:=\bigcup_tF_t$ is a random partial function. *Claim:* the law of $F_\infty$ is a machine law, with an index computable from the kernel.

*Proof.* The machine reads the tape as a sequence of bits and samples $F_1,F_2,\dots$ in turn: to sample from a finitely supported law with rational probabilities, it reads bits until the dyadic interval named by the bits read so far lies inside one of the consecutive half-open intervals of lengths equal to those probabilities, and takes that outcome. This fails to terminate only when the tape's real is an endpoint, a λ-null set. On query $x$ the machine runs the process until the first $t$ with $x\in\mathrm{dom}\,F_t$ and outputs $F_t(x)$; it diverges if there is none. So $T$ contains $(x,w,y)$ when the process, run on the bits of $w$, produces $F_1,\dots,F_t$ with $t$ the first index having $x\in\mathrm{dom}\,F_t$, and $F_t(x)=y$. The process reads its bits in order, so on comparable strings $w\sqsubseteq w'$ it produces the same initial segment of the chain; with $F_t\subseteq F_{t+1}$ this makes the triples consistent. Off the null set the sampled sequence has the law of the process, and $f_\omega=F_\infty$. $\square$

Conversely, every machine law is the law of $F_\infty$ for $F_t:=$ "the part of $f_\omega$ certified by triples enumerated within $t$ steps with $|w|\le t$", which is nested and depends on $\omega_{1:t}$; but this $(F_t)$ is Markov only in $\omega_{1:t}$, not in $F_t$. So machine laws are exactly the limits of computable nested processes driven by a hidden finite state. This is a restatement of Def 2.5. Its use is in the reformulation of Problem 3.6 below.

---

## 3. Universality

**Lemma 3.1 (realising a lower-semicomputable tree semimeasure)** **[known: A. K. Zvonkin, L. A. Levin, "The complexity of finite objects and the development of the concepts of information and randomness by means of the theory of algorithms", *Russian Math. Surveys* 25(6):83–124, 1970, for binary sequences (unverified); proof given here for countable alphabets, so: proved; construction computed: r2]**. Let $A$ be a countable alphabet with a fixed enumeration and $\mu$ a lower-semicomputable semimeasure on $A^*$: $\mu(\varepsilon)\le1$ and $\mu(s)\ge\sum_{a\in A}\mu(sa)$. There is a c.e. family of finite unions of dyadic intervals $I(s)=\bigcup_tI_t(s)\subseteq[0,1)$, computable from an index of $\mu$, with $I(sa)\subseteq I(s)$, $I(sa)\cap I(sb)=\emptyset$ for $a\ne b$, and $\lambda(I(s))=\mu(s)$ for every $s$. Consequently the map $\omega\mapsto$ "the longest $s$ with $\omega\in I(s)$" (reading $\omega$ as a binary real) is a monotone machine whose output extends $s$ with probability exactly $\mu(s)$, and the event "output extends $s$" is certified by a finite prefix of $\omega$.

*Proof.* Let $\mu_t$ be computable dyadic lower approximations, nondecreasing in $t$, with $\mu_t\to\mu$, and $\mu_t(s)=0$ unless $|s|\le t$ and $s$ uses only the first $t$ letters (round a rational approximation down to a multiple of $2^{-t}$; this preserves monotonicity in $t$). On this finite tree define $\mu'_t$ from the leaves up: $\mu'_t(s):=\max\{\mu_t(s),\ \sum_a\mu'_t(sa)\}$.
* $\mu'_t\le\mu$, by induction from the leaves: $\sum_a\mu'_t(sa)\le\sum_a\mu(sa)\le\mu(s)$.
* $\mu'_t$ is nondecreasing in $t$ (the tree grows and the inputs grow), $\mu'_t\ge\mu_t\to\mu$, so $\mu'_t\to\mu$.
* $\mu'_t(s)\ge\sum_a\mu'_t(sa)$, and $\mu'_t(\varepsilon)\le\mu(\varepsilon)\le1$.

Build $I_t$ top-down. $I_t(\varepsilon):=[0,\mu'_t(\varepsilon))$. Given $I_{t}(s)\supseteq I_{t-1}(s)$ of measure $\mu'_t(s)$, the room $I_t(s)\setminus\bigcup_aI_{t-1}(sa)$ has measure $\mu'_t(s)-\sum_a\mu'_{t-1}(sa)\ge\sum_a(\mu'_t(sa)-\mu'_{t-1}(sa))$, so we can add to each $I_{t-1}(sa)$ a disjoint dyadic piece of measure $\mu'_t(sa)-\mu'_{t-1}(sa)$ inside the room. All invariants are preserved, and $\lambda(I(s))=\lim_t\mu'_t(s)=\mu(s)$. Since each $I_t(s)$ is a finite union of dyadic intervals, $\omega\in I(s)$ is witnessed by a finite prefix. $\square$

**Theorem 3.2 (universal function machine)** **[proved]**. Define
$$T_U:=\{(x,\ pw,\ y):\ p\in\mathrm{dom}\,V,\ (x,w,y)\in T_{V(p)}\}.$$
$T_U$ is a function machine. Its law $M_F:=\nu_{T_U}$ satisfies $M_F(\emptyset)=1$ and, for every data set $D\ne\emptyset$,
$$\textstyle M_F(D)=\sum_i \mathbf m(i)\,\nu_{T_i}(D),\qquad\text{hence}\qquad M_F(D)\ \ge\ 2^{-K(\nu)}\,\nu(D)\ \text{ for every machine law }\nu .$$

*Proof.* $T_U$ is c.e. Consistency: if $(x,pw,y),(x,p'w',y')\in T_U$ with $pw,p'w'$ comparable, then $p,p'$ are comparable elements of the prefix-free set $\mathrm{dom}\,V$, so $p=p'$; then $w,w'$ are comparable triples of the same consistent $T_{V(p)}$, so $y=y'$. For $\omega=p\omega'$ with $p\in\mathrm{dom}\,V$ we get $f^{T_U}_\omega=f^{T_{V(p)}}_{\omega'}$, and $\omega'$ is uniform and independent of $p$. If $\omega$ has no prefix in $\mathrm{dom}\,V$, $f_\omega$ is the empty function, which extends only $\emptyset$. Summing over $p$ gives the formula, and $\mathbf m(i)\ge2^{-K(i)}$ gives the bound. $\square$

*Remark.* The formula is a Bayes mixture: $M_F$ is the prior predictive of "pick a machine $i$ with probability $\mathbf m(i)$, then a random tape". The posterior over $i$ after $D$ is $\mathbf m(i)\nu_{T_i}(D)/M_F(D)$.

**Proposition 3.3 (what machine laws include)** **[proved]**.
* (a) *Product laws (Hänni's x-only samplers).* Let $P(y\mid x)$ be lower semicomputable with $\sum_yP(y\mid x)\le1$ for every $x$ (a *conditional semimeasure*). Then $\nu_P(D):=\prod_{(x,y)\in D}P(y\mid x)$ is a machine law with $K(\nu_P)\le K(P)+O(1)$. Probabilistic machines that read $x$ and output $y$ (halting or not) define exactly the lower-semicomputable conditional semimeasures.
* (b) *Deterministic programs.* For a partial computable $\varphi$, $D\mapsto[\varphi\supseteq D]$ is a machine law with $K\le K(\varphi)+O(1)$ (index of $\varphi$).
* (c) *Computable laws.* Let $P$ be the law of a random partial function whose cylinder probabilities $q_S(v)=P(F|_S=v)$, $v\in(Y_\bot)^S$, are computable uniformly in $(S,v)$. Then $\nu_P$ is a machine law (exactly). If $Y$ is finite, it suffices that $\nu_P(D)$ is computable uniformly in $D$, since then each $q_S(v)=\Delta(v^{\rm def},S_\bot(v))$ is a finite alternating sum. For a random *total* function and any countable $Y$, it suffices that $\nu_P$ is computable, since then $q_S(v)=\nu_P(v)$ for $v$ without $\bot$ and $q_S(v)=0$ otherwise.
* (d) *Mixtures.* If $(\nu_i)$ are machine laws given by a computable sequence of indices and $w$ is a lower-semicomputable discrete semimeasure, then $D\mapsto\sum_iw_i\nu_i(D)$ ($D\neq\emptyset$) is a machine law.

*Proof.* (a) Apply Lemma 3.1 with alphabet $Y$ and depth one to $P(\cdot\mid x)$, uniformly in $x$: this gives c.e. disjoint dyadic sets $G_{x,y}$ with $\lambda(G_{x,y})=P(y\mid x)$. Fix a computable bijection $\langle\cdot,\cdot\rangle:\mathbb N^2\to\mathbb N$. The private stream of $x$ is $\omega^{(x)}_i:=\omega_{\langle j(x),i\rangle}$. Let $T$ contain $(x,w,y)$ whenever $w$ is long enough to contain the first $L$ bits of $\omega^{(x)}$ and these bits form a string $u$ with $[u]\subseteq G_{x,y}$. $T$ is c.e. and consistent. For distinct inputs the streams use disjoint coordinates of $\omega$, so they are independent and uniform, and $\nu_T(D)=\prod_{(x,y)\in D}\lambda(G_{x,y})=\nu_P(D)$. The samplers claim: a probabilistic machine's output probabilities are lower semicomputable (enumerate halting computations); the converse is the construction just given. (b) $T=\{(x,\varepsilon,\varphi(x))\}$. (c) Enumerate $X$ as $x_1,x_2,\dots$ and fix an enumeration of $Y_\bot$ with $\bot$ last. Build nested partitions of $[0,1)$: the interval $J(v)$ of $v\in(Y_\bot)^k$ is split, left to right, into the intervals $J(va)$ of lengths $q_{k+1}(va)$, $a\in Y$ in order, then $J(v\bot)$. Each left endpoint is $\mathrm{left}(v)+\sum_{a'<a}q(va')$, and the left endpoint of $J(v\bot)$ is $\mathrm{left}(v)+q_k(v)-q_{k+1}(v\bot)$; all are computable reals. Let $T$ contain $(x_k,w,y)$ when the dyadic interval of $w$ is certified (by rational approximations of the endpoints) to lie inside the interior of some $J(v)$ with $v\in(Y_\bot)^k$, $v_k=y\ne\bot$. Intervals at one level are disjoint and levels are nested, so $T$ is consistent. Boundary points form a null set, so $\lambda\{f_\omega(x_i)=v_i,\ i\le k\}=\lambda(J(v))=q_k(v)$ for every $v$, and the law of $f_\omega$ is $P$. The two "it suffices" claims are the formulas stated. (d) Realise $w$ by Lemma 3.1 (depth one, alphabet $\mathbb N$). The construction enumerates pairwise disjoint dyadic cylinders $[u]$, each labelled by some $i$, and the cylinders labelled $i$ have total measure $w_i$. Disjointness makes the set of enumerated strings $u$ prefix-free. Let $T:=\{(x,uw',y):\ [u]\text{ enumerated with label }i,\ (x,w',y)\in T_i\}$. As in Theorem 3.2, $T$ is consistent, the tape after $u$ is uniform and independent of $u$, and $\nu_T(D)=\sum_iw_i\nu_{T_i}(D)$ for $D\ne\emptyset$. Tapes outside all enumerated cylinders give the empty function. $\square$

*Remark (per input, not per query).* (a) gives each *input* its own private stream, so a repeated query of the same input returns the same label. A probabilistic machine run afresh at each *query* would draw new randomness each time. The per-input reading is a choice; it is the right one for data from a function (Hänni's setting: "input-output pairs from a function $f:X\to Y$"), and it is what makes $\nu_P$ a law of a random function. The per-query reading gives a different object, $M_{\rm pq}$ (Def 4.1, Prop 6.9).

**Theorem 3.4 (universal weak semimeasure)** **[proved; trimming computed: r3]**. There is a lower-semicomputable weak semimeasure $M^w$ such that $M^w\ge2^{-K(\nu)}\nu$ for every lower-semicomputable weak semimeasure $\nu$.

*Proof.* Let $\phi_i$ enumerate all lower-semicomputable maps from data sets to $[0,1]$, with approximations $\phi_{i,t}$. At stage $t$ use the finite universe $U_t$ of data sets whose inputs and labels are among the first $t$ inputs and labels. Define $\phi'_{i,t}$ on $U_t$ (and $0$ outside) by decreasing $|\mathrm{dom}\,D|$:
$$\textstyle\phi'_{i,t}(D):=\max\Big\{\phi_{i,t}(D),\ \max_{x\le t,\ x\notin\mathrm{dom}\,D}\ \sum_{y\le t}\phi'_{i,t}(D+(x,y))\Big\}.$$
If $\phi'_{i,t}(\emptyset)>1$, freeze ($\phi'_{i,s}:=\phi'_{i,t-1}$ for $s\ge t$). Then $\phi'_{i,t}$ is nondecreasing in $t$ and satisfies the weak inequality everywhere (inside $U_t$ by construction; outside, both sides vanish; a frozen $\phi'_{i,t-1}$ is weak for the same reason). Its limit $\nu_i$ is a weak semimeasure: for $x\notin\mathrm{dom}\,D$, $\sum_y\nu_i(D+(x,y))=\lim_t\sum_{y\le t}\phi'_{i,t}(D+(x,y))\le\lim_t\phi'_{i,t}(D)=\nu_i(D)$ by monotone convergence. If $\phi_i$ is already a weak semimeasure, induction from the largest domains shows $\phi'_{i,t}\le\phi_i$, so there is no freezing, and $\phi_{i,t}\le\phi'_{i,t}\le\phi_i$ gives $\nu_i=\phi_i$. Put $M^w:=\sum_i\mathbf m(i)\nu_i$. The weak inequalities are linear and $\sum_i\mathbf m(i)\le1$, so $M^w$ is a lower-semicomputable weak semimeasure dominating each $\nu_i$ with factor $\mathbf m(i)\ge2^{-K(i)}$. $\square$

**Theorem 3.5 (weak versus machine universality)** **[proved; computed: c1, c6, c9, r1]**.
* (i) $M_F\le2^{O(1)}M^w$.
* (ii) For every lower-semicomputable weak semimeasure $\nu$ and every data set $D$: $M_F(D)\ge2^{-K(\nu)-K(\mathrm{dom}\,D)-O(1)}\,\nu(D)$. In particular $M^w(D)\le2^{K(\mathrm{dom}\,D)+O(1)}M_F(D)$.
* (iii) The factor in (ii) cannot be replaced by a constant: for every $k$ there is a data set $D_k$ with $|\mathrm{dom}\,D_k|=2k$ and
$$\log\frac{M^w(D_k)}{M_F(D_k)}\ \ge\ k\log\tfrac32-K(k)-O(1).$$
* (iv) *Averaged explicit version.* For the $3^k$ explicit data sets $E_{\vec\imath}$ of the proof of (iii), $\frac1{3^k}\sum_{\vec\imath}\log\frac{M^w(E_{\vec\imath})}{M_F(E_{\vec\imath})}\ge k\log\tfrac32-K(k)-O(1)$.

*Proof.* (i) $M_F$ is a lower-semicomputable weak semimeasure (Prop 2.6), so Theorem 3.4 applies.

(ii) Fix $S=\{s_1<\dots<s_k\}$ and define the semimeasure $\mu_S$ on $Y^*$ by $\mu_S(y_1\dots y_j):=\nu(\{(s_1,y_1),\dots,(s_j,y_j)\})$ for $j\le k$, and $0$ for $j>k$. The weak inequality for $\nu$ is exactly the semimeasure inequality for $\mu_S$, and $\mu_S$ is lower semicomputable uniformly in $(\nu,S)$. Lemma 3.1 realises $\mu_S$ by a monotone machine. Let $T_{\nu,S}$ answer input $s_j$ with the $j$-th symbol of that machine's output (and be undefined off $S$). It is a function machine with index computable from $(\nu,S)$, and for $\mathrm{dom}\,D=S$ we get $\nu_{T_{\nu,S}}(D)=\mu_S(y_{s_1}\dots y_{s_k})=\nu(D)$. (For proper subsets of $S$ we only get $\le$; c6 checks both facts on examples.) Theorem 3.2 gives $M_F(D)\ge2^{-K(\nu,S)}\nu(D)$, and $K(\nu,S)\le K(\nu)+K(S)+O(1)$.

(iii) Use $\tau$ from Example 2.4 on blocks $B_j=\{3j,3j+1,3j+2\}$, $j<k$ (inputs as natural numbers). Let $\tau^{\otimes k}(D):=\prod_{j<k}\tau(D|_{B_j})$ if $\mathrm{dom}\,D\subseteq\bigcup_{j<k}B_j$ and $0$ otherwise. A one-point inequality at $x\in B_j$ involves only the $j$-th factor; at $x$ outside the blocks both sides are $0$. So $\tau^{\otimes k}$ is weak (c1 checks $k=2$ exhaustively, r1 also $k=3$). $\rho:=\sum_k\mathbf m(k)\tau^{\otimes k}$ is a lower-semicomputable weak semimeasure, so $M^w\ge2^{-O(1)}\rho$. For $\vec\imath\in\{1,2,3\}^k$ let $E_{\vec\imath}:=\bigcup_jE^{(j)}_{i_j}$ (the copy of $E_{i_j}$ in block $j$). These $3^k$ data sets are pairwise inconsistent and each has $\tau^{\otimes k}(E_{\vec\imath})=2^{-k}$. $M_F$ is the law of a random partial function, so $\sum_{\vec\imath}M_F(E_{\vec\imath})\le1$ and some $D_k:=E_{\vec\imath}$ has $M_F(D_k)\le3^{-k}$. But $M^w(D_k)\ge2^{-O(1)}\mathbf m(k)2^{-k}\ge2^{-K(k)-k-O(1)}$.

(iv) Each $-\log M^w(E_{\vec\imath})\le k+K(k)+O(1)$ as in (iii). By concavity of $\log$, $\frac1{3^k}\sum_{\vec\imath}-\log M_F(E_{\vec\imath})\ge-\log\big(\frac1{3^k}\sum_{\vec\imath}M_F(E_{\vec\imath})\big)\ge k\log3$. Subtract. $\square$

*How tight is (iii)?* The proof shows that every random partial function law $P$ has $\min_{\vec\imath}P(F\supseteq E_{\vec\imath})/\tau^{\otimes k}(E_{\vec\imath})\le(2/3)^k$. This is exact for every $k$ **[proved; computed: c9(b) for $k\le4$, r1]**: let $P_1$ be the uniform law on the three total functions $(0,1,0),(1,0,1),(1,0,0)$ on $(a,b,c)$. It gives probability $\tfrac13$ to each $E_i$ and to each of the singletons $(a,0),(b,1),(c,1)$, and $\tfrac23$ to the other three singletons, so $P_1\ge\tfrac23\tau$. Its $k$-fold product over independent blocks gives $P_1^{\otimes k}(F\supseteq D)=\prod_jP_1(F|_{B_j}\supseteq D|_{B_j})\ge(2/3)^k\tau^{\otimes k}(D)$, with equality on the $E_{\vec\imath}$. (`notes.md` reported this only for $k\le3$, from a linear program; the LP is now redundant.) In terms of complexity, $K(\mathrm{dom}\,D_k)\le k\log3+K(k)+O(1)$, because $\mathrm{dom}\,E_{\vec\imath}$ is determined by $\vec\imath$ and $k$. So on this family the gap $k\log(3/2)$ is asymptotically at least a fraction $\log(3/2)/\log3\approx0.369$ of the upper bound $K(\mathrm{dom}\,D_k)$. Gaps closer to $K(\mathrm{dom}\,D)$ may be possible with larger label sets (constraint systems whose "local" assignments are far from globally consistent); I have not worked this out.

*Explicitness.* The family $(E_{\vec\imath})$ is explicit and (iv) holds on average over it. Which member realises the gap of (iii) is not determined effectively, and cannot be: by Remark 4.10, along any computable family $k\mapsto D_k$ all five quantities of §4 agree up to $K(k)+O(1)$, while the gap in (iii) eventually exceeds $K(k)$.

**Problem 3.6 (open)**. Is every lower-semicomputable containment functional of a random partial function (Definition 2.2 with $\nu_P$ lower semicomputable) dominated by $M_F$ up to a multiplicative constant? Equivalently: is the class of such laws, up to constants, the class of machine laws? What is known:
* yes for machine laws (by definition), for lower-semicomputable product laws, for partial computable functions, for computable laws (computable cylinder probabilities; computable $\nu$ if $Y$ is finite or the function is total), for limits of computable filling-in processes (Remark 2.7), and for lower-semicomputable mixtures of these (Prop 3.3);
* up to $2^{K(\mathrm{dom}\,D)+O(1)}$ for all of them (Thm 3.5(ii), since every containment functional is weak).
* *The obstacle, reformulated* **[proof sketch]**. A machine law comes with approximations that are related by filling in: the part of $f_\omega$ certified by stage $t$ grows with $t$ (Remark 2.7). Conversely, suppose a lower-semicomputable $\nu_P$ has approximations $\nu_{P_t}\uparrow\nu_P$, where each $P_t$ is a law of a random partial function on a finite domain with finitely many labels and rational probabilities, computable from $t$, and consecutive laws admit a coupling with $F_t\subseteq F_{t+1}$. The couplings form a polytope given by rational linear constraints, so a rational one can be found by search, and Remark 2.7 then realises $\nu_P$ exactly. By Strassen's theorem for finite partially ordered sets **[known: V. Strassen, "The existence of probability measures with given marginals", *Ann. Math. Statist.* 36:423–439, 1965 (unverified)]**, such a coupling exists if and only if $P_t(U)\le P_{t+1}(U)$ for every up-set $U$ of the extension order. The containment events $\{F\supseteq D\}$ are only the *principal* up-sets, so $\nu_{P_t}\le\nu_{P_{t+1}}$ does not give it. The question is whether every lower-semicomputable $\nu_P$ admits, at a constant-factor loss, approximations that increase on all up-sets. (Not written out: the Strassen step is quoted, and the reduction from general lower approximations of $\nu_P$ to finite rational laws $P_t$ is not carried out.)
* `notes.md` also records a failed adversary argument: an adversary that forces repeated couplings on fresh blocks (in the spirit of Example 2.4) loses its own mass geometrically in the conditional version, and the machine survives the unconditional version with a constant reserve. Neither direction is settled.

**Answer to H1(a).** The universal element exists in both senses, but the two senses differ. In the weak sense (the brief's inequality) the universal semimeasure $M^w$ exists (Thm 3.4). In the machine sense (random function, shared randomness) the universal law $M_F$ exists (Thm 3.2). They agree up to $2^{K(\mathrm{dom}\,D)+O(1)}$, and not up to a constant (Thm 3.5). A Levin-style equivalence between "lower-semicomputable function semimeasures" and "machine laws" holds only after restricting the former to random-function laws, and even then only the inclusions in Prop 3.3 and Remark 2.7 are established. So the brief's "or equivalently monotone function machines" is **[refuted]** for the weak definition and **[open]** for random-function laws.

---

## 4. Program mixture, Kolmogorov version, product mixture, per-query mixture

**Definition 4.1.** Let $\varphi_e$ be the $e$-th partial computable function $X\rightharpoonup Y$, and let $(P_i)$ enumerate all lower-semicomputable conditional semimeasures (enumerable by the trimming of Thm 3.4 applied to each $x$ separately).
* *Deterministic program mixture* (Hänni's informal definition: "the usual prior on all programs ... picking a random program from this prior and generating using it"): $W(D):=\sum_{p\in\mathrm{dom}\,V}2^{-|p|}[\varphi_{V(p)}\supseteq D]=\sum_e\mathbf m(e)[\varphi_e\supseteq D]$.
* *Kolmogorov version* (single shortest program): $K_F(D):=\min\{|p|:p\in\mathrm{dom}\,V,\ \varphi_{V(p)}\supseteq D\}=\min\{K(e):\varphi_e\supseteq D\}$.
* *Product mixture* (private randomness per input, on data sets): $M_{\rm prod}(D):=\sum_i\mathbf m(i)\prod_{(x,y)\in D}P_i(y\mid x)$.
* *Per-query mixture* (private randomness per query, on sequences): $M_{\rm pq}(y_{1:n}\Vert x_{1:n}):=\sum_i\mathbf m(i)\prod_{t\le n}P_i(y_t\mid x_t)$, for any finite sequence of pairs, consistent or not.

$W(\emptyset)$, $M_{\rm prod}(\emptyset)$ and $M_{\rm pq}(\varepsilon\Vert\varepsilon)$ are below $1$ (non-halting programs). Normalising by them changes losses by a constant only.

*Why $W$ uses programs that delimit themselves before reading the input* (referee m16). With this choice $W$ is a mixture of fixed functions with input-independent weights: it is the containment functional of the random partial function "draw $p$ with probability $2^{-|p|}$, output $\varphi_{V(p)}$". Summing $2^{-|p|}$ over programs of a conditional prefix machine $V(p,x)$ is a different object: for each fixed $x$ the halting programs form a prefix-free set, but their union over $x$ need not, so these weights do not define one prior over functions. Reading such a conditional program lazily from one shared tape does give a random function, namely the function machine $x\mapsto V(\omega,x)$. That is a machine law of complexity $O(1)$, so it lies below $M_F$ up to a constant (Thm 3.2), and on single points it is $2^{-K(y\mid x)\pm O(1)}$ (context Prop 5.4(1)). It is not a mixture over fixed functions.

*Operator induction.* Solomonoff's third kind of induction takes an unordered set of question–answer pairs and mixes, with a $2^{-\text{length}}$ prior, probabilistic "operators" applied to the questions **[known: R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008; abstract and secondary snippets only (unverified)]**. Secondary sources write its prediction as $\sum_ja_j\prod_{i\le n}O^j(A_i\mid Q_i)$, a product over the $n$ pairs with no merging of repeated questions (E. Özkural, arXiv 1709.03879, snippet; unverified). That is $M_{\rm pq}$, not $M_{\rm prod}$. The two agree on data with distinct inputs (Prop 6.9(a)). `notes.md` identified operator induction with $M_{\rm prod}$; that identification is withdrawn (referee M3). The history track's claim 4.9 already uses the per-query reading.

**Theorem 4.2 (the chain)** **[proved]**. For every data set $D\ne\emptyset$:
$$2^{-K_F(D)}\ \le\ W(D)\ \le\ 2^{O(1)}M_{\rm prod}(D)\ \le\ 2^{O(1)}M_F(D)\ \le\ 2^{O(1)}M^w(D)\ \le\ 2^{K(\mathrm{dom}\,D)+O(1)}\,2^{-K_F(D)}.$$
So the five quantities agree up to $K(\mathrm{dom}\,D)+O(1)$ bits.

*Proof.* (1) The shortest program is one term of the sum. (2) $P_e(y\mid x):=[\varphi_e(x)=y]$ is a conditional semimeasure, lower semicomputable uniformly in $e$; let $g$ be computable with $P_{g(e)}=P_e$. The map $i\mapsto\sum_{e:g(e)=i}\mathbf m(e)$ is a lower-semicomputable discrete semimeasure, so $\mathbf m(i)\ge2^{-O(1)}\sum_{e:g(e)=i}\mathbf m(e)$ by the universality of $\mathbf m$ (coding theorem, known). Hence $M_{\rm prod}(D)\ge\sum_i\mathbf m(i)\nu_{P_i}(D)\ge2^{-O(1)}\sum_e\mathbf m(e)[\varphi_e\supseteq D]$. (3) $M_{\rm prod}$ is a lower-semicomputable mixture of product laws, a machine law by Prop 3.3(a,d); apply Thm 3.2. (4) Thm 3.5(i). (5) $K_F(D)\le K(D)+O(1)$ (the lookup table of $D$ is a program computable from $D$). $K(D)\le K(\mathrm{dom}\,D)+K(D\mid\mathrm{dom}\,D)+O(1)$ (subadditivity, known). $K(D\mid\mathrm{dom}\,D)\le-\log M^w(D)+O(1)$ by the conditional coding theorem applied to $P(E\mid S):=M^w(E)$ for $\mathrm{dom}\,E=S$, which sums to at most $1$ over $E$ (consequence (b) of Def 2.1). $\square$

**Proposition 4.3 (deterministic programs cannot separate inputs cheaply)** **[proved]**.
* (a) *Two points, binary labels.* Let $\{0,1\}\subseteq Y$. For every $\varepsilon>0$ and all large $n$ there are distinct $x_1,x_2\in\{0,1\}^n$ with $W(\{(x_1,0),(x_2,1)\})\le\varepsilon$. On the other hand $M_{\rm prod}(D)\ge2^{-O(1)}/4$ and $M_F(D)\ge2^{-O(1)}/4$ for every two-point $D$ with labels in $\{0,1\}$. Hence $M_{\rm prod}/W$ and $M_F/W$ are unbounded on two-point data sets.
* (b) *One point, long labels* (context track, Prop 5.4(2)). For $Y=\{0,1\}^*$ and every $n$ there is $y\in\{0,1\}^n$ with $W(\{(0^n,y)\})\le2^{1-n}\tau_V(n-1)$ while $M_{\rm prod}(\{(0^n,y)\})\ge2^{-n-O(1)}$, where $\tau_V(\ell):=\sum_{p\in\mathrm{dom}\,V,|p|\ge\ell}2^{-|p|}$. So $M_{\rm prod}/W$ and $M_F/W$ are unbounded already on one-point data sets.

*Proof.* $\tau_V(\ell)\to0$, since $\sum_{p\in\mathrm{dom}V}2^{-|p|}\le1$.
(a) Let $E_\ell$ be the set of fewer than $2^\ell$ indices $V(p)$ with $|p|<\ell$. Colour $x\in\{0,1\}^n$ by $c(x):=(\chi_e(x))_{e\in E_\ell}$, where $\chi_e(x)=\varphi_e(x)$ if this is $0$ or $1$ and $\chi_e(x)=*$ otherwise. There are at most $3^{2^\ell}$ colours, so if $2^n>3^{2^\ell}$ two distinct strings $x_1,x_2$ share a colour (pigeonhole). No $e\in E_\ell$ has $\varphi_e(x_1)=0$ and $\varphi_e(x_2)=1$. Hence $W(\{(x_1,0),(x_2,1)\})\le\tau_V(\ell)$. Choose $\ell$ with $\tau_V(\ell)\le\varepsilon$ and then $n$ with $2^n>3^{2^\ell}$. For the lower bound use the uniform product law $P(0\mid x)=P(1\mid x)=\tfrac12$, which has complexity $O(1)$.
(b) Fewer than $2^{n-1}$ programs have length at most $n-2$, and each gives one value at $0^n$. So at least $2^{n-1}$ strings $y\in\{0,1\}^n$ receive $W$-mass only from programs of length at least $n-1$, whose total mass is at most $\tau_V(n-1)$. One of them has $W(\{(0^n,y)\})\le\tau_V(n-1)/2^{n-1}$. For the lower bound, $P(y\mid x):=2^{-|x|}$ if $|y|=|x|$ and $0$ otherwise is a computable conditional probability of complexity $O(1)$, so $M_{\rm prod}(\{(0^n,y)\})\ge2^{-O(1)}2^{-n}$. $\square$

*Remark 4.3a (how fast the gaps of Prop 4.3 grow)* **[proved]**. Let $\ell_n:=\lceil\log_2(n/\log_23)\rceil-1$, the largest $\ell$ with $3^{2^\ell}<2^n$ (c8(a)).
* By (a), some two-point binary $D$ on $n$-bit inputs has $-\log W(D)\ge\log(1/\tau_V(\ell_n))$.
* By Prop 4.4(b) below, every two-point binary $D$ on inputs of length at most $n$ has $-\log W(D)\le2+\kappa(2^{n+1})+O(1)\le2+K(\lceil\log_2(n+1)\rceil)+O(1)$.
* Both functions are unbounded, and both are of "$\kappa$ type": $\log(1/\tau_V(\ell))\le\kappa(\ell)+O(1)$. (*Proof:* choose $L\ge\ell$ with $K(L)=\kappa(\ell)$. The prefix machine that reads a $V$-program for $L$, then $L$ more bits, and halts, is simulated by $V$ with a fixed prefix $r$; the resulting programs of $V$ have length at least $L\ge\ell$ and total weight $2^{-|r|-K(L)}$, so $\tau_V(\ell)\ge2^{-\kappa(\ell)-|r|}$.) By Prop 4.4(c), applied with $g(N):=h(\max(0,\lfloor\log_2N\rfloor-1))$, the two-point gap is at most $2\log_2(h(n)+2)+O_h(1)$ for every computable, nondecreasing, unbounded $h$. Its exact rate is open.

**Proposition 4.4 (tape-length bound for the program mixture)** **[proved; finite analogue computed: c9(a), r5]**. This replaces the hashing bound of `notes.md` (kept as Remark 4.4a).
* (a) Let $T$ be a function machine with law $\nu$. For $L\ge0$ let $\nu^{(L)}(D):=\lambda\{\omega:$ every $(x,y)\in D$ has a triple $(x,w,y)\in T$ with $w$ a prefix of $\omega_{1:L}\}$. Then $\nu^{(L)}$ is nondecreasing in $L$, $\nu^{(L)}(D)\uparrow\nu(D)$, and for every $D\ne\emptyset$ and every $L$,
$$W(D)\ \ge\ 2^{-K(T)-\kappa(L)-c}\,\nu^{(L)}(D),$$
with $c$ independent of $T$, $D$ and $L$. Consequently, with $L_{1/2}(\nu,D):=\min\{L:\nu^{(L)}(D)\ge\nu(D)/2\}$, $W(D)\ge2^{-K(T)-\kappa(L_{1/2}(\nu,D))-1-c}\,\nu(D)$. Applied to $T_U$: $\log\frac{M_F(D)}{W(D)}\le\kappa(L_{1/2}(M_F,D))+O(1)$.
* (b) *Fair-coin labels.* For every $D$ with labels in $\{0,1\}$ and $\mathrm{dom}\,D\subseteq\{0,1\}^{\le n}$:
$$W(D)\ \ge\ 2^{-|D|-\kappa(2^{n+1})-c'}\ \ge\ 2^{-|D|-K(\lceil\log_2(n+1)\rceil)-c''}.$$
* (c) *Growth of $\kappa$.* $\kappa$ is nondecreasing and unbounded, $\kappa(2^{2^s})\le K(s)+O(1)$, and for every computable, nondecreasing, unbounded $g:\mathbb N\to\mathbb N$ there is $c_g$ with $\kappa(N)\le2\log_2(g(N)+2)+c_g$ for all $N$.

*Proof.* (a) Monotonicity: a prefix of $\omega_{1:L}$ is a prefix of $\omega_{1:L'}$ for $L'\ge L$. Convergence: $f_\omega\supseteq D$ holds exactly when each of the finitely many pairs of $D$ has a certifying triple along $\omega$, and then all of them lie within the longest one; so $\{f_\omega\supseteq D\}=\bigcup_L\{\text{certified within }L\}$, an increasing union. For the bound, fix $L'\ge L$ with $K(L')=\kappa(L)$. For $w\in\{0,1\}^{L'}$ let $\varphi_{T,w}(x):=y$ if some $(x,w',y)\in T$ has $w'$ a prefix of $w$, and undefined otherwise. This is well defined because $T$ is consistent and two prefixes of $w$ are comparable, and it is partial computable (enumerate $T$). Let $V'$ be the prefix machine that reads a $V$-program for an index $i$ of $T$, then a $V$-program for $L'$, then $L'$ further bits $w$, and outputs an index of $\varphi_{T_i,w}$. Its domain is prefix-free. By universality $V(rs)=V'(s)$ for a fixed string $r$. Using shortest programs for $i$ and $L'$, the programs $r\,q_i\,q_{L'}\,w$ ($w\in\{0,1\}^{L'}$) are distinct elements of $\mathrm{dom}\,V$, so
$$W(D)\ \ge\ \sum_{w\in\{0,1\}^{L'}}2^{-|r|-K(T)-K(L')-L'}[\varphi_{T,w}\supseteq D]\ =\ 2^{-|r|-K(T)-\kappa(L)}\,\nu^{(L')}(D)\ \ge\ 2^{-|r|-K(T)-\kappa(L)}\,\nu^{(L)}(D).$$
The consequence is immediate, and $K(T_U)=O(1)$. (b) Apply (a) to the machine $F(x):=\omega_{j(x)+1}$, which has complexity $O(1)$ and law $2^{-|D|}$ on binary-labelled $D$; for $|x|\le n$ its certificates lie within $L=2^{n+1}-1$ bits, and $\kappa(2^{n+1}-1)\le\kappa(2^{n+1})$ since $\kappa$ is nondecreasing. With $s:=\lceil\log_2(n+1)\rceil$, $L'':=2^{2^s}\ge2^{n+1}$ and $K(L'')\le K(s)+O(1)$. (c) Monotone: the minimum is over a shrinking set. Unbounded: only finitely many $L$ have $K(L)\le c$. The bound for $2^{2^s}$ is the computation in (b). For $g$: let $N^*:=\min\{N':g(N')\ge g(N)+1\}$; it exists because $g$ is unbounded, it exceeds $N$ because $g$ is nondecreasing, and it is computable from $g(N)+1$. So $\kappa(N)\le K(N^*)\le K(g(N)+1)+c_g\le2\log_2(g(N)+2)+c'_g$, using $K(j)\le2\log_2(j+1)+O(1)$. $\square$

So the program mixture can imitate any shared-tape law, paying only for a self-delimiting description of (an upper bound on) how many tape bits the law reads. Hänni's random program "generating" labels does not need private random bits at all: it can carry the bits it needs. (The steeper track's Lemma 3.2′ adapts the same idea to product classes and computable samplers.)

*Remark 4.4a (the hashing bound of `notes.md`, superseded)* **[proved; computed: c2, r10]**. `notes.md` proved, via $|D|$-wise independent polynomial hashing over $\mathrm{GF}(2^{n+1})$, that $W(D)\ge2^{-|D|-K(n,k)-O(1)}$ for binary-labelled $D$ with $|D|\le k$ and inputs of length at most $n$. The proof is correct (c2 checks the independence exhaustively for small fields). Prop 4.4(b) is stronger, since $K(n,k)\ge K(n)-O(1)\ge\kappa(2^{n+1})-O(1)$, and it does not depend on $|D|$. The steeper track cites the hashing bound and proves the dyadic-sampler case as its Lemma 3.2; its Lemma 3.2′ uses the stored-tape argument instead. The brief's hint ("a log factor via $k$-wise independent hashing") describes the single shortest program, not $W$: for $K_F$ a logarithmic cost is real (Thm 4.7), and Prop 4.9 bounds it by a covering argument rather than by hashing.

**Proposition 4.5 (shared randomness is not a mixture of private randomness)** **[proved; counting step computed: r9(c)]**. Let $\{0,1\}\subseteq Y$ and let $\sigma$ be the law of $F(x):=\omega_{|x|}$: one fair coin per input length, shared by all inputs of that length. $\sigma$ is a machine law of complexity $O(1)$. But $\sup_D\sigma(D)/M_{\rm prod}(D)=\infty$. Hence $M_F/M_{\rm prod}$ is unbounded.

*Proof.* Suppose $M_{\rm prod}\ge c\,\sigma$ for some $c\in(0,1]$. Put $\varepsilon:=c/8$, write $M_{\rm prod}=\sum_iw_i\nu_{P_i}$ with $w_i=\mathbf m(i)$, and choose $J$ with $\sum_{i>J}w_i\le\varepsilon$. Let $a_n:=0^n$, $b_n:=1^n$, and $s_i(n,y):=P_i(y\mid a_n)P_i(y\mid b_n)$ for $y\in\{0,1\}$.
* *Compactness.* Choose an infinite set of lengths along which $P_i(y\mid a_n)\to\alpha_i(y)$ and $P_i(y\mid b_n)\to\beta_i(y)$ for all $i\le J$, $y\in\{0,1\}$. Let $S_i:=\alpha_i(0)\beta_i(0)+\alpha_i(1)\beta_i(1)\le\max_y\alpha_i(y)\cdot(\beta_i(0)+\beta_i(1))\le1$. If $S_i=1$ then $\max_y\alpha_i(y)=1$, so $\alpha_i=\delta_{y_i}$ for some $y_i$, and then $\beta_i(y_i)=1$, so $\beta_i=\delta_{y_i}$. Let $I_1:=\{i\le J:S_i=1\}$ and $I_0:=\{i\le J:S_i<1\}$, and $r:=\max_{i\in I_0}(1+S_i)/2<1$.
* *Subsequence.* Choose lengths $n_1<n_2<\cdots$ from that set so that, for every $j$: $s_i(n_j,0)+s_i(n_j,1)\le r$ for $i\in I_0$, and $s_i(n_j,1-y_i)\le\delta2^{-j}$ for $i\in I_1$, where $\delta:=\varepsilon/2$.
* *Data.* For $b\in\{0,1\}^k$ let $D_b:=\{(a_{n_j},b_j),(b_{n_j},b_j):j\le k\}$. Then $\sigma(D_b)=2^{-k}$. All $D_b$ have the same domain, so for every $i$, $\sum_b\nu_{P_i}(D_b)=\prod_j(s_i(n_j,0)+s_i(n_j,1))\le1$.
* *Count.* Let $B_k$ be $\{0,1\}^k$ without the two constant vectors. For $i\in I_1$ and $b\in B_k$ the set $T_b:=\{j:b_j\ne y_i\}$ is nonempty, so $\prod_js_i(n_j,b_j)\le\prod_{j\in T_b}\delta2^{-j}$, and $\sum_{b\in B_k}\prod_js_i(n_j,b_j)\le\prod_j(1+\delta2^{-j})-1\le e^\delta-1\le2\delta$. Therefore
$$\textstyle\sum_{b\in B_k}M_{\rm prod}(D_b)\le\sum_{i>J}w_i+\sum_{i\in I_0}w_ir^k+\sum_{i\in I_1}w_i\,2\delta\le\varepsilon+r^k+\varepsilon\le3\varepsilon$$
once $r^k\le\varepsilon$. But $\sum_{b\in B_k}c\,\sigma(D_b)=c(1-2^{1-k})\ge c/2=4\varepsilon$ for $k\ge2$, a contradiction. $\square$

*Remark 4.5a (size of this gap)* **[proved]**. The witnesses come from a compactness argument and are not explicit. Their size is limited by Prop 4.4: certificates of $\sigma$ for inputs of length at most $n$ lie in $\omega_{1:n+1}$, so on data with inputs of length at most $n$, $M_{\rm prod}(D)\ge2^{-O(1)}W(D)\ge2^{-\kappa(n+1)-O(1)}\sigma(D)$. So the gap that Prop 4.5 exhibits on data with inputs of length at most $n_k$ is at most $\kappa(n_k+1)+O(1)$ bits. A lower bound on its rate is open.

**Problem 4.6 (status).** `notes.md` listed three open questions here.
* (a) *Coding theorem for function programs: is $-\log W(D)=K_F(D)+O(1)$?* **Answered: no** (Thm 4.7 below). The gap is unbounded, and $K_F$ is not even bounded by a constant multiple of $-\log W$. `notes.md` conjectured "no"; the conjecture was correct.
* (b) *Is $\log(M_F(D)/W(D))=O(K(n,|D|))$ for inputs of length at most $n$?* Partly answered. For binary fair-coin labels the gap to the fair-coin law is at most $\kappa(2^{n+1})+O(1)$, independent of $|D|$ (Prop 4.4(b)). In general the gap is at most $\min\{\kappa(L_{1/2}(M_F,D)),\,K(\mathrm{dom}\,D)\}+O(1)$ (Prop 4.4(a), Thm 4.2). The tape length $L_{1/2}$ is not computably bounded in $(n,|D|)$, so the general question remains **[open]**.
* (c) *Rates for the gaps of Props 4.3 and 4.5.* Upper bounds of $\kappa$ type are now proved (Remarks 4.3a and 4.5a); matching lower rates are **[open]**.

**Theorem 4.7 (no coding theorem for function programs; referee's Prop A)** **[proved; pigeonhole arithmetic computed: c8(a); exact two-point covering numbers: c8(b), r11]**. Let $\{0,1\}\subseteq Y$ and $n\ge2$. There are distinct $x_1,x_2\in\{0,1\}^n$ such that $D:=\{(x_1,0),(x_2,1)\}$ satisfies
* (i) $K_F(D)\ \ge\ \log_2n-2$;
* (ii) $-\log W(D)\ \le\ 2+K(\lceil\log_2(n+1)\rceil)+c$;
* (iii) $-\log M_F(D)\ \le\ 2+c$,

with $c$ independent of $n$. Hence $K_F(D)+\log W(D)\ge\log_2n-K(\lceil\log_2(n+1)\rceil)-c-4\to\infty$, and on these data sets $-\log W(D)\le\log_2K_F(D)+O(\log\log K_F(D))$.

*Proof.* (i) Let $g:=\lceil\log_2(n/\log_23)\rceil-1$, so that $2^g\log_23<n$, i.e. $3^{2^g}<2^n$ (c8(a) checks the arithmetic for all $n\le2\cdot10^5$ and along powers of 2 up to $2^{200}$). Fewer than $2^g$ programs have length less than $g$; let $E$ be the set of their indices $V(p)$. Colour $x\in\{0,1\}^n$ by $(\chi_e(x))_{e\in E}\in\{0,1,*\}^E$ as in Prop 4.3. There are at most $3^{|E|}<2^n$ colours, so two distinct $x_1,x_2$ share a colour. Then no $e\in E$ has $\varphi_e(x_1)=0$ and $\varphi_e(x_2)=1$, so $K_F(D)\ge g\ge\log_2n-\log_2\log_23-1>\log_2n-2$.
(ii) Prop 4.4(b) with $|D|=2$: $W(D)\ge2^{-2-K(\lceil\log_2(n+1)\rceil)-c}$.
(iii) The uniform product law, as in Prop 4.3.
For the last claim: by (i), $\log_2n\le K_F(D)+2$, so $\lceil\log_2(n+1)\rceil\le K_F(D)+4$, and $K(s)\le\log_2s+2\log_2\log_2s+O(1)$ for $s\ge2$. $\square$

Equivalently, with $S_D:=\{e:\varphi_e\supseteq D\}$ (a c.e. set of indices), $W(D)=\mathbf m(S_D)$ and $K_F(D)=\min_{e\in S_D}K(e)$. Theorem 4.7 says that a c.e. set of programs can have algorithmic probability $2^{-O(\log\log n)}$ while its simplest member has complexity $\log_2n-O(1)$. Levin's "Occam bound on lowest complexity of elements" relates exactly these two quantities to the information the set carries about the halting problem **[known: L. A. Levin, *Ann. Pure Appl. Logic* 167(10):897–900, 2016, arXiv 1403.4539; see also S. Epstein, L. A. Levin, "Sets have simple members", arXiv 1107.1458; bibliographic data from snippets, statements unverified; whether they apply to infinite c.e. sets such as $S_D$ was not checked]**. Nothing here depends on these references.

*Comparison with sequences.* For binary sequences the monotone complexity $Km$ and $-\log M$ also differ unboundedly **[known: P. Gács, "On the relation between descriptional complexity and algorithmic probability", *Theoret. Comput. Sci.* 22:71–93, 1983; A. R. Day, "Increasing the gap between descriptional complexity and algorithmic probability", CCC 2009, pp. 263–273, journal version *Trans. Amer. Math. Soc.* 2011; bibliographic data from snippets; statements unverified]**. The referee reports a snippet giving an upper bound on $Km-KM$ logarithmic in $Km$ (unverified). I make no comparison of rates.

**Corollary 4.8 (two-point rates)** **[proved]**. Let $\rho_K(n)$ be the largest value of $K_F(D)+\log M_F(D)$ over two-point data sets $D$ with binary labels and $n$-bit inputs. Then
$$\log_2n-O(1)\ \le\ \rho_K(n)\ \le\ \log_2n+K(\lceil\log_2(n+2)\rceil)+O(1)\ =\ \log_2n+O(\log\log n).$$
Against $W$, every such $D$ has $-\log W(D)\le2+K(\lceil\log_2(n+1)\rceil)+O(1)$ (Prop 4.4(b)).

*Proof.* Lower: Thm 4.7(i),(iii). Upper: $-\log M_F(D)\ge0$, and Prop 4.9 with $k=2$ gives $K_F(D)\le2+\log_2(2(n+2))+K(\lceil\log_2(n+2)\rceil)+O(1)$. $\square$

(The referee's Cor A2 had $K(n)+\log_2n$; padding $n$ to $2^{\lceil\log_2(n+2)\rceil}-2$ in Prop 4.9 removes the $K(n)$. An explicit two-point covering family also exists: the $\lfloor N/2\rfloor$-subsets of $\{0,\dots,N-1\}$ that contain $0$, read as $N$ functions on $\binom{N-1}{\lfloor N/2\rfloor-1}$ inputs, show all four label patterns on every pair [computed: c8(b), $N\le14$]; this is the Kleitman–Spencer construction, which is optimal [known: D. J. Kleitman, J. Spencer, "Families of $k$-independent sets", *Discrete Math.* 6:255–262, 1973; bibliographic data from snippets; optimality unverified, computed for $N\le6$ in c8(b) and $N\le8$ in r11]. Covering all inputs of length at most $n$ needs $N-n\le6$ functions more than $n$ for $n\le40$ (c8(b)). Nothing depends on optimality.)

**Proposition 4.9 (covering bound for the single shortest program; referee's Prop A3, sharpened)** **[proved; computed: c8(c,d), r11(d)]**. For every $D$ with labels in $\{0,1\}$, $|D|=k$ and $\mathrm{dom}\,D\subseteq\{0,1\}^{\le n}$:
$$K_F(D)\ \le\ k+\log_2\big(k(n+2)\big)+K\big(\lceil\log_2(n+2)\rceil,k\big)+O(1).$$
Consequently, if $K(D\mid\mathrm{dom}\,D)\ge k-d$ (labels incompressible given the inputs), then
$$K_F(D)\ \le\ -\log M_F(D)+d+\log_2\big(k(n+2)\big)+K\big(\lceil\log_2(n+2)\rceil,k\big)+O(1).$$

*Proof.* Put $s:=\lceil\log_2(n+2)\rceil$ and $n':=2^s-2\ge n$; then $n'+2<2(n+2)$ (c8(d)). There are at most $\binom{2^{n'+1}-1}{k}2^k\le2^{k(n'+2)}$ binary-labelled data sets of size $k$ on $\{0,1\}^{\le n'}$. Put $N:=\lfloor2^kk(n'+2)\ln2\rfloor+1$. $N$ independent uniform truth tables on $\{0,1\}^{\le n'}$ all miss a fixed such $D$ with probability $(1-2^{-k})^N<e^{-N2^{-k}}\le2^{-k(n'+2)}$. By the union bound the expected number of uncovered data sets is below $1$, so some family of $N$ truth tables covers every such $D$. The lexicographically first such family is computable from $(n',k)$, hence from $(s,k)$, by exhaustive search. A program consists of a $V$-program for $(s,k)$ followed by a $\lceil\log_2N\rceil$-bit index (its length is computable from $(s,k)$, so the program is self-delimiting), and it outputs an index of the chosen truth table, undefined off $\{0,1\}^{\le n'}$. Its length is at most $K(s,k)+\log_2N+1+O(1)$, and $\log_2N\le k+\log_2(k(n'+2))\le k+\log_2(k(n+2))+1$. The consequence: $-\log M_F(D)\ge K(D\mid\mathrm{dom}\,D)-O(1)\ge k-d-O(1)$ (Thm 6.3(a)). $\square$

So the brief's hint "a log factor via $k$-wise independent hashing" is right for the **single shortest program**, with covering in place of hashing: the cost over $M_F$ is about $\log_2(k(n+2))$ plus lower-order terms. The program **mixture** needs no log factor (Prop 4.4).

**Remark 4.10 (witnesses of large gaps cannot be computable)** **[proved]**.
* If $k\mapsto D_k$ is computable, then $K_F(D_k)\le K(k)+O(1)$: a program reads a $V$-program for $k$, computes $D_k$ and outputs an index of its lookup table. All five quantities of Thm 4.2 lie between $2^{-K_F(D_k)-O(1)}$ and $1$, so they agree on $D_k$ up to $K(k)+O(1)$ bits. A gap that grows faster than $K(k)$, as in Thm 3.5(iii), therefore needs a non-computable family.
* If $n\mapsto D_n$ is computable and every input of $D_n$ has length $n$, one program reads $x$, computes $n=|x|$ and $D_n$, and outputs $D_n(x)$. So $K_F(D_n)=O(1)$ and all five quantities agree up to $O(1)$ on the family. The witness pairs of Prop 4.3(a) and Thm 4.7 therefore cannot be chosen by a computable rule from $n$; neither can the witness $y$ of Prop 4.3(b).
* The non-constructive witnesses are therefore not missing constructions. What explicitness is possible: Thm 3.5(iv) gives an explicit family on which the gap holds on average. Whether some computable family $k\mapsto D_k$ has a gap tending to infinity, for any of the comparisons of Table 4.12, is **[open]**.

**Remark 4.11 (where the randomness lives).** The mixtures differ in where the randomness lives:
* $W$ and $K_F$: none; each hypothesis is a fixed function;
* $M_{\rm prod}$: private per input (each hypothesis is a stochastic operator applied to each input independently, once);
* $M_{\rm pq}$: private per query (a repeated input is resampled);
* $M_F$: one tape shared by all inputs; a hypothesis may correlate labels across inputs, for example $F(x)=\omega_{|x|}$.

Because the mixture index is shared, every mixture correlates labels across inputs through its posterior. Props 4.3, 4.5 and Thm 4.7 show that the classes still differ by more than constants. Prop 4.4 shows that the differences among $W$, $M_{\rm prod}$ and $M_F$ are small whenever the relevant tape length has a simple upper bound.

### Table 4.12: the Kolmogorov and universal-semimeasure versions compared (Hänni's later request)

All statements are for data sets $D$; "$n$" bounds input lengths; gaps are in bits ($\log_2$ of the ratio, or $K_F+\log$ for $K_F$). Each row is proved above unless marked.

| comparison | equal up to $O(1)$? | gap: lower bound and witness | gap: upper bound | open |
|---|---|---|---|---|
| $2^{-K_F}$ vs $W$ | **no** (Thm 4.7) | $\ge\log_2n-K(\lceil\log_2(n+1)\rceil)-O(1)$ on some two-point binary $D$ (non-computable witness) | $K(\mathrm{dom}\,D)+O(1)$ (Thm 4.2); binary labels, $k$ points: $d+\log_2(k(n+2))+K(\lceil\log_2(n+2)\rceil,k)+O(1)$, $d:=k-K(D\mid\mathrm{dom}\,D)$; this bounds the gap to $M_F$, hence to $W$ (Prop 4.9) | exact rate in general |
| $2^{-K_F}$ vs $M_F$ | **no** | $\log_2n-O(1)$ on two points (Thm 4.7) | two points: $\log_2n+O(\log\log n)$ (Cor 4.8); general: $K(\mathrm{dom}\,D)+O(1)$ | general rate |
| $W$ vs $M_{\rm prod}$ (and vs $M_F$) | **no** (Prop 4.3) | two points: $\ge\log(1/\tau_V(\ell_n))-O(1)$; one point, $Y=\{0,1\}^*$: $\ge\log(1/\tau_V(n-1))-O(1)$ (non-computable witnesses) | two points, binary: $\kappa(2^{n+1})+O(1)$; against any machine law $\nu$: $K(\nu)+\kappa(L_{1/2}(\nu,D))+O(1)$ (Prop 4.4); general: $K(\mathrm{dom}\,D)+O(1)$ | Problem 4.6(b); rates |
| $M_{\rm prod}$ vs $M_F$ | **no** (Prop 4.5) | unbounded, no rate (compactness witnesses) | on $\sigma$-type data: $\kappa(n+1)+O(1)$ (Remark 4.5a); general: $\min\{\kappa(L_{1/2}(M_F,D)),K(\mathrm{dom}\,D)\}+O(1)$ | lower rate |
| $M_F$ vs $M^w$ | **no** (Thm 3.5) | $\ge k\log\frac32-K(k)-O(1)$ on some $2k$-point $D$; on average over the explicit family $E_{\vec\imath}$ (Thm 3.5(iv)) | $K(\mathrm{dom}\,D)+O(1)$ | how close to $K(\mathrm{dom}\,D)$ |
| $M_F$ vs every lsc random-function law | ? | — | $K(\mathrm{dom}\,D)+O(1)$ | Problem 3.6 |
| $M_{\rm prod}$ vs $M_{\rm pq}$ | equal on sequences with distinct inputs (Prop 6.9(a)) | with repeats: $M_{\rm pq}\le M_{\rm prod}$, and $M_{\rm pq}>0=M_{\rm prod}$ on inconsistent sequences | — | — |

*Explicit examples.* By Remark 4.10, no computable family exhibits a gap larger than $K(k)+O(1)$ for any row. The witnesses above are non-constructive by necessity. Thm 3.5(iv) is an explicit family with a linear gap on average.

### What the differences mean for prediction (referee Q3)

* *Gaps are cumulative losses.* For any weak semimeasure $\nu$, the cumulative log loss of its predictor on $D$, in any reveal order, is $-\log\nu(D)+\log\nu(\emptyset)$ (Prop 5.2). So a gap of $g$ bits between two of $W$, $M_{\rm prod}$, $M_F$, $M^w$ on $D$ is a difference of $g$ bits, up to the constants $\log W(\emptyset)$ and $\log M_{\rm prod}(\emptyset)$, in total log loss on $D$, in every order. Individual steps can differ by more or less.
* *Deterministic programs versus a random tape.* The program mixture predicts as well as SFI up to $\kappa(L_{1/2}(M_F,D))+O(1)$ bits in total (Prop 4.4). For binary fair-coin labels this is at most $K(\lceil\log_2(n+1)\rceil)+O(1)$ bits, however many labels are predicted. So whether the "random program" of Hänni's definition has a random tape matters little for prediction, unless SFI's explanation of the data uses a number of tape bits with no simple upper bound. The same holds for private versus shared randomness ($M_{\rm prod}$ lies between $W$ and $M_F$).
* *The single shortest program.* $K_F(D)$ is the code length of a one-program description (MDL with a single hypothesis; the Occam learner of §6.6). It can exceed SFI's total loss by $\log_2n-O(1)$ bits already on two points, and by $\log_2(k(n+2))$ plus lower-order terms on $k$ incompressible binary labels. $2^{-K_F}$ is not used here as a predictor; the statement is about description length and model selection, not about the loss of a Bayes mixture. For deterministic targets the risk bounds of the shortest consistent program and of SFI have the same rate (§6.6).
* *Weak versus random-function semimeasures.* $M^w$ can beat $M_F$ by a linear number of bits on data such as the $\tau$ blocks, which no random function produces. It pays for this by having no posterior over functions: its joint predictions for several test inputs need not be those of any random function (Example 2.4).
* *Deterministic computable targets.* All five quantities are at least $2^{-K(f)-O(1)}$ on $f$'s data, so the basic learning bounds (Thm 6.1(b), Cor 6.6, Thm 6.7(a)) are the same for all of them.
* *Fresh label noise with repeated inputs.* Here the per-query mixture and the set-based objects differ completely: finite against infinite loss (Props 6.8, 6.9).

**Answer to the question in Hänni's draft (§2.2, "Equivalence between Kolmogorov version and universal semimeasure version: need coding theorem").** There are three objects, and none is equivalent to another up to a constant.
* The *single shortest program* $K_F$ falls short of $M_F$ by $\log_2n\pm O(\log\log n)$ bits at worst on two-point data sets with $n$-bit inputs (Cor 4.8). The reason: one program must be chosen, and the fewer than $2^g$ programs shorter than $g$ cannot separate every pair among $2^n$ inputs when $3^{2^g}<2^n$, while a random tape separates any two inputs at constant cost.
* The *program mixture* $W$ falls short of $M_F$ by an unbounded amount (Prop 4.3), but by much less, and for a different reason. It sums over many programs: the $2^L$ programs that store the different $L$-bit tape prefixes together carry weight $2^{-K(L)}$, so $W$ pays only for naming a padded tape length, at most $\kappa(L_{1/2}(M_F,D))+O(1)$ bits (Prop 4.4), and only $K(\lceil\log_2(n+1)\rceil)+O(1)$ bits for fair-coin labels. `notes.md` gave the single-program reason for this gap too; that was misleading for $W$ (referee M4(e)).
* There is **no coding theorem for function programs**: $-\log W$ and $K_F$ differ unboundedly, and not even within a constant factor (Thm 4.7). What the coding theorem does give is the bound $K(\mathrm{dom}\,D)+O(1)$ for all comparisons (Thm 4.2).
* For deterministic computable targets the differences do not affect the basic bounds: all versions have loss at most $K(f)+O(1)$ on $f$'s data.

---

## 5. The definition of SFI and its conventions

**Definition 5.1 (Solomonoff function induction).** Fix $V$ and the enumeration of function machines. SFI is the random partial function $f_\omega:=f^{T_U}_\omega$ with $\omega$ uniform, and its law $M_F$ (Thm 3.2). After data $D$:
* the *posterior* is the conditional law of $f_\omega$ given $f_\omega\supseteq D$; it is again the law of a random partial function, with containment functional $E\mapsto M_F(D\cup E)/M_F(D)$ for $E$ consistent with $D$;
* the *predictive conditional* at a new input $x$ is $M_F(y\mid D,x):=M_F(D+(x,y))/M_F(D)$, a sub-probability on $Y$. Its defect $1-\sum_yM_F(y\mid D,x)$ is the posterior probability that $f_\omega(x)$ is undefined;
* at an input $x\in\mathrm{dom}\,D$ the prediction is the stored label with probability $1$ (because $f_\omega$ is a function).

$M_F(D)>0$ for every data set $D$, since the lookup table of $D$ is a program with positive weight.

**Proposition 5.2 (order independence)** **[proved; computed for a finite mixture: c4 part (2)]**. In the semimeasure convention the cumulative log loss of SFI on a consistent sequence $(x_t,y_t)_{t\le n}$ is
$$\textstyle L_n:=\sum_{t\le n}-\log M_F(y_t\mid D_{t-1},x_t)=-\log M_F(D_n),$$
which depends only on the set $D_n$, not on the order of presentation or on repetitions. On an inconsistent sequence $L_n=\infty$.

*Proof.* With the convention of §1 a repeated input with its stored label contributes the factor $1$, and with another label the factor $0$. The remaining factors telescope to $M_F(D_n)/M_F(\emptyset)$, and $M_F(\emptyset)=1$. $\square$

The same holds, with the same convention for repeated inputs, for $W$, $M_{\rm prod}$, $M^w$ and every weak semimeasure $\nu$, with $\nu(\emptyset)$ in the denominator: the cumulative loss is $-\log\nu(D_n)+\log\nu(\emptyset)$.

**Proposition 5.3 (normalisation)** **[proved; computed: c3, r8, r13]**. Let $\bar M_F(y\mid D,x):=M_F(D+(x,y))/\sum_{y'}M_F(D+(x,y'))$ be the normalised conditional. Then (a) the normalised cumulative loss is at most $L_n$ on every sequence, so every upper bound proved below for $L_n$ also holds for it; (b) for laws of random partial functions in general it can depend on the order; (c) for laws of random total functions it equals $L_n$.

*Proof.* (a) Each normaliser is at most $M_F(D)$, so each normalised conditional is at least the raw one. (b) Example (c3): inputs $a,b$, law $(F(a),F(b))=(0,0),(0,\bot),(1,1),(\bot,\bot)$ with probability $\tfrac14$ each, data $\{(a,0),(b,0)\}$. Revealing $a$ first gives normalised probability $\tfrac{1/2}{3/4}\cdot1=\tfrac23$; revealing $b$ first gives $\tfrac{1/4}{1/2}\cdot1=\tfrac12$. The semimeasure probability is $\tfrac14$ in both orders. (c) For a random total function every normaliser is $\sum_y\nu(D+(x,y))=\nu(D)$. $\square$

Whether the normalised loss of $M_F$ itself is order-dependent is **[open]**. Prop 5.4 gives the exact condition on two-point data sets.

**Proposition 5.4 (two-point criterion for order independence; referee's Prop B)** **[proved; computed: c10(a), r13]**. Let $P$ be the law of a random partial function on inputs $a,b$. Write $A=\{F(a)\ne\bot\}$ and $B=\{F(b)\ne\bot\}$, and assume $P(A),P(B)>0$. Consider the condition
$$(\star)\qquad P(B\mid F(a)=\alpha)=P(B\mid A)\ \ \text{for all }\alpha\text{ with }P(F(a)=\alpha)>0,\qquad P(A\mid F(b)=\beta)=P(A\mid B)\ \ \text{for all such }\beta .$$
* (i) If $(\star)$ holds, the normalised probability of $\{(a,\alpha),(b,\beta)\}$ is the same in both reveal orders, for every $(\alpha,\beta)$.
* (ii) Conversely, suppose every two-point probability $P(F(a)=\alpha,F(b)=\beta)$, $\alpha,\beta\in Y$, is positive (as it is for $M_F$). If the two orders agree for every $(\alpha,\beta)$, then $(\star)$ holds.
* (iii) Without positivity, (ii) can fail: c10(a4) gives a law with $P(B\mid F(a)=0)=1$, $P(B\mid F(a)=1)=\tfrac12$, $P(B\mid A)=\tfrac34$, whose normalised probabilities are order-independent.

*Proof.* Put $u(\alpha):=P(B\mid F(a)=\alpha)/P(B)$ and $v(\beta):=P(A\mid F(b)=\beta)/P(A)$, and $p(\alpha,\beta):=P(F(a)=\alpha,F(b)=\beta)$. Revealing $a$ first gives the normalised product
$$\frac{P(F(a)=\alpha)}{P(A)}\cdot\frac{p(\alpha,\beta)}{P(F(a)=\alpha,\,B)}=\frac{p(\alpha,\beta)}{P(A)P(B)\,u(\alpha)},$$
and revealing $b$ first gives $p(\alpha,\beta)/(P(A)P(B)\,v(\beta))$. When $p(\alpha,\beta)>0$ the two agree exactly when $u(\alpha)=v(\beta)$; when $p(\alpha,\beta)=0$ both are $0$ (with $0$ times an undefined second factor read as $0$). (i) $(\star)$ gives $u\equiv P(B\mid A)/P(B)=P(A\cap B)/(P(A)P(B))\equiv v$. (ii) Agreement on all pairs forces $u(\alpha)=v(\beta)$ for all $\alpha,\beta$, so $u\equiv v\equiv c$. Averaging $u$ over $\alpha$ with weights $P(F(a)=\alpha)/P(A)$ gives $c=P(A\cap B)/(P(A)P(B))$, which is $(\star)$. (iii) The law of c10(a4) puts mass only on the diagonal pairs $(0,0),(1,1)$ among defined pairs, and is symmetric in $a,b$, so $u(\alpha)=v(\alpha)$ on the diagonal although $u$ is not constant. $\square$

*Reading.* The normaliser leaks order information exactly when whether one input is defined says something about another input's label. Total laws always satisfy $(\star)$. The law of Prop 5.3(b) violates it ($P(B\mid F(a)=0)=\tfrac12\ne\tfrac23=P(B\mid A)$). Since $M_F$ gives every two-point data set positive mass, its normalised loss is order-independent on all two-point data sets with inputs $a,b$ if and only if $(\star)$ holds for $M_F$ and $(a,b)$. I expect that it fails for some pair, but I have no proof.

**Proposition 5.5 (what transfers to the normalised convention)** **[proved; (b) uses the relativised coding theorem, known; computed: c10(b,c)]**. Write $\bar L_n:=\sum_t-\log\bar M_F(y_t\mid D_{t-1},x_t)$ and $Z_t:=\sum_yM_F(D_{t-1}+(x_t,y))/M_F(D_{t-1})$ (the posterior probability that $f_\omega(x_t)$ is defined; $Z_t:=1$ for a repeated input).
* (a) *Exact relation.* $\bar L_n=L_n-\sum_{t\le n}\log_2(1/Z_t)$. So a lower bound on $L_n$ gives the same lower bound on $\bar L_n$ minus the total "undefinedness surprisal" $\sum_t\log(1/Z_t)$, and it is useful exactly when that sum is small. At the first step $Z_1=M_F(F(x_1)\ne\bot)\ge2^{-c}$ (a constant function is a machine of complexity $O(1)$), so single-point bounds transfer: $-\log\bar M_F(y\mid\emptyset,x)=K(y\mid x)\pm O(1)$ (Thm 6.3(c)).
* (b) *A pathwise lower bound.* For every input list $x_{1:n}$ and labels $y_{1:n}$: $\bar L_n\ge K^{\emptyset'}(y_{1:n}\mid x_{1:n})-O(1)$, where $K^{\emptyset'}$ is prefix complexity relative to the halting problem.
* (c) *An expected lower bound.* For any joint law of inputs and labels (the inputs may depend on past labels), $\mathbb E\,\bar L_n\ge\sum_t\mathbb E\,H(y_t\mid h_{t-1},x_t)$, the loss of the chronological Bayes predictor.

*Proof.* (a) Each normalised factor is the raw factor divided by $Z_t$. (b) Each normalised conditional is a ratio of two positive lower-semicomputable reals, hence computable relative to $\emptyset'$, uniformly. For a fixed input list, $y_{1:n}\mapsto\prod_t\bar M_F(y_t\mid D_{t-1},x_t)$ is a probability distribution on $Y^n$: summing out $y_n$, then $y_{n-1}$, and so on, each factor sums to $1$ (c10(b) checks this on random laws, with repeated inputs). Apply the conditional coding theorem relative to $\emptyset'$. (c) The normalised predictor is a history-aware predictor issuing probabilities; Gibbs' inequality at each step, as in the history track's Thm 3.5(b). $\square$

(b) and (c) are weak exactly where the question matters. In the chain, the skipped strings and Hänni's cyclic permutation, the labels are computable from the ordered list of inputs, so $K^{\emptyset'}(y_{1:n}\mid x_{1:n})=O(1)$ and the conditional entropies are $0$.

**Remark 5.6 (which lower bounds are semimeasure-only).** The following lower bounds are proved for $L_n=-\log M_F(D_n)$, or for every order-free predictor, and do **not** transfer automatically to $\bar L_n$, which is not order-free (Prop 5.3):
* here: Thm 6.3(a) (except single points, Prop 5.5(a)) and Example 6.4;
* history track: the chain (Thm 2.1), the skipped strings (Thm 2.2), the GF example (Thm 5.4);
* examples track: the lower bounds for H5 (cyclic permutation) and H6 (Eisenstat).

The context track's OOD lower bounds bound from below the posterior mass that is *defined and wrong*, which is at most the error in either convention, so they hold in both, as its notes state. The paper should say for each lower bound which convention it uses. Whether the semimeasure-only lower bounds hold for $\bar M_F$ is **[open]**.

**Recommendation: call $M_F$ "SFI".** Reasons:
1. *It is the object Hänni describes.* "Pick a random program from the prior and generate using it" is a random function. Programs that use random bits are included, and the random bits are a single tape read by all inputs (Def 2.5). (Prop 4.4 shows that, for prediction, the random tape matters little against the deterministic mixture $W$; but $M_F$ has the cleaner theory.)
2. *It has a posterior over functions* (Def 5.1). Joint predictions for several test inputs are coherent. The weak universal semimeasure $M^w$ has no such object (Example 2.4).
3. *It dominates every machine law with constant $2^{-K(\nu)}$* (Thm 3.2): deterministic programs, x-only samplers (product laws), shared-randomness laws, computable random functions, and lower-semicomputable mixtures of these (Prop 3.3).
4. *It is invariant* under the choice of universal machine and of encodings, up to an additive constant in log loss (Thm 6.2).
5. *Its cumulative loss is order-independent* in the semimeasure convention (Prop 5.2).

The variants should be named and kept distinct in the paper:
* $W$, "deterministic SFI" (Hänni's notes), and $K_F$, the "Kolmogorov version" (single shortest program);
* $M_{\rm prod}$, "private-randomness SFI" (per input, on data sets);
* $M_{\rm pq}$, the per-query mixture, which is Solomonoff's operator induction as secondary sources describe it (unverified against the 2008 paper);
* $M^w$, the universal weak (order-free) semimeasure.

They agree with $M_F$ up to $K(\mathrm{dom}\,D)+O(1)$ bits on data sets and differ by unbounded amounts (§3–4, Table 4.12). The steeper-simplicity track works with product hypotheses on data sets ($M_{\rm prod}$-type, frozen per-input noise), for a structural reason (each input pays separately); its notes say so explicitly.

---

## 6. Basic theorems

### 6.1 Dominance (H2)

**Theorem 6.1** **[proved]**. Let $\nu$ be a machine law. For every data set $D$, $M_F(D)\ge2^{-K(\nu)}\nu(D)$. Hence for every consistent sequence $(x_t,y_t)_{t\le n}$, however the inputs were chosen (fixed in advance, adversarial, adaptive, non-computable):
$$L_n=-\log M_F(D_n)\ \le\ -\log\nu(D_n)+K(\nu).$$
In particular:
* (a) *x-only samplers* (Hänni's "Thm 1 (template)", for data from a function, i.e. consistent sequences). For every lower-semicomputable conditional semimeasure $P$: $L_n\le\sum_{t\le n}-\log P(y_t\mid x_t)+K(P)+O(1)$. The right side counts a repeated input every time it appears; the left side counts it once.
* (b) *Deterministic programs.* If $y_t=\varphi(x_t)$ for all $t$, then $L_n\le K(\varphi)+O(1)$.
* (c) *Weak comparators.* For every lower-semicomputable weak semimeasure $\nu$: $L_n\le-\log\nu(D_n)+K(\nu)+K(\mathrm{dom}\,D_n)+O(1)$. The term $K(\mathrm{dom}\,D_n)$ cannot be replaced by $O(1)$: on the data sets $D_k$ of Thm 3.5(iii) the excess over $-\log M^w(D_k)$ is at least $k\log\frac32-K(k)-O(1)$, while $K(\mathrm{dom}\,D_k)\le k\log3+K(k)+O(1)$. So on that family at least a fraction $\log(3/2)/\log3\approx0.37$ of the $K(\mathrm{dom}\,D)$ term is needed, asymptotically. Whether the whole term is ever needed is open (Table 4.12).

*Proof.* Thm 3.2 and Prop 5.2. (a) Prop 3.3(a): $-\log\nu_P(D_n)=\sum_{(x,y)\in D_n}-\log P(y\mid x)$, which is at most the per-query sum. (b) Prop 3.3(b). (c) Thm 3.5(ii, iii) and the bound on $K(\mathrm{dom}\,D_k)$ in the remark after Thm 3.5. $\square$

**Status of H2 as stated in the brief.**
* Correct, as Thm 6.1, for every machine law. This includes all computable laws of random total functions for any countable $Y$ (Lemma 6.5a and Prop 3.3(c)), all computable laws of random partial functions with finite label set or with computable cylinder probabilities, all x-only samplers and all deterministic programs.
* Two corrections:
  * The label sequence must be consistent. If an input reappears with a different label, $L_n=\infty$, while a sampler that draws fresh randomness at each query has finite loss. Hänni's dovetailing remark ("use different bits of randomness ... for different inputs") gives randomness per *input*, not per *query*, and that is the right reading for data from a function. For fresh noise per query, see $M_{\rm pq}$ (Prop 6.9).
  * For lower-semicomputable *weak* semimeasures an extra term is needed. It is at most $K(\mathrm{dom}\,D_n)+O(1)$ and cannot be $O(1)$ (Thm 6.1(c)).
* For general lower-semicomputable random-function laws the statement is open (Problem 3.6).
* The "any data distribution" form follows by taking expectations of the pathwise bound.
* Hänni's "Thm 1 (template)" for x-only computable samplers is therefore proved, in his setting (data from a function), with the per-input reading of the samplers' randomness.

### 6.2 Invariance (Hänni's §2.1)

**Theorem 6.2** **[proved]**.
* (a) *Universal machine.* Let $M_F$ and $M'_F$ be built as in Thm 3.2 from two universal prefix machines and two effective enumerations of function machines. Then $|\log M_F(D)-\log M'_F(D)|\le c$ for all $D$, with $c$ independent of $D$. The same holds for any two function machines whose laws each dominate all machine laws up to constants.
* (b) *Encodings.* Let $\alpha:X\to X'$ and $\beta:Y\to Y'$ be computable injections, and for $D\subseteq X\times Y$ let $D^{\alpha\beta}:=\{(\alpha(x),\beta(y)):(x,y)\in D\}$. Let $M'_F$ be SFI over $X',Y'$. Then for all $D$:
$$|\log M_F(D)-\log M'_F(D^{\alpha\beta})|\le K(\alpha,\beta)+O(1).$$
So cumulative losses on the original and the re-encoded data differ by at most $K(\alpha,\beta)+O(1)$ bits, uniformly over all data sets and all reveal orders.
* (c) The same statements hold for $W$, $M_{\rm prod}$ and $M^w$, with the same proofs.

*Proof.* (a) Each law is a machine law, so each dominates the other by Thm 3.2. (b) The inverses $\alpha^{-1},\beta^{-1}$ are partial computable (search). The machine $\omega\mapsto\beta\circ f_\omega\circ\alpha^{-1}$ on $X'$ (undefined off the range of $\alpha$) has law $\nu'$ with $\nu'(D^{\alpha\beta})=\lambda\{\beta(f_\omega(x))=\beta(y)\ \forall(x,y)\in D\}=M_F(D)$, since $\beta$ is injective. Its index is computable from indices of $\alpha,\beta$, so $M'_F(D^{\alpha\beta})\ge2^{-K(\alpha,\beta)-O(1)}M_F(D)$. Conversely the machine $\omega\mapsto\beta^{-1}\circ f'_\omega\circ\alpha$ on $X$ has law $\nu$ with $\nu(D)=M'_F(D^{\alpha\beta})$. (c) $W$: a program for $\varphi$ becomes a program for $\beta\circ\varphi\circ\alpha^{-1}$ by a prefix of length $K(\alpha,\beta)+O(1)$. $M_{\rm prod}$: transform each conditional semimeasure in the same way. $M^w$: transform weak semimeasures by $\nu'(D'):=\nu(D)$ if $D'=D^{\alpha\beta}$ and $\nu'(D'):=0$ otherwise; if $D'=D^{\alpha\beta}$ and $x'\notin\mathrm{dom}\,D'$, the extensions of $D'$ at $x'$ of the form $E^{\alpha\beta}$ have $x'=\alpha(x)$ and labels $\beta(y)$, so the one-point inequality transfers. $\square$

*Remarks.* The constant $K(\alpha,\beta)$ is not small for complex encodings: a pixel permutation of complexity comparable to the data size can change losses by up to that much (only the upper bound is proved). Non-computable encodings are not covered. "Input encoding doesn't matter much" is therefore exact up to $K(\text{encoding})+O(1)$ bits, uniformly in the data.

### 6.3 Coding-theorem bounds

**Theorem 6.3** **[proved]**. For every data set $D$:
* (a) $-\log M_F(D)\ \ge\ K(D|_T\mid T)-O(1)$ for every $T\subseteq\mathrm{dom}\,D$. In particular $M_F(D)\le2^{-K(D\mid\mathrm{dom}\,D)+O(1)}$, and $M_F(D)\le2^{-K(y\mid x)+O(1)}$ for every $(x,y)\in D$.
* (b) $-\log M_F(D)\ \le\ \min\big\{K_F(D),\ \textstyle\sum_{(x,y)\in D}K(y\mid x)\big\}+O(1)\ \le\ K(\mathrm{dom}\,D)+K(D\mid\mathrm{dom}\,D)+O(1)$.
* (c) For single points, $-\log M_F(\{(x,y)\})=K(y\mid x)\pm O(1)$.

*Proof.* (a) $P(E\mid S):=M_F(E)$ for $\mathrm{dom}\,E=S$ is lower semicomputable uniformly in $(E,S)$ and sums to at most $1$ over $E$ (consequence (b) of Def 2.1). The conditional coding theorem gives $K(E\mid S)\le-\log M_F(E)+O(1)$. Monotonicity gives $M_F(D)\le M_F(D|_T)$. (b) The first term: $M_F\ge2^{-O(1)}W\ge2^{-K_F-O(1)}$ (Thm 4.2). The second: $\mathbf m(y\mid x):=\sum_{q:V(q,x)=y}2^{-|q|}$, with $V(\cdot,x)$ the conditional prefix machine, is a lower-semicomputable conditional semimeasure with $\mathbf m(y\mid x)\ge2^{-K(y\mid x)}$; its product law is a machine law of complexity $O(1)$ (Prop 3.3(a)). The last inequality is Thm 4.2, step (5). (c) Combine (a) with $T=\{x\}$ and (b). $\square$

**Example 6.4 (the bound $M_F(D)\le2^{-K(D\mid\mathrm{dom}\,D)+O(1)}$ can be far from tight; and the example is tight)** **[proved; computed: c9(c), r8]**. Take distinct $x_1,x_2\in\{0,1\}^n$ and the "swap" data set $D:=\{(x_1,x_2),(x_2,x_1)\}$.
* (i) $K(D\mid\mathrm{dom}\,D)=O(1)$: given the set $\{x_1,x_2\}$, a constant program outputs $D$.
* (ii) $-\log M_F(D)\ge\max\{K(x_2\mid x_1),K(x_1\mid x_2)\}-O(1)$, by Thm 6.3(a) with $T=\{x_1\}$ and $T=\{x_2\}$.
* (iii) $-\log M_F(D)\le n+O(1)$ for every such pair: the machine $F(x):=x\oplus\omega_{1:|x|}$ has complexity $O(1)$, and it extends $D$ exactly when $\omega_{1:n}=x_1\oplus x_2$, which has probability $2^{-n}$ (c9(c) checks all pairs for $n\le7$). Also $K_F(D)\le K(x_1\oplus x_2)+O(1)\le n+2\log n+O(1)$ (the program $x\mapsto x\oplus z$ with $z$ built in).
* (iv) For every $x_1$ some $x_2$ has $K(x_2\mid x_1)\ge n$ (fewer than $2^n$ programs are shorter than $n$). For such pairs $-\log M_F(D)=n\pm O(1)$.

So the data are trivial *as a set*, but each label is a random $n$-bit string *given its own input*: a function cannot see the other input. This does **not** separate SFI from history-aware prediction. A lower-semicomputable history-aware predictor, for instance the universal chronological semimeasure $\xi$ of Prop 7.2, shown $x_1$ first must predict the label $x_2$ before seeing it, and $y\mapsto\xi(y\Vert x)$ is a lower-semicomputable semimeasure given $x$, so it pays at least $K(x_2\mid x_1)-O(1)$ on that step; in the other order it pays at least $K(x_1\mid x_2)-O(1)$. Separations between SFI and history-aware predictors are the history track's chain and skipped strings (history Thms 2.1, 2.2) and the examples track's cyclic permutation (H5).

The two-sided bound of Thm 6.3 is therefore the correct general form. Its left side is a maximum over subsets $T$, not just $T=\mathrm{dom}\,D$. Neither side is tight in general, and a two-sided characterisation of $-\log M_F(D)$ up to $O(1)$ is **[open]** (other than the tautology $-\log M_F(D)=\min_\nu[K(\nu)-\log\nu(D)]\pm O(1)$ over machine laws $\nu$).

### 6.4 Merging and mistake bounds

**Lemma 6.5a (laws of random total functions)** **[proved]**. Let $Y$ be countable and $\nu$ a lower-semicomputable law of a random total function, i.e. $\nu(D)=\sum_y\nu(D+(x,y))$ for all $D$ and $x\notin\mathrm{dom}\,D$, with $\nu(\emptyset)=1$. Then $\nu$ is computable, uniformly in an index of a lower approximation. Conversely every computable such $\nu$ is a machine law (Prop 3.3(c), last clause). So for any countable $Y$, the machine laws of random total functions are exactly the computable laws of random total functions.

*Proof.* By induction on $|D|$. $\nu(\emptyset)=1$ is computable. If $\nu(D)$ is computable, then $\nu(D+(x,y))=\nu(D)-\sum_{y'\ne y}\nu(D+(x,y'))$ is a computable real minus a lower-semicomputable sum (possibly infinite), hence upper semicomputable; it is also lower semicomputable, hence computable. The induction is uniform. $\square$

(`notes.md` stated this for finite $Y$ only. The history track's §1.2 and the context track's Cor 5.2(c) cite the finite case; both extend to countable $Y$.)

**Theorem 6.5 (merging)** **[proved; finite analogue computed exactly, including the worst adaptive selection rule: c4 part (3), r6]**. Let $\nu$ be a machine law that is the law of a random *total* function (Lemma 6.5a). Let $F\sim\nu$. Inputs are chosen by any measurable rule $x_t=s_t(H_{t-1},\xi_t)$, where $H_{t-1}=(x_1,y_1,\dots,x_{t-1},y_{t-1})$, $(\xi_t)$ is independent of $F$, and $s_t$ is arbitrary (possibly non-computable). Put $y_t:=F(x_t)$ and
$$d_t:=\mathrm{KL}\big(\nu(\cdot\mid D_{t-1},x_t)\ \big\|\ M_F(\cdot\mid D_{t-1},x_t)\big)\quad\text{(bits)},\qquad \nu(y\mid D,x):=\nu(D+(x,y))/\nu(D).$$
Then for every $n$:
$$\textstyle\sum_{t\le n}\mathbb E\,d_t=\mathbb E\log\frac{\nu(D_n)}{M_F(D_n)}\le K(\nu).$$
Consequently $\sum_{t\ge1}\mathbb E\,d_t\le K(\nu)$, $d_t\to0$ almost surely, and $\sum_t\mathbb E\,\|\nu(\cdot\mid D_{t-1},x_t)-M_F(\cdot\mid D_{t-1},x_t)\|_1^2\le2\ln2\cdot K(\nu)$.

*Proof.* *Posterior lemma:* given $H_{t-1}=h$ and $\xi$, the conditional law of $F$ is $\nu(\cdot\mid F\supseteq D_h)$. Indeed $\{H_{t-1}=h\}$ is the intersection of $\{F\supseteq D_h\}$ with an event that depends on $\xi$ only (that the rule, fed the labels of $h$, produces the inputs of $h$), and $\xi$ is independent of $F$. Hence $P(y_t=y\mid H_{t-1},\xi)=\nu(y\mid D_{t-1},x_t)$. Let $Z_t:=\log\frac{\nu(y_t\mid D_{t-1},x_t)}{M_F(y_t\mid D_{t-1},x_t)}$. If $x_t\in\mathrm{dom}\,D_{t-1}$, both conditionals are the point mass at the stored label and $Z_t=d_t=0$. Otherwise $\mathbb E[Z_t\mid H_{t-1},\xi]=d_t\ge0$ ($d_t\ge0$ also when the second argument is a sub-probability, by Jensen: $\sum p\log(q/p)\le\log\sum q\le0$).
*Integrability* (referee m4). With $p=\nu(\cdot\mid D_{t-1},x_t)$ and $q=M_F(\cdot\mid D_{t-1},x_t)$, $\mathbb E[Z_t^-\mid H_{t-1},\xi]=\sum_yp(y)\max(0,\log\frac{q(y)}{p(y)})\le\log_2e\sum_yp(y)\big(\frac{q(y)}{p(y)}-1\big)^+\le\log_2e$, using $\log_2u\le(u-1)\log_2e$ (c11(c) checks the inequality numerically). The sum $\sum_{t\le n}Z_t=\log\frac{\nu(D_n)}{M_F(D_n)}$ is at most $K(\nu)$ on every path (Thm 3.2). So $\sum_tZ_t^+\le K(\nu)+\sum_tZ_t^-$, every $\mathbb EZ_t^+$ is finite, and linearity of expectation applies. Taking expectations (tower property) gives the identity and the bound. Almost-sure convergence: $\sum_td_t$ has finite expectation, so it is finite a.s. Pinsker's inequality, for a sub-probability $q$ extended by one extra atom carrying its defect, gives $\|p-q\|_1^2\le2\ln2\cdot\mathrm{KL}(p\|q)$ in bits. $\square$

*Remarks.*
* This is the function analogue of Solomonoff's convergence theorem (R. J. Solomonoff, "Complexity-based induction systems: comparisons and convergence theorems", *IEEE Trans. Inf. Theory* 24(4):422–432, 1978) **[known (unverified)]**.
* The input rule may be adversarial but must not see $F$ beyond the past labels. If it does see $F$ (for example, it chooses inputs whose label is $1$), the expected-KL statement can fail, because the conditional law of $y_t$ is no longer $\nu(\cdot\mid D_{t-1},x_t)$ (r6 gives an instance: summed KL $12.5$ against the bound $1$). The pathwise bound $L_n\le-\log\nu(D_n)+K(\nu)$ still holds. The history track's Thm 3.6 quantifies the excess by directed information.
* With finite horizon $n$ the worst adaptive rule matters. With all of a finite $X$ queried the total is the same for every rule, because $\log\nu(D_n)/M_F(D_n)$ depends only on the final set (c4 shows both).

**Corollary 6.6 (mistake bound)** **[proved]**. Let $\varphi$ be partial computable, and let $x_1,x_2,\dots\in\mathrm{dom}\,\varphi$ be any inputs, with $y_t=\varphi(x_t)$. The number of $t$ with $M_F(\varphi(x_t)\mid D_{t-1},x_t)\le\tfrac12$ is at most $K(\varphi)+O(1)$. So the predictor $\hat y_t:=\arg\max_yM_F(y\mid D_{t-1},x_t)$ makes at most $K(\varphi)+O(1)$ mistakes on every input sequence.

*Proof.* Each such $t$ adds at least $1$ bit to $L_n\le K(\varphi)+O(1)$ (Thm 6.1(b)). If $M_F(\varphi(x_t)\mid\cdot)>\tfrac12$, then $\varphi(x_t)$ is the unique maximiser. The maximum exists because only finitely many labels have conditional above any positive threshold. $\square$

This is the halving-algorithm bound $\log|H|$ (N. Littlestone, "Learning quickly when irrelevant attributes abound", *Machine Learning* 2:285–318, 1988; for enumerable classes J. M. Barzdin, R. V. Freivalds, "On the prediction of general recursive functions", *Soviet Math. Dokl.* 13:1224–1228, 1972) **[known; bibliographic data of Barzdin–Freivalds from snippets; contents unverified]**, with $K(\varphi)$ in place of $\log|H|$. The predictor is not computable (Prop 7.3).

### 6.5 Online-to-batch: SFI as supervised learning (H7)

**Theorem 6.7** **[proved; finite analogues computed: r9 for (a), c7 and r7 for (b)]**. Let $\pi$ be any probability distribution on $X$ (it need not be computable), and let $x_1,x_2,\dots$ be i.i.d. from $\pi$.
* (a) *Deterministic labels.* Let $\varphi$ be partial computable with $\pi(\mathrm{dom}\,\varphi)=1$ and $y_t=\varphi(x_t)$. Put $Q_t(\cdot\mid x):=M_F(\cdot\mid D_t,x)$, $\bar Q_n:=\frac1n\sum_{t=0}^{n-1}Q_t$, and $R(Q):=\mathbb E_{x\sim\pi}[-\log Q(\varphi(x)\mid x)]$. Then
$$\textstyle\sum_{t=0}^{n-1}\mathbb E\,R(Q_t)\le K(\varphi)+O(1),\qquad\mathbb E\,R(\bar Q_n)\le\frac{K(\varphi)+O(1)}n,\qquad \mathbb E\,\pi\{x:\arg\max_y\bar Q_n(y\mid x)\ne\varphi(x)\}\le\frac{K(\varphi)+O(1)}n .$$
* (b) *Noisy labels, time-stamped inputs.* Let $P(\cdot\mid x)$ be any conditional probability (possibly non-computable), and let $y_t\sim P(\cdot\mid x_t)$ independently given the inputs. Run SFI on the stamped inputs $\tilde x_t:=\langle x_t,t\rangle$ ($\langle\cdot,\cdot\rangle$ a computable bijection $X\times\mathbb N\to X$), with data $\tilde D_t$. Put $q_t(\cdot\mid x):=M_F(\cdot\mid\tilde D_{t-1},\langle x,t\rangle)$ and $\bar q_n:=\frac1n\sum_{t=1}^nq_t$. Then for every lower-semicomputable conditional semimeasure $\nu$:
$$\mathbb E\,\mathbb E_{x\sim\pi}\mathrm{KL}\big(P(\cdot\mid x)\,\|\,\bar q_n(\cdot\mid x)\big)\ \le\ \frac{K(\nu)+O(1)}n+\mathbb E_{x\sim\pi}\mathrm{KL}\big(P(\cdot\mid x)\,\|\,\nu(\cdot\mid x)\big).$$
In particular the bound is $(K(P)+O(1))/n$ if $P$ is lower semicomputable (hence computable, being a probability with countable $Y$, by the argument of Lemma 6.5a). The expected excess 0–1 risk of $\arg\max\bar q_n$ over the Bayes classifier is at most $\sqrt{2\ln2\cdot\text{(right side)}}$.
* (c) *Noisy labels, frozen per input.* Let $F$ have the product law of a computable conditional probability $P$ (one draw per input), and $y_t=F(x_t)$. Then $\sum_{t\le n}\mathbb E\,d_t\le K(P)+O(1)$ with $d_t$ as in Thm 6.5. This is Thm 6.5 for this law, and it holds for any input rule that sees only the past, not only i.i.d. inputs.

*Proof.* (a) $x_{t+1}$ is independent of $D_t$ and has law $\pi$, so $\mathbb E\,R(Q_t)=\mathbb E[-\log M_F(y_{t+1}\mid D_t,x_{t+1})]$. Summing over $t<n$ gives $\mathbb E\,L_n\le K(\varphi)+O(1)$ (Thm 6.1(b); repeated inputs contribute $0$). $-\log$ is convex, so $R(\bar Q_n)\le\frac1n\sum_tR(Q_t)$. For the 0–1 claim: if $\bar Q_n(\varphi(x)\mid x)>\tfrac12$, then $\varphi(x)$ is the unique maximiser, and by Markov's inequality $\pi\{\bar Q_n(\varphi(x)\mid x)\le\tfrac12\}\le R(\bar Q_n)$.

(b) Stamped inputs are distinct, so given the past the label $y_t$ has law $P(\cdot\mid x_t)$. As in Thm 6.5, $\sum_{t\le n}\mathbb E\,\mathrm{KL}(P(\cdot\mid x_t)\|q_t(\cdot\mid x_t))=\mathbb E\log\frac{\prod_tP(y_t\mid x_t)}{M_F(\tilde D_n)}$. The product law $\tilde\nu(y\mid\langle x,t\rangle):=\nu(y\mid x)$ is a machine law with $K(\tilde\nu)\le K(\nu)+O(1)$, so $M_F(\tilde D_n)\ge2^{-K(\nu)-O(1)}\prod_t\nu(y_t\mid x_t)$ and the right side is at most $K(\nu)+O(1)+\sum_t\mathbb E\log\frac{P(y_t\mid x_t)}{\nu(y_t\mid x_t)}=K(\nu)+O(1)+n\,\mathbb E_\pi\mathrm{KL}(P\|\nu)$. Since $x_t\sim\pi$ is independent of $\tilde D_{t-1}$, the $t$-th term on the left equals $\mathbb E\,\mathbb E_{x\sim\pi}\mathrm{KL}(P(\cdot\mid x)\|q_t(\cdot\mid x))$. KL is convex in its second argument, which gives the bound for $\bar q_n$. 0–1: with $y^*$ the Bayes label and $\hat y=\arg\max\bar q_n$, $P(y^*\mid x)-P(\hat y\mid x)\le[P(y^*)-\bar q(y^*)]+[\bar q(\hat y)-P(\hat y)]\le\|P(\cdot\mid x)-\bar q_n(\cdot\mid x)\|_1$. Then apply Pinsker (as in Thm 6.5) and Jensen.

(c) The product law of a computable total $P$ is a machine law (Prop 3.3(a)) and a law of a random total function. $\square$

The first inequality in (a) is the cumulative form; the batch statements are for the Cesàro average $\bar Q_n$, not for the last posterior predictive $Q_n$ (Prop 6.10, Remark 6.11).

**Proposition 6.8 (random-function SFI cannot model fresh label noise)** **[proved; computed: c5, r9(b)]**. Suppose $\pi(x_0)=\alpha>0$ and $P(\cdot\mid x_0)$ gives positive probability to two labels. Draw the pairs $(x_t,y_t)$ i.i.d. from $\pi\times P$ (fresh label at every draw), and run a predictor of the form $\nu(\cdot\mid D,x)$ for a weak semimeasure $\nu$ on data sets, with the repeated-input convention of §1. This covers $M_F$, $W$, $M_{\rm prod}$ and $M^w$, in both the semimeasure and the normalised convention. Then $\Pr[D_n\text{ inconsistent}]>0$ for every $n\ge2$, so $\mathbb E\,L_n=\infty$. Moreover $\Pr[D_n\text{ consistent}]\le(1-\alpha)^n+p_{\max}^{-1}(1-\alpha+\alpha p_{\max})^n\to0$, where $p_{\max}:=\max_yP(y\mid x_0)<1$.

*Proof.* Two draws of $x_0$ with different labels have positive probability, and then the second of them gets probability $0$ (the stored label has probability $1$). For the rate: the labels at $x_0$ agree with probability $(1-\alpha)^n+\sum_{j\ge1}\binom nj\alpha^j(1-\alpha)^{n-j}\sum_yP(y\mid x_0)^j$, and $\sum_yP(y\mid x_0)^j\le p_{\max}^{j-1}$. $\square$

Since $X$ is countable, $\pi$ is purely atomic. So the brief's H7 ("for any input distribution and computable conditional law $P(y\mid x)$, SFI's cumulative expected log loss exceeds that of $P$ by at most $K(P)+O(1)$") holds for $M_F$ for all $n\ge2$ exactly when $P(\cdot\mid x)$ is a point mass for every $x$ with $\pi(x)>0$. In that case $\varphi(x):=$ the label with $P(\varphi(x)\mid x)>\tfrac12$ is partial computable with $K(\varphi)\le K(P)+O(1)$ and $\pi(\mathrm{dom}\,\varphi)=1$, which is Thm 6.7(a). This is not a quirk of the proof: random-function SFI models the label as a *function* of the input, and a source with fresh noise is not a random function of the input. Three repairs: time stamps (Thm 6.7(b)), frozen noise (Thm 6.7(c)), and per-query mixing (Prop 6.9). In practice inputs rarely repeat exactly; in theory one repetition with a different label is enough for infinite loss.

**Proposition 6.9 (the per-query mixture: H7 under fresh noise)** **[proved; computed: c7, r7]**.
* (a) $M_{\rm pq}$ (Def 4.1) is a lower-semicomputable chronological semimeasure: $M_{\rm pq}(\varepsilon\Vert\varepsilon)\le1$ and $\sum_yM_{\rm pq}(y_{1:n}y\Vert x_{1:n}x)\le M_{\rm pq}(y_{1:n}\Vert x_{1:n})$ for every $x$. It depends only on the multiset of pairs. It equals $M_{\rm prod}(D_n)$ on sequences with distinct inputs. On consistent sequences with repeated inputs $M_{\rm pq}\le M_{\rm prod}(D_n)$, often strictly. On inconsistent sequences $M_{\rm pq}>0$ is possible, while $M_{\rm prod}$ gives $0$.
* (b) *Pathwise regret.* On every sequence, consistent or not: $-\log M_{\rm pq}(y_{1:n}\Vert x_{1:n})\le\sum_{t\le n}-\log P(y_t\mid x_t)+K(P)$ for every lower-semicomputable conditional semimeasure $P$.
* (c) *H7 under fresh noise.* Let $(x_t,y_t)$ be i.i.d. from $\pi\times P$, with $\pi$ arbitrary and $P$ any conditional probability. Let $q_t(\cdot\mid x):=M_{\rm pq}(y_{<t}\,\cdot\Vert x_{<t}x)/M_{\rm pq}(y_{<t}\Vert x_{<t})$ and $\bar q_n:=\frac1n\sum_{t\le n}q_t$. Then for every lower-semicomputable conditional semimeasure $\nu$:
$$\textstyle\sum_{t\le n}\mathbb E\,\mathbb E_{x\sim\pi}\mathrm{KL}(P(\cdot\mid x)\|q_t(\cdot\mid x))\le K(\nu)+n\,\mathbb E_\pi\mathrm{KL}(P\|\nu),\qquad \mathbb E\,\mathbb E_\pi\mathrm{KL}(P\|\bar q_n)\le\frac{K(\nu)}n+\mathbb E_\pi\mathrm{KL}(P\|\nu).$$
For lower-semicomputable $P$ the right sides are $K(P)$ and $K(P)/n$.
* (d) *Relation to stamped SFI.* On stamped inputs, the set mixture of the stamp-ignoring product laws $\tilde P_i(y\mid\langle x,t\rangle):=P_i(y\mid x)$ equals $M_{\rm pq}$ exactly; so $M_F(\tilde D_n)\ge2^{-O(1)}M_{\rm pq}(y_{1:n}\Vert x_{1:n})$ (Prop 3.3(a,d), Thm 3.2). Stamped SFI dominates the per-query mixture.

*Proof.* (a) Each term $\prod_tP_i(y_t\mid x_t)$ is chronological, because $\sum_yP_i(y\mid x)\le1$; mixtures with $\sum_i\mathbf m(i)\le1$ preserve this; lower semicomputability is clear. The product is symmetric in the pairs. With distinct inputs it is the definition of $M_{\rm prod}$. On a consistent sequence with repeats, the extra factors are at most $1$. The uniform product law gives positive mass to every sequence. (c7 checks (a) exhaustively on a 133-law class: 777 chronological inequalities, 216 permutation classes, 624 consistent sequences with 546 strict inequalities at repeats.) (b) $\mathbf m(i)\ge2^{-K(i)}$ for an index $i$ of $P$. (c) The predictor's product telescopes: $\prod_tq_t(y_t\mid x_t)=M_{\rm pq}(y_{1:n}\Vert x_{1:n})/M_{\rm pq}(\varepsilon\Vert\varepsilon)\ge M_{\rm pq}(y_{1:n}\Vert x_{1:n})$. Given the past, $y_t\sim P(\cdot\mid x_t)$ and $x_t\sim\pi$ is independent of the past, so $\mathbb E[\log\frac{P(y_t\mid x_t)}{q_t(y_t\mid x_t)}\mid\text{past}]=\mathbb E_{x\sim\pi}\mathrm{KL}(P(\cdot\mid x)\|q_t(\cdot\mid x))\ge0$. Summing, $\sum_t\mathbb E\,\mathbb E_\pi\mathrm{KL}(P\|q_t)\le\mathbb E\log\frac{\prod_tP(y_t\mid x_t)}{M_{\rm pq}(y_{1:n}\Vert x_{1:n})}\le K(\nu)+\sum_t\mathbb E\log\frac{P(y_t\mid x_t)}{\nu(y_t\mid x_t)}$ by (b), and the last sum is $n\,\mathbb E_\pi\mathrm{KL}(P\|\nu)$. (Integrability as in Thm 6.5.) Convexity of KL in its second argument gives the averaged bound. (d) For distinct stamped inputs the set mixture is $\sum_i\mathbf m(i)\prod_tP_i(y_t\mid x_t)$; c7(e) checks the identity exactly on all 1554 sequences of length at most 4, inconsistent ones included. $\square$

[computed: c7(d), a fresh-noise source on 3 inputs with $\pi=(\frac12,\frac13,\frac16)$: expected and pathwise regret of $M_{\rm pq}$ stay below $-\log_2w_P=10.27$ bits for $n\le7$, the telescoping identity holds to $10^{-9}$, and the probability that the per-input data set is still consistent falls from $0.85$ ($n=2$) to $0.16$ ($n=7$). r7 shows the same on a 27-law class up to $n=20$.]

So H7's regret form holds under fresh noise for the per-query mixture, with no stamps. The history track (its claim 4.9) reads operator induction the same way; the universal chronological semimeasure dominates $M_{\rm pq}$ (Prop 7.2).

**Proposition 6.10 (the expected risk of the posterior predictive need not decrease)** **[proved; computed: c11(a), r12]**. Let $X=\{a,b\}$ with $\pi$ uniform, target $\varphi\equiv0$, and a Bayes mixture over three total functions: $\varphi$ with prior weight $w$ and $(1,0)$, $(0,1)$ with weight $(1-w)/2$ each. Let $r_t:=\mathbb E\,R(Q_t)$ be the expected log risk of the posterior predictive after $t$ i.i.d. samples. Then
$$r_0=-\log_2\tfrac{1+w}2,\qquad r_1=\tfrac12\log_2\tfrac{1+w}{2w},\qquad r_t=2^{1-t}r_1\ (t\ge1).$$
So $r_1>r_0$ whenever $(1+w)^3>8w$, for example for all $w\le\frac15$. For $w=\frac1{16}$: $r_0=0.912$, $r_1=1.544$ bits. The cumulative sum $\sum_tr_t$ increases to $-\log_2w$.

*Proof.* Before any data, the predictive probability of label $0$ at either input is $w+\frac{1-w}2=\frac{1+w}2$. After seeing $(a,0)$, the consistent hypotheses are $\varphi$ and $(0,1)$, and the predictive probability of $0$ at $b$ is $\frac{w}{w+(1-w)/2}=\frac{2w}{1+w}$; symmetrically after $(b,0)$. After $t\ge1$ samples, both inputs have been seen with probability $1-2^{1-t}$ (risk $0$) and exactly one with probability $2^{1-t}$ (risk $\frac12\log\frac{1+w}{2w}$, since the unseen input has probability $\frac12$). $r_1>r_0$ is equivalent to $\frac{(1+w)^3}{8w}>1$. The cumulative sum is $r_0+2r_1=\log_2\frac1w$ in the limit. $\square$

This is a finite Bayes mixture, not $M_F$. It shows that "more data never hurts in expectation" is false for Bayes predictors with a fixed target, so nothing of that kind follows from the general theory; whether it fails for $M_F$ on some computable target is not established. The context track's Remark 2.11 makes the same point for sampling without replacement.

**Remark 6.11 (last iterate versus leave-one-out)** **[identity proved; computed: c11(b); bound open]**. With i.i.d. inputs, exchangeability of $x_1,\dots,x_{n+1}$ gives
$$\mathbb E\,R(Q_n)=\mathbb E\Big[\frac1{n+1}\sum_{i=1}^{n+1}-\log Q_{D_{n+1}\setminus\{i\}}\big(\varphi(x_i)\mid x_i\big)\Big],$$
the expected leave-one-out log loss on $n+1$ samples (a held-out input that also occurs among the others costs $0$). c11(b) checks the identity on 50 random finite mixtures (error $2\cdot10^{-15}$). So the question "is $\mathbb E\,R(Q_n)\le(K(\varphi)+O(1))/(n+1)$ for $M_F$?" is a leave-one-out question, the log-loss analogue of the context track's Conjecture 2.11. It is **[open]**. In the referee's 300 random finite instances (r12) the largest value of $(n+1)r_n/K$ was $0.87$.

### 6.6 Comparison with Occam, PAC-Bayes, MDL and expert-advice bounds

* **Occam's razor** (A. Blumer, A. Ehrenfeucht, D. Haussler, M. Warmuth, "Occam's razor", *Inf. Process. Lett.* 24:377–380, 1987) **[known (unverified)]**. The description-length form is easy to prove directly **[proved]**: for i.i.d. $x_t\sim\pi$ and deterministic $\varphi$, with probability at least $1-\delta$ every program $p\in\mathrm{dom}\,V$ consistent with $D_n$ has $\pi\{x:\varphi_{V(p)}(x)\ne\varphi(x)\}\le(|p|\ln2+\ln(1/\delta))/n$. (Put $\varepsilon_p:=(|p|\ln2+\ln\frac1\delta)/n$; a fixed $p$ with error above $\varepsilon_p$ is consistent with probability at most $(1-\varepsilon_p)^n\le2^{-|p|}\delta$; sum over $p$ by Kraft.) Applied to the shortest consistent program, whose length is $K_F(D_n)\le K(\varphi)+O(1)$, this gives the Kolmogorov version a high-probability 0–1 rate $(K(\varphi)\ln2+\ln\frac1\delta+O(1))/n$. Thm 6.7(a) gives SFI the same rate in expectation, for log loss as well as 0–1 loss. So for deterministic targets the two versions have the same learning rate, although their code lengths on a given data set can differ (Thm 4.7). They differ under noise: the Occam argument needs consistency, while SFI has the resolvability bound of Thm 6.7(b), which needs time stamps, and $M_{\rm pq}$ has it with no stamps (Prop 6.9).
* **PAC-Bayes** (D. McAllester, "Some PAC-Bayesian theorems", *Machine Learning* 37:355–363, 1999) **[known (unverified)]**: bounds of the form $\mathbb E_QR\le\mathbb E_Q\hat R+\sqrt{(\mathrm{KL}(Q\|\text{prior})+\ln(n/\delta))/(2n)}$, up to the version, with faster $\mathrm{KL}/n$ rates in the realisable case. With prior $2^{-K}$ and posterior concentrated on the target, $\mathrm{KL}(Q\|\text{prior})\approx K(\varphi)\ln2$, matching the rates above. The difference is in kind: PAC-Bayes bounds the risk of a randomised classifier with high probability; Thm 6.7 bounds the expected log risk of the averaged Bayes predictive.
* **MDL and the index of resolvability** (A. Barron, T. Cover, "Minimum complexity density estimation", *IEEE Trans. Inf. Theory* 37(4):1034–1054, 1991; A. Barron, "Information-theoretic characterization of Bayes performance and the choice of priors in parametric and nonparametric problems", *Bayesian Statistics* 6, 1998) **[known (unverified)]**. Thm 6.7(b) and Prop 6.9(c) are the Cesàro-average resolvability bound $\min_\nu[L(\nu)/n+D(P\|\nu)]$ for the Bayes mixture, with code length $L(\nu)=K(\nu)$, in the conditional (regression) setting, for every input distribution. For random-function SFI it needs time stamps; per-query mixing gives it directly.
* **Prediction with expert advice** (V. Vovk, "Aggregating strategies", COLT 1990; N. Cesa-Bianchi, G. Lugosi, *Prediction, Learning, and Games*, Cambridge 2006) **[known (unverified)]**. Under log loss the Bayes mixture has regret $\ln(1/w_i)$ against expert $i$ on every sequence. Thm 6.1 is this fact with the experts being machine laws: each expert predicts with its own posterior given past labels, so shared randomness is allowed.
* **Online-to-batch conversion** (N. Littlestone, "From on-line to batch learning", COLT 1989; N. Cesa-Bianchi, A. Conconi, C. Gentile, "On the generalization ability of on-line learning algorithms", *IEEE Trans. Inf. Theory* 50(9):2050–2057, 2004) **[known (unverified)]**. Thm 6.7 uses only the elementary averaging form, proved above. The context track's Prop 2.9 uses the same exchangeability argument; the paper should give it once.
* **Supervised learning in Hutter's framework.** Hutter's book treats "supervised learning from examples" as one of the problem classes of the AIXI model **[known: M. Hutter, *Universal Artificial Intelligence*, Springer 2005, the chapter on important problem classes (chapter and section numbers unverified; snippets of arXiv cs/0004001 confirm that supervised learning is among the classes treated); content unverified]**. That is prior work for §6.7 and should be checked before the paper claims novelty for the framing.

### 6.7 In what sense SFI is "ideal supervised learning"

What is established:
1. SFI is the Bayes predictor for the prior "a random lower-semicomputable labeller": machine laws $\nu_{T_i}$ weighted by $\mathbf m(i)\ge2^{-K(i)}$ (Thm 3.2, remark). It is universal for that class pathwise: on every consistent data sequence, however the inputs are chosen, its cumulative log loss exceeds that of any machine law $\nu$ by at most $K(\nu)$ (Thm 6.1).
2. In the standard supervised model (i.i.d. inputs from an arbitrary, even non-computable distribution; labels a computable function of the input), its averaged predictor has expected log risk at most $(K(\varphi)+O(1))/n$, and the same 0–1 rate (Thm 6.7(a)). With noise frozen per input, the cumulative bound $K(P)+O(1)$ holds (Thm 6.7(c)); with fresh noise, it holds on time-stamped inputs (Thm 6.7(b)) and for the per-query mixture (Prop 6.9). This is the Occam rate with Kolmogorov complexity in place of $\log|H|$, with no union bound and no confidence parameter. For non-computable label laws the bound becomes the resolvability bound.
3. Inputs are never predicted. The input distribution may be arbitrary and complex at no cost. (Sequence induction on $(x,y)$ streams must also predict the $x$'s; see the history track.)

Where the analogy breaks:
* *Loss.* The guarantees are for log loss on labels. 0–1 bounds follow: $K/n$ for deterministic labels and $\sqrt{K/n}$ excess risk with noise (Thm 6.7). SFI is a Bayes mixture, not an empirical-risk minimiser. Its Kolmogorov counterpart (the shortest consistent program) is the Occam learner, with the same rate for deterministic targets (§6.6) but longer code lengths (Thm 4.7).
* *Averaged, not last, predictor.* The batch bounds are for the Cesàro average. For Bayes mixtures the expected risk of the last posterior predictive need not decrease with $n$ (Prop 6.10); an $O(K/n)$ bound for it is open (Remark 6.11).
* *Function semantics.* SFI assumes that the label is a function of the input. Raw i.i.d. data with fresh label noise make its loss infinite (Prop 6.8).
* *Computability.* $M_F$ is lower semicomputable but not computable, and so are its predictions (Prop 7.3). It is an ideal reference, not an algorithm. Time-bounded and circuit versions are treated by the context track.
* *Constants.* All bounds hold up to the machine-dependent constant in $K$, which can be large; encodings cost $K(\text{encoding})$ (Thm 6.2).
* *Distribution shift.* The batch guarantees are for test inputs from the training distribution. On inputs that are rare or absent in training no guarantee follows (H8, context track).
* *Comparator class.* The comparators are random functions that do not see the history. Predictors that use the list of past inputs are not dominated: the history track's chain and skipped strings (history Thms 2.1, 2.2) and the examples track's cyclic permutation give simple history-aware predictors with loss $0$ against unbounded SFI loss. (Example 6.4 does *not* show this; see the discussion there.)

---

## 7. Further foundational points

**Proposition 7.1 (sequence induction is SFI on initial segments)** **[proved]**. Take $X=\mathbb N$ and $\{0,1\}\subseteq Y$. Let $M$ be the universal monotone semimeasure on binary sequences, $M(x)=\lambda\{\omega:U_{\rm mon}(\omega)\sqsupseteq x\}$ for a universal monotone machine (Zvonkin–Levin 1970; Li–Vitányi 2008 §4.5) **[known (unverified section)]**. For $x\in\{0,1\}^n$ let $D_x:=\{(i,x_{i+1}):i<n\}$. Then
$$2^{-O(1)}M(x)\ \le\ M_F(D_x)\ \le\ 2^{O(1)}M(x).$$
Hence on binary sequences presented in order, the cumulative losses of SFI and of Solomonoff induction differ by $O(1)$ for all $n$.

*Proof.* ($\ge$) $T_1:=\{(i,w,b):U_{\rm mon}(w)\text{ has length}>i\text{ and bit }i+1\text{ equal to }b\}$ is a function machine with $\nu_{T_1}(D_x)=M(x)$; apply Thm 3.2. ($\le$) Let $T_2$ be the monotone machine that, on tape $\omega$, outputs $f_\omega(0),f_\omega(1),\dots$ in order, as long as each value is found (by enumerating $T_U$ along prefixes of $\omega$) and lies in $\{0,1\}$. Its output extends $x$ exactly when $f_\omega\supseteq D_x$, so its output semimeasure at $x$ is $M_F(D_x)$, and $M$ dominates it. $\square$

So SFI generalises Solomonoff induction. Prop 7.2 shows that it is in turn dominated by universal prediction with side information.

**Proposition 7.2 (relation to universal prediction with side information)** **[proved]**. A *chronological semimeasure* (Hutter's $\rho(y_{1:n}\Vert x_{1:n})$, with our inputs as his "actions" and our labels as his "percepts") is a map $\rho\ge0$ on pairs of equal-length finite sequences with $\rho(\varepsilon\Vert\varepsilon)\le1$ and $\sum_{y}\rho(y_{1:n}y\Vert x_{1:n}x)\le\rho(y_{1:n}\Vert x_{1:n})$ for every $x$.
* (a) *Universal element.* There is a lower-semicomputable chronological semimeasure $\xi$ with $\xi\ge2^{-K(\rho)}\rho$ for every lower-semicomputable chronological semimeasure $\rho$.
* (b) $\rho_F(y_{1:n}\Vert x_{1:n}):=M_F(D_n)$ if the sequence is consistent and $0$ otherwise is a lower-semicomputable chronological semimeasure. Hence $\xi(y_{1:n}\Vert x_{1:n})\ge2^{-O(1)}M_F(D_n)$: the history-aware universal predictor is never worse than SFI by more than a constant, on any sequence and in any order. Likewise $\xi\ge2^{-O(1)}M_{\rm pq}$ (Prop 6.9(a)).
* (c) Call $\rho$ *order-free* if $\rho(y_{1:n}\Vert x_{1:n})$ depends only on the set $D_n$ and vanishes on inconsistent sequences. Order-free lower-semicomputable chronological semimeasures correspond exactly to lower-semicomputable weak function semimeasures, via $\rho(y_{1:n}\Vert x_{1:n})=\nu(D_n)$. So the universal order-free one is $M^w$, not $M_F$. $M_F$ is universal for the smaller class of order-free environments that are machine laws.
* (d) *Identification.* The history track defines SFI$^{\rm hist}$ as SFI whose hypotheses see the list of previous inputs, with law $M_H$, and proves that $M_H$ is a lower-semicomputable chronological semimeasure that dominates every one (history `notes.md` Lemma 4.1, Thm 4.2, Cor 4.3; its `notes-final.md` keeps these numbers). Since $\xi$ and $M_H$ each dominate the other, $2^{-c}\xi\le M_H\le2^c\xi$. That they also agree with Hutter's universal chronological semimeasure (M. Hutter, *Universal Artificial Intelligence*, Springer 2005, ch. 5) is **[known (unverified)]**; nothing here depends on it.

*Proof.* (a) The trimming of Thm 3.4, with data sets replaced by pairs $(x_{1:n},y_{1:n})$ and the one-point inequality replaced by the chronological inequality. Let $\phi_i$ enumerate all lower-semicomputable maps from such pairs to $[0,1]$. At stage $t$ use the finite universe $U_t$ of pairs of length at most $t$ whose entries are among the first $t$ strings, and define $\phi'_{i,t}$ on $U_t$ (and $0$ outside) by decreasing $n$: $\phi'_{i,t}(x_{1:n},y_{1:n}):=\max\{\phi_{i,t}(x_{1:n},y_{1:n}),\ \max_{x\le t}\sum_{y\le t}\phi'_{i,t}(x_{1:n}x,y_{1:n}y)\}$. Freeze if $\phi'_{i,t}(\varepsilon,\varepsilon)>1$. Exactly as in Thm 3.4: $\phi'_{i,t}$ is nondecreasing in $t$ and satisfies the chronological inequality everywhere; its limit $\nu_i$ is a chronological semimeasure by monotone convergence; and if $\phi_i$ is already a chronological semimeasure, induction from the longest sequences gives $\phi_{i,t}\le\phi'_{i,t}\le\phi_i$, so $\nu_i=\phi_i$. Put $\xi:=\sum_i\mathbf m(i)\nu_i$. (b) Lower semicomputability is clear. If $x_n\notin\{x_{<n}\}$, the chronological inequality is the weak inequality for $M_F$. If $x_n=x_s$ for some $s<n$, only $y_n=y_s$ gives a non-zero term, and that term equals $\rho_F(y_{<n}\Vert x_{<n})$. Apply (a). (c) The same computation in both directions: an order-free $\rho$ defines $\nu(D):=\rho$ of any enumeration of $D$, and the chronological inequality at a new input is the weak inequality. (d) Both are universal in the class, and each belongs to it. $\square$

The converse of (b) fails: the history track's chain and skipped strings, and its sandwich theorems, measure the gap. Hänni's conjecture H4 (SFI with oracle access to past inputs matches $\xi$) is the history track's Cor 4.3.

**Proposition 7.3 (computability)** **[proved]**.
* (a) $M_F(D)$ is lower semicomputable uniformly in $D$, and $M_F(D)>0$ for every $D$.
* (b) $M_F$ is not computable.
* (c) Neither the raw conditional $M_F(y\mid D,x)$ nor the normalised conditional $\bar M_F(y\mid D,x)$ is computable as a function of $(D,x,y)$.
* (d) Both conditionals are limit-computable ($\Delta^0_2$), indeed computable relative to $\emptyset'$.

*Proof.* (a) Prop 2.6 and §5. (c) Take $X=\mathbb N$ and suppose the raw conditional is computable. Define $f$ by recursion: with $D_t=\{(s,f(s)):s<t\}$, let $f(t)$ be the first $y\in\{0,1\}$ for which approximation certifies $M_F(y\mid D_t,t)<0.6$. Since the two conditionals sum to at most $1$, one of them is at most $\tfrac12$, so the search halts. $f$ is total computable, so $M_F(D_n)=\prod_{t<n}M_F(f(t)\mid D_t,t)<0.6^n$. This contradicts $M_F(D_n)\ge2^{-K(f)-O(1)}$ for large $n$. The same argument works for the normalised conditional: the normalised loss would be at least $n\log(1/0.6)$, while it is at most $L_n\le K(f)+O(1)$ (Prop 5.3). (b) If $M_F$ were computable, the raw conditional would be a computable ratio of positive computable reals. (d) Lower-semicomputable reals are computable from the halting problem, and the normaliser $\sum_yM_F(D+(x,y))$ is lower semicomputable and positive. $\square$

The exact arithmetical level (for example, whether the conditionals are lower or upper semicomputable) is not settled here. For Solomonoff's $M$ this was studied by J. Leike and M. Hutter, "On the computability of Solomonoff induction and knowledge-seeking", ALT 2015 **[known (unverified)]**.

**Remark 7.4.** The remark of `notes.md` on where the randomness lives is now Remark 4.11, extended by Prop 4.4.

---

## 8. Open problems

1. **Problem 3.6.** Is every lower-semicomputable law of a random partial function dominated by $M_F$ up to a constant? Reformulated: can its lower approximations be chosen increasing on all up-sets of the extension order (filling-in), at a constant-factor loss?
2. **Problem 4.6(b).** Is $\log(M_F(D)/W(D))=O(K(n,|D|))$, or even $\kappa$ of a computable function of $(n,|D|)$, for inputs of length at most $n$? Proved: at most $\min\{\kappa(L_{1/2}(M_F,D)),K(\mathrm{dom}\,D)\}+O(1)$ in general, and at most $\kappa(2^{n+1})+O(1)$ against fair-coin labels.
3. **Rates.** The exact growth of the two-point gap of $W$ (between $\log(1/\tau_V(\ell_n))$ and $\kappa(2^{n+1})$); a lower rate for $M_F/M_{\rm prod}$ (Prop 4.5); how close $\log(M^w/M_F)$ can get to $K(\mathrm{dom}\,D)$ (Thm 3.5).
4. **Explicit witnesses.** Is there a computable family $k\mapsto D_k$ along which any of the gaps of Table 4.12 tends to infinity? (Gaps larger than $K(k)+O(1)$ are impossible along computable families; Remark 4.10.)
5. **Two-sided characterisation** of $-\log M_F(D)$ up to $O(1)$ in terms of standard complexities (Thm 6.3 gives non-matching bounds; Example 6.4 shows that $K(D\mid\mathrm{dom}\,D)$ is the wrong lower bound in general).
6. **Normalised convention.** Is the normalised loss of $M_F$ order-dependent, i.e. does $(\star)$ of Prop 5.4 fail for some pair of inputs? Which of the semimeasure-only lower bounds of Remark 5.6 hold for $\bar M_F$?
7. **Last iterate.** Is $\mathbb E\,R(Q_n)\le(K(\varphi)+O(1))/(n+1)$ for SFI's posterior predictive with i.i.d. inputs and a deterministic computable target (Remark 6.11)?
8. **Arithmetical level** of the predictive conditionals (Prop 7.3).

---

## 9. Cross-track consistency

**Sources compared.** The other tracks' current notes when this was written (2026-10-12): `../context/notes-final.md` (as rewritten on 2026-10-12, 09:27); `../history/notes-final.md`, which is incomplete (it ends after its §3 at a continuation marker), so its §4–§7 were read in `../history/notes.md`; `../steeper/notes-final.md` (2026-10-12, 09:23); and `../examples/notes.md` (no final version yet). The history revision was in progress; its item numbers below are those of the files just named, and its final notes state that surviving results keep their numbers.

### 9.1 Definitions and notation

| object | here | history | context | examples | steeper |
|---|---|---|---|---|---|
| data set | finite partial function $D$; "consistent" sequence | same (`notes.md` said "function-consistent") | same | same | same |
| tape measure | $\lambda$ | $\lambda$ | $\lambda$ | $\lambda$ | — ($\lambda$ is the steepness exponent) |
| universal discrete semimeasure | $\mathbf m$ (was $m$) | — | — | — | $\mathbf m$ |
| padded length $\min_{L\ge N}K(L)$ | $\kappa(N)$ | $\kappa(n)$ (claim 4.10) | — | — | — ($\kappa$ is a machine constant) |
| SFI | $M_F$, law of $T_U$ (Def 5.1) | $M_F$ | $M_F$ | $M_F$ | mixture of $\Pi_F$ $=M_F$ |
| SFI loss | $L_n=-\log M_F(D_n)$ | $L_{\rm SFI}$ | $L_\nu(D)=-\log\nu(D)$ | $L_{\rm SFI}$ | $-\log P(D)$ |
| program mixture | $W$ (input-independent self-delimitation) | program mixture for SFI$^{\rm hist}$ (claim 4.10) | $W$, same | — | $W_{\rm det}$ |
| Kolmogorov version | $K_F(D)$ | — | $K_F$ | — | — |
| product mixture on data sets | $M_{\rm prod}$ | $M_{\rm prod}$ | $M_{\rm prod}$ | "product law" | $\xi_\times=M_{\rm prod}$ |
| per-query mixture (operator induction) | $M_{\rm pq}$ (new) | per-query mixture (claim 4.9) | $S$ (§6 item 1; X53) | — | mentioned in §1.1 |
| universal weak semimeasure | $M^w$ | $M^w$ | $M^w$ | — | mixture of $\Pi_w$ |
| universal chronological semimeasure | $\xi$ (Prop 7.2) $\asymp M_H$ | $\xi:=M_H$ | SFI$^{\rm hist}$ | (F7) | $\Pi_{\rm chr}$, $M_H$ |
| label set | countable | countable; finite where stated | $\{0,1\}^*$ or finite | finite where stated | finite |

**Notation clashes the paper must resolve.**
* $\lambda$: the fair-coin tape measure here and in the history, context and examples tracks; the steepness exponent in the steeper track and in the brief (H9). Recommendation: keep $\lambda$ for the steepness exponent, which is the brief's notation and appears in many of the steeper track's formulas, and write the tape measure differently in the paper (for example $\mathbb P_\omega$ or "Unif"). These notes keep $\lambda$ for the tape measure, for consistency with the three other tracks.
* $\kappa$: the padded length function here and in the history track; a machine constant in the steeper track; a kernel profile and the slides' norm complexity in the context track. The paper should give the padded length its own symbol.
* $S$: the context track uses it both for its time-bounded mixture (§3.1) and for the per-query mixture (§6 item 1), and the referee and `c7` use it for the per-query mixture. These notes write $M_{\rm pq}$ for the per-query mixture; the paper should keep $S$ for at most one object.
* Losses: the context track writes $L_\nu(D)=-\log\nu(D)$ for a general law and suggests $L_{\rm SFI}:=-\log M_F$ (history, examples). These notes write $L_n$ for SFI's cumulative loss on $D_n$, which is $L_{\rm SFI}(D_n)$. I agree with the context track's suggestion for the paper.
* $m$: a size (training set, junta, field degree) in the other tracks; here only the bold $\mathbf m$ is the universal discrete semimeasure.
* $c$: an additive machine constant here, in history and in context; $c=\lambda/N$ in the steeper track.

### 9.2 How the other tracks use these results, checked against this revision

All result numbers cited by other tracks are kept. Content changes that affect them:

* **Examples track** cites Def 2.1(a),(b), Thm 3.2, Prop 3.3, Prop 5.2, Thm 6.3, Prop 6.8. All unchanged in content. Prop 6.8 is retitled ("random-function SFI cannot model fresh label noise") and now also covers the normalised convention and weak semimeasures. Its Prop 4.6 uses frozen noise, which is Thm 6.7(c). Its H5 and H6 lower bounds are semimeasure-only (Remark 5.6), as its own notes say.
* **Context track** cites Defs 2.1, 2.5, 4.1, Prop 2.3, Ex 2.4, Thms 3.2, 3.4, 3.5, Prop 3.3, Thm 4.2, Prop 4.3, Props 5.2, 5.3, Thms 6.1, 6.3, 6.5, 6.7, Prop 6.8, Cor 6.6, §6.6.
  * Its X53 and §6 item 1 now read operator induction as the per-query mixture (its $S$), equal to $M_{\rm prod}$ on distinct inputs. This agrees with Def 4.1 and Prop 6.9 here and with the history track's claim 4.9. Its §8.3 lists this as "pending in foundations"; it is now settled here the same way.
  * Its Cor 5.2(c) (for finite $Y$, $M_F$ is universal among lower-semicomputable normalised order-independent predictors) extends to every countable $Y$, by Lemma 6.5a and Prop 3.3(c).
  * Its Prop 5.4(2) (one-point gap of $W$) is now cited here as Prop 4.3(b).
  * Its upper bounds are now proved with $L_\nu$ and only then weakened to $K_F$ (its Fact D and "Notation $L_\nu$"). Thm 4.7 shows that the weakened forms can be loose by $\Theta(\log n)$ bits already on two points; its §8.1 says the same, citing the referee's Prop A, which is Thm 4.7 here. Its note that the one-point gap of $W$ is at most $K(K(y\mid x))+O(1)$ agrees with Prop 4.4 (a padded length is all $W$ pays).
  * Its Remark 2.11 (learning curves can increase, without replacement) agrees with Prop 6.10 (with replacement). Its Conjecture 2.11 (leave-one-out error $O(K/N)$) is the error-probability analogue of the open question in Remark 6.11.
  * Its Prop 2.9 and Thm 6.7 here use the same exchangeability argument (§6.6).
  * Its OOD lower bounds bound the defined-and-wrong mass and hold in both conventions, as its §1.2 says; this agrees with Remark 5.6.
* **History track** cites Def 2.5, Prop 2.6, Thm 3.2, Prop 3.3(a,b,c), Def 2.1(b), Props 5.2, 5.3, Thm 6.3(a), Thm 6.5, Prop 7.2.
  * Its §1.2 says "for finite $Y$ these are exactly the computable laws of random total functions (foundations Thm 6.5)". This now holds for every countable $Y$ (Lemma 6.5a).
  * Its claim 4.9 (operator induction as a per-query mixture, dominated by $M_H$, equal to $M_{\rm prod}$ on distinct inputs) agrees with Def 4.1 and Prop 6.9.
  * Its claim 4.10 ($\kappa(n)+c$ for deterministic programs in SFI$^{\rm hist}$) is the history-aware analogue of Prop 4.4(b).
  * It defines the universal chronological semimeasure as $M_H$. Prop 7.2 now proves the existence of a universal one independently (trimming) and notes $\xi\asymp M_H$, so the two definitions agree up to constants.
  * Its chain and skipped-string lower bounds are semimeasure-only, as its §0 says; Remark 5.6 here lists them.
* **Steeper track** cites Defs 2.1, 2.5, 4.1, Prop 3.3(a), Thms 3.2, 3.4, Problem 3.6, Thm 4.2, Props 4.4, 4.5, Thms 6.1, 6.5, 6.7(c), Cor 6.6, Props 6.8, 7.2, 7.3(c).
  * "F Prop 4.4: hashing for fair coins" now refers to Remark 4.4a; Prop 4.4 is the tape-length bound. The steeper track's Lemma 3.2′ already adapts the tape-length argument (from the referee's report) to product classes and computable samplers. No result of that track changes.
  * Its §1.6–§1.8 say that at λ = 1 the product class costs "at most $K(\mathrm{dom}D)+O(1)$ bits against $M_F$, unboundedly in the worst case". Remark 4.5a and Prop 4.4 sharpen this: on its shared-coin data $D_\beta$ (inputs of length at most $k$), $M_{\rm prod}(D_\beta)\ge2^{-\kappa(k+1)-O(1)}\sigma(D_\beta)$, which makes precise its reading "at λ = 1 the first option costs the same as the shared class up to logarithmic terms".
  * Its per-input reading of product hypotheses (§1.1) is the reading of Prop 3.3(a) here; the per-query alternative is $M_{\rm pq}$.

### 9.3 Disagreements

* **Resolved: operator induction.** `notes.md` (F36) and the context track's `notes.md` (X53) identified it with $M_{\rm prod}$; the history track (4.9) with the per-query mixture. All three tracks now read it as the per-query mixture, equal to $M_{\rm prod}$ on distinct inputs, subject to the unverified secondary description of Solomonoff (2008) (Def 4.1).
* **Resolved: Example 6.4 as evidence about history-aware predictors.** `notes.md` §6.7 cited it for "predictors that use the list of past inputs are not dominated". That was wrong (a history-aware predictor also pays about $n$ bits there). The history and examples tracks' separations are the right citations (§6.7).
* **Resolved: the hashing verdict on H1(b)** (`notes.md` §10): the log factor is for $K_F$ (Prop 4.9), not for $W$ (Prop 4.4). The context track's §8.3 lists the referee's Prop A and M2 as "pending in foundations, no conflict"; they are now Thm 4.7 and Prop 4.4 here, and change no statement of that track.
* **None outstanding.** No result of another track contradicts a result here.

---

## 10. Claims table

| ID | Claim | Status | Where |
|---|---|---|---|
| F1 | Weak function semimeasures with $\nu(\emptyset)=1$ are exactly the order-independent online predictors (identified on positive-probability histories) | proved | Prop 2.1a |
| F2 | Containment functionals of random partial functions are characterised by the Möbius condition | proved; computed (c6a, r4) | Prop 2.3 |
| F3 | A weak semimeasure need not be the law of any random function; for $\tau$ no law reaches more than $\tfrac23\tau$, and $\tfrac23$ is attained | proved; computed (c1, c9b) | Ex 2.4 |
| F4 | Machine laws are lower-semicomputable random-function laws | proved | Prop 2.6 |
| F5 | Universal function machine: $M_F=\sum_i\mathbf m(i)\nu_{T_i}$, so $M_F\ge2^{-K(\nu)}\nu$ for every machine law | proved | Thm 3.2 |
| F6 | Machine laws include lsc product laws (x-only samplers, per input), partial computable functions, computable laws (computable cylinder probabilities; computable $\nu$ if $Y$ finite or the function total), and lsc mixtures | proved | Prop 3.3 |
| F7 | A universal lsc weak semimeasure $M^w$ exists | proved; trimming computed (r3) | Thm 3.4 |
| F8 | $M_F\ge2^{-K(\nu)-K(\mathrm{dom}\,D)-O(1)}\nu$ for lsc weak $\nu$; $M^w\le2^{K(\mathrm{dom}\,D)+O(1)}M_F$ | proved; step checked (c6b) | Thm 3.5(ii) |
| F9 | $\log(M^w/M_F)\ge k\log\tfrac32-K(k)-O(1)$ on some $2k$-point data sets; on average over an explicit family | proved | Thm 3.5(iii,iv) |
| F10 | Brief H1(a): "lsc function semimeasures, or equivalently monotone function machines" | refuted for the weak definition (F9); open for random-function laws (F11) | §3 |
| F11 | Every lsc random-function law is dominated by $M_F$ | open (reformulated via filling-in) | Problem 3.6 |
| F12 | $2^{-K_F}\le W\lesssim M_{\rm prod}\lesssim M_F\lesssim M^w\le2^{K(\mathrm{dom}\,D)+O(1)}2^{-K_F}$ | proved | Thm 4.2 |
| F13 | $M_{\rm prod}/W$ and $M_F/W$ are unbounded on two-point binary data and on one-point data with long labels | proved | Prop 4.3 |
| F14 | Hashing bound $W(D)\ge2^{-\lvert D\rvert-K(n,k)-O(1)}$ | proved; superseded by F41 | Remark 4.4a; c2, r10 |
| F15 | $M_F/M_{\rm prod}$ is unbounded (shared coin per input length) | proved | Prop 4.5 |
| F16 | Hänni §2.2: Kolmogorov version and semimeasure version are equivalent | refuted for $K_F$ and for $W$, with rates (F37, F38, F41); true up to $K(\mathrm{dom}\,D)+O(1)$ | §4, Table 4.12 |
| F17 | $-\log W=K_F+O(1)$ (coding theorem for function programs) | refuted: unbounded gap, not even within a constant factor | Thm 4.7 |
| F18 | Semimeasure cumulative loss $=-\log M_F(D_n)$ is order-independent | proved; computed (c4) | Prop 5.2 |
| F19 | Normalised loss is at most the semimeasure loss; can be order-dependent for random partial functions; equal for total ones; open for $M_F$ | proved; computed (c3, r8, r13) | Prop 5.3 |
| F20 | H2: pathwise dominance over every machine law, for every input sequence | proved | Thm 6.1 |
| F21 | H2 for lsc weak $\nu$ with constant $K(\nu)+O(1)$ | refuted; correct with $+K(\mathrm{dom}\,D_n)$, which cannot be $O(1)$ | Thm 6.1(c) |
| F22 | H2 needs consistent label sequences (randomness per input, not per query) | proved | §6.1 |
| F23 | Hänni's "Thm 1 (template)" for x-only computable samplers, for data from a function | proved (as F20(a)) | Thm 6.1(a) |
| F24 | Invariance under universal machine and computable injective encodings, constant $K(\alpha,\beta)+O(1)$ | proved | Thm 6.2 |
| F25 | $\max_TK(D\vert_T\mid T)-O(1)\le-\log M_F(D)\le\min\{K_F(D),\sum K(y\mid x)\}+O(1)$; tight for single points | proved | Thm 6.3 |
| F26 | Swap data: $K(D\mid\mathrm{dom}\,D)=O(1)$ but $-\log M_F(D)=n\pm O(1)$ for suitable pairs; not a separation from history-aware predictors | proved; computed (c9c, r8) | Ex 6.4 |
| F27 | Merging: $\sum_t\mathbb E\,\mathrm{KL}_t\le K(\nu)$ for computable random total functions and past-only input rules | proved; finite analogue computed (c4, r6) | Thm 6.5 |
| F28 | Mistake bound $K(\varphi)+O(1)$ for deterministic computable targets | proved | Cor 6.6 |
| F29 | H7 for deterministic labels: averaged predictor risk $\le(K+O(1))/n$, log and 0–1 | proved; computed (r9) | Thm 6.7(a) |
| F30 | H7 with stamped or frozen noise; resolvability bound for non-computable $P$; $\sqrt{\cdot}$ 0–1 excess | proved | Thm 6.7(b,c) |
| F31 | H7 for i.i.d. pairs with fresh noisy labels, for random-function SFI ($M_F$, $W$, $M_{\rm prod}$, $M^w$) | refuted; computed (c5, r9) | Prop 6.8 |
| F32 | Occam bound in description-length form; same rate as SFI for deterministic targets | proved (standard; reference unverified) | §6.6 |
| F33 | Solomonoff induction is SFI on initial segments, up to constants | proved | Prop 7.1 |
| F34 | A universal lsc chronological semimeasure $\xi$ exists, $\xi\asymp M_H$, and dominates SFI and $M_{\rm pq}$; order-free chronological semimeasures are the weak semimeasures | proved | Prop 7.2 |
| F35 | $M_F$ is lsc, not computable; its conditionals (raw, normalised) are not computable and are $\emptyset'$-computable | proved | Prop 7.3 |
| F36 | Operator induction (Solomonoff 2008) is the per-query mixture $M_{\rm pq}$, which equals $M_{\rm prod}$ on distinct inputs | known (unverified secondary description); `notes.md`'s "$=M_{\rm prod}$" corrected | Def 4.1 |
| F37 | No coding theorem for function programs: on some two-point binary data, $K_F\ge\log_2n-2$, $-\log W\le2+K(\lceil\log_2(n+1)\rceil)+O(1)$, $-\log M_F\le2+O(1)$ | proved; arithmetic computed (c8a) | Thm 4.7 |
| F38 | Largest two-point gap between $K_F$ and $-\log M_F$ on $n$-bit inputs is $\log_2n\pm O(\log\log n)$ | proved | Cor 4.8 |
| F39 | Covering bound $K_F(D)\le k+\log_2(k(n+2))+K(\lceil\log_2(n+2)\rceil,k)+O(1)$ for binary labels | proved; computed (c8c,d, r11d) | Prop 4.9 |
| F40 | Witnesses of gaps larger than $K(k)+O(1)$ cannot be computable families | proved | Remark 4.10 |
| F41 | Tape-length bound $W\ge2^{-K(\nu)-\kappa(L)-O(1)}\nu^{(L)}$; fair coins: $W\ge2^{-\lvert D\rvert-K(\lceil\log_2(n+1)\rceil)-O(1)}$; $\log(M_F/W)\le\kappa(L_{1/2})+O(1)$ | proved; finite analogue computed (c9a, r5) | Prop 4.4(a,b) |
| F42 | $\kappa(N)\le2\log_2(g(N)+2)+O_g(1)$ for every computable nondecreasing unbounded $g$ | proved | Prop 4.4(c) |
| F43 | The two-point gap of $W$ lies between $\log(1/\tau_V(\ell_n))$ and $\kappa(2^{n+1})+O(1)$, both of $\kappa$ type; Prop 4.5's gap is at most $\kappa(n_k+1)+O(1)$ | proved | Remarks 4.3a, 4.5a |
| F44 | Per-query mixture: lsc chronological semimeasure, multiset-invariant, $=M_{\rm prod}$ on distinct inputs, pathwise regret $K(P)$ on every sequence, H7 under fresh noise without stamps; dominated by stamped SFI | proved; computed (c7, r7) | Prop 6.9 |
| F45 | Two-point criterion $(\star)$ for order independence of normalised losses; fails without positivity | proved; computed (c10a, r13) | Prop 5.4 |
| F46 | $\bar L_n=L_n-\sum_t\log(1/Z_t)$; single-point lower bounds transfer; $\bar L_n\ge K^{\emptyset'}(y_{1:n}\mid x_{1:n})-O(1)$; Gibbs bound | proved; computed (c10b,c) | Prop 5.5 |
| F47 | Several lower bounds in the tracks hold only in the semimeasure convention | proved (as a list); transfer open | Remark 5.6 |
| F48 | The expected risk of the posterior predictive of a Bayes mixture need not decrease with $n$ (explicit two-input example) | proved; computed (c11a, r12) | Prop 6.10 |
| F49 | $\mathbb E\,R(Q_n)$ equals the expected leave-one-out log loss on $n+1$ samples; an $O(K/n)$ bound for $M_F$ | identity proved, computed (c11b); bound open | Remark 6.11 |
| F50 | Computable filling-in processes give machine laws; Problem 3.6 as a Strassen-type question | proved; reformulation proof sketch | Remark 2.7, Problem 3.6 |
| F51 | $(2/3)^k$ is the exact domination constant for $\tau^{\otimes k}$, every $k$ | proved; computed (c9b, r1) | Thm 3.5 remark |
| F52 | Lsc laws of random total functions are computable for every countable $Y$ | proved | Lemma 6.5a |
| F53 | Merging proof: integrability via $\mathbb E[Z_t^-]\le\log_2e$ | proved; inequality computed (c11c) | Thm 6.5 |

---

## 11. Verification log

**Environment.** Python 3.11.15, numpy 2.4.6, scipy 1.17.1. All scripts are deterministic or seeded (seed 20261011 for `c5`, `c6`; 20261012 for `c8`–`c11` and the referee's `r11`–`r13`), and each writes its output next to itself.

**Scripts of this track** (`checks/`, output `<name>.out.txt`).

| script | what it checks | result |
|---|---|---|
| `c1_weak_vs_random_function.py` | $\tau$ (Ex 2.4) and $\tau^{\otimes2}$ satisfy all one-point inequalities; Möbius sum of $\tau$; pairwise inconsistency of $E_1,E_2,E_3$; LP optimum of $\max\{c:\exists P,\ P\ge c\,\tau^{\otimes k}\}$ | 27 and 1458 inequalities, 0 violations; Möbius sum $-1/2$; all pairs inconsistent; LP optimum $(2/3)^k$ for $k=1,2,3$ |
| `c2_kwise_hash.py` | exact $j$-wise uniformity of polynomial hashing over $\mathrm{GF}(2^m)$ (Remark 4.4a) | every count equals $2^{mk-j}$ |
| `c3_normalisation_order.py` | semimeasure vs normalised probability in every reveal order (Prop 5.3) | $\rho_1$: $1/4$ both orders; normalised $2/3$ vs $1/2$; $\rho_2$: semimeasure constant $1/5$, normalised varies; normalised $\ge$ semimeasure |
| `c4_finite_mixture_merging.py` | pathwise dominance, order independence over 24 orders, worst adaptive input rule (Prop 5.2, Thm 6.5) | spread $\le1.8\cdot10^{-15}$; all maxima below $-\log_2w$ |
| `c5_repeated_inputs.py` | probability that i.i.d. pairs with fresh labels stay consistent (Prop 6.8) | e.g. $0.95$ ($n=2$), $0.113$ ($n=10$), $5\cdot10^{-4}$ ($n=20$) for $m=10$, $p=\frac12$; Monte Carlo agrees |
| `c6_moebius_and_sequential.py` | Möbius sums equal the defined/undefined probabilities; sequential realisation of weak semimeasures (Prop 2.3, Thm 3.5(ii)) | discrepancy $0$; identities hold |
| `c7_per_query_mixture.py` | $M_{\rm pq}$ on a 133-law class: chronological inequality, multiset invariance, $\le M_{\rm prod}$ with equality on distinct inputs, fresh-noise regret and telescoping identity, stamped equality (Prop 6.9) | 0 violations in 777, 216, 624 cases; 546 strict at repeats; regret $\le10.27$ for $n\le7$; stamped equality on all 1554 sequences |
| `c8_kf_covering.py` (new) | pigeonhole arithmetic of Thm 4.7(i); Kleitman–Spencer two-point covering columns; exhaustive maximum 2-covers for $N\le6$; Prop 4.9's union bound and random coverings; padding | 0 failures over 200,596 values of $n$; construction valid for $N=3..14$; exhaustive maxima $1,1,3,4,10$ equal the construction; $\mathbb E[\text{uncovered}]<1$ in all 9 cases, random families of that size cover everything in between 10 of 15 and 15 of 15 trials, depending on the case; padding holds for $n<10^5$ |
| `c9_tape_tau_swap.py` (new) | Prop 4.4 finite analogue on 30 random shared-tape machines (well-definedness, monotonicity, limit $=\nu$ from label tables); lookup identity; $(2/3)^k$ law for $k\le4$; swap probability $2^{-n}$ | 0 conflicts, 0 violations in 30,720 pairs; lookup identity in 2214 cases; minimum ratio exactly $(2/3)^k$, $k=1..4$; swap identity for $n\le7$ |
| `c10_normalised_convention.py` (new) | Prop 5.4 (criterion $\Leftrightarrow$ order independence; built laws; total laws; a non-positive counterexample to the converse); Prop 5.5 (normalised products sum to 1; first normaliser) | 400/400 agree; 400/400 built laws order-free; 200/200 total laws order-free with normalised = semimeasure; counterexample confirmed; 16,200/16,200 sums equal 1 |
| `c11_learning_curve.py` (new) | Prop 6.10 closed forms and $r_1>r_0$; exchangeability identity of Remark 6.11; $\mathbb E[Z^-]\le\log_2e$ | closed forms exact; $r_1>r_0$ for $w\le1/16$ in the grid; identity to $1.6\cdot10^{-15}$; 13/50 random mixtures non-monotone; largest $\mathbb E[Z^-]$ found $0.51<1.44$ |

**Reproduction runs.**
* `c1`–`c7` and the referee's `r1`–`r13` were re-run on scratch copies on 2026-10-12. All 20 output files were byte-identical to the saved ones. (`c7`'s docstring was afterwards updated to the numbering of these notes; it does not affect its output.)
* `c8`–`c11` were written for this revision and run to produce their saved outputs. They, and `c7` after its docstring edit, were then re-run on scratch copies; all five outputs were byte-identical to the saved ones. Running times: `c8` about 60 s, `c10` about 55 s, the others a few seconds.

**Referee scripts used** (`referee_code/`, output `<name>_output.txt`): r1 ($\tau$ blocks, $k\le4$), r2 (Lemma 3.1 intervals), r3 (trimming), r4 (Möbius and Prop 3.3(c) intervals), r5 (tape-length bound), r6 (merging when the rule sees $F$), r7 (operator induction under noise), r8 (normalisation, swap data), r9 (supervised bounds), r10 (hash independence), r11 ($K_F$ two-point covering), r12 (last iterate), r13 (two-point criterion). I read each against the claim it supports here.

**Proof checks done in this revision.**
* Thm 4.7: re-derived all three parts. (i) The count "fewer than $2^g$ programs shorter than $g$" and $3^{2^g}<2^n$; the colour argument handles labels outside $\{0,1\}$ by the symbol $*$. (ii) follows from Prop 4.4(b). The last claim's arithmetic: $\lceil\log_2(n+1)\rceil\le K_F+4$.
* Prop 4.4: the programs $r\,q_i\,q_{L'}\,w$ are distinct and form part of $\mathrm{dom}\,V$; $\varphi_{T,w}$ is well defined by consistency of $T$; $\nu^{(L)}\uparrow\nu$ because a data set has finitely many pairs. Part (c): $N^*>N$ uses monotonicity of $g$.
* Prop 4.9: the count of data sets, the strict inequality $(1-2^{-k})^N<e^{-N2^{-k}}$, the self-delimitation of the index (its length is computable from $(s,k)$), and the padding inequality $n'+2<2(n+2)$.
* Remark 4.10: the second bullet needs only that $n$ is computable from each input of $D_n$.
* Prop 5.4: the two normalised products were recomputed by hand for the law of Prop 5.3(b) ($\frac23$ and $\frac12$) and match c3, c10 and r13.
* Prop 5.5(b): for a fixed input list the normalised products form a probability on $Y^n$, including when inputs repeat (repeated inputs contribute factor 1 to the stored label); c10(b) confirms this exactly.
* Prop 6.9: the chronological inequality, the telescoping $\prod_tq_t=M_{\rm pq}/M_{\rm pq}(\varepsilon\Vert\varepsilon)$, and the independence of $x_t$ from the past.
* Prop 6.10: closed forms recomputed by hand for $w=\frac1{16}$ ($r_0=-\log_2\frac{17}{32}=0.912$, $r_1=\frac12\log_2\frac{17}2=1.544$).
* Lemma 6.5a and Thm 6.5: the induction for countable $Y$; the integrability bound.
* Prop 7.2(a): the chronological trimming, including the frozen case (a frozen $\phi'_{i,t-1}$ vanishes outside $U_{t-1}$, so the inequality holds there trivially).
* Thm 3.5 remark: the law $P_1$ was checked by hand on all ten data sets of the support of $\tau$, and by c9(b).
* Earlier checks (from `notes.md`, confirmed by the referee line by line): Prop 2.3, Thm 3.5(iii), Prop 4.5, Prop 6.8, Thm 6.5/6.7 identities.
* Not checked by computer: Lemma 3.1 (beyond r2), Thm 3.2, Prop 3.3, Thm 3.4 (beyond r3), Prop 4.3, Prop 7.1, Prop 7.3. These are standard constructions or short diagonal and pigeonhole arguments, written out in full.

**References, and their verification status.** No source could be opened (arxiv.org, journal sites and similar do not resolve here; WebSearch gives snippets). Everything below is therefore **unverified** against the source, except bibliographic data where a snippet confirmed it, as noted.
* L. A. Levin, "Laws of information conservation (nongrowth) and aspects of the foundation of probability theory", *Problems Inform. Transmission* 10(3):206–210, 1974 (Russian original *Probl. Peredachi Inf.* 10(3):30–35). Snippets confirm the data (some citers give pp. 206–211).
* P. Gács, "On the symmetry of algorithmic information", *Soviet Math. Dokl.* 15:1477–1480, 1974 (Russian original *Dokl. Akad. Nauk SSSR* 218(6):1265–1267). Snippets confirm the data.
* G. J. Chaitin, "A theory of program size formally identical to information theory", *J. ACM* 22(3):329–340, 1975. Snippets confirm the data and that it relates self-delimiting complexity to the probability that the universal computer outputs a string.
* A. K. Zvonkin, L. A. Levin, *Russian Math. Surveys* 25(6):83–124, 1970. Snippets (in `notes.md`) confirmed that lower-semicomputable semimeasures are the output distributions of monotone machines.
* M. Li, P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., Springer 2008 (section numbers unverified).
* R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008. Snippets confirm the data and the "unordered set of ordered pairs" third kind. The per-query product formula is from E. Özkural, arXiv 1709.03879 (snippet, via the referee).
* R. J. Solomonoff, "Complexity-based induction systems: comparisons and convergence theorems", *IEEE Trans. Inf. Theory* 24(4):422–432, 1978.
* P. Gács, "On the relation between descriptional complexity and algorithmic probability", *Theoret. Comput. Sci.* 22:71–93, 1983 (snippets: $Km-KM$ unbounded). A. R. Day, "Increasing the gap between descriptional complexity and algorithmic probability", CCC 2009, pp. 263–273; journal version in *Trans. Amer. Math. Soc.* 2011 (snippets confirm the title, the CCC pages and the journal and year; volume and pages not confirmed).
* L. A. Levin, "Occam bound on lowest complexity of elements", *Ann. Pure Appl. Logic* 167(10):897–900, 2016, arXiv 1403.4539 (snippets confirm the data). S. Epstein, L. A. Levin, "Sets have simple members", arXiv 1107.1458 (snippets confirm the title and topic).
* D. J. Kleitman, J. Spencer, "Families of $k$-independent sets", *Discrete Math.* 6:255–262, 1973 (snippets confirm the data).
* V. Strassen, "The existence of probability measures with given marginals", *Ann. Math. Statist.* 36:423–439, 1965 (from memory; not searched).
* M. Hutter, *Universal Artificial Intelligence*, Springer 2005 (chronological semimeasures; supervised learning as a problem class, the latter confirmed only for the arXiv cs/0004001 version by a snippet).
* J. Leike, M. Hutter, "On the computability of Solomonoff induction and knowledge-seeking", ALT 2015.
* A. Blumer, A. Ehrenfeucht, D. Haussler, M. Warmuth, "Occam's razor", *Inf. Process. Lett.* 24:377–380, 1987.
* D. McAllester, "Some PAC-Bayesian theorems", *Machine Learning* 37:355–363, 1999.
* A. Barron, T. Cover, "Minimum complexity density estimation", *IEEE Trans. Inf. Theory* 37(4):1034–1054, 1991; A. Barron, *Bayesian Statistics* 6, 1998.
* V. Vovk, "Aggregating strategies", COLT 1990; N. Cesa-Bianchi, G. Lugosi, *Prediction, Learning, and Games*, Cambridge 2006.
* N. Littlestone, *Machine Learning* 2:285–318, 1988; N. Littlestone, "From on-line to batch learning", COLT 1989; N. Cesa-Bianchi, A. Conconi, C. Gentile, *IEEE Trans. Inf. Theory* 50(9):2050–2057, 2004.
* J. M. Barzdin, R. V. Freivalds, "On the prediction of general recursive functions", *Soviet Math. Dokl.* 13:1224–1228, 1972 (Russian original *Dokl. Akad. Nauk SSSR* 206(3):521–524). Snippets confirm the data and the $\log_2n$ mistake bound for enumerations.
* M. Wegman, J. L. Carter, *J. Comput. Syst. Sci.* 22:265–279, 1981 (polynomial hashing; nothing depends on it).
* Choquet, Matheron, Shafer for completely monotone set functions (analogy only, Prop 2.3 remark).

**Relation to the brief's hypotheses (summary of verdicts).**
* H1(a): the universal element exists in both senses; "equivalently machines" is refuted for the weak definition and open for random-function laws (Thm 3.5, Problem 3.6).
* H1(b): $W$ and $2^{-K_F}$ are not within a constant of $M_F$. The program mixture loses at most $\kappa(L_{1/2}(M_F,D))+O(1)$ bits, and at most $K(\lceil\log_2(n+1)\rceil)+O(1)$ against fair-coin labels, with no log factor (Prop 4.4). The single shortest program loses up to $\log_2n\pm O(\log\log n)$ bits on two points, and at most about $\log_2(k(n+2))$ plus lower-order terms on $k$ incompressible binary labels (Thm 4.7, Prop 4.9). There is no coding theorem for function programs. The brief's "log factor via $k$-wise hashing" is right for $K_F$, via covering.
* H1(c): $M_{\rm prod}$ lies strictly between $W$ and $M_F$ (Props 4.3, 4.5), but the gaps are of $\kappa$ type on the known witnesses. The per-query mixture $M_{\rm pq}$ is a fourth object, equal to $M_{\rm prod}$ on distinct inputs.
* H1 (definition of SFI): $M_F$ (§5); its semimeasure-convention loss is order-independent; the normalised one need not be (open for $M_F$).
* H2: proved for machine laws, pathwise, for consistent label sequences (Thm 6.1); needs an extra term, at most $K(\mathrm{dom}\,D)$ and not $O(1)$, for weak comparators.
* Invariance (Hänni §2.1): proved with constant $K(\alpha,\beta)+O(1)$ (Thm 6.2).
* Coding-theorem bounds: Thm 6.3; the $K(D\mid\mathrm{dom}\,D)$ lower bound can be loose by about $n$ bits (Example 6.4).
* Merging and mistakes: Thm 6.5, Cor 6.6.
* H7: proved for deterministic labels (averaged predictor) and for stamped or frozen noise; refuted for random-function SFI under fresh noise; proved for the per-query mixture (Thm 6.7, Props 6.8, 6.9). The last-iterate form is open (Remark 6.11).
* Hänni's later request (Kolmogorov vs universal-semimeasure versions): answered in §4, Table 4.12 and the paragraphs after it.

**What was not checked.** The bibliographic references, as listed. No primary source on operator induction was read. The Strassen step in the reformulation of Problem 3.6 is quoted, not proved. The context and history tracks' final notes were incomplete or in revision when §9 was written; their later numbering may differ from the numbers cited there.
