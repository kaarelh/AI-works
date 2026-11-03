import NeuralGeneralization.FiniteUnionConditioning

/-! The localized paper's exact component-entropy identity, for the literal
raw restrictions. Zero-mass cells contribute zero and need no normalization. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace NeuralGeneralization.FiniteUnionConditioning
variable {W I : Type*} [MeasurableSpace W] [Fintype I] [Nonempty I]

/-- Shannon entropy is at most the logarithm of the alphabet size, including
zero weights. The proof uses the scalar logarithm inequality directly. -/
theorem entropy_le_log_card (q : I → ℝ) (hq : ∀ i,0 ≤ q i) (hsum : ∑ i,q i = 1) :
    (∑ i,-q i*Real.log (q i)) ≤ Real.log (Fintype.card I:ℝ) := by
  classical
  let M : ℝ := Fintype.card I
  have hM : 0 < M := by dsimp [M]; exact_mod_cast Fintype.card_pos
  have hpoint (i : I) : -q i*Real.log (q i) ≤
      q i*Real.log M+1/M-q i := by
    by_cases hz : q i = 0
    · simp only [hz,neg_zero,zero_mul,zero_add,sub_zero]
      positivity
    · have hp : 0 < q i := lt_of_le_of_ne (hq i) (Ne.symm hz)
      have hl := Real.log_le_sub_one_of_pos (div_pos (by norm_num : (0:ℝ)<1) (mul_pos hM hp))
      have heq : Real.log (1/(M*q i)) = -Real.log M-Real.log (q i) := by
        rw [Real.log_div (by norm_num) (by positivity),Real.log_one,Real.log_mul hM.ne' hp.ne']
        ring
      rw [heq] at hl
      have hh := mul_le_mul_of_nonneg_left hl hp.le
      have hid : q i*(1/(M*q i)-1) = 1/M-q i := by field_simp
      rw [hid] at hh
      nlinarith
  have hh := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hpoint i)
  simp only [Finset.sum_sub_distrib,Finset.sum_add_distrib,← Finset.sum_mul,hsum,one_mul,
    Finset.sum_const,Finset.card_univ,nsmul_eq_mul] at hh
  have hid : (Fintype.card I:ℝ)*(1/M)=1 := by dsimp [M] at *; field_simp
  rw [hid] at hh
  simpa using hh

/-- The entropy chain rule specialized to a measurable partition of a raw
conditioning event. The component divergences are Mathlib's actual KL. -/
theorem component_entropy_identity (μ : Measure W) [IsProbabilityMeasure μ]
    (E : I → Set W) (hE : ∀ j,MeasurableSet (E j))
    (hd : Pairwise (fun i j => Disjoint (E i) (E j)))
    (hpos : 0 < μ.real (⋃ j,E j)) :
    let q := fun j => μ.real (E j)/μ.real (⋃ i,E i)
    (∑ j,q j*(klDiv (cond μ (E j)) μ).toReal) =
      (klDiv (cond μ (⋃ j,E j)) μ).toReal + ∑ j,-q j*Real.log (q j) := by
  classical
  let U := μ.real (⋃ j,E j)
  let q := fun j => μ.real (E j)/U
  have hU : μ (⋃ j,E j) ≠ 0 := by
    intro hz
    simp only [Measure.real,hz,ENNReal.toReal_zero] at hpos
    exact (lt_irrefl 0) hpos
  have hlogU : 0 ≤ -Real.log U := neg_nonneg.mpr (Real.log_nonpos hpos.le measureReal_le_one)
  have hfull : (klDiv (cond μ (⋃ j,E j)) μ).toReal = -Real.log U := by
    rw [RobustPosterior.klDiv_cond_eq μ _ (MeasurableSet.iUnion hE) hU,ENNReal.toReal_ofReal hlogU]
  have hpoint (j : I) : q j*(klDiv (cond μ (E j)) μ).toReal =
      q j*(-Real.log U) + -q j*Real.log (q j) := by
    by_cases hz : μ.real (E j) = 0
    · simp [q,hz]
    · have hp : 0 < μ.real (E j) := lt_of_le_of_ne measureReal_nonneg (Ne.symm hz)
      have hne : μ (E j) ≠ 0 := by
        intro hh
        apply hz
        simp [Measure.real,hh]
      have hl : 0 ≤ -Real.log (μ.real (E j)) := neg_nonneg.mpr (Real.log_nonpos hp.le measureReal_le_one)
      rw [RobustPosterior.klDiv_cond_eq μ _ (hE j) hne,ENNReal.toReal_ofReal hl]
      dsimp [q]
      rw [Real.log_div hp.ne' hpos.ne']
      ring
  change (∑ j,q j*(klDiv (cond μ (E j)) μ).toReal) = _
  simp_rw [hpoint]
  rw [Finset.sum_add_distrib,← Finset.sum_mul]
  have hsum : (∑ j,q j) = 1 := sum_weight μ E hE hd hpos
  rw [hsum,one_mul,hfull]

/-- The exact entropy overhead of assigning a witnessing exception region
is at most log M. No component target-cylinder premise occurs. -/
theorem component_entropy_bound (μ : Measure W) [IsProbabilityMeasure μ]
    (E : I → Set W) (hE : ∀ j,MeasurableSet (E j))
    (hd : Pairwise (fun i j => Disjoint (E i) (E j)))
    (hpos : 0 < μ.real (⋃ j,E j)) :
    (∑ j,(μ.real (E j)/μ.real (⋃ i,E i))*(klDiv (cond μ (E j)) μ).toReal) ≤
      (klDiv (cond μ (⋃ j,E j)) μ).toReal + Real.log (Fintype.card I:ℝ) := by
  rw [component_entropy_identity μ E hE hd hpos]
  apply add_le_add le_rfl
  exact entropy_le_log_card _ (fun j => div_nonneg measureReal_nonneg hpos.le) (sum_weight μ E hE hd hpos)

end NeuralGeneralization.FiniteUnionConditioning
