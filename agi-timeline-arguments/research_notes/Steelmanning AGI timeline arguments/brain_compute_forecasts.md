# Brain-compute and hardware-based early forecasts of human-level AI (Turing to Legg): what they said, why the dates came out near 2025–2030, and whether that was luck

*Research notes as of 20 November 2026.*

**How these notes were made, and how far to trust the quotes.** The session's network policy blocked direct fetches of most primary hosts: jetpress.org, nickbostrom.com, edoras.sdsu.edu (Vinge), frc.ri.cmu.edu (Moravec), longbets.org, lesswrong.com and web.archive.org all failed. Partway through, the shared WebSearch budget for the turn ran out. Quotes are tagged by how they were checked:
- **[verbatim-primary]**: read in the primary text, or in a verbatim reproduction inside a paper fetched from arXiv.
- **[search-quote]**: wording reported by a web-search result that cites the primary page. Likely accurate, but not checked against the full text.
- **[secondary]**: a paraphrase or claim made by a secondary source.
- **[unverified]**: from the researcher's background knowledge. It is listed under Gaps and should not be used without checking.

---

## Q1. What exactly did each forecaster predict (event, date, probability), when, and on what reasoning chain? How did they restate it later?

### Takeaway
Almost all of these forecasts share one skeleton: (a) estimate the brain's processing rate, (b) extrapolate price-performance to the date when cheap machines reach it, (c) add a modest software lag. Moravec, Kurzweil, Bostrom and Legg spelled out each step. Turing, Vinge, Yudkowsky and Schmidhuber relied more loosely on exponential trends. The dates that now look good are Kurzweil's 2029, Legg's mode of 2025 and mean of 2028, Moravec's "cheap hardware in the 2020s" and Vinge's "before 2030". Each was attached to a mechanism that did not happen: brain reverse-engineering, neuroscience-derived algorithms, or a $1,000 PC.

### Cited Findings

#### Alan Turing (1950)
- **[verbatim-primary, reproduced in Gray 1999]** "I believe that in about fifty years' time it will be possible, to programme computers, with a storage capacity of about 10^9, to make them play the imitation game so well that an average interrogator will not have more than 70 per cent chance of making the right identification after five minutes of questioning. … Nevertheless I believe that at the end of the century the use of words and general educated opinion will have altered so much that one will be able to speak of machines thinking without expecting to be contradicted." — [Jim Gray, "What Next? A Dozen IT Research Goals" (1999), quoting Turing, arXiv cs/9911005](https://arxiv.org/pdf/cs/9911005)
- Source details: *Mind* 59(236):433–460, October 1950. The prediction is on p. 442. Turing gave the unit of storage in binary digits, so 10^9 bits is about 125 MB, and he compared it with the Encyclopaedia Britannica, 11th edition, at 2×10^9. — [OUP, Mind](https://academic.oup.com/mind/article/LIX/236/433/986238); [Stanford Encyclopedia of Philosophy, "The Turing Test"](https://plato.stanford.edu/entries/turing-test/); [Lemire 2016](https://lemire.me/blog/2016/05/08/we-are-passing-the-turing-test-right-on-schedule/) [secondary]
- Gray's 1999 assessment: "His technology forecast was astonishingly accurate, if a little pessimistic. The typical computer has the requisite capacity… On the other hand, his forecast for machine intelligence was optimistic." Gray added: "I think it will happen within the next 50 years because I am persuaded by the argument that we are nearing parity with the storage and computational power of simple brains." He operationalized the test as "Build a computer system that wins the imitation game at least 30% of the time." — [Gray 1999, arXiv cs/9911005](https://arxiv.org/pdf/cs/9911005) [verbatim-primary]
- Jack Copeland's reading: "about fifty years" does not mean "exactly fifty years". — [SEP](https://plato.stanford.edu/entries/turing-test/) [secondary]
- **Modern comparison.** Jones & Bergen (31 March 2025) ran a pre-registered, randomized three-party test of five minutes. GPT-4.5 with a humanlike-persona prompt was judged human 73% of the time, significantly more often than the real humans. LLaMa-3.1-405B with the same persona was judged human 56% of the time, not significantly different from humans. ELIZA scored 23% and GPT-4o 21%. The authors call this "the first empirical evidence that an artificial system passes a standard three-party Turing test." — [Jones & Bergen, "Large Language Models Pass the Turing Test," arXiv 2503.23674](https://arxiv.org/abs/2503.23674) [verbatim-primary abstract]
- An earlier study (9 May 2024) used a two-party, five-minute format. GPT-4 was judged human 54% of the time, humans 67% and ELIZA 22%. — [Jones & Bergen, "People cannot distinguish GPT-4 from a human in a Turing test," arXiv 2405.08007](https://arxiv.org/abs/2405.08007)

#### Hans Moravec (1975/76, 1978, 1988, 1998, 1999)
- **1975/76, "The Role of Raw Power in Intelligence."** The CMU copy is dated 1975; the Stanford AI exhibit lists it as 12 May 1976. Its thesis is that processing power, not cleverness of programs, limits AI. Search excerpts show a comparison of the visual system with computers, a figure of "10^8 bit/sec" and a "Growth of Processing Power" section. The dated forecast in the essay could not be extracted. — [CMU copy](https://frc.ri.cmu.edu/~hpm/project.archive/general.articles/1975/Raw.Power.html); [Stanford Spotlight exhibit](https://exhibits.stanford.edu/ai/catalog/ws563sd6050) [search-quote, partial]
- **1978, Analog article.** Moravec's own 1999 preface says it "implausibly called for someone to invest billions of dollars in computer hardware to possibly produce one humanlike machine." — [Moravec, Preface to *Robot* (book97 preview)](https://frc.ri.cmu.edu/~hpm/book97/0..Preface.html) [search-quote]. This matters for the spending question: Moravec did consider a billion-dollar machine, but abandoned it as implausible.
- **1988, *Mind Children*.** Robots "will need, at the least, the capacity to perform ten trillion calculations per second" (about 10^13 ops/s, derived from the retina). Moravec concludes that "our hardware will have no trouble meeting this forty-year timetable." — [NYRB review "Matter Over Mind," 1990](https://www.nybooks.com/articles/1990/02/01/matter-over-mind/) [search-quote of reviewer's paraphrase]
- **Conflicting readings of the 1988 dates:**
  - Wikiversity reads the book (pp. 64 and 68) as predicting human-level intelligence in supercomputers by 2010 and in personal computers by 2030. — [Wikiversity, Book Reviews/Mind Children](https://en.wikiversity.org/wiki/Book_Reviews/Mind_Children)
  - An AI Magazine review says that in 1988 Moravec projected "human equivalence in a supercomputer in the years 2000 to 2005 and in a personal computer by 2028 to 2030+", and in 1999 "2020 to 2030+". — [AI Magazine review of *Robot*](https://ojs.aaai.org/aimagazine/index.php/aimagazine/article/view/1472/1371)
  - Moravec's 1999 preface says *Mind Children* "rescheduled" humanlike performance "for ten-thousand-dollar personal computers in forty years", while the new book projects it "in thousand-dollar computers in forty years." — [Preface](https://frc.ri.cmu.edu/~hpm/book97/0..Preface.html) [search-quote]
  - Scott Alexander summarizes the 1988 forecast as human-level AI by 2010, from 10^13 ops/s. — [ACX, "Biological Anchors: A Trick That Might or Might Not Work"](https://www.astralcodexten.com/p/biological-anchors-a-trick-that-might) [secondary]
  - Yudkowsky's 2021 dialogue uses Moravec's 2010 as its base case. A footnote in the MIRI version says "Moravec just about nailed this part; the actual year was 2008," apparently referring to when the hardware arrived. — [MIRI, "Biology-Inspired AGI Timelines: The Trick That Never Works"](https://intelligence.org/2021/12/03/biology-inspired-agi-timelines-the-trick-that-never-works/) [search-quote]
- A 2025 review of *Mind Children* reads it as predicting "about 10 tera-ops and 100 terabits of compute and memory available for approximately $1000 in 2030." The reviewer says Moore's-law extrapolation put machines near brain-level computation "in the 2020s, as indeed happened!" and that the book "does not discuss concrete paths to AGI except as extrapolations of the robotics and symbolic logic systems of this era." — [Beren Millidge, Review of *Mind Children*, Jan 2025](https://www.beren.io/2025-01-12-Review-Of-Mind-Children-By-Hans-Moravec/) [search-quote]
- **1998, "When will computer hardware match the human brain?"** (*Journal of Evolution and Technology*, vol. 1):
  - Abstract: "Based on extrapolation of past trends and on examination of technologies under development, it is predicted that the required hardware will be available in cheap machines in the 2020s." — [jetpress.org](https://www.jetpress.org/volume1/moravec.htm) [search-quote]
  - "100 million MIPS to match human brain power will then arrive in home computers before 2030." — [jetpress.org](https://www.jetpress.org/volume1/moravec.htm) [search-quote]
  - He calibrates on the retina at about 1,000 MIPS and scales up by brain size: the whole brain "is 100,000 times larger than the retina, so is worth perhaps 100 million MIPS". — [Moravec book97 ch. 3](https://frc.ri.cmu.edu/~hpm/book97/ch3/index.html) [search-quote]
  - Hardware trend: "Since 1990, the power available to individual AI and robotics programs has doubled yearly, to 30 MIPS by 1994 and 500 MIPS by 1998." Before 1990 the power available "remained almost unchanged at 1 MIPS, barely insect power", because cost declines were absorbed by having more machines. — [jetpress.org](https://www.jetpress.org/volume1/moravec.htm) [search-quote]
  - Hedge: chess machines reached world-champion level at about 1/30 of brain power by his measure, and the 10^8 MIPS estimate "may be one or two orders of magnitude too small" for some tasks. The 1998 supercomputers, "costing tens of millions of dollars, can do a few million MIPS… within striking distance… but are unlikely to be applied to that end." — [jetpress.org](https://www.jetpress.org/volume1/moravec.htm) [search-quote]
  - The paper says the faster pace would make "humanlike robots possible before the middle of the next century." — [jetpress.org](https://www.jetpress.org/volume1/moravec.htm) [search-quote]
- A 2000 Moravec essay says computer power per price "roughly doubled each year in the 1990s, after doubling every 18 months in the 1980s, and every two years prior", and that "two or three decades more at the present pace" would close the millionfold gap. — [Moravec, "Ripples and Puddles," 2000](https://frc.ri.cmu.edu/~hpm/project.archive/robot.papers/2000/puddle.html) [search-quote]
- **1999, *Robot: Mere Machine to Transcendent Mind*, robot generations** (per secondary summaries of the book):
  - 2010: lizard scale, about 3,000 MIPS: general-purpose perception, manipulation and mobility.
  - 2020: mouse scale, about 100,000 MIPS: accommodation learning.
  - 2030: monkey scale, about 3,000,000 MIPS: world modelling.
  - 2040: human scale, about 100,000,000 MIPS: reasoning.

  — [Reason and Meaning summary](https://reasonandmeaning.com/2016/02/05/summary-of-hans-moravecs-robot-mere-machine-to-transcendent-mind/) [secondary]
- Moravec's December 1999 *Scientific American* article gives slightly different figures: "lizardlike 5,000-MIPS" minds around 2010 and a "monkeylike five million MIPS" third generation. It also says: "By 2040, I believe, we will finally achieve the original goal of robotics and a thematic mainstay of science fiction." — ["Rise of the Robots," SciAm Dec 1999](https://faculty.umb.edu/gary_zabel/Courses/Bodies,%20Souls,%20and%20Robots/Texts/AI%20and%20Robotics/Rise%20of%20the%20Robots,%20Moravec,%20Scientific%20American,%20December%201999.htm) [search-quote]
- A 2016 paper still read Moravec's schedule as "lizard-level occurring by 2020, mouse-level by 2030, monkey-level by 2040, and human-level by 2050". It also said "we expect by the year 2023 [inexpensive microprocessors] will reach the speed Moravec predicted as necessary to support human-level robotics." — [Metzger et al., arXiv 1612.03238](https://arxiv.org/pdf/1612.03238) [verbatim-primary]

#### Vernor Vinge (1993)
- Abstract: "Within thirty years, we will have the technological means to create superhuman intelligence. Shortly after, the human era will be ended." — [quoted verbatim in Walsh, "The Singularity May Never Be Near," arXiv 1602.06462](https://arxiv.org/pdf/1602.06462) [verbatim-primary]
- In a parenthetical right after the claim that greater-than-human intelligence will arrive within thirty years: "I'll be surprised if this event occurs before 2005 or after 2030." The essay was written for NASA's VISION-21 Symposium (NASA Lewis Research Center and the Ohio Aerospace Institute) and published in *Whole Earth Review*, Winter 1993. — [accelerating.org copy](https://accelerating.org/articles/comingtechsingularity.html); [UCSD copy](https://cseweb.ucsd.edu/~goguen/misc/singularity.html) [search-quote]

#### Nick Bostrom (1997, published 1998; postscripts to 2008)
- The abstract makes "the case for believing that we will have superhuman artificial intelligence within the first third of the next century". The search result confirms the gist and the "outline the case for believing" wording; the exact phrase "first third of the next century" was not seen verbatim. — [Bostrom PDF](https://nickbostrom.com/papers/how-long-before-superintelligence/how-long-before-superintelligence.pdf); [PhilPapers](https://philpapers.org/rec/BOSHLB) [search-quote/secondary]
- Hardware estimate: "The human brain contains about 10^11 neurons. Each neuron has about 5 × 10^3 synapses, and signals are transmitted along these synapses at an average frequency of about 10^2 Hz." That gives 10^17 ops. With optimization the requirement falls to between 10^14 and 10^17 ops, and "the entrance level would probably not be less than about 10^14 ops." — [IEET archive copy](https://archive.ieet.org/articles/bostrom1998.html) [search-quote]
- Moore's-law dating: supercomputers with 10^17 ops arrive around 2015 (12-month doubling) or 2024 (18-month doubling). The 10^14 lower bound arrives between 2004 and 2008. Bostrom notes that "Moore's law loses its credibility long before we reach absolute physical limits." — [IEET archive copy](https://archive.ieet.org/articles/bostrom1998.html) [search-quote]
- 2008 postscript: the paper was a case for early timelines, not his own final forecast. All things considered, he gives less than 50% probability to superintelligence by 2033. — [Bostrom PDF](https://nickbostrom.com/papers/how-long-before-superintelligence/how-long-before-superintelligence.pdf) [secondary paraphrase of postscript]

#### Eliezer Yudkowsky (1996 onward)
- "Staring into the Singularity" (1996, revised to 2001) argues that if computing power doubles every two years, then once computers do the research the doubling interval shrinks. "Computing power doubles every two years of work… One year later, their speed doubles again," and the intervals keep halving to a finite-time singularity. — [textfiles.com mirror](http://www.textfiles.com/russian/cyberlib.narod.ru/lib/critica/sing/singstar.html); [supaiku.com archive](https://supaiku.com/archive/staring-into-the-singularity) [search-quote]
- Date: a 2002 mirror of the essay contains "It's expected in 2035. (Oops, make that 2025.)" A prediction tracker lists the 1996 prediction as "Singularity by 2025 (or 2005, given funding!)". — [gordonmclean.co.uk 2002 mirror](https://www.gordonmclean.co.uk/2002/11/11/2537/); [foomflops tracker](https://foom.hyperplex.org/) [secondary]
- Later SIAI-era estimate: "final-stage AI will reach transhumanity sometime between 2005 and 2020, probably around 2008 or 2010." RationalWiki dates this to 2002; the foomflops tracker dates it to 2001. — [RationalWiki](https://rationalwiki.org/wiki/Eliezer_Yudkowsky); [foomflops](https://foom.hyperplex.org/) [secondary; conflicting dates]
- Goertzel notes that Yudkowsky later repudiated parts of the essay (2001 revision). — [Goertzel, JET v25.2](http://jetpress.org/v25.2/goertzel.htm) [secondary]
- In 2021 Yudkowsky attacked the whole brain-compute method: "this trick didn't work when Moravec tried it, it's not going to work while Ray Kurzweil is trying it, and it's not going to work when you try it either." — [LessWrong/MIRI, Dec 2021](https://www.lesswrong.com/posts/ax695frGJEzGxFBK4/biology-inspired-agi-timelines-the-trick-that-never-works) [search-quote]

#### Ray Kurzweil (1990, 1999, 2001, 2002, 2005, 2024)
- **1990, *The Age of Intelligent Machines*.** Predicted that a computer would become world chess champion by about the end of the 1990s; Deep Blue beat Kasparov in May 1997. Kurzweil's 1993 recollection says he also predicted that the next several years would bring convincing evidence that computers could pass "narrow" versions of the Turing Test. — [Kurzweil 1993 Library Journal essay](https://www.writingsbyraykurzweil.com/the-virtual-book-revisited); [AI for Good/ITU](https://aiforgood.itu.int/the-future-is-better-than-you-think-predictions-on-ai-and-development-from-ray-kurzweil/) [secondary]
- **1999, *The Age of Spiritual Machines*:**
  - 2009: it takes a supercomputer to match one brain.
  - 2019: about $4,000 (1999 dollars) matches one brain, per Wikipedia's summary. Another summary has "A $1,000 computing device is now approximately equal to the computational ability of the human brain." The sources conflict.
  - 2029: $1,000 buys about 1,000 brains. Machines pass the Turing test "routinely", after "prevalent reports" of non-rigorous passes in 2019.

  — [Wikipedia, "The Law of Accelerating Returns"](https://en.wikipedia.org/wiki/The_Law_of_Accelerating_Returns); [Penguin RH excerpt](https://penguinrandomhousehighereducation.com/book/?isbn=9780140282023) [secondary]
- **2001/2002 essay.** "We achieve one Human Brain capability (2 * 10^16 cps) for $1,000 around the year 2023." — [Kurzweil Library](https://www.thekurzweillibrary.com/max-more-and-ray-kurzweil-on-the-singularity-2) [search-quote]. Scott Alexander summarizes Kurzweil 2001 as 2×10^16 ops/s in a $1,000 computer in 2023, about 22 years out. — [ACX](https://www.astralcodexten.com/p/biological-anchors-a-trick-that-might) [secondary]
- **2002, Long Bet #1 (Kapor vs Kurzweil).** Kapor predicts "By 2029 no computer – or 'machine intelligence' – will have passed the Turing Test"; Kurzweil takes the other side. The stake is $20,000, going to the EFF if Kapor wins or to the Kurzweil Foundation if Kurzweil wins. Long Now arranges the test, each session has at least three Turing Test Trials, and Kurzweil said the rules took "months of dialogue". In 2014 Kurzweil did not accept the Eugene Goostman claim as satisfying the bet. — [Wikipedia, Long Bets](https://en.wikipedia.org/wiki/Long_Bets); [Kurzweil Library on Goostman](https://www.writingsbyraykurzweil.com/my-view-on-the-chatbot-claiming-to-pass-the-turing-test); [Integral Options Cafe 2014](http://integral-options.blogspot.com/2014/06/kurzweil-does-not-accept-victory-in.html) [secondary]
- **2005, *The Singularity Is Near*:**
  - Brain estimate of 10^16 cps and 10^13 bits of memory. "If we use the figure of 10^16 cps that I believe will be sufficient for functional emulation of human intelligence…" (p. 121). — [AI Impacts, "Preliminary prices for human-level hardware"](https://aiimpacts.org/preliminary-prices-for-human-level-hardware/) [search-quote]
  - $1,000 buys one brain's worth of computing "by around 2020". — [Wikipedia, *The Singularity Is Near*](https://en.wikipedia.org/wiki/The_Singularity_Is_Near) [secondary]
  - 2045: the "nonbiological intelligence created in that year will be one billion times more powerful than all human intelligence today" (p. 136). — [quoted in "Deep Hype in AGI," arXiv 2508.19749](https://arxiv.org/pdf/2508.19749) [verbatim-primary reproduction]
- **2024, *The Singularity Is Nearer*.** Keeps 2029 (human-level AI and passing the Turing test) and 2045 (singularity). — [Wikipedia](https://en.wikipedia.org/wiki/The_Singularity_Is_Nearer); [EDRM review](https://edrm.net/2024/07/ray-kurzweils-new-book-the-singularity-is-nearer-when-we-merge-with-ai/) [secondary]

#### Shane Legg (vetta.org 2009–2011; later restatements)
- **Feb 2009, "Tick, tock, tick, tock…".** IBM's Sequoia (due 2011) would do "20 Peta FLOPS" with "1.6 Peta bytes of RAM". Used to simulate a human cerebral cortex, it could allocate "50 bytes of RAM and 700 calculations per second to every synapse." — [vetta.org, Feb 2009](https://www.vetta.org/2009/02/tick-tock-tick-tock/) [search-quote]
- **Dec 2009, "Tick, tock, tick, tock… BING."** "my prediction for the last 10 years has been for roughly human level AGI in the year 2025 (though I also predict that sceptics will deny that it's happened when it does!) This year I've tried to come up with something a bit more precise. In doing so what I've found is that while my mode is about 2025, my expected value is actually a bit higher at 2028." — [vetta.org, Dec 2009](https://www.vetta.org/2009/12/tick-tock-tick-tock-bing/), as reposted [here](https://www.threads.com/@mwi.invest/post/DSgAZkaEoWf/shane-legg-deep-mind-cofounder-in-my-prediction-for-the-last-years-has-been-for) [search-quote]
- Same post, on hardware: "we're heading towards 10^20 FLOPS before 2030, even if things slow down a bit from 2020 onwards." He compares 10^20 with the number of neurons in all human brains combined. — [vetta.org](https://www.vetta.org/2009/12/tick-tock-tick-tock-bing/) [search-quote]
- Same post, on neuroscience. He describes what is seen in the brain as "a fairly sensible looking AGI design." He also says, roughly, that neuroscientists working on cortex "aren't going to be of much use to AGI efforts" for about the next five years; the exact wording and context are uncertain. In the comments: "more computer power makes solving the AGI design problem easier. Firstly, more powerful computers allow us to search larger spaces of programs looking for good algorithms." He named "brain-like, large-scale self-organising hierarchical temporal networks, similar to what we see in cortex" as the promising approach. — [vetta.org](https://www.vetta.org/2009/12/tick-tock-tick-tock-bing/); [Foresight Institute, "Is the brain a reasonable AGI design?"](https://events.foresight.org/is-the-brain-a-reasonable-agi-design/) [search-quote]
- **Oct 2009, talk "Machine Super Intelligence"** (Gatsby Unit, Halloween 2009). The outline includes "early 2020's: the Halloween scenario" and the question whether the brain can "tell us anything useful about AGI design?" — [vetta.org talk PDF](https://www.vetta.org/documents/extrobrit_talk.pdf) [search-quote, outline only]
- **Dec 2010, "Goodbye 2010":**
  - The AGI date is his "longest running prediction", dating from 1999. He first fitted it to a distribution the previous year: log-normal, mean 2028, mode 2025.
  - He estimated computational bottlenecks assuming a roughly brain-like architecture.
  - The compute a typical researcher can access is "perhaps 4 orders of magnitude less" than supercomputers.
  - Supercomputers of 10^18 FLOPS were "on track for around 2018".
  - "Proto-AGI" means basic vision, sound processing, movement control and language abilities, "all learned rather than preprogrammed".

  — [vetta.org, Goodbye 2010](https://www.vetta.org/2010/12/goodbye-2010/) [search-quote/secondary]
- **Jan 2011, "Technological themes."** "it's usually easier to predict fundamental things like FLOPS per dollar than is it to predict how these technological fundamentals will translate into applications." — [vetta.org](https://www.vetta.org/2011/01/technological-themes/) [search-quote]
- **June 2011, LessWrong Q&A.** Timeline answer 2018 / 2028 / 2050, read by secondary sources as 10% / 50% / 90%. AI was his "number 1 risk for this century". — [LessWrong, Q&A with Shane Legg](https://www.lesswrong.com/posts/No5JpRCHzBrWA4jmS/q-and-a-with-shane-legg-on-risks-from-ai) [search-quote; the percentage mapping is secondary]
- **Dec 2011, "Goodbye 2011, hello 2012."** "I give it a log-normal distribution with a mean of 2028 and a mode of 2025, under the assumption that nothing crazy happens like a nuclear war. I'd also like to add to this prediction that I expect to see an impressive proto-AGI within the next 8 years." — [vetta.org](https://www.vetta.org/2011/12/goodbye-2011-hello-2012/), quoted verbatim in [arXiv 1605.04232](https://arxiv.org/pdf/1605.04232) [verbatim-primary reproduction]. Progress was "maybe a little faster" than expected in neuroscience and machine learning. — [vetta.org](https://www.vetta.org/2011/12/goodbye-2011-hello-2012/) [secondary]
- AI Impacts summarizes the Dec 2009 post as predicting 2028 in expectation "based on progress in neuroscience and AI", and notes that Legg agreed with it again in 2012. — [AI Impacts, List of analyses of time to human-level AI](https://wiki.aiimpacts.org/ai_timelines/list_of_analyses_of_time_to_human-level_ai) [secondary]
- **Oct 2023, Dwarkesh Patel podcast.** "there's a 50% chance that we have AGI by 2028." — [Dwarkesh Podcast, 26 Oct 2023](https://www.dwarkesh.com/p/shane-legg) [search-quote]
- **Jul 2025, X post.** "Of course, when I wrote this blog comment I had also realised that there was a winning move based on this heretical belief: start an AGI company long before most people realise it's coming. Hence, @GoogleDeepMind" — [X, @ShaneLegg](https://x.com/ShaneLegg/status/1950830332250386441) [search-quote, from the page title]
- **Dec 2025, X post with the Hannah Fry podcast.** "I've publicly held the same prediction since 2009: there's a 50% chance we'll see #AGI by 2028." — [X, @ShaneLegg](https://x.com/ShaneLegg/status/1999180585407848776) [search-quote]. A late-2025 write-up says he expects "minimal AGI" roughly two years from late 2025. — [NextBigFuture, Dec 2025](https://www.nextbigfuture.com/2025/12/google-ai-lead-shane-legg-defines-levels-of-agi-and-superintelligence-and-how-to-test-for-it.html) [secondary]
- **Lineage of the reasoning.** Gwern recalls reading "Legg's blog posts where he's extrapolating out the trend with updated numbers from Kurzweil and Moravec". On seeing GPT-3: "Holy shit, we *are* living in the scaling world. Legg and Moravec and Kurzweil were right!" — [Gwern–Dwarkesh interview transcript](https://gwern.net/interview-dwarkesh) [search-quote]

#### DeepMind's 20-year mission (Hassabis and Legg, 2010) and Hassabis's later dates
- DeepMind was founded on 15 November 2010 to "solve intelligence" and then "use it to solve everything else". — [Wikipedia, Google DeepMind](https://en.wikipedia.org/wiki/Google_DeepMind) [secondary]
- "We've always had this 20 year plan from the start of DeepMind… I think we're on track." — [Alex Kantrowitz, Big Technology](https://www.bigtechnology.com/p/can-demis-hassabis-save-google) [search-quote]. A Cambridge lecture around 2025 called it a 20-year mission that is "sort of on track" 15 years in. — [End of Miles](https://www.endofmiles.net/deepminds-20-year-agi-mission-on-track-after-15-years-reveals-nobel-laureate-hassabis/) [secondary]
- Implied target: 2010 + 20 = 2030. Hassabis is reported as saying AGI is "on track for 2030, plus or minus a year". — [engineAI interview](https://engineai.eu/article/exclusive-interview-with-demis-hassabis-on-agi) [secondary]. In June 2025 he was reported as saying AGI "will begin to happen in 2030". — [Wired, Levy 4 June 2025, as cited in arXiv 2508.19749](https://arxiv.org/pdf/2508.19749) [verbatim reproduction of secondary]
- No primary founding document stating the 20-year target was found. — [UBC blog](https://blogs.ubc.ca/etec522/2026/06/08/demis-hassabis-co-founder-and-ceo-of-deepmind-now-google-deepmind/) [secondary]

#### Jürgen Schmidhuber (Omega ≈ 2040)
- He argues that the intervals between major computing breakthroughs have shrunk exponentially since 1623, each arriving roughly twice as fast as the previous one, converging at "Omega = 2040". — [Schmidhuber, "Greatest moments of computer history are speeding up"](https://people.idsia.ch/~juergen/computerhistory.html); [Schmidhuber, "History converging – again?"](https://people.idsia.ch/~juergen/history.html) [search-quote]
- 2006 paper: intervals between notable events over 40,000 years "have sped up exponentially, apparently converging to zero within the next few decades." It adds a caveat: "Or is this impression just a by-product of the way humans allocate memory space to past events?" — [arXiv cs/0606081](https://arxiv.org/abs/cs/0606081) [verbatim-primary]. A 2014 interview reportedly moved the convergence to around 2050. — [search summary of NPA interview](https://www.npa.org/public/interviews/careers_interview_663.cfm) [secondary]

#### Ben Goertzel
- At the 2024 Beneficial AGI Summit he said human-level AGI was plausible within 3–8 years, most likely 2029 or 2030, possibly 2027. — [Live Science](https://www.livescience.com/technology/artificial-intelligence/ai-agi-singularity-in-2027-artificial-super-intelligence-sooner-than-we-think-ben-goertzel) [secondary]
- He called Kurzweil's 2029 a "fair approximation". — [Fox News](https://www.foxnews.com/media/super-agi-matrix-sophia-the-robot-co-creator-economic-mayhem-road-ai-utopia.amp) [secondary]
- In 2026 he still said about 2029. — [Forbes, 21 Jun 2026](https://www.forbes.com/sites/boazsobrado/2026/06/21/agi-is-too-important-ben-goertzels-crypto-bet-against-openai/) [secondary]
- No dated pre-2012 Goertzel forecast was found. See Gaps.

#### Joseph Carlsmith (2020), the modern brain-FLOP/s reference
- "Overall, I think it more likely than not that 10^15 FLOP/s is enough to perform tasks as well as the human brain (given the right software, which may be very hard to create)." He finds 10^13–10^17 FLOP/s plausible on mechanistic estimates, considers it unlikely (<10%) that more than 10^21 FLOP/s is required, and reviews four methods. Published September 2020 by Open Philanthropy. — [Coefficient Giving / Open Philanthropy report](https://coefficientgiving.org/research/how-much-computational-power-does-it-take-to-match-the-human-brain/); [EA Forum summary](https://forum.effectivealtruism.org/posts/nGQJEYp5X2pCbeweg/new-report-on-how-much-computational-power-it-takes-to-match) [search-quote]
- Brain estimates compared: Moravec about 10^13–10^14 (instructions/s), Bostrom 10^14–10^17 ops, Kurzweil 10^16 (2×10^16 in 2001), Carlsmith central 10^15 FLOP/s. Moravec and Carlsmith differ by about 1–2 orders of magnitude; Kurzweil is 10× above Carlsmith. (Compiled from the sources above.)

### Inferences
- The forecasts cluster into two families:
  - **Explicit compute-anchor forecasts:** Moravec, Bostrom, Kurzweil, Legg. Each names a brain rate, a price-performance curve and a date.
  - **Acceleration or trend forecasts:** Vinge, Yudkowsky 1996, Schmidhuber. Each infers a convergence date from exponential or hyperbolic trends, with little explicit brain arithmetic.
- The first family is where the "compute predicted the date" story is strongest. Even there, most authors kept hardware and capability separate: Moravec's own *capability* date for human-level robots was 2040, not the 2020s.
- Legg's reasoning, as far as it can be reconstructed:
  1. Compute is the easiest variable to forecast ("FLOPS per dollar"), with 10^18 FLOPS supercomputers around 2018 and 10^20 before 2030.
  2. The brain is a "sensible looking AGI design" built from hierarchical temporal networks plus reinforcement learning, and neuroscience would make its principles legible.
  3. More compute makes the design problem easier, because larger program spaces can be searched.
  4. A proto-AGI with learned vision, sound, motor and language skills would appear first.

  Steps 1 and 3 match what happened. Step 2, neuroscience supplying the algorithms, largely did not: the decisive architecture, the transformer, owes little to cortex research. Step 4's "learned, not preprogrammed" multimodal proto-AGI did arrive within roughly his 8-year window (2012–2019 deep learning, GPT-2 in 2019), though not in the embodied form he sketched.
- Kurzweil's reasoning combined (i) a 10^16 cps hardware threshold reached in a $1,000 PC around 2020–2023 with (ii) software from reverse-engineering the brain, finished around the late 2020s. The hardware-at-$1,000 date was missed by roughly two orders of magnitude (see Q2), and brain reverse-engineering was not how capability arrived. The Turing-test prediction nonetheless came true early in its weak (5-minute) form.

### Gaps
- **Moravec 1976.** The exact numerical forecast in "Raw Power" (brain ops/s, year) could not be retrieved; the CMU host is blocked.
- **Vinge's hardware basis.** The researcher recalls a sentence in Vinge 1993 roughly like "Progress in computer hardware has followed an amazingly steady curve in the last few decades… Based largely on this trend, I believe that the creation of greater than human intelligence will occur during the next thirty years." [unverified]. The search to confirm it failed because the budget was exhausted.
- **Long Bet #1 rules.** The detailed rules (recalled as three judges, three human foils, about two hours of interviews per candidate, and the computer having to fool two of three judges) [unverified] could not be checked, because longbets.org is blocked.
- **Bostrom's software argument** (bottom-up via neuroscience and learning) and the exact postscript wording were not retrieved.
- **Yudkowsky 1996.** The essay's original 1996 wording and dates could not be fetched from primary text. "2025 (or 2005 given funding)" and "2035 (oops, 2025)" rest on mirrors and a tracker.
- **Kurzweil's growth-rate assumption.** The *Singularity Is Near* passage on reverse-engineering the brain by the 2020s, and Kurzweil's explicit "doubling time itself shrinks" statement, were not retrieved verbatim. The researcher recalls the 2001 essay saying computer speed per unit cost "doubled every three years between 1910 and 1950, every two years between 1950 and 1966, and is now doubling every year" [unverified].
- **Kurzweil's 2019 hardware milestone.** The conflict between $1,000 and $4,000 (1999 dollars) for one brain in 2019 is unresolved.
- **Turing's 1952 remark.** Turing's 1952 BBC remark of "at least 100 years" for passing a stronger version [unverified] could not be checked.
- **Turing's learning-machine proposal.** His "child machine" proposal in section 7 of the 1950 paper ("Instead of trying to produce a programme to simulate the adult mind, why not rather try to produce one which simulates the child's?") [unverified] is relevant to the "right mechanism" question but was not fetched.
- **Goertzel before 2012.** No dated pre-2012 forecast was found. The AGI-09 expert survey (Baum, Goertzel & Goertzel 2011) could not be searched.
- **Hassabis.** Exact Hassabis quotes, beyond secondary reports, on "5–10 years" and on the 20-year plan were not verified against transcripts.

---

## Q2. What hardware and price-performance trajectories did they assume, how did those compare with what happened, and did anyone account for training compute or spending growth? What does a corrected version look like?

### Takeaway
On hardware, Moravec's curve (about 10^14 operations per second per $1,000 in the 2020s) came out roughly right. Kurzweil's 10^16 cps per $1,000 by about 2020–2023 was about 100–300× too optimistic. Nobody in the classic group built the forecast on training compute; Moravec in 1978 considered and then dropped the idea of a billion-dollar machine. A training-based correction lands in roughly the same place: with each author's own brain estimate × about 10^9 seconds of lifetime experience, frontier training runs crossed the "lifetime anchor" between 2020 (Moravec's figure) and 2023 (Kurzweil's figure). They got there by spending 10^5–10^6× more than a $1,000 PC, not by cheaper chips.

### Cited Findings
- **Moravec's assumed trend.** Power per price doubled yearly in the 1990s, every 18 months in the 1980s and every 2 years before that. Brain-equivalent 10^8 MIPS "in home computers before 2030". — [Moravec 2000](https://frc.ri.cmu.edu/~hpm/project.archive/robot.papers/2000/puddle.html); [Moravec 1998](https://www.jetpress.org/volume1/moravec.htm) [search-quote]
- **Kurzweil's assumed trend.** 2×10^16 cps for $1,000 around 2023 (2001 essay), or "by around 2020" (2005). — [Kurzweil Library](https://www.thekurzweillibrary.com/max-more-and-ray-kurzweil-on-the-singularity-2); [Wikipedia, TSIN](https://en.wikipedia.org/wiki/The_Singularity_Is_Near) [search-quote/secondary]
- **Bostrom's assumed trend.** 12- or 18-month doubling, giving 10^17 ops supercomputers by 2015 or 2024. — [IEET copy](https://archive.ieet.org/articles/bostrom1998.html) [search-quote]
- **Legg's assumed trend.** 10^18 FLOPS supercomputers around 2018 and 10^20 FLOPS before 2030. — [vetta.org 2010](https://www.vetta.org/2010/12/goodbye-2010/); [vetta.org Dec 2009](https://www.vetta.org/2009/12/tick-tock-tick-tock-bing/) [search-quote]
- **Actual GPU price-performance:**
  - Epoch (2022): FP16 price-performance doubled every 2.32 years (95% CI 1.69–3.62), over 470 GPUs from 2006 to 2021. Overall best estimate about 2.5 years; "a doubling time of 2 years is too aggressive." — [Epoch, "Trends in GPU price-performance"](https://epoch.ai/publications/trends-in-gpu-price-performance)
  - ML GPUs: 2.1-year doubling in FP32 price-performance. — [Epoch, "Trends in ML hardware"](https://epoch.ai/blog/trends-in-machine-learning-hardware)
  - AI chips bought each quarter, 2023–2025: performance per dollar up about 49% per year (about a 1.7-year doubling), but only about 6% per year from 2023 to mid-2024, before Blackwell. — [Epoch data insight](https://epoch.ai/data-insights/chip-performance-per-dollar)
  - The H100 (2022, about $34,000) gives about 17× the computation per dollar of the P100 (2016, about $5,700). — [Epoch, AI chips overview](https://epoch.ai/publications/chips-topic-overview)
- **Training-compute growth (the variable none of them modelled):**
  - Before 2010, training compute doubled about every 20 months, in line with Moore's law. In the deep-learning era it doubled about every 6 months. — [Sevilla et al., "Compute Trends Across Three Eras," arXiv 2202.05924](https://arxiv.org/abs/2202.05924) [verbatim-primary abstract]
  - Frontier training compute grows about 4–5× per year. — [Epoch, cited in arXiv 2504.16138](https://arxiv.org/pdf/2504.16138)
  - GPT-4 (March 2023) was the first model trained on more than 10^25 FLOP. By mid-2025 there were 33 models at that scale or above. — [Epoch, models over 1e25 FLOP](https://epoch.ai/data-insights/models-over-1e25-flop); [Epoch on X](https://x.com/EpochAIResearch/status/1940470592462799200)
  - Grok 4 (July 2025) used about 5×10^26 FLOP, Grok 3 about 3.5×10^26 and GPT-4.5 about 2.1×10^26. — [Epoch, "Frontier LLM training runs can't get much longer"](https://epoch.ai/data-insights/longest-training-run)
  - A tracker page retrieved in November 2026 claims the largest entry in Epoch's dataset is about 9.4×10^26 FLOP (September 2026). It is internally inconsistent and not verified. — [AI 2027 Tracker](https://ai2027-tracker.com/predictions/training-compute/) [secondary, low confidence]
- **The lifetime anchor.** Cotra (2020) takes about 10^15 FLOP/s × about 10^9 s (about 30 years), roughly 10^24 FLOP, and multiplies by a computer-vs-brain inefficiency factor centred near 1,000. The report's overall training-compute median is about 10^28 FLOP; the lifetime anchor gets about 5% weight. Its overall forecast was 10% for transformative AI by 2031, 50% by 2052 and 78% by 2100. — [Alignment Forum, "Grokking Forecasting TAI with biological anchors"](https://www.alignmentforum.org/posts/wgio8E758y9XWsi8j/grokking-forecasting-tai-with-biological-anchors); [readscottalexander.com summary](https://readscottalexander.com/posts/acx-what-happened-with-bio-anchors) [secondary]
- **Spending.** Moravec's 1978 essay "implausibly called for someone to invest billions of dollars in computer hardware to possibly produce one humanlike machine". He then moved his anchor to $10,000 and later $1,000 PCs. — [Moravec 1999 preface](https://frc.ri.cmu.edu/~hpm/book97/0..Preface.html) [search-quote]. Legg noted that researchers had "perhaps 4 orders of magnitude less" compute than supercomputers. He used supercomputers, not PCs, as the frontier anchor, which is closer to what happened. — [vetta.org 2010](https://www.vetta.org/2010/12/goodbye-2010/) [secondary]
- **Hindsight on hardware.** One commentator argues that Moravec and Kurzweil "were surprised by the death of Dennard scaling and slowing price-performance growth", but the field is now in a compute-intensive boom "in the right region of compute space". — [LessWrong reply, cited via search](https://www.lesswrong.com/posts/NGkBfd8LTqcpbQn5Z/biological-anchors-the-trick-that-might-or-might-not-work) [secondary]

### Inferences
These are the researcher's own calculations. Where they rely on GPU specifications from background knowledge, that is marked.

- **Kurzweil's $1,000 target vs 2023.**
  - An H100 does about 1×10^15 dense FP16/BF16 FLOP/s (NVIDIA spec, [unverified]) for about $34k (Epoch). That is about 3×10^13 FLOP/s per $1,000, roughly 300× short of 10^16, or about 150× short using FP8.
  - A consumer RTX 4090 (about 1.6×10^14 dense FP16 tensor FLOP/s for $1,599; spec [unverified]) gives about 1×10^14 per $1,000, about 100× short.
  - So Kurzweil's hardware curve was about 2–2.5 orders of magnitude too optimistic by 2023. His double-exponential assumption broke when growth settled to about 2.3-year doublings (Epoch).
- **Moravec's $1,000 target vs the 2020s.** 10^8 MIPS is about 10^14 operations per second per $1,000 "before 2030". A consumer GPU reached about 10^14 low-precision FLOP/s per $1,000 around 2022–23. At 2.3-year doubling, datacentre GPUs reach it around 2026–27. Moravec's hardware forecast is therefore roughly on schedule, with the caveat that MIPS and FP16 FLOP are not the same unit.
- **Corrected, training-compute version, using each author's own brain figure × 10^9 s:**

  | Author | Brain figure | × 10^9 s | Crossed by |
  |---|---|---|---|
  | Moravec | 10^14 | 10^23 FLOP | GPT-3, 2020 (about 3.1×10^23 FLOP per Brown et al. 2020, arXiv 2005.14165, Table D.1 [unverified in this session]) |
  | Carlsmith | 10^15 | 10^24 FLOP | Frontier runs, 2021–22 |
  | Kurzweil | 10^16 | 10^25 FLOP | GPT-4, March 2023 |
  | Cotra lifetime × 1,000 inefficiency | 10^15 | about 10^27 FLOP | About the 2026 frontier, if the about 10^27 reports hold |

  So the training version, with no algorithmic penalty, gives *earlier* dates than the inference-at-$1,000 version. Adding Cotra's 1,000× penalty brings it back to about 2025–2026, which is exactly the window the old forecasts named.
- **Why the two criteria give similar dates (an identity).** Suppose $1,000 buys B FLOP/s at date D. A lifetime-anchor training run (B × 10^9 s × k) finished in about 10^7 s (about 4 months) needs a cluster of B × 100 × k FLOP/s. That cluster costs about $1,000 × 100 × k: about $10^5 for k = 1, or about $10^8 for k = 1,000.
  - So "a $1,000 PC matches the brain in real time" is roughly the same date as "a $100M cluster can train a brain-lifetime-equivalent model with 1,000× inefficiency".
  - Frontier labs actually spent $10^8–$10^10 on clusters in 2023–2026 (order of magnitude, not sourced here). Spending growth therefore more than covered the training-vs-inference gap and Kurzweil's price-performance shortfall.
  - This structural near-equivalence is the strongest explanation of why "PC-inference" forecasts landed near the right date despite modelling the wrong quantity.
- **Brain-rate inference already matches deployed hardware.** One deployed GPT-4-class model instance runs on a server of about 8 datacentre GPUs, about 10^16 FLOP/s, which is the Kurzweil and Carlsmith brain range (inference; specs [unverified]). Hardware for real-time "brain-rate" inference was therefore available at roughly $200–300k per instance by 2023, matching Moravec's 1998 remark about multi-million-dollar machines being "within striking distance".

### Gaps
- No source fetched in this session gives a measured 2023 FLOP/s-per-$1,000 figure. The GPU specifications above are background knowledge and should be checked, for example in Epoch's ML Hardware database or NVIDIA datasheets.
- Frontier training-run costs (dollars) for 2024–2026 were not retrieved. Epoch's "Trends in the dollar training cost of ML systems" appeared in search results but was not read.
- The 2026 frontier compute figure (about 10^27 FLOP) rests on a single inconsistent tracker page.
- The AI Impacts pages "Preliminary prices for human-level hardware" and "Brain performance in FLOPS" appeared in results but their content was not read.

---

## Q3. Why did the dates land near now despite wrong mechanisms? What do existing analyses say, how good are these forecasters' wider track records, and how much is cherry-picking or luck?

### Takeaway
The near-right dates come from several things together:
- **Offsetting errors.** Ignoring training compute pushed the dates earlier; ignoring spending growth and assuming a $1,000 machine pushed them later. Kurzweil's too-fast price-performance was offset by ignoring the spending scale-up.
- **An insensitive anchor.** Once frontier compute grew 4–5× per year, any brain anchor between 10^23 and 10^27 FLOP was going to be crossed in 2020–2026.
- **Algorithms gated by compute.** Algorithmic progress is itself largely compute-gated, so hardware timing does constrain capability timing.
- **Selection effects.** We remember the 2025–2030 forecasts, while the same method also produced the 2000 (Turing), 2008–2010 (Moravec 1988, Yudkowsky 2001) and 2004–2024 (Bostrom hardware) misses. Kurzweil's granular 2019 predictions were mostly wrong.

On balance this is "partly skill, partly luck": the method gets the order of magnitude of the date right more reliably than the year, and only the authors who chose a horizon of 20–30 years landed near 2025–2030.

### Cited Findings
- **Yudkowsky's critique (2021).** Biological-anchor timelines are "a trick that never works". Moravec in 1988 predicted 2010 and Kurzweil in 2001 predicted 2023, each about 22 years out. Commentators summarize his objection as being about "the unsoundedness of the methods by which Moravec reaches his conclusion", not the size of the brain estimate. The missing input is how much compute is needed to *build* AGI, which biology cannot supply. — [LessWrong/MIRI](https://www.lesswrong.com/posts/ax695frGJEzGxFBK4/biology-inspired-agi-timelines-the-trick-that-never-works); [ACX](https://www.astralcodexten.com/p/biological-anchors-a-trick-that-might) [search-quote/secondary]. A reply: [Karnofsky, "Reply to Eliezer on Biological Anchors"](https://www.alignmentforum.org/posts/nNqXfnjiezYukiMJi/reply-to-eliezer-on-biological-anchors).
- **Scott Alexander on Bio Anchors (2025/26).** Cotra's report "correctly predicted the AI scaling boom but got AGI timelines wrong by twenty years, due to severely underestimating the rate of algorithmic progress." It assumed about 1.3× per year algorithmic efficiency against later estimates of about 3× per year, so effective compute grew about 10.7× per year rather than the 3.6× it forecast. — [readscottalexander.com, "What Happened With Bio Anchors?"](https://readscottalexander.com/posts/acx-what-happened-with-bio-anchors); [ACX original](https://www.astralcodexten.com/p/what-happened-with-bio-anchors) [secondary]. The sophisticated 2020 compute model was further from the 2025–2030 window (median 2052) than the crude 1990s–2000s models.
- **Kurzweil's track record (Armstrong):**
  - 2009 predictions from *Age of Spiritual Machines*: 531 assessments of 172 predictions gave 27% true, 15% weakly true, 14% weakly false, 32% false and 11% undecidable. Armstrong called Kurzweil "an acceptable prognosticator, with very poor self-assessment". — [LessWrong, "Assessing Kurzweil: the results"](https://www.lesswrong.com/posts/kbA6T3xpxtko36GgP/assessing-kurzweil-the-results); [Armstrong, Sotala & Ó hÉigeartaigh 2014](https://www.researchgate.net/publication/264352013_The_errors_insights_and_lessons_of_famous_AI_predictions_-_and_what_they_mean_for_the_future) [secondary numbers]
  - 2019 predictions (2020 assessment of 105 statements; 34 assessors, 24 of whom assessed all 105): "considerably worse than those for 2009, with more than half strongly wrong". The breakdown was 12% true, 12% weakly true, 10% cannot decide, 15% weakly false and 52% false. Kurzweil had claimed an 86% hit rate. — [LessWrong, "Assessing Kurzweil predictions about 2019: the results"](https://www.lesswrong.com/posts/NcGBmDEe5qXB7dFBF/assessing-kurzweil-predictions-about-2019-the-results); [Kirchhoff critique](https://www.gwendolinkirchhoff.com/en/essays/kurzweil-singularity-theosphere-technosphere) [secondary breakdown via Slashdot syndication]
- **Moravec's track record.**
  - The 1988 supercomputer-by-2010 prediction "failed", which Wikiversity calls "tangible evidence for how problematic such extrapolation is". The book also expected robots on the market by 2000. — [Wikiversity](https://en.wikiversity.org/wiki/Book_Reviews/Mind_Children)
  - Beren: the hardware projections were "pretty accurate", but the book lacks concrete paths to AGI. — [Beren 2025](https://www.beren.io/2025-01-12-Review-Of-Mind-Children-By-Hans-Moravec/) [search-quote]
  - The 1999 robot generations (lizard-scale universal robots by 2010, mouse-scale by 2020) did not arrive as consumer products. This is the researcher's assessment, with no source fetched.
  - A LessWrong critique argues that Moravec's extrapolations put cheap human-level compute in the 2020s, and that the timing errors "completely trash[ed] his ability to predict and time the future". — [cited via Gwern scaling directory search](https://www.lesswrong.com/posts/ax695frGJEzGxFBK4/biology-inspired-agi-timelines-the-trick-that-never-works) [secondary; exact attribution unclear]
- **Yudkowsky's dated predictions.** Transhumanity between 2005 and 2020, probably 2008–2010, did not happen. RationalWiki also attributes to him a 1999 prediction of atomically precise nanotech by 2010, which also did not happen. — [RationalWiki](https://rationalwiki.org/wiki/Eliezer_Yudkowsky) [secondary]
- **Base rates for AI forecasts (Armstrong & Sotala 2012).** A database of 257 predictions, 95 of them timelines. The most common estimate, from experts and non-experts alike, is 15–25 years ahead. Expert predictions "do not correlate in any distinct way relative to non-experts". The Maes–Garreau "end of lifetime" pattern was not observed. MIRI later flagged a dataset error affecting the findings. — [Armstrong & Sotala, "How We're Predicting AI—or Failing To"](https://intelligence.org/files/PredictingAI.pdf); [MIRI Dec 2012 newsletter](https://intelligence.org/2012/12/19/december-2012-newsletter/); [AI Impacts, Maes–Garreau law](https://wiki.aiimpacts.org/ai_timelines/predictions_of_human-level_ai_timelines/interpretation_of_ai_predictions/accuracy_of_ai_predictions/the_maes-garreau_law)
- **Expert surveys for contrast.** The 2023 AI Impacts survey (published January 2024) put a 50% chance of HLMI by 2047, "13 years earlier" than the 2022 survey, and a 10% chance by 2027. — [Grace et al., arXiv 2401.02843](https://arxiv.org/abs/2401.02843) [verbatim-primary abstract]. The compute-anchored outsiders of 1998–2011 were 20–30 years earlier than mainstream expert opinion, and so far closer to the trend in capabilities.
- **Schmidhuber's own selection-bias caveat.** He asks whether the convergence pattern is "just a by-product of the way humans allocate memory space to past events". — [arXiv cs/0606081](https://arxiv.org/abs/cs/0606081). Commentators note his personal interest in witnessing Omega. — [search summary](https://people.idsia.ch/~juergen/history.html) [secondary]
- **Legg's own humility on mechanism.** It is "usually easier to predict fundamental things like FLOPS per dollar than… how these technological fundamentals will translate into applications". — [vetta.org 2011](https://www.vetta.org/2011/01/technological-themes/) [search-quote]
- **Testable pieces that have resolved:**
  - Turing's 5-minute imitation-game threshold was met in 2025 (GPT-4.5 judged human 73%), about 25 years after his "about fifty years". — [Jones & Bergen 2025](https://arxiv.org/abs/2503.23674)
  - Kurzweil's 1990 chess prediction resolved in 1997. — [AI for Good](https://aiforgood.itu.int/the-future-is-better-than-you-think-predictions-on-ai-and-development-from-ray-kurzweil/)
  - Kurzweil's 2029 Turing-test date is still open under the stricter Long Bet rules.

### Inferences
- **Mechanism scorecard.**

  | Forecaster | Forecasting element | Verdict |
  |---|---|---|
  | Turing | Storage | Too low by about 4 orders of magnitude. LLaMa-3.1-405B, which passed his test, holds about 405×10^9 parameters × 16 bits ≈ 6.5×10^12 bits, against his 10^9. His learning-machine idea ([unverified] quote) points the right way. |
  | Moravec | Hardware curve; brain-rate estimate | Right. |
  | Moravec | Embodied robots first, lizard → mouse → monkey → human | Wrong order. Language and abstract reasoning came first, while robotics lags. This fits "Moravec's paradox" itself, so his own paradox cut against his robot-generation schedule. |
  | Kurzweil | Hardware curve | Too fast. |
  | Kurzweil | $1,000 PC | Wrong: the relevant machines were $10^8–10^10 clusters. |
  | Kurzweil | Brain reverse-engineering | Wrong mechanism. |
  | Kurzweil | Turing test by 2029 | Right or early. |
  | Legg | Compute as the forecastable driver; scale makes search over designs easier | Right. |
  | Legg | Neuroscience supplying the algorithms | Mostly wrong. |
  | Legg | Supercomputer anchor rather than PC anchor | Closer to reality than Moravec's or Kurzweil's PC anchor. |
  | Yudkowsky 1996 | AI-accelerated hardware research, hyperbolic | Not the mechanism so far. Recursive AI-assisted research is only beginning to be discussed in 2025–26. |
  | Bostrom | Hardware window (2004–2024) | Too early, since the hardware arrived and AGI did not. |
  | Bostrom | Overall "first third" frame | Still live. |

- **Why the dates converge despite wrong mechanisms:**
  1. **Offsetting errors.** Training compute adds about 9 orders of magnitude of total FLOP over real-time inference, but only about 2 orders of magnitude in cluster FLOP/s for a 4-month run. Spending grew about 5–7 orders of magnitude above a $1,000 PC. The net effect roughly cancels; see the identity in Q2.
  2. **Steep compute growth compresses the uncertainty.** At 4–5× per year frontier growth, the 4-order-of-magnitude spread in brain estimates (10^13–10^17) corresponds to only about 6 years of calendar uncertainty. A crude anchor therefore pins the date to within a decade *if* one also assumes the steep scaling regime would happen. None of them predicted that regime explicitly, but Legg's supercomputer anchor came closest.
  3. **Algorithms are compute-gated** (see Q4). Hardware timing is a real, not spurious, predictor of when the needed algorithms appear.
  4. **Horizon choice.** These forecasters picked 20–30-year horizons, consistent with the 15–25-year folk norm. Those writing between 1993 and 2009 thus landed in 2023–2033. Forecasters who picked 10-year horizons (Moravec 1988 for supercomputers, Yudkowsky 2001) or used Turing's 50-year horizon from 1950 missed. There is survivorship: the "remarkably accurate" list is selected on outcome.
- **Is it luck?** Partly. Evidence of skill:
  - Moravec's hardware curve was right.
  - The compute-centric group beat contemporaneous expert surveys by decades.
  - The sophisticated 2020 compute model (Cotra) was *more* wrong in the conservative direction because it modelled algorithmic progress separately and too slowly. That suggests the crude "compute is what matters" heuristic captured something real: that algorithmic progress tracks compute.

  Evidence of luck:
  - The same method produced several clear misses.
  - Kurzweil's granular record is about 42% (2009) and about 24% (2019) true or weakly true.
  - The intermediate predictions (robots, brain scanning, neuroscience-derived algorithms) mostly failed.
  - "AGI" itself has not been certified as of November 2026, so the headline forecasts are not yet scored.
- **Fair framing.** The method has a good record on the *order of magnitude of compute* and on *decade-level timing*, and a poor record on *mechanism* and on *intermediate milestones*.

### Gaps
- The AI Impacts MIRI AI predictions dataset and its analysis pages (accuracy of AI predictions; Moravec and Kurzweil hardware retrospectives) could not be read; aiimpacts.org fetches were not attempted after other hosts failed, and search snippets were thin.
- No systematic scoring of Moravec's or Legg's full prediction sets was found.
- Whether any frontier system meets a given AGI definition as of November 2026 is out of scope here and unscored.

---

## Q4. What is the strongest steelman of "compute availability determines the AGI date"?

### Takeaway
The steelman: algorithms that work at scale have mostly been old ideas (backprop, convnets, LSTMs, search and learning) that became effective once compute arrived. Recent measurements suggest that most "algorithmic progress" is itself scale-dependent. So the date when enough compute is affordable to someone is the binding constraint, and brain-compute anchors are a crude but legitimate way to locate it. The 2025 evidence (Gundlach et al.) and the failure of a separately modelled algorithmic-progress term (Bio Anchors) are the newest support.

### Cited Findings
- **Sutton, "The Bitter Lesson" (13 March 2019).** "The biggest lesson that can be read from 70 years of AI research is that general methods that leverage computation are ultimately the most effective, and by a large margin." He attributes this to the continuing exponential fall in the cost per unit of computation (Moore's law). Search and learning are the two methods that scale with computation. — [Sutton, incompleteideas.net, PDF copy](https://nparikh.org/assets/pdf/sipa6545/readings/sutton-bitter-lesson.pdf); [mlanthology](https://mlanthology.org/misc/2019/sutton2019misc-bitter/) [search-quote; the opening sentence was confirmed by the search result]
- **Ho et al. (March 2024).** Compute needed to reach a fixed language-modelling performance halved about every 8 months (95% CI about 5–14 months), faster than Moore's law, across more than 200 evaluations from 2012 to 2023. The increase in compute contributed even more to performance gains than algorithmic innovation did. — [Ho et al., "Algorithmic progress in language models," arXiv 2403.05812](https://arxiv.org/abs/2403.05812) [verbatim-primary abstract]
- **Gundlach et al. (November 2025, revised November 2026).**
  - Ablations of the key 2012–2023 innovations explain "less than 10x of these gains at small compute scales", and "less than 100x efficiency gains total in low-compute regimes", against the 22,000× attributed to Ho et al.
  - "an algorithm's efficiency gains are tied to compute scale". Progress at smaller compute levels is "far slower than previously assumed", and efficiency measures are "strongly reference-dependent".

  — [Gundlach, Fogelson, Lynch, Trisovic, Rosenfeld, Sandhu, Thompson, "On the Origin of Algorithmic Progress in AI," arXiv 2511.21622](https://arxiv.org/abs/2511.21622) [verbatim-primary abstract]
- Per the LessWrong linkpost, the LSTM→Transformer switch and the Kaplan→Chinchilla rebalancing account for 91% of extrapolated gains at the 2025 frontier. Most individual innovations give under 10× and together under 10% of the extrapolated gain. — [LessWrong linkpost](https://www.lesswrong.com/posts/X8KGHstcJa4qZznfH/linkpost-on-the-origins-of-algorithmic-progress-in-ai); [Papers with Code summary: 3,360× total, scale-dependent innovations about 90% of log-efficiency gains](https://paperswithcode.co/paper/128957) [secondary]
- **Bio Anchors post-mortem.** Underestimating algorithmic progress (about 1.3× per year assumed against about 3× per year) produced a timeline about 20 years too late. One analysis argues the deeper miss was "the reverse effect, by which greater compute enables larger experiments and hence further algorithmic discoveries." — [readscottalexander.com](https://readscottalexander.com/posts/acx-what-happened-with-bio-anchors) [secondary]
- **Compute regime change.** Training compute doubled about every 20 months before 2010 and about every 6 months after. — [Sevilla et al. 2022](https://arxiv.org/abs/2202.05924). Frontier compute grows 4–5× per year. — [Epoch via arXiv 2504.16138](https://arxiv.org/pdf/2504.16138)
- **Legg's version of the steelman (2009).** "more computer power makes solving the AGI design problem easier… more powerful computers allow us to search larger spaces of programs looking for good algorithms." — [vetta.org](https://www.vetta.org/2009/12/tick-tock-tick-tock-bing/) [search-quote]
- **Moravec's version (1998).** AI performance tracks researchers' access to hardware. Power available to individual AI programs was flat at about 1 MIPS before 1990 and then doubled yearly. — [jetpress.org](https://www.jetpress.org/volume1/moravec.htm) [search-quote]
- **Gwern's testimony.** GPT-3 confirmed "the scaling world", where "Legg and Moravec and Kurzweil were right". He saw DanNet and AlexNet as early evidence that connectionism works once compute is available. — [Gwern–Dwarkesh interview](https://gwern.net/interview-dwarkesh); [The Scaling Era (Stripe Press 2025)](https://assets.stripeassets.com/fzn2n1nzq965/5j0dFbeGgGbohTE3a2jrVA/ebd35e791ca5fa926c6a0b076860c71c/ZINE-Scaling_Era-singles.pdf) [search-quote]

### Inferences
- **The steelman, in four steps:**
  1. Capability is a function of effective compute.
  2. The "algorithm" part of effective compute is mostly unlocked *by* compute, through scale-dependent innovations such as the transformer's better scaling exponent and compute-optimal data/parameter balance, plus experiments that only big budgets can run (Gundlach et al.; Ho et al.).
  3. Therefore the arrival date of enough compute, priced against what someone will pay, sets the date.
  4. Brain FLOP/s anchors, however crude, bracket the needed compute within about 4 orders of magnitude, and in a 4–5×-per-year regime that is under a decade.

  Under this view Moravec, Kurzweil and Legg were right about the *driver* and wrong about the *channel*: the channel was frontier clusters, not PCs, and gradient-trained transformers, not brain emulation. The driver is what fixes the date.
- **Historical support** (well known, not fetched here): backpropagation (popularized in 1986), convnets (LeCun, late 1980s) and LSTMs (1997) all became dominant only after GPU compute in 2009–2012. That fits Sutton's account.
- **Limits of the steelman:**
  - It needs a spending assumption that none of the classic forecasters made (or, in Moravec's case, rejected as "implausible").
  - The algorithmic-progress evidence is mostly from language-model pretraining.
  - Gundlach et al. show that measured efficiency is "strongly reference-dependent", which cuts both ways.
  - It cannot explain the *specific* year, which still depended on contingent choices: the transformer in 2017, the GPT scaling bets, investment cycles.

### Gaps
- Epoch's latest headline estimate of the algorithmic-progress rate (for example, about 3× per year) was only seen second-hand via Scott Alexander's summary.
- No source fetched in this session directly quantifies how much of 1986–1997 algorithms' success after 2012 was due to compute rather than data (ImageNet, the web). The data-availability confound is not addressed here.
