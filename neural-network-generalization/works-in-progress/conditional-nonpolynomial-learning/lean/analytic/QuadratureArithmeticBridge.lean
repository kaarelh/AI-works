import CanonicalEvaluator
import CanonicalRidgeQuadrature

/-! Convert actual importance quadrature nodes to the bounded real
coefficients of the concrete five-layer canonical arithmetic program. -/
noncomputable section
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

variable {Ω : Type*} [MeasurableSpace Ω] {d n m : ℕ}

 def quadratureProjectionCoefficient (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k : Ω→ℝ) (s : Fin n→Ω) (j : Fin m) (i : Fin n) : ℝ :=
  ((k (s i)/canonicalDensity μ e k (s i))*(e (s i)) j)/(n:ℝ)

 def quadratureNormCoefficient (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k : Ω→ℝ) (s : Fin n→Ω) (i : Fin n) : ℝ :=
  ((k (s i))^2/canonicalDensity μ e k (s i))/(n:ℝ)

 def quadratureJointValue (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k a : Ω→ℝ) (w : Ω→Fin d→ℝ) (s : Fin n→Ω) (v : Fin d→ℝ) :
    WithLp 2 (EuclideanSpace ℝ (Fin m) × ℝ) :=
  (n:ℝ)⁻¹ • ∑i,(canonicalNormalizer μ e k/canonicalEnvelope (e (s i)) (k (s i))) •
    jointCanonicalObservable (e (s i)) (k (s i)) (a (s i)) (∑j,w (s i) j*v j)

lemma quadratureProjectionCoefficient_bound (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k : Ω→ℝ) (s : Fin n→Ω) (hn : 0<n) (j : Fin m) (i : Fin n) :
    |quadratureProjectionCoefficient μ e k s j i| ≤ canonicalNormalizer μ e k/2 := by
  have hc := canonical_projection_coefficient_bound μ e k (s i)
  have hcoord : |(k (s i)/canonicalDensity μ e k (s i))*(e (s i)) j| ≤
      ‖(k (s i)/canonicalDensity μ e k (s i)) • e (s i)‖ :=
    PiLp.norm_apply_le ((k (s i)/canonicalDensity μ e k (s i)) • e (s i)) j
  have hn1 : (1:ℝ)≤n := by exact_mod_cast hn
  unfold quadratureProjectionCoefficient
  rw [abs_div,abs_of_nonneg (Nat.cast_nonneg n : (0:ℝ)≤n)]
  apply (div_le_iff₀ (Nat.cast_pos.mpr hn)).mpr
  have hZ := canonicalNormalizer_pos μ e k
  nlinarith [hcoord.trans hc]

lemma quadratureNormCoefficient_bound (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k : Ω→ℝ) (s : Fin n→Ω) (hn : 0<n) (i : Fin n) :
    0≤quadratureNormCoefficient μ e k s i ∧
      quadratureNormCoefficient μ e k s i≤canonicalNormalizer μ e k := by
  have hc := canonical_norm_coefficient_bound μ e k (s i)
  have hn1 : (1:ℝ)≤n := by exact_mod_cast hn
  constructor
  · exact div_nonneg hc.1 (Nat.cast_nonneg _)
  · apply (div_le_iff₀ (Nat.cast_pos.mpr hn)).mpr
    have hZ := canonicalNormalizer_pos μ e k
    nlinarith [hc.2]

lemma quadratureJointValue_projection (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k a : Ω→ℝ) (w : Ω→Fin d→ℝ) (s : Fin n→Ω) (v : Fin d→ℝ) (j : Fin m) :
    (quadratureJointValue μ e k a w s v).fst j =
      ∑i,quadratureProjectionCoefficient μ e k s j i*
        normalizedTanh (a (s i)) (∑l,w (s i) l*v l) := by
  simp only [quadratureJointValue,jointCanonicalObservable,WithLp.fst,WithLp.ofLp_smul,
    WithLp.ofLp_sum,WithLp.ofLp_toLp,Prod.smul_fst,Prod.fst_sum,
    Pi.smul_apply,Finset.sum_apply,smul_eq_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  unfold quadratureProjectionCoefficient canonicalDensity canonicalEnvelope
  field_simp
  <;> ring

lemma quadratureJointValue_norm (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k a : Ω→ℝ) (w : Ω→Fin d→ℝ) (s : Fin n→Ω) (v : Fin d→ℝ) :
    (quadratureJointValue μ e k a w s v).snd =
      ∑i,quadratureNormCoefficient μ e k s i*
        (normalizedTanh (a (s i)) (∑l,w (s i) l*v l))^2 := by
  simp only [quadratureJointValue,jointCanonicalObservable,WithLp.snd,WithLp.ofLp_smul,
    WithLp.ofLp_sum,WithLp.ofLp_toLp,Prod.smul_snd,Prod.snd_sum,smul_eq_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  unfold quadratureNormCoefficient canonicalDensity canonicalEnvelope
  field_simp
  <;> ring

def canonicalProgramVector (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ)
    (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ) (v : Fin d→ℝ) :
    WithLp 2 (EuclideanSpace ℝ (Fin m) × ℝ) :=
  WithLp.toLp 2 (WithLp.toLp 2 (fun j=>canonicalArithmeticProgram w a A b v (.inl j)),
    canonicalArithmeticProgram w a A b v (.inr ()))

theorem quadratureProgram_eq_completion (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k a : Ω→ℝ) (w : Ω→Fin d→ℝ) (s : Fin n→Ω) (v : Fin d→ℝ) :
    canonicalProgramVector (fun i=>w (s i)) (fun i=>a (s i))
      (quadratureProjectionCoefficient μ e k s) (quadratureNormCoefficient μ e k s) v =
      canonicalCompletion (quadratureJointValue μ e k a w s v).fst
        (quadratureJointValue μ e k a w s v).snd := by
  apply WithLp.ofLp_injective 2
  apply Prod.ext
  · apply WithLp.ofLp_injective 2
    funext j
    exact (canonicalArithmeticProgram_projection _ _ _ _ _ j).trans
      (quadratureJointValue_projection μ e k a w s v j).symm
  · change canonicalArithmeticProgram _ _ _ _ _ (.inr ()) = _
    rw [canonicalArithmeticProgram_residual]
    unfold canonicalCompletion
    change Real.sqrt (max 0 _) = Real.sqrt (max 0 _)
    congr 2
    rw [quadratureJointValue_norm,EuclideanSpace.real_norm_sq_eq]
    simp only [quadratureJointValue_projection,finiteRidgeValues]

/-- Actual finite-node moment accuracy propagates through the nonlinear
canonical residual, including at singular residual covariance. -/
theorem quadratureProgram_error (μ : Measure Ω) (e : Ω→EuclideanSpace ℝ (Fin m))
    (k a : Ω→ℝ) (w : Ω→Fin d→ℝ) (s : Fin n→Ω) (v : Fin d→ℝ)
    (M : WithLp 2 (EuclideanSpace ℝ (Fin m) × ℝ)) {R δ : ℝ}
    (hR : 0≤R) (hδ : 0≤δ) (hM : ‖M.fst‖≤R)
    (he : ‖quadratureJointValue μ e k a w s v-M‖≤δ) :
    ‖canonicalProgramVector (fun i=>w (s i)) (fun i=>a (s i))
      (quadratureProjectionCoefficient μ e k s) (quadratureNormCoefficient μ e k s) v-
      canonicalCompletion M.fst M.snd‖ ≤ δ+Real.sqrt ((1+2*(R+δ))*δ) := by
  rw [quadratureProgram_eq_completion]
  have hfst : ‖(quadratureJointValue μ e k a w s v).fst-M.fst‖≤δ :=
    (WithLp.norm_fst_le _ (quadratureJointValue μ e k a w s v-M)).trans he
  have hsnd : |(quadratureJointValue μ e k a w s v).snd-M.snd|≤δ :=
    (WithLp.norm_snd_le _ (quadratureJointValue μ e k a w s v-M)).trans he
  have hsample : ‖(quadratureJointValue μ e k a w s v).fst‖≤R+δ := by
    have hh := norm_sub_le (quadratureJointValue μ e k a w s v).fst M.fst
    have ht := norm_add_le ((quadratureJointValue μ e k a w s v).fst-M.fst) M.fst
    rw [sub_add_cancel] at ht
    linarith
  exact canonicalCompletion_error _ _ _ _ (R+δ) δ (by positivity) hδ hsample
    (hM.trans (by linarith)) hfst hsnd

#print axioms quadratureProgram_eq_completion
#print axioms quadratureProgram_error

#print axioms quadratureJointValue_projection
#print axioms quadratureJointValue_norm
end ConditionalNonpolynomial.Analytic
