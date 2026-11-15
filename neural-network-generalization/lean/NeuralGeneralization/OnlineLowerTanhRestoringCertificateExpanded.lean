import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringPolynomial
set_option Elab.async false
set_option maxRecDepth 10000
set_option maxHeartbeats 0
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

private lemma restoringChebyshev0 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 0).eval x = 1 := by
  simp

private lemma restoringChebyshev1 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 1).eval x = x := by
  simp

private lemma restoringChebyshev2 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 2).eval x = 2 * x^2 - 1 := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (0 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev1, restoringChebyshev0] at h
  rw [h]
  ring

private lemma restoringChebyshev3 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 3).eval x = 4 * x^3 - 3 * x := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (1 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev2, restoringChebyshev1] at h
  rw [h]
  ring

private lemma restoringChebyshev4 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 4).eval x = 8 * x^4 - 8 * x^2 + 1 := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (2 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev3, restoringChebyshev2] at h
  rw [h]
  ring

private lemma restoringChebyshev5 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 5).eval x = 16 * x^5 - 20 * x^3 + 5 * x := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (3 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev4, restoringChebyshev3] at h
  rw [h]
  ring

private lemma restoringChebyshev6 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 6).eval x = 32 * x^6 - 48 * x^4 + 18 * x^2 - 1 := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (4 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev5, restoringChebyshev4] at h
  rw [h]
  ring

private lemma restoringChebyshev7 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 7).eval x = 64 * x^7 - 112 * x^5 + 56 * x^3 - 7 * x := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (5 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev6, restoringChebyshev5] at h
  rw [h]
  ring

private lemma restoringChebyshev8 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 8).eval x = 128 * x^8 - 256 * x^6 + 160 * x^4 - 32 * x^2 + 1 := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (6 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev7, restoringChebyshev6] at h
  rw [h]
  ring

private lemma restoringChebyshev9 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 9).eval x = 256 * x^9 - 576 * x^7 + 432 * x^5 - 120 * x^3 + 9 * x := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (7 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev8, restoringChebyshev7] at h
  rw [h]
  ring

private lemma restoringChebyshev10 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 10).eval x = 512 * x^10 - 1280 * x^8 + 1120 * x^6 - 400 * x^4 + 50 * x^2 - 1 := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (8 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev9, restoringChebyshev8] at h
  rw [h]
  ring

private lemma restoringChebyshev11 (x : ℝ) :
    (Polynomial.Chebyshev.T ℝ 11).eval x = 1024 * x^11 - 2816 * x^9 + 2816 * x^7 - 1232 * x^5 + 220 * x^3 - 11 * x := by
  have h := congrArg (Polynomial.eval x) (Polynomial.Chebyshev.T_add_two ℝ (9 : ℤ))
  norm_num [Polynomial.eval_sub, Polynomial.eval_mul, restoringChebyshev10, restoringChebyshev9] at h
  rw [h]
  ring

private lemma restoringRatioPolynomial0 (q : ℝ) :
    restoringRatioPolynomial q 0 = 1 := by
  norm_num [restoringRatioPolynomial, Finset.sum_range_succ]

private lemma restoringRatioPolynomial1 (q : ℝ) :
    restoringRatioPolynomial q 1 = (1 - q) * (q + q^4 + q^7 + q^10 + q^13) := by
  norm_num [restoringRatioPolynomial, Finset.sum_range_succ]

private lemma restoringRatioPolynomial2 (q : ℝ) :
    restoringRatioPolynomial q 2 = (1 - q) * (q^2 + q^7 + q^12) := by
  norm_num [restoringRatioPolynomial, Finset.sum_range_succ]

private lemma restoringRatioPolynomial3 (q : ℝ) :
    restoringRatioPolynomial q 3 = (1 - q) * (q^3 + q^10) := by
  norm_num [restoringRatioPolynomial, Finset.sum_range_succ]

private lemma restoringRatioPolynomial4 (q : ℝ) :
    restoringRatioPolynomial q 4 = (1 - q) * (q^4 + q^13) := by
  norm_num [restoringRatioPolynomial, Finset.sum_range_succ]

private lemma restoringRatioPolynomial5 (q : ℝ) :
    restoringRatioPolynomial q 5 = (1 - q) * (q^5) := by
  norm_num [restoringRatioPolynomial, Finset.sum_range_succ]

def restoringPolynomialExpanded (q x : ℝ) : ℝ :=
    ((1600128/625)) * q^30 * x^9 +
    ((-3600288/625)) * q^30 * x^7 +
    ((2700216/625)) * q^30 * x^5 +
    ((-775062/625)) * q^30 * x^3 +
    ((75006/625)) * q^30 * x +
    ((-1600128/625)) * q^29 * x^9 +
    ((3600288/625)) * q^29 * x^7 +
    ((-2600208/625)) * q^29 * x^5 +
    ((650052/625)) * q^29 * x^3 +
    ((-87507/1250)) * q^29 * x +
    ((-7499/1250)) * q^29 +
    ((-100008/625)) * q^28 * x^5 +
    ((25002/125)) * q^28 * x^3 +
    ((-12501/250)) * q^28 * x +
    ((7499/1250)) * q^28 +
    ((6400512/625)) * q^27 * x^9 +
    ((-14801184/625)) * q^27 * x^7 +
    ((2300184/125)) * q^27 * x^5 +
    ((-3475278/625)) * q^27 * x^3 +
    ((362529/625)) * q^27 * x +
    ((7499/625)) * q^27 +
    ((-3200256/625)) * q^26 * x^9 +
    ((7600608/625)) * q^26 * x^7 +
    ((-5700456/625)) * q^26 * x^5 +
    ((1425114/625)) * q^26 * x^3 +
    ((-87507/625)) * q^26 * x +
    ((-22497/625)) * q^26 +
    ((-3200256/625)) * q^25 * x^9 +
    ((7200576/625)) * q^25 * x^7 +
    ((-5600448/625)) * q^25 * x^5 +
    ((1800144/625)) * q^25 * x^3 +
    ((-212517/625)) * q^25 * x +
    ((7499/625)) * q^25 +
    ((9600768/625)) * q^24 * x^9 +
    ((-23201856/625)) * q^24 * x^7 +
    ((18901512/625)) * q^24 * x^5 +
    ((-6050484/625)) * q^24 * x^3 +
    ((137511/125)) * q^24 * x +
    ((7499/125)) * q^24 +
    ((800064/625)) * q^23 * x^7 +
    ((-900072/625)) * q^23 * x^5 +
    ((150012/625)) * q^23 * x^3 +
    ((12501/625)) * q^23 * x +
    ((-7499/125)) * q^23 +
    ((-6400512/625)) * q^22 * x^11 +
    ((10400832/625)) * q^22 * x^9 +
    ((-600048/625)) * q^22 * x^7 +
    ((-5850468/625)) * q^22 * x^5 +
    ((2862729/625)) * q^22 * x^3 +
    ((-787563/1250)) * q^22 * x +
    ((-22497/1250)) * q^22 +
    ((6400512/625)) * q^21 * x^11 +
    ((-2400192/125)) * q^21 * x^9 +
    ((2600208/625)) * q^21 * x^7 +
    ((5900472/625)) * q^21 * x^5 +
    ((-725058/125)) * q^21 * x^3 +
    ((2512701/2500)) * q^21 * x +
    ((232469/2500)) * q^21 +
    ((1600128/625)) * q^20 * x^9 +
    ((-800064/125)) * q^20 * x^7 +
    ((3450276/625)) * q^20 * x^5 +
    ((-1137591/625)) * q^20 * x^3 +
    ((387531/2500)) * q^20 * x +
    ((-22497/2500)) * q^20 +
    ((-25602048/625)) * q^19 * x^11 +
    ((65605248/625)) * q^19 * x^9 +
    ((-57404592/625)) * q^19 * x^7 +
    ((18951516/625)) * q^19 * x^5 +
    ((-1212597/625)) * q^19 * x^3 +
    ((-112509/250)) * q^19 * x +
    ((-67491/1250)) * q^19 +
    ((12801024/625)) * q^18 * x^11 +
    ((-31202496/625)) * q^18 * x^9 +
    ((25202016/625)) * q^18 * x^7 +
    ((-6700536/625)) * q^18 * x^5 +
    ((-550044/625)) * q^18 * x^3 +
    ((400032/625)) * q^18 * x +
    ((29996/625)) * q^18 +
    ((12801024/625)) * q^17 * x^11 +
    ((-37603008/625)) * q^17 * x^9 +
    ((38203056/625)) * q^17 * x^7 +
    ((-15401232/625)) * q^17 * x^5 +
    ((1975158/625)) * q^17 * x^3 +
    ((-12501/500)) * q^17 * x +
    ((97487/2500)) * q^17 +
    ((-38403072/625)) * q^16 * x^11 +
    ((101608128/625)) * q^16 * x^9 +
    ((-94607568/625)) * q^16 * x^7 +
    ((35952876/625)) * q^16 * x^5 +
    ((-175014/25)) * q^16 * x^3 +
    ((-112509/500)) * q^16 * x +
    ((-82489/2500)) * q^16 +
    ((1600128/125)) * q^15 * x^9 +
    ((-16601328/625)) * q^15 * x^7 +
    ((11050884/625)) * q^15 * x^5 +
    ((-2775222/625)) * q^15 * x^3 +
    ((1262601/2500)) * q^15 * x +
    ((22497/2500)) * q^15 +
    ((28802304/625)) * q^14 * x^11 +
    ((-92866392/625)) * q^14 * x^9 +
    ((107341254/625)) * q^14 * x^7 +
    ((-106507521/1250)) * q^14 * x^5 +
    ((83695293/5000)) * q^14 * x^3 +
    ((-4417551/5000)) * q^14 * x +
    ((52493/2500)) * q^14 +
    ((-3200256/125)) * q^13 * x^11 +
    ((49662936/625)) * q^13 * x^9 +
    ((-11307438/125)) * q^13 * x^7 +
    ((28458047/625)) * q^13 * x^5 +
    ((-22777471/2500)) * q^13 * x^3 +
    ((986377/4000)) * q^13 * x +
    ((-247467/20000)) * q^13 +
    ((-12801024/625)) * q^12 * x^11 +
    ((39203136/625)) * q^12 * x^9 +
    ((-8400672/125)) * q^12 * x^7 +
    ((36790403/1250)) * q^12 * x^5 +
    ((-23739199/5000)) * q^12 * x^3 +
    ((5337727/20000)) * q^12 * x +
    ((427443/20000)) * q^12 +
    ((19201536/625)) * q^11 * x^11 +
    ((-49603968/625)) * q^11 * x^9 +
    ((46738582/625)) * q^11 * x^7 +
    ((-8035033/250)) * q^11 * x^5 +
    ((6542801/1000)) * q^11 * x^3 +
    ((-1027523/2000)) * q^11 * x +
    ((7499/400)) * q^11 +
    ((9600768/625)) * q^10 * x^11 +
    ((-31202496/625)) * q^10 * x^9 +
    ((34467914/625)) * q^10 * x^7 +
    ((-5866079/250)) * q^10 * x^5 +
    ((2957959/1000)) * q^10 * x^3 +
    ((-1312901/10000)) * q^10 * x +
    ((-7499/2000)) * q^10 +
    ((-3200256/625)) * q^9 * x^11 +
    ((6400512/625)) * q^9 * x^9 +
    ((-2200176/625)) * q^9 * x^7 +
    ((-2200176/625)) * q^9 * x^5 +
    ((1362609/625)) * q^9 * x^3 +
    ((-37503/125)) * q^9 * x +
    ((14998/625)) * q^9 +
    ((3200256/625)) * q^8 * x^11 +
    ((-1600128/125)) * q^8 * x^9 +
    ((7600608/625)) * q^8 * x^7 +
    ((-8288123/1250)) * q^8 * x^5 +
    ((6202889/2500)) * q^8 * x^3 +
    ((-245012/625)) * q^8 * x +
    ((67491/2500)) * q^8 +
    ((6400512/625)) * q^7 * x^11 +
    ((-18401472/625)) * q^7 * x^9 +
    ((19201536/625)) * q^7 * x^7 +
    ((-17213917/1250)) * q^7 * x^5 +
    ((1219619/500)) * q^7 * x^3 +
    ((-482569/2500)) * q^7 * x +
    ((7499/625)) * q^7 +
    ((80240224/625)) * q^6 * x^11 +
    ((-222260744/625)) * q^6 * x^9 +
    ((44892184/125)) * q^6 * x^7 +
    ((-199078519/1250)) * q^6 * x^5 +
    ((145313477/5000)) * q^6 * x^3 +
    ((-32282953/20000)) * q^6 * x +
    ((367451/20000)) * q^6 +
    ((-77039968/625)) * q^5 * x^11 +
    ((198199856/625)) * q^5 * x^9 +
    ((-180724754/625)) * q^5 * x^7 +
    ((68887307/625)) * q^5 * x^5 +
    ((-9714934/625)) * q^5 * x^3 +
    ((8112229/20000)) * q^5 * x +
    ((352453/20000)) * q^5 +
    ((12859992/625)) * q^4 * x^9 +
    ((-26799968/625)) * q^4 * x^7 +
    ((17864954/625)) * q^4 * x^5 +
    ((-32347283/5000)) * q^4 * x^3 +
    ((5897311/20000)) * q^4 * x +
    ((7499/800)) * q^4 +
    ((-1934998/625)) * q^3 * x^7 +
    ((3092493/625)) * q^3 * x^5 +
    ((-2081487/1000)) * q^3 * x^3 +
    ((1417439/10000)) * q^3 * x +
    ((82489/10000)) * q^3 +
    ((487499/1250)) * q^2 * x^5 +
    ((-542497/1250)) * q^2 * x^3 +
    ((26699/400)) * q^2 * x +
    ((67491/10000)) * q^2 +
    ((-167499/5000)) * q * x^3 +
    ((402489/20000)) * q * x +
    ((52493/20000)) * q +
    ((7499/20000)) * x +
    ((7497/20000))

theorem restoringPolynomial_eq_expanded (q x : ℝ) :
    restoringPolynomial q x - 1/10000 = restoringPolynomialExpanded q x := by
  norm_num [restoringPolynomial, restoringMu, restoringAmplitude, Finset.sum_range_succ,
    restoringRatioPolynomial0, restoringRatioPolynomial1, restoringRatioPolynomial2, restoringRatioPolynomial3, restoringRatioPolynomial4, restoringRatioPolynomial5,
    restoringChebyshev1, restoringChebyshev3, restoringChebyshev5, restoringChebyshev7, restoringChebyshev9, restoringChebyshev11]
  unfold restoringPolynomialExpanded
  ring

end NeuralGeneralization.OnlineLowerTanh
