import NeuralGeneralization.BatchTwoContinuousInputStability
import NeuralGeneralization.CylinderStability

/-! Width-independent input Lipschitz bounds using endpoint energy and internal
operator bounds, without a bound on the bulk Frobenius energy. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteInput
open ConcreteModel CompressionSampling Compression
variable {d N r : ℕ}

def goodWeights (d N r : ℕ) (K b : ℝ) : Set (Weights d N r) :=
  {w | (d : ℝ)/N*(∑ i,∑ j,w (.inl (i,j))^2)≤K ∧
    (N : ℝ)*(∑ i,w (.inr (.inr i))^2)≤K ∧
    ∀ s, matrixActionBound (fun i j => w (.inr (.inl (s,i,j)))) b}

theorem isClosed_goodWeights (d N r : ℕ) (K b : ℝ) : IsClosed (goodWeights d N r K b) := by
  unfold goodWeights matrixActionBound
  simp only [Set.setOf_and,Set.setOf_forall]
  apply IsClosed.inter (isClosed_le (by fun_prop) continuous_const)
  apply IsClosed.inter (isClosed_le (by fun_prop) continuous_const)
  apply isClosed_iInter
  intro s
  apply isClosed_iInter
  intro z
  exact isClosed_le (by fun_prop) continuous_const

theorem firstHidden_distance (hN : 0<N) (φ : ℝ → ℝ)
    (hφ : ∀ t s,|φ t-φ s|≤|t-s|) (w : Weights d N r) {K η : ℝ}
    (hfirst : (d : ℝ)/N*(∑ i,∑ j,w (.inl (i,j))^2)≤K) (hη : 0≤η)
    (x y : RealInput d) (hxy : ∀ i,|x i-y i|≤η) :
    squaredDistance (firstHidden φ w x) (firstHidden φ w y)≤(N : ℝ)*K*η^2 := by
  let v : Weights d N r := fun a => match a with
    | .inl ij => w (.inl ij)
    | .inr _ => 0
  have hv : weightedSquaredNorm v≤K := by
    simpa only [weightedSquaredNorm,v,zero_pow (by omega : 2≠0),Finset.sum_const_zero,
      mul_zero,add_zero] using hfirst
  exact firstHidden_input_distance hN φ hφ v hv hη x y hxy

theorem hiddenStep_distance (φ : ℝ → ℝ) (hφ : ∀ t s,|φ t-φ s|≤|t-s|)
    (w : Weights d N r) (b : ℝ) (s : Fin r)
    (hbound : matrixActionBound (fun i j => w (.inr (.inl (s,i,j)))) b) (u v : Fin N → ℝ) :
    squaredDistance (hiddenStep φ w u s) (hiddenStep φ w v s)≤b^2*squaredDistance u v := by
  apply (lipschitz_activation_squaredDistance φ hφ _ _).trans
  have he : (fun i => (∑ j,w (.inr (.inl (s,i,j)))*u j)-(∑ j,w (.inr (.inl (s,i,j)))*v j))=
      (fun i => ∑ j,w (.inr (.inl (s,i,j)))*(u j-v j)) := by
    funext i
    simp only [mul_sub,Finset.sum_sub_distrib]
  unfold squaredDistance
  rw [show (∑ i, ((∑ j,w (.inr (.inl (s,i,j)))*u j)-(∑ j,w (.inr (.inl (s,i,j)))*v j))^2)=
    ∑ i,(∑ j,w (.inr (.inl (s,i,j)))*(u j-v j))^2 by simp only [mul_sub,Finset.sum_sub_distrib]]
  exact hbound (fun i => u i-v i)

theorem hiddenFold_distance (φ : ℝ → ℝ) (hφ : ∀ t s,|φ t-φ s|≤|t-s|)
    (w : Weights d N r) (b : ℝ)
    (hbound : ∀ s,matrixActionBound (fun i j => w (.inr (.inl (s,i,j)))) b)
    (ss : List (Fin r)) (u v : Fin N → ℝ) :
    squaredDistance (ss.foldl (hiddenStep φ w) u) (ss.foldl (hiddenStep φ w) v)≤
      (b^2)^ss.length*squaredDistance u v := by
  induction ss generalizing u v with
  | nil => simp
  | cons s ss ih =>
    simp only [List.foldl_cons,List.length_cons]
    apply (ih _ _).trans
    have hh := mul_le_mul_of_nonneg_left (hiddenStep_distance φ hφ w b s (hbound s) u v)
      (pow_nonneg (sq_nonneg b) ss.length)
    simpa only [pow_succ,mul_assoc] using hh

theorem output_input_stability (hN : 0<N) (φ : ℝ → ℝ)
    (hφ : ∀ t s,|φ t-φ s|≤|t-s|) (w : Weights d N r) {K b η : ℝ}
    (hK : 0≤K) (hb : 0≤b) (hgood : w∈goodWeights d N r K b) (hη : 0≤η)
    (x y : RealInput d) (hxy : ∀ i,|x i-y i|≤η) :
    |output φ w x-output φ w y|≤K*b^r*η := by
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  have hread : (∑ i,w (.inr (.inr i))^2)≤K/(N : ℝ) := by
    apply (le_div_iff₀ hNR).mpr
    simpa only [mul_comm] using hgood.2.1
  have hf := firstHidden_distance hN φ hφ w hgood.1 hη x y hxy
  have hh := hiddenFold_distance φ hφ w b hgood.2.2 (List.finRange r) (firstHidden φ w x) (firstHidden φ w y)
  simp only [List.length_finRange] at hh
  have hh' := hh.trans (mul_le_mul_of_nonneg_left hf (pow_nonneg (sq_nonneg b) _))
  have hr := (readout_squaredDistance_le (fun i => w (.inr (.inr i)))
    (finalHidden φ w x) (finalHidden φ w y)).trans
    (mul_le_mul hread hh' (by positivity) (div_nonneg hK hNR.le))
  have he : K/(N : ℝ)*((b^2)^r*((N : ℝ)*K*η^2))=(K*b^r*η)^2 := by
    rw [mul_pow,mul_pow,←pow_mul,←pow_mul]
    field_simp
    <;> ring
  rw [he] at hr
  exact abs_le_of_sq_le_sq hr (by positivity)

end NeuralGeneralization.BatchTwoContinuous.FiniteInput
