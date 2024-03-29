% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{hospital_infections}
\alias{hospital_infections}
\title{Hospital acquired infections}
\format{
A data frame with 432 rows and 5 variables: \itemize{ \item
  {hospital} Abbreviated hospital name. \item{infection} Type of infection.
  BAC: Bacteremia, CDI: Clostridium difficile infection. UTI: Urinary tract
  infection. \item{month} First day of month. \item {n} Number of cases.
  \item{days} Number of risk days. A risk day is a patient day without
  infection. }
}
\source{
www.esundhed.dk (Capital Region of Denmark).
}
\usage{
hospital_infections
}
\description{
A dataset containing the number of hospital acquired bacteremia, Clostridium
difficile infections, and urinary tract infections in six hospitals in the
Capital Region of Denmark 2015-2016.
}
\keyword{datasets}
