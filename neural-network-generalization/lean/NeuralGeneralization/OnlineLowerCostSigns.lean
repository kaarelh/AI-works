import NeuralGeneralization.OnlineLowerGeometryAlgebra
import NeuralGeneralization.OnlineLowerCostColumns
import NeuralGeneralization.OnlineLowerReluFamily
import NeuralGeneralization.OnlineLowerBernsteinCost

noncomputable section
open MeasureTheory Set
open scoped BigOperators Classical symmDiff
namespace NeuralGeneralization.OnlineLower
open OnlineLowerGeometry OnlineLowerBernstein

theorem loopProduct_coefficient {m : ℕ} (β : Fin m → ℝ) (S : Finset (Fin m)) :
    walshCoefficients (fun s : ClippingCube m =>
      ∏ i, (1 + β i * cubeCoordinateSign (s i))) S =
        ∏ i, (if i ∈ S then β i else 1) := by
  have hchar (s : ClippingCube m) : walshCharacter S s =
      ∏ i : Fin m, if i ∈ S then cubeCoordinateSign (s i) else 1 := by
    simp [walshCharacter, Fintype.prod_ite_mem]
  unfold walshCoefficients uniformCubeMean
  simp_rw [hchar, ← Finset.prod_mul_distrib]
  rw [← Fintype.prod_sum (fun (i : Fin m) (b : Bool) =>
    (1+β i*cubeCoordinateSign b)*(if i∈S then cubeCoordinateSign b else 1))]
  have hbit (i : Fin m) :
      (∑ b : Bool, (1+β i*cubeCoordinateSign b) *
        (if i∈S then cubeCoordinateSign b else 1)) =
      2*(if i∈S then β i else 1) := by
    by_cases hi : i∈S <;> norm_num [hi,cubeCoordinateSign] <;> ring
  simp_rw [hbit]
  rw [Finset.prod_mul_distrib]
  simp only [Finset.prod_const, Finset.card_univ, Fintype.card_fin]
  have hcard : (Fintype.card (ClippingCube m) : ℝ) = 2^m := by simp [ClippingCube]
  rw [hcard]
  exact mul_div_cancel_left₀ _ (by positivity)

theorem loopProduct_coefficient_pos {m : ℕ} (β : Fin m → ℝ)
    (hβ : ∀ i, 0 < β i) (S : Finset (Fin m)) :
    0 < walshCoefficients (fun s : ClippingCube m =>
      ∏ i, (1+β i*cubeCoordinateSign (s i))) S := by
  rw [loopProduct_coefficient]
  apply Finset.prod_pos
  intro i _
  split_ifs
  · exact hβ i
  · norm_num

theorem coefficient_const_mul {m : ℕ} (F : ClippingCube m → ℝ) (c : ℝ)
    (S : Finset (Fin m)) : walshCoefficients (fun x => c*F x) S = c*walshCoefficients F S := by
  unfold walshCoefficients uniformCubeMean
  simp_rw [mul_assoc, ← Finset.mul_sum]
  ring

theorem coefficient_mul_factor {m : ℕ} (F : ClippingCube m → ℝ)
    (A S : Finset (Fin m)) (β : ℝ) :
    walshCoefficients (fun s => F s*(1+β*walshCharacter A s)) S =
      walshCoefficients F S + β*walshCoefficients F (A ∆ S) := by
  have he : (fun s => F s*(1+β*walshCharacter A s)) =
      (fun s => F s + β*(F s*walshCharacter A s)) := by funext s; ring
  rw [he, walshCoefficients_add, coefficient_const_mul,
    walshCoefficients_mul_character]

theorem factorProduct_nonnegative {m : ℕ} {ι : Type*}
    (I : Finset ι) (column : ι → Finset (Fin m)) (β : ι → ℝ)
    (hβ : ∀ i∈I, 0 ≤ β i) :
    (∀ S, 0 ≤ walshCoefficients (fun s : ClippingCube m =>
      ∏ i∈I, (1+β i*walshCharacter (column i) s)) S) ∧
    0 < walshCoefficients (fun s : ClippingCube m =>
      ∏ i∈I, (1+β i*walshCharacter (column i) s)) ∅ := by
  induction I using Finset.induction_on with
  | empty => simp [walshCoefficients_const]; intro S; split_ifs <;> norm_num
  | @insert a I ha ih =>
    have hba := hβ a (by simp)
    have hbi : ∀ i∈I, 0 ≤ β i := fun i hi => hβ i (by simp [hi])
    obtain ⟨hn,hp⟩ := ih hbi
    have he (s : ClippingCube m) :
        (∏ i∈insert a I,(1+β i*walshCharacter (column i) s)) =
          (∏ i∈I,(1+β i*walshCharacter (column i) s)) *
            (1+β a*walshCharacter (column a) s) := by rw [Finset.prod_insert ha]; ring
    simp_rw [he, coefficient_mul_factor]
    constructor
    · intro S
      exact add_nonneg (hn S) (mul_nonneg hba (hn _))
    · exact add_pos_of_pos_of_nonneg hp (mul_nonneg hba (hn _))

theorem loop_times_factorProduct_pos {m : ℕ} {ι : Type*}
    (I : Finset ι) (column : ι → Finset (Fin m)) (β : ι → ℝ)
    (hβ : ∀ i∈I, 0 ≤ β i) (loops : Fin m → ℝ)
    (hl : ∀ i, 0 < loops i) (S : Finset (Fin m)) :
    0 < walshCoefficients (fun s : ClippingCube m =>
      (∏ i, (1+loops i*cubeCoordinateSign (s i))) *
      (∏ j∈I, (1+β j*walshCharacter (column j) s))) S := by
  obtain ⟨hn,hp⟩ := factorProduct_nonnegative I column β hβ
  rw [walshCoefficients_product]
  apply Finset.sum_pos'
  · intro T _
    exact mul_nonneg (loopProduct_coefficient_pos loops hl T).le (hn _)
  · refine ⟨S, Finset.mem_univ _, ?_⟩
    simpa using mul_pos (loopProduct_coefficient_pos loops hl S) hp


theorem columnLaplaceFugacity_pos {δ t : ℝ} (hδ : 0<δ) (ht : 0<t) :
    0 < columnLaplaceFugacity δ t := by
  unfold columnLaplaceFugacity
  have he : Real.exp (-δ*t)<1 := Real.exp_lt_one_iff.mpr (by nlinarith)
  apply div_pos <;> linarith [Real.exp_pos (-δ*t)]

open OnlineLowerRelu

theorem family_factorization (k : ℕ) (t : ℝ) (s : ClippingCube (Family.logicalDim k)) :
    (∏ j : Fin (Family.pairDim k),
      (1+columnLaplaceFugacity (Family.increment k j) t*walshCharacter (Family.column k j) s)) =
    (∏ i : Fin (Family.logicalDim k), (1+columnLaplaceFugacity 4 t*cubeCoordinateSign (s i))) *
    (∏ e : Fin (2*k),
      (1+columnLaplaceFugacity (Family.increment k (Family.pairIndex k (.inr (.inr e)))) t*
        walshCharacter (Family.column k (Family.pairIndex k (.inr (.inr e)))) s)) := by
  have hp := (Family.pairIndex k).prod_comp (fun j =>
    (1+columnLaplaceFugacity (Family.increment k j) t*walshCharacter (Family.column k j) s))
  have hl := (Family.logicalIndex k).prod_comp (fun i =>
    (1+columnLaplaceFugacity 4 t*cubeCoordinateSign (s i)))
  rw [← hp, ← hl]
  simp only [Fintype.prod_sum_type, Family.increment_prefix, Family.increment_loop,
    Family.column_prefix, Family.column_loop, Nat.cast_ofNat,
    walshCharacter, Finset.prod_singleton]
  ring

theorem family_exp_coefficient_pos (k : ℕ) (n₀ t : ℝ) (ht : 0<t)
    (S : Finset (Fin (Family.logicalDim k))) :
    0 < walshCoefficients (fun s =>
      Real.exp (-columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ)) s*t)) S := by
  have he := exp_columnDegree n₀ t (Family.column k) (fun j => (Family.increment k j : ℝ))
  simp_rw [he, family_factorization]
  rw [coefficient_const_mul]
  apply mul_pos
  · exact mul_pos (Real.exp_pos _) (Finset.prod_pos fun j _ => columnLaplaceAlpha_pos _ _)
  · apply loop_times_factorProduct_pos Finset.univ
      (fun e : Fin (2*k) => Family.column k (Family.pairIndex k (.inr (.inr e))))
      (fun e => columnLaplaceFugacity (Family.increment k (Family.pairIndex k (.inr (.inr e)))) t)
    · intro e _
      apply (columnLaplaceFugacity_pos ?_ ht).le
      have hb := (Family.increment_bounds k (Family.pairIndex k (.inr (.inr e)))).1
      exact_mod_cast (show 0 < Family.increment k (Family.pairIndex k (.inr (.inr e))) by omega)
    · intro i
      exact columnLaplaceFugacity_pos (by norm_num) ht


theorem coefficient_sub {m : ℕ} (F G : ClippingCube m → ℝ) (S : Finset (Fin m)) :
    walshCoefficients (fun x => F x-G x) S = walshCoefficients F S-walshCoefficients G S := by
  simp only [walshCoefficients, uniformCubeMean, sub_mul, Finset.sum_sub_distrib, sub_div]

theorem coefficient_finset_sum {m : ℕ} {ι : Type*} (I : Finset ι)
    (F : ι → ClippingCube m → ℝ) (S : Finset (Fin m)) :
    walshCoefficients (fun x => ∑ i∈I,F i x) S = ∑ i∈I, walshCoefficients (F i) S := by
  unfold walshCoefficients uniformCubeMean
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm, Finset.sum_div]

theorem columnDegree_coefficient_nonpos {m : ℕ} {ι : Type*} [Fintype ι]
    (n₀ : ℝ) (column : ι → Finset (Fin m)) (δ : ι → ℝ)
    (hδ : ∀ i, 0 ≤ δ i) (S : Finset (Fin m)) (hS : S≠∅) :
    walshCoefficients (columnDegree n₀ column δ) S ≤ 0 := by
  unfold columnDegree
  rw [walshCoefficients_add, walshCoefficients_const, if_neg hS, zero_add,
    coefficient_finset_sum]
  apply Finset.sum_nonpos
  intro j _
  rw [coefficient_const_mul, coefficient_sub, walshCoefficients_const,
    if_neg hS, walshCoefficients_character]
  split_ifs
  · nlinarith [hδ j]
  · simp

theorem columnDegree_ge {m : ℕ} {ι : Type*} [Fintype ι]
    (n₀ : ℝ) (column : ι → Finset (Fin m)) (δ : ι → ℝ)
    (hδ : ∀ i, 0 ≤ δ i) (s : ClippingCube m) : n₀ ≤ columnDegree n₀ column δ s := by
  unfold columnDegree
  apply le_add_of_nonneg_right
  apply Finset.sum_nonneg
  intro j _
  have hc := walshCharacter_sq (column j) s
  have hc' : 0 ≤ 1-walshCharacter (column j) s := by nlinarith
  exact mul_nonneg (div_nonneg (hδ j) (by norm_num)) hc'

theorem coefficient_integrable {m : ℕ} (μ : Measure ℝ) (F : ClippingCube m → ℝ → ℝ)
    (hi : ∀ s, Integrable (F s) μ) (S : Finset (Fin m)) :
    Integrable (fun t => walshCoefficients (fun s => F s t) S) μ := by
  unfold walshCoefficients uniformCubeMean
  exact (integrable_finsetSum Finset.univ (fun s _ => (hi s).mul_const (walshCharacter S s))).div_const _

theorem coefficient_integral {m : ℕ} (μ : Measure ℝ) (F : ClippingCube m → ℝ → ℝ)
    (hi : ∀ s, Integrable (F s) μ) (S : Finset (Fin m)) :
    walshCoefficients (fun s => ∫ t,F s t ∂μ) S =
      ∫ t,walshCoefficients (fun s => F s t) S ∂μ := by
  unfold walshCoefficients uniformCubeMean
  rw [integral_div, integral_finsetSum _ (fun s _ => (hi s).mul_const (walshCharacter S s))]
  simp_rw [integral_mul_const]

theorem actual_family_cost_nonconstant_neg (k : ℕ) (n₀ : ℝ) (hn₀ : 1<n₀)
    (S : Finset (Fin (Family.logicalDim k))) (hS : S≠∅) :
    walshCoefficients (fun s => gammaCost
      (columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ)) s)) S < 0 := by
  let degree := columnDegree n₀ (Family.column k) (fun j => (Family.increment k j : ℝ))
  have hd : ∀ s, 1 < degree s := fun s => lt_of_lt_of_le hn₀
    (columnDegree_ge n₀ (Family.column k) _ (fun j => Nat.cast_nonneg _) s)
  let μ : Measure ℝ := volume.restrict (Ioi 0)
  let F : ClippingCube (Family.logicalDim k) → ℝ → ℝ :=
    fun s t => Real.exp (-degree s*t)*reluCostDensity t
  have hi : ∀ s, Integrable (F s) μ := fun s => reluCostDensity_laplaceIntegrable (hd s)
  have hid := coefficient_integrable μ F hi S
  have he (s) : gammaCost (degree s) = reluCostSlope*degree s+reluCostIntercept-∫ t,F s t ∂μ :=
    gammaCost_bernstein (hd s)
  have hrep : walshCoefficients (fun s => gammaCost (degree s)) S =
      reluCostSlope*walshCoefficients degree S -
        ∫ t, walshCoefficients (fun s => F s t) S ∂μ := by
    simp_rw [he]
    rw [coefficient_sub, walshCoefficients_add, coefficient_const_mul,
      walshCoefficients_const, if_neg hS, add_zero, coefficient_integral μ F hi S]
  have hpos : ∀ᵐ t ∂μ, (0 : ℝ) < walshCoefficients (fun s => F s t) S := by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    have hf : (fun s => F s t) =
        (fun s => reluCostDensity t*Real.exp (-degree s*t)) := by funext s; dsimp [F]; ring
    rw [hf, coefficient_const_mul]
    exact mul_pos (reluCostDensity_pos t) (family_exp_coefficient_pos k n₀ t ht S)
  have hstrict := integral_strict_mono_of_ae_lt μ (by simp [μ])
    (integrable_zero _ _ _) hid hpos
  simp only [Pi.zero_apply, integral_zero] at hstrict
  have hlin := columnDegree_coefficient_nonpos n₀ (Family.column k)
    (fun j => (Family.increment k j : ℝ)) (fun j => Nat.cast_nonneg _) S hS
  have hnon : reluCostSlope*walshCoefficients degree S ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos reluCostSlope_pos.le hlin
  change walshCoefficients (fun s => gammaCost (degree s)) S < 0
  rw [hrep]
  linarith

end NeuralGeneralization.OnlineLower


