import NeuralGeneralization.OnlineLowerTanhCodeShells

/-! # Uniform constants for the physical collective-switch determinant -/
noncomputable section
namespace NeuralGeneralization.OnlineLowerTanh

theorem exists_code_phase_parameters (M h T μ:ℝ) (hM:0<M) (hh:0<h)
    (hhT:h≤T) (hμ:0<μ) (hμ1:μ≤1) :
    ∃K a b:ℝ,0<K ∧ 0<a ∧ 0<b ∧ 8*K*a≤1 ∧
      b^2*(-2*Real.log μ)≤h^2*a ∧
      ∀D E s:ℝ,1≤D → 0≤E → E≤D*M^2 → h≤s → s≤T →
        8*s^2*E/Real.pi^2-4*Real.log μ≤K*D := by
  let Δ:ℝ:=-2*Real.log μ
  have hΔ:0≤Δ := by
    have hl:=Real.log_nonpos hμ.le hμ1
    dsimp [Δ]
    linarith
  let K:ℝ:=8*T^2*M^2/Real.pi^2+2*Δ+1
  have hK:0<K := by dsimp [K];positivity
  let a:ℝ:=1/(8*K)
  have ha:0<a := by dsimp [a];positivity
  let b:ℝ:=h*Real.sqrt (a/(Δ+1))
  have hb:0<b := by dsimp [b];positivity
  have hKa:8*K*a≤1 := by dsimp [a];field_simp;norm_num
  have hb2:b^2=h^2*(a/(Δ+1)) := by
    dsimp [b]
    rw [mul_pow,Real.sq_sqrt (by positivity)]
  have hba:b^2*Δ≤h^2*a := by
    rw [hb2]
    have hfrac:Δ/(Δ+1)≤1 := (div_le_one (by positivity : 0<Δ+1)).mpr (by linarith)
    have hm:=mul_le_mul_of_nonneg_left hfrac (show 0≤h^2*a by positivity)
    convert hm using 1 <;> first | rfl | ring
  refine ⟨K,a,b,hK,ha,hb,hKa,hba,?_⟩
  intro D E s hD hE hEM hhs hsT
  have hs0:0≤s := hh.le.trans hhs
  have hT0:0≤T := hs0.trans hsT
  have hs2:=pow_le_pow_left₀ hs0 hsT 2
  have hterm:8*s^2*E/Real.pi^2≤D*(8*T^2*M^2/Real.pi^2) := by
    have h1:=mul_le_mul_of_nonneg_right hs2 hE
    have h2:=mul_le_mul_of_nonneg_left hEM (sq_nonneg T)
    have h3:8*s^2*E≤8*D*T^2*M^2 := by nlinarith only [h1,h2]
    have hd:=div_le_div_of_nonneg_right h3 (sq_nonneg Real.pi)
    convert hd using 1 <;> first | rfl | ring
  have hdelta:=mul_le_mul_of_nonneg_left hD (show 0≤2*Δ by positivity)
  dsimp [K]
  dsimp [Δ] at hdelta ⊢
  nlinarith only [hterm,hdelta,hD]

end NeuralGeneralization.OnlineLowerTanh
