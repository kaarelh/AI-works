import NeuralGeneralization.EnergyProjection
import Mathlib.Analysis.SpecialFunctions.Sqrt

/-!
# A low-rank witness for failure of bounded-energy approximation

No singular-value decomposition is needed. A maximal orthogonal input family
under the energy budget gives either an actual operator approximation, or an
explicit family of at most `K/a²+1` directions whose captured part has energy
above `K`. Normalizing that captured part yields unit Hilbert--Schmidt norm
and correlation with the original operator greater than `sqrt K`.
-/

noncomputable section

namespace NeuralGeneralization

open scoped BigOperators RealInnerProductSpace
open InnerProductSpace

variable {E F : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F]

/-- Either a bounded-energy capture approximates the operator, or a small
orthonormal family already captures energy exceeding the budget. -/
theorem energy_approximation_or_small_witness [FiniteDimensional ℝ E]
    (A : E →L[ℝ] F) (a K : ℝ) (ha : 0 < a) (hK : 0 ≤ K) :
    (∃ s : Finset E, orthonormalFinset s ∧ capturedEnergy A s ≤ K ∧
      ‖A - energyCapture A s‖ ≤ a) ∨
    (∃ s : Finset E, orthonormalFinset s ∧
      (∀ v ∈ s, a < ‖A v‖) ∧ (s.card : ℝ) ≤ K / a ^ 2 + 1 ∧
      K < capturedEnergy A s) := by
  classical
  obtain ⟨s, hs, hlarge, henergy, _, hmax⟩ := exists_maximal_energy_family A a K hK
  by_cases hres : ‖A - energyCapture A s‖ ≤ a
  · exact Or.inl ⟨s, hs, henergy, hres⟩
  · obtain ⟨v, hv, horth, hAv⟩ := exists_orthogonal_direction_of_residual
      A s hs a ha.le (lt_of_not_ge hres)
    have hnot : v ∉ s := by
      intro hvs
      have hh := horth v hvs
      simp [hv] at hh
    have hcard := energy_family_card_bound A s ha.le hlarge henergy
    refine Or.inr ⟨insert v s, orthonormalFinset_insert s hs v hv horth, ?_, ?_, ?_⟩
    · intro w hw
      rcases Finset.mem_insert.mp hw with rfl | hw
      · exact hAv
      · exact hlarge w hw
    · rw [Finset.card_insert_of_notMem hnot, Nat.cast_add, Nat.cast_one]
      have hsdiv : (s.card : ℝ) ≤ K / a ^ 2 :=
        (le_div_iff₀ (sq_pos_of_pos ha)).mpr hcard
      linarith
    · simpa [capturedEnergy, Finset.sum_insert hnot, add_comm] using hmax v hv horth hAv

/-- Hilbert--Schmidt pairing computed in an actual orthonormal basis of the
input space. Its use below does not assume a spectral basis for the operator. -/
def hsPairing {ι : Type*} [Fintype ι] (e : OrthonormalBasis ι ℝ E)
    (A B : E →L[ℝ] F) : ℝ := ∑ i, ⟪A (e i), B (e i)⟫

lemma hsPairing_rankOne {ι : Type*} [Fintype ι] (e : OrthonormalBasis ι ℝ E)
    (A : E →L[ℝ] F) (u : F) (v : E) :
    hsPairing e A (rankOne ℝ u v) = ⟪A v, u⟫ := by
  unfold hsPairing
  simp only [rankOne_apply, inner_smul_right]
  have hreconstruct : (∑ i, ⟪v, e i⟫ • e i) = v := by
    simpa only [real_inner_comm] using e.sum_repr' v
  calc
    _ = ⟪A (∑ i, ⟪v, e i⟫ • e i), u⟫ := by
      simp [map_sum, map_smul, sum_inner, inner_smul_left]
    _ = _ := by rw [hreconstruct]

lemma hsPairing_capture {ι : Type*} [Fintype ι] (e : OrthonormalBasis ι ℝ E)
    (A B : E →L[ℝ] F) (s : Finset E) :
    hsPairing e A (energyCapture B s) = ∑ v ∈ s, ⟪A v, B v⟫ := by
  rw [energyCapture_eq_sum_rankOne]
  simp only [hsPairing, sum_apply, inner_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro v hv
  exact hsPairing_rankOne e A (B v) v

lemma energyProjection_eq_self (s : Finset E) (hs : orthonormalFinset s)
    (v : E) (hv : v ∈ s) : energyProjection s v = v := by
  classical
  rw [energyProjection_apply, Finset.sum_eq_single v]
  · simp [hs.1 v hv]
  · intro w hw hwv
    rw [hs.2 w hw v hv hwv, zero_smul]
  · exact fun h => (h hv).elim

lemma energyCapture_mem (A : E →L[ℝ] F) (s : Finset E)
    (hs : orthonormalFinset s) (v : E) (hv : v ∈ s) :
    energyCapture A s v = A v := by
  simp only [energyCapture, ContinuousLinearMap.comp_apply, energyProjection_eq_self s hs v hv]

/-- The pairing of the original operator with its actual capture is exactly
the captured energy. -/
lemma hsPairing_self_capture {ι : Type*} [Fintype ι] (e : OrthonormalBasis ι ℝ E)
    (A : E →L[ℝ] F) (s : Finset E) :
    hsPairing e A (energyCapture A s) = capturedEnergy A s := by
  rw [hsPairing_capture]
  simp only [capturedEnergy, real_inner_self_eq_norm_sq]

/-- The actual squared Hilbert--Schmidt norm of the captured operator is the
same energy, using only orthogonality of its right vectors. -/
lemma hsPairing_capture_self {ι : Type*} [Fintype ι] (e : OrthonormalBasis ι ℝ E)
    (A : E →L[ℝ] F) (s : Finset E) (hs : orthonormalFinset s) :
    hsPairing e (energyCapture A s) (energyCapture A s) = capturedEnergy A s := by
  rw [hsPairing_capture]
  unfold capturedEnergy
  apply Finset.sum_congr rfl
  intro v hv
  rw [energyCapture_mem A s hs v hv, real_inner_self_eq_norm_sq]

/-- Normalized captured operator. -/
def normalizedEnergyCapture (A : E →L[ℝ] F) (s : Finset E) : E →L[ℝ] F :=
  (Real.sqrt (capturedEnergy A s))⁻¹ • energyCapture A s

lemma hsPairing_smul_right {ι : Type*} [Fintype ι] (e : OrthonormalBasis ι ℝ E)
    (A B : E →L[ℝ] F) (c : ℝ) : hsPairing e A (c • B) = c * hsPairing e A B := by
  simp [hsPairing, inner_smul_right, Finset.mul_sum]

lemma hsPairing_smul_left {ι : Type*} [Fintype ι] (e : OrthonormalBasis ι ℝ E)
    (A B : E →L[ℝ] F) (c : ℝ) : hsPairing e (c • A) B = c * hsPairing e A B := by
  simp [hsPairing, inner_smul_left, Finset.mul_sum]

/-- The normalized capture has actual Hilbert--Schmidt squared norm one. -/
theorem normalizedEnergyCapture_unit {ι : Type*} [Fintype ι]
    (e : OrthonormalBasis ι ℝ E) (A : E →L[ℝ] F) (s : Finset E)
    (hs : orthonormalFinset s) (henergy : 0 < capturedEnergy A s) :
    hsPairing e (normalizedEnergyCapture A s) (normalizedEnergyCapture A s) = 1 := by
  rw [normalizedEnergyCapture, hsPairing_smul_left, hsPairing_smul_right,
    hsPairing_capture_self e A s hs]
  have hsqrt := Real.sq_sqrt henergy.le
  have hpos := Real.sqrt_pos.mpr henergy
  field_simp
  nlinarith

/-- Its correlation with the original operator is the square root of the
captured energy, not merely a lower bound. -/
theorem normalizedEnergyCapture_pairing {ι : Type*} [Fintype ι]
    (e : OrthonormalBasis ι ℝ E) (A : E →L[ℝ] F) (s : Finset E)
    (henergy : 0 < capturedEnergy A s) :
    hsPairing e A (normalizedEnergyCapture A s) = Real.sqrt (capturedEnergy A s) := by
  rw [normalizedEnergyCapture, hsPairing_smul_right, hsPairing_self_capture]
  have hsqrt := Real.sq_sqrt henergy.le
  have hpos := Real.sqrt_pos.mpr henergy
  field_simp
  nlinarith

/-- Every original factor norm is at most the square root of total captured
energy, so its normalized scalar coefficient is bounded by one. -/
lemma image_norm_le_sqrt_energy (A : E →L[ℝ] F) (s : Finset E)
    (v : E) (hv : v ∈ s) : ‖A v‖ ≤ Real.sqrt (capturedEnergy A s) := by
  have hterm : ‖A v‖ ^ 2 ≤ capturedEnergy A s :=
    Finset.single_le_sum (fun w _ => sq_nonneg ‖A w‖) hv
  have hsqrt := Real.sq_sqrt (capturedEnergy_nonneg A s)
  nlinarith [Real.sqrt_nonneg (capturedEnergy A s), norm_nonneg (A v)]

end NeuralGeneralization
