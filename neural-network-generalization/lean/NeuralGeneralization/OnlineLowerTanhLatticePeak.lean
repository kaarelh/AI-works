import NeuralGeneralization.OnlineLowerTanhLocalizationCore
import NeuralGeneralization.OnlineLowerTanhPhase
import Mathlib.Algebra.Ring.Int.Parity
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-! # A positive sine-product peak gives an actual positive odd lattice -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def positiveOddIndex (a u : ℝ) : ℕ := (phaseInteger true (|u|/a)).natAbs

theorem positiveOddIndex_odd (a u : ℝ) : Odd (positiveOddIndex a u) :=
  (phaseInteger_odd _).natAbs

theorem positiveOddIndex_pos (a u : ℝ) : 0 < positiveOddIndex a u :=
  (positiveOddIndex_odd a u).pos

theorem positiveOddIndex_residual (a u : ℝ) (ha : 0 < a) :
    (|u|-a*(positiveOddIndex a u:ℝ))^2 ≤ a^2*(phaseError true (|u|/a))^2 := by
  let k := phaseInteger true (|u|/a)
  have hres : |u|-a*(k:ℝ)=a*phaseError true (|u|/a) := by
    dsimp [k,phaseError]
    field_simp
  have habs := abs_abs_sub_abs_le_abs_sub |u| (a*(k:ℝ))
  rw [abs_abs,abs_mul,abs_of_pos ha] at habs
  have hk : (positiveOddIndex a u:ℝ)=|(k:ℝ)| := by
    dsimp [positiveOddIndex,k]
    rw [Nat.cast_natAbs,Int.cast_abs]
  rw [← hk,hres,abs_mul,abs_of_pos ha] at habs
  have hs := pow_le_pow_left₀ (abs_nonneg _) habs 2
  simpa only [sq_abs,mul_pow] using hs

/-- The conclusion uses literal positive odd natural integers, rather
than an abstract distance to a lattice. -/
theorem odd_lattice_of_phase_peak {n : ℕ} (u : Fin n → ℝ) (a μ : ℝ)
    (ha : 0 < a) (hμ : 0 < μ)
    (hpeak : μ ≤ ∏i, phaseWave true (|u i|/a)) :
    (∀i, Odd (positiveOddIndex a (u i))) ∧
      (∑i, (|u i|-a*(positiveOddIndex a (u i):ℝ))^2) ≤ -2*a^2*Real.log μ := by
  have hprod := prod_phaseWave_le_exp Finset.univ (fun _ : Fin n => true) (fun i => |u i|/a)
  have hlog := Real.log_le_log hμ (hpeak.trans hprod)
  rw [Real.log_exp] at hlog
  have hsum := Finset.sum_le_sum (fun i (_ : i∈Finset.univ) => positiveOddIndex_residual a (u i) ha)
  rw [← Finset.mul_sum] at hsum
  have hscaled := mul_le_mul_of_nonneg_left hlog (sq_nonneg a)
  refine ⟨fun i => positiveOddIndex_odd a (u i),?_⟩
  nlinarith only [hsum,hscaled]

/-- A frequency peak of the actual absolute sine product gives a lattice
with spacing pi/(2t). Input signs are already removed inside the indices. -/
theorem odd_lattice_of_sine_peak {n : ℕ} (u : Fin n → ℝ) (t μ : ℝ)
    (ht : 0 < t) (hμ : 0 < μ) (hpeak : μ ≤ paritySineProduct u t) :
    let a := Real.pi/(2*t)
    (∀i, Odd (positiveOddIndex a (u i))) ∧
      (∑i, (|u i|-a*(positiveOddIndex a (u i):ℝ))^2) ≤ -2*a^2*Real.log μ := by
  dsimp only
  apply odd_lattice_of_phase_peak u _ μ (by positivity) hμ
  have hpoint (i : Fin n) : phaseWave true (|u i|/(Real.pi/(2*t))) = |Real.sin (t*u i)| := by
    simp only [phaseWave,↓reduceIte]
    have he : Real.pi*(|u i|/(Real.pi/(2*t)))/2=t*|u i| := by field_simp
    rw [he]
    by_cases hu : 0≤u i
    · rw [abs_of_nonneg hu]
    · rw [abs_of_neg (lt_of_not_ge hu),mul_neg,Real.sin_neg,abs_neg]
  simpa only [hpoint,paritySineProduct] using hpeak

end NeuralGeneralization.OnlineLowerTanh
