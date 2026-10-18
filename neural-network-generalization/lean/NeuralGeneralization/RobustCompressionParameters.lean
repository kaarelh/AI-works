import NeuralGeneralization.RobustCompressionGrid
import NeuralGeneralization.PolynomialGrowth

/-!
# Explicit polynomial resources for finite-noise entropy compression

All resources below are actual natural-number formulas. The precision inputs
are upper bounds on inverse radius and inverse failure probability. Fixed
integer constants deliberately overestimate the analytic choices.

This file proves their polynomial growth. It does not replace the separate
analytic theorem that uses these resources to construct a coupling.
-/

namespace NeuralGeneralization.ConcreteModel

structure RobustCompressionInput where
  dimension : ℕ
  depth : ℕ
  energy : ℕ
  inverseRadius : ℕ
  inverseFailure : ℕ

namespace RobustCompressionInput

def size (p : RobustCompressionInput) : ℕ :=
  1 + p.dimension + p.depth + p.energy + p.inverseRadius + p.inverseFailure

def PolynomialGrowth (f : RobustCompressionInput → ℕ) : Prop :=
  ∃ A m : ℕ, 0 < A ∧ ∀ p, f p ≤ A * p.size ^ m

namespace PolynomialGrowth

theorem const (k : ℕ) : PolynomialGrowth (fun _ => k) := by
  exact ⟨k+1, 0, by omega, fun p => by simp⟩

theorem dimension_growth : PolynomialGrowth RobustCompressionInput.dimension := by
  refine ⟨1, 1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem depth_growth : PolynomialGrowth RobustCompressionInput.depth := by
  refine ⟨1, 1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem energy_growth : PolynomialGrowth RobustCompressionInput.energy := by
  refine ⟨1, 1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem inverseRadius_growth : PolynomialGrowth RobustCompressionInput.inverseRadius := by
  refine ⟨1, 1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem inverseFailure_growth : PolynomialGrowth RobustCompressionInput.inverseFailure := by
  refine ⟨1, 1, by decide, ?_⟩
  intro p
  simp only [one_mul, pow_one, size]
  omega

theorem mono {f g : RobustCompressionInput → ℕ} (hg : PolynomialGrowth g)
    (hfg : ∀ p, f p ≤ g p) : PolynomialGrowth f := by
  obtain ⟨A,m,hA,h⟩ := hg
  exact ⟨A,m,hA,fun p => (hfg p).trans (h p)⟩

theorem add {f g : RobustCompressionInput → ℕ}
    (hf : PolynomialGrowth f) (hg : PolynomialGrowth g) :
    PolynomialGrowth (fun p => f p + g p) := by
  obtain ⟨A,m,hA,hF⟩ := hf
  obtain ⟨B,n,hB,hG⟩ := hg
  refine ⟨A+B,m+n,by omega,?_⟩
  intro p
  have hu : 1 ≤ p.size := by unfold size; omega
  have hm := Nat.pow_le_pow_right hu (show m ≤ m+n by omega)
  have hn := Nat.pow_le_pow_right hu (show n ≤ m+n by omega)
  calc
    _ ≤ A*p.size^m + B*p.size^n := Nat.add_le_add (hF p) (hG p)
    _ ≤ A*p.size^(m+n) + B*p.size^(m+n) :=
      Nat.add_le_add (Nat.mul_le_mul_left A hm) (Nat.mul_le_mul_left B hn)
    _ = _ := by ring

theorem mul {f g : RobustCompressionInput → ℕ}
    (hf : PolynomialGrowth f) (hg : PolynomialGrowth g) :
    PolynomialGrowth (fun p => f p * g p) := by
  obtain ⟨A,m,hA,hF⟩ := hf
  obtain ⟨B,n,hB,hG⟩ := hg
  refine ⟨A*B,m+n,Nat.mul_pos hA hB,?_⟩
  intro p
  calc
    _ ≤ (A*p.size^m)*(B*p.size^n) := Nat.mul_le_mul (hF p) (hG p)
    _ = _ := by rw [pow_add]; ring

theorem pow {f : RobustCompressionInput → ℕ}
    (hf : PolynomialGrowth f) (k : ℕ) :
    PolynomialGrowth (fun p => f p ^ k) := by
  obtain ⟨A,m,hA,hF⟩ := hf
  refine ⟨A^k,m*k,Nat.pow_pos hA,?_⟩
  intro p
  calc
    _ ≤ (A*p.size^m)^k := Nat.pow_le_pow_left (hF p) k
    _ = _ := by rw [mul_pow, ← pow_mul]

end PolynomialGrowth

def inverseLayerError (p : RobustCompressionInput) : ℕ :=
  1000 * p.depth * p.inverseFailure * p.inverseRadius ^ 2

def inverseLayerFailure (p : RobustCompressionInput) : ℕ :=
  100 * p.depth * p.inverseFailure

def inverseSelectionError (p : RobustCompressionInput) : ℕ :=
  100 * p.inverseLayerError

def activeRank (p : RobustCompressionInput) : ℕ :=
  2 * p.energy * p.inverseLayerFailure * p.inverseSelectionError ^ 3 + 1

def activeSquaredBound (p : RobustCompressionInput) : ℕ :=
  4 * (8 * p.energy + 2 * p.activeRank) * p.inverseLayerError

def sourceClip (p : RobustCompressionInput) : ℕ :=
  128 * (p.activeRank + 1) * (p.activeSquaredBound + 1) * p.inverseLayerError

def inverseKernelPrecision (p : RobustCompressionInput) : ℕ :=
  128 * (p.activeSquaredBound + 1) * p.inverseLayerError

def readoutMoment (p : RobustCompressionInput) : ℕ :=
  (4 * p.energy + 2) * p.inverseLayerFailure

def readoutClip (p : RobustCompressionInput) : ℕ :=
  16 * p.readoutMoment * p.inverseRadius

/-- Both the hidden-source and readout sampling requirements are included. -/
def bankSize (p : RobustCompressionInput) : ℕ :=
  10000 * p.sourceClip ^ 4 * (p.activeRank + 1) ^ 2 *
    p.inverseKernelPrecision ^ 2 *
    (p.dimension + p.activeRank + p.inverseLayerFailure + p.depth + 1) +
  10000 * p.readoutClip ^ 2 * p.inverseRadius ^ 2 *
    (p.dimension + p.inverseLayerFailure + 1) + 1

/-- Covers the message-entropy and small-width branches without division by K. -/
def widthBound (p : RobustCompressionInput) : ℕ :=
  p.bankSize + 2 * p.depth * (p.dimension + 1) * (p.activeRank + 1) + 1

def gaussianSquaredBound (p : RobustCompressionInput) : ℕ :=
  256 * p.bankSize * p.inverseLayerError

def firstSquaredBound (p : RobustCompressionInput) : ℕ :=
  4 * (4 * p.energy + 2 * (p.dimension + 1)) * p.inverseLayerError

def smallParameterCount (p : RobustCompressionInput) : ℕ :=
  robustParameterCount p.dimension p.widthBound (p.depth - 2)

def smallSquaredBound (p : RobustCompressionInput) : ℕ :=
  4 * (4 * p.widthBound * p.energy + 2 * p.smallParameterCount) * p.inverseFailure

/-- Replacing each square root by its squared argument plus one is harmless. -/
def largeWeightBound (p : RobustCompressionInput) : ℕ :=
  (p.firstSquaredBound + 1) +
    (p.activeSquaredBound + 1) * p.sourceClip +
    (p.gaussianSquaredBound + 1) + p.readoutClip + 1

def weightBound (p : RobustCompressionInput) : ℕ :=
  p.smallSquaredBound + p.largeWeightBound + 1

def inverseOutputError (p : RobustCompressionInput) : ℕ :=
  8 * p.inverseRadius

def entropyBudget (p : RobustCompressionInput) : ℕ :=
  robustGridEntropyBudget p.dimension p.widthBound (p.depth - 2)
    p.weightBound p.inverseOutputError

open PolynomialGrowth

theorem inverseLayerError_polynomial : PolynomialGrowth inverseLayerError := by
  exact (((const 1000).mul depth_growth).mul inverseFailure_growth).mul (inverseRadius_growth.pow 2)

theorem inverseLayerFailure_polynomial : PolynomialGrowth inverseLayerFailure := by
  exact ((const 100).mul depth_growth).mul inverseFailure_growth

theorem inverseSelectionError_polynomial : PolynomialGrowth inverseSelectionError := by
  exact (const 100).mul inverseLayerError_polynomial

theorem activeRank_polynomial : PolynomialGrowth activeRank := by
  exact ((((const 2).mul energy_growth).mul inverseLayerFailure_polynomial).mul
    (inverseSelectionError_polynomial.pow 3)).add (const 1)

theorem activeSquaredBound_polynomial : PolynomialGrowth activeSquaredBound := by
  exact ((const 4).mul
    (((const 8).mul energy_growth).add ((const 2).mul activeRank_polynomial))).mul
      inverseLayerError_polynomial

theorem sourceClip_polynomial : PolynomialGrowth sourceClip := by
  exact (((const 128).mul (activeRank_polynomial.add (const 1))).mul
    (activeSquaredBound_polynomial.add (const 1))).mul inverseLayerError_polynomial

theorem inverseKernelPrecision_polynomial : PolynomialGrowth inverseKernelPrecision := by
  exact ((const 128).mul (activeSquaredBound_polynomial.add (const 1))).mul
    inverseLayerError_polynomial

theorem readoutMoment_polynomial : PolynomialGrowth readoutMoment := by
  exact (((const 4).mul energy_growth).add (const 2)).mul inverseLayerFailure_polynomial

theorem readoutClip_polynomial : PolynomialGrowth readoutClip := by
  exact ((const 16).mul readoutMoment_polynomial).mul inverseRadius_growth

theorem bankSize_polynomial : PolynomialGrowth bankSize := by
  have h₁ := ((((const 10000).mul (sourceClip_polynomial.pow 4)).mul
    ((activeRank_polynomial.add (const 1)).pow 2)).mul
    (inverseKernelPrecision_polynomial.pow 2)).mul
    ((((dimension_growth.add activeRank_polynomial).add inverseLayerFailure_polynomial).add
      depth_growth).add (const 1))
  have h₂ := (((const 10000).mul (readoutClip_polynomial.pow 2)).mul
    (inverseRadius_growth.pow 2)).mul ((dimension_growth.add inverseLayerFailure_polynomial).add (const 1))
  exact (h₁.add h₂).add (const 1)

theorem widthBound_polynomial : PolynomialGrowth widthBound := by
  exact (bankSize_polynomial.add
    ((((const 2).mul depth_growth).mul (dimension_growth.add (const 1))).mul
      (activeRank_polynomial.add (const 1)))).add (const 1)

theorem gaussianSquaredBound_polynomial : PolynomialGrowth gaussianSquaredBound := by
  exact ((const 256).mul bankSize_polynomial).mul inverseLayerError_polynomial

theorem firstSquaredBound_polynomial : PolynomialGrowth firstSquaredBound := by
  exact ((const 4).mul (((const 4).mul energy_growth).add
    ((const 2).mul (dimension_growth.add (const 1))))).mul inverseLayerError_polynomial

theorem internalDepth_polynomial : PolynomialGrowth (fun p => p.depth - 2) :=
  depth_growth.mono (fun p => Nat.sub_le _ _)

theorem smallParameterCount_polynomial : PolynomialGrowth smallParameterCount := by
  exact ((widthBound_polynomial.mul (dimension_growth.add (const 1))).add
    ((internalDepth_polynomial.mul widthBound_polynomial).mul widthBound_polynomial)).add
    widthBound_polynomial

theorem smallSquaredBound_polynomial : PolynomialGrowth smallSquaredBound := by
  exact ((const 4).mul ((((const 4).mul widthBound_polynomial).mul energy_growth).add
    ((const 2).mul smallParameterCount_polynomial))).mul inverseFailure_growth

theorem largeWeightBound_polynomial : PolynomialGrowth largeWeightBound := by
  exact ((((firstSquaredBound_polynomial.add (const 1)).add
    ((activeSquaredBound_polynomial.add (const 1)).mul sourceClip_polynomial)).add
    (gaussianSquaredBound_polynomial.add (const 1))).add readoutClip_polynomial).add (const 1)

theorem weightBound_polynomial : PolynomialGrowth weightBound := by
  exact (smallSquaredBound_polynomial.add largeWeightBound_polynomial).add (const 1)

theorem inverseOutputError_polynomial : PolynomialGrowth inverseOutputError := by
  exact (const 8).mul inverseRadius_growth

/-- The final finite-grid log cardinality has a universal polynomial envelope. -/
theorem entropyBudget_polynomial : PolynomialGrowth entropyBudget := by
  exact smallParameterCount_polynomial.mul
    (((((const 4).add weightBound_polynomial).add inverseOutputError_polynomial).add
      dimension_growth).add
      ((internalDepth_polynomial.add (const 1)).mul
        ((widthBound_polynomial.mul (weightBound_polynomial.add (const 1))).add (const 1))))

theorem weightBound_pos (p : RobustCompressionInput) : 0 < p.weightBound := by
  unfold weightBound
  omega

theorem widthBound_pos (p : RobustCompressionInput) : 0 < p.widthBound := by
  unfold widthBound
  omega

theorem log_code_card_le_entropyBudget (p : RobustCompressionInput)
    (hR : 0 < p.inverseRadius) :
    Real.log (Fintype.card (RobustOutputCode p.dimension p.widthBound
      (p.depth - 2) p.weightBound p.inverseOutputError) : ℝ) ≤ p.entropyBudget := by
  exact robustOutputCode_log_card_le _ _ _ (weightBound_pos p)
    (Nat.mul_pos (by decide) hR)

/-- Canonical integer envelopes for the real compression parameters. -/
noncomputable def ofRealParameters (d L : ℕ) (K radius failure : ℝ) :
    RobustCompressionInput :=
  ⟨d, L, ⌈K⌉₊, ⌈radius⁻¹⌉₊, ⌈failure⁻¹⌉₊⟩

/-- Ceiling the three real resources preserves a universal polynomial bound. -/
theorem PolynomialGrowth.real_envelope {f : RobustCompressionInput → ℕ}
    (hf : PolynomialGrowth f) :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
      ∀ (d L : ℕ) (K radius failure : ℝ),
        0 ≤ K → 0 < radius → 0 < failure →
        (f (ofRealParameters d L K radius failure) : ℝ) ≤
          A * (1 + (d : ℝ) + L + K + radius⁻¹ + failure⁻¹) ^ m := by
  obtain ⟨A,m,hA,hf⟩ := hf
  refine ⟨(A : ℝ) * 4^m, mul_pos (by exact_mod_cast hA) (by positivity), m, ?_⟩
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

/-- A universal polynomial for the concrete resources, with no depth held fixed. -/
theorem entropyBudget_real_polynomial :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
      ∀ (d L : ℕ) (K radius failure : ℝ),
        0 ≤ K → 0 < radius → 0 < failure →
        (entropyBudget (ofRealParameters d L K radius failure) : ℝ) ≤
          A * (1 + (d : ℝ) + L + K + radius⁻¹ + failure⁻¹) ^ m :=
  entropyBudget_polynomial.real_envelope

/-- The actual finite code class has a width-independent universal polynomial
log cardinality after substituting the explicit compression resources. -/
theorem actual_code_log_card_real_polynomial :
    ∃ A : ℝ, 0 < A ∧ ∃ m : ℕ,
      ∀ (d L : ℕ) (K radius failure : ℝ),
        0 ≤ K → 0 < radius → 0 < failure →
        let p := ofRealParameters d L K radius failure
        Real.log (Fintype.card (RobustOutputCode p.dimension p.widthBound
          (p.depth - 2) p.weightBound p.inverseOutputError) : ℝ) ≤
          A * (1 + (d : ℝ) + L + K + radius⁻¹ + failure⁻¹) ^ m := by
  obtain ⟨A,hA,m,hbound⟩ := entropyBudget_real_polynomial
  refine ⟨A,hA,m,?_⟩
  intro d L K radius failure hK hr ha
  have hR : 0 < (ofRealParameters d L K radius failure).inverseRadius := by
    change 0 < ⌈radius⁻¹⌉₊
    exact Nat.ceil_pos.mpr (inv_pos.mpr hr)
  exact (log_code_card_le_entropyBudget _ hR).trans (hbound d L K radius failure hK hr ha)

end RobustCompressionInput

end NeuralGeneralization.ConcreteModel
