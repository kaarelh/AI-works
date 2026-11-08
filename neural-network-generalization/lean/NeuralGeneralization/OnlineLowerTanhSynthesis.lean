import NeuralGeneralization.OnlineLowerOrbitAllocation
import NeuralGeneralization.OnlineLowerReluUniformMarginal
import NeuralGeneralization.OnlineLowerTanhScalarBounds

/-! # Exact finite tanh parity orbits and their allocation mass

These witnesses use actual neurons at the specified balanced gain. Neither
the global atomic lower bound nor a limiting representation is assumed.
-/

noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLower OnlineLowerRelu

def supportIncoming {d : ℕ} (S : Finset (Fin d)) (a : ℝ) : Fin (d+1) → ℝ :=
  Fin.cases 0 (fun i => if i∈S then a else 0)

theorem supportIncoming_score {d : ℕ} (S : Finset (Fin d)) (a : ℝ) (x : Cube d) :
    atomOutput Real.tanh (supportIncoming S a) x =
      Real.tanh (a*∑ i∈S,cubeCoordinateSign (x i)) := by
  unfold atomOutput
  rw [Fin.sum_univ_succ]
  simp only [supportIncoming,inputVector,Fin.cases_zero,Fin.cases_succ,zero_mul,zero_add]
  congr 1
  simp only [ite_mul,zero_mul]
  rw [Finset.sum_ite_mem]
  simp only [Finset.univ_inter,Finset.mul_sum]
  rfl

theorem supportIncoming_cost {d : ℕ} (S : Finset (Fin d)) (a : ℝ) :
    incomingAtomCost (supportIncoming S a) = (d:ℝ)*S.card*a^2 := by
  unfold incomingAtomCost
  rw [Fin.sum_univ_succ]
  simp [supportIncoming]
  ring

theorem support_tanh_walsh_eq_parity {d : ℕ} (S : Finset (Fin d)) (a : ℝ) :
    walshCoefficients (atomOutput Real.tanh (supportIncoming S a)) S =
      parityCorrelation (fun _ : Fin S.card => a) 0 := by
  let F : (↥S → Bool) → ℝ := fun y =>
    Real.tanh (a*∑ i:S,cubeCoordinateSign (y i))*∏ i:S,cubeCoordinateSign (y i)
  have hpoint (x:Cube d) : atomOutput Real.tanh (supportIncoming S a) x*walshCharacter S x =
      F (fun i:S => x i) := by
    rw [supportIncoming_score]
    dsimp [F,walshCharacter]
    rw [Finset.sum_attach S (fun i => cubeCoordinateSign (x i)),
      Finset.prod_attach S (fun i => cubeCoordinateSign (x i))]
  have hfirst : walshCoefficients (atomOutput Real.tanh (supportIncoming S a)) S = finiteAverage F := by
    unfold walshCoefficients uniformCubeMean
    simp_rw [hpoint]
    exact finiteAverage_restrict S F
  rw [hfirst]
  let e : ↥S ≃ Fin S.card := Fintype.equivOfCardEq (by simp)
  let E : (Fin S.card → Bool) ≃ (↥S → Bool) := Equiv.arrowCongr e.symm (Equiv.refl Bool)
  rw [←finiteAverage_equiv E F]
  have he (x:Fin S.card→Bool) : F (E x) =
      Real.tanh (a*∑ i:Fin S.card,cubeCoordinateSign (x i))*∏ i:Fin S.card,cubeCoordinateSign (x i) := by
    change Real.tanh (a*∑ i:S,cubeCoordinateSign (x (e i)))*
      (∏ i:S,cubeCoordinateSign (x (e i))) = _
    rw [e.sum_comp (fun i => cubeCoordinateSign (x i)), e.prod_comp (fun i => cubeCoordinateSign (x i))]
  simp_rw [he]
  unfold finiteAverage parityCorrelation paritySign
  rw [div_eq_inv_mul]
  congr 1
  apply Finset.sum_congr rfl
  intro x hx
  simp only [zero_add,incomingLinear_constant,spinSum]
  have heq : cubeCoordinateSign = labelReal := by funext b; cases b <;> rfl
  simp_rw [heq]
  ring

theorem support_tanh_walsh_abs {d : ℕ} (S : Finset (Fin d)) (r : ℕ)
    (hcard : S.card=2*r+1) :
    |walshCoefficients (atomOutput Real.tanh (supportIncoming S (balancedGain r))) S| =
      balancedParity r (balancedGain r) := by
  rw [support_tanh_walsh_eq_parity,hcard]
  have he := congrArg abs (show balancedParity r (balancedGain r) =
      (-1:ℝ)^r * parityCorrelation (fun _ : Fin (2*r+1) => balancedGain r) 0 from rfl)
  rw [abs_mul,abs_neg_one_pow,one_mul,abs_of_pos (balancedParity_gain_pos r)] at he
  exact he.symm

theorem supportIncoming_sqrt_cost {d : ℕ} (S : Finset (Fin d)) (r : ℕ)
    (hcard : S.card=2*r+1) :
    Real.sqrt (incomingAtomCost (supportIncoming S (balancedGain r))) =
      Real.sqrt (d:ℝ)*balancedGain r*Real.sqrt (2*r+1:ℕ) := by
  rw [supportIncoming_cost,hcard,Real.sqrt_mul (mul_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)),
    Real.sqrt_mul (Nat.cast_nonneg _),Real.sqrt_sq_eq_abs,abs_of_pos (balancedGain_pos r)]
  ring

theorem supported_orbit_mass_bound {d : ℕ} (hd : 0<d) (S : Finset (Fin d)) (r : ℕ)
    (hcard : S.card=2*r+1) (v : ℝ) :
    |v| / (|walshCoefficients (atomOutput Real.tanh (supportIncoming S (balancedGain r))) S| *
      Real.sqrt (incomingAtomCost (supportIncoming S (balancedGain r)))) ≤
        4*|v|/Real.sqrt (d:ℝ) := by
  rw [support_tanh_walsh_abs S r hcard,supportIncoming_sqrt_cost S r hcard]
  have hs : 0<Real.sqrt (d:ℝ) := Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd)
  have hprod : (1:ℝ)/4 ≤ balancedParity r (balancedGain r)*balancedGain r*Real.sqrt (2*r+1:ℕ) := by
    nlinarith only [balancedGain_mass_lower r]
  have hqa := balancedParity_gain_pos r
  have hga := balancedGain_pos r
  have hden : 0<balancedParity r (balancedGain r)*(Real.sqrt (d:ℝ)*balancedGain r*Real.sqrt (2*r+1:ℕ)) := by
    positivity
  apply (div_le_iff₀ hden).mpr
  have hh := mul_le_mul_of_nonneg_left hprod (abs_nonneg v)
  field_simp
  nlinarith only [hh]

theorem supported_orbit_cost {d : ℕ} (S : Finset (Fin d)) (r : ℕ)
    (hcard : S.card=2*r+1) (v : ℝ) :
    2*|v| *Real.sqrt (incomingAtomCost (supportIncoming S (balancedGain r))) /
      |walshCoefficients (atomOutput Real.tanh (supportIncoming S (balancedGain r))) S| =
        2*Real.sqrt (d:ℝ)*(|v| *balancedCost r) := by
  rw [support_tanh_walsh_abs S r hcard,supportIncoming_sqrt_cost S r hcard]
  unfold balancedCost
  ring

/-- Every bounded Fourier expansion over odd parities has allocation slack
at the actual balanced tanh gains. -/
theorem odd_parity_allocation_slack {d : ℕ} {ι : Type*} [Fintype ι]
    (hd : 144 < d) (S : ι → Finset (Fin d)) (r : ι → ℕ)
    (hcard : ∀ i, (S i).card=2*r i+1) (v : ι → ℝ)
    (hv : ∑ i, |v i| ≤ (3:ℝ)/2) :
    (∑ i, |v i| /
      (|walshCoefficients (atomOutput Real.tanh (supportIncoming (S i) (balancedGain (r i))))
        (S i)| * Real.sqrt (incomingAtomCost (supportIncoming (S i) (balancedGain (r i)))))) < 1 := by
  have hd0 : 0<d := by omega
  have hs : 12 < Real.sqrt (d:ℝ) := (Real.lt_sqrt (by norm_num)).mpr (by exact_mod_cast hd)
  have hs0 : 0<Real.sqrt (d:ℝ) := by linarith
  have hh := Finset.sum_le_sum (fun i (_ : i∈Finset.univ) =>
    supported_orbit_mass_bound hd0 (S i) (r i) (hcard i) (v i))
  calc
    _ ≤ ∑ i, 4*|v i|/Real.sqrt (d:ℝ) := hh
    _ = 4*(∑ i, |v i|)/Real.sqrt (d:ℝ) := by rw [← Finset.sum_div,← Finset.mul_sum]
    _ < 1 := (div_lt_iff₀ hs0).mpr (by nlinarith)

/-- Literal tanh networks realize a closed-margin odd-parity expansion at
all sufficiently large widths, with energy arbitrarily close to its
balanced-atom cost. Zero Fourier coefficients are allowed. -/
theorem odd_parity_expansion_strict_witness {d : ℕ} {ι : Type*} [Fintype ι]
    (hd : 144 < d) (S : ι → Finset (Fin d)) (r : ι → ℕ)
    (hcard : ∀ i, (S i).card=2*r i+1) (v : ι → ℝ)
    (hv : ∑ i, |v i| ≤ (3:ℝ)/2)
    (g : BooleanFunction d)
    (hmargin : ∀ x, (1/2:ℝ) ≤ labelReal (g x)*∑ i, v i*walshCharacter (S i) x)
    (B : ℝ) (hbudget : 2*Real.sqrt (d:ℝ)*(∑ i, |v i| *balancedCost (r i)) < B) :
    ∃ N₀ : ℕ, 0<N₀ ∧ ∀ N : ℕ, N₀≤N →
      ∃ w : Weights d N 0, w∈marginEvent Real.tanh (1/2) g ∧ weightedSquaredNorm w < B := by
  apply allocated_fourier_strict_witness_all_large Real.tanh S
    (fun i => supportIncoming (S i) (balancedGain (r i))) v
  · intro i
    apply abs_pos.mp
    rw [support_tanh_walsh_abs (S i) (r i) (hcard i)]
    exact balancedParity_gain_pos (r i)
  · intro i
    rw [supportIncoming_cost,hcard i]
    have := balancedGain_pos (r i)
    have hd0 : (0:ℝ)<d := by exact_mod_cast (show 0<d by omega)
    positivity
  · exact odd_parity_allocation_slack hd S r hcard v hv
  · exact hmargin
  · simp_rw [supported_orbit_cost _ _ (hcard _)]
    rw [← Finset.mul_sum]
    exact hbudget

end NeuralGeneralization.OnlineLowerTanh
