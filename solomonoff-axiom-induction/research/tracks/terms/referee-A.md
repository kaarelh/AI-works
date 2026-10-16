# Referee A (proofs) on thread `terms`

*Adversarial referee report on `notes.md` (this folder, 678 lines, dated 2026-10-15/16) and its scripts in `checks/`. Written 2026-10-16. Referee code: `referee_code/rA1_alt_output_rule.py` with its saved output. No git command that changes repository state was run. Numbering follows `notes.md`. DRAFT IN PROGRESS: sections are saved as they are completed.*

## Verdict

(pending; draft issues below)

## Issues

### Major

**M1. Prop 4.7: the construction written in the text is wrong as stated; only the script's (unwritten) construction is right.**
* *Where.* §4.5, proof of Prop 4.7: "Compile as in Lemma 4.5 with phases 2 and 3 only (no certificate) ... At start pairs this gives the output rules, with $R:=X$; the rest of the proof of Thm 4.6(i)–(iii) applies."
* *Problem 1 (start rule).* Lemma 4.5's start rule $(Z;c(s)Y)\Rightarrow({\rm blk}(\#)Z;c(s_0)Y)$ pushes the separator onto $r$, above the raw input; without phases 0–1 nothing moves it to $l$, and phase 2 then reads the bits of ${\rm blk}(\#)$ as raw input letters. The record's own self-check 7 found this (1023 mismatches), and the script was corrected, but the text of the proof was not: it never states the start rule that is actually used, $(Z;c(s)Y)\Rightarrow(Z;c(s_2){\rm blk}(\#)Y)$.
* *Problem 2 (output rules).* "The rest of the proof of Thm 4.6 applies" imports Thm 4.6's output rules $\forall x\forall z\,(C(x,\eta\,{\rm st}(s)\,z)\to R(x)^{\pm})$ with a free certificate variable $z$. Without a certificate phase, $z$ is not consumed: it sits below the separator, and phase 3 rewinds any block-aligned $z$ onto the tape, so $M_1$ is run on $z'\#x$ instead of $\#x$. Lemma 4.5(1)'s normal form says nothing about $M_1$ on such tapes. Prop 9.1(a)'s "scan first" argument does not help here, since it relies on phase 0 consuming $z$.
* *Counterexample (computed, `referee_code/rA1_alt_output_rule.out`).* The thread's own compiler and fixed-point evaluator are imported unchanged. Two transitions are added to the script's machine, $q_0\xrightarrow{0}{\rm ACC}$ and $q_0\xrightarrow{1}{\rm REJ}$. Both are unreachable from start configurations, since cell 0 of a start tape always holds $\#$. With the exact output rules all $2\times1023$ verdicts for $|x|\le9$ stay correct. With the free-$z$ output rules, $C(x,0\,{\rm st}(s)\,{\rm blk}(0))$ and $C(x,1\,{\rm st}(s)\,{\rm blk}(1))$ hold for every $x$. So the theory proves $R(t_x)$ and $\neg R(t_x)$ for every $x$, and it is inconsistent. On the script's unmodified machine the free-$z$ rules happen to give no wrong verdict (0 on 24 test certificates × 1023 words), because that machine gets stuck on every garbage prefix. So the script's checks could not have exposed the gap.
* *Fix.* Write out the alternating compile in full:
  * the start rule $(Z;c(s)Y)\Rightarrow(Z;c(s_2){\rm blk}(\#)Y)$, or $(Z;c(s)|{\rm exact})\Rightarrow(Z;c(s_2){\rm blk}(\#)|{\rm exact})$;
  * the exact output rules $\forall x\,(C(x,0\,{\rm st}(s))\to R(x))$ and $\forall x\,(C(x,1\,{\rm st}(s))\to\neg R(x))$, as the script has them (`make_theory`: `t + code['s'] + '.e'`);
  * the definition of $\mathcal R$ as the set of codes reachable from the exact start pairs $(x,\eta\,{\rm st}(s))$.

  Then state that the claim "$\sigma\in C^{\mathfrak T}$ iff the configuration accepts" is used only at these pairs. With these changes the remaining proof is correct (checked below). The observational version needs only the $\mathrm{Std}(x)$ premise on the output rule, as in the script.

(further issues pending)

## Verification log

(pending)
