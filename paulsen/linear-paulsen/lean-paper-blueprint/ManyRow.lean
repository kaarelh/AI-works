import Paulsen.Paper.Gaussian
import Paulsen.Linear.ManyRow
import Paulsen.Paper.ManyRowAux2
import Paulsen.Paper.ManyRowAuxDense

/-!
# Paper blueprint, Section 4.1–4.3: the many-row seed, noise and identities
(`sections/manyrow.tex`)

Representation (library objects):
* `E = rowTangentSpace X`, `F = globalTangentSpace X` (subspaces of `FrameVector n d`);
* `Z = n^{-1/2} Π_F g = conditionedNoise X g`, `Z₀ = n^{-1/2} Π_E g = rowNoise X g`, with the
  *same* standard Gaussian `g ∼ stdGaussian (FrameVector n d)`;
* `V = tangentSeed X Z a t` (rows `(x_i + t z_i)/√(1+t² r_i)`), `V₀ = tangentSeed X Z₀ a t`;
* expectations are Bochner integrals against `stdGaussian (FrameVector n d)`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- The standard Gaussian on `ℝ^{n×d}`. -/
abbrev gaussFrame (n d : ℕ) : Measure (FrameVector n d) := stdGaussian (FrameVector n d)

/-- `Z₀ = n^{-1/2} Π_{𝓔} g`, the row-independent tangent noise. -/
def rowNoise {n d : ℕ} (X : Frame n d) (g : FrameVector n d) : Frame n d :=
  frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g)

/-- `m = dim 𝓔 - dim 𝓕`. -/
def mrCodim {n d : ℕ} (X : Frame n d) : ℝ :=
  (Module.finrank ℝ (rowTangentSpace X) : ℝ) - (Module.finrank ℝ (globalTangentSpace X) : ℝ)

/-! ## 4.1 The noise -/

/-- Definition of `m` (manyrow, "The noise").

TeX: "let $m=\dim\mathcal E-\dim\mathcal F\le\dim\mathrm{Sym}_d\le d^2\le n$."
(The last inequality uses the standing assumption `n ≥ B d²`, here `d² ≤ n`.) -/
theorem mr_codim_le {n d : ℕ} (X : Frame n d) (hX : IsEqualNorm X) (hd : 1 ≤ d) :
    0 ≤ mrCodim X ∧ mrCodim X ≤ (d : ℝ) * ((d : ℝ) + 1) / 2 ∧
    (d : ℝ) * ((d : ℝ) + 1) / 2 ≤ (d : ℝ) ^ 2 := by
  obtain ⟨hle, h2⟩ := mrx_codim_le_sym X
  have hm : mrCodim X = ((Module.finrank ℝ (rowTangentSpace X) -
      Module.finrank ℝ (globalTangentSpace X) : ℕ) : ℝ) := by
    unfold mrCodim; rw [Nat.cast_sub hle]
  have h2R : 2 * ((Module.finrank ℝ (rowTangentSpace X) -
      Module.finrank ℝ (globalTangentSpace X) : ℕ) : ℝ) ≤ (d : ℝ) * ((d : ℝ) + 1) := by
    exact_mod_cast h2
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  refine ⟨by rw [hm]; positivity, by rw [hm]; linarith, by nlinarith⟩

/-- Covariance claims of "The noise" (unnumbered).

TeX: "each row $z_i$ of $Z$ is Gaussian with covariance $\Sigma_i\preceq n^{-1}(I-e_ie_i^T)$,
and $\Cov(\mathrm{vec}\,Z)\preceq I/n$." (with $e_i=x_i/\sqrt a$; the same holds for
$Z_0$.) -/
theorem mr_noise_covariance {n d : ℕ} (hn : 0 < n) (X : Frame n d) (hX : IsEqualNorm X) :
    opNorm (tangentNoiseFactor X) ^ 2 ≤ 1 / (n : ℝ) ∧
    opNorm (rowTangentNoiseFactor X) ^ 2 ≤ 1 / (n : ℝ) ∧
    ∀ (i : Fin n) (v : Fin d → ℝ),
      ∫ g, (∑ j, conditionedNoise X g i j * v j) ^ 2 ∂gaussFrame n d ≤
        (1 / (n : ℝ)) * (vectorNormSq v -
          (∑ j, X i j / Real.sqrt ((d : ℝ) / n) * v j) ^ 2) := by
  refine ⟨tangentNoiseFactor_operator_norm_sq_le X hn,
    Linear.rowTangentNoiseFactor_operator_norm_sq_le' X hn, fun i v => ?_⟩
  rcases Nat.eq_zero_or_pos d with hd | hd
  · subst hd
    simp [vectorNormSq]
  · exact (mrx_conditioned_row_sq hn hd X hX i v).2

/-- `eq:mr-noise`.

TeX: "\E\fro Z^2=\frac{n(d-1)-m}{n}\le d,\qquad
 \E\fro{Z-Z_0}^2=\frac mn\le\frac{d^2}n ." -/
theorem eq_mr_noise {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (X : Frame n d)
    (hX : IsEqualNorm X) :
    ∫ g, frobSq (conditionedNoise X g) ∂gaussFrame n d =
        ((n : ℝ) * ((d : ℝ) - 1) - mrCodim X) / n ∧
    ((n : ℝ) * ((d : ℝ) - 1) - mrCodim X) / n ≤ (d : ℝ) ∧
    ∫ g, sqDistance (conditionedNoise X g) (rowNoise X g) ∂gaussFrame n d =
        mrCodim X / n ∧
    mrCodim X / n ≤ (d : ℝ) ^ 2 / n := by
  have hd0 : 0 < d := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  obtain ⟨hm0, hm1, hm2⟩ := mr_codim_le X hX hd
  have hE := Linear.rowTangentSpace_finrank X hn hd0 hX
  have hfrob : ∀ g, frobSq (conditionedNoise X g) =
      ‖Matrix.toEuclideanLin (tangentNoiseFactor X) g‖ ^ 2 := fun g =>
    totalEnergy_frameOfVector _
  have hint1 : ∫ g, frobSq (conditionedNoise X g) ∂gaussFrame n d =
      ((n : ℝ) * ((d : ℝ) - 1) - mrCodim X) / n := by
    simp_rw [hfrob]
    rw [integral_tangentNoise_norm_sq]
    unfold mrCodim
    rw [hE]
    congr 1
    ring
  have hrem := mrx_removed_finrank X
  have hremR : (Module.finrank ℝ (removedTangentSpace X) : ℝ) = mrCodim X := by
    unfold mrCodim
    have : (Module.finrank ℝ (globalTangentSpace X) : ℝ) +
        (Module.finrank ℝ (removedTangentSpace X) : ℝ) =
        (Module.finrank ℝ (rowTangentSpace X) : ℝ) := by exact_mod_cast hrem
    linarith
  refine ⟨hint1, ?_, ?_, ?_⟩
  · rw [div_le_iff₀ hnR]; nlinarith
  · have hsq : ∀ g, sqDistance (conditionedNoise X g) (rowNoise X g) =
        ‖Matrix.toEuclideanLin (rowTangentNoiseFactor X) g -
          Matrix.toEuclideanLin (tangentNoiseFactor X) g‖ ^ 2 := by
      intro g
      unfold conditionedNoise rowNoise
      rw [sqDistance_frameOfVector, norm_sub_rev]
    simp_rw [hsq]
    rw [integral_tangentNoise_coupling_sq, hremR]
  · have : mrCodim X ≤ (d : ℝ) ^ 2 := hm1.trans hm2
    exact div_le_div_of_nonneg_right this hnR.le

/-- `r_i = ‖z_i‖²/a` for the constrained noise `Z`. -/
def mrRatio {n d : ℕ} (X : Frame n d) (g : FrameVector n d) (i : Fin n) : ℝ :=
  rowNormSq (conditionedNoise X g) i / ((d : ℝ) / n)

/-- `μ_i = E r_i`. -/
def mrRatioMean {n d : ℕ} (X : Frame n d) (i : Fin n) : ℝ :=
  ∫ g, mrRatio X g i ∂gaussFrame n d

/-- `δ_i = 1 - μ_i`. -/
def mrDeficit {n d : ℕ} (X : Frame n d) (i : Fin n) : ℝ := 1 - mrRatioMean X i

/-- `𝓜 = a ∑_i E[(r_i-1)²(1+r_i)²]`. -/
def mrMoment {n d : ℕ} (X : Frame n d) : ℝ :=
  ((d : ℝ) / n) * ∑ i, ∫ g, (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 ∂gaussFrame n d

/-- `Σ̃_i = Σ_i / a`, the normalised covariance of the row `z_i`. -/
def mrRowCovariance {n d : ℕ} (X : Frame n d) (i : Fin n) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k =>
    (∫ g, conditionedNoise X g i j * conditionedNoise X g i k ∂gaussFrame n d) / ((d : ℝ) / n)

/-! ### Row covariance structure (helpers, not paper items) -/

/-- The rows `(i,·)` of the noise factor: `z_i = K_i g`. -/
def mrRowFactor {n d : ℕ} (X : Frame n d) (i : Fin n) : Matrix (Fin d) (Fin n × Fin d) ℝ :=
  fun j s => tangentNoiseFactor X (i, j) s

theorem mr_aux_row_entry {n d : ℕ} (X : Frame n d) (g : FrameVector n d) (i : Fin n)
    (j : Fin d) : conditionedNoise X g i j = (Matrix.toEuclideanLin (mrRowFactor X i) g) j := by
  simp [conditionedNoise, frameOfVector, mrRowFactor, Matrix.toLpLin_apply, Matrix.mulVec,
    dotProduct]

theorem mr_aux_rowCov_eq {n d : ℕ} (X : Frame n d) (i : Fin n) :
    mrRowCovariance X i =
      (1 / ((d : ℝ) / n)) • (mrRowFactor X i * (mrRowFactor X i).transpose) := by
  ext j k
  simp only [mrRowCovariance, Matrix.of_apply, Matrix.smul_apply, smul_eq_mul, mr_aux_row_entry]
  rw [(gauss_aux_coord_mul (mrRowFactor X i) j k).2]
  ring

theorem mr_aux_euclideanQuadratic_smul {κ : Type*} [Fintype κ] [DecidableEq κ] (c : ℝ)
    (A : Matrix κ κ ℝ) (g : EuclideanSpace ℝ κ) :
    euclideanQuadratic (c • A) g = c * euclideanQuadratic A g := by
  unfold euclideanQuadratic
  rw [map_smul, LinearMap.smul_apply, inner_smul_right]

theorem mr_aux_ratio_eq {n d : ℕ} (X : Frame n d) (g : FrameVector n d) (i : Fin n) :
    mrRatio X g i = euclideanQuadratic ((1 / ((d : ℝ) / n)) •
      ((mrRowFactor X i).transpose * mrRowFactor X i)) g := by
  rw [mr_aux_euclideanQuadratic_smul, ← norm_sq_gaussianImage_eq_quadratic,
    EuclideanSpace.real_norm_sq_eq]
  unfold mrRatio rowNormSq
  simp_rw [mr_aux_row_entry]
  ring

theorem mr_aux_trace_pow {d : ℕ} {κ : Type*} [Fintype κ] [DecidableEq κ]
    (K : Matrix (Fin d) κ ℝ) (m : ℕ) :
    ((K.transpose * K) ^ (m + 1)).trace = ((K * K.transpose) ^ (m + 1)).trace := by
  have hpow : ∀ m : ℕ, K.transpose * (K * K.transpose) ^ m * K = (K.transpose * K) ^ (m + 1) := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [pow_succ (K * K.transpose), pow_succ (K.transpose * K), ← ih]
      simp only [Matrix.mul_assoc]
  rw [← hpow m, Matrix.trace_mul_comm, ← Matrix.mul_assoc, ← pow_succ']

theorem mr_aux_A_herm {n d : ℕ} (X : Frame n d) (i : Fin n) :
    ((1 / ((d : ℝ) / n)) • ((mrRowFactor X i).transpose * mrRowFactor X i)).IsHermitian := by
  ext p q
  simp [Matrix.mul_apply, mul_comm]

theorem mr_aux_mean_eq {n d : ℕ} (X : Frame n d) (i : Fin n) :
    mrRatioMean X i =
      ((1 / ((d : ℝ) / n)) • ((mrRowFactor X i).transpose * mrRowFactor X i)).trace := by
  unfold mrRatioMean
  simp_rw [mr_aux_ratio_eq]
  exact integral_euclideanQuadratic_stdGaussian _ (mr_aux_A_herm X i)

/-- Integrability of `ξ_i²` and `ξ_i⁴`, `ξ_i = r_i - μ_i` (not a paper item). -/
theorem mr_aux_xi_integrable {n d : ℕ} (X : Frame n d) (i : Fin n) :
    Integrable (fun g => (mrRatio X g i - mrRatioMean X i) ^ 2) (gaussFrame n d) ∧
    Integrable (fun g => (mrRatio X g i - mrRatioMean X i) ^ 4) (gaussFrame n d) := by
  simp_rw [mr_aux_ratio_eq, mr_aux_mean_eq]
  exact ⟨(memLp_centered_euclideanQuadratic_stdGaussian _ (mr_aux_A_herm X i)).integrable_sq,
    (mrx_fourth_moment_quadratic _ (mr_aux_A_herm X i)).1⟩

/-- Integrability of the row moment `(r_i-1)²(1+r_i)² = (r_i²-1)²` (not in the paper). -/
theorem mr_aux_moment_integrable {n d : ℕ} (hn : 0 < n) (hd : 0 < d) (X : Frame n d)
    (hX : IsEqualNorm X) (i : Fin n) :
    Integrable (fun g => (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2) (gaussFrame n d) := by
  have ha : 0 < (d : ℝ) / n := by positivity
  have hR := (Linear.integral_rowFourthDeviation_conditioned X hn hd hX).1
  refine (hR.div_const ((d : ℝ) / n)).mono' ?_ (Filter.Eventually.of_forall fun g => ?_)
  · apply Continuous.aestronglyMeasurable
    have hc : Continuous (fun g : FrameVector n d => rowNormSq (conditionedNoise X g) i) := by
      have heq : (fun g : FrameVector n d => rowNormSq (conditionedNoise X g) i) =
          fun g => euclideanQuadratic ((tangentNoiseFactor X).transpose *
            Linear.rowSelector i * tangentNoiseFactor X) g := by
        funext g
        exact Linear.rowNormSq_gaussianImage_eq _ g i
      rw [heq]
      unfold euclideanQuadratic
      fun_prop
    unfold mrRatio
    fun_prop
  · have hr0 : 0 ≤ mrRatio X g i := div_nonneg (rowNormSq_nonneg _ i) ha.le
    rw [Real.norm_eq_abs, abs_of_nonneg (by positivity)]
    unfold Linear.rowFourthDeviation
    rw [mul_div_cancel_left₀ _ ha.ne']
    have e : (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 =
        ((tangentRatio ((d : ℝ) / n) (conditionedNoise X g) i) ^ 2 - 1) ^ 2 := by
      simp only [mrRatio, tangentRatio]; ring
    rw [e]
    exact Finset.single_le_sum (f := fun j => ((tangentRatio ((d : ℝ) / n)
      (conditionedNoise X g) j) ^ 2 - 1) ^ 2) (fun j _ => sq_nonneg _) (Finset.mem_univ i)

/-- Proof of `lem:rowmoments`: Gaussian moment formulas, with explicit constants.

TeX: "$\tilde\Sigma_i=\Sigma_i/a\preceq d^{-1}I$ has trace $\mu_i\le(d-1)/d$, so
$\tr\tilde\Sigma_i^2\le1/d$ and $\tr\tilde\Sigma_i^4\le d^{-3}$. For
$\xi_i=r_i-\mu_i$ the Gaussian moment formulas give $\E\xi_i^2=2\tr\tilde\Sigma_i^2\le
2/d$ and $\E\xi_i^4=12(\tr\tilde\Sigma_i^2)^2+48\tr\tilde\Sigma_i^4\le60/d^2$." -/
theorem lem_rowmoments_gaussian {n d : ℕ} (hd : 2 ≤ d) (hdn : (d : ℝ) ^ 2 ≤ n)
    (X : Frame n d) (hX : IsEqualNorm X) (i : Fin n) :
    (∀ v : Fin d → ℝ, matrixQuadratic (mrRowCovariance X i) v ≤ (1 / (d : ℝ)) * vectorNormSq v) ∧
    (mrRowCovariance X i).trace = mrRatioMean X i ∧
    mrRatioMean X i ≤ ((d : ℝ) - 1) / d ∧
    (mrRowCovariance X i ^ 2).trace ≤ 1 / (d : ℝ) ∧
    (mrRowCovariance X i ^ 4).trace ≤ ((d : ℝ) ^ 3)⁻¹ ∧
    ∫ g, (mrRatio X g i - mrRatioMean X i) ^ 2 ∂gaussFrame n d =
      2 * (mrRowCovariance X i ^ 2).trace ∧
    2 * (mrRowCovariance X i ^ 2).trace ≤ 2 / (d : ℝ) ∧
    ∫ g, (mrRatio X g i - mrRatioMean X i) ^ 4 ∂gaussFrame n d =
      12 * ((mrRowCovariance X i ^ 2).trace) ^ 2 + 48 * (mrRowCovariance X i ^ 4).trace ∧
    12 * ((mrRowCovariance X i ^ 2).trace) ^ 2 + 48 * (mrRowCovariance X i ^ 4).trace ≤
      60 / (d : ℝ) ^ 2 := by
  have hd0 : 0 < d := by omega
  have hdR : (2 : ℝ) ≤ d := by exact_mod_cast hd
  have hnR : (0 : ℝ) < n := by nlinarith
  have hn : 0 < n := by exact_mod_cast hnR
  set a : ℝ := (d : ℝ) / n with ha_def
  have ha : 0 < a := by positivity
  have han : 1 / a * (1 / (n : ℝ)) = 1 / (d : ℝ) := by rw [ha_def]; field_simp
  set K := mrRowFactor X i with hK
  set S := mrRowCovariance X i with hSdef
  have hS : S = (1 / a) • (K * K.transpose) := mr_aux_rowCov_eq X i
  set A : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ := (1 / a) • (K.transpose * K) with hAdef
  have hA : A.IsHermitian := by
    ext p q
    simp [hAdef, Matrix.mul_apply, mul_comm]
  have hSH : S.IsHermitian := by
    rw [hS]; ext p q
    simp [Matrix.mul_apply, mul_comm]
  have hr (g : FrameVector n d) : mrRatio X g i = euclideanQuadratic A g := mr_aux_ratio_eq X g i
  have hμ : mrRatioMean X i = A.trace := by
    unfold mrRatioMean
    simp_rw [hr]
    exact integral_euclideanQuadratic_stdGaussian A hA
  have htr (m : ℕ) : (A ^ (m + 1)).trace = (S ^ (m + 1)).trace := by
    rw [hAdef, hS, smul_pow, smul_pow, Matrix.trace_smul, Matrix.trace_smul, mr_aux_trace_pow]
  -- the quadratic form of `Σ̃`
  have hcov (v : Fin d → ℝ) : ∫ g, (∑ j, conditionedNoise X g i j * v j) ^ 2 ∂gaussFrame n d =
      matrixQuadratic (K * K.transpose) v := by
    have hexp (g : FrameVector n d) : (∑ j, conditionedNoise X g i j * v j) ^ 2 =
        ∑ j, ∑ k, v j * ((Matrix.toEuclideanLin K g) j * (Matrix.toEuclideanLin K g) k) * v k := by
      simp_rw [mr_aux_row_entry, pow_two, Finset.sum_mul_sum]
      apply Finset.sum_congr rfl; intro j _
      apply Finset.sum_congr rfl; intro k _
      ring
    simp_rw [hexp]
    have hi (j k : Fin d) := (gauss_aux_coord_mul K j k).1
    rw [integral_finsetSum _ fun j _ => integrable_finsetSum _ fun k _ =>
      ((hi j k).const_mul (v j)).mul_const (v k)]
    unfold matrixQuadratic
    apply Finset.sum_congr rfl; intro j _
    rw [integral_finsetSum _ fun k _ => ((hi j k).const_mul (v j)).mul_const (v k)]
    apply Finset.sum_congr rfl; intro k _
    rw [integral_mul_const, integral_const_mul, (gauss_aux_coord_mul K j k).2]
  have hquadS (v : Fin d → ℝ) : matrixQuadratic S v =
      1 / a * ∫ g, (∑ j, conditionedNoise X g i j * v j) ^ 2 ∂gaussFrame n d := by
    rw [hcov, hS, matrixQuadratic_smul]
  have hS0 (v : Fin d → ℝ) : 0 ≤ matrixQuadratic S v := by
    rw [hquadS]
    exact mul_nonneg (by positivity) (integral_nonneg fun g => sq_nonneg _)
  have h1 (v : Fin d → ℝ) : matrixQuadratic S v ≤ (1 / (d : ℝ)) * vectorNormSq v := by
    rw [hquadS]
    have hb := (mr_noise_covariance hn X hX).2.2 i v
    have hsq := sq_nonneg (∑ j, X i j / Real.sqrt ((d : ℝ) / n) * v j)
    calc 1 / a * ∫ g, (∑ j, conditionedNoise X g i j * v j) ^ 2 ∂gaussFrame n d
        ≤ 1 / a * ((1 / (n : ℝ)) * vectorNormSq v) := by
          apply mul_le_mul_of_nonneg_left _ (by positivity)
          refine hb.trans ?_
          apply mul_le_mul_of_nonneg_left _ (by positivity)
          linarith
      _ = _ := by rw [← mul_assoc, han]
  have htrS : S.trace = mrRatioMean X i := by
    rw [hμ, ← pow_one A, htr 0, pow_one]
  -- `μ_i ≤ (d-1)/d`
  have hμle : mrRatioMean X i ≤ ((d : ℝ) - 1) / d := by
    rw [← htrS]
    have hdiag (j : Fin d) : S j j ≤ 1 / a * ((1 / (n : ℝ)) * (1 - X i j ^ 2 / a)) := by
      have hb := (mr_noise_covariance hn X hX).2.2 i (Pi.single j 1)
      have hl : ∀ g, ∑ k, conditionedNoise X g i k * (Pi.single j (1 : ℝ) : Fin d → ℝ) k =
          conditionedNoise X g i j := fun g => by simp [Pi.single_apply]
      have hr' : ∑ k, X i k / Real.sqrt ((d : ℝ) / n) * (Pi.single j (1 : ℝ) : Fin d → ℝ) k =
          X i j / Real.sqrt a := by simp [Pi.single_apply, ha_def]
      have hv : vectorNormSq (Pi.single j (1 : ℝ) : Fin d → ℝ) = 1 := by
        simp [vectorNormSq, Pi.single_apply]
      simp_rw [hl] at hb
      rw [hr', hv, div_pow, Real.sq_sqrt ha.le] at hb
      have : S j j = 1 / a * ∫ g, (conditionedNoise X g i j) ^ 2 ∂gaussFrame n d := by
        rw [hSdef]; simp only [mrRowCovariance, Matrix.of_apply, pow_two]; ring
      rw [this]
      exact mul_le_mul_of_nonneg_left hb (by positivity)
    have hsum := Finset.sum_le_sum (fun j (_ : j ∈ Finset.univ) => hdiag j)
    have hrow : ∑ j, X i j ^ 2 = a := hX i
    calc S.trace = ∑ j, S j j := rfl
      _ ≤ ∑ j, 1 / a * ((1 / (n : ℝ)) * (1 - X i j ^ 2 / a)) := hsum
      _ = 1 / a * (1 / (n : ℝ)) * ((d : ℝ) - (∑ j, X i j ^ 2) / a) := by
          rw [← Finset.mul_sum, ← Finset.mul_sum, Finset.sum_sub_distrib, ← Finset.sum_div]
          simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_one]
          ring
      _ = _ := by rw [han, hrow, div_self ha.ne']; ring
  -- eigenvalues of `Σ̃` lie in `[0, 1/d]`
  set lam := hSH.eigenvalues
  have hlam (k : Fin d) : 0 ≤ lam k ∧ lam k ≤ 1 / (d : ℝ) := by
    obtain ⟨he, hu⟩ := mrx_eigenvalue_eq_quadratic S hSH k
    have he' : lam k = matrixQuadratic S (fun j => (hSH.eigenvectorBasis k) j) := he
    refine ⟨he' ▸ hS0 _, ?_⟩
    rw [he']
    have := h1 (fun j => (hSH.eigenvectorBasis k) j)
    rwa [show vectorNormSq (fun j => (hSH.eigenvectorBasis k) j) = 1 from hu, mul_one] at this
  have hsum1 : ∑ k, lam k = mrRatioMean X i := by
    rw [← htrS, ← pow_one S, trace_pow_eq_sum_eigenvalues S hSH 1]
    simp [lam]
  have hμ0 : 0 ≤ mrRatioMean X i := by
    rw [← hsum1]; exact Finset.sum_nonneg fun k _ => (hlam k).1
  have hμ1 : mrRatioMean X i ≤ 1 := hμle.trans (by rw [div_le_one (by positivity)]; linarith)
  have htr2 : (S ^ 2).trace = ∑ k, lam k ^ 2 := trace_pow_eq_sum_eigenvalues S hSH 2
  have htr4 : (S ^ 4).trace = ∑ k, lam k ^ 4 := trace_pow_eq_sum_eigenvalues S hSH 4
  have hd1 : 0 < 1 / (d : ℝ) := by positivity
  have hb2 : (S ^ 2).trace ≤ 1 / (d : ℝ) := by
    rw [htr2]
    calc ∑ k, lam k ^ 2 ≤ ∑ k, (1 / (d : ℝ)) * lam k := Finset.sum_le_sum fun k _ => by
          have := hlam k; nlinarith
      _ = (1 / (d : ℝ)) * mrRatioMean X i := by rw [← Finset.mul_sum, hsum1]
      _ ≤ 1 / (d : ℝ) := by nlinarith
  have hb4 : (S ^ 4).trace ≤ ((d : ℝ) ^ 3)⁻¹ := by
    rw [htr4]
    calc ∑ k, lam k ^ 4 ≤ ∑ k, (1 / (d : ℝ)) ^ 3 * lam k := Finset.sum_le_sum fun k _ => by
          obtain ⟨h0, h1'⟩ := hlam k
          have : lam k ^ 3 ≤ (1 / (d : ℝ)) ^ 3 := pow_le_pow_left₀ h0 h1' 3
          nlinarith
      _ = (1 / (d : ℝ)) ^ 3 * mrRatioMean X i := by rw [← Finset.mul_sum, hsum1]
      _ ≤ (1 / (d : ℝ)) ^ 3 := by nlinarith [pow_pos hd1 3]
      _ = _ := by rw [one_div, inv_pow]
  have hb2' : 0 ≤ (S ^ 2).trace := by
    rw [htr2]; exact Finset.sum_nonneg fun k _ => sq_nonneg _
  -- the Gaussian moment formulas
  have hsymA : ∑ p, ∑ q, A p q ^ 2 = (A ^ 2).trace := by
    rw [pow_two]
    simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply]
    apply Finset.sum_congr rfl; intro p _
    apply Finset.sum_congr rfl; intro q _
    rw [pow_two, (Matrix.isHermitian_iff_isSymm.mp hA).apply p q]
  have hm2 : ∫ g, (mrRatio X g i - mrRatioMean X i) ^ 2 ∂gaussFrame n d =
      2 * (S ^ 2).trace := by
    simp_rw [hr, hμ]
    rw [integral_sq_centered_euclideanQuadratic_stdGaussian A hA, hsymA, htr 1]
  have hm4 : ∫ g, (mrRatio X g i - mrRatioMean X i) ^ 4 ∂gaussFrame n d =
      12 * ((S ^ 2).trace) ^ 2 + 48 * (S ^ 4).trace := by
    simp_rw [hr, hμ]
    rw [(mrx_fourth_moment_quadratic A hA).2, htr 1, htr 3]
  refine ⟨h1, htrS, hμle, hb2, hb4, hm2, by rw [show (2 : ℝ) / d = 2 * (1 / d) by ring]; linarith,
    hm4, ?_⟩
  have hd2 : ((d : ℝ) ^ 3)⁻¹ ≤ 1 / (d : ℝ) ^ 2 := by
    rw [one_div]
    apply inv_anti₀ (by positivity)
    nlinarith
  have hsq : ((S ^ 2).trace) ^ 2 ≤ (1 / (d : ℝ)) ^ 2 := pow_le_pow_left₀ hb2' hb2 2
  calc 12 * ((S ^ 2).trace) ^ 2 + 48 * (S ^ 4).trace ≤
      12 * (1 / (d : ℝ)) ^ 2 + 48 * (1 / (d : ℝ) ^ 2) := by nlinarith
    _ = 60 / (d : ℝ) ^ 2 := by field_simp; ring

/-- Proof of `lem:rowmoments`: the pointwise inequality.

TeX: "Finally $(r_i-1)^2\le2\xi_i^2+2\delta_i^2$ and $(1+r_i)^2\le8+2\xi_i^2$, so
\[ \E(r_i-1)^2(1+r_i)^2\le16\E\xi_i^2+4\E\xi_i^4+16\delta_i^2+4\delta_i^2\E\xi_i^2 \]"
(scalar form, with `r = 1 - δ + ξ`, `0 ≤ δ ≤ 1`). -/
theorem lem_rowmoments_scalar (δ ξ : ℝ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) :
    ((1 - δ + ξ) - 1) ^ 2 ≤ 2 * ξ ^ 2 + 2 * δ ^ 2 ∧
    (1 + (1 - δ + ξ)) ^ 2 ≤ 8 + 2 * ξ ^ 2 ∧
    ((1 - δ + ξ) - 1) ^ 2 * (1 + (1 - δ + ξ)) ^ 2 ≤
      16 * ξ ^ 2 + 4 * ξ ^ 4 + 16 * δ ^ 2 + 4 * δ ^ 2 * ξ ^ 2 := by
  have h1 : ((1 - δ + ξ) - 1) ^ 2 ≤ 2 * ξ ^ 2 + 2 * δ ^ 2 := by
    nlinarith [sq_nonneg (ξ + δ)]
  have h2 : (1 + (1 - δ + ξ)) ^ 2 ≤ 8 + 2 * ξ ^ 2 := by
    nlinarith [sq_nonneg (2 - δ - ξ)]
  refine ⟨h1, h2, ?_⟩
  calc _ ≤ (2 * ξ ^ 2 + 2 * δ ^ 2) * (8 + 2 * ξ ^ 2) :=
        mul_le_mul h1 h2 (sq_nonneg _) (by positivity)
    _ = _ := by ring

/-- `lem:rowmoments`, first claims.

TeX: "Let $r_i=\norm{z_i}^2/a$, $\mu_i=\E r_i$ and $\delta_i=1-\mu_i$. Then
$1/d\le\delta_i\le1$, $\sum_ia\delta_i=1+m/n\le2$"

(The bound `≤ 2` uses the standing assumption `m ≤ d² ≤ n`.) -/
theorem lem_rowmoments_deficit {n d : ℕ} (hd : 2 ≤ d) (hdn : (d : ℝ) ^ 2 ≤ n)
    (X : Frame n d) (hX : IsEqualNorm X) :
    (∀ i, 1 / (d : ℝ) ≤ mrDeficit X i ∧ mrDeficit X i ≤ 1) ∧
    ∑ i, ((d : ℝ) / n) * mrDeficit X i = 1 + mrCodim X / n ∧
    1 + mrCodim X / n ≤ 2 := by
  have hd1 : 1 ≤ d := by omega
  have hdR : (2 : ℝ) ≤ d := by exact_mod_cast hd
  have hnR : (0 : ℝ) < n := by nlinarith
  have hn : 0 < n := by exact_mod_cast hnR
  set a : ℝ := (d : ℝ) / n with ha_def
  have ha : 0 < a := by positivity
  have hg (i : Fin n) := lem_rowmoments_gaussian hd hdn X hX i
  obtain ⟨hZ, -, -, -⟩ := eq_mr_noise hn hd1 X hX
  obtain ⟨-, hm1, hm2⟩ := mr_codim_le X hX hd1
  have hμ0 (i : Fin n) : 0 ≤ mrRatioMean X i :=
    integral_nonneg fun g => div_nonneg (rowNormSq_nonneg _ i) ha.le
  refine ⟨fun i => ⟨?_, ?_⟩, ?_, ?_⟩
  · have := (hg i).2.2.1
    unfold mrDeficit
    have e : 1 - ((d : ℝ) - 1) / d = 1 / d := by field_simp; ring
    linarith
  · unfold mrDeficit; linarith [hμ0 i]
  · have hint (i : Fin n) : Integrable (fun g => rowNormSq (conditionedNoise X g) i)
        (gaussFrame n d) :=
      (memLp_rowNormSq_gaussianImage (tangentNoiseFactor X) i).integrable (by norm_num)
    have haμ (i : Fin n) : a * mrRatioMean X i =
        ∫ g, rowNormSq (conditionedNoise X g) i ∂gaussFrame n d := by
      unfold mrRatioMean mrRatio
      rw [integral_div, ← ha_def]
      field_simp
    have hsum : ∑ i, a * mrRatioMean X i = ((n : ℝ) * ((d : ℝ) - 1) - mrCodim X) / n := by
      simp_rw [haμ]
      rw [← integral_finsetSum _ fun i _ => hint i, ← hZ]
      rfl
    unfold mrDeficit
    simp_rw [mul_sub, mul_one]
    rw [Finset.sum_sub_distrib, hsum]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    rw [ha_def]
    field_simp
    ring
  · have : mrCodim X / n ≤ 1 := by
      rw [div_le_one hnR]; linarith
    linarith

/-- `lem:rowmoments`, main claim.

TeX: "\[ \mathcal M:=a\sum_i\E\bigl[(r_i-1)^2(1+r_i)^2\bigr]\le C_{\mathcal M}, \]
with $C_{\mathcal M}$ absolute." -/
theorem lem_rowmoments :
    ∃ CM : ℝ, 0 ≤ CM ∧ ∀ (n d : ℕ) (X : Frame n d), 2 ≤ d → (d : ℝ) ^ 2 ≤ n →
      IsEqualNorm X → mrMoment X ≤ CM := by
  refine ⟨192, by norm_num, fun n d X hd hdn hX => ?_⟩
  have hd0 : 0 < d := by omega
  have hd1 : 1 ≤ d := by omega
  have hdR : (2 : ℝ) ≤ d := by exact_mod_cast hd
  have hnR : (0 : ℝ) < n := by nlinarith
  have hn : 0 < n := by exact_mod_cast hnR
  set a : ℝ := (d : ℝ) / n with ha_def
  have ha : 0 < a := by positivity
  obtain ⟨hδ, hsumδ, hsum2⟩ := lem_rowmoments_deficit hd hdn X hX
  -- the per-row bound
  have hrow (i : Fin n) : ∫ g, (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 ∂gaussFrame n d ≤
      32 / d + 240 / (d : ℝ) ^ 2 + 20 * mrDeficit X i := by
    obtain ⟨-, -, -, -, -, hm2, hb2, hm4, hb4⟩ := lem_rowmoments_gaussian hd hdn X hX i
    obtain ⟨hδ1, hδ2⟩ := hδ i
    have hδ0 : 0 ≤ mrDeficit X i := le_trans (by positivity) hδ1
    set δ := mrDeficit X i with hδdef
    obtain ⟨hi2, hi4⟩ := mr_aux_xi_integrable X i
    have hpt (g : FrameVector n d) : (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 ≤
        16 * (mrRatio X g i - mrRatioMean X i) ^ 2 + 4 * (mrRatio X g i - mrRatioMean X i) ^ 4 +
          16 * δ ^ 2 + 4 * δ ^ 2 * (mrRatio X g i - mrRatioMean X i) ^ 2 := by
      have h := (lem_rowmoments_scalar δ (mrRatio X g i - mrRatioMean X i) hδ0 hδ2).2.2
      have e : 1 - δ + (mrRatio X g i - mrRatioMean X i) = mrRatio X g i := by
        rw [hδdef]; unfold mrDeficit; ring
      rwa [e] at h
    have hRint : Integrable (fun g => 16 * (mrRatio X g i - mrRatioMean X i) ^ 2 +
        4 * (mrRatio X g i - mrRatioMean X i) ^ 4 + 16 * δ ^ 2 +
        4 * δ ^ 2 * (mrRatio X g i - mrRatioMean X i) ^ 2) (gaussFrame n d) :=
      (((hi2.const_mul 16).add (hi4.const_mul 4)).add (integrable_const _)).add
        (hi2.const_mul _)
    have hmono := integral_mono (mr_aux_moment_integrable hn hd0 X hX i) hRint hpt
    have hcalc : ∫ g, (16 * (mrRatio X g i - mrRatioMean X i) ^ 2 +
        4 * (mrRatio X g i - mrRatioMean X i) ^ 4 + 16 * δ ^ 2 +
        4 * δ ^ 2 * (mrRatio X g i - mrRatioMean X i) ^ 2) ∂gaussFrame n d =
        16 * (2 * (mrRowCovariance X i ^ 2).trace) +
          4 * (12 * ((mrRowCovariance X i ^ 2).trace) ^ 2 + 48 * (mrRowCovariance X i ^ 4).trace) +
          16 * δ ^ 2 + 4 * δ ^ 2 * (2 * (mrRowCovariance X i ^ 2).trace) := by
      have j1 : Integrable (fun g => 16 * (mrRatio X g i - mrRatioMean X i) ^ 2 +
          4 * (mrRatio X g i - mrRatioMean X i) ^ 4) (gaussFrame n d) :=
        (hi2.const_mul 16).add (hi4.const_mul 4)
      have j2 : Integrable (fun g => 16 * (mrRatio X g i - mrRatioMean X i) ^ 2 +
          4 * (mrRatio X g i - mrRatioMean X i) ^ 4 + 16 * δ ^ 2) (gaussFrame n d) :=
        j1.add (integrable_const _)
      rw [integral_add j2 (hi2.const_mul _), integral_add j1 (integrable_const _),
        integral_add (hi2.const_mul 16) (hi4.const_mul 4)]
      simp only [integral_const_mul, integral_const, hm2, hm4, probReal_univ, one_smul]
    rw [hcalc] at hmono
    have hδsq : δ ^ 2 ≤ δ := by nlinarith
    have hdinv : 8 / (d : ℝ) ≤ 4 := by rw [div_le_iff₀ (by positivity)]; linarith
    have hS2 : 0 ≤ 2 * (mrRowCovariance X i ^ 2).trace := by
      have := lem_rowmoments_gaussian hd hdn X hX i
      rw [← this.2.2.2.2.2.1]; exact integral_nonneg fun g => sq_nonneg _
    have e1 : 4 * δ ^ 2 * (2 * (mrRowCovariance X i ^ 2).trace) ≤ 4 * δ * (2 / d) := by
      have := mul_le_mul hδsq hb2 hS2 hδ0
      nlinarith
    have e2 : 4 * δ * (2 / d) ≤ 4 * δ := by
      have : 4 * δ * (2 / (d : ℝ)) = δ * (8 / d) := by ring
      rw [this]; nlinarith
    have e3 : (32 : ℝ) / d = 16 * (2 / d) := by ring
    have e4 : (240 : ℝ) / d ^ 2 = 4 * (60 / d ^ 2) := by ring
    rw [e3, e4]
    linarith
  -- sum over the rows
  unfold mrMoment
  rw [← ha_def]
  calc a * ∑ i, ∫ g, (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 ∂gaussFrame n d
      ≤ a * ∑ i : Fin n, (32 / d + 240 / (d : ℝ) ^ 2 + 20 * mrDeficit X i) :=
        mul_le_mul_of_nonneg_left (Finset.sum_le_sum fun i _ => hrow i) ha.le
    _ = 32 + 240 / d + 20 * ∑ i, a * mrDeficit X i := by
        have e : ∀ i : Fin n, a * (32 / d + 240 / (d : ℝ) ^ 2 + 20 * mrDeficit X i) =
            a * (32 / d + 240 / (d : ℝ) ^ 2) + 20 * (a * mrDeficit X i) := fun i => by ring
        rw [Finset.mul_sum]
        simp_rw [e]
        rw [Finset.sum_add_distrib]
        simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
        congr 1
        · rw [ha_def]
          field_simp
        · rw [Finset.mul_sum]
    _ ≤ 192 := by
        rw [hsumδ]
        have : 240 / (d : ℝ) ≤ 120 := by rw [div_le_iff₀ (by positivity)]; linarith
        linarith

/-! ## 4.2 Row normalisation and the exact second-order identity -/

/-- The metric-projection fact used for `eq:mr-contract` (unnumbered).

TeX: "The map $y\mapsto\sqrt a\,y/\norm y$ is the metric projection onto the closed ball of
radius $\sqrt a$ on $\{\norm y\ge\sqrt a\}$, hence $1$-Lipschitz there." -/
theorem mr_normalisation_lipschitz {d : ℕ} {a : ℝ} (ha : 0 < a)
    (y y' : EuclideanSpace ℝ (Fin d)) (hy : Real.sqrt a ≤ ‖y‖) (hy' : Real.sqrt a ≤ ‖y'‖) :
    ‖(Real.sqrt a / ‖y‖) • y - (Real.sqrt a / ‖y'‖) • y'‖ ≤ ‖y - y'‖ := by
  set c := Real.sqrt a with hc
  have hc0 : 0 < c := Real.sqrt_pos.mpr ha
  set r := ‖y‖ with hr
  set r' := ‖y'‖ with hr'
  have hr0 : 0 < r := lt_of_lt_of_le hc0 hy
  have hr0' : 0 < r' := lt_of_lt_of_le hc0 hy'
  set p := inner ℝ y y' with hp
  have hpr : p ≤ r * r' := (real_inner_le_norm y y')
  have hcc : c * c ≤ r * r' := mul_le_mul hy hy' hc0.le hr0.le
  have hL : ‖(c / r) • y - (c / r') • y'‖ ^ 2 = 2 * c ^ 2 - 2 * (c ^ 2 / (r * r')) * p := by
    rw [norm_sub_sq_real, norm_smul, norm_smul, real_inner_smul_left, real_inner_smul_right,
      Real.norm_eq_abs, Real.norm_eq_abs, abs_of_pos (div_pos hc0 hr0),
      abs_of_pos (div_pos hc0 hr0'), ← hr, ← hr', ← hp]
    field_simp
    ring
  have hR : ‖y - y'‖ ^ 2 = r ^ 2 - 2 * p + r' ^ 2 := by
    rw [norm_sub_sq_real]
  have hkey : ‖(c / r) • y - (c / r') • y'‖ ^ 2 ≤ ‖y - y'‖ ^ 2 := by
    rw [hL, hR]
    have hrr : 0 < r * r' := mul_pos hr0 hr0'
    have hdiv : c ^ 2 / (r * r') * p * (r * r') = c ^ 2 * p := by field_simp
    have h1 : (2 * c ^ 2 - 2 * (c ^ 2 / (r * r')) * p) * (r * r') ≤
        (r ^ 2 - 2 * p + r' ^ 2) * (r * r') := by
      have e : (2 * c ^ 2 - 2 * (c ^ 2 / (r * r')) * p) * (r * r') =
          2 * c ^ 2 * (r * r') - 2 * (c ^ 2 * p) := by rw [← hdiv]; ring
      rw [e]
      nlinarith [mul_nonneg (sub_nonneg.mpr hpr) (sub_nonneg.mpr hcc),
        mul_nonneg hrr.le (sq_nonneg (r - r'))]
    exact le_of_mul_le_mul_right h1 hrr
  exact (pow_le_pow_iff_left₀ (norm_nonneg _) (norm_nonneg _) (by norm_num)).mp hkey

/-- Proof step of `eq:mr-contract` (via `mr_normalisation_lipschitz`): rowwise,
`‖v_i - v'_i‖ ≤ ‖y_i - y'_i‖ = t ‖z_i - z'_i‖` for `y_i = x_i + t z_i`. -/
theorem mr_aux_row_contract {n d : ℕ} (X Z Z' : Frame n d) {a : ℝ} (ha : 0 < a) (t : ℝ)
    (hX : ∀ i, rowNormSq X i = a) (hZ : ∀ i, rowDot X Z i = 0) (hZ' : ∀ i, rowDot X Z' i = 0)
    (i : Fin n) :
    ∑ j, (tangentSeed X Z a t i j - tangentSeed X Z' a t i j) ^ 2 ≤
      t ^ 2 * ∑ j, (Z i j - Z' i j) ^ 2 := by
  have hrow (W : Frame n d) (hW : ∀ i, rowDot X W i = 0) :
      ∃ y : EuclideanSpace ℝ (Fin d), Real.sqrt a ≤ ‖y‖ ∧
        (∀ j, y j = X i j + t * W i j) ∧
        ∀ j, tangentSeed X W a t i j = ((Real.sqrt a / ‖y‖) • y) j := by
    refine ⟨WithLp.toLp 2 (fun j => X i j + t * W i j), ?_, fun j => rfl, fun j => ?_⟩
    all_goals
      have hden := tangent_denominator_pos a t ha W i
      have hn2 : ‖(WithLp.toLp 2 (fun j => X i j + t * W i j) : EuclideanSpace ℝ (Fin d))‖ ^ 2 =
          a * (1 + t ^ 2 * tangentRatio a W i) := by
        rw [EuclideanSpace.real_norm_sq_eq]
        change ∑ j, (X i j + t * W i j) ^ 2 = _
        rw [tangent_row_norm_expansion, hX i, hW i, tangentRatio]
        field_simp
        ring
      have hnorm : ‖(WithLp.toLp 2 (fun j => X i j + t * W i j) : EuclideanSpace ℝ (Fin d))‖ =
          Real.sqrt a * Real.sqrt (1 + t ^ 2 * tangentRatio a W i) := by
        rw [← Real.sqrt_mul ha.le, ← hn2, Real.sqrt_sq (norm_nonneg _)]
    · rw [hnorm]
      have : 1 ≤ Real.sqrt (1 + t ^ 2 * tangentRatio a W i) := by
        rw [Real.le_sqrt (by norm_num) hden.le]
        nlinarith [mul_nonneg (sq_nonneg t) (tangentRatio_nonneg a ha W i)]
      nlinarith [Real.sqrt_nonneg a]
    · rw [hnorm, PiLp.smul_apply, smul_eq_mul]
      simp only [tangentSeed, Matrix.of_apply]
      have hsa : 0 < Real.sqrt a := Real.sqrt_pos.mpr ha
      have hsd : 0 < Real.sqrt (1 + t ^ 2 * tangentRatio a W i) := Real.sqrt_pos.mpr hden
      field_simp
  obtain ⟨y, hy, hyc, hyv⟩ := hrow Z hZ
  obtain ⟨y', hy', hyc', hyv'⟩ := hrow Z' hZ'
  have hlip := mr_normalisation_lipschitz ha y y' hy hy'
  have hsq := pow_le_pow_left₀ (norm_nonneg _) hlip 2
  rw [EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq] at hsq
  simp only [PiLp.sub_apply] at hsq
  calc ∑ j, (tangentSeed X Z a t i j - tangentSeed X Z' a t i j) ^ 2
      = ∑ j, (((Real.sqrt a / ‖y‖) • y) j - ((Real.sqrt a / ‖y'‖) • y') j) ^ 2 := by
        simp_rw [hyv, hyv']
    _ ≤ ∑ j, (y j - y' j) ^ 2 := hsq
    _ = t ^ 2 * ∑ j, (Z i j - Z' i j) ^ 2 := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl; intro j _
        rw [hyc, hyc']; ring

/-- `eq:mr-contract` (with the exact row norms and the 1-Lipschitz normalisation).

TeX: "Since $z_i\perp x_i$, $\norm{v_i}^2=\norm{v_{0,i}}^2=a$ exactly. [...] Thus
\[ \fro{V-X}\le t\fro Z,\quad \fro{V-V_0}\le t\fro{Z-Z_0},\quad
 \opn V\le\opn{X+tZ},\quad\opn{V_0}\le\opn{X+tZ_0}, \]" -/
theorem eq_mr_contract {n d : ℕ} (X Z Z₀ : Frame n d) {a t : ℝ} (ha : 0 < a) (ht : 0 < t)
    (ht1 : t ≤ 1) (hX : ∀ i, rowNormSq X i = a) (hZ : ∀ i, rowDot X Z i = 0)
    (hZ₀ : ∀ i, rowDot X Z₀ i = 0) :
    (∀ i, rowNormSq (tangentSeed X Z a t) i = a) ∧
    (∀ i, rowNormSq (tangentSeed X Z₀ a t) i = a) ∧
    Real.sqrt (sqDistance (tangentSeed X Z a t) X) ≤ t * Real.sqrt (frobSq Z) ∧
    Real.sqrt (sqDistance (tangentSeed X Z a t) (tangentSeed X Z₀ a t)) ≤
      t * Real.sqrt (sqDistance Z Z₀) ∧
    opNorm (tangentSeed X Z a t) ≤ opNorm (X + t • Z) ∧
    opNorm (tangentSeed X Z₀ a t) ≤ opNorm (X + t • Z₀) := by
  have hop (W : Frame n d) : opNorm (tangentSeed X W a t) ≤ opNorm (X + t • W) := by
    have h := euclidean_operator_norm_sq_le_of_frameEnergy (tangentSeed X W a t)
      (opNorm (X + t • W) ^ 2) (sq_nonneg _) (fun x =>
        (frameEnergy_tangentSeed_le_perturbed X W a t ha x).trans
          (frameEnergy_le_operator_norm_sq _ x))
    exact (pow_le_pow_iff_left₀ (norm_nonneg _) (mrx_opNorm_nonneg _) (by norm_num)).mp h
  have hsq (W : ℝ) (hW : 0 ≤ W) : Real.sqrt (t ^ 2 * W) = t * Real.sqrt W := by
    rw [Real.sqrt_mul (sq_nonneg t), Real.sqrt_sq ht.le]
  refine ⟨fun i => tangentSeed_rowNormSq X Z a t ha i (hX i) (hZ i),
    fun i => tangentSeed_rowNormSq X Z₀ a t ha i (hX i) (hZ₀ i), ?_, ?_, hop Z, hop Z₀⟩
  · have hX0 : tangentSeed X 0 a t = X := by
      ext i j; simp [tangentSeed, tangentRatio, rowNormSq]
    have h : sqDistance (tangentSeed X Z a t) X ≤ t ^ 2 * frobSq Z := by
      conv_lhs => rw [← hX0]
      unfold sqDistance frobSq
      rw [Finset.mul_sum]
      apply Finset.sum_le_sum; intro i _
      have := mr_aux_row_contract X Z 0 ha t hX hZ (fun i => by simp [rowDot]) i
      simpa using this
    have hF : 0 ≤ frobSq Z := Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ =>
      sq_nonneg _
    rw [← hsq _ hF]
    exact Real.sqrt_le_sqrt h
  · have h : sqDistance (tangentSeed X Z a t) (tangentSeed X Z₀ a t) ≤ t ^ 2 * sqDistance Z Z₀ := by
      unfold sqDistance
      rw [Finset.mul_sum]
      exact Finset.sum_le_sum fun i _ => mr_aux_row_contract X Z Z₀ ha t hX hZ hZ₀ i
    rw [← hsq _ (sqDistance_nonneg _ _)]
    exact Real.sqrt_le_sqrt h

/-- `c_i = r_i/(1+t² r_i)`, with `r_i = ‖z_i‖²/a`. -/
def mrWeight {n d : ℕ} (a t : ℝ) (Z : Frame n d) (i : Fin n) : ℝ :=
  tangentRatio a Z i / (1 + t ^ 2 * tangentRatio a Z i)

/-- `Q(Z) = ZᵀZ - ∑_i r_i x_i x_iᵀ`. -/
def mrQ {n d : ℕ} (X Z : Frame n d) (a : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  Z.transpose * Z - X.transpose * Matrix.diagonal (tangentRatio a Z) * X

/-- `R₃ = -t³ ∑_i c_i (x_i z_iᵀ + z_i x_iᵀ)`. -/
def mrR3 {n d : ℕ} (X Z : Frame n d) (a t : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  (-t ^ 3) • (X.transpose * Matrix.diagonal (mrWeight a t Z) * Z +
    Z.transpose * Matrix.diagonal (mrWeight a t Z) * X)

/-- `R₄ = -t⁴ ∑_i c_i (z_i z_iᵀ - r_i x_i x_iᵀ)`. -/
def mrR4 {n d : ℕ} (X Z : Frame n d) (a t : ℝ) : Matrix (Fin d) (Fin d) ℝ :=
  (-t ^ 4) • (Z.transpose * Matrix.diagonal (mrWeight a t Z) * Z -
    X.transpose * Matrix.diagonal (fun i => mrWeight a t Z i * tangentRatio a Z i) * X)

/-- Bridge to the library (not in the paper): `Q` and `R₃ + R₄` are the library's
`tangentQuadratic` and `tangentRemainder`. -/
theorem mrQ_mrR_eq_library {n d : ℕ} (X Z : Frame n d) (a t : ℝ) :
    mrQ X Z a = tangentQuadratic X Z a ∧
    mrR3 X Z a t + mrR4 X Z a t = tangentRemainder X Z a t := by
  constructor
  · ext j k
    simp only [mrQ, tangentQuadratic, Matrix.sub_apply, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.of_apply, Matrix.diagonal_apply, mul_ite, mul_zero, Finset.sum_ite_eq',
      Finset.mem_univ, if_true, Finset.sum_sub_distrib]
    congr 1
    apply Finset.sum_congr rfl; intro i _; ring
  · ext j k
    simp only [mrR3, mrR4, mrWeight, tangentRemainder, Matrix.add_apply, Matrix.sub_apply,
      Matrix.smul_apply, smul_eq_mul, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.of_apply, Matrix.diagonal_apply, mul_ite, mul_zero, Finset.sum_ite_eq',
      Finset.mem_univ, if_true, Finset.mul_sum, ← Finset.sum_add_distrib,
      ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl; intro i _; ring

/-- `eq:mr-identity`.

TeX: "Expanding $1/(1+t^2r_i)=1-t^2c_i$ with $c_i=\frac{r_i}{1+t^2r_i}$,
and using $X^TZ+Z^TX=0$, one finds the exact identity
\[ V^TV=S+t^2Q(Z)+R_3+R_4,\qquad Q(Z)=Z^TZ-\sum_ir_ix_ix_i^T, \]
\[ R_3=-t^3\sum_ic_i(x_iz_i^T+z_ix_i^T),\qquad
 R_4=-t^4\sum_ic_i(z_iz_i^T-r_ix_ix_i^T). \]" -/
theorem eq_mr_identity {n d : ℕ} (X Z : Frame n d) {a : ℝ} (ha : 0 < a) (t : ℝ)
    (hglobal : X.transpose * Z + Z.transpose * X = 0) :
    (∀ i, 1 / (1 + t ^ 2 * tangentRatio a Z i) = 1 - t ^ 2 * mrWeight a t Z i) ∧
    (tangentSeed X Z a t).transpose * tangentSeed X Z a t =
      X.transpose * X + t ^ 2 • mrQ X Z a + mrR3 X Z a t + mrR4 X Z a t := by
  refine ⟨fun i => ?_, ?_⟩
  · have hr := tangentRatio_nonneg a ha Z i
    have hden : 0 < 1 + t ^ 2 * tangentRatio a Z i := tangent_denominator_pos a t ha Z i
    unfold mrWeight
    field_simp
    ring
  · obtain ⟨hQ, hR⟩ := mrQ_mrR_eq_library X Z a t
    rw [add_assoc, hR, hQ]
    exact tangentSeed_frameOperator_expansion X Z a t ha hglobal

/-- `E Q(Z)`, entrywise. -/
def mrQMean {n d : ℕ} (X : Frame n d) : Matrix (Fin d) (Fin d) ℝ :=
  Matrix.of fun j k => ∫ g, mrQ X (conditionedNoise X g) ((d : ℝ) / n) j k ∂gaussFrame n d

/-- Proof of `lem:Q`: the unconstrained mean.

TeX: "For $Z_0$: $\E Z_0^TZ_0=n^{-1}\sum_i(I-e_ie_i^T)=I-S/d$ and $\E r_{0,i}=(d-1)/d$,
so $\E Q(Z_0)=I-S/d-(1-1/d)S=I-S$." -/
theorem lem_Q_row_mean {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (X : Frame n d)
    (hX : IsEqualNorm X) :
    (Matrix.of fun j k => ∫ g, ((rowNoise X g).transpose * rowNoise X g) j k ∂gaussFrame n d) =
      1 - (1 / (d : ℝ)) • (X.transpose * X) ∧
    (∀ i, ∫ g, tangentRatio ((d : ℝ) / n) (rowNoise X g) i ∂gaussFrame n d =
      ((d : ℝ) - 1) / d) ∧
    (Matrix.of fun j k => ∫ g, mrQ X (rowNoise X g) ((d : ℝ) / n) j k ∂gaussFrame n d) =
      1 - X.transpose * X := by
  have hd0 : 0 < d := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  set a : ℝ := (d : ℝ) / n with ha_def
  have ha : 0 < a := by positivity
  set R := rowTangentNoiseFactor X with hRdef
  set P := subspaceProjectionMatrix (rowTangentSpace X)
  have hRR : R * R.transpose = (1 / (n : ℝ)) • P := by
    rw [hRdef, rowTangentNoiseFactor, Matrix.transpose_smul, (subspaceProjectionMatrix_symmetric _).eq,
      Matrix.smul_mul, Matrix.mul_smul, smul_smul, subspaceProjectionMatrix_idempotent,
      div_mul_div_comm, one_mul, Real.mul_self_sqrt (Nat.cast_nonneg n)]
  have hP (i l : Fin n) (j k : Fin d) : P (i, j) (l, k) =
      if i = l then (if j = k then 1 else 0) - X i j * X i k / a else 0 :=
    rowTangentProjectionMatrix_apply X ha hX i l j k
  have hZ₀ (g : FrameVector n d) (i : Fin n) (j : Fin d) :
      rowNoise X g i j = (Matrix.toEuclideanLin R g) (i, j) := rfl
  have hcorr (i : Fin n) (j k : Fin d) := gauss_aux_coord_mul R (i, j) (i, k)
  -- `E Z₀ᵀZ₀`
  have h1 : (Matrix.of fun j k => ∫ g, ((rowNoise X g).transpose * rowNoise X g) j k
      ∂gaussFrame n d) = 1 - (1 / (d : ℝ)) • (X.transpose * X) := by
    ext j k
    simp only [Matrix.of_apply, Matrix.mul_apply, Matrix.transpose_apply, hZ₀]
    rw [integral_finsetSum _ fun i _ => (hcorr i j k).1]
    simp_rw [fun i => (hcorr i j k).2, hRR, Matrix.smul_apply, smul_eq_mul, hP, if_true]
    simp only [Matrix.sub_apply, Matrix.one_apply, Matrix.smul_apply, smul_eq_mul,
      Matrix.mul_apply, Matrix.transpose_apply]
    rw [← Finset.mul_sum, Finset.sum_sub_distrib]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    rw [← Finset.sum_div, ha_def]
    split_ifs <;> field_simp
  -- `E r_{0,i}`
  have h2 (i : Fin n) : ∫ g, tangentRatio a (rowNoise X g) i ∂gaussFrame n d =
      ((d : ℝ) - 1) / d := by
    unfold tangentRatio rowNormSq
    rw [integral_div, integral_finsetSum _ fun j _ => by
      simpa only [pow_two, hZ₀] using (hcorr i j j).1]
    simp_rw [pow_two, hZ₀, fun j => (hcorr i j j).2, hRR, Matrix.smul_apply, smul_eq_mul]
    rw [← Finset.mul_sum, rowTangentProjectionMatrix_block_trace X ha hX i, ha_def]
    field_simp
  refine ⟨h1, h2, ?_⟩
  -- `E Q(Z₀) = E Z₀ᵀZ₀ - ∑ E r_{0,i} x_i x_iᵀ = I - S/d - (1-1/d) S = I - S`
  ext j k
  have hQ (g : FrameVector n d) : mrQ X (rowNoise X g) a j k =
      ((rowNoise X g).transpose * rowNoise X g) j k -
        ∑ i, tangentRatio a (rowNoise X g) i * (X i j * X i k) := by
    simp only [mrQ, Matrix.sub_apply, Matrix.mul_apply, Matrix.transpose_apply,
      Matrix.diagonal_apply, mul_ite, mul_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true]
    congr 1
    apply Finset.sum_congr rfl; intro i _; ring
  have hint1 : Integrable (fun g => ((rowNoise X g).transpose * rowNoise X g) j k)
      (gaussFrame n d) := by
    simp only [Matrix.mul_apply, Matrix.transpose_apply, hZ₀]
    exact integrable_finsetSum _ fun i _ => (hcorr i j k).1
  have hint2 (i : Fin n) : Integrable (fun g => tangentRatio a (rowNoise X g) i)
      (gaussFrame n d) :=
    ((memLp_rowNormSq_gaussianImage R i).integrable (by norm_num)).div_const a
  simp only [Matrix.of_apply]
  simp_rw [hQ]
  rw [integral_sub hint1 (integrable_finsetSum _ fun i _ => (hint2 i).mul_const _),
    integral_finsetSum _ fun i _ => (hint2 i).mul_const _]
  simp_rw [integral_mul_const, h2]
  have h1jk := congrFun (congrFun h1 j) k
  simp only [Matrix.of_apply] at h1jk
  rw [h1jk]
  simp only [Matrix.sub_apply, Matrix.one_apply, Matrix.smul_apply, smul_eq_mul,
    Matrix.mul_apply, Matrix.transpose_apply]
  rw [← Finset.mul_sum]
  have hdR : (0 : ℝ) < d := by exact_mod_cast hd0
  field_simp
  ring

/-- Proof of `lem:Q`: the coefficient matrices of the entries of `Q`.

TeX: "Entry $(\alpha,\beta)$ of $Q$ is the quadratic form $\sum_iz_i^T\mathsf B_{\alpha\beta,i}z_i$
with $\mathsf B_{\alpha\beta,i}=\frac12(E_{\alpha\beta}+E_{\beta\alpha})-(e_i)_\alpha(e_i)_\beta I$
[...] Since $\sum_{\alpha,\beta}\fro{\mathsf B_{\alpha\beta,i}}^2\le2d^2+2d\le4d^2$ for
each $i$" (here `e` is any unit vector). -/
theorem lem_Q_coefficients {d : ℕ} (hd : 1 ≤ d) (e : Fin d → ℝ) (he : vectorNormSq e = 1) :
    ∑ α, ∑ β, frobSq ((1 / 2 : ℝ) • (Matrix.single α β (1 : ℝ) + Matrix.single β α 1) -
        (e α * e β) • (1 : Matrix (Fin d) (Fin d) ℝ)) ≤ 2 * (d : ℝ) ^ 2 + 2 * d ∧
    2 * (d : ℝ) ^ 2 + 2 * d ≤ 4 * (d : ℝ) ^ 2 := by
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  refine ⟨?_, by nlinarith⟩
  have hsingle (α β : Fin d) : frobSq (Matrix.single α β (1 : ℝ)) = 1 := by
    simp [frobSq, Matrix.single_apply, ite_and, Finset.sum_ite_eq]
  have hsplit (α β : Fin d) :
      frobSq ((1 / 2 : ℝ) • (Matrix.single α β (1 : ℝ) + Matrix.single β α 1) -
        (e α * e β) • (1 : Matrix (Fin d) (Fin d) ℝ)) ≤
      2 * 1 + 2 * ((e α) ^ 2 * (e β) ^ 2 * d) := by
    have hA : frobSq ((1 / 2 : ℝ) • (Matrix.single α β (1 : ℝ) + Matrix.single β α 1)) ≤ 1 := by
      have h := fun i j => (show ((1 / 2 : ℝ) * ((Matrix.single α β (1 : ℝ)) i j +
          (Matrix.single β α 1) i j)) ^ 2 ≤ (1 / 2) * ((Matrix.single α β (1 : ℝ)) i j) ^ 2 +
          (1 / 2) * ((Matrix.single β α (1 : ℝ)) i j) ^ 2 by
        nlinarith [sq_nonneg ((Matrix.single α β (1 : ℝ)) i j - (Matrix.single β α (1 : ℝ)) i j)])
      calc _ ≤ ∑ i, ∑ j, ((1 / 2) * ((Matrix.single α β (1 : ℝ)) i j) ^ 2 +
            (1 / 2) * ((Matrix.single β α (1 : ℝ)) i j) ^ 2) := by
            unfold frobSq
            exact Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => by
              simpa only [Matrix.smul_apply, Matrix.add_apply, smul_eq_mul] using h i j
        _ = (1 / 2) * frobSq (Matrix.single α β (1 : ℝ)) +
            (1 / 2) * frobSq (Matrix.single β α (1 : ℝ)) := by
            simp only [frobSq, Finset.sum_add_distrib, Finset.mul_sum]
        _ = 1 := by rw [hsingle, hsingle]; norm_num
    have hB : frobSq ((e α * e β) • (1 : Matrix (Fin d) (Fin d) ℝ)) =
        (e α) ^ 2 * (e β) ^ 2 * d := by
      simp only [frobSq, Matrix.smul_apply, Matrix.one_apply, smul_eq_mul, mul_ite, mul_one,
        mul_zero, ite_pow, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow,
        Finset.sum_ite_eq, Finset.mem_univ, if_true, Finset.sum_const, Finset.card_univ,
        Fintype.card_fin, nsmul_eq_mul]
      ring
    have hsub (A B : Matrix (Fin d) (Fin d) ℝ) : frobSq (A - B) ≤ 2 * frobSq A + 2 * frobSq B := by
      unfold frobSq
      rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
      apply Finset.sum_le_sum; intro i _
      rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
      apply Finset.sum_le_sum; intro j _
      simp only [Matrix.sub_apply]
      nlinarith [sq_nonneg (A i j + B i j)]
    calc _ ≤ _ := hsub _ _
      _ ≤ _ := by rw [hB]; linarith
  have he' : ∑ α, (e α) ^ 2 = 1 := he
  have hre : ∀ α β : Fin d, (2 * 1 + 2 * ((e α) ^ 2 * (e β) ^ 2 * d)) =
      2 + (2 * d) * ((e α) ^ 2 * (e β) ^ 2) := by
    intro α β; ring
  calc _ ≤ ∑ α : Fin d, ∑ β : Fin d, (2 * 1 + 2 * ((e α) ^ 2 * (e β) ^ 2 * d)) :=
        Finset.sum_le_sum fun α _ => Finset.sum_le_sum fun β _ => hsplit α β
    _ = _ := by
        simp_rw [hre, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.sum_mul, he']
        simp
        ring

theorem mrx_matrixQuadratic_neg {d : ℕ} (M : Matrix (Fin d) (Fin d) ℝ) (x : Fin d → ℝ) :
    matrixQuadratic (-M) x = -matrixQuadratic M x := by
  simp [matrixQuadratic, Finset.sum_neg_distrib]

/-- The total coefficient size `∑_{α,β} ‖𝖡_{αβ}‖_F² ≤ 4nd²` from `lem_Q_coefficients`
(not a paper item; the block-diagonal sum over the `n` rows). -/
theorem mr_aux_coefficient_total {n d : ℕ} (hd : 1 ≤ d) (X : Frame n d) {a : ℝ} (ha : 0 < a)
    (hrows : ∀ i, rowNormSq X i = a) :
    (∑ j, ∑ k, ∑ p, ∑ q, tangentQuadraticCoefficient X a j k p q ^ 2) ≤ 4 * n * (d : ℝ) ^ 2 := by
  simp_rw [tangentQuadraticCoefficient_sq_sum]
  have hrow (i : Fin n) : ∑ j, ∑ k, ∑ u, ∑ v, tangentRowCoefficient X a i j k u v ^ 2 ≤
      4 * (d : ℝ) ^ 2 := by
    set e : Fin d → ℝ := fun j => X i j / Real.sqrt a with he
    have hsa : Real.sqrt a ^ 2 = a := Real.sq_sqrt ha.le
    have hsa0 : Real.sqrt a ≠ 0 := (Real.sqrt_pos.mpr ha).ne'
    have hne : vectorNormSq e = 1 := by
      unfold vectorNormSq
      simp only [he, div_pow, hsa, ← Finset.sum_div]
      rw [show (∑ j, X i j ^ 2) = rowNormSq X i from rfl, hrows i, div_self ha.ne']
    have hco (j k : Fin d) : tangentRowCoefficient X a i j k =
        (1 / 2 : ℝ) • (Matrix.single j k (1 : ℝ) + Matrix.single k j 1) -
          (e j * e k) • (1 : Matrix (Fin d) (Fin d) ℝ) := by
      have hek : e j * e k = X i j * X i k / a := by
        simp only [he]; rw [div_mul_div_comm, ← pow_two, hsa]
      have hpair (u v j k : Fin d) : ((if u = j then (1:ℝ) else 0) * (if v = k then 1 else 0)) =
          (if j = u ∧ k = v then 1 else 0) := by
        by_cases h1 : u = j <;> by_cases h2 : v = k <;> simp [h1, h2, eq_comm]
      rw [hek]
      ext u v
      simp only [tangentRowCoefficient, coordinatePairCoefficient, Matrix.sub_apply,
        Matrix.of_apply, Matrix.smul_apply, Matrix.add_apply, Matrix.single_apply, smul_eq_mul,
        hpair]
      ring
    have := (lem_Q_coefficients hd e hne)
    calc _ = ∑ j, ∑ k, frobSq (tangentRowCoefficient X a i j k) := rfl
      _ = _ := by simp_rw [hco]
      _ ≤ 4 * (d : ℝ) ^ 2 := this.1.trans this.2
  calc _ = ∑ i, ∑ j, ∑ k, ∑ u, ∑ v, tangentRowCoefficient X a i j k u v ^ 2 := by
        calc _ = ∑ j, ∑ i, ∑ k, ∑ u, ∑ v, tangentRowCoefficient X a i j k u v ^ 2 :=
              Finset.sum_congr rfl fun j _ => Finset.sum_comm
          _ = _ := Finset.sum_comm
    _ ≤ ∑ _i : Fin n, 4 * (d : ℝ) ^ 2 := Finset.sum_le_sum fun i _ => hrow i
    _ = _ := by simp; ring

/-- `lem:Q` (Mean and fluctuation of `Q`).

TeX: "$\opn{\E Q(Z)-(I-S)}\le m/n$ and $\E\fro{Q(Z)-\E Q(Z)}^2\le8d^2/n$." -/
theorem lem_Q {n d : ℕ} (hn : 0 < n) (hd : 1 ≤ d) (X : Frame n d) (hX : IsEqualNorm X) :
    opNorm (mrQMean X - (1 - X.transpose * X)) ≤ mrCodim X / n ∧
    ∫ g, frobSq (mrQ X (conditionedNoise X g) ((d : ℝ) / n) - mrQMean X) ∂gaussFrame n d ≤
      8 * (d : ℝ) ^ 2 / n := by
  have hd0 : 0 < d := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  set a : ℝ := (d : ℝ) / n with ha_def
  have ha : 0 < a := by positivity
  set C := tangentNoiseFactor X with hCdef
  set R := rowTangentNoiseFactor X with hRdef
  have hQb (Z : Frame n d) (b : ℝ) : mrQ X Z b = tangentQuadratic X Z b :=
    (mrQ_mrR_eq_library X Z b 0).1
  have hmean : mrQMean X = tangentQuadraticMean X a C := by
    ext j k
    simp only [mrQMean, Matrix.of_apply]
    simp_rw [hQb]
    unfold conditionedNoise
    exact integral_tangentQuadratic X a C j k
  have hrowmean : (1 : Matrix (Fin d) (Fin d) ℝ) - X.transpose * X = tangentQuadraticMean X a R := by
    rw [← (lem_Q_row_mean hn hd X hX).2.2]
    ext j k
    simp only [Matrix.of_apply]
    simp_rw [hQb]
    unfold rowNoise
    exact integral_tangentQuadratic X a R j k
  constructor
  · -- the trace argument on `E Q(Z_⊥)`
    have hdiff : mrQMean X - (1 - X.transpose * X) =
        -((1 / (n : ℝ)) • tangentCovarianceMean X a
          (subspaceProjectionMatrix (removedTangentSpace X))) := by
      rw [hmean, hrowmean, hCdef, hRdef, tangentQuadraticMean_tangentNoiseFactor,
        tangentQuadraticMean_rowTangentNoiseFactor, removedTangentProjectionMatrix_eq_sub,
        tangentCovarianceMean_sub, smul_sub, neg_sub]
    have hm : (Module.finrank ℝ (removedTangentSpace X) : ℝ) = mrCodim X := by
      have hrem := mrx_removed_finrank X
      unfold mrCodim
      have : (Module.finrank ℝ (globalTangentSpace X) : ℝ) +
          (Module.finrank ℝ (removedTangentSpace X) : ℝ) =
          (Module.finrank ℝ (rowTangentSpace X) : ℝ) := by exact_mod_cast hrem
      linarith
    have hsymQ (Z : Frame n d) (b : ℝ) (j k : Fin d) : mrQ X Z b j k = mrQ X Z b k j := by
      simp only [mrQ, Matrix.sub_apply, Matrix.mul_apply, Matrix.transpose_apply,
        Matrix.diagonal_apply, mul_ite, mul_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true]
      congr 1 <;> apply Finset.sum_congr rfl <;> intro i _ <;> ring
    have hsym : (mrQMean X - (1 - X.transpose * X)).IsHermitian := by
      have h1 : (mrQMean X).IsHermitian := by
        ext j k
        simp only [Matrix.conjTranspose_apply, star_trivial, mrQMean, Matrix.of_apply]
        simp_rw [hsymQ _ ((d : ℝ) / n) k j]
      have h2 : (X.transpose * X).IsHermitian := by
        simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
          Matrix.isHermitian_conjTranspose_mul_self X
      exact h1.sub (Matrix.isHermitian_one.sub h2)
    have hm0 : 0 ≤ mrCodim X := (mr_codim_le X hX hd).1
    apply mrx_opNorm_le_of_quadratic _ hsym (div_nonneg hm0 hnR.le)
    intro x
    rw [hdiff, mrx_matrixQuadratic_neg, abs_neg, matrixQuadratic_smul, abs_mul,
      abs_of_nonneg (by positivity : (0 : ℝ) ≤ 1 / n)]
    have hb := tangentCovarianceMean_projection_abs_le X ha hX (removedTangentSpace X) x
    rw [hm] at hb
    calc 1 / (n : ℝ) * |matrixQuadratic (tangentCovarianceMean X a
          (subspaceProjectionMatrix (removedTangentSpace X))) x| ≤
        1 / (n : ℝ) * (mrCodim X * vectorNormSq x) := mul_le_mul_of_nonneg_left hb (by positivity)
      _ = _ := by unfold vectorNormSq; ring
  · -- the fluctuation, entry by entry
    have hC : opNorm C ^ 2 ≤ 1 / (n : ℝ) := tangentNoiseFactor_operator_norm_sq_le X hn
    have hCC : opNorm (C * C.transpose) ≤ 1 / (n : ℝ) := by
      rw [show opNorm (C * C.transpose) = opNorm C ^ 2 from euclidean_operator_norm_covariance C]
      exact hC
    have hentry (j k : Fin d) :
        ∫ g, (tangentQuadratic X (conditionedNoise X g) a j k - tangentQuadraticMean X a C j k) ^ 2
          ∂gaussFrame n d ≤
        2 * (1 / (n : ℝ)) ^ 2 * frobSq (tangentQuadraticCoefficient X a j k) := by
      have hB := tangentQuadraticCoefficient_isHermitian X a j k
      obtain ⟨-, hfrob, -, -⟩ := lem_gauss_a_correlated _ hB C 0
      have e1 : ∀ g, tangentQuadratic X (conditionedNoise X g) a j k -
          tangentQuadraticMean X a C j k =
          euclideanQuadratic (C.transpose * tangentQuadraticCoefficient X a j k * C) g -
            (C.transpose * tangentQuadraticCoefficient X a j k * C).trace := by
        intro g
        unfold conditionedNoise
        rw [tangentQuadratic_linear_image]
        rfl
      simp_rw [e1]
      rw [integral_sq_centered_euclideanQuadratic_stdGaussian _
        (isHermitian_quadratic_pullback _ hB C)]
      have hCC2 : opNorm (C * C.transpose) ^ 2 ≤ (1 / (n : ℝ)) ^ 2 :=
        pow_le_pow_left₀ (mrx_opNorm_nonneg _) hCC 2
      have hF0 : 0 ≤ frobSq (tangentQuadraticCoefficient X a j k) :=
        Finset.sum_nonneg fun p _ => Finset.sum_nonneg fun q _ => sq_nonneg _
      calc 2 * ∑ p, ∑ q, (C.transpose * tangentQuadraticCoefficient X a j k * C) p q ^ 2
          = 2 * frobSq (C.transpose * tangentQuadraticCoefficient X a j k * C) := rfl
        _ ≤ 2 * (opNorm (C * C.transpose) ^ 2 * frobSq (tangentQuadraticCoefficient X a j k)) :=
          mul_le_mul_of_nonneg_left hfrob (by norm_num)
        _ ≤ 2 * ((1 / (n : ℝ)) ^ 2 * frobSq (tangentQuadraticCoefficient X a j k)) := by
          gcongr
        _ = _ := by ring
    have hint (j k : Fin d) := (tangentQuadratic_centered_memLp X a C j k).integrable_sq
    have hfrob (g : FrameVector n d) : frobSq (mrQ X (conditionedNoise X g) a - mrQMean X) =
        ∑ j, ∑ k, (tangentQuadratic X (conditionedNoise X g) a j k -
          tangentQuadraticMean X a C j k) ^ 2 := by
      simp only [frobSq, Matrix.sub_apply, hQb, hmean]
    simp_rw [hfrob]
    unfold conditionedNoise
    rw [integral_finsetSum _ fun j _ => integrable_finsetSum _ fun k _ => hint j k]
    simp_rw [integral_finsetSum _ fun k _ => hint _ k]
    have htot := mr_aux_coefficient_total hd X ha hX
    calc _ ≤ ∑ j, ∑ k, 2 * (1 / (n : ℝ)) ^ 2 * frobSq (tangentQuadraticCoefficient X a j k) :=
          Finset.sum_le_sum fun j _ => Finset.sum_le_sum fun k _ => hentry j k
      _ = 2 * (1 / (n : ℝ)) ^ 2 *
          ∑ j, ∑ k, ∑ p, ∑ q, tangentQuadraticCoefficient X a j k p q ^ 2 := by
          simp only [frobSq, Finset.mul_sum]
      _ ≤ 2 * (1 / (n : ℝ)) ^ 2 * (4 * n * (d : ℝ) ^ 2) :=
          mul_le_mul_of_nonneg_left htot (by positivity)
      _ = _ := by field_simp; ring

/-- `c̄ = 1/(1+t²)`. -/
def mrCbar (t : ℝ) : ℝ := 1 / (1 + t ^ 2)

/-- `Γ = Diag(c_i - c̄)`. -/
def mrGamma {n d : ℕ} (a t : ℝ) (Z : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal fun i => mrWeight a t Z i - mrCbar t

/-- `Λ = Diag(c_i r_i - c̄)`. -/
def mrLambda {n d : ℕ} (a t : ℝ) (Z : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal fun i => mrWeight a t Z i * tangentRatio a Z i - mrCbar t

/-- Proof of `lem:remainder`: the scalar weight identities.

TeX: "c_i-\bar c=\frac{r_i-1}{(1+t^2r_i)(1+t^2)},\qquad
 c_ir_i-\bar c=\frac{(r_i-1)(1+r_i+t^2r_i)}{(1+t^2r_i)(1+t^2)},
so $|c_i-\bar c|\le|r_i-1|$ and, as $1+r+t^2r\le(1+r)(1+t^2r)$,
$|c_ir_i-\bar c|\le|r_i-1|(1+r_i)$." -/
theorem lem_remainder_scalar (r t : ℝ) (hr : 0 ≤ r) :
    r / (1 + t ^ 2 * r) - 1 / (1 + t ^ 2) = (r - 1) / ((1 + t ^ 2 * r) * (1 + t ^ 2)) ∧
    r / (1 + t ^ 2 * r) * r - 1 / (1 + t ^ 2) =
      (r - 1) * (1 + r + t ^ 2 * r) / ((1 + t ^ 2 * r) * (1 + t ^ 2)) ∧
    |r / (1 + t ^ 2 * r) - 1 / (1 + t ^ 2)| ≤ |r - 1| ∧
    1 + r + t ^ 2 * r ≤ (1 + r) * (1 + t ^ 2 * r) ∧
    |r / (1 + t ^ 2 * r) * r - 1 / (1 + t ^ 2)| ≤ |r - 1| * (1 + r) := by
  have hD1 : 1 ≤ 1 + t ^ 2 * r := by nlinarith [mul_nonneg (sq_nonneg t) hr]
  have hD2 : 1 ≤ 1 + t ^ 2 := by nlinarith [sq_nonneg t]
  have hD : 1 ≤ (1 + t ^ 2 * r) * (1 + t ^ 2) := by nlinarith
  have hDpos : 0 < (1 + t ^ 2 * r) * (1 + t ^ 2) := by linarith
  have e1 : r / (1 + t ^ 2 * r) - 1 / (1 + t ^ 2) = (r - 1) / ((1 + t ^ 2 * r) * (1 + t ^ 2)) := by
    field_simp; ring
  have e2 : r / (1 + t ^ 2 * r) * r - 1 / (1 + t ^ 2) =
      (r - 1) * (1 + r + t ^ 2 * r) / ((1 + t ^ 2 * r) * (1 + t ^ 2)) := by
    field_simp; ring
  have h4 : 1 + r + t ^ 2 * r ≤ (1 + r) * (1 + t ^ 2 * r) := by
    nlinarith [mul_nonneg (mul_nonneg (sq_nonneg t) hr) hr]
  refine ⟨e1, e2, ?_, h4, ?_⟩
  · rw [e1, abs_div, abs_of_pos hDpos]
    exact div_le_self (abs_nonneg _) hD
  · rw [e2, abs_div, abs_of_pos hDpos, abs_mul, abs_of_nonneg (by positivity : (0:ℝ) ≤ 1 + r + t ^ 2 * r)]
    rw [div_le_iff₀ hDpos]
    have hab := abs_nonneg (r - 1)
    calc |r - 1| * (1 + r + t ^ 2 * r) ≤ |r - 1| * ((1 + r) * (1 + t ^ 2 * r)) :=
          mul_le_mul_of_nonneg_left h4 hab
      _ ≤ |r - 1| * (1 + r) * ((1 + t ^ 2 * r) * (1 + t ^ 2)) := by
          have : (1 + r) * (1 + t ^ 2 * r) ≤ (1 + r) * ((1 + t ^ 2 * r) * (1 + t ^ 2)) := by
            apply mul_le_mul_of_nonneg_left _ (by linarith)
            nlinarith
          nlinarith [mul_le_mul_of_nonneg_left this hab]

/-- `lem:remainder` (Remainder), deterministic bounds.

TeX: "Let $\bar c=1/(1+t^2)$, $\Gamma=\Diag(c_i-\bar c)$ and
$\Lambda=\Diag(c_ir_i-\bar c)$. Then
\[ \opn{R_3}\le2t^3\opn X\fro{\Gamma Z},\qquad
 \opn{R_4}\le t^4\bigl(\opn Z^2+\opn Z\fro{\Gamma Z}+\opn S+\opn X\fro{\Lambda X}\bigr), \]" -/
theorem lem_remainder {n d : ℕ} (X Z : Frame n d) {a t : ℝ} (ha : 0 < a) (ht : 0 < t)
    (ht1 : t ≤ 1) (hglobal : X.transpose * Z + Z.transpose * X = 0) :
    opNorm (mrR3 X Z a t) ≤ 2 * t ^ 3 * opNorm X * Real.sqrt (frobSq (mrGamma a t Z * Z)) ∧
    opNorm (mrR4 X Z a t) ≤ t ^ 4 * (opNorm Z ^ 2 +
      opNorm Z * Real.sqrt (frobSq (mrGamma a t Z * Z)) + opNorm (X.transpose * X) +
      opNorm X * Real.sqrt (frobSq (mrLambda a t Z * X))) := by
  have hcb0 : 0 < mrCbar t := by unfold mrCbar; positivity
  have hcb1 : mrCbar t ≤ 1 := by
    unfold mrCbar; rw [div_le_one (by positivity)]; nlinarith [sq_nonneg t]
  have hDc : Matrix.diagonal (mrWeight a t Z) = mrGamma a t Z + mrCbar t • (1 : Matrix _ _ ℝ) := by
    ext i j
    by_cases hij : i = j
    · subst hij; simp [mrGamma]
    · simp [mrGamma, hij]
  have hDl : Matrix.diagonal (fun i => mrWeight a t Z i * tangentRatio a Z i) =
      mrLambda a t Z + mrCbar t • (1 : Matrix _ _ ℝ) := by
    ext i j
    by_cases hij : i = j
    · subst hij; simp [mrLambda]
    · simp [mrLambda, hij]
  have hΓT : (mrGamma a t Z).transpose = mrGamma a t Z := by
    unfold mrGamma; exact Matrix.diagonal_transpose _
  have hΛT : (mrLambda a t Z).transpose = mrLambda a t Z := by
    unfold mrLambda; exact Matrix.diagonal_transpose _
  have hopZT : opNorm Z.transpose = opNorm Z := mrx_opNorm_transpose Z
  have hopXT : opNorm X.transpose = opNorm X := mrx_opNorm_transpose X
  have hGZ := mrx_opNorm_le_sqrt_frobSq (mrGamma a t Z * Z)
  have hLX := mrx_opNorm_le_sqrt_frobSq (mrLambda a t Z * X)
  constructor
  · -- `R₃ = -t³ (XᵀΓZ + (XᵀΓZ)ᵀ)`
    set A := X.transpose * (mrGamma a t Z * Z) with hA
    have hR3 : mrR3 X Z a t = (-t ^ 3) • (A + A.transpose) := by
      have hglob : X.transpose * Matrix.diagonal (mrWeight a t Z) * Z +
          Z.transpose * Matrix.diagonal (mrWeight a t Z) * X = A + A.transpose := by
        rw [hDc, hA, Matrix.transpose_mul, Matrix.transpose_mul, hΓT, Matrix.transpose_transpose]
        simp only [Matrix.mul_add, Matrix.add_mul, Matrix.mul_smul, Matrix.smul_mul,
          Matrix.mul_one, Matrix.mul_assoc]
        have : mrCbar t • (X.transpose * Z) + mrCbar t • (Z.transpose * X) = 0 := by
          rw [← smul_add, hglobal, smul_zero]
        calc _ = X.transpose * (mrGamma a t Z * Z) + Z.transpose * (mrGamma a t Z * X) +
              (mrCbar t • (X.transpose * Z) + mrCbar t • (Z.transpose * X)) := by abel
          _ = _ := by rw [this, add_zero]
      unfold mrR3
      rw [hglob]
    have hAop : opNorm A ≤ opNorm X * Real.sqrt (frobSq (mrGamma a t Z * Z)) := by
      calc opNorm A ≤ opNorm X.transpose * opNorm (mrGamma a t Z * Z) := mrx_opNorm_mul_le _ _
        _ ≤ _ := by rw [hopXT]; exact mul_le_mul_of_nonneg_left hGZ (mrx_opNorm_nonneg _)
    rw [hR3, mrx_opNorm_smul, abs_neg, abs_of_pos (by positivity)]
    have h2 : opNorm (A + A.transpose) ≤ 2 * opNorm A := by
      have := mrx_opNorm_add_le A A.transpose
      rw [mrx_opNorm_transpose] at this
      linarith
    calc t ^ 3 * opNorm (A + A.transpose) ≤ t ^ 3 * (2 * opNorm A) :=
          mul_le_mul_of_nonneg_left h2 (by positivity)
      _ ≤ t ^ 3 * (2 * (opNorm X * Real.sqrt (frobSq (mrGamma a t Z * Z)))) := by
          gcongr
      _ = _ := by ring
  · have hR4 : mrR4 X Z a t = (-t ^ 4) • (mrCbar t • (Z.transpose * Z) +
        Z.transpose * (mrGamma a t Z * Z) - mrCbar t • (X.transpose * X) -
        X.transpose * (mrLambda a t Z * X)) := by
      unfold mrR4
      rw [hDc, hDl]
      congr 1
      simp only [Matrix.mul_add, Matrix.add_mul, Matrix.mul_smul, Matrix.smul_mul,
        Matrix.mul_one, Matrix.mul_assoc]
      abel
    rw [hR4, mrx_opNorm_smul, abs_neg, abs_of_pos (by positivity)]
    apply mul_le_mul_of_nonneg_left _ (by positivity)
    have e1 : opNorm (mrCbar t • (Z.transpose * Z)) ≤ opNorm Z ^ 2 := by
      rw [mrx_opNorm_smul, abs_of_pos hcb0]
      have h := mrx_opNorm_mul_le Z.transpose Z
      rw [hopZT] at h
      have h0 := mrx_opNorm_nonneg (Z.transpose * Z)
      calc mrCbar t * opNorm (Z.transpose * Z) ≤ 1 * opNorm (Z.transpose * Z) :=
            mul_le_mul_of_nonneg_right hcb1 h0
        _ ≤ _ := by rw [one_mul, pow_two]; exact h
    have e2 : opNorm (Z.transpose * (mrGamma a t Z * Z)) ≤
        opNorm Z * Real.sqrt (frobSq (mrGamma a t Z * Z)) := by
      calc _ ≤ opNorm Z.transpose * opNorm (mrGamma a t Z * Z) := mrx_opNorm_mul_le _ _
        _ ≤ _ := by rw [hopZT]; exact mul_le_mul_of_nonneg_left hGZ (mrx_opNorm_nonneg _)
    have e3 : opNorm (mrCbar t • (X.transpose * X)) ≤ opNorm (X.transpose * X) := by
      rw [mrx_opNorm_smul, abs_of_pos hcb0]
      calc mrCbar t * opNorm (X.transpose * X) ≤ 1 * opNorm (X.transpose * X) :=
            mul_le_mul_of_nonneg_right hcb1 (mrx_opNorm_nonneg _)
        _ = _ := one_mul _
    have e4 : opNorm (X.transpose * (mrLambda a t Z * X)) ≤
        opNorm X * Real.sqrt (frobSq (mrLambda a t Z * X)) := by
      calc _ ≤ opNorm X.transpose * opNorm (mrLambda a t Z * X) := mrx_opNorm_mul_le _ _
        _ ≤ _ := by rw [hopXT]; exact mul_le_mul_of_nonneg_left hLX (mrx_opNorm_nonneg _)
    have t1 := mrx_opNorm_sub_le (mrCbar t • (Z.transpose * Z) + Z.transpose * (mrGamma a t Z * Z) -
      mrCbar t • (X.transpose * X)) (X.transpose * (mrLambda a t Z * X))
    have t2 := mrx_opNorm_sub_le (mrCbar t • (Z.transpose * Z) + Z.transpose * (mrGamma a t Z * Z))
      (mrCbar t • (X.transpose * X))
    have t3 := mrx_opNorm_add_le (mrCbar t • (Z.transpose * Z)) (Z.transpose * (mrGamma a t Z * Z))
    linarith

/-- Pointwise domination behind `lem_remainder_moments` (proof step):
`‖ΓZ‖_F² ≤ a ∑_i (r_i-1)²(1+r_i)²` and `‖ΛX‖_F² ≤ a ∑_i (r_i-1)²(1+r_i)²`. -/
theorem mr_aux_gamma_lambda_pointwise {n d : ℕ} (hn : 0 < n) (hd : 0 < d) (X : Frame n d)
    (hX : IsEqualNorm X) (t : ℝ) (g : FrameVector n d) :
    frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) * conditionedNoise X g) ≤
      (d : ℝ) / n * ∑ i, (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 ∧
    frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X) ≤
      (d : ℝ) / n * ∑ i, (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 := by
  have ha : 0 < (d : ℝ) / n := by positivity
  set a := (d : ℝ) / n with ha_def
  set f : Fin n → FrameVector n d → ℝ := fun i g =>
    (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 with hf
  have hr0 (g : FrameVector n d) (i : Fin n) : 0 ≤ mrRatio X g i :=
    div_nonneg (rowNormSq_nonneg _ i) ha.le
  constructor
  · show frobSq (mrGamma a t (conditionedNoise X g) * conditionedNoise X g) ≤ a * ∑ i, f i g
    have hfrob : frobSq (mrGamma a t (conditionedNoise X g) * conditionedNoise X g) =
        ∑ i, (mrWeight a t (conditionedNoise X g) i - mrCbar t) ^ 2 *
          rowNormSq (conditionedNoise X g) i := by
      simp only [frobSq, mrGamma, Matrix.diagonal_mul, rowNormSq, mul_pow, Finset.mul_sum]
    rw [hfrob, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have hr := hr0 g i
    have hsc := (lem_remainder_scalar (mrRatio X g i) t hr).2.2.1
    have hrow : rowNormSq (conditionedNoise X g) i = a * mrRatio X g i := by
      simp only [mrRatio, ← ha_def]; field_simp
    rw [hrow]
    have h1 : (mrWeight a t (conditionedNoise X g) i - mrCbar t) ^ 2 ≤ (mrRatio X g i - 1) ^ 2 := by
      have := sq_le_sq' (abs_le.mp hsc).1 (abs_le.mp hsc).2
      rw [sq_abs] at this
      simpa only [mrWeight, mrCbar, tangentRatio, mrRatio] using this
    have h2 : mrRatio X g i ≤ (1 + mrRatio X g i) ^ 2 := by nlinarith
    calc (mrWeight a t (conditionedNoise X g) i - mrCbar t) ^ 2 * (a * mrRatio X g i)
        ≤ (mrRatio X g i - 1) ^ 2 * (a * (1 + mrRatio X g i) ^ 2) :=
          mul_le_mul h1 (mul_le_mul_of_nonneg_left h2 ha.le) (by positivity) (sq_nonneg _)
      _ = a * f i g := by simp only [hf]; ring
  · show frobSq (mrLambda a t (conditionedNoise X g) * X) ≤ a * ∑ i, f i g
    have hfrob : frobSq (mrLambda a t (conditionedNoise X g) * X) =
        ∑ i, (mrWeight a t (conditionedNoise X g) i * tangentRatio a (conditionedNoise X g) i -
          mrCbar t) ^ 2 * rowNormSq X i := by
      simp only [frobSq, mrLambda, Matrix.diagonal_mul, rowNormSq, mul_pow, Finset.mul_sum]
    rw [hfrob, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i _
    have hr := hr0 g i
    have hsc := (lem_remainder_scalar (mrRatio X g i) t hr).2.2.2.2
    rw [hX i]
    have h1 : (mrWeight a t (conditionedNoise X g) i * tangentRatio a (conditionedNoise X g) i -
        mrCbar t) ^ 2 ≤ ((mrRatio X g i - 1) * (1 + mrRatio X g i)) ^ 2 := by
      have hb := abs_le.mp hsc
      have := sq_le_sq' hb.1 hb.2
      have e : (|mrRatio X g i - 1| * (1 + mrRatio X g i)) ^ 2 =
          ((mrRatio X g i - 1) * (1 + mrRatio X g i)) ^ 2 := by
        rw [mul_pow, sq_abs, mul_pow]
      rw [e] at this
      simpa only [mrWeight, mrCbar, tangentRatio, mrRatio] using this
    calc _ ≤ ((mrRatio X g i - 1) * (1 + mrRatio X g i)) ^ 2 * a :=
          mul_le_mul_of_nonneg_right h1 ha.le
      _ = a * f i g := by simp only [hf]; ring

/-- Integrability of `‖ΓZ‖_F²` and `‖ΛX‖_F²` (not a paper item). -/
theorem mr_aux_gamma_lambda_integrable {n d : ℕ} (hn : 0 < n) (hd : 0 < d) (X : Frame n d)
    (hX : IsEqualNorm X) (t : ℝ) :
    Integrable (fun g => frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) *
      conditionedNoise X g)) (gaussFrame n d) ∧
    Integrable (fun g => frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X))
      (gaussFrame n d) := by
  have hfi (i : Fin n) := mr_aux_moment_integrable hn hd X hX i
  have hG : Integrable (fun g => (d : ℝ) / n * ∑ i, (mrRatio X g i - 1) ^ 2 *
      (1 + mrRatio X g i) ^ 2) (gaussFrame n d) :=
    (integrable_finsetSum _ fun i _ => hfi i).const_mul _
  have hcz (i : Fin n) (j : Fin d) : Continuous (fun g : FrameVector n d => conditionedNoise X g i j) := by
    have : (fun g : FrameVector n d => conditionedNoise X g i j) =
        fun g => (EuclideanSpace.proj (i, j) :
          FrameVector n d →L[ℝ] ℝ) ((Matrix.toEuclideanLin (tangentNoiseFactor X)).toContinuousLinearMap g) := rfl
    rw [this]
    fun_prop
  have hmz (i : Fin n) (j : Fin d) := (hcz i j).measurable
  constructor
  · refine hG.mono' ?_ (Filter.Eventually.of_forall fun g => ?_)
    · apply Measurable.aestronglyMeasurable
      simp only [frobSq, mrGamma, Matrix.diagonal_mul, mrWeight, mrCbar, tangentRatio, rowNormSq]
      fun_prop
    · rw [Real.norm_eq_abs, abs_of_nonneg (Finset.sum_nonneg fun i _ =>
        Finset.sum_nonneg fun j _ => sq_nonneg _)]
      exact (mr_aux_gamma_lambda_pointwise hn hd X hX t g).1
  · refine hG.mono' ?_ (Filter.Eventually.of_forall fun g => ?_)
    · apply Measurable.aestronglyMeasurable
      simp only [frobSq, mrLambda, Matrix.diagonal_mul, mrWeight, mrCbar, tangentRatio, rowNormSq]
      fun_prop
    · rw [Real.norm_eq_abs, abs_of_nonneg (Finset.sum_nonneg fun i _ =>
        Finset.sum_nonneg fun j _ => sq_nonneg _)]
      exact (mr_aux_gamma_lambda_pointwise hn hd X hX t g).2

/-- `lem:remainder`, moment bounds.

TeX: "and $\E\fro{\Gamma Z}^2\le\mathcal M$, $\E\fro{\Lambda X}^2\le\mathcal M$." -/
theorem lem_remainder_moments {n d : ℕ} (hn : 0 < n) (hd : 2 ≤ d) (X : Frame n d)
    (hX : IsEqualNorm X) {t : ℝ} (ht : 0 < t) (ht1 : t ≤ 1) :
    ∫ g, frobSq (mrGamma ((d : ℝ) / n) t (conditionedNoise X g) * conditionedNoise X g)
        ∂gaussFrame n d ≤ mrMoment X ∧
    ∫ g, frobSq (mrLambda ((d : ℝ) / n) t (conditionedNoise X g) * X) ∂gaussFrame n d ≤
      mrMoment X := by
  have hd0 : 0 < d := by omega
  have ha : 0 < (d : ℝ) / n := by positivity
  set a := (d : ℝ) / n with ha_def
  set f : Fin n → FrameVector n d → ℝ := fun i g =>
    (mrRatio X g i - 1) ^ 2 * (1 + mrRatio X g i) ^ 2 with hf
  have hfi (i : Fin n) : Integrable (f i) (gaussFrame n d) := mr_aux_moment_integrable hn hd0 X hX i
  have hG : Integrable (fun g => a * ∑ i, f i g) (gaussFrame n d) :=
    (integrable_finsetSum _ fun i _ => hfi i).const_mul a
  have hGint : ∫ g, a * ∑ i, f i g ∂gaussFrame n d = mrMoment X := by
    rw [integral_const_mul, integral_finsetSum _ fun i _ => hfi i]
    rfl
  have hr0 (g : FrameVector n d) (i : Fin n) : 0 ≤ mrRatio X g i :=
    div_nonneg (rowNormSq_nonneg _ i) ha.le
  constructor
  · rw [← hGint]
    apply integral_mono_of_nonneg (Filter.Eventually.of_forall fun g =>
      Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _) hG
    exact Filter.Eventually.of_forall fun g =>
      (mr_aux_gamma_lambda_pointwise hn hd0 X hX t g).1
  · rw [← hGint]
    apply integral_mono_of_nonneg (Filter.Eventually.of_forall fun g =>
      Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _) hG
    exact Filter.Eventually.of_forall fun g =>
      (mr_aux_gamma_lambda_pointwise hn hd0 X hX t g).2

/-- Remark after `lem:remainder` (the termwise bound).

TeX: "The termwise bound $\opn{R_3}\le2t^3\sum_ic_i\norm{x_i}\norm{z_i}\approx2t^3d$
would only allow $\eta\lesssim d^{-2}$." (the rigorous part: the termwise inequality.) -/
theorem rem_remainder_termwise {n d : ℕ} (X Z : Frame n d) {a t : ℝ} (ha : 0 < a)
    (ht : 0 < t) :
    opNorm (mrR3 X Z a t) ≤
      2 * t ^ 3 * ∑ i, mrWeight a t Z i * Real.sqrt (rowNormSq X i) *
        Real.sqrt (rowNormSq Z i) := by
  let O : Fin n → Matrix (Fin d) (Fin d) ℝ := fun i => Matrix.of fun j k => X i j * Z i k
  have hc0 (i : Fin n) : 0 ≤ mrWeight a t Z i := by
    unfold mrWeight
    exact div_nonneg (tangentRatio_nonneg a ha Z i) (tangent_denominator_pos a t ha Z i).le
  have hsum1 : X.transpose * Matrix.diagonal (mrWeight a t Z) * Z =
      ∑ i, mrWeight a t Z i • O i := by
    ext j k
    simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply, mul_ite,
      mul_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true, Matrix.sum_apply,
      Matrix.smul_apply, smul_eq_mul, Matrix.of_apply, O]
    apply Finset.sum_congr rfl; intro i _; ring
  have hsum2 : Z.transpose * Matrix.diagonal (mrWeight a t Z) * X =
      ∑ i, mrWeight a t Z i • (O i).transpose := by
    ext j k
    simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply, mul_ite,
      mul_zero, Finset.sum_ite_eq', Finset.mem_univ, if_true, Matrix.sum_apply,
      Matrix.smul_apply, smul_eq_mul, Matrix.of_apply, O]
    apply Finset.sum_congr rfl; intro i _; ring
  have hO (i : Fin n) : opNorm (O i) ≤ Real.sqrt (rowNormSq X i) * Real.sqrt (rowNormSq Z i) := by
    have hF : frobSq (O i) = rowNormSq X i * rowNormSq Z i := by
      simp only [frobSq, O, Matrix.of_apply, rowNormSq, mul_pow, Finset.sum_mul_sum]
    rw [← Real.sqrt_mul (rowNormSq_nonneg X i), ← hF]
    exact mrx_opNorm_le_sqrt_frobSq _
  unfold mrR3
  rw [hsum1, hsum2, mrx_opNorm_smul, abs_neg, abs_of_pos (by positivity)]
  have hb := mrx_opNorm_add_le (∑ i, mrWeight a t Z i • O i) (∑ i, mrWeight a t Z i • (O i).transpose)
  have hb1 := mrx_opNorm_sum_le Finset.univ (fun i => mrWeight a t Z i • O i)
  have hb2 := mrx_opNorm_sum_le Finset.univ (fun i => mrWeight a t Z i • (O i).transpose)
  have hterm (i : Fin n) : opNorm (mrWeight a t Z i • O i) + opNorm (mrWeight a t Z i • (O i).transpose) ≤
      2 * (mrWeight a t Z i * Real.sqrt (rowNormSq X i) * Real.sqrt (rowNormSq Z i)) := by
    rw [mrx_opNorm_smul, mrx_opNorm_smul, mrx_opNorm_transpose, abs_of_nonneg (hc0 i)]
    have := mul_le_mul_of_nonneg_left (hO i) (hc0 i)
    linarith
  have hsumt := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hterm i)
  rw [Finset.sum_add_distrib, ← Finset.mul_sum] at hsumt
  have : opNorm (∑ i, mrWeight a t Z i • O i + ∑ i, mrWeight a t Z i • (O i).transpose) ≤
      2 * ∑ i, mrWeight a t Z i * Real.sqrt (rowNormSq X i) * Real.sqrt (rowNormSq Z i) := by
    linarith
  calc t ^ 3 * opNorm _ ≤ t ^ 3 * (2 * ∑ i, mrWeight a t Z i * Real.sqrt (rowNormSq X i) *
        Real.sqrt (rowNormSq Z i)) := mul_le_mul_of_nonneg_left this (by positivity)
    _ = _ := by ring

/-! ## 4.3 A dense reference graph -/

/-- The conclusion of `lem:mr-dense` for given constants `h, t₀, c₁`. -/
def MrDenseConclusion (h t₀ c₁ : ℝ) : Prop :=
  ∀ (n d : ℕ) (X : Frame n d), 2 ≤ d → IsEqualNorm X → ∀ t : ℝ, 0 < t → t ≤ t₀ →
    1 - (n : ℝ) * Real.exp (-c₁ * ((n : ℝ) - 1)) ≤
      (gaussFrame n d).real {g | ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
        ((Finset.univ.filter (fun j => j ≠ i ∧
          h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
            |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)}

/-- Proof of `lem:mr-dense`: the per-pair failure estimates (explicit constants).

TeX: "By Markov, $\Prob(N_j>2)\le t^2/3$. [...] If $|u_j|\le\frac12$
the variance is at least $3t^2/(4d)$ and the Gaussian density bound gives
probability at most $4h/\sqrt{3\pi/2}\le3h$. If $|u_j|>\frac12$ and $2ht\le\frac14$,
failure requires $\frac t{\sqrt d}|\ip f{g'_j}|>\frac14$, of probability at most
$16t^2/d$. [...] (this also gives $2ht\le\frac14$, and $16t^2/d\le8t^2$ as $d\ge2$)."

Stated for a scalar Gaussian `ν ∼ N(u, s²)` and the elementary inequalities. -/
theorem lem_mr_dense_pair {h t : ℝ} {d : ℕ} (hd : 2 ≤ d) (hh : 0 < h) (ht : 0 < t)
    (ht1 : t ≤ 1) (u : ℝ) (s : NNReal) (hs : 3 * t ^ 2 / (4 * d) ≤ (s : ℝ)) :
    (gaussianReal u s).real {x | |x| < 2 * h * t / Real.sqrt d} ≤
      4 * h / Real.sqrt (3 * Real.pi / 2) ∧
    4 * h / Real.sqrt (3 * Real.pi / 2) ≤ 3 * h ∧
    16 * t ^ 2 / d ≤ 8 * t ^ 2 ∧
    (3 * h + t ^ 2 / 3 + 8 * t ^ 2 ≤ 1 / 50 → 2 * h * t ≤ 1 / 4) := by
  have hdR : (2 : ℝ) ≤ d := by exact_mod_cast hd
  have hsd : 0 < Real.sqrt d := Real.sqrt_pos.mpr (by linarith)
  have hs0 : 0 < (s : ℝ) := lt_of_lt_of_le (by positivity) hs
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- the Gaussian density is at most `1/√(2πs)`
    set r := 2 * h * t / Real.sqrt d with hr
    have hr0 : 0 ≤ r := by positivity
    have hsne : s ≠ 0 := by intro h0; rw [h0] at hs0; simp at hs0
    have hset : {x : ℝ | |x| < r} = Set.Ioo (-r) r := by ext x; simp [abs_lt]
    have hc : ∀ x, gaussianPDF u s x ≤ ENNReal.ofReal (Real.sqrt (2 * Real.pi * s))⁻¹ := by
      intro x
      apply ENNReal.ofReal_le_ofReal
      rw [gaussianPDFReal_def]
      have h1 : Real.exp (-(x - u) ^ 2 / (2 * s)) ≤ 1 := by
        rw [Real.exp_le_one_iff]
        have : 0 ≤ (x - u) ^ 2 / (2 * s) := by positivity
        linarith [neg_div (2 * (s : ℝ)) ((x - u) ^ 2)]
      have h2 : 0 ≤ (Real.sqrt (2 * Real.pi * s))⁻¹ := by positivity
      nlinarith
    have hmeas : gaussianReal u s {x | |x| < r} ≤
        ENNReal.ofReal (2 * r / Real.sqrt (2 * Real.pi * s)) := by
      rw [gaussianReal_apply u hsne, hset]
      calc ∫⁻ x in Set.Ioo (-r) r, gaussianPDF u s x
          ≤ ∫⁻ x in Set.Ioo (-r) r, ENNReal.ofReal (Real.sqrt (2 * Real.pi * s))⁻¹ :=
            lintegral_mono fun x => hc x
        _ = ENNReal.ofReal (Real.sqrt (2 * Real.pi * s))⁻¹ * volume (Set.Ioo (-r) r) :=
            MeasureTheory.setLIntegral_const _ _
        _ = ENNReal.ofReal (2 * r / Real.sqrt (2 * Real.pi * s)) := by
            rw [Real.volume_Ioo, ← ENNReal.ofReal_mul (by positivity)]
            congr 1; ring
    refine (ENNReal.toReal_le_of_le_ofReal (by positivity) hmeas).trans ?_
    have hlow : Real.sqrt (3 * Real.pi / 2) * t / Real.sqrt d ≤ Real.sqrt (2 * Real.pi * s) := by
      have e : Real.sqrt (3 * Real.pi / 2) * t / Real.sqrt d =
          Real.sqrt (2 * Real.pi * (3 * t ^ 2 / (4 * d))) := by
        rw [show 2 * Real.pi * (3 * t ^ 2 / (4 * d)) = 3 * Real.pi / 2 * (t / Real.sqrt d) ^ 2 by
          rw [div_pow, Real.sq_sqrt (by linarith)]; ring]
        rw [Real.sqrt_mul (by positivity), Real.sqrt_sq (by positivity)]
        ring
      rw [e]
      exact Real.sqrt_le_sqrt (by nlinarith [Real.pi_pos])
    have hpos : 0 < Real.sqrt (3 * Real.pi / 2) * t / Real.sqrt d := by
      have : 0 < Real.sqrt (3 * Real.pi / 2) := Real.sqrt_pos.mpr (by positivity)
      positivity
    calc 2 * r / Real.sqrt (2 * Real.pi * s) ≤ 2 * r / (Real.sqrt (3 * Real.pi / 2) * t /
          Real.sqrt d) := div_le_div_of_nonneg_left (by positivity) hpos hlow
      _ = 4 * h / Real.sqrt (3 * Real.pi / 2) := by
          rw [hr]; field_simp; ring
  · have hsq : 4 / 3 ≤ Real.sqrt (3 * Real.pi / 2) := by
      apply Real.le_sqrt_of_sq_le
      have := Real.two_le_pi
      nlinarith
    have hpos : 0 < Real.sqrt (3 * Real.pi / 2) := by linarith
    rw [div_le_iff₀ hpos]
    nlinarith
  · rw [div_le_iff₀ (by linarith)]
    nlinarith [sq_nonneg t]
  · intro hsum
    have hh150 : h ≤ 1 / 150 := by nlinarith [sq_nonneg t]
    nlinarith

/-- Proof of `lem:mr-dense`: the per-pair failure bound `≤ 1/50` (conditionally on row `i`).

TeX: "By Markov, $\Prob(N_j>2)\le t^2/3$. On $\{N_j\le2\}$ failure requires
$|\nu_j|<2ht/\sqrt d$. [...] Choose $h$ and $t_0$ so that $3h+t_0^2/3+8t_0^2\le\frac1{50}$"
(`f = v_{0,i}/√a` is the unit direction of row `i`, `e = e_j`). -/
theorem mr_aux_pair_fail {h t : ℝ} {d : ℕ} (hd : 2 ≤ d) (hh : 0 < h) (ht : 0 < t)
    (ht1 : t ≤ 1) (hsum : 3 * h + t ^ 2 / 3 + 8 * t ^ 2 ≤ 1 / 50)
    (e f : EuclideanSpace ℝ (Fin d)) (he : ‖e‖ = 1) (hf : ‖f‖ = 1) :
    (stdGaussian (EuclideanSpace ℝ (Fin d))).real
      {z | |inner ℝ f (independentTangentDirection e t z)| < h * t / Real.sqrt d} ≤ 1 / 50 := by
  have hd0 : 0 < d := by omega
  have hdR : (2 : ℝ) ≤ d := by exact_mod_cast hd
  have hsd : 0 < Real.sqrt d := Real.sqrt_pos.mpr (by linarith)
  set μ := stdGaussian (EuclideanSpace ℝ (Fin d))
  set σ := t / Real.sqrt d with hσ
  set m := inner ℝ f e with hm
  set D : StrongDual ℝ (EuclideanSpace ℝ (Fin d)) := σ • innerSL ℝ (f - m • e) with hD
  set R : EuclideanSpace ℝ (Fin d) → ℝ := fun z =>
    σ ^ 2 * ‖independentTangentProjection e z‖ ^ 2 with hR
  set w := h * t / Real.sqrt d with hw
  have hw0 : 0 < w := by positivity
  have hDnorm : ‖D‖ ^ 2 = σ ^ 2 * (1 - m ^ 2) := tangent_numerator_variance e f he hf σ
  have hσ2 : σ ^ 2 = t ^ 2 / d := by rw [hσ, div_pow, Real.sq_sqrt (by linarith)]
  -- `{|⟨f,u⟩| < w} ⊆ {R ≥ 3} ∪ {|m + Dz| < 2w}`
  have hsub : {z | |inner ℝ f (independentTangentDirection e t z)| < w} ⊆
      {z | 3 ≤ R z} ∪ {z | |m + D z| < 2 * w} := by
    intro z hz
    simp only [Set.mem_setOf_eq] at hz
    rw [independentTangentDirection_inner e f he t z] at hz
    by_cases hl : 3 ≤ R z
    · exact Or.inl hl
    · right
      push Not at hl
      simp only [Set.mem_setOf_eq]
      have hR0 : 0 ≤ R z := by simp only [hR]; positivity
      have hden : 0 < Real.sqrt (1 + R z) := Real.sqrt_pos.mpr (by linarith)
      have hden2 : Real.sqrt (1 + R z) < 2 := by
        rw [Real.sqrt_lt' (by norm_num)]; linarith
      rw [abs_div, abs_of_pos hden, div_lt_iff₀ hden] at hz
      have : |m + D z| = |inner ℝ f e + ((t / Real.sqrt d) • innerSL ℝ (f - (inner ℝ f e) • e)) z| :=
        rfl
      rw [this]
      nlinarith [abs_nonneg (inner ℝ f e + ((t / Real.sqrt d) • innerSL ℝ (f - (inner ℝ f e) • e)) z)]
  -- Markov for the normalisation
  have hRint : Integrable R μ := independentTangentProjection_integrable_norm_sq e t
  have hRmean : ∫ z, R z ∂μ ≤ t ^ 2 := independentTangentProjection_mean_norm_sq_le hd0 e t
  have hR3 : μ.real {z | 3 ≤ R z} ≤ t ^ 2 / 3 := by
    have hmk := mul_meas_ge_le_integral_of_nonneg
      (ae_of_all _ fun z => (by simp only [hR]; positivity : 0 ≤ R z)) hRint 3
    rw [le_div_iff₀ (by norm_num)]
    linarith
  -- the numerator
  have hnum : μ.real {z | |m + D z| < 2 * w} ≤ 3 * h + 8 * t ^ 2 := by
    have hpair := lem_mr_dense_pair (h := h) (t := t) hd hh ht ht1
    by_cases hm2 : |m| ≤ 1 / 2
    · -- density bound
      have hm2' : m ^ 2 ≤ 1 / 4 := by nlinarith [sq_abs m, abs_nonneg m]
      set v : NNReal := (‖D‖ ^ 2).toNNReal with hv
      have hvv : (v : ℝ) = ‖D‖ ^ 2 := Real.coe_toNNReal _ (sq_nonneg _)
      have hvlow : 3 * t ^ 2 / (4 * d) ≤ (v : ℝ) := by
        rw [hvv, hDnorm, hσ2]
        rw [div_mul_eq_mul_div, div_le_div_iff₀ (by positivity) (by positivity)]
        have := mul_le_mul_of_nonneg_left (show 3 / 4 ≤ 1 - m ^ 2 by linarith)
          (show 0 ≤ t ^ 2 * (4 * d) by positivity)
        nlinarith
      obtain ⟨h1, h2, -, -⟩ := hpair m v hvlow
      have hlaw := (hasLaw_dual_stdGaussian D).map_eq
      have hmap : μ.map (fun z => m + D z) = gaussianReal m v := by
        have : (fun z => m + D z) = (fun x => m + x) ∘ D := rfl
        rw [this, ← Measure.map_map (by fun_prop) D.continuous.measurable, hlaw,
          gaussianReal_map_const_add, zero_add]
      have hset : {z | |m + D z| < 2 * w} = (fun z => m + D z) ⁻¹' {x : ℝ | |x| < 2 * h * t / Real.sqrt d} := by
        ext z; simp only [Set.mem_setOf_eq, Set.mem_preimage, hw]; ring_nf
      rw [hset, ← map_measureReal_apply (by fun_prop)
        (measurableSet_lt (by fun_prop) measurable_const), hmap]
      nlinarith [sq_nonneg t]
    · -- second-moment bound
      push Not at hm2
      set s0 : NNReal := (3 * t ^ 2 / (4 * d)).toNNReal
      have hs0 : 3 * t ^ 2 / (4 * d) ≤ (s0 : ℝ) := (Real.coe_toNNReal _ (by positivity)).symm.le
      obtain ⟨-, -, h3, h4⟩ := hpair 0 s0 hs0
      have h24 := h4 hsum
      have hq : 2 * w ≤ 1 / 4 := by
        have hsd1 : 1 ≤ Real.sqrt d := by
          rw [Real.le_sqrt (by norm_num) (by linarith)]; linarith
        have : 2 * w ≤ 2 * h * t := by
          rw [hw, ← mul_div_assoc, ← mul_assoc]
          exact div_le_self (by positivity) hsd1
        linarith
      have hsmall := affineGaussian_small_ball_of_large_mean D hm2.le hq
      have hsub2 : {z | |m + D z| < 2 * w} ⊆ {z | |m + D z| ≤ 2 * w} :=
        fun z (hz : |m + D z| < 2 * w) => (le_of_lt hz : |m + D z| ≤ 2 * w)
      have hD16 : 16 * ‖D‖ ^ 2 ≤ 16 * t ^ 2 / d := by
        rw [hDnorm, hσ2, show (16 : ℝ) * t ^ 2 / d = 16 * (t ^ 2 / d) by ring]
        have : 0 ≤ t ^ 2 / d * m ^ 2 := by positivity
        nlinarith
      calc μ.real {z | |m + D z| < 2 * w} ≤ μ.real {z | |m + D z| ≤ 2 * w} :=
            measureReal_mono hsub2
        _ ≤ 16 * ‖D‖ ^ 2 := hsmall
        _ ≤ 16 * t ^ 2 / d := hD16
        _ ≤ 8 * t ^ 2 := h3
        _ ≤ 3 * h + 8 * t ^ 2 := by linarith
  calc μ.real {z | |inner ℝ f (independentTangentDirection e t z)| < h * t / Real.sqrt d}
      ≤ μ.real ({z | 3 ≤ R z} ∪ {z | |m + D z| < 2 * w}) := measureReal_mono hsub
    _ ≤ μ.real {z | 3 ≤ R z} + μ.real {z | |m + D z| < 2 * w} := measureReal_union_le _ _
    _ ≤ t ^ 2 / 3 + (3 * h + 8 * t ^ 2) := add_le_add hR3 hnum
    _ ≤ 1 / 50 := by linarith

/-- Proof of `lem:mr-dense`, with its explicit constant recipe.

TeX: "Choose $h$ and $t_0$ so that $3h+t_0^2/3+8t_0^2\le\frac1{50}$ [...] more than
$0.1(n-1)$ failures have probability at most
$\exp(-(n-1)[0.1-\frac{e-1}{50}])\le e^{-c_1(n-1)}$." -/
theorem lem_mr_dense_explicit {h t₀ : ℝ} (hh : 0 < h) (hh1 : h ≤ 1) (ht₀ : 0 < t₀)
    (ht₀1 : t₀ ≤ 1) (hsum : 3 * h + t₀ ^ 2 / 3 + 8 * t₀ ^ 2 ≤ 1 / 50) :
    0 < 1 / 10 - (Real.exp 1 - 1) / 50 ∧
    MrDenseConclusion h t₀ (1 / 10 - (Real.exp 1 - 1) / 50) := by
  have he3 := Real.exp_one_lt_d9
  refine ⟨by norm_num at he3 ⊢; linarith, ?_⟩
  intro n d X hd hX t ht htt₀
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn
    have : {g : FrameVector 0 d | ∀ i : Fin 0, 9 / 10 * (((0 : ℕ) : ℝ) - 1) ≤
        ((Finset.univ.filter (fun j => j ≠ i ∧
          h * t * Real.sqrt (((d : ℝ) / (0 : ℕ)) / (0 : ℕ)) ≤
            |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)} =
        Set.univ := by
      ext g; simp
    rw [this, probReal_univ]
    simp
  have hd0 : 0 < d := by omega
  have ht1 : t ≤ 1 := htt₀.trans ht₀1
  have hsum' : 3 * h + t ^ 2 / 3 + 8 * t ^ 2 ≤ 1 / 50 := by
    have : t ^ 2 ≤ t₀ ^ 2 := pow_le_pow_left₀ ht.le htt₀ 2
    linarith
  have hfail := mrx_dense_failure_le X hn hd0 hX ht hh (by norm_num : (0 : ℝ) ≤ 1 / 50)
    (fun e' f he' hf => mr_aux_pair_fail hd hh ht ht1 hsum' e' f he' hf)
  set G := {g : FrameVector n d | ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
    ((Finset.univ.filter (fun j => j ≠ i ∧
      h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
        |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)}
  have hcompl : {g : FrameVector n d | ¬ ∀ i : Fin n, 9 / 10 * ((n : ℝ) - 1) ≤
      ((Finset.univ.filter (fun j => j ≠ i ∧
        h * t * Real.sqrt (((d : ℝ) / n) / n) ≤
          |(rowIndependentSeed X t g * (rowIndependentSeed X t g).transpose) i j|)).card : ℝ)} = Gᶜ :=
    rfl
  rw [hcompl] at hfail
  have hu : (1 : ℝ) ≤ (gaussFrame n d).real G + (gaussFrame n d).real Gᶜ := by
    have h1 := measureReal_union_le (μ := gaussFrame n d) G Gᶜ
    rw [Set.union_compl_self, probReal_univ] at h1
    exact h1
  have e : -(1 / 10 - (Real.exp 1 - 1) * (1 / 50)) = -(1 / 10 - (Real.exp 1 - 1) / 50) := by ring
  rw [e] at hfail
  linarith

/-- `lem:mr-dense`.

TeX: "There are absolute $h,t_0\in(0,1]$ and $c_1>0$ such that for $d\ge2$ and
$t\le t_0$, with probability at least $1-ne^{-c_1(n-1)}$, every $i$ has at least $0.9(n-1)$
indices $j\ne i$ with \[ |\ip{v_{0,i}}{v_{0,j}}|\ge h\,t\sqrt{a/n}. \]"

(`V₀ = rowIndependentSeed X t g = tangentSeed X Z₀ a t`; `⟨v_{0,i}, v_{0,j}⟩ = (V₀V₀ᵀ)_{ij}`.) -/
theorem lem_mr_dense :
    ∃ h t₀ c₁ : ℝ, 0 < h ∧ h ≤ 1 ∧ 0 < t₀ ∧ t₀ ≤ 1 ∧ 0 < c₁ ∧ MrDenseConclusion h t₀ c₁ := by
  obtain ⟨hc, hD⟩ := lem_mr_dense_explicit (h := 1 / 300) (t₀ := 1 / 30) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  exact ⟨1 / 300, 1 / 30, _, by norm_num, by norm_num, by norm_num, by norm_num, hc, hD⟩

end

end Paulsen.Paper
