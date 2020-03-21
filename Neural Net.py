import pandas as pd
import numpy as np
import pandas as pd
import random as rn
import tensorflow as tf
from keras.models import Sequential
from keras.layers import Dense, Activation
from keras import backend as K

# read in training and validation data
train = pd.read_csv("/Users/patrickhe/Desktop/MSBA/Machine Learning/Machine Learning Final Project/Train_Sample3_0.1M.csv")
validation = pd.read_csv("/Users/patrickhe/Desktop/MSBA/Machine Learning/Machine Learning Final Project/Validation_Sample3_0.1M.csv")

Optimizer=optimizers.RMSprop(lr=0.01)

# Explore the data type of variables
train.head()
validation.head()
train = pd.DataFrame(train)
validation = pd.DataFrame(validation)
train.dtypes

# Encode categorical variables to dummy variables
pd.get_dummies(train).head()
train = pd.get_dummies(train)
validation = pd.get_dummies(validation)

#Dummy binary input variables so no need for variable scaling as already scaled to [0,1]

# Set ramdom seed
np.random.seed(1234)
rn.seed(1234)
session_conf = tf.ConfigProto(intra_op_parallelism_threads=1,inter_op_parallelism_threads=1)
tf.set_random_seed(1234)
sess = tf.Session(graph=tf.get_default_graph(), config=session_conf)
K.set_session(sess)


# store X variables for input and validation y-values for evaluation
Y = np.array(train['click'])
X = np.array(train.iloc[:,2:256])
Yval = np.array(val['click'])
Xval = np.array(val.iloc[:,2:256])

# Initialize the neural network
BCNN = Sequential()

BCNN.add(Dense(units=4,input_shape=(XTr.shape[1],),activation="relu",use_bias=True))
BCNN.add(Dense(units=4,activation="relu",use_bias=True))
BCNN.add(Dense(units=4,activation="relu",use_bias=True))
BCNN.add(Dense(units=1,activation="sigmoid",use_bias=True))

BCNN.compile(loss='binary_crossentropy', optimizer=Optimizer,metrics=['binary_crossentropy'])

# Fit the neural network with training data
FitHist = BCNN.fit(X,Y,epochs=10000,batch_size=len(Y),verbose=0)

# Predict the validation data with the fitted model
YHat = BCNN.predict(Xval,batch_size=Xval.shape[0])
YHat

# Store predicted values and actual values
pd.DataFrame(YHat).to_csv("YHat.csv")
pd.DataFrame(Yval).to_csv("Yval.csv")
