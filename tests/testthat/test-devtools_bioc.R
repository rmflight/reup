context("devtools & bioconductor")

test_that("devtools and bioconductor setups work", {
  old_libpaths <- .libPaths()
  old_libs <- Sys.getenv("R_LIBS")

  tmp_libpath <- file.path(tempdir(), "reup_test", "old_libs")

  if (dir.exists(tmp_libpath)) {
    unlink(tmp_libpath, recursive = TRUE, force = TRUE)
  }
  dir.create(file.path(tmp_libpath, "pkg1"), recursive = TRUE)


  .libPaths(c(tmp_libpath, .libPaths()))
  Sys.setenv(R_LIBS = tmp_libpath)

  # reset on exit
  on.exit({
    .libPaths(old_libpaths)
    Sys.setenv(R_LIBS = old_libs)
    unlink(tmp_libpath, force = TRUE, recursive = TRUE)
    #unlink(tmp_libpath2, force = TRUE, recursive = TRUE)
  }, add = TRUE)

  # reset everything
  reset_reup_options()
  # should have an error because new library is not set
  expect_error(setup_devtools())
  expect_error(setup_bioc())

})
