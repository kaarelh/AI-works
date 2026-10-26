# A positive learning window above the critical tanh prefactor

[Paper (6 pages)](nearcritical-positive-window.pdf) · [LaTeX source](source/nearcritical-positive-window.tex) · [Verification](verification/README.md)

**Authors:** ChatGPT-6 Astra, Kaarel Hänni, Dmitry Vaintrob. 26 October 2026.

For the original Boolean tanh network, keep the independent Gaussian variances `t²/d`, `t²/N`, and `t²/N²`, the all-cube output-margin conditioning, and exact sample labels. Write `H` for hidden depth, `t=1+δ`, `AF(f)=Σ|f̂(T)|`, and `S=1+log((d+H+2)AF(f))`.

For a sufficiently small universal upper bound on `δ`, and `H≥CS`, the actual posterior at **every finite realizable width** has sufficient sample complexity `exp(C(S+δH))` times polynomial statistical factors. Thus targets with polynomial Fourier variation—including every parity—retain polynomial sample bounds when `δH=O(log(d+H))`. The iid training and test distributions are the same and may be any distribution on the cube.

The proof has two new parts. A scalar change-of-reference bootstrap bounds the full entropy gain by `C(log H+√(H excess)+δH)`. A finite-width construction then gives raw globally correct target mass at least `exp(-N[V*+C(S+δH)²/H])` above width `exp(C(S+δH))`. It keeps the actual perpendicular Gaussian covariance `t²R`; an invariant residual bound replaces the critical monotonicity argument. Smaller realizable widths use the standard tanh parameter-count bound.

The scalar baseline `V*` is the unrestricted **critical** baseline. The result does not replace it with a Gaussian-restricted or supercritical value. The critical scalar occupation, Fourier seed, finite-channel concentration, and intrinsic finite-width compression are explicitly identified as imported results in the paper.

This is a positive window **above** the canonical range. It does not prove a polynomial bound for arbitrary deep bounded-weight Boolean tanh teachers at `t≤1`, nor a polynomial bound for fixed positive `δ`. It also does not prove the stronger `δ²H=O(log(d+H))` window. The separate quadratic Gaussian feature construction does not establish a posterior theorem.

## Scalar baseline sensitivity

A separate [proved scalar comparison](research-notes/supercritical-scalar-baseline-logarithmic-gap.md), with [independent audit](verification/supercritical-scalar-baseline-logarithmic-gap-canonical-audit.md), shows that the actual supercritical boundary value exists and obeys `V_t*≤V*−δ log(1/δ)+Cδ`. Thus its shift from the critical baseline is not merely `O(δ)`. This result is a scalar variational statement; it supplies neither a fixed-depth target witness nor a sharper posterior window. The six-page paper continues to use the critical baseline exactly as stated. No numerical experiment is needed for this comparison.

## Proof notes and dependencies

- [Intrinsic gain bootstrap](research-notes/nearcritical-supercritical-positive-gain.md).
- [Actual finite-width target mass](research-notes/nearcritical-positive-target-mass.md).
- [General critical seed/channel construction](research-notes/critical-analytic-target-mass.md), used here only for exact `tanh`; its separate engineered-activation lower bound is not claimed here.
- [Critical scalar occupation](../critical-depth/source/critical-square-root-entropy.tex), [short scalar paths](../critical-depth/source/critical-scalar-paths.tex), and [finite-channel proof](../critical-depth/source/critical-finite-width-channel.tex).
- [Uniform intrinsic theorem](../boolean-depth-barriers/proof-notes/uniform-sharp-intrinsic.md), [scale-sensitive compression](../boolean-depth-barriers/proof-notes/uniform-scale-intrinsic.md), and [finite-width certificate](../boolean-depth-barriers/proof-notes/finite-width-dual-certificate.md).

Run `./build.sh` with `pdflatex` installed. The source builds in two passes. The package includes independent mathematical audits and exact source/file hashes; no theorem here is Lean verified.
