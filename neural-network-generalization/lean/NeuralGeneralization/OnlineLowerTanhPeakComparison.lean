import NeuralGeneralization.OnlineLowerTanhBiasPeakLoss
import NeuralGeneralization.OnlineLowerTanhLocalBias

/-! Finite noncentral peak losses dominate the actual local optimization gain. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def finiteBiasPeakError (J:ℕ) : ℝ := 1+∑l∈Finset.range (J+1),
  (|biasPeakErrorConstant (oddBiasPeakPolynomial l)|+
   |biasPeakErrorConstant (evenBiasPeakPolynomial l)|)

lemma finiteBiasPeakError_pos (J:ℕ) : 0<finiteBiasPeakError J := by
  unfold finiteBiasPeakError
  positivity

lemma finiteBiasPeakError_bounds {J l:ℕ} (hl:l≤J) :
    biasPeakErrorConstant (oddBiasPeakPolynomial l)≤finiteBiasPeakError J ∧
    biasPeakErrorConstant (evenBiasPeakPolynomial l)≤finiteBiasPeakError J := by
  have hh:=Finset.single_le_sum (f:=fun l:ℕ=>
    |biasPeakErrorConstant (oddBiasPeakPolynomial l)|+
    |biasPeakErrorConstant (evenBiasPeakPolynomial l)|)
    (fun l _=>by positivity) (show l∈Finset.range (J+1) by simp;omega)
  have h1:=le_abs_self (biasPeakErrorConstant (oddBiasPeakPolynomial l))
  have h2:=le_abs_self (biasPeakErrorConstant (evenBiasPeakPolynomial l))
  unfold finiteBiasPeakError
  constructor <;> linarith [abs_nonneg (biasPeakErrorConstant (oddBiasPeakPolynomial l)),
    abs_nonneg (biasPeakErrorConstant (evenBiasPeakPolynomial l))]

lemma peak_loss_beats_local_gain {n M S p E K α:ℝ}
    (hn:0<n) (hnM:n≤M) (hMn:M≤2*n) (hE:0≤E) (hK:0≤K)
    (hα:0<α) (hS:α≤S) (hlarge:E+K/α<n)
    (hp:p≤S*(1-2/M+E/M^2)) : p+K/n^2<S := by
  have hM:0<M:=hn.trans_le hnM
  have hS0:0<S:=hα.trans_le hS
  have htwo:1/n≤2/M := by
    apply (div_le_div_iff₀ hn hM).mpr
    nlinarith
  have hEsq:E/M^2≤E/n^2 := by
    apply (div_le_div_iff₀ (sq_pos_of_pos hM) (sq_pos_of_pos hn)).mpr
    nlinarith [mul_nonneg hE (show 0≤M^2-n^2 by nlinarith)]
  have hp':p≤S*(1-1/n+E/n^2) := by
    apply hp.trans
    exact mul_le_mul_of_nonneg_left (by linarith) hS0.le
  have hnE:0<n-E := by linarith [div_nonneg hK hα.le]
  have hKS:K<S*(n-E) := by
    have hk:K<α*(n-E) := by
      have hh:K/α<n-E:=by linarith
      have hh':=(div_lt_iff₀ hα).mp hh
      nlinarith
    exact hk.trans_le (mul_le_mul_of_nonneg_right hS hnE.le)
  have hfrac:K/n^2<S*(n-E)/n^2 := (div_lt_div_iff_of_pos_right (sq_pos_of_pos hn)).mpr hKS
  have hid:S*(1-1/n+E/n^2)+S*(n-E)/n^2=S := by field_simp;ring
  linarith

/-- A common degree threshold works for every fixed finite set of peaks and
all gains, with the normalized central coefficient bounded below by `α`. -/
theorem finite_noncentral_peaks_strict (J:ℕ) (K α:ℝ) (hK:0≤K) (hα:0<α) :
    ∃N:ℕ,0<N ∧ ∀r l:ℕ,1≤l → l≤J → ∀a:ℝ,1≤a →
      (N≤2*r+1 → α≤Real.sqrt (2*(r:ℝ)+1)*balancedParity r a →
        Real.sqrt (2*(r:ℝ)+1)*((-1:ℝ)^(r+l)*
          parityCorrelation (fun _:Fin (2*r+1)=>a) (2*(l:ℝ)*a))+
          K/(2*(r:ℝ)+1)^2<Real.sqrt (2*(r:ℝ)+1)*balancedParity r a) ∧
      (N≤2*r → α≤Real.sqrt (2*(r:ℝ))*balancedParity r a →
        Real.sqrt (2*(r:ℝ))*((-1:ℝ)^(r+l)*
          parityCorrelation (fun _:Fin (2*r)=>a) ((2*(l:ℝ)+1)*a))+
          K/(2*(r:ℝ))^2<Real.sqrt (2*(r:ℝ))*balancedParity r a) := by
  let E:=finiteBiasPeakError J
  have hE:0<E:=finiteBiasPeakError_pos J
  obtain ⟨N,hN⟩:=exists_nat_gt (E+K/α+1)
  have hNpos:0<N := by
    have hcast:(0:ℝ)<N:=by linarith [div_nonneg hK hα.le]
    exact_mod_cast hcast
  refine ⟨N,hNpos,?_⟩
  intro r l hl hlJ a ha
  have hlR:(1:ℝ)≤l:=by exact_mod_cast hl
  have hq:=balancedParity_pos_of_one_le r a ha
  have hbounds:=finiteBiasPeakError_bounds hlJ
  have hM:0<2*(r:ℝ)+1:=by positivity
  have hM2:0<(2*(r:ℝ)+1)^2:=sq_pos_of_pos hM
  constructor
  · intro hn hαS
    have hnR:(N:ℝ)≤2*(r:ℝ)+1:=by exact_mod_cast hn
    have herr:((-1:ℝ)^(r+l)*parityCorrelation (fun _:Fin (2*r+1)=>a) (2*(l:ℝ)*a))/
        balancedParity r a≤1-2/(2*(r:ℝ)+1)+E/(2*(r:ℝ)+1)^2 := by
      have he:=(abs_le.mp (odd_bulk_peak_ratio_error r l a ha)).2
      have heE:=div_le_div_of_nonneg_right hbounds.1 hM2.le
      have hpen:2/(2*(r:ℝ)+1)≤2*(l:ℝ)^2/(2*(r:ℝ)+1):=
        div_le_div_of_nonneg_right (by nlinarith) hM.le
      linarith
    have hp:=mul_le_mul_of_nonneg_left ((div_le_iff₀ hq).mp herr)
      (Real.sqrt_nonneg (2*(r:ℝ)+1))
    apply peak_loss_beats_local_gain hM le_rfl (by linarith) hE.le hK hα hαS (by linarith)
    nlinarith
  · intro hn hαS
    have hnR:(N:ℝ)≤2*(r:ℝ):=by exact_mod_cast hn
    have hn0:0<2*(r:ℝ):=by exact_mod_cast lt_of_lt_of_le hNpos hn
    have hn1:(1:ℝ)≤2*(r:ℝ):=by exact_mod_cast (show 1≤2*r from lt_of_lt_of_le hNpos hn)
    have herr:((-1:ℝ)^(r+l)*parityCorrelation (fun _:Fin (2*r)=>a) ((2*(l:ℝ)+1)*a))/
        balancedParity r a≤1-2/(2*(r:ℝ)+1)+E/(2*(r:ℝ)+1)^2 := by
      have he:=(abs_le.mp (even_bulk_peak_ratio_error r l a ha)).2
      have heE:=div_le_div_of_nonneg_right hbounds.2 hM2.le
      have hpen:2/(2*(r:ℝ)+1)≤2*(l:ℝ)*((l:ℝ)+1)/(2*(r:ℝ)+1):=
        div_le_div_of_nonneg_right (by nlinarith) hM.le
      linarith
    have hp:=mul_le_mul_of_nonneg_left ((div_le_iff₀ hq).mp herr)
      (Real.sqrt_nonneg (2*(r:ℝ)))
    apply peak_loss_beats_local_gain (M:=2*(r:ℝ)+1) hn0 (by linarith) (by linarith)
      hE.le hK hα hαS (by linarith)
    nlinarith

end NeuralGeneralization.OnlineLowerTanh
