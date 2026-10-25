# The analytic counterexample can have every derivative globally bounded

25 October 2026. Corollary with a final amplifier improvement proposed by the root agent. This modifies the already published analytic-activation-depth-lower construction. It remains computationally contrived and does not concern exact tanh. Allowing amplifier weights of order d preserves the exp(cL) lower bound while making every derivative globally bounded.

## Statement

Fix any finite r>=1 and eta>0. There is one computable odd real-analytic activation phi with range (-1,1), derivative one at zero, global Lipschitz constant one, strict increase and strict concavity on the positive half-line, such that:

* every derivative of phi is globally bounded;
* ||phi-tanh||_(C^r(R))<eta;
* the circuit-hard Boolean targets f_d from the published paper have globally margined teachers of depth L_d=d+4, active width O(log(d+2)), coefficient magnitude O(d+1), and polynomial coefficient bit length;
* the published every-sample lower bound 139/1024 on posterior 2/3-confidence failure persists for every sample of size at most exp(cd), both in the cold fixed-width limit and in all fixed-gap Gaussian scalings above mean field, and at the actual critical scale with the same type of exponential-in-d learner-width threshold.

Thus the sample lower bound is exp(Omega(L_d)). The result gives an exponential-depth counterexample even after requiring all derivatives to be bounded. It does not claim a uniform analytic strip, a uniform Gevrey bound, or efficient activation evaluation.

## 1. Bands with a growing decay and decoder order

Keep the computable circuit-hard truth tables f_d and centers from the published paper. Choose a sufficiently large fixed integer M_0, say M_0>=24, and define

    m_d=M_0+ceil(log_2(d+2)),
    J_d=2^(m_d+10),
    Delta_d=2^(-d-4),
    r_d=Delta_d/J_d,
    c_(d,k)=-4d-1/4-Delta_d k,       0<=k<2^d,
    delta_d=tau r_d 2^(-(m_d-3)d)
            =tau 2^[-(m_d-2)d-m_d-14].

For a fixed sufficiently small positive rational tau put

    S(u)=sum_d sum_k delta_d f_d(k)(u/c_(d,k))^3
                              exp[-((u-c_(d,k))/r_d)^2],
    phi(u)=tanh(u)+S(u)-S(-u).

The widths remain exponentially small, while the amplitudes now decay like exp(-Theta(d log d)). All choices form one fixed computable activation, not a dimension-dependent activation sequence.

## 2. Shape, analyticity, and globally bounded derivatives

The same Gaussian lattice estimate as in the published proof gives, for each fixed derivative order j,

    sup_R |S_d^(j)|
       <= C_j tau (16J_d)^(j-1) 2^[-(m_d-j-2)d].       (1)

The right side is summable over d for every fixed j, because m_d grows like log_2 d and J_d=O(d). Thus every derivative is globally bounded. The series is locally uniformly convergent on every complex compact: moving band centers and Gaussian suppression dominate both the number 2^d of centers and every amplitude prefactor. Therefore S is entire and phi is real analytic.

The weighted first- and second-derivative arguments remain valid uniformly. Their band majorants are, respectively,

    C tau exp(8d) 2^[-(m_d-3)d],
    C tau J_d exp(8d) 2^[-(m_d-4)d].                  (2)

Both are summable, with all near-zero factors supplied by the same cubic prefactor. Choosing tau small gives the published relative bounds against sech^2 u and |tanh''u|. They preserve oddness, phi'(0)=1, strict increase, slope at most one, positive-half-line strict concavity, and saturation to +/-1. Equation (1) also makes the prescribed C^r difference arbitrarily small after reducing tau.

The uniform derivative bounds have constants depending on j; no common analytic-type growth estimate in j is asserted. Effective band tails and computability of the tables give computability of phi exactly as before.

## 3. A growing but inexpensive finite-difference decoder

For dimension d use

    h_d=Delta_d/(2m_d),
    F_d(u)=sum_(j=0)^(m_d) (-1)^j binom(m_d,j) phi(u+jh_d).

At u=c_(d,k), the central bump contributes delta_d f_d(k). Every off-center query is at least h_d from every same-band center. Since J_d=2^(m_d+10), the same-band error after multiplying by the coefficient sum 2^(m_d)=O(d) is o(delta_d).

For other bands e!=d, the amplitude ratio has logarithm O(d log d+e log e), while the Gaussian suppression contains -c(d-e)^2 4^e J_e^2. Split e<=d/2, d/2<e<d, and e>d. In the first part, even the smallest fixed e gives a negative quadratic in d, dominating d log d; the second part has suppression exp(-c4^(d/2)); in the third part the amplitudes already decrease and the Gaussian tail is stronger. Reflected bands are farther away. The coefficient sum O(d) does not change these conclusions.

For the tanh background, the negative-half-line series gives, for large d and m=m_d=O(log d),

    sup_(u<=-4d+1) |tanh^(m)(u)| <= C 2^m exp(-8d+2).

Indeed the series is bounded by 2^(m+1)sum_(n>=1)n^m exp[-(8d-2)n], whose first term dominates because m=o(d). Thus the m-th forward difference is at most

    C Delta_d^m m^(-m) exp(-8d).

Dividing by delta_d gives at most

    C tau^(-1) 2^(-2d-3m+14) m^(-m) exp(-8d),

which tends to zero. Consequently F_d(c_(d,k))=delta_d[f_d(k)+o(1)] uniformly in k.

The first teacher layer evaluates these m_d+1 points. Its coefficients have polynomial bit length and magnitude O(d); the next layer uses binomial coefficients at most 2^(m_d)=O(d). Set the scalar amplifier gain a_d=2^(m_d-2)=Theta(d). Because

    delta_d=tau 2^[-(m_d-2)d-m_d-14],

one has the exact identity delta_d a_d^(d+1)=tau 2^(-16)=:rho. Use d+1 amplification layers. The ideal preactivation amplitudes form a geometric sequence with sum at most 2rho, since a_d>=2. The estimate |phi(u)-u|<=2u^2 therefore gives the same uniform O(rho) relative-error bootstrap, independently of the growing gain. All actual preactivations stay below 2rho after choosing tau small, and a fixed readout 2/rho gives margin greater than one. There are one query layer, one difference-combination layer, d+1 amplifier layers, and the readout: L_d=d+4. The amplifying weights still satisfy O(d). Rounding to O(d log d) bits preserves the margin because the total propagation gain is exp(O(d log d)).

## 4. Cold and fixed-gap posterior bounds

The low-product hard-table threshold remains exp(ad), with the same universal capacity proof. Since L_d=d+4, the original fixed-gain memorizer applies. Set

    q_mem=exp(a/100),
    alpha=c_0(q_mem-1),

with the same sufficiently small fixed c_0 as in the original relative-error bootstrap. These are fixed constants, and

    q_mem^(L_d)=exp(ad/100+O(1)).

The first scalar memorizer energy remains at most one: its decaying factor q_mem^(-2(L_d-2)) is exp[-ad/50+O(1)], while the cloned initial readout has logarithm at most 3cd+O(log d). Choose c<a/1000 as before. The accumulated nonlinear relative error remains O(alpha/(q_mem-1)), hence uniformly small.

Its total energy is now

    K_d<=q_mem^2 L_d+O(1).                           (3)

AM–GM therefore gives a unit-margin Frobenius product at most

    exp[ad/100+O(1)] <= exp(ad)

for all sufficiently large d. This supplies the same circuit-hardness/Gibbs-error lower argument in the cold limit.

The fixed-gap finite-width proof is unchanged. Its inverse perturbation tolerance is exp(O(d)), and the Gaussian bulk terms are polynomial in d,L_d. Thus N>=exp(C_zeta d) suffices for every fixed zeta>0, uniformly over sample sizes at most exp(cd), exactly as in the published comparison argument. The resulting sign-function hardness and 139/1024 confidence-failure bound are unchanged.

## 5. The critical branch

The critical appendix requires the same shape assumptions, a sufficiently small weighted perturbation, and bounded derivatives through order five. Sections 1–2 supply all of them. Its scalar-potential, memorizer-target-mass, canonical-circuit, and actual finite-width statements therefore remain available with constants depending on this fixed activation.

For L_d=d+4 and n<=exp(cd), the depth condition L_d>=C log(d+n+L_d) holds for large d after reducing c. The posterior circuit ceiling is polynomial in d+n+L_d; a further reduction of c makes this at most 2^(d/4). Its width threshold 2^(Cd)(d+n+L_d)^C is still at most exp(C'd). Thus the every-sample critical-scale lower bound persists.

## Scope

This corollary removes the unbounded-high-derivative feature of the original construction. It does not remove its computational coding: inverse-exp(O(d log d)) activation accuracy decodes truth tables requiring exp(Omega(d)) Boolean gates. A polynomial-size evaluator is still impossible.

The increasing teacher amplifier gain is essential to the strengthened rate: weight-two amplifiers would use Theta(d log d) layers, but weights of order d are already allowed by the teacher's resource bounds and reduce this to d+1 amplification layers. No statement for tanh, ReLU, GELU, or a standard efficiently evaluable activation follows.
