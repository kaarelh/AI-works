import NeuralGeneralization.OnlineLowerTanhCurvatureCertificate
import NeuralGeneralization.OnlineLowerTanhSeriesTail

/-! Rational enclosures of the actual convergent curvature series. -/
noncomputable section
set_option maxRecDepth 4096
set_option maxHeartbeats 2000000
namespace NeuralGeneralization.OnlineLowerTanh
open RationalBall
open scoped BigOperators

def decayBall : RationalBall := ⟨21/250,1/500⟩
def powerBall (Y : RationalBall) (j : ℕ) : RationalBall := pow Y (2*j+1)
def valueBall (Y : RationalBall) (j : ℕ) : RationalBall := div (powerBall Y j) (add (point 1) (powerBall Y j))
def slopeBall (Y : RationalBall) (j : ℕ) : RationalBall :=
  div (mul (point (-2*(2*j+1))) (powerBall Y j)) (pow (add (point 1) (powerBall Y j)) 2)
def secondBall (Y : RationalBall) (j : ℕ) : RationalBall :=
  div (mul (mul (point ((2*(2*j+1))^2)) (powerBall Y j)) (sub (point 1) (powerBall Y j)))
    (pow (add (point 1) (powerBall Y j)) 3)

def LogisticBallAdmissible (Y : RationalBall) : Prop := ∀ j < 4,
  (add (point 1) (powerBall Y j)).radius < |(add (point 1) (powerBall Y j)).center| ∧
  (pow (add (point 1) (powerBall Y j)) 2).radius < |(pow (add (point 1) (powerBall Y j)) 2).center| ∧
  (pow (add (point 1) (powerBall Y j)) 3).radius < |(pow (add (point 1) (powerBall Y j)) 3).center|

theorem decayBall_admissible : LogisticBallAdmissible decayBall := by
  intro j hj
  interval_cases j <;> norm_num [powerBall,decayBall,point,add,pow,mul]

theorem valueBall_contains (Y : RationalBall) (hY : LogisticBallAdmissible Y) (y : ℝ) (hy : Y.Contains y) (j : ℕ) (hj : j < 4) :
    (valueBall Y j).Contains (logisticValue j y) :=
  by
    have h := contains_div (contains_pow hy (2*j+1))
      (contains_add (contains_point 1) (contains_pow hy (2*j+1))) (hY j hj).1
    simpa only [valueBall,powerBall,logisticValue,logisticPower,Rat.cast_one] using h

theorem slopeBall_contains (Y : RationalBall) (hY : LogisticBallAdmissible Y) (y : ℝ) (hy : Y.Contains y) (j : ℕ) (hj : j < 4) :
    (slopeBall Y j).Contains (logisticSlopeY j y) := by
  have h := contains_div (contains_mul (contains_point (-2*(2*j+1))) (contains_pow hy (2*j+1)))
    (contains_pow (contains_add (contains_point 1) (contains_pow hy (2*j+1))) 2) (hY j hj).2.1
  simpa only [slopeBall,powerBall,logisticSlopeY,logisticPower,Rat.cast_mul,Rat.cast_neg,Rat.cast_ofNat,Rat.cast_add,Rat.cast_one,Rat.cast_natCast] using h

theorem secondBall_contains (Y : RationalBall) (hY : LogisticBallAdmissible Y) (y : ℝ) (hy : Y.Contains y) (j : ℕ) (hj : j < 4) :
    (secondBall Y j).Contains (logisticCurvatureY j y) := by
  have h := contains_div
    (contains_mul (contains_mul (contains_point ((2*(2*j+1))^2)) (contains_pow hy (2*j+1)))
      (contains_sub (contains_point 1) (contains_pow hy (2*j+1))))
    (contains_pow (contains_add (contains_point 1) (contains_pow hy (2*j+1))) 3) (hY j hj).2.2
  simpa only [secondBall,powerBall,logisticCurvatureY,logisticPower,Rat.cast_mul,Rat.cast_pow,Rat.cast_ofNat,Rat.cast_add,Rat.cast_one,Rat.cast_natCast] using h

def scalarTermBall (Y : RationalBall) (i : Fin 6) (j : ℕ) : RationalBall :=
  match i.val with
  | 0 => mul (point (-4*(-1)^j)) (valueBall Y j)
  | 1 => mul (point (4*(-1)^j*(1+2*(j : ℚ)*(j+1)))) (valueBall Y j)
  | 2 => mul (point (-4*(-1)^j*(1+4*(j : ℚ)*(j+1)+2*((j : ℚ)*(j+1))^2))) (valueBall Y j)
  | 3 => mul (point (-4*(-1)^j)) (slopeBall Y j)
  | 4 => mul (point (-4*(-1)^j)) (secondBall Y j)
  | _ => mul (point (4*(-1)^j*(1+2*(j : ℚ)*(j+1)))) (slopeBall Y j)

theorem scalarTermBall_contains (Y : RationalBall) (hY : LogisticBallAdmissible Y) (i : Fin 6) (j : ℕ) (hj : j < 4)
    (y : ℝ) (hy : Y.Contains y) :
    (scalarTermBall Y i j).Contains (scalarTermY i j y) := by
  have hv := valueBall_contains Y hY y hy j hj
  have hs := slopeBall_contains Y hY y hy j hj
  have hc := secondBall_contains Y hY y hy j hj
  fin_cases i
  · simpa [scalarTermBall,scalarTermY] using
      contains_mul (contains_point (-4*(-1)^j)) hv
  · simpa [scalarTermBall,scalarTermY] using
      contains_mul (contains_point (4*(-1)^j*(1+2*(j : ℚ)*(j+1)))) hv
  · convert contains_mul (contains_point (-4*(-1)^j*(1+4*(j : ℚ)*(j+1)+2*((j : ℚ)*(j+1))^2))) hv using 1 <;> try rfl
    simp only [scalarTermY]
    push_cast
    ring
  · simpa [scalarTermBall,scalarTermY] using
      contains_mul (contains_point (-4*(-1)^j)) hs
  · simpa [scalarTermBall,scalarTermY] using
      contains_mul (contains_point (-4*(-1)^j)) hc
  · simpa [scalarTermBall,scalarTermY] using
      contains_mul (contains_point (4*(-1)^j*(1+2*(j : ℚ)*(j+1)))) hs


def componentConstant (i : Fin 6) : ℚ := if i.val=0 then 1 else 0

def scalarComponentY (i : Fin 6) (y : ℝ) : ℝ :=
  match i.val with
  | 0 => scalarF0Y y
  | 1 => scalarF1Y y
  | 2 => scalarF2Y y
  | 3 => scalarF0FirstY y
  | 4 => scalarF0SecondY y
  | _ => scalarF1FirstY y

theorem scalarComponentY_eq_tsum (i : Fin 6) (y : ℝ) :
    scalarComponentY i y = (componentConstant i : ℝ)+∑' j : ℕ, scalarTermY i j y := by
  fin_cases i <;> norm_num only [scalarComponentY,componentConstant]
  all_goals simp only [scalarTermY,scalarF0Y,scalarF1Y,scalarF2Y,
    scalarF0FirstY,scalarF0SecondY,scalarF1FirstY,mul_assoc,zero_add]
  all_goals rw [tsum_mul_left]
  all_goals norm_num
  all_goals ring

def partialScalarBall (Y : RationalBall) (i : Fin 6) : RationalBall :=
  add (add (add (add (point (componentConstant i)) (scalarTermBall Y i 0))
    (scalarTermBall Y i 1)) (scalarTermBall Y i 2)) (scalarTermBall Y i 3)
def scalarSeriesBall (Y : RationalBall) (i : Fin 6) : RationalBall :=
  add (partialScalarBall Y i) ⟨0,1/10000⟩

theorem partialScalarBall_contains (Y : RationalBall) (hY : LogisticBallAdmissible Y)
    (i : Fin 6) (y : ℝ) (hy : Y.Contains y) :
    (partialScalarBall Y i).Contains ((componentConstant i : ℝ)+
      ∑ j ∈ Finset.range 4, scalarTermY i j y) := by
  have h := contains_add (contains_add (contains_add
    (contains_add (contains_point (componentConstant i))
      (scalarTermBall_contains Y hY i 0 (by norm_num) y hy))
      (scalarTermBall_contains Y hY i 1 (by norm_num) y hy))
      (scalarTermBall_contains Y hY i 2 (by norm_num) y hy))
      (scalarTermBall_contains Y hY i 3 (by norm_num) y hy)
  simpa only [partialScalarBall,Finset.sum_range_succ,Finset.sum_range_zero,zero_add,add_assoc] using h

theorem scalarSeriesBall_contains (Y : RationalBall) (hY : LogisticBallAdmissible Y)
    (i : Fin 6) (y : ℝ) (hy : Y.Contains y) (hy0 : 0 ≤ y) (hy1 : y ≤ 1/10) :
    (scalarSeriesBall Y i).Contains (scalarComponentY i y) := by
  have ht : (⟨0,1/10000⟩ : RationalBall).Contains (∑' j : ℕ, scalarTermY i (j+4) y) := by
    simpa only [Contains,Rat.cast_zero,sub_zero,Rat.cast_div,Rat.cast_one,Rat.cast_ofNat] using
      scalarTermY_tail_abs_le i y hy0 hy1
  have h := contains_add (partialScalarBall_contains Y hY i y hy) ht
  have he := (scalarTermY_summable i y hy0 hy1).sum_add_tsum_nat_add 4
  rw [scalarComponentY_eq_tsum,← he]
  simpa only [scalarSeriesBall,add_assoc] using h

def componentTargetBall (i : Fin 6) : RationalBall :=
  match i.val with
  | 0 => f0Ball
  | 1 => f1Ball
  | 2 => f2Ball
  | 3 => ⟨279/500,9/500⟩
  | 4 => fppBall
  | _ => f1pBall

private theorem scalarSeriesBall_refines (i : Fin 6) :
    |(scalarSeriesBall decayBall i).center-(componentTargetBall i).center|+
      (scalarSeriesBall decayBall i).radius ≤ (componentTargetBall i).radius := by
  fin_cases i <;> norm_num [scalarSeriesBall,partialScalarBall,scalarTermBall,componentTargetBall,
    componentConstant,valueBall,slopeBall,secondBall,powerBall,decayBall,
    f0Ball,f1Ball,f2Ball,fppBall,f1pBall,point,add,sub,neg,mul,div,inv,pow]

/-- All six enclosures are derived from their literal infinite series. -/
theorem scalarComponentY_enclosure (i : Fin 6) (y : ℝ) (hy : decayBall.Contains y) :
    (componentTargetBall i).Contains (scalarComponentY i y) := by
  have hbounds := abs_le.mp hy
  have hy0 : 0 ≤ y := by norm_num [decayBall] at hbounds; linarith
  have hy1 : y ≤ 1/10 := by norm_num [decayBall] at hbounds; linarith
  exact contains_weaken (scalarSeriesBall_contains decayBall decayBall_admissible i y hy hy0 hy1)
    (scalarSeriesBall_refines i)

end NeuralGeneralization.OnlineLowerTanh
