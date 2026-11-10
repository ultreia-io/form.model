## Check results

R CMD check --as-cran for form.model on:

* Local computer: Linux (elementary OS 8), R 4.6.2.
* GitHub Actions: Ubuntu, R 4.6.2 (release).
* GitHub Actions: Ubuntu, R-devel (2026-11-09 r90865).
* GitHub Actions: macOS, R 4.6.2 (release).
* GitHub Actions: Windows, R 4.6.2 (release, UCRT).

Results: 0 errors, 0 warnings, 1 NOTE concerning the short interval since the previous CRAN release.

## Resubmission

This resubmission fixes the invalid file URIs reported in the README for version 0.6.1.
The README now links to the public documentation pages and remains included in the source package.
