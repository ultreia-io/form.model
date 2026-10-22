#' Check restricted YAML syntax
#' @param text YAML source text.
#' @param resource Source label for errors.
#' @details Rejects tags, anchors, aliases, merges, directives and document markers
#'   outside quoted strings, comments and block scalars. Parsing happens separately.
#' @return Returns silently on success; raises `model_form_error` otherwise.
#' @keywords internal
yaml_profile <- function(text, resource) {
  lines <- strsplit(text, "\n", fixed = TRUE)[[1L]]
  quote <- ""
  block <- NULL
  for (i in seq_along(lines)) {
    line <- lines[[i]]
    indent <- nchar(line) - nchar(sub("^ *", "", line))
    if (!is.null(block)) {
      if (!nzchar(trimws(line)) || indent > block) next
      block <- NULL
    }
    chars <- strsplit(line, "", fixed = TRUE)[[1L]]
    visible <- ""
    j <- 1L
    while (j <= length(chars)) {
      ch <- chars[[j]]
      if (nzchar(quote)) {
        if (quote == '"' && ch == "\\") {
          j <- j + 2L
          next
        }
        if (ch == quote) {
          if (quote == "'" && j < length(chars) && chars[[j + 1L]] == "'") {
            j <- j + 2L
            next
          }
          quote <- ""
        }
        visible <- paste0(visible, " ")
      } else if (ch %in% c("'", '"') &&
                 (j == 1L || grepl("[[:space:]:,\\[{?-]$", visible))) {
        quote <- ch
        visible <- paste0(visible, "Q")
      } else {
        if (ch == "#" && (j == 1L || grepl("[[:space:]]$", visible))) break
        visible <- paste0(visible, ch)
      }
      j <- j + 1L
    }
    if (grepl("(^[[:space:]]*([-?][[:space:]]+)?|:[[:space:]]+|[\\[{,][[:space:]]*)[!&*]|(^|[[:space:],{])<<[[:space:]]*:|^%|^---|^\\.\\.\\.", visible)) {
      abort_model(resource, paste0("$ (line ", i, ")"),
                  "YAML tags, anchors, aliases, merges, directives and document markers are unsupported")
    }
    if (grepl("[|>][-+0-9]*[[:space:]]*$", visible)) block <- indent
  }
}

#' Signal a model error
#' @param resource Source label.
#' @param path Location within the source.
#' @param message Error message.
#' @param diagnostics Optional definition diagnostics.
#' @return Raises `model_form_error` carrying the supplied context.
#' @keywords internal
abort_model <- function(resource, path, message, diagnostics = NULL) {
  stop(structure(list(message = paste0(resource, ": ", path, ": ", message),
                      call = NULL, resource = resource, path = path,
                      diagnostics = diagnostics),
                 class = c("model_form_error", "error", "condition")))
}

#' Require a nonempty string
#' @param x Value to check; whitespace is not trimmed.
#' @param name Argument name for errors.
#' @return Returns silently on success; raises `model_form_error` otherwise.
#' @keywords internal
text_arg <- function(x, name) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    abort_model("<argument>", name, "expected one nonempty string")
  }
}

#' Read restricted YAML as data
#' @param path UTF-8 YAML file.
#' @return Parsed data: named lists for mappings and unnamed lists for sequences.
#' @details Uses YAML 1.1 types without expression evaluation. Invalid syntax,
#'   non-string keys and parser warnings raise `model_form_error`.
#' @keywords internal
read_yaml_data <- function(path) {
  text_arg(path, "path")
  if (!file.exists(path) || dir.exists(path)) abort_model(path, "$", "file does not exist or is not a regular file")
  tryCatch({
    text <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    yaml_profile(text, path)
    # Keep sequences as lists and check map key types before string conversion.
    handler_error <- NULL
    handlers <- list(seq = identity, map = function(x) {
      keys <- attr(x, "keys")
      if (!all(vapply(keys, function(k) is.character(k) && length(k) == 1L && !is.na(k), logical(1)))) {
        handler_error <<- "mapping keys must be strings; quote numeric or boolean codes"
        return(x)
      }
      attr(x, "keys") <- NULL
      names(x) <- vapply(keys, identity, character(1))
      x
    })
    result <- withCallingHandlers(yaml::yaml.load(text, as.named.list = FALSE,
      handlers = handlers, eval.expr = FALSE), warning = function(w) stop(conditionMessage(w)))
    if (!is.null(handler_error)) abort_model(path, "$", handler_error)
    result
  }, error = function(e) {
    if (inherits(e, "model_form_error")) stop(e)
    abort_model(path, "$", conditionMessage(e))
  })
}

#' Locate an installed resource
#' @param path File path relative to the package directory.
#' @param package Installed package name.
#' @return Absolute file path. Missing files and paths escaping the package
#'   raise `model_form_error`.
#' @examples
#' form_resource("examples/survey-form.yaml", "form.model")
#' @export
form_resource <- function(path, package) {
  text_arg(path, "path")
  text_arg(package, "package")
  if (grepl("^[/\\\\~]|^[A-Za-z]:|(^|[/\\\\])\\.\\.([/\\\\]|$)", path)) {
    abort_model(package, path, "expected a relative path without parent traversal")
  }
  root <- system.file(package = package)
  if (!nzchar(root)) abort_model(package, path, "package is not installed")
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- file.path(root, path)
  if (!file.exists(file) || dir.exists(file)) abort_model(package, path, "resource file does not exist")
  file <- normalizePath(file, winslash = "/", mustWork = TRUE)
  if (!startsWith(file, paste0(root, "/"))) abort_model(package, path, "resource escapes package directory")
  file
}

#' Read and check a YAML form model
#' @param path File path, or package-relative path when `package` is supplied.
#' @param package Optional installed package name.
#' @return A checked `form_model` list. Invalid YAML or definitions raise
#'   `model_form_error` with source context and available diagnostics.
#' @details Uses YAML 1.1 types: quote versions and codes; use `true`/`false`
#'   for booleans. Tags, anchors, aliases, merges, directives and document markers
#'   are unsupported. The source path is not stored in the model.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' form_metadata(model)
#' @export
read_form_model <- function(path, package = NULL) {
  if (!is.null(package)) path <- form_resource(path, package)
  definition <- read_yaml_data(path)
  as_form_model(definition, normalizePath(path, winslash = "/", mustWork = TRUE))
}

#' Load a model by filename prefix
#' @param name Prefix of `<name>-form.yaml`, starting with a letter and containing
#'   only letters, digits, underscores, dots or hyphens.
#' @param directory Directory containing the file.
#' @return A checked `form_model`; see [`read_form_model()`][form.model::read_form_model] for errors.
#' @examples
#' directory <- system.file("examples", package = "form.model")
#' load_form_model("survey", directory)
#' @export
load_form_model <- function(name, directory) {
  text_arg(name, "name")
  text_arg(directory, "directory")
  if (!grepl("^[A-Za-z][A-Za-z0-9_.-]*$", name)) {
    abort_model("<argument>", "name", "expected a model name without a path or file suffix")
  }
  read_form_model(file.path(directory, paste0(name, "-form.yaml")))
}

#' Select an exact model version
#' @param paths Nonempty character vector of YAML file paths.
#' @param id Exact form identifier.
#' @param version Exact form version.
#' @param package Optional installed package containing the relative paths.
#' @return The matching `form_model`. All files are checked; invalid files or
#'   anything other than one match raise `model_form_error`.
#' @examples
#' select_form_model("examples/survey-form.yaml", "survey", "2026.1",
#'                   package = "form.model")
#' @export
select_form_model <- function(paths, id, version, package = NULL) {
  if (!is.character(paths) || !length(paths) || anyNA(paths) || any(!nzchar(paths))) {
    abort_model("<selection>", "paths", "expected explicit resource paths")
  }
  text_arg(id, "id")
  text_arg(version, "version")
  models <- lapply(paths, read_form_model, package = package)
  matches <- vapply(models, function(m) {
    d <- form_definition(m)
    identical(d$form$id, id) && identical(d$form$version, version)
  }, logical(1))
  if (sum(matches) != 1L) {
    abort_model(paste(paths, collapse = ", "), "$",
                paste0("exact selection matched ", sum(matches), " resources for ",
                       id, " / ", version))
  }
  models[[which(matches)]]
}
