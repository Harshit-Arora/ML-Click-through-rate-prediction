##DECISION TREE - TEAM 7

library(data.table)
library(dplyr)
library(tidyr)
library(R.utils)
library(lubridate)
library(tree)
library(glmnet)
library(MLmetrics)
library(ModelMetrics)

setwd("C:/Users/harsh/Desktop/MSBA/Fall/Machine Learning/Final project/Data/Project Data")

train <- fread("Train_Sample1_2M.csv")
validation <- fread("Validation_Sample2_1M.csv")

train[] <- lapply(train,as.factor)
validation[] <- lapply(validation,as.factor)

# store validation y-values for evaluation
Yval <- validation$click

# Getting formula for tree
fm <- click ~ .

# Initialize tree with different parameters

# Tested parameters: minsize: 5000 10000 15000 20000 25000
# Mincut chosen between 1/4 of minsize up-to 1/2 of minsize

tc <- tree.control(nrow(train),minsize=20000,mincut=5000) # Best parameters based on several permutations
tree_model <- tree(fm,data=train,control=tc,split="gini")
YHat <- predict(tree_model,validation)
YHat <- YHat[,2]
LogLoss(YHat,Yval)

summary(tree_model)$size

# function to get get best end node for the tree
NodeNumberRange <- 3:171
LL <- rep(NA,length(NodeNumberRange))

for(i in 1:length(NodeNumberRange)) {
  out1 <- prune.tree(tree_model,best=NodeNumberRange[i])
  ypred <- predict(out1,newdata=validation)
  LL[i] <- LogLoss(ypred[,2], Yval)
}

# Plot the end node against LogLoss Performance
plot(NodeNumberRange,LL)
