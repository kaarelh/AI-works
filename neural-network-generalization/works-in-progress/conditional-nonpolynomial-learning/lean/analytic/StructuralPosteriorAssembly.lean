import FullPosteriorCeilingBridge
import DenominatorBudgetArithmetic
import UniformMemorizerDenominatorClosed
import CeilingResourceArithmetic

/-! Assembly of the original finite-width posterior ceiling from the concrete
controlled-path circuit theorem. Every probability estimate here is proved
for the actual Gaussian network, uniformly in its physical scale. -/
noncomputable section
attribute [local instance] Classical.propDecidable
set_option maxHeartbeats 1500000
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

/-- The structural statement needed by the posterior argument. The path,
threshold graph, evaluation, size and depth are all their actual definitions. -/
def UniformPathCircuitBound : Prop :=
  ∀B : ℝ,0≤B→∃P K : ℕ,1≤P ∧ 1≤K ∧
    ∀d H R : ℕ,1≤d→1≤H→2≤R→d+H+1≤R→
      P*Nat.log2 R≤H→∀t : ℝ,0<t→t≤1→∀f : BooleanFunction d,
      ∀path : ControlledMarginPath d H t f,
      path.action≤(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
        B*(((t^2)⁻¹-1)*Real.log (R:ℝ)+(Real.log (R:ℝ))^2/(H:ℝ))→
      ∃c : ThresholdCircuit d,c.size≤R^K ∧ c.depth≤K*Nat.log2 R ∧ c.eval=f

lemma natural_le_real_two_pow (n : ℕ) : (n:ℝ)≤(2:ℝ)^n := by
  induction n with
  | zero => norm_num
  | succ n ih =>
    rw [pow_succ]
    push_cast
    have h1 : (1:ℝ)≤(2:ℝ)^n := one_le_pow₀ (by norm_num)
    nlinarith

lemma positive_constant_power {M R : ℝ} (hM : 0≤M) (hR : 2≤R) :
    M≤R^(⌈M⌉₊) := by
  exact (Nat.le_ceil M).trans ((natural_le_real_two_pow _).trans
    (pow_le_pow_left₀ (by norm_num) hR _))

theorem analyticPosteriorCeiling_of_uniform_path_circuits
    (hstruct : UniformPathCircuitBound) : AnalyticPosteriorCeiling := by
  obtain ⟨W,hW,C,hC,hdenom⟩ := exists_uniform_memorizer_denominator_constants
  obtain ⟨P,K,hP,hK,hpath⟩ := hstruct (2*C+24) (by linarith)
  let p : ℕ := ⌈2*C+260⌉₊+2
  let padding : ℕ := P+⌈2*(6656*targetProgramConstant)+2⌉₊+2
  let width : ℕ := W+20*p+20+1
  let b : CeilingConstants := ⟨padding,width,K,by dsimp [padding]; omega,
    by dsimp [width]; omega,by omega⟩
  refine ⟨b,?_⟩
  intro T d n r Cteacher N hd hn hr hpad hwidth hCN f hf sample
  let R : ℕ := ceilingResource d n r
  have hR : 2≤R := by dsimp [R,ceilingResource]; omega
  have hRreal : (2:ℝ)≤R := by exact_mod_cast hR
  have hR1 : (1:ℝ)≤R := by linarith
  have hR0 : (0:ℝ)<R := by linarith
  have hdR : (d:ℝ)+1≤R := by exact_mod_cast (show d+1≤R by dsimp [R,ceilingResource]; omega)
  have hnR : (n:ℝ)≤R := by exact_mod_cast (show n≤R by dsimp [R,ceilingResource]; omega)
  have hrR : (r:ℝ)+1≤R := by exact_mod_cast (show r+1≤R by dsimp [R,ceilingResource]; omega)
  have hw1 : 1≤width := by dsimp [width]; omega
  have hwW : W≤width := by dsimp [width]; omega
  have hw20 : 20≤width := by dsimp [width]; omega
  have hwp : 20*p≤width := by dsimp [width]; omega
  have hn2 : 2*r≤N := by
    have hh : 2*width*(r+1)≤N := by
      apply le_trans (Nat.le_add_left _ _) hwidth
    have hm : 2*r≤2*width*(r+1) := by nlinarith
    exact hm.trans hh
  have hN : 0<N := by omega
  have hNreal : (0:ℝ)<N := by exact_mod_cast hN
  have ht := T.positive d (r+2) N (by omega) (by omega) hN
  have ht1 := T.atMostOne d (r+2) N (by omega) (by omega) hN
  let t := T.scale d (r+2) N
  have ht0 : 0<t := ht
  have htone : t≤1 := ht1
  have hscaleeq : Real.sqrt N*(t/Real.sqrt N)=t := by
    field_simp [(Real.sqrt_pos.mpr hNreal).ne']
  let A := denominatorBudget C t (R:ℝ) r
  let τ := 1/(t^2*(r:ℝ))
  let U := (2*C+260)*(R:ℝ)^2
  have hA : 0≤A := denominatorBudget_nonneg hC.le ht0 htone hRreal
  have hτ : 0<τ := by dsimp [τ]; positivity
  have hU : 0<U := by dsimp [U]; positivity
  have hrpos : (0:ℝ)<r := by exact_mod_cast (show 0<r by omega)
  have hpadreal : 2*(6656*targetProgramConstant)+2≤(padding:ℝ) := by
    have hh := Nat.le_ceil (2*(6656*targetProgramConstant)+2)
    dsimp [padding]
    push_cast
    linarith [Nat.cast_nonneg P (α:=ℝ)]
  have htargetpos : 0≤6656*targetProgramConstant := by
    have hh := targetProgramConstant_ge
    positivity
  have hlogdepth : 6656*targetProgramConstant*Real.log (R:ℝ)≤(r:ℝ) :=
    padding_real_log hR htargetpos hpadreal hpad
  have hwidebase : (2:ℝ)^(width*d)*(R:ℝ)^width≤N := by
    have hh : 2^(width*d)*R^width≤N := (Nat.le_add_right _ _).trans hwidth
    exact_mod_cast hh
  have hdenomwidth : (2:ℝ)^d*(R:ℝ)^W≤N := by
    apply le_trans ?_ hwidebase
    apply mul_le_mul
    · exact pow_le_pow_right₀ (by norm_num) (by nlinarith)
    · exact pow_le_pow_right₀ hR1 hwW
    · positivity
    · positivity
  have hZ : Real.exp (-(N:ℝ)*A)≤posteriorDenominator Real.tanh (1/2)
      (smallPrior d N r (t/Real.sqrt N)) f sample :=
    hdenom d n r N sample f (R:ℝ) t hd hr hRreal hdR hnR hrR ht0 htone hlogdepth hdenomwidth
  have hNorm : t^2*(A+2*τ)≤U := by
    have hh := denominatorBudget_normalized hC.le ht0 htone hr hRreal hrR
    simpa only [A,τ,U,mul_one_div] using hh
  have hslack : 1≤t^2*τ*(r:ℝ) := by
    dsimp [τ]
    have htne : t≠0 := ht0.ne'
    have hrne : (r:ℝ)≠0 := hrpos.ne'
    field_simp
    norm_num
  have hp1 : 1≤p := by dsimp [p]; omega
  have hUp : U≤(R:ℝ)^p := by
    have hc := positive_constant_power (by linarith : 0≤2*C+260) hRreal
    have hh := mul_le_mul_of_nonneg_right hc (sq_nonneg (R:ℝ))
    simpa only [U,p,pow_add] using hh
  have hRp : (R:ℝ)≤(R:ℝ)^p := by
    simpa only [pow_one] using pow_le_pow_right₀ hR1 hp1
  have hHpow : ((r+1:ℕ):ℝ)≤(R:ℝ)^p := by
    have hh : ((r+1:ℕ):ℝ)≤R := by exact_mod_cast (show r+1≤R by dsimp [R,ceilingResource]; omega)
    exact hh.trans hRp
  have hwcert := normalizedMarginWidth_power d r p hRreal hp1 hU hrpos hUp
    ((by linarith : (r:ℝ)≤R).trans hRp)
    hHpow
  have hwidthcert : normalizedCertificateWidth d r U r (normalizedRepairLog d r U r)≤N := by
    apply hwcert.trans
    apply le_trans ?_ hwidebase
    apply mul_le_mul
    · exact pow_le_pow_right₀ (by norm_num) (by nlinarith)
    · exact pow_le_pow_right₀ hR1 hwp
    · positivity
    · positivity
  have hlog := posterior_ceiling_log_slack hr hn2 ht0 htone
  have hclass : ∀g : BooleanFunction d,
      ∀path : ControlledMarginPath d (r+1) t g,path.action≤A+3*τ→g∈ceilingClass b d n r := by
    intro g path ha
    have hb := denominatorBudget_shift_depth hC.le ht0 htone hr hRreal
    have hct := subcriticalCostBaseline_nonneg (t^2).toNNReal
      (Real.toNNReal_pos.mpr (sq_pos_of_pos ht0)).ne'
    have haction : path.action≤((r+1:ℕ):ℝ)*subcriticalCostBaseline (t^2).toNNReal+
        scalarBaseline.toReal+(2*C+24)*(((t^2)⁻¹-1)*Real.log (R:ℝ)+
          (Real.log (R:ℝ))^2/((r+1:ℕ):ℝ)) := by
      dsimp [A,τ] at ha
      push_cast
      have hh : 3*(1/(t^2*(r:ℝ)))=3/(t^2*(r:ℝ)) := by ring
      rw [hh] at ha
      linarith
    have hpadpath : P*Nat.log2 R≤r+1 := by
      have hk : 1≤Nat.log2 R := by rw [Nat.le_log2 (by omega)]; simpa using hR
      have hpp : P+2≤padding := by dsimp [padding]; omega
      dsimp only [b] at hpad
      nlinarith
    obtain ⟨c,hs,hdepth,heval⟩ := hpath d (r+1) R hd (by omega) hR
      (by dsimp [R,ceilingResource]; omega) hpadpath t ht0 htone g path haction
    exact ⟨c,hs,hdepth,heval⟩
  have hfinal := posterior_ceiling_of_margin_path_class (by omega : 0<d) hN
    (div_pos ht0 (Real.sqrt_pos.mpr hNreal)) (by rw [hscaleeq]; exact htone)
    hA hτ f sample (ceilingClass b d n r) hZ hlog
    (by rw [hscaleeq]; exact hNorm) (by rw [hscaleeq]; exact hslack) hwidthcert
    (by rw [hscaleeq]; exact hclass)
  exact hfinal

#print axioms analyticPosteriorCeiling_of_uniform_path_circuits
end ConditionalNonpolynomial.Analytic
