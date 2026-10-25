# A scalar-formula interface for one-dimensional entropy tilts of a Gaussian feature layer

25 October 2026. Independently audited restricted-path result, with later closure sections completing the initial local construction. This is not the original critical posterior theorem. The scalar norm oracle, arbitrary changing directions, large steps, physical normalization, and finite precision are completed in Sections 8--11 and the linked independent audit. The earlier local scope cautions are retained to make the proof dependencies visible; they are superseded exactly to the extent stated in Section 11. Arbitrary conditional or multidimensional entropy tilts remain outside the theorem.

The purpose is to handle genuinely non-Gaussian one-dimensional tilted coordinates without imposing moments above two.

## 1. Input and feature conventions

Let rho be a law on R with KL(rho||N(0,1))=D. Let Z~rho and let G be an independent isonormal Gaussian on a real Hilbert space H_perp=L2(Y,mu). Fix 0<q<=q0, for an absolute small q0. Write the normalized query state as

    h(x)=alpha(x)e0+v(x),       alpha(x)^2+||v(x)||^2<=1,
    r(x)=||v(x)||^2.

The feature map of interest, represented in L2(rho) tensor Gaussian Fock space over H_perp, is

    F(h)(z,G)=tanh(sqrt(q)[z alpha+G.v])/sqrt(q).       (1)

Its linear part is

    L(h)(z,G)=z alpha+G.v.

Set sigma^2=E_rho Z^2. Entropy implies

    sigma^2-1-log(sigma^2)<=2D,

so sigma and its reciprocal are bounded when D is small, and |sigma-1|<=C sqrt(D). Let J be the isometry sending e0 to z/sigma in Gaussian degree zero, and sending each perpendicular coordinate v_i to the constant-in-z degree-one coordinate with index i. These supports are disjoint. Then

    L=J diag(sigma,I).

This is a free weighted-copy isometry followed by a rank-one HS perturbation of size O(sqrt D).

Assume independent scalar formula calls for alpha, r, and each v_i, with correct means, common expected complex-formula size at most T, and

    E X_alpha^2 <= V,     E X_r^2 <= V,
    integral E X_i^2 dmu(i) <= V,

where V is a fixed absolute constant. Random formula shape is input-independent. The true r lies in [0,1], but its unbiased oracle may take negative values. All operations below preserve unbiasedness without clipping the oracle.

Coordinates may be a mixture of atoms and continuous measure. The trace invariant means the displayed integral, rather than a sum over a pointwise delta-function basis. Gaussian Fock tensors are L2(Y^k,mu^k); a final scalar readout is an L2 integral. Every sampled formula nevertheless uses only finitely many ordinary scalar leaves almost surely.

## 2. Useful scalar Poisson factories

For a real oracle X of mean a, second moment at most V, define

    K~Pois(lambda),   Z_s=product_(j=1)^K(1+i s X_j/lambda),
    lambda=1+s^2 V.

Then E Z_s=exp(i s a), E|Z_s|^2<=e, and expected complex-formula size is O(lambda T). Correlated subtraction uses the same realized children, copied syntactically with their full size charged.

Balancing work to O(T), by sparsifying an expensive call and averaging a cheaper call if needed, yields factories with the following second-moment bounds:

    sin(sa):       C s^2 V,
    cos(sa):       C(1+s^2 V),
    cos(sa)-1:     C min(s^4 V^2,s^2 V).                (2)

For the final line, before balancing,

    E(Re Z_s-1)^2
     =(cos u-1)^2+cos^2(u)(cosh w-1)+sin^2(u)sinh w,
    u=sa,   w=s^2 E X^2/lambda<=1.

This is O(min(s^4 V^2,1)); multiplication by lambda gives (2).

For a real oracle R of true mean r>=0 and second moment <=V, take

    K~Pois(lambda),   E_c=product_(j=1)^K(1-c R_j/lambda),
    lambda=1+c^2 V.

Then

    E E_c=e^(-cr),
    E E_c^2=e^(-2cr+c^2 E R^2/lambda)<=e e^(-2cr).

After balancing work to O(T), its second moment is at most

    C(1+c^2 V)e^(-2cr),

and a correlated factory for E_c-1 has second moment at most C c^2 V when r<=1 and V is a fixed constant. The latter uses

    E(E_c-1)^2=e^(-2cr)(exp(c^2 E R^2/lambda)-1)+(e^(-cr)-1)^2.

All these cost bounds count complex multiplication and real/imaginary projection as primitive formula operations. The established global complex-formula balancing theorem is applied only after a finite seed is selected; no K^2 real expansion is charged at each recursive call.

## 3. Gaussian degrees at least two

Put kappa(omega)=1/sinh(pi omega/2), and let w(omega) be its normalized omega^3 multiple on (0,infinity). The Gaussian Hermite/Fock coefficient of degree k in (1) is

    (1/sqrt(q)) integral_0^infinity kappa(omega)
      e^(-q omega^2 r/2) (omega sqrt(q))^k/sqrt(k!)
      times [sin(omega sqrt(q) z alpha) if k is even,
             cos(omega sqrt(q) z alpha) if k is odd]
      times the appropriate sign and v^(tensor k) d omega.        (3)

For a fixed output coordinate (z,k,I), sample omega from w. Estimate the damping factor with the previous relative exponential factory, using c=q omega^2/2. Estimate the trigonometric factor with its balanced factory. For each of the k tensor factors use an independent average of

    m=ceil(C(1+q omega^2 V))

copies of the appropriate v-coordinate oracle. Its summed trace moment is at most

    r+V/m.

The exponential factory's relative second-moment damping cancels the true-r exponential arising when the tensor degrees are summed:

    exp(-q omega^2 r)
       sum_(k>=0) [(q omega^2)(r+V/m)]^k/k!
      =exp(q omega^2 V/m)<=C.

For odd k>=3, the tail with k^2 inserted is bounded by

    C (q omega^2)^3 poly(1+q omega^2)
       exp(q omega^2(r+V/m)).

The balanced cosine factor contributes at most C(1+q omega^2 z^2). For even k>=2, the corresponding tail starts at (q omega^2)^2, but the sine factor contributes C q omega^2 z^2. Division by q and the square of w/kappa, namely a constant times omega^6, therefore gives, after integration over omega,

    sum_(k>=2) k^2 integral_(Y^k) E |residual_(z,k,I)|^2 dmu^k(I)
      <= C q^2(1+z^2).                                  (4)

The polynomial factors in omega are harmless because w has exponential tails. The moments in (4) are before rare creation of the coordinate. Conditional expected size is O(k m T+T), uniformly in z after the scalar balancing, so its omega average is O((k+1)T) for q<=q0.

Taking expectation in z uses only E_rho Z^2=sigma^2. No fourth or higher z-moment appears.

## 4. Degree one correction

The degree-one coefficient, relative to its copied linear coordinate, is

    psi_1(z,alpha,r)=E sech^2(sqrt(q)z alpha+sqrt(q r)G)-1
      =integral_0^infinity omega kappa(omega)
          [(cos(omega sqrt(q)z alpha)-1)e^(-q omega^2r/2)
             +(e^(-q omega^2r/2)-1)] d omega.             (5)

Here integral omega kappa(omega)d omega=1. Use the scalar factories in (2), and the exponential factories, with a fixed exponentially tailed frequency proposal that is bounded away from zero relative to the required polynomial powers of omega. A direct Cauchy estimate gives a common O(T) expected size and second moment bounded by

    C[min(q^2 z^4,q z^2)+q^2].                          (6)

For q<=q0, entropy duality gives

    E_rho min(q^2 Z^4,q Z^2)<=C(q^2+qD).

Indeed divide the minimum by q; the resulting variable is bounded by Z^2, and its small-q Gaussian exponential moment has logarithm O(q). Multiplying (5)'s oracle by a fresh v_i oracle and summing over i therefore costs trace at most C(q^2+qD).

## 5. Degree zero correction

Split the degree-zero residual as

    q^(-1/2)E tanh(sqrt(q)z alpha+sqrt(q r)G)-z alpha
       =[tanh(sqrt(q)z alpha)/sqrt(q)-z alpha]
        +q^(-1/2)integral kappa(omega)
             sin(omega sqrt(q)z alpha)
             [e^(-q omega^2r/2)-1]d omega.                (7)

The first term is the capped one-dimensional residual factory from
`nongaussian-entropy-formula-interfaces.md`:

    common expected size O(T),
    second moment <=C min(q^2 z^6,z^2).

For the heat correction, the omega^3 kappa proposal gives a second moment Cq^2 z^2: the sine contributes q omega^2 z^2, the exponential residual contributes q^2 omega^4, and the outer division by q and proposal square omega^6 cancel those frequency powers. Its expected size is O(T).

Entropy duality yields

    E_rho min(q^2 Z^6,Z^2)<=C(q^2+D).

Consequently the integrated degree-zero residual moment is at most C(q^2+D).

## 6. Restoring literal coordinate copies without an expensive basis rotation

Let R=F-L in the full direct-integral/Fock coordinate representation. Sections 3--5 produce separately sampled coordinate formulas of common size O(T), with total second-moment trace at most C(q^2+D); the degree-k costs in Section 3 are handled by the k^2-weighted bound.

The map

    F(h) -> (J*F(h), (I-JJ*)F(h))
          =(diag(sigma,I)h+J*R(h), (I-JJ*)R(h))            (8)

is an isometric embedding into H_old direct-sum H_new. It preserves the whole feature Gram kernel. Crucially, only the small residual is projected.

The adjoint J* is inexpensive because J has disjoint-support weighted-copy columns. For its anchor coordinate sample z with density z^2/sigma^2 relative to rho; for each perpendicular coordinate sample z directly from rho in the degree-one channel. The resulting trace second moment is at most the original residual trace. Reapplying J also preserves that trace and needs one scalar child per output coordinate. Thus (I-JJ*)R has total second-moment trace at most four times the original one, with common O(T) coordinate cost.

Apply rare creation with probability a=C0(q+sqrt D) for the degree-zero/one residuals and probability min(1,a/k^2) for degree k>=2, when a is small. Together with the rank-one linear correction sigma-1, this increases the maintained trace variance and common coordinate formula work by factors 1+O(q+sqrt D). The independent-copy variance-reset argument then gives exp[O(sum(q+sqrt D))] complex-formula work along a path, PROVIDED the auxiliary scalar norm-oracle invariant closes as assumed in Section 1.

If a designated anchor is along e0 before the layer, its new vector is within relative distance O(q+sqrt D) of the copied e0 direction, by the residual Lipschitz estimate. A minimal planar rotation sends that new normalized anchor back to e0 and has HS distance from the identity O(q+sqrt D). Unlike a Householder reflection, this near-identity rotation has small cost. Its scalar formulas are supplied by the near-copy HS perturbation lemma, including continuous kernels. This keeps the tilt direction a literal scalar coordinate in subsequent layers.

## 7. Remaining closure obligations

1. The squared perpendicular norm oracle r is not supplied automatically by a trace bound. Sampling a squared norm directly from arbitrary coordinates can cost exponentially in the input dimension. It must be updated as a separate scalar state. A promising formula uses the norm increment

       E_rho E_G tanh^2(sqrt(q)[z alpha+sqrt(r)G])/q
           -(sigma^2 alpha^2+r).

   Fourth-order Fourier cancellation appears to give an optimized scalar work-moment bound O((q+D)^2): for small sqrt(q)|z| the square-root potential is O(q(1+z^4)), and for large z it is O(1+z^2); entropy controls E min(qz^4,z^2) by O(q+D). The detailed common-child cancellation and auxiliary-variance recurrence are not yet written here.

2. General conditional entropy tilts are not of rank one. Projecting the full path onto one anchor leaves a total conditional-entropy budget bounded by its excess over the one-point optimum, but ignoring this budget is not justified after subsequent amplification. This construction does not remove that obstacle.

3. The direct-integral scalar formula construction needs a finite-bit completion. The moment-floor normalization proposal may extend to standard Borel coordinate measures, because each fixed seed selects finitely many coordinates, but this extension has not been audited.

4. Large q or D steps, and paths whose normalized state bound changes, need the usual explicit rescaling/reset bookkeeping before a complete theorem can be stated. The current estimates target the small-budget steps that dominate a long nearcritical trajectory.

No new Bayesian sample theorem or PNC1 classification is claimed in this note.

## 8. Detailed proposed closure of the scalar squared-norm oracle

This section supplies the first closure obligation above. It should be audited before the conditional path conclusion is promoted.

For fixed z define

    delta_z(alpha,r)=E_G tanh^2(sqrt(q)[z alpha+sqrt(r)G])/q
                      -(z^2 alpha^2+r).

There is an unbiased scalar complex-formula factory of common expected size O(T) and second moment at most C b(z)^2, where

    b(z)=q+min(q z^4,z^2).                               (9)

All input second moments are bounded by the same absolute V. Only second moments of independent child calls are used; syntactic reuse is needed within each correlated Taylor subtraction.

### 8.1 Fourth-order cosine remainder

For the complex Poisson product Z_s of Section 2, set

    Q_s=(s/lambda)^2 sum_(a<b<=K) X_a X_b,
    R_s=Re Z_s-1+Q_s.

Then E R_s=cos(sa)-1+(sa)^2/2, and

    E R_s^2 <= C s^8 V^4.                               (10)

For |s|sqrt(V)<=1, expand the compound-Poisson generating identity

    E[P(t)P(u)]=exp[a(t+u)+(E X^2/lambda)tu],
    P(t)=product_(j<=K)(1+t X_j/lambda).

After removal of degrees zero and two, every retained real term has degree at least four in each factor. Bounding absolute coefficients by the same identity with |a| and positive t,u gives O((|s|sqrt(V))^8), since that parameter is at most one. For |s|sqrt(V)>=1, the product has second moment <=e, while

    E Q_s^2=(u^4+4u^2 w+2w^2)/4,
    u=sa,  w=s^2 E X^2/lambda<=1.

Thus E R_s^2<=C(1+u^4)<=C s^8 V^4. This proves (10) globally.

The pair sum is formed in O(K) formula size through

    2 sum_(a<b) X_a X_b=(sum_a X_a)^2-sum_a X_a^2.

Each occurrence is a full syntactic copy of the same realized child. The fourth powers visible in that expression cancel algebraically; the exact pair polynomial and identity above show that no child fourth moment is required.

### 8.2 Second-order exponential remainder

For the real Poisson product E_c of Section 2, put

    Q_c=(c/lambda)sum_(j<=K) R_j,
    S_c=E_c-1+Q_c.

Then E S_c=e^(-cr)-1+cr, and

    E S_c^2<=C c^4                                       (11)

when the oracle second moment is bounded and 0<=r<=1. For c<=1, use the same compound-Poisson series argument with degrees at least two. For c>=1, E E_c^2<=e, while E Q_c^2=c^2 r^2+c^2 E R^2/lambda<=c^2+1. Hence the second moment is O(1+c^2)<=O(c^4). Its expected formula size is O((1+c^2)T).

### 8.3 Small q z^2

The Fourier identity for tanh^2 is

    tanh^2(u)=integral_0^infinity omega kappa(omega)[1-cos(omega u)]d omega,
    integral_0^infinity omega^3 kappa(omega)d omega=2.

Set u=omega sqrt(q) z alpha and c=q omega^2 r/2 in the deterministic expression below. Then

    1-cos(u)e^(-c)-(u^2/2+c)
       =(1-cos(u)-u^2/2)e^(-c)
         +(1-e^(-c)-c)+(u^2/2)(e^(-c)-1).              (12)

Use the factories (10)--(11), the relative exponential factory, and the first-order exponential remainder factory for the three terms. In (12) the symbol c includes r; in a Poisson call the coefficient is q omega^2/2 and the r oracle supplies its mean.

Sample omega from the omega^3 kappa proposal and multiply by the importance coefficient 2/(q omega^2). If qz^2<=1, (10) gives first-term moment O(q^2 z^8) after integration; (11) gives O(q^2); the cross term gives O(q^2 z^4). The extra polynomial frequency factors have finite expectation under the fixed exponentially tailed proposal. The expected complex-formula size is O(T), because the relevant Poisson rates are at most polynomials in omega, uniformly when qz^2<=1 and q<=q0. Thus the moment is bounded by

    C q^2(1+z^8) <= C[q+q z^4]^2.

### 8.4 Large q z^2

If qz^2>1, use the direct tanh^2 Fourier identity with proposal omega kappa(omega), which is a probability density. The balanced cosine factory has second moment O(1+q omega^2 z^2); the relative exponential factory has an additional polynomial-in-omega factor. Therefore the direct tanh^2/q estimate has second moment at most

    C(1+q z^2)/q^2 <= C z^4.

Its expected size is O(T). Subtract independent unbiased products for z^2 alpha^2 and the r oracle. Their moments are O(z^4+1)=O(z^4), since q<=q0 and qz^2>1. This proves the large-z part of (9).

### 8.5 Integrating z and updating the norm state

Let B=E_rho b(Z). Entropy duality, applied to min(qZ^4,Z^2), gives

    B<=C(q+D).

The variable is bounded by Z^2 and its Gaussian exponential moment has logarithm O(q), by the same min-bound argument used earlier. Sample z with density b(z)/B relative to rho and divide its scalar factory by that density. The resulting estimator of E_rho delta_z has second moment at most C B^2 and expected cost O(T).

Consequently the total squared-norm increment relative to alpha^2+r,

    delta_norm=E_rho delta_z +(sigma^2-1)alpha^2,

has an oracle of moment O((q+sqrt D)^2) and cost O(T), for small D. Use independent alpha copies for alpha^2.

After the near-identity anchor-alignment rotation, write alpha_new=alpha+Delta_alpha. The existing residual/HS formulas provide a Delta_alpha oracle with second moment O((q+sqrt D)^2) and cost O(T). A fresh product of Delta_alpha and alpha_new+alpha has the same moment order and mean alpha_new^2-alpha^2. Therefore

    r_new = r + delta_norm -(alpha_new+alpha)Delta_alpha

can be updated as a small scalar residual. Rare activation with probability proportional to q+sqrt D gives variance and work increments O(q+sqrt D). The true r_new remains in the controlled bounded interval after the same harmless global normalization used for the vector state. Independent two-copy averaging resets the scalar oracle variance at the same cumulative budget. No direct coordinatewise sampling of ||v||^2 is needed.

This completes the proposed oracle-level small-step closure. It still does not address arbitrary conditional tilts, and the continuous-coordinate finite-bit completion remains a separate obligation.

## 9. Arbitrary tilt directions: no fixed anchor is necessary

The parent agent observed that the direction of the one-dimensional tilt can change arbitrarily between layers. A persistent anchor coordinate and its alignment rotation are unnecessary.

Let a be any fixed unit vector in the current feature Hilbert space H, let P=I-aa*, and use the row law

    g=Z a+G_perp,   Z~rho,   G_perp standard Gaussian on a^perp,

with independence. For a query h, put alpha=<a,h> and v=Ph. Supply the old coordinate family and a stored scalar oracle for s=||h||^2. The local helpers are

    alpha=<a,h>,        v_i=h_i-a_i alpha,        r=s-alpha^2.

Sample alpha with density a_i^2 over the coordinate measure. Its second moment is at most the old trace budget V. Each v_i requires one old coordinate and one independent alpha helper; its total trace moment is at most 4V. The r helper uses two independent alpha copies and the s oracle, so its second moment is bounded by an absolute constant. Every helper has expected size O(T). They are called only inside the rare residual branches; their constant factors therefore do not accumulate at every layer.

It is harmless to realize G_perp as G.P, where G is an isonormal Gaussian on all of H. The residual vector v lies in a^perp, so the redundant Gaussian direction changes no feature kernel. Thus the Fock construction in Sections 3--5 applies without an expensive coordinate rotation.

Here the linear isometry is

    J h = (z/sigma)<a,h> in degree zero,
          Ph in degree one, constant in z.

It is not a disjoint-support coordinate map, but its adjoint on the SMALL residual remains inexpensive. Put

    b0=E_rho[z R0(z)/sigma],
    b_i=E_rho R1(z,i).

Then

    J*R = a b0+P b.

The scalar b0 uses density z^2/sigma^2; the b_i use rho. Evaluate a.b with density a_i^2, and return (Pb)_i=b_i-a_i(a.b). The trace second moment is bounded by a universal constant times the original residual trace. Reapplying J is even simpler:

    (JJ*R)_degree0=(z/sigma)b0,
    (JJ*R)_degree1=P b,

because a.Pb=0 as an exact identity. No numerical cancellation of separately estimated a.Pb is needed.

The isometric embedding (8) therefore gives the exact old-coordinate copy plus the rank-one linear perturbation

    (sigma-1)aa*h

and the small residual. Its HS norm is |sigma-1|=O(sqrt D) for small D. All permanent coordinates obey the near-copy trace/work recurrence, even though the tilt direction changes arbitrarily with the layer.

Store only the TOTAL norm s. Its update uses Section 8's scalar factory and

    s_new=s+delta_norm.

The perpendicular norm r=s-alpha^2 is a local helper, not a new persistent coordinate. This avoids the anchor-alignment and squared-alpha update bookkeeping entirely.

## 10. Physical normalization along a supplied rank-one-tilted path

For an actual finite input set, let u_j(x) be the physical feature vectors, and define

    q_j=max_x ||u_(j-1)(x)||^2,
    h_(j-1)(x)=u_(j-1)(x)/sqrt(q_j).

The local factory returns the new physical feature divided by sqrt(q_j). To obtain h_j, multiply every coordinate by sqrt(q_j/q_(j+1)). This is a scalar copy coefficient, not a new recursive child call.

The existing dimension-free metric-retention estimate for entropy-tilted tanh, applied to a query maximizing q_j and the zero vector, gives

    q_(j+1)>=q_j exp[-C(q_j+sqrt D_j+D_j)].

Consequently the positive logarithmic scalar gain is bounded by

    log^+ sqrt(q_j/q_(j+1))<=C(q_j+sqrt D_j+D_j).

This is charged to the same cumulative budget as the residual factories. Variance resets keep both vector trace and total-norm scalar second moments bounded. Large-D steps may have scalar gains exponential in O(D), which are still compatible with exponential-in-budget resource accounting; their explicit factory constants require a separate fixed-threshold treatment if they are retained.

Thus the small-step real-arithmetic construction has the following provisional path consequence. For arbitrary independently one-dimensional row tilts, arbitrary changing directions, q_j and D_j below fixed small thresholds, total budget

    B=sum_j(q_j+sqrt D_j+D_j),

and polynomial initial scalar resources, the expected complex scalar formula size is bounded by initial resources times exp(CB), with bounded trace/norm moments. The feature Gram kernel is preserved exactly at every step. A bounded readout and a globally positive margin then give an all-input fixed-seed arithmetic classifier by the standard averaging/majority argument.

This is still not the general critical posterior class: a density depending jointly on several Gaussian directions is not in general a product of independent rank-one tilts with the same budget. A polynomial-bit conclusion additionally needs the continuous-coordinate and same-child residual precision completion.


## 11. Completed restricted-path theorem and verification

**Theorem.** Start from the augmented Boolean input u0(x)=(1,x)/sqrt(d), x in {−1,1}^d. At each of H layers choose an arbitrary unit direction a_j in the current real feature Hilbert space, and a scalar law rho_j of finite relative entropy D_j with respect to N(0,1). The row law is a scalar Z_j~rho_j along a_j, independent of a standard isonormal Gaussian on a_j's perpendicular space. Apply ordinary tanh to that linear functional, giving the next L2 feature vector. Directions may change arbitrarily with the layer and need not be anchored to an input.

Let q_j be the maximum incoming physical squared norm on the cube, and put

    B=sum_(j=1)^H [q_j+sqrt(D_j)+D_j].

If a final bounded linear readout v gives signed margin eta>0 for a Boolean target, that target has a majority of rational arithmetic-sign formulas of total size

    poly(d+H+1+||v||/eta) exp(CB),

and logarithmic arithmetic depth in that size. In particular, when H, readout/margin resources, and exp(B) are polynomial in an ambient resource R, the target belongs to nonuniform PNC1, hence L/poly. No description-length, higher-moment, smooth-density, or lower coefficient-size restriction on rho_j is imposed. This is an existence theorem, not an efficient procedure for evaluating or sampling rho_j.

**Large steps.** For physical q<=2 and all D, Sections 2--8 give feature residual trace C(q^2+D), scalar norm residual moment C(q+sqrt D+D)^2, and the rank-one linear perturbation has HS norm |sigma−1|<=sqrt(2D). Below a fixed budget threshold, the rare-branch/reset argument applies. Above it, create the residual outright with degree-k probability 1/k^2, then average polynomially many copies to reset the polynomial-in-budget variance. Physical rescaling has log-gain bounded by C(q+sqrt D+D); its required averaging also costs exp of that budget. Summing logarithmic costs proves the real-formula resource bound. Initial q<=2 and every later physical q<=1, so no unbounded-q case is needed.

**Finite precision.** Inject the tiny independent coordinate-noise floors of `fock-moment-floor-finite-bits.md`, with aggregate budget bounded by a constant over the H stored layers. This preserves all means and adds only a polynomial H factor to the expected-size bound. The detailed theorem `same-child-multilinear-precision.md` then applies to all correlated Poisson subtractions, including the degree-four cosine and degree-two exponential residuals in the scalar norm update. Its fixed-dimensional degree-category algebra preserves the required cancellations. A single global balancing step gives ordinary scalar real formulas; independently expanding every local complex product is not used.

The precision theorem also covers measurable standard-Borel direct-integral coordinates. Only finitely many coordinates and constants occur in a selected seed. RMS normalization and an expected-call-count bound give polynomial logarithmic coefficient magnitude on a positive-probability good seed, without lower bounds on frequencies, kernel entries, scalar probabilities, or original real constants. Polynomial-bit rounding preserves the uniformly margined good groups. Polynomial majority and the established arithmetic-formula evaluation theorem give the stated PNC1 conclusion.

The independent audit `rank-one-entropy-interfaces-independent-audit.md` checks the scalar identities, trace estimates, norm closure, arbitrary-direction construction, large steps, physical scaling and continuous-coordinate finite precision. The source snapshots checked before this organizational completion are recorded there. The complete critical posterior allows more general row tilts and is not covered by this theorem.
