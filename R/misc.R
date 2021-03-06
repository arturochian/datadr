#' Apply Function to Key-Value Pair
#'
#' Apply a function to a single key-value pair - not a traditional R "apply" function.
#'
#' @param fn a function
#' @param kvPair a key-value pair (a list with 2 elements)
#' @param returnKV should the key and value be returned?
#'
#' @details Determines how a function should be applied to a key-value pair and then applies it: if the function has two formals, it applies the function giving it the key and the value as the arguments, and then expects the function to return a key and a value; if the function has one formal, it applies the function giving it just the value, and expects the function to return a value.
#'
#' This provides flexibility and simplicity for when a function is only meant to be applied to the value, but still allows keys to be used if desired.
#'
#' @export
kvApply <- function(fn, kvPair, returnKV = FALSE) {
  # TODO?: also do other stuff like add splitVars back on to df, etc. prior to applying
  if(length(formals(fn)) == 2) {
    res <- fn(kvPair[[1]], kvPair[[2]])
    if(!(is.list(res) && length(res) == 2))
      stop("A transformation function that takes a key and a value should return a key/value pair - see ?kvApply for more details.", call. = FALSE)
    if(!returnKV) {
      res <- res[[2]]
    }
  } else {
    res <- fn(kvPair[[2]])
    if(returnKV)
      res <- list(kvPair[[1]], res)
  }
  return(res)
}

### internal

# maybe hash functions should be exposed?
keyHash <- function(key, nBins) {
  sum(strtoi(charToRaw(digest(key)), 16L)) %% nBins
}

digestKeyHash <- function(digestKey, nBins) {
  sum(strtoi(charToRaw(digestKey), 16L)) %% nBins
}

validateListKV <- function(data) {
  # make sure it is a valid k/v list
  allLengthTwo <- !any(sapply(data, length) != 2)
  allLists <- !any(!sapply(data, is.list))
  if(!allLengthTwo || !allLists)
    stop("List must be a list of lists, each sublist being of length two (k/v pairs)")

  # # add "keyValue" class to each element
  # for(i in seq_along(data)) {
  #   class(data[[i]]) <- c("keyValue", "list")
  # }
}

nullAttributes <- function (e) {
  environment(e) <- NULL

  for (i in seq_along(e)) attributes(e[[i]]) <- NULL
  eval(parse(text = deparse(e)))
}

appendExpression <- function(expr1, expr2) {
  getLines <- function(expr) {
    if(inherits(expr, "expression")) {
      expr <- deparse(expr)
      n <- length(expr)
      if(n == 1) {
        warning("expression must be wrapped in {}: ", expr)
        return(expr)
      } else {
        return(expr[-c(1, n)])
      }
    } else {
      return("")
    }
  }

  eval(parse(text=paste("expression({", paste(c(getLines(expr1), getLines(expr2)), collapse="\n"), "})", sep="")))
}

isAbsolutePath <- function(path) {
  splitPath <- strsplit(path, split = "[/\\]")[[1]]

  any(
    grepl("^~", path),
    grepl("^.:(/|\\\\)", path),
    splitPath[1] == ""
  )
}

