# Verification record

This paper has independent AI-agent mathematical reviews, source correspondence records, numerical sanity checks, and a clean PDF build. It has not been formalized in Lean.

The mathematical checks cover the weighted sign-feature Gaussian construction; the Gaussian-readout sector and mixture separator; the Fourier convolution, constant-variance sphere embedding and finite quadrature; the fixed-dimensional teacher-growth obstruction; projected readout geometry with broad affine output priors; the fixed-teacher rate lower bound; nested rare-grid construction and weighted occupancy; the Gaussian-noise extension with bounded comparison targets and direct Gaussian witness concentration; the fixed-point width-two implementation of a shallow teacher; and the explicit finite-depth bound with energy O(H³), width exp(O(H)), and excess Ω(H⁻⁶) after exp(Ω(H)) observations.

The proofs distinguish ordinary raw means, clipped raw means, and means of clipped draws. The fixed-law rate theorem with affine output components and Gaussian labels is a raw-mean theorem. The changing-law constant-excess results and the one-fixed-law slow-rate theorem also have separate quantifiers.

`check_fourier.py` and its recorded output verify numerical instances of the Fourier interpolation, mask, convolution identity, and nonzero affine residual. These checks are supplementary; no numerical result is used as a proof assumption.

Run `../build.sh` from this directory, or `./build.sh` from the paper folder, to rebuild in an isolated temporary directory. The mathematical review and exact source hashes are recorded alongside this file.
