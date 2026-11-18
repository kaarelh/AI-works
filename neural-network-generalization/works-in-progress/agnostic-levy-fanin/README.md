# Fast agnostic learning with infinitely divisible neural-network priors

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

One fixed dense Bayesian neural network achieves **expected risk at most the best smaller network risk plus a remainder of nearly 1/n**, with coefficient exactly one. The predictor is the ordinary final posterior mean using all observations, and the constants are uniform over every finite learner width above comparator width. The hidden activation can be any fixed globally Lipschitz function, including ReLU, GELU, tanh, sigmoid, softplus and SiLU. A final bounded link such as tanh or clipping is part of the main Gaussian observation model.

The prior has independent, absolutely continuous weight coordinates with full support and no atom at zero. There is no prior over architectures, network sizes or sparsity patterns. A fan-in-F coordinate has the law of a time-1/F increment of one fixed symmetric Lévy process, with jump density

    nu(dx) = c / (|x| * (1+|x|)^p) dx,    p > 2.

The same coordinate family is used in every layer. Its dependence on fan-in is through the increment time; it is not a scalar rescaling of one fixed density. A named alternative uses independent differences of Gamma(c/F, 1) variables, the symmetric variance-gamma family. An explicit-density alternative uses a random sign times BetaPrime(c0/F, p); it has the same logarithmic coefficient-cost and learning guarantees, without requiring a Poisson construction.

With fixed Gaussian likelihood variance 128*(1+noise_proxy), the ordinary final posterior mean satisfies

    E_sample R(posterior mean) <= R(g)
        + [5+256*(1+noise_proxy)*K0 log(K1*(n+1)^2)]/(n+1).

The infimum over comparator networks can be taken directly. This is an expectation guarantee, with no held-out sample or averaging over sample sizes.

A separate high-probability companion uses R0 for irreducible label-noise risk and A_g for approximation error above that floor. For every chosen constant eta in (0,1], it gives

    R(posterior mean) <= R0 + (1+eta) A_g
                      + C*(1+noise_proxy)/(eta*n)
                        * [K0 log(K1*n) + log(2/delta)].

Conditional sub-Gaussian label noise is allowed, including unbounded Gaussian observations. The regression mean lies in [-1,1]. The high-probability companion uses fixed likelihood variance 16*(1+noise_proxy)/eta. Both variance choices are independent of n, learner width and comparator complexity.

The strongest complexity statement is in terms of a **layered formula**, where a hidden computation has only one outgoing use. For S hidden occurrences, depth H, maximum layer width m, coefficient cap B and input dimension d:

- K0 = O((d+1)(S+1)).
- log K1 = O(log((S+1)(d+1)(B+8)) + (H+1)log((m+1)(B+8))), with fixed activation/prior constants.
- The bound is jointly polynomial in formula size, depth and input dimension, with only logarithmic dependence on the coefficient cap.
- No robustness restriction is imposed.

For a shared implementation, one can use its actual rooted formula expansion size S. An arbitrary width-m, depth-H network has the coarse bound S <= m + m² + ... + m^H. The same guarantee then holds at **every learner width N >= m**, including widths too small to contain the entire unrolled formula. At fixed depth this gives polynomial comparator-width dependence. For width-one teachers the exact occurrence count is H, so the depth dependence remains polynomial.

For ReLU and tanh, a further fixed small-intensity choice makes **additional learner depth cost nearly linearly**. If a teacher has depth h, the learner has H >= h, and the teacher formula has S occurrences, the resource is roughly

    (d+1)*(S+m*(H-h)+1)
      * [(h+1)*log(mB) + log((H-h+1)*n*S*d*B)],

with harmless constants inside logarithms. ReLU uses exact identity relays; tanh uses weak relays whose required coefficients cost only logarithmically. This is a prior-intensity choice, not a robustness restriction on its support.

The same learner adapts to all comparator classes by a proof-only confidence allocation. At fixed depth, comparators of width n^u with any u < 1/H and polynomially growing coefficients have vanishing expected excess over their best risk at the single fixed likelihood variance. The high-probability analogue takes eta = 1/log(en), changing only that companion likelihood variance logarithmically.

The label assumptions can also be relaxed completely to **E[Y²] < infinity**. With output range M_n = n^b, 0 < b < 1/2, and Gaussian variance 128*M_n², the same prior is universally squared-risk consistent on compact inputs for every prescribed width sequence tending to infinity. Labels remain unchanged in the likelihood. An explicit finite-sample bound has complexity cost M_n²*K/n and the label-tail remainder E[Y² 1{|Y|>M_n}]. Under sub-Gaussian marginal labels, an output range of order sqrt(log n) retains the nearly 1/n rate up to logarithms.

A lower bound on two-point, uniform-cube, and uniform-sphere input laws shows that **linear learner-depth cost is sometimes necessary at fixed likelihood variance**. The target is a fixed shallow bounded-coefficient network, and every learner width is covered. A raw-output version allows native biases; for specified growing-temperature schedules it gives corresponding stronger depth costs. These are prior-and-temperature-specific lower bounds, not an impossibility for every likelihood choice.

The paper also proves:

- Uniform function neighborhoods on the entire input cube have prior mass bounded below independently of learner width.
- For margin-implementable formula targets on a prescribed input set, exact sign conditioning has polynomial total majority mistakes, confidence failures and expected sampled-prediction mistakes on every adaptive input sequence. No IID assumption is needed for this online statement.
- An alternative raw Gaussian likelihood has the same type of oracle against bounded raw teachers when prediction averages clipped posterior draws. There is no clipping inside that alternative likelihood.
- A finite, positive initialization output variance can coexist with a non-Gaussian wide-network limit and the proved small-network neighborhood guarantee.

The expectation argument adapts the 2026 leave-one-out method of Høgsgaard, Rebeschini and Wegel to an arbitrary prior and conditional sub-Gaussian noise; the full extension is proved in the paper.

The network proof suppresses large background jumps and perturbs the designated teacher coefficients. For each fixed embedding the comparison is itself a product measure. The number of possible neuron placements offsets the designated-edge probabilities. Suppressing background jumps costs only a logarithm of the desired precision, which turns exponential stability factors into logarithmic statistical costs.

This is a different prior family from the Gaussian fan-in priors elsewhere in the collection. The formula-depth result does not establish polynomial depth dependence for arbitrary circuits with shared subcomputations. Exact posterior computation may be intractable.

Dense heavy-tailed network priors and Lévy small-jump approximation have existing precedents, discussed in the paper. The specific guarantee here is a finite-sample agnostic oracle with constants uniform over every prescribed finite learner width.

The proofs have undergone independent AI-agent mathematical review. They have not been formalized in Lean. Build with bash build.sh.
