# A finite-chaos scalar interface for arbitrary bounded row densities

26 October 2026. Research lemma. This is a finite-degree local result, not an exact-tanh path theorem or a positive learning bound.

## 1. Statement

Let H be a real separable Hilbert space, gamma its isonormal Gaussian law, and rho=r gamma with

    0 <= r <= M,   E_gamma r=1,   D=KL(rho||gamma).

Fix an odd integer k=2m+1. Let p_k be the Taylor polynomial of tanh through degree k. There are constants c_(k,M), C_(k,M)>0, independent of dim H, such that if D<=c_(k,M), the polynomial feature

    F_(q,k)(h)(g)=p_k(sqrt(q) g.h)/sqrt(q),   ||h||<=1,

has an exact isometric representation of the form

    h + R_(q,k)(h)

in H plus an enlarged Hilbert space, with a scalar-coordinate factory for R whose integrated second moment is at most

    C_(k,M) (q+sqrt(D))^2                                  (1)

at common expected work C_(k,M) T. Here h is supplied through the same scalar-coordinate oracle interface as the Gaussian/Fock compiler: its coordinates have common work T and integrated second moment bounded by a fixed constant; a separate bounded-moment oracle for ||h||^2 is available. All coordinate choices and expression shapes are independent of the input.

The independently maintained squared-norm correction

    ||F_(q,k)(h)||_(L2(rho))^2 - ||h||^2

has a scalar factory with the same order of work and second moment. Constants are uniform for 0<q<=q0(k), and the factories are composed of linear sampling and products of at most a fixed number of fresh child samples. Consequently rare creation with probability comparable to q+sqrt(D) gives local work/moment growth 1+C_(k,M)(q+sqrt(D)), after the usual bounded-moment reset. Zero corrections are omitted.

The representation is exact for p_k. For tanh itself there is a common L2(rho) coupling with uniform error

    sup_(||h||<=1) ||tanh(sqrt(q) g.h)/sqrt(q)-F_(q,k)(h)||_2
          <= C_(k) sqrt(M) q^(m+1).                      (2)

No conclusion that the error in (2) can be discarded throughout an arbitrary critical path is included.

## 2. Gaussian chaos and the density tensors

Use the normalized Wiener-chaos isometry

    I_a : H^(symmetric a) -> L2(gamma),

so I_a(h^tensor a)=He_a(g.h/||h||)||h||^a/sqrt(a!). Put

    Fock_<=k = direct_sum_(a=0)^k H^(symmetric a),
    B=P_<=k M_r P_<=k,   T0=B-I.

The restriction is well-defined and 0<=B<=M I. Expand r-1 in Gaussian chaoses, with tensors v_b. Only b<=2k enter T0. Orthogonality gives

    sum_(b>=1) ||v_b||_HS^2 <= ||r-1||_2^2 <= C_M D.      (3)

The last inequality follows pointwise on 0<=t<=M from
(t-1)^2<=C_M(t log t-t+1), with its continuous value at t=1 and 0 log0=0.

The Gaussian product formula expresses every block (T0)_(a,c) as a finite sum of partial contractions with one v_b, where b=a+c-2ell and ell indices pass directly from input to output. All combinatorial coefficients depend only on k. Therefore

    ||T0||_diagram <= A_k ||r-1||_2                       (4)

for a finite A_k. In fact A_k<=C^k for a universal C (after increasing C to absorb fixed polynomial factors in k). For the normalized product formula the coefficient with a=r+ell, c=s+ell and b=r+s is

    sqrt(a! c! b!)/(ell! r! s!),

whose square is

    binom(r+ell,r) binom(s+ell,s) binom(r+s,r)
       <=2^(2(r+s+ell))<=2^(4k).

There are at most (k+1)^3 degree/contraction choices. This proves the exponential bound. It is a diagram-norm bound, not a claim of dimension-free Hilbert--Schmidt norm for the entire operator.

## 3. The partial-contraction algebra

A basic map from H^(symmetric a) to H^(symmetric c) consists of:

* ell identity strands pairing input and output indices;
* one Hilbert--Schmidt coefficient tensor on the remaining a+c-2ell indices;
* the orthogonal symmetrizations at input and output.

Its diagram weight is the HS norm of that coefficient tensor. Allow finite or absolutely summable sums of such maps and sum their weights, with the identity treated as a distinguished unit of weight one. Take the infimum over representations and the completion. Block indices range only from 0 to k.

This is a unital Banach operator algebra with submultiplicative diagram norm. To verify the only substantive point, compose two basic maps and expand the intermediate symmetric projection as the average over permutations. Each term is another partial-contraction map. The two coefficient tensors are contracted only against one another; any unchanged identity strands pass between the external input and output. A partial contraction of two HS tensors has HS norm at most the product of their norms. Scalar closed components are inner products and satisfy the same bound. There are no traces of a single arbitrary HS tensor: such a self-edge cannot arise from a pairing between the two different sides of the intermediate interface. Averaging the permutations does not increase the sum of weights. Composition of block matrices and absolutely convergent sums preserves this inequality.

Equivalently, after repeated compositions one gets tensor networks whose internal edges always join different original coefficient vertices. Merge vertices by contracting all their shared edges; the same HS inequality bounds every resulting coefficient tensor. This proves the completion and the operator-norm domination needed below. The identity plus an operator with diagram norm below one is therefore subject to the usual absolutely convergent scalar power series in this algebra.

Choose D small enough that A_k sqrt(C_M D)<=1/2. The binomial series then gives

    B^(1/2)=I+E,   ||E||_diagram <= C A_k sqrt(C_M D).      (5)

The series is also operator-norm convergent, so it is the positive square root. This constructs the exact positive kernel factor; it does not truncate the density to a signed polynomial and assume positivity.

## 4. Scalar realization of a diagram

A basic partial-contraction map applied to h^tensor a is a coefficient tensor contracted against at most a copies of h, tensored with the uncontracted copies, and symmetrized. With fresh samples for each copy of h, importance sampling the contracted indices gives an unbiased coordinate factory. Its integrated second moment is bounded by the squared HS coefficient norm times the a-th power of the integrated child second moment.

For clarity, if a coefficient tensor is C_(y,I), where I=(i1,...,ib) are contracted input indices and y labels output coordinates, sample I with the input-independent probability

    p_I=(sum_y |C_(y,I)|^2)/||C||_HS^2.

Return C_(y,I) product_j X_(ij)/p_I. Summing second moments over y gives exactly at most

    ||C||_HS^2 sum_I product_j E|X_(ij)|^2
       = ||C||_HS^2 (sum_i E|X_i|^2)^b.

The remaining uncontracted h factors contribute the remaining child-moment factors. No sampling probability uses an input-dependent second-moment profile or a coordinatewise supremum over inputs. The same construction works for scalar outputs and standard-Borel coordinate integrals. Zero coefficient columns are omitted.

More generally a partial-contraction map can act on any tensor-coordinate state X_(I,J), where J are the indices carried by identity strands. The same p_I gives total second moment at most

    ||C||_HS^2 sum_(I,J) E|X_(I,J)|^2.

Thus a diagram of weight a has a scalar-coordinate factory with trace at most a^2 times the incoming trace, at common work O(T). A sum of diagrams is sampled using their coefficient weights, also independently of the input. This stronger observation will be used for exact Gaussian residual coordinates below.

Average a fixed number depending on k of each child coordinate sample, so its integrated moment is at most 1+1/k whenever ||h||<=1. The at-most-k products then cost O_k(T) and have uniformly bounded moment. Sampling an absolutely summable diagram expansion with probabilities proportional to its weights gives moment O_k(||E||_diagram^2) and common work O_k(T). Internal tensor contractions are nonuniform constants; a realized formula requests only finitely many such constants. No algorithm for generating those constants is claimed.

## 5. The polynomial feature and its norm oracle

Under gamma, write the ordinary polynomial p_k(sqrt(q)g.h)/sqrt(q) in normalized Wiener chaoses. Its degree-one component is h plus an O_k(q) coefficient polynomial in ||h||^2. All other components have coefficient size O_k(q), uniformly for q<=q0(k), and degrees at most k. The separately maintained norm oracle handles these coefficient polynomials by independent products. Thus its Fock representative is

    Psi_(q,k)(h)=iota_1 h+N_(q,k)(h),

where N has coordinate-factory moment O_k(q^2) at common work O_k(T).

The exact rho feature kernel is

    <Psi(h),B Psi(h')> = <B^(1/2)Psi(h),B^(1/2)Psi(h')>.

Using (5), its representative is

    iota_1 h + N(h) + E iota_1 h + E N(h).

Section 4 supplies (1), including the mixed term. The original H is literally copied into degree one. There is no fixed cost multiplier on that copy at every layer.

For the norm oracle, evaluate

    <Psi(h),B Psi(h)>-||h||^2.

Expand the identity part and the finite Gaussian-product-formula expression for B-I. Every resulting scalar term is a fixed-degree contraction against density tensors from (3), multiplied by powers of q and ||h||^2. Its coefficient weight is O_(k,M)(q+sqrt(D)). The same sampling argument proves the asserted squared-moment bound. This avoids taking the square of an already randomized vector oracle.

Standard finite-bit moment-floor normalization applies to these fixed-degree multilinear formulas. The diagram square-root expansion causes no unbounded product degree in the queried h: after its coefficient tensors have been contracted, a realized map still contracts against at most k child factors. Constants can be selected and rounded only on the final finite good seed, as in the existing nonuniform compiler.

## 6. Approximation error and the unresolved exact-tanh limit

Every fixed derivative of tanh is globally bounded. Taylor's theorem at zero, retaining its odd polynomial through degree 2m+1, therefore gives a global bound

    |tanh z-p_(2m+1)(z)| <= C_m |z|^(2m+3).

The intermediate even coefficient vanishes, so expand through order 2m+2 before applying the remainder theorem. For ||h||<=1, Gaussian moments and r<=M prove (2).

This result supplies a dimension-free positive factorization for every fixed-degree approximation under arbitrary bounded density, beyond fixed-rank or normalized-ridge controls. It does not supply an exact tanh factory at the q+sqrt(D) budget: A_k grows quickly, the permitted D threshold depends on k, and the Taylor remainder has factorial Gaussian-moment constants. In particular one cannot let k grow with the target accuracy and call the constants uniform. Nor can one sum (2) over layers without propagating errors through the actual subsequent controls and final margin. Those are remaining obstacles, not conclusions of this note.


## 7. Separating the exact Gaussian layer from the density correction

The degree dependence need not multiply the unchanged Gaussian nonlinear feature. This sharper local approximate interface is useful when the density perturbation is very small.

Write the full Gaussian tanh feature as F_gamma(h)=iota_1 h+R(h), and let

    P=P_<=k,   R_k=P R,   R_>k=(I-P)R.

Gaussian Taylor approximation gives

    ||R_>k(h)||_2 <= C_k q^(m+1)                         (6)

uniformly on ||h||<=1. For the needed exact residual-coordinate factory, use the previously audited nonlinear-residual lemma in the public `source/non-gaussian-controls.tex` (equations `local`, `fock`, and `trace`). Set alpha=0, v=h, and its norm helper r=||h||^2. Its Gaussian specialization has degree-zero/one work O(T), degree-ell work O((ell+1)T), and weighted trace sum_(ell>=2) ell^2 V_ell plus the degree-one trace at most Cq^2. Thinning a degree-ell factory with probability 1/[C(ell+1)^2] gives common O(T) work and still total O(q^2) trace. There is no division by ||h|| and no lower norm premise. Coordinate projection to degrees <=k cannot increase either bound. This supplies R_k with common work O(T) and trace O(q^2), uniformly in k; it is not an unsupported coefficientwise Taylor estimate.

Let A=B^(1/2) and Sigma=iota_1* B iota_1=E_rho gg*. Define

    J=A iota_1 Sigma^(-1/2).

Then J is an isometry from H into Fock_<=k. Its isometric decomposition of the low-chaos feature is

    A P F_gamma(h) ->
       (Sigma^(1/2)h + Sigma^(-1/2)iota_1* B R_k(h),
        (I-JJ*) A R_k(h)).                              (7)

The original H is copied in the first component. The second component can be kept in the full low-degree Fock space, even though its range lies in J(H)^perp.

For D sufficiently small, Gaussian maximum entropy gives

    ||Sigma^(1/2)-I||_HS <=sqrt(2D),
    ||Sigma^(-1/2)-I||_HS <=C sqrt(D).

Consequently the *linear* correction in (7) has a scalar factory with moment O(D), without an exponential-in-k factor. The difference between the nonlinear part of (7) and its D=0 counterpart

    (iota_1* R_k, (I-iota_1 iota_1*)R_k)

has factory moment at most C^(2k) q^2 D and common work C^k T. This follows by expanding each factor as identity plus its diagram-small correction; every term contains R_k and at least one of A-I, B-I, or Sigma^(-1/2)-I. Projection and inclusion onto degree one have fixed diagram weight. The powers of the constant and fixed polynomials in k are absorbed into C^k.

Now retain the exact Gaussian high-chaos remainder R_>k in an additional orthogonal summand. The resulting feature map G_(q,k,r) is thus the existing exact Gaussian layer plus:

* an O(sqrt(D)) Hilbert--Schmidt linear correction;
* a nonlinear correction of scalar-factory moment C^(2k) q^2 D.

Rare creation gives local work/moment increment

    O(q + sqrt(D) + C^k q sqrt(D)),                     (8)

provided C^k sqrt(D) is below a sufficiently small fixed constant. The O(q) term is the already proved exact Gaussian Fock layer, not a Taylor approximation charged anew. The norm-state correction has a direct scalar factory, as follows. Its difference from the full Gaussian norm is exactly

    <P F_gamma,(B-I)P F_gamma>.

Use the Gaunt expansion with a,b odd and at most k, ell shared strands, and density-tensor degree c=a+b-2ell. Each term is a coefficient times

    t_a(q,s)t_b(q,s) s^ell <v_c,h^tensor c>,  s=||h||^2.

Here t_a are the exact damped Fourier/Fock coefficients. Use independent frequency proposals omega kappa(omega) and nu kappa(nu), where kappa(w)=1/sinh(pi w/2). This proposal handles a=1 without a spurious low-frequency singularity. The relative damping is exp[-q(omega^2+nu^2)s/2]. Put eta comparable to 1/[1+q(omega^2+nu^2)]. Average each h child sufficiently often that its trace is at most s+eta, and each norm-oracle child sufficiently often that its second moment is at most s^2+eta^2; this requires O(eta^-1) and O(eta^-2) copies, respectively. The tensor and shared-strand moments are then bounded by

    (s+eta)^(c+2ell)=(s+eta)^(a+b).

The squared relative damping cancels the true-s part when summing the two factorial series. Write x=q omega^2(s+eta), y=q nu^2(s+eta). For a+b>=4, their sum is at most

    x y (x+y)^2 exp(x+y).

After the outer q^-2/(omega^2 nu^2) factor, this is O(q^2(omega^2+nu^2)^2). Remaining work factors are fixed polynomials in the frequencies and in k, and the exponential proposal tails integrate them. Gaunt coefficients and the finite number of degree choices cost only C^k; the density tensors supply the factor D through (3).

For a=b=1, subtract h*(Sigma-I)h explicitly. The remaining coefficient contains exp[-q(omega^2+nu^2)s/2]-1, supplied by the existing relative exponential residual factory with moment O(q^2(omega^2+nu^2)^2). The linear covariance correction itself has O(D) moment by the HS quadratic-form factory. Thus the nonlinear scalar norm correction has moment C^(2k)q^2D and common work C^k T, as required. This calculation uses the stored norm oracle for shared strands; a generic trace bound on tensor coordinate oracles would not alone justify summing those inner products.

Constants in (8) include the fixed-degree sampling cost through C^k.

There is a common isometric embedding in which the actual rho feature and G differ by at most

    (sqrt(M)+1) C_k q^(m+1).                            (9)

Indeed the polynomial/low-chaos rho feature is matched exactly by (7). The discarded actual tail has rho norm at most sqrt(M) times its Gaussian norm, while the retained Gaussian tail has that Gaussian norm. Extend the isometry of the matched low-chaos spans to a common larger Hilbert space and apply the triangle inequality. This does not assert that the actual tail is orthogonal to the matched low-chaos span.

There is a minor distinction between two implementations: exact Hermite projection uses the established norm-dependent coefficient factories, whereas an ordinary Taylor proxy has polynomial coefficient formulas and a nonorthogonal difference from the Gaussian feature. For the exact orthogonal-tail statement above use the Hermite projection; for the elementary Taylor bound (6), it suffices that orthogonal projection minimizes Gaussian L2 error.

## 8. Why the refined interface is potentially useful, and what is still missing

If a path has a reference layer family with an exact cheap compiler and arbitrary bounded density perturbations of entropies delta_j, the target refinement is the analogue of (8), with delta_j in place of D_j. It would charge the delicate part by C^k sum_j q_j sqrt(delta_j). Cauchy--Schwarz bounds this by

    C^k sqrt[(sum_j q_j^2)(sum_j delta_j)].

Thus a total excess entropy of order polylog(H)/H could offset an exponential-in-k constant for k=c log H. This observation is only a budget calculation. Section 7 proves the Gaussian-reference local interface; it does not establish its extension to an arbitrary ridge reference, the required excess-entropy decomposition for actual optimal paths, or a global bound on accumulated approximation error. Those additional steps are necessary before claiming an original critical-posterior compiler.
