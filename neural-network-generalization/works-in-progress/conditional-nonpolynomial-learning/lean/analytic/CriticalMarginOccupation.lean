import CanonicalQueryProgram
import ControlledFieldOccupation
import NeuralGeneralization.NetworkGramBasics

/-! Occupation for the literal normalized Boolean input path. Its initial
variance is (d+1)/d, not at most one, so the scalar theorem is applied only
after the first actual tanh layer. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.NetworkGramBasics

def criticalEntropyBudget (H : ℕ) (ε : ℝ) : ℝ :=
  Real.sqrt (257+ε)+fieldEntropyOccupationBound (H-1) ε

def criticalVarianceBudget (H : ℕ) (ε : ℝ) : ℝ :=
  (2/driftDissipation)*(driftDissipation+
    ((driftDissipation/2)*varianceEntropyConstant+3)*fieldEntropyOccupationBound (H-1) ε+
    Real.log (8*(257+ε)))

theorem normalizedInputFeature_norm_sq_le_two {d : ℕ} (hd : 1≤d) (x : Cube d) :
    ‖normalizedInputFeature d x‖^2≤2 := by
  have hdpos : 0<(d:ℝ) := by exact_mod_cast (Nat.zero_lt_of_lt hd)
  rw [EuclideanSpace.norm_sq_eq]
  simp only [normalizedInputFeature,WithLp.ofLp_toLp,Real.norm_eq_abs,sq_abs,div_pow,
    Real.sq_sqrt (Nat.cast_nonneg d),← Finset.sum_div,inputVector_square_sum]
  apply (div_le_iff₀ hdpos).mpr
  have hdR : (1:ℝ)≤d := by exact_mod_cast hd
  linarith

theorem critical_action_eq {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) :
    P.action=(∑j∈Finset.range H,criticalLayerCost P j)+‖P.readout‖^2/2 := by
  rw [ControlledMarginPath.action]
  simp only [one_pow,mul_one]
  have hcoeff (j : ℕ) : scaledFeatureCoefficients 1 (P.feature j)=(fun x i => P.feature j x i) := by
    funext x i
    exact one_mul _
  simp_rw [hcoeff]
  change (∑j : Fin H,criticalLayerCost P j)+‖P.readout‖^2/2=_
  rw [Fin.sum_univ_eq_sum_range (criticalLayerCost P) H]

theorem criticalMarginPath_occupation {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (hd : 1≤d) (hH : 1≤H)
    {ε : ℝ} (hε : 0≤ε) (hnear : P.action≤scalarBaseline.toReal+ε) :
    (∑j : Fin H,Real.sqrt (criticalLayerCost P j))≤criticalEntropyBudget H ε ∧
    (∑j : Fin H,maxFeatureVariance (P.feature j))≤criticalVarianceBudget H ε := by
  classical
  obtain ⟨n,rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : H≠0)
  have hcoeff (j : ℕ) : scaledFeatureCoefficients 1 (P.feature j)=
      (fun x i => P.feature j x i) := by funext x i; exact one_mul _
  have hrec (j : ℕ) (hj : j<n+1) (x : Cube d) :
      ‖P.feature (j+1) x‖^2=∫z,(Real.tanh (z x))^2 ∂P.law j := by
    simpa only [real_inner_self_eq_norm_sq,pow_two] using P.recursion j hj x x
  have hcost : ∑j∈Finset.range (n+1),criticalLayerCost P j =
      criticalLayerCost P 0+∑j∈Finset.range n,criticalLayerCost P (j+1) := by
    rw [Finset.sum_range_succ']
    ring
  have haction := critical_action_eq P
  rw [hcost] at haction
  have hD0 : 0≤criticalLayerCost P 0 := ENNReal.toReal_nonneg
  have htailnear : (∑j∈Finset.range n,criticalLayerCost P (j+1))+‖P.readout‖^2/2≤
      scalarBaseline.toReal+ε := by linarith
  let x0 : Cube d := fun _ => false
  have hm : (1/2:ℝ)≤|inner ℝ P.readout (P.feature (n+1) x0)| := by
    have hh := P.margin x0
    have hl : labelReal (f x0)*inner ℝ P.readout (P.feature (n+1) x0)≤
        |inner ℝ P.readout (P.feature (n+1) x0)| := by
      calc
        _ ≤ |labelReal (f x0)*inner ℝ P.readout (P.feature (n+1) x0)| := le_abs_self _
        _ = _ := by rw [abs_mul,abs_labelReal,one_mul]
    linarith
  have ht := controlled_field_occupation n (fun j => P.feature (j+1))
    (fun j x i => P.feature (j+1) x i) (fun j => P.law (j+1))
    (fun j hj => P.probability (j+1) (by omega))
    (fun j hj => by simpa only [hcoeff] using P.finiteKL (j+1) (by omega))
    (fun j hj x => by simp only [WithLp.toLp_ofLp]; exact le_rfl)
    (fun j hj x => by simpa only [Nat.add_assoc] using hrec (j+1) (by omega) x)
    (fun x => by
      letI := P.probability 0 (by omega)
      rw [hrec 0 (by omega)]
      exact field_tanh_moment_le_one (P.law 0) x)
    P.readout x0 (by simpa using hm) ε hε htailnear
  have hD0upper : criticalLayerCost P 0≤257+ε := by
    have htailnonneg : 0≤∑j∈Finset.range n,criticalLayerCost P (j+1) :=
      Finset.sum_nonneg fun j _ => ENNReal.toReal_nonneg
    have hro : 0≤‖P.readout‖^2/2 := by positivity
    linarith [scalarBaseline_le]
  have hinitial : maxFeatureVariance (P.feature 0)≤2 := by
    unfold maxFeatureVariance
    rw [← real_inner_self_eq_norm_sq,P.initial,real_inner_self_eq_norm_sq]
    exact normalizedInputFeature_norm_sq_le_two hd _
  constructor
  · rw [Fin.sum_univ_eq_sum_range (fun j => Real.sqrt (criticalLayerCost P j)) (n+1),Finset.sum_range_succ']
    have hs := Real.sqrt_le_sqrt hD0upper
    simpa only [criticalEntropyBudget,Nat.succ_sub_one,criticalLayerCost,add_comm] using
      add_le_add ht.1 hs
  · rw [Fin.sum_univ_eq_sum_range (fun j => maxFeatureVariance (P.feature j)) (n+1),Finset.sum_range_succ']
    have htail := ht.2
    have hc := mul_le_mul_of_nonneg_left hinitial (by linarith [driftDissipation_pos] : 0≤driftDissipation/2)
    unfold criticalVarianceBudget
    simp only [Nat.succ_sub_one]
    have heq : (2/driftDissipation)*(driftDissipation+
        ((driftDissipation/2)*varianceEntropyConstant+3)*fieldEntropyOccupationBound n ε+
        Real.log (8*(257+ε))) =
      (2*(driftDissipation+
        ((driftDissipation/2)*varianceEntropyConstant+3)*fieldEntropyOccupationBound n ε+
        Real.log (8*(257+ε))))/driftDissipation := by ring
    rw [heq]
    apply (le_div_iff₀ driftDissipation_pos).mpr
    nlinarith

#print axioms criticalMarginPath_occupation
end ConditionalNonpolynomial.Analytic
