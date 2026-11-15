import NeuralGeneralization.OnlineLowerTanhPeriodicCompactSmoothing
import NeuralGeneralization.OnlineLowerTanhResidualUniformTheorem

/-! # The paper's uniform external-phase bound on every positive gain range -/
noncomputable section
open scoped Topology BigOperators Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma residualLeading_scaled_bound {n:ℕ} (hn:0<n) (q:Fin n→ℕ)
    (hq:∀i,0<q i) (d:Fin n→ℝ) {A M:ℝ} (hA:0<A)
    (hM:∀b:ℝ,|smoothedResponse A (∑i,(d i)^2) b| ≤ M) (B:ℝ) :
    Real.sqrt (residualVariance q)*|residualLeading q d A B| ≤ Real.sqrt (2/Real.pi)*M := by
  have hV:=residualVariance_pos hn q hq
  have hs:=hM (B+(n%2:ℕ)*A)
  have hM0:0 ≤ M:=(abs_nonneg _).trans hs
  have he:Real.exp (-B^2/(2*A^2*residualVariance q)) ≤ 1 :=
    Real.exp_le_one_iff.mpr (by
      have hd:0<2*A^2*residualVariance q:=by positivity
      exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (sq_nonneg B)) hd.le)
  have hnorm:Real.sqrt (residualVariance q)*Real.sqrt (2/(Real.pi*residualVariance q))=
      Real.sqrt (2/Real.pi) := by
    rw [←Real.sqrt_mul hV.le]
    congr 1
    field_simp
  unfold residualLeading
  rw [abs_mul,abs_mul,abs_mul,residualPhaseSign_abs,one_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),abs_of_pos (Real.exp_pos _)]
  calc
    _ = (Real.sqrt (residualVariance q)*Real.sqrt (2/(Real.pi*residualVariance q)))*
        (Real.exp (-B^2/(2*A^2*residualVariance q))*
          |smoothedResponse A (∑i,(d i)^2) (B+(n%2:ℕ)*A)|) := by ring
    _ ≤ Real.sqrt (2/Real.pi)*M := by
      rw [hnorm]
      apply mul_le_mul_of_nonneg_left _ (Real.sqrt_nonneg _)
      exact (mul_le_mul_of_nonneg_left hs (Real.exp_pos _).le).trans
        (mul_le_of_le_one_left hM0 he)

lemma residualLeading_scaled_cap_all_gain {n:ℕ} (hn:0<n) (q:Fin n→ℕ)
    (hq:∀i,0<q i) (d:Fin n→ℝ) {A:ℝ} (hA:0<A) (B:ℝ) :
    Real.sqrt (residualVariance q)*|residualLeading q d A B| ≤
      Real.sqrt (2/Real.pi)*scalarF0 A := by
  apply residualLeading_scaled_bound hn q hq d hA _ B
  intro b
  simpa only [periodicFourierMaximum_eq_scalarF0 A hA] using
    smoothedResponse_abs_le_all_gain hA (Finset.sum_nonneg (fun i _=>sq_nonneg (d i))) b

namespace ResidualSample
variable {ι:Type*} [Fintype ι] [DecidableEq ι]
variable {q:ι→ℕ} {α lo hi K:ℝ} (P:ResidualSample ι q α lo hi K)

lemma alphabet_pos_of_odd (hq:∀i,Odd (q i)) (i:Fin P.N):0<P.alphabet i := by
  have ho:=hq (P.label i)
  exact Nat.pos_of_ne_zero (by intro he; change q (P.label i)=0 at he; simpa [he] using ho)

lemma scaled_correlation_le_of_error {M ε:ℝ} (hlo:0<lo) (hq:∀i,Odd (q i))
    (hM:∀b:ℝ,|smoothedResponse P.A (∑i,(P.d i)^2) b| ≤ M)
    (herr:∀b:ℝ,P.fullDerivativeError 0 b<ε) (b:ℝ) :
    Real.sqrt (residualVariance P.alphabet)*|parityCorrelation P.incoming b| ≤
      Real.sqrt (2/Real.pi)*M+ε := by
  have hcap:=residualLeading_scaled_bound P.N_pos P.alphabet (P.alphabet_pos_of_odd hq)
    P.d (hlo.trans_le P.A_lo) hM b
  have he:=herr b
  simp only [fullDerivativeError,iteratedDeriv_zero] at he
  have htri:=abs_add_le (parityCorrelation P.incoming b-residualLeading P.alphabet P.d P.A b)
    (residualLeading P.alphabet P.d P.A b)
  rw [sub_add_cancel] at htri
  have hh:=mul_le_mul_of_nonneg_left htri (Real.sqrt_nonneg (residualVariance P.alphabet))
  rw [mul_add] at hh
  linarith
end ResidualSample

/-- Uniform external-phase cap, with finite ε/N/defect quantifiers. In
particular the remainder is o(V^(-1/2)) uniformly on the paper's full family. -/
theorem residual_uniform_external_phase_bound
    {ι:Type*} [Fintype ι] [DecidableEq ι]
    (q:ι→ℕ) (c:ι→ℤ) (hq:∀i,Odd (q i)) (hc:∑i,c i*(q i:ℤ)=1)
    {α Q lo hi K:ℝ} (hα:0<α) (hQ:0<Q) (hlo:0<lo) (hK:0 ≤ K)
    (hqQ:∀i,(q i:ℝ) ≤ Q) :
    ∀ε>0,∃N₀:ℕ,∃δ:ℝ,0<δ ∧
      ∀P:ResidualSample ι q α lo hi K,N₀ ≤ P.N→
        (∀i,|P.d i| ≤ δ)→∀b:ℝ,
          Real.sqrt (residualVariance P.alphabet)*|parityCorrelation P.incoming b| ≤
            Real.sqrt (2/Real.pi)*scalarF0 P.A+ε := by
  intro ε hε
  obtain ⟨N₀,δ,hδ,hh⟩:=residual_uniform_derivative_estimate q c hq hc hα hQ hlo hK hqQ 0 ε hε
  refine ⟨N₀,δ,hδ,?_⟩
  intro P hPN hPd b
  apply P.scaled_correlation_le_of_error hlo hq _ (hh P hPN hPd) b
  intro t
  have ha:=hlo.trans_le P.A_lo
  simpa only [periodicFourierMaximum_eq_scalarF0 P.A ha] using
    smoothedResponse_abs_le_all_gain ha (Finset.sum_nonneg (fun i _=>sq_nonneg (P.d i))) t

/-- Residual energy bounded away from zero gives a single strict loss in
F₀, uniform in every external phase and every literal admissible sample. -/
theorem residual_uniform_external_phase_strict_loss
    {ι:Type*} [Fintype ι] [DecidableEq ι]
    (q:ι→ℕ) (c:ι→ℤ) (hq:∀i,Odd (q i)) (hc:∑i,c i*(q i:ℤ)=1)
    {α Q lo hi e₀ K:ℝ} (hα:0<α) (hQ:0<Q) (hlo:0<lo) (hhi:lo ≤ hi)
    (he₀:0<e₀) (hK:e₀ ≤ K) (hqQ:∀i,(q i:ℝ) ≤ Q) :
    ∃η:ℝ,0<η ∧ ∃N₀:ℕ,∃δ:ℝ,0<δ ∧
      ∀P:ResidualSample ι q α lo hi K,N₀ ≤ P.N→
        (∀i,|P.d i| ≤ δ)→e₀ ≤ ∑i,(P.d i)^2→∀b:ℝ,
          Real.sqrt (residualVariance P.alphabet)*|parityCorrelation P.incoming b| ≤
            Real.sqrt (2/Real.pi)*(scalarF0 P.A-η) := by
  obtain ⟨η,hη,hgap⟩:=smoothedResponse_uniform_strict_loss hlo hhi he₀ hK
  have hs:0<Real.sqrt (2/Real.pi):=by positivity [Real.pi_pos]
  let ε:=Real.sqrt (2/Real.pi)*η/2
  have hε:0<ε:=by dsimp [ε]; positivity
  obtain ⟨N₀,δ,hδ,hh⟩:=residual_uniform_derivative_estimate q c hq hc hα hQ hlo
    (he₀.le.trans hK) hqQ 0 ε hε
  refine ⟨η/2,by positivity,N₀,δ,hδ,?_⟩
  intro P hPN hPd hPE b
  have hcap:=P.scaled_correlation_le_of_error hlo hq
    (hgap P.A ⟨P.A_lo,P.A_hi⟩ (∑i,(P.d i)^2) ⟨hPE,P.energy_bound⟩)
    (hh P hPN hPd) b
  dsimp [ε] at hcap
  nlinarith

end NeuralGeneralization.OnlineLowerTanh
