import NeuralGeneralization.BatchTwoActivationTowerStep

/-! Finite-depth covariance reconstruction from the actual Gaussian good events.
The source covariance identities are algebraic: the only analytic good event
is the explicitly defined polynomialLayerBad complement. -/
noncomputable section
set_option maxRecDepth 10000
set_option maxHeartbeats 1800000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel GaussianAngularPrice FiniteDifferential

theorem weightedFeatureGram_mul (a : ℝ) {J I : Type*} [Fintype J]
    (h : J → I → ℝ) (v : J → ℝ) (x y : I) :
    weightedFeatureGram h (fun j => a*v j) x y=a*weightedFeatureGram h v x y := by
  simp only [weightedFeatureGram,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem finite_gaussian_tower_reconstruction {b d K H N : ℕ}
    (hb : 1≤b) (hd : 1≤d) (hK : 1≤K) (hN : 0<N)
    {ℓ B t : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    (ht0 : 0≤t) (ht1 : t≤1)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀u,|deriv scalarCutoff u|≤B) (hbb : ∀u,|deriv (deriv scalarCutoff) u|≤B)
    (n : ℕ → ℕ) (c : ∀s,Cube d → Fin (n s) → ℝ)
    (z : ∀s,Fin N → Fin (n s) → ℝ) (Q : ℕ → Cube d → Cube d → ℝ)
    (hQ0 : ∀x y,Q 0 x y=(∑j : Fin (d+1),concreteInput x j*concreteInput y j)/(d:ℝ))
    (hsource : ∀s,s<H → ∀x y,gram (c s) x y=t^2*Q s x y)
    (houtput : ∀s,s<H → ∀x y,Q (s+1) x y=
      (∑j,φ (fieldLinear (c s) (z s j) x)*φ (fieldLinear (c s) (z s j) y))/(N:ℝ))
    (hvar : ∀s,s<H → ∀x,(∑j,(c s x j)^2)≤activationDiagonalBudget b d K s)
    (hgood : ∀s,s<H → z s∉polynomialLayerBad (c s) φ
      (activationStageBudget H (activationBaseBudget b d K H) s) N
      (activationDiagonalBudget b d K s) (4*K)) :
    ∃(W : FixedActivationNetwork d (activationFiniteWidth b d K H) ℓ (activationRawBudget b d K H))
      (v : Fin (fixedInputWidth d (activationFiniteWidth b d K H) H) → ℝ),
      (∀j,0≤v j ∧ v j≤1+56*(K:ℝ)) ∧
      (∀j x,|fixedActivationState W x H j|≤activationStateBudget b d K H) ∧
      ∀x y,|weightedFeatureGram (fun j x => fixedActivationState W x H j) v x y-
        Q H x y|≤1/(activationBaseBudget b d K H:ℝ) := by
  classical
  let F := activationFiniteWidth b d K H
  let A := activationBaseBudget b d K H
  have hA0 : 0<A := by dsimp [A,activationBaseBudget]; omega
  have ht2 : t^2≤1 := by nlinarith
  have hV0 : (0:ℝ)≤1+56*(K:ℝ) := by positivity
  have hind (s : ℕ) (hs : s≤H) :
      ∃(W : FixedActivationNetwork d F ℓ (activationRawBudget b d K H))
        (v : Fin (fixedInputWidth d F s) → ℝ),
        (∀j,0≤v j ∧ v j≤1+56*(K:ℝ)) ∧
        (∀j x,|fixedActivationState W x s j|≤activationStageStateBound b d K H s) ∧
        ∀x y,|weightedFeatureGram (fun j x => fixedActivationState W x s j) v x y-Q s x y|≤
          1/(activationPrecisionGrow A (H-s):ℝ) := by
    induction s with
    | zero =>
      let W := zeroFixedActivationNetwork d F ℓ (activationRawBudget b d K H) hℓ0.le
      refine ⟨W,fun _ => 1/(d:ℝ),?_,?_,?_⟩
      · intro j
        have hdR : (1:ℝ)≤d := by exact_mod_cast hd
        refine ⟨by positivity,?_⟩
        apply (one_div_le_one_div_of_le (by norm_num : (0:ℝ)<1) hdR).trans
        norm_num
      · intro j x
        change |concreteInput x j|≤(activationStageStateBound b d K H 0:ℝ)
        have hS : (1:ℝ)≤(activationStageStateBound b d K H 0:ℝ) := by
          exact_mod_cast activationStageStateBound_one_le b d K H 0
        exact (concreteInput_abs_le x j).trans hS
      · intro x y
        have he : weightedFeatureGram (fun j x => fixedActivationState W x 0 j)
            (fun _ => 1/(d:ℝ)) x y=Q 0 x y := by
          rw [hQ0]
          simp only [weightedFeatureGram,fixedActivationState]
          rw [Finset.sum_div]
          apply Finset.sum_congr rfl
          intro j _
          ring
        rw [he,sub_self,abs_zero]
        positivity
    | succ s ih =>
      have hsH : s<H := by omega
      obtain ⟨W,v,hv,hstate,hcov⟩ := ih (by omega)
      let k := activationStageBudget H A s
      have hprec : activationPrecisionGrow A (H-s)=k^160 := by
        have he : H-s=(H-1-s)+1 := by omega
        rw [he,activationPrecisionGrow]
        rfl
      have hvin (j) : 0≤t^2*v j ∧ t^2*v j≤1+56*(K:ℝ) := by
        refine ⟨mul_nonneg (sq_nonneg t) (hv j).1,?_⟩
        exact (mul_le_of_le_one_left (hv j).1 ht2).trans (hv j).2
      have hcin (x y : Cube d) :
          |weightedFeatureGram (fun j x => fixedActivationState W x s j) (fun j => t^2*v j) x y-
              gram (c s) x y|≤1/(k:ℝ)^160 := by
        rw [weightedFeatureGram_mul,hsource s hsH x y,←mul_sub,abs_mul,abs_of_nonneg (sq_nonneg t)]
        apply (mul_le_of_le_one_left (abs_nonneg _) ht2).trans
        simpa only [hprec,Nat.cast_pow] using hcov x y
      obtain ⟨W',v',hv',hstate',_,hcov'⟩ := fixed_reconstruction_step hb hK hsH hN
        hℓ0 hℓ hB0 hB hφ hb' hbb (c s) (z s) (hvar s hsH) (hgood s hsH)
        W (fun j => t^2*v j) hvin hstate hcin
      refine ⟨W',v',hv',hstate',?_⟩
      intro x y
      rw [houtput s hsH]
      have he : H-(s+1)=H-1-s := by omega
      simpa only [he,activationStageBudget] using (hcov' x y).le
  obtain ⟨W,v,hv,hs,hcov⟩ := hind H (le_refl _)
  refine ⟨W,v,hv,?_,?_⟩
  · intro j x
    exact hs j x
  · intro x y
    simpa only [Nat.sub_self,activationPrecisionGrow] using hcov x y

end NeuralGeneralization.BatchTwoActivation
