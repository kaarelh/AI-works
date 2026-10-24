import NeuralGeneralization.BatchTwoMergingBounds

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem power_mono_in_exponent {S : ℝ} (hS : 1≤S) {a b : ℕ} (hab : a≤b) : S^a≤S^b :=
  pow_le_pow_right₀ hS hab

theorem mainReadoutBound_le {d C r : ℕ} {S ε : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) (hlogε : -Real.log (ε/4)≤S) :
    mainReadoutBound d C r ε≤100000*(C:ℝ)*S^3 := by
  have hD := mergingTargetCost_le hC hS hd hr hlogC
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hS3 : S≤S^3 := by simpa using power_mono_in_exponent (by linarith : 1≤S) (show 1≤3 by omega)
  have hcS := mul_le_mul_of_nonneg_right hC1 (by linarith : 0≤S)
  have hcS3 := mul_le_mul_of_nonneg_left hS3 (Nat.cast_nonneg C : (0:ℝ)≤C)
  unfold mainReadoutBound
  nlinarith

theorem mainPopulationBound_le {d C r : ℕ} {S ε : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) (hlogε : -Real.log (ε/4)≤S)
    (hε : 0<ε) (hε1 : ε≤1) :
    (mainPopulationBound d C r ε:ℝ)≤2000000*(C:ℝ)*S^3 := by
  have hB := mainReadoutBound_le hC hS hd hr hlogC hlogε
  have hB0 := mainReadoutBound_ge_eight (d:=d) (C:=C) (r:=r) hε hε1
  have hc := Nat.ceil_lt_add_one (show 0≤1+16*mainReadoutBound d C r ε by linarith)
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hS3 : 1≤S^3 := one_le_pow₀ (by linarith : 1≤S)
  have hcs := mul_le_mul_of_nonneg_left hS3 (Nat.cast_nonneg C : (0:ℝ)≤C)
  change (⌈1+16*mainReadoutBound d C r ε⌉₊:ℝ)≤_
  nlinarith

theorem mainEnergyBound_le {d C r : ℕ} {S ε : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) (hlogε : -Real.log (ε/4)≤S)
    (hε : 0<ε) (hε1 : ε≤1) :
    mainEnergyBound d C r ε≤1000000000*(C:ℝ)*S^4 := by
  have hD := mergingTargetCost_le hC hS hd hr hlogC
  have hQ := mainPopulationBound_le hC hS hd hr hlogC hlogε hε hε1
  have hQ0 : (0:ℝ)<mainPopulationBound d C r ε := by exact_mod_cast mainPopulationBound_pos hε hε1
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hS1 : 1≤S := by linarith
  have hS0 : 0≤S := by linarith
  have hlogQ := log_le_of_monomial_bound 3 hQ0 (by norm_num : (1:ℝ)≤2000000) hC1 hS1 hlogC hQ
  have hlogQ0 := Real.log_nonneg (show (1:ℝ)≤mainPopulationBound d C r ε by exact_mod_cast mainPopulationBound_pos hε hε1)
  have hlog2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  have hdim0 : (0:ℝ)≤(d+2+r*mainPopulationBound d C r ε:ℕ) := Nat.cast_nonneg _
  have hdim : (d+2+r*mainPopulationBound d C r ε:ℕ)≤
      S+(r:ℝ)*(2000000*(C:ℝ)*S^3) := by
    push_cast
    have hh := mul_le_mul_of_nonneg_left hQ (Nat.cast_nonneg r : (0:ℝ)≤r)
    linarith
  have hlogterm := mul_le_mul (show 2*((r:ℝ)+1)≤2*S by linarith) hlogQ hlogQ0 (by positivity : 0≤2*S)
  have hdimterm := mul_le_mul_of_nonneg_left hlog2 (by positivity : (0:ℝ)≤((d+2+r*mainPopulationBound d C r ε:ℕ):ℝ)/2)
  have hrQ := mul_le_mul_of_nonneg_right hr (by positivity : 0≤2000000*(C:ℝ)*S^3)
  have hS14 := power_mono_in_exponent hS1 (show 1≤4 by omega)
  have hS24 := power_mono_in_exponent hS1 (show 2≤4 by omega)
  have hS34 := power_mono_in_exponent hS1 (show 3≤4 by omega)
  have hcS4 := mul_le_mul_of_nonneg_right hC1 (pow_nonneg hS0 4)
  have hc34 := mul_le_mul_of_nonneg_left hS34 (Nat.cast_nonneg C : (0:ℝ)≤C)
  unfold mainEnergyBound partitionEntropyBudget
  norm_num only [Nat.cast_ofNat] at hlogQ hlogterm
  push_cast at hdim hdimterm hdim0
  nlinarith

theorem mainEnergyBound_nonneg {d C r : ℕ} {ε : ℝ} (hε : 0<ε) (hε1 : ε≤1) :
    0≤mainEnergyBound d C r ε := by
  have hD := mergingTargetCost_nonneg d C r
  have hE := partitionEntropyBudget_nonneg d r (mainPopulationBound_pos (d:=d) (C:=C) (r:=r) hε hε1)
  have hl := Real.log_nonpos (by positivity : 0≤ε/4) (by linarith : ε/4≤1)
  unfold mainEnergyBound
  linarith

end NeuralGeneralization.BatchTwoMerging
