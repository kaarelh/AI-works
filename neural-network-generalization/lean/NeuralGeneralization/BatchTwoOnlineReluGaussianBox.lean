import NeuralGeneralization.GaussianSmallBall
import Mathlib.Analysis.Real.Pi.Bounds

/-! Literal Gaussian target-box geometry for the finite-variance ReLU budget. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
variable {ι : Type*} [Fintype ι] [Nonempty ι]

def boxRadius (ρ : ℝ) : ℝ := ρ/Real.sqrt (Fintype.card ι:ℝ)
def centeredBox (a : ι→ℝ) (ρ : ℝ) : Set (ι→ℝ) :=
  Set.pi Set.univ (fun i=>Set.Icc (a i-boxRadius (ι:=ι) ρ) (a i+boxRadius (ι:=ι) ρ))

theorem boxRadius_pos {ρ : ℝ} (hρ : 0<ρ) : 0<boxRadius (ι:=ι) ρ := by
  unfold boxRadius
  exact div_pos hρ (Real.sqrt_pos.mpr (Nat.cast_pos.mpr Fintype.card_pos))

theorem card_mul_boxRadius_sq (ρ : ℝ) :
    (Fintype.card ι:ℝ)*(boxRadius (ι:=ι) ρ)^2=ρ^2 := by
  have hp : (0:ℝ)<Fintype.card ι := Nat.cast_pos.mpr Fintype.card_pos
  rw [boxRadius,div_pow,Real.sq_sqrt hp.le]
  field_simp

theorem centeredBox_sq_dist_le (a : ι→ℝ) {ρ : ℝ} (hρ : 0<ρ)
    {x : ι→ℝ} (hx : x∈centeredBox a ρ) : ∑i,(x i-a i)^2≤ρ^2 := by
  calc
    _ ≤ ∑_i:ι,(boxRadius (ι:=ι) ρ)^2 := by
      apply Finset.sum_le_sum
      intro i _
      have hi := hx i (Set.mem_univ i)
      have ha : |x i-a i|≤boxRadius (ι:=ι) ρ := abs_le.mpr ⟨by linarith [hi.1],by linarith [hi.2]⟩
      simpa only [sq_abs] using pow_le_pow_left₀ (abs_nonneg _) ha 2
    _ = _ := by simpa only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul] using card_mul_boxRadius_sq (ι:=ι) ρ

theorem sum_abs_le_sqrt_card {K : ℝ} (hK : 0≤K) (a : ι→ℝ) (ha : ∑i,(a i)^2≤K) :
    ∑i,|a i|≤Real.sqrt (Fintype.card ι:ℝ)*Real.sqrt K := by
  have hh := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ) (fun i=>|a i|) (fun _:ι=>(1:ℝ))
  simp only [mul_one,sq_abs,one_pow,Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_one] at hh
  have hp : (0:ℝ)≤Fintype.card ι := Nat.cast_nonneg _
  have he : (Real.sqrt (Fintype.card ι:ℝ)*Real.sqrt K)^2=(Fintype.card ι:ℝ)*K := by
    rw [mul_pow,Real.sq_sqrt hp,Real.sq_sqrt hK]
  have hb := mul_le_mul_of_nonneg_right ha hp
  have hn : 0≤∑i,|a i| := Finset.sum_nonneg (fun i _=>abs_nonneg _)
  have hs : 0≤Real.sqrt (Fintype.card ι:ℝ)*Real.sqrt K := by positivity
  nlinarith

theorem expanded_box_energy_le {K ρ : ℝ} (hK : 0≤K) (hρ : 0<ρ)
    (a : ι→ℝ) (ha : ∑i,(a i)^2≤K) :
    ∑i,(|a i|+boxRadius (ι:=ι) ρ)^2≤(Real.sqrt K+ρ)^2 := by
  have hh := sum_abs_le_sqrt_card hK a ha
  have hb : 0≤boxRadius (ι:=ι) ρ := (boxRadius_pos hρ).le
  have he : (∑i,(|a i|+boxRadius (ι:=ι) ρ)^2)=
      (∑i,(a i)^2)+2*boxRadius (ι:=ι) ρ*(∑i,|a i|)+ρ^2 := by
    simp_rw [add_sq,sq_abs]
    rw [Finset.sum_add_distrib,Finset.sum_add_distrib]
    simp only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul,card_mul_boxRadius_sq]
    rw [Finset.mul_sum]
    congr 1
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hmul := mul_le_mul_of_nonneg_left hh (show 0≤2*boxRadius (ι:=ι) ρ by positivity)
  have hc : 2*boxRadius (ι:=ι) ρ*(Real.sqrt (Fintype.card ι:ℝ)*Real.sqrt K)=2*ρ*Real.sqrt K := by
    unfold boxRadius
    have hp : 0<Real.sqrt (Fintype.card ι:ℝ) := Real.sqrt_pos.mpr (Nat.cast_pos.mpr Fintype.card_pos)
    field_simp
  rw [hc] at hmul
  rw [he]
  nlinarith [Real.sq_sqrt hK]

/-- The exact logarithmic small-ball cost used by the online ReLU paper. -/
def gaussianBoxBudget (K S ρ : ℝ) : ℝ :=
  (Real.sqrt K+ρ)^2/2+S*Real.log (3*max 1 (Real.sqrt S/ρ))

theorem gaussian_box_prefactor {v S ρ : ℝ} (hv : 0<v) (hS : 0<S)
    (hρ : 0<ρ) (hdim : (Fintype.card ι:ℝ)*v≤S) :
    (3*max 1 (Real.sqrt S/ρ))⁻¹ ≤
      2*boxRadius (ι:=ι) ρ*(Real.sqrt (2*Real.pi*v))⁻¹ := by
  have hp : (0:ℝ)<Fintype.card ι := Nat.cast_pos.mpr Fintype.card_pos
  have hroot : 0<Real.sqrt (2*Real.pi*v) := Real.sqrt_pos.mpr (by positivity)
  have hrootp : 0<Real.sqrt (Fintype.card ι:ℝ) := Real.sqrt_pos.mpr hp
  have hrootS : 0<Real.sqrt S := Real.sqrt_pos.mpr hS
  have hprod : Real.sqrt (Fintype.card ι:ℝ)*Real.sqrt (2*Real.pi*v)≤3*Real.sqrt S := by
    have hpi : 2*Real.pi≤9 := by linarith [Real.pi_lt_four]
    have hh := mul_le_mul_of_nonneg_left hdim (show 0≤2*Real.pi by positivity)
    have hj := mul_le_mul_of_nonneg_right hpi hS.le
    have he : (Real.sqrt (Fintype.card ι:ℝ)*Real.sqrt (2*Real.pi*v))^2=
        (Fintype.card ι:ℝ)*(2*Real.pi*v) := by
      rw [mul_pow,Real.sq_sqrt hp.le,Real.sq_sqrt (by positivity)]
    nlinarith [Real.sq_sqrt hS.le, mul_nonneg hrootp.le hroot.le]
  have hD : 0<3*max 1 (Real.sqrt S/ρ) := by positivity
  have hDρ : 3*Real.sqrt S≤(3*max 1 (Real.sqrt S/ρ))*ρ := by
    have hh := mul_le_mul_of_nonneg_right (le_max_right (1:ℝ) (Real.sqrt S/ρ)) hρ.le
    rw [div_mul_cancel₀ _ hρ.ne'] at hh
    linarith
  rw [inv_eq_one_div,div_le_iff₀ hD]
  calc
    1 ≤ (2*ρ*(3*max 1 (Real.sqrt S/ρ)))/
        (Real.sqrt (Fintype.card ι:ℝ)*Real.sqrt (2*Real.pi*v)) := by
      apply (le_div_iff₀ (mul_pos hrootp hroot)).mpr
      nlinarith
    _ = _ := by unfold boxRadius; field_simp

theorem gaussian_centeredBox_mass_lower {K S ρ : ℝ}
    (hK : 0≤K) (hS : 0<S) (hρ : 0<ρ) (a : ι→ℝ)
    (ha : ∑i,(a i)^2≤K) (v : ℝ≥0) (hv : v≠0)
    (hdim : (Fintype.card ι:ℝ)*(v:ℝ)≤S) :
    Real.exp (-gaussianBoxBudget K S ρ/(v:ℝ)) ≤
      (Measure.pi fun _i:ι=>gaussianReal 0 v).real (centeredBox a ρ) := by
  have hvp : 0<(v:ℝ) := NNReal.coe_pos.mpr (pos_iff_ne_zero.mpr hv)
  let D : ℝ := 3*max 1 (Real.sqrt S/ρ)
  let c : ℝ := 2*boxRadius (ι:=ι) ρ*(Real.sqrt (2*Real.pi*(v:ℝ)))⁻¹
  have hD : 1≤D := by dsimp [D]; linarith [le_max_left (1:ℝ) (Real.sqrt S/ρ)]
  have hDp : 0<D := lt_of_lt_of_le zero_lt_one hD
  have hlog : 0≤Real.log D := Real.log_nonneg hD
  have hc : D⁻¹≤c := gaussian_box_prefactor hvp hS hρ hdim
  have hpow : Real.exp (-(Fintype.card ι:ℝ)*Real.log D)≤c^(Fintype.card ι) := by
    have hh := pow_le_pow_left₀ (inv_nonneg.mpr hDp.le) hc (Fintype.card ι)
    have he : D⁻¹=Real.exp (-Real.log D) := by rw [Real.exp_neg,Real.exp_log hDp]
    rw [he,← Real.exp_nat_mul] at hh
    simpa only [mul_neg,neg_mul] using hh
  have hexp : Real.exp (-(Real.sqrt K+ρ)^2/(2*(v:ℝ)))≤
      Real.exp (-(∑i,(|a i|+boxRadius (ι:=ι) ρ)^2)/(2*(v:ℝ))) := by
    apply Real.exp_le_exp.mpr
    exact div_le_div_of_nonneg_right (neg_le_neg (expanded_box_energy_le hK hρ a ha)) (by positivity)
  have hprod := GaussianTail.gaussian_rectangle_mass_lower a
    (fun _:ι=>boxRadius (ι:=ι) ρ) (fun _=>(boxRadius_pos hρ).le)
    (fun _:ι=>v) (fun _=>hv)
  have heq : (∏i,2*boxRadius (ι:=ι) ρ*(Real.sqrt (2*Real.pi*(v:ℝ)))⁻¹*
      Real.exp (-(|a i|+boxRadius (ι:=ι) ρ)^2/(2*(v:ℝ))))=
      c^(Fintype.card ι)*Real.exp (-(∑i,(|a i|+boxRadius (ι:=ι) ρ)^2)/(2*(v:ℝ))) := by
    rw [Finset.prod_mul_distrib,Finset.prod_const,Finset.card_univ,← Real.exp_sum]
    congr 2
    rw [← Finset.sum_div,Finset.sum_neg_distrib]
  rw [heq] at hprod
  have hdim' : (Fintype.card ι:ℝ)≤S/(v:ℝ) := (le_div_iff₀ hvp).mpr hdim
  have hb : Real.exp (-gaussianBoxBudget K S ρ/(v:ℝ))≤
      Real.exp (-(Fintype.card ι:ℝ)*Real.log D)*
        Real.exp (-(Real.sqrt K+ρ)^2/(2*(v:ℝ))) := by
    rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    have hh := mul_le_mul_of_nonneg_right hdim' hlog
    dsimp [gaussianBoxBudget,D] at *
    field_simp
    nlinarith
  have hbpos := boxRadius_pos (ι:=ι) hρ
  exact hb.trans ((mul_le_mul hpow hexp (Real.exp_pos _).le (by dsimp [c]; positivity)).trans hprod)

end NeuralGeneralization.BatchTwoOnlineReluFinite
