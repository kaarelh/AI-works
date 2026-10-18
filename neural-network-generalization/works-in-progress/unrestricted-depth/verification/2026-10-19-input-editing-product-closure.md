# Depth-independent input editing for intrinsic product complexity

## Result and scope

There is a useful closure operation that avoids running an auxiliary computation in parallel with an arbitrarily deep network: **edit its input before entering the old network**. In particular, changing any finite set of Boolean labels costs only a factor polynomial in the dimension and number of changes, and logarithmic in the old product complexity. The old depth does not enter this factor.

Let a tanh network have augmented input u=(1,x), no subsequent biases, a linear scalar readout z(u), and Frobenius product P. Suppose g(x)z(1,x)>=1 on the Boolean cube. The extension z to all of R^(d+1) is odd and P-Lipschitz:

z(-u)=-z(u),   |z(u)-z(v)|<=P||u-v||_2.

These two properties let a shallow prefix multiply the computed Boolean function by a simple Boolean predicate, without carrying the original input through the old depth. For arbitrary auxiliary predicates, constructing that prefix remains a genuine problem.

## 1. Vector-output cloning

For a one-hidden-layer vector map

T(u)=sum_j b_j tanh(a_j·u),   b_j in R^r,

define its variation V=sum_j ||a_j||_2 ||b_j||_2. Cloning neuron j exactly c_j times and dividing its output vector by c_j preserves T, and gives matrix product

[(sum_j c_j||a_j||_2^2)(sum_j ||b_j||_2^2/c_j)]^(1/2).

Omit zero terms. Choosing c_j=ceil(t||b_j||/||a_j||) and letting t increase makes this product tend to V. Thus a finite cloning attains product at most 2V. More explicitly, t=max_j ||a_j||/||b_j|| gives product at most sqrt(2)V; the ceiling only adds at most another t||a_j||||b_j|| to each incoming squared norm.

If T is inserted before an old network, its linear output B can be merged with the old first matrix W_1. Since ||W_1B||_F<=||W_1||_F||B||_F, the resulting product is at most P||A||_F||B||_F. There is just one additional hidden layer. A scalar rescaling of the old final output multiplies the product by the same factor.

## 2. Changing k Boolean labels

Let E be a set of k>=1 distinct Boolean inputs. Define f=-g on E and f=g outside E. Set h=1-2 1_E and

T(x)=h(x)(1,x)=(1,x)-sum_{e in E}(1,e)[1+(2 1_{x=e}-1)].

Then z(T(x))=h(x)z(1,x), so its signed margin for f is at least one. This works for constant g as well.

For each exception e, put

s_e(x)=e·x-d+1.

It is +1 at e and at most -1 elsewhere. Let R=sqrt(d+1), choose

delta=1/(4PkR),    lambda=(1/2)log(8PkR),

and replace 2 1_{x=e}-1 by t_e(x)=tanh(lambda s_e(x)). The replacement error is at most delta uniformly. Here P>=1: restrict the odd globally margined extension to the entire augmented Boolean cube; it has two adjacent vertices of opposite sign, which forces Lipschitz constant at least one. Alternatively, replacing P by max(P,1) everywhere avoids using this observation.

The vector map

T_tilde(x)=(1,x)-sum_{e in E}(1,e)[1+t_e(x)]

has error at most kR delta=1/(4P). Consequently 2z(T_tilde(x)) has signed margin at least 3/2 for f.

This is exactly a one-hidden-layer vector map. Let alpha=atanh(1/2) and tau=tanh(1). Use:

* one constant neuron with incoming row alpha e_0 and outgoing vector 2[e_0-sum_e(1,e)];
* d identity neurons with incoming rows e_i and outgoing vectors e_i/tau;
* k point neurons with incoming rows lambda(1-d,e) and outgoing vectors -(1,e).

The identity coordinates are exact because tanh(x_i)=tau x_i on the cube. Thus their cost does not depend on the requested approximation accuracy.

The variation is bounded by

V <= 2alpha(1+kR)+d/tau+k lambda d R,

since sqrt((d-1)^2+d)<=d for d>=1. Applying vector-output cloning, merging the prefix, and doubling the readout proves

P_new <= C P [d+1+k d sqrt(d+1) log(8Pk sqrt(d+1))].              (1)

The modified network has exactly one more hidden layer than the supplied representation. It has finite width; the displayed construction and the explicit cloning rule use prefix width polynomial in d,k,log(P+2). No assumptions on the old width or depth are needed. If k=0, keep the original network unchanged.

Taking infima gives the same bound with P replaced by intrinsic product complexity, after changing the universal constant. To justify an unattained infimum, choose a witness with product at most twice the infimum and apply (1).

## 3. A general Fourier input-editing lemma

Let T:{-1,1}^d -> R^r have vector Fourier expansion

T(x)=sum_{S subset [d]} b_S chi_S(x),   A=sum_S ||b_S||_2.

For any eta in (0,1), there is a one-hidden-layer tanh vector map T_tilde with

sup_x ||T_tilde(x)-T(x)||_2<=eta

and Frobenius product at most

C(d+1)^2 A log(2(d+1) max(A,1)/eta).                         (2)

The harmless max(A,1) can be replaced by A whenever A>=eta.

Proof: every parity chi_S can be approximated uniformly to delta by at most |S| Hamming thresholds plus one exact constant neuron. Writing t for the number of negative selected coordinates,

chi_S(x)=b_0+sum_{j=1}^{|S|}(-1)^j sign(2t-2j+1),

where b_0 is 0 or 1. Replacing signs by tanh at steepness (1/2)log(2|S|/delta) has scalar variation at most C(d+1)^2 log(2(d+1)/delta). The empty parity is exact. Use delta=min(1/2,eta/(2max(A,eta))) and multiply outgoing scalars by b_S. The total vector error is at most A delta<=eta, and total variation is at most the right side of (2), after enlarging C. Vector-output cloning finishes the proof. If A=0 the map is zero and there is nothing to prove.

More generally, suppose an old P-Lipschitz network z on R^r has target margin one after exact composition with T. Choose eta=1/(4max(P,1)), apply (2), merge the linear output with the old first matrix, and double the final output. The composed target has product at most

C P(d+1)^2 A log(8(d+1)max(A,1)max(P,1)).                    (3)

The old depth again does not enter the multiplier.

## 4. Parity modulation and low-Fourier-norm predicates

Let h be any Boolean predicate with Fourier l1 norm H=sum_S |h_hat(S)|. For T_h(x)=h(x)(1,x), each coordinate has Fourier l1 norm H, so its vector Fourier variation is at most (d+1)H. Since z(T_h(x))=h(x)z(1,x), (3) gives

P_intrinsic(gh) <= C P(d+1)^3 H log(8(d+1)^2 HP).             (4)

In particular H=1 for every signed parity. Multiplying any arbitrarily deep Boolean network by any parity therefore increases intrinsic product by only a polynomial dimension factor and a logarithm of P, with one extra hidden layer.

There is also an AND/OR version. Use +/-1 labels with +1 meaning true. If g takes the value -1, choose a Boolean witness a with g(a)=-1 and define

T(x)=(1, [(1+h(x))/2] x+[(1-h(x))/2] a).

This equals (1,x) when h=+1 and (1,a) when h=-1, so g(T(x))=g(x) AND h(x). Its vector Fourier variation is O((d+1)(H+1)), and (3) gives the same order as (4). If g is identically +1 the answer is h, which has a direct shallow representation of product O((d+1)^2 H log(2(d+1)H)); if g is identically -1 the answer is g. OR follows with a positive witness and the reversed selector. These are existence constructions; the chosen witness need not be found efficiently.

## 5. What this does and does not settle

This proves depth-independent closure under finite label modifications and under combination with low-Fourier-norm predicates. It bypasses the exponential parallel-block cost by composing a shallow input editor before the deep computation. It also gives near-linear, rather than an unspecified polynomial-power, dependence on the old product P.

It does not prove closure under majority of arbitrary polynomial-product networks. For a general deep h, implementing all coordinates of h(x)(1,x) with polynomial product would require a new identity-augmentation theorem. Carrying x through h's entire depth by disjoint rails recreates the old parallel-block penalty. The Fourier bound can be exponential for a polynomial-circuit predicate, so it cannot be iterated through arbitrary circuits to give the desired full theorem.

Likewise (1) is an interpolation witness, not a noisy-label generalization theorem: it supplies a cheap exact fit for a clean small target plus finitely many flipped labels, but does not compare the posterior weight of inaccurate interpolants.

Finally, no explicit function-level obstruction is known for unrestricted intrinsic product. Constant-depth threshold circuits already have polynomial intrinsic product. A Boolean polynomial-circuit family proved to have superpolynomial intrinsic product would therefore separate P/poly from TC0; an NC1 example would separate NC1 from TC0. The present constructions do not establish a converse class inclusion.
