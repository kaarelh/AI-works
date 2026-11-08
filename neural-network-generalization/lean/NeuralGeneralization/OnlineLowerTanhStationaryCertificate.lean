import NeuralGeneralization.OnlineLowerTanhSeriesCertificate

/-! Exact endpoint exponential and stationary-sign certificates. -/
noncomputable section
set_option maxRecDepth 4096
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh
open RationalBall

def expTaylorBall (x : ℚ) (n : ℕ) : RationalBall :=
  ⟨∑ k ∈ Finset.range n, x^k/(k.factorial : ℚ),
    |x|^n*((n+1 : ℕ) : ℚ)/((n.factorial : ℚ)*n)⟩

theorem expTaylorBall_contains (x : ℚ) (hx : |x| ≤ 1) (n : ℕ) (hn : 0 < n) :
    (expTaylorBall x n).Contains (Real.exp (x : ℝ)) := by
  have hx' : |(x : ℝ)| ≤ 1 := by exact_mod_cast hx
  have h := Real.exp_bound (n := n) hx' hn
  simp only [Nat.cast_succ] at h
  unfold Contains expTaylorBall
  push_cast
  convert h using 1 <;> try rfl
  ring

def lowDecayBall : RationalBall := ⟨1709/20000,1/20000⟩
def highDecayBall : RationalBall := ⟨1641/20000,1/20000⟩

theorem lowDecayBall_contains : lowDecayBall.Contains (Real.exp (-2*(123/100 : ℝ))) := by
  have h := contains_pow (expTaylorBall_contains (-123/200) (by norm_num) 10 (by norm_num)) 4
  have hw : |(pow (expTaylorBall (-123/200) 10) 4).center-lowDecayBall.center|+
      (pow (expTaylorBall (-123/200) 10) 4).radius ≤ lowDecayBall.radius := by
    norm_num [expTaylorBall,lowDecayBall,pow,mul,point,Finset.sum_range_succ]
  have hc := contains_weaken h hw
  have he : Real.exp (-2*(123/100 : ℝ)) = Real.exp (-123/200 : ℝ)^4 := by
    rw [← Real.exp_nat_mul]
    norm_num
  rw [he]
  simpa only [Rat.cast_div,Rat.cast_neg,Rat.cast_ofNat] using hc

theorem highDecayBall_contains : highDecayBall.Contains (Real.exp (-2*(5/4 : ℝ))) := by
  have h := contains_pow (expTaylorBall_contains (-5/8) (by norm_num) 10 (by norm_num)) 4
  have hw : |(pow (expTaylorBall (-5/8) 10) 4).center-highDecayBall.center|+
      (pow (expTaylorBall (-5/8) 10) 4).radius ≤ highDecayBall.radius := by
    norm_num [expTaylorBall,highDecayBall,pow,mul,point,Finset.sum_range_succ]
  have hc := contains_weaken h hw
  have he : Real.exp (-2*(5/4 : ℝ)) = Real.exp (-5/8 : ℝ)^4 := by
    rw [← Real.exp_nat_mul]
    norm_num
  rw [he]
  simpa only [Rat.cast_div,Rat.cast_neg,Rat.cast_ofNat] using hc

theorem lowDecayBall_admissible : LogisticBallAdmissible lowDecayBall := by
  intro j hj
  interval_cases j <;> norm_num [powerBall,lowDecayBall,point,add,pow,mul]

theorem highDecayBall_admissible : LogisticBallAdmissible highDecayBall := by
  intro j hj
  interval_cases j <;> norm_num [powerBall,highDecayBall,point,add,pow,mul]

def stationaryBall (a : ℚ) (Y : RationalBall) : RationalBall :=
  sub (mul (point a) (scalarSeriesBall Y 3)) (scalarSeriesBall Y 0)

theorem stationaryBall_contains (a : ℚ) (Y : RationalBall) (hY : LogisticBallAdmissible Y)
    (hy : Y.Contains (Real.exp (-2*(a : ℝ)))) (hy1 : Real.exp (-2*(a : ℝ)) ≤ 1/10) :
    (stationaryBall a Y).Contains (scalarStationary (a : ℝ)) := by
  have h0 := scalarSeriesBall_contains Y hY 0 (Real.exp (-2*(a : ℝ))) hy (Real.exp_pos _).le hy1
  have h3 := scalarSeriesBall_contains Y hY 3 (Real.exp (-2*(a : ℝ))) hy (Real.exp_pos _).le hy1
  exact contains_sub (contains_mul (contains_point a) h3) h0

private theorem low_stationaryBall_positive :
    0 < (stationaryBall (123/100) lowDecayBall).center-(stationaryBall (123/100) lowDecayBall).radius := by
  norm_num [stationaryBall,scalarSeriesBall,partialScalarBall,scalarTermBall,componentConstant,
    valueBall,slopeBall,powerBall,lowDecayBall,point,add,sub,neg,mul,div,inv,pow]
private theorem high_stationaryBall_negative :
    (stationaryBall (5/4) highDecayBall).center+(stationaryBall (5/4) highDecayBall).radius < 0 := by
  norm_num [stationaryBall,scalarSeriesBall,partialScalarBall,scalarTermBall,componentConstant,
    valueBall,slopeBall,powerBall,highDecayBall,point,add,sub,neg,mul,div,inv,pow]

theorem scalarStationary_low_pos : 0 < scalarStationary (123/100) := by
  have hy := abs_le.mp lowDecayBall_contains
  have hy1 : Real.exp (-2*(123/100 : ℝ)) ≤ 1/10 := by norm_num [lowDecayBall] at hy; linarith
  have h := stationaryBall_contains (123/100) lowDecayBall lowDecayBall_admissible (by simpa using lowDecayBall_contains)
    (by simpa using hy1)
  have hlo := (abs_le.mp h).1
  have hr : (0 : ℝ) < ((stationaryBall (123/100) lowDecayBall).center : ℝ)-
      (stationaryBall (123/100) lowDecayBall).radius := by exact_mod_cast low_stationaryBall_positive
  norm_num only [Rat.cast_div,Rat.cast_ofNat] at hlo
  linarith

theorem scalarStationary_high_neg : scalarStationary (5/4) < 0 := by
  have hy := abs_le.mp highDecayBall_contains
  have hy1 : Real.exp (-2*(5/4 : ℝ)) ≤ 1/10 := by norm_num [highDecayBall] at hy; linarith
  have h := stationaryBall_contains (5/4) highDecayBall highDecayBall_admissible (by simpa using highDecayBall_contains)
    (by simpa using hy1)
  have hhi := (abs_le.mp h).2
  have hr : ((stationaryBall (5/4) highDecayBall).center : ℝ)+
      (stationaryBall (5/4) highDecayBall).radius < (0 : ℝ) := by exact_mod_cast high_stationaryBall_negative
  norm_num only [Rat.cast_div,Rat.cast_ofNat] at hhi
  linarith

theorem decayBall_contains_of_gain_interval (a : ℝ) (ha : a ∈ Set.Icc (123/100) (5/4)) :
    decayBall.Contains (Real.exp (-2*a)) := by
  have hl := abs_le.mp lowDecayBall_contains
  have hh := abs_le.mp highDecayBall_contains
  have hlow : Real.exp (-(5/2 : ℝ)) ≤ Real.exp (-(2*a)) := Real.exp_le_exp.mpr (by linarith [ha.2])
  have hhigh : Real.exp (-(2*a)) ≤ Real.exp (-(123/50 : ℝ)) := Real.exp_le_exp.mpr (by linarith [ha.1])
  norm_num [lowDecayBall,highDecayBall] at hl hh
  apply abs_le.mpr
  norm_num [decayBall]
  constructor <;> linarith

/-- Positivity of the normalized optimized-curvature formula on the whole
certified gain interval, from the literal infinite scalar series. -/
theorem normalizedOptimizedCurvature_gt_tenth (a : ℝ) (ha : a ∈ Set.Icc (123/100) (5/4)) :
    (1 : ℝ)/10 < normalizedOptimizedCurvature a := by
  have hy := decayBall_contains_of_gain_interval a ha
  have h0 := scalarComponentY_enclosure 0 (Real.exp (-2*a)) hy
  have h1 := scalarComponentY_enclosure 1 (Real.exp (-2*a)) hy
  have h2 := scalarComponentY_enclosure 2 (Real.exp (-2*a)) hy
  have h4 := scalarComponentY_enclosure 4 (Real.exp (-2*a)) hy
  have h5 := scalarComponentY_enclosure 5 (Real.exp (-2*a)) hy
  have hga : gainBall.Contains a := by
    apply abs_le.mpr
    norm_num [gainBall]
    constructor <;> linarith [ha.1,ha.2]
  exact curvatureExpr_gt_tenth a _ _ _ _ _ hga h0 h1 h2 h4 h5

end NeuralGeneralization.OnlineLowerTanh
