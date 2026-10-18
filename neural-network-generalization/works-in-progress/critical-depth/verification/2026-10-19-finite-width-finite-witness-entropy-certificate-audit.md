# Independent audit: finite-width entropy extraction on a witness set

Reviewed `finite-witness-entropy-certificate.md`, Sections 1–4, on 19 October 2026.

**Verdict: Sections 1–4 pass.** Section 5's near-baseline scalar stability statement is explicitly pending and is not certified by this record.

## Exchangeability and one-layer estimates

The entropy increments a_k are nondecreasing: their difference is the expected conditional mutual information of the next two coordinates, using conditional exchangeability of the unrevealed coordinates. Their sum is the full block KL, so a_K<=B/(N-K). Averaging a_k and the adjacent increments over k=0,...,K-1 gives both stated entropy bounds.

For a bounded test phi, the conditional covariance of two unrevealed observations differs from the product expectation by at most twice the total variation distance, hence at most sqrt(2 times conditional pair KL). The conditional variance of their empirical average is therefore bounded as stated. Jensen, the random-prefix average, and the deterministic 2K/N difference from the full empirical mean give (1), with the displayed constants.

A minor notation clarification is useful: before averaging over the realized prefix, the pair-KL quantity is the pointwise KL of its conditional pair law against the conditional product law. Its expectation is the usual conditional mutual information. The proof uses the pointwise version in the conditional variance bound and the averaged version thereafter.

## Applying it to the conditioned network

Fixing all preceding weight blocks leaves the current block exchangeable under conditioning on one full sign function. Permuting current rows and simultaneously permuting the corresponding columns of the next block (or readout coordinates) preserves the prior and the full sign event. Integrating future blocks proves the required conditional exchangeability. No future block is fixed in this argument.

The pushed-forward conditional row law has KL no larger than the conditional weight-row KL. Its Gaussian reference is the actual preceding empirical covariance, including the singular case. Applying (1) to each tanh-product covariance observable, summing entries, and then applying Cauchy–Schwarz across hidden layers gives (2). In particular, the square-root term contains sqrt(H N A), rather than H sqrt(N A), exactly as stated.

The mean conditional readout lies in every closed training/full-function halfspace. Gaussian mean-entropy duality gives B_out>=N^2||vbar||^2/2. Since K_H=HH^T/N and z=H vbar, its minimum kernel readout cost is at most N||vbar||^2/2. This proves (3) without an additive constant or loss of the scalar baseline.

## Selecting a deterministic approximate path

Markov bounds the probability of any covariance-entry error exceeding delta by eta. Restricting the nonnegative action to this good event gives a realization of cost at most A/[(1-K/N)(1-eta)]. The selected conditional laws can depend on the selected complete realization; their references remain the original preceding empirical kernels, so they form exactly the asserted pseudo-path. No invalid independence claim is used.

For an explicit polynomial choice, let

    eta = min(1/4, tau/[8(A+1)]),
    kappa = min(eta, delta sqrt(eta)/[16 m sqrt(H)]),
    K = floor(kappa N).

For a sufficiently large universal C, choose

    N >= 2/kappa + C H m^2/(eta delta^2)
                    + C H (A+1) m^4/(kappa eta^2 delta^4),

and increase N to ensure K<=N-2. Then K>=kappa N/2, (2) is at most eta delta^2, and the selected action is at most A+tau. This verifies the polynomial assertion, including integer rounding and A=0.

## Limited check of the transfer setup

The preliminary deterministic matrix estimate in Section 5 is also correct: entrywise error delta gives nuclear norm difference at most m^2 delta, and the Powers–Størmer square-root inequality yields a common Gaussian coupling with maximum coordinate RMS error at most m sqrt(delta). The controlled Bures/max-coordinate transfer can therefore be applied to these finite witness domains. Whether the accumulated pseudo-path entropy has the proposed near-baseline square-root budget is a separate lemma and remains outside this audit.
