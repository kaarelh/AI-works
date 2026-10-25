# A Wasserstein lower bound for local group-product networks

**[Read the paper](paper.pdf)** · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

Research proof draft, 25 October 2026. This paper proves an **architecture lower bound** for neural networks computing a Boolean predicate of a finite-group word. It is neither a lower bound on a function's minimum product norm over unrestricted networks nor a Bayesian sample lower bound.

The network's physical layers must merge contiguous subwords through successive local modules. Different modules have disjoint data-dependent channels until their prescribed merge. Each band contains at least one actual matrix layer, and the bands partition all pre-readout layers. Boundary states may retain the entire subword, have arbitrary dimension and precision, and contain arbitrary fixed-seed estimator features. No internal margin, state decoder, or product-only encoding is assumed.

For successive partitions with normalized block sizes `mu`, the theorem bounds the product of all physical Frobenius norms by

`P_F >= [2 sqrt(p(1-p))/A_0] exp[(1/2) sum_bands H(mu)]`,

where `p` is the fraction of negative group products and `A_0` is the geometric mean of the input encoding's root-mean-square variation. The proof couples the conditional laws of arbitrary boundary states and then applies weighted AM--GM across actual matrix layers.

- With maximum merge arity `b`, including unbalanced hierarchies, the accumulated entropy gives `P_F >= const · exp[(log n)^2/(4 log b)+(log n)/4]`.
- Polynomial product requires a block containing at least `n^(1-epsilon)` letters to appear within `O((K+1)/epsilon)` charged bands when `P_F <= C_0 n^K`.
- Six-bit encodings of `A_5`, with a negative label exactly on three-cycles, give the explicit leading constant `2/(3 sqrt(3))`.

**Parity shows why the architecture restriction matters.** The same lower bound applies to local parity trees. The paper also constructs a global one-hidden-layer tanh parity network of product `O(n^2 log(n+1))`, using thresholds of the sum of all input bits. Thus the theorem obstructs a local compilation method while leaving nonlocal representations available. It does not resolve the original polynomial-versus-exponential depth question for the canonical tanh posterior.

The [complete manuscript audit](verification/local-group-wasserstein-full-assembly-audit.md) checks the coupling, physical-layer charging, entropy telescope, unbalanced arity bound, early-large-block consequence, explicit `A_5` constant, and parity construction. The [derivation note](research-notes/group-local-code-rms-obstruction.md) preserves the working proof. The manuscript is self-contained and does not require that note. **No theorem in this package is Lean verified.**

Run `./build.sh` to rebuild. The script places auxiliary files in `.build/` and copies the result to `paper.pdf`. Exact artifact hashes and the audit scope are recorded in the [build manifest](verification/build-manifest.json).
