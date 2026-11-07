import NeuralGeneralization.BatchTwoCircuitConverseCircuitBits

/-! Executable serialization and suffix-preserving parsing of the full exception language. -/
namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000

def writeChain {d : ℕ} (c : Circuit d) : {n : ℕ} → (Fin n → Patch d) → List Bool
  | 0,_ => writeBase c
  | n+1,p => true::(writeInput (p 0).1++((p 0).2::writeChain c (Fin.tail p)))

def serialize {d : ℕ} (p : Program d) : List Bool := writeChain p.2.2 p.2.1

/-- Fuel bounds exception nesting only; parsing an encoded program uses at
most its bit length, so the public decoder is total and executable. -/
def readProgramFuel (d : ℕ) : ℕ → List Bool → Option (Program d × List Bool)
  | 0,_ => none
  | _+1,[] => none
  | _+1,false::bs => do
    let (c,rest) ← readBase d (false::bs)
    return (Program.base c,rest)
  | fuel+1,true::bs => do
    let (x,rest) ← readInput d bs
    match rest with
    | [] => none
    | y::rest => do
      let (p,rest) ← readProgramFuel d fuel rest
      return (Program.exception x y p,rest)

/-- The complete decoder rejects malformed strings and trailing garbage. -/
def deserialize (d : ℕ) (bs : List Bool) : Option (Program d) := do
  let (p,rest) ← readProgramFuel d bs.length bs
  if rest=[] then return p else none

@[simp] theorem serialize_base {d : ℕ} (c : Circuit d) :
    serialize (Program.base c)=writeBase c := rfl

@[simp] theorem serialize_exception {d : ℕ} (x : Input d) (y : Bool) (p : Program d) :
    serialize (Program.exception x y p)=true::(writeInput x++(y::serialize p)) := by
  simp [serialize,writeChain,Program.exception]

lemma exception_eta {d n : ℕ} (p : Fin (n+1) → Patch d) (c : Circuit d) :
    Program.exception (p 0).1 (p 0).2 (⟨n,Fin.tail p,c⟩ : Program d)=⟨n+1,p,c⟩ := by
  simp [Program.exception]

lemma writeChain_length {d n : ℕ} (c : Circuit d) (p : Fin n → Patch d) :
    (writeChain c p).length=baseLength d c.size+n*(d+2) := by
  induction n with
  | zero => simp [writeChain]
  | succ n ih =>
    simp only [writeChain,List.length_cons,List.length_append,writeInput_length,ih,Nat.add_mul]
    omega

@[simp] theorem serialize_length {d : ℕ} (p : Program d) :
    (serialize p).length=p.length := writeChain_length _ _

lemma nesting_lt_length {d : ℕ} (p : Program d) : p.1 < (serialize p).length := by
  rw [serialize_length]
  have hbase := baseLength_ge d p.2.2.size
  unfold Program.length
  nlinarith

lemma readProgramFuel_base {d : ℕ} (fuel : ℕ) (c : Circuit d) (rest : List Bool) :
    readProgramFuel d (fuel+1) (writeBase c++rest)=some (Program.base c,rest) := by
  have he : ∃ bs,writeBase c=false::bs := by
    rcases c with ⟨n,g⟩
    cases n <;> simp [writeBase]
  obtain ⟨bs,hbs⟩ := he
  have h := readBase_writeBase c rest
  rw [hbs] at h ⊢
  simp only [List.cons_append] at h
  simp only [List.cons_append,readProgramFuel,h,Option.bind_eq_bind,Option.bind_some,Option.pure_def]

/-- Complete round trip, with arbitrary suffix and any adequate exception fuel. -/
theorem readProgramFuel_serialize {d : ℕ} (p : Program d) (fuel : ℕ) (hf : p.1<fuel)
    (rest : List Bool) :
    readProgramFuel d fuel (serialize p++rest)=some (p,rest) := by
  induction fuel generalizing p rest with
  | zero => omega
  | succ fuel ih =>
    rcases p with ⟨n,patches,c⟩
    cases n with
    | zero =>
      have he : patches=Fin.elim0 := by funext i; exact Fin.elim0 i
      subst patches
      exact readProgramFuel_base fuel c rest
    | succ n =>
      let p : Program d := ⟨n,Fin.tail patches,c⟩
      have hp : p.1<fuel := by dsimp [p]; dsimp only at hf; omega
      have heta := exception_eta patches c
      rw [← heta,serialize_exception]
      simp only [List.cons_append,List.append_assoc,readProgramFuel]
      rw [readInput_writeInput]
      simp only [Option.bind_eq_bind,Option.bind_some]
      rw [ih p hp rest]
      simp only [Option.bind_eq_bind,Option.bind_some,Option.pure_def,p]

@[simp] theorem deserialize_serialize {d : ℕ} (p : Program d) :
    deserialize d (serialize p)=some p := by
  unfold deserialize
  have h := readProgramFuel_serialize p (serialize p).length (nesting_lt_length p) []
  simp only [List.append_nil] at h
  rw [h]
  rfl

/-- Literal bit length equals the length used by all existing prefix-prior proofs. -/
theorem compiled_size_le_bits {d : ℕ} (p : Program d) :
    p.compile.size ≤ 3*(serialize p).length := by
  rw [serialize_length]
  exact Program.compile_size_le p

theorem serialize_injective (d : ℕ) : Function.Injective (@serialize d) := by
  intro p q h
  have hh := congrArg (deserialize d) h
  simpa only [deserialize_serialize,Option.some.injEq] using hh

/-- A valid complete program cannot be a proper prefix of another one. -/
theorem serialize_prefix_free {d : ℕ} (p q : Program d) (suffix : List Bool)
    (h : serialize p++suffix=serialize q) : p=q ∧ suffix=[] := by
  have hlen : (serialize p).length≤(serialize q).length := by
    have hh := congrArg List.length h
    simp only [List.length_append] at hh
    omega
  have hp := readProgramFuel_serialize p (serialize q).length
    ((nesting_lt_length p).trans_le hlen) suffix
  have hq := readProgramFuel_serialize q (serialize q).length (nesting_lt_length q) []
  rw [h] at hp
  simp only [List.append_nil] at hq
  have he := hp.symm.trans hq
  simpa only [Option.some.injEq,Prod.mk.injEq] using he

end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
