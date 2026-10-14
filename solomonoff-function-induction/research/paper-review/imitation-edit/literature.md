# Imitation literature for Paper 2: verified works and draft sentences (literature check, 2026-10-14)

*This record answers point 3 of §7 of `research/tracks/imitation/notes-final.md`: that synthesis searched no literature on imitation learning, behavioural cloning, or identifying preferences and policies from behaviour. It verifies a small set of works by WebSearch and records exactly what each abstract supports. It also drafts the sentences Paper 2 would carry: one related-work paragraph, and two sentences plus one clause for the imitation section `sec:imit` that the synthesis drafts. BibTeX is in `lit.bib` (this folder).*

* **Sources read.**
  * The brief `research/tracks/imitation/00-brief.md` (the author's message).
  * The synthesis `research/tracks/imitation/notes-final.md`: §0–§2.1, §2.5, §3.4, §4–§7 and the verification log. Also `final-check.md` (its citation check).
  * The drafts `drafts/imit.tex` and `drafts/related.diff`.
  * Paper 2's `sections/related.tex` in full, `limits.tex` (`prop:limits:rateblind`, `prop:limits:separable`), `app-limits.tex` (`prop:limits:noident`) and `paper-steeper/bib/*.bib`.
  * `research/paper-review/DECISIONS.md` §A5–§A9 and §G, and `REFRAME.md` in full.
  * The literature records of the sibling project `inferential-learning/`, which already cites Armstrong–Mindermann and Cohen–Hutter–Nanda.
* **Method.** Every bibliographic field and every content claim below comes from WebSearch results: 35 queries, listed in the Verification log.
  * Direct fetches were impossible. WebFetch failed on DNS for arxiv.org, proceedings.neurips.cc and mlanthology.org, and `curl` to the arXiv API was refused by the proxy (CONNECT 403).
  * So no full text and no abstract page was read directly. "Abstract" below means the abstract as the search results quote or paraphrase it. Where two or more independent results agree on its content, that is recorded.
  * Nothing here relies on the body of any paper.
* **Status tags.**
  * **[abstract]**: the content is confirmed at abstract level by at least two search results.
  * **[abstract, one source]**: one result only.
  * **[bib]**: the bibliographic data are confirmed by the sources named.
  * **[not confirmed]**: a field was searched for but not confirmed, and is left out of `lit.bib`.
  * **[beyond abstract]**: content seen in search output that comes from the body or a secondary source. It is recorded so that nobody uses it.
* **Binding rules applied.**
  * DECISIONS §A8: "X show that …" only for abstract-level content; no process hedges; our own readings are stated as ours.
  * REFRAME: "we" voice, no reference to the author's notes.
  * DECISIONS §A5: no process vocabulary in visible text.
* **Repository.** No git command was run, and nothing in `paper-steeper/`, `paper/` or `research/tracks/` was changed.
  * Files written: this record and `lit.bib`.
  * Scratch builds were made in the session scratchpad (§5).

---

## 0. Summary

1. **Thirteen works verified** (§2). Eight are recommended for citation:
   * behavioural cloning: Bain–Sammut 1999, Pomerleau 1991, de Haan–Jayaraman–Levine 2019;
   * imitation with unobserved confounders: Zhang–Kumor–Bareinboim 2020;
   * inverse reinforcement learning and its ambiguity: Ng–Russell 2000, Armstrong–Mindermann 2018, Cao–Cohen–Szpruch 2021;
   * Bayesian imitation in general environments: Cohen–Hutter–Nanda 2022.

   Five more are verified but not recommended for the main text (Pomerleau 1989, Shah et al. 2019, Skalse et al. 2023, Ross–Gordon–Bagnell 2011, Ortega et al. 2021). Their entries are in `lit.bib`; BibTeX prints only cited entries.
2. **One correction to the suggested list.** The ALVINN paper (Pomerleau 1989, NIPS 1) is not a behavioural-cloning reference at abstract level: its abstract says the network was trained on *simulated road images*. Pomerleau's 1991 *Neural Computation* paper is the one whose abstract says the network learns to drive *by watching a person drive*. The drafts cite the 1991 paper.
3. **Simplicity priors or MDL for imitation.** Four queries found no work that selects an imitator by a two-part code or a simplicity prior and asks whether it returns the demonstrator's own sampler (§1). The closest works are:
   * Armstrong–Mindermann: a simplicity prior over planner–reward decompositions, with a negative result;
   * Cohen–Hutter–Nanda: a Bayesian imitator from the universal-AI tradition, but a mixture, not a selected program.

   The search was small, so this is not a claim that no such work exists. The paper's wording "To our knowledge" stays the right form.
4. **Drafts** (§3). Each was built in a scratch copy of Paper 2 with all imitation drafts applied, with 0 errors, 0 undefined references or citations and 0 overfull boxes (§5):
   * a related-work paragraph of four sentences (about 12 lines);
   * a two-sentence fallback;
   * a clause and two sentences for `sec:imit`.

   Every attribution is checked against the abstracts in §4.
5. **Page cost** (§5).
   * Main version: 86 pages against the drafts' 84. One page comes from the text and eight references. The other comes from `tab:parity:ranges` in Appendix E floating onto a page of its own after the one-page shift, a layout artifact.
   * Fallback: 85 pages.

---

## 1. What was searched

| topic | queries | outcome |
|---|---|---|
| behavioural cloning (Pomerleau; Bain–Sammut) | 1, 2, 11, 12, 27, 28, 33 | verified; ALVINN 1989 trains on simulated images, Pomerleau 1991 learns from a person |
| inverse RL and reward ambiguity (Ng–Russell) | 3, 9, 13, 26, 35 | verified; degeneracy confirmed at abstract level (paraphrase, two sources) |
| identifying preferences from behaviour (Armstrong–Mindermann; Cao et al.; Skalse et al.; Shah et al.) | 4, 6, 7, 16, 18, 19, 29, 34 | verified |
| causal confusion and confounding (de Haan et al.; Zhang et al.; Ortega et al.) | 5, 8, 14, 15, 30, 31 | verified |
| Bayesian or universal imitation (Cohen–Hutter–Nanda) | 10, 21, 23 | verified |
| sequential imitation and i.i.d. (Ross et al.) | 22, 32 | verified (the PMLR volume rests on the venue) |
| MDL, Kolmogorov complexity or a simplicity prior for imitation | 17, 20, 24, 25 | **no imitation-specific work found** (below) |

**Simplicity priors for imitation: what the four queries returned.**
* An ICLR 2023 paper "Minimum Description Length Control" applies MDL to multitask reinforcement learning, distilling shared structure into a default policy. It does not concern demonstrations. Not verified further, not proposed.
* Hutter's "Discrete MDL predicts in total variation" (NIPS 2009) concerns countable classes in general. Not imitation; not proposed.
* Armstrong–Mindermann: a simplicity prior over planner–reward decompositions (§2).
* Informal posts on LessWrong and the Alignment Forum, for example "Kolmogorov complexity makes reward learning worse". These are not peer-reviewed and are not proposed (DECISIONS §G1 dropped an unverifiable online source for the same reason).

---

## 2. Verified works: data, what the abstract supports, relevance

The relevance column is our reading, to be stated as such in the paper.

### 2.1 Recommended for citation

**`pomerleau1991efficient`.** D. A. Pomerleau, "Efficient Training of Artificial Neural Networks for Autonomous Navigation", *Neural Computation* 3(1):88–97, March 1991, doi 10.1162/neco.1991.3.1.88. **[bib]**: CMU Robotics Institute record, MLAnthology; the initials "DA" are from the ModelDB citation record.
* **Abstract supports [abstract].** ALVINN, a back-propagation network that drives the CMU Navlab, learns to drive in about five minutes by watching a person drive. One result says "about", the other "under"; the drafts use neither. The trained system drove on single-lane paved and unpaved roads and on multilane lined and unlined roads, at up to 20 mph.
* **Not supported.** Anything about generalisation or failure modes.
* **Use.** An early instance of learning a person's behaviour by supervised learning.

**`bain1999framework`.** M. Bain and C. Sammut, "A Framework for Behavioural Cloning", in K. Furukawa, D. Michie and S. H. Muggleton (eds.), *Machine Intelligence 15: Intelligent Agents*, Oxford University Press, 1999, pp. 103–129. **[bib]**: the DBLP record of the volume gives the editors, OUP, 1999, ISBN 0-19-853867-7, and pp. 103–129. The workshop was held in 1995, which is why some sources cite "1995".
* **Abstract supports [abstract, one source].** The abstract is the copy on C. Sammut's UNSW page. Earlier behavioural clones were brittle and difficult to understand; the work separates an agent's goals from its knowledge of how to achieve them.
* **[beyond abstract].** "Logged data from skilled human operators are input to an induction program which outputs a control strategy" is from the paper's text, as a search result describes it. Not used.
* **Use.** The term "behavioural cloning" (title level), cited together with de Haan et al., whose abstract gives the definition.

**`dehaan2019causal`.** P. de Haan, D. Jayaraman and S. Levine, "Causal Confusion in Imitation Learning", *Advances in Neural Information Processing Systems 32* (NeurIPS 2019), oral; arXiv:1905.11979 (v1 28 May 2019, v2 4 Nov 2019). **[bib]**: arXiv listing, NeurIPS proceedings and virtual pages, MLAnthology. Pages **[not confirmed]**: MLAnthology gives 11698–11709 and the UvA repository 11666–11677, so they are left out.
* **Abstract supports [abstract].**
  * "Behavioral cloning reduces policy learning to supervised learning by training a discriminative model to predict expert actions given observations." This sentence was confirmed verbatim by a quoted-phrase search.
  * Such models are non-causal: training ignores the causal structure of the interaction between expert and environment, which is especially damaging because of distributional shift in imitation learning.
  * This leads to "causal misidentification": "access to more information can yield worse performance" (verbatim, quoted-phrase search).
  * A fix uses targeted interventions, by environment interaction or by expert queries, to determine the correct causal model.
  * The effect occurs in benchmark control domains and realistic driving settings, and the method is compared with DAgger.
* **Use.** It gives the definition of behavioural cloning. Its interventions fit `q:imit:open`(e), "data … from interventions".

**`zhang2020causal`.** J. Zhang, D. Kumor and E. Bareinboim, "Causal Imitation Learning with Unobserved Confounders", *Advances in Neural Information Processing Systems 33* (NeurIPS 2020), oral. **[bib]**: NeurIPS proceedings and virtual poster pages. The arXiv id and pages are **[not confirmed]** and left out.
* **Abstract supports [abstract].**
  * The paper studies imitation when the learner's sensory inputs differ from the expert's. Standard methods (behaviour cloning, inverse RL) assume the expert's decision covariates are fully observed, and the paper relaxes this.
  * It gives a non-parametric graphical criterion that is complete (necessary and sufficient) for deciding whether imitation is feasible from demonstration data and qualitative assumptions encoded as a causal model.
  * When the criterion fails, imitation may still be feasible using quantitative knowledge of the expert's trajectories.
  * An efficient procedure learns the imitating policy.
* **Not supported.** The word "imitability" was not found in the abstract and is not used.
* **Use.** The latent-cause case of `def:imit:setting`, where the person's coin depends on a cell the learner does not see, is our instance of a demonstrator whose choices depend on a variable the learner does not observe. That parallel is our reading.

**`ng2000algorithms`.** A. Y. Ng and S. Russell, "Algorithms for Inverse Reinforcement Learning", ICML 2000, pp. 663–670. **[bib]**: DBLP conf/icml/NgR00, MLAnthology.
* The DOI on MLAnthology (10.2460/AJVR.67.2.323) belongs to an unrelated journal and is not used.
* The editor (Langley), the publisher (Morgan Kaufmann) and the ordinal "Seventeenth" in the proceedings title are **[not confirmed]**. The booktitle is therefore generic.
* **Abstract supports [abstract].**
  * Inverse RL is "the problem of extracting a reward function given observed, optimal behaviour" (quoted, with small spelling differences, in three results).
  * The authors characterise the set of all reward functions for which a given policy is optimal, and derive three algorithms: full policy with a tabulated reward; linear approximation over an infinite state space; a policy known only through observed trajectories.
  * A key issue is degeneracy, the existence of a large set of reward functions for which the observed policy is optimal. They suggest heuristics that pick a reward that maximally differentiates the observed policy from sub-optimal ones. This point is confirmed by two results in paraphrase; the verbatim sentence was searched but not returned.
* **[beyond abstract].** "Any constant function can rationalize the expert's behaviour" is from a later paper on regularised IRL. Not used.
* **Use.** "Many rewards qualify."

**`armstrong2018occam`.** S. Armstrong and S. Mindermann, "Occam's Razor Is Insufficient to Infer the Preferences of Irrational Agents", *Advances in Neural Information Processing Systems 31* (NeurIPS 2018); arXiv:1712.05812 (v1 15 Dec 2017, v6 11 Jan 2019). **[bib]**: NeurIPS proceedings, arXiv, NeurIPS poster page.
* Author order is Armstrong first on the NeurIPS page and on arXiv. The PDF lists Mindermann first, marked as equal contribution.
* Pages **[not confirmed]**: two queries did not return them.
* **Abstract supports [abstract].**
  * Inverse reinforcement learning attempts to infer human rewards or preferences from observed behaviour.
  * A No Free Lunch result implies that it is impossible to uniquely decompose a policy into a planning algorithm and a reward function.
  * Even with a reasonable simplicity prior (Occam's razor) on the set of decompositions, the true decomposition cannot be distinguished from others that lead to high regret.
  * Simple "normative" assumptions, which cannot be deduced exclusively from observations, are needed.
  * The problem differs from the known ambiguity problems of IRL: it cannot be resolved by observing the agent's policy in enough environments.
* **[beyond abstract].** These come from search summaries of the paper body and are not used:
  * the simplicity measure is Kolmogorov complexity;
  * an "informal theorem" says that degenerate planner–reward pairs are simpler than the reasonable pair, and that a pair with the opposite reward has similar complexity;
  * the authors concede dependence on the reference language.

  They are the closest analogue of Paper 2's rate results and would need a reading of the full text (§6, point 2).
* **Use.** The planner–reward split is a non-identifiable decomposition of behaviour, as are Paper 2's rule–error split (`prop:limits:separable`, `prop:limits:noident`) and person–environment split (`prop:imit:limits`(a)). Their "normative assumptions not deducible from observations" correspond to Paper 2's "a choice of $c$ that does not use the imitation data" (`q:limits:open`). This parallel is our reading.
* The sibling project uses the same key and data, with wording accepted by its citation review: "show that a policy does not determine its decomposition into planner and reward, and that a simplicity prior over decompositions does not single out the intended one".

**`cao2021identifiability`.** H. Cao, S. N. Cohen and Ł. Szpruch, "Identifiability in Inverse Reinforcement Learning", *Advances in Neural Information Processing Systems 34* (NeurIPS 2021); arXiv:2106.03498 (v1 7 Jun 2021, v3 8 Nov 2021). **[bib]**: NeurIPS proceedings, arXiv, MLAnthology. Pages **[not confirmed]**.
* **Abstract supports [abstract].**
  * Reward recovery from behaviour is ill-posed: the reward is not identifiable even with perfect information about optimal behaviour (attributed there to Russell 1998).
  * For entropy-regularised problems and a fixed environment, the paper characterises all rewards that yield a given policy.
  * With demonstrations under two distinct discount factors, or in sufficiently different environments, the reward is recovered up to an additive constant.
  * Further conditions cover time-homogeneous rewards on finite horizons and action-independent rewards.
* **Use.** Data from several environments identify more, which is the subject of `q:imit:open`(e).

**`cohen2022fully`.** M. K. Cohen, M. Hutter and N. Nanda, "Fully General Online Imitation Learning", *Journal of Machine Learning Research* 23(334):1–30, 2022; arXiv:2102.08686. **[bib]**: jmlr.org/papers/v23/21-0618, MLAnthology; the same data as `inferential-learning/paper/bib/all.bib`.
* **Abstract supports [abstract].**
  * Earlier formal guidance on imitating so that events unfold as under the demonstrator covers only environments that restart.
  * The paper treats a fully general setting in which the stochastic environment and the demonstrator never reset, and the imitator learns online.
  * The "conservative Bayesian imitation learner underestimates the probabilities of each available action" (verbatim, quoted-phrase search), and queries the demonstrator with the remaining probability (paraphrase, three results).
  * Main result: an event that would have been unlikely had the demonstrator acted throughout has its likelihood bounded above when the initially ignorant imitator acts instead, and queries become rarer over time.
* **Use.** It is the nearest work from the universal-AI tradition. Their imitator is Bayesian, while Paper 2 selects one program and excludes Bayes mixtures over persons from its class (the first paragraph of `sec:imit`). The drafts cite it only for what the abstract says.

### 2.2 Verified, not recommended for the main text

| key | data [bib] | abstract supports [abstract] | why not cited |
|---|---|---|---|
| `pomerleau1989alvinn` | *Advances in Neural Information Processing Systems 1* (NIPS 1988, published 1989), ed. D. S. Touretzky, Morgan Kaufmann, pp. 305–313 (CMU record; NeurIPS proceedings page) | ALVINN, a 3-layer back-propagation network for road following; camera and laser range-finder input, steering direction output; **trained on simulated road images**; tests on the CMU vehicle show it can follow real roads under certain conditions | not learning from a person at abstract level; the 1991 paper replaces it |
| `shah2019feasibility` | ICML 2019, PMLR 97:5670–5679 (PMLR page) | IRL usually assumes a noisily optimal demonstrator, but people have systematic biases; the authors learn the demonstrator's planner (a differentiable planner) instead of assuming a bias; mixed results: learning beats a wrong assumption, but the loss from an approximate planner outweighs the gain | fits the teacher thread ("The gap to realistic errors"), not imitation; optional clause there |
| `skalse2023invariance` | ICML 2023, PMLR 202:32033–32058 (PMLR page, MLAnthology); arXiv:2203.07475; first names from the standard records | the reward is often only partially identifiable, even with infinite data; the partial identifiability is characterised for data sources including expert demonstrations and trajectory comparisons, together with its effect on downstream tasks such as policy optimisation | overlaps with Cao et al.; optional |
| `ross2011reduction` | AISTATS 2011, pp. 627–635 (MLAnthology, CMU record); arXiv:1011.0686; PMLR volume 15 = AISTATS 2011 (PMLR volume page; the snippet did not show this entry) | sequential prediction problems such as imitation learning, where future observations depend on previous actions, violate the i.i.d. assumptions of statistical learning; a no-regret iterative algorithm trains a stationary deterministic policy that performs well under its own induced distribution | Paper 2 assumes i.i.d. inputs; usable as a one-clause scope caveat (§3.3) |
| `ortega2021shaking` | arXiv:2110.10819, 20 Oct 2021, DeepMind technical report, 19 authors (P. A. Ortega, M. Kunesch, …; the rest not individually confirmed, so `and others`) | sequence models used for control can suffer "auto-suggestive delusions", treating their own actions as evidence about the task when latent confounders are present; the remedy is to treat actions as causal interventions; with no latent confounders, conditioning on actions causes no self-delusions | about acting, not about selecting a sampler; tangential |

---

## 3. Draft text

### 3.1 Related work (`sections/related.tex`): a new paragraph

**Placement.** A new paragraph, as built: after "Algorithmic statistics" and before "Novelty". The alternative is directly after "λ-weighted two-part MDL in noisy classification", whose last sentence mentions "a general imitation channel"; the two placements build identically, since `related.tex` has no floats.

**Header comment** to add to the file's comment block:

```latex
% Paragraph "Imitation and identifiability from behaviour" (research/paper-review/imitation-edit/literature.md §3.1):
% content of the cited works at abstract level only (DECISIONS §A8).
```

**Main version** (four sentences; built; about 12 lines):

```latex
\paragraph{Imitation and identifiability from behaviour.}
Behavioural cloning treats imitation as supervised learning of a demonstrator's actions given observations \citep{bain1999framework,pomerleau1991efficient,dehaan2019causal}; because this ignores the causal structure of demonstrator and environment, more information can make the imitator worse \citep{dehaan2019causal}, and \citet{zhang2020causal} give a graphical criterion, from a causal model, for when imitation is possible if the learner does not observe everything the demonstrator's decisions depend on. Inverse reinforcement learning infers a reward for which the observed behaviour is optimal, and many rewards qualify \citep{ng2000algorithms}; a policy does not determine its decomposition into a planner and a reward, and even a simplicity prior does not single out the true decomposition \citep{armstrong2018occam}, while demonstrations in sufficiently different environments identify an entropy-regularised reward up to a constant \citep{cao2021identifiability}. \citet{cohen2022fully} give a Bayesian imitation learner for environments that never reset. Our negative results are of the same kind, for one program selected from i.i.d.\ imitation data: $\lambda$ cannot be chosen from imitation data alone, since twin worlds with one teacher channel need different selections (\cref{prop:limits:separable,prop:limits:noident}), and no procedure reliably copies the sampler in each of several worlds with one data law (\cref{prop:imit:limits}(a)).
```

**Fallback** (two sentences; built; 85 pages):

```latex
\paragraph{Imitation and identifiability from behaviour.}
Behavioural cloning treats imitation as supervised learning of a demonstrator's actions given observations \citep{bain1999framework,dehaan2019causal}, and in inverse reinforcement learning a policy does not determine its decomposition into a planner and a reward, nor does a simplicity prior single out the true decomposition \citep{armstrong2018occam}. Our negative results are of the same kind, for one program selected from i.i.d.\ imitation data (\cref{prop:limits:noident,prop:imit:limits}).
```

**If `sec:imit` is not adopted.**
* In the main version, delete ", and no procedure reliably copies the sampler in each of several worlds with one data law (\cref{prop:imit:limits}(a))".
* In the fallback, cite `\cref{prop:limits:noident}` alone.
* Neither variant was built separately: each removes one clause and changes no citation.

**Wording choices.**
* The paragraph uses $\lambda$ and "the sampler", not $c$ and "the person". At §2 the paper has not yet introduced $\lambda=cn$, except in the weight-decay sentence that `drafts/related.diff` adds, nor "the person", which belongs to `sec:imit`.
* "$\lambda$ cannot be chosen from imitation data alone" is the title of `prop:limits:noident`.

### 3.2 Imitation section (`sections/imit.tex`, from `drafts/imit.tex`)

**I1, a clause in the first sentence** (built). Replace

> a learner trained on a person's answers should return a copy of the person

with

```latex
a learner trained on a person's answers, as in behavioural cloning \citep{bain1999framework,dehaan2019causal}, should return a copy of the person
```

**I2, two sentences** (built). Append them to the paragraph after the proof idea of `prop:imit:limits`, directly after "… as steeper selection does for error rules (\cref{prop:limits:separable})." and before "An incompressible coupling is not enough":

```latex
 Behaviour does not determine the split of a policy into a planner and a reward either, and a simplicity prior does not single out the true one \citep{armstrong2018occam}. Demonstrations in sufficiently different environments identify an entropy-regularised reward up to a constant \citep{cao2021identifiability}, and in behavioural cloning targeted interventions are used to determine the correct causal model \citep{dehaan2019causal}; whether such data identify which structure belongs to the person here is open (\cref{q:imit:open}(e)).
```

(The leading space joins it to the preceding sentence.)

**I3, optional, not built.** One sentence after "… (the feature case) or only through the channel (a latent shared cause)." in the paragraph after `def:imit:setting`:

```latex
In the latent case the person's answers depend on a variable the learner does not observe, a situation that \citet{zhang2020causal} study for imitation in causal terms.
```

This is our reading of the parallel. It is safe at abstract level, since the paper relaxes the assumption that the expert's decision covariates are fully observed. If I3 is used, the related-work paragraph may drop its Zhang et al. clause.

### 3.3 Optional, elsewhere (not built)

* **Discussion, "What the toy cases leave open", item (2).** After "… are conventions that imitation data cannot settle", add `, as for the planner--reward split of inverse reinforcement learning \citep{armstrong2018occam}`.
* **Discussion, "The gap to realistic errors".** A clause: `whether a demonstrator's systematic biases can be learned rather than assumed is studied for reward inference by \citet{shah2019feasibility}`.
* **Introduction scope paragraph, or discussion item (5).** A clause: `in sequential imitation the imitator's actions change its later inputs, which violates the i.i.d.\ assumption \citep{ross2011reduction}`.

---

## 4. Every attribution in the built drafts, against the abstracts

| sentence (draft) | cited work | abstract content it rests on (§2) | status |
|---|---|---|---|
| "Behavioural cloning treats imitation as supervised learning of a demonstrator's actions given observations" | de Haan et al. (definition); Bain–Sammut (the term, title level); Pomerleau 1991 (an instance: learns to drive by watching a person) | de Haan: "reduces policy learning to supervised learning … predict expert actions given observations" | [abstract] |
| "because this ignores the causal structure of demonstrator and environment, more information can make the imitator worse" | de Haan et al. | "non-causal … unaware of the causal structure of the interaction between the expert and the environment"; "access to more information can yield worse performance" | [abstract] |
| "give a graphical criterion, from a causal model, for when imitation is possible if the learner does not observe everything the demonstrator's decisions depend on" | Zhang et al. | complete graphical criterion for the feasibility of imitation from demonstration data and a causal model; expert's decision covariates not fully observed | [abstract] |
| "infers a reward for which the observed behaviour is optimal, and many rewards qualify" | Ng–Russell | extracting a reward function given observed optimal behaviour; degeneracy: a large set of rewards for which the observed policy is optimal | [abstract] (degeneracy in paraphrase, two sources) |
| "a policy does not determine its decomposition into a planner and a reward, and even a simplicity prior does not single out the true decomposition" | Armstrong–Mindermann | impossible to uniquely decompose a policy into a planning algorithm and a reward; with a simplicity prior the true decomposition cannot be distinguished from others with high regret | [abstract] |
| "demonstrations in sufficiently different environments identify an entropy-regularised reward up to a constant" | Cao et al. | entropy-regularised problems; two discount factors or sufficiently different environments; reward recovered up to an additive constant | [abstract] |
| "give a Bayesian imitation learner for environments that never reset" | Cohen et al. | conservative Bayesian imitation learner; environment and demonstrator never reset | [abstract] |
| "in behavioural cloning targeted interventions are used to determine the correct causal model" | de Haan et al. | targeted interventions (environment interaction or expert queries) to determine the correct causal model | [abstract] |
| "Our negative results are of the same kind …" | Paper 2 (`prop:limits:separable`, `prop:limits:noident`(iii), `prop:imit:limits`(a)) | `separable`: twin worlds with one teacher channel get the same selection at every $c$; `noident`(iii): every rule that chooses $c$ from imitation data alone is wrong in one of them; `imit:limits`(a): $\sum_i\Prob_{W_i}[\Psi\in\mathcal E(\nu_i)]\le1$ for worlds with one data law | [proved: Paper 2; `imit:limits`(a) per the synthesis §2.1] ; "of the same kind" is our reading |
| "whether such data identify which structure belongs to the person here is open" | `q:imit:open`(e) | "(e) Can data other than imitation data, from several environments or from interventions, identify which structure belongs to the person?" | [open] |

No sentence uses a **[beyond abstract]** item of §2, and none says how the literature was checked (DECISIONS §A8). In the scratch build, the vocabulary grep of DECISIONS §A5 on `pdftotext main.pdf` finds only the title footnote's "independent AI referees", as before.

---

## 5. Build check

Scratch copies of `paper-steeper/` were made in the session scratchpad (`main.tex`, `preamble.tex`, `sections/`, `bib/`, `build.sh`, `merge_bib.py`, `figures/`).
* In each copy, the six diffs of `research/tracks/imitation/drafts/` were applied with `patch -p1` (clean), and `imit.tex`, `app-imit.tex` and `imit.bib` were copied in.
* `lit.bib` was copied to `bib/`.
* The drafts of §3.1–§3.2 were inserted by script, with assertions that each anchor occurs exactly once.
* Each copy was built with its own `build.sh` under `flock /tmp/claude-0/paper-build-sfi.lock`.

| build | LaTeX errors | undefined refs | undefined cites | multiply defined | overfull > 10 pt | pages | bibliography entries |
|---|---|---|---|---|---|---|---|
| imitation drafts only (baseline) | 0 | 0 | 0 | 0 | 0 | 84 | 46 |
| + main version (§3.1) + I1 + I2 | 0 | 0 | 0 | 0 | 0 | 86 | 54 |
| + fallback (§3.1) + I1 + I2 | 0 | 0 | 0 | 0 | 0 | 85 | 50 (I2 adds Cao et al.) |

* **Where the pages go** (main version against the baseline):
  * `sec:absorb` starts at p. 11 instead of p. 10;
  * `sec:imit` at p. 34 instead of p. 33;
  * Appendix A at p. 44 instead of p. 43, so the main text and references grow by one page;
  * Appendix E (parity) grows from 6 to 7 pages because `tab:parity:ranges` (`[t]`) moves from p. 64 to its own page, p. 66, after the shift.

  The second page is a layout artifact; a final layout pass can recover it, for example by moving the table's source or changing its placement option.
* **The rendered paragraph** takes about 12 lines on p. 6. The new references print correctly: authors, venues, "doi:" for Pomerleau 1991, and arXiv ids.
* `merge_bib.py` reports 65 entries and 0 title conflicts. `bibtex.log` has no warnings.
* The LaTeX blocks of §3.1 (main and fallback) and §3.2 (I1, I2) are byte-identical to the inserted text (checked by script; Verification log).

---

## 6. Points for the author

1. **Recommended weight.** The four-sentence paragraph and I1 + I2 give the imitation thread the context a reader will look for: behavioural cloning, reward ambiguity, identifiability from several environments. The fallback keeps only the two most relevant works, Armstrong–Mindermann and behavioural cloning.
2. **The closest relative is Armstrong–Mindermann.** Their abstract-level result matches Paper 2's negative results, and their conclusion matches Paper 2's open problem of choosing $c$ without the imitation data: normative assumptions are needed that cannot be deduced from observations alone.
   * Their body reportedly argues that degenerate decompositions are *simpler* under Kolmogorov complexity. That would be the precise counterpart of Paper 2's "selection sorts components by rate, not validity".
   * The full text was not read, so the drafts say only what the abstract says. A comparison would need the paper itself.
3. **Novelty.** No work was found that selects an imitator by a two-part code or a simplicity prior and asks whether it returns the demonstrator's own sampler. The search was four queries, which is not a basis for a "first" claim.
   * If `sec:imit` is adopted, the `rem:related:new` list could add "the near-imitation theorem and the closeness lemma", under its existing "To our knowledge".
   * That is the author's call; it is not drafted here.
4. **Fields left out of `lit.bib`.** They are recorded so that a pre-submission check can fill them:
   * the NeurIPS page ranges of Armstrong–Mindermann, de Haan et al., Zhang et al. and Cao et al.;
   * the editor and publisher of ICML 2000;
   * the full author list of Ortega et al. (uncited).

---

## Verification log

* **2026-10-14, reading.** As listed under "Sources read". Key collisions were checked by script: none of the 13 keys of `lit.bib` occurs in `paper-steeper/bib/*.bib`, `research/tracks/imitation/drafts/imit.bib` or `paper/bib/*.bib`.
* **WebSearch queries** (35; standard mode unless marked):
  1. Pomerleau 1989 ALVINN NIPS pages 305–313
  2. Bain–Sammut, Machine Intelligence 15, pages
  3. Ng–Russell 2000, ICML pages, degenerate solutions
  4. Armstrong–Mindermann, NeurIPS 2018, arXiv 1712.05812
  5. de Haan–Jayaraman–Levine, arXiv 1905.11979
  6. Armstrong–Mindermann page numbers
  7. Armstrong–Mindermann abstract phrases
  8. de Haan et al. abstract phrases (quoted)
  9. Ng–Russell abstract phrases, editor, publisher
  10. Cohen–Hutter–Nanda, JMLR 23
  11. ALVINN abstract, Touretzky, Morgan Kaufmann
  12. Machine Intelligence 15 editors and publisher
  13. ICML 2000 proceedings title
  14. Zhang–Kumor–Bareinboim
  15. Ortega et al.
  16. Skalse et al., PMLR 202
  17. MDL or simplicity prior for imitation (extended)
  18. Shah et al., PMLR 97
  19. Cao–Cohen–Szpruch
  20. Solomonoff or universal prior for imitation (extended)
  21. Cohen et al. abstract text
  22. Ross–Gordon–Bagnell
  23. Cohen et al. quoted abstract sentence
  24. behavioural cloning or imitation with MDL
  25. IRL with simplicity prior or Kolmogorov complexity
  26. Ng–Russell "a key issue is degeneracy" (quoted)
  27. Bain–Sammut abstract (quoted)
  28. Pomerleau 1991, Neural Computation
  29. Skalse et al. abstract
  30. Zhang et al. pages
  31. Ortega et al. author list
  32. AISTATS 2011, PMLR 15
  33. "Dean A. Pomerleau" 1991
  34. Cao et al. author names
  35. ICML 2000 "Seventeenth"
* **Fetches.**
  * Five WebFetch calls failed with `getaddrinfo ENOTFOUND`: arxiv.org ×2, proceedings.neurips.cc ×2, mlanthology.org.
  * One `curl` to `export.arxiv.org` was refused by the proxy (CONNECT 403).
  * No other download was attempted.
* **Scratch builds** (§5): three full builds (baseline, main version, fallback), plus two earlier builds, both at 86 pages and both clean.
  * The first earlier build had a first version of the paragraph, which rendered at 19 lines and used $c$ and "the person" before Section 3 defines them. It was shortened, and $c$ and "the person" were replaced by $\lambda$ and "the sampler".
  * The second earlier build had the shortened paragraph with a first wording of I2, which read "which is the question of Question 10.5(e)" in the PDF. I2 was reworded, and the Zhang et al. clause was made closer to the abstract ("a graphical criterion, from a causal model").
* **`lit.bib`.** SHA-256 prefix `c827e73968e5e721`. It is byte-identical to the copy used in the final builds.
* **Byte identity.** The blocks of §3.1 (main, fallback) and §3.2 (I1, I2) were compared by script with the text inserted into the scratch builds: identical.
