The following record covers the initial capacity and spectral arguments. The [final integrated mean-field and uniform-scale review](meanfield-review.md) gives the current theorem scope and final source hashes.

# Independent review: unified Lipschitz-activation learning argument

Reviewed on 22 October 2026 by an independent AI agent. This is an ordinary mathematical review, not Lean verification.

## Scope reviewed

The manuscript `unified-proof.md` proves a width-independent capacity bound for networks with a fixed globally Lipschitz scalar activation vanishing at zero, a strong-prior learning theorem at every learner width above target width, and a finite-variance theorem for gamma at least two (all gamma at least one with one hidden layer). The capacity estimate permits independently chosen auxiliary Lipschitz activations at different neurons. The learning theorem continues to use the fixed activation and the specified Gaussian prior; the auxiliary class is only a counting device.

## Scalar activation net

The rounding argument is valid. With J=ceil(3R/eta) and Delta=R/J, a zero-at-zero 1-Lipschitz function has rounded adjacent grid values differing by at most two integer units. At most 5^(2J) codes occur. Choosing an actual member from every nonempty code keeps both the exact Lipschitz constant and the value zero at the origin. Within a code the grid-point discrepancy is at most Delta; moving to a grid point costs at most Delta for each function, giving uniform discrepancy at most 3Delta. The inequality log(2M)<=14R/eta holds for 0<eta<=R. No neuron-dependent enumeration factor is hidden here.

## Row collapse and exponential peeling

The enlarged scalar activation class is closed under psi(t) -> psi(rt)/r for r>0. Thus after writing the rows of a Frobenius-norm-one matrix as r_j u_j, each output is r_j times an allowed scalar feature; sum r_j^2<=1 collapses the vector norm to one scalar supremum. Previous normalized feature vectors have Euclidean norm at most R, even with different activation functions at each neuron. Every scalar argument therefore lies in the interval covered by the activation net.

Replacing the selected scalar function by its net representative costs m eta in the Rademacher sum. A union over the net and over the two signs costs a factor 2M in the exponential moment. For each fixed net representative, convex contraction applies to the entire previous feature/direction class. The resulting linear supremum is the previous vector supremum Z_(s-1). Therefore the claimed recurrence E exp(a Z_s)<=2M exp(a m eta) E exp(a Z_(s-1)) holds. Its factor is per layer, not per neuron.

At depth zero, E Z_0<=R sqrt(m). The bounded-difference moment bound has exponent a^2 m R^2/2 because changing one Rademacher sign changes the norm by at most 2R. Iteration and optimization give the stated bound. With eta=R m^(-1/3), the coefficient 1+H+sqrt(28H) is at most 8H for H>=1. Thus the Rademacher estimate has exactly the asserted m^(-1/3) rate. On a fixed finite sample the Rademacher probability space is finite, so suprema cause no measurability problem; finite approximations give the contraction argument when needed.

## Normalization and norm counting

For nonzero layer Frobenius norms m_s, q_s=lambda^s product_(j<=s)m_j gives h_s/q_s = psi_s((W_s/m_s)(h_(s-1)/q_(s-1))), where psi_s(t)=phi(m_s q_(s-1)t)/(lambda m_s q_(s-1)). This identity is exact without homogeneity. Each psi_s is 1-Lipschitz and zero at zero. A zero matrix gives identically zero output under the zero-at-zero assumption. The linear readout leaves an overall factor lambda^H times the physical product of all layer norms.

The weighted energy-to-product estimate is algebraic and independent of activation homogeneity: multiplying the squared weighted layer norms gives d times the squared physical product, and AM-GM supplies P<=d^(-1/2)(kappa/L)^(L/2). Shattering at strict output margin 1/2 requires empirical Rademacher complexity at least 1/2. The displayed cubic ceiling v(K) follows. Sauer's lemma then bounds the number of full-cube Boolean functions by (2^d+1)^v, including when v exceeds the domain size. The counted auxiliary class is common to every learner width.

## Target cloning and strong-prior comparison

Cloning k=floor(N/C) times and zero-padding preserves the original fixed-activation function exactly. First-layer energy does not increase, internal energy is unchanged, and weighted readout energy grows by less than two. A width-C teacher with individual weights at most C therefore has energy at most B=d(d+1)C^2+LC^4 at every N>=C. Unlike ReLU balancing, this argument does not pretend to rescale the fixed GELU activation homogeneously.

A function whose minimum energy is no larger than the target has a strict-margin representative below B+1, even if its infimum is not attained. Continuity makes each finite-cube margin event open. The ordinary finite-dimensional Gaussian rate lemma applies. The finite number of Boolean functions permits summing the exceptional relative masses, and target consistency bounds every posterior denominator from below by target prior mass. One small enough variance at each fixed width controls every later noiseless history. The same finite-class sample event applies to all widths; the variance threshold need not be uniform in width. Tied minimum-energy functions stay inside the retained class.

## Finite-variance extension

The scaled variables g_s=h_s/sqrt(N), g_0=xbar/sqrt(d), U_1=sqrt(d/N)W_1, U_s=W_s internally, and U_L=sqrt(N)v give the exact recursion g_s=phi_N(U_s g_(s-1)), phi_N(t)=phi(sqrt(N)t)/sqrt(N), z=U_L g_H. Every phi_N remains lambda-Lipschitz and zero at zero. This identity supplies the uniform perturbation bound; it does not require fixed-activation homogeneity.

Doubling the teacher readout before cloning gives weighted energy at most K0=4B. A combined perturbation of radius r changes all outputs by at most sqrt(2L)lambda^H r(sqrt(K0)+1)^(L-1), by telescoping and Cauchy-Schwarz. The selected radius leaves strict target margins throughout the target ball.

There are p=N(d+2)+(L-2)N^2 weighted Gaussian coordinates. At gamma>=2, p sigma^2<=d+L and sigma^2<=1. For L=2 the same inequalities already hold at gamma>=1. The cube probability lower bound, followed by the Gaussian density ratio for the target shift, gives the stated width-independent B0; the parameter dimension appears only through p sigma^2, including inside the logarithm. The chi-square exponential moment gives the stated T and posterior high-energy mass at most epsilon/2. The common low-energy capacity class finishes the proof.

## Conclusion

No mathematical defect was found in the reviewed claims. The encompassing activation condition is natural and includes exact GELU and ReLU, but the theorem is polynomial only at fixed depth; its explicit lambda^H and energy exponents do not prove polynomial depth. The original all-input output-margin support restriction is substantive. The broad finite-variance proof reviewed here does not cover deep 1<=gamma<2. Further sections or stronger results require their own review.

Reviewed proof-note SHA-256: `baf6035ec30b20418babaab02fa8d6bcacffdbddf9294524fab045d37840d10e`.

## Exact GELU Boolean-gate compilation (additional checked lemma)

For exact GELU phi(t)=t Phi(t), set tau=Phi(1), s=2tau-1, A=tau/s, and B=(1-tau)/s. Since tau>2/3, A<2 and B<1. The identity A phi(u)+B phi(-u)=ReLU(u) is exact at u=-1,0,1: the values at +1 and -1 are respectively [tau^2-(1-tau)^2]/s=1 and [-tau(1-tau)+(1-tau)tau]/s=0. At zero both features vanish.

A layered NOR/COPY/NOT Boolean circuit therefore has an exact same-stage GELU implementation using a pair of features phi(u),phi(-u) per gate and composing the two-term decoder into the next layer's incoming weights. NOR preactivations 1-a-b lie in {-1,0,1}; COPY and NOT use subsets of that set. A single constant feature phi(1)=tau is propagated with coefficient 1/tau. Each ordinary gate row has coefficients of magnitude at most A and B, or at most 2A and 2B for a repeated NOR input, all below four. The final sign output 2a_out-1 uses coefficients 2A,2B and -1/tau, also bounded by four. Initial Boolean bits (1+x_i)/2 are substituted into the first-layer affine rows.

If C counts the constant circuit wire, at most 2C-1 GELU neurons are needed per layer; padding gives width 2C. For the convention requiring individual weights bounded by the stated width, max(4,2C) is a uniform safe complexity bound. A circuit given in another gate basis first needs its counted NOR/COPY/NOT compilation. This lemma concerns exact teacher existence; it does not by itself prove internal-noise robustness or polynomial depth.

## Spectral extension to every fixed gamma greater than one

Independently reviewed `../allgamma/spectral-extension.tex` as a separate proof fragment.

The target-cylinder construction is valid for every lambda-Lipschitz activation vanishing at zero, including unbounded ones. Balanced clone sizes have ratios at most two. Cloning preserves the exact teacher function; its internal operator norm is at most sqrt(2) C^2 and its readout satisfies sqrt(N)||v_*||<=3sqrt(2)C^2 after tripling output. The displayed M bounds every teacher hidden coordinate. The constrained first-layer, group-projected internal, and readout coordinates are independent variance-t^2 Gaussian coordinates, with ND0 total coordinates and squared centers bounded by NB0. Their unconstrained internal orthogonal complements annihilate teacher states and have operator norm at most bt simultaneously with probability at least one half.

The normalized RMS error recurrence correctly uses the bounded teacher states while allowing perturbed states to be unbounded. In particular the free matrix acts only on the propagated error, and its operator norm controls that error. The induction bound e_(L-1)<=rho E and the readout error estimate give uniform output error at most 1/4. The one-dimensional Gaussian interval estimate follows from (|a|/t+rho)^2/2<=a^2/t^2+rho^2. Multiplying it and the free-matrix event gives the announced exp(-A N^gamma/2) lower mass, with every factor polynomial in fixed-depth teacher resources.

The Gaussian spectral tail follows from distance to the operator-norm ball of radius a/2. This ball has Gaussian mass above one half when a>=8 sigma sqrt(N). Its Frobenius distance equals the Euclidean norm of the singular-value excesses above a/2, and retained singular values above a have Frobenius norm at most twice that distance. Gaussian isoperimetry therefore gives the asserted exp(-K/(8sigma^2)) tail. The first- and last-layer chi-square tails also have the stated constants: for u>=8D, using the moment at 3/8 gives P(chi_D^2>u)<=exp(-3u/8+D log2)<=exp(-u/4).

Outside the aggregate exceptional event, first and readout weighted energies are at most K and retained internal Frobenius energies at most K. The original internal operators are at most sqrt(K)+a. Thus normalized original states satisfy M_s<=sqrt(2K)lambda^s(sqrt(K)+1)^(s-1), and the discarded-part error obeys the claimed recurrence and its explicit bound. The selected a_K gives output discrepancy strictly below 1/8. Doubling the truncated readout restores margin greater than 3/4 at energy at most (L+3)K. This proves a bound on total raw mass of all uncompressible functions, not just a per-function bound.

The large-width posterior comparison and finite-class bound follow. At smaller widths, target prior mass gives the direct expected bad-posterior-mass bound and Markov's inequality. The current displayed budget proves the claimed width-independent numerical guarantee for each fixed width. A single sample event for every width at a fixed gamma requires one additional finite union over N<T; replacing the logarithmic term by log(4T/(epsilon delta)) is sufficient and preserves polynomial dependence. This distinction was communicated to the authors for the unified final statement.

No mathematical defect was found in the fixed-gamma-greater-than-one extension. Its width threshold has powers 1/(gamma-1), so it neither covers gamma=1 nor is uniform as gamma approaches one.

## Final merged manuscript audit

The merged manuscript `source/paper.tex` and its included `source/spectral-extension.tex` were checked together on 22 October 2026. This final audit covers the complete written arguments, including their constants, notation, and theorem quantifiers. The earlier staged scope limitations above describe the initial proof note, not the final combined result.

The final claims are valid as written: every fixed globally Lipschitz activation vanishing at zero has the stated width-independent, fixed-depth polynomial learning bounds in the strong-prior limit and at each fixed exponent gamma>1. At depth L=2, the direct weighted-energy argument also includes gamma=1. The exact same-depth GELU compilation gives the claimed factor-two width overhead with coefficients bounded by four. Unrestricted deep gamma=1 remains outside this manuscript's claims.

The all-gamma theorem now uses log(4T/(epsilon delta)), correctly accounting for its simultaneous all-width event. Its large-width event is a single common finite-class event, and the fewer than T smaller widths each receive failure probability delta/(2T). The strong-prior theorem likewise has a common sample event but width-specific variance thresholds. The final proofs consistently bound posterior average error rather than silently replacing the posterior by a minimum-energy predictor.

The explicit one-coordinate convex contraction proof is valid: the pair of suprema after contraction is weakly majorized by the original pair, and convex nondecreasing functions preserve the sum inequality. The nonhomogeneous normalization, finite-dimensional Gaussian rate comparison, and shallow weighted-coordinate identities are all exact. No implementation-level numerical checks are needed for these symbolic arguments. This review is mathematical AI-agent review, not proof-assistant verification.

Reviewed final source SHA-256 values:

- `source/paper.tex`: `ef66a4cd79339ce4a2ff8c40dcf934181a9dc5368ca4dd99b3fce29740670f96`
- `source/spectral-extension.tex`: `b015092b62179be58f7b94fa3e3d293df08fda5dc3b6840a87590aec8e0fcc97`
