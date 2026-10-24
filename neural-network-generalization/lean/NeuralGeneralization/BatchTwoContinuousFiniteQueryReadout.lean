import NeuralGeneralization.BatchTwoContinuousFiniteReadout
import NeuralGeneralization.BatchTwoContinuousFiniteQueryModel

/-! Approximate dual readouts for the real-output network on finite queries. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 800000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open ConcreteModel TowerNetwork
variable {d q N r : ℕ}

theorem exists_approximate_covariance_readout (hN : 0<N)
    (xs : Cube q → RealInput d) (w : Weights d N r) {K η : ℝ}
    (hK : 0<K) (hη : 0<η)
    (henergy : (N : ℝ)*(∑ i,w (.inr (.inr i))^2)≤K) :
    ∃ β : Cube q → ℝ, (∑ x,|β x|)≤K/η ∧ ∀ x,
      |output Real.tanh w (xs x)-∑ y,β y*covariance xs w x y|≤η := by
  let h : Cube q → EuclideanSpace ℝ (Fin N) := fun x =>
    WithLp.toLp 2 (fun i => BatchTwoContinuous.finalHidden Real.tanh w (xs x) i/Real.sqrt N)
  let u : EuclideanSpace ℝ (Fin N) :=
    WithLp.toLp 2 (fun i => Real.sqrt N*w (.inr (.inr i)))
  have hsqrt : Real.sqrt (N : ℝ)≠0 := (Real.sqrt_pos.mpr (by exact_mod_cast hN)).ne'
  have hu : ‖u‖^2≤K := by
    have he := EuclideanSpace.real_norm_sq_eq u
    simp only [u,PiLp.toLp_apply,mul_pow,Real.sq_sqrt (Nat.cast_nonneg N),←Finset.mul_sum] at he
    rw [he]
    exact henergy
  have hread (x : Cube q) : inner ℝ (h x) u=output Real.tanh w (xs x) := by
    simp only [h,u,PiLp.inner_apply,RCLike.inner_apply,PiLp.toLp_apply,conj_trivial,
      output]
    apply Finset.sum_congr rfl
    intro i _
    field_simp
  have hgram (x y : Cube q) : inner ℝ (h x) (h y)=covariance xs w x y := by
    simp only [h,PiLp.inner_apply,RCLike.inner_apply,PiLp.toLp_apply,conj_trivial,
      covariance,Finset.sum_div]
    apply Finset.sum_congr rfl
    intro i _
    rw [div_mul_div_comm,←sq,Real.sq_sqrt (Nat.cast_nonneg N)]
    ring
  obtain ⟨β,hβ,hpred⟩ := FiniteReadout.exists_approximate_dual h u hK hη hu
  exact ⟨β,hβ,fun x => by simpa only [hread,hgram] using hpred x⟩

def covarianceReadout (xs : Cube q → RealInput d) (w : Weights d N r) (β : Cube q → ℝ) : Fin N → ℝ :=
  fun i => (∑ x,β x*BatchTwoContinuous.finalHidden Real.tanh w (xs x) i)/(N : ℝ)

theorem covarianceReadout_output (xs : Cube q → RealInput d) (w : Weights d N r)
    (β : Cube q → ℝ) (x : Cube q) :
    output Real.tanh (withReadout w (covarianceReadout xs w β)) (xs x)=
      ∑ y,β y*covariance xs w x y := by
  have hh : ∀ v x, BatchTwoContinuous.finalHidden Real.tanh (withReadout w v) x=
      BatchTwoContinuous.finalHidden Real.tanh w x := fun _ _ => rfl
  simp only [output,withReadout,hh,covarianceReadout,covariance,Finset.sum_div,
    div_mul_eq_mul_div,mul_div_assoc,Finset.sum_mul,Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro y _
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem covarianceReadout_bound (xs : Cube q → RealInput d) (w : Weights d N r)
    (β : Cube q → ℝ) {K : ℝ} (hβ : (∑ x,|β x|)≤K) {i : Fin N} :
    |covarianceReadout xs w β i|≤K/(N : ℝ) := by
  unfold covarianceReadout
  rw [abs_div,abs_of_nonneg (Nat.cast_nonneg N : (0 : ℝ)≤N)]
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg N)
  calc
    _ ≤ ∑ x,|β x*BatchTwoContinuous.finalHidden Real.tanh w (xs x) i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ x,|β x| := by
      apply Finset.sum_le_sum
      intro x _
      rw [abs_mul]
      have hh := TowerNetwork.finalHidden_tanh_abs_le_one (freezeInput (xs x) w) (fun _ => false) i
      rw [finalHidden_freeze] at hh
      simpa only [mul_one] using mul_le_mul_of_nonneg_left hh (abs_nonneg (β x))
    _ ≤ K := hβ

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
