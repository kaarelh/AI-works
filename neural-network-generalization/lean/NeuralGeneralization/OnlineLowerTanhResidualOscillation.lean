import NeuralGeneralization.OnlineLowerTanhResidualWindow
import NeuralGeneralization.OnlineLowerGaussianOscillation

/-! # Uniformity in the unbounded external affine phase -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma oscillatory_L1_difference (f g p : ℝ → ℝ) (hf : Integrable f) (hg : Integrable g)
    (hpmeas : AEStronglyMeasurable p volume) (hp : ∀ x, |p x| ≤ 1) :
    |(∫ x, p x*f x)-(∫ x, p x*g x)| ≤ ∫ x, |f x-g x| := by
  have hpi : ∀ᵐ x ∂volume, ‖p x‖ ≤ 1 := Eventually.of_forall (fun x => by simpa using hp x)
  rw [← integral_sub (hf.bdd_mul hpmeas hpi) (hg.bdd_mul hpmeas hpi)]
  have hh := norm_integral_le_of_norm_le (μ := volume) (f := fun x => p x*f x-p x*g x)
    (by simpa only [Real.norm_eq_abs] using (hf.sub hg).norm)
    (Eventually.of_forall (fun x => by
      rw [← mul_sub, Real.norm_eq_abs, abs_mul]
      exact mul_le_of_le_one_left (abs_nonneg _) (hp x)))
  simpa only [Real.norm_eq_abs, Pi.sub_apply] using hh

lemma residualWindow_integrable {n : ℕ} (q d : Fin n → ℝ) (A s t δ M : ℝ) (K : ℝ → ℝ)
    (hM : 0 ≤ M) (horth : ∑ i, q i*d i = 0)
    (hscale : A^2*(∑ i, (q i)^2)*s^2 = 1) (hKmeas : Measurable K)
    (hangle : ∀ y, |y*s| ≤ δ → ∀ i, |A*q i*(y*s)+d i*(t+y*s)| ≤ Real.pi/2)
    (hK : ∀ y, |y*s| ≤ δ → |K (t+y*s)| ≤ M) :
    Integrable (residualWindow q d A s t δ K) := by
  apply ((integrable_exp_neg_mul_sq (by positivity : 0 < 2/Real.pi^2)).const_mul M).mono'
    (residualWindow_measurable q d A s t δ K hKmeas).aestronglyMeasurable
  exact Eventually.of_forall (fun y => by
    simpa only [Real.norm_eq_abs] using residualWindow_bound q d A s t δ M K hM horth hscale hangle hK y)

lemma residualWindowModel_integrable {n : ℕ} (d : Fin n → ℝ) (t : ℝ) (K : ℝ → ℝ) :
    Integrable (residualWindowModel d t K) := by
  have hi := (integrable_exp_neg_mul_sq (by norm_num : (0:ℝ)<1/2)).mul_const
    (Real.exp (-(∑ i, (d i)^2)*t^2/2)*K t)
  convert hi using 1
  funext y
  unfold residualWindowModel
  rw [show -y^2/2=-(1/2:ℝ)*y^2 by ring]
  ring

lemma residualWindowModel_sine_integral {n : ℕ} (d : Fin n → ℝ) (s t B θ : ℝ) (K : ℝ → ℝ) :
    (∫ y : ℝ, Real.sin (B*(t+y*s)+θ)*residualWindowModel d t K y) =
      Real.sqrt (2*Real.pi)*Real.exp (-(B*s)^2/2)*Real.sin (B*t+θ)*
        Real.exp (-(∑ i, (d i)^2)*t^2/2)*K t := by
  have he (y : ℝ) : Real.sin (B*(t+y*s)+θ)*residualWindowModel d t K y =
      (Real.exp (-(∑ i, (d i)^2)*t^2/2)*K t)*
        (Real.exp (-y^2/2)*Real.sin ((B*s)*y+(B*t+θ))) := by
    unfold residualWindowModel
    rw [show B*(t+y*s)+θ=(B*s)*y+(B*t+θ) by ring]
    ring
  simp_rw [he]
  rw [integral_const_mul, gaussian_sine_integral]
  ring

/-- The approximation is uniform in both real oscillatory parameters B and θ.
No bound on the external bias is used. -/
theorem residualWindow_uniform_sine_error (N : ℕ → ℕ)
    (q d : (k : ℕ) → Fin (N k) → ℝ) (A s t D : ℕ → ℝ)
    {Q E t₀ δ M : ℝ} (hδ : 0 < δ) (hM : 0 ≤ M)
    (hq : ∀ k i, |q k i| ≤ Q) (hd : ∀ k i, |d k i| ≤ D k)
    (horth : ∀ k, ∑ i, q k i*d k i = 0)
    (hAs : Tendsto (fun k => A k*s k) atTop (𝓝 0))
    (hs : Tendsto s atTop (𝓝 0)) (ht : Tendsto t atTop (𝓝 t₀))
    (hD : Tendsto D atTop (𝓝 0))
    (hE : Tendsto (fun k => ∑ i, (d k i)^2) atTop (𝓝 E))
    (hscale : ∀ k, (A k)^2*(∑ i, (q k i)^2)*(s k)^2 = 1)
    (K : ℝ → ℝ) (hKmeas : Measurable K) (hKcont : ContinuousAt K t₀)
    (hangle : ∀ᶠ k in atTop, ∀ y, |y*s k| ≤ δ → ∀ i,
      |A k*q k i*(y*s k)+d k i*(t k+y*s k)| ≤ Real.pi/2)
    (hKbound : ∀ᶠ k in atTop, ∀ y, |y*s k| ≤ δ → |K (t k+y*s k)| ≤ M) :
    ∀ ε > 0, ∀ᶠ k in atTop, ∀ B θ : ℝ,
      |(∫ y : ℝ, Real.sin (B*(t k+y*s k)+θ)*
          residualWindow (q k) (d k) (A k) (s k) (t k) δ K y) -
        Real.sqrt (2*Real.pi)*Real.exp (-(B*s k)^2/2)*Real.sin (B*t k+θ)*
          Real.exp (-(∑ i, (d k i)^2)*(t k)^2/2)*K (t k)| < ε := by
  intro ε hε
  have hL1 := residualWindow_L1 N q d A s t D hδ hM hq hd horth hAs hs ht hD hE
    hscale K hKmeas hKcont hangle hKbound
  filter_upwards [hangle,hKbound,hL1.eventually (gt_mem_nhds hε)] with k hang hKb herr B θ
  rw [← residualWindowModel_sine_integral (d k) (s k) (t k) B θ K]
  apply lt_of_le_of_lt _ herr
  apply oscillatory_L1_difference
  · exact residualWindow_integrable (q k) (d k) (A k) (s k) (t k) δ M K hM
      (horth k) (hscale k) hKmeas hang hKb
  · exact residualWindowModel_integrable (d k) (t k) K
  · exact (by fun_prop : Continuous (fun y : ℝ => Real.sin (B*(t k+y*s k)+θ))).aestronglyMeasurable
  · intro y
    exact Real.abs_sin_le_one _

end NeuralGeneralization.OnlineLowerTanh
