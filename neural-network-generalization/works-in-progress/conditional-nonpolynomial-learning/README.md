# A conditional obstruction to polynomial sample complexity in unrestricted NNbayes

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Lean project](lean/README.md) · [Verification scope](verification/README.md)

**Assuming nonuniform P/poly differs from TC¹, the original unrestricted Gaussian tanh learner has no universal sample bound polynomial jointly in input dimension, teacher width, and teacher depth, independent of learner width.** This holds separately for each prescribed canonical scale schedule, including every fixed `gamma >= 1`. Accuracy and confidence can already be fixed constants.

The learner retains global absolute margin greater than `1/2`, exact fit of noiseless training labels, and a strict `>2/3` posterior correct-label criterion. Training and testing have the same arbitrary input distribution. The guarantee being ruled out must cover every learner width above teacher width; inference has no computational restriction.

The paper makes the conditional negative result central. It gives the complete finite majority/boosting reduction, the bounded-weight Boolean-to-tanh implementation, and the order of quantifiers in the circuit-class collapse. Its analytic input is the actual-posterior circuit ceiling from the [parallel-complexity paper](../boolean-depth-barriers/), stated explicitly here with its width, depth, scale, and sample conditions. The appendix explains its proof mechanism, and the Lean development proves the required fixed-probability version from the actual Gaussian model.

This is **not an exponential-depth lower bound**. It rules out a universal polynomial guarantee under the stated conjecture. If the target class and the other learning conventions are retained, obtaining that guarantee requires changing the prior; a robustness restriction is one possible change. Restricting the target class or input laws, or changing other parts of the learning setup, are alternative ways to change the premises.

## Formal verification

**The central theorem and its finite counterexample formulation have closed Lean proofs.** The [main entry point](lean/ClosedConditionalImpossibility.lean) proves `ConditionalImpossibility` with no analytic premise beyond the stated complexity-class separation. It includes the actual Gaussian posterior ceiling, all three scale regimes, explicit circuit compilation, teacher compilation, finite boosting and the family-level contrapositive.

An [independent expanded statement](lean/IndependentLiteralMainAudit.lean) spells out the actual posterior failure event and positive conditioning denominators. The [verification record](verification/README.md) provides source hashes, clean-build records and independent statement audits. The formal claim covers positive finite-scale schedules; the exact zero-temperature limiting posterior and the paper's stronger fixed-hard-family corollary are not separately formalized here.

## Reproduction

Run `./build.sh` with `latexmk` and a standard TeX installation. Generated files under `source/` are excluded from version control; the published PDF is `paper.pdf`.
