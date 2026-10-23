import NeuralGeneralization.BatchTwoOnlineSharpSpectralStability

/-! A common actual finite function class with exact F_L capacity, containing
all finite-width norm sublevels and all spectrally good networks. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel CompressionSampling MeasureTheory

def normFunctions (d r : ℕ) (φ : ℝ→ℝ) (J : ℝ) : Finset (BooleanFunction d) := by
  classical
  exact Finset.univ.filter fun f=>∃v : Weights d (normWidth d r (J+1)) r,
    v∈marginEvent φ (1/2) f ∧ boundedWeights (normWidth d r (J+1)) v

theorem normFunctions_card {d r : ℕ} {J : ℝ} (hJ : 0≤J)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) :
    ((normFunctions d r φ J).card:ℝ)≤Real.exp (normCapacity d r J) := by
  classical
  apply represented_class_card_paper _ (normWidth_pos (by linarith : 1≤J+1)) φ hφ
  intro f hf
  exact (Finset.mem_filter.mp hf).2

theorem mem_normFunctions_of_energy {d N r : ℕ} {J : ℝ} (hd : 1≤d) (hN : 0<N)
    (hJ : 0≤J) (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (hne : (marginEvent (N:=N) (r:=r) φ (1/2) f).Nonempty)
    (hE : 2*networkEnergy (N:=N) (r:=r) φ (1/2) f≤J) :
    f∈normFunctions d r φ J := by
  classical
  obtain ⟨w,hw,hcost⟩:=exists_nearoptimal_margin_network φ (1/2) f hne 1 zero_lt_one
  obtain ⟨v,hv,hvb,_⟩:=norm_compression hd hN (by linarith : 1≤J+1) φ hφ f w (by linarith) hw
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,v,hv,hvb⟩

def goodSpectralWeights (d N r : ℕ) (K a : ℝ) : Set (Weights d N r) :=
  {w | (d:ℝ)/N*(∑i,∑j,w (Sum.inl (i,j))^2)≤K ∧
    (N:ℝ)*(∑i,w (Sum.inr (Sum.inr i))^2)≤K ∧
    ∀s : Fin r,∃H : Fin N×Fin N→ℝ,LowRankGrid.squaredSum H≤K ∧
      ‖matrixOperator (fun ij=>w (Sum.inr (Sum.inl (s,ij.1,ij.2))))-matrixOperator H‖≤a}

theorem goodSpectral_mem_normFunctions {d N r : ℕ} {K : ℝ} (hd : 1≤d) (hN : 0<N)
    (hK : 1≤K) (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (w : Weights d N r) (hw : w∈marginEvent φ (1/2) f)
    (hg : w∈goodSpectralWeights d N r K (spectralRadius r K)) :
    f∈normFunctions d r φ (((r:ℝ)+5)*K) := by
  classical
  obtain ⟨hfirst,hread,hmat⟩:=hg
  choose H hH hres using hmat
  let HH:Fin r→Fin N→Fin N→ℝ:=fun s i j=>H s (i,j)
  have hH':∀s,(∑i,∑j,HH s i j^2)≤K:=by
    intro s
    simpa only [LowRankGrid.squaredSum,Fintype.sum_prod_type] using hH s
  have hres':∀s,matrixActionBound
      (fun i j=>w (Sum.inr (Sum.inl (s,i,j)))-HH s i j) (spectralRadius r K):=by
    intro s x
    exact matrix_residual_action_bound _ (H s) _ (spectralRadius_pos r K).le (hres s) x
  obtain ⟨v,hv,hcost⟩:=truncated_energy_witness hN hK φ hφ f w hw HH hfirst hread hH' hres'
  apply mem_normFunctions_of_energy hd hN (by positivity) φ hφ f ⟨v,hv⟩
  have hh:=networkEnergy_le_of_mem φ (1/2) f v hv
  linarith

theorem spectral_normFunctions_complement_mass_le {d N r : ℕ} {K : ℝ}
    (hd : 1≤d) (hN : 0<N) (hK : 1≤K) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ] :
    (∑f∈Finset.univ\normFunctions d r φ (((r:ℝ)+5)*K),functionMass φ (1/2) μ f)≤
      μ.real (goodSpectralWeights d N r K (spectralRadius r K))ᶜ := by
  classical
  let A:=Finset.univ\normFunctions d r φ (((r:ℝ)+5)*K)
  have heq:μ.real (⋃f∈A,marginEvent φ (1/2) f)=∑f∈A,functionMass φ (1/2) μ f:=by
    exact measureReal_biUnion_finset
      (fun f hf g hg hfg=>marginEvents_disjoint φ (by norm_num) hfg)
      (fun f _=>(isOpen_marginEvent (admissibleActivation_continuous hφ) (1/2) f).measurableSet)
  rw [←heq]
  apply measureReal_mono _ (measure_ne_top μ _)
  intro w hw hgood
  obtain ⟨f,hf,hwf⟩:=Set.mem_iUnion₂.mp hw
  exact (Finset.mem_sdiff.mp hf).2 (goodSpectral_mem_normFunctions hd hN hK φ hφ f w hwf hgood)

end NeuralGeneralization.BatchTwoOnlineSharp
