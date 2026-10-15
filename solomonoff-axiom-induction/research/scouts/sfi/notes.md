# Scout S: the relation of axiom induction to SFI, and time bounds

*Scout record for the paper on Solomonoff axiom induction (working name). Brief: `../../00-brief.md`. Sources: the earlier report `../../../../axiom-induction/` (paper Section 6 and Appendix E, `paper/sections/time.tex`, `app-time.tex`; refereed records `research/tracks/{model,universal,time-followup,short-derivations}/notes-final.md`), the two SFI papers `../../../../solomonoff-function-induction/paper/` ("Paper 1") and `.../paper-steeper/` ("Paper 2"), with `paper/NOTATION.md`. Scripts are in `checks/`; each is seeded or deterministic and writes `<name>.out` next to itself. No git command that changes repository state was run.*

**Abbreviations for sources.** "AI-paper" is the earlier report's PDF (`axiom-induction/paper/main.pdf`), cited by its labels and numbers (e.g. `thm:time:equiv` = Thm 6.3). "Model §6" is `tracks/model/notes-final.md` §6. "TF" is `tracks/time-followup/notes-final.md`, "SD" is `tracks/short-derivations/notes-final.md`, each in its final numbering. "P1" is Paper 1, cited by its labels (`thm:setting:universal` etc.).

**Status tags.** **[proved]**: full proof here, or a full proof in the cited refereed record (then the record is named and the statement is transcribed). **[proved, given X]**: the proof uses the cited result X. **[proof sketch]**: the argument is given and the missing steps are named. **[known]**: published; the reference was checked by a web search of its bibliographic data; "(content from abstract/secondary source)" says how much of the content was checked. **[computed]**: script and saved output named. **[conjecture]**, **[open]**, **[refuted]** (kept with its counterexample).

---

## 0. Summary

**What the relation is, version by version.** Axiom induction (AI) with free deduction is SFI on sentences restricted to logically consistent labellers, and the correspondence holds separately for each of P1's versions:

| AI version | SFI version (P1) | relation | where |
|---|---|---|---|
| deciders of axiom sets, prior 2^(−\|p\|) (the earlier report's AI) | coin-free W restricted to consistent labellers, W_cons | within a factor 2^(±c) on every data set | Thm 2.4 (the report's Thm 6.3, restated) |
| shortest compatible decider, K_AI | shortest consistent program, K_F^cons | equal up to ±c | Thm 2.4 |
| one-tape random axiom machines, M_AI (new) | one-tape M_F, restricted pathwise to consistent sampled labellers, M_F^cons | within 2^(±c) on every nonempty data set | Thm 2.5 |
| W_AI against M_AI | W against M_F | 2^(−c) W_AI ≤ M_AI; the gap is unbounded but at most min{K^pad(L_1/2), K(dom D)} + O(1) | Prop 2.6, Cor 2.8 |
| any of the above on positive literals R(t_w) | the same P1 version on strings w | equal up to constants: AI *is* SFI on such data | Thm 2.7 |

So the earlier report's slogan "axiom induction ≡ consistent function induction" must be restated as "≡ *coin-free* consistent SFI"; one-tape SFI corresponds to *random* axiom systems.

**What breaks.** (i) Logical closure: AI gives every consequence of the data probability 1, consistent SFI gives it probability 0 of "false" but positive probability of "undefined"; the three-way predictions (true, false, undefined/independent) agree only after SFI is restricted to deductively closed labellers, which costs O(1) bits (Prop 2.11). (ii) If "independent" is an *observed* label, the equivalence fails in one direction: a theory certifies independence for free, a labeller must commit in finite time; a single datum (σ, independent) separates them by an unbounded amount (Prop 2.12). (iii) Private randomness per sentence is incompatible with consistency on logically related sentences; random theories need the shared tape (Rem 2.13). (iv) None of the consistency-restricted mixtures is lower semicomputable.

**Time bounds.** Every penalty on checking or generating axioms leaves the coin-free equivalence intact (TF Thm 2.2); every time bound on the labellers makes it one-sided, and the transfers hold for one-tape clocked SFI and for P1's time-bounded mixtures (Thm 2.9). A natural, non-diagonal instance: on Presburger arithmetic AI has bounded loss and doubly-exponential-time consistent SFI unbounded loss, by the Fischer–Rabin lower bound (Prop 2.10).

**The theoretician's dilemma (Section 3).** The clean statement (§3.6):
1. *Hempel's horn.* With deduction free, restricting axioms to the observational vocabulary changes axiom induction by O(1) bits, also under time penalties on checking or generating axioms and for the predictive (inductive) probabilities (Thm 3.1).
2. *The practical horn, made precise.* Craig's construction writes a number (a run time or a Gödel number) in unary: from a theory whose observational consequences have derivations of size d, it produces axioms of size at least 2^d (Lemma 3.2). More generally, any observational axiomatisation by padded literals ("Craig type") fits, at polynomial derivation budgets, exactly the polynomial-time decidable regularities, whatever reading of "short derivation" is used (Thm 3.3). Axiom sets with theoretical predicates fit EXPTIME (every instance short) or every decidable regularity (only the theory's own axioms short), so unconditionally Craigian axiomatisations are useless in practice in this exact sense (Cor 3.4).
3. *But elimination itself is cheap when total derivation size is charged.* Padding with proofs instead of run times gives observational axiomatisations of description length +O(1) and derivation size polynomial in the original (Prop 3.5). What the classical reply gets right is that Craig's construction discards the derivations; what survives elimination at polynomial cost is not the theoretical vocabulary but the proofs.

**Top candidates, ranked** (§4): (1) the transfer principle on positive literals [proved]; (2) the one-tape equivalence [proved]; (3) the dilemma theorem [proved; conditional parts marked]; (4) the independent label breaks the equivalence [proved]; (5) logical closure and the trichotomy [proved]; (6) time-bounded transfers and the Presburger separation [proved, given Fischer–Rabin]; (7) a circuit analogue of the derivation-charged sandwich [proof sketch]; (8) whether theoretical predicates are needed under the per-instance readings [open, conjecture].

---

## 1. Inventory: the relation results of the earlier report

Statements are transcribed with their constants and hypotheses. Numbers are the AI-paper's (Section 6 and Appendix E). All are refereed (model track once; TF and SD once each by two referees).

### 1.1 Setting

* **Language and data** (`def:time:inducers`, Def 6.2; model §6.1). L a countable first-order language (finite where a result says so), B ⊆ Sent_L a decidable *background*, part of every hypothesis (possibly empty). Data D = ((φ_1, b_1), …, (φ_n, b_n)), b_i ∈ {1 (true), 0 (false)}; φ^1 := φ, φ^0 := ¬φ.
* **AI.** A hypothesis is a program p of the universal prefix machine U that halts on every input and decides A_p ⊆ Sent_L; compatible with D iff B ∪ A_p is consistent and B ∪ A_p ⊢ φ_i^{b_i} for all i. W_AI(D) := Σ_{p compatible} 2^(−|p|).
* **FIcons.** A hypothesis is a program f computing a partial map Sent_L → {acc, rej} with B ∪ Γ_f consistent, Γ_f := {φ : f(φ) = acc} ∪ {¬φ : f(φ) = rej}; compatible iff it gives every φ_i the label b_i. **FIall** drops consistency.
* **Semimeasure convention.** ℓ_X(D) := −log₂ W_X(D) + log₂ W_X(∅), the sum of the per-step losses −log₂(W_X(D_j)/W_X(D_{j−1})); it depends on D only as a set. Hypotheses that leave φ undecided drop out, so W(D + (φ,1)) + W(D + (φ,0)) ≤ W(D).
* **Machine assumption (S)** (App. E, "Machines"; TF §1.2). U reads a program to its end before its input (so time_p(x) ≥ |p|); constants α, a ≥ 1 bound the cost of self-simulation, parsing, copying and a dovetailing schedule with a work counter (cost ≤ α(T+1)^a up to work T). a' := max(a, 2), a* := max(a, 3). Assumed, not checked for a particular U.
* **Clocked classes** (`def:time:penalties`, Def E.10; TF Def 1.2). U_0 a plain universal machine; f^τ(φ) := U_0(f, φ) if it halts within τ(|φ|) steps with acc/rej, abstain otherwise; weight w(f) := 2^(−|E(f)|), E the Elias-δ code of |f|+1 followed by f (Σ_f w(f) = 1, computable tails). **FIcons^τ**: clocked strings with B ∪ Γ_{f^τ} consistent. **FIcons^poly**: pairs (f, k), clock (|φ|+2)^k, weight w(f)·2^(−2⌈log₂(k+1)⌉−1).
* **Literal language sequences** (`def:time:short`, Def E.18; SD Def 1.3). L ∋ e, s_0, s_1, R; t_w := s_{w_1}(⋯s_{w_k}(e)⋯), φ_w := R(t_w), |φ_w| = |w| + 2; D^X lists (φ_w, [w ∈ X]) over all words in length-lexicographic order. (TF Convention 1.5 uses φ_w = R(bin(1w)); the results transfer between encodings computable and invertible in polynomial time.)
* **Bounded loss** (`lem:time:bounded`, Lemma E.11; TF Lemma 1.6) **[proved]**: for a mixture Σ_h v(h)[h compatible with D] with Σv < ∞ and compatibility inherited by prefixes, sup_n ℓ(D_n) < ∞ iff a single h with v(h) > 0 is compatible with every prefix. The *fit class* of an inductor is the set of X with bounded loss on D^X.

### 1.2 Free deduction

* **I1 (`prop:time:fiall`, Prop E.1) [proved].** Literals R(w_i) or ¬R(w_i) by independent fair coins, all labelled true (a consistent labelling): FIall's loss ≤ c (the program "always accept"); the expected loss of AI and FIcons ≥ n bits (a + a' ≤ 1 for the two predictive probabilities, then convexity).
* **I2 (`thm:time:equiv`, Thm 6.3) [proved; Craig 1953 known].** There is c, depending only on U, the coding of syntax and the decider of B, with 2^(−c) W_AI(D) ≤ W_FI(D) ≤ 2^c W_AI(D) for every finite D; the semimeasure losses differ by ≤ 2c in every order and labelling. Maps: p ↦ f_p := "dovetail proof searches for φ and ¬φ from B ∪ A_p" (|f_p| ≤ |p| + c'); f ↦ the decider of the Craig set A^C_f := {φ^{∧(k+1)} : f(φ) = acc in exactly k steps} ∪ {(¬φ)^{∧(k+1)} : f(φ) = rej in exactly k steps} (|p_f| ≤ |f| + c''). Both maps injective.
* **I3 (`rem:time:convention`, Rem E.2) [proved].** Renormalising per step, the argument gives only 2c bits *per step*.
* **I4 (`prop:time:twosorted`, Prop 6.4) [proved].** Two sorts, B = Q on the arithmetic sort: if Γ_f has a model, B ∪ A_f is consistent and Cn(B ∪ A_f) ∩ Sent_L = Cn(Γ_f), where A_f := {Acc_f(⌜φ⌝) → φ} ∪ {Rej_f(⌜φ⌝) → ¬φ} is Hänni's schema. Generalised in TF Prop 2.4(b1) to B = B_A ∪ B_L, Q ⊆ B_A ⊆ Th(ℕ), no mixed axioms.
* **I5 (`prop:time:single`, Prop 6.5) [proved, assuming Con(PA)].** One sort, B = PA: the f that accepts ¬Con(PA) and searches for a PA-proof of ⊥ on Con(PA) has Γ_f = {¬Con(PA)} consistent with PA, while PA ∪ A_f is inconsistent.
* **I6 (`prop:time:bounded`, Prop E.17; TF Prop 2.5) [proved, given MRDP].** One sort, B ⊇ Q decidable: the schema with binary witness bounds A^bd_f := {Acc^{≤k}_f(bin⌜φ⌝) → φ, Rej^{≤k}_f(bin⌜φ⌝) → ¬φ : φ, k} has Cn(B ∪ A^bd_f) = Cn(B ∪ Γ_f) for every assigner and membership decidable in polynomial time without running f. (Craig's idea in the form of Hänni's schema.)
* **I7 (templates; `prop:time:notemplate`, `prop:time:collapse`, Props 6.6–6.7) [proved, given partial truth predicates].** The acceptance part of Hänni's schema contains no non-ground DT° template; one ground reflection sentence ρ_{f,n}, of length ≤ a|f| + b_n, reproduces every Σ_n-sound assigner over PA on Σ_n sentences.

### 1.3 Time penalties with free deduction

* **I8 (`prop:time:cheap`, Prop 6.8) [proved].** Membership in A_f (binary numerals) and in A^C_f is decidable in time polynomial in |χ|.
* **I9 (`lem:time:padded`, Lemma E.12; TF Lemma 2.1) [proved under (S)].** For a program q with yes-set S_q, the padded enumerator e_q writes χ^{∧(T+1)} when it first detects "yes" on χ at work counter T; Pad(q) := the set written. (a) Cn(B ∪ Pad(q)) = Cn(B ∪ S_q); (b) its decider d_q runs in time ≤ α(|q|+1) + 3α(|χ|+1)^{a'}; (c) delay e_i − e_{i−1} ≤ 2α|a_i|^a, strict e_i ≤ 5α|a_i|^{a*}, cumulative e_i ≤ 2α(|a_1| + … + |a_i|)^a; (d) |d_q|, |e_q| ≤ |q| + c, injective.
* **I10 (`thm:time:onesided`, Thm 6.14; TF Thm 2.2, Thm 3.1) [proved under (S)].** (a) For t(m) ≥ m^{a*} time-constructible: 2^(−c) W_FI ≤ W_{AI^chk_t} ≤ W_AI ≤ 2^c W_FI and 2^(−c) W_FI ≤ W_{AI^gen_t} ≤ 2^c W_FI (strict, delay and cumulative forms). (b) The losses of AI, AI^chk_t, AI^gen_t exceed that of FIcons^τ by at most c_τ := c + c_1 + c_⊥ (c_1 the clock wrapper, c_⊥ := −log₂ w(always abstain)). General form (TF Thm 3.1): if W_X ≥ 2^(−c_X) Σ_{g compatible} u(g), W_X(∅) ≤ Ω_X, and each hypothesis h of Y maps injectively to an FIcons hypothesis g_h computing the same partial map with v(h, D) ≤ K u(g_h), W_Y(∅) ≥ κ, then ℓ_X ≤ ℓ_Y + c_X + log₂(KΩ_X/κ).
* **I11 (`prop:time:kt`, Prop E.13; TF Prop 2.3) [proved under (S)].** Kt weights 2^(−|p|)/c_p: W_{AI^Kt_t}(∅) ≤ t(m_0); 2^(−c) W_{FI^1} ≤ W_{AI^Kt_t} ≤ 2^c t(m_0) W_{FI^1}, FI^1 with weights 2^(−|f|)/(|f|+1): a Kt penalty costs log₂(|f|+1) + O(1) bits.
* **I12 (`thm:time:diagonal`, Thm 6.15; TF Thm 3.2, Cor 3.3, Prop 3.4) [proved, given the recursion and MRDP theorems].** L ⊇ L_A, B true in an expansion of ℕ. For every computable predictor P there is e such that s_n := Out(bin(e), bin(n), S0) has label b_n = e(n), each s_n is decided by H_0 := Q ∪ {DET} (DET a true Π₁ sentence), ℓ_P(D_n) ≥ n − Σ_j log₂(1 + 2^(−j−2)) ≥ n − 1/(4 ln 2) ≥ n − 0.361 (≥ n with exact outputs; attained up to rounding), while AI, AI^chk_t, AI^gen_t lose ≤ log₂(Ω/ω), independent of P. FIall^τ loses ≥ n − 1.37, FIcons^τ ≥ n − 1.37 − c_⊥. Converse: on I1's coin literals Hänni's S and FIall^τ have bounded loss and AI loses n in expectation, so they are incomparable with AI ("strictly stronger than every time-bounded function inductor" is **refuted**).
* **I13 (`prop:time:evaluator`, Prop E.15; TF Prop 4.1) [(a),(b) proved; (c) proof sketch].** A constant-size consistent assigner u (evaluate e on n) labels every diagonal sequence correctly; so *unpenalised* FIcons wins there too. The separation comes from free deduction, not from axioms; under a time bound it is a hierarchy effect.
* **I14 (`prop:time:disguised`, Prop E.16; TF Prop 5.1) [proved under (S)].** Under P1a and P2 (and two-sorted P3 with true B_A) the posterior odds of any two classes of theories move by at most 2^(2c); a slow assigner keeps weight 2^(−|f|−c).
* **I15 (content-relative penalty P3; TF Prop 2.4, SD Cor 4.9).** It bites on Craig-type sets [proved, given the time hierarchy]; it is vacuous through Hänni's schema in two sorts with a true arithmetic background [proved]; in one sort for assigners inconsistent with Th(ℕ) it is open in L_A and vacuous with a spare relation symbol (trace schema) [proved].
* **I16 (universal track, Prop U2t; `rem:time:links` (i), (ii)) [proved; (ii) proof sketch].** No penalty monotone in the number of derivation steps reverses `thm:univ:B` (instances never favour ∀xφ over its schema); a Kt-style penalty charges O(ln k) for generating 0 + S^k0 = S^k0, less than the derivation charge.

### 1.4 Deduction charged

* **I17 (`thm:time:ntime`, Thm 6.9; `cor:time:hard`, Cor 6.10) [proved; corollary given the NTIME hierarchy].** If T has membership in time O(n^e), T ∪ Γ_{f_X} is consistent and every φ_w, w ∈ X, has a K-derivation of symbol size ≤ ℓ(|w|), then X ∈ NTIME(ℓ(m)^{c_e}). Hence a decidable X forces every finite DT° theory consistent with Γ_{f_X} to use derivations above s(m) infinitely often.
* **I18 (`thm:time:sandwich`, Thm 6.16; SD Lemma 2.2, Cor 2.3, Thm 3.1; TF Thm 4.2) [proved, under (F1) for renaming-closed axiom sets; Cook–Reckhow known].** (a) In a normal derivation every line sits at its own node of an instance used or of φ (up to abstracting parameters), so size ≤ (M + |φ|)(M + |φ| + 1)/2, M the *material* (total size of distinct instances); the ½ is attained. (b) With t⁺(m) := m^{k_0}(t(m)+1), t'^#(m) := m^{k_0} + t'(m), G(m) := (g+m+1)(g+m+2)/2: W_{AI[t,g]} ≤ W_{AI^b[t,g]} ≤ W_{AI[t,G]} hypothesis by hypothesis; W_{AI^b[t,g]} ≤ 2^c W_{FIcert[t⁺, βG log₂(G+2)]}; W_{FIcert[t',d']} ≤ 2^c times each of W_{AI^b[t'^#, 2d'+m+31]}, W_{AI^{a1}[t'^#, d'+m+16]}, W_{AI[t'^#, 2d'+2m+31]}. FIcert[t', d'] = consistent assigners f_V defined by verifiers V with time O(t') and certificates of length ≤ d'. The certificate axioms are θ_c → φ with θ_c := Z → (C_c → Z) an A1 instance encoding c (|θ_c| = |c| + 14).
* **I19 (`cor:time:separations`, Cor 6.17).** (a) [proved, under (F1); conditional where stated] at polynomial budgets with degrees charged the fit class of reading (b) (total material) is NP ∩ coNP; per sequence it beats FIcons^poly if NP ∩ coNP ≠ P and has bounded loss on the same sequences if P = NP; with degrees uncharged, FIcons^poly fails to dominate it unconditionally (regret ≥ 2^r − O(log r)); against FIcons^τ it wins at a budget a hierarchy gap above τ. (b) [proved, under (F1); hierarchy and APSPACE = EXPTIME known] reading (a1) (every instance used, logical included, ≤ h) has fit class EXPTIME at polynomial budgets (deterministic time 2^{O(h log h)} in general, SD Thm 4.2; ground alternating axioms A_M with auxiliary relation symbols C, C' realise ASPACE(h)); every predictor computable in time polynomial in the number of data loses ≥ n − 0.361 on a literal sequence where (a1) at a linear budget loses O(1). (c) [proved] readings (a2), (b2) (only nonlogical axioms bounded) fit every decidable X, by finitely many universally closed Horn sentences (auxiliary symbols pr, C).
* **I20 (TF Cor 4.3(a); `lem:time:clocked`, Lemma E.22) [proved under (S)].** FIcons^τ is dominated by AI[t_C, d_τ], t_C a fixed polynomial, d_τ(m) := γ(τ(m)+1)(m+4) (the Craig set of the clocked assigner).
* **I21 (SD Prop 4.6) [proved; (ii) given TF Prop 2.5, MRDP and the hierarchy].** (i) For a literal assigner f, every K-derivation of φ_w^b from A^C_f contains (φ_w^b)^{∧(k+1)}, k = time_f(φ_w). (ii) A^bd_f is blocked under every reading for hard X.
* **I22 (`prop:time:soft`, Prop E.26; SD Thm 5.2, Prop 5.3) [proved].** Soft charges 2^(−κ·bits) per datum: certificate induction at rates (κ, κ) beats soft AI by ≥ κ(2 + b_s[b=0]) bits per datum; soft AI ≤ soft certificate induction at rate (31b_s + 26)κ + O(1); no pair of rates gives two-sided constant regret.
* **I23 (`prop:time:horn`, `cor:time:tight`; SD Prop 6.1) [proved; Book–Greibach–Wegbreit known].** Finite first-order-pattern Horn template theories simulate any certificate verifier with derivations quadratic in its time; `cor:time:hard` is tight up to polynomials on literal data.
* **I24 (`prop:time:channel`, SD Prop 7.1) [proved].** Without (F1) a parameter index (one symbol) carries an unpriced certificate.

### 1.5 What the report leaves open (relevant here)

Model §10 problems 12, 15; TF §7 items 1–10 (P3 in one sort; search versus decision for Craig sets; AI^Kt against FIcons^τ; soft penalties; the intermediate case P ≠ NP = NP ∩ coNP… more precisely NP ∩ coNP = P ≠ NP; history-using time-bounded predictors; a computable consistency filter; rates; the diagonal under charged deduction; machine dependence); SD §9. None of them is about SFI's one-tape or Kolmogorov versions, which the report does not define.

---

## 2. Mapping onto the SFI papers' definitions

### 2.1 Dictionary and definitions

P1's objects (`NOTATION.md`): V universal prefix machine, 𝐦(i) := Σ_{V(p)=i} 2^(−|p|), φ_e the e-th partial computable function, data sets D as finite partial functions X ⇀ Y. Here X := Sent_L (an infinite decidable set of strings), Y := {0, 1}, ⊥ = undefined. D^± := {φ^{D(φ)} : φ ∈ dom D}. B is a decidable *consistent* background.

**Definition 2.1 (consistent and closed labellers).** A partial function f : Sent_L ⇀ {0,1} is *consistent* if B ∪ Γ_f is consistent, Γ_f := {φ^{f(φ)} : φ ∈ dom f}; *closed* if moreover f(φ) = b ⟺ B ∪ Γ_f ⊢ φ^b for every φ and b.

**Definition 2.2 (coin-free versions).**
* W(D) := Σ_{p ∈ dom V} 2^(−|p|)[φ_{V(p)} ⊇ D] (P1 `def:versions:variants`); W_cons, W_cl: the same sum restricted to p with φ_{V(p)} consistent, respectively closed.
* K_F^cons(D) := min{|p| : φ_{V(p)} consistent, φ_{V(p)} ⊇ D} (∞ if none).
* AI in P1's format: a *decider* is p ∈ dom V such that φ_{V(p)} is total and {0,1}-valued on Sent_L; A_p := {χ : φ_{V(p)}(χ) = 1}; compatible with D iff B ∪ A_p is consistent and proves D^±. W_AI(D) := Σ_{p compatible} 2^(−|p|), K_AI(D) := min{|p| : p compatible}. (The report's hypotheses are U-programs; a U-program for a total function and a V-program for its index differ in length by a constant, so the report's W_AI is within a constant factor of this one.)

**Definition 2.3 (one-tape versions).**
* *Function machines* T, their random functions f^T_ω and laws ν_T are P1's (`def:setting:machine`). The *consistent part* of ν_T is ν^cons_T(D) := 𝕌{ω : f^T_ω ⊇ D and B ∪ Γ_{f^T_ω} consistent}. M_F^cons := ν^cons_{T_U} with P1's universal function machine T_U (`thm:setting:universal`).
* An *axiom machine* is a c.e. set G ⊆ {0,1}* × Sent_L of pairs (w, χ) ("after reading w from the tape, emit χ"). For a tape ω, A_G(ω) := {χ : (w, χ) ∈ G for some prefix w of ω}. Its law μ_G(D) := 𝕌{ω : B ∪ A_G(ω) is consistent and proves D^±}. With an enumeration (G_i) of all c.e. sets of pairs, the universal axiom machine is G_U := {(pw, χ) : p ∈ dom V, (w, χ) ∈ G_{V(p)}}, and M_AI := μ_{G_U}: one random theory per tape, read by every question.
* A *random decider* is a function machine T with outputs in {0,1} such that f^T_ω is total for every ω; A_T(ω) := {χ : f^T_ω(χ) = 1}; μ^dec_T(D) := 𝕌{ω : B ∪ A_T(ω) consistent, proves D^±}; M_AI^dec(D) := Σ_{i : T_i a random decider} 𝕞(i) μ^dec_{T_i}(D).

For D ≠ ∅ the universal objects decompose as in P1's eq. (setting:mixture):
  M_F^cons(D) = Σ_{p ∈ dom V} 2^(−|p|) ν^cons_{T_{V(p)}}(D),   (2.1)
  M_AI(D) = Σ_{p ∈ dom V} 2^(−|p|) μ_{G_{V(p)}}(D) + (1 − Ω_V)·[B ⊢ D^±],   (2.2)
with Ω_V := Σ_{p∈dom V} 2^(−|p|): on a tape with no prefix in dom V, T_U is nowhere defined and G_U emits nothing. **[proved]** (Tapes pω' with p ∈ dom V give f^{T_U}_{pω'} = f^{T_{V(p)}}_{ω'} and A_{G_U}(pω') = A_{G_{V(p)}}(ω'), with ω' uniform; dom V is prefix-free.)

### 2.2 Coin-free: AI is W restricted to consistent labellers

**Theorem 2.4 (coin-free equivalence; the report's Thm 6.3 in P1's format).** There is c, depending only on V, the coding of syntax and B, such that for every finite D:
(a) 2^(−c) W_AI(D) ≤ W_cons(D) ≤ 2^c W_AI(D), and 2^(−c) W_cons(D) ≤ W_cl(D) ≤ W_cons(D);
(b) K_AI(D) − c ≤ K_F^cons(D) ≤ K_AI(D) + c; both are finite iff B ∪ D^± is consistent;
(c) for every φ ∉ dom D and each outcome o ∈ {1, 0, ⊥}, the weights of compatible hypotheses that give φ the outcome o (for AI: prove φ, prove ¬φ, decide neither) satisfy 2^(−c) W_AI(D; φ ↦ o) ≤ W_cl(D; φ ↦ o) ≤ 2^c W_AI(D; φ ↦ o).
**[proved; Craig 1953 known]**

*Proof.* By universality of V there are strings r_ps, r_C, r_cl with V(r_ps p) = an index of "proof search from B ∪ A_p" (for every decider p), V(r_C p) = an index of the decider of the Craig set A^C_{φ_{V(p)}}, and V(r_cl p) = an index of "proof search from B ∪ Γ_{φ_{V(p)}}" (dovetailing the enumeration of Γ with the search). The maps p ↦ r p are injective and add |r| to the length. Put c := max(|r_ps|, |r_C|, |r_cl|).
* *AI → closed.* Let p be compatible. f_p := φ_{V(r_ps p)} labels φ with b iff B ∪ A_p ⊢ φ^b (the first proof found decides; consistency rules out both). So f_p ⊇ D, Γ_{f_p} ⊆ Cn(B ∪ A_p) is consistent with B, and f_p is closed: B ∪ Γ_{f_p} ⊢ ψ iff B ∪ A_p ⊢ ψ, because A_p ⊆ Γ_{f_p} (each axiom is a theorem) and Γ_{f_p} ⊆ Cn(B ∪ A_p). f_p decides φ exactly as the theory does.
* *Consistent → AI.* Let f := φ_{V(p)} be consistent with f ⊇ D. φ_{V(r_C p)} decides A^C_f (it halts on every input even when f is partial: every run is bounded by the exponent m of the candidate power), and Cn(B ∪ A^C_f) = Cn(B ∪ Γ_f), which is consistent and proves D^±. So r_C p is a compatible decider. If f is closed, the theory decides φ iff f does, with the same value.
* *Consistent → closed.* φ_{V(r_cl p)} is the closure of f: it extends f, is consistent and closed (same argument as the first bullet with Γ_f for A_p).
* (a) and (c) follow by summing over injective maps; (b) by taking shortest programs. B ∪ D^± consistent iff the lookup table of D is a consistent labeller iff the decider of the finite set D^± is compatible. ∎

**Remarks.** (i) *Enumerators.* With hypotheses that enumerate axiom sets (no decidability), Craig is not needed: the enumerator of Γ_f has length |f| + c. (ii) *Steeper priors (P2).* All maps add a constant c to the length, so the equivalence holds for priors 2^(−λ|p|) with factor 2^(λc), and two-part λ-MAP scores of theories and of consistent labellers differ by ≤ λc. **[proved]** (iii) The equivalence is not affected by the coin: what differs between the report's FIcons and P1's W is only the program format (U-programs reading their input, or V-programs printing an index), a constant.

### 2.3 One tape: random axiom systems are M_F restricted to consistent labellers

**Theorem 2.5 (one-tape equivalence).** There is c, depending only on V, the coding and B, such that for every finite D ≠ ∅:
(a) 2^(−c) M_AI(D) ≤ M_F^cons(D) ≤ 2^c M_AI(D);
(b) the same with M_AI^dec (random deciders) in place of M_AI;
(c) both inclusions hold tape by tape: for every axiom machine G there is a function machine T_G with K(T_G) ≤ K(G) + c and {ω : G compatible} ⊆ {ω : f^{T_G}_ω ⊇ D, consistent}; for every function machine T there is an axiom machine G_T with A_{G_T}(ω) = Γ_{f^T_ω}, hence {ω : f^T_ω ⊇ D, consistent} ⊆ {ω : G_T compatible}, and a random decider C_T with A_{C_T}(ω) the Craig set of f^T_ω.
**[proved; computed: finite propositional analogue in `checks/s1_onetape_toy.out`, items (1)–(3)]**

*Proof.* *T_G.* On query φ, read the tape one bit at a time as needed and run, in stages s = 1, 2, …: read up to bit s, run s steps of the enumeration of G on the prefix read, and test the derivations of size ≤ s from B together with the sentences emitted so far; halt with 1 at the first derivation of φ, with 0 at the first of ¬φ (φ tested first within a stage). The computation is deterministic in the bits read, and a halting run reads a determined prefix, so the triples (φ, w, y) of halting runs are consistent: T_G is a function machine, with an index computable from one of G. If B ∪ A_G(ω) is consistent and proves D^±, each datum has a derivation from finitely many emitted sentences, the search finds it, and never a derivation of the opposite literal; so f^{T_G}_ω ⊇ D, and Γ_{f^{T_G}_ω} ⊆ Cn(B ∪ A_G(ω)) is consistent with B.
*G_T* := {(w, φ) : (φ, w, 1) ∈ T} ∪ {(w, ¬φ) : (φ, w, 0) ∈ T}, c.e., so A_{G_T}(ω) = Γ_{f^T_ω}. If f^T_ω ⊇ D and B ∪ Γ consistent, then B ∪ A_{G_T}(ω) is consistent and contains D^±.
*C_T.* On query χ, find the at most two decompositions χ = ψ^{∧m} (TF Lemma 2.1(b)); if ψ = φ (resp. ψ = ¬φ), simulate T on query φ, reading the tape as T does, for exactly m − 1 steps, and output 1 iff T halts with 1 (resp. 0) at step m − 1; otherwise output 0. Every run is bounded, so C_T is a random decider. A_{C_T}(ω) is the Craig set of f^T_ω, with the same consequences as Γ_{f^T_ω}.
*(a).* By (2.1), (2.2) and the inclusions, summing over p ∈ dom V with the injective maps p ↦ r_T p (a V-program for an index of T_{G_{V(p)}}) and p ↦ r_G p (for G_{T_{V(p)}}):
  Σ_p 2^(−|p|) μ_{G_{V(p)}}(D) ≤ 2^{|r_T|} M_F^cons(D),   M_F^cons(D) ≤ 2^{|r_G|} Σ_p 2^(−|p|) μ_{G_{V(p)}}(D) ≤ 2^{|r_G|} M_AI(D).
The remaining term (1 − Ω_V)[B ⊢ D^±] of (2.2) is ≤ 1, and if B ⊢ D^± the deterministic machine "proof search from B", which is consistent and extends D on every tape, gives M_F^cons(D) ≥ 2^(−c_B). So M_AI ≤ (2^{|r_T|} + 2^{c_B}) M_F^cons.
*(b).* A random decider T is an axiom machine (emit χ when T outputs 1), so M_AI^dec ≤ 2^c M_AI; and C_{T_{V(p)}} gives M_AI^dec ≥ 2^(−c) M_F^cons. ∎

*Overhead.* The constants are those of three wrappers (proof search over emitted axioms; emission of Γ; Craig) and of "proof search from B". Nothing in the proof uses lower semicomputability.

**Remark (penalised one-tape versions) [proof sketch].** Padding by the work counter (TF Lemma 2.1) works tape by tape: the padded random decider replays the dovetailing schedule of T on the tape bits up to the claimed counter, which reads at most |χ| bits, so membership stays polynomial in |χ| on every tape and the one-tape analogue of TF Thm 2.2 holds. Not written out: (S) for machines that read a tape.

### 2.4 The chain, and AI as SFI on positive literals

**Proposition 2.6 (chain for the consistent versions).** For every D ≠ ∅ with B ∪ D^± consistent,
  2^(−K_F^cons(D)) ≤ W_cons(D) ≤ 2^c M_F^cons(D) ≤ 2^{K(dom D)+c} 2^(−K_F^cons(D)),
and the same with K_AI, W_AI, M_AI by Theorems 2.4, 2.5. Moreover log₂(M_F^cons(D)/W_cons(D)) ≤ K^pad(L^cons_{1/2}(D)) + c, where L^cons_{1/2}(D) is the least L such that 𝕌{ω : D is produced within ω_{1:L}, f_ω consistent} ≥ M_F^cons(D)/2. **[proved, given P1 `thm:setting:coding`(a) and the argument of `prop:versions:tape`(a)]**

*Proof.* First: a shortest consistent program is a term of W_cons. Second: a consistent deterministic labeller is a function machine (ignoring the tape) that is consistent on every tape; with (2.1), W_cons(D) ≤ 2^c M_F^cons(D) by the wrapper "treat φ_{V(p)} as a machine". Third: M_F^cons(D) ≤ M_F(D) ≤ 2^{−K(D | dom D)+c} (P1 `thm:setting:coding`(a)); the lookup table of D is consistent (B ∪ D^± is), so K_F^cons(D) ≤ K(D) + c ≤ K(dom D) + K(D | dom D) + c. *The K^pad bound.* P1's proof of `prop:versions:tape`(a) uses the programs "simulate T with stored tape prefix w", |w| = L' ≥ L, K(L') = K^pad(L); the stored-prefix function φ_{T,w} is a sub-function of f^T_ω for every ω extending w, so it is consistent whenever some extension of w is a consistent tape. Counting only those w gives W_cons(D) ≥ 2^{−K(T)−K^pad(L)−c} 𝕌{ω : D produced within ω_{1:L}, f^T_ω consistent}; apply it with T = T_U and L = L^cons_{1/2}(D). ∎

**Theorem 2.7 (AI is SFI on positive literals).** Let L ⊇ {e, s_0, s_1, R}, P := {R(t_w) : w ∈ {0,1}*}, and let B be a decidable set of R-free sentences with a model in which the closed terms t_w are pairwise distinct (e.g. B = ∅). For a data set D with dom D ⊆ P and labels in {0,1}, let D^str := {(w, b) : (R(t_w), b) ∈ D}, a data set of P1 over X = {0,1}*. Then there is c with
  |K_AI(D) − K_F(D^str)| ≤ c,  2^(−c) W(D^str) ≤ W_AI(D) ≤ 2^c W(D^str),  2^(−c) M_F(D^str) ≤ M_AI(D) ≤ 2^c M_F(D^str) (D ≠ ∅),
where K_F, W, M_F are P1's objects on strings. **[proved]**

*Proof.* By Theorems 2.4 and 2.5 it suffices to compare K_F^cons, W_cons, M_F^cons on sentences with K_F, W, M_F on strings. *Strings to sentences.* For a partial computable g on strings let g^P(R(t_w)) := g(w), undefined off P; for a function machine T on strings let T^P answer R(t_w) as T answers w and abstain off P. Γ_{g^P} is a set of literals ±R(t_w) over pairwise distinct atoms, at most one per atom; it is consistent with B, since a model of B with distinct t_w can be given any R. So g^P and T^P (on every tape) are consistent, extend D iff g, T extend D^str, and have programs longer by a constant. *Sentences to strings.* For any labeller f on sentences let f^str(w) := f(R(t_w)); likewise for machines. f ⊇ D implies f^str ⊇ D^str, at a constant cost. Sum over injective maps and take shortest programs. ∎

**Corollary 2.8 (transfers).** Every result of P1 about data sets with labels in {0,1} that holds up to additive constants in K_F, −log W or −log M_F holds for axiom induction on positive literal data, with t_w for w and the same d = |w|. In particular **[proved, by Thm 2.7 and P1]**:
(a) *No coding theorem for axiom systems* (P1 `thm:versions:nocoding`): for every d ≥ 2 there are words x_1 ≠ x_2 of length d with D := {(R(t_{x_1}), 0), (R(t_{x_2}), 1)} such that every decider of a consistent axiom set proving ¬R(t_{x_1}) and R(t_{x_2}) has length ≥ log d − c, the total weight of such deciders is ≥ 2^{−2−K(⌈log(d+1)⌉)−c}, and M_AI(D) ≥ 2^{−2−c}.
(b) *Random theories beat deterministic ones* (P1 `prop:versions:Wgap`(a), `prop:versions:tape`): sup_D M_AI(D)/W_AI(D) = ∞ on two-point literal data, while on binary literal data over words of length ≤ d, log₂(M_AI(D)/W_AI(D)) ≤ K^pad(2^{d+1}) + c ≤ K(⌈log(d+1)⌉) + c'.
(c) *The chain* (P1 `thm:versions:chain`) and the covering bound (`prop:versions:covering`) for K_AI.
(d) The binary-label examples of P1's Sections 6–8 (Eisenstat's coin example, `thm:ex:expected`; order-independence lower bounds; the out-of-distribution bounds with binary labels) hold for M_AI on the encoded data.

So the content of axiom induction beyond SFI lies entirely in logically structured data. AI-paper Prop E.1 (I1) is an instance: its inputs are R(w_i) *or* ¬R(w_i); re-encoded as positive literals they are fair-coin labels, on which SFI loses n bits too. FIall's constant loss comes from treating ¬R(w) as an input unrelated to R(w); consistency is what ties them. **[proved: the re-encoding (¬R(w), true) ↦ (R(w), false) is a bijection of data sets that preserves consistent compatibility; P1's coin lower bound]**

### 2.5 Time-bounded and circuit SFI

P1 §9 (`sec:comp`) has two computable relatives: *time-bounded mixtures* of x-only probability predictors with length or round activation (M_len, M_rd, `def:comp:timebounded`, `prop:comp:round`, `cor:comp:poly`; private randomness per input, inconsistent hypotheses allowed) and *circuit SFI* (W_circ over circuits on d bits, `def:comp:circuits`). The report's FIcons^τ is a third kind: clocked *deterministic consistent* labellers (a clocked W_cons). Let M_F^{cons,τ} := Σ_f w(f) ν^cons_{T^τ_f}, the one-tape analogue: T^τ_f runs f on U_0 with a tape-reading instruction for at most τ(|φ|) steps and abstains otherwise; M_F^{all,τ} without the consistency restriction.

**Theorem 2.9 (time-bounded SFI against axiom induction).** Let L ⊇ L_A and B be true in an expansion of ℕ for (b)–(d).
(a) *Domination.* ℓ_{M_AI}(D) ≤ ℓ_{M_F^{cons,τ}}(D) + c_τ and ℓ_{AI}(D) ≤ ℓ_{W_cons^τ}(D) + c_τ for every D, with c_τ := c + c_1 + c_⊥ (c_1 the clock wrapper, c_⊥ := −log₂ of the weight of the always-abstaining string). **[proved; the second inequality is TF Thm 3.1; the first by TF Thm 3.1's argument with Thm 2.5]**
(b) *Diagonal, one tape.* There is a computable sequence of arithmetic sentences on which ℓ_{M_F^{all,τ}} ≥ n − 1.37, ℓ_{M_F^{cons,τ}} ≥ n − 1.37 − c_⊥, and ℓ_{M_AI} ≤ log₂(1/ω) with ω the M_AI-weight of the deterministic enumerator of H_0 = Q ∪ {DET}. **[proved, given TF Thm 3.2, Cor 3.3]**
(c) *P1's time-bounded mixtures.* M_len and M_rd (with computable weights with computable tails) are computable predictors on labelled sentences; each loses ≥ n − 0.361 (≥ n with exact rational outputs) on a computable sequence on which AI, AI^chk_t, AI^gen_t and M_AI lose O(1). Conversely, on AI-paper Prop E.1's coin literals all labelled true, M_rd has bounded loss (the constant predictor "true with probability 1" is in 𝒞_t, P1 `prop:comp:round`) while AI, W_cons, M_AI and M_F^cons lose ≥ n bits in expectation. So P1's time-bounded SFI and AI are incomparable. **[proved, given TF Thm 3.2 and P1 `prop:comp:round`]**
(d) *Source.* Unpenalised W_cons and M_F^cons have bounded loss on every sequence of (b), (c) through the constant-size consistent evaluator u of TF Prop 4.1. **[proved]**

*Proof.* (a) T^τ_f is a function machine whose V-program is a fixed wrapper followed by E(f), injectively; by (2.1), M_F^cons(D) ≥ 2^(−c_1) Σ_f w(f) ν^cons_{T^τ_f}(D), and M_AI ≥ 2^(−c) M_F^cons (Thm 2.5). With M_AI(∅) ≤ 1 and M_F^{cons,τ}(∅) ≥ 2^(−c_⊥), ℓ_{M_AI}(D) ≤ −log₂ M_F^{cons,τ}(D) + c + c_1 ≤ ℓ_{M_F^{cons,τ}}(D) + c_τ. (b) ν_{T^τ_f}(D) is computable exactly: each query reads at most τ(|φ|) bits, so the event is a finite union of cylinders. With computable tails of w, M_F^{all,τ} is a computable weak semimeasure with M_F^{all,τ}(∅) = 1, and P(D) := (M_F^{all,τ}(D) + 2^(−|D|))/2 is a computable predictor with q_0 + q_1 ≤ 1 (TF Cor 3.3(a)). Run TF Thm 3.2 against P: ℓ_P(D_n) ≥ n − 0.361; M_F^{all,τ}(D_n) ≤ 2P(D_n) gives ℓ_{M_F^{all,τ}} ≥ n − 1.37, and M_F^{cons,τ} ≤ M_F^{all,τ} with M_F^{cons,τ}(∅) ≥ 2^(−c_⊥) gives the second bound. H_0 is finite and true in ℕ, B ∪ H_0 is consistent and decides every s_n, so the deterministic axiom machine emitting H_0 is compatible with every D_n on every tape. (c) TF Thm 3.2 needs only that the predictor be computable. M_rd's predictive conditionals are finite computations (clocked runs of the active machines) plus the computable tail weight of the inactive ones, which all predict uniformly. The converse is P1 `prop:comp:round` with A := "true with probability 1", and AI-paper Prop E.1 for the consistent inductors (for M_F^cons and M_AI the same proof applies tape by tape: a consistent sampled labeller cannot accept both R(w) and ¬R(w)). (d) TF Prop 4.1. ∎

**Proposition 2.10 (a natural separation: Presburger arithmetic).** Let L := {0, 1, +, =}, B := ∅, and let D^Pres list all L-sentences in length-lexicographic order, labelled by truth in (ℕ, 0, 1, +). Then ℓ_AI(D^Pres_n) ≤ |p_PrA| for all n (p_PrA a decider of Presburger's axioms), while for every time-constructible τ with τ(m) ≤ 2^{2^{c'm}} for all large m, c' small enough, ℓ_{W_cons^τ}(D^Pres_n) → ∞. **[proved, given Fischer and Rabin 1974 (known: statement from the published abstract) and the completeness of Presburger's axiomatisation (known)]**

*Proof.* Presburger's axioms form a decidable consistent set whose deductive closure is Th(ℕ, 0, 1, +) [known], so p_PrA is compatible with every D^Pres_n and ℓ ≤ |p_PrA| (W_AI(∅) ≤ 1). If one τ-clocked string f labelled every datum correctly, f^τ would decide Th(ℕ, 0, 1, +), within q(C_f τ(m) + m) multitape steps on sentences of length m (overhead q of TF Convention 1.5). Fischer and Rabin: every nondeterministic (so every deterministic) decision procedure runs more than 2^{2^{cm}} steps on some sentence of length m, for every large m, with a fixed c > 0 [known]. For c' < c (adjusted for the encoding), q(C_f 2^{2^{c'm}} + m) < 2^{2^{cm}} for large m, a contradiction. By AI-paper Lemma E.11, ℓ_{W_cons^τ}(D^Pres_n) → ∞. ∎

The same paper bounds proof lengths: for complete axiomatisations with easily recognised axioms, some true sentences of length m need proofs longer than 2^{2^{cm}} [known: from the abstract; the exact condition "easily recognised" not checked]. So under charged deduction AI fails on D^Pres too, at every budget below that: the separation is again free deduction (I13), here on a natural theory. *One tape* **[conjecture]**: ℓ_{M_F^{cons,τ}}(D^Pres_n) → ∞ as well. Route: a clocked machine with a positive-measure set of correct tapes gives, by Lebesgue density, a bounded-error probabilistic procedure on a cylinder, hence (Sipser–Gács–Lautemann) a two-alternation procedure in time poly(τ); then a lower bound for alternating machines (Berman 1980) would finish. Not checked: Berman's exact statement.

**Circuit SFI.** The correspondence for circuits is the non-uniform form of the derivation-charged sandwich (I18): axiom sets of size s with derivations of size ℓ on d-bit literals correspond to verifier circuits (NP ∩ coNP-type) of size poly(s, ℓ, d), not to deterministic circuits. Proof sketch in §4, candidate 7.

### 2.6 What breaks

**Proposition 2.11 (logical closure and the trichotomy).** Let B ∪ D^± be consistent and B ∪ D^± ⊢ χ, χ ∉ dom D.
(a) Every AI hypothesis compatible with D proves χ, so P_AI(1 | D, χ) = 1 and P_AI(0) = P_AI(independent) = 0; the same for M_AI.
(b) No consistent labeller extending D labels χ false, so P_cons(0 | D, χ) = 0; P_cons(1 | D, χ) ≥ 2^(−2c) (Thm 2.4); and P_cons(⊥ | D, χ) ≥ 2^{−K(D)−c}/W_cons(D) ≥ 2^{−K(D)−c} > 0: the lookup table of D is consistent and abstains on χ. The same for M_F^cons.
(c) After restricting SFI to closed labellers, all three predictive probabilities agree with AI's within a factor 2^(2c) (Thm 2.4(c)), and W_cl ≍ W_cons.
**[proved; computed: `checks/s1_onetape_toy.out`, items (4)–(5)]**

So the report's trichotomy for AI (true / false / independent of the sampled theory) and P1's defect (the sampled labeller abstains or diverges) are different things: SFI's ⊥ mixes logical independence with laziness. The equivalence of Theorems 2.4–2.5 controls the semimeasure losses, not the size of the ⊥ mass.

**Remark 2.11' (three outcomes are a measure) [proved; computed: s1 item (6)].** For AI, W(D + (φ,1)) + W(D + (φ,0)) + W(D + (φ, ind)) = W(D) for φ ∉ dom D, where (φ, ind) is compatible with p iff B ∪ A_p decides neither φ nor ¬φ: each compatible theory falls in exactly one class. So the author's trichotomy makes AI's prediction a full probability over {true, false, independent}, with no missing mass; for SFI the three-way split has a defect (divergence).

**Proposition 2.12 (an observed "independent" label breaks the equivalence).** Let L = L_A, B = Q. Allow data labels in {1, 0, ind}. AI3: p is compatible iff B ∪ A_p is consistent, proves the 1/0-labelled data and decides neither φ nor ¬φ for each ind-labelled φ. FI3: a partial computable f : Sent ⇀ {1, 0, ind} is consistent iff B ∪ Γ_f is consistent (Γ_f from the 1/0 outputs) and B ∪ Γ_f decides none of the sentences f labels ind; W_FI3 sums 2^(−|p|) over consistent φ_{V(p)} ⊇ D. Then:
(a) 2^(−c) W_FI3(D) ≤ W_AI3(D) for every D;
(b) sup_D W_AI3(D)/W_FI3(D) = ∞, already over one-datum sets {(σ, ind)}: for every n there is a sentence σ_n with W_AI3({(σ_n, ind)}) ≥ 2^(−c) and W_FI3({(σ_n, ind)}) ≤ Ω_V^{>n} := Σ_{p ∈ dom V, |p| > n} 2^(−|p|) → 0;
(c) the gap on {(σ_n, ind)} is at most K(σ_n) + c (the lookup table is consistent).
**[proved, given Kleene's recursion theorem and AI-paper Lemma E.14 (Σ₁ facts about Q via MRDP)]**

*Proof.* (a) Map f to the Craig decider of Γ_f (1/0 outputs): its theory Cn(B ∪ Γ_f) proves the 1/0 data and, by the consistency of f, decides none of f's ind sentences.
(b) Let Ind_Q := {σ : Q ⊬ σ, Q ⊬ ¬σ}. *Productivity.* Given an r.e. W ⊆ Ind_Q, by the recursion theorem take a program e that on input 0 searches simultaneously for σ_e := Out(bin(e), bin(0), S0) in W and for a Q-proof of ¬σ_e, and halts with output 1 when either is found. If either search succeeds, e outputs 1 on 0, so σ_e is a true existential Diophantine sentence and Q ⊢ σ_e (AI-paper Lemma E.14(c)); then σ_e ∈ W ⊆ Ind_Q is impossible, and Q ⊢ ¬σ_e would make Q inconsistent. So neither succeeds: e does not halt on 0 with output 1, σ_e is false, Q ⊬ σ_e (Q is true in ℕ), Q ⊬ ¬σ_e, and σ_e ∉ W. *The data.* Let F_n be the finite set of p ∈ dom V with |p| ≤ n and φ_{V(p)} a consistent three-valued labeller, and I_n := ∪_{p ∈ F_n} {σ : φ_{V(p)}(σ) = ind}, an r.e. set (a finite union). For p ∈ F_n, f(σ) = ind implies B ∪ Γ_f ⊬ σ, ¬σ, hence Q ⊬ σ, ¬σ; so I_n ⊆ Ind_Q. Let σ_n := σ_e for W := I_n. Every consistent f compatible with {(σ_n, ind)} labels σ_n ind, so its program is not in F_n and has length > n: W_FI3 ≤ Ω_V^{>n}. The decider of ∅ (theory Q) is compatible: W_AI3 ≥ 2^(−c).
(c) The labeller "ind on σ_n, undefined elsewhere" is consistent, since σ_n ∈ Ind_Q. ∎

The witnesses σ_n are not computable from n (F_n is not), like P1's gap witnesses. The mechanism: "the theory decides neither" is a Π₁ property that a theory has without committing to anything, while a labeller must output ind after finitely many steps, and the sentences it can safely call independent form an r.e. subset of a productive set.

**Remark 2.13 (shared versus private randomness).** P1's product mixture M_prod draws private coins per input. Consistency and private randomness are incompatible on logically related sentences: if a product law P has P(1 | φ) > 0 and P(1 | ψ) > 0 with B ∪ {φ, ψ} inconsistent, the sampled labeller is inconsistent with probability ≥ P(1|φ)P(1|ψ), and the consistent part of a product law is not a product law (it correlates the labels). **[proved]** The shared tape is what makes a random labeller a random *theory*; private randomness is harmless only on logically independent sentences such as positive literals (Thm 2.7). Product laws are machine laws (P1 `prop:setting:includes`(a)), so M_F^cons dominates their consistent parts; nothing else is lost.

**Remark 2.14 (pathwise versus machine-wise consistency) [open; bounds proved].** M_F^cons conditions on the event that the *sampled* labeller is consistent. The alternative M_F^C := Σ_i 𝕞(i)[T_i consistent on every tape] ν_{T_i} satisfies W_cons ≤ 2^c M_F^C ≤ 2^c M_F^cons, and by Prop 2.6, M_F^cons ≤ 2^{min{K^pad(L^cons_{1/2}), K(dom D)} + c} M_F^C. A consistent machine cannot simulate T on the consistent tapes alone, since inconsistency is detected only in the limit and outputs cannot be withdrawn. Whether M_F^cons/M_F^C is bounded is open.

**Remark 2.15 (no lower semicomputability).** Consistency of B ∪ Γ_f is Π₁, so W_cons, W_AI, M_F^cons, M_AI are not lower semicomputable, and their predictive probabilities are not even approximately computable (TF Cor 3.3(c)); W_cons(D) is computable relative to ∅' (finitely many Δ₂ indicators up to a computable tail). P1's universality results ("M_F dominates every lsc ...") have only the restricted analogue "M_F^cons dominates ν^cons_T for every machine T", which is what Theorems 2.4–2.9 use. **[proved]**

### 2.7 Where the report's statements need restating

1. "Axiom induction ≡ consistent function induction" (Thm 6.3) → **≡ coin-free consistent SFI, W_cons** (Thm 2.4); one-tape SFI corresponds to random axiom systems (Thm 2.5); the Kolmogorov version K_AI = K_F^cons ± c is new.
2. FIall is W on sentences, FIcons is W_cons, and FIcons^τ is a clocked W_cons. P1's time-bounded SFI (M_len, M_rd) is neither: it is a product (private-randomness) mixture admitting inconsistent hypotheses, so only the diagonal and the coin-literal converse apply (Thm 2.9(c)).
3. The constant of Thm 6.3 depends on V (or U), the syntax coding and B; in P1's format the hypotheses are V-programs printing indices.
4. AI-paper Prop E.1 (FIall beats AI by n bits) should be read as a statement about encodings: on positive literals AI and SFI coincide (Thm 2.7); the gap comes from FIall treating φ and ¬φ as unrelated inputs.
5. The trichotomy (AI-paper §2.7) is not invariant under the equivalence; it matches SFI only over closed labellers (Prop 2.11), and with independence as an observed label the equivalence is one-sided (Prop 2.12).
6. The semimeasure convention is P1's: the report's ℓ(D) = −log W(D) + log W(∅) equals P1's cumulative loss L_ν(D) + log ν(∅) (P1 `prop:setting:order`). The normalised convention gives only 2c bits per step (I3), as in P1, where normalised lower bounds do not transfer.
7. The diagonal (Thm 6.15) applies verbatim to every computable predictor, P1's M_rd included (Thm 2.9(c)).

---

## 3. The theoretician's dilemma

### 3.1 The classical debate (known)

* Craig (1953) [known]: every recursively enumerable theory has a recursive (indeed primitive recursive) axiomatisation; the axioms are padded conjunctions φ ∧ … ∧ φ, the number of conjuncts encoding (in the usual presentations) a proof or an enumeration index. Craig (1956) applied it to the replacement of "auxiliary" (theoretical) expressions [known; bibliographic data checked; content not checked].
* Hempel (1958) [known; content from secondary sources]: the theoretician's dilemma. If theoretical terms serve their purpose of establishing connections among observables, they can be dispensed with (by Craig's method or Ramsey sentences); if they do not, they should be; so they are unnecessary. Hempel's own replies included that Craigian axiomatisations are infinite and practically unmanageable, and that theoretical terms may be logically indispensable for *inductive* systematisation (as summarised by Niiniluoto 1972).
* Putnam (1965) [known; content from secondary sources]: Craig's theorem does not show theoretical terms eliminable, since science aims not only at prediction; theoretical terms are needed to talk about theoretical entities.
* Finite axiomatisability with additional predicates: Kleene (1952) and Craig–Vaught (1958) [known; statements from secondary sources]: recursively axiomatisable theories (with only infinite models, in Kleene's form) have finitely axiomatisable conservative extensions in richer languages. Examples [known]: PA is not finitely axiomatisable (Ryll-Nardzewski 1952), while ACA₀ is a finitely axiomatisable conservative extension; ZF is not finitely axiomatisable (Montague 1961), while NBG is a finitely axiomatisable conservative extension.

The task is to make "Craigian axiomatisations are useless in practice" precise with the time-bounded results, and to say exactly what it does and does not establish.

### 3.2 Setting

L = L_O ∪ L_T, a finite language whose non-logical symbols split into observational and theoretical ones; equality is logical. Data are observational sentences. AI_L admits deciders of axiom sets A ⊆ Sent_L; AI_O admits only A ⊆ Sent_{L_O}; B ⊆ Sent_L is decidable and common to both. For a theory, T_O := Cn(B ∪ A) ∩ Sent_{L_O} is its observational content. Penalised and derivation-charged variants are those of §1.

### 3.3 Hempel's horn: free deduction

**Theorem 3.1 (theoretical vocabulary costs O(1) bits).** There is c such that for every finite observational D:
(a) 2^(−c) W_{AI_L}(D) ≤ W_{AI_O}(D) ≤ W_{AI_L}(D); the same for AI^chk_t and AI^gen_t (t ≥ m^{a*}, every form, under (S)), for K_AI (±c), and for the one-tape M_AI;
(b) for every class Θ of sets of observational sentences, W_{AI_O}(Θ; D) ≥ 2^(−c) W_{AI_L}(Θ; D), where W(Θ; D) is the weight of the compatible hypotheses with observational content in Θ; so posterior odds between classes of observational contents agree within 2^(2c);
(c) the predictive probabilities of every observational sentence agree within 2^(2c).
**[proved, given Craig (known) and, for the penalised versions, TF Lemma 2.1 under (S)]**

*Proof.* AI_O ⊆ AI_L gives the upper bounds. For p ∈ AI_L, let f_p^O be proof search from B ∪ A_p restricted to observational inputs (abstain elsewhere); Γ_{f_p^O} = T_O, because ¬φ is observational when φ is. Its Craig set (or, for the penalised versions, Pad(q) for q := "yes on χ iff χ ∈ T_O", TF Lemma 2.1) consists of powers of observational sentences, so it is observational, and Cn(B ∪ A^C) ∩ Sent_{L_O} = T_O: ⊇ since T_O ⊆ Cn(A^C); ⊆ since A^C ⊆ Cn(B ∪ A_p). Its decider has length ≤ |p| + c, injectively. Compatibility with observational data depends only on T_O, and consistency is inherited from B ∪ A_p. The class statement (b) follows because the map preserves T_O; (c) by dividing. One tape: apply the same map to the emitted sets, tape by tape (Thm 2.5). ∎

So in the Solomonoff setting with free deduction, theoretical terms are dispensable for prediction *and* for the prior: the posterior over observational contents, hence inductive support in the sense of the posterior predictive, is unchanged up to a constant factor. This is the precise form of Hempel's horn here, and it contradicts, for this notion of inductive systematisation, the thesis that theoretical terms are indispensable for it. (Hempel's own definition of inductive systematisation was not checked.)

### 3.4 The practical horn: charged deduction

**Lemma 3.2 (Craig's padding writes a number in unary).** Let T be any axiom set, B consistent, and let f^can_T be canonical proof search: on input φ it tests the binary strings in length-lexicographic order as codes of K-derivations from B ∪ T (in a code with at least one bit per symbol), spending at least one step per string, and stops at the first derivation of φ or ¬φ. Let d(φ^b) be the least symbol size of a derivation of the provable one of φ, ¬φ. Then
(a) time_{f^can_T}(φ) ≥ 2^{d(φ^b)} − 1;
(b) for literal observational data (B = ∅, or B as in Thm 2.7) every derivation of φ_w^b from the Craig set of f^can_T restricted to literals (exact-time or padded by the work counter) contains a line of size ≥ 2^{d(φ_w^b)}|φ_w^b|, so its size, material and largest instance are all ≥ 2^{d(φ_w^b)}|φ_w^b|;
(c) Craig's padding by the binary Gödel number of a derivation has the same lower bound up to a factor 2.
**[proved; (b) uses SD Prop 4.6(i); computed: `checks/s2_craig_blowup.out`]**

*Proof.* (a) The derivations of φ^{1−b} do not exist (consistency), and every string of length below the least code length ℓ(φ^b) ≥ d(φ^b) is tested and fails: at least 2^{ℓ} − 1 tests. (b) SD Prop 4.6(i): the Craig axioms are powers of literals; if none used were a power of φ_w^b, the term algebra with R satisfying the used literals and falsifying φ_w^b would refute the derivation. The only power of φ_w^b in the set has k + 1 ≥ time + 1 factors (padded sets: the counter is at least the simulated time). (c) A derivation with a code of length ℓ has binary Gödel number ≥ 2^{ℓ−1}. ∎

**Theorem 3.3 (Craig-type axiomatisations are polynomial-time labellers).** Literal data, B as in Thm 2.7. Call an axiom set *run-padded* if each member is a power ψ^{∧m}, m ≥ 1, of a literal ψ ∈ {R(t_w), ¬R(t_w)}. Let A be run-padded with membership decidable in polynomial time, and h a polynomial. If A is compatible with every D^X_n under reading (a1), (a2), (b), (b2) or derivation size ≤ h, then X ∈ P. Conversely every X ∈ P is fitted under all these readings, at some polynomial budget, by a run-padded set with polynomial membership.
**[proved; the converse is AI-paper Lemma E.22]**

*Proof.* Under each reading the axiom of A cited for φ_w^b has size ≤ h(|φ_w|) (it is a line, a nonlogical instance and part of the material). As in Lemma 3.2(b), some cited member is a power of φ_w^b. Decide w: for m = 1, …, h(|φ_w|), test whether (φ_w)^{∧m} or (¬φ_w)^{∧m} is in A; accept iff a power of φ_w is. This takes polynomially many polynomial-time tests. Correctness: a power of φ_w in A makes A ⊢ φ_w, so w ∈ X (else A, which proves ¬φ_w, would be inconsistent); and if w ∈ X the derivation within budget cites a power of φ_w with m ≤ h. Converse: a polynomial-time labeller of X, clocked, gives the Craig set of Lemma E.22, with membership in a fixed polynomial time and derivations (the Craig axiom, a substitution instance of a fixed propositional derivation of (B ∧ C) → B, and MP) of size and largest instance O((τ(m) + 1)(m + 4)). ∎

The mechanism: a run-padded axiom carries O(log) bits of information (its length), so the deriver's choice of axiom is a polynomial search; a certificate axiom θ_c → φ carries |c| bits, which no polynomial search recovers.

**Corollary 3.4 (the practical horn).** On literal sequences, at polynomial budgets with polynomial membership and degrees charged:

| hypotheses | (b) total material | (a1) every instance | (a2), (b2) nonlogical axioms only |
|---|---|---|---|
| run-padded (Craig-type), observational | P | P | P |
| observational certificate sets θ_c → φ | ⊇ NP ∩ coNP | ⊇ NP ∩ coNP | ⊇ NP ∩ coNP |
| all hypotheses (auxiliary predicates allowed) | NP ∩ coNP | EXPTIME | all decidable X |

Hence, unconditionally, under (a1) [X ∈ EXPTIME ∖ P, time hierarchy] and under (a2), (b2) [X decidable ∖ P], there are observational regularities fitted by axiom sets that use auxiliary (theoretical) predicates — the ground alternating axioms A_M (symbols C, C') and the finite Horn sentences T^∀_M (symbols pr, C) — and by no Craigian observational axiomatisation. Under (b) Craig-type sets lose to observational certificate sets on some sequence iff NP ∩ coNP ≠ P. **[proved, given SD Cor 3.2, Cor 4.4, Prop 4.12 (under (F1)), the hierarchy theorem (known) and Thm 3.3]**

**Proposition 3.5 (elimination by proof padding, reading (b)).** Let L be finite, B ⊆ Sent_{L_O} decidable in polynomial time, and (F1) as in SD. For every hypothesis p of AI_L[t, d] there is an observational hypothesis p' of AI_O[t⁺#, d''] with |p'| ≤ |p| + c, compatible with every observational D with which p is, where t⁺#(m) := m^{k_1} + m^{k_0}(t(m) + 1) and d''(m) := γ(m + βd(m) log₂(d(m) + 2) + 1). Hence W_{AI_L[t,d]}(D) ≤ 2^c W_{AI_O[t⁺#, d'']}(D) on observational data. **[proved, given TF Thm 4.2 (a), (b), under (F1)]**

*Proof.* TF Thm 4.2(a) maps p to the verifier V_p ("c codes a derivation of φ, resp. ¬φ, from B ∪ A_p of size ≤ d(|φ|)"); restrict it to observational φ (output ⊥ elsewhere). TF Thm 4.2(b) maps V to the certificate axioms φ ∧ θ_c (TF; or θ_c → φ, SD), where θ_c uses only =, ∀, ¬, →: observational sentences. Each is equivalent to an observational theorem of B ∪ A_p, so the set is consistent with B and proves every observational datum that p proves within d, with derivations of size ≤ d''. Lengths add constants; the maps are injective. ∎

**Example 3.6 (computed).** `checks/s2_craig_blowup.out`: a 7-sentence Horn theory with theoretical predicates E, O ("even/odd number of 1s") decides R(t_w) with |w| + 2 derivation lines and symbol size d_T ≈ |w|²/2 (376 at |w| = 24). Canonical proof search tests at least 10^{203} candidate sequences before succeeding at |w| = 24 (exact counts for |w| ≤ 4, cross-checked by brute force for |w| ≤ 2), so the Craig axiom has more than 10^{204} symbols; the certificate axiom has 795 symbols, and the Craig axiom of the fast parity labeller 702. The blow-up belongs to Craig's construction (padding by an exhaustive search's run time), not to the observational regularity.

### 3.5 The instrumentalist horn: time-bounded prediction

**Theorem 3.7 (theories against fast prediction rules).** (a) AI_O (hence AI_L) has loss at most c_τ above every clocked consistent labeller class, coin-free or one-tape (Thm 2.9(a)); (b) every computable predictor — every time-bounded "instrument", P1's M_rd and Hänni's S included — loses ≥ n − 0.361 on a computable sequence of arithmetic sentences on which AI_O loses O(1) (Thm 2.9(b), (c)), and on Presburger arithmetic every doubly-exponential-time consistent labeller class has unbounded loss while AI_O has bounded loss (Prop 2.10); (c) but unpenalised consistent SFI matches AI on all these sequences (Thm 2.9(d)), and time-bounded predictors that may be inconsistent beat AI by n − O(1) on coin literals (Thm 2.9(c)). **[proved, given TF Thm 3.1, 3.2, Prop 4.1 and Fischer–Rabin]**

So a theory with free deduction is not replaceable by any fixed-speed consistent prediction rule, but it is replaceable by a slow one (its own proof search), and that slow rule is exactly what Craig's construction axiomatises.

### 3.6 A clean statement for the paper

> **Theorem (the theoretician's dilemma in axiom induction).** Let data be observational sentences.
> (i) *In principle.* With deduction free, restricting hypotheses to observational axioms changes the prior weight of every observational content, the predictive probabilities and the cumulative log loss by at most a constant, also when the time to check or to generate axioms is penalised (Thm 3.1).
> (ii) *Craig's construction in practice.* When derivations are charged, Craig's axiomatisation of a theory whose observational consequences have derivations of size d needs derivations of size at least 2^d (Lemma 3.2), and every axiomatisation by padded observational literals fits, at polynomial budgets, exactly the polynomial-time decidable regularities (Thm 3.3); axiom sets with theoretical predicates fit all of EXPTIME when every axiom instance must be short, and every decidable regularity when only the theory's own axioms must be short (Cor 3.4).
> (iii) *Elimination in practice.* When total derivation size is charged, an observational axiomatisation that stores derivations instead of run times costs O(1) bits and a polynomial in the derivation budget (Prop 3.5).
> So the classical reply is a theorem about Craig's construction and about every run-padded axiomatisation: they are fast instrumentalist labellers in disguise. It is not a theorem about theoretical vocabulary: what cannot be eliminated at polynomial cost is the proofs, which an observational axiomatisation must then carry.

Status: (i) proved; (ii) proved (the EXPTIME clause under (F1), the separation unconditional via the time hierarchy); (iii) proved under (F1).

### 3.7 What remains open

**Question 3.8 (do theoretical predicates matter under the per-instance readings?).** In L_O = {e, s_0, s_1, R} (plus equality), what is the fit class at polynomial budgets of observational axiom sets with polynomial membership under (a1), and of finite observational theories under (a2)? If it is smaller than EXPTIME (resp. the decidable sets), theoretical predicates are provably indispensable for theories with short axioms, the formal counterpart of the Kleene / Craig–Vaught phenomenon. **[open]** *First pass.* Auxiliary information cannot be stored in R on closed terms: every closed term is some t_w, whose R-value is a datum. It must live on non-standard elements, which two unary functions can organise: an element z with s_0(z) = x, s_1(z) = y can code the pair (x, y), and R(z) a binary fact about it. Whether derivations from finitely many such axioms can be forced to link t_w to its "pair elements" without auxiliary predicates is the crux; a "Link" relation is exactly what the alternating and Horn constructions use C and pr for. **[conjecture]**: the (a2) fit class of finite observational theories in L_O is still every decidable X (via pair elements), so that predicate-free elimination is possible there too, at a linear cost in axiom size. Neither direction is proved.

**Question 3.9.** Soft charges (I22) only give a correspondence up to a constant factor in the rate; is there a soft form of Prop 3.5 with rate factor 1 between AI_L and AI_O? **[open]**

---

## 4. Candidate new results, ranked

Ranked by (interest for the paper) × (how far the proof is).

1. **AI is SFI on positive literals (Thm 2.7, Cor 2.8)** — **[proved]**. It answers the brief's "Kolmogorov / semimeasure gaps for axioms" question in one stroke (no coding theorem for axiom systems; random theories beat deterministic ones by unbounded amounts, at most K^pad), and it isolates where axiom induction differs from SFI: in logically structured data. Next step: state which of P1's results are *only* about positive literals and which have genuinely logical analogues.
2. **One-tape equivalence (Thm 2.5)** — **[proved]**. Random axiom machines ≍ M_F^cons ≍ random deciders; with padding, also under axiom-side time penalties [proof sketch]. Next step: write (S) for tape-reading machines.
3. **The dilemma theorem (§3.6)** — **[proved; parts under (F1); the (b)-separation conditional on NP ∩ coNP ≠ P]**. New ingredients: Lemma 3.2 (unary padding) and Thm 3.3 (run-padded = P); the rest assembles refereed results. Next step: Question 3.8.
4. **The independent label (Prop 2.12)** — **[proved]**. The trichotomy, taken seriously as an observable, separates theories from labellers by an unbounded amount on one datum. Next step: a computable family of witnesses, or a proof that none exists (cf. P1 `rem:versions:noncomputable`).
5. **Logical closure and the trichotomy (Prop 2.11, Rem 2.11')** — **[proved; computed]**. Small, but it fixes the meaning of "independent" across the two frameworks; AI's three-way prediction is a probability with no defect.
6. **Time-bounded transfers and Presburger (Thm 2.9, Prop 2.10)** — **[proved, given TF and Fischer–Rabin]**. The Presburger separation is natural and non-diagonal; the one-tape version is a **[conjecture]** (route in §2.5).
7. **A circuit analogue of the sandwich** — **[proof sketch]**. *Statement.* Fix d; data are the 2^d literals φ_x = R(t_x), |x| = d, labelled by f : {0,1}^d → {0,1}. Let s_N(f) be the least size of a circuit V(x, c) with f(x) = 1 iff ∃c V(x,c) = acc and f(x) = 0 iff ∃c V(x,c) = rej (never both); let a_ℓ(f) be the least size of a finite axiom set (auxiliary predicates allowed, L finite with a binary function or predicate to index gates) consistent with Γ_f from which each datum has a derivation of size ≤ ℓ. Then a_ℓ(f) = O((s_N(f) + d) log(s_N(f) + d)) for some ℓ = poly(s_N(f), d), and s_N(f) ≤ poly(a_ℓ(f), ℓ). *Sketch.* (⇐) Axioms: letter predicates ∀y B_1(s_1 y), ∀y ¬B_1(s_0 y), ∀y (B_{i+1}(s_a y) ↔ B_i(y)) (O(d) axioms), the same for a certificate term z; one biconditional per gate, G_g(x, z) ↔ op(G_a(x,z), G_b(x,z)); and ∀x∀z (Acc(x,z) → R(x)), ∀x∀z (Rej(x,z) → ¬R(x)). The intended model (term algebra, gates computed, R = f on length-d words) is consistent because V never accepts and rejects one x. A derivation instantiates z := t_c and propagates gate values: size poly(s, d, |c|). (⇒) Guess a derivation of size ≤ ℓ and check it: a circuit of size poly(a, ℓ) with O(ℓ log ℓ) guess bits (the non-uniform form of `thm:time:ntime`). *Not written out:* the checker circuit's size, and a gate-indexing scheme that keeps L finite. *Consequence (conjecture):* P1's circuit-Bayes theorem `thm:comp:circuitbayes` should transfer to an axiom-set prior with derivation budget, with nondeterministic circuit size in place of circuit size; the exception gadget becomes "replace the output axiom by its restriction to x ≠ t_a plus one literal", O(d) symbols.
8. **Theoretical predicates under the per-instance readings (Question 3.8)** — **[open; conjecture stated]**.
9. **Pathwise versus machine-wise consistency (Rem 2.14)** — **[open; bounds proved]**.
10. **Normalised convention.** Is the 2c-per-step bound of I3 attained up to constants on some sequence (a linear gap between normalised AI and normalised W_cons)? **[open]** A gap needs steps where the ⊥ mass of SFI differs from the independence mass of AI in a way that changes the ratio of the definite masses; Prop 2.11(c) shows that over closed labellers it cannot.

---

## 5. Draft table of equivalences and separations for the paper

Semimeasure convention throughout; "≍" means within a factor 2^(±c) on every data set, c a machine constant; budgets and classes as in §1.

| # | pair | relation | overhead / rate | hypotheses | status | source |
|---|---|---|---|---|---|---|
| 1 | AI (deciders) — W_cons (coin-free consistent SFI) | ≍; losses within 2c (2c per step normalised) | wrappers: proof search, Craig | B decidable, consistent | proved | AI-paper Thm 6.3; Thm 2.4 |
| 2 | K_AI — K_F^cons | equal ± c | same | same | proved | Thm 2.4 |
| 3 | AI — W_cl (closed labellers) | ≍, including the probability of "independent" | closure wrapper | same | proved | Thm 2.4(c), Prop 2.11 |
| 4 | M_AI (random axiom machines) — M_F^cons | ≍ (D ≠ ∅); tape by tape | three wrappers | same | proved | Thm 2.5 |
| 5 | W_AI — M_AI | W_AI ≤ 2^c M_AI; gap unbounded, ≤ min{K^pad(L^cons_{1/2}), K(dom D)} + c | — | same | proved | Prop 2.6, Cor 2.8(b) |
| 6 | any AI version on positive literals — P1's version on strings | ≍ / ± c | encoding wrapper | B R-free, t_w distinct in a model | proved | Thm 2.7 |
| 7 | K_AI — −log W_AI | no coding theorem: gap ≥ log d − K(⌈log(d+1)⌉) − c on two literals | — | literal data | proved | Cor 2.8(a) |
| 8 | AI — FIall (W on sentences) | FIall dominates AI; beats it by n bits on coin literals (an encoding effect, row 6) | — | — | proved | AI-paper Prop E.1; §2.4 |
| 9 | AI^chk_t, AI^gen_t (axiom-side time) — W_cons | ≍ (unpenalised!) | padding; t ≥ m^{a*} | (S) | proved | TF Thm 2.2 |
| 10 | AI^Kt_t — W_cons | ≍ to weights 2^(−\|f\|)/(\|f\|+1); factor t(m_0) | log₂(\|f\|+1) bits | (S) | proved | TF Prop 2.3 |
| 11 | AI, M_AI — W_cons^τ, M_F^{cons,τ} (clocked consistent SFI) | one-sided: regret ≤ c_τ; reverse regret ≥ n − 1.37 − c_⊥ on a computable sequence | — | L ⊇ L_A, B true in ℕ | proved | TF Thm 3.1, 3.2; Thm 2.9(a),(b) |
| 12 | AI — every computable predictor (P1's M_len, M_rd; Hänni's S; FIall^τ) | incomparable: predictor loses ≥ n − 0.361 on a computable sequence; AI loses n in expectation on coin literals | — | same | proved | TF Thm 3.2, Prop 3.4; Thm 2.9(c) |
| 13 | AI — W_cons^τ on Presburger arithmetic | AI bounded, W_cons^τ unbounded for τ ≤ 2^{2^{c'm}} | — | B = ∅ | proved, given Fischer–Rabin | Prop 2.10 |
| 14 | unpenalised W_cons — rows 11–13 | W_cons matches AI (evaluator) | constant | same | proved | TF Prop 4.1; Thm 2.9(d) |
| 15 | AI[t,d], AI^b (charged deduction) — FIcert (certificate SFI) | ≍ up to constant description length and polynomial budget changes | t⁺, βG log G; 2d'+m+31 | (F1) | proved | TF Thm 4.2; SD Thm 3.1 |
| 16 | AI^b[poly,poly] — W_cons^poly | fit class NP ∩ coNP vs P: per-sequence separation iff NP ∩ coNP ≠ P; same sequences if P = NP; non-domination with uncharged degrees | — | (F1) | proved (conditional parts) | SD Cor 3.2, Prop 3.4 |
| 17 | AI^{a1}[poly,poly] — W_cons^poly | EXPTIME vs P: unconditional separation | — | (F1) | proved | SD Cor 4.4 |
| 18 | AI^{a2}, AI^{b2} — W_cons | every decidable X fitted: no time limit | — | — | proved | SD Prop 4.12 |
| 19 | soft AI — soft FIcert | correspondence up to a constant factor in the rate; no two-sided constant regret | rate (31b_s+26) | — | proved | SD Thm 5.2, Prop 5.3 |
| 20 | AI_L — AI_O (theoretical vs observational axioms), free deduction | ≍; posterior over observational contents within 2^(2c) | Craig / padding | — | proved | Thm 3.1 |
| 21 | Craig-type (run-padded) AI_O — W_cons^poly, charged deduction | same fit class: P | — | literal data | proved | Thm 3.3 |
| 22 | AI_L[t,d] — AI_O (certificate axioms), reading (b) | AI_O ≥ 2^(−c) AI_L at polynomially larger budgets | O(1) bits; d'' = O(d log d) | (F1) | proved | Prop 3.5 |
| 23 | AI3 — FI3 (independence observed) | one-sided: AI3 ≥ 2^(−c) FI3; gap unbounded on one datum | — | B = Q | proved | Prop 2.12 |
| 24 | circuit AI (axiom size, derivation budget) — NP∩coNP-circuit SFI | polynomially related | poly | literal data, fixed d | proof sketch | §4 item 7 |

---

## 6. Checks

| script | what it checks | result |
|---|---|---|
| `checks/s1_onetape_toy.py` → `.out` (seed 20261015) | Finite propositional analogue (3 atoms, 20 sentences closed under one negation, 16 tapes, 25 random axiom machines and 25 random function machines, all 801 data sets with \|D\| ≤ 2, two backgrounds). (1) μ_G = ν^cons_{T_G}; (2) ν^cons_T ≤ μ_{G_T}; (3) mixture ratio; (4) Prop 2.11 on all (data, consequence) pairs, with the lookup table of D added; (5) closed labellers vs their axiom machines; (6) the three-outcome identity | (1) 0 violations; (2) 0 violations, strict in 12180/20025 and 10498/20025 cases (closure adds consequences); (3) M_AI/M_F^cons in [1.11, 1314] and [1.007, 7.92]; (4) AI gives (1,0,0) in 3448/3448 and 3754/3754 cases; consistent FI gives P(false) = 0 in all and P(⊥) > 0 in all, smallest 4.6·10⁻⁷; (5) 0 mismatches on 4722 pairs; (6) 0 violations |
| `checks/s2_craig_blowup.py` → `.out` (seed 20261015) | Example 3.6: the 7-sentence parity theory with theoretical predicates; canonical proof search counts (exact for \|w\| ≤ 4 by a counting depth-first search, brute-force cross-check for 7 words with \|w\| ≤ 2; lower bound Σ_{L<L*} N^L beyond); Craig, certificate and fast-labeller axiom sizes | counting search and brute force agree on all 7 words; log₁₀ of the Craig axiom from 2.73 (\|w\| = 1) to > 204.6 (\|w\| = 24); certificate axiom 36 to 795 symbols; fast-labeller Craig axiom 12 to 702 symbols; d_T from 8 to 376 |

The scripts check constructions and counting on finite analogues. The theorems are asymptotic and logical and are proved in the text.

---

## 7. References (bibliographic data checked by web search on 2026-10-15)

* W. Craig, "On axiomatizability within a system", *J. Symbolic Logic* 18 (1953) 30–32. [known; as cited in the AI-paper]
* W. Craig, "Replacement of auxiliary expressions", *Philosophical Review* 65(1) (1956) 38–55. [bibliographic data checked; reviewed in JSL 22(3) (1957) 317–318; content not checked]
* C. G. Hempel, "The theoretician's dilemma: a study in the logic of theory construction", in H. Feigl, M. Scriven, G. Maxwell (eds.), *Minnesota Studies in the Philosophy of Science* II, University of Minnesota Press, 1958, 37–98; reprinted in *Aspects of Scientific Explanation* (1965) 173–226. [bibliographic data checked; content from secondary summaries]
* H. Putnam, "Craig's theorem", *J. Philosophy* 62(10) (1965) 251–260, doi 10.2307/2023298. [bibliographic data checked; content from secondary summaries]
* I. Niiniluoto, "Inductive systematization: definition and a critical survey", *Synthese* 25 (1972) 25–81, doi 10.1007/BF00484998. [bibliographic data and abstract checked]
* S. C. Kleene, "Finite axiomatizability of theories in the predicate calculus using additional predicate symbols", in *Two Papers on the Predicate Calculus*, Memoirs of the AMS 10 (1952) 27–68 (page range 27–66 in the 1967 reprint listing). [bibliographic data checked; statement from secondary sources]
* W. Craig, R. L. Vaught, "Finite axiomatizability using additional predicates", *J. Symbolic Logic* 23(3) (1958, publ. 1959) 289–308. [bibliographic data checked; statement from secondary sources]
* C. Ryll-Nardzewski, "The role of the axiom of induction in elementary arithmetic", *Fundamenta Mathematicae* 39 (1952). [known; from a secondary source, pages not checked]
* R. Montague, ZF not finitely axiomatisable (1961). [known; from secondary sources, exact reference not checked]
* M. J. Fischer, M. O. Rabin, "Super-exponential complexity of Presburger arithmetic", *Complexity of Computation*, SIAM-AMS Proceedings VII (1974) 27–41; MIT LCS TM-43. [bibliographic data and abstract checked: nondeterministic lower bound 2^{2^{cn}} for Presburger arithmetic, 2^{cn} for real addition, and the same bounds for proof lengths in complete axiomatisations with easily recognised axioms]
* S. A. Cook, R. A. Reckhow, *J. Symbolic Logic* 44 (1979) 36–50. [known; as cited in TF]
* L. Berman, "The complexity of logical theories", *Theoretical Computer Science* 11 (1980). [cited only in a conjecture's route; not checked]
* M. Presburger (1929), completeness and decidability of Presburger arithmetic. [known; standard, not re-checked]
* Paper 1 and Paper 2 and the AI-paper with its track records, as named in the header.

---

## 8. Status of every claim

| claim | status |
|---|---|
| §1 inventory items I1–I24 | as stated there (transcribed from refereed records; not re-proved here) |
| (2.1), (2.2) decompositions | proved |
| Thm 2.4 (a)–(c); remarks (i)–(iii) | proved |
| Thm 2.5 (a)–(c) | proved; computed (s1, items 1–3) |
| one-tape penalised remark | proof sketch |
| Prop 2.6 | proved, given P1 `thm:setting:coding`(a) and `prop:versions:tape`(a)'s construction |
| Thm 2.7 | proved |
| Cor 2.8 (a)–(d) | proved, by Thm 2.7 and P1 |
| Thm 2.9 (a)–(d) | proved, given TF Thm 3.1, 3.2, Cor 3.3, Prop 4.1, P1 `prop:comp:round` |
| Prop 2.10 | proved, given Fischer–Rabin and Presburger (known) |
| Prop 2.10, charged deduction clause | known (from the abstract) |
| Prop 2.10, one tape | conjecture |
| Prop 2.11 | proved; computed (s1, items 4–5) |
| Rem 2.11' | proved; computed (s1, item 6) |
| Prop 2.12 | proved, given the recursion theorem and AI-paper Lemma E.14 |
| Rem 2.13 | proved |
| Rem 2.14 | bounds proved; boundedness open |
| Rem 2.15 | proved (incomputability: TF Cor 3.3(c)) |
| Thm 3.1 | proved, given Craig; penalised versions under (S) |
| Lemma 3.2 | proved; computed (s2) |
| Thm 3.3 | proved |
| Cor 3.4 | proved, given SD Cor 3.2, 4.4, Prop 4.12 (under (F1)) and the time hierarchy |
| Prop 3.5 | proved, given TF Thm 4.2, under (F1) |
| Ex 3.6 | computed (s2) |
| Thm 3.7 | proved, given TF and Fischer–Rabin |
| §3.6 theorem | proved, with the conditions stated there |
| Q 3.8 | open; the conjecture stated there is a conjecture |
| Q 3.9 | open |
| §4 item 7 (circuits) | proof sketch; consequence conjecture |
| §4 item 10 | open |
| historical statements of §3.1 | known, at the level of checking stated in §7 |

---

## 9. Verification log

*Reading.* Read in full: the brief; the AI-paper's `time.tex` and `app-time.tex`; model §6; TF (all sections, including the verification log and §11); SD §0, §1, §3, §4.2–4.3, §13 (other sections consulted through the paper's appendix, which transcribes them); P1's `setting.tex`, `versions.tex`, `comp.tex`, `intro.tex`, the relevant part of `app-ood.tex`; P1's `NOTATION.md`; the author's note `prior/hanni-solomonoff-axiom-induction.md`. Theorem numbers of the AI-paper were taken from `paper/main.aux`.

*Checks run.* `s1_onetape_toy.py` (about 1 minute) and `s2_craig_blowup.py` (about 2.5 minutes), outputs saved next to them.

*Self-checks that changed this file.*
1. **The lookup table was dropped in s1's first run.** In item (4) the lookup table of D was appended to the machine family but the weight list was not extended, so `zip` dropped it; P(⊥) > 0 then held in only 3063/3275 cases. Fixed by giving the lookup table weight 2^(−26); the rerun gives P(⊥) > 0 in every case, as Prop 2.11(b) predicts. The saved output is from the corrected script.
2. **s2's exact range.** A first version ran the exact counting search up to |w| = 6; valid prefixes grow too fast. Exact counts are now for |w| ≤ 4, and the rows beyond are marked as lower bounds (all shorter sequences tested first). The cross-check against brute force covers 7 words with |w| ≤ 2.
3. **Run-padded versus proposition-wise.** A first draft of Thm 3.3 was stated for every axiom set whose members are each equivalent to a literal ("proposition-wise"). That is **[refuted]**: the certificate axioms θ_c → φ are proposition-wise and fit NP ∩ coNP under reading (b) (SD Thm 3.1(iii)(b)), so they are not limited to P. The theorem is restated for run-padded sets (powers of literals), whose padding carries only O(log) bits; the counterexample is the reason for the restatement and is kept in the text as the contrast between the two rows of Cor 3.4.
4. **Hempel's horn and the background.** Thm 3.1 first assumed B observational. Checked that a theoretical B is harmless: the Craig set is contained in Cn(B ∪ A_p), so Cn(B ∪ A^C) ∩ Sent_{L_O} = T_O either way.
5. **Prop 2.12's first construction failed.** The first attempt made e halt when *any* program of length ≤ n labelled σ_e ind; short inconsistent labellers ("ind on everything") then force e to halt, and the datum's label becomes false. Fixed by searching only inside I_n, the union over the *consistent* labellers of length ≤ n, which is r.e. as a finite union and contained in Ind_Q; the price is that σ_n is not computable from n.
6. **Theorem 2.7 needs the t_w distinct.** Without a model of B in which the closed terms t_w are distinct, B can identify two words and make an R-labelling inconsistent; the hypothesis is stated.
7. **One-tape Presburger.** The density argument gives a bounded-error procedure, not a nondeterministic one, so Fischer–Rabin does not apply directly; the one-tape clause is a conjecture with the route named.

*Not done.* No referee. No proof assistant. Web pages of the cited philosophy papers and of Richard Zach's and the FOM archive's summaries could not be fetched from this environment; their content is used only as summarised by search results, and every such use is marked.
