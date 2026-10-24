import NeuralGeneralization.BatchTwoContinuousFiniteMeanFieldBudget
import NeuralGeneralization.BatchTwoContinuousFiniteQueryExtension
import NeuralGeneralization.BatchTwoContinuousFiniteQueryTail
import NeuralGeneralization.BatchTwoContinuousCover

/-! A counted uniform cover of the actual non-Gaussian mean-field function
prior, with an exponentially small excluded mass and no width factor in entropy. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
open ConcreteModel BatchTwoNonGaussian MeanFieldBudgets

abbrev Code (ν : CoordinateLaw) (d r K R : ℕ) :=
  RealOutputCode d (FiniteQuery.compressedWidth d (FiniteQuery.queryBits ν d r K R) r K R) r
    (FiniteQuery.compressedBound ν d (FiniteQuery.queryBits ν d r K R) r K R) (6*R)

def codeOutput (ν : CoordinateLaw) (d r K R : ℕ)
    (xs : Cube (FiniteQuery.queryBits ν d r K R) → RealInput d) (c : Code ν d r K R) : RealInput d → ℝ :=
  FiniteQuery.extensionOutput xs (2/(FiniteQuery.inputMesh ν r K R : ℝ)) c

def capacity (ν : CoordinateLaw) (d r K R : ℕ) : ℕ :=
  let M := FiniteQuery.compressedWidth d (FiniteQuery.queryBits ν d r K R) r K R
  let B := FiniteQuery.compressedBound ν d (FiniteQuery.queryBits ν d r K R) r K R
  robustParameterCount d M r*(2*realOutputMesh d M r B (6*R)+1)

theorem code_card_le_exp (ν : CoordinateLaw) (d r K R : ℕ) :
    (Fintype.card (Code ν d r K R) : ℝ)≤Real.exp (capacity ν d r K R) :=
  realOutputCode_card_le_exp _ _ _ _ _

def coverEvent (ν : CoordinateLaw) (d N r K R : ℕ)
    (xs : Cube (FiniteQuery.queryBits ν d r K R) → RealInput d)
    (X : Set (RealInput d)) : Set (Weights d N r) :=
  {w | ∃ c : Code ν d r K R,∀ x∈X,|output Real.tanh w x-codeOutput ν d r K R xs c x|≤2/(3*(R : ℝ))}

theorem isClosed_coverEvent (ν : CoordinateLaw) (d N r K R : ℕ)
    (xs : Cube (FiniteQuery.queryBits ν d r K R) → RealInput d) (X : Set (RealInput d)) :
    IsClosed (coverEvent ν d N r K R xs X) := by
  classical
  have he : coverEvent ν d N r K R xs X=⋃ c : Code ν d r K R,
      ⋂ x : RealInput d,⋂ _hx : x∈X,
        {w | |output Real.tanh w x-codeOutput ν d r K R xs c x|≤2/(3*(R : ℝ))} := by
    ext w
    simp[coverEvent]
  rw[he]
  apply isClosed_iUnion_of_finite
  intro c
  apply isClosed_iInter
  intro x
  apply isClosed_iInter
  intro hx
  exact isClosed_le ((continuous_output_weights tanh_continuous x).sub continuous_const).abs continuous_const

theorem goodWeights_mem_cover (ν : CoordinateLaw) {d N r K R : ℕ}
    (hd : 0<d) (hN : 0<N) (hK : 0<K) (hR : 0<R)
    (xs : Cube (FiniteQuery.queryBits ν d r K R) → RealInput d)
    (hxs : ∀ y,∑ j,xs y j^2≤1)
    (X : Set (RealInput d))
    (hnear : ∀ x∈X,∃ y,∀ j,|x j-xs y j|≤2/(FiniteQuery.inputMesh ν r K R : ℝ))
    (hNT : FiniteQuery.widthThreshold ν d r K R≤N) (z : Weights d N r)
    (hhidden : FiniteQuery.GoodHidden ν xs N r
      (fun s => (layerBudget r (2*FiniteQuery.regressionResource K R) (s+1) : ℝ)) (K : ℝ) z)
    (hinput : NonGaussianMeanField.weights z∈FiniteInput.goodWeights d N r K (FiniteInput.operatorBound ν K)) :
    NonGaussianMeanField.weights z∈coverEvent ν d N r K R xs X := by
  let J := FiniteQuery.regressionResource K R
  have hJ : 0<J := by dsimp[J,FiniteQuery.regressionResource]; positivity
  obtain ⟨hsize,herr⟩ := FiniteQuery.widthThreshold_budget ν hK hJ hNT
  obtain ⟨Γ,hΓ,hfirst,hcert⟩ := FiniteQuery.exists_covariance_certificates ν xs hN
    (fun s => (layerBudget r (2*J) (s+1) : ℝ)) (K : ℝ) (Nat.cast_nonneg K) r z
    (fun s _ => by exact_mod_cast layerBudget_pos r (show 0<2*J by omega) (s+1)) hsize herr hhidden
  obtain ⟨v,hv,he⟩ := FiniteQuery.exists_compressed_of_certificates ν xs hd hN hK hR
    (NonGaussianMeanField.weights z) Γ hinput.2.1 hΓ hfirst hcert
  obtain ⟨c,hc⟩ := exists_realGridOutput Real.tanh tanh_admissible
    (by
      unfold FiniteQuery.compressedBound mixedCompressedBound
      have : 0 < FiniteQuery.regressionResource K R := hJ
      omega) (by omega : 0<6*R) v hv
  refine ⟨c,?_⟩
  intro x hx
  obtain ⟨y,hselected,hclose⟩ := FiniteQuery.selectedPoint_spec xs _ x (hnear x hx)
  have hi := FiniteInput.output_input_stability hN Real.tanh tanh_admissible.2
    (NonGaussianMeanField.weights z) (Nat.cast_nonneg K) (Nat.cast_nonneg _) hinput
    (by positivity : 0≤2/(FiniteQuery.inputMesh ν r K R : ℝ)) x (xs y) hclose
  have hT := FiniteQuery.inputMesh_pos ν r hK hR
  have hTp : (0 : ℝ)<FiniteQuery.inputMesh ν r K R := by exact_mod_cast hT
  have hRR : (0 : ℝ)<R := by exact_mod_cast hR
  have hKR : (0 : ℝ)<K := by exact_mod_cast hK
  have hb : (0 : ℝ)<FiniteInput.operatorBound ν K := by
    have hq := NonGaussianMeanField.tailScale_ge_one ν
    unfold FiniteInput.operatorBound
    push_cast
    positivity
  have hid : (K : ℝ)*(FiniteInput.operatorBound ν K : ℝ)^r*(2/(FiniteQuery.inputMesh ν r K R : ℝ))=
      1/(6*(R : ℝ)) := by
    unfold FiniteQuery.inputMesh
    push_cast
    field_simp [ne_of_gt hKR, ne_of_gt hRR, ne_of_gt hb]
    <;> ring
  rw[hid] at hi
  have hg := hc (xs y) (hxs y)
  have hgy : |output Real.tanh v (xs y)-output Real.tanh (realGridWeights c) (xs y)|≤1/(6*(R : ℝ)) := by
    simpa only [Nat.cast_mul,Nat.cast_ofNat] using hg
  have hout : codeOutput ν d r K R xs c x=output Real.tanh (realGridWeights c) (xs y) := by
    simp only [codeOutput,FiniteQuery.extensionOutput,hselected]
  rw[hout]
  have ht := abs_sub_le (output Real.tanh (NonGaussianMeanField.weights z) x)
    (output Real.tanh (NonGaussianMeanField.weights z) (xs y)) (output Real.tanh (realGridWeights c) (xs y))
  have ht' := abs_sub_le (output Real.tanh (NonGaussianMeanField.weights z) (xs y))
    (output Real.tanh v (xs y)) (output Real.tanh (realGridWeights c) (xs y))
  have he' := he y
  have hsum : 1/(6*(R : ℝ))+1/(3*(R : ℝ))+1/(6*(R : ℝ))=2/(3*(R : ℝ)) := by ring
  linarith

theorem cover_complement_tail (ν : CoordinateLaw) {d N r K R : ℕ}
    (hd : 0<d) (hR : 0<R)
    (hK : 8*NonGaussianMeanField.tailScale ν*(d+1)≤K)
    (xs : Cube (FiniteQuery.queryBits ν d r K R) → RealInput d)
    (hxs : ∀ y,∑ j,xs y j^2≤1) (X : Set (RealInput d))
    (hnear : ∀ x∈X,∃ y,∀ j,|x j-xs y j|≤2/(FiniteQuery.inputMesh ν r K R : ℝ))
    (hNT : FiniteQuery.widthThreshold ν d r K R≤N) :
    (powerPrior ν d N r 1).real (coverEvent ν d N r K R xs X)ᶜ≤
      (3*(r : ℝ)+3)*Real.exp (-(N : ℝ)*(K : ℝ)/(8*(NonGaussianMeanField.tailScale ν : ℝ))) := by
  have hq := NonGaussianMeanField.tailScale_ge_one ν
  have hqn : 1≤NonGaussianMeanField.tailScale ν := by exact_mod_cast hq
  have hK4 : 4≤K := by nlinarith
  have hK0 : 0<K := by omega
  let J := FiniteQuery.regressionResource K R
  have hJ : 0<J := by dsimp[J,FiniteQuery.regressionResource]; positivity
  have hN : 0<N := (NonGaussianMeanField.widthThreshold_pos ν _ r J).trans_le hNT
  let G : ℕ → ℝ := fun s => (layerBudget r (2*J) (s+1) : ℝ)
  let H : Set (Weights d N r) := {z | ¬FiniteQuery.GoodHidden ν xs N r G (K : ℝ) z}
  let I : Set (Weights d N r) := {z | NonGaussianMeanField.weights z∉
    FiniteInput.goodWeights d N r K (FiniteInput.operatorBound ν K)}
  have hH := FiniteQuery.goodHidden_compl_tail ν (r := r) xs (FiniteQuery.queryBits_pos ν d r K R) hN
    (sparseCount_pos r (2*J)) G (K : ℝ) (by exact_mod_cast hK4)
    (fun s _ => by dsimp[G]; exact_mod_cast layerBudget_pos r (show 0<2*J by omega) (s+1))
    (fun s _ => layerBudget_sq_le_twice_sparseCount r (2*J) (show 1≤s+1 by omega))
    (FiniteQuery.widthThreshold_entropy ν hK4 hNT)
  have hI := FiniteInput.goodWeights_complement_tail ν (r := r) hd hN hK
  have hsub : NonGaussianMeanField.weights ⁻¹' (coverEvent ν d N r K R xs X)ᶜ⊆H∪I := by
    intro z hz
    by_contra hn
    have hh : z∉H ∧ z∉I := not_or.mp hn
    exact hz (goodWeights_mem_cover ν hd hN hK0 hR xs hxs X hnear hNT z
      (not_not.mp hh.1) (not_not.mp hh.2))
  rw[←NonGaussianMeanField.map_weights_eq_powerPrior ν d N r,Measure.real,
    Measure.map_apply (NonGaussianMeanField.continuous_weights d N r).measurable
      (isClosed_coverEvent ν d N r K R xs X).measurableSet.compl]
  apply (measureReal_mono (μ := rawPrior ν d N r) hsub).trans
  apply (measureReal_union_le H I).trans
  have hexp : Real.exp (-(N : ℝ)*(K : ℝ)/8)≤
      Real.exp (-(N : ℝ)*(K : ℝ)/(8*(NonGaussianMeanField.tailScale ν : ℝ))) := by
    apply Real.exp_le_exp.mpr
    have hh := div_le_div_of_nonneg_left (show 0≤(N : ℝ)*(K : ℝ) by positivity)
      (by norm_num : (0 : ℝ)<8) (show (8 : ℝ)≤8*(NonGaussianMeanField.tailScale ν : ℝ) by linarith)
    simpa only [neg_mul,neg_div,neg_le_neg_iff] using hh
  have hH' := hH.trans (mul_le_mul_of_nonneg_left hexp (by positivity : (0 : ℝ)≤r+1))
  change (rawPrior ν d N r).real H≤_ at hH'
  change (rawPrior ν d N r).real I≤_ at hI
  nlinarith

end NeuralGeneralization.BatchTwoContinuous.FiniteMeanField
