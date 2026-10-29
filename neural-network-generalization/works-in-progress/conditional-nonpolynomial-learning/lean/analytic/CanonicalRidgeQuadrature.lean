import CanonicalRidgeBounds

/-! Uniform finite-node approximation of the actual normalized tanh projection
and squared-norm observables. Only finite second moments and measurability are
required; the arbitrary scalar normalization does not enter the resource bound. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

variable {ι : Type*} [Fintype ι]

def ridgeInput {U : ℝ} (w : ι → ℝ) (t : ParameterCube ι U) : ℝ := ∑ i, w i*t.val i

lemma ridgeInput_bound {U : ℝ} (hU : 0 ≤ U) (w : ι → ℝ)
    (hw : ∀ i, |w i| ≤ 1) (t : ParameterCube ι U) :
    |ridgeInput w t| ≤ ((Fintype.card ι:ℝ)+1)*U := by
  calc
    |ridgeInput w t| ≤ ∑ i, |w i*t.val i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : ι, U := Finset.sum_le_sum fun i _ => by
      rw [abs_mul]
      simpa using mul_le_mul (hw i) (t.property i) (abs_nonneg _) (by norm_num : (0:ℝ) ≤ 1)
    _ ≤ ((Fintype.card ι:ℝ)+1)*U := by simp; nlinarith

lemma ridgeInput_lipschitz {U : ℝ} (w : ι → ℝ) (hw : ∀ i, |w i| ≤ 1)
    (t u : ParameterCube ι U) :
    |ridgeInput w t-ridgeInput w u| ≤ ((Fintype.card ι:ℝ)+1)*dist t u := by
  have hcoord (i : ι) : |t.val i-u.val i| ≤ dist t u := by
    exact norm_le_pi_norm (t.val-u.val) i
  calc
    |ridgeInput w t-ridgeInput w u| = |∑ i, w i*(t.val i-u.val i)| := by
      simp [ridgeInput, mul_sub, Finset.sum_sub_distrib]
    _ ≤ ∑ i, |w i*(t.val i-u.val i)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : ι, dist t u := Finset.sum_le_sum fun i _ => by
      rw [abs_mul]
      simpa using mul_le_mul (hw i) (hcoord i) (abs_nonneg _) (by norm_num : (0:ℝ) ≤ 1)
    _ ≤ ((Fintype.card ι:ℝ)+1)*dist t u := by simp; nlinarith [dist_nonneg (x:=t) (y:=u)]

variable {Ω E : Type*} [MeasurableSpace Ω] [NormedAddCommGroup E]
  [InnerProductSpace ℝ E] [CompleteSpace E]

def jointRidge {U : ℝ} (e : Ω → E) (k a : Ω → ℝ) (w : Ω → ι → ℝ)
    (t : ParameterCube ι U) (x : Ω) : WithLp 2 (E × ℝ) :=
  jointCanonicalObservable (e x) (k x) (a x) (ridgeInput (w x) t)

/-- Polynomial-budget empirical importance quadrature of the joint canonical
observable. In particular the bound is independent of `a`, even when `a` has
arbitrarily large or small magnitude. -/
theorem normalized_ridge_quadrature
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (e : Ω → E) (k a : Ω → ℝ) (w : Ω → ι → ℝ)
    (heMeas : Measurable (fun x => ‖e x‖^2)) (hkMeas : Measurable (fun x => (k x)^2))
    (heInt : Integrable (fun x => ‖e x‖^2) μ) (hkInt : Integrable (fun x => (k x)^2) μ)
    (hw : ∀ x i, |w x i| ≤ 1)
    (U : ℝ) (hU : 0 < U)
    (hMeas : ∀ t : ParameterCube ι U, AEStronglyMeasurable (jointRidge e k a w t) μ)
    (T : ℕ) (hT : 0 < T) (ε : ℝ) (hε : 0 < ε) (m : ℕ) (hm : 0 < m)
    (hmesh : let D := (Fintype.card ι:ℝ)+1
     let B := D*U
     let Z := canonicalNormalizer μ e k
     4*(Z*(D*(1+2*B)))*U ≤ (T:ℝ)*ε)
    (hbudget : let D := (Fintype.card ι:ℝ)+1
     let B := D*U
     let Z := canonicalNormalizer μ e k
     1024*(Z*(B+B^2))^2*(1+(Fintype.card ι:ℝ)*Real.log (2*(T:ℝ)+1)) ≤ (m:ℝ)*ε^2) :
    ∃ s : Fin m → Ω, ∀ t : ParameterCube ι U,
      ‖(m:ℝ)⁻¹ • (∑ j, (canonicalNormalizer μ e k/canonicalEnvelope (e (s j)) (k (s j))) •
          jointRidge e k a w t (s j)) - ∫ x, jointRidge e k a w t x ∂μ‖ < ε := by
  let D := (Fintype.card ι:ℝ)+1
  let B := D*U
  let H := fun x => canonicalEnvelope (e x) (k x)
  have hD : 0 < D := by dsimp [D]; positivity
  have hB : 0 < B := mul_pos hD hU
  have hHone : ∀ x, 1 ≤ H x := fun x => canonicalEnvelope_one_le (e x) (k x)
  have hHmeas : Measurable H := (measurable_const.add heMeas).add hkMeas
  have hHInt : Integrable H μ := ((integrable_const (1:ℝ)).add heInt).add hkInt
  have hZ : (∫ x, H x ∂μ) = canonicalNormalizer μ e k := by
    dsimp only [H, canonicalEnvelope, canonicalNormalizer]
    rw [integral_add (f:=fun x => 1+‖e x‖^2) (g:=fun x => (k x)^2)
      ((integrable_const (1:ℝ)).add heInt) hkInt,
      integral_add (f:=fun _ => (1:ℝ)) (g:=fun x => ‖e x‖^2) (integrable_const (1:ℝ)) heInt]
    simp
  have hbound (t : ParameterCube ι U) (x : Ω) :
      ‖jointRidge e k a w t x‖ ≤ H x*(B+B^2) :=
    jointCanonicalObservable_bound _ _ _ _ B (ridgeInput_bound hU.le (w x) (hw x) t)
  have hInt (t : ParameterCube ι U) : Integrable (jointRidge e k a w t) μ :=
    (hHInt.mul_const (B+B^2)).mono' (hMeas t) (Filter.Eventually.of_forall (hbound t))
  have hLip (t u : ParameterCube ι U) (x : Ω) :
      ‖jointRidge e k a w t x-jointRidge e k a w u x‖ ≤ H x*((D*(1+2*B))*dist t u) := by
    have hh := jointCanonicalObservable_lipschitz (e x) (k x) (a x)
      (ridgeInput (w x) t) (ridgeInput (w x) u) B
      (ridgeInput_bound hU.le (w x) (hw x) t) (ridgeInput_bound hU.le (w x) (hw x) u)
    have hr := ridgeInput_lipschitz (w x) (hw x) t u
    have hHpos : 0 ≤ H x := (by norm_num : (0:ℝ) ≤ 1).trans (hHone x)
    have hz : 0 ≤ H x*(1+2*B) := mul_nonneg hHpos (by linarith)
    have hh2 := mul_le_mul_of_nonneg_left hr hz
    dsimp only [jointRidge] at *
    nlinarith
  obtain ⟨s,hs⟩ := envelope_cube_quadrature μ H hHmeas hHInt hHone U hU T hT
    (jointRidge e k a w) hInt (B+B^2) (D*(1+2*B)) ε (by positivity) (by positivity)
    hε hbound hLip m hm (by simpa only [hZ] using hmesh) (by simpa only [hZ] using hbudget)
  exact ⟨s,fun t => by simpa only [hZ] using hs t⟩

#print axioms normalized_ridge_quadrature
end ConditionalNonpolynomial.Analytic
