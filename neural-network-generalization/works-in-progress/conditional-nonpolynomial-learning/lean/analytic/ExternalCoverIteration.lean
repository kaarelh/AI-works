import AnalyticPrefixReduction
import ActualCoverIteration

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch

theorem external_cover_step {E F : Type*} [PseudoMetricSpace E] [PseudoMetricSpace F]
    (S:Set E) (f:E→F) (N M:ℕ) (r R:ℝ)
    (hc:FiniteBallCover S N r)
    (hstep:∀z:E,FiniteBallCover (f '' Metric.closedBall z r) M R) :
    FiniteBallCover (f '' S) (N*M) R := by
  classical
  obtain ⟨C,hcard,hcover⟩ := hc
  choose Y hYcard hY using hstep
  refine ⟨C.biUnion Y,?_,?_⟩
  · exact (Finset.card_biUnion_le_card_mul C Y M (fun z _=>hYcard z)).trans
      (Nat.mul_le_mul_right M hcard)
  · rintro v ⟨x,hx,rfl⟩
    obtain ⟨z,hz,hxz⟩ := hcover x hx
    obtain ⟨y,hy,hxy⟩ := hY z (f x) ⟨x,hxz,rfl⟩
    exact ⟨y,Finset.mem_biUnion.mpr ⟨z,hz,hy⟩,hxy⟩

theorem external_cover_iteration {E:ℕ→Type*} [∀j,PseudoMetricSpace (E j)]
    (S:∀j,Set (E j)) (f:∀j,E j→E (j+1)) (r:ℕ→ℝ) (N M J:ℕ)
    (himage:∀j<J,S (j+1)=f j '' S j)
    (h0:FiniteBallCover (S 0) N (r 0))
    (hstep:∀j<J,∀z:E j,FiniteBallCover (f j '' Metric.closedBall z (r j)) M (r (j+1))) :
    ∀j≤J,FiniteBallCover (S j) (N*M^j) (r j) := by
  intro j
  induction j with
  | zero => intro _; simpa using h0
  | succ j ih =>
    intro hj
    rw [himage j (by omega)]
    have hh := external_cover_step (S j) (f j) (N*M^j) M (r j) (r (j+1))
      (ih (by omega)) (hstep j (by omega))
    simpa only [pow_succ,Nat.mul_assoc] using hh

theorem external_two_ball_actual_prefix {E:ℕ→Type*} [∀j,PseudoMetricSpace (E j)]
    (S:∀j,Set (E j)) (f:∀j,E j→E (j+1)) (b:ℕ→ℝ) (r:ℝ) (J:ℕ)
    (hr:0≤r) (hb:∀j<J,0≤b j)
    (himage:∀j<J,S (j+1)=f j '' S j)
    (h0:FiniteBallCover (S 0) 1 r)
    (hstep:∀j<J,∀z:E j,∀R:ℝ,0≤R→
      FiniteBallCover (f j '' Metric.closedBall z R) 2 (R*b j)) :
    ActualBallCover (S J) (2^J) (2*r*∏j∈Finset.range J,b j) := by
  let radius := fun n:ℕ=>r*∏j∈Finset.range n,b j
  have hrad (j:ℕ) (hj:j≤J) : 0≤radius j := by
    apply mul_nonneg hr
    exact Finset.prod_nonneg fun k hk=>hb k (lt_of_lt_of_le (Finset.mem_range.mp hk) hj)
  have hrad0 : radius 0=r := by simp [radius]
  have hrads (j:ℕ) : radius (j+1)=radius j*b j := by
    simp only [radius,Finset.prod_range_succ,mul_assoc]
  have hc := external_cover_iteration S f radius 1 2 J himage
    (by simpa only [hrad0] using h0)
    (fun j hj z=>by rw [hrads]; exact hstep j hj z (radius j) (hrad j hj.le)) J le_rfl
  obtain ⟨C,hcard,hCS,hC⟩ := hc.actual_centers
  refine ⟨C,fun x hx=>hCS x hx,by simpa using hcard,?_⟩
  intro x hx
  obtain ⟨c,hc,hxc⟩ := hC x hx
  exact ⟨c,hc,by simpa only [radius,mul_assoc] using hxc⟩

#print axioms external_two_ball_actual_prefix
end ConditionalNonpolynomial.Analytic
