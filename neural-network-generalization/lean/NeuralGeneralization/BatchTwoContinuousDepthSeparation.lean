import NeuralGeneralization.BatchTwoContinuousDepthSphere
import NeuralGeneralization.BatchTwoContinuousDepthFrostman
import Mathlib.Probability.Independence.Basic

/-! Quantitative iid sample separation for the exact fixed Cantor input law. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoContinuous

def sampleSeparation (n : ℕ) : ℝ := (100*(n : ℝ)^2)^(-1/frostmanExponent)

theorem sampleSeparation_pos {n : ℕ} (hn : 0 < n) : 0 < sampleSeparation n :=
  Real.rpow_pos_of_pos (by
    have hnr : (0 : ℝ) < n := by exact_mod_cast hn
    positivity) _

theorem sampleSeparation_power {n : ℕ} (hn : 0 < n) :
    (sampleSeparation n)^frostmanExponent = 1/(100*(n : ℝ)^2) := by
  have hα := frostmanExponent_pos.ne'
  unfold sampleSeparation
  rw [← Real.rpow_mul (by positivity),div_mul_cancel₀ _ hα,Real.rpow_neg_one]
  rw [one_div]

theorem sampleSeparation_le {n : ℕ} (hn : 0 < n) : sampleSeparation n≤1/100 := by
  have hn1 : (1 : ℝ)≤n := by exact_mod_cast hn
  have hb : (1 : ℝ)≤100*(n : ℝ)^2 := by nlinarith
  have hex : -1/frostmanExponent≤(-1 : ℝ) := by
    rw [div_le_iff₀ frostmanExponent_pos]
    linarith [frostmanExponent_le_one]
  unfold sampleSeparation
  calc
    _ ≤ (100*(n : ℝ)^2)^(-1 : ℝ) := Real.rpow_le_rpow_of_exponent_le hb hex
    _ = 1/(100*(n : ℝ)^2) := by rw [Real.rpow_neg_one,one_div]
    _ ≤ 1/100 := one_div_le_one_div_of_le (by norm_num) (by nlinarith)

theorem small_ball_loose {c δ : ℝ} (hδ : 0 < δ) (hsmall : 2*δ≤1) :
    cantorLaw.real {t | |t-c|<δ} ≤ 4*δ^frostmanExponent := by
  have h := cantorLaw_small_ball (c := c) hδ hsmall
  rw [Real.mul_rpow (by norm_num) hδ.le] at h
  have htwo : (2 : ℝ)^frostmanExponent≤2 := by
    simpa only [Real.rpow_one] using
      (Real.rpow_le_rpow_of_exponent_le (by norm_num : (1 : ℝ)≤2) frostmanExponent_le_one)
  have hp : 0≤δ^frostmanExponent := Real.rpow_nonneg hδ.le _
  nlinarith

theorem cantor_product_close {δ : ℝ} (hδ : 0 < δ) (hsmall : 2*δ≤1) :
    (cantorLaw.prod cantorLaw).real {p | |p.1-p.2|<δ} ≤ 4*δ^frostmanExponent := by
  have hs : MeasurableSet {p : ℝ×ℝ | |p.1-p.2|<δ} :=
    measurableSet_lt ((measurable_fst.sub measurable_snd).abs) measurable_const
  have hb : (cantorLaw.prod cantorLaw) {p | |p.1-p.2|<δ} ≤ ENNReal.ofReal (4*δ^frostmanExponent) := by
    rw [Measure.prod_apply hs]
    calc
      _ ≤ ∫⁻ _x, ENNReal.ofReal (4*δ^frostmanExponent) ∂cantorLaw := by
        apply lintegral_mono
        intro x
        have h := small_ball_loose (c := x) hδ hsmall
        change cantorLaw {t | |x-t|<δ}≤ENNReal.ofReal (4*δ^frostmanExponent)
        rw [← ENNReal.ofReal_toReal (measure_ne_top cantorLaw {t | |x-t|<δ})]
        apply ENNReal.ofReal_le_ofReal
        simpa only [Measure.real,abs_sub_comm] using h
      _ = _ := by simp
  have h := ENNReal.toReal_mono ENNReal.ofReal_ne_top hb
  simpa only [Measure.real,ENNReal.toReal_ofReal (by positivity : (0 : ℝ)≤4*δ^frostmanExponent)] using h

theorem inputLaw_first_coordinate : inputLaw.map (fun x => x 0)=cantorLaw := by
  rw [inputLaw,Measure.map_map (measurable_pi_apply 0) sphereCoding_measurable]
  rfl

theorem iid_pair_first_law {n : ℕ} (i j : Fin n) (hij : i≠j) :
    (Measure.pi (fun _ : Fin n => inputLaw)).map (fun s => ((s i) 0,(s j) 0))=
      cantorLaw.prod cantorLaw := by
  have hm : ∀ k : Fin n, AEMeasurable (fun x : RealInput 2 => x 0) inputLaw :=
    fun _ => (measurable_pi_apply 0).aemeasurable
  have hind := (iIndepFun_pi (μ := fun _ : Fin n => inputLaw) hm).indepFun hij
  have hmap := hind.map_prod_eq_prod_map_map
    (((measurable_pi_apply 0).comp (measurable_pi_apply i)).aemeasurable)
    (((measurable_pi_apply 0).comp (measurable_pi_apply j)).aemeasurable)
  simp only [Function.comp_def] at hmap
  rw [hmap]
  have he (k : Fin n) : (Measure.pi (fun _ : Fin n => inputLaw)).map (fun s => (s k) 0)=cantorLaw := by
    change (Measure.pi (fun _ : Fin n => inputLaw)).map
      ((fun x : RealInput 2 => x 0) ∘ (fun s : Fin n → RealInput 2 => s k))=cantorLaw
    rw [← Measure.map_map (measurable_pi_apply 0) (measurable_pi_apply k),
      (measurePreserving_eval (fun _ : Fin n => inputLaw) k).map_eq,inputLaw_first_coordinate]
  rw [he,he]

theorem iid_pair_close {n : ℕ} (i j : Fin n) (hij : i≠j) {δ : ℝ}
    (hδ : 0 < δ) (hsmall : 2*δ≤1) :
    (Measure.pi (fun _ : Fin n => inputLaw)).real {s | |(s i) 0-(s j) 0|<δ} ≤
      4*δ^frostmanExponent := by
  have hm : Measurable (fun s : Fin n → RealInput 2 => ((s i) 0,(s j) 0)) := by fun_prop
  have hs : MeasurableSet {p : ℝ×ℝ | |p.1-p.2|<δ} :=
    measurableSet_lt ((measurable_fst.sub measurable_snd).abs) measurable_const
  have he := map_measureReal_apply (μ := Measure.pi (fun _ : Fin n => inputLaw)) hm hs
  rw [iid_pair_first_law i j hij] at he
  have hh := cantor_product_close hδ hsmall
  rw [he] at hh
  exact hh

theorem ordered_pair_count (n : ℕ) :
    (∑ i : Fin n, ∑ j : Fin n, if i < j then (1 : ℝ) else 0) ≤ (n : ℝ)^2/2 := by
  let S : ℝ := ∑ i : Fin n, ∑ j : Fin n, if i < j then (1 : ℝ) else 0
  have hrev : (∑ i : Fin n, ∑ j : Fin n, if j < i then (1 : ℝ) else 0)=S := by
    rw [Finset.sum_comm]
  have heach (i j : Fin n) : (if i < j then (1 : ℝ) else 0)+(if j < i then 1 else 0)+
      (if i=j then 1 else 0)=1 := by
    rcases lt_trichotomy i j with h|h|h
    · simp [h,not_lt_of_ge h.le,h.ne]
    · simp [h]
    · simp [h,not_lt_of_ge h.le,h.ne']
  have hsum : S+S+(n : ℝ)=(n : ℝ)^2 := by
    calc
      S+S+(n : ℝ) = ∑ i : Fin n, ∑ j : Fin n,
          ((if i < j then (1 : ℝ) else 0)+(if j < i then 1 else 0)+(if i=j then 1 else 0)) := by
        simp only [Finset.sum_add_distrib,hrev]
        simp [S,pow_two]
      _ = _ := by simp only [heach]; simp [pow_two]
  change S≤_
  nlinarith [(Nat.cast_nonneg n : (0 : ℝ)≤n)]

def separatedSample (n : ℕ) : Set (Fin n → RealInput 2) :=
  {s | ∀ i j, i≠j → sampleSeparation n≤|(s i) 0-(s j) 0|}

/-- The paper's exact 49/50 sample probability, with its exact Delta_n. -/
theorem separatedSample_probability {n : ℕ} (hn : 0 < n) :
    (49/50 : ℝ)≤(Measure.pi (fun _ : Fin n => inputLaw)).real (separatedSample n) := by
  classical
  let μ := Measure.pi (fun _ : Fin n => inputLaw)
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
      exact iid_pair_close i j hij.ne (sampleSeparation_pos hn) (by linarith [sampleSeparation_le hn])
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
