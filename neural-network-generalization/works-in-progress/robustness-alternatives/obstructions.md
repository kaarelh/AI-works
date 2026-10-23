# Exact ReLU obstructions to simple stability substitutes

Independent mathematical note, 22 October 2026. These are capacity and parameter-stability statements. **They are not lower bounds for the posterior of the independent Gaussian neural-network prior on simple targets.**

## 1. A constant spectral cap greater than one still permits every truth table

Fix any constant `c > 1`. For every `d >= 1`, every Boolean truth table on `{-1,1}^d` has a ReLU realization with:

- width `N = 2 d 2^d + 1`;
- depth `L = O_c(d)`;
- exact outputs `f(x)` at all Boolean vertices;
- global Euclidean input Lipschitz constant at most `sqrt(d)`;
- weighted Gaussian energy at most `c^2 (3d + 2L)`;
- every internal matrix operator norm at most `c`;
- normalized first-layer operator norm `sqrt(d/N) ||W1||op <= c` and normalized readout norm `sqrt(N) ||v|| <= c`.

Consequently, polynomial input robustness, linear-in-depth energy, and an arbitrarily small fixed expansion allowance `c > 1` do not give a width-uniform capacity bound polynomial jointly in depth and dimension. The class still contains all `2^(2^d)` truth tables.

### Base network

Put `M = 2^d`. For each Boolean vertex `p`, define

`t_p(x) = ReLU(1 - sum_i |x_i - p_i|)`.

The open supports of different `t_p` are disjoint, since different Boolean vertices have l1 distance at least 2. Thus

`F(x) = sum_p f(p) t_p(x)`

equals `f` on the cube. It is globally `sqrt(d)`-Lipschitz: on every differentiable affine cell its gradient is either zero or the gradient of one signed tent, of Euclidean norm at most `sqrt(d)`. Integrating along segments gives the global bound. In particular, radius `1/(4 sqrt(d))` input perturbations around any Boolean vertex retain signed output at least `3/4`.

Implement this without separate internal biases:

1. Hidden layer 1 has, for every `(p,i)`, the two units `ReLU(x_i-p_i)` and `ReLU(p_i-x_i)`, together with one constant-one unit. Its squared Frobenius norm is `4dM+1`, and its rank is at most `d+1`.
2. Hidden layer 2 has the `M` tents and one copied constant-one unit. Each tent uses the `2d` appropriate absolute-value units with coefficient `-1` and the constant with coefficient `1`. Its squared Frobenius norm is `M(2d+1)+1`. Its operator norm squared is at least `M+1`, from its constant input column. Its stable rank is therefore at most `2d+1`.
3. Hidden layer 3 computes `ReLU(F)` and `ReLU(-F)`. Its two rows are opposite vectors supported on the tent coordinates, so its squared Frobenius norm and squared operator norm both equal `2M`; its stable rank is one.
4. Every further hidden layer copies these two nonnegative channels using a two-coordinate identity matrix. Its squared operator norm is one and its squared Frobenius norm is two.
5. The readout subtracts the two channels. Its squared norm is two.

All layers are padded with zero neurons to width `N`. This realizes `F` for any depth `L >= 4`.

### Rescaling and energy

Let the normalized layer matrices be

`A1 = sqrt(d/N) W1`, `As = Ws` internally, and `AL = sqrt(N) v^T`.

Write `a_s = ||A_s||op`, and put

`G = (product_s a_s^2)^(1/L)`.

Multiplying parameter layer `s` by `sqrt(G)/a_s` preserves the real output exactly: the product of these positive scale factors is one, and ReLU is positively homogeneous. Every new normalized operator norm is `sqrt(G)`, and stable ranks are unchanged. Its weighted energy is therefore

`kappa = G sum_s stable_rank(A_s) <= G (3d + 2L)`.

The two identity channels have operator norm one, so adding depth does not increase the operator-norm product. The preceding base bounds give

`product_s a_s^2 = d product_s ||Ws||op^2 <= 80 d^3 M^3`.

Choose

`L >= max(4, ceil(log(80 d^3 2^(3d)) / (2 log c)))`.

Then `G <= c^2`, proving all claimed bounds. The output remains the same globally Lipschitz `F`.

### Scope

The width here is exponential. Most truth tables have exponential circuit complexity. This proves failure of the proposed class-capacity implication; it does not show that Gaussian NNBayes assigns enough posterior mass to these functions to make a small-circuit target hard.

The strict threshold `c > 1` matters. This argument does not refute a genuinely nonexpansive hidden stack or a depth-dependent cap whose accumulated expansion is polynomial.

## 2. An unnormalized first-layer cap conflicts with arbitrary learner widths

For ReLU, suppose every ordinary hidden operator norm, including `||W1||op`, is at most `c`, and `E_v = N ||v||^2 <= B`. Then every Boolean input satisfies

`|z(x)| <= sqrt(B/N) c^(L-1) sqrt(d+1)`.

Thus a margin-`1/2` network is impossible whenever

`N > 4 B c^(2L-2) (d+1)`.

This is a direct obstruction to an unnormalized all-layer spectral cap in a theorem requiring every learner width at a fixed target depth and a width-independent polynomial readout-energy budget. The first layer must instead be normalized by `sqrt(N)` (as in the original Gaussian model), or a different width-dependent resource must be allowed.

At the one special lookup width above, all ordinary operator norms can also be capped by `c`, with `E_v=1`, by using a larger `L=O_c(d)`: set the first ordinary norm to `c`, the readout norm to `1/sqrt(N)`, and equalize the internal norms. The needed internal product is at most a fixed exponential in `d`, so linear depth suffices. This special-width observation does not evade the arbitrary-width obstruction just proved.

For a globally `lambda`-Lipschitz activation vanishing at zero, the same arbitrary-width obstruction holds with the factor `c^(L-1)` replaced by `(lambda c)^(L-1)`.

### Strict contraction has the opposite cost

For ReLU, suppose all internal operator norms are at most a fixed `a<1`. Write `E1=(d/N)||W1||F^2` and `Ev=N||v||^2`. Then

`|z(x)| <= sqrt(E1 Ev) sqrt((d+1)/d) a^(L-2)`.

A margin of `1/2` therefore requires

`E1 Ev >= [d/(4(d+1))] a^(-2(L-2))`.

Thus a fixed strict contraction cap rules out polynomial-energy margin implementations at unrestricted depth, even before asking about circuit expressivity.

It also has a quantitative mean-field Gaussian cost. For an internal matrix with independent `N(0,1/N)` entries, `||W||F^2=(1/N) chi-square_(N^2)`. The cap implies `||W||F^2<=N a^2`. The elementary lower chi-square tail gives

`P{||W||op<=a} <= exp[-N^2 (a^2-1-log(a^2))/2]`.

This cannot supply an `exp[-N poly(d,L,C)]` raw target cylinder when target resources are fixed and width grows. A learning proof for a prior conditioned on such a rare cap would need a different comparison within that conditioned law. The exact threshold `a=1` is not covered by this elementary lower-tail argument.

### A useful sufficient condition is a suffix-transfer budget

For a globally `lambda`-Lipschitz activation, define

`S = max_(1<=s<=H) product_(j=s+1)^H [lambda ||Wj||op]`,

including the empty product one. Global Lipschitz continuity bounds the output change under total normalized postactivation/readout disturbance `r` by

`sqrt(1 + H Ev S^2) r`.

Thus a polynomial `S` is a direct, verifiable sufficient condition for finite-radius internal robustness. This uses global operator bounds, so it controls the whole disturbance tube, not just the Jacobian at clean inputs. A residual stack with `lambda=1` and `sum_s Lip(F_s)<=B` for updates `h<-h+F_s(h)` has `S<=exp(B)`. Taking `B=O(log(poly(resources)))` gives polynomial stability. Whether every desired Boolean circuit has an economical realization under that particular transfer budget remains a separate expressivity question.

## 3. Path variation and almost-identity layers do not imply internal robustness

There is a particularly simple ReLU example for the constant target, at every width. Set `d=1`, `L=2m+2`, and let every first-layer neuron equal the constant one. For the next `m` hidden layers use the rank-one matrix whose every entry is `exp(-1/sqrt(m))/N`; for the following `m` layers use the matrix whose every entry is `exp(+1/sqrt(m))/N`. Read out the average of the final channels.

The output is exactly one. The weighted energy is

`kappa = L + 2m [cosh(2/sqrt(m)) - 1] <= L + 6`.

The inequality follows by expanding cosh: each term of `m^(1-k)` is at most one for integer `k>=1`, so the excess is at most `2(cosh 2 - 1) < 6`.

Every internal operator norm is at most `exp(1/sqrt(m))`, which tends to one. The sum of squared scalar residual gains `sum_s (a_s-1)^2` is bounded by a universal constant. At width one these are genuine residual blocks `I + Delta_s`, with `sum_s ||Delta_s||op^2` bounded. At larger widths the cloned matrices are near the identity only on the population-constant subspace, so the full-space residual claim must not be transferred to them. The absolute input-to-output path variation is exactly one: all coefficients are positive and the products of the contraction and expansion gains cancel.

Nevertheless, at the middle layer every hidden coordinate equals `exp(-sqrt(m))`. Subtracting that number from each coordinate erases the state. Its RMS-normalized size is exactly `exp(-sqrt(m))`, and the output then becomes zero.

Therefore none of the following alone implies inverse-polynomial internal-noise robustness of every parameter representative:

- near-minimal total energy with a constant additive allowance;
- constant absolute path variation;
- layers approaching the identity at rate `O(1/sqrt(L))`, already at width one;
- a bounded sum of squared residual operator norms, already at width one.

The same constant function has a stable representation with every scalar gain equal to one. The example concerns a parameter property, not intrinsic function difficulty, and gives no Gaussian posterior lower bound. A total variation bound on residual Lipschitz constants, an actual bound on suffix transfer gains, or finite-radius internal robustness is substantially stronger.

## 4. Restoring gates provide a natural robust ReLU/GELU Boolean witness

This is a constructive positive observation, with a separate probabilistic caveat.

Represent each logical signal by a pair whose difference is the decoded bit. For a decoded positive constant `c`, use the following ReLU pairs:

- NOR: `ReLU(1.5c-2a-2b)`, `ReLU(.5c-2a-2b)`.
- COPY: `ReLU(2a-.5c)`, `ReLU(2a-1.5c)`.
- NOT: the NOR pair with `b=0`.
- Constant: `ReLU(1.5c)`, `ReLU(.5c)`.

NOR's decoded difference is exactly `c` when `a+b<c/4`, and exactly zero when `a+b>3c/4`. COPY has analogous thresholds `a<c/4` and `a>3c/4`. Thus errors in ordinary bit signals are restored locally; they do not multiply with depth. The constant signal is copied, so only perturbations of the constant wire accumulate.

For width-`C` logical circuits, this uses `2C` physical neurons at the same depth. Internal individual weights are at most 4, including repeated inputs. The weighted energy is `O(d+LC)`, and balanced cloning preserves that bound up to universal constants.

If `r_s = ||eta_s||_2/sqrt(N)` is the postactivation disturbance at layer `s`, balanced cloning into `N>=2C` gives a decoded pair-noise bound `sqrt(8C) r_s`: each population has size at least `N/(4C)`, and Cauchy–Schwarz bounds the difference of its two population averages. Constant drift is therefore at most `sqrt(8CH) (sum_s r_s^2)^(1/2)`. Each other bit's error relative to the current constant is just the current pair error minus a possible current constant-pair error. A sufficiently small universal total-noise radius of order `1/sqrt(CH)` keeps all decoded bits in the restoring regions and preserves the final sign, uniformly over Boolean inputs. Include a constant upper cap on the radius if scalar readout noise is part of the disturbance norm.

For GELU, use the decoded gate

`[GELU(k u1) - GELU(k u2)]/k`

with one sufficiently large universal constant `k`. Since `sup_u |GELU(u)-ReLU(u)| <= 1/2`, the decoded gate differs from its ReLU counterpart by at most `1/k`. Use the constant pair `GELU(kc), GELU(-kc)`: its decoded difference is exactly `c`, by the identity `GELU(u)-GELU(-u)=u`. Fixed gate approximation errors are restored locally and do not accumulate with depth. A fixed invariant interval proves robustness for, e.g., any sufficiently large `k>=256` and a sufficiently small universal noise factor.

Internal physical weights remain `O(1)`, since the incoming gain `k` cancels the preceding decoder `1/k`. First-layer weights are `O(k)` and readout weights `O(1/k)`, so the energy remains `O(d+LC)` with universal constants. The hidden-noise radius scales as `k/sqrt(CH)`, capped by a constant for scalar readout noise. This matches a readout/depth reference radius of order `1/sqrt(1+H E_v)` up to universal factors, since `E_v` is of order `C/k^2` for the compiled final readout. Clean output need not be exactly `+/-1` for GELU; a uniform strict margin is sufficient.

**What this establishes:** cheap finite-radius internally robust Boolean implementations, at the same depth and with constant-factor width overhead, plus open positive-Gaussian-mass neighborhoods at each fixed width.

**What this construction alone does not establish:** the quantitative prior mass and capacity estimates needed for a learning theorem. The [companion note](internal-noise.md) supplies these estimates for the strong-prior limit and every `gamma>=2`. The mean-field/intermediate case remains open: the free Gaussian bulk annihilates clean cloned states but can act on non-population components of adversarially perturbed states. Controlling that effect requires a new quantitative argument. At those scales, merely putting all `N^2` entries in a tiny ball establishes positive mass but does not supply the needed width-independent rate.
