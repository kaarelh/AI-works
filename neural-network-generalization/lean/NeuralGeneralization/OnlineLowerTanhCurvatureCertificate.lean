import NeuralGeneralization.OnlineLowerTanhRationalBounds
import NeuralGeneralization.OnlineLowerTanhCurvature

/-! Exact rational arithmetic for the positive optimized curvature coefficient. -/
noncomputable section
set_option maxRecDepth 4096
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.OnlineLowerTanh
open RationalBall

def curvatureExpr (a f0 f1 f2 fpp f1p : ℝ) : ℝ :=
  a*(f1+f0/4)^2/f0^3 - a*(f2+f1/4+f0/32)/f0^2 +
    (f1-a*f1p)^2/(2*a*fpp*f0^2)

def gainBall : RationalBall := ⟨31/25,1/100⟩
def f0Ball : RationalBall := ⟨277/400,17/2000⟩
def f1Ball : RationalBall := ⟨597/2000,19/2000⟩
def f2Ball : RationalBall := ⟨-271/1000,3/250⟩
def fppBall : RationalBall := ⟨-883/1000,19/500⟩
def f1pBall : RationalBall := ⟨-503/1000,11/500⟩
def d1Ball : RationalBall := add f1Ball (div f0Ball (point 4))
def d2Ball : RationalBall := add (add f2Ball (div f1Ball (point 4))) (div f0Ball (point 32))
def curveFirstBall : RationalBall := div (mul gainBall (pow d1Ball 2)) (pow f0Ball 3)
def curveSecondBall : RationalBall := div (mul gainBall d2Ball) (pow f0Ball 2)
def curveThirdNumerator : RationalBall := pow (sub f1Ball (mul gainBall f1pBall)) 2
def curveThirdDenominator : RationalBall := mul (mul (mul (point 2) gainBall) fppBall) (pow f0Ball 2)
def curveThirdBall : RationalBall := div curveThirdNumerator curveThirdDenominator
def optimizedCurveBall : RationalBall := add (sub curveFirstBall curveSecondBall) curveThirdBall

private theorem f0_square_gap : (pow f0Ball 2).radius < |(pow f0Ball 2).center| := by
  norm_num [f0Ball,pow,mul,point]
private theorem f0_cube_gap : (pow f0Ball 3).radius < |(pow f0Ball 3).center| := by
  norm_num [f0Ball,pow,mul,point]
private theorem third_denominator_gap : curveThirdDenominator.radius < |curveThirdDenominator.center| := by
  norm_num [curveThirdDenominator,gainBall,fppBall,f0Ball,pow,mul,point]

theorem curvatureExpr_enclosure (a f0 f1 f2 fpp f1p : ℝ)
    (ha : gainBall.Contains a) (h0 : f0Ball.Contains f0) (h1 : f1Ball.Contains f1)
    (h2 : f2Ball.Contains f2) (hpp : fppBall.Contains fpp) (h1p : f1pBall.Contains f1p) :
    optimizedCurveBall.Contains (curvatureExpr a f0 f1 f2 fpp f1p) := by
  have h4 := contains_point (4 : ℚ)
  have h32 := contains_point (32 : ℚ)
  have hd1 : d1Ball.Contains (f1+f0/4) :=
    contains_add h1 (contains_div h0 h4 (by norm_num [point]))
  have hd2 : d2Ball.Contains (f2+f1/4+f0/32) :=
    contains_add (contains_add h2 (contains_div h1 h4 (by norm_num [point])))
      (contains_div h0 h32 (by norm_num [point]))
  have ht1 : curveFirstBall.Contains (a*(f1+f0/4)^2/f0^3) :=
    contains_div (contains_mul ha (contains_pow hd1 2)) (contains_pow h0 3) f0_cube_gap
  have ht2 : curveSecondBall.Contains (a*(f2+f1/4+f0/32)/f0^2) :=
    contains_div (contains_mul ha hd2) (contains_pow h0 2) f0_square_gap
  have hnum : curveThirdNumerator.Contains ((f1-a*f1p)^2) :=
    contains_pow (contains_sub h1 (contains_mul ha h1p)) 2
  have hden : curveThirdDenominator.Contains (2*a*fpp*f0^2) :=
    contains_mul (contains_mul (contains_mul (contains_point 2) ha) hpp) (contains_pow h0 2)
  exact contains_add (contains_sub ht1 ht2) (contains_div hnum hden third_denominator_gap)

private theorem optimizedCurveBall_lower : (1 : ℚ)/10 < optimizedCurveBall.center-optimizedCurveBall.radius := by
  norm_num [optimizedCurveBall,curveFirstBall,curveSecondBall,curveThirdBall,
    curveThirdNumerator,curveThirdDenominator,d1Ball,d2Ball,
    gainBall,f0Ball,f1Ball,f2Ball,fppBall,f1pBall,point,add,sub,neg,mul,div,inv,pow]

/-- This certificate is a literal rational calculation on the scalar
coefficient formula, with ample slack in all six input intervals. -/
theorem curvatureExpr_gt_tenth (a f0 f1 f2 fpp f1p : ℝ)
    (ha : gainBall.Contains a) (h0 : f0Ball.Contains f0) (h1 : f1Ball.Contains f1)
    (h2 : f2Ball.Contains f2) (hpp : fppBall.Contains fpp) (h1p : f1pBall.Contains f1p) :
    (1 : ℝ)/10 < curvatureExpr a f0 f1 f2 fpp f1p := by
  have he := curvatureExpr_enclosure a f0 f1 f2 fpp f1p ha h0 h1 h2 hpp h1p
  have hl : (1 : ℝ)/10 < (optimizedCurveBall.center : ℝ)-optimizedCurveBall.radius := by
    have h : (((1 : ℚ)/10 : ℚ) : ℝ) <
        ((optimizedCurveBall.center-optimizedCurveBall.radius : ℚ) : ℝ) :=
      Rat.cast_lt.mpr optimizedCurveBall_lower
    simpa only [Rat.cast_div,Rat.cast_one,Rat.cast_ofNat,Rat.cast_sub] using h
  have hh := (abs_le.mp he).1
  linarith

end NeuralGeneralization.OnlineLowerTanh
