import NeuralGeneralization.BatchTwoImprovedSamplingMoments
import NeuralGeneralization.BatchTwoImprovedProjectedGaussian
import NeuralGeneralization.BatchTwoImprovedActiveGeometry

/-! Exact importance-weighted sampled vectors and the residual standard-
deviation error. The sampler is defined in coefficient space before an input
is chosen; the bound below is pointwise in the input feature vector. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
open InnerProductSpace WithLp
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling RobustGaussianGeometry BatchTwoImprovedProjection Classical
variable {N q m : ℕ}

def sampledVector (a : Fin N → ℝ) (s : Fin m → Fin N) (h : Fin N → ℝ) :
    EuclideanSpace ℝ (Fin m) :=
  toLp 2 (fun i => Real.sqrt (a (s i))/Real.sqrt (m:ℝ)*h (s i))

def sampledColumns (a : Fin N → ℝ) (s : Fin m → Fin N) (u : Fin N → Fin q → ℝ) :
    Fin q → EuclideanSpace ℝ (Fin m) := fun k => sampledVector a s (fun j => u j k)

theorem sampledVector_norm_sq (a : Fin N → ℝ) (ha : ∀ j, 0 ≤ a j)
    (s : Fin m → Fin N) (h : Fin N → ℝ) :
    ‖sampledVector a s h‖^2 = sampleAverage s (fun j => a j*(h j)^2) := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [sampledVector, mul_pow, div_pow, Real.sq_sqrt (ha _),
    Real.sq_sqrt (Nat.cast_nonneg m), sampleAverage]
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem sampledColumns_inner (a : Fin N → ℝ) (ha : ∀ j, 0 ≤ a j)
    (s : Fin m → Fin N) (u : Fin N → Fin q → ℝ) (R : Fin N → ℝ) (k : Fin q) :
    ⟪sampledColumns a s u k,sampledVector a s R⟫ =
      sampleAverage s (fun j => a j*u j k*R j) := by
  simp only [EuclideanSpace.inner_eq_star_dotProduct, sampledColumns, sampledVector,
    star_trivial, dotProduct, sampleAverage]
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro i _
  have he : (Real.sqrt (a (s i)))^2=a (s i) := Real.sq_sqrt (ha _)
  have hm : (Real.sqrt (m:ℝ))^2=(m:ℝ) := Real.sq_sqrt (Nat.cast_nonneg m)
  calc
    _ = ((Real.sqrt (a (s i)))^2/(Real.sqrt (m:ℝ))^2)*(u (s i) k*R (s i)) := by ring
    _ = _ := by rw [he,hm]; ring

theorem sampledColumns_combination (a : Fin N → ℝ) (s : Fin m → Fin N)
    (u : Fin N → Fin q → ℝ) (v : Fin q → ℝ) :
    ∑ k, v k • sampledColumns a s u k =
      sampledVector a s (fun j => linearEvaluation (u j) v) := by
  apply PiLp.ext
  intro i
  change (EuclideanSpace.proj i) (∑ k, v k • sampledColumns a s u k) = _
  simp only [map_sum,map_smul,smul_eq_mul]
  change (∑ k, v k*(Real.sqrt (a (s i))/Real.sqrt (m:ℝ)*u (s i) k)) =
    Real.sqrt (a (s i))/Real.sqrt (m:ℝ)*linearEvaluation (u (s i)) v
  simp only [linearEvaluation,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro k _
  ring

theorem sampledColumns_zero (a : Fin N → ℝ) (s : Fin m → Fin N)
    (u : Fin N → Fin q → ℝ) (k : Fin q) (hk : ∀ j, u j k=0) :
    sampledColumns a s u k=0 := by
  apply PiLp.ext
  intro i
  simp [sampledColumns,sampledVector,hk]

theorem sampledColumns_coercivity (a : Fin N → ℝ) (ha : ∀ j, 0 ≤ a j)
    (s : Fin m → Fin N) (u : Fin N → Fin q → ℝ)
    (S : Finset (Fin q)) (hm : 0 < m)
    (hgood : ¬badGramOn (fun j k => Real.sqrt (a j)*u j k)
      (fun v => ∀ k, k ∉ S → v k=0) s)
    (v : Fin q → ℝ) (hv : ∀ k, k ∉ S → v k=0) :
    (∑ k, (v k)^2) ≤ 2*‖∑ k, v k • sampledColumns a s u k‖^2 := by
  rw [sampledColumns_combination,sampledVector_norm_sq a ha]
  have h := goodGramOn_coercivity (fun j k => Real.sqrt (a j)*u j k)
    (fun v => ∀ k, k ∉ S → v k=0)
    (by intro v hv c k hk; simp [hv k hk]) s hm hgood v hv
  have he (j : Fin N) :
      (linearEvaluation (fun k => Real.sqrt (a j)*u j k) v)^2 =
        a j*(linearEvaluation (u j) v)^2 := by
    have hl : linearEvaluation (fun k => Real.sqrt (a j)*u j k) v =
        Real.sqrt (a j)*linearEvaluation (u j) v := by
      simp [linearEvaluation, Finset.mul_sum,mul_assoc]
    rw [hl,mul_pow,Real.sq_sqrt (ha j)]
  simpa only [he,sampleAverage] using h

/-- The least-squares projection costs at most twice the squared sampled
residual correlations, on the actual good Gram event. -/
theorem sampled_residual_projection_error (a : Fin N → ℝ) (ha : ∀ j, 0 ≤ a j)
    (s : Fin m → Fin N) (u : Fin N → Fin q → ℝ) (R : Fin N → ℝ)
    (S : Finset (Fin q)) (hzero : ∀ k, k ∉ S → ∀ j, u j k=0) (hm : 0 < m)
    (hgood : ¬badGramOn (fun j k => Real.sqrt (a j)*u j k)
      (fun v => ∀ k, k ∉ S → v k=0) s) :
    (‖sampledVector a s R‖-
      ‖queryResidual (sampledColumns a s u) (sampledVector a s R)‖)^2 ≤
      2*∑ k, (sampleAverage s (fun j => a j*u j k*R j))^2 := by
  have h := (residual_norm_gap_square_le (sampledColumns a s u) (sampledVector a s R)).trans
    (projection_energy_le_active (sampledColumns a s u) S
      (fun k hk => sampledColumns_zero a s u k (hzero k hk))
      (sampledColumns_coercivity a ha s u S hm hgood) (sampledVector a s R))
  simpa only [sampledColumns_inner a ha] using h

/-- Exact square-root covariance comparison with a good-event indicator.
Its q/m dependence is the essential improvement over absolute covariance
approximation. No variance bounded away from zero is needed. -/
theorem whitened_variance_mean_square (hN : 0 < N) (hm : 0 < m)
    (p a : Fin N → ℝ) (hp : ∀ j, 0 ≤ p j) (hpm : ∑ j, p j=1)
    (ha : ∀ j, 0 ≤ a j) (hpa : ∀ j, p j*a j=1/(N:ℝ))
    (u : Fin N → Fin q → ℝ) (R : Fin N → ℝ)
    (horth : ∀ k, (∑ j, u j k*R j)=0)
    (henergy : ∀ j, a j*(∑ k, (u j k)^2) ≤ 2*q)
    (hbound : ∀ j, a j*(R j)^2 ≤ 4*((q:ℝ)+1))
    (hC : (∑ j, (R j)^2)/(N:ℝ) ≤ 1)
    (S : Finset (Fin q)) (hzero : ∀ k, k ∉ S → ∀ j, u j k=0) :
    mean (iidWeight p m) (fun s =>
      if badGramOn (fun j k => Real.sqrt (a j)*u j k)
        (fun v => ∀ k, k ∉ S → v k=0) s then 0 else
      (‖queryResidual (sampledColumns a s u) (sampledVector a s R)‖-
        Real.sqrt ((∑ j, (R j)^2)/(N:ℝ)))^2) ≤ 16*((q:ℝ)+1)/(m:ℝ) := by
  let C := (∑ j, (R j)^2)/(N:ℝ)
  have hsqrt (s : Fin m → Fin N) :
      Real.sqrt (sampleAverage s (fun j => a j*(R j)^2)) = ‖sampledVector a s R‖ := by
    rw [← sampledVector_norm_sq a ha,Real.sqrt_sq (norm_nonneg _)]
  have hs := residual_sample_sqrt_error hm p a hp hpm ha hpa R hbound
  simp_rw [hsqrt] at hs
  have hc := residual_sample_cross_square hm p a hp hpm ha hpa u R horth henergy
  have hpoint (s : Fin m → Fin N) :
      (if badGramOn (fun j k => Real.sqrt (a j)*u j k)
        (fun v => ∀ k, k ∉ S → v k=0) s then 0 else
        (‖queryResidual (sampledColumns a s u) (sampledVector a s R)‖-Real.sqrt C)^2) ≤
      2*(‖sampledVector a s R‖-Real.sqrt C)^2+
        4*∑ k, (sampleAverage s (fun j => a j*u j k*R j))^2 := by
    split_ifs with hbad
    · positivity
    · have h := sampled_residual_projection_error a ha s u R S hzero hm hbad
      nlinarith [sq_nonneg (2*‖sampledVector a s R‖-
        Real.sqrt C-‖queryResidual (sampledColumns a s u) (sampledVector a s R)‖),
        sq_nonneg (‖sampledVector a s R‖-Real.sqrt C)]
  have hmean := mean_mono (iidWeight p m) (iidWeight_nonneg p hp m) hpoint
  rw [mean_add,mean_mul,mean_mul] at hmean
  have hn : (0:ℝ) < m := by exact_mod_cast hm
  have hq : (0:ℝ) ≤ q := Nat.cast_nonneg q
  have hc' : 2*q*C/(m:ℝ) ≤ 2*q/(m:ℝ) :=
    div_le_div_of_nonneg_right (by nlinarith [hC]) hn.le
  change _ ≤ 16*((q:ℝ)+1)/(m:ℝ)
  have htotal := hc.trans hc'
  dsimp [C] at hmean
  have hfinal : 2*(4*((q:ℝ)+1)/(m:ℝ))+4*(2*q/(m:ℝ)) ≤
      16*((q:ℝ)+1)/(m:ℝ) := by
    apply (le_div_iff₀ hn).mpr
    field_simp
    nlinarith
  exact hmean.trans ((add_le_add (mul_le_mul_of_nonneg_left hs (by norm_num))
    (mul_le_mul_of_nonneg_left htotal (by norm_num))).trans hfinal)

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
