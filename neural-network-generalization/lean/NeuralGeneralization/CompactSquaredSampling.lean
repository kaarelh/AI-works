import NeuralGeneralization.CompactSquaredBootstrap
import NeuralGeneralization.SquaredLipschitzProcess
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap

/-! Squared-response sampling on compact feature domains, under arbitrary
probability measures. Labels can be incorporated into the feature vector;
no independence between features and labels is required. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
variable {D n : ℕ}

abbrev ProcessUnitBall (D : ℕ) := Metric.closedBall (0 : ProcessVector D) 1
instance : CompactSpace (ProcessUnitBall D) := isCompact_iff_compactSpace.mp (isCompact_closedBall _ _)
instance : Nonempty (ProcessUnitBall D) := ⟨⟨0,by simp⟩⟩

def squaredFeature (ψ : C(ℝ,ℝ)) (a : ProcessVector D) : C(ProcessUnitBall D,ℝ) where
  toFun u := ψ (linearEvaluation a u.val)^2
  continuous_toFun := by unfold linearEvaluation; fun_prop

lemma continuous_squaredFeature (ψ : C(ℝ,ℝ)) :
    Continuous (squaredFeature (D:=D) ψ) := by
  apply ContinuousMap.continuous_of_continuous_uncurry
  change Continuous (fun p : ProcessVector D × ProcessUnitBall D =>
    ψ (linearEvaluation p.1 p.2.val)^2)
  unfold linearEvaluation
  fun_prop

lemma norm_signed_squaredFeature (ψ : C(ℝ,ℝ)) (a : Fin n → ProcessVector D) (ε : Fin n → Bool) :
    ‖signedSum (squaredFeature ψ) ε a‖ =
      unitSquaredSup (fun i => (a i).ofLp) (fun _ => ψ) ε := by
  rw [ContinuousMap.norm_eq_iSup_norm]
  unfold unitSquaredSup iSup
  congr 1
  ext z
  constructor
  · rintro ⟨u,rfl⟩
    refine ⟨u.val,u.property,?_⟩
    simp [signedSum,squaredFeature,rowSquaredProcess,Real.norm_eq_abs]
  · rintro ⟨u,hu,rfl⟩
    refine ⟨⟨u,hu⟩,?_⟩
    simp [signedSum,squaredFeature,rowSquaredProcess,Real.norm_eq_abs]

lemma sample_quadratic_le_norm (a : Fin n → ProcessVector D) (u : ProcessVector D) (hu : ‖u‖ ≤ 1) :
    (∑ i,linearEvaluation (a i) u^2) ≤ ‖sampleSum (squaredFeature (ContinuousMap.id ℝ)) a‖ := by
  have hh := (sampleSum (squaredFeature (ContinuousMap.id ℝ)) a).norm_coe_le_norm
    (⟨u,by simpa only [Metric.mem_closedBall,dist_zero_right] using hu⟩ : ProcessUnitBall D)
  simp only [sampleSum,ContinuousMap.sum_apply,squaredFeature,ContinuousMap.coe_mk,
    ContinuousMap.id_apply,Real.norm_eq_abs] at hh
  exact (le_abs_self _).trans hh

def squaredProcessCoefficient (n D : ℕ) : ℝ :=
  1073741824*Real.sqrt (D:ℝ)*Real.sqrt (Real.log (2*((n:ℝ)+D)))

lemma squaredFeature_rademacher (ψ : C(ℝ,ℝ)) (hψ0 : ψ 0=0)
    (hψ : ∀ x y,|ψ x-ψ y| ≤ |x-y|) (hn : 0<n) (hD : 0<D)
    (a : Fin n → ProcessVector D) (ha : ∀ i,‖a i‖^2 ≤ D) :
    finiteMean (fun ε => ‖signedSum (squaredFeature ψ) ε a‖) ≤
      squaredProcessCoefficient n D * Real.sqrt ‖sampleSum (squaredFeature (ContinuousMap.id ℝ)) a‖ := by
  simp_rw [norm_signed_squaredFeature]
  have hh := squared_lipschitz_process (fun i => (a i).ofLp) (fun _ => ψ)
    (fun _ => hψ0) (fun _ => hψ) hn hD
    (Real.sqrt_nonneg (D:ℝ))
    (Real.sqrt_nonneg ‖sampleSum (squaredFeature (ContinuousMap.id ℝ)) a‖)
    (fun i => by rw [Real.sq_sqrt (Nat.cast_nonneg D)]; simpa only [EuclideanSpace.real_norm_sq_eq] using ha i)
    (fun u hu => by rw [Real.sq_sqrt (norm_nonneg _)]; exact sample_quadratic_le_norm a u hu)
  exact hh

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
variable [MeasurableSpace X] [BorelSpace X] [SecondCountableTopology X]

/-- The complete integral estimate before division by the sample count.
The feature law is arbitrary and may have continuous or singular support. -/
theorem compact_squared_sampling (μ : Measure X) [IsProbabilityMeasure μ]
    (a : X → ProcessVector D) (ha : Continuous a) (hrow : ∀ x,‖a x‖^2 ≤ D)
    (hiso : ∀ u : ProcessVector D,(∫ x,linearEvaluation (a x) u^2 ∂μ)=‖u‖^2)
    (ψ : C(ℝ,ℝ)) (hψ0 : ψ 0=0) (hψ : ∀ x y,|ψ x-ψ y| ≤ |x-y|)
    (hn : 0<n) (hD : 0<D) :
    (∫ s : Fin n → X,
      ‖sampleSum (fun x => squaredFeature ψ (a x)) s -
        (n:ℝ) • ∫ x,squaredFeature ψ (a x) ∂μ‖ ∂Measure.pi (fun _ => μ)) ≤
      4*(squaredProcessCoefficient n D)^2+2*squaredProcessCoefficient n D*Real.sqrt (n:ℝ) := by
  have hF := (continuous_squaredFeature ψ).comp ha
  have hG := (continuous_squaredFeature (ContinuousMap.id ℝ)).comp ha
  apply compact_squared_process_bootstrap μ hF hG n (squaredProcessCoefficient n D)
    (by unfold squaredProcessCoefficient; positivity)
  · apply (ContinuousMap.norm_le _ (by norm_num : (0:ℝ) ≤ 1)).mpr
    intro u
    rw [ContinuousMap.integral_apply (compact_integrable μ hG)]
    change |∫ x,linearEvaluation (a x) u.val^2 ∂μ| ≤ 1
    rw [hiso,abs_of_nonneg (sq_nonneg _)]
    have hu : ‖u.val‖ ≤ 1 := by simpa only [Metric.mem_closedBall,dist_zero_right] using u.property
    nlinarith [norm_nonneg u.val]
  · intro s
    exact squaredFeature_rademacher (ContinuousMap.id ℝ) rfl (fun _ _ => le_rfl)
      hn hD (fun i => a (s i)) (fun i => hrow (s i))
  · intro s
    exact squaredFeature_rademacher ψ hψ0 hψ hn hD (fun i => a (s i)) (fun i => hrow (s i))

end NeuralGeneralization.SquaredSampling
