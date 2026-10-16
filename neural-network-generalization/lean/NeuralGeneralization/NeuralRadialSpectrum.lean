import NeuralGeneralization.NeuralSpectrumMonotone
import NeuralGeneralization.WalshLevelKrawtchouk

/-! Exact degreewise forms of the actual permutation-invariant neural spectrum. -/
noncomputable section
namespace NeuralGeneralization.NeuralRadialSpectrum
open scoped BigOperators

def degreeSet (d j : ℕ) : Finset (Fin d) :=
  if h : j≤d then Classical.choose (Finset.exists_subset_card_eq
    (show j≤(Finset.univ : Finset (Fin d)).card by simpa using h)) else ∅

lemma degreeSet_card {d j : ℕ} (hj : j≤d) : (degreeSet d j).card=j := by
  unfold degreeSet
  rw [dif_pos hj]
  exact (Classical.choose_spec (Finset.exists_subset_card_eq
    (show j≤(Finset.univ : Finset (Fin d)).card by simpa using hj))).2

def levelWeight (d depth j : ℕ) : ℝ :=
  walshCoefficients (arcsineProfile d depth) (degreeSet d j)

lemma levelWeight_nonneg (d depth j : ℕ) : 0≤levelWeight d depth j :=
  arcsineProfile_coefficient_nonneg d depth _

lemma coefficient_eq_levelWeight {d : ℕ} (depth : ℕ) (S : Finset (Fin d)) :
    walshCoefficients (arcsineProfile d depth) S=levelWeight d depth S.card := by
  apply arcsineProfile_coefficient_eq_of_card_eq
  exact (degreeSet_card (by simpa using Finset.card_le_univ S)).symm

lemma card_level (d j : ℕ) :
    (Finset.univ.filter (fun S : Finset (Fin d)=>S.card=j)).card=d.choose j := by
  classical
  have he : (Finset.univ.filter (fun S : Finset (Fin d)=>S.card=j))=
      Finset.univ.powersetCard j := by
    ext S
    simp
  rw [he,Finset.card_powersetCard]
  simp

lemma sum_by_degree {M : Type*} [AddCommMonoid M] {d : ℕ} (f : Finset (Fin d)→M) :
    (∑ S,f S)=∑j∈Finset.range (d+1),∑S∈Finset.univ.filter (fun S : Finset (Fin d)=>S.card=j),f S := by
  classical
  symm
  apply Finset.sum_fiberwise_of_maps_to
  intro S _
  apply Finset.mem_range.mpr
  have hh : S.card≤d := by simpa using Finset.card_le_univ S
  omega

lemma sum_card_function {M : Type*} [AddCommMonoid M] (d : ℕ) (f : ℕ→M) :
    (∑S : Finset (Fin d),f S.card)=∑j∈Finset.range (d+1),(d.choose j) • f j := by
  classical
  rw [sum_by_degree]
  apply Finset.sum_congr rfl
  intro j hj
  calc
    _ = ∑S∈Finset.univ.filter (fun S : Finset (Fin d)=>S.card=j),f j := by
      apply Finset.sum_congr rfl
      intro S hS
      rw [(Finset.mem_filter.mp hS).2]
    _ = _ := by rw [Finset.sum_const,card_level]

lemma levelWeight_total (d depth : ℕ) :
    (∑j∈Finset.range (d+1),(d.choose j:ℝ)*levelWeight d depth j)=1 := by
  have hs : (∑S : Finset (Fin d),walshCoefficients (arcsineProfile d depth) S)=1 := by
    have h := walshExpansion_coefficients (arcsineProfile d depth) (fun _=>true)
    simpa [walshExpansion,walshCharacter,cubeCoordinateSign,arcsineProfile_one] using h
  simp_rw [coefficient_eq_levelWeight] at hs
  rw [sum_card_function] at hs
  simpa only [nsmul_eq_mul] using hs

lemma spectral_tail_le_one (d depth r : ℕ) :
    walshSpectralTail (arcsineProfile d depth) r≤1 := by
  classical
  have hs : (∑S : Finset (Fin d),walshCoefficients (arcsineProfile d depth) S)=1 := by
    simp_rw [coefficient_eq_levelWeight]
    rw [sum_card_function]
    simpa only [nsmul_eq_mul] using levelWeight_total d depth
  rw [← hs]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
    (fun S _ _=>arcsineProfile_coefficient_nonneg d depth S)

lemma tailCovariance_degree_sum (d depth r : ℕ) (x y : ClippingCube d) :
    arcsineTailCovariance d depth r x y=
      ∑j∈Finset.range (d+1),if r≤j then
        levelWeight d depth j*WalshLevelKrawtchouk.levelKernel j x y else 0 := by
  classical
  unfold arcsineTailCovariance walshKernel featureKernel
  rw [sum_by_degree]
  apply Finset.sum_congr rfl
  intro j hj
  by_cases hrj : r≤j
  · rw [if_pos hrj]
    unfold WalshLevelKrawtchouk.levelKernel
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro S hS
    have hcard := (Finset.mem_filter.mp hS).2
    dsimp only
    rw [coefficient_eq_levelWeight,hcard,if_pos hrj]
    ring
  · rw [if_neg hrj]
    apply Finset.sum_eq_zero
    intro S hS
    have hcard := (Finset.mem_filter.mp hS).2
    dsimp only
    rw [hcard,if_neg hrj]
    ring

lemma spectral_tail_degree_sum (d depth r : ℕ) :
    walshSpectralTail (arcsineProfile d depth) r=
      ∑j∈Finset.range (d+1),if r≤j then (d.choose j:ℝ)*levelWeight d depth j else 0 := by
  classical
  unfold walshSpectralTail
  rw [Finset.sum_filter]
  simp_rw [coefficient_eq_levelWeight]
  rw [sum_card_function d (fun j=>if r≤j then levelWeight d depth j else 0)]
  apply Finset.sum_congr rfl
  intro j hj
  split_ifs <;> simp

end NeuralGeneralization.NeuralRadialSpectrum
