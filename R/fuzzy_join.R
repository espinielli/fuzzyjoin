#' Join two tables based not on exact matches, but rather with a function
#' describing whether two vectors are matched or not
#'
#' The \code{match_fun} argument is called once on the pair of all unique comparisons:
#' thus, it should be efficient and vectorized.
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
fuzzy_join <- function(x, y, by = NULL, match_fun, ...) {
  by <- common_by(by, x, y)

  matches <- dplyr::bind_rows(lapply(seq_along(by$x), function(i) {
    col_x <- x[[by$x[i]]]
    col_y <- y[[by$y[i]]]

    indices_x <- data_frame(col = col_x, indices = seq_along(col_x)) %>%
      tidyr::nest(indices)
    indices_y <- data_frame(col = col_y, indices = seq_along(col_y)) %>%
      tidyr::nest(indices)

    u_x <- indices_x$col
    u_y <- indices_y$col
    n_x <- length(u_x)
    n_y <- length(u_y)

    # use col_y first so that order of x is preserved, not y
    m <- outer(u_x, u_y, match_fun)

    # return as a data frame of x and y indices that match
    w <- which(m)
    x_indices <- ((w - 1) %% n_x) + 1
    y_indices <- floor((w - 1) / n_x) + 1
    x_indices_l <- indices_x$indices[x_indices]
    y_indices_l <- indices_y$indices[y_indices]

    xls <- sapply(x_indices_l, length)
    yls <- sapply(y_indices_l, length)

    x_rep <- unlist(lapply(seq_along(x_indices_l), function(i) rep(x_indices_l[[i]], each = yls[i])))
    y_rep <- unlist(lapply(seq_along(y_indices_l), function(i) rep(y_indices_l[[i]], xls[i])))

    data_frame(i = i, x = x_rep, y = y_rep)
  }))

  if (length(by$x) > 1) {
    # only take cases where all pairs have matches
    matches <- matches %>%
      dplyr::count(x, y) %>%
      dplyr::ungroup() %>%
      dplyr::filter(n == length(by$x))
  }
  matches <- arrange(matches, x, y)

  # in cases where columns share a name, rename each to .x and .y
  for (n in by$x[by$x == by$y]) {
    x <- rename_(x, .dots = structure(n, .Names = paste0(n, ".x")))
    y <- rename_(y, .dots = structure(n, .Names = paste0(n, ".y")))
  }

  bind_cols(x[matches$x, ], y[matches$y, ])
}
