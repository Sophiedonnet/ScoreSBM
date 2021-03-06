% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tools.R
\name{scoreList2scoreMat}
\alias{scoreList2scoreMat}
\title{scoreList2scoreMat : transform a list of Score matrices (matrices of size nxn) into a matrix}
\usage{
scoreList2scoreMat(listScores, symmetric)
}
\arguments{
\item{listScores}{: list of scores vector}

\item{symmetric}{: TRUE is the network is not  directed. FALSE otherwise}
}
\value{
one matrix with 'nbDyads' rows and d columns
}
\description{
scoreList2scoreMat : transform a list of Score matrices (matrices of size nxn) into a matrix
}
\examples{
nbNodes  <- 100
directed <- TRUE
blockProp <- c(1/3,1/2,1/6)
nbBlocks   <- length(blockProp)
connectParam <- matrix(rbeta(nbBlocks^2,1.5,1.5 ),nbBlocks,nbBlocks)
connectParam <- 0.5*(connectParam + t(connectParam))
emissionParam <- list()
nbScores <- 4
emissionParam$noEdgeParam <- list(mean=rep(0,nbScores));
emissionParam$noEdgeParam$var <- diag(0.1,nrow = nbScores,ncol = nbScores)
emissionParam$edgeParam <- list( mean= 1:nbScores)
emissionParam$edgeParam$var <-  diag(0.1,nrow = nbScores,ncol = nbScores)
dataSim <- rScoreSBM(nbNodes,directed = TRUE, blockProp,connectParam,emissionParam,seed = NULL)
S <- scoreList2scoreMat(dataSim$scoreNetworks , symmetric = FALSE)
}
