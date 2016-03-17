library(ggplot2)
library(dplyr)

context("stringdist_join")

test_that("stringdist_join works on a large df with multiples in each", {
  # create something with names close to the cut column in the diamonds dataset
  d <- data_frame(cut2 = c("Idea", "Premiums", "Premiom",
                           "VeryGood", "VeryGood", "Faiir")) %>%
    mutate(type = row_number())
  j <- stringdist_join(diamonds, d, by = c(cut = "cut2"))

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
