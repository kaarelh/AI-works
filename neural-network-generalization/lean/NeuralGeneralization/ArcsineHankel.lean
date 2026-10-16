import NeuralGeneralization.ArcsineMoments
import NeuralGeneralization.HankelCoefficientBounds

/-! Positive coefficient Hankel matrices of the actual normalized arcsine
link, obtained from its exact positive moments. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set Matrix
open scoped BigOperators

/-- Entrywise integration preserves finite positive semidefiniteness. -/
theorem matrix_entrywise_integral_posSemidef {α ι : Type*} [MeasurableSpace α]
    [Fintype ι] (μ : Measure α) (M : α → Matrix ι ι ℝ)
    (hint : ∀ i j,Integrable (fun x => M x i j) μ)
    (hpos : ∀ᵐ x ∂μ,Matrix.PosSemidef (M x)) :
    Matrix.PosSemidef (fun i j => ∫ x,M x i j ∂μ) := by
  classical
  apply Matrix.posSemidef_iff_dotProduct_mulVec.mpr
  constructor
  · ext i j
    simp only [Matrix.conjTranspose_apply,star_trivial]
    apply integral_congr_ae
    filter_upwards [hpos] with x hx
    exact congrArg (fun A : Matrix ι ι ℝ => A i j) hx.1
  · intro v
    have hpoint : ∀ᵐ x ∂μ,0 ≤ star v ⬝ᵥ (M x *ᵥ v) := by
      filter_upwards [hpos] with x hx
      exact hx.dotProduct_mulVec_nonneg v
    have hnonneg := integral_nonneg_of_ae hpoint
    have hid : (∫ x,star v ⬝ᵥ (M x *ᵥ v) ∂μ) =
        star v ⬝ᵥ ((fun i j => ∫ x,M x i j ∂μ) *ᵥ v) := by
      simp only [dotProduct,Matrix.mulVec,Pi.star_apply,star_trivial,Finset.mul_sum]
      rw [integral_finsetSum]
      · apply Finset.sum_congr rfl
        intro i hi
        rw [integral_finsetSum]
        · apply Finset.sum_congr rfl
          intro j hj
          rw [integral_const_mul,integral_mul_const]
        · intro j hj
          exact ((hint i j).mul_const (v j)).const_mul (v i)
      · intro i hi
        exact integrable_finsetSum _ (fun j hj => ((hint i j).mul_const (v j)).const_mul (v i))
    rwa [hid] at hnonneg

/-- The nonnegative beta weight in the arcsine moment representation. -/
def arcsineMomentWeight (v : ℝ) : ℝ := (v*(1-v))^(-(1/2 : ℝ))

def arcsineSymmetricMoment (m : ℕ) (u v : ℝ) : ℝ :=
  ((u*Real.sqrt v)^m+(-u*Real.sqrt v)^m)*arcsineMomentWeight v

lemma arcsineMomentWeight_nonneg {v : ℝ} (hv : v ∈ Ioo (0 : ℝ) 1) :
    0 ≤ arcsineMomentWeight v := Real.rpow_nonneg (mul_nonneg hv.1.le (by linarith [hv.2])) _

lemma arcsineMomentWeight_integrable : IntegrableOn arcsineMomentWeight (Ioo 0 1) := by
  apply (real_beta_integrable (by norm_num : (0 : ℝ) < 1/2) (by norm_num : (0 : ℝ) < 1/2)).congr_fun _ measurableSet_Ioo
  intro v hv
  unfold arcsineMomentWeight
  rw [Real.mul_rpow hv.1.le (by linarith [hv.2])]
  norm_num

lemma arcsineSymmetricMoment_even (n : ℕ) (u : ℝ) {v : ℝ} (hv : 0 ≤ v) :
    arcsineSymmetricMoment (2*n) u v = 2*((u^2*v)^n)*arcsineMomentWeight v := by
  unfold arcsineSymmetricMoment
  rw [show -u*Real.sqrt v= -(u*Real.sqrt v) by ring,neg_pow,mul_pow,
    show (-1 : ℝ)^(2*n)=1 by rw [pow_mul]; norm_num]
  rw [pow_mul,mul_pow,pow_mul (Real.sqrt v) 2 n,Real.sq_sqrt hv]
  ring

lemma arcsineSymmetricMoment_odd (n : ℕ) (u v : ℝ) :
    arcsineSymmetricMoment (2*n+1) u v = 0 := by
  unfold arcsineSymmetricMoment
  rw [show -u*Real.sqrt v= -(u*Real.sqrt v) by ring,
    neg_pow,show (-1 : ℝ)^(2*n+1)= -1 by rw [pow_succ,pow_mul]; norm_num]
  ring

lemma arcsineSymmetricMoment_inner_even (n : ℕ) (u : ℝ) :
    (∫ v : ℝ in Ioo 0 1,arcsineSymmetricMoment (2*n) u v) =
      2*u^(2*n)*(Real.pi*arcsineDerivativeCoefficient n) := by
  have he : ∀ v ∈ Ioo (0 : ℝ) 1,arcsineSymmetricMoment (2*n) u v =
      (2*u^(2*n))*(v^((n : ℝ)-1/2)*(1-v)^(-(1/2 : ℝ))) := by
    intro v hv
    rw [arcsineSymmetricMoment_even n u hv.1.le]
    unfold arcsineMomentWeight
    rw [mul_pow,← pow_mul,Real.mul_rpow hv.1.le (by linarith [hv.2])]
    have hp : v^n*v^(-(1/2 : ℝ))=v^((n : ℝ)-1/2) := by
      rw [← Real.rpow_natCast v n,← Real.rpow_add hv.1]
      congr 1
    rw [show 2*(u^(2*n)*v^n)*(v^(-(1/2 : ℝ))*(1-v)^(-(1/2 : ℝ))) =
      2*u^(2*n)*(v^n*v^(-(1/2 : ℝ)))*(1-v)^(-(1/2 : ℝ)) by ring,hp]
    ring
  rw [setIntegral_congr_fun measurableSet_Ioo he,integral_const_mul,arcsineDerivativeCoefficient_beta]

lemma arcsineSymmetricMoment_inner_integrable (m : ℕ) (u : ℝ) :
    IntegrableOn (arcsineSymmetricMoment m u) (Ioo 0 1) := by
  rcases Nat.even_or_odd m with hm | hm
  · obtain ⟨n,hn⟩ := hm
    have hn' : m=2*n := by omega
    rw [hn']
    have hi : IntegrableOn (fun v : ℝ => (2*u^(2*n))*(v^((n : ℝ)+1/2-1)*(1-v)^((1/2 : ℝ)-1))) (Ioo 0 1) :=
      (real_beta_integrable (by positivity : 0 < (n : ℝ)+1/2)
        (by norm_num : (0 : ℝ) < 1/2)).const_mul _
    apply hi.congr_fun _ measurableSet_Ioo
    intro v hv
    rw [arcsineSymmetricMoment_even n u hv.1.le]
    unfold arcsineMomentWeight
    rw [Real.mul_rpow hv.1.le (by linarith [hv.2]),mul_pow,← pow_mul]
    have hp : v^n*v^(-(1/2 : ℝ))=v^((n : ℝ)-1/2) := by
      rw [← Real.rpow_natCast v n,← Real.rpow_add hv.1]
      congr 1
    rw [show 2*(u^(2*n)*v^n)*(v^(-(1/2 : ℝ))*(1-v)^(-(1/2 : ℝ))) =
      (2*u^(2*n))*(v^n*v^(-(1/2 : ℝ))*(1-v)^(-(1/2 : ℝ))) by ring,hp]
    congr 2 <;> congr 1 <;> ring
  · obtain ⟨n,hn⟩ := hm
    have hn' : m=2*n+1 := by omega
    rw [hn']
    change IntegrableOn (fun v : ℝ => arcsineSymmetricMoment (2*n+1) u v) (Ioo 0 1)
    simp only [arcsineSymmetricMoment_odd,integrableOn_zero]

lemma arcsineSymmetricMoment_outer_integrable (m : ℕ) :
    IntegrableOn (fun u : ℝ => ∫ v : ℝ in Ioo 0 1,arcsineSymmetricMoment m u v) (Ioo 0 1) := by
  rcases Nat.even_or_odd m with hm | hm
  · obtain ⟨n,hn⟩ := hm
    have hn' : m=2*n := by omega
    rw [hn']
    simp_rw [arcsineSymmetricMoment_inner_even]
    apply Continuous.integrableOn_Icc (by fun_prop) |>.mono_set Ioo_subset_Icc_self
  · obtain ⟨n,hn⟩ := hm
    have hn' : m=2*n+1 := by omega
    rw [hn']
    simp only [arcsineSymmetricMoment_odd,integral_zero,integrableOn_zero]


lemma arcsine_coefficient_symmetric_moment (m : ℕ) :
    IteratedArcsineSeries.coefficient 1 (m+1) = (1/Real.pi^2)*
      (∫ u : ℝ in Ioo 0 1,∫ v : ℝ in Ioo 0 1,arcsineSymmetricMoment m u v) := by
  rcases Nat.even_or_odd m with hm | hm
  · obtain ⟨n,hn⟩ := hm
    have hn' : m=2*n := by omega
    rw [hn',IteratedArcsineSeries.coefficient_one_odd,arcsineLinkCoefficient_moment]
    have he : (∫ u : ℝ in Ioo 0 1,∫ v : ℝ in Ioo 0 1,arcsineSymmetricMoment (2*n) u v) =
        2*(∫ u : ℝ in Ioo 0 1,∫ v : ℝ in Ioo 0 1,
          ((u^2*v)^n)*(v*(1-v))^(-(1/2 : ℝ))) := by
      rw [← integral_const_mul]
      apply setIntegral_congr_fun measurableSet_Ioo
      intro u hu
      dsimp only
      rw [← integral_const_mul]
      apply setIntegral_congr_fun measurableSet_Ioo
      intro v hv
      rw [arcsineSymmetricMoment_even n u hv.1.le]
      unfold arcsineMomentWeight
      ring
    rw [he]
    ring
  · obtain ⟨n,hn⟩ := hm
    have hn' : m=2*n+1 := by omega
    rw [hn',IteratedArcsineSeries.coefficient_even 1 _ (by omega)]
    simp only [arcsineSymmetricMoment_odd,integral_zero,mul_zero]

lemma arcsineSymmetricMoment_posSemidef (N : ℕ) (u : ℝ) {v : ℝ}
    (hv : v ∈ Ioo (0 : ℝ) 1) :
    Matrix.PosSemidef (fun i j : Fin N => arcsineSymmetricMoment (i.val+j.val) u v) := by
  let p : Fin N → ℝ := fun i => (u*Real.sqrt v)^i.val
  let q : Fin N → ℝ := fun i => (-u*Real.sqrt v)^i.val
  have hp := Matrix.posSemidef_vecMulVec_self_star p
  have hq := Matrix.posSemidef_vecMulVec_self_star q
  have h := (hp.add hq).smul (arcsineMomentWeight_nonneg hv)
  convert h using 1
  ext i j
  simp only [Matrix.smul_apply,Matrix.add_apply,Matrix.vecMulVec_apply,Pi.star_apply,
    star_trivial,smul_eq_mul,arcsineSymmetricMoment,p,q,pow_add]
  ring

/-- Every finite Hankel matrix of the actual normalized-arcsine power
coefficients is positive semidefinite. -/
theorem first_arcsine_positiveHankel :
    HankelCoefficientBounds.PositiveHankel (IteratedArcsineSeries.coefficient 1) := by
  intro N
  let M : ℝ → ℝ → Matrix (Fin N) (Fin N) ℝ :=
    fun u v i j => arcsineSymmetricMoment (i.val+j.val) u v
  have hi (u : ℝ) : Matrix.PosSemidef (fun i j : Fin N =>
      ∫ v : ℝ in Ioo 0 1,M u v i j) := by
    apply matrix_entrywise_integral_posSemidef
    · intro i j
      exact arcsineSymmetricMoment_inner_integrable _ u
    · filter_upwards [ae_restrict_mem measurableSet_Ioo] with v hv
      exact arcsineSymmetricMoment_posSemidef N u hv
  have ho : Matrix.PosSemidef (fun i j : Fin N =>
      ∫ u : ℝ in Ioo 0 1,∫ v : ℝ in Ioo 0 1,M u v i j) := by
    apply matrix_entrywise_integral_posSemidef
    · intro i j
      exact arcsineSymmetricMoment_outer_integrable _
    · exact Filter.Eventually.of_forall hi
  have h := ho.smul (by positivity : 0 ≤ (1/Real.pi^2 : ℝ))
  convert h using 1
  ext i j
  exact arcsine_coefficient_symmetric_moment _

end NeuralGeneralization
