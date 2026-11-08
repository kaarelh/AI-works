import NeuralGeneralization.OnlineLowerTanhKernelMoments
import NeuralGeneralization.OnlineLowerTanhQuantitativeCell

/-! Quantitative cosine-cell estimates for the first two actual bias derivative kernels. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology Classical
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

def balancedMomentCellWindow (n j:ℕ) (a:ℝ) (l:ℕ) (y:ℝ) : ℝ :=
  residualCellWindow (fun _ : Fin n=>1) (fun _=>0) a (balancedCellScale n a) l
    (Real.pi/8) (residualDerivativeKernel j) y

lemma balancedMomentCellWindow_eq_cutoff (j:ℕ) {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a)
    (l : ℕ) (y : ℝ) :
    balancedMomentCellWindow n j a l y =
      cutoffCosinePower n a (residualPeak a l) (Real.pi/8) y *
        residualDerivativeKernel j (residualPeak a l+y*balancedCellScale n a) := by
  have he : y/(a*Real.sqrt (n : ℝ)) = y*balancedCellScale n a := by
    simp only [balancedCellScale, div_eq_mul_inv]
  have hc := balancedCellScale_cell_iff hn ha y
  unfold balancedMomentCellWindow residualCellWindow cutoffCosinePower truncatedCosinePower
  rw [he]
  simp only [mul_one, zero_mul, add_zero]
  rw [balancedCellScale_mul n ha.ne' y]
  by_cases hcut : Real.pi/8 ≤ residualPeak a l+y*balancedCellScale n a
  · by_cases hcell : |y/Real.sqrt (n : ℝ)| ≤ Real.pi/2
    · simp only [hcut, hcell, hc.mpr hcell, and_self, ite_true, Finset.prod_const, Finset.card_univ, Fintype.card_fin]
    · simp only [hcut, hcell, show ¬ |y*balancedCellScale n a| ≤ Real.pi/(2*a) from fun h => hcell (hc.mp h), false_and, ite_false, ite_true, zero_mul]
  · simp [hcut]

/-- Conditional Taylor estimate on the exact support of the cutoff power. -/
lemma balancedMomentCell_kernel_taylor (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) (y : ℝ)
    (hnonzero : cutoffCosinePower n a (residualPeak a l) (Real.pi/8) y ≠ 0) :
    |residualDerivativeKernel j (residualPeak a l+y*balancedCellScale n a) -
      (residualDerivativeKernel j (residualPeak a l) +
        balancedCellScale n a*residualWeightedKernelFirst j (residualPeak a l)*y)| ≤
      (residualMomentEnvelope l)*(balancedCellScale n a)^2*y^2 := by
  have ha0 : 0 < a := by linarith
  have hcut : Real.pi/8 ≤ residualPeak a l+y*balancedCellScale n a := by
    by_contra hh
    have he : y/(a*Real.sqrt (n : ℝ)) = y*balancedCellScale n a := by
      simp only [balancedCellScale, div_eq_mul_inv]
    simp [cutoffCosinePower, he, hh] at hnonzero
  have hcell : |y/Real.sqrt (n : ℝ)| ≤ Real.pi/2 := by
    by_contra hh
    simp [cutoffCosinePower, truncatedCosinePower, hh] at hnonzero
  have ht := residualWeightedKernel_cell_taylor j hj ha ha2 l
    ((balancedCellScale_cell_iff hn ha0 y).mpr hcell) hcut
  convert ht using 1 <;> ring


/-- Literal scaled-cell Taylor approximation with a cellwise summable
constant and a uniform `1/n` remainder. -/
theorem balancedMomentCellWindow_pointwise_error (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) (y : ℝ) :
    |balancedMomentCellWindow n j a l y - Real.exp (-y^2/2) *
      (residualDerivativeKernel j (residualPeak a l) +
        balancedCellScale n a * residualWeightedKernelFirst j (residualPeak a l) * y)| ≤
      (residualMomentEnvelope l)/(n : ℝ)*saddleTaylorMajorant y := by
  have ha0 : 0 < a := by linarith
  obtain ⟨hs0, hs1, hs2⟩ := balancedCellScale_bounds hn ha
  obtain ⟨h0, h1, h2⟩ := residualWeightedKernel_center_bounds j hj ha ha2 l
  rw [balancedMomentCellWindow_eq_cutoff j hn ha0 l y]
  apply saddle_kernel_pointwise_error n hn a (residualPeak a l) (Real.pi/8)
    (balancedCellScale n a) y (residualDerivativeKernel j (residualPeak a l))
    (residualWeightedKernelFirst j (residualPeak a l))
    (residualDerivativeKernel j (residualPeak a l+y*balancedCellScale n a))
    (residualMomentEnvelope l) ha0 (balancedCell_cutoff_gap ha ha2 l)
    (residualMomentEnvelope_nonneg l) hs0 hs1 hs2 h0 h1
  exact balancedMomentCell_kernel_taylor j hj hn ha ha2 l y

/-- The exact original sine-cell integral uses this same window. -/
theorem balancedMomentCell_integral (j:ℕ) {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a)
    (l : ℕ) (B θ : ℝ) :
    (∫ t : ℝ in Ioc ((l : ℝ)*(Real.pi/a)) (((l : ℝ)+1)*(Real.pi/a)) ∩ Ici (Real.pi/8),
      residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel j) t) =
      balancedCellScale n a * (-1 : ℝ)^(n*l) *
        ∫ y : ℝ, Real.sin (B*(residualPeak a l+y*balancedCellScale n a)+θ)*
          balancedMomentCellWindow n j a l y := by
  have hh := residual_cell_integral ha (balancedCellScale_pos hn ha)
    (fun _ : Fin n => 1) (fun _ => by decide) (fun _ => 0) l (Real.pi/8) B θ
    (residualDerivativeKernel j)
  simpa only [Nat.cast_one, mul_one, add_zero, Nat.sub_self, Nat.zero_div,
    Finset.sum_const_zero, zero_add, balancedMomentCellWindow] using hh


/-- The scaled cell approximation retains the complete first-order kernel
term and is uniform over every real external bias. -/
theorem balancedMomentCell_oscillatory_error (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) (B θ : ℝ) :
    |(∫ y : ℝ, Real.sin (B*(residualPeak a l+y*balancedCellScale n a)+θ)*
      balancedMomentCellWindow n j a l y) -
      (residualDerivativeKernel j (residualPeak a l)*Real.sqrt (2*Real.pi)*
        Real.exp (-(B*balancedCellScale n a)^2/2)*Real.sin (B*residualPeak a l+θ) +
       balancedCellScale n a*residualWeightedKernelFirst j (residualPeak a l)*Real.sqrt (2*Real.pi)*
        (B*balancedCellScale n a)*Real.exp (-(B*balancedCellScale n a)^2/2)*
          Real.cos (B*residualPeak a l+θ))| ≤
      (residualMomentEnvelope l)/(n : ℝ) * ∫ y : ℝ, saddleTaylorMajorant y := by
  have ha0 : 0 < a := by linarith
  obtain ⟨hs0, hs1, hs2⟩ := balancedCellScale_bounds hn ha
  obtain ⟨h0, h1, _⟩ := residualWeightedKernel_center_bounds j hj ha ha2 l
  have hh := saddle_kernel_oscillatory_error n hn a (residualPeak a l) (Real.pi/8)
    (balancedCellScale n a) (residualDerivativeKernel j (residualPeak a l))
    (residualWeightedKernelFirst j (residualPeak a l)) (residualMomentEnvelope l)
    (B*balancedCellScale n a) (B*residualPeak a l+θ)
    (fun y => residualDerivativeKernel j (residualPeak a l+y*balancedCellScale n a))
    ((residualDerivativeKernel_measurable j).comp (by fun_prop))
    ha0 (balancedCell_cutoff_gap ha ha2 l) (residualMomentEnvelope_nonneg l) hs0 hs1 hs2
    h0
    h1
    (balancedMomentCell_kernel_taylor j hj hn ha ha2 l)
  have he : (∫ y : ℝ, Real.sin (B*(residualPeak a l+y*balancedCellScale n a)+θ)*
      balancedMomentCellWindow n j a l y) =
      ∫ y : ℝ, cutoffCosinePower n a (residualPeak a l) (Real.pi/8) y *
        residualDerivativeKernel j (residualPeak a l+y*balancedCellScale n a) *
          Real.sin (B*balancedCellScale n a*y+(B*residualPeak a l+θ)) := by
    apply integral_congr_ae
    filter_upwards [] with y
    rw [balancedMomentCellWindow_eq_cutoff j hn ha0 l y]
    have harg : B*(residualPeak a l+y*balancedCellScale n a)+θ =
      B*balancedCellScale n a*y+(B*residualPeak a l+θ) := by ring
    rw [harg]
    ring
  rwa [he]

end NeuralGeneralization.OnlineLowerTanh
