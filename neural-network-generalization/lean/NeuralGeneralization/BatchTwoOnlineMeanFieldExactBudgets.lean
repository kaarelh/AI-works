import NeuralGeneralization.IdealTowerTransport
import NeuralGeneralization.MeanFieldCertificateExtraction

/-! Literal real-valued backward budgets from the online manuscript appendix.
Here `r` counts internal hidden matrices, so there are `r+1` hidden layers. -/
noncomputable section
set_option maxHeartbeats 800000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineMeanFieldExact
open ConcreteModel GaussianAngularPrice GaussianFieldTilt CovarianceFactor TanhDifferential
open IdealTowerTransport

def grow (B : ℝ) : ℕ → ℝ
  | 0 => B
  | n+1 => 8*grow B n*(1+grow B n)^2

def layerBudget (r : ℕ) (K : ℝ) (s : ℕ) : ℝ := grow (32*(r+1)*K^2) ((r+1)-s)
def maxTilt (r : ℕ) (K : ℝ) : ℝ := layerBudget r K 1

def covariancePrecision (r : ℕ) (K : ℝ) : ℝ :=
  1/(32*K*(r+1)*(8*(1+maxTilt r K)^2)^r)

def sparseCount (r : ℕ) (K : ℝ) : ℕ := ⌈(maxTilt r K)^2/2⌉₊
def testEntropy (d : ℕ) : ℝ := Real.log (2*(2:ℝ)^(2*d)+1)
def learnerThreshold (d r : ℕ) (K : ℝ) : ℕ :=
  ⌈max 1 (2*(sparseCount r K:ℝ)*testEntropy d/(K-1))⌉₊

def compressedWidth (d r : ℕ) (K : ℝ) : ℕ :=
  ⌈2*(covariancePrecision r K)⁻¹^2*Real.log (8*(r+1)*(2:ℝ)^(2*d))⌉₊
def hiddenParameterCount (d u r : ℕ) : ℕ := u*(d+1)+r*u^2
def compressedBound (d r : ℕ) (K : ℝ) : ℝ :=
  max (max 1 (Real.sqrt (4*maxTilt r K+2*Real.log (8*max (hiddenParameterCount d (compressedWidth d r K) r:ℝ) 1))))
    (4*K/(compressedWidth d r K:ℝ))
def sensitivity (d u r : ℕ) (B : ℝ) : ℝ :=
  ((d:ℝ)+(r+2)*u)*(1+u*(B+1))^(r+1)
def capacity (d r : ℕ) (K : ℝ) : ℝ :=
  let u:=compressedWidth d r K
  let B:=compressedBound d r K
  (hiddenParameterCount d u r+u:ℕ)*Real.log (3+16*B*sensitivity d u r B)

theorem grow_pos {B : ℝ} (hB : 0<B) (n : ℕ) : 0<grow B n := by
  induction n with
  | zero => exact hB
  | succ n ih => simp only [grow]; positivity

theorem grow_mono {B : ℝ} (hB : 0≤B) : Monotone (grow B) := by
  have hn (n:ℕ):0≤grow B n := by
    induction n with
    | zero=>exact hB
    | succ n ih=>simp only [grow];positivity
  apply monotone_nat_of_le_succ
  intro n
  change grow B n≤8*grow B n*(1+grow B n)^2
  nlinarith [sq_nonneg (grow B n),hn n]

theorem layerBudget_pos (r : ℕ) {K : ℝ} (hK : 0<K) (s : ℕ) :
    0<layerBudget r K s := grow_pos (by positivity) _

theorem layerBudget_terminal (r : ℕ) (K : ℝ) :
    layerBudget r K (r+1)=32*(r+1)*K^2 := by simp [layerBudget,grow]

theorem layerBudget_backward {r s : ℕ} (K : ℝ) (hs : s<r+1) :
    layerBudget r K s=8*(1+layerBudget r K (s+1))^2*layerBudget r K (s+1) := by
  have hsub:(r+1)-s=((r+1)-(s+1))+1:=by omega
  unfold layerBudget
  rw [hsub,grow]
  ring

theorem layerBudget_le_max (r : ℕ) (K : ℝ) {s : ℕ} (hs : 1≤s) :
    layerBudget r K s≤maxTilt r K := by
  apply grow_mono (by positivity)
  omega

theorem covariancePrecision_pos (r : ℕ) {K : ℝ} (hK : 0<K) :
    0<covariancePrecision r K := by
  have hg:=layerBudget_pos r hK 1
  unfold covariancePrecision maxTilt
  positivity

theorem covariancePrecision_error (r : ℕ) {K : ℝ} (hK : 0<K) :
    4*K*((r+1:ℝ)*(8*(1+maxTilt r K)^2)^r*covariancePrecision r K)=1/8 := by
  have hg:=layerBudget_pos r hK 1
  have hbase:8*(1+maxTilt r K)^2≠0:=by unfold maxTilt;positivity
  unfold covariancePrecision
  field_simp
  <;> ring

theorem idealTower_error {X : Type*} [Fintype X] [DecidableEq X]
    {J : ℕ→Type*} [∀s,Fintype (J s)]
    (A : ∀s,X→J s→ℝ) (A₀ : X→X→ℝ) (Γ : ℕ→X→X→ℝ)
    {r : ℕ} {K : ℝ} (hK : 0<K)
    (hbase : ∀x y,gram A₀ x y=gram (A 0) x y)
    (hΓ : ∀s,s≤r→couplingMass (Γ s)≤layerBudget r K (s+1))
    (hcert : ∀s,s≤r→∀x y,|gram (A (s+1)) x y-tiltedMoment (A s) (Γ s) x y|≤
      K/layerBudget r K (s+1)) :
    ∀s,s≤r+1→∀x y,|gram (A s) x y-gram (idealTower A₀ Γ s) x y|≤
      (s:ℝ)*K/layerBudget r K s := by
  intro s
  induction s with
  | zero=>intro hs x y;simp [hbase]
  | succ s ih=>
    intro hs x y
    have hsr:s≤r:=by omega
    have hg:=layerBudget_pos r hK (s+1)
    have hgs:=layerBudget_pos r hK s
    have he:0≤(s:ℝ)*K/layerBudget r K s:=by positivity
    have hp:=tiltedMoment_stability (idealTower A₀ Γ s) (A s) (Γ s) x y hg.le he
      (hΓ s hsr) (ih (by omega))
    rw [idealTower_step]
    apply (abs_sub_le _ _ _).trans
    apply (add_le_add (hcert s hsr x y) hp).trans
    rw [layerBudget_backward K (by omega : s<r+1)]
    have hb:8*(1+layerBudget r K (s+1))^2≠0:=by positivity
    apply le_of_eq
    push_cast
    field_simp
    <;> ring

theorem idealTower_terminal_error {X : Type*} [Fintype X] [DecidableEq X]
    {J : ℕ→Type*} [∀s,Fintype (J s)]
    (A : ∀s,X→J s→ℝ) (A₀ : X→X→ℝ) (Γ : ℕ→X→X→ℝ)
    {r : ℕ} {K : ℝ} (hK : 0<K)
    (hbase : ∀x y,gram A₀ x y=gram (A 0) x y)
    (hΓ : ∀s,s≤r→couplingMass (Γ s)≤layerBudget r K (s+1))
    (hcert : ∀s,s≤r→∀x y,|gram (A (s+1)) x y-tiltedMoment (A s) (Γ s) x y|≤
      K/layerBudget r K (s+1)) (x y:X) :
    |gram (A (r+1)) x y-tiltedMoment (idealTower A₀ Γ r) (Γ r) x y|≤1/(32*K) := by
  have h:=idealTower_error A A₀ Γ hK hbase hΓ hcert (r+1) le_rfl x y
  rw [idealTower_step,layerBudget_terminal] at h
  have heq:((r+1:ℕ):ℝ)*K/(32*(r+1)*K^2)=1/(32*K):=by push_cast;field_simp
  rwa [heq] at h

end NeuralGeneralization.BatchTwoOnlineMeanFieldExact
