import NeuralGeneralization.RobustCompressionInductionState

/-! # Measurable canonical state and absorbing-abort updates -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel
variable {A : Type*} [MeasurableSpace A]

theorem measurable_firstRowsWeights {d N : ℕ} (a : A → FirstRows d N)
    (ha : Measurable a) : Measurable (fun z => firstRowsWeights (a z)) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · exact ha.eval.eval
  · exact Fin.elim0 s
  · exact measurable_const

theorem measurable_payloadHidden (d N m s : ℕ) {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) :
    Measurable (payloadHidden d N m φ x s) := by
  cases s with
  | zero =>
    apply measurable_pi_lambda
    intro i
    exact (continuous_firstHidden hφ x i).measurable.comp
      (measurable_firstRowsWeights _ measurable_id)
  | succ s => exact measurable_virtualHidden hφ x

theorem measurable_stepPayload (d N m s : ℕ)
    (p : A → PrefixPayload d N m s) (draw : A → PrefixDraw N m)
    (hp : Measurable p) (hd : Measurable draw) :
    Measurable (fun a => stepPayload d N m s (p a) (draw a)) := by
  cases s with
  | zero =>
    exact measurable_firstPrefix _ _ _
      (measurable_firstRowsWeights p hp) hd.fst hd.snd
  | succ s => exact measurable_extendPrefix p _ _ hp hd.fst hd.snd

theorem measurable_activeHidden {d N m s : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) :
    Measurable (fun p : ActivePrefix d N m s => activeHidden φ p x) := by
  exact ((measurable_payloadHidden d N m s hφ x).comp measurable_snd).ite
    (measurableSet_eq_fun measurable_fst measurable_const) measurable_const

theorem measurable_stepActive {d N m s : ℕ}
    (p : A → ActivePrefix d N m s) (draw : A → PrefixDraw N m) (success : A → Bool)
    (hp : Measurable p) (hd : Measurable draw) (hs : Measurable success) :
    Measurable (fun a => stepActive (p a) (draw a) (success a)) := by
  classical
  have hcond : MeasurableSet {a | (p a).1=true ∧ success a=true} :=
    (measurableSet_eq_fun hp.fst measurable_const).inter
      (measurableSet_eq_fun hs measurable_const)
  have hyes : Measurable (fun a => (true,stepPayload d N m s (p a).2 (draw a))) :=
    measurable_const.prodMk (measurable_stepPayload d N m s _ draw hp.snd hd)
  have hi : Measurable (fun a => if (p a).1=true ∧ success a=true then
      (true,stepPayload d N m s (p a).2 (draw a))
      else (false,zeroPayload d N m (s+1))) :=
    Measurable.ite hcond hyes measurable_const
  simpa only [stepActive,Bool.and_eq_true] using hi

theorem measurable_firstLayerOutput {d N m r : ℕ}
    (w : A → Weights d N r) (I : A → Fin m → Fin N) (v : A → Fin m → ℝ)
    (hw : Measurable w) (hI : Measurable I) (hv : Measurable v) :
    Measurable (fun a => firstLayerOutput (w a) (I a) (v a)) :=
  measurable_setReadout _ _
    (measurable_firstPrefix w I (fun _ _ _ => 0) hw hI measurable_const).fst hv

theorem measurable_finishPayload (d N m s : ℕ)
    (p : A → PrefixPayload d N m s) (I : A → Fin m → Fin N) (v : A → Fin m → ℝ)
    (hp : Measurable p) (hI : Measurable I) (hv : Measurable v) :
    Measurable (fun a => finishPayload d N m s (p a) (I a) (v a)) := by
  cases s with
  | zero => exact measurable_firstLayerOutput _ I v (measurable_firstRowsWeights p hp) hI hv
  | succ s => exact measurable_finishPrefix p I v hp hI hv

theorem measurable_finishActive {d N m s : ℕ}
    (p : A → ActivePrefix d N m s) (I : A → Fin m → Fin N) (v : A → Fin m → ℝ)
    (hp : Measurable p) (hI : Measurable I) (hv : Measurable v) :
    Measurable (fun a => finishActive (p a) (I a) (v a)) :=
  (measurable_finishPayload d N m s _ I v hp.snd hI hv).ite
    (measurableSet_eq_fun hp.fst measurable_const) measurable_const

end NeuralGeneralization.RobustCompressionInduction
