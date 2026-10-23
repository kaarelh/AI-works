import NeuralGeneralization.BatchTwoMergingGeluStability
import NeuralGeneralization.BatchTwoMergingGrid

/-! A finite, width-independent grid for the exact GELU perspective model. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel ParameterGrid

abbrev GeluGridIndex (d Q r : ℕ) := WeightIndex d Q r ⊕ (Fin (r+1)×Fin Q)
instance (d Q r : ℕ) : Fintype (GeluGridIndex d Q r) := by
  unfold GeluGridIndex
  infer_instance
instance (d Q r : ℕ) : DecidableEq (GeluGridIndex d Q r) := by
  unfold GeluGridIndex
  infer_instance

abbrev GeluGridCode (d Q r T : ℕ) := GeluGridIndex d Q r→GridInt T

def geluGridWeights (d Q r T : ℕ) (R : ℝ) (c : GeluGridCode d Q r T) :
    Weights d Q r := fun i=>R*decode T c (Sum.inl i)
def geluGridMasses (d Q r T : ℕ) (c : GeluGridCode d Q r T) :
    Fin (r+1)→Fin Q→ℝ := fun s i=>max (1/(T:ℝ)) (decode T c (Sum.inr (s,i)))

def geluGridAmplification (d Q : ℕ) (R : ℝ) : ℝ := 4*(d+1+Q)*(R+1)
def geluGridResolution (d Q r : ℕ) (R : ℝ) : ℕ :=
  ⌈64*R*(r+2)*geluGridAmplification d Q R^(r+2)⌉₊

theorem geluGridAmplification_bounds (d Q : ℕ) {R : ℝ} (hR : 1≤R) :
    1≤geluGridAmplification d Q R ∧
    (d+1:ℝ)*R≤geluGridAmplification d Q R ∧
    2*(d+1:ℝ)+1≤geluGridAmplification d Q R ∧
    2*(Q:ℝ)*R≤geluGridAmplification d Q R ∧
    2*(Q:ℝ)+1≤geluGridAmplification d Q R := by
  unfold geluGridAmplification
  have hd : (0:ℝ)≤d := Nat.cast_nonneg _
  have hQ : (0:ℝ)≤Q := Nat.cast_nonneg _
  have hdR : 0≤(d:ℝ)*R := mul_nonneg hd (by linarith)
  have hQR : 0≤(Q:ℝ)*R := mul_nonneg hQ (by linarith)
  constructor
  · nlinarith
  constructor
  · nlinarith
  constructor
  · nlinarith
  constructor <;> nlinarith

theorem geluGridResolution_pos (d Q r : ℕ) {R : ℝ} (hR : 1≤R) :
    0<geluGridResolution d Q r R := by
  apply Nat.ceil_pos.mpr
  have ha := (geluGridAmplification_bounds d Q hR).1
  positivity

theorem geluGridCode_card (d Q r T : ℕ) :
    Fintype.card (GeluGridCode d Q r T) =
      (2*T+1)^(Q*(d+2)+r*Q^2+(r+1)*Q) := by
  rw [Fintype.card_fun,gridInt_card]
  congr 1
  simp only [GeluGridIndex,WeightIndex,Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
  ring

theorem geluGridMasses_pos {d Q r T : ℕ} (hT : 0<T) (c : GeluGridCode d Q r T)
    (s : Fin (r+1)) (i : Fin Q) : 0<geluGridMasses d Q r T c s i := by
  exact lt_of_lt_of_le (by positivity) (le_max_left _ _)

theorem geluGridWeights_abs_le {d Q r T : ℕ} {R : ℝ} (hR : 0≤R) (hT : 0<T)
    (c : GeluGridCode d Q r T) (i : WeightIndex d Q r) :
    |geluGridWeights d Q r T R c i|≤R := by
  rw [geluGridWeights,abs_mul,abs_of_nonneg hR]
  simpa using mul_le_mul_of_nonneg_left (decode_abs_le_one T hT c (Sum.inl i)) hR

private theorem positive_clamp_error {u v η : ℝ} (hu : 0≤u) (hη : 0≤η)
    (hclose : |u-v|≤η) : |u-max η v|≤2*η := by
  have hm : |max u η-max v η|≤η :=
    (abs_max_sub_max_le_abs u v η).trans hclose
  have hr : |u-max u η|≤η := by
    by_cases h : u≤η
    · rw [max_eq_right h,abs_of_nonpos (by linarith)]
      linarith
    · rw [max_eq_left (le_of_not_ge h)]
      simpa using hη
  have ht := abs_sub_le u (max u η) (max v η)
  rw [max_comm v η] at ht hm
  linarith

theorem exists_geluGrid_close {d Q r T : ℕ} {R : ℝ} (hR : 1≤R) (hT : 0<T)
    (w : Weights d Q r) (mass : Fin (r+1)→Fin Q→ℝ)
    (hw : ∀i,|w i|≤R) (hmass : ∀s i,0<mass s i ∧ mass s i≤1) :
    ∃c : GeluGridCode d Q r T,
      (∀i,|w i-geluGridWeights d Q r T R c i|≤2*R/T) ∧
      (∀s i,|mass s i-geluGridMasses d Q r T c s i|≤2*R/T) := by
  let values : GeluGridIndex d Q r→ℝ := Sum.elim (fun i=>w i/R) (fun si=>mass si.1 si.2)
  have hRp : 0<R := by linarith
  have hv : ∀i,|values i|≤1 := by
    intro i
    cases i with
    | inl i =>
      change |w i/R|≤1
      rw [abs_div,abs_of_pos hRp]
      exact (div_le_one hRp).mpr (hw i)
    | inr si =>
      change |mass si.1 si.2|≤1
      rw [abs_of_pos (hmass _ _).1]
      exact (hmass _ _).2
  obtain ⟨c,hc⟩ := exists_close_grid T hT values hv
  have ht : (0:ℝ)<T := by exact_mod_cast hT
  refine ⟨c,?_,?_⟩
  · intro i
    have hh := mul_le_mul_of_nonneg_left (hc (Sum.inl i)) hRp.le
    change R*|w i/R-decode T c (Sum.inl i)|≤R*(1/(T:ℝ)) at hh
    have he : R*|w i/R-decode T c (Sum.inl i)|=
        |w i-geluGridWeights d Q r T R c i| := by
      rw [←abs_of_pos hRp,←abs_mul]
      congr 1
      rw [abs_of_pos hRp]
      unfold geluGridWeights
      field_simp
    rw [he] at hh
    exact hh.trans (by rw [mul_one_div]; exact div_le_div_of_nonneg_right (by linarith) ht.le)
  · intro s i
    have hh := positive_clamp_error (hmass s i).1.le (by positivity : 0≤1/(T:ℝ))
      (hc (Sum.inr (s,i)))
    change |mass s i-geluGridMasses d Q r T c s i|≤2*(1/(T:ℝ)) at hh
    exact hh.trans (by rw [mul_one_div]; exact div_le_div_of_nonneg_right (by linarith) ht.le)

theorem exists_gelu_grid_output_cover {d Q r : ℕ} {R : ℝ} (hR : 1≤R)
    (w : Weights d Q r) (mass : Fin (r+1)→Fin Q→ℝ)
    (hw : ∀i,|w i|≤R) (hmass : ∀s i,0<mass s i ∧ mass s i≤1) :
    ∃c : GeluGridCode d Q r (geluGridResolution d Q r R),∀x,
      |perspectiveOutput w mass x-
        perspectiveOutput (geluGridWeights d Q r (geluGridResolution d Q r R) R c)
          (geluGridMasses d Q r (geluGridResolution d Q r R) c) x|≤1/32 := by
  let T := geluGridResolution d Q r R
  let A := geluGridAmplification d Q R
  have hRp : 0<R := by linarith
  have hT : 0<T := geluGridResolution_pos d Q r hR
  obtain ⟨c,hc,hm⟩ := exists_geluGrid_close hR hT w mass hw hmass
  refine ⟨c,fun x=>?_⟩
  obtain ⟨ha,hdR,hd,hQR,hQ⟩ := geluGridAmplification_bounds d Q hR
  have hout := perspectiveOutput_difference w (geluGridWeights d Q r T R c)
    mass (geluGridMasses d Q r T c) (fun s i=>(hmass s i).1)
    (geluGridMasses_pos hT c) hRp.le ha (by positivity : 0≤2*R/(T:ℝ))
    hdR hd hQR hQ hw (geluGridWeights_abs_le hRp.le hT c) hc hm x
  have ht : (0:ℝ)<T := by exact_mod_cast hT
  have hceil : 64*R*(r+2)*A^(r+2)≤(T:ℝ) := Nat.le_ceil _
  refine hout.trans ?_
  change (2*R)/(T:ℝ)*(r+2)*A^(r+2)≤1/32
  rw [div_mul_eq_mul_div,div_mul_eq_mul_div]
  apply (div_le_iff₀ ht).mpr
  nlinarith

end NeuralGeneralization.BatchTwoMerging
