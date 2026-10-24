import NeuralGeneralization.BatchTwoActivationReadoutCertificate
import NeuralGeneralization.MeanFieldReadout

/-! The actual unbounded-activation network readout has a bounded covariance
dual. Only readout energy and the original global margin are used. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem actual_readout_margin_dual {d N r : ℕ} (hN : 0<N)
    (φ : ℝ → ℝ) (w : Weights d N r) (f : BooleanFunction d) {K : ℝ}
    (hmargin : w∈marginEvent φ (1/2) f)
    (henergy : (N:ℝ)*(∑i,w (.inr (.inr i))^2)≤K) :
    ∃β : Cube d → ℝ, (∑x,|β x|)≤4*K ∧
      ∀x,(1:ℝ)≤labelReal (f x)*(∑y,β y*finalCovariance φ w x y) := by
  let h : Cube d → EuclideanSpace ℝ (Fin N) := fun x => WithLp.toLp 2 (finalHidden φ w x)
  let u : EuclideanSpace ℝ (Fin N) := WithLp.toLp 2 (fun j => w (.inr (.inr j)))
  have hreadout (x : Cube d) : inner ℝ (h x) u=networkOutput φ w x := by
    simp [h,u,PiLp.inner_apply,RCLike.inner_apply,networkOutput]
  have hgram (x y : Cube d) : inner ℝ (h x) (h y)=
      ∑j,finalHidden φ w x j*finalHidden φ w y j := by
    simp [h,PiLp.inner_apply,mul_comm]
  have hunorm : ‖u‖^2=∑j,w (.inr (.inr j))^2 := by
    simpa [u] using EuclideanSpace.real_norm_sq_eq u
  obtain ⟨β,hβ,hpred⟩ := ReadoutDual.exists_normalized_gram_dual h
    (fun x => labelReal (f x)) u (scale := (N:ℝ)) (energy := K)
    (by exact_mod_cast hN) (fun x => abs_labelReal (f x))
    (fun x => by rw [hreadout]; exact (hmargin x).le)
    (by simpa only [hunorm] using henergy)
  refine ⟨fun x => 2*β x,?_,?_⟩
  · simp only [abs_mul,abs_of_nonneg (by norm_num : (0:ℝ)≤2),←Finset.mul_sum]
    linarith
  · intro x
    have hi := hpred x
    simp only [hgram] at hi
    have hhalf : (1/2:ℝ)≤labelReal (f x)*(∑y,β y*finalCovariance φ w x y) := by
      simpa only [finalCovariance,←mul_div_assoc,←Finset.sum_div] using hi
    have he : labelReal (f x)*(∑y,(2*β y)*finalCovariance φ w x y)=
        2*(labelReal (f x)*(∑y,β y*finalCovariance φ w x y)) := by
      simp only [mul_assoc,←Finset.mul_sum]
      ring
    rw [he]
    linarith

theorem actual_readout_reconstructed_margin {d N r : ℕ} (hN : 0<N)
    (φ : ℝ → ℝ) (w : Weights d N r) (f : BooleanFunction d) {K : ℝ} (hK : 0<K)
    (hmargin : w∈marginEvent φ (1/2) f)
    (henergy : (N:ℝ)*(∑i,w (.inr (.inr i))^2)≤K) :
    ∃β : Cube d → ℝ, (∑x,|β x|)≤4*K ∧
      ∀Q' : Cube d → Cube d → ℝ,
        (∀x y,|Q' x y-finalCovariance φ w x y|≤1/(32*K)) → ∀x,
          (7/8:ℝ)≤labelReal (f x)*(∑y,β y*Q' x y) := by
  obtain ⟨β,hβ,hpred⟩ := actual_readout_margin_dual hN φ w f hmargin henergy
  refine ⟨β,hβ,?_⟩
  intro Q' hQ
  exact MeanFieldReadout.transported_margin (finalCovariance φ w) Q' β f hK hβ hpred
    (fun x y => by simpa only [abs_sub_comm] using hQ x y)

end NeuralGeneralization.BatchTwoActivation
