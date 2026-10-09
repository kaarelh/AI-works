# Mathematical review B: Section 3 (the case ∀xφ), Section 6 (time penalties and Hänni's collapse), and their appendices

**Files reviewed:**
* `paper/sections/universal.tex`
* `app-universal.tex`
* `time.tex`
* `app-time.tex`

The PDF was built from these sources: `main.log` has no undefined references.

**Sources checked against:**
* `research/tracks/universal/notes-final.md` and its `referee.md`;
* `research/tracks/model/notes-final.md` §6 and its `referee.md`;
* the check outputs of both tracks (`checks/*.out`, `referee_code/*.out`);
* `research/prior/hanni-*.md`, for the quotations;
* the axiom-schemas definitions of DT° (`../axiom-schemas/paper/sections/setting.tex`).

**Independent code** is in `research/paper-review/scratch/mathB_*.py`, and each script's output sits next to it as `mathB_*.out`. None of these scripts imports track code. Line numbers below refer to the `.tex` files. The issue list is also in `issues-math-B.json`.

## 1. Verdict

The theorems in both sections are correct as proved. I re-derived every formula listed under §2 and recomputed every number I could. Most of them reproduce exactly. The only discrepancies are a stated inequality that is false for k ≥ 6 (MB-09) and two off-by-one sizes that come from a counting convention. The fixed-point detour value and the exact chain laws also agree with my own samplers and DP code.

The problems sit at the edges of the statements and in the summaries.

**Fatal.** Two claims are stronger than what is proved, or than the sources:
* **MB-01: "never favour".** The section says, without qualification, that instance data "never favour ∀xφ over its schema". It also says that "the axioms prove ∀xφ" does not gain from closed instances. Both statements omit a case that the universal notes list explicitly: a background with a fixed common weight under L_sel.
  * L_sel is the likelihood the paper recommends.
  * In this case the selected laws of the two versions differ. The ∀-version wins at a linear rate on data that it generated.
  * I computed a drift of +0.153 nats per datum.
* **MB-02: (B3) under Hänni's scores.** Thm B (B3) claims the odds bound under the scores for all data. That is false. For example, the datum ¬∃x¬φ, or a background {∀xφ → S0=0} together with the datum S0=0, gives the ∀-version a strictly better score. The claim holds for single axioms and quantifier-free data, by Herbrand's theorem.

**Major.** Seven issues:
* the limits under S_nc and S_g in Prop univ:hanni;
* three over-strong clauses in "The precise statement" of §6 (MB-04, MB-05, MB-06);
* an upper bound for ρ_{f,n} that the appendix itself says is not established (MB-07);
* the scope of Prop univ:open(d) (MB-08);
* a wrong numerical bound (MB-09).

**Minor.** Seventeen issues: missing hypotheses that are easy to restore, wording, notation and formatting.

None of the issues requires changing a proof. Each is fixed by stating the correct hypothesis or scope, or by adding a sentence.

## 2. What was checked, and how

### 2.1 Section 3 and Appendix B (universal)

#### Prop univ:factor and Thm univ:odds

* I re-derived the bijection between chains.
* I checked the normalisers Z_Hsch = (1−c)Σ_{k≤m}c^k and Z_Hall = (1−c)+cZ_Hsch.
* I re-derived every row of Table univ:odds, including c/(1+c) for quantifier-free φ.
* The "m leading quantifiers" must be universal quantifiers (MB-13).

#### Thm univ:B

* **(B2)** Verified. This covers the pointwise inequality under μ_T, the ordering of the normalisers Z_{B⊕∀} − Z_{B⊕σ} = w(1−c)(1−Z_sch) ≥ 0, and the integration over a common weight prior.
* **(B3), simulation inequality.** Verified: each pattern "∀E(cite ∀xφ, t)" has weight c·Q(t)·p_cite·w, against p_cite·w·Q(t) for its replacement, and the map is injective.
* **(B3), scores.** False as stated (MB-02).
* **Equality conditions in (B1).** Incomplete (MB-14).
* **The "never favour" framing.** See MB-01. My own script `mathB_lsel_fixed.py` shows that the fixed-weight L_sel case runs in either direction, depending on the mixture proportion.

#### Prop univ:B2

* I re-derived w_e = wc/(1−w+wc), its inverse, and dw/dv = h(v) = c/(c+v(1−c))².
* I checked the Beta representation, the range [c, 1/c] and the threshold √c/(1+√c) = 0.3539.
* I computed the Bayes factor by direct quadrature of the two likelihood integrals, without the change of variables. It gives 2.1912, 1.1534, 0.7101 and 0.4057 at n = 2·10⁴, against h = 2.1914, 1.1534, 0.7101 and 0.4056.

#### Rem univ:B2cit

The L_selc tie holds by the per-citation argument.

#### Prop univ:both

* I checked the ratio (1−w(1−c))/(1+wc) and both bounds.
* By quadrature, nI_n = 0.958, 0.996 and 0.9996 at n = 10, 10² and 10³, matching the paper.

#### Rem univ:detour

* I solved the fixed point of Z = D(eaZ)(p_c + cP_U + aZ²) myself. It gives D_∀ = 1.03160, D_σ = 1.02636 and R = 0.15553, all exact.
* My own Monte Carlo sampler of C_∧, with explicit formula objects, gives R = 0.1548 ± 0.0012 from 3·10⁵ derivations per theory. This agrees with 0.15553 and lies above c = 0.15.

#### Thm univ:size and Props univ:overspec, univ:memo

* I checked these proofs line by line: the log-sum inequality, the strong law of large numbers with E Y⁺ ≤ 1, Tonelli, and the case analysis on ρ.
* For univ:memo I also checked:
  * the identity for DirMult₁;
  * the bound multinomial ≤ 1/ML;
  * the tail n·q^{3 log_{1/q} n} = n^{−2} with Borel–Cantelli;
  * the O(ln² n) bookkeeping.
* The likelihood behind (4) is not named (MB-15).

#### Thm univ:confirm

* (1) to (4) verified. The data-generating assumption is missing from the statement (MB-10).
* I recomputed Σ_n(1 − M(I|D_n)) = 4.2199 ≤ ln 100.
* I recomputed 1 − π_n(G) = 0.3716 at n = 10⁵⁰. This value needs the prior 1/(j(j+1)), which the paper does not state (MB-16).

#### Thm univ:omega

* (a), (c1)–(c3), (d1), (d2) for the pair, and (e): verified.
* For (e) I checked the limit 1/4 for the filter family of c10(e), and the KL comparison in (d2) (cZ_sch < Z_all).

#### Prop univ:hanni

* The S_prove part is correct.
* The sentence on S_nc and S_g is wrong as read (MB-03).

#### Prop univ:q4

I checked the model on ℕ∪{a,b} case by case and by script on {0..60}∪{a,b}. It satisfies Q1–Q3 and Q5–Q7 with zero violations, and a+0 = 0 ≠ a.

#### Prop univ:gaifman (Tarski–Vaught)

* Correct.
* The Gaifman condition for all one-variable φ, closed-term parameters included, is the Tarski–Vaught criterion for M₀ ≼ M. This uses the fact that there are countably many φ.

#### Prop univ:open (a)–(c)

* I computed the exact C_open laws by an independent DP over chain states.
* Z_all = 0.6539235412, Z_open = 0.5130784708 and Z_sch = 0.5 equal the closed forms.
* The normalised ratios 0.882353, 0.207692 and 0.235385 are exact.
* μ_all/μ_open = 50 = 1/(gρ) at ∀xφ.
* (d) is proved only for the class of Table c5 (MB-08).

#### Lemma univ:waste, Props univ:rk, univ:rkrate and univ:noguard

* **Waste lemma.** I checked the convexity argument and the optimum. A grid check over 2000 random (τ, r_w) gives an error of at most 4·10⁻⁷.
* **R_k.** I recomputed the exact law of R_k by DP. Numerical minimisation of KL over all weights gives q^kW_o to 6 digits for k = 1..4, in three parameter settings. For example, at the defaults: 0.062582, 0.031291, 0.015645, 0.007823.
* **Countermodel.** I checked the countermodel ℕ∪{e,e′} by script.
* **Proofs.** I checked the KL rates and the sup/convexity argument in (b).
* **Laplace versus Dirichlet(½).** (b) is proved for Laplace-weighted memorisers, while the computations use Dirichlet(½) (MB-11).

#### Prop univ:quant

* **(a) and (c).** Verified.
* **(b): rates.** I recomputed the per-instance log ratios 0.021, 0.094, 0.307 and 1.323, and ln(1+c+c²+c³) = 0.3485.
* **(b): a shorter proof.** There is an exact identity r_B(w) = r_both(Kw), with K = 1+c+…+c^L; numerically the difference is 3·10⁻¹⁶. It gives BF_both/BF_B = K·∫₀¹r^n / ∫₀^K r^n → K at an exponential rate. This explains why c10(c) shows 0.349 "at every n", and it gives (b) for f_q = 0 without Watson's lemma. This is an optional improvement, not an error.

#### Prop univ:eqfrag

* (a): I verified the invariant w on 34 256 random Q4/Q5 rewrites, with zero violations.
* (b): I checked the Hoeffding constant.
* (c): I checked the threshold e^{−1/2} = 0.6065 and the two-part comparison.

#### Prop univ:sentences and Lemma univ:survivors (Lemma S1)

* **KL values.** I recomputed the KL for H_all, Split_k and Both0 by DP plus minimisation: 1.466337, 0.733169, 0.366584, 0.183292, 0.091646 and 1.018441, all equal to the closed forms.
* **Lemma S1, brute force.** I searched by brute force over atomic sentences ∀ȳ(l = r), with l rooted at + and r free of +, over {0, S, y1, y2, y3} at depth ≤ 2: 6912 sentences in all.
  * 90 of them yield at least 8 distinct numeral instances of 0+x=x.
  * Every one of the 90 either has a false closed instance, so Q ∪ T is inconsistent, or proves ∀yφ(S^a y).
  * This confirms the case analysis, including the case τ₀ = variable that the paper adds.

#### Cor univ:sound and Rem univ:mdl

* The corollary's Ville argument is correct. Acceptance on Bel_c implies π_n(C*_∀) ≤ δ, because Bel_c ≤ Bel.
* Rem univ:mdl: consistent with the cited results.

#### Tables

I compared Tables c2, inc, share, c5, noguard and sentences entry by entry with `c2_odds.out`, `c5_open_quant.out`, `c8_noguard.out`, `c9_sentences.out` and `c10_misc.out`. All entries match.

### 2.2 Section 6 and Appendix F (time)

#### Quotations

Each quotation from Hänni matches `hanni-solomonoff-axiom-induction.md` verbatim.

#### Prop time:fiall

I checked the a + a′ ≤ 1 argument and the convexity step.

#### Thm time:equiv (Craig's trick)

* **AI to FI.** The map is injective, and f_p is compatible because Γ_{f_p} ⊆ Th(B ∪ A_p).
* **FI to AI.** The Craig decider halts on every input. There are at most |χ| decompositions, since a right-nested power determines ψ, and each decomposition needs a bounded run of f. Cn(B ∪ A^C_f) = Cn(B ∪ Γ_f).
* **The 2c-bit equivalence.** Each of the terms −log W(D_n) and log W(∅) moves by at most c. Correct.
* **Per-step renormalisation.** It gives 2c bits per step. Correct.

#### Props time:twosorted and time:single

* **twosorted.** I checked consistency (the standard ℕ ⊕ M), the inclusion ⊇ (Σ₁-completeness of Q) and the inclusion ⊆ (truth depends only on M).
* **single, inconsistency.** I checked both derivations:
  * PA ⊢ Acc_f(⌜¬Con⌝) for the true Σ₁ sentence;
  * PA ⊢ ¬Con → Acc_f(⌜Con⌝), via the least proof of ⊥.
* **Wording.** The remark that his route "works only with two sorts" disagrees with l.74, where a sound f also suffices (MB-12).

#### Prop time:notemplate

Checked against the DT° definition: occurrences form an antichain, and arguments contain no metavariables. That makes the step "the path to q is the same" valid. The mixed Acc/Rej case of A_f is not treated (MB-18).

#### Props time:collapse and time:cheap

* **collapse.** I checked (a) and (b) as stated. The summary overstates them (MB-05).
* **cheap.** (a) is correct: membership in A_f does not depend on f's behaviour at all, so the brief's H6 sentence is rightly refuted. (b) is correct.

#### Thm time:ntime and Cor time:hard

* I checked both. The soundness step uses the consistency of T ∪ Γ_{f_X}.
* The hierarchy-theorem gap conditions hold for polynomials and 2^m (`mathB_time.out`).

#### Rem time:lonesize (the refuted Prop 6.9)

* I rebuilt the counterexample family in de Bruijn form. Sizes are 2^{k+3} − 1 and ν = 7 + 8k.
* The costs are 12.7657 + 12.2061k. This violates the stated "≤ 12.8 + 12.2k" for k ≥ 6 (MB-09).
* The A4 example's sizes come out one less than the referee's (144 against 145, and so on), which is a counting convention for ∀. Not an issue.

#### Lemma time:symexp

* I checked every case of the induction: DT° citation, A4, ∀E, Gen, MP.
* I checked the AM–GM bound sup_y(ν/y)^y = e^{ν/e}.
* The bound holds on the family up to k < 60.

#### Prop time:codelength, Thm time:log and Cor time:log

* **codelength.** Checked, including the Markov step.
* **log.** I checked the arithmetic e^{1/e} = 1.4447 < 2 and the bound ℓ·S^d ≤ 2^{(d+1)ℓ} for large ℓ.
* **Cor log.** Checked. Its condition s(m)² − (d+1)s(m+1) → ∞ holds for s(m) = m, m³ and 2^m.

#### Prop time:sigma

I checked the 4ℓ translation (each node is a premise at most once) and the inequalities in (a) and (c). The summary drops the constants (MB-06).

#### Rem time:summary and Rem time:upper

These contain the main problems of §6: MB-04, MB-05, MB-06 and MB-07.

#### Rem time:links and Rem time:e7

The numbers match the experiments notes: log₂(78/2) = 5.3 bits, 7 → 9 seeds, and 22 of 25 seeds.

## 3. Numbered issue list

Severity follows the brief:
* **fatal:** a false or unsupported mathematical claim, or a claim stronger than the sources;
* **major:** a missing hypothesis, a wrong number, an inconsistency, misleading framing, or a passage a reader cannot follow;
* **minor:** local wording or formatting.

### MB-01 (fatal): "never favour" omits the fixed-weight L_sel background case

**Where.** `universal.tex`: l.8, l.39 (the subsection title), l.68 (the title of Thm B), l.72 (the "Not covered" list), l.86, l.222.

**Problem.** Several statements are unqualified:
* l.8: instance data "never favour ∀xφ over its instance schema σ_φ";
* l.86: the effect of Prop B2 "is bounded";
* l.222: "'The axioms prove ∀xφ' does not gain from closed instances".

Thm B covers only:
* (B1) single axioms;
* (B2) a background under μ_T, L_one and L_cl;
* (B3) the CUiii calculi.

The universal notes list a further case explicitly (§4, "Not covered, or false"): "With fixed weights and a background under L1-sel, the two laws have different effective weights, and whichever matches the data wins." The paper drops this case from its "Not covered" list. In it:
* B⊕_w∀xφ has φ-instance share w_e = wc/(1−w+wc), while B⊕_wσ_φ has share w. This follows from the proof of Prop B2 (app l.32), which holds at fixed w.
* On closed-instance data from B⊕_w∀xφ, the log odds for the ∀-version therefore grow linearly.
* In the class {B⊕_w∀xφ, B⊕_wσ_φ}, P(T⊢∀xφ | D_n) → 1.

This holds under L_sel, the likelihood recommended at l.224.

**Evidence.** `scratch/mathB_lsel_fixed.out`, at c = 0.3, w = 0.5:

| data source | drift for the ∀-version | log odds at n = 2000 |
|---|---|---|
| B⊕_w∀xφ | +0.153 nats/datum | +324.6 |
| B⊕_wσ_φ | −0.171 nats/datum | not reported |

**Fix.**
* At l.8, l.39 and l.68, add "in the comparisons of Thm B".
* At l.72, add to "Not covered": "L_sel with a background and a fixed common weight: the selected laws differ, with effective weight wc/(1−w+wc) against w, and whichever matches the mixture proportion wins linearly; the signal is not logical".
* At l.86, write "With learned weights the effect is bounded".
* Qualify l.222 and l.224 accordingly, or recommend L_selc instead. Under L_selc, Rem B2cit gives an exact tie at every w.

### MB-02 (fatal): Thm B (B3) is false under the scores

**Where.** `universal.tex` l.69, Thm B (B3); `app-universal.tex` l.20.

**Problem.** (B3) claims the odds bound "under the scores" in CUiii calculi, on all data other than ∀xφ. The "score argument above" in the proof covers only single axioms on closed-instance data. Provability here is first-order (def:model:scores, def:sound:tri), and two counterexamples follow.
* **Single axioms.** The datum ¬∃x¬φ is proved by H_all and not by I_c(φ). So S_prove(H_sch) = 0 < 1 = S_prove(H_all), and the odds are infinite in favour of the ∀-version.
* **With a background**, which Prop univ:sim allows. Take B = {∀xφ → S0=0} and the quantifier-free datum S0=0.
  * B with ∀xφ proves the datum.
  * B with I_c(φ) does not: in the model ℕ∪{e} with 0+e = S0, S0=0 is false.
  * So S_prove and S_g favour the ∀-version.

**Fix.** Restrict the score part of (B3) to single axioms and quantifier-free data. There Herbrand's theorem gives {∀xφ} ⊢ s ⇔ I_c(φ) ⊢ s. Alternatively, use ⊢_C. Keep μ_T and L_max as they are. Say in (B1) that it is the restriction to closed instances that makes the score part true.

### MB-03 (major): the limits under S_nc and S_g are not the limit under S_prove

**Where.** `universal.tex` l.147, Prop univ:hanni; `app-universal.tex` l.123.

**Problem.** "The same holds for S_nc and S_g", read as a statement about the limit, is false.
* S_nc(T;D) = 1[T∪D consistent]. Its limit is therefore the prior restricted to {T : T ∪ I_c(φ) consistent}.
* That set contains non-provers of the instances: the empty theory, and {φ(Sz)} from the c2 class.
* Under S_g with g_∞ > 0, theories that fail finitely many instances keep positive mass.
* The proof only shows that provers share one factor.

**Fix.** State the S_nc and S_g limits separately. Then note that, among provers of all the instances, the prior odds are kept, so the trichotomy conclusion and the absence of a size principle carry over.

### MB-04 (major): "additive constant" for time penalties is not proved

**Where.** `time.tex` l.191, Rem time:summary (1); l.20.

**Problem.** The remark says that Kt and speed-prior penalties change Hänni's equivalence "by an additive constant at most", with status *proved*.
* No time-penalised prior is defined anywhere in §6.
* Prop time:cheap shows only that membership takes polynomial time for each fixed f.
* A Kt-style penalty takes the logarithm of the running time. The Craig decider's time includes an overhead, from simulating f, that depends on f.
* Rem model:priors(iii) itself says a Levin factor changes ln π by O(ln ℓ(T)).
* So "an additive constant" holds only for a penalty that depends on the polynomial degree alone.

**Fix.** Define the penalty (for example, a factor h(deg) for deciders with membership time O(n^deg)) and prove the constant for it. Otherwise say "do not block the collapse; for Kt-style penalties the change is at most logarithmic in |f| and |χ|", and mark that part as a proof sketch.

### MB-05 (major): "templates block his schema but not the collapse" overstates Prop time:collapse

**Where.** `time.tex` l.20; l.191, Rem time:summary (2).

**Problem.** Prop time:collapse proves much less than "the collapse":
* the background must be PA;
* it covers only Σ_n-sound assigners, and only on Σ_n sentences;
* the overhead is a|f|+b_n, linear in |f|, not a constant;
* for merely consistent assigners, PA+ρ can be inconsistent;
* whether Craig's set is a finite union of DT° templates is open (problem 15).

l.99 states these limits. The introduction and "The precise statement" drop them.

**Fix.** "Templates block his schema. In arithmetic over PA, one ground sentence reproduces every Σ_n-sound assigner on Σ_n sentences, at a cost linear in |f|. Whether templates block the constant-overhead equivalence for consistent assigners is open."

### MB-06 (major): Rem time:summary (3) misstates the bounds

**Where.** `time.tex` l.191, Rem time:summary (3).

**Problem.** The summary says derivation size is "between its nondeterministic time (a lower bound for every theory) and its deterministic time". This is inexact in four ways.
* **The lower bound.** It is t^{1/c_e}, a polynomial root of the nondeterministic time, not that time (Thm ntime gives X ∈ NTIME(ℓ^{c_e})).
* **Its scope.** It holds only infinitely often, only for hard languages, and only for theories with polynomial-time membership.
* **The upper bound.** It does not cover ρ_{f,n} (app-time l.92), and for two-sorted A_f it is only recalled.
* **The constants.** The charges drop the constants −ln(Z_T/Z^σ_T) and log₂ Z_T.

l.173 says "a polynomial root" correctly, so the summary contradicts the body.

**Fix.** Rewrite the remark with these qualifications. Suggested wording is in the JSON.

### MB-07 (major): the upper bound for ρ_{f,n} is not established

**Where.** `time.tex` l.130, Rem time:upper; `app-time.tex` l.92.

**Problem.** The remark lists ρ_{f,n}, via "the Tarski biconditional", among the constructions that pay at most a polynomial of the deterministic running time. The appendix says the size of that biconditional's proof "is not bounded in the notes", and the model notes do not bound it either.

**Fix.** Say that it is unbounded here, or cite a polynomial bound.

### MB-08 (major): Prop univ:open (d) is stated more widely than it is proved

**Where.** `universal.tex` l.168, Prop univ:open (d); `app-universal.tex` l.155.

**Problem.**
* (d) is stated for any class that contains the guarded H_sch. It is proved only for the four-member class of Table c5. The notes say "for the finitely many hypotheses compared".
* The proof cites Prop univ:both, which is proved in C_min. In C_open, H_both's ratio is [(1−w)+(1−ρ)cw/(1−gcρ)] / [(1−w)+w(1+c)/(1−gcρ)].
* For countable classes with learned-weight provers, the limit 0 is unproved.

**Fix.** Restrict (d) to finite classes or to fixed-weight classes. Give the C_open ratio and its Θ(1/n) decay.

### MB-09 (major, a wrong number): the cost bound fails for k ≥ 6

**Where.** `time.tex` l.140.

**Problem.** "−ln Pr(tree) ≤ 12.8 + 12.2k" is false for k ≥ 6.
* The exact cost is 12.7657 + 12.2061k.
* The paper's own table gives 378.95 at k = 30, against 378.8 from the bound.
* This is harmless for the argument, which needs only linear growth.

**Fix.** Write "= 12.77 + 12.21k".

### MB-10 to MB-26 (minor)

| id | where | problem | fix |
|---|---|---|---|
| MB-10 | `universal.tex` l.119, Thm univ:confirm | The data-generating assumption is missing: i.i.d. from P_{T*}, countable class, proper prior. | Add "Assume setting W, with T* ∈ G the generator". |
| MB-11 | `universal.tex` l.184, Prop univ:noguard(b) | Proved for Laplace-weighted memorisers, while the table uses Dirichlet(½). | Note the Krichevsky–Trofimov version of the bound, or state both α. |
| MB-12 | `time.tex` l.53 against l.74 | "Works only with two sorts" contradicts "two sorts or a sound f". In one sort, a sound f gives a true PA ∪ A_f that proves the labels. | Make the two lines agree. |
| MB-13 | `universal.tex` l.42, Prop univ:factor; `app-universal.tex` l.14 | "m leading quantifiers". | Write "leading universal quantifiers". |
| MB-14 | `universal.tex` l.69, Thm B (B1) | The equality conditions are omitted: ∀xφ ∉ S for L_sel, and ∀xφ consistent for the scores. | State them. |
| MB-15 | `universal.tex` l.102, Thm univ:size(4) | The likelihood is not stated. The proof is for the citation law; under L_one, ∀E opens extra routes to instances. | Name the likelihood. |
| MB-16 | `universal.tex` l.122 | The prior of the dyadic family is unstated. The value 0.37 depends on 1/(j(j+1)); I verified 0.3716 with it. | State the prior. |
| MB-17 | `universal.tex` l.181 | "A fixed fraction r_w": r_w is a ratio, and equals 1/c = 3.33 for Split_k. | Write "r_w times the tail mass". |
| MB-18 | `time.tex` l.80; `app-time.tex` l.62, Prop time:notemplate | Proved for C_f only. The conclusion is about A_f, and templates that mix the Acc and Rej parts need a constant body whose root differs from two symbols. | State the result for A_f and add that sentence. |
| MB-19 | `time.tex` l.111 | "No theory escapes this". | Write "no theory with polynomial-time membership". |
| MB-20 | `time.tex` l.53 | "The constant equivalence needs the semimeasure convention": only this argument needs it. | Write "This argument needs". |
| MB-21 | `app-time.tex` l.131 | The symbols g and ρ clash with C_open's g and ρ. | Rename them. |
| MB-22 | `universal.tex` l.224 | "Accepts only if the prior share ≥ 1−δ" is a statement about the limit. | Write "eventually", and cite Cor univ:sound for finite n. |
| MB-23 | `universal.tex` l.17 | g_∞ = 1/β lies outside [0,1) when β = 1. | Write "β > 1". |
| MB-24 | `universal.tex` l.72 | "The mechanism is the size principle" does not explain the factor c under unnormalised μ_T. | Add "the extra ∀E step". |
| MB-25 | `universal.tex` l.138, Thm univ:omega(e) | The pair law is undefined when P_T(S) = 0. | Restrict F, or set the likelihood to 0. |
| MB-26 | `universal.tex` l.234–235; `app-time.tex` l.154–155 | Overfull hboxes of 4.4pt and 0.7pt. | Rephrase. |

## 4. Scripts (seeded or deterministic; outputs saved next to them)

| script | checks | result |
|---|---|---|
| `mathB_chains.py` | exact C_open laws (DP over chain states); U11(c) ratios; KL of H_all and H_open; inf_w KL(R_k) = q^kW_o by numerical minimisation (k ≤ 4, three settings); waste lemma on a grid | all agree to at least 6 digits |
| `mathB_cmin.py` | Split_k, Both0, H_all KL; nI_n; Prop B2 Bayes factor by direct quadrature; U12(b) numbers and the identity r_B(w) = r_both(Kw); detour fixed point and an independent MC; U8 sums | all agree. MC R = 0.1548 ± 0.0012. Dyadic value 0.3716 once the j-tail is included |
| `mathB_models.py` | Q−Q4 model; R_k countermodel; B3 score counterexample; Lemma S1 brute force (6912 sentences); eqfrag invariant (34 256 rewrites) | no violations; counterexample confirmed |
| `mathB_time.py` | φ_k sizes, ν and costs; the 12.8 + 12.2k bound; Lemma symexp on the family; A4 sizes; hierarchy growth conditions | the bound fails for k ≥ 6. Everything else agrees, apart from an off-by-one in the A4 sizes from a counting convention |
| `mathB_lsel_fixed.py` | the fixed-weight L_sel background case (MB-01) | drift ±0.15 nats per datum, sign set by the data's mixture proportion |
| `mathB_make_json.py` | writes `issues-math-B.json` | 26 issues: 2 fatal, 7 major, 17 minor |
