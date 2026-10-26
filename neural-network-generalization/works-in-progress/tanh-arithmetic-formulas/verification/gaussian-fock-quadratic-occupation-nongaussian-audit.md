# Independent audit: quadratic Gaussian occupation

26 October 2026. Auditor: `/root/critical_nongaussian_formula`.

**PASS** at source SHA256 `dc68a9fee3a270daa95c71c0e328f0d53be8ddbb02a3957c17373bd3b9a7a00e`.

The orthogonal new-coordinate construction is valid. Averaging m_k=ceil(kV) independent children bounds the tensor product trace by e. With creation probability 1/(C k^2 V), the nonzero degree-k branch costs O(k^2 V T), while its zero branch costs one, so the common scalar-coordinate size remains at most T for T>=2 and a sufficiently large numerical C. The degree-one branch is a literal coefficient-weighted copy; no new residual addition forces an O(q) creation probability.

The integrated second moment is b_1^2 V + e sum_(k>=3) b_k^2/p_k. The previously proved weighted Hermite estimate therefore gives V_new<=V(1+Cq^2). The two-copy resets, their count, and the large-step averaging give exp(C sum q_j^2) work. Combining scalar coefficients on copied edges is consistent with the established arithmetic-formula model and its later finite-bit normalization.

The Hilbert--Schmidt extension is correctly conditional on the earlier compatible-coordinate, unit-mean-norm hypotheses. The text does not apply it to arbitrary variable diagonals. The uncontrolled nearcritical consequence includes initial and readout resources and is explicitly a feature/readout representation result, not a theorem for a margin-conditioned posterior or a positive teacher-complexity sample bound.

No mathematical correction was needed.
