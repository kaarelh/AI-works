import NeuralGeneralization.BatchTwoActivationConcreteNormalization

/-!
# Simultaneously normalizing a family of concrete Bayesian networks

Every member can have a different learner width. The identities concern the
actual architecture and its weighted Gaussian energy, not an assumed feature
representation.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel CompressionSampling SquaredSampling

variable {U : Type*} [Nonempty U] {d r n : ℕ}
variable {φ : ℝ→ℝ} {ℓ K : ℝ}

def concreteFamilyState (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0<ℓ) (hK : 0<K)
    (N : U→ℕ) (W : ∀ p, Weights d (N p) r) (x : Fin n→Cube d) :=
  matrixFamilyState (fun s p => concreteWidth d (N p) s)
    (fun s p _ => concreteActivation hφ hℓ hK (N p) s)
    (fun s p => concreteRows (W p) K s) (fun _ i => concreteInput (x i))

theorem concreteFamilyState_hidden (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0<ℓ) (hK : 0<K) (N : U→ℕ) (hN : ∀p, 0<N p)
    (W : ∀ p, Weights d (N p) r) (x : Fin n→Cube d) (s : ℕ) (hs : s≤r) :
    ∀ p i, concreteFamilyState hφ hℓ hK N W x (s+1) p i =
      WithLp.toLp 2 (fun j => hiddenPrefix φ (W p) (x i) s j /
        (Real.sqrt (N p)*(ℓ*K)^(s+1))) := by
  induction s with
  | zero =>
    intro p i
    apply PiLp.ext
    intro j
    change (concreteActivation hφ hℓ hK (N p) 0).val
      ⟪normalizedFirstRow (W p) K j, concreteInput (x i)⟫ = _
    simpa only [hiddenPrefix_zero, zero_add, pow_one] using
      concrete_first_identity hφ hℓ hK (hN p) (W p) (x i) j
  | succ s ih =>
    have hsr : s<r := by omega
    have hprev := ih (by omega)
    intro p i
    apply PiLp.ext
    intro j
    change (concreteActivation hφ hℓ hK (N p) (s+1)).val
      ⟪concreteRows (W p) K (s+1) j,
        concreteFamilyState hφ hℓ hK N W x (s+1) p i⟫ = _
    rw [hprev]
    simp only [concreteRows, dif_pos hsr]
    have h := concrete_internal_identity hφ hℓ hK (hN p) (W p)
      ⟨s,hsr⟩ (hiddenPrefix φ (W p) (x i) s) j
    have he := hiddenPrefix_succ φ (W p) (x i) (⟨s,hsr⟩ : Fin r)
    change hiddenPrefix φ (W p) (x i) (s+1) = _ at he
    rw [he]
    exact h

theorem concreteFamilyState_final (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0<ℓ) (hK : 0<K) (N : U→ℕ) (hN : ∀p, 0<N p)
    (W : ∀ p, Weights d (N p) r) (x : Fin n→Cube d) (p : U) (i : Fin n) :
    concreteFamilyState hφ hℓ hK N W x (r+1) p i =
      WithLp.toLp 2 (fun j => finalHidden φ (W p) (x i) j /
        (Real.sqrt (N p)*(ℓ*K)^(r+1))) := by
  simpa only [hiddenPrefix_last] using
    concreteFamilyState_hidden hφ hℓ hK N hN W x r le_rfl p i

theorem concreteFamilyState_output (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0<ℓ) (hK : 0<K) (N : U→ℕ) (hN : ∀p, 0<N p)
    (W : ∀ p, Weights d (N p) r) (x : Fin n→Cube d) (p : U) (i : Fin n) :
    networkOutput φ (W p) (x i) =
      (K*(ℓ*K)^(r+1))*⟪normalizedReadout (W p) K,
        concreteFamilyState hφ hℓ hK N W x (r+1) p i⟫ := by
  have hs : Real.sqrt (N p:ℝ)≠0 := (Real.sqrt_pos.mpr (by exact_mod_cast hN p)).ne'
  have hp : (ℓ*K)^(r+1)≠0 := pow_ne_zero _ (mul_ne_zero hℓ.ne' hK.ne')
  rw [concreteFamilyState_final hφ hℓ hK N hN]
  simp only [networkOutput, PiLp.inner_apply, RCLike.inner_apply, normalizedReadout,
    conj_trivial, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  field_simp
  <;> ring

theorem concreteFamilyState_norm_le (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d) (N : U→ℕ) (hN : ∀p, 0<N p)
    (W : ∀ p, Weights d (N p) r) (hW : ∀p, weightedSquaredNorm (W p)≤K)
    (x : Fin n→Cube d) (s : ℕ) :
    ∀ p i, ‖concreteFamilyState hφ hℓ (lt_of_lt_of_le zero_lt_one hK) N W x s p i‖ ≤
      (d:ℝ)+1 := by
  apply matrixFamilyState_norm_le
  · intro s p
    cases s <;> simp only [concreteWidth]
    · omega
    · exact hN p
  · intro s p
    exact concreteRows_frobenius hd (hN p) (W p) hK (hW p) s
  · intro p i
    exact concreteInput_norm_le (x i)

end NeuralGeneralization.BatchTwoActivation
