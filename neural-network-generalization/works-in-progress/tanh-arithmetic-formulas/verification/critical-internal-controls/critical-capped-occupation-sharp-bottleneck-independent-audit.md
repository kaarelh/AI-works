# Independent audit: capped critical occupation and sharp bottleneck

26 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at source SHA256 `1953b4f3ac2f962d2d86ca444d0c3fc381eecf5d3800771c2d23e692c41e5890`.

The maximum-variance drift is the previously audited arbitrary-entropy estimate. Suffix comparison at the last hidden state q_j<=2u bounds the entire entropy prefix by epsilon+C u, regardless of how often the path previously visited or left that band.

For g_u(q)=min(q,2u), its increment is at most the ordinary variance increment when q<=2u and is nonpositive otherwise. The displayed drift with indicator therefore holds on every transition. Summing through the last low state bounds the cumulative sum of low pre-state squares by C(u+epsilon), since the total possible decrease of the capped potential is at most 2u. The band [u,2u] then has at most C/u+C epsilon/u^2 counted visits. After that prefix only its departing pre-state can contribute; if there is no low hidden state, only the initial pre-state can contribute. No monotonicity assumption is used.

Summing half-open dyadic bands starting at the positive global minimum gives the asserted C/p+C epsilon/p^2 bound; the added one per band is absorbed by C/p. The fixed high-variance region contains only O(1) states by the total quadratic occupation estimate. Solving H p^2<=C p+C epsilon gives p<=C/H+C sqrt(epsilon/H). Restricting the last-low stopping index to any initial block gives the same bound there because the full hard-margin continuation still supplies the suffix lower bound.

The consequences for an excess epsilon=O(S_f^2/H), and for the first-aligned-crossing parameter E, follow directly. The proof is variational and allows arbitrary finite-entropy row controls. It proves neither a scalar-feature compiler nor a finite-width posterior learning bound.
