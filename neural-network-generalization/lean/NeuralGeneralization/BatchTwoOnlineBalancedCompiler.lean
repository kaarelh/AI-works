import NeuralGeneralization.BatchTwoOnlineBalancedGroups

/-! Boolean compilation with a distinct positive multiplicity for each hidden wire. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging
variable {d C N r : ℕ} {k : Fin C→ℕ}

def groupedWeights (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (A a : ℝ) : Weights d N r
  | .inl (i,j)=>A*(B.first (layoutGroup e i)).coeff 0 j
  | .inr (.inl (s,i,j))=>A*(B.internal s (layoutGroup e i)).coeff B.constant (layoutGroup e j)/(k (layoutGroup e j):ℝ)
  | .inr (.inr i)=>if layoutGroup e i=B.output then a/(k (layoutGroup e i):ℝ) else 0

theorem grouped_first_preactivation (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (A a : ℝ) (x : Cube d) (i : Fin N) :
    (∑j,groupedWeights B e A a (.inl (i,j))*inputVector x j)=
      A*(B.first (layoutGroup e i)).linear 1 (inputVector x) := by
  simp only [groupedWeights,mul_assoc,←Finset.mul_sum,DigitalGate.sum_coeff]
  rfl

theorem grouped_internal_preactivation (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (A a : ℝ) (h : Fin N→ℝ) (s : Fin r) (i : Fin N) :
    (∑j,groupedWeights B e A a (.inr (.inl (s,i,j)))*h j)=
      A*(B.internal s (layoutGroup e i)).linear (layoutMean e h B.constant) (layoutMean e h) := by
  rw [←(B.internal s (layoutGroup e i)).sum_coeff B.constant (layoutMean e h),←e.sum_comp]
  simp only [Fintype.sum_sigma,groupedWeights,layoutGroup,Equiv.symm_apply_apply]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro b _
  simp only [layoutMean,←Finset.mul_sum,div_mul_eq_mul_div,←Finset.sum_div]
  ring

theorem grouped_readout (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (A a : ℝ) (h : Fin N→ℝ) :
    (∑i,groupedWeights B e A a (.inr (.inr i))*h i)=a*layoutMean e h B.output := by
  rw [←e.sum_comp]
  simp only [Fintype.sum_sigma,groupedWeights,layoutGroup,Equiv.symm_apply_apply]
  rw [Finset.sum_eq_single B.output]
  · simp only [ite_true,layoutMean,←Finset.mul_sum]
    ring
  · intro b _ hb
    simp [hb]
  · simp

theorem grouped_signed_first (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) {A a : ℝ} (hA : 0≤A) (x : Cube d) (i : Fin N) :
    A≤layoutBits e (B.firstBits x) i*(∑j,groupedWeights B e A a (.inl (i,j))*inputVector x j) := by
  rw [grouped_first_preactivation]
  have hh := (B.first (layoutGroup e i)).signed_linear_margin (Fin.cases true x)
  rw [←inputVector_eq_labelBits] at hh
  have hm := mul_le_mul_of_nonneg_left hh hA
  change A≤labelReal ((B.first (layoutGroup e i)).eval (Fin.cases true x))*
    (A*(B.first (layoutGroup e i)).linear 1 (inputVector x))
  nlinarith

theorem grouped_signed_internal (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hk : ∀b,0<k b) (hwidth : ∀b,N≤2*C*k b)
    {A a ε : ℝ} (hA : 0≤A) (hsmall : 2*(C:ℝ)*ε^2≤(1/16:ℝ)^2)
    (h : Fin N→ℝ) (b : Fin C→Bool) (s : Fin r)
    (hc : ∀i j l,B.internal s i=.nand j l→b B.constant=true)
    (hstate : (∑i,(h i-layoutBits e b i)^2)≤(N:ℝ)*ε^2) (i : Fin N) :
    A/2≤layoutBits e (B.stepBits b s) i*(∑j,groupedWeights B e A a (.inr (.inl (s,i,j)))*h j) := by
  rw [grouped_internal_preactivation]
  have hh := (B.internal s (layoutGroup e i)).signed_linear_near_bits b (layoutMean e h)
    B.constant (hc (layoutGroup e i)) (layoutMean_error_le e hk hwidth h b (by norm_num) hsmall hstate)
  have hm := mul_le_mul_of_nonneg_left hh hA
  change A/2≤labelReal ((B.internal s (layoutGroup e i)).eval b)*
    (A*(B.internal s (layoutGroup e i)).linear (layoutMean e h B.constant) (layoutMean e h))
  nlinarith

theorem grouped_first_energy (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (A a : ℝ) :
    (∑i,∑j,groupedWeights B e A a (.inl (i,j))^2)≤(N:ℝ)*9*A^2 := by
  calc
    _ = ∑i,A^2*(∑j,(B.first (layoutGroup e i)).coeff 0 j^2) := by
      simp only [groupedWeights,mul_pow,Finset.mul_sum]
    _ ≤ ∑_i:Fin N,A^2*9 := Finset.sum_le_sum fun i _=>
      mul_le_mul_of_nonneg_left ((B.first (layoutGroup e i)).coeff_squaredSum_le 0) (sq_nonneg A)
    _ = _ := by simp; ring

theorem grouped_internal_row_energy (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hk : ∀b,0<k b)
    (A a : ℝ) (s : Fin r) (i : Fin N) :
    (∑j,groupedWeights B e A a (.inr (.inl (s,i,j)))^2)=
      A^2*∑b : Fin C,(B.internal s (layoutGroup e i)).coeff B.constant b^2/(k b:ℝ) := by
  rw [←e.sum_comp]
  simp only [Fintype.sum_sigma,groupedWeights,layoutGroup,Equiv.symm_apply_apply,
    Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro b _
  have hb : (k b:ℝ)≠0 := by exact_mod_cast (hk b).ne'
  field_simp

theorem grouped_readout_energy (B : LayeredBooleanCircuit d C r)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (hk : ∀b,0<k b) (A a : ℝ) :
    readoutEnergy (groupedWeights B e A a)=(N:ℝ)*a^2/(k B.output:ℝ) := by
  have hkR : (k B.output:ℝ)≠0 := by exact_mod_cast (hk B.output).ne'
  unfold readoutEnergy
  rw [←e.sum_comp]
  simp only [Fintype.sum_sigma,groupedWeights,layoutGroup,Equiv.symm_apply_apply,
    ite_pow,zero_pow (by omega : 2≠0),Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  simp only [mul_ite,mul_zero,Finset.sum_ite_eq',Finset.mem_univ,ite_true]
  field_simp

end NeuralGeneralization.BatchTwoOnlineBalanced
