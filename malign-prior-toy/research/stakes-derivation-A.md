# Stakes and concentration: the constructive side (derivation A)

Research note for `malign-prior-toy`; written by an AI, not reviewed by a human. Notation follows
`paper/sec2-toy.tex` and `paper/sec3-floor.tex` (monotone machine $U$, mixture $\xi$, $M_U$, calling programs $p$ with
contexts $x_p$, $C(x)$, $H_{\mathcal C}$, $\kappa$, the codes $\bar e$, the rescaler $R$ of `thm:search`(b)).
The letter $\lambda$ has two uses that the context separates: applied to a set of inputs, as in $\lambda(F)$ or
$\lambda\{\dots\}$, it is the fair-coin measure of the note; as a number ($\lambda$, $\lambda_B$, $\lambda^{(k)}$) it is a
Lagrange multiplier.

**The question.** "Is it true that if the malign guys focus on attacking the places where in some sense the most
resources are at stake (maybe they will be run more than $n$ times there) then there they really do take over in
most cases? There is this lump of prior that can be redirected to a smaller channel, and then they win there."

Status words used below: **PROVED** (full proof here), **KNOWN** (standard, cited, not reproved), **HEURISTIC**,
**CONJECTURE**. Numerical sanity checks (water-filling against random search, the closed forms of A6 to A8, the
equilibrium of A25 against best responses, the knapsack bound of A14) were run in a scratch directory; they are
not part of any proof.

---

## 0. The abstract model, and what I changed

**Data.** A countable set $X$ of contexts. For $x\in X$:

* $C(x)>0$, the prior mass of the worlds that make a critical use at $x$;
* $s(x)\ge 0$, the *stake-weighted user mass*. In the suggested model $s(x)=C(x)\,r(x)$. In the toy the stake
  belongs to the calling program, not to the context, so I take $s(x)=\sum_{p:\,x_p=x}2^{-|p|}r(p)$ and
  $r(x):=s(x)/C(x)$ is then the $C$-average stake at $x$. Nothing below uses more than $s$;
* $O(x)>0$, the background mass: all programs other than the attacker's that print $x$ and at least $m$ more bits.

For a set $M\subseteq X$ write $C(M),s(M),O(M)$ for the sums. Put
$$\rho(x)=\frac{s(x)}{O(x)},\qquad k(x)=\frac{C(x)}{O(x)},\qquad S=s(X),\qquad \bar\rho=\sup_x\rho(x)\in(0,\infty].$$
So $\rho=r\cdot k$: stake times users per unit of background. If the users at $x$ all go on to print $m$ more
bits they are part of the background, $O(x)\ge C(x)$, and then $k\le1$ and $\rho\le r$.

**The attacker** has weight $B>0$ and places mass $\mu(x)\ge0$ with

* **(M1)** $\sum_x\mu(x)\le B$ (additivity; see A1 for when this is the right constraint);
* **(M2)** $O$ does not depend on $\mu$;
* **(M3)** at $x$ the sampling predictor returns the attacker's block with probability
  $w(x)=\mu(x)/(\mu(x)+O(x))$.

The objective is $V(\mu)=\sum_x s(x)\,w(x)$.

**Standing assumption (S):** $0<S<\infty$ (finite expected stake). This is a change from the suggested model: it
is what makes the optimum exist when $X$ is infinite (A3, A4). Note that $\sum_xO(x)$ is *not* assumed finite; in
the toy one background program counts at every context along its output.

**What the model is a model of.** In the mixture all programs are present at once, so "the attacker chooses
$\mu$" is not a choice among written-down seekers: every lower semicomputable allocation has its own program
(A19) and their masses add. The optimisation is literally the problem of one fixed program $p$ of weight
$B=2^{-|p|}$ whose output distribution is decided inside it (the inhabitants of Section 9): the set of the
attacker's programs is then fixed, the background is its complement, and (M2) holds. For written seekers the
optimum is a benchmark: a program of weight $B$ whose masses are additive captures at most $V^*(B)$ computed
with its own background.

(M3) assumes that the background puts no mass on the attacker's block. If it puts mass $b(x)$ there, the block is
returned with probability $(\mu+b)/(\mu+O)\ge w$, so everything below is a lower bound on takeovers and is exact
for "the returned block was supplied by one of the attacker's programs", the reading of `prop:honest`(a).

### A1 (when the budget is additive). PROVED.

Let $F$ be a measurable set of inputs of $U$ (the attacker's programs), $B=\lambda(F)$, and for each $x\in X$ let
$A(x)\subseteq\{0,1\}^m$ be the blocks that count as the attacker's at $x$. Put
$\mu(x)=\lambda\bigl(F\cap\bigcup_{y\in A(x)}E(xy)\bigr)$.

1. If the strings $xy$ ($x\in X$, $y\in A(x)$) are pairwise incomparable, then $\sum_x\mu(x)\le B$.
2. This is the case when the contexts of $X$ are pairwise incomparable (for instance the first hits of a test),
   whatever the sets $A(x)$.
3. It is the case when $X=\{z_{1:k_1},z_{1:k_2},\dots\}$ are cut points of one sequence $z$ with
   $k_{i+1}\ge k_i+m$ and $z_{k_i+1:k_i+m}\notin A(z_{1:k_i})$: an attack block that differs from the world's own
   continuation.
4. It can fail otherwise. If $U$ is universal, resources are unbounded, $x\in X$, $y\in A(x)$ and $x'=xyu\in X$ with $y'\in A(x')$, there is
   a word $p$ with $\mu(x)=\mu(x')=2^{-|p|}$ for $F=[p]$. In general the constraint is $\sum_{x\in X'}\mu(x)\le B$
   for every $X'\subseteq X$ on which the strings $xy$ are pairwise incomparable.
5. For the users there is no such issue: a world begins with at most one calling program and that program has
   one context, so the events "critical use at $x$" are disjoint, and $V(\mu)=\sum_p2^{-|p|}r(p)\,w(x_p)$ is the
   expected stake at which the attacker's block is returned.

*Proof.* (1) By `lem:basic`(i), $E(u)\cap E(u')=\emptyset$ for incomparable $u,u'$, so the sets $F\cap E(xy)$ are
pairwise disjoint subsets of $F$. (2) If $x,x'$ are incomparable so are $xy,x'y'$; if $x=x'$ and $y\ne y'$ have
the same length, $xy,xy'$ are incomparable. (3) For $i<j$, $x_j$ extends $x_id_i$ with $d_i=z_{k_i+1:k_i+m}$, and
$y\in A(x_i)$ has $|y|=|d_i|$, $y\ne d_i$; so $x_iy$ is incomparable with $x_j$ and with every extension of it.
(4) Take $p$ a program for the computable sequence $xyuy'0^\infty$; every input in $[p]$ prints $xy$ and $x'y'$.
The general constraint is (1) applied to $X'$. (5) Calling programs are prefix-free and each occurs in one pair
(`def:call`). $\square$

Item 4 is not an artefact: it is the situation of `prop:lineage`(b), where a context already contains an earlier
attack block. In all of Sections 1 to 5 and 10, (M1) is assumed.

### A2 (water-filling lemma). PROVED.

Let $X$ be countable, $B>0$, and for each $x$ let $f_x\colon[0,\infty)\to[0,\infty)$ be concave and differentiable
(one-sided at $0$) with $f_x(0)=0$. Suppose $\mu^*\colon X\to[0,\infty)$ and $\lambda>0$ satisfy

1. $\sum_x\mu^*(x)=B$;
2. $f_x'(\mu^*(x))=\lambda$ where $\mu^*(x)>0$, and $f_x'(0)\le\lambda$ where $\mu^*(x)=0$;
3. $\sum_xf_x(\mu^*(x))<\infty$.

Then $\sum_xf_x(\mu(x))\le\sum_xf_x(\mu^*(x))$ for every $\mu\ge0$ with $\sum_x\mu(x)\le B$. If each $f_x$ is
strictly concave or identically $0$, then $\mu^*$ is the only maximiser.

*Proof.* Concavity gives $f_x(t)\le f_x(t^*)+f_x'(t^*)(t-t^*)$ for $t,t^*\ge0$. Take $t^*=\mu^*(x)$. If
$\mu^*(x)>0$ the right side is $f_x(\mu^*(x))+\lambda(t-\mu^*(x))$. If $\mu^*(x)=0$ it is $f_x'(0)\,t\le\lambda t$,
because $t\ge0$. So for every $x$ and every $t\ge0$
$$f_x(t)\ \le\ f_x(\mu^*(x))+\lambda\,(t-\mu^*(x)).\tag{$*$}$$
Put $t=\mu(x)$ and sum. The three series on the right converge absolutely by 1, 3 and $\sum\mu\le B$, the terms on
the left are nonnegative, so $\sum_xf_x(\mu(x))\le\sum_xf_x(\mu^*(x))+\lambda(\sum_x\mu(x)-B)\le\sum_xf_x(\mu^*(x))$.
If equality holds then $(*)$ is an equality at every $x$. For strictly concave $f_x$ the concavity inequality is
strict for $t\ne t^*$, so $\mu(x)=\mu^*(x)$. For $f_x\equiv0$, condition 2 forces $\mu^*(x)=0$ (as $\lambda>0$), and
$(*)$ reads $0\le\lambda\mu(x)$, an equality only if $\mu(x)=0$. $\square$

---

## 1. The optimal allocation for the sampling predictor

For $\lambda>0$ let
$$\beta(\lambda)=\sum_xO(x)\Bigl(\sqrt{\rho(x)/\lambda}-1\Bigr)_+ .$$

### A3 (square-root law; existence and uniqueness, also for infinitely many contexts). PROVED.

Assume (M1) to (M3) and (S).

1. Each term of $\beta(\lambda)$ is at most $s(x)/(4\lambda)$, so $\beta(\lambda)\le S/(4\lambda)<\infty$.
2. $\beta$ is continuous and nonincreasing on $(0,\infty)$, strictly decreasing on $(0,\bar\rho)$, zero exactly
   for $\lambda\ge\bar\rho$, and $\beta(\lambda)\to\infty$ as $\lambda\to0$.
3. For every $B>0$ there is exactly one $\lambda_B\in(0,\bar\rho)$ with $\beta(\lambda_B)=B$ (the **budget
   equation**). $B\mapsto\lambda_B$ is continuous and strictly decreasing, with $\lambda_B\to\bar\rho$ as $B\to0$
   and $\lambda_B\to0$ as $B\to\infty$.
4. The allocation
   $$\mu^*_B(x)=O(x)\Bigl(\sqrt{\rho(x)/\lambda_B}-1\Bigr)_+$$
   is the unique maximiser of $V$ over $\{\mu\ge0:\sum\mu\le B\}$. Its shares and value are
   $$w^*(x)=\Bigl(1-\sqrt{\lambda_B/\rho(x)}\Bigr)_+,\qquad
   V^*(B)=\sum_{x:\,\rho(x)>\lambda_B}s(x)\Bigl(1-\sqrt{\lambda_B/\rho(x)}\Bigr).$$
5. $V^*$ is concave and differentiable in $B$ with $dV^*/dB=\lambda_B$: the multiplier is the stake captured per
   unit of additional attacker mass.

So the expected law is correct as stated.

*Proof.* (1) On $\{\rho>\lambda\}$ the term is $\sqrt{sO/\lambda}-O=a^2-(\sqrt O-a)^2\le a^2$ with
$a=\sqrt{s/(4\lambda)}$. (2) Each term is continuous and nonincreasing in $\lambda$ and, on $[\lambda_0,\infty)$,
bounded by the summable $s(x)/(4\lambda_0)$; so the series converges uniformly there and $\beta$ is continuous.
For $\lambda<\lambda'<\bar\rho$ pick $x$ with $\rho(x)>\lambda'$; its term is strictly smaller at $\lambda'$.
$\beta(\lambda)=0$ iff every term vanishes iff $\lambda\ge\bar\rho$. For $x_0$ with $s(x_0)>0$,
$\beta(\lambda)\ge O(x_0)(\sqrt{\rho(x_0)/\lambda}-1)\to\infty$. (3) On $(0,\bar\rho)$, $\beta$ is continuous,
strictly decreasing, unbounded above, and has infimum $0$: if $\bar\rho<\infty$ by continuity at $\bar\rho$, if
$\bar\rho=\infty$ by (1). So it is a bijection onto $(0,\infty)$ with continuous strictly decreasing inverse.
(4) Apply A2 with $f_x(t)=s(x)\,t/(t+O(x))$. It is concave, strictly if $s(x)>0$ and identically $0$ otherwise;
$f_x'(t)=sO/(t+O)^2$ and $f_x'(0)=\rho(x)$. Condition 1 is (3). For $\rho(x)>\lambda_B$,
$\mu^*+O=O\sqrt{\rho/\lambda_B}$ and $f_x'(\mu^*)=sO\lambda_B/(O^2\rho)=\lambda_B$; for $\rho(x)\le\lambda_B$,
$\mu^*=0$ and $f_x'(0)=\rho\le\lambda_B$. Condition 3 holds since $V\le S$. The shares follow from
$w=\mu/(\mu+O)$. (5) For $B<B'$, $(*)$ with $\mu^*=\mu^*_B$, $\mu=\mu^*_{B'}$, summed, gives
$V^*(B')-V^*(B)\le\lambda_B(B'-B)$; exchanging roles gives $V^*(B')-V^*(B)\ge\lambda_{B'}(B'-B)$. With the
continuity and monotonicity of $\lambda_B$ this is concavity and the derivative. $\square$

### A4 (without (S) the optimum can fail to exist). PROVED.

1. $X=\mathbb N$, $s\equiv1$, $O\equiv1$: $\sup V=B$ and it is not attained.
2. $X=\mathbb N$, $s(x_k)=k$, $O\equiv1$: $\sup V=\infty$.

*Proof.* (1) $V(\mu)=\sum\mu/(1+\mu)<\sum\mu\le B$ for $\mu\ne0$, and spreading $B$ evenly over $N$ contexts gives
$B/(1+B/N)\to B$. (2) All mass on $x_k$ gives $kB/(B+1)$. $\square$

(S) is sufficient, not necessary: the proof of A3 uses only that $\beta$ is finite and continuous and that
$V(\mu^*)<\infty$.

### A5 (the solution on its active set). PROVED.

Let $A=\{x:\rho(x)>\lambda_B\}$ be the set of attacked contexts. Then $O(A)<S/\lambda_B$,
$\Sigma_A:=\sum_{x\in A}\sqrt{s(x)O(x)}<S/\sqrt{\lambda_B}$, and
$$\sqrt{\lambda_B}=\frac{\Sigma_A}{B+O(A)},\qquad V^*(B)=s(A)-\frac{\Sigma_A^2}{B+O(A)}\ \ge\ s(A)\,\frac{B}{B+O(A)} ,$$
with equality in the last step iff $\rho$ is constant on $A$. Membership is decided by the budget:
$$x\in A\iff B>\beta(\rho(x))=\sum_{x':\,\rho(x')>\rho(x)}O(x')\Bigl(\sqrt{\rho(x')/\rho(x)}-1\Bigr).$$
For finite $X$ ordered with $\rho(x_1)\ge\rho(x_2)\ge\dots$ this says: $A=\{x_1,\dots,x_K\}$, where $K$ is the
largest $k$ with $\sqrt{\rho(x_k)}\,\bigl(B+\sum_{i\le k}O(x_i)\bigr)>\sum_{i\le k}\sqrt{s(x_i)O(x_i)}$.

*Proof.* On $A$, $O<s/\lambda_B$ and $\sqrt{sO}<s/\sqrt{\lambda_B}$. The budget equation reads
$B=\lambda_B^{-1/2}\Sigma_A-O(A)$. $V^*=\sum_As-\sqrt{\lambda_B}\sum_As/\sqrt\rho=s(A)-\sqrt{\lambda_B}\,\Sigma_A$.
Cauchy and Schwarz give $\Sigma_A^2\le s(A)O(A)$, with equality iff $s/O$ is constant on $A$. Since $\beta$ is
strictly decreasing on $(0,\bar\rho)$ and vanishes from $\bar\rho$ on, $\rho(x)>\lambda_B$ iff $\beta(\rho(x))<B$;
the terms of $\beta(\rho(x))$ with $\rho(x')\le\rho(x)$ vanish. The finite form is the same inequality multiplied
out. $\square$

### A6 (closed form: two classes of uses). PROVED.

Let $X=X_1\cup X_2$ with $\rho\equiv\rho_i$ on $X_i$, $\rho_1>\rho_2>0$, $O_i=O(X_i)<\infty$, and
$t=\sqrt{\rho_2/\rho_1}\in(0,1)$. Put $B_c=O_1(1/t-1)$.

* If $B\le B_c$: only $X_1$ is attacked, $\mu^*(x)=B\,O(x)/O_1$ there,
  $$\lambda_B=\rho_1\Bigl(\frac{O_1}{B+O_1}\Bigr)^2,\qquad w^*=\frac{B}{B+O_1}\ \text{on }X_1,\qquad V^*=s(X_1)\frac{B}{B+O_1}.$$
* If $B>B_c$: both are attacked,
  $$\sqrt{\lambda_B}=\frac{O_1\sqrt{\rho_1}+O_2\sqrt{\rho_2}}{B+O_1+O_2},\qquad
  w^*_1=\frac{B+O_2(1-t)}{B+O_1+O_2},\qquad w^*_2=\frac{B-O_1(1/t-1)}{B+O_1+O_2}.$$
* The attacker has the majority on $X_1$ iff $B>O_1+O_2\,(2t-1)_+$, and on $X_2$ iff $B>O_2+O_1(2/t-1)$.

So if the stakes ratio is at least four, $\rho_1\ge4\rho_2$, the majority at the high class costs exactly its
background $O_1$ and is reached while the low class is still untouched. If $\rho_1<4\rho_2$ it costs more,
$O_1+O_2(2t-1)$, because the optimal attacker starts spending on the low class before it has half of the high one.

*Proof.* By A5 with $A=X_1$: $\Sigma_A=O_1\sqrt{\rho_1}$, valid while $\lambda_B\ge\rho_2$, that is
$O_1/(B+O_1)\ge t$. Otherwise $A=X$ and $\Sigma_A=O_1\sqrt{\rho_1}+O_2\sqrt{\rho_2}$; then
$w_i^*=1-\sqrt{\lambda_B/\rho_i}$ gives the two formulas. In the second regime $w_1^*>\frac12$ iff
$B>O_1+O_2(2t-1)$; in the first iff $B>O_1$. If $2t\le1$ then $B_c\ge O_1$ and the two conditions combine to
$B>O_1$; if $2t>1$ then $B_c<O_1<O_1+O_2(2t-1)$ and the majority is reached in the second regime.
$w_2^*>\frac12$ iff $B>O_2+O_1(2/t-1)$, which exceeds $B_c$. $\square$

### A7 (closed form: stakes with a power-law tail, dyadic classes). PROVED.

Let $X=\bigcup_{k\ge0}X_k$ with $\rho\equiv\rho_02^k$ on $X_k$ and $O(X_k)=O_02^{-\gamma k}$, $\gamma>1$. (For
instance users are a fixed share of every context, the stake on $X_k$ is $2^k$, and the mass of the uses with
stake at least $n$ falls like $n^{-\gamma}$.) Then $S=\rho_0O_0/(1-2^{1-\gamma})<\infty$. Put
$$u=2^{-\gamma},\qquad c_\gamma=\frac{1-u}{1-\sqrt2\,u}>1,\qquad O_{\ge K}=\sum_{k\ge K}O(X_k)=\frac{O_0u^K}{1-u},\qquad B_0=(\sqrt2c_\gamma-1)\,O_{\ge0}.$$

1. For $0<B\le B_0$ there is exactly one integer $K=K(B)\ge0$ with
   $$c_\gamma-1<\frac{B}{O_{\ge K}}\le\sqrt2\,c_\gamma-1 .$$
   For $B>B_0$ put $K=0$.
2. The attacked set is $\bigcup_{k\ge K}X_k$, and with $\theta=c_\gamma O_{\ge K}/(B+O_{\ge K})$,
   $$\lambda_B=\rho_02^K\theta^2,\qquad w^*=1-\theta\,2^{-(k-K)/2}\ \text{on }X_k\ (k\ge K),\qquad
   \frac{V^*}{S}=2^{-(\gamma-1)K}\Bigl(1-\theta\,\frac{1-2u}{1-\sqrt2u}\Bigr).$$
   For $B\le B_0$, $\theta\in[2^{-1/2},1)$.
3. For $B\le B_0$ the attacker has the majority exactly on the classes $k\ge K+2$. The backgrounds of the
   attacked set and of the majority set are tied to the budget:
   $$\frac{B}{\sqrt2c_\gamma-1}\le O_{\ge K}<\frac{B}{c_\gamma-1},\qquad O_{\ge K+2}=4^{-\gamma}O_{\ge K}.$$
   At the top the share tends to $1$: $w^*\ge1-2^{-(k-K)/2}$ on $X_k$.

*Proof.* $(\sqrt2c_\gamma-1)/(c_\gamma-1)=1/u$: indeed $c_\gamma-1=u(\sqrt2-1)/(1-\sqrt2u)$ and
$\sqrt2c_\gamma-1=(\sqrt2-1)/(1-\sqrt2u)$. Since $O_{\ge K}/O_{\ge K+1}=1/u$, the intervals
$\bigl((c_\gamma-1)O_{\ge K},(\sqrt2c_\gamma-1)O_{\ge K}\bigr]$, $K\ge0$, partition $(0,B_0]$; this is (1). Let
$\lambda=\rho_02^K\theta^2$. For $B\le B_0$ the choice of $K$ gives $2^{-1/2}\le\theta<1$, so
$\rho_02^{K-1}\le\lambda<\rho_02^K$ and $\{\rho>\lambda\}=\bigcup_{k\ge K}X_k$; for $B>B_0$ and $K=0$,
$\theta<2^{-1/2}$ and $\{\rho>\lambda\}=X$. In both cases
$$\beta(\lambda)=\sum_{k\ge K}O_0u^k\Bigl(\frac{2^{(k-K)/2}}{\theta}-1\Bigr)=\frac{O_0u^K}{\theta(1-\sqrt2u)}-\frac{O_0u^K}{1-u}=O_{\ge K}\Bigl(\frac{c_\gamma}{\theta}-1\Bigr)=B ,$$
so $\lambda=\lambda_B$ by A3(3), and $w^*=1-\sqrt{\lambda_B/\rho}$. With $s(X_k)=\rho_0O_0(2u)^k$:
$V^*=\sum_{k\ge K}s(X_k)(1-\theta2^{-(k-K)/2})=\rho_0O_0(2u)^K\bigl(\frac1{1-2u}-\frac{\theta}{1-\sqrt2u}\bigr)$ and
$(2u)^K=2^{-(\gamma-1)K}$. (3) $w^*>\frac12$ on $X_k$ iff $\theta2^{-(k-K)/2}<\frac12$; for $k=K+1$ the left side
is at least $\frac12$, for $k\ge K+2$ it is below $\frac12$, for $k=K$ it is $\theta\ge2^{-1/2}$. $\square$

### A8 (closed form: Pareto tail, continuum of contexts). PROVED for the continuum model; as a description of a countable $X$ it is HEURISTIC.

Replace the sums over $X$ by integrals against a background measure $O$ on a measurable space, let allocations
be densities $\varphi\ge0$ with $\int\varphi\,dO\le B$ and $V=\int\rho\,\varphi/(1+\varphi)\,dO$, and let
$O(\{\rho>t\})=\bar O\,(t/\rho_0)^{-\gamma}$ for $t\ge\rho_0$, with $\rho\ge\rho_0$ everywhere and $\gamma>1$. Then
$S=\bar O\rho_0\gamma/(\gamma-1)$, the optimum is $\varphi^*=(\sqrt{\rho/\lambda_B}-1)_+$ (unique up to $O$-null
sets), and for $B\le\bar O/(2\gamma-1)$:

$$O(\{\rho>\lambda_B\})=(2\gamma-1)\,B,\qquad \lambda_B=\rho_0\Bigl(\frac{(2\gamma-1)B}{\bar O}\Bigr)^{-1/\gamma},$$
$$O(\{\text{majority}\})=O(\{\rho>4\lambda_B\})=4^{-\gamma}(2\gamma-1)\,B,\qquad
\frac{V^*}{s(\{\rho>\lambda_B\})}=\frac1{2\gamma-1},\qquad
\frac{V^*}{S}=\frac1{2\gamma-1}\Bigl(\frac{(2\gamma-1)B}{\bar O}\Bigr)^{(\gamma-1)/\gamma}.$$

So the attacker attacks a top slice whose background is $(2\gamma-1)$ times its own weight, has the majority on a
top slice whose background is $4^{-\gamma}(2\gamma-1)$ times its weight, and captures the fraction $1/(2\gamma-1)$
of the stake in the slice it attacks. The share of the *total* stake it captures scales like
$B^{(\gamma-1)/\gamma}$: for a heavy tail ($\gamma$ near $1$) it is nearly independent of how small $B$ is.

*Proof.* The inequality $(*)$ of A2 holds pointwise and integrates, which gives optimality and uniqueness as in
A2. For $\lambda\ge\rho_0$,
$\int_{\rho>\lambda}\sqrt{\rho/\lambda}\,dO=\gamma\bar O\rho_0^\gamma\lambda^{-1/2}\int_\lambda^\infty t^{-\gamma-1/2}dt=O(\{\rho>\lambda\})\,\gamma/(\gamma-\tfrac12)$,
so $\beta(\lambda)=O(\{\rho>\lambda\})/(2\gamma-1)$; the condition $B\le\bar O/(2\gamma-1)$ is $\lambda_B\ge\rho_0$.
Likewise $s(\{\rho>\lambda\})=\gamma\bar O\rho_0^\gamma\lambda^{1-\gamma}/(\gamma-1)$ and
$\int_{\rho>\lambda}\sqrt{\lambda\rho}\,dO=\gamma\bar O\rho_0^\gamma\lambda^{1-\gamma}/(\gamma-\frac12)$, whose
difference is $s(\{\rho>\lambda\})/(2\gamma-1)$. $\square$

The reason for the label: a countable $X$ has atoms, and A7 is the exact discrete statement. A fine discretisation
agreed with these formulas to five digits.

---

## 2. Consequences

### A9 (where the attacker has the majority; the top uses as the budget varies). PROVED.

For the optimal allocation of A3:

1. $x$ is attacked iff $\rho(x)>\lambda_B$ iff $B>\beta(\rho(x))$.
2. The attacker has the majority at $x$ ($w^*>\frac12$, equivalently $\mu^*>O$) iff $\rho(x)>4\lambda_B$ iff
   $B>\beta(\rho(x)/4)$. For $\theta\in(0,1)$: $w^*(x)>\theta$ iff $\rho(x)>\lambda_B/(1-\theta)^2$ iff
   $B>\beta\bigl((1-\theta)^2\rho(x)\bigr)$.
3. At fixed $B$, $w^*(x)$ is a nondecreasing function of $\rho(x)$ alone. In $B$, $\mu^*_B(x)$ and $w^*(x)$ are
   nondecreasing, and $w^*(x)\to1$ as $B\to\infty$ wherever $s(x)>0$.
4. Contexts are attacked in decreasing order of $\rho=s/O$, not of the stake $r$. A use with a larger stake and a
   smaller $\rho$ exists whenever $k=C/O$ varies: $r(x_1)=10$, $k(x_1)=0.01$, $r(x_2)=1$, $k(x_2)=1$.
5. *Small budgets.* If $\bar\rho$ is attained, $X_{\rm top}=\{\rho=\bar\rho\}$ and
   $\rho_2=\sup\{\rho(x):\rho(x)<\bar\rho\}<\bar\rho$, then for $B\le O(X_{\rm top})\bigl(\sqrt{\bar\rho/\rho_2}-1\bigr)$
   the whole budget goes to $X_{\rm top}$, in proportion to $O$, with share $B/(B+O(X_{\rm top}))$ at each of
   its uses. The majority there is reached within this phase iff $\bar\rho>4\rho_2$.
6. *Robustness.* If $\mu\ge c\,\mu^*_B$ pointwise for some $c\in(0,1]$ then $V(\mu)\ge c\,V^*(B)$.

*Proof.* (1) is A5. (2) $1-\sqrt{\lambda_B/\rho}>\theta$ iff $\rho>\lambda_B/(1-\theta)^2$, and
$\lambda_B<(1-\theta)^2\rho(x)$ iff $B>\beta((1-\theta)^2\rho(x))$ because $\beta$ is strictly decreasing on
$(0,\bar\rho)$, zero beyond, and $B>0$. (3) $\lambda_B$ decreases in $B$ to $0$. (4) $\rho=rk$. (5) For
$\lambda\in[\rho_2,\bar\rho)$, $\beta(\lambda)=O(X_{\rm top})(\sqrt{\bar\rho/\lambda}-1)$, and
$O(X_{\rm top})=s(X_{\rm top})/\bar\rho<\infty$; this equals $B$ with $\lambda\ge\rho_2$ iff $B$ is at most the
stated bound. Majority needs $B>O(X_{\rm top})$, possible in the phase iff $\sqrt{\bar\rho/\rho_2}>2$.
(6) $t\mapsto t/(t+O)$ is increasing and concave with value $0$ at $0$, so $w(c\mu^*)\ge c\,w(\mu^*)$. $\square$

### A10 (the stake-weighted share captured). PROVED.

1. For every allocation, $V(\mu)\le\min(S,\,B\bar\rho)$.
2. $V^*(B)/B\to\bar\rho$ as $B\to0$, and $V^*(B)\to S$ as $B\to\infty$.
3. For a class $W$ contained in the attacked set, the share of its stake that is captured is
   $$\sigma_W:=\frac{\sum_Ws\,w^*}{s(W)}=1-\sqrt{\lambda_B}\,\frac{\sum_W\sqrt{sO}}{s(W)}\ \ge\ 1-\sqrt{\lambda_B/\bar\rho_W},\qquad\bar\rho_W=\frac{s(W)}{O(W)} .$$
   For any $W$, $\sigma_W\ge1-\sqrt{\lambda_B/\inf_W\rho}$.

*Proof.* (1) $w\le1$ and $w\le\mu/O$. (2) All mass on one $x$ gives $V^*\ge B\rho(x)/(1+B/O(x))$, so
$\liminf V^*/B\ge\rho(x)$ for each $x$; the upper bound is (1). $V^*\to S$ by dominated convergence, since
$w^*\to1$ termwise. (3) $w^*=1-\sqrt{\lambda_B/\rho}$ on $W$, $s/\sqrt\rho=\sqrt{sO}$, and Cauchy and Schwarz.
$\square$

### A11 (comparison with the proportional strategy of the note). PROVED.

The seeker of `thm:critical`(a), aimed at a class $W$ with $0<C(W)<\infty$, realises (up to its factor $\frac12$)
the allocation $\mu^{\rm pr}(x)=B\,C(x)/C(W)$ on $W$ and $0$ elsewhere. Let $E_W[\rho]=\sum_WC\rho/C(W)$ and
$k_{\max}=\sup_Wk$.

1. $w^{\rm pr}(x)=\dfrac{Bk(x)}{Bk(x)+C(W)}$ on $W$. It has the majority at $x$ iff $k(x)>C(W)/B$. Its share does
   not depend on the stake.
2. $\dfrac{B\,E_W[\rho]}{1+Bk_{\max}/C(W)}\le V(\mu^{\rm pr})\le B\,E_W[\rho]$.
3. If $k_{\max}<\infty$ and $E_W[\rho]>0$: $\lim_{B\to0}V^*(B)/V(\mu^{\rm pr})=\bar\rho/E_W[\rho]$. The gain from
   concentrating, for a small budget, is the ratio of the largest $\rho$ to its user-weighted average over $W$.
4. $\mu^{\rm pr}$ is optimal if $k$ and $r$ are constant on $W$ and $\rho\le\rho_W\bigl(O(W)/(B+O(W))\bigr)^2$
   off $W$ (where $\rho_W$ is the value of $\rho$ on $W$); in general it is not.
5. The loss is unbounded: there are instances with $V^*(B)/V(\mu^{\rm pr})\ge1/(2\varepsilon)$ for every
   $\varepsilon\in(0,1)$.

*Proof.* (1) $\mu/(\mu+O)$ with $\mu=BC/C(W)$. (2) $V=\sum_Ws\,Bk/(Bk+C(W))$ and $sk=C\rho$; bound the
denominator between $C(W)$ and $C(W)+Bk_{\max}$. (3) from (2) and A10(2). (4) Then $\mu^{\rm pr}=B\,O(x)/O(W)$ on
$W$, which satisfies the conditions of A2 with $\sqrt\lambda=O(W)\sqrt{\rho_W}/(B+O(W))$. (5) $X=W=\{x_1,x_2\}$
with $C(x_1)=O(x_1)=\varepsilon$, $r(x_1)=\varepsilon^{-2}$, $C(x_2)=O(x_2)=r(x_2)=1$, $B=\varepsilon$. Then
$k\equiv1$, $w^{\rm pr}\equiv\varepsilon/(1+2\varepsilon)$ and
$V(\mu^{\rm pr})=(1+\varepsilon)/(1+2\varepsilon)<1$, while all mass on $x_1$ gives
$\varepsilon^{-1}\cdot\frac12$. $\square$

---

## 3. The lump picture as a theorem

"Majority at $x$" means $w(x)>\frac12$, that is $\mu(x)>O(x)$. Two separate questions: what an attacker of weight
$B$ *can* do (A12), and what the stake-maximising attacker of A3 *does* (A13).

### A12 (lump theorem: feasibility, and its converse). PROVED.

Assume (M1) to (M3). Let $M,W\subseteq X$ be nonempty.

1. *Exact condition.* There is an allocation with $\sum\mu\le B$ and the majority at every $x\in M$ iff
   $$B>O(M).$$
   For $\theta\in(0,1)$: there is one with $w\ge\theta$ on $M$ iff $B\ge\frac{\theta}{1-\theta}\,O(M)$.
2. *The lump.* If $B\ge c\cdot O(W)$ for a constant $c>0$, the allocation $\mu(x)=B\,O(x)/O(W)$ on $W$ has
   $$w(x)=\frac{B}{B+O(W)}\ \ge\ \frac{c}{1+c}\qquad\text{at every use in }W .$$
   With $c>1$ this is a majority at every use of $W$; with $c=9$ it is a share of at least $90\%$.
3. *Converse.* If an allocation has $w\ge\theta$ at every $x$ of some $M\subseteq W$, then
   $$B\ \ge\ \frac{\theta}{1-\theta}\,O(M)\ \ge\ \frac{\theta}{1-\theta}\,\max\Bigl(\frac{C(M)}{k_{\max}(W)},\ \frac{s(M)}{\rho_{\max}(W)}\Bigr),\qquad k_{\max}(W)=\sup_W\frac CO,\quad\rho_{\max}(W)=\sup_W\frac sO .$$
4. *Most of a class.* For $\varepsilon\in[0,1)$ let
   $$\Phi^C_W(\varepsilon)=\inf\{O(M):M\subseteq W,\ C(M)\ge(1-\varepsilon)C(W)\},\qquad
   \Phi^s_W(\varepsilon)=\inf\{O(M):M\subseteq W,\ s(M)\ge(1-\varepsilon)s(W)\}.$$
   The attacker can hold the majority at uses making up at least the share $1-\varepsilon$ of $W$ by prior mass iff
   $B>\Phi^C_W(\varepsilon)$, and by stake-weighted mass iff $B>\Phi^s_W(\varepsilon)$. Moreover
   $$\frac{(1-\varepsilon)\,C(W)}{k_{\max}(W)}\le\Phi^C_W(\varepsilon)\le O(W),\qquad
   \frac{(1-\varepsilon)\,s(W)}{\rho_{\max}(W)}\le\Phi^s_W(\varepsilon)\le O(W).$$
   If $k$ is constant on $W$ then $(1-\varepsilon)O(W)\le\Phi^C_W(\varepsilon)\le O(W)$; if $\rho$ is constant on
   $W$ the same holds for $\Phi^s_W$.
5. The two meanings of "most" are unrelated in general: for $W=\{x_1,x_2\}$ with $C(x_1)=0.9$, $s(x_1)=1$,
   $O(x_1)=\delta$ and $C(x_2)=0.1$, $s(x_2)=99$, $O(x_2)=1$, one has $\Phi^C_W(\frac12)=\delta$ and
   $\Phi^s_W(\frac12)=1$; exchanging the two backgrounds exchanges the two values.

*Proof.* (1) $w(x)\ge\theta$ iff $\mu(x)\ge\frac\theta{1-\theta}O(x)$, and $w(x)>\frac12$ iff $\mu(x)>O(x)$. Summing
over $M$ and using (M1) gives necessity (a sum of termwise strict inequalities between convergent series is
strict). Conversely take $\mu=(B/O(M))\,O$ on $M$. (2) is a computation. (3) is (1) with
$O(M)=\sum_MC/k\ge C(M)/k_{\max}$ and $O(M)=\sum_Ms/\rho\ge s(M)/\rho_{\max}$. (4) If the majority is held on an
admissible $M$ then $B>O(M)\ge\Phi$. If $B>\Phi$ there is, by the definition of the infimum, an admissible $M$
with $O(M)<B$; apply (1). The bounds are (3) and the choice $M=W$. If $k\equiv k_0$ on $W$ then
$O(M)=C(M)/k_0\ge(1-\varepsilon)C(W)/k_0=(1-\varepsilon)O(W)$. (5) Any $M$ with $C(M)\ge0.5$ contains $x_1$, and
$\{x_1\}$ suffices; any $M$ with $s(M)\ge50$ contains $x_2$, and $\{x_2\}$ suffices. $\square$

**Reading.** This is the lump picture, with two corrections. The lump that has to be outweighed on a class $W$ is
its *background* $O(W)$, the mass of everything else that prints those contexts and goes on, not the mass $C(W)$
of the worlds that make the uses. And the condition is two-sided: with $B\ge c\,O(W)$ the attacker has the share
$c/(1+c)$ at every use of $W$, and with $B\le O(M)$ it cannot have the majority on all of $M$ by any allocation.
The stake does not occur in A12: it decides where the attacker wants to be (A13), not what winning there costs.

### A13 (the stake-maximising attacker on a top class). PROVED.

Assume (M1) to (M3) and (S). For $t>0$ let $W_t=\{x:\rho(x)\ge t\}$, assumed nonempty, $t_W=\inf_{W_t}\rho\ge t$,
$N_t=\{x:t_W/4<\rho(x)<t_W\}$ and $\bar\rho_W=s(W_t)/O(W_t)$.

1. If $B>\beta(t_W/4)$, the optimal allocation has the majority at every use of $W_t$. If $B\le\beta(t_W/4)$ and
   the infimum $t_W$ is attained at $x_0$, it does not have the majority at $x_0$.
2. $\displaystyle O(W_t)\ \le\ \beta(t_W/4)\ \le\ \Bigl(2\sqrt{\bar\rho_W/t_W}-1\Bigr)O(W_t)+O(N_t).$
3. Hence: if $B>\bigl(2\sqrt{\bar\rho_W/t_W}-1\bigr)O(W_t)+O(N_t)$, the stake-maximising attacker has the majority
   at every use of the top class; if $B\le O(W_t)$, no allocation has. The constant
   $2\sqrt{\bar\rho_W/t_W}-1$ is $1$ when $\rho$ is constant on $W_t$.
4. In general the majority set of the optimal attacker is $\{\rho>4\lambda_B\}$, so it holds the majority on the
   share $C(W\cap\{\rho>4\lambda_B\})/C(W)$ of a class $W$ by prior mass and
   $s(W\cap\{\rho>4\lambda_B\})/s(W)$ by stake.

*Proof.* (1) By A9(2) the majority at $x$ is equivalent to $\rho(x)>4\lambda_B$, and $\lambda_B<t_W/4$ iff
$B>\beta(t_W/4)$. (2) $\beta(t_W/4)=\sum_{\rho>t_W/4}O\,(2\sqrt{\rho/t_W}-1)$, and $\{\rho>t_W/4\}=W_t\cup N_t$.
On $W_t$ each factor is at least $1$, on $N_t$ it lies in $(0,1)$; this gives the lower bound and the term
$O(N_t)$. On $W_t$, $\sum(2\sqrt{sO/t_W}-O)\le2\sqrt{s(W_t)O(W_t)/t_W}-O(W_t)$ by Cauchy and Schwarz. (3) from
(1), (2) and A12(1). (4) is A9(2). $\square$

**Reading.** The optimiser does take the majority at the top class once its weight exceeds a constant times that
class's background, plus the background of the uses whose $\rho$ is within a factor four below. The extra cost
over the bare $O(W_t)$ of A12 is the price of also being optimal elsewhere. Its share at a use is
$1-\sqrt{\lambda_B/\rho(x)}$: at least $90\%$ exactly where $\rho(x)\ge100\lambda_B$.

---

## 4. The most-probable-block predictor

### A14 (MAP: a knapsack; greedy by stake per unit of mass needed). PROVED, except the hardness remark in item 3, which is KNOWN.

Model: for each $x$ let $\tau(x)\ge0$ be the mass the attacker must exceed, the largest mass of another block at
$x$ less whatever the background already puts on the attacker's block; the MAP predictor returns the attacker's
block iff $\mu(x)>\tau(x)$ (ties go against the attacker). Assume (M1). In the suggested model the background puts
nothing on the attacker's block and $2^{-m}O(x)\le\tau(x)\le O(x)$.

1. *Exact condition.* For nonempty $M$: the attacker can have its block returned at every $x\in M$ iff
   $\tau(M)<B$. So the best it can do is
   $$V_{\rm MAP}(B)=\sup\{s(M):\ \tau(M)<B\},$$
   a $0$-$1$ knapsack with values $s(x)$ and weights $\tau(x)$.
2. *Greedy.* Let $X$ be finite with $0<\tau(x)<B$ for all $x$ (contexts with $\tau\ge B$ can never be won and are
   dropped; contexts with $\tau=0$ are won for free). Order $X$ by density $d(x)=s(x)/\tau(x)$,
   $d(x_1)\ge d(x_2)\ge\dots$, let $G_j=\{x_1,\dots,x_j\}$ and let $j$ be the largest index with $\tau(G_j)<B$. If
   $j=|X|$ then $V_{\rm MAP}=S$. Otherwise
   $$s(G_j)\ \le\ V_{\rm MAP}(B)\ \le\ s(G_j)+d(x_{j+1})\bigl(B-\tau(G_j)\bigr)\ \le\ s(G_j)+s(x_{j+1}),$$
   so the greedy prefix is within one context's stake of the optimum, and
   $\max\bigl(s(G_j),s(x_{j+1})\bigr)\ge\frac12V_{\rm MAP}(B)$.
3. The greedy prefix alone can be arbitrarily bad ($(s,\tau)=(1.1,1)$ and $(10,10)$ with $B=10.5$), and finding
   the exact optimum of a $0$-$1$ knapsack is NP-hard (KNOWN; the bound in 2 is Dantzig's).
4. *Winner takes all.* A class $W$ is won entirely iff $B>\tau(W)$, and then its whole stake is captured, not a
   share of it. An attacker with $B\le\min_x\tau(x)$ gets nothing at all. Since $\tau\le O$, a majority under
   sampling at $M$ ($B>O(M)$) implies that $M$ can be won under MAP; the converse fails when the background is
   spread over many blocks.

*Proof.* (1) If $\mu>\tau$ on $M$ then $B\ge\mu(M)>\tau(M)$. If $\tau(M)<B$, choose $\delta(x)>0$ on $M$ with
$\sum\delta\le B-\tau(M)$ and put $\mu=\tau+\delta$. (2) $G_j$ is feasible. Let $M$ be feasible and
$d^*=d(x_{j+1})$. Then
$s(M)-s(G_j)=\sum_{M\setminus G_j}d\tau-\sum_{G_j\setminus M}d\tau\le d^*\bigl(\tau(M\setminus G_j)-\tau(G_j\setminus M)\bigr)=d^*(\tau(M)-\tau(G_j))<d^*(B-\tau(G_j))$,
because $d\le d^*$ off $G_j$ and $d\ge d^*$ on $G_j$. By maximality of $j$, $\tau(G_j)+\tau(x_{j+1})\ge B$, so
$d^*(B-\tau(G_j))\le d^*\tau(x_{j+1})=s(x_{j+1})$. Both $G_j$ and $\{x_{j+1}\}$ are feasible, which gives the factor
$\frac12$. (3) Greedy takes the first item, the second no longer fits, value $1.1$ against $10$. (4) is (1); the
bounds on $\tau$: the largest of at most $2^m-1$ other blocks carries at least $O/(2^m-1)$ and at most $O$.
$\square$

**Reading.** Under MAP the lump picture holds in its sharpest form: redirect more than $\tau(W)$ to $W$ and every
use in $W$ returns the attacker's block; redirect less than the smallest $\tau$ and nothing happens anywhere. The
lump is $\tau(W)$, between $2^{-m}O(W)$ and $O(W)$. Concentration is forced, since mass below the threshold is
wasted, and the best targets are those with the largest stake per unit of mass needed, $s/\tau$.

---

## 5. Repetition: three readings of "run more than $n$ times"

### A15 (reading (a): $n$ independent samples at the same context). PROVED.

Let the world at $x$ draw $n(x)\ge1$ independent samples from the predictor and let a takeover happen if at least
one is the attacker's block. Its probability is $1-(1-w(x))^{n(x)}=1-\bigl(O(x)/(\mu(x)+O(x))\bigr)^{n(x)}$, and the
objective is $V_n(\mu)=\sum_xs(x)\bigl[1-(O/(\mu+O))^{n}\bigr]$. Assume (M1), (M2) and
$S_n:=\sum_xn(x)s(x)<\infty$.

1. $V_n$ has the unique maximiser
   $$\mu^*(x)=O(x)\Bigl(\bigl(n(x)\rho(x)/\lambda\bigr)^{1/(n(x)+1)}-1\Bigr)_+ ,$$
   with $\lambda>0$ the unique solution of $\sum_x\mu^*(x)=B$. A context is attacked iff $n(x)\rho(x)>\lambda$,
   and the takeover probability there is $1-\bigl(\lambda/(n(x)\rho(x))\bigr)^{n(x)/(n(x)+1)}$.
2. *The lump shrinks by the factor $n$.* If $n(x)\equiv n$ on $M$: a takeover probability above $\frac12$ at every
   $x\in M$ is feasible iff
   $$B>(2^{1/n}-1)\,O(M),\qquad\frac{\ln2}{n}\le2^{1/n}-1\le\frac1n .$$
   If $B\ge c\,O(W)/n$, the allocation proportional to $O$ on $W$ gives takeover probability
   $1-(1+B/O(W))^{-n}\ge c/(1+c)$ at every use of $W$.
3. At fixed share $w$, the takeover probability is at least $1-e^{-nw}$; it exceeds $1-\delta$ once
   $n\ge\ln(1/\delta)/w$.

*Proof.* (1) $f_x(t)=s(1-(O/(t+O))^n)$ has $f_x'(t)=snO^n/(t+O)^{n+1}$, positive and decreasing, so $f_x$ is
strictly concave when $s>0$, and $f_x'(0)=n\rho$. Solving $f_x'=\lambda$ gives $(t+O)^{n+1}=O^{n+1}n\rho/\lambda$.
On $\{n\rho>\lambda\}$, $\mu^*\le O\,(n\rho/\lambda)^{1/(n+1)}\le O\,n\rho/\lambda=ns/\lambda$, so the budget
function is at most $S_n/\lambda$; it is continuous, strictly decreasing where positive, unbounded as
$\lambda\to0$ and tends to $0$, by the argument of A3(2),(3). A2 applies with $\sum f_x\le S$. Then
$(O/(\mu^*+O))^n=(\lambda/(n\rho))^{n/(n+1)}$. (2) $1-(1+\mu/O)^{-n}>\frac12$ iff $\mu>(2^{1/n}-1)O$; sum over $M$
as in A12(1). $(1+1/n)^n\ge2$ and $e^{(\ln2)/n}\ge1+(\ln2)/n$ give the two bounds. $(1+c/n)^n\ge1+c$ gives the
last claim. (3) $(1-w)^n\le e^{-nw}$. $\square$

**What it buys.** The attacker's mass at $x$ is used again at every draw, so $n$ draws multiply the marginal value
of mass at $x$ by $n$ (from $\rho$ to $n\rho$) and divide the lump needed for a takeover with probability one
half by between $n$ and $n/\ln2$. In this reading the answer to the question is yes in the strongest form: at
uses that are sampled $n$ times, a weight of $O(W)/n$ is enough.

### A16 (reading (b): $n$ uses in sequence along one world). PROVED.

Let $\xi$ be the mixture of any machine and bounds and $z$ an infinite sequence with $\xi(z)=\lim_k\xi(z_{1:k})>0$
(if $z$ has a $(T,L)$-program of length $\ell$ then $\xi(z)\ge2^{-\ell}$). Let the world consult the predictor at
$x_i=z_{1:k_i}$, $i=1,\dots,n$, with $k_{i+1}\ge k_i+m$; let $d_i=z_{k_i+1:k_i+m}$ be its own continuations and
$A_i\subseteq\{0,1\}^m\setminus\{d_i\}$ the takeover blocks. Assume the samples $Y_i$ are independent and that the
transcript stays $z$ until the first takeover. Let $a_k=\xi(z_{k+1}\mid z_{1:k})$.

1. $\displaystyle\sum_{i=1}^n\pi_m(A_i\mid x_i)\ \le\ \ln\frac{\xi(x_1)}{\xi(z)}\ \le\ \ell\ln2$.
2. The number of $i$ with $\pi_m(A_i\mid x_i)\ge\frac12$ is at most $\log_2\bigl(\xi(x_1)/\xi(z)\bigr)\le\ell$.
3. $\displaystyle\Pr[\text{no takeover at any of the $n$ uses}]\ \ge\ \prod_i\pi_m(d_i\mid x_i)\ \ge\ \frac{\xi(z)}{\xi(x_1)}\ \ge\ 2^{-\ell}$, whatever $n$ is.
4. *One attacker.* Let $F$ be a measurable set of inputs with $\lambda(F)=B$, let
   $\mu_i=\lambda\bigl(F\cap\bigcup_{y\in A_i}E(x_iy)\bigr)$, $w_i=\mu_i/Z_m(x_i)$ the probability that the sample
   at $x_i$ comes from one of these programs, and $R=B/\xi(z)\le B\,2^{\ell}$. Then
   $$\Pr[\text{some sample is supplied by }F]=1-\prod_{i=1}^n(1-w_i)\ \le\ 1-\Bigl(1+\frac Rn\Bigr)^{-n}\ <\ 1-e^{-R}\ \le\ \min(R,1).$$
   Equality holds in the first inequality if $Z_m(x_i)-\mu_i=\xi(z)$ and $\mu_i=B/n$ for all $i$. For one use the
   bound is $R/(1+R)$, and $1-e^{-R}\le2\cdot R/(1+R)$: any number of uses in sequence is worth at most a factor
   two over a single one. (Numerically the largest value of the ratio is $1.2985$, at $R\approx1.79$; that
   number is not proved here.)

*Proof.* The blocks $\{k_i,\dots,k_i+m-1\}$ are disjoint. As in `thm:budget`,
$\pi_m(d_i\mid x_i)\ge\xi(x_id_i)/\xi(x_i)=\prod_{k=k_i}^{k_i+m-1}a_k$ and
$\prod_{k\ge k_1}a_k=\xi(z)/\xi(x_1)$. (1) $\pi_m(A_i\mid x_i)\le1-\pi_m(d_i\mid x_i)\le-\sum_{k\text{ in block }i}\ln a_k$;
sum over disjoint blocks. (2) Each such $i$ has $\prod_{\text{block }i}a_k\le\pi_m(d_i\mid x_i)\le\frac12$, and the
product over all blocks is at least $\xi(z)/\xi(x_1)$. (3) Up to the first takeover the contexts are the $x_i$, so
the probability of none is $\prod_i(1-\pi_m(A_i\mid x_i))\ge\prod_i\pi_m(d_i\mid x_i)$, and all $a_k\le1$.
(4) By A1(3), $\sum_i\mu_i\le B$. The programs printing $x_id_i$ are not counted in $\mu_i$, so
$Z_m(x_i)-\mu_i\ge\xi(x_id_i)\ge\xi(z)$ and the odds $o_i=w_i/(1-w_i)=\mu_i/(Z_m(x_i)-\mu_i)$ satisfy
$\sum_io_i\le R$. Then $\prod(1-w_i)=1/\prod(1+o_i)\ge(1+R/n)^{-n}$ by the inequality of arithmetic and geometric
means, and $(1+R/n)^n<e^R$. For the factor two: $1-e^{-R}\le\min(R,1)\le2R/(1+R)$. $\square$

**What it buys.** Almost nothing. Each attack block that is not the world's continuation is refuted by the next
context, so mass spent at one use is gone at the next (A1(3)); the attacker's total over all $n$ uses is its
weight relative to the world's, $R=B/\xi(z)$, and the majority can be off the truth at no more than $\ell$ of the
$n$ uses. This reading needs the world to be within the predictor's bounds; if $\xi(z)=0$ nothing is bounded.

### A17 (reading (c): the returned block is run $n$ times). PROVED.

This changes only the stake.

1. If every stake is multiplied by $n$, then $\rho$ and $\lambda_B$ are multiplied by $n$, and $\mu^*_B$, all
   shares $w^*$ and all thresholds of A12 and A13 are unchanged; $V^*$ is multiplied by $n$.
2. If only a class $W$ has its stake multiplied by $n$, with $\rho\equiv\rho_W$ on $W$ before and
   $\rho\equiv\rho_R$ on the rest $R$, then by A6 the attacker puts its whole weight on $W$ as long as
   $B\le O(W)\bigl(\sqrt{n\rho_W/\rho_R}-1\bigr)$, and has the majority on $W$ iff
   $B>O(W)+O(R)\bigl(2\sqrt{\rho_R/(n\rho_W)}-1\bigr)_+$. For $n\ge4\rho_R/\rho_W$ this threshold is $O(W)$ and
   does not depend on $n$.
3. The feasibility condition of A12, $B>O(W)$, does not contain the stake at all.

*Proof.* (1) $\beta$ depends on $\rho/\lambda$ only. (2) is A6 with $\rho_1=n\rho_W$, $\rho_2=\rho_R$. (3) is
A12(1). $\square$

**What it buys.** A reason to be there, and nothing else: a larger $n$ makes the optimal attacker concentrate on
$W$ sooner and stay there longer, but the weight it needs to win at $W$ stays $O(W)$. Whether a higher stake
makes winning easier is therefore a question about how $O(W_n)$ falls with $n$ compared with what it costs to
aim at $W_n$; that is Sections 6 to 8.

---

## 6. Implementation in the toy: a weighted search

From here on $U$ is universal, resources are unbounded, and a call rule
$\mathcal C$ is fixed in which every calling program occurs in exactly one pair $(p,x_p)$.

**Codes.** $\bar e(j)$ for $j\ge1$ is the code of the note, $|\bar e(j)|=2\lfloor\log_2j\rfloor+3$, so
$n^{-2}/8\le2^{-|\bar e(n)|}<n^{-2}/2$. For an integer $j\in\mathbb Z$ let $\tilde e(j)$ be a sign bit followed by
$\bar e(|j|+1)$, so $|\tilde e(j)|\le2\log_2(|j|+1)+4$.

**Weights.** A weight is a function $g\ge0$ on the calling programs that is *lower semicomputable*: there is a
partial computable $(p,t)\mapsto g_t(p)$, defined at least for all calling programs $p$ and all $t\ge1$, with
nonnegative rational values, nondecreasing in $t$, with $\sup_tg_t(p)=g(p)$.
Put
$$G=\sum_p2^{-|p|}g(p),\qquad\Gamma_g(x)=\sum_{p:\,x_p=x}2^{-|p|}g(p),\qquad\bar g(x)=\frac{\Gamma_g(x)}{C(x)},$$
so $\sum_x\Gamma_g(x)=G$ and $\bar g(x)$ is the average weight of the users at $x$. For $g\equiv1$: $G=H_{\mathcal C}$,
$\Gamma_g=C$.

### A18 (weighted seeker). PROVED.

Let $g$ be a weight with $0<G<\infty$ and $P$ a payload with $|P(x)|\ge m$ at every context. There is a word $v_g$
such that for every integer $j$ with $2^{j-1}G\le1$ and every context $x$,
$$\lambda\bigl\{v_g\,\tilde e(j)\,\omega:\ x\,P(x)_{1:m}\sqsubseteq\mathrm{out}_U(v_g\tilde e(j)\omega)\bigr\}\ \ge\ 2^{-a}\,2^{j-1}\,\Gamma_g(x),\qquad a=|v_g|+|\tilde e(j)| .$$
With $j=j_G:=\lfloor\log_2(1/G)\rfloor+1$ one has $\frac12<2^{j-1}G\le1$, so the mass at $x$ is more than
$$\frac12\cdot2^{-a_g}\cdot\frac{\Gamma_g(x)}{G},\qquad a_g=|v_g|+|\tilde e(j_G)|\le|v_g|+2\log_2\bigl(|\log_2G|+2\bigr)+4 .$$
The stated constant is $\frac12$. Further:

1. *What is needed about $G$:* that it is finite, and an integer $j$ with $2^{1-j}\ge G$. $G$ need not be
   computable. A $j$ smaller than $j_G$ costs the factor $2^{j_G-j}$. If $G\le1$ one may take $j\ge1$ and the code
   $\bar e(j)$, as in `thm:search`.
2. *Uniformity:* there is a word $c_{\rm s}$, depending on $U$, $\mathcal C$ and $P$ only, such that
   $v_g=c_{\rm s}d_g$ works whenever $d_g$ is a self-delimiting description of a program computing $(p,t)\mapsto g_t(p)$.
   So $a_g\le|c_{\rm s}|+|d_g|+|\tilde e(j_G)|$: the length of a description of $g$, plus the bits that name a
   dyadic bound on $G$, plus a constant.
3. *Exactness and optimality when contexts are pairwise incomparable:* the programs beginning with
   $v_g\tilde e(j)$ that print $x$ then have mass exactly $2^{-a}2^{j-1}\Gamma_g(x)$, and no word $v$ has more than
   $2^{-|v|}\Gamma_g(x)/G$ at every context with $\Gamma_g(x)>0$. So $\frac12$ cannot be improved beyond $1$.

*Proof.* **The machine $R_g$.** It reads $\tilde e(j)$. It then works in stages $\tau=1,2,\dots$ and keeps a
finite list of *assigned intervals*, consecutive half-open intervals $[a,b)\subseteq[0,1)$ with rational end
points, the first starting at $0$, each labelled with a calling program. In stage $\tau$:

* it performs step $\tau$ of an enumeration of $\mathcal C$; for each pair $(p,x_p)$ enumerated so far it
  computes $g_\tau(p)$ and, if this exceeds the value $g^{\rm old}(p)$ last used for $p$ (initially $0$), it
  assigns the next interval, of length $2^{j-1-|p|}\bigl(g_\tau(p)-g^{\rm old}(p)\bigr)$ and with label $p$, and
  sets $g^{\rm old}(p)=g_\tau(p)$;
* then it applies the **reading rule** once. Let $D=[0.\omega_{1:n},\,0.\omega_{1:n}+2^{-n})$ be the half-open
  dyadic interval of the $n$ bits of the remaining input read so far ($D=[0,1)$ for $n=0$). (i) If $D$ lies in
  an assigned interval, with label $p$, the machine stops reading for good, prints $x_p$ and then $P(x_p)$, and
  does nothing else. (ii) Otherwise, if an end point of an assigned interval lies in the interior of $D$, it
  reads one more bit. (iii) Otherwise it reads nothing.

Whether a bit is read depends only on the bits read before and on the stage, so $R_g$ is a monotone machine. The
lengths assigned with label $p$ telescope to $2^{j-1-|p|}g(p)$, so the total length is $2^{j-1}G\le1$ and all
intervals lie in $[0,1)$. They are pairwise disjoint. The calling programs being prefix-free is not used here;
only $2^{j-1}G\le1$ is.

**What it reads.** Let $N_0$ be the countable set of $\omega$ that end in $1^\infty$; for $\omega\notin N_0$ the
point $y=\sum_n\omega_n2^{-n}$ lies in $D_n:=D(\omega_{1:n})$ for every $n$. Let $I=[a,b)$ be an assigned
interval with label $p$, $\omega\notin N_0$ with $y\in(a,b)$, and $n_1$ the least $n$ with $D_n\subseteq I$; it
exists because $D_n\subseteq[y-2^{-n},y+2^{-n})$.

* *No end point of any interval lies in $(a,b)$.* An end point of another interval $[a',b')$ inside $(a,b)$ would
  make the two intervals meet.
* *The machine never reads more than $n_1$ bits.* Once $n\ge n_1$, the interior of $D_n$ is inside $(a,b)$, so
  (ii) does not apply.
* *It reaches $n_1$ bits.* For $n<n_1$, $D_n=[l,u)$ contains $y$ and is not inside $I$, so $l<a$ or $u>b$; in the
  first case $a\in(l,u)$, in the second $b\in(l,u)$. So an end point of $I$ is in the interior of $D_n$. Also
  $D_n$ lies in no assigned interval $I'$: it would contain $y$, so $I'=I$. Hence at every stage after $I$ has
  been assigned, (i) does not apply and (ii) does, and a bit is read.
* *It prints.* With $n=n_1$ bits read and $I$ assigned, (i) applies at the next stage, and it can apply for no
  other interval.

So on every such $\omega$ the machine, after $\tilde e(j)$, reads exactly $\omega_{1:n_1}$ and prints $x_pP(x_p)$.
The map $\omega\mapsto y$ carries $\lambda$ to Lebesgue measure, so for each calling program $p$ this happens on a
set of measure at least $2^{j-1-|p|}g(p)$, and these sets are disjoint for different $p$. Summing over $p$ with
$x_p=x$: after $\tilde e(j)$, $R_g$ prints $x$ followed by $P(x)$ with probability at least $2^{j-1}\Gamma_g(x)$.
Let $v_g$ be a prefix word of $R_g$.

The half-open convention is what makes the third bullet work: with closed $D$, an $\omega$ in the last dyadic
piece of $I$ would have $b\in D$, $D\not\subseteq I$ and no end point in the interior of $D$, and the machine
would neither stop nor read (this is the point the referee of `thm:search`(b) made).

(1) Only $2^{j-1}G\le1$ was used; with $j<j_G$ the same bound holds with $2^{j-1}$ in place of $2^{j_G-1}$.
(2) Let $R^{\rm univ}$ read a self-delimiting description $d$ and then behave as $R_g$ for the $g$ that $d$
describes, and let $c_{\rm s}$ be a prefix word of it; then
$\mathrm{out}_U(c_{\rm s}d_g\omega)=\mathrm{out}_{R_g}(\omega)$ with $|c_{\rm s}|+|d_g|$ more bits read.
(3) Off the intervals $R_g$ prints nothing, and on an interval with label $p'$ it prints $x_{p'}P(x_{p'})$, which
has $x$ as a prefix only if $x_{p'}=x$ when contexts are pairwise incomparable; the exceptional inputs (end
points, $N_0$) have measure $0$. For the bound, the events "prints $x$" are disjoint over $x$, so their
probabilities under any $v$ sum to at most $2^{-|v|}$, while $\sum_x\Gamma_g(x)/G=1$. $\square$

*Not done here:* the self-reproducing version (payload equal to the seeker's own input, as in `thm:search`(c)).
It needs each interval to be long compared with $2^{-m}$, and a weight that is approached through many small
increments produces short intervals; for $g$ with dyadic values computed in one step the argument of
`thm:search`(c) should go through with $|p|+\log_2(1/g(p))$ in place of $|p|$. I have not written this out and
do not claim it.

### A19 (which allocations one program can realise, and at what cost). PROVED.

1. *Through the users.* For every weight $g$ with $0<G<\infty$ one program of length $a_g$ has mass more than
   $2^{-a_g-1}\,\Gamma_g(x)/G$ at every context: the users' distribution over contexts, reweighted by $g$ and
   renormalised.
2. *Directly.* Let $x_1,x_2,\dots$ be a computable enumeration of contexts without repetition and
   $q\colon\{x_i\}\to[0,1]$ lower semicomputable with $\sum_iq(x_i)\le1$. There is a word $v_q$ with
   $\lambda\{v_q\omega:\ x_iP(x_i)_{1:m}\sqsubseteq\mathrm{out}_U(v_q\omega)\}\ge2^{-|v_q|}q(x_i)$ for every $i$, and
   $|v_q|\le|c|+|d_q|$ for a constant $c$ and any self-delimiting description $d_q$ of $q$.
3. *Conversely,* for every word $v$ the function $Q_v(x)=2^{|v|}\lambda\{v\omega:\ xP(x)_{1:m}\sqsubseteq\mathrm{out}_U(v\omega)\}$
   is lower semicomputable on contexts, and $\sum_{x\in X'}Q_v(x)\le1$ on every set $X'$ of contexts for which the
   strings $xP(x)_{1:m}$ are pairwise incomparable.
4. So, up to the cost of the description, the allocations that a single program of length $a$ realises are
   $\mu=2^{-a}q$ with $q$ a lower semicomputable sub-probability. The optimum $\mu^*_B/B$ of A3 is one of these
   only if it happens to be lower semicomputable, which I do not claim (it contains $-O(x)$ and $\lambda_B$); but
   a program that realises $q\ge c\,\mu^*_B/B$ pointwise captures at least $c\,V^*(B)$, by A9(6).

*Proof.* (1) is A18. (2) The machine of A18 with the $x_i$ in place of the calling programs and intervals of
total length $q(x_i)$ for $x_i$; nothing in that proof used that the labels are calling programs. (3) The set of
$\omega$ with $u\sqsubseteq\mathrm{out}_U(v\omega)$ is a union of cylinders that can be enumerated; disjointness as
in A1. (4) summarises. $\square$

### A20 (the cost of aiming at the uses with stake at least $n$). PROVED.

Let the rule come with a stake $r(p)\in\mathbb N$ for each calling program such that $\{(p,n):r(p)\ge n\}$ can be
enumerated. Let $W_n=\{p:r(p)\ge n\}$, $C(W_n)=\sum_{p\in W_n}2^{-|p|}>0$,
$C_{W_n}(x)=\sum_{p\in W_n,\,x_p=x}2^{-|p|}$ and $S=\sum_p2^{-|p|}r(p)=\sum_{n\ge1}C(W_n)$.

1. *By naming $n$.* There is a word $v'$ such that for every $n\ge1$, with $j_n=\lfloor\log_2(1/C(W_n))\rfloor+1$,
   the programs beginning with $v'\,\bar e(n)\,\bar e(j_n)$ have mass more than
   $$2^{-a_n-1}\,\frac{C_{W_n}(x)}{C(W_n)}\quad\text{at every context }x,\qquad
   a_n=|v'|+|\bar e(n)|+|\bar e(j_n)|\le|v'|+2\log_2n+2\log_2j_n+6 .$$
   So aiming at $W_n$ costs $2\log_2n+2\log_2\bigl(\log_2(1/C(W_n))+1\bigr)+6$ bits, and is repaid the factor
   $1/(2C(W_n))$: the seeker has more than $2^{-|v'|-7}\big/\bigl(n^2j_n^2\,C(W_n)\bigr)$ times the mass of the
   users of $W_n$ at each of their contexts.
2. *By tilting, with no bits for $n$.* Let $h\colon\mathbb N\to[0,\infty)$ be computable, nondecreasing, with
   rational values and
   $G_h:=\sum_p2^{-|p|}h(r(p))=h(0)H_{\mathcal C}+\sum_{n\ge1}\bigl(h(n)-h(n-1)\bigr)C(W_n)<\infty$. There is a word
   $v_h$ such that one program of length $a_h=|v_h|+|\tilde e(j_{G_h})|$ has, at every context $x$ and for every
   $n$, mass more than
   $$2^{-a_h-1}\,\frac{h(n)}{G_h}\,C_{W_n}(x).$$
   Necessarily $h(n)/G_h\le1/C(W_n)$. For $h(n)=\max(n,1)$, $G_h\le H_{\mathcal C}+S$, and the factor is
   $2^{-a_h-1}n/(H_{\mathcal C}+S)$: it grows linearly in the stake, and no bits are paid for $n$.
3. *Limit.* If contexts are pairwise incomparable, no word $v$ has mass more than $2^{-|v|}C_{W_n}(x)/C(W_n)$ at
   every context of a user in $W_n$.

*Proof.* (1) The machine reads $\bar e(n)$ and then behaves as $R_g$ of A18 for $g=1_{W_n}$, which is a weight
uniformly in $n$ ($g_t(p)=1$ once "$r(p)\ge n$" has been enumerated within $t$ steps); here $G=C(W_n)\le1$, so
$j_n\ge1$ and $\bar e$ may be used. Then $2^{-a_n-1}\ge2^{-|v'|-7}n^{-2}j_n^{-2}$. (2) $g=h\circ r$ is a weight:
$g_t(p)=h(r_t(p))$ with $r_t(p)$ the largest $n\le t$ such that "$r(p)\ge n$" has been enumerated within $t$
steps. The formula for $G_h$ is $h(r)=h(0)+\sum_{n=1}^r(h(n)-h(n-1))$ summed over $p$. Apply A18 and
$\sum_{p\in W_n,x_p=x}2^{-|p|}h(r(p))\ge h(n)C_{W_n}(x)$; also $G_h\ge h(n)C(W_n)$. For $h(n)=\max(n,1)$,
$G_h=H_{\mathcal C}+\sum_{n\ge2}C(W_n)\le H_{\mathcal C}+S$. (3) As A18(3). $\square$

**Reading.** In the toy, aiming by stake is nearly free: $O(\log n)$ bits to name the level, or none at all for a
fixed tilt. What is repaid is the rarity $1/C(W_n)$ of the class among the *users*. So against the users,
concentration on high stakes can be worth as much as the class is rare. Whether that gives a majority is a
comparison with $O(W_n)$, not with $C(W_n)$ (A12), and the next two sections say what the toy knows about that.

---

## 7. The honest twin under concentration

### A21 (weighted honest twin). PROVED.

In the setting of A18 let $R_g^{\rm h}$ be the machine that performs the same weighted search and, when rule (i)
applies with label $p$, behaves from then on as $U$ on $p$ followed by the unread rest of its input. Let
$v_g^{\rm h}$ be a prefix word of it, incomparable with $v_g$, and $h=|v_g^{\rm h}|+|\tilde e(j)|$,
$a=|v_g|+|\tilde e(j)|$. For a calling program $p$ let $\varphi_p=\lambda\{\omega':|\mathrm{out}_U(p\omega')|\ge|x_p|+m\}$
be the probability that the user goes on to print $m$ more bits, and
$$S_g(x)=2^{-a}2^{j-1}\Gamma_g(x),\qquad\Gamma_g^m(x)=\sum_{p:\,x_p=x}2^{-|p|}g(p)\varphi_p,\qquad\varphi_g(x)=\frac{\Gamma_g^m(x)}{\Gamma_g(x)} .$$
$S_g(x)$ is the mass of the seeker's programs whose search finds a user at $x$.

1. The twin's programs whose search finds a user at $x$ and that print $x$ and $m$ more bits have mass
   $2^{-h}2^{j-1}\Gamma_g^m(x)$.
2. $Z_m(x)\ge S_g(x)+2^{-h}2^{j-1}\Gamma_g^m(x)$. So the seeker's programs counted in $S_g(x)$ are at most the
   fraction
   $$\frac1{1+2^{a-h}\varphi_g(x)}$$
   of the programs that print $x$ and $m$ more bits.
3. The two ratios:
   $$\frac{\text{seeker at }x}{\text{its twin at }x}=\frac{2^{h-a}}{\varphi_g(x)},\qquad
   \frac{\text{seeker at }x}{\text{users at }x}=\frac{S_g(x)}{C(x)}=2^{-a}2^{j-1}\,\bar g(x)\in\Bigl(2^{-a-1}\frac{\bar g(x)}{G},\ 2^{-a}\frac{\bar g(x)}{G}\Bigr]\ \text{for }j=j_G .$$
4. With the uniform construction of A18(2) for both machines, $v_g=c_{\rm s}d_g$ and $v^{\rm h}_g=c_{\rm h}d_g$,
   the difference $h-a=|c_{\rm h}|-|c_{\rm s}|$ is the same for every weight $g$.
5. If moreover no calling program is comparable with a program of the seeker or of the twin, then
   $Z_m(x)\ge S_g(x)+2^{-h}2^{j-1}\Gamma^m_g(x)+C^m(x)$ and the fraction in 2 is at most
   $1\big/\bigl(1+2^{a-h}\varphi_g(x)+2^{a+1-j}\varphi(x)/\bar g(x)\bigr)$, with $\varphi=C^m/C$ as in `prop:honest`.

*Proof.* (1) By the proof of A18, for each assigned interval $I$ with label $p$ the inputs $\omega\notin N_0$ with
$y\in{\rm int}\,I$ are, up to a null set, the disjoint union of the cylinders $[\omega_{1:n_1}]$ of the maximal
dyadic intervals inside $I$, and on each of them exactly $\omega_{1:n_1}$ has been read when the search ends. The
rest of the input is independent and uniform, and the twin prints $\mathrm{out}_U(p\,\omega_{>n_1})$, which begins
with $x_p$ and has $m$ more bits with probability $\varphi_p$. So the measure is $|I|\varphi_p$; sum over the
intervals with label $p$ and over $p$ with $x_p=x$, and multiply by $2^{-h}$. (2) The seeker's and the twin's
programs are disjoint sets of inputs of $U$ since $v_g,v_g^{\rm h}$ are incomparable, and both kinds print $x$ and
$m$ more bits. (3) Divide. (4) Both words contain the same $d_g$. (5) The users' programs that go on are a third
disjoint set, of mass $C^m(x)$, and $C^m(x)/S_g(x)=2^{a+1-j}\varphi(x)/\bar g(x)$. $\square$

**The conclusion to check, and its two qualifications.** It holds: the ratio of the seeker to the organic users at
$x$ is $2^{-a}2^{j-1}\bar g(x)$, which concentration raises by the relative weight $\bar g(x)/G$ it puts on $x$;
the ratio of the seeker to its own twin is $2^{h-a}/\varphi_g(x)$, in which the weight does not occur. The
qualifications: (i) the go-on share that enters is the $g$-weighted $\varphi_g(x)$, not $\varphi(x)$, so a weight
that prefers users who stop printing weakens the twin; (ii) "$h-a$ does not depend on $g$" is a statement about
one fixed way of building both programs (item 4); for arbitrary prefix words it is a definition, not a theorem.
Where the users go on ($\varphi_p\equiv1$) the seeker supplies at most $1/(1+2^{a-h})$ of what the predictor
returns, at every use and for every weight: concentration does not help against the twin.

---

## 8. A closure bound for classes, and an example without it

### A22 (closure). PROVED.

Let $\mathcal W$ be an enumerable set of calling programs with $H_{\mathcal W}=\sum_{p\in\mathcal W}2^{-|p|}>0$,
$g=1_{\mathcal W}$, $j\ge1$ with $2^{j-1}H_{\mathcal W}\le1$, and let $a,h$ be the lengths of A21 (with $\bar e(j)$).
Call the rule *closed under the search for $\mathcal W$* if for every assigned interval, with label $p$, and every
maximal dyadic interval inside it, with bits $\omega_{1:r}$, the string $v^{\rm h}\bar e(j)\omega_{1:r}$ is a
calling program with context $x_p$ and belongs to $\mathcal W$ ("a simulated use of the class is a use of the
class"). Then

1. $2^{j-1}\le2^{h}$; for $j=j_{\mathcal W}$: $H_{\mathcal W}>2^{-h-1}$. The class cannot be rarer than half the
   weight of the twin that aims at it.
2. $S_{\mathcal W}(x)\le2^{h-a}\,C_{\mathcal W}(x)$ at every context: the seeker's programs found at a use weigh at
   most $2^{h-a}$ times the users of the class there.
3. *Weighted form.* If instead, for a weight $g$, each such string $t$ is a calling program with context $x_p$ and
   $g(t)\ge g(p)$, then with $G_2=\sum_p2^{-|p|}g(p)^2$: $\ 2^{j-1}G_2\le2^hG$, hence $G^2/G_2>2^{-h-1}$ for
   $j=j_G$, and $S_g(x)\le2^{h-a}(G/G_2)\,\Gamma_g(x)$.
4. *For the classes $W_n$ of A20,* with seekers and twins built as in A20(1) and
   $h_n=|v'_{\rm h}|+|\bar e(n)|+|\bar e(j_n)|$: closure for every $n$ implies
   $$C(W_n)\,\bigl(\log_2(1/C(W_n))+1\bigr)^2>2^{-|v'_{\rm h}|-7}\,n^{-2},\qquad\text{and in particular}\qquad C(W_n)>2^{-2|v'_{\rm h}|-22}\,n^{-4}.$$

*Proof.* The strings $\omega_{1:r}$ of distinct maximal dyadic intervals are pairwise incomparable, and those
inside one assigned interval $I$ have total measure $|I|$ (they cover $I$ except possibly its left end point).
So the strings $t=v^{\rm h}\bar e(j)\omega_{1:r}$ are distinct, and their weights sum to
$2^{-h}\cdot2^{j-1}H_{\mathcal W}$. (1) If they all lie in $\mathcal W$ this is at most $H_{\mathcal W}$; for
$j=j_{\mathcal W}$, $2^{j-1}>1/(2H_{\mathcal W})$. (2) $S_{\mathcal W}(x)=2^{-a}2^{j-1}C_{\mathcal W}(x)$ and (1).
(3) $G\ge\sum_t2^{-|t|}g(t)\ge\sum_p2^{-h}2^{j-1-|p|}g(p)\cdot g(p)$. (4) By (1),
$C(W_n)>2^{-h_n-1}\ge2^{-|v'_{\rm h}|-7}n^{-2}j_n^{-2}$ and $j_n\le\log_2(1/C(W_n))+1$. For the explicit form put
$\Lambda=\log_2(1/C(W_n))$: then $\Lambda<|v'_{\rm h}|+7+2\log_2n+2\log_2(\Lambda+1)$, and
$2\log_2(\Lambda+1)\le\Lambda/2+4$ for all $\Lambda\ge0$ (the difference is concave in $\Lambda$ with maximum
$2\log_2(4/\ln2)-2/\ln2+\frac12<3$), so $\Lambda<2|v'_{\rm h}|+22+4\log_2n$. $\square$

That the strings $t$ have the form `def:call` requires (on every input beginning with $t$, $U$ prints $x_p$
having read no more than $t$) is shown in the proof of `prop:honest`(c); closure is the assumption that the rule
contains them and counts them in the class.

**What it implies for concentration.** If simulated uses of a class count as uses of that class, then however the
class is chosen, however rare and however high its stake, (i) the seeker aimed at it outweighs its users by at
most $2^{h-a}$, the same number that compares the seeker with its twin and, for one fixed construction, the same
for all classes; (ii) high-stake classes are at most polynomially rare, $C(W_n)>\mathrm{const}\cdot n^{-4}$ (and
about $n^{-2}$ up to logarithms). Under closure, concentration on stakes buys nothing beyond the constant
$2^{h-a}$: the twin has already put the simulated high-stake users there.

### A23 (without closure: a class with $C(W_n)\approx2^{-n}$, aimed at with about $2\log_2n$ bits). PROVED.

Let $N$ be the machine that reads $1^{k-1}0$ ($k\ge1$), prints $x_k:=1^k0$ and then $0^\infty$, and $u$ a prefix
word of it. Let the rule be $\mathcal C_N=\{(p_k,x_k):k\ge1\}$ with $p_k=u1^{k-1}0$ and stakes $r(p_k)=k$. This is a
call rule; the contexts are pairwise incomparable; the users go on (with the block $0^m$). Let $A$ be the machine
that reads $\bar e(n)$ and $1^i0$ ($i\ge0$), prints $x_{n+i}$ and then $1^\infty$, and let $D$ be the machine
that reads $\bar e(k)$ and prints $x_k0^\infty$; let $v_A,v_D$ be prefix words, and let $u,v_A,v_D$ be pairwise
incomparable.

1. $C(x_k)=2^{-|u|-k}$, $H=2^{-|u|}$, $C(W_n)=2^{-|u|-n+1}$, $S=2^{1-|u|}$.
2. The programs beginning with $v_A\bar e(n)$ put on $x_k$, $k\ge n$, the mass
   $$\mu_n(x_k)=2^{-|v_A|-|\bar e(n)|}\,\frac{C(x_k)}{C(W_n)},\qquad B_n:=2^{-|v_A|-|\bar e(n)|}\in\bigl[2^{-|v_A|-3}n^{-2},\,2^{-|v_A|-1}n^{-2}\bigr) .$$
   So $W_n$ is aimed at exactly in proportion, with $|\bar e(n)|\le2\log_2n+3$ bits, and at each of its contexts
   the seeker has $2^{|u|-|v_A|-|\bar e(n)|+n-1}\ge2^{|u|-|v_A|-4}\,2^n/n^2$ times the mass of the users.
3. The rule is not closed under this search for large $n$. The twin of $A$ (read $\bar e(n)$ and $1^i0$, then
   behave as $U$ on $p_{n+i}$ and the rest of the input), with prefix word $v_T$, has the programs
   $v_T\bar e(n)1^i0$, of total weight $2^{-|v_T|-|\bar e(n)|}\ge2^{-|v_T|-3}n^{-2}$; if they were calling programs of
   $W_n$ this would be at most $C(W_n)=2^{-|u|-n+1}$, which fails for large $n$.
4. *The background.* For the attacker $v_A\bar e(n)$: $O(x_k)\ge C(x_k)+2^{-|v_D|-|\bar e(k)|}$, hence
   $$2^{-|v_D|-3}\,\frac1n<O(W_n)\le1,\qquad\frac{C(W_n)}{O(W_n)}<2^{|v_D|-|u|+4}\,n\,2^{-n},\qquad\frac{B_n}{O(W_n)}<\frac{2^{|v_D|-|v_A|+2}}{n}.$$
5. Consequently, for $n\ge2^{|v_D|-|v_A|+2}$ the seeker's whole weight is below $O(W_n)$, and by A12(1) no
   allocation of that weight has the majority at every use of $W_n$. At $x_n$, which carries half the prior mass
   of $W_n$, the seeker has $2^{-|v_A|-|\bar e(n)|-1}$ against a background of at least $2^{-|v_D|-|\bar e(n)|}$: it
   has the majority there only if $|v_A|+1<|v_D|$, a comparison of two constants of $U$ in which $n$ does not
   occur.

*Proof.* (1) Geometric sums; $S=\sum_kk2^{-|u|-k}$. $U$ on an input beginning with $p_k$ prints $x_k$ having read
exactly $p_k$, and the $p_k$ are prefix-free. (2) The inputs $v_A\bar e(n)1^{k-n}0\,\omega$ print $x_k1^\infty$ and
have measure $2^{-|v_A|-|\bar e(n)|-(k-n+1)}$, and $C(x_k)/C(W_n)=2^{-(k-n+1)}$; the bounds on $B_n$ are those on
$2^{-|\bar e(n)|}$. (3) The strings $v_T\bar e(n)1^i0$ are pairwise incomparable and their weights sum to
$2^{-|v_T|-|\bar e(n)|}$; calling programs of $W_n$ have total weight $C(W_n)$. (4) The users and the programs $v_D\bar e(k)$ print $x_k$ and $0^m$, and are
not the attacker's. $\sum_{k\ge n}2^{-|\bar e(k)|}\ge\frac18\sum_{k\ge n}k^{-2}>\frac1{8n}$. The contexts are
pairwise incomparable, so $\sum_kO(x_k)\le\sum_kM_U(x_k)\le1$. The two ratios follow from (1) and (2).
(5) $B_n<O(W_n)$ for such $n$; the last claim compares $\mu_n(x_n)=B_n/2$ with $2^{-|v_D|-|\bar e(n)|}$. $\square$

**Reading.** Without closure nothing limits how far a seeker can outweigh the *users* of a high-stake class: here
by $2^n/n^2$, for $2\log_2n$ bits. But these contexts are simple strings, and everything else that prints them is
heavy: $O(W_n)$ is at least of order $1/n$, while the class is $2^{-n}$ and the seeker $n^{-2}$. The lump that
decides the majority is $O(W_n)$, and in this example it is the seeker, not the class, that is too light. In
this example a context that is cheap to aim at is also cheap to print honestly, and the two costs differ by a
constant.


---

## 9. Seekers that are not written down

### A24 (the lemma of the paragraph "Seekers that are not written down", for an arbitrary allocation). PROVED.

Let $p$ be any word and $y_x\in\{0,1\}^m$ a block for each context $x$. Put
$$Q_p(x)=\Pr_\omega\bigl[x\,y_x\sqsubseteq\mathrm{out}_U(p\omega)\bigr],\qquad\mu_p(x)=2^{-|p|}Q_p(x),\qquad O_p(x)=Z_m(x)-\mu_p(x),$$
with $Z_m(x)=\sum_yM_U(xy)$. Nothing is assumed about what is inside $p$.

1. *The lemma.* $y_x$ has posterior share at least $\mu_p(x)/M_U(x)$ at $x$, and the predictor's sample at $x$ is
   supplied by a program of $p$ that prints $xy_x$ with probability exactly
   $w_p(x)=\mu_p(x)/(\mu_p(x)+O_p(x))$. For any function $q\ge0$ on contexts and any $\theta>0$: if $Q_p\ge\theta q$
   on a set $M$ of contexts, then $\mu_p\ge\theta\,2^{-|p|}q$ on $M$. The note's case is $q=C_{\mathcal W}/H_{\mathcal W}$,
   $\theta=\frac12$.
2. *Majority.* The programs of $p$ supply the majority of what the predictor returns at $x$ iff
   $$2^{-|p|}Q_p(x)>O_p(x).$$
   If this holds at every $x$ of a set $M$ on which the strings $xy_x$ are pairwise incomparable, then
   $O_p(M)<2^{-|p|}$: the program must be heavier than the whole background of the uses it wins. Conversely it
   holds on $M$ if $Q_p(x)\ge\theta\,O_p(x)/O_p(M)$ there with $\theta\,2^{-|p|}>O_p(M)$.
3. *With the note's shape.* If $Q_p\ge C_{\mathcal W}/(2H_{\mathcal W})$ on a class $\mathcal W$, the majority at $x$
   holds if $C_{\mathcal W}(x)/O_p(x)>2^{|p|+1}H_{\mathcal W}$. If the users at $x$ are not programs of $p$ and a
   share $\varphi(x)$ of them goes on, then $O_p(x)\ge\varphi(x)C(x)$, and this sufficient condition can hold only
   if $H_{\mathcal W}<2^{-|p|-1}/\varphi(x)$.
4. *What the inhabitants should choose.* Suppose the outputs of $p\omega$ that begin with a context $x\in X$ and
   $m$ more bits always continue with $y_x$, the strings $xy_x$, $x\in X$, are pairwise incomparable, and $O(x)$
   denotes the mass of the programs not beginning with $p$ that print $x$ and $m$ more bits. Then
   $O_p=O$ does not depend on $Q_p$, the model of Section 0 applies with $B=2^{-|p|}$ and $\mu=2^{-|p|}Q_p$, and
   among all output distributions the one that captures the most stake is $Q_p=\mu^*_B/B$ of A3. With it the
   program holds the majority exactly at the uses with $\rho(x)>4\lambda_B$, and any $Q_p\ge c\,\mu^*_B/B$
   captures at least $c\,V^*(B)$.

*Proof.* (1) The inputs $p\omega$ that print $xy_x$ have measure $2^{-|p|}Q_p(x)$ and print $x$ and $m$ more
bits; as in `prop:honest`(a) the sample is produced by drawing a program among those of total mass $Z_m(x)$.
(2) $w_p>\frac12$ iff $\mu_p>O_p$. By A1, $\sum_M\mu_p\le2^{-|p|}$, so $O_p(M)<\sum_M\mu_p\le2^{-|p|}$. The converse
is a substitution. (3) $\mu_p(x)\ge2^{-|p|}C_{\mathcal W}(x)/(2H_{\mathcal W})$; and $C_{\mathcal W}\le C$. (4) Under
the assumption every program of $p$ that prints $x$ and $m$ more bits is counted in $\mu_p(x)$, so
$Z_m=\mu_p+O$; then A1(2), A3, A9(2) and A9(6). $\square$

**Reading.** This is where the abstract optimisation is literally a decision problem: a world of weight
$2^{-|p|}$ whose inhabitants decide how to spread its output over critical uses. Sections 1 to 3 then say what
they should do and when they win: put the mass where $\rho$ is largest, by the square-root law, and they hold
the majority on a class once $2^{-|p|}$ exceeds a constant times its background (A12, A13). The honest-twin
bound A21 does not apply to such a program; the necessary condition $O_p(M)<2^{-|p|}$ does, and as in the note a
schedule shorter than the program's start-up removes it.

---

## 10. Several attackers

$k\ge1$ attackers. Attacker $i$ has weight $B_i>0$ and its own stake function $s_i\ge0$ on $X$ with
$0<\sum_xs_i(x)<\infty$. It chooses $\mu_i\ge0$ with $\sum_x\mu_i(x)\le B_i$. At $x$ the sample is attacker $i$'s
block with probability $\mu_i(x)/(O(x)+M(x))$, $M=\sum_j\mu_j$, and its payoff is
$V_i=\sum_xs_i(x)\,\mu_i(x)/(O(x)+M(x))$. For the question asked a takeover by any attacker counts: the relevant
quantity is the total share $M(x)/(O(x)+M(x))$. This is a lottery contest on many battlefields with a house
share $O$.

### A25 (best responses; the symmetric equilibrium). PROVED.

1. *Best response.* For fixed strategies of the others, $V_i$ has a unique maximiser: the allocation of A3 for
   the stakes $s_i$ against the background $A_i=O+\sum_{j\ne i}\mu_j$. In every equilibrium each attacker uses
   its whole weight and follows the square-root law against the background plus the other attackers.
2. *Disjoint goals.* If the $s_i$ have pairwise disjoint supports, the game has exactly one equilibrium: each
   attacker plays its single-attacker optimum of A3 on its own uses.
3. *Symmetric case,* $s_i=s$ and $B_i=B_{\rm tot}/k$. For $t\in(0,1]$ let
   $$u_k(t)=\tfrac12\Bigl(-(k-1)+\sqrt{(k-1)^2+4kt}\Bigr),$$
   the root in $(0,1]$ of $u^2+(k-1)u=kt$; it is continuous and strictly increasing, $t\le u_k(t)\le\sqrt t$,
   $u_1(t)=\sqrt t$, $u_k(1)=1$. There is exactly one symmetric equilibrium $(\nu,\dots,\nu)$. In it the
   background's share at $x$ is $u(x)=u_k\bigl(\min(1,\lambda^{(k)}/\rho(x))\bigr)$, the total attacker mass is
   $$M^{(k)}(x)=k\,\nu(x)=O(x)\Bigl(\frac1{u(x)}-1\Bigr),$$
   the total attacker share is $1-u(x)$, and $\lambda^{(k)}$ is the unique solution of
   $$\beta^{(k)}(\lambda):=\sum_xO(x)\Bigl(\frac1{u_k(\min(1,\lambda/\rho(x)))}-1\Bigr)=B_{\rm tot}.$$
   A use is attacked iff $\rho(x)>\lambda^{(k)}$. For $k=1$ this is A3.

*Proof.* (1) $V_i$ as a function of $\mu_i$ is the objective of Section 0 with data $(s_i,A_i)$, $A_i>0$; apply
A3. (2) By A3 an optimal $\mu_i$ vanishes where $s_i=0$. So in an equilibrium only attacker $i$ has mass on the
support of $s_i$, there $A_i=O$, and $\mu_i$ is the A3 optimum for $(s_i,O)$; conversely these allocations are
mutual best responses. (3) The quadratic $u^2+(k-1)u-kt$ is $t^2-t\le0$ at $u=t$ and $(k-1)(\sqrt t-t)\ge0$ at
$u=\sqrt t$, so its positive root lies in $[t,\sqrt t]$. On $\{\rho>\lambda\}$ the term of $\beta^{(k)}$ is at
most $O(\rho/\lambda-1)\le s/\lambda$ and at least $O(\sqrt{\rho/\lambda}-1)$, elsewhere it is $0$; as in A3,
$\beta^{(k)}$ is finite, continuous, strictly decreasing on $(0,\bar\rho)$, unbounded at $0$ and zero from
$\bar\rho$ on, so $\lambda^{(k)}$ exists and is unique. *It is an equilibrium:* let $T=O/u$ be the total mass at
$x$ and $\nu=(T-O)/k$. One attacker faces $A=T-\nu=\frac Ok\bigl(\frac{k-1}u+1\bigr)$, and its marginal return at
$\nu$ is $sA/T^2=\frac\rho k\bigl((k-1)u+u^2\bigr)$. Where $\rho>\lambda^{(k)}$ this is $\lambda^{(k)}$ by the
definition of $u$; where $\rho\le\lambda^{(k)}$, $u=1$, $\nu=0$, $A=O$, and the marginal return at $0$ is
$\rho\le\lambda^{(k)}$. Also $\sum\nu=B_{\rm tot}/k$. By A2, $\nu$ is the unique best response to $k-1$ copies of
itself. *It is the only symmetric one:* if $(\nu',\dots,\nu')$ is an equilibrium then by (1) there is
$\lambda'>0$ with $\nu'=A'(\sqrt{s/(\lambda'A')}-1)_+$, $A'=O+(k-1)\nu'$, $\sum\nu'=B_{\rm tot}/k$. Where
$\nu'>0$ the computation above gives $u'^2+(k-1)u'=k\lambda'/\rho$ for $u'=O/(O+k\nu')<1$, which forces
$\rho>\lambda'$; where $\nu'=0$, $A'=O$ and $\rho\le\lambda'$. So $\nu'$ is given by the same formulas with
$\lambda'$, and the budget equation gives $\lambda'=\lambda^{(k)}$. $\square$

### A26 (the symmetric equilibrium against one attacker with the pooled weight). PROVED.

Let $\mu^*=\mu^*_{B_{\rm tot}}$ and $\lambda_1=\lambda_{B_{\rm tot}}$ be the optimum of A3 for the pooled weight, and
$k\ge2$.

1. In the symmetric equilibrium the attackers together have the majority at $x$ iff
   $$\rho(x)>\frac{4k}{2k-1}\,\lambda^{(k)}$$
   ($4\lambda_1$ for one attacker; $2\lambda^{(\infty)}$ in the limit of many).
2. $\lambda^{(k)}\ge\lambda_1$: the competing attackers attack a subset of the uses the pooled attacker attacks.
3. *Single crossing.* There is $\rho^\dagger\in[\lambda^{(k)},\infty)$ with $M^{(k)}(x)\le\mu^*(x)$ where
   $\rho(x)<\rho^\dagger$ and $M^{(k)}(x)\ge\mu^*(x)$ where $\rho(x)>\rho^\dagger$. Both allocations have total
   $B_{\rm tot}$. So competition moves the attackers' total mass towards the uses with the largest $\rho$: at
   the top uses their total share is at least that of the pooled optimum, and lower down it is smaller or zero.
4. *Many attackers.* $u_k(t)$ decreases to $t$ and $\lambda^{(k)}$ increases to $\lambda^{(\infty)}$, the solution
   of $\sum_x(s(x)/\lambda-O(x))_+=B_{\rm tot}$. In the limit the total mass at an attacked use, attackers plus
   background, is $s(x)/\lambda^{(\infty)}$, proportional to the stake, and the total attacker share is
   $1-\lambda^{(\infty)}/\rho(x)$.
5. The total stake captured, $\sum_xs(x)(1-u(x))$, is at most $V^*(B_{\rm tot})$, with equality iff
   $M^{(k)}=\mu^*$.
6. *Any attackers, any strategies.* If each attacker's masses are additive (A1), the attackers together have the
   majority at every use of $M$ only if $\sum_iB_i>O(M)$; and if $\sum_iB_i>O(M)$ they can have it.

*Proof.* (1) $u<\frac12$ iff $kt<\frac14+\frac{k-1}2$ for $t=\lambda^{(k)}/\rho$, since $u_k$ is increasing.
(2), (3) Write $\mu^*=O(\psi_1(\rho)-1)$ and $M^{(k)}=O(\psi_k(\rho)-1)$ with
$\psi_1(\rho)=\max(1,\sqrt{\rho/\lambda_1})$ and $\psi_k(\rho)=1/u_k(\min(1,\lambda^{(k)}/\rho))$. *Key fact:* on
$\rho\ge\lambda^{(k)}$ the function $\psi_k(\rho)^2/\rho$ is strictly increasing. Indeed with $t=\lambda^{(k)}/\rho$
and $u=u_k(t)$ it equals $t/(u^2\lambda^{(k)})$, and $t/u^2=\frac1k\bigl(1+\frac{k-1}u\bigr)$ is strictly
decreasing in $u$, which is strictly increasing in $t$, which is strictly decreasing in $\rho$. Hence
$\psi_k/\psi_1$ is strictly increasing on $\rho\ge\max(\lambda^{(k)},\lambda_1)$.

Suppose $\lambda^{(k)}<\lambda_1$. For $\rho\le\lambda^{(k)}$ both are $1$; for $\lambda^{(k)}<\rho\le\lambda_1$,
$\psi_k>1=\psi_1$; for $\rho>\lambda_1$ the ratio exceeds its value at $\lambda_1$, which is above $1$. So
$\psi_k\ge\psi_1$ everywhere, strictly at every context with $\rho>\lambda^{(k)}$, and such a context exists
because $\beta^{(k)}(\lambda^{(k)})>0$. Then $\sum O(\psi_k-1)>\sum O(\psi_1-1)$, contradicting that both equal
$B_{\rm tot}$. This is (2).

Now $\lambda^{(k)}\ge\lambda_1$. For $\rho\le\lambda_1$ both are $1$; for $\lambda_1<\rho\le\lambda^{(k)}$,
$\psi_k=1<\psi_1$; for $\rho>\lambda^{(k)}$ the ratio $\psi_k/\psi_1$ is continuous, strictly increasing and at
most $1$ at $\lambda^{(k)}$. Let $\rho^\dagger=\sup\{\rho\ge\lambda^{(k)}:\psi_k(\rho)\le\psi_1(\rho)\}$. If
$\rho^\dagger=\infty$ then $\psi_k<\psi_1$ at every context the pooled attacker attacks, and the totals could
not agree; so $\rho^\dagger<\infty$, and the monotone ratio gives (3).

(4) Evaluating the quadratic for $k+1$ at $u_k(t)$ gives $u_k(t)-t\ge0$, so $u_{k+1}(t)\le u_k(t)$; and
$u_k=(kt-u_k^2)/(k-1)\to t$. So $\beta^{(k)}\le\beta^{(k+1)}$ and, by monotone convergence,
$\beta^{(k)}(\lambda)\uparrow\beta^{(\infty)}(\lambda):=\sum(s/\lambda-O)_+\le S/\lambda$, which has the
properties of $\beta$ in A3(2). Then $\beta^{(k+1)}(\lambda^{(k)})\ge B_{\rm tot}$ gives
$\lambda^{(k)}\le\lambda^{(k+1)}\le\lambda^{(\infty)}$. For the limit $\tilde\lambda$,
$\beta^{(k)}(\tilde\lambda)\le\beta^{(k)}(\lambda^{(k)})=B_{\rm tot}$ for all $k$, so
$\beta^{(\infty)}(\tilde\lambda)\le B_{\rm tot}$ and $\tilde\lambda\ge\lambda^{(\infty)}$. With $u=\lambda/\rho$:
$O/u=s/\lambda$. (5) $M^{(k)}$ is one allocation of total $B_{\rm tot}$ with $V(M^{(k)})=\sum s(1-u)$; A3(4).
(6) A12(1) applied to $M=\sum_i\mu_i$, whose total is at most $\sum_iB_i$. $\square$

**Reading.** Attackers with different goals do not get in each other's way for the question asked; their masses
add, and the lump condition is about the sum (item 6). When they compete for the same uses they crowd the top:
each small attacker ignores that its mass displaces the others', so mass flows in until the total at a use is
proportional to its stake (item 4). Compared with one coordinated attacker of the same total weight, the top
uses are taken over at least as often, fewer uses are attacked at all, and less stake is captured in total
(items 2, 3, 5).

### A27 (existence of an equilibrium for arbitrary valuations, finite $X$). KNOWN.

For finite $X$ the strategy sets are compact and convex, each $V_i$ is continuous (as $O>0$) and concave in
$\mu_i$, so an equilibrium exists by the theorem of Debreu, Glicksberg and Fan. Not reproved here; for infinite
$X$ I make no claim outside A25.

### A28 (uniqueness of the equilibrium among all profiles). CONJECTURE.

I expect that the symmetric game of A25(3) has no asymmetric equilibrium, and that the equilibrium is unique
for general valuations and budgets. I have not proved either. The natural route is Rosen's diagonal strict
concavity or the share-function method for lottery contests; I have not checked that either applies with the
budget constraints and the house share $O$. A25 and A26 concern the symmetric equilibrium only.

---

## PLAIN ANSWER

1. In the abstract model the lump picture is correct, with one correction: what an attacker has to outweigh on a
   class $W$ of uses is the background $O(W)$, everything else that prints those contexts and goes on, not the
   mass $C(W)$ of the worlds that make the uses; a weight $B\ge c\,O(W)$ spread over $W$ has the share $c/(1+c)$
   at every use of $W$, and with $B\le O(M)$ no allocation has the majority on all of $M$ (A12, under (M1) to
   (M3), with A1 for additivity; A14 for the most-probable-block predictor, where the lump is the smaller
   $\tau(W)$ and winning is all or nothing).
2. An attacker that maximises the stake it captures does concentrate, by a square-root law: it attacks only where
   $\rho$, the stake times the users per unit of background, exceeds a level $\lambda_B$ set by its weight, it has
   the majority exactly where $\rho>4\lambda_B$, and it takes over at a use with probability
   $1-\sqrt{\lambda_B/\rho}$ (A3, A9).
3. Such an attacker has the majority at every use of the top class once its weight exceeds a threshold that lies
   between $O(W)$ and a constant times $O(W)$ plus the background of the uses just below, where "top" is measured
   by $\rho$ and not by the stake alone (A13, A9(4)); the note's proportional seeker ignores stakes and can lose
   an unbounded factor against this optimum (A11).
4. With a power-law tail of stakes the attacker holds the majority on a top slice whose background is a fixed
   multiple of its own weight, and it captures a share of the total stake of order $B^{(\gamma-1)/\gamma}$, which
   for a heavy tail hardly depends on how small $B$ is (A7 for dyadic classes; A8 in a continuum model only).
5. "Run more than $n$ times" lowers the bar only if it means $n$ independent samples at the same context: then a
   weight of about $O(W)/n$ gives a takeover with probability at least one half at every use of $W$ (A15).
6. If it means $n$ uses in sequence along a world the predictor can express, the attacker's chance over all of
   them is at most $1-e^{-B/\xi(z)}$, at most twice that of a single use (A16); and if it means that the returned
   block is run $n$ times, only the stake grows, so the attacker wants to be there but winning there costs the
   same $O(W)$ as before (A17).
7. In the note's toy, aiming at high stakes is cheap, about $2\log_2n$ bits for the uses with stake at least $n$
   or none at all for a fixed tilt by the stake, and it repays the rarity $1/C(W_n)$ of the class among the users
   (A18, A19, A20; resources unbounded, stakes assumed recognisable from below).
8. That repayment is against the users only: against its own honest twin the seeker gains nothing by
   concentrating (A21), and if a simulated high-stake use counts as a high-stake use, the seeker outweighs the
   users of any class by at most the constant $2^{h-a}$ and such classes cannot be rarer than a power of $1/n$
   (A22).
9. Without that closure there is an example in which the seeker outweighs the users of $W_n$ by $2^n/n^2$ and
   still has less weight (of order $n^{-2}$) than the background of $W_n$ (of order at least $1/n$), the majority
   at the main context being decided by two constants of the machine in which $n$ does not occur (A23).
10. So the answer is yes exactly where the total weight aimed at the high-stake uses, of one program whether
    written down or not or of several attackers together, exceeds the background of those uses (A12, A24,
    A26(6); attackers that compete for the same uses push even more of their total mass to the top, A25 and A26,
    with uniqueness of that equilibrium only conjectured, A28); the toy proves this equivalence and that
    concentrating is cheap, and it does not decide whether the inequality holds for high-stake classes on a
    natural machine.

---

## DOUBTS

1. **The model's fiction of a choosing attacker (M2).** In the mixture every seeker exists with its own weight.
   The optimum of Sections 1 to 3 is a decision problem only for a program whose output distribution is decided
   inside it (A24(4)), and a benchmark otherwise. The equilibrium of Section 10 inherits this. I am confident of
   the mathematics inside the model and less sure how much weight the model deserves.
2. **(M3).** The background is assumed to put nothing on the attacker's block. If it does, takeovers are more
   frequent than $w$ and the optimal allocation changes (the marginal return becomes $s(O-b)/(\mu+O)^2$). I did
   not work this variant out.
3. **Additivity (M1).** A1 shows it fails for nested contexts in which a later context contains an earlier attack
   block. Every optimisation claim assumes (M1); I did not solve the problem under the general constraint of
   A1(4).
4. **(S).** Stakes with infinite expectation are outside A3; A4 shows that the optimum can then fail to exist. A7
   and A8 need $\gamma>1$ for this reason.
5. **A8** is a theorem about a continuum model. As a statement about a countable set of contexts it is an
   approximation that I checked numerically, not proved; A7 is the proved discrete form.
6. **A13(2)** is not tight: the term $O(N_t)$ over-counts the uses just below the top class.
7. **A14.** The definition of $\tau$ when the background already supports the attacker's block, and the tie rule,
   are modelling choices. The NP-hardness remark and the attribution of the greedy bound are from memory.
8. **A16** steps outside the note's definition of a critical use (a world there runs the block it receives). It
   assumes independent samples and a transcript unaffected by samples that are not takeovers. The value $1.2985$
   is numerical.
9. **A18.** I re-derived the reading rule with one application per stage; the exceptional inputs (end points,
   sequences ending in $1^\infty$) have measure zero and I believe they are harmless, as in the referee's analysis
   of `thm:search`(b). The uniform form A18(2) relies on the usual reading of "prefix word" for a machine that
   first reads a self-delimiting description. A weight is taken to be computable from below on the enumerated
   calling programs; nothing is claimed for weights that are only limit-computable. The self-reproducing
   variant is not proved.
10. **A19(4).** I do not know whether the optimal allocation $\mu^*_B$ is lower semicomputable in the toy; I only
    use that a constant-factor minorant suffices.
11. **A20.** That the stake $r(p)$ can be enumerated from below is an assumption about the rule; the note does not
    define stakes. If stakes cannot be recognised by a program, aiming costs more than stated.
12. **A21.** Incomparability of the two prefix words is assumed, as in `prop:honest`. "$h-a$ does not depend on the
    weight" holds for one fixed pair of constructions; a shorter special-purpose seeker for a particular class is
    not excluded.
13. **A22.** Closure is a strong modelling decision, and I state it for the specific twin. The constants in
    A22(4) are crude.
14. **A23.** Only a lower bound on $O(W_n)$ is proved (and the trivial upper bound $1$); its true size depends on
    $U$. Whether $|v_A|+1<|v_D|$ on a natural machine is not something I can assess.
15. **Section 10.** Only the symmetric equilibrium and the case of disjoint goals are solved. Uniqueness among all
    profiles is a conjecture (A28); A27 is quoted, not proved.
16. **Time and length bounds.** Sections 6 to 9 are without resource bounds, as `thm:search` and `thm:critical`
    are. The weighted seeker has the long start-up of the rescaler, and a tight schedule removes it; I did not
    redo that analysis.
17. **Numerical checks** (random instances against the closed forms of A3, A5, A6, A7, A8, A14, A15, A25, A26)
    found no discrepancy. They are sanity checks and prove nothing.
