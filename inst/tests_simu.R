rm(list=ls())

library(ScoreSBM)
library(tensor)
# source('D:/WORK_ALL/RECHERCHE/TRAVAUX_RECHERCHE/Stephane_Robin/NOISY_Papier_Package/Package/ScoreSBM/R/funcVEM.R', encoding = 'UTF-8')
# source('D:/WORK_ALL/RECHERCHE/TRAVAUX_RECHERCHE/Stephane_Robin/NOISY_Papier_Package/Package/ScoreSBM/R/tools.R', encoding = 'UTF-8')
# source('D:/WORK_ALL/RECHERCHE/TRAVAUX_RECHERCHE/Stephane_Robin/NOISY_Papier_Package/Package/ScoreSBM/R/tools.R', encoding = 'UTF-8')
source('./R/funcVEM.R', encoding = 'UTF-8')
source('./R/tools.R', encoding = 'UTF-8')
source('./inst/veStepScoreSBMbis.R', encoding = 'UTF-8')
library(mclust)

# Parms
nNodes  <- 60
blockProp <- c(1/3,1/2,1/6)
d <- 4
nBlocks   <- length(blockProp) # SR: 'mixtureParam' -> 'blockProp'
connectParam <- matrix(rbeta(nBlocks^2,1.5,1.5 ), nBlocks, nBlocks)
emissionParam <- list()
emissionParam$noEdgeParam <- list(mean = rep(0,d),var = diag(0.1,nrow = d,ncol = d))
emissionParam$edgeParam <- list( mean = 1:d,var =  diag(0.1,nrow = d,ncol = d))

# Data
directed <- TRUE
if(!directed){connectParam <- 0.5*(connectParam + t(connectParam))}
dataSim <- rScoreSBM(nNodes, directed = TRUE, blockProp, connectParam, emissionParam, seed = NULL)

# Init
K <- 3
scoreList <- dataSim$scoreNetworks
initDist <- initInferenceScoreSBM(scoreList, directed)
scoreMat <- scoreList2scoreMat(scoreList, symmetric=!directed)
thetaInit <- mStepScoreSBM(scoreMat=scoreMat,
                          qDist=list(psi=initDist$psi, tau=initDist$tau[[K]], eta=initDist$eta[[K]]),
                          directed=directed)

# VEM
thetaHat <- thetaInit;
qDist <- veStepScoreSBM(scoreMat=scoreMat, theta=thetaHat, tauOld=initDist$tau[[K]], directed=directed)
# qDistBis <- veStepScoreSBMbis(scoreMat=scoreMat, theta=thetaHat, tauOld=initDist$tau[[K]], directed=directed)
# par(mfrow=c(3, 2), mex=.6, pch=20)
# plot(qDist$logPhi, qDistBis$logPhi); abline(0, 1)
# plot(qDist$logA, qDistBis$logA); abline(0, 1)
# plot(qDist$eta, qDistBis$eta, log='xy'); abline(0, 1)
# plot(qDist$tau, qDistBis$tau, log='xy'); abline(0, 1)
# plot(qDist$psi, qDistBis$psi, log='xy'); abline(0, 1)

# maxIterVE <- NULL; epsilon_tau <- 1e-4; epsilon_eta <- 2 * .Machine$double.eps
maxIterVEM <- 10; iter <- 1; J <- rep(0, 2*maxIterVEM);
for(iter in 1:maxIterVEM){
  qDist <- veStepScoreSBM(scoreMat=scoreMat, theta=thetaHat, tauOld=initDist$tau[[K]], directed=directed)
  if(iter>1){
    critMat <- c()
    critMat <- rbind(critMat, unlist(lowerBoundScoreSBM(scoreMat=scoreMat,theta=thetaHat,qDist=qDistOld,directed)))
    qDistOld$LogPhi <- qDist$logPhi
    critMat <- rbind(critMat, unlist(lowerBoundScoreSBM(scoreMat=scoreMat,theta=thetaHat,qDist=qDistOld,directed)))
    qDistOld$eta <- qDist$eta
    critMat <- rbind(critMat, unlist(lowerBoundScoreSBM(scoreMat=scoreMat,theta=thetaHat,qDist=qDistOld,directed)))
    qDistOld$tau <- qDist$tau
    critMat <- rbind(critMat, unlist(lowerBoundScoreSBM(scoreMat=scoreMat,theta=thetaHat,qDist=qDistOld,directed)))
    qDistOld$psi <- qDist$psi
    critMat <- rbind(critMat, unlist(lowerBoundScoreSBM(scoreMat=scoreMat,theta=thetaHat,qDist=qDistOld,directed)))
    rownames(critMat) <- c('init', 'logPhi', 'eta', 'tau', 'psi')
    print(critMat)
  }
  J[2*iter-1] <- lowerBoundScoreSBM(scoreMat=scoreMat,theta=thetaHat,qDist=qDist,directed)$lowerBound
  thetaHat <- mStepScoreSBM(scoreMat=scoreMat, qDist=qDist, directed=directed)
  J[2*iter] <- lowerBoundScoreSBM(scoreMat=scoreMat,theta=thetaHat,qDist=qDist,directed)$lowerBound
  qDistOld <- qDist; #iter <- iter+1
}
plot(J[1:(2*iter)], col=rep(1:2, iter), type='b')
