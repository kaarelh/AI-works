# Verification record

The paper contains mathematical proofs, with independent AI-agent checks. It has not been formalized in Lean.

The core continuous-gate comparison was independently reviewed by the proof-audit agent and the robust-learning agent. The latter's comparison review is included as [robust-agent-comparison-review.md](robust-agent-comparison-review.md). The final integrated manuscript review identifies the exact source snapshot.

The statistical modules give their full proofs. The high-probability relative-loss argument and the arbitrary-prior sharp expectation theorem were independently checked in the preceding research packages. The latter follows the leave-one-out strategy of Høgsgaard, Rebeschini and Wegel (2026), with the arbitrary-prior and conditional-sub-Gaussian extension proved in the manuscript.

The build script performs three clean pdfLaTeX passes in a temporary directory. The build outputs and final log are retained here. The final review records and SHA-256 snapshot identify precisely which source files were checked.
