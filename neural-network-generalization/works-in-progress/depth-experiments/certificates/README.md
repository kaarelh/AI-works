# Public certificate sources and selected proofs

The [public reproduction guide](../REPRODUCTION.md) identifies immediate checks,
from-scratch regeneration commands, and the large artifacts omitted from Git.

The complete small model-500 all-domain certificate and the model-105 saved
counterexample are independently checkable from this repository with
`python ../verify_representative.py`. Code and original weights are also provided
to regenerate the deeper Boolean and complete MNIST data proofs.

Large per-input tables and thousands of exact matrix-factor snapshots are listed
in the original replay manifest but are not all committed here. A summary JSON
alone is not substituted for replaying its omitted proof components.

[ORIGINAL-CERTIFICATES-README.md](ORIGINAL-CERTIFICATES-README.md) preserves the
historical documentation of the complete original archive. Read it together with
the public guide rather than assuming every historical path is already populated.
These verifiers are exact-integer/outward-interval computations, not Lean proofs.
