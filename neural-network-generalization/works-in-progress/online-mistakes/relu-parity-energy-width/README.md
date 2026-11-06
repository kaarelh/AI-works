# Minimum Gaussian energy for parity requires exponential ReLU width

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

For an even parity of degree `r ≥ 4`, a shallow ReLU network attains the smallest possible Gaussian weight energy **if and only if its width is at least `2^(r−1)`**. The same target has a shallow teacher of width `O(r²)`, all weights bounded by one, and output margin one. Its ordinary Boolean circuit size is `O(r)`.

The model uses the full Boolean cube, a constant input coordinate, a linear readout, and the unchanged isotropic Gaussian prior within each layer. At width `N` and input dimension `d`, the energy is

$$
K_N=\frac dN\sum_j(b_j^2+\lVert w_j\rVert_2^2)+N\sum_jv_j^2.
$$

Under the global margin requirement `χ(x)z(x) ≥ 1/2`, its exact minimum over all widths is

$$
E_* = \frac{\sqrt d}{\rho_r},\qquad
\rho_r=\frac{\binom{r-2}{(r-2)/2}}{2^{r-1}\sqrt r}.
$$

At every smaller width where the target is realizable, the minimum energy is strictly larger. For degree two the exact attainment threshold is four neurons.

The proof determines the sharp correlation of a single ReLU neuron with parity. Equality forces equal-magnitude relevant weights, zero bias, and zero irrelevant weights. Fourier coefficients then force positive mass on every antipodal pair of neuron orientations, giving the exponential width lower bound and a matching construction.

**Scope:** this is an exact energy and representation-width theorem. It is not an exponential sample-complexity or online-mistake lower bound, and it does not prove an exponential width requirement for approximating the optimal energy.

The paper has conventional proofs checked independently by AI agents. It has not been formalized in Lean. Authors are listed alphabetically: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.

To rebuild, run `bash build.sh` from this directory. The script requires `pdflatex` and writes `paper.pdf`.
