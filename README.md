# form.model

[![Build](https://img.shields.io/github/actions/workflow/status/ultreia-io/form.model/Build.yaml?branch=develop&label=Build&logo=githubactions&logoColor=white)](https://github.com/ultreia-io/form.model/actions/workflows/Build.yaml?query=branch%3Adevelop)
[![Website](https://img.shields.io/badge/website-documentation-blue?logo=readthedocs&logoColor=white)](index.html)
[![License](https://img.shields.io/badge/license-LGPL--2.1-blue?logo=gnu&logoColor=white)](https://github.com/ultreia-io/form.model/blob/main/LICENSE)

[![Latest release](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Fultreia-io%2Fform.model%2Freleases%2Flatest&query=%24.tag_name&label=Latest%20release&color=blue&logo=github&logoColor=white)](https://github.com/ultreia-io/form.model/releases/latest)
[![CRAN release](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fcrandb.r-pkg.org%2Fform.model&query=%24.Version&label=CRAN%20release&color=brightgreen&logo=r&logoColor=white)](https://CRAN.R-project.org/package=form.model)

[![Coverage develop](https://img.shields.io/codecov/c/github/ultreia-io/form.model/develop?label=coverage%20develop&logo=codecov)](https://app.codecov.io/gh/ultreia-io/form.model/tree/develop)
[![Coverage main](https://img.shields.io/codecov/c/github/ultreia-io/form.model/main?label=coverage%20main&logo=codecov)](https://app.codecov.io/gh/ultreia-io/form.model/tree/main)

## About this project

> `form.model` gives R packages a shared definition of the Excel forms they work with.

Read the [Terminology](articles/terminology.html) for the concepts used throughout this documentation.

A **form** is an Excel workbook used to collect data. Its **form model** describes the expected structure and rules in YAML.

A form model defines:

- The sheets, their order, and the positions of fixed cells or repeated data rows.
- The fields, their types, required values and constraints.
- The keys that identify records and connect related sheets.
- The catalogue tables and named lookups required by reference fields.

The package loads these definitions, checks their consistency, and exposes them through a common R API.

A form model has an identity and version, so applications can explicitly select the definition for a particular form.

Consumers share the form model instead of each maintaining their own description of the form.

The package is independent of any domain. Concrete forms and reference catalogues belong to the packages using it.

Form model checks verify the definition itself. The related packages below use it to work with forms and submitted data.

## Related packages

- [form.references](https://github.com/ultreia-io/form.references) loads reference catalogues and resolves form model lookups.
- [form.validation](https://github.com/ultreia-io/form.validation) validates submitted data against form models and references.
- [form.tools](https://github.com/ultreia-io/form.tools) splits forms using form model layouts and keys.

## Installation

Install the latest version available on CRAN:

``` r
# Install form.model from CRAN.
install.packages("form.model")
```

Alternatively, install the latest GitHub release:

``` r
# Install the package installer once.
install.packages("pak")
# Install the latest released form.model package.
pak::pak("ultreia-io/form.model@*release")
```

`pak` downloads the package and installs its dependencies automatically.

For the development version:

``` r
# Install form.model from the development branch.
pak::pak("ultreia-io/form.model@develop")
```

## Getting started

Follow the [Getting started guide](articles/form.model.html)
to load a form model, inspect its fields and diagnose invalid definitions.

The guide includes downloads of the YAML definition, populated form and empty form.

## Guides

- [Model authoring and schema
  dialect](articles/model-authoring.html)
- [Downstream package
  integration](articles/downstream-packages.html)
- [API
  reference](reference/index.html)
- [Contributing](CONTRIBUTING.html) and [maintenance](DEVELOPMENT.html)

## License

LGPL-2.1. See
[LICENSE](https://github.com/ultreia-io/form.model/blob/develop/LICENSE).
