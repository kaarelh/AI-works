import NeuralGeneralization.BatchTwoContinuousInputNet
import NeuralGeneralization.RobustCompressionGrid

/-! Finite grids of actual neural-network outputs on real unit-ball inputs. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling ParameterGrid

theorem augmentedInput_abs_le_one {d : ℕ} (x : RealInput d) (hx : ∑ i, x i^2 ≤ 1)
    (j : Fin (d+1)) : |augmentedInput x j| ≤ 1 := by
  refine Fin.cases (by simp [augmentedInput]) (fun i => ?_) j
  exact coord_abs_le_one x hx i

theorem freeze_bounded {d N r : ℕ} (x : RealInput d) (hx : ∑ i, x i^2 ≤ 1)
    (w : Weights d N r) {B : ℝ} (hB : 0 ≤ B) (hw : boundedWeights B w) :
    boundedWeights (((d : ℝ)+1)*B) (freezeInput x w) := by
  intro a
  have hBB : B ≤ ((d : ℝ)+1)*B := by nlinarith [Nat.cast_nonneg (α := ℝ) d]
  rcases a with ⟨i,j⟩ | a
  · refine Fin.cases ?_ (fun j => ?_) j
    · change |∑ k, w (Sum.inl (i,k))*augmentedInput x k| ≤ _
      calc
        _ ≤ ∑ k, |w (Sum.inl (i,k))*augmentedInput x k| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _k : Fin (d+1), B := by
          apply Finset.sum_le_sum
          intro k _
          rw [abs_mul]
          exact (mul_le_mul (hw _) (augmentedInput_abs_le_one x hx k) (abs_nonneg _) hB).trans (by simp)
        _ = _ := by simp
    · simpa [freezeInput] using mul_nonneg (show 0 ≤ (d : ℝ)+1 by positivity) hB
  · exact (hw _).trans hBB

theorem freeze_distance {d N r : ℕ} (x : RealInput d) (hx : ∑ i, x i^2 ≤ 1)
    (w v : Weights d N r) {η : ℝ} (hη : 0 ≤ η) (hwv : ∀ a, |w a-v a| ≤ η) :
    ∀ a, |freezeInput x w a-freezeInput x v a| ≤ ((d : ℝ)+1)*η := by
  intro a
  have hηη : η ≤ ((d : ℝ)+1)*η := by nlinarith [Nat.cast_nonneg (α := ℝ) d]
  rcases a with ⟨i,j⟩ | a
  · refine Fin.cases ?_ (fun j => ?_) j
    · change |(∑ k, w (Sum.inl (i,k))*augmentedInput x k)-(∑ k, v (Sum.inl (i,k))*augmentedInput x k)| ≤ _
      rw [← Finset.sum_sub_distrib]
      calc
        _ ≤ ∑ k, |w (Sum.inl (i,k))*augmentedInput x k-v (Sum.inl (i,k))*augmentedInput x k| := Finset.abs_sum_le_sum_abs _ _
        _ ≤ ∑ _k : Fin (d+1), η := by
          apply Finset.sum_le_sum
          intro k _
          rw [← sub_mul,abs_mul]
          exact (mul_le_mul (hwv _) (augmentedInput_abs_le_one x hx k) (abs_nonneg _) hη).trans (by simp)
        _ = _ := by simp
    · simpa [freezeInput] using mul_nonneg (show 0 ≤ (d : ℝ)+1 by positivity) hη
  · exact (hwv _).trans hηη

theorem real_parameter_stability {d N r B : ℕ} (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w v : Weights d N r) {η : ℝ} (hη : 0 ≤ η) (hv : boundedWeights B v)
    (hclose : ∀ a, |w a-v a| ≤ η) (x : RealInput d) (hx : ∑ i, x i^2 ≤ 1) :
    |output φ w x-output φ v x| ≤ η*((d : ℝ)+1)*parameterMesh d N r ((d+1)*B) := by
  have h := networkOutput_parameter_stability φ hφ (freezeInput x w) (freezeInput x v)
    (((d+1)*B : ℕ) : ℝ) (((d : ℝ)+1)*η) (by positivity) (by positivity)
    (by simpa using freeze_bounded x hx v (Nat.cast_nonneg B) hv)
    (freeze_distance x hx w v hη hclose) (fun _ => false)
  rw [output_freeze,output_freeze] at h
  have hm := mul_le_mul_of_nonneg_left (sensitivity_le_parameterMesh d N r ((d+1)*B))
    (show 0 ≤ ((d : ℝ)+1)*η by positivity)
  calc
    _ ≤ _ := h
    _ ≤ _ := hm
    _ = _ := by ring

def realOutputMesh (d M r B R : ℕ) : ℕ := B*R*(d+1)*parameterMesh d M r ((d+1)*B)

theorem realOutputMesh_pos (d M r : ℕ) {B R : ℕ} (hB : 0 < B) (hR : 0 < R) :
    0 < realOutputMesh d M r B R := by
  unfold realOutputMesh
  exact Nat.mul_pos (by positivity) (parameterMesh_pos _ _ _ _)

abbrev RealOutputCode (d M r B R : ℕ) := WeightIndex d M r → GridInt (realOutputMesh d M r B R)

def realGridWeights {d M r B R : ℕ} (q : RealOutputCode d M r B R) : Weights d M r :=
  fun i => (B : ℝ)*decode (realOutputMesh d M r B R) q i

theorem realGridWeights_bounded {d M r B R : ℕ} (hB : 0 < B) (hR : 0 < R)
    (q : RealOutputCode d M r B R) : boundedWeights B (realGridWeights q) := by
  intro i
  unfold realGridWeights
  rw [abs_mul,abs_of_nonneg (Nat.cast_nonneg B)]
  simpa using mul_le_mul_of_nonneg_left
    (decode_abs_le_one _ (realOutputMesh_pos d M r hB hR) q i) (Nat.cast_nonneg (α := ℝ) B)

theorem exists_realGridOutput {d M r B R : ℕ} (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (hB : 0 < B) (hR : 0 < R) (w : Weights d M r) (hw : boundedWeights B w) :
    ∃ q : RealOutputCode d M r B R, ∀ x : RealInput d, (∑ i, x i^2 ≤ 1) →
      |output φ w x-output φ (realGridWeights q) x| ≤ 1/(R : ℝ) := by
  have hBR : 0 < (B : ℝ) := by exact_mod_cast hB
  have hRR : 0 < (R : ℝ) := by exact_mod_cast hR
  have hT : 0 < (realOutputMesh d M r B R : ℝ) := by exact_mod_cast realOutputMesh_pos d M r hB hR
  obtain ⟨q,hq⟩ := exists_close_grid (realOutputMesh d M r B R) (realOutputMesh_pos d M r hB hR)
    (fun i => w i/(B : ℝ)) (fun i => by rw [abs_div,abs_of_pos hBR]; exact (div_le_one hBR).mpr (hw i))
  refine ⟨q,?_⟩
  have hclose (i : WeightIndex d M r) : |w i-realGridWeights q i| ≤ (B : ℝ)/realOutputMesh d M r B R := by
    have h := mul_le_mul_of_nonneg_left (hq i) hBR.le
    have hid : w i-realGridWeights q i=(B : ℝ)*(w i/B-decode (realOutputMesh d M r B R) q i) := by
      unfold realGridWeights
      field_simp
    rw [hid,abs_mul,abs_of_pos hBR]
    simpa only [mul_one_div] using h
  intro x hx
  apply (real_parameter_stability φ hφ w (realGridWeights q) (by positivity)
    (realGridWeights_bounded hB hR q) hclose x hx).trans
  have hp : (parameterMesh d M r ((d+1)*B) : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (parameterMesh_pos _ _ _ _).ne'
  have hd : (d : ℝ)+1 ≠ 0 := by positivity
  apply le_of_eq
  unfold realOutputMesh
  push_cast
  field_simp

theorem realOutputCode_card (d M r B R : ℕ) :
    Fintype.card (RealOutputCode d M r B R)=
      (2*realOutputMesh d M r B R+1)^robustParameterCount d M r := by
  change Fintype.card (WeightIndex d M r → GridInt _)=_
  rw [Fintype.card_fun,gridInt_card,robustWeightIndex_card]

end NeuralGeneralization.BatchTwoContinuous
