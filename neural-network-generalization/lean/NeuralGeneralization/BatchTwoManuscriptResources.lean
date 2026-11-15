import NeuralGeneralization.BatchTwoManuscriptLayerBudget
import NeuralGeneralization.BatchTwoGramPowerSource

/-! Literal scalar resources from the original-support all-scales appendix. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptResources

structure Input where
  dimension : ℕ
  depth : ℕ
  energy : ℝ
  radius : ℝ
  failure : ℝ
  dimension_pos : 0<dimension
  depth_ge_two : 2≤depth
  energy_ge_one : 1≤energy
  radius_pos : 0<radius
  radius_le_one : radius≤1
  failure_pos : 0<failure
  failure_le_eighth : failure≤1/8

def localError (p : Input) : ℝ := p.failure*p.radius^2/(1000*p.depth)
def localFailure (p : Input) : ℝ := p.failure/(100*p.depth)
def rank (p : Input) : ℕ := ⌈2*p.energy/(localError p*localFailure p)⌉₊
def messageCost (p : Input) : ℝ := (((p.dimension:ℝ)+1)*rank p+2)*Real.log 2
def activeEnergy (p : Input) : ℝ := 8*p.energy+2*rank p
def activeBound (p : Input) : ℝ := Real.sqrt (4*activeEnergy p/localError p)
def readoutEnergy (p : Input) : ℝ := (4*p.energy+2*Real.log 2)/localFailure p
def firstBound (p : Input) : ℝ := Real.sqrt (4*(4*p.energy+2*((p.dimension:ℝ)+1)*Real.log 2)/localError p)
def sampleCost (p : Input) : ℝ := max (max
  (10000*(activeEnergy p+rank p+1)/localError p)
  (64*((rank p:ℝ)+1)*Real.log (4*((rank p:ℝ)+1)/localFailure p)))
  (512*readoutEnergy p*p.radius⁻¹^2*((p.dimension:ℝ)*Real.log 2+Real.log (2/localFailure p)+1))
def bankSize (p : Input) : ℕ := ⌈sampleCost p⌉₊
def widthBound (p : Input) : ℕ := max (max (bankSize p) ⌈(p.depth:ℝ)*messageCost p/p.energy⌉₊) 1
def gaussianBound (p : Input) : ℝ := max 2 (2*Real.sqrt (Real.log (6*(bankSize p:ℝ)/localError p)))
def parameterCount (d M L : ℕ) : ℕ := M*(d+1)+(L-2)*M^2+M
def smallBound (p : Input) : ℝ := Real.sqrt
  (4*(4*(widthBound p:ℝ)*p.energy+2*(parameterCount p.dimension (widthBound p) p.depth:ℝ)*Real.log 2)/p.failure)
def largeBound (p : Input) : ℝ := max (max (max (firstBound p)
  (2*activeBound p*Real.sqrt ((rank p:ℝ)+1)/(bankSize p:ℝ)+Real.sqrt 2*gaussianBound p/Real.sqrt (bankSize p:ℝ)))
  (Real.sqrt (readoutEnergy p)/(bankSize p:ℝ))) 1
def weightBound (p : Input) : ℝ := max (max (smallBound p) (largeBound p)) 1
def gridEntropy (p : Input) : ℝ :=
  (parameterCount p.dimension (widthBound p) p.depth:ℝ)*Real.log
    (3+32*weightBound p*((p.dimension:ℝ)+p.depth+1)*
      (2*(widthBound p:ℝ)*(weightBound p+1))^p.depth/p.radius)

theorem depth_pos (p : Input) : (0:ℝ)<p.depth := by exact_mod_cast (by have := p.depth_ge_two; omega : 0<p.depth)
theorem energy_pos (p : Input) : 0<p.energy := by linarith [p.energy_ge_one]
theorem localError_pos (p : Input) : 0<localError p := by
  unfold localError
  exact div_pos (mul_pos p.failure_pos (sq_pos_of_pos p.radius_pos)) (mul_pos (by norm_num) (depth_pos p))
theorem localFailure_pos (p : Input) : 0<localFailure p := by
  unfold localFailure
  exact div_pos p.failure_pos (mul_pos (by norm_num) (depth_pos p))
theorem localFailure_le_one (p : Input) : localFailure p≤1 := by
  unfold localFailure
  apply (div_le_one (by have := depth_pos p; positivity)).mpr
  have hd : (2:ℝ)≤p.depth := by exact_mod_cast p.depth_ge_two
  linarith [p.failure_le_eighth]
theorem rank_pos (p : Input) : 0<rank p := by
  apply Nat.ceil_pos.mpr
  exact div_pos (mul_pos (by norm_num) (energy_pos p)) (mul_pos (localError_pos p) (localFailure_pos p))
theorem rank_allocation (p : Input) : 2*p.energy≤localFailure p*localError p*rank p := by
  have hh := (div_le_iff₀ (mul_pos (localError_pos p) (localFailure_pos p))).mp
    (Nat.le_ceil (2*p.energy/(localError p*localFailure p)))
  change _≤(rank p:ℝ)*(localError p*localFailure p) at hh
  nlinarith only [hh]
theorem activeEnergy_pos (p : Input) : 0<activeEnergy p := by
  unfold activeEnergy
  have := energy_pos p
  positivity

theorem bankSize_first_allocation (p : Input) :
    10000*(activeEnergy p+(rank p:ℝ)+1)/localError p≤bankSize p :=
  (le_trans (le_max_left _ _) (le_max_left _ _)).trans (Nat.le_ceil (sampleCost p))
theorem bankSize_gram_allocation (p : Input) :
    64*((rank p:ℝ)+1)*Real.log (4*((rank p:ℝ)+1)/localFailure p)≤bankSize p :=
  (le_trans (le_max_right _ _) (le_max_left _ _)).trans (Nat.le_ceil (sampleCost p))
theorem bankSize_readout_allocation (p : Input) :
    512*readoutEnergy p*p.radius⁻¹^2*((p.dimension:ℝ)*Real.log 2+Real.log (2/localFailure p)+1)≤bankSize p :=
  (le_max_right _ _).trans (Nat.le_ceil (sampleCost p))
theorem bankSize_pos (p : Input) : 0<bankSize p := by
  have hh := bankSize_first_allocation p
  have hp : 0<10000*(activeEnergy p+(rank p:ℝ)+1)/localError p := by
    have := activeEnergy_pos p
    have := localError_pos p
    positivity
  exact Nat.cast_pos.mp (hp.trans_le hh)
theorem widthBound_pos (p : Input) : 0<widthBound p := by
  have := le_max_right (max (bankSize p) ⌈(p.depth:ℝ)*messageCost p/p.energy⌉₊) 1
  change 1≤widthBound p at this
  omega

end NeuralGeneralization.BatchTwoManuscriptResources
