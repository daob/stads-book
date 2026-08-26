#!/usr/bin/env Rscript
# Report the R packages the book's code chunks and analysis scripts use, and
# which of them are missing on this machine.
#
# This check is for local work only: continuous integration renders the book
# from the frozen output in _freeze/ and needs no R packages at all.
#
# Usage:  Rscript tests/test-dependencies.R [--strict]
# With --strict the script exits non-zero when a package is missing.

root <- normalizePath(file.path(dirname(sub("^--file=", "",
          grep("^--file=", commandArgs(), value = TRUE)[1])), ".."))

files <- c(list.files(root, pattern = "\\.qmd$", full.names = TRUE),
           list.files(file.path(root, "analysis"), pattern = "\\.R$",
                      full.names = TRUE, recursive = TRUE),
           list.files(file.path(root, c("diagrams", "figures")),
                      pattern = "\\.R$", full.names = TRUE))

text <- unlist(lapply(files, readLines, warn = FALSE))
text <- text[!grepl("^\\s*#", text)]

pkgs <- unique(c(
  sub(".*\\b(?:library|require|requireNamespace)\\(\\s*[\"']?([A-Za-z][A-Za-z0-9.]*).*",
      "\\1", grep("\\b(library|require|requireNamespace)\\(", text, value = TRUE)),
  regmatches(text, regexpr("\\b[A-Za-z][A-Za-z0-9.]*(?=::)", text, perl = TRUE))
))
pkgs <- sort(setdiff(pkgs, c("base", "stats", "utils", "graphics", "grDevices",
                             "methods", "datasets", "tools", "parallel")))

installed <- vapply(pkgs, function(p) requireNamespace(p, quietly = TRUE), logical(1))
cat(sprintf("dependencies: %d packages used, %d installed, %d missing\n",
            length(pkgs), sum(installed), sum(!installed)))
if (any(!installed)) {
  cat("  missing:", paste(pkgs[!installed], collapse = ", "), "\n")
  cat('  install with: install.packages(c(',
      paste(sprintf('"%s"', pkgs[!installed]), collapse = ", "), '))\n', sep = "")
}
if ("--strict" %in% commandArgs(TRUE) && any(!installed)) quit(status = 1)
