import NeuralGeneralization.BatchTwoOnlineBalancedCompiler

/-! Actual Gaussian energy of balanced-clone Boolean compilers. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging
variable {d C N r : ℕ} {k : Fin C→ℕ}

theorem grouped_internal_energy (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hN : 0<N) (hk : ∀b,0<k b)
    (hwidth : ∀b,N≤2*C*k b) (A a : ℝ) (s : Fin r) :
    (∑i,∑j,groupedWeights B e A a (.inr (.inl (s,i,j)))^2)≤18*(C:ℝ)*A^2 := by
  have hNR : (0:ℝ)<N := by exact_mod_cast hN
  have hrow (i : Fin N) :
      (∑j,groupedWeights B e A a (.inr (.inl (s,i,j)))^2)≤18*(C:ℝ)*A^2/N := by
    rw [grouped_internal_row_energy B e hk]
    have hh : (∑b : Fin C,(B.internal s (layoutGroup e i)).coeff B.constant b^2/(k b:ℝ))≤
        (2*(C:ℝ)/N)*(∑b : Fin C,(B.internal s (layoutGroup e i)).coeff B.constant b^2) := by
      rw [Finset.mul_sum]
      apply Finset.sum_le_sum
      intro b _
      have hkR : (0:ℝ)<k b := by exact_mod_cast hk b
      have hr : 1/(k b:ℝ)≤2*(C:ℝ)/N := by
        apply (div_le_div_iff₀ hkR hNR).mpr
        simpa only [one_mul] using (show (N:ℝ)≤2*(C:ℝ)*(k b:ℝ) by exact_mod_cast hwidth b)
      have hm := mul_le_mul_of_nonneg_right hr (sq_nonneg ((B.internal s (layoutGroup e i)).coeff B.constant b))
      simpa only [one_div,div_eq_mul_inv,mul_comm,mul_one] using hm
    have hg := mul_le_mul_of_nonneg_left ((B.internal s (layoutGroup e i)).coeff_squaredSum_le B.constant)
      (show 0≤2*(C:ℝ)/N by positivity)
    have hm := mul_le_mul_of_nonneg_left (hh.trans hg) (sq_nonneg A)
    exact hm.trans_eq (by ring)
  calc
    _ ≤ ∑_i : Fin N,18*(C:ℝ)*A^2/N := Finset.sum_le_sum fun i _=>hrow i
    _ = _ := by simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]; field_simp

theorem grouped_readout_energy_bounds (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hk : ∀b,0<k b)
    (hwidth : ∀b,N≤2*C*k b) (hwidth' : ∀b,C*k b≤2*N) (A a : ℝ) :
    a^2*(C:ℝ)/2≤readoutEnergy (groupedWeights B e A a) ∧
    readoutEnergy (groupedWeights B e A a)≤2*(C:ℝ)*a^2 := by
  have hkR : (0:ℝ)<k B.output := by exact_mod_cast hk B.output
  rw [grouped_readout_energy B e hk]
  constructor
  · apply (le_div_iff₀ hkR).mpr
    have hh := mul_le_mul_of_nonneg_right
      (show (C:ℝ)*(k B.output:ℝ)≤2*(N:ℝ) by exact_mod_cast hwidth' B.output) (sq_nonneg a)
    nlinarith
  · apply (div_le_iff₀ hkR).mpr
    have hh := mul_le_mul_of_nonneg_right
      (show (N:ℝ)≤2*(C:ℝ)*(k B.output:ℝ) by exact_mod_cast hwidth B.output) (sq_nonneg a)
    nlinarith

theorem grouped_teacher_energy (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hN : 0<N) (hk : ∀b,0<k b)
    (hwidth : ∀b,N≤2*C*k b) (hwidth' : ∀b,C*k b≤2*N) (A a : ℝ) :
    weightedSquaredNorm (groupedWeights B e A a)≤9*d*A^2+18*r*C*A^2+2*C*a^2 := by
  have hNR : (0:ℝ)<N := by exact_mod_cast hN
  have hf := mul_le_mul_of_nonneg_left (grouped_first_energy B e A a) (show 0≤(d:ℝ)/N by positivity)
  have he : ((d:ℝ)/N)*((N:ℝ)*9*A^2)=9*d*A^2 := by field_simp
  rw [he] at hf
  have hi : (∑s,∑i,∑j,groupedWeights B e A a (.inr (.inl (s,i,j)))^2)≤18*r*C*A^2 := by
    calc
      _ ≤ ∑_s : Fin r,18*(C:ℝ)*A^2 := Finset.sum_le_sum fun s _=>grouped_internal_energy B e hN hk hwidth A a s
      _ = _ := by simp; ring
  have ho := (grouped_readout_energy_bounds B e hk hwidth hwidth' A a).2
  unfold weightedSquaredNorm
  change _+_+readoutEnergy _≤_
  linarith

theorem grouped_perturbed_readout_lower (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hN : 0<N) (hC : 0<C) (hk : ∀b,0<k b)
    (hwidth : ∀b,N≤2*C*k b) (hwidth' : ∀b,C*k b≤2*N)
    (w : Weights d N r) {A a ρ : ℝ} (ha : 0≤a) (hρ : 0≤ρ) (hρa : ρ≤a/4)
    (he : ∀i,|w (.inr (.inr i))-groupedWeights B e A a (.inr (.inr i))|≤ρ/N) :
    a^2*(C:ℝ)/8≤readoutEnergy w := by
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hc := (grouped_readout_energy_bounds B e hk hwidth hwidth' A a).1
  have hp := readoutEnergy_compare_of_coordinate_error hN w (groupedWeights B e A a) hρ he
  have hr : ρ^2≤a^2/16 := by nlinarith
  have hCa := mul_le_mul_of_nonneg_right hC1 (sq_nonneg a)
  nlinarith

theorem grouped_robustRadius_le (w : Weights d N r) {a c τ : ℝ}
    (ha : 0≤a) (hτ : 0≤τ) (henergy : a^2*(C:ℝ)/8≤readoutEnergy w)
    (hcal : 4*c≤τ*a*Real.sqrt C) : robustRadius c w≤τ := by
  have hp : 0<1+((r:ℝ)+1)*readoutEnergy w := by have hh := readoutEnergy_nonneg w; positivity
  have hs : a*Real.sqrt C/4≤Real.sqrt (1+((r:ℝ)+1)*readoutEnergy w) := by
    apply (Real.le_sqrt (by positivity) hp.le).mpr
    have he := readoutEnergy_nonneg w
    have hr := mul_nonneg (Nat.cast_nonneg r : (0:ℝ)≤r) he
    have hc := Real.sq_sqrt (Nat.cast_nonneg C : (0:ℝ)≤C)
    have hCa := mul_nonneg (sq_nonneg a) (Nat.cast_nonneg C : (0:ℝ)≤C)
    nlinarith
  unfold robustRadius
  apply (div_le_iff₀ (Real.sqrt_pos.mpr hp)).mpr
  have hh := mul_le_mul_of_nonneg_left hs hτ
  nlinarith

end NeuralGeneralization.BatchTwoOnlineBalanced
