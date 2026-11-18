# Independent compiler-resource review

Reviewed by the robust-prior research agent on 18 November 2026. No substantive gap found.

Checked the exact scalar-interface substitutions in `compiler-resources.tex` against `model-and-compilers.tex`. The continuous four-layer formula count is at most 34 T before padding and O(H T) afterward. The stable-padding interface therefore yields O(H T log(n kappa H T)) comparison entropy. The conservative Boolean exponent a=2b(b+1) dominates the complete unrolling exponent.

The sharp expected oracle uses the same fixed architecture, prior and likelihood at sample sizes n and n+1. The comparison precision affects only the proof. Taking the infimum over deterministic teachers is valid. For the displayed growing classes, the resource and compiled width are Otilde(n^(1/4)); every N>=n eventually contains the comparison, and the remainder is O(n^(-1/2)). No sample splitting or temperature selection is used.

This is an independent mathematical review, not a Lean verification. Exact source hashes are recorded alongside this file.
