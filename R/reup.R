#' setup devtools
#'
#' Makes modifications suitable for doing installations using \code{devtools} for
#' local and / or github based packages.
#'
#' @return NULL
#' @export
setup_devtools <- function(){
  if (.libPaths()[1] != reup_options$new_library){
    .libPaths(c(reup_options$new_library, .libPaths()))
  }
}

bioc_installer <- function(remote_info){
  pkg_name <- remote_info$Package
  BiocInstaller::biocLite(pkg_name, suppressUpdates = TRUE,
                          lib = reup:::reup_options$new_library)
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
#' Try to install the list of packages that are not yet installed.
#'
#' @param pkg_frame data.frame of packages to be installed
#'
#' @export
#' @return NULL
install_packages <- function(pkg_frame){
  split_type <- split(pkg_frame, pkg_frame$type)

  split_type <- lapply(split_type, function(x){
    x[order(x$n_deps, decreasing = FALSE), ]
  })

  if (!is.null(split_type$`NA`)) {
    split_type$`NA` <- NULL
  }



}

#' reup
#'
#' actually tries to do the upgrade of packages using `install.packages`.
#'
#' @param ... various options, normally set using the setter functions
#'
#' @export
reup <- function(...){

}
