import NeuralGeneralization.BatchTwoContinuousMinimizers
import NeuralGeneralization.NetworkEnergy

/-! Attainment in the closed weak-margin class even when the strict-margin
energy infimum itself is not attained. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set
namespace NeuralGeneralization.ConcreteModel

 theorem exists_weak_margin_representative {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    {φ : ℝ→ℝ} (hφ : Continuous φ) (f : BooleanFunction d)
    (hne : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty) {K : ℝ}
    (hK : 2*networkEnergy (N:=N) (r:=r) φ (1/2) f≤K) :
    ∃ w : Weights d N r, weightedSquaredNorm w≤K ∧
      ∀ x,(1/2:ℝ)≤labelReal (f x)*networkOutput φ w x := by
  let U := marginEvent (N:=N) (r:=r) φ (1/2) f
  let B := {w : Weights d N r | weightedSquaredNorm w≤K+1} ∩ closure U
  have hc : IsCompact B := (BatchTwoContinuous.isCompact_weightedEnergy_sublevel hd hN _).inter_right isClosed_closure
  obtain ⟨v,hv,hev⟩ := exists_nearoptimal_margin_network φ (1/2) f hne 1 zero_lt_one
  have hvB : v∈B := ⟨by change weightedSquaredNorm v≤K+1; linarith,subset_closure hv⟩
  obtain ⟨w,hw,hmin⟩ := hc.exists_isMinOn ⟨v,hvB⟩ BatchTwoContinuous.continuous_weightedEnergy.continuousOn
  refine ⟨w,?_,?_⟩
  · by_contra hnot
    have hdiff : 0<weightedSquaredNorm w-K := sub_pos.mpr (lt_of_not_ge hnot)
    let ε := min 1 ((weightedSquaredNorm w-K)/2)
    have hε : 0<ε := lt_min zero_lt_one (by positivity)
    obtain ⟨u,hu,heu⟩ := exists_nearoptimal_margin_network φ (1/2) f hne ε hε
    have hε1 : ε≤1 := min_le_left _ _
    have hε2 : ε≤(weightedSquaredNorm w-K)/2 := min_le_right _ _
    have huB : u∈B := ⟨by change weightedSquaredNorm u≤K+1; linarith,subset_closure hu⟩
    have hm := hmin huB
    change weightedSquaredNorm w≤weightedSquaredNorm u at hm
    linarith
  · have hc' : IsClosed {v : Weights d N r | ∀ x,(1/2:ℝ)≤labelReal (f x)*networkOutput φ v x} := by
      simp only [setOf_forall]
      exact isClosed_iInter fun x => isClosed_le continuous_const
        (continuous_const.mul (continuous_networkOutput hφ x))
    have hsub : closure U⊆{v : Weights d N r | ∀ x,(1/2:ℝ)≤labelReal (f x)*networkOutput φ v x} :=
      closure_minimal (fun v hv x => (hv x).le) hc'
    exact hsub hw.2

end NeuralGeneralization.ConcreteModel
