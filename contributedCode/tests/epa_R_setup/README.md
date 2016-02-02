# Tests for EPA R installation and output formats

Test materials to check that the items listed below are working
in your R install.

**Current status:** The markdown tests seems to work quite well,
the LaTeX tests haven't been tested.

There are [markdown](./markdown) and [LaTeX](./latex) versions
of the tests.  Each subfolder contains a `reference_results`
subfolder with expected output (html, pdf, and docx for markdown, and pdf
for LaTeX).

## Items checked

 - R-Studio can generate HTML output from markdown
 - R-Studio / R-markdown can find MikTex and generate PDF
 - R-Studio etc. can knit to Word / .odt
 - MikTex can install packages on demand
 - user can install non-MikTex LaTex add-ons (already known to work)
 - MikTex can generate fonts on demand (e.g. \usepackage{times})
 - Mathematical equations in LaTeX format propagate to all targets
 - tables propagate to all targets
 - BibTeX (LaTeX citation management) works
