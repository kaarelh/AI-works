import GridEndpointClassifier

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

 def representativeDistanceTolerance (A : ℝ) (n : ℕ) : ℝ :=1/(1024*A^2*((n:ℝ)+1))
 def representativeDistanceThreshold (A : ℝ) : ℝ :=1/(32*A^2)

 theorem representativeDistanceTolerance_pos {A : ℝ} (hA : 0<A) (n : ℕ) :
    0<representativeDistanceTolerance A n := by unfold representativeDistanceTolerance;positivity

 theorem representativeDistanceTolerance_le_one {A : ℝ} (hA : 1≤A) (n : ℕ) :
    representativeDistanceTolerance A n≤1 := by
  have hn:0≤(n:ℝ):=Nat.cast_nonneg _
  unfold representativeDistanceTolerance
  apply (div_le_iff₀ (by positivity : 0<1024*A^2*((n:ℝ)+1))).mpr
  nlinarith [sq_nonneg A,mul_nonneg (sq_nonneg A) hn]

 theorem representativeDistanceTolerance_inverse {A : ℝ} (n : ℕ) :
    (representativeDistanceTolerance A n)⁻¹=1024*A^2*((n:ℝ)+1) := by
  simp only [representativeDistanceTolerance,one_div,inv_inv]

 theorem representative_distance_budgets {A : ℝ} (hA : 0<A) (n : ℕ) :
    (1/(64*A)+1/(256*A))^2+((n:ℝ)+1)*representativeDistanceTolerance A n<representativeDistanceThreshold A ∧
    representativeDistanceThreshold A+((n:ℝ)+1)*representativeDistanceTolerance A n≤(3/(4*A)-1/(256*A))^2 := by
  have ha:A≠0:=ne_of_gt hA
  have hn:((n:ℝ)+1)≠0:=by positivity
  unfold representativeDistanceTolerance representativeDistanceThreshold
  constructor
  · field_simp
    nlinarith [sq_pos_of_pos hA]
  · field_simp
    nlinarith [sq_nonneg A]

 theorem representative_distance_gap {ι J : Type} [Fintype ι] [Fintype J]
    [DecidableEq ι] [DecidableEq J]
    (centers : J→EuclideanSpace ℝ ι) (labels : J→Bool) (x y : EuclideanSpace ℝ ι)
    (truth : Bool) {A : ℝ} (hA : 0<A) (he : ‖x-y‖≤1/(256*A))
    (hnear : truth=true→∃j,labels j=true ∧ ‖y-centers j‖≤1/(64*A))
    (hfar : truth=false→∀j,labels j=true→3/(4*A)≤‖y-centers j‖) :
    (truth=true→∃j,labels j=true ∧ ‖x-centers j‖^2+
      ((Fintype.card J:ℝ)+1)*representativeDistanceTolerance A (Fintype.card J)<representativeDistanceThreshold A) ∧
    (truth=false→∀j,labels j=true→ representativeDistanceThreshold A+
      ((Fintype.card J:ℝ)+1)*representativeDistanceTolerance A (Fintype.card J)≤‖x-centers j‖^2) := by
  have hb:1/(256*A)≤3/(4*A):=by
    apply (div_le_div_iff₀ (by positivity : 0<256*A) (by positivity : 0<4*A)).mpr
    nlinarith
  exact distance_gap_of_endpoint_error centers labels x y truth he hb hnear hfar
    (representative_distance_budgets hA (Fintype.card J)).1 (representative_distance_budgets hA (Fintype.card J)).2

#print axioms representative_distance_gap
end ConditionalNonpolynomial.AnalyticLookup
