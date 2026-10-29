import ScalarDyadicEntropy

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

/-- Every prefix of an actual finite controlled scalar path obeys the
baseline-subtracted bound. Charges may exceed the scalar marginal KL, as
happens when the full vector-layer entropy is used. -/
theorem controlled_path_prefix_bound (H : ℕ) (q a e : ℕ → ℝ) (Q : ℕ → Measure ℝ)
    {ε readout : ℝ}
    (hq : ∀j≤H,0<q j) (ha : ∀j<H,0≤a j) (haq : ∀j<H,a j≤q j)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hfinite : ∀j<H,klDiv (Q j) (gaussianReal 0 1)≠∞)
    (hcharge : ∀j<H,(klDiv (Q j) (gaussianReal 0 1)).toReal≤e j)
    (htrans : ∀j<H,q (j+1)≤scalarTransition (a j) (Q j))
    (hreadout : 1/(8*q H)≤readout)
    (hnear : (∑j ∈ Finset.range H,e j)+readout≤scalarBaseline.toReal+ε) :
    ∀i≤H,(∑j ∈ Finset.range i,e j)≤ε+526336*q i := by
  intro i hi
  have hs := scalarValue_controlled_suffix (H-i) (fun j => q (i+j))
    (fun j => a (i+j)) (fun j => Q (i+j))
    (fun j hj => hq (i+j) (by omega)) (fun j hj => ha (i+j) (by omega))
    (fun j hj => haq (i+j) (by omega)) (fun j hj => hprob (i+j) (by omega))
    (fun j hj => hfinite (i+j) (by omega))
    (fun j hj => by simpa only [Nat.add_assoc] using htrans (i+j) (by omega))
  simp only [Nat.add_zero,Nat.add_sub_of_le hi] at hs
  have hcost : (∑j ∈ Finset.range (H-i),(klDiv (Q (i+j)) (gaussianReal 0 1)).toReal)≤
      ∑j ∈ Finset.range (H-i),e (i+j) :=
    Finset.sum_le_sum fun j hj => hcharge (i+j) (by have hh := Finset.mem_range.mp hj; omega)
  have hbridge := (scalarBaseline_global_bridge (hq i hi)).2
  rw [sum_segment_eq e hi] at hcost
  linarith

/-- Genuine scalar-law specialization of the logarithmic square-root entropy
bound. No Bellman value, concentration, occupation, or dyadic certificate is
assumed: each is derived from the actual tanh transition and Mathlib KL. -/
theorem controlled_path_sqrt_entropy (H : ℕ) (q a e : ℕ → ℝ) (Q : ℕ → Measure ℝ)
    {ε readout : ℝ} (hε : 0≤ε)
    (hq : ∀j≤H,0<q j) (hq1 : ∀j≤H,q j≤1)
    (ha : ∀j<H,0≤a j) (haq : ∀j<H,a j≤q j)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hfinite : ∀j<H,klDiv (Q j) (gaussianReal 0 1)≠∞)
    (hcharge : ∀j<H,(klDiv (Q j) (gaussianReal 0 1)).toReal≤e j)
    (htrans : ∀j<H,q (j+1)≤scalarTransition (a j) (Q j))
    (hreadout : 1/(8*q H)≤readout)
    (hnear : (∑j ∈ Finset.range H,e j)+readout≤scalarBaseline.toReal+ε) :
    (∑j ∈ Finset.range H,Real.sqrt (e j))≤
      Real.sqrt (526337*(H:ℝ)*ε+526336)+
      ((Nat.log2 (H+1)+1:ℕ):ℝ)*dyadicBlockConstant 526336 := by
  have he (j:ℕ) (hj:j<H) : 0≤e j := ENNReal.toReal_nonneg.trans (hcharge j hj)
  have hd (j:ℕ) (hj:j<H) :
      q (j+1)-q j≤-driftDissipation*(q j)^2+e j/driftRate := by
    letI := hprob j hj
    have hh := scalar_entropy_drift_subcritical (Q j) (hfinite j hj)
      (ha j hj) (haq j hj) (hq1 j (by omega))
    have hch := div_le_div_of_nonneg_right (hcharge j hj) driftRate_pos.le
    have ht := htrans j hj
    change q (j+1)≤∫z,varianceTest (a j) z ∂Q j at ht
    linarith
  have hp := controlled_path_prefix_bound H q a e Q hq ha haq hprob hfinite hcharge htrans hreadout hnear
  have hh := logarithmic_sqrt_entropy H q e hε (by norm_num : (0:ℝ)≤526336) hq1 he hd hp
  norm_num at hh ⊢
  exact hh

#print axioms controlled_path_prefix_bound
#print axioms controlled_path_sqrt_entropy
end ConditionalNonpolynomial.Analytic
