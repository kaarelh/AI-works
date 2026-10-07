import InfLearn.RateThreshold
open InfLearn RateThreshold Rule
example : cost valid = 50 := by
  simp [cost, valid, Finset.sum_pair, len]; norm_num
example : resid valid = 2 / 5 := by
  simp [resid, valid, univ_eq, Finset.sum_insert, Finset.sum_pair, red, freq, gain]; norm_num
#check @add_div
#check @div_add_div_same
