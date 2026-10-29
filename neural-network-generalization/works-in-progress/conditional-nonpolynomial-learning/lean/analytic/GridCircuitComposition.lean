import GaussianCanonicalCircuit
import RadialCircuit

/-! Concrete coordinate recoding and compositional numerical semantics for
finite threshold DAGs. These support the simultaneous Picard update. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

variable {ι κ ζ : Type*} [Fintype ι] [Fintype κ] [Fintype ζ]

 def decodeCoordinates (Q N : ℕ) (a : ι→ScalarCode Q N) : EuclideanSpace ℝ ι :=
  WithLp.toLp 2 (fun i=>scalarDecode Q N (a i))

 def recodeCoordinates (Q Ni Q' No : ℕ) :
    CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q Ni))
      (Fintype.card ι*Fintype.card (ScalarGrid Q' No)) :=
  oneHotLayer (fun j i : Fin (Fintype.card ι)=>if i=j then (1:ℤ) else 0)
    (scalarNumerator Q Ni) (fun _ z=>scalarEncode Q' No ((z:ℝ)/Q))

@[simp] theorem recodeCoordinates_eval (Q Ni Q' No : ℕ) (a : ι→ScalarCode Q Ni) :
    (recodeCoordinates (ι:=ι) Q Ni Q' No).eval (encodeCoordinateState Q Ni a)=
      encodeCoordinateState Q' No (fun i=>scalarEncode Q' No (scalarDecode Q Ni (a i))) := by
  rw [recodeCoordinates,encodeCoordinateState,oneHotLayer_eval]
  congr 1
  funext j
  simp only [ite_mul,one_mul,zero_mul,Finset.sum_ite_eq',Finset.mem_univ,if_true,
    coordinateCodes,scalarDecode]

 theorem recodeCoordinates_depth (Q Ni Q' No : ℕ) :
    (recodeCoordinates (ι:=ι) Q Ni Q' No).depth≤5 := oneHotLayer_depth _ _ _

 theorem recodeCoordinates_size (Q Ni Q' No : ℕ) :
    let qi:=Fintype.card (ScalarGrid Q Ni)
    let qo:=Fintype.card (ScalarGrid Q' No)
    let W:=(Fintype.card ι*qi)*(Q*Ni+1)
    (recodeCoordinates (ι:=ι) Q Ni Q' No).size≤
      (Fintype.card ι*qo)*(qo*((8*W+9)*(2*W+1)+1)) := by
  have hc (j i : Fin (Fintype.card ι)) : (if i=j then (1:ℤ) else 0).natAbs≤1 := by
    split <;> norm_num
  simpa only [one_mul,recodeCoordinates] using oneHotLayer_size
    (fun j i : Fin (Fintype.card ι)=>if i=j then (1:ℤ) else 0) (scalarNumerator Q Ni)
    (fun _ z=>scalarEncode Q' No ((z:ℝ)/Q)) 1 (Q*Ni+1) hc (scalarNumerator_bound Q Ni)

 def GridApproximates (Q Ni Q' No : ℕ) (F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ)
    (c : CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q Ni))
      (Fintype.card κ*Fintype.card (ScalarGrid Q' No))) (ε : ℝ) : Prop :=
  ∀a:ι→ScalarCode Q Ni,∃b:κ→ScalarCode Q' No,
    c.eval (encodeCoordinateState Q Ni a)=encodeCoordinateState Q' No b ∧
      ‖F (decodeCoordinates Q Ni a)-decodeCoordinates Q' No b‖≤ε

/-- Composition is genuine DAG substitution. Numerical errors add after the
proved Lipschitz gain; no circuit-existence assertion is hidden here. -/
 theorem GridApproximates.then {Q0 N0 Q1 N1 Q2 N2 : ℕ}
    {F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ}
    {G : EuclideanSpace ℝ κ→EuclideanSpace ℝ ζ}
    {c : CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q0 N0))
      (Fintype.card κ*Fintype.card (ScalarGrid Q1 N1))}
    {b : CircuitMap (Fintype.card κ*Fintype.card (ScalarGrid Q1 N1))
      (Fintype.card ζ*Fintype.card (ScalarGrid Q2 N2))}
    {ε δ L : ℝ} (hc : GridApproximates Q0 N0 Q1 N1 F c ε)
    (hb : GridApproximates Q1 N1 Q2 N2 G b δ)
    (hL : 0≤L) (hG : ∀x y,‖G x-G y‖≤L*‖x-y‖) :
    GridApproximates Q0 N0 Q2 N2 (G∘F) (c.then b) (L*ε+δ) := by
  intro a
  obtain ⟨a',hca',hea'⟩ := hc a
  obtain ⟨a'',hba'',hea''⟩ := hb a'
  refine ⟨a'',?_,?_⟩
  · rw [CircuitMap.eval_then,hca',hba'']
  · have ht := dist_triangle (G (F (decodeCoordinates Q0 N0 a))) (G (decodeCoordinates Q1 N1 a'))
      (decodeCoordinates Q2 N2 a'')
    simp only [dist_eq_norm] at ht
    exact ht.trans (add_le_add ((hG _ _).trans (mul_le_mul_of_nonneg_left hea' hL)) hea'')

/-- An evaluator on encoded real inputs extends to *every* incoming code by
an actual coordinatewise recoding circuit. This avoids assuming incoming codes
are themselves exact encodings in the evaluator's preferred mesh. -/
 theorem gridApproximation_of_cube_evaluator {Q Ni Q' U Qo No : ℕ} (hQ : 0<Q)
    (hU : Ni+1≤U) (F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ)
    (c : CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q' U))
      (Fintype.card κ*Fintype.card (ScalarGrid Qo No))) (ε : ℝ)
    (hc : ∀x:EuclideanSpace ℝ ι,(∀i,|x i|≤(U:ℝ))→
      ∃b:κ→ScalarCode Qo No,
        c.eval (encodeCoordinateState Q' U (fun i=>scalarEncode Q' U (x i)))=
          encodeCoordinateState Qo No b ∧ ‖F x-decodeCoordinates Qo No b‖≤ε) :
    GridApproximates Q Ni Qo No F ((recodeCoordinates Q Ni Q' U).then c) ε := by
  intro a
  have hbound (i : ι) : |decodeCoordinates Q Ni a i|≤(U:ℝ) := by
    have hh := scalarDecode_bound Q Ni hQ (a i)
    have hu : (Ni:ℝ)+1≤U := by exact_mod_cast hU
    exact hh.trans hu
  obtain ⟨b,heb,herr⟩ := hc (decodeCoordinates Q Ni a) hbound
  refine ⟨b,?_,herr⟩
  rw [CircuitMap.eval_then,recodeCoordinates_eval]
  exact heb

#print axioms GridApproximates.then
#print axioms gridApproximation_of_cube_evaluator
end ConditionalNonpolynomial.AnalyticLookup
