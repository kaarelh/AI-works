# Hyperbolic and long-run growth models that predict a singularity near the present, and their relation to AGI

Research conditions (read first): this session could fetch full texts only from arXiv. Open Philanthropy / Coefficient Giving, GMU (Hanson), Science, NBER, OWID and gwern were blocked for direct fetch, and the web-search budget ran out partway through. So Roodman, Davidson, Hanson, Nordhaus, Bloom et al., Aghion–Jones–Jones and Trammell–Korinek are cited from search-result extracts of their abstracts, slides or summaries, not from a full read; those places are marked "(via search extract)". Full texts were read for: Johansen & Sornette 2001; Erdil & Besiroglu 2023/24; Epoch's GATE paper (2025); Korotayev & Malkov 2012; Golosovsky 2009; Yakovenko 2025; Bellina, De Marzo & Loreto 2025; Cunningham et al. 2026; Nielsen 2017 (abstract only). Numbers marked "my computation" come from a short script (`/tmp/claude-0/-home-user-AI-works/4efb40ba-54a6-5b00-b03f-3f1d0e56bdd6/scratchpad/scripts/vf.py`).

## Q1. von Foerster, Mora & Amiot (1960): model, parameters, data, interpretation, reactions, and when population left the curve

### Takeaway
VFMA fitted N(t) = C/(t0 − t)^k to world population estimates from about 1 CE to 1958 and got k ≈ 0.99, C ≈ 1.8×10^11 and t0 = 2026.87 ± 5.5. They explained the super-exponential growth by cooperation: communication lets people form coalitions, so a bigger population lowers risk per person. Population left the curve in stages. The growth rate peaked in 1962–63. The actual growth rate fell below the rate the curve implies in about the mid-1970s. The population level, though, stayed "ahead of schedule" (above the curve) until roughly the early 1990s.

### Cited Findings
- **Citation and title.** Heinz von Foerster, Patricia M. Mora, Lawrence W. Amiot, "Doomsday: Friday, 13 November, A.D. 2026," *Science* 132(3436):1291–1295, published 4 November 1960. A secondary listing gives the subtitle "At this date human population will approach infinity if it grows as it has grown in the last two millennia." — [Birchenall, Science 2026 (via search extract)](https://www.science.org/doi/10.1126/science.ael8752); [ResearchGate listing](https://www.researchgate.net/publication/233822850_Doomsday_Friday_13_November_AD_2026_At_this_date_human_population_will_approach_infinity_if_it_grows_as_it_has_grown_in_the_last_two_millenia); [RPI course copy of the paper](https://www2.bioinfo.rpi.edu/bystrc/courses/biol4520/Doomsday.pdf)
- **Model and fitted parameters.**
  - VFMA start from births minus deaths, dN/dt = a1N − (a2N + bN²). They then replace the competitive (logistic) term with a cooperative nonlinearity whose constants are "determined experimentally". Their fit gives **a0 = 5.5×10⁻¹² and k = 0.99**, which yields N = N1[(t0 − t1)/(t0 − t)]^k. Setting k = 1 gives N = C/(t0 − t), equivalently dN/dt = N²/C. — [Korotayev & Malkov 2012, arXiv:1206.0496](https://arxiv.org/pdf/1206.0496)
  - Golosovsky restates the fit as "α ≈ 1, C = 1.8·10¹¹ and tc = 2026". — [Golosovsky 2009, arXiv:0910.3056](https://arxiv.org/pdf/0910.3056)
  - Yakovenko compares his refit to "the value 1.8 × 10¹¹ found in Ref. [1]". — [Yakovenko 2025, arXiv:2508.11038](https://arxiv.org/pdf/2508.11038)
- **The date and the ±5.5 years.** The formula solved to 2026.87 ± 5.5 years. The New York Times reported that von Foerster "searched the center of this doom-time span for an appropriate date and found that a Friday the Thirteenth would fall conveniently in November of 2026." 13 November was also von Foerster's birthday (born 1911). — [Euronews, 12 Nov 2026](https://www.euronews.com/2026/11/12/doomsday-studys-prediction-of-the-end-of-the-world-on-13-november-2026-fails); [Yakovenko 2025](https://arxiv.org/pdf/2508.11038) ("The particular day of 13 November was a joke, as it is the birthday of Heinz von Foerster")
- **NYT coverage, 4 Nov 1960:** "A physicist has put a definite date on Doomsday… He calculates that it will come on Friday the Thirteenth in November, 2026 A. D. On that date, or thereabouts, the human population will have expanded so far as to approach infi[nity]" — [News from Science on X, 2026](https://x.com/NewsfromScience/status/2110001368555524546)
- **Data.** VFMA used global population estimates from about 1 CE to 1958. — [Birchenall, Science 394:173–174 (2026) (via search extract)](https://www.science.org/doi/10.1126/science.ael8752)
- **Their mechanism: coalitions and communication.**
  - Competition in a limited environment lowers the growth rate. That reasoning may fail when the population's members "possess a system of communication which enables them to form coalitions", and especially when "all elements are so strongly linked that the population as a whole can be considered from a game-theoretical point of view as a single person playing a two-person game with nature as the opponent". — [Korotayev & Malkov 2012, quoting VFMA](https://arxiv.org/pdf/1206.0496)
  - Korotayev & Malkov gloss this as: the larger the population, the more natural risk falls and the higher the growth rate. — [same](https://arxiv.org/pdf/1206.0496)
- **What the date meant.** Korotayev & Malkov: "Of course, von Foerster and his colleagues did not imply that the world population on that day could actually become infinite. The real implication was that the world population growth pattern that was followed for many centuries prior to 1960 was about to come to an end and be transformed into a radically different pattern." — [arXiv:1206.0496](https://arxiv.org/pdf/1206.0496)
  - A 2026 Substack argues the paper was tongue-in-cheek and that von Foerster expected social or ecological limits, not a literal doomsday. — [heycityzen Substack](https://heycityzen.substack.com/p/prediction-misses-the-point-of-von)
  - The claim that von Foerster later wrote the singularity "should not be interpreted literally" circulates in a 2026 Substack ([voxdw](https://voxdw.substack.com/p/von-foerster-doomsday-115th-birthday)). I could not verify it against a primary source.
- **Published reactions (citations found; content mostly not retrieved).**
  - T. Shinbrot, "Doomsday," *Science* 133:940–943 (1961), followed by a VFMA rejoinder, "Doomsday," *Science* 133:943–946 (March 1961). — [Umpleby 1990 reference list, Population and Environment](https://link.springer.com/article/10.1007/BF01254115)
  - J. Serrin, "Is 'Doomsday' on target?" *Science* 189 (1975). — [same reference lists (via search extract)](https://link.springer.com/article/10.1007/BF01254115)
  - S. Umpleby, "World Population: Still Ahead of Schedule," *Science* 237(4822):1555–1556 (25 Sep 1987), and "The scientific revolution in demography," *Population and Environment* (1990). — [Umpleby 1990](https://link.springer.com/article/10.1007/BF01254115); [Umpleby publication list](https://blogs.gwu.edu/umpleby/83-2/)
  - Related 1961–62 *Science* items: "Population Density and Growth," *Science* 133(3468):1931, and "'Projections' versus 'Forecasts' in Human Population Studies," *Science* 136(3511):173. — [Science 133:1931](https://www.science.org/doi/10.1126/science.133.3468.1931); [Science 136:173](https://www.science.org/doi/10.1126/science.136.3511.173.b)
- **Growth-rate peak.** Our World in Data's current figure is 2.3% per year in 1963. Older OWID vintages give 2.2% in 1962–63, or 2.1% in 1962. Growth was under 1% by 2020 and is about 0.9% now. — [OWID data insight](https://ourworldindata.org/data-insights/global-population-growth-peaked-six-decades-ago); [OWID population growth over time](https://ourworldindata.org/population-growth-over-time); [Golosovsky 2009](https://arxiv.org/pdf/0910.3056) ("achieved its maximum value of ∼ 2.1% in 1962 and then was steadily decreasing")
- **Outcome.** By 1975 world population was about 4 billion. In 2010 it was about 7 billion, against about 11 billion predicted. "The law of hyperbolic growth ceased to operate in the 1960–1970s." — [Science news, Oct 2026 (via search extract)](https://www.science.org/content/article/will-world-end-next-month-science-said-so-1960); [Wikipedia: Law of hyperbolic growth](https://en.wikipedia.org/wiki/Law_of_hyperbolic_growth_of_the_human_population)
- **Birchenall's 2026 verdict:** the model "was not wrong mathematically, but it was historically contingent", and its error lay in treating transient demographic trends as universal laws. — [Science 394:173–174, 8 Oct 2026, DOI 10.1126/science.ael8752 (via search extract)](https://www.science.org/doi/10.1126/science.ael8752)

### Inferences
- **Growth rates the curve implies** (my computation, N = 1.79×10¹¹/(2026.87 − t)^0.99):

  | year | implied growth rate |
  |---|---|
  | 1960 | 1.48% |
  | 1963 | 1.55% |
  | 1975 | 1.91% |
  | 2000 | 3.68% |
  | 2020 | 14.4% |
  | 2025 | 52.9% |

  With k = 1 the figures are 1.50%, 3.72%, 14.56% and 53.5%. So the ChatGPT figures (≈1.5%, 3.7%, 14.6%, 53%) are correct for k = 1.
- **Levels the curve implies** (my computation): 2.79 bn (1960), 3.59 bn (1975), 4.66 bn (1987), 5.03 bn (1990), 5.81 bn (1995), 6.88 bn (2000), 10.9 bn (2010), 26.6 bn (2020), 96 bn (2025), about 480 bn by mid-2026.
- **"Left the curve" has three different dates.** I compared the curve with approximate UN World Population Prospects values I did not re-fetch: about 3.0 bn in 1960, 4.07 bn in 1975, 5.0 bn in 1987, 5.3 bn in 1990, 5.7 bn in 1995, 6.15 bn in 2000, 7.0 bn in 2010 and 7.8 bn in 2020.
  - **Growth rate:** the peak was 1962–63. The actual rate (about 2.1–2.3%) was then above the curve's implied 1.55%. Actual growth fell below the curve's implied rate around the mid-to-late 1970s.
  - **Level:** the 1960 curve sits below the modern 1960 estimate, so the population stayed above ("ahead of") the curve until roughly 1993–95. This matches the title of Umpleby's 1987 *Science* letter. A search extract also reported that the fit held "until about 1993", citing MacEachern, but the underlying source was not identified, so treat this as unverified.
  - **Absolute increment:** dN/dt on the hyperbola keeps rising as N²/C. The actual annual increment peaked in the late 1980s (from memory, not re-fetched).
  - **Upshot:** "population left the trend soon after 1960" is right for the growth rate. For the level it is a 1990s event. The report should say which metric it means.
- **Before the Q2 refits.** Yakovenko's 2025 refit (ts = 2030, C = 2.63×10¹¹) passes above the VFMA curve. So the curve's position, and therefore the date population "left" it, depends on which fit you use (see Q2).

### Gaps
- The content of Shinbrot (1961), Serrin (1975) and the VFMA replies was not retrieved. Science's archive was blocked and the search budget ran out. Their arguments (for example, whether Serrin found the curve still "on target" in 1975) are unverified.
- I could not confirm from the primary text the exact C (1.79×10¹¹) together with the ±5.5-yr interval as VFMA printed them. Secondary sources give C ≈ 1.8×10¹¹ and the ±5.5 years.
- I could not check the exact data table (number and sources of estimates, 1 CE–1958) in the original paper.

## Q2. Successor models: Kapitza, Kremer, Korotayev et al., Johansen & Sornette, Hanson, Roodman (plus 2025 refits)

### Takeaway
Every successor model reproduces super-exponential growth up to about the 1960s–70s. They split on three questions: the mechanism (Kremer's nonrival ideas against cooperation or information networks), what happens next (saturation for Kapitza, Korotayev and Yakovenko; a transition to a new regime for Johansen & Sornette and Hanson; a stochastic explosion with median 2047 for Roodman), and the date. Fitted "singularity" dates run from 2005 to 2078 depending on the series, window and functional form.

### Cited Findings
**Kremer (1993)**
- "Population Growth and Technological Change: One Million B.C. to 1990," *QJE* 108(3):681–716. "The nonrivalry of technology, as modeled in the endogenous growth literature, implies that high population spurs technological change." The model "predicts that over most of history, the growth rate of population will be proportional to its level." Cross-region test: "among societies with no possibility for technological contact, those with larger initial populations have had faster technological change and population growth." — [Kremer 1993 (via search extract)](https://econpapers.repec.org/RePEc:oup:qjecon:v:108:y:1993:i:3:p:681-716.); [gwern PDF](https://gwern.net/doc/economics/1993-kremer.pdf)
- **Equations, as restated by Johansen & Sornette.**
  - Assumptions: output per person is fixed at subsistence, Y/L = ȳ; Y = Y0[A L]^(1−α); dA/dt = B L A, "embodying the concept that a larger population offers more opportunities for finding exceptionally talented-people".
  - Result: dL/dt = ((1−α)/α) B L², a finite-time singularity with exponent z = −1.
  - Kremer used population estimates back to 1 million B.C. and showed "the population growth rate is approximately linearly increasing with the population".
  - The theory "predicts…that in the historical times when regions were separated, technological progress was faster in regions with larger population, thus explaining the differences between Eurasia-Africa, the Americas, Australia and Tasmania." — [Johansen & Sornette 2001, arXiv:cond-mat/0002075](https://arxiv.org/pdf/cond-mat/0002075v4)
- Kremer's table runs from 1,000,000 B.C. The 25,000–10,000 B.C. growth rate uses Deevey's estimates. — [Kremer 1993 (via search extract)](https://gwern.net/doc/economics/1993-kremer.pdf)

**Kapitza (1996)**
- S. P. Kapitza, "The phenomenological theory of world population growth," *Physics–Uspekhi* 39:57–71 (*UFN* 166:63–80). Its premises: growth rate ∝ N² (self-similarity); a "large parameter" (the effective size of a coherent population group, about 10⁵); a microscopic parameter (human lifespan). It projects stabilisation at about 14 billion as a "systemic" effect, not a resource limit. — [UFN abstract](https://ufn.ru/en/articles/1996/1/c/); [Mathnet](https://mathnet.ru/eng/ufn1146)
- Kapitza's regularisation: dN/dt = C/[(tc − t)² + τ²], with τ "the lifespan of a generation, ∼45 years". — [Golosovsky 2009](https://arxiv.org/pdf/0910.3056)
- Kapitza predicted the peak of dN/dt around 2007 and later revised it to 2000, after the peak had passed. Yakovenko argues the arccot solution does not fit the data. — [Yakovenko 2025](https://arxiv.org/pdf/2508.11038)

**Korotayev and colleagues (compact macromodels)**
- Korotayev & Malkov propose a model that accounts for "more than 99 per cent of all the variation in economic and demographic macrodynamics of the world for almost two millennia".
  - World population 1–1973 CE fits the simple hyperbola with R² = .9991.
  - World GDP 1–1973 (Maddison) fits a quadratic hyperbola G = C/(t0 − t)² better (R² = .9986, against .9956 for the simple hyperbola).
  - Had VFMA had Maddison's GDP, "they could have made another striking 'prediction' – that on Saturday, 23 July, 2005 an 'economic doomsday' would take place". — [Korotayev & Malkov, arXiv:1206.0496](https://arxiv.org/pdf/1206.0496)
- Their demographic-transition mechanism: above about $3,500 GDP per capita, "the growth of such variables as education (and especially female education)…family planning…leads to a sharp decline of birth rates." — [same](https://arxiv.org/pdf/1206.0496)
- Golosovsky's tests of the Korotayev–Malkov–Khaltourina models.
  - The models fit until about 1960. The population growth rate rises linearly with N up to a maximum of 0.021 at N ≈ 3×10⁹. The "surplus product" growth rate peaks at 0.04 at the same N.
  - He argues the demographic transition "has already taken place in 1960-1970, rather than to occur in 2026-2040", and calls it a global phase transition. — [Golosovsky 2009](https://arxiv.org/pdf/0910.3056)
- Korotayev's "21st Century Singularity" (Journal of Big History, 2018) finds the Kurzweil–Modis macroevolution milestone series fits a singularity "in the region of 2027" (2029 in one version), matching Panov (2003). Panov's 19 phase transitions shrink by a ratio of about 2.67 each and give 2027. — [JBH 2018](https://jbh.journals.villanova.edu/index.php/JBH/article/download/2329/2251?inline=1); [search extract](https://www.sociostudies.org/almanac/articles/the_21st_century_singularity_in_the_big_history_per-spective-_a_re-analysis/)
- **Korotayev 2026, *Cliodynamics*,** "Doomsday: Friday, 13 November, A.D. 2026. Demographic-Technological Positive Feedback, Hyperbolic Acceleration of the Global Complexity Growth, and the 21st Century Singularity," DOI 10.21237/C7CLIO.68947.
  - Panov's series and VFMA's population are both governed by y = C/(2027 − t).
  - The 21st century is "singular" not because acceleration continues: "evidence suggests a similar deceleration has commenced in global techno-scientific and economic growth rates." — [academia.edu (via search extract)](https://www.academia.edu/178741773/Doomsday_Friday_13_November_A_D_2026_Demographic_Technological_Positive_Feedback_Hyperbolic_Acceleration_of_the_Global_Complexity_Growth_and_the_21st_Century_Singularity_corrected_final_version_)

**Johansen & Sornette (2001)**
- "Finite-time singularity in the dynamics of the world population, economic and financial indices," *Physica A* 294:465–502. Data: UN population for 0–1998; DeLong's world GDP for 0–1998, "given to us by R. Hanson". Both growth rates "are compatible with a spontaneous singularity occuring at the same critical time 2052 ± 10 signaling an abrupt transition to a new regime." — [arXiv:cond-mat/0002075v4](https://arxiv.org/pdf/cond-mat/0002075v4)
- **Fits.**
  - A simple power law fitted to population (0–1998) gives "tc ≈ 2078 and z ≈ −1.9".
  - Dow Jones: tc ≈ 2068; S&P: tc ≈ 2067.
  - Log-periodic fits to population give tc ≈ 2056 (ω ≈ 6.3, z ≈ −1.39). Dropping early points shifts this to 2053. Across 7 of 8 data subsets, tc stays within "2052 ± 10 years".
  - A Dow Jones fit over 210 years gives tc ≈ 2053.
  - "Varying tc from 2030 to 2050, illustrate the large uncertainty in its determination." — [same](https://arxiv.org/pdf/cond-mat/0002075v4)
- **Interpretation.** "Singularities are always mathematical idealisations…they are not present in reality but foreshadow an important transition or change of regime."
  - The post-1970 deceleration "is compatible with the concept of a finite-time singularity in the presence of so-called 'finite size effects'". Population growth "topped in 1970…approximately 80 years from the predicted critical point".
  - The data "all point to the existence of an end to the present era, which will be irreversible and cannot be overcome by any novel innovation of the preceding kind".
  - Their multivariate Romer-type model blows up when θ + β > 1 "even when each of these factors in isolation does not." — [same](https://arxiv.org/pdf/cond-mat/0002075v4)

**Hanson (1998/2000): "Long-Term Growth As A Sequence of Exponential Modes"**
- Fits DeLong's world product as a sum of exponential modes (hunting, farming, industry). "Each exponential mode grew over one hundred times faster than its predecessor." He "plots the logarithm of the world product as a function of the logarithm of tc − t with tc = 2050 and find a reasonable straight line decorated by oscillations". — [Johansen & Sornette summary of Hanson](https://arxiv.org/pdf/cond-mat/0002075v4)
- **Hanson's page (via search extract).** Current doubling time is roughly 6–15 years: about 6 for the new mode, about 15 while the transition is still under way. A new mode could bring a doubling time as short as about two weeks, "possibly within the next century". The abstract says a new mode "might appear with a doubling time measured in days, not years." — [Hanson longgrow page](https://mason.gmu.edu/~rhanson/longgrow.html); [Stafforini summary](https://stafforini.com/works/hanson-2000-longterm-growth-sequence/)
- Roodman, "Revisiting Hanson's 'Long-Term Growth as a Sequence of Exponential Modes'" (SSRN 4074164, 2022): the industrial mode's doubling time is about 6.3 years once the current transition finishes, and a new mode could shrink it to weeks or days. — [SSRN (via search extract)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4074164)
- **Hanson 2001, "Economic Growth Given Machine Intelligence"** (abstract): "At first, complementary effects dominate, and human wages rise with computer productivity. But eventually substitution can dominate, making wages fall as fast as computer prices now do. An intelligence population explosion makes per-intelligence consumption fall this fast, while economic growth rates rise by an order of magnitude or more." — [PhilPapers](https://api.philpapers.org/rec/HANEGG); [Stafforini](https://stafforini.com/works/hanson-2001-economic-growth-given/)
  - Erdil & Besiroglu summarise: output grows "at a familiar 4.3% per year" before machine intelligence, then at roughly the rate computing capacity improves ("40% per year in Hanson 2001"). — [arXiv:2309.11690](https://arxiv.org/pdf/2309.11690v3)

**Roodman (2020): "Modeling the Human Trajectory" / "On the probability distribution of long-term changes in the growth rate of the global economy"**
- **Model.** GWP since 10,000 BCE is treated as a sample path of a stochastic diffusion, "novel yet rooted in neoclassical growth theory". "Most empirical observations lie between the 40th and 60th percentiles of modeled distributions." — [Semantic Scholar abstract](https://www.semanticscholar.org/paper/Modeling-the-Human-Trajectory-Roodman/e146ce62e0ebcf9c2575b31ded2d65b04adfe68d); [Coefficient Giving page](https://coefficientgiving.org/research/modeling-the-human-trajectory/)
- **Misses.** The industrial revolution and the period after it ran above the 90th percentile. "The past 30 years have seen anomalously lower growth, around the 25th percentile." — [Alignment Newsletter #105](https://mailchi.mp/be2a0d160fa2/an-105-the-economic-trajectory-of-humanity-and-what-we-might-mean-by-optimization)
- **Prediction.** Extrapolating the trend gives "extremely rapid economic growth, approaching infinite GWP as we near the year 2047". Conditional on 2019 GWP, the median explosion year is 2047, and the probability of no eventual explosion is reported as about 10⁻⁶⁹. Roodman says he hoped the stochastic model would make infinite GWP "*possible* but not *inevitable*"; he reads the fit as showing "the human system is unstable". He credits von Foerster: explosion is "an inevitable implication of the straight-line model of history in that paper". — [EA Forum crosspost](https://forum.effectivealtruism.org/posts/2TqrRkXRmkpnSQu5b/modeling-the-human-trajectory-open-philanthropy); [gwern PDF of the paper (via search extract)](https://gwern.net/doc/economics/automation/2020-roodman.pdf)
- **Earlier fits.** EA Forum discussion lists the median explosion date the model gives with data up to each decade. With data to 1960 the median is about 2020 (spread about 60 years), and for recent decades the model "has consistently predicted a median…several decades ahead". — [EA Forum posts on Roodman's model (which post was not verified)](https://forum.effectivealtruism.org/posts/RuPKfSELEC2nXYX57/how-roodman-s-gwp-model-translates-to-tai-timelines)
- **Exponent.** A LessWrong post says Roodman's stochastic fit gives a hyperbolic exponent B ≈ 0.5. — [LessWrong "Hyperbolic takeoff"](https://www.lesswrong.com/posts/etgJYbkvvkBoDRm4k/hyperbolic-takeoff) (not confirmed from the paper)
- **Code and data:** an archive is at [GitHub michaeldickens/Modeling-Human-Trajectory](https://github.com/michaeldickens/Modeling-Human-Trajectory), which also fits hyperbolas over different windows.

**2025 refits and other recent models**
- **Yakovenko (arXiv:2508.11038, Aug 2025)**, using OWID (HYDE 3.3 before 1800) and World Bank data for 10,000 BCE–2023.
  - Population first grew exponentially with T = 2080 yr. Around 1700 it entered "the hyperbolic regime as N(t) ∝ (ts − t)⁻¹ with the extrapolated singularity year ts = 2030, which is close to the prediction by von Foerster et al." C_HB = 2.63×10¹¹ person-years.
  - The hyperbolic regime holds "since the year 1700, not during all of human history". He links it to the Industrial Revolution and fossil fuels.
  - After 2000, 1/N shows "avoided crossing". He predicts "a peak in human population at ts = 2030 of the time width τ = 32 years", with Nmax = 8.23 billion.
  - Johansen & Sornette's exponents for tc = 2030/2040/2050 (α = 0.88/1.01/1.14) are "consistent with a simple hyperbolic law". — [arXiv:2508.11038](https://arxiv.org/pdf/2508.11038)
- **Bellina, De Marzo & Loreto (arXiv:2411.03394, v2 Mar 2025).**
  - Macroevolution rates fit ρ = 2.054/(2029 − t) for Canonical Milestones and 1.886/(2027 − t) for Biological Transitions; population fits t* ≈ 2026.
  - "The discrete versions of the models, which typically represent the actual dynamics of real-world systems, do not exhibit any singularity", which "makes the singularity value practically unrelated to any constraints". — [arXiv:2411.03394](https://arxiv.org/pdf/2411.03394)
- **Nielsen (arXiv:1710.07928)**, a contrarian view: population and economic growth "were hyperbolic in the past 2,000,000 years"; from about 1950 they "started to be diverted to slower trajectories but they are still close to the historical hyperbolic trajectories". — [arXiv:1710.07928](https://arxiv.org/pdf/1710.07928)

### Inferences
- **Spread of published "singularity" dates** (all cited above): 2005 (GDP, Korotayev–Malkov), 2026.87 ± 5.5 (VFMA), 2027 (Panov; Korotayev; biological transitions), 2029 (canonical milestones), 2030 (Yakovenko), 2047 (Roodman, median), 2050 (Hanson's illustrative tc), 2052 ± 10 (Johansen–Sornette log-periodic), 2053/2056 (Johansen–Sornette subsets and Dow Jones), 2067/2068 (S&P, Dow Jones power law), 2078 (Johansen–Sornette simple power law on population).
  - The late-2020s cluster comes from population and milestone series. GWP-based and log-periodic fits put the date mid-century.
- **The GDP hyperbola failed faster than the population one** (my computation). The Korotayev–Malkov GDP fit (t0 = 23 Jul 2005, exponent 2) implies world GDP growth of 4.4% in 1960, 6.1% in 1973, 12.9% in 1990 and 36% in 2000. World growth stayed around 3–5%.
- **Mechanisms differ even though the curves agree.** VFMA: cooperation. Kremer: nonrival ideas × population. Kapitza: information exchange (∝ N²). Yakovenko: fossil energy since 1700. Johansen–Sornette: generic critical phenomena. A matching curve does not single out a mechanism, which weakens any argument that "the variable behind the curve was X".

### Gaps
- Kapitza's numerical constants are not verified: commonly cited values are C ≈ 1.86×10¹¹, T1 ≈ 2025 and τ ≈ 42–45 yr (only τ ∼ 45 yr is confirmed here, via Golosovsky).
- Hanson's per-mode doubling times are not verified: commonly cited values are about 224,000 yr (hunting), about 909 yr (farming) and about 6.3 yr (industry); only 6.3 yr appears, in Roodman's 2022 revisit. His exact text on when the next mode arrives was not read.
- Roodman's exact parameter estimates (B, s, δ, σ), the "8-year standard error" mentioned in one extract, and his own written view of the post-1960 deviation were not read directly.
- The full Korotayev 2026 *Cliodynamics* paper was not read.

## Q3. The AGI connection: Davidson; Aghion, Jones & Jones; Trammell & Korinek; Erdil & Besiroglu; GATE; Nordhaus; Galor–Weil; Jones; Bloom et al.; and 2026 additions

### Takeaway
The economics literature does turn the hyperbola into a conditional AGI prediction, and the conditional is explicit. Semi-endogenous growth models say growth was super-exponential while research input (people) was itself produced by output. They say it stopped when the demographic transition broke that link, and that it would resume if AI makes research and production labor accumulable. The counterweights are diminishing returns to ideas (Bloom et al.), Baumol bottlenecks (Aghion–Jones–Jones), Nordhaus's negative empirical tests, and 2026 calibrations finding that AI feedback loops are not yet self-sustaining.

### Cited Findings
- **Davidson (2021), "Could Advanced AI Drive Explosive Economic Growth?"** (Open Philanthropy, now Coefficient Giving). It defines explosive growth as GWP growth above 30% per year.
  - Mechanism: an ideas loop (more ideas → more output → more people/AIs → more ideas). "Before 1880, the ideas feedback loop led to super-exponential growth." The loop broke when more output stopped turning into more people. AI could restart it.
  - Davidson "tentatively assigns a 30% probability to explosive growth this century, conditional on the development of sufficiently advanced AI systems." — [Coefficient Giving report page](https://coefficientgiving.org/research/could-advanced-ai-drive-explosive-economic-growth/); [PDF](https://coefficientgiving.org/wp-content/uploads/Could-Advanced-AI-Drive-Explosive-Economic-Growth_.pdf); [Erdil & Besiroglu summary](https://arxiv.org/pdf/2309.11690v3)
  - A review by Benjamin Jones exists. — [EA Forum](https://forum.effectivealtruism.org/posts/aKR2iPhtapCtEaDjS/benjamin-jones-review-of-could-advanced-ai-drive-explosive)
- **Erdil & Besiroglu, "Explosive growth from AI automation: A review of the arguments"** (arXiv:2309.11690; v1 20 Sep 2023, v3 15 Jul 2024).
  - "Standard models of economic growth consistently predict explosive growth when AI can effectively substitute for human labor across a majority or all economic tasks." Their conclusion: "explosive growth seems plausible with AI capable of broadly substituting for human labor", but high confidence is unwarranted.
  - Davidson's mechanism, as they state it: AI "could rekindle the increasing returns to accumulable inputs like technology, which historically led to super-exponential growth until the demographic transition around 1900." — [arXiv:2309.11690](https://arxiv.org/pdf/2309.11690v3)
  - **Key condition.** With Y = AK^β and (1/A)dA/dt ∝ A^−ϕ I_A^λ, "as long as λ/ϕ + β > 1, the economy exhibits increasing returns, which implies that such an economy will grow hyperbolically". Bloom et al. imply λ/ϕ ≈ 0.32 for US TFP, so "hyperbolic growth occurs with values of β as low as 1 − 0.32 = 0.68". — [same](https://arxiv.org/pdf/2309.11690v3)
  - **Their Table 1 on semi-endogenous theory.** It predicts "Economic growth acceleration under Malthusian conditions" (citing Kremer 1993) and "Non-increasing growth in global output in the mid-20th century concurrent with the observed slowing rates of population growth" (citing C. I. Jones 2022). Maximum long-run growth should be "on the order of 3% per year". In Appendix C, with ϕ = 0.8, γ = 0.2, α = 0.3, steady-state growth g_y ≈ 1.5n, so growth is capped near population growth. — [same](https://arxiv.org/pdf/2309.11690v3)
  - **Bottlenecks.** Applying Laplace's rule to past accelerations gives "a probability of ∼ 40%" that a new bottleneck appears before world growth rises tenfold. Energy and land leave at least 2 orders of magnitude of room. — [same](https://arxiv.org/pdf/2309.11690v3)
- **Aghion, Jones & Jones (2017), "Artificial Intelligence and Economic Growth"** (NBER w23928; published 2019 in Agrawal, Gans & Goldfarb, eds.).
  - Type I explosion: growth rates rise without bound but stay finite. Type II: "infinite output is achieved in finite time".
  - Automating ideas production, Ȧ ∝ A^(1+φ), gives "a true (Type II) singularity for φ > 0", with blow-up date t* = 1/(φA0^φ).
  - Baumol theme: growth is constrained "not by what we are good at but rather by what is essential and yet hard to improve"; essential physical tasks can block explosion. — [NBER slides](https://conference.nber.org/confer/2018/YSAIf18/Jones.pdf); [NBER w23928](https://www.nber.org/system/files/working_papers/w23928/w23928.pdf)
- **Trammell & Korinek, "Economic Growth under Transformative AI"** (GPI 2020; NBER w31815, Oct 2023, revised Sep 2025; *Annual Review of Economics* 18:589–611, 2026). "Fully automating production alone (so that machines can self-replicate) would dramatically raise the growth rate and lower the labor share…Automating R&D (so that machines can self-improve) would accelerate the transformation, but may not produce it in isolation." Wages may rise or fall. — [NBER w31815](https://www.nber.org/papers/w31815)
- **Epoch's GATE model** (arXiv:2503.04941, v2 12 Mar 2025). An integrated assessment model with "semi-endogenous growth through hardware and software R&D" and adjustment costs. It keeps TFP exogenous because endogenising TFP "would also, under many parameter values, introduce hyperbolic growth dynamics, which imply unbounded future consumption and are thus challenging to analyze". — [arXiv:2503.04941](https://arxiv.org/pdf/2503.04941)
- **Nordhaus, "Are We Approaching an Economic Singularity? Information Technology and the Future of Economic Growth"** (NBER w21547, 2015; *AEJ: Macroeconomics* 13(1):299–332, 2021).
  - Abstract: "the tests suggest that the Singularity is not near."
  - Hanson's reading of the results: four of six tests "are rejected by our best estimates having the opposite sign", and the two that match imply "a century or more before growth rates exceed 20% per year". — [NBER](https://www.nber.org/papers/w21547); [Overcoming Bias "Failed Singularity Model"](https://www.overcomingbias.com/p/failed-singularity-modelhtml)
  - Stanford's Digital Economy Lab now runs a "Tracking the economic singularity" indicator tracker built on these tests. — [Stanford DEL](https://digitaleconomy.stanford.edu/project/indicators/takeoff-tracker/)
- **Bloom, Jones, Van Reenen & Webb, "Are Ideas Getting Harder to Find?"** (*AER* 110(4), 2020; NBER w23782, 2017).
  - The number of researchers needed to keep chip density doubling every two years "is more than 18 times larger than the number required in the early 1970s."
  - "Research productivity for the aggregate U.S. economy has declined by a factor of 41 since the 1930s, an average decrease of more than 5% per year." These figures are from the 2017 working paper.
  - "Exponential growth results from the large increases in research effort that offset its declining productivity." — [NBER w23782](https://www.nber.org/papers/w23782.pdf)
- **C. I. Jones on semi-endogenous growth.** "The past and future of economic growth: A semi-endogenous perspective," *Annual Review of Economics* (2022), cited by Erdil & Besiroglu as explaining mid-20th-century non-acceleration. — [reference in arXiv:2309.11690](https://arxiv.org/pdf/2309.11690v3)
- **C. I. Jones (2026), "A.I. and Our Economic Future,"** *JEP* 40(3):3–22 (Summer 2026); NBER w34779, Jan 2026. It frames two extremes, fast growth and "business as usual"; "Both scenarios are plausible, and the future will presumably lie somewhere between these extremes." Per the JEP managing editor's summary, even AI substituting for 50% of inputs gives limited growth effects, "modest for a decade or two at least". — [Jones PDF](https://web.stanford.edu/~chadj/AIandEconomicFuture.pdf); [Conversable Economist, Aug 2026](https://conversableeconomist.com/2026/08/07/growth-effects-of-ai-modest-for-a-decade-or-two-at-least/)
- **Cunningham, Althoff, Halperin, Jabarian, Koh, Ramani, Trammell, Whitfill & Wu (2026), "The Economics of Recursive Self-Improvement"** (arXiv:2609.15802, 14 Sep 2026).
  - Acceleration "depends on the product of elasticities across each feedback loop". Self-sustaining acceleration needs "a one-unit increase in AI model capabilities [to result] in at least 15% higher AI R&D productivity" (measured with Epoch's Capabilities Index).
  - Their estimate since coding agents arrived is about 9%, "suggesting we are not experiencing a self-sustaining acceleration", though the return "has been increasing of late".
  - They define "intelligence explosion" as capabilities going "to infinity in finite time". — [arXiv:2609.15802](https://arxiv.org/pdf/2609.15802)

### Inferences
- **The AGI reading is a conditional, not a forecast from the curve.** It is the move from "population was the research input" (Kremer) to "AI is the new accumulable research input" (Davidson; Erdil & Besiroglu; Trammell & Korinek). The literature predicts the regime ("super-exponential if AI substitutes broadly for labor"), not the date. None of these economists derives a date from von Foerster's t0.
- **Frontier versus world timing.** Davidson dates the break around 1880–1900 (frontier economies, where income stopped producing more people). The world population curve held until the 1960s. The two fit together because the hyperbola is a world aggregate, and the transition spread from the frontier to the world over about 80 years.
- **GATE's choice is informative.** Epoch's own integrated model keeps TFP exogenous precisely because endogenous TFP generates hyperbolic blow-up. Hyperbolic growth is a generic property of these models that modellers deliberately turn off, not a fitted result.

### Gaps
- Galor & Weil's unified growth theory (*AER*, 2000) was not retrieved, nor were Galor's later statements on whether post-transition growth could re-accelerate.
- Davidson's report could not be read directly. Its exact probabilities and its treatment of Roodman's model and the demographic transition come from secondary extracts.
- Nordhaus's six tests could not be read individually. The "century or more" figure is Hanson's reading.
- The AER 2020 version of Bloom et al. was not checked for changes from the 2017 numbers.

## Q4. Is there any variable that kept growing hyperbolically (growth rate ∝ 1/(t0 − t)) from 1960 to now? Has anyone spliced human and machine cognition into one series?

### Takeaway
No retrieved source shows any aggregate series (GWP, population, research productivity, or information processing) whose growth rate has kept rising as 1/(2026.87 − t) since 1960. Several sources state the reverse. Computing grows fast but as an exponential within regimes, with a step up around 2010. I found no published series that splices human and machine cognitive capacity into one curve tested against the hyperbola. The nearest things are Erdil & Besiroglu's "total effective workforce" and Hilbert & López's comparison of global computation to brains.

### Cited Findings
- **GWP.** The last 30 years ran around the 25th percentile of Roodman's model, i.e. "anomalously lower growth". — [Alignment Newsletter #105](https://mailchi.mp/be2a0d160fa2/an-105-the-economic-trajectory-of-humanity-and-what-we-might-mean-by-optimization)
  - "Non-increasing growth in global output in the mid-20th century". — [Erdil & Besiroglu Table 1, citing Jones 2022](https://arxiv.org/pdf/2309.11690v3)
  - The world surplus-product growth rate peaks at 0.04 around N ≈ 3×10⁹ (1960–70) and then decreases. — [Golosovsky 2009](https://arxiv.org/pdf/0910.3056)
- **Techno-scientific and economic growth rates.** "A similar deceleration has commenced in global techno-scientific and economic growth rates". — [Korotayev 2026 (via search extract)](https://www.academia.edu/178741773/Doomsday_Friday_13_November_A_D_2026_Demographic_Technological_Positive_Feedback_Hyperbolic_Acceleration_of_the_Global_Complexity_Growth_and_the_21st_Century_Singularity_corrected_final_version_)
- **Research productivity** falls about 5%+ per year, and growth is kept up only by rising research effort. — [Bloom et al. NBER w23782](https://www.nber.org/papers/w23782.pdf)
- **Information processing (Hilbert & López, *Science* 332:60, 2011).**
  - General-purpose computing capacity grew 58% per year (1986–2007), doubling about every 18 months; application-specific capacity doubled about every 14 months. A 2012 paper gives 61% per year (general-purpose) and 86% (application-specific).
  - "The 6.4 × 10¹⁸ instructions per second that humankind can carry out on its general-purpose computers in 2007 are in the same ballpark as the maximum number of nerve impulses executed by one human brain per second (10¹⁷)." — [Hilbert & López PDF](https://pdodds.w3.uvm.edu/files/papers/others/2011/hilbert2011a.pdf); [AAAS summary](https://www.aaas.org/news/science-researchers-take-inventory-worlds-information-capacity); [IJoC 2012](https://ijoc.org/index.php/ijoc/article/viewFile/1562/742)
- **AI training compute** (Sevilla et al., arXiv:2202.05924, 2022). Before 2010 it doubled roughly every 20 months (Moore's law). From the early 2010s it doubled roughly every 6 months. A "Large-Scale Era" from late 2015 brought models with 10–100× more compute. — [arXiv:2202.05924](https://arxiv.org/abs/2202.05924)
- **Splicing human and machine workers.** Erdil & Besiroglu argue AI "could dramatically expand the total effective workforce by combining human and artificial workers" (a model of growth in the stock of digital workers). They do not build a historical spliced series. — [arXiv:2309.11690](https://arxiv.org/pdf/2309.11690v3)
- **Patents** grow exponentially, not hyperbolically, against the number of technological codes. — [Bellina et al. 2025](https://arxiv.org/pdf/2411.03394)

### Inferences
- **What the curve demands** (my computation). For an "effective population" to stay on VFMA's curve, it must reach about 26.6 bn person-equivalents in 2020, 96 bn in 2025, about 205 bn in 2026, and diverge by late 2026. Against about 7.8–8.2 bn humans, machines would have to supply about 19 bn person-equivalents in 2020 and about 88 bn in 2025.
- **No constant-rate exponential can track a hyperbola to t0** (my computation). The hyperbola's growth rate k/(t0 − t) overtakes any constant rate g at t = t0 − k/g. For g = 58% per year (Hilbert & López) that happens in 2025.2. For g = 100% it happens in 2025.9. For g = 150% (roughly the 2010s training-compute rate) it happens in 2026.2.
  - So even the fastest-growing compute series would need its own growth rate to accelerate to stay on the curve at the end of 2026.
  - The steelman therefore needs a genuinely self-accelerating machine component (recursive self-improvement). The 2026 calibration says this is not yet happening (about 9% against a 15% threshold; [Cunningham et al.](https://arxiv.org/pdf/2609.15802)).
- **The splice is dominated by its conversion factor.** In 2007 all general-purpose computers together matched the nerve-impulse rate of about 64 brains (6.4×10¹⁸/10¹⁷, Hilbert & López), against about 6.6 bn human brains. A splice is therefore human-dominated through at least the 2000s, and its 1960–2010 shape is essentially the population curve, which was not hyperbolic after the 1960s.
  - When machines "take over" depends almost entirely on the assumed FLOP-per-brain (estimates span several orders of magnitude) and on how training compute is credited against inference compute. With compute growing about 1 order of magnitude every 2–5 years, that freedom moves the crossover date by a decade or more. That is a garden of forking paths, not a test.
- **Training compute is not on the curve either.** Its growth rate jumped (about 0.4/yr to about 1.4/yr in log terms) around 2010, far above the curve's implied 5.9% in 2010. It is a separate, steeper exponential, not a continuation of the hyperbola. Only a weighted mixture of slow human input and fast machine input could mimic a 1/(t0 − t) growth-rate path, and the weights would be fitted after the fact.

### Gaps
- No retrieved source estimates total installed compute in human-brain equivalents over 1960–2026 (for example AI Impacts or Epoch estimates of global FLOP/s). The search budget ran out before this could be checked.
- No retrieved source tests the number of researchers, global R&D spending, or "effective research labor" (human researchers weighted by education, plus AI) against a hyperbola since 1960. UNESCO and OECD researcher counts were not retrieved.
- I found no paper that explicitly splices human and machine cognition into one historical series and fits a finite-time singularity to it. Absence from this search is weak evidence that none exists.

## Q5. Steelman and critique: is von Foerster's 2026 hyperbola "really" an AGI prediction?

### Takeaway
**Steelman.** The hyperbola is the signature of a feedback loop: output creates research input, and research input creates ideas that raise output. That is well grounded in semi-endogenous growth theory, and Roodman's stochastic model treats the post-1960 slowdown as a plausible deviation on a path that explodes with median 2047. If AI restores the loop, the curve's prediction of a regime change "around now" could be vindicated in spirit.

**Critique.** Nothing measured stayed on the curve. The date moves by decades with the series and window. The proxy reinterpretation is post hoc and can absorb any outcome. Diminishing returns and bottlenecks are documented. And 13 November 2026 has passed with no visible explosion, with 2026 calibrations finding AI feedback below the self-sustaining threshold.

### Cited Findings
**For the steelman**
- **Mechanism.** Semi-endogenous growth "performs relatively well in explaining growth under Malthusian conditions, the constancy of recent growth rates, as well as maximum long-term growth rates". It "robustly predicts explosive growth from AI that suitably substitutes for human labor". — [Erdil & Besiroglu](https://arxiv.org/pdf/2309.11690v3)
- **Demographic transition as the break.** The ideas feedback loop drove super-exponential growth before about 1880, then broke when output stopped producing more people. — [Davidson report](https://coefficientgiving.org/research/could-advanced-ai-drive-explosive-economic-growth/)
- **Stochastic tolerance.** Most of history lies at the 40th–60th percentiles of Roodman's model. The recent 30 years sit at about the 25th percentile, not outside the distribution. The median explosion is 2047. — [Roodman abstract](https://www.semanticscholar.org/paper/Modeling-the-Human-Trajectory-Roodman/e146ce62e0ebcf9c2575b31ded2d65b04adfe68d); [AN #105](https://mailchi.mp/be2a0d160fa2/an-105-the-economic-trajectory-of-humanity-and-what-we-might-mean-by-optimization)
- **Regime change, not infinity.** "Finite-size effects" round off the singularity, and "mankind is entering in the critical region towards a transition to a new regime". The transition "cannot be overcome by any novel innovation of the preceding kind". — [Johansen & Sornette](https://arxiv.org/pdf/cond-mat/0002075v4)
- **Interacting variables.** Interplay between variables "may produce an 'explosion'…even though the individual dynamics do not". — [Johansen & Sornette](https://arxiv.org/pdf/cond-mat/0002075v4)
- **Modes.** Each new mode runs more than 100× faster than the last. The next might double world output in weeks. — [Johansen & Sornette summary of Hanson](https://arxiv.org/pdf/cond-mat/0002075v4); [Hanson](https://mason.gmu.edu/~rhanson/longgrow.html)
- **Convergent dates.** Independent macroevolution series (Panov; Kurzweil–Modis milestones) fit singularities at 2027–2029, matching VFMA. — [Korotayev JBH 2018](https://jbh.journals.villanova.edu/index.php/JBH/article/download/2329/2251?inline=1); [Bellina et al.](https://arxiv.org/pdf/2411.03394)
- **The newest input is accelerating.** Training-compute doubling went from about 20 months to about 6 months around 2010. — [Sevilla et al.](https://arxiv.org/abs/2202.05924)
  - Returns from AI to AI R&D productivity are rising: about 9% now against a 15% threshold. — [Cunningham et al. 2026](https://arxiv.org/pdf/2609.15802)
- **Bloom et al. do not by themselves block the explosion.** With λ/ϕ ≈ 0.32, hyperbolic growth needs returns to accumulable inputs of only about 0.68 or more. — [Erdil & Besiroglu](https://arxiv.org/pdf/2309.11690v3)

**For the critique**
- **The data on the hyperbola itself are weak.** Garfinkel found "very little empirical support for the Hyperbolic Growth Hypothesis". There is "approximately nothing to suggest that the post-Industrial Revolution acceleration continued a long-standing hyperbolic trend". With more recent data for a key parameter, Kremer's model "may no longer predict hyperbolic growth". Garfinkel nevertheless finds episodic acceleration "quite plausible". — [Garfinkel 2020, EA Forum](https://forum.effectivealtruism.org/posts/CWFn9qAKsRibpCGq8/does-economic-history-point-toward-a-singularity)
- **Old population figures are model outputs.** "World population statistics in past centuries are all generated by using some sort of statistical regression model." — [Johansen & Sornette](https://arxiv.org/pdf/cond-mat/0002075v4)
- **Fragility of the date.**
  - A simple power law gives 2078; log-periodic fits give 2052 ± 10. "Varying tc from 2030 to 2050, illustrate the large uncertainty". — [Johansen & Sornette](https://arxiv.org/pdf/cond-mat/0002075v4)
  - The hyperbolic regime holds only from about 1700 (ts = 2030) and ends in a population peak, not a singularity. — [Yakovenko 2025](https://arxiv.org/pdf/2508.11038)
  - Discrete models have no singularity, so the date is "practically unrelated to any constraints". — [Bellina et al.](https://arxiv.org/pdf/2411.03394)
- **The transition already happened.** It occurred in 1960–70, "rather than to occur in 2026-2040". — [Golosovsky](https://arxiv.org/pdf/0910.3056)
- **Contingent, not law-like.** The model was "historically contingent" and treated transient trends as laws. — [Birchenall, Science 2026](https://www.science.org/doi/10.1126/science.ael8752)
- **The proponents themselves see deceleration.** Korotayev's 2026 paper reports deceleration in techno-scientific and economic growth rates. — [Korotayev 2026](https://www.academia.edu/178741773/Doomsday_Friday_13_November_A_D_2026_Demographic_Technological_Positive_Feedback_Hyperbolic_Acceleration_of_the_Global_Complexity_Growth_and_the_21st_Century_Singularity_corrected_final_version_)
- **Bottlenecks and tests.**
  - Baumol: growth is constrained by "what is essential and yet hard to improve". — [Aghion, Jones & Jones](https://conference.nber.org/confer/2018/YSAIf18/Jones.pdf)
  - Automating R&D alone "may not produce" the transformation. — [Trammell & Korinek](https://www.nber.org/papers/w31815)
  - "The Singularity is not near." — [Nordhaus](https://www.nber.org/papers/w21547)
  - Growth effects "modest for a decade or two at least". — [Jones 2026 per Conversable Economist](https://conversableeconomist.com/2026/08/07/growth-effects-of-ai-modest-for-a-decade-or-two-at-least/)
  - About a 40% chance that a new bottleneck appears before a tenfold growth acceleration. — [Erdil & Besiroglu](https://arxiv.org/pdf/2309.11690v3)
- **Ideas are getting harder to find.** US research productivity has fallen 41× since the 1930s. — [Bloom et al.](https://www.nber.org/papers/w23782.pdf)
- **Not yet self-sustaining in 2026.** The RSI calibration finds feedback below threshold. — [Cunningham et al.](https://arxiv.org/pdf/2609.15802)

### Inferences
- **Best steelman, stated precisely.**
  1. Population was the endogenous research input in a Kremer loop (Ȧ/A ∝ N, N ∝ A^γ), which produces the hyperbola.
  2. After about 1880 at the frontier and about 1963 globally, output went into income per head and education rather than into more people, so research input stopped scaling with A. Growth fell to the semi-endogenous rate, about proportional to population growth (Erdil & Besiroglu, Appendix C).
  3. AI makes research labor accumulable again: output buys compute, and compute becomes researchers. If returns are strong enough (λβ > ϕ in the notation below), the loop closes and finite-time-type growth resumes.
  4. Under this reading the 1960 fit correctly identified that the old regime was ending and that a radically different pattern lay "around 2026 ± decades". VFMA's numbers do not pin down when or in which variable the next pattern arrives. Roodman's model, which gives the 2047 median on GWP rather than population and treats deviations as noise, is the strongest quantitative form.
- **The steelman's weak points.**
  - **(a) The specific date has no special standing.** Using GWP moves it to 2047, log-periodic fits to 2052, the GDP hyperbola to 2005. "2026" is a property of population data up to 1958, the variable that demonstrably broke.
  - **(b) It is unfalsifiable as usually stated.** Any slowdown can be called "finite-size rounding" (Johansen & Sornette) or "a plausible random deviation" (Roodman), and any later acceleration "the next mode".
  - **(c) The proxy is chosen after the fact.** No proxy was named in advance, and the one candidate that would be convincing (an effective-research-input series following 1/(t0 − t)) has not been built.
  - **(d) The arithmetic has run out.** As of 20 Nov 2026 the hyperbola requires a growth rate above 100% per year in 2026 and divergence by early 2027 (t0 + 5.5 yr = mid-2032 at the outer edge). No economic aggregate shows this.
  - **What remains defensible:** the claim that the long-run super-exponential pattern was driven by an accumulable-research-input feedback, and that AI could revive it. That is a conditional mechanism claim (Davidson; Erdil & Besiroglu; Trammell & Korinek), not a validation of 13 Nov 2026.
- **Is the ±5.5 years still open?** The steelman can say the window runs to 2032. But even a singularity in about May 2032 (2026.87 + 5.5) requires a growth rate in late 2026 of about 1/5.5 ≈ 18% per year in the relevant variable, still accelerating. None of the GWP sources retrieved shows any acceleration from the roughly 3–4% range. I retrieved no 2026 GWP growth figure.

#### Check of the claims in the ChatGPT answer
- **Roodman, median 2047, GDP not accelerating after 1960:** confirmed. Median 2047 conditional on 2019 GWP, and recent decades around the 25th percentile ([sources above](https://mailchi.mp/be2a0d160fa2/an-105-the-economic-trajectory-of-humanity-and-what-we-might-mean-by-optimization)).
  - Nuance: Roodman's model with data up to 1960 itself gave a median of about 2020 (EA Forum extract). So a GWP-based "von Foerster" fitted in 1960 would also have pointed to roughly now.
- **Computation as fast exponentials within regimes, not one hyperbola:** consistent with Hilbert & López (58% per year) and with Sevilla et al. (20-month → 6-month doubling, plus a Large-Scale Era step).
- **The Kremer-style model:** confirmed. Ȧ/A = bN with N ∝ A^γ gives a hyperbola. In Johansen & Sornette's restatement, dA/dt = BLA plus Malthusian L gives dL/dt ∝ L², z = −1.
- **The generalised model Ȧ = kRA^φ, R ∝ A^β blows up in finite time iff φ + β > 1:** correct (Ȧ = kA^(φ+β)).
  - It matches Johansen & Sornette's multivariate condition θ + β > 1 and Aghion–Jones–Jones's "Type II singularity for φ > 0" under full automation (Ȧ ∝ A^(1+φ)).
  - **Mapping to Bloom et al.'s notation.** In (1/A)Ȧ ∝ A^−ϕ R^λ with R ∝ A^β, blow-up requires λβ > ϕ. With λ/ϕ ≈ 0.32, that means β > about 3.1. Effective research input must grow more than 3× as fast (in logs) as TFP: about 8.7× more research input per doubling of TFP (my computation from Erdil & Besiroglu's λ/ϕ). The ChatGPT φ corresponds to 1 − ϕ (with λ = 1), which Bloom et al. would put strongly negative (around −2).
  - This is the precise "obstacle" claim. Erdil & Besiroglu's counterpoint is that with accumulable AI labor the relevant condition is λ/ϕ + (returns to accumulable inputs) > 1, which needs returns of only about 0.68 or more.
- **R = N·f·h + M as "effective research labor":** no source in the literature uses this exact construction. The nearest are Erdil & Besiroglu's human-plus-digital "total effective workforce" and Korotayev's literacy and education channel.
- **"A candidate variable must show growth rate 1/(2026.87 − t)":** correct as a test, and the arithmetic is verified (Q1). No series passing it was found (Q4).

### Gaps
- No quantitative test was found of whether Roodman's model, refit with data to 2025, still gives a median near 2047 or moves later.
- No formal treatment was found of how many free choices (proxy, weights, window) a spliced "effective research input" series has, though such a treatment would quantify the forking-paths critique.

## Q6. 2025–2026 commentary around the 13 November 2026 "doomsday"

### Takeaway
2026 coverage is mostly retrospective and demographic: the prediction failed because fertility fell, and the concern now is population decline and ageing. A few pieces link the date to AI, mostly as metaphor. The substantive scholarly items are Birchenall in *Science*, Korotayev in *Cliodynamics*, Yakovenko on arXiv, a *Kybernetes* paper on von Foerster and AI, and the 2026 AI-growth papers (Jones in JEP; Cunningham et al.; Trammell & Korinek in the *Annual Review of Economics*).

### Cited Findings
- **Science news, Oct 2026, "Will the world end next month? Science said so, in 1960":** about 8 billion people were alive one month before the date. — [Science](https://www.science.org/content/article/will-world-end-next-month-science-said-so-1960)
- **Birchenall Perspective, *Science* 394:173–174 (8 Oct 2026):** "historically contingent" (see Q1). — [Science](https://www.science.org/doi/10.1126/science.ael8752)
- **Complexity Science Hub Vienna, "Today Is Doomsday. But We're Still Here."** (13 Nov 2026) focuses on population loss and ageing. — [CSH](https://csh.ac.at/news/today-is-doomsday-but-were-still-here/)
- **Mainstream coverage.**
  - Newsweek, "Scientists predicted doomsday for November 13, 2026—they got it all wrong". — [Newsweek](https://www.newsweek.com/scientists-predicted-doomsday-for-november-13-2026-they-got-it-all-wrong-12704398)
  - Euronews, 12 Nov 2026. — [Euronews](https://www.euronews.com/2026/11/12/doomsday-studys-prediction-of-the-end-of-the-world-on-13-november-2026-fails)
  - Reason (Ronald Bailey, 13 Nov 2026): VFMA did not account for the demographic transition. — [Reason](https://reason.com/2026/11/13/human-extinction-scheduled-forhuh-how-about-that-today/)
  - RealClearScience, "Happy Doomsday!" (13 Nov 2026). — [RCS](https://www.realclearscience.com/blog/2026/11/13/happy_doomsday_1216332.html)
  - AEI, "Doomsday Friday". — [AEI](https://aei.org/commentary/doomsday-friday/)
  - IBTimes UK. — [IBTimes](https://www.ibtimes.co.uk/1960-doomsday-population-prediction-2026-1831915)
  - Yahoo. — [Yahoo](https://www.yahoo.com/news/science/articles/today-doomsday-physicist-once-predicted-144126848.html)
- **AI-linked pieces.**
  - Vietnam Signals, "Doomsday Was Right. At Least About AI" (argues the hyperbolic logic fits AI investment). — [Substack](https://vietnamsignals.substack.com/p/doomsday-was-right-at-least-about)
  - Archyde, "Is AI Doomsday Inevitable? Lessons from the Failed 2026 Population Apocalypse Prediction". — [Archyde](https://www.archyde.com/is-ai-doomsday-inevitable-lessons-from-the-failed-2026-population-apocalypse-prediction/)
  - *Kybernetes* (Emerald), "Heinz von Foerster, artificial intelligence and computationally mediated second-order observation," DOI 10.1108/K-06-2026-1671 (conceptual; uses the calculation to frame AI, not as a forecast). — [DOI](https://doi.org/10.1108/K-06-2026-1671)
  - "Beyond Doomsday: reading Von Foerster's 1960 equation as a lesson in second-order cybernetics". — [ResearchGate](https://www.researchgate.net/publication/415461146_Beyond_Doomsday_reading_Von_Foerster's_1960_equation_as_a_lesson_in_second-order_cybernetics)
- **Other Substacks.**
  - "Von Foerster's Doomsday Was Due Today" (voxdw, 13 Nov 2026). — [voxdw](https://voxdw.substack.com/p/von-foerster-doomsday-115th-birthday)
  - "Doomsday was Last Friday: The Great Spike of Humankind" (Seneca Effect). — [Seneca Effect](https://senecaeffect.substack.com/p/doomsday-was-last-friday)
  - "Congratulations, You Have Survived Doomsday" (goff). — [goff](https://goff.substack.com/p/congratulations-you-have-survived)
  - "Prediction misses the point of von Foerster's 'doomsday' equation" (heycityzen). — [heycityzen](https://heycityzen.substack.com/p/prediction-misses-the-point-of-von)
- **Scholarly 2025–26.**
  - Korotayev 2026, *Cliodynamics* (Q2). — [academia.edu](https://www.academia.edu/178741773/Doomsday_Friday_13_November_A_D_2026_Demographic_Technological_Positive_Feedback_Hyperbolic_Acceleration_of_the_Global_Complexity_Growth_and_the_21st_Century_Singularity_corrected_final_version_)
  - Yakovenko 2025 (Q2). — [arXiv:2508.11038](https://arxiv.org/pdf/2508.11038)
  - Bellina et al. 2025. — [arXiv:2411.03394](https://arxiv.org/pdf/2411.03394)
  - Jones 2026, JEP. — [PDF](https://web.stanford.edu/~chadj/AIandEconomicFuture.pdf)
  - Cunningham et al. 2026. — [arXiv:2609.15802](https://arxiv.org/pdf/2609.15802)
  - Trammell & Korinek 2026, *Annual Review of Economics*. — [NBER](https://www.nber.org/papers/w31815)
  - A 2025 arXiv paper on population crisis scenarios from a nonlinear model also appeared. — [arXiv:2502.19063](https://arxiv.org/pdf/2502.19063)

### Inferences
- Among the retrieved 2026 retrospectives, none seriously argues that the 2026 date was vindicated by AI. The AI framings are metaphorical (Vietnam Signals) or cybernetic-philosophical (*Kybernetes*). The steelman in Q5 would therefore be a novel contribution rather than a summary of existing commentary.
- The two most relevant scholarly 2026 statements point in opposite directions. Korotayev, a long-time hyperbolic modeller, reports deceleration. Cunningham et al. find AI feedback loops below the self-sustaining threshold but "strengthening".

### Gaps
- The full text of the Science news article, the Birchenall Perspective, the CSH piece and the Kybernetes paper were not read; only search extracts were available.
- LessWrong, EA Forum and Epoch commentary specifically around 13 Nov 2026 linking the date to AGI was not found, possibly because the search budget ran out.

## Q7. Where downloadable long-run data lives (for a quantitative analysis)

### Takeaway
World population: Our World in Data (HYDE 3.3 for 10,000 BCE–1799, Gapminder for 1800–1949, UN WPP 2024 for 1950 on), World Bank SP.POP.TOTL (1960–), and Kremer's 1993 Table I (1 million BC–1990). Long-run GWP: DeLong (1998), Maddison and the Maddison Project / Bolt & van Zanden (2020), and Roodman's code-and-data archive on GitHub. Computing: Hilbert & López's supplementary data and Epoch's training-compute dataset.

### Cited Findings
- **OWID population.** The long-run chart starts at 10,000 BCE. OWID uses HYDE (v3.3) before 1800 and UN WPP (2024 revision) for 1950–2023, updated twice a year. Yakovenko uses the World Bank variable SP.POP.TOTL (1960–2023) instead of UN data. — [Yakovenko 2025, data section](https://arxiv.org/pdf/2508.11038); [OWID population growth](https://ourworldindata.org/population-growth-over-time); [OWID past and future](https://ourworldindata.org/world-population-growth-past-future)
- **Kremer (1993):** table of population from 1,000,000 B.C. to 1990, with Deevey's estimates for 25,000–10,000 B.C. — [gwern PDF of Kremer 1993](https://gwern.net/doc/economics/1993-kremer.pdf)
- **UN population 0–1998** (UN Population Division) and **DeLong's "Estimating World GDP, One Million B.C.–Present"** (1998), formerly at econ161.berkeley.edu/TCEH/1998_Draft/World_GDP/Estimating_World_GDP.html; these are the inputs used by Johansen & Sornette. — [Johansen & Sornette references](https://arxiv.org/pdf/cond-mat/0002075v4)
- **Maddison:** world GDP 1–1973 (Maddison 2001), used by Korotayev & Malkov; the Maddison Project database is cited by Erdil & Besiroglu as Bolt & van Zanden (2020). — [Korotayev & Malkov](https://arxiv.org/pdf/1206.0496); [Erdil & Besiroglu](https://arxiv.org/pdf/2309.11690v3)
- **Roodman's code and data archive** (with hyperbola fits over different windows): [GitHub michaeldickens/Modeling-Human-Trajectory](https://github.com/michaeldickens/Modeling-Human-Trajectory). Paper PDFs: [Coefficient Giving PDF](https://coefficientgiving.org/wp-content/uploads/Modeling-the-human-trajectory-2.pdf); [gwern mirror](https://gwern.net/doc/economics/automation/2020-roodman.pdf)
- **Computing:** Hilbert & López's supplementary materials, [Science SOM](https://www.science.org/action/downloadSupplement?doi=10.1126%2Fscience.1200970&file=pap.pdf); Epoch training-compute data, [Sevilla et al. 2022](https://arxiv.org/abs/2202.05924).

### Inferences
- For a test of "did any proxy stay on the curve", a minimal reproducible set is: OWID/HYDE population, Roodman's GWP series, and a researcher series (UNESCO/OECD, not retrieved here). Fit N = C/(t0 − t)^k on data up to 1958 to reproduce VFMA, then compare later observations and implied growth rates against 1/(t0 − t). The script `/tmp/claude-0/-home-user-AI-works/4efb40ba-54a6-5b00-b03f-3f1d0e56bdd6/scratchpad/scripts/vf.py` already holds the curve's implied values.

### Gaps
- OWID, HYDE, Maddison Project and UN WPP download URLs and file formats could not be verified directly in-session (network restricted to arXiv).
- I did not locate Roodman's own original repository, only the archive above.
- Sources for global researcher counts (UNESCO Institute for Statistics), R&D spending (OECD MSTI) and total installed compute were not retrieved.
