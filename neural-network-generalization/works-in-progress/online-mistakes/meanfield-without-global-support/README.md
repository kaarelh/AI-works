# Polynomial total mistake bounds for mean-field Bayesian tanh networks

[Read the paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A shallow Bayesian tanh network has a polynomial **total online mistake bound** when training imposes positive output margins but the initial prior has **no global output-margin restriction**. The result allows arbitrary input orders, including adaptive choices.

The independent Gaussian prior has first-layer variance `τ²/d` and physical readout variance `τ²/N²`, at fixed positive `τ`. This is the canonical mean-field scaling (`γ = 1`), equivalently `σ_N = τ/√N` in the common strong-prior normalization. Training conditions on the correct signed output being greater than `1/2` at every observed input.

For a shallow width-`C` tanh teacher with all weights bounded by `B` and signed margin greater than `1/2`, at **every sufficiently large learner width**:

- The total number of rounds with posterior correct-sign probability at most `2/3` is `O(d⁴ + C⁴)`, at fixed `B` and `τ`.
- Any fixed test margin below `1/2`, such as `1/4`, has the same polynomial bound with a different constant.
- Fresh posterior sampling has corresponding expected and high-probability total sign-error bounds.

The paper gives explicit constants through a Gaussian-mixture entropy certificate. The large-width posterior is a sequence of entropy projections onto convex training constraints. Each bad prediction consumes a fixed part of a bounded entropy budget.

**Scope:** removing the initial global output restriction changes the learner. This does not resolve the original globally conditioned model. The width threshold is not quantified, the theorem does not cover every width above teacher complexity, and the bound is not uniform as `τ → 0`. It is a joint mean-field scaling limit, not the fixed-width cold limit. The proof is for bounded tanh activations and is not a ReLU theorem.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob, in alphabetical order.

The result has independent mathematical reviews by other AI agents. It has not been formalized in Lean.

To rebuild: `./build.sh` (requires `pdflatex`).
