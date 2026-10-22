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
Rscript -e 'roxygen2::roxygenise(); testthat::test_local()'
mkdir -p build
(cd build && R CMD build --no-manual ..)
package_version=$(Rscript -e 'cat(read.dcf("DESCRIPTION")[1, "Version"])')
R CMD check --no-manual --output=build "build/model.form_${package_version}.tar.gz"
Rscript tools/build-site.R
```

The site includes a native coverage page at `docs/articles/coverage.html`, using the shared theme and navigation.

Coverage CSV and XML stay in `docs/coverage/`. Archives and check output stay in `build/`.

Run `Rscript tools/coverage.R` to refresh coverage data alone; rebuild the site to refresh its page.

`roxygen2`, `rcmdcheck`, and `pkgload` are development tools, not runtime dependencies.

Review coverage gaps for missing behaviour. Check installed resources, runnable examples, and website navigation.

Keep the YAML schema authoritative. Semantic invariants live in R and must have focused behavioural tests.

## Release

1. **Prepare the release on `develop`:**

   1. **Prepare the release files:** update the version in `DESCRIPTION`, finalize `NEWS.md` and documentation.
   2. **Perform the [local checks](#local-verification).**
   3. **Commit the changes:** use `[model.form] Release <version>`, for example `[model.form] Release 0.2.0`.
   4. **Push the release commit.**

2. **Start the release on GitHub:** open **Actions → Start Release → Run workflow**, select `develop` and run it. The version is read from `DESCRIPTION`. This creates a release branch and opens a pull request to merge it into `main`.
3. **Merge the release PR:** wait for all checks to be green, then select **Create a merge commit**.

**Publish Release** then publishes the versioned package, checksum and documentation automatically.

Coverage runs automatically on pushes to `main` after the release merge, alongside publication without blocking it.

Run **Actions → Test Coverage → Run workflow** for coverage on demand. Build still runs tests on every push and PR.

## License

LGPL-2.1. See [LICENSE](LICENSE).
