import LongPrefixLastExit

noncomputable section
set_option maxHeartbeats 2200000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

/-- Initial normalized input variance is at least one, whereas every activated
state is bounded by one. Therefore the raw physical prefix cost is no greater
than its adjusted cost plus exactly J scalar reference charges. -/
theorem physical_prefix_cost_le_adjusted {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) {J : ℕ} (hJ1 : 1≤J) (hJH : J≤H) :
    (∑j∈Finset.range J,physicalLayerCost P j)≤
      (J:ℝ)*subcriticalCostBaseline (physicalVariance P)+
        ∑j∈Finset.range J,physicalAdjustedCost P j := by
  have hq := controlledMarginPath_variance_positive P
  have hqJ : physicalMaxVariance P J≤physicalMaxVariance P 0 :=
    (controlledMarginPath_variance_le_one P J hJH hJ1).trans (controlledMarginPath_initial_ge_one P hd)
  have hratio : 0≤physicalMaxVariance P J/physicalMaxVariance P 0 :=
    div_nonneg (hq J hJH).le (hq 0 (Nat.zero_le H)).le
  have hratio1 : physicalMaxVariance P J/physicalMaxVariance P 0≤1 :=
    (div_le_one (hq 0 (Nat.zero_le H))).mpr hqJ
  have hlog : Real.log (physicalMaxVariance P J/physicalMaxVariance P 0)≤0 :=
    Real.log_nonpos hratio hratio1
  have htel : (∑j∈Finset.range J,Real.log
      (physicalMaxVariance P (j+1)/physicalMaxVariance P j))=
      Real.log (physicalMaxVariance P J/physicalMaxVariance P 0) := by
    calc
      _ = ∑j∈Finset.range J,(Real.log (physicalMaxVariance P (j+1))-Real.log (physicalMaxVariance P j)) := by
        apply Finset.sum_congr rfl
        intro j hj
        have hh : j<J := Finset.mem_range.mp hj
        exact Real.log_div (hq (j+1) (by omega)).ne' (hq j (by omega)).ne'
      _ = Real.log (physicalMaxVariance P J)-Real.log (physicalMaxVariance P 0) :=
        Finset.sum_range_sub (fun j => Real.log (physicalMaxVariance P j)) J
      _ = _ := (Real.log_div (hq J hJH).ne' (hq 0 (Nat.zero_le H)).ne').symm
  have hsum : (∑j∈Finset.range J,physicalAdjustedCost P j)=
      (∑j∈Finset.range J,physicalLayerCost P j)-(J:ℝ)*subcriticalCostBaseline (physicalVariance P)-
        ((physicalVariance P:ℝ)⁻¹-1)/2*Real.log (physicalMaxVariance P J/physicalMaxVariance P 0) := by
    simp only [physicalAdjustedCost,adjustedLayerCost,Finset.sum_sub_distrib,
      ←Finset.mul_sum,Finset.sum_const,Finset.card_range,nsmul_eq_mul,htel]
  have hvpos : 0<(physicalVariance P:ℝ) := by rw [physicalVariance_coe]; exact sq_pos_of_pos P.scale_positive
  have hvone : (physicalVariance P:ℝ)≤1 := by exact_mod_cast physicalVariance_le_one P
  have hcoef : 0≤((physicalVariance P:ℝ)⁻¹-1)/2 := by
    have hh := (one_le_inv₀ hvpos).mpr hvone
    linarith
  have hh := mul_nonpos_of_nonneg_of_nonpos hcoef hlog
  linarith

/-- Actual long-prefix selection with its full adjusted and raw KL budgets. -/
theorem controlledMarginPath_long_prefix {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) {ε C K T a : ℝ}
    (hε : 0≤ε) (hC : 0≤C) (hK : 0<K) (hT : 1≤T) (ha : 0<a) (ha1 : a≤1)
    (hexcess : ε≤C*a*T)
    (hnear : (∑j∈Finset.range H,physicalAdjustedCost P j)+‖P.readout‖^2/2≤scalarBaseline.toReal+ε)
    (hdepth : longPrefixDepthConstant C K*T/a≤(H:ℝ)) :
    let J := longPrefixLength K T a
    1≤J ∧ K*T/a≤(J:ℝ) ∧ (J:ℝ)≤(K+1)*T/a ∧
      J≤lastExit (physicalMaxVariance P) H a ∧ J≤H ∧
      (∑j∈Finset.range J,physicalAdjustedCost P j)≤ε+526336*a ∧
      (∑j∈Finset.range J,physicalLayerCost P j)≤
        (J:ℝ)*subcriticalCostBaseline (physicalVariance P)+ε+526336*a := by
  have hdri (j : ℕ) (hj : j<H) (hj1 : 1≤j) :
      physicalMaxVariance P (j+1)-physicalMaxVariance P j≤
        -driftDissipation*(physicalMaxVariance P j)^2+physicalAdjustedCost P j/driftRate := by
    have hh := controlledMarginPath_adjusted_drift P j hj hj1
    have hh' : physicalMaxVariance P (j+1)-physicalMaxVariance P j+
        driftDissipation*(physicalMaxVariance P j)^2≤physicalAdjustedCost P j/driftRate :=
      (le_div_iff₀ driftRate_pos).mpr (by simpa only [mul_comm] using hh)
    linarith only [hh']
  have hp := long_prefix_before_lastExit H (physicalMaxVariance P) (physicalAdjustedCost P)
    hε hC hK hT ha ha1 hexcess
    (fun j hj hj1=>controlledMarginPath_variance_le_one P j hj hj1)
    (fun j hj=>(controlledMarginPath_adjusted_step P j hj).1) hdri
    (physical_adjusted_prefix_bound P hnear) hdepth
  obtain ⟨hJ1,hJlo,hJhi⟩ := longPrefixLength_bounds hK hT ha ha1
  have hJH := hp.1.trans (lastExit_le (physicalMaxVariance P) H a)
  refine ⟨hJ1,hJlo,hJhi,hp.1,hJH,hp.2,?_⟩
  have hh := physical_prefix_cost_le_adjusted P hd hJ1 hJH
  linarith [hp.2]

/-- The same actual prefix theorem, expressed directly using the path's raw
physical action excess. -/
theorem controlledMarginPath_long_prefix_of_action {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) {C K T a : ℝ}
    (hC : 0≤C) (hK : 0<K) (hT : 1≤T) (ha : 0<a) (ha1 : a≤1)
    (hexcess : physicalActionExcess P≤C*a*T)
    (hdepth : longPrefixDepthConstant C K*T/a≤(H:ℝ)) :
    let J := longPrefixLength K T a
    1≤J ∧ K*T/a≤(J:ℝ) ∧ (J:ℝ)≤(K+1)*T/a ∧
      J≤lastExit (physicalMaxVariance P) H a ∧ J≤H ∧
      (∑j∈Finset.range J,physicalAdjustedCost P j)≤physicalActionExcess P+526336*a ∧
      (∑j∈Finset.range J,physicalLayerCost P j)≤
        (J:ℝ)*subcriticalCostBaseline (physicalVariance P)+physicalActionExcess P+526336*a :=
  controlledMarginPath_long_prefix P hd (physicalActionExcess_nonneg P) hC hK hT ha ha1
    hexcess (physical_adjusted_action_excess P hd) hdepth

#print axioms controlledMarginPath_long_prefix_of_action

#print axioms physical_prefix_cost_le_adjusted
#print axioms controlledMarginPath_long_prefix
end ConditionalNonpolynomial.Analytic
