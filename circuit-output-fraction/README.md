# Beating Monte Carlo on rare circuit outputs

Notes by Claude, prompted by Kaarel Hänni. Research note, 27 October 2026; not reviewed by a human. The proofs were checked by AI referees (see [`verification/`](verification/)), not by humans.

**Question.** A Boolean circuit $C:\{0,1\}^n\to\{0,1\}$ and an input distribution $D$ are given, and $p=\Pr_D[C(x)=1]$ is tiny. Monte Carlo needs about $1/p$ samples. (1) Is there a polynomial-time procedure, one that checks some property of the circuit and then samples, that estimates $p$ faster than sampling on a reasonable class of circuits, while never being wrong on any circuit? (2) The same, when an unbounded prover may send one argument to a polynomial-time randomized verifier that must never be convinced of a falsehood (beyond probability $\varepsilon$), on any circuit.

**Paper:** [`paper/main.pdf`](paper/main.pdf) (LaTeX sources in [`paper/`](paper/)).

## Short answer

**Upper bounds need deduction; lower bounds need proposals; sampling pays for whatever surprise is left.**

- An *envelope* is a tractable function $\varphi\ge\mathbf 1_C$ whose mass $Z=\mathbb E_D\varphi$ can be computed exactly and from which one can sample (a DNF, a DNNF, a subcube, a Chernoff bound, …). Importance sampling from $D\varphi/Z$ has weights in $[0,1]$, so it gives *two-sided* intervals after $O(K\varepsilon^{-2}\log(1/\delta))$ samples, where $K=Z/p$ is the envelope's looseness. The envelope explains $\log_2(1/Z)$ bits of the surprise $\log_2(1/p)$ deductively; sampling pays $2^{\log_2 K}$ for the rest.
- **Without a prover**, the procedure *DFSB* (Decompose–Force–Sample–Branch) splits the event by exact rules (independence of variable-disjoint parts, literals forced by propagation and Gaussian elimination, Shannon expansion) and samples only at leaves that are dense or have tight envelopes. It is sound on every circuit, and costs $\mathrm{poly}\cdot K$ on every circuit whose ideal $K$-explanation tree is polynomial: read-once formulas (exactly), read-once compositions of sub-circuits each *component-dense* in the polarity in which it occurs (forcing and independence split it into exact or dense pieces), backdoor-style triggers, circuits with small cutsets (exactly), and versions of these disguised inside cones of logarithmic support. DNFs and DNNFs, whose ideal trees can be exponential, are covered by their own envelopes as envelope leaves ($K\le$ the number of terms for a DNF) and by the #DNNF FPRAS of Meel–de Colnet, which the meta-procedure runs. Beyond DFSB:
  - every circuit whose AND gates are bracketed with logarithmic *context width* compiles to a polynomial-size DNNF, of size $O(|N|(\mathrm{cw}+1)2^{\mathrm{cw}})$ for its NNF $N$, so (with the #DNNF FPRAS) it has an FPRAS; this covers, e.g., ORs of bounded-pathwidth CNFs, each bracketed as an AND-chain along a path decomposition (found in linear time for constant width), whose exact counting is #P-hard;
  - functions of independent *modules* (thresholds, majorities) are estimated through their quotients; the log-ratios of the quotient estimates add (up to lower-order terms) when each module is estimated to small relative error on the polarity its parent uses;
  - for unate circuits the *presumption of independence* is certified: Harris and Janson inequalities pin $p$ within $e^{\Delta/(1-\max_i b_i)}$ of $\prod_i D(A_i)$ ($b_i = D(\neg A_i)$), at a sampling cost linear in $\sum_i b_i \approx \log(1/p)$, a covariance correction makes the error third order, and pairwise data provably cannot do better than $e^{0.29\Delta}$;
  - *certified telescoping*: annealing becomes sound with exact coupling-from-the-past samplers whose truncation is certified empirically;
  - *local thresholds*: counts of overlapping local sub-circuits (bounded arity and degree, expander-like overlaps allowed) by exponential tilting with a heat-bath sampler whose mixing is certified locally (Dobrushin), or by coupling from the past for supermodular counts; e.g. $p\approx10^{-20}$ certified to a factor 1.7 with $7\cdot10^4$ chain samples;
  - *affine structure*: certified affine gates and an exact affine/triangular presolve remove the parity-check part of the surprise exactly; unions of affine subspaces give envelopes. For events that fill a $1/\mathrm{poly}(n)$ fraction of the solution set of $m\le n/6$ random parity checks, decomposition-based methods (envelopes with small leaves, context-width compilation, DFSB's completeness guarantee) cost Monte Carlo's price up to polynomial factors, and any use of a DNNF envelope at least its square root; under biased product distributions, small ANDs of parity checks admit no sound procedure that is complete on them unless NP ⊆ BPP;
  - bounded treewidth (exactly) and thresholds of independent blocks (exponential tilting, $K\le\tfrac43(2\sqrt k+1)$).
- **With a prover**, *proof-carrying importance sampling* checks implications in any propositional proof system (DRUP/LRAT, cutting planes, extended Frege) and samples the rest. It is sound against every argument, and complete on every circuit whose rarity has a short proof of confinement to a tractable region in which it is not rare. Lower bounds need no proof at all. XOR-propagation-tree arguments add parity reasoning (gate propagation and Gaussian elimination, affine pieces under product distributions), and Gibbs envelopes add tilted proposals with overlapping scopes, whose mixing certificate the verifier recomputes. Verifier cost is $\mathrm{poly}(|\pi|)+2^{\sigma_u}$ (up to polynomial factors), where $\sigma_u$ is the surprise left unexplained by the argument; in the black-box model each bit of argument saves at most a factor two in evaluations for lower bounds, and the $2^{\sigma_u}$ term is unavoidable for two-sided intervals once the envelope is fixed.
- **Limits.** No procedure beats sampling on all circuits (unless NP ⊆ BPP; and with exponentially hard PRGs, not by more than $p^{-o(1)}$). A verifier that only evaluates $C$ cannot certify an upper bound below about $1/T$ with $T$ evaluations, whatever the argument. No argument system is complete for upper bounds unless coNP ⊆ MA. On circuits with short refutations in the verifier's proof system (and padded versions with exactly certified $p>0$), a procedure without a prover can be complete iff the corresponding slice of the system's canonical pair is separable in randomized polynomial time; so the prover helps strictly for TC⁰-Frege, Frege and extended Frege if Blum integers cannot be factored by polynomial-size circuits (and two-sidedly, with a verifier that checks proofs in a theory such as ZFC, if factoring is not in BPP). Whether weak automatability removes the prover's advantage on general envelope classes is open. Upper-bound and two-sided separations cannot rest on NP-hardness under randomized many-one reductions to gap problems with gap at least $1+1/\mathrm{poly}$, unless coNP ⊆ AM. With interaction (sum-check) the problem becomes trivial, so the one-message model is the interesting one.

## Contents

- **`paper/`**: the paper (`main.pdf`) and its LaTeX sources.
- **`code/rareprob/`**: the Python implementation.
  - `circuit.py`, `dist.py`: circuits with bit-parallel evaluation; product distributions.
  - `nnf.py`: negation normal form, restriction, small-cone canonicalisation.
  - `envelope.py`, `compile.py`: envelope circuits, the envelope estimator with dense-leaf boxes, and the sound envelope compiler.
  - `dfsb.py`: Decompose–Force–Sample–Branch (atom size fixed at 12 variables). `meta.py`: the meta-procedure (variable elimination, Harris–Janson, tilting, tilted Glauber sampling for local thresholds, the affine presolve and affine envelopes, context width and DFSB, each at its share of δ, intersected).
  - `ctxwidth.py`: context-width compilation of any circuit into a DNNF. `cftp.py`: bounding-chain coupling from the past and certified telescoping for unate CNFs.
  - `tilting.py`: exponential tilting for thresholds of blocks, and proposal-based lower bounds. `janson.py`: the Harris–Janson sandwich. `ve.py`: exact variable elimination (greedy min-degree order).
  - `localthr.py`: local threshold circuits (overlapping scopes): Dobrushin certificates, systematic-scan heat-bath and monotone CFTP samplers, the thermodynamic-integration normaliser interval, and the sound estimator TG.
  - `affine.py`: GF(2) machinery, certified affine gates, the exact affine/triangular presolve, affine-union envelopes with Karp–Luby–Madras sampling, the linear-order dynamic program for affine subspaces under product distributions (masses with proved floating-point error bounds), and the verifier for Part-2 XPT arguments.
  - `cnf.py`, `rup.py`, `argument.py`: Tseitin encodings, unit propagation, Gaussian-elimination forcing, a DRUP checker, and the Part-2 verifier with an honest prover.
  - `stats.py`: KL confidence intervals, the sequential estimator, the DKLR stopping rule.
  - `families.py`: benchmark circuit families.
- **`code/tests/`**: pytest suite (exactness of masses and samplers, interval coverage, checker soundness, end-to-end arguments).
- **`experiments/`**: `exp_speedup.py`, `exp_coverage.py`, `exp_arguments.py`, `exp_ctx.py`, `exp_janson.py`, `exp_cftp.py`, `exp_local.py`, `exp_affine.py`, `check_second_order.py`, `check_independence_numbers.py`, and their outputs in `results/`; `make_figures.py` and `make_tables.py` regenerate the paper's figures and tables.
- **`verification/`**: the AI referee reports on the theorems, and how each finding was resolved.

Reproduce (Python 3 with numpy, scipy, matplotlib, python-sat; TeX Live for the paper):

```sh
cd code && python3 -m pytest -q tests
cd ../experiments && for e in exp_coverage exp_speedup exp_arguments exp_ctx exp_janson exp_cftp exp_local exp_affine check_second_order check_independence_numbers; do python3 $e.py; done
python3 make_figures.py && python3 make_tables.py
cd ../paper && latexmk -pdf main.tex
```

## Status

- **Proved here** (with proofs in the paper): the envelope estimator and its variants, DFSB soundness and completeness, context-width compilation, the certified-independence and certified-telescoping procedures, the tilting bound, the local-threshold estimator, the affine presolve and envelopes, the parity barrier, the barrier theorems, the argument-system soundness and completeness theorems, the black-box surprise-accounting bounds.
- **Proved here from cited theorems**: the separations that rely on known failures of feasible interpolation (Bonet–Pitassi–Raz; Krajíček–Pudlák for extended Frege), the FPRAS results that rely on the #DNNF FPRAS (Meel–de Colnet), and the biased-parity hardness, which relies on the NP-completeness of coset weights (Berlekamp–McEliece–van Tilborg). The cited statements were checked against abstracts and paper sections, as recorded in `verification/`.
- **Numerical**: the experiments.

**Working branch:** `claude/circuit-output-fraction-xixj34` holds the full working state; everything in this folder is published.
