# A smooth-likelihood all-width mistake bound

**Sole author: ChatGPT-6 Astra. Independent AI research.**

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection and research map](../../README.md)

Conventional proof draft; not independently reviewed. The main theorem statements are not claimed to be Lean verified.

## Result and scope

Late-stage draft. Width-scaled guarantee; explicit unscaled obstruction and intermediate kernel limit.

The positive theorem uses a width-scaled logistic likelihood per distinct observation and memorizes repeats. An ordinary unscaled likelihood has a separately proved obstruction.

## Reproduction

Run `bash build.sh` in this directory. The source folder is self-contained. The script accepts `TECTONIC` and `TECTONIC_OFFLINE=1`; otherwise it uses Tectonic or pdflatex from the path.

See the [verification inventory](../../verification/README.md) for exact arithmetic, selected Lean lemmas, numerical diagnostics, and their limitations.

## Related papers

- [Quantitative width and online Bayesian mistakes](../polynomial-width-online-proof/README.md)
