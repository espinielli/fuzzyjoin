#' Join two tables based not on exact matches, but rather with a function
#' describing whether two vectors are matched or not
#'
#' The \code{match_fun} argument is called once on a vector with all pairs
#' of unique comparisons: thus, it should be efficient and vectorized.
#'
#' @param x A tbl
#' @param y A tbl
#' @param by Columns of each to join
#' @param match_fun Vectorized function given two columns, returning
#' TRUE or FALSE as to whether they are a match
#' @param ... Extra arguments passed to match_fun
#'
#' @importFrom dplyr %>%
#'
#' @export
fuzzy_inner_join <- function(x, y, by = NULL, match_fun, ...) {
  by <- common_by(by, x, y)

  matches <- dplyr::bind_rows(lapply(seq_along(by$x), function(i) {
    col_x <- x[[by$x[i]]]
    col_y <- y[[by$y[i]]]

    indices_x <- dplyr::data_frame(col = col_x,
                                   indices = seq_along(col_x)) %>%
      tidyr::nest(indices) %>%
      dplyr::mutate(indices = purrr::map(data, "indices"))

    indices_y <- dplyr::data_frame(col = col_y,
                                   indices = seq_along(col_y)) %>%
      tidyr::nest(indices) %>%
      dplyr::mutate(indices = purrr::map(data, "indices"))

    u_x <- indices_x$col
    u_y <- indices_y$col
    m <- outer(u_x, u_y, match_fun, ...)

    # return as a data frame of x and y indices that match
    w <- which(m) - 1
    n_x <- length(u_x)
    x_indices_l <- indices_x$indices[w %% n_x + 1]
    y_indices_l <- indices_y$indices[w %/% n_x + 1]

    xls <- purrr::map_dbl(x_indices_l, length)
    yls <- purrr::map_dbl(y_indices_l, length)

    x_rep <- unlist(purrr::map2(x_indices_l, yls, function(x, y) rep(x, each = y)))
    y_rep <- unlist(purrr::map2(y_indices_l, xls, function(y, x) rep(y, each = x)))

    dplyr::data_frame(i = i, x = x_rep, y = y_rep)
  }))

  if (length(by$x) > 1) {
    # only take cases where all pairs have matches
    matches <- matches %>%
      dplyr::count(x, y) %>%
      dplyr::ungroup() %>%
      dplyr::filter(n == length(by$x))
  }
  matches <- dplyr::arrange(matches, x, y)

  # in cases where columns share a name, rename each to .x and .y
  for (n in by$x[by$x == by$y]) {
    x <- dplyr::rename_(x, .dots = structure(n, .Names = paste0(n, ".x")))
    y <- dplyr::rename_(y, .dots = structure(n, .Names = paste0(n, ".y")))
  }

  dplyr::bind_cols(x[matches$x, ], y[matches$y, ])
}
