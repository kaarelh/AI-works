# Attaining the Gaussian scalar baseline from the Boolean cube

25 October 2026. Scratch proof. This concerns Gaussian-controlled population
feature paths, not arbitrary row tilts or a finite-width posterior theorem.
It supplies nonvacuity for the Gaussian companion's **own-baseline** result.

## 1. Statement and conventions

Let the initial covariance on the (d)-cube be

    Q0(x,y) = (1+x dot y)/d,     d>=1.

A Gaussian-controlled layer chooses a Gaussian preactivation vector relative
to the centered Gaussian reference with covariance equal to the preceding
feature second moment, and applies tanh coordinatewise. The cost of the layer
is its Gaussian relative entropy. The terminal readout has outputs (f/2)
and costs one half its squared Hilbert-space norm. Write (J_H^G(f)) for the
infimum of this action over paths with exactly (H) hidden layers. Allowing
arbitrary Gaussian means is harmless; all steering stages below are centered.

Let (V_G) and (V_*^G) be the scalar Gaussian value and its zero-state limit
defined in `gaussian-scalar-baseline-gap.md`. Let (Q_1) be the first free
tanh feature covariance, and put

    a_f = (f^T Q1^{-1} f)^{-1},     S_f = 1+log(1/a_f).

Then there is a universal (C) such that, for every Boolean (f) and every
integer (H>=C S_f),

    J_H^G(f) <= V_*^G + C [S_f^2 + log^2(2H)]/H.             (1)

In particular (S_f<=15(d+1)), and constants or dictators have

    S_f <= C log(d+1).

Thus every fixed target attains the Gaussian scalar baseline as depth tends
to infinity. Constants and dictators already satisfy the useful quantitative
bound

    J_H^G(f) <= V_*^G + C log^2(d+H+2)/H

when (H>=C log(d+1)). Combined with Gaussian own-baseline occupation and
the Gaussian scalar-formula compiler, these constant/dictator paths lie in
its polynomial-resource range. This is not a claim that all targets have
polynomial-resource formulas: their (S_f) can be of order (d).

Counting total layers instead of hidden layers shifts the index by one;
changing the universal constants gives the same inequalities.

## 2. Source chain and the only change needed

The quantitative construction is exactly the one in
`/workspace/depth-research-round3-2026-10-18/critical-target-seed-upper.tex`,
Theorem `critical-target-seed-upper`, with (V_G) in place of (V).
Its supporting lemmas are:

* `critical-free-cooling.tex`, Lemma `critical-free-cooling`;
* `critical-rate-foundations.tex`, Lemma `critical-cheap-holding`;
* `critical-rate-upper-proof.tex`, Lemma `exact-target-purification`;
* `critical-scalar-paths.tex`, Lemma `critical-dyadic-short-path`;
* `critical-rate-foundations.tex`, Lemma `critical-scalar-lift`.

Cooling is the unmodified Gaussian law. Holding, prescribed growth, and
purification inflate the covariance of one Gaussian target coordinate.
The scalar lift rescales its scalar law and independently adds a residual
Gaussian vector. Consequently **every stage stays Gaussian if the scalar
suffix is chosen Gaussian**. No mixture of Gaussians with different means
or covariances is used. The diluted Fourier seed from the separate
`critical-analytic-target-mass.md` is not used here.

The Gaussian scalar suffix exists with the same quantitative estimates.
Monotonicity of (V_G), deletion of nonincreasing transitions, and bridges
to prescribed small states all use only Gaussian rescaling or centered
Gaussian variance inflation; see `gaussian-scalar-baseline-gap.md`, §4.
For small (p), an increasing Gaussian scalar path from (p) can therefore
have cost at most (V_G(p)+p), length at most (C/p), and sums of states
and square roots of stage costs at most (C log(2/p)). The dyadic proof
uses (V_*^G-V_G(q)<=Cq), the Bellman inequality for (V_G), and scalar
dissipation, all established there. It does not appeal to an unrestricted
optimal suffix.

## 3. Detailed depth and action accounting

Positive definiteness of (Q_1) and Cauchy--Schwarz give

    Q1 >= a_f f f^T,     0<a_f<=1.

Free cooling reaches constant diagonal in ([delta/2,delta]) in at most
(C/delta) stages and retains target component at least (c delta a_f).
Choose the smaller exact tracked component

    v0 = delta exp(-A S_f)

with fixed sufficiently large (A). This is a decomposition of a covariance,
not a change of the feature law. The residual remains positive semidefinite
with constant diagonal at most (delta).

Gaussian covariance inflation then holds (v_0) for any specified number
of stages at cost at most (C delta^2) each. It subsequently realizes the
prescribed sequence

    v_next = min(p, v[1+2(delta+v)]).

The number of growth steps is fixed by (v_0,delta,p), independently of
the holding interval or residual covariance. Its length is at most
(C S_f/delta), and its total cost is at most (C(p+S_f delta)).

Set

    delta = B1 S_f/H,
    p = B2 [S_f+log(2H)]/H,

with fixed (B_2>=B_1) sufficiently large. The assumption (H>=C S_f),
with (C) increased after choosing (B_1,B_2), makes both small. Cooling
and prescribed growth occupy at most (H/3) layers. Purify at fixed target
component (p) for (C log(2H)/p) layers; the residual diagonal becomes

    r0 <= delta (2H)^(-4)

at cost (C p log(2H)). A Gaussian scalar suffix of length at most (C/p)
then has nominal cost at most (V_G(p)+p). Its Gaussian lift has the same
or smaller hidden entropy, and at most (C H^{-4}) additional readout cost:
the scalar-lifting lemma applies with residual bound (r_0), giving
extra cost (C (C/p) r_0<=C H^{-4}).

For large enough (B_2), purification and the suffix occupy at most (H/3)
layers. Include the initial free layer in the bounded overhead and fill
the exact remaining integer number of layers by holding before growth.
All subsequent lengths were fixed independently of this holding time.

The total excess is at most

    C [H delta^2 + S_f delta + p + p log(2H) + H^(-4)]
      <= C [S_f^2+log^2(2H)]/H.

Since (V_G(p)<=V_*^G), this proves (1).

## 4. Why covariance decompositions preserve Gaussian admissibility

Suppose (Q=vff^T+R), (R>=0). Represent the reference preactivation as

    sqrt(v) f Z + G,    Z~N(0,1), G~N(0,R), independently.

Inflating or shifting the scalar Gaussian (Z) and retaining (G) gives
a Gaussian vector. Relative entropy of this vector is at most the scalar
relative entropy by data processing. This remains valid for singular (R).
It also explains why selecting a smaller tracked component costs nothing:
it merely selects a different Gaussian decomposition of the same (Q).

If one implements this through feature-space scores, unused independent
coordinates can be adjoined and then projected away. Their reference and
controlled distributions are Gaussian; projection gives a valid Gaussian
control on the actual finite query span and cannot increase entropy.
No Bernoulli mixture in the preactivation law is introduced by this device.

For a Gaussian scalar suffix law (eta=N(m,s^2)), the lifted scalar law
(sqrt(v/q)eta) is Gaussian; adding the independent Gaussian residual
therefore remains within the class defining (J_H^G), even when (m!=0).
Oddness of tanh and the constant residual diagonal make the conditional
feature mean exactly (f_x psi_r(Y)), so its second moment supplies the
claimed target component for either label.

## 5. Simple targets and a bounded free score

The first Hermite term gives

    Q1 >= c/(d+1) [1 1^T + sum_i x_i x_i^T].

Indeed (q=(d+1)/d) lies in ([1,2]), and Gaussian integration by parts
gives the first normalized coefficient
(sqrt(q) E sech^2(sqrt(q)Z)>=c>0). This proves (a_f>=c/(d+1)) for
constants and dictators. For arbitrary (f), the existing full-cube
spectral bound gives (a_f>=exp[-14(d+1)]), hence (S_f<=15(d+1)).

There is also a bounded score for the constant target without inverting
the full covariance. Write the free first feature as

    h1(x)=tanh((g0+sum_i gi xi)/sqrt(d)),
    g(g0)=E_Z tanh(g0/sqrt(d)+Z),
    v1=E g(g0)^2.

Conditioning on (g_0) shows (Q_1>=v_1 1 1^T). Cauchy--Schwarz and
Gaussian integration by parts give

    v1 >= [E g0 g(g0)]^2
       = d^(-1) [E sech^2(sqrt((d+1)/d)Z)]^2 >= c/d.

Thus (b_1=g(g_0)/sqrt(v_1)) has second moment one, satisfies
(E[b_1 h_1(x)]=sqrt(v_1)) for every cube input, and has
(|b_1|<=C sqrt(d)). Conditioning on (g_i) instead gives the dictator
analogue. This score is useful for future finite-width constructions,
but no finite-width claim is needed for (1).

## 6. Interpretation

The strict gap (V_*^G>V_*) prevents Gaussian controls from proving an
unrestricted near-(V_*) theorem. It does **not** make the Gaussian
own-baseline theorem empty: (1) attains that baseline from the actual
augmented-cube input, uniformly over all targets with its explicit seed
complexity cost. The Gaussian compiler remains a substantive conditional
structural theorem, while extending it to entropy-optimal non-Gaussian
controls is a separate unresolved task.
