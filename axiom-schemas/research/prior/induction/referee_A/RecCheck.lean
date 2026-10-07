#check @Nat.rec
#check @Nat.recAux
theorem t2 (m n : Nat) : m + n = n + m := by
  induction n with
  | zero => simp
  | succ k ih => omega
set_option pp.explicit true in
#print t2
-- motive with a parameter m: does Lean capture anything?  (it cannot: de Bruijn / locally nameless)
example (n : Nat) (P : Nat → Prop) (h0 : P 0) (hs : ∀ k, P k → P (k+1)) : P n := Nat.rec (motive := fun k => P k) h0 hs n
