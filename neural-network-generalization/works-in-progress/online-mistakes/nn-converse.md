# What a few online mistakes imply for a strong-prior neural network

ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob. Research note, 21 October 2026.

We prove a weak converse for the original neural-network support in a limit that takes the strong-prior limit first and width second: few cumulative mistakes imply that the target has a circuit of at most exponential size in the mistake count. Adding a fixed upper bound on network outputs improves this to a polynomial converse. The polynomial converse for the original fixed-width learner remains open. These results have undergone independent AI-agent mathematical review but are not Lean verified.

## 1. Model and online implication

Let $X=\lbrace-1,1\rbrace^d$, where $d\geq1$. A depth-$L$ tanh network has $L-1$ hidden layers of width $N$, an appended constant input, no further biases, and a linear readout $z_w$. Its normalized energy is

$$
\kappa_N(w)=\frac dN\|W^1\|_F^2+\sum_{s=2}^{L-1}\|W^s\|_F^2+N\|v\|_2^2.
$$

Let $\kappa_N(g)$ be the infimum over networks satisfying $g(x)z_w(x)>1/2$ everywhere, and put $\kappa_\infty(g)=\inf_N\kappa_N(g)$. We also consider the additional restriction $|z_w(x)|<U$ everywhere, for fixed $U>1$, denoting the resulting quantities by a superscript $U$.

For either energy, consider an online learner whose predictive distribution is supported on the functions of smallest energy consistent with revealed labels. Deterministic selection and majority prediction are also allowed. At a step where the minimum feasible energy increases strictly, **every** previously minimizing function has the wrong label. The step is therefore a mistake for deterministic selection or majority prediction, a posterior draw is wrong with probability one, and it is a confidence mistake for every positive required correct-label probability. Tied minimizers do not invalidate this implication. A posterior mistake can occur without an energy increase; the reverse implication is unnecessary.

This support property holds for every subsequential predictive limit obtained by first taking the strong-prior limit at each fixed width and then sending width to infinity. Indeed,

$$
\kappa_N(g)\longrightarrow\kappa_\infty(g).
$$

Clone a fixed width-$n$ implementation $k=\lfloor N/n\rfloor$ times, padding any unused neurons. This preserves its output, does not increase first-layer energy, preserves internal energy, and multiplies readout energy by $N/(kn)\to1$. The reverse inequality follows from the infimum definition. Finitely many Boolean functions exist, so positive limiting energy gaps exclude higher-energy functions. Cloning preserves the optional output cap. This limit has not been identified with any particular width-first $\gamma\geq1$ limit.

To deduce a statement about the entire target, revealed inputs must cover $X$. An infinite iid stream with full support eventually does so almost surely. A finite prefix of easy inputs gives no such conclusion. On a smaller support, the same argument bounds the complexity of an extension agreeing with the target there.

## 2. An exact singleton construction

Fix $a\in X$ and write $I_a(x)=\mathbf{1}\lbrace x=a\rbrace$. Set

$$
A=\tfrac12\log(4(d+1)),\qquad F=1+A^2d(d+1),\qquad D=dF+16+2L.
$$

There are $d+1$ affine-tanh features with first-layer squared row norms at most $F$ such that

$$
I_a=\sum_{j=0}^d b_jh_j,\qquad \sum_j|b_j|\leq4.
$$

Take $h_0=\tanh(1)$ and

$$
h_j(x)=\tanh\!\left(A\left[a\cdot x-(d-2j+1)\right]\right),\quad 1\leq j\leq d.
$$

**Proof.** Put $s=(d-a\cdot x)/2\in\lbrace0,\ldots,d\rbrace$ and $q_j=(1+h_j)/2$. The matrix with columns $1,q_1,\ldots,q_d$ differs entrywise by at most $e^{-2A}$ from the staircase matrix $T$ with columns $1,\mathbf{1}\lbrace s<1\rbrace,\ldots,\mathbf{1}\lbrace s<d\rbrace$. Its inverse maps a value vector $y$ to $y_d$ and the differences $y_{j-1}-y_j$, so its induced $\ell^1$ norm is at most two. For the perturbation matrix $E$,

$$
\|T^{-1}E\|_1\leq2(d+1)e^{-2A}=\tfrac12.
$$

The staircase coefficients of $I_a$ have $\ell^1$ norm one. A Neumann series gives coefficients in $1,q_1,\ldots,q_d$ with total absolute value at most two. Expanding the $q_j$ and replacing $1$ by $h_0/\tanh(1)$ costs less than another factor two. The row-norm estimate follows from $d$ coefficients of magnitude $A$ and a bias of magnitude at most $Ad$.

At every depth $L\geq2$ and for every real $t$, this implies

$$
\inf_N\ \inf_{z_w=tI_a}\kappa_N(w)\leq D+16t^2. \tag{2.1}
$$

For $L=2$, clone feature $j$ in asymptotic proportion $|b_j|/\sum_i|b_i|$, dividing its readout coefficient among its copies. First-layer energy is at most $dF$, and limiting readout energy is $t^2(\sum_j|b_j|)^2\leq16t^2$. Every finite choice of positive multiplicities represents the function exactly; only the energy approaches the bound. Zero coefficients may be omitted.

For $L\geq3$, let every second-layer neuron compute $\tanh(\sum_j b_jh_j)=\tau I_a$, where $\tau=\tanh(1)$. The limiting matrix energy is at most 16. In later hidden layers use constant matrices with entries $1/(N\tau)$, preserving $\tau I_a$; use readout entries $t/(N\tau)$. Each additional hidden matrix costs $\tau^{-2}<2$, and the readout costs $\tau^{-2}t^2<2t^2$. This proves (2.1). Exact representation avoids any consumption of existing strict-margin slack.

## 3. Direct sums and a weak converse for the original support

For realizable real functions $u,v$, let $E(u)$ be the infimum normalized energy over all widths at fixed depth. Then

$$
\sqrt{E(u+v)}\leq\sqrt{E(u)}+\sqrt{E(v)}. \tag{3.1}
$$

Clone the branches into asymptotic width fractions $1-\theta$ and $\theta$, with zero cross-block weights. First-layer energies are multiplied by their fractions, internal energies are unchanged, and readout energies are divided by their fractions. Total energy is at most $E(u)/(1-\theta)+E(v)/\theta$. Optimizing $\theta$ and taking approximation limits proves (3.1). Zero-energy cases follow by a limit.

Suppose a currently minimizing sign function has energy $K$. Choose a representative $z$ with energy arbitrarily close to $K$. To overwrite its value at $a$ with the desired sign $y$, set

$$
z_{\mathrm{new}}=z+(y-z(a))I_a.
$$

Every other value remains unchanged, and the new value at $a$ is $y$. Since bounded hidden activations imply $|z(a)|\leq\sqrt{\kappa_N(w)}$, (2.1) and (3.1) give

$$
\sqrt{K_{\mathrm{new}}}\leq5\sqrt K+\sqrt D+4. \tag{3.2}
$$

Choose representatives within an arbitrarily small energy tolerance and let that tolerance vanish. A minimizing sign function exists because finitely many sign functions exist, even when an optimal parameter vector is not attained.

A constant-sign implementation costs at most $d+2L\leq D$. Iterating (3.2) over $M$ energy-increase steps gives

$$
\kappa_\infty(f)\leq9D\,25^M. \tag{3.3}
$$

Indeed, its square root is at most $5^M[\sqrt{K_0}+(\sqrt D+4)/4]$, whose bracket squared is at most $9D$. Every energy increase is a mistake, so $M$ may be replaced by the total mistakes of any prediction convention from Section 1, after full revelation.

The original strong-prior compression theorem gives a bounded-weight depth-$L$ implementation of width

$$
C_L(f)\leq m_L\!\left(d,9D\,25^M+1\right).
$$

For fixed $L$, $m_L(d,K)$ is polynomial in $d,K$, with growth $K^{2(L-1)}$ up to logarithmic factors. Consequently

$$
C_L(f)\leq\mathrm{poly}_L(d)\exp(O_L(M)).
$$

This proves a logarithmic lower bound on mistakes in terms of circuit width. It is weaker than the desired polynomial converse.

## 4. A polynomial converse with an output cap

Add the support restriction $1/2<|z_w(x)|<U$ everywhere, for fixed $U>1$. The overwrite remains within this cap: it replaces exactly one output by $y\in\lbrace-1,1\rbrace$. Its amplitude is at most $U+1$. Set $P=D+16(U+1)^2$. The previous calculation becomes

$$
\sqrt{K_{\mathrm{new}}^U}\leq\sqrt{K^U}+\sqrt P.
$$

After $M$ mistakes and full revelation,

$$
\kappa_\infty^U(f)\leq P(M+1)^2,\qquad
C_L(f)\leq m_L\!\left(d,P(M+1)^2+1\right). \tag{4.1}
$$

This is polynomial in $d,U,M$ at fixed depth; the displayed compression bound has leading dependence $M^{4(L-1)}$, apart from logarithms. It applies to majority, posterior-sampling, and confidence mistakes under the minimum-energy support convention. The fixed output cap is an additional assumption.

## 5. Expected total mistakes

These conclusions also hold with the total mistake count replaced by its expectation $m=\mathbb E M$, including predictable adaptive query orders. **Invert the deterministic complexity inequality before taking expectations.** From (3.3), every complete-revelation path satisfies

$$
M\geq\max\!\left\lbrace0,\frac{\log(\kappa_\infty(f)/(9D))}{\log25}\right\rbrace.
$$

The right side is deterministic. Taking expectations and rearranging gives $\kappa_\infty(f)\leq9D\,25^m$. Likewise (4.1) gives $M\geq\sqrt{\kappa_\infty^U(f)/P}-1$, and hence

$$
\kappa_\infty^U(f)\leq P(m+1)^2.
$$

Compression gives the same circuit bounds with $m$ replacing $M$. This does not use a reversal of Jensen's inequality.

## 6. What remains open

The original fixed-width polynomial converse has several separate obstacles.

1. **Output amplitude.** The linear readout only gives $|z(x)|\leq\sqrt{\kappa_N(w)}$. An additive correction can therefore cost a constant fraction of the current energy. Bounded hidden activations do not make it uniformly cheap. A deep scalar amplification chain also cannot evade the necessary readout energy $N\|v\|^2\geq|z(x)|^2$.
2. **Fixed width.** Direct sums need fresh neurons. The unrestricted-width infimum supplies them; it does not prove the result at every fixed $N\geq C_L(f)$. The published compression theorem loses a constant energy factor, causing exponential growth if used after each mistake.
3. **Compression with nearly preserved energy.** A possible refinement trades greater polynomial width for energy at most $(1+\delta)K$ and small uniform output error. Its approximation-failure probability must be sufficiently smaller than $\delta$ to intersect the event of energy at most $(1+\delta)K$. Row-mass and matrix-norm events require the same careful budget. This could give a finite-width threshold for a bounded-output variant, but that theorem is not proved here.
4. **Clipping adds depth.** A scalar tanh applied to the readout bounds its output at constant multiplicative energy cost, but adds a hidden layer. Repeating this after each mistake increases depth and does not prove the fixed-depth claim.
5. **Selector gates.** The expression $(1-I_a)z+yI_a$ overwrites one value. A same-depth implementation with almost the original energy is missing. Gating every current feature separately can multiply width, and a suitable additive energy estimate has not been established.

The original fixed-width polynomial converse and extensions to width-first $\gamma\geq1$ Gibbs variational limits remain open. The compression theorem used here comes from the earlier strong-prior paper and original slides; the exact singleton and converse arguments are supplied here.

[Independent review and scope](verification/nn-converse-review.md) · [Strong-prior compression theorem](../../main-results/strong-prior-generalization/paper.pdf)
