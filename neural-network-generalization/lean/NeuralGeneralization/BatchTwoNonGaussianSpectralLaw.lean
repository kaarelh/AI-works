import NeuralGeneralization.BatchTwoNonGaussianPowerScale
import NeuralGeneralization.BatchTwoNonGaussianApproximationTail
import NeuralGeneralization.NetworkSpectralTail

/-! Exact coordinate marginals and endpoint tails for the actual non-Gaussian
width-exponent network prior. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

theorem productLaw_map_subfamily {ι κ : Type*} [Fintype ι] [Fintype κ]
    (μ : Measure ℝ) [IsProbabilityMeasure μ] (e : κ → ι) (he : Function.Injective e) :
    (Measure.pi fun _ : ι => μ).map (fun x j => x (e j))=Measure.pi (fun _ : κ => μ) := by
  have hi : iIndepFun (fun i (x : ι → ℝ) => x i) (Measure.pi fun _ : ι => μ) :=
    iIndepFun_pi (X := fun _ => id) (fun _ => aemeasurable_id)
  have hh := (hi.precomp he).map_fun_eq_pi_map
    (fun j => (measurable_pi_apply (e j)).aemeasurable)
  simpa only [(measurePreserving_eval (fun _ : ι => μ) _).map_eq] using hh

theorem smallScale_eq_mul_coordinateScale {d N r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (i : WeightIndex d N r) :
    smallScale d N r σ i=σ*coordinateScale d N r i := by
  have hs := smallScale_sq (r := r) hd hN σ i
  have hc := coordinateScale_sq (r := r) hd hN i
  have he : smallVariance d N r σ i=σ^2*smallVariance d N r 1 i := by
    rcases i with ij | (sij | j) <;> simp [smallVariance] <;> ring
  rw [he] at hs
  have hsq : (smallScale d N r σ i)^2=(σ*coordinateScale d N r i)^2 := by
    rw [mul_pow,hc,hs]
  exact (sq_eq_sq₀ (smallScale_pos (r := r) hd hN hσ i).le
    (mul_pos hσ (coordinateScale_pos (r := r) hd hN i)).le).mp hsq

theorem map_powerPrior_whiten (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) :
    (powerPrior ν d N r γ).map whiten=
      scaledCoordinates ν (WeightIndex d N r) (powerStandardDeviation N γ) := by
  rw [powerPrior_eq_smallPrior_standardDeviation ν hd hN γ,smallPrior,productPrior_eq_map,
    Measure.map_map (continuous_whiten d N r).measurable (by fun_prop),scaledCoordinates_eq_map]
  congr 1
  funext z i
  simp only [Function.comp_apply,whiten]
  rw [smallScale_eq_mul_coordinateScale hd hN (powerStandardDeviation_pos hN γ)]
  field_simp [(coordinateScale_pos (r := r) hd hN i).ne']

theorem map_powerPrior_whiten_subfamily (ν : CoordinateLaw) {d N r : ℕ}
    {κ : Type*} [Fintype κ] (hd : 0 < d) (hN : 0 < N) (γ : ℝ)
    (e : κ → WeightIndex d N r) (he : Function.Injective e) :
    (powerPrior ν d N r γ).map (fun w j => whiten w (e j))=
      scaledCoordinates ν κ (powerStandardDeviation N γ) := by
  rw [show (fun (w : Weights d N r) j => whiten w (e j))=
    (fun (x : Weights d N r) j => x (e j)) ∘ whiten from rfl,
    ←Measure.map_map (measurable_pi_lambda _ fun j => measurable_pi_apply (e j))
      (continuous_whiten d N r).measurable,map_powerPrior_whiten ν hd hN γ]
  unfold scaledCoordinates
  have : IsProbabilityMeasure (ν.law.map (fun x => powerStandardDeviation N γ*x)) :=
    Measure.isProbabilityMeasure_map (by fun_prop)
  exact productLaw_map_subfamily _ e he

theorem powerPrior_whiten_subfamily_tail (ν : CoordinateLaw) {d N r : ℕ}
    {κ : Type*} [Fintype κ] (hd : 0 < d) (hN : 0 < N) (γ : ℝ)
    (e : κ → WeightIndex d N r) (he : Function.Injective e) (b : ℝ)
    (hb : 8*(Fintype.card κ : ℝ)*((N : ℝ)^(-γ)*subGaussianVariance ν) ≤ b) :
    (powerPrior ν d N r γ).real {w | b ≤ ∑ j, (whiten w (e j))^2} ≤
      Real.exp (-b/(8*((N : ℝ)^(-γ)*subGaussianVariance ν))) := by
  have hmeas : Measurable (fun w : Weights d N r => fun j => whiten w (e j)) :=
    measurable_pi_lambda _ fun j =>
      (measurable_pi_apply (e j)).comp (continuous_whiten d N r).measurable
  have hm := Measure.le_map_apply (μ := powerPrior ν d N r γ) hmeas.aemeasurable
    {z : κ → ℝ | b ≤ ∑ j, z j^2}
  rw [map_powerPrior_whiten_subfamily ν hd hN γ e he] at hm
  apply (ENNReal.toReal_mono (measure_ne_top _ _) hm).trans
  simpa only [powerStandardDeviation_sq hN,Measure.real] using
    scaled_squaredNorm_upper_tail (I := κ) ν (powerStandardDeviation_pos hN γ) b
      (by simpa only [powerStandardDeviation_sq hN] using hb)

theorem powerPrior_first_energy_tail (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ b : ℝ)
    (hb : 8*((N*(d+1) : ℕ) : ℝ)*((N : ℝ)^(-γ)*subGaussianVariance ν) ≤ b) :
    (powerPrior ν d N r γ).real
      {w | b ≤ (d : ℝ)/N*(∑ i, ∑ j, w (.inl (i,j))^2)} ≤
      Real.exp (-b/(8*((N : ℝ)^(-γ)*subGaussianVariance ν))) := by
  have h := powerPrior_whiten_subfamily_tail ν hd hN (r := r) γ
    (Sum.inl : Fin N × Fin (d+1) → WeightIndex d N r) Sum.inl_injective b (by simpa using hb)
  simpa only [first_energy_eq_whitened hd hN] using h

theorem powerPrior_readout_energy_tail (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ b : ℝ)
    (hb : 8*(N : ℝ)*((N : ℝ)^(-γ)*subGaussianVariance ν) ≤ b) :
    (powerPrior ν d N r γ).real {w | b ≤ (N : ℝ)*(∑ i, w (.inr (.inr i))^2)} ≤
      Real.exp (-b/(8*((N : ℝ)^(-γ)*subGaussianVariance ν))) := by
  have h := powerPrior_whiten_subfamily_tail ν hd hN (r := r) γ
    (fun i : Fin N => Sum.inr (Sum.inr i)) (Sum.inr_injective.comp Sum.inr_injective)
    b (by simpa using hb)
  simpa only [readout_energy_eq_whitened hd hN] using h

theorem map_powerPrior_internal (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ : ℝ) (s : Fin r) :
    (powerPrior ν d N r γ).map
      (fun w (ij : Fin N × Fin N) => w (.inr (.inl (s,ij.1,ij.2))))=
      scaledCoordinates ν (Fin N × Fin N) (powerStandardDeviation N γ) := by
  have he : Function.Injective
      (fun ij : Fin N × Fin N => (Sum.inr (Sum.inl (s,ij.1,ij.2)) : WeightIndex d N r)) := by
    intro ij kl h
    simpa using h
  simpa only [whiten_internal] using map_powerPrior_whiten_subfamily ν hd hN γ _ he

theorem powerPrior_internal_approximation_tail (ν : CoordinateLaw) {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) (γ a K B : ℝ) (s : Fin r)
    (hmat : (scaledCoordinates ν (Fin N × Fin N) (powerStandardDeviation N γ)).real
      (matrixApproximationFailure N a K) ≤ B) :
    (powerPrior ν d N r γ).real
      {w | (fun ij => w (.inr (.inl (s,ij.1,ij.2)))) ∈ matrixApproximationFailure N a K} ≤ B := by
  have hm := Measure.le_map_apply (μ := powerPrior ν d N r γ)
    (show Measurable (fun (w : Weights d N r) (ij : Fin N × Fin N) =>
      w (.inr (.inl (s,ij.1,ij.2)))) by fun_prop).aemeasurable (matrixApproximationFailure N a K)
  rw [map_powerPrior_internal ν hd hN γ s] at hm
  exact (ENNReal.toReal_mono (measure_ne_top _ _) hm).trans hmat

end NeuralGeneralization.BatchTwoNonGaussian
