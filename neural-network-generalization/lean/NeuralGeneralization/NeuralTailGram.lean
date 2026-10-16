import NeuralGeneralization.FarWalshGramBound
import NeuralGeneralization.NeuralTailCoherence

/-!
# Actual sharp sampled neural tail-Gram estimate

This module specializes the fully proved random-restriction theorem to
the actual arcsine network spectrum. The pointwise spectrum and far-pair
coherence are proved properties of that spectrum, not hypotheses.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical NeuralRadialSpectrum CubeFarPairs
attribute [local instance] Classical.propDecidable

variable {d r n : ℕ}

def neuralTailCoherence (d r : ℕ) : ℝ :=
  (d+1:ℝ)*Real.exp (-(r:ℝ)/4)+2/(2:ℝ)^r

lemma neuralTailCoherence_pos (d r : ℕ) : 0 < neuralTailCoherence d r := by
  unfold neuralTailCoherence
  positivity

/-- Inclusion monotonicity and permutation invariance identify a true
maximum eigenvalue of the actual high-degree neural tail. -/
lemma arcsine_tail_eigenvalue_le (depth : ℕ) (hr : r≤d)
    (S : Finset (Fin d)) (hS : r≤S.card) :
    walshCoefficients (arcsineProfile d depth) S ≤ levelWeight d depth r := by
  obtain ⟨T,hTS,hT⟩ := Finset.exists_subset_card_eq hS
  have hh := arcsineProfile_coefficient_antitone depth hTS
  have he : walshCoefficients (arcsineProfile d depth) T=levelWeight d depth r := by
    unfold levelWeight
    exact arcsineProfile_coefficient_eq_of_card_eq depth T (degreeSet d r)
      (hT.trans (degreeSet_card hr).symm)
  exact hh.trans_eq he

/-- Full quantitative, actual-network-spectrum tail-Gram probability.
The cutoff convention retains degrees at least `r`.
All matrix concentration and IID/selector transfer have been proved. -/
theorem arcsine_tail_gram_probability (depth : ℕ) (hr : 0<r) (hdim : 6*r≤d)
    (hn : 4≤n) (hnm : 2*n≤Fintype.card (ClippingCube d))
    (t : ℝ) (ht : 0<t) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => ∃ u : Fin n → ℝ,
        t*(∑ i,u i^2) <
          |finiteQuadratic (fun i j => arcsineTailCovariance d depth r (s i) (s j)) u-
            walshSpectralTail (arcsineProfile d depth) r*(∑ i,u i^2)|) ≤
      tailGramBudget d n (neuralTailCoherence d r) (levelWeight d depth r)
        (walshSpectralTail (arcsineProfile d depth) r)
        (∑ S∈Finset.univ.filter (fun S : Finset (Fin d) => r≤S.card),
          walshCoefficients (arcsineProfile d depth) S^2)/t^2+
        (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ)+
        (n:ℝ)^2*nearProbabilityBound d := by
  let w : Finset (Fin d) → ℝ := fun S =>
    if r≤S.card then walshCoefficients (arcsineProfile d depth) S else 0
  have hw (S : Finset (Fin d)) : 0≤w S := by
    dsimp only [w]
    split_ifs
    · exact arcsineProfile_coefficient_nonneg d depth S
    · exact le_rfl
  have hmax (S : Finset (Fin d)) : w S≤levelWeight d depth r := by
    dsimp only [w]
    split_ifs with h
    · exact arcsine_tail_eigenvalue_le depth (by omega) S h
    · exact levelWeight_nonneg d depth r
  have hfar (x y : ClippingCube d) (hxy : far x y) :
      |walshKernel w x y|≤neuralTailCoherence d r := by
    obtain ⟨h₁,h₂⟩ := far_real_bounds hxy
    exact NeuralTailCoherence.arcsineTailCovariance_far depth hr hdim x y h₁ h₂
  have htrace : (∑ S,w S)=walshSpectralTail (arcsineProfile d depth) r := by
    simp only [w,walshSpectralTail,Finset.sum_filter]
  have hs2 : (∑ S,w S^2)=
      ∑ S∈Finset.univ.filter (fun S : Finset (Fin d)=>r≤S.card),
        walshCoefficients (arcsineProfile d depth) S^2 := by
    rw [Finset.sum_filter]
    apply Finset.sum_congr rfl
    intro S _
    dsimp only [w]
    split_ifs <;> simp
  have hh := far_walsh_gram_probability w hw (neuralTailCoherence d r)
    (levelWeight d depth r) t (neuralTailCoherence_pos d r)
    (levelWeight_nonneg d depth r) ht hmax hfar (by omega) hn hnm
  simpa only [htrace,hs2,w,arcsineTailCovariance] using hh

end NeuralGeneralization.RandomRestriction
