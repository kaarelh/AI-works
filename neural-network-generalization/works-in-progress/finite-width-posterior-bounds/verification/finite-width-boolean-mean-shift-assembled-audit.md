# Independent audit of the assembled linear-width Boolean learning theorem

Date: 26 October 2026.

Reviewed the final assembled Section 3, its theorem, proof, layerwise-resources remark, and its abstract/closing scope in the public finite-width posterior paper. Source SHA256: `fe1a12db26c6efde73160c755360f86b51b8ed18e2f46f8cca724cf42502bb0d`.

## Verdict

PASS. The assembled statement matches the independently checked scratch theorem, including the actual globally margined and exact-fit Gaussian posterior, the full posterior mixture, arbitrary common training/test input distribution, H=L−1 hidden layers, and all finite-width restrictions.

Checks included:

- The AND/OR signed affine margin remains at least 0.8 when both inputs and the explicitly charged constant wire have signed averages at least 0.9. COPY/NOT and the first-layer constant input are handled separately.
- Conditional row variance is at most two in the first layer and one internally for 0<t≤1. Conditional Hoeffding requires no independence across cube inputs. The width threshold bounds both hidden propagation and all-cube readout failures by 1/8 each.
- First-layer, internal, and readout Gaussian mean-shift entropies have the stated constants 450dN/t², 900NC/t² per internal stage, and NC/t². Coincident gate inputs are combined without increasing the coefficient absolute sum past three.
- Binary relative entropy converts the comparison-law good-event probability into the raw target mass with constant 2002.
- Global absolute-margin conditioning can only increase this target truth-table mass. The finite prior-mass exact-fit argument controls posterior Gibbs error, and then the >2/3 confidence criterion; it does not select a minimizer or a single network.
- The variable-width G bookkeeping uses the predecessor width for internal entropy and the final width for readout, and counts constants and padding.
- The statement is expressly linear in learner width only at fixed scale, not width independent. The t⁻² factor prevents a cold-limit conclusion from this particular witness. The below-threshold comparison explicitly assumes N≥C_max and does not claim the sharp d+G coefficient there.
- The hypothesis is a digital bounded-fan-in Boolean circuit at the available learner depth, not an arbitrary soft tanh teacher.

This is an independent mathematical audit, not a Lean formalization or a new audit of the unchanged other sections.
