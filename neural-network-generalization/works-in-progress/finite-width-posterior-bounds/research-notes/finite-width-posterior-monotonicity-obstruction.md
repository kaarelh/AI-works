# Correct-label posterior probability need not improve with width

25 October 2026. Scratch note. This is an exact finite-width counterexample to pointwise posterior-probability monotonicity and to multiplicative error domination across widths. It is not an exponential sample lower bound, and does not show that the original 2/3 confidence-failure criterion worsens in this example.

## A width-one teacher and a three-point sample

Take d=2 and weighted depth L=2, so there is one hidden tanh layer and a linear readout. Let

    f(x1,x2)=sign(1+x1+x2).

It has a width-one teacher z_f(x)=tanh(1+x1+x2), all physical weights equal to one, and global signed output margin at least tanh(1)>1/2. Thus the original bounded-weight teacher complexity is at most one.

Train on the three points

    (1,-1) -> +1,   (-1,1) -> +1,   (-1,-1) -> -1,

leaving (1,1) unseen. Only two Boolean cube functions agree with these three labels: f and g(x)=-x1 x2.

Every width-one network at this depth has output v tanh(w0+w1 x1+w2 x2), so its sign function is a linear threshold. The parity g is not a linear threshold on the square. Thus the original globally margined width-one posterior places probability one on f and has

    p_(N=1)(f(1,1)|(1,1),S)=1.

The posterior conditioning event has positive probability because the displayed teacher has strict global margin and a parameter neighborhood preserves it.

## Width two gives positive probability to the wrong completion

The width-two network

    z_g(x)=3 tanh(10(1+x1+x2))
            -6 tanh(0.4+0.2x1+0.2x2)

represents g with strict global margin greater than 1/2. Writing s=x1+x2, its values are

    s=-2: -3 tanh(10) < -2.99,
    s= 0:  3 tanh(10)-6 tanh(0.4) > 0.72,
    s= 2:  3 tanh(30)-6 tanh(0.8) < -0.98.

The target f also has a strict-margin width-two realization by zero padding its width-one teacher. Each realization has an open parameter neighborhood preserving all four signs and margins. Every actual positive Gaussian variance assigns positive mass to both neighborhoods.

Consequently, after the same global-margin and sample conditioning, the width-two posterior gives positive mass to both completions. At the unseen input,

    0 < p_(N=2)(f(1,1)|(1,1),S) < 1.

This works for every positive finite scale at each width, in particular for every common canonical prefactor 0<t<=1 and for every fixed exponent gamma>=1 with its prescribed width-dependent scale. The sample itself has positive probability under the uniform input distribution.

Hence the following potential bridge statements are false even for a width-one bounded-weight teacher:

* correct-label posterior probability is pointwise nondecreasing with learner width;
* the larger-width posterior wrong-label probability is bounded by any finite factor times the smaller-width wrong-label probability, uniformly over realizable teachers, samples, and test inputs.

The example does not establish that the width-two correct-label probability is at most 2/3. A more specialized comparison for the original confidence-failure risk remains logically possible.

## The shallow raw averaging identity does not survive label conditioning

At L=2 and fixed t, the width-N raw function can be written

    z_N(x)=(t/N) sum_(i=1)^N A_i tanh(W_i dot (1,x)),

where A_i are independent standard Gaussians and the W_i have the prescribed first-layer Gaussian law. Thus z_(kN) has exactly the law of the average of k independent width-N raw functions. This is a genuine shallow prior convolution identity.

It gives no projectivity of the globally margined sign prior: signs of an average depend on magnitudes, and averaging two width-one functions can create a width-two parity function absent from the width-one sign support. The strict support enlargement above already precludes transporting the margin-conditioned function law by a domination argument that preserves the smaller-width support. Deeper fully connected priors also have cross-block Gaussian weights, so this independent-block averaging identity is not available there in the same form.

No claim about monotonicity of expected Bayes risk under a jointly sampled teacher prior is made; the question here fixes a realizable teacher independently of the learner prior.
