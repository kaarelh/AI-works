# Track "pa": PA, ZF and "the axioms we actually have" (brief H7) — final record

This is the complete record of track "pa" after the referee report (`referee.md`). It replaces `notes.md` (kept for
the record) and is self-contained. Scripts are in `checks/`. Each is deterministic or seeded and writes `name.out`
next to itself. Section 9 is the verification log. It maps every referee issue to its resolution and lists every
check with its result.

**Status labels.**
* **proved**: full proof here.
* **proved (checked)**: a derivation checked line by line by `checks/nd.py`, a small proof checker, plus a short
  informal proof here.
* **computed**: script and output in `checks/`.
* **known**: published, with reference; "(location not verified)" when I could not check the page.
* **proof sketch**: the argument is given; some steps are not written out.
* **conjecture**.
* **refuted**: a claim shown false, kept with the counterexample.

**Reference labels.** `AS:` is the paper `../../../../axiom-schemas/paper/sections/*.tex`, by LaTeX label. "Model",
"universal" and "experiments" are the parallel tracks (`../model/`, `../universal/`, `../experiments/`). "Conv §k" is
section k of `../../../../axiom-schemas/research/conversation.md`.

**Framing.** This is a study of what a Bayesian axiom inducer would conclude about PA and ZF, as a check on the idea.
It is not a design for a stronger prover.

---

## Summary

1. **Equivalent axiomatisations (§1).**
   * Over B = Q1–Q5 + Dlt, the full schemas Ind, CVI (course-of-values induction) and LNP (least number principle)
     are interderivable, instance by instance. **Proved (checked).** CVI and LNP are higher-order patterns; Ind is
     not. **Proved.**
   * Under a derivation likelihood the posterior does not prefer the logically minimal axiomatisation. It prefers the
     one whose primitives match the usage. A non-primitive form costs 570–2250 bits per use to derive (§§1.2, 1.4);
     a template costs 70–190 bits of prior. **Computed** (upper bounds; one calculus, one code). Every derivation of CVI(P) in
     Q+Dlt+Ind costs at least 53 bits more than citing it. **Proved.**
   * All candidates compared there are deductively equivalent, so the theorems are right whichever one wins.
2. **The MDL finding of `AS:sec:many:mdl` survives a derivation likelihood (§2).** The split of T_Ind by main
   connective is driven by the instantiation grammar, not the likelihood family. **Computed.**
   * Under a shared, positional, learned grammar the split's margin is exactly the prior difference plus Occam terms:
     Δprior + ((|F| − 9)/2)·log₂n + O(1), for a split into |F| roots with 9 formula symbols in the root context.
     **Proved** (identity), and it matches the computation to 0.1 bit. The first version called this margin
     "constant". **Refuted**: it falls by 1 bit per doubling of n for the full split.
   * What a derivation likelihood does change: a split containing a non-atomic connective still derives every
     induction instance. **Proved (checked).**
3. **Theorem data: statements given without proof (§3, new).** This is the user's proposal. Under the computable
   two-part derivation code, deriving even a one-induction theorem costs 6–24 times more than adopting it as an
   axiom. So on data made of distinct short theorems, "Q + the theorems as axioms" beats Q+Ind, and that theory is
   strictly weaker than PA. **Computed.** A theory beats memorisation only on what it compresses: direct uses of its
   schemas, long theorems with short proofs, or data drawn from its own derivation process (where it wins in
   expectation on every new datum, **proved**, and asymptotically, **proved given known facts**).
4. **Th(ℕ), the IΣₙ chain and narrow practice (§4).**
   * With 0/1 derivability every consistent r.e. theory is eventually refuted. **Proved.** Inconsistent theories
     survive unless a refutation rule at growing depth removes them. **Proved.**
   * The reflection schema contains no non-ground DT° template. **Proved.**
   * Stochastic data separate the IΣₙ chain from PA; the posterior concentrates on PA's generator. **Proved, given
     known facts.**
   * **Refuted:** "in DT° the posterior lands on the PA (L∞) side". A practice of Σ₁ and open induction is covered by
     two term-only templates whose theory lies inside IΣ₁. That theory overtakes Q+T_Ind near n ≈ 2^26.7.
     **Computed.**
   * What is true: a read-once induction template with a formula metavariable gives full induction over Q; a template
     without one has a fixed skeleton and gives at most IΣₖ. **Proved.** Which side the posterior takes is set by an
     Occam balance between the number of templates and the number of grammar contexts they fix. **Proved**
     (identity) **and computed.**
5. **Unlabelled mixtures, a Bayesian DTRC (§5).** On Q+Ind practice the posterior puts mass ≥ 1 − 6·10⁻⁶ on Q+T_Ind
   from n = 100, within a hand-picked candidate set. **Computed.** Spare slots cost ½log₂n + prior bits. **Proved.**
   Unsound lumps of rarely used ground axioms win at n ≤ 30; a threshold verifier then accepts 0 = S0. **Computed.**
   The extra ∀-elimination step of ∀x(x+0=x) costs log₂R bits per datum under a fixed rule code, but only
   (R−1)/2·log₂n under a learned depth-indexed rule code. **Computed.** The direction (the instance schema wins)
   holds under every code.
6. **Robust failures (§6).** The worst are false generalisations with absent counterexamples (Euler's Prime(z²+z+41),
   preferred by 3.1·10⁵ bits at n = 10⁶), memorisation of theorem data, narrow practice, and inconsistency, which
   the size principle does not see.
7. **Overall answer (§7).** Within the candidate sets scored, and for data that are direct uses of axioms, nearly all
   posterior mass goes to theories deductively equivalent to PA. This is not robust in general: theorem data,
   syntactically narrow practice and absent counterexamples each move the posterior to a theory that is weaker than
   PA or false.

---

## 0. Definitions and notation

**Syntax and templates.** Sentences and templates are as in `AS:sec:setting`.
* DT° templates are second-order templates in which each metavariable has a pattern occurrence, so matching is
  unique and linear (`AS:thm:setting:matching`).
* PAT ⊆ DT° are the templates all of whose metavariable occurrences are pattern occurrences.
* A ground template is a single sentence.

**Definition 0.1 (theory).** A theory is a finite set T of DT° templates. Mixture weights carry a Dirichlet(½)
prior unless said otherwise.

**Definition 0.2 (prior).** On a finite candidate set, π(T) ∝ 2^(−β·Σ_{τ∈T}|τ|), where |τ| counts symbols.
* In the computations built on `AS`'s u7 code (§§2, 4.3, 5), β = 5 bits per symbol and |·| is the `dtlib` size
  (a de Bruijn quantifier counts 1).
* In the derivation computations (§§1, 3), β = log₂23 ≈ 4.52 bits per symbol and |·| is `nd.size` (a quantifier and
  its variable count 2).
* β|T| is not a proper prior over all theories. It is used only on finite candidate sets. Model Def 1.3 gives a
  proper prefix-code prior π_λ; its λ·ℓ(T) corresponds to β|T| up to the bits per token.

**Definition 0.3 (likelihoods).** The following members of the brief's H1 family are used.
* **L0 (citation).** A datum is an instance τθ of some τ ∈ T: P_T(d) = Σ_{τ∈T, d∈inst(τ)} w_τ·Q(θ_{τ,d}).
  * Q is the *instantiation grammar*: a sequential KT model of the metavariable bodies, symbol by symbol, in a
    context.
  * The **positional** grammar codes each body as the datum's subtree at the metavariable's read-off occurrence, in
    context (sort, depth, parent symbol, child index). So two templates that fix different amounts of a sentence code
    the remaining symbols in the same contexts (`checks/c4_bdtrc.py`, `occ_positions`).
  * With Dirichlet(½) weights the marginal is model §1.5's P^Dir_T.
* **L1 (derivation grammar).** Model §1.5: a random derivation tree that cites axioms (instantiated by Q) or applies
  rules; P_T(d) is the normalised probability that it concludes d. This is the generative model of the brief. Under
  subcriticality P_T(d) is a computable real, but whether P_T(d) > 0 is undecidable, and evaluation by truncation
  takes time exponential in the derivation size (model Prop 2.7).
* **L1-max (two-part).** −log₂ of the probability of the best single derivation (universal's name).
* **L1-sch (this track's computable two-part code).** A datum is the conclusion of a derivation in the
  natural-deduction calculus of `checks/nd.py` (rules hyp, ax, tc, →I, ∀E, ∀I, ∃I, ∃E, refl, subst; a standard sound
  and complete calculus).
  * The derivation is written schematically in a predicate metavariable P, and the motive φ is coded once by Q:
    code length = bits(π) + L_Q(φ).
  * bits(π) charges per line: log₂10 for the rule, log₂|T| for an axiom citation, log₂(line index) per premise
    reference, β per written symbol.
  * **Decodable variant** (`nd.Proof.bits_decodable`, referee m4): also codes the number of lines, the number of
    premises of each tc line (Elias γ), and the variable named by each subst and ∃I line. It adds 4.8–7.3% to the
    derivation costs of §1 (`c1_costs.out`). With these fields bits(·) is a prefix code for derivations over a fixed
    alphabet, so Σ_π 2^(−bits(π)) ≤ 1 by Kraft. L1-sch is then the two-part form of a sub-probability likelihood.
    (Strictly, β should be log₂ of the alphabet size, about log₂25 with the variable names used; this changes symbol
    costs by about 3% and no conclusion.)
  * Every number reported is for an explicit derivation, so it is an **upper bound** on the shortest one.
  * L1-sch charges β bits per *written symbol*. So it is a two-part form of model's L1^σ (a symbol-size penalty), not
    of plain L1, whose code length counts grammar choices and can be exponentially smaller than the symbol size
    (model §6.5). And a two-part code can change posterior limits relative to the full sum (model Prop 2.8).
* **L1-naive.** As L1-sch, but every written formula is written out at the instance (each axiom leaf instantiated
  independently). A derivation that writes P K times costs about β(K−1)(|φ|−1) more than citing.
* **L_ε (Hänni's "need not prove, must not contradict").** L_ε(T; d) = (1−ε)·P_T(d) + ε·μ₀(d)·[T ⊬_k ¬d], for a fixed
  law μ₀ and a bounded refutation search ⊬_k. It is a sub-probability whose total mass depends on T but not on the
  data. It is universal's noisy likelihood P^η_T with η = ε and noise law μ₀, restricted to sentences T does not
  refute. ε = 1 gives model's S_nc ("does not contradict") up to the data-dependent constant μ₀(D), which is the
  same for every theory; ε → 0 approaches S_prove ("proves the givens").

**Definition 0.4 (refutation rule R_d; one rule for the whole record; referee m6).** With data D and certified-false
sentences N (negative data), R_d sets the likelihood of T to 0 if T ⊢_{≤d} ¬d' for some d' ∈ D, or T ⊢_{≤d} s for some
s ∈ N. Here ⊢_{≤d} is derivability by derivations of size ≤ d (model's Th_d).
* Under L0, "derives" means "has as an instance" (d = 0); this is the rule used in `c4_bdtrc.py`.
* R_∞ refutes every inconsistent theory at the first datum, but it is not computable: "T is refuted" is r.e., not
  decidable.
* With a schedule d_n → ∞, each fixed inconsistent theory is refuted after finitely many steps (Prop 4.2).
* Where a statement uses the bare likelihood without R, it says so.

**Definition 0.5 (posterior and verifier).** π_n(T) := π(T | D_n). C* := {T : P_T = P_{T*}} is the generator class
(model §2). The thresholded verifier V_{δ,d} accepts s iff π_n({T : s ∉ Th_d(T)}) ≤ δ (model §4).

**Posterior odds.** In the u7-based, c2, c4 and c8 computations every code is −log₂ of a Dirichlet(½) marginal
likelihood plus prior bits. Sequential KT is the Dirichlet(½) mixture (**known**: Krichevsky and Trofimov 1981). So
code-length differences are log₂ posterior odds, exactly, except where a datum is covered by two templates and is
coded by the cheaper one (a two-part bound; Remark 5.4).

---

## 1. Equivalent axiomatisations: which does the posterior favour?

### 1.1 The equivalences, and over which base theory

Notation.
* Dlt := ∀u∀v(u<v ↔ ∃z(u+Sz=v)), the definition of <.
* For a motive φ with distinguished variable x (parameters allowed):
  * Ind(φ) = φ(0) ∧ ∀x(φ→φ(Sx)) → ∀xφ;
  * CVI(φ) = ∀x(∀y(y<x→φ(y)) → φ(x)) → ∀xφ;
  * LNP(φ) = ∃xφ → ∃x(φ ∧ ∀y(y<x→¬φ(y)));
  * θ_φ := ∀y(y<x→φ(y)).

**Proposition 1.1 (proved, checked).** Let B = {Q1,…,Q5, Dlt}, where Q1–Q5 are Robinson's axioms for S and +, with
Q3 as x=0 ∨ ∃y x=Sy. For every motive φ:
* (A) B ⊢ CVI(φ) → Ind(φ), using Q3, Q4, Q5 and Dlt;
* (B) B ⊢ Ind(θ_φ) → CVI(φ), using Q1–Q5 and Dlt;
* (C1) ⊢ CVI(¬φ) → LNP(φ), pure logic;
* (C2) ⊢ LNP(¬φ) → CVI(φ), pure logic.

Hence B+Ind, B+CVI and B+LNP have the same theorems. So do Q+Dlt+Ind (PA with < defined), Q+Dlt+CVI and Q+Dlt+LNP.
The multiplication axioms are not needed.

*Proof.* `checks/arith.py` builds each derivation schematically in a unary predicate symbol P, and `nd.py` checks
every line. Substituting a formula for P, after renaming the derivation's bound and eigenvariables away from φ, maps
derivations to derivations (the substitution theorem for predicate symbols; e.g. Shoenfield 1967, *Mathematical
Logic*; location not verified). `test_nd.py` replays all four derivations on 200 random concrete motives with
parameters; all check. The cited axioms are listed in the last block of `c1_costs.out`.

Informal proofs:
* **(A)** Assume φ(0) and ∀x(φ→φ(Sx)); show progressiveness. Take x with ∀y<x φ(y). By Q3, x=0, so φ(x); or x=Sw.
  Then w+S0 = S(w+0) = Sw by Q5 and Q4, so w<x by Dlt. Hence φ(w), hence φ(Sw) = φ(x). CVI gives ∀xφ.
* **(B)** Apply Ind to θ_φ.
  * Base: y<0 gives y+Sz = 0 for some z, so S(y+z) = 0 by Q5, contradicting Q1.
  * Step: y<Sx gives y+Sz = Sx, so y+z = x by Q5 and Q2. By Q3, z=0 or z=Sv. If z=0, then y = x by Q4, and φ(x)
    follows from θ_φ(x) and progressiveness. If z=Sv, then y+Sv = x, so y<x and φ(y) follows from θ_φ(x).
  * So ∀x θ_φ(x), and progressiveness gives ∀xφ.
* **(C1), (C2)** are contrapositions. ∎

**Remark 1.2 (proved).** CVI(P) and LNP(P) are in PAT: every occurrence of P is P(x) or P(y) under a binder for that
variable, a pattern occurrence (`AS:sec:setting`). T_Ind is in DT°∖PAT because of P(0) and P(Sx). So PA (with Dlt)
is Q, Dlt and one higher-order pattern. This complements `AS:prop:zf:indeq` (Tarski's IndEq, a first-order pattern).
It matters for learnability: pattern anti-unification applies to CVI and LNP but not to Ind (`AS:prop:zf:indpat`).

**Fragments (known; locations not verified).**
* For restricted motive classes the equivalences are the classical ones: over PA⁻, IΣₙ ⇔ IΠₙ ⇔ LΣₙ ⇔ LΠₙ (Paris and
  Kirby 1978, Logic Colloquium '77; Kaye 1991, *Models of Peano Arithmetic*, chapter on fragments; Hájek and Pudlák
  1993, ch. I §2). Theorem numbers not checked.
* The IΣₙ ⇔ IΠₙ equivalence fails for parameter-free schemes (Kaye, Paris and Dimitracopoulos, "On parameter free
  induction schemas", *JSL* 53(4):1082–1097, 1988; existence checked by the referee; I had cited slides).
* The motive transformation of (B), φ ↦ θ_φ, adds a bounded universal quantifier. That is why the fragment-level
  equivalence needs bounded collection, which the full-schema case does not.
* DT° templates cannot say "motive in Σₙ", since metavariables range over all formulas. Inside this hypothesis class
  only the full-schema equivalence is relevant.

### 1.2 What the posterior does: the per-use cost of a non-primitive form

**Setting (L1-sch).**
* Data are i.i.d. *uses* (f, φ): a form f ∈ {Ind, CVI, LNP} with probability p_f, and a motive φ ~ Q.
* Theories are T_S = Q1–Q7 + Dlt + S, for nonempty S ⊆ {Ind, CVI, LNP}.
* A use costs c_S(f) + L_Q(φ), where c_S(f) is the bit cost of the cheapest derivation of f(P) from T_S in a fixed
  library of checked derivations (a one-line citation if f ∈ S).

**Computed** (`c1_costs.py` → `c1_costs.out`; β = log₂23):

| theory | form | lines | written symbols | K (writes of P) | bits | overhead over citing | overhead, decodable code |
|---|---|---:|---:|---:|---:|---:|---:|
| T_Ind | CVI | 63 | 204 | 14 | 1483.6 | 1468.0 | 1551.2 |
| T_Ind | LNP | 82 | 332 | 33 | 2249.6 | 2234.1 | 2341.8 |
| T_CVI | Ind | 39 | 127 | 18 | 896.0 | 880.4 | 945.1 |
| T_CVI | LNP | 20 | 117 | 20 | 662.0 | 646.4 | 676.9 |
| T_LNP | Ind | 65 | 253 | 38 | 1707.7 | 1692.1 | 1792.3 |
| T_LNP | CVI | 27 | 128 | 21 | 773.1 | 757.5 | 799.1 |
| any T_S with f ∈ S | f | 1 | 2 | 1 | 15.5–15.8 | 0 | 0 |

Template prior costs β|f(P)|: Ind 72 bits, CVI 81, LNP 86.

**Proposition 1.3 (proved, given the library constants).** Let D_n be n i.i.d. uses. Then
(1/n)·(L(T_S; D_n) − L(T_{S'}; D_n)) → Σ_f p_f (c_S(f) − c_{S'}(f)) almost surely. So the posterior concentrates on
the S minimising E_p[c_S(f)], if the minimiser is unique.

*Proof.* The prior terms are constants. The L_Q(φ) terms are the same under every theory and cancel. The rest is a
sum of i.i.d. bounded terms, so the strong law of large numbers applies. Posterior odds are 2 to the minus the
code-length difference, which tends to 0 or ∞ exponentially when the limit is nonzero. ∎

The constants are upper bounds. A lower bound is still needed for "a non-primitive form costs more than citing".
The first version argued it wrongly ("at least two lines, so at least log₂10 + β more"; a citation also writes P(x),
2 symbols; referee m5). Here is a correct argument.

**Proposition 1.4 (proved; lower bound).** Under L1-sch, every derivation of CVI(P) from T_Ind = Q1–Q7 + Dlt + Ind
costs at least log₂10 + 11β ≈ 53 bits more than citing CVI(P) in T_CVI. Every derivation of Ind(P) from T_CVI costs at
least log₂10 + 9β ≈ 44 bits more than citing Ind(P) in T_Ind.

*Proof* (for CVI(P); Ind(P) is the same with its 11-symbol antecedent: Ind(P) fails in the structure {0, a} with
S0 = 0, Sa = a and P = {0}, and it is not an instance of CVI, whose antecedent has root ∀). A citation costs
log₂10 + log₂9 + 2β.
The term positions of both forms lie under binders or are 0, so a ∀E step cannot have produced them from a shorter
variable (that would capture a bound variable); written formulas on the chain therefore have the full sizes.
Let π be a T_Ind-derivation of CVI(P) without open hypotheses.
1. *π cites an axiom.* CVI(P) is not valid in pure logic: interpret < as the full relation and P as empty. Then
   ∀y(y<x→P(y)) fails for every x (take y = x), so the antecedent ∀x(∀y(y<x→P(y))→P(x)) holds, while ∀xP(x) fails.
   So some line of π is an axiom citation, which costs at least log₂10 + log₂9.
2. *The last line is not a citation, and some other line writes at least 13 symbols.* Follow the chain of premises
   back from the last line through ∀E (premise ∀v A with A[t/v] equal to the current formula), ∀I (premise the
   matrix) and ∃E (premise with the same conclusion). Every formula on this chain is CVI(P) with a quantifier prefix
   and with terms in place of variables; substituting terms for variables preserves the connective skeleton. The
   chain must end at a line of another rule:
   * ax is impossible. The Q-axioms and Dlt do not contain P. An Ind instance is an implication whose antecedent is
     a conjunction, while every formula on the chain has antecedent root ∀ once its prefix is removed. And no
     instance has a ∀-prefix.
   * refl (an equation) and ∃I (root ∃) are impossible.
   * hyp, tc and subst write a formula with CVI(P)'s skeleton: at least 18 symbols (13 skeleton symbols and at least
     one symbol at each of the 5 term positions). A hyp line must later be discharged; the line still writes it.
   * →I writes its discharged antecedent. On the chain this has the skeleton of CVI(P)'s antecedent: at least 13
     symbols (`c1_costs.out`, "lower-bound sizes").
   So π has a line other than the citation that writes at least 13 symbols, at cost ≥ log₂10 + 13β.
3. Premise references cost ≥ 0. So bits(π) ≥ 2 log₂10 + log₂9 + 13β, which exceeds the citation by log₂10 + 11β. ∎

**Consequences (computed from the table; all "iff" statements are for L1-sch with this derivation library;
referee m3).**
* **Among minimal theories, the asymptotic winner is a function of usage** (`c1_costs.out`, grid):
  * T_Ind wins only for p_Ind ≳ 0.7; T_CVI wins a broad middle region (both Ind and LNP derive from it in 650–900
    bits); T_LNP wins when p_LNP is large.
  * Pairwise break-even: T_Ind beats T_CVI iff p_CVI/p_Ind < 0.600; T_Ind beats T_LNP iff p_LNP/p_Ind < 0.757; T_CVI
    beats T_LNP iff p_LNP/p_CVI < 1.172.
  * Under the decodable code the three ratios are 0.609, 0.765 and 1.180.
  * Under L1-naive the first ratio is 0.671, 0.776, 0.900 and 1.052 at |φ| = 5, 10, 20, 40 (`c1_costs.out`, last
    block). So the ratios are robust to completing the code but not to changing how motives are coded.
* **The redundant union wins as soon as two forms are used.**
  * T_all = Q+Dlt+{Ind, CVI, LNP} pays 81 + 86 bits more prior and log₂(11/9) ≈ 0.29 bits more per citation.
  * One CVI use saves 1468 bits under T_Ind. So after about one use of a non-primitive form the redundant theory is
    ahead (`c1_costs.out`: ahead after 1–12 uses for the usage mixes tried).
  * By Prop 1.3 the posterior concentrates on the **usage-closed** axiomatisation: every form used at a rate above
    roughly 0.3/650 ≈ 5·10⁻⁴ per use is primitive.
  * This is a quantitative form of the brief's H2 remark (and model Prop 2.5) that a derivation likelihood identifies
    an axiomatisation, not a theory.
* **The code matters for which minimal theory wins.** Under L1-naive the overhead grows by about β(K−1) bits per
  motive symbol (CVI from T_Ind: 1621, 1915, 2515, 3832 bits at |φ| = 5, 10, 20, 40; Ind from T_CVI: 1088, 1487,
  2264, 4030). The redundant-union conclusion does not depend on the code.

### 1.3 Recursion conventions for + ("Q5 as written versus variants")

T_right = Q + Ind (Q4: x+0=x, Q5: x+Sy=S(x+y)). T_left replaces these by Q4L: 0+x=x and Q5L: Sx+y=S(x+y).

**Proposition 1.5 (proved, checked).** T_left ⊢ Q4, Q5 and T_right ⊢ Q4L, Q5L, each with one induction, on the
motives x+0=x; ∀y(x+Sy=S(x+y)); 0+x=x; and Sp+x=S(p+x) with parameter p. So the two theories are equivalent.

**Computed** (`c1_costs.out`, block (c)). Overheads per use: Q4 in T_left 213.8 bits, Q5 in T_left 593.4, Q4L in
T_right 213.8, Q5L in T_right 545.1. So the posterior adopts whichever convention the data use: T_right wins iff
r₄·213.8 + r₅·593.4 > l₄·213.8 + l₅·545.1, where r and l are the usage rates of the two conventions.

### 1.4 ZF: Replacement versus Collection, Foundation versus ∈-induction, Separation from Replacement

Forms (`checks/zf.py`; schema constructors rename their own binders away from the motive's free variables):
* SepJ: ∀X∃Y∀u(u∈Y ↔ u∈X ∧ φ).
* ReplJ (image form): ∀x∀y∀z(ψ∧ψ[z/y] → y=z) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X∧ψ)).
* ReplK (bounding form, ∃! spelled out); Coll, EInd and Found as in `AS:tab:zf:forms`.

The checker caught one error of mine: a first version of SepJ let its bound X capture the motive's parameter X.

* **Separation from Replacement (proved, checked).** ⊢ ReplJ(λxy. φ(x) ∧ y=x) → SepJ(φ), pure logic with equality.
  Computed: 36 lines, overhead 1209 bits per use; the SepJ template costs 72 bits. (Jech's book remarks that
  Separation follows from Replacement; recalled, not re-checked; the checked derivation does not depend on it.)
  Whether ReplK yields Separation was not studied.
* **Replacement from Collection (proved, checked).** ⊢ Coll(ψ) → ReplK(ψ), pure logic: 15 lines, 574 bits.
  Coll(ψ) with two SepJ instances ⊢ ReplJ(ψ): 43 lines, 1432 bits.
* **Collection from Replacement.**
  * Holds over ZF. **Known**: via ranks or reflection (Lévy 1979; Jech 2003; locations not verified).
  * Fails without Power Set. **Known**: Zarach 1996, "Replacement ↛ Collection", Gödel '96, Lecture Notes in Logic 6,
    pp. 307–322; Gitman, Hamkins and Johnstone, "What is the theory ZFC without power set?", MLQ 62(4–5):391–406,
    2016, doi 10.1002/malq.201500019. Both verified via abstracts and catalogue records, not full text.
  * Without Foundation but with Power Set: **unknown to me**; neither my search nor the referee's settled it, and
    `AS:prop:zf:coll` leaves it open.
  * Not formalised. **Conjecture**: its overhead is far larger than 574 bits.
* **Foundation from ∈-induction (proved, checked).** ⊢ EInd(¬x∈S) → Found, pure logic: 21 lines, 758 bits. The Found
  sentence costs 109 bits.
* **∈-induction from Foundation.** Needs transitive closures, so it holds over ZF minus Foundation (Infinity, Union
  and Replacement give TC({a}); standard). Without Infinity, transitive containment has to be assumed (**known**:
  Kaye and Wong, "On interpretations of arithmetic and set theory", NDJFL 48(4):497–510, 2007; abstract verified).
  Not formalised. **Conjecture**: overhead much larger than 758 bits.

**When do the textbook ZF axioms win?** By the accounting of Prop 1.3:
* **Separation** is redundant given ReplJ, yet each use saves about 1209 bits against its 72-bit template. So the
  posterior keeps Separation whenever it is used, as textbooks do.
* **Foundation versus ∈-induction.** If practice uses ∈-induction or ∈-recursion, EInd becomes primitive. The sentence
  Found survives only if it is itself cited (each citation saves about 758 bits against 109).
* **Collection versus Replacement.** Collection is added as soon as it is used (the reverse derivation is long;
  conjectured). With only Replacement uses, T_Coll pays 574–1432 bits per use, so Replacement wins.

### 1.5 Answer to question 1

The posterior favours the axiomatisation that makes the **used forms primitive**. Logical economy enters only through
prior terms of about 70–190 bits per template, which are swamped after about one use. So the textbook axioms win
exactly when the data are direct uses of them and of nothing else that they derive only at a cost. Among minimal
axiomatisations the usage mix decides. In every case of §1 the competitors are deductively equivalent, so the
posterior gets the *theorems* right even when it gets the *presentation* "wrong". The constants are for one calculus
and one code; the qualitative conclusions use only "overheads ≫ template costs" (computed) and "overheads > 0"
(Prop 1.4).

---

## 2. The MDL finding of `AS:sec:many:mdl` revisited

**The finding** (`AS:sec:many:mdl`, `AS:app:many:mdl`, `AS:tab:many:mdl`): "MDL tracks the statistics of usage, not
the logical boundaries of schemas". A naive two-part code splits T_Ind by the motive's main connective by a margin
linear in n. Under the natural usage law G1 even the depth-aware code DPC splits for n ≥ 1.6·10⁴.

### 2.1 The u7 codes are Bayes factors

The PC and DPC codes of u7 are sequential KT, i.e. Dirichlet(½) marginal likelihoods. The template part (5 bits per
symbol) is a prior. So u7's table already gives log₂ posterior odds, and its finding is Bayesian, not an artefact of
two-part coding. **Known** (Krichevsky–Trofimov), applied.

### 2.2 Exact comparisons with new grammars

`checks/c2_mdl.py` re-runs u7 with its data generators and seeds (`random.Random(n)`). Hypotheses:
* H_true = Q1–Q7 + T_Ind.
* H_root = Q + all seven root templates T_f.
* H_used = Q + the root templates of the roots that occur in the data. This is the split H_F of `AS:app:many:mdl`
  (F = the main connectives of the induction data), with the index alphabet restricted to F.

**Correction (referee m1).** The first version, like u7 itself (`u7_mdl.py`, line 99), charged prior only for the
templates some datum uses, while the KT index still ranged over all seven. Under G1 all seven roots occur, so nothing
changes. Under G2 (roots =, ¬, ∧, →) 355 prior bits were missing, and under G3 (=, →, ∀) 470. Every template is now
charged. The script also prints u7's bookkeeping; it reproduces `AS:tab:many:mdl` exactly at n = 1000 (G1: −223,
+2325, +2701; G2: −915, +1141, +1428 after rounding). The G2 rows of `AS:tab:many:mdl` carry the same undercount; this
does not change any conclusion there.

New grammars:
* **SDPC**: one learned grammar shared by all templates, context (depth, parent, child index). The split templates'
  bodies are coded at the positions they occupy in T_Ind, so the split changes only how the motive's root symbol is
  coded (by the template index instead of the grammar).
* **RDPC**: for H_true the grammar may condition on the motive's root symbol; the splits keep u7's per-template DPC.
* **CF** (`c2b_cf.py`): a probabilistic grammar with one nonterminal per sort, shared by all templates. (The first
  version called this "the brief's Q"; the brief does not fix one nonterminal per sort, and a grammar whose
  nonterminals carry (depth, parent, index) is SDPC. Referee m11.)

L(H) − L(H_true) in bits (positive: the posterior keeps T_Ind whole). **Computed** (`c2_mdl.out`, `c2b_cf.out`).

*G1 (all seven roots occur, so H_used = H_root; prior part +780):*

| n | NAIVE | PC | DPC | SDPC | RDPC | CF |
|---:|---:|---:|---:|---:|---:|---:|
| 1000 | −223.0 | +2325.3 | +2700.6 | +770.0 | +1676.6 | +709.8 |
| 4000 | −3526.0 | +2300.6 | +2815.5 | +767.9 | +2569.0 | +549.2 |
| 16000 | −16466.1 | −1198.5 | −3035.6 | +765.8 | +3724.6 | −301.8 |
| 64000 | −68242.6 | −19783.4 | −34412.3 | +763.8 | +4836.8 | −3583.1 |
| 256000 | −274655.9 | −94088.5 | −163027.5 | +761.9 | +5985.9 | −17241.7 |

*G2 and G3, H_used (the paper's split; prior part +425 under G2, +310 under G3), and SDPC for H_root (prior part
+780):*

| law | n | NAIVE | PC | DPC | SDPC | RDPC | CF | SDPC, H_root |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| G2 | 1000 | −926.0 | +1129.8 | +1417.1 | +403.7 | +870.1 | +236.5 | +769.9 |
| G2 | 16000 | −21484.6 | +1035.8 | +2805.3 | +393.7 | +1566.1 | −2341.2 | +765.8 |
| G2 | 256000 | −350773.1 | −12391.6 | +4289.5 | +383.7 | +2346.1 | −45211.8 | +761.8 |
| G3 | 1000 | −1300.8 | +772.5 | +543.0 | +284.6 | +931.3 | +270.0 | +769.7 |
| G3 | 16000 | −24985.6 | −3058.9 | −9258.6 | +272.8 | +1736.6 | −246.7 | +765.8 |
| G3 | 256000 | −404445.7 | −75061.9 | −186306.5 | +260.8 | +2564.9 | −7814.9 | +761.9 |

**Reading.**
* **SDPC** (a learned grammar, shared and positioned in the sentence) keeps T_Ind whole by about the prior
  difference. The margin is not constant (referee m2): it falls by 1.0 bit per doubling of n for H_root, by 2.5 for
  H_used under G2 and by 3.0 under G3. Proposition 2.3 gives the exact form. Extrapolated crossovers: n ≈ 2^780
  (H_root), 2^171 (G2, H_used), 2^105 (G3, H_used).
* **RDPC** keeps T_Ind whole with a margin growing like log n under all three laws: H_root's per-template grammar has
  more parameters, and they buy nothing.
* **CF does not fix the split.** The split wins at a linear rate (−0.067 bits per datum on G1 and −0.177 on G2 for
  H_used at n = 256000). Under CF the motive's root is coded with the pooled distribution of all formula symbols,
  which is not the distribution of roots; moving the root into the template index buys that KL divergence per
  induction datum. (Correction, referee m1: with every template charged, CF on G2 at n = 4000 gives +55 for H_root,
  not −300.)
* **First lesson: the finding is about Q.** A template split pays off linearly whenever the grammar ignores a feature
  that the split conditions on and that usage depends on.

**Proposition 2.1 (proved; chain rule).** Fix the parameters. Let H_true have weight w on T_Ind and body law
Q(φ) = Q(root f)·Q(rest | f). Let H_F have weights w·Q(f) on T_f and body law Q(· | f), with F ⊇ supp(root). Then
P_{H_F} = P_{H_true} on every datum.

*Proof.* For an induction datum Ind(φ) with root f, P_{H_F} = w·Q(f)·Q(φ|f) = w·Q(φ) = P_{H_true}. Ground data have
the same weight under both. ∎

So with a well-specified shared grammar and fixed parameters the data cannot separate the split from the schema
(model Prop 2.6(b) proves the same, also under L1). With learned parameters the comparison is decided by Occam
terms. The next proposition gives them exactly.

**Proposition 2.3 (Occam identity; exact part proved, expansion proved under the stated growth condition).** (New.
The numbers 2.1 and 2.2 of `notes.md` are kept, so that other tracks' citations stay valid; Prop 2.2 is in §2.4.)
* *Setting.* L0 with a Dirichlet(½) citation index (sequential KT over the templates of the hypothesis) and a shared,
  learned, positional grammar (sequential KT per context c, alphabet A_c). Let H and H' be hypotheses and D a data
  sequence such that:
  1. every datum is covered by exactly one template of H and exactly one of H';
  2. there is a set C of grammar contexts such that, datum by datum and in the same order, H' codes exactly the
     (context, symbol) pairs that H codes outside C, and codes nothing in C.
* *Exact identity.* With n_τ the citation counts and m_{c,a} the symbol counts in context c,
  L(H') − L(H) = Δprior + KT(n'; |H'|) − KT(n; |H|) − Σ_{c∈C} KT(m_c; |A_c|),
  where KT(k; A) := −log₂ of the Dirichlet(½) marginal of a count vector k over an alphabet of A symbols.
* *Expansion.* If every nonzero count grows linearly in n, then
  KT(k; A) = N·Ĥ(k) + ((A−1)/2)·log₂N + κ(A, j) + o(1), with N = Σk, Ĥ the empirical entropy in bits, j the number
  of nonzero counts and κ(A, j) = [(1−j)/2·ln 2π + j·lnΓ(½) − lnΓ(A/2)]/ln 2.
* *Consequence.* If moreover C contains a single context c, all data that visit c are covered by the same template of
  H, and the template of H' is a function of (the template of H, the datum's symbol in c) and conversely, then the
  entropy terms cancel exactly, and
  L(H') − L(H) = Δprior + ((|H'| − |H|) − (|A_c| − 1))/2 · log₂n + O(1).
  For a split of T_Ind into the roots F under SDPC this is Δprior + ((|F| − 9)/2)·log₂n + O(1).

*Proof.*
* *Exact identity.* Sequential KT in a context equals the Dirichlet(½) marginal of that context's counts, whatever
  the order (**known**, Krichevsky–Trofimov; it is the Pólya-urn form of the Dirichlet-multinomial). The total code is
  a sum over the index and over the contexts. By hypothesis 2 the two hypotheses have the same count vectors in every
  context outside C, hence equal terms there. H' has no counts in C. The index and prior terms remain.
* *Expansion.* KT(k; A)·ln 2 = lnΓ(N + A/2) − lnΓ(A/2) − Σ_{a: k_a>0}[lnΓ(k_a + ½) − lnΓ(½)]. Stirling,
  lnΓ(m + a) = (m + a − ½)ln m − m + ½ln 2π + o(1), applied to the j + 1 growing arguments gives
  N ln N − Σ k_a ln k_a + ((A−1)/2)ln N + (1−j)/2·ln 2π + j lnΓ(½) − lnΓ(A/2) + o(1); the first two terms are N·Ĥ
  in nats.
* *Consequence.* The empirical entropies satisfy n·Ĥ(n') = n·Ĥ(n) + m_c·Ĥ(m_c) by the chain rule, since the H'
  template is the pair (H template, symbol in c) up to a bijection. Collect the log terms; the constants are O(1). ∎

**Computed check.** For every n and law, `c2_mdl.out` prints the identity next to the SDPC code length; they agree to
the printed precision (e.g. G1, n = 1000: +770.0 and +770.015). The expansion gives the slopes −1 (|F| = 7), −2.5
(|F| = 4) and −3 (|F| = 3) bits per doubling, as observed. The same identity, with several contexts in C, explains
the narrow theories of §4.3 and the head-symbol split of §5.5.

### 2.3 Never-used roots: the used-roots split gains at a logarithmic rate

Prop 2.3 explains the G3 effect of the first version exactly. H_true's grammar pays ½·log₂n for each formula symbol
never used at the motive root (9 − |F| of them), while H_used pays (|F| − 1)/2·log₂n for its extra index weights.
Under G3 the net is 3 bits per doubling in favour of the split; the crossover is near n ≈ 2^105 (`c2_mdl.out`). The
same effect appears in §5.5 for x+0=x, where it is a Bayesian ω-gap.

### 2.4 What a derivation likelihood changes

**Proposition 2.2 (proved, checked; and known for the converse).**
* H_F derives every instance of induction if F contains a non-atomic connective. The wrappers are ¬¬P, P∧P, P∨P,
  (0=0)→P, ∀zP and ∃zP; each is logically equivalent to P and has the required main connective.
  `checks/c2_detour.py` checks a schematic derivation of Ind(P) from Ind(w_f(P)) for each. (This is a special case
  of Prop 4.8.)
* If F = {=}, H_F is contained in IOpen, so it is strictly weaker than PA: IOpen does not prove the irrationality of
  √2 (**known**: Shepherdson, "A non-standard model for a free variable fragment of number theory", Bull. Acad.
  Polon. Sci. 12 (1964) 79–86; verified through secondary sources), and PA proves it.

**Computed** (`c2_detour.out`). Overhead of the detour over citing Ind(P):

| root | wrapper | lines | overhead (bits) |
|---|---|---:|---:|
| ¬ | ¬¬P | 17 | 409.9 |
| ∧ | P∧P | 17 | 441.6 |
| ∨ | P∨P | 17 | 441.6 |
| → | (0=0)→P | 19 | 488.9 |
| ∀ | ∀zP | 17 | 369.2 |
| ∃ | ∃zP | 19 | 425.6 |

**Consequences.**
* **(a) No incompleteness at the level of theorems.** Under L0 a split is incomplete, and one datum with an unsplit
  root has probability 0 and kills it. Under L1 the split derives every induction instance, and such a datum costs
  370–490 bits. So MDL's error "towards incompleteness for schemas" (`AS:app:many:mdl`) is removed by a derivation
  likelihood once the split contains a non-atomic root. This is conv §7's "at the level of theorems it is nearly
  trivial", with a cost attached.
* **(b) The usage effect is unchanged.** On data whose roots are all covered, an L1-sch derivation of a direct
  instance is one citation, so the comparison is that of §2.2: decided by the grammar.
* **(c) The unsoundness error** ("towards unsoundness for rarely used ground axioms") is not removed either (§5.4).
  Under L1 the size principle does not even see inconsistency (Prop 5.3).

**Answer to question 2.** A derivation likelihood does not change *which templates* the posterior picks: that is
decided by the instantiation grammar, for the linear gain (NAIVE, PC, DPC, CF) and for its absence (SDPC, RDPC). It
changes the *consequences*: a split with a non-atomic connective is deductively equivalent to PA, and the verifier
V_{δ,d} then accepts every induction instance (for d large enough to contain the 17–19-line detours).

---

## 3. Theorem data: statements given without proof (new; referee M3)

The user proposed that "statements given without proof in our data set should be fairly easily derived from axioms".
Then the data are *theorems*, not axiom instances. The first version never computed this case.

### 3.1 Setting

* Data are sentences θ₁, θ₂, … that are theorems of the human's axioms, given without proof.
* Competitors: a theory T that derives them; T ∪ {θ}, which adopts a theorem as a ground axiom ("memorises" it); and
  Q ∪ S, which memorises a set S of theorems and has no induction.
* Code: L1-sch, as in §1. D_T(θ) denotes the bits of the cheapest derivation of θ from T in the library, and c the
  bits of a one-line citation.

### 3.2 The memorisation threshold

**Proposition 3.1 (proved; accounting).** Let D contain θ exactly r times, and let the best derivations of the other
data be the same under T and T ∪ {θ}. Then, under L1-sch,
  L(T ∪ {θ}; D) − L(T; D) = β|θ| + ΔI − r·(D_T(θ) − c),
where ΔI is the change in the citation-index cost of the other data (log₂((k+1)/k) per citation with the track's
uniform index over k axioms). So, up to ΔI, adopting θ at its first occurrence is cheaper iff
  β < β*(θ) := (D_T(θ) − c)/|θ|.

*Proof.* Adding θ adds β|θ| prior bits. Each occurrence of θ costs c instead of D_T(θ). The other data change only
through the index. ∎

**Computed** (`c6_theorem_data.py` → `c6_theorem_data.out`; all derivations checked by `nd.py`; the library is
`checks/thm.py`). In T_Ind = Q1–Q7 + Ind (8 axioms), β = 4.52:

| theorem | statement | \|θ\| | lines | D_T(θ) | memorise (β\|θ\| + c) | D/memorise | β*(θ) |
|---|---|---:|---:|---:|---:|---:|---:|
| snx | ∀x ¬Sx=x | 7 | 11 | 224.6 | 38.2 | 5.9 | 31.2 |
| mul0 | ∀x 0·x=0 | 7 | 14 | 281.3 | 38.2 | 7.4 | 39.3 |
| add0l | ∀x 0+x=x | 7 | 11 | 220.1 | 38.2 | 5.8 | 30.5 |
| addSl | ∀a∀v Sa+v=S(a+v) | 13 | 23 | 576.0 | 65.3 | 8.8 | 43.8 |
| comm | ∀q∀x x+q=q+x | 11 | 55 | 1358.6 | 56.3 | 24.2 | 122.9 |
| assoc | ∀a∀b∀x (a+b)+x=a+(b+x) | 17 | 27 | 793.4 | 83.4 | 9.5 | 46.3 |

* Memorising wins at the first occurrence for every theorem: β = 4.52 is far below β* = 30–123 bits per symbol.
  The referee's four theorems (recursion conventions) give β* = 30.5–45.6, the same picture.
* Structural reason (computed for this library, not a theorem about all derivations): every derivation ends with a
  tc line that writes the theorem, or with a tc line that writes a universal subformula of it, followed by ∀I lines
  (and, in addSl, a renaming). So D_T(θ) is about β|θ| plus the cost of all the other lines, while memorising costs
  β|θ| plus one citation.
* The usage effect of §1 transfers to theorem data: the same theorems cost 1148–4164 bits more in T_CVI and
  2241–8117 more in T_LNP (upper bounds: Ind is re-derived from CVI or LNP at each use). The referee's direct T_CVI
  derivation of ∀x(0+x=x) costs 652 bits more, against 1161 here; both are upper bounds.

### 3.3 Lemma reuse

**Computed** (`c6_theorem_data.out` (b)). Commutativity with its two lemmas (add0l, addSl) derived in-line costs
1358.6 bits; with the lemmas adopted as axioms, 504.7 bits. The lemmas cost 90.5 bits of prior. So by Prop 3.1 they
are adopted at the first use of commutativity. In general a lemma used r times is adopted once r·(saving) exceeds its
prior: frequently used lemmas become axioms. This is §1's usage effect, and universal's Prop U12(c).

### 3.4 Compressible theorems and template adoption

**Computed** (`c6_theorem_data.out` (c); seed 41). For a datum f(φ) with a random motive φ, per-datum bits under
three hypotheses: derive f(φ) in Q1–Q7 + Dlt + Ind (the schematic derivation of §1, plus β|φ|); memorise it
(β|f(φ)| + c); adopt the template f(P) (c + β|φ| per datum, plus β|f(P)| once).

| f | \|φ\| | derive in T_Ind | memorise | adopt template f(P) |
|---|---:|---:|---:|---:|
| Ind | 21 | 101.5 (a citation) | 431.7 | = derive |
| Ind | 429 | 1947.1 (a citation) | 8053.9 | = derive |
| CVI | 20 | 1565.0 | 332.2 | 97.0 (+81 once) |
| CVI | 418 | 3365.4 | 5733.3 | 1897.3 (+81 once) |
| LNP | 21 | 2335.5 | 350.3 | 101.5 (+86 once) |
| LNP | 400 | 4050.0 | 5493.6 | 1815.9 (+86 once) |

* A schema compresses its instances by a factor of about |f(φ)|/|φ| ≈ 4. Direct uses of an axiom schema are the
  data on which a theory beats memorisation.
* For a non-primitive form, deriving beats memorising only for long motives (the switch lies between |φ| ≈ 120 and
  420 in the output), and adopting the template beats both after one or two uses.

### 3.5 Theorem streams

**Computed** (`c6_theorem_data.out` (d); seed 42). Data: with probability u a fresh induction use Ind(φ); otherwise
one of the six library theorems, uniformly. Code lengths relative to T_Ind, with the uniform citation index:

| u | n | T_Ind + library | Q + library (+ memorised uses) | MAP |
|---:|---:|---:|---:|---|
| 0 | 10 | −4905 | −4978 | Q + library |
| 0 | 1000 | −561857 | −562036 | Q + library |
| 0.1 | 10 | −2999 | −2574 | T_Ind + library |
| 0.1 | 1000 | −513380 | −489898 | T_Ind + library |
| 0.5 | 1000 | −285950 | −147800 | T_Ind + library |

* With theorems only (u = 0), the MAP is Q + library from the first datum. It is Q plus six PA-theorems, a finite
  subtheory of PA, hence strictly weaker than PA (PA is not finitely axiomatisable; **known**, Ryll-Nardzewski, "The
  role of the axiom of induction in elementary arithmetic", Fund. Math. 39 (1952) 239–263).
* With any steady fraction of direct induction uses (u = 0.1, 0.5), the MAP is T_Ind + library, which has exactly
  the theorems of PA. The library theorems are still memorised: lemmas become axioms (§3.3).

### 3.6 The well-specified case: the generator beats memorisation

The memorisation result above is for a computable two-part code on human-like data. If the data come from the
theory's own derivation process (L1, full sum over derivations), the opposite holds.

**Proposition 3.2 (proved; Gibbs).** Let ℓ(s) ≥ 0 satisfy Σ_s 2^(−ℓ(s)) ≤ 1, for example ℓ(s) = β|s| for a
Polish-notation code over at most 2^β symbols. Let P be a probability on sentences with finite entropy. Then
  E_{s∼P}[−log₂P(s)] ≤ E_{s∼P}[ℓ(s)],
with equality iff P(s) = 2^(−ℓ(s)) for all s.

*Proof.* Let Z := Σ_s 2^(−ℓ(s)) ≤ 1 and q(s) := 2^(−ℓ(s))/Z. Then
E[ℓ(s) + log₂P(s)] = Σ_s P(s) log₂(P(s)/(Z q(s))) = KL(P ‖ q) − log₂Z ≥ 0, with equality iff P = q and Z = 1. ∎

*Consequence.* Adopting a new datum s as a ground axiom costs at least ℓ(s) = β|s| prior bits. So on data drawn from
P_{T*}, the generator's own code length on a new datum is, in expectation, no larger than the prior cost of
memorising it. Memorisation can then gain only on repeated data.

**Proposition 3.3 (proved, given model Thm 2.1 and the known facts cited).** Let the data be i.i.d. from PA's L1
generator, with all grammar weights positive and parameters admissible in the draws of logical-axiom instances, ∀E
terms and Gen (so supp P_PA = Th(PA), model Lemma 1.7(c)), in a countable class with π(PA) > 0.
* Every theory Q ∪ S with S a finite set of PA-theorems has posterior 0 after finitely many data, almost surely.
* π_n(C*) → 1 almost surely, where C* is PA's generator class.

*Proof.* Th(Q ∪ S) ⊆ Th(PA). Equality would make PA finitely axiomatisable, which it is not (Ryll-Nardzewski 1952,
**known**). So some σ ∈ Th(PA) ∖ Th(Q ∪ S) has P_PA(σ) > 0 and P_{Q∪S}(σ) = 0. It appears in the data almost surely.
The second claim is model Thm 2.1 (Doob's theorem for a countable class). ∎

Theories T* ∪ S that memorise on top of the generator have a different generator for generic weights, so by model
Thm 2.1 they lose too. Their decay should be polynomial, like a spare slot (model Prop 5.5); **proof sketch** for
this case, and I did not check whether some special weight makes P_{T*∪S} = P_{T*}.

### 3.7 The 0/1 "must prove" variant

**Proposition 3.4 (proved).** Use model's S_prove with bounded derivability, together with R_d: the score of T is 1 iff
every datum is in Th_d(T) and T is not refuted, and 0 otherwise. Then:
* (a) the posterior is the prior restricted to the theories with score 1;
* (b) among those, Q+Ind is preferred to Q ∪ {θ₁,…,θ_m} once β·Σ_i|θ_i| > β|Ind(P)| (72 bits; two library theorems
  suffice, e.g. 31.7 + 58.8 bits), provided d covers Q+Ind's derivations (11–55 lines here);
* (c) any unrefuted theory with a smaller prior that derives every datum within d beats both, for example the bare
  formula metavariable F₀ (one symbol), or an inconsistent theory whose shortest refutation is longer than d.

*Proof.* (a) is the definition. (b) compares prior bits. (c) as well: F₀ has every sentence as an instance, and an
inconsistent theory derives every sentence. ∎

So the hard constraint "the givens are easily derivable" removes the memorisation problem, but only by giving up the
size principle (model Prop 1.9(b)). It then needs refutation (negative data, or R_d) to remove over-general and
inconsistent theories, as in §5.4 and F6.

### 3.8 Answer: when does a derivation-length likelihood find Q+Ind from theorem data?

* **When the data come from Q+Ind's own derivation process** (Props 3.2, 3.3). This is well-specification, which
  human mathematics does not satisfy: human theorems are selected for short statements and interest, not sampled
  from a derivation grammar.
* **When the data contain direct uses of the schema**, or long theorems with short proofs (§3.4, §3.5).
* **When the axiom prior is much steeper than the proof code**: β ≥ β*(θ) ≈ 30–120 bits per symbol here, against
  4.52 for proof text. (A steeper prior on axioms than on proofs is one reading of Hänni's steeper simplicity
  penalty; experiments E7 tests λ = 2 for other reasons.)
* **Under the 0/1 constraint with refutation** (Prop 3.4).

Otherwise, on short theorems with long proofs, the computable two-part code memorises, and the resulting theory is
strictly weaker than PA (§3.5). Model Example 3.6 finds the same pattern with a generative (not two-part) equational
derivation grammar on closed theorems t = 0: an over-general escape template beats Q4, Q5 whenever Q makes the data's
terms cheaper than the derivation steps.

**Relation to the time penalty (brief H6).** The full-sum likelihood that makes the generator beat memorisation
(Prop 3.2) has an undecidable support and is expensive to approximate (model Prop 2.7). A time-bounded approximation
that sums over the derivations found within the bound lower-bounds μ_T(θ), so it overestimates the code length
−log₂μ_T(θ); the two-part code is the extreme case of one derivation. So a time bound on computing the likelihood
pushes the posterior towards adopting theorems with long proofs as axioms. The first version said this for "deep
theorems with no short proof" and did not compute it (old F9). §3.2 shows that, under this code, it already holds for
11-line proofs.

---

## 4. Data from Th(ℕ), the IΣₙ chain, and narrow practice

Data are i.i.d. true sentences under a law μ on Th(ℕ). No r.e. theory derives all of them.

**Proposition 4.1 (proved).** Use the bare 0/1-support likelihood: P_T(d) > 0 iff T ⊢ d (L1 with every rule, template
and grammar symbol of positive weight). Suppose μ has full support on Th(ℕ). Then every consistent r.e. theory T has
posterior 0 after finitely many data, almost surely.

*Proof.* If T proves a false φ, then ¬φ ∈ Th(ℕ) and T ⊬ ¬φ by consistency. Otherwise T ⊆ Th(ℕ); Th(ℕ) is not r.e.
while T's theorems are, so some true σ has T ⊬ σ. In both cases a sentence s with μ(s) > 0 and P_T(s) = 0 exists, and
the probability that it is absent from n draws is (1−μ(s))ⁿ → 0. ∎

**Proposition 4.2 (proved; refutation rule as in Def 0.4; referee m6, m8).**
* Under the bare 0/1 likelihood (no refutation rule), inconsistent theories derive every sentence and are never
  refuted.
* Under R_∞ every inconsistent theory is refuted by the first datum, but R_∞ is not computable.
* Under R_{d_n} with d_n → ∞, each fixed inconsistent theory is refuted after finitely many steps, since its shortest
  refutation has some finite size.
* No computable rule does better uniformly: consistency of r.e. theories is Π₁-complete, hence undecidable (**known**;
  standard). `AS:thm:many:depth` is a related but different statement, about DTRC-type accept sets on a family of
  practices with oracle R-Δ₀; the first version cited it too loosely here.

**Computed: a toy model of the drift** (`c3_tower.py` → `c3_tower.out`; seed 1).
* Setup: a datum has a level ℓ, the least k with T_k ⊢ it, along T₀ = PA, T_{k+1} = T_k + Con(T_k). Levels are i.i.d.
  Geometric(ρ). The prior is 2^(−b(k+1)) with b = 50. Each T_k generates its own theorems with a truncated geometric
  level law, rate s.
* The toy covers only the provable part of the data. Under a full-support μ on Th(ℕ) a positive fraction of the data
  is unprovable in every T_k, since the union of the T_k is r.e.; those data would be exceptions for every theory
  (referee m10).
* Results: the MAP level equals the largest level seen (16 at n = 10⁵ for ρ = ½; logarithmic drift). The posterior
  probability that the next datum is unprovable decays like 1/n (7.63·10⁻⁶ at n = 10⁵). The regret against the true law
  grows like b × (largest level): 798.9 bits at n = 10⁵ for ρ = s = ½. With misspecified s (s = 0.3, ρ = 0.5) the
  regret is linear (0.2637 bits per datum). With L_ε (ε = 0.01) the MAP lags the record and the regret is lower
  (674.0 bits).
* Why the drift goes through ground sentences: by Prop 4.3 the reflection schema is not a template, so in DT° each
  step up the progression adds a ground sentence. Model Prop 6.5 shows that one ground sentence (a uniform Σₙ
  reflection principle via a partial truth predicate) suffices per step.

**Proposition 4.3 (proved; the reflection schema contains no non-ground template).** Let Refl_T be the set of
sentences Pr_T(⌜φ⌝) → φ, φ a sentence, with ⌜φ⌝ a unary numeral S^k0. Every DT° template τ with inst(τ) ⊆ Refl_T is
ground. (This upgrades the first version's proof sketch. The argument is that of model Prop 6.4, for Hänni's
assigner schema, adapted.)

*Proof.* Suppose τ has a metavariable M with an occurrence at position q. Constant bodies exist for each sort with two
different root symbols: λz̄.0 and λz̄.(0+0) for terms, λz̄.(0=0) and λz̄.¬(0=0) for formulas. For a constant body, the
subtree of τθ at q is that constant (`AS:lem:setting:preservation`).
* *Case 1: q is the root, or lies inside the antecedent.*
  * If q lies inside the numeral argument, choose θ(M) := λz̄.(0+0). Then the argument of Pr_T in τθ contains +, so
    it is not a numeral, and τθ ∉ Refl_T.
  * Otherwise q is the root or a position of Pr_T's own fixed skeleton. All members of Refl_T carry the same symbol
    there. Choose a constant body with a different root symbol; then τθ ∉ Refl_T.
* *Case 2: no metavariable occurs at the root or in the antecedent.* Then the antecedent is a fixed formula
  Pr_T(N₀). Every member of Refl_T with that antecedent is Pr_T(⌜φ₀⌝) → φ₀ for the single φ₀ with ⌜φ₀⌝ = N₀. So
  inst(τ) has at most one element. But a template with a metavariable has infinitely many instances: each type has
  infinitely many bodies, and θ ↦ τθ is injective (`AS:thm:setting:matching`(a)). Contradiction.
So τ has no metavariable. ∎

The same argument applies to Hänni's assigner schema "T(⌜φ⌝) = accept → φ" (model Prop 6.4).

**Proposition 4.4 (proved; regret against a theory plus exceptions).** Use L_ε with mixture
P_mix(D) = Σ_T π(T)·Π_{d∈D} L_ε(T; d). For every theory T in the class and every data sequence D_n, let E(T, D_n) be
the set of data that T does not derive and does not refute. Then
  −log₂P_mix(D_n) ≤ −log₂π(T) + Σ_{d∈D_n∖E} −log₂((1−ε)P_T(d)) + Σ_{d∈E} −log₂(εμ₀(d)).
The same holds with 0/1 support (ε = 0) with T replaced by T ∪ E (memorised exceptions), whose exceptions cost prior
bits, β|e| each.

*Proof.* P_mix(D_n) ≥ π(T)·Π_d L_ε(T; d). For d ∉ E, L_ε(T; d) ≥ (1−ε)P_T(d); for d ∈ E, L_ε(T; d) ≥ εμ₀(d). Take
−log₂. ∎

**Remark 4.5 (proved; pointwise limits are trivial).** Under 0/1 support and full-support μ, each fixed true s
eventually appears in the data, and from then on every surviving theory derives s. Each fixed false s has ¬s
eventually in the data, and from then on every surviving *consistent* theory fails to derive s. So "every sentence is
eventually decided correctly" is achieved by memorisation alone. With inconsistent theories present the second
statement needs R_{d_n} (Prop 4.2). Whether the posterior mass of not-yet-refuted inconsistent theories deriving s
tends to 0 is **open**; their likelihood can be large (Prop 5.3).

### 4.1 The IΣₙ chain

In the Gold model the chain IΣ₁ ⊂ IΣ₂ ⊂ … with union PA is a limit point, so no learner identifies PA from a text of
theorems (conv §§7–10).

**Proposition 4.6.**
* **(a) Proved, given known facts; referee m7.** Let the data be i.i.d. theorems from PA's L1 generator (full support
  on Th(PA): positive weights and parameters admissible, model Lemma 1.7(c)). Represent each IΣₙ (n ≥ 1) in DT° as
  Q plus a single sentence σₙ (IΣₙ is finitely axiomatisable for n ≥ 1; **known**). Then each IΣₙ has posterior 0
  after finitely many data, almost surely, and moreover π_n(C*_PA) → 1 almost surely in any countable class with
  π(PA) > 0.

  *Proof.* IΣ_{n+1} ⊢ Con(IΣₙ) (**known**: Hájek and Pudlák 1993, Cor. I.4.34, as traced by the referee through
  arXiv:2101.03384; primary location not verified), so PA ⊢ Con(IΣₙ). IΣₙ ⊬ Con(IΣₙ) by Gödel's second theorem, since
  IΣₙ is consistent (it is true). So P_PA(Con(IΣₙ)) > 0 = P_{IΣₙ}(Con(IΣₙ)), and Con(IΣₙ) appears almost surely.
  Eliminating each IΣₙ is not yet concentration on PA, because the tail {IΣ_m : m > N} could hold mass. Model Thm 2.1
  (Doob, countable class) gives π_n(C*_PA) → 1, and no IΣₙ is in C*_PA since its generator has a different
  support. ∎

  The waiting time for Con(IΣₙ) is about 1/P_PA(Con(IΣₙ)), which is astronomically large (model Prop 5.2 makes the
  same remark).
* **(b) Proof sketch.** Before that happens, σₙ is penalised per use. Deriving Ind(φ) for a Σₙ motive φ from σₙ needs
  the Tarski biconditional for the partial truth predicate at ⌜φ⌝ (model Prop 6.5 uses the same predicate), a
  derivation whose length grows with |φ|. Citing T_Ind costs L_Q(φ) plus a constant. So on induction-use data the
  schema wins at a linear rate. I did not formalise this or check the growth rate.
* **(c) Refuted** (referee M4). The first version claimed: "if the community uses only Σₙ motives, every DT° theory
  that covers its practice as citations contains PA-strength induction; so in DT° the posterior lands on the L∞ side."
  Two counterexamples follow in §4.3. The step that fails: the anchor theorem `AS:thm:zf:indanchor` is about a
  *single* covering template, and the wrappers of Prop 2.2 need a *formula* metavariable under the connective. (The
  referee also says that the anchor theorem is stated only for parameter-free motives. That part is not right:
  `AS:thm:zf:indanchor` states that the result holds "in closure-normal form with parameters" by
  `AS:cor:single:special`(c). The single-template scope is the real gap.)

### 4.2 Which induction templates give full induction

**Lemma 4.7 (proved; equivalent motives).** If ⊢ ∀p̄∀x(χ ↔ ψ) in a theory B, then B + Ind(χ) ⊢ Ind(ψ).

*Proof.* From ∀x(χ ↔ ψ), instantiated at 0, at x and at Sx: ψ(0) gives χ(0), and ψ(x) → ψ(Sx) gives χ(x) → χ(Sx). So
the antecedent of Ind(ψ) gives that of Ind(χ). Ind(χ) gives ∀xχ, hence ∀xψ. Generalise over the parameters. ∎

**Proposition 4.8 (proved; read-once induction templates).** Let τ = T_Ind[P := λx.C], where C is a *read-once*
formula template: built from connectives and quantifiers over atoms; every atom is either A(x, z̄) = B(x, z̄) with
term metavariables A, B, or a formula-metavariable occurrence F(x, z̄); z̄ lists the bound variables in scope; and
each metavariable occurs once in C. Let Q1 be ∀u¬(Su = 0).
* (a) If C contains a formula metavariable, then Q1 + inst(τ) ⊢ Ind(ψ) for every formula ψ. So any theory containing
  τ and Q has all of PA's induction.
* (b) If C contains no formula metavariable, every instance of τ is Ind(χ) for a χ with C's formula skeleton (the
  tree of logical symbols with the atoms' terms erased). So Q + inst(τ) ⊆ IΣ_k, where Σ_k bounds the prenex
  complexity of that skeleton, and a finite set of such templates is contained in some IΣ_k ⊊ PA.

*Proof.*
* (a) Fix the path from C's root to one occurrence F(x, z̄). Instantiate every other atom as a constant: ⊤ := (0 = 0)
  (A := λ.0, B := λ.0), ⊥ := (S0 = 0) (A := λ.S0, B := λ.0), and every other formula metavariable as λ.(0=0) or
  λ.(S0=0). Q1 refutes S0 = 0. A read-once formula is not constant in its atoms, so each sibling subtree on the path
  can be made ⊤ or ⊥ as needed: ⊤ beside ∧ and ↔, ⊥ beside ∨, ⊤ as the antecedent of → when the path goes to the
  consequent, and ⊥ as the consequent when the path goes to the antecedent (then that step acts as a negation, as
  ¬ on the path does).
  Quantifiers on the path become vacuous: set F := λx z̄.ψ'(x), which ignores z̄. Then Q1 ⊢ ∀x(Cθ ↔ ψ') or
  Q1 ⊢ ∀x(Cθ ↔ ¬ψ'), by propositional logic, Q1 and the vacuous-quantifier laws. Take ψ' := ψ in the first case and
  ψ' := ¬ψ in the second (then ¬¬ψ ↔ ψ). Lemma 4.7 gives Ind(ψ).
* (b) Term metavariables are replaced by terms, which contain no logical symbols, so the skeleton of every instance is
  C's. A formula with a fixed skeleton is logically equivalent to a prenex formula of a fixed complexity Σ_k, and
  Lemma 4.7 turns the instances into Σ_k induction. IΣ_k ⊬ Con(IΣ_k) by Gödel's second theorem, while PA ⊢ Con(IΣ_k)
  (**known**, as in Prop 4.6(a)). ∎

The wrappers of Prop 2.2 are instances of (a); `c2_detour.py` checks six of them.

**Remark 4.9 (proved, checked; the read-once condition is sufficient, not necessary).** The template
Ind(λx. x=0 ∨ F(x)) has a rigid atom, so Prop 4.8 does not apply, and no instance is logically equivalent to Ind(P).
Yet Q1, Q2 + Ind(χ) ⊢ Ind(P) for χ(x) := x=0 ∨ ∃y(x = Sy ∧ P(y)), by shifting the motive. `checks/c9_shift.py` checks
the derivation (47 lines; 1403.3 bits against a 15.4-bit citation). So which non-read-once templates give full
induction is **open**.

### 4.3 Narrow practice: the posterior can land on the weaker side

**Computed counterexample 1** (`c8_narrow.py` part (A); the referee's `r8`, re-checked independently, seeds 31 and 33).
* *Practice.* Q, plus induction on motives of two shapes: ∃z(s=t) (Σ₁) and ¬(s=t) (open), s and t random terms, x
  free. There are two main connectives and x is free, so the premise of the old 4.6(c) holds.
* *Theory.* H_narrow = Q + T_E + T_N, with T_E = Ind(λx.∃z(A(x,z)=B(x,z))) and T_N = Ind(λx.¬(C(x)=D(x))); A, B, C, D
  are term metavariables.
* *Covering.* Every datum is covered by H_narrow (checked on 3000 data per seed).
* *Strength.* Every T_E instance is Σ₁ induction and every T_N instance is open induction, so Q + H_narrow ⊆ IΣ₁ ⊊ PA
  (Prop 4.8(b)).
* *Posterior.* Under the positional grammar of §5, L(H_narrow) − L(H_true) is +230.8, +212.5, +192.5, +174.6 bits at
  n = 100, 300, 1000, 3000 (seed 31). The exact identity of Prop 2.3 (with C = the three formula contexts that
  H_narrow fixes: the motive root and the two "=" positions) reproduces these numbers to 0.1 bit. The slope is
  (9 − 8)/2 − 3·(9−1)/2 = −11.5 bits per doubling, and the extrapolated crossover is n ≈ 2^26.7. Seed 33 gives the same
  to within 2 bits.
* So on this practice the posterior ends on the *weaker* side.

**Computed counterexample 2** (`c8_narrow.py` part (B); u7's natural law G1, seed 11 as in `c4_bdtrc.py`).
* G1's motives have depth 2 and quantify only atoms, so they have finitely many formula skeletons: exactly 157
  (counted on 200 000 motives, seed 12; 1 + 7 + 3·49 + 2 by hand).
* The skeleton theory H_skel = Q + {Ind(skeleton with term metavariables)} covers G1 (checked on 3000 data). Each G1
  motive is a Boolean combination of atoms and of single quantifiers over atoms, hence logically equivalent to a Σ₂
  formula, so Q + H_skel ⊆ IΣ₂ ⊊ PA. So the coverage claim of the old 4.6(c) fails even for G1.
* But here the posterior keeps PA. With the 112 skeletons seen in 3000 data, L(H_skel) − L(H_true) = +42838.5 bits
  (prior part +43040), and the identity matches the code. With all 157 skeletons, the asymptotic slope is
  (164 − 8)/2 − 19·(9−1)/2 = +2.0 bits per doubling (19 formula contexts): H_skel falls further behind. (Here C has
  19 contexts, so the entropy terms of Prop 2.3 cancel only asymptotically: G1 draws each connective independently
  given its context, so the difference is O_P(1) by Wilks's theorem for nested multinomial models. **Proof
  sketch.**)

**Conjecture 4.10.** For a practice whose motives have unbounded depth and use every connective at every depth with
positive probability, the posterior mass on theories that derive all of PA tends to 1. Why it is not proved:
covering theories may use non-read-once templates (Remark 4.9), whose strength is not classified.

**General lesson (revised).** In DT° the posterior draws the line between *theory* (what templates entail) and
*usage* (what the grammar makes probable). Positive data identify usage. Deductive strength beyond usage is decided by
an Occam balance (Prop 2.3): when the entropy terms cancel, a theory of term-only templates gains (|A_c| − 1)/2 bits
per doubling for each grammar context it fixes, and pays ½ bit per doubling for each extra template. Narrow practice (few skeletons) puts the
posterior on the narrow, weaker side; broad practice (many skeletons relative to contexts) puts it on the PA side.
This is the Bayesian form of conv §9's L∞-versus-L₅ choice, and the first version's "DT° forces the L∞ choice" is
**refuted**.

**What is the right notion of success for Th(ℕ)?**
* *Identification* is impossible (Prop 4.1). *Pointwise limiting correctness* is trivial (Remark 4.5). *Soundness at
  all times* fails in general (§6, F4).
* What can be promised: **(i) predictive competitiveness** against every theory in the class, paying its exceptions
  (Prop 4.4; per-datum regret vanishes when the exception rate does, as in the toy); **(ii) depth-relative
  soundness**: theories refuted within the current depth carry no mass (Prop 4.2; the residue-relative soundness of
  `AS`).
* Completeness along a path through ordinal notations (Turing 1939; Feferman 1962; cited from memory) is not
  effective, and DT° does not express reflection (Prop 4.3), so I make no claim.

---

## 5. Unlabelled mixtures: a Bayesian DTRC

### 5.1 The model, and the cost of a spare slot

**The model.**
* Hypotheses are finite sets of DT° templates; the prior is 5 bits per template symbol (each template costs bits, so
  a prior on the number of templates is implicit); weights are Dirichlet(½).
* One shared positional grammar for all bodies (Def 0.3). Negative data refute under R_0.
* Candidates are hand-picked (`c4_bdtrc.py` → `c4_bdtrc.out`). I do **not** compute the posterior over all finite
  unions.

**Proposition 5.1 (proved; cost of a spare slot).** Adding a never-used template τ to a theory with K templates costs
β|τ| + ½·log₂n + log₂(Γ(K/2)/Γ((K+1)/2)) + o(1) bits. So a spare slot's posterior odds decay like n^(−1/2)·2^(−β|τ|).

*Proof.* The Dirichlet(½) marginal of counts (n₁…n_K, 0) over K+1 categories, divided by that of (n₁…n_K) over K,
equals Γ((K+1)/2)Γ(n+K/2) / (Γ(K/2)Γ(n+(K+1)/2)). By Stirling, Γ(n+a+½)/Γ(n+a) ~ n^(1/2). ∎

Check: for K = 8 and τ = (F→F) (15 bits) the formula gives 19.03 bits at n = 1000 and 19.82 at n = 3000; the computed
values are +19.0 and +19.8. (Model Prop 5.5(a) is the same result.)

### 5.2 Q + Ind practice

**Computed** (u7 law G1, induction with probability ½, seed 11). L − L_true in bits; the table is generated from `c4_bdtrc.out` (referee M1: the first version had eight wrong entries at n = 1000 and 3000):

| candidate | n=10 | n=30 | n=100 | n=300 | n=1000 | n=3000 |
|---|---:|---:|---:|---:|---:|---:|
| true Q+T_Ind | 0 | 0 | 0 | 0 | 0 | 0 |
| root split (7 T_f) | +776.4 | +773.6 | +772.7 | +771.4 | +769.9 | +768.3 |
| spare Q+T_Ind+(F→F) | +15.9 | +16.6 | +17.4 | +18.2 | +19.0 | +19.8 |
| memorise instances | +1792.3 | +5392.7 | +15901.1 | +41418.2 | +133845.4 | +399693.6 |
| over-general Q+T_L∞ | +549.5 | +1500.6 | +3832.5 | +8964.3 | +27876.8 | +82717.0 |
| lump F₀+T_Ind | −174.7 | −42.0 | +319.3 | +1048.9 | +3205.5 | +8929.8 |
| bare F₀ | +584.0 | +2148.6 | +6067.9 | +14712.6 | +46251.0 | +137387.5 |

T_L∞ is Z₁ ∧ ∀x(Z₂(x)→Z₃(x)) → ∀xZ₂(x), the over-general template of `AS:prop:zf:indtwo`.

* **Posterior mass on Q+T_Ind** (`c4_bdtrc.out`). Without negatives: 2.607·10⁻⁵³ at n = 10, 2.204·10⁻¹³ at n = 30,
  and ≥ 1 − 6·10⁻⁶ from n = 100 on (the remainder is almost all on the spare slot: 5.808·10⁻⁶ at n = 100). With the
  two negatives {0=S0, the false T_L∞ instance (0=0)∧∀x(0=S0→0=S0)→∀x(0=S0)}: ≥ 1 − 1.6·10⁻⁵ from n = 10 on.
* **Within this candidate set**, the root split and the spare are deductively equivalent to PA (F→F is a tautology
  schema; the split contains ¬, Prop 2.2). So the mass on PA-equivalents is ≥ 1 − 10⁻⁹⁶ from n = 100 on; the
  remainder at n = 100 is the lump (7.679·10⁻⁹⁷). With negatives the remainder is 0.

### 5.3 Rates

Memorisation, the over-general template, the lump and bare F₀ lose at a linear rate without negatives: the size
principle. The root split gains about 1 bit per doubling of n on Q+T_Ind (+776.4 → +768.3), as Prop 2.3 predicts:
((14 − 8) − (9 − 1))/2 = −1; it would need about 2^770 data to catch up. The spare falls behind by ½ bit per
doubling (Prop 5.1).

### 5.4 Unsound lumps of rarely used ground axioms, and the verifier

**Computed.** At n = 10 and n = 30 the posterior prefers F₀+T_Ind by 174.7 and 42.0 bits. The seven Q-axioms are each seen about once, and the bare metavariable F₀ codes them through the
grammar more cheaply than seven ground templates cost in the prior. F₀ has every sentence as an instance, so the
theory is unsound. This is the Bayesian form of `AS:app:many:mdl`'s "errs towards unsoundness for rarely used ground
axioms". The negative 0=S0 refutes it at once; without negatives the crossover lies between n = 30 and n = 100.
Experiments E2 finds the same effect with a different grammar and a data-derived pool (lumps take ≥ 0.997 of the mass
in 3 of 5 seeds at n ≤ 32).

**The verifier on PA practice (brief H3; computed from `c4_bdtrc.out`).** Take V_{δ,0} (derivability = being an
instance, as under L0). Without negatives, the mass of theories that do not have 0=S0 as an instance is about
2.6·10⁻⁵³ at n = 10 and 2.2·10⁻¹³ at n = 30, because the lump and bare F₀ have every sentence as an instance. So
V_{δ,0} accepts the false sentence 0=S0 at n = 10 and 30 for every δ ≥ 3·10⁻¹³, in particular δ = 0.05. From n = 100
the lump's mass is below 10⁻⁹⁶ and 0=S0 is no longer accepted. With the two negatives it is never accepted. This
does not contradict model Thms 4.7 and 4.8 (soundness with Dirichlet weights; Thm 4.1 is for fixed weights): their
guarantee needs δ ≤ π(C^Dir_d)·δ′ (times a factor R_α(n, K) < 1 at a fixed weight vector), and π(Q+T_Ind) is
2^(−330) in this candidate set (renormalised prior). The u7 data are, moreover, not drawn from a model generator.

**Remark 5.4 (proof sketch; overlapping templates; referee m11).** For candidates whose templates overlap (the lump,
bare F₀), the reported code is a two-part bound: each datum is coded by the cheapest covering template given the
current counts. The exact marginal likelihood sums over the assignments of data to covering templates. Its code
length is at least the body code length under the best assignment, because the index probabilities of all assignments
sum to at most 1. If the best assignment is the greedy one (it puts induction data on T_Ind, whose motive is coded
once, rather than on F₀, which codes the whole sentence), the exact code is at most the greedy index cost, about n
bits for two covering templates, below the two-part code. At n = 100 the lump would still be at least +219 bits
behind, so the mass statements above survive. I did not prove that the greedy assignment is the best one.

### 5.5 ∀xφ as a sound merge, and the rate of the ∀-elimination penalty

Data: t+0=t for u7's random closed terms t (seed 12). L − L_schema in bits (`c4_bdtrc.out`, part (B)):

| candidate | n=10 | n=30 | n=100 | n=300 | n=1000 | n=3000 |
|---|---:|---:|---:|---:|---:|---:|
| schema z+0=z | 0 | 0 | 0 | 0 | 0 | 0 |
| split by head of t (0, S, +, ·): sound | +115.5 | +109.1 | +101.0 | +93.3 | +84.6 | +76.7 |
| memorise instances | +519.5 | +1263.8 | +3749.9 | +12204.1 | +34023.6 | +83197.3 |
| over-general z₁+0=z₂ | +145.5 | +351.5 | +927.2 | +2618.8 | +7975.5 | +22702.2 |
| ∀x(x+0=x), one ∀E step per datum, fixed rule code | +38.2 | +104.7 | +337.2 | +1001.6 | +3326.9 | +9970.8 |

* **The schema wins.** The instance schema is the merge of the instances (`AS:prop:many:forall`).
* **The over-general template** has a false instance and dies with the negative 0+0=S0.
* **A Bayesian ω-gap.** The sound split by head symbol covers every instance whose t is not a bare variable,
  including all closed instances, but not a+0=a, which in closure-normal form is ∀x(x+0=x). (With Q3 in the theory,
  its members S(z)+0=S(z) and 0+0=0 give ∀x(x+0=x) by cases; here the theory is the templates alone.) It closes in at
  about 5 bits per doubling of n. Prop 2.3 explains the rate: the schema's grammar codes t's head in a context with 14
  term symbols, of which the data use 4, and the split pays for 3 extra index weights: (3 − 13)/2 = −5. Extrapolated
  crossover: about n ≈ 10⁸. So with closed-instance data only, the posterior eventually prefers a theory that does
  not entail ∀x(x+0=x). Universal Thm U10 and model Example 3.2 give the same gap in other models.
* **The universal sentence loses, at a rate set by the rule code (referee M5).** The last row charges the extra ∀E
  step a fixed log₂10 bits per datum (uniform over the 10 rules), so its odds fall like 2^(−3.3n). The first version
  called this "H4's prediction". That exponential rate is a property of the fixed rule code. **Computed**
  (`c7_rulecode.py` → `c7_rulecode.out`), L(H_∀) − L(H_sch) in bits, R = 10 rules:

  | n | fixed | learned, one shared context | learned, context = depth in the derivation |
  |---:|---:|---:|---:|
  | 10³ | 3321.9 | 2004.0 | 41.1 |
  | 10⁶ | 3321928.1 | 2000004.0 | 85.9 |

  * With a learned depth-indexed rule law the penalty is (R−1)/2·log₂n + O(1) (4.31·log₂n at n = 10⁶, tending to 4.5):
    polynomial odds. With R = 2 (universal's calculus {cite, ∀E}) it is ½·log₂n + O(1).
  * In a mixed practice where a fraction f of the data are φ-instances and the rest are direct citations of other
    axioms, the extra step shares the root context with those citations. It then costs h(f) bits per datum
    (h the binary entropy; 0.469 at f = 0.9, 1.000 at f = 0.5): linear again.
  * The **direction** (H_sch preferred) holds under every code (it is universal's Thm B); the **rate** is a property
    of the rule code and of the practice, like the template splits of §2.

### 5.6 Negative data, refutation, and "does not contradict"

* **Refutation** is R_d (Def 0.4). Each true datum d refutes every theory that derives ¬d within the current depth, so
  true data act as negative data for their negations.
* **Proposition 5.2 (proved; pure "does not contradict" learns nothing).** If L(T; d) = μ₀(d)·[T ⊬ ¬d] with μ₀
  independent of T, the posterior is the prior restricted to data-compatible theories. *Proof:* the likelihood is the
  same constant μ₀(D) for every compatible theory and 0 otherwise. ∎ So the empty theory and every weak compatible
  theory keep their prior ratio, and no axiom gains mass. Hänni asks for weight depending on "how many of the given
  statements can be proven"; L_ε is the minimal model that does this: a theory pays −log₂(εμ₀(d)) for data it does not
  derive, so it is credited for derivations and not killed by gaps. (Model Prop 1.9(b) is the general statement.)
* **Proposition 5.3 (proved; the size principle does not see inconsistency).** Under L1 with citation weights, let
  T' = T ∪ {σ} with fixed weights, a fraction w going to σ. Then P_{T'}(d) ≥ (1−w)^{c(d)}·P_T(d), with P_T the
  two-part (best-derivation) likelihood and c(d) the number of citations in d's best T-derivation. With Dirichlet
  weights the cost of σ is at most its prior plus about ½log₂n (Prop 5.1). *Proof:* every T-derivation is a
  T'-derivation whose citations each lose a factor (1−w). ∎ So adding a sentence that makes T inconsistent costs no
  more than adding a useless true sentence, unless derivations through the contradiction are what explains the data.
  Consistency must be enforced by R_d, not by the size principle.

**Answer to question 4.** From unlabelled Q+Ind data the posterior recovers Q+T_Ind and puts almost all mass on it,
from n ≈ 100 without negatives and from n = 10 with two negatives, **within the hand-picked candidate set**.
Fragmentations and spare slots survive; both are PA-equivalent here; the spare decays polynomially and fragmentation
is held back by its prior, gaining only O(log n) when parts of the schema are never used. Not scored here: the
posterior over all unions, narrow term-only theories (§4.3), and stronger theories such as PA + Con(PA) (a spare slot;
by Prop 5.1 and model Prop 5.5 it would decay polynomially; not computed). Negative data remove unsound lumps at small
n, and in general the false templates of §6.

---

## 6. Robust failures, and whether they are fixable

* **F1. Usage over logic** (§1; computed). The posterior identifies the usage-closed axiomatisation, not the textbook
  minimal one. It is not a bug: the likelihood is right to prefer it. To recover "the textbook axioms" one must change
  the target: report the deductive equivalence class, or use a prior with strong pressure for independence. More data
  do not help: the effect grows with n.
* **F2. Grammar misspecification produces fragmentation** (§2; computed). Under NAIVE, PC, DPC or a
  one-nonterminal-per-sort grammar, splitting T_Ind wins at a linear rate. A shared, positional grammar conditioned on
  every feature a split could use holds the split at the prior margin, up to Occam terms (Prop 2.3). Some feature can
  always be left out of the grammar, and then a split pays off linearly if usage depends on it.
* **F3. Never-used parts of a schema** (§§2.3, 5.5; proved and computed). Splits that exclude never-used parts win at
  rate (number of unused symbols)/2 · log₂n minus their index cost (Prop 2.3). This includes the Bayesian ω-gap for
  x+0=x. At the level of theorems it is harmless under L1 if a non-atomic connective is covered (Prop 2.2). Not
  fixable at the level of templates without a prior choice.
* **F4. False generalisations whose counterexamples are rare or absent** (computed: `c5_euler.py` → `c5_euler.out`).
  * Data: true sentences Prime(k·k+k+41), with k geometric(ρ) conditioned on primality (the false k are 40, 41, 44, 49,
    56, …). H_sch is the template Prime(z·z+z+41): false. H_mem memorises: true.
  * Sizes are now measured on syntax trees (`nd.size`): m := k·k+k+41 occurs three times in
    Prime(m) := ¬m=0 ∧ ¬m=S0 ∧ ∀a∀b(a·b=m → a=S0 ∨ b=S0), and the logical frame has 27 symbols. The first version
    counted m twice (referee m9). The correction strengthens the conclusion.
  * The posterior prefers the false schema by 5.1·10⁴ bits at n = 100 and 3.1·10⁵ bits at n = 10⁶ (ρ = 0.9; flat
    grammar: 51445 and 314225). For ρ = 0.97 the figure is 1.8·10⁶ bits at n = 10⁶.
  * No finite union of unguarded templates that covers these data is true without memorising (**proof sketch**: a
    template covering infinitely many data needs a metavariable at or above a numeral position, so its instances
    include k = 41j, for which k²+k+41 is divisible by 41).
  * With a depth-indexed grammar, the schema's predictive probability of the counterexample k = 40 falls like 1/n
    (5.00·10⁻⁷ at n = 10⁶). Yet H_sch still *entails* Prime(40·40+40+41), which is false.
  * Under the flat grammar the linear KL term (about 0.007 bits per datum for ρ = 0.9) must eventually outweigh
    memorisation's prior, which grows like (log n)²; that happens beyond n = 10⁶ (**proof sketch**). Under the
    depth-indexed grammar both costs grow like (log n)², and the false schema stays ahead (**proof sketch**; constants
    estimated, not computed).
  * Not fixable from positive data. Fixable for this example by refutation (40²+40+41 = 41²). In general refutation
    depth is unavoidable, since consistency and Π₁ truth are undecidable (Prop 4.2; `AS:thm:many:depth` is the
    corresponding statement for DTRC).
* **F5. Rarely used ground axioms are merged unsoundly at small n** (§5.4; computed). One negative datum removes it, as
  does a little more data. Until then a threshold verifier accepts 0 = S0.
* **F6. Inconsistency is invisible to the size principle under L1** (Prop 5.3; proved). Fixable only by R_{d_n};
  its adequacy cannot be certified (Prop 4.2).
* **F7. No well-specified hypothesis for Th(ℕ)** (§4; proved and computed). The posterior drifts. Fixable in the sense
  of Prop 4.4 (regret), not as identification.
* **F8. Deductive strength beyond usage is decided by Occam terms, not forced** (§4.3; proved and computed; revised).
  The first version said "DT° forces the L∞ (PA) choice". **Refuted.** On narrow practice the posterior moves to a
  term-only theory inside IΣ₁ (crossover near n ≈ 2^26.7). On G1 it keeps PA. In the IΣₙ chain under well-specified
  data, Con-type theorems separate IΣₙ from PA only at astronomical waiting times (Prop 4.6). Truth-safe in this chain
  (all are true); unsafe where the stronger theory can be false (conv §9).
* **F9. Computing the likelihood** (§§0, 3). L1 needs derivation search; shortest derivations are not computable in
  general, and the constants here are upper bounds. Bounding search changes which theories look good: theorems with
  long proofs become axioms (now computed, §3.2).
* **F10. Theorem data are memorised** (§3; computed; new). On distinct short theorems given without proof, the
  two-part derivation code prefers "Q + the theorems" to Q+Ind, a theory strictly weaker than PA. Fixable by direct
  uses of the schema in the data, by a much steeper axiom prior, by well-specified data, or by the 0/1 constraint with
  refutation (§3.8).

---

## 7. Overall answer for PA and ZF (revised; referee M2)

**What holds, and on what evidence.**
* A Bayesian template inducer with a derivation likelihood does **not** robustly pick up the textbook axioms. It picks
  up the axioms that are *used* (§1, F1).
* **Within the hand-picked candidate sets scored here, and for data that are direct uses of axioms** (axiom-instance
  data), it puts nearly all posterior mass on theories deductively equivalent to PA. In three of the four cases this
  is automatic, because every candidate compared is PA-equivalent by construction: the usage mixes of Ind, CVI and LNP
  (§1.2), the recursion conventions (§1.3) and the splits by main connective (§2). Only the Bayesian DTRC run of §5
  has non-equivalent competitors, and there PA-equivalents get mass ≥ 1 − 10⁻⁹⁶ from n = 100.

**Where it fails, robustly.**
* **Theorem data** (§3, F10): memorising theories strictly weaker than PA win under the computable code.
* **Narrow practice** (§4.3, F8): term-only theories inside IΣ₁ overtake Q+T_Ind logarithmically.
* **Absent counterexamples** (F4): a false schema is preferred by 3.1·10⁵ bits at n = 10⁶.
* **Small n** (F5): unsound lumps take the mass, and a threshold verifier accepts 0 = S0.
* **Inconsistency** (F6): invisible to the size principle; only refutation at growing depth removes it.

**Competitors not scored** (so the positive statements are relative to them): the posterior over all finite template
unions; non-read-once templates (Remark 4.9); stronger true theories such as PA + Con(PA) (spare slots); ZF candidates
beyond the derivations of §1.4.

---

## 8. Cross-track consistency

I read the current notes of the other tracks: `../model/notes-final.md`, `../universal/notes-final.md` and
`../experiments/notes.md` (experiments had no `notes-final.md` when I read it). The model track's final notes already
cite this file's numbering; universal and experiments cite `notes.md` of this track (see the numbering map in §8.1).

### 8.1 Aligned in this revision

| item | this track now | was (notes.md) | matches |
|---|---|---|---|
| posterior | π_n(T) := π(T \| D_n) | "the posterior" | model §2, universal §1.5 |
| generator class | C* := {T : P_T = P_{T*}} | not used | model §2, universal §1.6 |
| generative derivation likelihood | L1 = model's normalised tree grammar | "the family of brief H1" | model L1 (universal "L1-norm") |
| best single derivation | L1-max; this track's computable instance is L1-sch, which charges per written symbol, i.e. the two-part form of model's L1^σ | "two-part" | universal L1-max; model §1.5, §2.4, §6.5 |
| bounded depth | L2 / Th_d | "bounded variant" | model L2, Th_d |
| Hänni's variants | S_prove, S_nc, S_g; L_ε = noisy likelihood restricted to non-refuted sentences | "must prove", "must not contradict" | model §1.5; universal S_prove, S_nc,β, P^η |
| refutation | R_d, stated once (Def 0.4) | implicit, inconsistent between §3 and §4.6 | model Th_d |
| verifier | V_{δ,d}; with Dirichlet weights model Thms 4.7–4.8 | "accept s iff mass ≥ 1−δ" | model §4; experiments Prop X8 |
| concentration (Doob) | model Thm 2.1 | Doob by name | model Thm 2.1, universal Lemma U7 |
| support of L1 | needs parameters admissible (model Lemma 1.7(c)); stated in Props 3.3, 4.6(a) | implicit | model Lemma 1.7(c) |
| computability of L1 | value computable, support undecidable (model Prop 2.7) | "not computable" | model §2.4 |
| splits are likelihood ties | Prop 2.1 = model Prop 2.6(b) | Prop 2.1 alone | model §2.3 |
| Dirichlet α | ½ | ½ | model, experiments, universal (new checks) |
| section numbers | §3 is new (theorem data); old §3 → §4 (old Prop 3.5 → 4.6), old §4 → §5 (old §4.5 → §5.5), old §5 → §6, old §6 → §9 | — | universal §12 and experiments §10 cite the old numbers |

### 8.2 Results that agree across tracks

* **Splits and the MDL finding.** Model Props 2.6(b), 5.4 and 5.6 (a schema and its split are ties for fixed
  parameters, under L0 and L1; with learned weights the split is the schema with a learned root law; misfit usage gives
  a linear gain) agree with §2. Experiments E2 (frag-complete about 700 bits behind T* under a well-specified grammar)
  and E3(b) (splits win under a misspecified motive law) agree with §2's two regimes.
* **Spare slots.** Model Prop 5.5(a), experiments X7 and E5, and Prop 5.1 here give the same n^(−1/2) law.
* **Unsound lumps at small n.** Experiments E2 (Q-lumped ≥ 0.997 in 3 of 5 seeds at n ≤ 32; a false sentence accepted
  at δ = 0.05) and §5.4 here.
* **Theorem data favour generators other than the axioms.** Model Example 3.6 (a generative equational derivation
  grammar: an escape template beats Q4, Q5 on closed theorems t = 0 unless Q makes the terms expensive), model
  Example 3.2 and Remark 3.5, and §3 here (two-part code: memorisation beats Q+Ind on short theorems) are the same
  phenomenon in three models: a theory wins only on what its derivations compress.
* **∀xφ from instances.** Universal Thm U2 / Thm B (instance data never favour ∀xφ over its schema) and §5.5 here
  agree on the direction. Universal reads this track's old §4.5 penalty as its L1-max row with c = 1/10, which is
  right for the fixed rule code.
* **ω-gap.** Universal Thm U10, model Example 3.2 and the head-symbol split of §5.5 are the same phenomenon.
* **Lemmas become axioms.** Universal Prop U12(c) and §3.3 here.
* **Identification is of the generator.** Model Prop 2.5, experiments E6 and §1 here.
* **Well-specified concentration.** Model Thm 2.1 underlies Props 3.3 and 4.6(a) here; model §5.2 ("memorisation
  dies") agrees with Prop 3.3; model Prop 5.2 (the data law decides between L₅ and L∞) agrees with Prop 4.6(a).
* **Reflection is not a template.** Model Prop 6.4 (Hänni's schema) and Prop 4.3 here use the same argument; model
  Prop 6.5 (one ground reflection sentence suffices) explains why the toy tower of §4 adds one ground sentence per
  step.

### 8.3 Remaining differences

* **Sign of the fragmentation drift.** Model Prop 5.4 (Q fixed, the whole template cited alone) gives the unsplit
  template (K−1)/2·ln n in its favour; experiments E2 (a fixed PCFG) sees frag-complete fall further behind by about
  3.3 bits per doubling (asymptote 4). Here, under SDPC (a *learned* grammar), the split *gains* (9 − |F|)/2 bits per
  doubling. Prop 2.3 reconciles them: when Q is fixed only the split pays Occam terms; when Q is learned, H_true pays
  for its root context too, and the balance is the alphabet size against the number of split templates. The model
  track's final notes (§11.3) state the same reconciliation.
* **Rate of the ∀-elimination penalty.** Universal Prop U2c: with one learned c shared by all nodes, the per-datum
  factor stays below ½. Here (c7) a rule law learned *per depth* gives polynomial odds on pure instance data, and h(f)
  bits per datum in a mixed practice. Both agree on the direction (Thm B); the rate depends on whether rule
  probabilities may depend on the position in the derivation.
* **Which code length a derivation likelihood charges.** L1-sch charges written symbols; model's plain L1 charges
  grammar choices, which can be exponentially fewer (model §6.5, Prop 6.9 refuted there). The β* thresholds of §3.2
  are for symbol counts; under plain L1 a derivation that substitutes large terms would be cheaper than its written
  size. I did not recompute §3 under plain L1.
* **Memorisation.** Model §5.2 (well-specified: memorisation dies) and Remark 3.5 (misspecified: memorise frequent
  data plus an escape template wins, conjecture); universal U6 (memorisers keep exp(−O(log²n)) under geometric
  numerals); here §3 (theorem data under the two-part code: memorising short theorems wins at the first occurrence;
  under well-specification it loses, Props 3.2–3.3). Different settings; each statement holds in its own.
* **Calculi and codes.** Model uses Mendelson's K as a tree grammar (and an equational grammar in Example 3.6);
  universal uses chains C_min and C_open; experiments use chains with K ≤ 2 steps; this track uses natural deduction
  with a two-part proof-text code that is not derived from a generative grammar. Numerical rates are not comparable
  across tracks; the qualitative statements are.
* **Instantiation grammar.** Fixed PCFGs in model, universal and experiments; a KT-learned positional grammar here.
* **Symbol counts and priors.** `nd.size` counts a quantifier and its variable as 2 symbols; `dtlib` and universal
  count a de Bruijn ∀ as 1; experiments use a stochastic template code; model uses a prefix code π_λ. Prior shares
  differ accordingly: universal §6.6 reports the prior share of H_∀ in {H_∀, H_sch} as 0.03–0.04 under this track's
  code against 0.333 and 0.484 elsewhere.
* **Strength of a covering theory.** Model Prop 5.2 treats L∞ versus L₅ for well-specified data (the data law
  decides). §4.3 here adds that, for misspecified human practice in DT°, narrow practice can put the posterior on the
  weaker side. The statements concern different data laws and do not conflict.

---

## 9. Verification log

### 9.1 Referee issues and their resolution

| issue | resolution | where | how checked |
|---|---|---|---|
| **M1** §4 table differs from `c4_bdtrc.out` (8 entries) | accepted; table regenerated from the output by a script, and every quoted number in this file is checked mechanically against the outputs | §5 table | `c10_quotes.py` → `c10_quotes.out` (all quotes found) |
| **M2** overall answer claims untested robustness | accepted; answer restated with the qualifiers "within the hand-picked candidate sets" and "axiom-instance data"; the failures and the unscored competitors are listed | §7, §5 answer | text; supported by §3, §4.3 |
| **M3** theorem data not treated; memorisation beats derivation | accepted; new section: memorisation threshold β*, lemma reuse, compressible theorems, theorem streams, the well-specified case (Gibbs, Doob), the 0/1 variant, the H6 link | §3, F10 | `thm.py` (5 new derivation schemes), `c6_theorem_data.py` (19 checked derivations); Props 3.1–3.4 proved |
| **M4** Prop 3.5(c) and F8 refuted | accepted; claim kept as refuted with the referee's counterexample (re-checked independently) and a second one (G1 skeleton theory); new Lemma 4.7, Prop 4.8 (read-once dichotomy), Remark 4.9, Conjecture 4.10; F8 and the summary rewritten | §4.1–4.3, F8 | `c8_narrow.py` (identity = c4 code to 0.1 bit); `c9_shift.py` (checked) |
| **M5** exponential ∀E rate is a property of the rule code | accepted; rate reported with the code; learned depth-indexed rule law gives (R−1)/2·log₂n; mixed practice gives h(f) per datum | §5.5 | `c7_rulecode.py` (reproduces the referee's r3 numbers) |
| **m1** H_root not charged for unused templates | accepted; every template charged; H_used added (the paper's H_F); u7 bookkeeping printed for reproduction | §2.2 | `c2_mdl.py`, `c2b_cf.py`; reproduction of `AS:tab:many:mdl` at n = 1000 |
| **m2** SDPC margin not constant | accepted; exact Occam identity and expansion (Prop 2.3) | §2.2 | identity printed next to the code length at every n; slopes −1, −2.5, −3 |
| **m3** break-even "iff" is code-specific | accepted; qualified; decodable and naive-code ratios added | §1.2 | `c1_costs.out` |
| **m4** proof-text code not decodable | accepted; `bits_decodable` added (+4.8% to +7.3%) | §0, §1.2 | `c1_costs.out` |
| **m5** wrong lower-bound argument | accepted; replaced by Prop 1.4 (≥ log₂10 + 11β) | §1.2 | proof; sizes in `c1_costs.out` |
| **m6** refutation rule inconsistent between sections | accepted; one rule R_d (Def 0.4), Prop 4.2 restated | §0, §4 | proof |
| **m7** eliminating each IΣₙ is not concentration | accepted; Doob via model Thm 2.1 added | Prop 4.6(a) | proof |
| **m8** `thm:many:depth` cited too loosely | accepted; replaced by Π₁-completeness of consistency | Prop 4.2, F4, F6 | text |
| **m9** Euler: m occurs three times | accepted; sizes measured with `nd.size`; lead is now 3.1·10⁵ bits at n = 10⁶ | F4 | `c5_euler.out` equals the referee's r4 "3 occurrences" column at every checkpoint |
| **m10** toy tower covers only provable data | accepted; sentence added | §4 | text |
| **m11** wording; two-part bounds; anchor scope | wording and two-part remark accepted (Remark 5.4, proof sketch). The anchor-scope remark is **not** right: `AS:thm:zf:indanchor` holds in closure-normal form with parameters (by `AS:cor:single:special`(c)); the real gap is the single-template scope (M4) | §2.2, Remark 5.4, Prop 4.6(c) | `AS` zfc.tex, theorem statement |
| missed Q1: theorem data | done | §3 | as M3 |
| missed Q2: posterior over all unions | not done; the Occam identity (Prop 2.3) gives the mechanism by which narrow unions compete | §4.3 | — |
| missed Q3: H6 in PA terms | partly: §3.8 (time bound on likelihood computation favours memorisation); Prop 4.6(b) remains a sketch | §3.8 | — |
| missed Q4: H3 verifier on PA data | done: V_{δ,0} accepts 0=S0 at n ≤ 30 without negatives | §5.4 | read off `c4_bdtrc.out` |
| missed Q5: misspecification with human data | partly: §3 (theorem data), F4 (Euler) | §3, F4 | — |

### 9.2 Checks

| what | how | result |
|---|---|---|
| checker soundness (`nd.py`) | `test_nd.py`: 10 unsound steps | all 10 rejected (eigenvariable conditions on ∀I and ∃E, non-tautology, capture, mismatched substitution, wrong goal, open hypotheses, quantified atom in tc, wrong ∃I witness); the referee's 173 mutants were also all rejected |
| Prop 1.1 derivations A, B, C1, C2 | checked schematically in P; replayed on 200 random concrete motives with a parameter (seed 20261008) | all checked; 200/200 replays; independently re-checked by the referee (`r1_recheck.py`) |
| Prop 1.5 (recursion conventions) | 4 derivations (`c1_costs.py`) | all checked |
| ZF derivations SepJ←ReplJ, Found←EInd, ReplK←Coll, ReplJ←Coll+SepJ | checked schematically (`c1_costs.py`, `zf.py`) | all checked; the checker found a capture bug in my SepJ constructor, fixed |
| per-use costs, decodable variant, break-even (three codes), phase grid, naive-code growth, cited base axioms, lower-bound sizes | `c1_costs.py` → `c1_costs.out` (deterministic; naive part seed 7) | as quoted in §1; decodable adds 4.8–7.3% |
| theorem library (6 theorems × 3 theories, comm with cited lemmas) | `thm.py`, `c6_theorem_data.py` → `c6_theorem_data.out` (seeds 41, 42) | all 19 derivations checked; as quoted in §3 |
| reproduction of u7 | `c2_mdl.py` at n = 1000 with u7 bookkeeping | NAIVE/PC/DPC identical to `AS:tab:many:mdl` (G1 −223/+2325/+2701; G2 −915/+1141/+1428) |
| corrected MDL table, H_used, SDPC identity | `c2_mdl.py` → `c2_mdl.out`; `c2b_cf.py` → `c2b_cf.out` (seeds random.Random(n)) | as in §2.2; identity equals the computed SDPC code length at every n and law (to 0.1 bit) |
| wrapper derivations | `c2_detour.py` → `c2_detour.out` | all six checked |
| toy drift | `c3_tower.py` → `c3_tower.out` (seed 1) | as quoted; independently re-implemented by the referee (`r5_tower.py`): identical |
| Bayesian DTRC candidates and ∀-merge | `c4_bdtrc.py` → `c4_bdtrc.out` (seeds 11, 12) | tables of §5 generated from this output |
| spare-slot formula (Prop 5.1) | closed form against computed | 19.03 vs 19.0; 19.82 vs 19.8 |
| Euler example | `c5_euler.py` → `c5_euler.out` (seeds 5, 6; trial division) | as quoted; equal to the referee's closed-form recomputation with three occurrences |
| rule codes for ∀E | `c7_rulecode.py` → `c7_rulecode.out` (closed form) | fixed and learned-shared linear, learned-depth (R−1)/2·log₂n, mixed h(f) per datum; matches the referee's r3 |
| narrow practice and G1 skeletons | `c8_narrow.py` → `c8_narrow.out` (seeds 31, 33, 11, 12, 13) | coverage true; identity = c4 code; slopes −11.5 and +2.0; crossover 2^26.7 |
| shift derivation (Remark 4.9) | `c9_shift.py` → `c9_shift.out` | checked, 47 lines |
| quoted numbers | `c10_quotes.py` → `c10_quotes.out`: numbers are extracted from each output by a regular expression, formatted as this file prints them, and the formatted string must occur here; tables are generated row by row | 87 quotes checked, 0 failed. Negative test (on a scratch copy with three planted errors, one of them the old M1 value 6440): exactly those three failed |
| reproducibility | every script re-run from the final code with `PYTHONDONTWRITEBYTECODE=1`; outputs compared with the saved `*.out` | see §9.3 |
| references | web search, abstracts and catalogue records (mine and the referee's) | Zarach 1996, Gitman–Hamkins–Johnstone 2016, Kaye–Wong 2007, Shepherdson 1964 (secondary), Kaye–Paris–Dimitracopoulos 1988 (existence, by the referee), Ryll-Nardzewski 1952 (bibliographic data from `AS`'s bibliography). Not verified: Kaye 1991 and Hájek–Pudlák theorem numbers; Lévy 1979 and Jech 2003 locations; Shoenfield's substitution lemma; Turing 1939, Feferman 1962, Wilks's theorem (from memory); Krichevsky–Trofimov 1981 (standard, not re-checked) |

### 9.3 Reproducibility run

See `checks/c10_quotes.out` for the final run's record. All scripts were re-run after the last code change; the
outputs of `test_nd`, `c1_costs`, `c2_detour`, `c3_tower`, `c4_bdtrc`, `c6_theorem_data`, `c7_rulecode`,
`c8_narrow`, `c9_shift` were byte-identical on a second run; `c2_mdl`, `c2b_cf` and `c5_euler` (several minutes each)
were run once from the final code. [[REPRO]]

### 9.4 Refuted claims (kept, with the reason)

* "Under a shared grammar the root split loses by a growing margin on G1" (first SDPC run: +803 … +12270 bits).
  **Refuted**: an encoding artefact (∀/∃ split bodies coded the bound variable as a hole); after re-plugging, the
  margin is +770 … +762.
* "The sound split of x+0=x by head symbol overtakes the schema at n = 1000" (first c4 run). **Refuted**: an artefact
  of coding split bodies from a root context; under the positional grammar the split stays behind and closes in at
  5 bits per doubling.
* "The SDPC margin is constant from n = 10³ to 2.56·10⁵" (old §2.2). **Refuted** (referee m2): it falls by 1 bit per
  doubling (Prop 2.3).
* "If the community uses only Σₙ motives, every DT° theory that covers its practice contains PA-strength induction;
  in DT° the posterior lands on the L∞ side" (old Prop 3.5(c), F8, Summary). **Refuted** (referee M4): H_narrow ⊆ IΣ₁
  covers a Σ₁/open practice and overtakes Q+T_Ind near 2^26.7; H_skel ⊆ IΣ₂ covers G1.
* "Under L1 the universal sentence's odds fall like 2^(−3.3n); this is H4's prediction" (old §4.5). **Refuted as a
  general rate** (referee M5): true for a fixed rule code; polynomial under a learned depth-indexed rule code.
* "It robustly gets a theory deductively equivalent to PA, with nearly all posterior mass" (old overall answer).
  **Refuted as stated** (referee M2, M3, M4): true only within the candidate sets and for axiom-instance data.
* "Every T_Ind-derivation of CVI(P) costs at least log₂10 + β more than a citation, because it has two lines" (old
  §1.2). **The argument was wrong** (referee m5); the conclusion holds with a correct proof (Prop 1.4).
* Old numbers corrected: eight entries of the old §4 table (M1); G2/G3 margins of the old §2 table (m1); the Euler
  lead (m9: 2.1·10⁵ → 3.1·10⁵ bits at n = 10⁶, ρ = 0.9).

### 9.5 Not done, or open

* Shortest-derivation searches: all overheads are upper bounds (lower bounds: Prop 1.4 only).
* The posterior over *all* finite template unions; only candidate sets were scored.
* A formal derivation of Coll from Repl in ZF, or of EInd from Found.
* The per-use penalty of IΣₙ's single-sentence axiomatisation (Prop 4.6(b)).
* Which non-read-once induction templates give full induction (Remark 4.9, Conjecture 4.10).
* Whether the mass of not-yet-refuted inconsistent theories vanishes (Remark 4.5).
* Whether the greedy assignment is optimal for overlapping templates (Remark 5.4).
* Collection from Replacement in ZF without Foundation (with Power Set).
