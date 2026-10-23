import NeuralGeneralization.BatchTwoActivationConcreteMoment
import NeuralGeneralization.BatchTwoActivationCapacityArithmetic
import Mathlib.Combinatorics.SetFamily.Shatter
import Mathlib.Data.Nat.Choose.Bounds

/-!
# A finite common sign class for all learner widths

The class is defined by actual networks with the original activation and
weighted energy. Its cardinal bound follows from proved exponential-moment
estimates and Sauer's lemma, with no capacity hypothesis.
-/

noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

/-- Explicit (nonoptimized) all-width margin dimension. -/
def activationCapacity (d r : ℕ) (ℓ K : ℝ) : ℕ :=
  let p := (d:ℝ)+1
  let P := outputNormalization r ℓ K
  ⌈16*P^2*p*capacityEntropy (r+1) (capacityResolution (r+1) p P) p⌉₊

theorem shattering_card_le {d r n : ℕ} {φ : ℝ→ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d)
    (x : Fin n→Cube d)
    (hshatter : ∀ ε : Fin n→Bool, ∃ N, 0<N ∧ ∃ w : Weights d N r,
      weightedSquaredNorm w≤K ∧ ∀i, (1/2:ℝ)≤cubeCoordinateSign (ε i)*networkOutput φ w (x i)) :
    n≤activationCapacity d r ℓ K := by
  have hP := outputNormalization_pos r hℓ (lt_of_lt_of_le zero_lt_one hK)
  have hp : (0:ℝ)<(d:ℝ)+1 := by positivity
  have hq := capacityResolution_pos (Nat.succ_pos r) hp hP
  have hm := shattering_mgf_bound hφ hℓ hK hd x hshatter hq
    (1/(4*outputNormalization r ℓ K*((d:ℝ)+1))) (by positivity)
  have hb := capacity_from_moment (Nat.succ_pos r) hp hP hm
  unfold activationCapacity
  exact_mod_cast hb.trans (Nat.le_ceil _)

/-- The strict-margin learner is contained in this weak-margin sign class. -/
def energyFunctions (d r : ℕ) (φ : ℝ→ℝ) (K : ℝ) : Finset (BooleanFunction d) :=
  Finset.univ.filter (fun f => ∃ N, 0<N ∧ ∃w : Weights d N r,
    weightedSquaredNorm w≤K ∧ ∀x, (1/2:ℝ)≤labelReal (f x)*networkOutput φ w x)

def functionPattern {d : ℕ} (f : BooleanFunction d) : Finset (Cube d) :=
  Finset.univ.filter (fun x => f x = true)

theorem functionPattern_injective {d : ℕ} : Function.Injective (@functionPattern d) := by
  intro f g h
  funext x
  have hx := congrArg (fun S : Finset (Cube d) => x∈S) h
  simp only [functionPattern, Finset.mem_filter, Finset.mem_univ, true_and] at hx
  cases hf : f x <;> cases hg : g x <;> simp_all

def energyPatterns (d r : ℕ) (φ : ℝ→ℝ) (K : ℝ) : Finset (Finset (Cube d)) :=
  (energyFunctions d r φ K).image functionPattern

theorem energyPatterns_shattered_card_le {d r : ℕ} {φ : ℝ→ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d)
    (S : Finset (Cube d)) (hS : (energyPatterns d r φ K).Shatters S) :
    S.card≤activationCapacity d r ℓ K := by
  let e : S≃Fin S.card := Fintype.equivFinOfCardEq (by simp)
  let x : Fin S.card→Cube d := fun i => (e.symm i).val
  have hx : Function.Injective x := by
    intro i j hij
    exact e.symm.injective (Subtype.ext hij)
  apply shattering_card_le hφ hℓ hK hd x
  intro ε
  let T : Finset (Cube d) := (Finset.univ.filter (fun i => ε i=true)).image x
  have hTS : T⊆S := by
    intro y hy
    obtain ⟨i, _, rfl⟩ := Finset.mem_image.mp hy
    exact (e.symm i).property
  obtain ⟨A, hA, hSA⟩ := hS hTS
  obtain ⟨f, hf, rfl⟩ := Finset.mem_image.mp hA
  obtain ⟨N, hN, w, hw, hm⟩ := (Finset.mem_filter.mp hf).2
  refine ⟨N,hN,w,hw,?_⟩
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

theorem energyPatterns_vcDim_le {d r : ℕ} {φ : ℝ→ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d) :
    (energyPatterns d r φ K).vcDim≤activationCapacity d r ℓ K := by
  unfold Finset.vcDim
  apply Finset.sup_le
  intro S hS
  exact energyPatterns_shattered_card_le hφ hℓ hK hd S (Finset.mem_shatterer.mp hS)

theorem sum_powers_le (a m : ℕ) : ∑ k∈Finset.range (m+1), a^k ≤ (a+1)^m := by
  induction m with
  | zero => simp
  | succ m ih =>
    have he : ∑ k∈Finset.range (m+1+1), a^k =
        1+a*∑ k∈Finset.range (m+1), a^k := by
      rw [Finset.sum_range_succ']
      simp only [pow_zero, pow_succ', ← Finset.mul_sum]
      omega
    rw [he, pow_succ']
    have hpow := Nat.one_le_pow m (a+1) (by omega)
    nlinarith [Nat.mul_le_mul_left a ih]

/-- One common finite function class contains every margin-separated network
of bounded Gaussian energy, at every positive width. -/
theorem energyFunctions_card_le {d r : ℕ} {φ : ℝ→ℝ} {ℓ K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d) :
    (energyFunctions d r φ K).card ≤ (2^d+1)^(activationCapacity d r ℓ K) := by
  have hvc := energyPatterns_vcDim_le (r := r) hφ hℓ hK hd
  have hc : (energyFunctions d r φ K).card=(energyPatterns d r φ K).card := by
    rw [energyPatterns, Finset.card_image_of_injective _ functionPattern_injective]
  rw [hc]
  calc
    _ ≤ (energyPatterns d r φ K).shatterer.card := Finset.card_le_card_shatterer _
    _ ≤ ∑ k∈Finset.Iic (energyPatterns d r φ K).vcDim, (Fintype.card (Cube d)).choose k :=
      Finset.card_shatterer_le_sum_vcDim
    _ ≤ ∑ k∈Finset.range (activationCapacity d r ℓ K+1), (2^d)^k := by
      calc
        _ ≤ ∑ k∈Finset.Iic (energyPatterns d r φ K).vcDim, (Fintype.card (Cube d))^k :=
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

end NeuralGeneralization.BatchTwoActivation
