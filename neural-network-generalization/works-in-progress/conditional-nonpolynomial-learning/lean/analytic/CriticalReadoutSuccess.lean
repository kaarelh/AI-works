import NetworkReadoutPlanting
import ControlHistorySuccess
import ChannelNetworkRecursion

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.NetworkReadout

theorem finalHidden_from_split {d N r : ℕ} (w : Weights d N r) (a : Fin N→ℝ)
    (x : Cube d) : finalHidden Real.tanh (assemble ((weightSplit d N r w).1) a) x=
      finalHidden Real.tanh w x := by
  have he : assemble ((weightSplit d N r w).1) ((weightSplit d N r w).2)=w := by
    rw [←weightSplit_symm]
    exact (weightSplit d N r).symm_apply_apply w
  calc
    _ = finalHidden Real.tanh (assemble ((weightSplit d N r w).1) 0) x := finalHidden_assemble _ _ _ _
    _ = finalHidden Real.tanh (assemble ((weightSplit d N r w).1) ((weightSplit d N r w).2)) x :=
      (finalHidden_assemble _ _ _ _).symm
    _ = _ := congrArg (fun v=>finalHidden Real.tanh v x) he

theorem criticalReadout_output {H : Type*} {d N r : ℕ} (hN : 0<N)
    (F : H→Weights d N r) (u : H→Fin N→ℝ)
    (h : H) (p : ℝ×(Fin N→ℝ)) (x : Cube d) :
    networkOutput Real.tanh (networkWithReadoutChannel (1/Real.sqrt N) F u (h,p)) x=
      (∑i,directionSplit (u h) p.1 p.2 i*finalHidden Real.tanh (F h) x i)/(N:ℝ) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have he : (1/Real.sqrt (N:ℝ))/Real.sqrt N=1/(N:ℝ) := by
    rw [div_div,←sq,Real.sq_sqrt hn.le]
  unfold networkOutput networkWithReadoutChannel
  rw [finalHidden_from_split]
  change (∑i,((1/Real.sqrt (N:ℝ))/Real.sqrt N*directionSplit (u h) p.1 p.2 i)*
    finalHidden Real.tanh (F h) x i)=_
  rw [he]
  simp only [mul_assoc,←Finset.mul_sum,one_div,div_eq_mul_inv,mul_comm,one_mul]

theorem networkWithReadoutChannel_measurable {H : Type*} [MeasurableSpace H] {d N r : ℕ}
    (σ : ℝ) (F : H→Weights d N r) (hF : Measurable F)
    (u : H→Fin N→ℝ) (hu : Measurable u) :
    Measurable (networkWithReadoutChannel σ F u) := by
  have he : networkWithReadoutChannel σ F u=
      (weightSplit d N r).symm ∘ (fun p : H×(ℝ×(Fin N→ℝ))=>
        ((weightSplit d N r (F p.1)).1,
          physicalReadout σ (directionSplit (u p.1) p.2.1 p.2.2))) := by
    funext p
    simp only [Function.comp_apply,weightSplit_symm,networkWithReadoutChannel]
  rw [he]
  apply (weightSplit d N r).symm.measurable.comp
  apply (((weightSplit d N r).measurable.comp (hF.comp measurable_fst)).fst).prodMk
  unfold physicalReadout directionSplit
  fun_prop

def signedHiddenFeatures {d N r : ℕ} (f : BooleanFunction d) (w : Weights d N r)
    (x : Cube d) (i : Fin N) : ℝ := labelReal (f x)*finalHidden Real.tanh w x i

theorem signedHiddenFeatures_bound {d N r : ℕ} (f : BooleanFunction d)
    (w : Weights d N r) (x : Cube d) (i : Fin N) : |signedHiddenFeatures f w x i|≤1 := by
  rw [signedHiddenFeatures,abs_mul,abs_labelReal,one_mul]
  exact NeuralGeneralization.TowerNetwork.finalHidden_tanh_abs_le_one w x i

/-- The readout success estimate applies to the literal network output. -/
theorem criticalReadout_conditional_success {H : Type*} {d N r : ℕ} (hN : 0<N)
    (F : H→Weights d N r) (u : H→Fin N→ℝ) (h : H)
    (hu : ∑i,u h i^2=1) (f : BooleanFunction d)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hcorr : ∀x,Real.sqrt v*(1-κ/8)≤
      (∑i,u h i*signedHiddenFeatures f (F h) x i)/Real.sqrt N)
    (hwidth : 64*(Fintype.card (Cube d):ℝ)≤(N:ℝ)*κ^3) :
    1-κ/2≤(readoutControlLaw N (readoutChannelMean N v κ)).real
      {p | networkWithReadoutChannel (1/Real.sqrt N) F u (h,p)∈marginEvent Real.tanh (1/2) f} := by
  let E : Set (Fin N→ℝ) := {z | ∀x,1/2<(∑i,z i*signedHiddenFeatures f (F h) x i)/N}
  have hE : MeasurableSet E := by
    change MeasurableSet {z : Fin N→ℝ | ∀x,1/2<(∑i,z i*signedHiddenFeatures f (F h) x i)/N}
    simp only [Set.setOf_forall]
    exact MeasurableSet.iInter (fun x=>measurableSet_lt measurable_const (by fun_prop))
  have hm : Measurable (fun p : ℝ×(Fin N→ℝ)=>directionSplit (u h) p.1 p.2) := by
    unfold directionSplit; fun_prop
  have heq : {p | networkWithReadoutChannel (1/Real.sqrt N) F u (h,p)∈marginEvent Real.tanh (1/2) f}=
      (fun p : ℝ×(Fin N→ℝ)=>directionSplit (u h) p.1 p.2) ⁻¹' E := by
    ext p
    change (∀x,1/2<labelReal (f x)*networkOutput Real.tanh
      (networkWithReadoutChannel (1/Real.sqrt N) F u (h,p)) x) ↔ _
    change _ ↔ ∀x,1/2<(∑i,directionSplit (u h) p.1 p.2 i*signedHiddenFeatures f (F h) x i)/N
    apply forall_congr'
    intro x
    rw [criticalReadout_output hN F u h p x]
    unfold signedHiddenFeatures
    rw [←mul_div_assoc,Finset.mul_sum]
    have hs : (∑i,labelReal (f x)*(directionSplit (u h) p.1 p.2 i*finalHidden Real.tanh (F h) x i))=
        ∑i,directionSplit (u h) p.1 p.2 i*(labelReal (f x)*finalHidden Real.tanh (F h) x i) := by
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [hs]
  rw [heq]
  have hh := readout_channel_success hN (u h) (signedHiddenFeatures f (F h)) hv hκ hκ1
    (signedHiddenFeatures_bound f (F h)) hcorr hwidth
  change 1-κ/2≤(shiftedReadoutLaw (u h) (readoutChannelMean N v κ)).real E at hh
  rw [←directionSplit_shifted_law (u h) hu (readoutChannelMean N v κ)] at hh
  simpa only [Measure.real,Measure.map_apply hm hE] using hh

theorem criticalReadout_history_success {H : Type*} [MeasurableSpace H]
    {d N r : ℕ} (hN : 0<N) (Q : Measure H) [IsProbabilityMeasure Q]
    (F : H→Weights d N r) (hF : Measurable F)
    (u : H→Fin N→ℝ) (hu : Measurable u) (hnorm : ∀h,∑i,u h i^2=1)
    (f : BooleanFunction d) (G : Set H) (hG : MeasurableSet G)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hcorr : ∀h∈G,∀x,Real.sqrt v*(1-κ/8)≤
      (∑i,u h i*signedHiddenFeatures f (F h) x i)/Real.sqrt N)
    (hwidth : 64*(Fintype.card (Cube d):ℝ)≤(N:ℝ)*κ^3) :
    Q.real G-κ/2≤(Q.prod (readoutControlLaw N (readoutChannelMean N v κ))).real
      (networkWithReadoutChannel (1/Real.sqrt N) F u ⁻¹' marginEvent Real.tanh (1/2) f) := by
  have hE := (isOpen_marginEvent NeuralGeneralization.TanhDifferential.continuous_tanh (1/2) f).measurableSet.preimage
    (networkWithReadoutChannel_measurable (1/Real.sqrt N) F hF u hu)
  apply product_success_step Q (readoutControlLaw N (readoutChannelMean N v κ)) G _ hG hE
    (by positivity : 0≤κ/2) (by linarith : κ/2≤1)
  intro h hh
  exact criticalReadout_conditional_success hN F u h (hnorm h) f hv hκ hκ1 (hcorr h hh) hwidth

#print axioms criticalReadout_history_success
end ConditionalNonpolynomial.Analytic
