# Independent audit of the supercritical intrinsic crossover

26 October 2026. **PASS for the intrinsic theorem and its explicitly conditional target consequence.** Source: `nearcritical-supercritical-positive-gain.md` SHA256 `7dfcd00f9f7ba79ae9e8cf56120fd1d742bb48eae2da8bd02858bc64fa6d59d4`. The finite-width certificate and normalized importance-compression theorems are imported analytic inputs, checked here for their compact-prefactor extension.

## Scalar comparison and bootstrap

The exact identity is `d1=d_t-log t+(1-t^-2)M/2`, equivalently the note's equation (3). Gaussian entropy duality bounds the physical second moment by `M<=t²R(D)`. On a fixed compact interval above one, `R(D)-1<=C(sqrt(D)+D)` therefore gives the claimed nonnegative overcost `e_j=(1+C delta)D_j+C delta sqrt(D_j)+C delta²` dominating both the full row entropy and the scalar critical-reference entropy.

The terminal critical readout cost is `r1=t²r_t>=1/(8q_H)`. Thus the scalar sequence with these dominating costs satisfies the same Bellman and dissipation inequalities used in the critical occupation theorem. The resulting total overcost is `V_*+O(epsilon+delta(1+epsilon)+delta Z+H delta²)` with `Z=sum sqrt(D_j)`.

The self-consistent occupation bound closes as stated: `H delta(1+epsilon)` is at most a constant times `[log(H+2)+sqrt(H epsilon)+H delta]²`, and `sqrt(H delta Z)` is absorbed by Young's inequality. This proves the sum-square-root and gain bounds without assuming the desired estimate in advance. The inequality `log R(D)<=2sqrt(D)` follows directly from `e^u-1-u>=u²/2`.

## Actual finite-width intrinsic transfer

I compared Section 2 against the published `uniform-sharp-intrinsic.md`. Its representation and finite-event portions use the exact layer gain `t sqrt(R(D_j))`, the scale-normalized readout norm, and arbitrary Gaussian reference covariances. The references to `Ht²<=H` and bounded t in that proof become `Ht²<=C H` and constant-factor changes on the compact interval considered here. The logarithm of the required covariance-moment accuracy remains polynomial in H and the normalized action, so no additional exponential width factor is introduced. The part genuinely specific to subcritical scaling was its baseline gain lemma; the note replaces that lemma rather than reusing its sign-dependent formula.

The vanishing readout repair has action slack O(1/H), so applying the new gain estimate gives the displayed `exp(C[sqrt(H E)+delta H])` intrinsic sample factor. The large-width certificate still divides by actual target mass, and the small-width VC completion remains valid. The confidence statement is converted through Gibbs error, as required for posterior mixtures.

## Scope

No target-mass estimate above the canonical prefactor is proved in this note. Its final target-class statement is conditional on equation (8). In particular, the subcritical residual-monotonicity argument cannot be reused unchanged for t>1, and the stronger regime `delta²H=O(S)` does not follow. These limitations are explicit and correct. The intrinsic result is adjacent to the canonical problem and does not resolve the unrestricted exact-tanh depth question.
