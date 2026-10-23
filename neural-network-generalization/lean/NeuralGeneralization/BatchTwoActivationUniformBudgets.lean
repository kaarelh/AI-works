import NeuralGeneralization.BatchTwoActivationUniformBudgetsTarget
import NeuralGeneralization.BatchTwoActivationSpectralNetwork

/-! Width- and scale-independent polynomial budgets for the three regimes. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation

def activationUniformSpectralEnergy (b d S r : ℕ) : ℕ :=
  32*(activationNatTarget b d S r+S+4*(r+2)+1)

def activationUniformInverseScale (b d S r : ℕ) : ℕ :=
  let K := activationUniformSpectralEnergy b d S r
  384*(K*b^2*(d+1)*K*(2*b^2*(K+1)+1)^r+1)+16*(d+1)+1

def activationUniformEndpointEnergy (b d S r : ℕ) : ℕ :=
  8*(activationNatTarget b d S r*(activationUniformInverseScale b d S r)^2+S+4*(r+2)+1)

def activationUniformWidth (b d S r : ℕ) : ℕ :=
  activationLearnerThreshold b d (activationUniformEndpointEnergy b d S r) (r+1)

def activationUniformSmallEnergy (b d S r : ℕ) : ℕ :=
  16*(activationNatTarget b d S r+(d+2+r*activationUniformWidth b d S r)+S+1)

def activationUniformEnergy (b d S r : ℕ) : ℕ :=
  (r+5)*activationUniformSpectralEnergy b d S r+activationUniformSmallEnergy b d S r+1

def activationIntegerCapacity (d H P : ℕ) : ℕ :=
  (16*P^2*(d+1)*(H*(2+(64*H*(d+1)*P+3)^2)+2*(d+1))+1)*(d+1)

def activationUniformEnergyScale (b d S r : ℕ) : ℕ :=
  let J := activationUniformEnergy b d S r
  J*(b*J)^(r+1)

def activationUniformCapacity (b d S r : ℕ) : ℕ :=
  activationIntegerCapacity d (r+1) (activationUniformEnergyScale b d S r)+
    activationEndpointCapacity b d (activationUniformEndpointEnergy b d S r) (r+1)+1

theorem activationUniformSpectralEnergy_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformSpectralEnergy b d S r) := by
  unfold activationUniformSpectralEnergy
  exact (PolynomialGrowth2.const 32).mul
    ((((activationNatTarget_polynomial b r).add PolynomialGrowth2.right).add
      (PolynomialGrowth2.const (4*(r+2)))).add (PolynomialGrowth2.const 1))

theorem activationUniformInverseScale_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformInverseScale b d S r) := by
  unfold activationUniformInverseScale
  let K := activationUniformSpectralEnergy_polynomial b r
  let D := PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)
  exact (((PolynomialGrowth2.const 384).mul
    (((((K.mul (PolynomialGrowth2.const (b^2))).mul D).mul K).mul
      ((((PolynomialGrowth2.const (2*b^2)).mul (K.add (PolynomialGrowth2.const 1))).add
        (PolynomialGrowth2.const 1)).pow r)).add (PolynomialGrowth2.const 1))).add
          ((PolynomialGrowth2.const 16).mul D)).add (PolynomialGrowth2.const 1)

theorem activationUniformEndpointEnergy_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformEndpointEnergy b d S r) := by
  unfold activationUniformEndpointEnergy
  exact (PolynomialGrowth2.const 8).mul
    (((((activationNatTarget_polynomial b r).mul ((activationUniformInverseScale_polynomial b r).pow 2)).add
      PolynomialGrowth2.right).add (PolynomialGrowth2.const (4*(r+2)))).add (PolynomialGrowth2.const 1))

theorem activationUniformWidth_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformWidth b d S r) :=
  (activationLearnerThreshold_polynomial b (r+1)).compositionRight
    (activationUniformEndpointEnergy_polynomial b r)

theorem activationUniformSmallEnergy_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformSmallEnergy b d S r) := by
  unfold activationUniformSmallEnergy
  exact (PolynomialGrowth2.const 16).mul
    ((((activationNatTarget_polynomial b r).add
      ((PolynomialGrowth2.left.add (PolynomialGrowth2.const 2)).add
        ((PolynomialGrowth2.const r).mul (activationUniformWidth_polynomial b r)))).add
      PolynomialGrowth2.right).add (PolynomialGrowth2.const 1))

theorem activationUniformEnergy_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformEnergy b d S r) := by
  unfold activationUniformEnergy
  exact (((PolynomialGrowth2.const (r+5)).mul (activationUniformSpectralEnergy_polynomial b r)).add
    (activationUniformSmallEnergy_polynomial b r)).add (PolynomialGrowth2.const 1)

theorem activationIntegerCapacity_polynomial (H : ℕ) :
    PolynomialGrowth2 (fun d P => activationIntegerCapacity d H P) := by
  unfold activationIntegerCapacity
  let P := PolynomialGrowth2.right
  let D := PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)
  exact (((((PolynomialGrowth2.const 16).mul (P.pow 2)).mul D).mul
    (((PolynomialGrowth2.const H).mul ((PolynomialGrowth2.const 2).add
      (((((PolynomialGrowth2.const (64*H)).mul D).mul P).add (PolynomialGrowth2.const 3)).pow 2))).add
        ((PolynomialGrowth2.const 2).mul D))).add (PolynomialGrowth2.const 1)).mul D

theorem activationUniformEnergyScale_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformEnergyScale b d S r) := by
  unfold activationUniformEnergyScale
  let J := activationUniformEnergy_polynomial b r
  exact J.mul (((PolynomialGrowth2.const b).mul J).pow (r+1))

theorem activationUniformCapacity_polynomial (b r : ℕ) :
    PolynomialGrowth2 (fun d S => activationUniformCapacity b d S r) := by
  unfold activationUniformCapacity
  exact (((activationIntegerCapacity_polynomial (r+1)).compositionRight
    (activationUniformEnergyScale_polynomial b r)).add
      ((activationEndpointCapacity_polynomial b (r+1)).compositionRight
        (activationUniformEndpointEnergy_polynomial b r))).add (PolynomialGrowth2.const 1)

theorem activationUniformSpectralEnergy_one_le (b d S r : ℕ) :
    1≤activationUniformSpectralEnergy b d S r := by unfold activationUniformSpectralEnergy; omega

theorem activationUniformEndpointEnergy_one_le (b d S r : ℕ) :
    1≤activationUniformEndpointEnergy b d S r := by unfold activationUniformEndpointEnergy; omega

theorem activationUniformInverseScale_one_le (b d S r : ℕ) :
    1≤activationUniformInverseScale b d S r := by simp only [activationUniformInverseScale]; omega

theorem activationUniformEnergy_one_le (b d S r : ℕ) :
    1≤activationUniformEnergy b d S r := by unfold activationUniformEnergy; omega

end NeuralGeneralization.BatchTwoActivation
