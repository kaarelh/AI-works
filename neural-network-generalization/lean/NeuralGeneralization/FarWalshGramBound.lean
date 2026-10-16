import NeuralGeneralization.CubeSampleMatrixBound
import NeuralGeneralization.CubeFarPairs
import NeuralGeneralization.WalshKernelMoments

/-! A complete actual sampled Walsh tail-Gram bound, from literal IID
sampling through the sharp random-restriction estimate. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical CubeFarPairs
attribute [local instance] Classical.propDecidable

/-- The explicit second-moment budget after cancelling every ambient
cube-cardinality factor. -/
def tailGramBudget (d n : ℕ) (rho ell tau s2 : ℝ) : ℝ :=
  32*(restrictionConstant*restrictionLog (Fintype.card (ClippingCube d))
        (Fintype.card (ClippingCube d))*rho^2*Real.log (Fintype.card (ClippingCube d))+
    2*restrictionConstant*(Real.exp 1+1)*(n:ℝ)*
      restrictionLog (Fintype.card (ClippingCube d)) (Fintype.card (ClippingCube d))*s2+
    16*(n:ℝ)^2*(ell+tau*nearProbabilityBound d)^2)

variable {d n : ℕ}

lemma cube_probability_le_add_of_imp (E F G : (Fin n → ClippingCube d) → Prop)
    (himp : ∀ s,E s → F s ∨ G s) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n E ≤
      ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n F+
      ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n G := by
  simp only [sampleProbability_uniform_eq_finiteMean]
  rw [←finiteMean_add]
  apply finiteMean_mono
  intro s
  by_cases he : E s
  · rcases himp s he with hf | hg
    · simp only [if_pos he,if_pos hf]
      split_ifs <;> norm_num
    · simp only [if_pos he,if_pos hg]
      split_ifs <;> norm_num
  · simp only [if_neg he]
    positivity

/-- The fully proved far-masked matrix norm bound for an actual Walsh
kernel, stated in the literal cube IID sample convention. -/
theorem far_walsh_operator_probability (w : Finset (Fin d) → ℝ)
    (hw : ∀ S,0 ≤ w S) (rho ell t : ℝ) (hrho : 0 < rho) (hell : 0 ≤ ell) (ht : 0 < t)
    (hmax : ∀ S,w S ≤ ell)
    (hfar : ∀ x y,far x y → |walshKernel w x y| ≤ rho)
    (hd : 0 < d) (hn : 4 ≤ n) (hnm : 2*n ≤ Fintype.card (ClippingCube d)) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => t < operatorSquare (fun i j => maskedKernel (walshKernel w) far (s i) (s j))) ≤
      tailGramBudget d n rho ell (∑ S,w S) (∑ S,w S^2)/t+
      (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ) := by
  have hentry (x y : ClippingCube d) : |maskedKernel (walshKernel w) far x y| ≤ rho := by
    unfold maskedKernel
    split_ifs with h
    · exact hfar x y h
    · simpa using hrho.le
  have hh := masked_walsh_kernel_probability w hw far far_symm (not_far_self hd)
    rho ell ((Fintype.card (ClippingCube d):ℝ)*nearProbabilityBound d) t
    hrho hell (mul_nonneg (by positivity) (nearProbabilityBound_nonneg d)) ht hmax hentry
    near_count_le hn hnm
  convert hh using 1
  unfold tailGramBudget
  have hM : (Fintype.card (ClippingCube d):ℝ) ≠ 0 := by positivity
  field_simp
  ring

lemma far_walsh_quadratic_close (w : Finset (Fin d) → ℝ) (s : Fin n → ClippingCube d)
    (t : ℝ) (ht : 0 ≤ t) (hd : 0 < d)
    (hfar : ∀ i j,i≠j → far (s i) (s j))
    (hop : operatorSquare (fun i j => maskedKernel (walshKernel w) far (s i) (s j)) ≤ t^2)
    (u : Fin n → ℝ) :
    |finiteQuadratic (fun i j => walshKernel w (s i) (s j)) u-(∑ S,w S)*(∑ i,u i^2)| ≤
      t*(∑ i,u i^2) := by
  have he : (fun i j => maskedKernel (walshKernel w) far (s i) (s j))=
      offDiagonal (fun i j => walshKernel w (s i) (s j)) := by
    funext i j
    by_cases hij : i=j
    · subst j
      simp [maskedKernel,offDiagonal,not_far_self hd]
    · simp [maskedKernel,offDiagonal,hij,hfar i j hij]
  rw [he] at hop
  rw [finiteQuadratic_offDiagonal_decomposition _ _
    (fun i => WalshKernelMoments.walshKernel_diagonal w (s i)) u,add_sub_cancel_left]
  exact finiteQuadratic_abs_le_of_operatorSquare _ t ht hop u

/-- The exact all-vector tail-Gram perturbation probability. The proof
includes actual near-pair/collision exclusion, selector decoupling,
rank-one concentration, and the sampled Euclidean operator geometry. -/
theorem far_walsh_gram_probability (w : Finset (Fin d) → ℝ)
    (hw : ∀ S,0 ≤ w S) (rho ell t : ℝ) (hrho : 0 < rho) (hell : 0 ≤ ell) (ht : 0 < t)
    (hmax : ∀ S,w S ≤ ell)
    (hfar : ∀ x y,far x y → |walshKernel w x y| ≤ rho)
    (hd : 0 < d) (hn : 4 ≤ n) (hnm : 2*n ≤ Fintype.card (ClippingCube d)) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => ∃ u : Fin n → ℝ,
        t*(∑ i,u i^2) <
          |finiteQuadratic (fun i j => walshKernel w (s i) (s j)) u-(∑ S,w S)*(∑ i,u i^2)|) ≤
      tailGramBudget d n rho ell (∑ S,w S) (∑ S,w S^2)/t^2+
        (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ)+
        (n:ℝ)^2*nearProbabilityBound d := by
  have hp := far_walsh_operator_probability w hw rho ell (t^2) hrho hell
    (sq_pos_of_pos ht) hmax hfar hd hn hnm
  have hnear := sampled_near_probability d n
  have hu := cube_probability_le_add_of_imp
    (fun s => ∃ u : Fin n → ℝ, t*(∑ i,u i^2) <
      |finiteQuadratic (fun i j => walshKernel w (s i) (s j)) u-(∑ S,w S)*(∑ i,u i^2)|)
    (fun s => t^2 < operatorSquare (fun i j => maskedKernel (walshKernel w) far (s i) (s j)))
    (fun s => ¬∀ i j,i≠j → far (s i) (s j)) (by
      intro s hs
      by_cases hf : ∀ i j,i≠j → far (s i) (s j)
      · left
        by_contra hnop
        obtain ⟨u,hu⟩ := hs
        exact (not_lt_of_ge (far_walsh_quadratic_close w s t ht.le hd hf (le_of_not_gt hnop) u)) hu
      · exact Or.inr hf)
  exact hu.trans (add_le_add hp hnear)

end NeuralGeneralization.RandomRestriction
