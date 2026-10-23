import NeuralGeneralization.BatchTwoActivationScalarCover

/-! Linear-entropy activation coding by adjacent rounded increments.
The chosen representatives remain actual globally one-Lipschitz functions. -/
noncomputable section
set_option maxHeartbeats 1200000
set_option maxRecDepth 10000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel ParameterGrid

abbrev ActivationWalk (J : ℕ) := {q : Fin (2*J+1) → GridInt J //
  (q ⟨J,by omega⟩).val=0 ∧
  ∀i : Fin (2*J), |(q i.succ).val-(q i.castSucc).val|≤1}

noncomputable instance (J : ℕ) : Fintype (ActivationWalk J) := Fintype.ofFinite _

def activationWalkIncrements {J : ℕ} (q : ActivationWalk J) : Fin (2*J)→GridInt 1 :=
  fun i=>⟨(q.val i.succ).val-(q.val i.castSucc).val,
    Finset.mem_Icc.mpr (by simpa only [Nat.cast_one] using abs_le.mp (q.property.2 i))⟩

theorem activationWalkIncrements_injective (J : ℕ) :
    Function.Injective (@activationWalkIncrements J) := by
  intro a b hab
  have hd (k : Fin (2*J+1)) : (a.val k).val-(b.val k).val =
      (a.val 0).val-(b.val 0).val := by
    induction k using Fin.induction with
    | zero => rfl
    | succ i ih =>
      have hh := congrArg Subtype.val (congrFun hab i)
      change (a.val i.succ).val-(a.val i.castSucc).val =
        (b.val i.succ).val-(b.val i.castSucc).val at hh
      omega
  have hz := hd ⟨J,by omega⟩
  rw [a.property.1,b.property.1] at hz
  apply Subtype.ext
  funext k
  apply Subtype.ext
  have hh := hd k
  omega

theorem activationWalk_card_le (J : ℕ) : Fintype.card (ActivationWalk J)≤3^(2*J) := by
  have hh := Fintype.card_le_of_injective _ (activationWalkIncrements_injective J)
  simpa only [Fintype.card_fun,Fintype.card_fin,gridInt_card] using hh

def sharpActivationNode (R : ℝ) (J : ℕ) (k : Fin (2*J+1)) : ℝ :=
  R*((k.val:ℝ)-(J:ℝ))/(J:ℝ)

theorem sharpActivationNode_abs_le {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (k : Fin (2*J+1)) : |sharpActivationNode R J k|≤R := by
  have hj : (0:ℝ)<J := Nat.cast_pos.mpr hJ
  have hk0 : (0:ℝ)≤k.val := Nat.cast_nonneg _
  have hk : (k.val:ℝ)≤2*(J:ℝ) := by exact_mod_cast (show k.val≤2*J by omega)
  rw [sharpActivationNode,abs_div,abs_mul,abs_of_pos hR,abs_of_pos hj]
  apply (div_le_iff₀ hj).mpr
  have hh : |(k.val:ℝ)-(J:ℝ)|≤(J:ℝ) := abs_le.mpr ⟨by linarith,by linarith⟩
  exact mul_le_mul_of_nonneg_left hh hR.le

def sharpActivationValue (R : ℝ) (J : ℕ) (φ : UnitActivation) (k : Fin (2*J+1)) : ℤ :=
  ⌊(J:ℝ)*φ.val (sharpActivationNode R J k)/R⌋

theorem sharpActivationValue_bounds {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (φ : UnitActivation) (k : Fin (2*J+1)) :
    -(J:ℤ)≤sharpActivationValue R J φ k ∧ sharpActivationValue R J φ k≤J := by
  have hj : (0:ℝ)≤J := Nat.cast_nonneg _
  have hp := (activation_abs_le φ.property (sharpActivationNode R J k)).trans
    (by simpa only [one_mul] using sharpActivationNode_abs_le hR hJ k)
  have hb : |(J:ℝ)*φ.val (sharpActivationNode R J k)/R|≤(J:ℝ) := by
    rw [abs_div,abs_mul,abs_of_nonneg hj,abs_of_pos hR]
    apply (div_le_iff₀ hR).mpr
    exact mul_le_mul_of_nonneg_left hp hj
  obtain ⟨hl,hu⟩ := abs_le.mp hb
  constructor
  · exact Int.le_floor.mpr (by simpa using hl)
  · have hh := Int.floor_mono hu
    simpa only [sharpActivationValue,Int.floor_natCast] using hh

theorem sharpActivationValue_zero (R : ℝ) (J : ℕ) (φ : UnitActivation) :
    sharpActivationValue R J φ ⟨J,by omega⟩=0 := by
  simp only [sharpActivationValue,sharpActivationNode,sub_self,mul_zero,zero_div,
    φ.property.1,Int.floor_zero]

theorem floor_adjacent {x y : ℝ} (h : |x-y|≤1) : |⌊x⌋-⌊y⌋|≤(1:ℤ) := by
  obtain ⟨hl,hu⟩ := abs_le.mp h
  have hx := Int.lt_floor_add_one x
  have hy := Int.lt_floor_add_one y
  have hxy : ⌊x⌋≤⌊y⌋+1 := Int.floor_le_iff.mpr (by push_cast; linarith)
  have hyx : ⌊y⌋≤⌊x⌋+1 := Int.floor_le_iff.mpr (by push_cast; linarith)
  exact abs_le.mpr ⟨by omega,by omega⟩

theorem sharpActivationValue_adjacent {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (φ : UnitActivation) (i : Fin (2*J)) :
    |sharpActivationValue R J φ i.succ-sharpActivationValue R J φ i.castSucc|≤1 := by
  have hj : (0:ℝ)<J := Nat.cast_pos.mpr hJ
  apply floor_adjacent
  have hl := φ.property.2 (sharpActivationNode R J i.succ) (sharpActivationNode R J i.castSucc)
  simp only [one_mul] at hl
  have hdiff : sharpActivationNode R J i.succ-sharpActivationNode R J i.castSucc=R/J := by
    simp only [sharpActivationNode,Fin.val_succ,Fin.val_castSucc,Nat.cast_add,Nat.cast_one]
    ring
  rw [hdiff,abs_of_pos (div_pos hR hj)] at hl
  rw [show (J:ℝ)*φ.val (sharpActivationNode R J i.succ)/R-
      (J:ℝ)*φ.val (sharpActivationNode R J i.castSucc)/R=
      ((J:ℝ)/R)*(φ.val (sharpActivationNode R J i.succ)-φ.val (sharpActivationNode R J i.castSucc)) by ring,
    abs_mul,abs_of_pos (div_pos hj hR)]
  calc
    _≤((J:ℝ)/R)*(R/J) := mul_le_mul_of_nonneg_left hl (div_pos hj hR).le
    _=1 := by field_simp

def sharpActivationCode {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (φ : UnitActivation) : ActivationWalk J :=
  ⟨fun k=>⟨sharpActivationValue R J φ k,Finset.mem_Icc.mpr (sharpActivationValue_bounds hR hJ φ k)⟩,
    sharpActivationValue_zero R J φ,sharpActivationValue_adjacent hR hJ φ⟩


def sharpGridIndex {J : ℕ} (i : GridInt J) : Fin (2*J+1) :=
  ⟨(i.val+(J:ℤ)).toNat,by
    have hi := Finset.mem_Icc.mp i.property
    omega⟩

theorem sharpGridIndex_node {R : ℝ} {J : ℕ} (i : GridInt J) :
    sharpActivationNode R J (sharpGridIndex i)=activationGridNode R J i := by
  have hi := Finset.mem_Icc.mp i.property
  have he : (((i.val+(J:ℤ)).toNat:ℕ):ℤ)=i.val+(J:ℤ) := Int.toNat_of_nonneg (by omega)
  have he' : ((i.val+(J:ℤ)).toNat:ℝ)=(i.val:ℝ)+(J:ℝ) := by exact_mod_cast he
  simp only [sharpActivationNode,sharpGridIndex,he',activationGridNode]
  ring

theorem equal_sharpActivationCode_grid_close {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (φ ψ : UnitActivation) (he : sharpActivationCode hR hJ φ=sharpActivationCode hR hJ ψ)
    (k : Fin (2*J+1)) :
    |φ.val (sharpActivationNode R J k)-ψ.val (sharpActivationNode R J k)|≤R/J := by
  have hj : (0:ℝ)<J := Nat.cast_pos.mpr hJ
  have hc := congrArg (fun q : ActivationWalk J => (q.val k).val) he
  change sharpActivationValue R J φ k=sharpActivationValue R J ψ k at hc
  let u := (J:ℝ)*φ.val (sharpActivationNode R J k)/R
  let v := (J:ℝ)*ψ.val (sharpActivationNode R J k)/R
  have heq : ⌊u⌋=⌊v⌋ := hc
  have huf := Int.floor_le u
  have hvf := Int.floor_le v
  have hfu := Int.lt_floor_add_one u
  have hfv := Int.lt_floor_add_one v
  rw [heq] at huf hfu
  have hdiff : |u-v|≤1 := abs_le.mpr ⟨by linarith,by linarith⟩
  have hediff : u-v=((J:ℝ)/R)*(φ.val (sharpActivationNode R J k)-ψ.val (sharpActivationNode R J k)) := by
    dsimp [u,v]; ring
  rw [hediff,abs_mul,abs_of_pos (div_pos hj hR)] at hdiff
  apply (le_div_iff₀ hj).mpr
  have hh := (mul_le_mul_of_nonneg_left hdiff hR.le)
  have hid : R*((J:ℝ)/R)=J := by field_simp
  rw [←mul_assoc,hid,mul_one] at hh
  nlinarith

/-- Same increment code gives the sharper three-mesh uniform error. -/
theorem equal_sharpActivationCode_close {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (φ ψ : UnitActivation) (he : sharpActivationCode hR hJ φ=sharpActivationCode hR hJ ψ)
    (x : ℝ) (hx : |x|≤R) : |φ.val x-ψ.val x|≤3*R/J := by
  let i := roundUnitGrid J (x/R)
  let y := activationGridNode R J i
  have hxy : |x-y|≤R/J := scaled_grid_error hR hJ x hx
  have hmid := equal_sharpActivationCode_grid_close hR hJ φ ψ he (sharpGridIndex i)
  rw [sharpGridIndex_node] at hmid
  have hl := φ.property.2 x y
  have hr := ψ.property.2 y x
  simp only [one_mul,abs_sub_comm y x] at hl hr
  have ht1 := abs_sub_le (φ.val x) (φ.val y) (ψ.val x)
  have ht2 := abs_sub_le (φ.val y) (ψ.val y) (ψ.val x)
  change |φ.val y-ψ.val y|≤R/J at hmid
  rw [show 3*R/(J:ℝ)=3*(R/(J:ℝ)) by ring]
  linarith

def sharpActivationRepresentative {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (q : ActivationWalk J) : UnitActivation := by
  classical
  exact if h : ∃φ,sharpActivationCode hR hJ φ=q then Classical.choose h else zeroUnitActivation

theorem sharpActivationRepresentative_code {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (φ : UnitActivation) : sharpActivationCode hR hJ
      (sharpActivationRepresentative hR hJ (sharpActivationCode hR hJ φ))=sharpActivationCode hR hJ φ := by
  unfold sharpActivationRepresentative
  split_ifs with h
  · exact Classical.choose_spec h
  · exact False.elim (h ⟨φ,rfl⟩)

theorem sharpActivationRepresentative_covers {R : ℝ} (hR : 0<R) {J : ℕ} (hJ : 0<J)
    (φ : UnitActivation) (x : ℝ) (hx : |x|≤R) :
    |φ.val x-(sharpActivationRepresentative hR hJ (sharpActivationCode hR hJ φ)).val x|≤3*R/J :=
  equal_sharpActivationCode_close hR hJ φ _ (sharpActivationRepresentative_code hR hJ φ).symm x hx


theorem three_le_exp_three_halves : (3:ℝ)≤Real.exp (3/2) := by
  have hh : (3/2:ℝ)≤Real.exp (1/2) := by linarith [Real.add_one_le_exp (1/2)]
  have hp := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤3/2) hh 3
  rw [←Real.exp_nat_mul] at hp
  norm_num at hp
  linarith

theorem sharpActivationWalk_factor_le_exp (J : ℕ) :
    2*(Fintype.card (ActivationWalk J):ℝ)≤Real.exp (1+3*(J:ℝ)) := by
  have hc : (Fintype.card (ActivationWalk J):ℝ)≤(3:ℝ)^(2*J) := by
    exact_mod_cast activationWalk_card_le J
  have hp := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤3) three_le_exp_three_halves (2*J)
  have h2 : (2:ℝ)≤Real.exp 1 := by linarith [Real.add_one_le_exp 1]
  apply (mul_le_mul h2 (hc.trans hp) (Nat.cast_nonneg _) (Real.exp_pos _).le).trans_eq
  rw [←Real.exp_nat_mul,←Real.exp_add]
  congr 1
  push_cast
  ring

def sharpActivationResolution (R η : ℝ) : ℕ := ⌈3*R/η⌉₊

theorem sharpActivationResolution_pos {R η : ℝ} (hR : 0<R) (hη : 0<η) :
    0<sharpActivationResolution R η := Nat.ceil_pos.mpr (by positivity)

theorem sharpActivationResolution_error {R η : ℝ} (hR : 0<R) (hη : 0<η) :
    3*R/(sharpActivationResolution R η:ℝ)≤η := by
  have hq : (0:ℝ)<sharpActivationResolution R η := Nat.cast_pos.mpr (sharpActivationResolution_pos hR hη)
  have hh : 3*R/η≤(sharpActivationResolution R η:ℝ) := Nat.le_ceil _
  apply (div_le_iff₀ hq).mpr
  have ht := (div_le_iff₀ hη).mp hh
  nlinarith

/-- The exact entropy constant used by the manuscript: the code space of
actual one-Lipschitz representatives has `log(2*M)≤14*R/η`. -/
theorem sharpActivationResolution_entropy {R η : ℝ} (hR : 0<R) (hη : 0<η) (hηR : η≤R) :
    2*(Fintype.card (ActivationWalk (sharpActivationResolution R η)):ℝ)≤Real.exp (14*R/η) := by
  apply (sharpActivationWalk_factor_le_exp _).trans
  apply Real.exp_le_exp.mpr
  have hq : (sharpActivationResolution R η:ℝ)≤3*R/η+1 := (Nat.ceil_lt_add_one (by positivity)).le
  have hr : 1≤R/η := (one_le_div hη).mpr hηR
  rw [show 3*R/η=3*(R/η) by ring] at hq
  rw [show 14*R/η=14*(R/η) by ring]
  linarith

end NeuralGeneralization.BatchTwoActivation
