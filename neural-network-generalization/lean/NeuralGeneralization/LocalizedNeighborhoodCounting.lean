import NeuralGeneralization.LocalizedEllipsoidCounting
import NeuralGeneralization.RobustInputNeighborhood

/-! The exact first-layer semimetric used by the input-neighborhood theorem
has the ellipsoidal exception-family bound, even when every network, width,
center and radius is chosen separately. -/
noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel RobustCertificates
open BatchTwoContinuous (RealInput augmentedInput)

lemma network_ellipsoid_eq {d N r : ℕ} (w : Weights d N r) (center : RealInput d) (x : Cube d) :
    ellipsoidDistanceSq (fun i j => w (.inl (i,j))) (augmentedInput center) x =
      ∑ i,(∑ j,w (.inl (i,j.succ))*(labelReal (x j)-center j))^2 := by
  simp only [ellipsoidDistanceSq,Fin.sum_univ_succ,inputVector,augmentedInput,
    Fin.cases_zero,Fin.cases_succ,sub_self,mul_zero,zero_add]

lemma network_neighborhood_exterior_iff {d N r : ℕ} (hN : 0 < N)
    (w : Weights d N r) (center : RealInput d) (x : Cube d)
    {R : ℝ} (hR : 0 ≤ R) :
    R < inputDistance w (fun j => labelReal (x j)) center ↔
      (N:ℝ)*R^2 < ellipsoidDistanceSq (fun i j => w (.inl (i,j))) (augmentedInput center) x := by
  rw [inputDistance,network_ellipsoid_eq]
  rw [Real.lt_sqrt hR]
  rw [lt_div_iff₀ (by positivity : (0:ℝ)<N)]
  rw [mul_comm (R^2)]

/-- Complements of unions of actual certified input neighborhoods all lie in
one family fixed by d and the number of slots, independent of widths. -/
theorem network_neighborhood_union_exception_mem {d k : ℕ} (N r : Fin k → ℕ)
    (hN : ∀ i,0 < N i) (w : ∀ i,Weights d (N i) (r i))
    (centers : Fin k → RealInput d) (R : Fin k → ℝ) (hR : ∀ i,0 ≤ R i)
    (active : Fin k → Bool) :
    (Finset.univ.filter fun x : Cube d =>
      ∀ i,active i=true → R i < inputDistance (w i) (fun j => labelReal (x j)) (centers i)) ∈
        ellipsoidExceptionFamily d k := by
  have hh := ellipsoid_union_exception_mem N (fun i a b => w i (.inl (a,b)))
    (fun i => augmentedInput (centers i)) (fun i => (N i:ℝ)*(R i)^2) active
  have he : (Finset.univ.filter fun x : Cube d =>
      ∀ i,active i=true → R i < inputDistance (w i) (fun j => labelReal (x j)) (centers i)) =
      (Finset.univ.filter fun x : Cube d => ∀ i,active i=true →
        (N i:ℝ)*(R i)^2 < ellipsoidDistanceSq (fun a b => w i (.inl (a,b))) (augmentedInput (centers i)) x) := by
    ext x
    simp only [Finset.mem_filter,Finset.mem_univ,true_and]
    exact forall_congr' fun i => imp_congr_right fun _ => network_neighborhood_exterior_iff (hN i) (w i) (centers i) x (hR i)
  rwa [he]

end NeuralGeneralization.RobustLocalized
