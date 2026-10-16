import NeuralGeneralization.FiniteCoordinateSymmetrization
import NeuralGeneralization.RankOneGeometry

/-!
# Actual random-partition decoupling at the second moment

Jensen's inequality and independent-coordinate swaps decouple the two
selectors of a hollow matrix. The vector-valued argument is valid in any
real normed space and uses literal uniform finite averages.
-/
noncomputable section
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators
open NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable

variable {α β W : Type*} [NormedAddCommGroup W] [NormedSpace ℝ W]

def vectorMean [Fintype α] (f : α → W) : W :=
  (Fintype.card α : ℝ)⁻¹ • ∑ x, f x

lemma vectorMean_smul [Fintype α] (f : α → ℝ) (v : W) :
    vectorMean (fun x => f x • v) = finiteMean f • v := by
  unfold vectorMean finiteMean
  rw [← Finset.sum_smul, smul_smul]
  congr 1
  ring

lemma vectorMean_sum {I : Type*} [Fintype I] [Fintype α] (F : I → α → W) :
    vectorMean (fun x => ∑ i, F i x) = ∑ i, vectorMean (F i) := by
  unfold vectorMean
  rw [Finset.sum_comm, Finset.smul_sum]

lemma norm_sq_vectorMean_le [Fintype α] [Nonempty α] (F : α → W) :
    ‖vectorMean F‖^2 ≤ finiteMean (fun x => ‖F x‖^2) := by
  have hc : (0:ℝ) < Fintype.card α := Nat.cast_pos.mpr Fintype.card_pos
  have hnorm := norm_sum_le Finset.univ F
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun _ : α => (1:ℝ)) (fun x => ‖F x‖)
  simp only [one_mul, one_pow, Finset.sum_const, Finset.card_univ, nsmul_eq_mul,
    mul_one] at hcs
  have hs := sq_le_sq₀ (norm_nonneg (∑ x,F x))
    (Finset.sum_nonneg (fun x _ => norm_nonneg (F x))) |>.mpr hnorm
  unfold vectorMean finiteMean
  rw [norm_smul, Real.norm_eq_abs, abs_inv, abs_of_nonneg hc.le, mul_pow]
  calc
    _ ≤ (Fintype.card α:ℝ)⁻¹^2*((Fintype.card α:ℝ)*∑ x, ‖F x‖^2) :=
      mul_le_mul_of_nonneg_left (hs.trans hcs) (sq_nonneg _)
    _ = _ := by field_simp

lemma half_partition_pair_mean {m : ℕ} (i j : Fin m) (hij : i ≠ j) :
    finiteMean (fun ε : Fin m → Bool =>
      (if ε i then (1:ℝ) else 0)*(if ε j then (0:ℝ) else 1)) = 1/4 := by
  let F := fun k : Fin m => fun b : Bool =>
    (if k=i then (if b then (1:ℝ) else 0) else 1)*
    (if k=j then (if b then (0:ℝ) else 1) else 1)
  have hp (ε : Fin m → Bool) :
      (∏ k, F k (ε k)) = (if ε i then (1:ℝ) else 0)*(if ε j then (0:ℝ) else 1) := by
    dsimp only [F]
    rw [Finset.prod_mul_distrib]
    simp
  have hm (k : Fin m) : finiteMean (F k) =
      (if k=i then (1/2:ℝ) else 1)*(if k=j then (1/2:ℝ) else 1) := by
    by_cases hi : k=i
    · subst k
      simp [F, hij, finiteMean]
    · by_cases hj : k=j
      · subst k
        simp [F, Ne.symm hij, finiteMean]
      · simp [F, hi, hj]
  have h := finiteMean_pi_prod F
  simp_rw [hp, hm] at h
  rw [Finset.prod_mul_distrib] at h
  norm_num at h
  simpa using h

/-- One directed cross-block determined by an independent half partition. -/
def crossBlock {m : ℕ} (ε : Fin m → Bool) (A : Fin m → Fin m → W) : W :=
  ∑ i, ∑ j, ((if ε i then (1:ℝ) else 0)*(if ε j then (0:ℝ) else 1)) • A i j

lemma crossBlock_mean {m : ℕ} (A : Fin m → Fin m → W) (hdiag : ∀ i,A i i=0) :
    vectorMean (fun ε : Fin m → Bool => crossBlock ε A) =
      (1/4:ℝ) • (∑ i,∑ j,A i j) := by
  unfold crossBlock
  rw [vectorMean_sum]
  simp_rw [vectorMean_sum, vectorMean_smul]
  rw [Finset.smul_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [Finset.smul_sum]
  apply Finset.sum_congr rfl
  intro j _
  by_cases hij : i=j
  · subst j
    simp [hdiag]
  · rw [half_partition_pair_mean i j hij]

/-- Jensen's partition estimate. The constant is deliberately nonoptimal;
this version needs no Hermitian-matrix identity. -/
theorem hollow_partition_second_moment {m : ℕ}
    (A : Fin m → Fin m → W) (hdiag : ∀ i,A i i=0) :
    ‖∑ i,∑ j,A i j‖^2 ≤
      16*finiteMean (fun ε : Fin m → Bool => ‖crossBlock ε A‖^2) := by
  have h := norm_sq_vectorMean_le (fun ε : Fin m → Bool => crossBlock ε A)
  rw [crossBlock_mean A hdiag, norm_smul, Real.norm_eq_abs] at h
  norm_num at h
  nlinarith only [h]

variable [Fintype α] [Nonempty α]

/-- A decoupled selector-weighted cross-block. -/
def selectorCross {m : ℕ} (choose : α → Bool) (ε : Fin m → Bool)
    (s t : Fin m → α) (A : Fin m → Fin m → W) : W :=
  crossBlock ε (fun i j =>
    ((if choose (s i) then (1:ℝ) else 0)*(if choose (t j) then (1:ℝ) else 0)) • A i j)

/-- The selected entries crossing a fixed partition depend on disjoint
coordinate families. Swapping the complementary coordinates with an
independent ghost proves their exact decoupled second-moment identity. -/
theorem selectorCross_decoupled_mean {m : ℕ} (choose : α → Bool)
    (ε : Fin m → Bool) (A : Fin m → Fin m → W) :
    finiteMean (fun s : Fin m → α => ‖selectorCross choose ε s s A‖^2) =
      finiteMean (fun s : Fin m → α => finiteMean (fun t : Fin m → α =>
        ‖selectorCross choose ε s t A‖^2)) := by
  have he (st : (Fin m → α) × (Fin m → α)) :
      selectorCross choose ε (signSwap ε st).1 (signSwap ε st).2 A =
        selectorCross choose ε st.1 st.1 A := by
    unfold selectorCross crossBlock
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    cases hi : ε i <;> cases hj : ε j <;>
      simp [hi,hj,signSwap]
  have h := finiteMean_equiv (signSwap ε)
    (fun st : (Fin m → α) × (Fin m → α) => ‖selectorCross choose ε st.1 st.2 A‖^2)
  simp_rw [he] at h
  rw [finiteMean_prod] at h
  simp only [finiteMean_const] at h
  rw [finiteMean_prod] at h
  exact h

/-- Exact second-moment partition decoupling for independent uniform finite
selectors. This separates all probabilistic work from norm contraction of
the deterministic matrix cross-block. -/
theorem selector_partition_decoupling {m : ℕ} (choose : α → Bool)
    (A : Fin m → Fin m → W) (hdiag : ∀ i,A i i=0) :
    finiteMean (fun s : Fin m → α =>
      ‖∑ i,∑ j, ((if choose (s i) then (1:ℝ) else 0)*
        (if choose (s j) then (1:ℝ) else 0)) • A i j‖^2) ≤
      16*finiteMean (fun ε : Fin m → Bool => finiteMean (fun s : Fin m → α =>
        finiteMean (fun t : Fin m → α => ‖selectorCross choose ε s t A‖^2))) := by
  have hp (s : Fin m → α) := hollow_partition_second_moment
    (fun i j => ((if choose (s i) then (1:ℝ) else 0)*
      (if choose (s j) then (1:ℝ) else 0)) • A i j)
    (fun i => by rw [hdiag i,smul_zero])
  have h := finiteMean_mono hp
  rw [finiteMean_mul, finiteMean_comm] at h
  change _ ≤ 16*finiteMean (fun ε : Fin m → Bool => finiteMean
    (fun s : Fin m → α => ‖selectorCross choose ε s s A‖^2)) at h
  simpa only [selectorCross_decoupled_mean] using h

end NeuralGeneralization.RandomRestriction
