#' setup devtools
#'
#' Makes modifications suitable for doing installations using \code{devtools} for
#' local and / or github based packages.
#'
#' @return NULL
#' @export
setup_devtools <- function(){
  if (.libPaths()[1] != reup_options$new_library) {
    .libPaths(c(reup_options$new_library, .libPaths()))
  }
}

bioc_installer <- function(remote_info){
  pkg_name <- remote_info$Package
  BiocInstaller::biocLite(pkg_name, suppressUpdates = TRUE,
                          lib = reup_options$new_library,
                          repos = c(get_bioc_mirror(), get_cran_mirror()))
}

cran_installer <- function(remote_info){
  pkg_name <- remote_info$Package
  install.packages(pkg_name, lib = reup_options$new_library,
                   repos = get_cran_mirror())
}

local_installer <- function(remote_info){
  pkg_name <- remote_info$remote
  devtools::install(pkg_name, reload = FALSE, local = TRUE, quiet = TRUE)
}

github_installer <- function(remote_info){
  pkg_name <- paste0(remote_info$remote, "@", remote_info$branch)
  devtools::install_github(pkg_name, reload = FALSE, local = TRUE, quiet = TRUE)
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
  for (ipkg in seq_len(nrow(pkg_frame))) {
    install_fun(pkg_frame[ipkg, ])
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
    split_type[["bioconductor"]] <- install_packages(split_type[["bioconductor"]], bioc_installer)
  }

  if ((nrow(split_type[["cran"]]) != 0) && !is.null(get_cran_mirror())) {
    split_type[["cran"]] <- install_packages(split_type[["cran"]], cran_installer)
  }

  if ((nrow(split_type[["bioconductor"]])) && !is.null(get_bioc_mirror())) {
    split_type[["bioconductor"]] <- install_packages(split_type[["bioconductor"]], bioc_installer)
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
  out_pkgs
}
