import NeuralGeneralization.BatchTwoMergingSharpGeometry

/-! The literal paper-radius cylinder belongs to the actual prior restriction. -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d N r : ℕ}

theorem sharp_merging_cylinder_containment (hd:0<d) (hN:0<N)
    (φ:ℝ→ℝ) (p:PopulationPartition N) (v:Weights d N r) (f:BooleanFunction d)
    (b:OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J:Finset (Fin N)) {ℓ κ C σ:ℝ}
    (hℓ:1≤ℓ) (hφ:∀u v,|φ u-φ v|≤ℓ*|u-v|)
    (hκ:1≤κ) (hC:1≤C) (hσ:0≤σ) (hscale:(N:ℝ)*σ^2≤1)
    (hJ:(J.card:ℝ)≤C)
    (hlayers:∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤κ*C)
    (hreadcost:readoutEnergy v≤16*κ*C)
    (hcount:(populationCount p:ℝ)-1≤C) (henergy:16*C≤readoutEnergy v)
    (houtput:∀x,networkOutput φ v x=4*labelReal (f x))
    (hfixed:mergedWeights (fun _=>p) v=v)
    (hstatefixed:∀(x:Cube d) (ss:List (Fin r)),
      populationAverage p (ss.foldl (hiddenStep φ v) (firstHidden φ v x))=
        ss.foldl (hiddenStep φ v) (firstHidden φ v x))
    (hrows:∀s i j,j∉J→basisCoordinates b (fun a=>v (Sum.inr (Sum.inl (s,i,a)))) j=0)
    (hhidden:∀(x:Cube d) (ss:List (Fin r)) j,j∉J→
      basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j=0)
    (hbounded:∀(x:Cube d) (ss:List (Fin r)) i,
      |ss.foldl (hiddenStep φ v) (firstHidden φ v x) i|≤1) :
    sharpCoordinateCylinder v b J (sharpRadius ℓ κ C (sharpBulkBound r) d r) σ ⊆
      mergingSupport φ ∩marginEvent φ (1/2) f := by
  intro w hw
  let ρ:=sharpRadius ℓ κ C (sharpBulkBound r) d r
  obtain ⟨hρ,hρ16,hA,hamp,hfinal⟩ := sharpRadius_control d r hℓ hκ hC (sharpBulkBound_nonneg r)
  have hρ1:ρ≤1 := by dsimp [ρ]; linarith
  obtain ⟨hraw,hmerged,hread⟩ := sharp_cylinder_raw_merged_error hd hN φ p v w b J
    hℓ hφ hκ hC hσ hscale hJ hlayers hreadcost hfixed hstatefixed hrows hhidden hbounded hw
  have hout (x:Cube d):|networkOutput φ w x-4*labelReal (f x)|≤1/4 := by
    simpa only [houtput] using hraw x
  have hmout (x:Cube d):|networkOutput φ (mergedWeights (fun _=>p) w) x-4*labelReal (f x)|≤1/4 := by
    simpa only [houtput] using hmerged x
  have hsigned (z : ℝ) (b : Bool) (hz : |z-4*labelReal b|≤1/4) :
      (1/2:ℝ)<labelReal b*z ∧ z^2≤25 := by
    have hh := abs_le.mp hz
    cases b <;> simp only [labelReal_false,labelReal_true,neg_one_mul,one_mul] at * <;>
      constructor <;> nlinarith
  have hecomp := readoutEnergy_compare_of_coordinate_error hN w v hρ.le hread
  have hρsq : ρ^2≤1 := by nlinarith
  have hew : 7*C≤readoutEnergy w := by nlinarith
  refine ⟨Set.mem_iUnion.mpr ⟨fun _=>p,?_,⟩,?_⟩
  · constructor
    · intro s x
      have hh := (hsigned _ _ (hout x)).2
      calc
        _ ≤ C*(networkOutput φ w x)^2 := mul_le_mul_of_nonneg_right hcount (sq_nonneg _)
        _ ≤ C*25 := mul_le_mul_of_nonneg_left hh (by linarith)
        _ ≤ 4*readoutEnergy w := by nlinarith
    · intro x
      rw [clippedScore_eq_label_of_margin (f x) _ (hsigned _ _ (hout x)).1.le,
        clippedScore_eq_label_of_margin (f x) _ (hsigned _ _ (hmout x)).1.le]
      norm_num
  · intro x
    exact (hsigned _ _ (hout x)).1

end NeuralGeneralization.BatchTwoMerging
