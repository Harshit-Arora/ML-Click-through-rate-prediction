#Logistic Regression - LASSO & RIDGE- Team 7


setwd("C:/Users/harsh/Desktop/MSBA/Fall/Machine Learning/Final project/Data/Project Data")

library(data.table)
library(dplyr)
library(tidyr)
library(R.utils)
library(lubridate)
library(gdata)

#A 10M rows long cleaned dataset. loads with the name train_sample - already sampled randomly out of the 32M full,cleaned dataset

load("Train2_10M_24_dynamic.RData")

complete <- train_sample

#Since this file is loaded AFTER ALREADY BEING RANDOMLY SAMPLED , now just split sequentially so we can use consistent
#data across different models

train <- complete[1:5000000]
validation <- complete[5000001:7500000]
test <- complete[7500001:10000000]

#Extract the features and Y variables for all 3 datasets 

Xtrain <- train[,-1]
Ytrain <- as.numeric(levels(train$click))[train$click]
Xval <- validation[,-1]
Yval <- as.numeric(levels(validation$click))[validation$click]
Xtest <- test[,-1]
Ytest <- as.numeric(levels(test$click))[test$click]

library(glmnet)
library(ModelMetrics)
library(MLmetrics)

#Build a model matrix which essentially makes a column for each dummy variable based on the levels in a factor

XTrain <- model.matrix(~ .,Xtrain)
XVal <- model.matrix(~ .,Xval)
XTest <- model.matrix(~ .,Xtest)

#Define a grid of values for the Lambda parameter that the model will be trained on

grid <- 10^(seq(-6,1,length=200)) #ran multiple times by adjusting this grid for different values

#Train the model
outll <- glmnet(XTrain,Ytrain, family = "binomial", lambda = grid, alpha=1) #alpha 1 for lasso, 0 for ridge

#Make predictions on the validation data for all values of lambda. This will have 200 columns, each for one value of lambda
p <- predict(outll, newx = as(XVal, "dgCMatrix"), type = "response" )

#Store logloss based on the validation data for each model from the grid here

temp1 <- NULL
temp2 <- NULL

for(i in 1:200)
{
  prob = p[,i]
  prob = as.data.frame(prob)
  temp1$loss = LogLoss(prob$prob,Yval)
  temp1$lambda = i
  temp2 = rbind(temp2,temp1)
}

#View(temp2)  #See all logloss at a glance - lowest 0.41

#Test it on the test data using the optimal value of lambda (lowest logless on Validation data)

p2 <- predict(outll, newx = as(XTest, "dgCMatrix"), type = "response" )

LogLoss(p2[,46],Ytest) #0.41




