# The Christiano point, domain by domain

A research report on the *Christiano point*: the point at which AI's contribution to a domain or process overtakes humans' contribution. It is assessed across these domains, as of 2 October 2026:
- mathematics and its subareas
- physics
- biology
- software engineering
- ML research
- frontier AI development
- frontier algorithmic progress
- the whole economy

Start with [the report](report.md). Its §0 is a two-page summary.

- **report.md**: the report. It covers the concept and its sources, six inequivalent readings of "contribution" and how they relate, domain-by-domain evidence, synthesis, forecasts, caveats and sources.
- **figures/**: the summary figure, in light and dark versions.
- **models/**:
  - `crossover_definitions.py` numerically checks the facts in §2 and Appendix A: uplift, Euler/Aumann–Shapley and two-player Shapley shares in the task model.
  - `rd_multiplier.py` is the Monte Carlo model of the AI R&D progress multiplier (§6.3, Appendix B).
  - `make_figure.py` draws the figure.
  - The `*_output.txt` files hold the script outputs.

Reproduce (Python 3 with numpy and matplotlib):

```sh
cd models
python3 crossover_definitions.py
python3 rd_multiplier.py
python3 make_figure.py
```
