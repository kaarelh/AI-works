import NeuralGeneralization.BatchTwoManuscriptResources
import NeuralGeneralization.RobustCompressionGridPadding

/-! A measurable finite grid with the literal real weight bound and literal J.
No integer rounding of the manuscript's weight or error resources is used. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open MeasureTheory
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel ParameterGrid

def gridSensitivity (p : Input) : ℝ := ((p.dimension:ℝ)+p.depth+1)*
  (2*(widthBound p:ℝ)*(weightBound p+1))^p.depth

def gridMesh (p : Input) : ℕ := ⌈16*weightBound p*gridSensitivity p/p.radius⌉₊

abbrev GridCode (p : Input) := WeightIndex p.dimension (widthBound p) (p.depth-2)→GridInt (gridMesh p)

def gridWeights (p : Input) (q : GridCode p) : Weights p.dimension (widthBound p) (p.depth-2) :=
  fun i=>weightBound p*decode (gridMesh p) q i

def gridOutput (p : Input) (φ : ℝ→ℝ) (q : GridCode p) : Cube p.dimension→ℝ :=
  networkOutput φ (gridWeights p q)

def roundCode (p : Input) (w : Weights p.dimension (widthBound p) (p.depth-2)) : GridCode p :=
  fun i=>roundUnitGrid (gridMesh p) (w i/weightBound p)

def padRoundCode (p : Input) {N : ℕ} (hN : N≤widthBound p)
    (w : Weights p.dimension N (p.depth-2)) : GridCode p := roundCode p (widthPaddedWeights hN w)

theorem weightBound_ge_one (p : Input) : 1≤weightBound p := le_max_right _ _
theorem weightBound_pos (p : Input) : 0<weightBound p := zero_lt_one.trans_le (weightBound_ge_one p)
theorem gridSensitivity_pos (p : Input) : 0<gridSensitivity p := by
  unfold gridSensitivity
  have := weightBound_pos p
  have hn : (0:ℝ)<widthBound p := Nat.cast_pos.mpr (widthBound_pos p)
  positivity

theorem gridMesh_pos (p : Input) : 0<gridMesh p := by
  apply Nat.ceil_pos.mpr
  exact div_pos (mul_pos (mul_pos (by norm_num) (weightBound_pos p)) (gridSensitivity_pos p)) p.radius_pos

theorem hiddenSensitivity_real_bound (d M r : ℕ) {B : ℝ} (hB : 0≤B) :
    hiddenSensitivity d M B r≤((d:ℝ)+1)*((M:ℝ)*(B+1)+1)^r := by
  induction r with
  | zero => simp [hiddenSensitivity]
  | succ r ih =>
    let X := ((d:ℝ)+1)*((M:ℝ)*(B+1)+1)^r
    have hbase : 1≤(M:ℝ)*(B+1)+1 := by have := Nat.cast_nonneg (α:=ℝ) M; nlinarith
    have hX : 1≤X := one_le_mul_of_one_le_of_one_le (by have := Nat.cast_nonneg (α:=ℝ) d; linarith) (one_le_pow₀ hbase)
    change nextSensitivity M B (hiddenSensitivity d M B r)≤_
    calc
      _≤(M:ℝ)*(1+B*X) := mul_le_mul_of_nonneg_left (add_le_add le_rfl (mul_le_mul_of_nonneg_left ih hB)) (Nat.cast_nonneg M)
      _≤((M:ℝ)*(B+1)+1)*X := by
        have hh := mul_le_mul_of_nonneg_left (show 1≤X from hX) (Nat.cast_nonneg (α:=ℝ) M)
        nlinarith
      _=_ := by dsimp [X]; rw [pow_succ]; ring

theorem sensitivity_allocation (p : Input) :
    nextSensitivity (widthBound p) (weightBound p)
      (hiddenSensitivity p.dimension (widthBound p) (weightBound p) (p.depth-2))≤gridSensitivity p := by
  let Z := 2*(widthBound p:ℝ)*(weightBound p+1)
  have hM : (1:ℝ)≤widthBound p := by exact_mod_cast widthBound_pos p
  have hB := weightBound_ge_one p
  have hA : 0≤(widthBound p:ℝ)*(weightBound p+1)+1 := by positivity
  have hAZ : (widthBound p:ℝ)*(weightBound p+1)+1≤Z := by dsimp [Z]; nlinarith
  have hZ : 1≤Z := by dsimp [Z]; nlinarith
  have hh := hiddenSensitivity_real_bound p.dimension (widthBound p) (p.depth-2+1) (weightBound_pos p).le
  change nextSensitivity _ _ (hiddenSensitivity _ _ _ _)≤_ at hh
  have hj : p.depth-2+1≤p.depth := by have := p.depth_ge_two; omega
  have hd : (p.dimension:ℝ)+1≤(p.dimension:ℝ)+p.depth+1 := by have := Nat.cast_nonneg (α:=ℝ) p.depth; linarith
  exact hh.trans ((mul_le_mul_of_nonneg_left (pow_le_pow_left₀ hA hAZ _) (by positivity)).trans
    (mul_le_mul hd (pow_le_pow_right₀ hZ hj) (by positivity) (by positivity)))

theorem gridWeights_bounded (p : Input) (q : GridCode p) : boundedWeights (weightBound p) (gridWeights p q) := by
  intro i
  unfold gridWeights
  rw [abs_mul,abs_of_pos (weightBound_pos p)]
  exact (mul_le_mul_of_nonneg_left (decode_abs_le_one _ (gridMesh_pos p) q i) (weightBound_pos p).le).trans_eq (mul_one _)

@[fun_prop] theorem measurable_roundCode (p : Input) : Measurable (roundCode p) := by
  apply measurable_pi_lambda
  intro i
  exact (measurable_roundUnitGrid _).comp ((measurable_pi_apply i).div_const _)

@[fun_prop] theorem measurable_padRoundCode (p : Input) {N : ℕ} (hN : N≤widthBound p) :
    Measurable (padRoundCode p hN) := (measurable_roundCode p).comp (measurable_widthPaddedWeights hN)

theorem roundCode_weights_close (p : Input)
    (w : Weights p.dimension (widthBound p) (p.depth-2)) (hw : boundedWeights (weightBound p) w)
    (i : WeightIndex p.dimension (widthBound p) (p.depth-2)) :
    |w i-gridWeights p (roundCode p w) i|≤weightBound p/(gridMesh p:ℝ) := by
  have hB := weightBound_pos p
  have hx : |w i/weightBound p|≤1 := by rw [abs_div,abs_of_pos hB]; exact (div_le_one hB).mpr (hw i)
  have hh := mul_le_mul_of_nonneg_left (roundUnitGrid_close _ (gridMesh_pos p) (w i/weightBound p) hx) hB.le
  have he : w i-gridWeights p (roundCode p w) i=weightBound p*(w i/weightBound p-
      ((roundUnitGrid (gridMesh p) (w i/weightBound p)).val:ℝ)/(gridMesh p:ℝ)) := by
    unfold gridWeights roundCode decode
    field_simp
  rw [he,abs_mul,abs_of_pos hB]
  simpa only [mul_one_div] using hh

theorem roundCode_output_close (p : Input) {φ : ℝ→ℝ} (hφ : admissibleActivation φ)
    (w : Weights p.dimension (widthBound p) (p.depth-2)) (hw : boundedWeights (weightBound p) w)
    (x : Cube p.dimension) : |networkOutput φ w x-gridOutput p φ (roundCode p w) x|≤p.radius/16 := by
  have hb := weightBound_pos p
  have hm : (0:ℝ)<gridMesh p := Nat.cast_pos.mpr (gridMesh_pos p)
  have ht := networkOutput_parameter_stability φ hφ w (gridWeights p (roundCode p w))
    (weightBound p) (weightBound p/(gridMesh p:ℝ)) hb.le (by positivity)
    (gridWeights_bounded p _) (roundCode_weights_close p w hw) x
  apply ht.trans
  apply (mul_le_mul_of_nonneg_left (sensitivity_allocation p) (by positivity : 0≤weightBound p/(gridMesh p:ℝ))).trans
  have hh := Nat.le_ceil (16*weightBound p*gridSensitivity p/p.radius)
  change 16*weightBound p*gridSensitivity p/p.radius≤(gridMesh p:ℝ) at hh
  have hh' := (div_le_iff₀ p.radius_pos).mp hh
  apply (le_div_iff₀ (by norm_num : (0:ℝ)<16)).mpr
  rw [div_mul_eq_mul_div,div_mul_eq_mul_div]
  apply (div_le_iff₀ hm).mpr
  nlinarith only [hh']

theorem padRoundCode_output_close (p : Input) {N : ℕ} (hN : N≤widthBound p)
    {φ : ℝ→ℝ} (hφ : admissibleActivation φ) (w : Weights p.dimension N (p.depth-2))
    (hw : boundedWeights (weightBound p) w) (x : Cube p.dimension) :
    |networkOutput φ w x-gridOutput p φ (padRoundCode p hN w) x|≤p.radius/16 := by
  simpa only [padRoundCode,networkOutput_widthPaddedWeights] using
    roundCode_output_close p hφ (widthPaddedWeights hN w) (widthPaddedWeights_bounded hN (weightBound_pos p).le w hw) x

theorem gridCode_log_card_le (p : Input) : Real.log (Fintype.card (GridCode p):ℝ)≤gridEntropy p := by
  have hc : Fintype.card (WeightIndex p.dimension (widthBound p) (p.depth-2))=
      parameterCount p.dimension (widthBound p) p.depth := by
    simp [WeightIndex,parameterCount,pow_two,Nat.mul_assoc,Nat.add_assoc]
  have hmesh : (gridMesh p:ℝ)<16*weightBound p*gridSensitivity p/p.radius+1 :=
    Nat.ceil_lt_add_one (by have := weightBound_pos p; have := gridSensitivity_pos p; have := p.radius_pos; positivity)
  change Real.log (Fintype.card (WeightIndex p.dimension (widthBound p) (p.depth-2)→GridInt (gridMesh p)):ℝ)≤_
  rw [Fintype.card_fun,gridInt_card,hc]
  push_cast
  rw [Real.log_pow]
  unfold gridEntropy
  apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg _)
  apply Real.log_le_log (by positivity)
  dsimp [gridSensitivity] at hmesh
  ring_nf at hmesh ⊢
  linarith only [hmesh]

end NeuralGeneralization.BatchTwoManuscriptResources
