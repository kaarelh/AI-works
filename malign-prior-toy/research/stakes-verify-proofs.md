# Stakes derivations A and B: proof check

Referee report on `research/stakes-derivation-A.md` (claims A1 to A28) and `research/stakes-derivation-B.md`
(claims B1 to B32). Lens: proofs. Written by an AI referee; not reviewed by a human.

**Method.** For each numbered claim I first derived the statement myself from the definitions of
`paper/sec2-toy.tex`, `sec3-floor.tex` and `sec4-limits.tex`, then read the author's proof line by line, then
compared. Every use of a result of the note was checked against the note's statement (`lem:basic`,
`def:universal`, `def:call`, `thm:calibration`, `thm:twin`, `thm:search`, `thm:critical`, `prop:honest`,
`prop:lineage`, `thm:budget`, `thm:machine`). Optimisation claims were compared with brute-force optima on
random small instances; the scripts were run in a scratch directory and are not part of the repository. The
numbers are quoted below. Neither file contains a counting claim about circuits, so there was nothing to
recount under an encoding.

Verdict words: **correct**, **correct with fix** (true after the stated change), **wrong**, **unclear**,
**overclaim**.

## Summary

* Of the 60 numbered claims, 49 are correct as stated and A27 is a quoted theorem whose hypotheses hold.
  Seven are correct after a fix (A1, A6, A18, A19, A20, B17, B25). A24 has three correct items and one
  item, A24(4), that is wrong as stated. The conjecture B32 is false as stated and true under an added
  hypothesis (proved below). The conjecture A28 is half settled here and half open.
* **The one error of substance is in A.** A24(4), and the paragraph "What the model is a model of" in A's
  Section 0, say that for a program whose output distribution is decided inside it the background does not
  depend on that distribution, so that assumption (M2) holds and Sections 1 to 3 are exact. This is false
  in the toy. Other programs simulate the program: the wrapper of B11 around it has, at every context,
  $2^{-c}$ times the program's own mass there, on a different block. So the background has a part
  proportional to the attacker's mass. B says this (B11, B22, B26) and is right. The theorems of A's
  Sections 1 to 5 and 10 are correct as theorems about the abstract model. Their "only if" halves hold in
  the toy; their "if" halves (a weight $B\ge c\,O(W)$ wins the share $c/(1+c)$; the share tends to one)
  do not. The corrected lump statement is given under Disagreement 1.
* A's plain answer, item 10 ("the answer is yes exactly where the weight aimed at the uses exceeds their
  background; the toy proves this equivalence") is an **overclaim**: with the background defined as
  everything else, it is the definition of a majority (B17(i)); as a criterion on the attacker's weight it
  needs (M2).
* The remaining fixes are small: three edge cases of strict inequalities (A18, A19, A20), a boundary case
  (A6), a necessary condition called "the" constraint (A1(4)), a missing hypothesis in a summation
  (B17(ii)), and a wording error about non-existence of an optimum (B25(a)).
* Two things the authors left open are settled here. B32 holds exactly when the rule has arbitrarily
  large sets of pairwise incomparable contexts (proof in the B32 section). The first half of A28 holds:
  for a common stake function and finitely many contexts the contest has exactly one equilibrium,
  whatever the budgets (proof in the A28 section).

## Numerical checks

All agree with the closed forms. "SLSQP" is a constrained optimiser started from random points; "random
search" is 20000 random allocations on the budget simplex.

| claim | instances | result |
|---|---|---|
| A3(4), B20 | 12 random instances, 2 to 6 contexts, lognormal $s$, $O$, $B$ | closed form and SLSQP agree to relative $1.5\cdot10^{-10}$; random search never exceeded the closed form (for example $V^*=7.42746649$ both ways, random search $7.424026$) |
| A3(5) | same | central difference of $V^*$ in $B$ equals $\lambda_B$ to relative $10^{-5}$ |
| A5, A9(1),(2), A10(1),(3), A13(2) | same | identities, the finite active-set rule, both membership tests and the inequalities hold in all instances |
| A6 | 8 random two-class instances, 6 budgets each, thresholds included | $\lambda_B$, both shares, $V^*$ and both majority thresholds agree to $10^{-8}$ |
| A7 | $\gamma\in\{1.05,1.3,2,3.5\}$, 7 budgets each | $\lambda_B$, $V^*/S$, first attacked class $K$ and first majority class $K+2$ agree (for example $\gamma=1.3$, $B=0.01B_0$: $K=5$, $\theta=0.74183$, $V^*/S=0.237868$ both ways) |
| A8, B24 | $\gamma\in\{1.1,1.22,2,3\}$, 3 budgets each, quadrature | all formulas agree to 6 digits ($\gamma=1.1$, $B=0.01$: $\lambda=55.7441$, $V^*/S=0.557441$, attacked mass $0.012$, majority mass $0.002612$, $\int\theta^*=0.003750$); a log-spaced discretisation with $2\cdot10^5$ atoms agrees to 7 digits at $\gamma=1.5$ |
| A11 | 5 random instances; the example of item 5 | bounds of item 2 hold; $V^*/V(\mu^{\rm pr})\to\bar\rho/E_W[\rho]$ (five digits at $B=10^{-7}$); example: ratios $1.33$, $5.45$, $50.5$ for $\varepsilon=0.5,0.1,0.01$ |
| A14(2) | 4000 random instances, 2 to 9 contexts, exhaustive knapsack | no violation of the chain of inequalities; worst greedy-prefix ratio seen $0.071$ |
| A15(1), B23 | 8 random instances with $n(x)\in\{1,\dots,8\}$ | closed form and SLSQP agree to $10^{-8}$; majority test $n\rho>2^{1+1/n}\lambda$ holds |
| A16(4) | $R\in\{0.1,1,1.79,5\}$, $n\in\{1,2,5,50\}$ | random odds never beat $1-(1+R/n)^{-n}$; $\max_R(1-e^{-R})(1+R)/R=1.298426$ at $R=1.79328$ |
| A22(4) | grid | $\max_\Lambda\bigl(2\log_2(\Lambda+1)-\Lambda/2\bigr)=2.67214$ at $\Lambda=4.771$ |
| A25, A26 | 8 random instances, $k\in\{2,\dots,6\}$ | the symmetric profile is a best response to itself (closed form to $10^{-14}$, SLSQP to $10^{-8}$); $\lambda^{(k)}\ge\lambda_1$, single crossing and $V_{\rm eq}\le V_{\rm pool}$ in all; $\lambda^{(k)}=2.7860,\,3.3527,\,3.6305,\,3.8245,\,3.8814,\,3.88509$ for $k=1,2,4,16,256,65536$ against $\lambda^{(\infty)}=3.88510$ |
| B21(e) | the stated example | $\mu=0.915347$, $\theta^*=0.32348$ at the top and $0.04326$ in the bulk, $B_{1/2}=0.424214$ |
| B22 | 6 random instances, $\tau\in[0,2.5]$ | closed form and SLSQP agree to $10^{-8}$; $\theta^*(1+\tau)<1$ throughout |
| B25(c) | $G_i\propto i^{-2}$, $v_i=i$ | $\mu_k=14.3,\,394,\,6429,\,8.0\cdot10^4,\,8.9\cdot10^5$ for $k=10,\dots,10^5$; $\theta^*(x_{10})=0.907,\,0.511,\,0,\,0,\,0$ |
| codes | $n<2\cdot10^5$ | $\lvert\bar e(n)\rvert=2\lfloor\log_2n\rfloor+3$ and $n^{-2}/8\le2^{-\lvert\bar e(n)\rvert}<n^{-2}/2$ |

---

## Part A

### A0. The model (Section 0, not numbered)

Two remarks that later verdicts refer to.

* **(M3) and the definition of $O$.** $O(x)$ is defined as the mass of the programs "other than the
  attacker's" that print $x$ and $m$ more bits, and (M3) puts $w=\mu/(\mu+O)$. The predictor's probability
  is $\mu(x)/Z_m(x)$. The two agree only if every attacker program that prints $x$ and $m$ more bits prints
  an attack block; otherwise $Z_m>\mu+O$ and (M3) overstates the share. A16(4) and A24 use
  $Z_m$ directly and are not affected. A24(4) states the needed hypothesis.
* **(M2).** The paragraph "What the model is a model of" asserts that for one fixed program whose output
  distribution is decided inside it "the background is its complement, and (M2) holds". This is the error
  discussed under A24(4) and Disagreement 1.

### A1. When the budget is additive

**Verdict: correct with fix (item 4, wording).**

*My derivation.* `lem:basic`(i) holds for every machine and all bounds and gives
$E(u)\cap E(u')=\emptyset$ for incomparable $u,u'$. Two different pairs $(x,y)$, $(x',y')$ with
$|y|=|y'|=m$ give different strings, so item 1 follows. Item 2: incomparable contexts stay incomparable
after appending; equal contexts with different blocks of equal length are incomparable. Item 3: for $i<j$
the string $x_j$ extends $x_id_i$, and $y\in A(x_i)$ has $|y|=|d_i|$, $y\ne d_i$, so $x_iy$ is incomparable
with $x_id_i$ and with all its extensions. Item 4, example: by `def:universal` the machine that ignores
its input and prints $xyuy'0^\infty$ has a prefix word $p$; then $[p]\subseteq E(xy)\cap E(x'y')$ and
$\mu(x)=\mu(x')=2^{-|p|}=B$. Item 5 is `def:call` (one pair per calling program, prefix-free).

*Error.* Item 4 ends: "In general the constraint is $\sum_{x\in X'}\mu(x)\le B$ for every $X'$ on which the
strings $xy$ are pairwise incomparable." These constraints are necessary. They are not all the
constraints. In the configuration of the example, with $A(x)=\{y\}$ and $A(x')=\{y'\}$, one has
$E(x'y')\subseteq E(xy)$ and therefore $\mu(x')\le\mu(x)$, which no antichain constraint gives (they say
only $\mu(x)\le B$ and $\mu(x')\le B$). *Fix:* "a necessary constraint is". No later claim uses more than
necessity.

### A2. Water-filling lemma

**Verdict: correct.**

The tangent inequality $f_x(t)\le f_x(t^*)+f_x'(t^*)(t-t^*)$ with $t^*=\mu^*(x)$ gives $(*)$ in both cases
(for $\mu^*(x)=0$ one uses $f_x(0)=0$, $f_x'(0)\le\lambda$ and $t\ge0$). The three series on the right
converge absolutely, so summing is legitimate. Equality in the sum forces equality in every term because
the terms are ordered pointwise and the sums are finite. For strictly concave $f_x$ and $\mu^*(x)=0$,
$f'_x(0)<\lambda$, the term inequality is the composition $f_x(t)\le f_x'(0)t\le\lambda t$; equality in
the first already forces $t=0$. For $f_x\equiv0$ the argument given is right. No gap.

### A3. Square-root law

**Verdict: correct.**

1. On $\{\rho>\lambda\}$ the term is $\sqrt{sO/\lambda}-O=a^2-(\sqrt O-a)^2$ with $a^2=s/(4\lambda)$.
2. Uniform convergence on $[\lambda_0,\infty)$ by the bound in 1; strict decrease below $\bar\rho$; zero
   exactly from $\bar\rho$ on; divergence at $0$ because some $s(x_0)>0$.
3. Bijection of $(0,\bar\rho)$ onto $(0,\infty)$. For $\bar\rho=\infty$ the infimum $0$ comes from 1.
4. A2 with $f_x(t)=s\,t/(t+O)$, $f_x'(t)=sO/(t+O)^2$: checked, including $\sum f_x\le S$ for condition 3
   and uniqueness (each $f_x$ strictly concave or zero).
5. $(*)$ summed in both directions gives $\lambda_{B'}\le\bigl(V^*(B')-V^*(B)\bigr)/(B'-B)\le\lambda_B$ for
   $B<B'$; with continuity of $\lambda_B$ this is the derivative.

Numerical agreement as in the table.

### A4. Without (S)

**Verdict: correct.**

(1) $\mu/(1+\mu)<\mu$ for $\mu>0$, and the even spread over $N$ contexts gives $B/(1+B/N)\to B$.
(2) All mass on $x_k$ gives $kB/(B+1)$. The closing remark (that A3 needs only $\beta<\infty$, continuity
and $V(\mu^*)<\infty$) is right: if $\beta$ is finite at one $\lambda_0$ it is continuous on
$[\lambda_0,\infty)$ and tends to $0$ by dominated convergence.

A note for the comparison with B25(a): in example 2 the value $+\infty$ is attained, for instance by
$\mu(x_k)=cB/k^2$, since $\sum_kk\cdot ck^{-2}/(1+ck^{-2})=\infty$. A4 claims only $\sup V=\infty$, which
is right.

### A5. The solution on its active set

**Verdict: correct.**

On $A$: $O<s/\lambda_B$ and $\sqrt{sO}=s/\sqrt\rho<s/\sqrt{\lambda_B}$. The budget equation is
$B=\lambda_B^{-1/2}\Sigma_A-O(A)$, and $V^*=s(A)-\sqrt{\lambda_B}\Sigma_A$ because $s/\sqrt\rho=\sqrt{sO}$.
Cauchy–Schwarz gives the last inequality with the stated equality case. Membership: for
$\rho(x)<\bar\rho$ use strict monotonicity of $\beta$ on $(0,\bar\rho)$; for $\rho(x)=\bar\rho$,
$\beta=0<B$. The finite form follows after multiplying by $\sqrt{\rho(x_k)}$; the terms with
$\rho(x_i)=\rho(x_k)$ contribute zero, so the sum may run over all $i\le k$. Convention needed and not
stated: for $\rho(x)=0$ read $\beta(0)=\infty$.

### A6. Two classes

**Verdict: correct with fix (one remark at the boundary).**

All displayed formulas re-derived from A5 and confirmed numerically. The case analysis for the majority
on $X_1$ is right in both cases $2t\le1$ and $2t>1$.

*Error.* The sentence after the list: "if the stakes ratio is at least four, $\rho_1\ge4\rho_2$, the
majority at the high class costs exactly its background $O_1$ and is reached while the low class is still
untouched." The cost statement holds for $\rho_1\ge4\rho_2$. The second half fails at equality: for
$\rho_1=4\rho_2$, $B_c=O_1$, the majority needs $B>O_1=B_c$, and for every such $B$ the low class is
attacked. Numerically ($O_1=1$, $O_2=2$, $\rho=(4,1)$): at $B=1$, $w_1=0.5$ and nothing is on the low
class; at $B=1.000001$, $w_1=0.5000001$ and the low class carries $5\cdot10^{-7}$. *Fix:* "reached while
the low class is still untouched if $\rho_1>4\rho_2$". A9(5) has it right ("iff $\bar\rho>4\rho_2$").

### A7. Power-law tail, dyadic classes

**Verdict: correct.**

Re-derived: $c_\gamma-1=u(\sqrt2-1)/(1-\sqrt2u)$, $\sqrt2c_\gamma-1=(\sqrt2-1)/(1-\sqrt2u)$, ratio $1/u$, so
the intervals partition $(0,B_0]$. With $\lambda=\rho_02^K\theta^2$ the budget series sums to
$O_{\ge K}(c_\gamma/\theta-1)=B$. $V^*$ and the majority statement (at $k=K+1$ the share is at most
$\frac12$ because $\theta\ge2^{-1/2}$; at $k=K+2$ it exceeds $\frac12$ because $\theta<1$) are right. In my
first numerical run two instances sat exactly on a boundary ($B=B_0$ and $B=(\sqrt2c_\gamma-1)O_{\ge3}$)
and failed by rounding; moved off the boundary by $10^{-7}$ they agree. The half-open conventions in
item 1 are the right ones.

### A8. Pareto tail, continuum

**Verdict: correct** (as a theorem about the continuum model, which is what is claimed).

The three integrals were recomputed: $\beta(\lambda)=O(\{\rho>\lambda\})/(2\gamma-1)$,
$s(\{\rho>\lambda\})=\gamma\bar O\rho_0^\gamma\lambda^{1-\gamma}/(\gamma-1)$,
$\int_{\rho>\lambda}\sqrt{\lambda\rho}\,dO=\gamma\bar O\rho_0^\gamma\lambda^{1-\gamma}/(\gamma-\frac12)$. The
formula for $S$ assumes $O(\{\rho=\rho_0\})=0$ (total mass $\bar O$); this is implicit. The formulas
coincide with B24 for $\bar O=\rho_0=1$:
$\frac1{2\gamma-1}\bigl((2\gamma-1)B\bigr)^{(\gamma-1)/\gamma}=(2\gamma-1)^{-1/\gamma}B^{1-1/\gamma}$.

### A9. Where the attacker has the majority

**Verdict: correct.**

Items 1 to 3 follow from $w^*=(1-\sqrt{\lambda_B/\rho})_+$ and the monotonicity of $\beta$ (the case
$(1-\theta)^2\rho(x)\ge\bar\rho$ is covered because then $\beta=0<B$). Item 4: $\rho=0.1$ against $\rho=1$.
Item 5: for $\lambda\in[\rho_2,\bar\rho)$ only $X_{\rm top}$ contributes to $\beta$; correct including the
strict condition $\bar\rho>4\rho_2$. Item 6: $t\mapsto t/(t+O)$ is increasing and concave through $0$.

### A10. Stake-weighted share

**Verdict: correct.**

(1) $w\le1$ and $w\le\mu/O$. (2) lower bound by one context, upper bound by (1); dominated convergence
for $B\to\infty$. (3) Cauchy–Schwarz; $O(W)<\infty$ because $W\subseteq A$ and $O(A)<S/\lambda_B$. The
last line holds for any $W$ with $0<s(W)<\infty$ because $(1-a)_+\ge1-a$.

### A11. The proportional strategy

**Verdict: correct.**

`thm:critical`(a) gives the mass $2^{-a}2^{j-1}C(x)$ with $2^{j-1}\in(1/(2C(W)),1/C(W)]$, which is
$\mu^{\rm pr}$ up to the factor in $(\frac12,1]$, as said. Items 1 and 2 are algebra ($sk=C\rho$). Item 3:
$E_W[\rho]\le k_{\max}S/C(W)<\infty$; note that $\bar\rho$ is the supremum over all of $X$, not over $W$.
Item 4: with $k$, $r$ constant on $W$, $\mu^{\rm pr}=B\,O/O(W)$ and A2 applies with the stated $\lambda$.
Item 5 recomputed: $V(\mu^{\rm pr})=(1+\varepsilon)/(1+2\varepsilon)$, single-context value
$1/(2\varepsilon)$.

### A12. Lump theorem

**Verdict: correct** (inside (M1) to (M3)).

(1) Necessity by summing $\mu(x)>O(x)$ over $M$ (strict for nonempty $M$; impossible if
$O(M)=\infty$); sufficiency by $\mu=B\,O/O(M)$. (2) algebra. (3) $O=C/k\ge C/k_{\max}$ and
$s=\rho O\le\rho_{\max}O$ (this form avoids dividing by $\rho=0$). (4) definition of the infimum plus (1);
the bounds are (3) and $M=W$. (5) recomputed.

What must be kept in mind when the claim is used: necessity ("the majority on $M$ needs $B>O(M)$") holds
in the toy for the actual background. Sufficiency and item 2 assume that $O$ stays where it is when the
attacker moves mass, which is (M2). See Disagreement 1.

### A13. The stake-maximising attacker on a top class

**Verdict: correct.**

$\{\rho>t_W/4\}=W_t\cup N_t$ because every $x$ with $\rho(x)\ge t_W$ is in $W_t$. On $W_t$ the factor
$2\sqrt{\rho/t_W}-1$ is at least $1$, on $N_t$ it lies in $(0,1)$. Cauchy–Schwarz gives the upper bound;
$O(W_t)\le S/t<\infty$. Items 1, 3, 4 follow from A9(2) and A12(1). The upper bound agrees with B21(b)
when $W_t$ is the top level.

### A14. The most-probable-block predictor

**Verdict: correct** (item 3's hardness remark is quoted, as stated).

(1) $\mu>\tau$ on $M$ forces $B>\tau(M)$; conversely $\mu=\tau+\delta$. (2) The exchange argument is
right: $d\le d^*$ off $G_j$ and $d\ge d^*$ on $G_j$ give
$s(M)-s(G_j)\le d^*(\tau(M)-\tau(G_j))\le d^*(B-\tau(G_j))\le s(x_{j+1})$, the last step by maximality of
$j$. The inequality in the middle is strict only if $d^*>0$; the claim states it non-strictly, which is
right. (3) example recomputed (1.1 against 10). (4) follows; $\tau\ge O/(2^m-1)$ when the background is on
the other $2^m-1$ blocks. The model assumes one attack block per context; with several, masses on
different blocks do not add (B18(iv)).

### A15. $n$ independent samples at one context

**Verdict: correct.**

$f_x'(t)=snO^n/(t+O)^{n+1}$, $f_x'(0)=n\rho$; the stationary point and the takeover probability
$1-(\lambda/(n\rho))^{n/(n+1)}$ follow. Finiteness of the budget function:
$(n\rho/\lambda)^{1/(n+1)}\le n\rho/\lambda$ on the attacked set, so the function is at most
$S_n/\lambda$. Item 2: $\mu>(2^{1/n}-1)O$ termwise; the two bounds and Bernoulli's inequality are right.
Item 3 is $(1-w)^n\le e^{-nw}$. Agrees with B19(i) and B23.

### A16. $n$ uses in sequence along one world

**Verdict: correct.**

Items 1 to 3 are `thm:budget`(i) to (iii) on disjoint blocks, using
$\pi_m(d_i\mid x_i)\ge\xi(x_id_i)/\xi(x_i)$; because the blocks are disjoint the factor $m$ of
`thm:budget`(iv) does not appear. Item 4: A1(3) gives $\sum\mu_i\le B$;
$Z_m(x_i)-\mu_i\ge\xi(x_id_i)\ge\xi(z)$ because the programs for $x_id_i$ are disjoint from those counted
in $\mu_i$; so the odds sum to at most $R$ and the arithmetic–geometric inequality gives the bound.

Two remarks on wording, neither an error.

* "$\Pr[\text{some sample is supplied by }F]=1-\prod(1-w_i)$" is an equality when all $n$ samples are
  drawn at the contexts $x_i$; in the process that stops at the first takeover by anyone it is an upper
  bound.
* "Any number of uses in sequence is worth at most a factor two over a single one" compares two upper
  bounds. The instance-wise statement is also true and is the one worth stating: for fixed backgrounds
  $O_i$, $1-\prod_iO_i/(\mu_i+O_i)\le1-e^{-B/O_{\min}}\le2\cdot B/(B+O_{\min})$, and the last expression is
  what the same weight obtains at the single best use. The sharp constant is $1.2984$, as stated.

### A17. The returned block is run $n$ times

**Verdict: correct.**

(1) $\beta$ depends on $\rho/\lambda$ only. (2) I checked the formula in all three orders
$n\rho_W>\rho_R$, $=\rho_R$, $<\rho_R$ (in the last, $W$ is the low class of A6 and its threshold
$O_2+O_1(2/t-1)$ gives the same expression). (3) is A12(1).

### A18. Weighted seeker

**Verdict: correct with fix (cosmetic, an edge case of a strict inequality).**

*My derivation of the machine.* Total assigned length is $2^{j-1}G\le1$. For $\omega$ not ending in
$1^\infty$ with point $y$ in the interior of an assigned $I=[a,b)$ and $n_1$ least with
$D_{n_1}\subseteq I$: (i) no end point of any interval, assigned at any time, lies in $(a,b)$; (ii) for
$n<n_1$, $D_n\ni y$ is not inside $I$, so an end point of $I$ is interior to $D_n$, and $D_n$ lies in no
assigned interval; (iii) for $n\ge n_1$ the interior of $D_n$ is inside $(a,b)$. Hence the machine never
reads past $n_1$ bits (also before $I$ is assigned), reads up to $n_1$ once $I$ is assigned, and then
prints. Rational end points cause no difficulty. This is the author's argument and it is complete. The
bound on $a_g$: for $G\le1$, $|j_G|\le|\log_2G|+1$; for $G>1$, $j_G=1-\lceil\log_2G\rceil$ and
$|j_G|<\log_2G$. Items 1 to 3 are right; in item 3, $x\sqsubseteq x_{p'}P(x_{p'})$ with incomparable
contexts forces $x_{p'}=x$.

*Fix.* "The mass at $x$ is more than $\frac12\,2^{-a_g}\Gamma_g(x)/G$" is false at contexts with
$\Gamma_g(x)=0$ when the seeker has no mass there (which is the case under pairwise incomparable contexts,
by item 3). Read "at least", or "more than, where $\Gamma_g(x)>0$". The same applies to A19(1) and A20(1),
(2).

### A19. Which allocations one program can realise

**Verdict: correct with fix (the same edge case in item 1).**

(2) is the machine of A18 with contexts as labels; nothing in A18's proof used that labels are calling
programs. (3) lower semicomputability holds at contexts where $|P(x)|\ge m$; additivity as in A1. (4) is a
summary; the phrase "sub-probability" is to be read on sets $X'$ as in item 3.

### A20. The cost of aiming at stakes at least $n$

**Verdict: correct with fix (the same edge case: "more than ... at every context").**

(1) $g=1_{W_n}$ is a weight uniformly in $n$; $G=C(W_n)\le1$ so $j_n\ge1$;
$2^{-a_n-1}\ge2^{-|v'|-7}n^{-2}j_n^{-2}$ from $2^{-|\bar e(k)|}\ge k^{-2}/8$. (2) $g_t=h(r_t)$ is
nondecreasing in $t$ because $h$ is; the formula for $G_h$ is summation by parts with nonnegative terms;
$\Gamma_g(x)\ge h(n)C_{W_n}(x)$; $G_h\ge h(n)C(W_n)$. For $h(n)=\max(n,1)$,
$G_h=\sum_p2^{-|p|}\max(r(p),1)\le H_{\mathcal C}+S$. (3) as A18(3). The item needs $G_h>0$, which is
implicit.

### A21. Weighted honest twin

**Verdict: correct.**

The inputs whose point lies in the interior of an assigned interval are, up to a null set, the union of
the cylinders of the maximal dyadic intervals inside it (countably many when the end points are not
dyadic); on each the bits read are exactly the code of that interval, and the rest of the input is
uniform and independent. This gives item 1. Items 2 to 5 are bookkeeping and were recomputed. Same
statement as B8(a) and (c) in different notation.

### A22. Closure

**Verdict: correct.**

(1) The strings $t$ are distinct with total weight $2^{-h}2^{j-1}H_{\mathcal W}$; if all are in
$\mathcal W$ this is at most $H_{\mathcal W}$. (2) follows. (3) recomputed:
$G\ge\sum_t2^{-|t|}g(t)\ge2^{-h}2^{j-1}G_2$. (4) recomputed, including
$2\log_2(\Lambda+1)\le\Lambda/2+4$ (maximum of the difference $2.672$). That the strings $t$ have the
form `def:call` requires is in the note's proof of `prop:honest`(c), as said.

### A23. Example without closure

**Verdict: correct.**

All five items recomputed: $C(x_k)=2^{-|u|-k}$, $C(W_n)=2^{-|u|-n+1}$, $S=2^{1-|u|}$;
$\mu_n(x_k)=B_n2^{-(k-n+1)}$; $\sum_{k\ge n}2^{-|\bar e(k)|}>1/(8n)$; $\sum_kO(x_k)\le1$ by
incomparability; the two ratios; and the comparison at $x_n$. The conclusion of item 5 ("no allocation of
that weight") is safe here even without (M2), because the lower bound on $O(x_k)$ comes from the users
and the programs $v_D\bar e(k)$, which are in the background of every attacker disjoint from them.

### A24. Seekers that are not written down

**Verdict: items 1 to 3 correct; item 4 wrong as stated.**

Items 1 to 3 are identities and inequalities for a fixed word $p$ with $O_p:=Z_m-\mu_p$; all correct, and
item 1 matches the note's paragraph.

*Item 4.* It says: under its hypotheses "$O_p=O$ does not depend on $Q_p$, the model of Section 0 applies
with $B=2^{-|p|}$ ..., and among all output distributions the one that captures the most stake is
$Q_p=\mu^*_B/B$". The identity $O_p=O$ for the given $p$ is right. The independence is not, and with it
the optimality statement falls.

*Proof that the background follows the program.* Let the contexts in $X$ be pairwise incomparable and
enumerable (the situation of B11, and of a test). Let $w_0,w_1$ be the wrapper words of B11 for the
constant payloads $0^\infty$ and $1^\infty$, and $c=\max(|w_0|,|w_1|)$. Fix $p$ as in item 4 and a context
$x$; choose $b$ with $b^m\ne y_x$. For every $\omega$ with $x\sqsubseteq\mathrm{out}_U(p\omega)$ the input
$w_bp\omega$ prints $x\,b^m$. It does not begin with $p$, because by the hypothesis of item 4 every input
beginning with $p$ that prints $x$ and $m$ more bits continues with $y_x$. So these inputs are counted in
$O(x)$, and
$$O(x)\ \ge\ 2^{-|w_b|-|p|}\Pr_\omega\bigl[x\sqsubseteq\mathrm{out}_U(p\omega)\bigr]\ \ge\ 2^{-c}\mu_p(x).$$
This component of the background is, by construction, proportional to the probability with which the
program itself prints $x$. For two words of equal length it differs by $2^{-|w_b|-|p|}$ times the
difference of those probabilities. Consequently
$w_p(x)\le1/(1+2^{-c})$ for every such $p$ and every $x$, whereas the model with (M2) allows shares
arbitrarily close to $1$ (A9(3)). $\square$

*Corrected statement.* Write $O(x)=\tau(x)\mu_p(x)+O_0(x)$ with $\tau\ge2^{-c}$ the mass, per unit of the
program's mass at $x$, of the programs that follow it there on other blocks. If $O_0$ and $\tau$ do not
depend on the distribution, the stake-maximising distribution is that of B22,
$\mu=\frac{O_0}{1+\tau}\bigl(\sqrt{s/(\lambda O_0)}-1\bigr)_+$, with share
$\frac1{1+\tau}\bigl(1-\sqrt{\lambda O_0/s}\bigr)_+$, and the program has the majority exactly where
$\tau<1$ and $s/O_0>4\lambda/(1-\tau)^2$. In every case $V\le V^*(B)$ computed with $O_0$ in place of $O$:
A3 is an upper bound, not the optimum. When $\tau$ is only the wrapper's $2^{-c}$ the numerical
difference is negligible; the point is that the toy gives no upper bound on $\tau$, and for a written
seeker $\tau\ge2^{a-h}\varphi$ (A21, B8).

### A25. Best responses; the symmetric equilibrium

**Verdict: correct.**

(1) A3 with data $(s_i,A_i)$. (2) optimal $\mu_i$ vanishes off the support of $s_i$, so on that support
$A_i=O$. (3) recomputed: the quadratic's root lies in $[t,\sqrt t]$; the marginal return at $\nu$ is
$\frac\rho k\bigl((k-1)u+u^2\bigr)=\rho t=\lambda^{(k)}$ on the attacked set and $\rho\le\lambda^{(k)}$
elsewhere; $\beta^{(k)}$ is squeezed between $\beta$ and $S/\lambda$ termwise; uniqueness among symmetric
profiles follows from the same computation read backwards. Numerically the profile is a best response to
itself to $10^{-14}$.

### A26. The symmetric equilibrium against the pooled attacker

**Verdict: correct.**

(1) $u_k(t)<\frac12$ iff $kt<\frac14+\frac{k-1}2$. (2), (3): the key fact
$t/u^2=\frac1k\bigl(1+\frac{k-1}u\bigr)$ makes $\psi_k^2/\rho$ strictly increasing on
$\rho\ge\lambda^{(k)}$ for $k\ge2$; both case analyses are complete (in (3), $\rho^\dagger<\infty$ because
otherwise $\psi_k<\psi_1$ on the whole pooled attacked set). (4) the quadratic for $k+1$ at $u_k(t)$
equals $u_k-t\ge0$; monotone convergence; both inequalities for the limit. (5) A3(4). (6) A12(1) applied
to the sum. Item 6's sufficiency half again needs (M2).

### A27. Existence of an equilibrium, finite $X$

**Verdict: correct** (quoted theorem; hypotheses checked: compact convex strategy sets, payoffs continuous
because $O>0$, concave in the own strategy).

### A28. Uniqueness of the equilibrium

**Verdict: unclear as a whole (it is a conjecture); the first half is true and is proved here, the second
half stays open.**

**Proposition.** Let $X$ be finite and $s_i=c_is$ with constants $c_i>0$ (in particular $s_i=s$). Then
the game has exactly one equilibrium, for arbitrary budgets. In the symmetric game of A25(3) it is the
symmetric one.

*Proof.* Dividing $V_i$ by $c_i$ does not change best responses, so let $s_i=s$. Existence is A27. Let
$T=O+\sum_j\mu_j$ and $g_i=\partial V_i/\partial\mu_i=s\,(T-\mu_i)/T^2$ at each context. At one context
the Jacobian of $(g_i)_i$ is $J_{ii}=-2s(T-\mu_i)/T^3$, $J_{ij}=s(2\mu_i-T)/T^3$, so
$-(J+J^{\mathsf T})\,T^3/(2s)=N$ with $N_{ii}=2(T-\mu_i)$, $N_{ij}=T-\mu_i-\mu_j$. For a vector $z$ with
$a=\sum_iz_i$ and $b=\sum_i\mu_iz_i$,
$$z^{\mathsf T}Nz=T|z|^2+Ta^2-2ab\ \ge\ (T-\textstyle\sum_j\mu_j)\,(|z|^2+a^2)=O\,(|z|^2+a^2),$$
because $2ab\le2|a|\,|\mu|_2|z|\le|\mu|_1(a^2+|z|^2)$. So $J+J^{\mathsf T}$ is negative definite at every
context with $s>0$, at every profile. Let $\mu,\mu'$ be equilibria and $z=\mu'-\mu$. Each $V_i$ is concave
and differentiable in $\mu_i$ on a convex set, so $\langle g_i(\mu),\mu_i'-\mu_i\rangle\le0$ and
$\langle g_i(\mu'),\mu_i-\mu_i'\rangle\le0$. Adding over $i$:
$\langle g(\mu')-g(\mu),z\rangle\ge0$. But
$\langle g(\mu')-g(\mu),z\rangle=\int_0^1z^{\mathsf T}J(\mu+tz)\,z\,dt=\frac12\int_0^1z^{\mathsf T}(J+J^{\mathsf T})z\,dt$,
a sum over contexts that is negative unless $z$ vanishes at every context with $s>0$. At contexts with
$s=0$ all best responses vanish (A3), so $z=0$ there too. Hence $\mu=\mu'$. $\square$

The inequality $z^{\mathsf T}Nz\ge O(|z|^2+a^2)$ held in $2\cdot10^5$ random trials (it is tight for
$z=e_i$, $\mu=|\mu|_1e_i$). Damped best-response dynamics from 20 random asymmetric starts reached one
point (spread below $2\cdot10^{-14}$) in 5 instances with common stakes and unequal budgets. This is
Rosen's diagonal strict concavity with equal weights; the house share $O>0$ is what makes it strict.

*What stays open.* Stake functions that are not proportional: the weights that would make the argument
work depend on the context. In 8 exploratory instances with unrelated stake functions the dynamics also
reached a single point from 40 starts each; that is no proof. Countably many contexts: the argument
extends if the pairings converge, which I did not write out.

---

## Part B

### B1. The predictor sees only the context

**Verdict: correct.** (a) is the definition of $\pi_m$. (b) $Y$ is drawn independently of $\omega$ given
$X$; Tonelli.

### B2. The candidates

**Verdict: correct.** The table is a set of modelling remarks; each entry that is a mathematical
statement checks out. Candidate 4: $C(x)$ is lower semicomputable because the rule is enumerable. The
entry "not semi-decidable": with $p_e=g_2\bar e(e)$ the class "the block keeps control for ever" is
$\{p_e:e\text{ does not halt}\}$, not enumerable; "at least $t$ steps" is decidable. The entry for
candidate 3 is B19(i).

### B3. A stake the context does not show

**Verdict: correct.** (a) arithmetic; (b), (c) are B1(b).

### B4. Prior weight, or number of worlds, as the stake

**Verdict: correct.** (a) from B5 and $\sum_xC_{\mathcal W}(x)=H_{\mathcal W}$. (b) $[p]=[p0]\cup[p1]$
and the new programs satisfy `def:call`. The remark $\rho\le1/\varphi$ is right. One phrase is loose: "the
uses at the top of the stake ordering are exactly those that no seeker longer than they are can outweigh";
*every* user $p$ has this property at its context ($F[x]\le2^{-a}<2^{-|p|}\le C(x)$ when $a>|p|$), not
only the top ones.

### B5. Conservation

**Verdict: correct.** `lem:basic`(i). Same content as A1(1), (2). A1(3) extends it to cut points along
one sequence, which B's doubt 2 leaves open.

### B6. Against the users alone

**Verdict: correct.** (a) is `thm:critical`(a) for the class; equality under (INC) because the machine
prints nothing off its intervals and $x\sqsubseteq x_{p'}P(x_{p'})$ forces $x_{p'}=x$. (b) from B5; (c)
rewrites (a).

### B7. Weighted search

**Verdict: correct.** Every lower semicomputable $g$ arises: replace a rational approximation $g_t$ by
$\lfloor2^tg_t\rfloor/2^t$, which is nondecreasing in $t$, and write each dyadic increment as a finite sum
of powers of two. With dyadic end points each $I_i$ is a finite union of maximal dyadic intervals, and
here "exactly" holds for every input in the cylinder, with no null set: for $n<|\sigma|$ the dyadic
interval is not inside $I_i$ but meets it, so an end point of $I_i$ is interior; for $n=|\sigma|$ the
machine stops; no end point of another interval is interior to $I_i$.

### B8. The honest twin for an arbitrary weighting

**Verdict: correct.**

(a) The unread rest of the input after a prefix-free stopping set is uniform and independent; the two
families are disjoint and both lie in $E^m(x)$ when $|P(x)|\ge m$. (b) read off. (c) the mass formula was
recomputed: $2^{-|r_0|-|\gamma|}\sum_{i:x_{p_i}=x}2^{-n_i}\cdot2^{-|u|}\lambda\{\dots\}$. (d) follows.

One point of presentation. In (c) the seeker's programs are $r_0\gamma\sigma u_P\omega''$: the word $u_P$
comes after the search bits $\sigma$, so these programs do not share a prefix word of length $a$, as (a)
assumes. Nothing breaks: the mass at $x$ is still $2^{-a}g(x)$ with $a=|r_0|+|\gamma|+|u_P|$, and the two
families are disjoint because the $\sigma$ form a prefix-free set and $u_P,u_{\mathrm h}$ are
incomparable. The same holds in B14. Remark 2 after the claim (the twin of a neighbouring aim costs a
constant more) is not a numbered claim. It is true at every context at which some user goes on with
probability above one half: from a description of $g$ one enumerates, at each context, the first user
found with $\varphi_p>\frac12$ (an enumerable property) and gives it the mass $g$ puts on the context.

### B9. Programs that print the context without using the answer

**Verdict: correct.** $S\le M$ gives the first display; $S>\psi M/2$ and $S\le2^{-a}P_{\mathcal W}$ give
the second.

### B10. Other concentrated seekers

**Verdict: correct.**

(a) two different blocks at one context have total probability at most one. (b)
$C(\mathcal W_N)=2^{-|g_0|-|\bar e(N)|-N}<2^{-a_P-1}$ iff $N>|w_P|+1-|g_0|$; each seeker's whole weight
$2^{-a_P}$ is on the one context. (c) I re-derived `thm:machine`(i):
$M_{U_k}(xy)\ge\frac12M_U(x)$ and $M_{U_k}(x)=(\frac12+2^{-k-1})M_U(x)$ at first hits; the elements of $G$
are pairwise incomparable, so each is a first hit; the transported rule satisfies `def:call` on $U_k$;
the hypothesis in the new lengths is again $N>|w_{P_1}|+1-|g_0|$.

### B11. Wrappers: a floor for call rules and a ceiling for every program

**Verdict: correct.**

$\mathrm{Tw}'$ may read more input than $U$ needed for $x$ while it waits for the enumeration; that does
not matter, because for every $\omega\in E(x)$ it prints $x\,P'(x)$, and (INC) makes the context found
unique. (a) and (b) follow; in (b) the hypothesis "every input of $F$ that prints $x$ continues with a
block of $A(x)$" is what makes the wrapped inputs fall outside $F$. (c) is a definition. This claim is
what decides Disagreement 1.

### B12. The whole account at one context

**Verdict: correct.** It is an identity once the families are disjoint, which (PF) gives. The sentence
"as the channel narrows it tends to $0$" carries its own condition ("if $N^m_*$ is small as well"); as
written it is not a theorem, and it is not presented as one.

### B13. A class that contains "enumerate the class and run a member"

**Verdict: correct.** $\mathrm{Fm}$ reads $\epsilon$ and nothing of the rest before $x_1$ is complete;
the strings $n\epsilon$ are pairwise incomparable because $\Phi$ is a prefix machine. For a test (and for
a decidable subset of first hits) $n\epsilon$ is a handing-over program: $U$ has read exactly $n\epsilon$
when the hit is complete.

### B14. Under closure under search there is no narrow channel

**Verdict: correct.** Summing over contexts gives $2^{j-1}\le2^h$ for $g(p)=2^{j-1-|p|}$, which is
A22(1); the two closure notions give the same bound.

### B15. Without closure the gap is unbounded

**Verdict: correct.** All quantities recomputed. That the class is not closed also follows from B13 for
large $N$, without appeal to the form of $n\epsilon$.

### B16. The gap is filled by programs that are not users

**Verdict: correct.** The programs $r_0\gamma_e\sigma$ print $x$ with total mass
$2^{-|r_0|-|\gamma_e|}2^{j-1}C_{\mathcal W}(x)$.

### B17. Definition (a)

**Verdict: correct with fix (a missing hypothesis in item (ii)).**

(i), (iii), (iv) are right ((iv): with weights $C^m(x)=Z_m(x)$ the average of $\theta$ is
$\sum_xb_A(x)/\sum_xZ_m(x)$). (ii): $Z_m\ge b_A+\varphi^{\bar A}_{\mathcal W}C_{\mathcal W}$ gives the
bound and both necessary conditions.

*Gap.* "Summing over disjoint classes all of whose contexts are pairwise incomparable" uses
$\sum_{\mathcal W}B_{\mathcal W}\le$ total weight of takeover programs (B5). Classes that are disjoint as
sets of calling programs can share a context, and then $b_A(x)$ is counted once per class. *Fix:* require
the classes to have pairwise disjoint sets of contexts (true for classes defined by the context, the case
R1).

### B18. Definition (b): most-probable block

**Verdict: correct.** (ii): seeker $2^{-a}g(x)$ against the twin's $2^{-h}g(x)\bar\varphi_g(x,d)$. The
rest is definitional. (v) assumes a deterministic tie rule.

### B19. Definition (c): $n$ samples of which one suffices

**Verdict: correct.** (i) $1-e^{-t}\le t$. (ii) B11 with a payload in $A$. (iii) definitions. (iv) with
the true block appended each time the blocks are adjacent and
$\prod_i\xi(x_id_i)/\xi(x_i)=\xi(x_{n+1})/\xi(x_1)\ge\xi(z)/\xi(x)$.

### B20. Optimal allocation against a passive background

**Verdict: correct.** Same theorem as A3, for a finite background measure (A3 does not need
$O(X)<\infty$). $\mathcal B(\mu)\le\sqrt{VG(\mathcal X)/\mu}$; the pointwise tangent inequality
integrates. Uniqueness in fact holds $G$-almost everywhere, also on $\{\rho=0\}$.

### B21. Are the attackers the majority at the top?

**Verdict: correct.** (a) holds also when $\mathcal B(\rho_0/4)=0$ (then both sides are true for every
$B>0$); the proof's "and $\mathcal B(\rho_0/4)>0$" is not needed and is not always true in the continuum
case. (b) to (d) recomputed. (e) recomputed and confirmed numerically; it agrees with A6
($w_1=(B+O_2(1-t))/(B+O_1+O_2)=0.32348$, threshold $O_1+O_2(2t-1)=0.42421$).

### B22. A background that follows the attackers

**Verdict: correct.** $h_\tau'(t)=((1+\tau)t+1)^{-2}$; stationarity gives $(1+\tau)\beta+1=\sqrt{\rho/\mu}$
and $\theta^*=\frac1{1+\tau}(1-\sqrt{\mu/\rho})_+$; the majority condition is
$\sqrt{\mu/\rho}<(1-\tau)/2$. Confirmed numerically.

### B23. $n$ samples

**Verdict: correct.** Same as A15(1). The approximation "about $\ln(n\rho/\mu)/(n+1)$" is for fixed
$\rho/\mu$.

### B24. Heavy-tailed stakes

**Verdict: correct.** All five formulas and all quoted numbers recomputed ($55.7\%$, $0.375\%$,
$0.261\%$, $2.71\%$; $\max_\alpha4^{-\alpha}(2\alpha-1)=0.26537$ at $\alpha=1.2213$). "$0.4\%$ of the uses"
means $\int\theta^*dG$, in units of background mass.

### B25. Unbounded stakes

**Verdict: correct with fix (wording of (a)).**

(a) $\sup\Phi=\infty$ is right ($G(x)\le M(x)\le1$). *Error:* "no allocation is optimal", and after the
claim "for every allocation there is a better one further out". There are allocations of value $+\infty$:
choose contexts $x_i$ with $v(x_i)\ge4^i$ and put $b(x_i)=B2^{-i}$; then
$\Phi\ge\sum_i4^iB2^{-i}/(B2^{-i}+1)\ge\frac B{B+1}\sum_i2^i=\infty$ (partial sums $30$, $1021$,
$1.0\cdot10^6$, $1.1\cdot10^{12}$ after $5,10,20,40$ terms with $B=\frac12$). *Fix:* "$\sup\Phi=\infty$;
no allocation of finite value is optimal, and the objective does not rank the allocations of infinite
value." (b) recomputed ($K(2^{2^k})\le2\log_2(k+1)+c$). (c) recomputed and confirmed numerically.

### B26. How the model relates to the toy

**Verdict: correct** (status HEURISTIC; its three reasons are each true). The third reason, that the
background is not passive, is a theorem: see the proof under A24(4). The sentence "presumably the optimum
can be approximated within constant factors" remains unproved, as the author says.

### B27. A schedule caps a search by tries

**Verdict: correct.** `def:universal` gives $r_U(v\omega,1)=|v|+r_{\mathrm{Tr}}(\omega,1)\ge|v|+i$ and
each step reads at most one bit; the union bound gives $I\,q(x)$. "Print $x$" is to be read as "succeed
with context $x$" (equal under (INC)).

### B28. Honest counterparts

**Verdict: correct.** "The programs of $p$" means those that print $x$ and a block of $A(x)$; with that
reading the bound is immediate, also when $p'=p$.

### B29. Under a test

**Verdict: correct.** `thm:calibration` with the set of pairs $\{(x,y):x\in\mathcal X',y\in A(x)\}$; the
theorem conditions on going on for $m$ bits, as B29 does.

### B30. Where users print nothing after the use

**Verdict: correct.** Two prefixes of one output are comparable, so (INC) forces $x_p=x$.

### B31. The lump must be told the width of the channel

**Verdict: correct.** For $j'>j_{\mathcal W}$ the note does not say what the machine does; with the
natural reading (intervals beyond $1$ are unreachable) the claim holds, in the form "no mass from the
users enumerated later".

### B32. The bits that name the width cannot be saved

**Verdict: correct with fix. As stated the conjecture is false for some rules; with the hypothesis below
it is a theorem.** (The constant $c$ in the statement is not used.)

**Theorem.** Let the numbering $e\mapsto\mathcal W_e$ be acceptable.

1. If for every $K$ the rule has $K$ calling programs with pairwise incomparable contexts (in particular
   under (INC) with infinitely many contexts), there are no word $v$ and $\beta>0$ with the property of
   B32.
2. If the rule's contexts contain at most $r$ pairwise incomparable strings, there is a word $v$ with the
   property for $\beta=1/r$.

*Proof of 1.* Suppose $v,\beta$ exist. Choose $K$ with $\sum_{i\le K}1/(2i)>1/\beta$ and calling programs
$p^{(1)},\dots,p^{(K)}$ with pairwise incomparable contexts $x^{(1)},\dots,x^{(K)}$, ordered so that
$|p^{(1)}|\ge\dots\ge|p^{(K)}|$. For a string $\epsilon$ let $\mathcal W[\epsilon]$ be enumerated as
follows: put $p^{(1)}$ in; for $i<K$, once $p^{(i)}$ is in, wait until
$\lambda\{\omega:x^{(i)}\sqsubseteq\mathrm{out}_U(v\epsilon\omega)\}$, which is lower semicomputable, is
seen to exceed $\beta/(2i)$, and then put $p^{(i+1)}$ in. An index of $\mathcal W[\epsilon]$ is computable
from $\epsilon$, and there is a computable $n\mapsto\epsilon_n$ with $\Phi(\epsilon_n)=n$. By the
recursion theorem there is $n$ with $\mathcal W_n=\mathcal W[\epsilon_n]$. Let $i$ be the last stage
reached. Then $\mathcal W_n=\{p^{(1)},\dots,p^{(i)}\}$, and since the weights are nondecreasing,
$P_{\mathcal W_n}(x^{(i)})\ge1/i$. By the assumed property the programs $v\epsilon_n\omega$ print $x^{(i)}$
with probability at least $\beta/i>\beta/(2i)$, so for $i<K$ the next stage is reached. Hence $i=K$, and
the $K$ events "$x^{(l)}$ is printed" have probabilities above $\beta/(2l)$ for $l<K$ and at least
$\beta/K$ for $l=K$. They are disjoint, so $\sum_{l\le K}\beta/(2l)\le1$, a contradiction. $\square$

*Proof of 2.* A set of strings with at most $r$ pairwise incomparable elements is a union of at most $r$
chains (Dilworth), and a chain under the prefix order consists of prefixes of one finite or infinite
sequence $z_l$. Each infinite $z_l$ is computable: beyond the point where it has separated from the
other chains, it is the limit of the enumerated contexts that extend a fixed prefix. Let the machine skip
a $\Phi$-program on its input (run $\Phi$ on it), then use the next $\lceil\log_2r\rceil$ bits to choose
$l$ and print $z_l$. Every context is printed with probability at least $2^{-\lceil\log_2r\rceil}$, which
is at least $P_{\mathcal W}(x)/(2r)$; with a choice that is exactly uniform (rejection sampling) it is
$1/r$. $\square$

So the conjecture holds exactly when the contexts contain arbitrarily large antichains. A rule with one
context, or one whose contexts are the cut points of a single sequence, is a counterexample to the
statement as written. The author's sketch (batches each $2^k$ times heavier, giving $\beta k\le1+o(1)$)
is the same idea; ordering by weight makes the heavier batches unnecessary and gives the harmonic bound.

---

## The bottom lines of the two files

**A, "PLAIN ANSWER".** Items 2 to 9 state A3 to A23 accurately, with their assumptions. Item 1 is right
"in the abstract model", as it says. **Item 10 is an overclaim.** "The answer is yes exactly where the
total weight aimed at the high-stake uses exceeds the background of those uses ...; the toy proves this
equivalence." With the background taken as everything else at the realised allocation, this is the
definition of a majority. Read as a condition the attacker can meet by bringing more weight, it needs
(M2), which fails in the toy. For a written seeker with $2^{a-h}\varphi\ge1$ the answer is no at every
weight (A21 itself). The sentence should read: "a majority requires that the weight exceed the background;
it is sufficient only for the part of the background that does not follow the attacker."

**B, "VERDICT".** S1 (true, with four qualifications), S2 (false: B10(b) is a valid counterexample),
S3 (two readings), S4 (false as a limit, under (INC) and with a computable block outside the takeover
set) and S5 (not decided) are each supported by the claims cited. In S1, third bullet, the derivation
$H_{\mathcal W}>2^{-j}\ge2^{-a-1}$ under a test is right.

---

## Disagreements between the files, and their resolution

**1. Is the background passive? (A: yes for a program that chooses its own output, Section 0 and A24(4).
B: no, B11, B22, B26.)** B is right. Proof: under A24(4). Consequences, each a short computation in the
model $O=O_0+\tau\mu$ with $\tau\ge0$ fixed:

* share: $w=\mu/((1+\tau)\mu+O_0)<1/(1+\tau)$;
* *corrected lump theorem:* the majority at every use of $M$ is feasible iff $\tau<1$ on $M$ and
  $B>\sum_{x\in M}O_0(x)/(1-\tau(x))$; a share of at least $\theta$ on $M$ is feasible iff
  $\theta(1+\tau)<1$ on $M$ and $B\ge\sum_M\theta\,O_0/(1-\theta(1+\tau))$ (from
  $\mu\ge\theta((1+\tau)\mu+O_0)$);
* the stake-optimal allocation is B22's; A3 with $O_0$ is an upper bound on the value;
* in the toy $\tau\ge2^{-c}$ for every program under (INC) (wrappers), and
  $\tau\ge2^{a-h}\bar\varphi_g$ for a seeker with a written search (twin).

What survives of A unchanged: every necessary condition, read with the background that is actually there
(A12(1) "only if", A12(3), A13(3) "if $B\le O(W_t)$ no allocation has", A24(2), A26(6) "only if"); A16
and A18 to A23, which do not use (M2); and the optima of A3, A14 and A15 as upper bounds on what the
attacker captures, when they are computed with the part $O_0$ of the background that does not follow.
What does not survive as a statement about the toy: A9(3) "$w^*\to1$", A12(2), A13(1) and (3) as
sufficient conditions, and A24(4).

**2. Does the takeover probability tend to one as the stake grows? (A9(3), A10(2), plain answer 2: the
share is $1-\sqrt{\lambda_B/\rho}$. B, S4: false in the toy.)** Both files prove the same formula in the
passive model (A3 and B20 are identical). The disagreement is disagreement 1. In the toy, under (INC) and
with a computable block outside the takeover set, $\theta\le1-2^{-c}$ (B11(a), which I verified), so B is
right about the limit, and B's own caveat (the ceiling is within $2^{-c}$ of one) is the honest size of
the correction when only wrappers follow.

**3. "They win exactly where the weight exceeds the background" (A, plain answer 10) against "a seeker
that outweighs the users does not thereby supply the majority" (B, S2).** No mathematical conflict: A
compares with the background, B's S2 is about the users. A's sentence is an overclaim for the reason given
above; B12 is the correct accounting.

**4. Closure.** A22 (the twin's programs for the class count as users of the class) and B13/B14 (first
member; member in proportion to an aim) formalise it differently. Both sets of statements are correct.
For the proportional aim they give the same inequality $2^{j-1}\le2^h$. B13 gives the sharper rarity bound
$C(\mathcal W_e)\ge2^{-K(e)-|n|}$, which for the classes $W_n$ is about $1/n$ up to logarithms, against
A22(4)'s $n^{-2}$ up to logarithms and $n^{-4}$ explicitly; the hypotheses differ, so neither refutes the
other.

**5. Non-existence of an optimum for unbounded stakes.** A4(2) says $\sup V=\infty$; B25(a) adds "no
allocation is optimal". A's statement is the correct one; see B25.

**6. Repetition.** A15 and B19(i), B23 agree. A16 and B19(iv) agree; A16(4) is the sharper statement
(a bound in terms of the attacker's weight). A17 and B2 (candidate 1) agree that "the block is run $n$
times" is not an event of the toy and acts only as a label.

**7. The most-probable-block predictor.** A14 treats thresholds $\tau(x)$ as given and gets a knapsack;
B18 shows that against the twin the threshold scales with the seeker's own mass, so the comparison is
again one of constants ($2^{-|u_P|}$ against $2^{-|u_{\mathrm h}|}\max_d\bar\varphi_g(x,d)$). Both are
correct; A14 inherits disagreement 1.

**8. Agreement worth recording.** A21 = B8 (twin; $h-a$ independent of the aim for a uniform
construction). A8 = B24 (identical formulas). A13(2) and B21(b) (same threshold at the top level). A6 and
B21(e) (same numbers). A23 and B15/B10(b) (without closure the seeker outweighs the users without bound
and the majority is decided by constants of the machine). A20 and B31 (the bits for $j$ are paid in
both).

---

## What is missing

1. **The allocation problem with a background that follows.** B22 solves it for a ratio $\tau(x)$ that is
   given. Neither file combines it with A's active-set analysis (A5, A7, A13) or with several attackers
   (A25, A26), and neither bounds $\tau$ from above for any class of programs. The corrected lump theorem
   above is the first step only.
2. **Sizes.** Nothing evaluates $|u_P|-|u_{\mathrm h}|$, the wrapper constant $c$, $\varphi$, or
   $O(W_n)$ on any concrete machine. Every "majority" statement is conditional on these.
3. **Nested contexts.** All optimisation claims assume additivity. A1(4) shows it fails when a later
   context contains an earlier attack block, which is the situation of `prop:lineage`(b), the only place
   in the toy where a block is in effect "run more than once". The problem under the true constraints
   (antichain sums and the nesting inequalities noted under A1) is not posed.
4. **Resource bounds.** Apart from A16, B19(iv) and B27, everything is for unbounded resources. The
   weighted seeker and its twin have the long start-up of the rescaler; the wrappers that produce $\tau$
   need the slack of `thm:twin`. No bounded version of A18, A21, B8, B11 or B14 is given.
5. **Realisability of the optimum.** Whether $\mu^*_B$ (or a constant-factor minorant of it) is lower
   semicomputable when $s$ and $O$ are only lower semicomputable is open in both files (A19(4), B26).
6. **(M3) with background mass on the attack block.** A's doubt 2 gives the marginal return
   $s(O-b)/(\mu+O)^2$ and stops.
7. **Uniqueness of the equilibrium for stake functions that are not proportional**, and for countably
   many contexts (A28; the common-stake case is proved above).
8. **The self-reproducing weighted seeker** (the analogue of `thm:search`(c) for A18) is stated as not
   done.
9. **A definition of stake inside the toy.** Both files attach stakes as labels (A: $r(p)$ enumerable
   from below; B: R1 to R3). No claim connects the label to anything the world does after the handover.
10. **"Most cases" under a following background.** B17 gives necessary conditions; a two-sided statement
    by prior mass and by stake, of the kind A12(4) gives in the passive model, is missing for the
    corrected model.
11. **$n$ samples with a following background.** B19(ii) notes the formula $1-(\tau/(1+\tau))^n$ at the
    cap; the optimal allocation for the objective of A15 with $\tau>0$ is not computed.
12. **The case $\xi(z)=0$** (a world outside the predictor's bounds) is excluded from A16 and B19(iv)
    and not otherwise treated.
