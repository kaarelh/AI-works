import NeuralGeneralization.OnlineLowerTanhResidualCellLimit

/-! # Canonical variance scale and concrete hyperbolic derivative kernels -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def residualVariance {n : ℕ} (q : Fin n → ℕ) : ℝ := ∑ i, (q i:ℝ)^2
def residualScale {n : ℕ} (A : ℝ) (q : Fin n → ℕ) : ℝ := (A*Real.sqrt (residualVariance q))⁻¹

def residualDerivativeKernel (j : ℕ) (t : ℝ) : ℝ := t^j/Real.sinh (Real.pi*t/2)

lemma residualVariance_ge_dimension {n : ℕ} (q : Fin n → ℕ) (hq : ∀ i, 0 < q i) :
    (n:ℝ) ≤ residualVariance q := by
  have hh : (∑ _ : Fin n, (1:ℝ)) ≤ ∑ i, (q i:ℝ)^2 := by
    apply Finset.sum_le_sum
    intro i _
    have hi : (1:ℝ) ≤ q i := by exact_mod_cast hq i
    nlinarith
  simpa only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one,residualVariance] using hh

lemma residualVariance_pos {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ) (hq : ∀ i, 0 < q i) :
    0 < residualVariance q := lt_of_lt_of_le (by positivity) (residualVariance_ge_dimension q hq)

lemma residualScale_pos {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ) (hq : ∀ i, 0 < q i)
    {A : ℝ} (hA : 0 < A) : 0 < residualScale A q := by
  unfold residualScale
  exact inv_pos.mpr (mul_pos hA (Real.sqrt_pos.mpr (residualVariance_pos hn q hq)))

lemma residualScale_identity {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ) (hq : ∀ i, 0 < q i)
    {A : ℝ} (hA : 0 < A) : A^2*(∑ i, (q i:ℝ)^2)*(residualScale A q)^2 = 1 := by
  have hV := residualVariance_pos hn q hq
  have hroot := Real.sq_sqrt hV.le
  have hrne := (Real.sqrt_pos.mpr hV).ne'
  unfold residualScale
  change A^2*residualVariance q*(A*Real.sqrt (residualVariance q))⁻¹^2 = 1
  field_simp
  nlinarith [hroot]

lemma residualScale_tendsto (N : ℕ → ℕ) (q : (k : ℕ) → Fin (N k) → ℕ)
    (hN : Tendsto N atTop atTop) (hq : ∀ k i, 0 < q k i)
    (A : ℕ → ℝ) {A₀ : ℝ} (hA : Tendsto A atTop (𝓝 A₀)) (hA₀ : A₀ ≠ 0) :
    Tendsto (fun k => residualScale (A k) (q k)) atTop (𝓝 0) := by
  have hV : Tendsto (fun k => residualVariance (q k)) atTop atTop :=
    tendsto_atTop_mono (fun k => residualVariance_ge_dimension (q k) (hq k))
      (tendsto_natCast_atTop_atTop.comp hN)
  have hi := tendsto_inv_atTop_zero.comp (Real.tendsto_sqrt_atTop.comp hV)
  have hh := (hA.inv₀ hA₀).mul hi
  simpa only [residualScale,mul_inv_rev,mul_zero,mul_comm,Function.comp_apply] using hh

lemma residualDerivativeKernel_measurable (j : ℕ) : Measurable (residualDerivativeKernel j) := by
  unfold residualDerivativeKernel
  exact (by fun_prop : Measurable (fun t : ℝ => t^j)).div (by fun_prop)

lemma residualDerivativeKernel_continuousAt (j : ℕ) {t : ℝ} (ht : 0 < t) :
    ContinuousAt (residualDerivativeKernel j) t := by
  unfold residualDerivativeKernel
  apply ContinuousAt.div (by fun_prop) (by fun_prop)
  exact (Real.sinh_pos_iff.mpr (by positivity)).ne'

lemma residualDerivativeKernel_interval_bound (j : ℕ) {ρ T t : ℝ}
    (hρ : 0 < ρ) (ht : ρ ≤ t) (htT : t ≤ T) :
    |residualDerivativeKernel j t| ≤ T^j/Real.sinh (Real.pi*ρ/2) := by
  have ht0 : 0 < t := hρ.trans_le ht
  have hs : 0 < Real.sinh (Real.pi*ρ/2) := Real.sinh_pos_iff.mpr (by positivity)
  have hst : 0 < Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
  unfold residualDerivativeKernel
  rw [abs_div,abs_of_nonneg (pow_nonneg ht0.le _),abs_of_pos hst]
  calc
    _ ≤ T^j/Real.sinh (Real.pi*t/2) :=
      div_le_div_of_nonneg_right (pow_le_pow_left₀ ht0.le htT j) hst.le
    _ ≤ _ := div_le_div_of_nonneg_left (pow_nonneg (ht0.le.trans htT) _) hs
      (Real.sinh_le_sinh.mpr (by nlinarith [Real.pi_pos]))

lemma residualPeak_cell_upper {A lo x : ℝ} (hlo : 0 < lo) (hA : lo ≤ A)
    (l : ℕ) (hx : |x| ≤ Real.pi/(2*A)) :
    residualPeak A l+x ≤ ((l:ℝ)+1)*Real.pi/lo := by
  have hApos := hlo.trans_le hA
  have hupper : residualPeak A l+x ≤ ((l:ℝ)+1)*Real.pi/A := by
    have hh := (abs_le.mp hx).2
    have he : residualPeak A l+Real.pi/(2*A) = ((l:ℝ)+1)*Real.pi/A := by
      unfold residualPeak periodicFrequency
      field_simp
      <;> ring
    linarith
  exact hupper.trans (div_le_div_of_nonneg_left (by positivity) hlo hA)

lemma residualPeak_lower {A hi : ℝ} (hA : 0 < A) (hhi : A ≤ hi) (l : ℕ) :
    Real.pi/(2*hi) ≤ residualPeak A l := by
  have hhi0 := hA.trans_le hhi
  calc
    _ ≤ Real.pi/(2*A) := div_le_div_of_nonneg_left Real.pi_pos.le (by positivity) (by linarith)
    _ ≤ residualPeak A l := by
      unfold residualPeak periodicFrequency
      have hh : (1:ℝ) ≤ 2*(l:ℝ)+1 := by linarith [Nat.cast_nonneg (α := ℝ) l]
      simpa only [one_mul] using mul_le_mul_of_nonneg_right hh (by positivity : 0 ≤ Real.pi/(2*A))

end NeuralGeneralization.OnlineLowerTanh
