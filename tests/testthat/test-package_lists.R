context("package_lists")

test_that("comparing package lists works", {
  old_libpaths <- .libPaths()
  old_libs <- Sys.getenv("R_LIBS")

  tmp_libpath <- file.path(tempdir(), "reup_test", "old_libs")

  if (!dir.exists(tmp_libpath)) dir.create(tmp_libpath, recursive = TRUE)
  .libPaths(c(tmp_libpath, .libPaths()))
  Sys.setenv(R_LIBS = tmp_libpath)

  # reset on exit
  on.exit({
    .libPaths(old_libpaths)
    Sys.setenv(R_LIBS = old_libs)
  }, add = TRUE)

  reset_reup_options()

  set_new_library()

  if (require("devtools")) {

    devtools::install("pkg1", reload = FALSE, local = TRUE, quiet = TRUE)
    devtools::install("pkg2", reload = FALSE, local = TRUE, quiet = TRUE)
    devtools::install("pkg3", reload = FALSE, local = TRUE, quiet = TRUE)

    .libPaths(c(reup:::reup_options$new_library))
    devtools::install("pkg1", reload = FALSE, local = TRUE, quiet = TRUE)
    #set_local_packages()
    new_pkgs <- compare_old_new_library()
    rownames(new_pkgs)
    expect_equal(c("pkg2", "pkg3"), rownames(new_pkgs))
  }
})

data("pkg_matrix")

test_that("counting number of dependencies", {
  expect_equal_to_reference(n_package_deps(pkg_matrix), "pkg_frame.rds")
})

test_that("getting install types", {
  pkg_frame <- n_package_deps(pkg_matrix)
  expect_equal_to_reference(package_type(pkg_frame), "pkg_types.rds")
})
