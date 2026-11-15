import NeuralGeneralization.OnlineLowerTanhFiniteParityPairSlices

/-! Local agreement of the actual absolute and signed affine ratios. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- Affine parameters, with coordinate zero containing the bias. -/
def affineParityCoefficient (n:ℕ) (z:Fin (n+1)→ℝ) : ℝ :=
  parityCorrelation (fun i=>z i.succ) (z 0)

def balancedAffinePoint (r:ℕ) (a:ℝ) : Fin ((2*r+1)+1)→ℝ :=
  Fin.cases 0 (fun _=>a)

def signedAffineParityRatio (r:ℕ) (z:Fin ((2*r+1)+1)→ℝ) : ℝ :=
  ((-1:ℝ)^r*affineParityCoefficient (2*r+1) z)/Real.sqrt (∑i,z i^2)

def absoluteAffineParityRatio (r:ℕ) (z:Fin ((2*r+1)+1)→ℝ) : ℝ :=
  |affineParityCoefficient (2*r+1) z|/Real.sqrt (∑i,z i^2)

lemma continuous_affineParityCoefficient (n:ℕ) : Continuous (affineParityCoefficient n) := by
  unfold affineParityCoefficient parityCorrelation incomingLinear
  fun_prop

lemma affineParityCoefficient_balanced (r:ℕ) (a:ℝ) :
    (-1:ℝ)^r*affineParityCoefficient (2*r+1) (balancedAffinePoint r a)=balancedParity r a := by
  rfl

/-- The absolute-correlation objective equals the signed smooth quotient on a
full affine-parameter neighborhood of the balanced optimizing point. -/
theorem absoluteAffineParityRatio_eventually_eq (r:ℕ) :
    absoluteAffineParityRatio r =ᶠ[𝓝 (balancedAffinePoint r (balancedGain r))]
      signedAffineParityRatio r := by
  have hf:Continuous (fun z:Fin ((2*r+1)+1)→ℝ=>(-1:ℝ)^r*affineParityCoefficient (2*r+1) z):=
    (continuous_affineParityCoefficient _).const_mul _
  have hpoint:0<(-1:ℝ)^r*affineParityCoefficient (2*r+1) (balancedAffinePoint r (balancedGain r)):=
    balancedParity_gain_pos r
  have hopen:IsOpen {z:Fin ((2*r+1)+1)→ℝ | 0<(-1:ℝ)^r*affineParityCoefficient (2*r+1) z}:=
    isOpen_Ioi.preimage hf
  filter_upwards [hopen.mem_nhds hpoint] with z hz
  have he:=abs_of_pos hz
  rw [abs_mul,abs_neg_one_pow,one_mul] at he
  exact congrArg (fun q:ℝ=>q/Real.sqrt (∑i,z i^2)) he

end NeuralGeneralization.OnlineLowerTanh
