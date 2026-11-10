test_that("optional row constraints retain declarations without requiring fields", {
  d <- definition()
  d$sheets$Equipment$unique_key <- list("label", "serial")
  d$sheets$Equipment$at_least_one <- list(fields = list("label", "serial"), severity = "warning")
  d$sheets$Equipment$fields$label$mandatory <- FALSE
  model <- as_form_model(d)
  expect_identical(form_sheets(model)$Equipment$unique_key, list("label", "serial"))
  expect_identical(form_sheets(model)$Equipment$at_least_one, d$sheets$Equipment$at_least_one)
  expect_false(form_field(model, "Equipment.label")$mandatory)
  expect_identical(form_sheets(model)$Equipment$primary_key, list("equipment_id"))
})

test_that("row constraints reject invalid field lists and fixed-cell layouts", {
  for (kind in c("unique_key", "at_least_one")) {
    for (fields in list(list(), list("absent"), list("serial", "serial"), list(42))) {
      d <- definition()
      d$sheets$Equipment[[kind]] <- if (kind == "at_least_one") list(fields = fields) else fields
      expect_false(check_form_model(d)$valid, info = kind)
    }
    d <- definition()
    d$sheets$Metadata[[kind]] <- if (kind == "at_least_one") list(fields = list("comment")) else list("comment")
    expect_bad(d, paste0(".Metadata.", kind), "table layout")
  }
  d <- definition(); d$sheets$Equipment$at_least_one <- list(severity = "warning")
  expect_bad(d, ".at_least_one.fields", "missing required")
  for (severity in c("error", "warning", "info")) {
    d$sheets$Equipment$at_least_one <- list(fields = list("label"), severity = severity)
    expect_true(check_form_model(d)$valid)
  }
  d$sheets$Equipment$at_least_one$severity <- "notice"
  expect_bad(d, ".at_least_one.severity", "unsupported value")
})
