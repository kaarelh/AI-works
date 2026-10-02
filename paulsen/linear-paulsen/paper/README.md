# A linear bound for the Paulsen problem — paper

The main file is `linear-paulsen.tex`. All included fragments are in `sections/`:

- `intro.tex`: statement, optimality and plan
- `toolbox.tex`: projections, scaling, barrier constant, static balancing, dense cores, seeds
- `bounded.tex`: Hamilton–Moitra
- `manyrow.tex`: the many-row seed
- `moderate.tex`: the drifted moderate-row seed
- `assembly.tex`: the three-case assembly and the derivation of both main theorems
- `gaussian.tex`: Gaussian tools (appendix)
- `formal.tex`: the Lean formalisation (appendix)

The bibliography is part of the main file, so BibTeX is not needed. To build:

```sh
pdflatex -interaction=nonstopmode -halt-on-error linear-paulsen.tex
pdflatex -interaction=nonstopmode -halt-on-error linear-paulsen.tex
```

The Lean source is in `../lean/`. Appendix B of the paper maps the paper to the Lean modules, describes the encoding, and lists the explicit values that the formalisation exhibits for constants the paper only asserts to exist.
