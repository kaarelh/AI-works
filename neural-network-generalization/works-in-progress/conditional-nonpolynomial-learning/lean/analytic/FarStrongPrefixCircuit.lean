import FarStrongGridParameters
import FarStrongLabeledPrefix
import GridEndpointResources

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalNonpolynomial.AnalyticLookup NeuralGeneralization.ConcreteModel

def farStrongCompilerExponent : ℕ := gainGridSizeExponent+16*distanceClassifierResourceExponent+100

theorem CanonicalLayerModel.gainRank_le_output
    {I J A:Type*} [Fintype I] [Fintype J] [Fintype A]
    {anchors:A→EuclideanSpace ℝ I} {D:ℝ}
    (M:CanonicalLayerModel (J:=J) anchors D) : M.gainRank≤Fintype.card J := by
  have hh:=LinearMap.finrank_le_finrank_of_injective (f:=M.output.toLinearMap) M.output.injective
  simp only [finrank_euclideanSpace,CanonicalIndex,Fintype.card_sum,Fintype.card_fin,Fintype.card_unit] at hh
  dsimp only [CanonicalLayerModel.gainRank]
  omega

variable {I:ℕ→Type} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K:Type} [Fintype K]
variable {anchors:∀j,K→EuclideanSpace ℝ (I j)} {D:ℕ→ℝ} {H d:ℕ}

theorem actual_farStrong_normalized_prefix_circuit
    (M:∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    (hcard:2≤Fintype.card (I 0)) {t a E W:ℝ}
    (ht:0<t) (ha:1/4≤a) (hta:t^2*(a+1)=1)
    (u:∀j,Input d→EuclideanSpace ℝ (I j)) (f:Input d→Bool)
    (hrec:∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (hu:∀x,‖u 0 x‖≤2) (c:EuclideanSpace ℝ (I H))
    (hmargin:∀x,(1/4:ℝ)≤labelReal (f x)*inner ℝ c (u H x))
    (sources:I 0→BooleanInputSource d) (hsource:∀x i,(sources i).eval x=u 0 x i)
    (hbudget:(∑j∈Finset.range H,D j)-(H:ℝ)*twoBallEntropyBaseline a≤E)
    (J:ℕ) (hJ:J≤H)
    (hJlarge:40*(E/a+Real.log (4*‖c‖/((1/4:ℝ)/8)))≤(J:ℝ))
    (hW:2≤W) (hdim:∀j≤J,(Fintype.card (I j):ℝ)≤W)
    (hJW:(J:ℝ)≤W) (hcenters:((2^J:ℕ):ℝ)≤W)
    (hLW:‖c‖*sharpFiniteProduct t D H≤W)
    (hi:(farStrongGridPrecision J (‖c‖*sharpFiniteProduct t D H))⁻¹≤W) :
    ∃circuit:ThresholdCircuit d,(circuit.size:ℝ)≤W^farStrongCompilerExponent ∧
      circuit.depth≤80*J+17 ∧ circuit.eval=f := by
  classical
  let L:=‖c‖*sharpFiniteProduct t D H
  have hcpos:0<‖c‖ := by
    apply norm_pos_iff.mpr
    intro hc
    have hh:=hmargin (fun _=>false)
    simp only [hc,inner_zero_left,mul_zero] at hh
    norm_num at hh
  have hL:0<L := mul_pos hcpos (sharpFiniteProduct_pos ht D H)
  obtain ⟨C,hCcard,hCrange,hCnorm,labels,hnear,hfar⟩:=
    actual_farStrong_prefix_classifier_geometry M hcard ht ha hta (by norm_num : (0:ℝ)<2)
      (by norm_num : (0:ℝ)<1/4) u f hrec hu c hmargin hbudget J hJ
      (by simpa only [show (2:ℝ)*2=4 by norm_num] using hJlarge)
  let δ:=farStrongGridPrecision J L
  let Q:=farStrongGridMesh W J L
  have hδ:0<δ := farStrongGridPrecision_positive J hL
  have hδone:δ≤1 := farStrongGridPrecision_le_one J hL
  obtain ⟨hQ,hQlow,hQup⟩:=farStrongGridMesh_bounds J hW hL hi
  have hrank (j:ℕ) (hj:j<J) : ((M j (lt_of_lt_of_le hj hJ)).gainRank:ℝ)≤W :=
    (show ((M j (lt_of_lt_of_le hj hJ)).gainRank:ℝ)≤Fintype.card (I (j+1)) by
      exact_mod_cast (M j (lt_of_lt_of_le hj hJ)).gainRank_le_output).trans (hdim (j+1) (by omega))
  obtain ⟨front,hpdepth,hpsize,hpapprox⟩:=exists_normalized_prefix_grid M ht u hrec hu
    sources hsource J Q hJ hδ hδone hW hdim hrank hi hQ hQup hQlow
  let ε:=farStrongClassifierPrecision W
  have hCw:(Fintype.card C:ℝ)≤W :=
    (show (Fintype.card C:ℝ)≤((2^J:ℕ):ℝ) by simpa only [Fintype.card_coe] using (show (C.card:ℝ)≤((2^J:ℕ):ℝ) by exact_mod_cast hCcard)).trans hcenters
  obtain ⟨hε,hεone,hεinv,hεnoise⟩:=farStrongClassifierPrecision_bounds hW hL hLW hCw
  let centers:C→EuclideanSpace ℝ (I J):=fun z=>z.val
  let radius:ℝ:=(1/(8*L))^2
  let classifier:=coordinateDistanceClassifier id Q 3 centers labels radius 2 4 ε
  let result:=substituteCircuit front.gates front.outputs classifier
  have hcenterbound (z:C) (i:I J) : |centers z i|≤(2:ℝ) :=
    (PiLp.norm_apply_le z.val i).trans (hCnorm z.val z.property)
  have herror (x:Input d) : ∃b:I J→ScalarCode Q 3,
      front.eval x=encodeCoordinateState Q 3 b ∧
      ‖finiteNormalizedState t D u J x-decodeCoordinates Q 3 b‖≤1/(32*L) := by
    obtain ⟨b,hb,he⟩:=hpapprox x
    exact ⟨b,hb,he.trans (farStrongGrid_total_error J (Fintype.card (I 0)) hW hL (hdim 0 (by omega)) hi)⟩
  refine ⟨result,?_,?_,?_⟩
  · have hW4:W≤W^4 := by simpa using resource_pow_mono hW (show 1≤4 by omega)
    have hbase4:2≤W^4 := hW.trans hW4
    have hg:=scalarGrid_card_resource hbase4 hQup
      ((show (3:ℝ)≤W^2 by nlinarith).trans (resource_pow_mono hW (show 2≤4 by omega)))
    rw [←pow_mul] at hg
    have hinit:=resource_mul hW (resource_mul hW (show (3:ℝ)≤W^2 by nlinarith)
      (a:=2) (b:=1) (by simpa using hdim 0 (by omega)) (by positivity)) hg (by positivity)
    have hceil:(⌈W^gainGridSizeExponent⌉₊:ℝ)≤W^(gainGridSizeExponent+2) :=
      (show (⌈W^gainGridSizeExponent⌉₊:ℝ)≤((⌈W^gainGridSizeExponent⌉₊+1:ℕ):ℝ) by push_cast;linarith).trans
        (resource_ceil_add_one hW (by positivity) le_rfl)
    have hchain:=resource_mul hW (a:=1) (by simpa using hJW) hceil (by positivity)
    have hprefix:(front.size:ℝ)≤W^(gainGridSizeExponent+24) := by
      have hin:3*((Fintype.card (I 0):ℝ)*(Fintype.card (ScalarGrid Q 3):ℝ))≤W^23 := by
        convert hinit using 1 <;> ring
      have hs:=(resource_add_same hW
        (hin.trans (resource_pow_mono hW (show 23≤gainGridSizeExponent+23 by omega)))
        (hchain.trans (resource_pow_mono hW (show 1+(gainGridSizeExponent+2)≤gainGridSizeExponent+23 by omega))))
      have hpcast:(front.size:ℝ)≤3*((Fintype.card (I 0):ℝ)*(Fintype.card (ScalarGrid Q 3):ℝ))+
        (J:ℝ)*(⌈W^gainGridSizeExponent⌉₊:ℝ) := by exact_mod_cast hpsize
      exact hpcast.trans hs
    have hW16:W≤W^16 := by simpa using resource_pow_mono hW (show 1≤16 by omega)
    have hbase16:2≤W^16 := hW.trans hW16
    have hdistdim:((distanceProgramBlock centers).maxDimension:ℝ)≤W^16 := by
      have hh:=distanceProgramBlock_dimension centers
      have hc:((distanceProgramBlock centers).maxDimension:ℝ)≤
          (Fintype.card (I J):ℝ)+(Fintype.card C:ℝ)*(Fintype.card (I J):ℝ)+(Fintype.card C:ℝ)+1 := by exact_mod_cast hh
      have hm:=resource_mul hW (a:=1) (b:=1) (by simpa using hCw) (by simpa using hdim J le_rfl) (by positivity)
      have hdw:(Fintype.card (I J):ℝ)≤W^2 := (hdim J le_rfl).trans (by simpa using resource_pow_mono hW (show 1≤2 by omega))
      have hcw:(Fintype.card C:ℝ)≤W^3 := hCw.trans (by simpa using resource_pow_mono hW (show 1≤3 by omega))
      apply hc.trans
      simpa only [Fintype.card_coe] using ((resource_add_one hW (resource_add_same hW
        (resource_add_same hW hdw hm) hcw)).trans (resource_pow_mono hW (show 5≤16 by omega)))
    have hclass:=coordinateDistanceClassifier_polynomial_size id Q 3 centers labels radius 2 4
      (by norm_num) hcenterbound hε hbase16 ((hdim J le_rfl).trans hW16) (hCw.trans hW16)
      hdistdim (hW.trans hW16)
      ((show (4:ℝ)≤W^2 by nlinarith).trans (resource_pow_mono hW (show 2≤16 by omega)))
      (hQup.trans (resource_pow_mono hW (show 4≤16 by omega)))
      ((show (3:ℝ)≤W^2 by nlinarith).trans (resource_pow_mono hW (show 2≤16 by omega))) hεinv
    rw [←pow_mul] at hclass
    have hsum:=resource_add_same hW
      (hprefix.trans (resource_pow_mono hW (show gainGridSizeExponent+24≤farStrongCompilerExponent-1 by
        unfold farStrongCompilerExponent;omega)))
      (hclass.trans (resource_pow_mono hW (show 16*distanceClassifierResourceExponent≤farStrongCompilerExponent-1 by
        unfold farStrongCompilerExponent;omega)))
    have hpos:0<farStrongCompilerExponent := by unfold farStrongCompilerExponent;omega
    rw [show farStrongCompilerExponent-1+1=farStrongCompilerExponent by omega] at hsum
    simpa only [result,classifier,ε,CircuitMap.size,substituteCircuit_size,Nat.cast_add] using hsum
  · have hh:=(substituteCircuit_depth front.gates front.outputs classifier).trans
      (add_le_add hpdepth (coordinateDistanceClassifier_depth id Q 3 centers labels radius 2 4 ε))
    exact hh.trans_eq (by omega)
  · funext x
    obtain ⟨b,hb,herr⟩:=herror x
    change (substituteCircuit front.gates front.outputs classifier).eval x=f x
    rw [substituteCircuit_eval]
    change classifier.eval (front.eval x)=f x
    rw [hb]
    have hgap:=distance_gap_of_endpoint_error centers labels (decodeCoordinates Q 3 b)
      (finiteNormalizedState t D u J x) (f x)
      (a:=1/(32*L)) (b:=1/(2*L)) (e:=1/(32*L)) (r:=radius)
      (δ:=((Fintype.card C:ℝ)+1)*ε)
      (by simpa only [norm_sub_rev] using herr) (one_div_le_one_div_of_le (by positivity) (by linarith : 2*L≤32*L))
      (by intro h; obtain ⟨z,hz,hd⟩:=hnear x; refine ⟨z,hz.trans h,?_⟩;
          simpa only [dist_eq_norm,L,show (1/4:ℝ)/(8*(‖c‖*sharpFiniteProduct t D H))=1/(32*(‖c‖*sharpFiniteProduct t D H)) by ring] using hd)
      (by intro h z hz; have hh:=hfar x z (by rw [hz,h];decide);
          apply (div_le_iff₀ (by positivity : 0<2*L)).mpr;
          rw [dist_eq_norm] at hh; change 2*(1/4:ℝ)≤L*‖_-_‖ at hh;nlinarith)
      (by dsimp [radius]; have hh:=hεnoise;change ((Fintype.card C:ℝ)+1)*ε≤_ at hh;
          have hz:0<1/(32*L):=by positivity;
          have he:1/(8*L)=4*(1/(32*L)):=by ring;
          rw [he];nlinarith)
      (by dsimp [radius];have hh:=hεnoise;change ((Fintype.card C:ℝ)+1)*ε≤_ at hh;
          have he:1/(8*L)=4*(1/(32*L)):=by ring;
          have he2:1/(2*L)=16*(1/(32*L)):=by ring;
          rw [he,he2];nlinarith [sq_nonneg (1/(32*L))])
    exact coordinateDistanceClassifier_correct id Q 3 centers labels radius 2 4 (by norm_num)
      hcenterbound hε hεone b (f x)
      (fun i=>by simpa only [id_eq,Nat.cast_ofNat,show (3:ℝ)+1=4 by norm_num] using scalarDecode_bound Q 3 hQ (b i)) (by norm_num) hgap.1 hgap.2

#print axioms actual_farStrong_normalized_prefix_circuit
end ConditionalNonpolynomial.Analytic
