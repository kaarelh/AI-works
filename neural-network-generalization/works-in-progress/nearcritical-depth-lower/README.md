# Exponential sample complexity arbitrarily near mean-field criticality

[Read the paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A Gaussian Bayesian tanh network can need exponentially many examples even for the constant Boolean target, when its variance prefactor is slightly above one. This note quantifies how the depth and width depend on that distance from criticality.

Write $t=1+\epsilon$ and $D=d+1+\log(1/\epsilon)$. The theorem uses independent Gaussian weights with variances $t^2/d$ in the first layer, $t^2/N$ in later hidden layers, and $t^2/N^2$ in the readout. At

$$
H=\left\lceil K(\epsilon^{-4}+\epsilon^{-2}D)\right\rceil,
\qquad N=\left\lceil e^{AD}\right\rceil,
$$

with absolute constants, all globally margined Boolean truth tables have raw prior probabilities within a factor $1+e^{-cD}$ of each other. This is a statement about the actual finite network, including the rare margin event.

The learner first conditions on an absolute output margin greater than $1/2$ at every cube input, then on the observed labels. Every unseen input consequently has posterior probability close to one half for either label. Under the uniform cube distribution, more than $2^{d-1}$ examples are required to assign the correct label probability greater than $2/3$ on more than half the inputs. A constant target already has a bounded-weight implementation of width two at every depth.

Taking $\epsilon=d^{-1/2}$ gives a prefactor tending to one, depth $H=\Theta(d^2)$, and a lower bound of $\exp(\Omega(\sqrt H))$ examples. When $d\gtrsim\epsilon^{-2}$, the bound has the natural form $\exp(\Omega(\epsilon^2H))$.

## What this does and does not establish

- The prior has mean-field width powers with prefactor **above** one. The unrestricted Boolean-depth question at exact canonical $t=1$, or at $t<1$, remains open.
- The theorem uses the stated global margin convention and specified widths. It does not assert failure at every larger width.
- It applies to any fixed confidence threshold above one half, and gives a Gibbs-error lower bound. Nearly half probabilities do not establish failure of deterministic majority prediction at exactly one half.
- The extra $\epsilon^{-4}$ depth term remains when $\epsilon^2D$ is small.
- There is no conflict with polynomial learning at each fixed depth; the obstruction concerns uniform dependence on depth.

The [earlier fixed-prefactor paper](../supercritical-depth-lower/README.md) keeps a simpler presentation for each fixed $t>1$. This paper is self-contained: its appendices give the empirical concentration, covariance geometry, and finite-width whitening proofs needed for the quantified theorem.

## Verification and reproducibility

The result has independent AI-agent mathematical audits of its ingredients and complete finite-width argument. It is **not Lean verified**. The [verification record](verification/README.md) distinguishes source audits from the final manuscript checks, names the standard external theorem used, and includes build hashes. [Detailed research notes](research-notes/README.md) are also included.

Build with a TeX Live installation containing `latexmk`:

```sh
./build.sh
```

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.
