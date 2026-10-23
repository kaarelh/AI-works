import NeuralGeneralization.ReadoutDual
import Mathlib.Analysis.InnerProductSpace.PiL2

/-! A finite source-space proof of the RKHS approximation certificate.
The construction projects onto a compact absolutely convex hull, so it
requires no inverse covariance, eigenvalue bound, or KKT assumption. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open Finset
variable {I E : Type*} [Fintype I] [DecidableEq I]
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def signedSource (a : I→E) : Option (I×Bool)→E
  | none => 0
  | some (i,true) => a i
  | some (i,false) => -a i

theorem signedSource_combination (a : I→E) (G : ℝ) (w : Option (I×Bool)→ℝ) :
    (∑j,w j • (G • signedSource a j))=
      ∑i,(G*(w (some (i,true))-w (some (i,false)))) • a i := by
  simp only [Fintype.sum_option,Fintype.sum_prod_type,Fintype.sum_bool,signedSource,
    smul_zero,zero_add,smul_neg,smul_smul]
  apply Finset.sum_congr rfl
  intro i hi
  simp only [sub_smul,mul_sub]
  module

theorem signedSource_l1 (a : I→E) {G : ℝ} (hG : 0≤G) (w : Option (I×Bool)→ℝ)
    (hw : ∀j,0≤w j) (hsum : (∑j,w j)=1) :
    (∑i,|G*(w (some (i,true))-w (some (i,false)))|)≤G := by
  calc
    _ ≤ G*(∑i,(w (some (i,true))+w (some (i,false)))) := by
      rw [Finset.mul_sum]
      apply Finset.sum_le_sum
      intro i hi
      rw [abs_mul,abs_of_nonneg hG]
      apply mul_le_mul_of_nonneg_left _ hG
      simpa only [abs_of_nonneg (hw _)] using (abs_sub (w (some (i,true))) (w (some (i,false))))
    _ ≤ G*1 := by
      apply mul_le_mul_of_nonneg_left _ hG
      simp only [Fintype.sum_option,Fintype.sum_prod_type,Fintype.sum_bool] at hsum
      linarith [hw none]
    _ = _ := mul_one G

/-- Approximate all finitely many linear observations of a unit source.
The coefficient budget is exactly the manuscript's `1/(4η)`. -/
theorem exists_source_l1_certificate (a : I→E) (u : E) (hu : ‖u‖≤1)
    {η : ℝ} (hη : 0<η) :
    ∃β:I→ℝ, (∑i,|β i|)≤1/(4*η) ∧
      ‖∑i,β i • a i‖≤1 ∧
      ∀i, |inner ℝ (a i) (∑j,β j • a j)-inner ℝ (a i) u|≤η := by
  classical
  let G : ℝ := 1/(4*η)
  have hG : 0<G := by dsimp [G]; positivity
  have hGη : G*η=1/4 := by dsimp [G]; field_simp <;> ring
  let b : Option (I×Bool)→E := fun j=>G • signedSource a j
  let K : Set E := convexHull ℝ (Set.range b)
  have hbK (j : Option (I×Bool)) : b j∈K := subset_convexHull ℝ _ ⟨j,rfl⟩
  have hKne : K.Nonempty := ⟨b none,hbK none⟩
  have hKcompact : IsCompact K := (Set.finite_range b).isCompact_convexHull ℝ
  have hKconvex : Convex ℝ K := convex_convexHull ℝ _
  obtain ⟨p,hp,hmin⟩ := exists_norm_eq_iInf_of_complete_convex hKne hKcompact.isComplete hKconvex u
  have hproj := (norm_eq_iInf_iff_real_inner_le_zero hKconvex hp).mp hmin
  obtain ⟨w,hw,hsum,hrep⟩ := ReadoutDual.convexHull_range_weights b hp
  let β : I→ℝ := fun i=>G*(w (some (i,true))-w (some (i,false)))
  have hβrep : (∑i,β i • a i)=p := by
    rw [←hrep]
    exact (signedSource_combination a G w).symm
  have hup : inner ℝ u p≤‖p‖ := by
    apply (real_inner_le_norm u p).trans
    simpa using mul_le_mul_of_nonneg_right hu (norm_nonneg p)
  have hself : ‖p‖^2 ≤ inner ℝ u p := by
    have h := hproj (b none) (hbK none)
    simp only [b,signedSource,smul_zero,zero_sub,inner_neg_right,
      inner_sub_left,real_inner_self_eq_norm_sq] at h
    linarith
  have hpunit : ‖p‖≤1 := by nlinarith [norm_nonneg p]
  have hquarter : inner ℝ (u-p) p≤1/4 := by
    rw [inner_sub_left,real_inner_self_eq_norm_sq]
    nlinarith [sq_nonneg (‖p‖-1/2)]
  have hobs (i : I) : G*|inner ℝ (u-p) (a i)|≤1/4 := by
    have hpos := hproj (b (some (i,true))) (hbK _)
    have hneg := hproj (b (some (i,false))) (hbK _)
    simp only [b,signedSource,inner_sub_right,real_inner_smul_right,inner_neg_right] at hpos hneg
    rcases le_total 0 (inner ℝ (u-p) (a i)) with h | h
    · rw [abs_of_nonneg h]; linarith
    · rw [abs_of_nonpos h]; linarith
  refine ⟨β,signedSource_l1 a hG.le w hw hsum,?_,?_⟩
  · rwa [hβrep]
  · intro i
    rw [hβrep,←inner_sub_right,←abs_neg]
    simp only [←inner_neg_right,neg_sub]
    rw [real_inner_comm]
    have h := hobs i
    nlinarith

end NeuralGeneralization.BatchTwoActivation
