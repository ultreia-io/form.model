# form.model 0.3.2

* Fix README documentation links and clarify the package description for CRAN checks.

# form.model 0.3.1

* Include R documentation in Git tags for direct source installation.
* Add a README badge showing the published test coverage percentage.
* Improve the website footer with company, copyright and license links.
* Use the latest R container in Linux CI and improve website dependency caching.
* Prepare for CRAN submission with a working maintainer email and the packaged vignette index.

# form.model 0.3.0

* Fix CI and release automation, including coverage uploads and documentation deployment.

# form.model 0.2.0

* Rename the package from `model.form` to `form.model`; update installation references and namespace calls.

* Derive table column counts from the ordered field definitions; remove redundant `layout.column_count` declarations.
* Simplify installation instructions and guide navigation; maintain the README directly in Markdown.
* Introduce release pull requests with manual merging, followed by package and documentation publication.

# model.form 0.1.0

* Load versioned YAML form definitions and check them against schema 1.0.0 and semantic constraints.
* Inspect ordered sheets, fields, cell and table layouts, and reference requirements.
* Support string, email, integer, number, boolean, latitude, longitude, date, and datetime fields.
* Define mandatory and conditional fields, enums, bounds, patterns, uniqueness, and code-list references.
* Expose shared field type checks for downstream validation packages.
* Include a complete survey example and guides for model authors and downstream packages.
