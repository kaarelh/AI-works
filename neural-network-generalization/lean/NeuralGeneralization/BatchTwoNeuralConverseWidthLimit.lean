import NeuralGeneralization.BatchTwoNeuralConverseCloning
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Algebra.Order.Floor.Semifield

/-! Cloning at every sufficiently large width with asymptotically unchanged energy. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology
open Classical Filter
open ConcreteModel

variable {d C N r : ℕ}

theorem weightedSquaredNorm_cloned_precise {k p : ℕ} (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    weightedSquaredNorm (clonedWeights e w) ≤
      ((N : ℝ)/((C : ℝ)*k))*weightedSquaredNorm w := by
  have hCR : (0 : ℝ)<C := by exact_mod_cast hC
  have hkR : (0 : ℝ)<k := by exact_mod_cast hk
  have hNR : (0 : ℝ)<N := by exact_mod_cast (Nat.mul_pos hC hk).trans_le hbelow
  have hb : (C : ℝ)*k≤N := by exact_mod_cast hbelow
  have hfactor : (1 : ℝ)≤N/((C : ℝ)*k) := (le_div_iff₀ (mul_pos hCR hkR)).mpr (by simpa)
  have hf : (d : ℝ)*k/N≤(d : ℝ)/C := by
    apply (div_le_div_iff₀ hNR hCR).mpr
    nlinarith [mul_le_mul_of_nonneg_left hb (Nat.cast_nonneg d : (0 : ℝ)≤d)]
  have hfirst : 0≤∑ i : Fin C, ∑ j : Fin (d+1), w (Sum.inl (i,j))^2 := by positivity
  have hinter : 0≤∑ s : Fin r, ∑ i : Fin C, ∑ j : Fin C,
      w (Sum.inr (Sum.inl (s,i,j)))^2 := by positivity
  have hcfirst : 0≤(d : ℝ)/C*(∑ i : Fin C, ∑ j : Fin (d+1), w (Sum.inl (i,j))^2) := by positivity
  have hf1 := mul_le_mul_of_nonneg_right hf hfirst
  have hf2 := mul_le_mul_of_nonneg_right hfactor hcfirst
  have hi := mul_le_mul_of_nonneg_right hfactor hinter
  have he : (N : ℝ)/(C*k)*(C : ℝ)=N/(k : ℝ) := by field_simp
  rw [weightedSquaredNorm_cloned hk]
  unfold weightedSquaredNorm
  simp only [mul_add]
  rw [←mul_assoc _ (C : ℝ),he]
  nlinarith

def paddedCloneEquiv (C N : ℕ) (hC : 0<C) :
    ((Fin C × Fin (N/C)) ⊕ Fin (N%C)) ≃ Fin N :=
  Fintype.equivOfCardEq (by simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]; have h := Nat.mod_add_div N C; omega)

def paddedClone (hC : 0<C) (N : ℕ) (w : Weights d C r) : Weights d N r :=
  clonedWeights (paddedCloneEquiv C N hC) w

theorem paddedClone_supported (hC : 0<C) (hCN : C≤N) (w : Weights d C r)
    {Λ U : ℝ} {f : BooleanFunction d} (hw : w ∈ functionSupport Λ U f) :
    paddedClone hC N w ∈ functionSupport Λ U f := by
  have hk : 0<N/C := Nat.div_pos hCN hC
  exact ⟨gainSupport_cloned hC hk (hC.trans_le hCN) _ w Λ U hw.1,
    (marginEvent_cloned_iff hk Real.tanh _ w (1/2) f).mpr hw.2⟩

theorem paddedClone_energy_le (hC : 0<C) (hCN : C≤N) (w : Weights d C r) :
    weightedSquaredNorm (paddedClone hC N w) ≤
      ((N : ℝ)/((C : ℝ)*(N/C : ℕ)))*weightedSquaredNorm w :=
  weightedSquaredNorm_cloned_precise hC (Nat.div_pos hCN hC) (Nat.mul_div_le N C)
    (paddedCloneEquiv C N hC) w

theorem clone_factor_tendsto (hC : 0<C) :
    Tendsto (fun N : ℕ => (N : ℝ)/((C : ℝ)*(N/C : ℕ))) atTop (𝓝 1) := by
  have hCR : (0 : ℝ)<C := by exact_mod_cast hC
  have hfloor := (tendsto_nat_floor_mul_div_atTop (show 0≤1/(C : ℝ) by positivity)).comp
    tendsto_natCast_atTop_atTop
  have he (N : ℕ) : ⌊(1/(C : ℝ))*(N : ℝ)⌋₊=N/C := by
    rw [one_div_mul_eq_div,Nat.floor_div_eq_div]
  change Tendsto (fun N : ℕ => (⌊(1/(C : ℝ))*(N : ℝ)⌋₊ : ℝ)/(N : ℝ)) atTop (𝓝 (1/(C : ℝ))) at hfloor
  simp_rw [he] at hfloor
  have hmul := hfloor.const_mul (C : ℝ)
  have hid : (C : ℝ)*(1/(C : ℝ))=1 := by field_simp
  rw [hid] at hmul
  have hinv := hmul.inv₀ (by norm_num : (1 : ℝ)≠0)
  convert hinv using 1
  · ext N
    change (N : ℝ)/((C : ℝ)*(N/C : ℕ)) = ((C : ℝ)*(((N/C : ℕ) : ℝ)/(N : ℝ)))⁻¹
    rw [←mul_div_assoc,inv_div]
  · simp

end
end NeuralGeneralization.BatchTwoNeuralConverse
