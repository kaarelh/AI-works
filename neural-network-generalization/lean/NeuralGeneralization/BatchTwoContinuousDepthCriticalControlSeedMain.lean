import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlSeed

/-! Every sufficiently wide first layer has a simultaneous signed feature
seed at Gaussian rate at most two, uniformly over the later network depth. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoContinuous
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

def seedDilution (n:ℕ) (δ:ℝ):ℕ:=⌈1+10*(seedSlope n δ)^2⌉₊
def dilutedSeedGain (n:ℕ) (δ:ℝ):ℝ:=7/(32*(n:ℝ)*(seedDilution n δ:ℝ))

theorem seedDilution_pos (n:ℕ) (δ:ℝ):0<seedDilution n δ:=by
  have hh:=Nat.le_ceil (1+10*(seedSlope n δ)^2)
  have hR:(0:ℝ)<(seedDilution n δ:ℝ):=by change 0<(⌈1+10*(seedSlope n δ)^2⌉₊:ℝ);nlinarith [sq_nonneg (seedSlope n δ)]
  exact_mod_cast hR

theorem dilutedSeedGain_pos {n:ℕ} (hn:0<n) (δ:ℝ):0<dilutedSeedGain n δ:=by
  unfold dilutedSeedGain
  have hp:=seedDilution_pos n δ
  positivity

def seedControlFamily {n:ℕ} (x:Fin n→RealInput 2) (y:Fin n→Bool) (δ:ℝ):
    (Fin n×Bool)→Fin 3→ℝ:=fun p=>seedShift (seedSlope n δ) δ (x p.1 0) (y p.1) p.2

def dilutedSeedControl {n:ℕ} (x:Fin n→RealInput 2) (y:Fin n→Bool) (δ:ℝ) (N:ℕ):Fin N→Fin 3→ℝ:=
  dilutedControl N (N/(Fintype.card (Fin n×Bool)*seedDilution n δ))
    (integer_dilution_upper _ _ _ (seedDilution_pos n δ)) (seedControlFamily x y δ)

theorem dilutedSeedControl_cost {n:ℕ} (x:Fin n→RealInput 2) (y:Fin n→Bool)
    {δ:ℝ} (hδ:0≤δ) (hδ1:δ≤1) (hx:∀i,|x i 0|≤1) (N:ℕ):
    (∑k,∑i,(dilutedSeedControl x y δ N k i)^2)≤(N:ℝ):=by
  apply dilutedControl_unit_budget (seedDilution_pos n δ) (seedControlFamily x y δ)
    (D:=10*(seedSlope n δ)^2) (by positivity)
  · intro p
    exact seedShift_energy _ _ _ _ _ (hx p.1) hδ hδ1
  · have hh:=Nat.le_ceil (1+10*(seedSlope n δ)^2)
    change 10*(seedSlope n δ)^2≤(⌈1+10*(seedSlope n δ)^2⌉₊:ℝ)
    linarith

theorem dilutedSeedControl_signed_mean {n N:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ)
    (x:Fin n→RealInput 2) (hx:∀i,∑j,x i j^2≤1)
    (hsep:∀i j,i≠j→δ≤|x i 0-x j 0|) (y:Fin n→Bool)
    (hN:2*(Fintype.card (Fin n×Bool)*seedDilution n δ)≤N) (i:Fin n):
    2*dilutedSeedGain n δ≤labelReal (y i)*
      shiftedFamilyMean (firstRowCoefficient (x i)) (dilutedSeedControl x y δ N):=by
  let P:=seedDilution n δ
  let m:=Fintype.card (Fin n×Bool)
  let q:=N/(m*P)
  have hm:m=2*n:=by simp only [m,Fintype.card_prod,Fintype.card_fin,Fintype.card_bool];omega
  have hmpos:0<m:=by rw [hm];omega
  have hPpos:0<P:=seedDilution_pos n δ
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn
  have hPR:(0:ℝ)<P:=by exact_mod_cast hPpos
  have hNR:(0:ℝ)<N:=by exact_mod_cast (show 0<N by nlinarith [Nat.mul_pos hmpos hPpos])
  have halpha:(1:ℝ)/(2*(P:ℝ))≤(q:ℝ)*(m:ℝ)/(N:ℝ):=integer_dilution_lower hmpos hPpos hN
  have hseed:=seedRows_signed_mean hn hδ x hx hsep y i
  let S:=∑p:Fin n×Bool,gaussianRowMean (firstRowCoefficient (x i))
    (∑j,firstRowCoefficient (x i) j*seedControlFamily x y δ p j)
  have hs:7/(8*(n:ℝ))≤labelReal (y i)*(S/(2*(n:ℝ))):=hseed
  have he:shiftedFamilyMean (firstRowCoefficient (x i)) (dilutedSeedControl x y δ N)=(q:ℝ)*S/(N:ℝ):=by
    unfold shiftedFamilyMean dilutedSeedControl
    rw [dilutedControl_sum _ _ _ _ (fun z=>gaussianRowMean (firstRowCoefficient (x i))
      (∑j,firstRowCoefficient (x i) j*z j)) (by simp [gaussianRowMean_zero])]
  have hmul:=mul_le_mul halpha hs (by positivity : 0≤7/(8*(n:ℝ)))
    (by positivity : 0≤(q:ℝ)*(m:ℝ)/(N:ℝ))
  rw [he]
  have hmR:(m:ℝ)=2*(n:ℝ):=by exact_mod_cast hm
  rw [hmR] at hmul
  have heR:((q:ℝ)*(2*(n:ℝ))/(N:ℝ))*(labelReal (y i)*(S/(2*(n:ℝ))))=
      labelReal (y i)*((q:ℝ)*S/(N:ℝ)):=by field_simp
  rw [heR] at hmul
  have heL:2*dilutedSeedGain n δ=(1:ℝ)/(2*(P:ℝ))*(7/(8*(n:ℝ))):=by
    unfold dilutedSeedGain P
    ring
  rwa [heL]

/-- A seed event in the actual standardized first-layer Gaussian matrix.
Only an explicit minimum width and a scalar concentration budget are needed. -/
theorem diluted_seed_probability {n N:ℕ} (hn:0<n) {δ:ℝ} (hδ:0<δ) (hδ1:δ≤1)
    (x:Fin n→RealInput 2) (hx:∀i,∑j,x i j^2≤1) (hx0:∀i,|x i 0|≤1)
    (hsep:∀i j,i≠j→δ≤|x i 0-x j 0|) (y:Fin n→Bool)
    (hN:2*(Fintype.card (Fin n×Bool)*seedDilution n δ)≤N)
    (hbudget:4*(n:ℝ)≤(N:ℝ)*(dilutedSeedGain n δ)^2):
    (1:ℝ)/2*Real.exp (-2*(N:ℝ)-4)≤
      (Measure.pi fun _ : Fin N=>(Measure.pi fun _ : Fin 3=>gaussianReal 0 1)).real
        {w|∀i,dilutedSeedGain n δ<labelReal (y i)*
          rowAverage (fun z=>Real.tanh (rowLinear (firstRowCoefficient (x i)) z)) w}:=by
  have hNpos:0<N:=by
    have hp:=seedDilution_pos n δ
    have hm:0<Fintype.card (Fin n×Bool):=by simp;omega
    nlinarith [Nat.mul_pos hm hp]
  have hg:=dilutedSeedGain_pos hn δ
  have hh:=seed_matrix_probability (fun i=>firstRowCoefficient (x i)) (dilutedSeedControl x y δ N)
    (E:=(N:ℝ)) (by positivity) (dilutedSeedControl_cost x y hδ.le hδ1 hx0 N)
    hg hNpos (by simpa only [Fintype.card_fin] using hbudget)
  apply hh.trans (measureReal_mono _)
  intro w hw i
  have he:=hw i
  have hsign:|labelReal (y i)*(rowAverage
      (fun z=>Real.tanh (rowLinear (firstRowCoefficient (x i)) z)) w-
      shiftedFamilyMean (firstRowCoefficient (x i)) (dilutedSeedControl x y δ N))|<dilutedSeedGain n δ:=by
    simpa only [abs_mul,abs_labelReal,one_mul] using he
  have hm:=dilutedSeedControl_signed_mean hn hδ x hx hsep y hN i
  have hlow: -dilutedSeedGain n δ<labelReal (y i)*(rowAverage
      (fun z=>Real.tanh (rowLinear (firstRowCoefficient (x i)) z)) w-
      shiftedFamilyMean (firstRowCoefficient (x i)) (dilutedSeedControl x y δ N)):=(abs_lt.mp hsign).1
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthCritical
