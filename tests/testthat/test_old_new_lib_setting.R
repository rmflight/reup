context("Old and New Library Setting")

test_that("new library setting works", {
  #skip_on_cran()

  # make a temp directory to install into
  old_libpaths <- .libPaths()
  old_libs <- Sys.getenv("R_LIBS")

  tmp_libpath <- file.path(tempdir(), "reup_test", "old_libs")

  if (dir.exists(tmp_libpath)) {
    unlink(tmp_libpath, recursive = TRUE, force = TRUE)
  }
  dir.create(tmp_libpath, recursive = TRUE)


  .libPaths(c(tmp_libpath, .libPaths()))
  Sys.setenv(R_LIBS = tmp_libpath)

  # reset on exit
  on.exit({
    .libPaths(old_libpaths)
    Sys.setenv(R_LIBS = old_libs)
    unlink(tmp_libpath, force = TRUE, recursive = TRUE)
    unlink(tmp_libpath2, force = TRUE, recursive = TRUE)
  }, add = TRUE)

  curr_r_version <- paste0("R", R.version$major, ".", R.version$minor)
  curr_bioc_version <- paste0("Bioc", tools:::.BioC_version_associated_with_R_version())

  # first, with NULLs
  reup:::reset_reup_options()

  #if (require("devtools")) {

    #devtools::install("pkg1", reload = FALSE, local = TRUE, quiet = TRUE)
    dir.create(file.path(tmp_libpath, "pkg1"))
    expect_message(set_new_library(), curr_r_version)

    unlink(reup:::reup_options$new_library, recursive = TRUE)
    reup:::reset_reup_options()
    set_cran_mirror()
    set_bioc_mirror()
    expect_message(set_new_library(), curr_bioc_version)

    # now set and create an explicit old one
    tmp_libpath2 <- file.path(tempdir(), "reup_test", "parent_1", "old_library")
    if (dir.exists(tmp_libpath2)) {
      unlink(tmp_libpath2, recursive = TRUE)
    }
    dir.create(tmp_libpath2, recursive = TRUE)

    set_old_library(file.path(tmp_libpath2, "old_library"))
    dir.create(file.path(tmp_libpath2, "pkg1"))
    expect_message(set_new_library(), tmp_libpath2)

    expect_message(set_new_library(lib_loc = file.path(tmp_libpath2, "help_me")), "help_me")
    expect_equal(reup:::reup_options$new_library, file.path(tmp_libpath2, "help_me"))
  #}

})
