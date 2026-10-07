# Notation and conventions for the paper (binding for all section writers)

Macros are in `preamble.tex`; do not redefine them. Use `\status{proved|computed|conjecture|known|proof sketch}` after every theorem-like heading, and `\src{track X Thm Y}` to point to the research record (e.g. `\src{single Thm D}`, `\src{cases Thm E}`, `\src{untagged U5}`, `\src{experiments E4}`, `\src{prior induction C3}`).

## Syntax
* Object languages: arithmetic $L_A=\{0,S,+,\cdot,=,<\}$; set theory $L_\in=\{\in,=\}$; connectives ¬ ∧ ∨ → ↔, quantifiers ∀ ∃ (bounded quantifiers as abbreviations).
* **Closure-normal form**: data are formulas whose free variables are *parameters* $p,q,\dots$ (an infinite supply of extra constants), read under universal closure. Leading universal quantifiers are *not* stripped automatically: ∀x(x+0=x) and $p+0=p$ are different data (the latter is an instance of the former's matrix at a parameter).
* **Bound variables**: de Bruijn indices in the theory and the code; in the text write named variables. The *named* and *de Bruijn first-order encodings* are compared in §5 (ZF): there a first-order metavariable can take a bound variable (capture), so freshness guards are needed; in the λ/de Bruijn template encoding metavariable values ("bodies") contain no free bound variables, only parameters and holes, so capture cannot occur.
* **Parameters in the code**: data rename parameters canonically by first occurrence and templates match up to injective renaming of parameters; minimal covering templates must then be computed over all parameter alignments ($\Min^{\mathrm{al}}$, experiments Prop E1-al). The theory sections treat parameters as constants; say this once in §2 and refer to it.

## Templates and classes
* A *template* $T$: like a formula but with *occurrences* $M(t_1,\dots,t_n)$ of metavariables $M$ of type $\iota^n\to o$ (formula metavariables: capital $P,Q,F$) or $\iota^n\to\iota$ (term metavariables: lowercase $f,g$; 0-ary term metavariables $z$). Arguments $t_i$ are **metavariable-free** terms (may contain bound variables in scope and parameters).
* *Pattern occurrence*: arguments are pairwise distinct bound variables in scope (0-ary: every occurrence).
* Classes, with $\FO\subseteq\PAT\subseteq\DT\subseteq\SO$:
  * $\FO$ first-order patterns (all metavariables 0-ary);
  * $\PAT$ higher-order (Miller) pattern templates: every occurrence is a pattern occurrence;
  * $\DT$ **determinate templates**: every metavariable has at least one pattern occurrence (other occurrences may have arbitrary metavariable-free arguments, e.g. $P(0)$, $P(Sx)$);
  * $\DTF$: $\DT$ with all term metavariables 0-ary (the implemented class);
  * $\SO$: all occurrences rigid with metavariable-free arguments, no determinacy requirement.
* *Body* of a metavariable: $\lambda z_1\dots z_n.\beta$; *instance* $T\theta$ by plugging (one-step β); $\inst(T)$; generality $T\gen T'$ ($T'$ is a substitution instance of $T$ by template bodies); $T\equiv T'$.
* Witness events (anchor conditions): \evR root variation per metavariable; \evRs root variation at every occurrence (general $\DT$); \evN every argument place of every metavariable is used by some body; \evD Plotkin's distinctness for first-order patterns; \evU no coincidence (no equation between a slot and another position, via a map of arguments, holds in all data unless the target imposes it); \Rich richness hypothesis needed for the "only if" direction of the general anchor theorem.

## Learning
* Data $D$ (finite set of sentences, positive instances). Hypothesis classes: single templates; tagged calculi $\Htag{k}$; untagged unions $\Hk{k}$ of at most $k$ templates.
* $\Min(D)$: ≥-minimal covering templates. $\Acc(D)=\bigcap\{\inst(T): D\subseteq \inst(T)\}$ (cautious verifier); $\Feat(D)$: sentences having every $D$-feature (single Thm C: $\Acc=\Feat$). $\Acc_k(D,N)$: cautious $k$-union acceptance with negatives $N$.
* *Anchor*: finite $D\subseteq\inst(T^*)$ with $\Acc(D)=\inst(T^*)$ (every covering hypothesis contains the target).
* Soundness is against adaptive provers (the verifier answers queries; a prover chooses queries knowing everything but future data). "Target-sound" = accepts only target instances; "truth-sound" = accepts only truths of the intended structure.
* Refutation oracle: sound, one-sided; $\Ref_d$ = sentences refuted within budget/depth $d$. Kinds: Δ0 evaluation in $\N$ after instantiating leading universal quantifiers with numerals ("R-Δ0"); hereditarily finite counterexamples to Π1 sentences of set theory, sound by Δ0 absoluteness; coherence (derivation of ⊥ from designated true sentences).
* Untagged: $k'$ target templates $\sigma_1..\sigma_{k'}$; *refutation separation* $\RS_d(D)$: every template covering data from two distinct targets has a $d$-refutable instance; residue $\Res_d(D)$.
* Method name: \DTRC{} (Determinate Templates with Refutation Clustering).

## Schemas
* PA: $\Q$'s axioms Q1–Q7; $\Ind(\varphi)=\varphi(0)\wedge\forall x(\varphi\to\varphi[Sx/x])\to\forall x\varphi$; induction template $T_{\Ind}=P(0)\wedge\forall x(P(x)\to P(Sx))\to\forall x P(x)$; $\IndEq(P)$ Tarski-style form.
* ZF(C): single axioms \Ext, \Pair, \Union, \Pow, \Inf, \Found, \AC; schemas \Sep (Separation), \Coll (Collection), \ReplU (Replacement with ∃! as a primitive binder), \ReplS (∃! spelled out, Kunen-style), \ReplJ (Jech's image form), \EInd (∈-induction).
* Q1 target: instance schema $\sigma_\varphi=\varphi(z_1,\dots,z_k)$; $\instc(\varphi)$ closed instances, $\insto(\varphi)$ parameter instances, $\Cap(\varphi)$ capture instances; $M_0$ the closed-term substructure; Tarski–Vaught $M_0\preceq M$.

## Bibliography keys (in bib/core.bib — use these)
hanni2026notes, claude2026whatfollows, gold1967language, angluin1980inductive, plotkin1970note, reynolds1970transformational, huet1975unification, huet1978proving, miller1991logic, pfenning1991unification, baumgartner2017higher, cerna2023antiunification, wright1989identification, motoki1991correct, muggleton1991inductive, tarski1957arithmetical, rylln1952axiomatizability, vaught1967axiomatizability, jech2003set, kunen1980set, kaye1991models, hajek1993metamathematics, matiyasevich1993hilbert, rissanen1978modeling, tenenbaum2001generalization, reiter1987theory, shapiro1983algorithmic, garey1979computers, demoura2021lean4, megill2019metamath, debruijn1972lambda.
Other references go into `bib/<sectionkey>.bib`; check that the key is not already in core.bib. Mark any citation you could not verify as such in a comment and keep claims about it hedged.

## Style
* Plain, precise prose; short sentences; no marketing. Every theorem-like environment gets a status marker and a source tag. Proofs: main text gives full short proofs or a proof idea pointing to the appendix (`\Cref{app:...}`); appendix gives full proofs. Never claim more than the final research notes (`notes-final.md`) establish; keep their caveats and corrections (e.g. refuted conjectures stay labelled as refuted).
* Label scheme: `sec:<key>`, `sec:<key>:<sub>`, `thm:<key>:<name>`, `prop:...`, `lem:...`, `cor:...`, `def:...`, `ex:...`, `rem:...`, `conj:...`, `tab:...`, `fig:...`, `app:<key>`, `app:<key>:<sub>`, with <key> ∈ {intro, setting, single, univ, zf, many, exp, disc, ver}.
