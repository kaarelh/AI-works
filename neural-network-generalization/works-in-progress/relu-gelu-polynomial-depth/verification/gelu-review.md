# Independent review of the GELU polynomial-depth extension

Reviewed on 22 October 2026 by an independent AI agent. This is ordinary mathematical review, not Lean verification. The parent agent independently reviewed the ReLU base argument; this record checks the GELU-specific extension and its integration with that base.

## Scope

The reviewed extension proves the stated polynomial-depth learning guarantee under the neuron-merging prior restriction, for exact GELU at every learner width N>=2C and every scale 0<t<=1. It includes arbitrary population sizes, exact same-depth compilation of the specified Boolean gate basis, a positive-mass target cylinder, and a common finite predictor grid for all widths and scales. It does not assert that the restriction is typical of trained networks or equivalent to ordinary perturbation stability.

## Exact compiler and norm budgets

For tau=Phi(1), s=2tau-1, A=tau/s and B=(1-tau)/s, the identity A GELU(u)+B GELU(-u)=ReLU(u) holds exactly at u=-1,0,1. Representing every bit, including the constant-one wire, by both signed preactivations therefore compiles NOR, COPY, and NOT at the same depth. Initial bits (1+x_i)/2 have first-layer row squared norm at most one, even with repeated gate inputs. Paired hidden features have magnitude at most one.

An internal logical affine row has squared coefficient norm at most five in the Boolean basis. Substituting the two-term decoders multiplies this by A^2+B^2<5, including repeated inputs and cancellations when an input is the constant wire. Hence the bound below 25 is valid. The final readout has squared norm between a^2 and 25a^2: for distinct output and constant wires it is 5a^2(A^2+B^2), and when they coincide it is a^2(A^2+B^2). Balanced cloning into D=2C populations then gives the stated conservative upper bounds 100D and 100a^2D, and the lower bound a^2D/2 for the normalized readout energy.

## Target cylinder

The free Gaussian bulk annihilates each teacher state because those states are constant on clone populations. GELU's global Lipschitz constant at most two gives the displayed RMS error recurrence. The enlarged S_G dominates every operator factor, and the chosen rho_G implies the announced hidden error and output discrepancy below 1/8. In particular, the teacher output af retains signed margin greater than one throughout the cylinder.

Projection onto the clone populations preserves all constrained coordinate intervals and removes the free bulk. This statement concerns the parameters and is valid without any claim that GELU commutes with averaging. Both original and merged networks are consequently in the same target cylinder; their clipped outputs are exactly equal to f/2. The normalized readout lower bound, together with M<=5a/4, proves the population-count inequality with q=D. The Gaussian interval multiplication therefore supplies the stated raw mass exp(-N D_G,*/t^2).

## Arbitrary population sizes

The exact compressed activation is psi_r(u)=r GELU(u/r), where r=sqrt(k/N). Its continuous extension at zero is ReLU(u). The derivative in r is -(u/r)^2 varphi(u/r), with absolute value at most 2/(e sqrt(2pi))<1. The extension is uniform in u because sup_v |GELU(v)-ReLU(v)| is finite. Thus the claimed joint bound 2|u-u'|+|r-r'| holds even when one mass is zero, as does |psi_r(u)|<=|u|.

Writing the full merged state as sqrt(N) F_s g_s yields exactly the displayed recurrence with psi_(r_s,j). The compressed Gaussian coefficients still have variance t^2/N after the first-layer sqrt(d) scaling, independently of population sizes. Consequently the same readout tail, partition union, and coefficient-energy tail apply. No inverse minimum population mass appears.

## Finite coding and polynomial degree

At most HQ mass parameters are appended to the coefficient grid, and masses are rounded within [0,1]. Padded zero neurons use mass zero and zero incoming coefficients. The factor four in A_G absorbs both the input Lipschitz factor two and the additive mass error. More explicitly, first-layer error is at most (2d+3)zeta_G; subsequent error is at most 2QR times the previous error plus 2Q zeta_G A_G^(s-1)+zeta_G. These are bounded by the displayed recurrence and hence by s zeta_G A_G^s. The final readout error is at most 1/32.

The predictor grid is allowed to contain unrealizable population masses; only its finite predictions enter the union bound. Its log-cardinality is at most (P_Q+HQ)log(3+4R/zeta_G), uniformly over all N and t. The same margin gap between training and test failures is preserved.

After ancestral pruning, C'<=min(C,2^H+1), so log(2+C')=O(L). The factor-two GELU compilation does not change this order. The formulas give log(1/rho_G)=O(S^2), D_G,*=O(C'S^3), Q=O(C'S^3), J=O(C'S^4), P_G=O((C')^2 S^7), and the final logarithmic grid factor O(S^2). Thus the literal C^2 S^9 envelope is valid after changing only the universal constant. At fixed other parameters the more precise width dependence remains O(C^2 log^3(2+C)).

## Verdict and reviewed sources

No mathematical defect was found in the GELU extension or its integration into the reviewed manuscript.

- `paper.tex` SHA-256: `5b93dfb76c4bee27813359453424175d60e739611c9578dd10f0624983186916`
- `gelu-extension.tex` SHA-256: `a14a258c07cfa4e3d5f27a8b9c8801bcef2d29d00a50f40ba2a1bae121bcfe47`
