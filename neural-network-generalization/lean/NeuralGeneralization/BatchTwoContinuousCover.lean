import NeuralGeneralization.BatchTwoContinuousUniformCompression
import NeuralGeneralization.BatchTwoContinuousParameterGrid
import NeuralGeneralization.PolynomialGrowth

/-! An actual finite uniform cover of every bounded-energy real-input network,
with a fixed-depth polynomial entropy bound independent of learner width. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

def uniformWidthUpper (d r K R : ℕ) : ℕ :=
  compressionWidth (d+d*(2*inputMesh r K R+1)) r (2*(R^2*K))

theorem uniformCompressionWidth_le (d r K R : ℕ) :
    uniformCompressionWidth d r K R ≤ uniformWidthUpper d r K R := by
  have h := netDimension_inputCode_le d (inputMesh r K R)
  unfold uniformCompressionWidth uniformWidthUpper compressionWidth
  gcongr

def coverEntropy (d r K R : ℕ) : ℕ :=
  let M := uniformWidthUpper d r K R
  robustParameterCount d M r*(2*realOutputMesh d M r M (6*R)+1)

abbrev UniformCoverCode (d r K R : ℕ) :=
  RealOutputCode d (uniformCompressionWidth d r K R) r (uniformCompressionWidth d r K R) (6*R)

def uniformCoverOutput (d r K R : ℕ) (φ : ℝ → ℝ) (q : UniformCoverCode d r K R) : RealInput d → ℝ :=
  output φ (realGridWeights q)

theorem exists_uniform_cover {d N r K R : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K) (hR : 1 ≤ R)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ (K : ℝ))
    (X : Set (RealInput d)) (hX : X.Nonempty) (hball : ∀ x ∈ X, ∑ j, x j^2 ≤ 1) :
    ∃ q : UniformCoverCode d r K R, ∀ x ∈ X,
      |output φ w x-uniformCoverOutput d r K R φ q x| ≤ 1/(3*(R : ℝ)) := by
  obtain ⟨v,hv,hb,he⟩ := uniform_real_input_compression hd hN hK hR φ hφ w hw X hX hball
  obtain ⟨q,hq⟩ := exists_realGridOutput φ hφ (uniformCompressionWidth_pos hK hR)
    (by omega : 0 < 6*R) v hb
  refine ⟨q,?_⟩
  intro x hx
  have ht := abs_sub_le (output φ w x) (output φ v x) (uniformCoverOutput d r K R φ q x)
  have hc := hq x (hball x hx)
  rw [abs_sub_comm (output φ w x) (output φ v x)] at ht
  have hid : 1/(6*(R : ℝ))+1/((6*R : ℕ) : ℝ)=1/(3*(R : ℝ)) := by push_cast; ring
  change |output φ v x-uniformCoverOutput d r K R φ q x| ≤ _ at hc
  linarith [he x hx]

theorem realOutputCode_card_le_exp (d M r B R : ℕ) :
    (Fintype.card (RealOutputCode d M r B R) : ℝ) ≤
      Real.exp ((robustParameterCount d M r*(2*realOutputMesh d M r B R+1) : ℕ) : ℝ) := by
  rw [realOutputCode_card]
  push_cast
  have ha : 2*(realOutputMesh d M r B R : ℝ)+1 ≤ Real.exp (2*(realOutputMesh d M r B R : ℝ)+1) :=
    (le_add_of_nonneg_right zero_le_one).trans (Real.add_one_le_exp _)
  calc
    _ ≤ (Real.exp (2*(realOutputMesh d M r B R : ℝ)+1))^robustParameterCount d M r :=
      pow_le_pow_left₀ (by positivity) ha _
    _ = _ := by rw [← Real.exp_nat_mul]

theorem realOutputMesh_mono {d r M M' B B' R R' : ℕ}
    (hM : M ≤ M') (hB : B ≤ B') (hR : R ≤ R') :
    realOutputMesh d M r B R ≤ realOutputMesh d M' r B' R' := by
  unfold realOutputMesh parameterMesh
  gcongr

theorem robustParameterCount_mono {d r M M' : ℕ} (hM : M ≤ M') :
    robustParameterCount d M r ≤ robustParameterCount d M' r := by
  unfold robustParameterCount
  gcongr

theorem uniformCoverCode_card_le_exp (d r K R : ℕ) :
    (Fintype.card (UniformCoverCode d r K R) : ℝ) ≤ Real.exp (coverEntropy d r K R : ℝ) := by
  apply (realOutputCode_card_le_exp _ _ _ _ _).trans
  apply Real.exp_le_exp.mpr
  apply Nat.cast_le.mpr
  unfold coverEntropy
  have h := uniformCompressionWidth_le d r K R
  exact Nat.mul_le_mul (robustParameterCount_mono h)
    (Nat.add_le_add_right (Nat.mul_le_mul_left 2 (realOutputMesh_mono h h le_rfl)) 1)

theorem coverEntropy_mono {d r K R K' R' : ℕ} (hK : K ≤ K') (hR : R ≤ R') :
    coverEntropy d r K R ≤ coverEntropy d r K' R' := by
  have hi : inputMesh r K R ≤ inputMesh r K' R' := by unfold inputMesh; gcongr
  have hw : uniformWidthUpper d r K R ≤ uniformWidthUpper d r K' R' := by
    unfold uniformWidthUpper compressionWidth compressionQ
    gcongr
  unfold coverEntropy
  exact Nat.mul_le_mul (robustParameterCount_mono hw)
    (Nat.add_le_add_right (Nat.mul_le_mul_left 2
      (realOutputMesh_mono hw hw (Nat.mul_le_mul_left 6 hR))) 1)

theorem coverEntropy_polynomial (r : ℕ) : PolynomialGrowth2 (fun d S => coverEntropy d r S S) := by
  have hi : PolynomialGrowth2 (fun _d S => inputMesh r S S) := by
    unfold inputMesh
    exact ((PolynomialGrowth2.const 48).mul PolynomialGrowth2.right).mul
      (((PolynomialGrowth2.const 4).mul (PolynomialGrowth2.right.pow 2 |>.mul PolynomialGrowth2.right)).pow (r+2))
  have hq : PolynomialGrowth2 (fun _d S => 2*(S^2*S)) :=
    (PolynomialGrowth2.const 2).mul (PolynomialGrowth2.right.pow 2 |>.mul PolynomialGrowth2.right)
  have hw : PolynomialGrowth2 (fun d S => uniformWidthUpper d r S S) := by
    unfold uniformWidthUpper compressionWidth compressionQ
    exact ((((PolynomialGrowth2.const 65536).mul (PolynomialGrowth2.const (r+1))).mul
      ((PolynomialGrowth2.left.add (PolynomialGrowth2.left.mul ((PolynomialGrowth2.const 2).mul hi |>.add (PolynomialGrowth2.const 1)))).add (PolynomialGrowth2.const 1))).mul
      ((((PolynomialGrowth2.const 24).mul (PolynomialGrowth2.const (r+1))).mul
        (((PolynomialGrowth2.const 4).mul hq).pow (r+1))).pow 8)).add ((PolynomialGrowth2.const 9).mul hq)
  have hp : PolynomialGrowth2 (fun d S => robustParameterCount d (uniformWidthUpper d r S S) r) := by
    unfold robustParameterCount
    exact ((hw.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).add
      (((PolynomialGrowth2.const r).mul hw).mul hw)).add hw
  have hm : PolynomialGrowth2 (fun d S => realOutputMesh d (uniformWidthUpper d r S S) r (uniformWidthUpper d r S S) (6*S)) := by
    unfold realOutputMesh parameterMesh
    exact (((hw.mul ((PolynomialGrowth2.const 6).mul PolynomialGrowth2.right)).mul
      (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).mul
      ((PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul
        ((hw.mul (((PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul hw).add (PolynomialGrowth2.const 1))).add (PolynomialGrowth2.const 1) |>.pow (r+1))))
  exact hp.mul (((PolynomialGrowth2.const 2).mul hm).add (PolynomialGrowth2.const 1))

end NeuralGeneralization.BatchTwoContinuous
