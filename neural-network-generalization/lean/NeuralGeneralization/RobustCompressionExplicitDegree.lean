import NeuralGeneralization.RobustCompressionParametersMain

/-!
# A deliberately loose, explicit degree for the formal resource formulas

This is a scalar accounting result for the actual finite-code resources.
It does not supply the analytic raw-compression construction. The bound is
intended to make the meaning of "polynomial" explicit, not to estimate a
practical sample size or to optimize any individual parameter dependence.
-/

namespace NeuralGeneralization.ConcreteModel.RobustCompressionInput

def DegreeAtMost (m : ℕ) (f : RobustCompressionInput → ℕ) : Prop :=
  ∃ A : ℕ, 0 < A ∧ ∀ p, f p ≤ A * p.size ^ m

namespace DegreeAtMost

theorem const (k : ℕ) : DegreeAtMost 0 (fun _ => k) := by
  exact ⟨k+1, by omega, fun p => by simp⟩

theorem dimension_growth : DegreeAtMost 1 RobustCompressionInput.dimension := by
  refine ⟨1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem depth_growth : DegreeAtMost 1 RobustCompressionInput.depth := by
  refine ⟨1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem energy_growth : DegreeAtMost 1 RobustCompressionInput.energy := by
  refine ⟨1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem inverseRadius_growth : DegreeAtMost 1 RobustCompressionInput.inverseRadius := by
  refine ⟨1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem inverseFailure_growth : DegreeAtMost 1 RobustCompressionInput.inverseFailure := by
  refine ⟨1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem mono {m : ℕ} {f g : RobustCompressionInput → ℕ}
    (hg : DegreeAtMost m g) (hfg : ∀ p, f p ≤ g p) : DegreeAtMost m f := by
  obtain ⟨A,hA,h⟩ := hg
  exact ⟨A,hA,fun p => (hfg p).trans (h p)⟩

theorem add {m n : ℕ} {f g : RobustCompressionInput → ℕ}
    (hf : DegreeAtMost m f) (hg : DegreeAtMost n g) :
    DegreeAtMost (max m n) (fun p => f p + g p) := by
  obtain ⟨A,hA,hF⟩ := hf
  obtain ⟨B,hB,hG⟩ := hg
  refine ⟨A+B,by omega,?_⟩
  intro p
  have hu : 1 ≤ p.size := by unfold size; omega
  have hm := Nat.pow_le_pow_right hu (Nat.le_max_left m n)
  have hn := Nat.pow_le_pow_right hu (Nat.le_max_right m n)
  calc
    _ ≤ A*p.size^m + B*p.size^n := Nat.add_le_add (hF p) (hG p)
    _ ≤ A*p.size^(max m n) + B*p.size^(max m n) :=
      Nat.add_le_add (Nat.mul_le_mul_left A hm) (Nat.mul_le_mul_left B hn)
    _ = _ := by ring

theorem mul {m n : ℕ} {f g : RobustCompressionInput → ℕ}
    (hf : DegreeAtMost m f) (hg : DegreeAtMost n g) :
    DegreeAtMost (m+n) (fun p => f p * g p) := by
  obtain ⟨A,hA,hF⟩ := hf
  obtain ⟨B,hB,hG⟩ := hg
  refine ⟨A*B,Nat.mul_pos hA hB,?_⟩
  intro p
  calc
    _ ≤ (A*p.size^m)*(B*p.size^n) := Nat.mul_le_mul (hF p) (hG p)
    _ = _ := by rw [pow_add]; ring

theorem pow {m : ℕ} {f : RobustCompressionInput → ℕ}
    (hf : DegreeAtMost m f) (k : ℕ) :
    DegreeAtMost (m*k) (fun p => f p ^ k) := by
  obtain ⟨A,hA,hF⟩ := hf
  refine ⟨A^k,Nat.pow_pos hA,?_⟩
  intro p
  calc
    _ ≤ (A*p.size^m)^k := Nat.pow_le_pow_left (hF p) k
    _ = _ := by rw [mul_pow, ← pow_mul]

theorem real_envelope {m : ℕ} {f : RobustCompressionInput → ℕ}
    (hf : DegreeAtMost m f) :
    ∃ A : ℝ, 0 < A ∧
      ∀ (d L : ℕ) (K radius failure : ℝ),
        0 ≤ K → 0 < radius → 0 < failure →
        (f (ofRealParameters d L K radius failure) : ℝ) ≤
          A * (1 + (d : ℝ) + L + K + radius⁻¹ + failure⁻¹) ^ m := by
  obtain ⟨A,hA,hf⟩ := hf
  refine ⟨(A : ℝ) * 4^m, mul_pos (by exact_mod_cast hA) (by positivity), ?_⟩
  intro d L K radius failure hK hr ha
  let p := ofRealParameters d L K radius failure
  have hbound : (f p : ℝ) ≤ (A : ℝ) * (p.size : ℝ)^m := by
    exact_mod_cast hf p
  have hceilK := Nat.ceil_lt_add_one hK
  have hceilr := Nat.ceil_lt_add_one (inv_nonneg.mpr hr.le)
  have hceila := Nat.ceil_lt_add_one (inv_nonneg.mpr ha.le)
  have hbase : (p.size : ℝ) ≤
      4 * (1 + (d : ℝ) + L + K + radius⁻¹ + failure⁻¹) := by
    simp only [p, ofRealParameters, size, Nat.cast_add, Nat.cast_one]
    have hd := Nat.cast_nonneg (α := ℝ) d
    have hL := Nat.cast_nonneg (α := ℝ) L
    have hrinv := inv_nonneg.mpr hr.le
    have hainv := inv_nonneg.mpr ha.le
    linarith
  calc
    _ ≤ (A : ℝ) * (p.size : ℝ)^m := hbound
    _ ≤ (A : ℝ) *
        (4 * (1 + (d : ℝ) + L + K + radius⁻¹ + failure⁻¹))^m :=
      mul_le_mul_of_nonneg_left
        (pow_le_pow_left₀ (Nat.cast_nonneg p.size) hbase m) (Nat.cast_nonneg A)
    _ = _ := by rw [mul_pow]; ring

end DegreeAtMost

open DegreeAtMost

theorem inverseLayerError_degree : DegreeAtMost 4 inverseLayerError := by
  exact (((const 1000).mul depth_growth).mul inverseFailure_growth).mul
    (inverseRadius_growth.pow 2)

theorem inverseLayerFailure_degree : DegreeAtMost 2 inverseLayerFailure := by
  exact ((const 100).mul depth_growth).mul inverseFailure_growth

theorem inverseSelectionError_degree : DegreeAtMost 4 inverseSelectionError := by
  exact (const 100).mul inverseLayerError_degree

theorem activeRank_degree : DegreeAtMost 15 activeRank := by
  exact ((((const 2).mul energy_growth).mul inverseLayerFailure_degree).mul
    (inverseSelectionError_degree.pow 3)).add (const 1)

theorem activeSquaredBound_degree : DegreeAtMost 19 activeSquaredBound := by
  exact ((const 4).mul
    (((const 8).mul energy_growth).add ((const 2).mul activeRank_degree))).mul
      inverseLayerError_degree

theorem sourceClip_degree : DegreeAtMost 38 sourceClip := by
  exact (((const 128).mul (activeRank_degree.add (const 1))).mul
    (activeSquaredBound_degree.add (const 1))).mul inverseLayerError_degree

theorem inverseKernelPrecision_degree : DegreeAtMost 23 inverseKernelPrecision := by
  exact ((const 128).mul (activeSquaredBound_degree.add (const 1))).mul
    inverseLayerError_degree

theorem readoutMoment_degree : DegreeAtMost 3 readoutMoment := by
  exact (((const 4).mul energy_growth).add (const 2)).mul inverseLayerFailure_degree

theorem readoutClip_degree : DegreeAtMost 4 readoutClip := by
  exact ((const 16).mul readoutMoment_degree).mul inverseRadius_growth

theorem bankSize_degree : DegreeAtMost 243 bankSize := by
  have h₁ := ((((const 10000).mul (sourceClip_degree.pow 4)).mul
    ((activeRank_degree.add (const 1)).pow 2)).mul
    (inverseKernelPrecision_degree.pow 2)).mul
    ((((dimension_growth.add activeRank_degree).add inverseLayerFailure_degree).add
      depth_growth).add (const 1))
  have h₂ := (((const 10000).mul (readoutClip_degree.pow 2)).mul
    (inverseRadius_growth.pow 2)).mul ((dimension_growth.add inverseLayerFailure_degree).add (const 1))
  exact (h₁.add h₂).add (const 1)

theorem widthBound_degree : DegreeAtMost 243 widthBound := by
  exact (bankSize_degree.add
    ((((const 2).mul depth_growth).mul (dimension_growth.add (const 1))).mul
      (activeRank_degree.add (const 1)))).add (const 1)

theorem gaussianSquaredBound_degree : DegreeAtMost 247 gaussianSquaredBound := by
  exact ((const 256).mul bankSize_degree).mul inverseLayerError_degree

theorem firstSquaredBound_degree : DegreeAtMost 5 firstSquaredBound := by
  exact ((const 4).mul (((const 4).mul energy_growth).add
    ((const 2).mul (dimension_growth.add (const 1))))).mul inverseLayerError_degree

theorem internalDepth_degree : DegreeAtMost 1 (fun p => p.depth - 2) :=
  depth_growth.mono (fun p => Nat.sub_le _ _)

theorem smallParameterCount_degree : DegreeAtMost 487 smallParameterCount := by
  exact ((widthBound_degree.mul (dimension_growth.add (const 1))).add
    ((internalDepth_degree.mul widthBound_degree).mul widthBound_degree)).add
    widthBound_degree

theorem smallSquaredBound_degree : DegreeAtMost 488 smallSquaredBound := by
  exact ((const 4).mul ((((const 4).mul widthBound_degree).mul energy_growth).add
    ((const 2).mul smallParameterCount_degree))).mul inverseFailure_growth

theorem largeWeightBound_degree : DegreeAtMost 247 largeWeightBound := by
  exact ((((firstSquaredBound_degree.add (const 1)).add
    ((activeSquaredBound_degree.add (const 1)).mul sourceClip_degree)).add
    (gaussianSquaredBound_degree.add (const 1))).add readoutClip_degree).add (const 1)

theorem weightBound_degree : DegreeAtMost 488 weightBound := by
  exact (smallSquaredBound_degree.add largeWeightBound_degree).add (const 1)

theorem inverseOutputError_degree : DegreeAtMost 1 inverseOutputError := by
  exact (const 8).mul inverseRadius_growth

/-- A literal degree for the concrete log-cardinality upper bound. -/
theorem entropyBudget_degree : DegreeAtMost 1219 entropyBudget := by
  exact smallParameterCount_degree.mul
    (((((const 4).add weightBound_degree).add inverseOutputError_degree).add
      dimension_growth).add
      ((internalDepth_degree.add (const 1)).mul
        ((widthBound_degree.mul (weightBound_degree.add (const 1))).add (const 1))))

theorem entropyBudget_real_degree :
    ∃ A : ℝ, 0 < A ∧
      ∀ (d L : ℕ) (K radius failure : ℝ),
        0 ≤ K → 0 < radius → 0 < failure →
        (entropyBudget (ofRealParameters d L K radius failure) : ℝ) ≤
          A * (1 + (d : ℝ) + L + K + radius⁻¹ + failure⁻¹) ^ 1219 :=
  entropyBudget_degree.real_envelope

end NeuralGeneralization.ConcreteModel.RobustCompressionInput

namespace NeuralGeneralization.RobustMainAssembly
open ConcreteModel RobustCompressionInput

/-- Explicit, deliberately unoptimized degree after actual posterior budgets. -/
theorem mainCompressionEntropy_degree :
    ∃ A : ℝ, 0 < A ∧
      ∀ (d C r : ℕ) (c ε U : ℝ),
        1 ≤ U → (d:ℝ)+1 ≤ U → (C:ℝ)+1 ≤ U → (r:ℝ)+1 ≤ U →
        0 < c → c ≤ U → c⁻¹ ≤ U → 0 < ε → ε < 1 → ε⁻¹ ≤ U →
        ((mainCompressionResources d C r c ε).entropyBudget : ℝ) ≤ A*U^10971 := by
  obtain ⟨A,hA,hbound⟩ := entropyBudget_real_degree
  refine ⟨A*(1000000000000000:ℝ)^1219, mul_pos hA (by positivity), ?_⟩
  intro d C r c ε U hU hd hC hr hc hcU hci hε hε1 hei
  have hR := mainCompressionRadius_pos d C r hc hε hε1
  have hK : 0 ≤ digitalMassPolynomial d C r c+1 := by
    have := digitalMassPolynomial_nonneg d C r c
    linarith
  have hh := hbound d (r+2) (digitalMassPolynomial d C r c+1)
    (mainCompressionRadius d C r c ε) (ε/12) hK hR (by positivity)
  have hbase := mainCompressionResourceBase_le d C r hU hd hC hr hc hcU hci hε hε1 hei
  have hbase0 : 0 ≤ 1+(d:ℝ)+(r+2:ℕ)+(digitalMassPolynomial d C r c+1)+
      (mainCompressionRadius d C r c ε)⁻¹+(ε/12)⁻¹ := by positivity
  calc
    _ ≤ A*(1+(d:ℝ)+(r+2:ℕ)+(digitalMassPolynomial d C r c+1)+
        (mainCompressionRadius d C r c ε)⁻¹+(ε/12)⁻¹)^1219 := hh
    _ ≤ A*(1000000000000000*U^9)^1219 :=
      mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hbase0 hbase 1219) hA.le
    _ = _ := by rw [mul_pow, ← pow_mul]; simp only [Nat.reduceMul, mul_assoc]

/-- An explicit degree for the exact finite-class statistical budget.
This is independent of the still-separate raw-compression existence proof. -/
theorem mainCompressionSampleBudget_degree :
    ∃ A : ℝ, 0 < A ∧
      ∀ (d C r : ℕ) (c ε δ : ℝ),
        0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
        2*(((mainCompressionResources d C r c ε).entropyBudget : ℝ)+
            Real.log (2/δ))/(ε/12)^2 ≤
          A*(mainPolynomialBase d C r c ε δ)^10974 := by
  obtain ⟨A,hA,hbound⟩ := mainCompressionEntropy_degree
  refine ⟨288*(A+1), by positivity, ?_⟩
  intro d C r c ε δ hc hε hε1 hδ hδ1
  let U := mainPolynomialBase d C r c ε δ
  obtain ⟨hU,hd,hC,hr,hcU,hci,hei,hlog⟩ :=
    mainPolynomialBase_bounds d C r hc hε hδ hδ1
  have hEnt := hbound d C r c ε U hU hd hC hr hc hcU hci hε hε1 hei
  have hUm : U^10971 ≤ U^10972 := pow_le_pow_right₀ hU (by norm_num)
  have hUone : U ≤ U^10972 := by
    simpa only [pow_one] using pow_le_pow_right₀ hU (show 1≤10972 by norm_num)
  have hsum : ((mainCompressionResources d C r c ε).entropyBudget : ℝ)+
      Real.log (2/δ) ≤ (A+1)*U^10972 := by
    have hm := mul_le_mul_of_nonneg_left hUm hA.le
    nlinarith
  have hεsq : (ε⁻¹)^2 ≤ U^2 :=
    pow_le_pow_left₀ (inv_nonneg.mpr hε.le) hei 2
  calc
    _ = 288*((mainCompressionResources d C r c ε).entropyBudget+
        Real.log (2/δ))*(ε⁻¹)^2 := by field_simp; ring
    _ ≤ 288*((A+1)*U^10972)*U^2 := by
      apply mul_le_mul
      · exact mul_le_mul_of_nonneg_left hsum (by norm_num)
      · exact hεsq
      · positivity
      · positivity
    _ = _ := by rw [show 10974=10972+2 by norm_num, pow_add]; ring

end NeuralGeneralization.RobustMainAssembly
