import InfLearn.Prop.Basic

/-!
# T6 Thm 3.4: no bounded-arity family of coherence constraints suffices (Specker)

Source: `research/theory/T6-philosophical-completeness.md`, §3.2, Theorem 3.4 (verification
log entry A13: "ok, no change"), the remark after it, and the probabilistic version of
Prop 4.7 (the frustrated triangle / Specker's parable).

Fix `k` atoms `A_0, …, A_{k-1}` (the paper's `A_1..A_k`). The agenda is
`F_k = {A_i, ¬A_i} ∪ {A_i ∧ A_j, ¬(A_i ∧ A_j) : i < j}`, and the credence is
`P_k(A_i) = 1/(k-1)`, `P_k(A_i ∧ A_j) = 0`, with complements on negations.

## Worlds and probabilities

* `World k := Fin k → Bool`: the `2^k` Boolean worlds.
* `IsProb μ`: `μ : World k → ℝ` is non-negative and sums to `1` (a finite sum over the
  `Fintype` of worlds).
* `pr μ E = ∑ x, μ x · [E x]`: the probability of an event `E : World k → Bool`.

## Main results (world level, the explicit form)

* `not_matchesOn_univ` (paper (b)): for `k ≥ 2` (in particular `k ≥ 3`) there is no
  probability on worlds with `μ(A_i) = 1/(k-1)` for all `i` and `μ(A_i ∧ A_j) = 0` for all
  `i ≠ j`. Proof: on the support at most one atom is true, so `k/(k-1) = ∑ μ(A_i) ≤ 1`.
* `exists_matchesOn` (paper (a)): for every set `S` of atoms with `|S| ≤ k-1` there is a
  probability on worlds matching `P_k` on all `A_i` (`i ∈ S`) and all `A_i ∧ A_j`
  (`i ≠ j ∈ S`). The witness is the paper's: mass `1/(k-1)` on each world `e_j` (`j ∈ S`)
  making exactly `A_j` true, and the rest on the all-false world. No hypothesis on `k` is
  needed.
* `thm_3_4`: both parts together, for `k ≥ 3`.

## Formula level (the paper's literal agenda `F_k ⊆ Formula`)

* `agenda k`, `Pk k`, `prF μ φ` (the credence a world-distribution induces on formulas,
  with `A_i := var i`), `CoherentOn k F'`.
* `thm_3_4_a`: every sub-agenda `F' ⊆ F_k` whose formulas jointly mention at most `k-1`
  atoms is coherent with `P_k`, i.e. `P_k|_{F'}` extends to a coherent credence on `F_k`.
* `thm_3_4_b`: `P_k` is incoherent on `F_k` (`k ≥ 2`).
* `thm_3_4_hence`: the "Hence" clause. Every family of *necessary* coherence constraints,
  each depending only on a sub-agenda over `≤ k-1` atoms, is satisfied by `P_k`, while `P_k`
  is incoherent.

## Strengthening (the remark after the theorem)

* `Qk k`: one fixed credence on *all* formulas. `Qk_eq_Pk`: it extends `P_k` on `F_k`.
* `exists_prF_eq_Qk`: for every `S` with `|S| ≤ k-1` one probability on worlds gives
  *every* formula over the atoms of `S` exactly the value `Qk`. So the values on formulas over
  `≤ k-1` atoms do not depend on the chosen set of atoms, as the paper's remark says for
  two-atom formulas (`two_atom_coherent`, `k ≥ 3`). `Qk_incoherent`: `Qk` is nevertheless
  incoherent on `F_k`.

## Specker's parable (`k = 3`)

* `specker_parable`: the `k = 3` instance of Thm 3.4 (`P_3(A_i) = 1/2`).
* `frustrated_triangle`: the probabilistic version of Prop 4.7: pair marginals uniform on
  `{10, 01}` exist on every sub-agenda over `≤ 2` of the three atoms, but no joint
  distribution has them all.
-/

namespace InfLearn.Specker

open Finset

/-! ### Worlds, probability distributions, events -/

/-- The `2^k` Boolean worlds over the atoms `A_0, …, A_{k-1}`. -/
abbrev World (k : ℕ) := Fin k → Bool

/-- A probability distribution on the (finitely many) worlds: non-negative real weights that
sum to `1`. -/
def IsProb {k : ℕ} (μ : World k → ℝ) : Prop :=
  (∀ x, 0 ≤ μ x) ∧ ∑ x, μ x = 1

/-- The indicator `[b] ∈ {0,1}` of a Boolean. -/
def ind (b : Bool) : ℝ := if b then 1 else 0

@[simp] theorem ind_true : ind true = 1 := rfl
@[simp] theorem ind_false : ind false = 0 := rfl

theorem ind_nonneg (b : Bool) : 0 ≤ ind b := by
  cases b <;> simp

theorem ind_le_one (b : Bool) : ind b ≤ 1 := by
  cases b <;> simp

/-- The probability `μ(E) = ∑_x μ(x)·[E x]` of an event `E` (given as a Boolean test on
worlds). -/
def pr {k : ℕ} (μ : World k → ℝ) (E : World k → Bool) : ℝ :=
  ∑ x, μ x * ind (E x)

theorem pr_nonneg {k : ℕ} {μ : World k → ℝ} (hμ : ∀ x, 0 ≤ μ x) (E : World k → Bool) :
    0 ≤ pr μ E :=
  Finset.sum_nonneg fun x _ => mul_nonneg (hμ x) (ind_nonneg _)

theorem pr_true {k : ℕ} (μ : World k → ℝ) : pr μ (fun _ => true) = ∑ x, μ x := by
  simp [pr]

/-- Finite additivity: `μ(E) = μ(E ∧ F) + μ(E ∧ ¬F)`. -/
theorem pr_split {k : ℕ} (μ : World k → ℝ) (E F : World k → Bool) :
    pr μ E = pr μ (fun x => E x && F x) + pr μ (fun x => E x && !F x) := by
  unfold pr
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun x _ => ?_
  cases hE : E x <;> cases hF : F x <;> simp [hE, hF]

/-- Complement: `μ(¬E) = 1 - μ(E)` for a probability `μ`. -/
theorem pr_not {k : ℕ} {μ : World k → ℝ} (hμ : IsProb μ) (E : World k → Bool) :
    pr μ (fun x => !E x) = 1 - pr μ E := by
  have h := pr_split μ (fun _ => true) E
  rw [pr_true, hμ.2] at h
  simp only [Bool.true_and] at h
  linarith

/-! ### The credence `P_k` on the world level -/

/-- The atom credence `P_k(A_i) = 1/(k-1)`. -/
noncomputable def atomCred (k : ℕ) : ℝ := 1 / ((k : ℝ) - 1)

/-- `μ` agrees with `P_k` on the sub-agenda over the atoms in `S`: `μ(A_i) = 1/(k-1)` for
`i ∈ S`, and `μ(A_i ∧ A_j) = 0` for `i ≠ j` in `S`. (Negations then agree automatically, see
`matchesOn_neg`.) -/
def MatchesOn (k : ℕ) (S : Finset (Fin k)) (μ : World k → ℝ) : Prop :=
  (∀ i ∈ S, pr μ (fun x => x i) = atomCred k) ∧
  (∀ i ∈ S, ∀ j ∈ S, i ≠ j → pr μ (fun x => x i && x j) = 0)

/-- Negated agenda formulas get the complementary values `1 - 1/(k-1)` and `1`. -/
theorem matchesOn_neg {k : ℕ} {S : Finset (Fin k)} {μ : World k → ℝ} (hμ : IsProb μ)
    (h : MatchesOn k S μ) :
    (∀ i ∈ S, pr μ (fun x => !x i) = 1 - atomCred k) ∧
    (∀ i ∈ S, ∀ j ∈ S, i ≠ j → pr μ (fun x => !(x i && x j)) = 1) := by
  refine ⟨fun i hi => ?_, fun i hi j hj hij => ?_⟩
  · rw [pr_not hμ (fun x => x i), h.1 i hi]
  · rw [pr_not hμ (fun x => x i && x j), h.2 i hi j hj hij]; ring

/-! ### Part (b): global incoherence -/

/-- **T6 Thm 3.4(b), world form.** For `k ≥ 2` (the paper takes `k ≥ 3`) no probability
distribution on the `2^k` worlds has `μ(A_i) = 1/(k-1)` for every `i` and
`μ(A_i ∧ A_j) = 0` for every `i ≠ j`.

Proof (the paper's): the events `A_i` are pairwise `μ`-disjoint, so at most one atom is true
on the support of `μ`, hence `k/(k-1) = ∑_i μ(A_i) ≤ 1`, a contradiction. -/
theorem not_matchesOn_univ {k : ℕ} (hk : 2 ≤ k) :
    ¬ ∃ μ : World k → ℝ, IsProb μ ∧ MatchesOn k univ μ := by
  rintro ⟨μ, ⟨hnn, hsum⟩, hA, hAA⟩
  -- pointwise: `μ(x) · #{i | x i} ≤ μ(x)`
  have hpt : ∀ x, μ x * ∑ i, ind (x i) ≤ μ x := by
    intro x
    rcases (hnn x).lt_or_eq with hpos | hzero
    · -- on the support, no two atoms are true together
      have hdisj : ∀ i j, i ≠ j → ¬ (x i = true ∧ x j = true) := by
        rintro i j hij ⟨hi, hj⟩
        have h0 := hAA i (mem_univ _) j (mem_univ _) hij
        unfold pr at h0
        have hterm : μ x * ind (x i && x j) = 0 :=
          (Finset.sum_eq_zero_iff_of_nonneg
            (fun y _ => mul_nonneg (hnn y) (ind_nonneg _))).1 h0 x (mem_univ x)
        simp only [hi, hj, Bool.and_self, ind_true, mul_one] at hterm
        linarith
      have hcount : ∑ i, ind (x i) = ((univ.filter fun i => x i = true).card : ℝ) := by
        rw [← Finset.sum_boole]
        rfl
      have hle : ∑ i, ind (x i) ≤ 1 := by
        rw [hcount]
        have : (univ.filter fun i => x i = true).card ≤ 1 :=
          Finset.card_le_one.2 fun a ha b hb => by
            by_contra hab
            exact hdisj a b hab ⟨(mem_filter.1 ha).2, (mem_filter.1 hb).2⟩
        exact_mod_cast this
      nlinarith
    · rw [← hzero]; simp
  have hsumA : ∑ i : Fin k, pr μ (fun x => x i) = k * atomCred k := by
    rw [Finset.sum_congr rfl fun i _ => hA i (mem_univ i)]
    simp
  have hswap : ∑ i : Fin k, pr μ (fun x => x i) = ∑ x, μ x * ∑ i, ind (x i) := by
    unfold pr
    rw [Finset.sum_comm]
    simp [Finset.mul_sum]
  have hle : (k : ℝ) * atomCred k ≤ 1 := by
    rw [← hsumA, hswap, ← hsum]
    exact Finset.sum_le_sum fun x _ => hpt x
  have hk' : (2 : ℝ) ≤ k := by exact_mod_cast hk
  unfold atomCred at hle
  rw [mul_one_div, div_le_one (by linarith)] at hle
  linarith

/-! ### Part (a): coherence on every sub-agenda over `≤ k-1` atoms -/

/-- The world `e_j` in which exactly `A_j` is true. -/
def single {k : ℕ} (j : Fin k) : World k := fun i => decide (i = j)

/-- The all-false world. -/
def allFalse {k : ℕ} : World k := fun _ => false

/-- The paper's witness: mass `c` on each `e_j` (`j ∈ S`) and the remaining mass
`1 - |S|·c` on the all-false world. -/
noncomputable def mixDist {k : ℕ} (S : Finset (Fin k)) (c : ℝ) : World k → ℝ :=
  fun x => (1 - (S.card : ℝ) * c) * ind (decide (x = allFalse)) +
    ∑ j ∈ S, c * ind (decide (x = single j))

/-- A point mass integrates to the value at the point. -/
theorem sum_point {k : ℕ} (a : ℝ) (y : World k) (E : World k → Bool) :
    ∑ x, a * ind (decide (x = y)) * ind (E x) = a * ind (E y) := by
  rw [Finset.sum_eq_single y (fun x _ hx => by simp [hx]) (by simp)]
  simp

/-- Probabilities under the witness: `μ(E) = (1 - |S|c)·[E(0)] + ∑_{j∈S} c·[E(e_j)]`. -/
theorem pr_mixDist {k : ℕ} (S : Finset (Fin k)) (c : ℝ) (E : World k → Bool) :
    pr (mixDist S c) E =
      (1 - (S.card : ℝ) * c) * ind (E allFalse) + ∑ j ∈ S, c * ind (E (single j)) := by
  unfold pr mixDist
  simp only [add_mul, Finset.sum_add_distrib, Finset.sum_mul]
  congr 1
  · exact sum_point _ _ _
  · rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun j _ => sum_point _ _ _

theorem isProb_mixDist {k : ℕ} (S : Finset (Fin k)) (c : ℝ) (hc : ∀ j ∈ S, 0 ≤ c)
    (hSc : (S.card : ℝ) * c ≤ 1) : IsProb (mixDist S c) := by
  refine ⟨fun x => ?_, ?_⟩
  · unfold mixDist
    exact add_nonneg (mul_nonneg (by linarith) (ind_nonneg _))
      (Finset.sum_nonneg fun j hj => mul_nonneg (hc j hj) (ind_nonneg _))
  · rw [← pr_true, pr_mixDist]
    simp

/-- The witness with `c = 1/(k-1)` is a probability distribution as soon as
`|S| ≤ k - 1`. -/
theorem isProb_mixDist_atomCred {k : ℕ} (S : Finset (Fin k)) (hS : S.card ≤ k - 1) :
    IsProb (mixDist S (atomCred k)) := by
  rcases Nat.lt_or_ge k 2 with hk | hk
  · -- `k ≤ 1`: then `S = ∅`
    have hS0 : S.card = 0 := by omega
    refine isProb_mixDist S _ (fun j hj => ?_) (by simp [hS0])
    rw [Finset.card_eq_zero] at hS0
    simp [hS0] at hj
  · have hk' : (2 : ℝ) ≤ k := by exact_mod_cast hk
    have hpos : (0 : ℝ) < (k : ℝ) - 1 := by linarith
    refine isProb_mixDist S _ (fun _ _ => by unfold atomCred; positivity) ?_
    have hS' : (S.card : ℝ) ≤ (k : ℝ) - 1 := by
      have : S.card + 1 ≤ k := by omega
      have : ((S.card : ℕ) : ℝ) + 1 ≤ k := by exact_mod_cast this
      linarith
    unfold atomCred
    rw [mul_one_div, div_le_one hpos]
    exact hS'

theorem pr_mixDist_atom {k : ℕ} (S : Finset (Fin k)) (c : ℝ) {i : Fin k} (hi : i ∈ S) :
    pr (mixDist S c) (fun x => x i) = c := by
  rw [pr_mixDist]
  simp [allFalse, single, ind, hi]

theorem pr_mixDist_and {k : ℕ} (S : Finset (Fin k)) (c : ℝ) {i j : Fin k} (hij : i ≠ j) :
    pr (mixDist S c) (fun x => x i && x j) = 0 := by
  rw [pr_mixDist, Finset.sum_eq_zero fun l _ => ?_]
  · simp [allFalse]
  · by_cases hil : i = l
    · subst hil; simp [single, Ne.symm hij]
    · simp [single, hil]

/-- **T6 Thm 3.4(a), world form.** For every set `S` of atoms with `|S| ≤ k - 1` there is a
probability distribution on the worlds `Fin k → Bool` matching `P_k` on every `A_i` and every
`A_i ∧ A_j` with `i, j ∈ S`. (No lower bound on `k` is needed.) -/
theorem exists_matchesOn {k : ℕ} (S : Finset (Fin k)) (hS : S.card ≤ k - 1) :
    ∃ μ : World k → ℝ, IsProb μ ∧ MatchesOn k S μ :=
  ⟨mixDist S (atomCred k), isProb_mixDist_atomCred S hS,
    fun _ hi => pr_mixDist_atom S _ hi, fun _ _ _ _ hij => pr_mixDist_and S _ hij⟩

/-- **T6 Thm 3.4 (explicit form).** For `k ≥ 3`, `P_k` is (a) coherent on every sub-agenda
mentioning at most `k - 1` of the atoms, and (b) globally incoherent. -/
theorem thm_3_4 {k : ℕ} (hk : 3 ≤ k) :
    (∀ S : Finset (Fin k), S.card ≤ k - 1 → ∃ μ : World k → ℝ, IsProb μ ∧ MatchesOn k S μ) ∧
    ¬ ∃ μ : World k → ℝ, IsProb μ ∧ MatchesOn k univ μ :=
  ⟨exists_matchesOn, not_matchesOn_univ (by omega)⟩

/-! ### The formula-level statement over the paper's agenda `F_k` -/

/-- Embed a world into a valuation of all atoms `p₀, p₁, …` (atoms `pₙ`, `n ≥ k`, false). -/
def toVal {k : ℕ} (x : World k) : Valuation := fun n => if h : n < k then x ⟨n, h⟩ else false

@[simp] theorem toVal_fin {k : ℕ} (x : World k) (i : Fin k) : toVal x i = x i := by
  simp [toVal, i.isLt]

theorem toVal_allFalse {k : ℕ} : toVal (allFalse : World k) = fun _ => false := by
  funext n; simp [toVal, allFalse]

theorem toVal_single {k : ℕ} (j : Fin k) : toVal (single j) = fun n => decide (n = j.val) := by
  funext n
  unfold toVal single
  by_cases h : n < k
  · simp only [h, dite_true]
    simp [Fin.ext_iff]
  · simp only [h, dite_false]
    have : n ≠ j.val := fun e => h (e ▸ j.isLt)
    simp [this]

/-- The credence that a world distribution induces on formulas (`A_i := pᵢ`). -/
def prF {k : ℕ} (μ : World k → ℝ) (φ : Formula) : ℝ :=
  pr μ (fun x => φ.eval (toVal x))

/-- The agenda `F_k = {A_i, ¬A_i : i < k} ∪ {A_i ∧ A_j, ¬(A_i ∧ A_j) : i < j < k}`. -/
def agenda (k : ℕ) : Set Formula :=
  {φ | ∃ i : Fin k, φ = .var i ∨ φ = .neg (.var i)} ∪
  {φ | ∃ i j : Fin k, i < j ∧
      (φ = .and (.var i) (.var j) ∨ φ = .neg (.and (.var i) (.var j)))}

/-- The credence `P_k`: `1/(k-1)` on atoms, `0` on conjunctions of two atoms, complements on
their negations. (Values off the agenda `F_k` are irrelevant and set to `0`.) -/
noncomputable def Pk (k : ℕ) : Formula → ℝ
  | .var _ => atomCred k
  | .neg (.var _) => 1 - atomCred k
  | .and (.var _) (.var _) => 0
  | .neg (.and (.var _) (.var _)) => 1
  | _ => 0

/-- A partial credence `P` is coherent on the sub-agenda `F'` iff some probability on worlds
induces exactly the values of `P` on `F'` (de Finetti coherence; this is what "`P|_{F'}`
extends to a coherent credence on `F_k`" means). -/
def CoherentOn (k : ℕ) (P : Formula → ℝ) (F' : Set Formula) : Prop :=
  ∃ μ : World k → ℝ, IsProb μ ∧ ∀ φ ∈ F', prF μ φ = P φ

/-- Agenda formulas only mention atoms below `k`. -/
theorem atoms_lt_of_mem_agenda {k : ℕ} {φ : Formula} (hφ : φ ∈ agenda k) :
    ∀ n ∈ φ.atoms, n < k := by
  rcases hφ with ⟨i, rfl | rfl⟩ | ⟨i, j, -, rfl | rfl⟩ <;>
    simp [Formula.atoms]

/-- If `μ` matches `P_k` (world form) on `S`, it matches `P_k` on every agenda formula over
the atoms of `S`. -/
theorem prF_eq_Pk_of_matchesOn {k : ℕ} {S : Finset (Fin k)} {μ : World k → ℝ}
    (hμ : IsProb μ) (h : MatchesOn k S μ) {φ : Formula} (hφ : φ ∈ agenda k)
    (hS : ∀ i : Fin k, i.val ∈ φ.atoms → i ∈ S) : prF μ φ = Pk k φ := by
  have hn := matchesOn_neg hμ h
  rcases hφ with ⟨i, rfl | rfl⟩ | ⟨i, j, hij, rfl | rfl⟩
  · have hi : i ∈ S := hS i (by simp [Formula.atoms])
    simpa [prF, Pk] using h.1 i hi
  · have hi : i ∈ S := hS i (by simp [Formula.atoms])
    simpa [prF, Pk] using hn.1 i hi
  · have hi : i ∈ S := hS i (by simp [Formula.atoms])
    have hj : j ∈ S := hS j (by simp [Formula.atoms])
    simpa [prF, Pk] using h.2 i hi j hj (ne_of_lt hij)
  · have hi : i ∈ S := hS i (by simp [Formula.atoms])
    have hj : j ∈ S := hS j (by simp [Formula.atoms])
    simpa [prF, Pk] using hn.2 i hi j hj (ne_of_lt hij)

/-- **T6 Thm 3.4(a), formula form.** Let `F' ⊆ F_k` be a sub-agenda whose formulas jointly
mention at most `k - 1` atoms (all their atoms lie in a set `J` with `|J| ≤ k - 1`). Then
`P_k|_{F'}` extends to a coherent credence: some probability on worlds induces exactly
`P_k` on `F'`. -/
theorem thm_3_4_a {k : ℕ} (F' : Set Formula) (hF' : F' ⊆ agenda k) (J : Finset ℕ)
    (hJ : J.card ≤ k - 1) (hatoms : ∀ φ ∈ F', φ.atoms ⊆ J) : CoherentOn k (Pk k) F' := by
  classical
  let S : Finset (Fin k) := univ.filter fun i => i.val ∈ J
  have hSJ : S.card ≤ J.card :=
    Finset.card_le_card_of_injOn Fin.val (fun i hi => (mem_filter.1 hi).2)
      (fun a _ b _ e => Fin.ext e)
  obtain ⟨μ, hμ, hm⟩ := exists_matchesOn S (le_trans hSJ hJ)
  refine ⟨μ, hμ, fun φ hφ => prF_eq_Pk_of_matchesOn hμ hm (hF' hφ) fun i hi => ?_⟩
  exact mem_filter.2 ⟨mem_univ _, hatoms φ hφ hi⟩

/-- **T6 Thm 3.4(b), formula form.** `P_k` is incoherent on `F_k` (for `k ≥ 2`, in
particular for `k ≥ 3`). -/
theorem thm_3_4_b {k : ℕ} (hk : 2 ≤ k) : ¬ CoherentOn k (Pk k) (agenda k) := by
  rintro ⟨μ, hμ, h⟩
  refine not_matchesOn_univ hk ⟨μ, hμ, fun i _ => ?_, fun i _ j _ hij => ?_⟩
  · have := h (.var i) (Or.inl ⟨i, Or.inl rfl⟩)
    simpa [prF, Pk] using this
  · rcases lt_or_gt_of_ne hij with hlt | hlt
    · have := h (.and (.var i) (.var j)) (Or.inr ⟨i, j, hlt, Or.inl rfl⟩)
      simpa [prF, Pk] using this
    · have := h (.and (.var j) (.var i)) (Or.inr ⟨j, i, hlt, Or.inl rfl⟩)
      simp only [prF, Pk, Formula.eval_and, Formula.eval_var, toVal_fin] at this
      rw [← this]
      unfold pr
      refine Finset.sum_congr rfl fun x _ => ?_
      simp only [Bool.and_comm]

/-- A predicate on credences *depends only on* the sub-agenda `F'`. -/
def DependsOnlyOn (C : (Formula → ℝ) → Prop) (F' : Set Formula) : Prop :=
  ∀ P P' : Formula → ℝ, (∀ φ ∈ F', P φ = P' φ) → (C P ↔ C P')

/-- **T6 Thm 3.4, "Hence" clause.** Let `𝒞` be any family of *necessary* coherence
constraints (every credence induced by a probability on worlds satisfies each of them), each
of which depends only on a sub-agenda `F' ⊆ F_k` mentioning at most `k - 1` atoms. Then `P_k`
satisfies every constraint in `𝒞`, although `P_k` is incoherent on `F_k`. So no such family
characterizes coherence. -/
theorem thm_3_4_hence {k : ℕ} (hk : 3 ≤ k) (𝒞 : Set ((Formula → ℝ) → Prop))
    (hloc : ∀ C ∈ 𝒞, ∃ F' ⊆ agenda k, ∃ J : Finset ℕ, J.card ≤ k - 1 ∧
      (∀ φ ∈ F', φ.atoms ⊆ J) ∧ DependsOnlyOn C F')
    (hnec : ∀ C ∈ 𝒞, ∀ μ : World k → ℝ, IsProb μ → C (prF μ)) :
    (∀ C ∈ 𝒞, C (Pk k)) ∧ ¬ CoherentOn k (Pk k) (agenda k) := by
  refine ⟨fun C hC => ?_, thm_3_4_b (by omega)⟩
  obtain ⟨F', hF', J, hJ, hat, hdep⟩ := hloc C hC
  obtain ⟨μ, hμ, hagree⟩ := thm_3_4_a F' hF' J hJ hat
  exact (hdep (prF μ) (Pk k) hagree).1 (hnec C hC μ hμ)

/-! ### Strengthening: one credence on all formulas over `≤ k-1` atoms -/

/-- A single credence on *all* formulas: with `c = 1/(k-1)` and `A(φ)` the atoms of `φ`,
`Q_k(φ) = (1 - |A(φ)|·c)·[φ(0)] + ∑_{a ∈ A(φ)} c·[φ(e_a)]`, where `0` is the all-false
valuation and `e_a` makes exactly `p_a` true. -/
noncomputable def Qk (k : ℕ) (φ : Formula) : ℝ :=
  (1 - (φ.atoms.card : ℝ) * atomCred k) * ind (φ.eval fun _ => false) +
    ∑ a ∈ φ.atoms, atomCred k * ind (φ.eval fun n => decide (n = a))

/-- `Q_k` extends `P_k` on the agenda `F_k`. -/
theorem Qk_eq_Pk {k : ℕ} {φ : Formula} (hφ : φ ∈ agenda k) : Qk k φ = Pk k φ := by
  rcases hφ with ⟨i, rfl | rfl⟩ | ⟨i, j, hij, rfl | rfl⟩
  · simp [Qk, Pk, Formula.atoms]
  · simp [Qk, Pk, Formula.atoms]
  · have hne : (i : ℕ) ≠ j := Fin.val_ne_of_ne (ne_of_lt hij)
    have hne' : (j : ℕ) ≠ i := hne.symm
    simp [Qk, Pk, Formula.atoms, Finset.sum_pair hne, hne, hne']
  · have hne : (i : ℕ) ≠ j := Fin.val_ne_of_ne (ne_of_lt hij)
    have hne' : (j : ℕ) ≠ i := hne.symm
    simp [Qk, Pk, Formula.atoms, Finset.sum_pair hne, hne, hne', Finset.card_pair hne]
    ring

/-- **Strengthened Thm 3.4(a)** (the remark after the theorem, for all formulas over `≤ k-1`
atoms rather than only two). For every set `S` of atoms with `|S| ≤ k - 1` there is one
probability on worlds that gives *every* formula whose atoms lie in `S` exactly the value
`Q_k(φ)`. In particular these values do not depend on `S`. -/
theorem exists_prF_eq_Qk {k : ℕ} (S : Finset (Fin k)) (hS : S.card ≤ k - 1) :
    ∃ μ : World k → ℝ, IsProb μ ∧
      ∀ φ : Formula, φ.atoms ⊆ S.map Fin.valEmbedding → prF μ φ = Qk k φ := by
  classical
  refine ⟨mixDist S (atomCred k), isProb_mixDist_atomCred S hS, fun φ hφ => ?_⟩
  set c := atomCred k
  set J := S.map Fin.valEmbedding
  set f : ℕ → ℝ := fun a => c * ind (φ.eval fun n => decide (n = a))
  set b := ind (φ.eval fun _ => false)
  -- the witness, rewritten as a sum over `J ⊆ ℕ`
  have h1 : prF (mixDist S c) φ = (1 - (J.card : ℝ) * c) * b + ∑ a ∈ J, f a := by
    unfold prF
    rw [pr_mixDist, toVal_allFalse, Finset.sum_map, Finset.card_map]
    simp only [toVal_single, f, b]
    rfl
  -- atoms of `J` outside `φ` do not affect `φ`
  have h2 : ∀ a ∈ J \ φ.atoms, f a = c * b := by
    intro a ha
    have ha' : a ∉ φ.atoms := (mem_sdiff.1 ha).2
    have : (φ.eval fun n => decide (n = a)) = φ.eval fun _ => false :=
      Formula.eval_congr fun n hn => by
        have : n ≠ a := fun e => ha' (e ▸ hn)
        simp [this]
    simp only [f, b, this]
  have h3 : ∑ a ∈ J, f a = ((J.card : ℝ) - φ.atoms.card) * c * b + ∑ a ∈ φ.atoms, f a := by
    rw [← Finset.sum_sdiff hφ, Finset.sum_congr rfl h2, Finset.sum_const, nsmul_eq_mul]
    have := Finset.card_sdiff_add_card_eq_card hφ
    have : ((J \ φ.atoms).card : ℝ) = J.card - φ.atoms.card := by
      rw [← this]; push_cast; ring
    rw [this]; ring
  rw [h1, h3]
  unfold Qk
  simp only [f, b]
  ring

/-- `Q_k` is still globally incoherent on `F_k` (it agrees with `P_k` there), although by
`exists_prF_eq_Qk` it is coherent on all formulas over any `k - 1` atoms. -/
theorem Qk_incoherent {k : ℕ} (hk : 2 ≤ k) : ¬ CoherentOn k (Qk k) (agenda k) := by
  rintro ⟨μ, hμ, h⟩
  exact thm_3_4_b hk ⟨μ, hμ, fun φ hφ => (h φ hφ).trans (Qk_eq_Pk hφ)⟩

/-- **The remark after Thm 3.4** (`P_k` is "pairwise coherent in the strongest sense"). For
`k ≥ 3`, every formula in at most two atoms gets one value `Q_k(φ)` (extending `P_k`), and
for every pair of atoms one probability on worlds realizes all of these values on all
formulas over that pair at once. -/
theorem two_atom_coherent {k : ℕ} (hk : 3 ≤ k) (i j : Fin k) :
    ∃ μ : World k → ℝ, IsProb μ ∧
      ∀ φ : Formula, φ.atoms ⊆ {i.val, j.val} → prF μ φ = Qk k φ := by
  classical
  have hcard : ({i, j} : Finset (Fin k)).card ≤ k - 1 :=
    le_trans (Finset.card_le_two) (by omega)
  obtain ⟨μ, hμ, h⟩ := exists_prF_eq_Qk ({i, j} : Finset (Fin k)) hcard
  refine ⟨μ, hμ, fun φ hφ => h φ (fun n hn => ?_)⟩
  rcases Finset.mem_insert.1 (hφ hn) with rfl | hn'
  · simp
  · rw [Finset.mem_singleton] at hn'
    subst hn'
    simp

/-! ### Specker's parable (`k = 3`) -/

theorem atomCred_three : atomCred 3 = 1 / 2 := by
  unfold atomCred; norm_num

/-- **Specker's parable, `k = 3` instance of Thm 3.4.** For three atoms with
`P(A_i) = 1/2` and `P(A_i ∧ A_j) = 0`: (a) on every sub-agenda over at most two of the atoms
there is a matching probability on the 8 worlds, but (b) there is none globally. -/
theorem specker_parable :
    (∀ S : Finset (Fin 3), S.card ≤ 2 → ∃ μ : World 3 → ℝ, IsProb μ ∧
      (∀ i ∈ S, pr μ (fun x => x i) = 1 / 2) ∧
      (∀ i ∈ S, ∀ j ∈ S, i ≠ j → pr μ (fun x => x i && x j) = 0)) ∧
    ¬ ∃ μ : World 3 → ℝ, IsProb μ ∧
      (∀ i, pr μ (fun x => x i) = 1 / 2) ∧
      (∀ i j, i ≠ j → pr μ (fun x => x i && x j) = 0) := by
  obtain ⟨ha, hb⟩ := thm_3_4 (k := 3) le_rfl
  refine ⟨fun S hS => ?_, fun ⟨μ, hμ, h1, h2⟩ => hb ⟨μ, hμ, ?_, ?_⟩⟩
  · obtain ⟨μ, hμ, h1, h2⟩ := ha S hS
    exact ⟨μ, hμ, fun i hi => atomCred_three ▸ h1 i hi, h2⟩
  · exact fun i _ => atomCred_three ▸ h1 i
  · exact fun i _ j _ hij => h2 i j hij

/-- **The frustrated triangle (T6 Prop 4.7, probabilistic version; Specker's parable).** Ask
that for each pair of the three atoms the joint law of `(A_i, A_j)` be uniform on
`{10, 01}` ("of any two boxes, exactly one holds the gem"). (a) On every sub-agenda over at
most two atoms this is realized by a probability on the 8 worlds; (b) no single probability
on worlds realizes it for all pairs. -/
theorem frustrated_triangle :
    (∀ S : Finset (Fin 3), S.card ≤ 2 → ∃ μ : World 3 → ℝ, IsProb μ ∧
      ∀ i ∈ S, ∀ j ∈ S, i ≠ j →
        pr μ (fun x => x i && !x j) = 1 / 2 ∧ pr μ (fun x => !x i && x j) = 1 / 2 ∧
        pr μ (fun x => x i && x j) = 0 ∧ pr μ (fun x => !x i && !x j) = 0) ∧
    ¬ ∃ μ : World 3 → ℝ, IsProb μ ∧
      ∀ i j : Fin 3, i ≠ j →
        pr μ (fun x => x i && !x j) = 1 / 2 ∧ pr μ (fun x => !x i && x j) = 1 / 2 := by
  refine ⟨fun S hS => ?_, ?_⟩
  · refine ⟨mixDist S (1 / 2), atomCred_three ▸ isProb_mixDist_atomCred S hS, ?_⟩
    intro i hi j hj hij
    -- `S = {i, j}`, since it contains the distinct `i, j` and has at most two elements
    have hsub : ({i, j} : Finset (Fin 3)) ⊆ S := by
      intro x hx
      rcases Finset.mem_insert.1 hx with rfl | hx
      · exact hi
      · rw [Finset.mem_singleton] at hx; exact hx ▸ hj
    have hSeq : S = {i, j} :=
      (Finset.eq_of_subset_of_card_le hsub (by rw [Finset.card_pair hij]; exact hS)).symm
    subst hSeq
    -- the witness is `½ δ_{e_i} + ½ δ_{e_j}` (no mass on the all-false world)
    have hval : ∀ E : World 3 → Bool, pr (mixDist {i, j} (1 / 2)) E =
        ind (E allFalse) * 0 + 1 / 2 * ind (E (single i)) + 1 / 2 * ind (E (single j)) := by
      intro E
      rw [pr_mixDist, Finset.sum_pair hij, Finset.card_pair hij]
      push_cast; ring
    refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [hval] <;> simp [single, hij, Ne.symm hij]
  · rintro ⟨μ, hμ, h⟩
    refine (thm_3_4 (k := 3) le_rfl).2 ⟨μ, hμ, fun i _ => ?_, fun i _ j _ hij => ?_⟩
    · -- `μ(A_i) = μ(A_i ∧ A_j) + μ(A_i ∧ ¬A_j)` for some `j ≠ i`
      obtain ⟨j, hij⟩ : ∃ j : Fin 3, i ≠ j := ⟨i + 1, by fin_cases i <;> decide⟩
      have hs := pr_split μ (fun x => x i) (fun x => x j)
      have hn := pr_split μ (fun x => !x i) (fun x => x j)
      have hc := pr_not hμ (fun x => x i)
      obtain ⟨h10, h01⟩ := h i j hij
      have hnn1 := pr_nonneg hμ.1 (fun x => x i && x j)
      have hnn2 := pr_nonneg hμ.1 (fun x => !x i && !x j)
      rw [atomCred_three]
      linarith
    · have hs := pr_split μ (fun x => x i) (fun x => x j)
      have hn := pr_split μ (fun x => !x i) (fun x => x j)
      have hc := pr_not hμ (fun x => x i)
      obtain ⟨h10, h01⟩ := h i j hij
      have hnn1 := pr_nonneg hμ.1 (fun x => x i && x j)
      have hnn2 := pr_nonneg hμ.1 (fun x => !x i && !x j)
      linarith

end InfLearn.Specker

/-! ### Axiom audit -/

#print axioms InfLearn.Specker.not_matchesOn_univ
#print axioms InfLearn.Specker.exists_matchesOn
#print axioms InfLearn.Specker.thm_3_4
#print axioms InfLearn.Specker.thm_3_4_a
#print axioms InfLearn.Specker.thm_3_4_b
#print axioms InfLearn.Specker.thm_3_4_hence
#print axioms InfLearn.Specker.Qk_eq_Pk
#print axioms InfLearn.Specker.exists_prF_eq_Qk
#print axioms InfLearn.Specker.Qk_incoherent
#print axioms InfLearn.Specker.two_atom_coherent
#print axioms InfLearn.Specker.specker_parable
#print axioms InfLearn.Specker.frustrated_triangle
