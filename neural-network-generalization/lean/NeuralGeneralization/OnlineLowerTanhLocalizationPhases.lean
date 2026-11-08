import NeuralGeneralization.OnlineLowerTanhLocalizationDeterminant
import NeuralGeneralization.OnlineLowerTanhPhase

/-!
# Actual nearest-phase separation for different rail orientations

The old selected coordinates that become unselected are paired with *all*
newly selected coordinates. Every cross determinant is odd. This avoids the
case split according to whether more or fewer than half the rails switch.
-/

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def switchedOffCoordinates (old new : ι → Bool) : Finset ι :=
  Finset.univ.filter (fun i => old i = true ∧ new i = false)

def selectedPhaseCoordinates (new : ι → Bool) : Finset ι :=
  Finset.univ.filter (fun i => new i = true)

theorem switchedOff_disjoint_selected (old new : ι → Bool) :
    Disjoint (switchedOffCoordinates old new) (selectedPhaseCoordinates new) := by
  rw [Finset.disjoint_left]
  intro i hi hj
  have ha := (Finset.mem_filter.mp hi).2.2
  have hb := (Finset.mem_filter.mp hj).2
  simp_all

/-- The collective determinant inequality with the actual nearest even/odd
integer phases and their actual squared errors. -/
theorem actual_phase_determinant_bound (old new : ι → Bool) (x : ι → ℝ)
    (γ K Δ : ℝ)
    (hK : (∑ i, (phaseInteger (old i) (x i) : ℝ)^2) ≤ K)
    (hΔ : (∑ i, (phaseError (old i) (x i))^2) ≤ Δ) :
    ((switchedOffCoordinates old new).card : ℝ) *
      ((selectedPhaseCoordinates new).card : ℝ) ≤
        4*K*((∑ i, (phaseError (new i) (γ*x i))^2)+γ^2*Δ) := by
  let A := switchedOffCoordinates old new
  let B := selectedPhaseCoordinates new
  let k := fun i => phaseInteger (old i) (x i)
  let l := fun i => phaseInteger (new i) (γ*x i)
  let δ := fun i => phaseError (old i) (x i)
  let ε := fun i => phaseError (new i) (γ*x i)
  have hd : Disjoint A B := switchedOff_disjoint_selected old new
  have hphase (i : ι) (_ : i ∈ A∪B) :
      γ*((k i : ℝ)+δ i) = (l i : ℝ)+ε i := by
    dsimp [k,l,δ,ε]
    rw [← phaseError_decompose,← phaseError_decompose]
  have hodd (a : ι) (ha : a ∈ A) (b : ι) (hb : b ∈ B) : Odd (k a*l b-k b*l a) := by
    have hao := (Finset.mem_filter.mp ha).2.1
    have han := (Finset.mem_filter.mp ha).2.2
    have hbn := (Finset.mem_filter.mp hb).2
    have hka : Odd (k a) := by simpa only [k,hao] using phaseInteger_odd (x a)
    have hla : Even (l a) := by simpa only [l,han] using phaseInteger_even (γ*x a)
    have hlb : Odd (l b) := by simpa only [l,hbn] using phaseInteger_odd (γ*x b)
    exact (hka.mul hlb).sub_even (hla.mul_left (k b))
  have sum_bound (f : ι → ℝ) : (∑ i ∈ A, f i^2)+(∑ i ∈ B, f i^2) ≤ ∑ i, f i^2 := by
    rw [← Finset.sum_union hd]
    exact Finset.sum_le_univ_sum_of_nonneg (fun i => sq_nonneg (f i))
  exact phase_determinant_total_bound A B k l δ ε γ K (∑ i, ε i^2) Δ hphase hodd
    ((sum_bound fun i => (k i : ℝ)).trans hK) (sum_bound ε) ((sum_bound δ).trans hΔ)

/-- Once the determinant mass dominates the old-error rescaling, every
competing orientation is exponentially small. This is a bound on the actual
product of absolute sine/cosine factors. -/
theorem actual_phase_product_small (old new : ι → Bool) (x : ι → ℝ)
    (γ K Δ q : ℝ) (hKpos : 0 < K)
    (hK : (∑ i, (phaseInteger (old i) (x i) : ℝ)^2) ≤ K)
    (hΔ : (∑ i, (phaseError (old i) (x i))^2) ≤ Δ)
    (hcard : 8*K*q ≤ ((switchedOffCoordinates old new).card : ℝ)*
      ((selectedPhaseCoordinates new).card : ℝ))
    (hshift : γ^2*Δ ≤ q) :
    (∏ i, phaseWave (new i) (γ*x i)) ≤ Real.exp (-q/2) := by
  have hd := actual_phase_determinant_bound old new x γ K Δ hK hΔ
  have he : q ≤ ∑ i, (phaseError (new i) (γ*x i))^2 := by
    have hh := mul_le_mul_of_nonneg_left hshift (show 0 ≤ 4*K by positivity)
    have hcancel : K*q ≤ K*(∑ i, (phaseError (new i) (γ*x i))^2) := by nlinarith
    exact (mul_le_mul_iff_right₀ hKpos).mp hcancel
  apply (prod_phaseWave_le_exp Finset.univ new (fun i => γ*x i)).trans
  exact Real.exp_le_exp.mpr (by linarith)


/-- A genuine constant-height resonance forces a bounded total squared
nearest-phase error. -/
theorem resonance_phase_error_bound (old : ι → Bool) (x : ι → ℝ) (μ : ℝ)
    (hμ : 0 < μ) (hpeak : μ ≤ ∏ i, phaseWave (old i) (x i)) :
    (∑ i, (phaseError (old i) (x i))^2) ≤ -2*Real.log μ := by
  have hp := hpeak.trans (prod_phaseWave_le_exp Finset.univ old x)
  have hl := Real.log_le_log hμ hp
  rw [Real.log_exp] at hl
  linarith

/-- Integer phase energy is bounded by the physical phase energy and the
nearest-phase error energy. -/
theorem phaseInteger_energy_le (old : ι → Bool) (x : ι → ℝ) :
    (∑ i, (phaseInteger (old i) (x i) : ℝ)^2) ≤
      2*(∑ i, x i^2)+2*(∑ i, (phaseError (old i) (x i))^2) := by
  have hpoint (i : ι) : (phaseInteger (old i) (x i) : ℝ)^2 ≤
      2*x i^2+2*(phaseError (old i) (x i))^2 := by
    have he := phaseError_decompose (old i) (x i)
    have hk : (phaseInteger (old i) (x i) : ℝ) = x i-phaseError (old i) (x i) := by linarith
    rw [hk]
    nlinarith [sq_nonneg (x i+phaseError (old i) (x i))]
  have hs := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  simpa only [Finset.sum_add_distrib,←Finset.mul_sum] using hs

end NeuralGeneralization.OnlineLowerTanh
