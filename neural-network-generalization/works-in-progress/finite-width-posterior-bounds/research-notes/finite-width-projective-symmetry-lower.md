# An exact finite-width posterior lower from augmented-coordinate symmetry

25 October 2026. Scratch theorem. This is a logarithmic-dimension sample lower bound for the actual posterior, valid at every width and depth. It is not an exponential-depth lower bound and does not settle the unrestricted depth question.

## Model

The input is (1,x), x in {-1,+1}^d. All hidden activations are odd (in particular tanh), the readout is linear, and there are no additional internal biases. The first-layer prior is invariant under signed permutations of its d+1 input columns, as in the original isotropic Gaussian prior. Remaining layers can have any independent distribution. Condition on the absolute output margin at every cube point and then on exact sample labels, as in the original posterior. Let the target be the constant +1 function and use the uniform cube input law.

## Deterministic sample obstruction

Suppose a nonempty training sample S has a coordinate j whose observed values are all one common sign s in {-1,+1}. Then the posterior confidence-failure mass at threshold >2/3 is at least 1/4.

To prove this, let A be the signed coordinate permutation on augmented vectors which exchanges coordinates 0 and j and multiplies both exchanged coordinates by s. It preserves the first-layer Gaussian law. Define the involution T on the cube by

    (Tx)_j=x_j,
    (Tx)_k=s x_j x_k   (k != j).

Then

    A(1,x) = s x_j (1,Tx).

The network is odd as a function of its entire augmented input. Thus applying A to the first-layer columns transforms its output to

    z_A(x)=s x_j z(Tx).

Since T permutes the cube, the all-cube absolute-margin event is invariant. On every observed input x_j=s, we have T x=x and s x_j=1; hence every training-label event is also invariant. This conclusion actually holds for arbitrary observed labels.

The exact conditioned posterior is therefore invariant under z -> z_A. Write p(x) for its probability of output sign +1. On the half cube B={x:x_j=-s},

    p(Tx)=1-p(x).

The involution T preserves uniform measure on B. The sets {x in B:p(x)>2/3} and its T-image are disjoint. Hence at most half of B can be confident and correct for the constant +1 target. At least one quarter of the entire cube fails the strict confidence criterion. Fixed points of T, if any, force p(x)=1/2 and only strengthen the conclusion.

The argument uses the actual finite-width posterior, not a rate limit, one preferred function, or a selected basin. It applies to every width N, every weighted depth L, and every common Gaussian prefactor t>0 for which the posterior is defined. In particular it applies throughout the canonical 0<t<=1 range.

## Iid sampling consequence

For n>=1 uniform iid cube examples, the d coordinate columns of the sample matrix are independent. A specified column is constant with probability 2^(1-n). Therefore

    P_S{confidence-failure mass >=1/4}
       >= 1-[1-2^(1-n)]^d
       >= 1-exp[-d 2^(1-n)].

Consequently, achieving confidence-failure mass strictly below 1/4 with success probability at least 1-delta requires

    n >= 1+log_2[d/(-log(1-delta))],

up to the integer endpoint convention. This necessary condition follows from d 2^(1-n)<=-log(1-delta). For fixed delta in (0,1), this is n>=log_2 d-O_delta(1).

A constant target has a width-two bounded-weight realization at every depth: carry a positive scalar using weight two, starting from the constant input, and use readout weight two. Its activations stay above 1/2 after initialization. Thus the lower is compatible with constant teacher width and coefficient bounds. Zero padding realizes it at every eligible larger width.

The bound grows only logarithmically with d; if d is polynomial in L, it gives only Omega(log L), not exponential dependence on depth. It complements the finite-architecture VC upper, which rules out superpolynomial sample complexity whenever N is polynomial in d,C,L.

## Many constant columns: failure approaches one half

The obstruction strengthens when the sample has k constant coordinate columns. Flip these coordinates so every observed value is +1; this preserves the prior and uniform input law. The posterior is invariant under all permutations of the corresponding k augmented input coordinates together with coordinate 0.

Permutations among the k ordinary selected coordinates show that p(x) depends on those coordinates only through their number r of negative signs, together with the outside coordinates y. Write this probability as p_r(y), and put

    w_r=2^(-k) binom(k,r),   0<=r<=k.

For r>=1, exchange coordinate 0 with a selected negative coordinate and renormalize the augmented first coordinate to one. Oddness gives

    p_(k+1-r)(-y)=1-p_r(y).                                (1)

For distinct paired levels r and k+1-r, let a_r and a_(k+1-r) denote their fractions of outside y with p>2/3. Since y -> -y is measure preserving, (1) implies a_r+a_(k+1-r)<=1. Their total good mass is therefore at most max(w_r,w_(k+1-r)). At the middle level, when k is odd, (1) implies a_r<=1/2. If there are no outside coordinates, it instead forces p_r=1/2 and gives the stronger a_r=0. The unpaired r=0 level contributes at most w_0.

If k=2m, w_r>=w_(k+1-r)=w_(r-1) for 1<=r<=m. Thus the total good mass is at most sum_(r=0)^m w_r=1/2+w_m/2. If k=2m+1, the paired levels and the middle bound give at most sum_(r=0)^m w_r+w_(m+1)/2=1/2+w_m/2. Consequently, for every k>=0,

    confidence-failure mass
       >= 1/2 - 2^(-k-1) binom(k,floor(k/2)).                (2)

For k=0 the expression is zero, as it should be. For k=1 or 2 it is 1/4; as k grows it tends to 1/2 at rate O(k^(-1/2)). The proof works for every strict confidence threshold greater than 1/2, not just 2/3.

Under iid uniform samples,

    K ~ Binomial(d, 2^(1-n)).

If n<=(1-eta)log_2 d for fixed eta>0, its mean is at least 2d^eta. Chernoff gives K>=d^eta with probability at least 1-exp(-d^eta/4). Equation (2) then yields failure mass at least 1/2-O(d^(-eta/2)). Thus every fixed desired error epsilon<1/2 and fixed success probability bounded away from zero requires n>=log_2 d-O_(epsilon,delta)(1). In particular this exact finite-width result does not rely on selecting epsilon<1/4.

No inference to exponential depth is available: polynomial d in L still turns this into only logarithmic depth dependence.

For the additive-constant formulation, fix a constant k_0 large enough that the right side of (2) exceeds epsilon. Choose a constant mu_0>=2k_0 with exp(-mu_0/8) smaller than the desired fixed failure-probability separation. Whenever d2^(1-n)>=mu_0, Chernoff makes K>=k_0 with that fixed high probability. Rearranging gives the claimed n>=log_2 d-O_(epsilon,delta)(1) necessity.

## Limit of this exact input-symmetry mechanism

The linear orthogonal transformations preserving the augmented cube vertex set are signed coordinate permutations. Including the possible global output-sign change, their input-label action has at most 2^(d+1)(d+1)! elements. Ordinary hidden-unit signed permutations preserve the represented function itself and do not enlarge its input-label orbit.

For any fixed target f, the orbit concept class under this input-label symmetry has at most that many functions. A standard realizable finite-class union bound eliminates every orbit function with population error at least epsilon after

    n >= [log(2^(d+1)(d+1)!)+log(1/delta)]/epsilon
       = O((d log(d+2)+log(1/delta))/epsilon).

This does not upper-bound the full neural posterior, which contains functions outside one orbit. It does show that a lower-bound proof relying only on indistinguishability of these exact symmetry transforms of one target cannot establish exponential-in-depth sample hardness when d is polynomial in depth. A stronger lower would need extra posterior structure or approximate per-input symmetries, as in the supercritical white-prior mechanism.
