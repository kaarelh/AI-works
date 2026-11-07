import NeuralGeneralization.BatchTwoCircuitConversePrefixCoding
import Mathlib.Data.List.OfFn

/-! Executable fixed-width binary fields and self-delimiting unary integers. -/
namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000

/-- Least significant bit first; the paper leaves the order inside an address unspecified. -/
def writeBits : ℕ → ℕ → List Bool
  | 0, _ => []
  | k+1, n => decide (n%2=1) :: writeBits k (n/2)

def readBits : ℕ → List Bool → Option (ℕ × List Bool)
  | 0, bs => some (0,bs)
  | _+1, [] => none
  | k+1, b::bs => do
    let (n,rest) ← readBits k bs
    return (2*n+b.toNat,rest)

@[simp] theorem writeBits_length (k n : ℕ) : (writeBits k n).length=k := by
  induction k generalizing n with
  | zero => rfl
  | succ k ih => simp [writeBits,ih]

lemma bit_remainder (n : ℕ) : (decide (n%2=1)).toNat=n%2 := by
  have h := Nat.mod_lt n (by omega : 0<2)
  by_cases hn : n%2=1 <;> simp [hn] <;> omega

/-- The parser returns the exact encoded integer and preserves any suffix. -/
theorem readBits_writeBits (k n : ℕ) (hn : n<2^k) (rest : List Bool) :
    readBits k (writeBits k n++rest)=some (n,rest) := by
  induction k generalizing n with
  | zero =>
    have he : n=0 := by simpa using hn
    subst n
    rfl
  | succ k ih =>
    have hdiv : n/2<2^k := by rw [pow_succ] at hn; omega
    simp [writeBits,readBits,ih (n/2) hdiv,bit_remainder]
    have he := Nat.mod_add_div n 2
    omega

/-- Successful fixed-width parsing consumes precisely that many bits. -/
theorem readBits_sound {k : ℕ} {bs rest : List Bool} {n : ℕ}
    (h : readBits k bs=some (n,rest)) : n<2^k ∧ bs=writeBits k n++rest := by
  induction k generalizing bs n rest with
  | zero => simp only [readBits,Option.some.injEq,Prod.mk.injEq] at h; rcases h with ⟨rfl,rfl⟩; simp [writeBits]
  | succ k ih =>
    cases bs with
    | nil => simp [readBits] at h
    | cons b bs =>
      cases hr : readBits k bs with
      | none => simp [readBits,hr] at h
      | some p =>
        rcases p with ⟨v,tail⟩
        simp only [readBits,hr,Option.bind_some,Option.pure_def,Option.some.injEq,Prod.mk.injEq] at h
        rcases h with ⟨rfl,rfl⟩
        obtain ⟨hv,hbs⟩ := ih hr
        cases b <;> simp only [Bool.toNat_false,Bool.toNat_true] at *
        · constructor
          · rw [pow_succ]; omega
          · simpa [writeBits,Nat.add_mod,Nat.mul_mod,Nat.add_div] using congrArg (List.cons false) hbs
        · constructor
          · rw [pow_succ]; omega
          · simpa [writeBits,Nat.add_mod,Nat.mul_mod,Nat.add_div] using congrArg (List.cons true) hbs

def writeUnary (n : ℕ) : List Bool := List.replicate n true++[false]

def readUnary : List Bool → Option (ℕ × List Bool)
  | [] => none
  | false::bs => some (0,bs)
  | true::bs => do
    let (n,rest) ← readUnary bs
    return (n+1,rest)

@[simp] theorem writeUnary_length (n : ℕ) : (writeUnary n).length=n+1 := by simp [writeUnary]

theorem readUnary_writeUnary (n : ℕ) (rest : List Bool) :
    readUnary (writeUnary n++rest)=some (n,rest) := by
  induction n with
  | zero => rfl
  | succ n ih =>
    change ((readUnary (writeUnary n++rest)).bind (fun p => some (p.1+1,p.2)))=some (n+1,rest)
    rw [ih]
    rfl

def writeInput {d : ℕ} (x : Input d) : List Bool := List.ofFn x

def readInput : (d : ℕ) → List Bool → Option (Input d × List Bool)
  | 0,bs => some (Fin.elim0,bs)
  | _+1,[] => none
  | d+1,b::bs => do
    let (x,rest) ← readInput d bs
    return (Fin.cons b x,rest)

@[simp] theorem writeInput_length {d : ℕ} (x : Input d) : (writeInput x).length=d := by simp [writeInput]

theorem readInput_writeInput {d : ℕ} (x : Input d) (rest : List Bool) :
    readInput d (writeInput x++rest)=some (x,rest) := by
  induction d with
  | zero =>
    have he : (Fin.elim0 : Input 0)=x := by funext i; exact Fin.elim0 i
    simp [writeInput,readInput,List.ofFn_zero,he]
  | succ d ih =>
    simp only [writeInput,List.ofFn_succ,List.cons_append,readInput]
    change (do let (a,tail) ← readInput d (writeInput (Fin.tail x)++rest)
               pure (Fin.cons (x 0) a,tail))=some (x,rest)
    rw [ih]
    simp

end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
