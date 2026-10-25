# Root audit of the projective-coordinate symmetry bound

25 October 2026. Independent algebraic check of the scratch finite-width
symmetry theorem and its proposed multiple-column extension. PASS, with
the scope and conventions below. This is not a Lean formalization.

For a training-constant coordinate x_j=s, the signed augmented-coordinate
swap A satisfies A(1,x)=s x_j(1,T x), where T fixes x_j and multiplies
all other input coordinates by s x_j. T is a cube bijection. Oddness of
the full network, invariance of the first-layer columns, and invariance
of the absolute-margin event give exact posterior symmetry. On x_j=-s,
p(Tx)=1-p(x); at most half of this half-cube can have p>c for any
c>1/2. Thus the 1/4 confidence-failure bound holds for all such thresholds,
and for the actual finite-width posterior, including mixtures.

For n>=1 uniform iid examples, a given coordinate column is constant with
probability 2^(1-n), independently across coordinates. The asserted event
probability and the necessary n>=log_2 d-O_delta(1) sample bound follow.
The argument allows repeats; it does not rely on sampling without replacement.

For the proposed strengthening, flip the k constant columns so their observed
values are +1. Permutations of those columns and the augmented constant
coordinate preserve all training events. Let r be the number of negatives
among the k columns, and y the remaining input coordinates. The posterior
vote is a common p_r(y) on each Hamming layer. For 1<=r<=k, moving a negative
coordinate into the augmented position and then reversing the full input
gives

    p_r(y) + p_(k+1-r)(-y) = 1.

The two Hamming layers have masses b_r=2^(-k) binom(k,r) and
b_(k+1-r)=b_(r-1). Their paired failure contribution is at least the smaller
mass. Counting each pair twice, including any self-paired middle layer,
therefore gives

    failure >= (1/2) sum_(r=1)^k min(b_r,b_(r-1))
            = (1-max_r b_r)/2.

The last identity follows by unimodality of the binomial coefficients.
At k=0 this expression is zero. The same proof applies to any confidence
threshold c>1/2. The possible self-paired middle layer can sometimes force
more errors, but does not invalidate this lower bound.

Since k is Binomial(d,2^(1-n)), for n<=(1-eta)log_2 d with fixed eta>0,
Chernoff gives k>=d^eta with probability 1-exp(-Omega(d^eta)), up to
irrelevant integer endpoints. The central-binomial bound then gives
failure >=1/2-O(d^(-eta/2)). This is logarithmic sample hardness in input
dimension, not exponential hardness in depth when d is polynomial in depth.

No corresponding lower bound for sign-of-posterior-mean prediction follows:
complementary votes can both be arbitrarily close to 1/2, and the confidence
criterion matters. For the ordinary majority label one does get at least
one error per paired point unless ties are resolved in a special favorable
way; a tie convention would have to be specified before asserting that
version. The confidence theorem needs no such convention.
