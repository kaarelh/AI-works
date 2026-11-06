# Independent audit: online I-projection bound without global support

Audited source:
`../numerics/meanfield-online-without-global-support.md`, read 2026-11-06.

Verdict: the theorem and proof are valid as a changed-learner result at
fixed positive mean-field prefactor tau. They do not establish a result
for the original globally conditioned prior or the fixed-width cold limit.

## Limit and normalization

The model has first weights of variance tau^2/d and physical readout
weights of variance tau^2/N^2. It is exactly the original canonical
relative normalization evaluated along `sigma_N=tau/sqrt(N)`, since

    N sigma_N^2/d = tau^2/d,
    sigma_N^2/N = tau^2/N^2.

It is useful to state this identity explicitly. The large-width limit
keeps tau fixed; it is neither a fixed-sigma width limit nor a
fixed-N sigma-to-zero limit. This scope clarification was requested from
the author and does not change the proof.

## Complete-output Cramer argument

The random neuron vector Z has unbounded coordinates because a is
Gaussian, but its moment-generating function is finite for every dual
vector. Conditioning on u integrates a exactly, and boundedness of tanh
gives the displayed global quadratic upper bound on Lambda.

The feature-span argument is correct. A finite family of sufficiently
steep tanh steps at distinct cube scores, together with a nonzero
constant tanh feature, gives an invertible feature matrix. Positive
Gaussian density and continuity then make G positive definite.

Jensen supplies the stated quadratic lower bound on Lambda. It ensures
that `theta.z-Lambda(theta)` is coercive in theta for every z. Lambda has
positive-definite Hessian under every finite exponential tilt because Z
is not supported on an affine hyperplane and the tilt has strictly
positive density. The Legendre maximizer therefore exists uniquely for
every z, satisfies `grad Lambda(theta_z)=z`, and gives a smooth strictly
convex finite rate I. The upper bound on Lambda gives the claimed
coercivity of I. No local-only claim about the range of grad Lambda is
being used.

Cramer's full finite-dimensional LDP applies. Although an empirical mean
at small widths can have restricted support, the LDP lower bound on the
nonempty strict feasible set guarantees positive conditioning probability
at all sufficiently large widths. The strict teacher point makes the
strict-set infimum equal to the unique closed-set minimum. Coercivity and
uniqueness give a positive rate gap outside every neighborhood. Hence the
entire conditioned output vector converges in probability, exponentially
fast, to its unique minimizer z_S.

The exponential tilt rho_z exists, has finite moments and mean z, and
satisfies the entropy identity used in the note. Finite KL relative to
rho_0 already implies finite a^2 moment by the displayed entropy bound,
so the identity has the required integrability for any competing finite-
KL neuron law.

## Successive projection bound and constants

The feasible sets C_S are closed convex half-space intersections. Their
first-order optimality inequality has the correct sign. The Bregman
identity for the exponential family consequently gives

    I(z_(S'))-I(z_S) >= KL(rho_(S') || rho_S).

The potential starts at zero and is at most K_T throughout.

The entropy estimate is exact with `c0=(log 2)/2`:

    E a^2 <= 4 tau^2 (K_T+c0).

For unnormalized squared Hellinger distance, Cauchy--Schwarz gives the
factor two in the observable-difference bound, and this Hellinger
distance is at most the indicated directed KL. Combining the two second
moments gives the denominator `16 tau^2(K_T+c0)`, so the displayed R_h,
R_0 and R_(1/4) constants are correct. Points exactly at the limiting
test threshold h are properly counted as bad, ensuring the same strictly
positive potential increment.

## Finite-width confidence, uniformity, and sampling

For fixed dimension and target, there are finitely many target-consistent
histories and next-input pairs. At every pair whose limiting signed mean
is strictly greater than h, the actual posterior correctness probability
tends to one. Taking the maximum of finitely many width thresholds makes
the statement simultaneous over all such pairs. This proves the claimed
all-orders finite-width confidence bound, including the strict 2/3
confidence convention. It does not provide a useful quantitative width
threshold, and none is claimed.

For sampling, make the conditional wrong-sign probability at every
limiting-good pair less than eta/2^d. Along any adaptive order of distinct
inputs, conditional union bounds give probability at least 1-eta of no
errors at these pairs. The pathwise projection argument bounds the number
of remaining pairs by floor(R_0). The same split gives expected count at
most R_0+eta. Fresh posterior sampling is sufficient; unconditional
independence of successive errors is not required. Previously observed
inputs have zero error probability because their positive training margin
is already imposed. Thus repetitions do not create an unbounded horizon
problem.

## Polynomial teacher certificate

The proposed Gaussian mixture has exactly the claimed mean output, since
u and a are independent in each component. Doubling the teacher output
and using `s<=1/(8CB sqrt(D))` makes its signed mean exceed 3/4, uniformly
over the cube. The Gaussian KL mean terms and covariance term match the
formula. Convexity of KL under mixing gives the same upper bound without
a log C penalty. The resulting bound is polynomial in the displayed
parameters up to the explicit logarithm.

## Crucial limitation

Global absolute-margin conditioning replaces each C_S by a union of
orthants. Convex first-order projection optimality, and therefore the
energy/entropy increment argument, is then unavailable. The proof makes
no claim that it survives that change. Its rigorous conclusion is a
polynomial cumulative-mistake bound for the stated learner without
initial global support conditioning.
