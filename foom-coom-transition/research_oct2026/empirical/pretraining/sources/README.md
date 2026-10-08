---
license: apache-2.0
language:
- en
library_name: pytorch
pipeline_tag: text-generation
tags:
- scaling-laws
- compute-multipliers
- pretraining
- isoflop
- data-quality
- research-checkpoints
datasets:
- Skylion007/openwebtext
- allenai/c4
- EleutherAI/pythia_pile_idxmaps
- olm/olm-CC-MAIN-2022-40-sampling-ratio-0.15894621295
- tiiuae/falcon-refinedweb
- HuggingFaceFW/fineweb-edu
- openbmb/Ultra-FineWeb
---

# Compute multipliers: the 1e19-FLOP isoFLOP-vertex checkpoints (50 models)

**Which mattered more for language-model progress from 2019 to 2025: the training recipe, or the data?** This release contains the checkpoints behind a controlled answer. We retrained seven best-of-year *recipes* (GPT-2 2019 → OLMo 2 2025) and seven best-of-year *pretraining corpora* (OpenWebText 2019 → Ultra-FineWeb 2025) under one frozen protocol and measured **compute multipliers**: how much less compute a change needs to reach the same downstream quality. The full campaign is 1,397 training runs from 1e17 to 1e19 FLOPs; the models here are the 50 final checkpoints at the top budget, 1e19 FLOPs, each at the compute-optimal model size for its cell, three seeds per cell.

**Headline, at 1e19 FLOPs on a 10-task multiple-choice average (OLMES):**

* Six years of **corpus** work (OpenWebText → Ultra-FineWeb, recipe held at OLMo 2): **×5.39** [4.55, 6.24]
* Six years of **recipe** work (GPT-2 → OLMo 2, corpus held at FineWeb-Edu): **×1.82** [1.66, 2.04]
* Both at once (2019 stack → 2025 stack): ×15.1 [10.9, 20.0] — far below the product of the two, so the gains overlap.
* Year over year: ×1.32/yr for data, ×1.10/yr for recipes, ×1.57/yr jointly.

The ordering (corpus ≫ recipe) holds on every ruler we tried; the *magnitudes* and the ranking *within* the data axis depend on the ruler, which is why each checkpoint ships with three endpoints (see below).

![2019→2025 upgrade on each axis across compute budgets](figures/fig1_scaling_both_axes.png)

Bands are 68% parametric-bootstrap intervals; hollow markers are crossings extrapolated beyond the measured range.

## What is in this repository

```
README.md                      this card
checkpoints.csv                index: one row per checkpoint, all metrics, sha256
checkpoints/<run_id>/model.safetensors   weights (safetensors, float32)
checkpoints/<run_id>/run.json    the run's terminal record: architecture, optimizer, LR,
                                token count, training-loss curve, held-out curve, wall time
recipes/<vintage>.yaml         the seven recipe configs (every knob annotated with its upstream source)
load_example.py                rebuilds any checkpoint in ~15 lines
figures/                        the figures on this page
```

50 checkpoints, 75 GB, 201–530M non-embedding parameters. `run_id` is the content-addressed id used in the study's released run record (`runs.csv` in the [code release](https://github.com/Lunar-Society/compute-multipliers)), so every number in the paper traces to a folder here.

### Three families

| family | what varies | what is fixed | cells |
|---|---|---|---|
| **Model axis** | recipe: GPT-2, GPT-3, GPT-J, GPT-NeoX, LLaMA, Llama 3, OLMo 2 | corpus = FineWeb-Edu | 7 × 3 seeds |
| **Data axis** | corpus: OpenWebText, C4, The Pile, OLM CC 2022, RefinedWeb, FineWeb-Edu, Ultra-FineWeb | recipe = OLMo 2 | 7 × 3–6 seeds |
| **Corner 2×2** | both extremes | — | {GPT-2, OLMo 2} × {OpenWebText, Ultra-FineWeb} |

## The checkpoints

Seed means at the isoFLOP vertex. *Native NLL* is held-out loss on the training corpus's own validation split (nats/token; comparable only within a corpus). *OLMES10* is the 10-task multiple-choice average (ARC-E/C, BoolQ, CSQA, HellaSwag, OBQA, PIQA, SIQA, WinoGrande, MMLU). *Held-out-7* is mean NLL over fixed slices of all seven corpora's validation splits (comparable across corpora). *Alt-8* is an eight-task alternative suite (LAMBADA, COPA, SciQ, and multiple-choice SQuAD, NQ, Jeopardy, CoQA, DROP).

| family | recipe | corpus | rung | N (non-embed) | tokens | seeds | native NLL | OLMES10 | held-out-7 NLL | alt-8 |
|---|---|---|---|---|---|---|---|---|---|---|
| model | GPT-2 (2019) | FineWeb-Edu (2024) | s8 | 201M | 8.28B | 3 | 2.8684 | 0.4477 | 3.2133 | 0.432 |
| model | GPT-3 (2020) | FineWeb-Edu (2024) | s8 | 201M | 8.28B | 3 | 2.8247 | 0.4538 | 3.1821 | 0.439 |
| model | GPT-J (2021) | FineWeb-Edu (2024) | s8 | 201M | 8.28B | 3 | 2.8141 | 0.4609 | 3.1782 | 0.440 |
| model | GPT-NeoX (2022) | FineWeb-Edu (2024) | s8 | 201M | 8.28B | 3 | 2.8446 | 0.4433 | 3.2061 | 0.432 |
| model | LLaMA (2023) | FineWeb-Edu (2024) | s9 | 394M | 4.23B | 3 | 2.8315 | 0.4608 | 3.1977 | 0.428 |
| model | Llama 3 (2024) | FineWeb-Edu (2024) | s9 | 345M | 4.83B | 3 | 2.8043 | 0.4610 | 3.1760 | 0.434 |
| model + data | OLMo 2 (2025) | FineWeb-Edu (2024) | 300M | 320M | 5.21B | 3 | 2.7915 | 0.4642 | 3.1579 | 0.433 |
| data + corner | OLMo 2 (2025) | OpenWebText (2019) | 300M | 320M | 5.21B | 4 | 2.8920 | 0.4208 | 3.5448 | 0.399 |
| data | OLMo 2 (2025) | C4 English (2020) | 300M | 320M | 5.21B | 3 | 3.1394 | 0.4264 | 3.1929 | 0.386 |
| data | OLMo 2 (2025) | The Pile (2021) | 300M | 320M | 5.21B | 3 | 2.0377 | 0.4042 | 3.1114 | 0.387 |
| data | OLMo 2 (2025) | OLM CC 2022 (2022) | 530M | 530M | 3.14B | 3 | 3.1439 | 0.4418 | 3.1203 | 0.402 |
| data | OLMo 2 (2025) | Falcon RefinedWeb (2023) | 300M | 320M | 5.21B | 3 | 3.0329 | 0.4354 | 3.0326 | 0.402 |
| data + corner | OLMo 2 (2025) | Ultra-FineWeb (2025) | 300M | 320M | 5.21B | 6 | 2.7886 | 0.4585 | 3.1730 | 0.428 |
| corner | GPT-2 (2019) | OpenWebText (2019) | s8 | 201M | 8.28B | 3 | 2.9907 | 0.4008 | 3.4999 | 0.385 |
| corner | GPT-2 (2019) | Ultra-FineWeb (2025) | s8 | 201M | 8.28B | 4 | 2.8653 | 0.4449 | 3.2243 | 0.422 |

## Compute multipliers at 1e19 FLOPs (OLMES10, 68% bands)

| year | recipe (ref. GPT-2, on FineWeb-Edu) | year | corpus (ref. OpenWebText, under OLMo 2) |
|---|---|---|---|
| 2019 | GPT-2 (2019): ×1.00 [1.00, 1.00] | 2019 | OpenWebText (2019): ×1.00 [1.00, 1.00] |
| 2020 | GPT-3 (2020): ×1.36 [1.16, 1.60] | 2020 | C4 English (2020): ×1.40 [1.09, 1.77] |
| 2021 | GPT-J (2021): ×1.71 [1.52, 1.96] | 2021 | The Pile (2021): ×0.43 [0.29, 0.58]‡ |
| 2022 | GPT-NeoX (2022): ×0.74 [0.56, 0.95]‡ | 2022 | OLM CC 2022 (2022): ×2.40 [2.04, 2.87] |
| 2023 | LLaMA (2023): ×1.68 [1.51, 1.92] | 2023 | Falcon RefinedWeb (2023): ×1.81 [1.55, 2.11] |
| 2024 | Llama 3 (2024): ×1.69 [1.52, 1.91] | 2024 | FineWeb-Edu (2024): ×4.79 [4.03, 5.52] |
| 2025 | OLMo-2 (2025): ×1.82 [1.66, 2.04] | 2025 | Ultra-FineWeb (2025): ×5.39 [4.55, 6.24] |

‡ crossing outside the measured range, estimated by nearest-segment extension.

![Model recipes on FineWeb-Edu](figures/fig3_models_fineweb_edu.png)

![Corpora under the OLMo 2 recipe](figures/fig4_corpora_olmo2.png)

## Three rulers, one ordering

The corpus axis dominates the recipe axis on every endpoint, but *which corpus is best* depends on what you measure:

* **OLMES10 (downstream multiple choice)**: the educational-filtered 2024–25 corpora (FineWeb-Edu, Ultra-FineWeb) lead by a wide margin.
* **Held-out-7 (mixed-domain perplexity)**: the ranking inverts — broad web corpora (RefinedWeb, OLM CC, even the Pile) lead; the filtered corpora predict general text no better than C4. The 2019→2025 recipe gain also shrinks (OLMo 2 vs GPT-2 ×1.48 instead of ×1.82).
* **Alt-8 (format-diverse tasks)**: the OLMES ranking is preserved at the top — the filtered corpora win knowledge-style tasks (SciQ by 14–17 points, Jeopardy by 8–11) and lose narrative cloze (LAMBADA by 3–5 points); recipe differences are within seed noise.

So what the 2024–25 data pipelines improved is downstream-targeted selection, not general language modelling. The heat map below shows each data-axis checkpoint's held-out loss on each corpus's validation split, relative to the C4-trained model.

![Held-out loss of each data-axis checkpoint on each corpus (relative to C4)](figures/e4_heldout_bin_matrix.png)

Held-out-7 multipliers against C4 at 1e19 (nll_mean; † = extrapolated):

| OpenWebText | The Pile | OLM CC 2022 | Falcon RefinedWeb | FineWeb-Edu | Ultra-FineWeb |
|---|---|---|---|---|---|
| ×0.15† | ×1.75 | ×1.71 | ×2.97 | ×1.28 | ×1.15 |

### Notes on `run.json` fields and seed counts

* `experiment_stage: nonreportable_pilot` / `reportable: false` are **launch-path labels, not a verdict on the run**: the campaign executed every production run through its `--nonreportable-pilot` worker path (the fail-closed authority ceremony that the flag refers to was retired before production). Every checkpoint here is a completed, seed-controlled production run in the released record.
* `n_compute` is the parameter count used for compute accounting (all trainable parameters except the token embedding `wte`, which is tied to the output head; for the GPT-2 family this also excludes the learned position table). `n_realized_trainable_excluding_wte` is the realized count of the built model. `n_source` is the published ladder's own coordinate for the OLMo recipe (differs because the vocabulary was swapped to GPT-2 BPE).
* Seed counts differ by cell on purpose: 3 seeds is the protocol; the OLMo 2 × OpenWebText and × Ultra-FineWeb cells carry 4 and 6 because they also serve the corner 2×2 and a pack-size sensitivity check, and GPT-2 × Ultra-FineWeb carries 4 for the same reason. All seeds are listed in `checkpoints.csv`; the study's tables use seed means.
* `curve` is the training-loss curve at the campaign's log-spaced evaluation points; `extra_eval` is the native held-out NLL at those points. Paths inside `run.json` refer to the campaign's storage volume and are informational only.

## Protocol in brief

* **Controlled inputs.** Every run: GPT-2 BPE tokenizer (50,257), 2,048-token context, 262,144-token global batch, nominal compute C = 6·N·D, no corpus wrapping past one pass. Tokenizer/context/batch progress is deliberately *excluded* from the recipe axis.
* **Recipes.** Architecture, optimizer, initialization and schedule of each year's representative open recipe, reproduced from the upstream paper/code with every knob's source annotated in `recipes/*.yaml`. Peak learning rates are *recalibrated* per recipe on swept anchors at this batch and context (verified at three budgets), not inherited.
* **isoFLOP vertex.** At each budget the model size is chosen where that cell's own native held-out loss is minimized over a ladder of sizes; the checkpoints here are those vertex runs.
* **Endpoints.** OLMES10 on full test sets; native held-out NLL; the held-out-7 mixture; the alt-8 suite. All are in `checkpoints.csv`.
* **Contamination.** 13-gram overlap between OLMES test items and the first 6B tokens of each corpus is ≤1% for most tasks and 1–5% for MMLU; re-scoring on uncontaminated items moves any cell by ≤0.2 points.

## Quickstart

```bash
pip install torch safetensors tiktoken pyyaml huggingface_hub
git clone https://github.com/Lunar-Society/compute-multipliers && export PYTHONPATH=$PWD/compute-multipliers
```

```python
from huggingface_hub import snapshot_download
from load_example import load  # in this repo
import tiktoken, torch

root = snapshot_download('j23h67/compute-multipliers-checkpoints', allow_patterns=['checkpoints/pilot-prod-e-v2025-olmo2-control-fineweb-edu-300m-seed6198-f40480225904/*', 'recipes/*', 'load_example.py'])
model, spec = load(f'{root}/checkpoints/pilot-prod-e-v2025-olmo2-control-fineweb-edu-300m-seed6198-f40480225904', recipes_dir=f'{root}/recipes')
enc = tiktoken.get_encoding('gpt2')
ids = torch.tensor([enc.encode_ordinary('The history of the Roman Empire begins')])
with torch.no_grad():
    for _ in range(30):
        logits, _ = model(ids)
        ids = torch.cat([ids, logits[:, -1].argmax(-1, keepdim=True)], 1)
print(enc.decode(ids[0].tolist()))
```

`model(idx, targets)` returns `(logits, loss)`; `model.nll_sum(idx, targets)` gives the summed next-token NLL used for all held-out numbers. Models are base LMs (no instruction tuning, no chat template); the context length is 2,048 tokens.

## Intended use and limitations

These are **research artifacts** for studying scaling, data quality and recipe effects: fitting scaling laws, probing what different corpora teach, measuring transfer, testing evaluation instruments, or extending the grid. They are small (≤530M non-embedding parameters, ≤1e19 FLOPs), trained on web text at one epoch or less, and not tuned for any downstream use.

* **Scale.** Nothing here speaks to frontier scale; recipe changes whose value is stability or throughput at large scale cannot show up as compute multipliers in this regime.
* **Instrument dependence.** The data-axis ranking depends on the endpoint (see *Three rulers*). Quote multipliers with their reference and ruler.
* **One representative per year.** Recipes and corpora are representative public choices, not demonstrably the best of their year.
* **Safety.** Base models trained on unfiltered-for-safety web corpora will reproduce biases, toxic language and personal information present in that text, and can be prompted to do so. Do not deploy them as assistants. No safety tuning or output filtering was applied.
* **Training data licences.** Corpora were used at pinned Hugging Face revisions under their upstream terms; no corpus text is redistributed here. The Pile and OLM CC 2022 are marked non-redistributable in our specs; the models trained on them are released, as is common practice, but users should consider the provenance of those corpora for their own use.

## Licence

Weights, `run.json` records, recipes and code snippets in this repository: **Apache-2.0**. The study's data tables and figures are CC-BY-4.0 in the code release.

## Citation

Jerry Han (Lunar Society). *Compute multipliers: recipe and corpus effects on language-model pretraining* (2026). Checkpoints: `j23h67/compute-multipliers-checkpoints`; code, run record and analysis notebooks: https://github.com/Lunar-Society/compute-multipliers; write-up: https://www.dwarkesh.com/p/pretraining-progress-is-mostly-data.

```bibtex
@misc{compute_multipliers_checkpoints_2026,
  title  = {Compute multipliers: 1e19-FLOP isoFLOP-vertex checkpoints},
  author = {Jerry Han},
  year   = {2026},
  url    = {https://huggingface.co/j23h67/compute-multipliers-checkpoints}
}
```
