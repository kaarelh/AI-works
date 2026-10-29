import CanonicalPicard

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ → CanonicalProgramState d}

theorem scale_le_exp (M : FiniteCanonicalDynamics P S states) :
    normalizingScale M.linearGain H≤Real.exp (canonicalEntropySum P) := by
  let w : ℕ → ℝ := fun j => if j<H then Real.sqrt (2*criticalLayerCost P j) else 0
  have he : M.linearGain=fun j => 1+w j := by
    funext j
    simp only [linearGain,w]
    split_ifs <;> ring
  rw [he]
  apply (normalizingScale_le_exp w (fun j => by dsimp [w]; split_ifs <;> positivity) H).trans_eq
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  simp only [w,if_pos (Finset.mem_range.mp hj)]

def paddedReadout (_M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) : CanonicalAmbient states H :=
  blockEmbedding (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index) ⟨H,by omega⟩ c

def predict (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) (v : CanonicalAmbient states H) : ℝ :=
  normalizingScale M.linearGain H*inner ℝ (M.paddedReadout c) v

theorem paddedReadout_norm (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) : ‖M.paddedReadout c‖=‖c‖ :=
  LinearIsometry.norm_map _ _

theorem predict_normState (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) (x : Cube d) :
    M.predict c (M.normState x H)=inner ℝ c ((states H).feature x) := by
  have hs : normalizingScale M.linearGain H≠0 := ne_of_gt
    (by linarith [normalizingScale_one_le M.linearGain M.linearGain_one_le H])
  rw [predict,normState,normalizedState,inner_smul_right,← mul_assoc,mul_inv_cancel₀ hs,one_mul]
  change inner ℝ (blockEmbedding _ ⟨H,by omega⟩ c) (M.state x H)=_
  rw [state,dif_pos (le_refl H)]
  exact LinearIsometry.inner_map_map _ _ _

theorem predict_error (M : FiniteCanonicalDynamics P S states)
    (c : EuclideanSpace ℝ (states H).Index) (x : Cube d)
    (v : CanonicalAmbient states H) {e : ℝ}
    (he : ‖v-M.normState x H‖≤e) :
    |M.predict c v-inner ℝ c ((states H).feature x)|≤
      Real.exp (canonicalEntropySum P)*‖c‖*e := by
  rw [← M.predict_normState c x]
  simp only [predict,← mul_sub,← inner_sub_right,abs_mul]
  have hs : 0≤normalizingScale M.linearGain H := by
    linarith [normalizingScale_one_le M.linearGain M.linearGain_one_le H]
  rw [abs_of_nonneg hs]
  calc
    _ ≤ normalizingScale M.linearGain H*(‖M.paddedReadout c‖*‖v-M.normState x H‖) :=
      mul_le_mul_of_nonneg_left (abs_real_inner_le_norm _ _) hs
    _ ≤ Real.exp (canonicalEntropySum P)*(‖c‖*e) := by
      rw [M.paddedReadout_norm]
      exact mul_le_mul M.scale_le_exp (mul_le_mul_of_nonneg_left he (norm_nonneg _))
        (mul_nonneg (norm_nonneg _) (norm_nonneg _)) (Real.exp_nonneg _)
    _ = _ := by ring

theorem iterate_readout_error (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {η : ℝ} (hη : 0<η)
    (hquery : ∀j≤H,∀x,QueryFeatureClose (P.feature j) (states j).feature S x η)
    (c : EuclideanSpace ℝ (states H).Index) (x : Cube d) (k : ℕ) :
    |M.predict c (M.iterate η x k H)-inner ℝ c ((states H).feature x)|≤
      Real.exp (canonicalEntropySum P)*‖c‖*
        ((4+2*η)*(canonicalNonlinearBudget P η)^k/(k.factorial:ℝ)) :=
  M.predict_error c x _ (M.iterate_error hd hη hquery x k)

theorem initial_linear_map (M : FiniteCanonicalDynamics P S states)
    (hzero : ∀x y,inner ℝ ((states 0).feature x) ((states 0).feature y)=
      inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y)) :
    ∃T : EuclideanSpace ℝ (Fin (d+1)) →L[ℝ] CanonicalAmbient states H,
      ‖T‖≤1 ∧ ∀x,T (normalizedInputFeature d x)=M.normState x 0 := by
  obtain ⟨T,hT,he⟩ := equal_gram_contraction (normalizedInputFeature d) (states 0).feature hzero
  let emb := blockEmbedding (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index) ⟨0,by omega⟩
  refine ⟨emb.toContinuousLinearMap.comp T,?_,?_⟩
  · apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
    intro v
    change ‖emb (T v)‖≤1*‖v‖
    rw [emb.norm_map]
    exact (T.le_opNorm v).trans (mul_le_mul_of_nonneg_right hT (norm_nonneg _))
  · intro x
    simp only [ContinuousLinearMap.comp_apply,LinearIsometry.coe_toContinuousLinearMap,he]
    simp only [normState,normalizedState,normalizingScale,inv_one,one_smul,state,
      dif_pos (Nat.zero_le H)]
    rfl

/-- The exact finite operations needed by the circuit evaluator: project and
scale, radially clip, evaluate the canonical Gaussian map, then apply one
linear output map and subtraction. -/
theorem normResidual_formula (M : FiniteCanonicalDynamics P S states) (η : ℝ)
    (j : Fin H) (x : CanonicalAmbient states H) :
    M.normResidual η j x =
      (normalizingScale M.linearGain (j+1))⁻¹ •
        blockEmbedding (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index) j.succ
          ((M.layer j).value
            (radialClip (canonicalRadius P η j)
              (normalizingScale M.linearGain j •
                blockProjection (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index) j.castSucc x)) -
           (M.layer j).linear
            (radialClip (canonicalRadius P η j)
              (normalizingScale M.linearGain j •
                blockProjection (fun k:Fin (H+1) => EuclideanSpace ℝ (states k).Index) j.castSucc x))) := by
  simp only [normResidual,normalizedResidual,residual,dif_pos j.isLt,
    blockLiftMap,map_smul,CanonicalLayerModel.clippedResidual]
  congr 2
  exact (eq_sub_iff_add_eq).mpr ((add_comm _ _).trans (((M.layer j).decomposition _).symm))


end FiniteCanonicalDynamics
#print axioms FiniteCanonicalDynamics.iterate_readout_error
#print axioms FiniteCanonicalDynamics.initial_linear_map
end ConditionalNonpolynomial.Analytic
