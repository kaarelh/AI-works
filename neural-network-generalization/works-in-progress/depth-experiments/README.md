# Depth experiments: source, results, and reproducibility

**Status: supporting empirical research, not an additional main learning result.**

The experiments investigate a prior-support condition on networks obtained by
gradient training. They do not sample from the Bayesian posterior or measure
its sample complexity. The mathematical learning statement is in the
[robust polynomial-depth paper](../../main-results/robust-polynomial-depth/README.md).
See the [technical FAQ](../../TECHNICAL-FAQ.md) for the distinctions between
global stability, a finite-data certificate, and a learning guarantee.

## What is included in Git

- Training, attack, quantization, plotting, and certificate code; every declared
  protocol; environment versions; data URLs and hashes; final tables and figures.
- All 70 configurations, training histories, and final outcomes in
  [the abridged record collection](experiment/all-model-record-summaries.json).
  Every failed fit remains visible. These records explicitly omit per-example
  output arrays; they are not represented as the original full record files.
- Original weights and full records for models **105, 301, 500, 504, and 505**.
  These five parameterizations are provided unchanged, with their original hashes.
- Saved model-105 counterexample inputs and disturbances, their exact-budget and
  interval checks, and the complete small model-500 all-domain certificate,
  including its exact matrix-factor witnesses.
- Independent audit notes and the complete inventory of the original replay
  archive, including file-level hashes. Historical source/audit statements are
  preserved for provenance; they do not expand the current Lean coverage.

## What is not included in Git

The full original replay archive contains **21 ordinary ZIP volumes totaling
911.99 MiB**, covering all 70 model checkpoints, original compressed datasets,
per-example outputs, every saved attack, and large exact factor certificates.
Those ZIPs are **not included in this repository and have not been assigned
public download URLs in this publication preparation**. The same applies to
the separately prepared compact archive and older-round archives listed in
the [asset index](reproducibility/archive-index.json), unless an entry explicitly
records an available URL.

This is an explicit storage boundary, not a claim that the complete original
archive is publicly available. Its lossless
[file manifest](reproducibility/full-replay-manifest.json.gz) preserves the
original paths, sizes, and hashes. The [reproduction guide](REPRODUCTION.md)
explains what can be checked directly from this Git payload and what must be
regenerated or supplied from the complete archive.

## Representative results and their scope

The primary score is `clip(z, -0.5, 0.5)`, with allowed change `1/16` under every
simultaneous hidden-postactivation/output disturbance of normalized radius
`c/sqrt(1 + H * Ev)`, where `Ev = N * ||v||²`. The primary constant is `.001`;
the fixed diagnostic grid also contains `.003`, `.01`, `.03`, and `.0625`.

- **Model 105:** all 60,000 official MNIST training signed margins exceed
  `4.48157`, and all 70,000 official training/test inputs have exact pointwise
  stability certificates at `c=.001`. Nevertheless, an exact saved synthetic
  eight-bit input has clean output above `.539` and hidden-only perturbed output
  below `.387`, violating the global support condition. The synthetic input has
  no asserted digit label. At the smaller, exploratory calibration `c=.001/16`,
  the same unchanged model has an exact global certificate on every real input.
  This smaller-radius result does not reverse the primary-radius failure.
  The original full-data certificates can be regenerated
  from the included weights and public MNIST data; their large tables are omitted
  here. The saved counterexample can be verified immediately without downloading
  a dataset.
- **Model 301:** the unchanged depth-32, width-128 MNIST 3-versus-8 network has
  an exact global certificate at the exploratory calibration `c=.001/32`.
  The certified raw-output change is below `.017821` on every real input.
  Its checkpoint, full record, and certificate generator are included, and
  `python verify_model301.py` regenerates the exact global proof without data
  downloads. This is the smaller-radius result cited in the FAQ, not a claim
  of global stability at the primary constant `c=.001`.
- **Model 500:** a depth-4, width-64 majority network has an exact certificate
  of invariant clipped score on all 512 inputs of its nine-bit domain at `c=.03`.
  Its 400 training margins are verified. This small proof is included in full.
- **Models 504 and 505:** depth-64, width-64 networks trained on majority and
  recursive-majority targets have exact all-512-input certificates at `c=.001`.
  Their original weights and the code to regenerate those proofs are included;
  the large matrix-factor snapshots are reserved for the full replay archive.
- All 70 prescribed parameterizations are retained in the outcome summaries.
  Of these, 22 meet the training-margin criterion: 13 tanh image models,
  six Boolean-domain models, and three ReLU comparisons outside the tanh theorem.
  All five spectrally projected parameterizations are globally certified but
  remain ineligible for the hard training-margin likelihood.

Exact integer/interval verifiers are **not Lean proofs**. Ordinary float64
sufficient certificates, rigorous selected certificates, and failed searches
remain distinct. A failed sufficient test is unresolved, not a counterexample.
The published [original proof-status ledger](ORIGINAL-ROUND3-PROOF-STATUS.txt)
records the historical research-round qualifications.

## Quick independent check

With NumPy and mpmath installed, run:

```sh
python verify_representative.py
```

This copies the necessary source and saved witnesses into a temporary directory,
checks the model-105 confident-input counterexample under both pixel conventions,
and recomputes the model-500 all-domain certificate. It needs no network or
external dataset and does not change the committed proof records.

For the depth-32 global certificate, run `python verify_model301.py`. This
separate check recomputes all 31 exact matrix inequalities in temporary files;
it also requires no dataset or network access.

For training, full-data verification, deeper Boolean proofs, and archive
restoration, follow [REPRODUCTION.md](REPRODUCTION.md).

[All paper results](../../README.md) · [Earlier supporting notes](../depth-supporting-notes/README.md)
