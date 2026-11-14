import NeuralGeneralization.OnlineLowerTanhPhaseAbsorption
import NeuralGeneralization.OnlineLowerTanhElementary

/-! # Exact equality in the dimension-independent phase-defect bound -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

/-- Maximum equality, rather than equality in a particular quantitative
lower estimate, holds exactly at vectors of odd lattice multiples. -/
theorem periodic_external_maximum_iff_odd_multiples {d η:ℕ} {a:ℝ}
    (ha:1≤a) (ha2:a≤2) (hη:Odd (η+d)) (u:Fin d→ℝ) :
    |uniformCubeMean (fun x=>paritySign x*periodicFourierResponse a
      ((η:ℝ)*a+incomingLinear u x))|=periodicFourierMaximum a ↔
      ∀ i, ∃ r:ℤ, Odd r ∧ u i=a*(r:ℝ) := by
  have ha0 : 0<a := by linarith
  constructor
  · intro hmax
    have hb := periodic_external_phase_stability ha ha2 hη u
    rw [hmax,sub_self] at hb
    have hc : 0<periodicPeakFloor/1600 := by positivity [periodicPeakFloor_pos]
    have hm : min (incomingEnergy (oddPhaseResidual a u)) 1≤0 := by nlinarith
    have hE : incomingEnergy (oddPhaseResidual a u)=0 := by
      have hn := incomingEnergy_nonneg (oddPhaseResidual a u)
      rcases le_total (incomingEnergy (oddPhaseResidual a u)) 1 with h|h
      · rw [min_eq_left h] at hm; linarith
      · rw [min_eq_right h] at hm; norm_num at hm
    intro i
    have hi := oddPhaseResidual_sq_le_energy a u i
    rw [hE] at hi
    have hz : oddPhaseResidual a u i=0 := by nlinarith [sq_nonneg (oddPhaseResidual a u i)]
    refine ⟨phaseInteger true (u i/a),phaseInteger_odd _,?_⟩
    simpa only [hz,add_zero] using oddPhaseResidual_decompose ha0 u i
  · intro hodd
    choose r hr heq using hodd
    obtain ⟨s,hs,hpoint⟩ := periodic_odd_phase_absorption ha0 hη r hr (0:Fin d→ℝ)
    have he : (fun i=>a*(r i:ℝ)+(0:Fin d→ℝ) i)=u := by
      funext i
      simp only [Pi.zero_apply,add_zero,←heq i]
    rw [he] at hpoint
    have hp : ∀x:Cube d,paritySign x*periodicFourierResponse a
        ((η:ℝ)*a+incomingLinear u x)=s*periodicFourierMaximum a := by
      intro x
      simpa [incomingLinear,periodicFourierMaximum] using hpoint x
    simp_rw [hp]
    simp only [uniformCubeMean,Finset.sum_const,Finset.card_univ,nsmul_eq_mul]
    simp only [mul_div_cancel_left₀ _ (by positivity : (Fintype.card (Cube d):ℝ)≠0)]
    rw [abs_mul,hs,one_mul]
    exact abs_of_nonneg (periodicFourierMaximum_pos ha0 ha2).le

end NeuralGeneralization.OnlineLowerTanh
