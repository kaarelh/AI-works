# Why two natural online upper-bound arguments do not apply

These are rigorous obstructions to proposed proof methods, not a disproof of a polynomial total online mistake bound for the canonical prior.

## Model

For fixed width N and d-dimensional Boolean inputs, use shallow tanh, a constant input coordinate, first-layer variance N sigma²/d and readout variance sigma²/N. The rate energy is

E=(d/N)sum||u_j||²+N sum v_j².

The prior is conditioned on absolute output margin>1/2 at every Boolean input, and then exact training labels. The strong-prior limit below is sigma->0 at each fixed N.

Write

Phi_d(Q)=min_(r>0) [d Q r²+1/(4 tanh²r)].

The essential-coordinate bound from the [anisotropic all-width paper](../anisotropic-allwidth/paper.pdf), specialized to unit coordinate weights, says that every nonconstant sign function g with global margins has energy at least Phi_d(|ess(g)|). A positive dictator x_i attains Phi_d(1) at every width. Phi_d is strictly increasing.

## A near-certain mistake with zero minimum-energy increment

Fix d>=4 and target f(x)=x_1. First reveal the all-positive input with label+1 and the all-negative input with label-1. Constants are excluded. The exact minimum energy is Phi_d(1). The only sign functions at this minimum are the d positive dictators: every other consistent function has at least two essential coordinates, hence energy at least Phi_d(2)>Phi_d(1). (A Boolean function with exactly one essential coordinate is a signed dictator; the calibration selects its positive sign.)

Input-coordinate permutations preserve the Gaussian prior and permute the d dictator cells transitively. Thus at every fixed width the strong-prior posterior converges to the uniform distribution on these dictators.

Now query x_*=(+1,-1,...,-1), whose correct label is+1. Exactly one surviving dictator is correct, so the limiting wrong-label probability is (d-1)/d. This is a majority mistake and violates the two-thirds correctness criterion, and can be made arbitrarily close to certainty by increasing d.

After the correct label is revealed, x_1 remains feasible at precisely the same energy Phi_d(1). The minimum energy therefore increases by zero.

A strict positive energy increment per mistake cannot prove a general online bound, even for this canonical all-width tanh model. A successful bound would need to track tie mass or another potential. This example has only one designated mistake and does not contradict a polynomial total-error theorem.

## Convexifying the training constraints loses the global-margin condition

Consider just the same two calibration examples, and temporarily remove the global absolute-margin requirement at unobserved inputs. Let a_j denote the nonconstant coordinates of row u_j and let c_j be its bias. Put

r²=(1/N)sum_j (a_j dot 1)^2.

The opposite-label margin requirements, the tanh paired-difference inequality, Cauchy--Schwarz, and concavity of tanh²sqrt(s) give

1/2 <=sqrt(N)||v|| tanh r.

The first-layer energy is at least r², because

(d/N)sum||a_j||² >=(1/N)sum(a_j dot1)^2=r².

Consequently the relaxed minimum energy is exactly

min_(r>0)[r²+1/(4 tanh²r)]=Phi_d(1/d),

attained by cloning rows with every nonconstant weight r/d, zero bias, and readout coefficients1/[2N tanh r]. The relaxed optimum is independent of d.

The genuine globally margin-valid minimum is Phi_d(1), which grows at least sqrt(d), by tanh r<=r and AM--GM. At even d the relaxed witness outputs exactly zero whenever the input coordinates sum to zero. At odd d>=3 its smallest absolute output is tanh(r/d)/(2tanh r)<1/2. Thus it is not a valid draw from the actual globally conditioned prior.

This gap persists at every width, including the convex neuron-measure limit. The admissible output functions form a union of disconnected margin orthants; replacing that union by the convex training-only feasible set changes the optimization problem. Standard projection/Pythagorean online arguments for convex hard-margin learners therefore do not transfer directly.

## What remains open

These observations leave room for a polynomial total-mistake bound using a richer potential, and also leave room for an exponential counterexample. A convex feature-mixture representation by itself does not settle the issue: it gives convexity for prescribed signs or for the relaxed training-only problem, whereas the original global-margin union remains nonconvex. A finite-function counting/compression bound gives polynomial logarithmic class size, but a minimum-energy selection rule can visit many different strict energy levels; counting alone does not turn it into a halving algorithm.

## Verification status

Both arguments have undergone an independent AI-agent mathematical check. They have not been formalized in Lean. The global essential-coordinate energy bound used here is proved in the linked paper; no numerical experiment is used as a premise.
