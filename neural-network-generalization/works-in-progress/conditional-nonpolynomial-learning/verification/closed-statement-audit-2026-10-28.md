# Independent audit of the public formal statement

28 October 2026. This audit compares the public paper's central theorem with its literal Lean definitions. It is a statement/scope audit, separate from the final clean build and from the analytic proof audit.

**Conclusion:** I found no mismatch between the central theorem in `conditional-nonpolynomial-learning/source/paper.tex` and `ConditionalImpossibility` / `ConditionalCounterexamples` in `lean/NNBayesStatement.lean`. The definitions genuinely describe the stated nonuniform complexity classes and the original finite-width Gaussian tanh posterior. The qualifications below should remain visible in publication.

## Complexity classes

- `Circuits.PPoly` uses explicit topologically ordered, fan-in-two NAND circuits, with the input bits and two constants available as initial wires. Circuit size counts NAND gates. Requiring the last gate as output changes ordinary circuit complexity by only a constant-size copy construction. Constants and arbitrary finite exceptional input lengths cause no change in P/poly.
- `Circuits.TC1` uses explicit acyclic **unweighted counting-threshold gates** and NAND gates, with polynomial gate-plus-input-wire count and depth at most `B * Nat.log2 (d+2)`. This is the standard nonuniform majority-circuit TC¹ class. A count threshold can be changed into a majority gate by padding with constants, using linear wire overhead; NAND is available from a fixed Boolean basis. Conversely, majority is already an allowed threshold. Counting wires instead of only gates changes polynomial-size classes by polynomial overhead, since ordinary majority circuits can have at most polynomially many incoming wires.
- Repeated input wires are counted, so exponentially large integer weights cannot be smuggled into one gate for free. An arbitrarily large natural cutoff also carries no hidden advice: above fan-in it is constant false, and cutoff zero is constant true. No arbitrary real threshold coefficients are part of these circuit definitions.
- Family constants are outside the input-length quantifier, and there is no algorithm generating the circuits: these are genuinely **nonuniform** classes. The `d+2` and floor-log conventions handle small dimensions without changing the class.
- `ThresholdToBoolean.TC1_subset_PPoly` is proved by an explicit polynomial NAND simulation. The separation assumption is the usual `PPoly ≠ TC1`, not an abstract separation between learner-dependent classes.

## Neural model and statistics

`Network.lean`, `Model.lean`, and `FunctionPrior.lean` agree with the displayed model:

- Boolean bits encode the signed cube; the sole initial constant coordinate is `1`.
- `L = r+2`: one input matrix, `r` hidden-to-hidden matrices, and a scalar linear readout. There are `L-1` hidden layers, all of width `N`, with neuronwise tanh and no separate hidden biases.
- `canonicalPrior` is an actual finite product of independent centered Gaussians. `canonical_variance` proves exactly the three variances `t²/d`, `t²/N`, and `t²/N²`, including the first-layer constant coordinate.
- The posterior is the actual pushforward to sign functions. It weights **each candidate function** `g` by its Gaussian mass on the global signed half-margin event and then conditions on `g` agreeing with the observed target labels. It does not accidentally condition on the target labels at unseen inputs. Disjoint sign events partition the global absolute-margin event, so this is exactly global `|z|>1/2` conditioning followed by exact noiseless training fit.
- `sampleProbability` is the finite product IID law. Repeats are allowed. The same arbitrary `InputLaw` is used for training and testing; there is no distribution shift.
- Success means test mass at most `1/16` where posterior correct-label probability is **at most** `2/3`. Thus equality at `2/3` is a failure. The sample-level success probability is at least `1/2`. This is a posterior-confidence criterion, not bare majority/sign prediction or posterior-mean regression.
- Conditioning denominators are proved strictly positive for every eligible target-labeled sample and width. The counterexamples do not exploit undefined conditioning.

## Teacher resources and quantifiers

`realizesAtComplexity` requires an actual width-`C`, depth-`L` tanh teacher, every coefficient bounded by `C`, and signed output strictly greater than `1/2` everywhere. It requires an implementation, not that `C` is minimal. This matches the paper's teacher-resource definition; narrower layers can be zero padded for tanh.

The ordinary Boolean-circuit reduction has polynomial-resource teachers: `C=d+s+256` and `L=d+s+3`. The explicit teacher uses fixed gain 64, readout gain 2, and coefficient magnitudes at most 192. Thus the obstruction does not rely on encoding a truth table in arbitrary real precision. The central quantified target class allows real coefficients, but the hard-family construction uses digital constant-magnitude weights.

For each prescribed scale schedule, the positive polynomial coefficient and integer degree are chosen **before** dimensions, teacher width/depth, learner width, input law, and sample count. They may depend on the chosen schedule. The schedule itself depends only on `(d,L,N)`, not on the target, input law, or realized training sample. The guarantee covers every `N≥C` and every integer `n` above its polynomial envelope. The counterexample statement negates exactly that guarantee, giving failure probability strictly greater than one half. The family proof fixes sample count before choosing width and then evaluates the schedule at that width; the input law is chosen later. There is no circular width/scale choice.

## Scope qualifications and publication checks

1. This rules out a **joint universal polynomial in input dimension, teacher width, and depth**, independent of learner width. It does not establish an exponential or stretched-exponential depth lower bound, nor refute fixed-depth polynomials whose degrees depend on depth.
2. The distribution-free and all-width quantifiers matter. The theorem does not give a uniform-input lower bound, and the width chosen in the contradiction can be exponentially large in input dimension. It is not a runtime lower bound for posterior inference.
3. The formal theorem covers every **positive** schedule `0<t≤1`, including the fixed-exponent family `γ≥1`. It does not itself state a theorem about the exact `t=0`/zero-temperature limiting posterior. A limit corollary would need its own statement and limit argument.
4. “Unrestricted” still retains the global absolute-margin conditioning. The theorem does not address a raw Gaussian posterior without that convention, non-tanh activations, noise, or a bare `>1/2` prediction criterion.
5. The need to change the prior is conditional on retaining the other listed architecture, target, likelihood, width, distribution, and prediction conventions. Restricting prior support is not asserted to be the uniquely necessary change.
6. The paper's analytic proposition is stronger than the public `AnalyticPosteriorCeiling` interface: the latter fixes posterior mass `5/6`, exact positive sample count, and realizable targets; the displayed proposition allows arbitrary `β`, samples up to a budget, and arbitrary positive conditioning events. The narrower formal interface is fully sufficient for the central theorem. Do not describe every quantifier of that stronger displayed proposition as independently formalized merely from the central entry point.
7. Likewise, the fixed-hard-family / one-law-for-all-widths-and-scales corollary is not a separately closed family-level declaration in the reviewed public modules. Its finite hard-law constituent is proved in `PosteriorBridge`, and the conventional corollary follows the stated common-class argument. Distinguish verification of the central theorem from a claim that every supplementary corollary has its own exact Lean statement.
8. The reviewed public README, verification record, paper abstract, and formal-verification section still describe the analytic ceiling as unproved. Those status passages must be updated once the new closed entry point and clean build are published. The older files' local comments that they prove a reduction under an explicit premise can remain accurate, but should link to the module discharging that premise.

Files reviewed: public `Circuits.lean`, `CircuitFamilies.lean`, `ThresholdToBoolean.lean`, `NNBayesStatement.lean`, `TeacherCompilation.lean`, `TeacherFamilies.lean`, `PosteriorBridge.lean`, `AnalyticCeiling.lean`, `FamilyCollapse.lean`; concrete library `Network.lean`, `Model.lean`, `FunctionPrior.lean`, and NAND circuit definitions; scratch `ClosedConditionalImpossibility.lean` and `StructuralPosteriorAssembly.lean`; public paper source, README, and verification record.
