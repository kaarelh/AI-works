# Audit of the Boolean witness and population-count normalization

Source reviewed: `improved-polynomials/neuron-averaging/source/paper.tex`
in `/workspace/nnbayes-better-polynomials`, 22 October 2026. No canonical
repository changes were made.

## Finding

**Yes:** every Boolean target in the paper's stated width-C, depth-H
layered-circuit class has an implementation satisfying the new population
restriction at every learner width N>=C. This extends to a set of strictly
positive Gaussian probability, with the stated quantitative cylinder bound.
The argument checks out. The population condition is nevertheless strongly
parameterization-dependent; its calibration should not be interpreted as
an intrinsic property of the represented Boolean function.

## Exact cloned implementation

Partition each layer into C balanced, nonempty groups of sizes k_b in
{floor(N/C),ceil(N/C)}. A logical gate's coefficients into a source group
are divided by that group's size k_b, and all neurons in a destination
group receive identical rows. First-layer rows are likewise identical
within destination groups. The readout has coefficient a/k_out on each
clone of the chosen output wire and zero elsewhere.

If P_s averages inside these groups, then exactly

    P_1 W1_*=W1_*,
    P_s Ws_* P_(s-1)=Ws_*,
    P_H v_*=v_*.

Thus averaging preserves the **real-valued** network, not just its signs.
The group count is q=C and its readout energy is

    E_v(w_*)=a^2 N/k_out >= a^2 C/2.

For a>=4 this comfortably implies C<=1+E_v. Saturated tanh gates implement
the Boolean circuit with a strict margin. Arbitrary N>=C is allowed; exact
divisibility by C is unnecessary.

Unused slots can be filled with constants or copies of an available wire.
Constants required by internal gates count toward C. The theorem is not
claiming the same width for a circuit model that supplies free internal
biases or uncounted constant wires. For H=1, the appended first-layer input
constant supplies biases. For C=1 and deeper circuits, admissible operations
are those possible with the single counted wire; a repeated-input NAND is
a negation and can be implemented as such. There is no N=C or N=1 failure
in the projection or Gaussian-mass argument under these conventions.

## Why the positive-mass neighborhood also works

The cylinder constrains standardized first-layer entries, each internal
row's C clone-direction coordinates, and standardized readout entries to
intervals of radius rho*t around their teacher centers. The orthogonal
internal Gaussian bulk remains unconstrained except for a positive-
probability operator-norm bound. Hence this is not a measure-zero exact-
cloning event.

For each internal layer

    Ws=Ws_*+Rs+Es,
    Rs=Rs P_(s-1),  Es P_(s-1)=0.

Projection averages rows whose teacher centers agree. It therefore preserves
every constrained coordinate interval. Right projection kills Es. Left
projection preserves the remaining intervals and cannot create a nonzero
bulk. The first-layer and readout intervals are also preserved by averaging.
Consequently the same projection maps the whole cylinder into itself.

The robust digital invariant in the paper gives, for every input and every
allowed internal disturbance, signed output greater than one, both before
and after averaging. **Clipping is decisive here:** both clipped outputs
are exactly f(x)/2. Their un-clipped numerical outputs need not coincide
for a generic point in the cylinder.

The readout bounds give

    E_v >= a^2 C/8 >=2C,
    r_c(w)<=tau_0,

so both the population-count condition and the optional RMS robustness
condition hold. The lower bound on E_v is deliberately supplied by the
readout amplitude and its distribution among clones.

There are N[d+2+(H-1)C] constrained independent coordinates. Their squared
centers sum to at most N B_0. Multiplication of the elementary interval
probability lower bounds and the independent bulk event gives exactly

    mu_N,t(cylinder) >= exp(-N D_*/t^2).

The event has nonempty interior: intervals have positive radius, the teacher
has zero bulk, all score margins have strict slack, and C<=1+E_v has slack.

## Calibration loopholes and what they mean

For q=N every population is a singleton, so P_s=I. The approximation
condition is then automatic. The baseline support therefore contains
**every** parameterization with

    E_v>=N-1, equivalently ||v||_2^2>=1-1/N.

For the lambda-calibrated version the threshold is
||v||_2^2>=lambda(1-1/N). At N=1 the population condition is automatic
regardless of the readout.

Multiplying the readout by a sufficiently large scalar can always buy this
q=N certificate. On a finite input set, if the clean network has no zero
outputs, sufficiently large readout scaling also eventually satisfies the
optional RMS restriction: the radius shrinks like the inverse scale while
the clean clipped scores saturate. This does not invalidate the theorem.
The inflated readout is expensive under the specified Gaussian, and the
posterior tail proof makes such large population budgets rare when learning
a cheap target. It does mean that the condition is a prior-cost certificate,
not an unconditional claim that every admitted network visibly has a small
number of redundant populations.

There is a second parameterization dependence. Uniformly cloning every
neuron k times and dividing outgoing coefficients by k preserves E_v
exactly. But unequal replication can change it. If a final feature h has
total coefficient a and is placed on k of the N neurons, then

    z=a h,  E_v=a^2 N/k.

Replicating that output feature across all N neurons makes E_v=a^2;
placing it on one makes E_v=a^2N, without changing z. Earlier layers can
remain complex. Thus changing only the last layer's redundancy can change
the allowed population count for **all** layers. Strict balancing also
means that uniform cloning of an arbitrary preexisting witnessing partition
need not preserve exact balance unless its original groups were equal.

These are naturality qualifications, not counterexamples to the witness or
sample theorem. Gaussian parameter priors themselves distinguish these
parameterizations.

## A rigorous readout-scale-invariant calibration variant

There is a simple way to remove the ability to buy a larger population
budget merely by scaling the output. Define, without target labels,

    M(w)=max_x |z_w(x)|.

Replace the count condition by

    (q-1) M(w)^2 <= 4 E_v(w).                                (N)

while keeping the existing clipped-score approximation and, optionally,
the original RMS restriction. This is a new prior. Its population-count
calibration is exactly invariant under nonzero global readout scaling.
The entire support condition is not completely scale invariant, because
its prediction comparison still uses the original absolute clipping scale.

The same quadratic learning proof works, up to universal constants, for
every nonempty training sample:

1. On the existing target cylinder, ||v||_1<=a+rho, so M<=a+rho<=5a/4.
   The sharper readout estimate is

       sqrt(E_v) >=a sqrt(C/2)-rho
                  >=(1/sqrt(2)-1/16)a sqrt(C)
                  >(5/8)a sqrt(C),

   because a>=4, rho<=1/4 imply rho<=a/16<=a sqrt(C)/16. Consequently

       E_v/M^2 > [(5/8)^2/(5/4)^2] C = C/4.

   Thus the **same cylinder and same D_*** satisfy (N).

2. Every exact-fitting posterior point for a nonempty sample has M>1/2.
   Therefore (N) implies q<=1+16E_v. After the unchanged readout truncation
   E_v<=B, use Q=ceil(1+16B) in the existing partition, grid and sample
   formulas. Nothing else in that proof changes.

This keeps quadratic C dependence, all N>=C, and every gamma>=1. It also
keeps the original readout-amplitude parameter from controlling the count
budget. The cross-multiplied condition is defined even at M=0. Such networks
never survive a nonempty strict-margin training sample, and the target
normalizer remains positive. Thus no division convention or extra support
exclusion is necessary.

This variant does **not** remove dependence on unequal neuron replication.
It should be described as an invariant calibration, not a completely
function-invariant notion of redundancy. A fully intrinsic functional
complexity requirement would need a different argument.
