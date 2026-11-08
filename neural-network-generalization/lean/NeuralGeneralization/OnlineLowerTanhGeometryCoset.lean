import NeuralGeneralization.OnlineLowerGeometryReluDual

/-! # The enlarged affine coset used by rectangle calibration -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

theorem cubeTranslation_assoc {m : ℕ} (x y z : ClippingCube m) :
    cubeTranslation x (cubeTranslation y z) = cubeTranslation (cubeTranslation x y) z := by
  funext i
  cases hx : x i <;> cases hy : y i <;> cases hz : z i <;>
    simp [cubeTranslation, hx, hy, hz]

theorem cubeTranslation_swap {m : ℕ} (x y z : ClippingCube m) :
    cubeTranslation x (cubeTranslation y z) = cubeTranslation y (cubeTranslation x z) := by
  rw [cubeTranslation_assoc, cubeTranslation_comm x y, ← cubeTranslation_assoc]

theorem cubeTranslation_cancel_pair {m : ℕ} (u x y : ClippingCube m) :
    cubeTranslation (cubeTranslation u x) (cubeTranslation u y) = cubeTranslation x y := by
  rw [← cubeTranslation_assoc, cubeTranslation_swap u x, cubeTranslation_involutive]

namespace CubeSubgroup
variable {m : ℕ} (H : CubeSubgroup m)

def cosetCarrier (v : ClippingCube m) : Finset (ClippingCube m) :=
  H.carrier.image (cubeTranslation v)

theorem mem_cosetCarrier (v z : ClippingCube m) :
    z ∈ H.cosetCarrier v ↔ cubeTranslation v z ∈ H.carrier := by
  constructor
  · intro hz
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
    simpa only [cubeTranslation_involutive] using hx
  · intro hz
    exact Finset.mem_image.mpr ⟨cubeTranslation v z, hz, cubeTranslation_involutive v z⟩

theorem cosetCarrier_card (v : ClippingCube m) : (H.cosetCarrier v).card = H.carrier.card :=
  Finset.card_image_of_injective _ (cubeTranslation v).injective

def adjoinPoint (u : ClippingCube m) : CubeSubgroup m where
  carrier := H.carrier ∪ H.cosetCarrier u
  one_mem := Finset.mem_union_left _ H.one_mem
  mul_mem := by
    intro x hx y hy
    rcases Finset.mem_union.mp hx with hx | hx <;>
      rcases Finset.mem_union.mp hy with hy | hy
    · exact Finset.mem_union_left _ (H.mul_mem x hx y hy)
    · apply Finset.mem_union_right
      apply (H.mem_cosetCarrier u _).mpr
      have hy' := (H.mem_cosetCarrier u y).mp hy
      rw [cubeTranslation_swap]
      exact H.mul_mem x hx _ hy'
    · apply Finset.mem_union_right
      apply (H.mem_cosetCarrier u _).mpr
      have hx' := (H.mem_cosetCarrier u x).mp hx
      rw [cubeTranslation_assoc]
      exact H.mul_mem _ hx' y hy
    · apply Finset.mem_union_left
      have hx' := (H.mem_cosetCarrier u x).mp hx
      have hy' := (H.mem_cosetCarrier u y).mp hy
      have h := H.mul_mem _ hx' _ hy'
      rwa [cubeTranslation_cancel_pair] at h

theorem mem_adjoinPoint (u z : ClippingCube m) :
    z ∈ (H.adjoinPoint u).carrier ↔ z ∈ H.carrier ∨ cubeTranslation u z ∈ H.carrier := by
  simp only [adjoinPoint, Finset.mem_union, H.mem_cosetCarrier]

theorem subset_adjoinPoint (u : ClippingCube m) : H.carrier ⊆ (H.adjoinPoint u).carrier :=
  fun _ hz => Finset.mem_union_left _ hz

theorem point_mem_adjoinPoint (u : ClippingCube m) : u ∈ (H.adjoinPoint u).carrier := by
  apply (H.mem_adjoinPoint u u).mpr
  exact Or.inr (by rw [cubeTranslation_self]; exact H.one_mem)

theorem adjoinPoint_card (u : ClippingCube m) (hu : u ∉ H.carrier) :
    (H.adjoinPoint u).carrier.card = 2 * H.carrier.card := by
  have hd : Disjoint H.carrier (H.cosetCarrier u) := by
    apply Finset.disjoint_left.mpr
    intro z hz hz'
    exact H.coset_disjoint u hu z ((H.mem_cosetCarrier u z).mp hz') hz
  change (H.carrier ∪ H.cosetCarrier u).card = _
  rw [Finset.card_union_of_disjoint hd, H.cosetCarrier_card]
  omega

theorem coset_mem_adjoinPoint (u v z : ClippingCube m) :
    cubeTranslation v z ∈ (H.adjoinPoint u).carrier ↔
      cubeTranslation v z ∈ H.carrier ∨ cubeTranslation v (cubeTranslation u z) ∈ H.carrier := by
  rw [H.mem_adjoinPoint, cubeTranslation_swap u v z]

theorem coset_partner_not_mem (u v z : ClippingCube m) (hu : u ∉ H.carrier)
    (hz : cubeTranslation v z ∈ H.carrier) :
    cubeTranslation v (cubeTranslation u z) ∉ H.carrier := by
  rw [← cubeTranslation_swap u v z]
  intro hp
  exact H.coset_disjoint u hu (cubeTranslation v z) hp hz

theorem coset_mem_not_anchor_or_shift (u v z : ClippingCube m)
    (hv : v ∉ (H.adjoinPoint u).carrier) (hz : cubeTranslation v z ∈ H.carrier) :
    z ≠ cubeOne m ∧ z ≠ u := by
  have hz' := H.subset_adjoinPoint u hz
  have hnot := (H.adjoinPoint u).coset_disjoint v hv z hz'
  constructor
  · rintro rfl
    exact hnot (H.adjoinPoint u).one_mem
  · rintro rfl
    exact hnot (H.point_mem_adjoinPoint _)

end CubeSubgroup
end NeuralGeneralization.OnlineLowerGeometry
