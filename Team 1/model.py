#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd

from sklearn.neighbors import NearestNeighbors
from sklearn import linear_model

import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties

#read variable data
data = pd.read_excel('Non Domestic Abuse VWI Offs.xlsx', header = 1)

##################################
parameters = ['employment_percentage', 'gender_percentage','house_price','Non Domestic Abuse VWI Offs']

data_pri = data[data['Priority'] == 1]
data_nor = data[data['Priority'] == 0]

#Train nearest neighbour data
X = data_nor[parameters]
X = X.reset_index(drop = True)
nbrs = NearestNeighbors(n_neighbors=1, algorithm='kd_tree').fit(X)

#get Y
decrease_rates = []

for index, row in data_pri.iterrows():
    
    record = row
    
    borough = record['Borough']
    year = record['Year']
    
    amount_pri = record['Non Domestic Abuse VWI Offs']
    
    #find nearest neighbour in data_nor
    paras = np.array(record[parameters].values).reshape(1, -1)
    index = nbrs.kneighbors(paras, 1, return_distance = False)
    amount_nor = X.loc[19]['Non Domestic Abuse VWI Offs']
    
    y = (amount_nor - amount_pri) / amount_nor
    decrease_rates.append(y)

#integrate data for regression
regr_data = data_pri[['employment_percentage', 'gender_percentage','house_price']]
regr_data['decrease_rate'] = decrease_rates
regr_data = regr_data.reset_index(drop = True)

#Split train/test -> 0.7/0.3
number  = len(regr_data.index)
tr_data = regr_data.loc[0:number*0.7]
te_data = regr_data.loc[number*0.7: ]
    
#multivariable relationships
sns.pairplot(tr_data)

#univariable regression
sns.regplot(x="employment_percentage",y="decrease_rate",data=tr_data)
sns.regplot(x="gender_percentage",y="decrease_rate",data=tr_data)
sns.regplot(x="house_price",y="decrease_rate",data=tr_data)

#train regression model
###################################
parameters = ['employment_percentage', 'gender_percentage','house_price']

lr = linear_model.LinearRegression()
lr.fit(tr_data[parameters], tr_data['decrease_rate']) #fit
print ('k, parameter(' + str(parameters)+'):' + str(lr.intercept_) +', ' + str(lr.coef_))

pre_rates = lr.predict(tr_data[parameters])  #prediction
print('train r2：' + str(lr.score(tr_data[parameters], tr_data['decrease_rate'])))

#predict test data
pre_te_rates = lr.predict(te_data[parameters])
print('test r2：' + str(lr.score(te_data[parameters], te_data['decrease_rate'])))


plt.scatter(range(len(pre_rates)),tr_data['decrease_rate'])
plt.plot(range(len(pre_rates)),pre_rates)
plt.title('training')
plt.show()


plt.scatter(range(len(pre_te_rates)),te_data['decrease_rate'])
plt.plot(range(len(pre_te_rates)),pre_te_rates)
plt.title('testing')
plt.show()








    
    


