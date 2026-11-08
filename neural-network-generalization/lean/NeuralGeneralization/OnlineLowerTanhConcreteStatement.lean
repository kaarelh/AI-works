import NeuralGeneralization.OnlineLowerTanhResources
import NeuralGeneralization.OnlineLowerReluConcreteStatement

/-! # The exact improved tanh theorem target and its resource interpretation

The target retains the literal m=6k+6 family, logarithmic rail ceilings,
shared carrier, exact number 2^(k-1) of designated rounds, and actual
Gaussian posterior. Defining this proposition does not assert its proof;
the eventual analytic construction must supply the protocol.
-/

noncomputable section
open scoped BigOperators Topology Classical
open Filter
namespace NeuralGeneralization.OnlineLower
open ConcreteModel

abbrev tanhConcreteDimension (K k : ℕ) := OnlineLowerTanh.Family.constructionDimension K k
abbrev tanhConcreteTarget (K k : ℕ) := OnlineLowerTanh.Family.constructionTarget K k
abbrev tanhConcreteTeacherWidth (K k : ℕ) := OnlineLowerTanh.Family.constructionTeacherWidth K k
def tanhConcreteCount (k : ℕ) : ℕ := 2^(k-1)

/-- One complete input permutation and its exact designated mistake set,
chosen before every sufficiently large finite width and before scale zero. -/
def TanhConcreteProtocol (K k : ℕ) (π : InputOrder (tanhConcreteDimension K k))
    (J : Finset (Fin (Fintype.card (Cube (tanhConcreteDimension K k))))) : Prop :=
  J.card = tanhConcreteCount k ∧
  AllLargeWidthsFail Real.tanh (tanhConcreteTarget K k) (tanhConcreteTeacherWidth K k) π J

/-- The paper's concrete theorem, with actual networks and posterior.
There is no assumed atomic, calibration, or energy certificate in the
statement. It is a target proposition until an unconditional theorem
inhabits it. -/
def TanhConcreteMainStatement : Prop :=
  ∃ K : ℕ, 1 ≤ K ∧ ∃ k₀ : ℕ, 3 ≤ k₀ ∧ ∀ k : ℕ, k₀ ≤ k →
    BoundedTeacher Real.tanh (tanhConcreteTarget K k) (tanhConcreteTeacherWidth K k) ∧
    HasCircuitAtMost (tanhConcreteTarget K k) (17*tanhConcreteDimension K k+5) ∧
    ∃ π : InputOrder (tanhConcreteDimension K k),
    ∃ J : Finset (Fin (Fintype.card (Cube (tanhConcreteDimension K k)))),
      TanhConcreteProtocol K k π J

/-- The exact construction gives the advertised joint width-depth-free
resources; the constants here are deliberately generous and explicit. -/
theorem TanhConcreteMainStatement.polylogResources (h : TanhConcreteMainStatement) :
    TanhPathLogarithmicRailStatement := by
  obtain ⟨K,hK,k₀,hk₀,hfamily⟩ := h
  obtain ⟨k₁,hresources⟩ := Filter.eventually_atTop.mp (OnlineLowerTanh.Family.construction_resources_eventually K hK)
  let A := 300000*K
  have hA : 0 < A := Nat.mul_pos (by norm_num) (by omega)
  refine ⟨A,hA,Real.log 2/2,div_pos (Real.log_pos (by norm_num)) (by norm_num),
    max k₀ k₁,by omega,?_⟩
  intro k hk
  have hk0 : k₀≤k := (le_max_left _ _).trans hk
  have hk1 : k₁≤k := (le_max_right _ _).trans hk
  have hk2 : 2≤k := by omega
  obtain ⟨ht,hc,π,J,hprotocol⟩ := hfamily k hk0
  obtain ⟨hd,_,_,_,hdl,hdu,hCu⟩ := hresources k hk1
  have hd0 : 0<tanhConcreteDimension K k := OnlineLowerTanh.Family.constructionDimension_pos K k
  have hAR : (A:ℝ)=300000*(K:ℝ) := by dsimp [A]; push_cast; rfl
  have hKR : (1:ℝ)≤K := by exact_mod_cast hK
  have hlog : 0≤Real.log (k:ℝ) := Real.log_nonneg (by exact_mod_cast (show 1≤k by omega))
  refine ⟨tanhConcreteDimension K k,tanhConcreteTeacherWidth K k,tanhConcreteTarget K k,
    π,J,hd0,ht.1,?_,?_,?_,ht,?_,?_,hprotocol.2⟩
  · simp only [pow_one]
    exact hdl.trans (by rw [hAR]; nlinarith [Nat.cast_nonneg (α:=ℝ) (tanhConcreteDimension K k)])
  · simp only [pow_one]
    rw [hAR]
    have hh : 0≤(K:ℝ)*(k:ℝ)*Real.log (k:ℝ)^2 := by positivity
    linarith
  · rw [hAR]
    exact hCu
  · obtain ⟨c,hcsize,hcoutput⟩ := hc
    refine ⟨c,hcsize.trans ?_,hcoutput⟩
    have hAk : 22≤A := by dsimp [A]; omega
    exact (show 17*tanhConcreteDimension K k+5 ≤ 22*tanhConcreteDimension K k by omega).trans
      (Nat.mul_le_mul_right _ hAk)
  · rw [hprotocol.1]
    simpa only [tanhConcreteCount,Nat.cast_pow,Nat.cast_ofNat] using binary_family_exponential_count k hk2

theorem TanhConcreteMainStatement.widthRate (h : TanhConcreteMainStatement) :
    TanhSquareRootLogLossStatement :=
  polylog_quadratic_resources_imply_square_root_log_loss Real.tanh 1 h.polylogResources

/-- The finite-scale bullets use the actual normalized joint posterior law,
including the stronger correct-label probability below one third. -/
theorem TanhConcreteProtocol.finite_scale {K k : ℕ}
    {π : InputOrder (tanhConcreteDimension K k)}
    {J : Finset (Fin (Fintype.card (Cube (tanhConcreteDimension K k))))}
    (h : TanhConcreteProtocol K k π J) :
    ∃ N₀ : ℕ, tanhConcreteTeacherWidth K k ≤ N₀ ∧ 0<N₀ ∧
      ∀ N : ℕ,N₀≤N → ∀η:ℝ,0<η → ∃σ₀:ℝ,0<σ₀ ∧
        ∀σ:ℝ,0<σ → σ<σ₀ →
          (1-η < designatedAtLeastProbability Real.tanh (tanhConcreteTarget K k) π N σ J (tanhConcreteCount k)) ∧
          (∀j∈J,correctAt Real.tanh (tanhConcreteTarget K k) π N σ j<(1/3:ℝ) ∧
            correctAt Real.tanh (tanhConcreteTarget K k) π N σ j<(1/2:ℝ)) := by
  obtain ⟨N₀,hCN₀,hN₀,hlarge⟩ := h.2
  refine ⟨N₀,hCN₀,hN₀,?_⟩
  intro N hN η hη
  have hl := (hlarge N hN).2
  obtain ⟨σ₁,hσ₁,hsmall₁⟩ := finite_scale_all_wrong_probability Real.tanh (tanhConcreteTarget K k) π J hl η hη
  obtain ⟨σ₂,hσ₂,hsmall₂⟩ := finite_designated_scale Real.tanh (tanhConcreteTarget K k) π J hl (1/3) (by norm_num)
  refine ⟨min σ₁ σ₂,lt_min hσ₁ hσ₂,?_⟩
  intro σ hσ hσlt
  have hs₁ : σ<σ₁ := lt_of_lt_of_le hσlt (min_le_left _ _)
  have hs₂ : σ<σ₂ := lt_of_lt_of_le hσlt (min_le_right _ _)
  constructor
  · have hp := designatedAtLeastProbability_ge_allWrong Real.tanh (tanhConcreteTarget K k) π σ J
      (fun j _ => (hlarge N hN).1 σ hσ j)
    rw [h.1] at hp
    exact (hsmall₁ σ hσ hs₁).trans_le hp
  · intro j hj
    have hh := hsmall₂ σ hσ hs₂ j hj
    exact ⟨hh,by linarith⟩

end NeuralGeneralization.OnlineLower
