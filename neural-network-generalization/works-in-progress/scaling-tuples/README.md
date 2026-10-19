# Layerwise scaling: a collapsed-layer prior and conjectured learning regions

Research note, 19 October 2026. The theorem below has conventional proofs and independent AI-agent mathematical checks; it is not Lean verified. The learning-region predictions remain conjectures. [Technical FAQ, Question 9](../../TECHNICAL-FAQ.md#9-can-we-classify-all-tuples-of-layerwise-scaling-exponents) gives the interpretation and the original layer-collapse heuristic.

## A precise collapsed-layer example

Fix a Boolean cube $X=\lbrace -1,1\rbrace ^d$, with $d\ge1$, and append a constant input coordinate. Consider one hidden tanh layer of width $N$ and a linear readout:

$$
z_N(x)=\sum_{i=1}^N v_i\tanh(w_i\cdot(x,1)).
$$

The coordinates are independent centered Gaussians with variances $c_1N^{-a}/d$ in each $w_i$ and $c_2N^{-b}$ in each $v_i$, where $c_1,c_2>0$ and **$a>b>1$** are fixed. The first layer is more tightly scaled than the readout. For $f:X\to\lbrace -1,1\rbrace $, let

$$
A_{N,f}=\lbrace f(x)z_N(x)>1/2\text{ for every }x\in X\rbrace .
$$

The polynomial threshold degree $r(f)$ is the least degree of a real polynomial $p$ such that $f(x)p(x)>0$ on $X$. Constants have degree zero. Write $k(f)$ for the least **positive odd** integer at least $r(f)$, and put

$$
\rho_k=\frac{ka+b}{k+1}.
$$

**Theorem.** For each fixed $f$ and fixed domain, there are constants $c,C>0$ and $N_0$ such that, for $N\ge N_0$,

$$
\exp(-CN^{\rho_{k(f)}})
\le \Pr(A_{N,f})
\le \exp(-cN^{\rho_{k(f)}}).
$$

Thus the raw negative log-prior mass has order $N^{\rho_{k(f)}}$. The proof uses $b>1$ only through $\rho_k>1$ in step 3. Since $\rho_k\ge\rho_1=(a+b)/2$, the theorem also holds whenever $a>b$ and $a+b>2$. The statement is width first: the constants and required width can depend on the entire target and domain. It is not a uniform bound as dimension grows.

### 1. Lower bound on the energy of every implementation

The Gaussian action is

$$
I_N(W,v)=\frac{dN^a}{2c_1}\lVert W\rVert_F^2+
\frac{N^b}{2c_2}\lVert v\rVert_2^2.
$$

For odd $k\ge3$, let $T_{k-2}$ be the Taylor polynomial of tanh through degree $k-2$. There is a constant $C_k$ such that

$$
|\tanh u-T_{k-2}(u)|\le C_k|u|^k\qquad(u\in\mathbb R).
$$

Taylor's theorem proves this for $|u|\le1$; boundedness of tanh and the lower degree of $T_{k-2}$ prove it outside that interval. For $k=1$, use $T_{-1}=0$ and $|\tanh u|\le|u|$.

Consequently the polynomial $P(x)=\sum_i v_iT_{k-2}(w_i\cdot(x,1))$ satisfies

$$
\max_{x\in X}|z_N(x)-P(x)|
\le C_{d,k}\lVert v\rVert_2\lVert W\rVert_F^k
\le C'_{d,k}I_N^{(k+1)/2}N^{-(ka+b)/2}.
$$

Here Cauchy--Schwarz and $\sum_i\lVert w_i\rVert^{2k}\le(\sum_i\lVert w_i\rVert^2)^k$ give the first inequality. If $I_N<cN^{\rho_k}$ for a sufficiently small constant $c$, the error is below $1/2$. A network in $A_{N,f}$ would then make $P$ a sign representation of $f$ of degree at most $k-2$. This contradicts the definition of $k=k(f)$. For $k=1$, approximation by zero contradicts the output margin directly. Therefore every implementation in $A_{N,f}$ has

$$
I_N\ge cN^{\rho_{k(f)}}.
$$

### 2. A matching finite-neuron construction

Choose a threshold polynomial $p$ of degree at most $k$ with $f(x)p(x)\ge2$. Homogenize it to degree $k$ using the constant coordinate. Homogeneous polynomials of degree $k$ are finite linear combinations of powers $(u\cdot(x,1))^k$; this follows, for example, from polarization of monomials.

All odd Taylor coefficients of tanh are nonzero. For $m=(k+1)/2$, choose distinct positive numbers $\lambda_1,\ldots,\lambda_m$. An invertible Vandermonde system gives constants $\alpha_j$ cancelling the odd Taylor terms below degree $k$ and setting its coefficient to one. Thus, on any fixed bounded set of $u$,

$$
t^{-k}\sum_{j=1}^{m}\alpha_j\tanh(\lambda_jtu)
=u^k+O(t^2).
$$

Apply this construction to every power in the representation of $p$. It uses a fixed finite number of neurons, independent of $N$, with first-layer weights of order $t$ and readout weights of order $t^{-k}$. Set unused neurons to zero. Its output is $p(x)+O(t^2)$ uniformly on the cube, and its action is at most

$$
C\bigl(N^at^2+N^bt^{-2k}\bigr).
$$

Taking $t=N^{-(a-b)/(2(k+1))}$ makes both terms of order $N^{\rho_k}$ and sends the output error to zero. For all sufficiently large widths, the constructed network has signed outputs at least one.

### 3. Turning the energy bounds into probability bounds

There are $P_N=N(d+2)$ Gaussian parameters, and $2I_N$ under the raw prior is chi-squared with $P_N$ degrees of freedom. Its exponential moment at $1/4$ gives

$$
\Pr(I_N\ge cN^{\rho_k})
\le 2^{P_N/2}\exp(-cN^{\rho_k}/2).
$$

Since $\rho_k>b>1$, this proves the required upper probability bound for large $N$.

For the lower bound, take a coordinate box of radius $N^{-K}$ about the construction in step 2, including every unused parameter. The central weights grow or shrink only polynomially in $N$. With $K$ a sufficiently large fixed number, tanh's Lipschitz bound ensures that every point of the box retains signed output above $1/2$, and throughout the box $I_N\le C'N^{\rho_k}$. Explicitly, the output perturbation is bounded by $NN^{-K}$ plus a constant times $t^{-k}N^{-K}$; by $(x+y)^2\le2x^2+2y^2$, the action anywhere in the box is at most twice the central action plus a constant times $N^{a+1-2K}+N^{b+1-2K}$. All requirements hold after increasing $K$.

The logarithm of the box volume and of the Gaussian normalizing factor are each $O(N\log N)$. Integrating the Gaussian density over this box therefore gives

$$
\Pr(A_{N,f})\ge\exp\bigl(-C'N^{\rho_k}-O(N\log N)\bigr)
\ge\exp(-C''N^{\rho_k}).
$$

This completes the theorem.

## Consequences for the actual conditioned prior

Global-margin conditioning preserves ratios between function events. For any fixed training set, conditioning on the global margin and its exact training labels is equivalent to restricting the raw prior to the union of $A_{N,g}$ over sample-consistent Boolean functions $g$.

Because $a>b$, the exponents $\rho_k=a-(a-b)/(k+1)$ strictly increase with $k$. There are finitely many functions on the fixed cube. The theorem therefore implies that posterior mass outside the sample-consistent functions of **minimum odd-rounded threshold degree** tends to zero as $N\to\infty$. It does not determine weights among ties. The raw mass formula must not be substituted unchanged for normalized probabilities: the global-margin normalizer also has a cost.

This ordering can disagree strongly with circuit complexity. For even $d$, full parity has threshold degree $d$, hence rounded degree $d+1$. Every other Boolean function except its negation has threshold degree at most $d-1$. For odd $d$ the separation fails at this level: parity then has $k=d$, the same rounded degree as every function of threshold degree $d-1$. To see this, write $\chi(x)=\prod_jx_j$. If $g\ne\chi,-\chi$, then $g\chi$ takes both signs. Choose strictly positive numbers $s_x$ so that $\sum_x g(x)\chi(x)s_x=0$. The multilinear interpolation polynomial with values $g(x)s_x$ then has zero Fourier coefficient of degree $d$, degree at most $d-1$, and sign $g$. Parity itself cannot have a lower-degree sign representation, since the mean of $\chi p$ would be both zero by Fourier orthogonality and positive by sign agreement.

Thus, for even dimension, parity is asymptotically less probable than **every** function except itself and its negation, including functions requiring exponentially larger Boolean circuits. This is a failure of a universal circuit-size ordering across all exponent tuples.

It is **not an exponential sample-complexity lower bound**. A posterior can exclude the exact target and still put almost all correct-label probability on most test inputs. Nor does this prove an intermediate sample-complexity phase: this degree-based prior might still belong to the parity-hard side of a coarse dichotomy.

## Conjectures worth testing next

The FAQ gives a tentative frozen-kernel region and a sparse-feature circuit-learning region. The latter uses one hidden layer, $a>0$ and $a\le b\le a+2$. A population $M$ of repeated order-one features has action of order $MN^a+N^b/M$, balanced at $M=N^{(b-a)/2}$ and action $N^{(a+b)/2}$. This is only a construction. Controlling the rest of the width and all competing posterior functions is the missing theorem.

For general deep tuples, balancing an active subnetwork is insufficient: typical intervening layers can regenerate a full nonlinear kernel at a cheaper scale. For example, the two-hidden-layer variance-exponent tuple $(a_1,a_2,a_3)=(0.2,0.5,1.1)$ of FAQ Question 9 has shrinking first-hidden preactivations (variance $N^{-0.2}$) but saturated second-hidden preactivations (variance $N^{0.3}$). Its output forcing has the candidate Gaussian scale $N^{0.1}$, below the $N^{0.6}$ scale obtained by balancing a structured active subnetwork. These are scaling estimates, not a posterior theorem for that tuple.

## Review record

The proof was independently checked in the [Taylor-prior audit](verification/taylor-prior-audit.md) and the [scaling assessment](verification/independent-scaling-assessment.md). The [phase assessment](verification/phase-note.md) records the separate conjectural discussion. These are AI-agent checks, not external peer review or Lean verification. No existing main theorem is changed by this note.
