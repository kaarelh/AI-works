import NeuralGeneralization.BatchTwoContinuousDepthCoding
import NeuralGeneralization.BatchTwoOnlineIIDMeasure
import NeuralGeneralization.BatchTwoContinuousDepthPairing
import Mathlib.Probability.Independence.InfinitePi

/-! The actual fixed nonatomic invariant Cantor input law, with bit-flip
symmetries giving the paired-input lower bound for posterior mixtures. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Filter MeasureTheory ProbabilityTheory
open scoped NNReal ENNReal Topology
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoOnline

def signLaw : Measure SignStream := iidQueryLaw Bool
instance : IsProbabilityMeasure signLaw := by unfold signLaw; infer_instance

def scalarCoding (ω : SignStream) : ℝ := coding ω

theorem scalarCoding_measurable : Measurable scalarCoding :=
  measurable_subtype_coe.comp coding_measurable

def cantorLaw : Measure ℝ := signLaw.map scalarCoding
instance : IsProbabilityMeasure cantorLaw := Measure.isProbabilityMeasure_map scalarCoding_measurable.aemeasurable

theorem signLaw_prefix_mass (n : ℕ) (η : SignStream) :
    signLaw.real {ω | ∀ i < n, ω i=η i} = (1/2 : ℝ)^n := by
  have hset : {ω : SignStream | ∀ i < n, ω i=η i} =
      sequencePrefix n ⁻¹' {sequencePrefix n η} := by
    ext ω
    simp only [mem_setOf_eq,mem_preimage,mem_singleton_iff,funext_iff,sequencePrefix]
    constructor
    · intro h i; exact h i i.isLt
    · intro h i hi; exact h ⟨i,hi⟩
  rw [hset,← map_measureReal_apply (measurable_sequencePrefix n) (measurableSet_singleton _)]
  change ((iidQueryLaw Bool).map (sequencePrefix n)).real {sequencePrefix n η} = _
  rw [iidQueryLaw_prefix,measureReal_def,uniformLaw_singleton]
  simp only [Fintype.card_fun,Fintype.card_bool,Fintype.card_fin,Nat.cast_pow,
    ENNReal.toReal_inv,ENNReal.toReal_pow,ENNReal.toReal_ofNat,ENNReal.toReal_natCast,one_div,inv_pow]
  norm_num

theorem signLaw_singleton (ω : SignStream) : signLaw {ω}=0 := by
  have hbound (n : ℕ) : signLaw.real {ω} ≤ (1/2 : ℝ)^n := by
    rw [← signLaw_prefix_mass n ω]
    exact measureReal_mono (by intro η hη; simpa only [mem_singleton_iff] using hη ▸ (fun i (_ : i<n) => rfl))
  have hz : signLaw.real {ω} = 0 := by
    apply le_antisymm _ measureReal_nonneg
    exact ge_of_tendsto (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num : (0 : ℝ) ≤ 1/2) (by norm_num))
      (Filter.Eventually.of_forall hbound)
  exact (ENNReal.toReal_eq_zero_iff _).mp hz |>.resolve_right (measure_ne_top _ _)

instance signLaw_nullSingleton : NullSingletonClass signLaw := ⟨signLaw_singleton⟩

theorem scalarCoding_injective : Function.Injective scalarCoding := fun _ _ h =>
  coding_injective (Subtype.ext h)

instance cantorLaw_nullSingleton : NullSingletonClass cantorLaw := by
  constructor
  intro x
  rw [cantorLaw,Measure.map_apply scalarCoding_measurable (measurableSet_singleton _)]
  exact ((subsingleton_singleton.preimage scalarCoding_injective)).measure_zero signLaw

theorem streamShift_measurable (n : ℕ) : Measurable (streamShift n) :=
  measurable_pi_lambda _ (fun i => measurable_pi_apply (n+i))

theorem signLaw_shift (n : ℕ) : signLaw.map (streamShift n)=signLaw := by
  exact Measure.map_infinitePi_infinitePi_of_inj (P := fun _ : ℕ => uniformLaw Bool)
    (f := fun i : ℕ => n+i) (fun i j h => Nat.add_left_cancel h)

theorem cantorLaw_invariant : cantorLaw.map expandingMap = cantorLaw := by
  rw [cantorLaw,Measure.map_map continuous_expandingMap.measurable scalarCoding_measurable]
  have he : expandingMap ∘ scalarCoding = scalarCoding ∘ streamShift 1 := by
    funext ω
    exact expandingMap_coding ω
  rw [he,← Measure.map_map scalarCoding_measurable (streamShift_measurable 1),signLaw_shift]

def flipCoordinate (r : ℕ) (ω : SignStream) : SignStream :=
  fun i => if i=r then !(ω i) else ω i

theorem flipCoordinate_measurable (r : ℕ) : Measurable (flipCoordinate r) := by
  apply measurable_pi_lambda
  intro i
  by_cases hi : i=r
  · simp only [flipCoordinate,if_pos hi]
    exact (measurable_of_finite (fun b : Bool => !b)).comp (measurable_pi_apply i)
  · simpa only [flipCoordinate,if_neg hi] using (measurable_pi_apply i : Measurable (fun ω : SignStream => ω i))

theorem uniformLaw_not : (uniformLaw Bool).map (fun b => !b)=uniformLaw Bool := by
  apply Measure.ext_of_singleton
  intro b
  rw [Measure.map_apply (measurable_of_finite _) (measurableSet_singleton _)]
  have he : (fun b : Bool => !b) ⁻¹' {b} = {!b} := by
    ext c
    cases b <;> cases c <;> simp
  rw [he]
  simp

theorem signLaw_flip (r : ℕ) : signLaw.map (flipCoordinate r)=signLaw := by
  unfold signLaw iidQueryLaw flipCoordinate
  rw [Measure.infinitePi_map_pi (fun _ : ℕ => uniformLaw Bool) (f := fun i b => if i=r then !b else b)
    (fun _ => measurable_of_finite _)]
  congr 1
  funext i
  by_cases hi : i=r
  · simp only [if_pos hi,uniformLaw_not]
  · simp only [if_neg hi]
    exact Measure.map_id

theorem scalarCoding_flip_law (r : ℕ) : signLaw.map (scalarCoding ∘ flipCoordinate r)=cantorLaw := by
  rw [← Measure.map_map scalarCoding_measurable (flipCoordinate_measurable r),signLaw_flip]
  rfl

theorem scalarCoding_pair_distance (r : ℕ) (ω : SignStream) :
    |scalarCoding ω-scalarCoding (flipCoordinate r ω)| ≤ (13/10 : ℝ)*(1/3)^r := by
  have h := coding_prefix_distance (ω := ω) (η := flipCoordinate r ω) r (fun i hi => by
    simp only [flipCoordinate,if_neg (by omega : i≠r)])
  exact h

theorem scalarCoding_pair_target_gap (r : ℕ) (ω : SignStream) :
    1 ≤ |expandingMap^[r] (scalarCoding ω)-expandingMap^[r] (scalarCoding (flipCoordinate r ω))| := by
  change 1 ≤ |expandingMap^[r] (coding ω)-expandingMap^[r] (coding (flipCoordinate r ω))|
  rw [expandingMap_iterate_coding,expandingMap_iterate_coding]
  have h := coding_opposite_first (ω := streamShift r ω) (η := streamShift r (flipCoordinate r ω))
  apply h
  simp only [streamShift,Nat.add_zero,flipCoordinate,↓reduceIte]
  cases ω r <;> decide

/-- A set of diameter smaller than the depth-n cylinder separation has
at most the mass of one depth-n cylinder. -/
theorem cantorLaw_small_diameter (n : ℕ) (E : Set ℝ) (hE : MeasurableSet E)
    (hdiam : ∀ x ∈ E, ∀ y ∈ E, |x-y| < (1/20 : ℝ)^n) :
    cantorLaw.real E ≤ (1/2 : ℝ)^(n+1) := by
  rw [cantorLaw,map_measureReal_apply scalarCoding_measurable hE]
  by_cases hnonempty : (scalarCoding ⁻¹' E).Nonempty
  · obtain ⟨η,hη⟩ := hnonempty
    rw [← signLaw_prefix_mass (n+1) η]
    refine measureReal_mono ?_ (measure_ne_top _ _)
    intro ω hω
    intro i hi
    by_contra hn
    have hs := coding_cylinder_separation n ⟨i,hi,hn⟩
    have hd := hdiam _ hω _ hη
    exact (not_le_of_gt hd) hs
  · rw [not_nonempty_iff_eq_empty.mp hnonempty]
    simp only [measureReal_empty]
    positivity

end NeuralGeneralization.BatchTwoContinuousDepthLower
