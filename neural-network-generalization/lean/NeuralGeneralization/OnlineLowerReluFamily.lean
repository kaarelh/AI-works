import NeuralGeneralization.OnlineLowerRailSystem
import Mathlib.Data.Finset.Range

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu.Family

abbrev prefixDim (k:ℕ) : ℕ := 4*k+3
abbrev pathDim (k:ℕ) : ℕ := 2*k+1
abbrev logicalDim (k:ℕ) : ℕ := prefixDim k+pathDim k
abbrev pairDim (k:ℕ) : ℕ := prefixDim k+(pathDim k+2*k)

@[simp] theorem logicalDim_eq (k:ℕ) : logicalDim k=6*k+4 := by unfold logicalDim prefixDim pathDim; omega
@[simp] theorem pairDim_eq (k:ℕ) : pairDim k=8*k+4 := by unfold pairDim prefixDim pathDim; omega

def logicalIndex (k:ℕ) : (Fin (prefixDim k) ⊕ Fin (pathDim k)) ≃ Fin (logicalDim k) :=
  finSumFinEquiv

def pairIndex (k:ℕ) : (Fin (prefixDim k) ⊕ (Fin (pathDim k) ⊕ Fin (2*k))) ≃ Fin (pairDim k) :=
  (Equiv.sumCongr (Equiv.refl _) finSumFinEquiv).trans finSumFinEquiv

def rawColumn (k:ℕ) : Fin (prefixDim k) ⊕ (Fin (pathDim k) ⊕ Fin (2*k)) →
    Finset (Fin (logicalDim k))
  | .inl i => {logicalIndex k (.inl i)}
  | .inr (.inl i) => {logicalIndex k (.inr i)}
  | .inr (.inr j) => {logicalIndex k (.inr j.castSucc),logicalIndex k (.inr j.succ)}

def column (k:ℕ) (j:Fin (pairDim k)) : Finset (Fin (logicalDim k)) :=
  rawColumn k ((pairIndex k).symm j)

@[simp] theorem column_prefix (k:ℕ) (i:Fin (prefixDim k)) :
    column k (pairIndex k (.inl i))={logicalIndex k (.inl i)} := by simp [column,rawColumn]
@[simp] theorem column_loop (k:ℕ) (i:Fin (pathDim k)) :
    column k (pairIndex k (.inr (.inl i)))={logicalIndex k (.inr i)} := by simp [column,rawColumn]
@[simp] theorem column_edge (k:ℕ) (j:Fin (2*k)) :
    column k (pairIndex k (.inr (.inr j)))=
      {logicalIndex k (.inr j.castSucc),logicalIndex k (.inr j.succ)} := by simp [column,rawColumn]

theorem column_card_le (k:ℕ) (j:Fin (pairDim k)) : (column k j).card≤2 := by
  obtain ⟨a,rfl⟩ := (pairIndex k).surjective j
  rcases a with i | i | e
  · simp
  · simp
  · rw [column_edge]
    exact Finset.card_le_two

def privatePair (k:ℕ) (i:Fin (logicalDim k)) : Fin (pairDim k) :=
  pairIndex k (match (logicalIndex k).symm i with
    | .inl j => .inl j
    | .inr j => .inr (.inl j))

@[simp] theorem column_privatePair (k:ℕ) (i:Fin (logicalDim k)) :
    column k (privatePair k i)={i} := by
  obtain ⟨a,rfl⟩ := (logicalIndex k).surjective i
  cases a <;> simp [privatePair]

def rawIncrement (k:ℕ) : Fin (prefixDim k) ⊕ (Fin (pathDim k) ⊕ Fin (2*k)) → ℕ
  | .inl _ => 4
  | .inr (.inl _) => 4
  | .inr (.inr j) => if j.val%2=0 then 6 else 2

def increment (k:ℕ) (j:Fin (pairDim k)) : ℕ := rawIncrement k ((pairIndex k).symm j)

@[simp] theorem increment_prefix (k:ℕ) (i:Fin (prefixDim k)) :
    increment k (pairIndex k (.inl i))=4 := by simp [increment,rawIncrement]
@[simp] theorem increment_loop (k:ℕ) (i:Fin (pathDim k)) :
    increment k (pairIndex k (.inr (.inl i)))=4 := by simp [increment,rawIncrement]
@[simp] theorem increment_edge (k:ℕ) (j:Fin (2*k)) :
    increment k (pairIndex k (.inr (.inr j)))=if j.val%2=0 then 6 else 2 := by simp [increment,rawIncrement]

theorem increment_bounds (k:ℕ) (j:Fin (pairDim k)) : 2 ≤ increment k j ∧ increment k j ≤ 6 := by
  obtain ⟨a,rfl⟩ := (pairIndex k).surjective j
  rcases a with i | i | e <;> simp
  split <;> omega

theorem increment_even (k:ℕ) (j:Fin (pairDim k)) : Even (increment k j) := by
  obtain ⟨a,rfl⟩ := (pairIndex k).surjective j
  rcases a with i | i | e
  · rw [increment_prefix]
    exact ⟨2,rfl⟩
  · rw [increment_loop]
    exact ⟨2,rfl⟩
  · rw [increment_edge]
    split
    · exact ⟨3,rfl⟩
    · exact ⟨1,rfl⟩

def size (R k:ℕ) (j:Fin (pairDim k)) : Bool→ℕ
  | false => R
  | true => R+increment k j

@[simp] theorem size_false (R k:ℕ) (j:Fin (pairDim k)) : size R k j false=R := rfl
@[simp] theorem size_true (R k:ℕ) (j:Fin (pairDim k)) : size R k j true=R+increment k j := rfl

theorem size_even (R k:ℕ) (hR:Even R) : ∀j b,Even (size R k j b) := by
  intro j b
  cases b
  · exact hR
  · exact hR.add (increment_even k j)

/-- The fixed-width coordinate witnessing each logical loop column. -/
def privateCoord (R k:ℕ) (hR:0<R) (i:Fin (logicalDim k)) : Fin (railDimension (size R k)) :=
  railIndex (size R k) ⟨privatePair k i,false,⟨0,hR⟩⟩

@[simp] theorem physicalColumn_privateCoord (R k:ℕ) (hR:0<R) (i:Fin (logicalDim k)) :
    physicalColumn (size R k) (column k) (privateCoord R k hR i)={i} := by
  unfold physicalColumn privateCoord
  rw [Equiv.symm_apply_apply]
  exact column_privatePair k i


private theorem edgeIncrement_sum_range (k:ℕ) :
    (∑ j∈Finset.range (2*k),if j%2=0 then 6 else 2)=8*k := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [show 2*(k+1)=2*k+1+1 by omega,Finset.sum_range_succ,Finset.sum_range_succ,ih]
    simp [Nat.add_mod,Nat.mul_mod]
    omega

theorem edgeIncrement_sum (k:ℕ) :
    (∑ j:Fin (2*k),if j.val%2=0 then 6 else 2)=8*k := by
  rw [Fin.sum_univ_eq_sum_range (fun j:ℕ => if j%2=0 then 6 else 2)]
  exact edgeIncrement_sum_range k

theorem increment_sum (k:ℕ) : (∑ j,increment k j)=4*pairDim k := by
  have he := (pairIndex k).sum_comp (increment k)
  rw [←he]
  simp only [increment,Equiv.symm_apply_apply]
  rw [Fintype.sum_sum_type,Fintype.sum_sum_type]
  simp only [rawIncrement,Finset.sum_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul]
  rw [edgeIncrement_sum]
  unfold pairDim prefixDim pathDim
  omega

theorem physicalDimension_eq (R k:ℕ) :
    railDimension (size R k)=pairDim k*(2*R+4) := by
  rw [railDimension_eq]
  simp only [size_false,size_true]
  have he : (∑ i:Fin (pairDim k),(R+(R+increment k i))) =
      (∑ _i:Fin (pairDim k),2*R)+(∑ i,increment k i) := by
    rw [←Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    omega
  rw [he,increment_sum]
  simp
  ring

theorem dimension_linear (R k:ℕ) : railDimension (size R k)≤(4*R+8)*logicalDim k := by
  rw [physicalDimension_eq]
  have hp : pairDim k≤2*logicalDim k := by rw [pairDim_eq,logicalDim_eq]; omega
  calc
    _ ≤ (2*logicalDim k)*(2*R+4) := Nat.mul_le_mul_right _ hp
    _ = _ := by ring

/-- The target in the lower-bound family has both a concrete bounded shallow
teacher and a linear-size NAND implementation. -/
theorem target_resources (R k:ℕ) (hR:0<R) :
    OnlineLower.BoundedTeacher OnlineLower.relu
      (OnlineLower.physicalParityTarget (physicalBase (size R k))
        (physicalColumn (size R k) (column k)))
      (OnlineLower.teacherWidth (railDimension (size R k)) (logicalDim k)) ∧
    OnlineLower.HasCircuitAtMost
      (OnlineLower.physicalParityTarget (physicalBase (size R k))
        (physicalColumn (size R k) (column k)))
      (17*railDimension (size R k)+5) ∧
    OnlineLower.teacherWidth (railDimension (size R k)) (logicalDim k)≤
      6*(4*R+9)*(logicalDim k)^2 := by
  apply OnlineLower.physicalParityTarget_resources
    (physicalBase (size R k)) (physicalColumn (size R k) (column k)) (privateCoord R k hR)
  · exact physicalColumn_privateCoord R k hR
  · intro j
    exact column_card_le k _
  · rw [logicalDim_eq]; omega
  · exact dimension_linear R k

theorem teacherWidth_quadratic_k (R k:ℕ) (hk:1≤k) :
    OnlineLower.teacherWidth (railDimension (size R k)) (logicalDim k)≤600*(4*R+9)*k^2 := by
  have hm : 1≤logicalDim k := by rw [logicalDim_eq]; omega
  have h := OnlineLower.teacherWidth_quadratic hm (dimension_linear R k)
  have hmk : logicalDim k≤10*k := by rw [logicalDim_eq]; omega
  calc
    _ ≤ 6*(4*R+9)*(logicalDim k)^2 := h
    _ ≤ 6*(4*R+9)*(10*k)^2 := Nat.mul_le_mul_left _ (Nat.pow_le_pow_left hmk 2)
    _ = _ := by ring


theorem support_card (R k:ℕ) (s:Finset (Fin (logicalDim k))) :
    (generatedSupport (physicalBase (size R k))
      (coordinateGenerator (physicalColumn (size R k) (column k))) s).card =
      pairDim k*R + ∑ j,if railOrientation (column k) s j then increment k j else 0 := by
  rw [physical_generatedSupport_card]
  have he (j:Fin (pairDim k)) : size R k j (railOrientation (column k) s j) =
      R+(if railOrientation (column k) s j then increment k j else 0) := by
    cases railOrientation (column k) s j <;> simp
  simp_rw [he]
  rw [Finset.sum_add_distrib]
  simp

theorem support_card_bounds (R k:ℕ) (s:Finset (Fin (logicalDim k))) :
    pairDim k*R ≤ (generatedSupport (physicalBase (size R k))
      (coordinateGenerator (physicalColumn (size R k) (column k))) s).card ∧
    (generatedSupport (physicalBase (size R k))
      (coordinateGenerator (physicalColumn (size R k) (column k))) s).card ≤ pairDim k*(R+4) := by
  rw [support_card]
  constructor
  · omega
  · have hs : (∑ j,if railOrientation (column k) s j then increment k j else 0)≤∑ j,increment k j := by
      apply Finset.sum_le_sum
      intro j _
      split <;> omega
    rw [increment_sum] at hs
    nlinarith

end NeuralGeneralization.OnlineLowerRelu.Family
