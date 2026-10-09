# Track "universal": Bayesian induction of ∀xφ from instances φ(t) — final record

*Brief item H4. The user's question is quoted in `../../00-brief.md`. This file is the complete, self-contained final
record of the track, written after the referee report `referee.md` (the referee's own code is in `referee_code/`).
It replaces `notes.md`, which is kept unchanged as the pre-referee version. All scripts of this track are in
`checks/`. Each is seeded and writes `checks/<name>.out`. They reuse the parser and the unique first-order matcher
of `../../../../axiom-schemas/code/dtrc/` (read-only).*

**Status markers.**
* **[proved]**: full proof in these notes.
* **[computed: script]**: checked by the named script; the output file has the same name with `.out`.
* **[known: reference]**: a published result; "(unverified)" means recalled and not checked against the source.
* **[proof sketch]**: the argument is given; named steps are not written out.
* **[conjecture]**: believed, not proved.
* **[refuted]**: a claim shown false, kept with the counterexample.

**Labels.** `AS:` refers to `../../../../axiom-schemas/paper/sections/*.tex` by LaTeX label. `IL:` refers to
`../../../../inferential-learning/paper/sections/*.tex`. "Model §k", "pa §k" and "experiments §k" refer to the
parallel tracks' notes (`../model/notes.md`, `../pa/notes.md`, `../experiments/notes.md`). None of them had a
`notes-final.md` when this file was written.

**What changed after the referee.** The referee found no fatal error, three major and eleven minor issues
(`referee.md`). The changes, all detailed in the verification log (§15.1), are these.
* Prop U11(e) ("without a guard the posterior takes the ω-step") is **refuted** as stated. It is replaced by an
  exact analysis of root splits (Lemma N0, Props N1–N3).
* Prop U16 (the sentence-only class) is redone with splits of every depth and with memorisers. The referee's
  replacement conclusion holds only when the split depth is bounded (§9).
* The faithful regime of Thm U10 is restricted to calculi like C_min, and the ⊢_C / ⊢ conflation is removed.
* The Remark after Prop U3 is **refuted**.
* New results: learned weights under the selection-aware likelihood (Prop B2), an unknown selection filter
  (U10(e)), noise mixtures (U2n), length and time penalties (U2t), learned c (U2c), the role of inconsistent
  theories, prior sensitivity, and the relation to the MDL finding (§10).
* Section 12 aligns notation with the other tracks and lists the remaining differences.

---

## 0. Summary

The user's intuition is: "∀xφ is a simple law that implies the data φ(t₁), φ(t₂), …; so the data should raise its
probability, while other hypotheses stay in play." Here is what holds.

1. **Against memorisation and over-general templates the intuition is right.**
   * Every normalised likelihood has a size principle. An over-general template τ loses at an exponential rate of
     at least log(1/P_τ(I)) nats per datum, where I is the set of φ-instances (Thm U4).
   * Memorisers die too, but not always exponentially. Under a geometric numeral law, memorisers with Laplace
     weights keep posterior log-odds ≥ −C·log² n against the schema, almost surely for all large n (Prop U6).
   * An over-specific template such as φ(Sz) *gains* while the data fit it, and dies at the first datum outside
     it (Prop U5).
2. **Against the instance schema σ_φ = φ(z) the intuition fails.** Once templates are allowed, as the user
   proposes, the instance schema is the right competitor. On closed-instance data the posterior odds of {∀xφ}
   against {σ_φ} never move towards ∀xφ in a comparison with fixed weights or single axioms (Thm B):
   * they stay at the prior odds under pure citation with the closure reading (L0-closure), under a selection-aware
     derivation likelihood (L1-sel), and under both of Hänni's variants;
   * they fall by exactly a factor c per datum under the derivation likelihood L1 of the minimal calculus
     {cite, ∀-elim}, where c is the probability of the extra ∀-elimination step. Normalised, the factor is
     c/(1+c) for quantifier-free φ.

   The reason is the size principle again. ∀xφ spends probability on outputs that are never observed: the sentence
   itself, and derivations that need the extra step. The direction survives noise mixtures, any length or time
   penalty that is monotone in the number of steps, and a learned c (Props U2n, U2t, U2c). Two qualifications:
   * With a background axiom and a learned mixture weight, L1-sel odds converge to the prior odds times
     c/(c + w*(1−c))², where w* is the true weight. This exceeds 1 when w* < √c/(1+√c) (Prop B2). It is an effect
     of the weight prior, bounded by 1/c, not evidence that the axioms prove ∀xφ.
   * The exact factor c holds in calculi where only ∀-elimination takes a quantified premise (Prop U3). With
     ∧-rules on quantified formulas the factor exceeds c. The earlier conjecture that it cannot is refuted. The
     direction (factor < 1) held on every computed example.
3. **"All future data are φ-instances" is confirmed.** Its posterior probability tends to 1 almost surely when the
   data come from a hypothesis with positive prior that emits only φ-instances (Thm U8). The rate depends on the
   prior mass of near-universal competitors: 1/n for Laplace's rule with a point mass, only 1/log n for a dyadic
   family. This matches Hutter (2007) on confirming universal hypotheses.
4. **The Bayesian ω-gap.** The posterior identifies the data law, not the theory (Thm U10). Instance data give three
   regimes for P(T ⊢ ∀xφ | D_n):
   * **prior share**: a limit strictly between 0 and 1 (L0-closure, L1-sel, Hänni's variants; also with learned
     weights, Prop B2). With an unknown selection filter the limit is a prior share over pairs (theory, filter)
     (U10(e));
   * **limit 0** for derivation likelihoods in calculi like C_min, when the generator emits only instances;
   * **misspecified**: when the data are a filtered sample and the likelihood ignores the filter, or in any calculus
     richer than C_min (where no hypothesis emits only instances). The limit is then set by the best-fitting
     generators in the class. These can be ever more specific (§7, §9). Whenever such splits are in the class, the
     pure-logic limit was 0 in every computation. Over Q it depends on the class.

   Hänni's trichotomy (true, false, independent) keeps positive mass on all three in the first regime and collapses
   onto "independent" in the second.
5. **Open instances or quantified data close the gap.**
   * One datum φ(p) at a fresh parameter makes P(T ⊢ ∀xφ | D) = 1 exactly, by Gen (Prop U11(a)).
   * Closed data teach a closedness guard when the class has one (U11(d)).
   * **Without a guard, the earlier claim that the posterior takes the ω-step is refuted** under the normalised
     derivation likelihood. The root splits R_k = {φ(0), …, φ(S^{k−1}0), φ(S^k z)} lose exactly q^k times what
     φ(z) loses per datum (Prop N2), so ever deeper splits take the mass. In c8 the best depth is log₂ n minus a
     slowly growing term. The splits do not prove ∀xφ in pure logic, and do over Q (Prop N3). Under L1-sel the
     ω-step is taken.
   * Quantified data refute every theory that cannot derive them (Prop U12(a)). If all theories derive them but at
     different cost, the log-odds move linearly, at a rate close to f_q·L·log(1/c) for quantified-data frequency f_q
     and extra derivation length L (U12(b), computed with equal priors).
6. **Truth is a separate question from derivability.** A credence about truth that meets the Gaifman condition
   tends to believe ∀xφ (probability → 1) given all true closed instances, provided P(∀xφ) > 0. That condition
   holds μ-almost surely exactly when M₀ ≼ M μ-almost surely, where M₀ is the term-generated part of M (Prop U15,
   via `AS:prop:univ:tv`). So the step is truth-safe for ℕ. It is unsafe whenever the credence gives weight to
   structures that are not elementary extensions of their term-generated part, such as ℝ, V, or the non-standard
   models of Q of `AS:ex:univ:q`.
7. **Without templates (sentences only).**
   * Under L0-closure the posterior concentrates on ∀xφ (U16(a)).
   * Under L1-norm, the split Split_k = {φ(0), …, φ(S^{k−1}0), ∀yφ(S^k y)} loses exactly q^k·log((1+c)/c) nats per
     datum at its best weights, so deeper splits win. In pure logic P(T ⊢ ∀xφ | D_n) → 0.
   * Over Q, every finite theory that keeps positive likelihood forever proves ∀xφ (Lemma S1). Whether the limit
     is 1 is a race between the split family and the memoriser family. With unbounded split depth the splits win
     (computed up to n = 10¹² under four prior variants), so the limit is 1 numerically. With depth ≤ 4 the
     memorisers win and the limit is 0. The earlier "= 1 over Q" came from a three-hypothesis class, and the
     referee's "→ 0 over Q" from a bounded-depth class.
8. **The MDL finding** (`AS:sec:many:mdl`: "MDL tracks the statistics of usage, not the logical boundaries of
   schemas"). A derivation likelihood does not remove it. An unmodelled selection creates it: root splits win
   linearly. Modelling the selection removes it again (§10).

**Brief conjectures (H4), verdicts.**

| conjecture | verdict |
|---|---|
| (a) mass leaves memorisation and over-general templates exponentially fast | **Over-general: proved** (U4). **Memorisation: refuted in general.** Laplace-weighted memorisers under geometric numerals keep ≥ exp(−O(log² n)) (U6). The rate is exponential under a Galton–Watson law (computed). |
| (b) instance data do not move H_∀ : H_sch towards H_∀; constant under L0, ×c per datum under L1 | **proved** for fixed weights and single axioms (U1–U3, Thm B), with exact factors. Qualified: learned weights under L1-sel (Prop B2, bounded factor in either direction); ∧-detours (factor > c; direction < 1 computed, not proved) |
| (c) P(next datum is an instance) → 1 and P(all future data are instances) → 1 | **proved** (U8); rates computed |
| (d) yet P(T ⊢ ∀xφ \| D) need not → 1 (Bayesian ω-gap) | **proved** (U10), three regimes |
| (e) open instances plus Gen: H_open ⊢ ∀xφ; when does P(T ⊢ ∀xφ \| D) → 1? | **proved** (U11(a)) for parameter data. Without a guard on closed data: **refuted** under L1-norm (N3(a)); holds under L1-sel (N3(c), proof sketch for learned weights; computed) |
| (f) quantified data shift mass to theories proving ∀xφ | **proved** (refutation, U12(a)); **computed** with equal priors (gradual case, U12(b)) |

---

## 1. Setup

### 1.1 Language and instances

* **Language.** L_A has 0, S, +, ·, < and =. Closed terms have no variables and no parameters. Parameters p, w₀, …
  are free names. A datum containing a parameter is read under universal closure (closure-normal form,
  `AS:sec:setting:syntax`).
* **φ.** φ(x) has exactly one free variable x, and x occurs in φ. It is quantifier-free in the examples:
  0+x=x, x+0=x, x·0=0, Sx≠0, x<Sx. Where stated, φ may contain quantifiers, e.g. φ(x) = ∀y(x+y=y+x).
* **Instance sets.** I_c(φ) = {φ(t) : t closed} is the set of closed instances. I_o(φ) also allows t to contain
  parameters.
* **Instance schema.** σ_φ := φ[z/x], where z is a 0-ary term metavariable (λ-convention: values contain no bound
  variables).

### 1.2 Term laws

One law Q instantiates every template metavariable and supplies the term of every ∀-elimination. This is a modelling
choice. With different laws the odds in §4 acquire a factor comparing the two laws, which is a statistical
difference, not a logical one.

* **Numerals:** Q_c(S^j 0) = (1−q)q^j. The default is q = 1/2.
* **Galton–Watson (GW):** each node independently picks its root: 0 with probability .4, S .3, + .2, · .1. So
  Q(t) = ∏_nodes p(root). The mean offspring is 0.9 < 1.
* **Open setting:** Q_open = ρ·[w₀] + (1−ρ)·Q_c, where w₀ is a bare parameter. One parameter name suffices for
  one-variable φ under closure.

In both root-generated laws Q(f(t₁…t_r)) = p_f·∏Q(t_i).

### 1.3 Hypotheses

A **theory** is a finite list of axioms (first-order templates; a sentence is a template without metavariables) with
citation weights summing to 1. Weights are fixed, or carry a Dirichlet(α) prior ("learned weights"). The older
checks c2–c7 use α = 1 (Laplace); the revision checks c8–c10 use α = ½, the default of the other tracks, with α = 1
as a robustness variant.

| name | axioms |
|---|---|
| H_∀ | {∀xφ} |
| H_sch | {σ_φ}, z ranging over closed terms. In the open setting this needs the guard closed(z) (law Q_c) |
| H_open | {σ_φ}, z ranging over all terms (law Q_open). With Gen it proves ∀xφ |
| H_both | {∀xφ, σ_φ} (weight θ on ∀xφ) |
| memorisers M_F | the finite set F of closed instances; uniform weights (M^u) or Dirichlet weights (M^l for Laplace) |
| over-specific | e.g. σ_φ[z := Sz] (the first-order lgg of instances at successor numerals) |
| over-general | each template obtained from σ_φ by replacing one subterm or subformula by a fresh metavariable (this generalises a constant, or un-identifies an occurrence of z), and the formula metavariable ?A |
| root split | {σ_φ[z := f(z₁…z_r)] : f a root symbol of Q}, with fixed weights p_f or learned weights |
| R_k (k ≥ 1) | {φ(0), …, φ(S^{k−1}0), φ(S^k z)}, z unguarded (open setting); weights (v₀, …, v_{k−1}, u) |
| Split_k (k ≥ 1) | {φ(0), …, φ(S^{k−1}0), ∀yφ(S^k y)}: sentences only. Split_1 = {φ(0), ∀yφ(Sy)} |
| Both0 | {φ(0), ∀xφ} |
| background combinations | B ⊕_w A: add axiom A with weight w to B, scaling B's weights by 1−w |

**Memoriser prior.** F is drawn by including each sentence s of a named universe 𝒰 independently with probability
r_s = 2^{−λ(|s|+1)}, where |s| is the dtrc symbol count. This needs Σ_{s∈𝒰} r_s < ∞ (so Z₀ := ∏_{s∈𝒰}(1−r_s) > 0).
* For 𝒰 = the numeral instances φ(S^k 0): |s| = |σ_φ| + occ·k, with occ the number of occurrences of z. The sum
  converges for every λ > 0.
* For 𝒰 = all closed instances (used with the GW law in c3): the number of closed terms of size m grows like
  (1+2√2)^m. So the sum converges if λ·occ > log₂(1+2√2) ≈ 1.94 and diverges if λ·occ < 1.94. For 0+x=x
  (occ = 2) at λ = 1 it converges (0.031, `referee_code/r6_prior_mass.out`). For Sx≠0 (occ = 1) at λ = 1 it
  diverges; that case is not used.
* Over all closed sentences the sum diverges at λ = 1 (referee m1). No check uses that universe.

### 1.4 Calculi

* **C_min = {cite, ∀-elim}.** Derivations are chains. At each node, with probability 1−c, cite: choose an axiom by
  weight and draw its metavariables from Q. With probability c, apply ∀-elimination to a recursively generated
  premise, with a term t ~ Q. The node fails if the premise does not begin with ∀.
* **C_open(c, g).** Adds Gen with probability g. Gen abstracts the parameter w₀ of the premise and fails if there is
  none. Cite then has probability K := 1−c−g.
* **U3 calculi.** Cite, ∀-elim, and further rules whose premises and conclusions are quantifier-free (equality
  rules; propositional rules and MP restricted to quantifier-free formulas). Each node picks its rule independently
  with fixed probabilities. Derivations are trees.
* **C_∧.** Cite (p_c), ∀-elim (c), ∧-introduction (a) and ∧-elimination (e, side left or right with probability ½),
  the ∧-rules applying to all formulas. Used only in §2.3.

### 1.5 Likelihoods

* **L0-strict (pure citation).** P_T(d) = Σ_A w_A·P_A(d), where P_A(d) = ∏_z Q(θ(z)) if d = Aθ, and 0 otherwise.
  Matching is unique for first-order templates. A sentence yields only itself.
* **L0-closure.** As L0-strict, but a universal sentence ∀x̄χ is cited through its instances χ(t̄).
* **L1(c)** (sub-probability). P_T(d) is the probability that the derivation grammar succeeds with conclusion d.
  Z_T := Σ_d P_T(d) is its total mass.
* **L1-norm.** P_T/Z_T.
* **L1-sel(S)** (selection-aware). P_T(d | S) = P_T(d)/P_T(S) for d ∈ S, where S is a set known to contain every
  datum, e.g. "closed quantifier-free sentences" or "closed φ-instances". This is the `L1sel` of experiments §1.7.
* **L1-max (Viterbi, two-part).** The probability of the best single derivation, max_π P(π). With prefix-free costs
  this is the two-part code. (Called "L2" in `notes.md`. Renamed because model §1.5 uses L2 for bounded depth.)
  Bounded size (only derivations of size ≤ B count) is a further variant.
* **S_prove** ("proves the givens"; Hänni, `prior/hanni-solomonoff-axiom-induction.md`). The score is
  1[T is consistent and T ⊢ d for all d ∈ D]. This is model §1.5's S_prove (formerly "Hä1" here).
* **S_nc,β** ("does not contradict", graded). The score is 1[T ∪ D is consistent]·β^{#{d ∈ D : T ⊢ d}}, with β ≥ 1.
  β = 1 is model's S_nc. For β > 1 it equals, up to the data-independent factor β^n, model's graded score S_g with
  g ≡ 1 on provable data and g(∞) = 1/β (formerly "Hä2" here).
* **Noisy versions.** P^η_T := (1−η)P_T + η·N, for a fixed noise law N with full support and η ∈ (0,1) (Hänni's
  "allow some mistakes").

The posterior is π_n(T) := π(T | D_n) ∝ π(T)·∏_{i≤n} P_T(d_i), with the scores in place of P_T for S_prove and
S_nc,β. Stochastic statements assume i.i.d. data from a normalised law P_{T*}, or from a law P* named explicitly.

### 1.6 Prior and notation

* **Prior.** Statements about countable classes (U7, U8, U10) use any proper prior π, for example the prefix code
  π_λ of model Def 1.3 (proper by Kraft, model Lemma 1.4). The checks use finite classes, or the explicitly summable
  families of c8 and c9. There the prior is 2^{−λ(Σ_A |A| + one per axiom)}, renormalised, with λ = 1 bit by default
  (a guard costs one symbol). Under this convention |∀x(0+x=x)| = 6 and |0+z=z| = 5, so the prior odds H_∀ : H_sch
  are ½. How much this choice matters is shown in §6.6.
  The rule 2^{−λ|T|} with λ = 1 is not a proper prior over all theories (referee m1). That is why it is used only on
  finite or summable families.
* **Generator class.** C* := {T : P_T = P_{T*}} (model §2). (Called E(T*) in `notes.md`.)
* **Trichotomy** (model §7). For a sentence s:
  * Bel(s) := π_n(T ⊢ s);
  * Dis(s) := π_n(T ⊢ ¬s);
  * Ind(s) := π_n(T ⊬ s and T ⊬ ¬s);
  * Inc := π_n(T inconsistent).

  Bel + Dis + Ind = 1 + Inc. Hänni's "true, false, independent" is (Bel, Dis, Ind) on consistent theories.
  P(T ⊢ ∀xφ | D_n) means Bel(∀xφ) and counts inconsistent theories as provers. Inc is reported separately (§6.2).

---

## 2. The derivation grammar: exact likelihoods

### 2.1 Factorisation and the odds on instance data

**Prop U1 (factorisation) [proved; computed: c1_grammar].** This holds in C_min for any φ with one free variable,
quantifiers allowed. Write P_X for the law of the one-axiom theory {X}.

* For every sentence d ≠ ∀xφ: P_{∀xφ}(d) = c·P_{σ_φ}(d).
* P_{∀xφ}(∀xφ) = 1−c and P_{σ_φ}(∀xφ) = 0.
* Z_{∀xφ} = (1−c) + c·Z_{σ_φ}, and Z_{σ_φ} = (1−c)·Σ_{k=0}^{m} c^k, where m is the number of leading ∀ of φ.
* For a background B and weight w:
  * P_{B⊕∀xφ}(d) = (1−w)P_B(d) + w·c·P_{σ_φ}(d);
  * P_{B⊕σ_φ}(d) = (1−w)P_B(d) + w·P_{σ_φ}(d).
* For k variables, ∀x₁…∀x_kφ against the k-ary schema gives a factor c^k on each full instance.

*Proof.* A derivation from {∀xφ} is a chain: cite ∀xφ, then k ≥ 0 eliminations with terms t₁, …, t_k. Its
probability is c^k(1−c)∏Q(t_j). With k = 0 it yields ∀xφ. For k ≥ 1, map it to the σ_φ-chain "cite σ_φ with
z := t₁, then the same k−1 eliminations". That chain has probability c^{k−1}(1−c)Q(t₁)∏_{j≥2}Q(t_j), which is the
first probability divided by c.

The two conclusions coincide: elim(∀xφ, t₁) = φ(t₁) = σ_φ[z := t₁], since t₁ has no bound variables, and the remaining
steps are the same. Well-typedness is preserved. The map is a bijection onto all σ_φ-chains. No σ_φ-chain yields
∀xφ, because every conclusion has fewer logical symbols.

Summing over chains with conclusion d gives the first claim. For theories, cite factorises over axioms, so
P_T = Σ_A w_A·P_A. Z counts the well-typed chains: the leading ∀ of φ are rigid, so exactly m+1 chain lengths succeed
from σ_φ. ∎

*Check.* c1 computes the identity on every output of 200 000 sampled derivations, for φ ∈ {0+x=x, Sx≠0,
∀y(x+y=y+x)} under the numeral and GW laws (between 21 and 63 763 distinct outputs each). The maximum deviation of
log P_∀ − log P_σ − log c is 5·10⁻¹⁴. The exact engine agrees with an independent procedural sampler (max |z| = 2.35
over 96 comparisons). The referee reproduced this with independent code (`r1_cmin.out`: deviation 1.6·10⁻¹⁵).

**Thm U2 (odds on instance data) [proved; computed: c2_odds, asserted along every sampled path].** Let D consist of n
closed φ-instances, and let O_n := π_n(H_∀)/π_n(H_sch). Then:

| likelihood | O_n / O_0 |
|---|---|
| L0-strict | 0 for n ≥ 1 (∀xφ cites only itself) |
| L0-closure | 1 |
| L1(c), sub-probability | c^n |
| L1-norm | (c·Z_σ/((1−c)+c·Z_σ))^n; for quantifier-free φ, (c/(1+c))^n |
| L1-sel(S), any S ∌ ∀xφ containing the data | 1 |
| L1-max (Viterbi) | c^n |
| S_prove, S_nc,β | 1 |
| background B, L1 | ∏_i r(d_i), with r(d) ∈ [c, 1]; r(d) = c whenever P_B(d) = 0 |

*Proof.* Every row is read off U1.
* **L0-strict:** P_{H_∀}(φ(t)) = 0.
* **L0-closure:** the two laws are identical by definition.
* **L1-norm:** divide by the normalisers.
* **L1-sel:** P_∀(d | S) = c·P_σ(d)/(c·P_σ(S)) = P_σ(d | S).
* **L1-max:** the bijection maps best chains to best chains, scaling each by c.
* **S_prove, S_nc,β:** both theories prove every instance (one ∀-elim; one citation) and are consistent with true
  data. So their indicators and β-factors coincide.
* **Background:** r(d) = ((1−w)P_B(d) + w·c·P_σ(d)) / ((1−w)P_B(d) + w·P_σ(d)). ∎

The referee's independent code reproduces every row on 20 streams of 200 instances (`r1_cmin.out`, deviations
≤ 7·10⁻¹³). Experiments Prop X6 and E1 reproduce the L1 and L1-sel rows in a different grammar (their c is 1 − c_stop).

### 2.2 Robustness of the direction

**Prop U2n (noise mixtures) [proved; computed: c10_misc (h)].** Fix a noise law N and η ∈ (0,1). Let d be any
sentence other than ∀xφ.
* Under L1 with noise, ((1−η)c·P_σ(d) + ηN(d)) / ((1−η)P_σ(d) + ηN(d)) ∈ [c, 1].
* Under L1-norm with noise (noise mixed into the normalised laws), the ratio is ≤ 1.
* Under L1-sel with noise mixed in after selection, the two noisy laws are identical.
* A false datum no longer refutes a theory: its likelihood is at least ηN(d) > 0.

*Proof.* By U1, P_∀(d) = c·P_σ(d). The first claim is the background row with P_B := N. For the second, the
component laws satisfy c·P_σ(d)/Z_∀ ≤ P_σ(d)/Z_σ because Z_∀ = (1−c) + cZ_σ ≥ Z_σ (as Z_σ ≤ 1). Mixing both with the
same ηN preserves the inequality. The third is U2's L1-sel row. ∎

c10 (h) checks the first two inequalities at 200 000 random parameter points.

**Prop U2t (length and time penalties) [proved].** In C_min, weight each chain by f(ℓ)·w_A·∏_j Q(t_j), where ℓ is
the number of eliminations and f is non-increasing. L1 is f(ℓ) = (1−c)c^ℓ. A Levin-style time penalty such as
f(ℓ) ∝ 1/(ℓ+1)² is another case. Then for every d ≠ ∀xφ, P^f_∀(d) ≤ sup_ℓ [f(ℓ+1)/f(ℓ)]·P^f_σ(d) ≤ P^f_σ(d).

*Proof.* The bijection of U1 maps a ∀xφ-chain with ℓ+1 eliminations and terms t₁, …, t_{ℓ+1} to the σ_φ-chain with
ℓ eliminations that cites σ_φ at t₁. The term product is the same. Only f(ℓ+1) becomes f(ℓ). ∎

So no penalty that is monotone in derivation length or time reverses Thm B. This agrees with model §6: a penalty
on checking axiom membership does not bite inside DT°, and only derivation length prices computation.

**Prop U2c (learned c) [proved].** Under L1-norm with quantifier-free φ, H_sch's normalised law is Q whatever c is,
and H_∀'s per-datum factor is c/(1+c) < ½ for every c ∈ (0,1). So whatever prior is put on c, O_n/O_0 ≤ 2^{−n}.

*Proof.* c/(1+c) is increasing in c and equals ½ at c = 1. Integrating a bound that holds for every c preserves it.
∎ (This answers the referee's question 7.)

### 2.3 Beyond C_min

**Prop U3 (simulation inequality) [proved].** Take a U3 calculus (§1.4) and quantifier-free φ. For every
quantifier-free d:

  P_{B⊕∀xφ}(d) − P⁰(d) ≤ c·(P_{B⊕σ_φ}(d) − P⁰(d)) ≤ P_{B⊕σ_φ}(d) − P⁰(d),

where P⁰(d) is the probability of derivations of d that never cite the added axiom. P⁰ is the same in both theories.

*Proof.* Take a derivation of a quantifier-free d from B⊕∀xφ, and a leaf citing ∀xφ. The leaf is not the root. Its
parent accepts a premise that is not quantifier-free, and only ∀-elim does. So every such leaf sits in a pattern
"∀-elim(cite ∀xφ, t)" with conclusion φ(t).

Replace each such pattern by the leaf "cite σ_φ, z := t". The pattern has probability p_elim·Q(t)·p_cite·w; the
replacement has p_cite·w·Q(t). So each replacement divides the probability by c. The map is injective: every σ_φ-leaf
in the image came from a pattern, since B⊕∀xφ contains no σ_φ. Conclusions are preserved.

So derivations with m ≥ 1 patterns contribute Σ c^m·P(f(π)) ≤ c·Σ_{π′ citing σ_φ} P(π′). Derivations with m = 0 never
cite the added axiom and have the same probability in both theories. ∎

**Remark after U3: detours through ∧ on quantified formulas [conjecture in notes.md; now refuted].** `notes.md`
conjectured that detours such as ∧I(∀xφ, ψ) followed by ∧E "cannot" make U3's inequality fail. They can.

*Counterexample (proof sketch; computed: referee r2_detour, c10_misc (a)).* Take C_∧ (§1.4), B = ∅ (so P⁰ = 0) and
φ = 0+x=x.
* *Spine decomposition.* Follow the root's ∧E premises upwards. A formula G produced at a base node (cite or
  ∀-elim) can reach the root through a balanced word of ∧I ("push G into a conjunction with a free partner") and ∧E
  ("pop the side containing G"). Each push–pop pair has weight a·Z_T·e, where Z_T is the success probability: the
  partner is any successful derivation, and the two orientations of ∧I cancel the ½ of ∧E. So
  P_T(G) = base_T(G)·D(e·a·Z_T), with D(x) = Σ_j Cat_j x^j = (1 − √(1−4x))/(2x), the Catalan generating function.
  The ansatz P(G) = base(G)·D satisfies the recursion P(G) = base(G) + e·Σ_W P(G∧W) exactly when D = 1 + xD².
* *The two theories.*
  * H_∀: base(∀xφ) = p_c, and base(φ(t)) = c·P(∀xφ)·Q(t). So P_∀(φ(t)) = c·p_c·D_∀²·Q(t).
  * H_sch: base(φ(t)) = p_c·Q(t), and ∀-elim never applies. So P_σ(φ(t)) = p_c·D_σ·Q(t).
  * Z_T is the least fixed point of Z = D(eaZ)·(p_c + c·P_U + aZ²), with P_U = p_c·D for H_∀ and 0 for H_sch.
* *The ratio.* The map for H_∀ dominates the map for H_sch, so Z_∀ ≥ Z_σ and D_∀ ≥ D_σ ≥ 1, with D_∀ > 1 when
  a, e > 0. Hence R := P_∀(φ(t))/P_σ(φ(t)) = c·D_∀²/D_σ ≥ c·D_∀ > c.
* *Numbers.* At (p_c, c, a, e) = (0.35, 0.15, 0.25, 0.25) the fixed point gives R = 0.15553. My own sampler gives
  R = 0.15528 ± 0.00067 over 10⁶ derivations per theory, 7.9 standard errors above c = 0.15 (c10 (a)). The referee's
  independent run gives 0.1562 ± 0.0005 (13σ). On the referee's 9139-point grid R > c everywhere, but R ≤ 0.925 < 1
  and the normalised ratio ≤ 0.48 (`r2_detour.out`).

So the factor c of Thm B and of Summary item 2 is specific to C_min and the U3 calculi. The weaker statement, that
detours never reverse the direction (R < 1), survives on this family and is open in general (§13, item 1).

### 2.4 General φ

* **Unchanged for quantified or many-variable φ:** U1 and U2 in C_min (their proofs do not use quantifier-freeness),
  U4 and U5 (any first-order templates, formula sort included).
* **k free variables:** the factor per full instance is c^k.
* **U3** is proved only for quantifier-free φ.
* **U10(d) with quantified φ:** see §6.1. It is proved for the pair {H_∀, H_sch} and only sketched in general.
* **Truth questions.** For <-free Σ₁ formulas φ (bounded quantifiers written with x ≤ y defined as ∃z(z+x=y)),
  every true closed instance is provable in Q [known: Σ₁-completeness of Q; Hájek and Pudlák 1993, location not
  verified; `AS:app-universal.tex` cites it for <-free Δ₀]. So under S_prove, Q stays admissible for every true
  <-free Σ₁ φ, and it does not prove ∀xφ in general (e.g. 0+x=x, `AS:ex:univ:q`).
  With < primitive and Q as in `AS:setting.tex` (Q1–Q7, no axiom for <), this fails [proved]. ℕ with < interpreted
  as ∅ is a model of Q, and 0 < S0 fails in it. So Q ⊬ 0<S0, a true closed instance of x<Sx
  (`referee_code/r5_models.out` (2)).
* **The examples of `AS:ex:univ:fail`** (ℝ, V, PA + ¬Con(PA)) are the quantified and Δ₀ cases of U15.

---

## 3. Memorisation, over-general and over-specific templates: brief item (a)

**Thm U4 (size principle) [proved; computed: c2_odds].** Let the data be i.i.d. from P* with P*(I) = 1. Let P′ be a
sub-probability with P′(I) = p < 1.

1. KL(P* ‖ P′) ≥ log(1/p) > 0.
2. (1/n)·log(P′(D_n)/P*(D_n)) → −KL(P* ‖ P′) almost surely. The limit is −∞ if the KL divergence is infinite.
3. E[P′(D_n)/P*(D_n)] = P′(supp P*)^n ≤ p^n. For a family {τ} with sup_τ P_τ(I) ≤ p̄ it follows that
   E[π_n({τ})/π_n(T*)] ≤ (π({τ})/π(T*))·p̄^n.
4. Let τ be a first-order template strictly more general than σ_φ, with metavariables i.i.d. from Q (terms) and F
   (formulas). Then P_τ(I) ≤ p̄ := max(max_f Q(root = f), max_g F(root = g)).

*Proof.*
1. By the log-sum inequality, Σ_{d∈I} P*(d)·log(P*(d)/P′(d)) ≥ P*(I)·log(P*(I)/P′(I)) = log(1/p).
2. Put X_i = log(P′(d_i)/P*(d_i)). Since x⁺ ≤ e^x, E[X⁺] ≤ E[e^X] = P′(supp P*) ≤ 1 < ∞. So E[X] = −KL is well defined
   in [−∞, 0), and the strong law of large numbers (which allows E[X] = −∞ when E[X⁺] < ∞) gives the limit.
3. Tonelli: E[∏_i P′(d_i)/P*(d_i)] = (Σ_{d: P*(d)>0} P′(d))^n.
4. Write σ_φ = τρ, where ρ is not a renaming. Then either (a) some metavariable u of τ has ρ(u) with a rigid root f,
   or (b) ρ sends two distinct metavariables u ≠ u′ to the same thing. If neither held, ρ would map metavariables
   injectively to metavariables, i.e. be a renaming.

   If τθ ∈ inst(σ_φ), then τθ = σ_φθ′ = τρθ′. Every metavariable of τ occurs in τ, and first-order matching is unique,
   so θ = ρθ′ on the metavariables of τ.
   * In case (a), θ(u) has root f. This has probability Q(root = f), or F(root = f) for formula sort.
   * In case (b), θ(u) = θ(u′). This has probability Σ_t Q(t)² ≤ max_t Q(t) ≤ max_f Q(root = f). ∎

Model Lemma 1.8 gives the exact form behind (1): KL(P* ‖ P′) = KL(P* ‖ P̃′) + log(1/p), with P̃′ := P′(· | supp P*).

*Computed (c2).* Bound and rate for numerals with q = 1/2, exact sums:

| φ | τ | P_τ(I) | −log P_τ(I) | KL (nats) |
|---|---|---|---|---|
| 0+x=x | ?y+?z=?z | 1/2 | 0.693 | 0.693 (equality: the ratio is constant) |
| 0+x=x | 0+?y=?z | 1/3 | 1.099 | 1.386 = H(Q) |
| x<Sx | ?z<?y | 1/6 | 1.792 | 2.079 |

c2 checks the bound in 38 cases: 13 by exact sums (numerals, term metavariables only) and 25 by Monte Carlo with
2·10⁵ samples (the GW law, and formula metavariables). It holds in all of them, within two standard errors. A template
with P_τ(I) = 0 under the term law (e.g. ?y=?z on numeral data) is refuted by the first datum. The referee checked
(4) on 130 random strict generalisations under 3 laws with an own matcher (`r7_misc.out` (1)).

**Prop U5 (over-specific templates) [proved; computed: c2_odds].** Let τ = σ_φ[z := f(z₁…z_r)] and let Q be
root-generated. Then:

* P_τ(φ(t))/P_σ(φ(t)) = 1/p_f if root(t) = f, and 0 otherwise.
* The odds τ : σ_φ equal O_0·p_f^{−n} while all n data have root f. This event has probability p_f^n. Afterwards the
  odds are 0.
* The odds form a martingale with mean O_0.

So the size principle favours the most specific template consistent with the data. The posterior settles on σ_φ
only once the data contain an anchor, i.e. Plotkin's events (R)+(D). The probability that some single-root
over-specific template is still alive is Σ_f p_f^n. This is exactly the failure probability P_N of
`AS:thm:univ:rates`(a).

*Proof.* Q(f(t̄)) = p_f∏Q(t_i), and τ matches φ(t) iff root(t) = f, with matcher z_i := t_i. ∎

*Computed.* Numerals, q = 1/2: the gain per datum is 0.693 = log 2 and the survival probability is 0.503. GW: 1.204
= log(1/.3) and 0.300. In c2, for 0+x=x with numerals, the over-specific mass is 0.110 at n = 1 and 0.067 at n = 5
(L0-closure), and 0 at n = 10.

**Prop U6 (memorisers) [(i), (ii), (ii′) proved; (iii) conjecture; computed: c3_memo].**

*Setting.* The prior on F is the product-Bernoulli prior of §1.3 over a universe 𝒰 with Σ_{s∈𝒰} r_s < ∞, so
Z₀ := ∏_{s∈𝒰}(1−r_s) > 0. Let S_n be the set of distinct data and m_n = |S_n|. The memoriser class has total prior μ.

* **(i) Bracket.** Σ_{F⊇S_n} π(F)·P^u_F(D_n) ∈ [Z₀·∏_{s∈S_n} r_s·m_n^{−n}, ∏_{s∈S_n} r_s·m_n^{−n}]. The same bracket
  holds for Dirichlet(α) weights, with the Dirichlet-multinomial DirMult_α(D_n) in place of m^{−n}. For α = 1 this is
  Lap(D_n) = Γ(m)∏_sΓ(n_s+1)/Γ(n+m).
* **(ii) Uniform weights.** If Q has infinite support and finite entropy, the log-odds of M^u against H_sch, divided
  by n, tend to −∞ almost surely: superexponential decay.
* **(ii′) Laplace weights.** Deterministically,
  log-odds(M^l : H_sch) ≥ log(μZ₀/π_sch) + Σ_{s∈S_n} log r_s − (m_n − 1)·log(n + m_n − 1).
  Under geometric numerals, with 𝒰 the numeral instances and r_s = 2^{−λ(|s|+1)}, this is ≥ −C·log² n **almost
  surely for all sufficiently large n**, for an explicit C. **So the memoriser mass is not exponentially small.**
* **(iii) [conjecture]** Under geometric numerals the log-odds are −Θ(log² n) almost surely.

*Proof.*
* **(i)** π(F) = Z₀∏_{s∈F} r_s/(1−r_s). Write F = S ∪ G.
  * The term G = ∅ gives the lower bound, using r_s/(1−r_s) ≥ r_s.
  * For the upper bound, Σ_{F⊇S} π(F) = ∏_{s∈S} r_s, and each likelihood is at most the one at F = S: |F|^{−n} ≤ m^{−n}
    for uniform weights, and adding j unused components multiplies DirMult_α by
    Γ((m+j)α)Γ(n+mα)/(Γ(mα)Γ(n+(m+j)α)) ≤ 1.
* **(ii)** The log-odds are ≤ const − n·log m_n + Σ_i log(1/Q(t_i)). The last sum is n·(H(Q) + o(1)) almost surely,
  and m_n → ∞ almost surely.
* **(ii′)** Lap(D_n) = [1/multinom(n; n_s)]·[1/C(n+m−1, m−1)]. The multinomial coefficient is ≤ 1/ML(D_n), because the
  type class has probability ≤ 1 under the maximum-likelihood distribution. Also C(n+m−1, m−1) ≤ (n+m−1)^{m−1}. And
  ML(D_n) ≥ ∏Q(t_i) = P_sch(D_n). This gives the deterministic bound.

  For numerals, s = φ(S^k0) has |s| = |σ_φ| + occ·k. Let K_n = max k among the data. Then
  P(K_n ≥ 3·log_{1/q} n) ≤ n·q^{3 log_{1/q} n} = n^{−2}, which is summable. By Borel–Cantelli, almost surely
  K_n < 3·log_{1/q} n for all large n. On that event m_n ≤ K_n + 1 and Σ_{s∈S_n}(|s|+1) = O(K_n²) = O(log² n), so the
  bound is ≥ −C·log² n with C depending on λ, |σ_φ|, occ and q. ∎ (`notes.md` stated the bound with probability
  ≥ 1 − 1/n at threshold 2·log_{1/q} n; referee m11. c10 (g) checks P(K_n ≥ 3 log_{1/q} n) ≤ n^{−2} exactly for
  q = 1/2 and 0.9, n ≤ 10⁶.)

*Computed (c3; 0+x=x; 10 seeds; D_l = log-odds of Laplace memorisers against H_sch, up to an additive constant in
[log Z₀, 0]).* The universes are the numeral instances (numeral laws) and all closed instances of 0+x=x (GW law),
both summable at λ = 1 (§1.3).

| law | behaviour of D_l | interpretation |
|---|---|---|
| numerals, q = 1/2 | D_l/ln²n ≈ −2.8 at n = 10³ and −2.5 at n = 10⁵; D_l/n → 0 | quasi-polynomial decay |
| numerals, q = 0.9 | D_l/ln²n from −35 (n = 10²) to −53 (n = 10⁵) | pre-asymptotic; same order |
| GW | m_n ≈ 2.2·10⁴ at n = 10⁵; D_l/n ≈ −4.0 throughout | **exponential** |

So the decay rate is governed by the growth of the number of distinct data, roughly
exp(−Θ(Σ_{s∈S_n}|s| + m_n·log n)). Uniform-weight memorisers decay superexponentially, e.g. D_u = −1.4·10⁵ at
n = 10⁵ for q = 1/2. The referee checked the bracket (i) on 200 random small universes (`r7_misc.out` (2)).

**Verdict on brief (a).** It is proved for over-general templates (U4). It is refuted for memorisation in general
(counterexample U6(ii′)). Over-specific templates behave differently again: they gain until the first anchor
datum. Sections 7 and 9 show a fourth kind of competitor, hybrids of memorisation and a shifted law (R_k, Split_k),
which can beat both memorisers and the true axioms when the likelihood is misspecified.

---

## 4. Instance data never favour ∀xφ over its schema: brief item (b)

**Thm B [proved].** Let D be a finite sequence of sentences, none equal to ∀xφ. Then the posterior odds of the
∀-version against the schema version are at most the prior odds in each of these cases.

* **(B1) C_min, single axioms.** π_n(H_∀)/π_n(H_sch) ≤ π(H_∀)/π(H_sch) for closed-instance data, under L0-closure,
  L1, L1-norm, L1-sel, L1-max, S_prove and S_nc,β (any φ with one free variable). Equality holds under L0-closure,
  L1-sel, S_prove and S_nc,β. Under L1 the odds are multiplied by exactly c^n.
* **(B2) C_min with a background.** π_n(B⊕∀xφ)/π_n(B⊕σ_φ) ≤ the prior odds, for any background B and any data
  other than ∀xφ (B's outputs allowed), under L1 and L1-norm. This holds with a fixed weight w, and also with a
  learned weight that has the same prior in both theories. Under L0-closure with the same weight, or the same
  weight prior, the odds equal the prior odds.
* **(B3) U3 calculi** (quantifier-free φ): under unnormalised L1, L1-max, S_prove and S_nc,β.

*Proof.* (B1) is U2. (B3) is U3, together with U2's argument for the scores.

For (B2), fix w. Under L1, P_{B⊕∀,w}(d) = (1−w)P_B(d) + wcP_σ(d) ≤ (1−w)P_B(d) + wP_σ(d) = P_{B⊕σ,w}(d) for every
d ≠ ∀xφ, by U1. Under L1-norm, the normalisers satisfy
Z_{B⊕∀,w} = (1−w)Z_B + w((1−c) + cZ_σ) ≥ (1−w)Z_B + wZ_σ = Z_{B⊕σ,w},
because (1−c)(1−Z_σ) ≥ 0. So the normalised inequality holds datum by datum too. A pointwise inequality between
likelihoods at every w survives integration against a common weight prior. Under L0-closure the two laws coincide
at every w. ∎

**Not covered, or false.**
* **L1-sel with a background and learned weights.** Here the odds can move towards ∀xφ, by a bounded factor
  (Prop B2 below). With fixed weights and a background under L1-sel, the two laws have different effective weights,
  and whichever matches the data wins. Neither effect is logical.
* **∧-detours on quantified formulas.** The factor exceeds c (§2.3); whether the direction can reverse is open.
* **Normalised likelihoods in the U3 calculi.** The normalisers were not compared.
* **Normalised bounded-size likelihoods.** The bijection of U1 maps chains of size s to size s−1, so the
  unnormalised bounded likelihood still satisfies P_∀(d) ≤ c·P_σ(d) on instances.

**Prop B2 (learned weights under L1-sel) [proved; computed: c10_misc (b)].**

*Setting.* C_min. The background is B = {σ_ψ}, with ψ quantifier-free and inst(σ_ψ) ∩ inst(σ_φ) = ∅ (e.g. ψ = Sx≠0,
φ = 0+x=x). Compare T_∀ := B ⊕_w ∀xφ with T_σ := B ⊕_w σ_φ. Both have a uniform prior on w and the same prior mass.
The likelihood is L1-sel with S = closed quantifier-free sentences. Data are i.i.d. from the mixture
(1−w*)·Q_ψ + w*·Q_φ of closed instances of the two schemas, w* ∈ (0,1).

*Claim.* The Bayes factor T_∀ : T_σ converges almost surely to h(w*), where h(v) := c/(c + v(1−c))². h decreases
from 1/c at v = 0 to c at v = 1, and h(w*) > 1 iff w* < √c/(1+√c).

*Proof.*
* *The likelihoods.* Under L1-sel, T_σ gives a φ-instance probability w·Q(t) and a ψ-instance probability
  (1−w)·Q(t). T_∀ gives w_e·Q(t) and (1−w_e)·Q(t), with the effective weight w_e = wc/(1−w+wc), because ∀xφ reaches S
  only after one elimination. With n_φ and n_ψ instances of each kind, the likelihoods are K_D·w_e^{n_φ}(1−w_e)^{n_ψ}
  and K_D·w^{n_φ}(1−w)^{n_ψ}, with the same K_D.
* *Change of variables.* w ↦ w_e is a C¹ bijection of [0,1] with inverse w = v/(c + v(1−c)), and dw/dv = h(v).
  Hence BF = ∫₀¹ v^{n_φ}(1−v)^{n_ψ} h(v) dv / ∫₀¹ v^{n_φ}(1−v)^{n_ψ} dv = E[h(V)], with V ~ Beta(n_φ+1, n_ψ+1).
* *Limit.* n_φ/n → w* almost surely, and the Beta(n_φ+1, n_ψ+1) law has mean → w* and variance ≤ 1/(4(n+3)). So
  V → w* in distribution. h is continuous and bounded on [0,1], so E[h(V)] → h(w*). ∎

*Computed (c10 (b), c = 0.3, 10 seeds).* At n = 10⁵ the mean Bayes factor is 2.1918, 1.1537, 0.7102 and 0.4056 for
w* = 0.1, 0.3, 0.5 and 0.8, against h(w*) = 2.1914, 1.1534, 0.7101 and 0.4056. The threshold is √c/(1+√c) = 0.354.

*Reading.* With learned weights the effective weight prior differs between the two theories, because the ∀-version
reaches the data only after an elimination. When the true weight is small, the ∀-version's induced prior on the
effective weight is denser there, and it gains a bounded factor. This is the second kind of non-logical difference
named below. It does not depend on n, and it vanishes for single-axiom theories.

**Total prover mass with a spare slot [proved; computed: c5_open_quant Part C].** Take the class
{H_sch, H_∀, H_both}, with a uniform prior on H_both's weight θ, L1-norm, quantifier-free φ, and instance data. Then
H_both's likelihood relative to H_sch is I_n = ∫₀¹ ((1−θ(1−c))/(1+θc))^n dθ, and 1/(n+1) ≤ I_n ≤ 1/(n(1−c)).

*Proof.* Under L1-norm, H_both(θ) gives φ(t) probability (1−θ+θc)·Q(t)/(1+θc) (U1, with Z = (1−c)(1+θc)). For the
lower bound, (1−θ+θc) ≥ (1−θ)(1+θc), because the difference is θ²c ≥ 0; so I_n ≥ ∫(1−θ)^n = 1/(n+1). For the
upper bound, the integrand is ≤ (1−θ(1−c))^n ≤ e^{−nθ(1−c)}. ∎

So P(T ⊢ ∀xφ | D_n) → 0 like Θ(1/n), not exponentially: H_both is a spare slot (brief H5; model Prop 5.5).
Computed: n·I_n = 0.958, 0.996 and 1.000 at n = 10, 10² and 10⁵.

*Computed (c2; 0+x=x; numerals q = 1/2; mean posterior over 50 seeds).* The class is H_∀, H_sch, four
over-general templates, the over-specific φ(Sz), and the root split (fixed and Laplace weights).

| likelihood | hypothesis | n = 0 | 1 | 5 | 20 | 200 |
|---|---|---|---|---|---|---|
| L0-closure (= L1-sel) | H_∀ | 0.021 | 0.194 | 0.303 | 0.332 | 0.332 |
| | H_sch | 0.042 | 0.387 | 0.605 | 0.665 | 0.665 |
| | over-general | 0.926 | 0.307 | 0.022 | 0.000 | 0.000 |
| L1 | H_∀ | 0.021 | 0.067 | 0.001 | 0.000 | 0.000 |
| | H_sch | 0.042 | 0.448 | 0.891 | 0.996 | 0.996 |
| L1-norm | H_∀ | 0.021 | 0.053 | 0.000 | 0.000 | 0.000 |

* Under L0-closure the ratio H_∀ : H_sch stays at the prior ratio ½ (6 symbols against 5).
* Under L1, H_sch saturates at 0.996 rather than 1. The remaining 0.004 is the fixed-weight root split, which has
  exactly the law of H_sch (model Prop 2.6(b): root splits with weights p_f are exact ties under L0 and L1).
* At n = 0 the over-general group holds 0.926, of which 0.674 is the inconsistent ?A. Section 6.2 reports Inc.
* The other four formulas and the GW law behave the same way (`checks/c2_odds.out`).

*Where could the other direction come from?* Only from non-logical differences:
* a ∀-elimination term law different from the schema's instantiation law;
* a prior that favours the sentence, directly, or through the induced prior on effective weights (Prop B2).

None of these is evidence that the axioms prove ∀xφ.

---

## 5. Predictive confirmation: brief item (c)

**Lemma U7 (Doob's consistency theorem, countable class) [proved; known: Doob 1949].** Let H be countable, and let
each P_T be a probability on a countable data space. Data are i.i.d. For every T* with π(T*) > 0, P_{T*}-almost surely:

  π_n(T) → π(T)·1[T ∈ C*]/π(C*) for every T, and the convergence is in total variation.

*Proof.*
* **Setup.** Work on the joint space of (θ, D_∞), with measure Π = Σ_T π(T)·δ_T ⊗ P_T^∞. Then
  π_n(T) = Π(θ = T | 𝔽_n). By Lévy's upward theorem it converges almost surely to q_T := Π(θ = T | 𝔽_∞),
  simultaneously for the countably many T.
* **Identification.** Let g(D_∞) be the limit of the empirical frequencies. By the strong law of large numbers over
  countably many points, g = P_T almost surely under P_T^∞. So the event {P_θ = g} has Π-probability 1.

  Put E_g := {T : P_T = g}. It is 𝔽_∞-measurable, so Π(θ ∈ E_g | 𝔽_∞) = Σ_{T∈E_g} q_T. This variable is ≤ 1 and has
  mean Π(θ ∈ E_g) = 1, hence equals 1 almost surely.
* **Shape of the limit.** Within E_g all likelihoods coincide at every n, so π_n(T)/π_n(T′) = π(T)/π(T′). Hence
  q_T = π(T)/π(E_g) on E_g and 0 elsewhere.
* **Conclusion.** Pointwise convergence of probability mass functions to a mass function gives total-variation
  convergence (Scheffé). An event of Π-probability 1 has P_T^∞-probability 1 for each T with π(T) > 0, and E_g = C*
  on that slice. ∎

Model Thm 2.1 and Cor 2.2 prove the same statement independently.

**Thm U8 (predictive confirmation) [proved; computed: c4_confirm].** Let M(· | D_n) = Σ_T π_n(T)·P_T(·) be the
posterior predictive. Let G := {T : P_T(I) = 1}, and suppose T* ∈ G.

1. Σ_{n≥0} E_{T*}[1 − M(I | D_n)] ≤ ln(1/π(T*)). Hence P(next datum ∈ I | D_n) → 1 almost surely, and the misses
   are summable.
2. P(all future data ∈ I | D_n) = π_n(G). This tends to 1 almost surely.
3. E_{T*}[1 − π_n(G)] ≤ min(1, Σ_{T∉G} (π(T)/π(T*))·P_T(supp P_{T*})^n).
4. Suppose every T ∈ G has law P̂ (so P̂(I) = 1), and every T ∉ G has the form (1−ε_T)·P̂ + ε_T·N with N(I) = 0. Then,
   for every sequence of instances,
   1 − π_n(G) = Σ_{T∉G} π(T)(1−ε_T)^n / (π(G) + Σ_{T∉G} π(T)(1−ε_T)^n).

*Proof.*
1. By the chain rule, Σ_{n<N} E[KL(P* ‖ M(· | D_n))] = E[ln(P*(D_N)/M(D_N))] ≤ ln(1/π(T*)), since M ≥ π(T*)·P*.
   Push forward to the indicator of I: KL ≥ ln(1/M(I | D_n)) ≥ 1 − M(I | D_n).
2. P_T(I)^∞ is 1 for T ∈ G and 0 otherwise. Then U7 applies, since C* ⊆ G.
3. Bound 1 − π_n(G) by min(1, Σ_{T∉G} π_n(T)/π_n(T*)), and use U4(3) for each T.
4. The instance factors cancel. ∎

*Computed (c4).*
* **Bayes–Laplace with a point mass.** Take π₀ at ε = 0 and Uniform(0,1) on ε. Then
  P(all future instances | n) = π₀/(π₀ + (1−π₀)/(n+1)), checked by quadrature. So 1 − P ≈ (1−π₀)/(π₀n). Without the
  point mass (π₀ = 0), P(all future) = 0 for every n, while P(next m all instances | n) = (n+1)/(n+m+1).
* **A dyadic family.** Take ε_j = 2^{−j} with prior ∝ 1/(j(j+1)), and π₀ = 0.01. W_n·log₂n rises from 0.80 (n = 10)
  to 0.98 (n = 10⁵⁰), with limit 1 − π₀ = 0.99, where W_n is the prior-weighted survival of the noisy hypotheses.
  And 1 − P(all future | n) = W_n/(π₀ + W_n) is still 0.37 at n = 10⁵⁰. Confirmation is very slow when the prior
  has much mass on near-universal hypotheses.
* **Item 1.** Σ_n(1 − M(I | D_n)) = 4.22 (Laplace) and 2.70 (dyadic), both ≤ ln(1/π₀) = 4.61. The referee reproduced
  4.2199 (`r7_misc.out` (4)).
* **Not monotone.** With prior ½ on σ_φ and ½ on φ(Sz), the datum φ(S0) *lowers* the posterior of σ_φ to 1/3. This is
  a Nicod-type non-monotonicity; compare Leike and Hutter (2015). Confirmation is asymptotic, not stepwise.

**Comparison with Hutter (2007) [known: Hutter 2007; verification partial, see §14].**
* **What Hutter shows.** The Bayes–Laplace model gives the universal hypothesis zero prior, hence zero posterior.
  Its "observable" form H″ = {all future observations black} also gets P(H″ | 1^n) = lim_k (n+1)/(n+k+1) = 0. The
  universal prior has no zero-p(oste)rior problem and confirms universal hypotheses.
* **What is shared.** U8(2) is the analogue for a countable class of i.i.d. laws: G is our H″. The mechanism is the
  same: positive prior mass on hypotheses that emit only instances.
* **What is ours.**
  * Rates that depend on the near-universal competitors (U8(3), (4)).
  * A sharp distinction: G is not the event "the axioms prove ∀xφ". G contains H_sch, which generates exactly the
    instances and does not prove ∀xφ. Confirming H″ is not confirming the sentence ∀xφ as an axiom or a theorem (§6).

---

## 6. The Bayesian ω-gap, and truth versus derivability: brief item (d)

### 6.1 The general theorem

**Thm U10 (Bayesian ω-gap).** Let H be countable with a proper prior π > 0 on H. Let
Prov := {T ∈ H : T ⊢ ∀xφ} (first-order provability; inconsistent theories are included, see §6.2). Let the data be
i.i.d. from P_{T*}, T* ∈ H, unless stated otherwise.

* **(a) General limit [proved].** P(T ⊢ ∀xφ | D_n) → π(Prov ∩ C*)/π(C*) almost surely. The same holds with ⊢_C for
  any calculus C, and for each of Bel, Dis, Ind and Inc.
* **(b) Prior-share regime [proved].** If C* contains a prover and a non-prover, the limit lies strictly between
  0 and 1. Instances:
  * (b1) H_∀ and H_sch under L0-closure or L1-sel (U2);
  * (b2) B⊕∀xφ and B⊕σ_φ under L0-closure, with the same fixed weight or the same weight prior (identical laws);
  * (b3) with a background and learned weights under L1-sel, the two marginal laws are not identical, so U7 does not
    apply. Prop B2 shows directly that the Bayes factor tends to h(w*) ∈ [c, 1/c]. So in a class of these two
    theories the limit is again strictly between 0 and 1.

  Hänni's trichotomy limit (Bel, Dis, Ind) is the vector of prior shares within C*. All three are positive when C*
  also contains a consistent theory that refutes ∀xφ. Under L1-sel an example is {σ_φ, ∃x(0+x≠x)} with S excluding
  the second sentence (its filtered law is Q for every weight). It is consistent: take ℕ ∪ {a} with 0+a ≠ a. Under
  L0-closure such a theory spends mass on ∃x¬φ and drops out. S_prove and S_nc,β are not i.i.d. data models; they
  are treated in §6.2 by continuity of measure, with the same conclusion.
* **(c) Faithful regime.** Call a likelihood **faithful for a calculus C** if supp P_T = Thm_C(T) ∩ X for every T ∈ H,
  where X is the data space.
  * **(c1) [proved]** If ∀xφ ∈ X, then P(T ⊢_C ∀xφ | D_n) → 1[T* ⊢_C ∀xφ].
  * **(c2) [proved]** If moreover C is sound and every axiom instance of every T ∈ H lies in X, then every T ∈ C* has
    the same first-order theorems as T*, and P(T ⊢ ∀xφ | D_n) → 1[T* ⊢ ∀xφ].
  * **(c3) [proved] Instance-only generators exist only in calculi like C_min.** In C_min, and in C_open with a
    guard, L1-norm with a full-support Q is faithful, and supp P_{H_sch} = I_c(φ) for quantifier-free φ. For
    T* = H_sch the limit is therefore 0, and the trichotomy collapses onto "independent". But suppose C has a rule
    that, applied with positive probability to an instance, yields a non-instance: ∧I or ∨I, symmetry of =, →I, or
    MP with cited logical axioms. Then every T with P_T(I_c) > 0 has P_T(X ∖ I_c) > 0. Then no hypothesis is
    instance-only. Instance-only data are a selected sample, misspecified for every hypothesis. (c1) and (c2) do not
    apply, and the limit is that of the best-fitting generators of the class (model Thm 3.1 for finite classes).
    Sections 7 and 9 show that this limit depends on which very specific generators the class contains.
* **(d) Filtered data.** Let the true generator be T° = H_∀, which proves ∀xφ, and let the analyst see only its
  outputs in S = closed φ-instances.
  * **(d1) [proved]** For quantifier-free φ in C_min, the filtered law P_{T°}(· | S) equals the law P̃_sch of H_sch
    exactly (U1). With the unconditional likelihood L1-norm, P(T ⊢ ∀xφ | D_n) → 0, by (c3) with T* := H_sch. The
    posterior confidently concludes "the axioms do not prove ∀xφ", from data that were filtered. With the
    selection-aware L1-sel the limit is the prior share, as in (b).
  * **(d2) [proved for the pair {H_∀, H_sch}; proof sketch in general]** For quantified φ, the eliminations of σ_φ
    leave S, so the filtered law P̃ := P_σ(· | S) is not the law of any hypothesis, and U7 does not apply. In the
    pair, H_sch is the KL-minimiser:
    KL(P̃ ‖ P_σ/Z_σ) = log(Z_σ/P_σ(S)) < log(Z_∀/(c·P_σ(S))) = KL(P̃ ‖ P_∀/Z_∀),
    because c·Z_σ < (1−c) + c·Z_σ = Z_∀. So the posterior concentrates on H_sch (U4(2), or model Thm 3.1), and the
    limit is 0. In larger classes the limit is the KL-minimiser's, which was not determined in general.
* **(e) Unknown selection filter [proved; computed: c10_misc (e)].** Let F be a countable family of filters (sets
  of sentences), with a prior ν independent of π. A pair (T, S) has the law P_{T,S}(d) := P_T(d)·1[d∈S]/P_T(S). Let the
  data be i.i.d. from some P_{T°,S°} with π(T°)ν(S°) > 0. Then U7 applies to the countable class of pairs. In
  particular, take H = {H_∀, H_sch}, C_min, quantifier-free φ, and closed-instance data with law Q. Let
  F₀ := {S ∈ F : S ⊇ I_c} and F₁ := {S ∈ F₀ : ∀xφ ∉ S}. Then
  P(T ⊢ ∀xφ | D_n) → π(H_∀)ν(F₁) / (π(H_∀)ν(F₁) + π(H_sch)ν(F₀)).

  So the ω-gap reappears as a prior share over theories and filters. If F contains only "all sentences" (no
  selection modelled), F₁ = ∅ and the limit is 0, which is L1-norm. If every filter excludes ∀xφ, the limit is the
  L1-sel prior share.

*Proof.*
* (a) is U7, summed over Prov (or over the theories counted by Bel, Dis, Ind, Inc).
* (b): both theories lie in C*, and one is in Prov and the other is not. (b3) is Prop B2.
* (c1): T ∈ C* implies supp P_T = supp P_{T*}, hence Thm_C(T) ∩ X = Thm_C(T*) ∩ X.
* (c2): for T ∈ C*, each axiom instance of T lies in Thm_C(T) ∩ X = Thm_C(T*) ∩ X, which consists of first-order
  consequences of T* (soundness). Symmetrically for T*. So T and T* prove each other's axioms.
  *Example (referee m3).* C_min with T* = {∀x(φ ∧ ψ)}. Here T* ⊬_{C_min} ∀xφ, so (c1) gives 0, while (c2) gives
  1[T* ⊢ ∀xφ] = 1. Both are correct; they answer different questions. `notes.md` wrote the limit of
  P(T ⊢ ∀xφ) as 1[T* ⊢_C ∀xφ], which conflated them.
* (c3): in C_min with quantifier-free φ, a σ_φ-chain can only cite (elimination fails), so H_sch emits exactly
  I_c(φ). For the second part, apply the rule to a derivation of an instance; both have positive probability, and the
  conclusion is not an instance.
* (d1): P_∀(· | S) = c·P_σ(· ∩ S)/(c·P_σ(S)) = P_σ(· | S) = P̃_σ, because supp P_σ = I_c ⊆ S. Then apply (c3).
* (d2): on S, P̃ = P_σ/P_σ(S) and P_∀ = c·P_σ (U1, since ∀xφ ∉ S), so both log-ratios are constant on S.
* (e): pairs form a countable class of i.i.d. laws, so U7 applies. With data law Q on I_c:
  * (H_sch, S) has law Q iff S ⊇ I_c, since H_sch emits only instances. If some instance lies outside S, it has
    probability 0 under the pair and positive probability under the truth.
  * (H_∀, S) with ∀xφ ∉ S and S ⊇ I_c has law Q by U2's L1-sel row.
  * (H_∀, S) with ∀xφ ∈ S gives ∀xφ positive probability, which the truth does not.

  Summing prior masses over C* gives the limit. ∎

*Computed (c5 Part A).* φ = 0+x=x, C_open with c = .3, g = .2, ρ = .1. Data are closed instances; this is also H_∀'s
output filtered to closed instances. Class: {H_∀, H_open, H_sch (guarded), H_both}. Prior share of the provers: 0.750.

| likelihood | P(T ⊢ ∀xφ \| D_n): n = 0 | n = 10 | n = 50 | n = 100 |
|---|---|---|---|---|
| L1-norm | 0.750 | 0.364 | 0.004 | 0.000 |
| L1-sel | 0.750 | 0.750 | 0.750 | 0.750 |

*Computed (c10 (e)).* {H_∀, H_sch} × {all sentences, closed quantifier-free sentences, closed φ-instances,
closed φ-instances with S-rooted argument}, π = (⅓, ⅔), ν uniform. P(T ⊢ ∀xφ | D_n) = 0.333, 0.284, 0.252, 0.250,
0.250 at n = 0, 1, 5, 10, 1000 (mean of 50 seeds). The predicted limit is 0.2500.

**Answer to model §3's question.** Model Example 3.2 shows that under L0 the posterior concentrates on theories
weaker than the human's ∀x(0+x=x) when the human states only closed instances. It asks whether this persists under L1.
* If the human's generator is H_∀ and all its outputs are reported (∀xφ itself included), the data are
  well-specified under L1-norm and P(T ⊢ ∀xφ | D_n) → 1 (c5 Part A, stream "output of H_∀": 1.000 from n = 5, with
  H_∀ itself at 0.993 at n = 10; experiments E1, generator "all": 1.000).
* If only closed instances are reported, the gap persists under L1-norm (d1) and becomes a prior share under L1-sel
  (b1) or under an unknown filter (e).

### 6.2 Hänni's two variants, and inconsistent theories

These use `AS:ex:univ:q`: a model of Q on ℕ ∪ {a, b}, standard on ℕ, with 0+a = b. So Q proves every closed instance
0+t=t, while Q, Q + ∀x(0+x=x) and Q + ∃x(0+x≠x) are all consistent with every closed instance.

* **S_prove ("proves the givens") [proved].** The admissible set Adm_n = {T consistent, T ⊢ D_n} decreases to
  Adm_∞ = {T consistent : T ⊢ I_c(φ)}. Under a full-support Q every closed instance eventually appears almost surely.
  By continuity of measure, π(· | Adm_n) → π(· | Adm_∞) in total variation.

  Adm_∞ contains Q (independent), Q + ∀x(0+x=x) (true), Q + ∃x(0+x≠x) (false), H_sch (independent) and H_∀ (true). It
  also contains every consistent over-general template that proves the instances (e.g. 0+z₁=z₂ alone, which has a
  one-element model). In the trichotomy, "true" means T ⊢ ∀xφ and "false" means T ⊢ ¬∀xφ. So all three values keep
  positive mass, and over-generalisations are never penalised. **S_prove has no size principle** (as model Prop
  1.9(b) shows in general). Inc = 0 by definition.
* **S_nc,β ("does not contradict").** Theories that prove all the data share the factor β^n, so their mutual odds
  stay at the prior odds. The trichotomy again keeps positive mass on true, false and independent. Inc = 0 by
  definition.
* **Inconsistent theories under the generative likelihoods [computed: c10_misc (d)].** c2's class contains
  inconsistent templates: ?A (an instance is ¬(0=0)) and, for φ = Sx≠0, also ~?B, ~?y=0 and ~S?z=?y (instances
  ¬(0=0), ¬(S0=S0)). They prove both ∀xφ and its negation, so they inflate Bel and Dis alike (referee m9). They waste
  mass on non-instances, so the size principle removes them:

| φ, law | Inc at n = 0 | n = 1 | n = 2 | n = 5 | n = 10 |
|---|---|---|---|---|---|
| 0+x=x, numerals (L0-closure, L1-norm, L1-sel) | 0.674 | 0.000 | 0.000 | 0.000 | 0.000 |
| Sx≠0, numerals, L0-closure / L1-norm | 0.931 | 0.585 / 0.635 | 0.319 / 0.390 | 0.056 / 0.081 | 0.002 / 0.003 |
| x<Sx, numerals, L0-closure | 0.627 | 0.080 | 0.004 | 0.000 | 0.000 |
| 0+x=x, GW, L0-closure | 0.674 | 0.042 | 0.001 | 0.000 | 0.000 |
| Sx≠0, GW, L0-closure | 0.931 | 0.454 | 0.191 | 0.010 | 0.000 |

  Under numerals ?A cannot produce an instance of 0+x=x at all (no + in numeral terms), so it dies at the first
  datum. The consistent part Bel_cons(∀xφ) = mass(H_∀) behaves as in §4: it tends to the prior share (≈ 0.332)
  under L0-closure and L1-sel and to 0 under L1-norm. The thresholded verifier at small n should therefore use
  Bel_cons, or exclude inconsistent theories from the class: at n = 0 in c2's class, Bel(∀xφ) ≈ 0.69 is almost all
  Inc.

### 6.3 With a derivation likelihood, on instance-only data

* In C_min-type calculi with a full-support Q, theories that prove or refute ∀xφ and *generate* ∀xφ or ∃x¬φ spend
  mass on unobserved outputs and lose (U4). "Independent" takes the mass (U10(c3)).
* In richer calculi, where Q's own derivations live, the comparison is misspecified for every theory (U10(c3)). The
  answer then depends on the class (§7, §9).
* Among theories that do not generate ∀xφ, Q's derivations of 0+S^k0 = S^k0 have at least k+1 axiom leaves already
  in the equational fragment E = {Q4, Q5} (U14(a)). In the two-part form (L1-max) this gives the schema an advantage
  linear in k at the default law (U14(c)). For the full-sum likelihood and for full Q this is not established.
  (`notes.md` stated without qualification that "Q is penalised by its long derivations … so the posterior favours
  the schema"; referee m6.)

### 6.4 An ω-gap for an axiom we actually have

**Prop U13 [proved; computed: c6_models].** (Q − Q4), together with all closed instances of x+0=x, does not prove
∀x(x+0=x). Here Q4 is x+0=x.

*Proof.* Take the structure on ℕ ∪ {a, b}, standard on ℕ, with:
* **successor:** Sa = a, Sb = b;
* **addition:** a + m = m and b + m = b (m ∈ ℕ); x + a = a for x ∈ ℕ ∪ {a}; b + a = b; x + b = b for every x;
* **multiplication:** x·0 = 0 for every x; a·m = a and b·m = b (m ≥ 1); n·a = n·b = b (n ≥ 1); 0·a = 0·b = 0;
  a·a = a·b = a; b·a = b·b = b.

Each axiom of Q other than Q4 checks by cases.
* **S is injective; 0 is not a successor; every x ≠ 0 is a successor.** S is the identity on {a, b} and n ↦ n+1 on ℕ.
* **Q5: x+Sy = S(x+y).**
  * For y = m: if x = a, then a+(m+1) = m+1 = S(a+m); if x = b, both sides are b; if x ∈ ℕ it is standard.
  * For y ∈ {a, b}: Sy = y, and every x+y lies in {a, b}, which S fixes.
* **Q6** holds by definition.
* **Q7: x·Sy = x·y + x.**
  * y = m: a·(m+1) = a = a·m + a, using a + a = a and 0 + a = a. b·(m+1) = b = b·m + b.
  * y ∈ {a, b}, so Sy = y: we need z + x = z for z := x·y. Case by case: x = 0: z = 0 and 0+0 = 0; x = n ≥ 1: z = b
    and b + n = b; x = a: z = a and a + a = a; x = b: z = b and b + b = b.

All closed terms denote standard numbers, so every closed instance n+0=n holds. But a+0 = 0 ≠ a. ∎

c6 checks all axioms on {0..40} ∪ {a, b} with no violations; the referee's independent check on {0..80} ∪ {a, b}
agrees (`r5_models.out` (1)).

So for Q4 itself, closed-instance data cannot tell "the axiom is ∀x(x+0=x)" from "the axiom is the schema x+0=x at
closed terms", and over Q − Q4 these differ in their theorems. "Does the method pick up the axioms we actually have?"
has no data-determined answer from closed instances alone.

### 6.5 Truth: the Gaifman condition

**Prop U15 (the Gaifman condition is the probabilistic ω-rule) [proved; known: Gaifman 1964 for the condition].**
Let μ be a probability on L-structures, or on complete theories, and P(ψ) := μ{M : M ⊨ ψ}. Let t₁, t₂, … enumerate
the closed terms.

1. P(∀xφ | φ(t₁) ∧ … ∧ φ(t_n)) → P(∀xφ)/μ{M : M ⊨ φ(t) for all closed t}.
2. The **Gaifman condition** for φ is P(∀xφ) = inf_n P(∧_{i≤n} φ(t_i)). It holds for every φ with one free variable
   iff μ-almost every M satisfies "M ⊨ ∀xφ iff M ⊨ φ(t) for all closed t", for every such φ. Iterating over the
   variables gives the many-variable version. By `AS:prop:univ:tv` (Tarski–Vaught), this holds iff M₀ ≼ M for
   μ-almost every M, where M₀ is the substructure of denotations of closed terms.
3. Under the Gaifman condition, with P(∀xφ) > 0, the limit is 1. With P(∀xφ) = 0 it is 0 for every n: the zero-prior
   problem.

*Proof.*
1. ∀xφ entails each instance, so P(∀xφ ∧ conjunction) = P(∀xφ). The conjunctions decrease to the event "all closed
   instances", by continuity of μ. If that event has μ-measure 0, then P(∀xφ) = 0 and every term is 0.
2. The difference between the two sides is μ{M : all closed instances hold but M ⊭ ∀xφ}. This vanishes for every φ
   iff μ-almost every M satisfies (i) of `AS:prop:univ:tv` (there are countably many φ). ∎

**What should a Bayesian believe about ∀xφ when the data are true closed instances?** Three questions need
separating.
* **Truth in ℕ.** If the credence ranges over structures with M₀ ≼ M, believe ∀xφ in the limit, provided its prior
  is positive. This is safe for ℕ. It is unsafe when the credence gives weight to structures that are not elementary
  extensions of their term-generated part: ℝ (¬(x·x = 1+1) holds at every closed term), V, models of PA + ¬Con(PA)
  (`AS:ex:univ:fail`), and the non-standard models of Q of `AS:ex:univ:q`. ℕ is itself a model of Q, so "unsafe for
  models of Q" in `notes.md` should have read "for some models of Q" (referee m10).
* **Future data.** Believe that all future data will be instances (U8).
* **Which axioms the data-producer uses, or what they prove.** Closed instances alone do not decide this. The
  selection-aware posterior keeps a prior share (U10(b), (e)). A likelihood that ignores the selection moves
  towards "does not prove ∀xφ" (U10(c3), (d)) or, in richer classes, towards very specific generators (§7, §9).

### 6.6 How much the prior share depends on the code

In the prior-share regime the answer *is* the prior share, so its dependence on the code matters (referee question
4). The share of H_∀ in {H_∀, H_sch} for φ = 0+x=x, under the codes used in this project [computed: c10_misc (f)]:

| code | bits(H_∀) | bits(H_sch) | share of H_∀ |
|---|---|---|---|
| this track: dtrc symbols + 1 per axiom, λ = 1 | 7 | 6 | 0.333 |
| model Def 1.3 (prefix code, 4 bits per token, λ = 1) | 27 | 26 | 0.333 |
| model Def 1.3 with λ = 2 | | | 0.200 |
| experiments `TemplateCode` (with a closed guard on z) | 17.18 | 17.09 | 0.484 |
| pa, 5 bits per symbol | 30 | 25 | 0.030 |
| pa, log₂23 bits per symbol | 27.14 | 22.62 | 0.042 |

The model-code row is computed by hand from model Def 1.3. ∀x(0+x=x) is six tokens plus two γ(1) index codes;
0+z=z is five tokens plus 3 bits for a new metavariable (new/old, γ(1) arity, sort) and 2 for an old one; each theory
adds γ(1). The experiments row is computed with their code and matches their E1 limit 0.484. So "strictly between 0
and 1" is robust, but the value ranges from 0.03 to 0.48 across reasonable codes. The data never move it.

---

## 7. Open instances, Gen, and the closedness guard: brief item (e)

### 7.1 Parameter data and the guard

**Prop U11 [(a)–(d) proved; computed: c1_grammar, c5_open_quant].** Assume the closure reading, a calculus with Gen
over parameters, theories without parameters, and a likelihood supported on theorems (P_T(d) > 0 ⇒ T ⊢ d).

* **(a) One datum suffices.** Once D contains φ(p) for a parameter p, every T with π(T | D) > 0 proves ∀xφ. So
  P(T ⊢ ∀xφ | D) = 1 exactly.
* **(b) Waiting time.** If P_{T*}(φ(p)) = β > 0, then P(P(T ⊢ ∀xφ | D_n) < 1) ≤ (1−β)^n.
* **(c) Exact laws in C_open(c, g) with Q_open = ρ[w₀] + (1−ρ)Q_c.** Put K = 1−c−g.
  * For the three axiom types with weights (w_∀, w_open, w_sch):
    * P(∀xφ) = a = K(w_∀ + gρw_open)/(1−gcρ);
    * P(φ(w₀)) = ρ(Kw_open + ca);
    * P(φ(t)) = Q_c(t)·[(1−ρ)(Kw_open + ca) + Kw_sch] for closed t;
    * Z = a(1+c) + K(w_open + w_sch).
  * Unnormalised ratios: P_∀/P_open = c at every instance and 1/(gρ) at ∀xφ; P_open/P_sch = (1−ρ)/(1−gcρ) at closed
    instances.
  * Normalisers: Z_open = K(1+gρ)/(1−gcρ), Z_∀ = K(1+c)/(1−gcρ), Z_sch = K.
  * Hence, per closed datum under L1-norm: open/sch = (1−ρ)/(1+gρ); ∀/sch = c(1−ρ)/(1+c); ∀/open = c(1+gρ)/(1+c).
* **(d) Closed data teach the guard.** If the class contains the guarded H_sch, then on closed data
  P(T ⊢ ∀xφ | D_n) → 0. The masses of H_open and H_∀ decay exponentially, at the per-datum factors above. The guard
  is learned at rate log((1+gρ)/(1−ρ)) per datum. A spare-slot prover such as H_both (∀xφ plus the guarded schema,
  with a learned weight) decays only like 1/n (§4).

*Proof.*
* **(a)** P_T(D) > 0 implies T ⊢ φ(p). Since p occurs in no axiom, Gen gives T ⊢ ∀xφ.
* **(b)** On the event that φ(p) has appeared, (a) applies.
* **(c)** The outputs are only ∀xφ, φ(w₀) and φ(t). Gen on a closed formula fails, and elimination on a
  quantifier-free φ fails. So a = Kw_∀ + g·P(φ(w₀)) and P(φ(x)) = Q_open(x)(Kw_open + ca) + [x closed]·K·w_sch·Q_c(x).
  Solving gives the formulas.
* **(d)** follows from (c) and U4(2) for the finitely many hypotheses compared. ∎

*Checks.* c1 compares (c) with a procedural sampler (200 000 derivations per theory, max |z| = 1.60). Exact ratios
printed: forall/open = 0.3000, open/sch = 0.9054 = (1−ρ)/(1−gcρ), and forall/open at ∀xφ = 50.0 = 1/(gρ). c5 prints
the normalised ratios 0.2077 = c(1−ρ)/(1+c), 0.8824 = (1−ρ)/(1+gρ) and 0.2354 = c(1+gρ)/(1+c). The referee
reproduced them with an own sampler (`r7_misc.out` (3), max |z| = 2.15).

*Computed (c5 Part A, prior share 0.75).*

| stream | class | n = 0 | 10 | 50 | 100 |
|---|---|---|---|---|---|
| closed data, L1-norm | full | 0.750 | 0.364 | 0.004 | 0.000 |
| closed data, L1-norm | {H_∀, H_open} | 1.000 | 1.000 | 1.000 | 1.000 |
| output of H_open | full | 0.750 | 0.860 | 1.000 | 1.000 |
| output of H_∀ | full | 0.750 | 1.000 | 1.000 | 1.000 |

### 7.2 Without a guard: the ω-step is not taken under L1-norm

**U11(e) as stated in `notes.md` [refuted].** "Suppose the class has no guard, as in DT° under the λ-convention with
parameters admissible. Then H_open wins on closed data …, and every surviving hypothesis proves ∀xφ: the posterior
takes the ω-step."

*Counterexample.* R₁ = {φ(0), φ(Sz)}, z unguarded, is a pair of DT° templates. Under L1-norm it beats H_open by
(1−q)·log((1+gρ)/(1−ρ)) nats per datum (Prop N2), and it does not prove ∀xφ in pure logic (Prop N3). In the class
{H_∀, H_open, R₁}, P(T ⊢ ∀xφ | D_n) is 0.697 at n = 100 and 0.000 from n = 1000 on (c8; referee r3: 0.880 at
n = 100 and 0.000 at n = 300). The proof in `notes.md` compared only H_open, H_∀ and H_both. The class computed in
c5 Part A ("no guard") was {H_∀, H_open}.

What survives:
* **(e1) [proved]** In the class {H_∀, H_open} every hypothesis proves ∀xφ, and H_open wins at the rates of (c).
* **(e2) [proved]** Under L1-norm, in any class whose pure-logic provers are H_∀ and H_open and which contains some
  R_k, P(T ⊢ ∀xφ | D_n) → 0 exponentially (Prop N3(a)).
* **(e3) [proof sketch; computed]** Under L1-sel the ω-step is taken: P(T ⊢ ∀xφ | D_n) → 1 (Prop N3(c)).

This is the Bayesian counterpart of `AS:prop:univ:open`(b), (c). The cautious verifier without a guard takes the
ω-step silently, and a closedness guard prevents it. A Bayesian whose likelihood ignores the selection does not take
the step. It approximates the missing guard by ever deeper root splits, whose wasted mass q^k·κ_o tends to 0. It
takes the step only when the selection is modelled.

**Lemma N0 (waste lemma) [proved].** Let P* be a law on a countable set, and let H ∪ T be a partition of supp P*
with τ := P*(T) ∈ (0, 1] (H = ∅ when τ = 1). Consider laws of the form

  P = p_h·P*(· | H) + p_t·P*(· | T) + λp_t·N_W,

where N_W is any law on a set W disjoint from supp P*, λ > 0 is fixed, p_t > 0 and p_h + (1+λ)p_t = 1. Then
min over p_t of KL(P* ‖ P) equals τ·log(1+λ), attained at p_t = τ/(1+λ), p_h = 1−τ.

*Proof.* The conditionals on H and T are exact, so by the chain rule
KL(P* ‖ P) = (1−τ)·log((1−τ)/p_h) + τ·log(τ/p_t). With p_h = 1 − (1+λ)p_t this is a convex function of p_t (a sum of
−log of affine functions plus constants). Its derivative (1−τ)(1+λ)/p_h − τ/p_t vanishes at p_t = τ/(1+λ), where
p_h = 1−τ. The value is τ·log(1+λ). ∎

**Prop N1 (exact law of the root split R_k in C_open) [proved; computed: c8_noguard Part 1].** Let
A := (1−ρ)/(1−gcρ) and B := (1+gρ)/(1−gcρ). Let R_k have sentence weights v₀, …, v_{k−1} and template weight u. Its
unnormalised output law is:
* P(φ(S^j 0)) = K·v_j for j < k;
* P(φ(S^{k+m} 0)) = K·u·A·Q_c(m) for m ≥ 0;
* P(φ(S^k w₀)) = K·u·ρ/(1−gcρ);
* P(∀yφ(S^k y)) = K·u·gρ/(1−gcρ);
* nothing else. The total is Z = K(1 − u + uB).

H_open is the case k = 0, u = 1.

*Proof.* Citing a sentence yields it. Gen and elimination then fail (no parameter; no leading ∀). Citing the template
yields φ(S^k t) with t ~ Q_open. Gen applies only to φ(S^k w₀) and yields U := ∀yφ(S^k y). Elimination applies only to
U and yields φ(S^k t) with t ~ Q_open. Let a := P(U) and b := P(φ(S^k w₀)). Then a = g·b and b = ρ(Ku + ca). Hence
a = gρKu/(1−gcρ) and b = ρKu/(1−gcρ). A closed tail instance has probability (1−ρ)Q_c(m)(Ku + ca) = K·u·A·Q_c(m).
Summing, Z = K(1−u) + Ku[(1−ρ) + ρ + gρ]/(1−gcρ) = K(1 − u + uB). ∎

c8 compares these formulas with the procedural sampler of `common.py` for R₁, R₂ and R₃ (2·10⁵ derivations each, ten
output classes each): max |z| = 2.07, and no unexpected outputs. The referee's independent sampler gives max |z| = 2.19
(`r3_noguard.out`).

**Prop N2 (rates) [proved; computed: c8_noguard Part 2].** On closed data with law P*(φ(S^j 0)) = Q_c(j), under
L1-norm, with κ_o := log((1+gρ)/(1−ρ)):
* KL(P* ‖ P_{H_∀}) = log((1+c)/(c(1−ρ)));
* KL(P* ‖ P_{H_open}) = κ_o;
* inf over weights of KL(P* ‖ P_{R_k}) = q^k·κ_o, attained at v_j ∝ Q_c(j) and u = q^k/(B(1−q^k) + q^k).

*Proof.* Conditioned on closed outputs, H_∀ and H_open have law P* (U11(c)). So their KL is log(1/P(closed)): for
H_∀ the closed mass is c(1−ρ)/(1+c), and for H_open it is A/B = (1−ρ)/(1+gρ). For R_k, by N1 the normalised law has
head mass (1−u)/Z_R with Z_R = 1−u+uB, tail mass p_t = Au/Z_R with the exact tail shape Q_c(j−k)/Σ = P*(· | tail),
and waste (B−A)u/Z_R = λp_t with λ = B/A − 1. For fixed u, the best head shape is v_j ∝ Q_c(j) (Gibbs' inequality).
Then Lemma N0 applies with τ = q^k. As u ranges over (0, 1], p_t ranges over (0, A/B] = (0, 1/(1+λ)], which contains
the optimum τ/(1+λ). Solving Au/(1−u+uB) = q^kA/B gives u. The value is q^k·log(1+λ) = q^k·log(B/A) = q^k·κ_o. ∎

c8 minimises the KL numerically for k = 0, …, 6 under four parameter settings. It agrees with q^k·κ_o to 1.8·10⁻¹⁵,
the minimiser agrees with the formula to 10⁻⁶, and random perturbations of the head weights never improve it. At
the default (c, g, ρ, q) = (.3, .2, .1, .5): κ_o = 0.1252, and R₁, R₂, R₃ lose 0.0626, 0.0313 and 0.0156 nats per
datum. The referee's grid optimisation gives the same values (`r3_noguard.out` (2)).

**Prop N3 (who wins without a guard).** Closed data i.i.d. from Q_c. The class contains H_∀, H_open and R_k for k in
a nonempty set 𝒦, with learned (Dirichlet) or optimal fixed weights. It may also contain memorisers (§1.3, numeral
universe).

* **Provability.** In pure logic H_∀ and H_open prove ∀xφ, and R_k and memorisers do not. Over Q (that is, for
  T ∪ Q), H_∀, H_open and every R_k prove ∀xφ, and memorisers do not [proved below].
* **(a) L1-norm, pure logic [proved].** If the pure-logic provers in the class are H_∀ and H_open, then
  P(T ⊢ ∀xφ | D_n) → 0 almost surely, exponentially, at rate at least (1 − q^k)κ_o per datum for any k ∈ 𝒦. Provers
  that add φ(z) as a spare component to some R_k, with learned weights, decay only polynomially relative to R_k
  [proof sketch; model Prop 5.5(b)].
* **(b) L1-norm, over Q, bounded depth [proved].** If 𝒦 is finite and memorisers (Laplace weights) are present, then
  P(T ∪ Q ⊢ ∀xφ | D_n) → 0 almost surely. If 𝒦 is finite and there are no memorisers, it is 1 for every n.
* **(c) L1-sel [proof sketch; computed].** H_∀ and H_open both have the law P*, and each R_k equals P* at exactly
  one weight vector. With learned weights each R_k pays an Occam factor of order n^{−k/2}. So
  P(T ⊢ ∀xφ | D_n) → 1 (pure logic) for finite 𝒦.
* **(d) L1-norm, unbounded depth [computed; conjecture for the limit].** With 𝒦 = {1, …, 40} and memorisers,
  P(T ∪ Q ⊢ ∀xφ | D_n) = 1.000 from n = 10, and the posterior follows ever deeper splits.

*Proof of the provability claims.*
* *R_k ⊬ ∀xφ in pure logic (k ≥ 1).* Take ℕ ∪ {e, e′}, standard on ℕ, with Se = e′, Se′ = e′, 0+e = e′ and
  0+e′ = e′, and other values arbitrary. For every element x, S^k x is a standard number ≥ k or e′, and 0 + S^k x =
  S^k x in both cases. So every instance of φ(S^k z), closed or with parameters, holds, and so do φ(0), …,
  φ(S^{k−1}0). But 0+e = e′ ≠ e.
* *Q ∪ R_k ⊢ ∀xφ.* Q proves every closed instance 0+S^j0 = S^j0: 0+0 = 0 by Q4, and 0+S^{j}0 = S(0+S^{j−1}0) by Q5,
  so this follows by induction on j outside the theory. Applying Q3 (every x ≠ 0 is a successor) k times, every x
  is one of 0, …, S^{k−1}0, or has the form S^k y. In the first cases Q proves φ(x). In the last case the instance
  φ(S^k w₀) of R_k, read under closure as ∀yφ(S^k y), gives it.
* *Memorisers.* Their sentences are closed instances, which Q already proves, and Q ⊬ ∀x(0+x=x) (`AS:ex:univ:q`).

*Proof of (a).* Each prover T ∈ {H_∀, H_open} has a fixed law, so (1/n)·log(P_T(D_n)/P*(D_n)) → −KL(P* ‖ P_T) ≤ −κ_o
almost surely (U4(2)). For R_k with learned weights, let w₀ be the optimal weights and N_ε an ε-neighbourhood of
w₀. On N_ε the weights are bounded away from 0, so |∂ log P_w(d)/∂w| ≤ M for all w ∈ N_ε and all data d (the
per-datum log-likelihood is log v_j − log Z_R or log(Au) + log Q_c(m) − log Z_R, and the term log Q_c(m) does not depend
on w). Hence the marginal is at least Dir(N_ε)·P_{w₀}(D_n)·e^{−nMε}, and
liminf (1/n)·log(marginal/P*(D_n)) ≥ −q^kκ_o − Mε. Since ε is arbitrary, the liminf is ≥ −q^kκ_o. So the log-odds of
R_k against each prover grow at least like n(κ_o − q^kκ_o) − o(n). ∎

*Proof of (b).* Every hypothesis in the class except the memorisers proves ∀xφ over Q, which gives the second
sentence. For the first: by U6(ii′) (with H_sch's law equal to P*), the memoriser class has log-marginal relative
to P* at least −C·log² n almost surely for large n. For each R_k, the likelihood ratio against P* depends on the data
only through the empirical frequencies p̂ of the k+1 categories (head values j < k, tail), because Q_c(k+m) = q^k Q_c(m)
cancels the tail shape. So (1/n)·log sup_w P_{R_k,w}(D_n)/P*(D_n) = sup_w G(p̂, w), a continuous function of p̂ near
p* > 0, and p̂ → p* almost surely. The limit is −q^kκ_o < 0, and the marginal is at most the supremum. So each R_k, and
H_∀ and H_open, lose linearly against the memorisers. With 𝒦 finite this gives the claim. ∎

*Sketch of (c).* Under L1-sel the filtered law of R_k has head v_j/N and tail A·u·Q_c(m)/N with N = 1−u+Au. This is a
smooth reparametrisation of a (k+1)-category multinomial, equal to P* at one interior point. The standard Laplace
(BIC) expansion of a regular k-parameter family [known: Schwarz 1978; Clarke and Barron 1990 (unverified details)]
gives a log-marginal relative to P* of −(k/2)·log n + O_P(1). Memorisers lose O(log² n). H_∀ and H_open have
log-ratio exactly 0. The step not written out is the almost-sure (rather than in-probability) control, uniformly in
k when 𝒦 is infinite.

*Computed (c8 Part 3; Dirichlet(½) weights; prior 2^{−(symbols + 1 per axiom)}; memoriser class mass 2^{−6} with
the lower bracket of U6(i); 20 seeds; n up to 10⁶).*

| likelihood, class | quantity | n = 0 | 10 | 100 | 10³ | 10⁴ | 10⁵ | 10⁶ |
|---|---|---|---|---|---|---|---|---|
| L1-norm, {H_∀, H_open, R₁} | P(T ⊢ ∀xφ), pure | 0.997 | 0.996 | 0.697 | 0.000 | 0.000 | 0.000 | 0.000 |
| | MAP | H_open | H_open | H_open | R₁ | R₁ | R₁ | R₁ |
| L1-norm, + R₂..R₄ + memorisers | P(T ∪ Q ⊢ ∀xφ) | 0.601 | 1.000 | 1.000 | 1.000 | 1.000 | 0.000 | 0.000 |
| | MAP | H_open | H_open | H_open | R₃ | R₄ | mem | mem |
| L1-norm, + R₂..R₄₀ + memorisers | P(T ⊢ ∀xφ), pure | 0.599 | 0.996 | 0.697 | 0.000 | 0.000 | 0.000 | 0.000 |
| | P(T ∪ Q ⊢ ∀xφ) | 0.601 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 | 1.000 |
| | MAP | H_open | H_open | H_open | R₃ | R₆ | R₉ | R₁₂ |
| L1-sel, every class | P(T ⊢ ∀xφ), pure | 0.997 / 0.599 | 0.998 | 0.987 | 1.000 | 1.000 | 1.000 | 1.000 |

*Computed (c8 Part 4; class with R₁..R₄₀ and memorisers; L1-norm; multinomial counts, 10 seeds per n).* The MAP is
R₁₅, R₁₈, R₂₁, R₂₄ and R₃₀ at n = 10⁷, 10⁸, 10⁹, 10¹⁰ and 10¹². P(T ∪ Q ⊢ ∀xφ) = 1.000 and the pure-logic value is 0
at every one of these n. The same holds with the memoriser upper bracket and memoriser class mass ½, with α = 1, and
with λ = 2 (MAP R₁₄ … R₃₀). The MAP depth is close to log₂ n minus a slowly growing term (≈ 8 at n = 10⁶, ≈ 10 at
n = 10¹²).

*Reading.*
* In pure logic the ω-step is not taken without a guard under L1-norm, in every computed class that contains a
  root split. (It is taken in the class {H_∀, H_open}, where every member proves ∀xφ.)
* Over Q, whether the limit is 1 is decided by a race between two families: the root splits, which prove ∀xφ over
  Q, and the memorisers, which do not. With unbounded depth the splits win in this setting: the memoriser mass is
  0.000 at every n ≥ 10, and under all four prior variants up to n = 10¹². With depth ≤ 4 the memorisers win. So the
  over-Q answer is a property of the hypothesis class, not of the data.
* The referee's class (`r3_noguard.out`: R₁..R₃, memorisers, Laplace weights) gives R₃ at n = 3000. That is consistent
  with these tables.

---

## 8. Quantified data, derivation length and lemmas: brief item (f)

**Prop U12 [(a) proved; (b) proved in the toy and computed: c5_open_quant Part B, c10_misc (c); (c) proof sketch].**

* **(a) Refutation.** If d ∈ D and B ∪ I_c(φ) ⊬ d, then under any likelihood supported on theorems, B⊕σ_φ has
  posterior 0 from then on.

  *Example:* B = Q and d = ∀y(0+Sy = Sy). In the model of `AS:ex:univ:q`, Sa = a and 0+a = b, so 0+Sa = b ≠ a = Sa;
  hence Q + I_c ⊬ d. Conversely Q + d ⊢ ∀x(0+x=x): if x = 0 use Q4; otherwise Q3 gives x = Sy and d gives
  0+Sy = Sy. So among theories extending Q, one quantified datum leaves only provers of ∀xφ.
* **(b) Gradual shift, when every theory proves ∀xφ but at different cost.** Take C_min and B = ∀^L∀xφ (L vacuous
  quantifiers, so ∀xφ needs L extra eliminations). The theories T_sch+B = {B, σ_φ} and T_both = {∀xφ, σ_φ} both
  carry a weight θ (on B, respectively ∀xφ) with a uniform prior. Data are ∀xφ with probability f_q and closed
  instances otherwise.
  * *Closed forms* (units of 1−c; S_B := Σ_{k=0}^{L+1} c^k).
    * T_both(θ): P(∀xφ) = θ/(1+θc) and P(φ(t)) = (1−θ+θc)Q(t)/(1+θc).
    * T_sch+B(θ): P(∀xφ) = θc^L/Z_B and P(φ(t)) = ((1−θ) + θc^{L+1})Q(t)/Z_B, with Z_B = θS_B + 1 − θ.
  * *Per-datum differences at a fixed θ.* For a datum ∀xφ, log P_{T_both} − log P_{T_sch+B} = L·log(1/c) +
    log(Z_B(θ)/(1+θc)). For an instance the difference is 0.021, 0.094, 0.307 and 1.323 nats at θ = 0.05, 0.2, 0.5
    and 0.9 (L = 3). So "instance data cost the two theories almost the same" holds only for small θ. `notes.md`
    said "≤ 0.1 nats per datum" without the θ range (referee m5).
  * *f_q = 0 [proved via Watson's lemma; computed].* Both Bayes factors against H_sch are deterministic integrals
    ∫₀¹ e^{n f_i(θ)} dθ, with f_i(0) = 0, f_i decreasing, f_both′(0) = −1 and f_B′(0) = −(1 + c + ⋯ + c^L). By
    Watson's lemma [known] each is (n|f_i′(0)|)^{−1}(1 + o(1)). So the log Bayes factor T_both : T_sch+B tends to
    log(1 + c + ⋯ + c^L): 0.349 for L = 3 and 0.357 for L = 10. c10 gives these values, to three decimals, at every n
    from 10 to 10⁵.
  * *f_q > 0 [proof sketch; computed].* With equal priors the log Bayes factor grows linearly at the rate
    Δ(f_q) := max_θ E ℓ_both(θ) − max_θ E ℓ_{sch+B}(θ). For L = 3, Δ = 0.0396, 0.1980 and 0.7921 nats per datum at
    f_q = 0.01, 0.05 and 0.2. The measured slopes (mean of 20 seeds, n = 10⁵) are 0.0395, 0.1977 and 0.7921. For
    L = 10: Δ = 0.1240, 0.6198 and 2.4793, measured 0.1236, 0.6187 and 2.4793. Δ is close to, and a little above,
    f_q·L·log(1/c) (0.036, 0.181 and 0.722 for L = 3). The step not written out is the Laplace approximation of both
    marginals at their interior maxima.
  * *The table of c5 Part B* (kept below) tracks something else. There T_sch+B has a much smaller prior, so the
    reported P(T ⊢ ∀xφ) = 1 − mass(T_sch) follows the refutation of T_sch by the first quantified datum, i.e. part
    (a). The mean over seeds equals 1 − (1−f_q)^n within Monte Carlo error.

| f_q | quantity (c5 Part B, L = 3; same for L = 10) | n = 10 | 50 | 200 | 1000 |
|---|---|---|---|---|---|
| 0 | mass(T_sch) | 1.000 | 1.000 | 1.000 | 1.000 |
| 0.01 | P(T ⊢ ∀xφ) | 0.075 | 0.300 | 0.875 | 1.000 |
| 0.05 | P(T ⊢ ∀xφ) | 0.450 | 0.975 | 1.000 | 1.000 |

* **(c) Lemmas become axioms; the derivation likelihood tracks usage.** In the two-part (L1-max) form, adding a
  derived sentence ψ as an axiom changes the code length by:
  * + prior bits for ψ;
  * + a dilution cost, O(log n) with learned weights;
  * − Σ_{d∈D}(ℓ_T(d) − ℓ_{T+ψ}(d))·log(1/c), where ℓ is derivation length.

  So frequently used lemmas become axioms, and rarely used ones are dropped. The posterior identifies the
  data-producer's working set of primitives, not a canonical axiomatisation. Pa §1 computes the same effect for
  induction, course-of-values induction and the least number principle.

**Prop U14 ("statements given without proof should be easily derivable": the equational fragment of Q)
[(a), (b), (c) proved; (a) computed: c6_models; full Q and the full-sum comparison at q = ½: open].**

* **(a) Equational lower bound.** In equational logic over E = {Q4: x+0=x, Q5: x+Sy=S(x+y)}, with any instances,
  every derivation of 0+S^k0 = S^k0 has at least k+1 axiom-instance leaves.
* **(b) Tail bound.** Suppose each node of a derivation grammar picks its rule independently, with at most 2
  premises and mean number of premises μ < 1. Then P(the derivation has ≥ L nodes) ≤ exp(−(L−1)(1−μ)²/2).
* **(c) Comparisons with the schema.**
  * *Full sum.* By (a) and (b), P_E(0+S^k0 = S^k0) ≤ exp(−k(1−μ)²/2), while P_{E⊕σ}(0+S^k0 = S^k0) ≥
    p_cite·w·(1−q)q^k. When q > e^{−(1−μ)²/2}, the log-odds favour the schema by Ω(k) on such a datum. This needs
    q > e^{−1/2} ≈ 0.61 even as μ → 0, so **it does not apply at the default q = ½** (referee m6).
  * *Two-part (L1-max).* Suppose every axiom leaf costs at least ℓ_min nats. Then ℓ_E(0+S^k0 = S^k0) ≥ (k+1)ℓ_min,
    while the schema costs O(1) + k·log(1/q). So the schema wins by at least k(ℓ_min − log(1/q)) − O(1). If each leaf
    pays log(1/p_cite) for the citation and draws at least one term from a law with maximal point mass ≤ 1−q (e.g.
    the numeral law), then ℓ_min ≥ log(1/p_cite) + log(1/(1−q)). This exceeds log(1/q) for every q ≥ ½. So at the
    default law the two-part comparison favours the schema linearly in k.

*Proof.*
* **(a)** Let w(t) := Σ over +-nodes (l + r) of t of (1 + #S(r)). Replacing an instance u+0 by u, or u+Sv by S(u+v),
  anywhere in a term changes w by exactly −1. The reverse replacements change it by +1. The reasons:
  * the removed or rewritten +-node contributes 1, respectively 2 + #S(v) against 1 + #S(v);
  * nodes inside u and v are untouched;
  * every +-node above keeps the number of S symbols in its right argument.

  Now w(0+S^k0) = k+1 and w(S^k0) = 0. A derivation tree (reflexivity, symmetry, transitivity, congruence,
  substitution, axiom instances) converts by induction into a replacement chain with at most as many steps as it has
  axiom leaves. Congruence and transitivity concatenate chains, symmetry reverses one, and substitution maps a chain
  to one of the same length.
* **(b)** Couple the grammar with the Galton–Watson tree of rule labels; success and the conclusion are functions of
  that tree and the term draws. Explore the tree depth-first. With ξ_i the premise counts, the number of nodes is
  ≥ L only if Σ_{i<L}(ξ_i − 1) ≥ 0. Apply Hoeffding's inequality to ξ_i − 1 ∈ [−1, 1], which has mean μ − 1.
* **(c)** The full-sum claim combines (a), (b) and the citation probability of the schema. For the two-part claim:
  the code length of a derivation is the sum over its nodes of −log of the rule choice and of the term draws, and
  each of the ≥ k+1 leaves contributes at least ℓ_min. The schema's derivation is one citation with z := S^k0, of
  cost log(1/p_cite) + log(1/w) + log(1/(1−q)) + k·log(1/q). ∎

*Computed.* A breadth-first search over all terms of size ≤ |0+S^k0| + 4 gives shortest chains of exactly k+1 for
k ≤ 5, and every explored step changed w by ±1 (c6). The referee checked the invariant on 339 250 random one-step
rewrites of terms with variables and · (`r5_models.out` (3)).

*Remark (the time penalty, brief H6, for this case).* Here checking axiomhood is linear in the size for every
hypothesis considered (unique matching), so a penalty on membership checking does not separate them. A Levin-style
Kt penalty (log of running time) on generating 0+S^k0 = S^k0 from E would charge O(log k), weaker than the
derivation-length charge of (a). Any penalty monotone in derivation length preserves Thm B (Prop U2t). Hänni's
collapse construction and the role of time penalties in it are treated in model §6. Its finding, that only
derivation length prices the assigner, is consistent with this section.

---

## 9. Without templates: the sentence-only class

The user proposes templates to block Hänni's collapse. What happens without them? Hypotheses are now finite sets of
sentences, so the instance schema is not available.

*Setting.* C_min with c = 0.3, numeral data φ(S^j 0) with q = ½, and φ = 0+x=x. Hypotheses: H_∀, Both0 = {φ(0), ∀xφ},
Split_k = {φ(0), …, φ(S^{k−1}0), ∀yφ(S^k y)} (k ≥ 1), and memorisers (numeral universe). Weights are learned:
Laplace in c7, Dirichlet(½) in c9.

**Prop U16 [(a) proof sketch; (b), (c) proved; (d) computed, conjecture for the limit; computed: c7_sentences,
c9_sentences].**

* **(a) L0-closure: ∀xφ wins.** H_∀ has the true law exactly. Split_k equals it at exactly one weight vector
  (v_j = Q_c(j), u = q^k), and Both0 only at the boundary θ = 0. So with learned weights both pay an Occam factor
  polynomial in n (order n^{−k/2} for Split_k), and memorisers lose O(log² n). Hence P(T ⊢ ∀xφ | D_n) → 1. The step
  not written out is the Laplace (BIC) expansion, uniformly in k. *Computed:* 0.999 at n = 500 in c7's class; 0.997
  at n = 20 and 1.000 from n = 10³ in all classes of c9, with H_∀ the MAP from n = 20.
* **(b) L1-norm: exact rates.** On numeral data:
  * KL(P* ‖ H_∀) = log((1+c)/c) (1.466 at c = 0.3);
  * inf over weights of KL(P* ‖ Split_k) = q^k·log((1+c)/c) (0.733, 0.367, 0.183, … at q = ½);
  * inf over weights of KL(P* ‖ Both0) = q·log((1+qc)/(qc)) (1.018).

  So Split₁ beats Both0, which beats H_∀, and each extra level of splitting halves the loss. In a class with finitely
  many hypotheses that contain a universal sentence, the best of them wins among them, and memorisers with Laplace
  weights eventually beat all of them (the proof of N3(b) applies unchanged).
* **(c) Status.** Split_k ⊬ ∀xφ in pure logic; Q ∪ Split_k ⊢ ∀xφ; memorisers do not prove ∀xφ even over Q; H_∀ and
  Both0 prove it in pure logic. Lemma S1 below: over Q, *every* finite set of sentences that keeps positive likelihood
  on infinitely many numeral instances proves ∀xφ.
* **(d) Which family wins with unbounded depth.** Pure logic: P(T ⊢ ∀xφ | D_n) → 0 in every class computed. Over Q
  it is a race between the split family and the memoriser family. With depth ≤ 40 the splits win (computed to
  n = 10¹² under four prior variants), so P(T ∪ Q ⊢ ∀xφ | D_n) = 1.000 from n = 10³. With depth ≤ 4 the memorisers
  win from n ≈ 10³ and the value tends to 0. [conjecture] With all depths available, P(T ∪ Q ⊢ ∀xφ | D_n) → 1 almost
  surely.

*Proof of (b).*
* *H_∀.* By U2, its normalised law gives each instance c/(1+c) times its true probability, and ∀xφ the rest. So the
  KL is log((1+c)/c).
* *Split_k.* C_min chains from Split_k: a sentence yields itself; the universal yields itself (probability
  (1−c)·u) or, after one elimination, φ(S^{k+m}0) with probability (1−c)·u·c·Q_c(m). Normalised by (1−c)(1+cu):
  head v_j/(1+cu), tail u·c·Q_c(m)/(1+cu), waste u/(1+cu) = p_t/c. Lemma N0 with τ = q^k and λ = 1/c gives
  q^k·log(1 + 1/c). The optimum p_t = q^k·c/(1+c) is attainable, since p_t = uc/(1+cu) ranges over (0, c/(1+c)].
* *Both0* (weight θ on φ(0)). Let M := (1−θ)c/(1+c(1−θ)) be the instance mass produced through ∀xφ. Then the tail
  {j ≥ 1} has mass qM with the exact conditional shape, the waste is M/c, and φ(0) has mass 1 − qM − M/c. So
  KL = (1−q)·log((1−q)/(1 − M(q + 1/c))) + q·log(1/M). This is convex in M, minimal at M = qc/(1+qc), which is
  attainable (M ranges over [0, c/(1+c)]), with value q·log((1+qc)/(qc)).

c9 confirms all three numerically to 9·10⁻¹⁶ under three parameter settings, and checks the closed-form laws against
the generic exact engine of `common.py` (max difference 1.1·10⁻¹⁶). ∎

*Proof of (c).* The countermodel of N3 (ℕ ∪ {e, e′}) satisfies every sentence of Split_k, since S^k x is a standard
number ≥ k or e′ for every x; and 0+e ≠ e. The derivation over Q is that of N3. ∎

**Lemma S1 (survivors prove ∀xφ over Q) [proved].** In C_min with numeral elimination terms, let T be a finite set
of sentences with P_T(φ(S^j0)) > 0 for infinitely many j (φ = 0+x=x). Then Q ∪ T ⊢ ∀xφ.

*Proof.* A chain cites some A ∈ T and eliminates leading quantifiers with numerals. Since T is finite, a single A
yields φ(S^j0) for infinitely many j. Its conclusion is quantifier-free, so the chain eliminates all leading
quantifiers: A = ∀y₁…∀y_r χ with χ quantifier-free, and χ[t̄/ȳ] = (0 + S^j0 = S^j0) for numeral tuples t̄ with
infinitely many distinct j. Numerals contain only 0 and S, and every other symbol of χ survives the substitution. So
χ = (0 + τ₁ = τ₂), where each τ_i is S^a y_l or S^a 0.
* τ₁ must contain a variable, since j is not constant: τ₁ = S^a y_l.
* τ₂ = S^b 0 would force j = b for every output. So τ₂ = S^b y_m.
* If m = l, the outputs require S^a t_l = S^b t_l, so a = b, and A ⊢ ∀y φ(S^a y). Over Q, a uses of Q3 split every x
  into 0, …, S^{a−1}0 or S^a y. Q proves the closed instances (N3), and ∀yφ(S^a y) covers the rest. So Q ∪ T ⊢ ∀xφ.
* If m ≠ l, then A ⊢ 0 + S^a 0 = S^b 0 and A ⊢ 0 + S^a 0 = S^{b+1} 0. So S^b 0 = S^{b+1} 0, which Q refutes (S is
  injective and 0 is not a successor). Then Q ∪ T is inconsistent and proves ∀xφ. ∎

So, with data from the numeral law, every hypothesis that keeps positive likelihood forever proves ∀xφ over Q. A
fixed memoriser is eventually refuted, but the memoriser *family* is not, and it can hold the mass at every n. That
is why the over-Q limit is a race between families.

*Computed (c9 Part 3; Dirichlet(½); prior 2^{−(symbols + 1 per axiom)}; memoriser class mass 2^{−6}, lower bracket;
20 seeds).*

| likelihood, class | quantity | n = 0 | 20 | 100 | 10³ | 10⁴ | 10⁵ | 10⁶ |
|---|---|---|---|---|---|---|---|---|
| L1-norm, {H_∀, Split₁, Both0} (c7's class) | P(T ⊢ ∀xφ), pure | 0.996 | 0.038 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| | MAP | H_∀ | Split₁ | Split₁ | Split₁ | Split₁ | Split₁ | Split₁ |
| L1-norm, {H_∀, Both0, Split₁..₄, memorisers} | P(T ∪ Q ⊢ ∀xφ) | 0.338 | 0.926 | 0.947 | 0.475 | 0.000 | 0.000 | 0.000 |
| | MAP | mem | Split₁ | Split₃ | mem | mem | mem | mem |
| L1-norm, {H_∀, Both0, Split₁..₄₀, memorisers} | P(T ⊢ ∀xφ), pure | 0.336 | 0.024 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| | P(T ∪ Q ⊢ ∀xφ) | 0.338 | 0.926 | 0.947 | 1.000 | 1.000 | 1.000 | 1.000 |
| | MAP | mem | Split₁ | Split₃ | Split₆ | Split₉ | Split₁₂ | Split₁₅ |
| L0-closure, same class | P(T ⊢ ∀xφ), pure | 0.336 | 0.997 | 0.999 | 1.000 | 1.000 | 1.000 | 1.000 |

*Computed (c9 Parts 4 and 5).* In the class with Split₁..₄₀, at n = 10⁷, 10⁸, 10⁹, 10¹⁰ and 10¹² the MAP is Split₁₈,
Split₂₁, Split₂₄, Split₂₇ and Split₃₄, and P(T ∪ Q ⊢ ∀xφ) = 1.000. This holds also with the memoriser upper bracket
and class mass ½, with α = 1, and with λ = 2. The log posterior odds of the split family against the memoriser family
(mean of 10 seeds) are 16.5, 34.4, 54.7, 71.5, 105.1, 145.2, 193.5 and 286.4 nats at n = 10², 10³, 10⁴, 10⁵, 10⁶,
10⁸, 10¹⁰ and 10¹². The smallest value over seeds is negative only at n = 10² (−2.9). The odds are of the same order
as L·log₂ L with L = log₂ n (18.2 … 212.0).

*Heuristic for (d) [conjecture].* Let L = log₂ n. The best memoriser must include every value seen, about L of them,
at a prior cost of about L² bits plus a Dirichlet cost of about (L/2)·ln n nats. The best split memorises only the
values below its depth k and covers the rest with one universal sentence, whose waste costs about
n·q^k·log((1+c)/c) nats. This waste balances the marginal cost of one more level (Θ(L) nats) when n·q^k = Θ(L), so
k ≈ L − log₂ L + O(1). The split thus saves about log₂ L levels at Θ(L) nats each, a margin of order L·log L. This
matches the growth in Part 5 but is not a proof: it ignores the fluctuations of the top values and the uniformity
over k.

**Resolution of referee M2.** `notes.md` reported U16(b) and (c) for the class {H_∀, Split, Both0}, where all three
hypotheses prove ∀xφ over Q, so "= 1 over Q" held by construction. The referee is right about that. The referee's
replacement, "P(T ⊢ ∀xφ | D_n) → 0 over Q as well", holds when the split depth is bounded (reproduced: c9, depth ≤ 4).
It does not hold with unbounded depth (c9, depth ≤ 40, n ≤ 10¹²). The robust statements are (b), (c), Lemma S1, and the
dependence on the class in (d).

*Remark (Kreisel's conjecture) [flagged: secondary sources only].* The idea "all instances have short derivations,
so ∀xφ is derivable" is close to Kreisel's conjecture: if PA proves every φ(S^n0) with proofs of a bounded number of
steps, then PA ⊢ ∀xφ. It is reported open for standard formalisations of PA, settled for some formulations (Parikh
1973; Baaz and Pudlák 1993), and false for some theories close to PA (Hrubeš 2007). Split₁ shows that the naive
version fails without background axioms such as Q3: every numeral instance is derivable in at most one step, and
∀xφ is not.

---

## 10. Relation to the MDL finding of axiom-schemas

The brief asks whether a derivation-based likelihood changes the finding of `AS:sec:many:mdl`: "MDL tracks the
statistics of usage, not the logical boundaries of schemas" (a naive code splits T_Ind by a margin linear in n; a
well-specified code gains at most O(log n) from splitting). For the ∀ case the answer has three parts.

1. **Well-specified, with Q factoring at the root.** A root split with fixed weights p_f has exactly the law of the
   schema, under L0 and under L1 (model Prop 2.6(b) and the remark after it). In c2 the fixed-weight root split
   keeps its prior share (0.004) at every n. With learned weights the split pays an Occam factor polynomial in n
   (model Prop 5.4(c): n^{−(K−1)/2}). In c2 the Laplace-weighted root split decays. This is `AS:prop:many:mdlwell`.
2. **Misspecified by an unmodelled selection.** On closed data under L1-norm, without a guard (§7.2) or without
   templates (§9), the root splits R_k and Split_k beat the schema-type hypotheses by a margin linear in n, at rates
   (1 − q^k)·κ_o and (1 − q^k)·log((1+c)/c) per datum. This is the linear margin of `AS:prop:many:mdlnaive`. Here the
   source of the misspecification is not the instantiation grammar but the selection of which theorems are
   reported, and the split is by numeral depth rather than by main connective. The same mechanism appears in
   experiments E3 (numeral data under a richer term law: the numeral split N₄ wins at a linear rate) and pa §2
   (fragmentation of T_Ind under a context-free grammar).
3. **Modelling the selection removes it.** Under L1-sel each R_k equals the truth at one weight vector and loses
   its Occam factor again (N3(c)).

So a derivation likelihood does not change the MDL finding. It adds one more way to be misspecified: the theorems
humans state are a selection from the theorems their axioms generate.

---

## 11. The user's intuition, precisely

The intuition reads: "∀xφ is a simple law which implies all the other statements … once we see them, we should up
its probability … still entertaining other hypotheses."

**In what sense it is right.**
1. **Against hypotheses that fit the data worse.** Any normalised likelihood rewards a hypothesis that generates the
   data from a short description and does not spread mass widely. The law beats memorisation (U6) and over-general
   templates (U4) once data accumulate. This is Bayesian Occam, the size principle.
2. **As prediction.** "All future data will be φ-instances" gains probability → 1. That requires positive prior
   mass on instance-only hypotheses, which a countable template prior gives and Laplace's rule does not (U8;
   Hutter 2007).
3. **As truth in a term-generated structure.** If the question is "is ∀xφ true in ℕ", a Gaifman-type credence
   believes it in the limit, and this is safe for ℕ (U15).
4. **Without templates, under pure citation.** ∀xφ takes the posterior (U16(a)).

**Where it needs refinement.**
1. **∀xφ is not the only simple law that implies the data.** Its instance schema generates exactly the instances.
   The data cannot raise ∀xφ relative to it (Thm B). A derivation likelihood even lowers ∀xφ by c per datum, and
   neither noise, nor learned c, nor any monotone length or time penalty reverses this (U2n, U2c, U2t). The theories
   that remain in play forever are not memorisers but predictively equivalent, deductively weaker theories: σ_φ,
   and background theories such as Q that prove each instance. Templates, which the user proposes to block Hänni's
   collapse, are exactly what bring σ_φ into the class.
2. **"Up its probability" covers three different propositions.**
   * "Future data are instances": this goes up (U8).
   * "∀xφ is true": this goes up only under a Gaifman-type prior, and is truth-safe only where M₀ ≼ M (U15).
   * "The axioms prove ∀xφ": this does not go up from closed instances (U10).
3. **The simplicity that matters is that of the generator.** A derivation likelihood rewards the most specific
   generator that fits (U5, N2, U16(b)) and frequently used lemmas (U12(c)). It does not reward the logically
   strongest law. When the likelihood ignores how the data were selected, the most specific generators are
   hybrids of memorisation and a shifted law (R_k, Split_k), and whether they prove ∀xφ depends on background axioms
   such as Q3.
4. **Data that do license ∀xφ:**
   * one instance at a parameter (U11(a));
   * quantified consequences, which refute or outweigh the weaker theories (U12);
   * a selection-aware likelihood in a class without a guard, where the ω-step is taken by design: soundly in ℕ,
     unsoundly in ℝ (N3(c), U15).

   In proof-assistant practice data at parameters are common. So the practical answer is often positive, for a
   reason other than the one the intuition gives.

**A good version, for this case.**
* **Prior:** a proper template prior (e.g. model Def 1.3), with inconsistent theories excluded or reported as Inc.
* **Likelihood:** a derivation likelihood that models the selection of reported data, either with a known filter
  (L1-sel) or with a prior over filters (U10(e)). Without this, the normalised derivation likelihood drifts to ever
  more specific generators on instance data (N3, U16).
* **Robustness:** a noise component (U2n), so that one false datum does not refute the true theory.
* **Verifier:** accept s iff Bel_cons(s) = π_n({T consistent : T ⊢ s}) ≥ 1 − δ.

What it does on ∀xφ:
* On closed instances it accepts ∀xφ only if the prior share of provers, over theories and filters, is ≥ 1−δ.
* It accepts every φ(t) once the law-like hypotheses (σ_φ, ∀xφ, H_open, the splits) carry mass ≥ 1−δ.
* It accepts ∀xφ after one parameter instance (U11(a)), or after a quantified datum that entails ∀xφ over the
  background (U12(a)).

**Soundness [proved, as an application of model Thm 4.1 / `IL:thm:caution:ville`].** Assume well-specification:
data i.i.d. from P_{T*}, T* ∈ H. Let C*_∀ := {T ∈ C* : T ⊢ ∀xφ iff T* ⊢ ∀xφ}, which contains T*. Suppose T* ⊬ ∀xφ.
Acceptance of ∀xφ needs π_n(C*_∀) ≤ δ. Since all members of C*_∀ have T*'s likelihood, π_n(C*_∀) =
π(C*_∀)·P_{T*}(D_n)/M(D_n), so acceptance needs M(D_n)/P_{T*}(D_n) ≥ π(C*_∀)/δ. That ratio is a nonnegative
supermartingale under P_{T*} with initial value 1. By Ville's inequality the probability of ever accepting is
≤ δ/π(C*_∀) ≤ δ/π(T*), uniformly over time. This is model Thm 4.1 with C*_d read at the single sentence ∀xφ.

Without well-specification there is no such guarantee.
* Under the filtered misspecification of U10(d), and in the misspecified classes of §7.2 and §9, the posterior's
  limit theories (σ_φ, R_k, Split_k, memorisers) are true in ℕ. The verifier then errs towards incompleteness in
  pure logic: it never accepts ∀xφ.
* Model Example 3.4 / Prop 4.2 shows that misspecification can also make the verifier accept a false sentence with
  probability 1.

---

## 12. Cross-track consistency

I read the current notes of the other tracks (`notes.md` in each; no `notes-final.md` existed). The experiments notes
were still being extended while I read them.

### 12.1 Aligned in this revision

| item | this track now | was (notes.md) | matches |
|---|---|---|---|
| posterior | π_n(T) | π(T \| D_n) | model §2 |
| generator class | C* = {T : P_T = P_{T*}} | E(T*) | model §2 |
| trichotomy | Bel, Dis, Ind, Inc; Bel + Dis + Ind = 1 + Inc | "true/false/independent", Inc not separated | model §7 |
| Hänni's variants | S_prove; S_nc,β (= S_nc at β = 1, = S_g with g ≡ 1, g(∞) = 1/β up to β^n) | Hä1, Hä2 | model §1.5 |
| best-derivation likelihood | L1-max | L2 | model's L2 is bounded depth |
| selection-aware likelihood | L1-sel(S) | same | experiments L1sel |
| guards | closed/open guard on a metavariable | same | experiments §1.1 |
| prior for countable classes | any proper prior, e.g. model's π_λ | 2^{−λ\|T\|}, improper over the full class | model Def 1.3, Lemma 1.4 |
| Dirichlet α | ½ in new checks (α = 1 as variant); old checks Laplace | Laplace | model, pa, experiments use ½ |
| verifier constant | δ/π(C*_∀) | δ/π(T*) | model Thm 4.1 |

### 12.2 Results that agree across tracks

* **Thm U2 / Thm B and experiments Prop X6, E1.** Experiments reproduce the exact factor (one bit per datum at
  c_stop = ½, i.e. c = ½) and the exact tie under L1sel for three formulas. Their L1sel limit 0.484 equals the prior
  share of H_∀ under their code, which §6.6 reproduces from their `TemplateCode` (17.18 against 17.09 bits).
* **Thm U10 and model Example 3.2 / Cor 2.3.** Model shows the ω-gap under L0. §6.1 answers its question about L1.
* **Root splits.** Model Prop 2.6(b) (exact ties with weights p_f) matches c2 (the fixed-weight root split keeps
  0.004 forever).
* **Size principle.** Model Lemma 1.8 is the exact decomposition behind U4(1). Lemma N0 is the same decomposition
  optimised over the split of mass between a head and a tail.
* **Pa §4.5.** Its two-part L1 charges ∀xφ about log₂10 bits per datum: U2's L1-max row with c = 1/10. Its "Bayesian
  ω-gap" (the split of x+0=x by head symbol, sound, not entailing ∀x(x+0=x) without Q3) is the phenomenon of N3: a
  split that excludes parameter instances and proves the universal only with Q3. Pa finds it gaining O(log n)
  because the parameter probability is learned there (½·log₂ n per unused symbol). Here ρ is fixed, and the guard is
  learned at an exponential rate (U11(d)). Both are correct for their models.
* **Experiments E3 (numerals).** Numeral data under a richer term law make the numeral split N₄ the MAP, and a
  memoriser in one seed by n = 1024. This is N3(b): with bounded split depth, memorisers eventually win. Their pool
  stops at depth 4.
* **Model Thm 4.1 and §11.** Same argument (Ville), same hypotheses.

### 12.3 Remaining differences

* **Calculi.** Model uses Mendelson's K as a tree grammar with Gen and logical axioms (α_ax, α_MP, …). This track
  uses the chain calculi C_min and C_open, and the U3 tree calculi. Experiments use a chain with at most K ≤ 2 steps
  and c_stop. Pa uses natural deduction with a two-part code. Numerical rates are not comparable across tracks; the
  qualitative statements are.
* **Elimination probability.** c = 0.3 here; c = 1 − c_stop = ½ in experiments; about 1/10 per step in pa.
* **Prior codes.** The prior share of H_∀ in {H_∀, H_sch} is 0.333 (here, and model's code at λ = 1), 0.484
  (experiments) and 0.03–0.04 (pa) (§6.6). Results that are prior shares differ accordingly.
* **Faithfulness.** Model Lemma 1.7(c) (supp P_T = Th(T)) needs parameters to be admissible, since Gen is how K
  derives some closed theorems (model referee m12). Here faithfulness is defined relative to the calculus C, and
  C_min has no Gen. The two notions agree when C = K with parameters admissible.
* **Memorisers.** Here: product-Bernoulli prior over a named universe, with the class marginal bracketed. Model: a
  prefix code over all ground templates. Experiments: only Mem(D_n), the best single memoriser.
* **Term laws.** Fixed numeral and GW laws here; a PCFG with a parameter option in experiments; a KT-learned
  positional grammar in pa.
* **Dirichlet α.** The older checks (c2–c7) use Laplace weights; the other tracks and c8–c10 use α = ½. c8 and c9
  show that their conclusions do not change with α = 1.

---

## 13. Open problems

1. **No reversal in full calculi.** Do detours through propositional rules on quantified formulas ever let instance
   data favour ∀xφ over σ_φ (ratio > 1)? The factor c is already lost (§2.3). Evidence: on the ∧-detour family the
   ratio is ≤ 0.925, and ≤ 0.48 normalised.
2. **Memoriser rates (U6(iii)).** Prove −Θ(log² n) under geometric numerals, and give the general rate in terms of
   the growth of distinct data.
3. **Full Q in U14, and the full-sum comparison at q = ½.** Does every Q-derivation of 0+S^k0 = S^k0 need Ω(k) steps
   in a standard calculus, and does the full-sum likelihood favour the schema at the default law?
4. **The race between hybrid families.** Prove that P(T ∪ Q ⊢ ∀xφ | D_n) → 1 when splits of every depth are
   available (U16(d), N3(d)). More generally, decide which family wins as a function of the waste per unit, the
   prior cost per level and α.
5. **Unknown selection in general.** U10(e) is proved for pairs (theory, filter) with a countable filter family.
   What happens when filters and templates are learned jointly in a rich class, and is N3(c) true almost surely,
   uniformly over infinitely many depths?
6. **Misspecified limits in rich classes.** Brief H2 asks what can be promised under misspecification. Here the
   limits were computed for specific families (R_k, Split_k, memorisers). Characterise the KL-minimising families
   in DT° classes for instance-only data.
7. **Multi-variable φ with mixed data**, e.g. closed in x and parametric in y. Which partial universal closures are
   licensed? Presumably the per-variable guard structure of `AS:prop:univ:capture`(e). Not checked.
8. **Hutter (2007)'s exact theorem and rate.** The full text was not reachable. §5 should be re-checked against its
   universal-prior section.
9. **Hänni's other ideas.** Only the noise mixture was treated (U2n). "Generate only a small subset of observations"
   is what L1-sel and U10(e) model. "Grade near misses" was not treated.

---

## 14. References (with verification status)

* **Hänni, K.** Notes in `research/prior/`: `hanni-solomonoff-axiom-induction.md` (the two variants; the collapse to
  function induction), `hanni-polytime-solomonoff.md`. Read in full.
* **axiom-schemas paper** (`../../../../axiom-schemas/paper/sections/`):
  * `universal.tex` and `app-universal.tex`: Prop univ:open, Prop univ:tv, Ex univ:fail, Ex univ:q, Thm univ:rates,
    Thm univ:anchor, Prop univ:capture;
  * `many.tex` and `app-many.tex`: sec:many:mdl, Prop many:mdlnaive, Prop many:mdlwell, Prop many:forall;
  * `setting.tex`: Q1–Q7.

  Read. The referee confirmed that the cited labels exist and say what is claimed.
* **inferential-learning report:** `paper/sections/caution.tex` thm:caution:ville, and `app-caution.tex`
  lem:app:caution:ville. Read; the argument is reused in §11. The referee confirmed the match.
* **Parallel tracks:** `../model/notes.md` (Def 1.3, Lemmas 1.4, 1.8, Thm 2.1, Cor 2.3, Props 2.6, 5.4, 5.5, Example
  3.2, Thm 3.1, Thm 4.1, §6, §7), `../pa/notes.md` (§1, §2, §4.5), `../experiments/notes.md` (Prop X6, E1, E3) and
  `../../../code/results/e1_universal.md`.
* **Hutter, M. (2007).** On universal prediction and Bayesian confirmation. *Theoretical Computer Science*
  384(1):33–48. doi:10.1016/j.tcs.2007.05.016; arXiv:0709.1516.
  * **Verified (web search, in `notes.md` and again by the referee):** the bibliographic data; the abstract's claim
    that the universal prior has "no zero p(oste)rior problem, i.e. it can confirm universal hypotheses"; the
    Bayes–Laplace analysis with H″ = {all future observations black} and P[H″ | 1^n] = 0.
  * **Not verified:** the full text, and the exact theorem number and rate for the universal prior.
* **Leike, J. and Hutter, M. (2015).** Solomonoff induction violates Nicod's criterion. ALT 2015, LNCS 9355.
  doi:10.1007/978-3-319-24486-0_23. Verified at the abstract level (confirmation is not stepwise monotone).
* **Gaifman, H. (1964).** Concerning measures in first order calculi. *Israel J. Math.* 2(1):1–18. Bibliographic data
  verified. The condition P(∃xψ) = sup_n P(ψ(t₁) ∨ … ∨ ψ(t_n)) is cited from memory; secondary sources state it with
  constants rather than closed terms, a harmless variant.
* **Gaifman, H. and Snir, M. (1982).** Probabilities over rich languages, testing and randomness. *J. Symbolic Logic*
  47(3):495–548. Bibliographic data verified; used only for context.
* **Doob, J. L. (1949).** Application of the theory of martingales. *Colloques Internationaux du CNRS* 13:23–27.
  Bibliographic data verified by the referee; U7 is proved here in full.
* **Tarski, A. and Vaught, R. (1957).** Via `AS:prop:univ:tv`.
* **Hoeffding, W. (1963).** Probability inequalities for sums of bounded random variables. *JASA* 58:13–30.
  Standard; from memory.
* **Watson's lemma** (Laplace's method at an endpoint). Standard; used in U12(b) for f_q = 0.
* **Schwarz, G. (1978).** Estimating the dimension of a model. *Ann. Statist.* 6(2):461–464. **Clarke, B. and
  Barron, A. (1990).** Information-theoretic asymptotics of Bayes methods. *IEEE Trans. Inform. Theory*
  36(3):453–471. Both for the (k/2)·log n Occam term; from memory, details unverified.
* **Hájek, P. and Pudlák, P. (1993).** *Metamathematics of First-Order Arithmetic.* Springer. Σ₁-completeness of Q;
  location not verified.
* **Kreisel's conjecture.** Parikh, R. (1973), Some results on the length of proofs, *Trans. AMS* 177:29–36
  (pages from the referee's search). Baaz, M. and Pudlák, P. (1993), Kreisel's conjecture for L∃1, in *Arithmetic,
  Proof Theory and Computational Complexity*, OUP. Hrubeš, P. (2007), Theories very close to PA where Kreisel's
  conjecture is false, *J. Symbolic Logic* 72(1):123–137. The last two are cited from the referee's search results
  and my memory of the titles; none of the three was opened.
* **Tenenbaum, J. and Griffiths, T. (2001).** Generalization, similarity, and Bayesian inference. *Behavioral and
  Brain Sciences* 24:629–640. The size principle; cited as in axiom-schemas.
* **Berk, R. H. (1966); Kleijn, B. J. K. and van der Vaart, A. W. (2006).** Misspecified posteriors; cited via model
  §3, not used directly.

---

## 15. Verification log

### 15.1 Referee issues and their resolution

Verdicts: **accepted** (the referee is right; fixed), **accepted in part** (fixed, with a correction to the
referee's suggested replacement, backed by evidence).

| issue | verdict | resolution | where | evidence |
|---|---|---|---|---|
| **M1** U11(e) false under L1-norm once root splits or memorisers are in the class | **accepted** | U11(e) kept as **refuted**, with the counterexample R₁. Restated as (e1) for {H_∀, H_open}, (e2) under L1-norm, (e3) under L1-sel. New exact theory: Lemma N0, Props N1 (law of R_k), N2 (KL = q^k·κ_o exactly), N3 (who wins). Summary item 5 and §11 item 4 corrected. On the referee's suggested over-Q conclusion: R_k does prove ∀xφ over Q, so P(T ∪ Q ⊢ ∀xφ) → 1 in finite classes without memorisers; with memorisers it → 0 for bounded depth and stays 1 for unbounded depth (computed) | §0 item 5, §7.2, §11 | c8 Parts 1–4; referee r3 (re-run, identical) |
| **M2** U16(b)/(c) and Summary item 7 hold only in a three-hypothesis class | **accepted in part** | Restated as a statement about that class. Exact rates for Split_k and Both0 (U16(b)). Lemma S1: every surviving finite theory proves ∀xφ over Q. The referee's "→ 0 over Q as well" holds only with bounded depth: with depth ≤ 4 memorisers win (reproduced), with depth ≤ 40 the split family wins up to n = 10¹² under four prior variants. The over-Q limit is class-dependent (conjecture: → 1 with all depths) | §0 item 7, §9 | c9 Parts 1–5; referee r4 (re-run, identical) |
| **M3** the "instance-only generator" regime exists only in calculi like C_min | **accepted** | U10(c3): restricted to C_min-like calculi, with a proof that any rule mapping instances to non-instances makes every hypothesis emit non-instances. Richer calculi: misspecified, limit set by the class (§7.2, §9). Summary item 4 rewritten with three regimes | §0 item 4, §6.1 | proof |
| **m1** memoriser prior improper at λ = 1 over all sentences; 2^{−\|T\|} improper over the full class | **accepted** | Universe named (§1.3), with the summability condition λ·occ > 1.94 for all closed instances. Countable-class theorems now assume a proper prior (e.g. model Def 1.3). c3's universes are summable, so its numbers stand | §1.3, §1.6, U6 | r6 (re-run, identical) |
| **m2** Σ₁-completeness of Q fails with < | **accepted** | Restricted to <-free Σ₁; Q ⊬ 0<S0 proved | §2.4 | r5 (2) |
| **m3** U10(c) conflates ⊢_C and ⊢ | **accepted** | Split into (c1) for ⊢_C and (c2) for ⊢, with the extra hypothesis; the referee's example worked out | §6.1 | proof |
| **m4** U10(b) "or learned weights" is outside U7 | **accepted and extended** | Prop B2 [proved]: under L1-sel with a background and a uniform weight prior, the Bayes factor → c/(c + w*(1−c))², which exceeds 1 for w* < √c/(1+√c). Thm B is now stated as (B1)–(B3), with learned weights covered under L1, L1-norm and L0-closure, and the L1-sel exception named | §4, §6.1 (b3) | c10 (b): BF at n = 10⁵ within 4·10⁻⁴ of h(w*) for four w* |
| **m5** the U12(b) table does not test the gradual shift; θ range missing | **accepted** | Recomputed with equal priors: f_q = 0 gives the constant log(1 + c + ⋯ + c^L) (proved via Watson's lemma); f_q > 0 gives slopes matching Δ(f_q) to three digits. θ range given. The old table is kept and labelled as a test of U12(a) | §8 | c10 (c) |
| **m6** U14(b) does not apply at q = ½, and §6 overstated it | **accepted** | U14(c): the full-sum condition stated with its range (fails at q = ½); a two-part version that holds at q = ½ [proved]; §6.3 restricted; the full-sum case at q = ½ added to the open problems | §6.3, §8, §13 item 3 | proof |
| **m7** U10(d) for quantified φ unproved | **accepted** | (d2): proved for the pair by the KL comparison; proof sketch in general | §6.1 | proof |
| **m8** the Remark after U3 is refuted | **accepted** | Marked **refuted** with the counterexample. The spine formula was re-derived (Catalan ansatz) and checked with an own sampler | §2.3, §13 item 1 | c10 (a): R = 0.15528 ± 0.00067 > c = 0.15 (7.9 s.e.); referee r2 (re-run, identical) |
| **m9** inconsistent hypotheses counted in Prov | **accepted** | Inc reported as a fourth outcome (model §7). The inconsistent templates of c2 are listed; Inc → 0 within a few data under every generative likelihood; the verifier uses Bel_cons | §1.6, §6.2, §11 | c10 (d) |
| **m10** over-broad wording (three places) | **accepted** | "does not prove ∀xφ" (§5); "generates exactly the instances" (§11); "some models of Q" (§0 item 6, §6.5) | §0, §5, §6.5, §11 | — |
| **m11** Summary item 1 dropped the probability qualifier | **accepted** | Threshold 3·log_{1/q} n with Borel–Cantelli: the bound holds almost surely for all large n | §0 item 1, U6(ii′) | c10 (g): exact tail ≤ n^{−2} for q = ½, 0.9, n ≤ 10⁶ |
| **Q1** unknown selection | addressed | U10(e) [proved]: with a prior over filters the ω-gap is a prior share over theories × filters | §6.1 | c10 (e): limit 0.2500 reached by n = 10 |
| **Q2** KL-minimisers in rich classes | addressed in part | Exact rates for the R_k and Split_k families and the races with memorisers (N2, N3, U16); general characterisation open | §7.2, §9, §13 item 6 | c8, c9 |
| **Q3** the MDL splitting result | addressed | §10: well-specified ties and Occam decay (mdlwell); linear wins under unmodelled selection (mdlnaive); removed by L1-sel | §10 | c2, c8, c9 |
| **Q4** prior sensitivity | addressed | Prior-share table over the project's codes: 0.03 to 0.48 | §6.6 | c10 (f) |
| **Q5** noise and near misses | addressed in part | Prop U2n (noise mixtures keep the direction; no refutation by one false datum); near-miss grading open | §2.2, §13 item 9 | c10 (h) |
| **Q6** the time penalty for this case | addressed | Prop U2t (monotone length or time penalties never reverse Thm B); remark after U14; collapse delegated to model §6 | §2.2, §8 | proof |
| **Q7** learned c | addressed | Prop U2c (factor < ½ for every c), as the referee proved | §2.2 | proof |

The referee's list of confirmed claims (U1, U2, U3 within its hypotheses, Thm B, U4, U5, U6(i)–(ii′), U7, U8,
U10(a)(b)(d), U11(a)–(d), U12(a), U13, U14(a), U15, the Ville argument) is carried over unchanged in substance.

### 15.2 Scripts and results

Each script is run as `python3 <script>` from `checks/` and writes `<script>.out`. All randomness is seeded. A second
full run of all ten scripts in a scratch directory reproduced every `.out` file byte for byte. The referee's seven
scripts (`referee_code/r1`–`r7`) were also re-run in a scratch directory and reproduced their `.out` files byte for
byte.

| script | what it checks | result |
|---|---|---|
| `c1_grammar.py` (≈1 min) | U1 identity; Z formulas; exact engine against the procedural sampler (C_min, 3 formulas × 2 laws, 2·10⁵ derivations each); C_open closed forms (U11(c)) for 4 theories | identity max deviation 5·10⁻¹⁴ on up to 63 763 outputs; Z identity exact; max \|z\| 2.35 and 1.60; ratios c, (1−ρ)/(1−gcρ), 1/(gρ) exact |
| `c2_odds.py` (≈2 min) | U2 identities asserted on every path (5 φ × 2 laws × 50 seeds × n ≤ 200 × 5 variants); U4 bound; U5 survival and gain; posterior tables | all assertions pass; U4 holds in 38/38 cases; over-specific gain log(1/p_S), survival p_S |
| `c3_memo.py` (≈75 s) | U6: memoriser log-odds, uniform and Laplace; the deterministic lower bound asserted | D_l/ln²n ≈ −2.5…−2.8 (q = ½); D_l/n ≈ −4 (GW); bound holds on every path |
| `c4_confirm.py` (≈10 s) | U8: Laplace with a point mass; dyadic family; summed-miss bound; Nicod example | closed form exact to 10⁻¹²; W_n·log₂n = 0.98 at 10⁵⁰; sums 4.22 and 2.70 ≤ 4.61; posterior ⅓ |
| `c5_open_quant.py` (≈30 s) | U10, U11 posterior tables in C_open; U12(b) closed forms asserted against the engine; spare-slot integral against its bounds | tables of §6, §7; n·I_n → 1.000 within the bounds |
| `c6_models.py` (≈1 s) | U13 model on {0..40} ∪ {a, b}; U14(a) invariant and breadth-first search, k ≤ 5 | 0 violations; a+0 = 0; shortest chains k+1; no step with \|Δw\| ≠ 1 |
| `c7_sentences.py` (≈20 s) | U16 in the three-hypothesis class, L0-closure and L1-norm | H_∀ → 0.999 (L0-closure); Split₁ → 1.000 (L1-norm) |
| `c8_noguard.py` (≈10 s) | integrator self-test against mpmath; N1 laws against the sampler of `common.py` (R₁, R₂, R₃); N2 by numerical minimisation (4 settings, k ≤ 6); N3 posteriors (paths to 10⁶; multinomial counts to 10¹²; 4 prior variants) | integrator error 9·10⁻¹³; max \|z\| 2.07; KL identity to 1.8·10⁻¹⁵; tables of §7.2 |
| `c9_sentences.py` (≈10 s) | closed-form laws of Split_k and Both0 against the generic engine; U16(b) KL formulas; posteriors in three classes (to 10⁶ on paths, to 10¹² by counts); log-odds of split family against memorisers | engine agreement 1.1·10⁻¹⁶; KL to 8.9·10⁻¹⁶; tables of §9 |
| `c10_misc.py` (≈6 s) | (a) ∧-detour counterexample; (b) Prop B2; (c) U12(b) with equal priors; (d) Inc in c2's class; (e) unknown filter; (f) prior shares; (g) Borel–Cantelli tail; (h) noise mixtures | R = 0.15528 ± 0.00067 (7.9 s.e. above c); BF → h(w*); slopes = Δ(f_q) to 3 digits; Inc → 0; limit 0.2500; shares 0.03–0.48; tails ≤ n^{−2}; noise ratios in [c, 1] and ≤ 1 |
| `common.py`, `rev_common.py` | shared code (dtrc reuse; laws, likelihoods, sampler; integrator, Dirichlet-multinomial) | `rev_common.log_int` validated in c8 |

### 15.3 Checked by proof only

* **U3.** The injectivity of the pattern map: every σ_φ-leaf in the image comes from a pattern.
* **U7.** The measurability of E_g: it is a function of the 𝔽_∞-measurable empirical limit g.
* **U10(c2), (c3), (d2), (e).** Short arguments given in §6.1; (e) reduces to U7 on pairs.
* **U14(b), (c).** The coupling with the Galton–Watson tree of rule labels (rule choice does not depend on context;
  typed grammars need the maximum of μ over contexts); the two-part leaf-cost bound.
* **Lemma S1, the provability claims of N3, Props U2n, U2t, U2c, Thm B (B2).**
* **The ∧-detour spine formula** (§2.3): derived via the Catalan ansatz. It is a proof sketch because uniqueness of the
  least fixed point as the success probability is not written out. Two independent samplers agree with it.

### 15.4 Known gaps

* Hutter (2007), Kreisel's conjecture and its literature, and the Occam-term references are not verified beyond the
  bibliographic level (§14).
* The over-general family in c2 contains only single-replacement generalisations and ?A. U4(4) covers all
  first-order generalisations.
* Memoriser rates beyond the proved lower bound are numerical (U6(iii)).
* N3(c) and U16(a) rely on standard Laplace (BIC) asymptotics without uniformity over infinitely many depths.
* N3(d) and U16(d) are computed for depth ≤ 40, n ≤ 10¹² and four prior variants. The claimed limits are conjectures.
* All misspecified limits are for specific families (R_k, Split_k, memorisers, spare slots). Other families of hybrids
  may compete in larger classes (§13 item 6).
