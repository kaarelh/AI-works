# Track "steeper": steeper simplicity in Solomonoff function induction

*Brief item H9: the teacher's-mistakes trick and the model-vs-randomness split.*

* **Sources.**
  * Hänni's note `prior/hanni-grokking-a-notion.md`, especially its "messy notes". These are read as the content of the LessWrong comment named in the request; that comment could not be fetched.
  * The earlier formalisation `../../inferential-learning/research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md` ("T5") and its scripts in `T5-checks/`. Every T5 result used here is re-derived below; its numbers are recomputed by this track's own scripts. Section 6 lists what is reused, what is corrected and what is new.
* **Scripts.** `checks/c1`–`c5`, seeded, with outputs saved next to them as `.out` files.
* **Coordination.** The definitions in §1 are aligned with the foundations track (`../foundations/notes.md`, "F" below):
  * shared hypotheses are F's *weak function semimeasures* (F Def 2.1); F's machine laws (F Def 2.5) are a subclass;
  * product hypotheses are F's product laws (F Prop 3.3(a));
  * the product-class mixture $\xi_\times$ here is F's $M_{\rm prod}$, and SFI's own predictor is F's $M_F$ (F Def 5.1).

  As F asks, this track works with $M_{\rm prod}$-type hypotheses (private randomness), for the structural reason given in §1.6. Section 1.2 says exactly which property each result uses.

**Status tags.**
* **[proved]**: full proof here.
* **[computed: cN]**: checked by script `checks/cN`; the output is in `checks/cN*.out`.
* **[known: ref]**: standard or published result. "(verified)" means the bibliographic data were confirmed by web search. "(content unverified)" means the statement could not be checked against the paper, because only search snippets were available (arxiv.org, cwi.nl and similar hosts do not resolve here).
* **[proof sketch]**, **[conjecture]**, **[refuted]**: as named.

All logarithms are base 2 unless written ln.

---

## 0. Summary

Hänni's proposal, in his words: penalise "the length of the program plus the negative log likelihood ... but with a higher coefficient on the length of the program", in *function* induction where "each input gets its own private randomness". The hope is that the selected hypothesis is "simple model + noise" rather than "model + memorised errors". In sequence induction "a universal hypothesis absorbs everything".

1. **Why private randomness is the difference (§1).**
   * *Absorption in shared classes* (Thm 1) [proved]. Take any hypothesis class that contains its own universal mixture $U$ as a single member of length $\ell_U$. This covers Solomonoff induction (SI), and SFI with shared randomness across inputs. For every $\lambda>1$ and every data set:
     * every λ-MAP has length at most $(\lambda\ell_U+c_0)/(\lambda-1)$, a bound that does not depend on the data;
     * the λ-MAP's log-loss on the data is at most $\lambda\ell_U$ bits worse than $U$'s;
     * the steeper-prior Bayes predictor's code length is within $\lambda\ell_U+O(1)$ bits of $U$'s.
     
     So for fixed λ and a deterministic teacher, errors included, the selected hypothesis and the steeper posterior both reproduce all but finitely many of the teacher's labels. Let $d'$ be the length of the shortest program for "simple model + noise"; for a parity model $d'\ge d-O(\log d)$. Once $d'>\ell_U$ and $\lambda>(d'+c_0)/(d'-\ell_U)$, no hypothesis of length $\ge d'$ is ever selected, so "simple model + noise" is never selected.
   * *Private randomness has no universal element* (Prop 1.3, Cor 1.4) [proved; re-derived from T5]. Every product hypothesis pays a mixture's $\log(1/w)$ at every input. For every product hypothesis $\nu_U$ there are parities on which it loses $2^d-1$ bits while the parity itself costs $d+O(\log d)$.
   * At λ = 1 the two decompositions give the same Bayes predictor. Steeper simplicity acts on *single hypotheses*, so its effect depends on what counts as one hypothesis. SFI's natural class, the x-only computable predictors against which its dominance theorem is stated, consists of product hypotheses.
   * So steeper SFI must be *defined* over product hypotheses (the foundations track's $M_{\rm prod}$-type hypotheses). Over all machine laws, $M_F$ is itself a short member and absorbs (§1.6).
2. **The teacher's-mistakes trick (§2).**
   * *Hänni's numbers* [computed: c1]:
     * his first version gives the window λ ∈ (10, 100) in total-bit units;
     * his second version gives $c=\lambda/N\in(1.12\cdot10^{-6},\,8.99\cdot10^{-3})$.
     
     His "≈ p log(1/p) ≈ 1/100": $p\log(1/p)=0.0098$ is 13% below the exact $H(2^{-10})=0.0112$. This is immaterial.
   * *A rigorous instance with his numbers* (Thm 2) [proved].
     * The simple model is a random parity on $\{0,1\}^{100}$, so $d=100$ bits.
     * The systematic error is a random error rule on the first $m=20$ input bits with density $p=2^{-10}$, of complexity $L_S=11{,}710$ bits ("10000 bits").
     * The theorem quantifies over **all** hypotheses with private randomness. For $c=\lambda/N$ in an explicit window $(2^{-m},c_{\rm hi}]$ it shows four things. With machine constants set to 0, the window is $(9.5\cdot10^{-7},\,8.1\cdot10^{-3}]$ [computed: c3].
       * The good model is optimal up to an explicit slack.
       * Every near-optimal hypothesis knows the parity.
       * Every near-optimal hypothesis holds at most a few dozen bits of information about the error rule, out of 11,710 (machine constants set to 0; about 100 bits with κ = 30).
       * On error inputs, every near-optimal hypothesis gives the teacher's erroneous label average probability at most ≈ 0.20–0.27 (κ = 0). The bound falls to ≈ 0.065 for $m=24$. The memoriser gives 1 and the good model gives $2^{-10}$.
     * The lower end $2^{-m}$ of the window is sharp to a factor $1+O((m+\log d)/L_S)$.
     * Below it, every near-optimal hypothesis reproduces the errors (the memoriser regime).
     * With $m=d$ (idiosyncratic errors on a finite domain, full truth table) the window is $\lambda\in(1,\,1.2\cdot10^4]$ at $d=20$. At λ = 1 the good model and the memoriser tie to $O(\log n)$.
     * A finite-sample corollary (Lemma 2.6) holds for N i.i.d. samples. It needs $N\approx10^{11}$ for useful constants at Hänni's sizes.
     * The power posterior with $\lambda=cN$ concentrates exponentially in $N$ on the near-optimal set (Prop 2.8).
   * *Plain Bayes and SI learn the errors* (Prop 2.9) [proved].
     * SFI at λ = 1 errs on at most $d+L_S+O(\log)$ inputs in total, while the number of error inputs grows like $pN$.
     * The λ-MAP for any fixed λ eventually reproduces the errors.
     * SI on the interleaved sequence has expected total label loss at most $K(\mu)+O(1)$.
   * *Limits.*
     * (a) A fixed λ does not work: systematic errors are eventually learned, so λ must grow like $N$ (Prop 2.9(b)).
     * (b) Rate blindness (Props 2.11–2.12). Errors are removed only when their rate is below the model's. With machine constants set to 0, a 3-bit error rule on 1/8 of the inputs, or a 6-bit one on 1/64 at $d\ge1000$, defeats the trick for every λ. This is proved over all hypotheses.
     * (c) Guard erosion (Prop 2.13).
     * (d) Every strictly proper score prefers the teacher's own channel, errors included. So λ cannot be chosen from imitation data (Prop 2.14).
     * (e) Universality returns when inputs contain labelled history (Prop 4.1).
     * (f) The proof method needs $p<0.056$.
3. **The model-vs-randomness split (§3).** Take a sampler ν of length $k$, and let "fill-ins" be the deterministic programs that reproduce the sampled labels.
   * *λ = 1* (Thm 3, Prop 3.3) [proved]. In SFI and in SI, the posterior odds of the fill-ins against the sampler program lie in $[2^{-O(\log N)},\,2^{k+m^*}]$, whatever the amount $NH$ of sampled randomness. Here $m^*$ is a Ville deficiency with $\Pr[m^*\ge m]\le2^{-m}$. This is Hänni's "both get similar posterior", made precise.
   * *λ > 1, SFI with private randomness* (Thm 4) [proved].
     * For every λ > 1, uniformly in $N$, every λ-MAP has length at most $(\lambda k+m^*)/(\lambda-1)$.
     * The fill-ins' posterior is at most $2^{\lambda k+\lambda m^*-(\lambda-1)(-\log\nu(D_N))}$, which decays exponentially in the sampled entropy.
     * Almost surely the MAP is eventually equivalent to ν, and the power posterior concentrates on ν-equivalent hypotheses.
     * All this holds for any (even adaptive) input sequence.
   * *λ > 1, SI or shared randomness* (Thm 5) [proved].
     * The universal mixture beats every sampler with $(\lambda-1)k>\lambda\ell_U+c_0$.
     * The posterior puts at most $2^{-(\lambda-1)L+\lambda\ell_U+O(1)}$ on all hypotheses of length ≥ L.
     * So no split is made.
   * *Algorithmic statistics* (§3.5) [proved, except where tagged].
     * Steeper two-part codes over finite-set models select near-minimal sufficient statistics.
     * The product-model analogue selects near-minimal *product*-sufficient statistics.
     * The two can differ by ≈ d bits. For a noisy random parity, set sophistication is $O(\log d)$: the parity's parameter is treated as noise. Product sophistication is $d\pm O(\log n)$ (Prop 3.8).
     * The product notions are new as far as I could check.
4. **Other results (§4).**
   * At a fixed λ > 1, SFI with private randomness identifies a computable product teacher exactly and never memorises its noise. SI does not.
   * Tempering the likelihood leaves deterministic hypotheses unchanged. So in SI's deterministic-program representation neither tempering nor a power prior can split model from randomness.
   * History-aware hypotheses keep per-input pricing iff their randomness is private and their inputs carry no labels.
   * Open problems are listed in §4.5.

---

## 1. Setup

### 1.1 Data and hypotheses

* $X$ is a decidable set of finite binary strings; in the examples $X=\{0,1\}^d$. $Y$ is a finite label set; in the examples $Y=\{0,1\}$.
* A **data set** is a finite partial function $D:X\rightharpoonup Y$, with domain $\mathrm{dom}\,D=\{x_1,\dots,x_N\}$ (distinct) and $y_i=D(x_i)$.
  * In SFI the target is a function, or a random function sampled once. A repeated input therefore carries no new label, and all data sets here are partial functions.
  * The other case, fresh noise on repeated queries, makes plain SFI's loss infinite with positive probability (F Prop 6.8).

**Definition 1.1 (product hypothesis: private randomness).** A *product hypothesis* is a lower-semicomputable conditional semimeasure $\nu(y\mid x)$: $\nu\ge0$, $\sum_y\nu(y\mid x)\le1$, and $\{(x,y,q):q<\nu(y\mid x)\}$ is c.e.
* It describes a random partial function $F$ whose values $F(x)\sim\nu(\cdot\mid x)$ are independent across distinct $x$, with $F(x)$ undefined with probability $1-\sum_y\nu(y\mid x)$. Operationally, it is a machine that on input $x$ uses fresh coins of its own.
* Its likelihood is $\nu(D):=\prod_{x\in\mathrm{dom}D}\nu(D(x)\mid x)$.
* Its prediction at a new input $x$ is $\nu(\cdot\mid x)$, which does not depend on $D$.
* It is *deterministic* if every $\nu(\cdot\mid x)$ is a point mass or zero, i.e. a partial computable function $f$. Then $\nu(D)=1$ if $f\supseteq D$, and $0$ otherwise.

**Definition 1.2 (shared hypothesis: shared randomness).** A *shared hypothesis* is a lower-semicomputable map $P$ from data sets to $[0,1]$ with $P(\emptyset)\le1$ and $\sum_yP(D\cup\{(x,y)\})\le P(D)$ for $x\notin\mathrm{dom}D$. These are the one-point ("weak") semimeasure inequalities.
* Its prediction is $P(y\mid x,D):=P(D\cup\{(x,y)\})/P(D)$.
* Examples:
  * containment functionals $P(D)=\Pr[F\supseteq D]$ of random partial functions generated by a monotone function machine reading **one** random tape for all inputs (brief H1(a));
  * Bayes mixtures $\sum_iw_iP_i$;
  * every product hypothesis, $\nu(D)$.
* The hypotheses of SI, semimeasures on strings over an interleaved encoding of $x_1y_1x_2y_2\dots$, are shared in the same sense.
* By telescoping, $P(D_N)=P(\emptyset)\prod_{i\le N}P(y_i\mid x_i,D_{i-1})$. So a shared hypothesis's cumulative sequential log-loss is $-\log P(D_N)+\log P(\emptyset)\le-\log P(D_N)$ in every reveal order.

Def 1.2 is F's weak function semimeasure (F Def 2.1). Machine laws (F Def 2.5) and product laws are special cases (F Prop 3.3).

What each result needs: Theorem 1 needs only the one-point inequalities and a dominance property (Dom), stated there. Both the machine-law class and the weak class satisfy (Dom):
* machine laws, with $U=M_F$ (F Thm 3.2);
* weak semimeasures, with $U=M^w$ (F Thm 3.4).

§2–3 use only product hypotheses.

### 1.2 Hypothesis classes and description length

**Definition 1.3.** A *hypothesis class* is:
* a c.e. prefix-free set $\Pi\subset\{0,1\}^*$ of *programs*;
* a uniformly lower-semicomputable family $(P_\pi)_{\pi\in\Pi}$ of shared hypotheses.

Its *product class* is the special case $P_\pi=\nu_\pi^{\otimes}$. Write $\ell(\pi):=|\pi|$.
* The class is *universal* for a family $\mathcal F$ of hypotheses if every member of $\mathcal F$ equals some $P_\pi$ with $|\pi|\le K(\cdot)+\kappa$.
* $\Pi_\times$ denotes a class universal for product hypotheses, including all total computable deterministic ones.
* Hypotheses are programs. Two programs for the same semimeasure are different hypotheses with separate prior weights.

**Standing facts** [known: Li–Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed. 2008, Ch. 3–4]. Here $\kappa$ denotes a constant that depends only on the reference machine and on the fixed programs built in the proofs. It never depends on $d,m,p,N$, the data or the hypotheses, and different occurrences may differ.
* (F1) $K(\pi)\le|\pi|+\kappa$ for $\pi\in\Pi$. *Proof:* read input bits until the string read so far is enumerated in $\Pi$, then output it. This is a prefix machine because $\Pi$ is prefix-free.
* (F2) *Conditional coding theorem* (Levin). If a fixed program lower-semicomputes, from $z$, a semimeasure $Q_z$ on a countable set, then $K(w\mid z)\le-\log Q_z(w)+\kappa$.
* (F3) $K(x)\le K(y)+K(x\mid y)+\kappa$ and $K(x,y\mid z)\le K(x\mid z)+K(y\mid x,z)+\kappa$.
* (F4) *Symmetry of information* (Gács; Levin): $K(x,y)=K(x)+K(y\mid x,K(x))+O(1)$.
* (F5) $K(n)\le2\log(n+1)+\kappa$, by a doubling code.

### 1.3 Objectives

For a data set $D$, a class and $\lambda\ge1$:
* **two-part (MAP) objective**: $J_\lambda(\pi;D):=\lambda\ell(\pi)-\log P_\pi(D)\in[0,\infty]$. A minimiser is a *λ-MAP*.
* **power-prior posterior**: $\Pi_\lambda(\pi\mid D):=2^{-\lambda\ell(\pi)}P_\pi(D)/\xi_\lambda(D)$, with $\xi_\lambda(D):=\sum_\pi2^{-\lambda\ell(\pi)}P_\pi(D)$. This is Bayes with the prior $2^{-\lambda\ell}$, whose Kraft sum is at most 1. Its predictor is the shared hypothesis $\xi_\lambda$.
* **tempered (fractional) posterior**: $\Pi^\eta(\pi\mid D)\propto2^{-\ell(\pi)}P_\pi(D)^\eta$ with $\eta\in(0,1]$.

These are Hänni's two descriptions ("a higher coefficient on the length of the program"; "penalize the likelihood term less"). In the literature they appear as generalised, Gibbs, fractional or "safe" posteriors with learning rate $\eta=1/\lambda$:
* Bissiri, Holmes & Walker 2016, *JRSS-B* 78(5):1103–1130;
* Bhattacharya, Pati & Yang 2019, *Ann. Statist.* 47(1):39–66;
* Grünwald 2012, ALT, LNCS 7568:169–183;
* Grünwald & van Ommen 2017, *Bayesian Analysis* 12(4):1069–1103;
* Zhang 2006, *Ann. Statist.* 34(5):2180–2210;
* Barron & Cover 1991, *IEEE Trans. IT* 37(4):1034–1054.

[known (verified); content unverified]. Whether and where Barron–Cover use a multiplier > 1 on the code length could not be checked.

**Lemma 1.1 [proved].**
* (i) If some $J_\lambda(\pi;D)<\infty$, the set of λ-MAPs is finite and nonempty.
* (ii) $\arg\min_\pi J_\lambda=\arg\max_\pi\Pi_\lambda(\pi\mid D)=\arg\max_\pi\Pi^{1/\lambda}(\pi\mid D)$.
* (iii) For deterministic hypotheses $P_\pi(D)^\eta=P_\pi(D)\in\{0,1\}$. So on any set of deterministic hypotheses the tempered posterior's relative weights equal those of the plain (λ = 1) posterior.

*Proof.*
* (i) $J_\lambda\ge\lambda\ell$, and by Kraft only finitely many programs have $\ell\le L$.
* (ii) $2^{-J_\lambda}=2^{-\lambda\ell}P=(2^{-\ell}P^{1/\lambda})^\lambda$, and $t\mapsto t^\lambda$ is increasing.
* (iii) is immediate. ∎

*Per-sample form.* With $N=|\mathrm{dom}D|$ and $c:=\lambda/N$, the objective is $\hat J_c:=J_\lambda/N=c\,\ell+\frac1N\sum_i-\log\nu(y_i\mid x_i)$ for product hypotheses. Hänni's "increase the hypothesis coefficient as the data set grows" is $c$ fixed, $\lambda=cN$. For a distribution on inputs and a fixed teacher, the population version is $J_c(\pi):=c\,\ell(\pi)+R(\pi)$ with $R(\pi):=\mathbb E_x[-\log\nu_\pi(y^*(x)\mid x)]$, and $\Phi(c):=\inf_\pi J_c(\pi)$.

**Lemma 1.2 (hull; T5 Lemma 3.1, re-derived) [proved; computed: c5(a)].** Let $A=\{(\ell(\pi),R(\pi))\}$, with finitely many points below each $\ell$-level and $R\ge0$.
* (i) For $c>0$, every minimiser of $c\ell+R$ lies on the lower convex boundary of $A$ at a supporting line of slope $-c$.
* (ii) If $c<c'$ and $h,h'$ minimise $J_c,J_{c'}$, then $\ell(h)\ge\ell(h')$ and $R(h)\le R(h')$.
* (iii) A point is the unique minimising point for all $c$ in an open interval iff it is a vertex of the lower hull with finite negative slopes. A hypothesis is the unique minimiser there iff, in addition, no other hypothesis has the same point.
* (iv) (Hänni's "absolute bound on model complexity" variant.) Every minimiser $h_c$ of $c\ell+R$ solves $\min\{R(h):\ell(h)\le\ell(h_c)\}$. A solution of a constrained problem minimises some penalised objective iff its point lies on the lower hull.

*Proof.*
* (i) and (iii): $c\ell+R=\langle(c,1),\cdot\rangle$, minimised over $\mathrm{conv}(A+\mathbb R^2_{\ge0})$. A vertex has an open cone of strictly supporting normals; a non-vertex boundary point is a convex combination of two vertices, both in $A$.
* (ii) Add $c\ell(h)+R(h)\le c\ell(h')+R(h')$ and $c'\ell(h')+R(h')\le c'\ell(h)+R(h)$. This gives $(c'-c)(\ell(h')-\ell(h))\le0$; then use the first inequality.
* (iv) If $\ell(h)\le\ell(h_c)$, then $R(h)\ge R(h_c)+c(\ell(h_c)-\ell(h))\ge R(h_c)$. The converse is the definition of a supporting line. ∎

So Hänni's two proposals, the penalty and the absolute bound, select the same hypotheses on the hull's vertices. The penalty cannot reach points above the hull.

### 1.4 Shared randomness: a universal hypothesis absorbs everything

**(Dom)** The class contains a program $\pi_U$, with $U:=P_{\pi_U}$ and $\ell_U:=\ell(\pi_U)$, such that $P_\pi(D)\le2^{\ell(\pi)+c_0}U(D)$ for all $\pi$ and $D$.

*Examples.*
* (1) **SFI with shared randomness**: monotone function machines reading one random tape. Let $V(\pi\omega)$ run machine $\pi$ on tape $\omega$. Then $P_V(D)=\sum_\pi2^{-|\pi|}P_\pi(D)$ over a prefix-free c.e. set of machine codes, and $V$ is itself a machine of the class with a code $\pi_U$ of length $O(1)$. So (Dom) holds with $c_0=0$, and $\xi_1=P_V=U$.
* (2) **SI**: Solomonoff's monotone-machine $M$, by the same argument.
* (3) Any class that contains the Bayes mixture of its own members as a member.

**Theorem 1 (absorption) [proved].** Assume (Dom), and let $\lambda>1$.
* **(a) MAP.** For every data set $D$, every λ-MAP $\hat\pi$ satisfies
  $$\ell(\hat\pi)\le L_\lambda:=\frac{\lambda\ell_U+c_0}{\lambda-1},\qquad -\log P_{\hat\pi}(D)\le-\log U(D)+\lambda\ell_U-\lambda\ell(\hat\pi).$$
  In particular, if $d>\ell_U$ and $\lambda>(d+c_0)/(d-\ell_U)$, then no hypothesis of length $\ge d$ is a λ-MAP for any data set. This holds for fixed λ and for $\lambda=cN$ once $cN$ exceeds this bound.
* **(b) Power posterior.** $2^{-\lambda\ell_U}U(D)\le\xi_\lambda(D)\le\xi_1(D)$. If $\xi_1\le2^{c_1}U$ ($c_1=0$ in Examples 1–2; $c_1=O(1)$ whenever the class is universal for lower-semicomputable shared hypotheses), the code lengths $-\log\xi_\lambda(D)$ and $-\log U(D)$ differ by at most $\lambda\ell_U+c_1$ bits on every data set. By telescoping (§1.1) the sequential log-losses equal these code lengths up to the constants $\log\xi_\lambda(\emptyset)$ and $\log U(\emptyset)$.
* **(c) Deterministic teacher (errors included).** Let $t:X\to Y$ be total computable, $\pi_t$ a program for it and $\ell_t:=\ell(\pi_t)$. Let $x_1,x_2,\dots$ be distinct and $D_N:=\{(x_i,t(x_i))\}_{i\le N}$.
  * (c1) $\sum_{i\le N}-\log\xi_\lambda(t(x_i)\mid x_i,D_{i-1})\le\min\{\lambda\ell_t,\ \lambda\ell_U+c_0+\ell_t\}$. So at most that many inputs, over the whole sequence, receive probability below 1/2 for the teacher's label.
  * (c2) Every λ-MAP for $D_N$ has $-\log P_{\hat\pi}(D_N)\le\lambda\ell_U+c_0+\ell_t$.
  * (c3) There are $N_0$ and a finite set $\Pi_{\rm fin}$ of programs such that every λ-MAP lies in $\Pi_{\rm fin}$ for all $N\ge N_0$. Moreover, at only finitely many $N\ge N_0$ does a λ-MAP $\hat\pi_N$ give the next label $t(x_{N+1})$ probability below 1/2.
* **(d) SI with random inputs.** Encode $(x_1,y_1,x_2,\dots)$ as a binary string with fixed-length blocks. Let the $x_i$ be i.i.d. from a computable law, $y_i=t(x_i)$, and let μ be the resulting computable measure on strings, with a program $\pi_\mu$ in the class. Then
  $$\mathbb E_\mu\sum_{i\le N}-\log\xi_\lambda(y_i\mid x_1y_1\dots x_i)\le\lambda\ell_U+c_0+\ell(\pi_\mu).$$

*Proof.*
* (a)
  * Since $\hat\pi$ is a MAP, $J_\lambda(\hat\pi)\le J_\lambda(\pi_U)=\lambda\ell_U-\log U(D)$; in particular $J_\lambda(\hat\pi)<\infty$ when $U(D)>0$.
  * By (Dom), $-\log U(D)\le\ell(\hat\pi)+c_0-\log P_{\hat\pi}(D)$.
  * Substituting gives $\lambda\ell(\hat\pi)\le\lambda\ell_U+c_0+\ell(\hat\pi)$, which is the length bound. The loss bound is $J_\lambda(\hat\pi)\le J_\lambda(\pi_U)$, rearranged.
  * Finally, $L_\lambda<d$ iff $\lambda(d-\ell_U)>d+c_0$.
* (b) The first inequality keeps one term of the sum. The second holds because $2^{-\lambda\ell}\le2^{-\ell}$. Losses telescope (§1.1).
* (c1) $\xi_\lambda(D_N)\ge2^{-\lambda\ell_t}P_{\pi_t}(D_N)=2^{-\lambda\ell_t}$. Also $\xi_\lambda(D_N)\ge2^{-\lambda\ell_U}U(D_N)\ge2^{-\lambda\ell_U-c_0-\ell_t}$ by (Dom). Then telescope; each label with probability below 1/2 adds more than one bit.
* (c2) This is (a) combined with $-\log U(D_N)\le\ell_t+c_0$.
* (c3)
  * Let $\Pi_\lambda:=\{\pi:\ell(\pi)\le L_\lambda\}$; it is finite and, by (a), contains every λ-MAP.
  * For $\pi\in\Pi_\lambda$ let $L_\pi(N):=-\log P_\pi(D_N)$. It is nondecreasing in $N$ by the one-point inequality, so it has a limit $L_\pi(\infty)\in[0,\infty]$.
  * Let $\Pi_{\rm fin}:=\{\pi\in\Pi_\lambda:L_\pi(\infty)<\infty\}$. It contains $\pi_U$, since $\ell_U\le L_\lambda$ and $L_U(\infty)\le\ell_t+c_0$.
  * For $\pi\in\Pi_\lambda\setminus\Pi_{\rm fin}$ we have $J_\lambda(\pi;D_N)\to\infty$, while $J_\lambda(\pi_U;D_N)\le\lambda\ell_U+\ell_t+c_0$ for every $N$. Finiteness gives $N_0$ beyond which no such $\pi$ is a MAP.
  * For $\pi\in\Pi_{\rm fin}$, $\sum_N[L_\pi(N+1)-L_\pi(N)]\le L_\pi(\infty)$, and each increment equals $-\log P_\pi(t(x_{N+1})\mid x_{N+1},D_N)$. So $\pi$ gives probability below 1/2 to the next label at most $L_\pi(\infty)$ times.
  * Summing over the finite set $\Pi_{\rm fin}$ bounds the number of such $N$ for MAPs.
* (d)
  * $\xi_\lambda\ge2^{-\lambda\ell_U}U\ge2^{-\lambda\ell_U-c_0-\ell(\pi_\mu)}\mu$, so $\mathbb E_\mu\log(\mu/\xi_\lambda)(\omega)\le\lambda\ell_U+c_0+\ell(\pi_\mu)$ for every prefix $\omega$.
  * Expand $\log(\mu/\xi_\lambda)$ by the chain rule over bit positions. At each position the conditional expectation is $\mathrm{KL}(\mu(\cdot\mid h)\,\|\,\xi_\lambda(\cdot\mid h))$, which is at least $-\log\sum_b\xi_\lambda(b\mid h)\ge0$ because $\xi_\lambda(\cdot\mid h)$ is a sub-probability.
  * At a label position $\mu(y_i\mid h)=1$, so the term equals $-\log\xi_\lambda(y_i\mid h)$.
  * Dropping the nonnegative input-position terms gives the claim. This is Solomonoff's bound restricted to the label positions [known: Solomonoff 1978, *IEEE Trans. IT* 24:422–432 (verified; exact constant there unverified)]. ∎

*Remarks.*
* (a) is the precise form of Hänni's "it'll be better to drop bits and take the likelihood loss" in the sequence case. It also reproduces T5 Prop 2.3's threshold $\ell_U+(\ell_U+c_0)/(\lambda-1)$. As $\lambda\to\infty$ the bound tends to $\ell_U$, not to 0, so hypotheses simpler than $U$ are not excluded. With $\lambda=cN$, (a) shows that every model longer than about $\ell_U$ is eventually excluded. Whether a given simple model is longer than $\ell_U$ depends on the reference machine. A 100-bit model may or may not be. A realistic concept, such as a dog classifier with millions of bits, certainly is.
* (c3) has no explicit bound. Explicit online bounds for discrete MDL are known to be exponentially worse than Bayes in general [known: Poland & Hutter 2005, *IEEE Trans. IT* 51(11):3780–3795 (verified; content per abstract)].

### 1.5 Private randomness: no hypothesis absorbs anything

**Proposition 1.3 (per-input pricing; T5 Thm 2.1 and Prop 2.2, re-derived) [proved; computed: c2(a)].** Let $F$ be a finite set of total functions $X\to Y$, $x_1,\dots,x_N$ distinct, and let $Q_x$ denote the law of $f(x)$ when $f\sim Q$.
* (i) For every product hypothesis ν and every distribution $Q$ on $F$:
  $$\max_{f\in F}\sum_i-\log\nu(f(x_i)\mid x_i)\ \ge\ \sum_iH(Q_{x_i}).$$
  The value $\inf_\nu\max_f\sum_i-\log\nu(f(x_i)\mid x_i)$ equals $\max_Q\sum_iH(Q_{x_i})$, which can be strictly below $\sum_i\log|F(x_i)|$. Example: $F=\{(a,a),(a,b),(b,a),(c,a)\}$ has value $2.5431<2.5850$ [computed: c2(a), both by maximising over $Q$ and by SLSQP over ν].
* (ii) Take $F$ = all parities on $\{0,1\}^d$ and nonzero inputs. Then $Q=$ uniform gives $H(Q_x)=1$, so every product hypothesis pays at least $N$ bits on some parity. The shared Bayes mixture over parities pays at most $d$ bits on every parity.
* (iii) A per-input mixture $\xi_{\rm fun}(y\mid x)=\sum_qw_qq(y\mid x)$ is again a product hypothesis. It pays up to $\log(1/w_q)$ at every input: with $\{\text{const }0,\text{const }1\}$ and $w=1/2$ it pays $N$ bits on $N$ ones, where the shared mixture pays 1.

*Proof.*
* (i) The bound:
  * $\max_f\ge\mathbb E_{f\sim Q}$.
  * For each $i$, $\mathbb E_{f\sim Q}[-\log\nu(f(x_i)\mid x_i)]=H(Q_{x_i})+\sum_yQ_{x_i}(y)\log\frac{Q_{x_i}(y)}{\nu(y\mid x_i)}$.
  * The last sum is at least $-\log\sum_y\nu(y\mid x_i)\ge0$ (Gibbs' inequality with a sub-probability).
* (i) The value:
  * Restrict ν to $\Delta_\varepsilon:=\{\nu:\nu(y\mid x_i)\ge\varepsilon\}$. This set is compact and convex, and the loss $L(\nu,Q)=\mathbb E_Q\sum_i-\log\nu(f(x_i)\mid x_i)$ is continuous on $\Delta_\varepsilon\times\Delta(F)$, convex in ν and linear in $Q$.
  * By Sion's minimax theorem [known: Sion 1958, *Pacific J. Math.* 8:171–176], $\min_{\Delta_\varepsilon}\max_Q=\max_Q\min_{\Delta_\varepsilon}$.
  * $\min_{\Delta_\varepsilon}L(\cdot,Q)$ lies between $\sum_iH(Q_{x_i})$ and $\sum_iH(Q_{x_i})-N\log(1-|Y|\varepsilon)$: use $\nu=(1-|Y|\varepsilon)Q_x+\varepsilon$. The error term is uniform in $Q$.
  * Let $\varepsilon\to0$; hypotheses outside every $\Delta_\varepsilon$ are covered by the inequality just proved.
* (ii) For $x\ne0$, exactly half of the parities give each label at $x$. The shared mixture gives $D$ probability at least $2^{-d}$.
* (iii) Every term of the per-input mixture assigns $1/2$ to the observed 1, at every input. ∎

**Corollary 1.4 (no universal product hypothesis) [proved].** For every product hypothesis $\nu_U$ and every constant $C$, there are a data set $D$ and a deterministic product hypothesis $f$ such that:
* $f\supseteq D$;
* $f$ has a program of length at most $d+2\log d+\kappa$;
* $\nu_U(D)\le2^{-(2^d-1)}$.

Choosing $d$ with $2^d-1-d-2\log d-\kappa>C$ gives $\nu_U(D)<2^{-C}2^{-\ell(\pi_f)}f(D)$. So (Dom) fails for every candidate $U$ in the product class.

*Proof.* Take $D$ to be the labels of a parity on all nonzero inputs of $\{0,1\}^d$, choosing the parity by Prop 1.3(ii). ∎

**Remark 1.5 (the universal conditional semimeasure is a fixed predictor; T5 Thm 2.4) [proved].** The universal lower-semicomputable conditional semimeasure $m(y\mid x)$ satisfies $m(y\mid x)\ge2^{-K(y\mid x)-\kappa}$.
* For $Y=\{0,1\}$ this gives $m(y\mid x)\ge2^{-\kappa'}$ for both labels, hence $m(y\mid x)\le1-2^{-\kappa'}$. So $m$ pays at least $\log\frac1{1-2^{-\kappa'}}>0$ bits for every label, on every data set.
* It dominates each product hypothesis input by input, $m\ge2^{-K(\nu)-\kappa}\nu$, but it pays the factor $2^{K(\nu)}$ at every input. It never learns.

**Lemma 1.6 (coding bound; holds in both classes) [proved].** For every product or shared hypothesis $\pi$ and every data set $D$:
$$\ell(\pi)-\log P_\pi(D)\ \ge\ K(y_D\mid\mathrm{dom}D)-\kappa,$$
where $y_D$ lists the labels in the canonical order of $\mathrm{dom}D$.

*Proof.*
* Given $\pi$ and the finite set $\mathrm{dom}D$, the map $y\mapsto P_\pi(\mathrm{dom}D\mapsto y)$ is a lower-semicomputable semimeasure on $Y^{\mathrm{dom}D}$. For product hypotheses this is $\prod_i\sum_{y_i}\nu(y_i\mid x_i)\le1$; for shared ones it follows from the one-point inequalities.
* (F2) gives $K(y_D\mid\pi,\mathrm{dom}D)\le-\log P_\pi(D)+\kappa$.
* (F3) and (F1) give $K(y_D\mid\mathrm{dom}D)\le\ell(\pi)+K(y_D\mid\pi,\mathrm{dom}D)+\kappa$. ∎

The coding bound is "one bit pays for at most one bit" and holds in both classes. What separates them is whether one member attains the bound up to a constant on *every* data set. $U$ does in a shared class (by (Dom)). Nothing does in the product class (Cor 1.4).

### 1.6 Why private randomness is what makes SFI different here

* **At λ = 1 nothing distinguishes the two decompositions.**
  * The Bayes mixture over the product class, $\xi_\times:=\sum_{\pi\in\Pi_\times}2^{-\ell(\pi)}\nu_\pi^{\otimes}$, is a *shared* hypothesis. It dominates every product hypothesis. It is the private-randomness version of the SFI predictor; F recommends the machine-law mixture $M_F$ as *the* SFI predictor (see below).
  * $\xi_\times$ is F's $M_{\rm prod}$. It agrees with $M_F$ up to $K(\mathrm{dom}D)+O(1)$ bits (F Thm 4.2), but not up to a constant: $M_F/M_{\rm prod}$ is unbounded (F Prop 4.5). Nothing here needs either fact.
  * The predictive distribution is the same object whichever way it is written as a mixture.
* **At λ > 1 the decomposition matters.** The steeper penalty acts on single hypotheses, so its effect depends on what counts as one hypothesis and on its length.
  * In SI, and in any class that contains its own mixture, the mixture is one short hypothesis and absorbs everything (Thm 1).
  * SFI's natural hypotheses are Hänni's "computably samplable predictors": x-only samplers that use separate randomness for each input. His dominance template (prior/hanni-sfi-notes.md) is stated against this class. These are exactly the product hypotheses (F Prop 3.3(a)). A product hypothesis is a fixed map $x\mapsto\nu(\cdot\mid x)$, so it cannot learn and it pays per input (Prop 1.3, Cor 1.4).
* This is Hänni's mechanism ("you have to pay the likelihood term separately at every x") in exact form.
* **Consequence for the definition of steeper SFI.** F recommends $M_F$, the law of the universal function machine, as *the* SFI predictor. $M_F$ is a mixture over machine laws, and machine laws use a shared tape. If steeper simplicity were applied to the class of all machine laws, $M_F$ would itself be a short member, and Theorem 1 would apply: absorption returns. So the steeper prior must be applied to the product sub-class (F's $M_{\rm prod}$-type hypotheses, "x-only samplers"). At λ = 1 nothing is lost: $M_{\rm prod}$ already dominates every product hypothesis. The choice of hypothesis class is part of the definition of steeper SFI, not a technicality.
* The protection depends on the granularity of inputs. If a hypothesis's input contains earlier *labelled* pairs, the in-context Bayes mixture is again a single member (Prop 4.1).

---

## 2. The teacher's-mistakes trick

### 2.1 Hänni's calculation [computed: c1]

* **Version 1** (total bits): a 100-bit simple model that "predicts 100 bits per specification bit" and a 100-bit error model that predicts 10 bits per bit.
  * The hull is coin → simple → simple+errors, with slopes 100 and 10.
  * "Simple" alone is selected exactly for λ ∈ (10, 100); λ = 1 selects simple+errors.
* **Version 2** (per sample): a 100-bit simple model, plus errors on a $2^{-10}$ fraction of inputs that "take 10000 bits to specify".
  * Rates: $(1-H(p))/110=8.989\cdot10^{-3}$ for the model and $H(p)/9990=1.1185\cdot10^{-6}$ for the errors, with 10 bits for the flip rate. Without those 10 bits the rates are $9.888\cdot10^{-3}$ and $1.1174\cdot10^{-6}$.
  * The good model is selected iff $c\in(1.12\cdot10^{-6},\,8.99\cdot10^{-3})$, a ratio of about 8000. At $N=10^6$ this is $\lambda\in(1.12,\,8989)$.
  * Plain MDL (λ = 1) switches to the memoriser at $N\approx8.94\cdot10^5$.
  * His "expected neg log likelihood ≈ p log(1/p) ≈ 1/100": the exact value is $H(2^{-10})=0.01117$, against $p\log(1/p)=0.00977$. The difference does not matter.
* **What the calculation does not show.** It does not show that no *other* hypothesis beats the good model in the window. Possible competitors are partial models, partial memorisers, mixtures and "universal-like" hypotheses; Hänni himself asks "maybe I'm just failing to construct the right universal hypothesis". Theorem 2 settles this for an instance with his numbers, over all product hypotheses.

### 2.2 The instance

**Setting 2.0.**
* Integers $1\le m\le d$; $p=2^{-r}$ with $2\le r\le m$; $s_0:=p2^m=2^{m-r}$.
* $a\in\{0,1\}^d$ with $K(a)\ge d$. The **simple model** is $f_a(x)=\langle a,x\rangle\bmod2$ on $X=\{0,1\}^d$.
* $S\subseteq\{0,1\}^m$ with $|S|=s_0$. The **error set** is $E:=S\times\{0,1\}^{d-m}$: the inputs whose first $m$ bits lie in $S$. Under uniform $x$, $\Pr[x\in E]=p$ exactly.
* The **teacher** is the deterministic function $y^*(x)=f_a(x)\oplus1_E(x)$.
  * For $m<d$ the errors are a *systematic* rule (a random junta), so they generalise to new inputs.
  * For $m=d$ they are an idiosyncratic random error set on a finite domain.
* $L_S:=\log\binom{2^m}{s_0}$; $\delta_S:=L_S-K(S\mid a,K(a))$ is the randomness deficiency of $S$ given $a$; $B_S:=L_S-\delta_S\ge0$.
  * Known bounds: $2^mH(p)-\log(2^m+1)\le L_S\le2^mH(p)$ [known: e.g. Cover & Thomas, *Elements of Information Theory*, binomial-coefficient bounds; checked numerically in c3].
  * Most $S$ have small deficiency: $\Pr_S[\delta_S>j]<2^{-j}$, because fewer than $2^{L_S-j}$ programs are shorter than $L_S-j$.
* **Hänni's numbers**: $d=100$, $m=20$, $p=2^{-10}$, giving $L_S=11{,}710$ bits [computed: c1].
* **Population quantities.** Inputs are uniform on $X$. For a product program π:
  * $R(\pi)=\mathbb E_x[-\log\nu_\pi(y^*(x)\mid x)]$;
  * for a truncation level $B\in[\log(1/p),\infty]$, $R_B(\pi):=\mathbb E_x\min\{B,-\log\nu_\pi(y^*(x)\mid x)\}\le R(\pi)$;
  * $J_c(\pi)=c\ell(\pi)+R(\pi)$, $J_c^B:=c\ell+R_B$, $\Phi^B(c):=\inf J^B_c\le\Phi(c)$.
  * Put $\tau_B:=2^{1-B}$ and $\beta_B:=2^m\log(1+\tau_B)$, both 0 if $B=\infty$.
* **Agreement**: $u(\pi):=\mathbb E_x\nu_\pi(f_a(x)\mid x)$. **Levels**: $\theta_t:=\frac12+2^{-t-1}$ and $T(\pi):=\min\{t\ge1:u(\pi)>\theta_t\}$, with $T(\pi):=\infty$ if $u(\pi)\le\frac12$.
* $s(t):=2t+2\log(t+1)\le4t$.
* $G_j:=1-\log(1+2^{-j}+2p+\tau_B)$ for $j\in[0,\infty]$. It is concave and increasing in $j$: with $v=2^{-j}$, $G'=v/(1+v+2p+\tau_B)>0$ and $G''=-\ln2\cdot v(1+2p+\tau_B)/(1+v+2p+\tau_B)^2<0$.
* **Reference programs**:
  * the **coin**, with $\ell\le\kappa$ and $R=1$;
  * the **good model** $\pi_g$: $\nu(f_a(x)\mid x)=1-p$, with $\ell(\pi_g)\le d+\kappa_g$, $\kappa_g:=2\log d+2\log r+\kappa$, and $R=R_B=H(p)$ exactly;
  * the **memoriser** $\pi_b$ = the deterministic $y^*$, with $\ell(\pi_b)\le d+\lceil L_S\rceil+\kappa_b$, $\kappa_b:=2\log d+2\log m+2\log s_0+\kappa$, and $R=0$.
* $\Lambda_1:=2\log d+2\log m+2\log B\cdot[B<\infty]+\beta_B+\kappa$.

### 2.3 Four lemmas

**Lemma 2.1 (list decoding for semimeasures) [proved; computed: c2(b)].** If $T(\pi)=t<\infty$, then $K(a\mid\pi)\le s(t)+2\log d+\kappa$.

*Proof.*
* Write $h_y(x):=\nu_\pi(y\mid x)$, $s_h:=h_0-h_1\in[-1,1]$, $\chi_{a'}(x):=(-1)^{\langle a',x\rangle}$ and $\hat s(a'):=\mathbb E_x[s_h\chi_{a'}]$.
* Then $u(\pi;a'):=\mathbb E_x\nu_\pi(f_{a'}(x)\mid x)=\frac12(\mathbb E_x[h_0+h_1]+\hat s(a'))\le\frac12(1+\hat s(a'))$. This identity was checked to machine precision in c2(b).
* Parseval gives $\sum_{a'}\hat s(a')^2=\mathbb E s_h^2\le1$. So $A_t:=\{a':u(\pi;a')>\theta_t\}\subseteq\{a':\hat s(a')>2^{-t}\}$ has fewer than $2^{2t}$ elements.
* $u(\pi;a')$ is lower-semicomputable uniformly in $(\pi,a',d)$, so $A_t$ is c.e. given $(\pi,d,t)$, and $a\in A_t$.
* Describe $a$ by $d$, $t$ and its index in the enumeration of $A_t$: $2t$ bits given $t$. Then use (F5).
* (This is T5's Lemma 2.5a with $\hat s$ replaced by the lower-semicomputable $u$, which handles semimeasures. The Parseval list bound is standard [known: Goldreich & Levin 1989, STOC; Kushilevitz & Mansour 1993, *SIAM J. Comput.* 22(6)].) ∎

**Lemma 2.2 (risk floor) [proved; computed: c2(b)].** $R_B(\pi)\ge-\log(u(\pi)+p+2^{-B})$, with $2^{-\infty}=0$. Hence:
* $T(\pi)=t\ge2$ implies $R_B(\pi)\ge G_{t-1}$;
* $T(\pi)=\infty$ implies $R_B(\pi)\ge G_\infty$.

*Proof.*
* $\min\{B,-\log v\}=-\log\max\{v,2^{-B}\}$. By Jensen, $R_B\ge-\log\mathbb E_x\max\{\nu_\pi(y^*\mid x),2^{-B}\}\ge-\log(\mathbb E_x\nu_\pi(y^*\mid x)+2^{-B})$.
* Off $E$, $y^*=f_a$; on $E$, $\nu\le1$. So $\mathbb E_x\nu_\pi(y^*\mid x)\le u(\pi)+p$.
* If $T=t\ge2$, then $u\le\theta_{t-1}=\frac12+2^{-t}$. ∎

**Lemma 2.3 (coding the error rule with a hypothesis) [proved].** $K(S\mid a,\pi)\le2^mR_B(\pi)+\beta_B+2\log m+2\log B\cdot[B<\infty]+\kappa$.

*Proof.*
* For $z\in\{0,1\}^m$ and $b\in\{0,1\}$, let $q_z(b):=2^{-\mathbb E_w\min\{B,-\log\nu_\pi(f_a(z,w)\oplus b\mid(z,w))\}}$, with $w$ uniform on $\{0,1\}^{d-m}$.
* By AM–GM, $q_z(b)\le\mathbb E_w\max\{\nu_\pi(f_a\oplus b\mid\cdot),2^{-B}\}$. Hence $\sum_bq_z(b)\le1+\tau_B$.
* $q_z$ is lower-semicomputable from $(\pi,a,m,B)$.
* So $Q(S'):=\prod_zq_z(1_{S'}(z))/(1+\tau_B)$ is a lower-semicomputable semimeasure on subsets of $\{0,1\}^m$.
* Since $y^*(z,w)=f_a(z,w)\oplus1_S(z)$, $-\log Q(S)=2^mR_B(\pi)+\beta_B$.
* Apply (F2) conditionally on $(\pi,a,m,B)$, and (F5). ∎

**Lemma 2.4 (two-part lower bounds) [proved].** If $T(\pi)=t<\infty$, then
* (D1) $\ell(\pi)\ge d-s(t)-\Lambda_1$;
* (D2) $\ell(\pi)+2^mR_B(\pi)\ge d+B_S-s(t)-\Lambda_1$.

*Proof.*
* (D1) $d\le K(a)\le K(\pi)+K(a\mid\pi)+\kappa\le\ell(\pi)+s(t)+2\log d+\kappa$, by (F3), (F1) and Lemma 2.1.
* (D2)
  * By (F4), $K(a,S)=K(a)+K(S\mid a,K(a))+O(1)\ge d+B_S-\kappa$.
  * By (F3), $K(a,S)\le K(\pi)+K(a\mid\pi)+K(S\mid a,\pi)+\kappa$.
  * Insert (F1), Lemma 2.1 and Lemma 2.3. ∎

### 2.4 The theorem

Define:
* $\psi_c(R):=c\max\{0,B_S-2^mR\}+R$;
* $M_1(c):=c(d-4-\Lambda_1)+B_S/2^m$;
* $t^*:=(d-\Lambda_1)/4$;
* $M_2(c):=\min\{c(d-8-\Lambda_1)+G_1,\ G_{t^*-1}\}$ if $t^*\ge2$, and $M_2(c):=G_1$ if $t^*<2$;
* $J_g(c):=c(d+\kappa_g)+H(p)\ge J_c(\pi_g)$ and $J_b(c):=c(d+\lceil L_S\rceil+\kappa_b)\ge J_c(\pi_b)$;
* $\Delta(c):=\max\{0,\,c(4+\Lambda_1+\kappa_g)+H(p)-B_S/2^m\}$.

The pieces of $M_2$ are increasing in $c$. So $\{c:J_g(c)\le M_2(c)\}=(0,c_{\rm hi}]$, where:
* $c_{\rm hi}=\min\{\frac{G_1-H(p)}{8+\Lambda_1+\kappa_g},\frac{G_{t^*-1}-H(p)}{d+\kappa_g}\}$ if $t^*\ge2$;
* $c_{\rm hi}=\frac{G_1-H(p)}{d+\kappa_g}$ otherwise.

$c_{\rm hi}>0$ requires $G_1>H(p)$. With $B=\infty$ this holds iff $p<0.0560$ [computed: c3].

**Theorem 2 (the teacher's-mistakes trick: three regimes) [proved].** In Setting 2.0, with $B\in[\log(1/p),\infty]$:

**(o) Level bounds.** For every product program π:
* if $T(\pi)=1$, then $J_c^B(\pi)\ge c(d-4-\Lambda_1)+\psi_c(R_B(\pi))$;
* if $T(\pi)\ge2$, including ∞, then $J_c^B(\pi)\ge M_2(c)$.

**(i) Window.** If $c\,2^m>1$ and $c\le c_{\rm hi}$, then $\Phi(c)\ge\Phi^B(c)\ge\min\{M_1(c),M_2(c)\}$ and $J_c(\pi_g)\le\Phi(c)+\Delta(c)$. Here $\Delta(c)\le c(4+\Lambda_1+\kappa_g)+(\log(2^m+1)+\delta_S)/2^m$.

**(ii) Identification.** Let $c\,2^m>1$, $\eta\ge0$ and $J_g(c)+\eta<M_2(c)$. Let π satisfy $J^B_c(\pi)\le J_g(c)+\eta$; this includes every π with $J_c(\pi)\le\Phi(c)+\eta$. Then $T(\pi)=1$, so $u(\pi)>3/4$. Write $\Lambda_2:=2^mH(p)-B_S+4+\Lambda_1+\kappa_g\le\log(2^m+1)+\delta_S+4+\Lambda_1+\kappa_g$, $\Lambda_3:=4+2\log d+\kappa$, and
$$\Delta_\ell:=\kappa_g+\frac\eta c+\frac{\Lambda_2+\eta/c}{c2^m-1}.$$
Then:
* (a) *it knows the simple model*: $u(\pi)\ge2^{-(J_g(c)+\eta)}-p-2^{-B}$;
* (b) *it fits no better than noise*: $R_B(\pi)\ge H(p)-\frac{c\Lambda_2+\eta}{c2^m-1}$;
* (c) *it is short*: $\ell(\pi)\le d+\Delta_\ell$;
* (d) *it holds almost no information about the error rule*: $K(S\mid a,\pi)\ge B_S-\Delta_\ell-\Lambda_3$;
* (e) *it does not predict the errors*. For every integer $g\ge1$,
  $$e(\pi):=\mathbb E[\nu_\pi(y^*(x)\mid x)\mid x\in E]\ \le\ 1-u(\pi)+\gamma_g+2^{-g},$$
  where $\gamma_g:=\sqrt{j_g\ln2/(2s_0)}$, $j_g$ is the least integer $j\ge0$ with $j-2\log(j+1)>\Gamma_g$, and $\Gamma_g:=\delta_S+\Delta_\ell+\Lambda_3+1+2\log m+2\log s_0+g+2\log g+\kappa$.

**(iii) Memoriser regime.** Let $c\,2^m<1$, and let π satisfy $J^B_c(\pi)\le J_b(c)+\eta$ with $J_b(c)+\eta<M_2(c)$. Then:
* $T(\pi)=1$;
* $(1-c2^m)\min\{R_B(\pi),B_S/2^m\}\le\rho:=c(\lceil L_S\rceil-L_S+\delta_S+4+\Lambda_1+\kappa_b)+\eta$;
* if $\rho<(1-c2^m)B_S/2^m$, then $R_B(\pi)\le\rho/(1-c2^m)$ and $e(\pi)\ge2^{-R_B(\pi)/p}-2^{-B}$.

**(iv) The lower end is sharp.** If $c<H(p)/(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)$, then $J_c(\pi_b)<J_c(\pi)$ for every π with $T(\pi)=1$ and $R(\pi)\ge H(p)$. Since $L_S=2^mH(p)-O(m)$, this threshold is $2^{-m}(1-O((m+\log d+\kappa)/L_S))$.

*Proof.*

**(o)**
* For $T=1$, (D1) and (D2) with $s(1)=4$ give $\ell\ge d-4-\Lambda_1+\max\{0,B_S-2^mR_B\}$. Multiply by $c$ and add $R_B$.
* For $T=t\in[2,\infty)$, (D1) and Lemma 2.2 give $J^B_c\ge c(d-s(t)-\Lambda_1)^++G_{t-1}\ge\varphi(t):=c(d-4t-\Lambda_1)^++G_{t-1}$, using $s(t)\le4t$.
* Extend φ to real $t\ge2$.
  * If $t^*\ge2$: on $[2,t^*]$, φ is linear plus concave, so $\varphi\ge\min\{\varphi(2),\varphi(t^*)\}=\min\{c(d-8-\Lambda_1)+G_1,G_{t^*-1}\}$. For $t>t^*$, $\varphi\ge G_{t-1}\ge G_{t^*-1}$.
  * If $t^*<2$: $\varphi(t)\ge G_{t-1}\ge G_1$.
* For $T=\infty$, $J^B_c\ge R_B\ge G_\infty\ge G_j$ for every $j$.
* [computed: c3, 0 violations of $\min_{t\ge2}\varphi\ge M_2$ over 2830 random instances using the exact $s(t)$.]

**(i)**
* When $c2^m>1$, ψ decreases on $[0,B_S/2^m]$ with slope $1-c2^m<0$ and has slope 1 after. So $\min_{R\ge0}\psi_c(R)=\psi_c(B_S/2^m)=B_S/2^m$, and level-1 programs satisfy $J^B_c\ge M_1(c)$.
* With (o), $\Phi^B\ge\min\{M_1,M_2\}$.
* Then $J_c(\pi_g)-\Phi(c)\le J_g-\min\{M_1,M_2\}\le\max\{J_g-M_1,\,J_g-M_2\}\le\Delta(c)$, because $J_g\le M_2$. The bound on $\Delta$ uses $L_S\ge2^mH(p)-\log(2^m+1)$.

**(ii)**
* $J^B_c(\pi)<M_2(c)$, so by (o) $T(\pi)=1$.
* (a) By Lemma 2.2, $-\log(u+p+2^{-B})\le R_B\le J^B_c\le J_g+\eta$.
* (b)
  * By (o), $\psi_c(R_B)\le c(4+\Lambda_1+\kappa_g)+H(p)+\eta$.
  * If $R_B<B_S/2^m$, then $\psi_c=cB_S-(c2^m-1)R_B$. Using $cB_S-H(p)=(c2^m-1)H(p)-c(2^mH(p)-B_S)$, this gives $(c2^m-1)R_B\ge(c2^m-1)H(p)-c\Lambda_2-\eta$.
  * If $R_B\ge B_S/2^m$, then $R_B\ge H(p)-(2^mH(p)-B_S)/2^m\ge H(p)-c\Lambda_2/(c2^m-1)$, since $\Lambda_2\ge2^mH(p)-B_S$. (If $2^mH(p)-B_S\le0$ the claim is trivial.)
* (c) $c\ell=J^B_c-R_B\le c(d+\kappa_g)+H(p)+\eta-R_B$, then apply (b).
* (d)
  * By (F3), $B_S=K(S\mid a,K(a))\le K(\pi\mid a,K(a))+K(S\mid\pi,a)+\kappa$.
  * By (F4) and (F3), $K(\pi\mid a,K(a))=K(\pi,a)-K(a)+O(1)\le K(\pi)+K(a\mid\pi)-K(a)+O(1)$.
  * This is at most $\ell(\pi)-d+s(1)+2\log d+\kappa\le\Delta_\ell+\Lambda_3$, by (F1), Lemma 2.1, $K(a)\ge d$ and (c).
* (e)
  * Let $v(z):=\mathbb E_w\nu_\pi(f_a(z,w)\oplus1\mid(z,w))\in[0,1]$. Then $e(\pi)=s_0^{-1}\sum_{z\in S}v(z)$, and $\bar v:=2^{-m}\sum_zv(z)=\mathbb E_x\nu_\pi(f_a\oplus1\mid x)\le1-u(\pi)$ because ν is a semimeasure.
  * Let $\theta$ be the least multiple of $2^{-g}$ that is $\ge1-u(\pi)+\gamma_g$. Then $K(\theta)\le g+2\log g+\kappa$ and $\theta\ge\bar v+\gamma_g$.
  * Suppose $e(\pi)>\theta$. The set $B_\theta:=\{S':|S'|=s_0,\ s_0^{-1}\sum_{z\in S'}v(z)>\theta\}$ is c.e. given $(\pi,a,m,s_0,\theta)$, because $v$ is lower-semicomputable. It contains $S$.
  * For $S'$ uniform among $s_0$-subsets, Hoeffding's bound for sampling without replacement gives $\Pr[\mathrm{avg}_{S'}v-\bar v\ge\gamma_g]\le e^{-2s_0\gamma_g^2}$ [known: Hoeffding 1963, *JASA* 58:13–30, Thm 4 (verified via secondary sources); sanity check in c3]. So $|B_\theta|\le2^{L_S-j_g}$.
  * Describe $S$ by $j_g$ (self-delimiting) and its index among the first $2^{\lceil L_S\rceil-j_g}$ elements enumerated. This gives $K(S\mid\pi,a)\le\lceil L_S\rceil-j_g+2\log(j_g+1)+2\log m+2\log s_0+g+2\log g+\kappa$.
  * Together with (d), this gives $j_g-2\log(j_g+1)\le\Gamma_g$, contradicting the choice of $j_g$. So $e(\pi)\le\theta\le1-u+\gamma_g+2^{-g}$.

**(iii)**
* $T=1$ follows from (o) as in (ii).
* For $c2^m<1$ and $R\ge0$, $\psi_c(R)\ge cB_S+(1-c2^m)\min\{R,B_S/2^m\}$. To check this, consider $R\le B_S/2^m$ and $R\ge B_S/2^m$ separately; note $B_S/2^m=cB_S+(1-c2^m)B_S/2^m$.
* Compare with $J^B_c\le J_b(c)+\eta$. The error-label bound follows from $p\cdot\mathbb E[\min(B,-\log\nu)\mid E]\le R_B$ and Jensen: $\mathbb E[\nu\mid E]\ge\mathbb E[\max(\nu,2^{-B})\mid E]-2^{-B}\ge2^{-R_B/p}-2^{-B}$.

**(iv)** By (D1), $J_c(\pi)\ge c(d-4-\Lambda_1)+H(p)>c(d+\lceil L_S\rceil+\kappa_b)\ge J_c(\pi_b)$. ∎

**Corollary 2.5 (idiosyncratic errors, full truth table) [proved; computed: c3].** Take $m=d$, $n=2^d$, $B=\infty$, and let the data be the whole truth table, so $N=n$.
* A λ-MAP minimises $\lambda\ell+nR=n\,J_{\lambda/n}$, so it satisfies Theorem 2(ii) with $\eta=0$ and $c=\lambda/n$.
* For every $\lambda\in(1,\,n\,c_{\rm hi}]$ with $J_g(\lambda/n)<M_2(\lambda/n)$, every λ-MAP satisfies:
  * $u(\pi)\ge2^{-(J_g+0)}-p$;
  * $nR(\pi)\ge nH(p)-\lambda\Lambda_2/(\lambda-1)$;
  * $\ell(\pi)\le d+\kappa_g+\Lambda_2/(\lambda-1)$;
  * $K(E\mid a,\pi)\ge B_E-\kappa_g-\Lambda_2/(\lambda-1)-\Lambda_3$;
  * the error-label bound (e).
* At λ = 1 all three are within $O(\log n)+\delta_E$ of each other: the optimum, $J_1(\pi_g)$ and $J_1(\pi_b)$. Indeed:
  * $J_1(\pi_g)\le d+\kappa_g+L_E+\log(n+1)$;
  * $J_1(\pi_b)\le d+\lceil L_E\rceil+\kappa_b$;
  * every level-1 program has $J_1\ge d+B_E-4-\Lambda_1$ by (D2);
  * every other program has $J_1\ge nG_1$, which exceeds $J_1(\pi_g)$ once $n(G_1-H(p))>d+\kappa_g+\log(n+1)$.
  
  So **λ = 1 does not determine whether the errors are memorised** (it depends on lower-order terms and the reference machine). **Every λ > 1 does**, up to the slack $\Lambda_2/(\lambda-1)$.
* *Numbers* [computed: c3], with κ = 0 for illustration ($d=m=20$, $p=2^{-10}$, $L_E=11{,}710$):
  * the window is $\lambda\in(1,\,1.19\cdot10^4]$;
  * at λ = 2: $u\ge0.991$, $\ell\le d+58$, information about $E$ at most 71 bits, $e\le0.23$;
  * at $\lambda=105$: $\ell\le d+16$, information at most 28 bits, $e\le0.19$.
  * With κ = 30 the window shrinks to $(1,6456]$ and the bounds weaken by tens of bits.
  * In an exact small instance ($d=m=8$, $|E|=8$) the good model and the memoriser switch at λ = 0.936 [computed: c3].

**Lemma 2.6 (finite sample) [proved].**
* *Setting.* Let $m\le d$ and $B<\infty$. Draw $N\le2^d$ inputs uniformly *without replacement*, so the data form a partial function as SFI requires, and label them by $y^*$. Let $\hat J_c(\pi):=c\ell(\pi)+\frac1N\sum_i-\log\nu_\pi(y^*(x_i)\mid x_i)$.
* *Reference.* Let $\pi_{\rm ref}$ be a fixed program whose per-input losses lie in $[0,A]$.
* *Claim.* With probability at least $1-\delta$, every minimiser $\hat\pi$ of $\hat J_c$ satisfies
$$J^B_c(\hat\pi)\le J_c(\pi_{\rm ref})+\varepsilon_1+B\sqrt{\frac{\hat L\ln2+\ln(2/\delta)}{2N}},$$
where $\varepsilon_1:=A\sqrt{\ln(2/\delta)/(2N)}$ and $\hat L:=(J_c(\pi_{\rm ref})+\varepsilon_1)/c$.

*Proof.*
* Each sampled input is marginally uniform. By Hoeffding's bound for sampling without replacement (Thm 4 of Hoeffding 1963), with probability at least $1-\delta/2$, $\hat J_c(\pi_{\rm ref})\le J_c(\pi_{\rm ref})+\varepsilon_1$.
* For each π, the truncated losses lie in $[0,B]$. Apply Hoeffding with confidence $(\delta/2)2^{-\ell(\pi)}$ and take a union bound (Kraft). With probability at least $1-\delta/2$, simultaneously for all π, $\hat J_c(\pi)\ge J^B_c(\pi)-B\sqrt{(\ell(\pi)\ln2+\ln(2/\delta))/(2N)}$.
* A minimiser satisfies $c\ell(\hat\pi)\le\hat J_c(\hat\pi)\le\hat J_c(\pi_{\rm ref})$, so $\ell(\hat\pi)\le\hat L$.
* Combine. (This adapts T5 Lemma 1.2: it is one-sided and uses truncation, so no noise floor on hypotheses is needed.) ∎

**Corollary 2.7 (Hänni's numbers with sampled data) [proved; computed: c3].** Take $\pi_{\rm ref}=\pi_g$ and $A=\log(1/p)$. With probability at least $1-\delta$, every λ-MAP with $\lambda=cN$ satisfies Theorem 2(ii) with $\eta=\varepsilon_N$, whenever $J_g+\varepsilon_N<M_2$.

At $d=100$, $m=20$, $p=2^{-10}$, $B=30$, $\delta=0.01$ and κ = 0 [computed: c3]:

| $c$ | $N$ | $\varepsilon_N/c$ | $u\ge$ | $\ell\le$ | $e\le$ |
|---|---|---|---|---|---|
| $10^{-4}$ | $10^{11}$ | 9.2 bits | 0.983 | $d+30$ | 0.21 |
| $10^{-4}$ | $10^{13}$ | 0.9 bits | 0.983 | $d+21.5$ | 0.20 |
| $10^{-3}$ | $10^{11}$ | — | 0.912 | — | 0.27 |

The required $N$ is large because uniform convergence over all programs is pessimistic. Theorem 2 itself is a population statement.

**Proposition 2.8 (the power posterior concentrates on near-minimisers) [proved; computed: c5(e)].** Let $\lambda=cN$, let $D$ be any data set and let $\hat J_g:=\hat J_c(\pi_g)$. Then for every $\eta>0$,
$$\frac{\Pi_\lambda(\{\pi:\hat J_c(\pi)\ge\hat J_g+\eta\}\mid D)}{\Pi_\lambda(\pi_g\mid D)}\ \le\ 2^{-N\eta+(\hat J_g+\eta)/c}.$$

*Proof.*
* $2^{-\lambda\ell(\pi)}\nu_\pi(D)=2^{-N\hat J_c(\pi)}$.
* $N\hat J_c(\pi)-\ell(\pi)=(\lambda-1)\ell(\pi)+N\hat L(\pi)\ge(1-1/\lambda)N\hat J_c(\pi)$, where $\hat L$ is the empirical loss. This holds because $N\hat J_c/\lambda\ge\ell$.
* Summing $2^{-\ell(\pi)}2^{-(1-1/\lambda)N(\hat J_g+\eta)}$ over the set gives at most $2^{-(1-1/\lambda)N(\hat J_g+\eta)}$, by Kraft.
* Divide by $2^{-N\hat J_g}$ and use $N/\lambda=1/c$. ∎

*Consequence* [proved]. Combine Prop 2.8 with Lemma 2.6's uniform deviation bound, which applies to every empirical near-minimiser because $\ell\le\hat J_c/c$. With probability at least $1-\delta$, the steeper posterior with $\lambda=cN$ puts all but a $2^{-N\eta+(\hat J_g+\eta)/c}$ fraction of its mass on programs that satisfy Theorem 2(ii) with $\eta'=\eta+\varepsilon_N$, provided $J_g+\eta'<M_2$.
* Its predictive, averaged over $E$, gives the error label probability at most $\sup e(\pi)+2^{-N\eta+(\hat J_g+\eta)/c}$, the supremum taken over those programs.
* Averaged over the fresh error inputs $E\setminus\mathrm{dom}D$ instead, the bound is multiplied by $|E|/(|E|-N)$. This factor is negligible at $d=100$.
* Example: $c=10^{-4}$, $\eta=10^{-3}$, $N=10^6$ gives a ratio of at most $2^{-776}$ (c5(e)).

### 2.5 Plain Bayes, MDL and SI learn the errors

**Proposition 2.9 [proved; computed: c3].**
* **(a) SFI (λ = 1).** For every sequence of distinct inputs,
$$\sum_i-\log\xi_\times(y^*(x_i)\mid x_i,D_{i-1})\le\ell(\pi_b)\le d+\lceil L_S\rceil+\kappa_b.$$
  The same holds for every SFI predictor that dominates the product class up to a constant, e.g. $M_F$. For $M_F$ this is F's mistake bound (F Cor 6.6).
  * So at most $d+L_S+O(\log)$ inputs, in total, receive probability below 1/2 for the teacher's label.
  * Under uniform inputs the number of error inputs grows like $pN$, so the fraction of error inputs on which SFI reproduces the teacher's error tends to 1.
* **(b) MDL / λ-MAP for any *fixed* λ ≥ 1.** Apply Lemma 2.6 with $\pi_{\rm ref}=\pi_b$ ($A=0$), $c=\lambda/N$, $\hat L=d+\lceil L_S\rceil+\kappa_b$. With probability at least $1-\delta$, the MAP has
  $$R_B\le\frac{\lambda\hat L}N+B\sqrt{\frac{\hat L\ln2+\ln(2/\delta)}{2N}}\to0,$$
  hence $e(\hat\pi)\ge2^{-R_B/p}-2^{-B}\to1-2^{-B}$. Numbers at λ = 1, κ = 0: $e\ge0.65$ at $N=10^{13}$ and $e\ge0.96$ at $N=10^{15}$.
* **(c) SI.** On the interleaved sequence with uniform i.i.d. inputs, Theorem 1(d) with λ = 1 gives $\mathbb E\sum_i-\log M(y_i\mid\cdot)\le K(\mu)+\kappa\le d+L_S+O(\log dm)$. For every λ > 1 the steeper SI predictor pays at most $\lambda\ell_U$ more.

*Proof.* (a) $\xi_\times(D_N)\ge2^{-\ell(\pi_b)}$, then telescope. (b) Lemma 2.6, and $R_B(\hat\pi)\le J^B_c(\hat\pi)$; the error-label bound is as in Theorem 2(iii). (c) is Theorem 1(d). ∎

So the trick needs $\lambda$ to grow like $N$. A **fixed** λ > 1 removes only noise (§3), not finite-complexity errors. This confirms Hänni's remark that the coefficient must increase with the data set. At $\lambda=cN$ the selection is asymptotically stable. This keeps T5's correction of an earlier gloss ("only on a finite-sample window").

### 2.6 Limits

**Proposition 2.10 (fixed λ) [proved].** This is Prop 2.9(b): for fixed λ and $N\to\infty$, the λ-MAP reproduces the systematic errors.

**Proposition 2.11 (rate blindness in the junta family) [proved; computed: c3].**
* **(i) Three-hypothesis form.** If
  $$\frac{H(p)}{\ell(\pi_b)-\ell(\pi_g)}\ \ge\ \frac{1-H(p)}{\ell(\pi_g)-\ell({\rm coin})},$$
  then at every $c$ the good-model program is beaten by the memoriser or by the coin.
  *Proof.* $J_c(\pi_b)<J_c(\pi_g)$ iff $c<H(p)/(\ell(\pi_b)-\ell(\pi_g))$; $J_c({\rm coin})\le J_c(\pi_g)$ iff $c\ge(1-H(p))/(\ell(\pi_g)-\ell({\rm coin}))$.
* **(ii) All hypotheses.** If
  $$\frac{H(p)}{\lceil L_S\rceil+\kappa_b+4+\Lambda_1}\ \ge\ \frac{1-H(p)}{d-4-\Lambda_1-\kappa},$$
  then at every $c$, every program that knows the simple model ($u>3/4$) and fits no better than noise ($R\ge H(p)$) is beaten by the memoriser or beaten or tied by the coin.
  *Proof.*
  * Below the left-hand side, Theorem 2(iv) applies.
  * At or above it, (D1) gives $J_c(\pi)\ge c(d-4-\Lambda_1)+H(p)\ge1+c\kappa\ge J_c({\rm coin})$.
* **(iii)** For $c<2^{-m}$, Theorem 2(iii) shows that near-optimal programs reproduce the errors.
* **Examples** (κ = 0; c3):
  * A single 7-bit error prefix ($p=2^{-7}$) with $d=100$ satisfies (i): the good model is never selected. A 6-bit one ($p=2^{-6}$) satisfies (i) at $d=100$.
  * A 3-bit error rule on 1/8 of the inputs satisfies (ii) at $d=100$. A 6-bit rule on 1/64 satisfies (ii) at $d\ge1000$.
  * In the memoriser regime of the 6-bit rule at $c=10^{-4}$, near-optimal programs give the error label probability $e\ge0.83$.
  * By contrast, Hänni's 11,710-bit error rule ($m=20$) leaves a window of a factor of about 8000.

**Proposition 2.12 (separable components; T5 Thm 3.2, re-derived) [proved; computed: c5(a)].**
* *Setting.* The inputs split into regions $X_1,\dots,X_k$, and hypotheses are products of per-region choices with additive code lengths.
* *Claim.* Each region independently picks the vertex of its own hull for slope $c$. If region $j$ offers "default" or "component $j$" (extra length $k_j$, risk reduction $r_j$), then component $j$ is selected iff $r_j/k_j>c$; ties are arbitrary.
* *Consequence.* A valid component whose rate is at most an error component's rate cannot be kept without the error, except at a common tie value of $c$.
* *Proof.* The objective is a sum over regions. 0 violations in 8000 brute-force tests (c5(a)). ∎

The steeper penalty sorts by **rate**, not by validity. Two worlds with the same teacher channel $P^*$, one where a component is an error and one where it is a rare valid rule, receive the same selection at every $c$. *Proof:* $J_c$ depends on the data only through $P^*$. This is T5 Thm 4.1, kept.

**Proposition 2.13 (guard erosion; T5 Prop 4.4, re-derived) [proved; computed: c5(b)].**
* *Setting.* In some region (contexts where a schema σ applies), the teacher applies σ only when a guard $G$ holds (frequency $\pi_G$, per-use gain $g$). Otherwise (frequency $\pi_{\neg G}$) the teacher plays one of the other $M-1$ steps.
* *Options and rates.*
  * The options are "none" (uniform), "unguarded σ" (cost $k_\sigma$) and "guarded σ" (cost $k_\sigma+k_G$).
  * With teacher noise η, the unguarded option's rate is $\rho_\sigma=(\pi_Gg-\pi_{\neg G}\log(1/\eta))/k_\sigma$.
  * The guard's marginal rate is $\rho_G=\pi_{\neg G}\Delta_G/k_G$, with $\Delta_G=\log(M/\eta)-\log(M-1)$.
* *Claim.* If $\rho_G<\rho_\sigma$, then for $c\in(\rho_G,\rho_\sigma)$ the selected rule is the **unguarded** one, which is unsound although the teacher never erred. Otherwise the path goes guarded → none.
* *Proof.* The three options are the points $(0,0)$, $(k_\sigma,-k_\sigma\rho_\sigma)$ and $(k_\sigma+k_G,-k_\sigma\rho_\sigma-k_G\rho_G)$. The middle one is a hull vertex iff $\rho_\sigma>\rho_G$. Apply Lemma 1.2. ∎
* *Numbers.* For $\pi_G=0.05$, $\pi_{\neg G}=5\cdot10^{-4}$, $k_\sigma=22$, $k_G=12$, $M=64$, η = 0.05: unguarded on $(1.81\cdot10^{-4},1.22\cdot10^{-2})$. For $\pi_G=\pi_{\neg G}=0.002$: guarded → none at $3.21\cdot10^{-4}$.

**Proposition 2.14 (λ cannot be chosen from imitation data; T5 Thm 4.3, re-derived) [proved; computed: c5(c)].**
* (i) For every strictly proper scoring rule, the expected score under the teacher's data is uniquely maximised by the teacher's channel $P^*(\cdot\mid x)$, errors included, at each $x$ of positive mass [known: definition and Gneiting & Raftery 2007, *JASA* 102:359–378 (verified)]. So any validation that estimates a strictly proper score on fresh imitation data prefers, among candidates, the one closest to $P^*$, not the norm. Computed for the log, Brier and spherical scores in Hänni's example.
* (ii) Along the population selection path, held-out log-loss $R(h_c)$ is nonincreasing as $c$ decreases (Lemma 1.2(ii)). So log-loss validation over a grid prefers the smallest grid value, i.e. the error-memorising end [computed: held-out loss 1.0, 0.0112, 0.0112, 0 at $c=10^{-1},10^{-3},10^{-5},10^{-7}$].
* (iii) In the twin worlds of Prop 2.12 every imitation-only rule picks the same $c$, so it is wrong in one of them.

SafeBayes learns the learning rate η = 1/λ from data by a sequential randomised log-loss [known: Grünwald 2012 (verified; content per abstract)]. By (i), it has no reason to move away from η = 1 in this well-specified imitation setting. This is my reading; the papers' exact criteria were not checked.

**Limitation of the proof method.** Theorem 2's window needs $G_1>H(p)$, i.e. $p<0.056$. At Hänni's sizes the identification constants are modest. For example $e\le0.20$ at $s_0=1024$; this improves to 0.065 at $s_0=16{,}384$ ($m=24$; computed). A sharper analysis would replace the Jensen floor of Lemma 2.2 by a finer one (T5's Lemma 2.5c does this for the full-table case); it is not reused here.

---

## 3. The model-vs-randomness split

Hänni: "a preference for a simple sampler over a model where the sampled bits are filled in (solomonoff doesn't have a preference here, both get similar posterior)".

### 3.1 Setting

* ν is a computable conditional *measure* (a sampler) with a program $\pi_\nu\in\Pi_\times$ of length $k$.
* Inputs $x_1,x_2,\dots$ are distinct and chosen by any rule, possibly adaptive or non-computable, before the corresponding label is drawn. Each label is drawn fresh, $y_i\sim\nu(\cdot\mid x_i)$.
* $D_N$ is the first $N$ pairs. The **sampled randomness** is $-\log\nu(D_N)=\sum_i-\log\nu(y_i\mid x_i)$; it is about $NH$ if every $\nu(\cdot\mid x)$ has entropy $H$.
* **Fill-ins** are deterministic programs consistent with $D_N$: they reproduce the sampled labels on the seen inputs and output anything elsewhere. Their total weight is $W_{\rm det}(D):=\sum_{\pi\ \rm det,\ \pi\supseteq D}2^{-\ell(\pi)}$.

**Lemma 3.1 (Ville deficiency) [proved; computed: c4(A)].** Let $\xi$ be any shared hypothesis with $\xi(\emptyset)\le1$; in particular $\xi=\xi_\times$. Let $m^*:=\sup_N\log(\xi(D_N)/\nu(D_N))$. Then:
* $\Pr[m^*\ge m]\le2^{-m}$ for all $m\ge0$;
* consequently, for $\xi=\xi_\times$, every program π and every $N$: $\nu_\pi(D_N)\le2^{\ell(\pi)+m^*}\nu(D_N)$.

*Proof.*
* $Z_N:=\xi(D_N)/\nu(D_N)$ satisfies $\mathbb E[Z_{N+1}\mid\mathcal F_N,x_{N+1}]=\sum_y\xi(D_N\cup\{(x_{N+1},y)\})/\nu(D_N)\le Z_N$, by the one-point inequality. So it is a nonnegative supermartingale with $Z_0\le1$.
* Ville's maximal inequality gives $\Pr[\sup Z_N\ge a]\le1/a$ [known: Ville 1939; Doob's maximal inequality].
* For the consequence, $\xi_\times\ge2^{-\ell(\pi)}\nu_\pi$.
* Simulation: empirical $\Pr[\sup\ge m]$ was 0.119, 0.055, 0.032, 0.014, 0.003 for $m=1,2,3,4,6$, all below $2^{-m}$ (c4(A)). ∎

**Lemma 3.2 (derandomising a sampler by hashing) [proved; computed: c4(B)].**
* *Setting.* Let $X=\{0,1\}^n$, and let ν be computed by a sampler that reads exactly $r$ uniform bits $b$ and outputs $\sigma(x,b)$.
* *Claim.* Let the class be universal for deterministic programs. For every data set $D$ with $N$ inputs,
$$W_{\rm det}(D)\ \ge\ 2^{-k-2\log(N+1)-2\log(n+1)-2\log(r+1)-\kappa}\,\nu(D).$$

*Proof.*
* Let $q:=\max(n,r)$ and let $\iota:\{0,1\}^n\to GF(2^q)$ be injective. For $s\in GF(2^q)^N$, let $h_s(x)$ be the first $r$ bits of $\sum_{j<N}s_j\iota(x)^j$.
* For distinct $x_1,\dots,x_N$ the map $s\mapsto(\sum_js_j\iota(x_i)^j)_i$ is a bijection (Vandermonde). So for uniform $s$ the values $h_s(x_i)$ are independent and uniform.
* The deterministic program $\varphi_s:x\mapsto\sigma(x,h_s(x))$ is described by $(\pi_\nu,N,n,r,s)$, with length at most $k+2\log(N+1)+2\log(n+1)+2\log(r+1)+qN+\kappa$; $s$ has known length $qN$.
* $\Pr_s[\varphi_s\supseteq D]=\prod_i\Pr_b[\sigma(x_i,b)=y_i]=\nu(D)$. Summing $2^{-\ell(\varphi_s)}$ over consistent seeds gives the claim.
* Checked exactly over $GF(16)$ for $N\le3$: 3232 cases, maximum error 0 (c4(B)). ∎

F Prop 4.4 proves the fair-coin case, at cost $K(n,k)$, with the same hash family. F's remark after it sketches the dyadic case; Lemma 3.2 proves that case.

In the function-machine version of SFI (one random tape, brief H1(a)), the dovetailed sampler is itself a union of cylinders, each fixing the bits it reads. These are "fill-ins" with no $K(N)$ cost. Lemma 3.2 is what the total-program mixture (brief H1(b)) needs.

### 3.2 λ = 1: the sampler and its fill-ins get similar posterior

**Theorem 3 (SFI, λ = 1) [proved].** In the setting of §3.1, under the hypotheses of Lemma 3.2, simultaneously for all $N$:
* (i) $\Pi_1(\pi_\nu\mid D_N)\ge2^{-k-m^*}$;
* (ii) $\Pi_1(\mathrm{det}\mid D_N)=W_{\rm det}(D_N)/\xi_\times(D_N)\ge2^{-k-2\log(N+1)-2\log(n+1)-2\log(r+1)-\kappa-m^*}$;
* (iii) the posterior odds of all fill-ins against the sampler program lie in
$$\big[\,2^{-2\log(N+1)-2\log(n+1)-2\log(r+1)-\kappa},\ \ 2^{k+m^*}\big],$$
whatever the sampled randomness $-\log\nu(D_N)$.

*Proof.*
* (i) $\Pi_1(\pi_\nu\mid D)=2^{-k}\nu(D)/\xi_\times(D)$; apply Lemma 3.1.
* (ii) Lemma 3.2 and Lemma 3.1.
* (iii) The lower end is Lemma 3.2. For the upper end, $W_{\rm det}\le\xi_\times\le2^{m^*}\nu$. ∎

**Proposition 3.3 (SI, λ = 1) [proved].**
* *Setting.* A string $z=z_{1:n}$ is drawn from a computable measure μ with $K(\mu)=k$. Let ξ be Solomonoff's mixture over lower-semicomputable semimeasures with weights $2^{-K}$, and let $m^*:=\sup_n\log(\xi(z_{1:n})/\mu(z_{1:n}))$.
* (i) $\pi(\mu\mid z_{1:n})\ge2^{-k-m^*}$ for all $n$, with $\Pr[m^*\ge m]\le2^{-m}$. This is the same proof as Lemma 3.1.
* (ii) The deterministic hypotheses consistent with $z$ (point masses on computable infinite extensions) have total weight at least $2^{-k-K(n)-\kappa}\mu(z)$. A single one suffices: $w=z0^\infty$ has $K(\delta_w)\le K(z)+\kappa\le K(n)+K(z\mid n)+\kappa\le K(n)+k-\log\mu(z)+\kappa$, by (F2) applied to μ restricted to length $n$.
* (iii) In Solomonoff's deterministic-program representation $M=\sum_p2^{-|p|}$, *every* hypothesis is a fill-in. The sampler appears only as the set of programs "decoder for μ, then a code of z", whose total weight is at least $2^{-k-\kappa}\mu(z)$ [known: this is the usual proof of $M\ge2^{-K(\mu)-\kappa}\mu$].

So Hänni's claim "both get similar posterior" holds in SI and in SFI, up to factors $2^{O(k+\log N)}$ and the Ville deficiency. The odds do not depend on how much randomness was sampled. In SI no hashing is needed, because a fill-in may output the whole sequence.

### 3.3 λ > 1 with private randomness: the sampler wins

Call π **ν-equivalent on the run** if $\sum_N\mathrm{H}^2\big(\nu(\cdot\mid x_N),\nu_\pi(\cdot\mid x_N)\big)<\infty$, where $\mathrm H^2(P,Q):=1-\sum_y\sqrt{P(y)Q(y)}$. For a sub-probability $Q$, $\mathrm H^2\in[0,1]$ still holds.

**Theorem 4 (SFI with private randomness, λ > 1) [proved; computed: c4(C)].** In the setting of §3.1 with the product class $\Pi_\times$, fix $\lambda>1$. Simultaneously for all $N$:
* **(i) MAP.** Every λ-MAP $\hat\pi_N$ has $\ell(\hat\pi_N)\le(\lambda k+m^*)/(\lambda-1)$ and $-\log\nu(D_N)-\ell(\hat\pi_N)-m^*\le-\log\nu_{\hat\pi_N}(D_N)\le-\log\nu(D_N)+\lambda k$.
* **(ii) Length tail.** $\Pi_\lambda(\{\pi:\ell(\pi)>L\}\mid D_N)\le2^{\lambda k+m^*-(\lambda-1)L}$.
* **(iii) Fill-ins.**
  * Every deterministic program consistent with $D_N$ has $\ell\ge-\log\nu(D_N)-m^*$.
  * $\Pi_\lambda(\mathrm{det}\mid D_N)\le2^{\lambda k+\lambda m^*-(\lambda-1)(-\log\nu(D_N))}$.
  * For the tempered posterior with $\eta=1/\lambda$: $\Pi^\eta(\mathrm{det}\mid D_N)\le2^{k+m^*-(1-\eta)(-\log\nu(D_N))}$.
* **(iv) Identification.** Almost surely:
  * from some $N$ on, every λ-MAP is ν-equivalent on the run;
  * $\Pi_\lambda(\nu\text{-equivalent on the run}\mid D_N)\to1$.

*Proof.*
* (i)
  * $J_\lambda(\hat\pi)\le J_\lambda(\pi_\nu)=\lambda k-\log\nu(D)$.
  * By Lemma 3.1, $-\log\nu_{\hat\pi}(D)\ge-\log\nu(D)-\ell(\hat\pi)-m^*$. Substituting gives $(\lambda-1)\ell(\hat\pi)\le\lambda k+m^*$.
  * The upper bound on the loss is $J_\lambda(\hat\pi)\le J_\lambda(\pi_\nu)$.
* (ii)
  * $\sum_{\ell(\pi)>L}2^{-\lambda\ell(\pi)}\nu_\pi(D)\le2^{-(\lambda-1)L}\xi_\times(D)\le2^{-(\lambda-1)L+m^*}\nu(D)$.
  * The normaliser is at least $2^{-\lambda k}\nu(D)$.
* (iii)
  * A consistent deterministic π has $1=\nu_\pi(D)\le2^{\ell(\pi)+m^*}\nu(D)$, which gives the length bound.
  * Power posterior: $\sum_{\rm det}2^{-\lambda\ell}\le2^{-(\lambda-1)(-\log\nu(D)-m^*)}W_{\rm det}(D)$, $W_{\rm det}\le\xi_\times\le2^{m^*}\nu(D)$, and the normaliser is at least $2^{-\lambda k}\nu(D)$.
  * Tempered posterior: the fill-ins' weight is $W_{\rm det}\le2^{m^*}\nu(D)$, and the sampler's is $2^{-k}\nu(D)^\eta$.
* (iv)
  * *Likelihood ratios vanish.* Fix π and let $\Lambda_N:=\nu_\pi(D_N)/\nu(D_N)$. Conditionally on the past and on $x_{N+1}$, $\mathbb E\sqrt{\Lambda_{N+1}/\Lambda_N}=1-\mathrm H^2_{N+1}$.
    * If some $\mathrm H^2_i=1$, then $\Lambda=0$ almost surely from that point on.
    * Otherwise $\sqrt{\Lambda_N}/\prod_{i\le N}(1-\mathrm H^2_i)$ is a nonnegative martingale, so it converges almost surely to a finite limit. On $\{\sum\mathrm H^2_i=\infty\}$ the product tends to 0, hence $\Lambda_N\to0$.
    * This is the Kakutani-type argument [known: Kakutani 1948, *Ann. Math.* 49:214–224 (verified)]. It holds for adaptive inputs.
  * *Countably many programs.* There are countably many π, so almost surely the following hold simultaneously: $m^*<\infty$, and $\Lambda_N(\pi)\to0$ for every π that is not ν-equivalent on the run.
  * *MAPs.* MAPs lie in the finite set $\{\ell\le L\}$ with $L=(\lambda k+m^*)/(\lambda-1)$, by (i). A MAP has $\Lambda_N(\hat\pi)\ge2^{\lambda\ell(\hat\pi)-\lambda k}\ge2^{-\lambda k}$. Each non-equivalent π in that finite set eventually has $\Lambda_N<2^{-\lambda k}$.
  * *Posterior.* $\Pi_\lambda(\text{non-equivalent}\mid D_N)\le2^{\lambda k}\big[\sum_{\ell(\pi)\le L,\ \text{non-eq}}2^{-\lambda\ell(\pi)}\Lambda_N(\pi)\big]+2^{\lambda k+m^*-(\lambda-1)L}$ for every $L$. The first term tends to 0; then let $L\to\infty$. ∎

So, uniformly in $N$, the steeper SFI posterior puts exponentially little mass on fill-ins, in the amount of sampled randomness. Its MAP has bounded length. Eventually both sit on samplers equivalent to ν. **This is the split Hänni hoped for, with any fixed λ > 1.** The model is the shortest ν-equivalent sampler, up to the slack $(k+m^*)/(\lambda-1)$; the randomness is everything else.

### 3.4 λ > 1 with shared randomness: no split

**Theorem 5 (SI, or SFI with shared randomness, λ > 1) [proved; computed: c4(C)].** Assume (Dom) and $\xi_1\le2^{c_1}U$, and let $\lambda>1$. For any data:
* (i) If $(\lambda-1)k>\lambda\ell_U+c_0$, then $J_\lambda(\pi_U)<J_\lambda(\pi_\nu)$ on every data set: the sampler program is never a λ-MAP, and every λ-MAP has length at most $L_\lambda<k$.
* (ii) For every set $A$ of programs: $\Pi_\lambda(A\mid D)\le2^{-(\lambda-1)\min_{\pi\in A}\ell(\pi)+\lambda\ell_U+c_1}$. In particular the power posterior puts at most $2^{-(\lambda-1)L+\lambda\ell_U+c_1}$ on all programs of length ≥ L, on every data set.

*Proof.*
* (i) $J_\lambda(\pi_U)=\lambda\ell_U-\log U(D)\le\lambda\ell_U+c_0+k-\log\nu(D)<\lambda k-\log\nu(D)=J_\lambda(\pi_\nu)$.
* (ii) $\sum_{\pi\in A}2^{-\lambda\ell(\pi)}P_\pi(D)\le2^{-(\lambda-1)\min_A\ell}\xi_1(D)\le2^{-(\lambda-1)\min_A\ell+c_1}U(D)$. The normaliser is at least $2^{-\lambda\ell_U}U(D)$. ∎

Compare Theorem 4.
* In a shared class, the steeper posterior lives, up to $2^{-s}$, on programs of length at most $(\lambda\ell_U+c_1+s)/(\lambda-1)$, **whatever the data**.
* In the product class, it concentrates on ν-equivalent samplers, whose length is at least the shortest ν-equivalent program's, and that is unbounded over ν.
* Predictively both converge to ν's predictions: $U$ learns ν, by Theorem 1(d) and Solomonoff's bound. The difference is *what the selected hypothesis is*:
  * a sampler of ν (a model plus private noise);
  * or a short universal learner that contains no model of ν at all.

**Example 3.4 (noisy parity, full table) [computed: c4(C)].**
* *Instance.* $d=12$, $n=4096$; the labels are a random parity with i.i.d. flips at rate 1/8 (509 flips).
* *Classes.* The product class contains the coin, parity-plus-noise samplers ($\ell=24.2$) and the memoriser (the good model plus the flip set). The shared class adds $U$, the Bayes mixture over all parities and noise rates, with $\ell_U=12$.
* *Results.*
  * The product-class MAP is the sampler at λ = 1, 1.1, 1.5, 2, 3 and 6.
  * At λ = 1 the memoriser is only 8.2 bits worse: a tie up to $O(\log n)$.
  * The shared-class MAP is the sampler for λ < 1.315 and $U$ for λ > 1.315.

### 3.5 Relation to algorithmic statistics

**Definitions** [known: Gács, Tromp & Vitányi 2001, *IEEE Trans. IT* 47(6):2443–2463; Vereshchagin & Vitányi 2004, *IEEE Trans. IT* 50(12):3265–3290; Vereshchagin & Shen 2017, "Algorithmic statistics: forty years later", in *Computability and Complexity*, LNCS 10010, 669–737 (all verified); the content below is standard, but exact statements were not checked against the papers].

For a string $z$, a *set model* is a finite set $S\ni z$, with two-part length $K(S)+\log|S|$.
* *Kolmogorov structure function*: $h_z(\alpha):=\min\{\log|S|:S\ni z,\ K(S)\le\alpha\}$. Kolmogorov's 1974 Tallinn talk, as reported in these papers.
* *Sufficiency line*: $K(S)+\log|S|\ge K(z)-\kappa$ for every $S\ni z$. *Proof:* $K(z\mid S)\le\log|S|+\kappa$, since $|S|$ is known from $S$, and (F3).
* $S$ is *c-sufficient* if $K(S)+\log|S|\le K(z)+c$ (GTV 2001's algorithmic sufficient statistic).
* A *minimal sufficient statistic* (MSS) minimises $K(S)$ among c-sufficient $S$.
* *Set sophistication*: $\mathrm{soph}^{\rm set}_c(z):=\min\{K(S):S\ni z,\ K(S)+\log|S|\le K(z)+c\}$.
  * Koppel defined sophistication with total programs [known: Koppel 1987, *Complex Systems* 1(6):1087–1091; Koppel & Atlan 1991, *Inform. Sci.* 56:23–33 (verified)].
  * Vitányi relates it to the minimal sufficient statistic in the model class of total recursive functions [known: Vitányi 2006, "Meaningful information", *IEEE Trans. IT* 52(10):4617–4626 (verified; content per abstract)].
  * Antunes and Fortnow revisit the definitions, including coarse sophistication [known: Antunes & Fortnow 2009, *Theory Comput. Syst.* 45(1):150–161 (verified bibliographically; content unverified)].
  * The equivalences between versions were not checked here. The set version is used as a definition.
* VV 2004 show (per their abstract) that the structure function determines the data's stochastic properties and can take essentially all shapes; the exact side conditions are unverified.

**Proposition 3.5 (steeper two-part codes over sets select near-minimal sufficient statistics) [proved].** Let $\lambda>1$, and let $S_\lambda$ minimise $\lambda K(S)+\log|S|$ over $S\ni z$. Then for every $c\ge0$:
* $K(S_\lambda)\le\mathrm{soph}^{\rm set}_c(z)+(c+\kappa)/(\lambda-1)$;
* $S_\lambda$ is $(c+(\lambda-1)\mathrm{soph}^{\rm set}_c(z))$-sufficient.

*Proof.*
* Let $S_c$ attain $\mathrm{soph}_c$. Then $\lambda K(S_\lambda)+\log|S_\lambda|\le(\lambda-1)\mathrm{soph}_c+K(z)+c$.
* Use the sufficiency line $K(S_\lambda)+\log|S_\lambda|\ge K(z)-\kappa$. ∎

This makes precise T5's sketch: λ = 1 is indifferent along the sufficiency line, and λ slightly above 1 selects an approximately minimal sufficient statistic.

**Definition (product versions).** For a data set $D$:
* the *product structure function* is $\rho^\times_D(\alpha):=\min\{-\log\nu_\pi(D):\ell(\pi)\le\alpha\}$;
* π is *product-c-sufficient* if $\ell(\pi)-\log\nu_\pi(D)\le K(y_D\mid\mathrm{dom}D)+c$;
* *product sophistication* is $\mathrm{soph}^\times_c(D):=\min\{\ell(\pi):\pi$ product-c-sufficient$\}$.

Lemma 1.6 is the product sufficiency line.

**Proposition 3.6 [proved].** Every λ-MAP over $\Pi_\times$ has length at most $\mathrm{soph}^\times_c+(c+\kappa)/(\lambda-1)$ and is $(c+(\lambda-1)\mathrm{soph}^\times_c)$-product-sufficient. *Proof:* as in Prop 3.5, with Lemma 1.6. ∎

**Proposition 3.7 (sets are at least as coarse as products) [proved for computable hypotheses].**
* *Claim.* Let π be product-c-sufficient for $D$, and let $\nu_\pi$ be a computable measure with rational values. Then there is a set model (conditional on $\mathrm{dom}D$) that is $(c+2\log(\rho+1)+\kappa)$-sufficient and has $K(S\mid\mathrm{dom}D)\le\ell(\pi)+2\log(\rho+1)+\kappa$, where $\rho:=\lceil-\log\nu_\pi(D)\rceil$.
* *Proof.* Take $S:=\{y':\nu_\pi(\mathrm{dom}D\mapsto y')\ge2^{-\rho}\}$. It is computable from $(\pi,\mathrm{dom}D,\rho)$, contains $y_D$, and has $|S|\le2^\rho$. ∎
* *Consequence.* $\mathrm{soph}^{\rm set}\le\mathrm{soph}^\times+O(\log)$, provided a computable product hypothesis attains $\mathrm{soph}^\times$. For lower-semicomputable hypotheses this $S$ is only c.e.; that case is open here.

**Proposition 3.8 (the two splits differ by ≈ d bits: noisy random parity) [proved; computed: c2(c), c4(C)].**
* *Setting.* Setting 2.0 with $m=d$, $n=2^d$, $p<1/4$ and $G_1>H(p)$ (true for $p<0.056$). Let $z=y^*\in\{0,1\}^n$ be the full table and $D$ the full data set, so $K(y_D\mid\mathrm{dom}D)=K(z\mid d)\pm\kappa$.
* **(i) Sets: the parity is noise.** $S_0:=\{f_{a'}\oplus1_{E'}:a'\in\{0,1\}^d,|E'|=pn\}$ has the following properties.
  * $|S_0|=2^{d+L_E}$. The map $(a',E')\mapsto$ table is injective, since a nonzero parity has weight $n/2>2pn$.
  * $K(S_0)\le2\log d+2\log r+\kappa$.
  * $K(z)\ge K(a,E)-\kappa\ge d+L_E-\delta_E-\kappa$.
  
  So $S_0$ is $(\delta_E+2\log d+2\log r+\kappa)$-sufficient, and $\mathrm{soph}^{\rm set}_c(z)\le2\log d+2\log r+\kappa$ for such $c$.
  * The set models $S_u$ that know $d-u$ bits of $a$ all have two-part length $d+L_E+O(\log d)$: the set structure function lies on the sufficiency line from $\alpha=O(\log d)$ on [computed: c2(c): flat totals].
  * By Prop 3.5, every λ-optimal set model with $\lambda>1$ knows at most $O(\log d)+(\delta_E+O(\log d))/(\lambda-1)$ bits of $a$, since $K(a\mid S)\ge d-K(S)-\kappa$.
* **(ii) Products: the parity is model.** For $\delta_E+2\log d+\kappa_g+\log(n+1)+\kappa\le c<n(G_1-H(p))-d-2\log n-\kappa$:
  $$d-4-\Lambda_1\ \le\ \mathrm{soph}^\times_c(D)\ \le\ d+\kappa_g.$$
  The product structure function satisfies $\rho^\times(\alpha)\ge nG_1$ for $\alpha<d-4-\Lambda_1$: a kink at $\alpha\approx d$.
  
  *Proof.*
  * Upper bound: the good model's two-part length is at most $d+\kappa_g+L_E+\log(n+1)\le K(z\mid d)+\delta_E+2\log d+\kappa_g+\log(n+1)+\kappa$, using $K(z\mid d)\ge K(z)-2\log d-\kappa\ge d+L_E-\delta_E-2\log d-\kappa$.
  * Lower bound: a product-c-sufficient π with $T(\pi)\ge2$ would have $\ell+nR\ge nG_1>K(z\mid d)+c$ by Lemma 2.2 (with $B=\infty$). Here $K(z\mid d)\le d+nH(p)+2\log n+\kappa$, using the memoriser program. So $T(\pi)=1$, and (D1) applies.
  * The kink: $\ell<d-4-\Lambda_1$ forces $T\ge2$ by (D1), hence $R\ge G_1$.
* **(iii)** The gap $\mathrm{soph}^\times-\mathrm{soph}^{\rm set}\ge d-O(\log d)$ is unbounded in $d$.

**Reading.**
* With shared randomness (sets, or any shared model), a uniformly random $d$-bit parameter costs the same in the model as in the data-to-model code. That is Hänni's "1 bit paying for 1 bit". So algorithmic statistics' minimal sufficient statistic treats the parity's parameter as *noise*, and the sophistication of a noisy random parity is $O(\log d)$.
* With private randomness the parameter cannot be moved into the noise: not knowing it costs about one bit *per input*. So the product split keeps it in the model.
* For supervised learning the product split is the relevant one. "The model" is the part of the description reused across inputs.
* This is also why steeper simplicity is useless over set models in the parity example (T5 Thm 2.5(a); Prop 3.8(i)) and decisive over product models (Thm 2, Cor 2.5).

### 3.6 What is new

* **Known:**
  * two-part codes and MDL;
  * the structure function, sufficient statistics, the MSS and sophistication (with the citations above);
  * tempered, fractional and generalised posteriors and their consistency theory;
  * Solomonoff's and Bayes' dominance bounds;
  * Kakutani's dichotomy;
  * Ville's inequality;
  * k-wise independent hashing.
* **New relative to the literature, as far as could be checked by search** (only snippets were available; a deeper check is needed before publication):
  * steeper simplicity analysed in function induction with *private* randomness, against classes with a universal element (Thm 1 versus Prop 1.3, Cor 1.4);
  * the exact model/randomness theorems: Thm 3 (λ = 1), Thm 4 (fixed λ > 1, via Ville and a Kakutani-type argument, for adaptive inputs) and Thm 5 (shared classes);
  * the product structure function, product sufficiency and product sophistication, and the ≈ d gap to the set notions (Prop 3.8);
  * Theorem 2's systematic-error (junta) instance with Hänni's numbers, including:
    * the information-theoretic identification (d);
    * the error-label bound (e);
    * the memoriser regime and the sharp lower end (iii)–(iv);
    * the all-hypothesis rate-blindness criterion (Prop 2.11(ii)).
* **Already in T5** (this project's earlier note, re-derived here):
  * per-input pricing;
  * the sequence pathology threshold;
  * the kink for full-table parity with random errors and its window;
  * the flatness of shared mixtures;
  * the hull lemma, rate thresholds, guard erosion, non-identifiability and block universality.

---

## 4. Other results

**Proposition 4.1 (labelled history restores universality; T5 Prop 2.6, re-derived) [proved; computed: c5(d)].**
* *Setting.* Suppose a hypothesis's input at position $i$ of a block contains the block's earlier labelled pairs. Let $(\nu_\theta)$ be a uniformly computable family of history-dependent "personas" with computable weights $w$.
* *Claim.* The in-context Bayes mixture $h_w$ is a single hypothesis with $\ell(h_w)\le K(w,(\nu_\theta))+\kappa$. On every block,
$$\sum_i-\log h_w(y_i\mid\cdot)=-\log\frac{\sum_\theta w_\theta\prod_i\nu_\theta(y_i\mid\cdot)}{\sum_\theta w_\theta}\le\min_\theta\Big[\log\frac1{w_\theta}+\sum_i-\log\nu_\theta(y_i\mid\cdot)\Big].$$
  So it pays $\log(1/w)$ per block, not per input.
* *Proof.* The predictive is $Z_{i+1}/Z_i$ with $Z_i:=\sum_\theta w_\theta\prod_{k<i}\nu_\theta(\cdot)$, and the product telescopes. Checked to $3.6\cdot10^{-15}$ over 2000 random instances with history-dependent inputs. ∎

**Proposition 4.2 (history of inputs only, private randomness) [proved].**
* *Claim.* Suppose a hypothesis sees the earlier *inputs* but not the earlier labels, and draws fresh randomness for each extended input $(x_{<i},x_i)$. This is the SFI^hist of brief H4, with private randomness. Then it is a product hypothesis on the extended input space. Extended inputs are pairwise distinct, so Prop 1.3 and Cor 1.4 apply verbatim: per-input pricing persists.
* *With shared randomness instead,* as in H4's conjecture that SFI^hist matches the chronological semimeasure, a universal element exists. Theorem 1 then applies whenever (Dom) holds.
* So the property that makes SFI^hist "as good as SI" (shared randomness) is the property that removes the steeper-simplicity benefit.

**Remark 4.3 (why neither form of steepness splits model from randomness in SI's program representation) [proved].**
* Solomonoff's $M$ is a mixture over deterministic programs.
* The tempered likelihood does not change deterministic hypotheses (Lemma 1.1(iii)). So the tempered posterior on $M$'s programs is the plain posterior.
* A power prior $2^{-\lambda|p|}$ charges sampled bits and model bits alike, since both are program bits. So it is indifferent between two decompositions with the same total length, e.g. "μ-decoder + code of the randomness" and a literal fill-in of the same length.
* The split needs a representation in which the randomness is not part of the program. That is a product hypothesis with private coins.

**4.4 Fixed λ versus λ ∝ N: summary [proved, from Thms 2 and 4 and Prop 2.9].**
* With **fixed** λ > 1, SFI with private randomness identifies any computable product teacher exactly and never memorises its noise (Thm 4). It eventually learns every finite-complexity regularity, systematic errors included (Prop 2.9(b)).
* With **λ = cN** it additionally discards components whose rate is below $c$, such as Hänni's error rule. Valid components below the rate are discarded too (Prop 2.12).
* SI and shared-randomness SFI do neither. At any λ > 1 their selected hypotheses have length at most $(\lambda\ell_U+c_0)/(\lambda-1)$ on all data and fit almost as well as $U$ (Thm 1). In particular, samplers with $(\lambda-1)k>\lambda\ell_U+c_0$ are never selected (Thm 5).
* *The price.* The steeper Bayes predictor has regret $\lambda\ell(\pi)$ against each π, i.e. $c\,\ell(\pi)$ per sample when $\lambda=cN$. By Prop 2.14 this price cannot be seen by any proper-score validation, and in the twin worlds it cannot be justified from imitation data.

**4.5 Open problems.**
1. *Kinks beyond parities.* Which simple-model classes give a window? Parities do, via list decoding. Majority-like functions should not, since short approximations exist; this is T5's open problem 1.
2. *Sharper identification constants*, for example a version of T5's Lemma 2.5c (randomness of $E$ relative to the hypothesis) for the junta case. This would push the error-label bound toward $1-u\approx0.02$ at Hänni's sizes, and extend the window method beyond $p<0.056$.
3. *Lower-semicomputable hypotheses in Prop 3.7.*
4. *Resolved by the foundations track.* Theorem 1 applies to the weak class (with $U=M^w$, F Thm 3.4) and to machine laws (with $U=M_F$, F Thm 3.2). Still open: whether every lower-semicomputable random-partial-function law is a member of a class with (Dom) up to a constant (F Problem 3.6). This matters only for which hypotheses count as "shared".
5. *A principled, data-free choice of c* (T5's open problem 3).

---

## 5. Hänni's specific claims, checked

| His claim (grokking note, messy notes) | Verdict |
|---|---|
| Sequence case: "it'll be better to drop bits and take the likelihood loss"; "a universal hypothesis ... starts to predict the human errors" | **Confirmed** (Thm 1(a), (c), (d); Prop 2.9(c)). |
| "this pathology is maybe not present in function solomonoff ... if each input has to sample its own random bits" | **Confirmed**: no product hypothesis is universal (Prop 1.3, Cor 1.4); in his example the selected hypothesis is the good model (Thm 2). **Qualified**: it fails when inputs carry labelled history (Prop 4.1). |
| "maybe I'm just failing to construct the right universal hypothesis" | **Settled** for the instance: Theorem 2 quantifies over all product hypotheses. |
| His three hypotheses and numbers | **Confirmed** [computed: c1]. "≈ p log(1/p) ≈ 1/100" is 0.0098 against the exact 0.0112; immaterial. |
| "the good model could be a vertex of the convex hull ... picked out by some loss of the form described (even in the limit of many data points, though we will need to increase the hypothesis term coefficient ... as the data set size increases)" | **Confirmed**: Lemma 1.2; λ = cN is necessary for systematic errors (Prop 2.9(b)); the window is $(2^{-m},c_{\rm hi}]$. A vertex is needed, not just a hull point, and no other hypothesis may sit at the same point. |
| "alternatively: just set abs bound on model complexity ... in a sense equivalent to the previous proposal" | **Confirmed** on hull vertices (Lemma 1.2(iv)). |
| "look at how many bits of entropy are left given the hypothesis ... some point at which the derivative changes ... (this doesn't show up in the seq case because there it's ... 1 bit paying for 1 bit)" | **Confirmed**: the product structure function has a kink at the simple model, while the set/shared one lies on the sufficiency line (Prop 3.8, T5 Thm 2.5). |
| "It seems plausible that some other pathology is present" | **Yes**: rate blindness (cheap frequent errors are learned and rare valid rules lost), guard erosion, non-identifiability of λ, block universality (§2.6, §4). |
| "solomonoff doesn't have a preference here, both get similar posterior" (sampler vs filled-in bits) | **Confirmed** with explicit factors (Thm 3, Prop 3.3). |
| a stronger simplicity prior gives "a preference for a simple sampler" in SFI | **Confirmed** for every fixed λ > 1 (Thm 4). In SI the universal mixture wins instead (Thm 5). |
| "have people not already considered this for solving the model + data split problem?" | Partly: algorithmic statistics and MDL study the split with *set or shared* models, where it treats incompressible parameters as noise (Prop 3.8). The product/private-randomness split appears not to have been studied (search-level check only). |

---

## 6. Relation to T5

**Re-derived and reused, with T5's corrections kept:**
* Thm 2.1 and Prop 2.2 → Prop 1.3. The exact minimax value via Sion is kept, along with the 2.5431 example.
* Prop 2.3 → Thm 1(a), with the same threshold.
* Thm 2.4 → Remark 1.5.
* Lemma 2.5a → Lemma 2.1, generalised to semimeasures through the lower-semicomputable agreement $u$.
* Lemma 2.5b → Lemma 2.2, with truncation.
* Thm 2.5(a) → Prop 3.8(i), in a general form: *every* λ-optimal set model knows at most $O(\log d)+(\delta_E+O(\log d))/(\lambda-1)$ bits of $a$.
* Thm 2.5(c) → Lemma 2.4(D2), with T5's corrected $2\log d$ term.
* Thm 3.5 and Cor 3.5a → Cor 2.5. This adds the (d) and (e) identification and fixes $c_{\rm hi}$ when $t^*<2$.
* T5 Lemma 1.2 → Lemma 2.6 here: one-sided, truncated, sampling without replacement.
* T5 Lemma 3.1 → Lemma 1.2 here.
* Thm 3.2 → Prop 2.12.
* Thm 4.1 → the twin-world remark after Prop 2.12.
* Thm 4.3 → Prop 2.14.
* Prop 4.4 → Prop 2.13, with $\Delta_G$ as corrected.
* Prop 2.6 → Prop 4.1.

**Not reused (and not re-verified here):** Thm 3.3 (idealised multi-region thresholds), Cor 3.4 (all shapes for product hulls), Lemma 2.5c, §5 (coherence and postulates), Prop 4.5, (d3) and (d6).

**Corrections relative to T5 found here:** none of substance.
* T5's window for $d=20$ was stated as "≈ 0.049 up to O(log) slack". The rigorous value from Theorem 2 with κ = 0 is $c_{\rm hi}=0.0114$. The heuristic value 0.049 ignores the $2\log d$ terms, which are of the same size as $d$ at $d=20$.

**New here:**
* the systematic (junta) error instance with Hänni's numbers;
* the error-label bound and the information bound;
* the memoriser regime and the sharp lower end;
* the all-hypothesis rate-blindness criterion;
* Theorem 1(c3) and (d);
* the power-posterior concentration (Prop 2.8);
* all of §3 except the parity flatness;
* Props 4.2 and 4.3.

---

## References

"(v)" means the bibliographic data were verified by web search; "(cu)" means the content was not checked against the source.

* Antunes, L., Fortnow, L. (2009). Sophistication revisited. *Theory Comput. Syst.* 45(1):150–161. (v, cu)
* Barron, A. R., Cover, T. M. (1991). Minimum complexity density estimation. *IEEE Trans. IT* 37(4):1034–1054. (v, cu)
* Bhattacharya, A., Pati, D., Yang, Y. (2019). Bayesian fractional posteriors. *Ann. Statist.* 47(1):39–66. (v, cu)
* Bissiri, P. G., Holmes, C. C., Walker, S. G. (2016). A general framework for updating belief distributions. *JRSS-B* 78(5):1103–1130. (v, cu)
* Cover, T. M., Thomas, J. A. *Elements of Information Theory* (binomial bounds). (standard)
* Gács, P., Tromp, J., Vitányi, P. (2001). Algorithmic statistics. *IEEE Trans. IT* 47(6):2443–2463. (v, cu)
* Gneiting, T., Raftery, A. E. (2007). Strictly proper scoring rules, prediction, and estimation. *JASA* 102(477):359–378. (v)
* Goldreich, O., Levin, L. A. (1989). A hard-core predicate for all one-way functions. STOC. (standard)
* Grünwald, P. (2012). The safe Bayesian: learning the learning rate via the mixability gap. ALT, LNCS 7568:169–183. (v, cu)
* Grünwald, P., van Ommen, T. (2017). Inconsistency of Bayesian inference for misspecified linear models, and a proposal for repairing it. *Bayesian Analysis* 12(4):1069–1103. (v, cu)
* Hoeffding, W. (1963). Probability inequalities for sums of bounded random variables. *JASA* 58:13–30, Thm 4. (v via secondary sources)
* Kakutani, S. (1948). On equivalence of infinite product measures. *Ann. Math.* 49:214–224. (v)
* Koppel, M. (1987). Complexity, depth, and sophistication. *Complex Systems* 1(6):1087–1091. (v, cu)
* Koppel, M., Atlan, H. (1991). An almost machine-independent theory of program-length complexity, sophistication, and induction. *Inform. Sci.* 56:23–33. (v, cu)
* Kushilevitz, E., Mansour, Y. (1993). Learning decision trees using the Fourier spectrum. *SIAM J. Comput.* 22(6). (standard)
* Li, M., Vitányi, P. (2008). *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed. (standard facts F1–F5)
* Poland, J., Hutter, M. (2005). Asymptotics of discrete MDL for online prediction. *IEEE Trans. IT* 51(11):3780–3795. (v, cu)
* Sion, M. (1958). On general minimax theorems. *Pacific J. Math.* 8:171–176. (standard)
* Solomonoff, R. J. (1978). Complexity-based induction systems: comparisons and convergence theorems. *IEEE Trans. IT* 24:422–432. (v; exact constant cu)
* Vereshchagin, N., Shen, A. (2017). Algorithmic statistics: forty years later. In *Computability and Complexity*, LNCS 10010:669–737. (v, cu)
* Vereshchagin, N., Vitányi, P. (2004). Kolmogorov's structure functions and model selection. *IEEE Trans. IT* 50(12):3265–3290. (v, cu)
* Ville, J. (1939). *Étude critique de la notion de collectif*. (standard)
* Vitányi, P. (2006). Meaningful information. *IEEE Trans. IT* 52(10):4617–4626. (v, cu)
* Zhang, T. (2006). From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation. *Ann. Statist.* 34(5):2180–2210. (v, cu)

---

## Verification log

**Method.**
* Every proof above was written out in full and re-checked step by step.
* Every T5 result that is reused was re-derived, not copied. T5's own scripts c1–c3 were re-run in a scratch directory and reproduce T5's numbers.
* Every number quoted here comes from this track's scripts, run with fixed seeds. Outputs are saved as `checks/*.out`.
* No independent referee has read this track yet. The parallel tracks may serve as one.

**Scripts and what they check.**
* `c1_hanni_numbers.py`: both versions of Hänni's calculation, the windows, the N at which λ = 1 switches, $H(2^{-10})$ against $p\log(1/p)$, and $L_S$ for the instances. Deterministic.
* `c2_pricing_kink.py` (seed 2):
  * (a) per-input pricing over parities: $N$ against $d$ bits; the minimax example (2.5431 by two methods);
  * (b) for 400 random semimeasure hypotheses, the identity $u=(\mathbb E m+\hat s)/2$, the list-size bound and the risk floor (Lemma 2.2, including truncation): 0 violations;
  * (c) the kink instance: product list mixtures against flat shared and set-model totals.
* `c3_junta_window.py` (seed 3):
  * the sanity inequalities: $s(t)\le4t$; binomial bounds; $\log(1+x)\le x/\ln2$; 0 violations of the concavity reduction in 2830 instances; Hoeffding without replacement;
  * the crossover $G_1=H(p)$ at $p=0.0560$;
  * windows for κ ∈ {0, 30};
  * the identification bounds (a)–(e) on a grid;
  * the memoriser regime;
  * rate blindness, in the three-hypothesis and all-hypothesis forms;
  * Lemma 2.6 numbers;
  * the λ = 1 MAP error-label bounds;
  * an exact small instance.
* `c4_model_vs_randomness.py` (seed 4):
  * (A) Ville's inequality, 4000 runs;
  * (B) the hashing lemma, exact over GF(16);
  * (C) noisy parity: product against shared MAPs and the λ threshold 1.315.
* `c5_limits.py` (seed 5):
  * (a) separable thresholds (8000 tests) and the hull lemma (300 random sets): 0 violations;
  * (b) guard-erosion paths;
  * (c) proper scores and held-out selection;
  * (d) block telescoping ($3.6\cdot10^{-15}$);
  * (e) the power-posterior bound.

**Self-check items, each resolved.**
1. Lemma 2.1 originally used $\hat s$, which is not computable for semimeasures. It was replaced by the lower-semicomputable $u$ with an enumeration argument.
2. Theorem 2(i)'s $c_{\rm hi}$ had to be corrected for $t^*<2$. There the first piece of the minimum is unnecessary, and $c_{\rm hi}=(G_1-H(p))/(d+\kappa_g)$. The formula and the script now match.
3. Theorem 2(ii)(b) needed the case $R_B\ge B_S/2^m$ handled separately; it is.
4. The tempered-likelihood posterior with $\lambda=cN$ is a fixed Gibbs measure that need not concentrate. No concentration claim is made for it; Prop 2.8 is for the power prior only.
5. Theorem 5(ii) first summed over "all programs computing ν", which is not a c.e. set. It now bounds any set of programs via $\xi_1$.
6. The window method fails for $p\ge0.056$. This is stated as a limitation and not hidden. The rate-blindness examples for larger $p$ use Prop 2.11, which does not need $G_1>H(p)$.
7. The finite-sample statement uses sampling without replacement, so the data are partial functions as SFI requires.

**Claims by status.**
* *Proved:* Lemmas 1.1, 1.2, 1.6, 2.1–2.4, 2.6, 3.1, 3.2; Theorems 1–5; Props 1.3, 2.8, 2.9, 2.11–2.14, 3.3, 3.5–3.8, 4.1, 4.2; Cors 1.4, 2.5, 2.7; Remarks 1.5, 4.3.
* *Computed:* all numerical statements in §§2–3 (c1–c5).
* *Known with references:* the facts F1–F5, Sion's minimax theorem, Hoeffding's bound without replacement, Ville's inequality, Kakutani's dichotomy, Solomonoff's bound, Parseval list decoding, and the definitions and results of algorithmic statistics. Bibliographic data were verified by search; most content was not checked against the sources (marked cu).
* *Conjectures:* none stated as results. The open problems are in §4.5.
* *Refuted:* none of Hänni's claims. One of T5's informal numbers was sharpened: the $d=20$ upper end of the window.
