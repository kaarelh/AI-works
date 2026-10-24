import NeuralGeneralization.BatchTwoNonGaussianCollision
import NeuralGeneralization.BatchTwoNonGaussianGroupCylinder

/-! Uniform normalized-sum small balls for every positive even group size.
Two iid half-sums collide in one short interval with probability linear in its
length. Reflection symmetry converts the difference to the desired sum. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian

theorem product_neg_preserving (ν : CoordinateLaw) (I : Type*) [Fintype I] :
    MeasurePreserving (fun z : I → ℝ => -z) (Measure.pi fun _ : I => ν.law)
      (Measure.pi fun _ : I => ν.law) := by
  refine ⟨by fun_prop,?_⟩
  apply Measure.ext
  intro E hE
  rw [Measure.map_apply (by fun_prop) hE]
  apply (ENNReal.toReal_eq_toReal_iff' (measure_ne_top _ _) (measure_ne_top _ _)).mp
  change (Measure.pi fun _ : I => ν.law).real ((fun z : I → ℝ => -z) ⁻¹' E)=
    (Measure.pi fun _ : I => ν.law).real E
  rw [ν.product_real_eq_integral _ (hE.preimage (by fun_prop)),ν.product_real_eq_integral E hE]
  have h := (Measure.measurePreserving_neg (volume : Measure (I → ℝ))).setIntegral_preimage_emb
    (MeasurableEquiv.neg (I → ℝ)).measurableEmbedding ν.productDensity E
  simpa only [ν.productDensity_neg] using h

def halfSum (m : ℕ) (z : Fin m → ℝ) : ℝ := (∑ i, z i)/Real.sqrt (m+m)

def collisionRadius (ν : CoordinateLaw) : ℝ := 8*subGaussianVariance ν+1

theorem collisionRadius_pos (ν : CoordinateLaw) : 0 < collisionRadius ν := by
  unfold collisionRadius
  have := subGaussianVariance_pos ν
  positivity

theorem halfSum_central_mass (ν : CoordinateLaw) {m : ℕ} (hm : 0 < m) :
    1/2 ≤ ((Measure.pi fun _ : Fin m => ν.law).map (halfSum m)).real
      (Icc (-collisionRadius ν) (collisionRadius ν)) := by
  let μ := Measure.pi fun _ : Fin m => ν.law
  let v := subGaussianVariance ν
  let R := collisionRadius ν
  have hv : 0 < v := subGaussianVariance_pos ν
  have hR : 0 < R := collisionRadius_pos ν
  have hs : 0 < Real.sqrt (m+m) := Real.sqrt_pos.mpr (by positivity)
  have hvar : v*(∑ _i : Fin m, (1/Real.sqrt (m+m))^2) ≤ v := by
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,div_pow,one_pow,
      Real.sq_sqrt (by positivity : (0 : ℝ) ≤ m+m)]
    have he : (m : ℝ)*(1/((m : ℝ)+m))=1/2 := by field_simp; ring
    rw [he]
    linarith
  have ht := actual_linear_abs_tail ν (fun _ : Fin m => 1/Real.sqrt (m+m)) v R hv hR.le hvar
  have hsum (z : Fin m → ℝ) : (∑ i, (1/Real.sqrt (m+m))*z i)=halfSum m z := by
    rw [←Finset.mul_sum]
    unfold halfSum
    ring
  simp only [hsum] at ht
  have he : 2*Real.exp (-R^2/(2*v)) ≤ 1/2 := by
    have h4 : 4 ≤ R^2/(2*v) := by
      apply (le_div_iff₀ (by positivity : 0 < 2*v)).mpr
      dsimp [R,collisionRadius,v]
      nlinarith [sq_nonneg (subGaussianVariance ν)]
    have hh : 4 ≤ Real.exp (R^2/(2*v)) := by linarith [Real.add_one_le_exp (R^2/(2*v))]
    rw [neg_div,Real.exp_neg]
    have hi := inv_le_inv₀ (Real.exp_pos _) (by norm_num : (0 : ℝ) < 4) |>.mpr hh
    nlinarith
  have htail : μ.real {z | R ≤ |halfSum m z|} ≤ 1/2 := ht.trans he
  have hset : MeasurableSet {z : Fin m → ℝ | |halfSum m z| ≤ R} := by
    apply measurableSet_le _ measurable_const
    unfold halfSum
    fun_prop
  have hcomp : μ.real {z : Fin m → ℝ | |halfSum m z| ≤ R}ᶜ ≤ 1/2 :=
    (measureReal_mono (by intro z hz; change ¬ |halfSum m z| ≤ R at hz; exact (lt_of_not_ge hz).le) (measure_ne_top _ _)).trans htail
  rw [probReal_compl_eq_one_sub hset] at hcomp
  rw [Measure.real,Measure.map_apply (by unfold halfSum; fun_prop) measurableSet_Icc]
  change 1/2 ≤ μ.real {z | -R ≤ halfSum m z ∧ halfSum m z ≤ R}
  have hEq : {z : Fin m → ℝ | -R ≤ halfSum m z ∧ halfSum m z ≤ R}=
      {z | |halfSum m z| ≤ R} := by ext z; exact abs_le.symm
  rw [hEq]
  linarith

def splitHalf (m : ℕ) : (Fin (m+m) → ℝ) ≃ᵐ ((Fin m → ℝ) × (Fin m → ℝ)) :=
  (MeasurableEquiv.piCongrLeft (fun _ : Fin (m+m) => ℝ) finSumFinEquiv).symm.trans
    (MeasurableEquiv.sumPiEquivProdPi (fun _ : Fin m ⊕ Fin m => ℝ))

theorem splitHalf_preserving (ν : CoordinateLaw) (m : ℕ) :
    MeasurePreserving (splitHalf m) (Measure.pi fun _ : Fin (m+m) => ν.law)
      ((Measure.pi fun _ : Fin m => ν.law).prod (Measure.pi fun _ : Fin m => ν.law)) :=
  (measurePreserving_sumPiEquivProdPi (fun _ : Fin m ⊕ Fin m => ν.law)).comp
    (measurePreserving_piCongrLeft (fun _ : Fin (m+m) => ν.law) finSumFinEquiv).symm

theorem halfSum_split (m : ℕ) (z : Fin (m+m) → ℝ) :
    normalizedSum (m+m) z=halfSum m (splitHalf m z).1+halfSum m (splitHalf m z).2 := by
  have hf (i : Fin m) : (splitHalf m z).1 i=z (Fin.castAdd m i) := rfl
  have hs (i : Fin m) : (splitHalf m z).2 i=z (Fin.natAdd m i) := rfl
  simp only [normalizedSum,halfSum,Fin.sum_univ_add,hf,hs,Nat.cast_add,add_div]

/-- Uniform linear small-ball bound for every even positive number of
independent coordinates. In particular the width threshold is independent of
ρ, which preserves logarithmic accuracy costs in target cylinders. -/
theorem even_normalized_sum_small_ball (ν : CoordinateLaw) {m : ℕ} (hm : 0 < m)
    {ρ : ℝ} (hρ : 0 < ρ) (hρ1 : ρ ≤ 1) :
    ρ/(8*(collisionRadius ν+1)) ≤
      (Measure.pi fun _ : Fin (m+m) => ν.law).real
        {z | |normalizedSum (m+m) z| ≤ ρ} := by
  let μ := Measure.pi fun _ : Fin m => ν.law
  let η := μ.map (halfSum m)
  have hf : Measurable (halfSum m) := by unfold halfSum; fun_prop
  haveI : IsProbabilityMeasure η := Measure.isProbabilityMeasure_map hf.aemeasurable
  have h := iid_difference_small_ball η (collisionRadius_pos ν).le hρ hρ1
    (halfSum_central_mass ν hm)
  have hmap : η.prod η=(μ.prod μ).map (Prod.map (halfSum m) (halfSum m)) :=
    Measure.map_prod_map μ μ hf hf
  rw [hmap,Measure.real,Measure.map_apply (hf.prodMap hf)
    (measurableSet_le (by fun_prop) measurable_const)] at h
  have href := (MeasurePreserving.id μ).prod (product_neg_preserving ν (Fin m))
  have hE : MeasurableSet {z : (Fin m → ℝ) × (Fin m → ℝ) |
      |halfSum m z.1-halfSum m z.2| ≤ ρ} := by
    apply measurableSet_le _ measurable_const
    unfold halfSum
    fun_prop
  have hr := href.measure_preimage hE.nullMeasurableSet
  have hn (z : Fin m → ℝ) : halfSum m (-z) = -halfSum m z := by
    simp [halfSum,Finset.sum_neg_distrib,neg_div]
  have hEq : (μ.prod μ).real {z : (Fin m → ℝ) × (Fin m → ℝ) |
      |halfSum m z.1+halfSum m z.2| ≤ ρ}=
      (μ.prod μ).real {z : (Fin m → ℝ) × (Fin m → ℝ) |
      |halfSum m z.1-halfSum m z.2| ≤ ρ} := by
    simpa only [Measure.real,Set.preimage_setOf_eq,Prod.map,Function.id_def,hn,sub_neg_eq_add]
      using congrArg ENNReal.toReal hr
  have hsplit := (splitHalf_preserving ν m).measure_preimage
    (show MeasurableSet {z : (Fin m → ℝ) × (Fin m → ℝ) |
      |halfSum m z.1+halfSum m z.2| ≤ ρ} by
      apply measurableSet_le _ measurable_const
      unfold halfSum
      fun_prop).nullMeasurableSet
  have he : (Measure.pi fun _ : Fin (m+m) => ν.law).real
      {z | |normalizedSum (m+m) z| ≤ ρ}=
      (μ.prod μ).real {z : (Fin m → ℝ) × (Fin m → ℝ) |
      |halfSum m z.1+halfSum m z.2| ≤ ρ} := by
    simpa only [Measure.real,Set.preimage_setOf_eq,halfSum_split] using congrArg ENNReal.toReal hsplit
  rw [he,hEq]
  exact h

end NeuralGeneralization.BatchTwoNonGaussian
