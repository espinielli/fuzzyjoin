library(ggplot2)
library(dplyr)

context("stringdist_join")

# setup
d <- data_frame(cut2 = c("Idea", "Premiums", "Premiom",
                         "VeryGood", "VeryGood", "Faiir")) %>%
  mutate(type = row_number())

test_that("stringdist_inner_join works on a large df with multiples in each", {
  # create something with names close to the cut column in the diamonds dataset
  j <- stringdist_inner_join(diamonds, d, by = c(cut = "cut2"))

  result <- j %>%
    count(cut, cut2) %>%
    arrange(cut)

  expect_equal(as.character(result$cut), c("Fair", "Very Good", "Premium", "Premium", "Ideal"))
  expect_equal(result$cut2, c("Faiir", "VeryGood", "Premiom", "Premiums", "Idea"))

  expect_equal(sum(j$cut == "Premium"), sum(diamonds$cut == "Premium") * 2)
  expect_equal(sum(j$cut == "Very Good"), sum(diamonds$cut == "Very Good") * 2)
  expect_equal(sum(j$cut2 == "Premiom"), sum(diamonds$cut == "Premium"))

  expect_true(all(j$type[j$cut == "Faiir"] == 1))
})


d2 <- head(d, 3)
included <- c("Ideal", "Premium")
notin <- c("Fair", "Good", "Very Good")


test_that("stringdist_left_join works as expected", {
  result <- diamonds %>%
    stringdist_left_join(d2, by = c(cut = "cut2"))

  expect_true(all(is.na(result$cut2[result$cut %in% notin])))
  expect_equal(sum(result$cut %in% notin), sum(diamonds$cut %in% notin))

  expect_equal(sum(result$cut2 == "Premiom", na.rm = TRUE),
               sum(diamonds$cut == "Premium"))
  expect_equal(sum(result$cut2 == "Premiom", na.rm = TRUE),
               sum(result$cut2 == "Premiums", na.rm = TRUE))
})


d3 <- bind_rows(d2, data_frame(cut2 = "NewType", type = 4))

test_that("stringdist_right_join works as expected", {
  result <- diamonds %>%
    stringdist_right_join(d3, by = c(cut = "cut2"))

  expect_equal(sum(result$cut2 == "NewType"), 1)
  expect_equal(sum(is.na(result$cut)), 1)
  expect_true(all(is.na(result$cut[result$cut2 == "NewType"])))

  expect_equal(sum(result$cut2 == "Premiom", na.rm = TRUE),
               sum(diamonds$cut == "Premium"))
  expect_equal(sum(result$cut2 == "Premiom", na.rm = TRUE),
               sum(result$cut2 == "Premiums", na.rm = TRUE))
})


test_that("stringdist_full_join works as expected", {
  result <- diamonds %>%
    stringdist_full_join(d3, by = c(cut = "cut2"))

  expect_equal(sum(result$cut2 == "NewType", na.rm = TRUE), 1)
  expect_equal(sum(is.na(result$cut)), 1)
  expect_true(all(is.na(result$cut[result$cut2 == "NewType"])))

  expect_true(all(is.na(result$cut2[result$cut %in% notin])))
  expect_equal(sum(result$cut %in% notin), sum(diamonds$cut %in% notin))

  expect_equal(sum(result$cut2 == "Premiom", na.rm = TRUE),
               sum(diamonds$cut == "Premium"))
  expect_equal(sum(result$cut2 == "Premiom", na.rm = TRUE),
               sum(result$cut2 == "Premiums", na.rm = TRUE))
})



test_that("stringdist_semi_join works as expected", {
  result <- diamonds %>%
    stringdist_semi_join(d2, by = c(cut = "cut2"))

  expect_equal(sort(as.character(unique(result$cut))), included)

  expect_equal(nrow(result), sum(result$cut %in% included))

  expect_true(!("cut2" %in% colnames(result)))
})



test_that("stringdist_anti_join works as expected", {
  result <- diamonds %>%
    stringdist_anti_join(d2, by = c(cut = "cut2"))

  expect_equal(sort(as.character(unique(result$cut))), notin)

  expect_equal(nrow(result), sum(result$cut %in% notin))
})
