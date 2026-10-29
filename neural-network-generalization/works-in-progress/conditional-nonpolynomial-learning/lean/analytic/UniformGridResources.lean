import UniformProgramGrid
import ArithmeticProgramResources

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

theorem coordinateRecodeSize_via_arithmetic_le (di Q Ni Q' No:ℕ) :
    coordinateRecodeSize di Q Ni Q' No≤arithmeticLayerSize di di (Q+Q') 1 Ni No := by
  have hqi:2*(Q*Ni+1)+1≤2*((Q+Q')*Ni+1)+1 := by nlinarith
  have hqo:2*(Q'*No+1)+1≤2*((Q+Q')*No+1)+1 := by nlinarith
  have hinner:Q*Ni+1≤((Q+Q')*1+1)*((Q+Q')*Ni+1) := by
    calc
      Q*Ni+1 ≤ 1*((Q+Q')*Ni+1) := by nlinarith
      _ ≤ ((Q+Q')*1+1)*((Q+Q')*Ni+1) := Nat.mul_le_mul_right _ (by omega)
  have hW:(di*(2*(Q*Ni+1)+1))*(Q*Ni+1)≤
      (di*(2*((Q+Q')*Ni+1)+1))*(((Q+Q')*1+1)*((Q+Q')*Ni+1)) :=
    Nat.mul_le_mul (Nat.mul_le_mul_left di hqi) hinner
  unfold coordinateRecodeSize arithmeticLayerSize
  dsimp only
  gcongr

theorem coordinateRecodeSize_via_arithmetic_resource {R:ℝ} (hR:2≤R)
    {di Q Ni Q' No:ℕ} (hd:(di:ℝ)≤R) (hQ:(Q:ℝ)≤R) (hNi:(Ni:ℝ)≤R)
    (hQ':(Q':ℝ)≤R) (hNo:(No:ℝ)≤R) :
    (coordinateRecodeSize di Q Ni Q' No:ℝ)≤R^100 := by
  have hpow:R≤R^2 := by nlinarith
  have hbase:2≤R^2 := by nlinarith
  have hsum:((Q+Q':ℕ):ℝ)≤R^2 := by push_cast;nlinarith
  have hh:=arithmeticLayerSize_resource (B:=1) hbase (hd.trans hpow) (hd.trans hpow) hsum
    (by norm_num only [Nat.cast_one]; nlinarith) (hNi.trans hpow) (hNo.trans hpow)
  have hs:(coordinateRecodeSize di Q Ni Q' No:ℝ)≤arithmeticLayerSize di di (Q+Q') 1 Ni No :=
    by exact_mod_cast coordinateRecodeSize_via_arithmetic_le di Q Ni Q' No
  exact hs.trans (by simpa only [←pow_mul] using hh)

def uniformGridExponent (h:ℕ) : ℕ :=
  100*((ArithmeticProgram.resourceExponent h+1)*ArithmeticProgram.resourceExponent h)+2

theorem uniformProgramGrid_resource {ι κ:Type*} [Fintype ι] [Fintype κ]
    (P:ArithmeticProgram (Fintype.card ι) (Fintype.card κ)) {R:ℝ} (hR:2≤R)
    (B U Q N h:ℕ) {ε:ℝ} (hε:0<ε) (hlen:P.length≤h) (hP:P.bounded B)
    (hDim:(P.maxDimension:ℝ)≤R) (ho:(Fintype.card κ:ℝ)≤R)
    (hB:(B:ℝ)≤R) (hU:(U:ℝ)≤R) (hQ:(Q:ℝ)≤R) (hN:(N:ℝ)≤R)
    (hi:1/ε≤R) :
    ((uniformProgramGrid P B U Q N ε).size:ℝ)≤R^(uniformGridExponent h) := by
  let E:=ArithmeticProgram.resourceExponent h
  let F:=(E+1)*E
  have hE:1≤E := ArithmeticProgram.resourceExponent_pos h
  have hF:1≤F := by dsimp [F];nlinarith
  have hEF:E≤F := by dsimp [F];nlinarith
  have hE1F:E+1≤F := by dsimp [F];nlinarith
  have hRF:R≤R^F := by simpa using resource_pow_mono hR hF
  have hbase:2≤R^F := hR.trans hRF
  have hd:(Fintype.card ι:ℝ)≤R :=
    (show (Fintype.card ι:ℝ)≤P.maxDimension by exact_mod_cast P.input_le_maxDimension).trans hDim
  have hh:=P.compiled_resources hR B U h hε hlen hDim hB hU hi
  have hv:(P.outputRange B U:ℝ)≤R^F := hh.1.trans (resource_pow_mono hR hEF)
  have hq:(P.mesh B U ε:ℝ)≤R^F := hh.2.1.trans (resource_pow_mono hR hE1F)
  have hin:=coordinateRecodeSize_via_arithmetic_resource hbase (hd.trans hRF) (hQ.trans hRF)
    (hN.trans hRF) hq (hU.trans hRF)
  have hout:=coordinateRecodeSize_via_arithmetic_resource hbase (ho.trans hRF) hq hv
    (hQ.trans hRF) (hN.trans hRF)
  rw [←pow_mul] at hin hout
  have hs:(P.sizeBudget (P.mesh B U ε) B U:ℝ)≤R^(F*100) :=
    hh.2.2.trans (resource_pow_mono hR (show F≤F*100 by omega))
  have hsum:=resource_add_same hR (resource_add_same hR hin hs)
    (hout.trans (resource_pow_mono hR (show F*100≤F*100+1 by omega)))
  have hsize:=uniformProgramGrid_size P B U Q N hP ε
  have hsize':((uniformProgramGrid P B U Q N ε).size:ℝ)≤
      (coordinateRecodeSize (Fintype.card ι) Q N (P.mesh B U ε) U:ℝ)+
      (P.sizeBudget (P.mesh B U ε) B U:ℝ)+
      (coordinateRecodeSize (Fintype.card κ) (P.mesh B U ε) (P.outputRange B U) Q N:ℝ) :=
    by exact_mod_cast hsize
  apply hsize'.trans
  simpa only [uniformGridExponent,F,E,Nat.mul_comm,Nat.add_assoc] using hsum

#print axioms coordinateRecodeSize_via_arithmetic_resource
#print axioms uniformProgramGrid_resource
end ConditionalNonpolynomial.AnalyticLookup
