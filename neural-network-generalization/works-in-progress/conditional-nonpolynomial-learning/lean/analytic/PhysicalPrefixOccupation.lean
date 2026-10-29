import ForcedCoolingOccupation
import SubcriticalMarginAccounting

/-! Prefix occupation for the actual physical posterior path. This uses only
its genuine adjusted entropy charges and their proved scalar drift; no
terminal-action or near-baseline hypothesis is imposed. -/
noncomputable section
set_option maxHeartbeats 2200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def physicalPrefixOccupationConstant : ℝ :=
  (2+1/driftDissipation)*(1+1/driftRate)

theorem physicalPrefixOccupationConstant_pos : 0<physicalPrefixOccupationConstant := by
  unfold physicalPrefixOccupationConstant
  positivity [driftDissipation_pos,driftRate_pos]

/-- Genuine physical-path prefix variance has logarithmic free occupation and
square-root dependence on the complete adjusted entropy spent in the prefix. -/
theorem physical_prefix_variance_occupation {d H J : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hJ : J≤H) :
    (∑j∈Finset.range J,physicalMaxVariance P j)≤2+
      physicalPrefixOccupationConstant*(Real.log ((J:ℝ)+2)+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalAdjustedCost P j))) := by
  have hcost (j : ℕ) (hj : j<H) : 0≤physicalAdjustedCost P j :=
    (controlledMarginPath_adjusted_step P j hj).1
  have hC := physicalPrefixOccupationConstant_pos
  by_cases hJzero : J=0
  · subst J
    simp only [Finset.range_zero,Finset.sum_empty,Nat.cast_zero,zero_mul,Real.sqrt_zero,zero_add,add_zero]
    have hl : 0≤Real.log (2:ℝ) := Real.log_nonneg (by norm_num)
    positivity
  obtain ⟨n,rfl⟩ := Nat.exists_eq_succ_of_ne_zero hJzero
  let e := fun j=>physicalAdjustedCost P (j+1)/driftRate
  have he (j : ℕ) (hj : j<n) : 0≤e j :=
    div_nonneg (hcost (j+1) (by omega)) driftRate_pos.le
  have hq (j : ℕ) (hj : j≤n) : 0≤physicalMaxVariance P (j+1) :=
    (controlledMarginPath_variance_positive P (j+1) (by omega)).le
  have hqone : physicalMaxVariance P 1≤1 := controlledMarginPath_variance_le_one P 1 (by omega) le_rfl
  have hstep (j : ℕ) (hj : j<n) :
      physicalMaxVariance P ((j+1)+1)-physicalMaxVariance P (j+1)≤
        -driftDissipation*(physicalMaxVariance P (j+1))^2+e j := by
    have hh := controlledMarginPath_adjusted_drift P (j+1) (by omega) (by omega)
    have hh' : physicalMaxVariance P ((j+1)+1)-physicalMaxVariance P (j+1)+
        driftDissipation*(physicalMaxVariance P (j+1))^2≤physicalAdjustedCost P (j+1)/driftRate :=
      (le_div_iff₀ driftRate_pos).mpr (by nlinarith only [hh])
    dsimp only [e]
    linarith
  have hgen := forced_cooling_occupation n (fun j=>physicalMaxVariance P (j+1)) e
    driftDissipation_pos hq hqone he hstep
  let E := ∑j∈Finset.range (n+1),physicalAdjustedCost P j
  let Etail := ∑j∈Finset.range n,physicalAdjustedCost P (j+1)
  let K := 1+1/driftRate
  have hK : 1≤K := by
    have hr : 0≤1/driftRate := by positivity [driftRate_pos]
    dsimp [K]
    linarith
  have hE : 0≤E := Finset.sum_nonneg fun j hj=>hcost j (by have := Finset.mem_range.mp hj; omega)
  have hEtail : 0≤Etail := Finset.sum_nonneg fun j hj=>hcost (j+1) (by have := Finset.mem_range.mp hj; omega)
  have hEtailE : Etail≤E := by
    dsimp [E,Etail]
    rw [Finset.sum_range_succ']
    linarith [hcost 0 (by omega)]
  have hsumE : (∑j∈Finset.range n,e j)=Etail/driftRate := by
    dsimp [e,Etail]
    rw [Finset.sum_div]
  rw [hsumE] at hgen
  have hprod : (n:ℝ)*Etail≤((n+1:ℕ):ℝ)*E := by
    have hh := mul_le_mul_of_nonneg_left hEtailE (Nat.cast_nonneg (α:=ℝ) n)
    push_cast
    nlinarith
  have hrate : 1/driftRate≤K^2 := by
    have hr : 0≤1/driftRate := by positivity [driftRate_pos]
    dsimp [K]
    nlinarith [sq_nonneg (1/driftRate)]
  have hprodDiv := div_le_div_of_nonneg_right hprod driftRate_pos.le
  have hprodK := mul_le_mul_of_nonneg_right hrate
    (mul_nonneg (Nat.cast_nonneg (α:=ℝ) (n+1)) hE)
  have hsqrt : Real.sqrt ((n:ℝ)*(Etail/driftRate))≤
      K*Real.sqrt (((n+1:ℕ):ℝ)*E) := by
    apply Real.sqrt_le_iff.mpr ⟨by positivity,?_⟩
    rw [mul_pow,Real.sq_sqrt (mul_nonneg (Nat.cast_nonneg _) hE)]
    have heq : (n:ℝ)*(Etail/driftRate)=((n:ℝ)*Etail)/driftRate := by ring
    rw [heq]
    have hprodK' : ((n+1:ℕ):ℝ)*E/driftRate≤K^2*(((n+1:ℕ):ℝ)*E) := by
      simpa only [div_eq_mul_inv,one_div,mul_comm,mul_left_comm,mul_assoc,one_mul,mul_one] using hprodK
    exact hprodDiv.trans hprodK'
  have hlog := Real.log_le_log (by positivity : 0<(n:ℝ)+2)
    (show (n:ℝ)+2≤((n+1:ℕ):ℝ)+2 by push_cast; linarith)
  have hlog0 : 0≤Real.log (((n+1:ℕ):ℝ)+2) := Real.log_nonneg (by linarith [Nat.cast_nonneg (α:=ℝ) (n+1)])
  have hlogK := mul_le_mul_of_nonneg_right hK hlog0
  have hsum : Real.log ((n:ℝ)+2)+Real.sqrt ((n:ℝ)*(Etail/driftRate))≤
      K*(Real.log (((n+1:ℕ):ℝ)+2)+Real.sqrt (((n+1:ℕ):ℝ)*E)) := by nlinarith
  have hC0 : 0≤2+1/driftDissipation := by positivity [driftDissipation_pos]
  have hscaled := mul_le_mul_of_nonneg_left hsum hC0
  have hq0 : physicalMaxVariance P 0≤2 := by
    unfold physicalMaxVariance maxFeatureVariance
    rw [←real_inner_self_eq_norm_sq,P.initial,real_inner_self_eq_norm_sq]
    exact normalizedInputFeature_norm_sq_le_two hd _
  rw [Finset.sum_range_succ']
  change (∑j∈Finset.range n,physicalMaxVariance P (j+1))+physicalMaxVariance P 0≤
    2+physicalPrefixOccupationConstant*(Real.log (((n+1:ℕ):ℝ)+2)+Real.sqrt (((n+1:ℕ):ℝ)*E))
  dsimp only [physicalPrefixOccupationConstant]
  change _≤2+(2+1/driftDissipation)*K*(Real.log (((n+1:ℕ):ℝ)+2)+Real.sqrt (((n+1:ℕ):ℝ)*E))
  nlinarith only [hgen,hscaled,hq0]

#print axioms physical_prefix_variance_occupation
end ConditionalNonpolynomial.Analytic
