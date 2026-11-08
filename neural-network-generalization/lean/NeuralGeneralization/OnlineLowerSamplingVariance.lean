import NeuralGeneralization.OnlineLowerSamplingMoments

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

theorem finiteAverage_square_shift {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (f:Ω→ℝ) (c:ℝ) :
    finiteAverage (fun ω=>(f ω-c)^2)=finiteAverage (fun ω=>f ω^2)-2*c*finiteAverage f+c^2 := by
  have he : (fun ω=>(f ω-c)^2)=(fun ω=>f ω^2-(2*c)*f ω+c^2) := by funext ω; ring
  rw [he,finiteAverage_add,finiteAverage_sub,finiteAverage_mul_left,finiteAverage_const]

theorem finiteAverage_square_ge {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (f:Ω→ℝ) : (finiteAverage f)^2≤finiteAverage (fun ω=>f ω^2) := by
  have h := finiteAverage_nonneg (fun ω=>(f ω-finiteAverage f)^2) (fun ω=>sq_nonneg _)
  rw [finiteAverage_square_shift] at h
  nlinarith

def scalarMean {p:ℕ} (z:Fin p→ℝ) : ℝ := (∑ i,z i)/p

def scalarSpread {p:ℕ} (z:Fin p→ℝ) : ℝ := ∑ i,(z i-scalarMean z)^2

theorem scalar_shift_identity {p:ℕ} (z:Fin p→ℝ) (c:ℝ) :
    (∑ i,(z i-c)^2)=(∑ i,z i^2)-2*c*(∑ i,z i)+(p:ℝ)*c^2 := by
  calc
    _ = ∑ i,(z i^2-(2*c)*z i+c^2) := by apply Finset.sum_congr rfl; intro i _; ring
    _ = _ := by
      rw [Finset.sum_add_distrib,Finset.sum_sub_distrib,←Finset.mul_sum]
      simp

theorem scalarSpread_eq {p:ℕ} (hp:0<p) (z:Fin p→ℝ) :
    scalarSpread z=(∑ i,z i^2)-(∑ i,z i)^2/(p:ℝ) := by
  have hn : (p:ℝ)≠0 := by exact_mod_cast hp.ne'
  rw [scalarSpread,scalar_shift_identity]
  unfold scalarMean
  field_simp
  ring

theorem scalarSpread_nonneg {p:ℕ} (z:Fin p→ℝ) : 0≤scalarSpread z :=
  Finset.sum_nonneg (fun i _=>sq_nonneg _)

theorem sum_square_le_card_sum_squares {p:ℕ} (hp:0<p) (z:Fin p→ℝ) :
    (∑ i,z i)^2≤(p:ℝ)*(∑ i,z i^2) := by
  have h := scalarSpread_nonneg z
  rw [scalarSpread_eq hp] at h
  have hn : (0:ℝ)<p := by exact_mod_cast hp
  have hh := mul_nonneg hn.le h
  field_simp at hh
  nlinarith

theorem independent_sum_square_average {Ω : Type*} [Fintype Ω]
    (p:ℕ) (Z:Ω→Fin p→ℝ)
    (hcross:∀ i j,i≠j→finiteAverage (fun ω=>Z ω i*Z ω j)=
      finiteAverage (fun ω=>Z ω i)*finiteAverage (fun ω=>Z ω j)) :
    finiteAverage (fun ω=>(∑ i,Z ω i)^2)=
      (∑ i,finiteAverage (fun ω=>Z ω i^2))-
      (∑ i,(finiteAverage (fun ω=>Z ω i))^2)+
      (∑ i,finiteAverage (fun ω=>Z ω i))^2 := by
  classical
  have he (ω:Ω) : (∑ i,Z ω i)^2=∑ i,∑ j,Z ω i*Z ω j := by
    rw [pow_two,Finset.sum_mul]
    simp_rw [Finset.mul_sum]
  have hc (i j:Fin p) : finiteAverage (fun ω=>Z ω i*Z ω j)=
      finiteAverage (fun ω=>Z ω i)*finiteAverage (fun ω=>Z ω j)+
      if i=j then finiteAverage (fun ω=>Z ω i^2)-(finiteAverage (fun ω=>Z ω i))^2 else 0 := by
    by_cases hij:i=j
    · subst j
      simp [pow_two]
    · simp [hij,hcross i j hij]
  simp_rw [he,finiteAverage_sum,hc,Finset.sum_add_distrib]
  simp only [Finset.sum_ite_eq,Finset.sum_ite_eq',Finset.mem_univ,if_true]
  rw [Finset.sum_sub_distrib]
  simp_rw [←Finset.mul_sum]
  rw [←Finset.sum_mul]
  ring

/-- Independence prevents a random common shift from hiding within-rail
variance. Two pairs suffice; the factor is uniform in the number of pairs. -/
theorem independent_centering_bound {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (p:ℕ) (hp:2≤p) (Z:Ω→Fin p→ℝ)
    (hcross:∀ i j,i≠j→finiteAverage (fun ω=>Z ω i*Z ω j)=
      finiteAverage (fun ω=>Z ω i)*finiteAverage (fun ω=>Z ω j)) :
    finiteAverage (fun ω=>∑ i,(Z ω i-scalarMean (fun j=>finiteAverage (fun ω=>Z ω j)))^2) ≤
      2*finiteAverage (fun ω=>scalarSpread (Z ω)) := by
  let μ : Fin p→ℝ := fun i=>finiteAverage (fun ω=>Z ω i)
  let A := ∑ i,finiteAverage (fun ω=>Z ω i^2)
  let B := ∑ i,(μ i)^2
  let C := (∑ i,μ i)^2
  have hp0 : 0<p := by omega
  have hn : (0:ℝ)<p := by exact_mod_cast hp0
  have hn2 : (2:ℝ)≤p := by exact_mod_cast hp
  have hBA : B≤A := Finset.sum_le_sum (fun i _=>finiteAverage_square_ge (fun ω=>Z ω i))
  have hCB : C≤(p:ℝ)*B := sum_square_le_card_sum_squares hp0 μ
  have hleft : finiteAverage (fun ω=>∑ i,(Z ω i-scalarMean μ)^2)=A-C/p := by
    rw [finiteAverage_sum]
    simp_rw [finiteAverage_square_shift]
    rw [Finset.sum_add_distrib,Finset.sum_sub_distrib,←Finset.mul_sum]
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
    dsimp [A,C,scalarMean,μ]
    field_simp
    ring
  have hright : finiteAverage (fun ω=>scalarSpread (Z ω))=A-(A-B+C)/p := by
    simp_rw [scalarSpread_eq hp0]
    rw [finiteAverage_sub,finiteAverage_sum]
    have hd (f:Ω→ℝ) : finiteAverage (fun ω=>f ω/(p:ℝ))=finiteAverage f/p := by
      simp [div_eq_mul_inv,finiteAverage_mul_right]
    rw [hd,independent_sum_square_average p Z hcross]
  change finiteAverage (fun ω=>∑ i,(Z ω i-scalarMean μ)^2)≤_
  rw [hleft,hright]
  refine le_of_mul_le_mul_right ?_ hn
  field_simp
  nlinarith [mul_nonneg (sub_nonneg.mpr hn2) (sub_nonneg.mpr hBA)]

end NeuralGeneralization.OnlineLowerRelu
