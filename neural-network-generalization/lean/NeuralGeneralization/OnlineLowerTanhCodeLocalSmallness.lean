import NeuralGeneralization.OnlineLowerTanhBalancedCode
import NeuralGeneralization.OnlineLowerTanhCodeLocalSharp

/-! The literal eventual smallness of the paper's local off-orientation coefficient.
The threshold is uniform in the rail length above any fixed positive logarithmic
square lower bound, and in every retained family and ambient atom.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma code_local_paper_base_le_inverse {D : ℝ} (hD : 2≤D) :
    4*Real.sqrt D/(Real.pi*D^2)≤D*(D^2)⁻¹ := by
  have hDp : 0<D := by linarith
  have hs0 := Real.sqrt_nonneg D
  have hs2 := Real.sq_sqrt hDp.le
  have hs : (4:ℝ)/3≤Real.sqrt D := by nlinarith
  have hm := mul_le_mul_of_nonneg_right hs hs0
  have hpi := mul_le_mul_of_nonneg_right Real.pi_gt_three.le hDp.le
  apply (div_le_iff₀ (by positivity : 0<Real.pi*D^2)).mpr
  have he : D*(D^2)⁻¹*(Real.pi*D^2)=Real.pi*D := by field_simp <;> ring
  rw [he]
  nlinarith

/-- An explicit finite numerical criterion for the displayed local constant. -/
theorem code_local_paper_coefficient_small {D W C₀ : ℝ} {p R : ℕ}
    (hD : 2≤D) (hp : (p:ℝ)≤D) (hR : 16≤R)
    (hW0 : 0≤W) (hW : W≤D^2)
    (hS : max 2 (96*Real.sqrt 6*W^2)≤D^3)
    (hC₀ : 0<C₀) (hC : C₀*Real.sqrt D≤D) :
    2*W*(p:ℝ)*D^4*(4*Real.sqrt D/(Real.pi*D^2))^R ≤
      1/(2*max 2 (96*Real.sqrt 6*W^2)*C₀*Real.sqrt D) := by
  have hDp : 0<D := by linarith
  have hS0 : 0<max 2 (96*Real.sqrt 6*W^2) := lt_of_lt_of_le (by norm_num) (le_max_left _ _)
  have hden : 0<2*max 2 (96*Real.sqrt 6*W^2)*C₀*Real.sqrt D := by positivity
  let E := 2*D^2*(p:ℝ)*(D*(D^2)⁻¹)^R/((D^2)⁻¹)^2
  have hE0 : 0≤E := by dsimp [E]; positivity
  have hA0 : 0≤2*W*(p:ℝ)*D^4*(4*Real.sqrt D/(Real.pi*D^2))^R := by positivity
  have hAE : 2*W*(p:ℝ)*D^4*(4*Real.sqrt D/(Real.pi*D^2))^R≤E := by
    calc
      _≤2*D^2*(p:ℝ)*D^4*(D*(D^2)⁻¹)^R := by
        gcongr
        exact code_local_paper_base_le_inverse hD
      _=E := by dsimp [E]; field_simp <;> ring
  have habs := (inverse_power_absorption_numerics D p R hD hp hR).2.2.2
  change 2*D^3*D*E≤1 at habs
  have hf : 2*max 2 (96*Real.sqrt 6*W^2)*C₀*Real.sqrt D≤2*D^3*D := by
    calc
      _=2*max 2 (96*Real.sqrt 6*W^2)*(C₀*Real.sqrt D) := by ring
      _≤2*D^3*D := by gcongr
  apply (le_div_iff₀ hden).mpr
  have hh := mul_le_mul hAE hf hden.le hE0
  nlinarith

/-- For every fixed positive logarithmic-square threshold, the paper's
coefficient is eventually small, uniformly in all allowed rail lengths and
all weights with a fixed linear bound. -/
theorem code_local_paper_coefficient_eventually_small (K C₀ K₀ : ℝ)
    (hK : 0<K) (hC₀ : 0<C₀) (hK₀ : 0<K₀) :
    ∃ p₀ : ℕ, 1≤p₀ ∧ ∀ p R : ℕ, p₀≤p →
      K₀*(Real.log ((p:ℝ)+2))^2≤R → ∀ W : ℝ, 0≤W → W≤K*(p*R:ℕ) →
      2*W*(p:ℝ)*((p*R:ℕ):ℝ)^4*
        (4*Real.sqrt ((p*R:ℕ):ℝ)/(Real.pi*((p*R:ℕ):ℝ)^2))^R ≤
      1/(2*max 2 (96*Real.sqrt 6*W^2)*C₀*Real.sqrt ((p*R:ℕ):ℝ)) := by
  let T := max 1 (16/K₀)
  let B := max 2 (max K (max (2+288*K^2) (C₀^2)))
  obtain ⟨p₀,hp₀⟩ := exists_nat_ge (max B (Real.exp T))
  have hpB : B≤(p₀:ℝ) := (le_max_left _ _).trans hp₀
  have hp02 : (2:ℝ)≤p₀ := (le_max_left _ _).trans hpB
  have hp01 : 1≤p₀ := by exact_mod_cast (show (1:ℝ)≤p₀ by linarith)
  refine ⟨p₀,hp01,?_⟩
  intro p R hpp hR W hW0 hW
  have hppR : (p₀:ℝ)≤p := by exact_mod_cast hpp
  have hlog : T≤Real.log ((p:ℝ)+2) := by
    apply (Real.le_log_iff_exp_le (by positivity : 0<(p:ℝ)+2)).mpr
    exact ((le_max_right _ _).trans hp₀).trans (by linarith)
  have hlog1 : 1≤Real.log ((p:ℝ)+2) := (le_max_left _ _).trans hlog
  have hlog16 : 16/K₀≤Real.log ((p:ℝ)+2) := (le_max_right _ _).trans hlog
  have hlogK : 16≤K₀*Real.log ((p:ℝ)+2) := by
    have hh := (div_le_iff₀ hK₀).mp hlog16
    nlinarith
  have hlogsq := mul_le_mul_of_nonneg_left
    (show Real.log ((p:ℝ)+2)≤(Real.log ((p:ℝ)+2))^2 by nlinarith) hK₀.le
  have hR16 : 16≤R := by exact_mod_cast (show (16:ℝ)≤R by linarith)
  let D : ℝ := (p*R:ℕ)
  change W≤K*D at hW
  have hpD : (p:ℝ)≤D := by
    dsimp [D]
    exact_mod_cast (show p≤p*R by nlinarith)
  have hBD : B≤D := hpB.trans (hppR.trans hpD)
  have hD2 : 2≤D := (le_max_left _ _).trans hBD
  have hDp : 0<D := by linarith
  have hKD : K≤D := ((le_max_left _ _).trans (le_max_right _ _)).trans hBD
  have hSD : 2+288*K^2≤D :=
    ((le_max_left _ _).trans ((le_max_right _ _).trans (le_max_right _ _))).trans hBD
  have hCD : C₀^2≤D :=
    ((le_max_right _ _).trans ((le_max_right _ _).trans (le_max_right _ _))).trans hBD
  have hWD : W≤D^2 := hW.trans (by nlinarith)
  have hsharp : max 2 (96*Real.sqrt 6*W^2)≤max 2 (288*W^2) := by
    apply max_le_max le_rfl
    have hs : Real.sqrt 6≤3 := by nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ)≤6),Real.sqrt_nonneg 6]
    nlinarith [mul_le_mul_of_nonneg_right hs (sq_nonneg W)]
  have hsupport := code_support_constant_bound D K W (by linarith) hK.le hW0 hW
  have hS : max 2 (96*Real.sqrt 6*W^2)≤D^3 :=
    hsharp.trans (hsupport.trans (by nlinarith [mul_le_mul_of_nonneg_right hSD (sq_nonneg D)]))
  have hC : C₀*Real.sqrt D≤D := by
    have hs0 := Real.sqrt_nonneg D
    have hs2 := Real.sq_sqrt hDp.le
    have hs : C₀≤Real.sqrt D := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_right hs hs0]
  exact code_local_paper_coefficient_small hD2 hpD hR16 hW0 hWD hS hC₀ hC

/-- The scalar smallness clause with `W` equal to the maximum of the actual
balanced costs on the retained family. -/
theorem retainedCarrier_local_paper_coefficient_eventually_small (C₀ K₀ : ℝ)
    (hC₀ : 0<C₀) (hK₀ : 0<K₀) :
    ∃ p₀ : ℕ, 1≤p₀ ∧ ∀ p r : ℕ, p₀≤p →
      K₀*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀ size : Fin p→Bool→ℕ, (∀i s,size i s≤4*r) →
      (∀i s,Even (size i s)) → ∀ A : Finset (Fin p→Bool), ∀ hA : A.Nonempty,
      let W := A.sup' hA (carrierBalancedCost size)
      let D : ℝ := (p*(2*r):ℕ)
      2*W*(p:ℝ)*D^4*(4*Real.sqrt D/(Real.pi*D^2))^(2*r) ≤
        1/(2*max 2 (96*Real.sqrt 6*W^2)*C₀*Real.sqrt D) := by
  obtain ⟨p₀,hp₀,hsmall⟩ := code_local_paper_coefficient_eventually_small 12 C₀ K₀
    (by norm_num) hC₀ hK₀
  refine ⟨p₀,hp₀,?_⟩
  intro p r hp hR size hhi heven A hA
  have hp1 : 1≤p := hp₀.trans hp
  have hlog : 0<Real.log ((p:ℝ)+2) := Real.log_pos (by have := Nat.cast_nonneg (α:=ℝ) p; linarith)
  have hrR : (0:ℝ)<(2*r:ℕ) := (mul_pos hK₀ (sq_pos_of_pos hlog)).trans_le hR
  have hr : 0<r := by exact_mod_cast (show (0:ℝ)<r by push_cast at hrR; linarith)
  let W := A.sup' hA (carrierBalancedCost size)
  have hW0 : 0≤W := by
    obtain ⟨θ,hθ⟩ := hA
    exact (carrierBalancedCost_pos size θ).le.trans (Finset.le_sup' _ hθ)
  have hW : W≤12*(p*(2*r):ℕ) := by
    exact Finset.sup'_le _ _ (fun θ _ => carrierBalancedCost_le_twelve (by omega) hr size hhi heven θ)
  exact hsmall p (2*r) hp hR W hW0 hW

end NeuralGeneralization.OnlineLowerTanh
