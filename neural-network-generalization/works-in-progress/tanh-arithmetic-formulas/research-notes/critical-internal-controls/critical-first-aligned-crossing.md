# A first aligned crossing has small total prefix entropy

26 October 2026. Continuation of critical-nearbaseline-signed-alignment.md. All statements concern arbitrary finite-entropy critical row-control paths, not a Gaussian-restricted subclass.

Let the full hard-margin action be A<=V_*+epsilon, with epsilon<=1 and hence A<3. Suppose a bottleneck layer b has maximum query variance q_b. Set

    E=epsilon+C q_b,

with C at least the scalar bridge constant. Fix K>=1 and assume E is sufficiently small in terms of K. Let q_j=max_x Q_j(x,x), and let j be the first index after b for which

    q_j > K E.

Choose K large enough that q_b<=K E. Such an index exists: the final readout cost is at least 1/(8q_H), so q_H>=1/(8A)>1/24, whereas K E is chosen below 1/24.

**Proposition.** At this crossing,

    K E < q_j <= K E exp(C_K sqrt(E))
                   <= K E[1+C'_K sqrt(E)],           (1)

and the ENTIRE hidden prefix, including layers before the bottleneck, has entropy

    sum_(i=1)^j D_i <= C_K E.                        (2)

The constants depend only on the fixed K and the universal scalar estimates.

**Proof.** For every query, Gaussian entropy duality and tanh²z<=z² give

    Q_i(x,x) <= Q_(i−1)(x,x) R(D_i),

where R(D)>=1 solves R−1−log R=2D. Thus q_i<=q_(i−1)R(D_i). Since D_i<=A<3, and R(3)<10, the first crossing has q_j<=10K E.

Choose x_j attaining q_j. Scalar comparison for this single witness input gives the entire suffix, including its margin readout, action at least V(q_j). All earlier costs are nonnegative, so

    sum_(i=1)^j D_i <= A−V(q_j)
         <= epsilon+[V_*−V(q_j)]
         <= epsilon+C q_j
         <= C_K E.                                  (3)

The small-state scalar bridge applies because 10K E is in its range. In particular D_j<=C_K E. Since log R(D)<=2sqrt(D), substituting this sharper one-step entropy bound into the crossing inequality proves (1).

No assumption is made that the maximum variance is monotone, that the maximizing input is the same at different layers, or that the controls before b were free. The suffix comparison uses one input chosen at layer j, which is enough.

## Consequences and the remaining issue

Choose K from the preceding signed-alignment theorem for a fixed small radius eta. Then at this first crossing all signed features are eta-close to one maximum-norm anchor, while all row controls that created them have total entropy O(E).

After the bottleneck and before the crossing, every maximum variance is at most K E. Therefore the elementary weighted budget also obeys

    sum_(i=b+1)^j q_(i−1) D_i <= C_K E².              (4)

The universal critical maximum-variance drift in universal-quadratic-variance-and-diagonal-occupation.md gives the further bounds

    sum_(i=b+1)^j q_(i−1)² <= C_K E,
    sum_(i=b+1)^j q_(i−1) sqrt(D_i) <= C_K E.         (5)

For the first inequality, telescope q_i−q_(i−1)<=C D_i−c q_(i−1)² from b to j, drop the nonpositive final term, and use q_b<=E/C and (2). The second follows by Cauchy--Schwarz and (2). Thus both the entropy and the quadratic variance occupation of this task-bearing low-variance interval are O(E).

This is potentially stronger than treating the small-entropy row controls independently with a triangle inequality. For example a nonlinear residual estimate with squared cost O(q D) could sum to O(E²) if it admitted a compatible orthogonal-innovation decomposition. Such a decomposition, stable under the subsequent controlled dynamics and suitable for an exact Boolean circuit compiler, has not been proved here. Equation (4) alone does not justify replacing arbitrary row laws by Gaussian laws or discarding those residuals.

