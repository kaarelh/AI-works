import ScalarPhysicalGain
import SubcriticalMarginGain

/-! Literal products of the sharp physical layer gains. The readout margin
bounds every partial normalization by the final gain and readout norm, even
when individual normalizations are arbitrarily small. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

def physicalLayerGain (P : ControlledMarginPath d H t f) (j : ℕ) : ℝ :=
  Real.sqrt (physicalVariance P:ℝ)*Real.sqrt (gaussianEntropyGain (physicalLayerCost P j))

def physicalGainProduct (P : ControlledMarginPath d H t f) (n : ℕ) : ℝ :=
  ∏j∈Finset.range n,physicalLayerGain P j

theorem physicalLayerGain_pos (P : ControlledMarginPath d H t f) (j : ℕ) :
    0<physicalLayerGain P j := by
  have hv : 0<(physicalVariance P:ℝ) := by
    exact_mod_cast (pos_iff_ne_zero.mpr (physicalVariance_ne_zero P))
  have hg : 0<gaussianEntropyGain (physicalLayerCost P j) :=
    lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le _)
  exact mul_pos (Real.sqrt_pos.mpr hv) (Real.sqrt_pos.mpr hg)

theorem physicalLayerGain_sq (P : ControlledMarginPath d H t f) (j : ℕ) :
    (physicalLayerGain P j)^2=(physicalVariance P:ℝ)*gaussianEntropyGain (physicalLayerCost P j) := by
  unfold physicalLayerGain
  rw [mul_pow,Real.sq_sqrt (NNReal.coe_nonneg _),
    Real.sq_sqrt (le_trans (by norm_num) (gaussianEntropyGain_one_le _))]

theorem physicalGainProduct_pos (P : ControlledMarginPath d H t f) (n : ℕ) :
    0<physicalGainProduct P n := Finset.prod_pos fun j _ => physicalLayerGain_pos P j

@[simp] theorem physicalGainProduct_zero (P : ControlledMarginPath d H t f) :
    physicalGainProduct P 0=1 := by simp [physicalGainProduct]

theorem physicalGainProduct_succ (P : ControlledMarginPath d H t f) (n : ℕ) :
    physicalGainProduct P (n+1)=physicalGainProduct P n*physicalLayerGain P n :=
  Finset.prod_range_succ _ n

theorem physicalGainProduct_log (P : ControlledMarginPath d H t f) (n : ℕ) :
    Real.log (physicalGainProduct P n)=∑j∈Finset.range n,physicalPathLogGain P j := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [physicalGainProduct_succ,Real.log_mul (physicalGainProduct_pos P n).ne'
      (physicalLayerGain_pos P n).ne',Finset.sum_range_succ,ih]
    rfl

theorem physicalGainProduct_exp (P : ControlledMarginPath d H t f) (n : ℕ) :
    physicalGainProduct P n=Real.exp (∑j∈Finset.range n,physicalPathLogGain P j) := by
  rw [← physicalGainProduct_log,Real.exp_log (physicalGainProduct_pos P n)]

theorem physical_pointwise_variance_gain (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j<H) (x : Cube d) :
    ‖P.feature (j+1) x‖^2≤‖P.feature j x‖^2*(physicalLayerGain P j)^2 := by
  rw [physicalLayerGain_sq]
  by_cases hn : 0<‖P.feature (j+1) x‖^2
  · letI := P.probability j hj
    have hmoment := controlledMarginPath_diagonal P j hj x
    have hsource := controlled_field_positive_source
      (scaledFeatureCoefficients t (P.feature j)) x (P.law j) (P.finiteKL j hj)
      (by rwa [← hmoment])
    rw [scaled_source_variance_eq] at hsource
    have hp : 0<‖P.feature j x‖^2 := by nlinarith [sq_nonneg t,sq_nonneg ‖P.feature j x‖]
    obtain ⟨R,hR,hf,hc,ht⟩ := controlled_field_subcritical_step
      (scaledFeatureCoefficients t (P.feature j)) x (P.law j) (P.finiteKL j hj)
      (physicalVariance P) hp (by rw [physicalVariance_coe]; exact scaled_source_variance_eq _ _ _)
    letI := hR
    have hg := scalar_physical_transition_gain R (physicalVariance P) (physicalVariance_ne_zero P)
      (physicalVariance_le_one P) hf hp.le hc
    rw [ht,←hmoment] at hg
    simpa only [physicalLayerCost,mul_assoc] using hg
  · have hz : ‖P.feature (j+1) x‖^2=0 := le_antisymm (not_lt.mp hn) (sq_nonneg _)
    rw [hz]
    exact mul_nonneg (sq_nonneg _) (mul_nonneg (NNReal.coe_nonneg _)
      (le_trans (by norm_num) (gaussianEntropyGain_one_le _)))

/-- Multiplicative variance propagation with no divisions by small partial
gains. -/
theorem physical_gain_product_variance (P : ControlledMarginPath d H t f)
    (s n : ℕ) (hsn : s≤n) (hnH : n≤H) (x : Cube d) :
    ‖P.feature n x‖^2*(physicalGainProduct P s)^2≤
      ‖P.feature s x‖^2*(physicalGainProduct P n)^2 := by
  apply Nat.le_induction (P := fun n _ => n≤H →
    ‖P.feature n x‖^2*(physicalGainProduct P s)^2≤
      ‖P.feature s x‖^2*(physicalGainProduct P n)^2) (fun _ => le_rfl) ?_ n hsn hnH
  intro j hsj ih hjH
  have hjlt : j<H := by omega
  have hprev := ih (by omega)
  have hnext := physical_pointwise_variance_gain P j hjlt x
  have h1 := mul_le_mul_of_nonneg_right hnext (sq_nonneg (physicalGainProduct P s))
  have h2 := mul_le_mul_of_nonneg_right hprev (sq_nonneg (physicalLayerGain P j))
  rw [physicalGainProduct_succ,mul_pow]
  nlinarith only [h1,h2]

/-- The original strict margin controls every hidden-layer normalization.
This estimate is uniform as t approaches zero. -/
theorem physical_partial_gain_readout_bound (P : ControlledMarginPath d H t f)
    (j : ℕ) (hj : j≤H) (hjpos : 1≤j) :
    physicalGainProduct P j≤2*‖P.readout‖*physicalGainProduct P H := by
  let x : Cube d := fun _ => false
  have hmargin : (1/2:ℝ)≤‖P.readout‖*‖P.feature H x‖ := by
    have hm := P.margin x
    have hl : labelReal (f x)*inner ℝ P.readout (P.feature H x)≤
        |inner ℝ P.readout (P.feature H x)| := by
      calc
        _ ≤ |labelReal (f x)*inner ℝ P.readout (P.feature H x)| := le_abs_self _
        _ = _ := by rw [abs_mul,abs_labelReal,one_mul]
    exact (le_of_lt (lt_of_lt_of_le hm hl)).trans (abs_real_inner_le_norm _ _)
  have hmargin2 : (1/4:ℝ)≤‖P.readout‖^2*‖P.feature H x‖^2 := by
    nlinarith [mul_nonneg (norm_nonneg P.readout) (norm_nonneg (P.feature H x))]
  have hg := physical_gain_product_variance P j H hj le_rfl x
  have hq : ‖P.feature j x‖^2≤1 := (feature_variance_le_max _ _).trans
    (controlledMarginPath_variance_le_one P j hj hjpos)
  have hprod := mul_le_mul_of_nonneg_right hq (sq_nonneg (physicalGainProduct P H))
  have hgn : ‖P.feature H x‖^2*(physicalGainProduct P j)^2≤(physicalGainProduct P H)^2 := by
    nlinarith
  have h1 := mul_le_mul_of_nonneg_right hmargin2 (sq_nonneg (physicalGainProduct P j))
  have h2 := mul_le_mul_of_nonneg_left hgn (sq_nonneg ‖P.readout‖)
  have hnon : 0≤2*‖P.readout‖*physicalGainProduct P H := by
    exact mul_nonneg (by positivity) (physicalGainProduct_pos P H).le
  nlinarith [physicalGainProduct_pos P j]

#print axioms physical_partial_gain_readout_bound
end ConditionalNonpolynomial.Analytic
