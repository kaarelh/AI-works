# Track "universal": Bayesian induction of ∀xφ from instances φ(t)

Brief item H4; the user's question in `../../00-brief.md`. Scripts are in `checks/` (seeded; each writes `checks/<name>.out`).
They reuse the parser and the unique first-order matcher of `../../../../axiom-schemas/code/dtrc/` (read-only).

Status markers: **[proved]** (full proof below), **[computed: script]**, **[known: reference]**, **[proof sketch]**,
**[conjecture]**, **[refuted]** (kept, with the counterexample).

---

## 0. Summary

The user's intuition is: "∀xφ is a simple law that implies the data φ(t₁), φ(t₂), …; so the data should raise its
probability, while other hypotheses stay in play." Here is what holds.

1. **Against memorisation and over-general templates the intuition is right.** Every normalised likelihood has a size
   principle. An over-general template τ loses at an exponential rate of at least log(1/P_τ(I)) nats per datum, where
   I is the set of φ-instances (Thm U4). Memorisers die too, but not always exponentially. Under a geometric numeral
   law, memorisers with learned weights keep mass at least exp(−O(log² n)) (Prop U6). An over-specific template such
   as φ(Sz) *gains* while the data fit it. It dies at the first datum outside it (Prop U5).
2. **Against the instance schema σ_φ = φ(z) the intuition fails.** The instance schema is the right competitor once
   templates are allowed, as the user proposes. On instance data the posterior odds of {∀xφ} against {σ_φ} never move
   towards ∀xφ (Thm U2):
   * they stay at the prior odds under pure citation with the closure reading (L0-closure), under a selection-aware
     derivation likelihood (L1-sel), and under both of Hänni's variants;
   * they fall by exactly a factor c per datum under a derivation likelihood (L1), where c is the probability of the
     extra ∀-elimination step. Normalised, the factor is c/(1+c) for quantifier-free φ.

   The reason is the size principle again. ∀xφ spends probability on outputs that are not observed: the sentence
   itself, and derivations that need the extra step. In the cases computed here (U2, U5, U11, U16), the size
   principle favours the hypothesis that emits the fewest unobserved outputs. On instance data that is the deductively
   weaker schema.
3. **"All future data are φ-instances" is confirmed.** Its posterior probability tends to 1 almost surely when the data
   come from a hypothesis with positive prior that emits only φ-instances (Thm U8). The rate depends on how much prior mass sits
   on near-universal competitors: 1/n for Laplace's rule with a point mass, and only 1/log n for a dyadic family with
   prior ∝ 1/j². This matches Hutter (2007) on confirming universal hypotheses. That paper's full text was not
   reachable; see §12.
4. **The Bayesian ω-gap.** The posterior identifies the data law, not the theory. As a result,
   P(T ⊢ ∀xφ | D) tends to the prior share of the provers within the class of hypotheses that fit the data equally
   well (Thm U10). Instance data give three regimes:
   * a limit strictly between 0 and 1 (L0-closure, L1-sel, Hänni's variants);
   * a limit of 0 (faithful derivation likelihoods with an instance-only generator);
   * a confidently wrong limit of 0 when the data are a filtered sample of a theory that proves ∀xφ, and the
     likelihood ignores the filter.

   Hänni's trichotomy (true, false, independent) keeps positive mass on all three outcomes in the first regime.
   In the second, it collapses onto "independent".
5. **Open instances or quantified data close the gap.**
   * One datum φ(p) at a fresh parameter makes P(T ⊢ ∀xφ | D) = 1 exactly, by Gen (Prop U11).
   * Closed data teach a closedness guard at a known rate. If the class has no guard, as in DT° with parameters
     admissible, the posterior takes the ω-step. This is the Bayesian analogue of axiom-schemas Prop univ:open.
   * Quantified data refute every theory that cannot derive them (Prop U12). Where a theory can derive them only
     slowly, each datum moves the log-odds by L·log(1/c) nats, where L is the extra derivation length.
6. **Truth is a separate question from derivability.** A credence about truth that meets the Gaifman condition tends to
   believe ∀xφ (prob → 1) given all true closed instances, provided P(∀xφ) > 0. That condition holds μ-almost surely
   exactly when M₀ ≼ M μ-almost surely (Prop U15, via axiom-schemas Prop univ:tv). So the step is truth-safe for ℕ and
   unsafe for ℝ, for V, and for models of Q.
7. **In a sentence-only class the intuition holds under pure citation, but a derivation likelihood can still undercut
   it.** Without templates, under L0-closure the posterior concentrates on ∀xφ. Under L1 the root split
   {φ(0), ∀yφ(Sy)} wins on numeral data; it does not prove ∀xφ in pure logic, but does over Q (Prop U16, computed).

Brief conjectures (H4), verdicts:

| conjecture | verdict |
|---|---|
| (a) mass leaves memorisation and over-general templates exponentially fast | **over-general: proved** (U4). **Memorisation: refuted in general.** Laplace-weighted memorisers under geometric numerals keep ≥ exp(−O(log² n)) (U6). The rate is exponential under a Galton–Watson law (computed). |
| (b) instance data do not move H_∀ : H_sch towards H_∀; constant under L0, ×c per datum under L1 | **proved** (U1–U3), with exact factors |
| (c) P(next datum is an instance) → 1 and P(all future data are instances) → 1 | **proved** (U8); rates computed |
| (d) yet P(T ⊢ ∀xφ \| D) need not → 1 (Bayesian ω-gap) | **proved** (U10), three regimes |
| (e) open instances plus Gen: H_open ⊢ ∀xφ; conditions for P(T ⊢ ∀xφ \| D) → 1 | **proved** (U11) |
| (f) quantified data shift mass to theories proving ∀xφ | **proved** (refutation); **computed** (gradual case, L·log(1/c) per datum) (U12) |

---

## 1. Setup

### 1.1 Language and instances

* **Language.** L_A has 0, S, +, ·, < and =. Closed terms have no variables and no parameters. Parameters p, w₀, …
  are free names. A datum containing a parameter is read under universal closure (closure-normal form, as in
  axiom-schemas `setting.tex`).
* **φ.** φ(x) has exactly one free variable x. It is quantifier-free in the examples:
  0+x=x, x+0=x, x·0=0, Sx≠0, x<Sx. Where stated, φ may also contain quantifiers, e.g. φ(x) = ∀y(x+y=y+x).
* **Instance sets.** I_c(φ) = {φ(t) : t closed} is the set of closed instances. I_o(φ) also allows t to contain
  parameters.
* **Instance schema.** σ_φ := φ[z/x], where z is a 0-ary term metavariable (λ-convention: the values contain no bound
  variables).

### 1.2 Term laws

Q is a probability distribution on terms. The same Q instantiates every template metavariable and supplies the term
of every ∀-elimination. This is a modelling choice. With different laws the odds in §4 acquire a factor that compares
the two laws; that factor is a statistical difference, not a logical one.

* **Numerals:** Q(S^k 0) = (1−q)q^k. The default is q = 1/2.
* **Galton–Watson (GW):** each node independently picks its root, with probability .4 for 0, .3 for S, .2 for + and
  .1 for ·, so Q(t) = ∏_nodes p(root). The mean offspring is 0.9 < 1.
* **Open setting:** Q_open = ρ·[w₀] + (1−ρ)·Q_c, where w₀ is a bare parameter. One parameter name suffices for
  one-variable φ under closure.

In both root-generated laws, Q(f(t₁…t_r)) = p_f ∏Q(t_i).

### 1.3 Hypotheses

A **theory** is a finite list of axioms with citation weights summing to 1 (fixed, or with a uniform/Dirichlet prior
on them). An axiom is a first-order template; a sentence is a template with no metavariables.

| name | axioms |
|---|---|
| H_∀ | {∀xφ} |
| H_sch | {σ_φ}, z ranging over closed terms (in the open setting: with guard closed(z), law Q_c) |
| H_open | {σ_φ}, z ranging over all terms (law Q_open); with Gen this proves ∀xφ |
| H_both | {∀xφ, σ_φ} (weight θ on ∀xφ) |
| memorisers M_F | the finite set F of sentences, uniform weights (M^u) or Laplace weights (M^l) |
| over-specific | e.g. σ_φ[z := Sz] (the first-order lgg of instances at successor numerals) |
| over-general | every template obtained from σ_φ by replacing one subterm or subformula by a fresh metavariable (this generalises a constant, or un-identifies an occurrence of z), plus the formula metavariable ?A |
| root split | {σ_φ[z := f(z₁…z_r)] : f a root symbol of Q}, with fixed weights p_f or a Dirichlet prior on them |
| background combinations | B ⊕_w A: add axiom A with weight w to B, scaling B's weights by 1−w (B = Q, or B = ∀^L∀xφ in §8) |

### 1.4 Likelihood variants

* **L0-strict (pure citation).** P_T(d) = Σ_A w_A·P_A(d), where P_A(d) = ∏_z Q(θ(z)) if d = Aθ and 0 otherwise.
  Matching is unique for first-order templates. A sentence yields only itself.
* **L0-closure.** As L0-strict, but a universal sentence ∀x̄χ is cited through its instances χ(t̄).
* **L1(c), the minimal calculus C_min = {cite, ∀-elim}.** At the root:
  * with probability 1−c, cite: choose A by weight and draw its metavariables from Q;
  * with probability c, apply ∀-elim to a recursively generated premise, with a term t ~ Q;
  * fail if the premise does not begin with ∀.

  Derivations are chains. P_T is the sub-probability of the conclusions, and Z_T is its total mass.
* **L1-norm.** P_T/Z_T.
* **C_open(c, g).** Adds Gen with probability g. Gen abstracts the parameter w₀ of the premise and fails if there is
  none. Cite then has probability 1−c−g.
* **L1-sel(S) (selection-aware).** P_T(d | S), for a set S known to contain every datum, e.g. "closed quantifier-free
  sentences" or "closed φ-instances".
* **L2 (Viterbi or two-part).** The probability of the best single derivation, max_π P(π). With prefix-free costs
  this is the two-part code. Bounded derivability (only derivations of size ≤ B count) is a further variant.
* **Hä1 ("proves the givens"; Hänni, `prior/hanni-solomonoff-axiom-induction.md`).**
  π(T | D) ∝ π(T)·1[T is consistent and T ⊢ d for all d ∈ D].
* **Hä2 ("does not contradict").** π(T | D) ∝ π(T)·1[T ∪ D is consistent]·β^{#{d ∈ D : T ⊢ d}}, with β ≥ 1. This
  follows Hänni's suggestion that the weight should depend on how many givens are proved.

### 1.5 Prior and posterior

Prior: π(T) ∝ 2^{−λ(Σ_A |A| + per-axiom cost)}, where |A| is the dtrc symbol count (de Bruijn, so ∀ costs one symbol).
The checks use λ = 1 bit and a per-axiom cost of 1; a guard costs 1 symbol. Under this convention
|∀x(0+x=x)| = 6 and |0+z=z| = 5.

The posterior is π(T | D) ∝ π(T)·∏_i P_T(d_i), for data D = (d₁, …, d_n). Stochastic statements assume i.i.d. data
from a normalised law P_{T*}.

---

## 2. The derivation grammar: exact likelihoods

**Prop U1 (factorisation) [proved; computed: c1_grammar].** This holds in C_min for any φ with one free variable,
quantifiers allowed. Write P_X for the law of the one-axiom theory {X}.

* For every sentence d ≠ ∀xφ: P_{∀xφ}(d) = c·P_{σ_φ}(d).
* P_{∀xφ}(∀xφ) = 1−c and P_{σ_φ}(∀xφ) = 0.
* Z_{∀xφ} = (1−c) + c·Z_{σ_φ}, and Z_{σ_φ} = (1−c)Σ_{k=0}^{m} c^k, where m is the number of leading ∀ of φ.
* For a background B and weight w:
  * P_{B⊕∀xφ}(d) = (1−w)P_B(d) + w·c·P_{σ_φ}(d);
  * P_{B⊕σ_φ}(d) = (1−w)P_B(d) + w·P_{σ_φ}(d).
* For k variables, ∀x₁…∀x_kφ against the k-ary schema gives a factor c^k on each full instance.

*Proof.* A derivation from {∀xφ} is a chain: cite ∀xφ, then k ≥ 0 eliminations with terms t₁, …, t_k. Its probability
is c^k(1−c)∏Q(t_j). With k = 0 it yields ∀xφ. For k ≥ 1, map it to the σ_φ-chain "cite σ_φ with z := t₁, then the
same k−1 eliminations". That chain has probability c^{k−1}(1−c)Q(t₁)∏_{j≥2}Q(t_j), which is the first probability
divided by c.

The two conclusions coincide: elim(∀xφ, t₁) = φ(t₁) = σ_φ[z := t₁], since t₁ has no bound variables, and the remaining
steps are the same. Well-typedness is preserved. The map is a bijection onto all σ_φ-chains. No σ_φ-chain yields ∀xφ,
because every conclusion has fewer logical symbols.

Summing over chains with conclusion d gives the first claim. For theories, cite factorises over axioms, so
P_T = Σ_A w_A·P_A. Z counts the well-typed chains: the leading ∀ of φ are rigid, so exactly m+1 chain lengths succeed
from σ_φ. ∎

*Check.* c1 computes the identity on every output of 200 000 sampled derivations: φ ∈ {0+x=x, Sx≠0,
∀y(x+y=y+x)}, numeral and GW laws, between 21 (numerals) and 63 763 (GW) distinct outputs each. The maximum deviation of
log P_∀ − log P_σ − log c is 5·10⁻¹⁴. The engine also agrees with an independent procedural sampler (max |z| = 2.35
over 96 comparisons).

**Thm U2 (odds on instance data) [proved; computed: c2_odds, asserted along every sampled path].** Let D consist of n
closed φ-instances, and let O_n := π(H_∀ | D)/π(H_sch | D). Then:

| likelihood | O_n / O_0 |
|---|---|
| L0-strict | 0 for n ≥ 1 (∀xφ cites only itself) |
| L0-closure | 1 |
| L1(c), sub-probability | c^n |
| L1-norm | (c·Z_σ/((1−c)+c·Z_σ))^n; for quantifier-free φ, (c/(1+c))^n |
| L1-sel(S), any S ∌ ∀xφ containing the data | 1 |
| L2 (Viterbi) | c^n |
| Hä1, Hä2 | 1 |
| background B, L1 | ∏_i r(d_i), with r(d) ∈ [c, 1]; r(d) = c whenever P_B(d) = 0 |

*Proof.* Every row is read off U1:

* **L0-strict:** P_{H_∀}(φ(t)) = 0.
* **L0-closure:** the two laws are identical by definition.
* **L1-norm:** divide by the normalisers.
* **L1-sel:** P_∀(d | S) = c·P_σ(d)/(c·P_σ(S)) = P_σ(d | S).
* **L2:** the bijection maps best chains to best chains, scaling each by c.
* **Hä1, Hä2:** both theories prove every instance (one ∀-elim; one citation) and are consistent with true data. So
  their indicator and β-factors coincide.
* **Background:** r(d) = ((1−w)P_B(d) + w·c·P_σ(d)) / ((1−w)P_B(d) + w·P_σ(d)). ∎

**Prop U3 (simulation inequality beyond C_min) [proved].** Let the calculus have cite, ∀-elim (term from Q), and any
further rules whose premises and conclusions are quantifier-free. Examples are equality rules, and propositional
rules and MP restricted to quantifier-free formulas. Each node picks its rule independently with fixed probabilities.
Let φ be quantifier-free. Then for every quantifier-free d:

  P_{B⊕∀xφ}(d) − P⁰(d) ≤ c·(P_{B⊕σ_φ}(d) − P⁰(d)) ≤ P_{B⊕σ_φ}(d) − P⁰(d),

where P⁰(d) is the probability of derivations of d that never cite the added axiom. P⁰ is the same in both theories.

*Proof.* Take a derivation of a quantifier-free d from B⊕∀xφ, and a leaf citing ∀xφ. The leaf is not the root. Its
parent accepts a premise that is not quantifier-free, and only ∀-elim does. So every such leaf sits in a pattern
"∀-elim(cite ∀xφ, t)" with conclusion φ(t).

Replace each such pattern by the leaf "cite σ_φ, z := t". The probability of the pattern is p_elim·Q(t)·p_cite·w; that
of the replacement is p_cite·w·Q(t). So each replacement divides the probability by c. The map is injective: every
σ_φ-leaf in the image came from a pattern, since B⊕∀xφ contains no σ_φ. Conclusions are preserved.

So derivations with m ≥ 1 patterns contribute Σ c^m·P(f(π)) ≤ c·Σ_{π′ citing σ_φ} P(π′). Derivations with m = 0 never
cite the added axiom, and have the same probability in both theories. ∎

So no derivation likelihood of this form lets closed instance data favour ∀xφ over its schema.

*Remark (which rules).* U3 needs "only ∀-elim takes a non-quantifier-free premise". If ∧-introduction were allowed on
quantified formulas, detours such as ∧I(∀xφ, ψ) followed by ∧E would add derivations with no σ_φ counterpart. Those
detours still cost extra steps. Whether they can ever make the inequality fail is open (§11). **[conjecture]** They
cannot.

**General φ (quantifiers, several variables).** For a φ that has quantifiers or several free variables, the
results change as follows.

* **Unchanged:** U1 and U2 in C_min (their proofs do not use quantifier-freeness), and U4 and U5 (any first-order
  templates, formula sort included).
* **k free variables:** the factor per full instance is c^k.
* **U3** was proved only for quantifier-free φ.
* **U10(d) with quantified φ:** the elimination chains of σ_φ leave S, so the filtered law is P_σ restricted to S and
  renormalised. The conclusion is the same.
* **Truth questions:** for Σ₁ formulas φ, every true closed instance is provable in Q. This is Σ₁-completeness of Q
  (known; Hájek and Pudlák 1993, cited from memory; axiom-schemas `app-universal.tex` cites it for Δ₀). So under Hä1,
  Q stays admissible for every true Σ₁ φ, and it does not prove ∀xφ in general (e.g. 0+x=x, axiom-schemas
  Ex univ:q).
* **The examples of axiom-schemas Ex univ:fail** (ℝ, V, PA + ¬Con(PA)) are the quantified and Δ₀ cases of U15.

---

## 3. Memorisation, over-general and over-specific templates: brief item (a)

**Thm U4 (size principle) [proved; computed: c2_odds].** Let the data be i.i.d. from P* with P*(I) = 1. Let P′ be a
sub-probability with P′(I) = p < 1.

1. KL(P* ‖ P′) ≥ log(1/p) > 0.
2. (1/n)·log(P′(D_n)/P*(D_n)) → −KL(P* ‖ P′) almost surely. The limit is −∞ if the KL divergence is infinite.
3. E[P′(D_n)/P*(D_n)] = P′(supp P*)^n ≤ p^n. For a family {τ} with sup_τ P_τ(I) ≤ p̄ it follows that
   E[π({τ} | D_n)/π(T* | D_n)] ≤ (π({τ})/π(T*))·p̄^n.
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

*Computed (c2).* Bound and rate for numerals with q = 1/2, exact sums:

| φ | τ | P_τ(I) | −log P_τ(I) | KL (nats) |
|---|---|---|---|---|
| 0+x=x | ?y+?z=?z | 1/2 | 0.693 | 0.693 (equality: the ratio is constant) |
| 0+x=x | 0+?y=?z | 1/3 | 1.099 | 1.386 = H(Q) |
| x<Sx | ?z<?y | 1/6 | 1.792 | 2.079 |

In all, c2 checks the bound in 38 cases: 13 by exact sums (numerals, term metavariables only) and 25 by Monte Carlo
with 2·10⁵ samples (the GW law, and formula metavariables). It holds in all of them, within two standard errors. A
template with P_τ(I) = 0 under the term law (e.g. ?y=?z on numeral data) is refuted by the first datum.

**Prop U5 (over-specific templates) [proved; computed: c2_odds].** Let τ = σ_φ[z := f(z₁…z_r)] and let Q be
root-generated. Then:

* P_τ(φ(t))/P_σ(φ(t)) = 1/p_f if root(t) = f, and 0 otherwise.
* The odds τ : σ_φ equal O_0·p_f^{−n} while all n data have root f. This event has probability p_f^n. Afterwards the
  odds are 0.
* The odds form a martingale with mean O_0.

So the size principle favours the most specific template consistent with the data. The posterior settles on σ_φ only
once the data contain an anchor, i.e. Plotkin's events (R)+(D). The probability that some single-root over-specific
template is still alive is Σ_f p_f^n. This is exactly the failure probability P_N of axiom-schemas Thm univ:rates(a).

*Proof.* Q(f(t̄)) = p_f∏Q(t_i), and τ matches φ(t) iff root(t) = f, with matcher z_i := t_i. ∎

*Computed.* Numerals, q = 1/2: the gain per datum is 0.693 = log 2 and the survival probability is 0.503. GW: 1.204 =
log(1/.3) and 0.300. In c2, for 0+x=x with numerals, the over-specific mass is 0.110 at n = 1 and 0.067 at n = 5
(L0-closure), and 0 at n = 10.

**Prop U6 (memorisers) [(i), (ii) proved; (iii) conjecture; computed: c3_memo].**

*Setting.* The prior on F is product-Bernoulli: each sentence s is included independently with probability r_s, where
Σr_s < ∞. Put Z₀ := ∏_s(1−r_s) > 0. Let S_n be the set of distinct data and m_n = |S_n|. The memoriser class is given
total prior μ.

* **(i) Bracket.** Σ_{F⊇S_n} π(F)·P^u_F(D_n) ∈ [Z₀·∏_{s∈S_n} r_s·m_n^{−n}, ∏_{s∈S_n} r_s·m_n^{−n}]. The same bracket
  holds for Laplace weights with Lap(D_n) = Γ(m)∏_sΓ(n_s+1)/Γ(n+m) in place of m^{−n}.
* **(ii) Uniform weights.** If Q has infinite support and finite entropy, the log-odds of M^u against H_sch, divided by
  n, tend to −∞ almost surely: superexponential decay.
* **(ii′) Laplace weights.** Deterministically,
  log-odds(M^l : H_sch) ≥ log(μZ₀/π_sch) + Σ_{s∈S_n} log r_s − (m_n − 1)·log(n + m_n − 1).
  Under geometric numerals, with r_s = 2^{−λ(|s|+1)}, this is ≥ −C·log² n with probability ≥ 1 − 1/n, for an
  explicit C. **So the memoriser mass is not exponentially small.**
* **(iii) [conjecture]** Under geometric numerals the log-odds are −Θ(log² n) almost surely.

*Proof.*

* **(i)** π(F) = Z₀∏_{s∈F} r_s/(1−r_s). Write F = S ∪ G.
  * The term G = ∅ gives the lower bound, using r_s/(1−r_s) ≥ r_s.
  * For the upper bound, |F|^{−n} ≤ m^{−n} and Σ_G ∏_{g∈G} r_g/(1−r_g) = ∏_{g∉S} 1/(1−r_g). The latter cancels Z₀ except
    for the factor ∏_{s∈S}(1−r_s).
  * For Laplace, adding j unused symbols multiplies Lap by ∏_{i<j}(K+i)/(n+K+i) ≤ 1.
* **(ii)** The log-odds are ≤ const − n·log m_n + Σ_i log(1/Q(t_i)). The last sum is n·(H(Q) + o(1)) almost surely,
  and m_n → ∞ almost surely.
* **(ii′)** Lap(D_n) = [1/multinom(n; n_s)]·[1/C(n+m−1, m−1)]. The multinomial coefficient is ≤ 1/ML(D_n), because the
  type class has probability ≤ 1 under the maximum-likelihood distribution. Also C(n+m−1, m−1) ≤ (n+m−1)^{m−1}. And
  ML(D_n) ≥ ∏Q(t_i) = P_sch(D_n).

  For numerals, s = φ(S^k0) has |s| = |σ| + occ·k, where occ is the number of occurrences of z. Let K_n = max k.
  Then P(K_n ≥ 2·log_{1/q} n) ≤ n·q^{2log_{1/q}n} = 1/n. On the complement, m_n ≤ K_n + 1 and
  Σ_{s∈S_n}(|s|+1) = O(K_n²). ∎

*Computed (c3; 0+x=x; 10 seeds; D_l = log-odds of Laplace memorisers against H_sch, up to O(1)).*

| law | behaviour of D_l | interpretation |
|---|---|---|
| numerals, q = 1/2 | D_l/ln²n ≈ −2.8 at n = 10³ and −2.5 at n = 10⁵; D_l/n → 0 | quasi-polynomial decay |
| numerals, q = 0.9 | D_l/ln²n from −35 (n = 10²) to −53 (n = 10⁵) | pre-asymptotic; same order |
| GW | m_n ≈ 2.2·10⁴ at n = 10⁵; D_l/n ≈ −4.0 throughout | **exponential** |

So the decay rate is governed by the growth of the number of distinct data, roughly exp(−Θ(Σ_{s∈S_n}|s| + m_n·log n)).
Uniform-weight memorisers decay superexponentially, e.g. D_u = −1.4·10⁵ at n = 10⁵ for q = 1/2.

**Verdict on brief (a).** It is proved for over-general templates (U4). **It is refuted for memorisation in general**
(counterexample U6(ii′)). Over-specific templates behave differently again: they gain until the first anchor datum.

---

## 4. Instance data never favour ∀xφ over its schema: brief item (b)

This is Thms U2 and U3 together. The precise statement:

**Thm B [proved].** Let D be any finite sequence of closed φ-instances. Then

  π(H_∀ | D)/π(H_sch | D) ≤ π(H_∀)/π(H_sch)

in the following cases.

* In C_min (any φ with one free variable), under L0-closure, L1, L1-norm, L1-sel, L2, Hä1 and Hä2. Here equality
  holds under L0-closure, L1-sel, Hä1 and Hä2. Under L1 the odds are multiplied by exactly c^n.
* In C_min for B⊕∀xφ against B⊕σ_φ, with any background B, under L1 and L1-norm. Under L1 the odds are multiplied by
  exactly c^n when B emits none of the data. Under L1-norm, use Z_{B⊕σ} ≤ Z_{B⊕∀}, which holds because Z_σ ≤ 1.
* In every calculus of U3 (quantifier-free φ), under unnormalised L1, L2, Hä1 and Hä2.

Under L0-strict H_∀ is refuted outright. Two cases are not covered:
* normalised likelihoods in the richer calculi of U3, where the normalisers were not compared;
* normalised bounded-size likelihoods. The bijection of U1 maps chains of size s to size s−1, so the unnormalised
  bounded likelihood still satisfies P_∀(d) ≤ c·P_σ(d) on instances.

**Total prover mass under L1 [proved; computed: c5_open_quant Part C].** Take the class {H_sch, H_∀, H_both}, with a
uniform prior on H_both's weight θ, L1-norm, quantifier-free φ, and instance data. Then H_both's likelihood relative to
H_sch is I_n = ∫₀¹ ((1−θ(1−c))/(1+θc))^n dθ, and 1/(n+1) ≤ I_n ≤ 1/(n(1−c)).

So P(T ⊢ ∀xφ | D_n) → 0 like Θ(1/n). It is not exponential: H_both is a "spare slot", and the brief's H5 applies.

*Proof.* Under L1-norm, H_both(θ) gives φ(t) probability (1−θ+θc)·Q(t)/(1+θc) (U1, with Z = (1−c)(1+θc)). For the
lower bound, (1−θ+θc) ≥ (1−θ)(1+θc), because the difference is θ²c ≥ 0; so I_n ≥ ∫(1−θ)^n = 1/(n+1). For the upper
bound, the integrand is ≤ (1−θ(1−c))^n ≤ e^{−nθ(1−c)}. ∎

Computed: n·I_n = 0.958, 0.996 and 1.000 at n = 10, 10², 10⁵.

*Computed (c2; 0+x=x; numerals q = 1/2; mean posterior over 50 seeds).* The class is H_∀, H_sch, four over-general
templates, the over-specific φ(Sz), and the root split (fixed and Laplace weights).

| likelihood | hypothesis | n = 0 | 1 | 5 | 20 | 200 |
|---|---|---|---|---|---|---|
| L0-closure (= L1-sel) | H_∀ | 0.021 | 0.194 | 0.303 | 0.332 | 0.332 |
| | H_sch | 0.042 | 0.387 | 0.605 | 0.665 | 0.665 |
| | over-general | 0.926 | 0.307 | 0.022 | 0.000 | 0.000 |
| L1 | H_∀ | 0.021 | 0.067 | 0.001 | 0.000 | 0.000 |
| | H_sch | 0.042 | 0.448 | 0.891 | 0.996 | 0.996 |
| L1-norm | H_∀ | 0.021 | 0.053 | 0.000 | 0.000 | 0.000 |

* Under L0-closure the ratio H_∀ : H_sch stays at the prior ratio 1/2 (6 symbols against 5).
* Under L1, H_sch saturates at 0.996 rather than 1. The remaining 0.004 is the fixed-weight root split, which has the
  same law as H_sch.
* The other four formulas and the GW law behave the same way (`checks/c2_odds.out`).

*Where could the other direction come from?* Only from non-logical differences. One is a ∀-elim term law different
from the schema's instantiation law. Another is a prior that favours the sentence. Neither is evidence that the
axioms prove ∀xφ.

---

## 5. Predictive confirmation: brief item (c)

**Lemma U7 (Doob's consistency theorem, countable class) [proved; known: Doob 1949].** Let H be countable, and let each
P_T be a probability on a countable data space. Data are i.i.d. Write E(T) = {T′ : P_{T′} = P_T}. For every T* with
π(T*) > 0, P_{T*}-almost surely:

  π(T | D_n) → π(T)·1[T ∈ E(T*)]/π(E(T*)) for every T, and the convergence is in total variation.

*Proof.*

* **Setup.** Work on the joint space of (θ, D_∞), with measure Π = Σ_T π(T)·δ_T ⊗ P_T^∞. Then
  π(T | D_n) = Π(θ = T | 𝔽_n). By Lévy's upward theorem it converges almost surely to q_T := Π(θ = T | 𝔽_∞),
  simultaneously for the countably many T.
* **Identification.** Let g(D_∞) be the limit of the empirical frequencies. By the strong law of large numbers over
  countably many points, g = P_T almost surely under P_T^∞. So the event {P_θ = g} has Π-probability 1.

  Put E_g := {T : P_T = g}. It is 𝔽_∞-measurable, so Π(θ ∈ E_g | 𝔽_∞) = Σ_{T∈E_g} q_T. This variable is ≤ 1 and has mean
  Π(θ ∈ E_g) = 1, hence equals 1 almost surely.
* **Shape of the limit.** Within E_g all likelihoods coincide at every n, so π(T | D_n)/π(T′ | D_n) = π(T)/π(T′).
  Hence q_T = π(T)/π(E_g) on E_g and 0 elsewhere.
* **Conclusion.** Pointwise convergence of probability mass functions to a mass function gives total-variation
  convergence (Scheffé). An event of Π-probability 1 has P_T^∞-probability 1 for each T with π(T) > 0, and E_g = E(T)
  on that slice. ∎

**Thm U8 (predictive confirmation) [proved; computed: c4_confirm].** Let M(· | D_n) = Σ_T π(T | D_n)·P_T(·) be the
posterior predictive. Let G := {T : P_T(I) = 1}, and suppose T* ∈ G.

1. Σ_{n≥0} E_{T*}[1 − M(I | D_n)] ≤ ln(1/π(T*)). Hence P(next datum ∈ I | D_n) → 1 almost surely, and the misses are
   summable.
2. P(all future data ∈ I | D_n) = π(G | D_n). This tends to 1 almost surely.
3. E_{T*}[1 − π(G | D_n)] ≤ min(1, Σ_{T∉G} (π(T)/π(T*))·P_T(supp P_{T*})^n).
4. Suppose every T ∈ G has law P̂ (so P̂(I) = 1), and every T ∉ G has the form (1−ε_T)·P̂ + ε_T·N with N(I) = 0. Then,
   for every sequence of instances,
   1 − π(G | D_n) = Σ_{T∉G} π(T)(1−ε_T)^n / (π(G) + Σ_{T∉G} π(T)(1−ε_T)^n).

*Proof.*

1. By the chain rule, Σ_{n<N} E[KL(P* ‖ M(· | D_n))] = E[ln(P*(D_N)/M(D_N))] ≤ ln(1/π(T*)), since
   M ≥ π(T*)·P*. Push forward to the indicator of I: KL ≥ ln(1/M(I | D_n)) ≥ 1 − M(I | D_n).
2. P_T(I)^∞ is 1 for T ∈ G and 0 otherwise. Then U7 applies, since E(T*) ⊆ G.
3. Bound 1 − π(G | D_n) by min(1, Σ_{T∉G} π(T | D_n)/π(T* | D_n)), and use U4(iii) for each T.
4. The instance factors cancel. ∎

*Computed (c4).*

* **Bayes–Laplace with a point mass.** Take π₀ at ε = 0 and Uniform(0,1) on ε. Then
  P(all future instances | n) = π₀/(π₀ + (1−π₀)/(n+1)); this was checked by quadrature. So 1 − P ≈ (1−π₀)/(π₀n).
  Without the point mass (π₀ = 0), P(all future) = 0 for every n, while P(next m all instances | n) = (n+1)/(n+m+1).
* **A dyadic family.** Take ε_j = 2^{−j} with prior ∝ 1/(j(j+1)), and π₀ = 0.01. Then
  W_n·log₂n rises from 0.80 (n = 10) to 0.98 (n = 10⁵⁰); its limit is 1 − π₀ = 0.99. Here W_n is the
  prior-weighted survival of the noisy hypotheses. Also
  1 − P(all future | n) = W_n/(π₀ + W_n) is still 0.37 at n = 10⁵⁰. Confirmation is very slow when the prior has
  much mass on near-universal hypotheses.
* **Item 1.** Σ_n(1 − M(I | D_n)) = 4.22 (Laplace) and 2.70 (dyadic), both ≤ ln(1/π₀) = 4.61.
* **Not monotone.** With prior 1/2 on σ_φ and 1/2 on φ(Sz), the datum φ(S0) *lowers* the posterior of σ_φ to 1/3.
  This is a Nicod-type non-monotonicity, compare Leike and Hutter (2015). Confirmation is asymptotic, not stepwise.

**Comparison with Hutter (2007) [known: Hutter 2007; verification partial, see §12].**

* **What Hutter shows.** The Bayes–Laplace model gives the universal hypothesis zero prior, hence zero posterior.
  Its "observable" form H″ = {all future observations black} also gets P(H″ | 1^n) = lim_k (n+1)/(n+k+1) = 0. The
  universal prior has no zero-p(oste)rior problem and confirms universal hypotheses.
* **What is shared.** U8(2) is the analogue for a countable class of i.i.d. laws: G is our H″. The mechanism is the
  same: positive prior mass on hypotheses that emit only instances.
* **What is ours.**
  * Rates that depend on the near-universal competitors (U8(3) and (4)).
  * A sharp distinction: G is not the event "the axioms prove ∀xφ". G contains H_sch, which proves no universal
    sentence. Confirming H″ is not confirming the sentence ∀xφ as an axiom or a theorem (§6).

---

## 6. The Bayesian ω-gap, and truth versus derivability: brief item (d) and task 4

**Thm U10 (Bayesian ω-gap) [proved; computed: c2_odds, c5_open_quant].** Let H be countable with π > 0, and let
Prov := {T ∈ H : T ⊢ ∀xφ}. Let the data be i.i.d. from P_{T*}, T* ∈ H.

* **(a) General limit.** P(T ⊢ ∀xφ | D_n) → π(Prov ∩ E(T*))/π(E(T*)) almost surely.
* **(b) Prior-share regime.** Suppose E(T*) contains a prover and a non-prover. This happens under L0-closure and
  under L1-sel for H_∀ and H_sch, by U2. With a background B it needs equal mixture laws, e.g. B = ∅, or learned
  weights. Then the limit lies strictly between 0 and 1.

  Hänni's trichotomy limit (P(true), P(false), P(independent)) is the vector of prior shares within E(T*). All three
  are positive if E(T*) also contains a theory that refutes ∀xφ. Under L1-sel, an example is {σ_φ, ∃x(0+x≠x)}, with S
  excluding the second sentence; it is consistent, by ℕ ∪ {a} with 0+a ≠ a. Under L0-closure such a theory spends
  mass on ∃x¬φ and drops out. Hä1 and Hä2 are not i.i.d. data models; they are treated below by continuity of
  measure, with the same conclusion.
* **(c) Faithful regime.** Call a likelihood **faithful** if supp P_T = Thm_C(T) ∩ X for each T: every C-theorem in the
  data space has positive probability, and nothing else does. Then every T ∈ E(T*) has the same C-theorems in X as T*.
  So if ∀xφ ∈ X, the limit is 1[T* ⊢_C ∀xφ].
  * L1-norm over C_min with a full-support Q is faithful for ⊢_{C_min}.
  * With a complete calculus and a full-support grammar, the posterior identifies the deductive closure of T* (on X).
    The gap disappears **when the data are an unselected sample of the generator's theorems.**
  * With an instance-only generator (T* = H_sch), the limit is 0, and the trichotomy collapses onto "independent".
* **(d) Filtered data, misspecified.** Let the true generator be T° = H_∀, which proves ∀xφ, and let the analyst see
  only its outputs in S = closed φ-instances. In C_min the filtered law P_{T°}(· | S) equals P̃_{H_sch} exactly (U1).
  * With the unconditional faithful likelihood (L1-norm), P(T ⊢ ∀xφ | D_n) → 0. The posterior confidently concludes
    "the axioms do not prove ∀xφ", from data that were filtered.
  * With the selection-aware L1-sel, the limit is the prior share, as in (b).

*Proof.*

* (a) is U7, summed over Prov.
* (b): both theories lie in E(T*); one is in Prov and the other is not (by hypothesis).
* (c): T ∈ E(T*) implies supp P_T = supp P_{T*}, hence equal theorem sets on X.
* (d): P_∀(· | S) = c·P_σ(· ∩ S)/(c·P_σ(S)) = P_σ(· | S) = P̃_σ, because supp P_σ = I_c ⊆ S for quantifier-free φ.
  Then apply (c) with T* := H_sch. ∎

*Computed (c5 Part A).* φ = 0+x=x, C_open with c = .3, g = .2 and ρ = .1. Data are closed instances; this is also
H_∀'s output filtered to closed instances. Class: {H_∀, H_open, H_sch (guarded), H_both}. Prior share of the provers:
0.750.

| likelihood | P(T ⊢ ∀xφ \| D_n): n = 0 | n = 10 | n = 50 | n = 100 |
|---|---|---|---|---|
| L1-norm | 0.750 | 0.364 | 0.004 | 0.000 |
| L1-sel | 0.750 | 0.750 | 0.750 | 0.750 |

**Hänni's two variants on Q ⊬ ∀x(0+x=x) [proved].** These use axiom-schemas Ex univ:q. That example gives a model of Q
on ℕ ∪ {a, b}, standard on ℕ, with 0+a = b. So Q proves every closed instance 0+t=t, while Q, Q + ∀x(0+x=x) and
Q + ∃x(0+x≠x) are all consistent with every closed instance.

* **Hä1 ("proves the givens").** The admissible set Adm_n = {T consistent, T ⊢ D_n} decreases to
  Adm_∞ = {T : T ⊢ I_c(φ)}. Under a full-support Q, every closed instance eventually appears almost surely. By
  continuity of measure, π(· | Adm_n) → π(· | Adm_∞) in total variation.

  Adm_∞ contains Q (independent), Q + ∀x(0+x=x) (true), Q + ∃x(0+x≠x) (false), H_sch (independent) and H_∀ (true). It
  also contains every consistent over-general template that proves the instances (e.g. 0+z₁=z₂ alone, which has a
  one-element model). In the trichotomy, "true" means T ⊢ ∀xφ and "false" means T ⊢ ¬∀xφ. So all three trichotomy values keep positive mass, and over-generalisations are never
  penalised. **Hä1 has no size principle.**
* **Hä2 ("does not contradict").** Theories that prove all the data share the factor β^n. Their mutual odds stay at
  the prior odds. The trichotomy again keeps positive mass on true, false and independent.
* **With a derivation likelihood (L1), instance-only data.** Theories that prove or refute ∀xφ spend mass on unobserved
  outputs (∀xφ, or ∃x¬φ) and lose. So "independent" takes all the mass (U10(c)). Among the independent theories, Q is
  penalised by its long derivations of 0+S^k0=S^k0 (U14). So the posterior favours the schema.

**Prop U13 (an ω-gap for an axiom we actually have) [proved; computed: c6_models].** (Q − Q4), together with all closed
instances of x+0=x, does not prove ∀x(x+0=x). Here Q4 is x+0=x.

*Proof.* Take the structure on ℕ ∪ {a, b}, standard on ℕ, with:

* **successor:** Sa = a, Sb = b;
* **addition:** a + m = m and b + m = b (m ∈ ℕ); x + a = a for x ∈ ℕ ∪ {a}; b + a = b; x + b = b for every x;
* **multiplication:** x·0 = 0 for every x; a·m = a and b·m = b (m ≥ 1); n·a = n·b = b (n ≥ 1); 0·a = 0·b = 0;
  a·a = a·b = a; b·a = b·b = b.

Each axiom of Q other than Q4 checks by cases.

* **S is injective; 0 is not a successor; every x ≠ 0 is a successor.** S is the identity on {a, b} and n ↦ n+1 on ℕ.
* **Q5: x+Sy = S(x+y).**
  * For y = m: if x = a, then a+(m+1) = m+1 = S(a+m); if x = b, both sides are b.
  * For y ∈ {a, b}: Sy = y, and every x+y lies in {a, b}, which S fixes.
* **Q6** holds by definition.
* **Q7: x·Sy = x·y + x.**
  * y = m: a·(m+1) = a = a·m + a, using a + a = a and 0 + a = a. b·(m+1) = b = b·m + b.
  * y ∈ {a, b}, so Sy = y: we need z + x = z for z := x·y. Case by case:
    * x = 0: z = 0, and 0+0 = 0;
    * x = n ≥ 1: z = b, and b + n = b;
    * x = a: z = a, and a + a = a;
    * x = b: z = b, and b + b = b.

All closed terms denote standard numbers, so every closed instance n+0=n holds. But a+0 = 0 ≠ a. ∎

c6 checks all the axioms on {0..40} ∪ {a, b} with no violations.

So for Q4 itself, closed-instance data cannot tell "the axiom is ∀x(x+0=x)" from "the axiom is the schema x+0=x at
closed terms", and over Q − Q4 these differ in their theorems. The question "does the method pick up the axioms we
actually have?" has no data-determined answer from closed instances alone.

**Prop U15 (truth: the Gaifman condition is the probabilistic ω-rule) [proved; known: Gaifman 1964 for the
condition].** Let μ be a probability on L-structures, or on complete theories, and P(ψ) := μ{M : M ⊨ ψ}. Let
t₁, t₂, … enumerate the closed terms.

1. P(∀xφ | φ(t₁) ∧ … ∧ φ(t_n)) → P(∀xφ)/μ{M : M ⊨ φ(t) for all closed t}.
2. The **Gaifman condition** for φ is P(∀xφ) = inf_n P(∧_{i≤n} φ(t_i)). It holds for every φ with one free variable
   iff μ-almost every M satisfies "M ⊨ ∀xφ iff M ⊨ φ(t) for all closed t", for every such φ. Iterating over the
   variables gives the many-variable version. By axiom-schemas Prop univ:tv (Tarski–Vaught), this is iff M₀ ≼ M for
   μ-almost every M.
3. Under the Gaifman condition, with P(∀xφ) > 0, the limit is 1. With P(∀xφ) = 0 it is 0 for every n: the zero-prior
   problem.

*Proof.*

1. ∀xφ entails each instance, so P(∀xφ ∧ conjunction) = P(∀xφ). The conjunctions decrease to the event "all closed
   instances", by continuity of μ. If that event has μ-measure 0, then P(∀xφ) = 0 and every term of the sequence is 0.
2. The difference between the two sides is μ{M : all closed instances hold but M ⊭ ∀xφ}. This vanishes for every φ
   iff μ-almost every M satisfies (i) of Prop univ:tv (there are countably many φ). ∎

**So what should a Bayesian believe about ∀xφ when the data are true closed instances?** Three questions need
separating.

* **Truth in ℕ.** If the credence ranges over term-generated or ω-like worlds (M₀ ≼ M), believe ∀xφ in the limit,
  provided its prior is positive. This is safe for ℕ and unsafe for ℝ (¬(x·x = 1+1)), for V, and for models of
  PA + ¬Con(PA) (axiom-schemas Ex univ:fail).
* **Future data.** Believe that all future data will be instances (U8).
* **Which axioms the data-producer uses, or what they prove.** Closed instances alone do not decide this. The honest,
  selection-aware posterior keeps the prior odds (U10(b)). A naive derivation likelihood moves towards "does not
  prove ∀xφ" (U10(c), (d)).

---

## 7. Open instances and Gen: brief item (e)

**Prop U11 [proved; computed: c1_grammar, c5_open_quant].** Assume the closure reading, a calculus with Gen over
parameters, theories without parameters, and a likelihood supported on theorems (P_T(d) > 0 ⇒ T ⊢ d).

* **(a) One datum suffices.** Once D contains φ(p) for a parameter p, every T with π(T | D) > 0 proves ∀xφ. So
  P(T ⊢ ∀xφ | D) = 1 exactly.
* **(b) Waiting time.** If P_{T*}(φ(p)) = β > 0, then P(P(T ⊢ ∀xφ | D_n) < 1) ≤ (1−β)^n.
* **(c) Exact laws in C_open(c, g) with Q_open = ρ[w₀] + (1−ρ)Q_c.** Put K = 1−c−g.
  * For the three axiom types with weights (w_∀, w_open, w_sch):
    * P(∀xφ) = a = K(w_∀ + gρw_open)/(1−gcρ);
    * P(φ(w₀)) = ρ(Kw_open + ca);
    * P(φ(t)) = Q_c(t)·[(1−ρ)(Kw_open + ca) + Kw_sch] for closed t;
    * Z = a(1+c) + K(w_open + w_sch).
  * Unnormalised ratios:
    * P_∀/P_open = c at every instance, and 1/(gρ) at ∀xφ;
    * P_open/P_sch = (1−ρ)/(1−gcρ) at closed instances.
  * Normalisers: Z_open = K(1+gρ)/(1−gcρ), Z_∀ = K(1+c)/(1−gcρ), Z_sch = K.
  * Hence, per closed datum under L1-norm:
    * open/sch = (1−ρ)/(1+gρ);
    * ∀/sch = c(1−ρ)/(1+c);
    * ∀/open = c(1+gρ)/(1+c).
* **(d) Closed data teach the guard.** If the class contains the guarded H_sch, then on closed data
  P(T ⊢ ∀xφ | D_n) → 0. The masses of H_open and H_∀ decay exponentially, at the per-datum factors above. A spare-slot
  prover such as H_both (∀xφ plus the guarded schema, with a learned weight) decays only like 1/n (§4).
* **(e) Without a guard the posterior takes the ω-step.** Suppose the class has no guard, as in DT° under the
  λ-convention with parameters admissible. Then H_open wins on closed data (by (1+c)/(c(1+gρ)) per datum against H_∀,
  under L1-norm), and every surviving hypothesis proves ∀xφ: the posterior takes the ω-step.

  This is the Bayesian counterpart of axiom-schemas Prop univ:open(b) and (c). The cautious verifier takes the step
  silently, and a closedness guard prevents it. Here the guard is learned by the size principle, at rate
  log((1+gρ)/(1−ρ)) per datum.

*Proof.*

* **(a)** P_T(D) > 0 implies T ⊢ φ(p). Since p occurs in no axiom, Gen gives T ⊢ ∀xφ.
* **(b)** On the event that φ(p) has appeared, (a) applies.
* **(c)** The outputs are only ∀xφ, φ(w₀) and φ(t). Gen on a closed formula fails, and elim on a quantifier-free φ
  fails. So a = Kw_∀ + g·P(φ(w₀)) and P(φ(x)) = Q_open(x)(Kw_open + ca) + [x closed]·K·w_sch·Q_c(x). Solving gives the
  formulas. The ratios use Z_open = K(1+gρ)/(1−gcρ), Z_∀ = K(1+c)/(1−gcρ) and Z_sch = K.
* **(d)** and **(e)** follow from (c) and U7. ∎

*Checks.*

* c1 compares (c) with a procedural sampler (200 000 derivations per theory, max |z| = 1.60). Exact ratios printed:
  forall/open = 0.3000, open/sch = 0.9054 (unnormalised, (1−ρ)/(1−gcρ)), and forall/open at ∀xφ = 50.0 = 1/(gρ).
  c5 prints the normalised ratios 0.2077 = c(1−ρ)/(1+c), 0.8824 = (1−ρ)/(1+gρ) and 0.2354 = c(1+gρ)/(1+c).
* c5 Part A (prior share 0.75):

| stream | class | n = 0 | 10 | 50 | 100 |
|---|---|---|---|---|---|
| closed data, L1-norm | full | 0.750 | 0.364 | 0.004 | 0.000 |
| closed data, L1-norm | no guard (H_open wins) | 1.000 | 1.000 | 1.000 | 1.000 |
| output of H_open | full | 0.750 | 0.860 | 1.000 | 1.000 |
| output of H_∀ | full | 0.750 | 1.000 | 1.000 | 1.000 |

---

## 8. Quantified data, derivation length and lemmas: brief item (f)

**Prop U12 [(a) proved; (b) proved in the toy, computed: c5_open_quant Part B; (c) proof sketch].**

* **(a) Refutation.** If d ∈ D and B ∪ I_c(φ) ⊬ d, then under any likelihood supported on theorems, B⊕σ_φ has posterior
  0 from then on.

  *Example:* B = Q and d = ∀y(0+Sy = Sy). In the model of axiom-schemas Ex univ:q, Sa = a and 0+a = b, so
  0+Sa = b ≠ a = Sa; hence Q + I_c ⊬ d. Conversely Q + d ⊢ ∀x(0+x=x): if x = 0 use Q4; otherwise Q3 gives x = Sy and
  d gives 0+Sy = Sy. So among theories extending Q, one quantified datum leaves only provers of ∀xφ.
* **(b) Gradual shift, when every theory proves ∀xφ but at different cost.** Take C_min and B = ∀^L∀xφ: L vacuous
  quantifiers, so ∀xφ needs L extra eliminations. The theories T_sch+B = {B, σ_φ} and T_both = {∀xφ, σ_φ} both carry a
  Laplace weight θ. For each datum ∀xφ:

  log P_{T_both(θ)} − log P_{T_sch+B(θ)} = L·log(1/c) + log(Z_B(θ)/Z_both(θ)).

  The second term is small; computed: 3.618 against L·log(1/c) = 3.612 for L = 3, and 12.046 against 12.040 for
  L = 10. Instance data cost the two theories almost the same (≤ 0.1 nats per datum).

  With quantified data at frequency f_q > 0, T_both takes the mass. With f_q = 0, T_sch (= H_sch) takes it.
* **(c) Lemmas become axioms; the derivation likelihood tracks usage.** In the two-part (L2) form, adding a derived
  sentence ψ as an axiom changes the code length by:
  * + prior bits for ψ;
  * + a dilution cost, O(log n) with learned weights;
  * − Σ_{d∈D}(ℓ_T(d) − ℓ_{T+ψ}(d))·log(1/c), where ℓ is derivation length.

  So frequently used lemmas become axioms, and rarely used ones are dropped. The posterior identifies the
  data-producer's working set of primitives, not a canonical axiomatisation.

  This is the axiom-schemas MDL finding (sec:many:mdl: "MDL tracks the statistics of usage, not the logical
  boundaries of schemas"). The derivation likelihood does not remove it; it sharpens it. U16 below is another
  instance: frequent instances get cited directly.

*Proof of (b).* For a two-axiom theory with weight θ on B, C_min chains from B yield B, then ∀^{L−1}∀xφ, …, ∀xφ (after
L eliminations), then φ(t). So P(∀xφ) = (1−c)θc^L and P(φ(t)) = (1−c)[(1−θ) + θc^{L+1}]Q(t), with
Z_B = (1−c)[θΣ_{k≤L+1}c^k + 1−θ]. For T_both, P(∀xφ) = (1−c)θ and Z_both = (1−c)(1+θc). Take the difference. c5
checks these forms against the generic engine at three values of θ. ∎

*Computed (c5 Part B; mean posterior over 40 seeds; L = 3; same for L = 10).*

| f_q | quantity | n = 10 | 50 | 200 | 1000 |
|---|---|---|---|---|---|
| 0 | mass(T_sch) | 1.000 | 1.000 | 1.000 | 1.000 |
| 0.01 | P(T ⊢ ∀xφ) | 0.075 | 0.300 | 0.875 | 1.000 |
| 0.05 | P(T ⊢ ∀xφ) | 0.450 | 0.975 | 1.000 | 1.000 |

The winner is T_both in each case with f_q > 0. P(T ⊢ ∀xφ) tracks the probability that some quantified datum has
appeared, 1 − (1−f_q)^n, within Monte Carlo error.

**Prop U14 ("statements given without proof should be easily derivable": Q alone) [(a), (b) proved; (a) computed:
c6_models; extension to full Q: conjecture].**

* **(a) Equational lower bound.** In equational logic over E = {Q4: x+0=x, Q5: x+Sy=S(x+y)}, any instances,
  every derivation of 0+S^k0 = S^k0 has at least k+1 axiom-instance leaves.
* **(b) Tail bound.** Suppose each node of a derivation grammar picks its rule independently, with at most 2 premises
  and mean number of premises μ < 1. Then P(the derivation has ≥ L nodes) ≤ exp(−(L−1)(1−μ)²/2).

  Hence P_E(0+S^k0 = S^k0) ≤ exp(−k(1−μ)²/2). Compare P_{E⊕σ}(0+S^k0 = S^k0) ≥ p_cite·w·(1−q)q^k under geometric
  numerals. When q > e^{−(1−μ)²/2}, the log-odds favour the schema by Ω(k) per datum. In the two-part form,
  ℓ_E ≥ (k+1)·(minimum leaf cost) holds unconditionally. The schema's cost is O(1) + k·log(1/q), so the schema wins by
  Ω(k) whenever the minimum leaf cost exceeds log(1/q).

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
  that tree and the term draws. Explore the tree depth-first. With ξ_i the premise counts, the number of nodes is ≥ L
  only if Σ_{i<L}(ξ_i − 1) ≥ 0. Apply Hoeffding's inequality to ξ_i − 1 ∈ [−1, 1], which has mean μ − 1. ∎

*Computed.* A breadth-first search over all terms of size ≤ |0+S^k0| + 4 gives shortest chains of exactly k+1 for
k ≤ 5. Every explored step changed w by ±1.

*Remark (the time penalty).* In this case checking axiomhood is linear in the size for every hypothesis considered
(unique matching). The only cost that separates hypotheses is derivation length, and the derivation likelihood already
charges it. A Levin-style Kt penalty (log of running time) on generating 0+S^k0 = S^k0 from E would charge only
O(log k). That is weaker than the derivation-length charge Ω(k) of (a). So the time penalty adds nothing here.

---

## 9. Without templates: the sentence-only class

**Prop U16 [computed: c7_sentences; (b) proved; (a) proof sketch].** Hypotheses are finite sets of sentences: H_∀,
Split = {φ(0), ∀yφ(Sy)}, and Both0 = {φ(0), ∀xφ}. The two-axiom theories carry a Laplace weight. Data are numerals with
q = 1/2, and φ is 0+x=x.

* **(a) L0-closure.** The posterior concentrates on H_∀: 0.999 at n = 500.

  *Proof sketch.* Split equals H_∀ in law only at the single weight θ = 1−q. With a continuous prior on θ its marginal
  likelihood relative to H_∀ is O(n^{−1/2}). With fixed matched weights it would keep its prior share forever.
* **(b) L1-norm.** Split wins: 0.974 at n = 20, 1.000 at n = 100. Under C_min with Split's weight θ on φ(0), the
  per-datum ratios against H_∀ are:
  * at φ(0): θ(1+c)/[(θ + (1−θ)(1+c))·c·(1−q)];
  * at φ(St): (1−θ)(1+c)/[(θ + (1−θ)(1+c))·q].

  At θ = 1/2, c = .3, these are 3.77 and 1.13, i.e. 0.72 nats per datum on average. Split cites the most frequent
  instance directly, and its universal emits only successor instances.
* **(c) Status of Split.** In pure logic Split ⊬ ∀xφ: add an element that is neither 0 nor a successor. Over Q it does
  prove ∀xφ, by Q3. So P(T ⊢ ∀xφ | D_n) → 0 in pure logic and = 1 over Q (c7).

So removing templates removes the schema competitor, as the user proposes. Under pure citation the intuition then holds
exactly. Under a derivation likelihood the size principle still finds a more specific sentence-level generator. Whether
it proves ∀xφ depends on the background axioms.

*Remark (Kreisel's conjecture) [flagged: cited from memory, not verified].* The idea "all instances have short
derivations, so ∀xφ is derivable" is close to Kreisel's conjecture. That conjecture says: if PA proves every φ(S^n0)
with proofs of a bounded number of steps, then PA ⊢ ∀xφ. To my knowledge it is open for standard formalisations, with
special cases settled (e.g. Parikh 1973). Split shows that the naive version fails without background axioms such as
Q3: every numeral instance is derivable in at most one step, and ∀xφ is not.

---

## 10. The user's intuition, precisely

The intuition reads: "∀xφ is a simple law which implies all the other statements … once we see them, we should up its
probability … still entertaining other hypotheses."

**In what sense it is right.**

1. **Against hypotheses that fit the data worse.** Any normalised likelihood rewards a hypothesis that generates the
   data from a short description and does not spread mass widely. The law beats memorisation (U6) and over-general
   templates (U4) once data accumulate. This is Bayesian Occam, i.e. the size principle.
2. **As prediction.** "All future data will be φ-instances" gains probability → 1. That requires positive prior mass on
   instance-only hypotheses, which a countable template prior gives and Laplace's rule does not (U8; Hutter 2007).
3. **As truth in a term-generated structure.** If the question is "is ∀xφ true in ℕ", a Gaifman-type credence believes
   it in the limit, and this is safe for ℕ (U15).
4. **Without templates, under pure citation, as stated.** ∀xφ takes the posterior (U16(a)).

**Where it needs refinement.**

1. **∀xφ is not the only simple law that implies the data.** Its instance schema implies exactly the data and nothing
   more. The data cannot raise ∀xφ relative to it (Thm B). A derivation likelihood even lowers ∀xφ by c per datum.
   The theories that remain in play forever are not memorisers but predictively equivalent, deductively weaker
   theories: σ_φ, and background theories such as Q that prove each instance. Templates, which the user proposes to
   block Hänni's collapse, are exactly what bring σ_φ into the class.
2. **"Up its probability" covers three different propositions.**
   * "Future data are instances": this goes up (U8).
   * "∀xφ is true": this goes up only under a Gaifman-type prior, and is truth-safe only where M₀ ≼ M (U15).
   * "The axioms prove ∀xφ": this does not go up from closed instances (U10).
3. **The simplicity that matters is that of the generator.** A derivation likelihood rewards the most specific
   generator (U5, U16) and frequently used lemmas (U12(c)). It does not reward the logically strongest law.
4. **Data that do license ∀xφ:**
   * one instance at a parameter (U11);
   * quantified consequences, which refute or outweigh the weaker theories (U12);
   * or a class with no guard, where the ω-step is taken by design: soundly in ℕ, unsoundly in ℝ (U11(e)).

   In proof-assistant practice data at parameters are common. So the practical answer is often positive, for a
   reason other than the one the intuition gives.

**A good version, for this case.** Use:

* a template prior;
* a selection-aware derivation likelihood (L1-sel);
* the thresholded verifier "accept s iff P(T ⊢ s | D) ≥ 1−δ".

On closed instances it accepts ∀xφ only if the prior share of provers is ≥ 1−δ. It accepts every φ(t) once the
law-like hypotheses (σ_φ, ∀xφ, H_open) carry mass ≥ 1−δ. It accepts ∀xφ after one parameter instance (U11(a)), or after
a quantified datum that entails ∀xφ over the background (U12(a)).

Under well-specification it is time-uniformly sound. If T* ⊬ ∀xφ, acceptance needs π(T* | D_n) ≤ δ, i.e.
M(D_n)/P*(D_n) ≥ π(T*)/δ. That ratio is a nonnegative supermartingale under P* with initial value 1. By Ville's
inequality the probability of ever accepting is ≤ δ/π(T*). This is the argument of inferential-learning
thm:caution:ville (prior–posterior ratio martingale) applied to the question "T ⊢ ∀xφ" **[proved, as just given]**.
Under the filtered misspecification of U10(d), the failure is the safe kind: the verifier never accepts ∀xφ, which is
incompleteness, not unsoundness.

---

## 11. Open problems

1. **U3 for full first-order calculi.** U3 needs "only ∀-elim takes a non-quantifier-free premise". Do detours
   through propositional rules on quantified formulas ever let instance data favour ∀xφ over σ_φ? Conjecture: no, up
   to a factor that tends to 1.
2. **Rates for memorisers (U6(iii)).** Prove −Θ(log² n) under geometric numerals, and give the general rate in terms of
   the growth of distinct data.
3. **Full Q in U14.** Does every Q-derivation of 0+S^k0 = S^k0 need Ω(k) steps in a standard Hilbert calculus? This is
   Kreisel-type: if bounded-step proofs existed for all k, a Kreisel-type principle would give Q ⊢ ∀x(0+x=x), which is
   false. But Kreisel-type principles for Q are themselves not established here.
4. **Selection-aware likelihoods when the selection is unknown.** L1-sel needs the filter S. If S must be inferred too,
   does the ω-gap reappear as a prior share over filters?
5. **Multi-variable φ with mixed data.** For instance, closed in x and parametric in y. Which partial universal closures
   are licensed? This is presumably the per-variable guard structure of axiom-schemas Prop univ:capture(e). Not
   checked.
6. **Sentence-only classes with background Q.** Characterise when the L1 posterior's limit theories prove ∀xφ over Q.
   U16 shows the answer depends on whether Q supplies the root case split (Q3).
7. **Hutter (2007)'s exact theorem and rate.** The full text was not reachable here. The comparison in §5 should be
   re-checked against its universal-prior section.

---

## 12. References (with verification status)

* **Hänni, K.** Notes in `research/prior/`: `hanni-solomonoff-axiom-induction.md` (the two variants; the collapse to
  function induction), `hanni-polytime-solomonoff.md`. Read in full.
* **axiom-schemas paper** (`../../../../axiom-schemas/paper/sections/`):
  * `universal.tex` and `app-universal.tex`: Prop univ:open, Prop univ:tv, Ex univ:fail, Ex univ:q, Thm univ:rates,
    Thm univ:anchor;
  * `many.tex` and `app-many.tex`: sec:many:mdl, Prop many:mdlnaive, Prop many:mdlwell, Prop many:forall.

  Read.
* **inferential-learning report:** `paper/sections/caution.tex` thm:caution:ville, and `app-caution.tex`
  lem:app:caution:ville. Read; the argument is reused in §10.
* **Hutter, M. (2007).** On universal prediction and Bayesian confirmation. *Theoretical Computer Science*
  384(1):33–48. doi:10.1016/j.tcs.2007.05.016; arXiv:0709.1516.
  * **Verified (web search):** the bibliographic data; the abstract's claims that the universal prior has "no zero
    p(oste)rior problem, i.e. it can confirm universal hypotheses", and the Bayes–Laplace analysis with
    H″ = {all future observations black} and P[H″ | 1^n] = lim_k ξ(1^k | 1^n) = 0.
  * **Not verified:** the full text and the exact theorem number and rate for the universal prior (arxiv.org and
    hutter1.net are blocked here). The statement "M(1^∞ | 1^n) → 1 since M(1^∞) > 0" is from memory.
* **Leike, J. and Hutter, M. (2015).** Solomonoff induction violates Nicod's criterion. ALT 2015, LNCS 9355.
  doi:10.1007/978-3-319-24486-0_23. Title and venue verified by search; content only at the abstract level
  (confirmation is not stepwise monotone).
* **Gaifman, H. (1964).** Concerning measures in first order calculi. *Israel J. Math.* 2(1):1–18. Bibliographic data
  verified by search. The condition P(∃xψ) = sup_n P(ψ(t₁) ∨ … ∨ ψ(t_n)) is cited from memory.
* **Gaifman, H. and Snir, M. (1982).** Probabilities over rich languages, testing and randomness. *J. Symbolic Logic*
  47(3):495–548. Bibliographic data verified; content not used beyond context.
* **Doob, J. L. (1949).** Application of the theory of martingales. *Colloques Internationaux du CNRS* 13:23–27. Cited
  from memory; U7 is proved here in full.
* **Tarski, A. and Vaught, R. (1957).** Via axiom-schemas Prop univ:tv.
* **Hoeffding, W. (1963).** Probability inequalities for sums of bounded random variables. *JASA* 58:13–30. Standard;
  from memory.
* **Kreisel's conjecture; Parikh, R. (1973),** "Some results on the length of proofs", *Trans. AMS* 177. Cited from
  memory; **unverified.**
* **Tenenbaum, J. and Griffiths, T. (2001).** The size principle; cited as in axiom-schemas.

---

## 13. Verification log

Each script is run as `python3 <script>` from `checks/` and writes `<script>.out`. All randomness is seeded. Runtimes
are on this container. A second full run of all seven scripts reproduced every `.out` file byte for byte.

| script | what it checks | result |
|---|---|---|
| `c1_grammar.py` (58 s) | U1 identity; Z formulas; exact engine against the procedural sampler (minimal calculus, 3 formulas × 2 laws, 2·10⁵ derivations each); C_open closed forms (U11(c)) against the sampler for 4 theories | identity max deviation 5·10⁻¹⁴ on up to 63 763 outputs; Z identity exact; max \|z\| 2.35 and 1.60; ratios c, (1−ρ)/(1−gcρ), 1/(gρ) exact |
| `c2_odds.py` (~2 min) | U2 identities asserted on every path (5 φ × 2 laws × 50 seeds × n ≤ 200 × 5 variants); U4 bound (exact sums for numerals, Monte Carlo for GW and formula metavariables); U5 survival and gain; posterior tables | all assertions pass; bound holds in 38/38 cases (equality where the ratio is constant); over-specific gain log(1/p_S), survival p_S |
| `c3_memo.py` (75 s) | U6: memoriser log-odds, uniform and Laplace; the proved lower bound asserted | D_l/ln²n ≈ −2.5…−2.8 (q = 1/2); D_l/n ≈ −4 (GW); lower bound holds on every path |
| `c4_confirm.py` (11 s) | U8: Laplace with a point mass (closed form against quadrature); dyadic family; summed-miss bound; Nicod example | closed form exact to 10⁻¹²; W_n·log₂n = 0.98 at 10⁵⁰ (limit 0.99); sums 4.22 and 2.70 ≤ 4.61; posterior 1/3 |
| `c5_open_quant.py` (27 s) | U10 and U11 posterior tables in C_open; U12(b) closed forms asserted against the engine; Part C spare-slot integral against its proved bounds | tables as in §6–§8; n·I_n → 1.000 within the bounds |
| `c6_models.py` (1 s) | U13 model on {0..40} ∪ {a, b}; U14(a) invariant and breadth-first search, k ≤ 5 | 0 violations; a+0 = 0; shortest chains k+1; no step with \|Δw\| ≠ 1 |
| `c7_sentences.py` (20 s) | U16: sentence-only class, L0-closure against L1-norm | H_∀ → 0.999 (L0-closure); Split → 1.000 (L1-norm) |

**What was checked by proof only.**

* **U3.** The injectivity of the pattern map. The key step is that every σ_φ-leaf in the image comes from a pattern.
* **U7.** The measurability of E_g. It is a function of the 𝔽_∞-measurable empirical limit g.
* **U10(d).** It needs supp P_σ ⊆ S, which holds for quantifier-free φ. For quantified φ the elimination chains of σ_φ
  leave S, and the filtered law is then P_σ restricted to S and renormalised. The statement still holds with
  P̃_{H_sch} replaced by that restricted law; it was not re-checked numerically.
* **U14(b).** The coupling: the rule-label tree is a Galton–Watson tree because rule choice does not depend on context.
  In typed grammars where it does, the bound needs the maximum of μ over contexts.

**Known gaps.**

* Hutter (2007), Kreisel's conjecture and Parikh (1973) are not verified beyond the bibliographic level (§12).
* The over-general family in c2 contains only single-replacement generalisations and ?A. U4(iv) covers all first-order
  generalisations.
* The memoriser rates beyond the proved lower bound are numerical (U6(iii)).
