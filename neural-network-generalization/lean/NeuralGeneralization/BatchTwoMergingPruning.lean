import NeuralGeneralization.BatchTwoMergingCircuit

/-!
# Same-depth ancestor unfolding of layered Boolean circuits

A single-output circuit of r+1 hidden Boolean layers needs at most 2^r
ancestor positions per layer, plus its constant rail. The construction uses
binary route addresses and preserves the actual circuit evaluation.
-/
namespace NeuralGeneralization.BatchTwoMerging
noncomputable section
open Classical
open ConcreteModel

namespace NorGate

def child {I : Type*} (g : NorGate I) (b : Bool) : I := match g with
  | .copy i => i
  | .negate i => i
  | .nor i j => if b then j else i

def rewire {I J : Type*} (g : NorGate I) (a b : J) : NorGate J := match g with
  | .copy _ => .copy a
  | .negate _ => .negate a
  | .nor _ _ => .nor a b

theorem eval_rewire {I J : Type*} (g : NorGate I) (a b : J)
    (h : J → Bool) (v : I → Bool)
    (ha : h a = v (g.child false)) (hb : h b = v (g.child true)) :
    (g.rewire a b).eval h = g.eval v := by
  cases g <;> simp_all [rewire, eval, child]

end NorGate
namespace LayeredNorCircuit
variable {d C r : ℕ}

/-- Follow k binary branch choices backwards from the single output. -/
def ancestor (B : LayeredNorCircuit d C r) : ℕ → (Fin r → Bool) → Fin C
  | 0, _ => B.output
  | k+1, route => if hk : k < r then
      (B.internal ⟨r-1-k, by omega⟩ (B.ancestor k route)).child (route ⟨k,hk⟩)
    else B.constant

theorem ancestor_congr (B : LayeredNorCircuit d C r) (k : ℕ)
    (u v : Fin r → Bool) (huv : ∀ i : Fin r, i.val < k → u i = v i) :
    B.ancestor k u = B.ancestor k v := by
  induction k with
  | zero => rfl
  | succ k ih =>
      simp only [ancestor]
      split_ifs with hk
      · rw [ih (fun i hi => huv i (by omega)), huv ⟨k,hk⟩ (by simp)]
      · rfl

theorem ancestor_update (B : LayeredNorCircuit d C r) (k : ℕ) (hk : k < r)
    (route : Fin r → Bool) (b : Bool) :
    B.ancestor k (Function.update route ⟨k,hk⟩ b) = B.ancestor k route := by
  apply B.ancestor_congr
  intro i hi
  exact Function.update_of_ne (by intro he; have := congrArg Fin.val he; simp at this; omega) _ _

theorem ancestor_update_succ (B : LayeredNorCircuit d C r) (k : ℕ) (hk : k < r)
    (route : Fin r → Bool) (b : Bool) :
    B.ancestor (k+1) (Function.update route ⟨k,hk⟩ b) =
      (B.internal ⟨r-1-k, by omega⟩ (B.ancestor k route)).child b := by
  simp only [ancestor, dif_pos hk, Function.update_self]
  rw [B.ancestor_update k hk route b]

/-- One backwards step, indexed by the original forward internal-layer number. -/
theorem ancestor_child (B : LayeredNorCircuit d C r) (s : Fin r)
    (route : Fin r → Bool) (b : Bool) :
    B.ancestor (r-s.val) (Function.update route ⟨r-(s.val+1), by omega⟩ b) =
      (B.internal s (B.ancestor (r-(s.val+1)) route)).child b := by
  have hk : r-(s.val+1) < r := by omega
  have he : r-s.val = (r-(s.val+1))+1 := by omega
  rw [he, B.ancestor_update_succ _ hk]
  congr 2
  apply Fin.ext
  simp only
  omega

abbrev PruningIndex (r : ℕ) := Option (Fin r → Bool)

def pruningWidth (r : ℕ) : ℕ := Fintype.card (PruningIndex r)

def pruningEquiv (r : ℕ) : Fin (pruningWidth r) ≃ PruningIndex r :=
  (Fintype.equivFin (PruningIndex r)).symm

@[simp] theorem pruningWidth_eq (r : ℕ) : pruningWidth r = 2^r+1 := by
  simp [pruningWidth, PruningIndex]

/-- Full binary route unfolding; unused positions are harmless duplicates. -/
def unfoldAncestors (B : LayeredNorCircuit d C r) : LayeredNorCircuit d (pruningWidth r) r where
  constant := (pruningEquiv r).symm none
  first i := match pruningEquiv r i with
    | none => .copy 0
    | some route => B.first (B.ancestor r route)
  internal s i := match pruningEquiv r i with
    | none => .copy ((pruningEquiv r).symm none)
    | some route => (B.internal s (B.ancestor (r-(s.val+1)) route)).rewire
        ((pruningEquiv r).symm (some (Function.update route ⟨r-(s.val+1), by omega⟩ false)))
        ((pruningEquiv r).symm (some (Function.update route ⟨r-(s.val+1), by omega⟩ true)))
  output := (pruningEquiv r).symm (some (fun _ => false))
  first_constant := by simp
  internal_constant := by intro s; simp

/-- States after t of the r internal layers. -/
def bitsAfter (B : LayeredNorCircuit d C r) (x : Cube d) (t : ℕ) : Fin C → Bool :=
  ((List.finRange r).take t).foldl B.stepBits (B.firstBits x)

@[simp] theorem bitsAfter_zero (B : LayeredNorCircuit d C r) (x : Cube d) :
    B.bitsAfter x 0 = B.firstBits x := by simp [bitsAfter]

theorem bitsAfter_succ (B : LayeredNorCircuit d C r) (x : Cube d) (t : ℕ) (ht : t < r) :
    B.bitsAfter x (t+1) = B.stepBits (B.bitsAfter x t) ⟨t,ht⟩ := by
  unfold bitsAfter
  rw [List.take_succ_eq_append_getElem (by simpa using ht), List.foldl_append]
  simp only [List.foldl_cons, List.foldl_nil, List.getElem_finRange]
  rfl

@[simp] theorem bitsAfter_all (B : LayeredNorCircuit d C r) (x : Cube d) :
    B.bitsAfter x r = B.finalBits x := by
  have ht : (List.finRange r).take r = List.finRange r := by
    simpa only [List.length_finRange] using (List.take_length (l := List.finRange r))
  simp only [bitsAfter, finalBits, ht]

/-- At stage t a route position represents its ancestor r-t steps before output. -/
def AncestorSimulation (B : LayeredNorCircuit d C r) (t : ℕ)
    (newState : Fin (pruningWidth r) → Bool) (oldState : Fin C → Bool) : Prop :=
  ∀ i, newState i = match pruningEquiv r i with
    | none => true
    | some route => oldState (B.ancestor (r-t) route)

theorem first_ancestorSimulation (B : LayeredNorCircuit d C r) (x : Cube d) :
    B.AncestorSimulation 0 (B.unfoldAncestors.firstBits x) (B.firstBits x) := by
  intro i
  unfold firstBits unfoldAncestors
  cases he : pruningEquiv r i <;> simp [he, NorGate.eval]

theorem step_ancestorSimulation (B : LayeredNorCircuit d C r) (s : Fin r)
    (newState : Fin (pruningWidth r) → Bool) (oldState : Fin C → Bool)
    (hsim : B.AncestorSimulation s.val newState oldState) :
    B.AncestorSimulation (s.val+1)
      (B.unfoldAncestors.stepBits newState s) (B.stepBits oldState s) := by
  intro i
  change (B.unfoldAncestors.internal s i).eval newState = _
  cases he : pruningEquiv r i with
  | none =>
      simp only [unfoldAncestors, he, NorGate.eval]
      have h := hsim ((pruningEquiv r).symm none)
      simpa only [Equiv.apply_symm_apply] using h
  | some route =>
      simp only [unfoldAncestors, he, stepBits]
      apply NorGate.eval_rewire
      · have h := hsim ((pruningEquiv r).symm
          (some (Function.update route ⟨r-(s.val+1), by omega⟩ false)))
        simpa only [Equiv.apply_symm_apply, ancestor_child] using h
      · have h := hsim ((pruningEquiv r).symm
          (some (Function.update route ⟨r-(s.val+1), by omega⟩ true)))
        simpa only [Equiv.apply_symm_apply, ancestor_child] using h

theorem bitsAfter_ancestorSimulation (B : LayeredNorCircuit d C r) (x : Cube d)
    (t : ℕ) (ht : t ≤ r) :
    B.AncestorSimulation t (B.unfoldAncestors.bitsAfter x t) (B.bitsAfter x t) := by
  induction t with
  | zero => simpa only [bitsAfter_zero] using B.first_ancestorSimulation x
  | succ t ih =>
      have htr : t < r := by omega
      rw [B.unfoldAncestors.bitsAfter_succ x t htr, B.bitsAfter_succ x t htr]
      exact B.step_ancestorSimulation ⟨t,htr⟩ _ _ (ih (by omega))

@[simp] theorem unfoldAncestors_computes (B : LayeredNorCircuit d C r) :
    B.unfoldAncestors.computes = B.computes := by
  funext x
  have h := B.bitsAfter_ancestorSimulation x r le_rfl
  specialize h ((pruningEquiv r).symm (some (fun _ => false)))
  change B.unfoldAncestors.finalBits x ((pruningEquiv r).symm (some (fun _ => false))) = B.finalBits x B.output
  simpa only [bitsAfter_all, Equiv.apply_symm_apply, Nat.sub_self, ancestor] using h

/-- Pruning never increases the original width and needs at most one binary
ancestor tree plus the constant rail; the number of layers is unchanged. -/
theorem exists_same_depth_pruning (B : LayeredNorCircuit d C r) :
    ∃ C' : ℕ, ∃ B' : LayeredNorCircuit d C' r,
      0 < C' ∧ C' ≤ C ∧ C' ≤ 2^r+1 ∧ B'.computes = B.computes := by
  by_cases hC : C ≤ 2^r+1
  · exact ⟨C, B, Nat.pos_of_ne_zero (by intro hz; have := B.constant.isLt; omega),
      le_rfl, hC, rfl⟩
  · refine ⟨pruningWidth r, B.unfoldAncestors, ?_, ?_, ?_, B.unfoldAncestors_computes⟩
    · rw [pruningWidth_eq]; exact Nat.succ_pos _
    · rw [pruningWidth_eq]; omega
    · rw [pruningWidth_eq]

end LayeredNorCircuit
end
end NeuralGeneralization.BatchTwoMerging
