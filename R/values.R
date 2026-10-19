#' Check a scalar against a form field type
#'
#' Share field-type checks between model definitions and validation consumers.
#' Requiredness and other field constraints are handled by the caller.
#' @param x Scalar value to check, without coercion.
#' @param type One of `string`, `email`, `integer`, `number`, `boolean`,
#'   `latitude`, `longitude`, `date`, or `datetime`.
#' @return One logical value; `FALSE` for missing or incompatible values,
#'   unsupported types, or classed values such as factors, `Date`, and `POSIXct`.
#' @details Dates require `YYYY-MM-DD`; datetimes require `YYYY-MM-DDTHH:MM:SSZ`.
#'   Both must parse and format back to the identical string, using UTC for
#'   datetimes. Emails require nonempty local and domain parts, a domain dot,
#'   and no whitespace or additional at signs. Mailbox existence is not checked.
#'   Numeric values must be finite; integers must have no fractional part.
#'   Coordinates are decimal degrees: latitude is in `[-90, 90]` and longitude
#'   in `[-180, 180]`, including both endpoints. Numeric text is not coerced.
#' @examples
#' form_value_matches_type("contact@example.org", "email")
#' form_value_matches_type("2026-10-18T12:00:00Z", "datetime")
#' @export
form_value_matches_type <- function(x, type) {
  if (!scalar_type(type, "string") ||
      !type %in% c("string", "email", "integer", "number", "latitude", "longitude", "boolean", "date", "datetime")) return(FALSE)
  if (type == "latitude") return(scalar_type(x, "number") && x >= -90 && x <= 90)
  if (type == "longitude") return(scalar_type(x, "number") && x >= -180 && x <= 180)
  if (type == "email") return(scalar_type(x, "string") && grepl("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", x, perl = TRUE))
  if (type %in% c("date", "datetime")) {
    if (!scalar_type(x, "string")) return(FALSE)
    pattern <- if (type == "date") "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" else
      "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"
    if (!grepl(pattern, x)) return(FALSE)
    parsed <- if (type == "date") as.Date(x, format = "%Y-%m-%d") else
      as.POSIXct(strptime(x, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
    if (is.na(parsed)) return(FALSE)
    fmt <- if (type == "date") "%Y-%m-%d" else "%Y-%m-%dT%H:%M:%SZ"
    return(identical(format(parsed, fmt, tz = "UTC"), x))
  }
  scalar_type(x, type)
}
