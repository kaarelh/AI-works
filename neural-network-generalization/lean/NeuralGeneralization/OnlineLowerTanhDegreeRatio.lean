import NeuralGeneralization.OnlineLowerTanhInterpolation
import NeuralGeneralization.OnlineLowerTanhHolomorphicGBounds
import NeuralGeneralization.OnlineLowerTanhKappaRatio

/-! Uniform finite-degree ratio estimates for actual balanced coefficients. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Complex
namespace NeuralGeneralization.OnlineLowerTanh

def balancedNormalized (r:ℕ) (a:ℝ) : ℝ := balancedParity r a/oddParityKappa r

def scalarFirstBound : ℝ := 4*weightedMajorantSum 3 2

def scalarFirstError : ℝ :=
  4*weightedMajorantSum 7 4+4*∑'j:ℕ,complexRemainderMajorant j

lemma scalarFirstBound_nonneg : 0≤scalarFirstBound := by
  unfold scalarFirstBound
  positivity [weightedMajorantSum_nonneg (by norm_num : (0:ℝ)≤3) 2]

lemma scalarFirstError_nonneg : 0≤scalarFirstError := by
  unfold scalarFirstError
  have hsum:0≤∑'j:ℕ,complexRemainderMajorant j := tsum_nonneg (fun j=>by
    unfold complexRemainderMajorant logisticMajorant; positivity)
  positivity [weightedMajorantSum_nonneg (by norm_num : (0:ℝ)≤7) 4]

lemma complexF1_uniform_bound {a:ℂ} (ha:1≤a.re) : ‖complexF1 a‖≤scalarFirstBound := by
  have h:=weightedLogistic_norm_bound (fun j=>(-1:ℂ)^j*(prefactoredFirst j:ℂ)) 3 2
    prefactoredFirst_weight_bound ha
  unfold complexF1 scalarFirstBound
  simpa only [norm_mul,norm_neg,norm_ofNat] using mul_le_mul_of_nonneg_left h (by norm_num : (0:ℝ)≤4)

lemma complexF2_uniform_bound {a:ℂ} (ha:1≤a.re) :
    ‖complexF2 a‖≤4*weightedMajorantSum 7 4 := by
  have h:=weightedLogistic_norm_bound (fun j=>(-1:ℂ)^j*(prefactoredSecond j:ℂ)) 7 4
    prefactoredSecond_weight_bound ha
  unfold complexF2
  simpa only [norm_mul,norm_neg,norm_ofNat] using mul_le_mul_of_nonneg_left h (by norm_num : (0:ℝ)≤4)

lemma complexF_first_order_bound {z a:ℂ} (hz:0≤z.re) (hn:1≤‖z‖)
    (ha:1≤a.re) :
    ‖complexF z a-(complexF0 a+complexF1 a/z)‖≤scalarFirstError/‖z‖^2 := by
  have hp:0<‖z‖ := lt_of_lt_of_le (by norm_num) hn
  have hnz:z≠0 := norm_ne_zero_iff.mp hp.ne'
  have hR:0≤4*∑'j:ℕ,complexRemainderMajorant j := by
    apply mul_nonneg (by norm_num)
    apply tsum_nonneg
    intro j
    unfold complexRemainderMajorant logisticMajorant
    positivity
  have he : complexF z a-(complexF0 a+complexF1 a/z)=
      (complexF z a-(complexF0 a+complexF1 a/z+complexF2 a/z^2))+complexF2 a/z^2 := by ring
  rw [he]
  apply (norm_add_le _ _).trans
  rw [norm_div,norm_pow]
  calc
    _ ≤ (4*∑'j:ℕ,complexRemainderMajorant j)/‖z‖^3+
        (4*weightedMajorantSum 7 4)/‖z‖^2 :=
      add_le_add (complexF_expansion_bound hz hnz ha)
        (div_le_div_of_nonneg_right (complexF2_uniform_bound ha) (sq_nonneg _))
    _ ≤ (4*∑'j:ℕ,complexRemainderMajorant j)/‖z‖^2+
        (4*weightedMajorantSum 7 4)/‖z‖^2 := by
      apply add_le_add _ le_rfl
      apply div_le_div_of_nonneg_left hR (sq_pos_of_pos hp)
      nlinarith
    _ = _ := by unfold scalarFirstError; ring

lemma balancedNormalized_first_order_bound (r:ℕ) (a:ℝ) (ha:1≤a) :
    |balancedNormalized r a-(scalarF0 a+scalarF1 a/(2*(r:ℝ)+1))|≤
      scalarFirstError/(2*(r:ℝ)+1)^2 := by
  have h:=complexF_first_order_bound (z:=((2*r+1:ℕ):ℂ)) (a:=(a:ℂ))
    (by simp only [Complex.natCast_re]; positivity)
    (by simp only [Complex.norm_natCast]; push_cast; nlinarith [Nat.cast_nonneg (α:=ℝ) r]) ha
  rw [complexF_odd_eq_balanced,complexF0_ofReal,complexF1_ofReal] at h
  have he : (balancedParity r a/oddParityKappa r:ℂ)-
      ((scalarF0 a:ℂ)+(scalarF1 a:ℂ)/((2*r+1:ℕ):ℂ)) =
      ((balancedNormalized r a-(scalarF0 a+scalarF1 a/(2*(r:ℝ)+1)):ℝ):ℂ) := by
    unfold balancedNormalized
    push_cast
    rfl
  rw [Complex.ofReal_div,he,Complex.norm_real,Real.norm_eq_abs,Complex.norm_natCast] at h
  simpa only [Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat,Nat.cast_one] using h

lemma scalarF1_uniform_bound (a:ℝ) (ha:1≤a) : |scalarF1 a|≤scalarFirstBound := by
  have h:=complexF1_uniform_bound (a:=(a:ℂ)) ha
  simpa only [complexF1_ofReal,Complex.norm_real,Real.norm_eq_abs] using h

lemma balancedNormalized_lower (r:ℕ) (a:ℝ) (ha:1≤a) : (1/2:ℝ)<balancedNormalized r a := by
  have hl:=balancedParity_lower r a (by linarith)
  have ht:=scalar_tanh_monotone ha
  have h1:=tanh_one_gt_three_quarters
  have hk:=oddParityKappa_pos r
  unfold balancedNormalized
  apply (lt_div_iff₀ hk).mpr
  nlinarith

lemma balancedNormalized_shift_error (r j:ℕ) (a:ℝ) (ha:1≤a) :
    |balancedNormalized (r+j) a-balancedNormalized r a|≤
      (2*scalarFirstError+2*(j:ℝ)*scalarFirstBound)/(2*(r:ℝ)+1)^2 := by
  let n:ℝ:=2*(r:ℝ)+1
  let m:ℝ:=2*((r+j:ℕ):ℝ)+1
  have hn:0<n := by dsimp [n]; positivity
  have hmn:n≤m := by dsimp [n,m]; push_cast; nlinarith [Nat.cast_nonneg (α:=ℝ) j]
  have hm:0<m := lt_of_lt_of_le hn hmn
  have hdiff:m-n=2*(j:ℝ) := by dsimp [m,n]; push_cast; ring
  have hE0:=balancedNormalized_first_order_bound r a ha
  have hE1:=balancedNormalized_first_order_bound (r+j) a ha
  have hF:=scalarF1_uniform_bound a ha
  change |balancedNormalized r a-(scalarF0 a+scalarF1 a/n)|≤scalarFirstError/n^2 at hE0
  change |balancedNormalized (r+j) a-(scalarF0 a+scalarF1 a/m)|≤scalarFirstError/m^2 at hE1
  have hdiv : |scalarF1 a/m-scalarF1 a/n|≤2*(j:ℝ)*scalarFirstBound/n^2 := by
    have he : scalarF1 a/m-scalarF1 a/n=-(scalarF1 a)*(m-n)/(n*m) := by field_simp; ring
    rw [he,abs_div,abs_mul,abs_neg,hdiff,abs_of_nonneg (by positivity : 0≤2*(j:ℝ)),
      abs_of_pos (mul_pos hn hm)]
    calc
      _ ≤ (scalarFirstBound*(2*(j:ℝ)))/(n*m) :=
        div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hF (by positivity)) (mul_pos hn hm).le
      _ ≤ (scalarFirstBound*(2*(j:ℝ)))/n^2 :=
        div_le_div_of_nonneg_left (mul_nonneg scalarFirstBound_nonneg (by positivity))
          (sq_pos_of_pos hn) (by nlinarith)
      _ = _ := by ring
  have hE1' : scalarFirstError/m^2≤scalarFirstError/n^2 :=
    div_le_div_of_nonneg_left scalarFirstError_nonneg (sq_pos_of_pos hn) (by nlinarith)
  have he : balancedNormalized (r+j) a-balancedNormalized r a=
      (balancedNormalized (r+j) a-(scalarF0 a+scalarF1 a/m))+
      (scalarF1 a/m-scalarF1 a/n)-
      (balancedNormalized r a-(scalarF0 a+scalarF1 a/n)) := by ring
  rw [he]
  apply (abs_sub _ _).trans
  apply (add_le_add (abs_add_le _ _) le_rfl).trans
  calc
    _ ≤ scalarFirstError/n^2+2*(j:ℝ)*scalarFirstBound/n^2+scalarFirstError/n^2 :=
      add_le_add (add_le_add (hE1.trans hE1') hdiv) hE0
    _ = _ := by dsimp [n]; ring

def balancedDegreeRatioError (j:ℕ) : ℝ :=
  2*(j:ℝ)^2+4*scalarFirstError+4*(j:ℝ)*scalarFirstBound

/-- Actual coefficient ratios, uniformly for every gain at least one. -/
theorem balancedParity_shift_ratio_error (r j:ℕ) (a:ℝ) (ha:1≤a) :
    |balancedParity (r+j) a/balancedParity r a-(1-(j:ℝ)/(2*(r:ℝ)+1))|≤
      balancedDegreeRatioError j/(2*(r:ℝ)+1)^2 := by
  let n:ℝ:=2*(r:ℝ)+1
  let f:=balancedNormalized r a
  let g:=balancedNormalized (r+j) a
  let p:=kappaShiftProduct n j
  have hn:0<n := by dsimp [n]; positivity
  have hf:(1/2:ℝ)<f:=balancedNormalized_lower r a ha
  have hf0:0<f := by linarith
  have hp:=kappaShiftProduct_bounds n hn j
  change 0<p ∧ p≤1 at hp
  have he:=kappaShiftProduct_error n hn j
  change 0≤p-(1-(j:ℝ)/n) ∧ p-(1-(j:ℝ)/n)≤2*(j:ℝ)^2/n^2 at he
  have hg:=balancedNormalized_shift_error r j a ha
  change |g-f|≤(2*scalarFirstError+2*(j:ℝ)*scalarFirstBound)/n^2 at hg
  have hratio:balancedParity (r+j) a/balancedParity r a=p*(g/f) := by
    dsimp [p,g,f,balancedNormalized,n]
    rw [←oddParityKappa_shift_ratio]
    have hk:oddParityKappa (r+j)≠0 := (oddParityKappa_pos _).ne'
    have hk0:oddParityKappa r≠0 := (oddParityKappa_pos _).ne'
    field_simp
  have hgf : |g/f-1|≤2*((2*scalarFirstError+2*(j:ℝ)*scalarFirstBound)/n^2) := by
    rw [show g/f-1=(g-f)/f by field_simp,abs_div,abs_of_pos hf0]
    calc
      _ ≤ ((2*scalarFirstError+2*(j:ℝ)*scalarFirstBound)/n^2)/(1/2) :=
        div_le_div₀ (by positivity [scalarFirstError_nonneg,scalarFirstBound_nonneg]) hg (by norm_num) hf.le
      _ = _ := by ring
  rw [hratio]
  have hid : p*(g/f)-(1-(j:ℝ)/n)=(p-(1-(j:ℝ)/n))+p*(g/f-1) := by ring
  rw [hid]
  apply (abs_add_le _ _).trans
  rw [abs_of_nonneg he.1,abs_mul,abs_of_pos hp.1]
  have hmul : p*|g/f-1|≤2*((2*scalarFirstError+2*(j:ℝ)*scalarFirstBound)/n^2) := by
    calc
      _ ≤ 1*|g/f-1| := mul_le_mul_of_nonneg_right hp.2 (abs_nonneg _)
      _ ≤ _ := by simpa using hgf
  apply (add_le_add he.2 hmul).trans
  exact le_of_eq (by dsimp [balancedDegreeRatioError,n]; ring)

end NeuralGeneralization.OnlineLowerTanh
