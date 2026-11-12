import NeuralGeneralization.BatchTwoMergingEvaluation
import NeuralGeneralization.GaussianOutputSymmetry

/-! Hidden-neuron sign symmetries of the actual tanh network and Gaussian prior. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel CompressionSampling BatchTwoMerging

abbrev HiddenSigns (N r : ℕ) := Fin (r+1)→Fin N→Bool

def signAt {N r : ℕ} (s : HiddenSigns N r) (j : Fin (r+1)) (i : Fin N) : ℝ := labelReal (s j i)

theorem signAt_sq {N r : ℕ} (s : HiddenSigns N r) (j : Fin (r+1)) (i : Fin N) :
    (signAt s j i)^2=1 := by unfold signAt; cases s j i <;> norm_num [labelReal]

theorem signAt_mul_self {N r : ℕ} (s : HiddenSigns N r) (j : Fin (r+1)) (i : Fin N) :
    signAt s j i*signAt s j i=1 := by rw [←pow_two,signAt_sq]

theorem tanh_signAt {N r : ℕ} (s : HiddenSigns N r) (j : Fin (r+1)) (i : Fin N) (u : ℝ) :
    Real.tanh (signAt s j i*u)=signAt s j i*Real.tanh u := by
  unfold signAt
  cases s j i <;> simp [labelReal,Real.tanh_neg]

def weightSign {d N r : ℕ} (s : HiddenSigns N r) : WeightIndex d N r→ℝ
  | .inl (i,_)=>signAt s 0 i
  | .inr (.inl (j,i,k))=>signAt s j.succ i*signAt s j.castSucc k
  | .inr (.inr i)=>signAt s (Fin.last r) i

def flipHiddenSigns {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r) : Weights d N r :=
  fun i=>weightSign s i*w i

theorem weightSign_sq {d N r : ℕ} (s : HiddenSigns N r) (i : WeightIndex d N r) :
    (weightSign s i)^2=1 := by
  rcases i with ij | (sij | j)
  · exact signAt_sq s 0 ij.1
  · simp only [weightSign,mul_pow,signAt_sq,one_mul]
  · exact signAt_sq s (Fin.last r) j

theorem flipHiddenSigns_involutive {d N r : ℕ} (s : HiddenSigns N r) :
    Function.Involutive (flipHiddenSigns (d:=d) s) := by
  intro w
  funext i
  simp only [flipHiddenSigns,←mul_assoc,←pow_two,weightSign_sq,one_mul]

theorem continuous_flipHiddenSigns {d N r : ℕ} (s : HiddenSigns N r) :
    Continuous (flipHiddenSigns (d:=d) s) := by
  unfold flipHiddenSigns
  fun_prop

theorem flipHiddenSigns_first {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r) (x : Cube d) :
    firstHidden Real.tanh (flipHiddenSigns s w) x=fun i=>signAt s 0 i*firstHidden Real.tanh w x i := by
  funext i
  simp only [firstHidden,flipHiddenSigns,weightSign,mul_assoc,←Finset.mul_sum,tanh_signAt]

theorem flipHiddenSigns_step {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r)
    (h : Fin N→ℝ) (j : Fin r) :
    hiddenStep Real.tanh (flipHiddenSigns s w) (fun i=>signAt s j.castSucc i*h i) j=
      fun i=>signAt s j.succ i*hiddenStep Real.tanh w h j i := by
  funext i
  unfold hiddenStep
  simp only [flipHiddenSigns,weightSign]
  have he : (∑k,(signAt s j.succ i*signAt s j.castSucc k*w (.inr (.inl (j,i,k))))*
      (signAt s j.castSucc k*h k))=signAt s j.succ i*∑k,w (.inr (.inl (j,i,k)))*h k := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro k _
    calc
      _ = signAt s j.succ i*(signAt s j.castSucc k)^2*w (.inr (.inl (j,i,k)))*h k := by ring
      _ = _ := by rw [signAt_sq]; ring
  rw [he,tanh_signAt]

theorem flipHiddenSigns_prefix {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r)
    (x : Cube d) (j : Fin (r+1)) :
    hiddenPrefix Real.tanh (flipHiddenSigns s w) x j.val=
      fun i=>signAt s j i*hiddenPrefix Real.tanh w x j.val i := by
  induction j using Fin.induction with
  | zero => simpa only [Fin.val_zero,hiddenPrefix_zero] using flipHiddenSigns_first s w x
  | succ j ih =>
    simp only [Fin.val_succ,Fin.val_castSucc,hiddenPrefix_succ] at ih ⊢
    rw [ih]
    exact flipHiddenSigns_step s w _ j

theorem flipHiddenSigns_output {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r) (x : Cube d) :
    networkOutput Real.tanh (flipHiddenSigns s w) x=networkOutput Real.tanh w x := by
  have hh := flipHiddenSigns_prefix s w x (Fin.last r)
  simp only [Fin.val_last,hiddenPrefix_last] at hh
  unfold networkOutput
  rw [hh]
  apply Finset.sum_congr rfl
  intro i _
  simp only [flipHiddenSigns,weightSign]
  calc
    _ = (signAt s (Fin.last r) i)^2*w (.inr (.inr i))*finalHidden Real.tanh w x i := by ring
    _ = _ := by rw [signAt_sq]; ring

theorem flipHiddenSigns_coordinate_sq {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r)
    (i : WeightIndex d N r) : (flipHiddenSigns s w i)^2=(w i)^2 := by
  rw [flipHiddenSigns,mul_pow,weightSign_sq,one_mul]

theorem flipHiddenSigns_energy {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r) :
    weightedSquaredNorm (flipHiddenSigns s w)=weightedSquaredNorm w := by
  simp only [weightedSquaredNorm,flipHiddenSigns_coordinate_sq]

theorem flipHiddenSigns_readoutEnergy {d N r : ℕ} (s : HiddenSigns N r) (w : Weights d N r) :
    readoutEnergy (flipHiddenSigns s w)=readoutEnergy w := by
  simp only [readoutEnergy,flipHiddenSigns_coordinate_sq]

theorem productGaussian_map_flipHiddenSigns {d N r : ℕ} (s : HiddenSigns N r)
    (v : WeightIndex d N r→ℝ) :
    (productGaussian d N r v).map (flipHiddenSigns s)=productGaussian d N r v := by
  unfold productGaussian flipHiddenSigns
  rw [Measure.pi_map_pi (f:=fun (i:WeightIndex d N r) (x:ℝ)=>weightSign s i*x)
    (fun i=>(show Measurable (fun x:ℝ=>weightSign s i*x) from measurable_const.mul measurable_id).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul,mul_zero]
  congr 1
  apply NNReal.eq
  simp only [NNReal.coe_mul,NNReal.coe_mk,weightSign_sq,one_mul]

end NeuralGeneralization.BatchTwoOnlineTanhMerging
