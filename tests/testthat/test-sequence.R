test_that("sequence declarations require valid table grouping and integer starts", {
  d <- list(schema_version = "1.0.0", form = list(id = "sequence", version = "1"),
    references = list(), sheets = list(Items = list(layout = list(kind = "table", start_row = 1L),
      fields = list(group = list(type = "string"), item = list(type = "string",
        sequence = list(start = 1L, group_by = list("group")))))))
  expect_true(check_form_model(d)$valid)
  bad <- d; bad$sheets$Items$fields$item$sequence$start <- 1.5
  expect_bad(bad, ".sequence.start", "integer")
  bad <- d; bad$sheets$Items$fields$item$sequence$group_by <- list("absent")
  expect_bad(bad, ".sequence", "unknown grouping field")
  bad <- d; bad$sheets$Items$fields$item$sequence$group_by <- list("group", "group")
  expect_bad(bad, ".sequence", "duplicate sequence grouping fields")
  bad <- d; bad$sheets$Items$fields$item$sequence$group_by <- list("item")
  expect_bad(bad, ".sequence", "group by itself")
  bad <- d; bad$sheets$Items$fields$item$type <- "number"
  expect_bad(bad, ".sequence", "integer or string")
  bad <- d; bad$sheets$Items$layout <- list(kind = "cells")
  bad$sheets$Items$fields$group$location <- "A1"
  bad$sheets$Items$fields$item$location <- "B1"
  expect_bad(bad, ".sequence", "table layout")
})
