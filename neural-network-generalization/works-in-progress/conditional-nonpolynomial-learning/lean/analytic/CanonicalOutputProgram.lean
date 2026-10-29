import CanonicalResidualRealMap
import ResidualProgramResources

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {d m o n:ℕ}

abbrev outputPre (d:ℕ) := (coordinateIso (Fin d)).symm.toContinuousLinearMap

def outputPostCore
    (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o)) :
    WithLp 2 (EuclideanSpace ℝ (Fin d)×EuclideanSpace ℝ (Fin m⊕Unit))→ₗ[ℝ]
      EuclideanSpace ℝ (Fin o) where
  toFun z:=T z.snd
  map_add' z w:=by simp only [WithLp.snd,WithLp.ofLp_add,Prod.snd_add,map_add]
  map_smul' c z:=by simp only [WithLp.snd,WithLp.ofLp_smul,Prod.smul_snd,map_smul,RingHom.id_apply]

lemma outputPostCore_bound
    (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o))
    (z:WithLp 2 (EuclideanSpace ℝ (Fin d)×EuclideanSpace ℝ (Fin m⊕Unit))) :
    ‖outputPostCore T z‖≤‖T‖*‖z‖ :=
  (T.le_opNorm z.snd).trans (mul_le_mul_of_nonneg_left (WithLp.norm_snd_le _ z) (norm_nonneg _))

def outputPost (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o)) :
    EuclideanSpace ℝ (Fin (Fintype.card (Fin d)+Fintype.card (Fin m⊕Unit)))→L[ℝ]
      EuclideanSpace ℝ (Fin o) :=
  ((outputPostCore T).mkContinuous ‖T‖ (outputPostCore_bound T)).comp
    (coordinatePairIso (Fin d) (Fin m⊕Unit)).toContinuousLinearMap

lemma outputPost_norm (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o)) :
    ‖outputPost (d:=d) T‖≤‖T‖ := by
  apply ContinuousLinearMap.opNorm_le_bound _ (norm_nonneg _)
  intro x
  exact (outputPostCore_bound T _).trans_eq
    (by congr 1;exact (coordinatePairIso (Fin d) (Fin m⊕Unit)).norm_map x)

lemma outputPost_encode (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o))
    (u:EuclideanSpace ℝ (Fin d)) (v:EuclideanSpace ℝ (Fin m⊕Unit)) :
    outputPost T (WithLp.toLp 2 (Fin.addCases (realCoordinates u) (realCoordinates v)))=T v := by
  change outputPostCore T (coordinatePairIso _ _ _)=_
  rw [coordinatePairIso_encode]
  rfl

def canonicalOutputProgram
    (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o))
    (w:Fin n→Fin d→ℝ) (a:Fin n→ℝ) (A:Fin m→Fin n→ℝ) (b:Fin n→ℝ) :
    ArithmeticProgram d o :=
  residualArithmeticProgram (linearCoefficients (outputPre d)) 2 w a A b
    (linearCoefficients (outputPost T))

lemma canonicalOutputProgram_length
    (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o))
    (w:Fin n→Fin d→ℝ) (a:Fin n→ℝ) (A:Fin m→Fin n→ℝ) (b:Fin n→ℝ) :
    (canonicalOutputProgram T w a A b).length=14 := residualArithmeticProgram_length _ _ _ _ _ _ _

lemma canonicalOutputProgram_error
    (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o))
    (w:Fin n→Fin d→ℝ) (a:Fin n→ℝ) (A:Fin m→Fin n→ℝ) (b:Fin n→ℝ)
    (F:EuclideanSpace ℝ (Fin d)→EuclideanSpace ℝ (Fin m⊕Unit)) {τ:ℝ}
    (hquad:∀x:EuclideanSpace ℝ (Fin d),‖x‖≤2→
      ‖WithLp.toLp 2 (canonicalArithmeticProgram w a A b x)-F x‖≤τ)
    (x:EuclideanSpace ℝ (Fin d)) :
    ‖WithLp.toLp 2 ((canonicalOutputProgram T w a A b).eval x)-T (F (radialClip 2 x))‖≤‖T‖*τ := by
  let ur:=radialArithmeticProgram 2 x
  let u:EuclideanSpace ℝ (Fin d):=WithLp.toLp 2 ur
  let z:EuclideanSpace ℝ (Fin m⊕Unit):=WithLp.toLp 2 (canonicalArithmeticProgram w a A b ur)
  have hu:u=radialClip 2 x := FiniteCanonicalDynamics.radial_program_vector 2 (by norm_num) x
  have hp : (matrixArithmeticLayer (linearCoefficients (outputPre d))).eval x=realCoordinates x := by
    funext i
    change (∑k,linearCoefficients (outputPre d) i k*x k)=_
    rw [linearCoefficients_eval]
    simp only [outputPre,coordinateIso,reindexedVector,
      LinearIsometryEquiv.piLpCongrLeft_symm,Equiv.symm_symm]
    rfl
  have heval:=residualArithmeticProgram_eval (linearCoefficients (outputPre d)) 2 w a A b
    (linearCoefficients (outputPost T)) x x hp
  have he : WithLp.toLp 2 ((canonicalOutputProgram T w a A b).eval x)=T z := by
    unfold canonicalOutputProgram
    rw [heval]
    have hh : WithLp.toLp 2 ((matrixArithmeticLayer (linearCoefficients (outputPost T))).eval
        (Fin.addCases (realCoordinates ur) (realCoordinates (canonicalArithmeticProgram w a A b ur))))=
      outputPost T (WithLp.toLp 2 (Fin.addCases (realCoordinates ur)
        (realCoordinates (canonicalArithmeticProgram w a A b ur)))) := by
      ext i
      simpa only [matrixArithmeticLayer_eval,WithLp.ofLp_toLp] using
        linearCoefficients_eval (outputPost T)
          (WithLp.toLp 2 (Fin.addCases (realCoordinates ur) (realCoordinates (canonicalArithmeticProgram w a A b ur)))) i
    rw [hh]
    exact outputPost_encode T u z
  rw [he,←hu,←map_sub]
  apply (T.le_opNorm _).trans
  exact mul_le_mul_of_nonneg_left (hquad u (by rw [hu];exact radialClip_norm_le (by norm_num) _))
    (norm_nonneg _)

lemma canonicalOutputProgram_bounded
    (T:EuclideanSpace ℝ (Fin m⊕Unit)→L[ℝ]EuclideanSpace ℝ (Fin o))
    (w:Fin n→Fin d→ℝ) (a:Fin n→ℝ) (A:Fin m→Fin n→ℝ) (b:Fin n→ℝ)
    (B:ℕ) (hB:1≤B) (hT:‖T‖≤(B:ℝ))
    (hw:∀j i,|w j i|≤(B:ℝ)) (hA:∀j i,|A j i|≤(B:ℝ)) (hb:∀i,|b i|≤(B:ℝ)) :
    (canonicalOutputProgram T w a A b).bounded B := by
  apply residualArithmeticProgram_bounded _ _ _ _ _ _ _ B hB _ _ hw hA hb _
  · intro j i
    apply (linearCoefficients_bound (outputPre d) j i).trans
    have hh : ‖outputPre d‖≤1 := (coordinateIso (Fin d)).symm.toLinearIsometry.norm_toContinuousLinearMap_le
    exact hh.trans (by exact_mod_cast hB)
  · have hh:(1:ℝ)≤B := by exact_mod_cast hB
    norm_num
    linarith
  · intro j i
    exact (linearCoefficients_bound (outputPost T) j i).trans ((outputPost_norm T).trans hT)

#print axioms canonicalOutputProgram_error
#print axioms canonicalOutputProgram_bounded
end ConditionalNonpolynomial.AnalyticLookup
