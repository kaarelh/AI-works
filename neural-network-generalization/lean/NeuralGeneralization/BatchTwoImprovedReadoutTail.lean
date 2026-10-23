import NeuralGeneralization.BatchTwoImprovedReadoutLaw

/-! Simultaneous finite-input approximation by the actual importance-sampled
readout. There is no coefficient truncation error. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoImprovedReadout
open RobustCompressionReadout RobustCompressionSampling CompressionSampling Classical
variable {N m : ℕ} {X : Type*}

def sampledCoefficient (v : Fin N → ℝ) (I : Fin m → Fin N) (j : Fin m) : ℝ :=
  amplitude v * coefficientSign (v (I j)) / m

def sampledOutput (v : Fin N → ℝ) (h : X → Fin N → ℝ)
    (I : Fin m → Fin N) (x : X) : ℝ :=
  ∑ j, sampledCoefficient v I j * h x (I j)

theorem sampledOutput_eq_empiricalMean (v : Fin N → ℝ) (h : X → Fin N → ℝ)
    (I : Fin m → Fin N) (x : X) :
    sampledOutput v h I x = empiricalMean (fun i => amplitude v * coefficientSign (v i) * h x i) I := by
  unfold sampledOutput sampledCoefficient empiricalMean
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem sampledCoefficient_bound (hN : 0 < N) (v : Fin N → ℝ)
    {K : ℝ} (hK : 0 ≤ K) (henergy : populationMean (fun i => (v i)^2) ≤ K)
    (I : Fin m → Fin N) (j : Fin m) :
    |sampledCoefficient v I j| ≤ Real.sqrt K / m := by
  unfold sampledCoefficient
  rw [abs_div, abs_mul, abs_of_nonneg (amplitude_nonneg v), sign_abs, mul_one,
    abs_of_nonneg (Nat.cast_nonneg m)]
  exact div_le_div_of_nonneg_right (amplitude_le_sqrt_energy hN v hK henergy) (Nat.cast_nonneg m)

theorem importance_sampling_tail [Fintype X] (hN : 0 < N) (hm : 0 < m)
    (v : Fin N → ℝ) (h : X → Fin N → ℝ) (hh : ∀ x i, |h x i| ≤ 1)
    {K ε : ℝ} (hK : 0 < K) (hε : 0 ≤ ε)
    (henergy : populationMean (fun i => (v i)^2) ≤ K) :
    (indicesKernel hN m v).real
      {I | ∃ x, ε ≤ |sampledOutput v h I x - readoutValue v h x|} ≤
      (Fintype.card X : ℝ) * (2 * Real.exp (-(m : ℝ) * ε^2 / (2*K))) := by
  have ha := amplitude_le_sqrt_energy hN v hK.le henergy
  have hbound (x : X) (i : Fin N) :
      |amplitude v * coefficientSign (v i) * h x i| ≤ Real.sqrt K := by
    rw [abs_mul, abs_mul, abs_of_nonneg (amplitude_nonneg v), sign_abs, mul_one]
    exact (mul_le_mul_of_nonneg_left (hh x i) (amplitude_nonneg v)).trans (by simpa using ha)
  have ht := finite_bank_tail_of_law N m hm (indexKernel hN v)
    (fun x i => amplitude v * coefficientSign (v i) * h x i)
    (Real.sqrt_pos.mpr hK) hbound hε
  simp_rw [integral_atom, ← sampledOutput_eq_empiricalMean, Real.sq_sqrt hK.le] at ht
  rw [indicesKernel_eq_iid]
  exact ht

/-- A concrete linear-in-energy sample budget. The failure event uses a weak
inequality, so outside it the approximation is strictly better than r/8. -/
theorem importance_sampling_budget [Fintype X] [Nonempty X]
    (hN : 0 < N) (hm : 0 < m) (v : Fin N → ℝ)
    (h : X → Fin N → ℝ) (hh : ∀ x i, |h x i| ≤ 1)
    {K r η : ℝ} (hK : 0 < K) (hr : 0 < r) (hη : 0 < η)
    (henergy : populationMean (fun i => (v i)^2) ≤ K)
    (hbudget : 128*K/r^2 * Real.log (2*(Fintype.card X : ℝ)/η) ≤ (m : ℝ)) :
    (indicesKernel hN m v).real
      {I | ∃ x, r/8 ≤ |sampledOutput v h I x - readoutValue v h x|} ≤ η := by
  apply (importance_sampling_tail hN hm v h hh hK (by positivity) henergy).trans
  have hc : (0 : ℝ) < Fintype.card X := Nat.cast_pos.mpr Fintype.card_pos
  have hden : 0 < 128*K/r^2 := by positivity
  have hlog : Real.log (2*(Fintype.card X : ℝ)/η) ≤ (m : ℝ)/(128*K/r^2) :=
    (le_div_iff₀ hden).mpr (by simpa only [mul_comm] using hbudget)
  have heq : -(m : ℝ)*(r/8)^2/(2*K) = -((m : ℝ)/(128*K/r^2)) := by
    field_simp <;> ring
  rw [heq]
  have he := Real.exp_le_exp.mpr (neg_le_neg hlog)
  have hl : Real.exp (-Real.log (2*(Fintype.card X : ℝ)/η)) = η/(2*Fintype.card X) := by
    rw [Real.exp_neg, Real.exp_log (by positivity)]
    field_simp
  rw [hl] at he
  calc
    _ ≤ (Fintype.card X : ℝ)*(2*(η/(2*Fintype.card X))) := by nlinarith
    _ = η := by field_simp

end NeuralGeneralization.BatchTwoImprovedReadout
