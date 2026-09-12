# Rebuilding the documents

The editable Markdown files are the document content; the package also includes generated standalone LaTeX sources. No economics is computed by the document build.

Rebuild the shipped standalone sources:

```sh
cd docs
latexmk -pdf -interaction=nonstopmode -halt-on-error architecture.tex
latexmk -pdf -interaction=nonstopmode -halt-on-error proof_ledger.tex
```

To regenerate LaTeX from edited Markdown, use `tools/build_docs.sh` from the repository root. This requires Pandoc, a TeX installation with the packages used in `docs/header.tex`, and `latexmk`. Inspect the resulting PDF pages visually, particularly long tables and displayed equations. A successful TeX exit code is not a layout review.

After implementation, keep statements synchronized with the manifest and exact elaborated Lean declarations; update the readable proof text rather than merely changing status labels. The package's initial ledger is a specification only.

To rebuild only the ledger after milestone 00, run `bash tools/build_docs.sh proof_ledger`. The ledger header renders the literal Lean audit symbols.
