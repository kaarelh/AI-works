import NeuralGeneralization.BatchTwoActivationConcreteFamily

/-!
# Concrete all-width exponential moment and shattering obstruction

Every hypothesis below is an actual finite-width network. Its weighted energy
controls the whole family at once. Shattering supplies witnesses for all sign
patterns, which gives a lower exponential moment and hence a capacity bound.
-/

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel SquaredSampling

variable {U : Type*} [Nonempty U] {d r n : ℕ}
variable {φ : ℝ→ℝ} {ℓ K : ℝ}

theorem concreteFamilyState_mgf (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d) (N : U→ℕ) (hN : ∀p, 0<N p)
    (W : ∀ p, Weights d (N p) r) (hW : ∀p, weightedSquaredNorm (W p)≤K)
    (x : Fin n→Cube d) {q : ℕ} (hq : 0<q) (a : ℝ) (ha : 0≤a) (s : ℕ) :
    finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
      (concreteFamilyState hφ hℓ (lt_of_lt_of_le zero_lt_one hK) N W x s) ε)) ≤
      (activationPeelingFactor n q ((d:ℝ)+1) a)^s *
        (2*((d:ℝ)+1)*Real.exp (a^2*((d:ℝ)+1)*n/2)) := by
  have hdim : ∀ s p, 0<concreteWidth d (N p) s := by
    intro s p
    cases s <;> simp only [concreteWidth]
    · omega
    · exact hN p
  have h := matrixFamilyState_mgf hq (fun s p => concreteWidth d (N p) s) hdim
    (fun s p _ => concreteActivation hφ hℓ (lt_of_lt_of_le zero_lt_one hK) (N p) s)
    (fun s p => concreteRows (W p) K s) (fun _ i => concreteInput (x i))
    (fun s p => concreteRows_frobenius hd (hN p) (W p) hK (hW p) s)
    (by positivity : (0:ℝ)<(d:ℝ)+1) (fun _ i => concreteInput_norm_le (x i)) a ha s
  have he (ε : Fin n→Bool) : dependentVectorProcess
      (fun (_ : U) i => concreteInput (x i)) ε =
      ‖∑ i, cubeCoordinateSign (ε i) • concreteInput (x i)‖ := by
    simp only [dependentVectorProcess, processSup, Set.range_const, csSup_singleton]
  change finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
    (concreteFamilyState hφ hℓ (lt_of_lt_of_le zero_lt_one hK) N W x s) ε)) ≤
    (activationPeelingFactor n q ((d:ℝ)+1) a)^s *
      finiteMean (fun ε : Fin n→Bool => Real.exp (a*dependentVectorProcess
        (fun (_ : U) i => concreteInput (x i)) ε)) at h
  simp_rw [he] at h
  have hi := input_vector_sign_mgf n (fun i => concreteInput (x i))
    (fun i j => concreteInput_abs_le (x i) j) a ha
  simp only [Fintype.card_fin, Nat.cast_add, Nat.cast_one] at hi
  exact h.trans (mul_le_mul_of_nonneg_left hi
    (pow_nonneg (activationPeelingFactor_nonneg _ _ _ _) _))

def outputNormalization (r : ℕ) (ℓ K : ℝ) : ℝ := K*(ℓ*K)^(r+1)

theorem outputNormalization_pos (r : ℕ) {ℓ K : ℝ} (hℓ : 0<ℓ) (hK : 0<K) :
    0<outputNormalization r ℓ K := by unfold outputNormalization; positivity

theorem shattering_mgf_bound (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0<ℓ) (hK : 1≤K) (hd : 1≤d) (x : Fin n→Cube d)
    (hshatter : ∀ ε : Fin n→Bool, ∃ N, 0<N ∧ ∃ w : Weights d N r,
      weightedSquaredNorm w≤K ∧ ∀i, (1/2:ℝ)≤cubeCoordinateSign (ε i)*networkOutput φ w (x i))
    {q : ℕ} (hq : 0<q) (a : ℝ) (ha : 0≤a) :
    Real.exp (a*((n:ℝ)/(2*outputNormalization r ℓ K))) ≤
      (activationPeelingFactor n q ((d:ℝ)+1) a)^(r+1) *
        (2*((d:ℝ)+1)*Real.exp (a^2*((d:ℝ)+1)*n/2)) := by
  classical
  choose N hN W hW hmargin using hshatter
  have hKp : 0<K := lt_of_lt_of_le zero_lt_one hK
  have hP := outputNormalization_pos r hℓ hKp
  let Z := concreteFamilyState hφ hℓ hKp N W x (r+1)
  have hZ := concreteFamilyState_norm_le hφ hℓ hK hd N hN W hW x (r+1)
  have lower (ε : Fin n→Bool) : (n:ℝ)/(2*outputNormalization r ℓ K) ≤
      dependentVectorProcess Z ε := by
    have hs : (n:ℝ)/2 ≤ ∑ i, cubeCoordinateSign (ε i)*networkOutput φ (W ε) (x i) := by
      calc
        _ = ∑ _i : Fin n, (1/2:ℝ) := by simp; ring
        _ ≤ _ := Finset.sum_le_sum (fun i _ => hmargin ε i)
    have hid : (∑ i, cubeCoordinateSign (ε i)*networkOutput φ (W ε) (x i)) =
        outputNormalization r ℓ K *
          ⟪normalizedReadout (W ε) K, ∑ i, cubeCoordinateSign (ε i) • Z ε i⟫ := by
      simp only [inner_sum, real_inner_smul_right, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      rw [concreteFamilyState_output hφ hℓ hKp N hN W x ε i]
      dsimp [outputNormalization, Z]
      ring
    rw [hid] at hs
    have hn := normalizedReadout_norm_le (W ε) hK (hW ε)
    have hh := linearRow_abs_le (normalizedReadout (W ε) K) hn
      (∑ i, cubeCoordinateSign (ε i) • Z ε i)
      (norm_le_dependentVectorProcess Z hZ ε ε)
    have he : (n:ℝ)/2 ≤ outputNormalization r ℓ K*dependentVectorProcess Z ε := by
      calc
        _ ≤ _ := hs
        _ ≤ _ := mul_le_mul_of_nonneg_left
          ((le_abs_self _).trans hh) hP.le
    apply (div_le_iff₀ (mul_pos (by norm_num) hP)).mpr
    linarith
  have hlo := finiteMean_mono (fun ε =>
    Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left (lower ε) ha))
  rw [finiteMean_const] at hlo
  exact hlo.trans (concreteFamilyState_mgf hφ hℓ hK hd N hN W hW x hq a ha (r+1))

end NeuralGeneralization.BatchTwoActivation
