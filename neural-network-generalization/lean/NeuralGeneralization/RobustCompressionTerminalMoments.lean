import NeuralGeneralization.RobustCompressionTerminalReadout

/-! # Actual terminal readout moment and energy abort from canonical entropy -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open RobustEntropy RobustEntropyMoments RobustCompressionSampling

variable {d N m s : ℕ}

def terminalStandardizedVector (p : TerminalState d N m s) : Fin N → ℝ :=
  fun i => p.2 (Sum.inr i)

@[fun_prop] theorem measurable_terminalStandardizedVector :
    Measurable (terminalStandardizedVector (d := d) (N := N) (m := m) (s := s)) := by
  unfold terminalStandardizedVector
  fun_prop

theorem terminal_standardized_kl_le
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q] :
    klDiv (Q.map terminalStandardizedVector) (Measure.pi (fun _ : Fin N => gaussianReal 0 1)) ≤
      futureEntropy Q (futurePrior N 0) := by
  have hR : Measurable (fun z : FutureWeights N 0 => fun i => z (Sum.inr i)) := by fun_prop
  have href : (Q.fst.prod (futurePrior N 0)).map terminalStandardizedVector =
      Measure.pi (fun _ : Fin N => gaussianReal 0 1) := by
    change (Q.fst.prod (futurePrior N 0)).map
      ((fun z : FutureWeights N 0 => fun i => z (Sum.inr i)) ∘ Prod.snd) = _
    rw [← Measure.map_map hR measurable_snd, Measure.map_snd_prod,
      measure_univ, one_smul, terminal_readout_reference]
  rw [← href]
  exact klDiv_map_le Q (Q.fst.prod (futurePrior N 0)) measurable_terminalStandardizedVector

theorem terminalEnergy_eq_scaled (t : ℝ) (p : TerminalState d N m s) :
    terminalEnergy t p.2 = t^2/(N : ℝ) * ∑ i, terminalStandardizedVector p i^2 := by
  unfold terminalEnergy terminalCoefficients terminalStandardizedVector populationMean
  simp only [mul_pow, ← Finset.mul_sum]
  ring

/-- Conditional entropy of the actual remaining readout gives a physical
moment uniform in the common Gaussian scale. -/
theorem terminal_energy_moment (hN : 0 < N)
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    {t K : ℝ} (ht : 0 < t) (ht1 : t^2 ≤ 1) (hK : 0 ≤ K)
    (hKL : futureEntropy Q (futurePrior N 0) ≤ ENNReal.ofReal (N*K/t^2)) :
    Integrable (fun p => terminalEnergy t p.2) Q ∧
      (∫ p, terminalEnergy t p.2 ∂Q) ≤ 4*K+2 := by
  let Qv := Q.map terminalStandardizedVector
  let G := Measure.pi (fun _ : Fin N => gaussianReal 0 1)
  letI : IsProbabilityMeasure Qv :=
    Measure.isProbabilityMeasure_map measurable_terminalStandardizedVector.aemeasurable
  have hb : klDiv Qv G ≤ ENNReal.ofReal (N*K/t^2) :=
    (terminal_standardized_kl_le Q).trans hKL
  obtain ⟨hi,hm⟩ := standard_gaussian_entropy_second_moment Qv
    (ne_top_of_le_ne_top ENNReal.ofReal_ne_top hb)
  have hZi : Integrable (fun p : TerminalState d N m s =>
      ∑ i, terminalStandardizedVector p i^2) Q :=
    hi.comp_measurable measurable_terminalStandardizedVector
  have hiE : Integrable (fun p : TerminalState d N m s => terminalEnergy t p.2) Q := by
    simp_rw [terminalEnergy_eq_scaled]
    exact hZi.const_mul _
  refine ⟨hiE, ?_⟩
  change (∫ z, ∑ i, z i^2 ∂Q.map terminalStandardizedVector) ≤ _ at hm
  rw [integral_map measurable_terminalStandardizedVector.aemeasurable
    (by exact (show Measurable (fun z : Fin N → ℝ => ∑ i, z i^2) by fun_prop).aestronglyMeasurable)] at hm
  have hbr := ENNReal.toReal_mono ENNReal.ofReal_ne_top hb
  rw [ENNReal.toReal_ofReal (by positivity : 0 ≤ (N : ℝ)*K/t^2)] at hbr
  have hmul := mul_le_mul_of_nonneg_left (hm.trans (by
    simpa only [Fintype.card_fin] using add_le_add (mul_le_mul_of_nonneg_left hbr (by norm_num)) le_rfl))
      (show 0 ≤ t^2/(N : ℝ) by positivity)
  have he : t^2/(N : ℝ) * (4*((N : ℝ)*K/t^2)+2*N) = 4*K+2*t^2 := by
    have hNR : (N : ℝ) ≠ 0 := (Nat.cast_pos.mpr hN).ne'
    field_simp
    <;> ring
  rw [he] at hmul
  simp_rw [terminalEnergy_eq_scaled]
  rw [integral_const_mul]
  exact hmul.trans (by linarith)

theorem terminal_energy_abort_of_entropy (hN : 0 < N)
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    {t K R : ℝ} (ht : 0 < t) (ht1 : t^2 ≤ 1) (hK : 0 ≤ K) (hR : 0 < R)
    (hKL : futureEntropy Q (futurePrior N 0) ≤ ENNReal.ofReal (N*K/t^2)) :
    Q.real {p | R < terminalEnergy t p.2} ≤ (4*K+2)/R := by
  obtain ⟨hi,hm⟩ := terminal_energy_moment hN Q ht ht1 hK hKL
  exact terminal_energy_abort_le Q hR hi hm

end NeuralGeneralization.RobustCompressionInduction
