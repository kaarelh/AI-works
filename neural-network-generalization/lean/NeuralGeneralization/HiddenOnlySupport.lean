import NeuralGeneralization.TwoMarginSupport

/-! The literal hidden-only support. Its calibration has no added scalar
noise term, and zero readout energy is declared stable as in the manuscript.
The Borel proof handles the singular calibration by countably many positive
energy strata rather than assuming continuity at zero readout. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel
variable {d N r : ℕ}

def radius (c : ℝ) (w : Weights d N r) : ℝ :=
  c/Real.sqrt (((r:ℝ)+1)*readoutEnergy w)

def atInput (φ : ℝ → ℝ) (c : ℝ) (w : Weights d N r) (x : Cube d) : Prop :=
  readoutEnergy w = 0 ∨
    ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ (radius c w)^2 → η.2 = 0 →
      |clippedScore (noisyNetworkOutput φ w x η)-clippedScore (networkOutput φ w x)| ≤ 1/16

def support (φ : ℝ → ℝ) (c : ℝ) : Set (Weights d N r) :=
  {w | ∀ x,atInput φ c w x}

lemma radius_pos {c : ℝ} (hc : 0 < c) {w : Weights d N r} (hw : 0 < readoutEnergy w) :
    0 < radius c w := div_pos hc (Real.sqrt_pos.mpr (by positivity))

lemma hidden_unit_iff (φ : ℝ → ℝ) (w : Weights d N r) (x : Cube d)
    {R : ℝ} (hR : 0 < R) :
    (∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ R^2 → η.2=0 →
      |clippedScore (noisyNetworkOutput φ w x η)-clippedScore (networkOutput φ w x)| ≤ 1/16) ↔
    (∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 → η.2=0 →
      |clippedScore (noisyNetworkOutput φ w x (scaleDisturbance R η))-
        clippedScore (networkOutput φ w x)| ≤ 1/16) := by
  have hh := TwoMarginTransport.all_noise_iff_unitBall hR
    (fun η : NetworkDisturbance N r => η.2=0 →
      |clippedScore (noisyNetworkOutput φ w x η)-clippedScore (networkOutput φ w x)| ≤ 1/16)
  simpa only [scaleDisturbance,mul_eq_zero,hR.ne',false_or] using hh

def stratumRadius (n : ℕ) (c : ℝ) (w : Weights d N r) : ℝ :=
  c/Real.sqrt (max (1/((n:ℝ)+1)) (((r:ℝ)+1)*readoutEnergy w))

lemma continuous_stratumRadius (n : ℕ) (c : ℝ) :
    Continuous (stratumRadius (d := d) (N := N) (r := r) n c) := by
  apply continuous_const.div
    ((continuous_const.max (continuous_const.mul continuous_readoutEnergy)).sqrt)
  intro w
  apply (Real.sqrt_pos.mpr _).ne'
  exact (show 0 < 1/((n:ℝ)+1) by positivity).trans_le (le_max_left _ _)

lemma stratumRadius_eq {n : ℕ} {c : ℝ} {w : Weights d N r}
    (hw : 1/((n:ℝ)+1) ≤ ((r:ℝ)+1)*readoutEnergy w) : stratumRadius n c w = radius c w := by
  rw [stratumRadius,max_eq_right hw]
  rfl

def stratumStable (n : ℕ) (φ : ℝ → ℝ) (c : ℝ) (x : Cube d) : Set (Weights d N r) :=
  {w | ∀ η : NetworkDisturbance N r,noiseBudgetSq η ≤ 1 → η.2=0 →
    |clippedScore (noisyNetworkOutput φ w x (scaleDisturbance (stratumRadius n c w) η))-
      clippedScore (networkOutput φ w x)| ≤ 1/16}

lemma isClosed_stratumStable (n : ℕ) {φ : ℝ → ℝ} (hφ : Continuous φ) (c : ℝ) (x : Cube d) :
    IsClosed (stratumStable (N := N) (r := r) n φ c x) := by
  have hcont (η : NetworkDisturbance N r) : Continuous (fun w : Weights d N r =>
      noisyNetworkOutput φ w x (scaleDisturbance (stratumRadius n c w) η)) := by
    apply continuous_noisyNetworkOutput hφ x
    apply Continuous.prodMk
    · apply continuous_pi
      intro s
      apply continuous_pi
      intro i
      exact (continuous_stratumRadius n c).mul continuous_const
    · exact (continuous_stratumRadius n c).mul continuous_const
  simp only [stratumStable,Set.setOf_forall]
  exact isClosed_iInter fun η => isClosed_iInter fun _ => isClosed_iInter fun _ =>
    isClosed_le (((continuous_clippedScore.comp (hcont η)).sub
      (continuous_clippedScore.comp (continuous_networkOutput hφ x))).abs) continuous_const

lemma atInput_iff_strata {φ : ℝ → ℝ} {c : ℝ} (hc : 0 < c) (w : Weights d N r) (x : Cube d) :
    atInput φ c w x ↔ readoutEnergy w=0 ∨
      ∃ n : ℕ,1/((n:ℝ)+1) ≤ ((r:ℝ)+1)*readoutEnergy w ∧ w ∈ stratumStable n φ c x := by
  constructor
  · rintro (hz | hs)
    · exact Or.inl hz
    · by_cases hz : readoutEnergy w=0
      · exact Or.inl hz
      · have hp : 0 < readoutEnergy w := lt_of_le_of_ne (readoutEnergy_nonneg w) (Ne.symm hz)
        obtain ⟨n,hn⟩ := exists_nat_one_div_lt (show 0 < ((r:ℝ)+1)*readoutEnergy w by positivity)
        refine Or.inr ⟨n,hn.le,?_⟩
        have hh := (hidden_unit_iff φ w x (radius_pos hc hp)).mp hs
        intro η hη hzero
        rw [stratumRadius_eq hn.le]
        exact hh η hη hzero
  · rintro (hz | ⟨n,hn,hs⟩)
    · exact Or.inl hz
    · right
      have hp : 0 < readoutEnergy w := by
        have hh := (show 0 < 1/((n:ℝ)+1) by positivity).trans_le hn
        exact (mul_pos_iff.mp hh).resolve_right (by intro h; have hr : 0 ≤ (r:ℝ) := Nat.cast_nonneg _; linarith [h.1]) |>.2
      apply (hidden_unit_iff φ w x (radius_pos hc hp)).mpr
      intro η hη hzero
      have hh := hs η hη hzero
      rwa [stratumRadius_eq hn] at hh

lemma measurable_atInput {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c)
    (x : Cube d) : MeasurableSet {w : Weights d N r | atInput φ c w x} := by
  have heq : {w : Weights d N r | atInput φ c w x} =
      {w | readoutEnergy w=0} ∪ ⋃ n : ℕ,
        {w | 1/((n:ℝ)+1) ≤ ((r:ℝ)+1)*readoutEnergy w} ∩ stratumStable n φ c x := by
    ext w
    simp only [Set.mem_union,Set.mem_iUnion,Set.mem_inter_iff,Set.mem_setOf_eq]
    exact atInput_iff_strata hc w x
  rw [heq]
  exact (measurableSet_eq_fun continuous_readoutEnergy.measurable measurable_const).union
    (MeasurableSet.iUnion fun n =>
      (measurableSet_le measurable_const (continuous_const.mul continuous_readoutEnergy).measurable).inter
        (isClosed_stratumStable n hφ c x).measurableSet)

lemma measurable_support {φ : ℝ → ℝ} (hφ : Continuous φ) {c : ℝ} (hc : 0 < c) :
    MeasurableSet (support (d := d) (N := N) (r := r) φ c) := by
  simp only [support,Set.setOf_forall]
  exact MeasurableSet.iInter (measurable_atInput hφ hc)

end NeuralGeneralization.HiddenOnly
