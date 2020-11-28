# take apart the clean_and_write function to test inner functionality before testing whole function



test_that("duplicates removed", {
  expect_lt(length(distinct(data)))
})
