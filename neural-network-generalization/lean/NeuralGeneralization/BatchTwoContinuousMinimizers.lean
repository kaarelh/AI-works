import NeuralGeneralization.BatchTwoContinuousExactInterpolants
import NeuralGeneralization.WeightedMarginMinimizers
import NeuralGeneralization.GaussianModelRate

/-! Existence and energy control of actual minimum-energy exact interpolants.
The feasible set contains network parameters, not a surrogate function class. -/
noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling BatchTwoSurvivalStatistics

def exactInterpolants {d N r n : ℕ} (φ : ℝ → ℝ) (f : RealInput d → ℝ)
    (s : Fin n → RealInput d) : Set (Weights d N r) :=
  {w | ∀ i, output φ w (s i) = f (s i)}

def energyMinimizers {d N r n : ℕ} (φ : ℝ → ℝ) (f : RealInput d → ℝ)
    (s : Fin n → RealInput d) : Set (Weights d N r) :=
  {w | w ∈ exactInterpolants φ f s ∧ ∀ v ∈ exactInterpolants (N := N) (r := r) φ f s,
    weightedSquaredNorm w ≤ weightedSquaredNorm v}

theorem continuous_weightedEnergy {d N r : ℕ} :
    Continuous (weightedSquaredNorm (d := d) (N := N) (r := r)) := by
  unfold weightedSquaredNorm
  fun_prop

theorem isClosed_exactInterpolants {d N r n : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : RealInput d → ℝ) (s : Fin n → RealInput d) :
    IsClosed (exactInterpolants (N := N) (r := r) φ f s) := by
  simp only [exactInterpolants, setOf_forall]
  exact isClosed_iInter (fun i => isClosed_eq (continuous_output_weights hφ _) continuous_const)

theorem isCompact_weightedEnergy_sublevel {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    (K : ℝ) : IsCompact {w : Weights d N r | weightedSquaredNorm w ≤ K} := by
  have hc (i : WeightIndex d N r) : 0 < coordinatePrecision d N r i := by
    rcases i with ij | (sij | j)
    · exact div_pos (Nat.cast_pos.mpr hd) (Nat.cast_pos.mpr hN)
    · exact zero_lt_one
    · exact Nat.cast_pos.mpr hN
  have he (w : Weights d N r) :
      featureEnergy (fun i => (coordinatePrecision d N r i)⁻¹) w =
        weightedSquaredNorm w := by
    rw [weightedSquaredNorm_eq_coordinateSum]
    simp only [featureEnergy, div_inv_eq_mul, mul_comm]
  simpa only [he] using WeightedMarginMinimizers.isCompact_energy_sublevel
    (fun i : WeightIndex d N r => (coordinatePrecision d N r i)⁻¹)
    (fun i => inv_pos.mpr (hc i)) K

theorem energyMinimizers_nonempty {d N r n : ℕ} (hd : 0 < d) (hN : 0 < N)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (f : RealInput d → ℝ) (s : Fin n → RealInput d)
    (hne : (exactInterpolants (N := N) (r := r) φ f s).Nonempty) :
    (energyMinimizers (N := N) (r := r) φ f s).Nonempty := by
  obtain ⟨v, hv⟩ := hne
  let K := {w : Weights d N r | weightedSquaredNorm w ≤ weightedSquaredNorm v} ∩
    exactInterpolants φ f s
  have hK : IsCompact K := (isCompact_weightedEnergy_sublevel hd hN _).inter_right
    (isClosed_exactInterpolants hφ f s)
  obtain ⟨w, hw, hmin⟩ := hK.exists_isMinOn (show K.Nonempty from ⟨v, (show weightedSquaredNorm v ≤ weightedSquaredNorm v from le_rfl), hv⟩) continuous_weightedEnergy.continuousOn
  refine ⟨w, hw.2, fun u hu => ?_⟩
  by_cases he : weightedSquaredNorm u ≤ weightedSquaredNorm v
  · exact hmin ⟨he, hu⟩
  · exact hw.1.trans (le_of_not_ge he)

theorem energyMinimizers_energy_le {d N r n : ℕ} {φ : ℝ → ℝ} {f : RealInput d → ℝ}
    {s : Fin n → RealInput d} {v w : Weights d N r}
    (hv : v ∈ exactInterpolants φ f s) (hw : w ∈ energyMinimizers φ f s) :
    weightedSquaredNorm w ≤ weightedSquaredNorm v := hw.2 v hv

theorem energyMinimizers_isClosed {d N r n : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    (f : RealInput d → ℝ) (s : Fin n → RealInput d) :
    IsClosed (energyMinimizers (N := N) (r := r) φ f s) := by
  have he : energyMinimizers (N := N) (r := r) φ f s = exactInterpolants φ f s ∩
      ⋂ v ∈ exactInterpolants (N := N) (r := r) φ f s, {w | weightedSquaredNorm w ≤ weightedSquaredNorm v} := by
    ext w
    simp [energyMinimizers]
  rw [he]
  exact (isClosed_exactInterpolants hφ f s).inter (isClosed_iInter fun v =>
    isClosed_iInter fun _ => isClosed_le continuous_weightedEnergy continuous_const)

/-- One sample event controls exact minimum-energy interpolation at every
width admitting a low-energy witness, and every probability mixture of the
minimizers. The cover and sample budget are the manuscript's explicit ones. -/
theorem exact_minimizers_generalize {d r K R : ℕ}
    (hd : 1 ≤ d) (hK : 1 ≤ K) (hR : 1 ≤ R)
    (f : RealInput d → ℝ) (hf : Continuous f)
    (X : Set (RealInput d)) (hX : X.Nonempty) (hcompact : IsCompact X)
    (hball : ∀ x ∈ X, ∑ j, x j^2 ≤ 1)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ = 0)
    {τ ε δ H : ℝ} (hτ : 0 < τ) (hε : 0 < ε) (hδ : 0 < δ)
    (haccuracy : 1/(3*(R : ℝ)) ≤ τ/8)
    (hcard : (Fintype.card (UniformCoverCode d r K R) : ℝ) ≤ Real.exp H)
    (n : ℕ) (hsize : (3/ε)*(H+Real.log (1/δ)) ≤ (n : ℝ)) :
    ∃ G : Set (Fin n → RealInput d), MeasurableSet G ∧
      1-δ ≤ (iidSamples D n).real G ∧ ∀ s ∈ G, ∀ N : ℕ, 0 < N →
      (∃ v : Weights d N r, v ∈ exactInterpolants Real.tanh f s ∧
        weightedSquaredNorm v ≤ (K : ℝ)) →
      (energyMinimizers (N := N) (r := r) Real.tanh f s).Nonempty ∧
      (∀ w ∈ energyMinimizers (N := N) (r := r) Real.tanh f s,
        D.real {x | τ < |output Real.tanh w x-f x|} ≤ ε/3) ∧
      (∀ Q : Measure (Weights d N r), IsProbabilityMeasure Q →
        (∀ᵐ w ∂Q, w ∈ energyMinimizers Real.tanh f s) →
        risk Real.tanh D Q f τ ≤ ε/3 ∧ confidenceFailure Real.tanh D Q f τ ≤ ε) := by
  obtain ⟨G, hG, hprob, hg⟩ := low_energy_interpolants_and_mixtures hd hK hR f hf
    X hX hcompact hball D hDX hτ hε hδ haccuracy hcard n hsize
  refine ⟨G, hG, hprob, ?_⟩
  intro s hs N hN hwitness
  obtain ⟨v, hv, henergy⟩ := hwitness
  have he (w : Weights d N r) (hw : w ∈ energyMinimizers Real.tanh f s) :
      weightedSquaredNorm w ≤ (K : ℝ) ∧
        ∀ i, |output Real.tanh w (s i)-f (s i)| ≤ τ/2 := by
    refine ⟨(energyMinimizers_energy_le hv hw).trans henergy, ?_⟩
    intro i
    rw [hw.1 i, sub_self, abs_zero]
    positivity
  refine ⟨energyMinimizers_nonempty (by omega) hN tanh_continuous f s ⟨v, hv⟩, ?_, ?_⟩
  · intro w hw
    exact (hg s hs).1 N hN w (he w hw).1 (he w hw).2
  · intro Q hprobQ hQ
    apply (hg s hs).2 N hN Q hprobQ
    filter_upwards [hQ] with w hw
    exact he w hw

/-- The bounded-teacher corollary, with cloning and the actual cover count
discharged: every learner width at least the teacher width is covered on one
measurable sample event. No interpolating-witness or capacity oracle remains. -/
theorem bounded_teacher_exact_minimizers {d C r K R : ℕ}
    (hd : 1 ≤ d) (hC : 1 ≤ C) (hK : 1 ≤ K) (hR : 1 ≤ R)
    (teacher : Weights d C r) {B : ℝ} (hB : 0 ≤ B) (hw : boundedWeights B teacher)
    (henergy : 2*teacherEnergyBound d C r B ≤ (K : ℝ))
    (X : Set (RealInput d)) (hX : X.Nonempty) (hcompact : IsCompact X)
    (hball : ∀ x ∈ X, ∑ j, x j^2 ≤ 1)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ = 0)
    {τ ε δ : ℝ} (hτ : 0 < τ) (hε : 0 < ε) (hδ : 0 < δ)
    (haccuracy : 1/(3*(R : ℝ)) ≤ τ/8)
    (n : ℕ) (hsize : (3/ε)*((coverEntropy d r K R : ℝ)+Real.log (1/δ)) ≤ (n : ℝ)) :
    ∃ G : Set (Fin n → RealInput d), MeasurableSet G ∧
      1-δ ≤ (iidSamples D n).real G ∧ ∀ s ∈ G, ∀ N : ℕ, C ≤ N →
      (energyMinimizers (N := N) (r := r) Real.tanh (output Real.tanh teacher) s).Nonempty ∧
      (∀ w ∈ energyMinimizers (N := N) (r := r) Real.tanh (output Real.tanh teacher) s,
        D.real {x | τ < |output Real.tanh w x-output Real.tanh teacher x|} ≤ ε/3) ∧
      (∀ Q : Measure (Weights d N r), IsProbabilityMeasure Q →
        (∀ᵐ w ∂Q, w ∈ energyMinimizers Real.tanh (output Real.tanh teacher) s) →
        risk Real.tanh D Q (output Real.tanh teacher) τ ≤ ε/3 ∧
        confidenceFailure Real.tanh D Q (output Real.tanh teacher) τ ≤ ε) := by
  obtain ⟨G, hG, hprob, hg⟩ := exact_minimizers_generalize hd hK hR
    (output Real.tanh teacher) (continuous_output_input tanh_continuous teacher)
    X hX hcompact hball D hDX hτ hε hδ haccuracy
    (uniformCoverCode_card_le_exp d r K R) n hsize
  refine ⟨G, hG, hprob, ?_⟩
  intro s hs N hCN
  apply hg s hs N (by omega)
  obtain ⟨v, hv, he⟩ := exists_real_clone_at_every_width (by omega) hCN Real.tanh teacher
  refine ⟨v, fun i => hv (s i), ?_⟩
  exact he.trans ((mul_le_mul_of_nonneg_left
    (bounded_teacher_energy (by omega) hB teacher hw) (by norm_num)).trans henergy)

end NeuralGeneralization.BatchTwoContinuous
