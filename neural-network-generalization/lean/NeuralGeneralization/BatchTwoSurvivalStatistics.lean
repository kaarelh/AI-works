import NeuralGeneralization.BatchTwoRelativeStatistics

/-! Exact IID survival for finite families of measurable error sets. This
zero-training-error bound keeps the full exponent, with no relative-loss loss. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoSurvivalStatistics
open CompressionSampling
variable {X H : Type*} [MeasurableSpace X] [Fintype H]

def survives (A : Set X) (n : ℕ) : Set (Fin n → X) := {s | ∀ i, s i ∉ A}

theorem measurable_survives (A : Set X) (hA : MeasurableSet A) (n : ℕ) :
    MeasurableSet (survives A n) := by
  simp only [survives,Set.setOf_forall]
  exact MeasurableSet.iInter fun i => hA.compl.preimage (measurable_pi_apply i)

theorem survives_probability (D : Measure X) [IsProbabilityMeasure D]
    (A : Set X) (hA : MeasurableSet A) (n : ℕ) :
    (iidSamples D n).real (survives A n)=(1-D.real A)^n := by
  have hset : survives A n=Set.pi Set.univ (fun _ : Fin n => Aᶜ) := by ext s; simp [survives]
  rw [hset]
  unfold Measure.real iidSamples
  rw [Measure.pi_pi]
  simp only [Finset.prod_const,Finset.card_univ,Fintype.card_fin,ENNReal.toReal_pow]
  rw [← Measure.real,measureReal_compl hA]
  simp [Measure.real]

theorem survives_probability_le_exp (D : Measure X) [IsProbabilityMeasure D]
    (A : Set X) (hA : MeasurableSet A) (n : ℕ) :
    (iidSamples D n).real (survives A n) ≤ Real.exp (-(n : ℝ)*D.real A) := by
  rw [survives_probability D A hA]
  have h := Real.add_one_le_exp (-D.real A)
  have hp : 0 ≤ 1-D.real A := by have hh := measureReal_le_one (μ := D) (s := A); linarith
  calc
    _ ≤ (Real.exp (-D.real A))^n := pow_le_pow_left₀ hp (by linarith) _
    _ = _ := by rw [← Real.exp_nat_mul]; congr 1; ring

def badSamples (D : Measure X) (A : H → Set X) (n : ℕ) (τ : ℝ) : Set (Fin n → X) :=
  {s | ∃ h, τ < D.real (A h) ∧ s ∈ survives (A h) n}

theorem measurable_badSamples (D : Measure X) (A : H → Set X)
    (hA : ∀ h, MeasurableSet (A h)) (n : ℕ) (τ : ℝ) : MeasurableSet (badSamples D A n τ) := by
  classical
  have heq : badSamples D A n τ=⋃ h : H, if τ < D.real (A h) then survives (A h) n else ∅ := by
    ext s
    simp only [badSamples,Set.mem_setOf_eq,Set.mem_iUnion]
    apply exists_congr
    intro h
    split_ifs <;> simp_all
  rw [heq]
  apply MeasurableSet.iUnion
  intro h
  split_ifs
  · exact measurable_survives _ (hA h) _
  · exact MeasurableSet.empty

theorem badSamples_probability (D : Measure X) [IsProbabilityMeasure D]
    (A : H → Set X) (hA : ∀ h, MeasurableSet (A h)) (n : ℕ) (τ : ℝ) :
    (iidSamples D n).real (badSamples D A n τ) ≤ (Fintype.card H : ℝ)*Real.exp (-(n : ℝ)*τ) := by
  classical
  let E (h : H) : Set (Fin n → X) := if τ < D.real (A h) then survives (A h) n else ∅
  have heq : badSamples D A n τ=⋃ h, E h := by
    ext s
    simp only [badSamples,Set.mem_setOf_eq,Set.mem_iUnion,E]
    apply exists_congr
    intro h
    split_ifs <;> simp_all
  rw [heq]
  calc
    _ ≤ ∑ h : H, (iidSamples D n).real (E h) := measureReal_iUnion_fintype_le _
    _ ≤ ∑ _h : H, Real.exp (-(n : ℝ)*τ) := by
      apply Finset.sum_le_sum
      intro h _
      dsimp [E]
      split_ifs with hh
      · apply (survives_probability_le_exp D _ (hA h) n).trans
        apply Real.exp_le_exp.mpr
        nlinarith [Nat.cast_nonneg (α := ℝ) n]
      · simp [Real.exp_nonneg]
    _ = _ := by simp

theorem goodSamples_probability_log [Nonempty H] (D : Measure X) [IsProbabilityMeasure D]
    (A : H → Set X) (hA : ∀ h, MeasurableSet (A h)) (n : ℕ) {τ δ E : ℝ}
    (hδ : 0 < δ) (hcard : (Fintype.card H : ℝ) ≤ Real.exp E)
    (hsize : E+Real.log (1/δ) ≤ (n : ℝ)*τ) :
    1-δ ≤ (iidSamples D n).real (badSamples D A n τ)ᶜ := by
  have hp := badSamples_probability D A hA n τ
  have hmul := mul_le_mul_of_nonneg_right hcard (Real.exp_nonneg (-(n : ℝ)*τ))
  have he : Real.exp E*Real.exp (-(n : ℝ)*τ) ≤ δ := by
    rw [← Real.exp_add]
    calc
      _ ≤ Real.exp (Real.log δ) := by
        apply Real.exp_le_exp.mpr
        rw [one_div,Real.log_inv] at hsize
        linarith
      _ = _ := Real.exp_log hδ
  have hb := hp.trans (hmul.trans he)
  rw [measureReal_compl (measurable_badSamples D A hA n τ)]
  simp only [measureReal_univ_eq_one]
  linarith

end NeuralGeneralization.BatchTwoSurvivalStatistics
