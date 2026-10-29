import PhysicalTwoBallCover
import CanonicalGaussianPolar

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch

theorem normalized_ball_cover {E F:Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (f:E→F) (M:ℕ) {b S T:ℝ} (hS:0<S) (hT:0<T)
    (hcover:∀z:E,∀r:ℝ,0≤r→FiniteBallCover (f '' Metric.closedBall z r) M (r*b))
    (z:E) (r:ℝ) (hr:0≤r) :
    FiniteBallCover ((fun x=>T⁻¹ • f (S • x)) '' Metric.closedBall z r) M
      (r*(S/T*b)) := by
  classical
  obtain ⟨C,hcard,hC⟩ := hcover (S • z) (S*r) (mul_nonneg hS.le hr)
  refine ⟨C.image (fun c=>T⁻¹ • c),Finset.card_image_le.trans hcard,?_⟩
  rintro y ⟨x,hx,rfl⟩
  have hx' : S • x∈Metric.closedBall (S • z) (S*r) := by
    rw [Metric.mem_closedBall,dist_eq_norm,←smul_sub,norm_smul,
      Real.norm_eq_abs,abs_of_pos hS]
    exact mul_le_mul_of_nonneg_left (by simpa only [Metric.mem_closedBall,dist_eq_norm] using hx) hS.le
  obtain ⟨c,hc,hxc⟩ := hC (f (S • x)) ⟨S • x,hx',rfl⟩
  refine ⟨T⁻¹ • c,Finset.mem_image_of_mem _ hc,?_⟩
  rw [dist_eq_norm,←smul_sub,norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hT]
  have hh := mul_le_mul_of_nonneg_left hxc (inv_nonneg.mpr hT.le)
  rw [dist_eq_norm] at hh
  convert hh using 1 <;> first | rfl | ring

namespace CanonicalLayerModel
variable {I J A:Type*} [Fintype I] [DecidableEq I] [Fintype J] [Fintype A]
variable {anchors:A→EuclideanSpace ℝ I} {D:ℝ}

theorem dimension_mono (M:CanonicalLayerModel (J:=J) anchors D) :
    Fintype.card I≤Fintype.card J := by
  obtain ⟨U,_⟩ := canonicalGaussianLinear_polar M.law M.finiteKL anchors
  let V := M.output.comp U
  have hh := LinearMap.finrank_le_finrank_of_injective (f:=V.toLinearMap) V.injective
  simpa only [finrank_euclideanSpace] using hh

theorem exists_normalized_two_ball_factor
    (M:CanonicalLayerModel (J:=J) anchors D) (hcard:2≤Fintype.card I)
    {t a S α:ℝ} (ht:0<t) (ha:0<a) (hta:t^2*(a+1)=1)
    (hS:0<S) (hα:0<α) :
    ∃b:ℝ,0<b ∧
      Real.log b≤(D-twoBallEntropyBaseline a-twoBallEntropyGap a)/a ∧
      ∀z:EuclideanSpace ℝ I,∀r:ℝ,0≤r→
        FiniteBallCover ((fun x=>(S*α)⁻¹ • M.value (t • (S • x))) '' Metric.closedBall z r)
          2 (r*(b/α)) := by
  obtain ⟨b,hb,hlog,hcover⟩ := M.exists_physical_two_ball_factor hcard ht ha hta
  refine ⟨b,hb,hlog,fun z r hr=>?_⟩
  have hh := normalized_ball_cover (fun x=>M.value (t • x)) 2 hS (mul_pos hS hα)
    hcover z r hr
  have he : S/(S*α)*b=b/α := by field_simp
  simpa only [he] using hh

#print axioms dimension_mono
#print axioms exists_normalized_two_ball_factor
end CanonicalLayerModel
end ConditionalNonpolynomial.Analytic
