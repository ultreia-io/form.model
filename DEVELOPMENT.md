# Maintainer guide

`develop` is the integration branch. `main` contains releases. Implementation branches use `feature/`.

## Code organization

The files organize functions in one package namespace. You do not source each file separately.

| File                   | Responsibility                                  |
| ---------------------- | ----------------------------------------------- |
| `read.R`               | Locate resources and parse YAML.                |
| `check.R`              | Check definitions and construct checked models. |
| `inspect.R`            | Retrieve model properties and print summaries.  |
| `values.R`             | Provide shared field-type checks.               |
| `model.form-package.R` | Provide package-level documentation.            |

Loading follows this call sequence:

```text
read_form_model()
  +-- form_resource()       Resolve the path when package is supplied
  +-- read_yaml_data()
  |     +-- yaml_profile()  Reject excluded YAML constructs
  |     +-- yaml::yaml.load() Parse data without evaluating expressions
  +-- as_form_model()
        +-- check_form_model()
              +-- form_schema()    Load the package-owned structural schema
              +-- schema_check()   Check properties and value types
              +-- semantic_check() Check references and consistency
```

Model definitions are checked in two steps:

1. **Structure:** required properties and their types, such as a field's `type`.
2. **Consistency:** valid combinations, such as unique cell locations and `minimum <= maximum`.

Consistency checks run only when structure passes.

`check_form_model()` returns diagnostics. `read_form_model()` and `as_form_model()` reject invalid definitions.

## Local verification

Run from the package root with development dependencies installed:

```sh
Rscript -e 'roxygen2::roxygenise(); rmarkdown::render("README.Rmd"); testthat::test_local()'
mkdir -p build
(cd build && R CMD build --no-manual ..)
R CMD check --no-manual --output=build build/model.form_0.1.0.tar.gz
Rscript tools/build-site.R
```

The site includes a native coverage page at `docs/articles/coverage.html`, using the shared theme and navigation.

Coverage CSV and XML stay in `docs/coverage/`. Archives and check output stay in `build/`.

Run `Rscript tools/coverage.R` to refresh coverage data alone; rebuild the site to refresh its page.

`roxygen2`, `rcmdcheck`, and `pkgload` are development tools, not runtime dependencies.

Review coverage gaps for missing behaviour. Check installed resources, runnable examples, and website navigation.

Keep the YAML schema authoritative. Semantic invariants live in R and must have focused behavioural tests.

## Release

Prepare DESCRIPTION and NEWS on `develop`, then commit and push.

Open **Actions → Perform Release → Run workflow**, select `develop`, enter the version, and run it.

The workflow checks the selected commit, creates its tag and GitHub Release, and uploads the archive and checksum.

It then deploys the documentation from the same commit.

Verify the workflow and release assets. If publication fails, rerun the failed job.

## License

LGPL-2.1. See [LICENSE](LICENSE).
