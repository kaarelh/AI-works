import WeightedAffine

/-! Signed integer coefficients, with no coefficient-normal-form assumption. -/
namespace ConditionalNonpolynomial.AnalyticLookup

def integerTerm {d : ℕ} (p : Fin d × ℤ) : SignedTerm d :=
  ⟨p.1, p.2.toNat, (-p.2).toNat⟩

@[simp] theorem integerTerm_value {d : ℕ} (p : Fin d × ℤ) (x : Input d) :
    (integerTerm p).value x = if x p.1 then p.2 else 0 := by
  simp [integerTerm, SignedTerm.value, Int.toNat_sub_toNat_neg]

@[simp] theorem integerTerm_weight {d : ℕ} (p : Fin d × ℤ) :
    (integerTerm p).positive+(integerTerm p).negative = p.2.natAbs := by
  simp [integerTerm]

def integerComparison {d : ℕ} (ts : List (Fin d × ℤ)) (cutoff : ℤ) : ThresholdCircuit d :=
  signedComparison (ts.map integerTerm) cutoff

@[simp] theorem integerComparison_eval {d : ℕ} (ts : List (Fin d × ℤ))
    (cutoff : ℤ) (x : Input d) :
    (integerComparison ts cutoff).eval x =
      decide (cutoff ≤ (ts.map (fun t => if x t.1 then t.2 else 0)).sum) := by
  simp [integerComparison, List.map_map, Function.comp_def]

theorem integerComparison_depth {d : ℕ} (ts : List (Fin d × ℤ)) (cutoff : ℤ) :
    (integerComparison ts cutoff).depth ≤ 2 := signedComparison_depth _ _

theorem integerComparison_size {d : ℕ} (ts : List (Fin d × ℤ)) (cutoff : ℤ) :
    (integerComparison ts cutoff).size ≤ 4*(ts.map (fun t => t.2.natAbs)).sum+1 := by
  simpa [integerComparison, List.map_map, Function.comp_def] using
    signedComparison_size (ts.map integerTerm) cutoff

#print axioms integerComparison_eval
#print axioms integerComparison_depth
#print axioms integerComparison_size
end ConditionalNonpolynomial.AnalyticLookup
