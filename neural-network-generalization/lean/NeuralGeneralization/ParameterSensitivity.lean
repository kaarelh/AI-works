import NeuralGeneralization.ParameterSensitivityTools
import NeuralGeneralization.CylinderStability
import NeuralGeneralization.NetworkGramBasics

/-! The literal width-independent parameter sensitivity factor in the
strong-prior manuscript, with the weighted Euclidean parameter norm. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.ParameterSensitivity
open ConcreteModel Compression CompressionSampling

def coefficient (R S : ℝ) : ℕ→ℝ
  | 0 => S
  | n+1 => R^2*coefficient R S n+1

theorem coefficient_nonneg (R : ℝ) {S : ℝ} (hS : 0≤S) (n : ℕ) : 0≤coefficient R S n := by
  induction n with
  | zero => exact hS
  | succ n ih => simp only [coefficient]; positivity

def firstDifference {d N r : ℕ} (w v : Weights d N r) : ℝ :=
  (d:ℝ)/N*(∑ i,∑ j,(w (.inl (i,j))-v (.inl (i,j)))^2)

def internalDifference {d N r : ℕ} (w v : Weights d N r) (s : Fin r) : ℝ :=
  ∑ i,∑ j,(w (.inr (.inl (s,i,j)))-v (.inr (.inl (s,i,j))))^2

def readoutDifference {d N r : ℕ} (w v : Weights d N r) : ℝ :=
  (N:ℝ)*(∑ i,(w (.inr (.inr i))-v (.inr (.inr i)))^2)

theorem first_difference_bound {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r) (x : Cube d) :
    squaredDistance (firstHidden φ w x) (firstHidden φ v x)≤
      (N:ℝ)*(((d:ℝ)+1)/d)*firstDifference w v := by
  have ha := square_activation_difference φ hφ.2
    (fun i => ∑ j,w (.inl (i,j))*inputVector x j)
    (fun i => ∑ j,v (.inl (i,j))*inputVector x j)
  have hm := matrix_sum_sq_le (fun i j => w (.inl (i,j))-v (.inl (i,j))) (inputVector x)
  have he (i : Fin N) : (∑ j,w (.inl (i,j))*inputVector x j)-(∑ j,v (.inl (i,j))*inputVector x j)=
      ∑ j,(w (.inl (i,j))-v (.inl (i,j)))*inputVector x j := by simp [sub_mul,Finset.sum_sub_distrib]
  simp_rw [he] at ha
  rw [NetworkGramBasics.inputVector_square_sum] at hm
  apply ha.trans
  apply hm.trans_eq
  unfold firstDifference
  have hd0 : (d:ℝ)≠0 := by exact_mod_cast hd.ne'
  have hN0 : (N:ℝ)≠0 := by exact_mod_cast hN.ne'
  field_simp
  <;> ring

theorem hidden_difference_bound {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r) {R : ℝ}
    (hw : weightedSquaredNorm w≤R^2) (ss : List (Fin r)) (x : Cube d) :
    squaredDistance (ss.foldl (hiddenStep φ w) (firstHidden φ w x))
      (ss.foldl (hiddenStep φ v) (firstHidden φ v x))≤
      (N:ℝ)*coefficient R (((d:ℝ)+1)/d) ss.length*
        (firstDifference w v+(ss.map (internalDifference w v)).sum) := by
  induction ss using List.reverseRecOn with
  | nil => simpa [coefficient] using first_difference_bound hd hN φ hφ w v x
  | append_singleton ss s ih =>
    have hS := coefficient_nonneg R (show 0≤((d:ℝ)+1)/d by positivity) ss.length
    have he : 0≤firstDifference w v+(ss.map (internalDifference w v)).sum := by
      unfold firstDifference
      apply add_nonneg (by positivity)
      exact List.sum_nonneg fun z hz => by
        obtain ⟨t,_,rfl⟩ := List.mem_map.mp hz
        unfold internalDifference
        positivity
    have hh := layer_change_sq φ hφ
      (fun i j => w (.inr (.inl (s,i,j)))) (fun i j => v (.inr (.inl (s,i,j)))) _ _
      hS he ((internal_squaredNorm_le_cost w s).trans hw)
      (fun i => hiddenFold_bounded φ hφ v ss x i) ih
    change squaredDistance
      (hiddenStep φ w (ss.foldl (hiddenStep φ w) (firstHidden φ w x)) s)
      (hiddenStep φ v (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) s)≤_ at hh
    simpa only [List.foldl_append,List.foldl_cons,List.foldl_nil,List.length_append,
      List.length_singleton,List.map_append,List.map_singleton,List.sum_append,List.sum_singleton,
      coefficient,add_assoc,internalDifference,Compression.layer,ConcreteModel.hiddenStep] using hh

theorem bounded_sum_sq {N : ℕ} (h : Fin N→ℝ) (hh : ∀ i,|h i|≤1) : (∑ i,h i^2)≤(N:ℝ) := by
  calc
    _ ≤ ∑ _i : Fin N,(1:ℝ) := Finset.sum_le_sum fun i _ => by
      simpa only [sq_abs,one_pow] using (sq_le_sq₀ (abs_nonneg _) zero_le_one).mpr (hh i)
    _ = _ := by simp

theorem output_difference_bound {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (w v : Weights d N r) {R : ℝ}
    (hw : weightedSquaredNorm w≤R^2) (x : Cube d) :
    (networkOutput φ w x-networkOutput φ v x)^2≤
      coefficient R (((d:ℝ)+1)/d) (r+1)*weightedSquaredNorm (w-v) := by
  let S := coefficient R (((d:ℝ)+1)/d) r
  let e := firstDifference w v+∑ s,internalDifference w v s
  let h := finalHidden φ w x
  let h' := finalHidden φ v x
  let a : ℝ := ∑ i,w (.inr (.inr i))*(h i-h' i)
  let b : ℝ := ∑ i,(w (.inr (.inr i))-v (.inr (.inr i)))*h' i
  have hS : 0≤S := coefficient_nonneg R (by positivity) r
  have he : 0≤e := by dsimp [e,firstDifference,internalDifference]; positivity
  have hh : squaredDistance h h'≤(N:ℝ)*S*e := by
    simpa only [S,e,h,h',ConcreteModel.finalHidden,List.length_finRange,← Fin.sum_univ_def] using hidden_difference_bound hd hN φ hφ w v hw (List.finRange r) x
  have hnorm := bounded_sum_sq h' (fun i => hiddenFold_bounded φ hφ v (List.finRange r) x i)
  have ha : a^2≤R^2*S*e := by
    have hcs := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ) (fun i => w (.inr (.inr i))) (fun i => h i-h' i)
    have hm := mul_le_mul (output_squaredNorm_le_of_cost hN w hw) hh
      (show 0≤squaredDistance h h' by unfold squaredDistance; positivity) (by positivity : 0≤R^2/(N:ℝ))
    apply hcs.trans
    apply hm.trans_eq
    have hN0 : (N:ℝ)≠0 := by exact_mod_cast hN.ne'
    field_simp
  have hb : b^2≤readoutDifference w v := by
    have hcs := Finset.sum_mul_sq_le_sq_mul_sq (s:=Finset.univ)
      (fun i => w (.inr (.inr i))-v (.inr (.inr i))) h'
    have hm := mul_le_mul_of_nonneg_left hnorm (show 0≤∑ i,(w (.inr (.inr i))-v (.inr (.inr i)))^2 by positivity)
    exact hcs.trans (by simpa [readoutDifference,mul_comm] using hm)
  have hs := sum_sq_add_le (fun _ : Fin 1 => a) (fun _ : Fin 1 => b)
    (a:=R^2*S) (b:=e) (c:=1) (d:=readoutDifference w v)
    (by positivity) he zero_le_one (by unfold readoutDifference; positivity)
    (by simpa using ha) (by simpa using hb)
  have hdiff : networkOutput φ w x-networkOutput φ v x=a+b := by
    simp only [networkOutput,a,b,h,h',mul_sub,sub_mul,Finset.sum_sub_distrib]
    ring
  have hcost : e+readoutDifference w v=weightedSquaredNorm (w-v) := by
    simp only [e,firstDifference,internalDifference,readoutDifference,weightedSquaredNorm,Pi.sub_apply]
  rw [hdiff]
  simpa only [Fin.sum_univ_one,coefficient,← hcost] using hs

end NeuralGeneralization.ParameterSensitivity
