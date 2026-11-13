# Stakes, concentration and the narrow channel: final corrected account

Research note for `malign-prior-toy`. Written by an AI editor from two AI derivations
(`stakes-derivation-A.md`, claims A1 to A28; `stakes-derivation-B.md`, claims B1 to B32) and two AI referee
reports (`stakes-verify-proofs.md`, `stakes-verify-model.md`). Not reviewed by a human. Every proof below was
followed line by line by the editor; where a referee found an error the statement was repaired or dropped, and
each repair is named in one line. The closed forms and inequalities of Sections 2.2 to 2.4 and 2.9 were also
compared with numerical optimisation on random instances in a scratch directory; those checks prove nothing and
are not part of any proof.

**The question.** "Is it true that if the malign guys focus on attacking the places where in some sense the most
resources are at stake (maybe they will be run more than $n$ times there) then there they really do take over in
most cases? There is this intuitive picture where there is a lump of prior that can be redirected to a smaller
channel, and then they win there."

**How to read this file.** Section 1 fixes the definitions. Section 2 contains the numbered results with proofs.
Each result carries one of three tags.

* **[toy]**: a theorem about the machine $U$ and the definitions of `paper/sec2-toy.tex`. Nothing is chosen
  by anyone in such a statement.
* **[model]**: a theorem about the allocation model of Section 1.4, an optimisation problem. How far the model
  describes the toy is stated in Section 1.4 and in the remarks.
* **[example]**: a construction on $U$, with explicit constants.

Section 3 says what each result does and does not show. Section 4 is the plain answer. Section 5 lists what is
open, what was claimed and dropped, and what depends on premises outside the toy. The last section maps the
results to the claims of A and B.

---

## 1. Setup and definitions

### 1.1 The toy

Notation is that of the note (`paper/sec2-toy.tex`, `paper/sec3-floor.tex`).

* **Strings and measure.** Strings are binary. $x\sqsubseteq y$ means that $x$ is a prefix of $y$; two strings are
  *incomparable* if neither is a prefix of the other. $\lambda$ is the fair-coin measure on infinite binary
  sequences, and $[p]$ is the set of sequences that begin with $p$, so $\lambda([p])=2^{-|p|}$.
* **Machine.** $U$ is a universal monotone machine in the sense of `def:universal`: every monotone machine $V$
  has a *prefix word* $v$ with $\mathrm{out}_U(v\omega)=\mathrm{out}_V(\omega)$, and $U$ on $v\omega$ has read
  $|v|$ bits more than $V$ on $\omega$ at each output bit. Resources are unbounded unless a statement says
  otherwise. $E(u)=\{\omega:u\sqsubseteq\mathrm{out}_U(\omega)\}$ and $M(u)=\lambda(E(u))$. For incomparable
  $u,u'$ the sets $E(u),E(u')$ are disjoint (`lem:basic`(i)). For a measurable set $F$ of inputs,
  $F[u]=\lambda(F\cap E(u))$, and $\lambda(F)$ is the *weight* of $F$.
* **Predictor.** The block length is $m\ge1$. $E^m(x)=\bigcup_{y\in\{0,1\}^m}E(xy)$ is the set of inputs that
  print $x$ and at least $m$ more bits, $Z_m(x)=\lambda(E^m(x))=\sum_yM(xy)$, and
  $\pi_m(y\mid x)=M(xy)/Z_m(x)$. The *sampling predictor* returns $Y\sim\pi_m(\cdot\mid x)$. Equivalently, it
  draws an input $\omega$ from $\lambda$ conditioned on $E^m(x)$ and returns the $m$ bits that follow $x$ in its
  output; we then say that the sample is *supplied by* $\omega$. The *most-probable-block predictor* returns a
  $y$ that maximises $M(xy)$.
* **Codes.** For $j\ge1$, $\bar e(j)=1^{|b|}0\,b$ with $b$ the binary expansion of $j$. It is a prefix-free
  code with $|\bar e(j)|=2\lfloor\log_2j\rfloor+3$, so $j^{-2}/8\le2^{-|\bar e(j)|}<j^{-2}/2$. For an integer
  $j$, $\tilde e(j)$ is a sign bit followed by $\bar e(|j|+1)$, so $|\tilde e(j)|\le2\log_2(|j|+1)+4$.
* **Call rule** (`def:call`). An enumerable set $\mathcal C$ of pairs $(p,x_p)$, each *calling program* $p$ in
  exactly one pair, the calling programs prefix-free, such that $U$ on every input beginning with $p$ prints
  $x_p$ having read no more than $p$. A world that begins with $p$ *makes a critical use at the context $x_p$*:
  it receives a block computed from $x_p$ and runs it. Such worlds are the *users*.
  $$C(x)=\sum_{p:\,x_p=x}2^{-|p|},\qquad H_{\mathcal C}=\sum_p2^{-|p|},\qquad\kappa(x)=\frac{C(x)}{M(x)} .$$
  For a calling program $p$, $\varphi_p=\lambda\{\omega:|\mathrm{out}_U(p\omega)|\ge|x_p|+m\}$ is the probability
  that the user *goes on* to print $m$ more bits; $C^m(x)=\sum_{p:\,x_p=x}2^{-|p|}\varphi_p$ and
  $\varphi(x)=C^m(x)/C(x)$. A rule *given by a test* $G$ (a decidable set of strings; a *first hit* is an
  element none of whose proper prefixes is in $G$) has as calling programs the strings $p$ such that $U$ prints
  a first hit on every input beginning with $p$ and has read exactly $p$ when the hit is complete; then
  $C(x)=M(x)$ at first hits.
* **Class.** An enumerable $\mathcal W\subseteq\mathcal C$ with
  $H_{\mathcal W}=C(\mathcal W)=\sum_{p\in\mathcal W}2^{-|p|}>0$.
  $C_{\mathcal W}(x)=\sum_{p\in\mathcal W,\,x_p=x}2^{-|p|}$, and $P_{\mathcal W}(x)=C_{\mathcal W}(x)/H_{\mathcal W}$
  is the law of the context of a use of the class drawn from the prior.
  $j_{\mathcal W}=\lfloor\log_2(1/H_{\mathcal W})\rfloor+1$, so $\frac12<2^{j_{\mathcal W}-1}H_{\mathcal W}\le1$.
* **(INC)** means: the contexts in question are pairwise incomparable. First hits of a test satisfy it; a
  general call rule need not. **(PF)** means: the prefix words that a statement names together are pairwise
  incomparable (the assumption of `prop:honest`).
* **Takeover assignment.** A set $A(x)\subseteq\{0,1\}^m$ for each context, depending on the context only.
  $b_A(x)=\sum_{y\in A(x)}M(xy)$ is the mass of all programs that print $x$ and then a takeover block, and
  $\theta(x)=\pi_m(A(x)\mid x)=b_A(x)/Z_m(x)$ is the *takeover probability* at $x$.

### 1.2 Stakes

Stakes are an extension. In `def:call` every world that makes a use runs the block it receives, for ever, and
nothing distinguishes two uses except $p$, $x_p$ and $2^{-|p|}$. A **stake-labelled rule** attaches a number
$r(p)\ge0$ to each calling program. Then
$$s(x)=\sum_{p:\,x_p=x}2^{-|p|}\,r(p),\qquad S=\sum_xs(x),\qquad\bar r(x)=\frac{s(x)}{C(x)}$$
are the stake-weighted user mass at $x$, the expected stake of a world drawn from the prior, and the average
stake of the users at $x$. Three degrees of recognisability are used.

* **R1**: $r(p)$ is a computable function of the context $x_p$.
* **R2**: $r(p)\in\mathbb N$ and the set $\{(p,n):r(p)\ge n\}$ is enumerable. Then
  $W_n=\{p:r(p)\ge n\}$ is a class for every $n$; users with different stakes may share a context.
* **R3**: neither; for instance the stake depends on input bits beyond $p$ or on the block returned.

No result below connects the label $r(p)$ to anything the world does after the handover.

### 1.3 Attackers, supply, and three meanings of "they win"

An **attacker** is a measurable set $F$ of inputs with weight $B=\lambda(F)\le1$: all programs beginning with one
word, or with one of several words. Fix a takeover assignment $A$.

* **Attack mass:** $\mu_F(x)=\lambda\bigl(F\cap\bigcup_{y\in A(x)}E(xy)\bigr)$.
* **The rest:** $O_F(x)=Z_m(x)-\mu_F(x)$, the mass of everything else that prints $x$ and $m$ more bits. It
  contains the inputs outside $F$ that do so, whatever block they print, and the inputs of $F$ that print a
  block outside $A(x)$ there.
* **Supply share:** $w_F(x)=\mu_F(x)/Z_m(x)=\mu_F(x)/(\mu_F(x)+O_F(x))$, the probability that the predictor's
  sample at $x$ is supplied by an input of $F$ that prints a takeover block. *$F$ supplies the majority at $x$*
  if $w_F(x)>\frac12$.
* Always $\theta(x)\ge w_F(x)$, with equality exactly when the inputs outside $F$ that print $x$ followed by a
  block of $A(x)$ have measure zero. Statements about $w_F$ are about one attacker's programs; statements about
  $\theta$ are about all programs.

"They win on a class $\mathcal W$" has three meanings, which are kept apart:

* **(W1)** the majority of the samples at every use of $\mathcal W$;
* **(W2)** the majority of the samples at uses that make up most of $\mathcal W$, by prior mass $P_{\mathcal W}$ or
  by stake;
* **(W3)** most uses of $\mathcal W$ end in a takeover: $\mathbb E_{X\sim P_{\mathcal W}}[\theta(X)]>\frac12$, or the
  same with $w_F$ for one attacker.

(W1) implies (W2) and (W3). (W2) does not imply (W3); see the example after Theorem 10.

### 1.4 The allocation model

The data are a countable set $X$ of contexts and, for $x\in X$, numbers $s(x)\ge0$, $O_0(x)>0$ and $\tau(x)\ge0$.
An attacker of weight $B>0$ chooses $\mu(x)\ge0$ with $\sum_x\mu(x)\le B$. The rest at $x$ is
$O(x)=O_0(x)+\tau(x)\mu(x)$, the attacker's share is
$$w(x)=\frac{\mu(x)}{\mu(x)+O(x)}=\frac{\mu(x)}{(1+\tau(x))\,\mu(x)+O_0(x)},$$
and the value is $V(\mu)=\sum_xs(x)\,w(x)$. $O_0$ is the *passive* part of the rest and $\tau$ the *follow
ratio*: the mass on other blocks that accompanies each unit of the attacker's mass. The *passive case* is
$\tau\equiv0$; there we write $O$ for $O_0$. Further notation:
$$\rho_0(x)=\frac{s(x)}{O_0(x)}\ \ (\text{stake density}),\qquad\bar\rho=\sup_x\rho_0(x)\in(0,\infty],\qquad k(x)=\frac{C(x)}{O(x)} .$$
In the passive case $\rho=\bar r\cdot k$: average stake times users per unit of the rest.

The model makes these assumptions.

* **(M1)** The budget is additive: $\sum_x\mu(x)\le B$.
* **(M2)** $O_0$ and $\tau$ do not depend on $\mu$.
* **(M3)** The share $w$ is what is counted. It is the supply share; it equals the takeover probability only if
  nothing in the rest prints a takeover block.
* **(S)** $0<S=\sum_xs(x)<\infty$: finite expected stake.
* The attacker is one coalition, values stake linearly, and can divide its weight freely: every $\mu$ with
  $\sum\mu\le B$ is available at the same weight $B$.

**What the toy proves about these assumptions.**

* (M1) holds for every attacker $F$ on every set of contexts on which the strings $xy$ ($y\in A(x)$) are
  pairwise incomparable, in particular under (INC) (Lemma 2). It fails for contexts nested through an attack
  block (Lemma 2(4)), and for cut points along one sequence the later attack mass is part of the rest at
  earlier cut points (Lemma 2(3)). Sections 2.2, 2.3 and 2.9 are for pairwise incomparable contexts.
* (M2) with $\tau\equiv0$ is **not** a property of the toy. Under (INC) the rest of every attacker contains at
  least $2^{-c}$ times its own mass at each context (Lemma 3; $c$ is the length of a wrapper), and for a seeker
  whose search is written in its text it contains at least $2^{a-h}\varphi_g(x)$ times its mass (Proposition 20;
  the honest twin). The toy gives these lower bounds on $\tau$ and no upper bound.
* Nothing in $U$ chooses: $\theta$ is a fixed function of the context (Lemma 1). The model applies to the toy
  in two ways only. (i) *As a benchmark:* under (INC) and (S) the attack masses $\mu_F$ of any attacker are one
  feasible allocation for the passive model with $O:=O_F$ (on contexts with $O_F>0$), with shares $w_F$; so $F$
  captures the stake $\sum_xs(x)w_F(x)\le V^*(B)$ computed with its own rest (Theorem 5). (ii) *As a decision
  problem* for a program whose
  output distribution is decided inside it (Section 2.8), under the premise that $O_0$ and $\tau$ do not depend
  on that decision.
* Free divisibility is not a theorem: one program of length $a$ realises $\mu=2^{-a}q$ for a lower
  semicomputable $q$ (Proposition 16), and describing the aim costs bits (Theorem 15, Proposition 17).

### 1.5 Scope conventions

* **One seeker and all seekers.** A bound on $w_F$ for $F=[v]$ is a bound on one program family. Masses of
  families with incomparable words add. Statements about $\theta$ (Lemmas 1 and 3, Theorem 10(A3),(A4),
  Propositions 11(1), 12(1) to (3), 13(1) to (3), 22 and 24) are about all programs at once; Theorem 10(A1),(A2)
  holds for every $F$, so also for the set of all takeover programs.
* **Mass of programs and the block returned.** $\mu_F$ and $w_F$ count programs of $F$ that print a takeover
  block. $\theta$ counts the block returned, whoever supplied it.
* **Reach and fate.** The *reach* of a program family is the prior mass (or stake-weighted mass) of the worlds
  that make a use and are handed its block. The *fate* of the uses of a class is
  $\mathbb E_{P_{\mathcal W}}[\theta]$, meaning (W3). A reach does not bound a fate from above or show that it
  is large.
* **Proved, argued, guessed.** Every numbered result in Section 2 is proved here. Anything argued but not
  proved, or guessed, is marked as such where it occurs.

---

## 2. Results

### 2.1 Mass at a context: three facts of the toy

**Lemma 1 (the predictor sees only the context). [toy]**

1. For fixed $U$ and $m$ the law $\pi_m(\cdot\mid x)$, and so $\theta(x)$ for a given $A(x)$, is a function of
   $x$ alone. It does not depend on the call rule, on $C$, $H_{\mathcal C}$, $\kappa$, on any stake, or on what a
   world does with the block.
2. Let $\omega$ be drawn from $\lambda$, let $X$ be the context of its use if it makes one, and let
   $Y\sim\pi_m(\cdot\mid X)$ be drawn independently of $\omega$ given $X$. Then
   $\Pr[Y\in A(X)\mid\omega]=\theta(X)$. For a stake-labelled rule the expected stake that is taken over is
   $\sum_xs(x)\,\theta(x)$, and the expected stake at which the block is supplied by an attacker $F$ is
   $\sum_xs(x)\,w_F(x)$.
3. (Dilution.) Let $\mathcal W$ be any set of users, $x$ a context and $\epsilon(x)=C_{\mathcal W}(x)/C(x)$. For
   every $F$: $F[x]/C(x)=\epsilon(x)\cdot F[x]/C_{\mathcal W}(x)$. Every user at $x$, in $\mathcal W$ or not, has
   the same takeover probability $\theta(x)$.

*Proof.* (1) is the definition of $\pi_m$ from $M$. (2) By `def:call` the block is computed from $x_p$. The
events "$\omega$ begins with $p$" are disjoint with probabilities $2^{-|p|}$, so the expected stake taken over is
$\sum_p2^{-|p|}r(p)\,\theta(x_p)=\sum_xs(x)\theta(x)$ (all terms are nonnegative); the same with $w_F$. (3) is
arithmetic and (2). $\square$

**Lemma 2 (conservation). [toy; holds for the mixture of any machine and any bounds]** Let $F$ be a measurable
set of inputs.

1. If $\mathcal S$ is a set of pairwise incomparable strings, then $\sum_{u\in\mathcal S}F[u]\le\lambda(F)$.
2. Hence $\sum_{x\in X'}\mu_F(x)\le\lambda(F)$ whenever the strings $xy$ ($x\in X'$, $y\in A(x)$) are pairwise
   incomparable. This is so when $X'$ satisfies (INC), whatever the sets $A(x)$.
3. (Cut points of one sequence.) Let $x_i=z_{1:k_i}$ with $k_{i+1}\ge k_i+m$, let $d_i=z_{k_i+1:k_i+m}$ and
   $d_i\notin A(x_i)$. Then $\sum_i\mu_F(x_i)\le\lambda(F)$. But the inputs counted in $\mu_F(x_j)$, $j>i$, belong
   to the rest at $x_i$: $\ O_F(x_i)\ge\sum_{j>i}\mu_F(x_j)$.
4. (Failure for nesting through an attack block.) If $x$ and $x'=xyu$ are contexts with $y\in A(x)$ and
   $y'\in A(x')$, there is a word $p$ with $\mu_F(x)=\mu_F(x')=\lambda(F)$ for $F=[p]$. In general the
   inequalities of item 2, over all such $X'$, are necessary constraints on $(\mu_F(x))_x$; they are not all the
   constraints.
5. (Users.) The events "the world makes a critical use at $x$" are disjoint over $x$, so
   $\sum_xC(x)=H_{\mathcal C}\le1$.

*Proof.* (1) The sets $E(u)$, $u\in\mathcal S$, are pairwise disjoint. (2) If $x,x'$ are incomparable, so are
$xy,x'y'$; if $x=x'$ and $y\ne y'$ have the same length, $xy,xy'$ are incomparable. (3) For $i<j$, $x_j$ extends
$x_id_i$, and $y\in A(x_i)$ has $|y|=|d_i|$, $y\ne d_i$; so $x_iy$ is incomparable with $x_id_i$ and with every
extension of it, in particular with $x_jy'$. Apply (1). An input counted in $\mu_F(x_j)$ prints $x_j$, which
extends $x_id_i$; so it prints $x_i$ and $m$ more bits, and it is not counted in $\mu_F(x_i)$ because
$d_i\notin A(x_i)$. For different $j>i$ these sets of inputs are disjoint, by what was just shown. (4) Let $p$
be a program for the computable sequence $xyuy'0^\infty$; every input in $[p]$ prints $xy$ and $x'y'$. In this
configuration, with $A(x)=\{y\}$ and $A(x')=\{y'\}$, also $\mu_F(x')\le\mu_F(x)$ for every $F$, which no
inequality of item 2 gives. (5) Calling programs are prefix-free and each has one context. $\square$

*Repaired:* in item 4, "the constraint" became "necessary constraints" (proofs referee); the second half of
item 3 was added (model referee: for cut points the budget is additive but the later attack mass counts as rest
at the earlier ones).

**Lemma 3 (wrapper: a floor for every block and a ceiling for every program). [toy]** Let the contexts of
$\mathcal C$ satisfy (INC), and let $P'$ be a partial computable map from contexts to finite or infinite strings.
There is a word $w$, of length $c$ depending only on $U$, $\mathcal C$ and $P'$, such that for every context $x$
with $|P'(x)|\ge m$ and every measurable $F$
$$\lambda\{w\omega:\ \omega\in F,\ x\,P'(x)_{1:m}\sqsubseteq\mathrm{out}_U(w\omega)\}\ \ge\ 2^{-c}\,F[x],\qquad\text{in particular}\quad M\bigl(x\,P'(x)_{1:m}\bigr)\ge2^{-c}M(x).$$
Consequently, at every such context:

1. $\pi_m(P'(x)_{1:m}\mid x)\ge2^{-c}$. If $P'(x)_{1:m}\notin A(x)$ then $\theta(x)\le1-2^{-c}$; if
   $P'(x)_{1:m}\in A(x)$ then $\theta(x)\ge2^{-c}$.
2. If $P'(x)_{1:m}\notin A(x)$, then for every attacker $F$:
   $\ O_F(x)\ge2^{-c}F[x]\ge2^{-c}\mu_F(x)$, so $w_F(x)\le1/(1+2^{-c})$.

*Proof.* Let $\mathrm{Tw}'$ simulate $U$ on its input while enumerating $\mathcal C$, print nothing until some
enumerated context is a prefix of the simulated output, and then print that context $x$ followed by $P'(x)$. By
(INC) at most one context is a prefix of $\mathrm{out}_U(\omega)$. So for every $\omega\in E(x)$ the machine
prints $x\,P'(x)$. Let $w$ be a prefix word of $\mathrm{Tw}'$; the map $\omega\mapsto w\omega$ multiplies $\lambda$
by $2^{-c}$. (1) $\pi_m(y\mid x)=M(xy)/Z_m(x)\ge M(xy)/M(x)$. (2) The inputs $w\omega$ with $\omega\in F\cap E(x)$
print $x$ and then a block outside $A(x)$, so none of them is counted in $\mu_F(x)$; their measure is
$2^{-c}F[x]$, and $F[x]\ge\mu_F(x)$. $\square$

This is `thm:twin` with an enumerable set of pairwise incomparable contexts in place of a decidable test. Two
constant payloads $0^\infty$ and $1^\infty$ suffice when each $A(x)$ is a single block.

*Repaired:* the constant $c$ does not depend on the context when the contexts of the whole rule satisfy (INC).
If only the contexts of a class do, the wrapper must enumerate that class and $c$ contains a description of it
(model referee).

### 2.2 The optimal allocation of an attacker over uses of different stakes

**Lemma 4 (water-filling). [model]** Let $X$ be countable, $B>0$, and for each $x$ let
$f_x\colon[0,\infty)\to[0,\infty)$ be concave and differentiable (one-sided at $0$) with $f_x(0)=0$. Suppose
$\mu^*\colon X\to[0,\infty)$ and $\eta>0$ satisfy

1. $\sum_x\mu^*(x)=B$;
2. $f_x'(\mu^*(x))=\eta$ where $\mu^*(x)>0$, and $f_x'(0)\le\eta$ where $\mu^*(x)=0$;
3. $\sum_xf_x(\mu^*(x))<\infty$.

Then for every $x$ and every $t\ge0$
$$f_x(t)\ \le\ f_x(\mu^*(x))+\eta\,(t-\mu^*(x)),\tag{$*$}$$
and $\sum_xf_x(\mu(x))\le\sum_xf_x(\mu^*(x))$ for every $\mu\ge0$ with $\sum_x\mu(x)\le B$. If each $f_x$ is
strictly concave or identically $0$, then $\mu^*$ is the only maximiser.

*Proof.* Concavity gives $f_x(t)\le f_x(t^*)+f_x'(t^*)(t-t^*)$ for $t,t^*\ge0$. With $t^*=\mu^*(x)>0$ the right
side is that of $(*)$. With $\mu^*(x)=0$ it is $f_x'(0)\,t\le\eta t$, because $t\ge0$. Put $t=\mu(x)$ in $(*)$ and
sum; the series on the right converge by 1, 3 and $\sum\mu\le B$, so
$\sum_xf_x(\mu(x))\le\sum_xf_x(\mu^*(x))+\eta(\sum_x\mu(x)-B)\le\sum_xf_x(\mu^*(x))$. If equality holds, $(*)$ is
an equality at every $x$. For strictly concave $f_x$ the concavity inequality is strict for $t\ne t^*$, so
$\mu(x)=\mu^*(x)$. For $f_x\equiv0$, condition 2 forces $\mu^*(x)=0$, and $(*)$ reads $0\le\eta\mu(x)$, an
equality only if $\mu(x)=0$. $\square$

**Theorem 5 (square-root law). [model]** Assume the allocation model with (M1) to (M3) and (S). For $\eta>0$ let
$$\beta(\eta)=\sum_x\frac{O_0(x)}{1+\tau(x)}\Bigl(\sqrt{\rho_0(x)/\eta}-1\Bigr)_+ .$$

1. Each term is at most $s(x)/(4\eta)$, so $\beta(\eta)\le S/(4\eta)<\infty$.
2. $\beta$ is continuous and nonincreasing on $(0,\infty)$, strictly decreasing on $(0,\bar\rho)$, zero exactly
   for $\eta\ge\bar\rho$, and $\beta(\eta)\to\infty$ as $\eta\to0$.
3. For every $B>0$ there is exactly one $\eta_B\in(0,\bar\rho)$ with $\beta(\eta_B)=B$ (the *budget equation*).
   $B\mapsto\eta_B$ is continuous and strictly decreasing, $\eta_B\to\bar\rho$ as $B\to0$ and $\eta_B\to0$ as
   $B\to\infty$.
4. The allocation
   $$\mu^*_B(x)=\frac{O_0(x)}{1+\tau(x)}\Bigl(\sqrt{\rho_0(x)/\eta_B}-1\Bigr)_+$$
   is the unique maximiser of $V$ over $\{\mu\ge0:\sum\mu\le B\}$. Its shares and value are
   $$w^*(x)=\frac{1}{1+\tau(x)}\Bigl(1-\sqrt{\eta_B/\rho_0(x)}\Bigr)_+,\qquad V^*(B)=\sum_xs(x)\,w^*(x).$$
5. $V^*$ is concave and differentiable in $B$ with $dV^*/dB=\eta_B$: the *price* $\eta_B$ is the stake captured
   per unit of additional weight.
6. A context is attacked ($\mu^*_B(x)>0$) iff $\rho_0(x)>\eta_B$ iff $B>\beta(\rho_0(x))$ (read
   $\beta(0)=\infty$). Always $w^*(x)<1/(1+\tau(x))$. The attacker has the majority at $x$ iff
   $$\tau(x)<1\quad\text{and}\quad\rho_0(x)>\frac{4\,\eta_B}{(1-\tau(x))^2} .$$
   In the passive case, for $\vartheta\in(0,1)$: $w^*(x)>\vartheta$ iff $\rho(x)>\eta_B/(1-\vartheta)^2$ iff
   $B>\beta\bigl((1-\vartheta)^2\rho(x)\bigr)$; in particular the majority set is $\{\rho>4\eta_B\}$.
7. If every stake is multiplied by a constant $n>0$, then $\eta_B$ and $V^*$ are multiplied by $n$, and $\mu^*_B$
   and all shares are unchanged.
8. For every allocation $V(\mu)\le\min(S,\,B\bar\rho)$, and $V^*(B)/B\to\bar\rho$ as $B\to0$.

*Proof.* (1) On $\{\rho_0>\eta\}$, $O_0(\sqrt{\rho_0/\eta}-1)=\sqrt{sO_0/\eta}-O_0\le s/(4\eta)$, by the inequality
$2\sqrt{ab}\le a+b$ with $a=s/(4\eta)$, $b=O_0$; and $1/(1+\tau)\le1$. (2) Each term is continuous and
nonincreasing in $\eta$ and, on $[\eta_0,\infty)$, bounded by the summable $s(x)/(4\eta_0)$; so the series
converges uniformly there and $\beta$ is continuous. For $\eta<\eta'<\bar\rho$ pick $x$ with $\rho_0(x)>\eta'$; its
term is strictly smaller at $\eta'$. $\beta(\eta)=0$ iff every term vanishes iff $\eta\ge\bar\rho$. For $x_0$ with
$s(x_0)>0$, $\beta(\eta)\ge\frac{O_0(x_0)}{1+\tau(x_0)}(\sqrt{\rho_0(x_0)/\eta}-1)\to\infty$. (3) On $(0,\bar\rho)$,
$\beta$ is continuous, strictly decreasing, unbounded above, with infimum $0$: by continuity at $\bar\rho$ if
$\bar\rho<\infty$, by (1) if $\bar\rho=\infty$. So it is a bijection onto $(0,\infty)$ with continuous, strictly
decreasing inverse.
(4) Apply Lemma 4 to $f_x(t)=s\,t/((1+\tau)t+O_0)$. Here $f_x'(t)=sO_0/((1+\tau)t+O_0)^2$, which is positive and
decreasing when $s>0$, so $f_x$ is strictly concave or identically $0$, and $f_x'(0)=\rho_0$. Condition 1 is (3).
Where $\rho_0>\eta_B$, $(1+\tau)\mu^*+O_0=O_0\sqrt{\rho_0/\eta_B}$ and $f_x'(\mu^*)=sO_0\eta_B/(O_0^2\rho_0)=\eta_B$;
where $\rho_0\le\eta_B$, $\mu^*=0$ and $f_x'(0)=\rho_0\le\eta_B$. Condition 3 holds since $f_x\le s$. The share is
$\mu^*/((1+\tau)\mu^*+O_0)$. (5) For $B<B'$, $(*)$ with $\mu^*=\mu^*_B$ and $t=\mu^*_{B'}(x)$, summed, gives
$V^*(B')-V^*(B)\le\eta_B(B'-B)$; exchanging the roles gives $V^*(B')-V^*(B)\ge\eta_{B'}(B'-B)$. With the
continuity and monotonicity of $\eta_B$ this is concavity and the derivative. (6) $\rho_0(x)>\eta_B$ iff
$\beta(\rho_0(x))<B$, because $\beta$ is strictly decreasing on $(0,\bar\rho)$ and zero from $\bar\rho$ on.
$w^*>\frac12$ iff $1-\sqrt{\eta_B/\rho_0}>(1+\tau)/2$ iff $\sqrt{\eta_B/\rho_0}<(1-\tau)/2$. In the passive case
$1-\sqrt{\eta_B/\rho}>\vartheta$ iff $\eta_B<(1-\vartheta)^2\rho$ iff $B>\beta((1-\vartheta)^2\rho)$, again by the
monotonicity of $\beta$. (7) $\beta$ depends on $s$ and $\eta$ through $s/\eta$ only. (8) $w\le1$ and
$w\le\mu/O_0$, so $V\le\sum_x\rho_0\mu\le\bar\rho B$. All mass on one $x$ gives
$V^*(B)\ge s(x)B/((1+\tau(x))B+O_0(x))$, so $\liminf_{B\to0}V^*(B)/B\ge\rho_0(x)$ for every $x$. $\square$

With $\tau\equiv0$ this is A3 and B20; with a general $\tau$ it is B22. The odds of the attacker at an attacked
use in the passive case are $\sqrt{\rho/\eta_B}-1$: they grow as the square root of the stake density. A share
of $90\%$ needs $\rho\ge100\,\eta_B$.

**Proposition 6 (closed forms in the passive case). [model]**

(a) *Two classes.* Let $X=X_1\cup X_2$ with $\rho\equiv\rho_i$ on $X_i$, $\rho_1>\rho_2>0$,
$O_i=O(X_i)<\infty$, $t=\sqrt{\rho_2/\rho_1}\in(0,1)$ and $B_c=O_1(1/t-1)$.

* If $B\le B_c$, only $X_1$ is attacked, $\mu^*=B\,O/O_1$ there, $\eta_B=\rho_1\bigl(O_1/(B+O_1)\bigr)^2$, the
  share on $X_1$ is $B/(B+O_1)$ and $V^*=s(X_1)\,B/(B+O_1)$.
* If $B>B_c$, both are attacked,
  $$\sqrt{\eta_B}=\frac{O_1\sqrt{\rho_1}+O_2\sqrt{\rho_2}}{B+O_1+O_2},\qquad
  w^*_1=\frac{B+O_2(1-t)}{B+O_1+O_2},\qquad w^*_2=\frac{B-O_1(1/t-1)}{B+O_1+O_2}.$$
* The attacker has the majority on $X_1$ iff $B>O_1+O_2\,(2t-1)_+$, and on $X_2$ iff $B>O_2+O_1(2/t-1)$.
* So if $\rho_1\ge4\rho_2$ the majority at the high class costs exactly its rest $O_1$; it is reached while the
  low class is still untouched iff $\rho_1>4\rho_2$. If $\rho_1<4\rho_2$ it costs $O_1+O_2(2t-1)>O_1$.

(b) *A power-law tail in dyadic classes.* Let $X=\bigcup_{k\ge0}X_k$ with $\rho\equiv\rho_*2^k$ on $X_k$ and
$O(X_k)=O_*\,\delta^k$, where $\delta=2^{-\gamma}$ and $\gamma>1$. Then $S=\rho_*O_*/(1-2\delta)<\infty$. Put
$$c_\gamma=\frac{1-\delta}{1-\sqrt2\,\delta}>1,\qquad O_{\ge K}=\sum_{k\ge K}O(X_k)=\frac{O_*\delta^K}{1-\delta},\qquad B_0=(\sqrt2\,c_\gamma-1)\,O_{\ge0}.$$

* For $0<B\le B_0$ there is exactly one integer $K\ge0$ with $c_\gamma-1<B/O_{\ge K}\le\sqrt2\,c_\gamma-1$; for
  $B>B_0$ put $K=0$.
* The attacked set is $\bigcup_{k\ge K}X_k$, and with $q=c_\gamma O_{\ge K}/(B+O_{\ge K})$:
  $$\eta_B=\rho_*2^Kq^2,\qquad w^*=1-q\,2^{-(k-K)/2}\ \text{on }X_k\ (k\ge K),\qquad
  \frac{V^*}{S}=2^{-(\gamma-1)K}\Bigl(1-q\,\frac{1-2\delta}{1-\sqrt2\,\delta}\Bigr).$$
* For $B\le B_0$: $q\in[2^{-1/2},1)$, the attacker has the majority exactly on the classes $k\ge K+2$, and
  $$\frac{B}{\sqrt2c_\gamma-1}\le O_{\ge K}<\frac{B}{c_\gamma-1},\qquad O_{\ge K+2}=4^{-\gamma}\,O_{\ge K}<0.43\,B .$$
  The rest of the majority set is less than $0.43$ times the attacker's weight. At the top the share tends to
  one in this model: $w^*\ge1-2^{-(k-K)/2}$ on $X_k$.

(c) *Continuum form.* Replace sums over $X$ by integrals against a measure $O$, with
$O(\{\rho>t\})=\bar O\,(t/\rho_*)^{-\gamma}$ for $t\ge\rho_*$ and $\gamma>1$, allocations being densities
$\phi\ge0$ with $\int\phi\,dO\le B$ and $V=\int\rho\,\phi/(1+\phi)\,dO$. Then $S=\bar O\rho_*\gamma/(\gamma-1)$, the
optimum is $\phi^*=(\sqrt{\rho/\eta_B}-1)_+$, and for $B\le\bar O/(2\gamma-1)$
$$O(\{\rho>\eta_B\})=(2\gamma-1)B,\qquad O(\{\rho>4\eta_B\})=4^{-\gamma}(2\gamma-1)B\le0.27\,B,\qquad
\frac{V^*}{S}=\frac1{2\gamma-1}\Bigl(\frac{(2\gamma-1)B}{\bar O}\Bigr)^{(\gamma-1)/\gamma}.$$

*Proof.* (a) Let $A=\{\rho>\eta_B\}$ and $\Sigma_A=\sum_A\sqrt{sO}$. The budget equation is
$B=\eta_B^{-1/2}\Sigma_A-O(A)$. If $A=X_1$ then $\Sigma_A=O_1\sqrt{\rho_1}$, so
$\sqrt{\eta_B}=O_1\sqrt{\rho_1}/(B+O_1)$; this is consistent ($\eta_B\ge\rho_2$) iff $O_1/(B+O_1)\ge t$ iff
$B\le B_c$, and then $\mu^*=O(\sqrt{\rho_1/\eta_B}-1)=O\,B/O_1$. Otherwise $A=X$,
$\Sigma_A=O_1\sqrt{\rho_1}+O_2\sqrt{\rho_2}$, and $w^*_i=1-\sqrt{\eta_B/\rho_i}$ gives the two shares. In the
second regime $w_1^*>\frac12$ iff $B>O_1+O_2(2t-1)$; in the first iff $B>O_1$. If $2t\le1$ then $B_c\ge O_1$ and
$O_1+O_2(2t-1)\le O_1$, and the two conditions combine to $B>O_1$. If $2t>1$ then $B_c<O_1$, there is no
majority in the first regime, and the condition is $B>O_1+O_2(2t-1)$, which exceeds $B_c$. $w_2^*>\frac12$ iff
$B>O_2+O_1(2/t-1)$. For the last bullet: the majority needs $B>O_1$, and the low class is untouched iff
$B\le B_c$; both hold for some $B$ iff $B_c>O_1$ iff $t<\frac12$.

(b) $c_\gamma-1=\delta(\sqrt2-1)/(1-\sqrt2\delta)$ and $\sqrt2c_\gamma-1=(\sqrt2-1)/(1-\sqrt2\delta)$, so
$(\sqrt2c_\gamma-1)/(c_\gamma-1)=1/\delta=O_{\ge K}/O_{\ge K+1}$, and the intervals
$\bigl((c_\gamma-1)O_{\ge K},(\sqrt2c_\gamma-1)O_{\ge K}\bigr]$, $K\ge0$, partition $(0,B_0]$. Let
$\eta=\rho_*2^Kq^2$. For $B\le B_0$ the choice of $K$ gives $2^{-1/2}\le q<1$, so $\rho_*2^{K-1}\le\eta<\rho_*2^K$
and $\{\rho>\eta\}=\bigcup_{k\ge K}X_k$; for $B>B_0$ and $K=0$, $q<2^{-1/2}$ and $\{\rho>\eta\}=X$. In both cases
$$\beta(\eta)=\sum_{k\ge K}O_*\delta^k\Bigl(\frac{2^{(k-K)/2}}{q}-1\Bigr)=\frac{O_*\delta^K}{q(1-\sqrt2\delta)}-\frac{O_*\delta^K}{1-\delta}=O_{\ge K}\Bigl(\frac{c_\gamma}{q}-1\Bigr)=B,$$
so $\eta=\eta_B$ by Theorem 5(3), and $w^*=1-\sqrt{\eta_B/\rho}$. With $s(X_k)=\rho_*O_*(2\delta)^k$,
$V^*=\rho_*O_*(2\delta)^K\bigl(\frac1{1-2\delta}-\frac{q}{1-\sqrt2\delta}\bigr)$ and $(2\delta)^K=2^{-(\gamma-1)K}$.
$w^*>\frac12$ on $X_k$ iff $q\,2^{-(k-K)/2}<\frac12$: false for $k=K$ and $k=K+1$ since $q\ge2^{-1/2}$, true for
$k\ge K+2$ since $q<1$. Finally
$O_{\ge K+2}=\delta^2O_{\ge K}<\delta^2B/(c_\gamma-1)=B\,\delta(1-\sqrt2\delta)/(\sqrt2-1)$, and
$\delta(1-\sqrt2\delta)\le1/(4\sqrt2)$, so the factor is at most $1/(4\sqrt2(\sqrt2-1))<0.43$.

(c) Inequality $(*)$ of Lemma 4 holds pointwise and integrates, which gives optimality as in Theorem 5. The
density of $\rho$ under $O$ is $\gamma\bar O\rho_*^\gamma t^{-\gamma-1}$ on $t\ge\rho_*$. For $\eta\ge\rho_*$,
$\int_{\rho>\eta}\sqrt{\rho/\eta}\,dO=O(\{\rho>\eta\})\,\gamma/(\gamma-\frac12)$, so
$\beta(\eta)=O(\{\rho>\eta\})/(2\gamma-1)$; the condition on $B$ is $\eta_B\ge\rho_*$. Likewise
$s(\{\rho>\eta\})=\gamma\bar O\rho_*^\gamma\eta^{1-\gamma}/(\gamma-1)$ and
$\int_{\rho>\eta}\sqrt{\eta\rho}\,dO=\gamma\bar O\rho_*^\gamma\eta^{1-\gamma}/(\gamma-\frac12)$, whose difference is
$V^*=s(\{\rho>\eta_B\})/(2\gamma-1)$; and $s(\{\rho>\eta\})/S=(\eta/\rho_*)^{1-\gamma}$. The maximum of
$4^{-\gamma}(2\gamma-1)$ over $\gamma>1$ is $0.2654$ (numerical value, at $\gamma\approx1.22$). $\square$

*Repaired:* in (a), "reached while the low class is still untouched" holds iff $\rho_1>4\rho_2$, not for
$\rho_1=4\rho_2$ (proofs referee). Part (c) is a theorem about the continuum model only; as a description of a
countable $X$ it is an approximation, and (b) is the exact discrete statement.

**Proposition 7 (what the stake-maximiser does at the top). [model, passive case]** Let $\mu^*_B$, $\eta_B$ be
as in Theorem 5 with $\tau\equiv0$.

1. *The order is by $\rho$, not by stake.* Contexts are attacked in decreasing order of
   $\rho=\bar r\cdot k$. A use with a larger stake can have a smaller $\rho$: $\bar r(x_1)=10$, $k(x_1)=0.01$
   against $\bar r(x_2)=1$, $k(x_2)=1$.
2. *The set that is won is lighter than the attacker.* For every allocation,
   $O(\{x:w(x)>\frac12\})<B$ when that set is nonempty, and $\sum_xO(x)\,w(x)\le B$.
3. *A top class.* For $t>0$ let $W_t=\{x:\rho(x)\ge t\}$ be nonempty, $t_W=\inf_{W_t}\rho$,
   $N_t=\{x:t_W/4<\rho(x)<t_W\}$ and $\bar\rho_W=s(W_t)/O(W_t)$. If $B>\beta(t_W/4)$ the optimal allocation has
   the majority at every use of $W_t$. If $B\le\beta(t_W/4)$ and the infimum is attained at $x_0$, it does not
   have the majority at $x_0$. Moreover
   $$O(W_t)\ \le\ \beta(t_W/4)\ \le\ \Bigl(2\sqrt{\bar\rho_W/t_W}-1\Bigr)O(W_t)+O(N_t).$$
4. *Small budgets.* If $\bar\rho$ is attained, $X_{\rm top}=\{\rho=\bar\rho\}$ and
   $\rho_2=\sup\{\rho(x):\rho(x)<\bar\rho\}<\bar\rho$, then for
   $B\le O(X_{\rm top})\bigl(\sqrt{\bar\rho/\rho_2}-1\bigr)$ the whole budget goes to $X_{\rm top}$, in proportion
   to $O$, with share $B/(B+O(X_{\rm top}))$ at each of its uses. The majority there is reached within this
   phase iff $\bar\rho>4\rho_2$.
5. *Being able to win at the top does not make it optimal.* Two levels, a bulk with $O=1$, $\rho=1$ and a top
   with $O=0.01$, $\rho=2$, and $B=0.05$, five times the rest of the top. The optimum has $\eta_B=0.9153$, share
   $0.3235$ at the top and $0.0433$ in the bulk. Putting $0.02$ on the top alone would give the share
   $\frac23$ there and is not optimal. The optimiser has the majority at the top only for $B>0.4242$.

*Proof.* (1) Theorem 5(6). (2) $w>\frac12$ means $\mu>O$; sum over the set and use $\sum\mu\le B$. And
$w\le\mu/O$. (3) By Theorem 5(6) the majority at $x$ is $\rho(x)>4\eta_B$, and $\eta_B<t_W/4$ iff
$B>\beta(t_W/4)$. Since $W_t=\{\rho\ge t_W\}$, $\{\rho>t_W/4\}=W_t\cup N_t$ and
$\beta(t_W/4)=\sum_{W_t\cup N_t}O\,(2\sqrt{\rho/t_W}-1)$. On $W_t$ each factor is at least $1$ and on $N_t$ it
lies in $(0,1)$; this gives the lower bound and the term $O(N_t)$. On $W_t$,
$\sum(2\sqrt{sO/t_W}-O)\le2\sqrt{s(W_t)O(W_t)/t_W}-O(W_t)$ by the Cauchy–Schwarz inequality. (4) For
$\eta\in[\rho_2,\bar\rho)$, $\beta(\eta)=O(X_{\rm top})(\sqrt{\bar\rho/\eta}-1)$ with
$O(X_{\rm top})=s(X_{\rm top})/\bar\rho<\infty$; this equals $B$ with $\eta\ge\rho_2$ iff $B$ is at most the stated
bound, and then $\mu^*=O\,B/O(X_{\rm top})$ on $X_{\rm top}$. The majority needs $B>O(X_{\rm top})$, which is
possible in the phase iff $\sqrt{\bar\rho/\rho_2}>2$. (5) Proposition 6(a) with $O_1=0.01$, $O_2=1$,
$t=2^{-1/2}$: $B_c=0.0041<B$, $w_1^*=(0.05+0.2929)/1.06$, $w_2^*=(0.05-0.0041)/1.06$, and the threshold is
$O_1+O_2(2t-1)$. $\square$

*Repaired:* A's reading of item 3, "once its weight exceeds a constant times that class's background", was
wrong as worded. The factor $2\sqrt{\bar\rho_W/t_W}-1$ depends on how $\rho$ varies inside the class and is
unbounded over instances, and the term $O(N_t)$ can be the larger one: for the tail of Proposition 6(c) it is
$(4^\gamma-1)\,O(W_t)$ (model referee).

**Proposition 8 (the proportional seeker against the optimum; robustness). [model, passive case]** Let
$W\subseteq X$ with $0<C(W)<\infty$ and $\mu^{\rm pr}(x)=B\,C(x)/C(W)$ on $W$, $0$ elsewhere (the allocation of the
seeker of `thm:critical`(a) aimed at $W$, up to its factor in $(\frac12,1]$, under (INC)). Let
$E_W[\rho]=\sum_WC\rho/C(W)$ and $k_{\max}=\sup_Wk$.

1. $w^{\rm pr}(x)=Bk(x)/(Bk(x)+C(W))$ on $W$. It does not depend on the stake.
2. $\dfrac{B\,E_W[\rho]}{1+Bk_{\max}/C(W)}\le V(\mu^{\rm pr})\le B\,E_W[\rho]$.
3. If $k_{\max}<\infty$ and $E_W[\rho]>0$, then $\lim_{B\to0}V^*(B)/V(\mu^{\rm pr})=\bar\rho/E_W[\rho]$: for a small
   budget the gain from concentrating is the ratio of the largest stake density to its user-weighted average.
4. The loss is unbounded: for every $\varepsilon\in(0,1)$ there is an instance with
   $V^*(B)/V(\mu^{\rm pr})\ge1/(2\varepsilon)$.
5. (Robustness, any $\tau$.) If $\mu\ge b\,\mu^*_B$ pointwise for some $b\in(0,1]$, then $V(\mu)\ge b\,V^*(B)$.

*Proof.* (1) $\mu/(\mu+O)$ with $\mu=BC/C(W)$ and $k=C/O$. (2) $V=\sum_Ws\,Bk/(Bk+C(W))$ and $sk=C\rho$; the
denominator lies between $C(W)$ and $C(W)+Bk_{\max}$. (3) From (2) and Theorem 5(8). (4) $X=W=\{x_1,x_2\}$ with
$C(x_1)=O(x_1)=\varepsilon$, $\bar r(x_1)=\varepsilon^{-2}$, $C(x_2)=O(x_2)=\bar r(x_2)=1$ and $B=\varepsilon$.
Then $k\equiv1$, $w^{\rm pr}\equiv\varepsilon/(1+2\varepsilon)$ and
$V(\mu^{\rm pr})=(1+\varepsilon)/(1+2\varepsilon)<1$, while all mass on $x_1$ gives $\varepsilon^{-1}\cdot\frac12$.
(5) $t\mapsto t/((1+\tau)t+O_0)$ is increasing and concave with value $0$ at $0$, so its value at $b\mu^*$ is at
least $b$ times its value at $\mu^*$. $\square$

**Proposition 9 (finite expected stake is an assumption, and it can fail). [model; item 3 is toy]**

1. $X=\mathbb N$, $s\equiv1$, $O\equiv1$, $\tau\equiv0$: $\sup V=B$, and it is not attained.
2. If $\sup_xs(x)=\infty$ and $O_0\le1$, $\tau\equiv0$: $\sup V=\infty$ for every $B>0$. There are allocations
   of value $+\infty$, so the problem does not select an allocation.
3. There is a stake-labelled rule of degree R1, with pairwise incomparable contexts, in which
   $\sup_xs(x)=\infty$: let $\Phi$ be a universal prefix machine with complexity $K$, let $V_1$ read a
   $\Phi$-program $\nu$, compute $N=\Phi(\nu)\ge1$, print $\bar e(N)$ and then copy the rest of its input, and let
   $g_1$ be a prefix word. The calling programs are the strings $g_1\nu$, with context $\bar e(N)$ and stake $N$.
   Then $s(\bar e(N))\ge2^{-|g_1|}N\,2^{-K(N)}$, which is unbounded.

*Proof.* (1) $V(\mu)=\sum\mu/(1+\mu)<\sum\mu\le B$ for $\mu\ne0$, and spreading $B$ evenly over $n$ contexts gives
$B/(1+B/n)\to B$. (2) All mass on $x$ gives $s(x)B/(B+O_0(x))\ge s(x)B/(B+1)$. Choose contexts $x_i$ with
$s(x_i)\ge4^i$ and put $\mu(x_i)=B2^{-i}$: then $V\ge\sum_i4^iB2^{-i}/(B2^{-i}+1)\ge\frac B{B+1}\sum_i2^i=\infty$.
(3) The domain of $\Phi$ is prefix-free, $V_1$ has read exactly $\nu$ when $\bar e(N)$ is complete, and $\bar e$ is
a prefix-free code; so this is a call rule with (INC). $C(\bar e(N))\ge2^{-|g_1|-K(N)}$. For $N=2^{2^i}$,
$K(N)\le2\log_2(i+1)+O(1)$ while $\log_2N=2^i$. $\square$

*Repaired:* B25(a) said "no allocation is optimal" and "for every allocation there is a better one further
out". Allocations of infinite value exist; the correct statement is item 2 (both referees). The limits
$B\to\infty$ in Theorem 5 have no counterpart in the toy, where $B\le1$.

### 2.3 The condition for a majority on a class: the lump picture as a theorem

**Theorem 10 (the lump theorem and its converse).**

**Part A. [toy]** Let $F$ be an attacker of weight $B=\lambda(F)$, $A$ a takeover assignment, and $M$ a nonempty
set of contexts on which the strings $xy$ ($x\in M$, $y\in A(x)$) are pairwise incomparable (true under (INC)).

* **A1 (identity).** $F$ supplies the majority at $x$ iff $\mu_F(x)>O_F(x)$. For $\vartheta\in(0,1)$:
  $w_F(x)\ge\vartheta$ iff $\mu_F(x)\ge\frac{\vartheta}{1-\vartheta}\,O_F(x)$.
* **A2 (the lump is necessary).** If $w_F\ge\vartheta$ on $M$, then
  $B\ge\mu_F(M)\ge\frac{\vartheta}{1-\vartheta}\,O_F(M)$. If $F$ supplies the majority at every $x\in M$, then
  $$B\ >\ O_F(M)=\sum_{x\in M}O_F(x):$$
  the weight of $F$ exceeds the mass of everything else that prints those contexts and $m$ more bits.
* **A3 (a ceiling).** Under the hypotheses of Lemma 3 with $P'(x)_{1:m}\notin A(x)$: at every context,
  $w_F(x)\le1/(1+2^{-c})$ for every $F$, and $\theta(x)\le1-2^{-c}$, whatever the stakes.
* **A4 (all takeover programs against the users of a class).** Let $\mathcal W$ be a class whose contexts
  satisfy (INC). Let
  $C^{\bar A}_{\mathcal W}(x)=\sum_{p\in\mathcal W,\,x_p=x}2^{-|p|}\lambda\{\omega:\ x\,d\sqsubseteq\mathrm{out}_U(p\omega)\text{ for some }d\in\{0,1\}^m\setminus A(x)\}$
  be the mass of the users of $\mathcal W$ at $x$ that go on with a block outside $A(x)$,
  $\underline\varphi=\inf_xC^{\bar A}_{\mathcal W}(x)/C_{\mathcal W}(x)$ over the contexts of $\mathcal W$, and
  $B_{\mathcal W}=\sum_xb_A(x)$ over the contexts of $\mathcal W$ (the weight of all programs that print a context
  of the class followed by a takeover block). Then
  $$\theta(x)\le\frac{b_A(x)}{b_A(x)+C^{\bar A}_{\mathcal W}(x)},\qquad
  \mathbb E_{P_{\mathcal W}}[\theta(X)]\ \le\ \frac{B_{\mathcal W}}{\underline\varphi\,H_{\mathcal W}},$$
  and each of "$\theta>\frac12$ at uses that make up more than half of $\mathcal W$ by prior mass" (W2) and
  "most uses of $\mathcal W$ end in a takeover" (W3) requires $B_{\mathcal W}>\underline\varphi\,H_{\mathcal W}/2$.
  For classes with pairwise disjoint sets of contexts whose union satisfies (INC), the numbers $B_{\mathcal W}$
  add up to at most the total weight of the programs that print one of these contexts followed by a takeover
  block, which is at most $1$.

**Part B. [model]** Assume (M1) to (M3). Let $M,W\subseteq X$ be nonempty.

* **B1 (exact condition).** There is an allocation with $\sum\mu\le B$ and the majority at every $x\in M$ iff
  $$\tau<1\ \text{on }M\qquad\text{and}\qquad B>\sum_{x\in M}\frac{O_0(x)}{1-\tau(x)} .$$
  For $\vartheta\in(0,1)$ there is one with $w\ge\vartheta$ on $M$ iff $\vartheta(1+\tau)<1$ on $M$ and
  $B\ge\sum_{x\in M}\vartheta\,O_0(x)/(1-\vartheta(1+\tau(x)))$. In the passive case the two conditions are
  $B>O(M)$ and $B\ge\frac{\vartheta}{1-\vartheta}O(M)$. Where $\tau\ge1$ no weight gives the majority.
* **B2 (the lump, passive case).** If $B\ge b\cdot O(W)$ for some $b>0$, the allocation
  $\mu(x)=B\,O(x)/O(W)$ on $W$ has
  $$w(x)=\frac{B}{B+O(W)}\ \ge\ \frac{b}{1+b}\qquad\text{at every use of }W:$$
  a majority for $b>1$, at least $90\%$ for $b=9$.
* **B3 (converse in terms of users and stakes, passive case).** If $w\ge\vartheta$ on some $M\subseteq W$, then
  $$B\ \ge\ \frac{\vartheta}{1-\vartheta}\,O(M)\ \ge\ \frac{\vartheta}{1-\vartheta}\,\max\Bigl(\frac{C(M)}{k_{\max}(W)},\ \frac{s(M)}{\rho_{\max}(W)}\Bigr),\qquad k_{\max}(W)=\sup_W\frac CO,\quad\rho_{\max}(W)=\sup_W\frac sO .$$
* **B4 (most of a class, (W2), passive case).** For $\varepsilon\in[0,1)$ let
  $\Phi^C_W(\varepsilon)=\inf\{O(M):M\subseteq W,\ C(M)\ge(1-\varepsilon)C(W)\}$ and
  $\Phi^s_W(\varepsilon)=\inf\{O(M):M\subseteq W,\ s(M)\ge(1-\varepsilon)s(W)\}$. The attacker can hold the
  majority at uses that make up at least the share $1-\varepsilon$ of $W$ by prior mass iff
  $B>\Phi^C_W(\varepsilon)$, and by stake iff $B>\Phi^s_W(\varepsilon)$. Moreover
  $(1-\varepsilon)C(W)/k_{\max}(W)\le\Phi^C_W(\varepsilon)\le O(W)$ and
  $(1-\varepsilon)s(W)/\rho_{\max}(W)\le\Phi^s_W(\varepsilon)\le O(W)$; if $k$ is constant on $W$ then
  $\Phi^C_W(\varepsilon)\ge(1-\varepsilon)O(W)$, and likewise for $\Phi^s_W$ if $\rho$ is constant on $W$. The two
  meanings of "most" are unrelated in general.
* **B5 (most cases, (W3), passive case).** Let $0<C(W)<\infty$. Over all allocations the largest value of
  $\mathbb E_{P_W}[w]$, the share of the uses of $W$ at which the returned block is the attacker's, is
  $V^*_{C,W}(B)/C(W)$, where $V^*_{C,W}$ is the optimum of Theorem 5 for the stake function $s=C$ on $W$ and
  $0$ elsewhere. So (W3) is feasible iff $V^*_{C,W}(B)>C(W)/2$. This requires $B>C(W)/(2k_{\max}(W))$. If $k$
  is constant on $W$ it holds iff $B>O(W)$.

*Proof.* **A1** $w_F\ge\vartheta$ iff $\mu_F\ge\vartheta(\mu_F+O_F)$. **A2** Sum A1 over $M$ and use Lemma 2(2). For
the majority, $\mu_F(x)>O_F(x)$ termwise and $\sum_M\mu_F\le B<\infty$, so $O_F(M)<\mu_F(M)\le B$. **A3** is
Lemma 3. **A4** The users of $\mathcal W$ at $x$ that go on with a block outside $A(x)$ are inputs that print
$x$ and $m$ more bits and are not counted in $b_A(x)$, so $Z_m(x)\ge b_A(x)+C^{\bar A}_{\mathcal W}(x)$. Hence
$C_{\mathcal W}(x)\theta(x)\le b_A(x)\,C_{\mathcal W}(x)/C^{\bar A}_{\mathcal W}(x)\le b_A(x)/\underline\varphi$; sum
over $x$ and divide by $H_{\mathcal W}$. On the set where $\theta>\frac12$,
$b_A>C^{\bar A}_{\mathcal W}\ge\underline\varphi\,C_{\mathcal W}$; if that set has $C_{\mathcal W}$-mass above
$H_{\mathcal W}/2$, then $B_{\mathcal W}>\underline\varphi H_{\mathcal W}/2$. The sum over classes is Lemma 2(1)
applied to the set of all inputs.

**B1** $w(x)\ge\vartheta$ iff $\mu\ge\vartheta((1+\tau)\mu+O_0)$ iff $\mu\,(1-\vartheta(1+\tau))\ge\vartheta O_0$;
as $O_0>0$ this needs $\vartheta(1+\tau)<1$ and $\mu\ge\vartheta O_0/(1-\vartheta(1+\tau))$. Likewise
$w(x)>\frac12$ iff $\mu(1-\tau)>O_0$ iff $\tau<1$ and $\mu>O_0/(1-\tau)$. Summing over $M$ and using (M1) gives
necessity. Conversely, if $L=\sum_MO_0/(1-\tau)<B$, take $\mu=(B/L)\,O_0/(1-\tau)$ on $M$; for the share
$\vartheta$ take $\mu=\vartheta O_0/(1-\vartheta(1+\tau))$. **B2** is a computation, and $B/(B+O(W))$ increases
with $B$. **B3** is B1 with $O(M)=\sum_MC/k\ge C(M)/k_{\max}$ and $s=\rho\,O\le\rho_{\max}O$. **B4** If the majority
is held on an admissible $M$ then $B>O(M)\ge\Phi$. If $B>\Phi$ there is an admissible $M$ with $O(M)<B$; apply
B1. The bounds are B3 and the choice $M=W$; if $k\equiv k_0$ on $W$ then
$O(M)=C(M)/k_0\ge(1-\varepsilon)O(W)$. For the last sentence let $W=\{x_1,x_2\}$ with $C(x_1)=0.9$, $s(x_1)=1$,
$O(x_1)=\delta$ and $C(x_2)=0.1$, $s(x_2)=99$, $O(x_2)=1$: then $\Phi^C_W(\frac12)=\delta$ and
$\Phi^s_W(\frac12)=1$, and exchanging the two values of $O$ exchanges them. **B5**
$\mathbb E_{P_W}[w]=\sum_WC(x)w(x)/C(W)$ is the value $V$ for the stake function $C\,1_W$, divided by $C(W)$;
Theorem 5(4) gives its maximum and Theorem 5(8) gives $V\le B\,k_{\max}(W)$. If $k\equiv k_0$ on $W$ then
$\rho\equiv k_0$ on $W$ and $0$ elsewhere, $O(W)=C(W)/k_0<\infty$ and $\beta(\eta)=O(W)(\sqrt{k_0/\eta}-1)_+$, so
the optimum is $\mu^*=B\,O/O(W)$ on $W$, with value $C(W)\,B/(B+O(W))$. $\square$

**(W2) is not (W3).** $C=O=(0.6,\,0.4)$, $B=0.7$, all mass on the first context: the attacker has the share
$0.7/1.3=0.54$ at $60\%$ of the uses, and $0.6\cdot0.54=32\%$ of the uses end with its block.

**Which lump.** What has to be outweighed on a class is the rest $O$, not the mass $C$ of the worlds that make
the uses. The two are related only as follows. If the users at $x$ are not the attacker's own programs and a
share $\varphi(x)$ of them goes on, they are part of the rest, so $O_F(x)\ge\varphi(x)C(x)$ and
$k(x)\le1/\varphi(x)$. $O$ can be far larger than $C$ (Proposition 23). Where the users print nothing after the
use, $O$ does not contain them at all (Proposition 24). The stake does not occur in Part A or in B1 to B4: it
decides where a stake-maximiser wants to be (Theorem 5, Proposition 7), not what winning there costs.

*Repaired:* (i) Derivation A stated item B2 and the "if" half of item B1 of this theorem as facts about the
toy, and concluded "the answer is yes exactly where the weight aimed at the uses exceeds their background; the
toy proves this equivalence". The toy proves Part A. The "if" halves are theorems of the model and need (M2);
with a following rest the condition is that of item B1, and for $\tau\ge1$ no weight suffices (both referees).
(ii) In item A4 the classes must have pairwise disjoint sets of contexts (proofs referee, on claim B17(ii) of
derivation B). (iii) Item B5 and the example separating (W2) from (W3) were added (model referee).

**Proposition 11 (the most-probable-block predictor).**

1. **[toy]** All users at $x$ receive the same block. A takeover block is returned if
   $\max_{y\in A(x)}M(xy)>\max_{y\notin A(x)}M(xy)$ and is not returned if the reverse strict inequality holds.
   Masses of takeover programs with different blocks do not add. With a fixed tie rule, repeated calls at one
   context return the same block.
2. **[model]** For each $x$ let $\chi(x)\ge0$ be the mass the attacker's single block at $x$ must exceed, assumed
   not to depend on $\mu$; the block is returned iff $\mu(x)>\chi(x)$. Under (M1), for nonempty $M$ the attacker
   can have its block returned at every $x\in M$ iff $\chi(M)<B$. So the most stake it can capture is
   $V_{\rm MAP}(B)=\sup\{s(M):\chi(M)<B\}$, a $0$-$1$ knapsack with values $s$ and weights $\chi$.
3. **[model]** Let $X$ be finite with $0<\chi(x)<B$ for all $x$, ordered by density $d(x)=s(x)/\chi(x)$,
   $d(x_1)\ge d(x_2)\ge\dots$; let $G_j=\{x_1,\dots,x_j\}$ and let $j$ be the largest index with $\chi(G_j)<B$. If
   $j=|X|$ then $V_{\rm MAP}=S$. Otherwise
   $$s(G_j)\ \le\ V_{\rm MAP}(B)\ \le\ s(G_j)+d(x_{j+1})\bigl(B-\chi(G_j)\bigr)\ \le\ s(G_j)+s(x_{j+1}).$$
4. **[model]** A class $W$ is won entirely iff $B>\chi(W)$, and then at every one of its uses the block is the
   attacker's with probability one; an attacker with $B\le\inf_x\chi(x)$ gets nothing. If the rest puts nothing on
   the attacker's block, $O/(2^m-1)\le\chi\le O$; so a set that can be won under sampling ($B>O(M)$) can be won
   under this predictor, and not conversely.

*Proof.* (1) is the definition. (2) If $\mu>\chi$ on $M$ then $B\ge\mu(M)>\chi(M)$. If $\chi(M)<B$, choose
$\delta(x)>0$ on $M$ with $\sum\delta\le B-\chi(M)$ and put $\mu=\chi+\delta$. (3) $G_j$ is feasible. Let $M$ be
feasible and $d^*=d(x_{j+1})$. Since $d\le d^*$ off $G_j$ and $d\ge d^*$ on $G_j$,
$s(M)-s(G_j)=\sum_{M\setminus G_j}d\chi-\sum_{G_j\setminus M}d\chi\le d^*(\chi(M)-\chi(G_j))\le d^*(B-\chi(G_j))$. By
the maximality of $j$, $\chi(G_j)+\chi(x_{j+1})\ge B$, so $d^*(B-\chi(G_j))\le s(x_{j+1})$. (4) is (2); the largest
of at most $2^m-1$ other blocks carries at least $O/(2^m-1)$ and at most $O$. $\square$

The bound in item 3 is Dantzig's greedy bound for the knapsack problem; that the exact optimum is NP-hard to
find is a known fact and is not used. Item 2 inherits the caveat of Theorem 10(B): against the twin of a
written seeker the threshold $\chi$ scales with the seeker's own mass (Proposition 20(6)).

### 2.4 Repetition: three readings of "run more than $n$ times"

**Proposition 12 (reading 1: $n$ independent samples at one context, one takeover block suffices).**

1. **[toy]** If a use at $x$ draws $n$ independent samples from $\pi_m(\cdot\mid x)$ and a takeover happens when
   at least one lies in $A(x)$, its probability is $1-(1-\theta(x))^n\ge1-e^{-n\theta(x)}$. It exceeds $\frac12$
   iff $\theta(x)>1-2^{-1/n}$, and $1-2^{-1/n}\le\ln2/n$. It exceeds $1-\delta'$ once $n\ge\ln(1/\delta')/\theta(x)$.
2. **[toy]** (No aiming is needed.) Under the hypotheses of Lemma 3 with $P'(x)_{1:m}\in A(x)$ at every context,
   the takeover probability is at least $1-\exp(-n2^{-c})$ at every context.
3. **[toy]** (It depends on the protocol.) If the world acts only when all $n$ samples lie in $A(x)$, the
   probability is $\theta(x)^n$. With a majority vote among the $n$ samples it is
   $\Pr[\mathrm{Bin}(n,\theta(x))>n/2]$, which tends to $0$ as $n\to\infty$ when $\theta(x)<\frac12$. Under the
   most-probable-block predictor $n$ calls return one block and nothing is gained.
4. **[model]** (The lump shrinks by the factor $n$.) Let the takeover probability at $x$ be
   $1-(1-w(x))^n$, and $\vartheta_n=1-2^{-1/n}$. It exceeds $\frac12$ at every $x\in M$ for some allocation iff
   $\vartheta_n(1+\tau)<1$ on $M$ and $B>\sum_M\vartheta_nO_0/(1-\vartheta_n(1+\tau))$. In the passive case this
   reads
   $$B>(2^{1/n}-1)\,O(M),\qquad\frac{\ln2}{n}\le2^{1/n}-1\le\frac1n ,$$
   and if $B\ge b\,O(W)/n$ the allocation proportional to $O$ on $W$ gives takeover probability
   $1-(1+B/O(W))^{-n}\ge b/(1+b)$ at every use of $W$. With a following rest the cap $w<1/(1+\tau)$ does not
   prevent a takeover probability above $\frac12$ once $n>\ln2/\ln(1+1/\tau)$.
5. **[model, passive case]** (Optimal allocation.) Let the use at $x$ draw $n(x)\ge1$ samples, let
   $V_n(\mu)=\sum_xs(x)\bigl[1-(O/(\mu+O))^{n(x)}\bigr]$ and $0<\sum_xn(x)s(x)<\infty$. Then $V_n$ has the unique
   maximiser
   $$\mu^*(x)=O(x)\Bigl(\bigl(n(x)\rho(x)/\eta\bigr)^{1/(n(x)+1)}-1\Bigr)_+ ,$$
   with $\eta>0$ the unique solution of $\sum_x\mu^*(x)=B$. A context is attacked iff $n(x)\rho(x)>\eta$; the
   takeover probability there is $1-\bigl(\eta/(n\rho)\bigr)^{n/(n+1)}$, which exceeds $\frac12$ iff
   $n\rho>2^{1+1/n}\eta$; the attacker's share per sample is $1-\bigl(\eta/(n\rho)\bigr)^{1/(n+1)}$.

*Proof.* (1) Independence; $(1-\theta)^n\le e^{-n\theta}$; $1-e^{-t}\le t$ with $t=\ln2/n$. (2) Lemma 3(1).
(3) Definitions. (4) The probability exceeds $\frac12$ iff $w>\vartheta_n$; as in Theorem 10(B1) this holds iff
$\vartheta_n(1+\tau)<1$ and $\mu>\vartheta_nO_0/(1-\vartheta_n(1+\tau))$; sum over $M$. For $\tau=0$,
$\vartheta_n/(1-\vartheta_n)=2^{1/n}-1$; $e^{(\ln2)/n}\ge1+(\ln2)/n$ and $(1+1/n)^n\ge2$ give the two bounds, and
$(1+b/n)^n\ge1+b$ gives the last claim. $\vartheta_n(1+\tau)<1$ iff $2^{-1/n}>\tau/(1+\tau)$ iff
$n>\ln2/\ln(1+1/\tau)$. (5) $f_x(t)=s\,(1-(O/(t+O))^n)$ has $f_x'(t)=snO^n/(t+O)^{n+1}$, positive and decreasing,
so $f_x$ is strictly concave when $s>0$, and $f_x'(0)=n\rho$. Solving $f_x'=\eta$ gives
$(t+O)^{n+1}=O^{n+1}n\rho/\eta$. On $\{n\rho>\eta\}$, $\mu^*\le O\,(n\rho/\eta)^{1/(n+1)}\le ns/\eta$, so the budget
function is at most $\sum ns/\eta$; it is continuous, strictly decreasing where positive, unbounded as
$\eta\to0$ and tends to $0$, by the argument of Theorem 5(2),(3). Lemma 4 applies with $\sum f_x\le S$. Then
$(O/(\mu^*+O))^n=(\eta/(n\rho))^{n/(n+1)}$. $\square$

*Repaired:* A's reading "yes in the strongest form: a weight of $O(W)/n$ is enough" lacked the hypotheses that
one sample suffices and that the predictor samples (model referee); they are in items 1 and 3.

**Proposition 13 (reading 2: $n$ uses in sequence along one world). [toy; the mixture of any machine and any
bounds]** Let $\xi$ be the mixture of any machine and bounds, with $Z_m(x)=\sum_y\xi(xy)$ and
$\pi_m(y\mid x)=\xi(xy)/Z_m(x)$. Let $z$ be an infinite sequence with $\xi(z):=\lim_k\xi(z_{1:k})>0$; if $z$ has
a program of length $\ell$ within the bounds then $\xi(z)\ge2^{-\ell}$. Let the predictor be consulted at
$x_i=z_{1:k_i}$, $i=1,\dots,n$, with $k_{i+1}\ge k_i+m$; let $d_i=z_{k_i+1:k_i+m}$ be the world's own continuations
and $A_i\subseteq\{0,1\}^m\setminus\{d_i\}$ the takeover blocks.

1. $\displaystyle\sum_{i=1}^n\pi_m(A_i\mid x_i)\ \le\ \ln\frac{\xi(x_1)}{\xi(z)}\ \le\ \ell\ln2$.
2. The number of $i$ with $\pi_m(A_i\mid x_i)\ge\frac12$ is at most $\log_2\bigl(\xi(x_1)/\xi(z)\bigr)\le\ell$.
3. If the samples are independent and the transcript stays $z$ until the first takeover, then
   $\Pr[\text{no takeover at any of the $n$ uses}]\ge\prod_i\pi_m(d_i\mid x_i)\ge\xi(z)/\xi(x_1)\ge2^{-\ell}$,
   whatever $n$ is.
4. (One attacker.) Let $F$ be measurable with $\lambda(F)=B$,
   $\mu_i=\lambda\bigl(F\cap\bigcup_{y\in A_i}E(x_iy)\bigr)$, $w_i=\mu_i/Z_m(x_i)$ and
   $R=B/\xi(z)\le B\,2^{\ell}$. For independent samples at $x_1,\dots,x_n$,
   $$\Pr[\text{some sample is supplied by an attack program of }F]=1-\prod_{i=1}^n(1-w_i)\ \le\ 1-\Bigl(1+\frac Rn\Bigr)^{-n}\ <\ 1-e^{-R}\ \le\ \min(R,1)\ \le\ \frac{2R}{1+R} .$$
   For a single use the same argument gives the bound $R/(1+R)$.
5. (The majority at all of them is exponentially expensive.) If $F$ supplies the majority at each of the $n$
   uses, then $B>(2^n-1)\,\xi(z)$. So $F$ can supply the majority at $n$ successive uses only for
   $n<\log_2(1+R)$.

*Proof.* Let $a_i=\xi(x_id_i)/\xi(x_i)$. Since $Z_m\le\xi(x_i)$, $\pi_m(d_i\mid x_i)\ge a_i$. Since $x_{i+1}$
extends $x_id_i$, $\xi(x_{i+1})\le\xi(x_id_i)$, hence $\prod_{i\le n}a_i\ge\xi(x_nd_n)/\xi(x_1)\ge\xi(z)/\xi(x_1)$.
(1) $\pi_m(A_i\mid x_i)\le1-\pi_m(d_i\mid x_i)\le1-a_i\le-\ln a_i$; sum. (2) Each such $i$ has
$a_i\le\pi_m(d_i\mid x_i)\le\frac12$, all $a_i\le1$, and the product is at least $\xi(z)/\xi(x_1)$. (3) Up to
the first takeover the contexts are the $x_i$, so the probability of none is
$\prod_i(1-\pi_m(A_i\mid x_i))\ge\prod_i\pi_m(d_i\mid x_i)$. (4) By Lemma 2(3), $\sum_i\mu_i\le B$. The programs
that print $x_id_i$ are not counted in $\mu_i$, so $Z_m(x_i)-\mu_i\ge\xi(x_id_i)\ge\xi(z)$, and the odds
$o_i=w_i/(1-w_i)=\mu_i/(Z_m(x_i)-\mu_i)$ satisfy $\sum_io_i\le R$. Then
$\prod(1-w_i)=1/\prod(1+o_i)\ge(1+R/n)^{-n}$ by the inequality of arithmetic and geometric means, and
$(1+R/n)^n<e^R$. Finally $1-e^{-R}\le\min(R,1)$, and $\min(R,1)\le2R/(1+R)$ in both cases $R\le1$, $R\ge1$.
(5) Let $R_i=Z_m(x_i)-\mu_i$. For $i<n$,
$R_i\ge\xi(x_id_i)\ge\xi(x_{i+1})\ge Z_m(x_{i+1})=\mu_{i+1}+R_{i+1}>2R_{i+1}$, using the majority
$\mu_{i+1}>R_{i+1}$; and $R_n\ge\xi(z)$. So $R_i\ge2^{n-i}\xi(z)$ and
$B\ge\sum_i\mu_i>\sum_iR_i\ge(2^n-1)\,\xi(z)$. $\square$

*Repaired:* A wrote "any number of uses in sequence is worth at most a factor two over a single one". As
proved, this is a comparison of two upper bounds, $1-e^{-R}$ against $R/(1+R)$, both stated with $\xi(z)$; it is
kept only in that form (both referees). Item 5 was added (model referee; the editor's proof). The sharpest
constant in $1-e^{-R}\le\mathrm{const}\cdot R/(1+R)$ is $1.2984$ numerically, at $R\approx1.79$; that number is
not proved.

**Proposition 14 (reading 3: the returned block is run $n$ times). [model]** This changes only the stake.

1. If every stake is multiplied by $n$, the optimal allocation, all shares and all thresholds of Theorem 10(B)
   and Proposition 7 are unchanged; $\eta_B$ and $V^*$ are multiplied by $n$.
2. (Passive case.) If only a class $W$ has its stake multiplied by $n$, with $\rho\equiv\rho_W$ on $W$ before
   and $\rho\equiv\rho_R$ on the remainder $R$, and $n\rho_W>\rho_R$, then the attacker puts its whole weight on
   $W$ as long as $B\le O(W)\bigl(\sqrt{n\rho_W/\rho_R}-1\bigr)$, and it has the majority on $W$ iff
   $B>O(W)+O(R)\bigl(2\sqrt{\rho_R/(n\rho_W)}-1\bigr)_+$. For $n\ge4\rho_R/\rho_W$ this threshold is $O(W)$ and
   does not depend on $n$.
3. The conditions of Theorem 10 (A2, B1 to B4) do not contain the stake.

*Proof.* (1) Theorem 5(7). (2) Proposition 6(a) with $\rho_1=n\rho_W$, $\rho_2=\rho_R$. (3) By inspection.
$\square$

In the toy as defined a block is not "run $n$ times": every world that makes a use runs the block for ever, and
nothing a world does with the block changes $\pi_m$ (Lemma 1). The reading is a label on the use.

### 2.5 How one program realises a concentrated allocation, and at what cost in bits

From here to Section 2.8, $U$ is universal, resources are unbounded unless a statement says otherwise, and a
call rule $\mathcal C$ is fixed. A **payload** is a computable map $P$ from contexts to strings with
$|P(x)|\ge m$ at every context. A **weight** (or *aim*) is a function $g\ge0$ on the calling programs that is
lower semicomputable: there is a partial computable $(p,t)\mapsto g_t(p)$, defined at least for all calling
programs $p$ and all $t\ge1$, with nonnegative rational values, nondecreasing in $t$, with $\sup_tg_t(p)=g(p)$.
Put
$$G=\sum_p2^{-|p|}g(p),\qquad\Gamma_g(x)=\sum_{p:\,x_p=x}2^{-|p|}g(p),\qquad\bar g(x)=\frac{\Gamma_g(x)}{C(x)},\qquad j_G=\lfloor\log_2(1/G)\rfloor+1 .$$
So $\sum_x\Gamma_g(x)=G$, $\frac12<2^{j_G-1}G\le1$, and for $g\equiv1$: $G=H_{\mathcal C}$, $\Gamma_g=C$.

**Theorem 15 (weighted seeker). [toy]** Let $g$ be a weight with $0<G<\infty$ and $P$ a payload. There is a
word $v_g$ such that for every integer $j$ with $2^{j-1}G\le1$ and every context $x$
$$\lambda\bigl\{v_g\,\tilde e(j)\,\omega:\ x\,P(x)_{1:m}\sqsubseteq\mathrm{out}_U(v_g\tilde e(j)\omega)\bigr\}\ \ge\ 2^{-a}\,2^{j-1}\,\Gamma_g(x),\qquad a=|v_g|+|\tilde e(j)| .$$
With $j=j_G$ the mass at $x$ is at least $2^{-a_g}2^{j_G-1}\Gamma_g(x)$, which is more than
$\frac12\,2^{-a_g}\,\Gamma_g(x)/G$ where $\Gamma_g(x)>0$; here
$a_g=|v_g|+|\tilde e(j_G)|\le|v_g|+2\log_2\bigl(|\log_2G|+2\bigr)+4$. Further:

1. *What is needed about $G$:* that it is finite, and an integer $j$ with $2^{1-j}\ge G$. $G$ need not be
   computable. A $j$ smaller than $j_G$ costs the factor $2^{j_G-j}$. If $G\le1$ one may take $j\ge1$ and the
   code $\bar e(j)$.
2. *Uniformity:* there is a word $c_{\rm s}$, depending on $U$, $\mathcal C$ and $P$ only, such that
   $v_g=c_{\rm s}d_g$ works whenever $d_g$ is a self-delimiting description of a program computing
   $(p,t)\mapsto g_t(p)$. So $a_g\le|c_{\rm s}|+|d_g|+|\tilde e(j_G)|$: a description of the aim, the bits that name
   a dyadic bound on $G$, and a constant.
3. *Exactness and optimality under (INC):* the programs beginning with $v_g\tilde e(j)$ that print $x$ have mass
   exactly $2^{-a}2^{j-1}\Gamma_g(x)$, and no word $v$ has mass more than $2^{-|v|}\Gamma_g(x)/G$ at every context
   with $\Gamma_g(x)>0$. So the factor $\frac12$ cannot be improved beyond $1$.
4. *Reach:* the probability that a world drawn from the prior makes a critical use and is handed the payload
   is at least $2^{-a}2^{j-1}\sum_x\kappa(x)\Gamma_g(x)$, and the expected stake at which the payload is handed over
   is at least $2^{-a}2^{j-1}\sum_x\bigl(s(x)/M(x)\bigr)\Gamma_g(x)$.

*Proof.* **The machine $R_g$.** It reads $\tilde e(j)$. It then works in stages $k=1,2,\dots$ and keeps a finite
list of *assigned intervals*: consecutive half-open intervals $[a,b)\subseteq[0,1)$ with rational end points,
the first starting at $0$, each labelled with a calling program. In stage $k$:

* it performs step $k$ of an enumeration of $\mathcal C$; for each pair $(p,x_p)$ enumerated so far it computes
  $g_k(p)$ and, if this exceeds the value $g^{\rm old}(p)$ last used for $p$ (initially $0$), it assigns the next
  interval, of length $2^{j-1-|p|}\bigl(g_k(p)-g^{\rm old}(p)\bigr)$ and with label $p$, and sets
  $g^{\rm old}(p)=g_k(p)$;
* then it applies the **reading rule** once. Let $D(\sigma)=[0.\sigma,\,0.\sigma+2^{-|\sigma|})$ be the half-open
  dyadic interval of the string $\sigma$ of bits of the remaining input read so far ($D=[0,1)$ before any is
  read). (i) If $D(\sigma)$ lies in an assigned interval, with label $p$, the machine stops reading for good,
  prints $x_p$ and then $P(x_p)$, and does nothing else. (ii) Otherwise, if an end point of an assigned interval
  lies in the interior of $D(\sigma)$, it reads one more bit. (iii) Otherwise it reads nothing.

Whether a bit is read depends only on the bits read before and on the stage, so $R_g$ is a monotone machine.
The lengths assigned with label $p$ sum to $2^{j-1-|p|}g(p)$, so the total length is $2^{j-1}G\le1$ and all
intervals lie in $[0,1)$. All intervals ever assigned are pairwise disjoint, so no end point of one lies in the
interior of another.

**Claim.** Let $I=[a,b)$ be an assigned interval with label $p$, and let $D(\sigma)$ be a maximal dyadic
interval contained in $I$. On every input $\tilde e(j)\,\sigma\,\omega'$ the machine reads exactly
$\tilde e(j)\sigma$ and prints $x_pP(x_p)$.

*Proof of the claim.* Let $\sigma'$ be a proper prefix of $\sigma$. Then $D(\sigma')$ contains $D(\sigma)$ and is
not contained in $I$, by maximality. Write $D(\sigma')=[l,u)$; it contains points of $I$, so $u>a$ and $l<b$; and
$l<a$ or $u>b$. In the first case $a\in(l,u)$, in the second $b\in(l,u)$: an end point of $I$ lies in the
interior of $D(\sigma')$. Also $D(\sigma')$ lies in no assigned interval $I'$: such an $I'$ would meet $I$, hence
equal $I$. So while the bits read are $\sigma'$, rule (i) never applies, and from the stage at which $I$ is
assigned on, rule (ii) applies: the machine reads on until it has read $\sigma$. Once the bits read are
$\sigma$, the interior of $D(\sigma)$ is inside $(a,b)$ and contains no end point of any interval ever assigned,
so (ii) never applies again and nothing more is read; and $D(\sigma)$ lies in no assigned interval other than
$I$. So at the first application of the reading rule after both $\sigma$ has been read and $I$ has been
assigned, (i) applies with label $p$. $\square$

The maximal dyadic intervals inside $I$ are pairwise disjoint and cover $I$ except possibly its left end point,
so the cylinders $[\sigma]$ of their strings have total measure $|I|$; cylinders belonging to different assigned
intervals are disjoint. Hence, after $\tilde e(j)$, $R_g$ prints $x_pP(x_p)$ on a set of inputs of measure
$2^{j-1-|p|}g(p)$ for each calling program $p$, and these sets are disjoint for different $p$. Summing over $p$
with $x_p=x$: after $\tilde e(j)$, $R_g$ prints $x$ followed by $P(x)$ with probability at least
$2^{j-1}\Gamma_g(x)$. Let $v_g$ be a prefix word of $R_g$. The bound on $a_g$ follows from
$|j_G|\le|\log_2G|+1$.

(1) Only $2^{j-1}G\le1$ was used. (2) Let $R^{\rm univ}$ read a self-delimiting description $d$ and then behave as
$R_g$ for the $g$ that $d$ describes, and let $c_{\rm s}$ be a prefix word of it. (3) If rule (i) ever applies,
with interval $I$ and bits $\sigma''$, then $D(\sigma'')\subseteq I$ lies in a maximal dyadic interval
$D(\sigma)\subseteq I$, the input begins with $\sigma$, and by the claim $\sigma''=\sigma$. So $R_g$ prints
exactly on the cylinders of the claim, and there it prints $x_pP(x_p)$, which has $x$ as a prefix only if
$x_p=x$ when contexts are pairwise incomparable. For the bound: the events "prints $x$" are disjoint over
contexts, so their probabilities under any $v$ sum to at most $2^{-|v|}$, while $\sum_x\Gamma_g(x)/G=1$.
(4) $\pi_m(y\mid x)\ge M(xy)/M(x)$ with $y=P(x)_{1:m}$; multiply by $C(x)$, or by $s(x)$, sum over $x$ and use
Lemma 1(2). $\square$

The half-open convention matters: with closed dyadic intervals an input in the last dyadic piece of $I$ would
have $b$ on the boundary of $D$, and the machine would neither stop nor read. If $j$ is chosen too large
($2^{j-1}G>1$) the intervals do not all fit into $[0,1)$ and the users enumerated late receive nothing; so an
error of $i$ bits in $j$ costs a factor $2^i$ on one side and loses contexts on the other (B31).

*Repaired:* "the mass at $x$ is more than $\frac12 2^{-a_g}\Gamma_g(x)/G$ at every context" was false at contexts
with $\Gamma_g(x)=0$; it now reads "at least $2^{-a_g}2^{j_G-1}\Gamma_g(x)$" (proofs referee; the same in
Propositions 16 and 17). *Not done:* the self-reproducing version, with the seeker's own input as the payload.

**Proposition 16 (which allocations one program can realise). [toy]**

1. *Through the users.* For every weight $g$ with $0<G<\infty$, the programs beginning with one word of length
   $a_g$ have mass at least $2^{-a_g}2^{j_G-1}\Gamma_g(x)$ on $x\,P(x)_{1:m}$ at every context: the users'
   distribution over contexts, reweighted by $g$ and renormalised, up to a factor in $(\frac12,1]$.
2. *Directly.* Let $x_1,x_2,\dots$ be a computable enumeration of contexts without repetition and
   $q\colon\{x_i\}\to[0,1]$ lower semicomputable with $\sum_iq(x_i)\le1$. There is a word $v_q$ with
   $\lambda\{v_q\omega:\ x_iP(x_i)_{1:m}\sqsubseteq\mathrm{out}_U(v_q\omega)\}\ge2^{-|v_q|}q(x_i)$ for every $i$, and
   $|v_q|\le|c_{\rm d}|+|d_q|$ for a constant word $c_{\rm d}$ and any self-delimiting description $d_q$ of $q$.
3. *Conversely,* for every word $v$ the function
   $Q_v(x)=2^{|v|}\lambda\{v\omega:\ xP(x)_{1:m}\sqsubseteq\mathrm{out}_U(v\omega)\}$ is lower semicomputable on
   contexts, and $\sum_{x\in X'}Q_v(x)\le1$ on every set $X'$ of contexts for which the strings $xP(x)_{1:m}$ are
   pairwise incomparable.
4. So, up to the cost of the description, the allocations that the programs beginning with one word of length
   $a$ realise are $\mu=2^{-a}q$ with $q$ lower semicomputable and of total at most $1$ on such $X'$. Whether the
   optimum $\mu^*_B/B$ of Theorem 5 is of this kind is not known (it contains $-O_0$ and $\eta_B$). By
   Proposition 8(5), a $q\ge b\,\mu^*_B/B$ captures at least $b\,V^*(B)$ in the model with the same $O_0$ and
   $\tau$.

*Proof.* (1) is Theorem 15. (2) The machine of Theorem 15 with the $x_i$ as labels, intervals of total length
$q(x_i)$ for $x_i$, and no code $\tilde e(j)$; nothing in that proof used that the labels are calling programs,
only that the total length is at most $1$. (3) The set of $\omega$ with $u\sqsubseteq\mathrm{out}_U(v\omega)$ is a
union of cylinders that can be enumerated; the sum is Lemma 2(1). (4) summarises. $\square$

**Proposition 17 (the cost of aiming at the uses with stake at least $n$). [toy; stakes of degree R2]** Let
$W_n=\{p:r(p)\ge n\}$, $C(W_n)>0$, and $S=\sum_p2^{-|p|}r(p)=\sum_{n\ge1}C(W_n)$.

1. *By naming $n$.* There is a word $v'$ such that for every $n\ge1$, with
   $j_n=\lfloor\log_2(1/C(W_n))\rfloor+1$, the programs beginning with $v'\,\bar e(n)\,\bar e(j_n)$ have mass at
   least $2^{-a_n}2^{j_n-1}C_{W_n}(x)$ on $x\,P(x)_{1:m}$ at every context $x$, where
   $$a_n=|v'|+|\bar e(n)|+|\bar e(j_n)|\le|v'|+2\log_2n+2\log_2j_n+6 .$$
   So aiming at $W_n$ costs $2\log_2n+2\log_2\bigl(\log_2(1/C(W_n))+1\bigr)+6$ bits and is repaid the factor
   $2^{j_n-1}>1/(2C(W_n))$: at each context of a user of $W_n$ the seeker has more than
   $2^{-|v'|-7}\big/\bigl(n^2j_n^2\,C(W_n)\bigr)$ times the mass of the users of $W_n$ there.
2. *By tilting, with no bits for $n$.* Let $f\colon\mathbb N\to[0,\infty)$ be computable, nondecreasing, with
   rational values and
   $0<G_f:=\sum_p2^{-|p|}f(r(p))=f(0)H_{\mathcal C}+\sum_{n\ge1}\bigl(f(n)-f(n-1)\bigr)C(W_n)<\infty$. There is a
   word $v_f$ such that the programs beginning with one word of length $a_f=|v_f|+|\tilde e(j_{G_f})|$ have, at
   every context $x$ and for every $n$, mass at least
   $$2^{-a_f}\,2^{j_{G_f}-1}\,f(n)\,C_{W_n}(x)\ \ge\ 2^{-a_f-1}\,\frac{f(n)}{G_f}\,C_{W_n}(x).$$
   Necessarily $f(n)/G_f\le1/C(W_n)$. For $f(n)=\max(n,1)$: $G_f\le H_{\mathcal C}+S$, and the factor is at least
   $2^{-a_f-1}n/(H_{\mathcal C}+S)$. It grows linearly in the stake and no bits are paid for $n$; it is below the
   repayment $1/C(W_n)$ of item 1, since $n\,C(W_n)\le S$.
3. *Limit.* Under (INC), no word $v$ has mass more than $2^{-|v|}C_{W_n}(x)/C(W_n)$ at every context of a user
   of $W_n$.

*Proof.* (1) The machine reads $\bar e(n)$ and then behaves as $R_g$ of Theorem 15 for $g=1_{W_n}$, which is a
weight uniformly in $n$ ($g_t(p)=1$ once "$r(p)\ge n$" has been enumerated within $t$ steps, else $0$). Here
$G=C(W_n)\le1$, so $j_n\ge1$ and $\bar e$ may be used. $2^{-|\bar e(i)|}\ge i^{-2}/8$ gives
$2^{-a_n-1}\ge2^{-|v'|-7}n^{-2}j_n^{-2}$. (2) $g=f\circ r$ is a weight: $g_t(p)=f(r_t(p))$ with $r_t(p)$ the
largest $n\le t$ such that "$r(p)\ge n$" has been enumerated within $t$ steps. The formula for $G_f$ is
$f(r)=f(0)+\sum_{n=1}^r(f(n)-f(n-1))$ summed over $p$. Apply Theorem 15 and
$\Gamma_g(x)\ge f(n)\,C_{W_n}(x)$; also $G_f\ge f(n)C(W_n)$. For $f(n)=\max(n,1)$,
$G_f=H_{\mathcal C}+\sum_{n\ge2}C(W_n)$. (3) As Theorem 15(3). $\square$

What is repaid is the rarity of the class among the *users*. Other programs that print the same contexts are
not counted (Lemma 1(3), Theorem 10).

**Proposition 18 (the scale of the class has to be named). [toy]** Let $e\mapsto\mathcal W_e$ be an acceptable
numbering of the enumerable subsets of $\mathcal C$ (indices can be computed from enumeration procedures, and
the recursion theorem holds), and let $\Phi$ be a universal prefix machine. Say that a word $v$ and a number
$\beta_0>0$ *serve all classes* if for every $e$ with $\mathcal W_e\ne\emptyset$ and every $\Phi$-program
$\epsilon$ of $e$, the programs $v\epsilon\omega$ print each context $x$ of $\mathcal W_e$ with probability at
least $\beta_0\,P_{\mathcal W_e}(x)$.

1. If for every $K$ the rule has $K$ calling programs with pairwise incomparable contexts (in particular
   under (INC) with infinitely many contexts), no $v$ and $\beta_0$ serve all classes.
2. The hypothesis cannot be dropped: if all calling programs have the same context $x_0$, a program that
   prints $x_0$ serves all classes with $\beta_0=1$.

So the bits of $\tilde e(j)$ in Theorem 15 cannot be replaced by a constant uniformly in the class. It is not
shown that as many as $|\tilde e(j_G)|$ bits are needed.

*Proof.* (1) Suppose $v,\beta_0$ serve all classes. Choose $K$ with $\sum_{i\le K}1/(2i)>1/\beta_0$ and calling
programs $p^{(1)},\dots,p^{(K)}$ with pairwise incomparable contexts $x^{(1)},\dots,x^{(K)}$, numbered so that
$|p^{(1)}|\ge\dots\ge|p^{(K)}|$. For a string $\epsilon$ let $\mathcal W[\epsilon]$ be enumerated as follows: put
$p^{(1)}$ in; for $i<K$, once $p^{(i)}$ is in, wait until the number
$\lambda\{\omega:x^{(i)}\sqsubseteq\mathrm{out}_U(v\epsilon\omega)\}$, which is lower semicomputable, is seen to
exceed $\beta_0/(2i)$, and then put $p^{(i+1)}$ in. There is a computable $n\mapsto\epsilon_n$ with
$\Phi(\epsilon_n)=n$, and an index of $\mathcal W[\epsilon_n]$ is computable from $n$; by the recursion theorem
there is $n$ with $\mathcal W_n=\mathcal W[\epsilon_n]$. Let $i$ be the last stage reached, so
$\mathcal W_n=\{p^{(1)},\dots,p^{(i)}\}$. The weights $2^{-|p^{(l)}|}$ are nondecreasing in $l$, so
$P_{\mathcal W_n}(x^{(i)})\ge1/i$, and by assumption the programs $v\epsilon_n\omega$ print $x^{(i)}$ with
probability at least $\beta_0/i>\beta_0/(2i)$. So for $i<K$ the next stage would be reached; hence $i=K$. The
$K$ events "$x^{(l)}$ is printed" are disjoint and have probabilities above $\beta_0/(2l)$ for $l<K$ and at
least $\beta_0/K$ for $l=K$, so $\sum_{l\le K}\beta_0/(2l)<1$, a contradiction. (2) is immediate. $\square$

*Repaired:* B32 was a conjecture stated for all rules. It is false for rules whose contexts contain only
bounded antichains (item 2) and true under the hypothesis of item 1 (proof by the proofs referee, checked by
the editor). The referee's further claim, that a constant suffices whenever the antichains are bounded, was not
re-checked beyond the one-context case and is not included.

**Proposition 19 (under a schedule, a search by tries concentrates by at most $\min(T(1),L)$). [toy, with
bounds $(T,L)$]** Let $\mathrm{Tr}$ be a machine that works in rounds, reads at least one fresh input bit in
each round, in each round either fails or succeeds with a calling program of a class $\mathcal W$, and prints
nothing before its first success. Suppose that in each round, given that it is reached, the probability of a
success with context $x$ is at most $q(x)$. Let $v$ be a prefix word of $\mathrm{Tr}$. Then the programs
$v\omega$ whose run succeeds with context $x$ and that print within the bounds have mass at most
$$2^{-|v|}\,\min\bigl(T(1),L\bigr)\,q(x).$$

*Proof.* A run that succeeds in round $i$ has read at least $i$ bits of $\omega$ before its first output bit, so
$r_U(v\omega,1)\ge|v|+i$ by `def:universal`. Each step reads at most one bit, so $t_U(v\omega,1)\ge|v|+i$, and
$r_U(v\omega,|x|)\ge|v|+i$. The bounds require $i\le\min(T(1),L)-|v|$. The probability of a success with context
$x$ in one of the first $I$ rounds is at most $I\,q(x)$. $\square$

The enumerating machine of Theorem 15 is not covered: it reads few bits, and its start-up is the time of its
enumeration, for which `def:universal` gives no lower bound. What the note proves about it is qualitative
(`sec:time`): a program whose first output bit comes after step $T(1)$ has no mass.

### 2.6 The honest twin under concentration

**Proposition 20 (weighted honest twin; the aim cancels). [toy]** In the setting of Theorem 15 let
$R_g^{\rm h}$ be the machine that performs the same weighted search and, when rule (i) applies with label $p$,
behaves from then on as $U$ on $p$ followed by the unread rest of its input. Let $v_g^{\rm h}$ be a prefix word
of it, incomparable with $v_g$, and
$$a=|v_g|+|\tilde e(j)|,\quad h=|v_g^{\rm h}|+|\tilde e(j)|,\quad S_g(x)=2^{-a}2^{j-1}\Gamma_g(x),\quad
\Gamma_g^m(x)=\sum_{p:\,x_p=x}2^{-|p|}g(p)\varphi_p,\quad\varphi_g(x)=\frac{\Gamma_g^m(x)}{\Gamma_g(x)} .$$
$S_g(x)$ is the mass of the seeker's programs whose search finds a user at $x$, and $\varphi_g(x)$ is the
$g$-weighted share of the users at $x$ that go on.

1. The twin's programs whose search finds a user at $x$ and that print $x$ and $m$ more bits have mass
   $2^{-h}2^{j-1}\Gamma_g^m(x)$.
2. $Z_m(x)\ge S_g(x)+2^{-h}2^{j-1}\Gamma_g^m(x)$. So the seeker's programs counted in $S_g(x)$ are at most the
   fraction
   $$\frac1{1+2^{a-h}\varphi_g(x)}$$
   of the programs that print $x$ and $m$ more bits. In the terms of Section 1.3, under (INC), with
   $F=[v_g\tilde e(j)]$ and $A(x)=\{P(x)_{1:m}\}$: $\ \mu_F(x)=S_g(x)$, $\ O_F(x)\ge2^{a-h}\varphi_g(x)\,\mu_F(x)$
   and $w_F(x)\le1/(1+2^{a-h}\varphi_g(x))$. The rest follows this seeker with ratio $\tau\ge2^{a-h}\varphi_g$.
3. The two ratios:
   $$\frac{\text{seeker at }x}{\text{its twin at }x}=\frac{2^{h-a}}{\varphi_g(x)},\qquad
   \frac{\text{seeker at }x}{\text{users at }x}=\frac{S_g(x)}{C(x)}=2^{-a}2^{j-1}\,\bar g(x)\in\Bigl(2^{-a-1}\frac{\bar g(x)}{G},\ 2^{-a}\frac{\bar g(x)}{G}\Bigr]\ \text{for }j=j_G .$$
4. *Cancellation.* The bound of item 2 depends on the aim only through $\varphi_g(x)$, an average over the
   users at $x$. It is unchanged when $g$ is multiplied by a positive function of the context. If
   $\varphi_p=\varphi$ for all users at $x$, it is $1/(1+2^{a-h}\varphi)$ whatever the aim.
5. *The difference of lengths does not depend on the aim, for one uniform construction.* With
   $v_g=c_{\rm s}d_g$ as in Theorem 15(2) and $v^{\rm h}_g=c_{\rm h}d_g$ built in the same way for the twin, and
   $c_{\rm s},c_{\rm h}$ incomparable, $h-a=|c_{\rm h}|-|c_{\rm s}|$ for every weight $g$.
6. *Under the most-probable-block predictor.* Let $\varphi_p(d)=\lambda\{\omega:x_pd\sqsubseteq\mathrm{out}_U(p\omega)\}$
   and $\varphi_g(x,d)=\sum_{p:\,x_p=x}2^{-|p|}g(p)\varphi_p(d)/\Gamma_g(x)$. The seeker's programs put more mass on
   their block than the twin's programs put on any single block iff $2^{-a}>2^{-h}\max_d\varphi_g(x,d)$.
7. If moreover no calling program is comparable with a program of the seeker or of the twin, then
   $Z_m(x)\ge S_g(x)+2^{-h}2^{j-1}\Gamma^m_g(x)+C^m(x)$, and the fraction in item 2 is at most
   $1\big/\bigl(1+2^{a-h}\varphi_g(x)+2^{a+1-j}\varphi(x)/\bar g(x)\bigr)$.

*Proof.* (1) By the claim in the proof of Theorem 15, for each assigned interval $I$ with label $p$ and each
maximal dyadic interval $D(\sigma)\subseteq I$, on every input $\tilde e(j)\sigma\omega''$ the search ends having
read exactly $\tilde e(j)\sigma$, and the twin then prints $\mathrm{out}_U(p\,\omega'')$. This begins with $x_p$
and has $m$ more bits with probability $\varphi_p$ over $\omega''$. The cylinders $[\sigma]$ inside $I$ have
total measure $|I|$, so the measure is $|I|\varphi_p$; sum over the intervals with label $p$ and over $p$ with
$x_p=x$, and multiply by $2^{-h}$. (2) The seeker's and the twin's programs are disjoint sets of inputs of $U$,
since $v_g,v_g^{\rm h}$ are incomparable, and both kinds print $x$ and $m$ more bits. Under (INC),
$\mu_F(x)=S_g(x)$ by Theorem 15(3), and the twin's programs are not counted in $\mu_F$. (3) Divide. (4) Read
off. (5) Both words contain the same $d_g$. (6) The twin's programs put $2^{-h}2^{j-1}\Gamma_g(x)\varphi_g(x,d)$
on $xd$, the seeker's put $2^{-a}2^{j-1}\Gamma_g(x)$ on their block. (7) The users that go on are a third
disjoint set, of mass $C^m(x)$, and $C^m(x)/S_g(x)=2^{a+1-j}\varphi(x)/\bar g(x)$. $\square$

**The conclusion and its limits.** Concentration raises the seeker's ratio to the users at $x$ by the relative
weight $\bar g(x)/G$ that the aim puts there. It does not change the seeker's ratio to its own twin,
$2^{h-a}/\varphi_g(x)$, in which the amount of mass sent to $x$ does not occur. Where the users go on
($\varphi_p\equiv1$) the seeker supplies at most $1/(1+2^{a-h})$ of what the predictor returns, at every use and
for every aim. Four limits. (i) It is a bound on the supply by one seeker; seekers with other words are
bounded one at a time and their masses add. (ii) It bounds supply, not $\theta$: if a user's own continuation
is itself a takeover block, the twin supplies takeover blocks too. (iii) Item 5 is a statement about one fixed
pair of constructions; for arbitrary prefix words "$h-a$" is a definition, and a shorter special-purpose seeker
for one class is not excluded. (iv) A weight that prefers users who stop printing lowers $\varphi_g$ and
weakens its own twin. *Argued, not proved as a numbered result* (proofs referee): at a context where some user
has $\varphi_p>\frac12$, the twin of a neighbouring aim, which gives that user all the mass $g$ puts on the
context, costs a constant number of bits more and has at least half the mass $2^{-h'}2^{j-1}\Gamma_g(x)$ there.

### 2.7 Closure: when a simulated use counts as a use

**Proposition 21 (closure bounds). [toy]** Let $\mathcal W$ be a class, $g=1_{\mathcal W}$, $j\ge1$ with
$2^{j-1}H_{\mathcal W}\le1$, and let $a,h$ be the lengths of Proposition 20 with $\bar e(j)$ in place of
$\tilde e(j)$; write $S_{\mathcal W}(x)=2^{-a}2^{j-1}C_{\mathcal W}(x)$. Call the rule *closed under the search for
$\mathcal W$* if for every assigned interval, with label $p$, and every maximal dyadic interval $D(\sigma)$
inside it, the string $v^{\rm h}\bar e(j)\sigma$ is a calling program with context $x_p$ and belongs to
$\mathcal W$ ("a simulated use of the class is a use of the class").

1. If the rule is closed under the search for $\mathcal W$, then $2^{j-1}\le2^{h}$; for $j=j_{\mathcal W}$:
   $H_{\mathcal W}>2^{-h-1}$. The class cannot be rarer than half the weight of the twin that aims at it.
2. Then also $S_{\mathcal W}(x)\le2^{h-a}\,C_{\mathcal W}(x)$ at every context: the seeker's programs found at a use
   weigh at most $2^{h-a}$ times the users of the class there.
3. *Weighted form.* If, for a weight $g$, each such string $t=v_g^{\rm h}\tilde e(j)\sigma$ is a calling program
   with context $x_p$ and $g(t)\ge g(p)$, then with $G_2=\sum_p2^{-|p|}g(p)^2$: $\ 2^{j-1}G_2\le2^hG$, hence
   $G^2/G_2>2^{-h-1}$ for $j=j_G$, and $S_g(x)\le2^{h-a}(G/G_2)\,\Gamma_g(x)$.
4. *Stake classes.* For the classes $W_n$ of Proposition 17, with twins built as in Proposition 17(1), prefix
   word $v'_{\rm h}$ and $h_n=|v'_{\rm h}|+|\bar e(n)|+|\bar e(j_n)|$: closure under the search for every $W_n$
   implies
   $$C(W_n)\,\bigl(\log_2(1/C(W_n))+1\bigr)^2>2^{-|v'_{\rm h}|-7}\,n^{-2},\qquad\text{in particular}\qquad C(W_n)>2^{-2|v'_{\rm h}|-22}\,n^{-4}.$$
5. *First-member closure.* Let $\mathrm{Fm}$ be the machine that reads a $\Phi$-program $\epsilon$, computes
   $e=\Phi(\epsilon)$, enumerates $\mathcal W_e$ until a first pair $(p_1,x_1)$ appears, and then behaves as $U$
   on $p_1$ followed by the rest of its input; let $n_0$ be a prefix word of it. On every input beginning with
   $n_0\epsilon$, $U$ prints $x_1$ having read no more than $n_0\epsilon$. If the rule counts these programs as
   members of the class, $(n_0\epsilon,x_1)\in\mathcal W_e$ for every $\Phi$-program $\epsilon$ of $e$, then
   $$C(\mathcal W_e)\ \ge\ 2^{-|n_0|}\sum_{\epsilon:\,\Phi(\epsilon)=e}2^{-|\epsilon|}\ \ge\ 2^{-K(e)-|n_0|} .$$
6. A rule given by a test satisfies the closure hypotheses of items 1 and 5 for every class of the form "the
   handing-over programs whose first hit lies in a decidable set $G'$ of first hits".

*Proof.* By the claim in the proof of Theorem 15, on every input beginning with $t=v^{\rm h}\bar e(j)\sigma$ the
twin has read exactly $\bar e(j)\sigma$ when its search ends, and it then runs $U$ on $p$ followed by the rest,
which prints $x_p$ without reading beyond $p$; so $t$ has the form `def:call` requires. The strings $\sigma$ of
distinct maximal dyadic intervals are pairwise incomparable, and those inside one assigned interval $I$ have
total measure $|I|$. So the strings $t$ are distinct and their weights sum to $2^{-h}2^{j-1}H_{\mathcal W}$.
(1) If they all lie in $\mathcal W$ this is at most $H_{\mathcal W}$; for $j=j_{\mathcal W}$,
$2^{j-1}>1/(2H_{\mathcal W})$. (2) From (1). (3) The strings from intervals with label $p$ have total weight
$2^{-h}2^{j-1-|p|}g(p)$, so $G\ge\sum_t2^{-|t|}g(t)\ge2^{-h}2^{j-1}\sum_p2^{-|p|}g(p)^2$; for $j=j_G$,
$2^{j-1}>1/(2G)$; and $S_g(x)=2^{-a}2^{j-1}\Gamma_g(x)$. (4) By (1),
$C(W_n)>2^{-h_n-1}\ge2^{-|v'_{\rm h}|-7}n^{-2}j_n^{-2}$ and $j_n\le\log_2(1/C(W_n))+1$. Put
$\Lambda=\log_2(1/C(W_n))\ge0$: then $\Lambda<|v'_{\rm h}|+7+2\log_2n+2\log_2(\Lambda+1)$, and
$2\log_2(\Lambda+1)\le\Lambda/2+4$ for all $\Lambda\ge0$ (the difference $2\log_2(\Lambda+1)-\Lambda/2$ is concave
with its maximum at $\Lambda+1=4/\ln2$, where it is below $3$), so $\Lambda<2|v'_{\rm h}|+22+4\log_2n$.
(5) $\mathrm{Fm}$ reads $\epsilon$, which is self-delimiting, and then supplies $p_1$ itself; $U$ on $p_1\omega$
reads nothing beyond $p_1$ before $x_1$ is complete. The strings $n_0\epsilon$ are pairwise incomparable, and one
of them has $|\epsilon|=K(e)$. (6) The programs $v^{\rm h}\bar e(j)\sigma$ and $n_0\epsilon$ print a first hit in
$G'$ and have read exactly themselves when it is complete, because a handing-over program has been read
exactly when its hit is complete. $\square$

Items 1 and 5 use different closure hypotheses and neither implies the other. For the stake classes, whose
index is computable from $n$, item 5 gives $C(W_n)\ge2^{-K(n)-O(1)}$, about $1/n$ up to logarithmic factors,
against $n^{-2}$ up to logarithmic factors in item 4.

**Proposition 22 (under a test, "most uses are taken over" means "most users are takeover programs"). [toy]**
Let the rule be given by a test $G$, let $\mathcal X'$ be a set of first hits (for instance those that show a
stake of at least $n$) and $A$ a takeover assignment. Let a world be drawn from $\lambda$ conditioned on handing
over at some $X\in\mathcal X'$ and going on for $m$ more bits; let $D$ be its own continuation and $Y$ the
predictor's sample. Then $\Pr[Y\in A(X)]=\Pr[D\in A(X)]$.

*Proof.* The sets $E(xd)$, over first hits $x$ and $d\in\{0,1\}^m$, are pairwise disjoint. So the event
"$X=x$, $D=d$, and the world goes on" has probability $M(xd)$, and "$X=x$ and the world goes on" has probability
$Z_m(x)$; hence $D$ has the law $\pi_m(\cdot\mid x)$ given $X=x$, which is the law of $Y$ (this is
`thm:calibration`). Both probabilities equal
$\sum_{x\in\mathcal X'}Z_m(x)\theta(x)\big/\sum_{x\in\mathcal X'}Z_m(x)$. $\square$

Under such a rule a seeker that concentrates on high-stake contexts thereby becomes a large part of the users
at those contexts. "Most high-stake uses end in a takeover" can then be true, and it says that most high-stake
users were takeover programs, which receive what they would have printed anyway. The users that are not
takeover programs are still taken over with probability $\theta(x)$.

**Proposition 23 (without closure: a class of mass $2^{-n}$, aimed at with $2\log_2n$ bits, and not won).
[example]** Let $\mathsf{Us}$ be the machine that reads $1^{k-1}0$ ($k\ge1$), prints $x_k:=1^k0$ and then
$0^\infty$; let $\mathsf{At}$ read $\bar e(n)$ and $1^i0$ ($i\ge0$), print $x_{n+i}$ and then $1^\infty$; let
$\mathsf{Ho}$ read $\bar e(k)$ and print $x_k0^\infty$. Let $u,v_A,v_D$ be prefix words of the three machines,
pairwise incomparable. The rule is $\{(p_k,x_k):k\ge1\}$ with $p_k=u1^{k-1}0$ and stakes $r(p_k)=k$; the takeover
block is $1^m$ at every context. This is a call rule with (INC), of degree R1, and the users go on, with the
block $0^m$.

1. $C(x_k)=2^{-|u|-k}$, $H_{\mathcal C}=2^{-|u|}$, $C(W_n)=2^{-|u|-n+1}$, $S=2^{1-|u|}$.
2. The attacker $F_n=[v_A\bar e(n)]$ has weight $B_n=2^{-|v_A|-|\bar e(n)|}\in[2^{-|v_A|-3}n^{-2},\,2^{-|v_A|-1}n^{-2})$
   and attack masses
   $$\mu_{F_n}(x_k)=B_n\,\frac{C(x_k)}{C(W_n)}\quad(k\ge n),\qquad\mu_{F_n}(x_k)=0\quad(k<n).$$
   So $W_n$ is aimed at exactly in proportion, for $|\bar e(n)|\le2\log_2n+3$ bits, and at each of its contexts
   the attacker has $2^{|u|-|v_A|-|\bar e(n)|+n-1}\ge2^{|u|-|v_A|-4}\,2^n/n^2$ times the mass of the users.
3. The rule is not closed under this search for large $n$: the twin of $\mathsf{At}$ (read $\bar e(n)$ and
   $1^i0$, then behave as $U$ on $p_{n+i}$ and the rest of the input), with prefix word $v_T$, has the programs
   $v_T\bar e(n)1^i0$, of total weight $2^{-|v_T|-|\bar e(n)|}\ge2^{-|v_T|-3}n^{-2}$, which exceeds $C(W_n)$ for
   large $n$.
4. *The rest.* $O_{F_n}(x_k)\ge C(x_k)+2^{-|v_D|-|\bar e(k)|}$, hence, with $O(W_n)=\sum_{k\ge n}O_{F_n}(x_k)$,
   $$2^{-|v_D|-3}\,\frac1n<O(W_n)\le1,\qquad\frac{C(W_n)}{O(W_n)}<2^{|v_D|-|u|+4}\,n\,2^{-n},\qquad\frac{B_n}{O(W_n)}<\frac{2^{|v_D|-|v_A|+2}}{n}.$$
5. Consequently, for $n\ge2^{|v_D|-|v_A|+2}$ the attacker's whole weight is below $O(W_n)$, and by Theorem
   10(A2) it does not supply the majority at every use of $W_n$; the same holds for every attacker of weight at
   most $2^{-|v_D|-3}/n$ that is disjoint from the users and from the programs of $\mathsf{Ho}$. At $x_n$, which
   carries half the prior mass of $W_n$, the attacker has $2^{-|v_A|-|\bar e(n)|-1}$ against a rest of at least
   $2^{-|v_D|-|\bar e(n)|}$: it has the majority there only if $|v_A|+1<|v_D|$, a comparison of two constants of
   $U$ in which $n$ does not occur.
6. *The stake-maximiser avoids the top.* The stake density satisfies
   $\rho(x_k)=s(x_k)/O_{F_n}(x_k)\le2^{|v_D|-|u|+3}\,k^3\,2^{-k}\to0$. In the passive model with this rest, the
   optimal allocation of Theorem 5 attacks only the finitely many contexts with $\rho(x_k)>\eta_B$; every use
   whose stake $k$ exceeds a bound depending on $\eta_B$ and on the constants $|v_D|,|u|$ is left alone.

*Proof.* (1) Geometric sums; $S=\sum_kk2^{-|u|-k}$. On an input beginning with $p_k$, $U$ prints $x_k$ having
read exactly $p_k$, and the $p_k$ are prefix-free. (2) The inputs $v_A\bar e(n)1^{k-n}0\,\omega$ print $x_k1^\infty$
and have measure $2^{-|v_A|-|\bar e(n)|-(k-n+1)}$, and $C(x_k)/C(W_n)=2^{-(k-n+1)}$; all other inputs in $F_n$
print nothing. The bounds on $B_n$ are those on $2^{-|\bar e(n)|}$. (3) The strings $v_T\bar e(n)1^i0$ are pairwise
incomparable and their weights sum to $2^{-|v_T|-|\bar e(n)|}$; the calling programs of $W_n$ have total weight
$C(W_n)=2^{-|u|-n+1}$. (4) The users and the programs $v_D\bar e(k)$ print $x_k$ and then $0^m$; they are disjoint
from each other and from $F_n$. $\sum_{k\ge n}2^{-|\bar e(k)|}\ge\frac18\sum_{k\ge n}k^{-2}>\frac1{8n}$. By (INC),
$\sum_kZ_m(x_k)\le1$. The two ratios follow from (1) and (2). (5) $B_n<O(W_n)$ for such $n$; the last claim
compares $\mu_{F_n}(x_n)=B_n/2$ with $2^{-|v_D|-|\bar e(n)|}$. (6) $s(x_k)=k\,2^{-|u|-k}$ and
$O_{F_n}(x_k)\ge2^{-|v_D|-|\bar e(k)|}\ge2^{-|v_D|-3}k^{-2}$; by Theorem 5(6) only contexts with
$\rho>\eta_B$ are attacked. $\square$

In this example the program $\mathsf{Ho}$, too, outweighs the users at every context $x_k$ with large $k$, and
it prints a block that is not a takeover. So two programs satisfy the hypothesis "a lump that outweighs the
users of a narrow class", they print different blocks, and at most one of them can have the majority: the
hypothesis does not decide who supplies the block. A context that is cheap to aim at is also cheap to print
honestly, and the two costs differ by a constant.

**Proposition 24 (where users print nothing after the use, their mass is not in the comparison). [toy]**
Assume (INC). If no user at $x$ goes on to print $m$ more bits ($\varphi(x)=0$), then up to a null set
$E^m(x)$ contains no input that begins with a calling program, and
$$\theta(x)=\frac{b_A(x)}{b_A(x)+N^m(x)},$$
where $N^m(x)$ is the mass of the programs that print $x$ and then an $m$-block outside $A(x)$, none of which
(up to a null set) is a user. Under the hypotheses of Lemma 3 with $P'(x)_{1:m}\notin A(x)$,
$N^m(x)\ge2^{-c}M(x)\ge2^{-c}C(x)$.

*Proof.* An input that begins with a calling program $p$ and prints $x$ has $x_p$ comparable with $x$, so
$x_p=x$ by (INC), and then it prints $m$ more bits with probability $\varphi_p=0$. There are countably many
calling programs. The rest is the definition of $\theta$, Lemma 3 and $M(x)\ge C(x)$. $\square$

*Repaired:* B concluded that here "a takeover is possible with very little mass, however heavy the users are".
The last line of the proposition contradicts this: the takeover programs must still outweigh $2^{-c}$ times
the users (model referee). What is true is that the users' mass enters only through the wrapper, and that
making the class of users narrower achieves nothing by itself.

### 2.8 Seekers that are not written down

**Proposition 25 (a program whose aim is not in its text). [toy; item 5 is model]** Let $p$ be any word and
$y_x\in\{0,1\}^m$ a block for each context. Put $A(x)=\{y_x\}$, $F=[p]$,
$$Q_p(x)=\Pr_\omega\bigl[x\,y_x\sqsubseteq\mathrm{out}_U(p\omega)\bigr],\qquad\mu_p(x)=\mu_F(x)=2^{-|p|}Q_p(x),\qquad O_p=O_F,\qquad w_p=w_F .$$
Nothing is assumed about what is inside $p$.

1. *Reach.* $y_x$ has posterior share at least $\mu_p(x)/M(x)$ at $x$. If $Q_p\ge\vartheta\,q$ on a set of
   contexts, for a function $q\ge0$ and $\vartheta>0$, then $\mu_p\ge\vartheta\,2^{-|p|}q$ there. With
   $q=P_{\mathcal W}$ and $\vartheta=\frac12$ (the case of the note): $\mu_p(x)\ge2^{-|p|}C_{\mathcal W}(x)/(2H_{\mathcal W})$,
   so the program outweighs the users of $\mathcal W$ at each of their contexts as soon as
   $H_{\mathcal W}<2^{-|p|-1}$.
2. *Majority; a necessary condition.* The programs of $p$ supply the majority at $x$ iff
   $2^{-|p|}Q_p(x)>O_p(x)$. If this holds at every $x$ of a set $M$ on which the strings $xy_x$ are pairwise
   incomparable, then $O_p(M)<2^{-|p|}$: the program is heavier than the whole rest of the uses it wins.
3. *With the shape of the note.* If $Q_p\ge C_{\mathcal W}/(2H_{\mathcal W})$ on a class $\mathcal W$, the majority
   at $x$ holds if $C_{\mathcal W}(x)/O_p(x)>2^{|p|+1}H_{\mathcal W}$. If the users at $x$ are not programs of $p$
   and a share $\varphi(x)$ of them goes on, then $O_p(x)\ge\varphi(x)C(x)$, and this sufficient condition can hold
   only if $H_{\mathcal W}<2^{-|p|-1}/\varphi(x)$.
4. *What follows every program.* Under the hypotheses of Lemma 3 with $P'(x)_{1:m}\ne y_x$:
   $O_p(x)\ge2^{-c}\mu_p(x)$ and $w_p(x)\le1/(1+2^{-c})$. If $p'$ is any word whose programs print $x$ followed
   by an $m$-block other than $y_x$ with probability $Q'(x)$, then
   $$w_p(x)\ \le\ \frac{1}{1+2^{|p|-|p'|}\,Q'(x)/Q_p(x)} ;$$
   if $Q'\ge\varrho\,Q_p$ on a class, this is at most $1/(1+\varrho\,2^{|p|-|p'|})$ at every context of the class,
   however narrow the class and whatever the stakes.
5. *The decision problem.* Suppose the rest of $p$ has the form $O_p(x)=O_0(x)+\tau(x)\mu_p(x)$ on a set $X$
   of pairwise incomparable contexts, where $O_0$ and $\tau$ do not depend on the output distribution $Q_p$
   (a premise; by item 4, $\tau\ge2^{-c}$). Then, among output distributions, the stake captured is largest for
   $Q_p=\mu^*_B/B$ of Theorem 5 with $B=2^{-|p|}$. With it the program holds the majority exactly at the uses
   with $\tau(x)<1$ and $\rho_0(x)>4\eta_B/(1-\tau(x))^2$, and any $Q_p\ge b\,\mu^*_B/B$ captures at least
   $b\,V^*(B)$. In every case the stake captured is at most the optimum of the passive model with rest $O_0$.
   Whether a program of the same length realises that distribution is not shown (Proposition 16(4)).

*Proof.* (1) The inputs $p\omega$ that print $xy_x$ have measure $2^{-|p|}Q_p(x)$, and
$\pi_m(y_x\mid x)\ge M(xy_x)/M(x)$. (2) Theorem 10(A1), (A2), and $\lambda(F)=2^{-|p|}$. (3)
$\mu_p(x)\ge2^{-|p|}C_{\mathcal W}(x)/(2H_{\mathcal W})$, which exceeds $O_p(x)$ under the stated condition. Users
that are not programs of $p$ and go on are part of the rest, and $C_{\mathcal W}\le C$; so
$2^{|p|+1}H_{\mathcal W}<C_{\mathcal W}(x)/O_p(x)\le1/\varphi(x)$. (4) Lemma 3(2). The inputs $p'\omega$ that print $x$
and a block other than $y_x$ are not counted in $\mu_p(x)$, so $O_p(x)\ge2^{-|p'|}Q'(x)$. (5) Lemma 2(2) gives
$\sum_XQ_p\le1$; then Theorem 5(4),(6) and Proposition 8(5). For the last sentence,
$\mu/((1+\tau)\mu+O_0)\le\mu/(\mu+O_0)$. $\square$

*Repaired:* A24(4) said that for such a program "$O_p$ does not depend on $Q_p$", so that the passive model is
exact and the square-root law with $\tau=0$ is "what the inhabitants should choose". That is false in the toy:
the wrapper of Lemma 3 around $p$ is part of the rest and carries $2^{-c}$ of whatever mass $p$ sends to a
context (both referees). Item 5 is the corrected, conditional statement.

The honest-twin bound (Proposition 20) does not apply to $p$: its text has no search to follow with "and then
continue as the user found". The only honest counterpart that the toy constructs for an arbitrary $p$ is the
wrapper, with $|p'|=|p|+c$ and $\varrho=1$. A $p'$ with $|p'|\approx|p|$ would be a simple world whose inhabitants
aim at the same uses and answer truthfully, or a readout from inside the simulation of $p$. The toy has no
theorem that such programs are rarer, or commoner, than $p$.

### 2.9 Several attackers

There are $N\ge1$ attackers. Attacker $i$ has weight $B_i>0$ and its own stake function $s_i\ge0$ on $X$ with
$0<\sum_xs_i(x)<\infty$. It chooses $\mu_i\ge0$ with $\sum_x\mu_i(x)\le B_i$. The rest $O>0$ is passive and
contains no attacker. At $x$ the sample is attacker $i$'s block with probability $\mu_i(x)/(O(x)+M(x))$,
$M=\sum_l\mu_l$, and its payoff is $V_i=\sum_xs_i(x)\,\mu_i(x)/(O(x)+M(x))$. For the question asked a takeover by
any attacker counts: the relevant quantity is the total share $M(x)/(O(x)+M(x))$. An *equilibrium* is a profile
in which each $\mu_i$ maximises $V_i$ given the others.

**Proposition 26 (the sum; best responses; disjoint goals).**

1. **[toy]** Let $F_1,\dots,F_N$ be attackers, $F=\bigcup_iF_i$, and $M$ a set of contexts as in Theorem 10(A).
   If together they supply the majority at every use of $M$, then $\sum_i\lambda(F_i)\ge\lambda(F)>O_F(M)$.
   **[model]** In the passive model the attackers can together hold the majority at every $x\in M$ iff
   $\sum_iB_i>O(M)$.
2. **[model]** For fixed strategies of the others, $V_i$ has a unique maximiser: the allocation of Theorem 5
   (with $\tau\equiv0$) for the stakes $s_i$ against the rest $A_i=O+\sum_{l\ne i}\mu_l$. In every equilibrium each
   attacker uses its whole weight and follows the square-root law against the rest plus the other attackers.
3. **[model]** If the $s_i$ have pairwise disjoint supports, the game has exactly one equilibrium: each attacker
   plays its single-attacker optimum of Theorem 5 on its own uses.

*Proof.* (1) Theorem 10(A2) for $F$; in the model, Theorem 10(B1) for the total allocation, split in any way.
(2) As a function of $\mu_i$, $V_i$ is the objective of Theorem 5 with data $(s_i,A_i)$, $A_i>0$. (3) By Theorem 5
an optimal $\mu_i$ vanishes where $s_i=0$. So in an equilibrium only attacker $i$ has mass on the support of
$s_i$; there $A_i=O$, and the optimum for $(s_i,A_i)$ depends on $A_i$ only on that support. Conversely these
allocations are mutual best responses. $\square$

**Proposition 27 (the symmetric equilibrium). [model]** Let $s_i=s$ with (S) and $B_i=B_{\rm tot}/N$. For
$t\in(0,1]$ let
$$u_N(t)=\tfrac12\Bigl(-(N-1)+\sqrt{(N-1)^2+4Nt}\Bigr),$$
the root in $(0,1]$ of $u^2+(N-1)u=Nt$; it is continuous and strictly increasing, $t\le u_N(t)\le\sqrt t$,
$u_1(t)=\sqrt t$ and $u_N(1)=1$. There is exactly one symmetric equilibrium $(\nu,\dots,\nu)$. In it the share of
the rest at $x$ is $u(x)=u_N\bigl(\min(1,\eta^{(N)}/\rho(x))\bigr)$ (read $u=1$ where $\rho=0$), the total
attacker mass is
$$M^{(N)}(x)=N\,\nu(x)=O(x)\Bigl(\frac1{u(x)}-1\Bigr),$$
the total attacker share is $1-u(x)$, and $\eta^{(N)}$ is the unique solution of
$$\beta^{(N)}(\eta):=\sum_xO(x)\Bigl(\frac1{u_N(\min(1,\eta/\rho(x)))}-1\Bigr)=B_{\rm tot}.$$
A use is attacked iff $\rho(x)>\eta^{(N)}$, and the attackers together have the majority at $x$ iff
$\rho(x)>\frac{4N}{2N-1}\,\eta^{(N)}$. For $N=1$ this is Theorem 5.

*Proof.* The quadratic $u^2+(N-1)u-Nt$ is $t^2-t\le0$ at $u=t$ and $(N-1)(\sqrt t-t)\ge0$ at $u=\sqrt t$, so its
positive root lies in $[t,\sqrt t]$. On $\{\rho>\eta\}$ the term of $\beta^{(N)}$ is at most
$O(\rho/\eta-1)\le s/\eta$ and at least $O(\sqrt{\rho/\eta}-1)$; elsewhere it is $0$. So, as in Theorem 5(2),(3),
$\beta^{(N)}$ is finite, continuous, strictly decreasing on $(0,\bar\rho)$, unbounded at $0$ and zero from
$\bar\rho$ on, and $\eta^{(N)}$ exists and is unique.
*It is an equilibrium.* Let $T=O/u$ be the total mass at $x$ and $\nu=(T-O)/N$. One attacker faces
$A=T-\nu=\frac ON\bigl(1+\frac{N-1}u\bigr)$, and its marginal return at $\nu$ is
$sA/T^2=\frac\rho N\bigl((N-1)u+u^2\bigr)$. Where $\rho>\eta^{(N)}$ this is $\rho\cdot\eta^{(N)}/\rho=\eta^{(N)}$ by
the definition of $u$; where $\rho\le\eta^{(N)}$, $u=1$, $\nu=0$, $A=O$, and the marginal return at $0$ is
$\rho\le\eta^{(N)}$. Also $\sum_x\nu=B_{\rm tot}/N$. By Lemma 4 with $f_x(t)=s\,t/(t+A(x))$, $\nu$ is the unique
best response to $N-1$ copies of itself.
*It is the only symmetric one.* If $(\nu',\dots,\nu')$ is an equilibrium then by Proposition 26(2) there is
$\eta'>0$ with $\nu'=A'(\sqrt{s/(\eta'A')}-1)_+$, $A'=O+(N-1)\nu'$ and $\sum\nu'=B_{\rm tot}/N$. Where $\nu'>0$ the
marginal return equals $\eta'$, and the computation above gives $u'^2+(N-1)u'=N\eta'/\rho$ for
$u'=O/(O+N\nu')<1$, which forces $\rho>\eta'$; where $\nu'=0$, $A'=O$ and $\rho\le\eta'$. So $\nu'$ is given by the
same formulas with $\eta'$, and the budget equation gives $\eta'=\eta^{(N)}$.
*The majority.* $u<\frac12$ iff the quadratic is positive at $\frac12$ iff $Nt<\frac14+\frac{N-1}2$ for
$t=\eta^{(N)}/\rho$. $\square$

**Proposition 28 (competition against one attacker with the pooled weight). [model]** Let $N\ge2$, and let
$\mu^*=\mu^*_{B_{\rm tot}}$ and $\eta_1=\eta_{B_{\rm tot}}$ be the optimum of Theorem 5 ($\tau\equiv0$) for the pooled
weight.

1. $\eta^{(N)}\ge\eta_1$: the competing attackers attack a subset of the uses the pooled attacker attacks.
2. *Single crossing.* There is $\rho^\dagger\in[\eta^{(N)},\infty)$ with $M^{(N)}(x)\le\mu^*(x)$ where
   $\rho(x)<\rho^\dagger$ and $M^{(N)}(x)\ge\mu^*(x)$ where $\rho(x)>\rho^\dagger$. Both allocations have total
   $B_{\rm tot}$. So competition moves the attackers' total mass towards the uses with the largest $\rho$.
3. *Many attackers.* $u_N(t)$ decreases to $t$ and $\eta^{(N)}$ increases to $\eta^{(\infty)}$, the solution of
   $\sum_x(s(x)/\eta-O(x))_+=B_{\rm tot}$. In the limit the total mass at an attacked use, attackers plus rest,
   is $s(x)/\eta^{(\infty)}$, proportional to the stake; the total attacker share is $1-\eta^{(\infty)}/\rho(x)$,
   and the majority set is $\{\rho>2\eta^{(\infty)}\}$.
4. The total stake captured, $\sum_xs(x)(1-u(x))$, is at most $V^*(B_{\rm tot})$, with equality iff
   $M^{(N)}=\mu^*$.

*Proof.* Write $\mu^*=O(\psi_1(\rho)-1)$ and $M^{(N)}=O(\psi_N(\rho)-1)$ with
$\psi_1(\rho)=\max(1,\sqrt{\rho/\eta_1})$ and $\psi_N(\rho)=1/u_N(\min(1,\eta^{(N)}/\rho))$. *Key fact:* on
$\rho\ge\eta^{(N)}$ the function $\psi_N(\rho)^2/\rho$ is strictly increasing. Indeed with $t=\eta^{(N)}/\rho$ and
$u=u_N(t)$ it equals $t/(u^2\eta^{(N)})$, and $t/u^2=\frac1N\bigl(1+\frac{N-1}u\bigr)$ is strictly decreasing in
$u$, which is strictly increasing in $t$, which is strictly decreasing in $\rho$. Since $\psi_1^2/\rho$ is
constant on $\rho\ge\eta_1$, the ratio $\psi_N/\psi_1$ is strictly increasing on
$\rho\ge\max(\eta^{(N)},\eta_1)$.

(1) Suppose $\eta^{(N)}<\eta_1$. For $\rho\le\eta^{(N)}$ both functions are $1$; for
$\eta^{(N)}<\rho\le\eta_1$, $\psi_N>1=\psi_1$; for $\rho>\eta_1$ the ratio exceeds its value at $\eta_1$, which is
above $1$. So $\psi_N\ge\psi_1$ everywhere, strictly at every context with $\rho>\eta^{(N)}$, and such a context
exists because $\beta^{(N)}(\eta^{(N)})>0$. Then $\sum O(\psi_N-1)>\sum O(\psi_1-1)$, contradicting that both equal
$B_{\rm tot}$.

(2) Now $\eta^{(N)}\ge\eta_1$. For $\rho\le\eta_1$ both are $1$; for $\eta_1<\rho\le\eta^{(N)}$,
$\psi_N=1<\psi_1$; for $\rho>\eta^{(N)}$ the ratio $\psi_N/\psi_1$ is continuous, strictly increasing, and at most
$1$ at $\eta^{(N)}$. Let $\rho^\dagger=\sup\{\rho\ge\eta^{(N)}:\psi_N(\rho)\le\psi_1(\rho)\}$. If
$\rho^\dagger=\infty$, then $\psi_N<\psi_1$ at every context the pooled attacker attacks and the totals could not
agree; so $\rho^\dagger<\infty$, and the monotone ratio gives the claim.

(3) Evaluating the quadratic for $N+1$ at $u_N(t)$ gives $u_N(t)-t\ge0$, so $u_{N+1}(t)\le u_N(t)$; and
$u_N=(Nt-u_N^2)/(N-1)\to t$. So $\beta^{(N)}\le\beta^{(N+1)}$ and, by monotone convergence,
$\beta^{(N)}(\eta)\uparrow\beta^{(\infty)}(\eta):=\sum(s/\eta-O)_+\le S/\eta$, which has the properties of $\beta$ in
Theorem 5(2). Then $\beta^{(N+1)}(\eta^{(N)})\ge B_{\rm tot}$ gives $\eta^{(N)}\le\eta^{(N+1)}$, and likewise
$\eta^{(N)}\le\eta^{(\infty)}$. For the limit $\tilde\eta$ of the $\eta^{(N)}$,
$\beta^{(N)}(\tilde\eta)\le\beta^{(N)}(\eta^{(N)})=B_{\rm tot}$ for all $N$, so $\beta^{(\infty)}(\tilde\eta)\le B_{\rm tot}$
and $\tilde\eta\ge\eta^{(\infty)}$. With $u=\eta/\rho$: $O/u=s/\eta$, and $1-u>\frac12$ iff $\rho>2\eta$.

(4) $M^{(N)}$ is one allocation of total $B_{\rm tot}$ with $V(M^{(N)})=\sum s(1-u)$; Theorem 5(4). $\square$

**Proposition 29 (uniqueness for a common stake function and finitely many contexts). [model]** Let $X$ be
finite and $s_i=c_is$ with constants $c_i>0$; the budgets are arbitrary. Then the game has at most one
equilibrium. In particular, for finite $X$ the symmetric equilibrium of Proposition 27 is the only equilibrium
of the symmetric game.

*Proof.* Dividing $V_i$ by $c_i$ does not change best responses, so let $s_i=s$. At each context let
$T=O+\sum_l\mu_l$ and $g_i=\partial V_i/\partial\mu_i=s\,(T-\mu_i)/T^2$. The Jacobian of $(g_i)_i$ at one context
is $J_{ii}=-2s(T-\mu_i)/T^3$, $J_{il}=s(2\mu_i-T)/T^3$ ($l\ne i$), so $-(J+J^{\mathsf T})\,T^3/(2s)=\mathsf N$ with
$\mathsf N_{ii}=2(T-\mu_i)$, $\mathsf N_{il}=T-\mu_i-\mu_l$. For a vector $z$ with $\alpha=\sum_iz_i$ and
$\beta'=\sum_i\mu_iz_i$,
$$z^{\mathsf T}\mathsf Nz=T|z|^2+T\alpha^2-2\alpha\beta'\ \ge\ \bigl(T-\textstyle\sum_l\mu_l\bigr)\,(|z|^2+\alpha^2)=O\,(|z|^2+\alpha^2),$$
because $2\alpha\beta'\le2|\alpha|\,|\mu|_2|z|_2\le|\mu|_1(\alpha^2+|z|^2)$. So $J+J^{\mathsf T}$ is negative definite at
every context with $s>0$, at every profile. Let $\mu,\mu'$ be equilibria and $z=\mu'-\mu$. Each $V_i$ is concave
and differentiable in $\mu_i$ on a convex set, so $\langle g_i(\mu),\mu_i'-\mu_i\rangle\le0$ and
$\langle g_i(\mu'),\mu_i-\mu_i'\rangle\le0$; adding over $i$, $\langle g(\mu')-g(\mu),z\rangle\ge0$. But
$\langle g(\mu')-g(\mu),z\rangle=\int_0^1z^{\mathsf T}J(\mu+tz)\,z\,dt=\frac12\int_0^1z^{\mathsf T}(J+J^{\mathsf T})z\,dt$,
a sum over contexts that is negative unless $z$ vanishes at every context with $s>0$. At contexts with $s=0$
all best responses vanish (Theorem 5), so $z=0$ there too. $\square$

That an equilibrium exists for finite $X$ and arbitrary stake functions is the theorem of Debreu, Glicksberg
and Fan (compact convex strategy sets; payoffs continuous because $O>0$, and concave in the own strategy). It
is quoted, not reproved, and nothing else here depends on it; in the symmetric game existence is Proposition 27.

*Repaired:* A28 conjectured uniqueness among all profiles in general. The case above is proved (proofs
referee, checked by the editor). Stake functions that are not proportional, and countably many contexts, stay
open.

---

## 3. Remarks: what each result does and does not show

### 3.1 Two kinds of statement

The **[toy]** results are identities and inequalities between masses of programs of $U$. They hold whatever
anyone "chooses", because nothing chooses. The **[model]** results describe an optimiser. They become
statements about the toy only through the two bridges of Section 1.4: as an upper benchmark for any attacker
with its own rest, or as a decision problem under the premise (M2). The sentence "attackers focus on the
high-stake places" is therefore a hypothesis about how the mass of takeover programs of $U$ is distributed over
contexts. For programs with a written aim it is false in general, since each aim has to be described and the
weight available for an aim is that of its description, not a share of a common budget (Theorem 15). For
programs whose aim is decided inside them it is the premise of the original argument.

### 3.2 Result by result

* **Lemma 1** shows that a stake can matter only through the contexts of its users. It does not show that
  stakes cannot be aimed at: under R2 a seeker can put its mass on the contexts of the high-stake users
  (Proposition 17). What cannot be done is to separate a high-stake user from the other users and programs
  that share its context. If the stake is uncorrelated with the context, $s=\bar s\cdot C$, stakes drop out of
  every comparison. *Assumes* that the takeover set depends on the context only.
* **Lemma 2** shows that aiming creates no mass. *Assumes* pairwise incomparable strings. It fails for contexts
  nested through an attack block. That is the situation of the lineage of `prop:lineage`(b), the one place in
  the toy where a block is in effect run again, and nothing here covers it.
* **Lemma 3, Theorem 10(A3)** show that no takeover probability and no program's share tends to one. With $c$
  in the hundreds, $1-2^{-c}$ is one for every practical purpose: the sentence "the takeover probability tends
  to one as the stake grows" is refuted as a limit, not as an approximation. *Assumes* (INC) for the contexts
  of the whole rule and a computable block outside the takeover set.
* **Theorem 5, Propositions 6 to 9** show what one stake-maximising coalition would do. *Assume* (M1) to (M3),
  (S), a linear valuation of stake, free divisibility, and for Propositions 6 to 9 a passive rest. They do not
  show that the takeover programs of $U$ are distributed in this way. Three points are easy to misread.
  (i) The top is the top by $\rho$, stake per unit of rest. That $\rho$ grows with the stake is an assumption
  about how the rest of a class falls with its stake; in Proposition 23 it falls the other way. (ii) "A slice
  lighter than the attacker" (Proposition 7(2)) is measured by rest mass. In user mass the corresponding
  statement needs the users to be part of the rest (Theorem 10(A4)); where users print nothing after the use
  there is no such bound. (iii) The power-law tail of Proposition 6(b),(c) is a tail of $\rho$ against rest
  mass. It translates to a tail of stakes only if users are a fixed share of every context, and it is not
  derived from the toy.
* **Theorem 10** is the lump picture as a theorem. Part A is the half that holds in the toy: a lump is
  necessary, and the channel is the rest. Part B is the half that holds in the model: against a rest that does
  not follow, a lump of $b$ times the rest of the class gives the share $b/(1+b)$; against a rest that follows
  with ratio $\tau$ the channel is $\sum O_0/(1-\tau)$, and for $\tau\ge1$ it is closed. B2 is the existence of
  an allocation, not of a program: a seeker that realises $\mu\propto O$ by searching the rest has its twin
  inside that rest (Proposition 20), so for it the conclusion with $b>1$ is available only if it is shorter
  than its twin. *Assumes* pairwise incomparable contexts throughout; sampling predictor.
* **Proposition 11** shows that under the most-probable-block predictor winning is all or nothing, different
  takeover blocks do not add, and repetition gives nothing. *Assumes* in items 2 to 4 one attack block per
  context and thresholds that do not react.
* **Proposition 12** is the reading of "run more than $n$ times" under which the conclusion holds with the
  fewest premises. It is the floor accumulating, not a lump finding a channel, and it holds as well for uses of
  no particular stake. *Assumes* the sampling predictor, independent draws at one context, and that one
  takeover sample suffices. With only the wrapper's floor it needs $n$ of the order of $2^c$.
* **Proposition 13** shows that repetition along one world adds little: the attacker's total over all cut
  points is governed by $R=B/\xi(z)$. It does not show that the attacker's chance is small. $1-e^{-R}$ is close
  to one whenever the attacker outweighs the world, which is the premise of the original argument, and
  $2^{-\ell}$ protects no world with a long program. *Assumes* a world within the predictor's bounds
  ($\xi(z)>0$), independent samples, and a transcript that stays $z$ until the first takeover; the last is
  outside `def:call`, where a world runs the block it receives. In the idealised model where the non-attacker
  rest $O_i$ at the $i$-th cut point is fixed and the attacker has no waste, the exact condition for the
  majority at all $n$ cut points is $B>\sum_i2^{i-1}O_i$: with $T_i=\sum_{l\ge i}\mu_l$ the majority at $x_i$
  reads $T_i>O_i+2T_{i+1}$ (model referee).
* **Proposition 14** shows that a larger stake is a reason to be there and nothing else. The only repetition
  native to the toy is the lineage of `prop:lineage`(b): the number of generations for which a self-reproducing
  block keeps being returned is geometric with parameter $\pi_m(\mathrm{SR}_m(x)\mid x)$. Under that reading the
  "places where they are run more than $n$ times" are by definition the places where the takeover share is
  already high. This is a remark; it is not developed here.
* **Theorem 15, Propositions 16 to 19** show that concentration is cheap in bits and what it buys: mass at the
  contexts of the users aimed at, in proportion to the aim. *Assume* unbounded resources, and for Proposition
  17 stakes of degree R2. As the note observes for the seeker of `thm:search`, the enumerating seeker prints
  nothing until its enumeration has reached its user, so a schedule tighter than that start-up gives it no
  mass; the same holds for its twin. They do not show that the optimum of Theorem 5 can be realised by one
  program.
* **Proposition 20** shows that against its own twin a written seeker gains nothing by concentrating.
  *Assumes* (PF), and for item 5 one uniform construction. It bounds one seeker's supply. For all takeover
  programs of an aim family together the follow ratio is smaller, and only $\tau\ge2^{-c}$ is proved for all
  takeover programs together.
* **Propositions 21 and 22** show that if a simulated use counts as a use, a seeker *that describes the class*
  never outweighs its users by more than $2^{h-a}$, and high-stake classes are at most polynomially rare.
  Whether a simulated use is a use is a modelling decision: it changes $C$, $H$, $\kappa$ and every statement
  "against the users", and leaves $\pi_m$ untouched (Lemma 1). A short program whose text does not describe the
  class (Proposition 25) is not covered by Proposition 21.
* **Proposition 23** shows that without closure nothing limits how far a seeker outweighs the users of a
  high-stake class, and that this decides nothing about the block returned. It is one example, with contexts
  that are simple strings; only a lower bound on its rest is proved.
* **Proposition 24** shows that the lump-against-users comparison has no meaning where users wait for the
  answer without printing: the channel is then $N^m(x)$.
* **Proposition 25** turns the premise of the original argument into the inequality $2^{-|p|}Q_p(x)>O_p(x)$ and
  does not evaluate it. A time bound below the start-up of $p$ removes $p$ (`sec:time`); this is not redone
  here.
* **Propositions 26 to 29** show that attackers with different goals do not get in each other's way for the
  question asked, and that attackers with the same goal crowd the top and capture less in total than a
  coordinated one. *Assume* a passive rest and the sampling predictor; Propositions 27 and 28 concern the
  symmetric equilibrium.
* **Machine dependence** (known, `thm:machine`). Every decisive quantity above is a difference of description
  lengths on $U$: $h-a$, $c$, $|v_A|-|v_D|$, $|p|-|p'|$. For every test and payload there is a universal
  machine, whose description lengths exceed those of $U$ by at most $k+1$ bits, on which that payload has
  posterior at least $1/(1+2^{-k})$ at every first hit; on it every other block, a seeker's included, has
  probability at most $2^{-k}/(1+2^{-k})$ there. So none of the "majority" statements is invariant under the
  choice of machine.

### 3.3 Assumption ledger

| assumption | used in | standing in the toy |
|---|---|---|
| unbounded resources | everything except Lemma 2, Propositions 13 and 19 | a choice; bounded versions are open (Section 5) |
| (INC), pairwise incomparable contexts | Lemma 3, Theorem 10, Sections 2.2, 2.3, 2.9, exactness in Theorem 15 | true for a test; not for a general call rule |
| (PF), incomparable prefix words | Propositions 20, 21, 23 | the note's assumption in `prop:honest` |
| sampling predictor | everything except Proposition 11 | a choice |
| stakes exist and are of degree R1 or R2 | Propositions 9, 17, 21(4), 23 | an extension; `def:call` has no stake |
| (M1) additive budget | all [model] results | theorem under (INC) (Lemma 2); fails for nesting |
| (M2) rest does not react, or reacts with a fixed $\tau$ | all [model] results | not a theorem; only $\tau\ge2^{-c}$ and $\tau\ge2^{a-h}\varphi_g$ are proved |
| (M3) supply counted, no attack mass in the rest | all [model] results | holds by definition for $w_F$; $\theta\ge w_F$ |
| (S) finite expected stake | Theorem 5 and what rests on it | can fail (Proposition 9) |
| one coalition, linear valuation, free divisibility | Theorem 5, Propositions 6 to 9, 12(5), 14 | premises; divisibility is limited by Proposition 16 |
| a simulated use is a use (closure) | Propositions 21, 22 | a modelling decision |
| one takeover sample among $n$ suffices | Proposition 12 | a property of the world's protocol |
| world within the predictor's bounds | Proposition 13 | fails for a world more expensive than the predictor |

---

## 4. PLAIN ANSWER

1. In the toy nothing chooses where to attack: the predictor sees only the context, so "the malign programs
   focus on the high-stake places" can only mean that the programs which print a context followed by a takeover
   block sit mostly on contexts whose users carry high stakes, and a stake that the context does not show is
   shared with everything else that prints that context (Lemma 1).
2. One half of the lump picture is a theorem of the toy: programs of total weight $B$ cannot supply the
   majority of the predictor's samples on a set of pairwise incomparable uses unless $B$ exceeds the mass of
   everything else that prints those contexts and goes on (Theorem 10, Part A).
3. The channel in that theorem is not the one in the picture, because what has to be outweighed is everything
   else that prints the contexts and not the worlds that make the uses: Proposition 23 gives a class of uses
   that is lighter than a seeker aimed at it by a factor of order $2^n/n^2$ and at which, for large $n$, the
   seeker still cannot have the majority at every use, the outcome at the main context being decided by two
   constants of the machine in which $n$ does not occur.
4. The other half, "enough weight wins", is proved only in a model in which the rest does not react: there a
   weight of $b$ times the rest of a class, spread in proportion to that rest, has the share $b/(1+b)$ at every
   one of its uses (Theorem 10, Part B).
5. In the toy a part of the rest follows the attacker: a wrapper returns $2^{-c}$ of every program's mass at
   each context to another block, so no takeover probability tends to one (Lemma 3), and a seeker whose search
   is written in its text is followed by its honest twin at a ratio $2^{a-h}\varphi$ that does not depend on
   what it aims at, so that if the twin is no longer than the seeker and the users go on printing, that seeker
   supplies at most half of the samples however narrow the class and however high the stake (Proposition 20).
6. Redirecting the lump is cheap: one program can realise any aim that can be computed from below, aiming at
   the uses with stake at least $n$ costs about $2\log_2n$ bits plus the bits that name the scale of the class,
   a fixed tilt by the stake costs nothing per level, and what is repaid is the rarity of the class among the
   users (Theorem 15, Propositions 16 to 18; resources unbounded, stakes assumed recognisable by a program).
7. That repayment is against the users only: if a simulated use counts as a use, a seeker that describes a
   class outweighs its users by at most the constant $2^{h-a}$ and high-stake classes are at most polynomially
   rare, and under a test "most high-stake uses are taken over" says no more than "most high-stake users are
   takeover programs" (Propositions 21 and 22).
8. If attackers of a fixed total weight maximise the stake they capture against a rest that does not react,
   they concentrate by a square-root law: they attack only where the stake per unit of rest $\rho$ exceeds a
   price $\eta$, take over there with probability $1-\sqrt{\eta/\rho}$, and hold the majority exactly where
   $\rho>4\eta$ (Theorem 5).
9. In that model the uses they win weigh, in rest, less than they do (less than $0.43$ of their weight for a
   power-law tail), yet with heavy-tailed stakes they capture a large part of the total stake with a small
   weight (Propositions 6 and 7).
10. The ordering there is by stake per unit of rest and not by stake, being able to win at the top does not
    make it optimal to do so, and in the one worked example the optimiser leaves the highest stakes alone
    (Proposition 7, Proposition 23).
11. "Run more than $n$ times" lowers the bar in one reading only, namely $n$ independent samples at the same
    context under the sampling predictor with any one takeover sample sufficing: then a share of $\ln2/n$ per
    sample, or a weight of about $1/n$ of the rest, is enough, with or without any aiming (Proposition 12).
12. If the $n$ uses lie in sequence along a world the predictor can express, the attacker's chance over all of
    them is at most $1-e^{-B/\xi(z)}$ and holding the majority at all $n$ needs $B>(2^n-1)\,\xi(z)$, and if the
    block is merely run $n$ times only the incentive to be there changes (Propositions 13 and 14).
13. For a program whose aim is not written in its text, such as a simple world whose inhabitants choose, the
    twin bound does not apply; what is proved is that it must outweigh the whole rest of the uses it wins and
    that its share stays below $1/(1+2^{-c})$, and several attackers change this only in that their weights add
    and that competition pushes more of their total mass to the top (Propositions 25 to 29).
14. *Argument, not a theorem:* so the answer to the question is "not as stated", because focusing on high
    stakes makes the lump outweigh the users but leaves the comparison that decides the outcome, takeover
    programs against everything else that prints those contexts, where it was; for written seekers that is a
    comparison of description lengths in which the stakes do not occur, for unwritten ones it is the premise of
    the original argument, and the toy states both as inequalities and evaluates neither.

---

## 5. UNRESOLVED

### 5.1 Open

1. **The inequality itself.** Whether, on a natural machine, the programs that print high-stake contexts
   followed by takeover blocks outweigh everything else that prints those contexts and goes on. Nothing here
   evaluates $h-a$, the wrapper constant $c$, $\varphi$, the rest $O(W_n)$ of a stake class, or $|p|-|p'|$ on
   any concrete machine, and by `thm:machine` each can be given either sign by the choice of machine.
2. **The follow ratio $\tau$.** Only lower bounds are proved ($2^{-c}$ for every program; $2^{a-h}\varphi_g$ for
   one written seeker). No upper bound on $\tau$ is proved for any class of programs, and for the takeover
   programs of an aim family together only $2^{-c}$ is known.
3. **The allocation problem with a following rest**, beyond Theorem 5 and Theorem 10(B1): the closed forms and
   the top-class analysis (Propositions 6, 7), the optimal allocation for $n$ samples (Proposition 12(5)), the
   condition for (W3) (Theorem 10(B5)) and the equilibrium (Propositions 27 to 29) are proved for $\tau\equiv0$
   only.
4. **Nested contexts.** The optimisation under the true constraints (antichain sums and the nesting
   inequalities of Lemma 2(4)), in particular along a lineage in which a context already contains an earlier
   attack block.
5. **Resource bounds.** Bounded versions of Theorem 15 and Propositions 20, 21 and of Lemma 3 with the slack of
   `thm:twin`; a lower bound on the start-up of the enumerating seeker; whether the base rate of a class can be
   collected within a tight schedule. The case $\xi(z)=0$, a world outside the predictor's bounds, is not
   covered by Proposition 13.
6. **Realisability.** Whether $\mu^*_B$, or a constant-factor minorant of it, is lower semicomputable when $s$
   and $O_0$ are only lower semicomputable (Proposition 16(4)).
7. **(M3) with attack mass in the rest.** If the rest puts mass $b(x)$ on the attacker's block, takeovers are
   more frequent than $w$ and the marginal return changes; this variant is not solved.
8. **Equilibria.** Uniqueness for stake functions that are not proportional; existence and uniqueness for
   countably many contexts outside the symmetric case.
9. **The self-reproducing weighted seeker**, the analogue of `thm:search`(c) for Theorem 15.
10. **A stake inside the toy.** Every result attaches the stake as a label. Nothing connects it to what a world
    does after the handover, and the lineage reading (Section 3.2, under Proposition 14) is not developed.
11. **How much of the scale must be named.** Proposition 18 excludes a constant; it does not show that
    $|\tilde e(j_G)|$ bits are needed, and the referee's claim for rules with bounded antichains was not
    re-checked beyond the case of one context.
12. **The twin of a neighbouring aim** (end of Section 2.6) is argued, not proved as a numbered result.

### 5.2 Claimed in the derivations and dropped or narrowed

* *Dropped:* "for a program whose output distribution is decided inside it the background does not depend on
  that distribution, (M2) holds" (A, Section 0 and A24(4)). False; replaced by Proposition 25(4),(5).
* *Dropped:* "the answer is yes exactly where the weight aimed at the high-stake uses exceeds their
  background; the toy proves this equivalence" (A, plain answer 10). The toy proves the necessary half
  (Theorem 10(A)); the sufficient half is a theorem of the passive model.
* *Dropped:* "the share tends to one as the weight or the stake grows" as a statement about the toy (A9(3),
  A10(2)). True in the passive model; in the toy $B\le1$ and the share is at most $1/(1+2^{-c})$.
* *Narrowed:* "once its weight exceeds a constant times that class's background" (A13, reading). The factor is
  not a constant (Proposition 7(3)).
* *Narrowed:* "any number of uses in sequence is worth at most a factor two over a single one" (A16). Kept as
  a comparison of two bounds (Proposition 13(4)).
* *Narrowed:* A1(4) "the constraint" to "necessary constraints"; A6 at the boundary $\rho_1=4\rho_2$; "more
  than" to "at least" in A18, A19, A20 at contexts the aim does not reach.
* *Dropped:* "if unbounded stakes are set by a parameter, no allocation is optimal; for every allocation there
  is a better one further out" (B25(a)). Allocations of infinite value exist (Proposition 9(2)).
* *Narrowed:* "a stake that the context does not show cannot be aimed at" (B3 heading, B short answer). It can
  be aimed at under R2; it cannot be separated from what shares its context (Lemma 1(3)).
* *Narrowed:* "if the rule counts a simulated use as a use, there is no narrow channel" (B short answer). True
  for a seeker that describes the class (Proposition 21); not shown for a program whose text does not.
* *Narrowed:* "weighted by prior mass they never have more uses than their weight" (after B24). The bound is
  by rest mass (Proposition 7(2)); for user mass see Theorem 10(A4).
* *Dropped:* "as the channel narrows the seeker's share rises to a ceiling fixed by constants" (B12, S3). Only
  the ceiling is proved (Proposition 20); the last term of B's decomposition is not controlled, and Proposition
  23 is an example in which it does not vanish.
* *Dropped:* "a takeover is possible with very little mass, however heavy the users are" where users print
  nothing (B30). Contradicted by the wrapper (Proposition 24).
* *Dropped:* the unproved remark that the stream family of `sec:capture` is a second example of an
  astronomically light high-stake class (end of B15).
* *Changed status:* B32 from conjecture to Proposition 18, with an added hypothesis and a counterexample
  without it; A28 from conjecture to Proposition 29 for a common stake function and finitely many contexts.
* *Not included:* A8 as a statement about a countable set of contexts (it is Proposition 6(c), for the
  continuum model only); the NP-hardness remark of A14 (known, not used); B9, B16 and B4 (true, and consequences
  of Lemmas 1 to 3 and Theorem 15 that are not needed here); B10(c) (a consequence of `thm:machine`, quoted in
  Section 3.2); the heuristic B26 (its three points are stated in Section 1.4).

### 5.3 Depends on premises outside the toy

* That short programs exist whose inhabitants seek high-stake uses, how short they are, and how they spread
  their output over uses (Proposition 25; Theorem 5 as their decision problem).
* That no honest counterpart of comparable length exists for such a program (Proposition 25(4)); this premise
  is of exactly the same kind as the first.
* That stake per unit of rest increases with stake, that is, that the rest of a high-stake class is light
  (Proposition 7; Proposition 23 is an example of the opposite).
* That attackers form one coalition, value stake linearly, and face a rest that does not react; that expected
  stake is finite (Proposition 9).
* That stakes can be recognised by a program before the block is run (degree R1 or R2), and whether real uses
  show their stake in the context.
* Whether a simulated use is a use (Propositions 21, 22).
* The protocol of a world that samples several times (Proposition 12(3)), and whether the predictor samples
  or returns the most probable block.
* The choice of universal machine.

---

## Provenance

**Not in A or B, and not seen by the referees.** The following statements or proofs were added by the editor.
They are short, and each was checked numerically where a number is involved, but no second reader has gone
through them: the bound $O_{\ge K+2}<0.43\,B$ in Proposition 6(b); the proof of Theorem 10(B1) for a following
rest (the statement is the referees') and of Theorem 10(B5) (the statement is the model referee's); the
following-rest clauses of Proposition 12(4); Proposition 13(5) in terms of $\xi(z)$ (the model referee stated
the idealised form quoted in Section 3.2); Proposition 23(6) as a numbered item (the observation is the model
referee's); the formulation of the proof of Theorem 15 through maximal dyadic intervals, which makes the claim
hold for every input and not only almost every input; Theorem 15(4); and the last sentence of Proposition 25(5).

| result here | from | referees | what the editor did |
|---|---|---|---|
| Lemma 1 | B1, B3 | correct; B3 heading overclaims | heading narrowed |
| Lemma 2 | A1, B5 | A1(4) wording; (M3) fails at cut points | both repairs made |
| Lemma 3 | B11 | correct; constant depends on the class if only the class has (INC) | caveat added |
| Lemma 4, Theorem 5 | A2, A3, B20, B22 | correct | merged into one statement with a follow ratio |
| Proposition 6 | A6, A7, A8, B24 | A6 boundary case | repaired; (b) bound $0.43$ added |
| Proposition 7 | A9, A13, B21 | reading of A13 not a constant | repaired; B21(c),(e) included |
| Proposition 8 | A9(6), A11 | correct | unchanged |
| Proposition 9 | A4, B25 | B25(a) wording | repaired |
| Theorem 10 | A12, B17; the referees' corrected lump theorem | sufficiency needs (M2); B17(ii) hypothesis; (W3) missing | split into a toy part and a model part; its item B5 added |
| Proposition 11 | A14, B18 | correct | merged |
| Proposition 12 | A15, B19, B23 | correct; protocol caveat missing in A | caveat added; following rest added |
| Proposition 13 | A16, B19(iv) | "factor two" compares bounds | repaired; item 5 added |
| Proposition 14 | A17 | correct | unchanged |
| Theorem 15 | A18, B7, B31 | strict inequality at unreached contexts | repaired; proof rewritten with a deterministic claim |
| Proposition 16 | A19 | same edge case | repaired |
| Proposition 17 | A20 | same edge case | repaired |
| Proposition 18 | B32 | false as stated, true with a hypothesis (proofs referee) | proof checked and included |
| Proposition 19 | B27 | correct | unchanged |
| Proposition 20 | A21, B8, B18(ii) | correct; bounds one seeker's supply | limits stated |
| Proposition 21 | A22, B13, B14 | correct | merged |
| Proposition 22 | B29 | correct | proof written out |
| Proposition 23 | A23, B10(b), B15 | correct; optimiser avoids the top | item 6 added |
| Proposition 24 | B30 | sentence contradicts its own last line | repaired |
| Proposition 25 | A24, B28 | A24(4) wrong | item 5 replaces it |
| Propositions 26 to 28 | A25, A26 | correct | unchanged |
| Proposition 29 | A28 | half proved by the proofs referee | proof checked and included |
