import InfLearn.Prelude
open Finset
#check @Finset.sum_fiberwise
#check @Finset.card_eq_sum_card_fiberwise
#check @Real.log_le_sub_one_of_pos
#check @ENNReal.ofReal_sum_of_nonneg
#check @ENNReal.ofReal_mul
#check @Finset.exists_mem_eq_sup'
#check @Finset.card_le_card_of_injOn
#check @Finset.sum_ite_mem
#check @mul_div_cancel₀
#check @Real.log_inv
#check @ENNReal.sum_eq_top
#check @Finset.single_le_sum
#check @Real.add_pow_le_pow_mul_pow_of_sq_le_sq
example (a b : ℝ) (ha : a ≠ 0) : a * (b / a - 1) = b - a := by field_simp
example : (({![0,0], ![0,1], ![1,0], ![2,0]} : Finset (Fin 2 → Fin 3)).filter (fun f => f 1 = 1)) = {![0,1]} := by decide
