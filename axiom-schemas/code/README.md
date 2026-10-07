# dtrc: Determinate Templates with Refutation Clustering

Code for the "experiments" track of the axiom-schemas project. The final notes are in
`../research/tracks/experiments/notes-final.md` (v2, after the referee's report `referee.md`; the v1 notes are
`notes.md`), and the shared brief is `../research/00-brief.md`.

**v2 changes** (after the referee): alignment-complete Min (`mincover.aligned_min`, DTRC default `align=True`); PA
oracle case split and constant propagation in both oracles; refuter top/bot and one-hot passes; optional DTRC sharing
pass (`share=True`); genuine term-level pattern lgg (`baselines.pattern_lgg`; the v1 baseline is
`pattern_lgg_formula`); numerals-only regime for the PA-mix universal axioms (`pa_mix(..., univ_dist='numerals')`,
now the default); held-out sets disjoint from training; hard ZF targets (`datasets.HARD_ZF`); new experiments E0b and
E10; the referee's independent oracle checks re-run against v2 in `experiments/recheck/`. v1 results are kept in
`results_v1/`.

## Package `dtrc/`

| module | contents |
|---|---|
| `syntax.py` | Terms and formulas as tuples. Bound variables are de Bruijn indices `('v',k)`; parameters `('p',name)` are read under universal closure (closure-normal form). Supports arithmetic {0,S,+,*,=,<} and set theory {in,=}, the connectives, quantifiers and bounded quantifiers. Also a parser and printer, shifting, plugging, and universal closure. |
| `templates.py` | DT° templates: metavariable occurrences `('M',name,args)` whose args are metavariable-free. Also instantiation, the unique determinate matcher (with injective renaming of template parameters), generality by freezing (`geq`), and canonical forms. |
| `mincover.py` | Minimal covering templates `Min(D)`, computed by enumerating *normal configurations* on the common-prefix tree and filtering by subsumption. The default class is DT°_F (term metavariables 0-ary); `term_arity0=False` gives full DT°. |
| `oracle_base.py`, `oracle_pa.py`, `oracle_zf.py` | Sound three-valued world oracles. PA: truth in N, decided by polynomial normal forms for symbolic variables, numeral search and exact bounded quantifiers. ZF: truth in V, decided by HF sets plus generic objects and a finite case analysis per unbounded quantifier (x in TC, x = an in-scope generic, x a fresh generic). Both use Kleene connectives with supervaluation. |
| `refute.py` | `Oracle` and `TemplateRefuter`. The refuter instantiates a template with small bodies, using parallel and diagonal enumeration over per-sort pools plus bodies cross-filled from the data, and caches results per template. |
| `dtrc.py` | `DTRC` runs agglomerative clustering with the merge test "Min(A u B) has an unrefuted member", then the per-cluster cautious verifier. `tagged_learner` is the tagged reference learner. |
| `baselines.py` | Baselines: first-order lgg (named-level and de Bruijn encodings), higher-order pattern lgg, and the cautious k-union learner. Skeleton clustering is `DTRC(use_refutation=False, k_stop=k)`. |
| `schemas.py`, `datasets.py`, `metrics.py` | Targets (Q, induction, universal axioms, ZF axioms and schemas), seeded data generators (PA-mix, ZF-mix, near-miss, mistakes), and metrics (ARI, purity, exactness, probes). |

## Running

```
python3 -m pytest -q tests             # 43 unit tests (about 10 s)
sh run_all.sh                          # all experiments (about 10 min); tables in results/*.md, data *.json, figures *.png
sh experiments/recheck/run_recheck.sh  # the referee's independent oracle checks against v2 (about 6 min)
```

Each experiment is also runnable on its own as `cd experiments; python3 eN_*.py`. Every random choice is
seeded, and the seeds are listed in each results file.
