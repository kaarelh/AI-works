import NeuralGeneralization.PrunedNetwork

/-! Sharp two-block Cauchy bounds for parameter sensitivity. No factor two
is lost when a layer and its input are changed simultaneously. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.ParameterSensitivity
open ConcreteModel Compression

 theorem sum_sq_add_le {I : Type*} [Fintype I] (u v : I→ℝ) {a b c d : ℝ}
    (ha : 0≤a) (hb : 0≤b) (hc : 0≤c) (hd : 0≤d)
    (hu : ∑ i,u i^2≤a*b) (hv : ∑ i,v i^2≤c*d) :
    (∑ i,(u i+v i)^2)≤(a+c)*(b+d) := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ) u v
  have hprod := mul_le_mul hu hv (Finset.sum_nonneg fun i _ => sq_nonneg (v i)) (mul_nonneg ha hb)
  have hcross : 2*(∑ i,u i*v i)≤a*d+c*b := by
    have h0 : 0≤a*d+c*b := add_nonneg (mul_nonneg ha hd) (mul_nonneg hc hb)
    nlinarith [sq_nonneg (a*d-c*b)]
  have he : (∑ i,(u i+v i)^2)=(∑ i,u i^2)+2*(∑ i,u i*v i)+(∑ i,v i^2) := by
    simp only [Finset.mul_sum,← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [he]
  nlinarith

theorem matrix_sum_sq_le {I J : Type*} [Fintype I] [Fintype J]
    (A : I→J→ℝ) (x : J→ℝ) :
    (∑ i,(∑ j,A i j*x j)^2)≤(∑ i,∑ j,A i j^2)*(∑ j,x j^2) := by
  rw [Finset.sum_mul]
  exact Finset.sum_le_sum fun i _ => Finset.sum_mul_sq_le_sq_mul_sq _ _ _

theorem square_activation_difference {I : Type*} [Fintype I] (φ : ℝ→ℝ)
    (hφ : ∀ x y,|φ x-φ y|≤|x-y|) (u v : I→ℝ) :
    (∑ i,(φ (u i)-φ (v i))^2)≤∑ i,(u i-v i)^2 := by
  apply Finset.sum_le_sum
  intro i _
  simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) (abs_nonneg _)).mpr (hφ (u i) (v i))

theorem layer_change_sq {N : ℕ} (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (A B : Fin N→Fin N→ℝ) (h h' : Fin N→ℝ) {R S e : ℝ}
    (hS : 0≤S) (he : 0≤e) (hA : ∑ i,∑ j,A i j^2≤R^2)
    (hh' : ∀ j,|h' j|≤1)
    (hh : squaredDistance h h'≤(N:ℝ)*S*e) :
    squaredDistance (layer φ A h) (layer φ B h')≤
      (N:ℝ)*(R^2*S+1)*(e+∑ i,∑ j,(A i j-B i j)^2) := by
  let u : Fin N→ℝ := fun i => ∑ j,A i j*(h j-h' j)
  let v : Fin N→ℝ := fun i => ∑ j,(A i j-B i j)*h' j
  have hnorm : (∑ j,h' j^2)≤(N:ℝ) := by
    calc
      _ ≤ ∑ _j : Fin N,(1:ℝ) := Finset.sum_le_sum fun j _ => by
        have h := hh' j
        have hs := (sq_le_sq₀ (abs_nonneg _) (by norm_num : (0:ℝ)≤1)).mpr h
        simpa using hs
      _ = _ := by simp
  have hu : (∑ i,u i^2)≤((N:ℝ)*R^2*S)*e := by
    have hm := matrix_sum_sq_le A (fun j => h j-h' j)
    have hp := mul_le_mul hA hh (show 0≤squaredDistance h h' by unfold squaredDistance; positivity) (sq_nonneg R)
    dsimp only [squaredDistance] at hp
    exact hm.trans (by convert hp using 1 <;> ring)
  have hv : (∑ i,v i^2)≤(N:ℝ)*(∑ i,∑ j,(A i j-B i j)^2) := by
    have hm := matrix_sum_sq_le (fun i j => A i j-B i j) h'
    have hp := mul_le_mul_of_nonneg_left hnorm
      (show 0≤∑ i,∑ j,(A i j-B i j)^2 by positivity)
    exact hm.trans (by simpa [mul_comm] using hp)
  have hs := sum_sq_add_le u v (a:=(N:ℝ)*R^2*S) (b:=e) (c:=(N:ℝ))
    (d:=∑ i,∑ j,(A i j-B i j)^2) (by positivity) he (Nat.cast_nonneg N) (by positivity) hu hv
  have ha := square_activation_difference φ hφ.2 (fun i => ∑ j,A i j*h j) (fun i => ∑ j,B i j*h' j)
  have hx (i : Fin N) : (∑ j,A i j*h j)-(∑ j,B i j*h' j)=u i+v i := by
    simp only [u,v,mul_sub,sub_mul,Finset.sum_sub_distrib]
    ring
  simp_rw [hx] at ha
  apply ha.trans
  exact hs.trans_eq (by ring)

end NeuralGeneralization.ParameterSensitivity
