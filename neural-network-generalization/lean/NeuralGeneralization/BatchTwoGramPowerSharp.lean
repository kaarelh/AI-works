import NeuralGeneralization.BatchTwoGramPowerNumerics

/-! The manuscript's literal empirical Gram lower-tail bound, proved using
finite polynomial trace potentials rather than an unformalized matrix
exponential inequality. -/
noncomputable section
set_option autoImplicit false
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoGramPower
open BatchTwoImprovedWeightedSampling Classical
variable {α : Type*} [Fintype α]

theorem weighted_badGram_exponential_radius (w : α→ℝ) (hw : ∀x,0≤w x)
    (hmass : ∑x,w x=1) {D m Q : ℕ} (hm : 0<m) (hQ : 0<Q) (v : α→Fin D→ℝ)
    (hiso : Isotropic w v) (hv : ∀x,(∑i,v x i^2)≤2*(Q:ℝ)) :
    mean (iidWeight w m) (fun s=>if badGram v s then (1:ℝ) else 0)≤
      (D:ℝ)*Real.exp (-(m:ℝ)/(16*((Q:ℝ)+1))) := by
  have hD1 : (1:ℝ)≤Q := by exact_mod_cast hQ
  have hD0 : (0:ℝ)<Q := Nat.cast_pos.mpr hQ
  have hm0 : (0:ℝ)<m := Nat.cast_pos.mpr hm
  let p := m*Q-1
  let a : ℝ := (2*(Q:ℝ)+1)*(m:ℝ)*(2*(Q:ℝ))
  have hp : p+1=m*Q := by dsimp [p]; have := Nat.mul_pos hm hQ; omega
  have hpR : (p:ℝ)+1=(m:ℝ)*(Q:ℝ) := by exact_mod_cast hp
  have ha : 0<a := by dsimp [a]; positivity
  have hec : 1-3*((p:ℝ)+1)/(4*a)=1-3/(8*(2*(Q:ℝ)+1)) := by
    rw [hpR]
    dsimp [a]
    field_simp
    <;> ring
  have hc : 0≤1-3*((p:ℝ)+1)/(4*a) := by
    rw [hec]
    have := (div_le_one (by positivity : 0<8*(2*(Q:ℝ)+1))).mpr
      (show (3:ℝ)≤8*(2*(Q:ℝ)+1) by linarith)
    linarith
  have hbudget : (2*(p:ℝ)+(m:ℝ))*(2*(Q:ℝ))≤a := by
    dsimp [a]
    nlinarith [mul_nonneg (show 0≤(p:ℝ) by positivity) hD0.le]
  have hlower : 0<a-(m:ℝ)/2 := by
    have ht : (m:ℝ)/2<(2*(Q:ℝ)+1)*(m:ℝ)*(2*(Q:ℝ)) := by
      nlinarith [mul_pos hm0 hD0,mul_nonneg hm0.le (show 0≤(Q:ℝ)-1 by linarith)]
    exact sub_pos.mpr ht
  have hh := weighted_badGram_power_probability w hw hmass v hiso
    (by positivity : 0≤2*(Q:ℝ)) ha hv p m hc hbudget hlower
  have heb : a-(m:ℝ)/2=a*(1-1/(4*(Q:ℝ)*(2*(Q:ℝ)+1))) := by
    dsimp [a]
    field_simp
    <;> ring
  have hx : 0<1-1/(4*(Q:ℝ)*(2*(Q:ℝ)+1)) := by
    rw [heb] at hlower
    exact (mul_pos_iff_of_pos_left ha).mp hlower
  rw [hec,hp,heb,mul_pow a (1-1/(4*(Q:ℝ)*(2*(Q:ℝ)+1)))] at hh
  have her : (1-3/(8*(2*(Q:ℝ)+1)))^m*((D:ℝ)*a^(m*Q))/
      (a^(m*Q)*(1-1/(4*(Q:ℝ)*(2*(Q:ℝ)+1)))^(m*Q))=
      (D:ℝ)*((1-3/(8*(2*(Q:ℝ)+1)))^m/(1-1/(4*(Q:ℝ)*(2*(Q:ℝ)+1)))^(m*Q)) := by
    field_simp
  rw [her] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left
    (gram_power_ratio_exp hD1 m (m*Q) (by push_cast; rfl)) (Nat.cast_nonneg D))

theorem weighted_badGram_exponential (w : α→ℝ) (hw : ∀x,0≤w x)
    (hmass : ∑x,w x=1) {D m : ℕ} (hm : 0<m) (v : α→Fin D→ℝ)
    (hiso : Isotropic w v) (hv : ∀x,(∑i,v x i^2)≤2*(D:ℝ)) :
    mean (iidWeight w m) (fun s=>if badGram v s then (1:ℝ) else 0)≤
      (D:ℝ)*Real.exp (-(m:ℝ)/(16*((D:ℝ)+1))) := by
  by_cases hD : D=0
  · subst D
    have hb (s : Fin m→α) : ¬badGram v s := by
      rintro ⟨u,hu,_⟩
      simpa using hu
    simp [hb,mean]
  have hD1 : (1:ℝ)≤D := by exact_mod_cast Nat.one_le_iff_ne_zero.mpr hD
  have hD0 : (0:ℝ)<D := by positivity
  have hm0 : (0:ℝ)<m := Nat.cast_pos.mpr hm
  let p := m*D-1
  let a : ℝ := (2*(D:ℝ)+1)*(m:ℝ)*(2*(D:ℝ))
  have hp : p+1=m*D := by dsimp [p]; have := Nat.mul_pos hm (Nat.pos_of_ne_zero hD); omega
  have hpR : (p:ℝ)+1=(m:ℝ)*(D:ℝ) := by exact_mod_cast hp
  have ha : 0<a := by dsimp [a]; positivity
  have hec : 1-3*((p:ℝ)+1)/(4*a)=1-3/(8*(2*(D:ℝ)+1)) := by
    rw [hpR]
    dsimp [a]
    field_simp
    <;> ring
  have hc : 0≤1-3*((p:ℝ)+1)/(4*a) := by
    rw [hec]
    have := (div_le_one (by positivity : 0<8*(2*(D:ℝ)+1))).mpr
      (show (3:ℝ)≤8*(2*(D:ℝ)+1) by linarith)
    linarith
  have hbudget : (2*(p:ℝ)+(m:ℝ))*(2*(D:ℝ))≤a := by
    dsimp [a]
    nlinarith [mul_nonneg (show 0≤(p:ℝ) by positivity) hD0.le]
  have hlower : 0<a-(m:ℝ)/2 := by
    have ht : (m:ℝ)/2<(2*(D:ℝ)+1)*(m:ℝ)*(2*(D:ℝ)) := by
      nlinarith [mul_pos hm0 hD0,mul_nonneg hm0.le (show 0≤(D:ℝ)-1 by linarith)]
    exact sub_pos.mpr ht
  have hh := weighted_badGram_power_probability w hw hmass v hiso
    (by positivity : 0≤2*(D:ℝ)) ha hv p m hc hbudget hlower
  have heb : a-(m:ℝ)/2=a*(1-1/(4*(D:ℝ)*(2*(D:ℝ)+1))) := by
    dsimp [a]
    field_simp
    <;> ring
  have hx : 0<1-1/(4*(D:ℝ)*(2*(D:ℝ)+1)) := by
    rw [heb] at hlower
    exact (mul_pos_iff_of_pos_left ha).mp hlower
  rw [hec,hp,heb,mul_pow a (1-1/(4*(D:ℝ)*(2*(D:ℝ)+1)))] at hh
  have her : (1-3/(8*(2*(D:ℝ)+1)))^m*((D:ℝ)*a^(m*D))/
      (a^(m*D)*(1-1/(4*(D:ℝ)*(2*(D:ℝ)+1)))^(m*D))=
      (D:ℝ)*((1-3/(8*(2*(D:ℝ)+1)))^m/(1-1/(4*(D:ℝ)*(2*(D:ℝ)+1)))^(m*D)) := by
    field_simp
  rw [her] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left
    (gram_power_ratio_exp hD1 m (m*D) (by push_cast; rfl)) (Nat.cast_nonneg D))

end NeuralGeneralization.BatchTwoGramPower
