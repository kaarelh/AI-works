import NeuralGeneralization.BatchTwoActivationTowerReadout
import NeuralGeneralization.BatchTwoActivationFullNetworkEventsDiagonal

/-! Full deterministic compression of the physical Gaussian learner on its
actual recursively defined hidden good event. -/
noncomputable section
set_option maxRecDepth 10000
set_option maxHeartbeats 1800000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel NetworkLayerSplit GaussianAngularPrice FiniteDifferential

theorem activationInputSource_gram {d N : ℕ} (σ : ℝ) (x y : Cube d) :
    gram (activationInputSource d N σ) x y=
      weightedFeatureGram (fun j x => concreteInput x j) (fun _ => (N:ℝ)*σ^2/d) x y := by
  unfold gram activationInputSource weightedFeatureGram
  apply Finset.sum_congr rfl
  intro j _
  change (σ*Real.sqrt ((N:ℝ)/d)*inputVector x j)*(σ*Real.sqrt ((N:ℝ)/d)*inputVector y j)=_
  have hs := Real.sq_sqrt (div_nonneg (Nat.cast_nonneg N) (Nat.cast_nonneg d))
  change _=((N:ℝ)*σ^2/d)*inputVector x j*inputVector y j
  calc
    _ = σ^2*(Real.sqrt ((N:ℝ)/d))^2*inputVector x j*inputVector y j := by ring
    _ = _ := by rw [hs]; ring

theorem activationLastSource_gram {d N r : ℕ} (hN : 0<N) (φ : ℝ → ℝ) (σ : ℝ)
    (w : Weights d N r) (x y : Cube d) :
    gram (activationLastSource φ σ w) x y=(N:ℝ)*σ^2*finalCovariance φ w x y := by
  unfold gram activationLastSource finalCovariance
  have hN0 : (N:ℝ)≠0 := Nat.cast_ne_zero.mpr hN.ne'
  calc
    _ = σ^2*(∑j,finalHidden φ w x j*finalHidden φ w y j) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring
    _ = _ := by field_simp

theorem actual_hidden_tower_reconstruction {b d K H N : ℕ}
    (hb : 1≤b) (hd : 1≤d) (hK : 1≤K) (hN : 0<N)
    {ℓ B σ : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀u,|deriv scalarCutoff u|≤B) (hbb : ∀u,|deriv (deriv scalarCutoff) u|≤B) :
    ∀r,r+1≤H → ∀w : Weights d N r,ActivationGoodHidden b d K H N φ σ r w →
      ∃(W : FixedActivationNetwork d (activationFiniteWidth b d K H) ℓ (activationRawBudget b d K H))
        (v : Fin (activationFiniteWidth b d K H) → ℝ),
        (∀j,0≤v j ∧ v j≤1+56*(K:ℝ)) ∧
        (∀j x,|fixedActivationState W x (r+1) j|≤activationStageStateBound b d K H (r+1)) ∧
        ∀x y,|weightedFeatureGram (fun j x => fixedActivationState W x (r+1) j) v x y-
          finalCovariance φ w x y|≤1/(activationPrecisionGrow (activationBaseBudget b d K H) (H-(r+1)):ℝ) := by
  classical
  let F := activationFiniteWidth b d K H
  let A := activationBaseBudget b d K H
  have hd0 : 0<d := by omega
  have hV0 : (0:ℝ)≤1+56*(K:ℝ) := by positivity
  intro r
  induction r with
  | zero =>
    intro hr w hw
    let W := zeroFixedActivationNetwork d F ℓ (activationRawBudget b d K H) hℓ0.le
    let v : Fin (d+1) → ℝ := fun _ => (N:ℝ)*σ^2/d
    have hv (j) : 0≤v j ∧ v j≤1+56*(K:ℝ) := by
      have hdR : (1:ℝ)≤d := by exact_mod_cast hd
      refine ⟨by dsimp [v]; positivity,?_⟩
      have hh : v j≤1 := by
        dsimp [v]
        apply (div_le_iff₀ (Nat.cast_pos.mpr hd0)).mpr
        linarith
      linarith
    have hstate (j) (x : Cube d) : |fixedActivationState W x 0 j|≤activationStageStateBound b d K H 0 := by
      change |concreteInput x j|≤_
      have hh : (1:ℝ)≤activationStageStateBound b d K H 0 := by exact_mod_cast activationStageStateBound_one_le b d K H 0
      exact (concreteInput_abs_le x j).trans hh
    have hcov (x y : Cube d) : |weightedFeatureGram (fun j x => fixedActivationState W x 0 j) v x y-
        gram (activationInputSource d N σ) x y|≤
          1/(activationStageBudget H A 0:ℝ)^160 := by
      rw [activationInputSource_gram]
      change |weightedFeatureGram (fun j x => concreteInput x j) v x y-
        weightedFeatureGram (fun j x => concreteInput x j) v x y|≤_
      rw [sub_self,abs_zero]
      positivity
    obtain ⟨W',v',hv',hs',_,hq'⟩ := fixed_reconstruction_step hb hK (by omega : 0<H) hN
      hℓ0 hℓ hB0 hB hφ hb' hbb (activationInputSource d N σ) (activationInputRows σ w)
      (activationInputSource_energy hd0 hscale) hw W v hv hstate hcov
    refine ⟨W',v',hv',hs',?_⟩
    intro x y
    simpa only [activationInputRows_output hd0 hN hσ,finalCovariance,
      activationStageBudget,Nat.sub_zero] using (hq' x y).le
  | succ r ih =>
    intro hr w hw
    have hprev := hw.1
    obtain ⟨W,v,hv,hstate,hcov⟩ := ih (by omega) (previousWeights w) hprev
    let k := activationStageBudget H A (r+1)
    have hprec : activationPrecisionGrow A (H-(r+1))=k^160 := by
      have he : H-(r+1)=(H-1-(r+1))+1 := by omega
      rw [he,activationPrecisionGrow]
      rfl
    have hvin (j) : 0≤((N:ℝ)*σ^2)*v j ∧ ((N:ℝ)*σ^2)*v j≤1+56*(K:ℝ) := by
      refine ⟨mul_nonneg (by positivity) (hv j).1,?_⟩
      exact (mul_le_of_le_one_left (hv j).1 hscale).trans (hv j).2
    have hcin (x y : Cube d) :
        |weightedFeatureGram (fun j x => fixedActivationState W x (r+1) j)
          (fun j => ((N:ℝ)*σ^2)*v j) x y-gram (activationLastSource φ σ (previousWeights w)) x y|≤1/(k:ℝ)^160 := by
      rw [weightedFeatureGram_mul,activationLastSource_gram hN,←mul_sub,abs_mul,
        abs_of_nonneg (show 0≤(N:ℝ)*σ^2 by positivity)]
      apply (mul_le_of_le_one_left (abs_nonneg _) hscale).trans
      have hc := hcov x y
      change _≤1/(activationPrecisionGrow A (H-(r+1)):ℝ) at hc
      simpa only [hprec,Nat.cast_pow] using hc
    have hdiag := ActivationGoodHidden.diagonal hd0 hN hb hK hσ hscale hφ hℓ0.le hℓ r (previousWeights w) hprev
    have hvar := activationLastSource_energy hN hscale (previousWeights w)
      (activationDiagonalBudget b d K (r+1)) (Nat.cast_nonneg _) hdiag
    obtain ⟨W',v',hv',hs',_,hq'⟩ := fixed_reconstruction_step hb hK (by omega : r+1<H) hN
      hℓ0 hℓ hB0 hB hφ hb' hbb (activationLastSource φ σ (previousWeights w)) (activationLastRows σ w)
      hvar hw.2 W (fun j => ((N:ℝ)*σ^2)*v j) hvin hstate hcin
    refine ⟨W',v',hv',hs',?_⟩
    intro x y
    have he : H-(r+1+1)=H-1-(r+1) := by omega
    simpa only [activationLastRows_output hσ,finalCovariance,he,activationStageBudget]
      using (hq' x y).le

theorem actual_good_network_auxiliary_mem {b d K N r : ℕ}
    (hb : 1≤b) (hd : 1≤d) (hK : 1≤K) (hN : 0<N)
    {ℓ B σ : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀u,|deriv scalarCutoff u|≤B) (hbb : ∀u,|deriv (deriv scalarCutoff) u|≤B)
    (w : Weights d N r) (f : BooleanFunction d)
    (hmargin : w∈marginEvent φ (1/2) f)
    (hgood : ActivationGoodHidden b d K (r+1) N φ σ r w)
    (hreadout : (N:ℝ)*(∑i,w (.inr (.inr i))^2)≤8*(K:ℝ)) :
    f∈auxiliaryFunctions d (r+1) (activationAuxiliaryScale b d K (r+1) ℓ) := by
  obtain ⟨W,v,hv,hs,hcov⟩ := actual_hidden_tower_reconstruction hb hd hK hN
    hℓ0 hℓ hB0 hB hσ hscale hφ hb' hbb r (le_refl _) w hgood
  have hKR : (0:ℝ)<K := by exact_mod_cast (show 0<K by omega)
  obtain ⟨β,hβ,hpred⟩ := actual_readout_reconstructed_margin hN φ w f (by positivity : 0<8*(K:ℝ)) hmargin hreadout
  apply fixed_tower_readout_membership (by omega : 0<r+1) hℓ0 W v hv hs β (by nlinarith) f
  apply hpred
  intro x y
  have hc := hcov x y
  simp only [Nat.sub_self,activationPrecisionGrow] at hc
  apply hc.trans
  have hA : 256*(K:ℝ)≤activationBaseBudget b d K (r+1) := by
    exact_mod_cast (show 256*K≤activationBaseBudget b d K (r+1) by unfold activationBaseBudget; omega)
  have hh := one_div_le_one_div_of_le (by positivity : 0<256*(K:ℝ)) hA
  convert hh using 1 <;> ring

end NeuralGeneralization.BatchTwoActivation
