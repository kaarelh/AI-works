import PicardGridResourceBounds
import UniformProgramGrid

noncomputable section
set_option maxHeartbeats 1000000
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

def uniformProgramResourceExponent (h : ℕ) : ℕ :=
  (ArithmeticProgram.resourceExponent h+1)*(ArithmeticProgram.resourceExponent h+50)+2

theorem uniformProgramGrid_budget_resource {d o : ℕ} (A : ArithmeticProgram d o)
    {R : ℝ} (hR : 2≤R) (B U Q N h : ℕ) {ε : ℝ} (hε : 0<ε)
    (hlen : A.length≤h) (hd : (d:ℝ)≤R) (ho : (o:ℝ)≤R)
    (hDim : (A.maxDimension:ℝ)≤R) (hB : (B:ℝ)≤R)
    (hU : (U:ℝ)≤R) (hQ : (Q:ℝ)≤R) (hN : (N:ℝ)≤R) (hεinv : ε⁻¹≤R) :
    (coordinateRecodeSize d Q N (A.mesh B U ε) U+
      A.sizeBudget (A.mesh B U ε) B U+
      coordinateRecodeSize o (A.mesh B U ε) (A.outputRange B U) Q N:ℕ)≤
        R^(uniformProgramResourceExponent h) := by
  have hp := A.compiled_resources hR B U h hε hlen hDim hB hU (by simpa only [one_div] using hεinv)
  let E := ArithmeticProgram.resourceExponent h
  have hE : 1≤E := ArithmeticProgram.resourceExponent_pos h
  have hRbig : R≤R^(E+1) := by simpa only [pow_one] using resource_pow_mono hR (by omega : 1≤E+1)
  have hbig : 2≤R^(E+1) := hR.trans hRbig
  have hrec1 := coordinateRecodeSize_resource hbig (hd.trans hRbig) (hQ.trans hRbig)
    (hN.trans hRbig) hp.2.1 (hU.trans hRbig)
  have hrec2 := coordinateRecodeSize_resource hbig (ho.trans hRbig) hp.2.1
    (hp.1.trans (resource_pow_mono hR (by omega : E≤E+1))) (hQ.trans hRbig) (hN.trans hRbig)
  rw [←pow_mul] at hrec1 hrec2
  let K := (E+1)*(E+50)
  have hrK : (E+1)*50≤K := by dsimp [K];nlinarith
  have hsK : (E+1)*E≤K := by dsimp [K];nlinarith
  have hsum1 := resource_add_same hR
    (hrec1.trans (resource_pow_mono hR hrK)) (hp.2.2.trans (resource_pow_mono hR hsK))
  have hsum2 := resource_add_same hR hsum1
    (hrec2.trans (resource_pow_mono hR (hrK.trans (Nat.le_succ K))))
  simpa only [Nat.cast_add,uniformProgramResourceExponent,E,K] using hsum2

#print axioms uniformProgramGrid_budget_resource
end ConditionalNonpolynomial.AnalyticLookup
