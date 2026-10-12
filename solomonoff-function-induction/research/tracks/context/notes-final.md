# Track "context": out-of-distribution behaviour, computable versions, NN Bayes, literature, extras (final notes)

*Final notes of the context track for the SFI paper, revised after the referee report `referee.md`. They replace `notes.md` (kept unchanged for the record) and are self-contained. Read `../../00-brief.md` for the project. This track covers brief items H8 (OOD) and H10 (computable and physical versions), the NN-Bayes motivation and the Vaintrob–Hänni slides, the literature, and further results. Scripts are in `checks/` (seeded where random; each writes `<name>_output.txt` next to itself). The referee's own scripts are in `referee_code/`; I did not use them for any claim here, and wrote independent checks instead.*

**Status labels.**
* **[proved]**: full proof in these notes.
* **[computed]**: checked by a seeded script whose saved output is cited.
* **[known]**: published result, with reference. **(unverified)** means I could not check it against the source in this session (arxiv.org, lesswrong.com and publisher sites do not resolve; only web-search snippets were available). **(snippet)** means that the bibliographic data, and only the content the snippet states, were confirmed by a search snippet.
* **[proof sketch]**: argument given, some steps not written out.
* **[conjecture]**: believed, not proved.
* **[refuted]**: a claim shown false, kept with its counterexample. This includes claims made in `notes.md` that the revision withdraws.
* **[claimed in the slides]**: stated in the Vaintrob–Hänni slides and not verified here.
* Hänni's claims are treated as hypotheses.

---

## 0. Summary

**Out-of-distribution behaviour (H8).** SFI is $M_F$, the law of the universal function machine (foundations track). $W$ is the deterministic program mixture.

1. *Hänni's proposition, with no log term* [proved, Prop 2.1]. If a decidable property $Q$ contains no training input, SFI gives probability at least $2^{-K(Q,b)-c}$ to every computable behaviour $b$ on all $Q$-inputs at once, for every training set. This holds for $W$ and $M_F$, in both loss conventions. A log term appears only for plain complexity; a merely semi-decidable $Q$ loses the bound altogether (Remark 2.2).
2. *Relative version* [proved, Prop 2.3, corrected]: a property simple **given** a training-consistent program $p$ forces bad behaviour with probability at least $2^{-K(q,r\mid p)-c}$ times $p$'s posterior weight, with genuine conditional complexity.
3. *Language dependence* [proved, Prop 2.4]. For each $Q,b$ some universal machine, $K(Q,b)+O(1)$ bits from the reference one, gives the bad behaviour posterior $\ge1/2$ for every training set avoiding $Q$. This is the supervised analogue of Leike and Hutter's "bad universal priors" [known (snippet)].
4. *The PDF draft's two-sided "result"* [proved, Thm 2.5; refuted as literally stated, Prop 2.6]. With an unseen decidable $Q$, the probability of $P$-abiding outputs on $Q$ lies in $[2^{-K(P,Q)-c},1-2^{-K(P,Q)-c}]$, for every amount of data. The draft's "at most $2^{-C(Q)}\cdots$" is false as written; it must bound the probability of *violation* from below. Its "at least $2^{-C(P)}$" is false without the separating $Q$.
5. *OOD failure is a bounded resource* [proved, Thm 2.7, Prop 2.8]. On any sequence of distinct inputs (adversarial, adaptive, non-computable), the posterior error probabilities satisfy $\sum_ke_k\le(\ln2)(K(f)+c)$. The separation lower bounds $e_k\ge2^{-\sigma_k-c}$ sum to at most $2^{-c}$, so separation arguments force at most $O(1)$ cumulative error (Remark 2.8a, corrected after the referee).
6. *Positive results.*
   * Random splits generalise, for every finite input set [proved, Prop 2.9; this is the standard exchangeability (online-to-batch) argument applied to SFI].
   * **New: a converse given the labelled sample** [proved, Prop 2.16]. For $x^*\in B$ and $A=B\setminus\{x^*\}$, with $f$ the labels of $B$:
     $$2^{-\sigma(x^*;A)-K(y)-c}\ \le\ e^{\rm wr}(x^*)\ \le\ e_{\rm norm}(x^*)\ \le\ 2^{K_F(f)-K(x^*\mid f)+c},$$
     and $K(x^*\mid f)$ equals, up to $O(1)$, the least complexity *given the labelled sample* of a property separating $x^*$ from $A$. So "$f$ simple, and no property simple given the sample separates the test point" does imply a small error.
   * **New: per-step in-distribution bound** [proved, Cor 2.17; computed, c7]. For i.i.d. inputs from any distribution, $\mathbb E\,e(x_{m+1})\le((K(f)+c)\ln2+\ln m+1)/m$. This is the Markov half of the slides' relevance-based bound, applied to $W$ and $M_F$. Together with the lower bound $\Omega(2^{-K(f)}/(m\log^2m))$ of Prop 2.12, the per-step error in distribution is $1/m$ up to logarithmic factors. This replaces the invalid comparison in `notes.md` between a per-step lower bound and a Cesàro upper bound.
   * The naive converse ("no simple property separates test from train ⇒ small error") is false for random targets, for every learner (Prop 2.13). Prop 2.16 shows what replaces it for simple targets.
   * Easy-to-hard [proved, Example 2.15] and shortest-proof labels [proved, Example 2.15a]: the probability of the intended answer on a hard statement stays in $[2^{-K(T)-c},1-2^{-K(T)-c}/\log_2^2L]$, however many easy statements were seen.

**Computable versions (H10).**

7. *Time-bounded SFI* [proved regret, proof sketch of time, Thm 3.1]. A length-activated, length-clocked mixture has constant regret against every $x$-only predictor in time $O(p(|x|))$ **on sequences of distinct inputs**. The revision makes the restriction explicit. With repeated short inputs (noisy labels) its regret grows linearly [computed, c9]. A round-activated, round-clocked mixture has constant regret on every stream [proved, Prop 3.2a; computed, c9]. Hänni's Remark 4 (time $n^{\omega(1)}$ against all polynomial-time predictors) follows [proved, Cor 3.2b]. Against time-bounded *history-aware* predictors, a time-bounded chronological mixture with Hänni's catch-up has constant regret [regret proved, time proof sketch, Prop 3.2c]; the class is now defined.
8. *Samplers* [proved, Prop 3.3, corrected]: the mixture must range over clocked samplers as well as clocked predictors. Efficient constant regret against samplers is open (Question 3.4).
9. *Circuit Bayes* [proved, Thm 3.5; computed, c1]. On every ordering, Gibbs mistakes $m$ and log loss $L_B$ satisfy $m\le(\ln2)L_B$ and $L_B\le16\,m(d+1)\log_2(2(m+1)(d+2))$ (explicit constant, new), and the circuit size is at most $\lceil L_B\rceil$.
10. *Occam (simplest-consistent) learning.* In distribution: $O(\ell(d+\log\ell)+d^2)$ expected mistakes [proved, Prop 3.9]. Out of distribution: **the conjunction ladder** [proved, Thm 3.11; computed, c6]: for $f=x_1\wedge\dots\wedge x_d$, of description length $\Theta(d\log d)$, Occam makes at least $2^d-2$ mistakes (formulas) or $2^d-d-2$ (circuits of §3.2) on an ordering of the cube. So worst-case Occam mistakes are $2^{\Omega(\ell/\log\ell)}$ in both natural languages. The construction is from the Vaintrob–Hänni slides (Appendix K). `notes.md` called this question open; that was wrong (referee M1). With the same prior, the Bayes posterior-majority predictor makes at most $\ell$ mistakes on every ordering (Remark 3.10); on the ladder at $d=4$ it makes 3.5 against Occam's 15 [computed, c6].

**NN Bayes and circuit SFI.**

11. General facts [proved, Props 4.1–4.4]: the NN posterior is function-space Bayes with the parameter–function-map prior $P_A$; $P_A(f)\le2^{-K(f\mid a)+c}$ (no $\log\log$ term); every prior nearly saturates this on its own typical set [known, standard; proof included]; there is no general lower bound.
12. Uniform priors over circuits of a fixed size contain the circuit simplicity prior [proved, Prop 4.5].
13. NNGP/NTK and parities [proved, Thm 4.6, Cor 4.7, Remark 4.8; computed, c2, c10]. The Walsh diagonalisation is **known** (Yang–Salman; also proved in the slides, Appendix J); the kernel lower bound is the standard dimension argument; the vanishing of odd eigenvalues of degree $\ge3$ for bias-free two-layer ReLU kernels is **known** (Basri et al. 2019, on the sphere). New here only: the consequence for GP *classification* priors, which give probability exactly 0 to such parities [proved; computed, c10].
14. **The Vaintrob–Hänni slides** (§4.5), now read and summarised with their caveats. Their main theorem (strong-prior limit) and the claimed "mistakes ⇒ small circuit" direction update the open items of `notes.md`. I re-checked the warm-up, Appendix A and Appendix K (the ladder), and not the main theorem.

**Order independence (§5), corrected.** Order-independent predictors are exactly the *weak* function semimeasures [proved, Prop 5.1(a)]. They are Bayesian for a random partial function only under the Möbius condition (foundations Prop 2.3) [refuted in general: two-point counterexample]. Normalised order-independent predictors are exactly random *total* functions [proved, Prop 5.1(b)]. For a finite label set, $M_F$ is universal among lower-semicomputable normalised order-independent predictors [proved, Cor 5.2(c), from foundations]. It is not universal among all order-independent ones; the universal element there is $M^w$ (foundations Thm 3.4–3.5). `notes.md`'s Cor 5.2 is withdrawn.

**Other extras.** Choosing the query order never changes total log loss, and small loss does not give efficient identification [proved, Prop 5.3]. Single-query $M_F$ is the conditional discrete universal distribution, while the program mixture $W$ falls short of it by an unbounded factor already on one-point data sets [proved, Prop 5.4]. This strengthens foundations Prop 4.3.

**Literature (§6).** The closest prior objects are Solomonoff's operator induction (2008), Hutter's chronological semimeasures, and Lattimore–Hutter's Solomonoff-style classifier. The "apparently new" list is corrected (referee M5): Thm 4.6, Remark 4.8, Prop 2.9 and the ladder are known; Prop 2.4 is the supervised analogue of Leike–Hutter (2015).

### 0.1 Response to the referee

The referee found no fatal issues and five major ones. I agree with all five and fixed them. On M4 I go further than the referee in two places. The converse is conditioned on the labelled sample, which gives exponent $K_F(f)$ instead of $2K_F(f)$ (Prop 2.16). The per-step bound is $((K+c)\ln2+\ln m+1)/m$ instead of the referee's $2^{2K}\log m/m$ (Cor 2.17(a)).

| Item | Referee's point | Action | Where |
|---|---|---|---|
| M1 | Occam OOD lower bound is settled by the ladder (slides, App. K) | Agreed. Theorem with full proof for both languages (circuits: $k\ge2$ only), independent check $d\le5$; "open" withdrawn; open problem 5 restated as the $\log\ell$ gap | Thm 3.11, Lemma 3.11a, Remark 3.12; c6 |
| M2 | Prop 5.1/Cor 5.2 wrong for sub-probability predictors | Agreed. Retitled; Bayesian reading kept only for normalised predictors and under Möbius; Cor 5.2 replaced; universality of $M_F$ among normalised order-independent predictors (finite $Y$) added | §5.1 |
| M3 | Slides treated as unavailable | Agreed. Placeholder replaced by a hedged summary; Thm 4.6 credited; open items updated; warm-up and App. A re-checked | §4.5, §4.6; c8 |
| M4 | Positive converse given the input set missing; per-step bound missing | Agreed. Prop 2.16 conditions on the *labelled* sample, giving $2^{K_F(f)-K(x^*\mid f)}$, which implies the referee's $2^{2K_B(f)-K(x^*\mid B)}$. Cor 2.17(a) gives $((K+c)\ln2+\ln m+1)/m$; Cor 2.17(b) gives $2^{K+c}/(m+1)$; both sharper than the referee's R2 | §2.4; c7 |
| M5 | Several "apparently new" items are known | Agreed; list corrected; citations added (Basri et al.; Leike–Hutter; Haussler–Littlestone–Warmuth; slides) | §6, Remark 4.8, Prop 2.4, Prop 2.9 |
| m1 | Thm 3.1 proof wrong for active comparators on short inputs | Fixed: two cases, "$\le$" | Thm 3.1; c9 |
| m2 | "Distinct inputs loses nothing" is false for noisy labels | Agreed, kept as [refuted] with the c9 counterexample; round-clocked version added | §3.1, Prop 3.2a |
| m3 | Size of the constant; hybrid design; time-constructibility | Stated; hybrid design added; $p$ time-constructible assumed | Remark 3.1a |
| m4 | Samplers need their own mixture | Fixed | Prop 3.3 |
| m5 | Prop 2.8's sandwich is lopsided | Stated | Remark 2.8a |
| m6 | Per-step vs Cesàro comparison invalid | Agreed; kept as [refuted]; replaced by Cor 2.17 | Prop 2.12, Cor 2.17 |
| m7 | Semi-decidable $Q$ loses the bound, not a log term | Reworded | Remark 2.2 |
| m8 | $K(Q_p,b_p\mid p)$ was not conditional complexity | Fixed by reading $p$ first | Prop 2.3 |
| m9 | Prop 4.3: hypotheses of the two-sided reading; it is standard | Stated; cited as known | Prop 4.3 |
| m10 | GP classification partly provable | Added | Remark 4.8(b); c10 |
| m11 | History-aware time-bounded version undefined | Class defined; regret proved, time sketched | Prop 3.2c |
| m12 | Explicit constant in Thm 3.5 | Analytic: $L_B\le16m(d+1)\log_2(2(m+1)(d+2))$ for all $m>0$. The referee's $52md\log_2(md+2)$ holds only for $m\ge1$: for small $m$ the ratio grows with $d$ (c8) | Thm 3.5; c8 |
| m13 | Reference details | Corrected; "Thm 19" withdrawn (slides cite "Example 1"); Goldblum pages now confirmed by snippet | §6 |
| m14 | Missing related work | Added (Filan–Leike–Hutter; Schmidhuber; Leike–Hutter; Basri et al.; Cesa-Bianchi–Lugosi) | §6 |
| m15 | Shortest-proof labels not treated | Added | Example 2.15a |
| m16 | $4e$ can be $4e^2$ | Fixed | Cor 4.7 |
| m17 | LOO conjecture | Kept as conjecture with the referee's analysis; explained why the Markov argument of Cor 2.17 does not reach it | Remark 2.11, Remark 2.18 |
| Q5 | Polytime note's Remark 4 | Added | Cor 3.2b |

---

## 1. Setting and notation

The definitions follow the foundations track (`../foundations/notes.md`, cited as "foundations"), which fixes them for the paper. §1.4 maps the notation of `notes.md` to the one used here.

### 1.1 Objects

* **Inputs, outputs, data.** $X=Y=\{0,1\}^*$; sometimes $Y$ is a finite label set. A *data set* $D$ is a finite partial function $X\rightharpoonup Y$, written as a set of pairs; $\operatorname{dom}D$ is its domain; $D+(x,y)$ adds a pair with $x\notin\operatorname{dom}D$. For a function $f$ and a finite $B\subseteq X$, $f|_B$ is the restriction. $\log=\log_2$.
* **Programs.** $V$ is a fixed universal prefix machine; its domain $\operatorname{dom}V$ is prefix-free and $V(p)$ is an index of a partial computable function $\varphi_{V(p)}:X\rightharpoonup Y$. Write $p(x):=\varphi_{V(p)}(x)$. A program is self-delimiting **independently of the input**: $V$ reads $p$ before the input is used.
* **Complexities.** $K(\cdot)$ and $K(\cdot\mid\cdot)$ are prefix complexity and conditional prefix complexity (with the standard conditional machine, which may use the condition while reading its program). For a data set $D$, $K_F(D):=\min\{|p|:p\in\operatorname{dom}V,\ p\supseteq D\}$ (foundations Def 4.1). For a computable total $f$, $K(f):=K_F(f)=\min\{K(e):\varphi_e=f\}$ up to $O(1)$; for a partial computable $\varphi$, $K(\varphi)$ is the least $K(e)$ over its indices. The input-independent conditional complexity is $K^{\mathcal P}(z\mid x):=\min\{|h|:h\in\operatorname{dom}V,\ h(x)=z\}$. It satisfies [proved]
  $$K(z\mid x)-c\ \le\ K^{\mathcal P}(z\mid x)\ \le\ K(z\mid x)+K(K(z\mid x))+c .$$
  The upper bound: prefix a standard conditional program with a self-delimiting code of its length. The lower bound: every $h\in\operatorname{dom}V$ is a conditional program.
* **Program mixture** (deterministic SFI): $W(D):=\sum\{2^{-|p|}:p\in\operatorname{dom}V,\ p\supseteq D\}$. $W(\emptyset)\le1$.
* **Function machines and $M_F$** (foundations Def 2.5, Thm 3.2). A function machine $T$ maps a uniformly random infinite tape $\omega$ to a partial function $f^T_\omega$ whose value at $x$ is fixed by a finite prefix of $\omega$. The tape is **shared** by all inputs. Its law is $\nu_T(D):=\lambda\{\omega:f^T_\omega\supseteq D\}$ ($\lambda$ the fair-coin measure). The universal function machine $T_U$ first reads a $V$-program $p$ from the tape and then runs the machine $T_{V(p)}$ on the rest. Its law
  $$M_F(D)=\sum_im(i)\,\nu_{T_i}(D)\quad(D\ne\emptyset),\qquad M_F\ge2^{-K(\nu)}\nu\ \text{ for every machine law }\nu,$$
  is **SFI**. Machine laws include deterministic partial computable functions, lower-semicomputable product laws and computable random functions with finite label set (foundations Prop 3.3). $M_F\ge2^{-c}W$ (foundations Thm 4.2).
* **Other mixtures** (foundations §3–4). $M_{\rm prod}$ is the universal mixture of product laws $\prod_{(x,y)\in D}P(y\mid x)$ (private randomness per input; Solomonoff's operator induction as formalised there). $M^w$ is the universal *weak* function semimeasure: a map $\nu$ with $\nu(\emptyset)\le1$ and $\nu(D)\ge\sum_y\nu(D+(x,y))$ for $x\notin\operatorname{dom}D$ (foundations Def 2.1, Thm 3.4).

### 1.2 Conventions for predictions and errors

For $\nu\in\{W,M_F\}$ (and any weak semimeasure):
* **semimeasure-convention conditional:** $\nu(y\mid D,x):=\nu(D+(x,y))/\nu(D)$. Its defect $1-\sum_y\nu(y\mid D,x)$ is the posterior mass undefined at $x$. At an input $x\in\operatorname{dom}D$ the prediction is the stored label with probability 1.
* **normalised conditional:** $\bar\nu(y\mid D,x):=\nu(D+(x,y))/\sum_{y'}\nu(D+(x,y'))\ \ge\ \nu(y\mid D,x)$.
* For a target $f$ and inputs $x_1,x_2,\dots$, $D_k:=\{(x_j,f(x_j)):j\le k\}$. The **posterior error** at step $k$ is $e_k:=1-\nu(f(x_k)\mid D_{k-1},x_k)$: the mass that is wrong *or undefined* at $x_k$. At a single test point $x^*$ with training labels $f|_A$:
  * $e(x^*):=1-\nu(f(x^*)\mid f|_A,x^*)$ (semimeasure convention);
  * $e^{\rm wr}(x^*):=\sum_{y\ne f(x^*)}\nu(f|_A+(x^*,y))/\nu(f|_A)$ (defined and wrong);
  * $e_{\rm norm}(x^*):=1-\bar\nu(f(x^*)\mid f|_A,x^*)$ (normalised).

  Always $e^{\rm wr}\le e_{\rm norm}\le e$, because $\sum_y\nu(f|_A+(x^*,y))\le\nu(f|_A)$ [proved]. So every **lower** bound proved below for $e^{\rm wr}$ holds in both conventions, and every **upper** bound proved for $e$ holds in both.

### 1.3 Facts used throughout

* **Fact A (chain rule; order independence)** [proved, trivial; foundations Prop 5.2]. For every enumeration of $D_n$,
  $$\sum_{k\le n}-\log\nu(y_k\mid D_{k-1},x_k)=-\log\frac{\nu(D_n)}{\nu(\emptyset)}\ \le\ -\log\nu(D_n),$$
  by telescoping. The total loss depends only on the set $D_n$.
* **Fact B (conditional coding theorem)** [known: Levin 1974; Gács 1974; Chaitin 1975; Li & Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed. 2008, §4.3 (unverified section number)]. Let $z\mapsto\mu(\cdot\mid z)$ be semimeasures on a countable set ($\sum_x\mu(x\mid z)\le1$), lower semicomputable uniformly in $z$. Then $\mu(x\mid z)\le2^{-K(x\mid z)+c_\mu}$. The constant does not depend on the family member when $z$ is itself a program that lower-semicomputes $\mu(\cdot\mid z)$.
* **Fact C (Kraft)** [known]. $\sum_x2^{-K(x\mid z)}\le1$ for every $z$.
* **Fact D (lower bounds by deterministic programs)** [proved]. If $p\in\operatorname{dom}V$ and $p\supseteq D$, then $W(D)\ge2^{-|p|}$ and $M_F(D)\ge2^{-|p|-c}$. In particular $W(f|_B)\ge2^{-K_F(f|_B)}$ and $M_F(f|_B)\ge2^{-K_F(f|_B)-c}$.

### 1.4 Notation map

| `notes.md` (old) | here and in foundations | history track | examples track |
|---|---|---|---|
| $U$ (universal prefix machine), $U(p,x)$ | $V$, $p(x)=\varphi_{V(p)}(x)$ | $U(p,x)$ | as foundations |
| $V$ (universal function machine) | $T_U$; law $M_F$ | $U^\omega$; law $M_F$ | as foundations |
| $K_B(f)$ | $K_F(f\vert_B)$ | — | — |
| $K_F(f)$ ($f$ total) | $K(f)$ | $K(g)$ | $K(f)$ |
| $-\log\nu(D_n)$ | $L_n$ (foundations), $-\log M_F(D_n)$ | $L_F(D_n)$ | $L_{\rm SFI}(D_n)$ |
| (F1) chain rule, (F2) coding theorem | Fact A, Fact B | (F4) coding theorem | (F3) coding theorem |

The numbering of the results of `notes.md` that other tracks cite (Props 2.1, 2.3, 2.4, Thm 2.5, Thm 2.7, Example 2.15) is unchanged. New results get new numbers.

---

## 2. Out-of-distribution generalisation (H8)

A "property" is a set $Q\subseteq X$. $Q$ **separates** $x^*$ from a training set $A$ if $x^*\in Q$ and $Q\cap A=\emptyset$. $K(Q,b)$ is the prefix complexity of a pair $\langle e,e'\rangle$ of indices, where $\varphi_e$ is total and decides $Q$ and $\varphi_{e'}$ computes $b$ (on $Q\cap\operatorname{dom}b$). Up to $O(1)$, $K(Q,b)\le K(Q)+K(b)+O(1)$.

### 2.1 Hänni's proposition, with no log term

**Proposition 2.1 (unseen simple property ⇒ constant probability of any simple behaviour) [proved].**
Let $Q$ be decidable and $b$ partial computable. Let $D$ be a data set with $\operatorname{dom}D\cap Q=\emptyset$, $S\subseteq Q\cap\operatorname{dom}b$ finite, and $E:=b|_S$. Then, with $c$ depending only on $V$:
1. $W(D\cup E)\ge2^{-K(Q,b)-c}\,W(D)$. Moreover the programs consistent with $D$ that agree with $b$ on **all** of $Q\cap\operatorname{dom}b$ have total weight $\ge2^{-K(Q,b)-c}W(D)$.
2. $M_F(D\cup E)\ge2^{-K(Q,b)-c}\,M_F(D)$, and likewise for the event "agrees with $b$ on all of $Q\cap\operatorname{dom}b$".
3. The shortest program consistent with $D\cup E$ is at most $K(Q,b)+c$ bits longer than the shortest program consistent with $D$.

So the posterior probability that SFI behaves like $b$ on all of $S$ is at least $2^{-K(Q,b)-c}$, whatever $D$ is and however large. When $|S|=1$ this is a lower bound on $e^{\rm wr}$ if $b$ is wrong there, so it holds in both conventions (§1.2). Example: with $b\equiv0$, SFI outputs $0$ on all unseen $Q$-inputs with probability at least $2^{-K(Q)-c}$.

*Proof.*
1. Let $V'$ be the prefix machine that reads a $V$-program $z$ (delimited by simulating $V$), obtains $\langle e,e'\rangle=V(z)$, then reads a $V$-program $p$ (delimited the same way), and outputs an index of the function $x\mapsto\varphi_{e'}(x)$ if $\varphi_e(x)=1$, and $x\mapsto p(x)$ otherwise. $\operatorname{dom}V'$ is prefix-free. By universality there is a fixed string $w$ with $V(wu)=V'(u)$ for all $u$. The map $p\mapsto wzp$ is injective. If $p$ is consistent with $D$, so is $wzp$, because the inputs of $D$ are not in $Q$; and $wzp$ agrees with $b$ on $Q\cap\operatorname{dom}b$. Summing over consistent $p$ gives $W(D\cup E)\ge2^{-|w|-|z|}W(D)$. Take $|z|=K(Q,b)$ and $c=|w|$.
2. Let $T_{Q,b}(x,\omega):=b(x)$ if $x\in Q$ and $f^{T_U}_\omega(x)$ otherwise. It is a function machine with an index computable from $\langle e,e'\rangle$. Every $\omega$ with $f^{T_U}_\omega\supseteq D$ has $f^{T_{Q,b}}_\omega\supseteq D\cup b|_{Q\cap\operatorname{dom}b}$. So $\nu_{T_{Q,b}}(D\cup E)\ge M_F(D)$, and universality gives the claim. The infinite event is a countable intersection of events, and the same inclusion applies to it.
3. Part 1 applied to one shortest $p$. ∎

**Remark 2.2 (where a log term would come from; reworded after referee m7).** Hänni asked whether "some log term" is lost and whether the universal semimeasure avoids it.
* No log term arises, for $W$ or for $M_F$. The modified program is a concatenation of self-delimiting codes, and the proof sums over all consistent programs. $M_F$ is not needed for this.
* With **plain** complexity $C(Q)$ one pays $K(Q)\le C(Q)+K(C(Q))+O(1)\le C(Q)+2\log C(Q)+O(1)$. This is a log term.
* If $Q$ is only **semi-decidable**, the argument does not give a weaker bound; it gives none. The wrapper cannot decide $Q$ and would have to race "$Q$ accepts $x$" against "$p$ halts on $x$". A decidable subset $Q_t=\{x:Q\text{ accepts }x\text{ within }t(|x|)\text{ steps}\}$, for a simple computable $t$, restores the bound on $Q_t$.
* Comparing a single modified program with the total posterior gives $2^{-K(Q,b)-c}$ times that program's posterior weight; summing over programs avoids this.

**Proposition 2.3 (properties simple given a training-consistent program) [proved; corrected after referee m8].** Let $p\in\operatorname{dom}V$ be consistent with $D$. Let $q,r$ be indices of functions taking $p$ as an auxiliary input: $Q_p:=\{x:\varphi_q(\langle p,x\rangle)=1\}$ with $\varphi_q(\langle p,\cdot\rangle)$ total, and $b_p(x):=\varphi_r(\langle p,x\rangle)$. Let $K(q,r\mid p)$ be the conditional prefix complexity of the pair given $p$. If $Q_p\cap\operatorname{dom}D=\emptyset$ and $S\subseteq Q_p\cap\operatorname{dom}b_p$ is finite, then
$$W(D\cup b_p|_S)\ \ge\ 2^{-K(q,r\mid p)-c}\cdot2^{-|p|},\qquad\text{so}\qquad \frac{W(D\cup b_p|_S)}{W(D)}\ \ge\ 2^{-K(q,r\mid p)-c}\cdot\frac{2^{-|p|}}{W(D)}.$$
The last factor is the posterior probability of the program $p$. The same holds for $M_F$ with $2^{-|p|}/M_F(D)$, by $M_F\ge2^{-c}W$.

*Proof.* The wrapper reads $p$ first (delimited by simulating $V$), then a conditional program $z$ for $\langle q,r\rangle$ given $p$ (delimited by the conditional universal machine, which knows $p$). On input $x$ it outputs $b_p(x)$ if $x\in Q_p$ and $p(x)$ otherwise. The set of strings $wpz$ is prefix-free, its length is $|w|+|p|+K(q,r\mid p)$, and it is consistent with $D\cup b_p|_S$. ∎

`notes.md` read $z$ before $p$; then $z$ cannot use $p$, and the quantity was the complexity of the pair, not the conditional complexity. Reading $p$ first gives the genuine conditional complexity. This is Hänni's worry about "an internal variable set to 0". If the MAP program has an internal variable that never triggers on training inputs, a test property defined through it is simple *relative to the program* even if it is complex in absolute terms. When that program carries a constant fraction of the posterior, bad behaviour on the property gets probability $2^{-O(\text{bits to name the variable})}$.

**Proposition 2.4 (dependence on the universal machine) [proved].** Fix $V$, a decidable $Q$ and a partial computable $b$. Let $V'(0u):=V(u)$, and let $V'(1u)$ be an index of $x\mapsto b(x)$ if $x\in Q$, else $\varphi_{V(u)}(x)$. Then $V'$ is a universal prefix machine; for every $D$ with $\operatorname{dom}D\cap Q=\emptyset$ and every finite $S\subseteq Q\cap\operatorname{dom}b$, $W'(D)=W(D)$ and $W'(D\cup b|_S)/W'(D)\ge\tfrac12$; and $2^{-K(Q,b)-c}W'\le W\le2W'$.

*Proof.* The programs $0u$ consistent with $D$ have total weight $W(D)/2$. The programs $1u$ consistent with $D$ also have weight $W(D)/2$, since they agree with $u$ off $Q$, and all of them output $b$ on $S$. $V$ simulates $V'$ with overhead $K(Q,b)+c$ (the wrapper of Prop 2.1), and $V'$ simulates $V$ with overhead 1. ∎

So Hänni's "there's a programming language in which [good behaviour] doesn't have a better const" is right. The language must be at least about $\log(\text{posterior odds})$ bits from the reference machine, and it is tailored to one property and one behaviour. This is the supervised, single-property analogue of the "bad universal priors" of Leike & Hutter (COLT 2015, PMLR 40:1244–1259) [known (snippet): there, adversarial choices of the universal machine make AIXI misbehave and make Legg–Hutter intelligence subjective].

### 2.2 The PDF draft's two-sided "result", reconstructed

The draft (`hanni-sfi-draft-2025-09.txt`, §3) says: "the probability of $P$-abiding generalization is at least $2^{-C(P)}$" and "if no input with property $Q$ is seen during training, then probability of $P$-abiding generalization is at most $2^{-C(Q)}$ times 2 to the negative complexity of the smallest string not satisfying $P$ on the given input times a const". Here $P\subseteq X\times Y$ is a property of input–output pairs (e.g. "$y$ is a correct proof of $x$").

**Theorem 2.5 (two-sided bound on $P$-abiding generalisation) [proved].** Let $Q$ be decidable, $D$ a data set with $\operatorname{dom}D\cap Q=\emptyset$, $S\subseteq Q$ finite and nonempty, and $\nu\in\{W,M_F\}$. $K(P,Q)$ is the complexity of a pair (decider of $Q$, enumerator of $P$ or of its complement, as appropriate).
1. **Lower bound.** If $P$ is r.e. and every $x\in Q$ has some $y$ with $(x,y)\in P$, then $\nu(\text{every }x\in S\text{ gets a }P\text{-abiding output}\mid D)\ge2^{-K(P,Q)-c}$.
2. **Upper bound.** If $(X\times Y)\setminus P$ is r.e. (e.g. $P$ decidable) and every $x\in Q$ has some $y$ with $(x,y)\notin P$, then $\nu(\text{some }x\in S\text{ gets a }P\text{-violating output}\mid D)\ge2^{-K(P,Q)-c}$. Consequently $\nu(\text{every }x\in S\text{ is }P\text{-abiding}\mid D)\le1-2^{-K(P,Q)-c}$.
3. **Single-input form.** For $x\in Q$ and any $z$ with $(x,z)\notin P$: $M_F(D+(x,z))\ge2^{-K(Q)-K(z\mid x)-c}M_F(D)$ and $W(D+(x,z))\ge2^{-K(Q)-K^{\mathcal P}(z\mid x)-c}W(D)$. So for $M_F$ the probability of a $P$-abiding output at $x$ is at most $1-2^{-K(Q)-\min_{z:(x,z)\notin P}K(z\mid x)-c}$, and for $W$ the same with $K^{\mathcal P}$.

*Proof.*
1. Let $b_P(x)$ be the first $y$ found in a fixed enumeration of $P$ with first coordinate $x$. It is partial computable, total on $Q$, and $K(Q,b_P)\le K(P,Q)+O(1)$. Apply Prop 2.1.
2. The same with $b_{\neg P}$ from an enumeration of the complement. For the consequence: the events "all abiding" and "some violating" are disjoint sets of labellings of $S$, and for $W$ (disjoint program sets) and $M_F$ (disjoint tape sets) $\sum_E\nu(D\cup E)\le\nu(D)$ over labellings $E$ of $S$.
3. For $W$: let $h\in\operatorname{dom}V$ be shortest with $h(x)=z$ and apply Prop 2.1 with $b:=h$, using $K(Q,b)\le K(Q)+|h|+O(1)$. For $M_F$: let $T(x',\omega)$ split $\omega$ into even and odd bits; if $x'\in Q$, run the conditional universal prefix machine on $x'$, reading program bits lazily from the odd bits; otherwise run $T_U$ on the even bits. The streams are independent and uniform, so $\nu_T(D+(x,z))=M_F(D)\cdot\sum\{2^{-|u|}:u\text{ outputs }z\text{ on }x\}\ge M_F(D)2^{-K(z\mid x)}$. Universality costs $K(Q)+c$. ∎

**Reading of the draft.** Its upper bound must be read as a lower bound on the probability of *violation*; this is part 3, with "the smallest string not satisfying $P$" as the simplest violating output. Taking $z_x$ to be the first violating output in an enumeration gives $K(z_x\mid x)\le K(P)+O(1)$, so part 3 contains part 2's form for each input. The draft's summary ("good ood generalization ... has at least a const probability of happening but also at least some const probability of not happening") is exactly parts 1–2, uniformly in the amount of training data, as long as no training input lies in $Q$.

**Proposition 2.6 (the draft's two bounds as literally stated are false) [refuted, with counterexamples; proved].**
* (a) *Literal upper bound.* Let $P=\{(x,0)\}$. Let $Q_n$ be decidable with $K(Q_n)\to\infty$, let $D$ label inputs outside $Q_n$ with 0, and let $x^*\in Q_n$. The constant-0 program $p_0$ is consistent with $D+(x^*,0)$, so $\nu((x^*,0)\mid D)\ge2^{-|p_0|-c}/\nu(D)\ge2^{-|p_0|-c}$, a fixed positive constant. The literal claim, "$\le c\,2^{-K(Q_n)}2^{-K(z)}$", tends to 0.
* (b) *"At least $2^{-C(P)}$" without a separating property.* Let $P=\{(x,0)\}$, so $K(P)=O(1)$. Fix $n$ and $x^*\in\{0,1\}^n$ with $K(x^*\mid n)\ge n$. Let $D=\{(x,1):x\in\{0,1\}^n,\ x\ne x^*\}$. Then $\nu((x^*,0)\mid D)\le2^{-n+c'}$ for $\nu\in\{W,M_F\}$, also normalised.
  * *Proof.* Let $\mu_n(x):=\nu(\{(x',1):x'\ne x\}\cup\{(x,0)\})$ for $x\in\{0,1\}^n$. The events are disjoint, so $\sum_x\mu_n(x)\le1$, and $\mu_n$ is lower semicomputable uniformly in $n$. Fact B gives $\mu_n(x^*)\le2^{-K(x^*\mid n)+c}\le2^{-n+c}$. The constant-1 program gives $\nu(D)\ge2^{-c_1}$. ∎
  * Theorem 2.5(1) with $Q=\{x^*\}$ ($K(Q)\le n+2\log n+c$) gives the lower bound $2^{-n-2\log n-c}$. So the $K(Q)$ term in Theorem 2.5 is necessary and nearly tight here.

### 2.3 OOD failure is a bounded resource

**Theorem 2.7 (cumulative bound) [proved].** Let $f$ be computable. Let $x_1,x_2,\dots$ be any sequence of distinct inputs (adversarial, adaptive or non-computable). Then for every $n$, with $c=0$ for $W$ and a machine constant for $M_F$:
$$\sum_{k\le n}-\log(1-e_k)\le K(f)+c,\qquad\sum_{k\le n}e_k\le(\ln2)(K(f)+c),\qquad\#\{k:e_k\ge\delta\}\le\frac{(\ln2)(K(f)+c)}{\delta}.$$
The same holds for the normalised errors, and with $K(f)$ replaced by $K_F(f|_B)$, $B=\{x_1,\dots,x_n\}$.

*Proof.* By Fact A the left sum is $-\log(\nu(D_n)/\nu(\emptyset))\le-\log\nu(D_n)\le K_F(f|_B)+c$ (Fact D). Then $-\ln(1-e)\ge e$, and Markov's inequality for the count. ∎

**Proposition 2.8 (the novelty budget) [proved].** For binary $Y$, let $\sigma_k:=\min\{K(Q):Q\text{ decidable},\ x_k\in Q,\ Q\cap\{x_1,\dots,x_{k-1}\}=\emptyset\}$. Then $e_k\ge e^{\rm wr}_k\ge2^{-\sigma_k-c}$ for every $k$, and $\sum_k2^{-\sigma_k}\le1$.

*Proof.* Prop 2.1 with $b\equiv1-f(x_k)$, a constant of complexity $O(1)$. A fixed $Q$ separates $x_k$ from its predecessors for at most one $k$: once some $x_k\in Q$ has been seen, $Q$ separates no later input. So distinct $k$ use distinct minimising $Q$'s, whose shortest codes are distinct elements of a prefix-free set; Kraft's inequality applies. ∎

**Remark 2.8a (what Prop 2.8 does and does not say; corrected after referee m5).** `notes.md` read Prop 2.8 as "SFI's total OOD error lies between the input sequence's novelty and $f$'s complexity". That reading is lopsided. Since $\sum_k2^{-\sigma_k}\le1$, the novelty lower bound $2^{-c}\sum_k2^{-\sigma_k}$ is always at most $2^{-c}$. Separation arguments can therefore force a constant error at individual steps, but never more than $O(1)$ cumulative error. The upper bound $(\ln2)(K(f)+c)$ of Theorem 2.7 is the binding one. Each simple property can cause surprise only once. Calling this a formalisation of Hänni's "fake OOD generalization ... where you've already seen many 'ood generalizations' of the same kind" is an interpretation, not a theorem.

Combined with $x$-only dominance (foundations Thm 6.1), the positive statement is relative. If a computable $x$-only predictor $P$ generalises correctly across all the shifts, SFI's total excess log loss over $P$ is at most $K(P)+O(1)$ bits. Hänni's "human inductor" argument needs more: the human generalises *after seeing the data*, i.e. is history-aware, and the $x$-only theorem does not cover such predictors (history track, H3). The chronological version (history track Cor 4.3) is needed for that.

### 2.4 Positive results, and the converse

**Proposition 2.9 (random splits generalise, for every input set) [proved; computed, c3 Part 3; standard argument].** Let $B$ be any finite input set, $|B|=N$ (possibly adversarial), and $f$ any labelling of $B$. Choose a uniformly random order of $B$ and an independent uniform split point $k\in\{1,\dots,N\}$; train on the first $k-1$ inputs and test on the $k$-th. Then
$$\mathbb E_{\pi,k}\big[-\log\nu(f(x_{\pi(k)})\mid D_{\pi,k-1},x_{\pi(k)})\big]=\frac{-\log(\nu(f|_B)/\nu(\emptyset))}{N}\le\frac{K_F(f|_B)+c}{N},$$
and $\mathbb E[e]\le(\ln2)(K_F(f|_B)+c)/N$.

*Proof.* By Fact A, for each order the step losses sum to the order-free total. Average over $k$. ∎

This is the exchangeability form of online-to-batch conversion, applied to SFI [known as a technique: Littlestone, "From on-line to batch learning", COLT 1989; Cesa-Bianchi, Conconi & Gentile, *IEEE Trans. Inf. Theory* 50(9):2050–2057, 2004 (unverified); a permutation argument of this kind is used by Haussler, Littlestone & Warmuth, "Predicting {0,1}-functions on randomly drawn points", *Inf. Comput.* 115(2):248–292, 1994 (bibliography snippet-verified; content unverified)]. What SFI adds is order independence (Fact A), which makes the identity exact for every input set. Monte Carlo on a toy mixture: $1.8230\pm0.0071$ against total$/N=1.8200$ [computed, c3].

**Proposition 2.10 (leave-one-out) [proved; computed, c7 part (1)].** For $\nu\in\{W,M_F\}$, $f$ on $B$, $|B|=N$, and $e_{\rm LOO}(x):=1-\nu(f|_B)/\nu(f|_{B\setminus x})$:
$$\sum_{x\in B}e_{\rm LOO}(x)\ \le\ \frac{\nu(\emptyset)-\nu(f|_B)}{\nu(f|_B)}\ <\ 2^{K_F(f|_B)+c}.$$

*Proof.* $e_{\rm LOO}(x)\,\nu(f|_{B\setminus x})=\nu(f|_{B\setminus x})-\nu(f|_B)$ is the mass of hypotheses (programs or tapes) correct on $B\setminus x$ and not correct at $x$. These sets are disjoint for different $x$, because such a hypothesis fails at exactly one point of $B$, and none of them is correct on all of $B$. So the sum of the masses is $\le\nu(\emptyset)-\nu(f|_B)$. Finally $\nu(f|_{B\setminus x})\ge\nu(f|_B)$ and Fact D. ∎

**Remark 2.11 (learning curves can increase; the LOO conjecture) [computed, c3 Part 2; conjecture].**
* Consider a Bayes mixture of the truth $f$ (weight $w_f$) and $N$ hypotheses each wrong at exactly one point of $B$ (weight $w$ each). The step-$k$ loss $\log\frac{w_f+w(N-k+1)}{w_f+w(N-k)}$ is the same for every order and **increases** with $k$. With $w=w_f=1/(N+1)$ and $N=16$, the last step (leave-one-out) costs 1 bit while the random-split average is $0.255$ bits [computed]. Kraft allows this only with $N\le2^{K}-1$ when $w=w_f=2^{-K}$, so Prop 2.10 is tight up to constants for general prior-weighted mixtures.
* **Conjecture 2.11.** For SFI's weights, $\frac1N\sum_{x\in B}e_{\rm LOO}(x)=O(K_F(f|_B)/N)$, up to logarithmic factors.
  * Heuristic: the natural one-exception hypotheses "$f$ except at $x$" have weight about $2^{-K(f)-K(x\mid f)}$, and $\sum_x2^{-K(x\mid f)}\le1$.
  * The referee could not refute it either. A counterexample needs $\gg K$ points $x$ whose one-point flips $f^x$ have $K(f^x)\lesssim K(f)$; by symmetry of information this needs $K(x\mid f^{x})\approx K(x\mid f)$ for many $x$. Natural attempts (halting-set indicators, pseudo-random seeds, thresholds) give $O(1)$ or $O(K)$ bad points.
  * Consequence, if true: Remark 2.18.

**Proposition 2.12 (separating properties are typical even in distribution) [proved; computed, c4].** Let $f\equiv0$ on $\{0,1\}^n$; let $x_1,\dots,x_m$ be i.i.d. uniform training inputs and $x^*$ an independent uniform test input, with $n\ge\ell:=\lceil\log m\rceil+1$. Let $\pi$ be the $\ell$-bit prefix of $x^*$ and $Q_\pi$ the set of strings starting with $\pi$. Then:
1. $\Pr[Q_\pi\text{ separates }x^*\text{ from the training set}]=(1-2^{-\ell})^m\ge1-m2^{-\ell}\ge1/2$;
2. $K(Q_\pi)\le\ell+2\log(\ell+1)+c$;
3. $\mathbb E[e^{\rm wr}(x^*)]\ge\frac12\cdot2^{-\ell-2\log(\ell+1)-c}\ge\frac{2^{-c}}{8m(\log m+3)^2}$, for $W$ and $M_F$, hence in both conventions.

*Proof.* (1) Each training input independently avoids the prefix with probability $1-2^{-\ell}$; Bernoulli's inequality and $2^{-\ell}\le1/(2m)$. (2) An Elias-type code for $\pi$. (3) Prop 2.1 with $b\equiv1$ on the event of (1), and $2^{-\ell}\ge1/(4m)$. ∎

* For general binary $f$, take $b=1-f$: $\mathbb E[e^{\rm wr}]\ge2^{-K(f)-c}/(8m(\log m+3)^2)$.
* Computed (c4, $n=48$): the separating complexity $\sigma$ (1 + the longest common prefix with a training input) has median $\approx\log m+1$; $\Pr[\sigma\le\lceil\log m\rceil+1]\in[0.63,0.76]$, matching the exact value; $m\cdot\mathbb E[2^{-\sigma-2\log(\sigma+1)}]\cdot\log^2m\in[0.45,0.68]$ for $m=10,\dots,10^4$.
* **[refuted] in `notes.md`:** "this matches the $O(1/m)$ Cesàro upper bound up to $\log^2m$". The comparison was between a per-step lower bound and an average over steps, which proves nothing about the per-step rate (since $\sum_k\mathbb E e_k<\infty$, $\liminf_m m\,\mathbb E e_m=0$). The correct per-step upper bound is Cor 2.17 below.
* So "no simple property separates test from train" can hold typically only at scales $s\lesssim\log m$.

**Proposition 2.13 (the naive converse is false for random targets) [proved].** Let $f:\{0,1\}^n\to\{0,1\}$ be uniformly random, and $A=\{x_1,\dots,x_m\}$, $x^*$ i.i.d. uniform, all independent.
1. For every learner, SFI included, $\mathbb E[e_{\rm norm}(x^*)\mid x^*\notin A]\ge1/2$.
2. Let $z$ be any string determined by $f$ (e.g. a shortest program for $f$). For every $s\ge0$,
   $$\Pr\big[\exists\text{ decidable }Q:\ K(Q\mid z)\le s,\ Q\text{ separates }x^*\text{ from }A\big]\le\frac{2^{s+1}}{m+1}.$$

*Proof.* (1) Given $(A,f|_A,x^*)$ with $x^*\notin A$, the label $f(x^*)$ is a fair coin independent of the predictor's output $(q_0,q_1)$, $q_0+q_1\le1$, so the expected error is $\ge1-\frac{q_0+q_1}2\ge\frac12$. (2) Condition on $f$, hence on $z$. Fewer than $2^{s+1}$ properties have $K(Q\mid z)\le s$. For each, with density $\delta$, $\Pr[x^*\in Q,\ A\cap Q=\emptyset]=\delta(1-\delta)^m\le\frac1{m+1}$. Union bound. ∎

So "no property separating test from train that is simple relative to a good program" does not imply good generalisation **when $f$ is random** ($K(f)\gg m$). The obstruction is information-theoretic, not a defect of SFI. `notes.md` drew a broader conclusion ("no bound of the form 'no simple separating property ⇒ small error' holds"); that is **[refuted]** as stated, by Prop 2.16: for simple $f$, with properties simple given the labelled sample, such a bound holds.

**Proposition 2.14 (sandwich for a single test point) [proved].** Let $A$ be finite, $x^*\notin A$, $B=A\cup\{x^*\}$, $y\ne f(x^*)$, $\lambda_y:=f|_A+(x^*,y)$, and $\nu\in\{W,M_F\}$. Then for every decidable $Q$ separating $x^*$ from $A$ and every partial computable $b$ with $b(x^*)=y$:
$$2^{-K(Q,b)-c}\ \le\ \frac{\nu(\lambda_y)}{\nu(f|_A)}\ \le\ 2^{K_F(f|_A)-K(\lambda_y\mid B)+c}.$$

*Proof.* Left: Prop 2.1. Right: for a finite set $B$ given as a list, $\lambda\mapsto\nu(\lambda)$ on labellings of $B$ is a semimeasure (disjoint program or tape sets), lower semicomputable uniformly in $B$; Fact B gives $\nu(\lambda_y)\le2^{-K(\lambda_y\mid B)+c}$. Fact D gives $\nu(f|_A)\ge2^{-K_F(f|_A)-c}$. ∎

SFI errs at $x^*$ only if some wrong completion $\lambda_y$ is, *given the full input set*, not much more complex than the training labels are to produce *by a program that does not know $A$*. A simple separating property makes $\lambda_y$ cheap given $B$, because $x^*$ is the unique element of $B\cap Q$. The gap between $K(\cdot\mid B)$ and $K_F(\cdot)$ is where knowledge of the other inputs would help; it is the same gap as between $x$-only and history-aware prediction (history track Thm 5.2; examples track H5).

**Example 2.15 (easy-to-hard generalisation) [proved].**
* *Setting.* Inputs are sentences of a consistent theory $T$ with decidable proof checking. The label is 1 if $T$ proves the sentence and 0 if $T$ refutes it. All training statements have a proof or refutation of length $\le L$. The test statement $x^*$ is decidable in $T$, but its shortest proof or refutation is longer than $L':=2^{\lceil\log L\rceil}\ (\le2L)$.
* $Q:=\{x:\text{no proof or refutation of }x\text{ of length}\le L'\}$ is decidable given $T$ and $L'$, separates $x^*$ from the training set, and $K(Q)\le K(T)+K(\lceil\log L\rceil)+c\le K(T)+2\log\log L+c$ for large $L$.
* By Prop 2.1 with $b\equiv0$ and $b\equiv1$, one of which is wrong at $x^*$, SFI's error at $x^*$ is $\ge2^{-K(Q)-c}\ge2^{-K(T)-c'}/\log^2L$, however many easy statements were seen.
* The proof-search program has length $K(T)+c$ and is consistent with every correctly labelled data set, so the correct label has probability $\ge2^{-K(T)-c}$.
* So the probability of the correct label on the hard statement lies in $[2^{-K(T)-c},\,1-2^{-K(T)-c'}/\log^2L]$, independently of the number of training statements. This makes precise Hänni's remarks that "easy-to-hard generalization is not a thing" for SI and that task decomposition creates a simple separating property.
* Relative to the proof-search program the bound is much stronger (Prop 2.3): the wrong label has probability $\ge2^{-K(L'\mid p)-c}$ times the posterior weight of proof search (examples track §5.1).
* The same analysis applies to the "lengths of odd strings" example: the correct generalisation to even lengths has probability in $[2^{-c},1-2^{-c}]$ with machine constants, because "$|x|$ is even" and "output 0" are $O(1)$ bits.

**Example 2.15a (shortest proofs as labels; referee m15) [proved].** Label each provable sentence by its shortest proof (the first in a fixed enumeration among the shortest). $P:=\{(x,y):y\text{ is that proof of }x\}$ is decidable given $T$. Let all training sentences have shortest proofs of length $\le L$, and the provable test sentence $x^*$ none of length $\le L'$. With $Q$ as in Example 2.15 and the violating output $z=\varepsilon$ (not a proof, $K(\varepsilon\mid x^*)=K^{\mathcal P}(\varepsilon\mid x^*)=O(1)$), Theorem 2.5(3) gives
$$\nu(\text{output at }x^*\text{ is not its shortest proof}\mid D)\ \ge\ 2^{-K(T)-2\log\log L-c}\qquad(\nu\in\{W,M_F\}),$$
for every number of training sentences. The intended answer has probability $\ge2^{-K(T)-c}$ (search proofs by length). This matches the examples track §5.2.

**Proposition 2.16 (converse given the labelled sample) [proved; new].** Let $\nu\in\{W,M_F\}$, $B$ finite, $f$ a labelling of $B$ (a data set with domain $B$), $x^*\in B$, $A:=B\setminus\{x^*\}$. Then
$$e^{\rm wr}(x^*)\ \le\ e_{\rm norm}(x^*)\ \le\ 2^{\,K_F(f)-K(x^*\mid f)+c},$$
where $K(x^*\mid f)$ is conditional on the finite object $f$. Moreover:
1. $|K(x^*\mid f)-\sigma(x^*;A\mid f)|\le c$, where $\sigma(x^*;A\mid f):=\min\{K(Q\mid f):Q\text{ decidable},\ x^*\in Q,\ Q\cap A=\emptyset\}$ is the least complexity, *given the labelled sample*, of a property separating $x^*$ from $A$.
2. With $\sigma(x^*;A):=\min\{K(Q):Q\text{ separates }x^*\text{ from }A\}$ (unconditional) and any $y\ne f(x^*)$:
   $$2^{-\sigma(x^*;A)-K(y)-c}\ \le\ e^{\rm wr}(x^*)\ \le\ e_{\rm norm}(x^*)\ \le\ 2^{\,K_F(f)-\sigma(x^*;A\mid f)+c}.$$
3. Conditioning on the input set only: $e_{\rm norm}(x^*)\le2^{\,2K_F(f)-K(x^*\mid B)+c}$ (the referee's R1).

*Proof.* For $x\in B$ let $\mu_f(x):=\sum_{y\ne f(x)}\nu(f|_{B\setminus x}+(x,y))$, the mass of hypotheses that agree with $f$ on $B\setminus\{x\}$ and give a defined wrong label at $x$. A hypothesis in the set for $x$ disagrees with $f$ at $x$ and agrees at every other point of $B$, so the sets for distinct $x$ are disjoint. Hence $\sum_{x\in B}\mu_f(x)\le\nu(\emptyset)\le1$ [computed on a finite mixture, c7 part (1)]. $\mu_f(x)$ is lower semicomputable uniformly in $(f,x)$: enumerate programs (for $W$) or tape cylinders (for $M_F$). Fact B gives $\mu_f(x^*)\le2^{-K(x^*\mid f)+c}$. Since $\sum_y\nu(f|_A+(x^*,y))\ge\nu(f)\ge2^{-K_F(f)-c}$ (Fact D),
$$e_{\rm norm}(x^*)=\frac{\mu_f(x^*)}{\sum_y\nu(f|_A+(x^*,y))}\le2^{K_F(f)-K(x^*\mid f)+c}.$$
(1) $Q=\{x^*\}$ is decidable from $x^*$, so $\sigma(x^*;A\mid f)\le K(x^*\mid f)+c$. Conversely, given $f$ (hence $B$) and a decider for a separating $Q$, $x^*$ is the unique element of $B\cap Q$, so $K(x^*\mid f)\le\sigma(x^*;A\mid f)+c$. (2) The lower bound is Prop 2.1 with $b\equiv y$; the upper bound is the main claim with (1). (3) $K(x^*\mid B)\le K(x^*\mid f)+K(f\mid B)+c$ and $K(f\mid B)\le K_F(f)+c$ (run a shortest consistent program on the list $B$). ∎

*Reading.* If $f$ is simple on the sample and no property that is simple **given the labelled sample** separates the test point from the rest, SFI's error at the test point is small. The two sides of (2) differ by $K_F(f)+K(y)$ plus the difference between unconditional and conditional separating complexity. Prop 2.13 is consistent with this: there $K_F(f)\approx|B|$, and the bound is vacuous. The mass *undefined* at $x^*$ is not lower semicomputable, so the argument does not bound the semimeasure-convention $e(x^*)$ pointwise; Cor 2.17 bounds it in distribution.

**Corollary 2.17 (per-step in-distribution error) [proved; computed, c7 parts (3)–(4); new].** Let $\pi$ be any distribution on $X$ (not necessarily computable), $f$ partial computable with $\pi(\operatorname{dom}f)=1$, and $x_1,\dots,x_m,x^*$ i.i.d. from $\pi$. Let $\nu\in\{W,M_F\}$ and let $e$ be the semimeasure-convention error (so the bounds also hold normalised).
* **(a) Markov form.** For every $\varepsilon\in(0,1)$,
  $$\mathbb E\,e(x^*)\ \le\ \varepsilon+2^{K(f)+c}e^{-\varepsilon m},\qquad\text{hence}\qquad \mathbb E\,e(x^*)\ \le\ \frac{(K(f)+c)\ln2+\ln m+1}{m}.$$
  For $\delta\in(0,1)$, with probability at least $1-\delta$ over the training sample, $\mathbb E_{x^*}[e(x^*)\mid D_m]\le\varepsilon+2^{K(f)+c}e^{-\varepsilon m}/\delta$. The posterior-majority predictor errs at $x$ only if $e(x)\ge\frac12$, so its expected 0–1 risk is at most $2\,\mathbb E\,e(x^*)$.
* **(b) Exchangeability form.** $\mathbb E\,e(x^*)\le\mathbb E\big[\frac{\nu(\emptyset)-\nu(f|_S)}{(m+1)\nu(f|_S)}\big]\le\frac{2^{K(f)+c}}{m+1}$, where $S$ is the set of sampled values.

With Prop 2.12: for $f\equiv0$ and uniform inputs on $\{0,1\}^n$, $n\ge\lceil\log m\rceil+1$,
$$\frac{2^{-c}}{8m(\log m+3)^2}\ \le\ \mathbb E\,e(x_{m+1})\ \le\ \frac{c'+\ln m}{m}.$$
So in distribution the per-step error of SFI is $1/m$ up to logarithmic factors.

*Proof of (a).* Treat each hypothesis as a deterministic partial function: for $W$, a program $h=p$ with weight $2^{-|p|}$; for $M_F$, a tape $\omega$ with measure $\lambda$ and function $h=f^{T_U}_\omega$. Let $\varepsilon_h:=\pi\{x:h(x)\ne f(x)\text{ or }h(x)\text{ undefined}\}$. For a fresh $x^*$, $e(x^*)$ is the posterior mass of hypotheses not correct at $x^*$ (zero if $x^*$ was a training input, since every surviving hypothesis is correct there), so
$$\mathbb E[e(x^*)\mid D_m]=\frac{\int_{h\supseteq D_m}\varepsilon_h\,d\nu(h)}{\nu(D_m)}\ \le\ \varepsilon+\frac{\nu\{h\supseteq D_m:\varepsilon_h>\varepsilon\}}{\nu(D_m)}.$$
The denominator is at least $2^{-K(f)-c}$ (Fact D). A fixed hypothesis survives the $m$ independent training inputs with probability $(1-\varepsilon_h)^m$, so by Fubini $\mathbb E\,\nu\{h\supseteq D_m:\varepsilon_h>\varepsilon\}\le e^{-\varepsilon m}\nu(\emptyset)\le e^{-\varepsilon m}$. This gives the expectation bound; Markov's inequality on the surviving bad mass gives the high-probability form. Take $\varepsilon=((K(f)+c)\ln2+\ln m)/m$. ∎

This is the "Markov half" of the relevance-based bound in the Vaintrob–Hänni slides (Appendix A), with the non-tail set $S=\{f\}$. The union-bound half and the slides' geometric length prior are not needed: the weight of long programs enters only multiplied by $e^{-\varepsilon m}$.

*Proof of (b).* Condition on the multiset of the $m+1$ sampled values. By exchangeability, $x^*$ is a uniformly random one of the $m+1$ positions. If its value occurs more than once, it is a training input and $e(x^*)=0$. Otherwise the training set, as a set, is $S\setminus\{x^*\}$, and $e(x^*)=e_{\rm LOO}(x^*;S)$, because SFI sees training data only as a set. So $\mathbb E[e(x^*)\mid\text{multiset}]=\frac1{m+1}\sum_{x\in S\text{ occurring once}}e_{\rm LOO}(x;S)$, and Prop 2.10 and Fact D finish. ∎

c7 checks, exactly and for a mixture with deterministic, partial, product and shared-randomness hypotheses on a 5-point domain ($m\le6$, three input laws): the exchangeability identity (error $\le3.2\cdot10^{-15}$), bound (b), and bound (a) in the form $\min_\varepsilon[\varepsilon+\nu(\emptyset)e^{-\varepsilon m}/\nu(f)]$. Form (a) is far stronger in $K$; form (b) is kept because it is the without-replacement statement that connects to Conjecture 2.11.

This corrects `notes.md`'s comparison of a per-step lower bound with a Cesàro upper bound (referee m6). The referee's proposed R2 had $2^{2K}\log m/m$; (a) has $(K\ln2+\ln m+O(1))/m$.

**Remark 2.18 (relations).**
* *Cesàro versus per step.* Theorem 2.7 gives $\frac1m\sum_{k\le m}\mathbb E\,e_k\le(\ln2)(K(f)+c)/m$ on every input sequence; Cor 2.17(a) gives the per-step rate in distribution at the price of an additive $\ln m$. The foundations track's Thm 6.7(a) is the Cesàro statement for log loss of the averaged predictor.
* *Leave-one-out is different.* For a fixed finite set $B$ and a uniformly random held-out point (sampling without replacement), the training set kills every hypothesis with two or more errors on $B$, so the Markov argument has nothing to work on: what remains is the posterior mass of one-exception hypotheses, which is the subject of Conjecture 2.11. If Conjecture 2.11 holds, the proof of (b) gives $\mathbb E\,e(x^*)\le\frac{|S|}{m+1}O\big(\frac{K(f)}{|S|}\big)=O\big(\frac{K(f)}{m+1}\big)$ up to logarithmic factors, without the additive $\ln m$ [proved implication].

### 2.5 Answer to "the strongest true positive statement"

1. **Relative generalisation.** SFI's total OOD loss over any sequence of shifts exceeds that of any computable $x$-only generaliser $P$ by at most $K(P)+O(1)$ (foundations Thm 6.1 with Theorem 2.7). Its total error is at most $(\ln2)(K(f)+c)$ on every sequence (Theorem 2.7); separation forces only $O(1)$ of it (Remark 2.8a).
2. **No selection, no failure.** For every input set, a random train/test split gives expected loss $\le K_F(f|_B)/|B|$ (Prop 2.9).
3. **A converse for single test points.** For simple $f$, the error at $x^*$ is between $2^{-\sigma(x^*;A)-O(1)}$ and $2^{K_F(f)-\sigma(x^*;A\mid f)+O(1)}$, where the two $\sigma$'s are the least complexities of a separating property, unconditionally and given the labelled sample (Prop 2.16). For random $f$ no converse holds for any learner (Prop 2.13).
4. **In distribution, per step,** the error is between $\Omega(2^{-K}/(m\log^2m))$ and $((K+c)\ln2+\ln m+1)/m$ (Prop 2.12, Cor 2.17).

---

## 3. Computable versions (H10)

### 3.1 Time-bounded SFI

**Setting.**
* $Y$ is finite, $|Y|\ge2$. Logs are base 2.
* A **probability predictor** is a RAM program $A$ that on input $x$ halts and outputs rationals $(A(y\mid x))_{y\in Y}$, nonnegative and summing to 1. $T_A(x)$ is its running time.
* $p:\mathbb N\to\mathbb N_{\ge1}$ is nondecreasing, and $p$ and the clock factor $g$ (below) are **time-constructible**, so that the clocks can be run (a hidden hypothesis of `notes.md`, referee m3). $\mathcal C_p:=\{A:\exists c_A\ \forall x\ T_A(x)\le c_Ap(|x|)\}$. A bound holding only for long inputs extends to all inputs by enlarging $c_A$.
* **Data.** Theorem 3.1 is about sequences of **distinct** inputs with arbitrary labels.

**[refuted] in `notes.md`: "Under the semimeasure convention a repeated input carries no information and no loss, both for SFI and for any random function. So restricting to distinct inputs loses nothing."** This is false for the natural use of probability predictors, noisy labels (referee m2). Two failures:
* the mixture $S$ below is a law over data sets; a repeated input with a different label makes the data set inconsistent and gets probability 0 (infinite regret), while an $x$-only comparator pays a finite loss (foundations Prop 6.8 for SFI itself);
* even if the same product hypotheses are mixed round by round (so repeats are allowed), length-based clocking leaves a comparator over budget on short inputs forever. On a stream that repeats 12 short inputs with labels drawn from a comparator $A_4\in\mathcal C_p$, the regret against $A_4$ reaches 469 bits after 4000 rounds and grows linearly [computed, c9 stream B].

So distinctness is a genuine restriction of Theorem 3.1. Prop 3.2a removes it.

**Construction (length-activated, length-clocked).**
* Enumerate RAM programs $A_1,A_2,\dots$ with computable weights $w_i>0$, $\sum_iw_i\le1$.
* Choose activation lengths $n_1<n_2<\cdots$ and a nondecreasing unbounded clock factor $g\ge1$. The running-time claims use $n_i=2^{2^i}$ and $g(n)=\lceil\log\log(n+4)\rceil$.
* $q_i(\cdot\mid x):=A_i(\cdot\mid x)$ if $|x|\ge n_i$ and $A_i$ halts on $x$ within $g(|x|)p(|x|)$ steps with a valid vector; otherwise $q_i(\cdot\mid x):=u$, the uniform vector.
* $S(D):=\sum_iw_i\prod_{(x,y)\in D}q_i(y\mid x)$. Each term is a product of probability vectors, so $\sum_yS(D+(x,y))=S(D)$ for $x\notin\operatorname{dom}D$, and $S(\emptyset)=\sum_iw_i\le1$. $S$ is a mixture of product laws (private randomness per input). The learner predicts $S(y\mid D_{k-1},x_k)=S(D_{k-1}+(x_k,y))/S(D_{k-1})$.

**Theorem 3.1 (time-bounded SFI) [(a) proved, corrected after referee m1; (b) proof sketch; computed, c5, c9].**
* **(a) Constant regret on distinct inputs.** Let $A=A_i\in\mathcal C_p$ with constant $c_A$, and $N_A:=\max(n_i,\min\{n:g(n)\ge c_A\})$. For every sequence of distinct inputs, all labels and all $k$:
$$\sum_{j\le k}-\log S(y_j\mid D_{j-1},x_j)-\sum_{j\le k}-\log A(y_j\mid x_j)\ \le\ \log\tfrac1{w_i}+\#\{j\le k:|x_j|<N_A\}\log|Y|\ \le\ \log\tfrac1{w_i}+(2^{N_A}-1)\log|Y|.$$
* **(b) Running time.** $S$ can be run online. Round $k$ costs $a(|x_k|):=\#\{i:n_i\le|x_k|\}\le\log\log|x_k|+1$ simulations of $g(|x_k|)p(|x_k|)$ steps each, plus $O(a(|x_k|))$ arithmetic operations on stored weights, plus $O(1)$ bookkeeping. With floating-point weights at relative precision $k^{-2}$ the cumulative loss changes by $O(1)$.

*Proof of (a).* By Fact A, the learner's cumulative loss is $-\log(S(D_k)/S(\emptyset))\le\log(1/w_i)+\sum_{j\le k}-\log q_i(y_j\mid x_j)$ (using $S(\emptyset)\le1$). For $|x_j|\ge N_A$, $A$ is active and finishes within $c_Ap(|x_j|)\le g(|x_j|)p(|x_j|)$ steps, so $q_i(\cdot\mid x_j)=A(\cdot\mid x_j)$. For $|x_j|<N_A$ there are two cases: $q_i(\cdot\mid x_j)=A(\cdot\mid x_j)$, if $A$ happens to be active and to finish within the clock on this input; or $q_i(\cdot\mid x_j)=u$. In both cases $-\log q_i(y_j\mid x_j)\le\log|Y|-\log A(y_j\mid x_j)$, because $-\log A\ge0$. Subtract $A$'s loss. Distinctness bounds the number of short inputs by $2^{N_A}-1$. ∎

(`notes.md` wrote "$=\log|Y|$" for short inputs, which is false in the first case; the inequality above holds in both. c9 includes comparators that run faster than their worst case on half the inputs, so the first case occurs; the bound holds at every prefix, with minimum slack 0.10 bits.)

*Proof sketch of (b).*
* Store $v_i:=w_i|Y|^k\prod_{j\le k}q_i(y_j\mid x_j)$ for machines with $n_i\le\max_{j\le k}|x_j|$; every other machine has $v_i=w_i$. Then $S(D_k)=|Y|^{-k}V$ with $V:=\sum_iv_i$.
* A machine inactive at $x_k$ has $q_i=u$ and its $v_i$ is unchanged by round $k$, since $|Y|u(y)=1$. Hence
  $$S(y\mid D_{k-1},x_k)=\frac{\sum_{i\in\mathrm{act}(x_k)}v_iq_i(y\mid x_k)+(V-\sum_{i\in\mathrm{act}(x_k)}v_i)/|Y|}{V}.$$
* Updating touches only the $a(|x_k|)$ active $v_i$; $V$ is maintained by adding their changes, starting from $\sum_iw_i$.
* Relative errors $\varepsilon_k$ in the weights perturb each predictive probability by a factor $1\pm O(\varepsilon_k)$, so the cumulative loss changes by $O(\sum_k\varepsilon_k)$.
* Not written out: the machine model (RAM versus multitape; cf. Hänni's technical remark) and the cost of the clocks.
* c5 checks on a toy instance that this incremental algorithm gives the brute-force mixture's predictive probabilities to $2.5\cdot10^{-16}$, and that the regret against a time-$3|x|$ target stays below the proved constant (132.4 against 184 bits) and is flat once no new short inputs arrive. ∎

**Remark 3.1a (size of the constant; a hybrid design) [proved].**
* With $w_i=2^{-i}$ and $n_i=2^{2^i}$, the regret constant $\log(1/w_i)+(2^{N_A}-1)\log|Y|$ is at least $2^{2^{2^i}}$, triple exponential in the index $i$, and $i$ can be exponential in the description length of $A$. Weights $w_A=2^{-\ell(A)}$ from a prefix-free code make $\log(1/w_A)$ the description length, but the activation term remains.
* *Hybrid design:* activate machine $i$ at round $k_i$ and clock by input length. The same proof gives, on distinct inputs,
  $$\text{regret}\ \le\ \log\tfrac1{w_i}+(k_i-1)\log|Y|+\#\{j:|x_j|<N'_A\}\log|Y|,\qquad N'_A:=\min\{n:g(n)\ge c_A\},$$
  so $n_i$ leaves the exponent. The per-round cost becomes $a(k)$ simulations of $g(|x_k|)p(|x_k|)$ steps with $a(k):=\#\{i:k_i\le k\}$, which grows (slowly) with the round count.

**Proposition 3.2a (round-activated, round-clocked mixture: constant regret on every stream) [proved; computed, c9; new].** Let $(x_k,y_k)_{k\ge1}$ be any stream: repeated inputs and inconsistent labels allowed. Let $q_i^{(k)}:=A_i(\cdot\mid x_k)$ if $k\ge k_i$ and $A_i$ halts on $x_k$ within $g(k)p(|x_k|)$ steps with a valid vector, and $q_i^{(k)}:=u$ otherwise. Predict with $S^{\rm rd}(y\mid h_{k-1},x_k)$, the Bayes mixture of the per-round products $\prod_{j\le k}q_i^{(j)}(y_j)$ with weights $w_i$. Then for every $A=A_i\in\mathcal C_p$, every stream and every $k$:
$$\text{regret against }A\ \le\ \log\tfrac1{w_i}+(J_A-1)\log|Y|,\qquad J_A:=\max\big(k_i,\min\{k:g(k)\ge c_A\}\big).$$
Round $k$ costs $a(k)$ simulations of $g(k)p(|x_k|)$ steps plus $O(a(k))$ arithmetic [time: proof sketch, as in Thm 3.1(b)].

*Proof.* The mixture's cumulative loss is at most $\log(1/w_i)+\sum_{j\le k}-\log q_i^{(j)}(y_j)$. For $j\ge J_A$, machine $i$ is active and $T_A(x_j)\le c_Ap(|x_j|)\le g(j)p(|x_j|)$, so $q_i^{(j)}=A(\cdot\mid x_j)$. For $j<J_A$, $q_i^{(j)}\in\{A(\cdot\mid x_j),u\}$ and $-\log q_i^{(j)}(y_j)\le\log|Y|-\log A(y_j\mid x_j)$. ∎

This is the time-bounded analogue of SFI on time-stamped inputs (foundations Thm 6.7(b)): each round is its own input, so noisy labels cost nothing extra. c9 stream B: the round-clocked regret against $A_4$ is 10.0 bits against the bound 20, while the length-clocked one is 469 bits. c9 stream A (4000 distinct inputs, labels adversarial against the length-clocked mixture): both bounds hold at every prefix for all six comparators.

**Corollary 3.2b (Hänni's Remark 4: all polynomial-time predictors) [proved].** Let $g$ be nondecreasing, unbounded and computable, and suppose the clock $t_k(x):=(|x|+2)^{g(k)}$ is time-constructible. Use $t_k$ in place of $g(k)p(|x_k|)$ in Prop 3.2a. Every $A$ with $T_A(x)\le c_A(|x|+2)^{e_A}$ (any polynomial time bound) is within budget once $g(k)\ge e_A+\log c_A$. So the regret against every polynomial-time $x$-only predictor is bounded by a constant depending on $A$, on every stream, and round $k$ costs $a(k)$ simulations of $(|x_k|+2)^{g(k)}$ steps: time $|x|^{\omega(1)}$ with an arbitrarily slowly growing $\omega(1)$. The length-clocked version (clock $(|x|+2)^{g(|x|)}$) gives the same on distinct inputs. *Proof:* as Prop 3.2a and Thm 3.1(a). ∎

**Remark 3.2 (Hänni's "apples to oranges" caveat).**
* In his sequence theorem the predictor sees a growing prefix and gets $p(n)$ time per bit, while $S$ reuses state; his fix lets the predictor reuse state too, with an amortised warm-up.
* In the function setting the natural comparison class is $x$-only predictors. They see one input and have nothing from earlier rounds to reuse, so Thm 3.1 and Prop 3.2a compare like with like as they stand. The learner keeps state (weights); every learner must.
* For **history-aware** comparators the right learner is a time-bounded *chronological* mixture. The $x$-only learners cannot compete with that class even without time bounds: the history-aware predictors of the history track's counterexamples (chain, skipped strings; history Thm 2.1(c), 2.2(a)) run in time linear in the length of the history, while SFI's loss on those data is unbounded. `notes.md` said "Hänni's amortisation trick then applies verbatim [proof sketch]" without defining the class or giving the sketch (referee m11). Prop 3.2c does both.

**Proposition 3.2c (time-bounded history-aware predictors) [regret proved; running time proof sketch; new].**
* *Class.* A history-aware online predictor is a RAM program $A$ that keeps a state between rounds. At round $k$ it receives $x_k$, outputs a probability vector $A(\cdot\mid h_{k-1},x_k)$, and then receives $y_k$. Let $N_k:=|\mathrm{code}(h_{k-1},x_k)|$, the length of the encoded history plus the new input. $A\in\mathcal H_p$ if round $k$ (prediction and update) takes at most $c_Ap(N_k)$ steps.
* *Learner.* Machine $i$ is started at round $k_i$. From then on, at each round $k$ the learner gives it $2g(k)p(N_k)$ steps. It spends them replaying the stored history from round 1 (feeding $x_1,y_1,x_2,\dots$) and, once the replay has reached the present, on the current round. $q_i^{(k)}$ is $A_i$'s output at round $k$ if the replay has caught up and round $k$'s prediction finished within the budget; otherwise $q_i^{(k)}:=u$. The learner predicts with the Bayes mixture of the per-round products, weights $w_i$.
* *Claim.* For every $A=A_i\in\mathcal H_p$ and every stream, the regret against $A$ is at most $\log(1/w_i)+2k_0\log|Y|$, with $k_0:=\max(k_i,\min\{k:g(k)\ge c_A\})$. The cost of round $k$ is $O(a(k)\,g(k)\,p(N_k))$ steps plus the replay memory, with $a(k):=\#\{i:k_i\le k\}$ [proof sketch].

*Proof of the regret bound.* $N_k$ is nondecreasing in $k$ and $p$ is nondecreasing, so for $k\ge k_0$ and $j\le k$, one round of $A$ at time $j$ costs at most $c_Ap(N_j)\le g(k)p(N_k)$. Hence at each learner round $k\ge k_0$ the budget $2g(k)p(N_k)$ completes at least two further rounds of $A$ (counting a partly done round), unless the replay reaches the present. Let $r_k$ be the number of rounds of $A$ completed after learner round $k$. Then $r_k\ge\min(k,r_{k-1}+2)$ for $k\ge k_0$, so $r_k\ge\min(k,2(k-k_0+1))$, which equals $k$ for $k\ge2k_0-2$. Once caught up, the replay stays caught up, because one round costs at most the budget. So $q_i^{(k)}=A(\cdot\mid h_{k-1},x_k)$ for $k\ge2k_0-2$. For earlier rounds $q_i^{(k)}\in\{A,u\}$ and $-\log q_i^{(k)}(y_k)\le\log|Y|-\log A(y_k\mid h_{k-1},x_k)$. Sum as in Prop 3.2a. ∎

The class contains the chain and skipped-string predictors (with $p(n)=n$). It is the time-bounded counterpart of the history track's SFI$^{\rm hist}$, which equals Hutter's chronological $\xi$ up to constants (history Cor 4.3). The simulation overhead is assumed to be a constant factor (RAM model), absorbed in $g$; this is the unwritten part.

**Proposition 3.3 (samplers) [proved; corrected after referee m4].**
* Let $A(x;r)$ be a probabilistic RAM program (fair coins $r$) that halts within $c_Ap(|x|)$ steps on all coin sequences, with output law $P_A(\cdot\mid x)$.
* A probability predictor with non-dyadic outputs is not a bounded-time sampler, and a sampler's program is not a predictor's program, so the mixture must contain both readings of each program. For each $i$ let $q_i^{\rm pred}$ be as in Thm 3.1, and let $q_i^{\rm samp}(y\mid x)$ be the probability that $A_i(x;r)$ halts within $g(|x|)p(|x|)$ steps with output $y$, plus $1/|Y|$ times the probability that it does not, when $|x|\ge n_i$; and $q_i^{\rm samp}:=u$ when $|x|<n_i$. Put $S(D):=\sum_i\frac{w_i}2\big(\prod_Dq_i^{\rm pred}+\prod_Dq_i^{\rm samp}\big)$.
* Then Theorem 3.1(a) holds against every such sampler (regret measured against $P_A$), with $\log(2/w_i)$ in place of $\log(1/w_i)$, by the same proof; likewise for predictors. Prop 3.2a extends in the same way.
* $q_i^{\rm samp}(y\mid x)$ is computable exactly: a run within $B$ steps reads at most $B$ coins, so it is a finite sum over at most $2^{g(|x|)p(|x|)}$ coin strings. Round $k$ costs $O(a(|x_k|)\,2^{gp}gp)$ steps.

**Question 3.4 (open).** Is there a learner with per-round time polynomial in $p(|x|)$ that has constant regret against all time-$O(p)$ samplers?
* Monte Carlo estimation with $t$ samples per round adds, when probabilities are bounded away from 0 and 1, an expected excess loss of order $1/t$ per round. Constant regret then needs $t_k\to\infty$ with $\sum_k1/t_k<\infty$, so the time per round grows with the round count.
* Impagliazzo & Levin, "No better ways to generate hard NP instances than picking uniformly at random", FOCS 1990, pp. 812–821 [known (snippet): "universal extrapolation is possible precisely when cryptography is not"; exact statements unverified], suggest that an efficient version is tied to the non-existence of one-way functions.
* Related: speed priors. Schmidhuber, "The Speed Prior: a new simplicity measure yielding near-optimal computable predictions", COLT 2002, LNAI 2375, pp. 216–228 [known (snippet)]; Filan, Leike & Hutter, "Loss bounds and time complexity for speed priors", AISTATS 2016, PMLR 51:1394–1402 [known (snippet): a variant of the speed prior predicts sequences from measures estimable in polynomial time and is computable in doubly exponential time]. Those are sequence results.

### 3.2 Circuit setting

* Fix $d\ge1$ and the basis $G$ of all 16 two-input Boolean gates.
* A circuit of size $s\ge1$ is a list of $s$ gates. Gate $j$ has a type in $G$ and two inputs from $\{x_1,\dots,x_d,0,1,\text{gate}_1,\dots,\text{gate}_{j-1}\}$. The output is gate $s$. Dead gates are allowed.
* There are $N_s=\prod_{j=1}^s16(d+1+j)^2$ circuits of size $s$.
* **Prior:** $w(C):=2^{-s}/N_s$ for $C$ of size $s$. This is $2^{-|{\rm desc}(C)|}$ for the prefix-free description "size in unary ($s$ bits), then the gate list in $\log N_s$ bits", so $\sum_Cw(C)=1$. The description length of a function $f$, $\ell(f)=c(f)+\log N_{c(f)}$, is increasing in the least size $c(f)$.
* $W(D):=\sum\{w(C):C\text{ consistent with }D\}$, $c(f)$ the minimum circuit size, $L(f):=-\log W(f)$; for $B\subseteq\{0,1\}^d$, $c_B(f)$ and $L_B:=-\log W(f|_B)$.
* **Exception gadget.** For $a\in\{0,1\}^d$ and $v\in\{0,1\}$, append $\max(d-1,1)$ gates computing $E_a=[x=a]$ (gates $u\wedge v$, $u\wedge\neg v$, $\neg u\wedge\neg v$), then one output gate, $\mathrm{out}\vee E_a$ if $v=1$ or $\mathrm{out}\wedge\neg E_a$ if $v=0$. So $g\le d+1$ gates are added. The map $C\mapsto C'$ is injective ($C$ is the first $s$ gates of $C'$); $C'$ agrees with $C$ off $a$ and outputs $v$ at $a$. Weight ratio: $w(C')/w(C)=2^{-g}N_s/N_{s+g}\ge2^{-B(s)}$, $B(s):=g\,(5+2\log(d+1+s+g))$.

### 3.3 Circuit Bayes: mistakes and circuit size

**Theorem 3.5 [proved; computed, c1, c8].** Let $x_1,\dots,x_N$ be any ordering of any set $B\subseteq\{0,1\}^d$ and $f$ any Boolean function. Let $P_i$ be the posterior probability of the wrong label at step $i$ (circuits are total, so this is also the normalised value), $m:=\sum_iP_i$ the expected number of posterior-sampling (Gibbs) mistakes, and $L_B=-\log W(f|_B)$.
* **(a)** Some circuit of size $\le\lceil L_B\rceil$ agrees with $f$ on $B$, and $L_B\le c_B(f)+\log N_{c_B(f)}=O(c_B(f)\log(c_B(f)+d))$. For $B=\{0,1\}^d$: $c(f)\le\lceil L(f)\rceil$.
* **(b)** $m\le(\ln2)L_B$ and $L_B\le2m\,(B(\lceil L_B\rceil)+3)$. Explicitly,
  $$L_B\ \le\ 16\,m\,(d+1)\log\big(2(m+1)(d+2)\big)\qquad\text{and}\qquad c_B(f)\ \le\ \lceil L_B\rceil,$$
  for all $m>0$ and $d\ge1$.
* Both directions hold for **every** ordering. The number of mistakes of the Bayes posterior-majority predictor is $\le L_B$ (Remark 3.10).

*Proof.*
* (a) $\sum_{s>S}2^{-s}=2^{-S}$. If no circuit of size $\le S$ agrees with $f$ on $B$, then $W(f|_B)<2^{-S}$; the inequality is strict because at every size some constant circuit disagrees with $f$ on $B\ne\emptyset$. So $S<L_B$; take $S=\lceil L_B\rceil$. Second part: $W(f|_B)\ge w(C_{\min})=2^{-c_B}/N_{c_B}$.
* (b), first inequality: $P_i\le-\ln(1-P_i)$ and Fact A, with $W(\emptyset)=1$.
* (b), second inequality. Fix $i$ and $S:=\lceil L_B\rceil$. Let $\mathcal R$ and $\mathcal W$ be the circuits consistent with $D_{i-1}$ that give $x_i$ the right and wrong label. The gadget sends $\mathcal W_{\le S}$ injectively into $\mathcal R$ (earlier inputs differ from $x_i$, and the gadget changes only the output at $x_i$), so $w(\mathcal W_{\le S})\le2^{B(S)}w(\mathcal R)$. Also $w(\mathcal W_{>S})\le2^{-S}\le2^{-L_B}\le w(\mathcal R)$, since $\mathcal R$ contains every circuit agreeing with $f$ on $B$. So $P_i/(1-P_i)\le2^{B(S)}+1$ and $-\log(1-P_i)\le B(S)+2$. In $L_B=\sum_i-\log(1-P_i)$, terms with $P_i\le\frac12$ contribute $\le2P_i$ (convexity: the chord from $(0,0)$ to $(\frac12,1)$); at most $2m$ indices have $P_i>\frac12$, each contributing $\le B(S)+2$. So $L_B\le2m(B(S)+3)$.
* Explicit form. $g\le d+1$ and $d+1+S+g\le2d+4+L_B$, so $L_B\le R(L_B)$ with $R(L):=2m[(d+1)(5+2\log(2d+4+L))+3]$. $R$ is concave and increasing with $R(0)>0$, so $\{L\ge0:L\le R(L)\}=[0,L^*]$, and it suffices to show $K:=16a\Lambda>R(K)$, where $a:=m(d+1)$, $\Lambda:=\log(2(m+1)(d+2))=X+Y$, $X:=\log(2(d+2))\ge\log6$, $Y:=\log(m+1)$. Since $6m\le3a$, $R(K)\le13a+4a\log(2d+4+K)$, and $2d+4+16a\Lambda\le2(d+2)(1+8m\Lambda)\le2(d+2)(1+8m)(1+X)(1+Y)$. So it suffices that
  $$\big[12X-4\log(1+X)-13\big]+\big[16Y-4\log(1+8m)-4\log(1+Y)\big]>0.$$
  The first bracket is increasing in $X$ and equals $10.65$ at $X=\log6$. For the second: $\log(1+Y)\le Y+0.087$ for all $Y\ge0$ (the maximum of $\log(1+Y)-Y$ is $0.0861$), and $\log(1+Y)\le Y$ for $Y\ge1$. If $m\le1$, $(1+8m)/(1+m)\le9/2$, so the bracket is $\ge12Y-4\log4.5-4(Y+0.087)\ge-9.03$. If $m\ge1$, $(1+8m)/(1+m)<8$, so it is $>12Y-12-4Y\ge-4$. The sum is positive. ∎

c8 computes $L^*(m,d)$ by bisection on a grid ($m\in[10^{-3},10^5]$, $d\in[1,10^4]$): the largest ratio $L^*/(m(d+1)\log(2(m+1)(d+2)))$ is 10.85 (at $m\approx0.63$, $d=1$), below 16. The referee's form $L\le52\,md\log(md+2)$ holds on the part of the grid with $m\ge1$ (largest ratio 48.6), but not uniformly in $m$: for $m=10^{-6}$ and $d=10^4$ the ratio is 66.7, and it grows like $4\log d$ when $m\ll1/d$ [computed, c8].

**Remark 3.6 (relation to Hänni's sketch; the gap in it).**
* *Hänni's direction.* "Expected regret $m$ ⇒ circuit of size $O(m\log m\cdot d)$" is Theorem 3.5(b)+(a), with $\log((m+1)(d+2))$ in place of $\log m$, and with three improvements: one ordering suffices (no expectation over orderings); no Markov step is needed, since the total log loss is order independent; and the "$+O(\log m)$" he flagged is the $\log(d+s)$ in $B(s)$, handled by splitting at size $\lceil L\rceil$.
* *The gap.* His sketch goes from "log loss $\le\mathrm{poly}(m)$" to "a circuit of size $\mathrm{poly}(m)$" without argument. That step is a **circuit coding theorem**, and it depends on the prior's size tail. With the exponential tail $2^{-s}$ it is part (a). With a polynomial tail (e.g. an Elias code $\approx2^{-2\log s}$ for the size) the same argument gives only $c(f)\le2^{O(L)}$. A polynomial bound would need that random large circuits rarely compute functions without small circuits; open, as far as I know. For random AND/OR *formulas* there are limit laws relating a function's probability to its formula size [known (snippet): Lefmann & Savický 1997; Chauvin, Flajolet, Gardy & Gittenberger 2004; exact bounds unverified].
* *The converse ("regret $\le$ poly(circuit complexity)").* Hänni proves it for Occam in distribution. For circuit Bayes it holds on every ordering: $m\le(\ln2)L\le(\ln2)c(f)(5+2\log(d+1+c(f)))$.
* *Gibbs versus MAP.* "Few MAP mistakes ⇒ small circuit" is open: steps with $P_i$ just below $\frac12$ cost log loss but no MAP mistakes.
* *Other languages.* The proof uses only a size prior with exponential tail times a uniform choice within each size, and an injective exception surgery with bounded weight cost. For **formulas** (leaves $x_j,\neg x_j,0,1$; nodes AND, OR, XOR; size = number of leaves; prior $2^{-s}$ times uniform), the surgery adds $d$ leaves and, since $\mathrm{Cat}(n+1)/\mathrm{Cat}(n)<4$, costs $B=d(1+\log(12(2d+2)))$, independent of size.
* The slides' remark that "the $O(C\log(C+d))$ of Solomonoff induction over boolean circuits" is out of reach for their NN bound refers to this rate (Theorem 3.5(a)).

**Remark 3.7 (computed check, c1: formulas on $d=3$) [computed].** All 256 functions have formula size $\le5$; $L(f)$ ranges from 2.87 (literals) to 17.66. For every $f$ and every ordering of the 8 inputs (dynamic programming over subsets): $c(f)\le\lceil L(f)\rceil$; $L(f)\le c(f)+\log N_{c(f)}$; $m\le(\ln2)L$; $L\le2m_{\min}(B+3)$ with $B=22.75$ (largest observed $L/m_{\min}$ is 4.92 against 51.5). Order independence of $\sum_i-\log(1-P_i)$ holds to $1.8\cdot10^{-14}$. Worst-case adversarial mistakes: Occam up to 8 (all inputs), posterior majority up to 7.5 (ties count $\frac12$). `notes.md` said these numbers "say nothing about asymptotics"; Theorem 3.11 shows that the Occam figure is the $d=3$ case of an exponential lower bound.

### 3.4 Occam (simplest-consistent) learning

* Fix a prefix-free description language and order hypotheses by (length of shortest description, then a fixed tie rule). $\ell(f)$ is $f$'s shortest description length.
* The Occam learner predicts with the first hypothesis consistent with the data so far. It only uses hypotheses in $H_f:=\{h:h\text{ precedes or equals }f\}$, and $|H_f|<2^{\ell(f)+1}$.

**Proposition 3.8 (Occam PAC; Hänni's in-distribution theorem) [known: Blumer, Ehrenfeucht, Haussler & Warmuth, "Occam's razor", *Inf. Process. Lett.* 24(6):377–380, 1987 (snippet); proof standard, included].** For any input distribution $\mu$ and i.i.d. samples, $m\ge(\ln|H_f|+\ln(1/\delta))/\varepsilon$ samples give $\Pr[\mathrm{err}_\mu(h_m)>\varepsilon]\le\delta$. *Proof.* A fixed $h$ with error $>\varepsilon$ survives $m$ samples with probability $<(1-\varepsilon)^m\le e^{-\varepsilon m}$; union bound over $H_f$. ∎ With $\varepsilon=\delta=0.01$, $m\ge70\,\ell(f)+531$ suffices. So Hänni's "$10^6\cdot C(f)$ samples" is correct when $C(f)$ is the description length; for gate count, multiply by $O(\log(C(f)+d))$.

**Proposition 3.9 (Occam's expected mistakes in distribution; Hänni's converse direction) [proved].** Let inputs be i.i.d. from $\mu$ (repetitions allowed), and $p_{\min}$ the least positive point mass of $\mu$. Then
$$\mathbb E[\#\text{mistakes}]\le6.7+(\ln|H_f|)(1+\ln N)+\ln^2N,\qquad N:=\lceil\ln|H_f|/p_{\min}\rceil.$$
For uniform $\mu$ on $\{0,1\}^d$ this is $O(\ell(f)(d+\log\ell(f))+d^2)$.

*Proof.*
* Step $n+1$, $n\ge1$: $\Pr[\text{mistake}]=\mathbb E[\mathrm{err}(h_n)]\le\varepsilon+|H_f|(1-\varepsilon)^n$ for every $\varepsilon$. With $\varepsilon_n:=\ln(|H_f|(n+1)^2)/n$ this is $\le\varepsilon_n+(n+1)^{-2}$.
* Steps $1,\dots,N$: summing (step 1 costs $\le1$), with $\ln(n+1)\le\ln n+1/n$ and $\sum_{n<N}\frac{\ln n}n\le\frac12\ln^2N+\frac1e$, the expected mistakes are $\le5.7+(\ln|H_f|)(1+\ln N)+\ln^2N$.
* After step $N$: each mistake is made by the current $h_n\in H_f$, which is consistent with $D_N$, wrong somewhere on the support of $\mu$, and eliminated by the mistake. So the later mistakes are at most the number of such hypotheses surviving $N$ samples, whose expectation is $\le|H_f|(1-p_{\min})^N\le1$. ∎

**Remark 3.10 (Hänni's "physicist's proof" is a proof for weighted majority) [proved; known].** His argument assumes that when the current guess is wrong, a constant fraction of the competing weight is wrong too. That is exactly the guarantee of the **posterior-majority (weighted-majority, Bayes MAP-label) predictor**: when it errs, at least half of the posterior mass errs, so $W(D_i)\le W(D_{i-1})/2$, and the number of its mistakes is $\le\log(W(\emptyset)/W(f|_B))\le L_B$ on every ordering. This is the halving / weighted-majority argument [known: Littlestone, *Machine Learning* 2:285–318, 1988; Littlestone & Warmuth, *Inf. Comput.* 108:212–261, 1994 (unverified)]. With the circuit prior, posterior-majority mistakes are $\le L\le\ell(f)=O(c\log(c+d))$ on every ordering. For Occam the assumption can fail at every step (Theorem 3.11).

**Lemma 3.11a (Möbius lemma) [proved; computed, c6(a) exhaustively for $d\le4$].** Let $1\le k\le d$ and let $h:\{0,1\}^d\to\{0,1\}$ satisfy $h(1^d)=1$ and $h(x)=0$ whenever $|x|<k$ ($|x|$ the Hamming weight). Then (i) $h$ depends on at least $k$ variables; (ii) if $h$ depends on exactly $k$ variables, then $h=\mathrm{AND}_S:=\bigwedge_{j\in S}x_j$ for some $|S|=k$.

*Proof.* Write $h$ in algebraic normal form, $h=\bigoplus_Sc_S\prod_{j\in S}x_j$ over GF(2). Evaluating at $1_T$ (the indicator of $T$) gives $h(1_T)=\bigoplus_{S\subseteq T}c_S$, so by Möbius inversion $c_S=\bigoplus_{T\subseteq S}h(1_T)$. If $|S|<k$, every $T\subseteq S$ has $|T|<k$, so $c_S=0$. Since $h\ne0$, some $c_S=1$ with $|S|\ge k$. By uniqueness of the ANF, $h$ depends on every variable occurring in a monomial with $c_S=1$; this gives (i). For (ii), let $h$ depend only on the variables in $R$, $|R|=k$. For $a\in\{0,1\}^R$ with $a\ne1_R$, the input equal to $a$ on $R$ and $0$ elsewhere has weight $<k$, so $h=0$ there; and $h(1_R,\cdot)=h(1^d)=1$. So $h=\mathrm{AND}_R$. ∎

**Theorem 3.11 (the conjunction ladder: Occam fails exponentially out of distribution) [proved; computed, c6; construction from the Vaintrob–Hänni slides, Appendix K].** Let $f=\mathrm{AND}_{[d]}$. Consider the Occam learner, with any fixed tie rule among functions of equal least size, in either of two languages:
* **formulas** (leaves $x_j,\neg x_j,0,1$; nodes AND, OR, XOR; size = number of leaves), $d\ge2$;
* **circuits** of §3.2 (size = number of gates), $d\ge3$.

Present $1^d$, then $0^d$, then the inputs of weight $1,2,\dots,d-1$, level by level; inside a level, present an input on which the current Occam hypothesis errs, if there is one. Then Occam makes at least $2^d-2$ mistakes (formulas) or $2^d-d-2$ mistakes (circuits) on the $2^d$ inputs. The description length of $f$ (unary size code and uniform choice within the size, as in §3.2–3.3) is $\ell(f)=d+\log(\mathrm{Cat}(d-1)3^{d-1}(2d+2)^d)$ for formulas and $\ell(f)=(d-1)+\log N_{d-1}$ for circuits, both $\Theta(d\log d)$. Hence the worst-case number of Occam mistakes over orderings is
$$2^{\Omega(\ell/\log\ell)},$$
while the trivial upper bound is $\min(2^d,|H_f|-1)\le2^{\ell+1}$. For $f=\mathrm{AND}_{[d]}$ the lower bound is tight up to the constant in the exponent, since there are only $2^d$ inputs.

*Proof.* Stage $k$ ($1\le k\le d-1$) begins when the data are "$h(1^d)=1$ and $h(x)=0$ for $|x|<k$", which is the case after $1^d$, $0^d$ and all inputs of weight $<k$ have been shown, with the correct labels of $f$.
* *Formulas.* A formula with $s$ leaves depends on at most $s$ variables. By Lemma 3.11a(i), every function consistent at the start of stage $k$ has formula size $\ge k$. A consistent function of size exactly $k$ depends on at most $k$, hence exactly $k$, variables, so it is a $k$-conjunction by Lemma 3.11a(ii). Every $\mathrm{AND}_S$ with $|S|=k$ is consistent and has a size-$k$ formula. So the consistent functions of least size are exactly the $\binom dk$ $k$-conjunctions, and Occam's hypothesis is one of them. The description length is increasing in the size, so ordering by description length is ordering by size.
* *Circuits, $k\ge2$.* In a circuit with $s$ gates, let $t\le s$ be the number of gates from which the output can be reached. Each of the $t-1$ reachable non-output gates occupies at least one of the $2t$ input slots of reachable gates, so at most $t+1$ slots hold variables, and the function depends on at most $s+1$ variables. By Lemma 3.11a(i), a consistent circuit has $s\ge k-1$. If $s=k-1$, then $t=s$, exactly $t-1$ slots are gate references and exactly $k$ slots hold variables, which must be $k$ distinct variables; so the function depends on exactly $k$ variables and is a $k$-conjunction by Lemma 3.11a(ii). $\mathrm{AND}_S$ has a circuit with $k-1$ gates. So again the least-size consistent functions are exactly the $k$-conjunctions. (For $k=1$ this fails: the one-gate circuit $x_1\wedge x_2$ is consistent at the start of stage 1, c6(c).)
* *Each level input is a mistake.* For $|S|=|S'|=k$, $\mathrm{AND}_{S'}(1_S)=1$ iff $S'\subseteq S$ iff $S'=S$. If Occam's hypothesis at a step in stage $k$ is $\mathrm{AND}_S$ and $1_S$ is unrevealed, the adversary shows $1_S$: Occam predicts 1, the label is $f(1_S)=0$, a mistake, and exactly $\mathrm{AND}_S$ is eliminated among the $k$-conjunctions. Occam's hypothesis is always an unrevealed one (the revealed ones are inconsistent), so all $\binom dk$ inputs of weight $k$ are mistakes, and after them the data are the start of stage $k+1$.
* *Count.* Formulas: $\sum_{k=1}^{d-1}\binom dk=2^d-2$. Circuits: $\sum_{k=2}^{d-1}\binom dk=2^d-d-2$.
* *Description length.* At $k=d$ the lemma shows that $f$ has least size $d$ (formulas) or $d-1$ (circuits), so $\ell(f)$ is as stated. $\log((2d+2)^d)=\Theta(d\log d)$ dominates the formula count ($\mathrm{Cat}(d-1)\le4^d$), and $\log N_{d-1}=\sum_{j<d}(4+2\log(d+1+j))=\Theta(d\log d)$. So $d=\Theta(\ell/\log\ell)$ and the mistakes are $\ge2^{d-1}=2^{\Omega(\ell/\log\ell)}$ for $d\ge4$. ∎

c6 checks the lemma exhaustively for $d\le4$ (all $2^{16}$ functions at $d=4$), the "least-size consistent = $k$-conjunctions" statement for formulas with $d=3,4,5$ and for circuits with $d=3,4,5$ ($k\ge2$) by enumerating all functions of the relevant sizes, and simulates Occam (ties by truth-table index): formulas 7, 15, 31 mistakes of 8, 16, 32 inputs; circuits 4, 11, 26. The ratio $\log(\text{mistakes})/(\ell/\log\ell)$ stays between 0.64 and 0.82 (formulas) and 0.35 and 0.59 (circuits) for $d=3,\dots,40$ [computed, c6(d)].

`notes.md` said that for natural languages "a super-polynomial lower bound, or a polynomial upper bound, is **open**" and listed it as open problem 5. That claim is **withdrawn** (referee M1); the slides (Appendix K) already contained the construction, and c1's "Occam worst = 8" at $d=3$ was its smallest instance. What remains open is the gap between $2^{\Omega(\ell/\log\ell)}$ and $2^{O(\ell)}$ for targets other than conjunctions (§7). The ordering is computable from $d$ and the tie rule, so it has description complexity $O(\log d)$ plus that of the tie rule: "structured orderings are safe" is false, as the slides also note.

**Remark 3.12 (it is the selection rule, not the prior) [computed, c6(e); other rows claimed in the slides].** With the same prior, the posterior-majority predictor makes at most $L(f)\le\ell(f)$ mistakes on every ordering (Remark 3.10). c6(e) computes the formula prior exactly (zeta and Walsh–Hadamard transforms over truth tables, cross-checked against direct counting at $d=3$ to $1.4\cdot10^{-13}$):

| $d$ | Occam on the ladder | majority on the ladder | majority, worst ordering | Gibbs, worst ordering | halving bound $\log(W(\emptyset)/W(f))$ |
|---|---|---|---|---|---|
| 3 | 7 | 2.5 | 5.5 | 4.47 | 10.83 |
| 4 | 15 | 3.5 | 8.5 | 7.08 | 15.30 |

(ties count $\frac12$; worst orderings by dynamic programming over all $2^{2^d}$ subsets). The slides tabulate four selection rules with the same prior $\propto2^{-C(g)}$: deterministic argmax $2^{\Theta(C/\log C)}$ (proved above); argmax with randomised tie-breaking $\tilde\Theta(C^2)$; a uniformly random consistent hypothesis with a doubling budget $O(C)$; weighted majority $\le C$ (Remark 3.10). The middle two rows are **[claimed in the slides]** and not checked here. The slides also claim that a random ordering gives $\mathbb E[\text{mistakes}]=O((C+d)d)$ in any language [claimed in the slides].

**Remark 3.13 (uniform tie-breaking: the steeper-posterior limit on the ladder) [proved].** In the formula prior every formula of a given size has the same weight. So the limit $\lambda\to\infty$ of the power posterior $\propto w(\text{formula})^\lambda\cdot[\text{consistent}]$ (the steeper-simplicity direction of the steeper track) is uniform over the consistent formulas of least size, not a deterministic argmax. A variable permutation maps the size-$k$ formulas computing $\mathrm{AND}_S$ bijectively onto those computing $\mathrm{AND}_{\sigma(S)}$, so at stage $k$ this limit is uniform over the surviving $k$-conjunctions. On the ladder, when $j$ conjunctions survive and $1_S$ is shown for a survivor $S$, the Gibbs error is $1/j$ and the posterior-majority prediction is wrong only if $j=1$ (and tied if $j=2$). Counting the first two steps (Gibbs errors $\frac12$ and $\frac1{d+1}$), the Gibbs mistakes are at most $1+\sum_{k=1}^{d-1}H_{\binom dk}\le d+d^2\ln2$ ($H_n$ the harmonic number), and the majority mistakes at most $\frac32(d-1)+1$. This is the ladder instance of two rows of the slides' table (randomised tie-breaking $\tilde\Theta(C^2)$, majority $O(d)$ on the ladder). So Theorem 3.11 is a failure of deterministic tie-breaking. It does not show that steeper SFI fails on this ordering; whether a steeper posterior over a prefix-free universal machine can fail exponentially out of distribution is not settled here.

---

## 4. NN Bayes and circuit SFI

### 4.1 The exact identity

**Proposition 4.1 [proved, trivial].** Let an architecture be a parameter space $\Theta$ with prior $\pi$ and a map $\theta\mapsto f_\theta:\{0,1\}^d\to Y$. Let the likelihood depend on $\theta$ only through the values of $f_\theta$ on the data (0–1 likelihood, margin rules, any label-noise model). Then the posterior predictive of the network equals the function-space Bayes predictive with prior $P_A(f):=\pi\{\theta:f_\theta=f\}$. *Proof.* Group the parameter integral by the value of $f_\theta$. ∎

So "NN Bayes" is function induction with the prior $P_A$. The question is how $P_A$ compares with $2^{-K}$, with $M_F$, or with a circuit description-length prior.

### 4.2 The upper bound, and what it does not say

**Proposition 4.2 (coding-theorem upper bound) [proved, given Fact B].** Suppose $P_A$, as a semimeasure on truth tables, is lower-semicomputed by a program $a$ (architecture, prior and $d$). Then $P_A(f)\le2^{-K(f\mid a)+c}\le2^{-K(f)+K(a)+c'}$, with $c$ independent of the architecture. $P_A$ is lower semicomputable for finite parameter sets with rational probabilities [proved], and for Gaussian priors on real weights with threshold or sign outputs [proof sketch: up to a null boundary, $\{\theta:f_\theta=f\}$ is an open semialgebraic set whose Gaussian measure is approximable from below by rational boxes certified inside it]. *Proof.* Fact B for the family indexed by $a$. ∎

* Hänni's version has an extra $\log\log(1/p)$ term, from describing a probability cutoff; it is unnecessary.
* This is the "simplicity bias" bound of Dingle, Camargo & Louis (*Nat. Commun.* 9:761, 2018) [known (snippet)], who state it with computable complexity approximations and fitted constants. The slides (Appendix F) state the same one-directionality.

**Proposition 4.3 (sampled functions nearly saturate the bound, for any prior) [proved; known as a standard fact; hypotheses made explicit after referee m9].**
* For **every** semimeasure $P$ on truth tables, every string $a$ and every $t\ge0$: $P\{f:P(f)\le2^{-K(f\mid a)-t}\}\le2^{-t}$. *Proof.* The left side is $\le\sum_f2^{-K(f\mid a)-t}\le2^{-t}$ (Fact C). ∎
* If moreover $P=P_A$ is lower-semicomputed by $a$ (Prop 4.2) and $\pi$ is a probability measure, then with probability $\ge1-2^{-t}$ over $\theta\sim\pi$: $K(f_\theta\mid a)-c\le-\log P_A(f_\theta)<K(f_\theta\mid a)+t$.
* This is the usual Kraft/Markov argument behind "$K(x)\approx-\log P(x)$ for $P$-most $x$" [known: Li & Vitányi, sections on the coding theorem and on expected complexity versus entropy (unverified section numbers); also the examples track's Lemma 1.2].

This confirms Hänni's remark that the result "should be true about any low complexity prior on functions — the NNs aren't doing anything here". $P_A$ looks like $2^{-K}$ *on its own typical set*, which can omit most simple functions.

**Proposition 4.4 (no general lower bound) [proved].**
1. Let $F_d$ be the set of functions computable by architecture $A_d$, with $|F_d|<2^{2^d}$ and membership in $F_d$ decidable given $d$ (any finite parameter set; any fixed real-weight threshold architecture, by Tarski's decision procedure). The first truth table $f_d\notin F_d$ has $K(f_d)\le K(d)+c$ and $P_{A_d}(f_d)=0$. For example, a threshold network with $s(d)=2^{o(d)}$ gates computes at most $2^{o(2^d)}$ functions (known counting; unverified constant). So no bound $P_A(f)\ge2^{-aK(f)-b}$ with $a,b$ independent of $d$ holds for such families. The slides (Appendix F) make the same point with functions that diagonalise against all small circuits.
2. The parameter–function-map formalism alone implies no simplicity bias: a lookup-table "architecture" with uniform parameters gives $P(f)=2^{-2^d}$ for every $f$, and Hänni's footnote construction gives zero mass to every simple fast function.

### 4.3 Uniform circuit priors and what a bridge would give

**Proposition 4.5 (uniform priors over fixed-size circuits contain the circuit simplicity prior) [proved; one half of Hänni's "first open problem"].** Let $P_{\mathrm{unif},S}$ be uniform over circuits of size exactly $S$ (§3.2). For every $f$ with $c(f)<S$:
$$P_{\mathrm{unif},S}(f)\ \ge\ \frac{1}{N_{c(f)}\cdot16(d+1+S)^2}\ =\ \frac{2^{c(f)}\,w(C_{\min})}{16(d+1+S)^2}.$$
Consequently Bayes with this prior makes at most $(\ln2)\big(\log N_{c(f)}+2\log(d+1+S)+4\big)=O(c(f)\log(c(f)+d)+\log S)$ posterior-sampling mistakes on **every** ordering, for every $f$ with $c(f)<S$.

*Proof.* Let $C$ be a minimal circuit, of size $s=c(f)$. The size-$S$ circuits whose first $s$ gates equal $C$, whose gates $s+1,\dots,S-1$ are arbitrary, and whose last gate is $\mathrm{AND}(\text{gate}_s,\text{gate}_s)$ all compute $f$. Their fraction is $\prod_{j=s+1}^{S-1}16(d+1+j)^2/\prod_{j=1}^S16(d+1+j)^2=1/(N_s\cdot16(d+1+S)^2)$. Mistakes: the cumulative log loss on any ordering is $\le-\log P_{\mathrm{unif},S}(f)$, and $m\le(\ln2)\times$ that. ∎

This is the circuit analogue of the padding argument for programs. The other half (that the uniform prior is not much *larger* than the simplicity prior on functions without small circuits) is open; it would need exception surgery inside a fixed size, by re-using dead gates.

**What a bridge would give [proved, each from the stated hypothesis].**
* *Lower half.* If $P_A(f)\ge2^{-a\ell(f)-b}$ for a description length $\ell$, then on every ordering NN Bayes makes $\le(\ln2)(a\ell(f)+b)$ Gibbs mistakes and $\le a\ell(f)+b$ posterior-majority mistakes (Theorem 2.7's proof; Remark 3.10).
* *Upper half.* If also $P_A(f)\le2^{-a'\ell(f)+b'}$, the full-domain log loss is $\ge a'\ell(f)-b'$.
* *The converse (few mistakes ⇒ small circuit).* Hänni wrote that it is "true for NN bayes as well". `notes.md` called this unproved. The slides now **claim** it in their strong-prior setting ("the circuit complexity $C_L$ of the learned function is at most poly($d$, #mistakes made while learning it)", "Additional results"); I found no proof in the slides, so it is **[claimed in the slides]**. For circuit Bayes it holds on every ordering (Theorem 3.5). For a fixed finite architecture it is trivially true with a bound depending on the architecture's size.

### 4.4 The NNGP/NTK caveat

**Theorem 4.6 [proved; computed, c2; (a) known, (b) standard].**
* **(a) Walsh diagonalisation.** Let $k(x,x')=\kappa(\langle x,x'\rangle/d)$ on $\{\pm1\}^d$. Then every Walsh character $\chi_S$ is an eigenfunction of $(Tg)(x)=\mathbb E_{x'}k(x,x')g(x')$, with eigenvalue depending only on $|S|$. This covers the NNGP and NTK kernels of fully connected networks with i.i.d. Gaussian weights and biases, since $\|x\|^2=d$ is constant on the cube.
* **(b) Dimension lower bound.** Let $V$ be any space of functions on $\{\pm1\}^d$ of dimension $\le n$, e.g. $V=\mathrm{span}\{k(x_i,\cdot)\}_{i\le n}$ for any kernel and training inputs, which contains the GP posterior mean (Gaussian likelihood, any noise level) and the kernel ridge regression solution. Then, in $L^2$ of the uniform distribution,
  $$\frac1{\binom dk}\sum_{|S|=k}\ \min_{g\in V}\|\chi_S-g\|^2\ \ge\ 1-\frac n{\binom dk}.$$

*Proof.* (a) $k(x,x')=h(x\odot x')$ with $h(z)=\kappa(\sum_jz_j/d)$, $\odot$ the coordinatewise product. With $x'=x\odot z$ (uniform), $(T\chi_S)(x)=\mathbb E_z[h(z)\chi_S(x\odot z)]=\chi_S(x)\hat h(S)$, and $\hat h(S)=\mathbb E_z[h(z)\chi_S(z)]$ depends only on $|S|$ because $h$ is invariant under coordinate permutations. (b) $\min_{g\in V}\|\chi_S-g\|^2=1-\|P_V\chi_S\|^2$ and $\sum_{\text{all }T}\|P_V\chi_T\|^2=\operatorname{tr}P_V=\dim V\le n$. ∎

*Credit (corrected after referee M3(a), M5).* (a) is known: Yang & Salman, arXiv 1907.10599 [known (snippet): "eigenvalue depends only on $|S|$"]; the slides (Appendix J) prove it by the same character argument and quote Yang–Salman's statement that both kernels "are diagonalized by the natural Fourier basis". (b) is the standard dimension argument [known: Kamath, Montasser & Srebro, "Approximate is good enough: probabilistic variants of dimensional and margin complexity", COLT 2020, PMLR 125:2236–2262 (snippet); the slides cite its "Example 1". The theorem number "Thm 19" given in `notes.md` is withdrawn as unverified]. The slides give the trace-budget form: for a kernel normalised by $k(x,x)=1$, $\#\{S:\lambda_S\ge1/n\}\le n$. Lower bounds for rotation-invariant kernels in high dimension: Donhauser, Wu & Yang, ICML 2021, PMLR 139:2804–2814 [known (snippet)]; Ghorbani, Mei, Misiakiewicz & Montanari [cited by the slides; unverified]. Nothing in Theorem 4.6 is new.

**Corollary 4.7 (separation from SFI) [proved; computed, c2].**
* *SFI side.* On any sequence of distinct inputs, program SFI on $\chi_S$ ($|S|=k$) has $\sum_te_t\le(\ln2)(K(\chi_S)+c)$, with $K(\chi_S)\le\log\binom dk+2\log(k+1)+2\log(d+1)+c$.
* For i.i.d. uniform inputs, the posterior-mean predictor $\hat g\in[-1,1]$ has pointwise squared error $\le4e^2\le4e$ (corrected after referee m16: with right label $y^*$, wrong mass $w$ and error $e\ge w$, $|y^*-\hat g|=e+w\le2e$). Its test mean squared error averaged over the first $n$ steps is $\le4(\ln2)(K(\chi_S)+c)/n$.
* *Kernel side.* Any kernel method or GP posterior mean needs $n\ge(1-\varepsilon)\binom dk$ samples for average error $\le\varepsilon$ over random $k$-sparse targets; SFI needs $O(k\log d/\varepsilon)$ in the Cesàro sense, or per step by Cor 2.17(a). The separation is exponential in $k$.
* *Computed* ($d=10$, 20 targets per cell, ridge $10^{-3}$, c2). For two- and three-layer ReLU NNGP, NTK and RBF the kernel error is above $1-n/\binom dk$ in every cell; for $k=5$ it stays above 0.68 at every $n\le640$ (three-layer NNGP 0.75, RBF 0.68, two-layer kernels about 1.5). The parity-restricted Bayes mixture (prior $2^{-\ell(S)}$) has error 0.000 from $n=20$ ($k=5$) and $n=40$ ($k=3$), and cumulative Gibbs mistakes (mean 3.7–5.5, max 6.04) below the proved bound $(\ln2)\ell(S)$ (6.70–9.81). Errors above 1 come from near-interpolation with a small ridge. c2 asserts the lower bound per cell over 20 sampled targets with tolerance 0.05, which is weaker than Theorem 4.6(b) itself.

**Remark 4.8 (two-layer bias-free ReLU kernels and odd parities).**
* **(a) [proved; computed, c2; known].** For the two-layer bias-free ReLU NNGP, $\kappa_1(\rho)=(\sqrt{1-\rho^2}+\rho(\pi-\arccos\rho))/\pi$, and for the NTK, $\kappa_1(\rho)+\rho\kappa_0(\rho)$ with $\kappa_0(\rho)=(\pi-\arccos\rho)/\pi$, the function $\kappa(\rho)-a\rho$ is even ($a=\frac12$ for the NNGP, $a=1$ for the NTK). So $z\mapsto\kappa(\rho(z))-a\rho(z)$, $\rho(z)=\sum_iz_i/d$, is invariant under $z\mapsto-z$ and has no odd Walsh coefficients, while $a\rho(z)$ has Walsh coefficients only at $|S|=1$. Hence the eigenvalue of every $\chi_S$ with $|S|$ odd and $\ge3$ is exactly 0. Then $V=\mathrm{span}\{k(x_i,\cdot)\}\perp\chi_S$ and $\|\chi_S-\hat g\|^2=1+\|\hat g\|^2\ge1$ for every $n$: the kernel predictor never learns these parities. c2 computes these eigenvalues as below $3\cdot10^{-18}$ in absolute value; biases or a third layer make them nonzero. *Known:* Basri, Jacobs, Kasten & Kritchman, "The convergence rate of neural networks for learned functions of different frequencies", NeurIPS 2019 (arXiv 1906.00425) [known (snippet): a shallow network without bias cannot represent or learn low-frequency functions with odd frequencies, on the sphere]. The referee also attributes the vanishing of the odd NTK eigenvalues to Bietti & Mairal, "On the inductive bias of neural tangent kernels", NeurIPS 2019 (arXiv 1905.12173); my searches confirmed the paper but not that statement (attribution unverified). The cube version is the same algebra. The arc-cosine kernel is from Cho & Saul, NeurIPS 2009 [known (unverified)].
* **(b) GP classification [proved; computed, c10; new as far as I know].** Let $z\sim\mathrm{GP}(0,k)$ on the cube with $k$ one of these two kernels and $|S|\ge3$ odd. Then $\langle z,\chi_S\rangle:=\mathbb E_xz(x)\chi_S(x)$ is Gaussian with mean 0 and variance $\lambda_S=0$, so $\langle z,\chi_S\rangle=0$ almost surely. Any $z$ with $\operatorname{sign}z=\chi_S$ on the whole cube has $\langle z,\chi_S\rangle=\mathbb E|z|>0$. So the GP prior, and every posterior obtained by conditioning it on events of positive probability (sign or margin likelihoods, such as the slides' rule $|z|>\frac12$), gives probability exactly 0 to "the classifier equals $\chi_S$". c10 ($d=8$): $\mathrm{Var}\langle z,\chi_S\rangle\le4.4\cdot10^{-18}$ for $|S|\in\{3,5\}$ under both kernels, against $1.5\cdot10^{-4}$ and $1.4\cdot10^{-3}$ at $|S|=4$, and $8.4\cdot10^{-5}$ ($|S|=3$) with a bias term. The per-point test error of GP classification on these parities is **open**.

### 4.5 The Vaintrob–Hänni slides

**Source.** D. Vaintrob and K. Hänni, *A Generalization Result for Overparametrized Neural Net Bayesian Learning*, slides, ILIAD 2026, 110 pages (footers numbered to 38); https://kaarelh.github.io/ai/nnbayes-generalization.pdf; local copy `prior/vaintrob-hanni-nnbayes-generalization-slides.{pdf,txt}`, read in full for this revision. `notes.md` treated them as unavailable (referee M3).

**Their own caveats.** "Kaarel used Claude's help when creating these slides." The appendices "have largely been generated by Claude from bullet-point outlines and rough notes", and "I haven't meticulously reviewed many appendix slides yet, so there could be some errors". The main results are stated as "much more caveated and detailed versions" of their headline claims. Only the strong-prior case is proved in the talk. The setting is Bayesian, not SGD, and the authors say these are "importantly different".

**What they claim.**
1. *Warm-up (SFI).* Python programs with prior $\propto3^{-|p|}$, i.i.d. inputs from a distribution $D$; $C$ the length of the shortest program for $f$. After $n=O(C)$ samples, with probability $1-\exp(-\Omega(C))$, the posterior's average probability on the correct answer exceeds 99.9%; the posterior-majority predictor then errs on less than 0.2% of test inputs. A proof is given.
2. *Relevance-based sample-complexity bound* (Appendix A). Countable class $H\ni f$, prior $\pi$, $S\subseteq H$ with $f\in S$, $|S|\le M$, $\pi(H\setminus S)\le T\pi(f)$. After $n\ge\frac1\varepsilon(\log M+\log(2+T)+\log\frac1\delta+\log\frac1\eta)$ samples, with probability $\ge1-2\delta$, the average probability on the correct answer is $\ge1-(\varepsilon+\eta)$. Body version: $4000(\log M+4)$ samples, probability $\ge1-\frac1{1000M}$, accuracy $>99.9\%$.
3. *Setting of the main theorem.* An MLP of depth $L$ and width $N$; activation bounded, Lipschitz and non-polynomial; no biases (a constant input instead); a weight vector implements $f$ if $z_w(x)>\frac12$ where $f=1$ and $<-\frac12$ where $f=-1$, and the prior is restricted to weights implementing full Boolean functions; Gaussian weights with standard deviations $\sqrt{N/d}\,\sigma$, $\sigma$, $\sigma/\sqrt N$ (first, inner, output layers); the strong-prior limit $\sigma\to0$ at fixed $N$.
4. *Complexities.* $C_L(f)$, the least $C$ such that a depth-$L$, width-$C$ MLP with weights of absolute value at most $C$ implements $f$; $\kappa_N(f)$, the least layer-weighted squared norm of an implementing weight vector.
5. *Main theorem.* For $C=C_L(f)$ and any width $N\ge C$, after $\mathrm{poly}(d,C)$ samples, with probability $1-\exp(-\Omega(C))$, the average posterior probability on the correct answer exceeds 99.9%. The polynomial hides a factor exponential in the depth.
6. *Equivalence.* $\kappa_N(f)\le\mathrm{poly}(d,C_L(f))$ and $C_L(f)\le\mathrm{poly}(d,\kappa_N(f))$, with polynomials independent of $N$ ("cloning" and "subsampling"); hence $\#\{g:\kappa_N(g)\le\kappa_N(f)\}\le\exp\mathrm{poly}(d,C_L(f))$, and the relevance-based bound applies.
7. *Robust weights.* Restricting the prior to "robust" weights makes the dependence on depth polynomial.
8. *Additional results.* An in-distribution online mistake bound $\mathrm{poly}(d,C_L(f))$ in expectation; and "the circuit complexity $C_L$ of the learned function is at most $\mathrm{poly}(d,\#\text{mistakes made while learning it})$".
9. *Other regimes.* Mean field: Vaintrob & Hänni, arXiv 2607.05735 (cited by the slides; that arXiv number, title "Width-Robust Learnability in Mean-Field Bayesian Neural Networks" and date are confirmed only by a search snippet). The strong-prior proof write-up is "upcoming". The NNGP does not have a good circuit prior: its kernel is diagonal in the parities (Appendix J), and heuristically a size-$k$ XOR needs about $d^k$ samples.
10. *Out of distribution* (Appendix K): the in-distribution guarantee is false out of distribution; the conjunction ladder (Theorem 3.11 here) and the table of selection rules (Remark 3.12).
11. *Open problems they list.* A lower bound on the log prior of a function; bounding the tail at fixed small $\sigma>0$; removing $\exp(\text{depth})$; classifying scalings; an OOD mistake bound for NN Bayes; other architectures; gradient descent.

**What I checked.** Items 1 and 2: the proofs read correctly, and the arithmetic holds [computed, c8]: the tail inequality $3(2/3)^{3C+26}<3^{-C}/2000$ is equivalent to $\ln6000+26\ln\frac23+C\ln\frac89<0$, true for all $C\ge0$ since $\ln6000+26\ln\frac23=-1.84$; the union bound gives $e^{-C}$ at $n=2000((3C+26)\ln2+C)$; and at $n=4000(\ln M+4)$ the union-bound and Markov conditions reduce to $e^{-8}=3.4\cdot10^{-4}<1/2000$. The general formula of Appendix A is a sufficient condition and is looser than the body's $4000(\log M+4)$; the body's constants follow from the proof, as the slides say. Appendix J's character argument is Theorem 4.6(a). Appendix K is Theorem 3.11, proved here independently for two languages. **Not checked:** items 3–9 (main theorem, equivalence, counting, robust variant, mistake bounds, mean field) and Appendices B–I. They are **[claimed in the slides]**.

**How they relate to this track.**
* *SFI warm-up versus §2–3.* The warm-up and Appendix A are in-distribution, high-probability and per-$n$. Theorem 2.7 is pathwise and Cesàro, on every input sequence. Cor 2.17(a) is the Markov half of Appendix A applied to $W$ and $M_F$: it needs neither the union bound nor the geometric length prior $3^{-|p|}$. Prop 3.8 is the classical Occam special case, as Appendix A also notes.
* *NN Bayes ≈ circuit SFI.* The main theorem says that, in the strong-prior limit, the prior *ordering* of functions is polynomially scrambled relative to circuit complexity, which is enough for the relevance-based bound. That is a statement about log-indices, not a two-sided bound on prior mass; the slides list a lower bound on the log prior as open. It addresses Hänni's "second open problem" (`hanni-bridging-parametrized-bayes-and-solomonoff.md`) in that limit and in that ordering sense, by a route that bypasses the uniform circuit prior of his first open problem (Prop 4.5).
* *Mistakes ⇒ small circuit.* Item 8's second claim is the NN analogue of Theorem 3.5(b)+(a), which is proved here for circuit Bayes on every ordering.
* *NNGP.* Item 9's NNGP picture agrees with Theorem 4.6 and Remark 4.8. Remark 4.8(b) is the exact zero-mass version of their Appendix J estimate $-\log\pi(w\text{ implements }\chi_S)\approx\Theta(1)/\lambda_{|S|}$.
* *OOD.* Item 10 agrees with Theorem 3.11 and Remark 3.12.

### 4.6 What can be said rigorously about "NN Bayes ≈ circuit SFI"

* **Proved here.**
  * (i) NN Bayes is function-space Bayes with prior $P_A$ (Prop 4.1).
  * (ii) $P_A\le2^{-K+O(K(a))}$, and on its typical set $P_A\approx2^{-K}$, for any prior (Props 4.2–4.3).
  * (iii) No general lower bound: fixed architectures miss $K$-simple functions without small circuits (Prop 4.4). So the right comparison object is **circuit** SFI, not program SFI.
  * (iv) For gate-list "architectures", the uniform prior over a fixed size contains the circuit simplicity prior up to $\mathrm{poly}(S)$ and inherits circuit Bayes's mistake bounds on every ordering (Prop 4.5).
  * (v) In the infinite-width Gaussian limits (NNGP/NTK) the regression predictor is diagonal in the Walsh basis and needs $\binom dk$ samples for $k$-sparse parities where circuit and program SFI need $O(k\log d)$ (Thm 4.6, Cor 4.7); for bias-free two-layer ReLU kernels, odd parities of degree $\ge3$ are never learned and have GP-classification prior mass 0 (Rem 4.8).
  * (vi) Circuit Bayes: mistakes and circuit size are polynomially related on every ordering (Thm 3.5); argmax (Occam) selection over the same prior is exponentially worse out of distribution (Thm 3.11).
* **Claimed in the slides, not checked here.** In the strong-prior limit with sigmoid-type activations: polynomial equivalence of $\kappa_N$ and $C_L$ uniformly in width; $\mathrm{poly}(d,C_L(f))$ in-distribution sample complexity and mistake bound; "mistakes ⇒ small circuit"; the mean-field case (arXiv 2607.05735).
* **Open.** A two-sided bound on $P_A(f)$ itself at fixed $\sigma$ (the slides list it as open); finite-width continuous-weight priors outside the strong-prior limit; whether NN Bayes generalises like SGD-trained networks at all (Hänni's skepticism in `hanni-bridging-parametrized-bayes-and-solomonoff.md`; the slides also stress that Bayes is not SGD).

### 4.7 The simplicity-bias literature

**The parameter–function map.**
* Dingle, Camargo & Louis, "Input–output maps are strongly biased towards simple outputs", *Nat. Commun.* 9:761, 2018 [known (snippet)]. $P(x)$ decays exponentially with an approximate complexity, and the upper bound is tight for most inputs. Prop 4.2 is the exact (uncomputable) version; Prop 4.3 explains "tight for most inputs" without any property of the map.
* Valle-Pérez, Camargo & Louis, "Deep learning generalizes because the parameter-function map is biased towards simple functions", ICLR 2019, arXiv 1805.08522 [known (snippet)]. Hänni's critique (`hanni-kolmogorov-prior-in-NNs.md`) is that the upper bound holds for every map and the needed lower bound fails in general; Props 4.3–4.4 make both points rigorous, and the slides (Appendix F) agree.
* Mingard, Valle-Pérez, Skalse & Louis, "Is SGD a Bayesian sampler? Well, almost", *JMLR* 22(79):1–64, 2021 [known (snippet)]: empirically $P_{\rm SGD}(f\mid S)\approx P_B(f\mid S)$ to first order. This bears on Hänni's doubt that NN Bayes and SGD are similar; these notes take no position.
* Mingard et al., "Neural networks are a priori biased towards Boolean functions with low entropy", arXiv 1909.11522 [unverified]; Mingard et al., "Deep neural networks have an inbuilt Occam's razor", *Nat. Commun.* 2025 [cited by the slides; a search result shows arXiv 2304.06670 under this title; otherwise unverified].
* Buzaglo, Harel, Shpigel Nacson, Brutzkus, Srebro & Soudry, "How uniform random weights induce non-uniform bias: typical interpolating neural networks generalize with narrow teachers", ICML 2024, PMLR 235:5035–5081 [known (snippet)]: random interpolators under a flat parameter prior generalise when a narrow teacher exists; the slides call it the closest prior work and note that its bound degrades linearly in the student width.

**No free lunch, Kolmogorov complexity and universal predictors.**
* Goldblum, Finzi, Rowan & Wilson, "Position: The no free lunch theorem, Kolmogorov complexity, and the role of inductive biases in machine learning", ICML 2024, PMLR 235:15788–15808, arXiv 2304.05366 [known (snippet; page range now confirmed)].
* Lattimore & Hutter, "No free lunch versus Occam's razor in supervised learning", in *Algorithmic Probability and Friends*, LNCS 7070, pp. 223–235, arXiv 1111.3846 [known (snippet)]: a Solomonoff-inspired off-line classifier; random selection of training data can reduce misclassification (related to Prop 2.9; whether it is the same statement is unverified).
* Grau-Moya, Genewein, Hutter, Orseau et al., "Learning universal predictors", ICML 2024, PMLR 235:16178–16205, arXiv 2401.14953 [known (snippet)]: networks meta-trained on data from universal Turing machines to approximate Solomonoff induction. The function analogue is meta-training on $(x,f(x))$ prompts with $f$ from a program prior.

**Amortised function induction.**
* Müller, Hollmann, Pineda, Grabocka & Hutter, "Transformers can do Bayesian inference", ICLR 2022, arXiv 2112.10510 [known (snippet)]; Garg, Tsipras, Liang & Valiant, "What can transformers learn in-context?", NeurIPS 2022, arXiv 2208.01066 [known (snippet)].
* Both train a network on prompts $(x_1,y_1,\dots,x_k)$ with $f$ drawn from a prior. The trained network approximates the posterior predictive *with history in context*, i.e. a chronological predictor (history track). With a program or circuit prior this is amortised SFI. The steeper track's Prop 4.1 makes the related point that an in-context Bayes mixture is a single short hypothesis.

**Infinite-width limits.** Lee et al., "Deep neural networks as Gaussian processes", ICLR 2018 [known (snippet)]; Jacot, Gabriel & Hongler, "Neural tangent kernel", NeurIPS 2018, arXiv 1806.07572 [known (snippet)]; Yang & Salman, arXiv 1907.10599 [known (snippet)]; Neal, *Bayesian Learning for Neural Networks*, 1996 [known (unverified)].

**Hänni's notes in this area.**
* `hanni-kolmogorov-prior-in-NNs.md`: Props 4.2–4.4 prove its claims and remove its $\log\log$ term.
* `hanni-bridging-parametrized-bayes-and-solomonoff.md`: Prop 4.5 settles one half of its first open problem; the slides address its second in the strong-prior limit (claimed); Thm 4.6 and Rem 4.8 prove its NNGP/NTK remark for the posterior mean and, for odd parities, for classification.
* The LessWrong post "Deep Learning is cheap Solomonoff induction?" (dated 7 December 2024 per snippet; author shown as "Lucius", surname unconfirmed) [snippet only].

---

## 5. Further results

### 5.1 Order independence (corrected after referee M2)

A **predictor** assigns to every data set $D$ and $x\notin\operatorname{dom}D$ a sub-probability vector $q(\cdot\mid x,D)$ on $Y$. It is **order independent** if, for every $D$, the product of its one-step probabilities along an enumeration of $D$ is the same for all enumerations.

**Proposition 5.1 [proved; (a) is the foundations track's "predictor reading" of its Def 2.1; computed, c3 Part 1].**
* **(a)** $q$ is order independent iff there is a weak function semimeasure $\nu$ with $\nu(\emptyset)=1$ and $q(y\mid x,D)=\nu(D+(x,y))/\nu(D)$ whenever $\nu(D)>0$.
* **(b)** If moreover every $q(\cdot\mid x,D)$ sums to 1, then $\nu$ is the containment functional of a unique law of a random **total** function $F\in Y^X$: $P(F\supseteq D)=\nu(D)$.
* **(c)** $\nu$ is the containment functional of a random **partial** function iff it satisfies the Möbius condition of foundations Prop 2.3.

*Proof.* (a) ⇐: telescoping. ⇒: let $\nu(D)$ be the common product; enumerating $D$ first and $x$ last gives $\nu(D+(x,y))=\nu(D)q(y\mid x,D)$, and summing over $y$ gives the weak inequality. (b) Now $\sum_y\nu(D+(x,y))=\nu(D)$, so for each finite $A\subseteq X$ the map $l\mapsto\nu(l)$ on labellings of $A$ is a probability distribution (by induction on $|A|$), and these distributions are consistent under marginalisation. $Y$ is countable, so the Kolmogorov extension theorem gives the law on $Y^X$ [known]; uniqueness holds because cylinder probabilities are determined. (c) Foundations Prop 2.3. ∎

**[refuted] in `notes.md`.** Its Prop 5.1 was titled "order-independent predictors are Bayesian predictors for random partial functions", and its reading said that order independence "singles out exactly the Bayesian predictors over random (partial) functions". That is false for sub-probability predictors. Counterexample (foundations Ex 2.4): inputs $a,b$, labels $\{0,1\}$, $\nu(\emptyset)=\nu(\{(a,0)\})=\nu(\{(b,0)\})=1$, all other values 0. This is a weak semimeasure, so its predictor is order independent. A random partial function with $P(F(a)=0)=P(F(b)=0)=1$ has $P(F(a)=0,F(b)=0)=1\ne0$. More generally, weak semimeasures can give pairwise incompatible data sets total mass above 1, which no law of a random partial function can do: foundations Ex 2.4 gives three such data sets of total mass $\frac32$, and its block products give $3^k$ of total mass $(\frac32)^k$ (foundations Thm 3.5(iii)).

**Corollary 5.2 (universal order-independent predictors) [proved, from the foundations track; replaces Cor 5.2 of `notes.md`].**
* **(a)** For every function machine $T$, every $D$ and every order, $-\log M_F(D)\le-\log\nu_T(D)+K(\nu_T)$ (foundations Thm 3.2 and Fact A).
* **(b)** The universal element of the class of all lower-semicomputable order-independent predictors is $M^w$ (foundations Thm 3.4), not $M_F$: $\log(M^w(D)/M_F(D))\le K(\operatorname{dom}D)+O(1)$ always, and $\ge k\log\frac32-K(k)-O(1)$ for some data sets with $2k$ points (foundations Thm 3.5). `notes.md`'s Cor 5.2 assumed "$M_F$ dominates every lower-semicomputable function semimeasure"; that hypothesis is **refuted** by foundations Thm 3.5(iii).
* **(c) New.** For finite $Y$, $M_F$ is universal among lower-semicomputable **normalised** order-independent predictors: if $\nu$ is lower semicomputable and all its conditionals sum to 1, then $M_F\ge2^{-K(\nu)-O(1)}\nu$.

*Proof of (c).* By Prop 5.1(b), $\nu$ is the law of a random total function. With $Y$ finite, $\nu$ is computable: by induction on $|D|$, $\nu(D+(x,y))=\nu(D)-\sum_{y'\ne y}\nu(D+(x,y'))$ is upper semicomputable as well as lower semicomputable (foundations, remark in Thm 6.5). A computable law of a random function with finite label set is a machine law with an index computable from that of $\nu$ (foundations Prop 3.3(c)). Apply foundations Thm 3.2. ∎

*Reading.* Requiring that an inductor's total surprise on a data set not depend on the presentation order gives exactly the weak function semimeasures. Requiring in addition that each prediction be a probability vector gives exactly the random total functions, and among the lower-semicomputable ones (finite $Y$) SFI is universal. SFI's own normalised predictor is order dependent in general (foundations Prop 5.3). History-aware predictors that exploit the order, such as the chain predictor, violate order independence; their ideal is SFI$^{\rm hist}$ (history Cor 4.3).

*Computed (c3).* For a random 6-point mixture with partial and product hypotheses (a law of a random partial function): the semimeasure-convention loss is $10.919980315195$ in all 720 orders; the normalised loss ranges from 7.33 to 10.64.

### 5.2 Chosen inputs (active learning)

**Proposition 5.3 [proved].**
1. For any query set $A$, chosen adaptively or not, the total semimeasure-convention log loss on the labels of $A$ is $-\log(\nu(f|_A)/\nu(\emptyset))$, whatever the order. For log loss on the queried labels, choosing the order is worthless; only the choice of the set matters.
2. Small total loss does not give efficient identification. Let $f_a=[x=a]$ on $\{0,1\}^n$. SFI's total loss on any query sequence, even all of $\{0,1\}^n$, is $\le K(f_a)+c\le n+2\log n+c$. Yet any query strategy (adaptive, randomised) needs $\ge(2^n-1)/2$ queries in expectation over uniform $a$ to identify $a$: until $a$ is queried every answer is 0, so the queries are those the strategy makes on $f\equiv0$ (with the same coins), and identification needs $\min(\text{position of }a,\,2^n-1)$ queries, whose mean over uniform $a$ is $\ge(2^n-1)/2$.

So for active learning the log-loss guarantee must be paired with a different objective, such as expected information gain [known (snippet): Orseau, Lattimore & Hutter, "Universal knowledge-seeking agents for stochastic environments", ALT 2013].

### 5.3 Structured outputs

**Proposition 5.4 (single-query SFI and structured outputs) [proved, given Fact B].**
1. $M_F(\{(x,y)\})=2^{-K(y\mid x)\pm O(1)}$: single-query SFI is the conditional discrete universal distribution (also foundations Thm 6.3(c)).
2. $2^{-K^{\mathcal P}(y\mid x)}\le W(\{(x,y)\})\le2^{-K(y\mid x)+c}$, and the lower bound $W(\{(x,y)\})\ge2^{-K(y\mid x)-c}$ **fails** for every constant $c$. So $W$ and $M_F$ differ by more than a constant factor already on one-point data sets.
3. Let $M(\cdot\mid x)$ be the universal monotone semimeasure given $x$ (SI predicting $y$ symbol by symbol after $x$). Then $2^{-K(y\mid x)}\le2^cM(y\mid x)$, but $M(0^n\mid\epsilon)\ge2^{-c}$ while $2^{-K(0^n)}=2^{-K(n)\pm O(1)}$.
4. With an end marker, $M(y\$\mid x)=2^{-K(y\mid x)\pm O(1)}$.

*Proof.*
1. Upper bound: $y\mapsto M_F(\{(x,y)\})$ is a lower-semicomputable semimeasure given $x$; Fact B. Lower bound: the function machine that runs the conditional universal prefix machine on $x$, reading program bits lazily from $\omega$, outputs $y$ with probability $\ge2^{-K(y\mid x)}$.
2. The bounds: the shortest program for the lower one, Fact B for the upper one. *Failure of the lower bound.* Fix $t$ with $2^{1-t}\le\frac12$. For each $n$ pick $x_n$ of length $n$. Fewer than $2^{n-t+1}$ programs have length $\le n-t$, each with one output on $x_n$, so at least $2^{n-1}$ strings $y$ of length $n$ get all their $W$-mass from programs longer than $n-t$. Their total mass is at most $P_n:=\sum\{2^{-|p|}:p\in\operatorname{dom}V,|p|>n-t\}$, which tends to 0. Hence some such $y$ has $W(\{(x_n,y)\})\le2P_n2^{-n}$. But $K(y\mid x_n)\le n+c_0$ for every $|y|=n$ (read $n=|x_n|$ from the condition, then $n$ bits). So $W(\{(x_n,y)\})\ge2^{-K(y\mid x_n)-c}$ would force $P_n\ge2^{-c-c_0-1}$ for all $n$, a contradiction.
3. A prefix program for $y$ given $x$ is a monotone program that outputs $y$; a constant program outputs $0^\infty$.
4. "$\ge$" is part 3 applied to $y\$$. "$\le$": $y\mapsto M(y\$\mid x)$ is a lower-semicomputable semimeasure over the prefix-free set $\{y\$\}$; Fact B. ∎

* SFI treats an output as a complete object; it must commit to where the answer ends and pays for the length. SI on an undelimited $y$ does not. With delimiters, single-query $M_F$ and SI agree up to constants; across examples they differ in how information is shared (history track).
* Part 2 concerns the program mixture with **input-independent** self-delimitation, which is the $W$ of foundations Def 4.1. It pays up to $K(K(y\mid x))$ bits for not seeing the input while reading its program. The product law of the conditional universal discrete semimeasure $m(y\mid x)$ is a machine law of complexity $O(1)$ (foundations Thm 6.3(b)), so $M_{\rm prod}/W$ and $M_F/W$ are unbounded already on one-point data sets. This strengthens foundations Prop 4.3 (two-point data sets). A program mixture over conditional prefix programs (the machine may read $x$ first) would remove the single-query gap, but it is no longer a mixture over functions with input-independent weights.

### 5.4 Remarks

**Remark 5.5 (positive-example induction) [proof sketch].** Hänni's "positive example induction" learns a set or distribution from samples. In SFI terms, positive labels $(x,1)$ alone are useless: the constant-1 program explains them. The right formalisation is a sampling likelihood: samples are outputs of a hypothesis with private randomness per sample, i.e. SFI on index inputs $i\mapsto x_i$ restricted to index-ignoring product hypotheses. This gives the i.i.d. mixture $\sum_\mu w_\mu\prod_i\mu(x_i)$ over computable $\mu$, the private-randomness analogue of the universal semimeasure on the sample sequence. It is the object of Chater & Vitányi's ideal learning from positive evidence [known (snippet): *J. Math. Psych.* 51(3):135–163, 2007; their exact model unverified].

**Remark 5.6 (interventions).** If inputs are interventions set by the experimenter independently of the system's randomness, $x$-only dominance (foundations Thm 6.1) applies to the interventional law $P(y\mid\mathrm{do}(x))$. With observational inputs, SFI targets $P(y\mid x)$ like any conditional learner. I found nothing specific to SFI to prove here.

---

## 6. Literature on SFI-like objects

Status as above. "(snippet)" means the bibliographic data, and only the content quoted, were confirmed by a search snippet.

1. **Solomonoff's three kinds of induction.**
   * R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008 (snippet). The abstract describes (1) sequence extrapolation, (2) extrapolating an unordered set, and (3) **unordered sets of ordered pairs, where given the first element of a new pair one estimates a distribution over the second**, each with a convergence theorem. Kind (3) is supervised learning with a universal distribution. Secondary sources call it **operator induction** (E. Özkural, "Ultimate Intelligence" Parts II/III, arXiv 1504.03303 and 1709.03879 (snippet)), describe it as inferring a conditional density, and quote a convergence theorem bounding the total error by $\ln2$ times the complexity of the source.
   * *Unverified recollection.* Operator induction weights probabilistic operators $O^j(A\mid Q)$ by a priori probabilities and predicts with $\sum_ja_j\prod_iO^j(A_i\mid Q_i)$: the product (private-randomness) mixture, i.e. $M_{\rm prod}$ (foundations Def 4.1). If so, $M_{\rm prod}$ and its $x$-only dominance are Solomonoff's; this must be checked against the 2008 paper.
   * Earlier: Solomonoff, "Two kinds of probabilistic induction", *Comput. J.* 42(4):256–259, 1999 (snippet; content unverified); "Progress in incremental machine learning", IDSIA-16-03, 2003 (snippet; content unverified); *Information and Control* 7(1):1–22 and 7(2):224–254, 1964 (snippet; whether they discuss question–answer pairs is unverified); *IEEE Trans. Inf. Theory* 24(4):422–432, 1978 (unverified), the sequence convergence theorem.
2. **Hutter's chronological semimeasures.** M. Hutter, *Universal Artificial Intelligence*, Springer 2005, and the AIXI papers arXiv cs/0004001 and cs/0012011 (snippet). The universal chronological semimeasure dominates all enumerable chronological semimeasures (snippet). With actions as inputs and percepts as labels it is SFI$^{\rm hist}$ (history Cor 4.3). The book lists supervised learning from examples among AIXI's problem classes (snippet of Hutter's 2013 slides); the section's content is unverified.
3. **Lattimore, Hutter & Gavane**, "Universal prediction of selected bits", ALT 2011, LNAI 6925, arXiv 1107.5531 (snippet): normalised Solomonoff induction learns recursive sub-patterns in otherwise unstructured sequences; the unnormalised form can fail. Relevant to SI on interleaved $x_1y_1x_2y_2\ldots$ (history track).
4. **Lattimore & Hutter**, "No free lunch versus Occam's razor in supervised learning" (§4.7): a Solomonoff-inspired off-line classifier (snippet); their exact prior over functions is unverified.
5. **Leike & Hutter**, "Bad universal priors and notions of optimality", COLT 2015, PMLR 40:1244–1259 (snippet): AIXI's behaviour depends on the reference machine, with no invariance theorem; Prop 2.4 is a supervised, single-property analogue.
6. **MDL for regression and classification.** Poland & Hutter, "Strong asymptotic assertions for discrete MDL in regression and classification", Benelearn 2005, arXiv math/0502315 (snippet); "Asymptotics of discrete MDL for online prediction", *IEEE Trans. Inf. Theory* 51(11):3780–3795, 2005 (snippet). The slides (Appendix K) compare their MDL-versus-Bayes loss gap ($\Theta(2^{K})$ against $O(K)$) with the Occam-versus-majority gap of Theorem 3.11 [claimed in the slides]. Grünwald, *The Minimum Description Length Principle*, MIT Press 2007 (known); Grünwald & Langford, *Machine Learning* 66:119–149, 2007 (snippet).
7. **Ryabko**, "Pattern recognition for conditionally independent data", *JMLR* 7:645–664, 2006 (snippet): deterministic labels, objects conditionally i.i.d. given labels.
8. **Vovk**, "Universal forecasting algorithms", *Inf. Comput.* 96(2):245–277, 1992 (snippet; content unverified). Vovk, Gammerman & Shafer, *Algorithmic Learning in a Random World*, Springer 2005 (known (unverified)): conformal prediction, an exchangeability-based supervised framework related to Prop 2.9.
9. **PAC-Bayes, Occam, online-to-batch.** Blumer et al. 1987 (snippet). McAllester, COLT 1998 and *Machine Learning* 37(3):355–363, 1999; COLT 1999 (snippet). Haussler, Kearns & Schapire, *Machine Learning* 14:83–113, 1994 (snippet). Haussler, Littlestone & Warmuth, *Inf. Comput.* 115(2):248–292, 1994 (bibliography snippet-verified; content unverified). Littlestone, COLT 1989; Cesa-Bianchi, Conconi & Gentile, 2004 (unverified). Cesa-Bianchi & Lugosi, *Prediction, Learning, and Games*, Cambridge 2006 (known (unverified)): the Bayes-mixture regret $\log(1/w_i)$ used in Thm 3.1 and Prop 3.2a. Barron & Cover, *IEEE Trans. Inf. Theory* 37(4), 1991 (known).
10. **Li & Vitányi**, *An Introduction to Kolmogorov Complexity and Its Applications* (3rd ed. 2008; 4th ed. 2019) (known): coding theorem, conditional universal distribution, discrete versus continuous (Prop 5.4).
11. **Inductive inference of recursive functions.** Gold, *Information and Control* 10(5):447–474, 1967 (known); Bārzdiņš & Freivalds, *Dokl. Akad. Nauk SSSR* 206(3):521–524, 1972 (snippet; content unverified); Case & Smith, *TCS* 25:193–220, 1983 (snippet). The deterministic-identification ancestors, mostly in the input order $0,1,2,\ldots$.
12. **Average-case complexity and speed priors.** Impagliazzo & Levin, FOCS 1990, pp. 812–821 (snippet); Schmidhuber, COLT 2002, LNAI 2375, pp. 216–228 (snippet); Filan, Leike & Hutter, AISTATS 2016, PMLR 51:1394–1402 (snippet) (Question 3.4).
13. **Kernels and parities.** Yang & Salman (snippet); Kamath, Montasser & Srebro, PMLR 125:2236–2262 (snippet); Donhauser, Wu & Yang, PMLR 139:2804–2814 (snippet); Basri, Jacobs, Kasten & Kritchman, NeurIPS 2019 (snippet); Bietti & Mairal, NeurIPS 2019 (snippet for the bibliography only) (§4.4).
14. **The Vaintrob–Hänni slides** (§4.5), read in full; and Vaintrob & Hänni, arXiv 2607.05735 (snippet only).

**What exists, and what is new here (to the extent a snippet-level search can tell; corrected after referee M5).**
* *Exists.* The product mixture for supervised pairs and its convergence theorem (Solomonoff's third kind, very likely; verify). The chronological universal semimeasure (Hutter). Solomonoff-style classifiers and NFL discussion (Lattimore–Hutter). MDL classification (Poland–Hutter). Occam, PAC-Bayes and online-to-batch bounds, including the exchangeability argument of Prop 2.9. The halving / weighted-majority bound (Remark 3.10). The Walsh diagonalisation and the dimension lower bound for kernels (Thm 4.6). The vanishing odd eigenvalues of bias-free two-layer ReLU kernels (Remark 4.8(a); Basri et al.). Machine dependence of universal priors (Leike–Hutter; Prop 2.4 is an analogue). The conjunction ladder (slides, Appendix K; Theorem 3.11 gives a full proof for formulas and for circuits). The relevance-based bound (slides, Appendix A; Cor 2.17(a) is its Markov half for $W$ and $M_F$).
* *Apparently new* (no prior use found of the name "Solomonoff function induction"; none of the following found in the snippets):
  * the OOD results of §2 for SFI: the two-sided separation bounds (Prop 2.1, Thm 2.5, Prop 2.6), the novelty budget (Prop 2.8), the failure of the naive converse for random targets (Prop 2.13), the sandwich (Prop 2.14), the converse given the labelled sample (Prop 2.16), the per-step in-distribution bounds for SFI (Cor 2.17; part (a) is the slides' relevance argument specialised to $W$ and $M_F$), easy-to-hard and shortest-proof examples (Ex 2.15, 2.15a);
  * time-bounded SFI with length activation, and its round-clocked and history-aware variants (Thm 3.1, Props 3.2a, 3.2c), in the function setting; the sequence analogues are Hänni's polytime note and the speed-prior literature;
  * circuit Bayes mistakes ↔ size on every ordering with explicit constants (Thm 3.5);
  * the uniform-circuit padding bound (Prop 4.5);
  * GP-classification prior mass 0 for odd parities (Remark 4.8(b));
  * the order-independence characterisation in its corrected form (with the foundations track, whose predictor reading is Prop 5.1(a)), and universality of $M_F$ among normalised order-independent predictors (Cor 5.2(c));
  * the single-query separation of $W$ from $M_F$ (Prop 5.4(2)).
* Each "apparently new" item should be re-checked against Solomonoff (2008), Hutter (2005, the supervised-learning section) and Lattimore–Hutter (2013) before publication.

---

## 7. Open problems from this track

1. **LOO** (Conjecture 2.11): is $\frac1N\sum_xe_{\rm LOO}(x)=O(K_F(f|_B)/N)$ up to logarithms? It would also remove the additive $\ln m$ from Cor 2.17(a) (Remark 2.18).
2. **Efficient time-bounded SFI against samplers** (Question 3.4).
3. **A circuit coding theorem** for size priors with polynomial tails (Remark 3.6): do random large circuits rarely compute functions without small circuits?
4. **Few MAP mistakes ⇒ small circuit** (Remark 3.6).
5. **Occam out of distribution, beyond conjunctions.** Theorem 3.11 gives $2^{\Omega(\ell/\log\ell)}$ worst-case mistakes for $\mathrm{AND}_{[d]}$, tight for that target because there are only $2^d$ inputs. Is there a natural language and a target with $2^{\Omega(\ell)}$ worst-case Occam mistakes? (`notes.md`'s open problem 5, restated.) Does a steeper posterior over a prefix-free universal machine fail exponentially on some ordering (Remark 3.13)?
6. **Bridges.** The upper half of the uniform-circuit bridge (Prop 4.5); a lower bound on the NN log prior at fixed $\sigma$ (listed as open in the slides); a check of the slides' main theorem and of its "mistakes ⇒ small circuit" claim.
7. **GP classification** with NNGP/NTK priors on odd parities: per-point test error (Remark 4.8(b)).
8. **Machine-model details** of the running-time claims (Thm 3.1(b), Props 3.2a, 3.2c).

---

## 8. Cross-track consistency

Compared with the foundations, history and examples tracks' `notes.md` (no `notes-final.md` existed for them when this was written; the foundations and history revisions were in progress) and the steeper track's `notes-final.md`.

### 8.1 Definitions and notation

| Object | Here | Foundations | History | Examples | Steeper (final) |
|---|---|---|---|---|---|
| data set | finite partial function $D$ | same | function-consistent sequence, $D_n$ | same | same |
| deterministic program mixture | $W$, input-independent self-delimitation | $W$ (Def 4.1), same | — | — | — |
| SFI | $M_F$, law of $T_U$ | $M_F$ (Def 5.1) | $M_F$, $U^\omega$ | $M_F$ | mixture of $\Pi_F$ $=M_F$ |
| private-randomness mixture | $M_{\rm prod}$ | $M_{\rm prod}$ (Def 4.1) | — | — | $\xi_\times=M_{\rm prod}$ |
| universal weak semimeasure | $M^w$ (§5.1) | $M^w$ (Thm 3.4) | — | — | $\Pi_w$ |
| loss | $-\log\nu(D_n)$, semimeasure convention; normalised also used | same (Prop 5.2, 5.3) | $L_F$ | $L_{\rm SFI}$ | same |
| history-aware universal | SFI$^{\rm hist}$ (cited) | Hutter's $\xi$ (Prop 7.2) | SFI$^{\rm hist}\asymp\xi$ (Cor 4.3) | (F7) | $\Pi_{\rm chr}$ |

* All tracks use the same objects. This track now uses the foundations notation throughout (§1.4 maps the old notation).
* **Notation clashes for the paper.** $\lambda$ is the fair-coin tape measure here and in foundations, history and examples, but the steepness exponent in the steeper track; the steeper track suggests another symbol for the tape measure, and I agree. $c$ is a machine constant here, but $c=\lambda/N$ in the steeper track. $m$ is a training-set size (§2) and an expected number of mistakes (§3) here, a junta size in the steeper track, and $m(i)$ the universal discrete semimeasure in foundations. $K_F$ means the shortest consistent program length (foundations); `notes.md` used $K_B(f)$ for $K_F(f|_B)$ and $K_F(f)$ for $K(f)$.
* **Conventions.** Every OOD lower bound here (Props 2.1, 2.8, 2.12, Thm 2.5) bounds the *defined wrong* mass, so it holds in both conventions. The history and examples tracks' lower bounds (chain, skipped strings, H5, H6) hold only in the semimeasure convention. No conflict, but the paper should say which convention each lower bound uses.
* **Numbering.** Items of `notes.md` cited by other tracks keep their numbers: Props 2.1, 2.3, 2.4, Thm 2.5, Example 2.15, Thm 2.7 (examples track); Prop 2.1, Thm 3.1, Prop 3.3, §2.1, §4.1 (steeper track).

### 8.2 Results that interlock

* **Foundations.**
  * Foundations Thm 6.1 (pathwise dominance) with Theorem 2.7 gives the relative OOD statement of §2.5.
  * Foundations Thm 6.7(a) is the Cesàro form of online-to-batch for log loss; Cor 2.17(a) adds the per-step rate for the error probability, at the price of $+\ln m$; Prop 2.12 is the matching lower bound up to $\log^2m$ and $2^{\pm K}$. Consistent.
  * Foundations Prop 6.8 (fresh noise with repeated inputs makes SFI's loss infinite) is the reason the distinctness assumption of Thm 3.1 is a genuine restriction. Prop 3.2a is the time-bounded analogue of foundations' time-stamp repair (Thm 6.7(b)).
  * Foundations Prop 4.3 ($M_{\rm prod}/W$ unbounded on two-point sets) is strengthened by Prop 5.4(2) to one-point sets. Both use the same $W$, with input-independent self-delimitation; the separation depends on that choice.
  * Foundations §2–3 (weak versus machine universality) and §5.1 here now agree. `notes.md`'s Prop 5.1 reading and Cor 5.2 contradicted foundations, and foundations was right (referee M2). Cor 5.2(c) adds a positive statement derived from foundations Prop 3.3(c) and Thm 3.2.
  * Foundations §6.6 (description-length Occam bound) is Prop 3.8; foundations Cor 6.6 (at most $K(\varphi)+O(1)$ steps with conditional $\le\frac12$) is the SFI analogue of Remark 3.10's halving bound.
* **History.**
  * History Cor 4.3 (SFI$^{\rm hist}\asymp\xi$) is the unbounded counterpart of Prop 3.2c. Remark 3.2 uses history Thm 2.1(c) and 2.2(a): the chain and skipped-string predictors are fast and history-aware, and SFI's loss on those data is unbounded.
  * The gap in Prop 2.14 between $K(\cdot\mid B)$ and $K_F(\cdot)$ is the single-point form of the history track's sandwich (Thm 5.2) and of the examples track's H5 lower bound: what SFI lacks is knowledge of the other inputs.
* **Examples.**
  * The examples track's §5 uses Props 2.1, 2.3, 2.4, Thm 2.5, Example 2.15 and Theorem 2.7 as stated there. Their statement of Thm 2.7 as "total error $\le K(g)+c$" is implied by $\sum_ke_k\le(\ln2)(K+c)$.
  * Their §5.1 relative bound uses Prop 2.3. With the corrected Prop 2.3 the cost is $K(L'\mid p)$, conditional on the proof-search program, which is at most $K(L')+O(1)$; their stated bound still holds.
  * Their §5.2 (shortest proofs) and Example 2.15a agree. Their e5 computation (the intended answer gets 0.98–0.9998 or 0.11 depending on the grammar) is an instance of Prop 2.4.
  * Their parity bound $\log\binom dk+K(d)+K(k)+c$ (Example 4.2) and Cor 4.7's $K(\chi_S)$ bound agree up to the form of the $O(\log)$ terms.
* **Steeper.**
  * Steeper Prop 2.16(i) at $\lambda=1$ is Prop 2.1 for $M_{\rm prod}$ (the wrapper argument works for conditional semimeasures too); for $\lambda=cN$ it shows that steeper simplicity removes the constant lower bound of Prop 2.1.
  * Steeper Prop 2.16(ii) says the steeper posterior concentrates on the shortest train-fitting hypotheses, with no OOD guarantee. Theorem 3.11 and Remark 3.13 make this concrete for the formula prior: deterministic argmax fails exponentially on the ladder, while uniform tie-breaking (the $\lambda\to\infty$ limit there) makes $O(d^2)$ Gibbs and $O(d)$ majority mistakes. Neither result settles the steeper posterior over a universal machine.
  * Steeper Remark 4.7 (a network with an output law per $\theta$ is a mixture of product laws) and Prop 4.1 here (function-space Bayes with the parameter–function-map prior) are compatible views of the same posterior.
  * Steeper Prop 4.4 uses Thm 3.1 and Prop 3.3 with code-length weights; Remark 3.1a here recommends the same.

### 8.3 Disagreements

* Resolved: `notes.md`'s Prop 5.1 reading and Cor 5.2 against foundations §2–3 (now §5.1, agreeing with foundations).
* Resolved: `notes.md`'s claim that a super-polynomial Occam OOD lower bound is open, against the slides' Appendix K (now Theorem 3.11).
* None outstanding. The foundations and history tracks were being revised while this was written; their item numbers cited here refer to their `notes.md` of 2026-10-11 and may change.

---

## 9. Claims table

| ID | Claim | Status | Where |
|---|---|---|---|
| X1 | Unseen decidable $Q$ ⇒ every computable behaviour $b$ on $Q$ has posterior $\ge2^{-K(Q,b)-c}$, no log term, $W$ and $M_F$ | proved | Prop 2.1, Rem 2.2 |
| X2 | Relative version with conditional complexity $K(q,r\mid p)$ | proved (corrected) | Prop 2.3 |
| X3 | A universal machine $K(Q,b)+O(1)$ bits away gives bad behaviour posterior $\ge\frac12$ | proved; analogue of Leike–Hutter (known) | Prop 2.4 |
| X4 | Two-sided bound on $P$-abiding generalisation; single-input form | proved | Thm 2.5 |
| X5 | Draft's literal "at most $2^{-C(Q)}\cdots$" and "at least $2^{-C(P)}$" | refuted | Prop 2.6 |
| X6 | $\sum_ke_k\le(\ln2)(K(f)+c)$ on every sequence of distinct inputs | proved | Thm 2.7 |
| X7 | Separation lower bounds sum to $\le2^{-c}$ | proved | Prop 2.8, Rem 2.8a |
| X8 | `notes.md`: "total OOD error lies between novelty and complexity" | refuted as stated (lopsided) | Rem 2.8a |
| X9 | Random splits: expected test loss $\le K_F(f\vert_B)/\vert B\vert$ | proved; technique known; computed c3 | Prop 2.9 |
| X10 | LOO average $<2^{K_F+c}/N$ | proved; computed c7 | Prop 2.10 |
| X11 | LOO average $O(K/N)$ | conjecture | Conj 2.11 |
| X12 | In distribution, $\mathbb E\,e\ge2^{-K-c}/(8m(\log m+3)^2)$ | proved; computed c4 | Prop 2.12 |
| X13 | `notes.md`: "matches the Cesàro bound up to $\log^2m$" | refuted (invalid comparison) | Prop 2.12 |
| X14 | Naive converse fails for random $f$, for every learner | proved | Prop 2.13 |
| X15 | `notes.md`: "no bound of the form 'no simple separating property ⇒ small error' holds" | refuted as stated (overbroad) | Prop 2.13, 2.16 |
| X16 | Single-point sandwich | proved | Prop 2.14 |
| X17 | Easy-to-hard; shortest-proof labels | proved | Ex 2.15, 2.15a |
| X18 | Converse given the labelled sample: $e_{\rm norm}\le2^{K_F(f)-K(x^*\mid f)+c}$ | proved; disjointness computed c7 | Prop 2.16 |
| X19 | Per step in distribution: $\mathbb E\,e\le((K+c)\ln2+\ln m+1)/m$; also $\le2^{K+c}/(m+1)$ | proved; computed c7 | Cor 2.17 |
| X20 | Time-bounded SFI: constant regret on distinct inputs | proved (corrected); computed c5, c9 | Thm 3.1(a) |
| X21 | Its running time | proof sketch | Thm 3.1(b) |
| X22 | `notes.md`: "restricting to distinct inputs loses nothing" | refuted; computed c9 | §3.1 |
| X23 | Round-clocked mixture: constant regret on every stream | proved; computed c9 | Prop 3.2a |
| X24 | Time $n^{\omega(1)}$ against all polynomial-time predictors | proved | Cor 3.2b |
| X25 | Time-bounded history-aware class: constant regret | regret proved; time proof sketch | Prop 3.2c |
| X26 | Samplers: constant regret with both readings in the mixture | proved (corrected) | Prop 3.3 |
| X27 | Efficient learner against samplers | open | Q 3.4 |
| X28 | Circuit Bayes: $m\le(\ln2)L_B$, $L_B\le16m(d+1)\log(2(m+1)(d+2))$, $c_B(f)\le\lceil L_B\rceil$, every ordering | proved; computed c1, c8 | Thm 3.5 |
| X29 | Occam PAC; Occam in-distribution mistakes | known + proved; proved | Prop 3.8, 3.9 |
| X30 | Posterior-majority mistakes $\le L_B$ on every ordering | proved; known | Rem 3.10 |
| X31 | Möbius lemma | proved; computed c6 | Lemma 3.11a |
| X32 | Conjunction ladder: Occam makes $\ge2^d-2$ (formulas), $\ge2^d-d-2$ (circuits) mistakes; $2^{\Omega(\ell/\log\ell)}$ | proved; computed c6; construction known (slides) | Thm 3.11 |
| X33 | `notes.md`: "super-polynomial Occam OOD lower bound is open" | refuted (withdrawn) | Thm 3.11 |
| X34 | Majority 2.5/3.5 vs Occam 7/15 on the ladder ($d=3,4$) | computed c6 | Rem 3.12 |
| X35 | Uniform tie-breaking on the ladder: $\le d+d^2\ln2$ Gibbs, $\le\frac32(d-1)+1$ majority mistakes | proved | Rem 3.13 |
| X36 | NN Bayes is function-space Bayes with $P_A$ | proved | Prop 4.1 |
| X37 | $P_A(f)\le2^{-K(f\mid a)+c}$ | proved | Prop 4.2 |
| X38 | Every prior nearly saturates it on its typical set | proved; known (standard) | Prop 4.3 |
| X39 | No general lower bound on $P_A$ | proved | Prop 4.4 |
| X40 | Uniform fixed-size circuit prior contains the simplicity prior | proved | Prop 4.5 |
| X41 | NN Bayes: "mistakes ⇒ small circuit"; main strong-prior theorem; equivalence $\kappa_N\leftrightarrow C_L$; mean field | claimed in the slides | §4.3, §4.5 |
| X42 | Walsh diagonalisation; dimension lower bound | proved; known | Thm 4.6 |
| X43 | Kernel vs SFI separation on parities | proved; computed c2 | Cor 4.7 |
| X44 | Bias-free two-layer ReLU kernels: odd eigenvalues $\ge3$ vanish | proved; computed c2; known (Basri et al.) | Rem 4.8(a) |
| X45 | GP-classification prior gives odd parities mass 0 | proved; computed c10 | Rem 4.8(b) |
| X46 | Slides' warm-up and relevance-based bound | known (slides); proofs and arithmetic re-checked, computed c8 | §4.5 |
| X47 | Order-independent predictors = weak function semimeasures; normalised ones = random total functions | proved | Prop 5.1 |
| X48 | `notes.md`: "order independence characterises Bayesian random-(partial)-function predictors"; its Cor 5.2 | refuted (two-point counterexample; foundations Thm 3.5) | §5.1 |
| X49 | $M_F$ universal among lsc normalised order-independent predictors (finite $Y$) | proved (from foundations) | Cor 5.2(c) |
| X50 | Query order is worthless for log loss; small loss ≠ efficient identification | proved | Prop 5.3 |
| X51 | Single-query $M_F=2^{-K(y\mid x)\pm O(1)}$; $W$ falls short by an unbounded factor | proved | Prop 5.4 |
| X52 | Positive-example induction as a sampling likelihood | proof sketch | Rem 5.5 |
| X53 | $M_{\rm prod}$ is Solomonoff's operator induction | known (unverified match) | §6 |

---

## Verification log

**Scripts.** All in `checks/`, run with `python3 <script>` from that folder (Python 3.11.15, numpy 2.4.6, scipy 1.17.1). Each saves `<script>_output.txt` next to itself.

| script | seed | what it checks | result | time |
|---|---|---|---|---|
| `c1_formula_bayes_d3.py` | 0 (orderings only) | Thm 3.5 inequalities for the formula prior, $d=3$, all 256 functions and all orderings (DP over subsets); order independence; worst-case Occam and majority mistakes | all inequalities hold; order-independence error $1.8\cdot10^{-14}$; max $L/m_{\min}=4.92$ vs 51.5 | 4 s |
| `c2_kernel_parity.py` | 1 | Thm 4.6(a) for four kernels; odd-degree zero eigenvalues of two-layer ReLU NNGP/NTK; Thm 4.6(b) per cell (20 sampled targets, tolerance 0.05); Cor 4.7 | as reported in §4.4 | 15 s |
| `c3_order_and_learning_curves.py` | 2 | Prop 5.1 (720 orders); Prop 2.9 Monte Carlo; Remark 2.11 curves | as reported | 3 s |
| `c4_ood_prefix_separation.py` | 3 | Prop 2.12: separating-prefix complexity, exact probabilities, $\log^2m$ scaling | matches | 1 s |
| `c5_time_bounded_mixture.py` | 4 | Thm 3.1(b) bookkeeping vs brute force; regret vs the proved constant | max difference $2.5\cdot10^{-16}$; 132.4 ≤ 184 bits | 1 s |
| `c6_occam_ladder.py` (new) | none (deterministic) | Lemma 3.11a exhaustively ($d\le4$); Theorem 3.11 for formulas ($d=3,4,5$) and circuits ($d=3,4,5$, own DAG enumeration; function counts at $d-1$ gates cross-checked against the referee's r2); description lengths; Remark 3.12 (formula prior by zeta/Möbius/Walsh transforms, cross-checked at $d=3$; worst orderings by DP over subsets) | lemma holds; Occam 7, 15, 31 (formulas) and 4, 11, 26 (circuits); majority 2.5/3.5 on the ladder, worst 5.5/8.5 ≤ halving 10.83/15.30; transform vs direct $1.35\cdot10^{-13}$ | 7 s |
| `c7_converse_exchangeability.py` (new) | 7 | Prop 2.10 and the disjointness step of Prop 2.16 on all 31 subsets; $e^{\rm wr}\le e_{\rm norm}$, $e^{\rm wr}\le e_{\rm LOO}$; Cor 2.17(b) identity and bound, and Cor 2.17(a) in the form $\min_\varepsilon[\varepsilon+\nu(\emptyset)e^{-\varepsilon m}/\nu(f)]$, exactly for $m\in\{1,2,4,6\}$ and three input laws, on a mixture with deterministic, partial, product and shared-randomness hypotheses | all hold; identity error $\le3.2\cdot10^{-15}$ | 138 s |
| `c8_constants.py` (new) | none | Thm 3.5 explicit constant on a grid ($m\in[10^{-3},10^5]$, $d\in[1,10^4]$) and at small $m$; slides' warm-up tail and union-bound arithmetic; Appendix A at $n=4000(\ln M+4)$ | max ratio 10.85 < 16; referee's form fails for $m\ll1/d$ (66.7 at $m=10^{-6}$, $d=10^4$); slides' arithmetic holds | 10 s |
| `c9_time_bounded_clocks.py` (new) | 9 | Thm 3.1(a) with comparators that run faster than their worst case (m1); Prop 3.2a; length- vs round-clocked mixtures on repeated short inputs with noisy labels (m2) | both bounds hold at every prefix on distinct inputs (min slack 0.10 and 0.00 bits); on repeated inputs length-clocked regret 469.1 bits, round-clocked 10.0 ≤ 20 | 1 s |
| `c10_gp_odd_parity.py` (new) | 10 | Remark 4.8(b): variance of $\langle z,\chi_S\rangle$ and 2000 GP samples, $d=8$, four kernels | odd $\vert S\vert\in\{3,5\}$: variance $\le4.4\cdot10^{-18}$ for bias-free two-layer kernels; nonzero with bias or three layers | 12 s |

* c1–c5 were rerun on scratch copies for this revision; all five outputs are byte-identical to the saved ones.
* c6–c10 are new and independent of the referee's scripts in `referee_code/`. I read the referee's outputs but did not use them for any claim. Where both exist they agree. In particular the referee's r2 counts of circuit functions with at most $d-1$ gates (152 for $d=3$, 3000 for $d=4$) are reproduced by c6's own DAG enumeration; they happen to equal the formula counts with at most $d$ leaves. The Occam mistake counts on the ladder agree (formulas 7, 15, 31; circuits 4, 11).
* Corrections made while writing the checks: c9 first took `min` over a generator of length $10^9$ (it hung; replaced by `next`) and underflowed in the mixture loss (replaced by log-sum-exp); c8 first showed the small-$m$ regime at $m=10^{-3}$, where the referee's form is not yet violated, and now uses $m\le10^{-6}$.

**Proofs.** Every proof was re-read after the revision for quantifier order and constants. Points checked specifically:
* Prop 2.1: concatenation of self-delimiting codes, injectivity, $D$-consistency from $\operatorname{dom}D\cap Q=\emptyset$; the function machine $T_{Q,b}$.
* Prop 2.3: the wrapper reads $p$ before $z$, so $z$ is a conditional program and the set $\{wpz\}$ is prefix-free.
* Prop 2.16: disjointness of the one-point-flip sets across $x$; lower semicomputability of $\mu_f$ uniformly in the finite object $f$; $\sum_y\nu(f|_A+(x^*,y))\ge\nu(f)$; the triangle inequality $K(a\mid b)\le K(a\mid c)+K(c\mid b)+O(1)$ for part (3).
* Cor 2.17(a): Fubini over hypotheses and samples; a fixed hypothesis survives $m$ independent inputs with probability $(1-\varepsilon_h)^m$; the posterior denominator is at least $2^{-K(f)-c}$ deterministically. (b): exchangeability and the identification $e(x^*)=e_{\rm LOO}(x^*;S)$ for values that occur once.
* Cor 2.17(a), a correction made while writing: a first draft of Remark 2.18 said that the heavy length tail of a prefix-free prior (programs longer than $L$ have weight at least of order $1/\log L$) blocks the relevance-based argument for $W$. That was wrong, because the tail enters only multiplied by $e^{-\varepsilon m}$; the Markov form (a) was proved instead and the claim was dropped.
* Thm 3.1(a): both cases for short inputs. Prop 3.2a: the round threshold $J_A$. Prop 3.2c: the recursion $r_k\ge\min(k,r_{k-1}+2)$ and that a caught-up replay stays caught up.
* Thm 3.5: the chain $R(K)\le13a+4a\log(2d+4+K)$, the factorisation $2d+4+16a\Lambda\le2(d+2)(1+8m)(1+X)(1+Y)$, and the two cases $m\le1$, $m\ge1$.
* Lemma 3.11a and Theorem 3.11: Möbius inversion over GF(2); essential variables from the ANF; the slot count for circuits ($t-1$ gate references among $2t$ slots); $k=1$ excluded for circuits.
* Remark 3.13: the variable-permutation bijection; the harmonic-sum bound.
* Remark 4.8: the evenness of $\kappa(\rho)-a\rho$ (the referee's cleaner proof, adopted).
* Prop 5.1(b), Cor 5.2(c): Kolmogorov extension; the induction that makes a lower-semicomputable random-total-function law with finite $Y$ computable.
* The referee checked §§1–4 of `notes.md` line by line and found no wrong inequality or constant apart from the items in §0.1. That is the only external check; the new material (Prop 2.16, Cor 2.17, Props 3.2a–c, Cor 3.2b, the explicit constant in Thm 3.5, Theorem 3.11 for circuits, Remarks 3.13 and 4.8(b), Cor 5.2(c)) has had no external referee.

**Literature.** Every reference is marked known (snippet), known (unverified) or claimed in the slides.
* Searches made for this revision (snippet level): Basri et al. 2019 (confirmed, with the abstract's odd-frequency statement); Bietti & Mairal 2019 (bibliography confirmed, odd-eigenvalue statement **not** confirmed); Leike & Hutter 2015 (confirmed); Haussler, Littlestone & Warmuth 1994 (bibliography confirmed); Kamath, Montasser & Srebro 2020 (confirmed, PMLR 125:2236–2262); Filan, Leike & Hutter 2016 (confirmed); Goldblum et al. 2024 (page range PMLR 235:15788–15808 now confirmed); Donhauser, Wu & Yang 2021 (confirmed, PMLR 139:2804–2814); Schmidhuber 2002 (confirmed, pages from a mailing-list announcement); Buzaglo et al. 2024 (confirmed, PMLR 235:5035–5081).
* The other references carry over from `notes.md` with their earlier status.
* The most important unverified items: the exact form of Solomonoff's operator induction (§6, item 1), and everything in the slides beyond the warm-up, Appendix A, Appendix J's character argument and Appendix K.

**Not done.**
* The slides' main theorem, equivalence theorem, mistake bounds and mean-field claim were not checked.
* No experiments on real networks.
* Hutter's book section on supervised learning and the full text of Solomonoff (2008) were not read (not reachable).
* Machine-model details of the running-time claims.
* `notes.md` is kept unchanged for the record.
