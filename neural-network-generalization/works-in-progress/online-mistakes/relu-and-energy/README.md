# Exact Gaussian energy and posterior identification of AND for ReLU networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex)

This paper gives the exact full-cube margin variation norm of AND for ordinary shallow ReLU networks in every input dimension `q`. It converts that formula to the unchanged isotropic Gaussian energy at every sufficiently large width, with a polynomial threshold `1+binom(q,2)` for `q>=3`.

It also identifies every global-margin energy minimizer after the positive all-plus input and its `q` negative neighbors. Consequently the actual strong-prior posterior concentrates on the entire AND function after those `q+1` labels. The target has a same-depth teacher of width `q+1` and all weights at most one (width two for the two small dimensions).

This theorem does **not** give an exponential online-mistake construction or an arbitrary-order online bound for AND. No additivity statement for several gadgets is proved.

Run `bash build.sh` to regenerate the seven-page PDF. The source and first rendered page have been checked for the required alphabetical author order and footnote; PDF metadata is consistent.

Conventional proof with independent AI-agent checks; not human peer reviewed or formally verified. The full-source review is recorded in [verification](verification/README.md). The theorem is a supporting result; arbitrary-order learning of the AND target remains open here.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob.[^authors]

[^authors]: Authors are listed in alphabetical order.
