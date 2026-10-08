# Referee report on track "universal" (notes.md, checks/)

Adversarial referee. I read the brief, Hänni's notes in `research/prior/`, the cited parts of `axiom-schemas`
(`universal.tex`, `app-universal.tex`, `setting.tex`, `many.tex` §mdl) and of `inferential-learning`
(`caution.tex` thm:caution:ville, `app-caution.tex`), then `notes.md` (all 939 lines) and every script in `checks/`.
I checked each proof line by line. I wrote independent code in `referee_code/`. It does not import the track's
`common.py` or `dtrc`. Each script is seeded and writes `<name>.out` next to itself.

Status markers below: **proved** (proof given here), **computed** (script and output named), **proof sketch**,
**known** (reference), **conjecture**, **refuted**.

## Verdict

No fatal error. The core identities are correct: U1, U2, U3 (within its hypotheses), Thm B, U4, U5, U6(i)–(ii′),
U7, U8, U10(a)(b)(d, quantifier-free φ), U11(a)–(d), U12(a), U13, U14(a), U15, the Ville argument of §10.

Three claims are stronger than what was shown. Each holds only in the small hypothesis class that was computed.

* **U11(e)** ("without a guard the posterior takes the ω-step") is false under L1-norm once the class contains a
  root split or memorisers. These are hypotheses the track itself uses elsewhere.
* **U16(b)/(c) and Summary item 7** ("Split wins"; "P(T ⊢ ∀xφ) = 1 over Q") are artefacts of a three-hypothesis
  class. Deeper splits win, and later memorisers win, which do not prove ∀xφ even over Q.
* **The "instance-only generator" regime** of U10(c) and Summary item 4 exists only in calculi as weak as C_min.

One conjecture is refuted: the Remark after U3, that detours through ∧-rules "cannot" break U3's inequality.

Counts: fatal 0, major 3, minor 11.

---

## Major issues

### M1. U11(e) is false as stated: without a guard, L1-norm moves to root splits, which do not prove ∀xφ

**Claim (notes §7, U11(e); repeated in Summary item 5 and §10 item 4).** "Suppose the class has no guard, as in DT°
under the λ-convention with parameters admissible. Then H_open wins on closed data … and every surviving hypothesis
proves ∀xφ: the posterior takes the ω-step." It is marked **[proved]**, from (c) and U7.

**Problem.** The proof compares only H_open, H_∀ and H_both. That matches the "no guard" class of c5 Part A,
which is just {H_∀, H_open} (`c5_open_quant.py`, `hs = ['forall', 'open']`). The claim is stated for DT°-type classes.
Such a class also contains the unguarded root split R₁ = {φ(0), φ(Sz)} and the deeper splits
R_k = {φ(0), …, φ(S^{k−1}0), φ(S^k z)}. The track uses root splits in c2 and U5, and memorisers in U6.

R_k wastes mass on parameter outputs only through its last template. That template carries weight about q^k.
H_open wastes a fraction ρ on every citation. So R_k beats H_open on closed data. Under the closure reading R_k is
{φ(0), …, φ(S^{k−1}0), ∀xφ(S^k x)}. In pure logic it does not prove ∀xφ.

*Countermodel* (**proved**): take ℕ ∪ {e, e′} with S e = e′, S e′ = e′, 0+e = e′ and 0+e′ = e′, standard on ℕ,
other values arbitrary. Every axiom of R_k holds, and 0+e ≠ e.

**Evidence (computed: `referee_code/r3_noguard.py`, `r3_noguard.out`).**

*Exact laws.* In C_open (c = .3, g = .2, ρ = .1, numerals q = 1/2), with template weight u, R_k gives:

* P(φ(S^j0)) = v_j/Z_R for j < k;
* P(φ(S^{k+m}0)) = (1−ρ)Q_c(S^m0)·u/((1−gcρ)Z_R);
* Z_R = (1 − gcρ + gρu(1+c))/(1−gcρ), in units of K.

These match an independent sampler (max |z| = 2.19).

*Per-datum expected log-likelihood against the true law, in nats:*

| hypothesis | rate |
|---|---|
| H_∀ | −1.572 |
| H_open | −0.125 |
| R₁ | −0.063 |
| R₂ | −0.031 |
| R₃ | −0.016 |

*Posterior, 40 seeds:*

| class | quantity | n = 100 | n = 300 | n = 3000 |
|---|---|---|---|---|
| {H_∀, H_open, R₁} | P(T ⊢ ∀xφ) | 0.880 | 0.000 | 0.000 |
| | mass(R₁) | 0.120 | 1.000 | 1.000 |
| full | P(T ⊢ ∀xφ) | 0.879 | 0.000 | 0.000 |
| | mass(R₃) | 0.000 | 0.001 | 1.000 |

The full class adds R₂, R₃ and memorisers.

*Under L1-sel* (S = closed instances) with the same full class, P(T ⊢ ∀xφ | D_n) → 1. Both H_∀ and H_open
then reduce to the true law. So the ω-step claim holds under L1-sel, not under L1-norm.

**Fix.** State U11(e) for the class actually computed, or under L1-sel. Add the root-split result:

* under L1-norm without a guard, the size principle drifts to ever more specific root splits;
* these prove ∀xφ over Q (by k uses of Q3) but not in pure logic.

Correct Summary item 5 and §10 item 4 accordingly.

### M2. U16(b)/(c) and Summary item 7: "Split wins" holds only in a three-hypothesis class

**Claim.** U16 is marked **[computed: c7]**. It says the class is "sentence-only", "Under L1 the root split
{φ(0), ∀yφ(Sy)} wins on numeral data". It also says "P(T ⊢ ∀xφ | D_n) → 0 in pure logic and = 1 over Q".
Summary item 7 and §10 repeat this.

**Problem.** c7's class is {H_∀, Split, Both0}. All three prove ∀xφ over Q, so "= 1 over Q" holds by
construction. A sentence-only class also contains:

* the deeper splits Split_k = {φ(0), …, φ(S^{k−1}0), ∀yφ(S^k y)};
* finite sets of instances (memorisers).

Under L1-norm, every hypothesis that emits a universal sentence pays a cost linear in n on instance-only data.
Memorisers pay only O(log² n) (U6(ii′)).

**Evidence (computed: `referee_code/r4_sentences.py`, `r4_sentences.out`).** The exact laws are
P(φ(S^j0)) = v_j/(1+cu) for j < k and P(φ(S^{k+m}0)) = ucQ(m)/(1+cu). They match a sampler (max |z| = 1.95).

*Per-datum rate at the best weights, in nats:*

| hypothesis | rate |
|---|---|
| H_∀ | −1.466 |
| Split₁ | −0.733 |
| Split₂ | −0.367 |
| Split₃ | −0.183 |
| Split₄ | −0.092 |
| Split₆ | −0.023 |

The rate halves with each extra level.

*Posterior, 40 seeds:*

| class | quantity | n = 100 | n = 500 | n = 2000 | n = 10⁴ |
|---|---|---|---|---|---|
| {H_∀, Split₁…₄} | mass(Split₁) | 0.000 | 0.000 | 0.000 | 0.000 |
| | mass(Split₄) | 0.392 | 1.000 | 1.000 | 1.000 |
| {H_∀, Split₁…₄, memorisers} | mass(memorisers) | 0.048 | 0.106 | 0.983 | 1.000 |

Memorisers prove ∀xφ neither in pure logic nor over Q. So in this class P(T ⊢ ∀xφ | D_n) → 0 over Q as well.

The track's own ratios check out: 3.768 and 1.130, mean 0.725 nats.

**Fix.** Report U16(b) as a statement about the three-hypothesis class. Replace the conclusion with the robust one:
under L1-norm with instance-only data, any hypothesis citing a universal sentence loses linearly, and the posterior
drifts to ever more instance-specific sentence sets. This strengthens the track's negative message. It removes the
claim "= 1 over Q".

### M3. The "faithful regime with an instance-only generator" exists only in calculi like C_min

**Claim.** U10(c), Summary item 4 (second regime), and §6 ("With a derivation likelihood (L1), instance-only data …
'independent' takes all the mass"). U10(c) passes from "L1-norm over C_min is faithful" to "with a complete calculus
and a full-support grammar, the posterior identifies the deductive closure of T*". It then says "With an
instance-only generator (T* = H_sch), the limit is 0".

**Problem.** A faithful likelihood for a calculus with any rule beyond cite and ∀-elim makes every hypothesis emit
non-instances. Equality rules, propositional rules and the U3 rules all do this. For a complete calculus, every
hypothesis emits all logical validities. So no hypothesis is instance-only. Instance-only data are then always a
selected sample, and L1-norm is misspecified for every hypothesis. U7 and U10(c) do not apply.

The limit is set by the KL-minimiser over the whole class, which the track computes only for very small classes. M1 and
M2 show what that minimiser can be in natural classes: ever deeper root splits, or memorisers. That is a moving target,
not "H_sch". The conclusion "P(T ⊢ ∀xφ) → 0" survives in those examples. The stated mechanism (Doob over E(H_sch))
does not.

**Fix.**

* Restrict the second regime explicitly to C_min-like calculi.
* For richer calculi, state the misspecified (KL-minimiser) version.
* Say that its limit depends on which very specific generators are in the class.

---

## Minor issues

### m1. U6: the memoriser prior with λ = 1 is improper over all sentences

**Claim.** U6 is set up with a product-Bernoulli prior with Σ r_s < ∞. Part (ii′) then uses r_s = 2^{−λ(|s|+1)}.
§1.5 fixes λ = 1, and c3 uses it. c3 states its results "up to an additive constant in [log Z₀, 0]".

**Problem.** Closed terms over {0, S, +, ·} of dtrc size n grow like 3.83^n. So Σ_s 2^{−(|s|+1)} = ∞ over
closed sentences. Then Z₀ = 0, the random F is almost surely infinite, and the (ii′) bound contains log Z₀ = −∞.

The same counting makes π(T) ∝ 2^{−|T|} improper over the full template class. U7 and U10 need a proper prior on a
countable class. The checks use only finite classes, so their numbers are unaffected.

**Evidence (computed: `r6_prior_mass.out`).**

* T(n+1)/T(n) → 3.78, against the limit 1 + 2√2 = 3.83.
* Partial sums over closed equations reach 6.7·10²⁹ at size 120.
* Restricted to instances of 0+x=x the sum converges (0.031), even for all closed t.
* For instances of Sx≠0 over all closed t it diverges.

**Fix.** Name the universe of the memoriser prior: φ-instances, with a condition on φ and Q. Or take λ larger than
log₂ of the growth rate, or use a prefix-free code. The quasi-polynomial conclusion survives. The U6(i) bracket is
correct; it was checked exhaustively in `r7_misc.out` (2): the lower and upper brackets hold in 200/200 random cases.

### m2. Σ₁-completeness of Q fails for formulas with <

**Claim (§2, "Truth questions").** "For Σ₁ formulas φ, every true closed instance is provable in Q … So under Hä1, Q
stays admissible for every true Σ₁ φ."

**Problem.** L_A contains <. Q as defined in axiom-schemas `setting.tex` l.156 (Q1–Q7) has no axiom for <.
`app-universal.tex` restricts its citation to <-free Δ₀ formulas for exactly this reason. The track's own example
x < Sx is a counterexample. ℕ with < interpreted as ∅ is a model of Q in which 0 < S0 fails. **Proved**; illustrated
in `r5_models.out` (2).

**Fix.** Restrict to <-free Σ₁ formulas, or add a defining axiom for <.

### m3. U10(c) conflates ⊢_C and ⊢

**Problem.** Prov is defined with ⊢ (first-order provability), but the limit in (c) is stated as
1[T* ⊢_C ∀xφ].

**Counterexample (proved).** Take C_min and T* = {∀x(φ ∧ ψ)}. Then T* ⊬_{C_min} ∀xφ, so the stated limit is 0. But
every T in E(T*) has the same C-theorems. Its axioms are C-theorems. So T is first-order equivalent to T*, and
P(T ⊢ ∀xφ | D_n) → 1.

**Fix.** Either define Prov with ⊢_C, or state the limit as 1[T* ⊢ ∀xφ]. The second needs that all axioms lie in X.

### m4. U10(b) "or learned weights" is outside U7

**Problem.** A hypothesis with a Dirichlet prior on its weights has an exchangeable law, not an i.i.d. one. U7 is
proved for countable classes of i.i.d. laws. Also, B⊕∀xφ and B⊕σ_φ with learned weights do not have equal marginal
laws: the reparametrisation changes the prior on the effective weight. The conclusion is plausible: the odds tend to
a ratio of prior densities, by a Bernstein–von Mises argument. It is not proved.

**Fix.** Mark this case **proof sketch**, or treat (T, θ) as the parameter and cite a consistency theorem for smooth
finite-dimensional families.

### m5. U12(b): the table does not test the gradual shift

**Problem.**

* In c5 Part B, T_sch+B has posterior ≤ 0.001 at every n, already at n = 0, because of its prior. So the reported
  P(T ⊢ ∀xφ) = 1 − mass(T_sch) only tracks the refutation of T_sch. That is U12(a). The notes say this themselves
  ("tracks … 1 − (1−f_q)^n").
* "Instance data cost the two theories almost the same (≤ 0.1 nats per datum)" holds only for small θ. At θ = 0.9,
  L = 3, the per-instance log-ratio is about 1.3 nats (**computed by hand** from the closed forms in U12(b)).

**Fix.** Give T_sch+B a comparable prior, report the T_both : T_sch+B log-odds against n, and state the θ range.

### m6. U14(b) does not apply at the default law, and §6 overstates it

**Problem.** The condition q > e^{−(1−μ)²/2} needs q > e^{−1/2} ≈ 0.61, so it fails at the default q = 1/2. U14 is
also about the equational fragment E = {Q4, Q5}, not about Q. Yet §6 says "Q is penalised by its long derivations
… So the posterior favours the schema", with no qualifier.

**Fix.** Either charge the term draws at the leaves, or restrict the §6 sentence. Each Q5 leaf on the shortest chain
must instantiate y with a specific numeral, which suggests a much stronger bound, of order q^{Θ(k²)}
(**conjecture**, not checked).

### m7. U10(d) for quantified φ is unproved

**Problem.** §2 and the verification log say the conclusion "is the same" for quantified φ. Then the filtered law is
not the law of any hypothesis in the class (σ_φ's further eliminations leave S), so U7 does not apply. A KL argument
is needed. For the pair H_∀, H_sch it goes through: both waste the same relative mass, and H_sch is the
KL-minimiser (**proved** by the one-line comparison Z_σ < Z_∀/c). It is not proved for a general class.

**Fix.** Mark it **proof sketch** and state the KL comparison.

### m8. The Remark after U3 conjecture is refuted, though the weaker open problem survives

**Claim (Remark after U3).** Detours through ∧I/∧E on quantified formulas "cannot" make U3's inequality
P_∀ − P⁰ ≤ c(P_σ − P⁰) fail. Marked **[conjecture]**.

**Refutation (proof sketch; computed).** Take the calculus {cite p_c, ∀-elim c, ∧I a, ∧E e} with ∧-rules on all
formulas, φ = 0+x=x, B = ∅ (so P⁰ = 0).

*Spine decomposition.* From the root, an ∧E pushes the chosen side and an ∧I pops it. The other premise of an ∧I is
free, with success mass Z. The spine is therefore a Dyck word followed by a base node: cite, elim, or a top-level ∧I.
Write D(x) = Σ_j Cat_j x^j and x = e·a·Z_T. Then:

* P_∀(φ(t)) = c·D_∀²·p_c·Q(t);
* P_σ(φ(t)) = D_σ·p_c·Q(t);
* Z_T = D_T(p_c + c·P_U + aZ_T²).

The map defining Z_∀ dominates the map defining Z_σ, so Z_∀ ≥ Z_σ. Hence D_∀ ≥ D_σ ≥ 1, and D_∀ > 1 when a, e > 0.
So R := P_∀/P_σ = c·D_∀²/D_σ > c.

*Evidence (`r2_detour.out`).*

* The spine formulas match an independent sampler (all |z| ≤ 2).
* R > c at all 9139 grid points.
* A direct Monte Carlo run with 2·10⁶ derivations gives R = 0.1562 ± 0.0005 against c = 0.15 (13σ).
* On the grid, R < 1 (max 0.925) and the normalised ratio is < 1 (max 0.48). So the weaker statement of §11
  item 1 (no reversal) survives on this family.

The factor c of Thm B, and of Summary item 2, is therefore specific to C_min and the U3 calculi.

**Fix.** Mark the Remark's conjecture **refuted**, with this example. Keep §11 item 1 as stated.

### m9. Inconsistent hypotheses are counted in Prov

**Problem.** In c2 the formula metavariable ?A is instantiated by a law that produces negations. So {?A} is an
inconsistent theory. It is the largest-prior hypothesis in c2, with prior 2^{−2} against 2^{−6} for H_sch.
Under L0, L1 and L1-sel it belongs to Prov and to "T ⊢ ¬∀xφ" at once. Only Hä1 excludes it.

This does not break the Ville bound, which is relative to T*. It does affect:

* the trichotomy shares of U10(b);
* the thresholded verifier at small n, where P(T ⊢ ⊥ | D₀) is about 0.67 in c2's class (**computed by hand**
  from c2's prior).

**Fix.** Exclude inconsistent theories from the class, or report them as a fourth outcome.

### m10. Over-broad wording

* §5: "G contains H_sch, which proves no universal sentence". H_sch proves every valid universal sentence, e.g.
  ∀x(x=x). Say "does not prove ∀xφ".
* §10 item 1: "Its instance schema implies exactly the data and nothing more". Say "generates exactly the instances".
* Summary item 6: "unsafe … for models of Q". It is unsafe for *some* models of Q; ℕ is a model of Q.

### m11. Summary item 1 drops the probability qualifier of U6(ii′)

**Problem.** U6(ii′) proves the bound "with probability ≥ 1 − 1/n". The summary states it without qualifier.

**Fix.** Use 3·log_{1/q} n in place of 2·log_{1/q} n. Then P(K_n ≥ 3·log_{1/q} n) ≤ n^{−2} is summable, and
Borel–Cantelli gives the bound almost surely (**proved**, one line). Either change is fine.

---

## References: what I could verify

Web search worked. arxiv.org, ar5iv, hutter1.net and sciencedirect were blocked.

| reference | what I found |
|---|---|
| Hutter 2007, TCS 384(1):33–48, arXiv:0709.1516 | **Bibliographic data verified.** The abstract's claim "no zero p(oste)rior problem, i.e. can confirm universal hypotheses" is verified. Search snippets confirm the Bayes–Laplace finite-population formula (n+1)/(N+1), which equals the notes' (n+1)/(n+k+1) with k = N−n. The notation H″ and any theorem for M(1^∞ \| 1^n) were **not verified**. The track already flags this; the flag is correct. |
| Leike and Hutter 2015, ALT, LNCS 9355, doi 10.1007/978-3-319-24486-0_23 | **Verified.** Search summaries add that the non-monotonicity occurs infinitely often for the unnormalised prior and finitely often for the normalised one. The notes' use (confirmation is not stepwise monotone) is consistent. |
| Gaifman 1964, Israel J. Math. 2(1):1–18 | **Verified.** Secondary sources state the condition with constants rather than closed terms. That is a harmless variant. |
| Gaifman and Snir 1982, JSL 47(3):495–548 | **Verified.** |
| Doob 1949, Colloques Internationaux du CNRS 13:23–27 | **Verified** via Doob's bibliography and Dubins–Freedman 1963. |
| Parikh 1973, Trans. AMS 177 | **Verified.** The pages are 29–36; the notes omit them. Parikh's system uses ternary relations for + and ·. |
| Kreisel's conjecture | Reported open for standard PA (Cavagnetto); proved for some formulations (Baaz–Pudlák 1993, "for L∃1"; Hrubeš for PAM); false for some theories close to PA (Hrubeš, JSL 2007). The notes' "open for standard formalisations, special cases settled" is consistent. Adding Hrubeš 2007 would help. |
| Hoeffding 1963, Tarski–Vaught 1957, Tenenbaum–Griffiths 2001 | Standard; not re-checked. |
| axiom-schemas labels | **All exist and say what is claimed:** Ex univ:q (model with Sa = a, 0+a = b), Prop univ:open, Prop univ:tv, Ex univ:fail, Thm univ:rates(a) (P_N = Σ_f p_f^N), sec:many:mdl, Prop many:mdlnaive, mdlwell, many:forall. |
| inferential-learning thm:caution:ville, lem:app:caution:ville | **Exist and match.** The track's use of the prior–posterior ratio supermartingale is correct. |

---

## Important questions the track missed or left thin

1. **Unknown selection.** The recommended "good version" (§10) needs the filter S to be known. With S unknown, M1
   and M2 suggest that L1-norm without S drifts to very specific generators. The question decides whether the
   recommendation is usable. It is listed only as open problem 4.
2. **KL-minimisers in rich classes.** Brief H2 asks what can be promised under misspecification. The track computes
   misspecified limits only in classes of two to four hypotheses. M1 to M3 show that a larger class changes the answer.
3. **The MDL splitting result** (brief, `sec:many:mdl`). The track engages it only through lemma usage (U12(c),
   proof sketch). The direct analogue is visible in its own data:
   * c2's well-specified class: the Laplace root split decays, which matches Prop many:mdlwell;
   * r3 and r4, where the selection is not modelled: splitting σ_φ by the root of z wins by a margin linear in n,
     which matches Prop many:mdlnaive.

   This answers the brief's question "does a derivation likelihood change it?" for the ∀ case, and it is not stated.
4. **Prior sensitivity.** In regime (b) the answer *is* the prior share. The shares 1/3, 2/3 and 0.75 come from
   counting ∀ as one symbol, with no charge for declaring the range of z. There is no sensitivity analysis, and no
   prefix-free code (see m1).
5. **Noise and near misses.** These are Hänni's "other ideas", and the brief points to them. Every likelihood here is
   supported on theorems, so one false datum refutes the true theory. Robustness is not studied.
6. **The time penalty (H6) for this case** gets only a remark (U14). Hänni's collapse construction is not discussed for
   the ∀ case.
7. **Learned c.** Not raised. I checked it, and it confirms the track. Under L1-norm with quantifier-free φ the
   per-datum factor is c/(1+c) < 1/2 for every c ∈ (0, 1) (**proved**: c/(1+c) increases in c). So letting H_∀ choose
   its own elimination rate cannot rescue it.

---

## Claims I checked and confirm

| claim | how checked | result |
|---|---|---|
| U1 (factorisation, Z formulas) | proof read; `r1_cmin.out` exact enumeration, 3 formulas incl. quantified | max deviation 1.6·10⁻¹⁵; MC max \|z\| 2.74 (a 10⁶ re-run gives z = 0.68) |
| U2, all rows | proof read; `r1_cmin.out` (d) on 20 streams | L1 c^n, L1-norm (c/(1+c))^n, L1-sel and L0-closure constant, to 10⁻¹² |
| U3 within its hypotheses | proof read | correct; injectivity holds because cited axioms are labelled |
| Thm B, all bullets incl. Z_{B⊕σ} ≤ Z_{B⊕∀} | proof read | correct (Z_∀ − Z_σ = (1−c)(1−Z_σ) ≥ 0) |
| Total prover mass bounds 1/(n+1) ≤ I_n ≤ 1/(n(1−c)) | proof read | correct |
| U4(1)–(4) | proof read; `r7_misc.out` (1): 130 random strict generalisations × 3 laws, own matcher | max standardised excess 1.3, attained at equality cases (e.g. ?u+z=z, q = 1/2) |
| U4 table values (1/2, 1/3, 1/6; KL 0.693, 1.386, 2.079) | by hand | correct |
| U5 | proof read | correct; P_N = Σ_f p_f^n matches Thm univ:rates(a) |
| U6(i), (ii), (ii′) proofs | proof read; `r7_misc.out` (2) | correct given Σ r_s < ∞ (see m1) |
| U7 (Doob, countable class) | proof read | correct, including measurability of E_g and the Scheffé step |
| U8(1)–(4) | proof read; summed misses 4.2199 (`r7_misc.out` (4)) | correct; the bound ln 100 = 4.605 holds |
| U10(a), (b) (fixed weights), (d) (quantifier-free φ) | proof read | correct |
| Hä1 / Hä2 analysis | proof read | correct; Hä1 has no size principle |
| U11(a)–(d) | proof read; own derivation; `r7_misc.out` (3) against own sampler | max \|z\| 2.15; normalised ratios 0.2077, 0.8824, 0.2354 exact |
| U12(a) incl. Q + ∀y(0+Sy=Sy) ⊢ ∀x(0+x=x) | proof read | correct |
| U12(b) closed forms | proof read | correct (but see m5) |
| U13 | `r5_models.out` (1): all pairs on {0..80} ∪ {a, b}, no window edge skipped | 0 violations of Q1–Q3, Q5–Q7; Q4 fails only at a |
| U14(a) | proof read; `r5_models.out` (3): 339 250 random one-step rewrites, terms with variables and · | Δw = ∓1 in every case |
| U14(b) Hoeffding bound | proof read | correct as a bound (but see m6) |
| U15 | proof read | correct; matches Prop univ:tv |
| U16(b) per-datum ratios 3.77, 1.13 | `r4_sentences.out` | reproduced (0.725 nats); the class issue is M2 |
| §10 Ville argument | proof read against thm:caution:ville | correct under well-specification; useful only when π(T*) > δ |
| Track numbers | re-ran c3, c4, c5, c6, c7 into a scratch directory | `.out` files byte-identical |

## Referee code (`referee_code/`, seeded; each writes `<name>.out`)

| script | checks | runtime |
|---|---|---|
| `r1_cmin.py` | U1 and U2 with own formulas, exact chain enumeration and sampler | 2 s |
| `r2_detour.py` | m8: spine formulas, MC, 9139-point grid, 2·10⁶ MC test | 75 s |
| `r3_noguard.py` | M1: R_k laws and MC; rates; posteriors under L1-norm and L1-sel | 2 s |
| `r4_sentences.py` | M2: Split_k laws and MC; rates; posteriors with deeper splits and memorisers | 3 s |
| `r5_models.py` | U13 model, Q ⊬ 0<S0, U14(a) invariant | 15 s |
| `r6_prior_mass.py` | m1: term growth and divergence of the λ = 1 prior | <1 s |
| `r7_misc.py` | U4(4), U6(i) bracket, U11(c) closed forms, U8 summed misses | 35 s |
