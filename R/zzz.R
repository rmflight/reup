reup_options <- new.env(hash = TRUE)

reset_reup_options <- function(){
  curr_names <- names(reup_options)

  if (length(curr_names) > 0) {
    for (iname in curr_names) {
      assign(iname, NULL, envir = reup_options)
    }
  }

}
