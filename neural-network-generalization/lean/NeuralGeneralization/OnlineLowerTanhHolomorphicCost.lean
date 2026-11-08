import NeuralGeneralization.OnlineLowerTanhOptimizedCostJet

noncomputable section
open scoped Topology BigOperators
open Complex Set Metric Filter Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh

lemma rightDegree_eventually_iff (p:ℂ→Prop) :
    (∀ᶠz in rightDegreeInfinity,p z) ↔ ∃T:ℝ,∀z:ℂ,0<z.re→T<‖z‖→p z := by
  constructor
  · intro h
    change ∀ᶠz in Bornology.cobounded ℂ ⊓ 𝓟 {z:ℂ|0<z.re},p z at h
    rw [eventually_inf_principal] at h
    obtain ⟨T,_,hT⟩:=hasBasis_cobounded_norm.mem_iff.mp h
    exact ⟨T,fun z hz hzT=>hT hzT.le hz⟩
  · rintro ⟨T,hT⟩
    filter_upwards [rightDegree_re_eventually,rightDegree_large T] with z hz hzT
    exact hT z hz hzT

lemma actualGainBranch_complexF_tendsto (b:ActualGainBranch) :
    Tendsto (fun z=>complexF z (b.gain z)) rightDegreeInfinity
      (𝓝 (scalarF0 limitingGain:ℂ)) := by
  let δ:ℂ→ℂ:=fun z=>b.gain z-(limitingGain:ℂ)
  have hd:Tendsto δ rightDegreeInfinity (𝓝 0):=
    (actualGainBranch_displacement_bigO b).trans_tendsto rightDegree_inv_tendsto
  have hh:=rightDegree_inv_tendsto
  have he:= (actualGainBranch_complexF_jet b).trans_tendsto (by simpa using hh.pow 3)
  have hq:= ((((tendsto_const_nhds (x:=(scalarF0 limitingGain:ℂ))).add
    ((tendsto_const_nhds (x:=(scalarF0First limitingGain:ℂ))).mul hd)).add
    ((tendsto_const_nhds (x:=((scalarF0Second limitingGain:ℂ)/2))).mul (hd.pow 2))).add
    (((tendsto_const_nhds (x:=(scalarF1 limitingGain:ℂ))).add
      ((tendsto_const_nhds (x:=(scalarF1First limitingGain:ℂ))).mul hd)).mul hh)).add
    ((tendsto_const_nhds (x:=(scalarF2 limitingGain:ℂ))).mul (hh.pow 2))
  convert he.add hq using 1 <;> simp [δ]

lemma holomorphicOptimizedCost_eventually_analytic (b:ActualGainBranch) :
    ∃T:ℝ,2≤T ∧ b.threshold≤T ∧
      DifferentiableOn ℂ (holomorphicOptimizedCost b) {z:ℂ|0<z.re ∧ T<‖z‖} := by
  have hn:(scalarF0 limitingGain:ℂ)≠0:=by exact_mod_cast scalarF0_limitingGain_pos.ne'
  obtain ⟨T₀,hT₀⟩:= (rightDegree_eventually_iff _).mp
    ((actualGainBranch_complexF_tendsto b).eventually_ne hn)
  let T:ℝ:=max 2 (max b.threshold T₀)
  have h2:2≤T:=le_max_left _ _
  have hb:b.threshold≤T:=(le_max_left _ _).trans (le_max_right _ _)
  have h0:T₀≤T:=(le_max_right _ _).trans (le_max_right _ _)
  let U:Set ℂ:={z:ℂ|0<z.re ∧ T<‖z‖}
  have hU:IsOpen U:=(isOpen_lt continuous_const Complex.continuous_re).inter
    (isOpen_lt continuous_const continuous_norm)
  have hba:DifferentiableOn ℂ b.gain U:=b.analytic.mono (fun z hz=>⟨hz.1,hb.trans_lt hz.2⟩)
  have hF:DifferentiableOn ℂ (fun z=>complexF z (b.gain z)) U:=by
    apply complexF_comp_differentiableOn b.gain hU (fun z hz=>hz.1) hba
    intro z hz
    have hd:dist (b.gain z) (limitingGain:ℂ)<(1/8:ℝ):=by
      have hh:dist (b.gain z) (limitingGain:ℂ)≤b.radius:=(b.root z hz.1 (hb.trans_lt hz.2)).1
      linarith [b.radius_small,b.radius_pos]
    exact (limitingGain_disk_bounds hd).1.le
  have hH:DifferentiableOn ℂ centralBinomialHolomorphic U:=
    differentiableOn_centralBinomialHolomorphic.mono (fun z hz=>⟨hz.1,h2.trans_lt hz.2⟩)
  have hden:∀z∈U,centralBinomialHolomorphic z*complexF z (b.gain z)≠0:=by
    intro z hz
    exact mul_ne_zero (Complex.exp_ne_zero _) (hT₀ z hz.1 (h0.trans_lt hz.2))
  refine ⟨T,h2,hb,?_⟩
  exact ((differentiableOn_const _).mul differentiableOn_id).mul (hba.div (hH.mul hF) hden)

/-- Uniform holomorphic expansion with the certified strictly positive
linear and reciprocal-degree coefficients. -/
theorem holomorphicOptimizedCost_uniform_expansion (b:ActualGainBranch) :
    ∃T K:ℝ,2≤T ∧ 0<K ∧ b.threshold≤T ∧
      DifferentiableOn ℂ (holomorphicOptimizedCost b) {z:ℂ|0<z.re ∧ T<‖z‖} ∧
      ∀z:ℂ,0<z.re→T<‖z‖→
        ‖holomorphicOptimizedCost b z-((optimizedCostSlope:ℂ)*z+
          (optimizedCostIntercept:ℂ)+(optimizedCostCurvature:ℂ)/z)‖≤K/‖z‖^2 := by
  obtain ⟨K₀,hK₀⟩:=isBigO_iff.mp (holomorphicOptimizedCost_jet b)
  obtain ⟨T₀,hT₀⟩:=(rightDegree_eventually_iff _).mp hK₀
  obtain ⟨T₁,h2,hb,ha⟩:=holomorphicOptimizedCost_eventually_analytic b
  refine ⟨max T₀ T₁,|K₀|+1,h2.trans (le_max_right _ _),by positivity,
    hb.trans (le_max_right _ _),ha.mono (fun z hz=>⟨hz.1,(le_max_right _ _).trans_lt hz.2⟩),?_⟩
  intro z hz hzT
  have he:=hT₀ z hz ((le_max_left _ _).trans_lt hzT)
  calc
    _ ≤ K₀*‖z⁻¹^2‖:=he
    _ ≤ (|K₀|+1)*‖z⁻¹^2‖:=by gcongr; exact le_trans (le_abs_self K₀) (by linarith)
    _ = _ := by rw [norm_pow,norm_inv,inv_pow,div_eq_mul_inv]

end NeuralGeneralization.OnlineLowerTanh
