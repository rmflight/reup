check_new_library <- function(){
  if (is.null(get_new_library())) {
    stop("A new library must be set first!")
  }
}

setup_devtools <- function(){

  set_libpaths <- function(){
    if (.libPaths()[1] != get_new_library()) {
      .libPaths(c(get_new_library(), .libPaths()))
    }
  }

  check_new_library()

  if (suppressWarnings(require("devtools", lib.loc = get_new_library(), quietly = TRUE))) {
    set_libpaths()
  } else {
    install.packages("devtools", lib = get_new_library(), repos = get_cran_mirror())
    if (!suppressWarnings(require("devtools", lib.loc = get_new_library(), quietly = TRUE))) {
      stop("devtools could not be installed, please install it to install local packages.")
    } else {
      set_libpaths()
    }
  }
}

setup_bioc <- function(){
  check_new_library()
  if (!suppressWarnings(require("BiocInstaller", lib.loc = get_new_library(), quietly = TRUE))) {
    source("https://bioconductor.org/biocLite.R")

    if (!suppressWarnings(require("BiocInstaller", lib.loc = get_new_library(), quietly = TRUE))) {
      stop("BiocInstaller not available, should be installed for installing Bioconductor packages!")
    }
  }
}

bioc_installer <- function(remote_info){
  pkg_name <- remote_info$Package
  BiocInstaller::biocLite(pkg_name, suppressUpdates = TRUE,
                          lib = reup_options$new_library)
}

cran_installer <- function(remote_info){
  pkg_name <- remote_info$Package
  install.packages(pkg_name, lib = reup_options$new_library,
                   repos = get_cran_mirror())
}

local_installer <- function(remote_info){
  pkg_name <- remote_info$remote
  devtools::install(pkg_name, reload = FALSE, local = TRUE, quiet = FALSE)
}

github_installer <- function(remote_info){
  pkg_name <- paste0(remote_info$remote, "@", remote_info$branch)
  devtools::install_github(pkg_name, reload = FALSE, local = TRUE, quiet = FALSE)
}

#' install packages
#'
#' Try to install a list of packages in a \code{data.frame}. Installation success
#' is determined by comparing to results of \code{installed.packages}, so the list
#' of uninstalled may not be exactly correct if a package was installed previously.
#'
#' @param pkg_frame data.frame of packages to be installed
#' @param install_fun the installation function to use
#'
#' @export
#' @return data.frame
install_packages <- function(pkg_frame, install_fun){

  # try to install each of the packages listed once
  # done in a while loop, because even though we might have a low number of dependencies,
  # we haven't installed our dependencies yet, which means other things might get
  # installed. We don't want to have to install those again either.
  pkg_frame$try_install <- TRUE
  pkg_frame <- pkg_frame[order(pkg_frame$n_deps, decreasing = TRUE), ]
  while (any(pkg_frame$try_install)) {
    ipkg <- min(which(pkg_frame$try_install))
    pkg_frame[ipkg, "try_install"] <- FALSE # don't try it again
    install_fun(pkg_frame[ipkg, ])

    all_installed <- rownames(installed.packages(lib.loc = reup:::reup_options$new_library))
    pkg_frame[(pkg_frame$Package %in% all_installed), "try_install"] <- FALSE
  }

  all_installed <- rownames(installed.packages(lib.loc = reup:::reup_options$new_library))
  not_installed <- pkg_frame[!(pkg_frame$Package %in% all_installed), ]
  not_installed
}

#' reup
#'
#' actually tries to do the upgrade of packages using `install.packages`.
#'
#' @param ... various options, normally set using the setter functions
#'
#' @export
reup <- function(...){
  # get all the options needed
  # generate the package data.frame
  pkg_matrix <- compare_old_new_library()
  pkg_deps <- n_package_deps(pkg_matrix)
  pkg_frame <- package_type(pkg_deps)

  split_type <- split(pkg_frame, pkg_frame$type)

  split_type <- lapply(split_type, function(x){
    x[order(x$n_deps, decreasing = FALSE), ]
  })

  # save the NA pkgs so we can tell the user about them
  # if (!is.null(split_type$`NA`)) {
  #   na_pkgs <- split_type$`NA`
  #   split_type$`NA` <- NULL
  # }

  # try cran and bioconductor twice in case of funny chicken egg dependencies
  if (!is.null(split_type[["cran"]]) && !is.null(get_cran_mirror())) {
    split_type[["cran"]] <- install_packages(split_type[["cran"]], cran_installer)
  }

  if (!is.null(split_type[["bioconductor"]]) && !is.null(get_bioc_mirror())) {
    setup_bioc()
    split_type[["bioconductor"]] <- install_packages(split_type[["bioconductor"]], bioc_installer)
  }

  if (!is.null(split_type[["cran"]]) && !is.null(get_cran_mirror())) {
    if (nrow(split_type[["cran"]]) != 0) {
      split_type[["cran"]] <- install_packages(split_type[["cran"]], cran_installer)
    }

  }

  if (!is.null(split_type[["bioconductor"]]) && !is.null(get_bioc_mirror())) {
    if (nrow(split_type[["bioconductor"]]) != 0) {
      split_type[["bioconductor"]] <- install_packages(split_type[["bioconductor"]], bioc_installer)
    }
  }

  if (!is.null(split_type[["github"]])) {
    setup_devtools()
    split_type[["github"]] <- install_packages(split_type[["github"]], github_installer)
  }

  if (!is.null(split_type[["local"]])) {
    setup_devtools()
    split_type[["local"]] <- install_packages(split_type[["local"]], local_installer)
  }

  out_pkgs <- do.call(rbind, split_type)
  if (nrow(out_pkgs) == 0) {
    message("All packages successfully installed!")
  }
  out_pkgs
}
