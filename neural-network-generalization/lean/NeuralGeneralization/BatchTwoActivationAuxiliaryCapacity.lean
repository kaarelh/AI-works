import NeuralGeneralization.BatchTwoActivationAuxiliaryNetwork

/-!
# Counting all heterogeneous auxiliary sign functions

The finite class includes every width and every neuron-specific globally
1-Lipschitz zero-at-zero activation. Its logarithmic cardinality is bounded by
an explicit polynomial of depth, input dimension, and output scale.
-/
noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

def auxiliaryCapacity (d H : ℕ) (P : ℝ) : ℕ :=
  let p := (d:ℝ)+1
  ⌈16*P^2*p*capacityEntropy H (capacityResolution H p P) p⌉₊

theorem auxiliary_shattering_card_le {d H n : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P)
    (x : Fin n→Cube d)
    (hshatter : ∀ε : Fin n→Bool, ∃W : AuxiliaryNetwork d H,
      ∀i, (1/2:ℝ)≤cubeCoordinateSign (ε i)*auxiliaryOutput W P (x i)) :
    n≤auxiliaryCapacity d H P := by
  have hp : (0:ℝ)<(d:ℝ)+1 := by positivity
  have hq := capacityResolution_pos hH hp hP
  have hm := auxiliary_shattering_mgf hP x hshatter hq
    (1/(4*P*((d:ℝ)+1))) (by positivity)
  have hb := capacity_from_moment hH hp hP hm
  unfold auxiliaryCapacity
  exact_mod_cast hb.trans (Nat.le_ceil _)

def auxiliaryFunctions (d H : ℕ) (P : ℝ) : Finset (BooleanFunction d) :=
  Finset.univ.filter (fun f => ∃W : AuxiliaryNetwork d H,
    ∀x, (1/2:ℝ)≤labelReal (f x)*auxiliaryOutput W P x)

def auxiliaryPatterns (d H : ℕ) (P : ℝ) : Finset (Finset (Cube d)) :=
  (auxiliaryFunctions d H P).image functionPattern

theorem auxiliaryPatterns_shattered_card_le {d H : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P)
    (S : Finset (Cube d)) (hS : (auxiliaryPatterns d H P).Shatters S) :
    S.card≤auxiliaryCapacity d H P := by
  let e : S≃Fin S.card := Fintype.equivFinOfCardEq (by simp)
  let x : Fin S.card→Cube d := fun i => (e.symm i).val
  have hx : Function.Injective x := by
    intro i j hij
    exact e.symm.injective (Subtype.ext hij)
  apply auxiliary_shattering_card_le hH hP x
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

theorem auxiliaryPatterns_vcDim_le {d H : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P) :
    (auxiliaryPatterns d H P).vcDim≤auxiliaryCapacity d H P := by
  unfold Finset.vcDim
  apply Finset.sup_le
  intro S hS
  exact auxiliaryPatterns_shattered_card_le hH hP S (Finset.mem_shatterer.mp hS)

theorem auxiliaryFunctions_card_le {d H : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P) :
    (auxiliaryFunctions d H P).card ≤ (2^d+1)^(auxiliaryCapacity d H P) := by
  have hvc := auxiliaryPatterns_vcDim_le (d := d) (H := H) hH hP
  have hc : (auxiliaryFunctions d H P).card=(auxiliaryPatterns d H P).card := by
    rw [auxiliaryPatterns, Finset.card_image_of_injective _ functionPattern_injective]
  rw [hc]
  calc
    _ ≤ (auxiliaryPatterns d H P).shatterer.card := Finset.card_le_card_shatterer _
    _ ≤ ∑ k∈Finset.Iic (auxiliaryPatterns d H P).vcDim, (Fintype.card (Cube d)).choose k :=
      Finset.card_shatterer_le_sum_vcDim
    _ ≤ ∑ k∈Finset.range (auxiliaryCapacity d H P+1), (2^d)^k := by
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

theorem auxiliaryCapacity_le_polynomial (d H : ℕ) {P : ℝ} (hP : 0≤P) :
    (auxiliaryCapacity d H P : ℝ)≤capacityPolynomial H ((d:ℝ)+1) P := by
  have hp : (0:ℝ)≤(d:ℝ)+1 := by positivity
  have hc : (auxiliaryCapacity d H P : ℝ)≤
      16*P^2*((d:ℝ)+1)*capacityEntropy H
        (capacityResolution H ((d:ℝ)+1) P) ((d:ℝ)+1)+1 := by
    apply (Nat.ceil_lt_add_one _).le
    exact mul_nonneg (by positivity) (capacityEntropy_nonneg _ _ hp)
  apply hc.trans
  unfold capacityPolynomial
  apply add_le_add_left
  exact mul_le_mul_of_nonneg_left (capacityEntropy_le hp hP) (by positivity)

theorem auxiliaryFunctions_card_le_exp {d H : ℕ} {P : ℝ} (hH : 0<H) (hP : 0<P) :
    ((auxiliaryFunctions d H P).card : ℝ)≤
      Real.exp (capacityPolynomial H ((d:ℝ)+1) P*((d:ℝ)+1)) := by
  have hc := auxiliaryFunctions_card_le (d := d) hH hP
  have hc' : ((auxiliaryFunctions d H P).card : ℝ)≤
      ((2:ℝ)^d+1)^(auxiliaryCapacity d H P) := by exact_mod_cast hc
  have heq : ((2:ℝ)^d+1)^(auxiliaryCapacity d H P)=
      Real.exp ((auxiliaryCapacity d H P : ℝ)*Real.log ((2:ℝ)^d+1)) := by
    rw [Real.exp_nat_mul,Real.exp_log (by positivity)]
  rw [heq] at hc'
  apply hc'.trans
  apply Real.exp_le_exp.mpr
  calc
    _ ≤ (auxiliaryCapacity d H P : ℝ)*((d:ℝ)+1) :=
      mul_le_mul_of_nonneg_left (cube_log_card_le d) (Nat.cast_nonneg _)
    _ ≤ _ := mul_le_mul_of_nonneg_right (auxiliaryCapacity_le_polynomial d H hP.le) (by positivity)

end NeuralGeneralization.BatchTwoActivation
