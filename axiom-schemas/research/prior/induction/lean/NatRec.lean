#check @Nat.rec
set_option pp.all true in
#print axioms Nat.rec
theorem t (n : Nat) : n + 0 = n := by
  induction n with
  | zero => rfl
  | succ k ih => rfl
set_option pp.explicit true in
#print t
