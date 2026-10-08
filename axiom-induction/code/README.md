# bai: Bayesian axiom induction over DT° template theories

Code for the "experiments" track of the axiom-induction project. The track notes are
`../research/tracks/experiments/notes.md`; the shared brief is `../research/00-brief.md`.

The package reuses `../../axiom-schemas/code/dtrc` (syntax, DT° templates, the unique matcher, minimal covering
templates `Min`, skeleton clustering and DTRC). It is imported read-only through `sys.path` (see `bai/__init__.py`)
and is not modified.

## Package `bai/`

| module | contents |
|---|---|
| `grammar.py` | `Grammar`: the instantiation grammar Q, a probabilistic context-free grammar over metavariable bodies (closed terms, terms and formulas with holes); exact log-probabilities and a sampler. `TemplateCode`: the prior's prefix code for DT° templates; `theory_bits`: the code of a theory (a set of components). |
| `theory.py` | `Component` (a DT° template in canonical form, with a guard `closed`/`open` per metavariable), `Theory` (a finite set of components), the prior `2^-(lambda bits) (1+size)^-tau`, and the L0 citation coefficient `a_i(d) = prod_M Q(theta_d(M))`. |
| `lik.py` | `dirichlet_marginal`: the exact Dirichlet-integrated mixture likelihood (variable elimination; dense arrays when at most 3 components overlap); `dirichlet_bounds` for oversize cases. `Chain`: the L1 chain derivation grammar (cite, then up to K steps of forall-elimination with a term from Qe, Gen, or MP with a cited conditional), its sampler and the exact backward recursion for `a_i(d)`. `SelChain`: L1 observed only through closed quantifier-free outputs (`class_prob_qf`). `l1_exact_supported`: theories for which the guided recursion needs no brute-force fallback. |
| `pool.py` | Template helpers (`forall_of`, `specialise`, `term_patterns`, `generalisations`), data-derived candidates (`min_theories`: Min of data subsets; `skeleton_theories`: skeleton clusters), `mem_theory`. |
| `posterior.py` | `evaluate`: the posterior by exact enumeration over a pool (plus Mem(D_n)) at several n; `Deriver`: bounded derivability `T |-_K s`; `support_mass`, `verifier_accepts`: the threshold verifier. |
| `gens.py` | Seeded generators: citations, chain derivations, heavy-tailed terms, selected data. |

## Running

```
python3 -m pytest -q tests        # 18 unit tests (about 20 s)
sh run_all.sh                     # tests and E1-E7 (about 25 min on 4 cores); results/*.md, *.json, *.log
cd experiments && python3 eN_*.py # one experiment
```

| script | experiment |
|---|---|
| `e1_universal.py` | E1: forall x phi from data about phi (3 formulas x 5 generators x 5 seeds; L0, L1, L1sel) |
| `e2_pa.py` | E2: unlabelled PA mixture (Q1..Q7 + induction), posterior over the pool (L0) |
| `e3_misspec.py` | E3: misspecified generators (heavy tails, numerals only, selected small terms, another grammar; PA motive laws) |
| `e4_ville.py` | E4: adaptive prover against the threshold verifier; the Ville bound, well specified and misspecified |
| `e5_gold.py` | E5: spare slots, L_inf versus L_k, Gold's text |
| `e6_equivalent.py` | E6: equivalent axiomatisations under L1 and L1sel |
| `e7_prior.py` | E7: time factor and steeper simplicity penalty |

Every random choice is seeded; the seeds are listed in each results file.

## Restrictions (see the notes for details)

* The posterior is exact only over the finite candidate pool, which is built from the data and by hand.
* Single-parameter convention: the only parameter is `w0`.
* L1 is computed exactly for chains of length K <= 2. Theories whose components need the brute-force predecessor
  enumeration are left out of the L1 pools (`l1_exact_supported`); the experiments report how many.
* When the exact Dirichlet sum is too large (more than 3 overlapping components and more than 20000 states), the
  theory's marginal is bracketed by rigorous bounds and the results report the largest posterior mass it could have.
