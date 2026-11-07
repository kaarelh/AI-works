# Fifteen posterior mistakes on the four-dimensional cube

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Exact verification](verification/README.md)

A one-hidden-layer ReLU network with the canonical isotropic Gaussian prior can be wrong at every query after the first on a fixed order of the sixteen Boolean inputs. The prior includes the global absolute output margin greater than one half and exact training labels. At every fixed width `N≥16`, the expected number of posterior-sampling mistakes tends to **15.5** as the common prior scale tends to zero. Posterior majority is wrong on the last fifteen queries as well.

The target is `x₁x₂ ANDsign(x₃,x₄)`. It has a sixteen-neuron teacher with canonical parameters bounded by one and margin `21/40`. Its exact ReLU variation norm is `(5√30+4√2)/6`; all sixteen one-label corruptions are cheaper. The sequential theorem additionally checks every competing Boolean function, so it does not select an unfavorable predictor from a tie.

This is a **finite four-input result**. It does not prove an exponential lower bound as dimension or teacher complexity grows, and the sufficiently small prior scale may depend on the learner width.

The proof is computer assisted, using exact rational and algebraic certificates for all 65,536 Boolean functions modulo 222 symmetry classes. The two verification scripts require Python, NumPy, and SymPy and call no optimizer. Independent mathematical and code reviews checked the certificates and the transfer to the actual Gaussian posterior. This paper is not Lean formalized.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob, listed alphabetically.
