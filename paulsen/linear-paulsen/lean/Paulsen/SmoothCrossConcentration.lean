import Paulsen.RegularizedLaplacianWhitening
import Paulsen.SmoothSchurConcentration
import Mathlib.Analysis.Complex.ExponentialBounds

/-! Concentration of the actual retained tangent graph's whitened linear term. -/
namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory
noncomputable section
variable {κ : Type*} [Fintype κ] [DecidableEq κ]

def whitenedGaussianGraphCross {n : ℕ} (P M : Matrix (Fin n) (Fin n) ℝ)
    (C : Matrix (Fin n × Fin n) κ ℝ) (t : ℝ) (g : EuclideanSpace ℝ κ) :
    Matrix (Fin n) (Fin n) ℝ :=
  M * graphLinearCross P (gaussianMatrixImage C g) t * M.transpose

theorem whitenedGaussianGraphCross_series {n : ℕ}
    (P M : Matrix (Fin n) (Fin n) ℝ) (hP : ∀ i j, P i j=P j i)
    (C : Matrix (Fin n × Fin n) κ ℝ) (hC : ∀ s i j, C (i,j) s=C (j,i) s)
    (t : ℝ) (g : EuclideanSpace ℝ κ) :
    whitenedGaussianGraphCross P M C t g =
      gaussianMatrixSeries (correlatedMatrixCoefficient (whitenedGraphCoefficient P M t) C)
        (fun s => g s) := by
  rw [correlatedMatrixCoefficient_series]
  have hY (i j : Fin n) : gaussianMatrixImage C g i j = gaussianMatrixImage C g j i := by
    simp only [gaussianMatrixImage, frameOfVector, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct]
    simp_rw [hC _ i j]
  exact (whitenedGraphCoefficient_series P M (gaussianMatrixImage C g) t hP hY).symm

/-- At regularization `(d/n)t²`, the actual retained cross series has variance
at most `8/d`, regardless of the number of ambient Gaussian coordinates. -/
theorem retainedTangentGraphCross_variance_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d) {ρ : ℝ} (hρ : 0≤ρ)
    {t : ℝ} (ht : t≠0) (M : Matrix (Fin n) (Fin n) ℝ)
    (hM : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖^2 ≤
      1/((d:ℝ)/n*t^2))
    (hframe : (1-M*projectionLaplacian (frameProjection U)*M.transpose).PosSemidef) :
    ((8/(d:ℝ)) • (1 : Matrix (Fin n) (Fin n) ℝ) -
      ∑ s, (correlatedMatrixCoefficient (whitenedGraphCoefficient (frameProjection U) M t)
        (retainedTangentFactor U ρ) s)^2).PosSemidef := by
  have hh := whitenedGraphCorrelated_variance_le (frameProjection U) M t
    (frameProjection_symm U) hU.frameProjection_idempotent (by positivity : (0:ℝ)≤2/(n:ℝ))
    hM hframe (retainedTangentFactor U ρ) (retainedTangentFactor_operator_norm_sq_le hU hρ)
  have he : (2/(n:ℝ))*(4*t^2*(1/((d:ℝ)/n*t^2)))=8/(d:ℝ) := by
    have hn' : (n:ℝ)≠0 := (Nat.cast_pos.mpr hn).ne'
    have hd' : (d:ℝ)≠0 := (Nat.cast_pos.mpr hd).ne'
    field_simp
    ring
  simpa only [he] using hh

/-- A genuine inverse-square-root whitener exists and the resulting cross term
has a logarithmic expected-norm bound and an exponential tail. -/
theorem exists_retainedTangentGraphCross_concentration {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d) {ρ : ℝ} (hρ : 0≤ρ)
    {t : ℝ} (ht : t≠0) :
    ∃ M : Matrix (Fin n) (Fin n) ℝ, M.PosDef ∧
      M * (projectionLaplacian (frameProjection U) + ((d:ℝ)/n*t^2) • 1) * M.transpose = 1 ∧
      (∫ g, ‖(Matrix.toEuclideanLin
        (whitenedGaussianGraphCross (frameProjection U) M (retainedTangentFactor U ρ) t g)).toContinuousLinearMap‖
        ∂stdGaussian (FrameVector n d)) ≤
        2*Real.sqrt (16*Real.exp 1*(Real.log (n:ℝ)+2)/(d:ℝ)) ∧
      ∀ (p : ℕ), 0<p → ∀ (u : ℝ), 0<u →
        16*Real.exp 1*(p:ℝ)/(d:ℝ)≤u^2 →
        (stdGaussian (FrameVector n d)).real
          {g | u≤‖(Matrix.toEuclideanLin
            (whitenedGaussianGraphCross (frameProjection U) M (retainedTangentFactor U ρ) t g)).toContinuousLinearMap‖}
          ≤ (n:ℝ)*Real.exp (-(p:ℝ)) := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hd' : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have hr : 0<(d:ℝ)/n*t^2 := mul_pos (div_pos hd' hn') (sq_pos_of_ne_zero ht)
  obtain ⟨M,hMp,hW,hframe,hM⟩ := exists_regularized_whitener
    (projectionLaplacian (frameProjection U)) hU.laplacian_posSemidef hr
  let A := correlatedMatrixCoefficient (whitenedGraphCoefficient (frameProjection U) M t)
    (retainedTangentFactor U ρ)
  have hA : ∀ s, (A s).IsHermitian :=
    correlatedMatrixCoefficient_isHermitian _ (whitenedGraphCoefficient_isHermitian _ _ _) _
  have hvar := retainedTangentGraphCross_variance_le hU hn hd hρ ht M hM hframe
  have hseries (g : FrameVector n d) :
      whitenedGaussianGraphCross (frameProjection U) M (retainedTangentFactor U ρ) t g =
      gaussianMatrixSeries A (fun s => g s) :=
    whitenedGaussianGraphCross_series _ _ (frameProjection_symm U) _ (retainedTangentFactor_symmetric U ρ) t g
  refine ⟨M,hMp,hW,?_,?_⟩
  · letI : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
    simp_rw [hseries]
    have hh := stdGaussian_matrixSeries_expected_operator_norm_le A hA (8/(d:ℝ)) (by positivity) hvar
    convert hh using 1
    simp only [Fintype.card_fin]
    congr 2
    ring
  · intro p hp u hu hu2
    simp_rw [hseries]
    have he : 2*Real.exp 1*(p:ℝ)*(8/(d:ℝ))=16*Real.exp 1*(p:ℝ)/(d:ℝ) := by ring
    simpa only [Fintype.card_fin] using
      stdGaussian_matrixSeries_operator_norm_tail_exp A hA (8/(d:ℝ)) (by positivity)
        hvar p hp u hu (by simpa only [he] using hu2)

/-- An explicit logarithmic dimension assumption gives a one-percent failure
bound for the same actual whitened graph cross term. -/
theorem exists_retainedTangentGraphCross_failure_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d) {ρ : ℝ} (hρ : 0≤ρ)
    {t δ : ℝ} (ht : t≠0) (hδ : 0<δ)
    (hlarge : 10000*(Real.log (n:ℝ)+2)≤δ^2*d) :
    ∃ M : Matrix (Fin n) (Fin n) ℝ, M.PosDef ∧
      M * (projectionLaplacian (frameProjection U) + ((d:ℝ)/n*t^2) • 1) * M.transpose = 1 ∧
      (stdGaussian (FrameVector n d)).real
        {g | δ≤‖(Matrix.toEuclideanLin
          (whitenedGaussianGraphCross (frameProjection U) M (retainedTangentFactor U ρ) t g)).toContinuousLinearMap‖}
        ≤ 1/100 := by
  obtain ⟨M,hM,hW,_hexp,htail⟩ := exists_retainedTangentGraphCross_concentration hU hn hd hρ ht
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hd' : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have hn1 : (1:ℝ)≤n := by exact_mod_cast hn
  have hlog : 0≤Real.log (n:ℝ) := Real.log_nonneg hn1
  let p : ℕ := ⌈Real.log (n:ℝ)⌉₊ + 100
  have hp : 0<p := by omega
  have hplower : Real.log (n:ℝ)+100≤(p:ℝ) := by
    have hh := Nat.le_ceil (Real.log (n:ℝ))
    simp only [p, Nat.cast_add, Nat.cast_ofNat]
    linarith
  have hpupper : (p:ℝ)≤Real.log (n:ℝ)+101 := by
    have hh := Nat.ceil_lt_add_one hlog
    simp only [p, Nat.cast_add, Nat.cast_ofNat]
    linarith
  have hu2 : 16*Real.exp 1*(p:ℝ)/(d:ℝ)≤δ^2 := by
    apply (div_le_iff₀ hd').mpr
    have he := mul_le_mul_of_nonneg_right Real.exp_one_lt_three.le
      (show 0≤16*(p:ℝ) by positivity)
    nlinarith only [he, hpupper, hlog, hlarge]
  have hprob : (n:ℝ)*Real.exp (-(p:ℝ))≤1/100 := by
    calc
      _ ≤ (n:ℝ)*Real.exp (-(Real.log (n:ℝ)+100)) := by gcongr
      _ = Real.exp (-100) := by
        rw [neg_add, Real.exp_add, Real.exp_neg (Real.log n), Real.exp_log hn']
        field_simp
      _ ≤ 1/100 := by
        rw [Real.exp_neg, ← one_div]
        apply (div_le_iff₀ (Real.exp_pos _)).mpr
        linarith [Real.add_one_le_exp (100:ℝ)]
  refine ⟨M,hM,hW,?_⟩
  exact (htail p hp δ hδ hu2).trans hprob

/-- The cross estimate directly in the original graph energy; no whitener or
spectral-inverse estimate is assumed by this probability statement. -/
theorem retainedTangentGraphCross_energy_failure_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d) {ρ : ℝ} (hρ : 0≤ρ)
    {t δ : ℝ} (ht : t≠0) (hδ : 0<δ)
    (hlarge : 10000*(Real.log (n:ℝ)+2)≤δ^2*d) :
    (stdGaussian (FrameVector n d)).real {g |
      ∃ x : Fin n → ℝ,
        δ*(matrixQuadratic (projectionLaplacian (frameProjection U)) x +
          ((d:ℝ)/n*t^2)*vectorNormSq x) <
        |matrixQuadratic (graphLinearCross (frameProjection U)
          (gaussianMatrixImage (retainedTangentFactor U ρ) g) t) x|} ≤ 1/100 := by
  obtain ⟨M,hM,hW,hprob⟩ := exists_retainedTangentGraphCross_failure_le hU hn hd hρ ht hδ hlarge
  refine (measureReal_mono ?_).trans hprob
  intro g hg
  change δ ≤ ‖(Matrix.toEuclideanLin
    (whitenedGaussianGraphCross (frameProjection U) M (retainedTangentFactor U ρ) t g)).toContinuousLinearMap‖
  by_contra hbad
  have hb := (lt_of_not_ge hbad).le
  obtain ⟨x,hx⟩ := hg
  have hh := quadratic_cross_le_of_whitened_norm
    (projectionLaplacian (frameProjection U) + ((d:ℝ)/n*t^2) • 1)
    (graphLinearCross (frameProjection U) (gaussianMatrixImage (retainedTangentFactor U ρ) g) t)
    M hM hW hb (WithLp.toLp 2 x)
  have hreg : euclideanQuadratic
      (projectionLaplacian (frameProjection U) + ((d:ℝ)/n*t^2) • 1) (WithLp.toLp 2 x) =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x +
        ((d:ℝ)/n*t^2)*vectorNormSq x := by
    simp only [euclideanQuadratic, map_add, map_smul, LinearMap.add_apply,
      LinearMap.smul_apply, inner_add_right, real_inner_smul_right]
    simp only [Matrix.toEuclideanLin, Matrix.toLpLin_one, LinearMap.id_apply,
      real_inner_self_eq_norm_sq, EuclideanSpace.real_norm_sq_eq]
    change euclideanQuadratic (projectionLaplacian (frameProjection U)) (WithLp.toLp 2 x) + _ = _
    rw [euclideanQuadratic_eq_matrixQuadratic]
    rfl
  rw [hreg, euclideanQuadratic_eq_matrixQuadratic] at hh
  exact (not_lt_of_ge hh) hx

end
end Paulsen.Smooth
