import NeuralGeneralization.OnlineLowerHolomorphicStationaryBranch
import Mathlib.Analysis.Calculus.FDeriv.Analytic
import Mathlib.Analysis.Calculus.IteratedDeriv.Defs
import Mathlib.Analysis.Asymptotics.Lemmas

noncomputable section
open scoped Topology BigOperators
open Filter Asymptotics
namespace NeuralGeneralization.OnlineLowerTanh

theorem analytic_taylor_bigO (f:ℂ→ℂ) (a:ℂ) (hf:AnalyticAt ℂ f a) (n:ℕ) :
    (fun h=>f (a+h)-∑j∈Finset.range n,(iteratedDeriv j f a/(j.factorial:ℂ))*h^j)
      =O[𝓝 0] (fun h:ℂ=>h^n) := by
  obtain ⟨p,r,hp⟩:=hf
  have hpat:HasFPowerSeriesAt f p a:=⟨r,hp⟩
  have he:=hpat.isBigO_sub_partialSum_pow n
  have hcoeff (j:ℕ) (h:ℂ) : p j (fun _=>h)=(iteratedDeriv j f a/(j.factorial:ℂ))*h^j := by
    have hc:=hp.factorial_smul h j
    rw [iteratedFDeriv_apply_eq_iteratedDeriv_mul_prod] at hc
    simp only [Finset.prod_const,Finset.card_univ,Fintype.card_fin,smul_eq_mul,nsmul_eq_mul] at hc
    have hn:(j.factorial:ℂ)≠0:=by exact_mod_cast j.factorial_ne_zero
    rw [div_mul_eq_mul_div]
    apply (eq_div_iff hn).mpr
    convert hc using 1 <;> ring
  have hsum (h:ℂ) : p.partialSum n h=∑j∈Finset.range n,(iteratedDeriv j f a/(j.factorial:ℂ))*h^j := by
    unfold FormalMultilinearSeries.partialSum
    exact Finset.sum_congr rfl (fun j hj=>hcoeff j h)
  simp_rw [hsum] at he
  exact (he.congr_right (fun h=>by rw [norm_pow])).of_norm_right

end NeuralGeneralization.OnlineLowerTanh
