# Neural converse: mathematical review

The parent agent and a separate circuit-converse agent independently read the complete proof. They checked the exact tanh singleton construction, the staircase matrix inverse and its perturbation bound, normalized first-layer/internal/readout costs, the square-root-energy triangle inequality, and both mistake recurrences. They also checked the passage from fixed-width energy to its unrestricted-width infimum, tied minimizing functions, the order of the two limits, and the expected-mistake conclusion obtained by inverting before averaging. No mathematical correction remained.

The proved statements are an exponential converse for the original support and a polynomial converse with an additional fixed output cap, both after taking the strong-prior limit before the width limit. They do not prove a fixed-width polynomial converse or identify the resulting limit with a finite-exponent width-first variational learner.

The note has no Lean formalization. The exact singleton construction and converse proofs are new here; the final circuit conversion imports the earlier strong-prior compression theorem.

Research-note SHA-256: `27cbe8db2dfaeebf4222dc505971bc6f88b9915f0e7ebb6cd584cc4291a14617`.

Publication-note SHA-256: `6fc2e502fed537a2ada7df020f22705dedff72c67470710a7aa33d727a937c5a`. Publication changes only make set braces render reliably on GitHub and add local navigation links.
