import ScalarChannelEmpirical
import ControlHistorySuccess

/-! The actual recursive empirical-moment event for a finite scalar channel.
Its probability is obtained by integration over independent row sources; the
events themselves can depend on the complete previous history. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.BatchTwoContinuousDepthCritical

variable {A Ω J : Type*} [MeasurableSpace A] [MeasurableSpace Ω] [Fintype J]

theorem measurableSet_parametricMomentEvent (Q : Measure Ω) [IsProbabilityMeasure Q]
    (F : J→A→Ω→ℝ) (hF : ∀j,Measurable (fun p : A×Ω=>F j p.1 p.2))
    (α : ℝ) (N : ℕ) :
    MeasurableSet {p : A×(Fin N→Ω) | p.2∈finiteMomentEvent Q (fun j=>F j p.1) α N} := by
  change MeasurableSet {p : A×(Fin N→Ω) |
    ∀j,|rowAverage (F j p.1) p.2-∫z,F j p.1 z ∂Q|<α}
  simp only [Set.setOf_forall]
  apply MeasurableSet.iInter
  intro j
  have hmean : Measurable (fun a=>∫z,F j a z ∂Q) :=
    (hF j).stronglyMeasurable.integral_prod_right.measurable
  have hsample (i : Fin N) : Measurable (fun p : A×(Fin N→Ω)=>F j p.1 (p.2 i)) :=
    (hF j).comp (measurable_fst.prodMk ((measurable_pi_apply i).comp measurable_snd))
  apply measurableSet_lt _ measurable_const
  unfold rowAverage
  exact (((Finset.measurable_sum Finset.univ (fun i _=>hsample i)).div_const (N:ℝ)).sub
    (hmean.comp measurable_fst)).abs

variable {H Ω X : Type} [MeasurableSpace H] [MeasurableSpace Ω] [Fintype X]

def channelGoodHistory (Q : ℕ→Measure Ω) (b : ℕ→Ω→ℝ)
    {N : ℕ} (f : (n : ℕ)→ControlHistory H (Fin N→Ω) n→X→Ω→ℝ)
    (G₀ : Set H) (α : ℝ) : (n : ℕ)→Set (ControlHistory H (Fin N→Ω) n)
  | 0 => G₀
  | n+1 => {p | p.1∈channelGoodHistory Q b f G₀ α n ∧
      p.2∈finiteMomentEvent (Q n) (channelObservables (b n) (f n p.1)) α N}

theorem measurableSet_channelGoodHistory (Q : ℕ→Measure Ω)
    [∀n,IsProbabilityMeasure (Q n)] (b : ℕ→Ω→ℝ) (hb : ∀n,Measurable (b n))
    {N : ℕ} (f : (n : ℕ)→ControlHistory H (Fin N→Ω) n→X→Ω→ℝ)
    (hf : ∀n x,Measurable (fun p : ControlHistory H (Fin N→Ω) n×Ω=>f n p.1 x p.2))
    (G₀ : Set H) (hG₀ : MeasurableSet G₀) (α : ℝ) (n : ℕ) :
    MeasurableSet (channelGoodHistory Q b f G₀ α n) := by
  induction n with
  | zero => exact hG₀
  | succ n ih =>
      apply MeasurableSet.inter (ih.preimage measurable_fst)
      apply measurableSet_parametricMomentEvent (Q n)
        (fun j h z=>channelObservables (b n) (f n h) j z)
      rintro (_ | (x | x))
      · exact ((hb n).comp measurable_snd).pow_const 2
      · exact ((hb n).comp measurable_snd).mul (hf n x)
      · exact (hf n x).pow_const 2

theorem channelGoodHistory_probability (μ : Measure H) [IsProbabilityMeasure μ]
    (Q : ℕ→Measure Ω) [∀n,IsProbabilityMeasure (Q n)]
    (b : ℕ→Ω→ℝ) (hb : ∀n,Measurable (b n))
    {N : ℕ} (hN : 0<N)
    (f : (n : ℕ)→ControlHistory H (Fin N→Ω) n→X→Ω→ℝ)
    (hf : ∀n x,Measurable (fun p : ControlHistory H (Fin N→Ω) n×Ω=>f n p.1 x p.2))
    (B κ : ℕ→ℝ) (hB : ∀n,1≤B n)
    (hbB : ∀n z,|b n z|≤B n) (hfB : ∀n h x z,|f n h x z|≤1)
    (hκ : ∀n,0≤κ n) (hκ1 : ∀n,κ n≤1)
    {α η : ℝ} (hα : 0<α)
    (hwidth : ∀n,(1+2*(Fintype.card X:ℝ))*(B n)^4≤κ n*((N:ℝ)*α^2))
    (G₀ : Set H) (hG₀ : MeasurableSet G₀) (hinit : 1-η≤μ.real G₀) (n : ℕ) :
    1-η-(∑j : Fin n,κ j)≤
      (controlHistoryLaw μ (fun j=>Measure.pi fun _ : Fin N=>Q j) n).real
        (channelGoodHistory Q b f G₀ α n) := by
  apply controlHistory_success μ (fun j=>Measure.pi fun _ : Fin N=>Q j)
    (channelGoodHistory Q b f G₀ α)
    (measurableSet_channelGoodHistory Q b hb f hf G₀ hG₀ α)
    κ hκ hκ1 hinit
  intro j h hh
  have hfj (x : X) : Measurable (f j h x) :=
    (hf j x).comp (measurable_const.prodMk measurable_id)
  have hs := scalar_channel_moment_probability (Q j) (b j) (f j h) (hb j)
    hfj (hB j) (hbB j) (hfB j h) hN hα (hwidth j)
  have heq : Prod.mk h ⁻¹' channelGoodHistory Q b f G₀ α (j+1)=
      finiteMomentEvent (Q j) (channelObservables (b j) (f j h)) α N := by
    ext w
    simp only [Set.mem_preimage,channelGoodHistory,Set.mem_setOf_eq,hh,true_and]
  rw [heq]
  exact hs

#print axioms channelGoodHistory_probability
end ConditionalNonpolynomial.Analytic
