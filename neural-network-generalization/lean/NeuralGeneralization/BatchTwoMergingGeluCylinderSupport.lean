import NeuralGeneralization.BatchTwoMergingGeluCylinderGeometry
import NeuralGeneralization.BatchTwoMergingCylinderSupport

/-! # An open teacher cylinder lies in the population-merging restriction -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d N r : ℕ}

def geluMergingCylinderRadius (d r : ℕ) (K G : ℝ) : ℝ :=
  1/(16*(geluCylinderOutputFactor d r K G (16*((r:ℝ)+1))+1))

theorem geluMergingCylinderRadius_bounds {K G : ℝ} (hK : 0≤K) (hG : 0≤G) :
    0<geluMergingCylinderRadius d r K G ∧ geluMergingCylinderRadius d r K G≤1/16 ∧
    (geluMergingCylinderRadius d r K G)^2*
      geluCylinderOutputFactor d r K G (16*((r:ℝ)+1))≤1/16 := by
  have hF : 0≤geluCylinderOutputFactor d r K G (16*((r:ℝ)+1)) := by
    unfold geluCylinderOutputFactor unboundedCylinderOutputFactor unboundedCylinderAmplification cylinderInputFactor
    positivity
  let F := geluCylinderOutputFactor d r K G (16*((r:ℝ)+1))
  change 0<1/(16*(F+1)) ∧ 1/(16*(F+1))≤1/16 ∧ (1/(16*(F+1)))^2*F≤1/16
  have hp : 0<F+1 := by dsimp [F]; linarith
  refine ⟨by positivity,?_,?_⟩
  · apply (div_le_iff₀ (by positivity : 0<16*(F+1))).mpr
    dsimp [F]
    nlinarith
  · apply le_of_mul_le_mul_right (a := (16*(F+1))^2) _ (by positivity)
    field_simp
    nlinarith [sq_nonneg F]

theorem gelu_merging_cylinder_containment (hd : 0<d) (hN : 0<N)
    (p : PopulationPartition N) (v : Weights d N r) (f : BooleanFunction d)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) {K G C σ : ℝ}
    (hK : 0≤K) (hG : 0≤G) (hC : 1≤C) (hσ : 0≤σ)
    (hscale : (N:ℝ)*σ^2≤1) (hJ : (J.card:ℝ)≤G)
    (hcost : weightedSquaredNorm v≤K) (hcount : (populationCount p:ℝ)-1≤C)
    (henergy : 16*C≤readoutEnergy v)
    (houtput : ∀x,networkOutput gelu v x=4*labelReal (f x))
    (hfixed : mergedWeights (fun _ => p) v=v)
    (hrows : ∀s i j,j∉J→basisCoordinates b (fun a=>v (Sum.inr (Sum.inl (s,i,a)))) j=0)
    (hhidden : ∀(x : Cube d) (ss : List (Fin r)) j,j∉J→
      basisCoordinates b (ss.foldl (hiddenStep gelu v) (firstHidden gelu v x)) j=0)
    (hcolumns : ∀k j,j∉J→basisCoordinates b (fun i=>populationProjection p i k) j=0)
    (hbounded : ∀(x : Cube d) (ss : List (Fin r)) i,
      |ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) i|≤1) :
    robustCoordinateCylinder v b J (geluMergingCylinderRadius d r K G) σ ⊆
      mergingSupport gelu ∩ marginEvent gelu (1/2) f := by
  intro w hw
  obtain ⟨hρ,hρ16,hρF⟩ := geluMergingCylinderRadius_bounds (d:=d) (r:=r) hK hG
  have hρ1 : geluMergingCylinderRadius d r K G≤1/2 := by linarith
  obtain ⟨hraw,hmerged,hread⟩ := gelu_cylinder_raw_merged_error hd hN p v w b J
    hK hG hρ.le hρ1 hσ hscale hJ hcost hfixed hrows hhidden hcolumns hbounded hw
  have hout (x : Cube d) : |networkOutput gelu w x-4*labelReal (f x)|≤1/4 := by
    have hh := (hraw x).trans hρF
    rw [houtput] at hh
    exact (sq_le_sq₀ (abs_nonneg _) (by norm_num : (0:ℝ)≤1/4)).mp (by norm_num only [sq_abs, one_div, inv_pow, show (4:ℝ)^2=16 by norm_num] at *; exact hh)
  have hmout (x : Cube d) : |networkOutput gelu (mergedWeights (fun _=>p) w) x-
      4*labelReal (f x)|≤1/4 := by
    have hh := (hmerged x).trans hρF
    rw [houtput] at hh
    exact (sq_le_sq₀ (abs_nonneg _) (by norm_num : (0:ℝ)≤1/4)).mp (by norm_num only [sq_abs, one_div, inv_pow, show (4:ℝ)^2=16 by norm_num] at *; exact hh)
  have hsigned (z : ℝ) (b : Bool) (hz : |z-4*labelReal b|≤1/4) :
      (1/2:ℝ)<labelReal b*z ∧ z^2≤25 := by
    have hh := abs_le.mp hz
    cases b <;> simp only [labelReal_false,labelReal_true,neg_one_mul,one_mul] at * <;>
      constructor <;> nlinarith
  have hecomp := readoutEnergy_compare_of_coordinate_error hN w v hρ.le hread
  have hρsq : (geluMergingCylinderRadius d r K G)^2≤1 := by nlinarith
  have hew : 7*C≤readoutEnergy w := by nlinarith
  refine ⟨Set.mem_iUnion.mpr ⟨fun _=>p,?_,⟩,?_⟩
  · constructor
    · intro s x
      have hh := (hsigned _ _ (hout x)).2
      calc
        _ ≤ C*(networkOutput gelu w x)^2 := mul_le_mul_of_nonneg_right hcount (sq_nonneg _)
        _ ≤ C*25 := mul_le_mul_of_nonneg_left hh (by linarith)
        _ ≤ 4*readoutEnergy w := by nlinarith
    · intro x
      rw [clippedScore_eq_label_of_margin (f x) _ (hsigned _ _ (hout x)).1.le,
        clippedScore_eq_label_of_margin (f x) _ (hsigned _ _ (hmout x)).1.le]
      norm_num
  · intro x
    exact (hsigned _ _ (hout x)).1

end NeuralGeneralization.BatchTwoMerging
