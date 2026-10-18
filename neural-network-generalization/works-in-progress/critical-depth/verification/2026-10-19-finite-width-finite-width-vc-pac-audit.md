# Independent audit: local representability, VC, and finite-width PAC

Auditor: `/root/continuous_audit`.

Audited source:
`source/critical-finite-width-certificate.tex`
SHA256 `6d7f660e55bf4619224f6e9ddb2e3d312b8d60df57bbfca2fb64f9ac040b48e6`.

This record audits the concluding local-representability-to-VC reduction
and its use in the actual posterior. The earlier probabilistic extraction
and controlled-kernel estimates are dependencies independently audited by
other agents; the auditor also read them for consistency but does not
claim a new complete audit of every referenced transfer theorem.

## Exceptional mass and VC

The reduction in `cor:critical-finite-width-exceptional-mass` is correct.
Fix the common finite-witness network width M and a universal upper bound
v on its VC dimension. Set m=floor(v)+1. If m exceeds the cube size, the
class of all Boolean functions has VC dimension at most the enlarged R,
and its exceptional mass is zero.

Otherwise take G_A to be the functions whose restriction to every m-point
subset is realizable by a width-M depth-L network. If G_A shattered any
m-point subset, then for each of its 2^m assignments some function in G_A
would provide a representing network. The network class would shatter the
same subset, contrary to its VC bound v<m. Thus VC(G_A)<m.

For a fixed witness Z, the event of globally margined networks with a
nonrepresentable sign restriction is measurable and invariant under hidden
neuron permutations. If it had raw mass at least exp(-NA), the finite-witness
theorem would produce a member with a representable restriction, a
contradiction. The strict upper bound exp(-NA) is therefore justified.
A union over at most (2^d)^m witnesses proves the displayed exceptional
mass bound. The enlarged universal exponent in R absorbs the VC polynomial
and the finite-witness width requirement. The class depends only on the
architectural parameters and A, not on training inputs or learner width N.

## Intrinsic actual-posterior deduction

The deduction is written in `source/critical-finite-width-learning.tex`,
SHA256 `56de4ecdbd778f6da0ab449a3fd6a62d6b4c3befaa8db6ba952ca92c46fca6af`.
Its author is this auditor; it has been independently read and approved by
`/root/depth_memorization` (separate audit record).

For a_N=-log(raw target mass)/N, choose A=a_N+1/L. The target event lies
inside every posterior-conditioning event, so raw normalization is at least
exp(-Na_N), uniformly over all samples. The exceptional posterior mass is
at most exp(dR log(2)-N/L). This is at most epsilon/6 above the explicit
large-width threshold. Finite-cube Sauer counting gives log|G_A|<=C(d+1)R,
so exact-fit generalization of every consistent member follows by a simple
finite-class union bound. Averaged posterior error is at most epsilon/3;
the probability-2/3 criterion follows by Markov's inequality.

Below that threshold the width itself is bounded by a universal polynomial
in R,L,d,log(1/epsilon). The ordinary tanh VC theorem bounds the whole
posterior support by the same type of finite-cube count. This covers every
finite width with positive target mass, not only asymptotic widths.

The conclusion is intrinsic: its target cost is actual finite-width raw
mass, not merely the limiting rate J_L(f). It does not establish a uniform
near-baseline target-mass estimate from general teacher complexity.

No correction or unresolved issue was found in the audited reduction.
