import NeuralGeneralization.OnlineLowerTanhCodePartial
import NeuralGeneralization.OnlineLowerTanhPairReindex
import NeuralGeneralization.OnlineLowerTanhPairPeak

/-! # Literal signed conditioning mixtures of actual tanh parity coefficients

The mixture weights, signs, and shifts in the residual CLT are obtained here
from a finite partition of the physical input cube. No conditioning identity
or second-moment hypothesis is assumed.
-/
noncomputable section
open scoped BigOperators Topology
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

lemma paritySign_partition {d : ℕ} (A : Finset (Fin d)) (x : Cube d) :
    paritySign (subsetInputs A x)*paritySign (subsetInputs Aᶜ x)=paritySign x := by
  rw [paritySign_subsetInputs,paritySign_subsetInputs]
  exact Finset.prod_mul_prod_compl A (fun i => labelReal (x i))

lemma paritySign_join {d : ℕ} (A : Finset (Fin d))
    (y : Cube Aᶜ.card) (z : Cube A.card) :
    paritySign ((subsetCubeEquiv A).symm (y,z))=paritySign z*paritySign y := by
  simpa only [subsetInputs_join_selected,subsetInputs_join_outside] using
    (paritySign_partition A ((subsetCubeEquiv A).symm (y,z))).symm

/-- Conditioning the full-parity coefficient of any real ridge function on
its outside Boolean coordinates. -/
lemma ridgeParity_conditioning {d : ℕ} (f : ℝ → ℝ) (A : Finset (Fin d))
    (u : Fin d → ℝ) (b : ℝ) :
    ridgeParity f u b=cubeMean (fun y => paritySign y*
      ridgeParity f (subsetWeights A u) (incomingLinear (subsetWeights Aᶜ u) y+b)) := by
  unfold ridgeParity
  rw [cubeMean_join A]
  apply cubeMean_congr
  intro y
  rw [← cubeMean_const_mul]
  apply cubeMean_congr
  intro z
  rw [incomingLinear_join,paritySign_join]
  have he : b+(incomingLinear (subsetWeights A u) z+incomingLinear (subsetWeights Aᶜ u) y)=
      (incomingLinear (subsetWeights Aᶜ u) y+b)+incomingLinear (subsetWeights A u) z := by ring
  rw [he]
  ring

lemma ridgeParity_tanhSecond {n : ℕ} (u : Fin n → ℝ) (b : ℝ) :
    ridgeParity tanhSecond u b=parityBiasSecond u b := by
  simp [ridgeParity,cubeMean,parityBiasSecond,Cube]

lemma parityCorrelation_conditioning {d : ℕ} (A : Finset (Fin d))
    (u : Fin d → ℝ) (b : ℝ) :
    parityCorrelation u b=cubeMean (fun y => paritySign y*
      parityCorrelation (subsetWeights A u) (incomingLinear (subsetWeights Aᶜ u) y+b)) := by
  simpa only [ridgeParity_tanh] using ridgeParity_conditioning Real.tanh A u b

lemma parityBiasSecond_conditioning {d : ℕ} (A : Finset (Fin d))
    (u : Fin d → ℝ) (b : ℝ) :
    parityBiasSecond u b=cubeMean (fun y => paritySign y*
      parityBiasSecond (subsetWeights A u) (incomingLinear (subsetWeights Aᶜ u) y+b)) := by
  simpa only [ridgeParity_tanhSecond] using ridgeParity_conditioning tanhSecond A u b

lemma parityBiasSecond_equiv {n m : ℕ} (e : Fin n ≃ Fin m) (u : Fin m → ℝ) (b : ℝ) :
    parityBiasSecond (fun i => u (e i)) b=parityBiasSecond u b := by
  have hs := (coordinateCubeEquiv e).sum_comp (fun x : Cube n =>
    paritySign x*tanhSecond (b+incomingLinear (fun i => u (e i)) x))
  simp_rw [paritySign_coordinateCubeEquiv,incomingLinear_coordinateCubeEquiv] at hs
  have hc := Fintype.card_congr (coordinateCubeEquiv e)
  unfold parityBiasSecond
  rw [← hs,← hc]

/-- Number of actual outside Boolean configurations. -/
def outsideMixtureSize {d : ℕ} (A : Finset (Fin d)) : ℕ := Fintype.card (Cube Aᶜ.card)

def outsideMixtureCube {d : ℕ} (A : Finset (Fin d)) : Fin (outsideMixtureSize A) ≃ Cube Aᶜ.card :=
  (Fintype.equivFin (Cube Aᶜ.card)).symm

def outsideMixtureProbability {d : ℕ} (A : Finset (Fin d)) : Fin (outsideMixtureSize A) → ℝ :=
  fun _ => ((outsideMixtureSize A : ℕ) : ℝ)⁻¹

def outsideMixtureSign {d : ℕ} (A : Finset (Fin d)) : Fin (outsideMixtureSize A) → ℝ :=
  fun i => paritySign (outsideMixtureCube A i)

def outsideMixtureShift {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ) :
    Fin (outsideMixtureSize A) → ℝ :=
  fun i => incomingLinear (subsetWeights Aᶜ u) (outsideMixtureCube A i)

lemma outsideMixtureSize_pos {d : ℕ} (A : Finset (Fin d)) : 0 < outsideMixtureSize A :=
  Fintype.card_pos

lemma outsideMixtureProbability_nonneg {d : ℕ} (A : Finset (Fin d)) (i) :
    0 ≤ outsideMixtureProbability A i := by
  unfold outsideMixtureProbability
  positivity

lemma outsideMixture_sum {d : ℕ} (A : Finset (Fin d)) (f : Cube Aᶜ.card → ℝ) :
    (∑ i,outsideMixtureProbability A i*f (outsideMixtureCube A i))=cubeMean f := by
  unfold outsideMixtureProbability
  rw [← Finset.mul_sum,(outsideMixtureCube A).sum_comp f]
  simp [cubeMean,outsideMixtureSize,Cube]

lemma outsideMixtureProbability_sum {d : ℕ} (A : Finset (Fin d)) :
    ∑ i,outsideMixtureProbability A i=1 := by
  simpa only [mul_one,cubeMean_const] using outsideMixture_sum A (fun _ => 1)

lemma outsideMixtureSign_abs {d : ℕ} (A : Finset (Fin d)) (i) :
    |outsideMixtureSign A i|=1 := by
  unfold outsideMixtureSign paritySign
  rw [Finset.abs_prod]
  have hl (b : Bool) : |labelReal b|=1 := by cases b <;> norm_num [labelReal]
  simp only [hl,Finset.prod_const_one]

lemma outsideMixtureShift_secondMoment {d : ℕ} (A : Finset (Fin d)) (u : Fin d → ℝ) :
    (∑ i,outsideMixtureProbability A i*(outsideMixtureShift A u i)^2)=
      incomingEnergy (subsetWeights Aᶜ u) := by
  rw [show (∑ i,outsideMixtureProbability A i*(outsideMixtureShift A u i)^2)=
    cubeMean (fun y => (incomingLinear (subsetWeights Aᶜ u) y)^2) from
      outsideMixture_sum A (fun y => (incomingLinear (subsetWeights Aᶜ u) y)^2)]
  simpa only [zero_add,zero_pow (by decide : (2 : ℕ) ≠ 0)] using
    affine_secondMoment (subsetWeights Aᶜ u) 0

lemma outsideMixture_parityCorrelation {d : ℕ} (A : Finset (Fin d))
    (u : Fin d → ℝ) (b : ℝ) :
    (∑ i,outsideMixtureProbability A i*(outsideMixtureSign A i*
      parityCorrelation (subsetWeights A u) (outsideMixtureShift A u i+b)))=
      parityCorrelation u b := by
  rw [show (∑ i,outsideMixtureProbability A i*(outsideMixtureSign A i*
    parityCorrelation (subsetWeights A u) (outsideMixtureShift A u i+b)))=
    cubeMean (fun y => paritySign y*parityCorrelation (subsetWeights A u)
      (incomingLinear (subsetWeights Aᶜ u) y+b)) from outsideMixture_sum A (fun y => paritySign y*parityCorrelation (subsetWeights A u)
      (incomingLinear (subsetWeights Aᶜ u) y+b))]
  exact (parityCorrelation_conditioning A u b).symm

lemma outsideMixture_parityBiasSecond {d : ℕ} (A : Finset (Fin d))
    (u : Fin d → ℝ) (b : ℝ) :
    (∑ i,outsideMixtureProbability A i*(outsideMixtureSign A i*
      parityBiasSecond (subsetWeights A u) (outsideMixtureShift A u i+b)))=
      parityBiasSecond u b := by
  rw [show (∑ i,outsideMixtureProbability A i*(outsideMixtureSign A i*
    parityBiasSecond (subsetWeights A u) (outsideMixtureShift A u i+b)))=
    cubeMean (fun y => paritySign y*parityBiasSecond (subsetWeights A u)
      (incomingLinear (subsetWeights Aᶜ u) y+b)) from outsideMixture_sum A (fun y => paritySign y*parityBiasSecond (subsetWeights A u)
      (incomingLinear (subsetWeights Aᶜ u) y+b))]
  exact (parityBiasSecond_conditioning A u b).symm

end NeuralGeneralization.OnlineLowerTanh
