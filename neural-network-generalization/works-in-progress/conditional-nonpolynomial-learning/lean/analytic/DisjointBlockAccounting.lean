import BlockAccounting
import PhysicalPrefixOccupation

noncomputable section
set_option maxHeartbeats 1500000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic

def disjointBlockCost (cost : ℕ→ℝ) (offset length i : ℕ) : ℝ :=
  ∑j∈Finset.range length,cost (offset+i*length+j)

/-- Exact accounting, including a possible initial offset. -/
theorem disjoint_block_sum (cost : ℕ→ℝ) (offset length n : ℕ) :
    (∑i∈Finset.range n,disjointBlockCost cost offset length i)=
      ∑j∈Finset.range (n*length),cost (offset+j) := by
  induction n with
  | zero=>simp [disjointBlockCost]
  | succ n ih=>
    rw [Finset.sum_range_succ,ih,Nat.succ_mul,Finset.sum_range_add]
    congr 1
    apply Finset.sum_congr rfl
    intro j hj
    simp only [Nat.add_assoc]

theorem disjoint_block_nonneg (cost : ℕ→ℝ) {offset length n : ℕ}
    (hcost : ∀j<offset+n*length,0≤cost j) (i : ℕ) (hi : i<n) :
    0≤disjointBlockCost cost offset length i := by
  apply Finset.sum_nonneg
  intro j hj
  apply hcost
  have hjlt := Finset.mem_range.mp hj
  have hm : (i+1)*length≤n*length := Nat.mul_le_mul_right length (by omega)
  rw [Nat.add_mul,Nat.one_mul] at hm
  omega

/-- Complete disjoint blocks charge at most the containing prefix's total. -/
theorem disjoint_block_sum_le_prefix (cost : ℕ→ℝ) {length n J : ℕ}
    (hcost : ∀j<J,0≤cost j) (hfit : n*length≤J) :
    (∑i∈Finset.range n,disjointBlockCost cost 0 length i)≤∑j∈Finset.range J,cost j := by
  rw [disjoint_block_sum]
  simp only [Nat.zero_add]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono hfit)
    (fun j hj _=>hcost j (Finset.mem_range.mp hj))

/-- The number of expensive blocks is controlled by the actual total cost;
no independence or pointwise control within blocks is required. -/
theorem disjoint_bad_blocks (cost : ℕ→ℝ) {length n J : ℕ} (θ : ℝ)
    (hcost : ∀j<J,0≤cost j) (hfit : n*length≤J) :
    θ*(((Finset.range n).filter fun i=>θ<disjointBlockCost cost 0 length i).card:ℝ)≤
      ∑j∈Finset.range J,cost j := by
  apply (bad_block_card_bound (Finset.range n) (disjointBlockCost cost 0 length) θ ?_).trans
    (disjoint_block_sum_le_prefix cost hcost hfit)
  intro i hi
  exact disjoint_block_nonneg cost (offset:=0) (n:=n)
    (fun j hj=>hcost j (by omega)) i (Finset.mem_range.mp hi)

/-- The standard ceil(c/a) block length gives at least c contraction-time
and loses less than one time step. -/
theorem ceiling_block_length {a c : ℝ} (ha : 0<a) (hc : 0<c) :
    0<⌈c/a⌉₊ ∧ c≤a*(⌈c/a⌉₊:ℝ) ∧ a*(⌈c/a⌉₊:ℝ)<c+a := by
  have hpos : 0<c/a := div_pos hc ha
  have hlo := Nat.le_ceil (c/a)
  have hhi := Nat.ceil_lt_add_one hpos.le
  have hmul := mul_le_mul_of_nonneg_left hlo ha.le
  have hmul' := mul_lt_mul_of_pos_left hhi ha
  have he : a*(c/a)=c := by field_simp
  refine ⟨?_,?_,?_⟩
  · exact Nat.ceil_pos.mpr hpos
  · rw [he] at hmul
    exact hmul
  · rw [mul_add,he,mul_one] at hmul'
    exact hmul'

theorem physical_prefix_nonlinear_occupation {d H J : ℕ} {t : ℝ}
    {f : NeuralGeneralization.ConcreteModel.BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hJ : J≤H) :
    (∑j∈Finset.range J,(physicalMaxVariance P j+Real.sqrt (physicalAdjustedCost P j)))≤
      2+(physicalPrefixOccupationConstant+1)*(Real.log ((J:ℝ)+2)+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalAdjustedCost P j))) := by
  have he (j : ℕ) (hj : j<J) : 0≤physicalAdjustedCost P j :=
    (controlledMarginPath_adjusted_step P j (by omega)).1
  have hs := Real.le_sqrt_of_sq_le (sum_sqrt_sq_le J (physicalAdjustedCost P) he)
  have hv := physical_prefix_variance_occupation P hd hJ
  have hl : 0≤Real.log ((J:ℝ)+2) := Real.log_nonneg (by linarith [Nat.cast_nonneg (α:=ℝ) J])
  rw [Finset.sum_add_distrib]
  nlinarith only [hs,hv,hl]

/-- Actual physical nonlinear block charges inherit the square-root forcing
count bound; concentration of forcing in a few steps causes no extra loss. -/
theorem physical_bad_nonlinear_blocks {d H J b n : ℕ} {t : ℝ}
    {f : NeuralGeneralization.ConcreteModel.BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hJ : J≤H) (hfit : n*b≤J) (θ : ℝ) :
    θ*(((Finset.range n).filter fun i=>θ<disjointBlockCost
      (fun j=>physicalMaxVariance P j+Real.sqrt (physicalAdjustedCost P j)) 0 b i).card:ℝ)≤
      2+(physicalPrefixOccupationConstant+1)*(Real.log ((J:ℝ)+2)+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalAdjustedCost P j))) := by
  apply (disjoint_bad_blocks (fun j=>physicalMaxVariance P j+Real.sqrt (physicalAdjustedCost P j))
    θ ?_ hfit).trans (physical_prefix_nonlinear_occupation P hd hJ)
  intro j hj
  exact add_nonneg (controlledMarginPath_variance_positive P j (by omega)).le (Real.sqrt_nonneg _)

theorem disjoint_sqrt_block_sum_le_prefix (cost : ℕ→ℝ) {length n J : ℕ}
    (hcost : ∀j<J,0≤cost j) (hfit : n*length≤J) :
    (∑i∈Finset.range n,Real.sqrt ((length:ℝ)*disjointBlockCost cost 0 length i))≤
      Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,cost j)) := by
  have hblock (i : ℕ) (hi : i<n) : 0≤disjointBlockCost cost 0 length i :=
    disjoint_block_nonneg cost (offset:=0) (n:=n) (fun j hj=>hcost j (by omega)) i hi
  have hs := sum_sqrt_sq_le n (fun i=>(length:ℝ)*disjointBlockCost cost 0 length i)
    (fun i hi=>mul_nonneg (Nat.cast_nonneg _) (hblock i hi))
  rw [←Finset.mul_sum] at hs
  have htotal := disjoint_block_sum_le_prefix cost hcost hfit
  have htotal0 : 0≤∑j∈Finset.range J,cost j :=
    Finset.sum_nonneg fun j hj=>hcost j (Finset.mem_range.mp hj)
  have hscale := mul_le_mul_of_nonneg_left htotal
    (mul_nonneg (Nat.cast_nonneg (α:=ℝ) n) (Nat.cast_nonneg (α:=ℝ) length))
  have hfitR : (n:ℝ)*length≤J := by exact_mod_cast hfit
  have hfinal := mul_le_mul_of_nonneg_right hfitR htotal0
  apply Real.le_sqrt_of_sq_le
  nlinarith only [hs,hscale,hfinal]

def physicalBlockEnvelope {d H : ℕ} {t : ℝ}
    {f : NeuralGeneralization.ConcreteModel.BooleanFunction d}
    (P : ControlledMarginPath d H t f) (b i : ℕ) : ℝ :=
  disjointBlockCost (physicalMaxVariance P) 0 b i+
    Real.sqrt ((b:ℝ)*disjointBlockCost (physicalAdjustedCost P) 0 b i)

/-- The same square-root bad-block estimate holds for the coarser Cauchy
block envelope, sum q plus sqrt(block length times block adjusted entropy). -/
theorem physical_bad_envelope_blocks {d H J b n : ℕ} {t : ℝ}
    {f : NeuralGeneralization.ConcreteModel.BooleanFunction d}
    (P : ControlledMarginPath d H t f) (hd : 1≤d) (hJ : J≤H) (hfit : n*b≤J) (θ : ℝ) :
    θ*(((Finset.range n).filter fun i=>θ<physicalBlockEnvelope P b i).card:ℝ)≤
      2+(physicalPrefixOccupationConstant+1)*(Real.log ((J:ℝ)+2)+
        Real.sqrt ((J:ℝ)*(∑j∈Finset.range J,physicalAdjustedCost P j))) := by
  have hq (j : ℕ) (hj : j<J) : 0≤physicalMaxVariance P j :=
    (controlledMarginPath_variance_positive P j (by omega)).le
  have he (j : ℕ) (hj : j<J) : 0≤physicalAdjustedCost P j :=
    (controlledMarginPath_adjusted_step P j (by omega)).1
  have hsumQ := disjoint_block_sum_le_prefix (physicalMaxVariance P) hq hfit
  have hsumE := disjoint_sqrt_block_sum_le_prefix (physicalAdjustedCost P) he hfit
  have hqOcc := physical_prefix_variance_occupation P hd hJ
  have hlog : 0≤Real.log ((J:ℝ)+2) := Real.log_nonneg (by linarith [Nat.cast_nonneg (α:=ℝ) J])
  have hbad := bad_block_card_bound (Finset.range n) (physicalBlockEnvelope P b) θ
    (fun i hi=>add_nonneg
      (disjoint_block_nonneg (physicalMaxVariance P) (offset:=0) (n:=n)
        (fun j hj=>hq j (by omega)) i (Finset.mem_range.mp hi)) (Real.sqrt_nonneg _))
  simp only [physicalBlockEnvelope,Finset.sum_add_distrib] at hbad
  unfold physicalBlockEnvelope
  nlinarith only [hbad,hsumQ,hsumE,hqOcc,hlog]

#print axioms physical_bad_envelope_blocks
#print axioms physical_bad_nonlinear_blocks
#print axioms disjoint_bad_blocks
#print axioms ceiling_block_length
end ConditionalNonpolynomial.Analytic
