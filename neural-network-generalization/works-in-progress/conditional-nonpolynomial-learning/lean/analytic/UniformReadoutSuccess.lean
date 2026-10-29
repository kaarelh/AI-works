import CriticalReadoutSuccess

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.NetworkReadout

theorem uniformReadout_output {H : Type*} {d N r : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (F : H→Weights d N r) (u : H→Fin N→ℝ)
    (h : H) (p : ℝ×(Fin N→ℝ)) (x : Cube d) :
    networkOutput Real.tanh (networkWithReadoutChannel (t/Real.sqrt N) F u (h,p)) x=
      (∑i,directionSplit (u h) p.1 p.2 i*(t*finalHidden Real.tanh (F h) x i))/(N:ℝ) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have he : (t/Real.sqrt (N:ℝ))/Real.sqrt N=t/(N:ℝ) := by
    rw [div_div,←sq,Real.sq_sqrt hn.le]
  unfold networkOutput networkWithReadoutChannel
  rw [finalHidden_from_split]
  change (∑i,((t/Real.sqrt (N:ℝ))/Real.sqrt N*directionSplit (u h) p.1 p.2 i)*
    finalHidden Real.tanh (F h) x i)=_
  rw [he]
  simp only [div_eq_mul_inv,Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- The readout success estimate applies to the literal network output. -/
theorem uniformReadout_conditional_success {H : Type*} {d N r : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (F : H→Weights d N r) (u : H→Fin N→ℝ) (h : H)
    (hu : ∑i,u h i^2=1) (f : BooleanFunction d)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hcorr : ∀x,Real.sqrt v*(1-κ/8)≤
      (∑i,u h i*signedHiddenFeatures f (F h) x i)/Real.sqrt N)
    (hwidth : 64*(Fintype.card (Cube d):ℝ)≤(N:ℝ)*κ^3) :
    1-κ/2≤(readoutControlLaw N (readoutChannelMean N (t^2*v) κ)).real
      {p | networkWithReadoutChannel (t/Real.sqrt N) F u (h,p)∈marginEvent Real.tanh (1/2) f} := by
  let E : Set (Fin N→ℝ) := {z | ∀x,1/2<(∑i,z i*(t*signedHiddenFeatures f (F h) x i))/N}
  have hE : MeasurableSet E := by
    change MeasurableSet {z : Fin N→ℝ | ∀x,1/2<(∑i,z i*(t*signedHiddenFeatures f (F h) x i))/N}
    simp only [Set.setOf_forall]
    exact MeasurableSet.iInter (fun x=>measurableSet_lt measurable_const (by fun_prop))
  have hm : Measurable (fun p : ℝ×(Fin N→ℝ)=>directionSplit (u h) p.1 p.2) := by
    unfold directionSplit; fun_prop
  have heq : {p | networkWithReadoutChannel (t/Real.sqrt N) F u (h,p)∈marginEvent Real.tanh (1/2) f}=
      (fun p : ℝ×(Fin N→ℝ)=>directionSplit (u h) p.1 p.2) ⁻¹' E := by
    ext p
    change (∀x,1/2<labelReal (f x)*networkOutput Real.tanh
      (networkWithReadoutChannel (t/Real.sqrt N) F u (h,p)) x) ↔ _
    change _ ↔ ∀x,1/2<(∑i,directionSplit (u h) p.1 p.2 i*(t*signedHiddenFeatures f (F h) x i))/N
    apply forall_congr'
    intro x
    rw [uniformReadout_output hN ht ht1 F u h p x]
    unfold signedHiddenFeatures
    rw [←mul_div_assoc,Finset.mul_sum]
    have hs : (∑i,labelReal (f x)*(directionSplit (u h) p.1 p.2 i*(t*finalHidden Real.tanh (F h) x i)))=
        ∑i,directionSplit (u h) p.1 p.2 i*(t*(labelReal (f x)*finalHidden Real.tanh (F h) x i)) := by
      apply Finset.sum_congr rfl
      intro i _
      ring
    rw [hs]
  rw [heq]
  have hv' : 0<t^2*v := mul_pos (sq_pos_of_pos ht) hv
  have hsqrt : Real.sqrt (t^2*v)=t*Real.sqrt v := by
    rw [Real.sqrt_mul (sq_nonneg t),Real.sqrt_sq ht.le]
  have hbound : ∀x i,|t*signedHiddenFeatures f (F h) x i|≤1 := by
    intro x i
    rw [abs_mul,abs_of_pos ht]
    calc
      _ ≤ t*1 := mul_le_mul_of_nonneg_left (signedHiddenFeatures_bound f (F h) x i) ht.le
      _ ≤ 1 := by simpa using ht1
  have hcorr' : ∀x,Real.sqrt (t^2*v)*(1-κ/8)≤
      (∑i,u h i*(t*signedHiddenFeatures f (F h) x i))/Real.sqrt N := by
    intro x
    rw [hsqrt]
    have hh := mul_le_mul_of_nonneg_left (hcorr x) ht.le
    calc
      _ = t*(Real.sqrt v*(1-κ/8)) := by ring
      _ ≤ t*((∑i,u h i*signedHiddenFeatures f (F h) x i)/Real.sqrt N) := hh
      _ = _ := by
        rw [←mul_div_assoc,Finset.mul_sum]
        congr 1
        apply Finset.sum_congr rfl
        intro i _
        ring
  have hh := readout_channel_success hN (u h) (fun x i=>t*signedHiddenFeatures f (F h) x i)
    hv' hκ hκ1 hbound hcorr' hwidth
  change 1-κ/2≤(shiftedReadoutLaw (u h) (readoutChannelMean N (t^2*v) κ)).real E at hh
  rw [←directionSplit_shifted_law (u h) hu (readoutChannelMean N (t^2*v) κ)] at hh
  simpa only [Measure.real,Measure.map_apply hm hE] using hh

theorem uniformReadout_history_success {H : Type*} [MeasurableSpace H]
    {d N r : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1) (Q : Measure H) [IsProbabilityMeasure Q]
    (F : H→Weights d N r) (hF : Measurable F)
    (u : H→Fin N→ℝ) (hu : Measurable u) (hnorm : ∀h,∑i,u h i^2=1)
    (f : BooleanFunction d) (G : Set H) (hG : MeasurableSet G)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hcorr : ∀h∈G,∀x,Real.sqrt v*(1-κ/8)≤
      (∑i,u h i*signedHiddenFeatures f (F h) x i)/Real.sqrt N)
    (hwidth : 64*(Fintype.card (Cube d):ℝ)≤(N:ℝ)*κ^3) :
    Q.real G-κ/2≤(Q.prod (readoutControlLaw N (readoutChannelMean N (t^2*v) κ))).real
      (networkWithReadoutChannel (t/Real.sqrt N) F u ⁻¹' marginEvent Real.tanh (1/2) f) := by
  have hE := (isOpen_marginEvent NeuralGeneralization.TanhDifferential.continuous_tanh (1/2) f).measurableSet.preimage
    (networkWithReadoutChannel_measurable (t/Real.sqrt N) F hF u hu)
  apply product_success_step Q (readoutControlLaw N (readoutChannelMean N (t^2*v) κ)) G _ hG hE
    (by positivity : 0≤κ/2) (by linarith : κ/2≤1)
  intro h hh
  exact uniformReadout_conditional_success hN ht ht1 F u h (hnorm h) f hv hκ hκ1 (hcorr h hh) hwidth

#print axioms uniformReadout_history_success
end ConditionalNonpolynomial.Analytic
