import NeuralGeneralization.OnlineLowerTanhKernelTaylor
import NeuralGeneralization.OnlineLowerSaddleTaylor
import NeuralGeneralization.OnlineLowerTanhResidualCellIntegral

/-! # Quantitative Gaussian cells for actual equal-coordinate tanh atoms -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology Classical
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

def balancedCellScale (n : ℕ) (a : ℝ) : ℝ := (a*Real.sqrt (n : ℝ))⁻¹

def balancedCellWindow (n : ℕ) (a : ℝ) (l : ℕ) (y : ℝ) : ℝ :=
  residualCellWindow (fun _ : Fin n => 1) (fun _ => 0) a (balancedCellScale n a) l
    (Real.pi/8) (residualDerivativeKernel 0) y

lemma balancedCellScale_eq_residual (n : ℕ) (a : ℝ) :
    balancedCellScale n a = residualScale a (fun _ : Fin n => 1) := by
  simp [balancedCellScale, residualScale, residualVariance]

lemma balancedCellScale_pos {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a) :
    0 < balancedCellScale n a := by unfold balancedCellScale; positivity

lemma balancedCellScale_bounds {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 1 ≤ a) :
    0 ≤ balancedCellScale n a ∧ balancedCellScale n a ≤ 1 ∧
      (balancedCellScale n a)^2 ≤ 1/(n : ℝ) := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have hs1 : 1 ≤ Real.sqrt (n : ℝ) := by
    simpa only [Real.sqrt_one] using Real.sqrt_le_sqrt hn1
  have hs := Real.sq_sqrt hnR.le
  have ha0 : 0 < a := by linarith
  have hprod : 1 ≤ a*Real.sqrt (n : ℝ) := by nlinarith
  refine ⟨(balancedCellScale_pos hn ha0).le, ?_, ?_⟩
  · unfold balancedCellScale
    exact inv_le_one_of_one_le₀ hprod
  · have hh := one_div_le_one_div_of_le hnR
      (show (n : ℝ) ≤ (a*Real.sqrt (n : ℝ))^2 by nlinarith [sq_nonneg (a-1)])
    simpa only [balancedCellScale, inv_pow, one_div] using hh

lemma balancedCellScale_mul (n : ℕ) {a : ℝ} (ha : a ≠ 0) (y : ℝ) :
    a * (y * balancedCellScale n a) = y / Real.sqrt (n : ℝ) := by
  unfold balancedCellScale
  field_simp

lemma balancedCellScale_cell_iff {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a) (y : ℝ) :
    |y*balancedCellScale n a| ≤ Real.pi/(2*a) ↔ |y/Real.sqrt (n : ℝ)| ≤ Real.pi/2 := by
  rw [← balancedCellScale_mul n ha.ne' y, abs_mul a (y*balancedCellScale n a), abs_of_pos ha]
  constructor
  · intro h
    have hh := (le_div_iff₀ (show 0 < 2*a by positivity)).mp h
    linarith
  · intro h
    apply (le_div_iff₀ (show 0 < 2*a by positivity)).mpr
    linarith

lemma balancedCell_cutoff_gap {a : ℝ} (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) :
    (1 : ℝ)/4 ≤ a*(residualPeak a l-Real.pi/8) := by
  have ha0 : 0 < a := by linarith
  have hid : a*residualPeak a l = (2*(l : ℝ)+1)*Real.pi/2 := by
    unfold residualPeak periodicFrequency
    field_simp
  have hl0 : (0 : ℝ) ≤ l := by positivity
  nlinarith [Real.pi_gt_three]

/-- Exact equality of the actual transported product and the quantitative
cutoff cosine saddle; no asymptotic or probability hypotheses enter. -/
lemma balancedCellWindow_eq_cutoff {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a)
    (l : ℕ) (y : ℝ) :
    balancedCellWindow n a l y =
      cutoffCosinePower n a (residualPeak a l) (Real.pi/8) y *
        residualDerivativeKernel 0 (residualPeak a l+y*balancedCellScale n a) := by
  have he : y/(a*Real.sqrt (n : ℝ)) = y*balancedCellScale n a := by
    simp only [balancedCellScale, div_eq_mul_inv]
  have hc := balancedCellScale_cell_iff hn ha y
  unfold balancedCellWindow residualCellWindow cutoffCosinePower truncatedCosinePower
  rw [he]
  simp only [mul_one, zero_mul, add_zero]
  rw [balancedCellScale_mul n ha.ne' y]
  by_cases hcut : Real.pi/8 ≤ residualPeak a l+y*balancedCellScale n a
  · by_cases hcell : |y/Real.sqrt (n : ℝ)| ≤ Real.pi/2
    · simp only [hcut, hcell, hc.mpr hcell, and_self, ite_true, Finset.prod_const, Finset.card_univ, Fintype.card_fin]
    · simp only [hcut, hcell, show ¬ |y*balancedCellScale n a| ≤ Real.pi/(2*a) from fun h => hcell (hc.mp h), false_and, ite_false, ite_true, zero_mul]
  · simp [hcut]

/-- Conditional Taylor estimate on the exact support of the cutoff power. -/
lemma balancedCell_kernel_taylor {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) (y : ℝ)
    (hnonzero : cutoffCosinePower n a (residualPeak a l) (Real.pi/8) y ≠ 0) :
    |residualDerivativeKernel 0 (residualPeak a l+y*balancedCellScale n a) -
      (residualDerivativeKernel 0 (residualPeak a l) +
        balancedCellScale n a*residualKernelFirst (residualPeak a l)*y)| ≤
      (512*Real.exp (-(l : ℝ)))*(balancedCellScale n a)^2*y^2 := by
  have ha0 : 0 < a := by linarith
  have hcut : Real.pi/8 ≤ residualPeak a l+y*balancedCellScale n a := by
    by_contra hh
    have he : y/(a*Real.sqrt (n : ℝ)) = y*balancedCellScale n a := by
      simp only [balancedCellScale, div_eq_mul_inv]
    simp [cutoffCosinePower, he, hh] at hnonzero
  have hcell : |y/Real.sqrt (n : ℝ)| ≤ Real.pi/2 := by
    by_contra hh
    simp [cutoffCosinePower, truncatedCosinePower, hh] at hnonzero
  have ht := residualKernel_cell_taylor ha ha2 l
    ((balancedCellScale_cell_iff hn ha0 y).mpr hcell) hcut
  convert ht using 1 <;> ring


/-- Literal scaled-cell Taylor approximation with a cellwise summable
constant and a uniform `1/n` remainder. -/
theorem balancedCellWindow_pointwise_error {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) (y : ℝ) :
    |balancedCellWindow n a l y - Real.exp (-y^2/2) *
      (residualDerivativeKernel 0 (residualPeak a l) +
        balancedCellScale n a * residualKernelFirst (residualPeak a l) * y)| ≤
      (512*Real.exp (-(l : ℝ)))/(n : ℝ)*saddleTaylorMajorant y := by
  have ha0 : 0 < a := by linarith
  obtain ⟨hs0, hs1, hs2⟩ := balancedCellScale_bounds hn ha
  obtain ⟨h0, h1, h2⟩ := residualKernel_center_bounds ha ha2 l
  rw [balancedCellWindow_eq_cutoff hn ha0 l y]
  apply saddle_kernel_pointwise_error n hn a (residualPeak a l) (Real.pi/8)
    (balancedCellScale n a) y (residualDerivativeKernel 0 (residualPeak a l))
    (residualKernelFirst (residualPeak a l))
    (residualDerivativeKernel 0 (residualPeak a l+y*balancedCellScale n a))
    (512*Real.exp (-(l : ℝ))) ha0 (balancedCell_cutoff_gap ha ha2 l)
    (by positivity) hs0 hs1 hs2 (h0.trans (by nlinarith [Real.exp_pos (-(l : ℝ))])) (h1.trans (by nlinarith [Real.exp_pos (-(l : ℝ))]))
  exact balancedCell_kernel_taylor hn ha ha2 l y

/-- The exact original sine-cell integral uses this same window. -/
theorem balancedCell_integral {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a)
    (l : ℕ) (B θ : ℝ) :
    (∫ t : ℝ in Ioc ((l : ℝ)*(Real.pi/a)) (((l : ℝ)+1)*(Real.pi/a)) ∩ Ici (Real.pi/8),
      residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel 0) t) =
      balancedCellScale n a * (-1 : ℝ)^(n*l) *
        ∫ y : ℝ, Real.sin (B*(residualPeak a l+y*balancedCellScale n a)+θ)*
          balancedCellWindow n a l y := by
  have hh := residual_cell_integral ha (balancedCellScale_pos hn ha)
    (fun _ : Fin n => 1) (fun _ => by decide) (fun _ => 0) l (Real.pi/8) B θ
    (residualDerivativeKernel 0)
  simpa only [Nat.cast_one, mul_one, add_zero, Nat.sub_self, Nat.zero_div,
    Finset.sum_const_zero, zero_add, balancedCellWindow] using hh


/-- The scaled cell approximation retains the complete first-order kernel
term and is uniform over every real external bias. -/
theorem balancedCell_oscillatory_error {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (l : ℕ) (B θ : ℝ) :
    |(∫ y : ℝ, Real.sin (B*(residualPeak a l+y*balancedCellScale n a)+θ)*
      balancedCellWindow n a l y) -
      (residualDerivativeKernel 0 (residualPeak a l)*Real.sqrt (2*Real.pi)*
        Real.exp (-(B*balancedCellScale n a)^2/2)*Real.sin (B*residualPeak a l+θ) +
       balancedCellScale n a*residualKernelFirst (residualPeak a l)*Real.sqrt (2*Real.pi)*
        (B*balancedCellScale n a)*Real.exp (-(B*balancedCellScale n a)^2/2)*
          Real.cos (B*residualPeak a l+θ))| ≤
      (512*Real.exp (-(l : ℝ)))/(n : ℝ) * ∫ y : ℝ, saddleTaylorMajorant y := by
  have ha0 : 0 < a := by linarith
  obtain ⟨hs0, hs1, hs2⟩ := balancedCellScale_bounds hn ha
  obtain ⟨h0, h1, _⟩ := residualKernel_center_bounds ha ha2 l
  have hh := saddle_kernel_oscillatory_error n hn a (residualPeak a l) (Real.pi/8)
    (balancedCellScale n a) (residualDerivativeKernel 0 (residualPeak a l))
    (residualKernelFirst (residualPeak a l)) (512*Real.exp (-(l : ℝ)))
    (B*balancedCellScale n a) (B*residualPeak a l+θ)
    (fun y => residualDerivativeKernel 0 (residualPeak a l+y*balancedCellScale n a))
    ((residualDerivativeKernel_measurable 0).comp (by fun_prop))
    ha0 (balancedCell_cutoff_gap ha ha2 l) (by positivity) hs0 hs1 hs2
    (h0.trans (by nlinarith [Real.exp_pos (-(l : ℝ))]))
    (h1.trans (by nlinarith [Real.exp_pos (-(l : ℝ))]))
    (balancedCell_kernel_taylor hn ha ha2 l)
  have he : (∫ y : ℝ, Real.sin (B*(residualPeak a l+y*balancedCellScale n a)+θ)*
      balancedCellWindow n a l y) =
      ∫ y : ℝ, cutoffCosinePower n a (residualPeak a l) (Real.pi/8) y *
        residualDerivativeKernel 0 (residualPeak a l+y*balancedCellScale n a) *
          Real.sin (B*balancedCellScale n a*y+(B*residualPeak a l+θ)) := by
    apply integral_congr_ae
    filter_upwards [] with y
    rw [balancedCellWindow_eq_cutoff hn ha0 l y]
    have harg : B*(residualPeak a l+y*balancedCellScale n a)+θ =
      B*balancedCellScale n a*y+(B*residualPeak a l+θ) := by ring
    rw [harg]
    ring
  rwa [he]

end NeuralGeneralization.OnlineLowerTanh
