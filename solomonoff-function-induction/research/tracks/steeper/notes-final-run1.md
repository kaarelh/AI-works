# Track "steeper": steeper simplicity in Solomonoff function induction (final notes)

*Brief item H9: the teacher's-mistakes trick and the model-vs-randomness split. This file revises `notes.md` after the referee report `referee.md`. It is self-contained and supersedes `notes.md`, which is kept unchanged as the record of the first version. §7 lists every referee item and what was done about it.*

* **Sources.**
  * Hänni's note `prior/hanni-grokking-a-notion.md`, especially its "messy notes", and the LessWrong thread `prior/hanni-lesswrong-comment-thread.md`, which contains Cole Wyeth's objection and Hänni's reply with his numbers. The two texts agree; the thread is quoted where it is more precise.
  * The earlier formalisation `../../inferential-learning/research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md` ("T5") and its scripts. Every T5 result used here is re-derived below. §6 lists what is reused, corrected and new.
  * The other tracks' notes (`../foundations/notes.md` "F", `../history/notes.md`, `../context/notes.md`, `../examples/notes.md`). No track had a `notes-final.md` when this file was written. §8 aligns the definitions.
* **Scripts.** `checks/c1`–`c6`, seeded or deterministic, outputs saved next to them as `.out` files. `c3` and `c5` were corrected in this revision and re-run; `c6` is new. `checks/t5_rerun/` holds the saved re-run of T5's scripts c1–c3. The referee's independent scripts are in `referee_code/` and are cited where they are the only check.

**Status tags.**
* **[proved]**: full proof here.
* **[computed: cN]**: checked by `checks/cN`; the output is in `checks/cN*.out`.
* **[known: ref]**: standard or published result. "(verified)" means the bibliographic data were confirmed by web search. "(content unverified)" means the statement could not be checked against the source, because only search snippets were available (arxiv.org, cwi.nl, ar5iv and similar hosts do not resolve here). "(snippet)" means a search snippet confirmed the specific content quoted.
* **[proof sketch]**, **[conjecture]**, **[open]**, **[refuted]**: as named.
* **Illustration (κ = 0)**: a number obtained by setting the unknown machine constant κ to 0. Such numbers are not proved; robust versions are given where they exist.

All logarithms are base 2 unless written ln. κ denotes a constant that depends only on the reference machine and on the fixed programs built in the proofs. It never depends on $d,m,p,N$, the data or the hypotheses, and different occurrences may differ.

---

## 0. Summary

Hänni's proposal, in his words: penalise "the length of the program plus the negative log likelihood ... but with a higher coefficient on the length of the program", in *function* induction where "each input gets its own private randomness". The hope is that the selected hypothesis is "simple model + noise" rather than "model + memorised errors". Cole Wyeth objected that "I can just choose a hypothesis that is a universal distribution which penalizes complexity minimally as usual". Hänni replied that with private randomness he did not see how to write such a hypothesis down.

1. **Wyeth's objection, and why private randomness answers it (§1).**
   * *Absorption* (Thm 1) [proved]. This is Wyeth's objection made exact. Take any hypothesis class that contains its own Bayes mixture $U$ as one member of length $\ell_U$. Examples: Solomonoff induction (SI); SFI with shared randomness, i.e. machine laws with $U=M_F$; the weak class with $U=M^w$; history-aware SFI with $U=M_H\asymp$ Hutter's ξ. For every $\lambda>1$ and every data set:
     * every λ-MAP has length at most $(\lambda\ell_U+c_0)/(\lambda-1)$, a bound that does not depend on the data;
     * the λ-MAP's log-loss on the data is at most $\lambda\ell_U$ bits worse than $U$'s;
     * the steeper Bayes code length is within $\lambda\ell_U$ bits of $U$'s.
     
     So for fixed λ and a deterministic teacher, errors included, the selected hypothesis and the steeper posterior reproduce all but finitely many of the teacher's labels.
   * *No universal product hypothesis* (Prop 1.3, Cor 1.4) [proved]. For every product hypothesis $\nu_U$ there are parities on which it loses $2^d-1$ bits while the parity costs $d+2\log d+\kappa$. A per-input Bayes mixture pays its $\log(1/w)$ again at every input (Prop 1.3(iii)).
   * *The price of private randomness* (Prop 1.7) [proved; new]. Product hypotheses cannot express a latent random cause shared by several inputs.
     * At λ = 1 this costs at most $K(\mathrm{dom}D)+O(1)$ bits against $M_F$ (F Thm 4.2), and the loss is unbounded in the worst case (F Prop 4.5).
     * At λ > 1 it costs a constant factor. On $k$ pairs of inputs that share one fair coin per pair, every steeper product predictor pays at least $\min(\lambda,2)(K(\beta\mid k)-\kappa)$ bits, where β lists the coins. $M_F$ pays at most $k+\kappa$.
   * *Answer to Wyeth* (§1.8). His construction works for SI and for SFI as the foundations track defines it ($M_F$). It is unavailable in the product class (Cor 1.4). The cost of that restriction is Prop 1.7. Labelled history restores the construction (Prop 4.1). The algorithmic-statistics reading he points to is Prop 3.8.
   * So steeper SFI is *defined* over product hypotheses: x-only samplers, the foundations track's $M_{\rm prod}$-type hypotheses. This is a modelling choice, not a technicality: "the model" is what is reused across inputs, and "the noise" is private to each input.
2. **The teacher's-mistakes trick (§2).**
   * *Hänni's numbers* [computed: c1]. His second version gives $c=\lambda/N\in(1.12\cdot10^{-6},\,8.99\cdot10^{-3})$. His "≈ p log(1/p) ≈ 1/100" is 13% below the exact $H(2^{-10})=0.0112$; this is immaterial.
   * *A rigorous instance with his numbers* (Thm 2) [proved].
     * The simple model is a random parity on $\{0,1\}^{100}$ ($d=100$ bits). The systematic error is a random rule on the first $m=20$ input bits with density $p=2^{-10}$; it takes $L_S=11{,}710$ bits ("10000 bits").
     * The theorem quantifies over **all** product hypotheses; its lower bounds hold in every c.e. prefix-free product class (§4.5). For $c$ in an explicit window $(2^{-m},c_{\rm hi}]$:
       * the good model is optimal up to an explicit slack;
       * every near-optimal hypothesis agrees with the parity on more than 3/4 of the inputs on average (at least 0.98 at $c=10^{-4}$, κ = 0);
       * every near-optimal hypothesis holds little information about the error rule beyond the parity: $I\le37.7$ bits at κ = 0 and $I\le98.3$ bits at κ = 30 ($c=10^{-4}$), out of $L_S=11{,}710$. Against $L_S$ itself add the randomness deficiency $\delta_S$ of the rule, which exceeds $j$ with probability below $2^{-j}$;
       * on error inputs, every near-optimal hypothesis gives the teacher's erroneous label average probability at most 0.199 (κ = 0, $\delta_S=0$), 0.218 ($\delta_S=20$) or 0.274 (κ = 30). For $m=24$ the bound is 0.065. The memoriser gives 1 and the good model $2^{-10}$.
     * The window is $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ for κ = 0 and $(9.54\cdot10^{-7},3.66\cdot10^{-3}]$ for κ = 30 [computed: c3].
     * The lower end $2^{-m}$ is sharp to a factor $1+O((m+\log d+\kappa)/L_S)$. Below it, near-optimal hypotheses reproduce the errors, under the explicit condition of Thm 2(iii).
     * With $m=d$ (idiosyncratic errors, full truth table) the window is $\lambda\in(1,1.19\cdot10^4]$ at $d=20$, κ = 0. At λ = 1 the good model and the memoriser tie to $O(\log n)$.
   * *Hänni's first version, realised* (Example 2.7a) [proved; computed: c6]. At $d=100$, $m=10$, $p=2^{-6}$ ($L_S=116$ bits) the population window is $c\in(9.8\cdot10^{-4},5.8\cdot10^{-3}]$ at κ = 0. At $N=10^4$ this is $\lambda\in(9.8,58]$, against his $(10,100)$. The window is nonempty up to κ = 30. Only coarse identification is proved at this size.
   * *Plain Bayes and SI learn the errors* (Prop 2.9) [proved].
   * *Limits* (§2.6).
     * (a) A fixed λ does not work: systematic errors are eventually learned. λ must grow like $N$.
     * (b) *Rate blindness* (Prop 2.11). For a fixed error rule and any machine constant κ, the all-hypothesis criterion holds for every $d\ge d_0(\kappa)$, with $d_0$ linear in κ (Lemma 2.11a). Examples: a 3-bit rule on 1/8 of the inputs has $d_0=49$ at κ = 0 and $d_0=169$ at κ = 30; a single 6-bit prefix has $d_0=450$ and $1005$ [computed: c6].
     * (c) Guard erosion; (d) λ cannot be chosen from imitation data; (e) labelled history restores universality.
     * (f) The window depends on the input law (Prop 2.15).
     * (g) *OOD* (Prop 2.16). Steeper simplicity removes Hänni's constant-probability OOD lower bound: it becomes $2^{-\lambda(K(Q,b)+\kappa)}$. It does so only by sharpening the preference for the shortest train-fitting hypotheses, whatever they do on the unseen inputs.
     * (h) The proof method needs $p<0.056$.
3. **The model-vs-randomness split (§3).** Take a sampler ν of length $k$. "Fill-ins" are deterministic programs that reproduce the sampled labels.
   * *λ = 1* (Thm 3, Prop 3.3) [proved]. In SFI the posterior odds of the fill-ins against the sampler program lie in $[2^{-2\log(N+1)-2\log(n+1)-2\log(r+1)-\kappa},\,2^{k+m^*}]$, whatever the amount of sampled randomness. This is for dyadic samplers that read $r$ bits, on inputs of length at most $n$. $m^*$ is a Ville deficiency with $\Pr[m^*\ge m]\le2^{-m}$. In SI the same holds with $K(n)$ in place of the logarithms. This is Hänni's "both get similar posterior", made precise.
   * *λ > 1, private randomness* (Thm 4) [proved]. This holds in every countable product class with Kraft weights.
     * For all $N$, every λ-MAP has length at most $(\lambda k+m^*)/(\lambda-1)$.
     * The fill-ins' posterior is at most $2^{\lambda k+\lambda m^*-(\lambda-1)(-\log\nu(D_N))}$. This decays exponentially in the sampled randomness; it is not zero.
     * If infinitely many distinct inputs are seen, then almost surely every λ-MAP is eventually ν-equivalent on the run, and the power posterior concentrates on ν-equivalent hypotheses. Inputs may be adaptive.
   * *λ > 1, shared randomness or SI* (Thm 5) [proved]. The universal mixture beats every sampler with $(\lambda-1)k>\lambda\ell_U+c_0$. No split is made.
   * *Algorithmic statistics* (§3.5).
     * Steeper two-part codes over finite sets trade off sophistication against sufficiency (Prop 3.5). The product analogue holds (Prop 3.6).
     * For a noisy random parity the two splits differ by about $d$ bits (Prop 3.8). Set sophistication is $O(\log d)$: the parity's parameter is treated as noise. Product sophistication is $d\pm O(\log n)$.
     * That restricting the model family changes the structure function is known. Hamming-ball models (Vereshchagin–Vitányi 2010) are the closest case. New here, as far as a snippet-level search can tell, is only the product (private-randomness) family on partial data and its link to SFI.
4. **Other results (§4).**
   * Labelled history restores universality (Prop 4.1). A history of *inputs* with private randomness does not (Prop 4.2).
   * Tempering the likelihood leaves deterministic hypotheses unchanged (Remark 4.3).
   * *Fixed λ versus λ ∝ N* (§4.4). With λ = cN the steeper predictor is not a single Bayesian predictor. Its guarantees are batch statements at each $N$.
   * *Computable versions* (§4.5).
     * Theorems 2 and 4 hold in any c.e. prefix-free product class, for example time-bounded samplers or circuits with private output noise. Each class has its own constants (Prop 4.4).
     * The steeper predictive is lower semicomputable and not computable (Prop 4.5).
     * Cold posteriors in Bayesian deep learning sharpen prior and likelihood together. They are not the λ > 1 direction (Remark 4.6).

---

## 1. Setup

### 1.1 Data and hypotheses

This section follows the foundations track's definitions (F §1–§5). §8 gives the correspondence.

* $X=\{0,1\}^*$. Statements about a fixed input length use $\{0,1\}^d\subseteq X$; asymptotic statements need infinitely many distinct inputs, and $X$ is infinite. $Y$ is a **finite** label set with $|Y|\ge2$; in the examples $Y=\{0,1\}$.
* A **data set** is a finite partial function $D:X\rightharpoonup Y$, with domain $\mathrm{dom}\,D=\{x_1,\dots,x_N\}$ (distinct) and $y_i=D(x_i)$.
  * In SFI the target is a function, or a random function sampled once. A repeated input therefore carries no new label, and all data sets here are partial functions.
  * The other case, fresh noise on repeated queries, makes plain SFI's loss infinite with positive probability (F Prop 6.8). All noisy examples below draw each label once per distinct input ("frozen noise", F Thm 6.7(c)).

**Definition 1.1 (product law; private randomness).** A *product hypothesis* is a lower-semicomputable conditional semimeasure $\nu(y\mid x)$: $\nu\ge0$, $\sum_y\nu(y\mid x)\le1$, and $\{(x,y,q):q<\nu(y\mid x)\}$ is c.e.
* It describes a random partial function $F$ whose values $F(x)\sim\nu(\cdot\mid x)$ are independent across distinct $x$, with $F(x)$ undefined with probability $1-\sum_y\nu(y\mid x)$. Operationally, it is a probabilistic machine that on input $x$ uses fresh coins of its own (F Prop 3.3(a)).
* Its likelihood is the product law $\nu(D):=\prod_{x\in\mathrm{dom}D}\nu(D(x)\mid x)$.
* Its prediction at a new input $x$ is $\nu(\cdot\mid x)$, which does not depend on $D$.
* It is *deterministic* if every $\nu(\cdot\mid x)$ is a point mass or zero, i.e. a partial computable function $f$. Then $\nu(D)=1$ if $f\supseteq D$, and $0$ otherwise.

**Definition 1.2 (shared hypothesis).** A *shared hypothesis* is a lower-semicomputable **weak function semimeasure** (F Def 2.1): a map $P$ from data sets to $[0,1]$ with $P(\emptyset)\le1$ and $\sum_yP(D\cup\{(x,y)\})\le P(D)$ for $x\notin\mathrm{dom}D$.
* Its prediction is $P(y\mid x,D):=P(D\cup\{(x,y)\})/P(D)$.
* Examples: machine laws, i.e. laws of random partial functions generated by a function machine reading **one** random tape for all inputs (F Def 2.5; brief H1(a)); Bayes mixtures $\sum_iw_iP_i$; every product law.
* By telescoping, $P(D_N)=P(\emptyset)\prod_{i\le N}P(y_i\mid x_i,D_{i-1})$. So a shared hypothesis's cumulative sequential log-loss is $-\log P(D_N)+\log P(\emptyset)\le-\log P(D_N)$ in every reveal order (F Prop 5.2).
* SI's hypotheses are semimeasures on strings over an interleaved encoding of $x_1y_1x_2y_2\dots$. They are *not* weak function semimeasures: they depend on the order and they assign probabilities to the inputs. Theorem 1 covers them through its observation-indexed form (§1.4).

### 1.2 Hypothesis classes and description length

**Definition 1.3 (class).** Fix a countable set $\mathcal O$ of *observations*: data sets for SFI, finite strings for SI, input–label sequences for history-aware prediction. A *hypothesis class* is:
* a c.e. prefix-free set $\Pi\subset\{0,1\}^*$ of *programs*, with $\ell(\pi):=|\pi|$;
* a family $(P_\pi)_{\pi\in\Pi}$ of maps $\mathcal O\to[0,1]$, lower semicomputable uniformly in π.

Hypotheses are programs. Two programs for the same law are different hypotheses with separate prior weights. By Kraft, $\sum_\pi2^{-\ell(\pi)}\le1$.

**Canonical classes.** Let $V$ be the fixed universal prefix machine. Take $\Pi:=\mathrm{dom}\,V$, and let $P_\pi$ be the hypothesis with index $V(\pi)$ in a fixed effective enumeration of the relevant family (with F's trimming, so that every member of the family occurs and only members occur):
* $\Pi_\times$: lower-semicomputable conditional semimeasures, $P_\pi=\nu_{V(\pi)}^{\otimes}$ (product laws). Its mixture $\xi_\times:=\sum_\pi2^{-|\pi|}P_\pi=\sum_i\mathbf m(i)\nu_i^\otimes$ **is F's $M_{\rm prod}$** (F Def 4.1), where $\mathbf m(i)=\sum_{V(\pi)=i}2^{-|\pi|}$.
* $\Pi_F$: function machines, $P_\pi=\nu_{T_{V(\pi)}}$ (machine laws). Its mixture is $M_F$ on nonempty data sets (F Thm 3.2).
* $\Pi_w$: lower-semicomputable weak function semimeasures. Its mixture is $M^w$ (F Thm 3.4).
* $\Pi_{\rm SI}$: lower-semicomputable semimeasures on strings. Its mixture is the Solomonoff–Levin $M$.
* $\Pi_{\rm chr}$: history-oracle function machines (history §4.1), with $P_\pi$ the chronological semimeasure $\rho(y_{1:n}\Vert x_{1:n})$ of machine $V(\pi)$. Its mixture is SFI$^{\rm hist}$'s $M_H$. By history Lemma 4.1 and Thm 4.2, $M_H$ is a lower-semicomputable chronological semimeasure that dominates every one, so it is itself a member and equals Hutter's ξ up to constants (history Cor 4.3). Taking $M_H$ as the universal element avoids relying on an enumeration of all chronological semimeasures, as the history track's referee suggests.

The canonical classes are closed under prefix-free simulation: for every prefix machine $V'$ whose outputs are indices of the family, there is a string ρ with $V(\rho w)=V'(w)$ for all $w\in\mathrm{dom}V'$. This is what makes the per-program sums in Lemma 3.2 and Prop 2.16 exact.

**Standing facts** [known: Li–Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed. 2008, Ch. 3–4 (section numbers unverified)].
* (F1) For every class, $K(\pi)\le|\pi|+\kappa$ for $\pi\in\Pi$, with κ depending on the class. *Proof:* the identity map on the c.e. prefix-free set Π (defined on Π, divergent elsewhere) is a partial computable function with prefix-free domain, i.e. a prefix machine; the universal machine simulates it with a fixed prefix. For canonical classes $\Pi=\mathrm{dom}V$ and this is immediate.
* (F2) *Conditional coding theorem* (Levin). If a fixed program lower-semicomputes, from $z$, a semimeasure $Q_z$ on a countable set, then $K(w\mid z)\le-\log Q_z(w)+\kappa$.
* (F3) $K(x)\le K(y)+K(x\mid y)+\kappa$, and $K(x,y\mid z)\le K(x\mid z)+K(y\mid x,z)+\kappa$.
* (F4) *Symmetry of information* (Gács; Levin): $K(x,y)=K(x)+K(y\mid x,K(x))+O(1)$.
* (F5) $K(n)\le2\log(n+1)+\kappa$, by a doubling code.

### 1.3 Objectives

For an observation $o$, a class and $\lambda\ge1$:
* **two-part (MAP) objective**: $J_\lambda(\pi;o):=\lambda\ell(\pi)-\log P_\pi(o)\in[0,\infty]$. A minimiser is a *λ-MAP*.
* **power-prior posterior**: $\Pi_\lambda(\pi\mid o):=2^{-\lambda\ell(\pi)}P_\pi(o)/\xi_\lambda(o)$, with $\xi_\lambda(o):=\sum_\pi2^{-\lambda\ell(\pi)}P_\pi(o)$. This is Bayes with the prior $2^{-\lambda\ell}$, whose Kraft sum is at most 1. For data-set classes its predictor is the shared hypothesis $\xi_\lambda$.
* **tempered (fractional) posterior**: $\Pi^\eta(\pi\mid o)\propto2^{-\ell(\pi)}P_\pi(o)^\eta$ with $\eta\in(0,1]$.

These are Hänni's two descriptions ("a higher coefficient on the length of the program"; "penalize the likelihood term less"). In the literature they appear as generalised, Gibbs, fractional or "safe" posteriors with learning rate $\eta=1/\lambda$, and as two-part MDL with a complexity weight above 1:
* Bissiri, Holmes & Walker 2016, *JRSS-B* 78(5):1103–1130;
* Bhattacharya, Pati & Yang 2019, *Ann. Statist.* 47(1):39–66;
* Grünwald 2012, ALT, LNCS 7568:169–183; Grünwald & van Ommen 2017, *Bayesian Analysis* 12(4):1069–1103;
* Zhang 2006, *Ann. Statist.* 34(5):2180–2210;
* Barron & Cover 1991, *IEEE Trans. IT* 37(4):1034–1054.

[known (verified); content unverified]. A secondary source (arXiv 2311.03852, seen as a snippet) restates the Barron–Cover risk bound for two-part MDL with a complexity weight $\alpha>1$, citing Barron & Cover 1991, Zhang and Grünwald 2007. So **λ > 1 two-part codes are standard in MDL convergence theory** and are not claimed as new here. What this track studies is how λ > 1 interacts with universal hypotheses and with private versus shared randomness.

**Lemma 1.1 [proved].**
* (i) If some $J_\lambda(\pi;o)<\infty$, the set of λ-MAPs is finite and nonempty.
* (ii) $\arg\min_\pi J_\lambda=\arg\max_\pi\Pi_\lambda(\pi\mid o)=\arg\max_\pi\Pi^{1/\lambda}(\pi\mid o)$.
* (iii) For deterministic hypotheses $P_\pi(D)^\eta=P_\pi(D)\in\{0,1\}$. So on any set of deterministic hypotheses the tempered posterior's relative weights equal those of the plain (λ = 1) posterior.

*Proof.*
* (i) $J_\lambda\ge\lambda\ell$, and by Kraft only finitely many programs have $\ell\le L$. A minimum over the finitely many programs with $\lambda\ell\le J_\lambda(\pi_0)$ exists.
* (ii) $2^{-J_\lambda}=2^{-\lambda\ell}P=(2^{-\ell}P^{1/\lambda})^\lambda$, and $t\mapsto t^\lambda$ is increasing.
* (iii) is immediate. ∎

*Per-sample form.* With $N=|\mathrm{dom}D|$ and $c:=\lambda/N$, the objective for product hypotheses is $\hat J_c:=J_\lambda/N=c\,\ell+\frac1N\sum_i-\log\nu(y_i\mid x_i)$. Hänni's "increase the hypothesis coefficient as the data set grows" is $c$ fixed, $\lambda=cN$. For a distribution on inputs and a fixed teacher, the population version is $J_c(\pi):=c\,\ell(\pi)+R(\pi)$ with $R(\pi):=\mathbb E_x[-\log\nu_\pi(y^*(x)\mid x)]$, and $\Phi(c):=\inf_\pi J_c(\pi)$.

*λ = cN is not one Bayesian predictor.* For fixed λ, $\xi_\lambda$ is a single shared hypothesis, so its sequential loss telescopes and is order-independent (§1.1). With $\lambda=cN$ the prior exponent changes with $N$. The sequence $(\xi_{cN})_N$ is not the conditional sequence of any one semimeasure, and telescoping does not apply to it. All statements below with λ = cN are **batch** statements about the posterior or the code length at a given $N$.

**Lemma 1.2 (hull; T5 Lemma 3.1, re-derived) [proved; computed: c5(a), c6(F)].** Let $A=\{(\ell(\pi),R(\pi))\}$, with finitely many points below each $\ell$-level and $R\in[0,\infty]$. Let $C:=\mathrm{conv}(A\cap\{R<\infty\})+\mathbb R^2_{\ge0}$ and call the extreme points of $C$ its *vertices*.
* (i) For $c>0$, every minimiser of $c\ell+R$ lies on the boundary of $C$, on a supporting line with normal $(c,1)$.
* (ii) If $c<c'$ and $h,h'$ minimise $J_c,J_{c'}$, then $\ell(h)\ge\ell(h')$ and $R(h)\le R(h')$.
* (iii) A point $a\in A$ is the unique minimising point of $c\ell+R$ for every $c$ in some nonempty open interval iff $a$ is a vertex of $C$. The two end vertices count: the point of least $\ell$ (least $R$ among those) is the unique minimiser for all large $c$, and the point of least $R$, if it exists, for all small $c$. A hypothesis is the unique minimiser on that interval iff, in addition, no other hypothesis has the same point. Example: in $\{(0,1),(10,0.5),(20,0)\}$ the middle point is never the unique minimiser, and the two end points are unique minimisers on $(0.05,\infty)$ and $(0,0.05)$.
* (iv) (Hänni's "absolute bound on model complexity" variant.) Every minimiser $h_c$ of $c\ell+R$ ($c>0$) solves $\min\{R(h):\ell(h)\le\ell(h_c)\}$. Conversely, a solution of a constrained problem $\min\{R(h):\ell(h)\le L\}$ minimises $c\ell+R$ for some $c>0$ iff its point lies on the boundary of $C$ and not on the horizontal ray to the right of the least-$R$ vertex. Constrained solutions can lie above the boundary: in $\{(0,1),(5,0.9),(10,0)\}$ the point $(5,0.9)$ solves the problem for $L\in[5,10)$ and minimises no penalised objective.

*Proof.*
* (i) $c\ell+R=\langle(c,1),\cdot\rangle$, and its minimum over $A$ equals its minimum over $C$.
* (iii) The lower-left boundary of $C$ is a polygonal line whose corners are points of $A$, since only finitely many points lie below each $\ell$-level. A corner $a$ has two incident boundary pieces with different slopes $-s_-<-s_+\le0$ (with $s_-=\infty$ for the first corner, where the piece is vertical, and $s_+=0$ for the last, where it is horizontal). For $c\in(s_+,s_-)$ the line with normal $(c,1)$ through $a$ meets $C$ only at $a$, so $a$ is the unique minimising point. Conversely, if $a$ is the unique minimising point for all $c$ in an open interval, $a$ is an exposed point of $C$, hence a vertex. A non-vertex boundary point is a convex combination of two other boundary points; whenever it is minimising, so are they.
* (ii) Add $c\ell(h)+R(h)\le c\ell(h')+R(h')$ and $c'\ell(h')+R(h')\le c'\ell(h)+R(h)$. This gives $(c'-c)(\ell(h')-\ell(h))\le0$; then use the first inequality.
* (iv) If $\ell(h)\le\ell(h_c)$, then $R(h)\ge R(h_c)+c(\ell(h_c)-\ell(h))\ge R(h_c)$. For the converse: by the proof of (iii), every boundary point that is a vertex, or lies on a segment between two vertices (slope $-s$ with $s>0$), has a supporting line with normal $(c,1)$ for some $c>0$, and so minimises $c\ell+R$. A point on the open horizontal ray is beaten, for every $c>0$, by the least-$R$ vertex, which has the same $R$ and smaller $\ell$. A point on the vertical ray above the least-$\ell$ vertex is never a constrained solution. A point not on the boundary minimises no linear functional with normal $(c,1)$. ∎

[computed: c6(F): over 401 random point sets (5061 points, duplicates and collinear points included) the two sides of (iii) agree in every case.]

*Correction of `notes.md`.* `notes.md` stated (iv) as "a solution of a constrained problem minimises some penalised objective iff its point lies on the lower hull". **[refuted]** Counterexample: $A=\{(0,1),(10,0),(20,0)\}$. The point $(20,0)$ lies on the boundary of $C$ and solves the constrained problem for $L\ge20$ (it ties in $R$ with $(10,0)$), but for every $c>0$ the point $(10,0)$ is strictly better. The corrected statement is (iv) above.

So Hänni's two proposals, the penalty and the absolute bound, select the same hypotheses at the vertices. The absolute bound can also select points above the boundary, which the penalty never selects.

### 1.4 Shared randomness: a universal hypothesis absorbs everything

**(Dom)** The class contains a program $\pi_U$, with $U:=P_{\pi_U}$ and $\ell_U:=\ell(\pi_U)$, such that $P_\pi(o)\le2^{\ell(\pi)+c_0}U(o)$ for all π and $o$.

*Examples.* In every canonical class whose family contains its own mixture, (Dom) holds with $c_0=0$, and moreover $\xi_1=U$:
* (1) **SFI with shared randomness**, $\Pi_F$: $U=M_F$. $M_F$ is a machine law (F Thm 3.2), so it has an index $i_U$; take $\pi_U$ a shortest program for $i_U$. For $D\ne\emptyset$, $P_\pi(D)=\nu_{T_{V(\pi)}}(D)\le M_F(D)/\mathbf m(V(\pi))\le2^{|\pi|}M_F(D)$, and both sides are 1 at $\emptyset$.
* (2) The weak class $\Pi_w$: $U=M^w$ (F Thm 3.4), by the same argument.
* (3) **SI**, $\Pi_{\rm SI}$: $U=M$.
* (4) History-aware SFI, $\Pi_{\rm chr}$: $U=M_H\asymp\xi$ (history Lemma 4.1, Thm 4.2, Cor 4.3).
* (5) Any class that contains the Bayes mixture of its own members as a member.

**Theorem 1 (absorption) [proved].** Assume (Dom), and let $\lambda>1$.
* **(a) MAP.** For every observation $o$, every λ-MAP $\hat\pi$ satisfies
  $$\ell(\hat\pi)\le L_\lambda:=\frac{\lambda\ell_U+c_0}{\lambda-1},\qquad -\log P_{\hat\pi}(o)\le-\log U(o)+\lambda\ell_U-\lambda\ell(\hat\pi).$$
  In particular, if $d>\ell_U$ and $\lambda>(d+c_0)/(d-\ell_U)$, then no hypothesis of length $\ge d$ is a λ-MAP for any observation. This holds for fixed λ, and for $\lambda=cN$ once $cN$ exceeds this bound.
* **(b) Power posterior.** $2^{-\lambda\ell_U}U(o)\le\xi_\lambda(o)\le\xi_1(o)$. If $\xi_1\le2^{c_1}U$ ($c_1=0$ in the canonical examples), then $-c_1\le-\log\xi_\lambda(o)+\log U(o)\le\lambda\ell_U$ on every observation. For data-set classes the sequential log-losses equal these code lengths up to $\log\xi_\lambda(\emptyset)$ and $\log U(\emptyset)$, by telescoping.
* **(c) Deterministic teacher (errors included); data-set classes.** Let $t:X\to Y$ be total computable, $\pi_t$ a program for it and $\ell_t:=\ell(\pi_t)$. Let $x_1,x_2,\dots$ be distinct and $D_N:=\{(x_i,t(x_i))\}_{i\le N}$.
  * (c1) $\sum_{i\le N}-\log\xi_\lambda(t(x_i)\mid x_i,D_{i-1})\le\min\{\lambda\ell_t,\ \lambda\ell_U+c_0+\ell_t\}$. So at most that many inputs, over the whole sequence, receive probability below 1/2 for the teacher's label.
  * (c2) Every λ-MAP for $D_N$ has $-\log P_{\hat\pi}(D_N)\le\lambda\ell_U+c_0+\ell_t$.
  * (c3) There are $N_0$ and a finite set $\Pi_{\rm fin}$ of programs such that every λ-MAP lies in $\Pi_{\rm fin}$ for all $N\ge N_0$. Moreover, at only finitely many $N\ge N_0$ does a λ-MAP $\hat\pi_N$ give the next label $t(x_{N+1})$ probability below 1/2.
* **(d) SI with random inputs.** Encode $(x_1,y_1,x_2,\dots)$ as a binary string with fixed-length blocks. Let the $x_i$ be i.i.d. from a computable law, $y_i=t(x_i)$, and let μ be the resulting computable measure on strings, with a program $\pi_\mu\in\Pi_{\rm SI}$. Then
  $$\mathbb E_\mu\sum_{i\le N}-\log\xi_\lambda(y_i\mid x_1y_1\dots x_i)\le\lambda\ell_U+c_0+\ell(\pi_\mu).$$

*Proof.*
* (a)
  * Since $\hat\pi$ is a MAP, $J_\lambda(\hat\pi)\le J_\lambda(\pi_U)=\lambda\ell_U-\log U(o)$.
  * By (Dom), $-\log U(o)\le\ell(\hat\pi)+c_0-\log P_{\hat\pi}(o)$.
  * Substituting gives $\lambda\ell(\hat\pi)\le\lambda\ell_U+c_0+\ell(\hat\pi)$, which is the length bound. The loss bound is $J_\lambda(\hat\pi)\le J_\lambda(\pi_U)$, rearranged.
  * Finally, $L_\lambda<d$ iff $\lambda(d-\ell_U)>d+c_0$.
* (b) The first inequality keeps one term of the sum. The second holds because $2^{-\lambda\ell}\le2^{-\ell}$. Then use $\xi_1\le2^{c_1}U$. Losses telescope (§1.1).
* (c1) $\xi_\lambda(D_N)\ge2^{-\lambda\ell_t}P_{\pi_t}(D_N)=2^{-\lambda\ell_t}$. Also $\xi_\lambda(D_N)\ge2^{-\lambda\ell_U}U(D_N)\ge2^{-\lambda\ell_U-c_0-\ell_t}$ by (Dom). Telescope, using $\xi_\lambda(\emptyset)\le\sum_\pi2^{-\lambda\ell(\pi)}\le1$. Each conditional is at most 1 by the one-point inequality, and each label with probability below 1/2 adds more than one bit.
* (c2) This is (a) combined with $-\log U(D_N)\le\ell_t+c_0$.
* (c3)
  * Let $\Pi_\lambda:=\{\pi:\ell(\pi)\le L_\lambda\}$; it is finite and, by (a), contains every λ-MAP.
  * For $\pi\in\Pi_\lambda$ let $L_\pi(N):=-\log P_\pi(D_N)$. It is nondecreasing in $N$ by the one-point inequality, so it has a limit $L_\pi(\infty)\in[0,\infty]$.
  * Let $\Pi_{\rm fin}:=\{\pi\in\Pi_\lambda:L_\pi(\infty)<\infty\}$. It contains $\pi_U$, since $\ell_U\le L_\lambda$ and $L_U(\infty)\le\ell_t+c_0$.
  * For $\pi\in\Pi_\lambda\setminus\Pi_{\rm fin}$ we have $J_\lambda(\pi;D_N)\to\infty$, while $J_\lambda(\pi_U;D_N)\le\lambda\ell_U+\ell_t+c_0$ for every $N$. Finiteness gives $N_0$ beyond which no such π is a MAP.
  * For $\pi\in\Pi_{\rm fin}$, $\sum_N[L_\pi(N+1)-L_\pi(N)]\le L_\pi(\infty)$, and each increment equals $-\log P_\pi(t(x_{N+1})\mid x_{N+1},D_N)$. So π gives probability below 1/2 to the next label at most $L_\pi(\infty)$ times.
  * Summing over the finite set $\Pi_{\rm fin}$ bounds the number of such $N$ for MAPs.
* (d)
  * $\xi_\lambda\ge2^{-\lambda\ell_U}U\ge2^{-\lambda\ell_U-c_0-\ell(\pi_\mu)}\mu$, so $\mathbb E_\mu\log(\mu/\xi_\lambda)(\omega)\le\lambda\ell_U+c_0+\ell(\pi_\mu)$ for every prefix $\omega$.
  * Expand $\log(\mu/\xi_\lambda)$ by the chain rule over bit positions. At each position the conditional expectation is $\mathrm{KL}(\mu(\cdot\mid h)\,\|\,\xi_\lambda(\cdot\mid h))$, which is at least $-\log\sum_b\xi_\lambda(b\mid h)\ge0$ because $\xi_\lambda(\cdot\mid h)$ is a sub-probability.
  * At a label position $\mu(y_i\mid h)=1$, so the term equals $-\log\xi_\lambda(y_i\mid h)$.
  * Dropping the nonnegative input-position terms gives the claim. This is Solomonoff's bound restricted to the label positions [known: Solomonoff 1978, *IEEE Trans. IT* 24(4):422–432 (verified; exact constant there unverified)]. ∎

*Remarks.*
* (a) is the precise form of Hänni's "it'll be better to drop bits and take the likelihood loss" in the sequence case, and of Wyeth's objection. It reproduces T5 Prop 2.3's threshold $\ell_U+(\ell_U+c_0)/(\lambda-1)$. As $\lambda\to\infty$ the bound tends to $\ell_U$, not to 0, so hypotheses simpler than $U$ are not excluded. With $\lambda=cN$, every model longer than about $\ell_U$ is eventually excluded. Whether a given simple model is longer than $\ell_U$ depends on the reference machine. A 100-bit model may or may not be. A realistic concept, such as a dog classifier with millions of bits, certainly is.
* (d) needs the inputs to be modelled by μ. With adaptive or non-computable inputs use $\Pi_{\rm chr}$ instead, where $U=M_H\asymp\xi$ dominates every lower-semicomputable chronological semimeasure on every input sequence (history Cor 4.3(b)); (a)–(b) hold there as stated.
* (c3) has no explicit bound. Explicit online bounds for discrete MDL are known to be exponentially worse than Bayes in general [known: Poland & Hutter 2005, *IEEE Trans. IT* 51(11):3780–3795, with erratum by Poland, *IEEE Trans. IT* 52(3):1279, 2006, which corrects the abstract's description of the setting from i.i.d. to arbitrary processes (verified; content per abstract and snippet)].

### 1.5 Private randomness: no hypothesis absorbs anything

**Proposition 1.3 (per-input pricing; T5 Thm 2.1 and Prop 2.2, re-derived) [proved; computed: c2(a); referee r2].** Let $F$ be a finite set of total functions $X\to Y$, $x_1,\dots,x_N$ distinct, and let $Q_x$ denote the law of $f(x)$ when $f\sim Q$.
* (i) For every product hypothesis ν and every distribution $Q$ on $F$:
  $$\max_{f\in F}\sum_i-\log\nu(f(x_i)\mid x_i)\ \ge\ \sum_iH(Q_{x_i}).$$
  The value $\inf_\nu\max_f\sum_i-\log\nu(f(x_i)\mid x_i)$ equals $\max_Q\sum_iH(Q_{x_i})$, which can be strictly below $\sum_i\log|F(x_i)|$. Example: $F=\{(a,a),(a,b),(b,a),(c,a)\}$ has value $2.5431<2.5850$ [computed: c2(a), by maximising over $Q$ and by SLSQP over ν; referee r2 by grid search, mirror ascent and a primal certificate].
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

**Corollary 1.4 (no universal product hypothesis) [proved].** Let $X\supseteq\{0,1\}^d$ for every $d$ (here $X=\{0,1\}^*$). For every product hypothesis $\nu_U$ and every constant $C$, there are a data set $D$ and a deterministic product hypothesis $f$ such that:
* $f\supseteq D$;
* $f$ has a program of length at most $d+2\log d+\kappa$;
* $\nu_U(D)\le2^{-(2^d-1)}$.

Choosing $d$ with $2^d-1-d-2\log d-\kappa>C$ gives $\nu_U(D)<2^{-C}2^{-\ell(\pi_f)}f(D)$. So (Dom) fails for every candidate $U$ in the product class.

*Proof.* Take $D$ to be the labels of a parity on all nonzero inputs of $\{0,1\}^d$, choosing the parity by Prop 1.3(ii) (some parity costs $\nu_U$ at least $2^d-1$ bits). A parity is given by $d$ and $a\in\{0,1\}^d$. ∎

**Remark 1.5 (the universal conditional semimeasure is a fixed predictor; T5 Thm 2.4) [proved].** The universal lower-semicomputable conditional semimeasure $\mathbf m(y\mid x)$ satisfies $\mathbf m(y\mid x)\ge2^{-K(y\mid x)-\kappa}$.
* For $Y=\{0,1\}$ this gives $\mathbf m(y\mid x)\ge2^{-\kappa'}$ for both labels, hence $\mathbf m(y\mid x)\le1-2^{-\kappa'}$. So $\mathbf m$ pays at least $\log\frac1{1-2^{-\kappa'}}>0$ bits for every label, on every data set.
* It dominates each product hypothesis input by input, $\mathbf m\ge2^{-K(\nu)-\kappa}\nu$, but it pays the factor $2^{K(\nu)}$ at every input. It never learns.

**Lemma 1.6 (coding bound; holds in every data-set class) [proved].** For every product or shared hypothesis $P_\pi$ and every data set $D$:
$$\ell(\pi)-\log P_\pi(D)\ \ge\ K(y_D\mid\mathrm{dom}D)-\kappa,$$
where $y_D$ lists the labels in the canonical order of $\mathrm{dom}D$.

*Proof.*
* Given π and the finite set $\mathrm{dom}D$, the map $y\mapsto P_\pi(\mathrm{dom}D\mapsto y)$ is a lower-semicomputable semimeasure on $Y^{\mathrm{dom}D}$. For product hypotheses this is $\prod_i\sum_{y_i}\nu(y_i\mid x_i)\le1$; for shared ones it is F's consequence (b) of Def 2.1.
* (F2) gives $K(y_D\mid\pi,\mathrm{dom}D)\le-\log P_\pi(D)+\kappa$.
* (F3) and (F1) give $K(y_D\mid\mathrm{dom}D)\le\ell(\pi)+K(y_D\mid\pi,\mathrm{dom}D)+\kappa$. ∎

The coding bound is "one bit pays for at most one bit" and holds in both kinds of class. What separates them is whether one member attains the bound up to a constant on *every* data set. $U$ does in a class with (Dom). Nothing does in the product class (Cor 1.4).

### 1.6 Why private randomness is what makes SFI different here

* **At λ = 1 the decomposition into hypotheses does not change the predictor.** The Bayes mixture over the product class, $\xi_\times=M_{\rm prod}$, is a *shared* hypothesis. It dominates every product hypothesis with constant $2^{-K(\nu)-\kappa}$. The predictive distribution is the same object whichever way it is written as a mixture.
* **At λ > 1 the decomposition matters.** The steeper penalty acts on single hypotheses, so its effect depends on what counts as one hypothesis and on its length.
  * In SI, and in any class that contains its own mixture, the mixture is one short hypothesis and absorbs everything (Thm 1).
  * SFI's natural hypotheses for this purpose are Hänni's "computably samplable predictors": x-only samplers that use separate randomness for each input. His dominance template (`prior/hanni-sfi-notes.md`) is stated against this class. These are exactly the product hypotheses (F Prop 3.3(a)). A product hypothesis is a fixed map $x\mapsto\nu(\cdot\mid x)$, so it cannot learn, and it pays per input (Prop 1.3, Cor 1.4).
  * This is Hänni's mechanism ("you have to pay the likelihood term separately at every x") in exact form.
* **Consequence for the definition of steeper SFI.** F recommends $M_F$, the law of the universal function machine, as *the* SFI predictor. $M_F$ is a mixture over machine laws, which use a shared tape. If steeper simplicity were applied to the class $\Pi_F$ of all machine laws, $M_F$ would itself be a short member, and Theorem 1 would apply: absorption returns. So the steeper prior is applied to the product class $\Pi_\times$. Its λ → 1 limit is $M_{\rm prod}$, not $M_F$.
* **What this restriction costs.**
  * At λ = 1: $M_{\rm prod}$ agrees with $M_F$ up to $K(\mathrm{dom}D)+O(1)$ bits (F Thm 4.2), but not up to a constant: $M_F/M_{\rm prod}$ is unbounded, already against an $O(1)$-complexity law with one shared coin per input length (F Prop 4.5).
  * At λ > 1: a constant factor on data with shared latent causes (Prop 1.7 below).
  * The protection also depends on the granularity of inputs. If a hypothesis's input contains earlier *labelled* pairs, the in-context Bayes mixture is again a single member (Prop 4.1).

### 1.7 The price of private randomness under a steeper prior

**Proposition 1.7 (shared latent coins) [proved; computed: c6(D)].** Let $Y=\{0,1\}$, $k\ge1$, and for $j\le k$ put $a_j:=0^j$ and $b_j:=1^j$. For $\beta\in\{0,1\}^k$ let
$$D_\beta:=\{(a_j,\beta_j),(b_j,\beta_j):j\le k\},$$
"one coin per pair of inputs, shown on both". Let $\xi^\times_\lambda$ be the steeper predictor of the canonical product class $\Pi_\times$.
* (i) For every $\lambda\ge1$ and every β: $-\log\xi^\times_\lambda(D_\beta)\ \ge\ \min(\lambda,2)\,\big(K(\beta\mid k)-\kappa\big)$.
* (ii) Hence every program $\pi\in\Pi_\times$ has $J_\lambda(\pi;D_\beta)\ge\min(\lambda,2)(K(\beta\mid k)-\kappa)$. The same bound holds for every product subclass with a prefix-free code, with κ depending on the subclass.
* (iii) On the other side, the law σ that answers input $x$ with the $|x|$-th bit of the shared tape is a machine law of complexity $O(1)$ with $\sigma(D_\beta)=2^{-k}$. So $-\log M_F(D_\beta)\le k+\kappa$, and the steeper predictor over the machine-law class $\Pi_F$ has $-\log\xi^F_\lambda(D_\beta)\le k+\lambda\kappa$.
* (iv) For β uniform, $\Pr[K(\beta\mid k)<k-j]<2^{-j}$. So with probability at least $1-2^{-j}$ the steeper product predictor pays at least $(\min(\lambda,2)-1)k-\kappa'(\lambda+j)$ bits more than $M_F$ and than $\xi^F_\lambda$.

*Proof.*
* (i) Fix $\pi\in\Pi_\times$ with conditional semimeasure $\nu=\nu_{V(\pi)}$. Then $\nu(D_\beta)=\prod_js_j(\beta_j)$ with $s_j(y):=\nu(y\mid a_j)\nu(y\mid b_j)$.
  * By AM–GM, $s_j(y)\le q_j(y)^2$ with $q_j(y):=\frac12(\nu(y\mid a_j)+\nu(y\mid b_j))$. Each $q_j$ is a sub-probability on $\{0,1\}$. So $\nu(D_\beta)\le Q_\pi(\beta)^2$ with $Q_\pi(\beta):=\prod_jq_j(\beta_j)\le1$, and $Q_\pi$ is a semimeasure on $\{0,1\}^k$, lower semicomputable uniformly in $(\pi,k)$.
  * Let $R(\beta):=\sum_{\pi\in\Pi_\times}2^{-|\pi|}Q_\pi(\beta)$. It is a lower-semicomputable semimeasure on $\{0,1\}^k$ given $k$, so $R(\beta)\le2^{-K(\beta\mid k)+\kappa}$ by (F2).
  * If $1\le\lambda\le2$: $2^{-\lambda|\pi|}Q_\pi^2=(2^{-|\pi|}Q_\pi)^\lambda Q_\pi^{2-\lambda}\le(2^{-|\pi|}Q_\pi)^\lambda$. If $\lambda\ge2$: $2^{-\lambda|\pi|}Q_\pi^2\le(2^{-|\pi|}Q_\pi)^2$.
  * For nonnegative $t_\pi$ and $\gamma\ge1$, $\sum_\pi t_\pi^\gamma\le(\sum_\pi t_\pi)^\gamma$. With $\gamma=\min(\lambda,2)$ this gives $\xi^\times_\lambda(D_\beta)\le\sum_\pi2^{-\lambda|\pi|}Q_\pi(\beta)^2\le R(\beta)^{\min(\lambda,2)}\le2^{-\min(\lambda,2)(K(\beta\mid k)-\kappa)}$.
* (ii) $2^{-J_\lambda(\pi;D_\beta)}$ is one term of $\xi^\times_\lambda(D_\beta)$. For a subclass, replace $\Pi_\times$ by the subclass in the definition of $R$; (F2) then holds with a constant for that subclass.
* (iii) σ is the function machine $T=\{(x,w,w_{|x|}):x\ne\varepsilon,\ w\in\{0,1\}^{|x|}\}$, where $w_{|x|}$ is the last bit of the tape prefix $w$; at input $x$ it reads tape bit $|x|$. Inputs $a_j,b_j$ have the same length $j$, so they get the same bit, and distinct $j$ get independent bits. Apply F Thm 3.2. For $\xi^F_\lambda$ keep the single term of a program for σ.
* (iv) Fewer than $2^{k-j}$ strings have $K(\cdot\mid k)<k-j$. ∎

[computed: c6(D): the inequality $\xi_\lambda(D_\beta)\le R(\beta)^{\min(\lambda,2)}$ held in all 24,732 checks on random finite product classes with Kraft weights, $\lambda\in\{1,1.3,1.7,2,2.5,4\}$; equality occurs.]

*Reading.* A product class must treat a coin that several inputs share either as **model**, writing the coin into the program at λ bits per coin, or as **noise**, paying for it again at every input that shows it: 2 bits per coin here. A shared class pays 1 bit. At λ = 1 the first option costs the same as the shared class up to logarithmic terms, which is why $M_{\rm prod}$ and $M_F$ are close (F Thm 4.2). At λ > 1 the product class pays $\min(\lambda,2)$ bits per coin. This is the same model-versus-randomness choice as in §3, but here the randomness is shared, so neither option is right. Persistent latent causes in real labelling (a labeller's mood, a per-batch coin) are of this kind.

### 1.8 Answer to Wyeth's objection

Wyeth: "If you penalize the complexity of my hypotheses more steeply, I can just choose a hypothesis that is a universal distribution which penalizes complexity minimally as usual. So that won't work, at least not naively. This sort of question is studied in algorithmic statistics."

* **(i) The objection is correct wherever a universal hypothesis is one member of the class.** Theorem 1 is the objection made exact. It applies to SI ($U=M$), to SFI as the foundations track defines it ($U=M_F$, class $\Pi_F$), to the weak class ($U=M^w$) and to history-aware SFI ($U=M_H\asymp\xi$). In each, every λ-MAP has length at most $(\lambda\ell_U+c_0)/(\lambda-1)$ on every data set, and fits almost as well as $U$. So it reproduces the teacher's errors (Thm 1(c)), and samplers longer than about $\ell_U$ are never selected (Thm 5).
* **(ii) The construction is unavailable in the product class.** No product hypothesis is universal (Cor 1.4). The candidate Wyeth's construction suggests, the universal conditional semimeasure $\mathbf m(y\mid x)$, is a fixed predictor that never learns (Remark 1.5). Seeing earlier *inputs* does not help while the randomness stays private (Prop 4.2). This is Hänni's reply, made exact: "if each input gets its own private randomness, then I don't see how to write down a universal hypothesis".
* **(iii) The restriction has a price, and a boundary.**
  * The steeper product class cannot represent latent randomness shared across inputs. At λ = 1 this costs at most $K(\mathrm{dom}D)+O(1)$ bits against $M_F$, unboundedly in the worst case (F Thm 4.2, Prop 4.5). At λ > 1 it costs a factor $\min(\lambda,2)$ on shared coins (Prop 1.7).
  * The protection ends where hypotheses see labelled history: then the in-context Bayes mixture is one member again, and absorption returns per block (Prop 4.1).
  * So relative to SFI as F defines it ($M_F$), restricting to private randomness is not free. "Nothing is lost at λ = 1" holds only relative to the product class.
* **(iv) The algorithmic-statistics reading.** Wyeth is right that the question lives in algorithmic statistics. For set models (shared randomness) the minimal sufficient statistic of a noisy random parity treats the parity's $d$-bit parameter as noise: its sophistication is $O(\log d)$. For product models the parameter is model: product sophistication is $d\pm O(\log n)$ (Prop 3.8). Restricting the model family to "parameter + private noise per input" is what moves the split. §3.5 relates this to known work on restricted model families.
* **Is the restriction ad hoc?** It is a choice, and the paper should present it as one. Two reasons support it. Hänni's dominance template for SFI is stated against x-only samplers, which are the product hypotheses (F Prop 3.3(a)). And in supervised learning "the model" is naturally the part of the description that is reused across inputs; noise that is private to each input is, by construction, not part of it. The price in (iii) is what the choice gives up.

---

## 2. The teacher's-mistakes trick

### 2.1 Hänni's calculation [computed: c1; T5 re-run: t5_rerun/c1]

* **Version 1** (total bits, data fixed): a 100-bit simple model that "predicts 100 bits per specification bit" and a 100-bit error model that predicts 10 bits per bit.
  * The hull is coin → simple → simple+errors, with slopes 100 and 10.
  * "Simple" alone is selected exactly for λ ∈ (10, 100); λ = 1 selects simple+errors.
* **Version 2** (per sample, from the LessWrong thread): a 100-bit simple model, plus errors on a $2^{-10}$ fraction of inputs whose set takes "10000 bits to specify".
  * Rates: $(1-H(p))/110=8.989\cdot10^{-3}$ for the model and $H(p)/9990=1.1185\cdot10^{-6}$ for the errors, with 10 bits for the flip rate. Without those 10 bits the rates are $9.888\cdot10^{-3}$ and $1.1174\cdot10^{-6}$.
  * The good model is selected among the three iff $c\in(1.12\cdot10^{-6},\,8.99\cdot10^{-3})$, a ratio of about 8000. At $N=10^6$ this is $\lambda\in(1.12,\,8989)$.
  * Plain MDL (λ = 1) switches to the memoriser at $N\approx8.94\cdot10^5$.
  * His "expected neg log likelihood ≈ p log(1/p) ≈ 1/100": the exact value is $H(2^{-10})=0.01117$, against $p\log(1/p)=0.00977$ (13% lower). The difference does not matter.
  * T5's script reproduces these numbers (saved in `checks/t5_rerun/c1_user_example.out`).
* **What the calculation does not show.** It does not show that no *other* hypothesis beats the good model in the window. Possible competitors are partial models, partial memorisers, mixtures and "universal-like" hypotheses; Hänni himself asks "maybe I'm just failing to construct the right universal hypothesis". Theorem 2 settles this for an instance with his Version 2 numbers, over all product hypotheses. Example 2.7a does it, more coarsely, for Version 1.

### 2.2 The instance

**Setting 2.0.**
* Integers $1\le m\le d$; $p=2^{-r}$ with $2\le r\le m$; $s_0:=p2^m=2^{m-r}$.
* $a\in\{0,1\}^d$ with $K(a)\ge d$. The **simple model** is $f_a(x)=\langle a,x\rangle\bmod2$ on $\{0,1\}^d\subseteq X$.
* $S\subseteq\{0,1\}^m$ with $|S|=s_0$. The **error set** is $E:=S\times\{0,1\}^{d-m}$: the inputs whose first $m$ bits lie in $S$. Under uniform $x\in\{0,1\}^d$, $\Pr[x\in E]=p$ exactly.
* The **teacher** is the deterministic function $y^*(x)=f_a(x)\oplus1_E(x)$.
  * For $m<d$ the errors are a *systematic* rule (a random junta), so they generalise to new inputs.
  * For $m=d$ they are an idiosyncratic random error set on a finite domain.
* $L_S:=\log\binom{2^m}{s_0}$. $B_S:=K(S\mid a,K(a))$, and $\delta_S:=L_S-B_S$ is the randomness deficiency of $S$ given $a$.
  * Known bounds: $2^mH(p)-\log(2^m+1)\le L_S\le2^mH(p)$ [known: e.g. Cover & Thomas, *Elements of Information Theory*, binomial-coefficient bounds; checked numerically in c3].
  * $\delta_S\ge-\kappa$, and most $S$ have small deficiency: $\Pr_S[\delta_S>j]<2^{-j}$, because fewer than $2^{L_S-j}$ programs are shorter than $L_S-j$.
  * The **information** a program π holds about the error rule beyond the parity is $I(\pi):=B_S-K(S\mid a,\pi)$. Against the rule's full length, $L_S-K(S\mid a,\pi)=\delta_S+I(\pi)$.
* **Hänni's numbers**: $d=100$, $m=20$, $p=2^{-10}$, giving $L_S=11{,}710.27$ bits [computed: c1, exact].
* **Population quantities.** Inputs are uniform on $\{0,1\}^d$. For a product program π:
  * $R(\pi)=\mathbb E_x[-\log\nu_\pi(y^*(x)\mid x)]$;
  * for a truncation level $B\in[\log(1/p),\infty]$, $R_B(\pi):=\mathbb E_x\min\{B,-\log\nu_\pi(y^*(x)\mid x)\}\le R(\pi)$;
  * $J_c(\pi)=c\ell(\pi)+R(\pi)$, $J_c^B:=c\ell+R_B$, $\Phi^B(c):=\inf J^B_c\le\Phi(c)$, the infimum over the class.
  * Put $\tau_B:=2^{1-B}$ and $\beta_B:=2^m\log(1+\tau_B)$, both 0 if $B=\infty$.
* **Agreement**: $u(\pi):=\mathbb E_x\nu_\pi(f_a(x)\mid x)$. **Levels**: $\theta_t:=\frac12+2^{-t-1}$ and $T(\pi):=\min\{t\ge1:u(\pi)>\theta_t\}$, with $T(\pi):=\infty$ if $u(\pi)\le\frac12$. So $T(\pi)=1$ iff $u(\pi)>3/4$.
* $s(t):=2t+2\log(t+1)\le4t$.
* $G_j:=1-\log(1+2^{-j}+2p+\tau_B)$ for $j\in[0,\infty]$. It is concave and increasing in $j$: with $v=2^{-j}$, $G'=v/(1+v+2p+\tau_B)>0$ and $G''=-\ln2\cdot v(1+2p+\tau_B)/(1+v+2p+\tau_B)^2<0$.
* **Reference programs** in $\Pi_\times$:
  * the **coin**, with $\ell\le\kappa$ and $R=1$;
  * the **good model** $\pi_g$: $\nu(f_a(x)\mid x)=1-p$, with $\ell(\pi_g)\le d+\kappa_g$, $\kappa_g:=2\log d+2\log r+\kappa$, and $R=R_B=H(p)$ exactly;
  * the **memoriser** $\pi_b$ = the deterministic $y^*$, with $\ell(\pi_b)\le d+\lceil L_S\rceil+\kappa_b$, $\kappa_b:=2\log d+2\log m+2\log s_0+\kappa$, and $R=0$.
* $\Lambda_1:=2\log d+2\log m+2\log B\cdot[B<\infty]+\beta_B+\kappa$.

### 2.3 Four lemmas

**Lemma 2.1 (list decoding for semimeasures) [proved; computed: c2(b); referee r3].** If $T(\pi)=t<\infty$, then $K(a\mid\pi)\le s(t)+2\log d+\kappa$.

*Proof.*
* Write $h_y(x):=\nu_\pi(y\mid x)$, $s_h:=h_0-h_1\in[-1,1]$, $\chi_{a'}(x):=(-1)^{\langle a',x\rangle}$ and $\hat s(a'):=\mathbb E_x[s_h\chi_{a'}]$.
* Then $u(\pi;a'):=\mathbb E_x\nu_\pi(f_{a'}(x)\mid x)=\frac12(\mathbb E_x[h_0+h_1]+\hat s(a'))\le\frac12(1+\hat s(a'))$.
* Parseval gives $\sum_{a'}\hat s(a')^2=\mathbb E s_h^2\le1$. So $A_t:=\{a':u(\pi;a')>\theta_t\}\subseteq\{a':\hat s(a')>2^{-t}\}$ has fewer than $2^{2t}$ elements.
* $u(\pi;a')$ is lower semicomputable uniformly in $(\pi,a',d)$, so $A_t$ is c.e. given $(\pi,d,t)$, and $a\in A_t$.
* Describe $a$ by $d$, $t$ and its index in the enumeration of $A_t$: $2t$ bits given $t$. Then use (F5).
* (This is T5's Lemma 2.5a with $\hat s$ replaced by the lower-semicomputable $u$, which handles semimeasures. The Parseval list bound is standard [known: Goldreich & Levin 1989, STOC; Kushilevitz & Mansour 1993, *SIAM J. Comput.* 22(6)].) ∎

**Lemma 2.2 (risk floor) [proved; computed: c2(b)].** $R_B(\pi)\ge-\log(u(\pi)+p+2^{-B})$, with $2^{-\infty}=0$. Hence:
* $T(\pi)=t\ge2$ implies $R_B(\pi)\ge G_{t-1}$;
* $T(\pi)=\infty$ implies $R_B(\pi)\ge G_\infty$.

*Proof.*
* $\min\{B,-\log v\}=-\log\max\{v,2^{-B}\}$. By Jensen, $R_B\ge-\log\mathbb E_x\max\{\nu_\pi(y^*\mid x),2^{-B}\}\ge-\log(\mathbb E_x\nu_\pi(y^*\mid x)+2^{-B})$.
* Off $E$, $y^*=f_a$; on $E$, $\nu\le1$. So $\mathbb E_x\nu_\pi(y^*\mid x)\le u(\pi)+p$.
* If $T=t\ge2$, then $u\le\theta_{t-1}=\frac12+2^{-t}$, and $\frac12+2^{-t}+p+2^{-B}\le\frac12(1+2^{-(t-1)}+2p+\tau_B)$. ∎

**Lemma 2.3 (coding the error rule with a hypothesis) [proved; referee r3].** $K(S\mid a,\pi)\le2^mR_B(\pi)+\beta_B+2\log m+2\log B\cdot[B<\infty]+\kappa$. (For finite $B$, take $B$ an integer.)

*Proof.*
* For $z\in\{0,1\}^m$ and $b\in\{0,1\}$, let $q_z(b):=2^{-\mathbb E_w\min\{B,-\log\nu_\pi(f_a(z,w)\oplus b\mid(z,w))\}}$, with $w$ uniform on $\{0,1\}^{d-m}$.
* By AM–GM, $q_z(b)\le\mathbb E_w\max\{\nu_\pi(f_a\oplus b\mid\cdot),2^{-B}\}$. Hence $\sum_bq_z(b)\le1+\tau_B$.
* $q_z$ is lower semicomputable from $(\pi,a,m,B)$.
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

The pieces of $M_2$ are nondecreasing in $c$, and $J_g$ is linear. So $\{c:J_g(c)\le M_2(c)\}=(0,c_{\rm hi}]$, where:
* $c_{\rm hi}=\min\{\frac{G_1-H(p)}{8+\Lambda_1+\kappa_g},\frac{G_{t^*-1}-H(p)}{d+\kappa_g}\}$ if $t^*\ge2$;
* $c_{\rm hi}=\frac{G_1-H(p)}{d+\kappa_g}$ otherwise.

$c_{\rm hi}>0$ requires $G_1>H(p)$. With $B=\infty$ this holds iff $p<0.0560$ [computed: c3; referee r1(B): 0.05596].

**Theorem 2 (the teacher's-mistakes trick: three regimes) [proved].** In Setting 2.0, with $B\in[\log(1/p),\infty]$, for every program π of $\Pi_\times$ (or of any class covered by Prop 4.4):

**(o) Level bounds.**
* If $T(\pi)=1$, then $J_c^B(\pi)\ge c(d-4-\Lambda_1)+\psi_c(R_B(\pi))$.
* If $T(\pi)\ge2$, including ∞, then $J_c^B(\pi)\ge M_2(c)$.

**(i) Window.** If $c\,2^m>1$ and $c\le c_{\rm hi}$, then $\Phi(c)\ge\Phi^B(c)\ge\min\{M_1(c),M_2(c)\}$ and $J_c(\pi_g)\le\Phi(c)+\Delta(c)$. Here $\Delta(c)\le c(4+\Lambda_1+\kappa_g)+(\log(2^m+1)+\delta_S)/2^m$.

**(ii) Identification.** Let $c\,2^m>1$, $\eta\ge0$ and $J_g(c)+\eta<M_2(c)$. Let π satisfy $J^B_c(\pi)\le J_g(c)+\eta$; this includes every π with $J_c(\pi)\le\Phi(c)+\eta$. Then $T(\pi)=1$, so $u(\pi)>3/4$. Write $\Lambda_2:=2^mH(p)-B_S+4+\Lambda_1+\kappa_g\le\log(2^m+1)+\delta_S+4+\Lambda_1+\kappa_g$, $\Lambda_3:=4+2\log d+\kappa$, and
$$\Delta_\ell:=\kappa_g+\frac\eta c+\frac{\Lambda_2+\eta/c}{c2^m-1}.$$
Then:
* (a) *it knows the simple model*: $u(\pi)\ge\max\{3/4,\ 2^{-(J_g(c)+\eta)}-p-2^{-B}\}$;
* (b) *it fits no better than noise*: $R_B(\pi)\ge H(p)-\frac{c\Lambda_2+\eta}{c2^m-1}$;
* (c) *it is short*: $\ell(\pi)\le d+\Delta_\ell$;
* (d) *it holds little information about the error rule*: $I(\pi)=B_S-K(S\mid a,\pi)\le\Delta_\ell+\Lambda_3$, so $L_S-K(S\mid a,\pi)\le\delta_S+\Delta_\ell+\Lambda_3$;
* (e) *it does not predict the errors*. For every integer $g\ge1$,
  $$e(\pi):=\mathbb E[\nu_\pi(y^*(x)\mid x)\mid x\in E]\ \le\ 1-u(\pi)+\gamma_g+2^{-g},$$
  where $\gamma_g:=\sqrt{j_g\ln2/(2s_0)}$, $j_g$ is the least integer $j\ge0$ with $j-2\log(j+1)>\Gamma_g$, and $\Gamma_g:=\delta_S+\Delta_\ell+\Lambda_3+1+2\log m+2\log s_0+g+2\log g+\kappa$.

**(iii) Memoriser regime.** Let $c\,2^m<1$, and let π satisfy $J^B_c(\pi)\le J_b(c)+\eta$ with $J_b(c)+\eta<M_2(c)$. Then:
* $T(\pi)=1$;
* $(1-c2^m)\min\{R_B(\pi),B_S/2^m\}\le\rho:=c(\lceil L_S\rceil-L_S+\delta_S+4+\Lambda_1+\kappa_b)+\eta$;
* if $\rho<(1-c2^m)B_S/2^m$, then $R_B(\pi)\le\rho/(1-c2^m)$ and $e(\pi)\ge2^{-R_B(\pi)/p}-2^{-B}$. The condition says that $c$ is below $2^{-m}$ by a relative margin of order $\rho2^m/B_S$.

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
* Then $J_c(\pi_g)-\Phi(c)\le J_g-\min\{M_1,M_2\}\le\max\{J_g-M_1,\,J_g-M_2\}\le\Delta(c)$, because $J_g\le M_2$. The bound on Δ uses $L_S\ge2^mH(p)-\log(2^m+1)$.

**(ii)**
* $J^B_c(\pi)<M_2(c)$, so by (o) $T(\pi)=1$.
* (a) By Lemma 2.2, $-\log(u+p+2^{-B})\le R_B\le J^B_c\le J_g+\eta$.
* (b)
  * By (o), $\psi_c(R_B)\le c(4+\Lambda_1+\kappa_g)+H(p)+\eta$.
  * If $R_B<B_S/2^m$, then $\psi_c=cB_S-(c2^m-1)R_B$. Using $cB_S-H(p)=(c2^m-1)H(p)-c(2^mH(p)-B_S)$, this gives $(c2^m-1)R_B\ge(c2^m-1)H(p)-c\Lambda_2-\eta$.
  * If $R_B\ge B_S/2^m$, then $R_B\ge H(p)-(2^mH(p)-B_S)/2^m\ge H(p)-c\Lambda_2/(c2^m-1)$, since $\Lambda_2\ge2^mH(p)-B_S$ and $c/(c2^m-1)>2^{-m}$. (If $2^mH(p)-B_S\le0$ the claim is trivial.)
* (c) $c\ell=J^B_c-R_B\le c(d+\kappa_g)+H(p)+\eta-R_B$, then apply (b).
* (d)
  * By (F3), $B_S=K(S\mid a,K(a))\le K(\pi\mid a,K(a))+K(S\mid\pi,a)+\kappa$.
  * By (F4) and (F3), $K(\pi\mid a,K(a))=K(\pi,a)-K(a)+O(1)\le K(\pi)+K(a\mid\pi)-K(a)+O(1)$.
  * This is at most $\ell(\pi)-d+s(1)+2\log d+\kappa\le\Delta_\ell+\Lambda_3$, by (F1), Lemma 2.1, $K(a)\ge d$ and (c).
* (e)
  * Let $v(z):=\mathbb E_w\nu_\pi(f_a(z,w)\oplus1\mid(z,w))\in[0,1]$. Then $e(\pi)=s_0^{-1}\sum_{z\in S}v(z)$, and $\bar v:=2^{-m}\sum_zv(z)=\mathbb E_x\nu_\pi(f_a\oplus1\mid x)\le1-u(\pi)$ because ν is a semimeasure.
  * Let θ be the least multiple of $2^{-g}$ that is $\ge1-u(\pi)+\gamma_g$. Then $K(\theta)\le g+2\log g+\kappa$ and $\theta\ge\bar v+\gamma_g$.
  * Suppose $e(\pi)>\theta$. The set $B_\theta:=\{S':|S'|=s_0,\ s_0^{-1}\sum_{z\in S'}v(z)>\theta\}$ is c.e. given $(\pi,a,m,s_0,\theta)$, because $v$ is lower semicomputable. It contains $S$.
  * For $S'$ uniform among $s_0$-subsets, Hoeffding's bound for sampling without replacement gives $\Pr[\mathrm{avg}_{S'}v-\bar v\ge\gamma_g]\le e^{-2s_0\gamma_g^2}$ [known: Hoeffding 1963, *JASA* 58:13–30, Thm 4 (verified via secondary sources); sanity check in c3; exhaustive check in referee r3]. So $|B_\theta|\le2^{L_S-j_g}$.
  * Describe $S$ by $j_g$ (self-delimiting) and its index among the first $2^{\lceil L_S\rceil-j_g}$ elements enumerated. This gives $K(S\mid\pi,a)\le\lceil L_S\rceil-j_g+2\log(j_g+1)+2\log m+2\log s_0+g+2\log g+\kappa$.
  * Together with (d), this gives $j_g-2\log(j_g+1)\le\Gamma_g$, contradicting the choice of $j_g$. So $e(\pi)\le\theta\le1-u+\gamma_g+2^{-g}$.

**(iii)**
* $T=1$ follows from (o) as in (ii).
* For $c2^m<1$ and $R\ge0$, $\psi_c(R)\ge cB_S+(1-c2^m)\min\{R,B_S/2^m\}$. To check this, consider $R\le B_S/2^m$ and $R\ge B_S/2^m$ separately; note $B_S/2^m=cB_S+(1-c2^m)B_S/2^m$.
* Compare with $J^B_c\le J_b(c)+\eta$, using $L_S=B_S+\delta_S$. The error-label bound follows from $p\cdot\mathbb E[\min(B,-\log\nu)\mid E]\le R_B$ and Jensen: $\mathbb E[\nu\mid E]\ge\mathbb E[\max(\nu,2^{-B})\mid E]-2^{-B}\ge2^{-R_B/p}-2^{-B}$.

**(iv)** By (D1), $J_c(\pi)\ge c(d-4-\Lambda_1)+H(p)>c(d+\lceil L_S\rceil+\kappa_b)\ge J_c(\pi_b)$. ∎

**Numbers** [computed: c3, c6(B); referee r1(A), r1(C)]. All at $d=100$, $m=20$, $p=2^{-10}$, $B=\infty$, $\eta=0$; κ is the machine constant.
* Window $(2^{-m},c_{\rm hi}]$: $(9.54\cdot10^{-7},\,8.06\cdot10^{-3}]$ at κ = 0 (ratio 8453); $(9.54\cdot10^{-7},\,3.66\cdot10^{-3}]$ at κ = 30 (ratio 3837). Since $2^{-20}=9.537\cdot10^{-7}$, the lower end is $9.54\cdot10^{-7}$ to three digits.
* Identification at $c=10^{-4}$ (best $g$):

| κ | $\delta_S$ | $u\ge$ | $\ell\le$ | $I\le$ | $L_S-K(S\mid a,\pi)\le$ | $e\le$ |
|---|---|---|---|---|---|---|
| 0 | 0 | 0.983 | $d+20.4$ | 37.7 | 37.7 | 0.199 |
| 0 | 20 | 0.983 | $d+20.6$ | 37.9 | 57.9 | 0.218 |
| 30 | 0 | 0.981 | $d+51.0$ | 98.3 | 98.3 | 0.274 |
| 30 | 20 | 0.981 | $d+51.2$ | 98.5 | 118.5 | 0.287 |

* At $c=10^{-3}$, κ = 0: $u\ge0.912$, $e\le0.270$. At $m=24$ ($L_S=187{,}457$), κ = 0, $c=10^{-4}$: $e\le0.065$; κ = 30: $e\le0.084$.
* The κ = 0 rows are illustrations. The κ = 30 rows show how the bounds degrade; any fixed κ gives numbers of the same kind, since every bound is explicit in κ.

**Corollary 2.5 (idiosyncratic errors, full truth table) [proved; computed: c3].** Take $m=d$, $n=2^d$, $B=\infty$, and let the data be the whole truth table, so $N=n$.
* A λ-MAP minimises $\lambda\ell+nR=n\,J_{\lambda/n}$, so it satisfies Theorem 2(ii) with $\eta=0$ and $c=\lambda/n$.
* For every $\lambda\in(1,\,n\,c_{\rm hi}]$, every λ-MAP satisfies:
  * $u(\pi)\ge\max\{3/4,\ 2^{-J_g(\lambda/n)}-p\}$;
  * $nR(\pi)\ge nH(p)-\lambda\Lambda_2/(\lambda-1)$;
  * $\ell(\pi)\le d+\kappa_g+\Lambda_2/(\lambda-1)$;
  * $I(\pi)\le\kappa_g+\Lambda_2/(\lambda-1)+\Lambda_3$;
  * the error-label bound (e).
* At λ = 1 three quantities are within $O(\log n)+\delta_E$ of each other: the optimum, $J_1(\pi_g)$ and $J_1(\pi_b)$. Indeed:
  * $J_1(\pi_g)\le d+\kappa_g+L_E+\log(n+1)$;
  * $J_1(\pi_b)\le d+\lceil L_E\rceil+\kappa_b$;
  * every level-1 program has $J_1\ge d+B_E-4-\Lambda_1$ by (D2);
  * every other program has $J_1\ge nG_1$, which exceeds $J_1(\pi_g)$ once $n(G_1-H(p))>d+\kappa_g+\log(n+1)$.
  
  So **λ = 1 does not determine whether the errors are memorised**; that depends on lower-order terms and the reference machine. **Every λ > 1 in the window does**, up to the slack $\Lambda_2/(\lambda-1)$.
* *Numbers* [computed: c3, $g=7$]. With κ = 0 (illustration), $d=m=20$, $p=2^{-10}$, $L_E=11{,}710$:
  * the window is $\lambda\in(1,\,1.19\cdot10^4]$; with κ = 30 it is $(1,6456]$;
  * at λ = 2: $u\ge0.991$, $\ell\le d+58.2$, $I\le70.8$ bits, $e\le0.225$;
  * at $\lambda=105$: $\ell\le d+15.7$, $I\le28.3$ bits, $e\le0.188$;
  * with κ = 30 the bounds weaken by tens of bits (λ = 105: $\ell\le d+46.3$, $I\le88.9$, $e\le0.266$).
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
* A minimiser satisfies $c\ell(\hat\pi)\le\hat J_c(\hat\pi)\le\hat J_c(\pi_{\rm ref})$, so $\ell(\hat\pi)\le\hat L$ on the first event.
* Combine. (This adapts T5 Lemma 1.2: it is one-sided and uses truncation, so no noise floor on hypotheses is needed.) ∎

**Corollary 2.7 (Hänni's numbers with sampled data) [proved; computed: c3].** Take $\pi_{\rm ref}=\pi_g$ and $A=\log(1/p)$. With probability at least $1-\delta$, every λ-MAP with $\lambda=cN$ satisfies Theorem 2(ii) with $\eta=\varepsilon_N$ (the excess in Lemma 2.6), whenever $J_g+\varepsilon_N<M_2$.

At $d=100$, $m=20$, $p=2^{-10}$, $B=30$, $\delta=0.01$, κ = 0 (illustration), $g=7$ [computed: c3]:

| $c$ | $N$ | $\varepsilon_N/c$ | $u\ge$ | $\ell\le$ | $e\le$ |
|---|---|---|---|---|---|
| $10^{-4}$ | $10^{11}$ | 9.2 bits | 0.9825 | $d+29.8$ | 0.212 |
| $10^{-4}$ | $10^{13}$ | 0.9 bits | 0.9830 | $d+21.5$ | 0.204 |
| $10^{-3}$ | $10^{11}$ | 0.7 bits | 0.9117 | $d+20.7$ | 0.274 |

The required $N$ is large because uniform convergence over all programs is pessimistic. Theorem 2 itself is a population statement.

**Example 2.7a (Hänni's Version 1, realised in population form) [proved, as an instance of Theorem 2; computed: c6(C)].**
* *Instance.* $d=100$, $m=10$, $p=2^{-6}$, so $s_0=16$, $L_S=115.6$ bits and $H(p)=0.116$. At $N=10^4$ the model saves $N(1-H(p))=8839$ bits for its 100 bits (88 bits per bit) and the error rule saves $NH(p)=1161$ bits for its 116 bits (10.0 bits per bit). These are Version 1's sizes and rates: a 100-bit model at about 100 bits per bit and a 100-bit error model at 10 bits per bit.
* *Window.* $c\in(2^{-10},c_{\rm hi}]$ with $c_{\rm hi}=5.80\cdot10^{-3}$ at κ = 0, $4.06\cdot10^{-3}$ at κ = 10, $2.53\cdot10^{-3}$ at κ = 30. At $N=10^4$ this reads $\lambda\in(9.77,58.0]$ at κ = 0; Hänni's three-hypothesis calculation gives $(10,100)$. The window is nonempty for every κ ≤ 30 checked.
* *What is proved in the window.* Every near-optimal hypothesis has $u>3/4$ and $\ell\le d+\Delta_\ell$. At κ = 0: $\ell\le d+47.8$ and $I\le65.0$ bits at $c=2.5\cdot10^{-3}$; $\ell\le d+28.3$ and $I\le45.6$ bits at $c=5.5\cdot10^{-3}$, out of $L_S=115.6$. Near the lower end of the window the information bound exceeds $L_S$ and says nothing. The error-label bound (e) is vacuous at these sizes, because $s_0=16$ is too small for the Hoeffding step. Below $c=6.9\cdot10^{-4}$ the memoriser beats every level-1 hypothesis with $R\ge H(p)$ (Thm 2(iv)).
* *Caveats.* This is the population objective. At $N=10^4$ samples Lemma 2.6 gives no guarantee: for every admissible $B\ge\log(1/p)=6$ its excess term is at least $6\sqrt{(d-4-\Lambda_1)\ln2/(2N)}=0.31$, while the margin $M_2-J_g$ is at most 0.22 anywhere in the window [computed: c6(H)]. The referee's full-table instance ($d=13$, $m=10$, $p=2^{-6}$; window $\lambda\in(8,86]$ at κ = 0) matches the error rule's size but not the model's.

**Proposition 2.8 (the power posterior concentrates on near-minimisers) [proved; computed: c5(e)].** Let $\lambda=cN$, let $D$ be any data set and let $\hat J_g:=\hat J_c(\pi_g)$. Then for every $\eta>0$,
$$\frac{\Pi_\lambda(\{\pi:\hat J_c(\pi)\ge\hat J_g+\eta\}\mid D)}{\Pi_\lambda(\pi_g\mid D)}\ \le\ 2^{-N\eta+(\hat J_g+\eta)/c}.$$

*Proof.*
* $2^{-\lambda\ell(\pi)}\nu_\pi(D)=2^{-N\hat J_c(\pi)}$.
* $N\hat J_c(\pi)-\ell(\pi)=(\lambda-1)\ell(\pi)+N\hat L(\pi)\ge(1-1/\lambda)N\hat J_c(\pi)$, where $\hat L$ is the empirical loss. This holds because $N\hat J_c/\lambda\ge\ell$.
* Summing $2^{-\ell(\pi)}2^{-(1-1/\lambda)N(\hat J_g+\eta)}$ over the set gives at most $2^{-(1-1/\lambda)N(\hat J_g+\eta)}$, by Kraft.
* Divide by $2^{-N\hat J_g}$ and use $N/\lambda=1/c$. ∎

*Consequence* [proved]. Combine Prop 2.8 with Lemma 2.6's uniform deviation bound, which applies to every empirical near-minimiser because $\ell\le\hat J_c/c$. With probability at least $1-\delta$, the steeper posterior with $\lambda=cN$ puts all but a $2^{-N\eta+(\hat J_g+\eta)/c}$ fraction of its mass on programs that satisfy Theorem 2(ii) with $\eta'=\eta+\varepsilon_N$, provided $J_g+\eta'<M_2$.
* Its predictive, averaged over $E$, gives the error label probability at most $\sup e(\pi)+2^{-N\eta+(\hat J_g+\eta)/c}$, the supremum over those programs.
* Averaged over the fresh error inputs $E\setminus\mathrm{dom}D$ instead, the bound is multiplied by $|E|/(|E|-N)$. This factor is negligible at $d=100$.
* Example (κ = 0, with $\hat J_g$ replaced by its population value $J_g=c(d+\kappa_g)+H(p)=0.0232$): $c=10^{-4}$, $\eta=10^{-3}$, $N=10^6$ gives a ratio of at most $2^{-758}$ [computed: c5(e), corrected in this revision; referee r1(F)].

### 2.5 Plain Bayes, MDL and SI learn the errors

**Proposition 2.9 [proved; computed: c3, c6(G)].**
* **(a) SFI (λ = 1).** Let $P$ be any predictor with $P\ge2^{-\ell(\pi)-\kappa}\nu_\pi$ for every program π of $\Pi_\times$: for example $\xi_\times=M_{\rm prod}$ (κ = 0) or $M_F$ (F Thm 4.2). For every sequence of distinct inputs and every $N$,
$$\sum_{i\le N}-\log P(y^*(x_i)\mid x_i,D_{i-1})\le\ell(\pi_b)+\kappa\le d+\lceil L_S\rceil+\kappa_b+\kappa.$$
  * So at most $d+L_S+O(\log dm)$ inputs, in total, receive probability below 1/2 for the teacher's label. Every other error input among those revealed gets the erroneous label with probability at least 1/2. For $M_F$ this is F's mistake bound (F Cor 6.6).
  * Explicitly: if all $2^d$ inputs are revealed, the error inputs number $p2^d$, and the fraction of them on which $P$ gives the erroneous label probability at least 1/2 is at least $1-(d+\lceil L_S\rceil+\kappa_b+\kappa)/(p2^d)$. At Hänni's sizes with κ = 0 this is $1-9.6\cdot10^{-24}$ [computed: c6(G)].
* **(b) MDL / λ-MAP for any *fixed* λ ≥ 1.** Apply Lemma 2.6 with $\pi_{\rm ref}=\pi_b$ ($A=0$), $c=\lambda/N$, $\hat L=d+\lceil L_S\rceil+\kappa_b$. With probability at least $1-\delta$, the MAP has
  $$R_B\le\frac{\lambda\hat L}N+B\sqrt{\frac{\hat L\ln2+\ln(2/\delta)}{2N}},$$
  hence $e(\hat\pi)\ge2^{-R_B/p}-2^{-B}$. This tends to $1-2^{-B}$ as $N$ grows (for $N\le2^d$). Numbers at λ = 1, κ = 0, $B=30$, $\delta=0.01$: $e\ge0.65$ at $N=10^{13}$ and $e\ge0.96$ at $N=10^{15}$.
* **(c) SI.** On the interleaved sequence with uniform i.i.d. inputs, Theorem 1(d) with λ = 1 gives $\mathbb E\sum_i-\log M(y_i\mid\cdot)\le K(\mu)+\kappa\le d+L_S+O(\log dm)$. For every λ > 1 the steeper SI predictor pays at most $\lambda\ell_U$ more.

*Proof.* (a) $P(D_N)\ge2^{-\ell(\pi_b)-\kappa}$, then telescope; each label with probability below 1/2 costs more than one bit. (b) Lemma 2.6, and $R_B(\hat\pi)\le J^B_c(\hat\pi)$; the error-label bound is as in Theorem 2(iii). (c) is Theorem 1(d). ∎

So the trick needs λ to grow like $N$. A **fixed** λ > 1 removes only noise (§3), not finite-complexity errors. This confirms Hänni's remark that the coefficient must increase with the data set. At $\lambda=cN$ the population selection is stable as $N$ grows. This keeps T5's correction of an earlier gloss ("only on a finite-sample window").

### 2.6 Limits

**Proposition 2.10 (fixed λ) [proved].** This is Prop 2.9(b): for fixed λ, the λ-MAP reproduces the systematic errors once $N$ is large.

**Proposition 2.11 (rate blindness in the junta family) [proved; computed: c3, c6(A)].** Here $B=\infty$ and the coin has length at most κ.
* **(i) Three-hypothesis form.** If
  $$\frac{H(p)}{\ell(\pi_b)-\ell(\pi_g)}\ \ge\ \frac{1-H(p)}{\ell(\pi_g)-\ell({\rm coin})},$$
  then at every $c$ the good-model program is beaten by the memoriser or beaten or tied by the coin.
  *Proof.* $J_c(\pi_b)<J_c(\pi_g)$ iff $c<H(p)/(\ell(\pi_b)-\ell(\pi_g))$; $J_c({\rm coin})\le J_c(\pi_g)$ iff $c\ge(1-H(p))/(\ell(\pi_g)-\ell({\rm coin}))$.
* **(ii) All hypotheses.** If
  $$\frac{H(p)}{\lceil L_S\rceil+\kappa_b+4+\Lambda_1}\ \ge\ \frac{1-H(p)}{d-4-\Lambda_1-\kappa},\qquad d-4-\Lambda_1-\kappa>0,\qquad(\star)$$
  then at every $c$, every program that knows the simple model ($u>3/4$) and fits no better than noise ($R\ge H(p)$) is beaten by the memoriser or beaten or tied by the coin.
  *Proof.*
  * Below the left-hand side, Theorem 2(iv) applies.
  * At or above it, $c(d-4-\Lambda_1-\kappa)\ge1-H(p)$, so (D1) gives $J_c(\pi)\ge c(d-4-\Lambda_1)+H(p)\ge1+c\kappa\ge J_c({\rm coin})$.
* **(iii)** For $c<2^{-m}$, Theorem 2(iii) shows that near-optimal programs reproduce the errors, under its condition on ρ.

**Lemma 2.11a (the criterion is robust in the machine constant) [proved; computed: c6(A)].** Fix $m$ and $r$ ($2\le r\le m$), and put $H:=H(2^{-r})$, $q:=(1-H)/H$,
$$a:=2+4q,\qquad b:=4+2\log m+2\kappa+q\big(\lceil L_S\rceil+4\log m+2\log s_0+2\kappa+4\big),\qquad F(d):=d-a\log d-b.$$
* (i) For every $d\ge1$, $(\star)$ holds iff $F(d)\ge0$.
* (ii) If $b\ge a/\ln2$, then $\{d\ge1:F(d)\ge0\}=[d_0,\infty)$ for a unique real $d_0$. So for each κ, criterion $(\star)$ holds for all $d\ge d_0(\kappa)$, and fails below.
* (iii) $b$ is affine in κ with slope $2+2q$, and $d_0=b+a\log d_0$. So $d_0(\kappa)$ grows linearly in κ, with slope $(2+2q)(1+o(1))$.

*Proof.*
* (i) Substitute $\Lambda_1=2\log d+2\log m+\kappa$ and $\kappa_b=2\log d+2\log m+2\log s_0+\kappa$. When both denominators of $(\star)$ are positive, $(\star)$ is equivalent to $H(d-4-\Lambda_1-\kappa)\ge(1-H)(\lceil L_S\rceil+\kappa_b+4+\Lambda_1)$, and the difference of the two sides is exactly $H\cdot F(d)$. Conversely, $F(d)\ge0$ implies $d-4-\Lambda_1-\kappa\ge F(d)+4q\log d+q(\lceil L_S\rceil+4)>0$, so the side condition of $(\star)$ holds.
* (ii) $F'(d)=1-a/(d\ln2)$, so $F$ is strictly increasing on $[a/\ln2,\infty)$ and tends to ∞. On $[1,a/\ln2]$, $F(d)\le d-b\le a/\ln2-b\le0$, with equality only if $d=1$ and $b=1$; but $b\ge4$. So $F<0$ there.
* (iii) is read off from the formula for $b$ and $F(d_0)=0$. ∎

[computed: c6(A): for every row of the table below, $b\ge a/\ln2$; $(\star)$ fails at $d_0-1$, holds at $d_0$, and holds at every one of about 400 values of $d$ in $[d_0,10^6]$.]

| error rule | κ = 0 | κ = 10 | κ = 20 | κ = 30 | κ = 50 | κ = 100 |
|---|---|---|---|---|---|---|
| $m=3$, $p=1/8$ (3-bit rule) | 49 | 90 | 130 | 169 | 245 | 434 |
| $m=4$, $p=1/16$ (single 4-bit prefix) | 106 | 172 | 236 | 299 | 422 | 727 |
| $m=6$, $p=1/64$ (single 6-bit prefix) | 450 | 639 | 823 | 1005 | 1364 | 2248 |
| $m=7$, $p=1/128$ (single 7-bit prefix) | 901 | 1231 | 1554 | 1873 | 2505 | 4063 |
| $m=6$, $p=1/8$ (8 prefixes of 6 bits) | 89 | 129 | 168 | 206 | 282 | 470 |

*The table gives $d_0(\kappa)$: the all-hypothesis rate-blindness criterion holds for every $d\ge d_0$.*

* **Robust statement.** For each fixed cheap error rule and each machine constant κ, there is an explicit $d_0(\kappa)$, linear in κ, such that for every $d\ge d_0(\kappa)$ no program that knows the parity and fits no better than noise is ever optimal, at any $c$. A cheap, frequent error rule defeats the trick once the simple model is long enough.
* **Illustrations at κ = 0** (not proved for any particular reference machine).
  * Three-hypothesis form, with lengths set equal to the upper bounds $d+\kappa_g$ and $d+\lceil L_S\rceil+\kappa_b$, at $d=100$: single 6- and 7-bit prefixes give "never selected", with margins 9.6 and 1.4 bits (the verdict flips if $\ell(\pi_b)-\ell(\pi_g)$ grows by that much); an 8-bit prefix leaves a window [computed: c3, c6(A), corrected for the ceiling bug].
  * All-hypothesis form: the 3-bit rule satisfies $(\star)$ at $d=100$ for κ ≤ 10 and fails for κ ≥ 20; the single 6-bit prefix needs $d\ge450$ at κ = 0.
  * In the memoriser regime of the single 6-bit prefix at $c=10^{-4}$, near-optimal programs give the error label probability $e\ge0.83$ [computed: c3].
  * By contrast, Hänni's 11,710-bit error rule ($m=20$) leaves a window of a factor of about 8000 (κ = 0) or 3800 (κ = 30).

**Proposition 2.12 (separable components; T5 Thm 3.2, re-derived) [proved; computed: c5(a)].**
* *Setting.* The inputs split into regions $X_1,\dots,X_k$, and hypotheses are products of per-region choices with additive code lengths.
* *Claim.* Each region independently picks the vertex of its own hull for slope $c$. If region $j$ offers "default" or "component $j$" (extra length $k_j$, population risk reduction $r_j$), then component $j$ is selected iff $r_j/k_j>c$; ties are arbitrary.
* *Consequence.* A valid component whose rate is at most an error component's rate cannot be kept without the error, except at a common tie value of $c$.
* *Proof.* The objective is a sum over regions. 0 violations in 8000 brute-force tests (c5(a)). ∎

The steeper penalty sorts by **rate**, not by validity. Two worlds with the same teacher channel $P^*$ and the same input law, one where a component is an error and one where it is a rare valid rule, receive the same selection at every $c$. *Proof:* $J_c$ depends on the data only through $P^*$ and the input law. This is T5 Thm 4.1, kept.

**Proposition 2.13 (guard erosion; T5 Prop 4.4, re-derived) [proved; computed: c5(b), c6(G)].**
* *Setting.* In some region (contexts where a schema σ applies), the teacher applies σ only when a guard $G$ holds (frequency $\pi_G$, per-use gain $g$). Otherwise (frequency $\pi_{\neg G}$) the teacher plays one of the other $M-1$ steps.
* *Options and rates.*
  * The options are "none" (uniform), "unguarded σ" (cost $k_\sigma$) and "guarded σ" (cost $k_\sigma+k_G$).
  * With teacher noise η, the unguarded option's rate is $\rho_\sigma=(\pi_Gg-\pi_{\neg G}\log(1/\eta))/k_\sigma$.
  * The guard's marginal rate is $\rho_G=\pi_{\neg G}\Delta_G/k_G$, with $\Delta_G=\log(M/\eta)-\log(M-1)$.
* *Claim.* If $\rho_G<\rho_\sigma$, then for $c\in(\rho_G,\rho_\sigma)$ the selected rule is the **unguarded** one, which is unsound although the teacher never erred. Otherwise the path goes guarded → none.
* *Proof.* The three options are the points $(0,0)$, $(k_\sigma,-k_\sigma\rho_\sigma)$ and $(k_\sigma+k_G,-k_\sigma\rho_\sigma-k_G\rho_G)$. The middle one is a vertex iff $\rho_\sigma>\rho_G$. Apply Lemma 1.2. ∎
* *Numbers.* For $\pi_G=0.05$, $\pi_{\neg G}=5\cdot10^{-4}$, $k_\sigma=22$, $k_G=12$, $M=64$, η = 0.05: unguarded on $(1.810\cdot10^{-4},1.223\cdot10^{-2})$. For $\pi_G=\pi_{\neg G}=0.002$: guarded → none at $c=3.203\cdot10^{-4}$ (exact crossing, c6(G); c5's grid gives $3.21\cdot10^{-4}$).

**Proposition 2.14 (λ cannot be chosen from imitation data; T5 Thm 4.3, re-derived) [proved; computed: c5(c)].**
* (i) For every strictly proper scoring rule, the expected score under the teacher's data is uniquely maximised by the teacher's channel $P^*(\cdot\mid x)$, errors included, at each $x$ of positive mass [known: definition and Gneiting & Raftery 2007, *JASA* 102:359–378 (verified)]. So any validation that estimates a strictly proper score on fresh imitation data prefers, among candidates, the one closest to $P^*$, not the norm. Computed for the log, Brier and spherical scores in Hänni's example.
* (ii) Along the population selection path, held-out log-loss $R(h_c)$ is nonincreasing as $c$ decreases (Lemma 1.2(ii)). So log-loss validation over a grid prefers the smallest grid value, i.e. the error-memorising end [computed: held-out loss 1.0, 0.0112, 0.0112, 0 at $c=10^{-1},10^{-3},10^{-5},10^{-7}$].
* (iii) In the twin worlds after Prop 2.12 every imitation-only rule picks the same $c$, so it is wrong in one of them.

SafeBayes learns the learning rate η = 1/λ from data by a sequential randomised log-loss [known: Grünwald 2012 (verified; content per abstract)]. By (i), it has no reason to move away from η = 1 in this well-specified imitation setting. This is my reading; the papers' exact criteria were not checked.

**Proposition 2.15 (the selection depends on the input law) [proved].** In the setting of Prop 2.12, let the inputs have law π, and let $\Delta_j$ be component $j$'s expected log-loss reduction per input of region $j$, given $x\in X_j$. Then $r_j=\pi(X_j)\Delta_j$, and component $j$ is selected iff $\pi(X_j)\Delta_j>c\,k_j$.
* So the window that keeps a valid component $j$ and drops an error component $j'$ is $c\in(\pi(X_{j'})\Delta_{j'}/k_{j'},\ \pi(X_j)\Delta_j/k_j)$. It moves with the input law, and it is empty once $\pi(X_{j'})/\pi(X_j)\ge\Delta_jk_{j'}/(\Delta_{j'}k_j)$.
* Under a shift from π to π′ with the same teacher channel, a $c$ chosen in π's window keeps the error in π′ iff $\pi'(X_{j'})\Delta_{j'}>ck_{j'}$.

*Proof.* The population risk is $\sum_j\pi(X_j)\mathbb E[\text{loss}\mid X_j]$, so choosing component $j$ changes $J_c$ by $ck_j-\pi(X_j)\Delta_j$. ∎

Theorem 2 is for uniform inputs. Its window depends on the input law through the same mechanism: the error rule's rate is proportional to the mass of $E$ (T5's remark (d7), here proved only in the separable case).

**Proposition 2.16 (steeper simplicity and unseen properties) [proved].** Work in the canonical product class $\Pi_\times$. Let $Q\subseteq X$ be decidable, $b$ partial computable, $D$ a data set with $\mathrm{dom}D\cap Q=\emptyset$, $S\subseteq Q\cap\mathrm{dom}\,b$ finite and $E:=b|_S$. Let $K(Q,b)$ be the length of a shortest self-delimiting code for a pair (decider for $Q$, program for $b$), as in the context track (§2.1 there). For every $\lambda\ge1$:
* (i) The "wrapped" programs, which answer $b(x)$ on $Q$ and run a program $p$ elsewhere, carry posterior mass exactly $2^{-\lambda(K(Q,b)+\kappa)}$ for a fixed κ; all of them output $b$ on $S$. Hence the steeper predictive gives the behaviour $b$ on all of $S$ probability at least $2^{-\lambda(K(Q,b)+\kappa)}$.
* (ii) For any two programs $\pi_1,\pi_2$ with $\nu_{\pi_1}(D)=\nu_{\pi_2}(D)>0$: $\Pi_\lambda(\pi_1\mid D)/\Pi_\lambda(\pi_2\mid D)=2^{-\lambda(\ell(\pi_1)-\ell(\pi_2))}$.

*Proof.*
* (i) Let $V'$ be the prefix machine that reads a code $z$ of a pair $(q,r)$, then $p\in\mathrm{dom}V$, and outputs an index of the conditional semimeasure "$[y=b(x)]$ if $q$ accepts $x$, else $\nu_{V(p)}(y\mid x)$". By simulation closure (§1.2) there is ρ with $V(\rho zp)=V'(zp)$; put κ := |ρ| and take $|z|=K(Q,b)$. Distinct $p$ give distinct programs $\rho zp$. Since $\mathrm{dom}D\cap Q=\emptyset$, $\nu_{\rho zp}(D)=\nu_p(D)$ and $\nu_{\rho zp}(D\cup E)=\nu_p(D)$. So $\sum_p2^{-\lambda|\rho zp|}\nu_{\rho zp}(D)=2^{-\lambda(K(Q,b)+\kappa)}\xi_\lambda(D)$, and the same sum with $D\cup E$ is a lower bound for $\xi_\lambda(D\cup E)$.
* (ii) Equal likelihoods cancel in the posterior ratio. ∎

*Reading.*
* At λ = 1, (i) is the context track's Prop 2.1 for $M_{\rm prod}$: Hänni's "simple property absent from training gives a constant probability of bad behaviour". With $\lambda=cN$ the lower bound $2^{-cN(K(Q,b)+\kappa)}$ vanishes, so steeper simplicity removes his constant lower bound.
* It does so by (ii): among hypotheses that fit the training data equally, posterior odds become $2^{-\lambda\Delta\ell}$. The steeper posterior concentrates on the shortest train-fitting hypotheses, whatever they do on $Q$. If the shortest one extrapolates well, steeper SFI is more reliable out of distribution than SFI. If a shorter hypothesis agrees on training data and is wrong on $Q$, steeper SFI is more confidently wrong. No guarantee about unseen properties follows.

**Limitation of the proof method.** Theorem 2's window needs $G_1>H(p)$, i.e. $p<0.056$. The identification constants at Hänni's sizes are modest, and Example 2.7a shows they become coarse when the error rule is small. A sharper analysis would replace the Jensen floor of Lemma 2.2 by a finer one (T5's Lemma 2.5c does this for the full-table case); it is not reused here.

---

## 3. The model-vs-randomness split

Hänni: "a preference for a simple sampler over a model where the sampled bits are filled in (solomonoff doesn't have a preference here, both get similar posterior)".

### 3.1 Setting

* ν is a computable conditional *measure* (a sampler: $\sum_y\nu(y\mid x)=1$) with a program $\pi_\nu$ of length $k$ in the class under consideration.
* Inputs $x_1,x_2,\dots$ are distinct and chosen by any rule, possibly adaptive or non-computable, before the corresponding label is drawn. Each label is drawn fresh, $y_i\sim\nu(\cdot\mid x_i)$; since inputs are distinct, this is frozen noise.
* $D_N$ is the first $N$ pairs. The **sampled randomness** is $-\log\nu(D_N)=\sum_i-\log\nu(y_i\mid x_i)$; it is about $NH$ if every $\nu(\cdot\mid x)$ has entropy $H$.
* **Fill-ins** are deterministic programs consistent with $D_N$: they reproduce the sampled labels on the seen inputs and output anything elsewhere. Their total weight is $W_{\rm det}(D):=\sum_{\pi\ \rm det,\ \nu_\pi\supseteq D}2^{-\ell(\pi)}$.

**Lemma 3.1 (Ville deficiency) [proved; computed: c4(A)].** Let ξ be any shared hypothesis with $\xi(\emptyset)\le1$; in particular the mixture $\xi_{\mathcal C}:=\sum_{\pi\in\mathcal C}2^{-\ell(\pi)}\nu_\pi$ of any countable product class $\mathcal C$ with $\sum_{\mathcal C}2^{-\ell}\le1$ (for $\Pi_\times$ this is $M_{\rm prod}$). Let $m^*:=\sup_N\log(\xi(D_N)/\nu(D_N))$. Then:
* $\Pr[m^*\ge m]\le2^{-m}$ for all $m\ge0$;
* consequently, for $\xi=\xi_{\mathcal C}$, every $\pi\in\mathcal C$ and every $N$: $\nu_\pi(D_N)\le2^{\ell(\pi)+m^*}\nu(D_N)$.

*Proof.*
* $Z_N:=\xi(D_N)/\nu(D_N)$ satisfies $\mathbb E[Z_{N+1}\mid\mathcal F_N,x_{N+1}]=\sum_y\xi(D_N\cup\{(x_{N+1},y)\})/\nu(D_N)\le Z_N$, by the one-point inequality. So it is a nonnegative supermartingale with $Z_0\le1$; adaptive inputs are allowed because $x_{N+1}$ is $\mathcal F_N$-measurable given the selector's own randomness.
* Ville's maximal inequality gives $\Pr[\sup Z_N\ge a]\le1/a$ [known: Ville 1939; Doob's maximal inequality].
* For the consequence, $\xi_{\mathcal C}\ge2^{-\ell(\pi)}\nu_\pi$.
* Simulation: empirical $\Pr[\sup\ge m]$ was 0.119, 0.055, 0.032, 0.014, 0.003 for $m=1,2,3,4,6$, all below $2^{-m}$ (c4(A)). ∎

**Lemma 3.2 (derandomising a dyadic sampler by hashing) [proved; computed: c4(B), c6(E); referee r5].**
* *Setting.* The class is the canonical $\Pi_\times$. ν is a product measure whose values are multiples of $2^{-r}$, and $\pi_\nu\in\Pi_\times$ is a program for it with $|\pi_\nu|=k$. $D$ is a data set with $N$ inputs, all of length at most $n$.
* *Claim.*
$$W_{\rm det}(D)\ \ge\ 2^{-k-2\log(N+1)-2\log(n+1)-2\log(r+1)-\kappa}\,\nu(D).$$

*Proof.*
* *Exact values.* From the index $V(\pi_\nu)$ and $r$ one computes ν exactly. Enumerate lower approximations $\nu_t(y\mid x)\uparrow\nu(y\mid x)$ until $\sum_y\nu_t(y\mid x)>1-2^{-r}$; this happens because ν is a measure and $Y$ is finite. Then every deficit $\nu-\nu_t$ is below $2^{-r}$, and $\nu(y\mid x)$ is the least multiple of $2^{-r}$ that is $\ge\nu_t(y\mid x)$.
* *Canonical sampler.* For $b\in\{0,\dots,2^r-1\}$ let $\sigma(x,b)$ be the label $y$ whose cumulative interval $[\sum_{y'<y}\nu(y'\mid x),\sum_{y'\le y}\nu(y'\mid x))$ contains $b2^{-r}$. Then $\Pr_b[\sigma(x,b)=y]=\nu(y\mid x)$.
* *Hash.* Let $q:=\max(n+1,r)$, fix (computably from $q$) an irreducible polynomial of degree $q$ over GF(2), and embed $\{0,1\}^{\le n}$ injectively in $GF(2^q)$ by $x\mapsto$ the element with coefficient vector $1x$. For a seed $s\in GF(2^q)^N$ let $h_s(x)$ be the first $r$ coefficient bits of $\sum_{j<N}s_j\iota(x)^j$. For distinct $x_1,\dots,x_N$, the map $s\mapsto(\sum_js_j\iota(x_i)^j)_{i\le N}$ is a bijection (Vandermonde with distinct nodes). So for uniform $s$ the values $h_s(x_i)$ are independent and uniform on $\{0,1\}^r$.
* *Programs, one per seed.* Let $V'$ be the prefix machine that reads $\pi_\nu$ (by simulating $V$, which consumes exactly $\pi_\nu$), then self-delimiting codes of $N,n,r$, then $qN$ bits $s$, and outputs an index of the deterministic conditional semimeasure $x\mapsto\sigma(x,h_s(x))$ on $\{0,1\}^{\le n}$ (undefined elsewhere). By simulation closure (§1.2) there is ρ with $V(\rho w)=V'(w)$. The programs $p_s:=\rho\,\pi_\nu\langle N\rangle\langle n\rangle\langle r\rangle s$ are distinct for distinct $s$, deterministic, and have length $L_0+qN$ with $L_0\le k+2\log(N+1)+2\log(n+1)+2\log(r+1)+\kappa$.
* *Sum.* $\sum_s2^{-|p_s|}[\nu_{p_s}\supseteq D]=2^{-L_0}\Pr_s[\forall i:\sigma(x_i,h_s(x_i))=y_i]=2^{-L_0}\prod_i\nu(y_i\mid x_i)=2^{-L_0}\nu(D)$. ∎

[computed: c4(B) checks the independence exactly over GF(16) for $N\le3$ (3232 cases, maximum error 0). c6(E) checks the full statement with the embedding $1x$, $q=\max(n+1,r)$, $r\in\{2,3,4\}$, $|Y|=3$ and $N\le3$: 2106 cases, maximum error 0. The referee's r5 confirms the independence over GF(32) and shows that distinct seeds often give the same function on $X$; the sum above is over programs, so this does not matter.]

F Prop 4.4 proves the fair-coin case, at cost $K(n,k)$, with the same hash family; F's remark after it sketches the dyadic case, which Lemma 3.2 proves. In the function-machine version of SFI (one random tape), a sampler is itself a union of cylinders, each fixing the bits it reads; these are "fill-ins" with no $K(N)$ cost. Lemma 3.2 is what the program mixture (brief H1(b)) and the product class need.

### 3.2 λ = 1: the sampler and its fill-ins get similar posterior

**Theorem 3 (SFI, λ = 1) [proved].** In the setting of §3.1 with the canonical class $\Pi_\times$, for a dyadic sampler as in Lemma 3.2, and simultaneously for all $N$, with $n_N:=\max_{i\le N}|x_i|$:
* (i) $\Pi_1(\pi_\nu\mid D_N)\ge2^{-k-m^*}$;
* (ii) $\Pi_1(\mathrm{det}\mid D_N)=W_{\rm det}(D_N)/\xi_\times(D_N)\ge2^{-k-2\log(N+1)-2\log(n_N+1)-2\log(r+1)-\kappa-m^*}$;
* (iii) the posterior odds of all fill-ins against the sampler program lie in
$$\big[\,2^{-2\log(N+1)-2\log(n_N+1)-2\log(r+1)-\kappa},\ \ 2^{k+m^*}\big],$$
whatever the sampled randomness $-\log\nu(D_N)$.

*Proof.*
* (i) $\Pi_1(\pi_\nu\mid D)=2^{-k}\nu(D)/\xi_\times(D)$; apply Lemma 3.1.
* (ii) Lemma 3.2 and Lemma 3.1.
* (iii) The lower end is Lemma 3.2 divided by $2^{-k}\nu(D_N)$. For the upper end, $W_{\rm det}\le\xi_\times\le2^{m^*}\nu$. ∎

**Proposition 3.3 (SI, λ = 1) [proved].**
* *Setting.* A string $z=z_{1:n}$ is drawn from a computable measure μ with $K(\mu)=k$. Let ξ be Solomonoff's mixture over lower-semicomputable semimeasures with weights $2^{-K}$, and let $m^*:=\sup_n\log(\xi(z_{1:n})/\mu(z_{1:n}))$.
* (i) $\pi(\mu\mid z_{1:n})\ge2^{-k-m^*}$ for all $n$, with $\Pr[m^*\ge m]\le2^{-m}$. This is the same proof as Lemma 3.1.
* (ii) The deterministic hypotheses consistent with $z$ (point masses on computable infinite extensions) have total weight at least $2^{-k-K(n)-\kappa}\mu(z)$. A single one suffices: $w=z0^\infty$ has $K(\delta_w)\le K(z)+\kappa\le K(n)+K(z\mid n)+\kappa\le K(n)+k-\log\mu(z)+\kappa$, by (F2) applied to μ restricted to length $n$.
* (iii) In Solomonoff's deterministic-program representation $M=\sum_p2^{-|p|}$, *every* hypothesis is a fill-in. The sampler appears only as the set of programs "decoder for μ, then a code of $z$", whose total weight is at least $2^{-k-\kappa}\mu(z)$ [known: this is the usual proof of $M\ge2^{-K(\mu)-\kappa}\mu$].

So Hänni's claim "both get similar posterior" holds in SI and in SFI, up to factors $2^{O(k+\log N+\log n+\log r)}$ (SFI) or $2^{O(k+K(n))}$ (SI) and the Ville deficiency. The odds do not depend on how much randomness was sampled. In SI no hashing is needed, because a fill-in may output the whole sequence.

### 3.3 λ > 1 with private randomness: the sampler wins

Call π **ν-equivalent on the run** if $\sum_N\mathrm{H}^2\big(\nu(\cdot\mid x_N),\nu_\pi(\cdot\mid x_N)\big)<\infty$, where $\mathrm H^2(P,Q):=1-\sum_y\sqrt{P(y)Q(y)}$. For a sub-probability $Q$, $\mathrm H^2\in[0,1]$ still holds.

**Theorem 4 (SFI with private randomness, λ > 1) [proved; computed: c4(C); referee r4].** Let $\mathcal C$ be any countable class of product programs with $\sum_{\mathcal C}2^{-\ell}\le1$ that contains $\pi_\nu$ (for example $\Pi_\times$, or a time-bounded or circuit subclass). Fix $\lambda>1$, and define $m^*$ from $\xi_{\mathcal C}$. Simultaneously for all $N$:
* **(i) MAP.** Every λ-MAP $\hat\pi_N$ has $\ell(\hat\pi_N)\le(\lambda k+m^*)/(\lambda-1)$ and $-\log\nu(D_N)-\ell(\hat\pi_N)-m^*\le-\log\nu_{\hat\pi_N}(D_N)\le-\log\nu(D_N)+\lambda k$.
* **(ii) Length tail.** $\Pi_\lambda(\{\pi:\ell(\pi)>L\}\mid D_N)\le2^{\lambda k+m^*-(\lambda-1)L}$.
* **(iii) Fill-ins.**
  * Every deterministic program consistent with $D_N$ has $\ell\ge-\log\nu(D_N)-m^*$.
  * $\Pi_\lambda(\mathrm{det}\mid D_N)\le2^{\lambda k+\lambda m^*-(\lambda-1)(-\log\nu(D_N))}$.
  * For the tempered posterior with $\eta=1/\lambda$: $\Pi^\eta(\mathrm{det}\mid D_N)\le2^{k+m^*-(1-\eta)(-\log\nu(D_N))}$.
* **(iv) Identification.** Suppose the input sequence is infinite (so $X$ is infinite). Almost surely:
  * from some $N$ on, every λ-MAP is ν-equivalent on the run;
  * $\Pi_\lambda(\nu\text{-equivalent on the run}\mid D_N)\to1$.

*Proof.*
* (i)
  * $J_\lambda(\hat\pi)\le J_\lambda(\pi_\nu)=\lambda k-\log\nu(D)$.
  * By Lemma 3.1, $-\log\nu_{\hat\pi}(D)\ge-\log\nu(D)-\ell(\hat\pi)-m^*$. Substituting gives $(\lambda-1)\ell(\hat\pi)\le\lambda k+m^*$.
  * The upper bound on the loss is $J_\lambda(\hat\pi)\le J_\lambda(\pi_\nu)$.
* (ii)
  * $\sum_{\ell(\pi)>L}2^{-\lambda\ell(\pi)}\nu_\pi(D)\le2^{-(\lambda-1)L}\xi_{\mathcal C}(D)\le2^{-(\lambda-1)L+m^*}\nu(D)$.
  * The normaliser is at least $2^{-\lambda k}\nu(D)$.
* (iii)
  * A consistent deterministic π has $1=\nu_\pi(D)\le2^{\ell(\pi)+m^*}\nu(D)$, which gives the length bound.
  * Power posterior: $\sum_{\rm det}2^{-\lambda\ell}\le2^{-(\lambda-1)(-\log\nu(D)-m^*)}W_{\rm det}(D)$, $W_{\rm det}\le\xi_{\mathcal C}\le2^{m^*}\nu(D)$, and the normaliser is at least $2^{-\lambda k}\nu(D)$.
  * Tempered posterior: the fill-ins' weight is $W_{\rm det}\le2^{m^*}\nu(D)$, and the sampler's is $2^{-k}\nu(D)^\eta$.
* (iv)
  * *Likelihood ratios vanish.* Fix π and let $\Lambda_N:=\nu_\pi(D_N)/\nu(D_N)$. Conditionally on the past and on $x_{N+1}$, $\mathbb E\sqrt{\Lambda_{N+1}/\Lambda_N}=1-\mathrm H^2_{N+1}$.
    * If some $\mathrm H^2_i=1$, then $\Lambda=0$ almost surely from that point on.
    * Otherwise $\sqrt{\Lambda_N}/\prod_{i\le N}(1-\mathrm H^2_i)$ is a nonnegative martingale ($\mathrm H^2_i$ is predictable), so it converges almost surely to a finite limit. On $\{\sum\mathrm H^2_i=\infty\}$ the product tends to 0, hence $\Lambda_N\to0$.
    * This is the Kakutani-type argument [known: Kakutani 1948, *Ann. Math.* 49:214–224 (verified)]. It holds for adaptive inputs.
  * *Countably many programs.* There are countably many π, so almost surely the following hold simultaneously: $m^*<\infty$, and $\Lambda_N(\pi)\to0$ for every π that is not ν-equivalent on the run.
  * *MAPs.* MAPs lie in the finite set $\{\ell\le L\}$ with $L=(\lambda k+m^*)/(\lambda-1)$, by (i). A MAP has $\Lambda_N(\hat\pi)\ge2^{\lambda\ell(\hat\pi)-\lambda k}\ge2^{-\lambda k}$. Each non-equivalent π in that finite set eventually has $\Lambda_N<2^{-\lambda k}$.
  * *Posterior.* $\Pi_\lambda(\text{non-equivalent}\mid D_N)\le2^{\lambda k}\big[\sum_{\ell(\pi)\le L,\ \text{non-eq}}2^{-\lambda\ell(\pi)}\Lambda_N(\pi)\big]+2^{\lambda k+m^*-(\lambda-1)L}$ for every $L$. The first term tends to 0; then let $L\to\infty$. ∎

So, uniformly in $N$, the steeper SFI posterior puts exponentially little (but positive) mass on fill-ins, in the amount of sampled randomness. Its MAP has bounded length. With infinitely many distinct inputs, both eventually sit on samplers equivalent to ν on the run. **This is the split Hänni hoped for, with any fixed λ > 1.** The model is the shortest ν-equivalent sampler, up to the slack $(k+m^*)/(\lambda-1)$; the randomness is everything else. On a finite domain such as $\{0,1\}^n$, (iv) is vacuous and (i)–(iii) are the content.

### 3.4 λ > 1 with shared randomness: no split

**Theorem 5 (SI, or SFI with shared randomness, λ > 1) [proved; computed: c4(C); referee r4].** Assume (Dom) and $\xi_1\le2^{c_1}U$, and let $\lambda>1$. Let $\pi_\nu$ be a program for a sampler, of length $k$, in the class. For every observation:
* (i) If $(\lambda-1)k>\lambda\ell_U+c_0$, then $J_\lambda(\pi_U)<J_\lambda(\pi_\nu)$: the sampler program is never a λ-MAP, and every λ-MAP has length at most $L_\lambda<k$.
* (ii) For every set $A$ of programs: $\Pi_\lambda(A\mid o)\le2^{-(\lambda-1)\min_{\pi\in A}\ell(\pi)+\lambda\ell_U+c_1}$. In particular the power posterior puts at most $2^{-(\lambda-1)L+\lambda\ell_U+c_1}$ on all programs of length ≥ L, on every observation.

*Proof.*
* (i) $J_\lambda(\pi_U)=\lambda\ell_U-\log U(o)\le\lambda\ell_U+c_0+k-\log P_{\pi_\nu}(o)<\lambda k-\log P_{\pi_\nu}(o)=J_\lambda(\pi_\nu)$.
* (ii) $\sum_{\pi\in A}2^{-\lambda\ell(\pi)}P_\pi(o)\le2^{-(\lambda-1)\min_A\ell}\xi_1(o)\le2^{-(\lambda-1)\min_A\ell+c_1}U(o)$. The normaliser is at least $2^{-\lambda\ell_U}U(o)$. ∎

Compare Theorem 4.
* In a shared class, the steeper posterior lives, up to $2^{-s}$, on programs of length at most $(\lambda\ell_U+c_1+s)/(\lambda-1)$, **whatever the data**.
* In the product class, it concentrates on ν-equivalent samplers, whose length is at least the shortest ν-equivalent program's, and that is unbounded over ν.
* Predictively both converge to ν's predictions. In $\Pi_F$, $U=M_F$ satisfies $-\log M_F(D)\le-\log\nu(D)+K(\nu)+\kappa$ on every input sequence (F Thm 6.1), so the merging bound F Thm 6.5 applies for every input rule that sees only the past. In SI on the interleaved sequence this needs the inputs to be modelled (Thm 1(d)); for adaptive or non-computable inputs use $\Pi_{\rm chr}$ with $U=M_H\asymp\xi$, which dominates every lower-semicomputable chronological semimeasure on every input sequence (history Cor 4.3). The difference is *what the selected hypothesis is*:
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

**Definitions** [known: Gács, Tromp & Vitányi 2001, *IEEE Trans. IT* 47(6):2443–2463; Vereshchagin & Vitányi 2004, *IEEE Trans. IT* 50(12):3265–3290; Vereshchagin & Shen 2017, "Algorithmic statistics: forty years later", in *Computability and Complexity*, LNCS 10010, 669–737 (all verified bibliographically); the content below is standard, but exact statements were not checked against the papers].

For a string $z$, a *set model* is a finite set $S\ni z$, with two-part length $K(S)+\log|S|$.
* *Kolmogorov structure function*: $h_z(\alpha):=\min\{\log|S|:S\ni z,\ K(S)\le\alpha\}$ (Kolmogorov's 1974 Tallinn talk, as reported in these papers).
* *Sufficiency line*: $K(S)+\log|S|\ge K(z)-\kappa$ for every $S\ni z$. *Proof:* $K(z\mid S)\le\log|S|+\kappa$, since $|S|$ is known from $S$, and (F3).
* $S$ is *c-sufficient* if $K(S)+\log|S|\le K(z)+c$ (GTV 2001's algorithmic sufficient statistic).
* A *minimal sufficient statistic* (MSS) minimises $K(S)$ among c-sufficient $S$.
* *Set sophistication*: $\mathrm{soph}^{\rm set}_c(z):=\min\{K(S):S\ni z,\ K(S)+\log|S|\le K(z)+c\}$. Conditional on a string $w$ (for example a domain), replace $K$ by $K(\cdot\mid w)$ throughout.
  * Koppel defined sophistication with total programs [known: Koppel 1987, *Complex Systems* 1(6):1087–1091; Koppel & Atlan 1991, *Inform. Sci.* 56:23–33 (verified)].
  * Vitányi relates it to the minimal sufficient statistic in the model class of total recursive functions [known: Vitányi 2006, "Meaningful information", *IEEE Trans. IT* 52(10):4617–4626 (verified; content per abstract)].
  * Antunes and Fortnow revisit the definitions, including coarse sophistication [known: Antunes & Fortnow 2009, *Theory Comput. Syst.* 45(1):150–161 (verified bibliographically; content unverified)].
  * The equivalences between versions were not checked here. The set version is used as a definition.
* VV 2004 show (per their abstract) that the structure function determines the data's stochastic properties and can take essentially all shapes; the exact side conditions are unverified.

**Proposition 3.5 (steeper two-part codes over sets) [proved].** Let $\lambda>1$, and let $S_\lambda$ minimise $\lambda K(S)+\log|S|$ over $S\ni z$ (a minimiser exists because only finitely many $S$ have $K(S)\le L$). Then for every $c\ge0$:
* $K(S_\lambda)\le\mathrm{soph}^{\rm set}_c(z)+(c+\kappa)/(\lambda-1)$;
* $S_\lambda$ is $(c+(\lambda-1)\mathrm{soph}^{\rm set}_c(z))$-sufficient.

*Proof.*
* Let $S_c$ attain $\mathrm{soph}_c$. Then $\lambda K(S_\lambda)+\log|S_\lambda|\le\lambda K(S_c)+\log|S_c|\le(\lambda-1)\mathrm{soph}_c+K(z)+c$.
* Subtract the sufficiency line $K(S_\lambda)+\log|S_\lambda|\ge K(z)-\kappa$ for the first claim. For the second, use $K(S_\lambda)+\log|S_\lambda|\le\lambda K(S_\lambda)+\log|S_\lambda|$. ∎

*Reading (corrected).* The two bounds trade off. As λ → 1 the slack $(c+\kappa)/(\lambda-1)$ in the first bound blows up; as λ grows the sufficiency deficiency $(\lambda-1)\mathrm{soph}_c$ grows. The proposition is useful at λ − 1 = Θ(1) when the sophistication is small: then $S_\lambda$ is within $O(c+\kappa)$ of minimal and within $O(c+\mathrm{soph}_c)$ of sufficient. At λ = 1 the selection is indifferent along the sufficiency line. (`notes.md` said "λ slightly above 1 selects an approximately minimal sufficient statistic". **[refuted]** as a reading of the proposition: as λ → 1 the length bound $\mathrm{soph}_c+(c+\kappa)/(\lambda-1)$ becomes vacuous, so the proposition says nothing about minimality there.)

**Definition (product versions).** For a data set $D$ and the class $\Pi_\times$:
* the *product structure function* is $\rho^\times_D(\alpha):=\min\{-\log\nu_\pi(D):\ell(\pi)\le\alpha\}$;
* π is *product-c-sufficient* if $\ell(\pi)-\log\nu_\pi(D)\le K(y_D\mid\mathrm{dom}D)+c$;
* *product sophistication* is $\mathrm{soph}^\times_c(D):=\min\{\ell(\pi):\pi$ product-c-sufficient$\}$.

Lemma 1.6 is the product sufficiency line. Product notions are conditional on the domain by construction, since product hypotheses do not model the inputs.

**Proposition 3.6 [proved].** Every λ-MAP over $\Pi_\times$ has length at most $\mathrm{soph}^\times_c(D)+(c+\kappa)/(\lambda-1)$ and is $(c+(\lambda-1)\mathrm{soph}^\times_c(D))$-product-sufficient. *Proof:* as in Prop 3.5, with Lemma 1.6. The same trade-off reading applies. ∎

**Proposition 3.7 (sets are at least as coarse as products) [proved for computable hypotheses; believed to be the standard translation between distribution and set models].**
* *Claim.* Let π be product-c-sufficient for $D$, and let $\nu_\pi$ be a computable measure with rational values. Put $\rho:=\lceil-\log\nu_\pi(D)\rceil$ (so ρ is of order $N$ and $\log\rho$ of order $\log N$). Then the set $S:=\{y'\in Y^{\mathrm{dom}D}:\nu_\pi(\mathrm{dom}D\mapsto y')\ge2^{-\rho}\}$ contains $y_D$, has $K(S\mid\mathrm{dom}D)\le\ell(\pi)+2\log(\rho+1)+\kappa$, and is $(c+2\log(\rho+1)+\kappa)$-sufficient **conditionally on** $\mathrm{dom}D$:
  $$K(S\mid\mathrm{dom}D)+\log|S|\le K(y_D\mid\mathrm{dom}D)+c+2\log(\rho+1)+\kappa.$$
* *Proof.* $S$ is computable from $(\pi,\mathrm{dom}D,\rho)$ because $Y$ is finite and $\nu_\pi$ is computable with rational values; it contains $y_D$; and $|S|\le2^\rho$ because $\nu_\pi(\mathrm{dom}D\mapsto\cdot)$ sums to at most 1. So $K(S\mid\mathrm{dom}D)+\log|S|\le\ell(\pi)+2\log(\rho+1)+\kappa+\rho\le\ell(\pi)-\log\nu_\pi(D)+1+2\log(\rho+1)+\kappa$. ∎
* *Consequence.* $\mathrm{soph}^{\rm set}_{c'}(y_D\mid\mathrm{dom}D)\le\mathrm{soph}^\times_c(D)+2\log(\rho+1)+\kappa$ with $c'=c+2\log(\rho+1)+\kappa$, provided a computable rational product hypothesis attains $\mathrm{soph}^\times_c(D)$. The comparison is with *conditional* set sophistication. Against unconditional set sophistication of a string, add $K(\mathrm{dom}D)$. For lower-semicomputable hypotheses this $S$ is only c.e.; that case is open here.
* *Status.* Vereshchagin–Shen 2017 state, per a search snippet, that set and distribution models are equivalent with logarithmic precision. The thresholding above is presumably that translation; this was not checked against the paper.

**Proposition 3.8 (the two splits differ by ≈ d bits: noisy random parity) [proved; computed: c2(c), c4(C)].**
* *Setting.* Setting 2.0 with $m=d$, $n=2^d$, $p<1/4$ and $G_1>H(p)$ (true for $p<0.056$). Let $z=y^*\in\{0,1\}^n$ be the full table and $D$ the full data set, so $\mathrm{dom}D=\{0,1\}^d$ and $K(y_D\mid\mathrm{dom}D)=K(z\mid d)\pm\kappa$. Let $\delta_E:=L_E-K(E\mid a,K(a))$.
* **(i) Sets: the parity is noise.** $S_0:=\{f_{a'}\oplus1_{E'}:a'\in\{0,1\}^d,|E'|=pn\}$ has the following properties.
  * $|S_0|=2^{d+L_E}$. The map $(a',E')\mapsto$ table is injective, since two distinct parities differ on $n/2>2pn$ inputs.
  * $K(S_0\mid d)\le2\log r+\kappa$ and $K(S_0)\le2\log d+2\log r+\kappa$.
  * $K(z)\ge K(a,E)-\kappa\ge d+L_E-\delta_E-\kappa$: $z$ determines $(a,E)$ by minimum-distance decoding, and (F4).
  
  So $S_0$ is $(\delta_E+2\log d+2\log r+\kappa)$-sufficient, and $\mathrm{soph}^{\rm set}_c(z)\le2\log d+2\log r+\kappa$ for such $c$.
  * *Flatness* [proved]. For $0\le u\le d$ let $S_u$ be the subset of $S_0$ whose parities agree with $a$ on the first $d-u$ coordinates. Then $\log|S_u|=u+L_E$ and $K(S_u)\le d-u+2\log d+2\log(u+1)+2\log r+\kappa$, so every $S_u$ has two-part length $d+L_E+O(\log d)$, within $\delta_E+O(\log d)$ of the sufficiency line. The set structure function lies on the sufficiency line from $\alpha=O(\log d)$ on. (c2(c) prints these totals; they are this one-line computation, not an independent check.)
  * By Prop 3.5, every λ-optimal set model with λ > 1 knows at most $O(\log d)+(\delta_E+O(\log d))/(\lambda-1)$ bits of $a$, since $K(a\mid S)\ge d-K(S)-\kappa$.
* **(ii) Products: the parity is model.** For $\delta_E+2\log d+\kappa_g+\log(n+1)+\kappa\le c<n(G_1-H(p))-d-2\log n-\kappa$:
  $$d-4-\Lambda_1\ \le\ \mathrm{soph}^\times_c(D)\ \le\ d+\kappa_g.$$
  The product structure function satisfies $\rho^\times(\alpha)\ge nG_1$ for $\alpha<d-4-\Lambda_1$: a kink at $\alpha\approx d$.
  
  *Proof.*
  * Upper bound: the good model's two-part length is $\ell(\pi_g)+nH(p)\le d+\kappa_g+L_E+\log(n+1)\le K(z\mid d)+\delta_E+2\log d+\kappa_g+\log(n+1)+\kappa$, using $K(z\mid d)\ge K(z)-2\log d-\kappa\ge d+L_E-\delta_E-2\log d-\kappa$.
  * Lower bound: a product-c-sufficient π with $T(\pi)\ge2$ would have $\ell+nR\ge nG_1>K(z\mid d)+c$ by Lemma 2.2 (with $B=\infty$). Here $K(z\mid d)\le d+nH(p)+2\log n+\kappa$, using the memoriser program. So $T(\pi)=1$, and (D1) applies.
  * The kink: $\ell<d-4-\Lambda_1$ forces $T\ge2$ by (D1), hence $R\ge G_1$.
* **(iii)** The gap $\mathrm{soph}^\times-\mathrm{soph}^{\rm set}\ge d-O(\log d)$ is unbounded in $d$.

**Relation to restricted model families** (referee M3).
* Algorithmic statistics has studied model families other than all finite sets.
  * Vereshchagin & Vitányi, "Rate distortion and denoising of individual data using Kolmogorov complexity", *IEEE Trans. IT* 56(7):3438–3454, 2010 [known (verified bibliographically); content per abstract and snippet]. It studies distortion balls containing a word, including Hamming balls, through the minimal complexity of a ball of given size containing the word (a canonical rate-distortion function, which can take many shapes). It argues that low-complexity balls capture the word's meaningful properties, which suggests denoising.
  * Milovanov (CSR 2016) restricts hypotheses to Vereshchagin's "strong models" and studies "normal" strings [known (snippet); unverified].
  * Set and distribution models are equivalent up to logarithmic terms (Vereshchagin–Shen 2017, per snippet).
* For the full-table parity, the Hamming ball of radius $pn$ around $f_a$ is a set model with complexity about $d$ and log-size about $nH(p)$: exactly "parity + i.i.d. flips" as a set. So the kink of $\rho^\times$ at $\alpha\approx d$ (Prop 3.8(ii)) is the same phenomenon as the kink in the Hamming-ball-restricted rate-distortion curve at the centre's complexity. Restricting the model family moves the split; that is known.
* What the product view adds, as far as a snippet-level search can tell:
  * a family defined by an operational constraint (private randomness per input, i.e. x-only samplers) rather than by a geometric family, for general lower-semicomputable product models on partial data sets;
  * its role as the hypothesis class of steeper SFI, with the absorption contrast (Thm 1 vs Cor 1.4) and the selection theorems (Thms 2, 4);
  * structured, non-i.i.d. "noise" (the junta error rule of Thm 2) with information-theoretic identification bounds.
  
  These should be checked against VV 2010 and the restricted-model literature before any novelty claim is published.

**Reading.**
* With shared randomness (sets, or any shared model), a uniformly random $d$-bit parameter costs the same in the model as in the data-to-model code. That is Hänni's "1 bit paying for 1 bit". So algorithmic statistics' minimal sufficient statistic treats the parity's parameter as *noise*, and the sophistication of a noisy random parity is $O(\log d)$.
* With private randomness the parameter cannot be moved into the noise: not knowing it costs about one bit *per input*. So the product split keeps it in the model.
* For supervised learning the product split is the relevant one. "The model" is the part of the description reused across inputs.
* This is also why steeper simplicity is useless over set models in the parity example (T5 Thm 2.5(a); Prop 3.8(i)) and decisive over product models (Thm 2, Cor 2.5).

### 3.6 What is new

* **Known:**
  * two-part codes and MDL, including complexity weights above 1 (Barron–Cover's α > 1, per a secondary source);
  * the structure function, sufficient statistics, the MSS and sophistication (with the citations above);
  * restricted model families in algorithmic statistics (Hamming and other distortion balls, strong models) and the equivalence of set and distribution models up to $O(\log)$;
  * tempered, fractional and generalised posteriors and their consistency theory;
  * Solomonoff's and Bayes' dominance bounds; Kakutani's dichotomy; Ville's inequality; $k$-wise independent hashing.
* **Not found in a snippet-level search** (so possibly new; a full literature check is needed before publication):
  * steeper simplicity analysed in function induction with *private* randomness, against classes with a universal element (Thm 1 versus Prop 1.3, Cor 1.4), and its price on shared latent causes (Prop 1.7);
  * the model/randomness theorems: Thm 3 (λ = 1), Thm 4 (fixed λ > 1, via Ville and a Kakutani-type argument, for adaptive inputs, in any countable product class) and Thm 5 (shared classes);
  * the product structure function, product sufficiency and product sophistication as defined here, and the ≈ d gap to the set notions for a noisy parity (Prop 3.8), as an instance of the restricted-family phenomenon above;
  * Theorem 2's systematic-error (junta) instance with Hänni's numbers, including the identification bounds (d), (e), the memoriser regime, the sharp lower end, and the all-hypothesis rate-blindness criterion with its κ-robust form (Prop 2.11, Lemma 2.11a).
* **Already in T5** (this project's earlier note, re-derived here):
  * per-input pricing;
  * the sequence pathology threshold;
  * the kink for full-table parity with random errors and its window;
  * the flatness of shared mixtures;
  * the hull lemma, rate thresholds, guard erosion, non-identifiability and block universality.

---

## 4. Other results

**Proposition 4.1 (labelled history restores universality; T5 Prop 2.6, re-derived) [proved; computed: c5(d)].**
* *Setting.* Suppose a hypothesis's input at position $i$ of a block contains the block's earlier labelled pairs. Let $(\nu_\theta)_{\theta\in\Theta}$, Θ countable, be uniformly computable history-dependent conditional measures with strictly positive values ("personas"), and let $w$ be computable positive weights with $\sum_\theta w_\theta\le1$ and a computable sum. (A finite family with rational values and rational weights also works.)
* *Claim.* The in-context Bayes mixture $h_w(y_i\mid\cdot):=Z_{i+1}/Z_i$, with $Z_i:=\sum_\theta w_\theta\prod_{k<i}\nu_\theta(y_k\mid\cdot)$, is a computable conditional measure on extended inputs, hence a single product hypothesis with $\ell(h_w)\le K(w,(\nu_\theta))+\kappa$. On every block,
$$\sum_i-\log h_w(y_i\mid\cdot)=-\log\frac{\sum_\theta w_\theta\prod_i\nu_\theta(y_i\mid\cdot)}{\sum_\theta w_\theta}\le\min_\theta\Big[\log\frac1{w_\theta}+\sum_i-\log\nu_\theta(y_i\mid\cdot)\Big].$$
  So it pays $\log(1/w)$ per block, not per input.
* *Proof.* Each $Z_i$ is a computable positive real, uniformly: the terms are computable, positive, and the tail is bounded by the computable tail of $\sum w$. So $h_w$ is computable, and $\sum_yh_w(y\mid\cdot)=1$ because the $\nu_\theta$ are measures. The product of the predictive probabilities telescopes to $Z_{n+1}/Z_1$, and $Z_1=\sum w\le1$. Checked to $3.6\cdot10^{-15}$ over 2000 random instances with history-dependent inputs (c5(d)). ∎

(Without the computability hypothesis, $Z_{i+1}/Z_i$ is a ratio of lower-semicomputable sums, which need not even be lower semicomputable; this is why it is added.)

**Proposition 4.2 (history of inputs only, private randomness) [proved].**
* *Claim.* Suppose a hypothesis sees the earlier *inputs* but not the earlier labels, and draws fresh randomness for each extended input $(x_{<i},x_i)$. This is the SFI$^{\rm hist}$ of brief H4 with private randomness. Then it is a product hypothesis on the extended input space. Extended inputs are pairwise distinct, so Prop 1.3 and Cor 1.4 apply verbatim: per-input pricing persists.
* *With shared randomness instead*, as in the history track's SFI$^{\rm hist}$, a universal element exists ($M_H\asymp\xi$, history Cor 4.3). Theorem 1 then applies.
* So the property that makes SFI$^{\rm hist}$ "as good as SI" (shared randomness) is the property that removes the steeper-simplicity benefit.

**Remark 4.3 (why neither form of steepness splits model from randomness in SI's program representation) [proved].**
* Solomonoff's $M$ is a mixture over deterministic programs.
* The tempered likelihood does not change deterministic hypotheses (Lemma 1.1(iii)). So the tempered posterior on $M$'s programs is the plain posterior.
* A power prior $2^{-\lambda|p|}$ charges sampled bits and model bits alike, since both are program bits. So it is indifferent between two decompositions with the same total length, e.g. "μ-decoder + code of the randomness" and a literal fill-in of the same length.
* The split needs a representation in which the randomness is not part of the program. That is a product hypothesis with private coins.

### 4.4 Fixed λ versus λ ∝ N [proved, from Thms 2 and 4 and Props 2.9, 2.12]

* With **fixed** λ > 1, SFI over a product class, facing a computable sampler ν of length $k$ (Thm 4):
  * its MAP length is at most $(\lambda k+m^*)/(\lambda-1)$ for every $N$;
  * the posterior mass on fill-ins that memorise the noise is at most $2^{\lambda k+\lambda m^*-(\lambda-1)(-\log\nu(D_N))}$: exponentially small in the sampled randomness, not zero;
  * with infinitely many distinct inputs, almost surely every MAP is eventually ν-equivalent on the run.
  
  It also eventually learns every finite-complexity *deterministic* regularity, systematic errors included (Prop 2.9(b)).
* With **λ = cN** it additionally discards components whose population rate is below $c$, such as Hänni's error rule (Thm 2). Valid components below the rate are discarded too (Prop 2.12), and the rates depend on the input law (Prop 2.15).
* SI and shared-randomness SFI do neither. At any λ > 1 their selected hypotheses have length at most $(\lambda\ell_U+c_0)/(\lambda-1)$ on all data and fit almost as well as $U$ (Thm 1). In particular, samplers with $(\lambda-1)k>\lambda\ell_U+c_0$ are never selected (Thm 5).
* *The price.* At a given $N$, with $\lambda=cN$, the steeper code length satisfies $-\log\xi_\lambda(D_N)\le\lambda\ell(\pi)-\log\nu_\pi(D_N)=N(c\,\ell(\pi)+\hat L(\pi))$ for every program π. This is a **batch** excess of $c\,\ell(\pi)$ bits per sample over π's own loss, against $\ell(\pi)/N$ per sample at λ = 1. It is not a sequential regret, because λ = cN is not one Bayesian predictor (§1.3). By Prop 2.14 this price cannot be seen by proper-score validation, and in the twin worlds it cannot be justified from imitation data. On shared latent causes the product class pays an additional factor (Prop 1.7).

### 4.5 Computable versions, NN Bayes and cold posteriors

**Proposition 4.4 (Theorems 2 and 4 hold in computable product classes) [proved].** Let $\Pi'$ be any class of product hypotheses in the sense of Def 1.3: a c.e. prefix-free code and uniformly lower-semicomputable conditional semimeasures. Let κ′ be its (F1) constant, $K(\pi)\le|\pi|+\kappa'$.
* (a) Lemmas 2.1–2.4 and the lower-bound parts of Theorem 2 ((o), the lower bound on $\Phi$ in (i), (ii), the level and $R_B$ statements in (iii)) hold for every $\pi\in\Pi'$, with κ replaced by κ + κ′. The parts that use reference programs (the slack in (i), $J_g$ and $J_b$, (iv)) hold if $\Pi'$ contains a good-model program $\pi'_g$ and a memoriser $\pi'_b$, with $\kappa_g:=\ell(\pi'_g)-d$ and $\kappa_b:=\ell(\pi'_b)-d-\lceil L_S\rceil$ for the class's own programs.
* (b) Theorem 4 holds as stated for every countable product class with Kraft weights that contains a program for ν.
* (c) Prop 1.7(ii) holds in every product class with a prefix-free code.

*Proof.* Inspection. Lemma 2.1 uses only that $u(\pi;a')$ is lower semicomputable uniformly in $(\pi,a',d)$; Lemma 2.3 that $q_z$ is lower semicomputable uniformly in $(\pi,a,m,B)$; Lemma 2.4 uses (F1) for the class. Theorem 2's proofs use only Lemmas 2.1–2.4, Lemma 2.2 and the reference programs. Theorem 4 uses Lemma 3.1 for $\xi_{\mathcal C}$, Kraft and countability. ∎

*Examples* [remarks; constants not computed].
* *Time-bounded samplers*: probabilistic programs clocked at $t(|x|)$ steps, as in the context track's time-bounded SFI (context Thm 3.1, Prop 3.3), but weighted by a prefix-free code length rather than an enumeration index. The good model runs in time $O(d)$ and the memoriser in time $O(d+s_0m)$, so for generous time bounds their lengths, and hence $\kappa_g,\kappa_b$, change by $O(\log)$ terms only.
* *Circuits with private output noise*: a circuit outputs a label and a flip probability from a finite menu; programs are prefix-free gate lists. A parity on $d$ inputs needs a gate list of about $d\log d$ bits, so $\kappa_g$ grows to order $d\log d$. The window's upper end shrinks by about that factor, and the information bound (d) grows to order $d\log d$ bits. For Hänni's sizes the window stays nonempty (since $2^{-20}$ is far below $c_{\rm hi}$); the numbers were not computed.
* *What does not transfer.* Theorem 1 needs a member that is (nearly) the class's own mixture. A mixture of all time-$t$ programs is not itself a time-$t$ program. Whether time-bounded *shared* classes contain a short member that absorbs everything is open (§4.6). So the contrast "product vs shared" is established here only for the unbounded classes.

**Proposition 4.5 (computability of the steeper predictor) [proved].** Let λ ≥ 1 be computable, the class $\Pi_\times$ or $\Pi_F$, $X$ infinite and $\{0,1\}\subseteq Y$.
* (a) $\xi_\lambda(D)$ is lower semicomputable uniformly in $D$.
* (b) Neither the raw conditional $\xi_\lambda(y\mid D,x)$ nor the normalised conditional is computable.
* (c) Both are limit-computable.

*Proof.* (a) Each term $2^{-\lambda|\pi|}P_\pi(D)$ is lower semicomputable and the weights are computable. (b) This is F Prop 7.3(c)'s argument. If the raw conditional were computable, define $f(t)$ for $t\in\mathbb N\subseteq X$ as the first $y\in\{0,1\}$ certified to have $\xi_\lambda(y\mid D_t,t)<0.6$, with $D_t:=\{(s,f(s)):s<t\}$; one of the two conditionals is at most 1/2, so the search halts. Then $f$ is total computable and $\xi_\lambda(D_n)<0.6^n$. But a program for $f$ of length $K(f)+\kappa$ gives $\xi_\lambda(D_n)\ge2^{-\lambda(K(f)+\kappa)}$, a contradiction for large $n$. For the normalised conditional, its cumulative loss would be at least $n\log(1/0.6)$, but it is at most the raw cumulative loss $\le\lambda(K(f)+\kappa)$, since each normaliser is at most $\xi_\lambda(D)$. (c) Lower-semicomputable reals are computable from the halting problem, and the normaliser is positive. ∎

Whether the λ-MAP is computable from the data is not settled here; it is presumably not, by the same kind of argument, but no proof is given.

**Remark 4.6 (cold posteriors are a different direction).** Wenzel et al. (ICML 2020, PMLR 119) report that "cold" posteriors $p(\theta\mid D)^{1/T}\propto\exp(-U(\theta)/T)$ with $T<1$, where $U=-\sum\log p(y\mid x,\theta)-\log p(\theta)$, improve the predictive performance of Bayesian deep networks [known (snippet: definition via $\exp(-U/T)$ and the improvement for $T<1$); details unverified].
* In this track's parametrisation, $\exp(-U/T)=p(\theta)^{1/T}\prod p(y\mid x,\theta)^{1/T}$. Prior and likelihood get the same exponent, so the prior-to-likelihood ratio stays λ = 1; the cold posterior only sharpens both.
* Tempering the likelihood alone with exponent $1/T>1$ and leaving the prior alone corresponds to λ = T < 1, the opposite of λ > 1. Fractional posteriors (likelihood exponent η < 1, Bhattacharya et al. 2019) are the λ = 1/η > 1 direction.
* So the cold-posterior findings do not bear directly on λ > 1. I did not find (at snippet level) work that studies λ > 1 for Bayesian neural networks.

**Remark 4.7 (NN Bayes is a private-randomness mixture).** A network with output law $p(y\mid x,\theta)$ and labels independent given θ defines, for each θ, a product law. Its Bayes posterior is therefore a mixture of product laws with a parameter prior: an $M_{\rm prod}$-type object, not a machine-law (shared-randomness) mixture. The context track (§4.1 there) identifies it with function-space Bayes under the parameter–function-map prior. Two consequences, as remarks only:
* Theorem 4 applies to any countable discretisation with weights $p(\theta)$ (Kraft holds since $\sum p=1$). Under the power prior $p(\theta)^\lambda$ with λ > 1, deterministic parameter settings that memorise the label noise have posterior mass exponentially small in the sampled randomness, provided the noise model itself is in the family.
* Whether a parameter prior behaves like a description-length prior, which Theorem 2 needs for its lower bounds, is the context track's bridge question. Nothing here settles it.

### 4.6 Open problems

1. *Kinks beyond parities.* Which simple-model classes give a window? Parities do, via list decoding. Majority-like functions should not, since short approximations exist; this is T5's open problem 1.
2. *Sharper identification constants.* A version of T5's Lemma 2.5c (randomness of $E$ relative to the hypothesis) for the junta case would push the error-label bound toward $1-u\approx0.02$ at Hänni's sizes, give a nonvacuous bound for small error rules (Example 2.7a), and extend the window method beyond $p<0.056$.
3. *Lower-semicomputable hypotheses in Prop 3.7.*
4. *Which hypotheses count as shared.* Whether every lower-semicomputable random-function law is dominated by $M_F$ up to a constant is F Problem 3.6. Theorem 1 holds for the weak class and the machine-law class either way.
5. *A principled, data-free choice of $c$* (T5's open problem 3). Prop 2.14 shows imitation data cannot supply it.
6. *Time-bounded shared classes.* Does a time-bounded shared class contain a short member that absorbs at λ > 1, as in Theorem 1? If not, steeper simplicity could work in time-bounded SI too.
7. *Computability of the λ-MAP.*
8. *Finite samples.* Lemma 2.6 needs $N\approx10^{11}$ at Hänni's sizes; a sharper concentration argument (e.g. localisation around the window) is needed for realistic $N$.
9. *Literature.* Check the novelty claims of §3.6 against Vereshchagin–Vitányi 2010 and the restricted-model literature, and Barron–Cover's α > 1 condition against the paper.

---

## 5. Hänni's specific claims, checked

| His claim (grokking note, messy notes, LessWrong thread) | Verdict |
|---|---|
| Sequence case: "it'll be better to drop bits and take the likelihood loss"; "a universal hypothesis ... starts to predict the human errors" | **Confirmed** (Thm 1(a), (c), (d); Prop 2.9(c)). |
| Wyeth: "I can just choose a hypothesis that is a universal distribution" | **Correct** for SI and for shared-randomness SFI, including $M_F$ (Thm 1); **not available** in the product class (Cor 1.4); the restriction has a price (Prop 1.7). See §1.8. |
| "this pathology is maybe not present in function solomonoff ... if each input has to sample its own random bits" | **Confirmed**: no product hypothesis is universal (Prop 1.3, Cor 1.4); in his example the selected hypothesis is the good model (Thm 2). **Qualified**: it fails when inputs carry labelled history (Prop 4.1), and private randomness cannot express shared latent causes (Prop 1.7). |
| "maybe I'm just failing to construct the right universal hypothesis" | **Settled** for the instance: Theorem 2 quantifies over all product hypotheses. |
| His three hypotheses and numbers | Version 2: **confirmed** [computed: c1]; "≈ p log(1/p) ≈ 1/100" is 0.0098 against the exact 0.0112, immaterial. Version 1: **realised in population form** (Example 2.7a): window $\lambda\in(9.77,58.0]$ at $N=10^4$, κ = 0, against his (10, 100); only coarse identification is proved at that size. |
| "the good model could be a vertex of the convex hull ... picked out by some loss of the form described (even in the limit of many data points, though we will need to increase the hypothesis term coefficient ... as the data set size increases)" | **Confirmed**: Lemma 1.2; λ = cN is necessary for systematic errors (Prop 2.9(b)); the window is $(2^{-m},c_{\rm hi}]$. A vertex is needed, not just a boundary point, and no other hypothesis may sit at the same point. |
| "alternatively: just set abs bound on model complexity ... in a sense equivalent to the previous proposal" | **Confirmed** at vertices (Lemma 1.2(iv)). Not equivalent elsewhere: the absolute bound can also select points above the boundary, which no penalty selects. |
| "look at how many bits of entropy are left given the hypothesis ... some point at which the derivative changes ... (this doesn't show up in the seq case because there it's ... 1 bit paying for 1 bit)" | **Confirmed**: the product structure function has a kink at the simple model, while the set/shared one lies on the sufficiency line (Prop 3.8, T5 Thm 2.5). |
| "It seems plausible that some other pathology is present" | **Yes**: rate blindness (cheap frequent errors are learned and rare valid rules lost, robustly in κ: Lemma 2.11a), guard erosion, non-identifiability of λ, block universality, input-law dependence, and confident wrong extrapolation off the training support (§2.6, §4). |
| "solomonoff doesn't have a preference here, both get similar posterior" (sampler vs filled-in bits) | **Confirmed** with explicit factors (Thm 3, Prop 3.3). |
| a stronger simplicity prior gives "a preference for a simple sampler" in SFI | **Confirmed** for every fixed λ > 1 in every countable product class (Thm 4). In SI the universal mixture wins instead (Thm 5). |
| "have people not already considered this for solving the model + data split problem?" | Partly. Algorithmic statistics and MDL study the split with set or shared models, where incompressible parameters are treated as noise (Prop 3.8), and restricted model families (Hamming balls) move the split; λ > 1 two-part codes appear in MDL convergence theory. The private-randomness (product) family and its use in steeper SFI were not found (snippet-level check only). |

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
* Thm 3.2 → Prop 2.12; Thm 4.1 → the twin-world remark after Prop 2.12; Thm 4.3 → Prop 2.14; Prop 4.4 → Prop 2.13, with $\Delta_G$ as corrected; Prop 2.6 → Prop 4.1.
* T5's (d7) (input-law dependence) → Prop 2.15, in the separable case only.

**Not reused (and not re-verified here):** Thm 3.3 (idealised multi-region thresholds), Cor 3.4 (all shapes for product hulls), Lemma 2.5c, §5 (coherence and postulates), Prop 4.5, (d3) and (d6).

**T5's scripts.** T5's c1–c3 were re-run from scratch copies; the outputs are saved in `checks/t5_rerun/` and reproduce T5's numbers (window $(1.119\cdot10^{-6},8.989\cdot10^{-3})$, ratio 8037; λ = 1 switch at $N=894{,}054$; the c2 kink table; 0 violations in c3).

**Corrections relative to T5:** none of substance. T5's window for $d=20$ was stated as "≈ 0.049 up to O(log) slack". The rigorous value from Theorem 2 with κ = 0 is $c_{\rm hi}=0.0114$; the heuristic value ignores the $2\log d$ terms, which are of the same size as $d$ at $d=20$.

**New here:** the systematic (junta) error instance with Hänni's numbers; the error-label and information bounds; the memoriser regime and the sharp lower end; the all-hypothesis rate-blindness criterion and its κ-robust form; Theorem 1(c3), (d); the power-posterior concentration (Prop 2.8); Example 2.7a; Props 1.7, 2.15, 2.16, 4.2, 4.4, 4.5; all of §3 except the parity flatness.

---

## 7. Response to the referee

The referee found no fatal errors, three major issues and twenty minor ones, and listed six questions the track had missed. All were accepted; none is disputed. The table says where each is handled.

| Item | What was done |
|---|---|
| **M1** κ = 0 numbers called "proved" | All κ = 0 numbers are now labelled illustrations. New Lemma 2.11a gives the robust form: the all-hypothesis criterion holds for all $d\ge d_0(\kappa)$, $d_0$ linear in κ, with a table for κ ≤ 100 [c6(A)]. Prop 2.11(i)'s examples are stated with their margins (9.6 and 1.4 bits). Every Theorem 2 number is given at κ = 0 and κ = 30. |
| **M2** Wyeth not answered; cost understated | New §1.8 "Answer to Wyeth's objection" with points (i)–(iv) and the ad-hoc question. "Nothing is lost" was removed (§1.6). New Prop 1.7 quantifies the price at λ > 1: a factor $\min(\lambda,2)$ on shared latent coins [proved; c6(D)]. |
| **M3** novelty vs restricted model classes | §3.5 now has "Relation to restricted model families" (VV 2010 Hamming/distortion balls; strong models; set–distribution equivalence). §3.6 is toned down. Prop 3.7 is marked as presumably the standard translation. λ > 1 two-part codes are noted as known (§1.3). |
| m1 Lemma 3.2 per-seed counting | Canonical classes are now $\Pi=\mathrm{dom}V$, closed under prefix-free simulation (§1.2); Lemma 3.2 builds one program per seed. Checked with the $1x$ embedding [c6(E)]. |
| m2 c3 ceiling bug | Fixed with exact integer binomials; only the rate-blindness lines changed (verification log). |
| m3 Prop 2.8 example | c5(e) now uses the formula; exponent −758. |
| m4 $\delta_S$ and "information" | $B_S$, $\delta_S$, $I(\pi)$ defined in Setting 2.0; Thm 2(ii)(d) restated; table with $\delta_S\in\{0,20\}$ [c6(B)]. |
| m5 overstatements | §0 and §4.4 rewritten (Thm 4 wording; per-input mixtures only; the condition in Thm 2(iii)). |
| m6 finite domains | Thm 4(iv) requires an infinite input sequence; Prop 2.9 states explicit finite-$N$ bounds. |
| m7 SI not a weak function semimeasure | Classes are observation-indexed (Def 1.3); Thm 1(c) is for data-set classes; the chronological class covers adaptive inputs (Thm 1 remarks, Thm 5). |
| m8 Prop 4.1 computability | Hypothesis added, with the reason. |
| m9 Prop 3.7 conditional | Conditional set sufficiency stated; $\log\rho\approx\log N$ noted. |
| m10 Prop 3.5 reading | Corrected to a trade-off. |
| m11 Lemma 1.2(iii) wording | Reworded via the vertices of $C$, end vertices included; checked [c6(F)]. While doing this, (iv)'s "iff" was found to fail on the horizontal ray; corrected (log item 13). |
| m12 "flat totals" tag | Now a one-line proof in Prop 3.8(i). |
| m13 Version 1 | Example 2.7a at $d=100$, $m=10$, $p=2^{-6}$, matching both sizes; the referee's $d=13$ instance is also reported [c6(C), c6(H)]. |
| m14 hidden terms in Thm 3 | Stated in Thm 3 and §0, with the dyadic restriction. |
| m15 λ = cN not Bayesian | Stated in §1.3; §4.4 speaks of batch excess, not regret. |
| m16 (F1) proof | Fixed (§1.2). |
| m17 Cor 1.4 input space | $X\supseteq\{0,1\}^d$ for all $d$ stated. |
| m18 Cor 2.7 table | Filled from c3. |
| m19 unsaved T5 re-run | Saved in `checks/t5_rerun/` (§6). |
| m20 references | Poland's erratum cited; Barron–Cover's α > 1 noted via a secondary source, still unverified at the source. |
| Missed: Wyeth | §1.8. |
| Missed: steeper vs OOD | Prop 2.16. |
| Missed: input distribution | Prop 2.15. |
| Missed: computability, H10 | §4.5: Props 4.4, 4.5, Remark 4.7, open problem 6. |
| Missed: Version 1 | Example 2.7a. |
| Missed: cold posteriors | Remark 4.6. |

---

## 8. Cross-track consistency

No track had a `notes-final.md` when this was written; the comparison is with the current `notes.md` of foundations (F), history, context and examples.

**Terminology and objects.**

| This track | Foundations (F) | History | Context | Examples |
|---|---|---|---|---|
| data set: finite partial function $D$ | same (§1) | function-consistent sequence, $D_n$ (§1.1) | same (§1) | same (§1.1) |
| shared hypothesis = lsc weak function semimeasure | Def 2.1 | — | — | — |
| machine law (shared tape) | Def 2.5 | function machine $M_T$ (§1.2) | $\mu_T$ (§1) | $\nu_T$ (§1.1) |
| product hypothesis = lsc product law, $\nu(D)=\prod\nu(y\mid x)$ | Prop 3.3(a) | computable sampler without history | "product (private-randomness) hypothesis" | "product law" |
| $\xi_\times$ (mixture of $\Pi_\times$) | $=M_{\rm prod}$ exactly (Def 4.1), "operator induction" | — | — | — |
| mixture of $\Pi_F$ | $=M_F$ on $D\ne\emptyset$ (Thm 3.2); F's recommended SFI | $M_F$ (§1.2) | $M_F$ | $M_F$, $L_{\rm SFI}=-\log M_F$ |
| mixture of $\Pi_{\rm chr}$ | Hutter's ξ (Prop 7.2) | $\xi\asymp M_H$ = SFI$^{\rm hist}$ (Cor 4.3) | — | (F7) |
| loss: semimeasure convention, $-\log P(D)$, order-independent for a fixed hypothesis | Prop 5.2 | §1.2 | (F1) | §1.1 |

**Notation clashes the paper should resolve.**
* λ: here the steepness exponent (brief H9). The foundations, history, context and examples tracks use λ for the uniform measure on tapes. Suggest a different symbol for one of them (for example $\mathrm{Unif}$ for the measure).
* $m$: here the junta size. F uses $m(i)$ for the universal discrete semimeasure, written $\mathbf m$ here; the history track uses $m$ for $GF(2^m)$.
* $c$: here $c=\lambda/N$. The other tracks use $c$ for machine constants, written κ here.
* $Y$: F, history and context take $Y=\{0,1\}^*$; this track needs $Y$ finite (Lemmas 2.1–2.3 binary, Prop 3.7, Lemma 3.2).

**Results used from other tracks, and how they are used.**
* F Thm 3.2 and Thm 3.4: (Dom) for $\Pi_F$ and $\Pi_w$ (§1.4).
* F Prop 3.3(a): product laws are machine laws; x-only samplers are product laws (§1.1, §1.6).
* F Thm 4.2 and Prop 4.5: the price of private randomness at λ = 1 (§1.6, §1.8).
* F Prop 4.4: hashing for fair coins; Lemma 3.2 proves the dyadic case that F's remark sketches.
* F Thm 6.1, Thm 6.5, Cor 6.6: $M_F$'s pathwise dominance, merging and mistake bound (Prop 2.9(a), Thm 5 remark).
* F Prop 6.8: fresh noise on repeated inputs gives infinite loss; all noise here is frozen.
* F Prop 7.3(c): its diagonal argument gives Prop 4.5(b).
* History Lemma 4.1, Thm 4.2, Cor 4.3: $M_H$ (SFI$^{\rm hist}$) is a universal lower-semicomputable chronological semimeasure, $M_H\asymp\xi$; used for $\Pi_{\rm chr}$ (§1.2), Thm 1 (example 4), Prop 4.2 and Thm 5.
* Context Prop 2.1: Hänni's OOD proposition; Prop 2.16 is its λ > 1 counterpart for the product class.
* Context Thm 3.1, Prop 3.3: time-bounded x-only SFI, a mixture of clocked product hypotheses; Prop 4.4 says Theorems 2 and 4 transfer to such classes when weighted by code length.
* Context §4.1: NN posterior as function-space Bayes; Remark 4.7.
* Examples Prop 4.6: frozen label noise around a computable $g$ costs SFI $\log\binom n{e_n}+\log(n+1)+K(g)+c$ at λ = 1. This is the λ = 1 side of §3: sampler and memoriser are close (Thm 3); λ > 1 separates them (Thm 4). Its machine $T_g$ shares the flip rate ε′ across inputs, so it is a machine law (a mixture of product laws), not a product law. In $\Pi_\times$ the same bound holds up to $O(\log n)$ [proved]: the product law "$g$ flipped independently with probability $e_n/n$" has a program of length $K(g)+O(\log n)$, and its loss is $nH(e_n/n)\le\log\binom n{e_n}+\log(n+1)$.

**Consistency checks.**
* F's request ("the steeper-simplicity track should say explicitly that it works with $M_{\rm prod}$-type hypotheses") is met: §1.2 defines $\Pi_\times$ so that $\xi_\times=M_{\rm prod}$ exactly, and §1.6–§1.8 state the consequences, including the price relative to F's recommended $M_F$.
* F's verdict on H1(a) (weak and machine universality differ by up to $K(\mathrm{dom}D)$) does not affect this track: Theorem 1 holds in both classes, with $U=M^w$ or $U=M_F$.
* The history track's H4 result (SFI$^{\rm hist}$ is universal because the tape is shared) and Prop 4.2 here are two sides of one fact: shared randomness gives universality and removes the steeper-simplicity protection; private randomness keeps per-input pricing and forgoes universality.
* The examples track's H5/H6 results and the context track's OOD results use $M_F$ at λ = 1; nothing here contradicts them. Prop 2.16 adds that steeper simplicity removes the context track's constant lower bound only by sharpening the preference for the shortest train-fitting hypotheses.
* No disagreement with another track was found.
* The context and history tracks have referee reports but no final notes yet. Those reports found no fatal error in the results used here: context Prop 2.1 and Thm 3.1(a) (with a wording fix) and history Lemma 4.1, Thm 4.2 and Cor 4.3 were confirmed. The history referee's caveat on Thm 4.2 (exactness fails at the root when $\rho(\varepsilon\Vert\varepsilon)<1$) does not affect dominance, which is all this track uses.

---

## References

"(v)" means the bibliographic data were verified by web search; "(cu)" means the content was not checked against the source; "(snippet)" means a search snippet confirmed the specific content cited.

* Antunes, L., Fortnow, L. (2009). Sophistication revisited. *Theory Comput. Syst.* 45(1):150–161. (v, cu)
* Barron, A. R., Cover, T. M. (1991). Minimum complexity density estimation. *IEEE Trans. IT* 37(4):1034–1054. (v, cu; the α > 1 complexity weight is per a secondary source, arXiv 2311.03852, snippet)
* Bhattacharya, A., Pati, D., Yang, Y. (2019). Bayesian fractional posteriors. *Ann. Statist.* 47(1):39–66. (v, cu)
* Bissiri, P. G., Holmes, C. C., Walker, S. G. (2016). A general framework for updating belief distributions. *JRSS-B* 78(5):1103–1130. (v, cu)
* Cover, T. M., Thomas, J. A. *Elements of Information Theory* (binomial bounds). (standard)
* Gács, P., Tromp, J., Vitányi, P. (2001). Algorithmic statistics. *IEEE Trans. IT* 47(6):2443–2463. (v, cu)
* Gneiting, T., Raftery, A. E. (2007). Strictly proper scoring rules, prediction, and estimation. *JASA* 102(477):359–378. (v)
* Goldreich, O., Levin, L. A. (1989). A hard-core predicate for all one-way functions. STOC. (standard)
* Grünwald, P. (2012). The safe Bayesian: learning the learning rate via the mixability gap. ALT, LNCS 7568:169–183. (v, cu)
* Grünwald, P., van Ommen, T. (2017). Inconsistency of Bayesian inference for misspecified linear models, and a proposal for repairing it. *Bayesian Analysis* 12(4):1069–1103. (v, cu)
* Hoeffding, W. (1963). Probability inequalities for sums of bounded random variables. *JASA* 58:13–30, Thm 4. (v via secondary sources)
* Hutter, M. (2005). *Universal Artificial Intelligence*. Springer, ch. 5 (chronological semimeasures). (cited via the history track; cu)
* Kakutani, S. (1948). On equivalence of infinite product measures. *Ann. Math.* 49:214–224. (v)
* Koppel, M. (1987). Complexity, depth, and sophistication. *Complex Systems* 1(6):1087–1091. (v, cu)
* Koppel, M., Atlan, H. (1991). An almost machine-independent theory of program-length complexity, sophistication, and induction. *Inform. Sci.* 56:23–33. (v, cu)
* Kushilevitz, E., Mansour, Y. (1993). Learning decision trees using the Fourier spectrum. *SIAM J. Comput.* 22(6). (standard)
* Li, M., Vitányi, P. (2008). *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed. (standard facts F1–F5; section numbers unverified)
* Milovanov, A. (2016). Paper on normal objects and universal models in algorithmic statistics, CSR 2016 (preprint at lirmm.fr, `2016-milovanov-csr.pdf`). (snippet only; exact title and pages unverified)
* Poland, J., Hutter, M. (2005). Asymptotics of discrete MDL for online prediction. *IEEE Trans. IT* 51(11):3780–3795. Erratum: Poland, J. (2006), *IEEE Trans. IT* 52(3):1279, which corrects the abstract's description of the setting (i.i.d. → arbitrary processes on a finite observation space). (v, snippet)
* Sion, M. (1958). On general minimax theorems. *Pacific J. Math.* 8:171–176. (standard)
* Solomonoff, R. J. (1978). Complexity-based induction systems: comparisons and convergence theorems. *IEEE Trans. IT* 24(4):422–432. (v; exact constant cu)
* Vereshchagin, N., Shen, A. (2017). Algorithmic statistics: forty years later. In *Computability and Complexity*, LNCS 10010:669–737. (v; set–distribution equivalence with logarithmic precision per snippet)
* Vereshchagin, N., Vitányi, P. (2004). Kolmogorov's structure functions and model selection. *IEEE Trans. IT* 50(12):3265–3290. (v, cu)
* Vereshchagin, N., Vitányi, P. (2010). Rate distortion and denoising of individual data using Kolmogorov complexity. *IEEE Trans. IT* 56(7):3438–3454. (v; content per abstract and snippet)
* Ville, J. (1939). *Étude critique de la notion de collectif*. (standard)
* Vitányi, P. (2006). Meaningful information. *IEEE Trans. IT* 52(10):4617–4626. (v, cu)
* Wenzel, F., et al. (2020). How good is the Bayes posterior in deep neural networks really? ICML 2020, PMLR 119. (v; definition of the cold posterior and the reported improvement per snippet)
* Zhang, T. (2006). From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation. *Ann. Statist.* 34(5):2180–2210. (v, cu)

---

## Verification log

**Method.**
* Every proof was written out in full and re-checked step by step. The new proofs of this revision (Prop 1.7, Lemma 2.11a, Props 2.15, 2.16, 4.4, 4.5, the per-program Lemma 3.2, the reworded Lemma 1.2(iii), the conditional Prop 3.7, the flatness in Prop 3.8(i)) were checked by hand and, where a finite analogue exists, by script.
* Every T5 result that is reused was re-derived, not copied. T5's scripts c1–c3 were re-run from scratch copies; outputs are saved in `checks/t5_rerun/`.
* Every number quoted comes from this track's scripts, run with fixed seeds or deterministically. Outputs are saved as `checks/*.out`.
* An independent referee read `notes.md` and wrote `referee_code/r1`–`r6`. Where a claim's only independent check is the referee's, this is stated.
* Environment: Python 3.11.15, numpy 2.4.6, scipy 1.17.1.

**Scripts and what they check.**

| Script | Seed | What it checks | Result |
|---|---|---|---|
| `c1_hanni_numbers.py` | deterministic | Both versions of Hänni's calculation; windows; λ = 1 switch; $H(2^{-10})$ vs $p\log(1/p)$; $L_S$ for the instances | Version 2 window $(1.1185\cdot10^{-6},8.9893\cdot10^{-3})$, ratio 8037; switch at $N=8.941\cdot10^5$; $L_S=11{,}710.3$ |
| `c2_pricing_kink.py` | 2 | (a) per-input pricing over parities; minimax example 2.5431 by two methods. (b) 400 random semimeasure hypotheses: the identity for $u$, the list-size bound and the risk floor (Lemmas 2.1, 2.2). (c) kink instance: product list mixtures vs flat shared and set totals | 0 violations; 2.5431 < 2.5850 |
| `c3_junta_window.py` (**corrected**) | 3 | Sanity inequalities; concavity reduction (2830 instances); $G_1=H(p)$ crossover; windows for κ ∈ {0, 30}; identification (a)–(e) on a grid ($g=7$); memoriser regime; rate blindness (three-hypothesis and all-hypothesis); Lemma 2.6 numbers; λ = 1 MAP error bounds; exact small instance | 0 violations; crossover $p=0.0560$; numbers as quoted |
| `c4_model_vs_randomness.py` | 4 | (A) Ville, 4000 runs; (B) hashing exact over GF(16); (C) noisy parity, product vs shared MAPs, threshold λ = 1.315 | all below $2^{-m}$; max error 0; as quoted |
| `c5_limits.py` (**corrected**) | 5 | (a) separable thresholds (8000 tests), hull (300 sets); (b) guard erosion; (c) proper scores, held-out selection; (d) block telescoping; (e) power-posterior bound, now with $J_g$ from the formula | 0 violations; $3.6\cdot10^{-15}$; exponent −758 |
| `c6_revision.py` (**new**) | 6 | (A) Lemma 2.11a: $d_0(\kappa)$ for five rules and κ ≤ 100, direct check at $d_0-1$, $d_0$ and on ~400 values up to $10^6$; Prop 2.11(i) margins. (B) Theorem 2(ii) with $\delta_S\in\{0,10,20\}$, κ ∈ {0, 30}, best $g$. (C) Example 2.7a and the referee's $d=13$ instance. (D) Prop 1.7's inequality on random finite product classes (24,732 checks) and an illustrative class. (E) Lemma 3.2 with the $1x$ embedding, exact (2106 cases). (F) Lemma 1.2(iii) on 401 random point sets (5061 points). (G) exact guard-erosion crossing; Prop 2.9(a) fraction. (H) Example 2.7a: Lemma 2.6 excess vs margin at $N=10^4$ | all checks pass: $d_0$ table as quoted, 0 violations in (D), maximum error 0 in (E), 0 mismatches in (F); excess 0.308 > margin 0.224 in (H) |
| `t5_rerun/` | (T5's) | T5's c1–c3 from scratch copies | reproduces T5's window, switch $N$, kink table and 0 violations |

**Changes to existing scripts in this revision.**
* `c3`: `log2binom` now uses exact integer binomials when affordable (the lgamma version gave $m+10^{-14}$ for $|S|=1$, so $\lceil L_S\rceil=m+1$). Diff of the output: only the rate-blindness lines changed. Three-hypothesis thresholds for $m=6,7,8$ moved from $1.6588,0.82393,0.40972\cdot10^{-2}$ to $1.9353,0.94163,0.46093\cdot10^{-2}$; all-hypothesis left sides for $m=6$ moved slightly; single-prefix memoriser bounds moved slightly (e.g. $e\ge0.829\to0.833$). No verdict changed. This matches the referee's r1(E), r6(c).
* `c5`: part (e) computes $J_g=c(d+\kappa_g)+H(p)$ instead of hard-coded values; exponents −776 → −758, −9776 → −9758, −888 → −868, 230 → 247 (matches referee r1(F), r6(d)).
* All six scripts were re-run after the last edit; c1, c2, c3, c4, c5 and c6 reproduce their saved outputs byte for byte.

**Self-check items, each resolved.**
1. Lemma 2.1 originally used $\hat s$, which is not computable for semimeasures. It was replaced by the lower-semicomputable $u$ with an enumeration argument.
2. Theorem 2(i)'s $c_{\rm hi}$ had to be corrected for $t^*<2$; the formula and the script match (referee r1(A): closed form equals bisection to $10^{-15}$).
3. Theorem 2(ii)(b) needed the case $R_B\ge B_S/2^m$ handled separately; it is.
4. The tempered-likelihood posterior with λ = cN is a fixed Gibbs measure that need not concentrate; Prop 2.8 is for the power prior only.
5. Theorem 5(ii) first summed over "all programs computing ν", which is not a c.e. set; it now bounds any set of programs via $\xi_1$.
6. The window method fails for $p\ge0.056$; stated as a limitation. The rate-blindness results do not need $G_1>H(p)$.
7. The finite-sample statement uses sampling without replacement, so the data are partial functions as SFI requires.
8. (Revision) Lemma 3.2's sum is over programs, one per seed, in a class closed under prefix-free simulation; the earlier per-seed sum was not justified by "universality" alone.
9. (Revision) Prop 2.16(i)'s exact mass $2^{-\lambda(K(Q,b)+\kappa)}$ uses the same closure: the wrapper map $p\mapsto\rho zp$ is injective.
10. (Revision) Lemma 2.11a needs $b\ge a/\ln2$ for the up-set property; c6(A) checks it for every row of the table.
11. (Revision) In Example 2.7a the bound $u\ge2^{-(J_g+\eta)}-p$ can fall below 3/4; Theorem 2(ii) now states $u\ge\max\{3/4,\cdot\}$, since $T(\pi)=1$ gives $u>3/4$.
12. (Revision) Numbers are rounded in the safe direction: lower bounds down, upper bounds up, window ends not widened.
13. (Revision) `notes.md`'s Lemma 1.2(iv) said that a constrained solution minimises some penalised objective iff its point lies on the lower hull. That fails for points on the horizontal ray to the right of the least-$R$ vertex (they tie in $R$ but lose for every $c>0$). The statement and proof are corrected.

**Literature checks in this revision** (WebSearch snippets only; arxiv.org, ar5iv, cwi.nl did not resolve):
* Vereshchagin–Vitányi 2010: bibliographic data and abstract-level content (distortion balls, Hamming, denoising) confirmed.
* Vereshchagin–Shen 2017: set and distribution models equivalent with logarithmic precision, per snippet.
* Milovanov (CSR 2016): strong models and normal objects, per snippet; title not confirmed.
* Barron–Cover 1991: the α > 1 complexity weight is confirmed only through a secondary source (arXiv 2311.03852).
* Poland 2006 erratum: confirmed (52(3):1279; corrects the abstract's i.i.d. description).
* Wenzel et al. 2020: definition of the cold posterior and the reported improvement confirmed.

**Claims by status.**
* *Proved:* Lemmas 1.1, 1.2, 1.6, 2.1–2.4, 2.6, 2.11a, 3.1, 3.2; Theorems 1–5; Props 1.3, 1.7, 2.8, 2.9, 2.11–2.16, 3.3, 3.5–3.8, 4.1, 4.2, 4.4, 4.5; Cors 1.4, 2.5, 2.7; Example 2.7a; Remarks 1.5, 4.3.
* *Computed:* all numerical statements in §§2–3 and Prop 1.7's inequality (c1–c6).
* *Illustrations (κ = 0), not proved:* every number labelled κ = 0, in particular Prop 2.11's examples at fixed $d$.
* *Known with references:* the facts F1–F5, Sion's minimax theorem, Hoeffding's bound without replacement, Ville's inequality, Kakutani's dichotomy, Solomonoff's bound, Parseval list decoding, the definitions and results of algorithmic statistics, restricted model families, α > 1 two-part MDL, cold posteriors. Bibliographic data were verified by search; most content was not checked against the sources (marked cu).
* *Remarks without proof:* the circuit and time-bounded examples after Prop 4.4; Remark 4.6; Remark 4.7.
* *Conjectures:* none stated as results. Open problems are in §4.6.
* *Refuted:* none of Hänni's claims. Two statements in `notes.md` were wrong and are corrected: the reading of Prop 3.5 ("λ slightly above 1 selects an approximately minimal sufficient statistic"), and the "iff" in Lemma 1.2(iv) (counterexample: a point on the horizontal ray to the right of the least-$R$ vertex). One of T5's informal numbers was sharpened: the $d=20$ upper end of the window.
