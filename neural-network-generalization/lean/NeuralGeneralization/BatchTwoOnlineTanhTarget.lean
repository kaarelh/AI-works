import NeuralGeneralization.BatchTwoOnlineTanhSupportBounds
import NeuralGeneralization.BatchTwoOnlineTanhCylinder
import NeuralGeneralization.BatchTwoOnlineTanhSignedSupport
import NeuralGeneralization.BatchTwoImprovedTargetMain

/-! An actual Gaussian cylinder inside the tanh signed-merging prior, at every learner width. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging
variable {d C N r k p : ℕ}

def tanhMergeKappa (C r : ℕ) (c : ℝ) : ℝ :=
  1+18*(improvedGain C r)^2+2*(improvedReadout c)^2

def tanhMergeRadius (d C r : ℕ) (c : ℝ) : ℝ :=
  min (improvedRadius d C)
    (sharpRadius 1 (tanhMergeKappa C r c) ((C:ℝ)+1) (sharpBulkBound r) d r)

def tanhMergeTargetCost (d C r : ℕ) (c : ℝ) : ℝ :=
  sharpCylinderCost d r (improvedTeacherCost d C r c) ((C:ℝ)+1) (tanhMergeRadius d C r c)

theorem tanhMergeKappa_one_le (C r : ℕ) (c : ℝ) : 1≤tanhMergeKappa C r c := by
  unfold tanhMergeKappa
  nlinarith [sq_nonneg (improvedGain C r),sq_nonneg (improvedReadout c)]

theorem tanhMergeRadius_bounds (d r : ℕ) (hC : 0<C) (c : ℝ) :
    0<tanhMergeRadius d C r c ∧ tanhMergeRadius d C r c≤1/16 := by
  have hi := improvedRadius_bounds d hC
  have hs := sharpRadius_control d r (by norm_num : (1:ℝ)≤1)
    (tanhMergeKappa_one_le C r c) (by linarith [Nat.cast_nonneg (α:=ℝ) C] : (1:ℝ)≤(C:ℝ)+1) (sharpBulkBound_nonneg r)
  exact ⟨lt_min hi.1 hs.1,(min_le_right _ _).trans hs.2.1⟩

theorem tanhMergeTargetCost_nonneg (d r : ℕ) (hC : 0<C) (c : ℝ) :
    0≤tanhMergeTargetCost d C r c :=
  sharpCylinderCost_nonneg d r (by unfold improvedTeacherCost; positivity) (by positivity)
    (tanhMergeRadius_bounds d r hC c).1 (tanhMergeRadius_bounds d r hC c).2

theorem saturated_merge_layer_budget (hk : 0<k) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r) (c : ℝ) (s : Fin r) :
    (∑i,∑j,B.saturatedClone e (improvedGain C r) (improvedReadout c) (.inr (.inl (s,i,j)))^2)≤
      tanhMergeKappa C r c*((C:ℝ)+1) := by
  have hkR : (0:ℝ)<k := by exact_mod_cast hk
  have hratio : (N:ℝ)/k≤2*C := (div_le_iff₀ hkR).mpr (by exact_mod_cast habove)
  calc
    _ ≤ ∑_i:Fin N,9*(improvedGain C r)^2/k := Finset.sum_le_sum fun i _=>
      B.saturatedClone_internal_row_energy e hk _ _ s i
    _ = ((N:ℝ)/k)*(9*(improvedGain C r)^2) := by simp; ring
    _ ≤ (2*C)*(9*(improvedGain C r)^2) := mul_le_mul_of_nonneg_right hratio (by positivity)
    _ ≤ _ := by
      unfold tanhMergeKappa
      nlinarith [mul_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C) (sq_nonneg (improvedReadout c))]

theorem saturated_merge_readout_budget (hk : 0<k) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r) (c : ℝ) :
    readoutEnergy (B.saturatedClone e (improvedGain C r) (improvedReadout c))≤
      16*tanhMergeKappa C r c*((C:ℝ)+1) := by
  have hkR : (0:ℝ)<k := by exact_mod_cast hk
  have hratio : (N:ℝ)/k≤2*C := (div_le_iff₀ hkR).mpr (by exact_mod_cast habove)
  rw [B.saturatedClone_readout_energy_eq e hk]
  have hh := mul_le_mul_of_nonneg_right hratio (sq_nonneg (improvedReadout c))
  rw [show (N:ℝ)*(improvedReadout c)^2/k=((N:ℝ)/k)*(improvedReadout c)^2 by ring]
  unfold tanhMergeKappa
  nlinarith [mul_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C) (sq_nonneg (improvedGain C r)),
    mul_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C) (sq_nonneg (improvedReadout c))]

theorem tanh_merge_cylinder_containment (hd : 0<d) (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N))
    {c σ : ℝ} (hc : 0<c) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (hJ : J.card≤C+1)
    (hrows : ∀s i j,j∉J→basisCoordinates b
      (fun u=>B.saturatedClone e (improvedGain C r) (improvedReadout c) (.inr (.inl (s,i,u)))) j=0)
    (hhidden : ∀(x:Cube d) (ss:List (Fin r)) j,j∉J→basisCoordinates b
      (ss.foldl (hiddenStep Real.tanh (B.saturatedClone e (improvedGain C r) (improvedReadout c)))
        (firstHidden Real.tanh (B.saturatedClone e (improvedGain C r) (improvedReadout c)) x)) j=0)
    (hideal : ∀(bits:Fin C→Bool) j,j∉J→basisCoordinates b (saturatedCloneBits e B.constant bits) j=0) :
    sharpCoordinateCylinder (B.saturatedClone e (improvedGain C r) (improvedReadout c)) b J
      (tanhMergeRadius d C r c) σ⊆
      (mergingSupport Real.tanh ∩robustEvent Real.tanh c)∩marginEvent Real.tanh (1/2) B.computes := by
  have hN : 0<N := (Nat.mul_pos hC hk).trans_le hbelow
  let v := B.saturatedClone e (improvedGain C r) (improvedReadout c)
  intro w hw
  have hi : w∈sharpCoordinateCylinder v b J (improvedRadius d C) σ :=
    sharpCoordinateCylinder_mono v b J (min_le_left _ _) hσ.le hw
  have hs : w∈sharpCoordinateCylinder v b J
      (sharpRadius 1 (tanhMergeKappa C r c) ((C:ℝ)+1) (sharpBulkBound r) d r) σ :=
    sharpCoordinateCylinder_mono v b J (min_le_right _ _) hσ.le hw
  obtain ⟨hA,ha,hε,hε1,hτ,hρ,hreadρ,hfirst,hgroup,hinit,hstep,hout,hcal⟩ :=
    improved_parameter_conditions d r hC hc
  have hstrong := tanhCoordinateCylinder_strong_containment hd hN hk habove hbelow B e b J
    hA ha hε hε1 hτ hρ hreadρ hfirst hgroup hinit hstep hout hc hcal hσ hscale hJ hrows hideal hi
  obtain ⟨hraw,hmerged,hread⟩ := sharp_cylinder_raw_merged_error hd hN Real.tanh (clonePartition e)
    v w b J (by norm_num) (fun u v=>by simpa only [one_mul] using tanh_admissible.2 u v)
    (tanhMergeKappa_one_le C r c) (by linarith [Nat.cast_nonneg (α:=ℝ) C] : (1:ℝ)≤(C:ℝ)+1) hσ.le hscale
    (by exact_mod_cast hJ) (saturated_merge_layer_budget hk habove e B c)
    (saturated_merge_readout_budget hk habove e B c)
    (merging_fixes_saturated e B _ _) (saturated_hidden_fixed Real.tanh e B _ _)
    hrows hhidden (fun x ss=>hiddenFold_bounded Real.tanh tanh_admissible v ss x) hs
  have hr := sharpRadius_control d r (by norm_num : (1:ℝ)≤1)
    (tanhMergeKappa_one_le C r c) (by linarith [Nat.cast_nonneg (α:=ℝ) C] : (1:ℝ)≤(C:ℝ)+1) (sharpBulkBound_nonneg r)
  have ha4 : 4 ≤ improvedReadout c := by unfold improvedReadout; linarith
  have hbudget := saturated_perturbed_population_budget hN hC hk hbelow e B w (improvedGain C r)
    ha hr.1.le (by linarith [hr.2.1]) hread
  have hm (x : Cube d) : (1/2:ℝ)<labelReal (B.computes x)*
      networkOutput Real.tanh (mergedWeights (fun _=>clonePartition e) w) x := by
    have hh := hstrong.2 x
    have h1 := abs_le.mp (hraw x)
    have h2 := abs_le.mp (hmerged x)
    cases hb : B.computes x <;>
      simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at * <;> linarith
  have hmargin : w∈marginEvent Real.tanh (1/2) B.computes := fun x=>lt_trans (by norm_num) (hstrong.2 x)
  refine ⟨⟨Set.mem_iUnion.mpr ⟨fun _=>clonePartition e,?_,⟩,hstrong.1⟩,hmargin⟩
  constructor
  · intro _ x
    exact hbudget x
  · intro x
    rw [clippedScore_eq_label_of_margin (B.computes x) _ (hmargin x).le,
      clippedScore_eq_label_of_margin (B.computes x) _ (hm x).le]
    norm_num

theorem tanh_merge_target_mass_cloned (hd : 0<d) (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (B : LayeredBooleanCircuit d C r)
    {c σ : ℝ} (hc : 0<c) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-tanhMergeTargetCost d C r c/σ^2)≤
      (smallPrior d N r σ).real
        ((mergingSupport Real.tanh∩robustEvent Real.tanh c)∩marginEvent Real.tanh (1/2) B.computes) := by
  have hN : 0<N := (Nat.mul_pos hC hk).trans_le hbelow
  obtain ⟨b,J,hJ,hrows,hhidden,hideal⟩ :=
    exists_adapted_saturated_merging Real.tanh e B (improvedGain C r) (improvedReadout c)
  obtain ⟨hr,hr16⟩ := tanhMergeRadius_bounds d r hC c
  have hcost := B.saturatedClone_sharp_energy e hN hk habove (improvedGain C r) (improvedReadout c)
  have hm := sharpCoordinateCylinder_mass hd hN
    (B.saturatedClone e (improvedGain C r) (improvedReadout c)) b J hr hr16 hσ hscale
    (show (J.card:ℝ)≤(C:ℝ)+1 by exact_mod_cast hJ) hcost
  exact hm.trans (measureReal_mono
    (tanh_merge_cylinder_containment hd hC hk hbelow habove e B b J hc hσ hscale hJ hrows hhidden hideal)
    (measure_ne_top _ _))

theorem tanh_merge_target_mass_all_widths (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-tanhMergeTargetCost d C r c/σ^2)≤
      (smallPrior d N r σ).real
        ((signedMergingSupport∩robustEvent Real.tanh c)∩marginEvent Real.tanh (1/2) B.computes) := by
  classical
  let k := N/C
  have hk : 0<k := Nat.div_pos hCN hC
  have hmod : N%C<C := Nat.mod_lt _ hC
  have hsplit : N%C+C*k=N := Nat.mod_add_div N C
  have hbelow : C*k≤N := by omega
  have hCk : C≤C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N≤2*C*k := by nlinarith
  let e : ((Fin C×Fin k)⊕Fin (N-C*k))≃Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  apply (tanh_merge_target_mass_cloned hd hC hk hbelow habove e B hc hσ hscale).trans
  exact measureReal_mono (fun _ hw=>⟨⟨mergingSupport_subset_signed hw.1.1,hw.1.2⟩,hw.2⟩)
    (measure_ne_top _ _)

end NeuralGeneralization.BatchTwoOnlineTanhMerging
