import ActualChannelWidthMass
import FourierSeedNetworkAdapter
import RareSeedState
import ScalarPathScoreProgram
import TaggedScalarAppend

/-! An actual rare Fourier seed followed by an actual scalar path gives a
literal finite-width Gaussian-prior lower bound. -/
noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel

theorem taggedFourierPathNetwork_raw_mass {d N : ℕ} (hd : 1≤d) (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (f : BooleanFunction d) {θ A τ B S : ℝ}
    (hθ : 0<θ) (hθ1 : θ≤1)
    (p : TaggedScalarPath t
      (rareSeedSignal (fun x=>labelReal (f x)) (t/Real.sqrt d) θ)
      (rareSeedResidual (fun x=>labelReal (f x)) (t/Real.sqrt d) θ))
    (hterminal : p.terminal.1≤1)
    (hB : 1≤B) (hBseed : 1/Real.sqrt θ≤B) (hBpath : p.bound≤B)
    (hS : channelEntropyPrefix (fun j=>(klDiv (p.control j) (taggedGaussianReference 1)).toReal) p.length≤S)
    (hA : 0≤A) (hτ : 0<τ)
    (hbase : t^2*(θ*seedEntropyBudget d (t/Real.sqrt d))+p.cost≤A)
    (hwidth : finiteChannelWidthBudget (Fintype.card (Cube d)) p.length B S p.terminal.1
      (channelSlackProbability A τ) τ≤(N:ℝ)) :
    Real.exp (-(N:ℝ)*(A+τ)/t^2)≤(smallPrior d N p.length (t/Real.sqrt N)).real
      (marginEvent Real.tanh (1/2) f) := by
  let g : ClippingCube d→ℝ := fun x=>labelReal (f x)
  let σ : ℝ := t/Real.sqrt d
  let Q₀ := rareSeedLaw θ (seedGaussianReference σ) (actualFourierSeedLaw g σ)
  let P₀ : Measure (Bool×(Option (Fin d)→ℝ)) := rareSeedLaw θ (seedGaussianReference σ) (seedGaussianReference σ)
  have hg : ∃x,g x≠0 := by
    refine ⟨fun _=>true,?_⟩
    dsimp only [g]
    cases f (fun _=>true) <;> norm_num
  have hbool : ∀x,(g x)^2=1 := by intro x; dsimp only [g]; cases f x <;> norm_num
  have hσ : ((d:ℝ)+1)*σ^2≤2 := originalScale_noise_variance hd t ht.le ht1
  have hd0 : (0:ℝ)<d := by exact_mod_cast (show 0<d by omega)
  have hσ0 : σ≠0 := by dsimp [σ]; positivity
  letI := actualFourierSeedLaw_probability g σ hg hσ
  letI : IsProbabilityMeasure Q₀ := rareSeedLaw_probability θ _ _ hθ.le hθ1
  letI : IsProbabilityMeasure P₀ := rareSeedLaw_probability θ _ _ hθ.le hθ1
  letI (j : ℕ) : IsProbabilityMeasure (p.control j) := p.control_probability j
  have hseedlaw : P₀.map taggedSeedInput=Measure.pi fun _ : Fin (d+1)=>
      gaussianReal 0 (((N:ℝ)/d)*(t/Real.sqrt N)^2).toNNReal := by
    have he : σ^2=((N:ℝ)/d)*(t/Real.sqrt N)^2 := by
      rw [uniform_first_variance hN d t]
      dsimp [σ]
      rw [div_pow,Real.sq_sqrt hd0.le]
    have hvar : (⟨σ^2,sq_nonneg σ⟩ : ℝ≥0)=(((N:ℝ)/d)*(t/Real.sqrt N)^2).toNNReal := by
      apply NNReal.coe_injective
      simp only [←he,Real.coe_toNNReal _ (sq_nonneg σ)]
      rfl
    change (rareSeedLaw θ (Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 ⟨σ^2,sq_nonneg σ⟩)
      (Measure.pi fun _ : Option (Fin d)=>gaussianReal 0 ⟨σ^2,sq_nonneg σ⟩)).map taggedSeedInput=_
    rw [taggedSeedInput_reference θ hθ.le hθ1,hvar]
  have hkl := rareFourierSeed_kl_bound g σ θ hg hσ0 hσ hθ.le hθ1
  have hfinite : klDiv Q₀ P₀≠∞ := ne_top_of_le_ne_top ENNReal.ofReal_ne_top hkl
  have hseedCost : (klDiv Q₀ P₀).toReal≤θ*seedEntropyBudget d σ := by
    have hh := ENNReal.toReal_mono ENNReal.ofReal_ne_top hkl
    simpa only [ENNReal.toReal_ofReal (mul_nonneg hθ.le (seedEntropyBudget_nonneg d σ))] using hh
  have ha₀ (x : Cube d) : p.nominal (f x) 0=canonicalCompletion
      (∫z,rareSeedScore θ z*seedFeature taggedSeedInput x z ∂Q₀)
      (∫z,(seedFeature taggedSeedInput x z)^2 ∂Q₀) := by
    simp_rw [seedFeature_taggedSeedInput]
    rw [rareFourierSeed_canonical_moment g σ θ hg hbool hσ hθ hθ1]
    change WithLp.toLp 2 (labelReal (f x)*Real.sqrt (rareSeedSignal g σ θ),
      Real.sqrt (rareSeedResidual g σ θ))=_
    congr 1
    ext <;> simp [g,mul_comm]
  have hv := (p.state_pos p.length).1
  rw [p.state_terminal] at hv
  have hpathCost : t^2*(∑j : Fin p.length,(klDiv (p.control j) (taggedGaussianReference t)).toReal)+
      1/(8*p.terminal.1)=p.cost := by
    rw [←p.priorHiddenCost_eq_sum]
    rfl
  have htotal : t^2*((klDiv Q₀ P₀).toReal+
      (∑j : Fin p.length,(klDiv (p.control j) (taggedGaussianReference t)).toReal))+
      1/(8*p.terminal.1)≤A := by
    rw [mul_add,add_assoc,hpathCost]
    have hh := mul_le_mul_of_nonneg_left hseedCost (sq_nonneg t)
    dsimp [σ] at hh
    linarith
  have hP (j : ℕ) : (taggedGaussianReference t).map Prod.fst=gaussianReal 0 (t^2).toNNReal :=
    taggedGaussianReference_fst t
  have hR (j : ℕ) : (taggedGaussianReference 1).map Prod.fst=gaussianReal 0 1 := by
    simpa using taggedGaussianReference_fst 1
  exact actualUniformChannel_raw_mass_of_width hN ht ht1 Q₀ P₀ p.control
    (fun _=>taggedGaussianReference t) (fun _=>taggedGaussianReference 1)
    taggedSeedInput taggedSeedInput_measurable hseedlaw hfinite (fun _=>Prod.fst)
    (fun _=>measurable_fst) hP hR (rareSeedScore θ) p.score
    (measurable_rareSeedScore θ) p.score_measurable (rareSeedScore_memLp θ hθ Q₀) p.score_memLp
    (rareSeedScore_secondMoment θ _ _ hθ hθ1) p.score_unit p.control_priorKL (p.control_criticalKL ht)
    (fun j x=>p.nominal (f x) j) ha₀ (fun _ _=>rfl)
    p.length f hv hterminal (fun x=>p.nominal_terminal (f x)) hS hB
    (fun z=>(rareSeedScore_bound θ hθ z).trans hBseed)
    (fun j z=>(p.score_bound j z).trans hBpath) hA hτ htotal hwidth

#print axioms taggedFourierPathNetwork_raw_mass
end ConditionalNonpolynomial.Analytic
