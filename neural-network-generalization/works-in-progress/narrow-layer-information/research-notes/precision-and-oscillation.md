# Constant-width tanh teachers: precision, bottlenecks, and the depth question

25 October 2026. Supporting results on finite-precision implementations and oscillation. The original unrestricted-prior sample-complexity question remains open. This note gives precision obstructions and a sharper rounding argument; it does not prove an NNBayes sample lower bound or a general subexponential-depth upper bound.

## 1. Audit of the existing analog compiler

The six-register construction in the [companion paper, Appendix A](../../boolean-depth-barriers/paper.pdf) has no apparent missing source of precision. The first layer explicitly encodes all input bits using the coefficients delta*4^(-i); the registers holding exact constants are charged neurons; repeated-source NAND coefficients are charged; uniform cloning divides each logical coefficient by four without decreasing its internal Frobenius norm. The temporary register's switch between small-memory and robust-bit modes is valid because each read overwrites it. The exponent 4^N in temporary-memory error, rather than an accumulation over all program steps, is justified because each read copies the main memory afresh. The stated bit-precision argument is correct but considerably looser than the schedule requires.

There are three distinct notions of precision:

1. Absolute resolution exp(-poly(resource)), which this compiler uses.
2. Number of binary description bits, which is polynomial and not exponential.
3. A common rational grid 1/Q with Q polynomial in the resources. This last restriction is much stronger and cannot represent all the same small-circuit targets at constant first-layer width.

Having individually small rational denominators is not identical to having a polynomial common denominator. For example, distinct prime denominators can have an exponentially large least common multiple. Statements below about a polynomial grid concern a common denominator, in particular ordinary bounded-fractional-bit dyadic weights.

## 2. A genuine necessity of exponentially fine first-layer grids

Let IP_m(u,v)=(-1)^(sum_i u_i v_i), where u,v are Boolean m-vectors. Suppose a deterministic network computes IP_m exactly and its first hidden layer has width r. No conditions on the activation or on the depth, width, precision, or computational power of the subsequent deterministic map are needed.

Assume every first-layer coefficient is in (1/Q)Z and has magnitude at most B. Split its first affine map into the Alice contribution a(u), Bob contribution b(v), and bias. If two different u,u' had a(u)=a(u'), every later computation would agree for every v. This is impossible: choose v equal to a coordinate vector at which u and u' differ. Thus the first-layer Alice sums have 2^m distinct values.

With signed Boolean inputs each coordinate of Q a(u) is an integer in [-QBm,QBm]. Consequently

    2^m <= (2 floor(QBm)+1)^r,
    Q >= (2^(m/r)-1)/(2Bm).

This is also the elementary deterministic one-way communication lower bound for inner-product parity: Alice must send enough information to distinguish all 2^m rows of its communication matrix.

For fixed r and polynomial B, a polynomial common denominator Q is impossible. IP_m has an O(m)-gate Boolean circuit and therefore has the bounded-width, polynomial-depth tanh implementation supplied by the analog compiler. Hence the compiler cannot in general be replaced by a constant-width implementation on an inverse-polynomial first-layer grid, even if unlimited later depth is permitted. This is an unconditional obstruction, not a consequence of an unresolved circuit-class separation.

For this argument, plain parity does not prove the claim, because a single integer-weight sum retains its parity. Inner-product parity does.

## 3. The corresponding geometric/conditioning obstruction

The same example forces fine *state* resolution without assuming rational coefficients. Suppose the first affine map is A x + B y + b with r output coordinates, the first activation is 1-Lipschitz, the suffix has Lipschitz constant T, and every target output has signed margin at least one.

For every distinct x,x', choose y separating their inner-product labels. The two outputs differ by at least2, whereas their difference is bounded by T||A(x-x')||. Hence the 2^m points A x are pairwise at distance at least2/T. They all lie in a Euclidean ball of radius sqrt(m)||A||F. Disjoint radius-1/T balls around them lie in the ball of radius sqrt(m)||A||F+1/T. Taking r-dimensional volumes gives

    2^m <= (1+sqrt(m)||A||F T)^r,
    ||A||F T >= (2^(m/r)-1)/sqrt(m).

If the suffix is itself a 1-Lipschitz-activation network, its Frobenius product upper-bounds T. Therefore **every implementation with first hidden width r** has total Frobenius product at least (2^(m/r)-1)/sqrt(m), independently of later depth and widths. Rank-deficient A only strengthens the packing bound; one may work in its span.

The [main paper, Theorem 3.1](../paper.pdf) improves the numerical bound by averaging over the input cube: at least half the 2^m code points lie in a ball of radius sqrt(2)||A||F. The same volume argument then gives the stronger inequality T||A||F >= (2^((m-1)/r)-1)/sqrt(2), which is the bound stated in the main paper.

This is a bottleneck-architecture lower bound, not an intrinsic lower bound allowing a wider first layer. Inner-product parity has a shallow polynomial-width, polynomial-product implementation. An unrestricted learner can use that alternative implementation. Thus fragility and exponential product in a narrow teacher do not establish bad NNBayes generalization.

## 4. Sharper rounding of the analog compiler: O(d+S) fractional bits suffice

Let N=d+S, M=N+1, delta=eta=4^(-20M), K=500M, and H<=5000M^3 as in the existing construction. Its final generic perturbation estimate used O(H+log d) bits. The actual register schedule permits a common dyadic grid with only O(M) fractional bits.

Round identical physical clone coefficients identically, toward zero, to error at most

    epsilon = 4^(-1000M).

The four clones of each logical register remain identical. Each effective logical coefficient changes by at most4epsilon. All initial input-encoding coefficients and the copy, hold, pop multiplier4, and append multiplier1/4 coefficients are dyadic and already lie on this grid, so they remain exact. The only relevant rounded coefficients are the amplifier/large-rail multiplier, delta/c in insertion and popping, and the final readout. The unused small D rail can be retained or deleted; it does not feed another register.

An amplifier block has K steps. Comparing its rounded update with u -> tanh(kappa u), starting at the same actual entering value, gives output discrepancy at most

    4epsilon sum_(j<K) 2^j < 4epsilon 2^K.

Here kappa<2 and |u|<=1. This is much less than eta. The original amplifier lemma therefore returns a bit within2eta of its intended endpoint, provided its entering value has the correct sign and magnitude at least delta/10. Subsequent robust holds preserve the 2eta interval: in that neighborhood the exact map has derivative below0.8 and its per-step perturbation is at most4epsilon. The large constant rail stays within20epsilon of c by the same contraction argument.

All Boolean gate signs remain correct, since their c-scale margins dominate these perturbations. For small memory registers, the hold/copy tanh errors remain O(delta^3), while the modified delta/c edges introduce O(epsilon) per append or pop. Replacing the old eta-accurate bit bound by2eta yields bounds of the form

    E_R <= C[H delta^3 + N delta eta + N epsilon],
    E_T <= C 4^N[H delta^3 + N delta eta + N epsilon],

with an absolute constant C (one may take C=100). The epsilon term is negligible relative even to delta^3. Dividing by delta gives at most a polynomial in M times 4^(-19M), with enormous slack below1/100 for M>=2. The same simultaneous bootstrap as in the original argument closes: all memory reads start the amplifier above delta/10 with the correct sign. The final readout still has signed margin greater than1.9.

This proof avoids multiplying a worst-case layer gain across the whole program. Robust registers contract while waiting; a temporary memory is expanded at most N times before it is discarded. The O(M)-bit precision claim is a refinement of the construction, not a polynomial-grid claim: Q=4^(1000M) is still exponential in M.

## 5. Fixed width and analyticity alone do not limit oscillations subexponentially

An exact elementary tanh map already has exponential iterated oscillation:

    F(x)=tanh(10(x+1/2))-tanh(10(x-1/2))-1.

Set I=[-0.9,0.9], J_+=[0.35,0.65], and J_-=-J_+. Direct elementary exponential bounds give

    F(0.35)>0.9,  F(0.65)<-0.9,
    |F'(x)|>1.8 on J_+ union J_-,
    |F'(x)|<=10 on the whole real line.

For the lower derivative bound, |10(x-1/2)|<=1.5 and 10(x+1/2)>=8.5 on J_+, so its magnitude is at least 10[sech²(1.5)-sech²(8.5)]>1.8. The map is even, and is strictly decreasing on the positive half-line. Each J branch therefore covers I monotonically. More precisely, F^(-1)(I) consists of exactly two closed intervals, one inside each J branch, because F is even and strictly decreasing on the positive half-line. Its two inverse branches map I back inside I. This also shows that |F^H(x)|<=0.9 forces membership in one of the full H-step branches.

It follows that F composed H times has 2^H disjoint monotone branches mapping onto I, each containing one simple zero. On each such branch the derivative magnitude is at least1.8^H and at most10^H. The intervals on either side of its zero up to output +/-0.9 have length at least0.9*10^(-H).

This iterated map is representable by a constant-width ordinary tanh network. Let c=tanh1 and retain a constant rail C=c. Store

    T_1=tanh(10(z+1/2)), T_2=tanh(10(z-1/2)),
    F(z)=T_1-T_2-C/c.

One further hidden layer updates these to the features of F(z): its logical preactivations are

    10T_1-10T_2-5C/c,
    10T_1-10T_2-15C/c.

Give each of T_1,T_2,C twenty equal clones. Every physical coefficient is at most1, since 15/(20c)<1. This uses width60; every repeated-map step costs one hidden layer. Initialization can first form z=tanh(u) and C=tanh1 with twenty clones each, and then the displayed features.

### Boolean grid and global margin

There is also a Boolean restriction exhibiting exponentially many lexicographic changes while maintaining a global output margin. Choose

    d >= ceil(H log_2 10)+5,
    Delta=2^(1-d), R=2^H, epsilon_0=Delta/(16R).

Use signed Boolean inputs to form

    u=sum_(i=1)^d 2^(-i) x_i + t,

where t=theta-Delta/2 and theta belongs to[0,Delta). These are equally spaced grid points in[-1,1]. The roots of F^H(tanh u) lie in[-atanh(.65),atanh(.65)]. For any root, values of theta making a grid point lie within epsilon_0 of it occupy at most2epsilon_0 of the circle of length Delta. All R roots therefore exclude at mostDelta/8 of the possible shifts.

A dyadic shift of O(H+d) fractional bits can be chosen outside the excluded set: a mesh of epsilon_0/4 has64R points per period, whereas the excluded intervals cover at most12R of them. At each resulting Boolean grid point the output is either at least0.9 in magnitude, or lies in one of the monotone branches. In the latter case the derivative with respect to u is at least sech²(1)*1.8^H>0.4*1.8^H. Thus every grid value has magnitude at least

    min(0.9, 0.4*1.8^H epsilon_0) = exp(-O(H+d)).

An additional O(H+d) amplifier layers turn this into signed output margin greater than1.9, with the same fixed width and physical coefficient bound. Since Delta<0.1*10^(-H), each zero has grid points on both sides within its monotone branch, so the Boolean labels have at least2^H lexicographic sign changes. The total teacher depth is O(H+d)=O(H), and d=Theta(H).

The shift can be selected nonuniformly; this is not claimed to be an efficient uniform algorithm for finding it. The resulting finite network can also be rounded to O(H+d) binary fractional bits with its final margin intact, using the ordinary full-network perturbation bound now that its total depth is O(H+d).

This construction obstructs a proposed route, not the desired learning theorem. Exponentially many sign intervals along an encoded Boolean grid need not imply high intrinsic Boolean-circuit complexity or high minimum Frobenius product at wider widths. Parity is a familiar warning against inferring circuit hardness from one-dimensional alternation.

## 6. Current implication for the requested general subexponential upper

We do not obtain a general exp(o(depth)) sample upper bound for all constant-width bounded-weight tanh teachers. The quantized first-layer result does give such an upper whenever r log(QBd)=o(depth), and gives a polynomial bound for fixed r and polynomial Q. Sections2–3 show that these restrictions exclude natural small-circuit functions at constant teacher width, rather than merely excluding a peculiar register encoding.

For arbitrary real first-layer coefficients, the obvious replacement is to round them to preserve labels using a suffix Lipschitz bound. At fixed width w and bounded weights this requires resolution exp(-O(depth log w)). Substituting into the finite-partition bound recovers exp(O(depth)); it does not improve it. Section5 shows that an argument based only on analytic-region count cannot fix that loss.

A successful general argument would need to exploit an alternative wide implementation of the represented Boolean function, rather than only faithfully discretizing or perturbing the given narrow teacher. The inner-product example makes this distinction concrete. No new intrinsic-function lower bound, nor a general alternative-implementation compiler with subexponential product, is established here.
