import NeuralGeneralization.BatchTwoActivationSpectralNetwork
import NeuralGeneralization.BatchTwoActivationTargetMass

/-! Bounded-width total-energy branch for arbitrary zero-at-zero Lipschitz
activations. The actual Gaussian energy law and finite common function class
are used; no compression theorem is required in this branch. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

variable {d N r:ℕ} {φ:ℝ→ℝ} {ℓ σ J:ℝ}

theorem energyFunctions_complement_mass_le_cost_tail (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ)
    (μ:Measure (Weights d N r)) [IsFiniteMeasure μ]:
    (∑f∈Finset.univ\energyFunctions d r φ J,functionMass φ (1/2) μ f)≤
      μ.real {w|J≤weightedSquaredNorm w}:=by
  classical
  let A:=Finset.univ\energyFunctions d r φ J
  have heq:μ.real (⋃f∈A,marginEvent φ (1/2) f)=∑f∈A,functionMass φ (1/2) μ f:=by
    exact measureReal_biUnion_finset
      (fun f hf g hg hfg=>marginEvents_disjoint φ (by norm_num) hfg)
      (fun f _=>(isOpen_marginEvent (zeroLipschitzActivation_continuous hφ hℓ) (1/2) f).measurableSet)
  rw [←heq]
  apply measureReal_mono _ (measure_ne_top μ _)
  intro w hw
  obtain ⟨f,hf,hwf⟩:=Set.mem_iUnion₂.mp hw
  by_contra hn
  have hcost:weightedSquaredNorm w≤J:=(lt_of_not_ge hn).le
  exact (Finset.mem_sdiff.mp hf).2 (Finset.mem_filter.mpr
    ⟨Finset.mem_univ _,N,hN,w,hcost,fun x=>(hwf x).le⟩)

theorem smallPrior_total_energy_tail (hd:0<d) (hN:0<N) (hσ:0<σ)
    (hJ:8*(Fintype.card (WeightIndex d N r):ℝ)*σ^2≤J):
    (smallPrior d N r σ).real {w|J≤weightedSquaredNorm w}≤Real.exp (-J/(4*σ^2)):=by
  have hh:=smallPrior_whiten_subfamily_tail hd hN hσ (id:WeightIndex d N r→WeightIndex d N r)
    Function.injective_id J hJ
  have he (w:Weights d N r):weightedSquaredNorm w=∑i,(whiten w i)^2:=by
    rw [←weightedSquaredNorm_unwhiten hd hN,unwhiten_whiten hd hN]
  simpa only [he,id_eq] using hh

theorem smallPrior_energyFunctions_smallWidth_tail (hd:0<d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) (hσ:0<σ)
    (hJ:8*(Fintype.card (WeightIndex d N r):ℝ)*σ^2≤J):
    (∑f∈Finset.univ\energyFunctions d r φ J,functionMass φ (1/2) (smallPrior d N r σ) f)≤
      Real.exp (-J/(4*σ^2)):=
  (energyFunctions_complement_mass_le_cost_tail hN hφ hℓ _).trans
    (smallPrior_total_energy_tail hd hN hσ hJ)

/-- Only the normalized parameter count enters the bounded-width budget. -/
theorem bandPrior_energyFunctions_smallWidth_tail (hd:0<d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) {t D:ℝ} (ht:0<t) (ht1:t≤1)
    (hp:(Fintype.card (WeightIndex d N r):ℝ)≤(N:ℝ)*D) (hD:8*D≤J):
    (∑f∈Finset.univ\energyFunctions d r φ J,functionMass φ (1/2) (activationBandPrior d N r t) f)≤
      Real.exp (-(N:ℝ)*J/(4*t^2)):=by
  have hn:(0:ℝ)<N:=by exact_mod_cast hN
  have hs:0<Real.sqrt (N:ℝ):=Real.sqrt_pos.mpr hn
  have hD0:0≤D:=by
    have hc:0≤(Fintype.card (WeightIndex d N r):ℝ):=Nat.cast_nonneg _
    nlinarith
  have ht2:t^2≤1:=by nlinarith
  have hbudget:8*(Fintype.card (WeightIndex d N r):ℝ)*(t/Real.sqrt (N:ℝ))^2≤J:=by
    rw [div_pow,Real.sq_sqrt hn.le]
    have hh:=mul_le_mul_of_nonneg_right hp (by positivity : 0≤t^2/(N:ℝ))
    have he:(N:ℝ)*D*(t^2/(N:ℝ))=D*t^2:=by field_simp
    rw [he] at hh
    nlinarith [mul_le_mul_of_nonneg_left ht2 hD0]
  have hh:=smallPrior_energyFunctions_smallWidth_tail hd hN hφ hℓ
    (show 0<t/Real.sqrt (N:ℝ) by positivity) hbudget
  have he:-J/(4*(t/Real.sqrt (N:ℝ))^2)=-(N:ℝ)*J/(4*t^2):=by
    rw [div_pow,Real.sq_sqrt hn.le]
    field_simp
  simpa only [activationBandPrior,he] using hh

/-- A raw target lower bound and the bounded-width energy tail give the desired
relative excluded mass. The target premise can be instantiated with the proved
activation target-cylinder theorem. -/
theorem bandPrior_smallWidth_relative_tail (hd:0<d) (hN:0<N)
    (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0≤ℓ) {t D A ε:ℝ}
    (ht:0<t) (ht1:t≤1) (hA:0≤A) (hε:0<ε) (hε2:ε≤2)
    (hp:(Fintype.card (WeightIndex d N r):ℝ)≤(N:ℝ)*D)
    (hJD:8*D≤J) (hJA:4*A+4*Real.log (2/ε)≤J)
    (f:BooleanFunction d)
    (hmass:Real.exp (-(N:ℝ)*A/t^2)≤functionMass φ (1/2) (activationBandPrior d N r t) f):
    (∑g∈Finset.univ\energyFunctions d r φ J,functionMass φ (1/2) (activationBandPrior d N r t) g)≤
      (ε/2)*functionMass φ (1/2) (activationBandPrior d N r t) f:=by
  have htail:=bandPrior_energyFunctions_smallWidth_tail hd hN hφ hℓ ht ht1 hp hJD
  have hn1:(1:ℝ)≤N:=by exact_mod_cast hN
  have hn:(0:ℝ)<N:=by positivity
  have ht2:0<t^2:=sq_pos_of_pos ht
  have ht21:t^2≤1:=by nlinarith
  have hlog:0≤Real.log (2/ε):=Real.log_nonneg ((one_le_div hε).mpr hε2)
  have hfactor:1≤(N:ℝ)/t^2:=(le_div_iff₀ ht2).mpr (by nlinarith)
  have hb:(N:ℝ)/t^2*Real.log (2/ε)≤(N:ℝ)/t^2*(J/4-A):=
    mul_le_mul_of_nonneg_left (by linarith) (by positivity)
  have hlogle:Real.log (2/ε)≤(N:ℝ)/t^2*Real.log (2/ε):=by
    nlinarith [mul_le_mul_of_nonneg_right hfactor hlog]
  have hb':Real.log (2/ε)≤(N:ℝ)/t^2*(J/4-A):=hlogle.trans hb
  have hexp:Real.exp (-(N:ℝ)*J/(4*t^2))≤(ε/2)*Real.exp (-(N:ℝ)*A/t^2):=by
    have he:Real.exp (-Real.log (2/ε))=ε/2:=by
      rw [Real.exp_neg,Real.exp_log (by positivity)]
      field_simp
    rw [←he,←Real.exp_add]
    apply Real.exp_le_exp.mpr
    have hid:-(N:ℝ)*J/(4*t^2)=-((N:ℝ)/t^2*(J/4-A)) + -(N:ℝ)*A/t^2:=by ring
    rw [hid]
    linarith only [hb']
  exact htail.trans (hexp.trans (mul_le_mul_of_nonneg_left hmass (by positivity)))

end NeuralGeneralization.BatchTwoActivation
