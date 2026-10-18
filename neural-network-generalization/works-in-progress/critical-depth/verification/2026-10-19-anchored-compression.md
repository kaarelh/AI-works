# Finite critical-path compression by exact anchor preservation

**Active proof draft.** This seeks an actual finite-width realization, with arbitrary finite real weights. No product-norm bound is claimed or needed for a subsequent tanh VC argument.

## Proposed theorem

Let X={-1,1}^d. A depth-L critical path (H=L-1 hidden transitions) has entropy costs D_j, readout action r, total action A=sum D_j+r, and output z with fz>=1/2 everywhere. Put S=sum sqrt(D_j) and assume A>=1 by replacing A by max(A,1). Then f has a depth-L tanh network realization, with uniform margin >=1/4, width

n <= poly(d,H,A) exp(C S),

where the polynomial degree and C are universal. Weights are finite real numbers with no quantitative bound asserted. More generally the output uniformly approximates z to error <=1/4. For a near-baseline path, the previous square-root entropy theorem gives n<=poly(d,H,A) exp(C sqrt(H epsilon)).

## 1. Select a common finite anchor set

For the original controlled preactivation law rho_j with Gaussian reference N(0,Q_{j-1}), define

I_j(T)=KL((rho_j)_T || N(0,Q_{j-1,TT})).

These quantities are monotone under inclusion and <=D_j. If the conditional KL at some coordinate x given T exceeds delta, then adding x increases I_j by >delta, by the exact entropy chain rule. A greedy search over all j,x thus selects at most (sum D_j)/delta anchors before every one-coordinate conditional entropy is <=delta. Adding anchors can change these conditional entropies, so recheck all of them; the monotone total sum_j I_j bounds the number of additions.

Also let h_x be the terminal feature vector in its Hilbert realization, and let u represent the readout, ||u||^2=2r. Enlarge T whenever |<u-P_Tu,h_x>|>t, where P_T projects onto span{h_a:a in T}. Each addition increases ||P_Tu||^2 by >t^2 because ||h_x||<=1. Continue both greedy searches together. The potential sum_j I_j(T)+(delta/t^2)||P_Tu||^2 shows

|T| <= (sum D_j)/delta+2r/t^2.

At termination all conditional one-query entropies are <=delta, and the projected readout z_T(x)=<P_Tu,h_x> approximates z uniformly to t. Its RKHS norm remains <=sqrt(2r). It is a finite linear combination of the kernel sections at T; its coefficients need not have bounded l1 norm.

## 2. The anchored query distance

For kernels K,K' with **exactly the same TT block**, define

u_K(x)=K_TT^{+1/2} K_Tx (on the range of K_TT),
sigma_K(x)^2=K_xx-||nu_K(x)||^2,

d_T(K,K')=max_x sqrt( ||nu_K(x)-nu_K'(x)||^2 +(sigma_K(x)-sigma_K'(x))^2 ).

This is the minimum RMS discrepancy between the two Gaussian coordinates at x when their Gaussian anchor vectors are coupled identically, followed by the maximum over x. Each query may use its own coupling. It is a pseudometric on kernels with the fixed anchor block and satisfies the triangle inequality. It ignores covariances between non-anchor queries, which are unnecessary for the following controlled transitions and final readout.

A second-moment coupling version holds: if for each x there is a joint law of (H_T,H_x,H'_x), with the prescribed feature marginals and identical anchor feature vector, then d_T(K,K') <= max_x(E|H_x-H'_x|^2)^(1/2). Take the uncentered second-moment matrix as a centered Gaussian covariance, as in the previous Bures lemma. Nonzero means cause no problem.

## 3. Rao–Blackwellize each original control

Replace rho_j by rho_j^T having the same anchor marginal, but the Gaussian reference conditional law given G_T elsewhere. Its density relative to N(0,Q_{j-1}) depends only on G_T; its entropy is I_j(T)<=D_j. Its feature TT covariance is exactly the original Q_{j,TT}.

At any query x, conditional Gaussian T2 given G_T couples the original G_x to the Rao–Blackwellized G'_x with identical G_T and

E|G_x-G'_x|^2 <=2 Var_reference(G_x|G_T) * conditional_KL_x <=2delta,

because Q_{j-1,xx}<=1 for j>=2. At j=1 the original input diagonal is <=2, so use 4delta. Tanh is 1-Lipschitz and the second-moment observation gives an injected d_T error <=2sqrt(delta). This comparison is between the original output covariance and the output of its T-measurable control at its original input covariance.

## 4. Propagate T-measurable controls

Suppose K_TT=K'_TT and the density w(G_T) is fixed, integrating to one under that common Gaussian anchor law. Couple the reference Gaussian anchor vectors identically, and at query x use the optimal scalar conditional Gaussian coupling. Tilt this joint law by w(G_T). BOTH marginals now have exactly the intended T-measurable control, and the new feature TT blocks remain equal.

The joint tilt has entropy D_T=KL(controlled anchor law||Gaussian anchor law). Whitening its joint Gaussian and Gaussian T2 imply, for each scalar difference,

(E_tilt |G_x-G'_x|^2)^(1/2) <=(1+sqrt(2D_T))(E_reference |G_x-G'_x|^2)^(1/2).

After tanh and Gaussianization,

d_T(F_w(K),F_w(K')) <=(1+sqrt(2D_T)) d_T(K,K').

This avoids the earlier full-covariance rank obstruction: only the anchor vectors must be coupled jointly, while each query uses a different extension. The common density depends exclusively on anchors, so the resulting candidate law is independent of the chosen query.

## 5. Finite quadrature with exact anchor covariance

**Central lemma requiring independent audit.** Given any probability law nu on [-1,1]^X with covariance/second moment K and anchor set T of size q, and 0<eta<=1/8, there exist n<=C(q+1)^4 eta^{-2}[d+log(q+2)+1] sampled feature vectors h_i from nu and a positive definite matrix B on their weighted coordinate space such that the finite kernel K' has K'_TT=K_TT exactly and d_T(K,K')<=6sqrt(eta). This is a covariance factorization absorbed into the next incoming weight matrix; it introduces no extra nonlinear layer.

Proof details:

Let s=rank K_TT<=q, and write K_TT=U Lambda U^T on its range. Set a(h)=Lambda^{-1/2}U^T h_T, so E aa^T=I_s and h_T=U Lambda^{1/2}a almost surely. Sample h from the importance law p(h)nu(dh), where p(h)=(1+||a(h)||^2)/(s+1). Thus p>0, E_nu p=1, and both ||a/sqrt(p)|| and |h_x|/sqrt(p) are <=sqrt(s+1).

For n independent samples, put E_{i,:}=a(h_i)^T/sqrt(n p_i), and F_x=(h_i(x)/sqrt(n p_i))_i. Let M=E^TE, vhat_x=E^TF_x, khat_x=||F_x||^2. Hoeffding and a union bound over at most s^2+s*2^d+2^d entries imply that the stated n suffices for a realization with

||M-I||op<=eta,
max_x ||vhat_x-v_x||<=eta, where v_x=E_nu[a(h)h_x],
max_x |khat_x-K_xx|<=eta.

Define B=I_n+E(M^{-2}-M^{-1})E^T. This is positive definite: it acts with eigenvalues lambda^{-1} on the singular directions of E having Gram eigenvalues lambda, and as identity on their orthogonal complement. In particular ||B||op<=2. Define K'_xy=F_x^T B F_y.

Writing C=Lambda^{1/2}U^T, F_T=EC, so K'_TT=C^T E^TBE C=C^TC=K_TT. The normalized anchor cross vector is v'_x=M^{-1}vhat_x. Since ||v_x||<=1,

||v'_x-v_x||<=4eta,
|K'_xx-K_xx|<=10eta.

The latter follows from K'_xx=khat_x+vhat_x^T(M^{-2}-M^{-1})vhat_x, ||M^{-2}-M^{-1}||<=4eta, and ||vhat_x||<=1+eta. Consequently the conditional residual variances differ by at most 26eta, and

d_T(K,K')^2 <=16eta^2+26eta<=28eta<36eta.

When s=0, take p=1, E empty, B=I; only the diagonal estimate is needed.

## 6. Realize the entire finite network

Start with the exact original linear input covariance Q_0. At layer j, apply its original T-measurable density w_j on the finite reference Gaussian field built from the preceding stored neurons and covariance factor B_{j-1}; its anchor block matches Q_{j-1,TT} exactly, so the density is normalized exactly. Sample finitely many incoming Gaussian rows from this controlled law with the leverage importance weights above. Their activated outputs are ordinary tanh neurons. Set the next covariance factor B_j by the exact-anchor correction.

The factors F_i include sqrt(1/(n p_i)), and B_i^{1/2} is absorbed into the next layer's incoming weights. This changes weight distributions, which is harmless: the result is a deterministic finite-network representation, not a new prior. All weights are finite almost surely. No density upper bound or numerical weight bound is required.

At each layer compare: original control -> its Rao–Blackwellization (error <=2sqrt(delta)); propagated candidate control (factor <=1+sqrt(2D_j)); finite quadrature/correction (error <=6sqrt(eta)). All kernels have exactly the same original TT block. With delta=eta, the final distance is at most

8H sqrt(delta) prod_j(1+sqrt(2D_j)) <=8H sqrt(delta) exp(sqrt(2) S).

The projected readout uses only anchors. Since that block is exact, the same coefficient vector gives a candidate output with error at most sqrt(2r) times this distance. Including the projection error t gives

||z-z_finite||infinity <=t+8sqrt(2r)H sqrt(delta) exp(sqrt(2)S).

Take t=1/16 and

delta=eta=[256 H sqrt(max(2r,1)) exp(sqrt(2)S)]^{-2}.

Then total error <=1/16+1/32<1/4. The number of anchors is <=A/delta+512r, and the quadrature width above is poly(d,H,A) exp(C S). Padding layers to a common width does not change the function. Since the original margin is 1/2, the finite output has margin >1/4.

## What needs auditing

1. Exact anchor preservation and the conditional Gaussian coupling metric, especially singular anchor blocks.
2. The greedy anchor selection with simultaneous entropy and readout objectives.
3. The importance quadrature and PSD correction: it must be absorbed into incoming weights without changing depth.
4. VC/counting for finite-width tanh networks with arbitrary real weights (assigned to a separate agent).

If these all hold, this is the missing finite-representation bridge, although it does not prove the original product-norm conjecture.
