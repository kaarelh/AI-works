# Target-mass, polynomial-budget, and quantifier review

Date: 23 October 2026 (publication timezone). This is an AI-agent mathematical review of the written manuscript, not Lean verification or human peer review. The reviewer checked the actual displayed formulas and proof, rather than only the earlier construction outline.

**Finding:** no mathematical defect found in the target-mass lemma, the degree-13 envelope, or the simultaneous all-width/all-scale conclusion as written. The theorem changes the prior by the stated balanced-averaging support restriction and assumes an actual same-activation teacher; these restrictions are essential to its scope.

## Target cylinder

- The teacher readout is nonzero because of the signed-margin premise. The replacement `v' = 4 max(1,1/‖v‖) v` has norm `4 max(1,‖v‖)`, between `4` and `4B√C`, and multiplies the signed output by at least four. No inverse-small-readout cost remains in the final coefficient norm.
- Balanced cloning uses all `N` neurons, including when `N` is not divisible by `C`. The inequalities `C/2 ≤ N/k_a ≤ 2C` and `k_b/k_a ≤ 2` justify the internal squared Frobenius bound `2C²B²` and readout energy interval `[8C,32C²B²]`. Cloning preserves the exact computation for any activation; zero-at-zero and homogeneity are unnecessary.
- The bound `|φ(u)| ≤ b+λ|u|` gives `m_s ≤ R_*^s`. The internal operator bound, normalized readout bound `V`, and hidden bound `M` therefore hold for the actual cloned teacher, with arbitrary real weights satisfying the given coefficient bound.
- There are exactly `N[d+2+(H−1)C]` constrained Gaussian coordinates. The first-layer squared centers contribute at most `Nd(d+1)B²`; the internal centers contribute at most `2N(H−1)C²B²`; the readout centers contribute at most `32NC²B²`. Their sum is the printed `NB_0`.
- The row coordinates in the clone span and its orthogonal complement are independent under the isotropic Gaussian law. Thus the free bulk operator event remains independent after imposing every cylinder interval. The standard Gaussian matrix bound gives failure at most `1/(2H)` per internal layer with the displayed `g_H`; the joint success probability is at least one half. There are no such layers at `H=1`.
- The perturbation recurrence gives `e_H ≤ ρE`. Its constant source term includes the full teacher magnitude `M`, so it does not incorrectly assume bounded hidden activations. The same recurrence applies to the merged network: left population averaging contracts errors, preserves the clone centers, and removes the free bulk because its right projection is zero. Consequently both outputs differ from the amplified teacher by at most `1/8`, giving signed values greater than `15/8` everywhere and identical clipped values.
- The readout interval bounds imply `√E_v(w) ≥ √(8C)−ρ ≥ √(2C)`, since `ρ≤1/8`. The selected `q=C` balanced partitions therefore satisfy `q≤1+E_v(w)`. No assumption that the original unmodified teacher satisfied the support condition is used.
- The scalar Gaussian interval bound includes the factor `e` correctly: `(a+ρt)²/(2t²) ≤ a²/t²+ρ²`, and `ρ²≤1`. Multiplication of all intervals and the independent bulk probability gives the printed rate `D_*`, using `t≤1` and `N/t²≥1`. The event also lies in the optional global-margin restriction and fits every noiseless sample, so all subsequent normalization denominators have the claimed positive lower bound.

## Actual finite Gaussian scales and posterior truncation

The prior variances in the manuscript are used literally. For fixed balanced partitions, the compressed coordinates have the three printed variances, are independent across blocks, and have energy-coordinate variances at most `2t²/N`. Hence the exponential moment at `N/(8t²)` is bounded by `2^(P_q/2)`. The count `q^(HN)` is an upper bound on ordered balanced partition tuples, and `P_q/N ≤ d+2+(H−1)q` uses `q≤N`.

The readout identity `N E_v/t² ~ χ²_N` is correct. The displayed `B_r` budget makes its posterior tail at most `ε/4`. For the partition tail, the factor `Q` is paid by the extra `log Q` in `(H+1) log Q`, since `N/t²≥1`; the remaining dimension and partition-count factors are also absorbed by the printed `J/8`. Dividing by the target-mass lower bound gives the second `ε/4`. These arguments use no width limit, no lower bound on `t`, and no sample-dependent witness union bound.

## Degree-13 envelope and common event

Let `S_0` be the theorem's resource sum. The following chain is valid with universal constants:

```text
log(1/ρ) = O(H log S_0),     D_* = O(S_0^5),
Q = O(S_0^5),               J = O(S_0^6),
R = O(S_0^6),               A_g = O(S_0^12),
P_Q = O(S_0^11),            log(3+4R/ζ) = O(S_0^2).
```

For example, `B_0 = O(S_0^5)` and `q_0 = O(S_0^2)`, while only `log(1/ρ)` enters `D_*`; exponential hidden magnitudes are never inserted directly into the sample budget. The product of the last two bounds gives the advertised degree 13. The coefficient and exponent are universal over the stated activation bounds, not fixed only after choosing the activation or depth.

The fixed grid uses the chosen activation, teacher resources and accuracy, but no learner width, Gaussian scale or optional-margin switch. Padding is valid for nonzero activation offsets because every outgoing edge and the readout coefficient of each dummy neuron are zero, and rounding preserves zero. The rounded-network output error bound `1/32` plus merging discrepancy `1/16` gives the stated `3/32`. Training fits put the grid score at least `13/32`; every original test-margin failure puts it at most `11/32`. Thus the finite-class event used in the final union bound is valid and controls every retained network simultaneously. Adding the truncated posterior mass proves all-width/all-scale simultaneity without a union over the continuum of scales.

The common sample event is for a fixed activation and target; uniform polynomial constants do not assert that an activation can be selected using the same data. This distinction, the optional global-margin convention, and the restriction to Boolean labels with a real-valued implementing teacher are explicitly stated in the manuscript.
