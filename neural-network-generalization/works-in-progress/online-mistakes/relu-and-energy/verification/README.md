# Verification record

The paper determines the exact shallow-ReLU margin variation norm of AND in every input dimension and shows that the actual strong-prior posterior concentrates on the full AND function after observing the all-plus input and its negative neighbors, at every sufficiently large width. These reviews cover the norm, equality cases, Gaussian energy transfer, and bounded teacher; they do not establish an arbitrary-order online mistake bound.

The root research agent and the `deep_activation` agent independently derived the odd-dimensional all-atom dual bound and exact norm. The root agent supplied the symmetric second-moment witness proof. The `deep_activation` agent supplied the polynomial-support weighted two-design refinement, equality-case posterior identification, even-dimensional formula and witness, and small-dimensional formulas.

The `tanh_nonlinear` agent independently checked all note-level proofs, including the even-dimensional moment identity, the two small dimensions, the Caratheodory support bound, equality rigidity, Gaussian energy gap, and bounded teacher. It then audited the assembled LaTeX source in full and reported no mathematical flaw. The detailed independent review is in [tanh-review.md](tanh-review.md).

The manuscript was compiled twice with `pdflatex`; the final log has no overfull boxes, undefined references, or LaTeX warnings. The rendered first page was inspected. Author order, the alphabetical-order footnote, and PDF metadata were checked.

These are AI mathematical checks, not human peer review or formal verification. Numerical cone searches guided the original conjecture but are not premises of any theorem in the manuscript.
