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

#' reup
#'
#' actually tries to do the upgrade of packages using `install.packages`.
#'
#' @param ... various options, normally set using the setter functions
#'
#' @export
reup <- function(...){

}
