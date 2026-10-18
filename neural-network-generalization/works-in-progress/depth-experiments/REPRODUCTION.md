# Reproducing the depth experiments

Use Python 3.12 with the versions recorded in
[experiment/environment.json](experiment/environment.json). The original runs
used NumPy 2.3.5, SciPy 1.17.0, Matplotlib 3.10.8, and mpmath 1.3.0. Different BLAS
implementations can change a newly trained optimizer trajectory. The five
included original model archives avoid retraining for the selected verifications.

## Two checks requiring only this repository

From this directory:

```sh
python verify_representative.py
```

The program works in a temporary directory. It verifies the hidden-only
model-105 counterexample and the entire nine-bit domain of model 500. It checks
exact budgets and mathematical sufficient inequalities; an unsuccessful attack
is never substituted for a positive certificate. The code relies on Python
integers, NumPy's storage of saved dyadic values, and mpmath's interval arithmetic.
It does not invoke Lean.

## Regenerating the model-301 global proof without data

The included original model 301 has 32 hidden layers of width 128. Run:

```sh
python verify_model301.py
```

This works in a temporary directory and checks the checkpoint against its
original SHA-256 hash. It proposes fresh spectral factors and verifies all
31 matrix inequalities using exact integer/rational arithmetic, then checks
the complete global noise bound at `c=1/32000=.001/32`. It requires no dataset,
network access, or omitted proof snapshots, and does not modify committed
records. The certified raw-output variation is below `.017821` for every real
input, hence the clipped-score variation is below `1/16`.

To retain generated factors in a working copy, run from `certificates/`:

```sh
python verify_global_exact.py --indices 301 --c 1/32000 --replay
```

When no saved factors exist, the verifier first proposes new ones. Floating
SVD output is never itself accepted as the norm certificate: the proposed
factorization and its errors are checked exactly. This calibration is the
exploratory inverse-depth radius; it does not establish the primary
`c=.001` condition for this model.

## Regenerating the model-105 full-data proof

Work in a copy of this directory if you want to preserve every checked-in result
byte for byte. Generation scripts write their outputs alongside their sources.
The original normalization is float32 `pixel / 127.5 - 1`, followed by casting
those represented values to float64 for ordinary audits; the exact verifiers
enclose those same dyadic inputs.

First acquire and validate the original public dataset files:

```sh
python prepare_datasets.py
```

This uses the URLs in the original downloader, checks all eight compressed files
against the published source hashes, and creates ignored parsed-array caches.
It can work offline when the original gzip files are already in `experiment/data/`.
The datasets are not bundled in Git.

Then, from `certificates/`, run the generation commands in this order:

```sh
python verify_global_exact.py --indices 105 --c 1/16000 --replay
python exact_heldout_105.py
python exact_heldout_105_local.py
python compose_heldout_105.py
python exact_training_105.py
python audit_105_dataset_labels.py
```

The first command regenerates exact operator-norm bounds; approximate SVDs only
propose factors, whose errors are checked using integer/rational arithmetic.
Its global stability claim uses the weaker radius `c=.001/16`. The subsequent
full-data programs independently set **`c=.001`** and use the norm bounds to
prove pointwise stability on the official inputs. Do not conflate these radii
or domain quantifiers.

Expected original results are all 60,000 signed training margins above `4.48157`,
stability on all 60,000 training and 10,000 test inputs at `c=.001`, and 9,892
correct/108 incorrect/zero ambiguous test labels. The test proof combines 9,988
global-bound cases with 12 local cases. The original generation records are
identified in the compressed full replay manifest. A different valid spectral
factor proposal may change intermediate bounds without changing the theorem.

After these artifacts exist, `python replay_model105_70000.py` independently
replays the generated full proof into temporary directories. This replay command
requires the generated data/factor files; it is not an immediate check on the
curated Git subset alone.

## Regenerating the deeper Boolean-domain proofs

The Boolean domains require no external data. The included saved weights and
records determine the exact split and parameterization. From `certificates/`:

```sh
python partition_exact_cube.py --index 504 --c 1/1000 --time-limit 2400
python partition_exact_cube.py --index 505 --c 1/1000 --time-limit 2400
python exact_covariance_state_point.py --index 505 --vertex 325 --c 1/1000
python compose_full_cube_505.py
```

Do not use `--reuse-clean-cache` for an independent run. The original model-505
partition has one unresolved vertex, 325. The separate covariance proof covers
that same vertex, and the composition preserves the original unresolved record.
The expected final conclusions cover every one of the 512 vertices; they do
not require every vertex to have the correct target label.

## Training and the complete cohort

The original [training instructions](experiment/ORIGINAL-EXPERIMENT-README.md)
describe the fixed protocols and commands. Every protocol and all final metrics
are included here. Five original checkpoints and five full raw record files
are bundled. The remaining 65 checkpoints and per-example records require either
the complete original replay archive or new training runs. The abridged
`all-model-record-summaries.json` is clearly labeled and is not passed off as those
missing raw records. Full-cohort plotting or artifact audits can therefore
require restoring or regenerating the omitted records.

## Complete original archives and hashes

[reproducibility/archive-index.json](reproducibility/archive-index.json) lists
the prepared archives and their exact availability status. A null URL means no
public download is supplied; no external hosting should be inferred.
The complete original file inventory is
[full-replay-manifest.json.gz](reproducibility/full-replay-manifest.json.gz), which
can be read with Python's `gzip.open` and `json.load`.

When all 21 full-round-3 ZIP volumes are available, extract them into one empty
directory. They are complementary ordinary ZIP archives, not a split ZIP stream.
The separately prepared compact ZIP contains all three papers and their original
source layout, but omits most model/data/factor artifacts. Earlier-round archive
entries preserve the older experiments and supporting material.
