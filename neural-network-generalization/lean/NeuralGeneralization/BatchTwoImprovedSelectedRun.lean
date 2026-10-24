import NeuralGeneralization.BatchTwoImprovedCanonicalLayer
import NeuralGeneralization.RobustCompressionInductionSelectedRun

/-! # Construction of the actual depthwise selected-query program

At every stage the selected message comes from that stage's actual conditional
law. The recursion constructs the next common coefficient law before selecting
queries for the following layer. All choices and all resulting laws are
independent of the later pointwise test-input couplings.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel RobustEntropy RobustCompressionInduction BatchTwoImprovedCanonicalLayer
variable {d N m q : ℕ}
local notation "QI" => Fin (Fintype.card (Cube d))
local notation "Msg" => QueryMessage QI q

def sharpSelectedNext {s r : ℕ} [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hq : 0 < q)
    (t BH BG δ η : ℝ) (Q : CanonicalStateLaw d N m s (r+1))
    (S : ActualPrefixSelection Q φ hφ q t δ η) : CanonicalStateLaw d N m (s+1) r :=
  CanonicalTransition.next d N m Msg
    (@sharpSelectedTransition d N m s q r (Fintype.card (Cube d)) inferInstance
      hFin hFinS hMsg hMsgS hq (indexedPrefixQueries φ) (measurable_indexedPrefixQueries hφ)
      t BH BG S.queries S.measurable_queries) Q

inductive SharpSelectedRun [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hq : 0 < q) (t BH BG δ η : ℝ) :
    (s r : ℕ) → CanonicalStateLaw d N m s r → Type
  | nil (s : ℕ) (Q : CanonicalStateLaw d N m s 0) : SharpSelectedRun hφ hq t BH BG δ η s 0 Q
  | cons {s r : ℕ} (Q : CanonicalStateLaw d N m s (r+1))
      (S : ActualPrefixSelection Q φ hφ q t δ η)
      (tail : SharpSelectedRun hφ hq t BH BG δ η (s+1) r
        (sharpSelectedNext (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η Q S)) :
      SharpSelectedRun hφ hq t BH BG δ η s (r+1) Q

/-- Actual choices exist through every remaining layer whenever the explicit
scalar entropy envelope fits the uniform conditional-selection budget. -/
theorem exists_sharpSelectedRun [NeZero N] [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    [hMsgB : StandardBorelSpace Msg]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (t BH BG δ η K : ℝ) (hq : 0 < q) (hN : 0 < N)
    (ht : 0 < t) (hδ : 0 < δ) (hη : 0 ≤ η) (hrank : 2*K ≤ η*δ^3*q)
    (base : ℝ≥0∞) (s r : ℕ) (Q : CanonicalStateLaw d N m s r)
    (hentropy : futureEntropy Q.law (futurePrior N r) ≤
      base+s • ENNReal.ofReal (Real.log (Fintype.card Msg)))
    (hcap : ∀ j ≤ s+r,base+j • ENNReal.ofReal (Real.log (Fintype.card Msg)) ≤
      ENNReal.ofReal (2*N*K/t^2)) :
    Nonempty (SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s r Q) := by
  induction r generalizing s with
  | zero => exact ⟨.nil s Q⟩
  | succ r ih =>
    obtain ⟨S⟩ := @exists_prefixSelection d N m s r q (Fintype.card (Cube d)) inferInstance
      hFin hFinS hMsg hMsgS Q.law inferInstance (indexedPrefixQueries φ)
      (measurable_indexedPrefixQueries hφ) K t δ η hq hN ht hδ hη
      (hentropy.trans (hcap s (by omega))) hrank
    let Q' := sharpSelectedNext hφ hq t BH BG δ η Q S
    have he : futureEntropy Q'.law (futurePrior N r) ≤
        base+(s+1) • ENNReal.ofReal (Real.log (Fintype.card Msg)) := by
      let transition := @sharpSelectedTransition d N m s q r (Fintype.card (Cube d)) inferInstance
        hFin hFinS hMsg hMsgS hq (indexedPrefixQueries φ)
        (measurable_indexedPrefixQueries hφ) t BH BG S.queries S.measurable_queries
      have hs := canonicalStepLaw_futureEntropy_le Q.law transition.message transition.reconstruct
      refine hs.trans ?_
      calc
        _ ≤ (base+s • ENNReal.ofReal (Real.log (Fintype.card Msg)))+
            ENNReal.ofReal (Real.log (Fintype.card Msg)) := add_le_add hentropy le_rfl
        _ = _ := by rw [add_nsmul,one_nsmul]; ac_rfl
    obtain ⟨tail⟩ := ih (s+1) Q' he (fun j hj => hcap j (by omega))
    exact ⟨.cons Q S tail⟩

/-- Erasing the conditional-entropy witnesses leaves the explicit canonical
message/reconstruction program whose terminal law is shared by all inputs. -/
def SharpSelectedRun.program [NeZero N] [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    [hMsgB : StandardBorelSpace Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {hq : 0 < q} {t BH BG δ η : ℝ}
    {s r : ℕ} {Q : CanonicalStateLaw d N m s r}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s r Q) :
    Σ k, CanonicalProgram d N m Msg s r k :=
  match P with
  | .nil s _ => ⟨s,.nil s⟩
  | .cons _ S tail =>
    let z := tail.program
    ⟨z.1,.cons (@sharpSelectedTransition d N m _ q _ (Fintype.card (Cube d)) inferInstance
      hFin hFinS hMsg hMsgS hq (indexedPrefixQueries φ)
      (measurable_indexedPrefixQueries hφ) t BH BG S.queries S.measurable_queries) z.2⟩

def SharpSelectedRun.terminal [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {hq : 0 < q} {t BH BG δ η : ℝ}
    {s r : ℕ} {Q : CanonicalStateLaw d N m s r}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s r Q) :
    Σ k, CanonicalStateLaw d N m k 0 :=
  match P with
  | .nil s Q => ⟨s,Q⟩
  | .cons _ _ tail => tail.terminal

theorem SharpSelectedRun.terminal_stage [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {hq : 0 < q} {t BH BG δ η : ℝ}
    {s r : ℕ} {Q : CanonicalStateLaw d N m s r}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s r Q) :
    P.terminal.1=s+r := by
  induction P with
  | nil s Q => simp [terminal]
  | @cons s r Q S tail ih => simpa only [terminal] using ih.trans (by omega)

theorem SharpSelectedRun.terminal_entropy [NeZero N]
    [hFin : MeasurableSpace (Finset QI)] [hFinS : MeasurableSingletonClass (Finset QI)]
    [hMsg : MeasurableSpace Msg] [hMsgS : MeasurableSingletonClass Msg]
    [hMsgB : StandardBorelSpace Msg]
    {φ : ℝ → ℝ} {hφ : Continuous φ} {hq : 0 < q} {t BH BG δ η : ℝ}
    {s r : ℕ} {Q : CanonicalStateLaw d N m s r}
    (P : SharpSelectedRun (d:=d) (N:=N) (m:=m) (q:=q) hφ hq t BH BG δ η s r Q) :
    futureEntropy P.terminal.2.law (futurePrior N 0) ≤
      futureEntropy Q.law (futurePrior N r)+r • ENNReal.ofReal (Real.log (Fintype.card Msg)) := by
  induction P with
  | nil s Q => simp only [terminal, zero_nsmul, add_zero]; exact le_rfl
  | @cons s r Q S tail ih =>
    let transition := @sharpSelectedTransition d N m s q r (Fintype.card (Cube d)) inferInstance
      hFin hFinS hMsg hMsgS hq (indexedPrefixQueries φ)
      (measurable_indexedPrefixQueries hφ) t BH BG S.queries S.measurable_queries
    have hs := canonicalStepLaw_futureEntropy_le Q.law transition.message transition.reconstruct
    refine ih.trans ?_
    change futureEntropy (canonicalStepLaw Q.law transition.message transition.reconstruct)
      (futurePrior N r) + r • _ ≤ _
    calc
      _ ≤ (futureEntropy Q.law (futurePrior N (r+1))+ENNReal.ofReal
        (Real.log (Fintype.card Msg)))+r • _ := add_le_add hs le_rfl
      _ = _ := by rw [add_nsmul,one_nsmul]; ac_rfl

end NeuralGeneralization.BatchTwoImprovedInduction
