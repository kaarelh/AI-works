import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlShift
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlNormalize
import NeuralGeneralization.LayerGramConcentration

/-! Conditional matrix controls, expressed in the actual independent-row law. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open GaussianTranslatePacking
set_option maxHeartbeats 1000000
variable {I K:Type*} [Fintype I] [Fintype K]

theorem standardCurry_preserving:
    MeasurePreserving (MeasurableEquiv.curry K I ℝ)
      (Measure.pi fun _ : K×I=>gaussianReal 0 1)
      (Measure.pi fun _ : K=>(Measure.pi fun _ : I=>gaussianReal 0 1)):=by
  exact MeasurePreserving.symm (MeasurableEquiv.curry K I ℝ).symm
    (LayerGramConcentration.measurePreserving_uncurry (fun (_:K) (_:I)=>gaussianReal 0 1))

def matrixTranslate (c:K→I→ℝ) (B:Set (K→I→ℝ)):Set (K→I→ℝ):=
  {w|(fun i j=>w i j-c i j)∈B}

theorem measurableSet_matrixTranslate (c:K→I→ℝ) {B:Set (K→I→ℝ)} (hB:MeasurableSet B):
    MeasurableSet (matrixTranslate c B):=hB.preimage (by fun_prop)

/-- Arbitrary row-dependent matrix shifts with bounded total squared cost. -/
theorem gaussian_matrix_control_lower (c:K→I→ℝ) (B:Set (K→I→ℝ)) (hB:MeasurableSet B)
    {E:ℝ} (hE:0≤E) (hc:(∑i,∑j,c i j^2)≤E)
    (hprob:(3:ℝ)/4≤(Measure.pi fun _ : K=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real B):
    (1:ℝ)/2*Real.exp (-2*E-4)≤
      (Measure.pi fun _ : K=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real (matrixTranslate c B):=by
  let e:=MeasurableEquiv.curry K I ℝ
  have hm:=standardCurry_preserving (K:=K) (I:=I)
  have he (A:Set (K→I→ℝ)):
      (standardGaussian (I:=K×I)).real (e⁻¹' A)=
      (Measure.pi fun _ : K=>(Measure.pi fun _ : I=>gaussianReal 0 1)).real A:=by
    exact congrArg ENNReal.toReal (hm.measure_preimage_emb e.measurableEmbedding A)
  have hh:=gaussian_control_translate_lower (fun ij:K×I=>c ij.1 ij.2) (e⁻¹' B)
    (hB.preimage e.measurable) hE (by simpa only [Fintype.sum_prod_type] using hc)
    (by rw [he];exact hprob)
  have hset:translateSet (fun ij:K×I=>c ij.1 ij.2) (e⁻¹' B)=e⁻¹' matrixTranslate c B:=by
    ext z
    rfl
  rwa [hset,he] at hh

/-- A repeated rank-one row shift costs exactly width times its squared
amplitude when the source direction has unit norm. -/
theorem constant_matrix_control_cost (t:I→ℝ) (ht:∑i,t i^2=1) (a:ℝ):
    (∑_ : K,∑i,(a*t i)^2)=(Fintype.card K:ℝ)*a^2:=by
  simp only [mul_pow,←Finset.mul_sum,ht,mul_one,Finset.sum_const,Finset.card_univ,nsmul_eq_mul]

end NeuralGeneralization.BatchTwoContinuousDepthCritical
