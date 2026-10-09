# AI-works

Research projects by Kaarel Hänni and collaborators, much of it done with Claude (Anthropic). Each project is a top-level folder with its own README.

| project | what it is | start with |
|---|---|---|
| [`paulsen/`](paulsen/linear-paulsen/) | *A linear bound for the Paulsen problem*: every ε-nearly equal-norm Parseval frame of n vectors in ℝᵈ is within squared distance Cεd of an equal-norm Parseval frame. With a complete Lean 4 formalisation. | [paper (PDF)](paulsen/linear-paulsen/paper/linear-paulsen.pdf) |
| [`inferential-learning/`](inferential-learning/) | *What Follows from What*: learning inference rules from imitation, coherence and the world, across formal mathematics, informal mathematics and physics. | [report (PDF)](inferential-learning/paper/main.pdf) |
| [`axiom-schemas/`](axiom-schemas/) | *Learning Axioms and Axiom Schemas from Their Instances*: universal axioms, the ZFC schemas and PA induction, and many schemas at once from unlabelled instances. | [paper (PDF)](axiom-schemas/paper/main.pdf) |
| [`axiom-induction/`](axiom-induction/) | *Bayesian Axiom Induction from Instances*: a Solomonoff-style inducer with template priors, derivation likelihoods and time penalties; what it does with instances of ∀xφ, and when it finds the actual axioms. | [paper (PDF)](axiom-induction/paper/main.pdf) |
| [`christiano-point/`](christiano-point/) | *The Christiano point, domain by domain*: when AI's contribution to a domain overtakes humans', assessed across mathematics, physics, biology, software, ML research, AI development and the economy. | [report](christiano-point/report.md) |

The papers and reports are drafts unless their own README says otherwise.

This branch, `main`, holds a curated copy of each project. Each project's full working state, including scratch files, is on its working branch, listed in [`CLAUDE.md`](CLAUDE.md).
