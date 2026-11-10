pkgdown::clean_site(force = TRUE)
pkgdown::init_site()
source("tools/coverage.R")
pkgdown::build_site(new_process = FALSE, install = TRUE, preview = FALSE)

# Publish the survey files alongside the guide for direct downloads.
example_directory <- "docs/examples/survey"
dir.create(example_directory, recursive = TRUE, showWarnings = FALSE)
example_files <- file.path("inst/examples/survey", c("form.yaml", "form.xlsx", "form-empty.xlsx"))
if (!all(file.copy(example_files, example_directory, overwrite = TRUE)))
  stop("Could not copy the survey downloads into the website.", call. = FALSE)

# Include the licence file linked from the maintainer documentation.
if (!file.copy("LICENSE", "docs/LICENSE", overwrite = TRUE))
  stop("Could not copy the licence into the website.", call. = FALSE)

# Make generated links to this site independent of its deployment address.
site_url <- yaml::read_yaml("_pkgdown.yml")$url
for (page_path in list.files("docs", pattern = "[.]html$", recursive = TRUE)) {
  page_directory <- dirname(page_path)
  page_depth <- if (page_directory == ".") 0L else length(strsplit(page_directory, "/", fixed = TRUE)[[1L]])
  page_prefix <- paste(rep("../", page_depth), collapse = "")
  page_file <- file.path("docs", page_path)
  page_html <- readLines(page_file, warn = FALSE)
  for (attribute in c('href="', 'src="')) {
    page_html <- gsub(paste0(attribute, site_url, '"'),
      paste0(attribute, page_prefix, 'index.html"'), page_html, fixed = TRUE)
    page_html <- gsub(paste0(attribute, site_url), paste0(attribute, page_prefix), page_html, fixed = TRUE)
  }
  writeLines(page_html, page_file)
}
