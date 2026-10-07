import InfLearn.Prelude
#check @Fintype.exists_ne_map_eq_of_card_lt
#check @List.ext_getElem
#check @List.getElem_append_left
#check @List.getElem_append_right
#check @List.length_append
#check @MonotoneOn
#check @List.getD
example (q : ℕ) : Fintype.card (Fin q → Bool) = 2 ^ q := by simp
