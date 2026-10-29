import AffineGridCircuit
import GridOutputRecoding
import CarriedGridIteration

/-! Genuine parallel residual evaluation followed by a precomputed affine
Volterra update. All costs refer to the actual finite threshold graphs. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ζ ι J : Type*} [Fintype ζ] [Fintype ι] [Fintype J]

 def residualCarryMap (F : J→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι)
    (x : EuclideanSpace ℝ (ζ⊕(J×ι))) : EuclideanSpace ℝ (ζ⊕(J×ι)) :=
  WithLp.toLp 2 (Sum.elim (fun i=>x (.inl i))
    (fun z=>F z.1 (WithLp.toLp 2 (fun i=>x (.inr (z.1,i)))) z.2))

 def residualCarryCircuit (Q N : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N))) :=
  sumGridCircuits (projectGridCoordinates Q N (Sum.inl : ζ→ζ⊕(J×ι)))
    ((projectGridCoordinates Q N (Sum.inr : J×ι→ζ⊕(J×ι))).then
      (parallelBlockCircuits Q N Q N cs))

 theorem residualCarryCircuit_approximates (Q N : ℕ)
    (F : J→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    {ε : ℝ} (hε : 0≤ε) (hc : ∀j,GridApproximates Q N Q N (F j) (cs j) ε) :
    GridApproximates Q N Q N (residualCarryMap (ζ:=ζ) F) (residualCarryCircuit (ζ:=ζ) Q N cs)
      (((Fintype.card (ζ⊕(J×ι)):ℝ)+1)*(((Fintype.card (J×ι):ℝ)+1)*ε)) := by
  intro a
  obtain ⟨b,hbeval,hberror⟩:=parallelBlockCircuits_approximates Q N Q N F cs hε hc (fun z=>a (.inr z))
  refine ⟨Sum.elim (fun i=>a (.inl i)) b,?_,?_⟩
  · apply sumGridCircuits_eval
    · exact projectGridCoordinates_eval Q N _ a
    · rw [CircuitMap.eval_then,projectGridCoordinates_eval]
      exact hbeval
  · apply euclidean_norm_of_coordinate_bounds _ (by positivity)
    rintro (i|z)
    · simp [residualCarryMap,decodeCoordinates]
      positivity
    · exact (PiLp.norm_apply_le
        (parallelRealMap F (decodeCoordinates Q N (fun z=>a (.inr z)))-decodeCoordinates Q N b) z).trans hberror

 theorem affineRealMap_lipschitz {α β : Type*} [Fintype α] [Fintype β]
    (c : β→α→ℝ) (b : β→ℝ) {B : ℝ} (hB : 0≤B) (hc : ∀j i,|c j i|≤B)
    (x y : EuclideanSpace ℝ α) :
    ‖affineRealMap c b x-affineRealMap c b y‖≤
      (((Fintype.card β:ℝ)+1)*(Fintype.card α:ℝ)*B)*‖x-y‖ := by
  have hε : 0≤(Fintype.card α:ℝ)*B*‖x-y‖ := by positivity
  have hcoord (j : β) : |(affineRealMap c b x-affineRealMap c b y) j|≤
      (Fintype.card α:ℝ)*B*‖x-y‖ := by
    change |(b j+∑i,c j i*x i)-(b j+∑i,c j i*y i)|≤_
    have he : (b j+∑i,c j i*x i)-(b j+∑i,c j i*y i)=∑i,c j i*(x i-y i) := by
      simp only [mul_sub,Finset.sum_sub_distrib]
      ring
    rw [he]
    calc
      _ ≤ ∑i,|c j i*(x i-y i)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑_i:α,B*‖x-y‖ := Finset.sum_le_sum fun i _=>by
        rw [abs_mul]
        exact mul_le_mul (hc j i) (PiLp.norm_apply_le (x-y) i) (abs_nonneg _) hB
      _ = _ := by simp;ring
  convert euclidean_norm_of_coordinate_bounds _ hε hcoord using 1 <;> ring

 def parallelPicardCircuit (Q B N V : ℕ)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (C : (J×ι)→(ζ⊕(J×ι))→ℝ) (b : (J×ι)→ℝ) :=
  ((residualCarryCircuit (ζ:=ζ) Q N cs).then (affineGridCircuit C b Q N V)).then
    (recodeCoordinates Q V Q N)

 theorem parallelPicardCircuit_approximates (Q B N V : ℕ) (hQ : 0<Q)
    (F : J→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι)
    (cs : J→CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Q N))
      (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (C : (J×ι)→(ζ⊕(J×ι))→ℝ) (b : (J×ι)→ℝ)
    (hC : ∀j i,|C j i|≤(B:ℝ)) (hb : ∀j,|b j|≤(B:ℝ))
    (hV : B+Fintype.card (ζ⊕(J×ι))*(B+1)*(N+1)≤V)
    {ε R : ℝ} (hε : 0≤ε) (hc : ∀j,GridApproximates Q N Q N (F j) (cs j) ε)
    (hR : ∀a:(ζ⊕(J×ι))→ScalarCode Q N,
      ‖affineRealMap C b (residualCarryMap F (decodeCoordinates Q N a))‖≤R)
    (hN : R+
      ((((Fintype.card (J×ι):ℝ)+1)*(Fintype.card (ζ⊕(J×ι)):ℝ)*B)*
        (((Fintype.card (ζ⊕(J×ι)):ℝ)+1)*(((Fintype.card (J×ι):ℝ)+1)*ε))+
      (((Fintype.card (J×ι):ℝ)+1)*(((Fintype.card (ζ⊕(J×ι)):ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ)))))≤N) :
    GridApproximates Q N Q N (affineRealMap C b∘residualCarryMap F)
      (parallelPicardCircuit Q B N V cs C b)
      (((((Fintype.card (J×ι):ℝ)+1)*(Fintype.card (ζ⊕(J×ι)):ℝ)*B)*
        (((Fintype.card (ζ⊕(J×ι)):ℝ)+1)*(((Fintype.card (J×ι):ℝ)+1)*ε))+
      (((Fintype.card (J×ι):ℝ)+1)*(((Fintype.card (ζ⊕(J×ι)):ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ)))))+
      ((Fintype.card (J×ι):ℝ)+1)/(2*(Q:ℝ))) := by
  apply GridApproximates.recodeOutput
    ((residualCarryCircuit_approximates Q N F cs hε hc).then
      (affineGridCircuit_approximates C b Q B N V hQ hC hb hV) (by positivity)
      (affineRealMap_lipschitz C b (Nat.cast_nonneg B) hC)) hQ hR hN

#print axioms parallelPicardCircuit_approximates
end ConditionalNonpolynomial.AnalyticLookup
