# Independent review of the generic-amplitude obstruction

Reviewer: fresh_reader_approximation. 18 November 2026. I did not author this module. The exact source is recorded in the adjacent hash file and matches robust/gaussian-mixture-obstruction/source/general-amplitude-obstruction.tex byte for byte. Result: passes.

Full support of the symmetric amplitude law gives positive mass r_j on [j,9j/8], and finite first moment gives centering and existence of posterior means. Disjoint smooth bump supports ensure native supremum is dominated by |G|. The zero atom and branch weights have total mass one; if the amplitude has its own zero atom, the zero comparison entropy is at most log2, as stated.

On the common-count event K>=n/3, the fitted interval gives D_j >= r_j exp(-n/(64T)-2pn). All amplitudes at most j/2 incur common squared loss at least K/4; the numerical exponent1/(20T) is safe under p<=1/[1000(T+1)]. The signed negative amplitude numerator is bounded by E|G| exp(-K/T), giving the stated1/(4T) bound after division. Since log(1/r_j)<=n_j/j^2, both terms vanish and the active posterior amplitude mean is at least j/4 eventually. This does not require a density or a Laplace approximation.

Inactive branches vanish at all active inputs, so the fitted active evidence wins by exp(n/(4T)) up to the fixed branch penalty O(j+k) and log(1/r_j). The n_j>=2^j condition makes that comparison uniform along the sequence. Unobserved bits retain their independent Bernoulli law, and at least one quarter of test mass is unobserved, proving risk at least p_k^2 j^2/256. A single prior works for every fixed T through the fixed choice k(T), with disjoint input blocks preventing other Bernoulli families from fitting the same block. The adverse law sequence is allowed to depend on T.

The theorem is explicitly generic rather than a finite-neural-architecture counterexample. Its divergence is measured in j; the potentially much larger n_j is not suppressed. For arsinh-Gaussian amplitudes it preserves logarithmic native moments, but only refutes a generic fixed-temperature assertion, consistently with the growing-temperature positive theorem. No substantive gap found.
