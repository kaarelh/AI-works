# Beating Monte Carlo on rare circuit outputs

Notes by Claude, prompted by Kaarel Hänni. Research note, 27 October 2026; not reviewed by a human. The proofs were checked by AI referees (see [`verification/`](verification/)), not by humans.

**Question.** A Boolean circuit $C:\{0,1\}^n\to\{0,1\}$ and an input distribution $D$ are given, and $p=\Pr_D[C(x)=1]$ is tiny. Monte Carlo needs about $1/p$ samples. (1) Is there a polynomial-time procedure, one that checks some property of the circuit and then samples, that estimates $p$ faster than sampling on a reasonable class of circuits, while never being wrong on any circuit? (2) The same, when an unbounded prover may send one argument to a polynomial-time randomized verifier that must never be convinced of a falsehood (beyond probability $\varepsilon$), on any circuit.

**Paper:** [`paper/main.pdf`](paper/main.pdf) (LaTeX sources in [`paper/`](paper/)).

## Short answer

**Upper bounds need deduction; lower bounds need proposals; sampling pays for whatever surprise is left.**

- An *envelope* is a tractable function $\varphi\ge\mathbf 1_C$ whose mass $Z=\mathbb E_D\varphi$ can be computed exactly and from which one can sample (a DNF, a DNNF, a subcube, a Chernoff bound, …). Importance sampling from $D\varphi/Z$ has weights in $[0,1]$, so it gives *two-sided* intervals after $O(K\varepsilon^{-2}\log(1/\delta))$ samples, where $K=Z/p$ is the envelope's looseness. The envelope explains $\log_2(1/Z)$ bits of the surprise $\log_2(1/p)$ deductively; sampling pays $2^{\log_2 K}$ for the rest.
- **Without a prover**, the procedure *DFSB* (Decompose–Force–Sample–Branch) splits the event by exact rules (independence of variable-disjoint parts, literals forced by propagation and Gaussian elimination, Shannon expansion) and samples only at leaves that are dense or have tight envelopes. It is sound on every circuit, and costs $\mathrm{poly}\cdot K$ on every circuit whose ideal $K$-explanation tree is polynomial: products and read-once compositions of arbitrary dense sub-circuits, backdoor-style triggers, circuits with small cutsets (exactly), DNFs and DNNFs, and locally disguised versions of all of these. Beyond DFSB:
  - every circuit of logarithmic *context width* compiles to a polynomial-size DNNF, so (with the #DNNF FPRAS of Meel–de Colnet) it has an FPRAS; this covers, e.g., ORs of bounded-pathwidth CNFs, whose exact counting is #P-hard;
  - functions of independent *modules* (thresholds, majorities) are estimated through their quotients;
  - for unate circuits the *presumption of independence* is certified: Harris and Janson inequalities pin $p$ within $e^{\Delta}$ of $\prod_i D(A_i)$, a covariance correction makes the error third order, and pairwise data provably cannot do better than $e^{0.29\Delta}$;
  - *certified telescoping*: annealing becomes sound with exact coupling-from-the-past samplers whose truncation is certified empirically;
  - bounded treewidth (exactly) and thresholds of independent blocks (exponential tilting, $K\le\tfrac43(2\sqrt k+1)$).
- **With a prover**, *proof-carrying importance sampling* checks implications in any propositional proof system (DRUP/LRAT, cutting planes, extended Frege) and samples the rest. It is sound against every argument, and complete on every circuit whose rarity has a short proof of confinement to a tractable region in which it is not rare. Lower bounds need no proof at all. Verifier cost is $\mathrm{poly}(|\pi|)+2^{\sigma_u}$, where $\sigma_u$ is the surprise left unexplained by the argument; each bit of argument buys at most one bit of surprise.
- **Limits.** No procedure beats sampling on all circuits (unless NP ⊆ BPP; and with exponentially hard PRGs, not by more than $p^{-o(1)}$). A verifier that only evaluates $C$ cannot certify an upper bound below about $1/T$ with $T$ evaluations, whatever the argument. No argument system is complete for upper bounds unless coNP ⊆ MA. The prover's advantage for upper bounds is exactly the non-weak-automatability of its proof system (so it is real under standard cryptographic assumptions), and such separations cannot rest on NP-hardness alone. With interaction (sum-check) the problem becomes trivial, so the one-message model is the interesting one.

## Contents

- **`paper/`**: the paper (`main.pdf`) and its LaTeX sources.
- **`code/rareprob/`**: the Python implementation.
  - `circuit.py`, `dist.py`: circuits with bit-parallel evaluation; product distributions.
  - `nnf.py`: negation normal form, restriction, small-cone canonicalisation.
  - `envelope.py`, `compile.py`: envelope circuits, the envelope estimator with dense-leaf boxes, and the sound envelope compiler.
  - `dfsb.py`: Decompose–Force–Sample–Branch. `meta.py`: the meta-procedure that runs every applicable method and intersects.
  - `ctxwidth.py`: context-width compilation of any circuit into a DNNF. `cftp.py`: bounding-chain coupling from the past and certified telescoping for unate CNFs.
  - `tilting.py`: exponential tilting for thresholds of blocks, and proposal-based lower bounds. `janson.py`: the Harris–Janson sandwich. `ve.py`: exact variable elimination.
  - `cnf.py`, `rup.py`, `argument.py`: Tseitin encodings, unit propagation, Gaussian-elimination forcing, a DRUP checker, and the Part-2 verifier with an honest prover.
  - `stats.py`: KL confidence intervals, the sequential estimator, the DKLR stopping rule.
  - `families.py`: benchmark circuit families.
- **`code/tests/`**: pytest suite (exactness of masses and samplers, interval coverage, checker soundness, end-to-end arguments).
- **`experiments/`**: `exp_speedup.py`, `exp_coverage.py`, `exp_arguments.py`, `exp_ctx.py`, `exp_janson.py`, `exp_cftp.py`, `check_second_order.py`, and their outputs in `results/`; `make_figures.py` and `make_tables.py` regenerate the paper's figures and tables.
- **`verification/`**: the AI referee reports on the theorems, and how each finding was resolved.

Reproduce (Python 3 with numpy, scipy, matplotlib, python-sat; TeX Live for the paper):

```sh
cd code && python3 -m pytest -q tests
cd ../experiments && for e in exp_coverage exp_speedup exp_arguments exp_ctx exp_janson exp_cftp check_second_order; do python3 $e.py; done
python3 make_figures.py && python3 make_tables.py
cd ../paper && latexmk -pdf main.tex
```

## Status

- **Proved here** (with proofs in the paper): the envelope estimator and its variants, DFSB soundness and completeness, the tilting bound, the barrier theorems, the argument-system soundness and completeness theorems, the black-box surprise-accounting bounds.
- **Proved here from cited theorems**: the separations that rely on known non-automatability results (Bonet–Pitassi–Raz, Krajíček–Pudlák) and on the #DNNF FPRAS (Meel–de Colnet). The cited statements were checked against abstracts and paper sections, as recorded in `verification/`.
- **Numerical**: the experiments.

**Working branch:** `claude/circuit-output-fraction-xixj34` holds the full working state; everything in this folder is published.
