# Random Forest - Team 7

#A 10M rows long cleaned dataset. loads with the name train_sample - already sampled randomly out of the 32M full,cleaned dataset

load("Train2_10M_24_dynamic.RData")

complete <- train_sample

#Since this file is loaded AFTER ALREADY BEING RANDOMLY SAMPLED , now just split sequentially so we can use consistent
#data across different models

train <- complete[1:5000000]
validation <- complete[5000001:7500000]

# Initialize the random forest with ntree=100 and keep other parameters as defaults
if(!require("randomForest")) { install.packages("randomForest"); require("randomForest") }
fm <- click ~ .

# Fit the random forest with training data
rf <- randomForest(fm, train, ntree = 100)

# Test the performance of random forest on validation data base on LogLoss
pHatrf <- predict(rf,validation, type = "prob")
pHatrf <- pHatrf[, 2]
LogLoss(pHatrf, Yval)

# Modify parameters settings to check whether performance can be improved
rf <- randomForest(fm, train, ntree = 250)
pHatrf <- predict(rf,validation, type = "prob")
pHatrf <- pHatrf[, 2]
LogLoss(pHatrf, Yval)

rf <- randomForest(fm, train, ntree = 500)
pHatrf <- predict(rf,validation, type = "prob")
pHatrf <- pHatrf[, 2]
LogLoss(pHatrf, Yval)

# Find the best mtry (number of parameters to choose from in each split) for randomForest
mtryrange <- 5:20
LL <- rep(NA,length(mtryrange))

for(i in 1:length(NodeNumberRange)) {
  out1 <- randomForest(fm,data=train, mtry=k, ntree=100)
  pHatrf <- predict(out1,validation, type = "prob")
  LL[i] <- LogLoss(pHatrf[,2], Yval)
}

# Plot the mtry against LogLoss Performance
plot(mtryrange,LL)
which.min(LL)
bestk <- which.min(LL) + 4
# Rebuild the model with the best "mtry"
bestrf <- randomForest(fm,data=train, mtry=bestk,ntree=100)

# Bagging
# Set the argument mtry to the number of variables (which is 21) to build the bagging model.
# Fit the bagging with training data
out2 <- randomForest(fm,train,mtry=21,ntree=500)

# Test the performance of bagging on validation data base on LogLoss
Hat <- predict(out2,validation,type="prob")
PHat <- PHat[,2]
LogLoss(PHat, Yval)
