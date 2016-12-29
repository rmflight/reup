context("local packages")

test_that("local packages works correctly", {
  old_libpaths <- .libPaths()
  old_libs <- Sys.getenv("R_LIBS")

  tmp_libpath <- file.path(tempdir(), "reup_test", "old_libs")

  if (!dir.exists(tmp_libpath)) dir.create(tmp_libpath, recursive = TRUE)
  .libPaths(c(tmp_libpath, .libPaths()))
  Sys.setenv(R_LIBS = tmp_libpath)

  on.exit({
    .libPaths(old_libpaths)
    Sys.setenv(R_LIBS = old_libs)
  }, add = TRUE)

  # reset everything
  reset_reup_options()
  # should have an error because new library is not set
  expect_error(set_local_packages())

  set_new_library()
  # still error because devtools isnt installed
  expect_error(set_local_packages())

  if(require("devtools")) {
    devtools::install("dummyDevtools", reload = FALSE, local = TRUE, quiet = TRUE,
                      lib = reup:::reup_options$new_library)
    #set_local_packages()
    expect_silent(set_local_packages())
  }
})
