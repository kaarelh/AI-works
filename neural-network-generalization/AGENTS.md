# Manuscript author convention

The user requires alphabetical author order on all current and future papers and named-author companions in this folder, including AI coauthors.

- Alphabetize human authors by family name and AI authors by their credited display name. The usual order is **ChatGPT-6 Astra; Claude (when credited); Kaarel Hänni; Dmitry Vaintrob**.
- Preserve each paper's actual author roster. This ordering rule is not a reason to add contributors or convert recipients into coauthors.
- Use the user's preferred credit **ChatGPT-6 Astra** for this OpenAI coauthor. Do not list OpenAI Codex as a second author identity for the same contribution.
- For multi-author LaTeX papers, match the established format by attaching `\thanks{Authors are listed in alphabetical order.}` to the last author in `\author{...}`. Retain any additional substantive information already in the author footnote. Authored Markdown manuscripts should use the same sentence in a footnote.
- Keep the visible roster, PDF `pdfauthor` metadata, any README author list, and the catalog's `authors` array consistent. Rebuild affected published PDFs and update current catalog/checksum records.
- Preserve single-author audits, preparer/recipient distinctions, and explicitly archived provenance copies. Do not invent a roster for an unnamed research note.
- Check the rendered first-page order and footnote after rebuilding. Author-only revisions must preserve mathematical statements, proofs, and Lean sources.
