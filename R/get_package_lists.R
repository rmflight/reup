#' old packages
#'
#' get the list of packages installed in the old library
#'
#' @param old_library where to look
#'
#' @export
#' @return matrix
get_old_packages <- function(old_library = get_old_library()) {
  old_pkgs <- installed.packages(lib.loc = old_library)
  old_pkgs
}

#' new packages
#'
#' get the list of packages installed in the new library
#'
#' @param new_library where to look
#'
#' @export
#' @return matrix
get_new_packages <- function(new_library = get_new_library()){
  new_pkgs <- installed.packages(lib.loc = new_library)
  new_pkgs
}

#' compare lists
#'
#' Compares the old and new package lists, and then returns the list of things
#' that have yet to be installed in the new library location.
#'
#' @export
#' @return matrix
compare_old_new_library <- function(){
  old_pkgs <- get_old_packages()
  new_pkgs <- get_new_packages()

  old_pkgs <- old_pkgs[setdiff(rownames(old_pkgs), rownames(new_pkgs)), ]
  old_pkgs
}
