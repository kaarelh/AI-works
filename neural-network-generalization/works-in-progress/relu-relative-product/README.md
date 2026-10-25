# ReLU compression above the depth baseline

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Independent audit](verification/independent-audit.md)

A globally margined nonconstant Boolean ReLU classifier has an unavoidable norm cost that grows with depth. This paper separates that baseline from the additional cost of the represented function.

For a network with $H$ hidden layers, input dimension $d$, and layer Frobenius product $P$, define

$$
T=\frac{dP^2}{2^H}.
$$

The main results are:

- **A sharp baseline at one input bit.** Every nonconstant unit-margin classifier satisfies $P^2\ge(1+d^{-1/H})^H$. For the Gaussian weighted energy and $L=H+1$, this implies $\kappa\ge2L+\log d-2\log2$. At $d=1$, the stronger exact finite-depth bound $L2^{H/L}$ is attained by a dictator at every common width at least two.
- **Compression in terms of the relative product.** The same Boolean function has another ReLU representation of depth $O(1+\log T)$ and product $\exp(O(1+\log T))$, independently of its original depth and widths. No hidden robustness condition is imposed.
- **A cold-prior learning consequence.** For a target with relative product $T_*$, a number of examples polynomial in $d,T_*,1/\varepsilon,\log(1/\delta)$ suffices for the posterior-confidence criterion above $2/3$, independently of learner width and learner depth. The statement takes the Gaussian scale sufficiently small at **each fixed finite architecture**; that scale threshold may depend on the architecture and target.

The network has ReLU hidden activations, an augmented constant input, and no separately supplied hidden biases. All constant rails are counted. The posterior conditions on absolute output margin greater than $1/2$ at every Boolean input and exact noiseless training labels. Training and test inputs have the same arbitrary distribution, and posterior mixtures are allowed.

The cold prior is isotropic in the weighted energy coordinates

$$
\kappa=\frac dN\|W_1\|_F^2+
\sum_{s=2}^{H}\|W_s\|_F^2+N\|v\|_2^2.
$$

Equivalently, the independent physical entry variances are $N\sigma^2/d$, $\sigma^2$, and $\sigma^2/N$, with $\sigma\to0$ at fixed learner width and depth.

**The general depth question remains open.** The target's relative product can itself be exponential in target depth. This is therefore neither a joint polynomial bound for arbitrary small deep teachers nor an exponential sample lower bound. The paper does not establish the analogous statistical theorem at every prescribed fixed Gaussian exponent.

The baseline, compression, counting, and cold-prior arguments are included in the paper. An optional circuit consequence uses the [product-to-parallel-circuit theorem](../boolean-depth-barriers/paper.pdf). The results have undergone conventional mathematical audits and have not been formalized in Lean. See the [verification record](verification/README.md).

Run `./build.sh` with `latexmk` and a standard TeX installation to rebuild the PDF. Generated build files are excluded from version control.
