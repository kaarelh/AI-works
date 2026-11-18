# Independent mathematical review

Reviewed the complete frozen source, including the one-hidden-layer addition, on 18 November 2026. No substantive proof gap was found. This is a conventional mathematical audit, not a Lean formalization.

The audit checked the conditional Gaussian residual-operator concentration with mean term omega^(-1/2), the exact latent Gram bound, vector/profile propagation without a rank multiplier, scalar terminal sampling, and the parameter exponents p_H=H^2+2H-2 and q_H=4H-2. The effective-width cutoff starts at layer two and equals C_H K^((H^2+H-4)/2) a^(-(2H-2)).

Statistical uniformity is applied to fixed compact program families. The auxiliary good set may depend on the sample because its prior tail is pointwise valid for every fixed sample. The entropy and posterior-tail arguments preserve these quantifiers. The complementary effective widths are covered by the simultaneous-scale PAC-Bayes lemma with kappa_N=sqrt(N/T_0); the resulting term is 512 T_0/(n lambda^2), and the main sample budget dominates it.

The activation extension to bounded C^2 functions with |phi'|<=1 and bounded phi'' is supported, including nonzero phi(0). The generic shallow normalized-atom argument and the sharper monotone shallow halfspace-mixture argument were separately checked. The corrected normalized-atom integral uses phi'(tr(u dot x)).

The main statement matches the proof: one sample event covers every N above the comparison width and every tau in (0,1]; labels are arbitrary bounded IID labels; predictions and likelihood use raw outputs; no architecture prior is used. Fixed-comparator rates are n^(-1/2), n^(-1/8), and n^(-1/(H^2+2H-1)) for H=1, H=2, and H>=3, respectively, up to the stated logarithms. Constants may depend strongly on depth and activation derivatives.
