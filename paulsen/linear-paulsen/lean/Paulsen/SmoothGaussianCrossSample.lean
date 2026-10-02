import Paulsen.SmoothGaussianSample
import Paulsen.SmoothCrossConcentration

namespace Paulsen.Smooth
open Matrix MeasureTheory ProbabilityTheory Set
open scoped BigOperators ProbabilityTheory
noncomputable section

theorem exists_moderateGaussianSample_with_cross {n d : ℕ} [NeZero n]
    {U : Frame n d} (hU : IsParseval U)
    (hd : 1000000≤d) (hdn : d≤n) (hdensity : (d:ℝ)/n≤1/2)
    (hrows : ∀ i,((d:ℝ)/n)/2≤rowNormSq U i ∧ rowNormSq U i≤3*((d:ℝ)/n)/2)
    {D t ζ : ℝ} (hD : 0<D) (ht : 0<t) (hζ : 0<ζ) (hζ1 : ζ≤1)
    (hfluctuation : 100*(D^2+1)*(Real.log n+200)≤ζ^2*d)
    (hgraph : 4096000000000000*(Real.log n+2)≤(d:ℝ))
    (hdense : (4000000000000*Real.pi^2)*Real.log (100*(n:ℝ))≤(d:ℝ))
    (M : Frame n n) :
    ∃ g : FrameVector n d,
      ModerateGaussianSample U (D^2*t^2) t (ζ*((d:ℝ)/n)*t) (ζ*((d:ℝ)/n)) M g ∧
      ∀ x : Fin n→ℝ,
        |matrixQuadratic (graphLinearCross (frameProjection U)
          (gaussianMatrixImage (retainedTangentFactor U (D^2*t^2)) g) t) x|≤
            (1/32)*(matrixQuadratic (projectionLaplacian (frameProjection U)) x+
              ((d:ℝ)/n*t^2)*vectorNormSq x) := by
  have hn:0<n:=NeZero.pos n
  have hd0:0<d:=by omega
  have hL:0≤Real.log n:=Real.log_nonneg (by exact_mod_cast hn)
  have hcross : 10000*(Real.log n+2)≤(1/32:ℝ)^2*d := by nlinarith
  have hprob:=retainedTangentGraphCross_energy_failure_le hU hn hd0
    (show 0≤D^2*t^2 by positivity) ht.ne' (by norm_num : (0:ℝ)<1/32) hcross
  obtain ⟨g,hg,havoid⟩:=exists_moderateGaussianSample_scaled_avoiding hU hd hdn hdensity
    hrows hD ht hζ hζ1 hfluctuation hgraph hdense M _ hprob
  refine ⟨g,hg,?_⟩
  intro x
  exact le_of_not_gt (fun hx=>havoid ⟨x,hx⟩)

theorem moderateNoiseFrame_tangent {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d) :
    gaussianMatrixImage (retainedTangentFactor U ρ) g=
      moderateNoiseFrame U ρ g*U.transpose+U*(moderateNoiseFrame U ρ g).transpose := by
  have he : Matrix.toEuclideanLin (retainedTangentFactor U ρ) g=
      Matrix.toEuclideanLin (tangentLiftMatrix U)
        (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) := by
    simp only [retainedTangentFactor,Matrix.toEuclideanLin,Matrix.toLpLin_mul_same,LinearMap.comp_apply]
  ext i j
  change Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j)=_
  rw [he]
  exact tangentLiftMatrix_mulVec U (moderateNoiseFrame U ρ g) i j

end
end Paulsen.Smooth
