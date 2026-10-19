# Independent assessment of layerwise scaling tuples

Status: bounded research review for FAQ, 2026-10-19. No repository edits.

## What the slides actually argue

Appendix I assumes posterior hidden preactivations remain order one (neither vanishing nor saturated), and fixes the first layer to a random embedding. It does not classify all exponent tuples under the actual unconstrained prior.

With order-one incoming features, one hidden layer of N neurons has Gaussian action approximately p_l=1/sigma_l^2; the single readout has price 1/(N sigma_L^2). A tight layer followed by a cheap layer can reduce its amplitude to t and recover a degree-k nonlinear feature downstream. Toy action p_l t^2+p_(l+1)t^(-2k) balances at t=(k p_(l+1)/p_l)^(1/(2k+2)). If p_l/p_(l+1) diverges, t tends to zero: the optimum leaves the stipulated order-one-amplitude class. This is an exclusion, not a reduction theorem.

A step in the other direction is claimed to force all computation into the cheap prefix, leaving a costly suffix to copy an answer. Universal approximation is invoked to finish the answer early, but it gives no polynomial resource bound. A full multi-input implementation also depends on feature Gram matrices and entropy, so scalar prices are insufficient.

## Rigorous-looking collapsed-layer result, independently checked

One hidden tanh layer, augmented constant input, first-layer entry variance N^(-a)/d, readout variance N^(-b), a>b>1. Fix a finite Boolean cube and target f before taking N to infinity. Let k be the least odd integer at least the polynomial threshold degree of f; use k=1 for constant functions. Then the raw globally margined target-event probability satisfies

    P(A_f) = exp[-Theta_f(N^e_k)], e_k=(k a+b)/(k+1).

The constants depend on the fixed domain and f; this is not a uniform sample-complexity estimate.

Proof check: with weighted action I=N^a||W||_F^2+N^b||v||_2^2 (absorb d into constants), tanh Taylor truncation through degree k-2 has uniform global remainder

    <= C ||v||_2 ||W||_F^k
    <= C I^((k+1)/2) N^(-(ka+b)/2).

Below a constant times N^e_k, the truncation preserves the 1/2 margin and would be a lower-degree sign representation, impossible. The k=1 version truncates to zero and uses tanh's Lipschitz bound.

Conversely homogenize a threshold polynomial to odd total degree k using the constant input. Write it as a finite sum of kth powers of linear forms and cancel lower odd tanh coefficients with a finite Vandermonde combination. Set first-layer amplitudes t=N^(-(a-b)/(2k+2)) and readout amplitudes t^(-k). Both action terms are O(N^e_k), and the Taylor remainder vanishes. Gaussian parameter dimension is O(N). Since e_k>b>1, the chi-square tail and polynomial-radius boxes around this construction yield matching exponential orders; N log N is negligible.

Hence on the finite domain the width-first posterior gives zero limiting mass to any sample-consistent function whose odd-rounded threshold degree exceeds the minimum available degree. We do not identify weights among degree ties.

For even d, full parity has rounded degree d+1, while every function other than plus/minus parity has threshold degree at most d-1: choose positive magnitudes for f's output so the top Fourier coefficient vanishes. Therefore parity is asymptotically less probable than all those functions, including functions with exponentially greater circuit complexity. This disproves a universal circuit-size ordering over all tuples. It does not prove an exponential sample lower bound: low-degree functions can approximate parity, and lower-degree exact-training extensions can be almost correct.

## Limited positive-region conjecture

For the same one-hidden-layer family, a>0 and a<=b<=a+2, use M=N^((b-a)/2) active neurons. First-layer action M N^a and readout action N^b/M balance at N^((a+b)/2). The active block is a balanced strong-prior family at its own width. The full N-neuron background cannot simply be discarded, but only finitely many Taylor degrees have typical Gaussian action no larger than this scale. Their dimension is polynomial in d, with exponent depending on a,b. This supports a tentative circuit-learning conjecture in this region. No posterior theorem is established.

For b<a, the degree exponents e_k strictly increase with k, without a fixed degree cutoff. Likely a hard learning regime, but exp(Omega(k)) parity lower bounds require their own argument. Approximate polynomial-threshold representations of parity can have degree O(sqrt(k)), so threshold degree alone does not settle the sample rate.

## Why a tempting general cone is insufficient

For L layers and active widths N^q_s, equalizing cloned-teacher action gives

    E=(sum a_s)/L,
    q_s=s E-sum_(j<=s) a_j.

The constraints 0<=q_s<=1 and E>max q_s make a structured active block affordable, but are not a sufficient circuit-prior criterion. For example a=(.2,.5,1.1) gives E=.6, q=(.4,.5), while typical activation recursion yields b_1=.2 and b_2=0 with saturated second-layer preactivations. A full-rank sign-feature kernel can then handle fixed labels at Gaussian action N^.1, cheaper than the structured block N^.6. Deeper saturation can regenerate a full kernel and invalidate the one-layer finite-degree-background argument.

Safe FAQ stance: two broad outcomes remain a plausible organizing conjecture in some slices, not an established or presently convincing exhaustive classification. Frozen-feature, feature-learning, collapsed-degree, and mixed blocks need separate treatment; an explicit collapsed-degree slice can already be proved.

## Exact public draft review

Reviewed FAQ Question 9 and the complete scaling-tuples README. The statement, Taylor-action lower bound, finite-neuron upper construction, Gaussian-volume conversion, conditioning corollary, and even-d parity comparison are mathematically sound. The conjecture table labels its claims appropriately and restricts the active-population conjecture to one hidden layer. No mathematical correction requested. Suggested only a rendering edit from `degree-$k$` to `Taylor term of degree $k$` in FAQ item 2.

Source hashes at review:

- `TECHNICAL-FAQ.md`: SHA-256 `922f23398cfe402393238fd31bba452c7bf53adedf87c38e7ab3c5ce5bdd81ee`
- `works-in-progress/scaling-tuples/README.md`: SHA-256 `00f8b4a460bc5f977f7d92c57ce43edf1618fed1cac1317d971b1dfa2463c797`
