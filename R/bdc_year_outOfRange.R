#' Identify records with year out-of-range
#' 
#' This function identifies records out-of-range (e.g., in the future) or old records collected before a year informed in 'year_threshold'.
#' 
#' @param data A data frame containing column with event date information.
#' @param eventDate numeric or date. The column with event date information.
#' @param year_threshold numeric. A four-digit year threshold used to flag old
#' (potentially invalid) records. Default = NULL.
#' 
#' @details Following the "VALIDATION:YEAR_OUTOFRANGE"
#' \href{https://github.com/tdwg/bdq/projects/2}{Biodiversity data quality
#' group}, the results of this test are time-dependent. While the user may
#' provide a lower limit to the year, the upper limit is defined based on the
#' year when the test is run. Lower limits can be used to flag old, often
#' imprecise, records. For example, records collected before GPS advent
#' (1980). If 'year_threshold' is not provided, the lower limit to the year is
#' by default 1600, a lower limit for collecting dates of biological specimens.
#' Records with empty or NA 'eventDate' are not tested and returned as NA.
#' 
#' @return A data.frame contain the column ".year_outOfRange". Compliant
#' (TRUE) if 'eventDate' is not out-of-range; otherwise "FALSE".
#' 
#' @importFrom dplyr if_else
#' @importFrom lubridate year
#' @importFrom stringr str_extract
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' collection_date <- c(NA, "31/12/2015", "2013-06-13T00:00:00Z", "2013-06-20",
#' "", "2013", "0001-01-00")
#' x <- data.frame(collection_date)
#' 
#' bdc_coordinates_empty(data = x, eventDate = "collection_date")
#' }
bdc_year_outOfRange <-
  function(data,
           eventDate,
           year_threshold = NULL) {
    col <- data[[eventDate]]
    nDigits <- function(x) nchar(trunc(abs(x)))

    col <-
      stringr::str_extract(col, "[[:digit:]]{4}") %>%
      as.numeric()

    if (is.null(year_threshold)) {
      .year <-
        dplyr::if_else(
          col %in% 1600:lubridate::year(Sys.Date()),
          TRUE,
          FALSE
        )
    } else {
      if (!is.numeric(year_threshold)) {
        stop("'year_threshold' is not numeric")
      }
      if (nDigits(year_threshold) != 4) {
        stop("'year_threshold' does not have four digits")
      }

      .year <-
        dplyr::if_else(
          col %in% 1600:lubridate::year(Sys.Date()),
          TRUE,
          FALSE
        )

      .year <- .year & col > year_threshold
    }

    res <- cbind(data, .year)

    message(
      paste(
        "\nbdc_year_outOfRange:\nFlagged",
        sum(.year == FALSE),
        "records.\nOne column was added to the database.\n"
      )
    )

    return(res)
  }