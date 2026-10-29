import RadialHilbertContraction
import NonexpansiveGridChain
import BooleanGridInput

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup
variable {I:ℕ→Type*} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K:Type*} [Fintype K]
variable {anchors:∀j,K→EuclideanSpace ℝ (I j)} {D:ℕ→ℝ} {H:ℕ}

def clippedFiniteMap
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (t:ℝ) (j:ℕ) (x:EuclideanSpace ℝ (I j)) : EuclideanSpace ℝ (I (j+1)) :=
  finiteNormalizedMap M t j (radialClip 2 x)

theorem clippedFiniteMap_gainClipped
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (t:ℝ) (j:ℕ) (hj:j<H) :
    clippedFiniteMap M t j=(M j hj).gainClippedValue
      (t*sharpFiniteProduct t D j) (Real.sqrt (gaussianEntropyGain (D j))) := by
  funext x
  simp only [clippedFiniteMap,finiteNormalizedMap,dif_pos hj,
    CanonicalLayerModel.gainClippedValue,sharpFiniteProduct_succ,sharpFiniteGain,smul_smul]
  congr 2 <;> ring

theorem clippedFiniteMap_nonexpansive
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (j:ℕ) (x y:EuclideanSpace ℝ (I j)) :
    ‖clippedFiniteMap M t j x-clippedFiniteMap M t j y‖≤‖x-y‖ :=
  (finiteNormalizedMap_nonexpansive M ht j _ _).trans
    (radialClip_hilbert_contraction (by norm_num) x y)

theorem clippedFiniteMap_actual_chain {X:Type*}
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (u:∀j,X→EuclideanSpace ℝ (I j))
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (hu:∀x,‖u 0 x‖≤2) :
    ∀j≤H,∀x,nonexpansiveRealChain (clippedFiniteMap M t) j (u 0 x)=
      finiteNormalizedState t D u j x := by
  intro j
  induction j with
  | zero=>intro _ x;simp only [nonexpansiveRealChain,finiteNormalizedState,sharpFiniteProduct_zero,inv_one,one_smul,id_eq]
  | succ j ih=>
    intro hj x
    rw [nonexpansiveRealChain,Function.comp_apply,ih (by omega),
      finiteNormalizedMap_recurrence M ht u hrec j (by omega)]
    unfold clippedFiniteMap
    rw [radialClip_eq_self (by norm_num) (finiteNormalizedState_norm M ht u hrec hu j (by omega) x)]

theorem exists_normalized_prefix_grid {d:ℕ}
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (u:∀j,Input d→EuclideanSpace ℝ (I j))
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (hu:∀x,‖u 0 x‖≤2)
    (sources:I 0→BooleanInputSource d) (hsource:∀x i,(sources i).eval x=u 0 x i)
    (J Q:ℕ) (hJ:J≤H) {δ R:ℝ} (hδ:0<δ) (hδ1:δ≤1) (hR:2≤R)
    (hdim:∀j≤J,(Fintype.card (I j):ℝ)≤R)
    (hrank:∀j (hj:j<J),((M j (lt_of_lt_of_le hj hJ)).gainRank:ℝ)≤R)
    (hi:δ⁻¹≤R) (hQ:0<Q) (hQup:(Q:ℝ)≤R^4) (hQlow:2*(R+1)/δ≤(Q:ℝ)) :
    ∃c:CircuitMap d (Fintype.card (I J)*Fintype.card (ScalarGrid Q 3)),
      c.depth≤1+J*80 ∧
      c.size≤3*(Fintype.card (I 0)*Fintype.card (ScalarGrid Q 3))+J*⌈R^gainGridSizeExponent⌉₊ ∧
      ∀x,∃b:I J→ScalarCode Q 3,
        c.eval x=encodeCoordinateState Q 3 b ∧
        ‖finiteNormalizedState t D u J x-decodeCoordinates Q 3 b‖≤
          (J:ℝ)*δ+((Fintype.card (I 0):ℝ)+1)/(2*(Q:ℝ)) := by
  classical
  have hex (j:ℕ) (hj:j<J) :
      ∃c:CircuitMap (Fintype.card (I j)*Fintype.card (ScalarGrid Q 3))
        (Fintype.card (I (j+1))*Fintype.card (ScalarGrid Q 3)),
        c.depth≤80 ∧ (c.size:ℝ)≤R^gainGridSizeExponent ∧
        GridApproximates Q 3 Q 3 (clippedFiniteMap M t j) c δ := by
    have hα:Real.sqrt (gaussianEntropyGain ((klDiv (M j (by omega)).law
        (NeuralGeneralization.GaussianAngularFields.standardLaw (I j))).toReal))≤
        Real.sqrt (gaussianEntropyGain (D j)) :=
      Real.sqrt_le_sqrt (gaussianEntropyGain_mono ENNReal.toReal_nonneg (M j (by omega)).cost_le)
    have hql:2*((Fintype.card (I (j+1)):ℝ)+1)/δ≤(Q:ℝ) :=
      (div_le_div_of_nonneg_right (by linarith [hdim (j+1) (by omega)]) hδ.le).trans hQlow
    obtain ⟨c,hc⟩:=(M j (lt_of_lt_of_le hj hJ)).exists_gainClipped_grid Q
      (mul_pos ht (sharpFiniteProduct_pos ht D j)) hα hδ hδ1 hR
      (hdim j (by omega)) (hdim (j+1) (by omega)) (hrank j hj) hi hQ hQup hql
    refine ⟨c,hc.1,hc.2.1,?_⟩
    rw [clippedFiniteMap_gainClipped M t j (lt_of_lt_of_le hj hJ)]
    exact hc.2.2
  let rows:=fun j=>if hj:j<J then Classical.choose (hex j hj)
    else CircuitMap.ofCircuits (fun _=>constantCircuit _ false)
  have hrows (j:ℕ) (hj:j<J) :
      (rows j).depth≤80 ∧ ((rows j).size:ℝ)≤R^gainGridSizeExponent ∧
      GridApproximates Q 3 Q 3 (clippedFiniteMap M t j) (rows j) δ := by
    simpa only [rows,dif_pos hj] using Classical.choose_spec (hex j hj)
  let initial:=booleanGridInput Q 3 sources
  let chain:=nonexpansiveGridChain Q 3 rows J
  refine ⟨initial.then chain,?_,?_,?_⟩
  · have hh:=(nonexpansiveGridChain_resources Q 3 rows J ⌈R^gainGridSizeExponent⌉₊ 80
      (fun j hj=>by exact_mod_cast (hrows j hj).2.1.trans (Nat.le_ceil _))
      (fun j hj=>(hrows j hj).1) J le_rfl).2
    exact (CircuitMap.depth_then initial chain).trans (add_le_add (booleanGridInput_depth Q 3 sources) hh)
  · have hh:=(nonexpansiveGridChain_resources Q 3 rows J ⌈R^gainGridSizeExponent⌉₊ 80
      (fun j hj=>by exact_mod_cast (hrows j hj).2.1.trans (Nat.le_ceil _))
      (fun j hj=>(hrows j hj).1) J le_rfl).1
    rw [CircuitMap.size_then]
    exact add_le_add (booleanGridInput_size Q 3 sources) hh
  · intro x
    let a:I 0→ScalarCode Q 3:=fun i=>scalarEncode Q 3 ((sources i).eval x)
    have ha:‖u 0 x-decodeCoordinates Q 3 a‖≤((Fintype.card (I 0):ℝ)+1)/(2*(Q:ℝ)) := by
      have hh:=euclidean_norm_of_coordinate_bounds (u 0 x-decodeCoordinates Q 3 a)
        (show 0≤1/(2*(Q:ℝ)) by positivity) (by
          intro i
          have hb:|u 0 x i|≤(3:ℝ) := (PiLp.norm_apply_le (u 0 x) i).trans ((hu x).trans (by norm_num))
          simpa only [a,hsource,PiLp.sub_apply,decodeCoordinates,WithLp.ofLp_toLp] using
            scalarEncode_error Q 3 hQ (u 0 x i) hb)
      convert hh using 1 <;> ring
    have happ:=nonexpansiveGridChain_approximates Q 3 rows (clippedFiniteMap M t) (fun _=>δ) J
      (fun j hj=>(hrows j hj).2.2) (fun j _ x y=>clippedFiniteMap_nonexpansive M ht j x y) J le_rfl
    obtain ⟨b,hb,herr⟩:=happ a
    refine ⟨b,?_,?_⟩
    · rw [CircuitMap.eval_then,booleanGridInput_eval]
      exact hb
    · have ht1:=nonexpansiveRealChain_norm (clippedFiniteMap M t) J
        (fun j _ x y=>clippedFiniteMap_nonexpansive M ht j x y) J le_rfl (u 0 x)
        (decodeCoordinates Q 3 a)
      rw [clippedFiniteMap_actual_chain M ht u hrec hu J hJ x] at ht1
      have ht2:=dist_triangle (finiteNormalizedState t D u J x)
        (nonexpansiveRealChain (clippedFiniteMap M t) J (decodeCoordinates Q 3 a))
        (decodeCoordinates Q 3 b)
      simp only [dist_eq_norm] at ht2
      have hs: (∑j∈Finset.range J,δ)=(J:ℝ)*δ := by simp
      rw [hs] at herr
      linarith [ht1.trans ha]

#print axioms exists_normalized_prefix_grid
end ConditionalNonpolynomial.Analytic
