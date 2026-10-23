import NeuralGeneralization.BatchTwoMergingSharpSupport
import NeuralGeneralization.BatchTwoMergingGeluTeacher

/-! Exact layerwise compiler budgets for the two manuscript parameter choices. -/
noncomputable section
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
variable {d C N r k p : ℕ}

theorem cloned_readout_upper (hk:0<k) (habove:N≤2*C*k)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (w:Weights d C r) {V:ℝ}
    (hV:0≤V) (hw:(∑i,w (Sum.inr (Sum.inr i))^2)≤V) :
    readoutEnergy (clonedWeights e w)≤2*C*V := by
  have hkr:(0:ℝ)<k := by exact_mod_cast hk
  have har:(N:ℝ)≤2*C*k := by exact_mod_cast habove
  unfold readoutEnergy
  rw [readout_squaredSum_cloned hk,←mul_div_assoc]
  apply (div_le_iff₀ hkr).mpr
  have hh:=mul_le_mul_of_nonneg_left hw (Nat.cast_nonneg N : (0:ℝ)≤N)
  have hh':=mul_le_mul_of_nonneg_right har hV
  nlinarith

theorem sharp_cloned_gelu_compiler_energy (hC:0<C) (hk:0<k)
    (hbelow:(2*C)*k≤N) (habove:N≤2*(2*C)*k)
    (e:((Fin (2*C)×Fin k)⊕Fin p)≃Fin N) (B:LayeredNorCircuit d C r) (a:ℝ) :
    weightedSquaredNorm (clonedWeights e (B.geluWeights a))≤
      (d:ℝ)+25*r*(2*C)+50*a^2*(2*C) := by
  have hN:0<N := (Nat.mul_pos (Nat.mul_pos (by omega : 0<2) hC) hk).trans_le hbelow
  have hNr:(0:ℝ)<N := by exact_mod_cast hN
  have hkr:(0:ℝ)<k := by exact_mod_cast hk
  have hbr:(2*C:ℝ)*k≤N := by exact_mod_cast hbelow
  have har:(N:ℝ)≤2*(2*C)*k := by exact_mod_cast habove
  have hf:=mul_le_mul_of_nonneg_left (B.gelu_first_squaredSum_le a)
    (by positivity : 0≤(d:ℝ)*k/N)
  have hff:((d:ℝ)*k/N)*(2*C)≤d := by
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hNr).mpr
    nlinarith [mul_le_mul_of_nonneg_left hbr (Nat.cast_nonneg d : (0:ℝ)≤d)]
  have hi:(∑s,∑i,∑j,B.geluWeights a (Sum.inr (Sum.inl (s,i,j)))^2)≤25*r*(2*C) := by
    calc
      _ ≤ ∑_s:Fin r,25*(2*C:ℝ) := Finset.sum_le_sum fun s _=>B.gelu_internal_squaredSum_le a s
      _ = _ := by simp; ring
  have hv:=mul_le_mul_of_nonneg_left (B.gelu_readout_squaredSum_bounds a).2
    (by positivity : 0≤(N:ℝ)/k)
  have hvv:((N:ℝ)/k)*(25*a^2)≤50*a^2*(2*C) := by
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hkr).mpr
    nlinarith [mul_le_mul_of_nonneg_right har (by positivity : 0≤25*a^2)]
  rw [weightedSquaredNorm_cloned hk]
  push_cast at hf ⊢
  linarith

theorem sharp_relu_clone_cylinder_containment (hd:0<d) (hC:0<C) (hk:0<k)
    (hbelow:C*k≤N) (habove:N≤2*C*k)
    (e:((Fin C×Fin k)⊕Fin p)≃Fin N) (B:LayeredNorCircuit d C r)
    (b:OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J:Finset (Fin N)) (hJ:J.card≤C)
    (hrows:∀s i j,j∉J→basisCoordinates b
      (fun a=>clonedWeights e (B.weights 4) (Sum.inr (Sum.inl (s,i,a)))) j=0)
    (hhidden:∀(x:Cube d) (ss:List (Fin r)) j,j∉J→basisCoordinates b
      (ss.foldl (hiddenStep relu (clonedWeights e (B.weights 4)))
        (firstHidden relu (clonedWeights e (B.weights 4)) x)) j=0)
    {σ:ℝ} (hσ:0≤σ) (hscale:(N:ℝ)*σ^2≤1) :
    sharpCoordinateCylinder (clonedWeights e (B.weights 4)) b J
      (sharpRadius 1 10 C (sharpBulkBound r) d r) σ ⊆
        mergingSupport relu ∩marginEvent relu (1/2) B.computes := by
  have hN:0<N := (Nat.mul_pos hC hk).trans_le hbelow
  apply sharp_merging_cylinder_containment hd hN relu (clonePartition e)
    (clonedWeights e (B.weights 4)) B.computes b J (by norm_num) (by
      intro u v
      simpa only [one_mul] using relu_lipschitzZero.2 u v)
    (by norm_num) (by exact_mod_cast hC) hσ hscale (by exact_mod_cast hJ)
  · intro s
    rw [internal_squaredSum_cloned hk]
    exact (B.internal_squaredSum_le 4 s).trans (by nlinarith [Nat.cast_nonneg (α:=ℝ) C])
  · have hh:=cloned_readout_upper hk habove e (B.weights 4)
      (by norm_num : (0:ℝ)≤5*4^2) (B.readout_squaredSum_bounds 4).2
    nlinarith
  · have hcR:(populationCount (clonePartition e):ℝ)≤(C:ℝ)+1 := by exact_mod_cast clonePartition_count_le e
    linarith
  · exact cloned_compiler_readout_lower hk hbelow e B
  · intro x
    rw [networkOutput_cloned hk,LayeredNorCircuit.networkOutput_weights]
  · exact merging_fixes_clone e (B.weights 4)
  · intro x ss
    rw [firstHidden_cloned,hiddenFold_cloned hk]
    exact activeClone_average_fixed relu e _
  · exact hrows
  · exact hhidden
  · exact cloned_compiler_hidden_bound hk e B 4

theorem sharp_gelu_clone_cylinder_containment (hd:0<d) (hC:0<C) (hk:0<k)
    (hbelow:(2*C)*k≤N) (habove:N≤2*(2*C)*k)
    (e:((Fin (2*C)×Fin k)⊕Fin p)≃Fin N) (B:LayeredNorCircuit d C r)
    (b:OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J:Finset (Fin N)) (hJ:J.card≤2*C)
    (hrows:∀s i j,j∉J→basisCoordinates b
      (fun a=>clonedWeights e (B.geluWeights 4) (Sum.inr (Sum.inl (s,i,a)))) j=0)
    (hhidden:∀(x:Cube d) (ss:List (Fin r)) j,j∉J→basisCoordinates b
      (ss.foldl (hiddenStep gelu (clonedWeights e (B.geluWeights 4)))
        (firstHidden gelu (clonedWeights e (B.geluWeights 4)) x)) j=0)
    {σ:ℝ} (hσ:0≤σ) (hscale:(N:ℝ)*σ^2≤1) :
    sharpCoordinateCylinder (clonedWeights e (B.geluWeights 4)) b J
      (sharpRadius 2 100 (2*C) (sharpBulkBound r) d r) σ ⊆
        mergingSupport gelu ∩marginEvent gelu (1/2) B.computes := by
  have hD:0<2*C := Nat.mul_pos (by omega) hC
  have hN:0<N := (Nat.mul_pos hD hk).trans_le hbelow
  apply sharp_merging_cylinder_containment hd hN gelu (clonePartition e)
    (clonedWeights e (B.geluWeights 4)) B.computes b J (by norm_num) (by
      intro u v
      simpa only [NNReal.coe_ofNat,Real.dist_eq] using gelu_lipschitz.dist_le_mul u v)
    (by norm_num) (by exact_mod_cast hD) hσ hscale (by exact_mod_cast hJ)
  · intro s
    rw [internal_squaredSum_cloned hk]
    exact (B.gelu_internal_squaredSum_le 4 s).trans (by nlinarith [Nat.cast_nonneg (α:=ℝ) C])
  · have hh:=cloned_readout_upper hk habove e (B.geluWeights 4)
      (by norm_num : (0:ℝ)≤25*4^2) (B.gelu_readout_squaredSum_bounds 4).2
    push_cast at hh
    nlinarith
  · have hcR:(populationCount (clonePartition e):ℝ)≤(2*C:ℝ)+1 := by exact_mod_cast clonePartition_count_le e
    linarith
  · exact gelu_cloned_compiler_readout_lower hk hbelow e B
  · intro x
    rw [networkOutput_cloned hk,LayeredNorCircuit.gelu_networkOutput]
  · exact merging_fixes_clone e (B.geluWeights 4)
  · intro x ss
    rw [firstHidden_cloned,hiddenFold_cloned hk]
    exact activeClone_average_fixed gelu e _
  · exact hrows
  · exact hhidden
  · intro x ss i
    rw [firstHidden_cloned,hiddenFold_cloned hk]
    cases hi : e.symm i with
    | inl ai => simpa only [clonedHidden,hi] using B.gelu_hiddenFold_abs_le_one 4 ss x ai.1
    | inr j => simp [clonedHidden,hi,gelu_zero]

end NeuralGeneralization.BatchTwoMerging
