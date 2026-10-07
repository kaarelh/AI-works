# A linear bound for the Paulsen problem

Astra, Claude, Hugo Eberhard, Kaarel Hänni.

Start with [the paper PDF](paper/linear-paulsen.pdf).

- **paper/**: PDF, complete LaTeX sources and build instructions.
- **lean/**: complete Lean 4 project, pinned dependency manifest, build instructions, audit file and verification report.

The paper proves that every real ε-nearly equal-norm Parseval frame of n vectors in ℝᵈ is within squared Frobenius distance Cεd of an equal-norm Parseval frame, where C is universal. It also proves the equivalent projection form, with bound Cnβ. The proof has four parts:

- **Static balancing.** A box-constrained log-determinant minimisation corrects the diagonal. It is controlled by the barrier constant (half-set hitting time) of the squared-Gram graph.
- **Drifted moderate-row seed.** A filtered Gaussian tangent perturbation with a deterministic drift, used when d ≳ log n.
- **Many-row seed.** A row-tangent Gaussian with row renormalisation and a centred remainder estimate, used when n ≳ d².
- **Bounded rank.** The Hamilton–Moitra argument, used when d is bounded.

The Lean development formalises the paper statement by statement, with exactly the paper's constants. The principal results are `Paulsen.Paper.thm_main : Paulsen.SharpPaulsenBound` and `Paulsen.Paper.thm_projection : Paulsen.SharpProjectionBound`, both in [Assembly.lean](lean/Paulsen/Paper/Assembly.lean). The [audit report](lean/final-audit.md) records the build and the checks of statements, axioms and proof dependencies.

## Reproduce the paper

From `paper/`, with a standard TeX Live installation:

```sh
pdflatex -interaction=nonstopmode -halt-on-error linear-paulsen.tex
pdflatex -interaction=nonstopmode -halt-on-error linear-paulsen.tex
```

## Reproduce the formalisation

Install Lean through elan, then run from `lean/`:

```sh
lake exe cache get
lake build
```

The project pins Lean 4.32.0 and mathlib v4.32.0. The first command downloads the dependency caches; they are not included in this folder.
