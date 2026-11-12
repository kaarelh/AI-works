import NeuralGeneralization.BatchTwoOnlineBalancedSupport
import NeuralGeneralization.BatchTwoOnlineBalancedSubspace
import NeuralGeneralization.BatchTwoOnlineBalancedCylinder
import NeuralGeneralization.BatchTwoOnlineTanhTarget

/-! Positive Gaussian mass in the literal balanced support, at every width N >= C. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineBalanced
open ConcreteModel BatchTwoMerging BatchTwoOnlineTanhMerging
variable {d C N r : ℕ} {k : Fin C→ℕ}

def balancedTargetCost (d C r : ℕ) (c : ℝ) : ℝ := tanhMergeTargetCost d C r (2*c)

theorem grouped_merge_layer_budget (hN : 0<N) (hk : ∀b,0<k b) (habove : ∀b,N≤2*C*k b)
    (e : (Σb : Fin C,Fin (k b))≃Fin N) (B : LayeredBooleanCircuit d C r) (c : ℝ) (s : Fin r) :
    (∑i,∑j,groupedWeights B e (improvedGain C r) (improvedReadout c) (.inr (.inl (s,i,j)))^2)≤
      tanhMergeKappa C r c*((C:ℝ)+1) := by
  apply (grouped_internal_energy B e hN hk habove _ _ s).trans
  unfold tanhMergeKappa
  nlinarith [sq_nonneg (improvedGain C r),sq_nonneg (improvedReadout c),
    mul_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C) (sq_nonneg (improvedReadout c))]

theorem grouped_merge_readout_budget (hk : ∀b,0<k b) (habove : ∀b,N≤2*C*k b)
    (hbelow : ∀b,C*k b≤2*N) (e : (Σb : Fin C,Fin (k b))≃Fin N)
    (B : LayeredBooleanCircuit d C r) (c : ℝ) :
    readoutEnergy (groupedWeights B e (improvedGain C r) (improvedReadout c))≤
      16*tanhMergeKappa C r c*((C:ℝ)+1) := by
  apply (grouped_readout_energy_bounds B e hk habove hbelow _ _).2.trans
  unfold tanhMergeKappa
  nlinarith [sq_nonneg (improvedGain C r),sq_nonneg (improvedReadout c),
    mul_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C) (sq_nonneg (improvedReadout c)),
    mul_nonneg (Nat.cast_nonneg C : (0:ℝ)≤C) (sq_nonneg (improvedGain C r))]

theorem balanced_merge_cylinder_containment (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N))) (J : Finset (Fin N))
    {c σ : ℝ} (hc : 0<c) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    (hJ : J.card≤C+1)
    (hrows : ∀s i j,j∉J→basisCoordinates b
      (fun u=>groupedWeights B (balancedLayout hC) (improvedGain C r) (improvedReadout (2*c)) (.inr (.inl (s,i,u)))) j=0)
    (hhidden : ∀(x:Cube d) (ss:List (Fin r)) j,j∉J→basisCoordinates b
      (ss.foldl (hiddenStep Real.tanh (groupedWeights B (balancedLayout hC) (improvedGain C r) (improvedReadout (2*c))))
        (firstHidden Real.tanh (groupedWeights B (balancedLayout hC) (improvedGain C r) (improvedReadout (2*c))) x)) j=0)
    (hideal : ∀(bits:Fin C→Bool) j,j∉J→basisCoordinates b (layoutBits (balancedLayout hC) bits) j=0) :
    sharpCoordinateCylinder (groupedWeights B (balancedLayout hC) (improvedGain C r) (improvedReadout (2*c))) b J
      (tanhMergeRadius d C r (2*c)) σ⊆
      (balancedMergingSupport∩robustEvent Real.tanh c)∩marginEvent Real.tanh (1/2) B.computes := by
  have hN : 0<N := hC.trans_le hCN
  let e := balancedLayout (N:=N) hC
  have hk := balancedGroupSize_pos hC hCN
  have habove := fun a=>(balancedGroupSize_bounds hC hCN a).1
  have hbelow := fun a=>(balancedGroupSize_bounds hC hCN a).2
  let v := groupedWeights B e (improvedGain C r) (improvedReadout (2*c))
  intro w hw
  have hi : w∈sharpCoordinateCylinder v b J (improvedRadius d C) σ :=
    sharpCoordinateCylinder_mono v b J (min_le_left _ _) hσ.le hw
  have hs : w∈sharpCoordinateCylinder v b J
      (sharpRadius 1 (tanhMergeKappa C r (2*c)) ((C:ℝ)+1) (sharpBulkBound r) d r) σ :=
    sharpCoordinateCylinder_mono v b J (min_le_right _ _) hσ.le hw
  obtain ⟨hA,ha,hε,hε1,hτ,hρ,_,hfirst,hgroup,hinit,hstep,hout,hcal⟩ :=
    improved_parameter_conditions d r hC (show 0<2*c by positivity)
  have ha4 : 4≤ improvedReadout (2*c) := by unfold improvedReadout; linarith
  have hradius := (improvedRadius_bounds d hC).2.1.trans (improvedError_bounds hC).2
  have hreadρ : improvedRadius d C≤ improvedReadout (2*c)/4 := by linarith
  have hcal' : 4*c≤ improvedNoise C*improvedReadout (2*c)*Real.sqrt C := by linarith
  have hstrong := balancedCoordinateCylinder_strong_containment hd hN hk habove hbelow B e b J
    hA ha hε hε1 hτ hρ hreadρ hfirst hgroup hinit hstep hout hc hcal' hσ hscale hJ hrows hideal hi
  obtain ⟨hraw,hmerged,hread⟩ := sharp_cylinder_raw_merged_error hd hN Real.tanh (layoutPartition e hk)
    v w b J (by norm_num) (fun u v=>by simpa only [one_mul] using tanh_admissible.2 u v)
    (tanhMergeKappa_one_le C r (2*c)) (by linarith [Nat.cast_nonneg (α:=ℝ) C] : (1:ℝ)≤(C:ℝ)+1) hσ.le hscale
    (by exact_mod_cast hJ) (grouped_merge_layer_budget hN hk habove e B (2*c))
    (grouped_merge_readout_budget hk habove hbelow e B (2*c))
    (merging_fixes_grouped e hk B _ _) (grouped_hidden_fixed Real.tanh e hk B _ _)
    hrows hhidden (fun x ss=>hiddenFold_bounded Real.tanh tanh_admissible v ss x) hs
  have hr := sharpRadius_control d r (by norm_num : (1:ℝ)≤1)
    (tanhMergeKappa_one_le C r (2*c)) (by linarith [Nat.cast_nonneg (α:=ℝ) C] : (1:ℝ)≤(C:ℝ)+1) (sharpBulkBound_nonneg r)
  have henergy := grouped_perturbed_readout_lower B e hN hC hk habove hbelow w
    ha hr.1.le (by linarith [hr.2.1]) hread
  have hbudget : (C:ℝ)≤1+readoutEnergy w := by
    have hh := mul_le_mul_of_nonneg_right (show 16≤(improvedReadout (2*c))^2 by nlinarith)
      (Nat.cast_nonneg C : (0:ℝ)≤C)
    nlinarith [(Nat.cast_nonneg C : (0:ℝ)≤C)]
  have hm (x : Cube d) : (1/2:ℝ)<labelReal (B.computes x)*
      networkOutput Real.tanh (mergedWeights (fun _=>layoutPartition e hk) w) x := by
    have hh := hstrong.2 x
    have h1 := abs_le.mp (hraw x)
    have h2 := abs_le.mp (hmerged x)
    cases hb : B.computes x <;>
      simp only [hb,labelReal_false,labelReal_true,neg_one_mul,one_mul] at * <;> linarith
  have hmargin : w∈marginEvent Real.tanh (1/2) B.computes := fun x=>lt_trans (by norm_num) (hstrong.2 x)
  refine ⟨⟨Set.mem_iUnion.mpr ⟨balancedTeacherPartitions hC hCN,?_,⟩,hstrong.1⟩,hmargin⟩
  refine ⟨hbudget,?_⟩
  intro x
  change |clippedScore (networkOutput Real.tanh w x)-
    clippedScore (networkOutput Real.tanh (mergedWeights (fun _=>layoutPartition e hk) w) x)|≤_
  rw [clippedScore_eq_label_of_margin (B.computes x) _ (hmargin x).le,
    clippedScore_eq_label_of_margin (B.computes x) _ (hm x).le]
  norm_num

theorem balanced_target_mass_all_widths (hd : 0<d) (hC : 0<C) (hCN : C≤N)
    (B : LayeredBooleanCircuit d C r) {c σ : ℝ} (hc : 0<c) (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1) :
    Real.exp (-balancedTargetCost d C r c/σ^2)≤
      (smallPrior d N r σ).real
        ((balancedMergingSupport∩robustEvent Real.tanh c)∩marginEvent Real.tanh (1/2) B.computes) := by
  have hN : 0<N := hC.trans_le hCN
  let e := balancedLayout (N:=N) hC
  have hk := balancedGroupSize_pos hC hCN
  have habove := fun a=>(balancedGroupSize_bounds hC hCN a).1
  have hbelow := fun a=>(balancedGroupSize_bounds hC hCN a).2
  obtain ⟨b,J,hJ,hrows,hhidden,hideal⟩ :=
    exists_adapted_grouped_merging Real.tanh e hk B (improvedGain C r) (improvedReadout (2*c))
  obtain ⟨hr,hr16⟩ := tanhMergeRadius_bounds d r hC (2*c)
  have hcost := grouped_teacher_energy B e hN hk habove hbelow (improvedGain C r) (improvedReadout (2*c))
  have hm := sharpCoordinateCylinder_mass hd hN
    (groupedWeights B e (improvedGain C r) (improvedReadout (2*c))) b J hr hr16 hσ hscale
    (show (J.card:ℝ)≤(C:ℝ)+1 by exact_mod_cast (Nat.le_succ_of_le hJ)) hcost
  exact hm.trans (measureReal_mono
    (balanced_merge_cylinder_containment hd hC hCN B b J hc hσ hscale (Nat.le_succ_of_le hJ) hrows hhidden hideal)
    (measure_ne_top _ _))

theorem balancedTargetCost_nonneg (d r : ℕ) (hC : 0<C) (c : ℝ) :
    0≤balancedTargetCost d C r c := tanhMergeTargetCost_nonneg d r hC (2*c)

end NeuralGeneralization.BatchTwoOnlineBalanced
