# Independent audit of the formula-rank compiler

26 October 2026. **PASS** for the proof note and its assembled Theorem 1.4/Section 6 in `manuscripts/structural-boolean-upper-bounds.tex`, source SHA256 `ca7b33b7f27d20bc82dde32b0ebe4e4eb73124917d187702bbe3512e526f3b7d`.

The Horton--Strahler definition implies that a node has at most one child of its own rank. Equal-rank components are therefore paths, and every off-path child has smaller rank. At a path's bottom, the starting value is either a leaf or the output of a gate whose children have smaller rank. Once lower ranks have been evaluated, each subsequent gate is a unary map of the carried bit; its two truth-table entries are unary functions of a known off-path bit and have constant-depth preparation.

The unary-map composition circuit is explicit and correct. Reset and flip are distinguished by the two output bits. If there is a last reset, only its constant output and later flips matter; otherwise the initial bit and all flips matter. Threshold tests for every suffix flip count, followed by an alternating threshold sum, compute all suffix parities in two stages. The last-reset indicators are mutually exclusive and exhaustive. The final XORs, choices and OR use a further constant number of threshold stages. Count and parity scores have integer margin one; conversion to signed wires uses only polynomially bounded bias coefficients on a charged constant rail.

The path compiler has O((m+1)^2) gates and polynomially many connections. All paths at one rank are computed in parallel. Their squared lengths sum to at most s², and carrying at most s previously computed path roots and d inputs through at most s ranks has polynomial size with a universal degree. Hence total threshold depth is O(r+1), and width, connections and gate norms are polynomial in d+s with degrees independent of r.

Substitution into the audited heterogeneous-prefix resource gives `S=O(log(d+L+3)+(r+1)log(d+s+L+3))`; the layer-count overhead is absorbed because r<=s. The actual-posterior conclusion retains the required learner-depth padding, arbitrary common input distribution, every realizable width, and all canonical prefactors. For fixed r it is polynomial; a general formula can have rank of order log s, giving only the existing quasipolynomial order.

This does not flatten arbitrary bounded-width branching programs: the proof uses the four-element unary Boolean transformation monoid, not a non-solvable larger-state monoid. The manuscript's scope distinction is correct. The earlier three structural theorems are unchanged except for numbering and framing.

Final editorial follow-up: the author corrected only abstract grammar, replacing the mismatched singular pronoun with a coordinated plural sentence. No mathematics changed. Final source SHA256 `dc3b32fdb45c039f502bb431d562bffb67d3623d85fa3a41834ff7733fc065bc` is approved.
