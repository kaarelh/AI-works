import ValidGridIteration
import ParallelPicardCircuit

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ζ ι J : Type*} [Fintype ζ] [Fintype ι] [Fintype J]
 theorem parallelPicardCircuit_approximatesOn (Q B N V : ℕ) (hQ : 0<Q)
    (F : J→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (C : (J×ι)→(ζ⊕(J×ι))→ℝ) (b : (J×ι)→ℝ)
    (hC : ∀j i,|C j i|≤(B:ℝ)) (hb : ∀j,|b j|≤(B:ℝ))
    (hV : B+Fintype.card (ζ⊕(J×ι))*(B+1)*(N+1)≤V)
    {ε R : ℝ} (hε : 0≤ε) (hc : ∀j,GridApproximates Q N Q N (F j) (cs j) ε)
    (valid : (ζ→ScalarCode Q N)→Prop)
    (hR : ∀a:(ζ⊕(J×ι))→ScalarCode Q N,valid (fun i=>a (.inl i))→
      ‖affineRealMap C b (residualCarryMap F (decodeCoordinates Q N a))‖≤R)
    (hN : R+
      ((((Fintype.card (J×ι):ℝ)+1)*(Fintype.card (ζ⊕(J×ι)):ℝ)*B)*
        (((Fintype.card (ζ⊕(J×ι)):ℝ)+1)*(((Fintype.card (J×ι):ℝ)+1)*ε))+
      (((Fintype.card (J×ι):ℝ)+1)*(((Fintype.card (ζ⊕(J×ι)):ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ)))))≤N) :
    GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) (affineRealMap C b∘residualCarryMap F)
      (parallelPicardCircuit Q B N V cs C b)
      (((((Fintype.card (J×ι):ℝ)+1)*(Fintype.card (ζ⊕(J×ι)):ℝ)*B)*
        (((Fintype.card (ζ⊕(J×ι)):ℝ)+1)*(((Fintype.card (J×ι):ℝ)+1)*ε))+
      (((Fintype.card (J×ι):ℝ)+1)*(((Fintype.card (ζ⊕(J×ι)):ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ)))))+
      ((Fintype.card (J×ι):ℝ)+1)/(2*(Q:ℝ))) := by
  apply GridApproximatesOn.recodeOutput
    ((residualCarryCircuit_approximates Q N F cs hε hc).then
      (affineGridCircuit_approximates C b Q B N V hQ hC hb hV) (by positivity)
      (affineRealMap_lipschitz C b (Nat.cast_nonneg B) hC)).restrict hQ hR hN

#print axioms parallelPicardCircuit_approximatesOn
end ConditionalNonpolynomial.AnalyticLookup
