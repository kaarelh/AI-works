import NeuralGeneralization.BatchTwoContinuousDepthJitterLaw

/-! Conditioning on the independent jitter preserves the exact Frostman
constant and hence the manuscript's 49/50 iid separation probability. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoContinuous
variable (r : ℕ) (ν : Measure (Jitter r)) [IsProbabilityMeasure ν]

theorem jitteredScalarLaw_interval_bound {a b : ℝ} (hl : 0 < b-a) (hu : b-a ≤ 1) :
    (jitteredScalarLaw r ν).real (Icc a b) ≤ 2*(b-a)^frostmanExponent := by
  have hm : MeasurableSet (jitteredScalar r ⁻¹' Icc a b) :=
    (jitteredScalar_measurable r) measurableSet_Icc
  have hb : jitteredScalarLaw r ν (Icc a b) ≤ ENNReal.ofReal (2*(b-a)^frostmanExponent) := by
    rw [jitteredScalarLaw, Measure.map_apply (jitteredScalar_measurable r) measurableSet_Icc,
      Measure.prod_apply_symm hm]
    calc
      _ ≤ ∫⁻ _u, ENNReal.ofReal (2*(b-a)^frostmanExponent) ∂ν := by
        apply lintegral_mono
        intro u
        have he : (fun ω => (ω,u)) ⁻¹' (jitteredScalar r ⁻¹' Icc a b) =
            scalarCoding ⁻¹' Icc (a-u.val) (b-u.val) := by
          ext ω
          simp only [mem_preimage, mem_Icc, jitteredScalar]
          constructor <;> rintro ⟨h₁,h₂⟩ <;> constructor <;> linarith
        dsimp only
        rw [he, ← Measure.map_apply scalarCoding_measurable measurableSet_Icc]
        change cantorLaw (Icc (a-u.val) (b-u.val)) ≤ _
        rw [← ENNReal.ofReal_toReal (measure_ne_top cantorLaw _)]
        apply ENNReal.ofReal_le_ofReal
        have h := cantorLaw_interval_bound (a := a-u.val) (b := b-u.val)
          (by linarith) (by linarith)
        simpa only [sub_sub_sub_cancel_right, Measure.real] using h
      _ = _ := by simp
  have h := ENNReal.toReal_mono ENNReal.ofReal_ne_top hb
  simpa only [Measure.real, ENNReal.toReal_ofReal (by positivity : (0 : ℝ) ≤ 2*(b-a)^frostmanExponent)] using h

theorem jitteredScalarLaw_small_ball {c δ : ℝ} (hδ : 0 < δ) (hsmall : 2*δ ≤ 1) :
    (jitteredScalarLaw r ν).real {t | |t-c|<δ} ≤ 2*(2*δ)^frostmanExponent := by
  have h := jitteredScalarLaw_interval_bound r ν (a := c-δ) (b := c+δ) (by linarith) (by linarith)
  rw [show c+δ-(c-δ)=2*δ by ring] at h
  refine (measureReal_mono (μ := jitteredScalarLaw r ν) ?_).trans h
  intro t ht
  have htc := abs_lt.mp (show |t-c|<δ from ht)
  exact ⟨by linarith [htc.1],by linarith [htc.2]⟩

theorem jittered_small_ball_loose {c δ : ℝ} (hδ : 0 < δ) (hsmall : 2*δ≤1) :
    (jitteredScalarLaw r ν).real {t | |t-c|<δ} ≤ 4*δ^frostmanExponent := by
  have h := jitteredScalarLaw_small_ball r ν (c := c) hδ hsmall
  rw [Real.mul_rpow (by norm_num) hδ.le] at h
  have htwo : (2 : ℝ)^frostmanExponent≤2 := by
    simpa only [Real.rpow_one] using
      (Real.rpow_le_rpow_of_exponent_le (by norm_num : (1 : ℝ)≤2) frostmanExponent_le_one)
  have hp : 0≤δ^frostmanExponent := Real.rpow_nonneg hδ.le _
  nlinarith

theorem jittered_product_close {δ : ℝ} (hδ : 0 < δ) (hsmall : 2*δ≤1) :
    ((jitteredScalarLaw r ν).prod (jitteredScalarLaw r ν)).real {p | |p.1-p.2|<δ} ≤ 4*δ^frostmanExponent := by
  have hs : MeasurableSet {p : ℝ×ℝ | |p.1-p.2|<δ} :=
    measurableSet_lt ((measurable_fst.sub measurable_snd).abs) measurable_const
  have hb : ((jitteredScalarLaw r ν).prod (jitteredScalarLaw r ν)) {p | |p.1-p.2|<δ} ≤ ENNReal.ofReal (4*δ^frostmanExponent) := by
    rw [Measure.prod_apply hs]
    calc
      _ ≤ ∫⁻ _x, ENNReal.ofReal (4*δ^frostmanExponent) ∂(jitteredScalarLaw r ν) := by
        apply lintegral_mono
        intro x
        have h := jittered_small_ball_loose r ν (c := x) hδ hsmall
        change (jitteredScalarLaw r ν) {t | |x-t|<δ}≤ENNReal.ofReal (4*δ^frostmanExponent)
        rw [← ENNReal.ofReal_toReal (measure_ne_top (jitteredScalarLaw r ν) {t | |x-t|<δ})]
        apply ENNReal.ofReal_le_ofReal
        simpa only [Measure.real,abs_sub_comm] using h
      _ = _ := by simp
  have h := ENNReal.toReal_mono ENNReal.ofReal_ne_top hb
  simpa only [Measure.real,ENNReal.toReal_ofReal (by positivity : (0 : ℝ)≤4*δ^frostmanExponent)] using h

theorem jittered_iid_pair_first_law {n : ℕ} (i j : Fin n) (hij : i≠j) :
    (Measure.pi (fun _ : Fin n => (jitteredInputLaw r ν))).map (fun s => ((s i) 0,(s j) 0))=
      (jitteredScalarLaw r ν).prod (jitteredScalarLaw r ν) := by
  have hm : ∀ k : Fin n, AEMeasurable (fun x : RealInput 2 => x 0) (jitteredInputLaw r ν) :=
    fun _ => (measurable_pi_apply 0).aemeasurable
  have hind := (iIndepFun_pi (μ := fun _ : Fin n => (jitteredInputLaw r ν)) hm).indepFun hij
  have hmap := hind.map_prod_eq_prod_map_map
    (((measurable_pi_apply 0).comp (measurable_pi_apply i)).aemeasurable)
    (((measurable_pi_apply 0).comp (measurable_pi_apply j)).aemeasurable)
  simp only [Function.comp_def] at hmap
  rw [hmap]
  have he (k : Fin n) : (Measure.pi (fun _ : Fin n => (jitteredInputLaw r ν))).map (fun s => (s k) 0)=(jitteredScalarLaw r ν) := by
    change (Measure.pi (fun _ : Fin n => (jitteredInputLaw r ν))).map
      ((fun x : RealInput 2 => x 0) ∘ (fun s : Fin n → RealInput 2 => s k))=(jitteredScalarLaw r ν)
    rw [← Measure.map_map (measurable_pi_apply 0) (measurable_pi_apply k),
      (measurePreserving_eval (fun _ : Fin n => (jitteredInputLaw r ν)) k).map_eq,jitteredInputLaw_scalar r ν]
  rw [he,he]

theorem jittered_iid_pair_close {n : ℕ} (i j : Fin n) (hij : i≠j) {δ : ℝ}
    (hδ : 0 < δ) (hsmall : 2*δ≤1) :
    (Measure.pi (fun _ : Fin n => (jitteredInputLaw r ν))).real {s | |(s i) 0-(s j) 0|<δ} ≤
      4*δ^frostmanExponent := by
  have hm : Measurable (fun s : Fin n → RealInput 2 => ((s i) 0,(s j) 0)) := by fun_prop
  have hs : MeasurableSet {p : ℝ×ℝ | |p.1-p.2|<δ} :=
    measurableSet_lt ((measurable_fst.sub measurable_snd).abs) measurable_const
  have he := map_measureReal_apply (μ := Measure.pi (fun _ : Fin n => (jitteredInputLaw r ν))) hm hs
  rw [jittered_iid_pair_first_law r ν i j hij] at he
  have hh := jittered_product_close r ν hδ hsmall
  rw [he] at hh
  exact hh

/-- The paper's exact 49/50 sample probability, with its exact Delta_n. -/
theorem jittered_separatedSample_probability {n : ℕ} (hn : 0 < n) :
    (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n => (jitteredInputLaw r ν))).real (separatedSample n) := by
  classical
  let μ := Measure.pi (fun _ : Fin n => (jitteredInputLaw r ν))
  let E : Fin n → Fin n → Set (Fin n → RealInput 2) :=
    fun i j => if i < j then {s | |(s i) 0-(s j) 0|<sampleSeparation n} else ∅
  have he : (separatedSample n)ᶜ=⋃ i, ⋃ j, E i j := by
    ext s
    simp only [separatedSample,mem_compl_iff,mem_setOf_eq,not_forall,_root_.not_imp,not_le,mem_iUnion]
    constructor
    · rintro ⟨i,j,hij,hd⟩
      rcases lt_or_gt_of_ne hij with hij|hji
      · exact ⟨i,j,by simpa only [E,if_pos hij,mem_setOf_eq] using hd⟩
      · exact ⟨j,i,by simpa only [E,if_pos hji,mem_setOf_eq,abs_sub_comm] using hd⟩
    · rintro ⟨i,j,hs⟩
      by_cases hij : i < j
      · exact ⟨i,j,hij.ne,by simpa only [E,if_pos hij,mem_setOf_eq] using hs⟩
      · simpa [E,hij] using hs
  have hb (i j : Fin n) : μ.real (E i j) ≤
      (if i < j then (1 : ℝ) else 0)*(4*(sampleSeparation n)^frostmanExponent) := by
    by_cases hij : i < j
    · simp only [E,if_pos hij,one_mul]
      exact jittered_iid_pair_close r ν i j hij.ne (sampleSeparation_pos hn) (by linarith [sampleSeparation_le hn])
    · simp [E,hij]
  have hunion : μ.real (separatedSample n)ᶜ ≤ (1/50 : ℝ) := by
    rw [he]
    calc
      _ ≤ ∑ i : Fin n, μ.real (⋃ j, E i j) := measureReal_iUnion_fintype_le _
      _ ≤ ∑ i : Fin n, ∑ j : Fin n, μ.real (E i j) :=
        Finset.sum_le_sum (fun _ _ => measureReal_iUnion_fintype_le _)
      _ ≤ ∑ i : Fin n, ∑ j : Fin n,
          (if i < j then (1 : ℝ) else 0)*(4*(sampleSeparation n)^frostmanExponent) :=
        Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => hb i j
      _ = (∑ i : Fin n, ∑ j : Fin n, if i < j then (1 : ℝ) else 0)*
          (4*(sampleSeparation n)^frostmanExponent) := by simp only [Finset.sum_mul]
      _ ≤ ((n : ℝ)^2/2)*(4*(sampleSeparation n)^frostmanExponent) :=
        mul_le_mul_of_nonneg_right (ordered_pair_count n) (mul_nonneg (by norm_num) (Real.rpow_nonneg (sampleSeparation_pos hn).le _))
      _ = 1/50 := by
        rw [sampleSeparation_power hn]
        have hn0 : (n : ℝ)≠0 := by exact_mod_cast hn.ne'
        field_simp
        norm_num
  have hmeas : MeasurableSet (separatedSample n) := by
    unfold separatedSample
    simp only [setOf_forall]
    apply MeasurableSet.iInter
    intro i
    apply MeasurableSet.iInter
    intro j
    apply MeasurableSet.iInter
    intro _
    exact measurableSet_le measurable_const (by fun_prop)
  have hcomp := measureReal_compl (μ := μ) hmeas
  simp only [probReal_univ] at hcomp
  change (49/50 : ℝ)≤μ.real (separatedSample n)
  linarith

end NeuralGeneralization.BatchTwoContinuousDepthLower
