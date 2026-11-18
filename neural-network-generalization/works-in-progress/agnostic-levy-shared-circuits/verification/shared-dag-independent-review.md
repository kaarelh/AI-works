# Independent review: shared circuit comparison
Reviewed both exact sources. No mathematical gap found.

Every relevant hidden vertex has an outgoing nonzero edge, so E>=V. Disjoint per-vertex index groups and threshold-separated designated coordinates decode an embedding even with repeated shared children; all relevant vertices are reachable backward from the output. Mixture entropy subtracts V location choices from E fan-in penalties and leaves exactly (E-V) log N. The fixed-index small-width branch absorbs V log N into V log(2(V+1)). Sparse first-layer coefficients cost E1 log(d+1), while all centered background coordinates together cost a row-level logarithm.

The first-moment path and error recursions only require independence of the current layer from earlier features, so correlations from sharing are harmless. Their constants can be chosen independent of depth. Under hidden-row absolute-gain stability, native gain <=1/2 controls the global average path bound; selected bounds grow linearly and accumulated approximation error quadratically in depth. For bounded activations deterministic feature bounds remove the native-gain assumption.

Scope: arbitrary shared circuits retain logarithmic learner-width cost. Formula comparators, for which E=V, recover width independence.

This is an independent mathematical source review, not a Lean verification.
