import NeuralGeneralization.BatchTwoContinuousDepthVariableChannel

/-! The scalar radius schedule and the dense network have exactly the same
normalized channel semantics. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous

def radiusGains {r : ℕ} (rs : Fin (r+1) → ℝ) : Fin (r+1) → ℝ :=
  Fin.cases (Real.artanh (rs 0)) (fun j => Real.artanh (rs j.succ)/rs j.castSucc)

def normalizedChannelState {r : ℕ} (rs : Fin (r+1) → ℝ) (x : ℝ) (t : ℕ) : ℝ :=
  ((List.finRange (r+1)).take t).foldl (fun z s => normalizedTanh (rs s) z) x

def radiusList {r : ℕ} (rs : Fin (r+1) → ℝ) : List ℝ := (List.finRange (r+1)).map rs

theorem normalizedChannelState_succ {r : ℕ} (rs : Fin (r+1) → ℝ) (x : ℝ)
    (s : Fin (r+1)) : normalizedChannelState rs x (s.val+1) =
      normalizedTanh (rs s) (normalizedChannelState rs x s.val) := by
  unfold normalizedChannelState
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt),List.foldl_append]
  simp only [List.foldl_cons,List.foldl_nil,List.getElem_finRange]
  rfl

theorem normalizedChannelState_full {r : ℕ} (rs : Fin (r+1) → ℝ) (x : ℝ) :
    normalizedChannelState rs x (r+1) = channelComposition (radiusList rs) x := by
  have htake : (List.finRange (r+1)).take (r+1)=List.finRange (r+1) := by simp
  simp only [normalizedChannelState,htake,channelComposition,radiusList,List.foldl_map]

theorem radiusGains_state {r : ℕ} (rs : Fin (r+1) → ℝ) (hrs : ∀ i, rs i ≠ 0)
    (x : ℝ) (t : ℕ) (ht : t ≤ r) :
    scalarChannelState (radiusGains rs) x (t+1) =
      rs ⟨t,by omega⟩ * normalizedChannelState rs x (t+1) := by
  induction t with
  | zero =>
    rw [show 0+1=(0 : Fin (r+1)).val+1 from rfl,scalarChannelState_succ,normalizedChannelState_succ]
    simp only [scalarChannelState,normalizedChannelState,Fin.val_zero,List.take_zero,List.foldl_nil,
      radiusGains,Fin.cases_zero,normalizedTanh]
    change Real.tanh (Real.artanh (rs 0)*x)=rs 0*(Real.tanh (Real.artanh (rs 0)*x)/rs 0)
    rw [mul_div_cancel₀ _ (hrs 0)]
  | succ t ih =>
    let j : Fin r := ⟨t,by omega⟩
    rw [show t+1+1=j.succ.val+1 from rfl,scalarChannelState_succ,normalizedChannelState_succ]
    change Real.tanh (radiusGains rs j.succ*scalarChannelState (radiusGains rs) x (t+1)) =
      rs j.succ*normalizedTanh (rs j.succ) (normalizedChannelState rs x (t+1))
    rw [ih (by omega)]
    change Real.tanh ((Real.artanh (rs j.succ)/rs j.castSucc)*
      (rs j.castSucc*normalizedChannelState rs x (t+1))) =
      rs j.succ*(Real.tanh (Real.artanh (rs j.succ)*normalizedChannelState rs x (t+1))/rs j.succ)
    field_simp [hrs]

/-- A radius schedule's normalized composition is the literal real output
of the dense variable-channel weights. -/
theorem radiusChannel_output {d N r : ℕ} (hN : 0 < N) (rs : Fin (r+1) → ℝ)
    (hrs : ∀ i, rs i ≠ 0) (w : Weights d N 0) (x : RealInput d) :
    output Real.tanh (variableChannelWeights (radiusGains rs) (1/rs (Fin.last r)) w) x =
      channelComposition (radiusList rs) (output Real.tanh w x) := by
  rw [variableChannel_output hN,radiusGains_state rs hrs _ r le_rfl,normalizedChannelState_full]
  change (1/rs (Fin.last r))*(rs (Fin.last r)*_) = _
  field_simp [hrs]

theorem radiusChannel_global_bound {d N r : ℕ} (hN : 0 < N) (rs : Fin (r+1) → ℝ)
    (hrs : ∀ i, rs i ∈ Set.Ioo (0 : ℝ) 1) (w : Weights d N 0)
    (hw : ∀ x, |output Real.tanh w x| ≤ 1) :
    ∀ x, |output Real.tanh (variableChannelWeights (radiusGains rs) (1/rs (Fin.last r)) w) x| ≤ 1 := by
  intro x
  rw [radiusChannel_output hN rs (fun i => (hrs i).1.ne')]
  apply channelComposition_bound _ _ (hw x)
  intro a ha
  obtain ⟨i,_,rfl⟩ := List.mem_map.mp ha
  exact hrs i

end NeuralGeneralization.BatchTwoContinuousDepthPaper
