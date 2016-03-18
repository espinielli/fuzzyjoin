#' Join two tables based on fuzzy string matching of their columns
#'
#' Join two tables based on fuzzy string matching of their columns.
#' This is useful, for example, in matching free-form inputs in
#' a survey or online form, where it can catch misspellings and
#' small personal changes.
#'
#' @param x A tbl
#' @param y A tbl
#' @param by Columns by which to join the two tables
#' @param max_dist Maximum distance to use for joining
#' @param ignore_case Whether to be case insensitive (default yes)
#' @param ... Arguments passed on to \code{\link{stringdist}},
#' most notably "method": see \code{stringdist-methods} in the
#' stringdist package.
#'
#' @examples
#'
#' library(dplyr)
#' library(ggplot2)
#' data(diamonds)
#'
#' d <- data_frame(approximate_name = c("Idea", "Premiums", "Premioom",
#'                                      "VeryGood", "VeryGood", "Faiir"),
#'                 type = 1:6)
#'
#' # no matches when they are inner-joined:
#' diamonds %>%
#'   inner_join(d, by = c(cut = "approximate_name"))
#'
#' # but we can match when they're fuzzy joined
#' diamonds %>%
#'  stringdist_inner_join(d, by = c(cut = "approximate_name"))
#'
#' @export
stringdist_inner_join <- function(x, y, by = NULL, max_dist = 2, ignore_case = FALSE, ...) {
  match_fun <- function(v1, v2) {
    if (ignore_case) {
      v1 <- stringr::str_to_lower(v1)
      v2 <- stringr::str_to_lower(v2)
    }

    dists <- stringdist::stringdist(v1, v2, ...)
    dists <= max_dist
  }

  fuzzy_inner_join(x, y, by = by, match_fun = match_fun)
}
