# Independent mathematical review

Reviewed by the tanh nonlinear research agent on 7 November 2026.
Reviewed source: `../source/paper.tex`, titled *Exact Gaussian energy and
posterior identification of AND for ReLU networks*.

Result: no mathematical error found in the full assembled source.
This is an independent AI mathematical audit, not human peer review or
formal verification.

The review checked the following claims against the source, rather than
relying only on the earlier research notes:

- The all-atom dual bound, including both halfspaces, the adverse component
  along the all-ones vector, and the equality classifications. The modified
  even-dimensional coefficient has exactly the required norm `D`, and the
  positive equality atom has nonnegative neighbor preactivations.
- The uniform subset first and pair moments. The displayed formulas for
  `E Y_i^2` and `E Y_i Y_j` correctly give the stated second-moment identity.
  The pointwise quadratic inequality yields the full-cube lower bound on
  the negative atom average, not only the star margins.
- The matching witness coefficients and exact odd/even norm formulas.
  The pair-indicator vectors lie in an affine space of dimension at most
  `binom(q,2)-1`, so Caratheodory gives at most `binom(q,2)` negative atoms.
  Pair moments imply first moments because `k>=2`. The Hadamard refinement
  is valid under its explicit existence assumption.
- The separate q=1 and q=2 dual arguments, witnesses, exact costs, and
  bounded teachers. In the q=2 positive dual bound the term
  `A b-2 ReLU(b)` is nonpositive for both signs of b, and positive equality
  uniquely identifies the stated hinge direction.
- Per-neuron ReLU balancing gives the canonical Gaussian energy at every
  integer width above the stated sufficient threshold, with zero padding.
  Readout amplification identifies strict-cell infima with weak minima.
- Equality in the dual after the star sample restricts all positive
  coefficient atoms to one hinge and all negative coefficient atoms to
  nonnegative hinges that vanish at the center. This forces output below
  `1/2` at every other input; the global weak absolute margin therefore
  forces a negative label there.
- The posterior argument uses the actual full posterior. The finite union
  of bad weak sign cells is closed, the energy is coercive, and rigidity
  gives a strictly positive energy gap. A ball around a strict feasible
  near-minimizer gives the Gaussian denominator bound. No selection among
  tied parameter minimizers is made.
- Further target-consistent labels preserve the entire AND cell, so its
  posterior probability cannot decrease. The expected-mistake conclusion
  is correctly limited to fixed q,N and a continuation without repetitions.
- The main theorem explicitly retains the fixed-width cold limit and does
  not claim an exponential online lower bound or an arbitrary-order upper
  bound. The stated unit-weight teachers have the claimed margins and
  widths.

The author ordering, author footnote, and PDF-author metadata in the source
are consistent with the repository convention. This audit did not rebuild
or visually inspect the PDF.
