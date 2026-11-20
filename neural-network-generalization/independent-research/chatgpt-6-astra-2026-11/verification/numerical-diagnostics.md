# Numerical diagnostics and interrupted campaigns

The campaigns were interrupted between active sessions. The table reports completed jobs, rather than counting planned work as finished. These are diagnostic calculations, not proof certificates.

| Campaign | Completed / planned | Scope |
| --- | --- | --- |
| cold_transfer | 12 / 24 | Paired MCMC starts; no mixing guarantee. |
| mitm_campaign | 20 / 24 | Gaussian smoothing, finite-cube sums and Monte Carlo. |
| universal_smoothing | 27 / 36 | Uniform/Laplace smoothing; finite-cube sums and Monte Carlo. |
| scalar_sampler | 50 / 54 | Independent scalar-posterior proposals; restricted-cone importance diagnostics. |



The cold-transfer package contains four parameter snapshots per completed chain and its recorded observables. `analyze_cold_transfer.py` recomputes those observables and fits fresh Gaussian readouts. Large raw parameter trajectories are omitted. Campaign manifests preserve historical commands; rerunning the campaign scripts regenerates paths for a new checkout.



The scalar runs support slow finite-width convergence: at width 262,144 and margin 1, the stored replicate `d4_N262144_s1_rep0` has mean classification error about 0.0666, approaching the proved limit 1/16. Its empirical normalized-weight discrepancy is about 0.0133. That number is **not** a total-variation bound for the full posterior; omitted configurations are not controlled by this numerical check.



The new full-label independent constructions have exact finite-algebra checks and conventional probability proofs. They do not yet have an end-to-end numerical implementation in this collection.



The Fourier analysis files record achieved sample counts, including explicitly partial jobs. High-precision integrals are non-interval computations. Compare the stored lower/upper expressions and empirical errors with those qualifications.



See [diagnostics-summary.json](../results/diagnostics-summary.json) for completed job names and scalar aggregates.
