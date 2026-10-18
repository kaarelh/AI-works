import NeuralGeneralization.Network
import Mathlib.Data.Fintype.Powerset
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Concrete finite codes for bounded query subsets

A selected subset of at most q inputs is encoded by its finite list,
with none-padding to q slots. One further option value represents abort.
The encoding is injective; no cardinality hypothesis is assumed.
-/

noncomputable section

namespace NeuralGeneralization.ConcreteModel

abbrev BoundedQuerySubset (ι : Type*) (q : ℕ) := {S : Finset ι // S.card ≤ q}

def encodeQuerySubset {ι : Type*} (q : ℕ) (S : BoundedQuerySubset ι q) :
    Fin q → Option ι :=
  fun i => S.val.toList[i.val]?

theorem mem_iff_encodeQuerySubset {ι : Type*} {q : ℕ}
    (S : BoundedQuerySubset ι q) (a : ι) :
    a ∈ S.val ↔ ∃ i : Fin q, encodeQuerySubset q S i = some a := by
  constructor
  · intro ha
    have hlist : a ∈ S.val.toList := Finset.mem_toList.mpr ha
    obtain ⟨i,hi,hget⟩ := List.mem_iff_getElem.mp hlist
    have hiq : i < q := by
      have hlen := Finset.length_toList S.val
      omega
    refine ⟨⟨i,hiq⟩,?_⟩
    exact List.getElem?_eq_some_iff.mpr ⟨hi,hget⟩
  · rintro ⟨i,hi⟩
    apply Finset.mem_toList.mp
    exact List.mem_iff_getElem?.mpr ⟨i.val,hi⟩

theorem encodeQuerySubset_injective {ι : Type*} (q : ℕ) :
    Function.Injective (encodeQuerySubset (ι := ι) q) := by
  intro S T hST
  apply Subtype.ext
  apply Finset.ext
  intro a
  rw [mem_iff_encodeQuerySubset, mem_iff_encodeQuerySubset]
  simp only [hST]

theorem boundedQuerySubset_card_le (ι : Type*) [Fintype ι] (q : ℕ) :
    Fintype.card (BoundedQuerySubset ι q) ≤ (Fintype.card ι + 1)^q := by
  classical
  have h := Fintype.card_le_of_injective _ (encodeQuerySubset_injective (ι := ι) q)
  simpa only [Fintype.card_fun, Fintype.card_fin, Fintype.card_option] using h

abbrev QueryMessage (ι : Type*) (q : ℕ) := Option (BoundedQuerySubset ι q)
abbrev QueryMessageCode (ι : Type*) (q : ℕ) := Option (Fin q → Option ι)

def encodeQueryMessage {ι : Type*} (q : ℕ) :
    QueryMessage ι q → QueryMessageCode ι q :=
  Option.map (encodeQuerySubset q)

theorem encodeQueryMessage_injective {ι : Type*} (q : ℕ) :
    Function.Injective (encodeQueryMessage (ι := ι) q) := by
  intro S T h
  cases S <;> cases T
  · rfl
  · simp [encodeQueryMessage] at h
  · simp [encodeQueryMessage] at h
  · simp only [encodeQueryMessage, Option.map_some, Option.some.injEq] at h
    congr 1
    exact encodeQuerySubset_injective q h

theorem queryMessage_card_le (ι : Type*) [Fintype ι] (q : ℕ) :
    Fintype.card (QueryMessage ι q) ≤ (Fintype.card ι + 1)^q + 1 := by
  classical
  simpa only [QueryMessage, Fintype.card_option] using
    Nat.add_le_add_right (boundedQuerySubset_card_le ι q) 1

theorem cubeQueryMessage_card_le (d q : ℕ) :
    Fintype.card (QueryMessage (Cube d) q) ≤ 2^((d+1)*q+2) := by
  have hbase : 2^d + 1 ≤ 2^(d+1) := by
    have hpow : 1 ≤ 2^d := Nat.one_le_pow d 2 (by decide)
    rw [pow_succ]
    omega
  have hp : (2^d+1)^q ≤ 2^((d+1)*q) := by
    simpa only [← pow_mul] using Nat.pow_le_pow_left hbase q
  have hc := queryMessage_card_le (Cube d) q
  simp only [Cube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin] at hc
  have hone : 1 ≤ 2^((d+1)*q) := Nat.one_le_pow _ 2 (by decide)
  calc
    _ ≤ (2^d+1)^q + 1 := hc
    _ ≤ 2^((d+1)*q) + 1 := Nat.add_le_add_right hp 1
    _ ≤ 2^((d+1)*q+2) := by rw [pow_add]; norm_num

/-- The precise query-plus-abort entropy budget used in the compression chain. -/
theorem cubeQueryMessage_log_card_le (d q : ℕ) :
    Real.log (Fintype.card (QueryMessage (Cube d) q) : ℝ) ≤
      (((d+1)*q+2 : ℕ) : ℝ) * Real.log 2 := by
  have hpos : (0 : ℝ) < Fintype.card (QueryMessage (Cube d) q) := by
    exact_mod_cast Fintype.card_pos_iff.mpr (inferInstance : Nonempty (QueryMessage (Cube d) q))
  have h := Real.log_le_log hpos
    (show (Fintype.card (QueryMessage (Cube d) q) : ℝ) ≤
      ((2^((d+1)*q+2) : ℕ) : ℝ) by exact_mod_cast cubeQueryMessage_card_le d q)
  simpa only [Nat.cast_pow, Nat.cast_ofNat, Real.log_pow] using h

/-- The same budget applies to any enumeration of at most the Boolean inputs,
including the Fin (2^d) interface used by the Gaussian projection modules. -/
theorem queryMessage_log_card_le_of_card_le (ι : Type*) [Fintype ι]
    (d q : ℕ) (hcard : Fintype.card ι ≤ 2^d) :
    Real.log (Fintype.card (QueryMessage ι q) : ℝ) ≤
      (((d+1)*q+2 : ℕ) : ℝ)*Real.log 2 := by
  have hbase : Fintype.card ι + 1 ≤ 2^(d+1) := by
    have hpow : 1 ≤ 2^d := Nat.one_le_pow d 2 (by decide)
    rw [pow_succ]
    omega
  have hp : (Fintype.card ι+1)^q ≤ 2^((d+1)*q) := by
    simpa only [← pow_mul] using Nat.pow_le_pow_left hbase q
  have hc := queryMessage_card_le ι q
  have hone : 1 ≤ 2^((d+1)*q) := Nat.one_le_pow _ 2 (by decide)
  have hbound : Fintype.card (QueryMessage ι q) ≤ 2^((d+1)*q+2) := by
    calc
      _ ≤ (Fintype.card ι+1)^q+1 := hc
      _ ≤ 2^((d+1)*q)+1 := Nat.add_le_add_right hp 1
      _ ≤ _ := by rw [pow_add]; norm_num
  have hpos : (0 : ℝ) < Fintype.card (QueryMessage ι q) := by
    exact_mod_cast Fintype.card_pos_iff.mpr (inferInstance : Nonempty (QueryMessage ι q))
  have h := Real.log_le_log hpos
    (show (Fintype.card (QueryMessage ι q) : ℝ) ≤ ((2^((d+1)*q+2) : ℕ) : ℝ) by
      exact_mod_cast hbound)
  simpa only [Nat.cast_pow,Nat.cast_ofNat,Real.log_pow] using h

end NeuralGeneralization.ConcreteModel
