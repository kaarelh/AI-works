import NeuralGeneralization.BatchTwoActivationLayerDecomposition
import NeuralGeneralization.BatchTwoActivationDualRows

/-! A complete one-layer covariance certificate, on the actual Gaussian row
events: bounded quadratic tilt plus normalized residual atoms. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields GaussianFieldTilt BoundedDual
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I] {N n : ℕ}

theorem empirical_average_difference (v w : Fin N → ℝ) {D : ℝ} (hN : 0<N)
    (h : ∀j, |v j-w j|≤D) : |(∑j,v j)/(N:ℝ)-(∑j,w j)/(N:ℝ)|≤D := by
  rw [←sub_div,abs_div,abs_of_pos (show 0<(N:ℝ) from Nat.cast_pos.mpr hN),←Finset.sum_sub_distrib]
  apply (div_le_iff₀ (Nat.cast_pos.mpr hN)).2
  calc
    _ ≤ ∑j,|v j-w j| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑_j : Fin N,D := Finset.sum_le_sum (fun j _ => h j)
    _ = _ := by simp [mul_comm]

def layerResidualCovariance (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    (φ : ℝ → ℝ) (M a T : ℝ) (p q : I) : ℝ :=
  (∑j,cutoffTailWeight a T (fieldLinear c (x j)) *
    φ (linearObservation c (gaussianResidualSource c M (x j)) p) *
    φ (linearObservation c (gaussianResidualSource c M (x j)) q))/(N:ℝ)

theorem gaussian_layer_certificate (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    {φ : ℝ → ℝ} {ℓ M a T A b₀ b₁ b₂ D G K : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ) (hM : 0<M) (ha : 0<a) (hT : 0<T)
    (hBT : 2*gaussianBulkThreshold I M≤T)
    (hscale : Real.log (2*Fintype.card I)≤a*T)
    (hvar : ∀i, (∑j,(c i j)^2)≤M) (hN : 0<N)
    (henergy : ∑j, ‖gaussianResidualSource c M (x j)‖^2≤(N:ℝ)*A)
    (b : I → BoundedJet I b₀ b₁ b₂) (hb₀ : 0<b₀)
    (happrox : ∀p q z, |(b p).value z*(b q).value z-
      actualCutoffFeature φ a T p z*actualCutoffFeature φ a T q z|≤D)
    (hG : 0<G)
    (hgood : x ∉ scaledBadRows c (fun (pq : I×I) z => (b pq.1).value z*(b pq.2).value z)
      N (b₀^2) G K) :
    ∃Γ : I×I → ℝ, (∑j,|Γ j|)≤G ∧
      ∀p q, |(∑j,φ (fieldLinear c (x j) p)*φ (fieldLinear c (x j) q))/(N:ℝ)-
        (boundedFeatureCovariance c (fun i => (b i).value) Γ p q+
          layerResidualCovariance c x φ M a T p q)|≤
        6*ℓ^2*gaussianBulkThreshold I M*M*A/T+D+K/G := by
  let F : I×I → (I→ℝ) → ℝ := fun pq z => (b pq.1).value z*(b pq.2).value z
  have hF : ∀pq, Measurable (F pq) := fun pq =>
    (b pq.1).continuous.measurable.mul (b pq.2).continuous.measurable
  have hFb : ∀pq z, |F pq z|≤b₀^2 := fun pq z => by
    dsimp [F]
    rw [abs_mul,pow_two]
    exact mul_le_mul ((b pq.1).value_bound z) ((b pq.2).value_bound z)
      (abs_nonneg _) hb₀.le
  obtain ⟨Γ,hΓ,hent,hcert⟩ := exists_tilt_of_not_scaledBadRows c F hF
    (sq_pos_of_pos hb₀) hG hFb x hgood
  refine ⟨Γ,hΓ,?_⟩
  intro p q
  have hdecomp := gaussian_layer_cutoff_decomposition c x hφ hℓ hM ha hT hBT hscale
    hvar hN henergy p q
  have hobs (j : Fin N) : (fun i => linearObservation c (WithLp.toLp 2 (x j)) i) =
      fieldLinear c (x j) := by
    funext i
    simp only [linearObservation,fieldLinear_apply,PiLp.toLp_apply]
  simp only [hobs] at hdecomp
  change |(∑j,φ (fieldLinear c (x j) p)*φ (fieldLinear c (x j) q))/(N:ℝ)-
    ((∑j,actualCutoffFeature φ a T p (fieldLinear c (x j))*
      actualCutoffFeature φ a T q (fieldLinear c (x j)))/(N:ℝ)+
        layerResidualCovariance c x φ M a T p q)|≤_ at hdecomp
  have hsmooth := empirical_average_difference
    (fun j => (b p).value (fieldLinear c (x j))*(b q).value (fieldLinear c (x j)))
    (fun j => actualCutoffFeature φ a T p (fieldLinear c (x j))*
      actualCutoffFeature φ a T q (fieldLinear c (x j))) hN
    (fun j => happrox p q (fieldLinear c (x j)))
  have ht := hcert (p,q)
  change |(∑j,(b p).value (fieldLinear c (x j))*(b q).value (fieldLinear c (x j)))/(N:ℝ)-
    boundedFeatureCovariance c (fun i => (b i).value) Γ p q|≤K/G at ht
  have htri := abs_sub_le
    ((∑j,φ (fieldLinear c (x j) p)*φ (fieldLinear c (x j) q))/(N:ℝ))
    ((∑j,actualCutoffFeature φ a T p (fieldLinear c (x j))*
      actualCutoffFeature φ a T q (fieldLinear c (x j)))/(N:ℝ)+
        layerResidualCovariance c x φ M a T p q)
    (boundedFeatureCovariance c (fun i => (b i).value) Γ p q+
      layerResidualCovariance c x φ M a T p q)
  have htri' := abs_sub_le
    ((∑j,actualCutoffFeature φ a T p (fieldLinear c (x j))*
      actualCutoffFeature φ a T q (fieldLinear c (x j)))/(N:ℝ))
    ((∑j,(b p).value (fieldLinear c (x j))*(b q).value (fieldLinear c (x j)))/(N:ℝ))
    (boundedFeatureCovariance c (fun i => (b i).value) Γ p q)
  simp only [add_sub_add_right_eq_sub] at htri
  rw [abs_sub_comm] at hsmooth
  linarith

end NeuralGeneralization.BatchTwoActivation
