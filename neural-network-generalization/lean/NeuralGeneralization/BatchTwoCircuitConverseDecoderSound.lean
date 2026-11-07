import NeuralGeneralization.BatchTwoCircuitConverseProgramBits

/-! The parser accepts exactly the serialized grammar; no malformed alternative encodings survive. -/
namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000

lemma readUnary_sound {bs rest : List Bool} {n : ℕ}
    (h : readUnary bs=some (n,rest)) : bs=writeUnary n++rest := by
  induction bs generalizing n rest with
  | nil => simp [readUnary] at h
  | cons b bs ih =>
    cases b with
    | false =>
      simp only [readUnary,Option.some.injEq,Prod.mk.injEq] at h
      rcases h with ⟨rfl,rfl⟩
      rfl
    | true =>
      cases hr : readUnary bs with
      | none => simp [readUnary,hr] at h
      | some p =>
        rcases p with ⟨v,tail⟩
        simp only [readUnary,hr,Option.bind_eq_bind,Option.bind_some,Option.pure_def,
          Option.some.injEq,Prod.mk.injEq] at h
        rcases h with ⟨rfl,rfl⟩
        simpa [writeUnary,List.replicate_succ,List.append_assoc] using congrArg (List.cons true) (ih hr)

lemma readInput_sound {d : ℕ} {bs rest : List Bool} {x : Input d}
    (h : readInput d bs=some (x,rest)) : bs=writeInput x++rest := by
  induction d generalizing bs rest with
  | zero =>
    simp only [readInput,Option.some.injEq,Prod.mk.injEq] at h
    rcases h with ⟨rfl,rfl⟩
    rfl
  | succ d ih =>
    cases bs with
    | nil => simp [readInput] at h
    | cons b bs =>
      cases hr : readInput d bs with
      | none => simp [readInput,hr] at h
      | some p =>
        rcases p with ⟨v,tail⟩
        simp only [readInput,hr,Option.bind_eq_bind,Option.bind_some,Option.pure_def,
          Option.some.injEq,Prod.mk.injEq] at h
        rcases h with ⟨rfl,rfl⟩
        simpa [writeInput,List.ofFn_succ] using congrArg (List.cons b) (ih hr)

lemma readBase_sound {d : ℕ} {bs rest : List Bool} {c : Circuit d}
    (h : readBase d bs=some (c,rest)) : bs=writeBase c++rest := by
  cases bs with
  | nil => simp [readBase] at h
  | cons b bs =>
    cases b with
    | true => simp [readBase] at h
    | false =>
      cases bs with
      | nil => simp [readBase] at h
      | cons b bs =>
        cases b with
        | false =>
          simp only [readBase,Option.some.injEq,Prod.mk.injEq] at h
          rcases h with ⟨rfl,rfl⟩
          rfl
        | true =>
          cases hu : readUnary bs with
          | none => simp [readBase,hu] at h
          | some p =>
            rcases p with ⟨n,tail⟩
            cases n with
            | zero => simp [readBase,hu] at h
            | succ n =>
              cases hg : readGates d (n+1) tail with
              | none => simp [readBase,hu,hg] at h
              | some p =>
                rcases p with ⟨g,tail1⟩
                simp only [readBase,hu,Option.bind_eq_bind,Option.bind_some,Nat.succ_ne_zero,
                  ite_false,hg,Option.pure_def,Option.some.injEq,Prod.mk.injEq] at h
                rcases h with ⟨rfl,rfl⟩
                rw [readUnary_sound hu,readGates_sound hg]
                simp only [writeBase,List.append_assoc,List.cons_append,List.nil_append]

/-- Successful streaming parsing consumes exactly one canonical program. -/
theorem readProgramFuel_sound {d fuel : ℕ} {bs rest : List Bool} {p : Program d}
    (h : readProgramFuel d fuel bs=some (p,rest)) : bs=serialize p++rest := by
  induction fuel generalizing bs rest p with
  | zero => simp [readProgramFuel] at h
  | succ fuel ih =>
    cases bs with
    | nil => simp [readProgramFuel] at h
    | cons b bs =>
      cases b with
      | false =>
        cases hb : readBase d (false::bs) with
        | none => simp [readProgramFuel,hb] at h
        | some v =>
          rcases v with ⟨c,tail⟩
          simp only [readProgramFuel,hb,Option.bind_eq_bind,Option.bind_some,Option.pure_def,
            Option.some.injEq,Prod.mk.injEq] at h
          rcases h with ⟨rfl,rfl⟩
          exact readBase_sound hb
      | true =>
        cases hx : readInput d bs with
        | none => simp [readProgramFuel,hx] at h
        | some v =>
          rcases v with ⟨x,tail⟩
          cases tail with
          | nil => simp [readProgramFuel,hx] at h
          | cons y tail =>
            cases hp : readProgramFuel d fuel tail with
            | none => simp [readProgramFuel,hx,hp] at h
            | some v =>
              rcases v with ⟨p0,tail0⟩
              simp only [readProgramFuel,hx,hp,Option.bind_eq_bind,Option.bind_some,Option.pure_def,
                Option.some.injEq,Prod.mk.injEq] at h
              rcases h with ⟨rfl,rfl⟩
              rw [readInput_sound hx,ih hp,serialize_exception]
              simp only [List.cons_append,List.append_assoc]

/-- Decoding and encoding describe exactly the same valid finite strings. -/
theorem deserialize_eq_some_iff {d : ℕ} (bs : List Bool) (p : Program d) :
    deserialize d bs=some p ↔ bs=serialize p := by
  constructor
  · intro h
    unfold deserialize at h
    cases hr : readProgramFuel d bs.length bs with
    | none => simp [hr] at h
    | some v =>
      rcases v with ⟨p0,tail⟩
      simp only [hr,Option.bind_eq_bind,Option.bind_some] at h
      split at h
      · rename_i ht
        subst tail
        simp only [Option.pure_def,Option.some.injEq] at h
        subst p0
        simpa only [List.append_nil] using readProgramFuel_sound hr
      · simp at h
  · rintro rfl
    exact deserialize_serialize p

/-- The public parser rejects every string outside the specified grammar. -/
theorem deserialize_none_iff {d : ℕ} (bs : List Bool) :
    deserialize d bs=none ↔ ∀ p : Program d,bs≠serialize p := by
  rw [Option.eq_none_iff_forall_not_mem]
  simp only [Option.mem_def,deserialize_eq_some_iff]

end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
