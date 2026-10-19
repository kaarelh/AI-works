# Independent audit: a Taylor-degree hierarchy for a one-hidden-layer prior

19 October 2026. This is an independent mathematical check, not a Lean proof.

**Verdict:** the proposed raw-prior asymptotic is correct under the stated fixed-domain and fixed-exponent assumptions. No fatal gap found. The interpretation must say *odd-rounded polynomial threshold degree*, and the theorem alone is not a sample-complexity classification.

## Exact formulation

Fix an integer d >= 1, constants c1,c2 > 0, and real exponents a > b > 1. Let

    z_N(x) = sum_{i=1}^N v_i tanh(w_i · (x,1)),

where all coordinates are independent, each coordinate of w_i has variance c1 N^{-a}/d, and v_i has variance c2 N^{-b}. For a Boolean function f on {−1,1}^d, let r(f) be its real polynomial threshold degree: the least degree of p such that f(x)p(x)>0 everywhere. Let k be the least positive odd integer at least r(f). Then, for

    A_f = {f(x)z_N(x)>1/2 for every cube input x},
    rho = (ka+b)/(k+1),

there are constants 0<c<C<infinity and N0, depending on the fixed data, such that for N>=N0,

    exp(−C N^rho) <= P(A_f) <= exp(−c N^rho).

In particular log(−log P(A_f))/log N tends to rho.

## Lower bound on the necessary Gaussian energy

Use the unhalved normalized energy

    E_N = (d/c1)N^a ||W||_F^2 + (1/c2)N^b ||v||_2^2.

Its law is chi-square with M=N(d+2) degrees of freedom. Let T_{k−2} be the odd Taylor polynomial of tanh through degree k−2, taking T_{−1}=0. The bound

    |tanh(u)−T_{k−2}(u)| <= C_k |u|^k

actually holds for all real u: use Taylor's theorem on |u|<=1 and boundedness of tanh plus the lower degree of T outside that interval. Thus no separate small-preactivation assumption is needed for this direction.

The polynomial q(x)=sum_i v_i T_{k−2}(w_i·(x,1)) has degree at most k−2. Uniformly over the cube,

    |z_N(x)−q(x)|
      <= C_{d,k} ||v||_2 (sum_i ||w_i||_2^{2k})^{1/2}
      <= C_{d,k} ||v||_2 ||W||_F^k
      <= C E_N^{(k+1)/2} N^{−(ka+b)/2}.

If E_N<c N^rho, with c sufficiently small, this error is strictly below 1/2. On A_f it follows that f(x)q(x)>0 everywhere. This contradicts r(f)>k−2. For k=1 it simply says that the zero polynomial cannot have the required positive signs. Therefore A_f requires E_N>=c N^rho.

Since rho>b>1, M=o(N^rho). The chi-square moment generating function at 1/4 gives

    P(E_N>=c N^rho) <= exp(−c N^rho/4) 2^{M/2}
                      <= exp(−c' N^rho).

This proves the probability upper bound. Dependence on f is harmless because the domain and f are fixed before N tends to infinity.

## A finite-neuron construction attaining the energy exponent

Choose a sign-representing p with f(x)p(x)>=2. Homogenize p to homogeneous degree k in the d+1 augmented variables using the constant coordinate. Every homogeneous degree-k real polynomial is a finite linear combination of k-th powers of real linear forms, by polarization. Hence

    p(x) = sum_l alpha_l (u_l·(x,1))^k.

Write k=2s+1. Choose s+1 distinct positive numbers lambda_j. A Vandermonde system gives coefficients beta_j cancelling the tanh Taylor coefficients at degrees 1,3,...,k−2 and normalizing degree k to one. This uses the fact that every odd Taylor coefficient of tanh is nonzero. Uniformly on the finite cube,

    t^{-k} sum_j beta_j tanh(lambda_j t u_l·(x,1))
       = (u_l·(x,1))^k + O(t^2).

The resulting network uses a fixed finite number of neurons; pad the rest with zeros. Its input weights are O(t), readout weights O(t^{-k}), and its output tends uniformly to p. Put

    t=N^{-eta},  eta=(a−b)/(2(k+1))>0.

Then its energy is at most a constant times

    N^a t^2 + N^b t^{-2k} = 2 N^rho,

and it lies strictly inside A_f for all sufficiently large N.

## Turning the construction into prior mass

Take a coordinate box of radius h=N^{-q} around this center, including around the zero inactive parameters, with q a sufficiently large fixed constant. The active output perturbation is O(h t^{-k}+h); the inactive neurons contribute O(Nh^2). Thus q>k eta and q>1/2 ensure a uniformly vanishing output perturbation. Choose q larger still so that

    N^{a+1}h^2 + N^{b+1}h^2 = O(N^rho).

Every point in the box then remains in A_f and has Gaussian energy O(N^rho), using the squared-norm triangle bound. The box volume and Gaussian normalization contribute only O(N log N) to the negative log probability. Since rho>1 this is lower order, and the box probability is at least exp(−C N^rho). This completes both sides.

## Interpretation and limits

1. The hierarchy groups r=0 and r=1 together, r=2 and r=3 together, and so on. It must not be described as recovering the exact threshold degree.
2. The constant input coordinate is material to homogenization. The model should explicitly include it, as above.
3. This is a fixed-d, N-to-infinity theorem. Its unspecified constants and neuron threshold are not uniform in growing d, degree, or the target implementation size.
4. This proves a distinct prior-ordering mechanism: if two functions have different odd-rounded degrees, the higher-degree function has asymptotically much smaller raw prior mass on the logarithmic scale. Equal rounded degree leaves leading constants and lower-order structure unresolved.
5. Conditioning on the global margin does not change the ratio of the prior probabilities of two sign functions. The theorem therefore also supplies their ordering in the globally margined prior. For an individual normalized probability the common denominator must still be included; one should not repeat the raw Θ exponent indiscriminately for the minimum-degree class.
6. It does not by itself prove an intermediate learning rate or disprove a coarse dichotomy in worst-case sample complexity. A posterior prediction theorem would still need to control all interpolating sign functions and their weights.

## Exact public-source check

I separately read and approved the full public proof note, including its posterior-concentration consequence and even-dimensional full-parity corollary, at this SHA-256:

    00f8b4a460bc5f977f7d92c57ce43edf1618fed1cac1317d971b1dfa2463c797
    neural-network-generalization/works-in-progress/scaling-tuples/README.md

The parity corollary is sound. For g other than parity and its negation, positive weights s_x can cancel the top Fourier coefficient of g(x)s_x. The interpolating multilinear polynomial then has degree at most d−1. When d is even, its odd-rounded degree is at most d−1, whereas parity's is d+1, giving a strict prior exponent separation. Posterior concentration on the least rounded degree follows by a finite union over sample-consistent sign functions on the fixed cube.

I also checked Question 9 of the FAQ at SHA-256:

    922f23398cfe402393238fd31bba452c7bf53adedf87c38e7ab3c5ce5bdd81ee
    neural-network-generalization/TECHNICAL-FAQ.md

The proved statements there match the note and retain the necessary fixed-domain, width-first, nonuniformity, and non-learning-theorem qualifications. The frozen-feature and larger circuit-learning regions are explicitly conjectural; this approval does not turn those scaling estimates into theorems. In particular, the tentative sparse-population construction still lacks control of inactive neurons and competing posterior functions, exactly as the text states.

