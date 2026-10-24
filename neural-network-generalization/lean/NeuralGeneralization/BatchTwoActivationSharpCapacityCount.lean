import NeuralGeneralization.BatchTwoActivationSharpCapacity

/-! Exact cubic product-norm capacity, including the Boolean-cube Sauer
count with the manuscript's logarithmic factor. -/
noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

theorem auxiliaryPatterns_sharp_shattered_card_le {d H : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P)
    (S : Finset (Cube d)) (hS : (auxiliaryPatterns d H P).Shatters S) :
    S.card≤sharpAuxiliaryCapacity d H P := by
  let e : S≃Fin S.card := Fintype.equivFinOfCardEq (by simp)
  let x : Fin S.card→Cube d := fun i => (e.symm i).val
  have hx : Function.Injective x := by
    intro i j hij
    exact e.symm.injective (Subtype.ext hij)
  apply auxiliary_shattering_sharp_card_le hH hP x
  intro ε
  let T : Finset (Cube d) := (Finset.univ.filter (fun i => ε i=true)).image x
  have hTS : T⊆S := by
    intro y hy
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp hy
    exact (e.symm i).property
  obtain ⟨A, hA, hSA⟩ := hS hTS
  obtain ⟨f, hf, rfl⟩ := Finset.mem_image.mp hA
  obtain ⟨w, hm⟩ := (Finset.mem_filter.mp hf).2
  refine ⟨w,?_⟩
  intro i
  have he : x i∈T ↔ ε i=true := by
    simp only [T, Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨j,hj,hji⟩
      simpa [hx hji] using hj
    · intro hi
      exact ⟨i,hi,rfl⟩
  have hfε : f (x i)=ε i := by
    have hmem : x i∈S := (e.symm i).property
    have hiff : f (x i)=true ↔ ε i=true := by
      rw [← he, ← hSA]
      simp [hmem, functionPattern]
    cases ha : f (x i) <;> cases hb : ε i <;> simp_all
  have h := hm (x i)
  rw [hfε] at h
  exact h

theorem auxiliaryPatterns_sharp_vcDim_le {d H : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P) :
    (auxiliaryPatterns d H P).vcDim≤sharpAuxiliaryCapacity d H P := by
  unfold Finset.vcDim
  apply Finset.sup_le
  intro S hS
  exact auxiliaryPatterns_sharp_shattered_card_le hH hP S (Finset.mem_shatterer.mp hS)

theorem auxiliaryFunctions_sharp_card_le {d H : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P) :
    (auxiliaryFunctions d H P).card ≤ (2^d+1)^(sharpAuxiliaryCapacity d H P) := by
  have hvc := auxiliaryPatterns_sharp_vcDim_le (d := d) (H := H) hH hP
  have hc : (auxiliaryFunctions d H P).card=(auxiliaryPatterns d H P).card := by
    rw [auxiliaryPatterns, Finset.card_image_of_injective _ functionPattern_injective]
  rw [hc]
  calc
    _ ≤ (auxiliaryPatterns d H P).shatterer.card := Finset.card_le_card_shatterer _
    _ ≤ ∑ k∈Finset.Iic (auxiliaryPatterns d H P).vcDim, (Fintype.card (Cube d)).choose k :=
      Finset.card_shatterer_le_sum_vcDim
    _ ≤ ∑ k∈Finset.range (sharpAuxiliaryCapacity d H P+1), (2^d)^k := by
      calc
        _ ≤ ∑ k∈Finset.Iic (auxiliaryPatterns d H P).vcDim, (Fintype.card (Cube d))^k :=
          Finset.sum_le_sum (fun k _ => Nat.choose_le_pow _ _)
        _ ≤ _ := by
          have hcube : Fintype.card (Cube d)=2^d := by simp [Cube]
          rw [hcube]
          apply Finset.sum_le_sum_of_subset_of_nonneg
          · intro k hk
            exact Finset.mem_range.mpr (by have := Finset.mem_Iic.mp hk; omega)
          · intro k _ _
            exact Nat.zero_le _
    _ ≤ _ := sum_powers_le _ _


theorem auxiliaryFunctions_sharp_card_le_exp {d H:ℕ} {P:ℝ} (hH:0<H) (hP:0<P) :
    ((auxiliaryFunctions d H P).card:ℝ)≤
      Real.exp ((sharpAuxiliaryCapacity d H P:ℝ)*Real.log ((2:ℝ)^d+1)) := by
  have hh := auxiliaryFunctions_sharp_card_le (d:=d) hH hP
  have hh' : ((auxiliaryFunctions d H P).card:ℝ)≤((2:ℝ)^d+1)^(sharpAuxiliaryCapacity d H P) := by
    exact_mod_cast hh
  rw [Real.exp_nat_mul,Real.exp_log (by positivity)]
  exact hh'

end NeuralGeneralization.BatchTwoActivation
