#' Join two tables based on absolute distance between their columns
#'
#' @param x A tbl
#' @param y A tbl
#' @param by Columns by which to join the two tables
#' @param max_dist Maximum distance to use for joining
#'
#' @seealso \code{\link{stringdist-methods}}
#'
#' @examples
#'
#' library(dplyr)
#'
#' head(iris)
#' sepal_lengths <- data_frame(Sepal.Length = c(5, 6, 7), Type = 1:3)
#'
#' iris %>%
#'   difference_join(sepal_lengths, max_dist = .5)
#'
#' @export
difference_join <- function(x, y, by = NULL, max_dist = 1) {
  match_fun <- function(v1, v2) {
    abs(v1 - v2) <= max_dist
  }

  fuzzy_join(x, y, by = by, match_fun = match_fun)
}
