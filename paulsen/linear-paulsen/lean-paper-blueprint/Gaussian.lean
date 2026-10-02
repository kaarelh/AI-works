import Paulsen.Paper.Toolbox
import Paulsen.GaussianQuadraticForm
import Paulsen.GaussianLinearImage
import Paulsen.GaussianRotationConcentration
import Paulsen.GaussianOperatorNet
import Paulsen.GaussianMatrixTail
import Paulsen.GaussianRowMoments

/-!
# Paper blueprint, Appendix A: Gaussian tools (`sections/gaussian.tex`)

Gaussian vectors are `g ∼ stdGaussian (EuclideanSpace ℝ κ)`; a correlated Gaussian vector
is `C g` (`Matrix.toEuclideanLin C g`) with covariance `C Cᵀ`; `Cov ⪯ σ² I` is
`‖C‖_op² ≤ σ²`.  Probabilities are `(stdGaussian _).real {g | …}`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-! ### Auxiliary estimates for the proof of `lem:gauss` (a) -/

/-- `log(1-u) ≥ -u - u²` for `|u| ≤ 1/2`, i.e. `-x - ½log(1-2x) ≤ 2x²` for `|x| ≤ 1/4`. -/
theorem gauss_aux_log_lower (u : ℝ) (hu1 : -(1 / 2) ≤ u) (hu2 : u ≤ 1 / 2) :
    -u - u ^ 2 ≤ Real.log (1 - u) := by
  rcases le_or_gt u 0 with hu | hu
  · have hden : 0 < 1 - u := by linarith
    have hlog := Real.one_sub_inv_le_log_of_pos hden
    have hkey : -u - u ^ 2 ≤ 1 - (1 - u)⁻¹ := by
      rw [show 1 - (1 - u)⁻¹ = -u / (1 - u) by field_simp; ring]
      rw [le_div_iff₀ hden]
      nlinarith [sq_nonneg u, mul_nonneg (sq_nonneg u) (neg_nonneg.mpr hu)]
    linarith
  · have habs : |u| < 1 := by rw [abs_of_pos hu]; linarith
    have h := Real.abs_log_sub_add_sum_range_le habs 4
    simp only [Finset.sum_range_succ, Finset.sum_range_zero, abs_of_pos hu] at h
    have hden : 0 < 1 - u := by linarith
    have hrem : u ^ (4 + 1) / (1 - u) ≤ 2 * u ^ 5 := by
      rw [div_le_iff₀ hden]
      have : 0 ≤ u ^ 5 := by positivity
      norm_num
      nlinarith
    have h' := (abs_le.mp h).1
    norm_num at h'
    have hu3 : u ^ 3 ≤ u ^ 2 / 2 := by nlinarith [sq_nonneg u]
    have hu4 : u ^ 4 ≤ u ^ 2 / 4 := by nlinarith [sq_nonneg u, pow_pos hu 3]
    have hu5 : u ^ 5 ≤ u ^ 2 / 8 := by nlinarith [sq_nonneg u, pow_pos hu 4]
    nlinarith

/-- The sharp MGF bound of `lem:gauss` (a):
`log E e^{s(gᵀAg - tr A)} ≤ 2 s² ‖A‖_F²` for `|s| ‖A‖ ≤ 1/4`. -/
theorem gauss_aux_mgf_le {κ : Type*} [Fintype κ] [DecidableEq κ] (A : Matrix κ κ ℝ)
    (hA : A.IsHermitian) (s : ℝ) (hs : |s| * opNorm A ≤ 1 / 4) :
    (∀ i, 0 < 1 - 2 * s * hA.eigenvalues i) ∧
    mgf (fun g : EuclideanSpace ℝ κ => euclideanQuadratic A g - A.trace)
      (stdGaussian (EuclideanSpace ℝ κ)) s ≤ Real.exp (2 * s ^ 2 * frobSq A) := by
  have heig (i : κ) : |s * hA.eigenvalues i| ≤ 1 / 4 := by
    rw [abs_mul]
    exact (mul_le_mul_of_nonneg_left (abs_eigenvalue_le_euclidean_operator_norm A hA i)
      (abs_nonneg s)).trans hs
  have hpos (i : κ) : 0 < 1 - 2 * s * hA.eigenvalues i := by
    have := (abs_le.mp (heig i)).2
    nlinarith
  refine ⟨hpos, ?_⟩
  rw [mgf_euclideanQuadratic_stdGaussian A hA s hpos]
  have hfac (i : κ) : Real.exp (-s * hA.eigenvalues i) /
      Real.sqrt (1 - 2 * s * hA.eigenvalues i) ≤
        Real.exp (2 * s ^ 2 * hA.eigenvalues i ^ 2) := by
    have hw := hpos i
    have hsq : 0 < Real.sqrt (1 - 2 * s * hA.eigenvalues i) := Real.sqrt_pos.mpr hw
    rw [div_le_iff₀ hsq]
    have hlog := gauss_aux_log_lower (2 * s * hA.eigenvalues i)
      (by have := (abs_le.mp (heig i)).1; nlinarith)
      (by have := (abs_le.mp (heig i)).2; nlinarith)
    have hsqrt : Real.sqrt (1 - 2 * s * hA.eigenvalues i) =
        Real.exp (Real.log (1 - 2 * s * hA.eigenvalues i) / 2) := by
      rw [← Real.log_sqrt hw.le, Real.exp_log hsq]
    rw [hsqrt, ← Real.exp_add, Real.exp_le_exp]
    nlinarith
  calc
    _ ≤ ∏ i, Real.exp (2 * s ^ 2 * hA.eigenvalues i ^ 2) :=
      Finset.prod_le_prod (fun i _ => div_nonneg (Real.exp_pos _).le (Real.sqrt_nonneg _))
        (fun i _ => hfac i)
    _ = Real.exp (2 * s ^ 2 * frobSq A) := by
      rw [← Real.exp_sum, ← Finset.mul_sum, eigenvalues_sq_sum_eq_entry_sq_sum A hA]
      rfl

/-- One-sided Chernoff step of `lem:gauss` (a). -/
theorem gauss_aux_one_sided {κ : Type*} [Fintype κ] [DecidableEq κ] (A : Matrix κ κ ℝ)
    (hA : A.IsHermitian) (u s : ℝ) (hs0 : 0 ≤ s) (hs : s * opNorm A ≤ 1 / 4) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u ≤ euclideanQuadratic A g - A.trace} ≤
      Real.exp (-s * u + 2 * s ^ 2 * frobSq A) ∧
    (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u ≤ -(euclideanQuadratic A g - A.trace)} ≤
      Real.exp (-s * u + 2 * s ^ 2 * frobSq A) := by
  constructor
  · have hs' : |s| * opNorm A ≤ 1 / 4 := by rwa [abs_of_nonneg hs0]
    obtain ⟨hpos, hm⟩ := gauss_aux_mgf_le A hA s hs'
    have hint := integrable_exp_euclideanQuadratic_stdGaussian A hA s hpos
    have h := measure_ge_le_exp_mul_mgf (X := fun g : EuclideanSpace ℝ κ =>
      euclideanQuadratic A g - A.trace) u hs0 hint
    calc _ ≤ _ := h
      _ ≤ Real.exp (-s * u) * Real.exp (2 * s ^ 2 * frobSq A) :=
        mul_le_mul_of_nonneg_left hm (Real.exp_pos _).le
      _ = _ := by rw [← Real.exp_add]
  · have hs' : |-s| * opNorm A ≤ 1 / 4 := by rwa [abs_neg, abs_of_nonneg hs0]
    obtain ⟨hpos, hm⟩ := gauss_aux_mgf_le A hA (-s) hs'
    have hint := integrable_exp_euclideanQuadratic_stdGaussian A hA (-s) hpos
    have hint' : Integrable (fun g : EuclideanSpace ℝ κ =>
        Real.exp (s * (-(euclideanQuadratic A g - A.trace))))
        (stdGaussian (EuclideanSpace ℝ κ)) := by
      refine hint.congr (Filter.Eventually.of_forall fun g => ?_)
      simp only; ring_nf
    have h := measure_ge_le_exp_mul_mgf (X := fun g : EuclideanSpace ℝ κ =>
      -(euclideanQuadratic A g - A.trace)) u hs0 hint'
    have hmgf : mgf (fun g : EuclideanSpace ℝ κ => -(euclideanQuadratic A g - A.trace))
        (stdGaussian (EuclideanSpace ℝ κ)) s =
        mgf (fun g : EuclideanSpace ℝ κ => euclideanQuadratic A g - A.trace)
        (stdGaussian (EuclideanSpace ℝ κ)) (-s) := by
      unfold mgf
      congr 1
      funext g
      ring_nf
    rw [hmgf] at h
    have hF : (-s) ^ 2 = s ^ 2 := by ring
    rw [hF] at hm
    calc _ ≤ _ := h
      _ ≤ Real.exp (-s * u) * Real.exp (2 * s ^ 2 * frobSq A) :=
        mul_le_mul_of_nonneg_left hm (Real.exp_pos _).le
      _ = _ := by rw [← Real.exp_add]

/-- `|λ|² ≤ ‖A‖_F²` makes `‖A‖_op > 0` when `‖A‖_F > 0`. -/
theorem gauss_aux_opNorm_pos {κ : Type*} [Fintype κ] [DecidableEq κ] (A : Matrix κ κ ℝ)
    (hA : A.IsHermitian) (hF : 0 < frobSq A) : 0 < opNorm A := by
  by_contra hle
  push Not at hle
  have h0 : ∀ i, hA.eigenvalues i = 0 := by
    intro i
    have := (abs_eigenvalue_le_euclidean_operator_norm A hA i).trans hle
    exact abs_nonpos_iff.mp this
  have hsum := eigenvalues_sq_sum_eq_entry_sq_sum A hA
  simp only [h0, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow,
    Finset.sum_const_zero] at hsum
  have : frobSq A = 0 := hsum.symm
  linarith

/-- `lem:gauss` (a), quadratic forms.

TeX: "\emph{(Quadratic forms.)} For $g$ standard Gaussian and $\mathsf A$
symmetric, $\Var(g^T\mathsf Ag)=2\fro{\mathsf A}^2$ and
\[ \Prob\{|g^T\mathsf Ag-\tr\mathsf A|>u\}\le2\exp\Bigl[-\tfrac18\min\Bigl\{\frac{u^2}{\fro{\mathsf A}^2},\frac u{\opn{\mathsf A}}\Bigr\}\Bigr]. \]" -/
theorem lem_gauss_a {κ : Type*} [Fintype κ] [DecidableEq κ] (A : Matrix κ κ ℝ)
    (hA : A.IsHermitian) (u : ℝ) :
    variance (fun g => euclideanQuadratic A g) (stdGaussian (EuclideanSpace ℝ κ)) =
      2 * frobSq A ∧
    (stdGaussian (EuclideanSpace ℝ κ)).real {g | u < |euclideanQuadratic A g - A.trace|} ≤
      2 * Real.exp (-(1 / 8) * min (u ^ 2 / frobSq A) (u / opNorm A)) := by
  set μ := stdGaussian (EuclideanSpace ℝ κ)
  constructor
  · have hm : AEStronglyMeasurable (fun g : EuclideanSpace ℝ κ => euclideanQuadratic A g) μ := by
      apply Continuous.aestronglyMeasurable
      unfold euclideanQuadratic
      fun_prop
    rw [← variance_sub_const hm A.trace, variance_euclideanQuadratic_stdGaussian A hA]
    rfl
  set F := frobSq A
  set N := opNorm A
  have hF0 : 0 ≤ F := Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _
  have hN0 : 0 ≤ N := norm_nonneg _
  -- degenerate cases: the right-hand side is at least `2`
  by_cases hdeg : u ≤ 0 ∨ F = 0
  · have hmin : min (u ^ 2 / F) (u / N) ≤ 0 := by
      rcases hdeg with hu | hF
      · exact (min_le_right _ _).trans (div_nonpos_of_nonpos_of_nonneg hu hN0)
      · exact (min_le_left _ _).trans (by rw [hF, div_zero])
    have hexp : 1 ≤ Real.exp (-(1 / 8) * min (u ^ 2 / F) (u / N)) :=
      Real.one_le_exp (by nlinarith)
    have h1 : μ.real {g | u < |euclideanQuadratic A g - A.trace|} ≤ 1 := measureReal_le_one
    linarith
  push Not at hdeg
  obtain ⟨hu, hF⟩ := hdeg
  have hFpos : 0 < F := lt_of_le_of_ne hF0 (Ne.symm hF)
  have hNpos : 0 < N := gauss_aux_opNorm_pos A hA hFpos
  set s := min (u / (4 * F)) (1 / (4 * N)) with hsdef
  have hs0 : 0 ≤ s := le_min (by positivity) (by positivity)
  have hsN : s * N ≤ 1 / 4 := by
    have := mul_le_mul_of_nonneg_right (min_le_right (u / (4 * F)) (1 / (4 * N))) hN0
    rw [← hsdef] at this
    calc s * N ≤ 1 / (4 * N) * N := this
      _ = 1 / 4 := by field_simp
  have hexpo : -s * u + 2 * s ^ 2 * F ≤ -(1 / 8) * min (u ^ 2 / F) (u / N) := by
    rcases le_total (u / (4 * F)) (1 / (4 * N)) with hcase | hcase
    · have hs : s = u / (4 * F) := min_eq_left hcase
      have hval : -s * u + 2 * s ^ 2 * F = -(1 / 8) * (u ^ 2 / F) := by
        rw [hs]; field_simp; ring
      rw [hval]
      have := min_le_left (u ^ 2 / F) (u / N)
      nlinarith
    · have hs : s = 1 / (4 * N) := min_eq_right hcase
      have hFu : F ≤ u * N := by
        rw [div_le_div_iff₀ (by positivity) (by positivity)] at hcase
        nlinarith
      have hval : -s * u + 2 * s ^ 2 * F ≤ -(1 / 8) * (u / N) := by
        rw [hs]
        have : 2 * (1 / (4 * N)) ^ 2 * F ≤ 2 * (1 / (4 * N)) ^ 2 * (u * N) :=
          mul_le_mul_of_nonneg_left hFu (by positivity)
        have heq : -(1 / (4 * N)) * u + 2 * (1 / (4 * N)) ^ 2 * (u * N) =
            -(1 / 8) * (u / N) := by field_simp; ring
        linarith
      have := min_le_right (u ^ 2 / F) (u / N)
      nlinarith
  obtain ⟨h1, h2⟩ := gauss_aux_one_sided A hA u s hs0 hsN
  have hsub : {g : EuclideanSpace ℝ κ | u < |euclideanQuadratic A g - A.trace|} ⊆
      {g | u ≤ euclideanQuadratic A g - A.trace} ∪
        {g | u ≤ -(euclideanQuadratic A g - A.trace)} := by
    intro g hg
    simp only [Set.mem_setOf_eq] at hg
    rcases le_or_gt 0 (euclideanQuadratic A g - A.trace) with h | h
    · left; simp only [Set.mem_setOf_eq]; rw [abs_of_nonneg h] at hg; linarith
    · right; simp only [Set.mem_setOf_eq]; rw [abs_of_neg h] at hg; linarith
  calc _ ≤ μ.real ({g | u ≤ euclideanQuadratic A g - A.trace} ∪
        {g | u ≤ -(euclideanQuadratic A g - A.trace)}) := measureReal_mono hsub
    _ ≤ _ := measureReal_union_le _ _
    _ ≤ Real.exp (-s * u + 2 * s ^ 2 * F) + Real.exp (-s * u + 2 * s ^ 2 * F) :=
      add_le_add h1 h2
    _ ≤ _ := by
      have := Real.exp_le_exp.mpr hexpo
      linarith

/-- `lem:gauss` (a), correlated version.

TeX: "For a Gaussian vector $\zeta=\Sigma^{1/2}g$, apply this to
$\Sigma^{1/2}\mathsf A\Sigma^{1/2}$, whose norms are at most $\opn\Sigma$ times those of
$\mathsf A$."

Encoding: `ζ = C g` with `Σ = C Cᵀ`; then `ζᵀAζ = gᵀ(CᵀAC)g`, and `CᵀAC` plays the role of
`Σ^{1/2}AΣ^{1/2}`. -/
theorem lem_gauss_a_correlated {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ]
    [DecidableEq κ] (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (C : Matrix ι κ ℝ) (u : ℝ) :
    (∀ g : EuclideanSpace ℝ κ,
      euclideanQuadratic A (Matrix.toEuclideanLin C g) =
        euclideanQuadratic (C.transpose * A * C) g) ∧
    frobSq (C.transpose * A * C) ≤ opNorm (C * C.transpose) ^ 2 * frobSq A ∧
    opNorm (C.transpose * A * C) ≤ opNorm (C * C.transpose) * opNorm A ∧
    (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u < |euclideanQuadratic A (Matrix.toEuclideanLin C g) -
          (C.transpose * A * C).trace|} ≤
      2 * Real.exp (-(1 / 8) * min (u ^ 2 / frobSq (C.transpose * A * C))
        (u / opNorm (C.transpose * A * C))) := by
  have hcov : opNorm (C * C.transpose) = opNorm C ^ 2 := euclidean_operator_norm_covariance C
  refine ⟨fun g => euclideanQuadratic_linear_image A C g, ?_, ?_, ?_⟩
  · have h := entry_sq_sum_quadratic_pullback_le A C
    change frobSq (C.transpose * A * C) ≤ opNorm C ^ 4 * frobSq A at h
    rw [hcov]
    calc _ ≤ _ := h
      _ = _ := by ring
  · rw [hcov]
    exact euclidean_operator_norm_quadratic_pullback_le A C
  · have hset : {g : EuclideanSpace ℝ κ | u < |euclideanQuadratic A (Matrix.toEuclideanLin C g) -
        (C.transpose * A * C).trace|} =
        {g | u < |euclideanQuadratic (C.transpose * A * C) g - (C.transpose * A * C).trace|} := by
      ext g
      simp only [Set.mem_setOf_eq, euclideanQuadratic_linear_image]
    rw [hset]
    exact (lem_gauss_a _ (isHermitian_quadratic_pullback A hA C) u).2

/-- `lem:gauss` (b), Lipschitz functions.

TeX: "\emph{(Lipschitz functions.)} If $F$ is $C^1$ with $\norm{\nabla F}\le\ell$
and $g$ is standard Gaussian, then
$\Prob\{|F(g)-\E F(g)|>u\}\le2\exp(-2u^2/(\pi^2\ell^2))$."

(`u ≥ 0` is implicit in the paper; the inequality is false for very negative `u`.) -/
theorem lem_gauss_b {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E]
    (F : E → ℝ) (hF : ContDiff ℝ 1 F) {ℓ : ℝ} (hℓ : ∀ x, ‖fderiv ℝ F x‖ ≤ ℓ)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | u < |F x - ∫ y, F y ∂stdGaussian E|} ≤
      2 * Real.exp (-2 * u ^ 2 / (Real.pi ^ 2 * ℓ ^ 2)) := by
  have hℓ0 : 0 ≤ ℓ := (norm_nonneg _).trans (hℓ 0)
  rcases hℓ0.lt_or_eq with hℓpos | hℓz
  · exact (measureReal_mono (fun x (hx : u < _) => le_of_lt hx)).trans
      (stdGaussian_smooth_abs_tail F hF hℓpos hℓ hu)
  · rw [← hℓz]
    simp only [ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, mul_zero, div_zero,
      Real.exp_zero, mul_one]
    have : (stdGaussian E).real {x | u < |F x - ∫ y, F y ∂stdGaussian E|} ≤ 1 :=
      measureReal_le_one
    linarith

/-- `lem:gauss` (c), nets.

TeX: "\emph{(Nets.)} If $Z$ is an $r\times s$ centred Gaussian matrix with
$\Cov(\mathrm{vec}\,Z)\preceq\sigma^2I$, then
$\Prob\{\opn Z>u\}\le2\cdot5^{r+s}\exp(-u^2/(32\sigma^2))$."

Encoding: `Z = frameOfVector (C g)`, `Cov(vec Z) = C Cᵀ ⪯ σ² I ⟺ ‖C‖_op² ≤ σ²`.
(`u ≥ 0` is implicit in the paper.) -/
theorem lem_gauss_c {r s : ℕ} {κ : Type*} [Fintype κ] [DecidableEq κ]
    (C : Matrix (Fin r × Fin s) κ ℝ) {σ u : ℝ} (hu : 0 ≤ u) (hC : opNorm C ^ 2 ≤ σ ^ 2) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u < opNorm (frameOfVector (Matrix.toEuclideanLin C g))} ≤
      2 * 5 ^ (r + s) * Real.exp (-u ^ 2 / (32 * σ ^ 2)) := by
  rcases (sq_nonneg σ).lt_or_eq with hv | hv
  · have h := gaussian_matrix_operator_net_tail C (σ ^ 2) (u / 4) hv (by positivity) hC
    have h4 : 4 * (u / 4) = u := by ring
    have he : -(u / 4) ^ 2 / (2 * σ ^ 2) = -u ^ 2 / (32 * σ ^ 2) := by
      field_simp; ring
    rw [h4, he] at h
    exact h
  · rw [← hv, mul_zero, div_zero, Real.exp_zero, mul_one]
    have h1 : (stdGaussian (EuclideanSpace ℝ κ)).real
        {g | u < opNorm (frameOfVector (Matrix.toEuclideanLin C g))} ≤ 1 := measureReal_le_one
    have h5 : (1 : ℝ) ≤ 5 ^ (r + s) := one_le_pow₀ (by norm_num)
    linarith

/-- Covariance of a Gaussian linear image: `E (Cg)_a (Cg)_b = (CCᵀ)_{ab}` (not a paper item). -/
theorem gauss_aux_coord_mul {α κ : Type*} [Fintype α] [Fintype κ] [DecidableEq κ]
    (C : Matrix α κ ℝ) (a b : α) :
    Integrable (fun g : EuclideanSpace ℝ κ =>
      (Matrix.toEuclideanLin C g) a * (Matrix.toEuclideanLin C g) b)
      (stdGaussian (EuclideanSpace ℝ κ)) ∧
    ∫ g, (Matrix.toEuclideanLin C g) a * (Matrix.toEuclideanLin C g) b
      ∂stdGaussian (EuclideanSpace ℝ κ) = (C * C.transpose) a b := by
  set μ := stdGaussian (EuclideanSpace ℝ κ)
  let c : α → EuclideanSpace ℝ κ := fun a => WithLp.toLp 2 (fun k => C a k)
  have hξ (g : EuclideanSpace ℝ κ) (a : α) :
      (Matrix.toEuclideanLin C g) a = innerSL ℝ (c a) g := by
    simp only [innerSL_apply_apply, PiLp.inner_apply, Real.inner_apply, Matrix.toLpLin_apply,
      Matrix.mulVec, dotProduct, c]
  have hint2 (w : EuclideanSpace ℝ κ) :
      Integrable (fun g => (innerSL ℝ w g) ^ 2) μ :=
    (IsGaussian.memLp_dual μ (innerSL ℝ w) 2 (by norm_num)).integrable_sq
  simp_rw [hξ]
  have hpol (g : EuclideanSpace ℝ κ) : innerSL ℝ (c a) g * innerSL ℝ (c b) g =
      ((innerSL ℝ (c a + c b) g) ^ 2 - (innerSL ℝ (c a - c b) g) ^ 2) / 4 := by
    simp only [map_add, map_sub, _root_.add_apply, _root_.sub_apply]
    ring
  have hI : Integrable (fun g => ((innerSL ℝ (c a + c b) g) ^ 2 -
      (innerSL ℝ (c a - c b) g) ^ 2) / 4) μ :=
    ((hint2 _).sub (hint2 _)).div_const _
  refine ⟨hI.congr (Filter.Eventually.of_forall fun g => (hpol g).symm), ?_⟩
  simp_rw [hpol]
  rw [integral_div, integral_sub (hint2 _) (hint2 _), integral_sq_dual_stdGaussian,
    integral_sq_dual_stdGaussian, innerSL_apply_norm, innerSL_apply_norm,
    norm_add_sq_real, norm_sub_sq_real]
  simp only [Matrix.mul_apply, Matrix.transpose_apply, PiLp.inner_apply, Real.inner_apply, c]
  ring

/-- Reordering a fourfold finite sum. -/
theorem gauss_aux_sum4_comm {ι₁ ι₂ ι₃ ι₄ : Type*} [Fintype ι₁] [Fintype ι₂] [Fintype ι₃]
    [Fintype ι₄] (f : ι₁ → ι₂ → ι₃ → ι₄ → ℝ) :
    ∑ i, ∑ j, ∑ a, ∑ b, f i j a b = ∑ a, ∑ b, ∑ i, ∑ j, f i j a b := by
  calc ∑ i, ∑ j, ∑ a, ∑ b, f i j a b = ∑ i, ∑ a, ∑ j, ∑ b, f i j a b :=
        Finset.sum_congr rfl fun i _ => Finset.sum_comm
    _ = ∑ a, ∑ i, ∑ j, ∑ b, f i j a b := Finset.sum_comm
    _ = ∑ a, ∑ i, ∑ b, ∑ j, f i j a b :=
        Finset.sum_congr rfl fun a _ => Finset.sum_congr rfl fun i _ => Finset.sum_comm
    _ = ∑ a, ∑ b, ∑ i, ∑ j, f i j a b := Finset.sum_congr rfl fun a _ => Finset.sum_comm

/-- Paragraph "Covariance domination" (unnumbered claim used in `lem:sample` (S4)).

TeX: "If a Gaussian vector $\xi$ has covariance
$\Gamma\preceq\gamma I$ and $(M_\alpha)$ are matrices, then
$\E\fro{\sum_\alpha\xi_\alpha M_\alpha}^2=\tr(\Gamma\mathsf G)\le\gamma\sum_\alpha
\fro{M_\alpha}^2$, where $\mathsf G\succeq0$ is the Gram matrix of the $M_\alpha$."

Encoding: `ξ = C g`, `Γ = C Cᵀ`, `Γ ⪯ γ I ⟺ ‖C‖_op² ≤ γ`. -/
theorem covariance_domination {α κ : Type*} [Fintype α] [DecidableEq α] [Fintype κ]
    [DecidableEq κ] {p q : ℕ} (C : Matrix α κ ℝ) {γ : ℝ} (hC : opNorm C ^ 2 ≤ γ)
    (M : α → Matrix (Fin p) (Fin q) ℝ) :
    ∫ g, frobSq (∑ a, (Matrix.toEuclideanLin C g) a • M a)
        ∂stdGaussian (EuclideanSpace ℝ κ) =
      (C * C.transpose * Matrix.of (fun a b => ∑ i, ∑ j, M a i j * M b i j)).trace ∧
    (C * C.transpose * Matrix.of (fun a b => ∑ i, ∑ j, M a i j * M b i j)).trace ≤
      γ * ∑ a, frobSq (M a) := by
  set μ := stdGaussian (EuclideanSpace ℝ κ)
  set G : Matrix α α ℝ := Matrix.of (fun a b => ∑ i, ∑ j, M a i j * M b i j) with hG
  -- the rows of `C` as vectors
  let c : α → EuclideanSpace ℝ κ := fun a => WithLp.toLp 2 (fun k => C a k)
  have hξ (g : EuclideanSpace ℝ κ) (a : α) :
      (Matrix.toEuclideanLin C g) a = innerSL ℝ (c a) g := by
    simp only [innerSL_apply_apply, PiLp.inner_apply, Real.inner_apply, Matrix.toLpLin_apply,
      Matrix.mulVec, dotProduct, c]
  have hint2 (w : EuclideanSpace ℝ κ) :
      Integrable (fun g => (innerSL ℝ w g) ^ 2) μ :=
    (IsGaussian.memLp_dual μ (innerSL ℝ w) 2 (by norm_num)).integrable_sq
  have hcorr (a b : α) : Integrable (fun g => innerSL ℝ (c a) g * innerSL ℝ (c b) g) μ ∧
      ∫ g, innerSL ℝ (c a) g * innerSL ℝ (c b) g ∂μ = (C * C.transpose) a b := by
    simpa only [hξ] using gauss_aux_coord_mul C a b
  have hexp (g : EuclideanSpace ℝ κ) :
      frobSq (∑ a, (Matrix.toEuclideanLin C g) a • M a) =
        ∑ a, ∑ b, (innerSL ℝ (c a) g * innerSL ℝ (c b) g) * G a b := by
    have h1 : frobSq (∑ a, (Matrix.toEuclideanLin C g) a • M a) =
        ∑ i, ∑ j, ∑ a, ∑ b, (innerSL ℝ (c a) g * innerSL ℝ (c b) g) * (M a i j * M b i j) := by
      unfold frobSq
      apply Finset.sum_congr rfl; intro i _
      apply Finset.sum_congr rfl; intro j _
      simp only [Matrix.sum_apply, Matrix.smul_apply, smul_eq_mul, hξ, pow_two,
        Finset.sum_mul_sum]
      apply Finset.sum_congr rfl; intro a _
      apply Finset.sum_congr rfl; intro b _
      ring
    rw [h1]
    refine Eq.trans (gauss_aux_sum4_comm _) ?_
    apply Finset.sum_congr rfl; intro a _
    apply Finset.sum_congr rfl; intro b _
    simp only [hG, Matrix.of_apply, Finset.mul_sum]
  have htr : (C * C.transpose * G).trace = ∑ a, ∑ b, (C * C.transpose) a b * G a b := by
    simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply (M := C * C.transpose)]
    apply Finset.sum_congr rfl; intro a _
    apply Finset.sum_congr rfl; intro b _
    congr 1
    simp only [hG, Matrix.of_apply]
    apply Finset.sum_congr rfl; intro i _
    apply Finset.sum_congr rfl; intro j _
    ring
  constructor
  · simp_rw [hexp]
    rw [integral_finsetSum _ (fun a _ => integrable_finsetSum _ (fun b _ =>
      (hcorr a b).1.mul_const _))]
    rw [htr]
    apply Finset.sum_congr rfl; intro a _
    rw [integral_finsetSum _ (fun b _ => (hcorr a b).1.mul_const _)]
    apply Finset.sum_congr rfl; intro b _
    rw [integral_mul_const, (hcorr a b).2]
  · rw [htr]
    let Mm : Matrix α (Fin p × Fin q) ℝ := fun a ij => M a ij.1 ij.2
    have hmain := entry_sq_sum_mul_le C.transpose Mm
    rw [euclidean_operator_norm_transpose] at hmain
    have hL : ∑ a, ∑ b, (C * C.transpose) a b * G a b =
        ∑ k, ∑ ij, ((C.transpose * Mm) k ij) ^ 2 := by
      have hrhs : ∑ k, ∑ ij, ((C.transpose * Mm) k ij) ^ 2 =
          ∑ k, ∑ i, ∑ j, ∑ a, ∑ b, (C a k * C b k) * (M a i j * M b i j) := by
        apply Finset.sum_congr rfl; intro k _
        rw [Fintype.sum_prod_type]
        apply Finset.sum_congr rfl; intro i _
        apply Finset.sum_congr rfl; intro j _
        simp only [Matrix.mul_apply, Matrix.transpose_apply, Mm, pow_two, Finset.sum_mul_sum]
        apply Finset.sum_congr rfl; intro a _
        apply Finset.sum_congr rfl; intro b _
        ring
      rw [hrhs]
      have hk : ∑ k, ∑ i, ∑ j, ∑ a, ∑ b, (C a k * C b k) * (M a i j * M b i j) =
          ∑ i, ∑ j, ∑ a, ∑ b, ∑ k, (C a k * C b k) * (M a i j * M b i j) := by
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl; intro i _
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl; intro j _
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl; intro a _
        rw [Finset.sum_comm]
      rw [hk]
      refine Eq.trans ?_ (gauss_aux_sum4_comm _).symm
      apply Finset.sum_congr rfl; intro a _
      apply Finset.sum_congr rfl; intro b _
      simp only [hG, Matrix.of_apply, Matrix.mul_apply, Matrix.transpose_apply,
        Finset.sum_mul, Finset.mul_sum]
    have hR : ∑ a, ∑ ij, Mm a ij ^ 2 = ∑ a, frobSq (M a) := by
      apply Finset.sum_congr rfl; intro a _
      rw [Fintype.sum_prod_type]
      rfl
    rw [hL]
    calc _ ≤ _ := hmain
      _ = opNorm C ^ 2 * ∑ a, frobSq (M a) := by rw [hR]; rfl
      _ ≤ γ * ∑ a, frobSq (M a) :=
        mul_le_mul_of_nonneg_right hC (Finset.sum_nonneg fun a _ =>
          Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _)

end

end Paulsen.Paper
