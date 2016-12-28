context("mirrors")

test_that("cran mirror gets set properly", {
  # default
  set_cran_mirror()
  expect_equal(get_cran_mirror(), "https://cloud.r-project.org/")

  # something else
  set_cran_mirror("anything_else")
  expect_equal(get_cran_mirror(), "anything_else")
})

test_that("bioconductor mirror get set properly", {
  # default
  set_bioc_mirror()
  expect_equal(get_bioc_mirror(), "https://bioconductor.org")

  set_bioc_mirror("random_bioconductor")
  expect_equal(get_bioc_mirror(), "random_bioconductor")
})
