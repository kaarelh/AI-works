import NeuralGeneralization.BatchTwoNonGaussianStrongRate
import NeuralGeneralization.LowEnergyCapacity

/-! A width-independent finite relevant class, derived from actual weighted-norm
compression. The larger teacher budget absorbs the ratio of curvature constants. -/

noncomputable section
open MeasureTheory Filter
open scoped BigOperators Topology
open NeuralGeneralization.ConcreteModel NeuralGeneralization.CompressionSampling
namespace NeuralGeneralization.BatchTwoNonGaussian

def teacherEnergy (d r C : ℕ) : ℕ := d * (d + 1) * C ^ 2 + (r + 1) * C ^ 4

theorem teacherEnergy_scaled (d r C k : ℕ) (hk : 1 ≤ k) :
    k * teacherEnergy d r C ≤ teacherEnergy d r (k * C) := by
  have h2 : k ≤ k ^ 2 := le_self_pow₀ hk (by decide)
  have h4 : k ≤ k ^ 4 := le_self_pow₀ hk (by decide)
  unfold teacherEnergy
  rw [mul_pow, mul_pow]
  calc
    _ = d * (d + 1) * (k * C ^ 2) + (r + 1) * (k * C ^ 4) := by ring
    _ ≤ d * (d + 1) * (k ^ 2 * C ^ 2) + (r + 1) * (k ^ 4 * C ^ 4) := by gcongr

def energyClass (d N r B : ℕ) (φ : ℝ → ℝ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun g =>
    (marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty ∧
      networkEnergy (N := N) (r := r) φ (1 / 2) g ≤ (teacherEnergy d r B : ℝ)

theorem mem_energyClass {d N r B : ℕ} (φ : ℝ → ℝ) (g : BooleanFunction d) :
    g ∈ energyClass d N r B φ ↔
      (marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty ∧
      networkEnergy (N := N) (r := r) φ (1 / 2) g ≤ (teacherEnergy d r B : ℝ) := by
  classical
  simp [energyClass]

theorem energyClass_compressed {d N r B : ℕ} (hd : 1 ≤ d) (hN : 0 < N)
    {φ : ℝ → ℝ} (hφ : admissibleActivation φ) (g : BooleanFunction d)
    (hg : g ∈ energyClass d N r B φ) :
    ∃ w : Weights d (strongCompressionWidth d r B) r,
      w ∈ marginEvent φ (1 / 2) g ∧ boundedWeights (strongCompressionWidth d r B) w := by
  obtain ⟨hne, henergy⟩ := (mem_energyClass φ g).mp hg
  obtain ⟨w, hw, hcost⟩ := exists_nearoptimal_margin_network φ (1 / 2) g hne 1 zero_lt_one
  have hbudget : weightedSquaredNorm w ≤ (strongEnergyBudget d r B : ℝ) := by
    have hEq : (strongEnergyBudget d r B : ℝ) = 2 * (teacherEnergy d r B : ℝ) + 1 := by
      simp [strongEnergyBudget, teacherEnergy]
    rw [hEq]
    linarith
  have hK : 1 ≤ strongEnergyBudget d r B := by unfold strongEnergyBudget; omega
  obtain ⟨v, hv, hb, _⟩ := norm_compression hd hN hK φ hφ g w hbudget hw
  exact ⟨v, hv, hb⟩

theorem energyClass_card_le_exp {d N r B : ℕ} (hd : 1 ≤ d) (hN : 0 < N)
    {φ : ℝ → ℝ} (hφ : admissibleActivation φ) :
    ((energyClass d N r B φ).card : ℝ) ≤ Real.exp (strongCapacity d r B : ℝ) :=
  representedClass_card_le_exp (energyClass d N r B φ)
    (strongCompressionWidth d r B) r (strongCompressionWidth d r B) φ hφ
    (fun g hg => energyClass_compressed hd hN hφ g hg)

theorem energyClass_tail_ratio (ν : CoordinateLaw) {d C N r k : ℕ}
    (hd : 0 < d) (hk : 1 ≤ k) (hcurv : ν.upperCurvature ≤ ν.lowerCurvature * k)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hc : realizesAtComplexity (r := r) φ f C) (hCN : C ≤ N) :
    Tendsto (fun σ =>
      (∑ g ∈ Finset.univ \ energyClass d N r (k * C) φ,
        functionMass φ (1 / 2) (smallPrior ν d N r σ) g) /
      functionMass φ (1 / 2) (smallPrior ν d N r σ) f) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  classical
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hc.1) hCN
  have hf := margin_witness_at_larger_width φ f hc hCN
  have htarget : networkEnergy (N := N) (r := r) φ (1 / 2) f ≤ (teacherEnergy d r C : ℝ) := by
    simpa only [teacherEnergy, Nat.cast_add, Nat.cast_mul, Nat.cast_pow, Nat.cast_one] using
      networkEnergy_le_complexity_polynomial φ f hc hCN
  have hscaled : (k : ℝ) * (teacherEnergy d r C : ℝ) ≤ (teacherEnergy d r (k * C) : ℝ) := by
    exact_mod_cast teacherEnergy_scaled d r C k hk
  have hbound : ν.upperCurvature * networkEnergy (N := N) (r := r) φ (1 / 2) f ≤
      ν.lowerCurvature * (teacherEnergy d r (k * C) : ℝ) := by
    calc
      _ ≤ ν.upperCurvature * (teacherEnergy d r C : ℝ) :=
        mul_le_mul_of_nonneg_left htarget ν.upperCurvature_pos.le
      _ ≤ (ν.lowerCurvature * k) * (teacherEnergy d r C : ℝ) :=
        mul_le_mul_of_nonneg_right hcurv (Nat.cast_nonneg _)
      _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_left hscaled ν.lowerCurvature_pos.le]
  have hratio : ∀ g ∈ Finset.univ \ energyClass d N r (k * C) φ,
      Tendsto (fun σ => functionMass φ (1 / 2) (smallPrior ν d N r σ) g /
        functionMass φ (1 / 2) (smallPrior ν d N r σ) f) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
    intro g hg
    by_cases hne : (marginEvent (N := N) (r := r) φ (1 / 2) g).Nonempty
    · have hgt : (teacherEnergy d r (k * C) : ℝ) < networkEnergy (N := N) (r := r) φ (1 / 2) g := by
        apply lt_of_not_ge
        intro hle
        exact (Finset.mem_sdiff.mp hg).2 ((mem_energyClass φ g).mpr ⟨hne, hle⟩)
      apply smallMass_ratio_tendsto_zero ν hd hN hφ f g hf hne
      exact hbound.trans_lt (mul_lt_mul_of_pos_left hgt ν.lowerCurvature_pos)
    · have hempty : marginEvent (N := N) (r := r) φ (1 / 2) g = ∅ := Set.not_nonempty_iff_eq_empty.mp hne
      simpa only [functionMass, hempty, measure_empty, ENNReal.toReal_zero, zero_div] using
        (tendsto_const_nhds : Tendsto (fun _ : ℝ => (0 : ℝ)) (𝓝[>] (0 : ℝ)) (𝓝 0))
  simpa only [Finset.sum_div, Finset.sum_const_zero] using
    tendsto_finsetSum (Finset.univ \ energyClass d N r (k * C) φ) hratio

end NeuralGeneralization.BatchTwoNonGaussian
