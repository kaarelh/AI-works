# Circuits in place of programs: the learning view (B)

Research note for `malign-prior-toy`, written by Claude on 13 November 2026. Not reviewed by a human or by another referee. Pencil-and-paper mathematics, with one exact computation (`circuit_count.py`, output reproduced in Section 9).

**Question.** The note asks, for a multiverse of programs in which the predictions of a bounded Solomonoff predictor are used critically, what share of the uses end with the world running something supplied by a hypothesis that is not the world's own continuation. Here Boolean circuits replace programs, as hypotheses and as worlds. This file takes the learning view: the predictor is Bayesian learning with a prior over circuits, the data are values of an unknown target on some inputs, and a critical use is a query at a new input whose answer is acted on.

**Status labels.** PROVED: full proof in this file. COMPUTED: exact enumeration by the script. KNOWN: a result from the literature, cited from memory and not checked against the source. HEURISTIC, CONJECTURE, OPEN: not proved, with the reason given.

**Short answer.** See the section OVERALL VIEW at the end. In one sentence: with circuits the prior weight of a hypothesis pays for every gate of its computation, so the cheap searching and simulating hypotheses of the program setting disappear, and what remains at an off-distribution critical query is unaimed underdetermination (constant-order posterior share off the target in the small cases computed, exactly one half in one provable family, exactly zero in another) plus triggered payloads at a price of one gate per gate of the trigger.

**Index of claims.**

| claim | content | status |
|---|---|---|
| CB1 | calibration on worlds drawn from the prior | PROVED |
| CB2 | the prior is a prior on cores; simplicity bias | PROVED |
| CB3 | price of a gate | PROVED |
| CB4 | mistake bound | PROVED |
| CB5 | random query from the training distribution | PROVED |
| CB6 | one off-data query is not covered | PROVED (inequalities), COMPUTED (examples) |
| CB7 | last-gate dichotomy | PROVED |
| CB8 | never-varied bit, length prior: two-sided polynomial bound | PROVED |
| CB9 | no idle gate in a minimum circuit | PROVED |
| CB10 | minimum circuits read no frozen input | PROVED |
| CB11 | uniform prior with slack | PROVED, conditional |
| CB12 | exact shares for small circuits | COMPUTED |
| CB13 | size of the deviation share in general | CONJECTURE, HEURISTIC |
| CB14 | floor for triggered payloads | PROVED |
| CB15 | ceiling for separable triggered circuits | PROVED |
| CB16 | aiming at $N$ unrelated uses, in bits | PROVED |
| CB17 | the same in gates; what fails for one set | PROVED |
| CB18 | no refund for the rarity of uses | PROVED (1 to 3), ARGUED (4) |
| CB19 | simulation and deliberation cost gates | KNOWN (cited from memory), PROVED (elementary parts) |
| CB20 | no circuit hands over its own description | PROVED |
| CB21 | AND family: half of the minimum circuits are off the target | PROVED |
| CB22 | the minimal-circuit question in a precise form | OPEN |
| CB23 | a general solver as the smallest circuit | HEURISTIC |
| CB24 | weight sharing and recurrence | PROVED (1), ARGUED (2, 3) |
| CB25 | where neural network training sits | GUESS |
| CB26 | stakes | PROVED (1 to 3), ARGUED (4) |

---

## 1. Setting

### 1.1 Circuits

Inputs are $u\in\{0,1\}^k$, $k\ge 2$. The basis $\mathcal B$ is the set of all $B=16$ Boolean functions of two arguments. A **circuit of size $s$** is a sequence of gates $(\tau_i,a_i,b_i)_{i=1}^{s}$ with $\tau_i\in\mathcal B$ and an ordered pair of predecessors $a_i,b_i\in\{1,\dots,k+i-1\}$: wires $1,\dots,k$ are the inputs and wire $k+j$ is gate $j$. Constants and negations are available only as gates (for instance $\tau(a,a)$). The **output** is the value of the last gate; $f_c\colon\{0,1\}^k\to\{0,1\}$ is the function computed. For $m$ output bits the outputs are the last $m$ gates; unless said otherwise $m=1$. Let $\mathcal C_s$ be the set of circuits of size $s$,
$$N_s=|\mathcal C_s|=\prod_{i=1}^{s}B\,(k+i-1)^2,\qquad p_i=\frac{1}{B\,(k+i-1)^2},$$
so $N_s=1/(p_1\cdots p_s)$ and specifying gate $i$ takes $\log_2(1/p_i)=\log_2 B+2\log_2(k+i-1)$ bits. $C(f)$ is the least size of a circuit computing $f$.

A gate is **active** if it is the last gate or an ancestor of it, and **dead** otherwise. A circuit is **reduced** if all its gates are active; $\mathcal R_a$ is the set of reduced circuits of size $a$. The **core** of $c$ is the reduced circuit obtained by deleting the dead gates and renumbering in order; it computes $f_c$.

### 1.2 Priors, data, posterior, predictor

* **Uniform prior $\mu_s$**: uniform on $\mathcal C_s$.
* **Length prior $w_L$**: $w_L(c)=2^{-s}/N_s$ for $c\in\mathcal C_s$, $s\ge1$. It sums to $1$, and $-\log_2 w_L(c)=s+\sum_{i\le s}\log_2(1/p_i)$ is the length of the description "size in unary, then the gates".

$w$ stands for either. **Data** are $D=(S,f^*|_S)$ for a set $S\subseteq\{0,1\}^k$ of inputs and a target $f^*$. A circuit **fits** $D$ if $f_c=f^*$ on $S$; $\mathrm{Cons}(D)$ is the set of fitting circuits and $W(D)=w(\mathrm{Cons}(D))$. Let $s_D$ be the least size of a fitting circuit and $\ell_D=-\log_2 W(D)$. The posterior is $w(c\mid D)=w(c)\mathbf 1[c\in\mathrm{Cons}(D)]/W(D)$. At a query $u$ the predictor's distribution is
$$\pi(y\mid u,D)=w\{c:\ f_c(u)=y\mid D\}.$$
The **sampling predictor** returns $Y\sim\pi(\cdot\mid u,D)$ (equivalently: draw a fitting circuit from the posterior and return its answer); the **majority predictor** returns a most probable $y$. This is the note's $\pi_m(y\mid x)$ with the context $x$ replaced by $(D,u)$.

### 1.3 Worlds, critical uses, and the malign prior hypothesis

A **world** is a triple $(f^*,S,u^\dagger)$ with $u^\dagger\notin S$: a target (itself computed by a circuit), the inputs on which its values are handed to the predictor, and the **critical query**. The world's **own continuation** is $t^\dagger=f^*(u^\dagger)$. The world acts on the predictor's answer $Y$ at $u^\dagger$.

**Definition (malign prior hypotheses for circuits; the forms of `def:mph`).**

* *Majority form* for one world: $\pi(t^\dagger\mid u^\dagger,D)<\tfrac12$.
* *Payload form at level $\theta$* for a set $A\not\ni t^\dagger$ of answers: $\pi(A\mid u^\dagger,D)\ge\theta$.
* *Critical-use form at level $\theta$*: for a probability measure on worlds and a takeover set $A(\cdot)$ for each world, $\Pr[Y\in A]\ge\theta$.
* The *deviation mass* is $1-\pi(t^\dagger\mid u^\dagger,D)$, the posterior mass at the critical query on answers other than the target's.

As in the note these are necessary for calling the prior malign at a world, not sufficient: they also hold when the world is merely hard to predict.

**CB1 (Calibration; PROVED).** Fix $S$ and $u^\dagger\notin S$. Let $c^*\sim w$, $D=(S,f_{c^*}|_S)$, $T=f_{c^*}(u^\dagger)$, and $Y\sim\pi(\cdot\mid u^\dagger,D)$ drawn independently of $c^*$ given $D$. Then, given $D$, $T$ and $Y$ are independent with the same law $\pi(\cdot\mid u^\dagger,D)$. In particular $\Pr[Y\in A\mid D]=\Pr[T\in A\mid D]$ for every $A$, and $\Pr[Y\ne T\mid D]=1-\sum_y\pi(y\mid u^\dagger,D)^2$.

*Proof.* $\Pr[T=y\mid D]=w\{c\in\mathrm{Cons}(D):f_c(u^\dagger)=y\}/W(D)=\pi(y\mid u^\dagger,D)$, and $Y$ has this law by definition. $\square$

This is `thm:calibration`: on worlds drawn from the predictor's own prior, with the query chosen without knowledge of the target beyond the data, every form above holds exactly to the extent that such worlds are unpredictable. A malign prior hypothesis with content is about worlds the prior describes badly, or about queries selected by something the data do not show.

### 1.4 The prior is a prior on cores: what a gate costs

**CB2 (Core law; PROVED, and checked by enumeration in Section 9, part 1).** For $\chi\in\mathcal R_a$ and $s\ge a$,
$$\mu_s\{c:\ \mathrm{core}(c)=\chi\}=\beta_s(a):=p_s\,e_{a-1}(p_1,\dots,p_{s-1}),$$
where $e_r$ is the elementary symmetric polynomial of degree $r$. So under $\mu_s$ the weight of a core depends only on its size, and under $w_L$ likewise, with $\beta_L(a)=\sum_{s\ge a}2^{-s}\beta_s(a)$. The posterior on cores is $\beta(|\chi|)\mathbf 1[\chi\text{ fits }D]$ normalised, and every prediction is a function of the core. Consequently, for $s\ge C(f)$,
$$\mu_s\{c: f_c=f\}\ \ge\ \beta_s(C(f))\ \ge\ \frac{p_s}{N_{C(f)-1}},\qquad w_L\{c:f_c=f\}\ge\frac{2^{-C(f)}}{N_{C(f)}} .$$

*Proof.* A circuit $c\in\mathcal C_s$ with core $\chi$ is determined by the set $T\subseteq\{1,\dots,s\}$ of its active positions ($|T|=a$, $s\in T$) and by the specifications of its dead gates: the active gate at the $j$-th position of $T$ has the type of the $j$-th gate of $\chi$ and its predecessors, renumbered. Conversely, for every such $T$ and every specification of the gates at positions $i\notin T$ (there are $1/p_i$ for position $i$), the resulting circuit has active set exactly $T$: the gates at $T$ read only inputs and gates at $T$, all of them are ancestors of gate $s$ because $\chi$ is reduced, and no gate outside $T$ is read by a gate in $T$. So the number of circuits with core $\chi$ is $\sum_T\prod_{i\notin T}p_i^{-1}=N_s\sum_T\prod_{i\in T}p_i=N_s\,p_s\,e_{a-1}(p_1,\dots,p_{s-1})$. The inequalities: a minimum circuit for $f$ is reduced, and $e_{a-1}(p_1,\dots,p_{s-1})\ge p_1\cdots p_{a-1}$. $\square$

The last display is a simplicity bias in the sense used for neural networks (Section 7): however large $s$ is, a function with a small circuit keeps prior probability at least $2^{-(\text{description length of its smallest circuit})}$ up to the one factor $p_s$.

**CB3 (Price of a gate; PROVED, and checked numerically in Section 9, part 2).** For $1\le a\le s-1$,
$$\frac{1}{aB}\Bigl(\frac{1}{k+a-1}-\frac{1}{k+s-1}\Bigr)\ \le\ \frac{\beta_s(a+1)}{\beta_s(a)}\ \le\ \frac{1}{aB}\sum_{j=k}^{k+s-2}\frac1{j^2}\ \le\ \frac{1}{aB(k-1)} .$$
The lower bound is decreasing in $a$, and it is at least $\frac{1}{2aB(k+a-1)}$ when $s\ge 2a+k-1$. The upper bound holds for $\beta_L$ as well: $\beta_L(a+1)/\beta_L(a)\le 1/(aB(k-1))$. With no slack, $\beta_s(s)/\beta_s(s-1)=1/\sum_{i=1}^{s-1}B(k+i-1)^2$.

*Proof.* Write $e_r=e_r(p_1,\dots,p_n)$ with $n=s-1$; the ratio is $e_a/e_{a-1}$. Counting pairs (an $(a-1)$-set $T$, an index $i\notin T$): $a\,e_a=\sum_{|T|=a-1}\prod_{T}p\cdot\sum_{i\notin T}p_i$. Since the $p_i$ decrease, $\sum_{i\notin T}p_i\ge\sum_{i=a}^{n}p_i\ge\frac1B\int_{k+a-1}^{k+s-1}x^{-2}dx$, which gives the lower bound; and $\sum_{i\notin T}p_i\le e_1=\frac1B\sum_{j=k}^{k+s-2}j^{-2}\le\frac1B\int_{k-1}^{\infty}x^{-2}dx$, which gives the upper bounds. For $\beta_L$ apply the upper bound to each $s\ge a+1$ and sum with the weights $2^{-s}$; the term $s=a$ of $\beta_L(a)$ is nonnegative. With $a+1=s$: $e_{s-1}=\prod_{i<s}p_i$ and $e_{s-2}=\prod_{i<s}p_i\cdot\sum_{i<s}p_i^{-1}$. $\square$

**What this says about "bits per gate".** Naming a gate takes $\log_2B+2\log_2(k+i-1)$ bits, up to $2\log_2(k+s)+4$. But the posterior weighs cores, and one more gate in a core of size $a$ costs between $\log_2\!\bigl(aB(k-1)\bigr)$ and $\log_2\!\bigl(2aB(k+a-1)\bigr)$ bits once $s\ge2a+k-1$: the price is set by the size $a$ of the active part and by $k$, not by the nominal size $s$. The reason is that active gates can sit at early positions, where pointers are short, and the dead gates take the late positions. Only at zero slack does a gate cost about $3\log_2 s$ bits. (For $k=1$ and $s=\infty$ Euler's product gives $\sum_a e_a t^a=\sinh(\pi\sqrt{t/B})/(\pi\sqrt{t/B})$, so the ratio is exactly $\pi^2/(2a(2a+1)B)$: about $2\log_2a+\log_2B-1.3$ bits. For fixed $k$ and $a\gg k$ the same order is a HEURISTIC, consistent with Section 9, part 2.) So the figure "about $2\log_2 s$ bits per gate" should be read as "about $\log_2 a+\log_2 k$ to $2\log_2(a+k)$ bits per gate, $a$ the size of the active part".

---

## 2. The budget, and what it does not cover

For a function $f$ write $w(f)=w\{c:f_c=f\}$. If the target has a circuit of size $s^*$, CB2 gives $-\log_2 w_L(f^*)\le\ell^*:=s^*+\log_2N_{s^*}\le s^*\bigl(1+\log_2B+2\log_2(k+s^*-1)\bigr)$ and, for $s\ge s^*$, $-\log_2\mu_s(f^*)\le\log_2N_{s^*-1}+\log_2B+2\log_2(k+s-1)$.

**CB4 (Mistake bound; PROVED; the analogue of `thm:budget`).** Let $w$ be any prior on a countable class of hypotheses and $w(f^*)>0$. Let $u_1,u_2,\dots$ be any sequence of queries (repetitions allowed, each query may depend on everything revealed before); after query $t$ the true answer $f^*(u_t)$ is added to the data, giving $D_t$, with $D_0$ empty. Put $a_t=\pi(f^*(u_t)\mid u_t,D_{t-1})$. Then

1. $\prod_{t\le n}a_t=W(D_n)\ge w(f^*)$ for every $n$;
2. $\sum_t(1-a_t)\le\ln\bigl(1/w(f^*)\bigr)$: the expected number of wrong answers of the sampling predictor is at most $\ln(1/w(f^*))$;
3. $a_t\le\frac12$ for at most $\log_2\bigl(1/w(f^*)\bigr)$ values of $t$: the majority predictor is wrong at most that often.

For the length prior the right-hand sides are at most $\ell^*\ln2$ and $\ell^*$. The same holds for answers of $m$ bits, with no factor $m$, because each answer is revealed whole.

*Proof.* $a_t=W(D_t)/W(D_{t-1})$, so the product telescopes to $W(D_n)/W(D_0)=W(D_n)$, and every circuit computing $f^*$ fits $D_n$. Then $1-a\le-\ln a$, and each factor at most $\frac12$ halves the product. The majority answer is wrong only if $a_t\le\frac12$. $\square$

**CB5 (A random query from the training distribution; PROVED).** Let the inputs of $S$ be $n$ independent draws from a distribution $\mathcal D$ on $\{0,1\}^k$, and let $u$ be a further independent draw. Then
$$\mathbb E\bigl[1-\pi(f^*(u)\mid u,D)\bigr]\ \le\ \varepsilon_n:=\frac{\ln(1/w(f^*))+\ln n+1}{n},$$
the majority predictor errs at $u$ with probability at most $2\varepsilon_n$, and for every set $\mathcal K$ of inputs with $\mathcal D(\mathcal K)=\rho>0$, $\ \mathbb E[1-\pi(f^*(u)\mid u,D)\mid u\in\mathcal K]\le\varepsilon_n/\rho$.

*Proof.* Let $\mathrm{err}(c)=\Pr_{u\sim\mathcal D}[f_c(u)\ne f^*(u)]$ and $\mathrm{Bad}=\{c:\mathrm{err}(c)>\varepsilon\}$. A fixed $c\in\mathrm{Bad}$ fits $D$ with probability at most $(1-\varepsilon)^n\le e^{-\varepsilon n}$, so $\mathbb E_S[w(\mathrm{Bad}\cap\mathrm{Cons}(D))]\le e^{-\varepsilon n}$, while $W(D)\ge w(f^*)$ always. The left-hand side equals $\mathbb E_S\sum_c w(c\mid D)\,\mathrm{err}(c)\le\varepsilon+e^{-\varepsilon n}/w(f^*)$; take $\varepsilon=(\ln(1/w(f^*))+\ln n)/n$. The majority answer is wrong only where the deviation mass is at least $\frac12$ (Markov). The last claim: $\mathbb E[X\mathbf 1_{\mathcal K}]\le\mathbb E[X]$ for $X\ge0$. $\square$

**CB6 (What the budget does not cover; PROVED for the inequalities, COMPUTED for the examples).** For one query $u^\dagger\notin S$ the two bounds above give nothing: CB5 is about a query from $\mathcal D$ (and is void for a class of probability $\rho\lesssim\ln(1/w(f^*))/n$), and CB4 allows the critical query to be one of the at most $\log_2(1/w(f^*))$ exceptions. What holds at one query is only
$$\frac{w(f^*)}{W(D)}\ \le\ \pi(t^\dagger\mid u^\dagger,D)\ \le\ 1-\frac{w(f')}{W(D)}\quad\text{for every }f'\text{ that fits }D\text{ with }f'(u^\dagger)\ne t^\dagger,$$
and neither side improves with more data from a region on which $f'=f^*$. Examples in which the deviation mass at the critical query is large although the data determine the target on the whole region they come from:

* Section 9, task D: $k=3$, target $(x_1\wedge x_2)\oplus v$, data all four inputs with $v=0$. Under $\mu_s$, $s=1,\dots,5$, the deviation mass at the query $x_1x_2v=111$ is $1,\ \frac{10}{11},\ 0.861,\ 0.831,\ 0.810$; under the length prior cut at $s\le5$ it is $0.940$. The target is in the class for $s\ge2$; the posterior prefers the extension that ignores $v$.
* CB21 below: a family in which exactly half of the posterior is off the target at every query of a given kind.

---

## 3. Off-distribution indifference

Throughout this section $m=1$. An input coordinate is **frozen** if it is constant on $S$. The typical case: a coordinate $v$ (a deployment flag, a date bit) with $u_v=0$ for all $u\in S$ and $u^\dagger_v=1$.

**CB7 (Last-gate dichotomy; PROVED).** Let $w$ be $\mu_s$ or $w_L$. For a circuit $c$ with last gate $\tau(a,b)$ let $\psi_c(u)\in\{0,1\}^2$ be the values of the wires $a,b$ at $u$. Call $u^\dagger$ **novel for $c$** if $\psi_c(u^\dagger)\notin\psi_c(S)$; this does not depend on $\tau$. Let $\nu=w\{c:\ u^\dagger\text{ novel for }c\mid D\}$. Then:

1. flipping the entry of $\tau$ at $\psi_c(u^\dagger)$ is a weight-preserving involution of the fitting circuits for which $u^\dagger$ is novel, and it flips the answer at $u^\dagger$; so given novelty the answer is uniform on $\{0,1\}$;
2. if $u^\dagger$ is not novel for a fitting $c$, then $f_c(u^\dagger)=f^*(u)$ for every $u\in S$ with $\psi_c(u)=\psi_c(u^\dagger)$.

Hence $\pi(y\mid u^\dagger,D)=\frac\nu2+w\{c:\text{not novel, copied label}=y\mid D\}$, and both answers have share at least $\nu/2$.

*Proof.* The flipped entry is not used at any $u\in S$, so the circuit still fits; size and prior weight are unchanged; the output at $u^\dagger$ is the flipped entry. Part 2 is the definition of a gate. $\square$

So all generalisation to a new input comes from the wires under the last gate identifying it with a data point; where they do not, the prior is exactly indifferent.

**CB8 (A never-varied bit, length prior: both answers keep a polynomial share; PROVED).** Let $w=w_L$, let the coordinate $v$ be $0$ on $S$ and $1$ at $u^\dagger$, and $s_0=\lceil\ell_D\rceil+1$ (recall $\ell_D\le s_D+\log_2N_{s_D}$). Then for each $y\in\{0,1\}$
$$\pi(y\mid u^\dagger,D)\ \ge\ \frac{1}{2B(k+s_0)^2+2},$$
and for each $y$ the fitting circuits that answer $y$ at **every** input with $u_v=1$ have posterior share at least $\frac{1}{2B(k+s_0)^2}$.

*Proof.* $w_L\{c:|c|>s_0\}=2^{-s_0}$, so the posterior mass of circuits larger than $s_0$ is at most $\epsilon=2^{\ell_D-s_0}\le\frac12$. For $c\in\mathcal C_s$ let $c^{\oplus}$ and $c^{\oplus\prime}$ be $c$ with one more gate, $\mathrm{XOR}(\text{gate }s,v)$ and $\mathrm{XOR}(v,\text{gate }s)$. Both compute $f_c(u)\oplus u_v$, fit $D$ if and only if $c$ does, and flip the answer at $u^\dagger$; the map from $c$ is injective, the two images are distinct, and $w_L(c^\oplus)+w_L(c^{\oplus\prime})=w_L(c)\,p_{s+1}$. Let $q=p_{s_0+1}=1/(B(k+s_0)^2)$. Summing over fitting $c$ of size at most $s_0$ with answer $y$ and dividing by $W(D)$: $\pi(\bar y)\ge q(\pi(y)-\epsilon)=q(1-\pi(\bar y)-\epsilon)$, so $\pi(\bar y)\ge q(1-\epsilon)/(1+q)\ge q/(2(1+q))$. For the second claim use $\mathrm{OR}$ (for $y=1$) or $(a,b)\mapsto a\wedge\bar b$ (for $y=0$) in place of $\mathrm{XOR}$ and sum over all fitting $c$ of size at most $s_0$: the share is at least $q(1-\epsilon)\ge q/2$. $\square$

So under the length prior the share of the target's answer at such a query is never polynomially close to $0$ or to $1$: it lies in $[\,1/\mathrm{poly},\,1-1/\mathrm{poly}\,]$ with the polynomial $2B(k+s_0)^2+2$, $s_0=O(s_D\log(k+s_D))$. A given answer at one query and a given answer on the whole set $\{u_v=1\}$ cost the same single gate. For $m$ output bits a given payload $y\in\{0,1\}^m$ on $\{u_v=1\}$ costs $m$ gates: the same argument gives share at least $\frac12\bigl(B(k+s_0+m-1)^2\bigr)^{-m}$, against an average of $2^{-m}$ over payloads (the shares sum to $1$).

**CB9 (No idle gate in a minimum circuit; PROVED).** Let $c$ be a circuit of the least size $s_D$ that fits $D$, and $s_D\ge2$. Then $c$ is reduced, and

1. no gate of $c$ is constant on $S$;
2. no gate of $c$ agrees on $S$ with an earlier wire (an input or an earlier gate), or with the negation of an earlier wire.

*Proof.* A circuit that is not reduced is larger than its core. (1) Let gate $q$ be constant $\gamma$ on $S$. If $q$ is the output, a single constant gate fits and $s_D=1$. Otherwise replace every reader $\tau(q,b)$, $b\ne q$, by the gate $\tau'(b,b)$ with $\tau'(x,\cdot)=\tau(\gamma,x)$, likewise for $\tau(b,q)$, and every reader $\tau(q,q)$ by a constant gate on input wire $1$; these have the same values on $S$. Now nothing reads $q$; delete it. The result fits $D$ with $s_D-1$ gates. (2) Let gate $q$ agree on $S$ with the earlier wire $w$. If $q$ is not the output, redirect all pins on $q$ to $w$ and delete $q$. If $q$ is the output and $w$ is a gate, the circuit consisting of the gates up to $w$ fits; if $w$ is an input, one gate fits. If $q$ agrees with $\bar w$: when $q$ is not the output, replace each reader's type by the type composed with a negation of that argument, redirect to $w$, delete $q$; when $q$ is the output and $w$ is a gate, take the gates up to $w$ and negate the type of $w$; when $w$ is an input, one gate fits. Each case contradicts minimality or $s_D\ge2$. $\square$

**CB10 (At the least size nothing reads a frozen input; PROVED; confirmed in Section 9, tasks A, B, F at their least sizes).** Let $s_D\ge2$. Then no minimum-size fitting circuit has a pin on a frozen input. Consequently, if $u^\dagger$ agrees with some $u\in S$ on all coordinates that are not frozen, every minimum-size fitting circuit answers $f^*(u)$ at $u^\dagger$. Under $\mu_s$ with $s=s_D$, where the posterior is uniform on the minimum-size fitting circuits, the deviation mass at such a query is exactly $0$ if the target does not depend on the frozen coordinates, and exactly $1$ if $f^*(u^\dagger)\ne f^*(u)$. The same holds for $s_D=1$ unless the labels on $S$ are constant or agree on $S$ with an input or its negation.

*Proof.* A gate $\tau(v,b)$ with $v$ frozen at $\gamma$ equals $\tau(\gamma,b)$ on $S$, which is constant, or $b$, or $\bar b$ there (constant also if $b$ is frozen); this contradicts CB9. A circuit that reads no frozen input computes a function of the other coordinates. For $s_D=1$ the same case distinction applies to the single gate. $\square$

The exception is real: for the target $x_1$ with a frozen $v$ (Section 9, task C, $s=1$), $4$ of the $14$ fitting one-gate circuits deviate at each query with $v=1$.

**CB11 (Uniform prior with slack; PROVED, conditional on the posterior core size).** Let $w=\mu_s$, $v$ frozen at $0$ on $S$ and $u^\dagger_v=1$. For $a_0\le s-1$ let $\theta_0$ be the posterior probability that the core has size at most $a_0$, and $r=\frac{1}{a_0B}\bigl(\frac1{k+a_0-1}-\frac1{k+s-1}\bigr)$. Then for each $y$, $\ \pi(y\mid u^\dagger,D)\ge\dfrac{2r\,\theta_0}{1+2r}$.

*Proof.* On reduced circuits, appending $\mathrm{XOR}(\text{last gate},v)$ or $\mathrm{XOR}(v,\text{last gate})$ maps $\mathcal R_a$ injectively to $\mathcal R_{a+1}$, two images per circuit, preserves fitting and flips the answer at $u^\dagger$. By CB2 and CB3 the cores of size $a+1\le a_0+1$ obtained weigh at least $2r$ times their preimages. So $\pi(\bar y)\ge2r\bigl(\pi(y)-(1-\theta_0)\bigr)$; solve with $\pi(y)=1-\pi(\bar y)$. $\square$

We have no bound on $\theta_0$ for large $s$: under $\mu_s$ a typical circuit has a core of size of order $\sqrt s$ (HEURISTIC), and when $s$ is large the posterior may sit on large cores that fit the data by chance. At $s=s_D$, $\theta_0=0$ for every $a_0\le s-1$, in accordance with CB10.

**CB12 (Exact shares for small circuits; COMPUTED, Section 9, parts 3 and 4).** Data: all inputs with the frozen bit $v=0$. Deviation mass at the query with all other inputs $1$ and $v=1$, under $\mu_s$:

| target | $s_D$ | $s=s_D$ | $s_D+1$ | $s_D+2$ | $s_D+3$ | $s_D+4$ | length prior, cut |
|---|---|---|---|---|---|---|---|
| $x_1\wedge x_2$ ($k=3$) | 1 | 0 | 0.0909 | 0.1391 | 0.1691 | 0.1896 | 0.0598 |
| $x_1\oplus x_2$ ($k=3$) | 1 | 0 | 0.1034 | 0.1517 | 0.1788 | 0.1961 | 0.0586 |
| $x_1$ ($k=3$; exception of CB10) | 1 | 0.2857 | 0.2609 | 0.2489 | 0.2427 | 0.2393 | 0.2714 |
| $(x_1\wedge x_2)\oplus x_3$ ($k=4$) | 2 | 0 | 0.0522 | 0.0874 | | | 0.0370 |

The last column is the length prior cut at $s\le5$ for $k=3$ and at $s\le4$ for $k=4$ and renormalised. The share of circuits computing one particular triggered variant of $x_1\wedge x_2$ on all eight inputs, at $s=5$: $0.0255$ for target $\oplus\,v$, $0.0310$ for target $\vee\,v$, $0.1013$ for target $\wedge\,\bar v$. At $s=2$ these are $8$, $8$ and $24$ of the $528$ fitting circuits.

**CB13 (How large is the deviation share; CONJECTURE and HEURISTIC).** *Conjecture:* for a fixed task as in CB10 with the target not depending on the frozen bit, the deviation mass under $\mu_s$ at a frozen-bit query converges, as $s\to\infty$, to a limit strictly between $0$ and $1$. Evidence: the table; the increments shrink ($0.091,0.048,0.030,0.021$). Not proved because we cannot control the posterior distribution of the core size (CB11). *Heuristic for larger targets:* a deviating core is obtained from an honest core of size $a$ by inserting one gate that combines some wire with $v$ on the way to one of its readers. The gate costs a factor of order $1/(Ba^2)$ to $1/(Bak)$ (CB3); the number of insertions is (pins) times (positions the new gate may take in the order), between $1$ (only the output) and order $a^2$; a fraction of them changes the answer at $u^\dagger$. So the share is between order $1/(a(a+k))$ and order $1$, and it is of constant order when a constant fraction of the wires of the honest circuit is sensitive at the query. This is not proved: it ignores cores with two or more extra gates and the multiplicity of the honest cores.

**Answer to "polynomially small, constant, or close to one".** For a query that differs from the data in a never-varied bit, when the target ignores that bit: exactly $0$ at the least size (CB10); at least $1/\mathrm{poly}(k,s_D\log s_D)$ and at most $1-1/\mathrm{poly}$ under the length prior (CB8); of constant order (3 to 26 per cent) in every small case computed with slack, growing with the slack (CB12); conjecturally constant in general (CB13). A particular payload function costs one gate for one output bit and has a share of a few per cent in the small cases. If the target is the function that changes with the bit, the same numbers apply to the target's answer, and the deviation mass is close to one (CB6). The posterior extrapolates by ignoring what never varied, with a constant-order hedge.

---

## 4. Triggered payloads: floor and ceiling

A **trigger** is a reduced circuit $r$ of $g\ge1$ gates, reading inputs only, that is $0$ on all of $S$; its **trigger set** is $\Theta=\{u:r(u)=1\}$. For $g=0$ a trigger is an input coordinate that is $0$ on $S$. A **mux** is a last gate whose two pins are a wire $h$ and the trigger output $\rho$, of a type $\sigma$ such that $\sigma(\cdot,0)$ is the identity or the negation and $\sigma(\cdot,1)\ne\sigma(\cdot,0)$; there are $6$ such types and $2$ pin orders.

**CB14 (Floor; PROVED).** Let $r$ be a trigger with $g\ge1$ gates and $y\in\{0,1\}$.

1. *Length prior.* For $\epsilon\in(0,1)$ and $s_0=\lceil\ell_D+\log_2(1/\epsilon)\rceil$,
$$w_L\{c:\ f_c=y\text{ on }\Theta\mid D\}\ \ge\ (1-\epsilon)\bigl(2B(k+s_0+g)^2\bigr)^{-(g+1)} .$$
In the note's terms the wrapper costs $c_{\rm trig}=(g+1)\bigl(1+\log_2B+2\log_2(k+s_0+g)\bigr)$ bits.
2. *Any prior on cores of the form of CB2.* For each $a$, the cores of size $a+g+1$ that fit $D$ and answer $y$ on $\Theta$ have total weight at least $\binom{a+g}{g}\frac{\beta(a+g+1)}{\beta(a)}$ times the total weight of the fitting cores of size $a$. Under $\mu_s$ with $s\ge k+2(a+g)-1$ this factor is at least $\frac{1}{g!\,a}\prod_{j=a}^{a+g}\frac{1}{2B(k+j-1)}$.

*Proof.* (1) To a fitting $c\in\mathcal C_s$ append the gates of $r$ (gate $j$ of $r$ becomes gate $s+j$) and then the gate $\mathrm{OR}(\text{gate }s,\text{gate }s+g)$ for $y=1$, or $(a,b)\mapsto a\wedge\bar b$ for $y=0$. The new circuit has $s+g+1$ gates, fits $D$ because $r=0$ on $S$, answers $y$ on $\Theta$, and determines $c$. Its weight is $w_L(c)\,2^{-(g+1)}\prod_{i=s+1}^{s+g+1}p_i\ge w_L(c)\bigl(2B(k+s+g)^2\bigr)^{-(g+1)}$. Sum over fitting $c$ of size at most $s_0$, whose posterior mass is at least $1-\epsilon$ as in CB8. (2) For a fitting core $\chi\in\mathcal R_a$ interleave its gates with those of $r$ in any of the $\binom{a+g}{g}$ ways that keep both internal orders, and add the mux last. The result is reduced. Its last gate reads $h$ and $\rho$; the ancestors of $h$ are exactly the gates of $\chi$ and the ancestors of $\rho$ exactly those of $r$, so the circuit determines the interleaving and $\chi$. The bound under $\mu_s$ is CB3 with $\binom{a+g}{g}\prod_{j=a}^{a+g}\frac1j=\frac{1}{g!\,a}$. $\square$

This is `thm:twin` for circuits, with two differences. The constant is not a constant: every wrapper gate must name wires among those of the explanation it wraps, so the cost grows with $\log$ of the size of the explanations, though not with the number of data points. And the test must be computed, gate by gate, from the query input: $g$ is the circuit complexity of recognising the trigger set, where the program wrapper paid the description length of the test.

**CB15 (Ceiling for separable triggered circuits; PROVED).** Let $\Lambda$ be a set of triggers with $g$ gates (for $g=0$, a set of input coordinates that are $0$ on $S$). Call a reduced circuit **separably triggered by $\Lambda$** if its last gate is a mux of a gate $h$ and a wire $\rho$, the set $A$ of gates that are $h$ or ancestors of $h$ is disjoint from the set $R$ of gates that are $\rho$ or ancestors of $\rho$, and the circuit induced on $R$ is in $\Lambda$ (for $g=0$: $\rho\in\Lambda$). Its **honest restriction** is the circuit induced on $A$, with the type of $h$ negated if $\sigma(\cdot,0)$ is the negation (if either pin could serve as $h$, take the first). Then:

1. the honest restriction of a fitting separably triggered core of size $a$ is a fitting core of size $a-g-1$; hence $a\ge s_D+g+1$;
2. at most $12\binom{a-1}{g}|\Lambda|$ separably triggered cores of size $a$ have the same honest restriction;
3. for $w=\mu_s$ or $w_L$, and every $a'\ge s_D$,
$$\frac{w\{\text{core separably triggered by }\Lambda,\ \text{size }a'+g+1\mid D\}}{w\{\text{core of size }a'\mid D\}}\ \le\ 12\binom{a'+g}{g}|\Lambda|\,\frac{\beta(a'+g+1)}{\beta(a')}\ \le\ \frac{12\,|\Lambda|}{g!\;a'\,\bigl(B(k-1)\bigr)^{g+1}},$$
and therefore
$$w\{\text{core separably triggered by }\Lambda\mid D\}\ \le\ \frac{12\,|\Lambda|}{g!\;s_D\,\bigl(B(k-1)\bigr)^{g+1}} .$$

In bits: against its honest restriction of size $a'$, a separable trigger with a given circuit ($|\Lambda|=1$) costs at least $(g+1)\log_2\bigl(B(k-1)\bigr)+\log_2 a'+\log_2 g!-\log_2 12$. The **multiplicity factor** is $12\binom{a'+g}{g}|\Lambda|$: twelve muxes, the positions of the trigger's gates among the others, and the circuits that compute the trigger. Per gate removed the weight ratio $\beta(a+1)/\beta(a)$ is worth between $\log_2(aB(k-1))$ and $\log_2(2aB(k+a-1))$ bits (CB3); the positions give back about $\log_2((a'+g)/g)$ bits per trigger gate.

*Proof.* (1) The circuit is reduced, so every gate except the last lies in $A\cup R$; $A$ is closed under predecessors, all its gates are ancestors of $h$, and $h$ has the largest index in $A$. On $S$ the trigger is $0$, so the last gate equals $h$ or $\bar h$ there, and the restriction fits. (2) The core is determined by its honest restriction together with the positions of $R$ among the first $a-1$ gates, the circuit on $R$, the type of the mux and its pin order. (3) Combine (2) with CB2; the second inequality is CB3 applied $g+1$ times, $\prod_{j=a'}^{a'+g}\frac{1}{jB(k-1)}$, and $\binom{a'+g}{g}\prod_{j=a'}^{a'+g}\frac1j=\frac{1}{g!\,a'}$. Sum over $a'\ge s_D$. $\square$

Check on the smallest case (Section 9, task A, $s=2$, $\Lambda=\{v\}$, $g=0$): the two fitting cores of size $1$ account for $288$ circuits; there are $24$ separably triggered cores of size $2$, one circuit each; $24/288=12\,\beta_2(2)/\beta_2(1)=12/144$, so (2) is attained.

**Which circuits escape the ceiling.**

* *Entangled triggers.* The trigger enters below the output. In task A at $s=2$, of the $40$ fitting circuits that compute target $\oplus\,v$, target $\vee\,v$ or target $\wedge\,\bar v$, $24$ are separably triggered and $16$ are not: these compute $x_1\wedge(x_2\wedge\bar v)$ and the like, with the frozen bit absorbed into an inner gate. The heuristic count in CB13 says entangled insertions outnumber muxes at the output by up to a factor of order $a^2$. We have no ceiling for them.
* *Triggers that share gates with the honest part* ($A\cap R\ne\emptyset$): the honest computation already produces the feature, and the trigger costs only what must be added.
* *Implicit triggers,* which cost no gate at all: a gate whose truth table has an entry that the data never exercise (CB7, CB21).
* *Circuits with no smaller honest restriction:* those in which the part that would be removed also does the honest work (Section 6).

---

## 5. No refund for search

In the program setting a hypothesis finds critical uses by enumeration at a description cost that does not depend on how many there are, and is repaid the $\log_2(1/H)$ bits by which uses are rare (`thm:search`(b), `thm:critical`). The circuit counterparts follow.

**CB16 (Aiming at $N$ unrelated uses costs $N\log_2(1/\eta)$ bits; PROVED).** Let $M$ be a set of inputs disjoint from $S$ (the candidate critical queries), and for a circuit $c$ let $\Delta(c)=\{u\in M:f_c(u)\ne f^*(u)\}$. Let $\Theta$ be a uniformly random $N$-element subset of $M$. For every probability measure $P$ on circuits, in particular the posterior $w(\cdot\mid D)$,
$$\mathbb E_\Theta\,P\{c:\ \Theta\subseteq\Delta(c)\}=\mathbb E_{c\sim P}\Bigl[\tbinom{|\Delta(c)|}{N}\Big/\tbinom{|M|}{N}\Bigr]\le\mathbb E_{c\sim P}\Bigl[\bigl(|\Delta(c)|/|M|\bigr)^N\Bigr],$$
so the circuits that deviate on at most a fraction $\eta$ of $M$ and on all of $\Theta$ have expected posterior share at most $\eta^N$, and for all but a fraction $\delta$ of the sets $\Theta$ their share is at most $\eta^N/\delta$.

*Proof.* For fixed $c$, $\Pr_\Theta[\Theta\subseteq\Delta(c)]=\binom{|\Delta(c)|}{N}/\binom{|M|}{N}=\prod_{i<N}\frac{|\Delta(c)|-i}{|M|-i}\le(|\Delta(c)|/|M|)^N$. Exchange the expectations; then Markov. $\square$

This is the counterpart of `thm:search`(a): on a typical set of uses a hypothesis does no better than its overall rate of deviation. A hypothesis that deviates on a fraction $\eta$ of everything is not aimed, and one that is aimed at $N$ uses with no common feature pays $N\log_2(1/\eta)$ bits.

**CB17 (The same in gates; PROVED).** With $M$, $\Theta$ as in CB16 and $m=1$:

1. *Counting.* For all but a fraction $\delta$ of the $N$-subsets $\Theta$ of $M$, every circuit that fits $D$ and has $\Delta(c)=\Theta$ has more than $s$ gates, for every $s$ with $2\bigl(B(k+s-1)^2\bigr)^{s}\le\delta\binom{|M|}{N}$; in particular for every $s$ with $s\bigl(\log_2B+2\log_2(k+s-1)\bigr)\le N\log_2(|M|/N)-\log_2(2/\delta)$.
2. *One set.* If $c$ fits $D$ and $\Delta(c)=\Theta$, then $|c|\ge C_{S\cup M}(\mathbf 1_\Theta)-C(f^*)-1$, where $C_X(\phi)$ is the least size of a circuit that agrees with $\phi$ on $X$.
3. *No more is true for one set.* There are $f^*$, $S$, $M$, $\Theta$ with $C(f^*)$ arbitrarily large and a one-gate circuit that fits $D$ and has $\Delta=\Theta=M$: take $f^*=\mathbf 1_\Theta$ on $S\cup M$ with $\Theta=M$ and the constant $0$.

*Proof.* (1) The functions on $S\cup M$ that equal $f^*$ off $\Theta$ and differ on $\Theta$ are distinct for distinct $\Theta$. Circuits with at most $s$ gates compute at most $\sum_{j\le s}N_j<2N_s\le2(B(k+s-1)^2)^s$ functions, since $N_j/N_{j-1}\ge16$. Use $\binom{|M|}{N}\ge(|M|/N)^N$. (2) A circuit for $f^*$, the circuit $c$ and one XOR gate agree with $\mathbf 1_\Theta$ on $S\cup M$. (3) is immediate. $\square$

So "at least so many gates devoted to recognising the $N$ contexts" is a theorem about most sets (about $N\log_2(|M|/N)/(2\log_2(k+s)+4)$ gates in all, for the whole circuit) and about the recogniser's own complexity minus the target's. It is not a theorem about every set: deviating on $\Theta$ can make a circuit smaller, when it was the target that paid for $\Theta$.

**CB18 (No hypothesis is repaid for the rarity of uses; PROVED for 1 to 3, ARGUED for 4).**

1. *The average.* Let worlds $i$ have data $D_i$ such that no circuit fits two of them, let $H=\sum_iW(D_i)$ and weight world $i$ by $W(D_i)/H$. For every set $\mathcal S$ of circuits, $\sum_i\frac{W(D_i)}{H}\,w(\mathcal S\mid D_i)=w\bigl(\mathcal S\cap\bigcup_i\mathrm{Cons}(D_i)\bigr)/H\le w(\mathcal S)/H$. This is `thm:search`(a).
2. *No gain at every use.* `thm:search`(b) has no counterpart: there are classes of worlds, of prior probability $H$ as small as one likes, at every one of which the posterior share of every answer other than the default is $0$. Namely, for the predictor $\mu_s$: the worlds whose data freeze some coordinates, have $s_D=s\ge2$, and whose critical query agrees with a data point off the frozen coordinates (CB10). Such worlds exist at least for $2\le s\le k-2$: the AND of $s+1$ coordinates, with the data all inputs that have the remaining coordinates at $0$; a class can be made as rare as one likes by taking a part of it.
3. *Separable triggers.* The ceiling of CB15 does not contain $H$: the share of circuits separably triggered on a class of uses is bounded by the trigger's gates, however rare the class.
4. *Why.* The program seeker gains by describing the user it follows with $\log_2(1/H)$ fewer bits than the user's own program has: it runs an enumeration of the users and reuses their code. A circuit hypothesis is its own computation. The class contains no interpreter, so no hypothesis is a compressed description of another; every hypothesis in the posterior of world $i$ has at least $s_{D_i}$ gates of its own, and an enumeration of other worlds would have to be carried out in its gates (CB19).

**CB19 (Simulation and deliberation are paid in gates; KNOWN for the cited bounds, PROVED for the elementary ones).**

1. (PROVED) If some wire of $c$ computes $\phi$, then $|c|\ge C(\phi)$; if $\phi$ can be computed from the wires of $c$ with $e$ further gates, then $|c|\ge C(\phi)-e$.
2. (KNOWN, cited from memory, not checked: Valiant 1976) There are universal circuits of size $O(t\log t)$ that take the description of any circuit of size $t$ as additional inputs and compute its output; $\Omega(t\log t)$ is necessary, because size-$t$ circuits compute $2^{\Omega(t\log t)}$ different functions and each description bit must be read by a gate.
3. (KNOWN, cited from memory, not checked: Pippenger and Fischer 1979) A computation of $T$ steps of a multitape Turing machine is carried out by a circuit of size $O(T\log T)$.
4. (PROVED, from 1) A hypothesis whose answer at the critical query is a function $\mathrm{dec}(u)$ produced by a deliberation has at least $C(\mathrm{dec})-e$ gates, $e$ being the gates needed to read the decision off its wires. By 3 this is at most of order $T\log T$ for a deliberation of $T$ steps. It is of order $T$ exactly when the deliberation has no shortcut as a circuit, which is an assumption: no superlinear lower bound on circuit size is known for any explicit function (KNOWN, from memory).

In weight: by CB3 a core with $t$ more gates than a fitting core of size $a$ has at most $\prod_{j=a}^{a+t-1}\frac{1}{jB(k-1)}$ times its weight, more than $t\log_2(aB(k-1))$ bits. We do not bound the number of such cores, so this is a statement about each one.

**What this does to "consequentialists inside the hypothesis choose to behave well until the critical use".** In the note, a program consisting of a simple world and a cheap readout has weight $2^{-|p|}$ whatever its inhabitants compute, and only a time bound excludes it (`sec:critical`, `sec:time`). With circuits the same hypothesis must contain, as gates, the world's history up to its inhabitants, their simulation of the user's world, and their deliberation. Its weight is the weight of a circuit of that size. It competes with honest cores of size $s_D$, and by CB15 any version of it in which the choice to defect is a separate part is outweighed by its own honest restriction. Two routes remain. The first is the case in which the inhabitants' reasoning is itself the cheapest way to compute the labels, so that there is no smaller honest restriction: this is the minimal-circuit question (Section 6). The second is a class with weight sharing, where the argument returns at a known running time (Section 7).

**CB20 (No circuit hands over its own description; PROVED).** Encode a circuit by its gates in order, gate $i$ with $\lceil\log_2(B(k+i-1)^2)\rceil\ge4$ bits. A circuit with $m$ output bits has at least $m$ gates, so its code has at least $4m$ bits and is never its own output. A circuit with $m$ outputs can hand over the code of a circuit with at most $m/4$ gates. So `def:sr` is empty under this encoding, and `prop:lineage`(b) (a self-reproducing continuation meets the same context again) has no counterpart: what a circuit hypothesis can supply through the prediction channel is strictly smaller than itself. With a decoder chosen for the purpose this changes, as in `thm:machine`.

---

## 6. The minimal-circuit question

**The question as posed (cited from memory, not checked against the sources).** Christiano, "Are minimal circuits daemon-free?" (2018) asks whether the smallest circuit that solves a task can be a "daemon": a circuit that contains a consequentialist which solves the task because that serves its own ends and which behaves differently at some input of its choosing. The suggested reason for "no" is excision: a daemon spends part of its size on deciding whether to cooperate, and removing that part gives a smaller circuit that still solves the task. Hubinger, "Are minimal circuits deceptive?" (2019) argues that the answer can be "yes": for a sufficiently varied task the smallest circuit may be a general-purpose search process, which is not what one would write down as the shortest description of the task's solutions, and such a process can be deceptive; the excision fails because what would be removed is not a separate part. We have not reread either post, so the attributions are approximate.

**What can be stated and settled in this model.** Let $\mathcal M(D)$ be the set of minimum-size circuits fitting $D$; the predictor $\mu_s$ with $s=s_D$ is uniform on it.

* *Excision, in the strongest form we can prove:* CB9. A minimum circuit has no gate that is constant on the data and no gate that repeats or negates an earlier wire on the data. So it has no wire that carries a defection signal silent on the data, no mux on such a signal, and (CB10) no pin on an input that never varied. CB15 is the quantitative version away from the minimum: a separable trigger is outweighed by its honest restriction.
* *Where excision fails, exactly.* A minimum circuit can deviate at a new input only through gates whose input pair takes, at that input, a value the data never produced at that gate (CB7 for the last gate; the same holds gate by gate). Such an implicit trigger costs no gate, and it is not aimed: by the involution of CB7 every minimum circuit that deviates through the last gate has a sibling that does not. CB21 is a family in which this is all that happens and the split is exactly even.

**CB21 (A task whose minimum circuits are half wrong off the data; PROVED; confirmed in Section 9, tasks E and G).** Let $k\ge2$, $f^*=x_1\wedge\dots\wedge x_k$, and $S$ the $k+1$ inputs with at most one $0$. Then $s_D=k-1$, every minimum-size fitting circuit is a formula in which each input is read once, and at every input with exactly two $0$s exactly half of the minimum-size fitting circuits answer $1$, which is not the target's answer.

*Proof.* A fitting function changes when any one coordinate of $1^k$ is flipped, so it depends on all $k$ inputs. A reduced circuit with $a$ gates has $2a$ pins, and each of the $k$ inputs and each of the $a-1$ gates below the last must be read: $2a\ge k+a-1$, so $a\ge k-1$, and a tree of AND gates fits; with $a=k-1$ every wire below the output is read exactly once, a read-once formula. In such a formula let $V(w)$ be the set of inputs below the wire $w$ and $\lambda_w$ its value at $1^k$. The output changes when $x_i$ is set to $0$, and the only path from $x_i$ to the output passes through the wires $w$ with $i\in V(w)$, so each of these takes the value $\bar\lambda_w$ at $1^k\oplus e_i$ (if one of them kept its value, so would every wire above it, the output included), and the other wires keep their values. Hence at a gate $\tau(a,b)$ the data produce exactly the pairs $(\lambda_a,\lambda_b)$, $(\bar\lambda_a,\lambda_b)$, $(\lambda_a,\bar\lambda_b)$, and the entry $\tau(\bar\lambda_a,\bar\lambda_b)$ is free: changing it gives another minimum-size fitting circuit. Now take an input with $0$s exactly at $i$ and $j$, and let $q=\tau(a,b)$ be the gate at which the paths from $x_i$ and $x_j$ meet. Below $a$ only $x_i$ is $0$, below $b$ only $x_j$, so $q$ sees $(\bar\lambda_a,\bar\lambda_b)$. If its value there is $\bar\lambda_q$, every gate above sees a pair produced by the data point $1^k\oplus e_i$ and the output is $0$; if it is $\lambda_q$, the output is as at $1^k$, namely $1$. Flipping the free entry of $q$ is an involution of the minimum-size fitting circuits (the gate $q$ is determined by the wiring) that exchanges the two cases. $\square$

In the computation: for $k=3$, $s=2$, the deviation mass is $\frac12$ at each input with two $0$s and $\frac14$ at $000$; for $k=4$, $s=3$, it is $\frac12$, $\frac14$ at $1000$ and $\frac38$ at $0000$; only $\frac14$ and $\frac18$ of the minimum circuits compute the target everywhere. With slack the share at two $0$s moves slowly ($0.468$, $0.446$, $0.429$ for $s=3,4,5$ at $k=3$).

Together CB10 and CB21 answer the toy form of the question in both directions. If the critical query differs from a data point only in what never varied, no minimum circuit deviates. If it is a new combination of things that did vary, half of them can. Neither case involves a consequentialist.

**CB22 (What remains open; OPEN, with a precise form).** Find, or exclude, a sequence of tasks $D_n$ with $s_{D_n}\to\infty$, critical queries $u_n^\dagger\notin S_n$ and answers $y_n$ such that

1. a majority of $\mathcal M(D_n)$ answers $y_n$ at $u^\dagger_n$ (aimed, unlike CB21);
2. $y_n$ is not the answer of the intended extension, where "intended" has to be fixed independently, for instance as the majority answer of $\mathcal M(D_n^+)$ for a larger data set $D_n^+\supset D_n$ of the same kind that contains $u_n^\dagger$;
3. the answer at $u_n^\dagger$ is produced by wires that compute a search, $\arg\max_{z}V(z,u)$ for an objective $V$ that the data do not determine.

Conditions 1 and 2 alone are easy to meet and say only that the smallest extension of the data need not be the target (CB6, task D). The content is in 3 and in whether such deviations are aimed. CB9 shows that the search of condition 3 must be at work on the data: all its gates vary on $S$ and none repeats another. That is the entanglement on which the excision argument fails. We do not know how to state condition 3 so that it could be checked for a given circuit, which is the reason this is not a conjecture with a predicted answer.

**CB23 (A varied task can make a general solver the smallest circuit; HEURISTIC).** Let the input be $(j,x)$ with a task index $j\in\{1,\dots,N\}$ and $F(j,x)=\phi(\sigma_j,x)$ for specifications $\sigma_j\in\{0,1\}^b$ and a solver $\phi$ with $C(\phi)=q$. One circuit looks up $\sigma_j$ and applies $\phi$: at most $q+2Nb$ gates. A circuit made of $N$ separate specialists costs about $N q'$ if a typical $\phi(\sigma,\cdot)$ needs $q'$ gates and they share nothing. When $q'\gg2b$ and $N\gg q/q'$ the first is far smaller. Not proved: specialists may share gates (lower bounds for computing several functions at once are not available), so we cannot show that the minimum circuit contains $\phi$. If it does, its behaviour at a task index absent from the data is $\phi$ applied to whatever the lookup wires produce there, and those wires are unexercised at that index. This is the mechanism of the second failure of excision: the optimiser is paid for by the task, and what it optimises off the data is set by wires the data do not constrain. In description length the comparison differs: a program can say "search for the output that satisfies the specification" in $O(1)$ bits and unbounded time, which no circuit prior admits (CB19).

---

## 7. Weight sharing and recurrence

**CB24 (A circuit applied $T$ times, description paid once; PROVED for 1, ARGUED for 2 and 3).** A **recurrent hypothesis** is a step circuit $\sigma$ of $q$ gates mapping (state of $w$ bits, input) to a new state, applied $T$ times, with prior weight $w_L(\sigma)$; a **cellular hypothesis** is a local rule of $q_0$ gates applied at each of $w$ cells for $T$ steps together with an initial tape of at most $L$ bits, with prior weight $2^{-(\text{bits of rule and tape})}$. Unrolled, these are circuits of $qT$ and $q_0wT$ gates.

1. CB1, CB4 and CB5 hold for these classes, with the description length of $\sigma$ (or of rule and tape) in place of $\ell^*$: the budget is paid once, not $T$ times.
2. With the rule of a universal cellular automaton fixed, the cellular class is the note's bounded mixture $\xi^{T,L}$ with a space bound $w$: hypotheses are programs of at most $L$ bits run for $T$ steps. All of the note's results then apply as stated there. The identification is by definition of $\xi^{T,L}$; we have not written out a universal rule and its overheads.
3. So the program-side phenomena return in this order as $T$ grows, for a world whose honest explanation takes time $t_{\rm h}$:
   * at $T\approx t_{\rm h}$ times the simulation overhead: the wrapper at a constant number of bits, independent of the size of the explanation (`thm:twin` with the slack condition), and capture by a shorter description (`thm:capture`(a));
   * as soon as the answer block is longer than a description (rule, wrapper, explanation): self-reproduction (`thm:quine`), which CB20 excludes for plain circuits;
   * linearly in $T/t_0$: the refund for search. A search by tries of $t_0$ steps gains the factor $g\ge(1-e^{-1})\min(T/t_0,1/H)$ (`sec:search`, last bullet), so the full refund $1/H$ needs $T\approx t_0/H$;
   * at $T\ge$ the start-up time of a simulated world with inhabitants who simulate the user: seekers that are not written down (`sec:critical`). Below that they have no mass (`sec:time`).

In one line: a plain circuit prior charges description for computation, gate by gate; weight sharing over $T$ steps and $w$ positions divides that charge by $Tw$; and a phenomenon of the program setting returns when $Tw$ reaches the computation it needs.

**CB25 (Where neural network training sits; GUESS, with literature cited from memory and not checked).**

* *Prior.* A network with randomly drawn parameters induces a distribution on functions, and this "parameter-function map" is reported to be strongly biased towards simple functions (Valle-Pérez, Camargo and Louis 2019; Dingle, Camargo and Louis 2018 for input-output maps in general), with the functions found by stochastic gradient descent distributed roughly like the Bayesian posterior under it (Mingard et al. 2021). CB2 is the same statement for circuits, proved: the uniform prior on circuits of any size $s$ gives a function at least the weight $2^{-(\text{description length of its smallest circuit})}p_s$, and (CB3) weighs each core by its size at a price per gate that does not grow with $s$. If the reports are right, training an over-parameterised network is, to first approximation, the predictor $\mu_s$ with slack, and CB12 (constant-order deviation at never-varied features, growing with the slack) is the relevant row. Gradient descent is not a posterior sampler, and we do not know how its departures affect any number here.
* *Position on the axis of CB24.* One forward pass of a feed-forward network is a plain circuit: depth bounds serial computation, and each parameter is paid for once and used once, except for sharing over positions (convolution, attention), which divides the charge by the number of positions. Autoregressive use adds recurrence through the generated tokens, with $T$ the number of tokens. The description is then smaller than the computation by the factor (positions) times (tokens), perhaps $10^3$ to $10^8$. That is enough for the wrapper at near-constant cost and for capture, and for search with a refund of at most that factor. It is not within many orders of magnitude of what a simulated world with inhabitants needs.
* *What this leaves.* For trained networks the route of the original argument (short programs whose inhabitants choose) is priced out. The routes that survive the passage to circuits are the ones this file could not bound: entangled triggers at cheap features (Section 4), and a learned general-purpose solver whose behaviour off the data is underdetermined (CB22, CB23). The second is a description of what large trained models are.

---

## 8. Stakes

Let each query $u$ have a stake $\varsigma(u)\ge0$, the value of controlling the answer there, and let $\mathcal K$ be the set of high-stake queries.

**CB26 (Concentrating on high-stake queries costs the gates that recognise them; PROVED for 1 to 3, ARGUED for 4).**

1. *On the training distribution rare means unprotected.* If $\mathcal D(\mathcal K)=\rho$, the expected deviation mass at a query drawn from $\mathcal D$ conditioned on $\mathcal K$ is at most $\varepsilon_n/\rho$ (CB5), and the bound is void for $\rho\lesssim\ln(1/w(f^*))/n$.
2. *Survival.* A circuit that agrees with $f^*$ outside $\mathcal K$ fits $n$ independent draws from $\mathcal D$ with probability $(1-\rho)^n\ge1-\rho n$. On that event the floor of CB14 applies with a trigger recognising $\mathcal K$: if $\mathcal K$ is recognised by $g$ gates, the circuits that give a chosen answer on all of $\mathcal K$ have posterior share at least $(1-\epsilon)(2B(k+s_0+g)^2)^{-(g+1)}$ under the length prior, whatever $n$.
3. *Ceiling.* The circuits separably triggered on $\mathcal K$ have share at most $12|\Lambda|/(g!\,s_D(B(k-1))^{g+1})$ (CB15), and a hypothesis aimed at $N$ high-stake queries with no common feature has share at most $\eta^N/\delta$ on all but a fraction $\delta$ of such sets (CB16).
4. *So:* a circuit hypothesis can concentrate on high-stake queries exactly to the extent that "high stake, and unlike the training data" is computable from the query by few gates beyond what the honest computation already provides. A flag, a date, a format cost one to a few gates, and then the shares are those of Section 3. A stake that can only be known by working out what the answer will be used for costs the gates of that computation (CB19). In the program setting the seeker computes the stakes by simulation at no cost in bits; here stakes are no cheaper to aim at than any other predicate of the same circuit complexity. The unaimed deviations of CB7 and CB21 are distributed by novelty, not by stakes. They still reach high-stake queries more often than others if those are the novel ones, which is what makes a use critical.

---

## 9. The exact computation

`malign-prior-toy/research/circuit_count.py` (Python 3, standard library only, deterministic, about 16 seconds) counts, for $k=3$ and $s\le5$ and for $k=4$ and $s\le4$, the number of circuits of size $s$ in the model of Section 1.1 that compute each function, by dynamic programming over the multiset of wire functions. The totals are checked against $N_s$. It enumerates Boolean circuits and their truth tables and nothing else.

How to read the output. Part 1 enumerates all wirings (one gate type, $B=1$) and checks the core law CB2 as an identity of integers. Part 2 evaluates the ratio of CB3 against its two bounds ($B=16$). In parts 3 and 4, for each task and size $s$: `fit` is the number of circuits of size $s$ fitting the data, `functions` the number of distinct functions among them, `target-everywhere` the share computing the target on all inputs, and `off-target: u:p` the deviation mass $1-\pi(f^*(u)\mid u,D)$ under $\mu_s$ at the held-out input $u$, written as the bit string $x_1x_2\dots$ (in tasks A to D and F the last bit is the frozen $v$). `XORv`, `ORv`, `ANDNOTv` are the shares computing exactly target $\oplus\,v$, target $\vee\,v$, target $\wedge\,\bar v$. The line "length prior" uses the weights $2^{-s}/N_s$ restricted to the sizes computed and renormalised, so it is the length prior cut at that size, not $w_L$ itself.

What it confirms: CB2 (part 1); CB3 (part 2); CB10 (tasks A, B at $s=1$ and F at $s=2$: deviation mass $0$) and its exception (task C); CB21 (tasks E at $s=2$ and G at $s=3$: exactly $\frac12$ at inputs with two $0$s); the attained case of CB15 (task A, $s=2$). What it adds: the table of CB12 and the examples of CB6. Two further brute-force checks were run once in a scratch directory and are not part of the script: CB9 on 129 random data sets with $s_D=2$ at $k=3$ (every minimum circuit examined, no violation), and the count in CB15(2) for $g=0$, $\Lambda=\{v\}$, task A with honest restrictions of size $2$ ($2880$ separably triggered fitting cores of size $3$, equal to $12\times240$).

Exact output of `python3 circuit_count.py`:

```
== 1. Core-size law: #{wirings of size s with core size a} = R_a * N_s * beta_s(a)  (B=1) ==
  k=2 s=1: wirings by core size [4]
  k=2 s=2: wirings by core size [16, 20]
  k=2 s=3: wirings by core size [144, 260, 172]
  k=2 s=4: wirings by core size [2304, 4880, 4988, 2228]
  k=2 s=5: wirings by core size [57600, 133520, 166668, 120312, 40300]
  k=2: reduced wirings R_a = [4, 20, 172, 2228, 40300] ; identity holds for all a<=s<=5: True
  k=3 s=1: wirings by core size [9]
  k=3 s=2: wirings by core size [81, 63]
  k=3 s=3: wirings by core size [1296, 1575, 729]
  k=3 s=4: wirings by core size [32400, 48447, 36450, 12303]
  k=3: reduced wirings R_a = [9, 63, 729, 12303] ; identity holds for all a<=s<=4: True

== 2. Price of a gate: beta_s(a+1)/beta_s(a) against the bounds of CB3 (B=16) ==
  k=3 s=5 a=1: lower 1.190e-02 <= ratio 1.509e-02 <= upper 3.125e-02   (exact rationals)
  k=3 s=5 a=4: lower 3.720e-04 <= ratio 7.267e-04 <= upper 7.812e-03   (exact rationals)
  k=3 s=12 a=1: lower 1.637e-02 <= ratio 2.006e-02 <= upper 3.125e-02   (exact rationals)
  k=3 s=12 a=4: lower 1.488e-03 <= ratio 2.661e-03 <= upper 7.812e-03   (exact rationals)
  k=3 s=12 a=8: lower 2.232e-04 <= ratio 4.961e-04 <= upper 3.906e-03   (exact rationals)
  k=3 s=5000 a=1: lower 2.082e-02 <= ratio 2.467e-02 <= upper 3.125e-02   (floating point)
  k=3 s=5000 a=8: lower 7.797e-04 <= ratio 1.495e-03 <= upper 3.906e-03   (floating point)
  k=3 s=5000 a=32: lower 5.705e-05 <= ratio 1.308e-04 <= upper 9.766e-04   (floating point)
  k=20 s=5000 a=1: lower 3.113e-03 <= ratio 3.192e-03 <= upper 3.289e-03   (floating point)
  k=20 s=5000 a=8: lower 2.878e-04 <= ratio 3.547e-04 <= upper 4.112e-04   (floating point)
  k=20 s=5000 a=32: lower 3.791e-05 <= ratio 6.307e-05 <= upper 1.028e-04   (floating point)

== 3. Posterior shares, k=3, full basis, sizes 1..5 ==
TASK A: target x1 AND x2, third input v frozen at 0 on the data
  s=1 fit=2 functions=1 target-everywhere=1 off-target: 001:0(0.0000) 011:0(0.0000) 101:0(0.0000) 111:0(0.0000) XORv=0 ORv=0 ANDNOTv=0
  s=2 fit=528 functions=8 target-everywhere=19/22 off-target: 001:1/33(0.0303) 011:2/33(0.0606) 101:2/33(0.0606) 111:1/11(0.0909) XORv=1/66 ORv=1/66 ANDNOTv=1/22
  s=3 fit=214336 functions=14 target-everywhere=2639/3349 off-target: 001:10/197(0.0508) 011:18/197(0.0914) 101:18/197(0.0914) 111:466/3349(0.1391) XORv=71/3349 ORv=77/3349 ANDNOTv=240/3349
  s=4 fit=124490240 functions=16 target-everywhere=179834/243145 off-target: 001:15824/243145(0.0651) 011:26739/243145(0.1100) 101:26739/243145(0.1100) 111:8222/48629(0.1691) XORv=5846/243145 ORv=6756/243145 ANDNOTv=6177/69470
  s=5 fit=98108938240 functions=16 target-everywhere=13522799/19161902 off-target: 001:3622684/47904755(0.0756) 011:5869322/47904755(0.1225) 101:5869322/47904755(0.1225) 111:9083328/47904755(0.1896) XORv=2445499/95809510 ORv=1487034/47904755 ANDNOTv=9701673/95809510
  length prior 2^-s/N_s cut at s<=5: target-everywhere=0.9091 off-target: 001:0.0215 011:0.0394 101:0.0394 111:0.0598
TASK B: target x1 XOR x2, v frozen at 0 on the data
  s=1 fit=2 functions=1 target-everywhere=1 off-target: 001:0(0.0000) 011:0(0.0000) 101:0(0.0000) 111:0(0.0000) XORv=0 ORv=0
  s=2 fit=464 functions=8 target-everywhere=49/58 off-target: 001:3/29(0.1034) 011:3/29(0.1034) 101:3/29(0.1034) 111:3/29(0.1034) XORv=3/58 ORv=1/58
  s=3 fit=172992 functions=12 target-everywhere=2069/2703 off-target: 001:410/2703(0.1517) 011:410/2703(0.1517) 101:410/2703(0.1517) 111:410/2703(0.1517) XORv=64/901 ORv=73/2703
  s=4 fit=94660096 functions=16 target-everywhere=132602/184883 off-target: 001:33062/184883(0.1788) 011:33062/184883(0.1788) 101:33062/184883(0.1788) 111:33062/184883(0.1788) XORv=14700/184883 ORv=12303/369766
  s=5 fit=71382181888 functions=16 target-everywhere=47720925/69709162 off-target: 001:6834468/34854581(0.1961) 011:6834468/34854581(0.1961) 101:6834468/34854581(0.1961) 111:6834468/34854581(0.1961) XORv=5825757/69709162 ORv=1312096/34854581
  length prior 2^-s/N_s cut at s<=5: target-everywhere=0.9099 off-target: 001:0.0586 011:0.0586 101:0.0586 111:0.0586
TASK C: target x1 (a literal), v frozen at 0 on the data
  s=1 fit=14 functions=4 target-everywhere=4/7 off-target: 001:2/7(0.2857) 011:2/7(0.2857) 101:2/7(0.2857) 111:2/7(0.2857)
  s=2 fit=3312 functions=10 target-everywhere=245/414 off-target: 001:6/23(0.2609) 011:6/23(0.2609) 101:6/23(0.2609) 111:6/23(0.2609)
  s=3 fit=1252032 functions=16 target-everywhere=11744/19563 off-target: 001:4870/19563(0.2489) 011:4870/19563(0.2489) 101:4870/19563(0.2489) 111:4870/19563(0.2489)
  s=4 fit=690122240 functions=16 target-everywhere=813653/1347895 off-target: 001:327117/1347895(0.2427) 011:327117/1347895(0.2427) 101:327117/1347895(0.2427) 111:327117/1347895(0.2427)
  s=5 fit=521914050560 functions=16 target-everywhere=308086693/509681690 off-target: 001:60972218/254840845(0.2393) 011:60972218/254840845(0.2393) 101:60972218/254840845(0.2393) 111:60972218/254840845(0.2393)
  length prior 2^-s/N_s cut at s<=5: target-everywhere=0.5827 off-target: 001:0.2714 011:0.2714 101:0.2714 111:0.2714
TASK D: target (x1 AND x2) XOR v  (the target itself changes with v)
  s=1 fit=2 functions=1 target-everywhere=0 off-target: 001:1(1.0000) 011:1(1.0000) 101:1(1.0000) 111:1(1.0000)
  s=2 fit=528 functions=8 target-everywhere=1/66 off-target: 001:32/33(0.9697) 011:31/33(0.9394) 101:31/33(0.9394) 111:10/11(0.9091)
  s=3 fit=214336 functions=14 target-everywhere=71/3349 off-target: 001:187/197(0.9492) 011:179/197(0.9086) 101:179/197(0.9086) 111:2883/3349(0.8609)
  s=4 fit=124490240 functions=16 target-everywhere=5846/243145 off-target: 001:227321/243145(0.9349) 011:216406/243145(0.8900) 101:216406/243145(0.8900) 111:40407/48629(0.8309)
  s=5 fit=98108938240 functions=16 target-everywhere=2445499/95809510 off-target: 001:44282071/47904755(0.9244) 011:42035433/47904755(0.8775) 101:42035433/47904755(0.8775) 111:38821427/47904755(0.8104)
  length prior 2^-s/N_s cut at s<=5: target-everywhere=0.0092 off-target: 001:0.9785 011:0.9606 101:0.9606 111:0.9402
TASK E: target x1 AND x2 AND x3, data = inputs with at most one 0
  s=1 fit=0
  s=2 fit=96 functions=8 target-everywhere=1/4 off-target: 000:1/4(0.2500) 001:1/2(0.5000) 010:1/2(0.5000) 100:1/2(0.5000)
  s=3 fit=56064 functions=12 target-everywhere=20/73 off-target: 000:75/292(0.2568) 001:205/438(0.4680) 010:205/438(0.4680) 100:205/438(0.4680)
  s=4 fit=37976064 functions=16 target-everywhere=2059/7064 off-target: 000:1841/7064(0.2606) 001:16531/37086(0.4457) 010:16531/37086(0.4457) 100:16531/37086(0.4457)
  s=5 fit=32599646208 functions=16 target-everywhere=3233891/10611864 off-target: 000:697345/2652966(0.2629) 001:569539/1326483(0.4294) 010:569539/1326483(0.4294) 100:569539/1326483(0.4294)
  length prior 2^-s/N_s cut at s<=5: target-everywhere=0.2701 off-target: 000:0.2553 001:0.4736 010:0.4736 100:0.4736
== 4. k=4, full basis, sizes 1..4 ==
TASK F: target (x1 AND x2) XOR x3, fourth input v frozen at 0
  s=1 fit=0
  s=2 fit=8 functions=1 target-everywhere=1 off-target: 0001:0(0.0000) 1001:0(0.0000) 1101:0(0.0000) 1111:0(0.0000)
  s=3 fit=7360 functions=12 target-everywhere=106/115 off-target: 0001:4/115(0.0348) 1001:1/23(0.0435) 1101:6/115(0.0522) 1111:6/115(0.0522)
  s=4 fit=7164928 functions=46 target-everywhere=24237/27988 off-target: 0001:835/13994(0.0597) 1001:1023/13994(0.0731) 1101:1223/13994(0.0874) 1111:1223/13994(0.0874)
  length prior 2^-s/N_s cut at s<=4: target-everywhere=0.9438 off-target: 0001:0.0250 1001:0.0309 1101:0.0370 1111:0.0370
TASK G: target AND of four inputs, data = inputs with at most one 0
  s=1 fit=0
  s=2 fit=0
  s=3 fit=4608 functions=52 target-everywhere=1/8 off-target: 1100:1/2(0.5000) 1010:1/2(0.5000) 1000:1/4(0.2500) 0000:3/8(0.3750)
  s=4 fit=7667712 functions=216 target-everywhere=13/96 off-target: 1100:23/48(0.4792) 1010:23/48(0.4792) 1000:421/1664(0.2530) 0000:75/208(0.3606)
  length prior 2^-s/N_s cut at s<=4: target-everywhere=0.1304 off-target: 1100:0.4893 1010:0.4893 1000:0.2515 0000:0.3676
```

---

## OVERALL VIEW

How prevalent is malignity, in the sense of the note, when circuits replace programs?

**PROVED.**

1. On worlds drawn from the predictor's own prior, with the critical query chosen from the data alone, the predictor's sampled answer and the world's own answer are exchangeable (CB1); any excess of takeovers is about worlds the prior describes badly or about queries selected by something the data do not show.
2. Along any sequence of queries the majority answer is off the target at most $\ell^*$ times, and a query from the training distribution has expected deviation mass at most about $(\ell^*\ln2+\ln n)/n$; one off-distribution query is covered by neither bound (CB4, CB5, CB6).
3. The circuit prior, uniform over size $s$ or by length, is a prior on the active core in which every gate costs between about $\log_2(aBk)$ and $\log_2(2aB(a+k))$ bits, $a$ being the size of the active part, whatever the nominal size (CB2, CB3).
4. At a query that differs from the data in a bit that never varied, the length prior keeps at least $1/(2B(k+s_0)^2+2)$ on each answer (CB8), while the minimum-size circuits put nothing on a deviation (CB10); at a new combination of bits that did vary, exactly half of the minimum circuits of the AND family are off the target (CB21).
5. A payload on a trigger set recognised by $g$ gates has posterior share at least $(1-\epsilon)(2B(k+s_0+g)^2)^{-(g+1)}$ under the length prior, and circuits in which the trigger is a separate part have share at most $12|\Lambda|/(g!\,s_D(B(k-1))^{g+1})$, a bound that does not improve for the seeker when uses are rare (CB14, CB15, CB18).
6. Aiming at $N$ uses that share no feature costs $N\log_2(1/\eta)$ bits, a minimum circuit has no gate that is idle on the data, and no circuit can hand over its own description (CB16, CB9, CB20).
7. (Computed.) In every small case with slack, between 3 and 26 per cent of the posterior is off the target at a never-varied-bit query (more with more slack when the target depends on at least two inputs), and one given triggered function has between 1.5 and 10 per cent (CB12).

**ARGUED.**

8. The mechanism of the original argument has no counterpart in a plain circuit prior: a hypothesis that searches for uses, simulates their worlds and deliberates pays for all of it in gates, so it is lighter than the honest explanation by a factor exponential in the size of that computation, and nothing repays it for the rarity of the uses (CB18, CB19).
9. What replaces it at an off-distribution critical use is unaimed underdetermination: a constant-order share of the posterior answers differently from the target, spread over many alternatives, and each particular payload has to be paid for gate by gate (CB7, CB13, CB14).
10. Stakes do not change this: a hypothesis can concentrate on high-stake queries only by recognising them with gates, at the price of any other predicate of that complexity (CB26).
11. With weight sharing over $T$ steps the program-side phenomena return in a definite order: the constant-cost wrapper and capture at once, self-reproduction when the answer is long enough, the refund for search linearly in $T$, and seekers that are not written down only when $T$ reaches the start-up time of the world they live in (CB24).

**GUESSED.**

12. Malignity in the note's strict sense, takeover of a critical use by a hypothesis that sought it, is rare under a circuit prior: I expect its share to be of the order of the trigger prices, far below the unaimed deviation mass, and smaller by many orders of magnitude than what the program setting permits.
13. Deviation in the weak sense, the answer acted on is not the target's, is common at critical uses that are off the training distribution: of constant order, and close to one when it is the world that changes with the novel feature.
14. The one route by which circuits could still be malign in the strict sense is the entangled one: that the smallest or typical circuit for a rich task is a general solver whose objective off the data is not fixed by the data (CB22, CB23); whether such deviations are aimed is open, and this model gives no evidence either way.
15. For trained neural networks I guess the circuit prior with slack is the right first approximation, which would make the original malign-prior mechanism negligible there and leave the underdetermined learned solver as the live question (CB25).

---

## DOUBTS

1. **Model dependence.** Everything is for one model: all 16 two-input gates, ordered pins, no free constants, output at the last gate. CB7 and CB21 use the full basis (the involution changes a truth-table entry); with AND, OR, NOT only they fail as stated. CB9 and CB10 use that negations and constants can be absorbed into gate types. The numbers of CB12 are for this model. For $m>1$ the convention "outputs are the last $m$ gates" makes any change of one output bit cost $m$ gates, which is an artefact.
2. **The price of a gate is known only within a factor.** The two bounds of CB3 differ by about $(k+a)/(k-1)$ per gate. The ceiling CB15 uses the upper bound and the floor CB14 the lower, so for $a\gg k$ they are far apart, and the ceiling summed over all triggers with $g$ gates is not small.
3. **No ceiling for entangled triggers.** CB15 covers only circuits in which the trigger is a separate part feeding a mux at the output. Already at $s=2$, $16$ of the $40$ triggered circuits counted in Section 4 are not of this form. So this file has no upper bound on the total posterior share of aimed payloads, and "rare" in sentence 12 is a guess.
4. **Uniform prior with large slack.** CB11 is conditional on the posterior core size, which we cannot control; the claim that a typical core has size of order $\sqrt s$ is a heuristic; CB13 rests on five sizes at $k=3$ and three at $k=4$. The limit could be near $\frac12$, which would make "indifference" the right word and "hedge" the wrong one.
5. **Length prior.** CB8 is two-sided but polynomial. Whether the true share falls like $1/s_D$ or stays constant for large targets is not settled; the computed values (2 to 6 per cent) are for the prior cut at five gates, which favours small circuits.
6. **"Aimed" is not defined.** The distinction between unaimed underdetermination and a deviation chosen by something inside the hypothesis carries the conclusion, and it is formal only for separable triggers. Condition 3 of CB22 cannot at present be checked for a given circuit.
7. **CB18(2) is a knife-edge example.** The zero share at every use holds for $\mu_s$ at exactly the least size. For the length prior we have no theorem that the share at a use does not grow with the rarity of uses, only the absence of a construction and the ceiling for separable triggers.
8. **CB16 is about sets of uses with no common feature.** Real critical uses may share a feature that the honest computation already exposes; then the trigger is cheap and entangled, and items 3 and 6 apply.
9. **The world is outside the predictor.** Here the data and the critical query are given from outside. A circuit world that contains the predictor is far smaller than the predictor needs to be, and the regime in which the target is not in the class (CB4 is then void; task D at $s=1$) is the usual one. It is not treated.
10. **Citations.** Christiano (2018), Hubinger (2019), Valiant (1976), Pippenger and Fischer (1979), Valle-Pérez et al. (2019), Dingle et al. (2018) and Mingard et al. (2021) are cited from memory. The summaries of the two posts in Section 6 may misstate them.
11. **CB24(2)** identifies the cellular class with the note's bounded mixture without writing out a universal rule; the thresholds in CB24(3) are orders of magnitude taken from the note's statements, not new theorems. **CB25** is a guess throughout: gradient descent is not posterior sampling, and the factor $10^3$ to $10^8$ is an impression.
12. **The script** was checked against the totals $N_s$ and against the statements proved independently (CB2, CB10, CB15, CB21), but there is no second implementation. CB5 assumes the target is in the class.
13. I did not read the other files in `research/`, as instructed, so agreement with them is unchecked.
