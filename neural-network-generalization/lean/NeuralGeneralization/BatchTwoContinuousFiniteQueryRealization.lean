import NeuralGeneralization.BatchTwoContinuousFiniteQueryModel
import NeuralGeneralization.BatchTwoNonGaussianTower

/-! Realization of finite real-query mixed covariance towers by actual tanh
networks in the original input dimension. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open ConcreteModel BatchTwoNonGaussian GaussianTowerConstruction TowerNetwork
open FiniteDifferential GaussianAngularPrice GaussianFieldTilt TanhDifferential TiltedGaussianRows

variable {d q N r : ℕ}

theorem gram_activationMatrix (hN : 0<N) (xs : Cube q → RealInput d) (w : Weights d N r)
    (x y : Cube q) : gram (activationMatrix xs w) x y=covariance xs w x y := by
  rw [←coefficient_final,gram_coefficient_final hN]

theorem finalHidden_inputWeights (xs : Cube q → RealInput d)
    (a : Fin N → Fin (d+1) → ℝ) (x : Cube q) (i : Fin N) :
    BatchTwoContinuous.finalHidden Real.tanh (inputWeights a) (xs x) i=
      Real.tanh (fieldLinear (inputMatrix xs) (a i) x) := by
  simp only [BatchTwoContinuous.finalHidden,List.finRange_zero,List.foldl_nil,
    BatchTwoContinuous.firstHidden,inputWeights,fieldLinear_apply,inputMatrix]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem freeze_appendLayer (x : RealInput d) (w : Weights d N r) (a : Fin N → Fin N → ℝ) :
    freezeInput x (appendLayer w a)=appendLayer (freezeInput x w) a := by
  funext i
  rcases i with ij | (sij | j) <;> rfl

theorem finalHidden_append_normalizedRows (xs : Cube q → RealInput d) (w : Weights d N r)
    (a : Fin N → Fin N → ℝ) (x : Cube q) (i : Fin N) :
    BatchTwoContinuous.finalHidden Real.tanh (appendLayer w (normalizedRows a)) (xs x) i=
      Real.tanh (fieldLinear (activationMatrix xs w) (a i) x) := by
  have hh := GaussianTowerConstruction.finalHidden_append_normalizedRows
    (freezeInput (xs x) w) a (fun _ => false) i
  rw [←freeze_appendLayer,finalHidden_freeze] at hh
  simpa only [fieldLinear_apply,GaussianTowerConstruction.activationMatrix,
    finalHidden_freeze,activationMatrix] using hh

theorem exists_input_covariance (ν : CoordinateLaw) (xs : Cube q → RealInput d)
    (hd : 0<d) (hN : 0<N) (Γ : Cube q → Cube q → ℝ) {G η B : ℝ}
    (hη : 0≤η) (hB : 0≤B) (hΓ : couplingMass Γ≤G)
    (hbudget : 2*(Fintype.card (Cube q) : ℝ)^2*Real.exp (-(N : ℝ)*η^2/2)+
      2*ν.comparisonFactor ν.lowerCurvature*(N : ℝ)*(d+1 : ℝ)*
        Real.exp (2*G-ν.lowerCurvature*B^2/2)<1) :
    ∃ w : Weights d N 0, (∀ i, |w i|≤B) ∧ ∀ x y,
      |covariance xs w x y-actualTiltedMoment ν (inputMatrix xs) Γ x y|≤η := by
  obtain ⟨a,ha,hc⟩ := exists_actual_bounded_tanh_rows ν (inputMatrix xs) Γ hΓ hN hη hB
    (by simpa using hbudget)
  refine ⟨inputWeights a,inputWeights_bound hd a hB (fun i j => (ha i j).le),?_⟩
  intro x y
  simpa only [covariance,finalHidden_inputWeights] using (hc x y).le

theorem exists_append_covariance (xs : Cube q → RealInput d) (hN : 0<N) (w : Weights d N r)
    (R Γ : Cube q → Cube q → ℝ) {G e η B : ℝ}
    (hG : 0≤G) (he : 0≤e) (hη : 0≤η) (hB : 0≤B)
    (hw : ∀ i,|w i|≤B) (hΓ : couplingMass Γ≤G)
    (hcov : ∀ x y,|covariance xs w x y-gram R x y|≤e)
    (hbudget : 2*(Fintype.card (Cube q) : ℝ)^2*Real.exp (-(N : ℝ)*η^2/2)+
      2*(N : ℝ)*(N : ℝ)*Real.exp (2*G-B^2/2)<1) :
    ∃ v : Weights d N (r+1), (∀ i,|v i|≤B) ∧ ∀ x y,
      |covariance xs v x y-tiltedMoment R Γ x y|≤η+8*(1+G)^2*e := by
  obtain ⟨a,ha,hacov⟩ := exists_bounded_tanh_rows (activationMatrix xs w) Γ hΓ hN hη hB
    (by simpa using hbudget)
  refine ⟨appendLayer w (normalizedRows a),
    appendLayer_bound w _ hw (normalizedRows_bound hN a (fun i j => (ha i j).le)),?_⟩
  intro x y
  have hs : |covariance xs (appendLayer w (normalizedRows a)) x y-
      tiltedMoment (activationMatrix xs w) Γ x y|≤η := by
    simpa only [covariance,finalHidden_append_normalizedRows] using (hacov x y).le
  have hp := tiltedMoment_stability R (activationMatrix xs w) Γ x y hG he hΓ
    (fun p s => by simpa only [gram_activationMatrix hN] using hcov p s)
  exact (abs_sub_le _ _ _).trans (add_le_add hs hp)

theorem exists_mixed_finite_tower (ν : CoordinateLaw) (xs : Cube q → RealInput d)
    (hd : 0<d) (hN : 0<N) (Q R Γ : ℕ → Cube q → Cube q → ℝ) {G η B : ℝ}
    (hG : 0≤G) (hη : 0≤η) (hB : 0≤B)
    (hbase : ∀ x y,Q 0 x y=actualTiltedMoment ν (inputMatrix xs) (Γ 0) x y)
    (hgram : ∀ s x y,gram (R s) x y=Q s x y)
    (hinputBudget : 2*(Fintype.card (Cube q) : ℝ)^2*Real.exp (-(N : ℝ)*η^2/2)+
      2*ν.comparisonFactor ν.lowerCurvature*(N : ℝ)*(d+1 : ℝ)*
        Real.exp (2*G-ν.lowerCurvature*B^2/2)<1)
    (hhiddenBudget : 2*(Fintype.card (Cube q) : ℝ)^2*Real.exp (-(N : ℝ)*η^2/2)+
      2*(N : ℝ)*(N : ℝ)*Real.exp (2*G-B^2/2)<1) :
    ∀ r : ℕ, (∀ s,s≤r → couplingMass (Γ s)≤G) →
      (∀ s,s<r → ∀ x y,Q (s+1) x y=tiltedMoment (R s) (Γ (s+1)) x y) →
      ∃ w : Weights d N r, (∀ i,|w i|≤B) ∧ ∀ x y,
        |covariance xs w x y-Q r x y|≤(r+1 : ℝ)*(8*(1+G)^2)^r*η := by
  intro r
  induction r with
  | zero =>
    intro hΓ hstep
    obtain ⟨w,hw,hc⟩ := exists_input_covariance ν xs hd hN (Γ 0) hη hB (hΓ 0 le_rfl) hinputBudget
    refine ⟨w,hw,?_⟩
    intro x y
    simpa only [hbase,Nat.cast_zero,zero_add,pow_zero,mul_one,one_mul] using hc x y
  | succ r ih =>
    intro hΓ hstep
    obtain ⟨w,hw,hc⟩ := ih (fun s hs => hΓ s (by omega)) (fun s hs => hstep s (by omega))
    have he : 0≤(r+1 : ℝ)*(8*(1+G)^2)^r*η := by positivity
    obtain ⟨v,hv,hvc⟩ := exists_append_covariance xs hN w (R r) (Γ (r+1)) hG he hη hB hw
      (hΓ (r+1) le_rfl) (fun x y => by rw [hgram]; exact hc x y) hhiddenBudget
    refine ⟨v,hv,?_⟩
    intro x y
    rw [hstep r (by omega)]
    apply (hvc x y).trans
    have hb : 1≤8*(1+G)^2 := by nlinarith
    have hp : 1≤(8*(1+G)^2)^(r+1) := one_le_pow₀ hb
    have he' := mul_le_mul_of_nonneg_right hp hη
    simp only [one_mul] at he'
    calc
      _ ≤ (8*(1+G)^2)^(r+1)*η+8*(1+G)^2*((r+1 : ℝ)*(8*(1+G)^2)^r*η) := add_le_add he' le_rfl
      _ = _ := by rw [pow_succ]; push_cast; ring

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
