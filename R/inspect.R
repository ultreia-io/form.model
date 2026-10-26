#' Check a model argument's shape
#' @param model Object passed to an accessor.
#' @return Returns silently for a `form_model` with required top-level properties;
#'   otherwise raises `model_form_error`. Does not recheck the definition.
#' @keywords internal
model_arg <- function(model) {
  required <- c("schema_version", "form", "references", "sheets")
  if (!inherits(model, "form_model") || !is.list(model) ||
      !all(required %in% names(model))) {
    abort_model("<argument>", "model", "expected a form_model; use as_form_model()")
  }
}

#' Get the complete definition
#' @param model A checked `form_model` from [`read_form_model()`][form.model::read_form_model] or [`as_form_model()`][form.model::as_form_model].
#' @return An ordinary list with `schema_version`, `form`, `references` and `sheets`.
#' @details Accessors preserve declaration order and do not revalidate models.
#'   Treat checked models as read-only. Invalid model arguments raise `model_form_error`.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' form_definition(model)$form
#' @export
form_definition <- function(model) {
  model_arg(model)
  unclass(model)
}

#' Get form identity and versions
#' @inheritParams form_definition
#' @return A list with `form` and `schema_version`.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' form_metadata(model)
#' @export
form_metadata <- function(model) {
  d <- form_definition(model)
  d[c("form", "schema_version")]
}

#' Get fields in declaration order
#' @inheritParams form_definition
#' @param sheet Exact worksheet name, or `NULL` for all sheets.
#' @return Field definitions named `<sheet>.<field>`. Unknown sheets raise `model_form_error`.
#' @details Adds field IDs, names, sheet names and numeric coordinates.
#'   Omitted `mandatory` becomes `FALSE`; reference shorthand becomes a mapping
#'   with severity `"error"` when omitted. Other undeclared properties stay absent.
#'   Use [`form_definition()`][form.model::form_definition] for the original declarations.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' form_fields(model, sheet = "Observations")
#' @export
form_fields <- function(model, sheet = NULL) {
  sheets <- form_sheets(model)
  if (!is.null(sheet)) {
    text_arg(sheet, "sheet")
    if (!sheet %in% names(sheets)) abort_model("<model>", "sheets", paste0("unknown sheet: ", sheet))
    sheets <- sheets[sheet]
  }
  result <- list()
  for (sheet_name in names(sheets)) {
    definition <- sheets[[sheet_name]]
    for (i in seq_along(definition$fields)) {
      local_name <- names(definition$fields)[[i]]
      field <- definition$fields[[i]]
      field$id <- paste(sheet_name, local_name, sep = ".")
      field$name <- local_name
      field$sheet <- sheet_name
      field$mandatory <- isTRUE(field$mandatory)
      if (definition$layout$kind == "table") field$column <- i else {
        cell <- cell_coordinates(field$location)
        field$row <- cell$row
        field$column <- cell$column
      }
      if (is.character(field$reference)) {
        field$reference <- list(id = field$reference)
      }
      if (!is.null(field$reference) && is.null(field$reference$severity)) {
        field$reference$severity <- "error"
      }
      result[[field$id]] <- field
    }
  }
  result
}

#' Get one field
#' @inheritParams form_definition
#' @param id Exact `<sheet>.<field>` identifier.
#' @return One definition as returned by [`form_fields()`][form.model::form_fields]. Unknown IDs raise `model_form_error`.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' form_field(model, "Observations.unit")$enum
#' @export
form_field <- function(model, id) {
  text_arg(id, "id")
  fields <- form_fields(model)
  if (!id %in% names(fields)) abort_model("<model>", "fields", paste0("unknown field: ", id))
  fields[[id]]
}

#' Get sheet definitions
#' @inheritParams form_definition
#' @return Sheets in declaration order, named by worksheet, each with `fields` and `layout`.
#' @details Table layouts include `column_count` derived from the ordered fields.
#'   An optional `primary_key` preserves the declared sequence of local field names.
#'   Key components must be filled and their combination must identify one row;
#'   this package checks the declaration, not submitted values.
#'   Use [`form_definition()`][form.model::form_definition] for the original declarations.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' names(form_sheets(model))
#' @export
form_sheets <- function(model) {
  sheets <- form_definition(model)$sheets
  for (name in names(sheets)) {
    if (sheets[[name]]$layout$kind == "table") {
      sheets[[name]]$layout$column_count <- length(sheets[[name]]$fields)
    }
  }
  sheets
}

#' Get a sheet layout
#' @inheritParams form_definition
#' @param id Exact worksheet name.
#' @return The effective layout (`cells` or `table`), with table `column_count`
#'   derived from the fields. Unknown sheets raise `model_form_error`.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' form_layout(model, "Observations")
#' @export
form_layout <- function(model, id) {
  text_arg(id, "id")
  sheets <- form_sheets(model)
  if (!id %in% names(sheets)) abort_model("<model>", "sheets", paste0("unknown sheet: ", id))
  sheets[[id]]$layout
}

#' Get reference requirements
#' @inheritParams form_definition
#' @return Declared reference names. Reference data is not loaded.
#' @examples
#' model <- read_form_model("examples/survey-form.yaml", "form.model")
#' form_references(model)
#' @export
form_references <- function(model) unlist(form_definition(model)$references, use.names = FALSE)

#' Print a model summary
#' @param x A checked `form_model`.
#' @param ... Unused.
#' @return `x`, invisibly; prints identity, versions, and field and sheet counts.
#' @export
print.form_model <- function(x, ...) {
  d <- form_definition(x)
  cat("<form_model> ", d$form$id, " @ ", d$form$version,
      " (schema ", d$schema_version, ")\n", sep = "")
  cat(length(form_fields(x)), "fields;", length(d$sheets), "sheets\n")
  invisible(x)
}

#' Print definition check results
#' @param x A `form_model_check` from [`check_form_model()`][form.model::check_form_model].
#' @param ... Unused.
#' @return `x`, invisibly; prints validity and any diagnostics.
#' @export
print.form_model_check <- function(x, ...) {
  cat("<form_model_check> ", if (x$valid) "valid" else "invalid", "\n", sep = "")
  if (nrow(x$diagnostics)) print(x$diagnostics, row.names = FALSE)
  invisible(x)
}

#' Decode a checked cell location
#' @param location Uppercase A1-style address already checked by the schema.
#' @return List with one-based numeric `row` and `column` coordinates.
#' @keywords internal
cell_coordinates <- function(location) {
  letters <- sub("[0-9]+$", "", location)
  list(row = as.numeric(sub("^[A-Z]+", "", location)),
       column = Reduce(function(value, digit) value * 26 + digit,
                       utf8ToInt(letters) - utf8ToInt("A") + 1, init = 0))
}
