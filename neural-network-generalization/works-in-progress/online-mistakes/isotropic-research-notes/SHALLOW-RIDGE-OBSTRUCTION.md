# A general obstruction to the canonical affine-minimum route

This is not an upper bound for unrestricted NNbayes. It is an upper bound for a particular proof mechanism: reducing the canonical wide learner to successive convex minimum-norm affine separators. It explains why a successful continuous-activation example with a small bounded shallow teacher must use a different mechanism.

## Model and a width-uniform teacher energy bound

Let d,C>=1, B,K>0, D=d+1, augmented Boolean inputs xbar=(1,x), and consider one hidden layer with a K-Lipschitz activation phi satisfying phi(0)=0. The canonical Gaussian energy is

    E_N=(d/N) sum_j ||u_j||² + N sum_j v_j².

Suppose the target has a width-C teacher whose incoming and outgoing weights all have absolute value at most B and whose global output margin exceeds1/2. For every N>=2C, allocate m_j clones to each teacher neuron, with sum m_j=N and m_j>=N/(2C), and divide its outgoing weight by m_j. This preserves the entire real-valued output. The energy is at most

    E_T=d(d+1)B²+2C²B².                              (1)

Indeed the first-layer contribution is at most dD B². The readout contribution is at most 2C sum_j v_j²<=2C²B². Therefore every exact-label history of this target has a feasible global-margin network of energy at most E_T at all these widths.

## Every affine ridge witness has a norm-dependent energy lower bound

Let a be a nonzero convex minimum-Euclidean-norm unit-margin affine separator of a nonempty labeled history. Write Q=||a||². At least one training constraint is active: y_i a dot xbar_i=1, since otherwise positive rescaling down would reduce the norm.

Consider any ridge network with first-layer rows u_j=r_j a. The r_j and v_j may be arbitrary and need not coincide across neurons. At that active input, phi(0)=0 and Lipschitzness imply

    1/2 <= |sum_j v_j phi(r_j a dot xbar_i)|
         <= K sum_j |v_j r_j|
         <= K sqrt(N sum_j v_j²) sqrt((1/N)sum_j r_j²).

Consequently AM--GM gives

    E_N=dQ (1/N)sum_j r_j²+N sum_j v_j²
        >=sqrt(dQ)/K.                               (2)

This does not require a bounded or homogeneous activation. It includes tanh, hardtanh, and ReLU. It is stronger than a lower bound only for identical clones.

Use closed global margins |F(x)|>=1/2 when discussing minimizers. Their fixed-function minima exist by continuity and coercivity, and equal the corresponding strict-cell infima by arbitrarily small readout amplification. If such a ridge realizes the global closed-margin energy minimum for a target-consistent history, (1)--(2) force

    Q <= K² E_T²/d.                                 (3)

## A wrong affine margin prediction has a definite norm increment

Let a_t be the convex minimum-norm affine unit-margin separator of all labels seen before round t. Assume it has global absolute affine margin at least one on the Boolean cube, as in the scalar-selector construction. If its prediction at the next input is wrong, then

    y_t a_t dot xbar_t <=-1,
    y_t a_(t+1) dot xbar_t >=1.

Thus ||a_(t+1)-a_t||²>=4/D by Cauchy--Schwarz. Projection of the origin onto the old closed convex feasible set gives

    a_t dot(a_(t+1)-a_t)>=0,

because a_(t+1) remains feasible for every old label. Therefore

    Q_(t+1)>=Q_t+||a_(t+1)-a_t||²>=Q_t+4/D.          (4)

At all other rounds Q is still nondecreasing.

## Conditional consequence for a proposed reduction

Suppose an argument claims, throughout a finite online sequence and at every resulting state, that the canonical closed-global-margin energy minimum is realized by a ridge along the convex affine unit-margin minimizer, and that the predictions follow its affine signs with global affine margin at least one. Suppose also that the target has the bounded shallow teacher above and N>=2C.

Then (3)--(4) bound the number of mistaken rounds by

    mistakes <= (d+1) K² E_T²/(4d).                  (5)

This is a polynomial in d,C,B,K. If the ridge condition is only known before the final update, add one to account for that last round.

Thus exponentially many mistakes with polynomial d,C,B and fixed K cannot arise through this particular canonical affine-minimum reduction. Geometric calibration cannot rescue that proof route while keeping all its other features: a bounded teacher supplies a competing polynomial-energy implementation.

The extra-readout-penalty theorem avoids this obstruction because its teacher energy grows with A_N. The sign-activation theorem avoids it because sign is discontinuous and has no finite Lipschitz constant. No conclusion is drawn about unrestricted nonlinear minimizers of canonical tanh, hardtanh, or ReLU networks.

## Without the global affine margin assumption

If only the wrong affine sign `y_t a_t dot xbar_t<=0` is known, the same projection argument gives `Q_(t+1)-Q_t>=1/D`. The conditional mistake bound is then four times (5). Thus global affine margin is not needed for the qualitative polynomial obstruction; it supplies the stronger numerical factor used in the scalar-selector setting. This concerns the affine witness's margin, not the neural model's imposed global output margin.

## Independent checks

Both `wide_geometry` and `wide_numerics` independently checked the cloning bound, arbitrary parallel-row ridge bound, convex projection increment, and conditional theorem scope. The weak-margin/strict-infimum distinction above incorporates the numerical agent's clarification. No Lean verification is claimed.
