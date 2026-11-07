# Why the triangle argument does not directly extend to smooth periodic activations

Research result and scope note, 7 November 2026. The triangle wave is the fixed elementary function

`phi(t)=(2/pi) arcsin(sin(pi t/2))`.

It is the usual odd triangular wave from Fourier analysis: bounded, continuous, periodic, and 1-Lipschitz. It is a natural piecewise-linear analogue of sine, although it is not a commonly used monotone neural activation. Its nonmonotonicity and its corners at integer peaks are essential to the exact atomic geometry proved in the sibling triangle notes.

The results below obstruct a direct replacement by a smooth periodic activation. They do **not** prove an online upper bound for sine or rule out a different sine counterexample.

## 1. Smooth lattice parity atoms are never norm-optimal

Let `psi` be any continuously differentiable activation of period four. Let `S` have size at least two, take odd integer incoming weights `q_i` on `S`, zero weights elsewhere, and arbitrary bias `b`. Suppose the parity coefficient of

`h(x)=psi(b+sum_(i in S) q_i x_i)`

is nonzero.

Shrink only the ordinary weights:

`h_epsilon(x)=psi(b+(1-epsilon)sum_i q_i x_i)`.

At `epsilon=0`, the argument modulo four depends only on `chi_S(x)`. The same is therefore true of `psi'` at the argument: it is of the form `A+B chi_S(x)`. With `ell(x)=sum_i q_i x_i`, differentiating the parity coefficient gives

`d/depsilon E[chi_S h_epsilon] at0 = -E[chi_S (A+B chi_S) ell]=0`,

because `E ell=E chi_S ell=0` for `|S|>=2`. In contrast, the incoming Euclidean norm has a strictly negative derivative under this shrinkage. Hence, for all sufficiently small positive `epsilon`,

`||(b,(1-epsilon)q)|| / |hat h_epsilon(S)|`

is strictly less than its value at zero.

Thus a pure parity atom located on the usual periodic integer lattice cannot be an optimal atom for its parity Fourier coefficient under any `C^1` periodic smoothing. This statement does not require that the lattice phases are local extrema of the activation.

## 2. The exact one-parity cost for sine

Take `psi(t)=sin(pi t/2)` and odd `n>=3`. Its exact Euclidean variation cost for the real parity `chi_[n]` is

`a_n = sqrt(n) min_(0<u<=1) u/[sin(pi u/2)]^n`.       (1)

To prove this, the parity coefficient of an arbitrary affine sine atom is, up to sign,

`cos(pi b/2) product_i sin(pi w_i/2)`.

Extra coordinates contribute cosine factors. Removing bias and extra coordinates cannot worsen the coefficient-to-norm ratio. Reducing the remaining weights modulo two and taking absolute values puts them in `(0,1]` without increasing their norm or changing the denominator. At fixed squared norm, Jensen applies because

`z -> log sin((pi/2)sqrt(z))`

is strictly concave on `(0,1]`: both terms in its second derivative are negative. Hence equal magnitudes are optimal. Sign averaging extracts exactly the parity without increasing variation cost, proving (1).

The minimizer `u_n` is the unique point in `(0,1)` satisfying

`x cot x=1/n`,  `x=pi u_n/2`.

In particular,

`u_n=1-4/(pi^2 n)+O(n^-2)`,

`a_n=sqrt(n)[1-2/(pi^2 n)+O(n^-2)]<sqrt(n)`.

## 3. Even the projected code norm is not diagonally weighted Fourier l1

Let `C` have odd size `c>=3`, let `B` have positive even size `r`, and put `n=c+r`. Consider the optimal one-parity atom

`h(x)=sin((pi u_n/2)sum_(i in C union B) x_i)`.

Its two relevant Fourier coefficients are nonzero and satisfy

`|hat h(C union B)| = sin(pi u_n/2)^n`,

`|hat h(C)| = sin(pi u_n/2)^c cos(pi u_n/2)^r >0`.

By the definition of `u_n`,

`a_n |hat h(C union B)|=sqrt(n)u_n=||w||`.

Now project onto the two-character space spanned by `chi_C` and `chi_(C union B)`. This projection is a signed average of input-sign isometries:

`P h(x)=E_(epsilon:chi_B(epsilon)=1) chi_C(epsilon) h(epsilon*x)`.

It cannot increase variation norm. Consequently,

`V_sine(P h) <= ||w||`

`             < a_c |hat h(C)| + a_n |hat h(C union B)|`.       (2)

Therefore the proposed **exact** code norm identity with the optimized one-parity costs is false, not merely unproved. The same counterexample embeds into any larger common-core code family by setting other block weights to zero.

The extra coefficient is very small: for large `n`, its cosine factor is approximately `(2/(pi n))^r`. Nevertheless it is strictly positive, and exact strict ordering of nearly tied star costs cannot discard it without a quantitative comparison.

## 4. What a weaker fiber argument could still do

At the optimal sine atom, write `delta_n=1-u_n`. The exact pointwise identity is

`h(x)=eta chi_(C union B)(x) cos((pi delta_n/2)sum_i x_i)`.

As `n` grows, its phase perturbation is at most `2/pi+o(1)`, so its amplitude lies approximately between `cos(2/pi)=.804...` and one. A small mixture of such efficient atoms can therefore have limited oscillation inside a parity fiber. This observation may support a weaker sign-invariance lemma; it does not repair the false diagonal norm identity (2).

A successful smooth-periodic extension would need a genuinely non-diagonal latent atomic norm, or a quantitatively controlled approximate norm together with robust strict energy ordering. Neither is supplied here.

## 5. Monotone activations

For any nondecreasing scalar activation, a single ridge is unate in every input coordinate. A nonconstant parity on at least two inputs is non-unate in each of them. Thus the triangle proof's optimal one-neuron parity dictionary cannot be transferred literally to tanh, ReLU, softplus, or another monotone activation.

These are mechanism-level obstructions only. They do not rule out multi-atom parity representations, different exact duals, or a different all-completion argument for a common activation.

## A monotone extension that does work

The literal one-neuron obstruction in Section 5 does not prevent a finite signed average from cancelling a free affine term. The [monotone-activation paper](../../isotropic-monotone-allwidth/paper.pdf) successfully handles `psi(t)=(2t+phi(t))/3`. Four orientations cancel the affine term, while calibration charges any uncancelled affine component. This activation is fixed, strictly increasing, and 1-Lipschitz, with infinitely many kinks. The smooth-sine counterexample in Sections 1--3 remains valid.

The exact obstruction also applies to the smooth strictly increasing 1-Lipschitz analogue

`psi_sin(t)=[2t+(2/pi)sin(pi t/2)]/3`,

whose derivative lies in `[1/3,1]`. Code projection annihilates its affine part, while the sine residual is merely multiplied by a fixed positive constant. Therefore (2), with the corresponding reciprocal scaling of the weights, still strictly contradicts the proposed diagonal code norm. Smoothness, monotonicity, and a bounded derivative are not enough to preserve the successful triangle-residual norm identity.

The independent `tanh_nonlinear` research lane audited the phase derivative, exact sine optimizer and asymptotic expansion, and projected two-character counterexample, and reported no substantive flaw.
