import ScalarLookup

/-! Exact bounded-integer affine comparisons using actual threshold circuits.
Repeated wires convert natural coefficients into unweighted threshold fan-in.
Complemented literals provide the usual normal form for signed coefficients. -/

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup

structure WeightedLiteral (d : ℕ) where
  input : Fin d
  polarity : Bool
  weight : ℕ

def WeightedLiteral.value {d : ℕ} (t : WeightedLiteral d) (x : Input d) : ℕ :=
  if x t.input = t.polarity then t.weight else 0

def WeightedLiteral.copies {d : ℕ} (t : WeightedLiteral d) : List (ThresholdCircuit d) :=
  List.replicate t.weight (literal t.input t.polarity)

def weightedComparison {d : ℕ} (ts : List (WeightedLiteral d)) (cutoff : ℕ) :
    ThresholdCircuit d :=
  thresholdList (ts.flatMap WeightedLiteral.copies) cutoff

lemma weightedCopies_count {d : ℕ} (ts : List (WeightedLiteral d)) (x : Input d) :
    ((ts.flatMap WeightedLiteral.copies).map (fun c => c.eval x)).count true =
      (ts.map (fun t => t.value x)).sum := by
  induction ts with
  | nil => simp
  | cons t ts ih =>
    simp [WeightedLiteral.copies, List.map_append, List.count_append, ih,
      List.count_replicate, WeightedLiteral.value]

@[simp] theorem weightedComparison_eval {d : ℕ} (ts : List (WeightedLiteral d))
    (cutoff : ℕ) (x : Input d) :
    (weightedComparison ts cutoff).eval x =
      decide (cutoff ≤ (ts.map (fun t => t.value x)).sum) := by
  simp [weightedComparison, weightedCopies_count]

theorem weightedComparison_depth {d : ℕ} (ts : List (WeightedLiteral d)) (cutoff : ℕ) :
    (weightedComparison ts cutoff).depth ≤ 2 := by
  apply thresholdList_depth _ _ 1
  intro c hc
  obtain ⟨t,ht,hc⟩ := List.mem_flatMap.mp hc
  have heq := (List.mem_replicate.mp hc).2
  subst c
  exact literal_depth _ _

theorem weightedCopies_length {d : ℕ} (ts : List (WeightedLiteral d)) :
    (ts.flatMap WeightedLiteral.copies).length = (ts.map WeightedLiteral.weight).sum := by
  induction ts with
  | nil => simp
  | cons t ts ih => simp [WeightedLiteral.copies, ih]

theorem weightedComparison_size {d : ℕ} (ts : List (WeightedLiteral d)) (cutoff : ℕ) :
    (weightedComparison ts cutoff).size ≤ 4*(ts.map WeightedLiteral.weight).sum+1 := by
  rw [weightedComparison, thresholdList_size]
  have hs := sum_sizes_le (ts.flatMap WeightedLiteral.copies) 3 (by
    intro c hc
    obtain ⟨t,ht,hc⟩ := List.mem_flatMap.mp hc
    have heq := (List.mem_replicate.mp hc).2
    subst c
    exact literal_size _ _)
  rw [weightedCopies_length] at hs ⊢
  omega

/-- An integer coefficient is represented by a difference of natural weights. -/
structure SignedTerm (d : ℕ) where
  input : Fin d
  positive : ℕ
  negative : ℕ

def SignedTerm.value {d : ℕ} (t : SignedTerm d) (x : Input d) : ℤ :=
  if x t.input then (t.positive : ℤ)-t.negative else 0

def SignedTerm.literals {d : ℕ} (t : SignedTerm d) : List (WeightedLiteral d) :=
  [⟨t.input, true, t.positive⟩, ⟨t.input, false, t.negative⟩]

def signedComparison {d : ℕ} (ts : List (SignedTerm d)) (cutoff : ℤ) :
    ThresholdCircuit d :=
  weightedComparison (ts.flatMap SignedTerm.literals)
    (cutoff + ((ts.map SignedTerm.negative).sum : ℕ)).toNat

lemma signed_offset_identity {d : ℕ} (ts : List (SignedTerm d)) (x : Input d) :
    (↑(((ts.flatMap SignedTerm.literals).map (fun t => t.value x)).sum : ℕ) : ℤ) =
      (ts.map (fun t => t.value x)).sum + ((ts.map SignedTerm.negative).sum : ℕ) := by
  induction ts with
  | nil => simp
  | cons t ts ih =>
    simp only [List.flatMap_cons, List.map_append, List.sum_append, List.map_cons,
      List.sum_cons, Nat.cast_add, ih]
    cases hx : x t.input <;>
      simp [SignedTerm.literals, WeightedLiteral.value, SignedTerm.value, hx] <;> omega

@[simp] theorem signedComparison_eval {d : ℕ} (ts : List (SignedTerm d))
    (cutoff : ℤ) (x : Input d) :
    (signedComparison ts cutoff).eval x =
      decide (cutoff ≤ (ts.map (fun t => t.value x)).sum) := by
  rw [signedComparison, weightedComparison_eval]
  congr 1
  rw [Int.toNat_le, signed_offset_identity]
  apply propext
  omega

theorem signedComparison_depth {d : ℕ} (ts : List (SignedTerm d)) (cutoff : ℤ) :
    (signedComparison ts cutoff).depth ≤ 2 := weightedComparison_depth _ _

lemma signed_weights_sum {d : ℕ} (ts : List (SignedTerm d)) :
    ((ts.flatMap SignedTerm.literals).map WeightedLiteral.weight).sum =
      (ts.map (fun t => t.positive + t.negative)).sum := by
  induction ts with
  | nil => simp
  | cons t ts ih => simp [SignedTerm.literals, ih, Nat.add_assoc]

theorem signedComparison_size {d : ℕ} (ts : List (SignedTerm d)) (cutoff : ℤ) :
    (signedComparison ts cutoff).size ≤
      4*(ts.map (fun t => t.positive+t.negative)).sum+1 := by
  simpa only [signedComparison, signed_weights_sum] using
    weightedComparison_size (ts.flatMap SignedTerm.literals)
      (cutoff + ((ts.map SignedTerm.negative).sum : ℕ)).toNat

#print axioms signedComparison_eval
#print axioms signedComparison_depth
#print axioms signedComparison_size
#print axioms weightedComparison_eval
#print axioms weightedComparison_depth
#print axioms weightedComparison_size

end ConditionalNonpolynomial.AnalyticLookup
