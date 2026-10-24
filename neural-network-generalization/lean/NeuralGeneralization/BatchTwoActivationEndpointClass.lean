import NeuralGeneralization.BatchTwoActivationActualTower

/-! A single finite class, with polynomial logarithmic cardinality, contains
every physical-network function reconstructed by the good events. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem auxiliaryFunctions_mono {d H : ℕ} {P P' : ℝ} (hP : 0<P) (hPP' : P≤P') :
    auxiliaryFunctions d H P⊆auxiliaryFunctions d H P' := by
  classical
  intro f hf
  obtain ⟨_,W,hw⟩ := Finset.mem_filter.mp hf
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _,W,?_⟩
  intro x
  have hh := hw x
  unfold auxiliaryOutput at hh ⊢
  have hz : 0≤labelReal (f x)*inner ℝ W.readout
      (auxiliaryFamilyState (fun _ : Unit => W) (fun _ : Fin 1 => x) H () 0) := by
    have he : labelReal (f x)*(P*inner ℝ W.readout
        (auxiliaryFamilyState (fun _ : Unit => W) (fun _ : Fin 1 => x) H () 0))=
      P*(labelReal (f x)*inner ℝ W.readout
        (auxiliaryFamilyState (fun _ : Unit => W) (fun _ : Fin 1 => x) H () 0)) := by ring
    rw [he] at hh
    exact nonneg_of_mul_nonneg_right (by linarith : 0≤P*_) hP
  have hm := mul_le_mul_of_nonneg_right hPP' hz
  nlinarith

def activationEndpointScale (b d K H : ℕ) : ℕ :=
  activationRawBudget b d K H*(b*activationRawBudget b d K H)^H

def activationEndpointFunctions (b d K H : ℕ) : Finset (BooleanFunction d) :=
  auxiliaryFunctions d H (activationEndpointScale b d K H)

def activationEndpointCapacity (b d K H : ℕ) : ℕ :=
  let P := activationEndpointScale b d K H
  (16*P^2*(d+1)*(H*(2+(64*H*(d+1)*P+3)^2)+2*(d+1))+1)*(d+1)

theorem activationEndpointScale_pos {b d K H : ℕ} (hb : 1≤b) :
    0<activationEndpointScale b d K H := by
  unfold activationEndpointScale
  have := activationRawBudget_pos b d K H
  positivity

theorem activationEndpointFunctions_card_le_exp {b d K H : ℕ} (hb : 1≤b) (hH : 0<H) :
    ((activationEndpointFunctions b d K H).card:ℝ)≤Real.exp (activationEndpointCapacity b d K H) := by
  have hh := auxiliaryFunctions_card_le_exp (d:=d) hH
    (Nat.cast_pos.mpr (activationEndpointScale_pos (d:=d) (K:=K) (H:=H) hb))
  convert hh using 1 <;> simp [activationEndpointFunctions,activationEndpointCapacity,capacityPolynomial]

theorem activationEndpointScale_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationEndpointScale b d K H) := by
  unfold activationEndpointScale
  exact (activationRawBudget_polynomial b H).mul
    (((PolynomialGrowth2.const b).mul (activationRawBudget_polynomial b H)).pow H)

theorem activationEndpointCapacity_polynomial (b H : ℕ) :
    PolynomialGrowth2 (fun d K => activationEndpointCapacity b d K H) := by
  let P := activationEndpointScale_polynomial b H
  let D := PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)
  unfold activationEndpointCapacity
  exact (((((PolynomialGrowth2.const 16).mul (P.pow 2)).mul D).mul
    (((PolynomialGrowth2.const H).mul
      ((PolynomialGrowth2.const 2).add
        (((((PolynomialGrowth2.const (64*H)).mul D).mul P).add (PolynomialGrowth2.const 3)).pow 2))).add
      ((PolynomialGrowth2.const 2).mul D))).add (PolynomialGrowth2.const 1)).mul D

theorem actual_good_network_endpoint_mem {b d K N r : ℕ}
    (hb : 1≤b) (hd : 1≤d) (hK : 1≤K) (hN : 0<N)
    {ℓ B σ : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀u,|deriv scalarCutoff u|≤B) (hbb : ∀u,|deriv (deriv scalarCutoff) u|≤B)
    (w : Weights d N r) (f : BooleanFunction d)
    (hmargin : w∈marginEvent φ (1/2) f)
    (hgood : ActivationGoodHidden b d K (r+1) N φ σ r w)
    (hreadout : (N:ℝ)*(∑i,w (.inr (.inr i))^2)≤8*(K:ℝ)) :
    f∈activationEndpointFunctions b d K (r+1) := by
  have hf := actual_good_network_auxiliary_mem hb hd hK hN hℓ0 hℓ hB0 hB hσ hscale hφ hb' hbb w f hmargin hgood hreadout
  apply auxiliaryFunctions_mono (P:=activationAuxiliaryScale b d K (r+1) ℓ) _ _ hf
  · unfold activationAuxiliaryScale
    have : (0:ℝ)<activationRawBudget b d K (r+1) := Nat.cast_pos.mpr (activationRawBudget_pos b d K (r+1))
    positivity
  · unfold activationAuxiliaryScale activationEndpointScale
    push_cast
    gcongr

end NeuralGeneralization.BatchTwoActivation
