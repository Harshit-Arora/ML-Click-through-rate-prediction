#XGBOOST

#Team 7

setwd("C:/Users/harsh/Desktop/MSBA/Fall/Machine Learning/Final project/Data/Project Data")

library(data.table)
library(dplyr)
library(tidyr)
library(R.utils)
library(lubridate)
library(gdata)


#loads with the name train_sample - already sampled (in the Data Cleaning File) randomly out of the 32M full,cleaned dataset
#10M Size, further split into Train- Val - Test 50%-25%-25%

load("Train2_10M_24_dynamic.RData")

complete <- train_sample

#Since this file is loaded AFTER ALREADY BEING RANDOMLY SAMPLED , now just split sequentially so we can use consistent
#data across different models for comparison

train <- complete[1:5000000]
validation <- complete[5000001:7500000]
test <- complete[7500001:10000000]


#Extract features and target variable in seperate objects for all 3 datasets

Xtrain <- train[,-1] 
Ytrain <- as.numeric(levels(train$click))[train$click]
Xval <- validation[,-1]
Yval <- as.numeric(levels(validation$click))[validation$click]
Xtest <- test[,-1]
Ytest <- as.numeric(levels(test$click))[test$click]

rm(complete)

library(Matrix)
library(xgboost)

#Make sparse matrices as they are computationally cheaper and because xgboost does not accept a dataframe input

xgbtrain <- sparse.model.matrix(data=train,click~.-1) #click~. ignores click as a feature
xgbval <- sparse.model.matrix(data=validation,click~.-1)
xgbtest <- sparse.model.matrix(data=test,click~.-1)

xgb_train <- xgb.DMatrix(data=xgbtrain,label=Ytrain) #Change to DMatrix which is a required input for XGboost
xgb_val <- xgb.DMatrix(data=xgbval,label=Yval)
xgb_test <- xgb.DMatrix(data=xgbtest,label=Ytest)

#Parameters for tuning to reduce extent of overfitting and find the parameters with the lowest logloss on the validation data

params = list(
  booster="gbtree",
  eta=0.1,
  max_depth=17,
  min_child_weight=5,
  colsample_bytree=0.8,
  gamma=3,
  subsample=0.75,
  objective="binary:logistic",
  eval_metric="logloss"
)

#Will do 3000 rounds as a cap but will stop earlier if performance does not improve or gets worse for 10 continuous rounds

xgb <- xgb.train(
  params=params,
  data=xgb_train,
  nrounds=3000,
  nthreads=0,
  early_stopping_rounds=10,
  watchlist=list(val1=xgb_train,val2=xgb_val), #tunes using validation data and stops when performance does not improve for 10 rounds
  verbose=1
)


#LogLoss function
LL <- function(Pred,YVal){
  ll <- -mean(YVal*log(Pred)+(1-YVal)*log(1-Pred))
  return(ll)
} 

#Predict on our own test data
YHat <- predict(xgb,xgb_test)

LL(YHat,Ytest)

#--- Load the cleaned test data for submission (done the same way as we cleaned the train data)
#Replaces the file test - save a copy of the current test if needed

#test_copy_1 <- test

load(file = "test_clean_submission.RData")

submissions <- fread("ProjectSubmission-TeamX.csv")

# -- Prepare test data for predictions

library(tibble)

#Since we have a sparse matrix in use, we will make a dummy "Click" column and fill it with 0s and 1s 
#This does not have effect on model predictions as the matrix will ignore this column upon our specification

test_copy <- test
test_copy <- add_column(test_copy,.before = "C1") #Add this column to maintain the same order as training data
test_copy$click <- c(rep(seq(0,1,by=1),nrow(test_copy)/4),rep(seq(1,0,by=-1),nrow(test_copy)/4),0)
test_copy$click <- as.factor(test_copy$click)
test_copy <- test_copy[,names(train)]
test_copy <- as.data.table(test_copy)

names(test_copy) == names(train) #Verify orders are same

#---  Check the factors match that of the training data

train_levels <- as.data.table(train)
levels_per_column_y <- train_levels[, lapply(.SD, function(x) length(levels(x)))] 

test_levels <- as.data.table(test_copy)
levels_per_column_x <- test_levels[, lapply(.SD, function(x) length(levels(x)))] 

#Numbers match - but order of the levels should be same so that the matrix has all the features in the same order as well
#Verify if that is the case

levels(train$click) == levels(test_copy$click)

levels(train$C1) ==levels(test_copy$C1)

levels(train$banner_pos) == levels(test_copy$banner_pos)

levels(train$site_id) == levels(test_copy$site_id)

levels(train$site_domain) == levels(test_copy$site_domain)

levels(train$site_category) == levels(test_copy$site_category) ## THIS NEEDS REORDERING, others are ok

table(test_copy$site_category) #see the distribution before changing the level order

satecategory_train_levels <- as.vector(levels(train$site_category)) #reorder factors based on training data order
test_copy$site_category <-  factor(test_copy$site_category, levels = satecategory_train_levels)

table(test_copy$site_category) # verify only levels got changed and not the underlying data

levels(train$app_id) ==levels(test_copy$app_id)

levels(train$app_domain) == levels(test_copy$app_domain)

levels(train$app_category) == levels(test_copy$app_category)

levels(train$device_model) == levels(test_copy$device_model)

levels(train$device_type) == levels(test_copy$device_type)

levels(train$device_conn_type) == levels(test_copy$device_conn_type)

levels(train$C14) == levels(test_copy$C14)

levels(train$C15) == levels(test_copy$C15)

levels(train$C16) == levels(test_copy$C16)

levels(train$C17) == levels(test_copy$C17)

levels(train$C18) == levels(test_copy$C18)

levels(train$C19) == levels(test_copy$C19)

levels(train$C20) == levels(test_copy$C20)

levels(train$C21) == levels(test_copy$C21)

#-- Looks good - make predictions

Ytest <- as.numeric(levels(test_copy$click))[test_copy$click]
xgbtest <- sparse.model.matrix(data=test_copy,click~.-1)
xgb_test <- xgb.DMatrix(data=xgbtest,label=Ytest)
YHat <- predict(xgb,xgb_test)

head(YHat)

fwrite(as.data.table(YHat),"XGBoost_predictions.csv") #Will be loaded into the "SubmissionFileRoundTrip.r" file and prepared for submission
