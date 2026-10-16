import NeuralGeneralization.GaussianReadout
import NeuralGeneralization.UniformGaussianMarginRate

/-! Equality of actual Gaussian margin laws and uniqueness of their
quadratic rates across different Gaussian feature representations. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators Topology NNReal
namespace NeuralGeneralization.GaussianMarginLaw
open GaussianRate GaussianMarginGeometry GaussianReadout
variable {I I' X : Type*} [Fintype I] [Fintype I'] [Fintype X]

def fieldMargin (s : X → ℝ) (a : ℝ) : Set (EuclideanSpace ℝ X) :=
  {z | ∀ x, a < s x * z x}

def signedCoefficients (H : I → X → ℝ) (s : X → ℝ) : X → I → ℝ :=
  fun x i => s x * H i x

theorem isOpen_fieldMargin (s : X → ℝ) (a : ℝ) : IsOpen (fieldMargin s a) := by
  have he : fieldMargin s a = ⋂ x, {z | a < s x * z x} := by
    ext z
    simp only [fieldMargin, Set.mem_setOf_eq, Set.mem_iInter]
  rw [he]
  exact isOpen_iInter_of_finite (fun x => isOpen_lt continuous_const (by fun_prop))

omit [Fintype X] in
theorem readout_preimage_fieldMargin (H : I → X → ℝ) (s : X → ℝ) (a : ℝ) :
    readout H ⁻¹' fieldMargin s a = linearMargin (signedCoefficients H s) a := by
  ext z
  simp only [Set.mem_preimage, fieldMargin, Set.mem_setOf_eq, linearMargin,
    readout, signedCoefficients, Finset.mul_sum]
  apply forall_congr'
  intro x
  have he : (∑ i, s x * (z i * H i x)) = ∑ i, s x * H i x * z i := by
    apply Finset.sum_congr rfl
    intro i hi
    ring
  rw [he]

theorem mapped_fieldMargin_mass (H : I → X → ℝ) (s : X → ℝ) (a t : ℝ) :
    ((Measure.pi fun _ : I => gaussianReal 0 t.toNNReal).map (readout H)).real (fieldMargin s a) =
      isotropicMass (linearMargin (signedCoefficients H s) a) t := by
  rw [Measure.real, Measure.map_apply (continuous_readout _).measurable
    (isOpen_fieldMargin s a).measurableSet, readout_preimage_fieldMargin]
  rfl

/-- Identical actual Gaussian Gram matrices give identical strict-margin
probabilities at every variance. -/
theorem isotropic_margin_mass_eq_of_gram (H : I → X → ℝ) (H' : I' → X → ℝ)
    (hgram : ∀ x y, gram H x y = gram H' x y) (s : X → ℝ) (a t : ℝ) :
    isotropicMass (linearMargin (signedCoefficients H s) a) t =
      isotropicMass (linearMargin (signedCoefficients H' s) a) t := by
  have he := law_eq_of_gram_eq H H' t.toNNReal t.toNNReal (fun x y => by rw [hgram])
  have hm := congrArg (fun μ : Measure (EuclideanSpace ℝ X) => μ.real (fieldMargin s a)) he
  simpa only [mapped_fieldMargin_mass] using hm

/-- A positive diverging speed determines at most one exponential rate. -/
theorem rate_unique {T : Type*} {l : Filter T} [NeBot l]
    {speed w : T → ℝ} {E F : ℝ} (hs : Tendsto speed l atTop)
    (hE : HasExponentialRate l speed w E) (hF : HasExponentialRate l speed w F) : E = F := by
  have hle {E F : ℝ} (hE : HasExponentialRate l speed w E)
      (hF : HasExponentialRate l speed w F) : E ≤ F := by
    by_contra hnot
    have hFE : F < E := lt_of_not_ge hnot
    let ε := (E - F) / 4
    have hε : 0 < ε := by dsimp [ε]; linarith
    obtain ⟨n, hnE, hnF, hns⟩ := ((hE ε hε).and ((hF ε hε).and
      (hs.eventually (eventually_gt_atTop (0 : ℝ))))).exists
    have he := Real.exp_le_exp.mp (hnF.1.trans hnE.2)
    have hdiff : 0 < E - F - 2 * ε := by dsimp [ε]; linarith
    have hp := mul_pos hdiff hns
    nlinarith
  exact le_antisymm (hle hE hF) (hle hF hE)

/-- The infimum quadratic energy does not depend on which finite Gaussian
feature representation of a covariance was chosen. -/
theorem squareInf_margin_eq_of_gram (H : I → X → ℝ) (H' : I' → X → ℝ)
    (hgram : ∀ x y, gram H x y = gram H' x y) (s : X → ℝ) (a : ℝ)
    (hne : (linearMargin (signedCoefficients H s) a).Nonempty)
    (hne' : (linearMargin (signedCoefficients H' s) a).Nonempty) :
    squareInf (linearMargin (signedCoefficients H s) a) =
      squareInf (linearMargin (signedCoefficients H' s) a) := by
  have hrate := gaussian_open_event_hasExponentialRate
    (isOpen_linearMargin (signedCoefficients H s) a) hne
  have hrate' := gaussian_open_event_hasExponentialRate
    (isOpen_linearMargin (signedCoefficients H' s) a) hne'
  have heq : isotropicMass (linearMargin (signedCoefficients H' s) a) =ᶠ[𝓝[>] (0 : ℝ)]
      isotropicMass (linearMargin (signedCoefficients H s) a) :=
    Eventually.of_forall (fun t => (isotropic_margin_mass_eq_of_gram H H' hgram s a t).symm)
  have hr := rate_unique
    (show Tendsto (fun t : ℝ => 1 / t) (𝓝[>] (0 : ℝ)) atTop by
      simpa only [one_div] using tendsto_inv_nhdsGT_zero)
    hrate (hrate'.congr heq)
  linarith

theorem signedCoefficients_close {H H' : I → X → ℝ} (s : X → ℝ)
    (hs : ∀ x, |s x| = 1) {δ : ℝ} (hδ : 0 < δ) (h : dist H H' < δ) :
    dist (signedCoefficients H s) (signedCoefficients H' s) < δ := by
  apply (dist_pi_lt_iff hδ).mpr
  intro x
  apply (dist_pi_lt_iff hδ).mpr
  intro i
  have hi := (dist_pi_lt_iff hδ).mp ((dist_pi_lt_iff hδ).mp h i) x
  simpa only [signedCoefficients, Real.dist_eq, ← mul_sub, abs_mul, hs, one_mul] using hi

end NeuralGeneralization.GaussianMarginLaw
