import NeuralGeneralization.GaussianTranslatePacking
import NeuralGeneralization.GaussianLinear

/-! Finite Gaussian strip packings for actual families of linear forms. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianTranslatePacking

variable {I J : Type*} [Fintype I] [Fintype J]

def rowForm (a y : I → ℝ) : ℝ := ∑ i, a i*y i

def rowStrip (a : J → I → ℝ) (t : ℝ) : Set (I → ℝ) :=
  {y | ∀ j, |rowForm (a j) y| < t}

lemma rowForm_sub (a x y : I → ℝ) : rowForm a (x-y) = rowForm a x-rowForm a y := by
  simp only [rowForm, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

lemma rowForm_neg (a y : I → ℝ) : rowForm a (-y) = -rowForm a y := by
  simp only [rowForm, Pi.neg_apply, mul_neg, Finset.sum_neg_distrib]

lemma rowForm_smul (a y : I → ℝ) (s : ℝ) : rowForm a (s • y) = s*rowForm a y := by
  unfold rowForm
  simp only [Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

lemma measurableSet_rowStrip (a : J → I → ℝ) (t : ℝ) : MeasurableSet (rowStrip a t) := by
  have h := MeasurableSet.iInter (fun j : J =>
    measurableSet_lt (show Measurable (fun y : I → ℝ => |rowForm (a j) y|) by
      unfold rowForm
      fun_prop) (measurable_const (a := t)))
  convert h using 1
  ext y
  simp only [rowStrip, Set.mem_setOf_eq, Set.mem_iInter]

omit [Fintype J] in
lemma rowStrip_symmetric (a : J → I → ℝ) (t : ℝ) (y : I → ℝ) :
    -y ∈ rowStrip a t ↔ y ∈ rowStrip a t := by
  simp only [rowStrip, Set.mem_setOf_eq, rowForm_neg, abs_neg]

/-- The mass bound is derived from the actual product-Gaussian linear-form
tails and a finite union bound. -/
theorem gaussian_rowStrip_halfmass (a : J → I → ℝ) (V t : ℝ)
    (hV : 0 < V) (ht : 0 ≤ t) (hvar : ∀ j, (∑ i, a j i^2) ≤ V)
    (hsize : 4*(Fintype.card J : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1) :
    (1:ℝ)/2 ≤ (standardGaussian (I := I)).real (rowStrip a t) := by
  have htail (j : J) : (standardGaussian (I := I)).real
      {y | t ≤ |rowForm (a j) y|} ≤ 2*Real.exp (-t^2/(2*V)) := by
    apply GaussianTail.gaussian_linear_form_abs_tail (fun _ : I => 1) (a j) V t hV ht
    simpa only [NNReal.coe_one, mul_one] using hvar j
  have hcompl : (rowStrip a t)ᶜ = ⋃ j : J, {y | t ≤ |rowForm (a j) y|} := by
    ext y
    simp only [rowStrip, Set.mem_compl_iff, Set.mem_setOf_eq, not_forall, not_lt,
      Set.mem_iUnion]
  have hunion := measureReal_iUnion_fintype_le (μ := standardGaussian (I := I))
    (fun j : J => {y | t ≤ |rowForm (a j) y|})
  have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => htail j)
  have hbound := hunion.trans hsum
  rw [← hcompl, probReal_compl_eq_one_sub (measurableSet_rowStrip a t)] at hbound
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hbound
  nlinarith only [hbound, hsize]

omit [Fintype J] in
/-- Separation in at least one actual row makes the Gaussian strip
translates disjoint. -/
theorem rowStrip_translates_disjoint (a : J → I → ℝ) (t : ℝ) (x y : I → ℝ)
    (hsep : ∃ j, 2*t ≤ |rowForm (a j) (x-y)|) :
    Disjoint (translateSet x (rowStrip a t)) (translateSet y (rowStrip a t)) := by
  rw [Set.disjoint_left]
  intro z hzx hzy
  obtain ⟨j, hj⟩ := hsep
  have hx : |rowForm (a j) (z-x)| < t := hzx j
  have hy : |rowForm (a j) (z-y)| < t := hzy j
  have heq : rowForm (a j) (x-y) = rowForm (a j) (z-y)-rowForm (a j) (z-x) := by
    simp only [rowForm_sub]
    ring
  rw [heq] at hj
  have htri := abs_sub (rowForm (a j) (z-y)) (rowForm (a j) (z-x))
  linarith

/-- A direct finite entropy bound for row-seminorm packings, using the
literal Gaussian product and actual Euclidean energies of the centers. -/
theorem gaussian_row_packing {K : Type*} [Fintype K]
    (a : J → I → ℝ) (x : K → I → ℝ) (V t R : ℝ)
    (hV : 0 < V) (ht : 0 ≤ t) (hvar : ∀ j, (∑ i, a j i^2) ≤ V)
    (hsize : 4*(Fintype.card J : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (hsep : ∀ i j, i ≠ j → ∃ l, 2*t ≤ |rowForm (a l) (x i-x j)|)
    (hR : ∀ j, (∑ i, x j i ^ 2) ≤ R) :
    (Fintype.card K : ℝ) ≤ 2*Real.exp (R/2) :=
  gaussian_translate_packing x (rowStrip a t) (measurableSet_rowStrip a t)
    (rowStrip_symmetric a t) (gaussian_rowStrip_halfmass a V t hV ht hvar hsize)
    (fun _ _ hij => rowStrip_translates_disjoint a t _ _ (hsep _ _ hij)) R hR

/-- The same packing bound at arbitrary scale, expressed in the original
row seminorm rather than in rescaled Gaussian coordinates. -/
theorem gaussian_row_packing_scaled {K : Type*} [Fintype K]
    (a : J → I → ℝ) (x : K → I → ℝ) (V t R s : ℝ)
    (hV : 0 < V) (ht : 0 ≤ t) (hs : 0 ≤ s)
    (hvar : ∀ j, (∑ i, a j i^2) ≤ V)
    (hsize : 4*(Fintype.card J : ℝ)*Real.exp (-t^2/(2*V)) ≤ 1)
    (hsep : ∀ i j, i ≠ j → ∃ l, 2*t ≤ s*|rowForm (a l) (x i-x j)|)
    (hR : ∀ j, (∑ i, x j i ^ 2) ≤ R) :
    (Fintype.card K : ℝ) ≤ 2*Real.exp (s^2*R/2) := by
  apply gaussian_row_packing a (fun j => s • x j) V t (s^2*R) hV ht hvar hsize
  · intro i j hij
    obtain ⟨l, hl⟩ := hsep i j hij
    refine ⟨l, ?_⟩
    rw [← smul_sub, rowForm_smul, abs_mul, abs_of_nonneg hs]
    exact hl
  · intro j
    simp only [Pi.smul_apply, smul_eq_mul, mul_pow, ← Finset.mul_sum]
    exact mul_le_mul_of_nonneg_left (hR j) (sq_nonneg s)

/-- Explicit dual-Sudakov packing for the maximum of finitely many
rank-one seminorms. No covering or entropy estimate is a hypothesis. -/
theorem row_seminorm_packing_bound {K : Type*} [Fintype K] [Nonempty J]
    (a : J → I → ℝ) (x : K → I → ℝ) (V R ε : ℝ)
    (hV : 0 < V) (hε : 0 < ε) (hvar : ∀ j, (∑ i, a j i^2) ≤ V)
    (hsep : ∀ i j, i ≠ j → ∃ l, ε ≤ |rowForm (a l) (x i-x j)|)
    (hR : ∀ j, (∑ i, x j i ^ 2) ≤ R) :
    (Fintype.card K : ℝ) ≤
      2*Real.exp (4*R*V*Real.log (4*(Fintype.card J : ℝ))/ε^2) := by
  let C := 4*(Fintype.card J : ℝ)
  have hcard : (1 : ℝ) ≤ Fintype.card J := by exact_mod_cast Fintype.card_pos
  have hC : 0 < C := by dsimp only [C]; linarith
  have hlog : 0 ≤ Real.log C := Real.log_nonneg (by dsimp only [C]; linarith)
  let t := Real.sqrt (2*V*Real.log C)
  have ht : 0 ≤ t := Real.sqrt_nonneg _
  have ht2 : t^2 = 2*V*Real.log C := Real.sq_sqrt (by positivity)
  have hsize : C*Real.exp (-t^2/(2*V)) ≤ 1 := by
    have he : -t^2/(2*V) = -Real.log C := by rw [ht2]; field_simp
    rw [he, Real.exp_neg, Real.exp_log hC]
    exact le_of_eq (mul_inv_cancel₀ (ne_of_gt hC))
  let s := 2*t/ε
  have hs : 0 ≤ s := div_nonneg (by positivity) hε.le
  have hscaled := gaussian_row_packing_scaled a x V t R s hV ht hs hvar hsize
    (fun i j hij => by
      obtain ⟨l, hl⟩ := hsep i j hij
      refine ⟨l, ?_⟩
      have h := mul_le_mul_of_nonneg_left hl hs
      have he : s*ε = 2*t := by dsimp only [s]; field_simp
      rwa [he] at h) hR
  have he : s^2*R/2 = 4*R*V*Real.log C/ε^2 := by
    dsimp only [s]
    rw [div_pow, mul_pow, ht2]
    ring
  rw [he] at hscaled
  exact hscaled

end NeuralGeneralization.GaussianTranslatePacking
