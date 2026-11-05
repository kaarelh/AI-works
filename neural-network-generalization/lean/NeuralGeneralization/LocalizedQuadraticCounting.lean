import NeuralGeneralization.LocalizedFamilyCounting
import NeuralGeneralization.BatchTwoShallowHalfspaces
import Mathlib.Data.Sym.Card

/-! Quadratic inequalities on the Boolean cube are actual linear thresholds
in unordered pairs of augmented coordinates. This gives the printed,
width-independent VC and cardinality bounds without assuming a feature oracle. -/
noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel BatchTwoShallow

abbrev QuadraticIndex (d : ℕ) := Sym2 (Fin (d+1))

def quadraticDimension (d : ℕ) : ℕ := Fintype.card (QuadraticIndex d)

theorem quadraticDimension_eq (d : ℕ) : quadraticDimension d = (d+1)*(d+2)/2 := by
  simp only [quadraticDimension,QuadraticIndex,Sym2.card,Fintype.card_fin,Nat.choose_two_right]
  congr 1
  rw [show d+1+1-1=d+1 by omega]
  ring

def quadraticMonomial {d : ℕ} (x : Cube d) : QuadraticIndex d → ℝ :=
  Sym2.lift ⟨fun i j => inputVector x i*inputVector x j,fun i j => mul_comm _ _⟩

def quadraticFeatures (d : ℕ) (x : Cube d) : Fin (quadraticDimension d) → ℝ :=
  fun j => quadraticMonomial x ((Fintype.equivFin (QuadraticIndex d)).symm j)

def quadraticPatterns (d : ℕ) : Finset (Finset (Cube d)) := halfspacePatterns (quadraticFeatures d)

/-- Every arbitrary real quadratic form in the augmented input has a literal
coefficient vector in the finite feature space. No symmetry assumption on M. -/
theorem quadratic_representable {d : ℕ} (M : Fin (d+1) → Fin (d+1) → ℝ) :
    ∃ b : Fin (quadraticDimension d) → ℝ,∀ x : Cube d,
      dot b (quadraticFeatures d x) = ∑ i,∑ j,M i j*inputVector x i*inputVector x j := by
  let mk : Fin (d+1) × Fin (d+1) → QuadraticIndex d := fun p => Sym2.mk p.1 p.2
  let C : QuadraticIndex d → ℝ := fun s => ∑ p ∈ Finset.univ.filter (fun p => mk p=s),M p.1 p.2
  let e := Fintype.equivFin (QuadraticIndex d)
  refine ⟨fun j => C (e.symm j),fun x => ?_⟩
  have hsum : (∑ s,C s*quadraticMonomial x s) =
      ∑ p : Fin (d+1) × Fin (d+1),M p.1 p.2*quadraticMonomial x (mk p) := by
    calc
      _ = ∑ s,∑ p ∈ Finset.univ.filter (fun p => mk p=s),M p.1 p.2*quadraticMonomial x (mk p) := by
        apply Finset.sum_congr rfl
        intro s _
        dsimp [C]
        rw [Finset.sum_mul]
        apply Finset.sum_congr rfl
        intro p hp
        rw [(Finset.mem_filter.mp hp).2]
      _ = _ := Finset.sum_fiberwise Finset.univ mk _
  calc
    dot (fun j => C (e.symm j)) (quadraticFeatures d x) = ∑ s,C s*quadraticMonomial x s := by
      exact Fintype.sum_equiv e.symm _ _ (fun _ => rfl)
    _ = _ := hsum
    _ = _ := by simp only [Fintype.sum_prod_type,mk,quadraticMonomial,Sym2.lift_mk,mul_assoc]

theorem quadratic_pattern_mem {d : ℕ} (M : Fin (d+1) → Fin (d+1) → ℝ) :
    (Finset.univ.filter fun x : Cube d => 0 < ∑ i,∑ j,M i j*inputVector x i*inputVector x j) ∈
      quadraticPatterns d := by
  obtain ⟨b,hb⟩ := quadratic_representable M
  apply Finset.mem_filter.mpr
  exact ⟨Finset.mem_univ _,b,fun x => by simp only [Finset.mem_filter,Finset.mem_univ,true_and,hb]⟩

theorem quadratic_vcDim (d : ℕ) : (quadraticPatterns d).vcDim ≤ quadraticDimension d :=
  halfspace_vcDim_le _

/-- The manuscript uses the looser J+1 bound; the homogeneous augmented
feature representation actually proves J. -/
theorem quadratic_vcDim_paper (d : ℕ) :
    (quadraticPatterns d).vcDim ≤ (d+1)*(d+2)/2+1 := by
  have hh := quadratic_vcDim d
  rw [quadraticDimension_eq] at hh
  omega

theorem quadratic_card (d : ℕ) :
    (quadraticPatterns d).card ≤ (2^d+1)^((d+1)*(d+2)/2+1) := by
  simpa [Cube] using family_card_le_vc_power _ (quadratic_vcDim_paper d)

theorem quadratic_log_card (d : ℕ) :
    Real.log ((quadraticPatterns d).card:ℝ) ≤
      (((d+1)*(d+2)/2+1:ℕ):ℝ)*((d:ℝ)+1)*Real.log 2 :=
  cube_family_log_card _ (quadratic_vcDim_paper d)

/-- Complementing every set preserves shattering and hence cannot increase
VC dimension. This covers weak quadratic sublevel inequalities as well. -/
lemma complement_vcDim_le {X : Type*} [Fintype X] [DecidableEq X]
    (F : Finset (Finset X)) : (F.image fun A => Aᶜ).vcDim ≤ F.vcDim := by
  unfold Finset.vcDim
  apply Finset.sup_le
  intro S hS
  have hs := Finset.mem_shatterer.mp hS
  have hsh : F.Shatters S := by
    intro T hT
    obtain ⟨U,hU,hSU⟩ := hs (Finset.sdiff_subset (s := S) (t := T))
    obtain ⟨V,hV,rfl⟩ := Finset.mem_image.mp hU
    refine ⟨V,hV,?_⟩
    ext x
    have hh := congrArg (fun A : Finset X => x ∈ A) hSU
    simp only [Finset.mem_inter,Finset.mem_compl,Finset.mem_sdiff] at hh ⊢
    have ht : x ∈ T → x ∈ S := fun hx => hT hx
    tauto
  exact hsh.card_le_vcDim

def quadraticClosedPatterns (d : ℕ) : Finset (Finset (Cube d)) :=
  (quadraticPatterns d).image fun A => Aᶜ

theorem quadratic_closed_vcDim_paper (d : ℕ) :
    (quadraticClosedPatterns d).vcDim ≤ (d+1)*(d+2)/2+1 :=
  (complement_vcDim_le _).trans (quadratic_vcDim_paper d)

/-- The weak sublevel set of every real quadratic form is included, including
boundary points where the form vanishes. -/
theorem quadratic_closed_pattern_mem {d : ℕ} (M : Fin (d+1) → Fin (d+1) → ℝ) :
    (Finset.univ.filter fun x : Cube d => (∑ i,∑ j,M i j*inputVector x i*inputVector x j) ≤ 0) ∈
      quadraticClosedPatterns d := by
  apply Finset.mem_image.mpr
  refine ⟨_,quadratic_pattern_mem M,?_⟩
  ext x
  simp

end NeuralGeneralization.RobustLocalized
