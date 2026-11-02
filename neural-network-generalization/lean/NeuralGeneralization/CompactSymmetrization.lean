import NeuralGeneralization.FiniteSymmetrization
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.MeasureTheory.Function.LocallyIntegrable
import Mathlib.Topology.ContinuousMap.Compact

/-! Rademacher symmetrization for arbitrary probability laws on compact
spaces. The process takes values in a Banach space, so continuous function
classes can be handled with their actual supremum norm. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
variable {X E : Type*}
variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
variable [MeasurableSpace X] [BorelSpace X] [SecondCountableTopology X]
variable [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]

lemma compact_integrable {Y G : Type*} [TopologicalSpace Y] [CompactSpace Y]
    [MeasurableSpace Y] [BorelSpace Y]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (μ : Measure Y) [IsFiniteMeasure μ] {f : Y → G} (hf : Continuous f) :
    Integrable f μ := hf.integrable_of_hasCompactSupport (HasCompactSupport.of_compactSpace f)

def sampleSum (F : X → E) {n : ℕ} (s : Fin n → X) : E := ∑ i,F (s i)
def signedSum (F : X → E) {n : ℕ} (ε : Fin n → Bool) (s : Fin n → X) : E :=
  ∑ i,cubeCoordinateSign (ε i) • F (s i)

lemma continuous_sampleSum {n : ℕ} {F : X → E} (hF : Continuous F) :
    Continuous (sampleSum (n:=n) F) := by unfold sampleSum; fun_prop
lemma continuous_signedSum {n : ℕ} {F : X → E} (hF : Continuous F) (ε : Fin n → Bool) :
    Continuous (signedSum F ε) := by unfold signedSum; fun_prop

lemma measurePreserving_signSwap (μ : Measure X) [IsProbabilityMeasure μ]
    {n : ℕ} (ε : Fin n → Bool) :
    MeasurePreserving (signSwap (α:=X) ε)
      ((Measure.pi (fun _ : Fin n => μ)).prod (Measure.pi (fun _ : Fin n => μ)))
      ((Measure.pi (fun _ : Fin n => μ)).prod (Measure.pi (fun _ : Fin n => μ))) := by
  let e := MeasurableEquiv.arrowProdEquivProdArrow X X (Fin n)
  have he := measurePreserving_arrowProdEquivProdArrow X X (Fin n) (fun _ => μ) (fun _ => μ)
  let f : Fin n → X × X → X × X := fun i p => if ε i then p else p.swap
  have hf (i : Fin n) : MeasurePreserving (f i) (μ.prod μ) (μ.prod μ) := by
    dsimp only [f]
    cases ε i
    · simpa only [Bool.false_eq_true, if_false] using (Measure.measurePreserving_swap (μ:=μ) (ν:=μ))
    · simp only [if_true]
      exact ⟨measurable_id,Measure.map_id⟩
  have hh := he.comp ((measurePreserving_pi (fun _ : Fin n => μ.prod μ)
    (fun _ : Fin n => μ.prod μ) hf).comp (he.symm e))
  convert hh using 1
  funext p
  apply Prod.ext <;> funext i <;> cases h : ε i <;> simp [e,f,signSwap,h,
    MeasurableEquiv.arrowProdEquivProdArrow,Function.comp_def]

lemma sampleSum_signSwap {n : ℕ} (F : X → E) (ε : Fin n → Bool)
    (p : (Fin n → X) × (Fin n → X)) :
    sampleSum F (signSwap ε p).1 - sampleSum F (signSwap ε p).2 =
      signedSum F ε p.1 - signedSum F ε p.2 := by
  unfold sampleSum signedSum
  rw [← Finset.sum_sub_distrib,← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  cases h : ε i <;> simp [signSwap,h,cubeCoordinateSign,sub_eq_add_neg,add_comm]

lemma integral_sampleSum (μ : Measure X) [IsProbabilityMeasure μ]
    {F : X → E} (hF : Continuous F) (n : ℕ) :
    (∫ s : Fin n → X,sampleSum F s ∂Measure.pi (fun _ => μ)) = (n:ℝ) • ∫ x,F x ∂μ := by
  unfold sampleSum
  rw [integral_finsetSum _ (fun i _ => compact_integrable _
    (show Continuous (fun s : Fin n → X => F (s i)) from hF.comp (continuous_apply i)))]
  have he (i : Fin n) : (∫ s : Fin n → X,F (s i) ∂Measure.pi (fun _ => μ)) = ∫ x,F x ∂μ := by
    have hm := measurePreserving_eval (fun _ : Fin n => μ) i
    have hi := integral_map hm.aemeasurable hF.aestronglyMeasurable
    rw [hm.map_eq] at hi
    exact hi.symm
  simp_rw [he]
  simp [Nat.cast_smul_eq_nsmul]


lemma compact_ghost_symmetrization (μ : Measure X) [IsProbabilityMeasure μ]
    {F : X → E} (hF : Continuous F) :
    (∫ x,‖F x-∫ y,F y ∂μ‖ ∂μ) ≤ ∫ x,∫ y,‖F x-F y‖ ∂μ ∂μ := by
  have hj : Continuous (fun p : X × X => ‖F p.1-F p.2‖) :=
    ((hF.comp continuous_fst).sub (hF.comp continuous_snd)).norm
  apply integral_mono (compact_integrable μ (hF.sub continuous_const).norm)
    (compact_integrable (μ.prod μ) hj).integral_prod_left
  intro x
  have he : F x-∫ y,F y ∂μ = ∫ y,F x-F y ∂μ := by
    rw [integral_sub (integrable_const _) (compact_integrable μ hF)]
    simp
  change ‖F x-∫ y,F y ∂μ‖ ≤ ∫ y,‖F x-F y‖ ∂μ
  rw [he]
  exact norm_integral_le_integral_norm _

lemma integral_finiteMean {Y I : Type*} [MeasurableSpace Y] [Fintype I]
    (μ : Measure Y) (f : I → Y → ℝ) (hf : ∀ i,Integrable (f i) μ) :
    (∫ y,finiteMean (fun i => f i y) ∂μ)=finiteMean (fun i => ∫ y,f i y ∂μ) := by
  unfold finiteMean
  rw [integral_div,integral_finsetSum _ (fun i _ => hf i)]

/-- Symmetrization under an arbitrary probability law, with the actual IID
product law and uniform independent signs. No finite-domain assumption. -/
theorem compact_rademacher_symmetrization (μ : Measure X) [IsProbabilityMeasure μ]
    {F : X → E} (hF : Continuous F) (n : ℕ) :
    (∫ s : Fin n → X,‖sampleSum F s-(n:ℝ) • ∫ x,F x ∂μ‖ ∂Measure.pi (fun _ => μ)) ≤
      2*∫ s : Fin n → X,finiteMean (fun ε : Fin n → Bool => ‖signedSum F ε s‖)
        ∂Measure.pi (fun _ => μ) := by
  let ν := Measure.pi (fun _ : Fin n => μ)
  have hFsum := continuous_sampleSum (n:=n) hF
  have hghost := compact_ghost_symmetrization ν hFsum
  rw [integral_sampleSum μ hF n] at hghost
  have hj : Continuous (fun p : (Fin n → X) × (Fin n → X) =>
      ‖sampleSum F p.1-sampleSum F p.2‖) :=
    ((hFsum.comp continuous_fst).sub (hFsum.comp continuous_snd)).norm
  have hsigned (ε : Fin n → Bool) :
      (∫ s,∫ t,‖sampleSum F s-sampleSum F t‖ ∂ν ∂ν) ≤
        2*∫ s,‖signedSum F ε s‖ ∂ν := by
    rw [← integral_prod _ (compact_integrable (ν.prod ν) hj)]
    have hmp := measurePreserving_signSwap μ ε
    let e : ((Fin n → X) × (Fin n → X)) ≃ᵐ ((Fin n → X) × (Fin n → X)) :=
      { toEquiv := signSwap ε
        measurable_toFun := hmp.measurable
        measurable_invFun := hmp.measurable }
    have hi := hmp.integral_comp' (f:=e)
      (fun p => ‖sampleSum F p.1-sampleSum F p.2‖)
    rw [← hi]
    simp_rw [show (e : ((Fin n → X) × (Fin n → X)) → _) = signSwap ε from rfl,
      sampleSum_signSwap]
    have hc := continuous_signedSum hF ε
    have hsub : Continuous (fun p : (Fin n → X) × (Fin n → X) =>
        ‖signedSum F ε p.1-signedSum F ε p.2‖) :=
      ((hc.comp continuous_fst).sub (hc.comp continuous_snd)).norm
    have hadd : Continuous (fun p : (Fin n → X) × (Fin n → X) =>
        ‖signedSum F ε p.1‖+‖signedSum F ε p.2‖) :=
      (hc.comp continuous_fst).norm.add (hc.comp continuous_snd).norm
    apply (integral_mono (compact_integrable _ hsub) (compact_integrable _ hadd)
      (fun p => norm_sub_le _ _)).trans_eq
    rw [integral_prod _ (compact_integrable _ hadd)]
    change (∫ s,∫ t,‖signedSum F ε s‖+‖signedSum F ε t‖ ∂ν ∂ν) = _
    simp_rw [integral_add (integrable_const _) (compact_integrable ν hc.norm)]
    simp only [integral_const]
    simp only [measureReal_univ_eq_one,one_smul]
    rw [integral_add (compact_integrable ν hc.norm) (integrable_const _),integral_const]
    simp only [measureReal_univ_eq_one,one_smul]
    ring
  have havg := finiteMean_mono hsigned
  rw [finiteMean_const,finiteMean_mul] at havg
  have hcomm := integral_finiteMean ν (fun ε s => ‖signedSum F ε s‖)
    (fun ε => compact_integrable ν (continuous_signedSum hF ε).norm)
  rw [← hcomm] at havg
  exact hghost.trans havg

end NeuralGeneralization.SquaredSampling
