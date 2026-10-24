import NeuralGeneralization.BatchTwoContinuousDepthBranches
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.MeasureTheory.Constructions.BorelSpace.Metrizable

/-! The literal infinite inverse-branch coding map for the fixed input law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Filter MeasureTheory
open scoped NNReal Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

abbrev SignStream := ℕ → Bool

def streamShift (n : ℕ) (ω : SignStream) : SignStream := fun j => ω (n+j)

theorem streamShift_zero (ω : SignStream) : streamShift 0 ω = ω := by
  funext j
  exact congrArg ω (Nat.zero_add j)

def branchPrefix (ω : SignStream) : ℕ → BranchDomain → BranchDomain
  | 0 => id
  | n+1 => fun y => branchPrefix ω n (branch (ω n) y)

theorem branchPrefix_lipschitz (ω : SignStream) (n : ℕ) :
    LipschitzWith ((1/3)^n) (branchPrefix ω n) := by
  induction n with
  | zero => simpa only [branchPrefix,pow_zero] using (LipschitzWith.id : LipschitzWith 1 (id : BranchDomain → BranchDomain))
  | succ n ih => simpa only [branchPrefix,pow_succ,Function.comp_def] using ih.comp (branch_lipschitz (ω n))

theorem branchPrefix_shift (ω : SignStream) (n : ℕ) (y : BranchDomain) :
    branchPrefix ω (n+1) y = branch (ω 0) (branchPrefix (streamShift 1 ω) n y) := by
  induction n generalizing y with
  | zero => rfl
  | succ n ih =>
    change branchPrefix ω (n+1) (branch (ω (n+1)) y) =
      branch (ω 0) (branchPrefix (streamShift 1 ω) n (branch (streamShift 1 ω n) y))
    rw [ih]
    simp only [streamShift,Nat.add_comm]

theorem branchPrefix_agree {ω η : SignStream} (n : ℕ)
    (h : ∀ i < n, ω i = η i) : branchPrefix ω n = branchPrefix η n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    funext y
    simp only [branchPrefix,ih (fun i hi => h i (by omega)),h n (by omega)]

theorem branchDomain_distance_bound (s t : BranchDomain) : dist s t ≤ (3/2 : ℝ) := by
  rw [Subtype.dist_eq,Real.dist_eq,abs_le]
  have hs:=s.property
  have ht:=t.property
  constructor <;> linarith [hs.1,hs.2,ht.1,ht.2]

def branchOrigin : BranchDomain := ⟨0,by constructor <;> norm_num⟩

instance : Nonempty BranchDomain := ⟨branchOrigin⟩

def codingApprox (ω : SignStream) (n : ℕ) : BranchDomain := branchPrefix ω n branchOrigin

theorem codingApprox_step (ω : SignStream) (n : ℕ) :
    dist (codingApprox ω n) (codingApprox ω (n+1)) ≤ (3/2 : ℝ)*(1/3)^n := by
  have h := (branchPrefix_lipschitz ω n).dist_le_mul branchOrigin (branch (ω n) branchOrigin)
  change dist (codingApprox ω n) (codingApprox ω (n+1)) ≤ _ at h
  simp only [NNReal.coe_pow,NNReal.coe_div,NNReal.coe_one,NNReal.coe_ofNat] at h
  have hb := branchDomain_distance_bound branchOrigin (branch (ω n) branchOrigin)
  have hp : (0 : ℝ) ≤ (1/3)^n := by positivity
  exact h.trans (by nlinarith)

theorem codingApprox_cauchy (ω : SignStream) : CauchySeq (codingApprox ω) :=
  cauchySeq_of_le_geometric (1/3) (3/2) (by norm_num) (codingApprox_step ω)

def coding (ω : SignStream) : BranchDomain := limUnder atTop (codingApprox ω)

theorem coding_tendsto (ω : SignStream) : Tendsto (codingApprox ω) atTop (𝓝 (coding ω)) :=
  (codingApprox_cauchy ω).tendsto_limUnder

theorem coding_unfold (ω : SignStream) : coding ω = branch (ω 0) (coding (streamShift 1 ω)) := by
  apply tendsto_nhds_unique ((coding_tendsto ω).comp (tendsto_add_atTop_nat 1))
  have h := ((branch_lipschitz (ω 0)).continuous.tendsto (coding (streamShift 1 ω))).comp
    (coding_tendsto (streamShift 1 ω))
  convert h using 1
  funext n
  exact branchPrefix_shift ω n branchOrigin

theorem coding_range (ω : SignStream) :
    (1/2 : ℝ) ≤ |(coding ω).val| ∧ |(coding ω).val| ≤ 13/20 := by
  rw [coding_unfold]
  have h := positiveBranch_mem (coding (streamShift 1 ω))
  cases he : ω 0 <;> simp only [he,branch,Bool.false_eq_true,↓reduceIte,abs_neg]
    <;> rw [abs_of_nonneg (by linarith [h.1])]
    <;> exact h

theorem coding_domain_distance (ω η : SignStream) : dist (coding ω) (coding η) ≤ (13/10 : ℝ) := by
  rw [Subtype.dist_eq,Real.dist_eq]
  exact (abs_sub _ _).trans (by linarith [(coding_range ω).2,(coding_range η).2])

theorem coding_prefix (ω : SignStream) (n : ℕ) :
    coding ω = branchPrefix ω n (coding (streamShift n ω)) := by
  induction n with
  | zero => simp only [branchPrefix,streamShift_zero,id_eq]
  | succ n ih =>
    change coding ω = branchPrefix ω n (branch (ω n) (coding (streamShift (n+1) ω)))
    rw [ih,coding_unfold (streamShift n ω)]
    have he : streamShift 1 (streamShift n ω) = streamShift (n+1) ω := by
      funext j
      dsimp [streamShift]
      congr 1
      omega
    simp only [he,streamShift,Nat.add_zero]

theorem expandingMap_coding (ω : SignStream) :
    expandingMap (coding ω) = coding (streamShift 1 ω) := by
  rw [coding_unfold,expandingMap_branch]

theorem expandingMap_iterate_coding (ω : SignStream) (n : ℕ) :
    expandingMap^[n] (coding ω) = coding (streamShift n ω) := by
  induction n generalizing ω with
  | zero => simp only [Function.iterate_zero,streamShift_zero,id_eq]
  | succ n ih =>
    rw [Function.iterate_succ_apply',ih,expandingMap_coding]
    congr 2
    funext j
    dsimp [streamShift]
    congr 1
    omega

theorem branch_measurable : Measurable (fun p : Bool × BranchDomain => branch p.1 p.2) := by
  have htrue : Measurable (fun p : Bool × BranchDomain => branch true p.2) := (branch_lipschitz true).continuous.measurable.comp measurable_snd
  have hfalse : Measurable (fun p : Bool × BranchDomain => branch false p.2) := (branch_lipschitz false).continuous.measurable.comp measurable_snd
  have he : (fun p : Bool × BranchDomain => branch p.1 p.2) =
      fun p => if p.1 = true then branch true p.2 else branch false p.2 := by
    funext p
    cases p.1 <;> rfl
  rw [he]
  exact htrue.ite (measurable_fst (measurableSet_singleton true)) hfalse

theorem branchPrefix_measurable (n : ℕ) :
    Measurable (fun p : SignStream × BranchDomain => branchPrefix p.1 n p.2) := by
  induction n with
  | zero => exact measurable_snd
  | succ n ih =>
    exact ih.comp (measurable_fst.prodMk
      (branch_measurable.comp (((measurable_pi_apply n).comp measurable_fst).prodMk measurable_snd)))

theorem coding_measurable : Measurable coding := by
  apply measurable_of_tendsto_metrizable
    (f := fun n ω => codingApprox ω n)
    (fun n => (branchPrefix_measurable n).comp (measurable_id.prodMk measurable_const))
  exact tendsto_pi_nhds.mpr coding_tendsto

theorem coding_prefix_distance {ω η : SignStream} (n : ℕ)
    (h : ∀ i < n, ω i = η i) :
    dist (coding ω) (coding η) ≤ (13/10 : ℝ)*(1/3)^n := by
  rw [coding_prefix ω n,coding_prefix η n,← branchPrefix_agree n h]
  have hl := (branchPrefix_lipschitz ω n).dist_le_mul
    (coding (streamShift n ω)) (coding (streamShift n η))
  simp only [NNReal.coe_pow,NNReal.coe_div,NNReal.coe_one,NNReal.coe_ofNat] at hl
  have hb := coding_domain_distance (streamShift n ω) (streamShift n η)
  have hp : (0 : ℝ) ≤ (1/3)^n := by positivity
  exact hl.trans (by nlinarith)

theorem coding_opposite_first {ω η : SignStream} (h : ω 0 ≠ η 0) :
    1 ≤ dist (coding ω) (coding η) := by
  rw [coding_unfold ω,coding_unfold η,Subtype.dist_eq,Real.dist_eq]
  cases hω : ω 0 <;> cases hη : η 0
  · exact (h (hω.trans hη.symm)).elim
  · rw [abs_sub_comm]
    exact branch_gap _ _
  · exact branch_gap _ _
  · exact (h (hω.trans hη.symm)).elim

/-- Different cylinders of depth n+1 are separated by 20^-n. -/
theorem coding_cylinder_separation {ω η : SignStream} (n : ℕ)
    (h : ∃ i < n+1, ω i ≠ η i) :
    (1/20 : ℝ)^n ≤ dist (coding ω) (coding η) := by
  induction n generalizing ω η with
  | zero =>
    obtain ⟨i,hi,hne⟩:=h
    have he : i=0 := by omega
    subst i
    simpa only [pow_zero] using coding_opposite_first hne
  | succ n ih =>
    by_cases h0 : ω 0 = η 0
    · have hs : ∃ i < n+1, streamShift 1 ω i ≠ streamShift 1 η i := by
        obtain ⟨i,hi,hne⟩:=h
        have hi0 : i≠0 := by intro he; subst i; exact hne h0
        obtain ⟨j,rfl⟩ := Nat.exists_eq_succ_of_ne_zero hi0
        exact ⟨j,by omega,by simpa [streamShift,Nat.add_comm] using hne⟩
      have hb := (branch_distance (ω 0) (coding (streamShift 1 ω)) (coding (streamShift 1 η))).1
      rw [coding_unfold ω,coding_unfold η,← h0]
      rw [Subtype.dist_eq,Real.dist_eq]
      have hi := ih hs
      rw [Subtype.dist_eq,Real.dist_eq] at hi
      rw [pow_succ]
      nlinarith
    · exact (pow_le_one₀ (by norm_num : (0 : ℝ) ≤ 1/20) (by norm_num)).trans
        (coding_opposite_first h0)

theorem coding_injective : Function.Injective coding := by
  intro ω η he
  funext n
  by_contra hn
  have hd := coding_cylinder_separation n ⟨n,by omega,hn⟩
  rw [he,dist_self] at hd
  exact (not_le_of_gt (pow_pos (by norm_num : (0 : ℝ)<1/20) n)) hd

end NeuralGeneralization.BatchTwoContinuousDepthLower
