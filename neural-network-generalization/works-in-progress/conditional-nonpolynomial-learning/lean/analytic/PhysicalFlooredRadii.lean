import PhysicalCanonicalRadii

/-! Polynomially bounded normalized radii. The floor is inverse polynomial
in the actual gain/readout resource, and adds at most one to the complete
physical squared-radius budget. -/
noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

def physicalRadiusFloor (P : ControlledMarginPath d H t f) : ℝ :=
  (((H:ℝ)+1)*(physicalPartialGainBound P+1))⁻¹

lemma physicalRadiusFloor_pos (P : ControlledMarginPath d H t f) : 0<physicalRadiusFloor P := by
  unfold physicalRadiusFloor
  positivity [physicalPartialGainBound_pos P]

lemma physicalRadiusFloor_le_one (P : ControlledMarginPath d H t f) : physicalRadiusFloor P≤1 := by
  have hP := (physicalPartialGainBound_pos P).le
  have hden : 1≤((H:ℝ)+1)*(physicalPartialGainBound P+1) := by
    nlinarith [Nat.cast_nonneg (α:=ℝ) H]
  exact (inv_le_one₀ (by positivity)).mpr hden

lemma physicalRadiusFloor_total (P : ControlledMarginPath d H t f) :
    (H:ℝ)*(physicalRadiusFloor P)^2*(physicalPartialGainBound P)^2≤1 := by
  let A := physicalPartialGainBound P
  let δ := physicalRadiusFloor P
  have hA : 0≤A := (physicalPartialGainBound_pos P).le
  have hδ : 0≤δ := (physicalRadiusFloor_pos P).le
  have hH : 0≤(H:ℝ) := Nat.cast_nonneg _
  have hid : δ*(((H:ℝ)+1)*(A+1))=1 := inv_mul_cancel₀ (by positivity)
  have hscaled : ((H:ℝ)+1)*(δ*A)≤1 := by
    have hn : 0≤δ*((H:ℝ)+1) := mul_nonneg hδ (by positivity)
    nlinarith only [hid,hn]
  have hscaled0 : 0≤((H:ℝ)+1)*(δ*A) := by positivity
  have hsquare := pow_le_pow_left₀ hscaled0 hscaled 2
  have hHsq : (H:ℝ)≤((H:ℝ)+1)^2 := by nlinarith [sq_nonneg (H:ℝ)]
  have hm := mul_le_mul_of_nonneg_right hHsq (sq_nonneg (δ*A))
  change (H:ℝ)*δ^2*A^2≤1
  nlinarith only [hsquare,hm]

def physicalFlooredRadius (P : ControlledMarginPath d H t f)
    (states : ℕ→CanonicalProgramState d) (j : ℕ) : ℝ :=
  max (physicalRadiusFloor P)
    (Real.sqrt (maxFeatureVariance (states j).feature)/physicalGainProduct P j)

lemma physicalFlooredRadius_floor (P : ControlledMarginPath d H t f)
    (states : ℕ→CanonicalProgramState d) (j : ℕ) :
    physicalRadiusFloor P≤physicalFlooredRadius P states j := le_max_left _ _

lemma physicalFlooredRadius_pos (P : ControlledMarginPath d H t f)
    (states : ℕ→CanonicalProgramState d) (j : ℕ) :
    0<physicalFlooredRadius P states j :=
  (physicalRadiusFloor_pos P).trans_le (physicalFlooredRadius_floor P states j)

lemma physicalFlooredRadius_contains (P : ControlledMarginPath d H t f)
    (states : ℕ→CanonicalProgramState d) (j : ℕ) (x : Cube d) :
    ‖(physicalGainProduct P j)⁻¹ • (states j).feature x‖≤physicalFlooredRadius P states j := by
  have hnorm : ‖(states j).feature x‖≤Real.sqrt (maxFeatureVariance (states j).feature) :=
    (Real.le_sqrt (norm_nonneg _) (maxFeatureVariance_nonneg _)).mpr (feature_variance_le_max _ _)
  rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos (physicalGainProduct_pos P j)]
  apply (mul_le_mul_of_nonneg_left hnorm (inv_nonneg.mpr (physicalGainProduct_pos P j).le)).trans
  change _≤max _ _
  convert le_max_right (physicalRadiusFloor P)
    (Real.sqrt (maxFeatureVariance (states j).feature)/physicalGainProduct P j) using 1 <;> ring

lemma physicalFlooredRadius_le_two (P : ControlledMarginPath d H t f) (hd : 1≤d)
    (S : Finset (Cube d)) (states : ℕ→CanonicalProgramState d)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y))
    (hstep : ∀j<H,PhysicalCanonicalProgramStep P S j (states j) (states (j+1)))
    (j : ℕ) (hj : j≤H) : physicalFlooredRadius P states j≤2 := by
  apply max_le ((physicalRadiusFloor_le_one P).trans (by norm_num))
  apply (div_le_iff₀ (physicalGainProduct_pos P j)).mpr
  apply Real.sqrt_le_iff.mpr ⟨by positivity [physicalGainProduct_pos P j],?_⟩
  have hh := physical_canonical_max_variance_gain P hd S states hzero hstep j hj
  nlinarith [sq_nonneg (physicalGainProduct P j)]

lemma physicalFlooredRadius_physical_square (P : ControlledMarginPath d H t f)
    (states : ℕ→CanonicalProgramState d) (j : ℕ) (hj : j≤H) :
    (t*physicalGainProduct P j*physicalFlooredRadius P states j)^2≤
      maxFeatureVariance (states j).feature+(physicalRadiusFloor P)^2*(physicalPartialGainBound P)^2 := by
  have ht2 : t^2≤1 := by nlinarith [P.scale_positive,P.scale_le_one]
  have hq := maxFeatureVariance_nonneg (states j).feature
  have hg := physicalGainProduct_le_partialBound P j hj
  have hgp := (physicalGainProduct_pos P j).le
  have hgsq := pow_le_pow_left₀ hgp hg 2
  unfold physicalFlooredRadius
  rcases le_total (physicalRadiusFloor P)
    (Real.sqrt (maxFeatureVariance (states j).feature)/physicalGainProduct P j) with hh|hh
  · rw [max_eq_right hh]
    have he : t*physicalGainProduct P j*
        (Real.sqrt (maxFeatureVariance (states j).feature)/physicalGainProduct P j)=
        t*Real.sqrt (maxFeatureVariance (states j).feature) := by
      field_simp [(physicalGainProduct_pos P j).ne']
    rw [he,mul_pow,Real.sq_sqrt hq]
    have hm := mul_le_mul_of_nonneg_right ht2 hq
    nlinarith [sq_nonneg (physicalRadiusFloor P),sq_nonneg (physicalPartialGainBound P)]
  · rw [max_eq_left hh]
    have hm := mul_le_mul_of_nonneg_left hgsq (sq_nonneg (physicalRadiusFloor P))
    have ht := mul_le_mul_of_nonneg_right ht2 (sq_nonneg (physicalGainProduct P j*physicalRadiusFloor P))
    nlinarith only [hm,ht,hq]

#print axioms physicalFlooredRadius_physical_square
#print axioms physicalFlooredRadius_le_two
end ConditionalNonpolynomial.Analytic
