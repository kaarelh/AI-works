import NeuralGeneralization.BatchTwoContinuousInputNet

/-! Uniform compression on the unit ball with a width independent of the
learner width. The intermediate input mesh depends only on energy and error. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling

def inputMesh (r K R : ℕ) : ℕ := 48*R*(4*(R^2*K))^(r+2)

theorem inputMesh_pos {r K R : ℕ} (hK : 1 ≤ K) (hR : 1 ≤ R) : 0 < inputMesh r K R := by
  unfold inputMesh
  positivity

def uniformCompressionWidth (d r K R : ℕ) : ℕ :=
  compressionWidth (netDimension d (InputCode d (inputMesh r K R))) r (2*(R^2*K))

theorem uniformCompressionWidth_pos {d r K R : ℕ} (hK : 1 ≤ K) (hR : 1 ≤ R) :
    0 < uniformCompressionWidth d r K R := by
  unfold uniformCompressionWidth
  apply compressionWidth_pos
  have hp : 0 < 2*(R^2*K) := by positivity
  omega

theorem uniform_real_input_compression {d N r K R : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K) (hR : 1 ≤ R)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ (K : ℝ))
    (X : Set (RealInput d)) (hX : X.Nonempty) (hball : ∀ x ∈ X, ∑ j, x j^2 ≤ 1) :
    let M := uniformCompressionWidth d r K R
    ∃ v : Weights d M r, weightedSquaredNorm v ≤ 4*((R^2*K : ℕ) : ℝ) ∧
      boundedWeights M v ∧ ∀ x ∈ X, |output φ v x-output φ w x| ≤ 1/(6*(R : ℝ)) := by
  let T := inputMesh r K R
  let Q := R^2*K
  let rep : InputCode d T → RealInput d := inputRepresentative X hX
  have hT : 0 < T := inputMesh_pos hK hR
  have hrep : ∀ q, ∑ j, rep q j^2 ≤ 1 := fun q => hball _ (inputRepresentative_mem X hX q)
  obtain ⟨v,hv,hb,he⟩ := finite_real_input_compression_scaled hd hN hK hR φ hφ w hw rep hrep
  refine ⟨v,hv,hb,?_⟩
  intro x hx
  obtain ⟨q,hq⟩ := inputRepresentative_close hT X hX hball x hx
  have hKR : 1 ≤ (K : ℝ) := by exact_mod_cast hK
  have hRR : 1 ≤ (R : ℝ) := by exact_mod_cast hR
  have hRp : 0 < (R : ℝ) := by linarith
  have hTp : 0 < (T : ℝ) := by exact_mod_cast hT
  have hKQ : (K : ℝ) ≤ 4*(Q : ℝ) := by
    have hR2 : 1 ≤ (R : ℝ)^2 := by nlinarith
    have hh := mul_le_mul_of_nonneg_right hR2 (by linarith : 0 ≤ (K : ℝ))
    dsimp [Q]
    push_cast
    nlinarith
  have hQ1 : 1 ≤ 4*(Q : ℝ) := hKR.trans hKQ
  have hvx := output_input_stability (uniformCompressionWidth_pos hK hR) φ hφ.2 v hQ1 hv
    (by positivity : 0 ≤ 2/(T : ℝ)) x (rep q) hq
  have hwx := output_input_stability hN φ hφ.2 w hQ1 (hw.trans hKQ)
    (by positivity : 0 ≤ 2/(T : ℝ)) x (rep q) hq
  have hbudget : (4*(Q : ℝ))^(r+2)*(2/(T : ℝ))=1/(24*(R : ℝ)) := by
    have hQp : 0 < (Q : ℝ) := by linarith
    have hTeq : (T : ℝ)=48*(R : ℝ)*(4*(Q : ℝ))^(r+2) := by dsimp [T,Q,inputMesh]; push_cast; rfl
    rw [hTeq]
    field_simp
    <;> ring
  rw [hbudget] at hvx hwx
  have htriangle := abs_sub_le (output φ v x) (output φ v (rep q)) (output φ w x)
  have htriangle' := abs_sub_le (output φ v (rep q)) (output φ w (rep q)) (output φ w x)
  rw [abs_sub_comm (output φ w (rep q))] at htriangle'
  have herr := he q
  have hfrac : 1/(24*(R : ℝ))+1/(12*(R : ℝ))+1/(24*(R : ℝ))=1/(6*(R : ℝ)) := by field_simp; ring
  linarith

end NeuralGeneralization.BatchTwoContinuous
