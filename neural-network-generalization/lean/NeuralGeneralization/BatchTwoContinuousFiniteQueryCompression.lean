import NeuralGeneralization.BatchTwoContinuousFiniteQueryBudget
import NeuralGeneralization.BatchTwoContinuousFiniteQueryExtraction
import NeuralGeneralization.BatchTwoContinuousFiniteQueryReadout
import NeuralGeneralization.BatchTwoNonGaussianMixedTransport

/-! Arbitrarily accurate compression of an actual good mean-field regression
network on a finite real-input query table. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open ConcreteModel BatchTwoNonGaussian GaussianAngularPrice GaussianFieldTilt
open MeanFieldBudgets TowerNetwork TanhDifferential

 theorem compressedWidth_pos (d q r : ℕ) {K R : ℕ} (hK : 0<K) (hR : 0<R) :
    0<compressedWidth d q r K R := by
  apply TowerSamplingBudget.width_pos
  apply TowerCompression.precision_pos
  unfold regressionResource
  positivity

theorem exists_compressed_of_certificates (ν : CoordinateLaw) {d q N r K R : ℕ}
    (xs : Cube q → RealInput d) (hd : 0<d) (hN : 0<N) (hK : 0<K) (hR : 0<R)
    (w : Weights d N r) (Γ : ℕ → Cube q → Cube q → ℝ)
    (henergy : (N : ℝ)*(∑ i,w (.inr (.inr i))^2)≤(K : ℝ))
    (hΓ : ∀ s,s≤r → couplingMass (Γ s)≤(layerBudget r (2*regressionResource K R) (s+1) : ℝ))
    (hfirst : ∀ x y, |gram (coefficient xs w 1) x y-actualTiltedMoment ν (inputMatrix xs) (Γ 0) x y|≤
      (K : ℝ)/(layerBudget r (2*regressionResource K R) 1 : ℝ))
    (hcert : ∀ s,1≤s → s≤r → ∀ x y,
      |gram (coefficient xs w (s+1)) x y-tiltedMoment (coefficient xs w s) (Γ s) x y|≤
        2*(K : ℝ)/(layerBudget r (2*regressionResource K R) (s+1) : ℝ)) :
    ∃ v : Weights d (compressedWidth d q r K R) r,
      boundedWeights (compressedBound ν d q r K R) v ∧
      ∀ x, |output Real.tanh w (xs x)-output Real.tanh v (xs x)|≤1/(3*(R : ℝ)) := by
  let J := regressionResource K R
  let G := maxTiltBudget r (2*J)
  let E := TowerCompression.precision r J G
  let M := compressedWidth d q r K R
  let B := actualRowBound ν (d+q) E G
  have hJ : 0<J := by dsimp[J,regressionResource]; positivity
  have hJJ : 0<2*J := by omega
  have hKR : (0 : ℝ)<K := by exact_mod_cast hK
  have hRR : (0 : ℝ)<R := by exact_mod_cast hR
  have hRM : (1 : ℝ)≤R := by exact_mod_cast hR
  have hKJ : (K : ℝ)≤J := by
    have hRn : 1≤R^2 := Nat.one_le_pow 2 R (by omega)
    dsimp[J,regressionResource]
    exact_mod_cast (show K≤12*K*R^2 by nlinarith)
  obtain ⟨R₀,hR₀⟩ := actualTiltedMoment_has_gram_factor ν (inputMatrix xs) (Γ 0)
  let T := mixedTower R₀ Γ
  have hbase : ∀ x y, |gram (coefficient xs w 1) x y-gram R₀ x y|≤
      ((2*J : ℕ) : ℝ)/(layerBudget r (2*J) 1 : ℝ) := by
    intro x y
    rw[hR₀]
    exact (hfirst x y).trans (div_le_div_of_nonneg_right (by push_cast; linarith) (by positivity))
  have hcert' : ∀ s,1≤s → s≤r → ∀ x y,
      |gram (coefficient xs w (s+1)) x y-tiltedMoment (coefficient xs w s) (Γ s) x y|≤
        ((2*J : ℕ) : ℝ)/(layerBudget r (2*J) (s+1) : ℝ) := by
    intro s hs hsr x y
    exact (hcert s hs hsr x y).trans
      (div_le_div_of_nonneg_right (by push_cast; linarith) (by positivity))
  have hcov : ∀ x y, |covariance xs w x y-gram (T r) x y|≤1/(32*(J : ℝ)) := by
    intro x y
    rw [←gram_coefficient_final hN]
    apply (mixedTower_terminal_error (coefficient xs w) R₀ Γ hJJ hbase hΓ hcert' x y).trans
    apply one_div_le_one_div_of_le (by positivity : (0 : ℝ)<32*J)
    push_cast
    nlinarith [Nat.cast_nonneg J (α := ℝ)]
  obtain ⟨β,hβ,hpred⟩ := exists_approximate_covariance_readout hN xs w hKR
    (by positivity : (0 : ℝ)<1/(12*(R : ℝ))) henergy
  have hβ' : (∑ x,|β x|)≤12*(K : ℝ)*R := by
    convert hβ using 1 <;> field_simp <;> ring
  have hE : 0<E := TowerCompression.precision_pos r J G hJ
  have hM : 0<M := compressedWidth_pos d q r hK hR
  have hbudgets := sampling_budgets ν d q E G hE (Nat.cast_nonneg G) le_rfl
  obtain ⟨v,hv,hvcov⟩ := exists_mixed_finite_tower ν xs hd hM (fun s => gram (T s)) T Γ
    (Nat.cast_nonneg G) (by positivity : (0 : ℝ)≤1/(E : ℝ)) (Nat.cast_nonneg B)
    hR₀ (fun _ _ _ => rfl) hbudgets.1 hbudgets.2 r
    (fun s hs => (hΓ s hs).trans (by exact_mod_cast layerBudget_le_max r (2*J) (show 1≤s+1 by omega)))
    (fun s _ x y => mixedTower_step R₀ Γ s x y)
  have hvcov' : ∀ x y, |covariance xs v x y-gram (T r) x y|≤1/(32*(J : ℝ)) := by
    intro x y
    have hprec := TowerCompression.precision_error r J G hJ
    have hJR : (0 : ℝ)<J := by exact_mod_cast hJ
    have he : (r+1 : ℝ)*(8*(1+(G : ℝ))^2)^r*(1/(E : ℝ))=1/(32*(J : ℝ)) := by
      apply (mul_left_cancel₀ (by positivity : (4*(J : ℝ))≠0))
      rw [hprec]
      field_simp
      <;> ring
    simpa only [he] using hvcov x y
  let v' := withReadout v (covarianceReadout xs v β)
  refine ⟨v',?_,?_⟩
  · intro i
    have hBR : (B : ℝ)≤compressedBound ν d q r K R := by
      unfold compressedBound mixedCompressedBound
      dsimp only [B,E,G,J]
      exact_mod_cast Nat.le_add_right _ _
    have hβB : 12*(K : ℝ)*R≤compressedBound ν d q r K R := by
      have hRJ : 12*(K : ℝ)*R≤(J : ℝ) := by
        dsimp[J,regressionResource]
        push_cast
        nlinarith [mul_nonneg (show (0 : ℝ)≤12*K by positivity) (show (0 : ℝ)≤(R : ℝ)^2-R by nlinarith)]
      apply hRJ.trans
      unfold compressedBound mixedCompressedBound
      dsimp only [G,J]
      push_cast
      nlinarith [Nat.cast_nonneg (actualRowBound ν (d+q) (TowerCompression.precision r (regressionResource K R) (maxTiltBudget r (2*regressionResource K R))) (maxTiltBudget r (2*regressionResource K R))) (α := ℝ)]
    rcases i with ij | (sij | j)
    · exact (hv (.inl ij)).trans hBR
    · exact (hv (.inr (.inl sij))).trans hBR
    · exact ((covarianceReadout_bound xs v β hβ' (i := j)).trans
        (div_le_self (by positivity) (by exact_mod_cast hM))).trans hβB
  · intro x
    have hdiff : ∀ x y,|covariance xs w x y-covariance xs v x y|≤2/(32*(J : ℝ)) := by
      intro x y
      have hh := abs_sub_le (covariance xs w x y) (gram (T r) x y) (covariance xs v x y)
      rw [abs_sub_comm (gram (T r) x y)] at hh
      have hid : 1/(32*(J : ℝ))+1/(32*(J : ℝ))=2/(32*(J : ℝ)) := by ring
      linarith [hcov x y,hvcov' x y]
    have haction := TowerCompression.covariance_action_difference_bound (covariance xs w) (covariance xs v) β
      (by positivity : (0 : ℝ)≤2/(32*(J : ℝ))) hβ' hdiff x
    have hnum : (12*(K : ℝ)*R)*(2/(32*(J : ℝ)))≤1/(12*(R : ℝ)) := by
      dsimp only [J,regressionResource]
      push_cast
      field_simp
      nlinarith
    have ht := abs_sub_le (output Real.tanh w (xs x)) (∑ y,β y*covariance xs w x y)
      (output Real.tanh v' (xs x))
    change |output Real.tanh w (xs x)-output Real.tanh v' (xs x)|≤_
    have hvout := covarianceReadout_output xs v β x
    change output Real.tanh v' (xs x)=_ at hvout
    rw [hvout] at ht
    have hid : 1/(12*(R : ℝ))+1/(12*(R : ℝ))≤1/(3*(R : ℝ)) := by
      field_simp
      nlinarith
    rw [hvout]
    linarith [hpred x,haction.trans hnum]

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
