import TwoPrincipalSelection
import PhysicalCanonicalLayerModel
import GaussianSpectralNorm

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
namespace CanonicalLayerModel
variable {I J A:Type*} [Fintype I] [DecidableEq I] [Fintype J] [Fintype A]
variable {anchors:A→EuclideanSpace ℝ I} {D:ℝ}

lemma value_spectral_metric (M:CanonicalLayerModel (J:=J) anchors D)
    (u v:EuclideanSpace ℝ I) :
    dist (M.value u) (M.value v)^2≤
      ∑i,(secondMomentMatrix_isHermitian M.law).eigenvalues i*
        ((secondMomentMatrix_isHermitian M.law).eigenvectorBasis.repr (u-v) i)^2 := by
  rw [←linearL2Map_spectral_norm_sq M.law M.finiteKL]
  apply pow_le_pow_left₀ dist_nonneg _ 2
  change ‖M.output _-M.output _‖≤_
  rw [←M.output.map_sub,M.output.norm_map]
  exact (ConditionalAnalytic.canonicalVector_distance (actualCanonicalSpan M.law M.finiteKL anchors)
    (actualTanhL2 M.law u) (actualTanhL2 M.law v)).trans
      (actualTanhL2_le_linearL2 M.law M.finiteKL u v)

theorem exists_physical_two_ball_factor
    (M:CanonicalLayerModel (J:=J) anchors D) (hcard:2≤Fintype.card I)
    {t a:ℝ} (ht:0<t) (ha:0<a) (hta:t^2*(a+1)=1) :
    ∃b:ℝ,0<b ∧
      Real.log b≤(D-twoBallEntropyBaseline a-twoBallEntropyGap a)/a ∧
      ∀z:EuclideanSpace ℝ I,∀r:ℝ,0≤r→
        FiniteBallCover ((fun x=>M.value (t • x)) '' Metric.closedBall z r) 2 (r*b) := by
  let w := (secondMomentMatrix_isHermitian M.law).eigenvalues
  let e := (secondMomentMatrix_isHermitian M.law).eigenvectorBasis
  have hw (i:I) : 0<w i := secondMomentMatrix_eigenvalues_pos M.law M.finiteKL i
  obtain ⟨i,j,hij,hji,_,hmax⟩ := exists_two_principal_indices w hcard
  have hwi := hw i
  have hwj := hw j
  let b := Real.sqrt ((t^2*w i+t^2*w j)/2)
  have hb : 0<b := Real.sqrt_pos.mpr (by positivity)
  have he : (t^2*w i+t^2*w j)/2=(w i+w j)/(2*(a+1)) := by
    apply (eq_div_iff (by positivity : 2*(a+1)≠0)).mpr
    nlinarith [congrArg (fun q:ℝ=>q*(w i+w j)) hta]
  have hc := secondMomentMatrix_two_eigenvalues_entropy M.law M.finiteKL i j hij
  have hg := two_moment_entropy_gain a (w i) (w j) D ha (hw i) (hw j) (by
    have hcost : (klDiv M.law (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal≤D := M.cost_le
    dsimp [w]
    linarith)
  refine ⟨b,hb,by simpa only [b,he] using hg,?_⟩
  intro z r hr
  apply two_principal_ball_metric_cover e (fun k=>t^2*w k) i (t^2*w j)
    (mul_pos (sq_pos_of_pos ht) (hw i)) (mul_nonneg (sq_nonneg _) (hw j).le)
    (mul_le_mul_of_nonneg_left hji (sq_nonneg _))
    (fun k hk=>mul_le_mul_of_nonneg_left (hmax k hk) (sq_nonneg _))
    (fun x=>M.value (t • x)) _ z r hr
  intro x y
  have hm := M.value_spectral_metric (t • x) (t • y)
  rw [←smul_sub] at hm
  simp only [map_smul,PiLp.smul_apply,smul_eq_mul,mul_pow] at hm
  convert hm using 1
  apply Finset.sum_congr rfl
  intro k _
  ring

#print axioms exists_physical_two_ball_factor
end CanonicalLayerModel
end ConditionalNonpolynomial.Analytic
