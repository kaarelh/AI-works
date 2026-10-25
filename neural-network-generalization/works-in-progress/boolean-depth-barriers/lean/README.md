# Lean components of the Boolean-depth argument

These ten modules verify analytic prefix compression and relevant-coordinate reduction. They **do not** formalize the complete finite-bit TC¹ compiler or any posterior-learning theorem.

The checked versions are Lean **4.32.0** and mathlib commit **81a5d257c8e410db227a6665ed08f64fea08e997**. The project files pin those versions and all transitive dependencies.

With [elan](https://github.com/leanprover/elan) installed, run from this directory:

```sh
lake exe cache get
./build-analytic.sh
```

The first command downloads mathlib's compiled dependencies through its normal cache workflow. The second builds required dependencies and checks all ten local files in dependency order, putting generated objects in `.build/`. It does not rely on previously compiled local files.

An existing project with the same pinned mathlib revision can also be used:

```sh
./build-analytic.sh /absolute/path/to/mathlib-project /absolute/path/to/lake
```

[analytic-interfaces.txt](analytic-interfaces.txt) states each module's hypotheses and concrete conclusions. The most substantial theorem, `polynomial_analytic_prefix`, returns an actual finite network, bounded prefix width, actual normalized prototypes, and an exact geometric label decoder. The probability modules prove the finite concentration inequalities used in compression rather than assuming them.

`BooleanRelevant.lean` proves the relevant-coordinate count, dependence only on those coordinates, and a norm-nonincreasing replacement that freezes irrelevant variables while preserving every label's margin. This replacement keeps the original coordinate index set and zeros the irrelevant columns; deletion and reindexing are not formalized.

The unformalized steps include lookup quantization, finite-bit arithmetic, conversion of the geometric decoder into threshold gates, and all later posterior and target-mass theorems. Whole-vector activations are allowed in the geometric cover module only; the network compression modules use actual neuronwise scalar 1-Lipschitz, zero-preserving activations.

[analytic-build.log](analytic-build.log) records a complete check and axiom reports. The principal theorems use only Lean's standard `propext`, `Classical.choice`, and `Quot.sound`. No custom axiom or `sorry` is used. [verified-source-sha256.json](verified-source-sha256.json) records the publication source and build-file hashes. The ten `.lean` files match the [original checked hashes](../verification/original-lean-source-sha256.json); the publication build script changes only paths and output locations and has been rechecked with the same pinned dependencies. [verified-lake-manifest.json](verified-lake-manifest.json) preserves the original dependency manifest; `lake-manifest.json` has the same dependency pins and the new local project name.
