import ReadoutFeatureTransport
import ProjectedReadoutFeasibility
import HilbertCovarianceRepair

noncomputable section
open scoped BigOperators InnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.TowerNetwork

variable {d N r : ℕ}

/-- The empirical-kernel normalization of the actual final hidden features. -/
def normalizedHiddenFeature (w : Weights d N r) (x : Cube d) : EuclideanSpace ℝ (Fin N) :=
  WithLp.toLp 2 (fun i => finalHidden Real.tanh w x i/Real.sqrt N)

/-- Physical projected readout expressed against the normalized hidden features. -/
def normalizedProjectedReadout (σ : ℝ) (w : Weights d N r) : EuclideanSpace ℝ (Fin N) :=
  WithLp.toLp 2 (fun i => Real.sqrt N*projectedReadout σ w i)

lemma normalizedProjectedReadout_output (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (w : Weights d N r) (x : Cube d) :
    inner ℝ (normalizedProjectedReadout σ w) (normalizedHiddenFeature w x)=
      networkOutput Real.tanh w x := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hsqrt : Real.sqrt N≠0 := (Real.sqrt_pos.mpr hn).ne'
  rw [← projectedReadout_preserves_output hN hσ w x]
  simp only [normalizedProjectedReadout,normalizedHiddenFeature,PiLp.inner_apply,
    Real.inner_apply,networkOutput,finalHidden_withReadout]
  apply Finset.sum_congr rfl
  intro i hi
  change (Real.sqrt N*projectedReadout σ w i)*(finalHidden Real.tanh w x i/Real.sqrt N)=
    projectedReadout σ w i*finalHidden Real.tanh w x i
  field_simp

lemma normalizedProjectedReadout_norm_sq (hN : 0<N) (σ : ℝ) (w : Weights d N r) :
    ‖normalizedProjectedReadout σ w‖^2=σ^2*projectedReadoutSquared σ w := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  rw [EuclideanSpace.norm_sq_eq]
  simp only [normalizedProjectedReadout,WithLp.ofLp_toLp,Real.norm_eq_abs,sq_abs,mul_pow,
    Real.sq_sqrt hn.le,← Finset.mul_sum]
  rw [projectedReadout_norm hN]
  field_simp

/-- Transport the actual finite-network readout to the repaired terminal
feature family, with exact energy normalization and no increase in its norm. -/
theorem actual_network_readout_transport {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (w : Weights d N r) (C D : Cube d → E)
    (hgram : ∀ x y, inner ℝ (C x) (C y)=
      inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y))
    (ε : ℝ) (hCD : ∀ x, ‖C x-D x‖ ≤ ε) :
    ∃ b : E, ‖b‖^2 ≤ σ^2*projectedReadoutSquared σ w ∧
      (∀ x, inner ℝ b (C x)=networkOutput Real.tanh w x) ∧
      ∀ x, |inner ℝ b (D x)-networkOutput Real.tanh w x| ≤
        Real.sqrt (σ^2*projectedReadoutSquared σ w)*ε := by
  obtain ⟨b,hb,hC,hD⟩ := transport_readout_with_error (normalizedHiddenFeature w) C D hgram
    (normalizedProjectedReadout σ w) ε hCD
  refine ⟨b,?_,?_,?_⟩
  · rw [← normalizedProjectedReadout_norm_sq hN]
    exact (sq_le_sq₀ (norm_nonneg _) (norm_nonneg _)).mpr hb
  · intro x
    exact (hC x).trans (normalizedProjectedReadout_output hN hσ w x)
  · intro x
    rw [← normalizedProjectedReadout_output hN hσ w x,
      ← normalizedProjectedReadout_norm_sq hN,Real.sqrt_sq (norm_nonneg _)]
    exact hD x

/-- The rate cost of the transported readout is at most the certificate's
projected readout rate. Here t²=Nσ² is kept exact, including tiny t. -/
lemma transported_readout_rate {E : Type*} [NormedAddCommGroup E]
    (hN : 0<N) {σ : ℝ} (hσ : 0<σ) (b : E) (P : ℝ)
    (hb : ‖b‖^2 ≤ σ^2*P) :
    ‖b‖^2/(2*((N:ℝ)*σ^2)) ≤ P/(2*N) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
  nlinarith [mul_le_mul_of_nonneg_right hb (show 0≤2*(N:ℝ) by positivity)]

end ConditionalNonpolynomial.Analytic
