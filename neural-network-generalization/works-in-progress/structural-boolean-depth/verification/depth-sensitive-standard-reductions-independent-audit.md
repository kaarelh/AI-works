# Independent audit of depth-sensitive standard reductions

25 October 2026. Audited `depth-sensitive-standard-reductions-audit.md`.
**PASS for the two stated structural product upper bounds and their scope.**

The short-prefix/narrow-cut argument correctly requires synchronous Boolean
dataflow, or inclusion of all later-injected input bits in the cut state.
If every earlier layer has more than `y` gates, its length is at most `s/y`.
The retained prefix uses the existing resource-sensitive cone compiler,
and a truth-table decoder costs logarithmic product `O(y)`; the exponents
add. Prefix output accuracy only needs to be inverse polynomial in `y`:
each pattern-detecting threshold has fan-in `y` and a fixed Boolean gap.
The decoder's exponentially many false-pattern leaks are handled by a
gain `O(y)` inside the decoder, already charged by its `O(y)` exponent.
Thus no exponentially small accuracy is silently demanded of the prefix.
Optimizing `y+(s/y)K/log(K+2)` gives the claimed square-root bound.

For the treewidth argument, enlarging each bag by the predecessors of its
vertices has size at most three times the old size. For any vertex `u`,
the newly included bags are the union of its old connected bag subtree
with the old bag subtrees of its successors. Each successor subtree meets
the subtree of `u`, because their original edge is covered. This proves
running intersection after the enlargement. Every gate's full scope is
then covered by a bag. In the dynamic program, the overlap of the two
child subtrees is contained in the parent bag, so compatibility with a
fixed parent assignment is sufficient for gluing satisfying assignments.
Input equations introduce only literal conjunctions in each local table.

The table count, wire count, retention of local terms until their merge,
and final existential OR over root assignments are all
`2^{O(k)} poly(v+d)` at `O(log v)` threshold depth. Identity wires and
charged constant rails fit these bounds. A gate with fan-in at most `F`
can tolerate preceding errors `O(1/F)` and attain such output accuracy
with tanh gain `O(log(F+2))`. Even when `F=2^{O(k)} poly(v+d)`, each layer's
log Frobenius norm is therefore `O(k+log(v+d))`. This validates the claimed
`O((k+log(v+d)) log v)` logarithmic product.

The generic depth-only theorems are not treated as polynomial-size
simulations, and the arithmetic formal-degree condition is not replaced
by Boolean functional degree. No treewidth, cutset, or pebbling lower
bound is promoted to an intrinsic neural lower bound. The note also
correctly distinguishes integer arithmetic sign formulas from ordinary
Boolean formulas in its discussion of the forward PNC1 compiler.

The separate literature claims are attributed to primary sources; this
audit verifies the displayed neural-resource deductions rather than
independently reproving every cited circuit theorem.
