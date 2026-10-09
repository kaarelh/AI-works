# AI-works

Research projects mostly by Claude and ChatGPT, prompted by Kaarel Hänni. Each project has a top-level folder with its own README.

| project | what it is | start with |
|---|---|---|
| [`paulsen/`](paulsen/linear-paulsen/) | *A linear bound for the Paulsen problem*: every ε-nearly equal-norm Parseval frame of n vectors in ℝᵈ is within squared distance Cεd of an equal-norm Parseval frame. With a complete Lean 4 formalisation. | [paper (PDF)](paulsen/linear-paulsen/paper/linear-paulsen.pdf) |
| [`inferential-learning/`](inferential-learning/) | *What Follows from What*: learning inference rules from imitation, coherence and the world, across formal mathematics, informal mathematics and physics. | [report (PDF)](inferential-learning/paper/main.pdf) |
| [`axiom-schemas/`](axiom-schemas/) | *Learning Axioms and Axiom Schemas from Their Instances*: universal axioms, the ZFC schemas and PA induction, and many schemas at once from unlabelled instances. | [paper (PDF)](axiom-schemas/paper/main.pdf) |
| [`axiom-induction/`](axiom-induction/) | *Bayesian Axiom Induction from Instances*: a Solomonoff-style inducer with template priors, derivation likelihoods and time penalties; what it does with instances of ∀xφ, and when it finds the actual axioms. | [paper (PDF)](axiom-induction/paper/main.pdf) |
| [`christiano-point/`](christiano-point/) | *The Christiano point, domain by domain*: when AI's contribution to a domain overtakes humans', assessed across mathematics, physics, biology, software, ML research, AI development and the economy. | [report](christiano-point/report.md) |
| [`foom-coom-transition/`](foom-coom-transition/) | *The foom-coom transition*: when to stop improving computational efficiency and use the remaining compute for what one values, with empirical fits, a subjective forecast and astronomical resource scales. | [report](foom-coom-transition/report.md) · [PDF](foom-coom-transition/report.pdf) |
| [`computational-cosmology/`](computational-cosmology/) | *Computational cosmology*: what computations can run in our universe, with bounds and conditional constructions for causal access, sequential depth, memory, entropy, specification, and reliability. By GPT-6 Astra (OpenAI). | [report](computational-cosmology/report.md) · [PDF](computational-cosmology/output/pdf/computational-cosmology.pdf) |
| [`purpose-sensitivity/`](purpose-sensitivity/) | *Does an AI's work depend on what it's for?*: four Claude models do identical tasks for an AI-ban campaign, MIRI, a frontier AI lab, a newsroom, and both sides of a deep-sea-mining ban. No measurable penalty for AI-ban work; what shifts with the principal is strategic advice. | [report](purpose-sensitivity/README.md) · [design](purpose-sensitivity/DESIGN.md) |

The papers and reports are drafts unless their own README says otherwise.

This branch, `main`, holds a curated copy of each project. Each project's full working state, including scratch files, is on its working branch, listed in [`CLAUDE.md`](CLAUDE.md).
