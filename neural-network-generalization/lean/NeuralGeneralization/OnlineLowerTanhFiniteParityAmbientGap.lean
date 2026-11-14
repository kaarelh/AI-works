import NeuralGeneralization.OnlineLowerTanhFiniteParityQuadraticGap
import NeuralGeneralization.OnlineLowerTanhCodeSupport

/-! A quadratic selected-support gap in the complete physical parameter space. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1800000
open scoped BigOperators Topology
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel TanhDifferential

def supportedAffinePoint {d:ℕ} (A:Finset (Fin d)) (a:ℝ) : Fin (d+1)→ℝ :=
  Fin.cases 0 (fun i=>if i∈A then a else 0)

def selectedAffineCoefficient {d:ℕ} (A:Finset (Fin d)) (z:Fin (d+1)→ℝ) : ℝ :=
  walshCoefficients (fun x=>Real.tanh (z 0+incomingLinear (fun i=>z i.succ) x)) A

def selectedAbsoluteRatio {d:ℕ} (A:Finset (Fin d)) (z:Fin (d+1)→ℝ) : ℝ :=
  |selectedAffineCoefficient A z|/Real.sqrt (∑i,z i^2)

def effectiveAffineParameters {d:ℕ} (A:Finset (Fin d)) (y:Cube Aᶜ.card)
    (z:Fin (d+1)→ℝ) : Fin (A.card+1)→ℝ :=
  Fin.cases (z 0+incomingLinear (subsetWeights Aᶜ (fun i=>z i.succ)) y)
    (subsetWeights A (fun i=>z i.succ))

lemma effectiveAffineParameters_at_supported {d:ℕ} (A:Finset (Fin d)) (a:ℝ)
    (y:Cube Aᶜ.card) :
    effectiveAffineParameters A y (supportedAffinePoint A a)=Fin.cases 0 (fun _:Fin A.card=>a) := by
  funext i
  refine Fin.cases ?_ (fun j=>?_) i
  · simp only [effectiveAffineParameters,supportedAffinePoint,Fin.cases_zero,Fin.cases_succ,
      subsetWeights,incomingLinear,zero_add]
    apply Finset.sum_eq_zero
    intro j _
    have hj:(Aᶜ.equivFin.symm j).val∉A:=Finset.mem_compl.mp (Aᶜ.equivFin.symm j).property
    simp [hj]
  · simp only [effectiveAffineParameters,supportedAffinePoint,Fin.cases_succ,subsetWeights]
    simp [(A.equivFin.symm j).property]

lemma continuous_effectiveAffineParameters {d:ℕ} (A:Finset (Fin d)) (y:Cube Aᶜ.card) :
    Continuous (effectiveAffineParameters A y) := by
  apply continuous_pi
  intro i
  refine Fin.cases ?_ (fun j=>?_) i
  · unfold effectiveAffineParameters subsetWeights incomingLinear
    simp only [Fin.cases_zero]
    fun_prop
  · unfold effectiveAffineParameters subsetWeights
    simp only [Fin.cases_succ]
    fun_prop

lemma selectedAffineCoefficient_conditioned {d:ℕ} (A:Finset (Fin d)) (z:Fin (d+1)→ℝ) :
    selectedAffineCoefficient A z=
      cubeMean (fun y=>affineParityCoefficient A.card (effectiveAffineParameters A y z)) := by
  rw [selectedAffineCoefficient,tanh_walshCoefficient_eq_conditioned]
  rfl

lemma supportedAffinePoint_energy {d:ℕ} (A:Finset (Fin d)) (a:ℝ) :
    (∑i,(supportedAffinePoint A a i)^2)=(A.card:ℝ)*a^2 := by
  classical
  simp only [supportedAffinePoint,Fin.sum_univ_succ,Fin.cases_zero,Fin.cases_succ,zero_pow (by norm_num : (2:ℕ)≠0),zero_add]
  simp

lemma effectiveAffineParameters_energy_mean {d:ℕ} (A:Finset (Fin d)) (a:ℝ)
    (z:Fin (d+1)→ℝ) :
    cubeMean (fun y=>∑i,(effectiveAffineParameters A y z i-(Fin.cases 0 (fun _:Fin A.card=>a) i))^2)=
      ∑i,(z i-supportedAffinePoint A a i)^2 := by
  classical
  simp only [Fin.sum_univ_succ,effectiveAffineParameters,Fin.cases_zero,Fin.cases_succ,sub_zero]
  rw [cubeMean_add,affine_secondMoment,cubeMean_const]
  rw [incomingEnergy_subsetWeights]
  have hactive:(∑i:Fin A.card,(subsetWeights A (fun j=>z j.succ) i-a)^2)=
      ∑i∈A,(z i.succ-a)^2:=subset_sum_reindex A (fun i=>(z i.succ-a)^2)
  rw [hactive]
  simp only [supportedAffinePoint,Fin.cases_zero,Fin.cases_succ,sub_zero]
  rw [←Finset.sum_add_sum_compl A (fun i=>(z i.succ-(if i∈A then a else 0))^2)]
  have hA:(∑i∈A,(z i.succ-(if i∈A then a else 0))^2)=∑i∈A,(z i.succ-a)^2:=by
    apply Finset.sum_congr rfl
    intro i hi
    simp [hi]
  have hAc:(∑i∈Aᶜ,(z i.succ-(if i∈A then a else 0))^2)=∑i∈Aᶜ,(z i.succ)^2:=by
    apply Finset.sum_congr rfl
    intro i hi
    simp [Finset.mem_compl.mp hi]
  rw [hA,hAc]
  ring

theorem selectedAffineCoefficient_energy_tangent {d:ℕ} (A:Finset (Fin d))
    (hA:5≤A.card) (hodd:Odd A.card) :
    ∃c>0,∀ᶠ z in 𝓝 (supportedAffinePoint A (balancedGain (A.card/2))),
      (-1:ℝ)^(A.card/2)*selectedAffineCoefficient A z≤
        balancedParity (A.card/2) (balancedGain (A.card/2))/((A.card:ℝ)*balancedGain (A.card/2))*
          (∑i∈A,z i.succ)-c*(∑i,(z i-supportedAffinePoint A (balancedGain (A.card/2)) i)^2) := by
  obtain ⟨c,hc,hev⟩:=signedAffineCoefficient_energy_tangent_odd A.card hA hodd
  refine ⟨c,hc,?_⟩
  have hall:∀y:Cube Aᶜ.card,∀ᶠ z in 𝓝 (supportedAffinePoint A (balancedGain (A.card/2))),
      (-1:ℝ)^(A.card/2)*affineParityCoefficient A.card (effectiveAffineParameters A y z)≤
        balancedParity (A.card/2) (balancedGain (A.card/2))/((A.card:ℝ)*balancedGain (A.card/2))*
          (∑i:Fin A.card,effectiveAffineParameters A y z i.succ)-
        c*(∑i,(effectiveAffineParameters A y z i-(Fin.cases 0 (fun _:Fin A.card=>balancedGain (A.card/2)) i))^2):=by
    intro y
    have ht: Tendsto (effectiveAffineParameters A y)
        (𝓝 (supportedAffinePoint A (balancedGain (A.card/2))))
        (𝓝 (Fin.cases 0 (fun _:Fin A.card=>balancedGain (A.card/2)))):=by
      have ht:=(continuous_effectiveAffineParameters A y).continuousAt
        (x:=supportedAffinePoint A (balancedGain (A.card/2))) |>.tendsto
      rwa [effectiveAffineParameters_at_supported] at ht
    exact ht.eventually hev
  filter_upwards [Filter.eventually_all.mpr hall] with z hz
  have hh:=cubeMean_mono _ _ hz
  rw [cubeMean_const_mul,←selectedAffineCoefficient_conditioned,cubeMean_sub] at hh
  simp_rw [cubeMean_const_mul] at hh
  rw [effectiveAffineParameters_energy_mean] at hh
  have he:(fun y:Cube Aᶜ.card=>∑i:Fin A.card,effectiveAffineParameters A y z i.succ)=
      (fun _=>∑i∈A,z i.succ):=by
    funext y
    exact subset_sum_reindex A (fun i=>z i.succ)
  rw [he,cubeMean_const] at hh
  exact hh

lemma selectedAffineCoefficient_at_supported {d:ℕ} (A:Finset (Fin d)) (hodd:Odd A.card) (a:ℝ) :
    (-1:ℝ)^(A.card/2)*selectedAffineCoefficient A (supportedAffinePoint A a)=balancedParity (A.card/2) a := by
  have hcard:A.card=2*(A.card/2)+1:=by obtain ⟨k,hk⟩:=hodd;omega
  rw [selectedAffineCoefficient_conditioned]
  simp_rw [effectiveAffineParameters_at_supported]
  rw [cubeMean_const]
  unfold affineParityCoefficient
  simp only [Fin.cases_zero,Fin.cases_succ]
  rw [hcard]
  have hd:(2*(A.card/2)+1)/2=A.card/2:=by omega
  rw [hd]
  rfl

lemma continuous_selectedAffineCoefficient {d:ℕ} (A:Finset (Fin d)) :
    Continuous (selectedAffineCoefficient A) := by
  unfold selectedAffineCoefficient walshCoefficients uniformCubeMean incomingLinear
  fun_prop

lemma selected_sum_le_radial {d:ℕ} (A:Finset (Fin d)) (z:Fin (d+1)→ℝ) :
    (∑i∈A,z i.succ)≤Real.sqrt (A.card:ℝ)*Real.sqrt (∑i,z i^2) := by
  classical
  have hcs:=Finset.sum_mul_sq_le_sq_mul_sq A (fun i=>z i.succ) (fun _=> (1:ℝ))
  simp only [mul_one,one_pow,Finset.sum_const,Finset.card_univ,nsmul_eq_mul,mul_one] at hcs
  have hE:(∑i∈A,(z i.succ)^2)≤∑i:Fin (d+1),z i^2:=by
    have hh: (∑i∈A,(z i.succ)^2)≤∑i:Fin d,(z i.succ)^2:=
      Finset.sum_le_univ_sum_of_nonneg (fun _=>sq_nonneg _)
    rw [Fin.sum_univ_succ]
    linarith [sq_nonneg (z 0)]
  have hmul:=mul_le_mul_of_nonneg_left hE (Nat.cast_nonneg A.card : (0:ℝ)≤A.card)
  have hsqA:=Real.sq_sqrt (Nat.cast_nonneg A.card : (0:ℝ)≤A.card)
  have hsqE:(Real.sqrt (∑i,z i^2))^2=∑i,z i^2:=
    Real.sq_sqrt (Finset.sum_nonneg (fun i _=>sq_nonneg (z i)))
  have hp:0≤Real.sqrt (A.card:ℝ)*Real.sqrt (∑i,z i^2):=by positivity
  have he:(Real.sqrt (A.card:ℝ)*Real.sqrt (∑i,z i^2))^2=(A.card:ℝ)*(∑i,z i^2):=by rw [mul_pow,hsqA,hsqE]
  nlinarith only [hcs,hmul,hp,he]

lemma norm_sq_le_sum_sq {n:ℕ} (z:Fin n→ℝ) : ‖z‖^2≤∑i,z i^2 := by
  have hs:0≤∑i,z i^2:=Finset.sum_nonneg (fun i _=>sq_nonneg _)
  have hsqrt:=Real.sq_sqrt hs
  have hnorm:‖z‖≤Real.sqrt (∑i,z i^2):=by
    apply (pi_norm_le_iff_of_nonneg (Real.sqrt_nonneg _)).mpr
    intro i
    have hi:(z i)^2≤∑j,z j^2:=Finset.single_le_sum (fun j _=>sq_nonneg _) (Finset.mem_univ i)
    rw [Real.norm_eq_abs]
    nlinarith [abs_nonneg (z i),sq_abs (z i),Real.sqrt_nonneg (∑i,z i^2)]
  nlinarith [norm_nonneg z,Real.sqrt_nonneg (∑i,z i^2)]

/-- The selected absolute ratio loses a fixed positive multiple of the
squared full parameter displacement. This includes every inactive weight. -/
theorem selectedAbsoluteRatio_quadratic_gap {d:ℕ} (A:Finset (Fin d))
    (hA:5≤A.card) (hodd:Odd A.card) :
    ∃c>0,∀ᶠ z in 𝓝 (supportedAffinePoint A (balancedGain (A.card/2))),
      selectedAbsoluteRatio A z≤
        selectedAbsoluteRatio A (supportedAffinePoint A (balancedGain (A.card/2)))-
          c*‖z-supportedAffinePoint A (balancedGain (A.card/2))‖^2 := by
  let a:=balancedGain (A.card/2)
  let q:=balancedParity (A.card/2) a
  let n:ℝ:=A.card
  let x:=supportedAffinePoint A a
  let R:=Real.sqrt (n*a^2)
  let U:=R+1
  have ha:0<a:=balancedGain_pos _
  have hq:0<q:=balancedParity_gain_pos _
  have hn:0<n:=Nat.cast_pos.mpr (by omega)
  have hR:0<R:=Real.sqrt_pos.mpr (by positivity)
  have hU:0<U:=by dsimp [U];linarith
  have hsqrt:Real.sqrt (n*a^2)=Real.sqrt n*a:=by
    rw [Real.sqrt_mul hn.le,Real.sqrt_sq_eq_abs,abs_of_pos ha]
  have hscale:q/(n*a)*Real.sqrt n=q/R:=by
    dsimp [R]
    rw [hsqrt]
    have hh:=Real.sq_sqrt hn.le
    have hs:0<Real.sqrt n:=Real.sqrt_pos.mpr hn
    field_simp
    nlinarith only [hh]
  have hbase:(-1:ℝ)^(A.card/2)*selectedAffineCoefficient A x=q:=selectedAffineCoefficient_at_supported A hodd a
  have he_abs:|selectedAffineCoefficient A x|=q:=by
    have hh:=abs_of_pos (hbase.symm ▸ hq)
    rw [abs_mul,abs_neg_one_pow,one_mul,hbase] at hh
    exact hh
  have hvalue:selectedAbsoluteRatio A x=q/R:=by
    rw [selectedAbsoluteRatio,he_abs,supportedAffinePoint_energy]
  have hc:Continuous (fun z:Fin (d+1)→ℝ=>(-1:ℝ)^(A.card/2)*selectedAffineCoefficient A z):=
    (continuous_selectedAffineCoefficient A).const_mul _
  have hevent:∀ᶠ z in 𝓝 x,0<(-1:ℝ)^(A.card/2)*selectedAffineCoefficient A z:=
    (isOpen_Ioi.preimage hc).mem_nhds (by change 0<(-1:ℝ)^(A.card/2)*selectedAffineCoefficient A x;rw [hbase];exact hq)
  have hrad:Continuous (fun z:Fin (d+1)→ℝ=>Real.sqrt (∑i,z i^2)):=by fun_prop
  have hradevent:∀ᶠ z in 𝓝 x,Real.sqrt (∑i,z i^2)∈Ioo 0 U:=by
    apply (isOpen_Ioo.preimage hrad).mem_nhds
    change Real.sqrt (∑i,(supportedAffinePoint A a i)^2)∈Ioo 0 U
    rw [supportedAffinePoint_energy]
    exact ⟨hR,by dsimp [U];linarith⟩
  obtain ⟨c,hcpos,htangent⟩:=selectedAffineCoefficient_energy_tangent A hA hodd
  refine ⟨c/U,div_pos hcpos hU,?_⟩
  filter_upwards [htangent,hevent,hradevent] with z hz hsign hradz
  have heq:|selectedAffineCoefficient A z|=(-1:ℝ)^(A.card/2)*selectedAffineCoefficient A z:=by
    have hh:=abs_of_pos hsign
    rwa [abs_mul,abs_neg_one_pow,one_mul] at hh
  have hsum:=selected_sum_le_radial A z
  have hupper:=mul_le_mul_of_nonneg_left hsum (show 0≤q/(n*a) by positivity)
  rw [←mul_assoc,hscale] at hupper
  have hnum:(-1:ℝ)^(A.card/2)*selectedAffineCoefficient A z≤
      q/R*Real.sqrt (∑i,z i^2)-c*(∑i,(z i-x i)^2):=hz.trans (sub_le_sub_right hupper _)
  have hnorm:=norm_sq_le_sum_sq (z-x)
  have hcost:(c/U)*‖z-x‖^2*Real.sqrt (∑i,z i^2)≤c*(∑i,(z i-x i)^2):=by
    calc
      _ ≤ (c/U)*‖z-x‖^2*U:=mul_le_mul_of_nonneg_left hradz.2.le (by positivity)
      _ = c*‖z-x‖^2:=by field_simp
      _ ≤ c*(∑i,(z i-x i)^2):=mul_le_mul_of_nonneg_left hnorm hcpos.le
  change selectedAbsoluteRatio A z≤selectedAbsoluteRatio A x-(c/U)*‖z-x‖^2
  rw [selectedAbsoluteRatio,heq,hvalue]
  apply (div_le_iff₀ hradz.1).mpr
  nlinarith only [hnum,hcost]

lemma supportedAffinePoint_radius_pos {d:ℕ} (A:Finset (Fin d)) (hA:0<A.card)
    (a:ℝ) (ha:0<a) : 0<Real.sqrt (∑i,(supportedAffinePoint A a i)^2) := by
  rw [supportedAffinePoint_energy]
  exact Real.sqrt_pos.mpr (mul_pos (Nat.cast_pos.mpr hA) (sq_pos_of_pos ha))

lemma selectedAbsoluteRatio_at_supported {d:ℕ} (A:Finset (Fin d)) (hodd:Odd A.card) :
    selectedAbsoluteRatio A (supportedAffinePoint A (balancedGain (A.card/2)))=
      (balancedCost (A.card/2))⁻¹ := by
  let a:=balancedGain (A.card/2)
  have ha:0<a:=balancedGain_pos _
  have hq:=balancedParity_gain_pos (A.card/2)
  have hcard:A.card=2*(A.card/2)+1:=by obtain ⟨k,hk⟩:=hodd;omega
  have hh:=selectedAffineCoefficient_at_supported A hodd a
  have habs:|selectedAffineCoefficient A (supportedAffinePoint A a)|=balancedParity (A.card/2) a:=by
    have h:=congrArg abs hh
    rw [abs_mul,abs_neg_one_pow,one_mul,abs_of_pos hq] at h
    exact h
  change selectedAbsoluteRatio A (supportedAffinePoint A a)=(balancedCost (A.card/2))⁻¹
  rw [selectedAbsoluteRatio,habs,supportedAffinePoint_energy,
    Real.sqrt_mul (Nat.cast_nonneg A.card),Real.sqrt_sq_eq_abs,abs_of_pos ha]
  unfold balancedCost
  rw [←hcard,inv_div]
  congr 1
  ring

end NeuralGeneralization.OnlineLowerTanh
