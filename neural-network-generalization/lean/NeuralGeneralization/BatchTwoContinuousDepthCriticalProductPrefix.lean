import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductMeasure
import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductState

/-! Certified histories are measurable events of the actual finite network;
all their shorter prefixes use its literal earlier weight coordinates. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkLayerSplit TowerNetwork BatchTwoContinuous.PairMoments

variable {d N r : ℕ}

def networkPrefix (w : Weights d N r) (k : ℕ) : Weights d N k
  | .inl ij => w (.inl ij)
  | .inr (.inl (s,i,j)) => if h : s.val<r then w (.inr (.inl (⟨s.val,h⟩,i,j))) else 0
  | .inr (.inr i) => w (.inr (.inr i))

@[simp] theorem networkPrefix_self (w : Weights d N r) : networkPrefix w r=w := by
  funext i
  rcases i with ij | (⟨s,i,j⟩ | i)
  · rfl
  · simp [networkPrefix,s.isLt]
  · rfl

@[fun_prop] theorem measurable_networkPrefix (k : ℕ) :
    Measurable (fun w : Weights d N r=>networkPrefix w k) := by
  apply measurable_pi_lambda
  intro i
  rcases i with ij | (⟨s,i,j⟩ | i)
  · exact measurable_pi_apply _
  · by_cases h : s.val<r
    · have he : (fun w : Weights d N r => networkPrefix w k (Sum.inr (Sum.inl (s,i,j)))) =
          (fun w : Weights d N r => w (Sum.inr (Sum.inl (⟨s.val,h⟩,i,j)))) := by
        funext w
        change (if hh : s.val<r then w (Sum.inr (Sum.inl (⟨s.val,hh⟩,i,j))) else 0)=_
        split_ifs <;> simp_all
      rw [he]
      exact measurable_pi_apply _
    · simp only [networkPrefix,dif_neg h]
      exact measurable_const
  · exact measurable_pi_apply _

theorem networkPrefix_previous (w : Weights d N (r+1)) {k : ℕ} (hk : k≤r) :
    networkPrefix (previousWeights w) k=networkPrefix w k := by
  funext i
  rcases i with ij | (⟨s,i,j⟩ | i)
  · rfl
  · have hs : s.val<r := lt_of_lt_of_le s.isLt hk
    have hs' : s.val<r+1 := by omega
    simp only [networkPrefix,hs,hs',dite_true]
    rfl
  · rfl

def certifiedPrefix (seed : Set (Weights d N 0))
    (step : (k : ℕ)→Set (Weights d N (k+1))) : (r : ℕ)→Set (Weights d N r)
  | 0=>seed
  | r+1=>{w | previousWeights w∈certifiedPrefix seed step r ∧ w∈step r}

theorem certifiedPrefix_measurable (seed : Set (Weights d N 0))
    (step : (k : ℕ)→Set (Weights d N (k+1))) (hseed : MeasurableSet seed)
    (hstep : ∀k,MeasurableSet (step k)) (r : ℕ) :
    MeasurableSet (certifiedPrefix seed step r) := by
  induction r with
  | zero=>exact hseed
  | succ r ih=>exact (ih.preimage continuous_previousWeights.measurable).inter (hstep r)

theorem certifiedPrefix_prefix (seed : Set (Weights d N 0))
    (step : (k : ℕ)→Set (Weights d N (k+1))) (w : Weights d N r)
    (hw : w∈certifiedPrefix seed step r) {k : ℕ} (hk : k≤r) :
    networkPrefix w k∈certifiedPrefix seed step k := by
  induction r with
  | zero=>have hk0 : k=0 := by omega
          subst k
          simpa only [networkPrefix_self] using hw
  | succ r ih=>
    by_cases he : k=r+1
    · subst k
      simpa only [networkPrefix_self] using hw
    · have hk' : k≤r := by omega
      rw [←networkPrefix_previous w hk']
      exact ih (previousWeights w) hw.1 hk'

theorem certifiedPrefix_seed (seed : Set (Weights d N 0))
    (step : (k : ℕ)→Set (Weights d N (k+1))) (w : Weights d N r)
    (hw : w∈certifiedPrefix seed step r) : networkPrefix w 0∈seed :=
  certifiedPrefix_prefix seed step w hw (Nat.zero_le r)

theorem certifiedPrefix_step (seed : Set (Weights d N 0))
    (step : (k : ℕ)→Set (Weights d N (k+1))) (w : Weights d N r)
    (hw : w∈certifiedPrefix seed step r) {k : ℕ} (hk : k<r) :
    networkPrefix w (k+1)∈step k :=
  (certifiedPrefix_prefix seed step w hw (by omega : k+1≤r)).2

theorem networkPrefix_previous_succ (w : Weights d N r) {k : ℕ} (hk : k<r) :
    previousWeights (networkPrefix w (k+1))=networkPrefix w k := by
  funext i
  rcases i with ij | (⟨s,i,j⟩ | i)
  · rfl
  · have hs : s.val<r := lt_trans s.isLt hk
    change (if h : s.val<r then w (.inr (.inl (⟨s.val,h⟩,i,j))) else 0)=_
    simp only [networkPrefix,hs,dite_true]
  · rfl

end NeuralGeneralization.BatchTwoContinuousDepthCritical
