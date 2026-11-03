options(covr.rstudio_source_markers = FALSE)
coverage <- covr::package_coverage()
print(coverage)
output <- "docs/coverage"
dir.create(output, recursive = TRUE, showWarnings = FALSE)
covr::to_cobertura(coverage, filename = file.path(output, "coverage.xml"))
utils::write.csv(covr::tally_coverage(coverage), file.path(output, "coverage.csv"), row.names = FALSE)
print(covr::zero_coverage(coverage))

# Generate a local badge so previews do not read coverage from another deployment.
coverage_rows <- covr::tally_coverage(coverage)
coverage_percentage <- sprintf("%.1f%%", 100 * mean(coverage_rows$value > 0))
coverage_badge <- sprintf('<svg xmlns="http://www.w3.org/2000/svg" width="130" height="20" role="img" aria-label="Coverage: %s"><title>Coverage: %s</title><rect width="76" height="20" fill="#555"/><rect x="76" width="54" height="20" fill="#4c1"/><g fill="#fff" text-anchor="middle" font-family="Verdana,sans-serif" font-size="11"><text x="38" y="14">coverage</text><text x="103" y="14">%s</text></g></svg>', coverage_percentage, coverage_percentage, coverage_percentage)
writeLines(coverage_badge, file.path(output, "badge.svg"))
