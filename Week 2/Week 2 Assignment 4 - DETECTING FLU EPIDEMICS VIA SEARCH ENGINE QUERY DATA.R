#Week 2 Assignment 4 - DETECTING FLU EPIDEMICS VIA SEARCH ENGINE QUERY DATA

setwd("C:/Users/fch80_000/Dropbox/-- edX Courses--/MITx 15.071x The Analytics Edge/Week 2")

#Flu epidemics constitute a major public health concern causing respiratory illnesses, hospitalizations, and deaths. According to the National Vital Statistics Reports published in October 2012, influenza ranked as the eighth leading cause of death in 2011 in the United States. Each year, 250,000 to 500,000 deaths are attributed to influenza related diseases throughout the world.

#The U.S. Centers for Disease Control and Prevention (CDC) and the European Influenza Surveillance Scheme (EISS) detect influenza activity through virologic and clinical data, including Influenza-like Illness (ILI) physician visits. Reporting national and regional data, however, are published with a 1-2 week lag.

#The Google Flu Trends project was initiated to see if faster reporting can be made possible by considering flu-related online search queries -- data that is available almost immediately.

#We would like to estimate influenza-like illness (ILI) activity using Google web search logs. Fortunately, one can easily access this data online:

#ILI Data - The CDC publishes on its website the official regional and state-level percentage of patient visits to healthcare providers for ILI purposes on a weekly basis.

#Google Search Queries - Google Trends allows public retrieval of weekly counts for every query searched by users around the world. For each location, the counts are normalized by dividing the count for each query in a particular week by the total number of online search queries submitted in that location during the week. Then, the values are adjusted to be between 0 and 1.

#The csv file FluTrain.csv aggregates this data from January 1, 2004 until December 31, 2011 as follows:
  
#  "Week" - The range of dates represented by this observation, in year/month/day format.

#"ILI" - This column lists the percentage of ILI-related physician visits for the corresponding week.

#"Queries" - This column lists the fraction of queries that are ILI-related for the corresponding week, adjusted to be between 0 and 1 (higher values correspond to more ILI-related search queries).

#Before applying analytics tools on the training set, we first need to understand the data at hand. Load "FluTrain.csv" into a data frame called FluTrain. Looking at the time period 2004-2011, which week corresponds to the highest percentage of ILI-related physician visits? Select the day of the month corresponding to the start of this week.

flu.train<- read.csv("FluTrain.csv")
str(flu.train)
summary(flu.train)

flu.train$Week[which.max(flu.train$ILI)]

2009-10-18

#Which week corresponds to the highest percentage of ILI-related query fraction?

flu.train$Week[which.max(flu.train$Queries)]
2009-10-18
#cor(flu.train$ILI, flu.train$Queries)

#Let us now understand the data at an aggregate level. Plot the histogram of the dependent variable, ILI. What best describes the distribution of values of ILI?

hist(flu.train$ILI)

#Most of the ILI values are small, with a relatively small number of much larger values (in statistics, this sort of data is called "skew right").


#When handling a skewed dependent variable, it is often useful to predict the logarithm of dependent variable instead of the dependent variable itself -- this prevents the small number of unusually large or small observations from having an undue influence on the sum of squared errors of predictive models. In this problem, we will predict the natural log of the ILI variable, which can be computed in R using the log() function.

#Plot the natural logarithm of ILI versus Queries. What does the plot suggest?.

plot( flu.train$Queries, log(flu.train$ILI) )

#There is a positive, linear relationship between log(ILI) and Queries.

#Based on the plot we made earlier, it seems that a linear regression model could be a good modeling choice. Based on our understanding of the data from the previous subproblem, which model best describes our estimation problem?

#log(ILI) = intercept + coefficient x Queries, where the coefficient is positive

#Let's call the regression model from the previous problem (Problem 2.1) FluTrend1 and run it in R. Hint: to take the logarithm of a variable Var in a regression equation, you simply use log(Var) when specifying the formula to the lm() function.

#What is the training set R-squared value for FluTrend1 model?

flu.trend1<- lm(log(ILI) ~ Queries, data = flu.train)
summary(flu.trend1)
0.709

#For a single variable linear regression model, there is a direct relationship between the R-squared and the correlation between the independent and the dependent variables. What is the relationship we infer from our problem? (Don't forget that you can use the cor function to compute the correlation between two variables.)

cor(log(flu.train$ILI),flu.train$Queries)^2
#R-squared = Correlation^2 

#Note that the "exp" function stands for the exponential function. The exponential can be computed in R using the function exp().

#The csv file FluTest.csv provides the 2012 weekly data of the ILI-related search queries and the observed weekly percentage of ILI-related physician visits. Load this data into a data frame called FluTest.

flu.test<- read.csv("FluTest.csv")

#Normally, we would obtain test-set predictions from the model FluTrend1 using the code

#pred.test1 = predict(flu.trend1, newdata=flu.test)

#However, the dependent variable in our model is log(ILI), so PredTest1 would contain predictions of the log(ILI) value. We are instead interested in obtaining predictions of the ILI value. We can convert from predictions of log(ILI) to predictions of ILI via exponentiation, or the exp() function. The new code, which predicts the ILI value, is

pred.test1 = exp(predict(flu.trend1, newdata=flu.test))

#What is our estimate for the percentage of ILI-related physician visits for the week of March 11, 2012?
which(flu.test$Week %in% "2012-03-11 - 2012-03-17")
flu.test$Week
flu.test$Week[11]
pred.test1[11]
2.187378

#What is the relative error betweeen the estimate and the observed for that week? Note that the relative error is calculated as

#(Observed ILI - Estimated ILI)/Observed ILI
(flu.test$ILI[11] - pred.test1[11])/flu.test$ILI[11]
0.04623827 

#What is the Root Mean Square Error (RMSE) between our estimates and the actual observations for the percentage of ILI-related physician visits?

SSE<- sum((pred.test1 - flu.test$ILI)^2)
SSE
RMSE<- sqrt(SSE/nrow(flu.test))
RMSE
0.7490645

#SST<- sum((mean(flu.train$ILI) - flu.test$ILI)^2)
#SST
#R2<- 1-(SSE/SST)
#R2

#The observations in this dataset are consecutive weekly measurements of the dependent and independent variables. This sort of dataset is called a "time series." Often, statistical models can be improved by predicting the current value of the dependent variable using the value of the dependent variable from earlier weeks. In our models, this means we will predict the ILI variable in the current week using values of the ILI variable from previous weeks.

#First, we need to decide the amount of time to lag the observations. Because the ILI variable is reported with a 1- or 2-week lag, a decision maker cannot rely on the previous week's ILI value to predict the current week's value. Instead, the decision maker will only have data available from 2 or more weeks ago. We will build a variable called ILILag2 that contains the ILI value from 2 weeks before the current observation.

#To do so, we will use the "zoo" package, which provides a number of helpful methods for time series models. While many functions are built into R, you need to add new packages to use some functions. New packages can be installed and loaded easily in R, and we will do this many times in this class. Run the following two commands to install and load the zoo package. In the first command, you will be prompted to select a CRAN mirror to use for your download. Select a mirror near you geographically.

#install.packages("zoo")

library(zoo)

#After installing and loading the zoo package, run the following commands to create the ILILag2 variable in the training set:
  
ILI.lag2 = lag(zoo(flu.train$ILI), -2, na.pad=TRUE)

flu.train$ILI.lag2 = coredata(ILI.lag2)

#In these commands, the value of -2 passed to lag means to return 2 observations before the current one; a positive value would have returned future observations. The parameter na.pad=TRUE means to add missing values for the first two weeks of our dataset, where we can't compute the data from 2 weeks earlier.

#How many values are missing in the new ILILag2 variable?

summary(flu.train)
2

#Use the plot() function to plot the log of ILILag2 against the log of ILI. Which best describes the relationship between these two variables?

plot(log(flu.train$ILI.lag2), log(flu.train$ILI))

#There is a strong positive relationship between log(ILILag2) and log(ILI).

#Train a linear regression model on the FluTrain dataset to predict the log of the ILI variable using the Queries variable as well as the log of the ILILag2 variable. Call this model FluTrend2.

#Which coefficients are significant at the p=0.05 level in this regression model?

flu.trend2<- lm(log(ILI) ~ Queries + log(ILI.lag2), data = flu.train)
summary(flu.trend2)

#All variables are significant

#What is the R^2 value of the FluTrend2 model?
0.9063

#On the basis of R-squared value and significance of coefficients, which statement is the most accurate?

summary(flu.trend1)
summary(flu.trend2)

#FluTrend2 is a stronger model than FluTrend1 on the training set.

#So far, we have only added the ILILag2 variable to the FluTrain data frame. To make predictions with our FluTrend2 model, we will also need to add ILILag2 to the FluTest data frame (note that adding variables before splitting into a training and testing set can prevent this duplication of effort).

#Modify the code from the previous subproblem to add an ILILag2 variable to the FluTest data frame. How many missing values are there in this new variable?

ILI.lag2 = lag(zoo(flu.test$ILI), -2, na.pad=TRUE)

flu.test$ILI.lag2 = coredata(ILI.lag2)

summary(flu.test)
2

#In this problem, the training and testing sets are split sequentially -- the training set contains all observations from 2004-2011 and the testing set contains all observations from 2012. There is no time gap between the two datasets, meaning the first observation in FluTest was recorded one week after the last observation in FluTrain. From this, we can identify how to fill in the missing values for the ILILag2 variable in FluTest.

#Which value should be used to fill in the ILILag2 variable for the first observation in FluTest?

#The ILI value of the second-to-last observation in the FluTrain data frame

#Which value should be used to fill in the ILILag2 variable for the second observation in FluTest?

#The ILI value of the last observation in the FluTrain data frame. 

#Fill in the missing values for ILILag2 in FluTest. In terms of syntax, you could set the value of ILILag2 in row "x" of the FluTest data frame to the value of ILI in row "y" of the FluTrain data frame with "FluTest$ILILag2[x] = FluTrain$ILI[y]". Use the answer to the previous questions to determine the appropriate values of "x" and "y". It may be helpful to check the total number of rows in FluTrain using str(FluTrain) or nrow(FluTrain).

#What is the new value of the ILILag2 variable in the first row of FluTest?

nrow(flu.train)
flu.test$ILI.lag2[1:2]<- flu.train$ILI[416:417]

flu.test$ILI.lag2[1]
1.852736

#What is the new value of the ILILag2 variable in the second row of FluTest?
flu.test$ILI.lag2[2]
2.124130

#Obtain test set predictions of the ILI variable from the FluTrend2 model, again remembering to call the exp() function on the result of the predict() function to obtain predictions for ILI instead of log(ILI).

#What is the test-set RMSE of the FluTrend2 model?

pred.test2 = exp(predict(flu.trend2, newdata=flu.test))

SSE<- sum((pred.test2 - flu.test$ILI)^2)
SSE
RMSE<- sqrt(SSE/nrow(flu.test))
RMSE
0.2942029

#Which model obtained the best test-set RMSE?

flu.trend2

#In this problem, we used a simple time series model with a single lag term. ARIMA models are a more general form of the model we built, which can include multiple lag terms as well as more complicated combinations of previous values of the dependent variable. If you're interested in learning more, check out ?arima or the available online tutorials for these sorts of models.

