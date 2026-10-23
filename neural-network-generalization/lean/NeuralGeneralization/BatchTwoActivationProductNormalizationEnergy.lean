import NeuralGeneralization.BatchTwoActivationProductNormalizationConcrete

/-! The exact weighted-energy AM-GM bound on the product normalization. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def weightedLayerEnergy {d N r : ℕ} (w:Weights d N r):Fin r⊕Bool→ℝ
  | .inl s=>∑i,∑j,w (.inr (.inl (s,i,j)))^2
  | .inr true=>(d:ℝ)/N*(∑i,∑j,w (.inl (i,j))^2)
  | .inr false=>(N:ℝ)*(∑i,w (.inr (.inr i))^2)

theorem weightedLayerEnergy_nonneg {d N r : ℕ} (w:Weights d N r) (i:Fin r⊕Bool):
    0≤weightedLayerEnergy w i:=by
  cases i with
  | inl s=>unfold weightedLayerEnergy;positivity
  | inr b=>cases b <;> unfold weightedLayerEnergy <;> positivity

theorem weightedLayerEnergy_sum {d N r : ℕ} (w:Weights d N r):
    ∑i,weightedLayerEnergy w i=weightedSquaredNorm w:=by
  simp only [Fintype.sum_sum_type,Fintype.sum_bool,weightedLayerEnergy,weightedSquaredNorm]
  ring

theorem product_le_average_power {ι:Type*} [Fintype ι] [Nonempty ι]
    (e:ι→ℝ) (he:∀i,0≤e i) {K:ℝ} (hK:0<K) (hs:∑i,e i≤K):
    ∏i,e i≤(K/(Fintype.card ι:ℝ))^Fintype.card ι:=by
  classical
  let a:=K/(Fintype.card ι:ℝ)
  have hc:0<(Fintype.card ι:ℝ):=by exact_mod_cast Fintype.card_pos
  have ha:0<a:=by dsimp [a];positivity
  have hp (i:ι):e i≤a*Real.exp (e i/a-1):=by
    have hh:=mul_le_mul_of_nonneg_left (Real.add_one_le_exp (e i/a-1)) ha.le
    have heq:a*((e i/a-1)+1)=e i:=by field_simp;ring
    rw [heq] at hh
    exact hh
  calc
    _ ≤ ∏i,a*Real.exp (e i/a-1):=Finset.prod_le_prod (fun i _=>he i) (fun i _=>hp i)
    _ = a^Fintype.card ι*Real.exp ((∑i,e i)/a-(Fintype.card ι:ℝ)):=by
      rw [Finset.prod_mul_distrib,←Real.exp_sum]
      simp [Finset.sum_sub_distrib,←Finset.sum_div]
    _ ≤ a^Fintype.card ι*1:=by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      rw [Real.exp_le_one_iff]
      have hh:(∑i,e i)/a≤(Fintype.card ι:ℝ):=by
        apply (div_le_iff₀ ha).mpr
        have heq:(Fintype.card ι:ℝ)*a=K:=by dsimp [a];field_simp
        rwa [heq]
      linarith
    _ = _:=mul_one _

theorem physicalProduct_sq {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (w:Weights d N r):
    (physicalProduct hN hφ w)^2=
      (∑j,w (.inr (.inr j))^2)*(∑i,∑j,w (.inl (i,j))^2)*
        ∏s:Fin r,∑i,∑j,w (.inr (.inl (s,i,j)))^2:=by
  let W:=physicalProductNetwork hN hφ w
  have hfirst:(layerFrobenius W 0)^2=∑i,∑j,w (.inl (i,j))^2:=by
    rw [layerFrobenius_sq]
    simp only [W,physicalProductNetwork,physicalRows,EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply]
  have hinter (s:ℕ) (hs:s<r):(layerFrobenius W (s+1))^2=
      ∑i,∑j,w (.inr (.inl (⟨s,hs⟩,i,j)))^2:=by
    rw [layerFrobenius_sq]
    simp only [W,physicalProductNetwork,physicalRows,dif_pos hs,EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply]
  have hread:‖W.readout‖^2=∑j,w (.inr (.inr j))^2:=by
    simp only [W,physicalProductNetwork,EuclideanSpace.real_norm_sq_eq,PiLp.toLp_apply]
  change (‖W.readout‖*(∏s∈Finset.range (r+1),layerFrobenius W s))^2=_
  rw [mul_pow,←Finset.prod_pow,hread,Finset.prod_range_succ',hfirst]
  rw [←Fin.prod_univ_eq_prod_range]
  have hp : (∏s:Fin r,(layerFrobenius W (s.val+1))^2)=
      ∏s:Fin r,∑i,∑j,w (.inr (.inl (s,i,j)))^2:=by
    apply Finset.prod_congr rfl
    intro s _
    exact hinter s.val s.isLt
  rw [hp]
  ring

theorem weightedLayerEnergy_product {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (w:Weights d N r):
    ∏i,weightedLayerEnergy w i=(d:ℝ)*(physicalProduct hN hφ w)^2:=by
  have hNR:(N:ℝ)≠0:=by exact_mod_cast hN.ne'
  rw [physicalProduct_sq]
  simp only [Fintype.prod_sum_type,Fintype.prod_bool,weightedLayerEnergy]
  field_simp
  <;> ring

def sharpProductScale (d r : ℕ) (ℓ K:ℝ):ℝ:=
  ℓ^(r+1)/Real.sqrt d*(K/(r+2:ℝ))^((r+2:ℝ)/2)

theorem physicalProduct_le {d N r : ℕ} {φ:ℝ→ℝ} {ℓ K:ℝ}
    (hd:0<d) (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ)
    (w:Weights d N r) (hK:0<K) (hw:weightedSquaredNorm w≤K):
    physicalProduct hN hφ w≤(K/(r+2:ℝ))^((r+2:ℝ)/2)/Real.sqrt d:=by
  have hdR:0<(d:ℝ):=by exact_mod_cast hd
  have hbase:0≤K/(r+2:ℝ):=by positivity
  have hp:=product_le_average_power (weightedLayerEnergy w) (weightedLayerEnergy_nonneg w) hK
    (by rwa [weightedLayerEnergy_sum])
  rw [weightedLayerEnergy_product hN hφ] at hp
  simp only [Fintype.card_sum,Fintype.card_fin,Fintype.card_bool,Nat.cast_add,Nat.cast_ofNat] at hp
  have heq:((K/(r+2:ℝ))^((r+2:ℝ)/2))^2=(K/(r+2:ℝ))^(r+2):=by
    rw [←Real.rpow_mul_natCast hbase ((r+2:ℝ)/2) 2]
    norm_num only [Nat.cast_ofNat]
    have hexp:((r+2:ℝ)/2)*(2:ℝ)=(r+2:ℝ):=by ring
    rw [hexp]
    simpa only [Nat.cast_add,Nat.cast_ofNat] using Real.rpow_natCast (K/(r+2:ℝ)) (r+2)
  apply (sq_le_sq₀ (physicalProduct_nonneg hN hφ w) (by positivity)).mp
  rw [div_pow,heq,Real.sq_sqrt hdR.le]
  apply (le_div_iff₀ hdR).mpr
  nlinarith

end NeuralGeneralization.BatchTwoActivation
