import ArithmeticPrograms

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup

lemma layerAmplification_one_le (d B N : ℕ) : 1≤layerAmplification d B N := by
  dsimp [layerAmplification]
  omega

namespace ArithmeticProgram

def tolerance : {d o : ℕ}→ArithmeticProgram d o→ℕ→ℕ→ℝ→ℝ
  | _,_,.nil _,_,_,ε=>ε
  | d,_,.cons _ T,B,N,ε=>(T.tolerance B (layerNextRange d B N) ε/(layerAmplification d B N:ℝ))^2

theorem tolerance_pos {d o : ℕ} (P : ArithmeticProgram d o) (B N : ℕ)
    {ε : ℝ} (hε : 0<ε) : 0<P.tolerance B N ε := by
  induction P generalizing N with
  | nil _=>exact hε
  | @cons di mi oi A T ih=>
    exact sq_pos_of_pos (div_pos (ih _) (by exact_mod_cast (layerAmplification_one_le di B N)))

theorem tolerance_le {d o : ℕ} (P : ArithmeticProgram d o) (B N : ℕ)
    {ε : ℝ} (hε : 0≤ε) (hεone : ε≤1) : P.tolerance B N ε≤ε := by
  induction P generalizing N with
  | nil _=>exact le_refl _
  | @cons di mi oi A T ih=>
    have hh:=ih (layerNextRange di B N)
    have ha : (1:ℝ)≤layerAmplification di B N := by exact_mod_cast layerAmplification_one_le di B N
    have hpos : 0≤T.tolerance B (layerNextRange di B N) ε := by
      by_cases hεpos : 0<ε
      · exact (T.tolerance_pos B _ hεpos).le
      · have he : ε=0 := by linarith
        subst ε
        clear hh
        induction T generalizing N with
        | nil _=>simp [tolerance]
        | cons _ _ _=>exact sq_nonneg _
    have hdiv : 0≤T.tolerance B (layerNextRange di B N) ε/(layerAmplification di B N:ℝ) :=
      div_nonneg hpos (by linarith)
    have hdivle : T.tolerance B (layerNextRange di B N) ε/(layerAmplification di B N:ℝ)≤ε := by
      apply (div_le_iff₀ (by linarith)).mpr
      nlinarith
    change (_ / _)^2≤ε
    nlinarith

theorem error_le_of_precision {d o : ℕ} (P : ArithmeticProgram d o) (Q B N : ℕ)
    {ε η : ℝ} (hε : 0<ε) (hεone : ε≤1) (hη : 0≤η)
    (hp : 1/(2*(Q:ℝ))≤η) (hηtol : η≤P.tolerance B N ε) :
    P.error Q B N η≤ε := by
  induction P generalizing N η with
  | nil _=>exact hηtol
  | @cons di mi oi A T ih=>
    let e:=T.tolerance B (layerNextRange di B N) ε
    have he : 0<e := T.tolerance_pos B _ hε
    have heone : e≤1 := (T.tolerance_le B _ hε.le hεone).trans hεone
    have ha : (1:ℝ)≤layerAmplification di B N := by exact_mod_cast layerAmplification_one_le di B N
    have hηone : η≤1 := hηtol.trans ((ArithmeticProgram.cons A T).tolerance_le B N hε.le hεone |>.trans hεone)
    have hstep : layerError di Q B N η≤e := by
      calc
        _ ≤ (layerAmplification di B N:ℝ)*Real.sqrt η := layerError_sqrt_bound di Q B N hη hηone hp
        _ ≤ (layerAmplification di B N:ℝ)*Real.sqrt ((e/(layerAmplification di B N:ℝ))^2) :=
          mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt hηtol) (by linarith)
        _ = e := sqrt_scaled_square (by linarith) he.le
    exact ih (layerNextRange di B N) (layerError_nonneg _ _ _ _ hη)
      (layerError_precision _ _ _ _ hη) hstep

end ArithmeticProgram
#print axioms ArithmeticProgram.error_le_of_precision
end ConditionalNonpolynomial.AnalyticLookup
