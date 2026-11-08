import NeuralGeneralization.OnlineLowerTanhCodeOffIntegral

/-! # Relative weighted off-mass after peak localization -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

lemma normalized_offmass_bound (s D K B A C E tail ρ Q : ℝ)
    (hs:0<s) (hD:s≤D) (hK:0≤K) (hB:0<B) (hA:0≤A) (hC:0≤C)
    (hE:0≤E) (htail:0≤tail) (hρ:B*s≤ρ) (hDs:D=2*s^2)
    (hcap:s*Q≤K*D*(s*A*Real.sqrt E+C*tail)) :
    Q≤((2*K/B)*(A+C))*ρ*(D*Real.sqrt E+tail) := by
  let H:ℝ:=s*A*Real.sqrt E+C*tail
  have hH:0≤H := by dsimp [H];positivity
  have hQ : Q≤2*K*s*H := by
    apply (mul_le_mul_iff_right₀ hs).mp
    rw [hDs] at hcap
    dsimp [H]
    nlinarith only [hcap]
  have hc : 2*K*s≤(2*K/B)*ρ := by
    have hh := mul_le_mul_of_nonneg_left hρ (show 0≤2*K/B by positivity)
    have heq : (2*K/B)*(B*s)=2*K*s := by field_simp
    rwa [heq] at hh
  have hρ0 : 0≤ρ := (mul_pos hB hs).le.trans hρ
  have hD0 : 0≤D := hs.le.trans hD
  have hJ : H≤(A+C)*(D*Real.sqrt E+tail) := by
    have hh := mul_le_mul_of_nonneg_right hD (mul_nonneg hA (Real.sqrt_nonneg E))
    have hcross1 : 0≤A*tail := mul_nonneg hA htail
    have hcross2 : 0≤C*D*Real.sqrt E := by positivity
    dsimp [H]
    nlinarith only [hh,hcross1,hcross2]
  calc
    Q≤2*K*s*H := hQ
    _≤((2*K/B)*ρ)*H := mul_le_mul_of_nonneg_right hc hH
    _≤((2*K/B)*ρ)*((A+C)*(D*Real.sqrt E+tail)) :=
      mul_le_mul_of_nonneg_left hJ (by positivity)
    _=_ := by ring

def codeOffConstant (K B M:ℝ) : ℝ :=
  (2*K/B)*(Real.sqrt (4*M)*sqrtFrequencyKernelConstant+32/Real.pi)

theorem codeOffConstant_pos (K B M:ℝ) (hK:0<K) (hB:0<B) (hM:0≤M) :
    0<codeOffConstant K B M := by
  unfold codeOffConstant
  have ha : 0≤Real.sqrt (4*M)*sqrtFrequencyKernelConstant :=
    mul_nonneg (Real.sqrt_nonneg _) sqrtFrequencyKernelConstant_nonneg
  exact mul_pos (by positivity) (by positivity)

/-- The entire analytic error is now a polynomial prefactor times the
square root of the low-frequency height, plus an exponential tail. -/
theorem carrierCodeMass_relative_height_tail {p r:ℕ} (hp:2≤p) (hr:1≤r)
    (size:Fin p→Bool→ℕ) (hR:∀i s,2*r≤size i s) (heven:∀i s,Even (size i s))
    (A:Finset (Fin p→Bool)) (w:(Fin p→Bool)→ℝ) (K B M E T ρ:ℝ)
    (hK:0<K) (hB:0<B) (hM:0≤M) (hE:0≤E) (hT:1≤T)
    (hw0:∀θ∈A,0≤w θ) (hw:∀θ∈A,w θ≤K*(p*(2*r):ℕ))
    (bias:ℝ) (u:Fin (carrierDimension size)→ℝ)
    (henergy:incomingEnergy u≤(p*(2*r):ℕ)*M^2)
    (hheight:∀t∈Ioc 0 T,retainedCarrierProduct size A u t≤2*E)
    (hρ:B*Real.sqrt ((p*r:ℕ):ℝ)≤ρ) :
    carrierCodeMass size A w bias u≤codeOffConstant K B M*ρ*
      (((p*(2*r):ℕ):ℝ)*Real.sqrt E+Real.exp (-(Real.pi/8)*T)) := by
  let s:ℝ:=Real.sqrt ((p*r:ℕ):ℝ)
  let D:ℝ:=((p*(2*r):ℕ):ℝ)
  have hs:0<s := by dsimp [s];positivity
  have hs2:s^2=(p*r:ℕ) := Real.sq_sqrt (by positivity)
  have hDs:D=2*s^2 := by dsimp [D];rw [hs2];push_cast;ring
  have hD:s≤D := by
    have hn:(1:ℝ)≤(p*r:ℕ) := by exact_mod_cast (show 1≤p*r by nlinarith)
    rw [hDs]
    nlinarith [hs.le]
  have hh := carrierCodeMass_height_tail hp hr size hR heven A w (K*D)
    hw0 hw (by dsimp [D];positivity) bias u M (2*E) T hM (by positivity) hT henergy hheight
  have hroot : Real.sqrt (2*M*(2*E))=Real.sqrt (4*M)*Real.sqrt E := by
    rw [show 2*M*(2*E)=(4*M)*E by ring,Real.sqrt_mul (by positivity : 0≤4*M)]
  rw [hroot] at hh
  have hcap : s*carrierCodeMass size A w bias u≤K*D*
      (s*(Real.sqrt (4*M)*sqrtFrequencyKernelConstant)*Real.sqrt E+(32/Real.pi)*Real.exp (-(Real.pi/8)*T)) := by
    simpa only [s,mul_comm,mul_left_comm,mul_assoc] using hh
  exact normalized_offmass_bound s D K B (Real.sqrt (4*M)*sqrtFrequencyKernelConstant)
    (32/Real.pi) E (Real.exp (-(Real.pi/8)*T)) ρ (carrierCodeMass size A w bias u)
    hs hD hK.le hB (mul_nonneg (Real.sqrt_nonneg _) sqrtFrequencyKernelConstant_nonneg)
    (by positivity) hE (Real.exp_pos _).le hρ hDs hcap

end NeuralGeneralization.OnlineLowerTanh
