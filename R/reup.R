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
  get("bioc_mirror", envir = reup_options)
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
    lib_loc <- Sys.getenv("R_LIBS")
  }
  assign("old_library", lib_loc, envir = reup_options)
}

get_old_library <- function(){
  get("old_library", envir = reup_options)
}

#' new library location
#'
#' Creates a new library location based on the version of R, and if the
#' Bioconductor mirror is set, then the Bioconductor version as well.
#'
#' @param parent_directory the parent directory
#' @param library_directory the actual library directory, default is NULL
#'
#' @export
#' @return NULL
set_new_library <- function(parent_directory = NULL, library_directory = NULL){
  r_version <- R.version
  #usr_home <- Sys.getenv("HOME")

  if (is.null(get_old_library())) {
    set_new_library()
    old_library <- get_old_library()
  }

  if (is.null(parent_directory)) {
    parent_directory <- basename(old_library)
  }

  if (is.null(library_directory)) {
    library_directory <- paste0("R_", r_version$major, ".", r_version$minor)

    if (!is.null(get_bioc_mirror())) {
      library_directory <- paste0(library_directory, "_bioc", tools:::.BioC_version_associated_with_R_version())
    }
  }
  full_library <- file.path(parent_directory, library_directory)

  if (!dir.exists(full_library)) {
    dir.create(full_library)
  }

  message(paste0("New Library Will Be Stored In: ", full_library))
  message(paste0("You should add this line to your .Renviron file: \n\n",
                 "R_LIBS=", full_library))

  assign("new_library", full_library, envir = reup_options)

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
