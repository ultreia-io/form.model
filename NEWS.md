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
