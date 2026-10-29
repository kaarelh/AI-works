import MatrixCoordinates
import ParallelPicardCircuit

/-! Exact coordinate matrices of a genuine finite Volterra update. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ζ ι : Type*} [Fintype ζ] [Fintype ι] {h : ℕ}

 def finiteVolterraValue
    (A : Fin h→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (C : Fin h→Fin h→EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ ι)
    (F : Fin h→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι)
    (x : EuclideanSpace ℝ ζ) (u : Fin h→EuclideanSpace ℝ ι) (j : Fin h) : EuclideanSpace ℝ ι :=
  A j x+∑i,if i<j then C j i (F i (u i)) else 0

 def volterraCoefficients
    (A : Fin h→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (C : Fin h→Fin h→EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ ι)
    (z : Fin h×ι) : (ζ⊕(Fin h×ι))→ℝ :=
  Sum.elim (linearCoefficients (A z.1) z.2)
    (fun v=>if v.1<z.1 then linearCoefficients (C z.1 v.1) z.2 v.2 else 0)

 theorem volterraCoefficients_bound
    (A : Fin h→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (C : Fin h→Fin h→EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ ι)
    {B : ℝ} (hB : 0≤B) (hA : ∀j,‖A j‖≤B) (hC : ∀j i,‖C j i‖≤B) :
    ∀z v,|volterraCoefficients A C z v|≤B := by
  rintro z (v|v)
  · exact (linearCoefficients_bound _ _ _).trans (hA z.1)
  · change |if v.1<z.1 then _ else 0|≤B
    split_ifs
    · exact (linearCoefficients_bound _ _ _).trans (hC z.1 v.1)
    · simpa only [abs_zero] using hB

 theorem volterraCoefficients_eval
    (A : Fin h→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (C : Fin h→Fin h→EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ ι)
    (F : Fin h→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι)
    (x : EuclideanSpace ℝ ζ) (u : Fin h→EuclideanSpace ℝ ι) (z : Fin h×ι) :
    affineRealMap (volterraCoefficients A C) (fun _=>0)
      (residualCarryMap F (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun v=>u v.1 v.2)))) z=
        finiteVolterraValue A C F x u z.1 z.2 := by
  change (0:ℝ)+∑v,volterraCoefficients A C z v*
    (residualCarryMap F (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun v=>u v.1 v.2)))) v=_
  rw [zero_add,Fintype.sum_sum_type]
  change (∑i,linearCoefficients (A z.1) z.2 i*x i)+
    (∑v:Fin h×ι,(if v.1<z.1 then linearCoefficients (C z.1 v.1) z.2 v.2 else 0)*F v.1 (u v.1) v.2)=_
  rw [linearCoefficients_eval,Fintype.sum_prod_type]
  change _+_= (A z.1 x+∑i:Fin h,if i<z.1 then C z.1 i (F i (u i)) else 0) z.2
  simp only [PiLp.add_apply,WithLp.ofLp_sum,Finset.sum_apply]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  by_cases hij:i<z.1
  · simp only [if_pos hij]
    exact linearCoefficients_eval _ _ _
  · simp [hij]

 theorem finiteVolterraValue_norm
    (A : Fin h→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι)
    (C : Fin h→Fin h→EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ ι)
    (F : Fin h→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι)
    (hA : ∀j,‖A j‖≤1) (hC : ∀j i,‖C j i‖≤1)
    (R : Fin h→ℝ) (hR : ∀i,0≤R i) (hF : ∀i v,‖F i v‖≤R i)
    (x : EuclideanSpace ℝ ζ) (u : Fin h→EuclideanSpace ℝ ι) (j : Fin h) :
    ‖finiteVolterraValue A C F x u j‖≤‖x‖+∑i,R i := by
  have ha : ‖A j x‖≤‖x‖ := (A j).le_opNorm x |>.trans
    ((mul_le_mul_of_nonneg_right (hA j) (norm_nonneg x)).trans_eq (one_mul _))
  have hc (i : Fin h) : ‖if i<j then C j i (F i (u i)) else 0‖≤R i := by
    split_ifs
    · exact ((C j i).le_opNorm _).trans ((mul_le_mul (hC j i) (hF i _) (norm_nonneg _)
        (by norm_num : (0:ℝ)≤1)).trans_eq (one_mul _))
    · simpa only [norm_zero] using hR i
  exact (norm_add_le _ _).trans (add_le_add ha ((norm_sum_le _ _).trans (Finset.sum_le_sum fun i _=>hc i)))

#print axioms volterraCoefficients_eval
#print axioms finiteVolterraValue_norm
end ConditionalNonpolynomial.AnalyticLookup
