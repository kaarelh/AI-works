import NeuralGeneralization.WalshGaussianLaw
import Mathlib.MeasureTheory.Measure.Portmanteau
import Mathlib.Analysis.SpecificLimits.Basic

/-! Fixed and moving orthant probabilities under ordinary weak convergence.
The moving-margin result follows from actual boundary nullity, dominated
continuity of the limiting orthant mass, and a monotone sandwich. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped Topology
namespace NeuralGeneralization.OrthantContinuity
open WalshGaussianLaw
variable {d : ℕ}

theorem orthant_antitone (g : ConcreteModel.BooleanFunction d) : Antitone (orthant g) :=
  fun _ _ hab _ hz x => hab.trans_lt (hz x)

theorem mass_antitone (μ : Measure (EuclideanSpace ℝ (ClippingCube d))) [IsFiniteMeasure μ]
    (g : ConcreteModel.BooleanFunction d) : Antitone (fun a => μ.real (orthant g a)) := by
  intro a b hab
  exact measureReal_mono (orthant_antitone g hab)

theorem indicator_continuousAt (g : ConcreteModel.BooleanFunction d) (a : ℝ)
    (z : EuclideanSpace ℝ (ClippingCube d))
    (hzbound : ∀ x, ConcreteModel.labelReal (g x)*z x ≠ a) :
    ContinuousAt (fun t => (orthant g t).indicator (fun _ => (1 : ℝ)) z) a := by
  classical
  by_cases hz : z ∈ orthant g a
  · have hev : ∀ᶠ t in 𝓝 a, z ∈ orthant g t :=
      Filter.eventually_all.2 fun x => gt_mem_nhds (hz x)
    have heq : (fun t => (orthant g t).indicator (fun _ => (1 : ℝ)) z) =ᶠ[𝓝 a]
        (fun _ => 1) := by
      filter_upwards [hev] with t ht
      exact indicator_of_mem ht _
    exact heq.continuousAt
  · have hx : ∃ x, ConcreteModel.labelReal (g x)*z x ≤ a := by
      simpa only [orthant, mem_setOf_eq, not_forall, not_lt] using hz
    obtain ⟨x,hx⟩ := hx
    have hxa : ConcreteModel.labelReal (g x)*z x < a := lt_of_le_of_ne hx (hzbound x)
    have heq : (fun t => (orthant g t).indicator (fun _ => (1 : ℝ)) z) =ᶠ[𝓝 a]
        (fun _ => 0) := by
      filter_upwards [lt_mem_nhds hxa] with t ht
      apply indicator_of_notMem
      intro hz'
      exact (not_lt.mpr ht.le) (hz' x)
    exact heq.continuousAt

theorem mass_continuousAt (μ : Measure (EuclideanSpace ℝ (ClippingCube d))) [IsFiniteMeasure μ]
    (g : ConcreteModel.BooleanFunction d) (a : ℝ)
    (hnull : ∀ x, μ {z | z x = ConcreteModel.labelReal (g x)*a} = 0) :
    ContinuousAt (fun t => μ.real (orthant g t)) a := by
  have hcoord : ∀ᵐ z ∂μ, ∀ x, ConcreteModel.labelReal (g x)*z x ≠ a := by
    rw [ae_all_iff]
    intro x
    have hz : ∀ᵐ z ∂μ, z x ≠ ConcreteModel.labelReal (g x)*a := by
      rw [ae_iff]
      simpa only [not_not] using hnull x
    filter_upwards [hz] with z hz
    intro he
    apply hz
    cases hg : g x <;> simp [ConcreteModel.labelReal, hg] at he ⊢ <;> linarith
  have h := continuousAt_of_dominated (μ := μ)
    (F := fun t z => (orthant g t).indicator (fun _ => (1 : ℝ)) z)
    (bound := fun _ => (1 : ℝ))
    (Eventually.of_forall fun t =>
      (measurable_const.indicator (isOpen_orthant g t).measurableSet).aestronglyMeasurable)
    (Eventually.of_forall fun t => Eventually.of_forall fun z => by
      by_cases hz : z ∈ orthant g t <;> simp [hz])
    (integrable_const 1)
    (hcoord.mono fun z hz => indicator_continuousAt g a z hz)
  have heq : (fun t => ∫ z, (orthant g t).indicator (fun _ => (1 : ℝ)) z ∂μ) =
      (fun t => μ.real (orthant g t)) := by
    funext t
    exact integral_indicator_one (isOpen_orthant g t).measurableSet
  rwa [heq] at h

/-- A scalar sandwich for antitone functions evaluated at a moving argument. -/
theorem tendsto_antitone_diagonal {F : ℕ → ℝ → ℝ} {L : ℝ → ℝ} {aN : ℕ → ℝ} {a : ℝ}
    (hF : ∀ n, Antitone (F n)) (hlim : ∀ t, Tendsto (fun n => F n t) atTop (𝓝 (L t)))
    (hL : ContinuousAt L a) (ha : Tendsto aN atTop (𝓝 a)) :
    Tendsto (fun n => F n (aN n)) atTop (𝓝 (L a)) := by
  have hε : Tendsto (fun n : ℕ => 1 / ((n : ℝ)+1)) atTop (𝓝 (0 : ℝ)) :=
    tendsto_one_div_add_atTop_nhds_zero_nat
  apply tendsto_order.2
  constructor
  · intro b hb
    have hplus : Tendsto (fun n : ℕ => a+1/((n : ℝ)+1)) atTop (𝓝 a) := by
      simpa only [add_zero] using hε.const_add a
    obtain ⟨m,hm⟩ := ((hL.tendsto.comp hplus).eventually (lt_mem_nhds hb)).exists
    have hδ : (0 : ℝ) < 1/((m : ℝ)+1) := by positivity
    have hth := ha.eventually (gt_mem_nhds (show a < a+1/((m : ℝ)+1) by linarith))
    have hv := (hlim (a+1/((m : ℝ)+1))).eventually (lt_mem_nhds hm)
    filter_upwards [hth,hv] with n hn hvn
    exact hvn.trans_le (hF n hn.le)
  · intro b hb
    have hminus : Tendsto (fun n : ℕ => a-1/((n : ℝ)+1)) atTop (𝓝 a) := by
      simpa only [sub_zero] using hε.const_sub a
    obtain ⟨m,hm⟩ := ((hL.tendsto.comp hminus).eventually (gt_mem_nhds hb)).exists
    have hδ : (0 : ℝ) < 1/((m : ℝ)+1) := by positivity
    have hth := ha.eventually (lt_mem_nhds (show a-1/((m : ℝ)+1) < a by linarith))
    have hv := (hlim (a-1/((m : ℝ)+1))).eventually (gt_mem_nhds hm)
    filter_upwards [hth,hv] with n hn hvn
    exact (hF n hn.le).trans_lt hvn

theorem fixed_orthant_tendsto {μN : ℕ → ProbabilityMeasure (EuclideanSpace ℝ (ClippingCube d))}
    {μ : ProbabilityMeasure (EuclideanSpace ℝ (ClippingCube d))}
    (hμ : Tendsto μN atTop (𝓝 μ)) (g : ConcreteModel.BooleanFunction d) (a : ℝ)
    (hnull : (μ : Measure _ ) (frontier (orthant g a)) = 0) :
    Tendsto (fun n => (μN n : Measure _).real (orthant g a)) atTop
      (𝓝 ((μ : Measure _).real (orthant g a))) := by
  exact (ENNReal.tendsto_toReal (measure_ne_top (μ : Measure (EuclideanSpace ℝ (ClippingCube d))) _)).comp
    (ProbabilityMeasure.tendsto_measure_of_null_frontier_of_tendsto' hμ hnull)

theorem moving_orthant_tendsto {μN : ℕ → ProbabilityMeasure (EuclideanSpace ℝ (ClippingCube d))}
    {μ : ProbabilityMeasure (EuclideanSpace ℝ (ClippingCube d))}
    (hμ : Tendsto μN atTop (𝓝 μ)) (g : ConcreteModel.BooleanFunction d)
    (hnull : ∀ (x : ClippingCube d) (a : ℝ),
      (μ : Measure (EuclideanSpace ℝ (ClippingCube d))) {z | z x = a} = 0)
    {aN : ℕ → ℝ} {a : ℝ} (ha : Tendsto aN atTop (𝓝 a)) :
    Tendsto (fun n => (μN n : Measure _).real (orthant g (aN n))) atTop
      (𝓝 ((μ : Measure _).real (orthant g a))) := by
  apply tendsto_antitone_diagonal (fun n => mass_antitone (μN n : Measure _) g)
    (fun t => fixed_orthant_tendsto hμ g t ?_)
    (mass_continuousAt (μ : Measure _) g a (fun x => hnull x _)) ha
  exact measure_mono_null (frontier_orthant_subset g t)
    (measure_iUnion_null (fun x => hnull x _))

theorem moving_orthant_walsh {μN : ℕ → ProbabilityMeasure (EuclideanSpace ℝ (ClippingCube d))}
    (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    (hμ : Tendsto μN atTop (𝓝 (⟨law w, inferInstance⟩ : ProbabilityMeasure _)))
    (g : ConcreteModel.BooleanFunction d) {aN : ℕ → ℝ} {a : ℝ}
    (ha : Tendsto aN atTop (𝓝 a)) :
    Tendsto (fun n => (μN n : Measure _).real (orthant g (aN n))) atTop
      (𝓝 ((law w).real (orthant g a))) :=
  moving_orthant_tendsto hμ g (coordinate_boundary_null w hw) ha

end NeuralGeneralization.OrthantContinuity
end
