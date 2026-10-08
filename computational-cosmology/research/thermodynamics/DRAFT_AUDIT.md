# Thermodynamic audit of the main draft

8 October 2026. Reviewed `computational_cosmology/report.md`, principally sections 1, 5 and 7. Applied surgical edits only in sections 5 and 7; section 1 needed no correction. Did not modify appendices or other sections.

## Verdict

The draft's principal thermodynamic claims are sound within their stated domains. It correctly distinguishes erasure capacity from useful gates, avoids asserting either an immortal reversible computer or a universal nonzero error floor, and keeps the channel-time example architecture-dependent. The aestivation discussion fairly captures the important correction without asserting that patience is never useful.

## Precise corrections applied

- Specified a uniformly random bit with degenerate logical energies for the simple kBT ln2 reset formula. “Uncertain” alone need not mean a full bit of Shannon entropy.
- Made collected photon energy → available work an explicit assumption before the harvesting benchmark is converted into erasure equivalents.
- Reworded h as entropy capacity consumed per useful gate, and explicitly made it dependent on hardware and operating rate. This avoids blurring entropy transfer, thermodynamic entropy production, and logical irreversibility.
- Added lossless/broadband/fixed-temperature assumptions to the bosonic channel model and stated that its energy and entropy fluxes are net outgoing minus incoming quantities.
- Replaced ambiguous “half the ideal Landauer efficiency” with “spending twice the quasistatic energy per bit”. Replaced “hotter operation” in the immediately following list with “greater energy expenditure”, which maps directly to the equation while holding the bath fixed.
- Added the original Kramers source to the stationary thermal-activation example and fixed subject–verb agreement.

## Quantitative checks

- The channel formula E≥kBT ln2 B+3ħ ln²2 B²/(πCτ) has the correct coefficient for the declared C independent ideal bosonic modes.
- At TdS=ħH/(2πk), η=.5, B=10^120, C=1 gives τ=6 ln2 B/H=7.29×10^130 years at the report's H.
- The activated-memory example requires Eb/(kBT)=419.90 for n=10^30, ν=10^12/s, δ=.01 and that duration. The 300-K conversion is10.86 eV. Properly qualified as a model, it usefully rebuts claims that runtime alone establishes impossibility.
- A reversible 400-bit counter has2^400≈2.58×10^120 states. This is a valid counterexample to deriving a gate-count bound from one-erasure-per-increment assumptions; it is not being oversold as reliable hardware.

## Minor consistency point for the parent, if desired

The channel example at B=10^120 and η=.5 uses E=2 kBTdS ln2 B≈4.21×10^67 J. It is a distinct illustrative budget from the2.80×10^67-J harvesting benchmark. Nothing in the present wording logically identifies the two, but an appendix footnote could make this explicit. With the harvesting benchmark held fixed and η=.5, B≈6.66×10^119 and the same C=1 model instead gives τ≈4.86×10^130 years. Keeping the round10^120 example is reasonable if explicitly presented as a scaling illustration.

## Remaining physical limitations are already properly identified

No feasible universal C is derived; flat/local channel assumptions do not establish mode access near a cosmological horizon; internal entropy storage avoids immediate export demand; h is not fixed universally; passive barrier stability is not an active computation/control design; and collected radiation is not automatically pure work. No further mandatory main-text corrections found.
