import NeuralGeneralization.OnlineLowerScoreBound

/-! Width-independent output caps for activations with a constant offset. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLower
open ConcreteModel

lemma readout_squared_sum_le_energy {d N : ℕ} (w : Weights d N 0) :
    (N : ℝ)*(∑j,readoutAtoms w j^2) ≤ weightedSquaredNorm w := by
  unfold weightedSquaredNorm readoutAtoms
  have h : 0 ≤ (d : ℝ)/(N : ℝ)*∑j,∑k,w (Sum.inl (j,k))^2 := mul_nonneg (div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _))
    (Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _)
  simp only [Finset.univ_eq_empty,Finset.sum_empty,add_zero]
  linarith

theorem readout_absolute_sum_le_sqrt_energy {d N : ℕ} (w : Weights d N 0) :
    (∑j,|readoutAtoms w j|) ≤ Real.sqrt (weightedSquaredNorm w) := by
  have hs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun _ : Fin N => (1 : ℝ))
    (fun j => |readoutAtoms w j|)
  simp only [one_mul,one_pow,Finset.sum_const,Finset.card_univ,Fintype.card_fin,
    nsmul_eq_mul,mul_one,sq_abs] at hs
  have henergy := readout_squared_sum_le_energy w
  have he := Real.sq_sqrt (weightedSquaredNorm_nonneg w)
  have hn := Real.sqrt_nonneg (weightedSquaredNorm w)
  nlinarith

/-- An affine growth bound on an activation gives a uniform shallow-network
output cap, including when its value at zero is nonzero. -/
theorem networkOutput_abs_le_energy_add_offset {d N : ℕ}
    (hd : 0 < d) (hN : 0 < N) (φ : ℝ → ℝ) (a : ℝ) (ha : 0 ≤ a)
    (hφ : ∀t,|φ t| ≤ |t|+a) (w : Weights d N 0) (x : Cube d) :
    |networkOutput φ w x| ≤ weightedSquaredNorm w+a*Real.sqrt (weightedSquaredNorm w) := by
  rw [networkOutput_eq_atomicScore]
  have hsum : |atomicScore φ (incomingAtoms w) (readoutAtoms w) x| ≤
      atomicWeightedCost (incomingAtoms w) (readoutAtoms w)+a*(∑j,|readoutAtoms w j|) := by
    calc
      _ ≤ ∑j,|readoutAtoms w j*φ (∑k,incomingAtoms w j k*inputVector x k)| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑j,(2*|readoutAtoms w j| *Real.sqrt (incomingAtomCost (incomingAtoms w j))+
        a*|readoutAtoms w j|) := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul]
        have hh : |φ (∑k,incomingAtoms w j k*inputVector x k)| ≤
            2*Real.sqrt (incomingAtomCost (incomingAtoms w j))+a := by
          have hh := hφ (∑k,incomingAtoms w j k*inputVector x k)
          have hb := input_dot_abs_le_atom_cost hd (incomingAtoms w j) x
          linarith
        have hm := mul_le_mul_of_nonneg_left hh (abs_nonneg (readoutAtoms w j))
        nlinarith
      _ = _ := by simp only [Finset.sum_add_distrib,←Finset.mul_sum,atomicWeightedCost]
  have hE := atomicWeightedCost_le_weightedSquaredNorm hN w
  have hR := mul_le_mul_of_nonneg_left (readout_absolute_sum_le_sqrt_energy w) ha
  linarith

/-- A fixed energy cap supplies a fixed output cap at every positive width. -/
theorem networkOutput_abs_le_offset_cap {d N : ℕ}
    (hd : 0 < d) (hN : 0 < N) (φ : ℝ → ℝ) (a : ℝ) (ha : 0 ≤ a)
    (hφ : ∀t,|φ t| ≤ |t|+a) (w : Weights d N 0) (cap : ℝ)
    (hcap : weightedSquaredNorm w ≤ cap) (x : Cube d) :
    |networkOutput φ w x| ≤ cap+a*Real.sqrt cap := by
  exact (networkOutput_abs_le_energy_add_offset hd hN φ a ha hφ w x).trans
    (add_le_add hcap (mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt hcap) ha))
end NeuralGeneralization.OnlineLower
