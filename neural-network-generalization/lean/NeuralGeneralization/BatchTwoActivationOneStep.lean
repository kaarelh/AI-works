import NeuralGeneralization.BatchTwoActivationWeightedFeatures

/-! Finite feedforward reconstruction of one actual Gaussian layer. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularFields GaussianAngularPrice
variable {I J : Type*} [Fintype I] [Nonempty I] [DecidableEq I]
  [Fintype J] [DecidableEq J] {N n nA nB : ℕ}

def boundedCovarianceModulus (b₀ b₁ b₂ G : ℝ) : ℝ :=
  let F₀ := b₀*b₀
  let F₁ := b₁*b₀+b₀*b₁
  let F₂ := b₂*b₀+2*b₁*b₁+b₀*b₂
  F₂+2*F₁*(G*F₁)+2*F₀*(G*F₂+(G*F₁)^2)

theorem gaussian_one_step_realization
    (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    {φ : ℝ → ℝ} {ℓ M a T A b₀ b₁ b₂ D G K e η εA εB R V Bh : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hM : 0<M) (ha : 0<a) (hT : 0<T)
    (hA : 0<A) (hb₀ : 0<b₀) (hb₁ : 0≤b₁) (hb₂ : 0≤b₂) (hG : 0<G)
    (he : 0≤e) (hη : 0<η) (hεA : 0≤εA) (hεB : 0≤εB) (hR : 0≤R)
    (hV : 0≤V) (hBh : 0≤Bh) (hN : 0<N) (hnA : 0<nA) (hnB : 0<nB)
    (hBT : 2*gaussianBulkThreshold I M≤T)
    (hscale : Real.log (2*Fintype.card I)≤a*T)
    (hvar : ∀i,(∑j,(c i j)^2)≤M)
    (henergy : ∑j,‖gaussianResidualSource c M (x j)‖^2≤(N:ℝ)*A)
    (b : I → BoundedJet I b₀ b₁ b₂)
    (happrox : ∀p q z, |(b p).value z*(b q).value z-
      actualCutoffFeature φ a T p z*actualCutoffFeature φ a T q z|≤D)
    (hgood : x ∉ scaledBadRows c (fun (pq : I×I) z => (b pq.1).value z*(b pq.2).value z)
      N (b₀^2) G K)
    (h : J → I → ℝ) (v : J → ℝ) (hv : ∀j,0≤v j) (hvV : ∀j,v j≤V)
    (hh : ∀j i,|h j i|≤Bh)
    (hQe : ∀i j,|weightedFeatureGram h v i j-gram c i j|≤e)
    (hQη : ∀i j,|weightedFeatureGram h v i j-gram c i j|≤η^2)
    (hbudgetA : 2*(Fintype.card I:ℝ)^2*Real.exp (-(nA:ℝ)*((εA/A)/(ℓ*Real.sqrt M)^2)^2/2)<1)
    (hbudgetB : 2*(Fintype.card I:ℝ)^2*Real.exp (-(nB:ℝ)*(εB/(4*ℓ*T)^2)^2/2)+
      2*(nB:ℝ)*(Fintype.card J:ℝ)*Real.exp (2*(G*b₀^2)-R^2/2)<1) :
    ∃(ψ : (Fin nB ⊕ Fin nA) → ℝ → ℝ) (W : (Fin nB ⊕ Fin nA) → J → ℝ)
      (v' : (Fin nB ⊕ Fin nA) → ℝ),
      (∀j,zeroLipschitzActivation ℓ (ψ j)) ∧
      (∀j,0≤v' j ∧ v' j≤max 1 A) ∧
      (∀j k,|W j k|≤max (Real.sqrt V*R) (V*Bh/(4*η))) ∧
      (∀j i,|ψ j (∑k,W j k*h k i)|≤
        ℓ*(Fintype.card J:ℝ)*max (Real.sqrt V*R) (V*Bh/(4*η))*Bh) ∧
      ∀p q, |weightedFeatureGram (fun j i => ψ j (∑k,W j k*h k i)) v' p q-
        (∑j,φ (fieldLinear c (x j) p)*φ (fieldLinear c (x j) q))/(N:ℝ)|<
        6*ℓ^2*gaussianBulkThreshold I M*M*A/T+2*D+K/G+
          e*boundedCovarianceModulus b₀ b₁ b₂ G+εB+
          εA+A*(5*ℓ*η/4)*(2*ℓ*Real.sqrt M+5*ℓ*η/4) := by
  obtain ⟨Γ,hΓ,hcert⟩ := gaussian_layer_certificate c x hφ hℓ.le hM ha hT hBT hscale
    hvar hN henergy b hb₀ happrox hG hgood
  obtain ⟨ξ,β,hξ,hβ,hatom⟩ := exists_finite_gaussian_residual_atoms c x hφ hℓ hM hA
    hεA hη a T hN hvar henergy hnA hbudgetA
  let c' := weightedFeatureSource h v
  have hcov : ∀i j,|gram c' i j-gram c i j|≤e := by
    intro i j
    simpa only [c',weightedFeatureSource_gram h v hv] using hQe i j
  have hprice (p q : I) :
      |boundedFeatureCovariance c' (fun i => (b i).value) Γ p q-
        boundedFeatureCovariance c (fun i => (b i).value) Γ p q|≤
        e*boundedCovarianceModulus b₀ b₁ b₂ G :=
    boundedFeatureCovariance_stability c c' b Γ hb₀.le hb₁ hb₂ hG.le he hΓ hcov p q
  obtain ⟨w,hw,hbulk⟩ := exists_bounded_cutoff_rows c' hφ hℓ ha hT b hb₀.le Γ hΓ
    happrox hnB hεB hR hbudgetB
  let ψ : (Fin nB ⊕ Fin nA) → ℝ → ℝ := Sum.elim (fun _ => φ) ξ
  let W : (Fin nB ⊕ Fin nA) → J → ℝ := Sum.elim
    (fun j k => Real.sqrt (v k)*w j k) (fun j k => v k*(∑i,β j i*h k i))
  let v' : (Fin nB ⊕ Fin nA) → ℝ := Sum.elim
    (fun j => (smoothCutoff a T (fieldLinear c' (w j)))^2/(nB:ℝ)) (fun _ => A/(nA:ℝ))
  have hψ (j) : zeroLipschitzActivation ℓ (ψ j) := by
    cases j with
    | inl j => exact hφ
    | inr j => exact hξ j
  have hW (j k) : |W j k|≤max (Real.sqrt V*R) (V*Bh/(4*η)) := by
    cases j with
    | inl j => exact (weightedFeatureSource_weight_bound v (w j) hV hvV (fun k => (hw j k).le) k).trans (le_max_left _ _)
    | inr j =>
      have hvabs : ∀k,|v k|≤V := fun k => by rw [abs_of_nonneg (hv k)]; exact hvV k
      have hh' := weighted_feature_weight_bound h v (β j) hBh hV (hβ j) hvabs hh k
      apply le_trans _ (le_max_right _ _)
      change |v k*(∑i,β j i*h k i)|≤V*Bh/(4*η)
      apply hh'.trans_eq
      ring
  refine ⟨ψ,W,v',hψ,?_,hW,?_,?_⟩
  · intro j
    cases j with
    | inl j =>
      have hj := cutoff_covariance_coefficient_bounds hnB a T (fieldLinear c' (w j))
      exact ⟨hj.1,hj.2.trans (le_max_left _ _)⟩
    | inr j =>
      have hj := constant_covariance_coefficient_bounds hnA hA.le
      exact ⟨hj.1,hj.2.trans (le_max_right _ _)⟩
  · intro j i
    apply finite_feature_evaluation_bound h (W j) (hψ j) hℓ.le hBh _ hh (hW j) i
    exact (mul_nonneg (Real.sqrt_nonneg V) hR).trans (le_max_left _ _)
  · intro p q
    let B : ℝ := (∑j,(smoothCutoff a T (fieldLinear c' (w j)))^2*
      φ (fieldLinear c' (w j) p)*φ (fieldLinear c' (w j) q))/(nB:ℝ)
    let R' : ℝ := (A/(nA:ℝ))*(∑j,ξ j (∑i,β j i*weightedFeatureGram h v p i)*
      ξ j (∑i,β j i*weightedFeatureGram h v q i))
    have hsum : weightedFeatureGram (fun j i => ψ j (∑k,W j k*h k i)) v' p q=B+R' := by
      unfold weightedFeatureGram
      rw [Fintype.sum_sum_type]
      congr 1
      · dsimp only [v',ψ,W,Sum.elim_inl,B]
        simp only [c',weightedFeatureSource_action,Finset.sum_div]
        apply Finset.sum_congr rfl
        intro j hj
        ring
      · dsimp only [v',ψ,W,Sum.elim_inr,R']
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro j hj
        simp only [weightedFeatureGram,weighted_feature_action]
        ring
    rw [hsum]
    have hb := hbulk p q
    have hr := hatom (weightedFeatureGram h v) hQη p q
    have hp := hprice p q
    have hc := hcert p q
    change |B-boundedFeatureCovariance c' (fun i => (b i).value) Γ p q|<εB+D at hb
    change |R'-layerResidualCovariance c x φ M a T p q|<_ at hr
    have hb' := abs_sub_le B (boundedFeatureCovariance c' (fun i => (b i).value) Γ p q)
      (boundedFeatureCovariance c (fun i => (b i).value) Γ p q)
    have hsumerr : |(B+R')-(boundedFeatureCovariance c (fun i => (b i).value) Γ p q+
        layerResidualCovariance c x φ M a T p q)|≤
        |B-boundedFeatureCovariance c (fun i => (b i).value) Γ p q|+
        |R'-layerResidualCovariance c x φ M a T p q| := by
      rw [show (B+R')-(boundedFeatureCovariance c (fun i => (b i).value) Γ p q+
        layerResidualCovariance c x φ M a T p q)=
        (B-boundedFeatureCovariance c (fun i => (b i).value) Γ p q)+
        (R'-layerResidualCovariance c x φ M a T p q) by ring]
      exact abs_add_le _ _
    have htri := abs_sub_le (B+R')
      (boundedFeatureCovariance c (fun i => (b i).value) Γ p q+layerResidualCovariance c x φ M a T p q)
      ((∑j,φ (fieldLinear c (x j) p)*φ (fieldLinear c (x j) q))/(N:ℝ))
    rw [abs_sub_comm] at hc
    linarith

end NeuralGeneralization.BatchTwoActivation
