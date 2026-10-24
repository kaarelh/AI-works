import NeuralGeneralization.BatchTwoMergingSharpTeacher

/-! Unsquared Euclidean estimates used by the explicit cylinder radius. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel Compression WithLp

abbrev coordinateNorm {I : Type*} [Fintype I] (u : I→ℝ) : ℝ := ‖toLp 2 u‖

theorem coordinateNorm_sq {I : Type*} [Fintype I] (u : I→ℝ) :
    coordinateNorm u^2=∑i,u i^2 := EuclideanSpace.real_norm_sq_eq _

theorem coordinateNorm_add {I : Type*} [Fintype I] (u v : I→ℝ) :
    coordinateNorm (fun i=>u i+v i)≤coordinateNorm u+coordinateNorm v := by
  exact norm_add_le (toLp 2 u) (toLp 2 v)

theorem coordinateNorm_bound {I : Type*} [Fintype I] {u:I→ℝ} {B:ℝ}
    (hB : 0≤B) (hu : (∑i,u i^2)≤B^2) : coordinateNorm u≤B := by
  apply (sq_le_sq₀ (norm_nonneg _) hB).mp
  rwa [coordinateNorm_sq]

theorem coordinateNorm_of_pointwise {I : Type*} [Fintype I] (u:I→ℝ) {a:ℝ}
    (ha : 0≤a) (hu : ∀i,|u i|≤a) :
    coordinateNorm u≤Real.sqrt (Fintype.card I:ℝ)*a := by
  apply coordinateNorm_bound (by positivity)
  calc
    _ ≤ ∑_i:I,a^2 := Finset.sum_le_sum fun i _=>by
      simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg _) ha).mpr (hu i)
    _ = _ := by simp [mul_pow,Real.sq_sqrt (Nat.cast_nonneg (Fintype.card I))]

theorem matrixActionBound_coordinateNorm {N : ℕ} (A : Fin N→Fin N→ℝ) {B:ℝ}
    (hB : 0≤B) (hA : matrixActionBound A B) (u:Fin N→ℝ) :
    coordinateNorm (fun i=>∑j,A i j*u j)≤B*coordinateNorm u := by
  apply coordinateNorm_bound (by positivity)
  rw [mul_pow,coordinateNorm_sq]
  exact hA u

theorem frobenius_coordinateNorm {N : ℕ} (A : Fin N→Fin N→ℝ) {K:ℝ}
    (hK : 0≤K) (hA : (∑i,∑j,A i j^2)≤K) (u:Fin N→ℝ) :
    coordinateNorm (fun i=>∑j,A i j*u j)≤Real.sqrt K*coordinateNorm u := by
  apply coordinateNorm_bound (by positivity)
  rw [mul_pow,Real.sq_sqrt hK,coordinateNorm_sq]
  exact (matrix_action_squaredSum_le A u).trans
    (mul_le_mul_of_nonneg_right hA (Finset.sum_nonneg fun _ _=>sq_nonneg _))

theorem activation_coordinateNorm_difference {I : Type*} [Fintype I]
    (φ:ℝ→ℝ) {a:ℝ} (ha : 0≤a)
    (hφ : ∀u v,|φ u-φ v|≤a*|u-v|) (u v:I→ℝ) :
    coordinateNorm (fun i=>φ (u i)-φ (v i))≤a*coordinateNorm (fun i=>u i-v i) := by
  apply coordinateNorm_bound (by positivity)
  rw [mul_pow,coordinateNorm_sq,Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have hh := (sq_le_sq₀ (abs_nonneg _) (by positivity : 0≤a*|u i-v i|)).mpr (hφ (u i) (v i))
  simpa only [sq_abs,mul_pow] using hh

theorem sharp_cylinder_hiddenStep {d N r : ℕ} (φ:ℝ→ℝ) {a K G B ρ:ℝ}
    (ha : 0≤a) (hφ : ∀u v,|φ u-φ v|≤a*|u-v|)
    (hK : 0≤K) (hG : 0≤G) (hB : 0≤B) (hρ : 0≤ρ)
    (w v : Weights d N r) (R E : Fin r→Fin N→Fin N→ℝ)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : ∀s,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤K)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*G)
    (hE : ∀s,matrixActionBound (E s) B)
    (u z : Fin N→ℝ) (hz : ∀i,|z i|≤1)
    (hkill : ∀s i,(∑j,E s i j*z j)=0) (s:Fin r) :
    coordinateNorm (fun i=>hiddenStep φ w u s i-hiddenStep φ v z s i)≤
      a*((Real.sqrt K+B+ρ*Real.sqrt G)*coordinateNorm (fun i=>u i-z i)+
        ρ*Real.sqrt G*Real.sqrt (N:ℝ)) := by
  let du := fun i=>u i-z i
  let t := fun i=>∑j,v (Sum.inr (Sum.inl (s,i,j)))*du j
  let e := fun i=>∑j,E s i j*du j
  let rd := fun i=>∑j,R s i j*du j
  let rz := fun i=>∑j,R s i j*z j
  have hdiff : (fun i=>(∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)-
      (∑j,v (Sum.inr (Sum.inl (s,i,j)))*z j))=fun i=>t i+e i+rd i+rz i := by
    funext i
    dsimp [t,e,rd,rz,du]
    simp_rw [hdecomp,add_mul,mul_sub]
    simp only [Finset.sum_add_distrib,Finset.sum_sub_distrib,hkill s i]
    ring
  have ht := frobenius_coordinateNorm (fun i j=>v (Sum.inr (Sum.inl (s,i,j)))) hK (hv s) du
  have he := matrixActionBound_coordinateNorm (E s) hB (hE s) du
  have hrad : Real.sqrt (ρ^2*G)=ρ*Real.sqrt G := by
    rw [Real.sqrt_mul (sq_nonneg ρ),Real.sqrt_sq hρ]
  have hr := frobenius_coordinateNorm (R s) (mul_nonneg (sq_nonneg ρ) hG) (hR s) du
  have hrz := frobenius_coordinateNorm (R s) (mul_nonneg (sq_nonneg ρ) hG) (hR s) z
  rw [hrad] at hr hrz
  have hzN : coordinateNorm z≤Real.sqrt (N:ℝ) := by
    simpa only [Fintype.card_fin,mul_one] using coordinateNorm_of_pointwise z zero_le_one hz
  have hsum : coordinateNorm (fun i=>t i+e i+rd i+rz i)≤
      coordinateNorm t+coordinateNorm e+coordinateNorm rd+coordinateNorm rz := by
    have h1 := coordinateNorm_add (fun i=>t i+e i+rd i) rz
    have h2 := coordinateNorm_add (fun i=>t i+e i) rd
    have h3 := coordinateNorm_add t e
    linarith
  have hbound : coordinateNorm (fun i=>t i+e i+rd i+rz i)≤
      (Real.sqrt K+B+ρ*Real.sqrt G)*coordinateNorm du+ρ*Real.sqrt G*Real.sqrt (N:ℝ) := by
    have hh := mul_le_mul_of_nonneg_left hzN (mul_nonneg hρ (Real.sqrt_nonneg G))
    change coordinateNorm t≤_ at ht
    change coordinateNorm e≤_ at he
    change coordinateNorm rd≤_ at hr
    change coordinateNorm rz≤_ at hrz
    nlinarith
  have hh := activation_coordinateNorm_difference φ ha hφ
    (fun i=>∑j,w (Sum.inr (Sum.inl (s,i,j)))*u j)
    (fun i=>∑j,v (Sum.inr (Sum.inl (s,i,j)))*z j)
  rw [hdiff] at hh
  exact hh.trans (mul_le_mul_of_nonneg_left hbound ha)

end NeuralGeneralization.BatchTwoMerging
