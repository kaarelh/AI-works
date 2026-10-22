# Quadratic-width learning with stable neuron populations

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Independent review](../verification/neuron-averaging-review.md)

For layered Boolean teachers of width `C`, this paper proves a quadratic-width, polynomial-depth sample bound at every learner width `N >= C` and every `gamma >= 1`. It uses a stronger prior-support condition: neurons can be averaged into a controlled number of balanced populations without substantially changing clipped predictions. The condition can be combined with the existing internal-noise restriction or imposed by itself.

The paper gives explicit budgets, a different population-count calibration with improved depth dependence, and a literal `C²` envelope with a universal polynomial in the other resources. It does not prove the same result under the original robustness condition alone or establish the new condition for ordinary trained networks.

The target construction builds on the earlier robust-prior work, including contributions from Claude. The new Gaussian partition bound and learning argument have independent AI-agent mathematical review. This paper is not Lean verified and has not received full human mathematical review.

Run `./build.sh` to rebuild `paper.pdf` with `pdflatex`. Build products are kept in the ignored `build/` directory. See the [collection overview](../README.md) for the relationship to the other improved bounds.
