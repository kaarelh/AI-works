# Track "experiments": a Bayesian template-theory inducer and empirical tests — final record

*Track "experiments" of the axiom-induction project. Read `../../00-brief.md` first. This file is the complete,
self-contained final record of the track. It was written after the referee report `referee.md` (the referee's code
is in `referee_code/`) and supersedes `notes.md`, which is kept unchanged as the pre-referee version. Code: the
package `bai` ("Bayesian axiom induction") in `../../../code/bai`, experiments in `../../../code/experiments`,
results in `../../../code/results/*.md` and `*.json` (the pre-referee results are kept in
`../../../code/results/v1/`), unit tests in `../../../code/tests`. Small checks for these notes are in `checks/`; each
writes a `.out` file next to it.*

**Status tags.** **[proved]**: full proof here. **[proof sketch]**: argument given, some steps not written out.
**[computed]**: by a named script; the output file is named. **[known]**: published, with reference; **(unverified)**
means recalled, not checked against the source in this session. **[conjecture]**. **[refuted]**: kept, with the
counterexample.

**References to other work.** `AS:` labels refer to `../../../../axiom-schemas/paper/sections/*.tex`; `IL:` labels to
`../../../../inferential-learning/paper/sections/*.tex`. "Conv §k" is section k of
`../../../../axiom-schemas/research/conversation.md`. "Model", "universal" and "pa" are the parallel tracks, cited by
their final notes: `../model/notes-final.md`, `../universal/notes-final.md`, `../pa/notes-final.md`. I cite their
results where my computations test them; I did not rely on them for any proof marked [proved] here, except where a
statement says "proved in model" and is then marked [known].

**Framing.** The code is a small, exact laboratory for checking claims about a Bayesian axiom inducer. It is not a
prover and is not meant to become one.

**What changed after the referee.** The referee found no fatal issue, five major issues (M1–M5) and fourteen minor
ones (m1–m14), and listed brief questions the track had not addressed. All are addressed in the text (M5 only in
part); the map is in the verification log (§16.1). In short:
* **M1.** The PA pools used data the learner had not yet seen and lacked the obvious sound competitor SeenQ(D_n).
  Pools are now causal and contain trimmed sub-theories; E2 and E7 use 25 seeds. Unsound acceptance at δ = 0.05
  happens in 5 of 25 seeds, not in most (§4).
* **M2.** Three of E6's "logically equivalent" forms of commutativity are strictly weaker (Prop X12). E6 is
  relabelled and extended with genuinely equivalent forms (§8).
* **M3.** The soundness promise now states its hypothesis: data from the Dirichlet-averaged law, or a shrinking
  threshold at a fixed weight vector (Prop X8, proved). A constant threshold at fixed weights fails (computed).
* **M4.** With atomic induction motives the PA posterior goes to a strictly weaker theory (E3(b), Prop X10).
* **M5.** New E8: a derivation likelihood with latent citations does not change the MDL split finding (Prop X13).
  PA under a derivation likelihood is still not computed here.

---

## 0. Summary

**What was built.** `code/bai` computes exact posteriors over finite pools of theories made of DT° templates
(§1). The prior is a prefix code with an optional time factor. There are three likelihoods, all with
Dirichlet-integrated mixture weights: citation (L0), a chain derivation grammar (L1: a cited axiom followed by at
most K ≤ 2 steps of ∀-elimination, Gen, or MP with a cited major premise), and L1 observed through a filter
(L1sel). The verifier accepts s when the posterior mass of theories with T ⊢_K s is at least 1 − δ. Exactness is
proved (Props X1–X4) and checked against brute force, a forward sampler, Monte Carlo and the referee's independent
reimplementation (21 unit tests). Pools now use only data already seen, and the PA pools contain the trimmed
sub-theory Trim(T, D_n) of every pool theory. The main restriction: the posterior is exact over a pool, not over
the whole class.

**Answers, with status** (all "computed" claims are from seeded runs listed in §15).

1. **∀xφ from instances (E1, Prop X6).** The posterior identifies the *generator*, at the predicted rates.
   * On closed instance data, mass never moves from the schema H_sch to H_∀ = {∀xφ}. Under L0, H_∀ cannot emit
     instances. Under L1 it loses exactly log₂(1/(1 − c_stop)) bits per datum (one bit here) [proved; computed].
     Under L1sel the odds stay at the prior odds [proved; computed]. So P(T ⊢ ∀xφ | D) → 0 (L0, L1), or it tends to
     the prior share of the ∀xφ-provers among the theories tied with H_sch (0.484 or 0.269; L1sel). Meanwhile
     P(T ⊢ φ(t*) | D) for held-out instances is ≥ 0.999 from n = 8 (from n = 16 under L0 on open data)
     [computed].
   * When the data come from a theory that proves ∀xφ, L1 finds that theory by n = 16 in every run, and
     P(⊢ ∀xφ) → 1 [computed]. The theories are H_∀, with or without quantified theorems, and H_open with Gen.
   * Under L0, derived theorems can only be explained as axioms. Gen-generated data therefore end at memorisation
     [computed].
2. **PA without labels (E2; revised, M1).** Data from T* = Q + T_Ind at fixed weights, 25 seeds.
   * T* (or an equivalent) takes the mass once Q1, Q2, Q4..Q7 have each been cited (median datum 55); Q3 is
     redundant given induction (Prop X11). Mean mass of T* 0.996 at n = 512 [computed].
   * Before that the posterior prefers the sound but weaker SeenQ(D_n) = {Q axioms seen} + T_Ind [computed].
   * In 5 of 25 seeds an unsound lump of the rarely cited Q axioms gets mass ≥ 0.95 at n = 8 or 16, and a δ = 0.05
     verifier then accepts false sentences such as ∀x∀y(y = x) [computed]; an unsound theory is the MAP in 7 seeds
     at n = 8 and 5 at n = 16, and in none from n = 64. The first version reported 3 of 5 seeds, on a pool
     that used unseen data and lacked SeenQ; that frequency is **refuted** as a property of the method (it is 19 of 25
     with the old pool and 5 of 25 with a pool built from seen data). This does not contradict Prop X8, whose
     fixed-weight form (c) needs a threshold of order 2^(−226)·n^(−3.5).
   * Fragmentation of induction by the motive's root does not win (≈ 700 bits behind, falling further behind by about
     4 bits per doubling of n). A false spare slot keeps posterior 0.004 at n = 512 and decays only like n^(−1/2)
     [computed; Prop X7].
3. **Misspecification (E3; revised, M4 and m12).** All data are theorems of the target, but the term or motive law
   is not the model's. The posterior moves at a rate linear in n to the theory that best fits the usage statistics
   [computed]:
   * a nested theory with the same instance set (heavy-tailed terms: C_2 = {φ(?t), φ(S?z), φ(SS?z)} or
     {φ(?t), φ(SS?z)}, the deepest nestings in the pool);
   * an over-specific, incomplete theory (numerals only: a numeral split N_m whose depth m keeps growing with n);
   * a finite memoriser (a finite selected support);
   * in PA with connective-rich motive laws, fragments of induction that are deductively equivalent to T*
     (Prop X9);
   * in PA with **atomic** motives, Q + {T_=, T_<} with mass 1.000 in every seed from n = 1024, which is **strictly
     weaker** than T* (Prop X10: it does not prove the irrationality of √2).

   So the first version's "robust at the level of theorems, not of axioms" is **refuted** as a general statement. It
   held for the three connective-rich motive laws first tried. No misspecified run moved mass to an unsound theory
   at large n.
4. **Soundness (E4, Prop X8; revised, M3).** If the data come from the Dirichlet-averaged law of T* (for a
   one-component T*, simply i.i.d.), the verifier is time-uniformly sound with probability at least 1 − δ′ for
   δ ≤ 2^(−bits(T*))·δ′, for any pool containing T*, even a data-dependent one [proved]. At a fixed weight vector
   the threshold must shrink like n^(−(m−1)/2) for an m-component T* [proved]; a constant threshold then fails: an
   underivable query is accepted with probability 0.977 and 1.000 against a nominal 0.02 [computed; the referee's
   and model's example]. Under misspecification the prover won in every run in two cases [computed]:
   * a fraction of false "near miss" data;
   * selected data, when the only competitor that fits better is a decoy.

   With a clean better-fitting theory in the pool, selection was harmless.
5. **Gold (E5, Prop X7).**
   * Spare slots die only polynomially: n^(−1/2) if unused [proved; computed], about n^(−1/4) if nested inside the
     data's support [proof sketch; computed to n = 10⁸, fitted exponent −0.251 ± 0.002].
   * With stochastic data both ends of Gold's limit point are identified: L_5 data give L_5, L_∞ data give L_∞
     [computed].
   * On Gold's adversarial text the MAP changes at every one of the 14 stages built [computed].
6. **Equivalent axiomatisations (E6; revised, M2).** Under L1 the generating axiomatisation is identified, both among
   logically equivalent forms of commutativity (A_xy, A_yx and two open-guard forms) and among instance-equivalent
   but strictly weaker forms (S_ab, M_x, M_y; Prop X12) [proved; computed]. Under L1sel the five closed-guard forms
   tie exactly, so the mass on theories that prove commutativity tends to its prior share 0.088 [computed]: with only
   fully instantiated theorems in view the data cannot even tell whether commutativity is an axiom.
7. **Time factor and steeper penalty (E7; revised, M1, m7).** A membership-time factor inside DT° is a penalty of at
   most a few bits, which follows from its definition. It changes nothing from n = 64 on; at n ≤ 32 it favours the
   smaller unsound lumps a little (unsound MAP at n = 8 in 9 instead of 7 of 25 seeds) [computed]. A steeper
   simplicity penalty (λ = 2) makes the early unsound lumping much more frequent (unsound MAP at n = 8 in 22 of 25
   seeds, against 7 at λ = 1) but removes the false spare slot faster [computed].
8. **Derivation likelihood and the MDL split (E8, Prop X13; new, M5).** Under the chain derivation likelihood with
   latent citations, a schema and its root split are exact ties at matched weights [proved; computed to 1.1·10⁻¹³].
   With learned weights the split loses at the Occam rate when Q fits the usage (−1.43 bits per doubling of n under
   L1, −1.51 under L0, between n = 256 and 4096) and wins linearly when it does not; the linear gain is larger under
   L1 than under L0 (0.202 against 0.074 bits per datum) [computed]. So a derivation likelihood does not change the
   MDL finding, in agreement with model Prop 5.6 and pa §2. PA induction under a derivation likelihood is not computed
   here.

**What can be promised.**
* If the data are i.i.d. from a one-component pool theory, the posterior concentrates on the theories with its
  data law (Prop X5(a), known). If they come from a multi-component pool theory with Dirichlet-learned weights, it
  concentrates at least on the theories with its instance set, for almost every weight vector (X5(b), known). Under
  L1 the data law singles out the generating axiomatisation (E6), under L0 its cited axioms, and under a filtered
  likelihood such as L1sel only a class of tied theories, which need not all prove the same things (E6).
* The threshold verifier is then time-uniformly sound with probability at least 1 − δ′ for δ ≤ 2^(−bits(T*))·δ′, for
  any pool containing T*, even a data-dependent one (X8(a)). At a fixed weight vector this needs a threshold shrinking
  like n^(−(m−1)/2) (X8(c)).

**What cannot be promised.**
* The "actual axioms", or even their theorems, under misspecification: atomic motive usage gives a strictly weaker
  theory (E3(b)); numeral-only usage gives an incomplete one (E3(a)).
* Soundness at practical thresholds early on (E2: 5 of 25 seeds), or at a constant threshold at fixed weights.
* Completeness when the usage statistics are selected.
* Anything beyond the pool: the winners and even the frequency of unsound acceptance changed when the pool changed
  (E2, E3(a)).

**On the user's question.** The method robustly finds the *generator* of the data. It finds a deductively
equivalent system when the data are varied enough that the cheapest fitting templates still entail everything (PA
with connective-rich motives). It gives the actual axioms much mass only when the data look like the model's own
derivations. Under narrow usage it settles on a weaker theory that fits the usage (atomic motives, numerals), and on
data whose rarely used axioms have been seen once it can briefly prefer an unsound lump.


---

## 1. The model as implemented

Everything below is implemented in `code/bai`; module names are given in brackets.

### 1.1 Sentences, templates, components

* **Syntax** (dtrc `syntax.py`, reused). Terms over 0, S, +, ·; atoms =, <; connectives ¬, ∧, ∨, →, ↔; ∀, ∃. Bound
  variables are de Bruijn indices. Formulas are in closure-normal form: a free *parameter* is read under universal
  closure (`AS:sec:setting:syntax`). Leading ∀'s are not stripped. This is the convention of all four tracks
  (model §1.1).
* **Single-parameter convention.** The only parameter is w0. A datum such as φ(Sw0) means ∀y φ(Sy). Bodies and
  data with two different parameters are outside the model (probability 0). This keeps the closure-normal renaming
  of parameters the identity, which §2 needs. It is a restriction of the implementation. It matters in E6: a
  template with one bound variable and one open-guard metavariable can still state a two-variable law (Prop X12(a)).
* **Templates** (dtrc `templates.py`, reused). DT° templates: metavariable occurrences M(t̄) with metavariable-free
  arguments, every metavariable with a pattern occurrence. Matching is unique and linear (`AS:thm:setting:matching`).
* **Components** [`theory.Component`]. A DT° template in dtrc canonical form, with a *guard* per metavariable:
  `closed` (the body may not contain w0) or `open` (it may). A ground component is a single sentence.
* **Theories** [`theory.Theory`]. Finite sets of components (model Def 1.1, with guards added). Deduplication is by
  canonical template plus guards.

### 1.2 The instantiation grammar Q [`grammar.Grammar`]

A probabilistic context-free grammar over metavariable bodies. The context of a node is (nh, nb, ap): nh holes
(the metavariable's arguments), nb bound variables of the body's own binders, ap = whether w0 is allowed.

* Term node: 0, S, +, · with weights 0.45, 0.35, 0.10, 0.10; a variable with total weight 0.3, split uniformly over
  the nh + nb variables in scope (absent if none); w0 with weight 0.15 (only if ap). Normalised over what is
  available.
* Formula node: =, <, ¬, ∧, ∨, →, ↔, ∀, ∃ with weights 0.35, 0.20, 0.10, 0.10, 0.05, 0.10, 0.02, 0.05, 0.03. A
  quantifier adds a bound variable.

*Properness* [proved]. The expected number of same-sort children is 0.75 (closed terms), at most 0.75 (other term
contexts) and 0.72 (formulas). The term law depends on the context only through whether a variable or w0 is
available, so terms form a single-type subcritical branching process in each context, with expected size at most
Σ_k 0.75^k = 4. Formula nodes form a subcritical process with expected number Σ_k 0.72^k ≈ 3.6, and each has at
most two term children. So the expected body size is finite and bodies are finite almost surely; all finite trees
have total probability 1. This grammar satisfies the uniform weighted subcriticality condition of model Def 1.5
(take h(formula) = 1 and h(term) small; model §1.4 says so). The referee's exact size distributions agree
(`referee_code/r1_core_compare.out`, (b)).

Holes and bound variables are counted alike, so a body with a hole and the same formula with that hole bound by a
quantifier get matching probabilities. This makes splits of a schema by the root symbol of its body exact
reparametrisations under Q (used in E2, E3, E8; Prop X13; model Prop 2.6(b)).

### 1.3 The prior [`grammar.TemplateCode`, `grammar.theory_bits`, `Theory.log_prior`]

A prefix code for templates, given as −log₂ of a subcritical stochastic grammar over templates:
* formula node ∈ {=, <, ¬, ∧, ∨, →, ↔, ∀, ∃, M} with probabilities 0.20, 0.10, 0.10, 0.10, 0.05, 0.10, 0.05, 0.10,
  0.05, 0.15;
* term node ∈ {0, S, +, ·, var, w0, M} with 0.30, 0.20, 0.10, 0.10, 0.15, 0.05, 0.10 ('var' only with a bound variable
  in scope; renormalised), the variable chosen uniformly (log₂ nb bits);
* an occurrence M: which metavariable of its sort, uniform over the k already introduced and "new" (log₂(k+1) bits);
  a new one codes its arity r with r+1 bits and its guard with 1 bit; its arguments are metavariable-free terms.

A theory {T₁..T_m} costs bits(T) = Elias-gamma(m) + Σ bits(T_i) − log₂ m! (a set of distinct components saves the
order). The prior is π(T) ∝ 2^(−λ·bits(T)) · (1 + |T|)^(−τ), where |T| is the total template size. Defaults λ = 1,
τ = 0. The factor (1+|T|)^(−τ) is a membership-time factor: deciding whether a sentence is an axiom of T is one
linear match per template, so its time is O(|T|·|s|) and log₂(1+|T|) is its size-dependent part. Examples of
theory code lengths (bits): {?t+0=?t} 17.1; {∀x(x+0=x)} 17.2; {?P} 5.7; T* = Q1..Q7 + T_Ind 226.2 (the template
T_Ind alone costs 44.8). The referee's independent implementation of this code gives the same lengths to four
decimals (`referee_code/r1_core_compare.out`, (d)); a unit test now compares the two
(`test_against_independent_reference`).

*Kraft* [proved]. Σ over all theories of 2^(−bits(T)) ≤ 1: template codes are prefix-free (arities fix the tree
shape; guard bits are coded once per metavariable), so Σ_τ 2^(−bits(τ)) ≤ 1 (a sum of probabilities of distinct finite
derivations of a stochastic grammar); a theory of m distinct components is coded by γ(m) and the m codes in some
order, and the m! orders of a set of distinct components all have the same length, so Σ_{sets} 2^(−bits) ≤ Σ_m
2^(−γ(m)) (Σ_τ 2^(−bits(τ)))^m ≤ Σ_m 2^(−γ(m)) ≤ 1. The referee confirmed this (referee §4).

### 1.4 L0: citation [`Component.logcoef0`, `lik.logcoefs0`]

A theory with weights w emits a datum by choosing component i with probability w_i and drawing a body for each
metavariable from Q (respecting guards). So P(d | T, w) = Σ_i w_i a_i(d) with a_i(d) = Π_M Q(θ_d(M)), θ_d the
unique matcher (Prop X1). This is model's L0 and universal's L0-strict.

### 1.5 Dirichlet-integrated weights [`lik.dirichlet_marginal`]

The weights get a symmetric Dirichlet(α) prior, α = ½ throughout (the default of all tracks). The marginal
likelihood M_T(D) = E_w Π_j Σ_i w_i a_i(d_j) (model's P^Dir_T) is computed exactly (Prop X2):
* data covered by one component are counted directly;
* if at most 3 components overlap, a dense dynamic programme over their counts;
* otherwise variable elimination over count vectors, with a cap of 20000 states. Above the cap the code returns
  rigorous lower and upper bounds (Prop X2(c)) and reports the largest posterior mass the theory could have. Where
  this happened is listed per experiment (§§3–10) and in `checks/check_bounded.out`.

### 1.6 L1: the chain derivation grammar [`lik.Chain`]

A derivation is a chain s₀, s₁, …, s_k with k ≤ K:
* s₀ = T_iθ, a citation (component i with probability w_i, bodies from Q);
* at step j < K, if some rule applies to s_j, the chain stops with probability c_stop; otherwise it picks an
  applicable rule r with probability c_r / Σ(c over applicable rules), and applies it:
  * **elim** (s_j = ∀xψ): s_{j+1} = ψ[t/x], with t drawn from a term grammar Qe (closed terms; with w0 allowed iff
    `qe_open`);
  * **gen** (s_j contains w0): s_{j+1} = ∀x s_j[x/w0], abstracting every occurrence;
  * **mp** (an *MP component* A → B, A and B DT° with every metavariable of A in B, has A matching s_j): one such
    component is chosen uniformly; s_{j+1} = Bθ, θ read off s_j on A's metavariables and drawn from Q on the rest.
    The major premise is cited; the minor premise is the current sentence.
* if no rule applies, or j = K, the chain stops; the datum is the last sentence.

Defaults: c_stop = ½, c_elim = c_gen = c_mp = 1. K = 1 in most runs, K = 2 in E1 (allq2) and E6. The chain never
fails, so L1 is a proper distribution (Prop X3). The first citation is the only mixture choice (the major premise
of an MP step is chosen uniformly among the applicable MP components, not by weight), so P(d | T, w) = Σ_i w_i
a_i^{L1}(d) and §1.5 applies unchanged.

*Relation to the other tracks' likelihoods.* This is a chain calculus like universal's C_min and C_open (universal
§1.4), with c = 1 − c_stop. It is the special case of model's tree grammar L1 (model §1.5) in which every MP has a
cited major premise and a derived minor premise, and depth is bounded by K. I chose it because it never fails, so
the likelihood needs no normaliser, and because its exact backward sum is tractable (Prop X4). A tree grammar with
derived major premises is not implemented. Consequence: induction followed by MP and ∀-elimination, the PA
derivation the brief has in mind, is outside L1 here (§11; §13, open problem 2).

### 1.7 L1sel: the chain observed through a filter [`lik.SelChain`, `lik.class_prob_qf`]

A model of "only closed quantifier-free theorems are reported" (universal's L1-sel(S) with S = closed
quantifier-free sentences). Each citation of component i is repeated until its chain outputs a closed
quantifier-free sentence. So a_i^{sel}(d) = a_i^{L1}(d)/c_i, with c_i the probability that a chain from component i
ends in that class. This per-citation rejection is not the same law as filtering the output stream of a
multi-component theory, which would give Σ_i w_i a_i(d) / Σ_i w_i c_i instead of Σ_i w_i a_i(d)/c_i (referee m8).
The two agree for one-component theories, and every generator used with L1sel (E1 sch, E6) has one component; for
multi-component pool members (E6's A_xy+A_yx, A_xy+S_ab, Mem) the per-citation form is a modelling choice.

c_i is computed exactly for components ∀^a φ with φ quantifier-free, term metavariables only, every leading
variable used, and no MP components (a finite Markov chain on (number of leading ∀, w0 present)); `class_prob_qf`
raises an error otherwise and such theories are left out of L1sel pools. Checked against Monte Carlo (unit test
`test_class_prob_monte_carlo`; and, for the open-guard components added to E6, `checks/check_classprob_open.out`:
8 components, largest |z| = 2.17 with 40000 chains each).

### 1.8 Pools and the posterior [`pool.py`, `posterior.evaluate`] (revised after the referee, M1)

The posterior is computed **by exact enumeration over a finite pool**, i.e. it is the full posterior conditioned on
"the theory is in the pool". The pool at sample size n is built by the following rule.

1. **Fixed (hand) theories.** The alternatives the brief names, listed per experiment.
2. **Data-derived theories, causal.** For every build point b ≤ n (E1: b ∈ {1, 2, 4, …, 64}; E3(a): {8, 32, 64};
   PA experiments: {8, 16, 32, 64}): Min of random subsets of D_b (dtrc `aligned_min`), skeleton clusters of D_b
   (dtrc `DTRC` without refutation, stopped at k), and, for PA, DTRC with the dtrc PA refuter on D_b and
   frag-observed@b (Q plus the fragments of the motive roots seen in D_b) [`pool.CausalPool`]. A theory built at b
   stays in the pool for all n ≥ b. So **every pool member uses only data already seen.**
3. **Trimmed theories** (PA experiments E2, E3(b), E7). For every pool theory T with at least two components,
   Trim(T, D_n) := the components i of T with a_i(d) > 0 for some datum d of D_n, i.e. those that could have been
   the first citation of some datum seen (under L0: those that match some datum) [`posterior.trimmed`].
   Trim(T*, D_n) is the referee's SeenQ(D_n) = {Q axioms seen in D_n} + T_Ind.
4. **Mem(D_n)**, the set of distinct data seen so far.

Theories are deduplicated at each n by their component keys; the first occurrence keeps its name. If Mem(D_n)
equals a pool theory, that theory keeps its mass and 'Mem' becomes an alias with no mass of its own.

*What changed.* The first version built the data-derived theories once, from the first 16, 40 or 64 data, and used
them at every n; so at n = 8 the posterior ranged over theories built from data 9–64 (the first version's §1.8
said so). It had no trimmed theories, and it added Mem(D_n) without deduplication, which double-counted a theory
whenever Mem(D_n) coincided with it (this happened in E6 at n = 1 and 2; see §8). The referee showed that the PA
results depended on this (M1); §4 reports both pools.

*Mem(D_n) among memorisers.* Under L0, among memorising theories that cover D_n, Mem(D_n) has the largest posterior:
an extra sentence that no datum cites costs prior bits and the Dirichlet factor of Prop X7(a), and cannot raise the
likelihood. Under L1 this argument fails, because an extra ground sentence such as ∀xφ can derive other data and
raise the likelihood (referee m4). The referee computed Mem + {∀x x+0=x} against Mem on E1 sch data under L1: 11–16
bits worse, with the margin shrinking from 14.4 to 11.2 bits between n = 16 and 256 in seed 0
(`referee_code/r10_mem_not_max.out`). So under L1 the claim is restricted to "Mem(D_n) is the memoriser in the
pool", not "the best memoriser".

### 1.9 Bounded derivability and the verifier [`posterior.Deriver`, `support_mass`]

T ⊢_K s iff s is the output of some chain of length ≤ K from T with Qe allowing w0 and all rule weights positive,
i.e. iff P_T(s) > 0 under that L1. This is a sound under-approximation of first-order derivability from inst(T)
(each rule is sound: citation, ∀-elimination, Gen on the parameter, MP). It is model's Th_d with d measured in chain
steps. The threshold verifier accepts s iff Σ_{T ⊢_K s} π_n(T) ≥ 1 − δ (sum over the pool at n, including trimmed
theories and Mem(D_n)); this is model's V_{δ,d}. K = 1 in E1, E3(a) and E4; K = 0 (citation only) in E2, E3(b) and
E7.

The oracle uses the same predecessor enumeration as L1, with a cap on the number of occurrences of one term in a
datum; above the cap it may drop predecessors and answer "not derivable" wrongly. Every experiment now reports how
often the cap was hit (referee m13). It was hit 0 times in every run (E1, E3(a), E4; §§3, 5, 6).

---

## 2. Propositions about the implementation

**Prop X1 (L0 is exact) [proved].** Let T be a component, Q the grammar of §1.2, and d a sentence with at most the
parameter w0. Citing T with independent bodies θ(M) ~ Q (guards respected) yields d with probability
Π_M Q(θ_d(M)) if T matches d with matcher θ_d respecting the guards, and 0 otherwise.

*Proof.* The bodies contain no parameter other than w0, so Tθ contains at most w0 and is already in closure-normal
form; the event "the datum is d" is the event Tθ = d. By `AS:thm:setting:matching` there is at most one θ with
Tθ = d (template parameters, if any, are w0 and map to w0). So P(Tθ = d) = Σ_{θ:Tθ=d} Π_M Q(θ(M)) is the single
term Π_M Q(θ_d(M)) when θ_d exists and respects the guards (a guard-violating body has probability 0 under the
closed grammar), and 0 otherwise. ∎

**Prop X2 (the Dirichlet sum) [proved; computed].** (a) With coefficients a_ij ≥ 0,
E_{w~Dir(α)} Π_j Σ_i w_i a_ij = Σ_z Π_j a_{z_j j} · Γ(mα)/Γ(mα+n) · Π_i Γ(α+n_i(z))/Γ(α), the sum over assignments
z of data to components with a_{z_j j} > 0 and n_i(z) the counts. (b) `dirichlet_marginal` computes this sum.
(c) `dirichlet_bounds` returns L ≤ log M ≤ U.

*Proof.* (a) Expand the product and use E Π w_i^{n_i} = Γ(mα)/Γ(mα+n)·Π Γ(α+n_i)/Γ(α) [known: Dirichlet moments].
(b) The summand depends on z only through Π a and the count vector. Data with one covering component contribute a
fixed factor and a fixed count. For the others, summing over their assignments is summing a product of linear
forms Π_j(Σ_{i∈S_j} a_ij x_i) against the functional x^c ↦ Π Γ(α+c_i); the dense programme (≤ 3 overlapping
components) and the dictionary programme both compute the coefficients of this polynomial exactly. In the dictionary
programme a component's factor Γ(α + c_i) is applied as soon as no later group contains it, which is valid because
the functional is a product over components. (c) Lower: one term of the sum in (a). Upper: E_w L(w) ≤ max_w L(w),
and f = log L is concave on the simplex, so for any w, f(w*) ≤ f(w) + ∇f(w)·(w* − w) ≤ f(w) + max_i ∇_i f(w) − n,
since w·∇f(w) = n. ∎

*Computed.* Against brute-force enumeration of assignments on 300 + 200 random instances (m ≤ 6, n ≤ 9): maximum
difference 1.4·10⁻¹⁴ (unit test `test_dirichlet_dp_exact`). Against the referee's independent count-vector sum on
400 cases with up to 5 overlapping components: 1.4·10⁻¹⁴ (`referee_code/r1_core_compare.out`, (f)); 100 further
cases in `test_against_independent_reference`. The bounds of (c) bracket the exact value on 100 random instances
(`test_dirichlet_bounds_bracket_exact`).

**Prop X3 (L1 is proper) [proved].** For every theory, weights and K, Σ_d P^{L1}(d | T, w) = 1.

*Proof.* The chain makes at most K rule applications. Each step chooses among finitely many outcomes (stop, or an
applicable rule) with probabilities summing to 1, and each rule's random input (a term from Qe, a body from Q, a
uniform choice of MP component) is drawn from a proper distribution (§1.2). A rule is only applied when it applies,
so no run fails. The probabilities of all runs sum to 1, and the datum is a function of the run. ∎

**Prop X4 (the backward recursion is exact) [proved; computed].** Write G_k(s) for the vector (over components i)
of P(s_k = s, first citation i)/w_i. Then G_0(s)_i = a_i^{L0}(s), and for k ≥ 1
  G_k(d) = Σ_{(pred, r, ξ)} G_{k−1}(pred) · (1 − c_stop) · c_r/Σ_{r' applicable to pred} c_{r'} · P(ξ),
summing over predecessors pred, rules r applicable to pred, and random inputs ξ with r(pred, ξ) = d; finally
a_i^{L1}(d) = Σ_k G_k(d)_i · stop_k(d), with stop_k(d) = 1 if k = K or no rule applies to d, and c_stop otherwise.
`Chain.logcoefs` computes this sum exactly for every theory accepted by `l1_exact_supported`, because its
predecessor sets are complete:

(a) *Elim, template-guided.* Let U = ∀xB be a template whose derived template D = B[?u/x] (x replaced by a fresh
0-ary term metavariable) is DT°. Then the pairs (θ, t) with ∀-elim(Uθ, t) = d and x occurring in B correspond
one-to-one to matchers θ' = θ ∪ {u ↦ t} of D against d; so there is at most one.
*Proof.* D is DT° only if x is not an argument of a metavariable occurrence (an argument ?u would not be
metavariable-free). So x occurs in B only at rigid positions, bodies never contain x (λ-convention), and
substituting t for x commutes with plugging the bodies: (Bθ)[t/x] = Dθ'. Uniqueness is `AS:thm:setting:matching`. ∎

The vacuous predecessor ∀x d contributes G_{k−1}(∀x d) with weight Σ_t Qe(t) = 1.

(b) *Elim from bare formula metavariables* ?P and ∀x ?P(x), at step 0. For a parameter-free d, the predecessors are
∀xψ_S with ψ_S = d with a nonempty set S of occurrences of one closed term t replaced by x. Under Q every node of
ψ_S lies in a context with a variable, so Q_F(∀xψ_S) = Q_F(∀x d) · Π_{o∈S} r_o with r_o = (p_var/nv_o)/Q_hv(t),
where nv_o = 1 + (binder depth at o) and Q_hv(t) is t's probability in a context with variables. Summing over S:
Σ_{S≠∅} Q_F(∀xψ_S) = Q_F(∀x d)·(Π_o(1 + r_o) − 1). For ∀x ?P(x) the body probability is the same up to the factor
q(∀). These predecessors have no parameter and no MP component exists in such theories, so elim is the only
applicable rule. If d contains w0 and the guard is closed, the predecessor must have no parameter, so t contains
w0 and S is all occurrences: one predecessor per t.
*Proof.* Direct from the product form of the PCFG; nodes inside a replaced occurrence are removed and replaced by
one variable node; contexts of the remaining nodes do not change between S and ∅ (all lie under the new ∀). ∎

(c) *Gen then elim* (K = 2). A level-1 ∀-sentence from gen is gen(s₀) for a level-0 sentence s₀ = Tθ₀ containing
w0, and ∀-elim(gen(s₀), t) = s₀[t/w0]. Write D for T with its rigid w0 replaced by a fresh ?u. Then s₀[t/w0] = Dθ
with θ(M) = θ₀(M)[t/w0], so θ is the unique matcher of D against d; closed-guard bodies equal θ₀(M); open-guard
bodies θ₀(M) arise from θ(M) by replacing a subset of the occurrences of t by w0; and if T has no rigid w0, t occurs
in some open body. The code enumerates exactly these candidates and keeps those with ∀-elim(gen(s₀), t) = d. ∎

(d) *Gen and MP predecessors* are unique: gen⁻¹(∀xχ) = χ[w0/x] if χ uses x and d has no parameter; for MP,
B is DT° and contains A's metavariables, so θ is the unique matcher of B against d and pred = Aθ.

(e) *Pruning.* A predecessor is skipped only if its (∀-spine, parameter flag) is not in the abstract set of
step k−1, computed forward from the components (elim drops a leading ∀ and may add w0 if Qe allows it; gen adds a
∀ and removes w0; MP gives B's spine). By induction on k every step-k sentence lies in the step-k set, so pruning
never drops a predecessor with G > 0.

*Computed.* (i) The guided recursion equals the brute-force recursion (all subsets of all occurrences, no
templates, no closed forms) to 10⁻⁹ on every datum of random samples from 10 theories, at K = 1 and K = 2
(`test_l1_guided_equals_bruteforce_K1`, `_K2`, `test_star_closed_form_large_numeral`). These share the class
`Chain` and differ only in the predecessor enumeration, so they are not independent (referee m1). (ii) An
independent check: the referee's own brute-force backward recursion, written from this description, agrees on 904
(theory, datum, component) triples to 2.1·10⁻¹⁴ (`referee_code/r1_core_compare.out`, (g)); a reduced version of that
comparison is now a unit test (`test_against_independent_reference`). (iii) The forward sampler agrees with the
exact probabilities (chi-square over cells with expected count ≥ 20 plus one pooled cell, 30000 samples each,
5 theories: `test_l1_sampler_matches_exact`).

**Prop X5 (what a well-specified posterior can identify) [known; proofs in track model]. Revised after the
referee (M3, m2).**
(a) *Fixed weights.* Suppose every theory of a countable class carries a fixed law (fixed mixture weights), the
prior gives T* positive mass, and the data are i.i.d. from P_{T*}. Then, almost surely, the posterior mass of the
generator class C* = {T : P_T = P_{T*}} tends to 1, and inside C* the posterior equals the renormalised prior at
every n (model Thm 2.1 and Cor 2.2, proved there for countable classes; known as a case of Doob 1949).
(b) *Dirichlet weights.* With the parameter (T, w), prior π(T)·Dir_T(dw), likelihood L0 with full-support Q and data
i.i.d. from P_{T*,w*}: for Lebesgue-almost every w* the posterior mass of {T : ∪inst(T) = ∪inst(T*)} tends to 1
almost surely (model Thm 5.1(b), proved there). The stronger statement "concentrates on the theories with the same
law" is false in general (model Thm 5.1(b″)): with linearly independent components the exact class has posterior
mass 0 at every n.
(c) *What is not covered.* The posterior computed here integrates the weights against Dir(½), so (a) applies to
it only for one-component theories, which have no weights. For multi-component generators (b) is the relevant
statement, and it holds for Lebesgue-almost every w*, not for a given one: Doob-type theorems hold for
prior-almost every parameter (Doob 1949; see Miller, arXiv:1801.03122 (unverified), for the a.e. qualification),
and model Thm 5.1(c) ("every interior w*") is a conjecture. E2, E3(b), E5(b) and E8 draw data from
multi-component theories at one fixed weight vector; E1, E4 and E6 use one-component generators, and E3(a)'s
generators are not pool theories at all.
I use X5 only as the yardstick for the experiments. The first version stated it without the a.e. qualification
and without the identifiability hypothesis (referee m2); that version is withdrawn.

**Prop X6 (L1 against L1sel for the universal) [proved; computed].** Let φ be quantifier-free with one variable
used, H_∀ = {∀xφ}, H_sch = {φ(?z)} (closed guard), Qe = Q with closed terms, K ≥ 1. For every closed instance
d = φ(t):
(a) under L1, P_∀(d) = (1 − c_stop)·Q(t) and P_sch(d) = Q(t), so after n closed instances
log₂[π_n(H_sch)/π_n(H_∀)] = log₂[π(H_sch)/π(H_∀)] + n·log₂(1/(1 − c_stop));
(b) under L1sel, P^{sel}_∀(d) = P^{sel}_sch(d) = Q(t), so the posterior odds equal the prior odds for every n.
*Proof.* H_∀ cites ∀xφ; only elim applies (no w0, no MP component); the chain stops with probability c_stop
(datum ∀xφ, not an instance) or eliminates with t ~ Q, giving φ(t), to which no rule applies. t ↦ φ(t) is
injective because x occurs in φ. H_sch cites φ(t) and no rule applies. (b): c_∀ = 1 − c_stop and c_sch = 1. Each
theory has one component, so the Dirichlet integral is trivial. ∎ This is universal Thm U2 for this grammar (their
c is my 1 − c_stop). The same argument gives exact ties under L1sel among all theories of E6 whose fully
instantiated outputs have the same law (§8), whether or not they are logically equivalent.

**Prop X7 (spare slots) [(a) proved; (b) proof sketch; both computed].** (a) If τ covers no datum, then for every D
and every theory T with m components covering D, M_{T∪{τ}}(D)/M_T(D) = Γ((m+1)α)Γ(mα+n)/(Γ(mα)Γ((m+1)α+n)) ~
(Γ((m+1)α)/Γ(mα))·n^{−α}.
(b) [proof sketch] If τ = φ(S?z) is nested in T = {φ(?z)} and data come from T, the log Bayes factor behaves as
−(α/2)·ln n + O_P(1).
*Proof of (a).* The assignments of data are the same with and without τ, and each assignment has count 0 on τ.
The Dirichlet moment of Prop X2(a) then changes by the stated ratio, which does not depend on the assignment;
Stirling gives the rate. ∎ This is model Prop 5.5(a) and pa Prop 5.1.
*Sketch of (b).* Under {φ(?z), φ(S?z)} a datum has probability Q(t)(1 − w₂ + w₂/q_S) if t is S-rooted and
Q(t)(1 − w₂) otherwise (q_S = Q's root probability of S, since Q(St') = q_S·Q(t')). So the likelihood ratio is
(1 + w₂(1/q_S − 1))^{n_S}(1 − w₂)^{n−n_S}, a regular one-parameter family whose true value w₂ = 0 is on the boundary;
its log is n·(O_P(n^{−1/2})·w₂ − c·w₂²) near 0, so the integrand is of order 1 on w₂ ≲ n^{−1/2}. The Beta(α, α)
density near 0 is ∝ w₂^{α−1}, so the integral is ≍ ∫₀^{n^{−1/2}} w₂^{α−1} dw₂ ≍ n^{−α/2}. For a disjoint spare the
factor (1−w₂)^n confines w₂ to ≲ 1/n, giving n^{−α} as in (a). The step not written out is the uniform control of
the O_P term. This is model Prop 5.5(c) (also a sketch there; the referee of that track points to Rousseau and
Mengersen 2011 for the boundary Laplace approximation). Computed in E5.

**Prop X8 (soundness of the threshold verifier) [(a), (b), (c) proved; (a) adapted from IL:thm:caution:ville(b)].**
Let F be a countable family of theories with prior weights 2^(−bits(T)) (total C ≤ 1, by the Kraft argument of §1.3).
For T ∈ F let M_T be its Dirichlet-integrated marginal law on data sequences (L0, L1 or L1sel; each is a probability
on sequences, consistent in n). Fix T* ∈ F. Let R_n ⊆ F be any pool, possibly chosen by looking at the data, with
T* ∈ R_n, and let the verifier use the posterior restricted to R_n.

(a) *Data from the Dirichlet-averaged law.* Suppose the data are distributed as M_{T*}: first w ~ Dir(α), then
i.i.d. from P_{T*,w} (for a one-component T*, simply i.i.d. from P_{T*}). If δ ≤ 2^(−bits(T*))·δ′, then with
probability at least 1 − δ′ the verifier never accepts any s with T* ⊬_K s, at any n, whatever the prover asks
and when. The event depends only on the data.
(b) If F is a fixed pool H plus the memorisation family {Mem(S)}, the factor 2^(−bits(T*)) can be replaced by
w* = 2^(−bits(T*)) / (Σ_{T∈H} 2^(−bits(T)) + 1).
(c) *Data at a fixed weight vector.* Suppose T* has m components and the data are i.i.d. from P_{T*,w} for a fixed
w in the closed simplex. Let R(n, m) := min over count vectors c ∈ ℕ^m with Σc_i = n of
DirMom_α(c)/Π_i (c_i/n)^{c_i} (0⁰ := 1), where DirMom_α(c) = Γ(mα)/Γ(mα+n)·Π_i Γ(α+c_i)/Γ(α). If the threshold
at sample size n satisfies δ_n ≤ 2^(−bits(T*))·R(n, m)·δ′ for every n, then with probability at least 1 − δ′ the
verifier never accepts any s with T* ⊬_K s. For α = ½, R(n, m) ≍ n^(−(m−1)/2) [known: Krichevsky and Trofimov 1981;
computed exhaustively for m = 2, 3, 4 in `checks/kt_regret.out`]; for α ≤ 1, R(n, m) ≥ Γ(mα)/(e(m−1)!Γ(α)^m)·
(n+1)^(−(m−1)) (model Lemma 4.6(b), proved there; checked for m = 2, n ≤ 2000, in `checks/check_fixed_weight.out`).

*Proof.* (a) Let C = Σ_{T∈F} 2^(−bits(T)) ≤ 1 and Z_n = Σ_{T∈F} (2^(−bits(T))/C)·M_T(D_n)/M_{T*}(D_n). Each M_T
is a probability on sequences with Σ_d M_T(D_n d) = M_T(D_n), so under M_{T*},
E[M_T(D_{n+1})/M_{T*}(D_{n+1}) | D_n] = Σ_{d: M_{T*}(D_n d)>0} M_T(D_n d)/M_{T*}(D_n) ≤ M_T(D_n)/M_{T*}(D_n). By
Tonelli, Z is a nonnegative supermartingale with Z_0 = 1, and Ville's inequality (`IL:lem:app:caution:ville`) gives
P[sup_n Z_n ≥ 1/δ′] ≤ δ′. The restricted posterior satisfies, pathwise,
π_R(T* | D_n) = 2^(−bits(T*))M_{T*}(D_n) / Σ_{T∈R_n} 2^(−bits(T))M_T(D_n) ≥ (2^(−bits(T*))/C)/Z_n ≥ 2^(−bits(T*))/Z_n,
because R_n ⊆ F and all terms are nonnegative. Off the Ville event this is > 2^(−bits(T*))δ′ ≥ δ. Accepting s needs
posterior mass ≥ 1 − δ on {T ∈ R_n : T ⊢_K s}, which excludes T*, so it needs π_R(T* | D_n) ≤ δ.
(b) Same, with C ≤ Σ_{T∈H} 2^(−bits(T)) + 1: the memorisation theories are theories of ground components, whose
codes form a prefix-free set, so their total weight is at most 1.
(c) *Termwise bound.* Expand both laws over assignments z of the data to components (Prop X2(a)):
P_{T*,w}(D_n) = Σ_z Π_i w_i^{c_i(z)} Π_j a_{z_j}(d_j) and M_{T*}(D_n) = Σ_z DirMom_α(c(z)) Π_j a_{z_j}(d_j). For each
z, Π_i w_i^{c_i} ≤ max_v Π_i v_i^{c_i} = Π_i (c_i/n)^{c_i}, so DirMom_α(c) ≥ R(n, m)·Π_i (c_i/n)^{c_i} ≥ R(n, m)· Π_i
w_i^{c_i}. Summing over z: M_{T*}(D_n) ≥ R(n, m)·P_{T*,w}(D_n). *Ville.* Z′_n := Σ_{T∈F}(2^(−bits(T))/C)·
M_T(D_n)/P_{T*,w}(D_n) is a nonnegative supermartingale under P_{T*,w} with Z′_0 = 1, by the argument of (a) with
P_{T*,w} as the reference law; so P[sup_n Z′_n ≥ 1/δ′] ≤ δ′. *Pathwise.* π_R(T* | D_n) ≥ 2^(−bits(T*))M_{T*}(D_n)/
(C·Z′_n·P_{T*,w}(D_n)) ≥ 2^(−bits(T*))R(n, m)/Z′_n, which off the Ville event is > 2^(−bits(T*))R(n, m)δ′ ≥ δ_n.
Conclude as in (a). ∎

(a) and (c) are model Thms 4.7 and 4.8 (with the class C^Dir_d there in place of T* here); the termwise bound is
model Lemma 4.6(a). The first version marked (c) a proof sketch; the argument was complete (referee M3), so it is
now marked proved.

*What the proposition does not cover.*
* *A constant threshold at a fixed weight vector.* This can fail. In the referee's example (model Example 4.9),
  recomputed here with this track's likelihood code and every n ≤ 2·10⁶ checked, a δ = 0.01 verifier accepts an
  underivable query with probability 0.977 (ε = 10⁻⁵) and 1.000 (ε = 10⁻⁶), 300 runs each, against the nominal
  0.02 (median first acceptance at n ≈ 8000); with weights drawn from the prior it accepts with probability 0.003
  and 0.007; with the threshold of (c), never (`checks/check_fixed_weight.out`). The first version's summary promised
  soundness "if the data are i.i.d. from a theory in the pool" for a constant threshold. That promise is **refuted**
  for multi-component T* at fixed weights.
* Data that are not distributed as any M_T in F (misspecification), and data whose selection depends on the
  prover. E4 shows what happens then.

**Prop X9 (fragments of induction are deductively equivalent) [proved].** Let T_f, for a root symbol f, be T_Ind
with the motive restricted to root f: for = and <, λx.a(x) f b(x) with 1-ary term metavariables a, b; for ¬,
λx.¬P₁(x); for ∧, ∨, →, ↔, λx.P₁(x) f P₂(x); for ∀, ∃, λx.f y P₁(x, y). Let Q⁻ be any set of sentences.
(a) inst({T_f : all 9 roots}) = inst(T_Ind). (b) For each connective f ∈ {¬, ∧, ∨, →, ↔, ∀, ∃}, Q⁻ ∪ {T_f} and
Q⁻ ∪ {T_Ind} have the same first-order consequences. (c) For f ∈ {=, <} this argument does not apply; Prop X10
shows that the atomic fragments are strictly weaker.

*Proof.* (a) Every motive body has one of the 9 roots, and an instance of T_Ind whose body has root f is the
instance of T_f whose sub-bodies are read off the body (for ∀, ∃ the bound variable becomes the second argument
of P₁). Conversely every instance of T_f is an instance of T_Ind. (b) inst(T_f) ⊆ inst(T_Ind) gives one direction.
For the other, let φ be any motive and choose: for ∧ and ∨, P₁ = P₂ = φ; for ¬, P₁ = ¬φ; for → and ↔, P₁ = (0=0),
P₂ = φ; for ∀ and ∃, P₁(x, y) = φ(x). In each case the chosen body ψ satisfies ⊢ ∀x(ψ(x) ↔ φ(x)) in first-order
logic with equality (for ∃ because domains are nonempty; for ¬ by double negation). Ind(ψ) is
(ψ(0) ∧ ∀x(ψ(x) → ψ(Sx))) → ∀xψ(x); replacing ψ by the equivalent φ in all three places gives Ind(φ). ∎
This is the "any non-atomic connective" observation of conv §7, pa Prop 2.2 (checked derivations there) and a case
of pa Prop 4.8(a).

**The Q axioms.** In all PA experiments the Q axioms are numbered as in dtrc `schemas.py`: Q1 ∀x ¬Sx=0;
Q2 ∀x∀y (Sx=Sy → x=y); Q3 ∀x (¬x=0 → ∃y x=Sy); Q4 ∀x x+0=x; Q5 ∀x∀y x+Sy=S(x+y); Q6 ∀x x·0=0;
Q7 ∀x∀y x·Sy=x·y+x. T* = Q1..Q7 + T_Ind, with T_Ind = (?P(0) ∧ ∀x(?P(x) → ?P(Sx))) → ∀x ?P(x) (one-hole motives,
no parameters). Other tracks number Robinson's axioms differently.

**Prop X10 (the atomic fragments are strictly weaker than T*) [proved, given two known facts]. New (referee M4).**
Let T_A := Q1..Q7 + {T_=, T_<}, and σ := ¬∃x∃y(¬y=0 ∧ x·x = (SS0·y)·y) (the irrationality of √2).
(a) T* proves every instance of the induction schema with parameters; so T* contains PA (as a set of theorems).
(b) T* ⊢ σ and T_A ⊬ σ.

*Proof.* (a) Let φ(x, w̄) be a formula with parameters w̄. Take the parameter-free motive
ψ(x) := ∀w̄[(φ(0, w̄) ∧ ∀y(φ(y, w̄) → φ(Sy, w̄))) → φ(x, w̄)]. Then ψ(0) is a tautology. For the step, assume ψ(x),
fix w̄, and assume the base and the step for w̄; ψ(x) gives φ(x, w̄), and the step gives φ(Sx, w̄); so ψ(Sx). T_Ind
cites Ind(ψ), so T* ⊢ ∀xψ(x), which is induction for φ, uniformly in w̄. The language has < with no Q axiom about it;
PA here means Q plus induction in the full language. (b) T* ⊢ σ: PA proves σ [known; standard], and T* ⊇ PA by (a).
T_A ⊬ σ: by Shepherdson [known: J. C. Shepherdson, "A non-standard model for a free variable fragment of number
theory", Bull. Acad. Polon. Sci. 12 (1964) 79–86; verified by me and by the referee and the pa track only through
secondary sources], there is a model M of Q plus open induction (with parameters) in which x·x = 2·y·y has a solution
with y ≠ 0. M is the non-negative part of a discretely ordered ring (by the secondary sources, built from an integer
part of a real closed field of Puiseux series), with Sx := x + 1; such a structure satisfies Q1–Q7 (Q3 because the
order is discrete). Every instance of T_= is an instance of open induction (the motive a(x) = b(x) is an equation,
without parameters), so it holds in M. Interpret < in M as the empty relation: every instance of T_< has the false
conjunct a(0) < b(0) in its antecedent, so it holds; and σ does not mention <. So M ⊨ T_A and M ⊭ σ. By soundness T_A
⊬ σ. ∎

The same holds for Q-subsets with T_= and T_< and for any theory whose induction-type templates are all term-only
(fixed formula skeleton): those lie inside IΣ_k for some k, and IΣ_k ⊊ PA (pa Prop 4.8(b), from Gödel's second
theorem and PA ⊢ Con(IΣ_k) [known]).

**Prop X11 (which Q axioms are redundant given induction) [proved; models checked numerically]. New.**
(a) Q1, Q2, Q4..Q7 + T_Ind ⊢ Q3. (b) For each i ∈ {1, 2, 4, 5, 6, 7}, the axioms Q_j (j ≠ i) together with every
instance of the induction schema (all formulas, parameters allowed) do not prove Q_i.

*Proof.* (a) T_Ind cites Ind(ψ) for the one-hole motive ψ(x) := x = 0 ∨ ∃y(x = Sy). ψ(0) holds by the first
disjunct, and ψ(Sx) holds by the second with y := x, so the step ∀x(ψ(x) → ψ(Sx)) is a theorem of pure logic.
Hence ∀xψ(x), which gives Q3 propositionally.
(b) In a structure in which every element is the value of a numeral S^k 0, every instance of induction holds: if
φ(0, ā) and ∀x(φ(x, ā) → φ(Sx, ā)) hold, then φ(S^k 0, ā) holds for every k, by induction on k in the metatheory, so
φ holds of every element. Each of the following structures has this property, satisfies Q_j for j ≠ i and falsifies
Q_i:
* i = 1: domain {0}, all operations constant 0 (S0 = 0);
* i = 2: domain {0, 1}, S0 = S1 = 1; x + 0 = x, x + 1 = 1; x·0 = 0, x·1 = x (S0 = S1 although 0 ≠ 1);
* i = 4: ℕ with standard S, x ⊕ y := x + y + 1, x ⊗ y := y(x + 1) (then x ⊕ 0 = x + 1);
* i = 5: ℕ with standard S, x ⊕ y := x, x ⊗ y := 0 (then x ⊕ Sy = x ≠ S(x ⊕ y));
* i = 6: ℕ with standard S and +, x ⊗ y := xy + 1 (then x ⊗ 0 = 1);
* i = 7: ℕ with standard S and +, x ⊗ y := 0 (then 1 ⊗ S0 = 0, while (1 ⊗ 0) + 1 = 1).

Each verification is a line of arithmetic (for i = 4: x ⊕ Sy = x + y + 2 = S(x ⊕ y), x ⊗ 0 = 0, x ⊗ Sy =
(y+1)(x+1) = (x ⊗ y) ⊕ x; the others are similar). `checks/check_models.out` evaluates all seven axioms in each
structure on a finite range and confirms the pattern. ∎

*Consequence for the tags.* A theory made of Q axioms and induction-type templates is deductively equivalent to T*
iff it contains Q1, Q2, Q4..Q7 and a full-induction template (T_Ind, IndSwap, or a connective fragment); if one of
Q1, Q2, Q4..Q7 is missing it is strictly weaker. In particular T* − Q3 is equivalent to T*. The first version
tagged all seven "T* − Q_i" as not equivalent; for T* − Q3 that tag was wrong (it was the MAP in one seed of E2 at
n = 64, so the first version's "equivalent to T*" column slightly undercounted). The tags are computed by
`pa_common.pa_classify` (rules in its docstring; unit test `test_pa_classify_tags`).

**Prop X12 (E6: which forms of commutativity are equivalent) [proved; model checked numerically]. New (referee
M2).** Let A_xy = ∀x∀y x+y=y+x, A_yx = ∀y∀x x+y=y+x, S_ab = {?a+?b=?b+?a}, M_x = {∀x x+?b=?b+x}, M_y =
{∀y ?a+y=y+?a}, all with closed guards, and let S_ab^open, M_x^open, M_y^open be the same templates with open guards
(bodies may contain w0).
(a) A_xy, A_yx, M_x^open and M_y^open are logically equivalent.
(b) S_ab ∪ M_x ∪ M_y ∪ S_ab^open ⊬ A_xy. So S_ab, M_x, M_y and S_ab^open are strictly weaker than A_xy, although
S_ab, M_x and M_y have the same closed instances as A_xy.

*Proof.* (a) A_xy and A_yx differ by the order of two universal quantifiers. M_x^open cites ∀x(x + w0 = w0 + x)
(body ?b := w0), which under the closure reading is ∀w∀x(x + w = w + x), i.e. A_yx; every instance ∀x(x + b = b + x)
of M_x^open, b any term with at most the parameter w0, follows from A_xy by ∀-elimination. Same for M_y^open.
(b) This is the referee's model, extended to one-parameter instances. Domain ℕ ⊔ {α, β}. On ℕ, 0, S, +, · are
standard. S(α) = α, S(β) = β. For a ∈ {α, β} and n ∈ ℕ: a + n = n + a = a; a·n = n·a = a if n ≠ 0 and 0 if n = 0.
α + α = α·α = α, β + β = β·β = β, α + β = α·β = α, β + α = β·α = β. Then ℕ ∪ {a} is closed under S, +, · for each
a ∈ {α, β}, and + is commutative on it. Every closed term denotes a natural number, so every closed instance of
S_ab holds. An instance ∀x(x + t = t + x) of M_x (t closed, value n ∈ ℕ) holds: for x ∈ ℕ by ℕ, for x = a by
a + n = a = n + a. M_y likewise. An instance of S_ab^open is ∀w(f(w) + g(w) = g(w) + f(w)) with f, g terms in the one
parameter w (single-parameter convention); for w ∈ ℕ both values are in ℕ, and for w = a both lie in ℕ ∪ {a},
where + is commutative. (With two parameters the instance w0 + w1 = w1 + w0 would be A_xy; the single-parameter
convention excludes it.) But α + β = α ≠ β = β + α, so A_xy fails. By soundness of first-order logic A_xy is not
derivable. ∎ `checks/check_models.out` evaluates these instances for all terms up to 7 nodes (closed) and 5 nodes
(one parameter).

So the referee's remark that "even with open guards, the single-parameter convention cannot reach ∀x∀y" is right
for S_ab and wrong for M_x and M_y: one bound variable plus the parameter already give two variables.

**Prop X13 (a root split is an exact reparametrisation under L1, chain grammar) [proved; computed in E8].** Let
τ ∈ T be a component with a 0-ary closed-guard term metavariable u (its body is a closed term drawn from Q in the
context without variables or parameter, wherever u occurs), and let τ_f := τ[u := f(?u₁, …, ?u_r)] for the root
symbols f ∈ {0, S, +, ·} (fresh 0-ary closed metavariables). Let T′ := (T ∖ {τ}) ∪ {τ_f : f}. Suppose τ is not an MP
component. For weights w on T define w′ on T′ by w′(τ_f) := w(τ)·q_f, with q_f the root probability of f under Q for a
closed term, and w′ = w elsewhere. Then P^{L1}_{T′,w′} = P^{L1}_{T,w} for every K, c_stop and rule weights.
Consequently, with Dirichlet weights the split is the whole theory with a learned root law for u (model Prop 5.6(a)).

*Proof.* Under Q a closed term has root f with probability q_f and, given the root, independent children drawn from
the same closed-term law (the context of every node of a closed term is the same, §1.2). So "cite τ (probability
w(τ)) and draw u's body from Q" and "cite τ_f (probability w(τ)q_f) and draw the bodies of ?u₁..?u_r from Q" give
the same law on the cited sentence, jointly with the bodies of τ's other metavariables, which are drawn
identically. The other components are unchanged. Every later step of the chain depends only on the current sentence
and on the set of MP components, which is the same in T and T′ because τ, and hence each τ_f, is not an MP
component. So the law of the run, and of the datum, is the same. ∎ This is model Prop 2.6(b) for the chain grammar.

---

## 3. E1: ∀xφ from data about φ

**Setup** (`code/experiments/e1_universal.py`; results `code/results/e1_universal.md`, `.json`). φ ∈ {x+0=x, 0+x=x,
¬(Sx=0)}, given as templates P = φ(?t). Seeds 0–4; n = 1, 2, 4, …, 256 (prefixes of one data stream per seed).
Generators:
* **sch**: L0 citations of φ(?t), closed terms from Q;
* **all**: the L1 chain (K = 1, closed elim terms) from H_∀ = {∀xφ}; about half of the data are ∀xφ itself, the rest
  closed instances;
* **allq**: the same with open elim terms (instances such as φ(Sw0), i.e. the quantified theorem ∀yφ(Sy) in
  closure-normal form);
* **open**: the L1 chain (K = 1, open elim terms) from H_open = {φ(?t), guard open}; Gen turns open instances into
  explicit ∀-sentences such as ∀yφ(Sy);
* **allq2**: the L1 chain with K = 2 from H_∀ (elim with an open term, then Gen), which emits explicit quantified
  theorems derived from ∀xφ.

Pool (15–28 theories at n = 256 depending on generator, φ and seed, counting Mem(D_n)): H_∀, H_sch, H_open, H_∀+sch,
H_∀+open, the over-specific {φ(0), φ(S?z)}, the root splits frag1 (4 templates) and frag2 (37 templates), three
spare-slot theories ({φ(?t), φ(S?z)}, {φ(?t), 0=S0}, {φ(?t), ?u·0=0}), the one- and two-step generalisations of P
(over-general), the bare ?P, and, causally (§1.8), Min of random subsets of D_b and skeleton clusters of D_b for b ∈
{1, 2, 4, …, 64}, b ≤ n. Likelihoods: L0; L1 with the generator's own chain (well specified); for sch data also L1sel.
The L1 pools contain only theories with exact L1 (§1.8); this excluded 65 (open) and 43 (allq2) data-derived theories
for φ = ¬(Sx=0), summed over seeds, mostly skeleton clusters, and nothing else. For allq2 (K = 2) the pool has no bare
formula metavariables. The likelihood fallback and the derivability-oracle fallback were never used. The Dirichlet
bounds replaced the exact sum for some skeleton theories and Mem under L1; the largest posterior mass any of them
could have had is 8·10⁻¹⁴ (results file).

*Revision.* The first version built the data-derived theories from the first 64 data and used them at every n.
With the causal pool every generator-mass entry in the table below is unchanged to the printed precision
(`checks/check_e1_v1.out`; changes above 10⁻³ occur only at n ≤ 4). Two L0 entries of the first version's table were
wrong on its own results, and are corrected here: "H_∀+open takes 1.000 by n = 8" (allq; seed 2 had H_∀+sch at 0.86 at
n = 8) and "Mem takes 1.000 by n = 16" (allq2; in seeds 0 and 4 H_∀+open held the mass until n = 16 and 32).

**Results** (means over 5 seeds and, where the three φ agree, over φ; the φ differ only through prior bits).

| generator | likelihood | mass of the generating theory at n = 4, 8, 32, 256 | MAP at n = 256 (all runs) | P(T ⊢₁ ∀xφ \| D) at n = 256 | first n with generator mass ≥ 0.99 from then on (worst run) |
|---|---|---|---|---|---|
| sch | L0 | 0.87, 0.97, 1.000, 1.000 | H_sch | 2·10⁻⁷ | 16 |
| sch | L1 | 0.84, 0.96, 1.000, 1.000 | H_sch | 3·10⁻⁷ | 16 |
| sch | L1sel | 0.43, 0.42, 0.53, 0.59 | H_sch | 0.484 (x+0=x, 0+x=x), 0.269 (¬(Sx=0)) | never (tie with H_∀) |
| all | L0 | H_∀ dies at the first instance; H_∀+sch is the MAP from n = 8 and has ≥ 0.995 from n = 32 in every run | H_∀+sch | 1.000 | – |
| all | L1 | 0.87, 0.99, 1.000, 1.000 | H_∀ | 1.000 | 16 |
| allq | L0 | H_∀+open has 1.000 from n = 16 in every run (from n = 8 in 4 of 5 seeds) | H_∀+open | 1.000 | – |
| allq | L1 | 0.73, 0.90, 1.000, 1.000 | H_∀ | 1.000 | 16 |
| open | L0 | Mem has 1.000 from n = 16 in every run | Mem | 1.000 | – |
| open | L1 | 0.89, 1.000, 1.000, 1.000 | H_open | 1.000 | 8 |
| allq2 | L0 | Mem has 1.000 from n = 64 in every run (by n = 16 in 3 of 5 seeds; H_∀+open is the MAP at n = 16 in seed 0 and at n = 16 and 32 in seed 4) | Mem | 1.000 | – |
| allq2 | L1 | 0.88, 0.997, 1.000, 1.000 | H_∀ | 1.000 | 16 |

Further computed facts (results file, per φ and seed):
* **The L1 factor is exact.** On sch data the log₂ posterior odds H_sch : H_∀ under L1 are n + 0.090 for x+0=x and
  0+x=x, and n + 1.440 for ¬(Sx=0), at every n and seed: one bit per datum (c_stop = ½) plus the prior difference.
  The prior difference is now computed by the referee's independent prior code, not read off the run
  (`checks/check_x6.out`: largest deviation 1.1·10⁻¹¹ bits). This is Prop X6(a) and universal Thm U2.
* **L1sel is an exact tie.** Under L1sel the odds H_sch : H_∀ stay at the prior odds for all n (largest deviation
  1.0·10⁻¹³ bits, `checks/check_x6.out`), and P(T ⊢ ∀xφ | D) converges to the prior share of the ∀xφ-provers among
  the theories whose L1sel likelihoods are tied with H_sch's (H_∀, H_sch, H_∀+sch and the like): 0.484 or 0.269, not
  0 or 1 (Prop X6(b); universal Thm U10, first regime).
* **Instance generalisation.** The posterior mass of theories deriving a held-out closed instance φ(t*) (mean of
  three) is ≥ 0.999 from n = 8 in every run under L1 and L1sel, and under L0 in every run except open data, where it
  is 0 at n = 4 and 8 in the worst run (Mem without ∀xφ wins there) and 1.000 from n = 16. No held-out instance
  occurs in any training stream (`referee_code/r7_misc.out`). "All instances follow" is learned quickly whichever
  theory wins.
* **Memorisation and over-general templates die fast.** On sch data at n = 8, Mem's mass is ≤ 2.4·10⁻¹² and the
  over-general theories (bare ?P and the generalisations of P) sum to ≤ 7·10⁻⁵, under L0 and L1, in every run (size
  principle); both keep falling exponentially (tables). Under these term laws this is exponential decay of the
  single memoriser Mem(D_n), which pays for every new instance; universal Prop U6 shows slower decay for the memoriser
  *class* under a geometric numeral law, which E1 does not test.
* **Under L0, derived data must be axioms.** Data that are outputs of derivations (∀xφ next to its instances;
  Gen-outputs ∀yφ(Sy)) are explained under L0 only by theories that contain them as axioms: H_∀+sch, H_∀+open, or
  Mem. With Gen-outputs of unbounded variety (open, allq2), L0 ends at Mem: citation alone cannot represent
  "theorems of a small theory".

**Verdicts on the brief's H4 (E1 part).**
* "Instance data move mass away from memorisation and over-general templates at an exponential rate": **computed,
  confirmed** for over-general templates and for the single memoriser Mem(D_n) under these term laws.
* "Instance data do not by themselves move mass from H_sch to H_∀; under a derivation likelihood they may move it
  the other way by c^(−n)": **computed, confirmed exactly** (L1: one bit per datum; L1sel: no movement; L0: H_∀ has
  likelihood 0 on instances).
* "'All future data are φ-instances' gets probability → 1, but 'the axioms prove ∀xφ' need not": **computed,
  confirmed**: P(⊢ held-out instance) ≥ 0.999 from n = 8 while P(⊢ ∀xφ) → 0 (L0, L1) or stays at the prior share
  (L1sel).
* "With open instances and Gen, H_open ⊢ ∀xφ": **computed**: H_open is identified on open data and P(⊢∀xφ) → 1.
* "Quantified theorems whose derivations use ∀xφ shift mass to H_∀": **computed, confirmed under L1** when they are
  generated by H_∀ (allq, allq2), and **refined**: if the quantified theorems come from H_open with Gen, the mass
  goes to H_open, which also proves ∀xφ. Under L0 they shift mass to theories that list them, not to H_∀.

---

## 4. E2: unlabelled PA mixture (revised; referee M1)

**Setup** (`code/experiments/e2_pa.py`, `pa_common.py`; results `code/results/e2_pa.md`, `.json`). Data: L0 citations
from T* = Q1..Q7 + T_Ind (dtrc numbering, §2) with **fixed** weights 0.05 for each Q axiom and 0.65 for T_Ind;
induction motives from Q (one hole, no parameter). Seeds 0–24 (the first version used 0–4); n = 8, …, 512.
Likelihood L0 with the same Q (well specified as to the instance law; the weights are fixed, so Prop X8(c), not
X8(a), is the applicable soundness statement).

Pool at n (causal, §1.8):
* fixed: T*; T* − Q_i for each i; frag-complete (Q + the 9 root fragments T_f of Prop X9); frag-atoms (Q + T_=, T_<);
  spare slots T* + T_∧ (nested), T* + ∀x(0+x=x) (a true sentence), T* + 0=S0 (a false one); IndSwap (Q + the swapped
  induction template, deductively equivalent, never cited); over-general induction variants ("any base", "any
  antecedent"); Q-lumped ({∀x∀y ?P(x,y), ∀x ?P(x), T_Ind}); bare ?P;
* built from D_b, b ∈ {8, 16, 32, 64}, b ≤ n: frag-observed@b, skeleton clusters (k = 4, 6, 8), DTRC with the dtrc PA
  refuter, Q + Min of random subsets of the induction data;
* Trim(T, D_n) for every pool theory T (SeenQ(D_n) = Trim(T*, D_n) among them), and Mem(D_n).

Tags by `pa_common.pa_classify` (Props X9–X11, and the budgeted refuter for other templates): *equivalent* to T*,
*weaker* (sound, strictly weaker), *unsound*, *unknown*. Held-out induction instances are now drawn outside the
training stream (referee m5). For comparison the first version's ("legacy") pool is also evaluated at n ≤ 64: its
data-derived theories are built from the first 16, 40 and 64 data, and it has no trimmed theories. The Dirichlet
bounds replaced the exact sum for two skeleton theories (skel6@32, skel6@64) in some seeds; the largest posterior
mass they could have had is 0 to double precision (`checks/check_bounded.out`).

**Posterior mass (means over 25 seeds; causal pool).**

| n | T* | equivalent to T* | weaker | unsound | seeds where a δ = 0.05 verifier accepts a false probe | MAP [tag] (count of 25) |
|---|---|---|---|---|---|---|
| 8 | 2·10⁻²¹ | 4·10⁻¹³ | 0.744 | 0.256 | 2 | skel4@8 [weaker] 12, DTRC@8 [weaker] 6, trim:Q-lumped [unsound] 4, Q-lumped [unsound] 2, … |
| 16 | 9·10⁻⁷ | 5·10⁻⁶ | 0.803 | 0.197 | 3 | skel6@16 [weaker] 9, skel4@16 [weaker] 5, Q-lumped [unsound] 3, DTRC@8 [weaker] 3, … |
| 32 | 0.197 | 0.197 | 0.727 | 0.077 | 0 | T*−Q2 [weaker] 7, skel6@32 [weaker] 6, T* 5, T*−Q7 [weaker] 2, … |
| 64 | 0.751 | 0.791 | 0.200 | 0.009 | 0 | T* 19, T*−Q3 [equivalent] 1, … |
| 128 | 0.991 | 0.991 | 0 | 0.009 | 0 | T* 25 |
| 512 | 0.996 | 0.996 | 0 | 0.004 (spare-false) | 0 | T* 25 |

**SeenQ(D_n) = {the Q axioms cited in D_n} + T_Ind.**

| n | mean number of Q axioms seen | mean posterior of SeenQ | code length SeenQ − Q-lumped (bits; mean, range over seeds) |
|---|---|---|---|
| 8 | 2.5 | 0.744 | −16.8 (−49.1 to +8.9) |
| 16 | 4.0 | 0.803 | −38.1 (−92.8 to +12.7) |
| 32 | 5.7 | 0.923 | −87.6 (−169.7 to −25.1) |
| 64 | 6.7 | 0.991 | −255.0 (−446.3 to −122.4) |

At n ≤ 32 SeenQ is usually in the pool already under the name of a data-derived theory (the skeleton clusterer and
DTRC, run on D_n, return exactly SeenQ in 25 of 25 seeds at n = 8); from n = 64 it is usually T* itself or T* − Q_i.

**Legacy pool against causal pool** (seeds in which a δ = 0.05 verifier accepts a false probe, of 25).

| n | legacy pool | causal pool | mean unsound mass, legacy | mean unsound mass, causal |
|---|---|---|---|---|
| 8 | 18 | 2 | 0.720 | 0.256 |
| 16 | 3 | 3 | 0.147 | 0.197 |
| 32 | 2 | 0 | 0.081 | 0.077 |
| 64 | 0 | 0 | 0.009 | 0.009 |
| some n ≤ 64 | 19 | 5 | | |

**Code length relative to T* (bits, mean over 25 seeds; positive = worse).**

| n | frag-complete | T* + T_∧ (nested spare) | T* + ∀x(0+x=x) (unused true) | T* + 0=S0 (unused false) | Q-lumped |
|---|---|---|---|---|---|
| 8 | 696.9 | 87.6 | 13.8 | 5.1 | −100.0 |
| 64 | 703.6 | 88.5 | 15.1 | 6.3 | 248.2 |
| 512 | 716.3 | 89.2 | 16.6 | 7.8 | 2928.5 |

**Findings.**
1. **T* takes the mass once every needed axiom has been cited** [computed]. Before that the posterior prefers the
   sound but weaker SeenQ: an axiom that has never been cited costs its prior bits plus the Dirichlet factor of Prop
   X7(a). Q3 is not needed: T* − Q3 is equivalent to T* (Prop X11). Over the 25 seeds the last of Q1, Q2, Q4..Q7
   first appears at datum 20–97 (median 55); the mass on theories equivalent to T* is ≥ 0.95 from n = 32 (5 seeds),
   64 (15) or 128 (5) on; T* is the MAP in every seed from n = 128 and has mean mass 0.996 at n = 512.
2. **Early unsound lumping is real but rarer than the first version reported** [computed; refutes the first
   version's frequency]. At n ≤ 16 the lump Q-lumped (or its trim, which drops a lump component that no datum uses)
   beats SeenQ in some seeds: by up to 8.9 bits at n = 8 and 12.7 at n = 16. A δ = 0.05 verifier then accepts the
   false sentences ∀x(x+0=0), ∀x(Sx=x) and ∀x∀y(y=x) in 2 seeds at n = 8 and 3 seeds at n = 16, 5 of 25 seeds in all,
   and never from n = 32. With the legacy pool it accepts in 19 of 25 seeds (18 at n = 8), which reproduces the
   referee's count (`referee_code/r2_e2_seenq.out`). The drop from 19 to 5 has two causes, both found by the referee:
   the legacy pool lacked SeenQ, and its sound stand-ins (DTRC(n=16), skeletons of the first 40 data) were built from
   unseen data and so carried axioms not yet cited, which cost prior bits. The referee's own variant, the legacy pool
   plus SeenQ, accepts in 4 of 25 seeds (1, 4, 11 at n = 16; 17 at n = 8). The causal pool accepts in the same four
   and in seed 14 at n = 8, where trimming creates a cheaper lump: trim:Q-lumped, Q-lumped without a component that no
   datum uses, is the MAP with mass 1.000. So the causal pool is not uniformly more favourable to soundness. Mean
   unsound mass: 0.256, 0.197, 0.077, 0.009 at n = 8, 16, 32, 64; from n = 64 it is the false spare slot only.
   *Relation to Prop X8.* The data have fixed weights, so X8(a) does not apply; X8(c) requires δ_n ≤ 2^(−226)·R(n,
   8)·δ′ with R(n, 8) ≍ n^(−3.5), a threshold no practical verifier uses. So the acceptances do not contradict X8. The
   first version said the guarantee "needs δ ≤ 2^(−226)·δ′", citing X8(a), whose hypothesis (weights drawn from the
   prior) the data do not satisfy (referee M3). This is the Bayesian form of the MDL observation `AS:app:many:mdl`
   that rarely used ground axioms are lumped unsoundly, and of pa §5.4.
3. **With a well-specified Q, fragmentation does not win** [computed; consistent with `AS:prop:many:mdlwell`, model
   Prop 5.4]. frag-complete has exactly T*'s instance set (Prop X9(a)), and its family of data laws contains T*'s
   law (weights w_Ind·q(f); Prop X13 is the L1 analogue). So it can only lose: its code length exceeds T*'s by the
   prior difference (698.9 bits) plus a Dirichlet term: +697 at n = 8, +716 at n = 512, 4.2 bits per doubling of n
   between n = 64 and 512 (the asymptotic value is (16 − 8)/2 = 4).
4. **Spare slots decay polynomially, at the predicted rates** [computed; Prop X7]. Unused spare sentences grow by
   0.49 bits per doubling between n = 64 and 512 (α = ½), the nested T_∧ by 0.25 bits per doubling (α/2). So the
   inconsistent theory T* + 0=S0 keeps posterior mass 0.004 at n = 512 and loses it only like n^(−1/2): positive
   data never refute it.
5. **A deductively equivalent but uncited axiomatisation gets nothing** [computed]. IndSwap has the same theorems
   as T* but likelihood 0 under L0 from the first induction datum. Under citation, identification is of the cited
   axioms, not of the theory.
6. **Over-general induction templates die fast** [computed]. "Any base" (Q + (?A ∧ ∀x(?P(x) → ?P(Sx))) → ∀x ?P(x))
   and "any antecedent" (Q + ?A → ∀x ?P(x)) cover every induction datum but spend probability on sentences T* never
   emits. Their code lengths exceed T*'s by 147 and 538 bits at n = 8 (means; at least 19 and 83 in every seed), by
   at least 215 and 942 bits in every seed from n = 32 on, and by 8303 and 32624 bits at n = 512: linear in n.

*Refuted claims of the first version (kept).*
* *[refuted]* "In 3 of 5 seeds an unsound lump of the rarely used Q axioms has mass ≥ 0.997 at some n ≤ 32, and a
  δ = 0.05 verifier accepts a false sentence." True for the first version's pool and seeds 0–4. As a statement about
  the method it overstated the frequency: with a pool built from seen data and containing SeenQ, it happens in 2 of
  seeds 0–4 (seeds 1 and 4, at n = 16) and in 5 of 25 seeds. Counterexample to the representativeness of "3 of 5":
  seed 2 at n = 32, where the legacy skel4 (built from 40 data) had mass 1.0; in the causal pool the unsound
  skel4@32 (built from D_32) has mass 0.85, below the acceptance level.
* *[refuted]* "MAP at n = 8: DTRC(n=16) ×3, Q-lumped ×2." DTRC(n=16) was built from data 9–16, which the learner
  had not seen at n = 8.

---

## 5. E3: misspecification (revised; referee M4, m11, m12)

**Setup** (`code/experiments/e3_misspec.py`; results `code/results/e3_misspec.md`, `.json`). In every generator all
data are theorems of the target (instances of φ(?t), or Q axioms and induction instances), but their distribution
is not that of any pool theory. Seeds 0–4.

**(a) φ = x+0=x**, model Q = default grammar, likelihoods L0 and L1 (closed elim, K = 1), n up to 1024 (L0) and 512
(L1). Generators: *heavy*: a zeta(1.5) numeral S^k0 (k ≤ 400) with probability 0.7, else S^k(t₁ ∘ t₂) with zeta k
and Q-terms; *numerals*: S^k0 with k ~ Geometric(0.2); *small*: Q-terms selected to have at most 4 symbols (a
selected set of theorems, 12 distinct sentences); *skewQ*: another PCFG (0: 0.5, S: 0.1, +: 0.2, ·: 0.2). Pool: the
E1 hand pool, numeral splits N_m = {φ(0), …, φ(S^{m−1}0), φ(S^m ?z)} for m = 1..16 (the first version stopped at
m = 4), the nested chains C_1 = {φ(?t), φ(S?z)} (E1's spare_nested) and C_2 = {φ(?t), φ(S?z), φ(SS?z)} (new; deeper
chains need more than three overlapping components, beyond the exact dense DP), and causal Min and skeleton
theories (build points 8, 32, 64). Theories are grouped by their instance set relative to inst(φ(?t)): the same, a
subset (over-specific; incomplete), a superset (over-general, spare slots with extra sentences, H_open), ∀-type,
memorisers. The likelihood and oracle fallbacks were never used. Wherever the Dirichlet bounds replaced the exact
sum, the largest posterior mass the theory could have had was 0 to double precision (results file;
`checks/check_bounded.out` for seed 0: no case).

| generator | MAP at the largest n (5 seeds; L0 and L1 alike) | instance set of the MAP | gain of the MAP over H_sch, L0 (bits; n = 512 → 1024) | P(⊢ held-out instance) at the largest n | largest mass on superset theories at the largest n (over seeds and both likelihoods) |
|---|---|---|---|---|---|
| heavy | C_2 (3 seeds), {φ(?t), φ(SS?z)} (2 seeds; a skeleton theory of D_8) | same | 212 → 455 (range 194–238 → 436–471) | 1.000 | 3·10⁻⁶³ (L1, n = 512) |
| numerals | N_9 or N_10 at n = 512, N_11 or N_12 at n = 1024 | subset | 1271 → 2897 | 0.333 (only the numeral one) | 0 |
| small | H_sch up to n = 512; Mem at n = 1024 (L0, all seeds) | same → finite | 0 → 156 | 1.000 → 0.000 | 7·10⁻⁵ (L1, n = 512) |
| skewQ | frag1 (from n = 512) | same | 70 → 212 | 1.000 | 2·10⁻²⁰ (L1, n = 512) |

Code length relative to H_sch on the extended families (L0, mean over seeds, bits; negative = preferred; C_1 and
C_2 on heavy data, N_m on numeral data):

| n | C_1 | C_2 | N_4 | N_9 | N_11 | N_12 | N_16 |
|---|---|---|---|---|---|---|---|
| 128 | −0.2 | −11.5 | −162.0 | −86.6 | −3.0 | +46.6 | +300.2 |
| 512 | −76.3 | −204.4 | −978.8 | −1270.0 | −1248.5 | −1220.7 | −1015.0 |
| 1024 | −165.5 | −447.0 | −2063.1 | −2835.1 | −2894.6 | −2895.1 | −2751.7 |

**Findings (a).**
1. **The posterior moves to the theory that best matches the usage statistics, at a rate linear in n**
   [computed]. Within L0 the gain over H_sch roughly doubles from n = 512 to 1024 (heavy 212 → 455 bits, 0.47 bits per
   added datum; numerals 1271 → 2897; skewQ 70 → 212, 0.28 bits per added datum). The first version compared L1 at
   n = 512 with L0 at n = 1024 (referee m11). This is the misspecified half of `AS:sec:many:mdl` ("MDL tracks the
   statistics of usage, not the logical boundaries of schemas") in Bayesian form: the model's Q fixes the usage
   statistics, and a theory with extra components can re-weight them.
2. **The named winners are members of families, not fixed theories** (referee m12). With numeral data the best
   numeral split deepens with n: N_4 or N_5 at n = 128, N_9 or N_10 at 512, N_11 or N_12 at 1024, and the family
   is now interior at every n (N_16 is worse than N_12 at n = 1024). This reproduces the referee's extension
   (`referee_code/r6_e3_extensions.out` (a)) and matches universal Prop N3(d) ("the posterior follows ever deeper
   splits"). With heavy-tailed terms the winner is the deepest nested theory available: C_2, or the two-component
   {φ(?t), φ(SS?z)} that a skeleton clusterer built from D_8. C_2 gains on C_1 at a linear rate (−447 against −166
   bits at n = 1024), so a deeper chain would probably win if it were in the pool [conjecture; not computed]. The
   first version named N_4 and {φ(?t), φ(S?z)} as the winners; both were the edges of the families it had.
3. **In these runs misspecification never moved mass to over-general (unsound) theories at large n** [computed]:
   the superset mass at the largest n is at most 7·10⁻⁵ in every run. Earlier it can be larger (up to 0.20 at
   n = 8 under *small*; this class includes the sound H_open as well as over-general templates). With positive data
   only, a superset theory always pays the size principle, so this is expected; it is not a guarantee (see E4 C1 for
   data with mistakes).
4. **What fails is completeness** [computed]. With numerals only, the winner does not derive φ(2+3) or φ(1·4): the
   posterior mass on theories deriving these held-out instances is 0 at n = 1024 (only the numeral instance φ(9) is
   derived). With a finite selected support (*small*), the posterior concludes at n = 1024 that the axioms are
   exactly the 12 observed sentences, and no held-out instance is derived. Both are reasonable inferences from the
   data seen; both lose the universal law that generated the theorems before selection. This is model Example 3.2's
   phenomenon: all data are theorems of T*, and the posterior goes to a strictly weaker theory.
5. **Under L1 the same happens**; L1 adds the factor of Prop X6 against ∀-type theories and otherwise agrees with
   L0 on instance-only data (identical MAPs at every n ≤ 512 in every run).

**(b) PA mixture with a misspecified motive law** (L0; same fixed weights as E2; n up to 2048). Generators:
*dtrc-motive* (motives from the dtrc generator `pa_motive`, without parameters: bounded quantifiers, other
frequencies); *root-skew* (motive root drawn from {→ 0.5, ∧ 0.2, = 0.2, ∃ 0.1}, the rest from Q); *deep* (a PCFG with
more connectives); **atomic** (new, referee M4: motive a(x) = b(x) with probability 0.6 or a(x) < b(x) with 0.4, a
and b Q-terms with one hole). Pool: the causal E2 pool (with trimmed theories and Mem(D_n)) plus T* + T_f for every
root f (nested fragments, equivalent to T*). Wherever the Dirichlet bounds replaced the exact sum, the largest
posterior mass the theory could have had was 0 to double precision.

| generator | MAP at n = 256 / 1024 / 2048 (5 seeds) | mass equivalent to T* at 2048 | mass weaker than T* at 2048 | T* at 2048 | unsound mass at n = 16 (mean; max over seeds) |
|---|---|---|---|---|---|
| dtrc-motive | T* / T* + T_∃ / T* + T_∃ | 1.000 | 0 | 5·10⁻⁷⁰ | 0.25; 1.0 |
| root-skew | T* + T_→ / frag-observed@16 or @32 / the same | 1.000 | 0 | 0 | 0.52; 1.0 |
| deep | T* / T* / T* | 0.998 | 0 | 0.998 | 2·10⁻¹¹; 7·10⁻¹¹ |
| **atomic** | frag-atoms (4 seeds), T* (1) / frag-atoms / frag-atoms | 2·10⁻¹⁷⁸ | 1.000 | 4·10⁻²⁹⁸ | 0.21; 0.999 |

Code length relative to T* at n = 2048 (bits, range over seeds): root-skew: frag-observed@b −1387 to −1509,
frag-complete −965 to −1087, T* + T_→ −789 to −957; dtrc-motive: T* + T_∃ −228 to −318, frag-complete +8 to +125;
deep: frag-complete +665 to +674; atomic: frag-atoms −986 to −1028, frag-complete −396 to −437, T* + T_= −128 to −182.

**Findings (b).**
6. **Axiom-level identification fails under a misspecified motive law** [computed]. With dtrc motives the posterior
   moves from T* (0.994 at n = 256) to T* + T_∃ (a nested fragment that re-weights existential motives) by
   n = 1024. With the root-skewed law it moves to T* + T_→ and then to the observed-root split frag-observed@b
   (Q + the fragments of the four roots the generator uses), which beats T* by 1387–1509 bits at n = 2048.
7. **Theorem-level identification survives for connective-rich motive laws, and fails for atomic ones** [computed;
   Props X9, X10]. In the first three generators every winner contains T_Ind or a connective fragment and all of
   Q1, Q2, Q4..Q7, so it is deductively equivalent to T* (Prop X9(b)); the mass on theories equivalent to T* is
   0.998–1.000 at n = 2048. With atomic motives — every datum still a theorem of T* — the posterior moves at a linear
   rate to frag-atoms = Q + {T_=, T_<} (mass 1.000 in every seed from n = 1024; −986 to −1028 bits against T* at n =
   2048), which is **strictly weaker** than T*: it does not prove the irrationality of √2, which T* proves (Prop X10).
   At n = 64 T* had mass 0.988 in 4 of 5 seeds, so the posterior moves *away* from T* as data accumulate. This
   reproduces the referee's finding (`referee_code/r6_e3_extensions.out` (c)) with a causal pool. The first version's
   summary ("robust at the level of theorems but not of axioms") is **refuted** as a general statement: it holds for
   the motive laws first tried, not for a natural narrow one. Pa §4.3 finds the same with its code ("narrow practice
   can put the posterior on the weaker side").
8. **Citation-level derivability is lost even when theorems are kept** [computed]. Under root-skew the winners lack
   the fragments for roots not seen, so they do not *cite* every held-out induction instance (mass citing them at
   K = 0: 0.40 at n = 2048, mean over seeds), although they prove them all (Prop X9(b)). Under atomic motives the
   winner cites only the held-out instances with atomic motives (0.37). It does not prove every instance of T_Ind
   (otherwise it would prove σ, contradicting Prop X10); which of the other held-out instances it proves is not
   computed.
9. **The early unsound lumping recurs** at n = 16 (mean unsound mass 0.21–0.52 under dtrc-motive, root-skew and
   atomic; mass ≥ 0.999 in some seed of each), as in E2.

---

## 6. E4: an adaptive prover against the threshold verifier

**Setup** (`code/experiments/e4_ville.py`; results `code/results/e4_ville.md`, `.json`; check
`checks/check_e4_tight.py`). The verifier accepts s iff the posterior mass of {T : T ⊢₁ s} is ≥ 1 − δ. The prover
wins if some s with T* ⊬₁ s is ever accepted. In every setting below T* has one component, so data i.i.d. from T*
are data from its Dirichlet-averaged law and Prop X8(a), (b) apply: P(win) ≤ δ′ when δ = w*·δ′.

**(A) The tight construction** (`IL:prop:caution:tight` in theory form). T* = {φ(?t)} with numerals only and
P(t = 0) = 1 − u; the decoy T′ = {φ(0), 0=S0}; prior w* on T*; the prover asks 0=S0 in every round. T′ fits the
frequent datum φ(0) better (Dirichlet weight on one sentence) and dies at the first other datum. The prover wins
iff the first t* data are φ(0), where t* is the first n with π_n(T*) ≤ δ given φ(0)ⁿ; so P(win) = (1 − u)^t* exactly.

| u | w* | δ′ | t* | exact P(win) | closed-form Monte Carlo (10⁵ streams) | full pipeline (400 streams) | bound δ′ | selected data (only φ(0)) |
|---|---|---|---|---|---|---|---|---|
| 0.05 | 0.01 | 0.01 | 150 | 0.00046 | 0.00046 | 0/400 | 0.01 | 20/20 |
| 0.01 | 0.001 | 0.05 | 680 | 0.00108 | 0.00123 | not run (t* > 200) | 0.05 | 20/20 |
| 0.5 | 0.01 | 0.01 | 10 | 0.00098 | 0.00095 | 2/400 | 0.01 | 20/20 |
| 0.1 | 0.1 | 0.1 | 47 | 0.00707 | 0.00694 | 5/400 | 0.1 | 20/20 |
| 0.2 | 0.05 | 0.2 | 17 | 0.02252 | 0.02298 | 6/400 | 0.2 | 20/20 |

* The win probability is always below the bound δ′ [computed; Prop X8]. Here it is 9–46 times below it. The
  Dirichlet factor of T′ (≈ n^(−1/2)) delays t* compared with the fixed-weight construction of
  `IL:prop:caution:tight`, which reaches 0.99δ′ (model §4.1 shows that a small fixed weight on the decoy's extra
  sentence attains the IL value exactly).
* The full pipeline (posterior + derivability + threshold) wins on exactly the streams where the first t* data are
  φ(0): 400/400 agreement in two settings (`checks/check_e4_tight.out`, re-run on the final code).
* With *selected* data (only φ(0) is shown; every datum is still a theorem of T*), the prover wins in every run.
  Well-specification of the theorem set is not enough; the data law matters (model Prop 4.2).

**(B, C) Pools.** φ = x+0=x, T* = H_sch. Pool: the E1 hand alternatives (those with exact L1) plus Mem(D_n), and per
setting one extra theory; no data-derived theories. w* = 2^(−bits(T*))/(Σ_pool 2^(−bits) + 1) = 7·10⁻⁶ (Prop X8(b),
valid with the data-dependent Mem). δ = 0.05·w*, so the bound is 0.05. In every round the prover asks every
statement of a fixed list that T* does not derive: ∀x(x+0=x), 1+0=0, 0+0=1, 0=S0, 2+0=3, 7+0=8, (1+1)+0=S(1+1),
0=0 (8 sentences; the code's list has 9 entries because it writes 1+0=0 twice, once as `S0+0=0`;
`checks/check_e4_where.out`). Two of these are true (∀x(x+0=x), 0=0); the guarantee is about derivability from T*,
not truth. 100 streams per row, n = 1..256, **every n checked** (the first version checked 88 values of n; referee
m6), L0 and L1 (closed elim, K = 1) alike. The derivability-oracle and likelihood fallbacks were never used.

| setting | data | prover wins (L0 / L1) | largest mass ever on an invalid query (L0 / L1) | MAP at n = 256 |
|---|---|---|---|---|
| B | well specified: L0 citations of φ(?t) | 0/100 / 0/100 | 0.4524 / 0.5329 | H_sch x100 |
| C1 | 10% of data replaced by false near misses t+0=St; the pool also has {φ(?t), ?t+0=S?t} | 100/100 / 100/100 | 1.0000 / 1.0000 | sch+mistake-schema x100 |
| C2 | heavy-tailed terms (as E3 heavy) | 0/100 / 0/100 | 0.4524 / 0.5358 | spare_nested x96; H_sch x4 |
| C3 | only φ(0) is shown; the decoy T′ is in the pool | 0/100 / 0/100 | 0.1072 / 0.1120 | Mem x100 |

**Findings** [computed].
1. **Well specified: no wins**, within the bound. The largest mass ever put on theories deriving an invalid query is
   0.4524 (L0) and 0.5329 (L1). In all 200 streams it is the mass on the true but T*-underivable ∀x(x+0=x), and it
   occurs at n ≤ 6 (at n ≤ 3 in 184 streams). At that point it sits on H_open, which derives ∀x(x+0=x) by Gen (mean
   0.23 under L0, 0.21 under L1), on H_∀ under L1 (0.15), and on the one-step generalisation of P (0.03–0.04)
   (`checks/check_e4_where.out`, which re-runs the streams to n = 32 and reproduces every maximum). It is never near 1
   − δ.
2. **Mistakes in the data make the verifier accept false sentences, every time.** The posterior goes to the theory
   that also contains the mistake pattern, and accepts false instances such as 0+0=1, first at n = 1 to 39 (median 7);
   in 90 of the 100 streams of each likelihood this is the very datum at which the first mistake appears, in the other
   10 between 2 and 5 data later (`checks/check_e4_where.out`). Queries first accepted: 0+0=1 (196 streams), 2+0=3 (4
   streams). Relative to the generator this is no failure: the generator is that two-schema theory with fixed weights
   (0.9, 0.1), and Prop X8(c) applies to it (with its shrinking threshold). Relative to the intended T* it is the
   failure that the brief's H2 anticipated: nothing forces the data-law minimiser to be "the actual axioms".
3. **Misspecification by heavy tails or by selection did no harm here, because a clean better-fitting theory was in
   the pool.** Under selection the posterior goes to Mem = {φ(0)} rather than to the decoy {φ(0), 0=S0}, which
   costs more prior bits and a Dirichlet factor. Compare (A), where the decoy was the only alternative and won
   every time. Soundness under misspecification depends on what else is in the pool; I have no theorem for this
   (open problem 5).

---

## 7. E5: spare slots, L_∞ against L_k, and Gold's text

**Setup** (`code/experiments/e5_gold.py`; results `code/results/e5_gold.md`, `.json`). Seeds 0–9 (numpy seed 0 for
the quadrature draws). Dirichlet α = ½. Unchanged from the first version except (a2), which now uses 1000 draws per n
and reports standard errors (referee m14).

**(a) Spare slots** [computed; Prop X7]. Data: L0 citations of φ(?t) (φ = x+0=x). Exact log₂ Bayes factors of
T + spare against T = {φ(?t)}.

| spare | mean log₂ BF at n = 1, 16, 256, 4096 | slope against log₂ n (n = 256 → 4096) | extra prior bits |
|---|---|---|---|
| false sentence 0=S0 (never cited) | −1.00, −2.84, −4.83, −6.83 | −0.500 | 8.4 |
| disjoint schema ?u·0=0 (never matched) | −1.00, −2.84, −4.83, −6.83 | −0.500 | 14.5 |
| nested φ(S?z) | +0.17, −1.05, −2.85, −3.97 | −0.281 | 21.3 |

The two unused spares agree with the exact formula of Prop X7(a) to all printed digits on every seed (the factor
does not depend on the data). The nested spare decays more slowly.

**(a2) The nested spare at large n.** The Bayes factor depends only on n and the number n_S of S-rooted data (Prop
X7(b)): BF = E[(1 − w₂ + w₂/q_S)^{n_S}(1 − w₂)^{n−n_S}] with w₂ ~ Beta(½, ½) and q_S = 0.35. It is computed by
quadrature with n_S ~ Binomial(n, q_S), 1000 draws per n. The quadrature agrees with the exact DP at n = 500 to
10⁻⁴ bits (two seeds; the referee's exact Beta-moment sum agrees with it to 3·10⁻⁴ bits up to n = 10⁶).

| n | 10² | 10³ | 10⁴ | 10⁵ | 10⁶ | 10⁷ | 10⁸ |
|---|---|---|---|---|---|---|---|
| mean log₂ BF | −2.196 | −3.028 | −3.867 | −4.658 | −5.575 | −6.332 | −7.200 |
| s.e. of the mean | 0.030 | 0.029 | 0.029 | 0.031 | 0.029 | 0.030 | 0.028 |

The least-squares slope of the mean against log₂ n is −0.251 ± 0.002 (n = 10²…10⁸) and −0.251 ± 0.003 (n = 10⁴…10⁸; ±
one standard error from the draws); the slope on each successive decade is −0.250, −0.253, −0.238, −0.276, −0.228,
−0.261. This supports the rate n^(−α/2) = n^(−1/4) of Prop X7(b) and model Prop 5.5(c) [computed; the proposition
itself is a proof sketch]. The first version reported −0.259 from 200 draws without a standard error; the referee's
independent sum gave −0.233 on n = 10²…10⁷ with 40 draws.

So a spare slot never dies at an exponential rate. A spare slot holding a false sentence makes the theory
inconsistent, and positive data remove it only like n^(−1/2), on top of its prior cost. This is what Gold's
theorem leaves to a Bayesian learner: no refutation, only polynomial attrition.

**(b) L_∞ against L_k** [computed]. Numerals only: Q_num gives S^j0 probability 2^(−(j+1)).
L_k = {φ(0), …, φ(S^{k−1}0)} (k ground sentences with Dirichlet weights), k = 1..40, and L_∞ = {φ(?t)}. Prior
bits: L_1 10.9, L_5 89.4, L_8 187.9, L_∞ 17.1.
* Data i.i.d. uniform on L_5: the posterior first prefers L_∞ (prior), then switches to L_5 between n = 64
  (mass of L_5: 2·10⁻⁶) and n = 128 (0.66), and has L_5 mass 1.000 from n = 256 in all 10 seeds. Per datum L_5
  gains 3 − log₂5 ≈ 0.68 bits over L_∞ (code length log₂5 = 2.32 bits against the mean code length 3 bits under
  Q_num), which repays the 72-bit prior difference, plus L_5's Dirichlet cost of about 2 log₂ n bits, between
  n = 64 and 128.
* Data i.i.d. from L_∞: L_∞ has mean mass 0.986 at n = 4, 0.999 at n = 8, and 1.000 from n = 16; it is the MAP
  in all 10 seeds from n = 4.

So with stochastic data the Bayesian learner identifies both ends of Gold's limit point, L_5 and L_∞ (conv §9's
"L_∞ versus L_5"; model Prop 5.2): it does not need to choose a preference in advance; the size principle decides.

**(c) Gold's text** [computed]. Against the MAP learner over {L_1, …, L_60, L_∞}, stage i presents
φ(0), …, φ(S^{i−1}0) round-robin until the MAP is L_i. The first 14 stages all end: lengths 1, 24, 81, 115, 104, 83,
68, 55, 45, 39, 33, 33, 32, 27 (740 data). These are the first 14 stages of a sequence which, if every stage ends,
is a text for L_∞ on which the MAP changes at every stage, as Gold's theorem requires of some text (referee m10: that
every stage ends is shown here only for 14 stages). The stages shorten after i = 4 because L_∞'s cost per datum on
round-robin data grows with i (mean code length 1 + (i−1)/2 bits) while L_i pays log₂ i. Such texts have probability
0 under i.i.d. sampling from L_∞ (model Prop 5.2(c)), which is why (b) succeeds.

---

## 8. E6: generating axiomatisations, logically equivalent and merely instance-equivalent (revised; referee M2)

**Setup** (`code/experiments/e6_equivalent.py`; results `code/results/e6_equivalent.md`, `.json`). Commutativity of
addition in eight forms: A_xy = {∀x∀y x+y=y+x}, A_yx = {∀y∀x x+y=y+x}, the closed schema S_ab = {?a+?b=?b+?a}, the
mixed M_x = {∀x x+?b=?b+x} and M_y = {∀y ?a+y=y+?a} (closed guards), and, new in this revision, the open-guard forms
M_x^open, M_y^open and S_ab^open; also A_xy+A_yx, A_xy+S_ab and Mem(D_n). Prior bits: A_xy, A_yx 31.6; S_ab, S_ab^open
30.0; M_x, M_y, M_x^open, M_y^open 28.4. Data: the L1 chain (K = 2, c_stop = ½, closed elim terms) from A_xy and from
M_x, and L0 citations of S_ab; seeds 0–4; n up to 256. Likelihoods: L1 (that chain) and L1sel (the same stream
filtered to closed quantifier-free outputs). The pool is fixed (no data-derived or trimmed theories). The Dirichlet
bounds replaced the exact sum only for Mem, whose largest possible mass was 0 to double precision
(`checks/check_bounded.out`).

**What is equivalent to what** (Prop X12). A_xy, A_yx, M_x^open and M_y^open are logically equivalent. S_ab, M_x,
M_y and S_ab^open are strictly weaker than A_xy; S_ab, M_x and M_y have exactly the closed instances of A_xy. The
first version called all five closed-guard forms "logically equivalent". That claim is **refuted** (referee M2;
counterexample: the model of Prop X12(b), in which every instance of S_ab, M_x and M_y holds and α + β ≠ β + α).

| data from | L1: generator's mass at n = 2, 4, 8, 16, 256 | L1: first n with generator mass ≥ 0.99 from then on (per seed) | L1: P(proves A_xy) at n = 4, 256 | L1sel at n = 256 (all three sources) |
|---|---|---|---|---|
| A_xy | 0.34, 0.90, 1.000, 1.000, 1.000 | 8, 8, 8, 4, 2 | 1.000, 1.000 | A_xy 0.044, A_yx 0.044, S_ab 0.128, M_x 0.392, M_y 0.392; open-guard forms ≤ 6·10⁻⁹; P(proves A_xy) = 0.088 |
| M_x | 0.60, 0.80, 0.90, 0.99, 1.000 | 32, 16, 8, 16, 16 | 0.205, 7·10⁻⁴⁹ | the same |
| S_ab | 0.28, 0.56, 0.95, 1.000, 1.000 | 16 in every seed | 0.060, 1·10⁻¹¹ | the same |

**Findings** [computed; Props X6, X12].
1. **L1 identifies the generating axiomatisation**, both among logically equivalent ones and among instance-
   equivalent but weaker ones, by n = 32 in every run. A_xy is told apart from its logically equivalent twin A_yx
   and from M_x^open and M_y^open through partially instantiated outputs such as ∀y(2+y = y+2); on A_xy data the
   strongest early competitors are M_y (0.39 at n = 2, 0 from n = 4: some datum is then outside its outputs) and
   M_y^open (0.26 at n = 2, 0.10 at n = 4); M_y^open proves A_xy too, so the mass on theories proving A_xy is 1.000
   from n = 4. On M_x data the competitor is M_x^open (0.20 at n = 4), which also proves A_xy; once M_x wins, the mass
   on provers of A_xy goes to 0, correctly, since the generator does not prove it. This is "identification is of the
   generator, not of the theory" (brief H2; model Prop 2.5).
2. **Under L1sel the five closed-guard forms are tied exactly**, whichever of the three generated the data: their
   likelihoods are equal on every datum (the argument of Prop X6(b)), so their posterior odds equal
   their prior odds, and once the other theories have died their posterior is their prior, renormalised. Two of the
   five (A_xy, A_yx) prove A_xy; the other three are strictly weaker. So the mass on theories that prove commutativity
   tends to their prior share 0.088, not to 1 (referee M2: 0.044 + 0.044). This is the Bayesian ω-gap of E1 again
   (universal Thm U10), not a tie among equivalents. The open-guard forms are not tied: their bodies may contain w0,
   so their law on closed outputs differs, and they lose (≤ 6·10⁻⁹ at n = 256). With only fully instantiated theorems
   in view, the data cannot even decide whether commutativity is an axiom; only the prior decides, and here it says no
   with probability 0.91.
3. **Two equivalent axioms are not better than one.** A_xy+A_yx and A_xy+S_ab stay below 10⁻⁹: a redundant
   second form is a spare slot.

*Correction.* At n = 1 and 2 the first version reported, on A_xy data, A_xy 0.104 and 0.316 and Mem 0.725 and
0.100. In some seeds Mem(D_n) equalled A_xy (the first data were the cited sentence itself), and the first version
counted that theory twice (§1.8). With the double count removed and the first version's pool, the values are A_xy
0.204 and 0.416, Mem 0.625 and 2·10⁻⁴ (a run made during the revision); with the larger pool of this revision they
are those in the results file (A_xy 0.158 and 0.342). From n = 4 on, no reported number was affected.

---

## 9. E7: the time factor and a steeper simplicity penalty (brief H6; revised, M1, m7)

**Setup** (`code/experiments/e7_prior.py`; results `code/results/e7_prior.md`, `.json`). The E2 data, causal pools
(with trimmed theories and Mem(D_n)) and seeds 0–24; prior π(T) ∝ 2^(−λ·bits(T))·(1+|T|)^(−τ) for
(λ, τ) ∈ {(1, 0), (1, 1), (1, 4), (2, 0), (½, 0)}. Template sizes: T* 77 symbols, frag-complete 287, Q-lumped 22,
bare ?P 1. The first version used seeds 0–4 and the legacy pool.

| (λ, τ) | T* at n = 64 / 512 | unsound mass at n = 8 / 16 / 32 / 512 | seeds accepting a false probe at n = 8 / 16 / 32 | MAP at n = 8: equivalent / weaker / unsound (of 25) |
|---|---|---|---|---|
| (1, 0) | 0.751 / 0.996 | 0.256 / 0.197 / 0.077 / 0.004 | 2 / 3 / 0 | 0 / 18 / 7 |
| (1, 1) | 0.751 / 0.996 | 0.293 / 0.217 / 0.084 / 0.004 | 2 / 3 / 0 | 0 / 16 / 9 |
| (1, 4) | 0.752 / 0.996 | 0.372 / 0.262 / 0.103 / 0.004 | 5 / 4 / 1 | 0 / 16 / 9 |
| (2, 0) | 0.594 / 1.000 | 0.860 / 0.792 / 0.737 / 2·10⁻⁴ | 18 / 19 / 18 | 0 / 3 / 22 |
| (½, 0) | 0.719 / 0.980 | 3·10⁻⁴ / 7·10⁻⁵ / 0.014 / 0.019 | 0 / 0 / 0 | 0 / 25 / 0 |

**Findings** [computed].
1. **The time factor acts as a small extra simplicity penalty, by construction** (referee m7). Deciding axiomhood is
   a linear match per template, so the factor is τ·log₂(1+|T|) bits: 6.3 bits for T*, 1 bit for bare ?P, 8.2 bits
   for frag-complete; at τ = 1 it shifts the log-odds between T* and any hand competitor by at most
   log₂(78/2) ≈ 5.3 bits. So it matters only where theories are within a few bits of each other. From n = 64 on it
   changes nothing visible (T* has 0.751–0.752 at n = 64 and 0.996 at n = 512 for every τ). At n ≤ 32, where
   SeenQ-like theories and the smaller unsound lumps are close, it favours the smaller lumps: the mean unsound mass
   at n = 8 rises from 0.256 (τ = 0) to 0.293 (τ = 1) and 0.372 (τ = 4), the seeds with an unsound MAP from 7 to 9,
   and the largest change, over seeds and n, of the mass of T*, of the theories equivalent to T* or of the unsound
   theories is 0.181 (τ = 1) and 0.563 (τ = 4). The first version reported at most 0.002 and 0.016; its pool had no
   close competitors at small n. Either way this is a consequence of the definition of the factor, not a test of brief
   H6. The informative questions — a time penalty on derivation search, and a penalty against non-template axiom sets
   such as Hänni's collapse construction — are answered in model §6 (a membership-time penalty does not block the
   collapse, model Prop 6.6; derivation size does price the assigner, model Thm 6.7) and are not tested here.
2. **A steeper simplicity penalty trades early soundness for late soundness.** With λ = 2 the MAP at n = 8 is unsound
   in 22 of 25 seeds (λ = 1: 7), the mean unsound mass is 0.860, 0.792, 0.737 at n = 8, 16, 32 (λ = 1: 0.256, 0.197,
   0.077), and a δ = 0.05 verifier accepts a false probe in 18, 19, 18 seeds at n = 8, 16, 32 (λ = 1: 2, 3, 0). In
   return the false spare slot vanishes faster: unsound mass 2·10⁻⁴ at n = 512 against 0.004 at λ = 1. With λ = ½ the
   reverse: unsound MAP at n = 8 in 0 seeds, mean unsound mass 3·10⁻⁴ at n = 8, but the false spare slot keeps 0.019
   at n = 512. Neither setting removes both failure modes. The direction agrees with the referee's re-run with SeenQ
   added to the first version's pool (`referee_code/r3_e7_seenq.out`: unsound MAP at n = 8 in 19 of 25 seeds at λ =
   2).

---

## 10. E8: does a derivation likelihood change the MDL split finding? (new; referee M5)

**Question** (brief, on `AS:sec:many:mdl`): MDL splits a schema by the root of its argument when the instantiation
code misfits the usage, by a margin linear in n; a well-specified code gains at most O(log n) from splitting. Does a
derivation-based likelihood change this? Model Prop 5.6 proves, for tree grammars, that the split with learned
weights is the schema with a learned root law, that it gains at most ln(1/η) nats with probability 1 − η when Q fits
the usage, and that it gains linearly when it does not; pa §2 computes the PA case under its two-part code. E8 tests
the question in this track's chain grammar, in a case where citations are latent.

**Setup** (`code/experiments/e8_split_l1.py`; results `code/results/e8_split_l1.md`, `.json`). φ(t) = (t+0 = t),
ψ(t) = (0+t = t).
* whole = {φ(?t), ψ(?t), φ(?t) → ψ(?t)};
* split = {φ(0), φ(S?z), φ(?a+?b), φ(?a·?b), ψ(?t), φ(?t) → ψ(?t)} (φ split by the root of its argument).

Under L1 (K = 1, c_stop = ½) a citation of φ(t) stops (datum φ(t)) or applies MP with the cited conditional (datum
ψ(t)); ψ(t) can also be cited directly. So the component behind a ψ-datum is latent: it may be ψ(?t), or φ(?t)
followed by MP. Data: the L1 chain from whole with fixed weights (0.5, 0.25, 0.25), bodies drawn from the model's Q
(*wellspec*) or from skewQ (term roots 0: .5, S: .1, +: .2, ·: .2; *skew*). Likelihoods: L1 (the generating chain
with the model's Q) and L0. Seeds 0–9; n = 16 … 4096. About 25% of the data are cited conditionals; 47–50% are
φ-instances and 61–62% ψ-instances (0+0=0 is both). Log₂ Bayes factors split : whole with Dirichlet(½) weights,
without the prior (the prior adds 76.4 bits in favour of whole).

Log₂ Bayes factor split : whole (mean over 10 seeds, range), without the prior:

| n | wellspec, L1 | wellspec, L0 | skew, L1 | skew, L0 |
|---|---|---|---|---|
| 16 | −1.7 (−3.4 to 0.8) | −2.2 (−4.5 to 1.2) | 1.7 (−1.5 to 8.3) | −0.2 (−2.3 to 5.6) |
| 64 | −3.5 (−5.5 to 1.2) | −2.8 (−5.2 to 0.1) | 7.7 (−0.4 to 14.3) | 1.2 (−2.9 to 5.7) |
| 256 | −7.3 (−8.3 to −6.1) | −6.8 (−7.8 to −5.6) | 48.8 (37.9 to 72.6) | 17.4 (6.4 to 34.2) |
| 1024 | −9.8 (−11.6 to −6.5) | −9.3 (−11.4 to −6.2) | 196.5 (165.4 to 232.8) | 72.1 (41.9 to 98.0) |
| 4096 | −13.0 (−14.6 to −11.3) | −12.9 (−14.5 to −11.4) | 817.0 (738.9 to 912.3) | 299.6 (210.7 to 351.5) |

**Findings** [computed; Prop X13].
1. **Exact tie at matched weights.** With the split's weights set to w_φ·q_r (q_r = Q's root probabilities), the
   split and the whole theory give the same L1 probability to every datum: the largest difference of log
   probabilities over the first 2000 data of every run is 1.1·10⁻¹³. This is Prop X13 (model Prop 2.6(b) for the chain
   grammar), with latent citations.
2. **Well-specified usage: the split loses at the Occam rate.** Between n = 256 and 4096 the mean log₂ Bayes factor
   changes by −1.43 bits per doubling of n under L1 and −1.51 under L0. Model Prop 5.6(d) conjectures −((K−1)/2)·log₂
   n, with K the number of root productions (there K is not the chain length); here K = 4, i.e. −1.5 bits per
   doubling. Under L0 this rate is model Prop 5.4(c). The split never gets far ahead (the largest single-seed value in
   the table is 1.2 bits); model Prop 5.6(b) proves a time-uniform bound of this kind for a one-component schema with
   fixed weights, a setting that differs from this one.
3. **Misspecified usage: the split wins linearly, under both likelihoods, and more under L1.** At n = 4096 the split
   is ahead by 817 bits under L1 and 300 under L0 (means); between n = 1024 and 4096 it gains 0.202 bits per datum
   under L1 and 0.074 under L0. Under L1 a ψ-datum can be explained as φ followed by MP, so the roots of the arguments
   of ψ-data also inform the split's root law; under L0 only φ-data do.
4. **Answer to the brief's question, for this model:** a derivation likelihood does not change the MDL finding. The
   split is still decided by whether Q fits the usage; latent citations dilute nothing here and can enlarge the
   linear gain. This agrees with model Prop 5.6 (proved for tree grammars) and pa §2 (computed for PA). What a
   derivation likelihood does change for PA is the *consequences* of a split (a split containing a connective
   derives every induction instance; pa Prop 2.2) — not tested here, because the chain grammar cannot derive the
   premises of an induction axiom.

---

## 11. Questions of the brief: what this track answers, and where the rest is

The referee listed brief questions that the first version left open (referee §3). This track's answer, or the
place where another track answers them:

1. **Does a derivation likelihood change the MDL finding?** Answered for a schema split by the root of a term,
   under the chain derivation likelihood with latent citations (E8, Prop X13): it does not change the direction in
   either regime, and it can enlarge the linear gain under misspecified usage. Proved in general by model Prop 5.6
   (a)–(c) for tree grammars; pa §2 computes it for PA under its code. **Not done here:** PA induction under a
   derivation likelihood, because the chain grammar cannot derive the premises of an induction axiom (§1.6).
2. **Time penalty against Hänni's collapse.** Not tested here. E7 only shows that a membership-time factor barely
   moves mass inside DT°, which holds by construction (§9). Model §6 treats the collapse: a penalty on the time to
   check or generate axioms does not block it (model Prop 6.6); derivation size is what prices the assigner (model
   Thm 6.7, Cor 6.8).
3. **Hänni's "do not contradict" variant.** Not implemented here. Model Prop 1.9(b) shows that it has no size
   principle; pa Def 0.3 defines its noisy form L_ε.
4. **PA and ZF beyond the unlabelled mixture** (Th(ℕ), the IΣₙ chain, Q+Ind against LNP or strong induction,
   Replacement against Collection). Not done here; pa §§1, 4.
5. **The cautious verifier as the δ → 0 limit.** Not done here; model Prop 4.3.
6. **"Statements given without proof should be easily derivable."** Represented here only by the geometric stop of
   the chain (K ≤ 2). Theorem data are studied in pa §3 and universal Prop U14.
7. **Human-written data.** No run here uses a list of textbook theorems. Every misspecified generator perturbs the
   model's own term or motive law, or selects from it. Pa §3, §4.3 and model Example 3.6 are closer to that case.
8. **Search beyond a pool.** Open (§13, problem 1). E2 and E3 show that the reported winners depend on which
   theories are in the pool; this is the main gap for the question "does it robustly pick up the actual axioms?".

---

## 12. Limitations (what the experiments do not show)

* **Pool, not class.** Every posterior is exact over a finite pool (hand alternatives, causal data-derived theories,
  trimmed theories, Mem(D_n)). A theory outside the pool can beat all of them. E2's legacy-against-causal comparison,
  E3(a)'s extended numeral splits and E3(a)'s nested chain C_2 show that the winner, and even the frequency of
  unsound acceptance, can change when the pool changes. Prop X8 is stated so that pool restriction does not break
  soundness; nothing comparable is shown for identification.
* **Chain derivations, K ≤ 2.** MP needs a cited major premise; derived conditionals (e.g. uses of induction
  followed by ∀-elimination) are outside L1. Gen acts on the single parameter w0.
* **One parameter.** Data with two distinct parameters are outside the model. A one-variable template with an
  open-guard metavariable can still state a two-variable law (Prop X12(a)).
* **Fixed Q.** The instantiation grammar is fixed, not learned; misspecification of usage statistics is therefore
  absorbed by extra components (E3, E8). A hierarchical Q is not implemented (pa §2 uses a learned grammar).
* **Bounded derivability.** ⊢_K under-approximates first-order derivability, so "P(T ⊢ s)" columns are lower
  bounds on the mass of theories that prove s (E3(b): fragment theories prove every induction instance by Prop X9
  but cite only some). For E6 the provability of A_xy is taken from Prop X12, not from ⊢_K.
* **Tags of data-derived PA theories** come from Props X9–X11 where they apply and from a budgeted refuter
  otherwise: "unsound" is certain, "unrefuted" is not "sound" (such theories are tagged "unknown").
* **Small runs.** 25 seeds in E2 and E7, 5 in E1, E3, E6, 10 in E5 and E8; n ≤ 4096 (10⁸ for the E5 quadrature,
  2·10⁶ for the fixed-weight check).
* **Wall-clock.** The exact Dirichlet sum is exponential in the number of overlapping components in the worst
  case; above 3 overlapping components and 20000 states it is replaced by bounds (§1.5; where this happened is
  listed in each section and in `checks/check_bounded.out`). It also limits the nested chains of E3(a) to C_2.

---

## 13. Open problems

1. **Beyond a pool.** An exact or certified posterior over all finite sets of DT° templates (for instance a
   sampler whose moves are Min, DTRC merges and trimming, with the exact likelihoods of this package as targets),
   and a condition under which a data-derived pool provably contains the posterior mode.
2. **Tree derivations.** A derivation likelihood in which MP may use a derived major premise (needed for induction
   followed by ∀-elimination), with an exact or certified normaliser; then E2, E3(b) and E8 for PA.
3. **Learning Q.** A hierarchical instantiation grammar (Dirichlet priors on Q's production weights, shared
   across components). Conjecture (pa Prop 2.3 computes the analogue for its code): it removes the linear
   advantage of splits in E3 and E8, leaving Occam terms.
4. **Early unsound lumping.** In E2 the δ = 0.05 verifier accepts a false sentence in 5 of 25 seeds at some
   n ≤ 64 (causal pool). Which cheap addition removes this: negative data (pa §5.4 reports that one refuted
   sentence suffices), a prior that charges metavariables more, or a refutation step before the posterior?
5. **Soundness under misspecification.** A bound for the threshold verifier in terms of how far the data law is
   from the pool (e.g. when every KL-minimiser in the pool is sound), matching E4: misspecification by selection
   was harmless when a clean minimiser was in the pool and fatal when only a decoy was.
6. **The nested spare-slot rate.** Prop X7(b) is a proof sketch; E5(a2) supports −α/2.
7. **Narrow practice in PA.** E3(b) atomic shows that a narrow motive law puts the posterior on a strictly weaker
   theory. For which motive laws does the posterior keep T*'s theorems? (pa Conjecture 4.10 states a version.)

---

## 14. Cross-track consistency

I read the current notes of the other tracks: `../model/notes-final.md`, `../universal/notes-final.md` and
`../pa/notes-final.md`. All three cite this track's `notes.md` (the pre-referee version). I kept the numbering of
Props X1–X9 and of E1–E7, so their citations still point to the same statements; the changed statements are listed
in §14.3.

### 14.1 Aligned in this revision

| item | this track now | was (`notes.md`) | matches |
|---|---|---|---|
| posterior | π_n(T) := π(T \| D_n) | π(T \| D) | model §2, universal §1.5, pa Def 0.5 |
| generator class | C* := {T : P_T = P_{T*}} (X5) | "theories whose marginal law equals that of T*" | model §2, universal §1.6, pa Def 0.5 |
| Dirichlet marginal | M_T = model's P^Dir_T | M_T | model §1.5 |
| consistency statement | X5 through model Thm 2.1, Cor 2.2 (fixed weights) and Thm 5.1(b) (Dirichlet, a.e. w*, instance-union level) | Doob without the a.e. qualification | model §§2, 5.1 (referee M3, m2) |
| soundness | X8(a) = model Thm 4.7 (data from the Dirichlet-averaged law); X8(c) = model Thm 4.8 (fixed weights, shrinking threshold), now proved | X8(c) a sketch; the summary promised a constant threshold at fixed weights | model §4.2, Lemma 4.6 (referee M3) |
| verifier | V_{δ,K}, derivability by chains of ≤ K steps | "threshold verifier" | model's V_{δ,d}, Th_d; pa Def 0.5 |
| likelihood names | L0 = model L0 = universal L0-strict; L1 = a chain calculus (universal C_min/C_open family, a bounded special case of model's tree L1); L1sel = universal L1-sel(S) | same names, relations not stated | model §1.5, universal §1.5 |
| Hänni's variants | not implemented; named S_prove, S_nc as in model §1.5 | not named | model §1.5, universal §1.5, pa Def 0.3 |
| subcriticality of Q | stated as an instance of model Def 1.5 | per-type mean < 1 | model §1.4 |
| Q axiom numbering | dtrc numbering stated explicitly (§2) | implicit | pa and model use other numberings |
| strength of atomic induction | Prop X10, with the Shepherdson reference as in pa | "this argument does not apply" | pa Prop 2.2 |
| cross-references | to the other tracks' `notes-final.md`, with pa's new section numbers (Bayesian DTRC is pa §5, the ∀xφ merge pa §5.5) | to their `notes.md` (pa §4, §4.5) | referee m3; pa §8.1 |

### 14.2 Results that agree across tracks

* **∀xφ from instances.** Universal Thm U2 / Thm B (instance data never favour ∀xφ over its schema; one factor c per
  datum under L1; no movement under a selection-aware likelihood): Prop X6 and E1 reproduce the factor exactly
  (c = 1 − c_stop = ½) and the exact tie under L1sel. Universal §6.6 reproduces E1's L1sel limit 0.484 from this
  track's prior code.
* **Bayesian ω-gap.** Universal Thm U10, model Example 3.2 and pa §5.5: E1 under L1sel (P(⊢∀xφ) → prior share 0.484
  or 0.269) and E6 under L1sel (P(proves A_xy) → prior share of the provers).
* **Spare slots.** Model Prop 5.5 and pa Prop 5.1: X7 and E5 (n^(−α) unused; about n^(−α/2) nested, slope with a
  standard error now).
* **Soundness.** Model Thms 4.7, 4.8 and Example 4.9: X8 and `checks/check_fixed_weight.out` reproduce Example 4.9
  with this track's likelihood code (fixed w*: 0.977 and 1.000 against model's 0.997 and 1.000; averaged over w*:
  0.003 and 0.007 against 0.007 and 0.003; shrinking threshold: 0 in both; 300 runs per cell, every n ≤ 2·10⁶).
* **Splits and the MDL finding.** Model Props 2.6(b), 5.4, 5.6 and pa §2: E2 (frag-complete about 700 bits behind
  T*, falling further behind, under a well-specified Q), E3 (splits win under misspecified usage) and E8 (the same
  under the chain derivation likelihood with latent citations; exact tie at matched weights, Prop X13).
* **Atomic induction is weaker.** Pa Prop 2.2 (F = {=} lies in IOpen, strictly weaker than PA) and pa §4.3 (narrow
  practice can put the posterior on the weaker side): Prop X10 and E3(b) atomic, where the posterior concentrates on
  Q + {T_=, T_<}.
* **Unsound lumps at small n.** Pa §5.4: E2, with the frequency now measured on 25 seeds and a causal pool.
* **Gold, L∞ against L₅.** Model Prop 5.2: E5(b), (c).
* **Posterior on strictly weaker theories when all data are theorems.** Model Example 3.2: E3(a) numerals and
  small, E3(b) atomic.
* **Time factor.** Model §1.3 and Prop 6.6: a membership-time factor is a penalty of a few bits inside DT°, so it
  matters only between near-tied theories (E7; by construction).

### 14.3 Remaining differences

* **E2 numbers cited by pa.** Pa §5.4 and §8.2 cite "experiments E2: Q-lumped ≥ 0.997 in 3 of 5 seeds at n ≤ 32".
  That number belongs to the first version's pool, which used data the learner had not seen and lacked SeenQ
  (referee M1). With the causal pool the δ = 0.05 verifier accepts a false sentence in 2 of seeds 0–4 (at n = 16)
  and in 5 of 25 seeds at some n ≤ 64 (§4). The phenomenon pa describes stands; its frequency is lower.
* **E6 as cited by pa.** Pa §8.2 cites E6 (with model Prop 2.5) for "identification is of the generator" among
  deductively equivalent axiomatisations. After the referee's M2, only A_xy and A_yx (and the new open-guard forms)
  are logically equivalent; S_ab, M_x and M_y are strictly weaker (Prop X12). Identification of the generator among
  A_xy and A_yx still holds under L1 (§8).
* **E3 numerals as cited by universal.** Universal §12.2 cites "N₄ is the MAP ... their pool stops at depth 4". With
  the family extended to N_16 the MAP depth keeps growing with n (N_9–N_10 at n = 512, N_11–N_12 at n = 1024; §5),
  as universal Prop N3(d) finds ("the posterior follows ever deeper splits"). In the first version's pool a memoriser
  was the MAP in one seed at n = 1024; with the extended family Mem has mass at most 1.4·10⁻²⁴⁶ there. Universal Prop
  N3(b) predicts that with a bounded split depth the memorisers win eventually; n = 1024 is too small to see that
  with depth 16.
* **The nested spare-slot slope.** Model §11.2 quotes this track's first-version slopes (−0.224 and −0.290 per
  decade, against −0.25). The revised E5(a2) reports a least-squares slope with a standard error (§7).
* **Verifier constants.** 2^(−bits(T*)) here (any pool containing T*, even data-dependent), δ/π(C*_d) in model,
  δ/π(C*_∀) in universal. The same theorem with different priors and classes.
* **Calculi.** Chains with K ≤ 2 here; Mendelson's K as a tree grammar in model; C_min, C_open and U3 trees in
  universal; natural deduction with a two-part code in pa. Numerical rates are not comparable across tracks; the
  qualitative statements are.
* **Elimination probability.** c = 1 − c_stop = ½ here; c = 0.3 in universal; about 1/10 per step in pa.
* **Priors.** A stochastic template code here (prior share of H_∀ in {H_∀, H_sch}: 0.484 for x+0=x); model's prefix
  code π_λ; 2^(−λ(Σ|A|+1)) in universal (share 0.333); 2^(−β·symbols) in pa (share 0.03–0.04). Prior shares differ
  accordingly (universal §6.6).
* **Instantiation grammar.** A fixed PCFG here, in model and in universal; a learned positional grammar in pa. With
  a learned grammar the sign of the fragmentation drift can change (pa Prop 2.3); model §11.3 and pa §8.3 reconcile
  this with the fixed-Q rate seen in E2.
* **Memorisers.** Only Mem(D_n) (and trimmed theories, which can be memorisers) here; the memoriser class with a
  product prior in universal (U6); memorisation of theorem data in pa §3. Each statement holds in its own setting.
* **Misspecification and unsound theories.** Model §11.3 records that E3 found no mass on unsound theories under
  misspecified usage. That still holds in E3(a) and E3(b), including the atomic generator: there the winner is
  strictly weaker, not unsound. Model Examples 3.4 and 3.6 (unsound escape templates on derived theorems) concern
  other data; the statements are compatible.

---

## 15. Commands, seeds, reproduction

All commands from `code/` (results in `code/results`, logs `*.log`, tables `*.md`, raw data `*.json`; the
pre-referee results are in `code/results/v1/`):

| command | what | seeds | wall time (4 cores, shared machine) |
|---|---|---|---|
| `python3 -m pytest -q tests` | 21 unit tests (`results/pytest.txt`) | fixed in the tests | 18 s |
| `cd experiments && python3 e1_universal.py` | E1 | 0–4 (data); (1000+seed)·1000+b (Min subsets at build point b) | 58 s |
| `cd experiments && python3 e2_pa.py` | E2 (causal and legacy pools) | 0–24; (500+seed)·1000+b (Min subsets); 9000+seed (held-out probes); DTRC refuter seed = seed, tagging refuter seed 0 | 52 s |
| `cd experiments && python3 e3_misspec.py` | E3 | 0–4; (77+seed)·1000+b (Min subsets) | 10 min |
| `cd experiments && python3 e4_ville.py` | E4 | (A) streams 0–399, closed-form MC seed 1; (B, C) 0–99 | 32 min |
| `cd experiments && python3 e5_gold.py` | E5 | 0–9; numpy seed 0 (quadrature draws) | 66 s |
| `cd experiments && python3 e6_equivalent.py` | E6 | 0–4 | 19 s |
| `cd experiments && python3 e7_prior.py` | E7 | 0–24 (E2 data) | 3 min |
| `cd experiments && python3 e8_split_l1.py` | E8 | 0–9 | 30 s |
| `sh run_all.sh` | tests and E1–E8 | as above | about 50 min |
| `cd ../research/tracks/experiments/checks && python3 kt_regret.py` | Prop X8(c) regret factor | none | 5 s |
| `… && python3 check_x6.py` | Prop X6 against the E1 output, prior from the referee's code | reads E1 json | 1 s |
| `… && python3 check_e4_tight.py` | E4(A) pipeline against the closed-form event | streams 0–399 | 1 min |
| `… && python3 check_e1_v1.py` | E1 against the first version's results | reads E1 json | 1 s |
| `… && python3 check_e4_where.py` | E4(B): where the largest invalid-query mass sits; E4(C1): first acceptance against the first mistake | streams 0–99 | 2 min |
| `… && python3 check_bounded.py` | where the Dirichlet bounds replaced the exact sum (E2, E3, E4(B, C), E6) | as the experiments | about 8 min |
| `… && python3 check_fixed_weight.py` | Prop X8 at fixed weights (referee M3) | numpy seed 11; Python seeds 0–4 | 5 min |
| `… && python3 check_models.py` | the counter-models of Props X11, X12 | none | 1 s |
| `… && python3 check_classprob_open.py` | L1sel class probabilities incl. open guards | 5 | 30 s |

Python 3.11, numpy 2.4, scipy 1.17. The dtrc package is read from `../../axiom-schemas/code` (not modified). The
referee's independent implementation `referee_code/ref_core.py` is imported, unmodified, by one unit test and by
`check_x6.py`. The first version's check outputs are kept as `checks/*.v1.out` where a check changed.

---

## 16. Verification log

Two sessions produced this track: the first wrote `notes.md` and the code; the second, after the referee report
`referee.md` (referee scripts in `referee_code/`), revised the code, re-ran every experiment and wrote this file.
Nothing is verified in a proof assistant, and no human has checked the proofs.

### 16.1 Referee issues and their resolution

| issue | the referee's point | resolution | where |
|---|---|---|---|
| **M1** | E2's early unsound lumping is largely a pool artefact: the pool lacked SeenQ(D_n) and its sound stand-ins were built from unseen data; 18/25 → 1/25 seeds at n = 8 with SeenQ | **Accepted.** Pools are now causal (built from D_b, b ≤ n) and contain Trim(T, D_n) for every pool theory, which includes SeenQ; 25 seeds; the first version's pool is reported alongside. Result: a δ = 0.05 verifier accepts a false sentence in 5/25 seeds at some n ≤ 64 (2 at n = 8, 3 at n = 16) against 19/25 with the legacy pool (the referee's 19/25 reproduced; the referee's legacy pool plus SeenQ gave 4/25: the same seeds as here except seed 14, where trimming creates a cheaper unsound lump; §4). The first version's "3 of 5" and its n = 8 MAP list are kept as refuted. E7 re-run on the same pools and 25 seeds | §1.8, §4, §9 |
| **M2** | E6 calls S_ab, M_x, M_y "logically equivalent" to A_xy; they are strictly weaker | **Accepted.** Claim kept as refuted. Prop X12 (proved; model checked numerically): S_ab, M_x, M_y, S_ab^open ⊬ A_xy; A_xy ≡ A_yx ≡ M_x^open ≡ M_y^open. P(proves A_xy) reported: 0.088 under L1sel. Genuinely equivalent forms added (M_x^open, M_y^open); L1 identifies the generator among them. **One remark of the referee is wrong:** "even with open guards the single-parameter convention cannot reach ∀x∀y" fails for M_x and M_y (Prop X12(a)) | §2, §8 |
| **M3** | The summary's soundness promise omits that X8(a) needs data from the Dirichlet-averaged law; at fixed weights a constant threshold fails (R9: 0.86–1.00 against 0.02); X5 lacks the a.e. qualification; X8(c) can be "proved" | **Accepted.** Summary restated (§0). X5 rewritten through model Thm 2.1 (fixed weights) and Thm 5.1(b) (Dirichlet, a.e. w*), with what is not covered. X8(a), (c) stated with their hypotheses; X8(c) proved in full. E2 finding 2 now cites X8(c). The failure reproduced with this track's likelihood code, every n ≤ 2·10⁶: 0.977 and 1.000 (fixed w*), 0.003 and 0.007 (w* from the prior), 0 (shrinking threshold) | §0, §2, `checks/check_fixed_weight.out` |
| **M4** | "Robust at the level of theorems" in PA rests on connective-rich motive laws; with atomic motives the posterior goes to Q + {T_=, T_<}, strictly weaker | **Accepted.** Atomic generator added to E3(b): the posterior concentrates on frag-atoms = Q + {T_=, T_<} (mass 1.000 in 5 of 5 seeds from n = 1024, after T* had 0.988 at n = 64 in 4 seeds); the mass on theories equivalent to T* is 2·10⁻¹⁷⁸ at n = 2048. Prop X10 (proved, given PA ⊢ √2 irrational and Shepherdson 1964): Q + {T_=, T_<} ⊬ σ while T* ⊢ σ. Summary item 3 restated | §2, §5 |
| **M5** | The brief's question "does a derivation likelihood change the MDL finding?" is not addressed; PA runs only under L0 | **Accepted in part.** New E8 and Prop X13: under the chain derivation likelihood with latent citations a root split is an exact reparametrisation (tie to 1.1·10⁻¹³); it loses at the Occam rate when Q fits the usage and wins linearly when it does not, more than under L0. So the finding stands, as model Prop 5.6 proves for tree grammars. PA induction under a derivation likelihood is **not** done here: the chain grammar cannot derive the premises of an induction axiom; this is left to model §5.3 and pa §2 and listed as open problem 2 | §10, §11 |
| m1 | the "brute force" tests share code with `Chain`; check_x6 compares L1 with L1sel from the same code | **Accepted.** New unit test against the referee's independent `ref_core.py` (Q, matcher, L0, prior code, Dirichlet marginal, L1 coefficients); check_x6 now takes the prior from `ref_core` | §2, `tests/test_bai.py`, `checks/check_x6.out` |
| m2 | X5's wording imprecise (identifiability, a.e.) | **Accepted.** X5 rewritten | §2 |
| m3 | cross-references to superseded drafts | **Accepted.** All references now to the other tracks' `notes-final.md` | throughout, §14 |
| m4 | Mem(D_n) is not the best memoriser under L1 | **Accepted.** Claim restricted to L0; the referee's r10 numbers quoted | §1.8 |
| m5 | held-out PA instances occur in the training stream | **Accepted.** Held-out instances now drawn outside the stream | §4, `pa_common.pa_heldout` |
| m6 | E4(B, C) checks 88 of 256 values of n | **Accepted.** Every n is checked now | §6 |
| m7 | E7's time-factor result holds by construction | **Accepted.** Reworded as a consequence of the definition; the informative questions are deferred to model §6 | §9, §11 |
| m8 | L1sel is per-citation rejection, not stream filtering | **Accepted.** Stated in §1.7 | §1.7 |
| m9 | summary item 1 wording (prior share of the provers among tied theories) | **Accepted.** | §0, §3 |
| m10 | E5(c): "a text for L_∞" only if every stage ends | **Accepted.** | §7 |
| m11 | E3(a) gains compared across likelihoods | **Accepted.** Compared within L0 | §5 |
| m12 | E3(a)'s winners sit at the edge of hand-built families (N_4; depth-1 nesting) | **Accepted.** N_m extended to m ≤ 16 and C_2 added: the numeral MAP deepens with n (N_9 or N_10 at n = 512, N_11 or N_12 at n = 1024) and is now interior to the family; on heavy-tailed data the MAP is C_2 (3 seeds) or the skeleton theory {φ(?t), φ(SS?z)} (2 seeds), still at the edge of what can be computed exactly; winners are named as family members | §5 |
| m13 | the derivability oracle's fallback counter is not reported | **Accepted.** Reported for E1, E3(a), E4: 0 in every run | §§3, 5, 6 |
| m14 | small samples behind the E5(a2) slope; no standard error | **Accepted.** 1000 draws per n; slope with a standard error: −0.251 ± 0.002 on n = 10²…10⁸, −0.251 ± 0.003 on 10⁴…10⁸, against −0.25 | §7 |
| §3 of the report | brief questions not addressed | Answered where this track can (E8), otherwise pointed to the track that does | §11 |

### 16.2 Further problems found during the revision

* **Mem(D_n) was double-counted** when it equalled a pool theory (first version, `evaluate`). It affected E6 at
  n = 1 and 2 only (§8). Fixed: the pool theory keeps its name and Mem becomes an alias without mass; unit test
  `test_trim_causal_pool_and_mem_alias`.
* **T* − Q3 is equivalent to T*** (Prop X11(a)); the first version tagged it "not equivalent". Fixed in the tags.
* **Two wrong L0 entries in the first version's E1 table** ("H_∀+open takes 1.000 by n = 8" on allq data; "Mem takes
  1.000 by n = 16" on allq2 data), found by re-reading the per-run results; corrected in §3.
* **Memorisers under other names.** With causal pools, a data-derived ground theory (a Min of D_1) can coincide with
  Mem(D_n). E1 and E3(a) now count such theories as memorisers. A first attempt also counted the hand theory H_∀,
  a single ground sentence that occurs in some data streams, as a memoriser; that misclassification was caught by
  comparing with the first version's results and corrected before the final run.

### 16.3 Checks and their results

All re-run on the final code. Outputs are next to the scripts.

| what | how | result |
|---|---|---|
| unit tests | `python3 -m pytest -q tests` (21 tests: the first version's 18, plus trimming/causal pools/Mem alias, the independent reference, the PA tags) | 21 passed in 18 s (`code/results/pytest.txt`) |
| core probabilities against an independent implementation | `test_against_independent_reference` (Q on 1600 samples; matcher and L0 on 180 sentences × 6 templates; prior code; Dirichlet marginal on 100 cases; L1 coefficients for 3 theories, K = 1, 2) | all within 10⁻⁹ |
| Prop X6 | `checks/check_x6.py`, prior from the referee's code | L1: 1.1·10⁻¹¹ from prior + n; L1sel: 1.0·10⁻¹³ from prior |
| Prop X8 at fixed weights (M3) | `checks/check_fixed_weight.py`: closed form against `evaluate` (4.1·10⁻¹³), R(n, 2) bound for n ≤ 2000 (holds, margin ≥ 2.1 nats), acceptance with every n ≤ 2·10⁶, 300 runs per cell | fixed w*: 0.977, 1.000; w* from the prior: 0.003, 0.007; shrinking threshold: 0, 0 (bound 0.02) |
| Prop X8(c) regret | `checks/kt_regret.py` (first version; code unchanged) | slopes −0.499, −0.998, −1.485 against −(m−1)/2 |
| Props X11, X12 models | `checks/check_models.py` | all six X11 structures as claimed; X12 instances hold up to the size bounds, A_xy fails at (α, β) |
| L1sel class probabilities incl. open guards | `checks/check_classprob_open.py`, 40000 chains per component | largest |z| = 2.17 over 8 components |
| E4(A) pipeline | `checks/check_e4_tight.py` | 400/400 agreement in both settings (2 and 6 wins, exactly the closed-form events), unchanged from the first version |
| E4(B): where the invalid-query mass peaks | `checks/check_e4_where.py` (streams re-run to n = 32) | all 200 maxima reproduced exactly; always on ∀x(x+0=x), at n ≤ 6; carried by H_open, H_∀ (L1) and the one-step generalisation of P; the query list has 8 distinct sentences; in C1 the first acceptance comes at the first mistaken datum in 90 of 100 streams per likelihood and 2–5 data later in the other 10 |
| bounded marginals | `checks/check_bounded.py` (E2 all 25 seeds with both pools, E3(a), E3(b), E4(B, C), E6 seed 0) | E2 (25 seeds, both pools): 14 cases (skel6@32, skel6@64), largest possible mass 0 to double precision; E3(a), E3(b), E4(B, C) seed 0: none; E6: Mem, largest possible mass 0 |
| oracle and likelihood fallbacks | counters in E1, E3(a), E4 results | 0 everywhere |
| E2 against the referee's SeenQ analysis | legacy-pool acceptance counts | 18, 3, 2, 0 seeds at n = 8, 16, 32, 64; 19/25 at some n: identical to `referee_code/r2_e2_seenq.out` |
| E3 extensions against the referee's r6 | numerals MAP, heavy MAP with C_2, atomic motives | numerals: N_9/N_10 at n = 512 and N_11/N_12 at 1024, as in r6 (a); heavy: C_2 in 3 seeds and the skeleton theory {φ(?t), φ(SS?z)} (not in r6's pool) in 2, r6 (b) had C_2 in all 5; atomic: Q + {T_=, T_<} with mass 1.000 at n = 1024 in 5/5 seeds, as in r6 (c) |
| E1 against the first version | `checks/check_e1_v1.py`: posterior masses of the hand theories, per run and n | every generator-mass entry of the §3 table is unchanged at three decimals; for n ≥ 8 the posterior of every hand theory changes by at most 6·10⁻⁴ (L0), 4·10⁻⁷ (L1) and 9·10⁻⁸ (L1sel); at n ≤ 4 by up to 0.76 (L0, open data, bare ?P at n = 4) and 0.50 (L1, allq2 data, n = 2), because the first version's pool held theories built from data not yet seen; P(⊢ ∀xφ) changes by at most 3·10⁻⁸ from n = 16 (`checks/check_e1_v1.out`). The final E1 run differs from the batch run of `run_all.sh` only in the class sums (the H_∀-as-memoriser fix of §16.2); all posteriors are identical |
| reproducibility | `sh run_all.sh` on the final code (tests and E1–E8); then E1, E2 and E3 re-run after the last edits to their reporting code | `run_all.sh` ran to the end on the final code (about 50 min; 21 tests pass). The E5–E8 outputs agree exactly with the runs made while writing. E1, E2 and E3 were then re-run with their final reporting code: all posteriors are identical to the batch run; only derived labels changed (E1 class sums, §16.2; E3 heavy: the skeleton theory {φ(?t), φ(SS?z)} now labelled "same instance set" instead of "other") and E2/E3 gained the code lengths of the over-general induction templates. Afterwards only a comment in `e4_ville.py` changed; the tests were re-run on it (21 pass) |
| numbers quoted in §§3–10 | read from the json files by short scripts while writing | corrected where they differed |

### 16.4 Status of the claims

* **Proved here:** Props X1, X2, X3, X4 (with the computed checks), X6, X7(a), X8(a)–(c), X9, X10 (given two known
  facts), X11, X12, X13; the Kraft inequality of §1.3; the properness of Q (§1.2).
* **Proof sketch:** Prop X7(b).
* **Known, cited:** Prop X5 (model Thm 2.1, Cor 2.2, Thm 5.1(b)); the KT regret rate; PA ⊢ σ; Shepherdson 1964
  (verified only through secondary sources); IΣ_k ⊊ PA; Doob 1949.
* **Computed:** everything in §§3–10.
* **Conjecture:** the open problems of §13.
* **Refuted (kept, with the counterexample):**
  * the first version's E2 frequency of unsound lumping ("3 of 5 seeds") and its n = 8 MAP list (§4);
  * "S_ab, M_x and M_y are logically equivalent to A_xy" (§8; Prop X12(b));
  * the first version's summary promise of soundness at a constant threshold for any well-specified data (§0, X8;
    `checks/check_fixed_weight.out`);
  * "robust at the level of theorems" for PA without qualification (§5; E3(b) atomic, Prop X10);
  * the referee's remark that open guards cannot reach ∀x∀y under the single-parameter convention (§8; Prop X12(a));
  * from the first session: "on E2 data a δ = 0.05 verifier accepts no false probe" (mean over seeds hid seeds 1, 2,
    4); "P(T ⊢ φ(t*) | D) = 1.000 from n = 8 in every E1 configuration" (counterexample: open data under L0).

### 16.5 Not done

* No PA experiment under a derivation likelihood (needs tree derivations; open problem 2).
* No experiment on Hänni's collapse or on the "do not contradict" variant (model §6, Prop 1.9(b)).
* No run on human-written theorem lists.
* No search beyond a finite pool.
* The references marked unverified were not checked against their sources in this session.
