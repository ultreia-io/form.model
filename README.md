# model.form

[![Build](https://github.com/ultreia-io/model.form/actions/workflows/Build.yaml/badge.svg?branch=develop)](https://github.com/ultreia-io/model.form/actions/workflows/Build.yaml?query=branch%3Adevelop)
[![Test Coverage](https://github.com/ultreia-io/model.form/actions/workflows/TestCoverage.yaml/badge.svg?branch=main)](https://github.com/ultreia-io/model.form/actions/workflows/TestCoverage.yaml?query=branch%3Amain)
[![Website](https://img.shields.io/badge/website-documentation-blue)](https://ultreia-io.github.io/model.form/)
[![Latest
release](https://img.shields.io/github/v/release/ultreia-io/model.form?display_name=tag&sort=semver)](https://github.com/ultreia-io/model.form/releases/latest)
[![License](https://img.shields.io/github/license/ultreia-io/model.form)](https://github.com/ultreia-io/model.form/blob/main/LICENSE)

Neutral, versioned form definitions with explicit YAML resources and
ordered workbook layouts.

**Model checks validate definitions. They do not validate submitted form
data.**

## Installation

Install the latest released version directly from GitHub:

``` r
install.packages("pak") # Once
pak::pak("ultreia-io/model.form@*release")
```

`pak` downloads the package and installs its dependencies automatically.

For the development version:

``` r
pak::pak("ultreia-io/model.form@develop")
```

## Start here

``` r
library(model.form)
directory <- system.file("examples", package = "model.form")
m <- load_form_model("survey", directory)

form_field(m, "Observations.unit")[c("enum", "required_field")]
form_layout(m, "Observations")$start_row
check_form_model(form_definition(m))
```

The name `survey` resolves exactly to `survey-form.yaml` in the supplied
directory.

Use separate directories for different versions. No directory scanning
or latest-version selection occurs.

Explicit file loading and exact version selection remain available:

``` r
select_form_model(
  "examples/survey-form.yaml", "survey", "2026.1",
  package = "model.form"
)
```

## Contract

- Independent schema and form versions.
- Ordered sheets, fields, fixed cells, and table columns.
- Explicit types and compact constraints, including `mandatory`.
- Declarative references supplied by callers; no embedded domain
  reference data.
- Structured definition diagnostics and ordinary list/S3 values.
- One runtime dependency: `yaml`. Loading the package has no external
  side effects.

## Model defaults and conventions

These omitted properties receive values from `model.form`:

| Model YAML                   | Effective meaning                                                             |
|------------------------------|-------------------------------------------------------------------------------|
| `mandatory` omitted          | The field may be absent or null; `form_fields()` returns `mandatory = FALSE`. |
| Reference `severity` omitted | An unknown code is an error; `form_fields()` returns `severity = "error"`.    |

Table column counts are derived from the fields. Other omissions do not invent values.

Every sheet listed under `sheets` is mandatory. There is no sheet-level
flag. Cell layouts declare `column_count`. Table column counts are derived
from the fields, whose mapping order defines column order. An explicit table
`column_count` is optional and must match the number of fields. An
optional `row_count` declares an exact extent. Fixed fields must lie
inside all declared dimensions.

`form_definition()` preserves the compact YAML declaration.
`form_sheets()` and `form_layout()` expose the derived table column counts.
`form_fields()` returns effective fields with derived full IDs, columns,
and the resolved defaults above.

## Guides

- [Getting
  started](https://ultreia-io.github.io/model.form/articles/model.form.html)
- [Model authoring and schema
  dialect](https://ultreia-io.github.io/model.form/articles/model-authoring.html)
- [Downstream package
  integration](https://ultreia-io.github.io/model.form/articles/downstream-packages.html)
- [API
  reference](https://ultreia-io.github.io/model.form/reference/index.html)
- [Contributing](CONTRIBUTING.md) and [maintenance](DEVELOPMENT.md)

## Boundaries

This package loads, checks, and exposes form definitions.

Workbook reading, submitted-data validation, and database loading belong
to consuming packages.

## License

LGPL-2.1. See
[LICENSE](https://github.com/ultreia-io/model.form/blob/develop/LICENSE).
