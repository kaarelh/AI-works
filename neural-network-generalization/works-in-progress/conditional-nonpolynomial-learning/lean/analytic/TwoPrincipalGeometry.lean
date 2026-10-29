import NetworkBallCover
import Mathlib.Analysis.InnerProductSpace.PiL2

noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch

theorem weighted_two_principal_bound {I : Type*} [Fintype I] [DecidableEq I]
    (w v : I→ℝ) (i : I) (B : ℝ) (hL : 0<w i) (hB : 0≤B)
    (hBL : B≤w i) (hother : ∀j,j≠i→w j≤B)
    (hv : ∑j,v j^2≤1) :
    (∑j,w j*v j^2)-2*((w i-B)/(2*w i))*w i*|v i|+
      ((w i-B)/(2*w i))^2*w i≤(w i+B)/2 := by
  let k := (w i-B)/(2*w i)
  have hk : 2*w i*k=w i-B := by dsimp [k]; field_simp
  have hj2 : v i^2≤1 :=
    (Finset.single_le_sum (fun j _=>sq_nonneg (v j)) (Finset.mem_univ i)).trans hv
  have ht1 : |v i|≤1 := by nlinarith [sq_abs (v i),abs_nonneg (v i)]
  have htail : (∑j∈Finset.univ.erase i,w j*v j^2)≤B*(1-v i^2) := by
    calc
      _ ≤ ∑j∈Finset.univ.erase i,B*v j^2 := by
        apply Finset.sum_le_sum
        intro j hj
        exact mul_le_mul_of_nonneg_right (hother j (Finset.mem_erase.mp hj).1) (sq_nonneg _)
      _ = B*(∑j∈Finset.univ.erase i,v j^2) := by rw [Finset.mul_sum]
      _ ≤ _ := by
        apply mul_le_mul_of_nonneg_left _ hB
        have hh := Finset.sum_erase_add Finset.univ (fun j=>v j^2) (Finset.mem_univ i)
        linarith
  have hfull := Finset.sum_erase_add Finset.univ (fun j=>w j*v j^2) (Finset.mem_univ i)
  have hend := weighted_endpoint_bound (w i) B k |v i| hL hB hBL (abs_nonneg _) ht1 hk
  rw [sq_abs] at hend
  change _-2*k*w i*|v i|+k^2*w i≤_
  nlinarith

theorem weighted_shift_axis {I : Type*} [Fintype I] [DecidableEq I]
    (w v : I→ℝ) (i : I) (k : ℝ) :
    (∑j,w j*(v j-(if j=i then k else 0))^2)=
      (∑j,w j*v j^2)-2*k*w i*v i+k^2*w i := by
  have he (j:I) : w j*(v j-(if j=i then k else 0))^2=
      w j*v j^2+(if j=i then -2*k*w i*v i+k^2*w i else 0) := by
    split_ifs with h
    · subst j; ring
    · ring
  simp_rw [he]
  rw [Finset.sum_add_distrib]
  simp
  ring

theorem two_principal_unit_metric_cover
    {I E F : Type*} [Fintype I] [DecidableEq I]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E] [PseudoMetricSpace F]
    (b : OrthonormalBasis I ℝ E) (w : I→ℝ) (i:I) (B:ℝ)
    (hL : 0<w i) (hB : 0≤B) (hBL : B≤w i)
    (hother : ∀j,j≠i→w j≤B) (f:E→F)
    (hf : ∀x y,dist (f x) (f y)^2≤∑j,w j*(b.repr (x-y) j)^2) :
    ∃c:E, ‖c‖≤1 ∧ ∀x:E,‖x‖≤1→
      dist (f x) (f c)≤Real.sqrt ((w i+B)/2) ∨
      dist (f x) (f (-c))≤Real.sqrt ((w i+B)/2) := by
  let k := (w i-B)/(2*w i)
  have hk0 : 0≤k := div_nonneg (sub_nonneg.mpr hBL) (by positivity)
  have hk1 : k≤1 := (div_le_one (by positivity)).mpr (by linarith)
  let c := k • b i
  have hc : ‖c‖≤1 := by
    dsimp [c]
    rw [norm_smul,Real.norm_eq_abs,abs_of_nonneg hk0,OrthonormalBasis.norm_eq_one,mul_one]
    exact hk1
  refine ⟨c,hc,fun x hx=>?_⟩
  have hv : ∑j,(b.repr x j)^2≤1 := by
    have he : ∑j,(b.repr x j)^2=‖x‖^2 := by
      simp_rw [b.repr_apply_apply]
      exact b.sum_sq_inner_right x
    rw [he]
    nlinarith [norm_nonneg x]
  have hw := weighted_two_principal_bound w (fun j=>b.repr x j) i B hL hB hBL hother hv
  have hrepr (j:I) : b.repr c j=if j=i then k else 0 := by
    dsimp [c]
    rw [b.repr_apply_apply,real_inner_smul_right,b.inner_eq_ite]
    split_ifs <;> simp_all
  have hs : ∑j,w j*(b.repr (x-c) j)^2=
      (∑j,w j*(b.repr x j)^2)-2*k*w i*(b.repr x i)+k^2*w i := by
    simp only [map_sub,PiLp.sub_apply,hrepr]
    exact weighted_shift_axis w _ i k
  have hp : ∑j,w j*(b.repr (x-(-c)) j)^2=
      (∑j,w j*(b.repr x j)^2)+2*k*w i*(b.repr x i)+k^2*w i := by
    simp only [map_sub,map_neg,PiLp.sub_apply,PiLp.neg_apply,hrepr]
    have hh := weighted_shift_axis w (fun j=>b.repr x j) i (-k)
    have hneg (j:I) : (if j=i then -k else 0)= -(if j=i then k else 0) := by split_ifs <;> simp
    simp_rw [hneg] at hh
    convert hh using 1 <;> ring
  have hr : 0≤(w i+B)/2 := by positivity
  by_cases hsign : 0≤b.repr x i
  · left
    have hh := hf x c
    rw [hs] at hh
    rw [abs_of_nonneg hsign] at hw
    apply (sq_le_sq₀ (dist_nonneg) (Real.sqrt_nonneg _)).mp
    rw [Real.sq_sqrt hr]
    exact hh.trans hw
  · right
    have hh := hf x (-c)
    rw [hp] at hh
    rw [abs_of_neg (lt_of_not_ge hsign)] at hw
    apply (sq_le_sq₀ (dist_nonneg) (Real.sqrt_nonneg _)).mp
    rw [Real.sq_sqrt hr]
    dsimp [k] at hh
    nlinarith

theorem two_principal_ball_metric_cover
    {I E F : Type*} [Fintype I] [DecidableEq I]
    [NormedAddCommGroup E] [InnerProductSpace ℝ E] [PseudoMetricSpace F]
    (b : OrthonormalBasis I ℝ E) (w : I→ℝ) (i:I) (B:ℝ)
    (hL : 0<w i) (hB : 0≤B) (hBL : B≤w i)
    (hother : ∀j,j≠i→w j≤B) (f:E→F)
    (hf : ∀x y,dist (f x) (f y)^2≤∑j,w j*(b.repr (x-y) j)^2)
    (z:E) (r:ℝ) (hr : 0≤r) :
    FiniteBallCover (f '' Metric.closedBall z r) 2
      (r*Real.sqrt ((w i+B)/2)) := by
  classical
  rcases hr.eq_or_lt with hr | hr
  · subst r
    refine ⟨{f z},by simp,?_⟩
    rintro y ⟨x,hx,rfl⟩
    have hxz : x=z := dist_le_zero.mp hx
    subst x
    exact ⟨f z,by simp,by simp⟩
  let g := fun x:E => f (z+r • x)
  have hg (x y:E) : dist (g x) (g y)^2≤
      ∑j,(r^2*w j)*(b.repr (x-y) j)^2 := by
    have hh := hf (z+r • x) (z+r • y)
    have he : z+r • x-(z+r • y)=r • (x-y) := by module
    rw [he] at hh
    simp only [map_smul,PiLp.smul_apply,smul_eq_mul,mul_pow] at hh
    convert hh using 1
    apply Finset.sum_congr rfl
    intro j _
    ring
  obtain ⟨c,hc,hcover⟩ := two_principal_unit_metric_cover b (fun j=>r^2*w j) i (r^2*B)
    (mul_pos (sq_pos_of_pos hr) hL) (mul_nonneg (sq_nonneg _) hB)
    (mul_le_mul_of_nonneg_left hBL (sq_nonneg _))
    (fun j hj=>mul_le_mul_of_nonneg_left (hother j hj) (sq_nonneg _)) g hg
  have hrad : Real.sqrt ((r^2*w i+r^2*B)/2)=r*Real.sqrt ((w i+B)/2) := by
    apply (sq_eq_sq₀ (Real.sqrt_nonneg _) (by positivity)).mp
    rw [mul_pow,Real.sq_sqrt (by positivity),Real.sq_sqrt (by positivity)]
    ring
  refine ⟨{g c,g (-c)},Finset.card_le_two,?_⟩
  rintro y ⟨x,hx,rfl⟩
  let u := r⁻¹ • (x-z)
  have hu : ‖u‖≤1 := by
    dsimp [u]
    rw [norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hr]
    exact (inv_mul_le_iff₀ hr).mpr (by simpa only [Metric.mem_closedBall,dist_eq_norm,mul_one] using hx)
  have hxu : g u=f x := by
    dsimp [g,u]
    congr 1
    rw [smul_smul,mul_inv_cancel₀ hr.ne',one_smul]
    abel
  rcases hcover u hu with hh | hh
  · rw [hxu,hrad] at hh
    exact ⟨g c,by simp,hh⟩
  · rw [hxu,hrad] at hh
    exact ⟨g (-c),by simp,hh⟩

#print axioms two_principal_unit_metric_cover
#print axioms two_principal_ball_metric_cover
end ConditionalNonpolynomial.Analytic
