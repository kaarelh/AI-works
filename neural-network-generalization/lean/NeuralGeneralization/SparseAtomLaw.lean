import NeuralGeneralization.SparseAtoms
import NeuralGeneralization.IIDLaw
import Mathlib.Probability.ProbabilityMassFunction.Constructions
import Mathlib.Probability.ProbabilityMassFunction.Integrals

/-!
# A concrete sparse-atom probability law and its barycenter

The law is an explicit finite PMF and the draws use the actual product
measure. Its integrals and averaged barycenter are exact. The companion
`SparseAtomMGF` module derives the exponential penalty for these same draws.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal NNReal

namespace NeuralGeneralization.SparseAtoms

open BoundedDual CompressionSampling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def pmf {G : ℝ} (hG : 0 < G) (lam : ι → ℝ) (hlam : entryL1 lam ≤ G) : PMF (Atom ι) :=
  PMF.ofFintype (fun a => ENNReal.ofReal (weight G lam a)) (by
    rw [← ENNReal.ofReal_sum_of_nonneg (fun a _ => weight_nonneg hG lam hlam a)]
    rw [sum_weight, ENNReal.ofReal_one])

variable [MeasurableSpace (Atom ι)]

def law {G : ℝ} (hG : 0 < G) (lam : ι → ℝ) (hlam : entryL1 lam ≤ G) :
    Measure (Atom ι) := (pmf hG lam hlam).toMeasure

instance law_probability {G : ℝ} (hG : 0 < G) (lam : ι → ℝ) (hlam : entryL1 lam ≤ G) :
    IsProbabilityMeasure (law hG lam hlam) := by
  unfold law
  infer_instance

variable [MeasurableSingletonClass (Atom ι)]

omit [DecidableEq ι] in
theorem integral_law {G : ℝ} (hG : 0 < G) (lam : ι → ℝ)
    (hlam : entryL1 lam ≤ G) (f : Atom ι → ℝ) :
    (∫ a, f a ∂law hG lam hlam) = ∑ a, weight G lam a * f a := by
  unfold law
  rw [PMF.integral_eq_sum]
  simp only [pmf, PMF.ofFintype_apply, ENNReal.toReal_ofReal (weight_nonneg hG lam hlam _),
    smul_eq_mul]

theorem integral_vector {G : ℝ} (hG : 0 < G) (lam : ι → ℝ)
    (hlam : entryL1 lam ≤ G) (i : ι) :
    (∫ a, vector G a i ∂law hG lam hlam) = lam i := by
  rw [integral_law]
  exact mean_vector hG lam i

theorem integral_pairing {G : ℝ} (hG : 0 < G) (lam z : ι → ℝ)
    (hlam : entryL1 lam ≤ G) :
    (∫ a, pairing (vector G a) z ∂law hG lam hlam) = pairing lam z := by
  rw [integral_law]
  exact mean_pairing hG lam z

omit [DecidableEq ι] in
theorem iid_eval_integral (ν : Measure (Atom ι)) [IsProbabilityMeasure ν]
    (s : ℕ) (i : Fin s) (f : Atom ι → ℝ) :
    (∫ a, f (a i) ∂iidSamples ν s) = ∫ x, f x ∂ν := by
  have hmap : (iidSamples ν s).map (fun a => a i) = ν :=
    (measurePreserving_eval (fun _ : Fin s => ν) i).map_eq
  have h := integral_map (μ := iidSamples ν s)
    (measurable_pi_apply i).aemeasurable (measurable_of_finite f).aestronglyMeasurable
  rw [hmap] at h
  exact h.symm

theorem integral_average_pairing {G : ℝ} (hG : 0 < G) (lam z : ι → ℝ)
    (hlam : entryL1 lam ≤ G) {s : ℕ} (hs : 0 < s) :
    (∫ a, pairing (average G s a) z ∂iidSamples (law hG lam hlam) s) = pairing lam z := by
  have hsR : (s : ℝ) ≠ 0 := by exact_mod_cast hs.ne'
  simp_rw [pairing_average]
  rw [integral_div, integral_finsetSum Finset.univ (fun _ _ => Integrable.of_finite)]
  have hi (j : Fin s) := iid_eval_integral (law hG lam hlam) s j
    (fun a => pairing (vector G a) z)
  simp_rw [hi, integral_pairing hG lam z hlam]
  simp only [Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]
  exact mul_div_cancel_left₀ _ hsR

end NeuralGeneralization.SparseAtoms

end
