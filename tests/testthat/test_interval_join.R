context("interval_join")

x1 <- data.frame(id1 = 1:3, start = c(1, 5, 10), end = c(3, 7, 15))
y1 <- data.frame(id2 = 1:3, start = c(2, 4, 16), end = c(4, 8, 20))
b1 <- c("start", "end")

x2 <- data.frame(id1 = 1:3, start1 = c(1, 5, 10), end1 = c(3, 7, 15))
y2 <- data.frame(id2 = 1:3, start2 = c(2, 4, 16), end2 = c(4, 8, 20))
b2 <- c(start1 = "start2", end1 = "end2")

test_that("Can inner join on intervals", {
  j <- interval_inner_join(x1, y1, by = b1)
  expect_equal(nrow(j), 2)
  expect_equal(colnames(j), c("id1", "start.x", "end.x", "id2", "start.y", "end.y"))
  expect_equal(j$id1, 1:2)
  expect_equal(j$id2, 1:2)

  j2 <- interval_inner_join(x2, y2, by = b2)
  expect_equal(nrow(j2), 2)
  expect_equal(colnames(j2), c("id1", "start1", "end1", "id2", "start2", "end2"))
  expect_equal(j2$id1, 1:2)
  expect_equal(j2$id2, 1:2)
})

test_that("Can do non-inner joins on intervals", {
  j_left <- interval_left_join(x1, y1, by = b1)
  expect_equal(nrow(j_left), 3)
  expect_equal(j_left$start.x, x1$start)
  expect_equal(j_left$start.y, c(2, 4, NA))

  j_right <- interval_right_join(x1, y1, by = b1)
  expect_equal(nrow(j_right), 3)
  expect_equal(j_right$start.y, y1$start)
  expect_equal(j_right$start.x, c(1, 5, NA))

  j_full <- interval_full_join(x1, y1, by = b1)
  expect_equal(nrow(j_full), 4)
  expect_equal(j_full$start.x, c(x1$start, NA))
  expect_equal(j_full$start.y, c(2, 4, NA, 16))

  j_semi <- interval_semi_join(x1, y1, by = b1)
  expect_equal(j_semi, x1[1:2, ])

  j_anti <- interval_anti_join(x1, y1, by = b1)
  expect_equal(j_anti, x1[3, ])
})

test_that("Can do non-inner joins on intervals with findOverlaps arguments", {
  j_maxgap <- interval_inner_join(x1, y1, maxgap = 1)
  expect_equal(j_maxgap$id1, c(1, 1, 2, 2, 3))
  expect_equal(j_maxgap$id2, c(1, 2, 1, 2, 3))
})
