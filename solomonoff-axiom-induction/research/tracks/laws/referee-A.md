# Referee report A (proofs) on thread `laws`

*Adversarial referee A, 2026-10-16. Object: `tracks/laws/notes.md` (653 lines, state of 02:47) and `checks/`. Work in progress; sections are filled in as the check proceeds.*

## Status of this report

In progress. Draft issues noted while reading §§1–7 (to be checked against the cited sources and re-ordered):

* D1 (major?) Setting S3 says times are i.i.d. from an atomless $\mu$; Def 1.5 makes times numerals in a countable decidable set $I$. Atomless impossible. Repeated times break i.i.d. costs (Karlin: distinct values $o(n)$); distinct times make $\pi_c$ unbounded ($\ge\log j$ for most). Affects Thm 3.8 use in Cor 3.9 (Q/det), Prop 3.10(a), §3.6 det pricings, Prop 6.1, 6.2.
* D2 (minor) dithered cell endpoints $\Delta(m-u)$ with $u\sim U[0,1)$ are irrational a.s.: not sentences of RCF with rational constants. Fix: discrete dither.
* D3 (major) Prop 7.1(d) is correct within the family $H^\varepsilon$, but the Reading, §0 and §9.1 say the honest form is "exactly what the two theories have in common" / "exactly what its successor derives". False: the common content is $T_0^W\vee T_N^W$, strictly stronger than $H^{\varepsilon_{\min}}$.
* D4 (minor) Prop 6.1(b) "iff $\gamma<\min$" fails at ties with a.s. constant cost difference, which is exactly the code-Q fine-regime case used in (c).
* D5 (minor) Prop 1.10(ii) proof: "fails in any language with a binary relation symbol" false for complete decidable $B$ (RCF); true for $B=\emptyset$.
* D6 (minor) Prop 1.11(b) $w_T$ not a semimeasure for inconsistent $T$; "e.g. on pointwise interval laws" vs "every finite $T$".
* D7 (minor/major) Prop 1.10(i): "programs are codewords of law presentations (a decidable prefix-free set)" with $P_T$ computable needs presentations of total $(l,u)$; no decidable set of programs covers all total computable functions; restricted presentation language is a hidden hypothesis.
* D8 (minor) Lemma 3.2 coarse regime should be $\Delta\ge\varepsilon+\max(\varepsilon,\varepsilon^*)$.
* D9 (minor) Prop 4.2 "iff $r\le r^*(\delta)$" needs linear $F$, $d=1$ (tightness) and $e_0=0$ for $r^*$ as defined.
* D10 (minor/major) Prop 4.3(b),(c) "only if" directions need $B$ to prove the failure ($B$ complete for the relevant sentences, e.g. RCF with semialgebraic data); "B true in the intended structure" is not enough.
* D11 (minor) Prop 5.7 constant depends on $\mathcal L'$'s syntax code.
* D12 (minor) Copernicus–Ptolemy: "in the best system for $\lambda<\sum a_p/H$" needs $H<\sum a_p$; EP "against the stated coincidences" mixes two comparisons.
* D13 (minor) Prop 6.2(c) monotonicity of $\gamma_{\rm si}$ in $\Delta$ under code R asserted, not proved; hypothesis $\gamma_{\rm si}\ge c_K$ must hold for all $\Delta$.
* D14 (minor) Q/rand "stays near 1" false as $p\to0$ (threshold grows like $\log(1/p)/2\gamma$).
* D15 (minor) §9.1 "only there (Prop 1.9(d))" overstates; Prop 1.9(d) shows collapse over all machines, not uniqueness of the class.
* D16 (minor) "what SAI actually charges"/"SAI's pricing": Prop 1.8 is an upper bound; the right reading is relative weight of two named machines in $M_A$'s mixture.
