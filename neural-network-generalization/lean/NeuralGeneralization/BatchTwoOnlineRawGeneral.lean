import NeuralGeneralization.BatchTwoOnlineRawHighProbability

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineRaw
open BatchTwoOnline SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

theorem expected_total_general (hm : 0<m) {A : Finset H} {good : H → Fin m → Prop} {β : ℝ}
    (P : CoverProcess A good β) (h : ℝ) (hh : 0≤h) (hβ : 0≤β)
    (hcard : (A.card : ℝ)≤Real.exp h) :
    finiteMean (total P)≤1+2*(h+1)*harmonicSum (m-1)+(m : ℝ)*β := by
  obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero hm.ne'
  simpa only [Nat.succ_eq_add_one,Nat.add_sub_cancel] using expected_total k P h hh hβ hcard

theorem total_high_probability_general (hm : 0<m) {A : Finset H} {good : H → Fin m → Prop} {β : ℝ}
    (P : CoverProcess A good β) (h δ : ℝ) (hh : 0≤h) (hβ : 0≤β)
    (hδ : 0<δ) (hδ1 : δ<1) (hcard : (A.card : ℝ)≤Real.exp h) :
    finiteEvent (fun π => (Real.exp 1-1)*(1+2*(h+Real.log (2*(m : ℝ)/δ))*harmonicSum (m-1)+m*β)+
      Real.log (2/δ)<total P π)≤δ := by
  obtain ⟨k,rfl⟩ := Nat.exists_eq_succ_of_ne_zero hm.ne'
  simpa only [Nat.succ_eq_add_one,Nat.add_sub_cancel] using total_high_probability k P h δ hh hβ hδ hδ1 hcard

end NeuralGeneralization.BatchTwoOnlineRaw
