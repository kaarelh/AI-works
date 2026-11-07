# Source check: existing triangle-wave activation

Verified 7 November 2026 using the publisher's PDF and abstract page, plus the authors' publication records for the page range.

* Authors, in published order: **Lassi Meronen, Martin Trapp, Arno Solin**.
* Title: **Periodic Activation Functions Induce Stationarity**.
* Venue: **Advances in Neural Information Processing Systems**, volume **34**, **2021**, pages **1673–1685**, Curran Associates, Inc. The conference is NeurIPS 2021 (the 35th conference; volume 34 should not be confused with the conference ordinal).
* Publisher PDF: <https://proceedings.neurips.cc/paper_files/paper/2021/file/0d5a4a5a748611231b945d28436b8ece-Paper.pdf>.
* Publisher abstract: <https://papers.nips.cc/paper_files/paper/2021/hash/0d5a4a5a748611231b945d28436b8ece-Abstract.html>.
* Page range also appears in Martin Trapp's and Arno Solin's publication records and DBLP.

Section 3.2, printed page 6, equation (11), defines the period-`p` triangle wave as

\[
 \psi_p(x)=\frac4p\left(x-\frac p2\left\lfloor\frac{2x}{p}+\frac12\right\rfloor\right)
 (-1)^{\lfloor2x/p+1/2\rfloor}.
\]

Putting `p=4` gives exactly our odd, period-four function `phi`, with `phi(t)=t` on `[-1,1]`. No amplitude adjustment is needed relative to their equation (11).

Their subsequently scaled activation in equation (12) instead uses period `2pi`:

\[
 \sigma_{\rm triangle}(x)=\frac{\pi}{2\sqrt2}
 \left(x-\pi\left\lfloor\frac x\pi+\frac12\right\rfloor\right)
 (-1)^{\lfloor x/\pi+1/2\rfloor}.
\]

The exact relationship is

\[
 \phi(t)=\frac{4\sqrt2}{\pi^2}
          \sigma_{\rm triangle}\left(\frac\pi2t\right).
\]

This source supports prior use of the **triangle wave itself** as a neural activation. It does not establish that our strictly monotone affine-plus-triangle combination is a standard activation. Their stationarity discussion uses other prior assumptions, including a uniform bias distribution in this section. No prior-transfer, posterior, or online-mistake claim here is imported from that paper. Their phrase “periodic ReLU” also refers to a separate periodic activation, not ordinary ReLU.

Ready-to-use LaTeX and BibTeX are in `triangle-activation-reference.tex` and `.bib`.
