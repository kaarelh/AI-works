# Independent mathematical review

Reviewed by a separate AI agent, 21 October 2026 (client date; execution date 22 October UTC).

I read the complete `paper.tex` and independently checked:

- the exact NAND overwrite construction, including the empty circuit, its gate count, and injectivity across descriptions of different lengths;
- the geometric gate-count prior's normalization, posterior tail cutoff, injective mass comparison, and predictive-probability lower bound;
- the conversion between conditional sampling mistakes and log loss, monotonicity of the function used to lower-bound mistakes, and constants in the explicit inversion;
- the prefix language's prefix-freeness, Kraft bound, uniform overwrite probability ratio, exponential length tail, and compilation bound;
- the predictable adaptive query convention, complete-revelation requirement, and the infinite-IID argument;
- the distinction between actual minimum-circuit mistakes and expected posterior-sampling mistakes, and the stated absence of a Bayesian-majority converse.

No mathematical correction was needed. In particular, the converse concerns total NAND gate count with unrestricted depth. It does not imply a converse for fixed-depth, fixed-width Gaussian neural-network priors.

This is a human-readable AI-agent audit, not a Lean verification. The paper's model-name/date metadata should be brought into agreement with the publication's chosen author attribution separately from the mathematical review.

Audited source SHA-256: `32de39074eb2c26e682a21a10f4cfd43b43a8e371e59c8ca9972f97955aa1cf3`.
