import Paulsen.ModerateDiagonal
import Mathlib.Analysis.Real.Pi.Bounds

/-! Explicit, deliberately loose universal parameters for the moderate regime. -/

namespace Paulsen
noncomputable section

def moderateSeedA : ℝ := 10^130
def moderateSeedD : ℝ := 10^40
def moderateSeedZeta : ℝ := 1/10^20
def moderateSeedK : ℝ := 10^30
def moderateSeedEpsilon : ℝ := 1/10^130

theorem moderate_log_budgets {n : ℕ} (hn : 0<n) :
    1/2≤Real.log (2*(n:ℝ)) ∧
    Real.log n+200≤401*Real.log (2*(n:ℝ)) ∧
    Real.log n+2≤5*Real.log (2*(n:ℝ)) ∧
    Real.log (100*(n:ℝ))≤201*Real.log (2*(n:ℝ)) := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hn1 : (1:ℝ)≤n := by exact_mod_cast hn
  have hl0 : 0≤Real.log n := Real.log_nonneg hn1
  have hl2 : (1/2:ℝ)≤Real.log 2 := by linarith [Real.log_two_gt_d9]
  have hl : Real.log (2*(n:ℝ))=Real.log 2+Real.log n := Real.log_mul (by norm_num) hn'.ne'
  have hl100 : Real.log (100:ℝ)≤99 := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<100)
    norm_num at hh
    exact hh
  rw [Real.log_mul (by norm_num : (100:ℝ)≠0) hn'.ne']
  constructor
  · linarith
  constructor
  · linarith
  constructor <;> linarith

theorem moderate_dimension_budgets {n d : ℕ} (hn : 0<n) (hdn : d≤n)
    (hlarge : moderateSeedA*Real.log (2*(n:ℝ))≤(d:ℝ)) :
    20000000≤n ∧ 1000000≤d ∧
    100*(moderateSeedD^2+1)*(Real.log n+200)≤moderateSeedZeta^2*(d:ℝ) ∧
    4096000000000000*(Real.log n+2)≤(d:ℝ) ∧
    (4000000000000*Real.pi^2)*Real.log (100*(n:ℝ))≤(d:ℝ) ∧
    10000*(Real.log n+2)≤(1/64:ℝ)^2*(d:ℝ) := by
  obtain ⟨hL,h200,h2,h100⟩ := moderate_log_budgets hn
  have hn1 : (1:ℝ)≤n := by exact_mod_cast hn
  have hlog0 : 0≤Real.log n := Real.log_nonneg hn1
  have hdn' : (d:ℝ)≤n := by exact_mod_cast hdn
  have hsize : (20000000:ℝ)≤d := by
    norm_num [moderateSeedA] at hlarge
    linarith
  refine ⟨by exact_mod_cast hsize.trans hdn', by exact_mod_cast (show (1000000:ℝ)≤d by linarith),
    ?_,?_,?_,?_⟩
  · norm_num [moderateSeedA,moderateSeedD,moderateSeedZeta] at *
    nlinarith only [h200,hL,hlarge]
  · norm_num [moderateSeedA] at hlarge
    nlinarith only [h2,hL,hlarge]
  · have hpi : Real.pi^2≤16 := by nlinarith [Real.pi_lt_four,Real.pi_pos]
    have hpositive : 0≤Real.log (100*(n:ℝ)) :=
      Real.log_nonneg (by nlinarith)
    have hh := mul_le_mul_of_nonneg_right hpi hpositive
    norm_num [moderateSeedA] at hlarge
    nlinarith only [hh,h100,hL,hlarge]
  · norm_num [moderateSeedA] at hlarge
    nlinarith only [h2,hL,hlarge]

theorem moderate_amplitude_budgets {ε : ℝ} (hε : 0<ε) (hcap : ε≤moderateSeedEpsilon) :
    let t := Real.sqrt (moderateSeedK*ε)
    0<t ∧ t^2=moderateSeedK*ε ∧ t^2≤1/(10^24:ℝ) ∧
    moderateSeedD^2*t^2≤1/2 ∧ ε≤1/2 ∧
    ε+(4*ε+3*moderateSeedZeta+moderateSeedZeta+10^12*t)*t^2≤(1/10^18)*t^2 := by
  dsimp only
  have hK : 0<moderateSeedK := by norm_num [moderateSeedK]
  have ht : 0<Real.sqrt (moderateSeedK*ε) := Real.sqrt_pos.mpr (mul_pos hK hε)
  have ht2 : (Real.sqrt (moderateSeedK*ε))^2=moderateSeedK*ε :=
    Real.sq_sqrt (mul_pos hK hε).le
  have hsmall : (Real.sqrt (moderateSeedK*ε))^2≤1/(10^100:ℝ) := by
    rw [ht2]
    norm_num [moderateSeedK,moderateSeedEpsilon] at *
    linarith
  have htbound : Real.sqrt (moderateSeedK*ε)≤1/(10^50:ℝ) := by
    nlinarith [sq_nonneg (Real.sqrt (moderateSeedK*ε)-1/(10^50:ℝ))]
  refine ⟨ht,ht2,by norm_num at *; linarith,?_,?_,?_⟩
  · norm_num [moderateSeedD] at *
    linarith
  · norm_num [moderateSeedEpsilon] at *
    linarith
  · have hcoeff : 4*ε+3*moderateSeedZeta+moderateSeedZeta+
        10^12*Real.sqrt (moderateSeedK*ε)≤1/(10^19:ℝ) := by
      norm_num [moderateSeedZeta,moderateSeedEpsilon] at *
      linarith
    have hh := mul_le_mul_of_nonneg_right hcoeff (sq_nonneg (Real.sqrt (moderateSeedK*ε)))
    have ht2' : (Real.sqrt (moderateSeedK*ε))^2=(10^30:ℝ)*ε := ht2
    nlinarith only [hh,ht2',hε.le]

theorem moderate_graph_penalty {n d : ℕ} (hn : 0<n) (hd : 0<d)
    {t : ℝ} (ht : 0<t) (hsmall : t^2≤1/(10^24:ℝ)) :
    t^2*(2/(n:ℝ)+80/(d:ℝ)+8/(moderateSeedD^2*t^2))≤1/4 := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hd' : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have hn1 : (1:ℝ)≤n := by exact_mod_cast hn
  have hd1 : (1:ℝ)≤d := by exact_mod_cast hd
  have h₁ : (2:ℝ)/(n:ℝ)≤2 := (div_le_iff₀ hn').mpr (by linarith)
  have h₂ : (80:ℝ)/(d:ℝ)≤80 := (div_le_iff₀ hd').mpr (by linarith)
  have hh := mul_le_mul_of_nonneg_left (add_le_add h₁ h₂) (sq_nonneg t)
  have he : t^2*(2/(n:ℝ)+80/(d:ℝ)+8/(moderateSeedD^2*t^2))=
      t^2*(2/(n:ℝ)+80/(d:ℝ))+8/(10^80:ℝ) := by
    dsimp only [moderateSeedD]
    field_simp
  rw [he]
  nlinarith only [hh,hsmall]

end
end Paulsen
