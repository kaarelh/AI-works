import NeuralGeneralization.RobustCircuit
import NeuralGeneralization.CloneSubspace
import NeuralGeneralization.CylinderGeometry

/-!
# Saturated cloning at every integer width above Boolean width

Unlike disconnected padding, every extra neuron computes the counted
constant wire. Thus every ideal hidden coordinate is a saturated Boolean
value. Input columns belonging to padding remain unused by the teacher.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ConcreteModel
variable {d C N r k p : ℕ}

namespace LayeredBooleanCircuit

def cloneInputGate (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (i : Fin N) : DigitalGate (Fin (d+1)) :=
  match e.symm i with
  | .inl (a,_) => B.first a
  | .inr _ => .copy 0

def cloneInternalGate (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (s : Fin r) (i : Fin N) : DigitalGate (Fin C) :=
  match e.symm i with
  | .inl (a,_) => B.internal s a
  | .inr _ => .copy B.constant

/-- Padded rows compute the constant wire; padded columns have zero teacher weight. -/
def saturatedClone (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (A a : ℝ) : Weights d N r
  | Sum.inl (i,j) => A * (B.cloneInputGate e i).coeff 0 j
  | Sum.inr (Sum.inl (s,i,j)) =>
      match e.symm j with
      | .inl (b,_) => A * (B.cloneInternalGate e s i).coeff B.constant b / (k : ℝ)
      | .inr _ => 0
  | Sum.inr (Sum.inr i) =>
      match e.symm i with
      | .inl (b,_) => if b=B.output then a/(k:ℝ) else 0
      | .inr _ => 0

end LayeredBooleanCircuit

/-- Ideal Boolean state with all padding coordinates equal to `+1`. -/
def saturatedCloneBits (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (b : Fin C → Bool) : Fin N → ℝ :=
  fun i => match e.symm i with
    | .inl (a,_) => labelReal (b a)
    | .inr _ => 1

/-- Logical wire value obtained by averaging its active copies. -/
def cloneMean (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (h : Fin N → ℝ) (a : Fin C) : ℝ :=
  (∑ j : Fin k, h (e (.inl (a,j)))) / (k : ℝ)

@[simp] theorem abs_saturatedCloneBits
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (b : Fin C → Bool) (i : Fin N) :
    |saturatedCloneBits e b i| = 1 := by
  unfold saturatedCloneBits
  split <;> simp

theorem saturatedCloneBits_mem_subspace
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (b : Fin C → Bool) :
    saturatedCloneBits e b ∈ cloneSubspace e := by
  exact clonedHidden_mem_cloneSubspace (fun _ => 1) e (fun a => labelReal (b a))

@[simp] theorem cloneMean_saturatedCloneBits (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (b : Fin C → Bool) (a : Fin C) :
    cloneMean e (saturatedCloneBits e b) a = labelReal (b a) := by
  have hkR : (k:ℝ) ≠ 0 := by exact_mod_cast hk.ne'
  simp [cloneMean, saturatedCloneBits, hkR]

/-- Summing one actual clone group is dominated by summing the entire width. -/
theorem clone_group_energy_le
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (z : Fin N → ℝ) (a : Fin C) :
    (∑ j : Fin k, z (e (.inl (a,j)))^2) ≤ ∑ i : Fin N, z i^2 := by
  classical
  have hi : Function.Injective (fun j : Fin k => e (.inl (a,j))) := by
    intro j l h
    have hh := e.injective h
    simpa using hh
  calc
    _ = ∑ i ∈ Finset.univ.image (fun j : Fin k => e (.inl (a,j))), z i^2 := by
      rw [Finset.sum_image]
      exact fun j _ l _ h => hi h
    _ ≤ _ := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      (fun i _ _ => sq_nonneg (z i))

/-- The group-mean error follows from the joint squared error, with no
coordinatewise assumption about the noisy hidden state. -/
theorem cloneMean_error_sq (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (h : Fin N → ℝ) (b : Fin C → Bool) (a : Fin C) :
    (cloneMean e h a-labelReal (b a))^2 ≤
      (∑ i, (h i-saturatedCloneBits e b i)^2) / (k:ℝ) := by
  have hkR : (0:ℝ) < k := Nat.cast_pos.mpr hk
  have he : cloneMean e h a-labelReal (b a) =
      (∑ j : Fin k, (h (e (.inl (a,j)))-labelReal (b a))) / (k:ℝ) := by
    simp only [cloneMean, Finset.sum_sub_distrib, Finset.sum_const,
      Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  rw [he, div_pow]
  have hh := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ)
    (fun _ : Fin k => (1:ℝ))
    (fun j : Fin k => h (e (.inl (a,j)))-labelReal (b a))
  simp only [one_mul, one_pow, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, mul_one] at hh
  have hg := clone_group_energy_le e (fun i => h i-saturatedCloneBits e b i) a
  simp only [saturatedCloneBits, Equiv.symm_apply_apply] at hg
  apply (div_le_div_iff₀ (sq_pos_of_pos hkR) hkR).mpr
  have hbound := hh.trans (mul_le_mul_of_nonneg_left hg hkR.le)
  have hm := mul_le_mul_of_nonneg_right hbound hkR.le
  simpa only [saturatedCloneBits, pow_two, mul_assoc, mul_left_comm, mul_comm] using hm

namespace LayeredBooleanCircuit

theorem saturatedClone_internalRow_mem (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (A a : ℝ) (s : Fin r) (i : Fin N) :
    (fun j => B.saturatedClone e A a (Sum.inr (Sum.inl (s,i,j)))) ∈ cloneSubspace e := by
  let u : Option (Fin C) → ℝ := fun g => match g with
    | none => 0
    | some b => A*(B.cloneInternalGate e s i).coeff B.constant b/(k:ℝ)
  have he : (fun j => B.saturatedClone e A a (Sum.inr (Sum.inl (s,i,j)))) =
      fun j => u (cloneGroup e j) := by
    funext j
    cases hj : e.symm j <;> simp [saturatedClone, cloneGroup, u, hj]
  rw [he]
  exact cloneGroup_function_mem e u

theorem saturatedClone_first_preactivation (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (A a : ℝ) (x : Cube d) (i : Fin N) :
    (∑ j, B.saturatedClone e A a (Sum.inl (i,j))*inputVector x j) =
      A*(B.cloneInputGate e i).linear 1 (inputVector x) := by
  simp only [saturatedClone, mul_assoc, ← Finset.mul_sum, DigitalGate.sum_coeff]
  rfl

theorem saturatedClone_internal_preactivation (B : LayeredBooleanCircuit d C r)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (A a : ℝ) (h : Fin N → ℝ)
    (s : Fin r) (i : Fin N) :
    (∑ j, B.saturatedClone e A a (Sum.inr (Sum.inl (s,i,j)))*h j) =
      A*(B.cloneInternalGate e s i).linear (cloneMean e h B.constant) (cloneMean e h) := by
  rw [← (B.cloneInternalGate e s i).sum_coeff B.constant (cloneMean e h)]
  rw [← e.sum_comp]
  simp only [Fintype.sum_sum_type, Fintype.sum_prod_type, saturatedClone,
    Equiv.symm_apply_apply, zero_mul, Finset.sum_const_zero, add_zero]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _hj
  simp only [cloneMean, ← Finset.mul_sum, div_mul_eq_mul_div, ← Finset.sum_div]
  ring

end LayeredBooleanCircuit
end NeuralGeneralization.ConcreteModel
