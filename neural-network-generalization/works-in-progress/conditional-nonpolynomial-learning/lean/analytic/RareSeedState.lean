import RareSeedMoments

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization

variable {d : ℕ}

def rareSeedSignal (f : ClippingCube d→ℝ) (σ θ : ℝ) : ℝ :=
  θ/(fourierSeedNormalizer f σ)^2

def rareSeedResidual (f : ClippingCube d→ℝ) (σ θ : ℝ) : ℝ :=
  rareSeedDiagonal f σ θ-rareSeedSignal f σ θ

theorem rareSeedSignal_pos (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) (hθ : 0 < θ) :
    0 < rareSeedSignal f σ θ := div_pos hθ (sq_pos_of_pos (fourierSeedNormalizer_pos f σ hf hσ))

theorem rareSeedResidual_nonneg (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hbool : ∀ x,(f x)^2=1) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (hθ0 : 0 < θ) (hθ1 : θ ≤ 1) : 0 ≤ rareSeedResidual f σ θ :=
  sub_nonneg.mpr (rareSeedDiagonal_signal_le f σ θ hf hbool hσ hθ0 hθ1)

theorem rareSeedState_total_le (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (hθ0 : 0 ≤ θ) (hθ1 : θ ≤ 1) :
    rareSeedSignal f σ θ+rareSeedResidual f σ θ ≤ 1 := by
  have hh := (rareSeedDiagonal_bounds f σ θ hf hσ hθ0 hθ1).2
  unfold rareSeedResidual
  linarith

theorem rareSeedSignal_sqrt (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2) (hθ : 0 ≤ θ) :
    Real.sqrt (rareSeedSignal f σ θ)=Real.sqrt θ/fourierSeedNormalizer f σ := by
  unfold rareSeedSignal
  rw [Real.sqrt_div hθ,Real.sqrt_sq (fourierSeedNormalizer_pos f σ hf hσ).le]

theorem rareFourierSeed_canonical_moment (f : ClippingCube d→ℝ) (σ θ : ℝ)
    (hf : ∃ x,f x ≠ 0) (hbool : ∀ x,(f x)^2=1) (hσ : ((d : ℝ)+1)*σ^2 ≤ 2)
    (hθ0 : 0 < θ) (hθ1 : θ ≤ 1) (x : ClippingCube d) :
    canonicalCompletion
      (∫ z,rareSeedScore θ z*tanhCubeFeature z.2 x
        ∂rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ))
      (∫ z,tanhCubeFeature z.2 x ^ 2
        ∂rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw f σ))=
      WithLp.toLp 2 (Real.sqrt (rareSeedSignal f σ θ)*f x,Real.sqrt (rareSeedResidual f σ θ)) := by
  have hc := rareFourierSeed_correlation f σ θ hf hσ (seedGaussianReference σ) hθ0 hθ1 x
  have hd := rareFourierSeed_constant_diagonal f σ θ hf hσ hθ0.le hθ1 x (fun _ => true)
  rw [hc,hd]
  change canonicalCompletion _ (rareSeedDiagonal f σ θ)=_
  rw [← rareSeedSignal_sqrt f σ θ hf hσ hθ0.le]
  unfold canonicalCompletion
  simp only [Real.norm_eq_abs,sq_abs,mul_pow,Real.sq_sqrt (rareSeedSignal_pos f σ θ hf hσ hθ0).le,
    hbool,mul_one]
  have hr := rareSeedResidual_nonneg f σ θ hf hbool hσ hθ0 hθ1
  change 0 ≤ rareSeedDiagonal f σ θ-rareSeedSignal f σ θ at hr
  rw [max_eq_right hr]
  rfl

#print axioms rareFourierSeed_canonical_moment
end ConditionalNonpolynomial.Analytic
