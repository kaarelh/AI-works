import NeuralGeneralization.RandomSampleMatrixBound
import NeuralGeneralization.WalshMaskedMatrixGeometry
import NeuralGeneralization.ParityLowFeatures
import NeuralGeneralization.SampleMatrixQuadratic

/-! Literal IID cube samples inherit the proved matrix restriction bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace NeuralGeneralization.RandomRestriction
open scoped BigOperators Matrix.Norms.L2Operator
open SquaredSampling Classical
attribute [local instance] Classical.propDecidable

variable {d n : ℕ}

lemma sampleProbability_cubeIndex (E : (Fin n → ClippingCube d) → Prop) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n E =
      finiteEvent (fun s : Fin n → Fin (Fintype.card (ClippingCube d)) =>
        E (fun i => cubeIndex d (s i))) := by
  rw [sampleProbability_uniform_eq_finiteMean]
  unfold finiteEvent
  have hh := finiteMean_equiv (Equiv.piCongrRight (fun _ : Fin n => cubeIndex d))
    (fun s : Fin n → ClippingCube d => if E s then (1:ℝ) else 0)
  exact hh.symm

/-- The indexed matrix and the literal sampled kernel have exactly the
same entries. -/
lemma sampled_indexedKernel (K : ClippingCube d → ClippingCube d → ℝ)
    (s : Fin n → Fin (Fintype.card (ClippingCube d))) :
    sampledMatrix (indexedKernel K) s=fun i j => K (cubeIndex d (s i)) (cubeIndex d (s j)) := rfl

/-- The full actual IID cube-kernel probability bound, with no selector
or distributional hypotheses remaining. -/
theorem hollow_cube_kernel_probability (K : ClippingCube d → ClippingCube d → ℝ)
    (R C t : ℝ) (hn : 4 ≤ n) (hnm : 2*n ≤ Fintype.card (ClippingCube d))
    (hR : 0 < R) (hC : 0 ≤ C) (ht : 0 < t)
    (hdiag : ∀ x,K x x=0) (hentry : ∀ x y,K x y^2 ≤ R)
    (hrow : ∀ i,(∑ j,indexedKernel K i j^2) ≤ C)
    (hcol : ∀ j,(∑ i,indexedKernel K i j^2) ≤ C) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => t < operatorSquare (fun i j => K (s i) (s j))) ≤
      32*(restrictionConstant*restrictionLog (Fintype.card (ClippingCube d))
          (Fintype.card (ClippingCube d))*R*Real.log (Fintype.card (ClippingCube d))+
        restrictionConstant*(Real.exp 1+1)*(2*(n:ℝ)/(Fintype.card (ClippingCube d):ℝ))*
          restrictionLog (Fintype.card (ClippingCube d)) (Fintype.card (ClippingCube d))*C+
        4*(2*(n:ℝ)/(Fintype.card (ClippingCube d):ℝ))^2*operatorSquare (indexedKernel K))/t+
      (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ) := by
  rw [sampleProbability_cubeIndex]
  exact hollow_sampled_operatorSquare_probability_explicit (indexedKernel K) R C t hn hnm hR hC ht
    (fun i => hdiag _) (fun i j => hentry _ _) hrow hcol

/-- All deterministic inputs to the matrix theorem are discharged for an
actual masked Walsh kernel. Only explicit scalar bounds remain. -/
theorem masked_walsh_kernel_probability (w : Finset (Fin d) → ℝ)
    (hw : ∀ S,0 ≤ w S) (keep : ClippingCube d → ClippingCube d → Prop)
    (hkeep : ∀ x y,keep x y ↔ keep y x) (hdiag : ∀ x,¬keep x x)
    (rho ell b t : ℝ) (hrho : 0 < rho) (hell : 0 ≤ ell) (hb : 0 ≤ b) (ht : 0 < t)
    (hmax : ∀ S,w S ≤ ell)
    (hentry : ∀ x y,|maskedKernel (walshKernel w) keep x y| ≤ rho)
    (hcount : ∀ x,((Finset.univ.filter (fun y => ¬keep x y)).card:ℝ) ≤ b)
    (hn : 4 ≤ n) (hnm : 2*n ≤ Fintype.card (ClippingCube d)) :
    ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
      (fun s => t < operatorSquare (fun i j => maskedKernel (walshKernel w) keep (s i) (s j))) ≤
      32*(restrictionConstant*restrictionLog (Fintype.card (ClippingCube d))
          (Fintype.card (ClippingCube d))*rho^2*Real.log (Fintype.card (ClippingCube d))+
        restrictionConstant*(Real.exp 1+1)*(2*(n:ℝ)/(Fintype.card (ClippingCube d):ℝ))*
          restrictionLog (Fintype.card (ClippingCube d)) (Fintype.card (ClippingCube d))*
          ((Fintype.card (ClippingCube d):ℝ)*∑ S,w S^2)+
        4*(2*(n:ℝ)/(Fintype.card (ClippingCube d):ℝ))^2*
          ((Fintype.card (ClippingCube d):ℝ)*ell+(∑ S,w S)*b)^2)/t+
      (n:ℝ)*((n:ℝ)-1)/(Fintype.card (ClippingCube d):ℝ) := by
  have hentry' (x y : ClippingCube d) : maskedKernel (walshKernel w) keep x y^2 ≤ rho^2 := by
    have hh := (sq_le_sq₀ (abs_nonneg _) hrho.le).mpr (hentry x y)
    simpa only [sq_abs] using hh
  have hh := hollow_cube_kernel_probability (maskedKernel (walshKernel w) keep)
    (rho^2) ((Fintype.card (ClippingCube d):ℝ)*∑ S,w S^2) t hn hnm
    (sq_pos_of_pos hrho) (by positivity) ht
    (fun x => by simp [maskedKernel,hdiag]) hentry'
    (indexedMaskedWalsh_square_row_le w keep) (indexedMaskedWalsh_square_col_le w keep)
  have hop := indexedMaskedWalsh_operatorNorm_le w hw keep hkeep ell b hell hb hmax hcount
  have htrace : 0 ≤ ∑ S,w S := Finset.sum_nonneg (fun S _ => hw S)
  have hs := (sq_le_sq₀ (norm_nonneg _) (show (0:ℝ) ≤
    (Fintype.card (ClippingCube d):ℝ)*ell+(∑ S,w S)*b from by positivity)).mpr hop
  change operatorSquare (indexedKernel (maskedKernel (walshKernel w) keep)) ≤ _ at hs
  exact hh.trans (by gcongr)

end NeuralGeneralization.RandomRestriction
