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
| `form.model-package.R` | Provide package-level documentation.            |

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

Run from the package root with development dependencies and LaTeX installed:

```sh
Rscript tools/check.R
```

This generates documentation, runs tests, builds and checks the archive with `--as-cran`, then builds the website.

Local and CI checks share the CRAN mirror settings in `tools/check.Renviron`. All CRAN checks remain enabled.

The **Build** workflow measures coverage with `covr` on Linux after successful checks and uploads it to Codecov.

The README coverage badge links to the Codecov report. Website builds do not run coverage checks.

Archives and check output stay in `build/`.

`roxygen2`, `rcmdcheck`, and `pkgload` are development tools, not runtime dependencies.

Review coverage gaps for missing behaviour. Check installed resources, runnable examples, and website navigation.

Keep the YAML schema authoritative. Semantic invariants live in R and must have focused behavioural tests.

## GitHub Release

1. **Prepare the release on `develop`:**

   1. **Prepare the release files:** update the version in `DESCRIPTION`, finalize `NEWS.md` and documentation.
   2. **Perform the [local checks](#local-verification).**
   3. **Commit the changes:** use `[form.model] Release <version>`, for example `[form.model] Release 0.2.0`.
   4. **Push the release commit.**

2. **Start the release on GitHub:**

   1. Open **Actions → Start Release**.
   2. Click **Run workflow**, select `develop`, then click **Run workflow** to confirm.
   3. Open the release PR created by the workflow.

3. **Merge the release PR:**

   1. **Wait for the checks:** all checks on the release PR must be green.
   2. **Merge:** click **Merge pull request**, then **Confirm merge**.
   3. Merging automatically starts the **Publish Release** workflow.

The **Publish Release** workflow:

1. Publishes the package archive, checksum and documentation.
2. **Submits the same archive to CRAN**.

## Manual CRAN submission

Use this fallback only if the release has not already been submitted by CI.

Start from a clean working tree. Replace `0.6.0` with the release version to submit.

```sh
# Fetch the published release tags.
git fetch origin --tags
# Check out the release tag.
git switch --detach 0.6.0
```

Run these commands in R from the package root, with `devtools` installed.

```r
# Build and run R CMD check --as-cran, including the PDF manual and incoming checks.
devtools::check(args = "--as-cran", manual = TRUE, remote = TRUE, error_on = "warning")

# After resolving errors and warnings and reviewing NOTES, submit the release to CRAN.
devtools::submit_cran()
```

This manual route rebuilds from the release tag. CI submits the existing GitHub archive unchanged.

Confirm CRAN's email, then wait for its checks and response.

## License

LGPL-2.1. See [LICENSE](LICENSE).
