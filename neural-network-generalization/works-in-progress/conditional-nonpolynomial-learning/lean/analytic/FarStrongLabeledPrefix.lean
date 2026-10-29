import ActualCoverLabels
import FarStrongPrefixRadius

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
variable {I:ℕ→Type*} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K X:Type*} [Fintype K] [Nonempty X]
variable {anchors:∀j,K→EuclideanSpace ℝ (I j)} {D:ℕ→ℝ} {H:ℕ}

theorem actual_farStrong_prefix_classifier_geometry
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (hcard:2≤Fintype.card (I 0)) {t a R E μ:ℝ}
    (ht:0<t) (ha:1/4≤a) (hta:t^2*(a+1)=1) (hR:0<R) (hμ:0<μ)
    (u:∀j,X→EuclideanSpace ℝ (I j)) (f:X→Bool)
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (hu:∀x,‖u 0 x‖≤R) (c:EuclideanSpace ℝ (I H))
    (hmargin:∀x,μ≤labelReal (f x)*inner ℝ c (u H x))
    (hbudget:(∑j∈Finset.range H,D j)-(H:ℝ)*twoBallEntropyBaseline a≤E)
    (J:ℕ) (hJ:J≤H)
    (hJlarge:40*(E/a+Real.log (2*R*‖c‖/(μ/8)))≤(J:ℝ)) :
    let L:=‖c‖*sharpFiniteProduct t D H
    ∃C:Finset (EuclideanSpace ℝ (I J)), C.card≤2^J ∧
      (↑C:Set (EuclideanSpace ℝ (I J)))⊆Set.range (finiteNormalizedState t D u J) ∧
      (∀z∈C,‖z‖≤R) ∧ ∃labels:C→Bool,
        (∀x,∃z:C,labels z=f x ∧ dist (finiteNormalizedState t D u J x) z≤μ/(8*L)) ∧
        (∀x,∀z:C,labels z≠f x→2*μ≤L*dist (finiteNormalizedState t D u J x) z) := by
  intro L
  have hcpos : 0<‖c‖ := by
    apply norm_pos_iff.mpr
    intro hc
    obtain ⟨x⟩:=‹Nonempty X›
    have hh:=hmargin x
    simp only [hc,inner_zero_left,mul_zero] at hh
    linarith
  have hL : 0<L := mul_pos hcpos (sharpFiniteProduct_pos ht D H)
  obtain ⟨b,hb,hcover⟩:=actual_normalized_two_ball_prefix M hcard ht (by linarith) hta u hrec hR.le hu
  let radius:=2*R*∏j∈Finset.range J,b j/sharpFiniteGain t D j
  have hD (j:ℕ) (hj:j<H) : 0≤D j := ENNReal.toReal_nonneg.trans (M j hj).cost_le
  have hsmall : L*radius≤μ/8 :=
    farStrong_readout_radius_small D b H J hJ ht ha hta hR hcpos (by positivity)
      hD (fun j hj=>(hb j (lt_of_lt_of_le hj hJ)).1)
      (fun j hj=>(hb j (lt_of_lt_of_le hj hJ)).2) hbudget hJlarge
  obtain ⟨C,hcardC,hCS,labels,hclose,hsep⟩:=actual_cover_with_labels
    (finiteNormalizedState t D u J) f (fun x=>inner ℝ c (u H x)) (2^J)
    (hcover J hJ) hmargin
    (finiteNormalizedState_readout_lipschitz M ht u hrec c J hJ)
    (by change L*radius<2*μ; linarith) hL.le
  refine ⟨C,hcardC,hCS,?_,labels,?_,hsep⟩
  · intro z hz
    obtain ⟨x,rfl⟩:=hCS hz
    exact finiteNormalizedState_norm M ht u hrec hu J hJ x
  · intro x
    obtain ⟨z,hz,hd⟩:=hclose x
    refine ⟨z,hz,?_⟩
    apply (le_div_iff₀ (by positivity : 0<8*L)).mpr
    have hm:=mul_le_mul_of_nonneg_left hd hL.le
    change L*dist (finiteNormalizedState t D u J x) z≤L*radius at hm
    nlinarith

#print axioms actual_farStrong_prefix_classifier_geometry
end ConditionalNonpolynomial.Analytic
