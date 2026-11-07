import NeuralGeneralization.BatchTwoCircuitConverseBitFields

/-! Executable, range-checked wire addresses and NAND-circuit descriptions. -/
namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000

def writeAddress {n : ℕ} (i : Fin n) : List Bool := writeBits (Nat.clog 2 n) i.val

def readAddress (n : ℕ) (bs : List Bool) : Option (Fin n × List Bool) := do
  let (i,rest) ← readBits (Nat.clog 2 n) bs
  if hi : i<n then return (⟨i,hi⟩,rest) else none

@[simp] theorem writeAddress_length {n : ℕ} (i : Fin n) :
    (writeAddress i).length=Nat.clog 2 n := writeBits_length _ _

theorem readAddress_writeAddress {n : ℕ} (i : Fin n) (rest : List Bool) :
    readAddress n (writeAddress i++rest)=some (i,rest) := by
  have hi : i.val<2^(Nat.clog 2 n) := i.isLt.trans_le (Nat.le_pow_clog (by omega) n)
  simp [readAddress,writeAddress,readBits_writeBits _ _ hi,i.isLt]

theorem readAddress_sound {n : ℕ} {bs rest : List Bool} {i : Fin n}
    (h : readAddress n bs=some (i,rest)) : bs=writeAddress i++rest := by
  unfold readAddress at h
  cases hr : readBits (Nat.clog 2 n) bs with
  | none => simp [hr] at h
  | some p =>
    rcases p with ⟨v,tail⟩
    simp only [hr,Option.bind_eq_bind,Option.bind_some] at h
    split at h
    · simp only [Option.pure_def,Option.some.injEq,Prod.mk.injEq] at h
      rcases h with ⟨rfl,rfl⟩
      exact (readBits_sound hr).2
    · simp at h

/-- Addresses equal to or beyond the available wire count are rejected. -/
theorem readAddress_reject {n v : ℕ} {bs rest : List Bool}
    (h : readBits (Nat.clog 2 n) bs=some (v,rest)) (hv : n≤v) : readAddress n bs=none := by
  simp [readAddress,h,not_lt_of_ge hv]

def writeGates {d : ℕ} : {n : ℕ} → Gates d n → List Bool
  | 0,_ => []
  | n+1,(g,i,j) => writeGates g++writeAddress i++writeAddress j

def readGates (d : ℕ) : (n : ℕ) → List Bool → Option (Gates d n × List Bool)
  | 0,bs => some ((),bs)
  | n+1,bs => do
    let (g,tail) ← readGates d n bs
    let (i,tail) ← readAddress (d+2+n) tail
    let (j,tail) ← readAddress (d+2+n) tail
    return ((g,i,j),tail)

@[simp] theorem writeGates_length {d n : ℕ} (g : Gates d n) :
    (writeGates g).length=2*addressBits d n := by
  induction n with
  | zero => simp [writeGates,addressBits]
  | succ n ih =>
    rcases g with ⟨g,i,j⟩
    simp only [writeGates,List.length_append,ih,writeAddress_length,addressBits_succ]
    omega

theorem readGates_writeGates {d n : ℕ} (g : Gates d n) (rest : List Bool) :
    readGates d n (writeGates g++rest)=some (g,rest) := by
  induction n generalizing rest with
  | zero => cases g; rfl
  | succ n ih =>
    rcases g with ⟨g,i,j⟩
    simp only [writeGates,List.append_assoc,readGates]
    rw [ih]
    simp only [Option.bind_eq_bind,Option.bind_some,readAddress_writeAddress,Option.pure_def]

theorem readGates_sound {d n : ℕ} {bs rest : List Bool} {g : Gates d n}
    (h : readGates d n bs=some (g,rest)) : bs=writeGates g++rest := by
  induction n generalizing bs rest with
  | zero => simp only [readGates,Option.some.injEq,Prod.mk.injEq] at h; exact h.2
  | succ n ih =>
    cases hg : readGates d n bs with
    | none => simp [readGates,hg] at h
    | some p =>
      rcases p with ⟨g0,tail0⟩
      cases hi : readAddress (d+2+n) tail0 with
      | none => simp [readGates,hg,hi] at h
      | some p =>
        rcases p with ⟨i,tail1⟩
        cases hj : readAddress (d+2+n) tail1 with
        | none => simp [readGates,hg,hi,hj] at h
        | some p =>
          rcases p with ⟨j,tail2⟩
          simp only [readGates,hg,hi,hj,Option.bind_eq_bind,Option.bind_some,Option.pure_def,Option.some.injEq,Prod.mk.injEq] at h
          rcases h with ⟨rfl,rfl⟩
          rw [ih hg,readAddress_sound hi,readAddress_sound hj]
          simp only [writeGates,List.append_assoc]

def writeBase {d : ℕ} : Circuit d → List Bool
  | ⟨0,_⟩ => [false,false]
  | ⟨n+1,g⟩ => [false,true]++writeUnary (n+1)++writeGates g

def readBase (d : ℕ) : List Bool → Option (Circuit d × List Bool)
  | false::false::rest => some (Circuit.empty d,rest)
  | false::true::rest => do
    let (n,tail) ← readUnary rest
    if n=0 then none else do
      let (g,tail) ← readGates d n tail
      return (⟨n,g⟩,tail)
  | _ => none

@[simp] theorem writeBase_length {d : ℕ} (c : Circuit d) :
    (writeBase c).length=baseLength d c.size := by
  rcases c with ⟨n,g⟩
  cases n with
  | zero => simp [writeBase,baseLength]
  | succ n => simp [writeBase,baseLength]; omega

theorem readBase_writeBase {d : ℕ} (c : Circuit d) (rest : List Bool) :
    readBase d (writeBase c++rest)=some (c,rest) := by
  rcases c with ⟨n,g⟩
  cases n with
  | zero => cases g; rfl
  | succ n =>
    simp only [writeBase,List.append_assoc,List.cons_append,List.nil_append,readBase]
    rw [readUnary_writeUnary]
    simp only [Option.bind_eq_bind,Option.bind_some,Nat.add_eq_zero_iff,one_ne_zero,and_false,ite_false,
      readGates_writeGates,Option.pure_def]

end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
