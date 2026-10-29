import StructuralPosteriorAssembly
import PhysicalScaleRegimes

/-! Separation and recombination of the three physical scale regimes. -/
noncomputable section
set_option maxHeartbeats 1000000
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def pathCircuitResource (d R K : ℕ) (f : BooleanFunction d) : Prop :=
  ∃c : ThresholdCircuit d,c.size≤R^K ∧ c.depth≤K*Nat.log2 R ∧ c.eval=f

def SmallActionPathCapacity : Prop :=
  ∀B : ℝ,0≤B→∃P K : ℕ,1≤P ∧ 1≤K ∧
    ∀d H R : ℕ,1≤d→1≤H→2≤R→d+H+1≤R→P*Nat.log2 R≤H→
      ∀t : ℝ,0<t→t≤1→∀f : BooleanFunction d,
      ∀path : ControlledMarginPath d H t f,
        path.action≤scalarBaseline.toReal+B*(Real.log (R:ℝ))^2/(H:ℝ)→pathCircuitResource d R K f

def LongNearcriticalPathCapacity : Prop :=
  ∀B : ℝ,0≤B→∃Q : ℝ,1≤Q ∧ ∃P K : ℕ,1≤P ∧ 1≤K ∧
    ∀d H R : ℕ,1≤d→1≤H→2≤R→d+H+1≤R→P*Nat.log2 R≤H→
      ∀t : ℝ,0<t→t≤1→0<(t^2)⁻¹-1→(t^2)⁻¹-1<1/4→
      Q*Real.log (R:ℝ)≤((t^2)⁻¹-1)*(H:ℝ)→∀f : BooleanFunction d,
      ∀path : ControlledMarginPath d H t f,
        path.action≤(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
          B*(((t^2)⁻¹-1)*Real.log (R:ℝ)+(Real.log (R:ℝ))^2/(H:ℝ))→
        pathCircuitResource d R K f

def FarStrongPathCapacity : Prop :=
  ∀B : ℝ,0≤B→∃P K : ℕ,1≤P ∧ 1≤K ∧
    ∀d H R : ℕ,1≤d→1≤H→2≤R→d+H+1≤R→P*Nat.log2 R≤H→
      ∀t : ℝ,0<t→t≤1→1/4≤(t^2)⁻¹-1→∀f : BooleanFunction d,
      ∀path : ControlledMarginPath d H t f,
        path.action≤(H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
          B*(((t^2)⁻¹-1)*Real.log (R:ℝ)+(Real.log (R:ℝ))^2/(H:ℝ))→
        pathCircuitResource d R K f

theorem pathCircuitResource_mono {d R K K' : ℕ} {f : BooleanFunction d}
    (hR : 1≤R) (hK : K≤K') (h : pathCircuitResource d R K f) :
    pathCircuitResource d R K' f := by
  obtain ⟨c,hs,hd,he⟩ := h
  exact ⟨c,hs.trans (Nat.pow_le_pow_right hR hK),
    hd.trans (Nat.mul_le_mul_right _ hK),he⟩

theorem short_scale_action_with_constant {H a T B Q V A c : ℝ}
    (hH : 0<H) (ha : 0≤a) (hT : 0≤T) (hB : 0≤B) (hQ : 1≤Q)
    (hc : c≤a^2/2) (hshort : a*H≤Q*T)
    (hA : A≤H*c+V+B*(a*T+T^2/H)) :
    A≤V+((2*B+1)*Q^2)*T^2/H := by
  have hQ0 : 0≤Q := by linarith
  have hTQ : T≤Q*T := by nlinarith
  have hprod := mul_le_mul_of_nonneg_left hTQ ha
  have hsq := pow_le_pow_left₀ hT hTQ 2
  have hdiv := div_le_div_of_nonneg_right hsq hH.le
  have hscaled := mul_le_mul_of_nonneg_left (add_le_add hprod hdiv) hB
  have hb : A≤H*c+V+B*(a*(Q*T)+(Q*T)^2/H) := by linarith
  have hh := short_scale_action hH ha (mul_nonneg hQ0 hT) hB hc hshort hb
  convert hh using 1 <;> ring

theorem uniformPathCircuitBound_of_three_regimes
    (hsmall : SmallActionPathCapacity) (hlong : LongNearcriticalPathCapacity)
    (hfar : FarStrongPathCapacity) : UniformPathCircuitBound := by
  intro B hB
  obtain ⟨Q,hQ,Pl,Kl,hPl,hKl,hl⟩ := hlong B hB
  obtain ⟨Ps,Ks,hPs,hKs,hs⟩ := hsmall ((2*B+1)*Q^2) (by positivity)
  obtain ⟨Pf,Kf,hPf,hKf,hf⟩ := hfar B hB
  refine ⟨Ps+Pl+Pf,Ks+Kl+Kf,by omega,by omega,?_⟩
  intro d H R hd hH hR hres hpad t ht ht1 f path haction
  have hps : Ps*Nat.log2 R≤H := (Nat.mul_le_mul_right _ (by omega : Ps≤Ps+Pl+Pf)).trans hpad
  have hpl : Pl*Nat.log2 R≤H := (Nat.mul_le_mul_right _ (by omega : Pl≤Ps+Pl+Pf)).trans hpad
  have hpf : Pf*Nat.log2 R≤H := (Nat.mul_le_mul_right _ (by omega : Pf≤Ps+Pl+Pf)).trans hpad
  have hR1 : 1≤R := by omega
  by_cases hfarcase : 1/4≤(t^2)⁻¹-1
  · exact pathCircuitResource_mono hR1 (by omega : Kf≤Ks+Kl+Kf)
      (hf d H R hd hH hR hres hpf t ht ht1 hfarcase f path haction)
  · have hnear : (t^2)⁻¹-1<1/4 := lt_of_not_ge hfarcase
    have ha : 0≤(t^2)⁻¹-1 := by
      have hh := (one_le_inv₀ (sq_pos_of_pos ht)).mpr (by nlinarith : t^2≤1)
      linarith
    have hlog : 0<Real.log (R:ℝ) := Real.log_pos (by exact_mod_cast (show 1<R by omega))
    by_cases hlongcase : Q*Real.log (R:ℝ)≤((t^2)⁻¹-1)*(H:ℝ)
    · have hap : 0<(t^2)⁻¹-1 := by
        have hQlog : 0<Q*Real.log (R:ℝ) := mul_pos (by linarith) hlog
        nlinarith [Nat.cast_nonneg H (α:=ℝ)]
      exact pathCircuitResource_mono hR1 (by omega : Kl≤Ks+Kl+Kf)
        (hl d H R hd hH hR hres hpl t ht ht1 hap hnear hlongcase f path haction)
    · have hH0 : (0:ℝ)<H := by exact_mod_cast (show 0<H by omega)
      have hct : subcriticalCostBaseline (t^2).toNNReal≤((t^2)⁻¹-1)^2/2 := by
        have hh := subcriticalCostBaseline_quadratic
          (Real.toNNReal_pos.mpr (sq_pos_of_pos ht)).ne'
          (by rw [Real.coe_toNNReal _ (sq_nonneg t)]; nlinarith : ((t^2).toNNReal:ℝ)≤1)
        simpa only [Real.coe_toNNReal _ (sq_nonneg t)] using hh
      have hraw := short_scale_action_with_constant hH0 ha hlog.le hB hQ hct
        (le_of_lt (lt_of_not_ge hlongcase)) haction
      exact pathCircuitResource_mono hR1 (by omega : Ks≤Ks+Kl+Kf)
        (hs d H R hd hH hR hres hps t ht ht1 f path hraw)

#print axioms uniformPathCircuitBound_of_three_regimes
end ConditionalNonpolynomial.Analytic
