# Quadratic Gaussian occupation companion: assembly record

26 October 2026. This record describes the assembly and self-check; it is
not an independent audit or Lean verification.

Source: `manuscripts/gaussian-fock-quadratic-occupation.tex`.
PDF: `manuscripts/gaussian-fock-quadratic-occupation.pdf` (four pages).

Source SHA256:
`2a860b2edca3c62a6b082534452845db5a590b568ade1e854dac020831c77137`.
PDF SHA256:
`e6426a30ca68baeba5c45b02d0d432b1aa96e73f36b2724b64024d022b269e14`.

The mathematical source is `gaussian-fock-quadratic-occupation.md`,
independently audited in `gaussian-fock-quadratic-occupation-nongaussian-audit.md`.
The paper includes the exact weighted Hermite-tail proof from
`gaussian-fock-scalar-formulas.md` and an explicit row-sampling proof of the
compatible Hilbert--Schmidt control estimate from
`near-copy-scalar-formula-compiler.md`.

The theorem concerns exact unbiased real arithmetic formulas, with
input-independent random shapes, for common-variance Gaussian Fock maps
in compatible countable coordinate bases. True inputs to every Fock map
have norm exactly one; all other true intermediate states have norm at
most one. Signed partial coordinate injections do not duplicate old
coordinates, and control matrices are Hilbert--Schmidt in those bases.

The proof checks the q-independent creation probability, independent
averages at repeated tensor indices, Tonelli summation over ordered words,
small-step two-copy resets, and large-step averaging resets. Zero controls
and zero rows are omitted before any division. Scalar copies combine
their edge coefficients, preventing a per-layer unary-node cost.

The finite-input readout consequence is a majority of signs of finite
real arithmetic formulas. It does not assert a finite-bit completion.
The free nearcritical estimate is only a normalized feature/readout
representation statement, with initial and readout resources retained.
No variable-diagonal, non-Gaussian, margin-conditioned posterior, or new
learning theorem is claimed.

Build command in `manuscripts/`:
`latexmk -pdf -interaction=nonstopmode -halt-on-error gaussian-fock-quadratic-occupation.tex`.
The final log has no warnings or overfull/underfull boxes; `pdfinfo`
confirms four pages. Correct author names are included in the source.
An initial TeX encoding issue in seven `\rm` commands was corrected before
the final hashes above; this changed typography only.
The parent's fresh full read passed the construction and suggested making
the scalar free-variance comparison explicit. The final source includes
that short proof using invariance below a constant times delta and reciprocal
decay above it. This changes no theorem scope.
