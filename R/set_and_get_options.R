#' set cran mirror
#'
#' Sets the CRAN mirror to use. Default is the RStudio one
#'
#' @param url the url of the CRAN mirror
#'
#' @export
#' @return NULL
set_cran_mirror <- function(url = "https://cloud.r-project.org/"){
  assign("cran_mirror", url, envir = reup_options)
}

get_cran_mirror <- function(){
  get("cran_mirror", envir = reup_options)
}

#' set bioconductor mirror
#'
#' Sets the Bioconductor mirror to use. Default is https://bioconductor.org
#'
#' @export
#' @return NULL
set_bioc_mirror <- function(url = "https://bioconductor.org"){
  assign("bioc_mirror", url, envir = reup_options)
}

get_bioc_mirror <- function(){
  reup:::reup_options$bioc_mirror
}

#' old library location
#'
#' Sets the old library. Default is to take it from R_LIBS
#'
#' @param lib_loc the library location
#'
#' @export
#' @return NULL
set_old_library <- function(lib_loc = NULL){
  if (is.null(lib_loc)) {
    dir_info <- get_lib_dir_info()
    # if latest dir creation time is less than 24 hours, assume that one is
    # actually the new library, and set the old one to the next oldest
    if (difftime(Sys.time(), dir_info[1, "ctime"], units = "hours") < 24) {
      lib_loc <- rownames(dir_info)[2]
    } else {
      lib_loc <- rownames(dir_info)[1]
    }
  }
  assign("old_library", lib_loc, envir = reup_options)
}

get_lib_dir_info <- function(){
  top_dir <- dirname(Sys.getenv("R_LIBS"))
  if (nchar(top_dir) == 0) {
    top_dir <- dirname(.libPaths[1])
  }

  all_dirs <- list.dirs(top_dir, recursive = FALSE)
  dir_info <- file.info(all_dirs)
  dir_info <- dir_info[order(dir_info$ctime, decreasing = TRUE), ]
  dir_info
}

get_old_library <- function(){
  reup:::reup_options$old_library
}

#' new library location
#'
#' Creates a new library location based on the version of R, and if the
#' Bioconductor mirror is set, then the Bioconductor version as well.
#'
#' @param lib_loc the full directory name
#'
#' @export
#' @return NULL
set_new_library <- function(lib_loc = NULL){
  r_version <- R.version
  #usr_home <- Sys.getenv("HOME")

  if (is.null(get_old_library())) {
    set_old_library()
    old_library <- get_old_library()
  } else {
    old_library <- get_old_library()
  }

  if (is.null(lib_loc)) {
    dir_info <- get_lib_dir_info()
    if (difftime(Sys.time(), dir_info[1, "ctime"], units = "hours") < 24) {
      lib_loc <- rownames(dir_info)[1]
    }
  }

  if (is.null(lib_loc)) {
    dir_name <- paste0("R", r_version$major, ".", r_version$minor)

    if (!is.null(get_bioc_mirror())) {
      dir_name <- paste0(dir_name, "_Bioc", tools:::.BioC_version_associated_with_R_version())
    }
  }
  lib_loc <- file.path(dirname(get_old_library()), dir_name)

  if (!dir.exists(lib_loc)) {
    dir.create(lib_loc)
    message(paste0("New Library Will Be Stored In: ", lib_loc))
    message(paste0("You should add this line to your .Renviron file: \n",
                   "  R_LIBS=", lib_loc))
  }

  assign("new_library", lib_loc, envir = reup_options)

}

get_new_library <- function(){
  reup:::reup_options$new_library
}

#' set local packages
#'
#' Set a directory to search recursively for the existence of local packages
#' that should be installed using \code{devtools}.
#'
#' @param local_pkg_dir the directory to search for local packages
#'
#' @export
#' @return NULL
set_local_packages <- function(local_pkg_dir = getwd()){
  if (!is.null(get_new_library())) {

    if (suppressWarnings(require("devtools", lib.loc = get_new_library(), quietly = TRUE))) {
      assign("local_packages", local_pkg_dir, envir = reup_options)
    } else {
      stop("devtools must be already installed to install local packages!")
    }

  } else {
    stop("A new library must already be set!")
  }
}
