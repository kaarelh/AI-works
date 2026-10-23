import NeuralGeneralization.BatchTwoOnlineMeanFieldExactSampling
import NeuralGeneralization.BatchTwoOnlineMeanFieldExactCount

/-! Exact finite description of every good actual mean-field draw. -/
noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators
open MeasureTheory
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel GaussianAngularPrice GaussianFieldTilt CovarianceFactor TanhDifferential
open GaussianTowerConstruction TowerNetwork IdealTowerTransport MeanFieldReadout
open MeanFieldCoefficientSequence

theorem exists_finite_tower_exact {d r : ℕ} (hd : 0<d) {K : ℝ} (hK : 0<K)
    (R Γ : ℕ→Cube d→Cube d→ℝ)
    (hbase : ∀x y,gram (R 0) x y=gram (inputMatrix d) x y)
    (hstep : ∀s,s<r→∀x y,gram (R (s+1)) x y=tiltedMoment (R s) (Γ s) x y)
    (hΓ : ∀s,s≤r→couplingMass (Γ s)≤maxTilt r K) :
    ∃w : Weights d (compressedWidth d r K) r,
      (∀i,|w i|≤compressedBound d r K) ∧
      ∀x y,|finalCovariance Real.tanh w x y-tiltedMoment (R r) (Γ r) x y|≤
        (r+1:ℝ)*(8*(1+maxTilt r K)^2)^r*covariancePrecision r K := by
  have hN:=compressedWidth_pos d r hK
  have hG:0≤maxTilt r K:=(layerBudget_pos r hK 1).le
  have hη:0≤covariancePrecision r K:=(covariancePrecision_pos r hK).le
  have hB:0≤compressedBound d r K:=by linarith [compressedBound_ge_one d r K]
  cases r with
  | zero=>
    simpa using exists_input_covariance hd hN (R 0) (Γ 0) hG hη hB (hΓ 0 le_rfl)
      hbase (input_sampling_budget d 0 hK)
  | succ r=>
    exact exists_finite_tower hd hN R Γ hG hη hB hbase
      (input_sampling_budget d (r+1) hK) (hidden_sampling_budget d (r+1) (by omega) hK)
      (r+1) hΓ hstep

theorem mem_functions_of_tower {d r : ℕ} (hd : 0<d) {K : ℝ} (hK : 0<K)
    (R Γ : ℕ→Cube d→Cube d→ℝ) (β : Cube d→ℝ) (f : BooleanFunction d)
    (hbase : ∀x y,gram (R 0) x y=gram (inputMatrix d) x y)
    (hstep : ∀s,s<r→∀x y,gram (R (s+1)) x y=tiltedMoment (R s) (Γ s) x y)
    (hΓ : ∀s,s≤r→couplingMass (Γ s)≤maxTilt r K)
    (hβ : (∑x,|β x|)≤4*K)
    (hmargin : ∀x,(7/8:ℝ)≤labelReal (f x)*∑y,β y*tiltedMoment (R r) (Γ r) x y) :
    f∈functions d r K := by
  obtain ⟨w,hw,hcov⟩:=exists_finite_tower_exact hd hK R Γ hbase hstep hΓ
  let v:=withReadout w (covarianceReadout Real.tanh w β)
  apply mem_representedFunctions.mpr
  refine ⟨v,?_,?_⟩
  · intro x
    have herror:=TowerCompression.covariance_action_difference_bound (finalCovariance Real.tanh w)
      (tiltedMoment (R r) (Γ r)) β
      (show 0≤(r+1:ℝ)*(8*(1+maxTilt r K)^2)^r*covariancePrecision r K by
        exact mul_nonneg (by positivity) (covariancePrecision_pos r hK).le) hβ hcov x
    rw [covariancePrecision_error r hK] at herror
    have hsigned:|labelReal (f x)*(networkOutput Real.tanh v x-
        ∑y,β y*tiltedMoment (R r) (Γ r) x y)|≤1/8:=by
      rw [abs_mul,abs_labelReal,one_mul]
      exact (covarianceReadout_output Real.tanh w β x) ▸ herror
    have hm:=hmargin x
    change (1/2:ℝ)<labelReal (f x)*networkOutput Real.tanh v x
    nlinarith [(abs_le.mp hsigned).1]
  · intro i
    rcases i with ij | (sij | j)
    · exact hw (.inl ij)
    · exact hw (.inr (.inl sij))
    · exact (covarianceReadout_bound w β hβ (i:=j)).trans (compressedBound_readout d r K)

theorem good_network_mem_functions {d N r : ℕ} (hd : 0<d) (hN : 0<N) {K : ℝ} (hK : 0<K)
    (w : Weights d N r) (f : BooleanFunction d)
    (hmargin : w∈marginEvent Real.tanh (1/2) f)
    (henergy : (N:ℝ)*(∑i,w (.inr (.inr i))^2)≤K)
    (hgood : MeanFieldGoodEvent.GoodHidden d N r (fun s=>layerBudget r K (s+1)) K w) :
    f∈functions d r K := by
  classical
  obtain ⟨Γ,hΓ,hcert⟩:=MeanFieldCertificateExtraction.exists_covariance_certificates hN
    (fun s=>layerBudget r K (s+1)) K r w (fun s hs=>layerBudget_pos r hK (s+1)) hgood
  obtain ⟨A₀,hA₀⟩:=gram_has_square_factor (coefficient w 0)
  let R:=idealTower A₀ Γ
  obtain ⟨β,hβ,hβmargin⟩:=exists_unit_margin_dual hN w f hmargin henergy
  have hcov:∀x y,|finalCovariance Real.tanh w x y-tiltedMoment (R r) (Γ r) x y|≤1/(32*K):=by
    intro x y
    rw [←gram_coefficient_final hN w x y]
    exact idealTower_terminal_error (coefficient w) A₀ Γ hK hA₀ hΓ hcert x y
  have hmargin':=transported_margin (finalCovariance Real.tanh w)
    (tiltedMoment (R r) (Γ r)) β f hK hβ hβmargin hcov
  apply mem_functions_of_tower hd hK R Γ β f
  · intro x y
    exact hA₀ x y
  · intro s hs x y
    exact idealTower_step A₀ Γ s x y
  · intro s hs
    exact (hΓ s hs).trans (layerBudget_le_max r K (by omega))
  · exact hβ
  · exact hmargin'

theorem functions_card_le_exp (d r : ℕ) {K : ℝ} (hK : 0<K) :
    ((functions d r K).card:ℝ)≤Real.exp (capacity d r K) :=
  representedFunctions_count d (compressedWidth d r K) r (compressedWidth_pos d r hK)
    (compressedBound_ge_one d r K)

def goodWeights (d N r : ℕ) (K : ℝ) : Set (Weights d N r) :=
  {w|MeanFieldGoodEvent.GoodHidden d N r (fun s=>layerBudget r K (s+1)) K w ∧
    (N:ℝ)*(∑i,w (.inr (.inr i))^2)≤K}

theorem excluded_mass_le_bad_event {d N r : ℕ} (hd : 0<d) (hN : 0<N) {K : ℝ} (hK : 0<K)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ] :
    (∑f∈Finset.univ\functions d r K,functionMass Real.tanh (1/2) μ f)≤
      μ.real (goodWeights d N r K)ᶜ := by
  classical
  let A:=Finset.univ\functions d r K
  have heq:μ.real (⋃f∈A,marginEvent Real.tanh (1/2) f)=
      ∑f∈A,functionMass Real.tanh (1/2) μ f:=by
    exact measureReal_biUnion_finset
      (fun f hf g hg hfg=>marginEvents_disjoint Real.tanh (by norm_num) hfg)
      (fun f hf=>(isOpen_marginEvent tanh_continuous (1/2) f).measurableSet)
  rw [←heq]
  apply measureReal_mono _ (measure_ne_top μ _)
  intro w hw hgood
  obtain ⟨f,hf,hwf⟩:=Set.mem_iUnion₂.mp hw
  exact (Finset.mem_sdiff.mp hf).2 (good_network_mem_functions hd hN hK w f hwf hgood.2 hgood.1)

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
