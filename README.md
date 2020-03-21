# ML-Click-through-rate-prediction
Classification Project on a dataset of 32M rows using models such as Decision Trees, Logisitic Regression, Random Forests, Neural Nets and XGBoost

## Introduction:
Online advertising is a form of marketing which delivers promotional messages to consumers via the Internet. Due to the volume of advertisements being published & huge cost associated with marketing campaigns, serving the right advertisement to the right consumer is extremely important. Hence, the ability to predict whether a consumer will click an advertisement on a search engine such as Google will help the firm determine the right advertisement to serve the right consumer. Our project intends to unravel this prediction by creating a classification model, utilizing data of 9 days (Oct 21st - 29th 2014) during which more than 30 million instances of advertisements were served to various consumers.

### Models implemented:
We built and implemented models using the following algorithms:

##### Logistic regression (With Lasso & Ridge Regularization)
##### Decision Trees
##### Random Forest
##### XGBoost


### The Final Model, with a logloss of 0.39 on the test data, was submitted and won 3rd place in a class competition of 11 teams.


### More on the dataset

This project involves predicting clicks for on-line advertisements. The training data consists of data for 9 days from October 21, 2014 to October 29, 2014. The variables in this file are as follows:

-id = the identifier of the ad (this may, or may not be unique to each row).
-click = 1 means the ad was clicked on. click = 0 means the ad was not clicked on.
-hour = the date and hour when the ad was displayed. Format is YYMMDDHH.
-C1 = an anonymized categorical variable.
-banner_pos = the position in the banner.
-site_id = an identifier for the web site.
-site_domain = an identifier for the site domain
-site_category = a code for the site’s category.
-app_id = an identifier for the application showing the ad.
-app_domain = an identifier for the app’s domain.
-app_category = a code for the category of the app.
-device_id = an identifier for the device used.
-device_ip = a code for the ip of the device.
-device_model = the model of the device.
-device_type = the type of the device.
-device_conn_type = the type of the device’s connection
-C14 – C21 = anonymized categorical variables

Thus, there are 24 columns in the dataset. The variable “click” is the Y-variable in the dataset.
