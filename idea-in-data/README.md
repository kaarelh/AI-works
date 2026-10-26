# Is the idea in the data?

These notes analyse a proposed definition: an idea $Y$ is *in* data $X$ iff $K(Y\mid X)\ll K(Y)$. They cover where the definition sits in the literature, its equivalent characterisations and basic calculus, a theorem showing that partial containment is not containment of a part, and what changes under resource bounds.

Start with [notes.md](notes.md), then [landscape.md](landscape.md). Each opens with a short summary.

- **notes.md**: the analysis, with full proofs of the new statements and references.
  - Main theorem: Theorem 4.1. For a random point $Y$ of $\mathbb F_q^m$ on a random line $X$, $Y$ is $(1-1/m)$-contained in $X$, yet every part of $Y$ either misses as much information given $X$ as $Y$ does, or shares nothing with $X$.
- **landscape.md**: the sequel. It asks what the set of ideas contained in a big $X$ looks like, for an image corpus or an atom-level spacetime block, and whether $X$ can be decomposed into its ideas.
  - The raw set is dominated by accidental, isotropic content.
  - Structure lives in redundancy: natural latents are unique (Corollary 4.3) and exist iff shared information is extractable (Proposition 4.4).
  - Structure-plus-local-noise decomposition: Theorem 6.3.

Working branch: `claude/ecstatic-bell-d0ghzt`. Nothing here stays only on the working branch.
