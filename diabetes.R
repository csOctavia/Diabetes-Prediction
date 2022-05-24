#########################################
#Octavia Istocescu (Student ID: 4328030)#
#########################################


#####################################################################################################################
#Un-comment to install any packages you don't have
#####################################################################################################################
# install.packages("tidyverse")
# install.packages("naniar")
# install.packages("ggcorrplot")
# install.packages("caret")
# install.packages("skewness")
# install.packages("missForest")
# install.packages("randomForest")
# install.packages("nnet")
# install.packages("rcpp")
# install.packages("Amelia")

#####################################################################################################################
#Loading the packages
#####################################################################################################################
library(tidyverse)
library(naniar)
library(ggcorrplot)
library(caret)
library(skewness)
library(missForest)
library(randomForest)
library(nnet)
library(rcpp)
library(Amelia)

#####################################################################################################################
#Loading in the data
#####################################################################################################################
pima = read.csv(file="diabetes.csv",  header=TRUE,  sep=",")
as_tibble(pima)

#####################################################################################################################
#                                                 CLEANING THE DATA
#####################################################################################################################

#checking for missing/NA values
summary(pima)
sapply(pima, function(x) sum(is.na(x)))

#checking for duplicated entries
pima[duplicated(pima)]

#turning 0's into NA's
pima[,2:8][pima[, 2:8] == 0] <- NA

#Calculating the percentages of missing values 
pct_miss(pima$Pregnancies)
pct_miss(pima$Glucose)
pct_miss(pima$BloodPressure)
pct_miss(pima$SkinThickness)
pct_miss(pima$Insulin)
pct_miss(pima$BMI)
pct_miss(pima$DiabetesPedigreeFunction)
pct_miss(pima$Age)
pct_miss(pima$Outcome)

#splitting the ages into groups
p = pima %>% mutate(AgeGroup = case_when( Age >= 70  & Age <= 81 ~ '70-81',
                                          Age >= 60  & Age <= 69 ~ '60-69',
                                          Age >= 50  & Age <= 59 ~ '50-59',
                                          Age >= 40  & Age <= 49 ~ '40-49',
                                          Age >= 30  & Age <= 39 ~ '30-39',
                                          Age >= 21  & Age <= 29 ~ '21-29')) 

#####################################################################################################################
#                                                DATA EXPLORATION & ANALYSIS
#####################################################################################################################

#visualizing missing data, grouped by Outcome
pima %>% 
  gg_miss_var(show_pct = TRUE, facet = Outcome) +
  labs(title = "Missing data grouped by Outcome")

#visualizing missing data, grouped by age group
p %>% 
  gg_miss_var(show_pct = TRUE, facet = AgeGroup) +
  labs(title = "Missing data grouped by age")

#Visualizing the impact of age over the outcome
ggplot(pima, aes(x = Age, fill = factor(Outcome))) +
  geom_density(alpha = 0.4) +
  scale_fill_manual(values = c("red", "blue")) +
  labs(title = "Distribution of age by outcome", y = "Density", fill = "Diabetes Outcome")

#Removing all NA entries for visualization purposes
pima_NArm = pima %>%
  drop_na() 

#Creating a scatterplot matrix after removing NA's
my_cols <- c("#00AFBB", "#E7B800", "#FC4E07")  
pairs(pima_NArm, pch = 19,  cex = 0.5,
      col = my_cols[factor(pima$Outcome)],
      lower.panel=NULL)

#Visualizing correlation between all variables after removing NA's
ggcorrplot(cor(pima_NArm), 
           hc.order = TRUE, 
           type = "lower",
           lab = TRUE) +
  labs(title = "Correlation matrix after removing NA's")

#Checking and visualizing the normality of Glucose, BloodPressure, SkinThickness, Insulin, BMI, DiabetesPedigreeFunction
hist(pima$Glucose, col='steelblue')
hist(pima$BloodPressure, col='steelblue')
hist(pima$SkinThickness, col='steelblue')
hist(pima$Insulin, col='steelblue')
hist(pima$BMI, col='steelblue')
hist(pima$DiabetesPedigreeFunction, col='steelblue')

#Calculating skewness on the dataset where I removed all NA's
# 0.5158663: right-skewed
skewness(pima_NArm$Glucose)  
# -0.08718115: left-skewed
skewness(pima_NArm$BloodPressure)
# 0.208509: right-skewed
skewness(pima_NArm$SkinThickness)
# 2.156822: right-skewed
skewness(pima_NArm$Insulin)
# 0.6609435: right skewed
skewness(pima_NArm$BMI)
#1.951597: right-skewed
skewness(pima_NArm$DiabetesPedigreeFunction)

#Using Little's MCAR test on the non-partitioned dataset to see if missing data is MCAR 
mcar_test(pima)

#####################################################################################################################
#                                                 PRE-PROCESSING THE DATA 
#####################################################################################################################

#########################
# Dealing with outliers #
#########################

#Checking the distributions for the other variables to see if we have any outliers
boxplot(pima$Pregnancies, main = "Distribution of Pregnancies", ylab = "Range")
boxplot(pima$Glucose, main = "Distribution of Glucose", ylab = "Range") 
boxplot(pima$BloodPressure, main = "Distribution of BloodPressure", ylab = "Range") 
boxplot(pima$SkinThickness, main = "Distribution of SkinThickness", ylab = "Range") 
boxplot(pima$Insulin, main = "Distribution of Insulin", ylab = "Range") 
boxplot(pima$BMI, main = "Distribution of BMI", ylab = "Range")
boxplot(pima$DiabetesPedigreeFunction, main = "Distribution of DiabetesPedigreeFunction", ylab = "Range")
boxplot(pima$Age, main = "Distribution of Age", ylab = "Range")

#Let's see the percentage of outliers that need to be removed
find_outliers <- function(x, n = 3) {
  mean(x > mean(x) + n*sd(x) | x < mean(x) - n*sd(x))
}

find_outliers(pima_NArm$BloodPressure) +
find_outliers(pima_NArm$SkinThickness) +
find_outliers(pima_NArm$Insulin) +
find_outliers(pima_NArm$BMI) +
find_outliers(pima_NArm$DiabetesPedigreeFunction)

#Let's see the outliers in Pregnancies
pregnancies_outliers = boxplot.stats(pima[,"Pregnancies"])$out
pregnancies_outliers

#Let's see the outliers in Glucose
glucose_outliers = boxplot.stats(pima[,"Glucose"])$out
glucose_outliers

#Let's see the outliers in BloodPressure
blPressure_outliers = boxplot.stats(pima[,"BloodPressure"])$out
blPressure_outliers

#Let's see the outliers in SkinThickness
skin_outliers = boxplot.stats(pima[,"SkinThickness"])$out
skin_outliers

#Let's see the outliers in Insulin 
insulin_outliers = boxplot.stats(pima[,"Insulin"])$out
insulin_outliers

#Let's see the outliers in BMI
BMI_outliers = boxplot.stats(pima[,"BMI"])$out
BMI_outliers

#Let's see the outliers in DiabetesPedigreeFunction
pedigree_outliers = boxplot.stats(pima[,"DiabetesPedigreeFunction"])$out
pedigree_outliers

#Let's see the outliers in Age
age_outliers = boxplot.stats(pima[,"Age"])$out
age_outliers

#########################  
# Removing the outliers #  !!Un-comment to test the models with all outliers removed
######################### -Default with only BloodPressure and Insulin outliers removed, yields better performance

#Removing extreme BloodPressure outliers
pima = pima[!pima$BloodPressure %in% blPressure_outliers,]
#checking them again for BloodPressure
boxplot.stats(pima[,"BloodPressure"])$out

#Removing extreme Insulin outliers
pima = pima[!pima$Insulin %in% insulin_outliers,]
#checking them again for Insulin
boxplot.stats(pima[,"Insulin"])$out


### !!! UNCOMMENT THIS SECTION TO TEST THE MODELS WITH ALL OUTLIERS REMOVED :)

# #Removing extreme Pregnancies outliers
 pima = pima[!pima$Pregnancies %in% pregnancies_outliers,]
# #checking them again for Pregnancies
# boxplot.stats(pima[,"Pregnancies"])$out
#
# #Removing extreme Glucose outliers
 pima = pima[!pima$Glucose %in% glucose_outliers,]
# #checking them again for Glucose
# boxplot.stats(pima[,"Glucose"])$out

# #Removing extreme SkinThickness outliers
 pima = pima[!pima$SkinThickness %in% skin_outliers,]
# #checking them again for SkinThickness
# boxplot.stats(pima[,"SkinThickness"])$out
#
# #Removing extreme BMI outliers
 pima = pima[!pima$BMI %in% BMI_outliers,]
# #checking them again for BMI
# boxplot.stats(pima[,"BMI"])$out
#
# #Removing extreme DiabetesPedigreeFunction outliers
 pima = pima[!pima$DiabetesPedigreeFunction %in% pedigree_outliers,]
# #checking them again for DiabetesPedigreeFunction
# boxplot.stats(pima[,"DiabetesPedigreeFunction"])$out
#
# #Removing extreme Age outliers
 pima = pima[!pima$Age %in% age_outliers,]
# #checking them again for Age
# boxplot.stats(pima[,"Age"])$out

###################################################
# Partitioning the data into training/testing set #
###################################################

#setting the seed for reproducible results
set.seed(1234)

#splitting the data into train/test partitions
partition <- caret::createDataPartition(pima$Outcome, p = 0.25, list = FALSE)

#create training data set
training <- pima[-partition,]

#create testing data set, subtracting the rows partition to get remaining 25% of the data
testing <- pima[partition,]

#checking the statistical differences between the partitions
summary(training)
summary(testing)

par(mfrow=c(1, 2))
boxplot(training)
boxplot(testing)

#Checking the distribution of variables in the training set
par(mfrow=c(3, 3))
colnames_training <- dimnames(training)[[2]]
for (i in 1:8) {
  hist(training[,i], main=colnames_training[i], probability=TRUE, col="gray", border="white")
}

#Checking the distribution of variables in testing set
par(mfrow=c(3, 3))
colnames_testing <- dimnames(testing)[[2]]
for (i in 1:8) {
  hist(testing[,i], main=colnames_testing[i], probability=TRUE, col="gray", border="white")
}

par(mfrow=c(2, 2))

#Let's see how the Outcome is distributed in the training set
training_barchart = pima %>%
  group_by(Outcome) %>%
  summarize(count = n())
#plotting the data as a grouped bar chart
ggplot(training_barchart, aes(fill = as.factor(Outcome), y = count, x = as.factor(Outcome))) + 
  geom_bar(position="dodge", stat="identity")  +
  labs(title= "Outcome distribution in training set", x= "Outcome", y = "Count")

#Let's see how the Outcome is distributed in the testing set
testing_barchart = pima %>%
  group_by(Outcome) %>%
  summarize(count = n())
#plotting the data as a grouped bar chart
ggplot(testing_barchart, aes(fill = as.factor(Outcome), y = count, x = as.factor(Outcome))) + 
  geom_bar(position="dodge", stat="identity")  +
  labs(title= "Outcome distribution in training set", x= "Outcome", y = "Count")
#They're evelnly distributed

dev.off()

###########################
# Missing data imputation #
###########################

#percentage of missing values in pima
mean(is.na(pima)) * 100

#Counting the number of zero's in training/testing sets
sum(training$Outcome == 0) #354
sum(testing$Outcome == 0) #128

######################## Amelia Imputation ########################

#making copies of the training and testing sets so that we keep the originals intact
amelia_training <- training
amelia_testing <- testing

#Imputing missing values on the training set using Amelia imputation
amelia_training = amelia(training, m = 5, parallel = "multicore")
amelia_training = amelia_training$imputations[[5]]

sum(amelia_training$Outcome == 0) #354

#Imputing missing values on the testing set using Amelia imputation
amelia_testing = amelia(testing, m = 5, parallel = "multicore")
amelia_testing = amelia_testing$imputations[[5]]

sum(amelia_testing$Outcome == 0) #128

#checking if the imputations were successful
sapply(amelia_training, function(x) sum(is.na(x)))
sapply(amelia_testing, function(x) sum(is.na(x)))

######################## MissForest Imputation ########################

#making copies of the training and testing sets so that we keep the originals intact
missForest_training <- training
missForest_testing <- testing

#Imputing missing values on the training set using MissForest imputation
missForest_training <- missForest(training)
missForest_training = missForest_training$ximp

sum(missForest_training$Outcome == 0) #354

#Imputing missing values on the testing set using MissForest imputation
missForest_testing <- missForest(testing)
missForest_testing = missForest_testing$ximp

sum(missForest_testing$Outcome == 0) #128

#checking if the imputations were successful
sapply(missForest_training, function(x) sum(is.na(x)))
sapply(missForest_testing, function(x) sum(is.na(x)))


#####################################################################################################################
#                                                 BUILDING THE MODELS
#####################################################################################################################

########################################################################
# Testing on dataset with outliers removed AND missing data imputation #
########################################################################

###############################################
# MODEL : Neural Network on AMELIA IMPUTATION #
###############################################

#setting the seed for reproductible result
set.seed(1234)

#Turning the Outcome variable into a factor
amelia_training$Outcome = as.factor(amelia_training$Outcome)
amelia_testing$Outcome = as.factor(amelia_testing$Outcome)

#Creating the model
amelia_randForest <- nnet(Outcome~., data = amelia_training, size = 5, decay = 0.2)
amelia_randForest

#Amelia imputation, Random Forest prediction
amelia_rf_pred <- predict(amelia_randForest, amelia_testing, type = "class")

#Performance metrics
performance_amelia_rf = confusionMatrix(factor(amelia_rf_pred), amelia_testing$Outcome, mode = "everything", positive = "1")
performance_amelia_rf

###################################################
# MODEL :  Neural Network on MISSFOREST IMPUTATION # <--- Better performance
###################################################

#setting the seed for reproductible result
set.seed(1234)

#Turning the Outcome variable into a factor
missForest_training$Outcome = as.factor(missForest_training$Outcome)
missForest_testing$Outcome = as.factor(missForest_testing$Outcome)

#Creating the model
miss_randForest <- nnet(Outcome~., data = missForest_training, size = 5, decay = 0.2)
miss_randForest

#MissForest Imputation, Random Forest prediction
missForest_rf_pred <- predict(miss_randForest, missForest_testing, type = "class")

#Performance metrics
performance_miss_rf = confusionMatrix(factor(missForest_rf_pred), missForest_testing$Outcome, mode = "everything")
performance_miss_rf

###########################################################################################
# Testing on dataset with outliers removed, missing data imputation AND feature reduction #
###########################################################################################

############################################################################
# MODEL :  Neural Network with Amelia imputation and reduced to 5 features #
############################################################################

#Keeping only the variables Glucose, SkinThickness, Insulin, BMI, Age and Outcome
red_training <- amelia_training[,c("Glucose", "SkinThickness", "Insulin", "BMI", "Age", "Outcome")]
red_testing <- amelia_testing[,c("Glucose", "SkinThickness", "Insulin", "BMI", "Age", "Outcome")]

#setting the seed for reproductible result
set.seed(1234)

#Turning the Outcome variable into a factor
red_training$Outcome = as.factor(red_training$Outcome)
red_testing$Outcome = as.factor(red_testing$Outcome)

#Creating the model
red_randForest <- nnet(Outcome~., data = red_training, size = 5, decay = 0.2)
red_randForest

#MissForest Imputation, Random Forest prediction
red_rf_pred <- predict(red_randForest, red_testing, type = "class")

#Performance metrics
performance_red_rf = confusionMatrix(factor(red_rf_pred), red_testing$Outcome, mode = "everything")
performance_red_rf

############################################################################
# MODEL :  Neural Network with Amelia imputation and reduced to 6 features #
############################################################################

#Keeping only the variables Pregnancies, Glucose, BloodPressure, BMI, DiabetesPedigreeFunction, Age
red_training2 <- amelia_training[,c("Pregnancies", "Glucose", "BloodPressure", "BMI", "DiabetesPedigreeFunction", "Age", "Outcome")]
red_testing2 <- amelia_testing[,c("Pregnancies", "Glucose", "BloodPressure", "BMI", "DiabetesPedigreeFunction", "Age", "Outcome")]

#setting the seed for reproductible result
set.seed(1234)

#Turning the Outcome variable into a factor
red_training2$Outcome = as.factor(red_training2$Outcome)
red_testing2$Outcome = as.factor(red_testing2$Outcome)

#Creating the model
red_randForest2 <- nnet(Outcome~., data = red_training2, size = 5, decay = 0.2)
red_randForest2

#MissForest Imputation, Random Forest prediction
red_rf_pred2 <- predict(red_randForest2, red_testing2, type = "class")

#Performance metrics
performance_red_rf2 = confusionMatrix(factor(red_rf_pred2), red_testing2$Outcome, mode = "everything", positive = "1")
performance_red_rf2
