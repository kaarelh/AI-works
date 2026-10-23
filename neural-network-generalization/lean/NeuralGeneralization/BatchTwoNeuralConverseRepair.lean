import NeuralGeneralization.BatchTwoNeuralConverseParallel
import NeuralGeneralization.BatchTwoNeuralConverseConstant

/-! Exact one-point label repair in the original gain-restricted prior. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical
open ConcreteModel

def repairBudget (d r : ℕ) (U : ℝ) : ℝ :=
  singletonBaseBudget d (r+1)+singletonReadoutBudget (r+1)*(U+1)^2

theorem repairBudget_pos (d r : ℕ) (U : ℝ) : 0<repairBudget d r U := by
  unfold repairBudget singletonBaseBudget singletonReadoutBudget firstFeatureBudget
  positivity

theorem functionSupport_energy_pos {d N r : ℕ} {Λ U : ℝ} {g : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ functionSupport Λ U g) : 0<weightedSquaredNorm w := by
  have ho : networkOutput Real.tanh w (fun _ => false)≠0 := by
    have hx := hw.1.1 (fun _ => false)
    intro hz
    rw [hz,abs_zero] at hx
    linarith [hx.1]
  exact (readoutEnergy_pos_of_output_ne_zero w _ ho).trans_le (readoutEnergy_le_weightedSquaredNorm w)

theorem supported_width_pos {d N r : ℕ} {Λ U : ℝ} {g : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ functionSupport Λ U g) : 0<N := by
  by_contra hn
  have hN : N=0 := by omega
  subst N
  have hx := hw.1.1 (fun _ => false)
  simp [networkOutput] at hx
  linarith [hx.1]

theorem repair_output_support {d N M r : ℕ} {Λ U : ℝ} {g : BooleanFunction d}
    (hU : 1<U) (w : Weights d N r) (hw : w ∈ functionSupport Λ U g)
    (a : Cube d) (y : Bool) (u : Weights d M r)
    (hout : ∀ x, networkOutput Real.tanh u x =
      networkOutput Real.tanh w x+(if x=a then labelReal y-networkOutput Real.tanh w a else 0))
    (hg : gainSq u<Λ^2*((r : ℝ)+1)*readoutEnergy u) :
    u ∈ functionSupport Λ U (Function.update g a y) := by
  constructor
  · refine ⟨?_,hg⟩
    intro x
    rw [hout]
    by_cases hx : x=a
    · subst x
      simp only [↓reduceIte,add_sub_cancel_left]
      cases y <;> norm_num [labelReal] <;> exact hU
    · simpa [hx] using hw.1.1 x
  · intro x
    rw [hout]
    by_cases hx : x=a
    · subst x
      simp only [↓reduceIte,add_sub_cancel_left,Function.update_self]
      cases y <;> norm_num [labelReal]
    · simpa [hx] using hw.2 x

/-- The repair remains inside the actual prior support and has square-root
energy arbitrarily close to the old square-root energy plus sqrt(P). -/
theorem exists_repaired_network {d N r : ℕ} (hd : 0<d) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) {g : BooleanFunction d}
    (w : Weights d N r) (hw : w ∈ functionSupport Λ U g)
    (a : Cube d) (y : Bool) (ε : ℝ) (hε : 0<ε) :
    ∃ M : ℕ, 0<M ∧ ∃ u : Weights d M r,
      u ∈ functionSupport Λ U (Function.update g a y) ∧
      Real.sqrt (weightedSquaredNorm u) <
        Real.sqrt (weightedSquaredNorm w)+Real.sqrt (repairBudget d r U)+ε := by
  let t := labelReal y-networkOutput Real.tanh w a
  have hP : 0<repairBudget d r U := repairBudget_pos d r U
  have hK := functionSupport_energy_pos w hw
  have hsK := Real.sqrt_nonneg (weightedSquaredNorm w)
  have hsP := Real.sqrt_pos.mpr hP
  by_cases ht : t=0
  · have hsame : Function.update g a y=g := by
      apply Function.update_eq_self_iff.mpr
      have hwa := hw.2 a
      have ht' : networkOutput Real.tanh w a=labelReal y := by dsimp [t] at ht; linarith
      rw [ht'] at hwa
      cases hga : g a <;> cases hy : y <;> simp_all [labelReal] <;> norm_num at hwa
    refine ⟨N,supported_width_pos w hw,w,?_,?_⟩
    · simpa [hsame] using hw
    · linarith
  obtain ⟨M,hM,v,hvout,hvenergy,hvgain⟩ := exists_singleton_network hd a r t Λ ht hΛ
  have htbound : t^2≤(U+1)^2 := by
    have hwa := hw.1.1 a
    have hyabs : |labelReal y|=1 := by cases y <;> norm_num [labelReal]
    have ha : |t|≤U+1 := by
      calc
        |t| ≤ |labelReal y|+|networkOutput Real.tanh w a| := abs_sub _ _
        _ ≤ U+1 := by rw [hyabs]; linarith [hwa.2]
    nlinarith [abs_nonneg t,sq_abs t]
  have hvP : weightedSquaredNorm v≤repairBudget d r U := by
    have hQ : 0≤singletonReadoutBudget (r+1) := by unfold singletonReadoutBudget; positivity
    exact hvenergy.trans (by unfold repairBudget; nlinarith)
  have hvpositive : 0<weightedSquaredNorm v := by
    have ho : networkOutput Real.tanh v a≠0 := by simpa [hvout] using ht
    exact (readoutEnergy_pos_of_output_ne_zero v a ho).trans_le (readoutEnergy_le_weightedSquaredNorm v)
  let S := Real.sqrt (weightedSquaredNorm w)+Real.sqrt (repairBudget d r U)
  have hS : 0<S := by dsimp [S]; positivity
  let δ := (S+ε)^2-S^2
  have hδ : 0<δ := by dsimp [δ]; nlinarith
  obtain ⟨J,hJ,u,huout,huenergy,hugain⟩ := exists_parallel_network (supported_width_pos w hw) hM
    w v Λ hw.1.2 hvgain hK hvpositive δ hδ
  refine ⟨J,hJ,u,?_,?_⟩
  · apply repair_output_support hU w hw a y u _ hugain
    intro x
    rw [huout,hvout]
  · have hvroot : Real.sqrt (weightedSquaredNorm v)≤Real.sqrt (repairBudget d r U) := Real.sqrt_le_sqrt hvP
    have hsq : (Real.sqrt (weightedSquaredNorm w)+Real.sqrt (weightedSquaredNorm v))^2≤S^2 := by
      dsimp [S]
      nlinarith [Real.sqrt_nonneg (weightedSquaredNorm v)]
    have hu : weightedSquaredNorm u<(S+ε)^2 := by dsimp [δ] at huenergy; linarith
    have hroot := Real.sq_sqrt (weightedSquaredNorm_nonneg u)
    change Real.sqrt (weightedSquaredNorm u)<S+ε
    nlinarith [Real.sqrt_nonneg (weightedSquaredNorm u)]

end
end NeuralGeneralization.BatchTwoNeuralConverse
