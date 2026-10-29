import PhysicalCompressionIndex
import PhysicalSharpTangent
import TwoBallMixedGain

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch

variable {I:ℕ→Type*} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K X:Type*} [Fintype K]
variable {anchors:∀j,K→EuclideanSpace ℝ (I j)} {D:ℕ→ℝ} {H:ℕ}

def sharpFiniteGain (t:ℝ) (D:ℕ→ℝ) (j:ℕ) : ℝ := t*Real.sqrt (gaussianEntropyGain (D j))
def sharpFiniteProduct (t:ℝ) (D:ℕ→ℝ) (n:ℕ) : ℝ := ∏j∈Finset.range n,sharpFiniteGain t D j

theorem sharpFiniteGain_pos {t:ℝ} (ht:0<t) (D:ℕ→ℝ) (j:ℕ) : 0<sharpFiniteGain t D j :=
  mul_pos ht (Real.sqrt_pos.mpr ((by norm_num : (0:ℝ)<1).trans_le (gaussianEntropyGain_one_le _)))
theorem sharpFiniteProduct_pos {t:ℝ} (ht:0<t) (D:ℕ→ℝ) (j:ℕ) : 0<sharpFiniteProduct t D j :=
  Finset.prod_pos fun k _=>sharpFiniteGain_pos ht D k
@[simp] theorem sharpFiniteProduct_zero (t:ℝ) (D:ℕ→ℝ) : sharpFiniteProduct t D 0=1 := by
  simp [sharpFiniteProduct]
theorem sharpFiniteProduct_succ (t:ℝ) (D:ℕ→ℝ) (j:ℕ) :
    sharpFiniteProduct t D (j+1)=sharpFiniteProduct t D j*sharpFiniteGain t D j :=
  Finset.prod_range_succ _ j

def finiteNormalizedState (t:ℝ) (D:ℕ→ℝ) (u:∀j,X→EuclideanSpace ℝ (I j))
    (j:ℕ) (x:X) : EuclideanSpace ℝ (I j) := (sharpFiniteProduct t D j)⁻¹ • u j x

def finiteNormalizedMap
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (t:ℝ) (j:ℕ) (x:EuclideanSpace ℝ (I j)) : EuclideanSpace ℝ (I (j+1)) :=
  if hj:j<H then (sharpFiniteProduct t D (j+1))⁻¹ •
    (M j hj).value (t • (sharpFiniteProduct t D j • x)) else 0

theorem finiteNormalizedMap_recurrence
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t:ℝ} (ht:0<t) (u:∀j,X→EuclideanSpace ℝ (I j))
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (j:ℕ) (hj:j<H) (x:X) :
    finiteNormalizedState t D u (j+1) x=
      finiteNormalizedMap M t j (finiteNormalizedState t D u j x) := by
  simp only [finiteNormalizedState,finiteNormalizedMap,dif_pos hj,smul_smul,
    mul_inv_cancel₀ (sharpFiniteProduct_pos ht D j).ne',one_smul,hrec j hj]

theorem finiteCanonical_dimension_lower
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (hcard:2≤Fintype.card (I 0)) : ∀j≤H,2≤Fintype.card (I j) := by
  intro j
  induction j with
  | zero => intro _; exact hcard
  | succ j ih => intro hj; exact (ih (by omega)).trans (M j (by omega)).dimension_mono

theorem actual_normalized_two_ball_prefix
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (hcard:2≤Fintype.card (I 0))
    {t a:ℝ} (ht:0<t) (ha:0<a) (hta:t^2*(a+1)=1)
    (u:∀j,X→EuclideanSpace ℝ (I j))
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    {R:ℝ} (hR:0≤R) (hu:∀x,‖u 0 x‖≤R) :
    ∃b:ℕ→ℝ,(∀j<H,0<b j ∧ Real.log (b j)≤
        (D j-twoBallEntropyBaseline a-twoBallEntropyGap a)/a) ∧
      ∀J≤H,ActualBallCover (Set.range (finiteNormalizedState t D u J)) (2^J)
        (2*R*∏j∈Finset.range J,b j/sharpFiniteGain t D j) := by
  classical
  have hex (j:ℕ) (hj:j<H) := (M j hj).exists_normalized_two_ball_factor
    (finiteCanonical_dimension_lower M hcard j hj.le) ht ha hta
    (sharpFiniteProduct_pos ht D j) (sharpFiniteGain_pos ht D j)
  let b:ℕ→ℝ := fun j=>if hj:j<H then Classical.choose (hex j hj) else 1
  have hb (j:ℕ) (hj:j<H) : 0<b j ∧ Real.log (b j)≤
        (D j-twoBallEntropyBaseline a-twoBallEntropyGap a)/a ∧
      ∀z:EuclideanSpace ℝ (I j),∀r:ℝ,0≤r→
        FiniteBallCover (finiteNormalizedMap M t j '' Metric.closedBall z r) 2
          (r*(b j/sharpFiniteGain t D j)) := by
    have hh := Classical.choose_spec (hex j hj)
    simpa only [b,dif_pos hj,finiteNormalizedMap,sharpFiniteProduct_succ] using hh
  refine ⟨b,fun j hj=>⟨(hb j hj).1,(hb j hj).2.1⟩,?_⟩
  intro J hJ
  apply external_two_ball_actual_prefix
    (fun j=>Set.range (finiteNormalizedState t D u j)) (finiteNormalizedMap M t)
    (fun j=>b j/sharpFiniteGain t D j) R J hR
    (fun j hj=>div_nonneg (hb j (lt_of_lt_of_le hj hJ)).1.le (sharpFiniteGain_pos ht D j).le)
  · intro j hj
    have he : finiteNormalizedState t D u (j+1)=
        finiteNormalizedMap M t j ∘ finiteNormalizedState t D u j := by
      funext x
      exact finiteNormalizedMap_recurrence M ht u hrec j (lt_of_lt_of_le hj hJ) x
    rw [he,Set.range_comp]
  · refine ⟨{0},by simp,?_⟩
    rintro y ⟨x,rfl⟩
    refine ⟨0,by simp,?_⟩
    simpa only [finiteNormalizedState,sharpFiniteProduct_zero,inv_one,one_smul,dist_zero_right] using hu x
  · intro j hj z r hr
    exact (hb j (lt_of_lt_of_le hj hJ)).2.2 z r hr

#print axioms actual_normalized_two_ball_prefix
end ConditionalNonpolynomial.Analytic
