# Obstructions to width-independent bounds from raw prior mass

**Supporting research note; not Lean verified.** 19 October 2026. See the [mathematical review](verification/README.md#raw-prior-mass-obstructions). A conventional Bayesian learning certificate often charges the negative logarithm of the prior probability of an accurate implementation. This note identifies two obstacles to making that cost polynomial in teacher complexity and independent of learner width: a mismatched output scale, and the allocation of variance across Boolean functions by a Gaussian process. These are obstructions to a particular certificate, not sample-complexity lower bounds for the learner.

The [finite-sample calculation](README.md) uses a more general variational certificate, charging relative entropy for a comparison distribution with small expected output error. The scale obstruction applies to that certificate too. Throughout, “raw prior” means the weight prior before any conditioning on output margins. Outputs must approximate specified real values, rather than merely have the correct signs.

## 1. Vanishing output scale: a constant target already costs width

Consider any network with bounded final hidden activations $|h_j(x)|\le1$ and an independent Gaussian linear readout,

$$
z_w(x)=\sum_{j=1}^N v_jh_j(x),\qquad
v_j\sim\mathcal N(0,N^{-\gamma-1}).
$$

The hidden-layer prior is otherwise arbitrary. Let $\mu$ be any input distribution, fix $0\le\rho<1$, and consider the constant target $f=1$. Then

$$
\pi_N\left(\lVert z_w-1\rVert_{L^2(\mu)}\le\rho\right)
\le \exp\left[-\frac{(1-\rho)^2}{2}N^\gamma\right].
$$

To prove this, set $M(w)=\mathbb E_Xz_w(X)$. Conditional on the hidden layers, $M=\sum_jv_jm_j$, where $m_j=\mathbb E_Xh_j(X)$ satisfies $|m_j|\le1$. Its conditional variance is at most $N^{-\gamma}$. Consequently

$$
\mathbb E_{\pi_N}e^{tM}\le e^{t^2N^{-\gamma}/2}.
$$

The displayed approximation event implies $M\ge1-\rho$ by Cauchy–Schwarz. Applying the exponential Markov inequality and optimizing $t$ proves the claim. For every $\gamma>0$, even this fixed simple target has negative log prior mass growing at least as $N^\gamma$.

The same cost is unavoidable for a broad comparison distribution. If

$$
\mathbb E_q\lVert z_w-1\rVert_{L^2(\mu)}^2\le\rho^2,
$$

then $\mathbb E_qM\ge1-\rho$. The relative-entropy variational inequality gives, for every $t\ge0$,

$$
\mathrm{KL}(q\Vert\pi_N)
\ge t\mathbb E_qM-\log\mathbb E_{\pi_N}e^{tM}
\ge t(1-\rho)-\frac{t^2N^{-\gamma}}2.
$$

Optimization yields

$$
\mathrm{KL}(q\Vert\pi_N)\ge\frac{(1-\rho)^2}{2}N^\gamma.
$$

Thus changing the shape or extent of the comparison distribution cannot remove this raw-prior cost. The conclusion does not require localization near a particular implementation, Gaussian hidden weights, or a finite input domain.

More generally, at a fixed input, if a centered output has standard deviation $s_N\to0$, then a nonzero target value $a$ and tolerance $r<|a|$ satisfy

$$
\pi_N(|z_w(x)-a|\le r)\le\frac{s_N^2}{(|a|-r)^2}.
$$

This elementary second-moment bound already forces the raw cost to diverge. Sub-Gaussian control, as above, gives a stronger rate.

## 2. Diverging output scale: finite-amplitude neighborhoods become rare

With independent centered Gaussian readout of variance $\tau_N^2$, write

$$
V_N(x)=\tau_N^2\sum_jh_j(x)^2.
$$

Conditional on the hidden layers, $z_w(x)$ is Gaussian with variance $V_N(x)$. Its probability of an interval of length $2r$ is at most

$$
\pi_N(|z_w(x)-a|\le r)
\le\mathbb E\min\left(1,\frac{2r}{\sqrt{2\pi V_N(x)}}\right).
$$

If $V_N(x)\to\infty$ in probability, the right side tends to zero. Quantitatively, if $V_N(x)\ge u_N^2$ except on an event of probability $\eta_N$, then the bound is at most

$$
\eta_N+\sqrt{2/\pi}\,r/u_N.
$$

A lower bound $\log u_N-O(1)$ on the negative log probability follows when $\eta_N=O(1/u_N)$. Concentration without a rate proves divergence, but does not justify that particular rate. A uniform function tube is contained in the single-input event above. For integrated prediction error, one instead needs the scale condition on a region of positive input probability.

Divergence of the unconditional output standard deviation alone is insufficient. For example, a centered Gaussian scale mixture whose conditional variance is $1$ with probability $1-1/N$ and $N^3$ with probability $1/N$ has diverging variance, while its probability of a fixed interval converges to the standard Gaussian probability of that interval.

For any event $G$, data processing of relative entropy gives

$$
q(G)\ge p\quad\Longrightarrow\quad
\mathrm{KL}(q\Vert\pi_N)
\ge p\log\frac1{\pi_N(G)}-\log2.
$$

Indeed, map both measures to the indicator of $G$ and use the binary relative-entropy formula. Hence a fixed positive requirement on the comparison distribution's mass in an increasingly rare amplitude interval also forces its relative-entropy cost to diverge.

## 3. Constant output scale: a Gaussian prior cannot favor every small parity

Constant-order output variance does not by itself imply a Gaussian-process limit. Suppose, additionally, that the limiting function $F$ really is a centered Gaussian vector on the Boolean cube $\lbrace-1,1\rbrace^d$. Give the cube its uniform input distribution and define

$$
V=\mathbb E_X\mathbb E[F(X)^2],\qquad
\chi_S(x)=\prod_{i\in S}x_i,\qquad
A_S=\mathbb E_X[F(X)\chi_S(X)].
$$

Assume $V>0$. If $V=0$, the process is identically zero almost surely and all the parity approximation events below have probability zero.

The Boolean characters are an orthonormal basis. Parseval's identity and finite summation imply

$$
\sum_{S\subseteq\lbrace1,\ldots,d\rbrace}\mathrm{Var}(A_S)=V.
$$

At least one nonempty $S$ therefore satisfies

$$
\mathrm{Var}(A_S)\le\frac{V}{2^d-1}.
$$

If $\lVert F-\chi_S\rVert_{L^2}\le\rho<1$, then $A_S\ge1-\rho$, again by Cauchy–Schwarz. Since $A_S$ is a centered Gaussian, its one-sided tail bound proves

$$
-\log\mathbb P\left(\lVert F-\chi_S\rVert_{L^2}\le\rho\right)
\ge\frac{(1-\rho)^2(2^d-1)}{2V}.
$$

If its variance is zero, the event is impossible and the same inequality holds with infinite cost. Thus when $V$ is bounded, or merely polynomial in $d$, some parity has exponential raw-prior cost despite its small circuit.

A symmetry assumption gives a sparse-parity version. If the law of $F$ is invariant under permutations of input coordinates, the variances $\mathrm{Var}(A_S)$ agree for all $|S|=k$. Parseval then gives, for every such $S$,

$$
-\log\mathbb P\left(\lVert F-\chi_S\rVert_{L^2}\le\rho\right)
\ge\frac{(1-\rho)^2}{2V}\binom dk.
$$

The same lower bound applies to an accurate comparison distribution for this GP. If $\mathbb E_q\lVert F-\chi_S\rVert_{L^2}^2\le\rho^2$, then $\mathbb E_q A_S\ge1-\rho$. Applying the entropy variational inequality to the Gaussian linear statistic $A_S$ gives

$$
\mathrm{KL}(q\Vert\pi)\ge\frac{(1-\rho)^2}{2\mathrm{Var}_{\pi}(A_S)}.
$$

Thus a broad comparison distribution cannot remove this Gaussian variance-budget cost either. Here $\pi$ is the GP law; the inequality also holds for a parameter comparison distribution inducing these outputs, by data processing.

These are prior-mass and comparison-cost statements, not the sample lower bound for parity proved elsewhere under different posterior conventions. They do not analyze how observations change the posterior.

### Small tanh teachers suffice

The obstruction also applies to real outputs of small bounded-weight tanh teachers, without requiring a tanh network to equal a Boolean function on a continuous domain. For a parity on $k$ coordinates, put $s=\sum_{i\in S}x_i$. On the Boolean cube, $s$ takes $k+1$ values spaced two apart. A linear combination of the $k$ thresholds

$$
\mathrm{sign}(s-(-k+2j-1)),\qquad 1\le j\le k,
$$

with alternating coefficients of magnitude one and a constant term, equals the parity. Replacing each threshold by $\tanh(A(s-(-k+2j-1)))$ incurs total error at most $2ke^{-2A}$. Taking $A=\tfrac12\log(2k/\eta)$ gives uniform error at most $\eta$. A constant hidden unit supplies the constant term. This produces a depth-two teacher of width at most $k+1$ with weights bounded by $O(k\log(k/\eta))$.

If this teacher's output is $g$, then $\lVert F-g\rVert_{L^2}\le\rho$ implies $A_S\ge1-\rho-\eta$. The preceding bounds therefore remain valid with $1-\rho$ replaced by $1-\rho-\eta>0$.

### Transfer from a finite-width network

Suppose the vector of outputs of the finite-width raw prior converges in distribution to $F$ on the entire fixed Boolean cube. An $L^2$ ball around a fixed target is a closed subset of this finite-dimensional space. The closed-set part of the Portmanteau theorem gives

$$
\limsup_{N\to\infty}\pi_N(\lVert z_w-g\rVert_{L^2}\le\rho)
\le\mathbb P(\lVert F-g\rVert_{L^2}\le\rho).
$$

Consequently the Gaussian obstruction transfers to the limiting raw-prior cost. This takes width to infinity at each fixed $d$; it supplies no quantitative uniform threshold for simultaneously growing $d$ and $N$.

## 4. Why marginal output scale is not a complete classification

Joint Gaussianity matters. On a fixed Boolean cube, choose a circuit $C$ using a prefix-code prior $q(C)=2^{-\ell(C)}/Z$, where $\ell(C)$ is its code length and $0<Z\le1$ is the normalizing constant. Let $f_C$ be its Boolean output, draw $G\sim\mathcal N(0,1)$ independently, and set

$$
F(x)=Gf_C(x).
$$

Every individual $F(x)$ is exactly standard Gaussian. Nevertheless the joint law is a mixture of Gaussian functions associated with different circuits, rather than a GP. For any specified circuit $C$ and fixed $0<\rho<1$,

$$
\mathbb P(\lVert F-f_C\rVert_\infty\le\rho)
\ge q(C)\,\mathbb P(|G-1|\le\rho).
$$

Its negative log probability is therefore at most $\ell(C)\log2+O_\rho(1)$. Thus constant Gaussian marginals can coexist with a circuit-description prior. This is a structured function prior, not the independent fully connected weight prior studied here. It isolates why a standard-deviation observation cannot establish Gaussian joint behavior or exclude circuit-like prior mass.

## 5. A complete obstruction for power scalings with one hidden layer

For one hidden layer, the additional Gaussian-limit statement can be proved for all deterministic power scalings. On the Boolean cube, augment each input by a constant coordinate, write $D=d+1$, and consider

$$
z_N(x)=b_N\sum_{j=1}^N g_j\tanh(a_Nu_j^{\mathsf T}\bar x/\sqrt D),
\qquad u_j\sim\mathcal N(0,I_D),\quad g_j\sim\mathcal N(0,1),
$$

with all draws independent. Let $q(a)=\mathbb E\tanh^2(aG)$ for standard Gaussian $G$. Every input has exact output variance

$$
s_N^2=Nb_N^2q(a_N).
$$

If $a_N\to a\in[0,\infty]$, the normalized output vector $z_N/s_N$ converges jointly to a centered Gaussian function. For $0<a<\infty$, its covariance is

$$
K_a(x,y)=\frac{\mathbb E[\tanh(aG_x)\tanh(aG_y)]}{q(a)},
\qquad \mathbb E[G_xG_y]=r(x,y)=\frac{\bar x^{\mathsf T}\bar y}{D}.
$$

At the two endpoints, $K_0(x,y)=r(x,y)$ and $K_\infty(x,y)=(2/\pi)\arcsin r(x,y)$.

Here is a proof that also covers rapidly shrinking first-layer scales. Concavity of tanh on the positive half-line gives $q(a)\ge a^2q(1)$ for $0<a\le1$. Together with $|\tanh t|\le|t|$, this implies

$$
\sup_{a>0}\frac{\mathbb E\tanh^4(aG)}{q(a)^2}\le\frac3{q(1)^2}.
$$

For $a\ge1$, boundedness of tanh and $q(a)\ge q(1)$ give the same bound. Conditional on the hidden weights, the normalized output vector is Gaussian. Each entry of its conditional covariance is an empirical average of $N$ independent normalized feature products. Cauchy–Schwarz and the fourth-moment estimate bound its variance by $3/[Nq(1)^2]$. All covariance entries therefore concentrate on the fixed finite cube. As $a\downarrow0$, the normalized feature converges in $L^2$ to $G$; as $a\to\infty$, it converges to $\mathrm{sign}(G)$. These facts give the endpoint covariance formulas. Conditional Gaussian characteristic functions prove the asserted joint convergence.

Now take $a_N=A N^\alpha$ and $b_N=B N^\beta$, with $A,B>0$ fixed independently of $N$ and $d$. Since $q(a)\sim a^2$ near zero and $q(a)\to1$ at infinity, the output-variance exponent is

$$
e=1+2\beta+2\min(\alpha,0).
$$

Equivalently, if input-weight variance is proportional to $N^{-u}/D$ and readout variance to $N^{-v}$, then $e=1-v-\max(u,0)$. The order-one output-scale line is $v+\max(u,0)=1$.

If $e<0$, the constant target already has vanishing good-function mass: the triangle inequality and Markov give

$$
\mathbb P(\lVert z_N-1\rVert_{L^2}\le\rho)
\le\frac{s_N^2}{(1-\rho)^2}\longrightarrow0.
$$

If $e>0$, that same event implies $|z_N(x_0)|\le2^{d/2}(1+\rho)$ at every fixed input $x_0$. The normalized scalar output converges to a non-atomic standard Gaussian, while $s_N\to\infty$, so this probability again tends to zero.

If $e=0$, the output converges to a Gaussian function of finite positive variance

$$
V=\begin{cases}
A^2B^2,&\alpha<0,\\
B^2q(A),&\alpha=0,\\
B^2,&\alpha>0.
\end{cases}
$$

The parity obstruction in Section 3 applies. The covariance is also invariant under permutations of input coordinates, so its sparse-parity conclusion applies as well.

Thus **none of these power scalings gives a negative log raw good-function mass bounded polynomially in teacher width, input dimension, weight bound and inverse accuracy, uniformly over learner widths and teachers**. Away from $e=0$, even a constant teacher has a width-diverging cost. At $e=0$, some depth-two teacher of width $O(d)$ and polynomially bounded weights has a cost exponential in $d$. Dimension-independent $A,B$ ensure that $V$ does not erase this exponential factor; polynomially growing $V$ would also suffice. This is a complete classification of this restricted prior-mass question, not of posterior learning behavior or general deep networks.

## 6. Scope: prior certificates, conditioning, and actual learning

A diverging raw-prior cost need not mean that the learner needs more samples. Consider scalar Gaussian regression with observation variance $s^2>0$ and prior $\theta\sim\mathcal N(0,u_N^2)$, where $u_N\to\infty$. The prior mass of any fixed bounded interval is $O(1/u_N)$. After $n\ge1$ observations, however, the posterior has

$$
v_n=(u_N^{-2}+n/s^2)^{-1},\qquad
m_n=v_n\sum_{i=1}^nY_i/s^2.
$$

At fixed $n$, these converge to $s^2/n$ and the sample mean. The increasing raw log-prior cost does not produce increasingly slow learning. A prior-mass upper bound can be loose because it does not exploit cancellation between posterior numerator and denominator.

Amplitude requirements also matter. Multiplying every output by a positive deterministic factor leaves its sign function unchanged. A diverging output scale does not make a positive-sign or lower-margin event rare. Conversely, shrinking-scale penalties may cancel after conditioning: for $Z=uG$ with $G$ standard Gaussian,

$$
\mathbb P(Z\ge m\mid |Z|\ge m)=\frac12
$$

for every $u,m>0$, even though the unconditioned numerator tends to zero as $u\to0$. General global-margin conditioning replaces raw probabilities by ratios; its normalizing denominator must be analyzed.

The results above therefore do not contradict width-independent learning theorems established through margin-conditioned priors, relative energy, compression, or appropriately scaled likelihoods. They establish a narrower limitation: an absolute raw-prior mass or relative-entropy charge for a prescribed nonzero output scale can be intrinsically expensive. In a Gaussian-process limit at bounded output variance, that same charge is exponentially expensive for some small parity teachers. Extending this dichotomy to every depth and every layerwise scaling requires additional limit theorems; output standard deviation alone does not provide them.
