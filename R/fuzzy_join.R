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
#' TRUE or FALSE as to whether they are a match. Can be a list of functions
#' one for each pair of columns specified in \code{by} (if a named list, it
#' uses the names in x).
#' If only one function is given it is used on all column pairs.
#' @param mode One of "inner", "left", "right", "full" "semi", or "anti"
#' @param ... Extra arguments passed to match_fun
#'
#' @importFrom dplyr %>%
#'
#' @export
fuzzy_join <- function(x, y, by = NULL, match_fun,
                             mode = "inner", ...) {
  mode <- match.arg(mode, c("inner", "left", "right", "full", "semi", "anti"))

  by <- common_by(by, x, y)

  if (length(match_fun) == 1){
    match_fun <- rep(c(match_fun), length(by$x))
  }
  if (length(match_fun) != length(by$x)){
    stop("Length of match_fun not equal to columns specified in 'by'.", call. = FALSE)
  }

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

    if (!is.null(names(match_fun))) {
      # match_fun is a named list, use the names in x
      mf <- match_fun[[by$x[[i]]]]
    } else {
      mf <- match_fun[[i]]
    }

    m <- outer(u_x, u_y, mf, ...)

    # return as a data frame of x and y indices that match
    w <- which(m) - 1

    if (length(w) == 0) {
      # there are no matches
      ret <- dplyr::data_frame(i = numeric(0), x = numeric(0), y = numeric(0))
      return(ret)
    }

    n_x <- length(u_x)
    x_indices_l <- indices_x$indices[w %% n_x + 1]
    y_indices_l <- indices_y$indices[w %/% n_x + 1]

    xls <- purrr::map_dbl(x_indices_l, length)
    yls <- purrr::map_dbl(y_indices_l, length)

    x_rep <- unlist(purrr::map2(x_indices_l, yls, function(x, y) rep(x, each = y)))
    y_rep <- unlist(purrr::map2(y_indices_l, xls, function(y, x) rep(y, x)))

    dplyr::data_frame(i = i, x = x_rep, y = y_rep)
  }))

  if (length(by$x) > 1) {
    # only take cases where all pairs have matches
    matches <- matches %>%
      dplyr::count(x, y) %>%
      dplyr::ungroup() %>%
      dplyr::filter(n == length(by$x))
  }

  if (mode == "semi") {
    # just use the x indices to include
    return(x[sort(unique(matches$x)), ])
  }
  if (mode == "anti") {
    if (nrow(matches) == 0) {
      return(x)
    }
    # just use the x indices to exclude
    return(x[-sort(unique(matches$x)), ])
  }

  matches <- dplyr::arrange(matches, x, y)

  # in cases where columns share a name, rename each to .x and .y
  for (n in by$x[by$x == by$y]) {
    x <- dplyr::rename_(x, .dots = structure(n, .Names = paste0(n, ".x")))
    y <- dplyr::rename_(y, .dots = structure(n, .Names = paste0(n, ".y")))
  }

  # fill in indices of the x, y, or both
  # curious if there's a higher performance approach
  if (mode == "left") {
    matches <- dplyr::data_frame(x = seq_len(nrow(x))) %>%
      dplyr::left_join(matches, by = "x")
  } else if (mode == "right") {
    matches <- dplyr::data_frame(y = seq_len(nrow(y))) %>%
      dplyr::left_join(matches, by = "y")
  } else if (mode == "full") {
    matches <- matches %>%
      dplyr::full_join(dplyr::data_frame(x = seq_len(nrow(x))), by = "x") %>%
      dplyr::full_join(dplyr::data_frame(y = seq_len(nrow(y))), by = "y")
  }

  dplyr::bind_cols(x[matches$x, ], y[matches$y, ])
}


#' @rdname fuzzy_join
#' @export
fuzzy_inner_join <- function(x, y, by = NULL, match_fun, ...) {
  fuzzy_join(x, y, by, match_fun, mode = "inner", ...)
}


#' @rdname fuzzy_join
#' @export
fuzzy_left_join <- function(x, y, by = NULL, match_fun, ...) {
  fuzzy_join(x, y, by, match_fun, mode = "left", ...)
}


#' @rdname fuzzy_join
#' @export
fuzzy_right_join <- function(x, y, by = NULL, match_fun, ...) {
  fuzzy_join(x, y, by, match_fun, mode = "right", ...)
}


#' @rdname fuzzy_join
#' @export
fuzzy_full_join <- function(x, y, by = NULL, match_fun, ...) {
  fuzzy_join(x, y, by, match_fun, mode = "full", ...)
}


#' @rdname fuzzy_join
#' @export
fuzzy_semi_join <- function(x, y, by = NULL, match_fun, ...) {
  fuzzy_join(x, y, by, match_fun, mode = "semi", ...)
}


#' @rdname fuzzy_join
#' @export
fuzzy_anti_join <- function(x, y, by = NULL, match_fun, ...) {
  fuzzy_join(x, y, by, match_fun, mode = "anti", ...)
}
