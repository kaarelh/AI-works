# Verification and scope

This folder records two different checks: a mathematical review of the argument and a reproducible build of the manuscript. **Neither is a Lean formalization or human peer review.**

## Mathematical review

The [fresh independent AI-agent audit](MATHEMATICAL-AUDIT.md), dated 25 October 2026, reviewed the complete activation construction and the critical appendix. It found no substantive mathematical error. The reviewed steps include:

- global analyticity, computability, derivative control, monotonicity and concavity of the engineered activation;
- uniform truth-table decoding, teacher margin, depth, coefficient size and precision;
- the low-energy memorizer and cold/fixed-gap finite-width posterior argument;
- critical scalar control, actual finite-width target probability, near-baseline circuit simulation, and the full-cube entropy certificate;
- the absence of an invalid transfer of tanh-specific VC or Pfaffian bounds to the engineered activation.

The audit also checks the essential qualification: the activation encodes difficult computation and cannot be evaluated efficiently at the precision used by its teachers. The theorem does not resolve the unrestricted-depth question for exact tanh, ReLU, or GELU.

The added variant with all derivatives globally bounded received two independent mathematical checks: [the companion-agent audit](BOUNDED-DERIVATIVES-AUDIT.md) and [the root-agent audit](BOUNDED-DERIVATIVES-ROOT-AUDIT.md). They check the growing finite-difference order, cross-band estimates, and the amplifier gain of order `d` that preserves teacher depth `L=d+4`. Its lower rate remains `exp(Ω(L))`, and the original fixed-gain memorizer applies. The [research note](../research-notes/all-derivatives-bounded-counterexample.md) records the audited argument before LaTeX integration; the public appendix gives the complete proof.

## Isolated manuscript build

On 25 October 2026, only the following files were copied into a new empty temporary directory:

```text
build.sh
source/paper.tex
source/critical-appendix.tex
source/bounded-derivatives-appendix.tex
```

Running `bash build.sh` there succeeded and produced the complete **25-page PDF**, without LaTeX errors, undefined references, or overfull boxes. The rebuilt PDF and the distributed PDF had identical extracted text and identical renders of all 25 pages at 72 dpi. Their bytes differed only in the PDF trailer document identifiers; after normalizing those identifiers, the complete files were identical.

[build-check.json](build-check.json) records the source and PDF SHA-256 hashes, build result, page count, and comparison results. The fixed default `SOURCE_DATE_EPOCH` in the script stabilizes creation dates; PDF document identifiers may still depend on the build directory. The build requires `latexmk` and the LaTeX packages declared in the sources. The verification additionally used `pdftotext` and `pdftoppm`.

The public source is self-contained. Its two local LaTeX inclusions are `critical-appendix.tex` and `bounded-derivatives-appendix.tex`, both included in the folder. The original theorem and critical appendix remain unchanged. The new final appendix adds the bounded-derivative variant and a quantitative Gevrey-to-evaluation proposition; the abstract and folder documentation describe their scope.

## What this record does not certify

A successful PDF build establishes that the distributed source builds independently. Rendering equality checks that the isolated build reproduces the displayed manuscript. The mathematical audit is a conventional review and may miss errors; it does not have the status of a kernel-checked proof. This paper remains among the works in progress and is separate from the two batches of formalized main results.
