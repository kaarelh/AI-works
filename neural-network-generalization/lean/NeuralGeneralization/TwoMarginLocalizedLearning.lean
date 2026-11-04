import NeuralGeneralization.TwoMarginLocalizedPosterior
import NeuralGeneralization.TwoMarginCompression
import NeuralGeneralization.RobustLocalizedLearning
import NeuralGeneralization.RobustMaskedComparison
import NeuralGeneralization.RobustConditionedCompression
import NeuralGeneralization.RobustMaskedStatistics

/-! Deterministic learning on common validation and masked-loss events for
the exact localized union posterior, uniformly in width and Gaussian scale. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.TwoMarginTransport.Localized
open ConcreteModel RobustPosterior RobustStatistics RobustConfidence FiniteUnionConditioning
variable {d C N r M m n : ℕ}

abbrev componentCost := RobustLocalized.componentCost
abbrev componentCost_nonneg := RobustLocalized.componentCost_nonneg

/-- The law remains a raw Gaussian conditioned on a union. Its disjoint
components appear only in the proof of the bound. -/
theorem risk_on_common_events (hd : 0 < d) (T : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    (B : Fin M → Set (Cube d)) (j0 : Fin M) (hzero : B j0 = ∅)
    {c ρ σ ε : ℝ} (hc : 0 < c) (hρ : 0 ≤ ρ) (hσ : 0 < σ)
    (hscale : (N:ℝ)*σ^2 ≤ 1) (hε : 0 < ε) (hε1 : ε < 1)
    (D : Measure (Cube d)) [IsProbabilityMeasure D]
    (V : Fin m → Cube d) (S : Fin n → Cube d) (hn : 0 < n)
    (hcoverage : ∀ j,D.real (B j) ≤ empiricalLoss (exceptionLoss B) V j+ε/12)
    (hlearn : ∀ j,S ∈ generalizationEvent D
      (maskedCandidateLoss (B j) T.computes
        (RobustConditioned.candidate d r (componentCost d C r M c ε) c ε)) n (ε/12)) :
    gibbsMarginRisk D (posterior (N := N) (r := r) B c ρ σ T.computes V S)
      (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  classical
  letI : Nonempty (Fin M) := ⟨j0⟩
  have hM : 0 < M := Nat.zero_lt_of_lt j0.isLt
  have hC : 0 < C := Nat.pos_of_ne_zero (fun hz => by simpa [hz] using T.constant.isLt)
  have hN := hC.trans_le hCN
  have hN1 : (1:ℝ) ≤ N := by exact_mod_cast hN
  have hs1 : σ^2 ≤ 1 := by nlinarith [sq_nonneg σ]
  let μ := smallPrior d N r σ
  let A := witnessEvent (N := N) (r := r) B c ρ T.computes V S
  let E := disjointed A
  have hA : ∀ j,MeasurableSet (A j) := measurable_witnessEvent B hc ρ T.computes V S
  have hE : ∀ j,MeasurableSet (E j) := measurable_disjointed A hA
  have hdis : Pairwise (fun i j => Disjoint (E i) (E j)) := disjoint_disjointed A
  have hunion : (⋃ j,E j) = posteriorEvent B c ρ T.computes V S := iUnion_disjointed
  have hmass : Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤ μ.real (⋃ j,E j) := by
    rw [hunion]
    exact target_mass hd T hCN B j0 hzero hc hρ hσ hscale V S
  have hpos : 0 < μ.real (⋃ j,E j) := (Real.exp_pos _).trans_le hmass
  let K := componentCost d C r M c ε
  have hK := componentCost_nonneg d C r hM c hε hε1
  let risk := fun j => gibbsMarginRisk D (cond μ (E j))
    (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4)
  have hupper (j : Fin M) : risk j ≤ 1 := by
    by_cases hz : μ (E j) = 0
    · simp [risk,gibbsMarginRisk,cond_eq_zero_of_meas_eq_zero hz]
    · letI := cond_isProbabilityMeasure hz
      apply (integral_mono (integrable_finite_domain D _) (integrable_const (1:ℝ))
        (fun x => measureReal_le_one)).trans_eq
      simp
  have hgood (j : Fin M)
      (hj : (ε/12)/Fintype.card (Fin M) ≤ μ.real (E j)/μ.real (⋃ i,E i)) :
      risk j ≤ ρ+5*(ε/12) := by
    have hmj : Real.exp (-K/σ^2) ≤ μ.real (E j) := by
      simpa only [K,componentCost,RobustLocalized.componentCost,Fintype.card_fin] using retained_mass μ E (sq_pos_of_pos hσ) hs1
        (show 0 < ε/12 by positivity) (show ε/12 ≤ 1 by linarith) hmass j hj
    let Q := cond μ (E j)
    let Q' := cond μ (E j ∩ readoutCap (RobustConditioned.cap K ε))
    obtain ⟨hQ,hQ',hKL,hsupport,hrestore⟩ := RobustConditioned.retained_inputs hd hN hK hc hσ hscale hε hε1 (E j) (hE j) hmj
    letI : IsProbabilityMeasure Q := hQ
    letI : IsProbabilityMeasure Q' := hQ'
    obtain ⟨Γ,hΓ,π,hfail⟩ := TwoMarginTransport.pointwise_compression hd hN hK hc hε hε1 hσ hscale Q' hKL
      (hsupport.mono fun _ hw => hw.2)
    letI : IsProbabilityMeasure Γ := hΓ
    have hnull (x : Cube d) (hx : x ∉ B j) : Q'.real {w | ¬ atInput Real.tanh c w x} = 0 := by
      apply cond_null_of_disjoint μ _ _ ((hE j).inter (measurable_readoutCap _))
      apply Set.disjoint_left.mpr
      intro w hw hbad
      exact hbad ((disjointed_subset A j hw.1).2.1 x hx)
    have htrain (i : Fin n) : Q'.real {w | labelReal (T.computes (S i))*networkOutput Real.tanh w (S i) ≤ 1/2} = 0 := by
      apply cond_null_of_disjoint μ _ _ ((hE j).inter (measurable_readoutCap _))
      apply Set.disjoint_left.mpr
      intro w hw hbad
      exact (not_le_of_gt ((disjointed_subset A j hw.1).2.2 i)) hbad
    have hfreq : empiricalLoss (exceptionLoss B) V j ≤ ρ := by
      have hcellpos := (Real.exp_pos _).trans_le hmj
      have hne : (E j).Nonempty := by
        by_contra hn
        have he := Set.not_nonempty_iff_eq_empty.mp hn
        rw [he,measureReal_empty] at hcellpos
        exact (lt_irrefl 0) hcellpos
      obtain ⟨w,hw⟩ := hne
      exact (disjointed_subset A j hw).1
    have hh := rule.masked_posterior_margin_risk_on_event D (B j) T.computes
      (RobustConditioned.candidate d r K c ε) hn (show 0 ≤ ε/12 by positivity) S (hlearn j)
      Q Q' Γ (networkOutput Real.tanh) (fun x => (continuous_networkOutput tanh_continuous x).measurable) π
      (fun x hx => by simpa only [hnull x hx,add_zero] using hfail x) htrain
      (fun x => hrestore {w | labelReal (T.computes x)*networkOutput Real.tanh w x ≤ 1/4})
    change risk j ≤ _ at hh
    linarith [hcoverage j]
  have hmix : gibbsMarginRisk D (posterior (N := N) (r := r) B c ρ σ T.computes V S)
      (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) =
      ∑ j,(μ.real (E j)/μ.real (⋃ i,E i))*risk j := by
    unfold gibbsMarginRisk posterior
    rw [← hunion]
    change (∫ x,(cond μ (⋃ j,E j)).real
      {w | labelReal (T.computes x)*networkOutput Real.tanh w x ≤ 1/4} ∂D) = _
    have hid (x : Cube d) := cond_partition μ E hE hdis
      {w | labelReal (T.computes x)*networkOutput Real.tanh w x ≤ 1/4}
      (measurableSet_le ((continuous_networkOutput tanh_continuous x).measurable.const_mul _) measurable_const)
    simp_rw [hid]
    rw [integral_finsetSum]
    · simp only [integral_const_mul,risk,gibbsMarginRisk]
    · intro j _
      exact (integrable_finite_domain D _).const_mul _
  rw [hmix]
  have hh := weighted_restore μ E hE hdis (show 0 ≤ ε/12 by positivity)
    (show 0 ≤ ρ+5*(ε/12) by positivity) hpos risk hupper hgood
  linarith

end NeuralGeneralization.TwoMarginTransport.Localized
