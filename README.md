# Diabetes-Prediction
_This is an excerpt taken from the joint academic paper which can be found in full in the attached files._

Data Science project for predicting diabetes based on the Pima Indians Diabetes dataset, using Artificial Neural Network in R language.
 

The project is divided into four main parts:
1. Data Exploration
2. Data Pre-Processing
3. Building the models
4. Results

**I. Data Exploration**

![missing data box plot](https://user-images.githubusercontent.com/106180362/170104911-aee6df4e-bbe7-4d6a-a594-da1a95c1ab64.png)

Upon initial inspection of the dataset it is clear there are a number of zeros within many features. For the features Pregnancies and Outcome the zeros are feasible values, as it is feasible a woman has not had any pregnancies and 0 in Outcome represents the absence of diabetes. However, for the features BloodPressure, SkinThickness, Glucose, BMI, and Insulin the value zero is impossible, therefore this most likely represents missing values. 
There is a large amount of missing data on SkinThickness and Insulin, 29.6% and 48.7% respectively, which will need to be tackled in data preprocessing as leaving these values as zeros may negatively impact model performance.

Another potential problem to model performance are outliers that may exist within data. Outliers are observations that exist at extreme limits from other values.

<img width="436" alt="Screenshot 2022-05-24 at 19 22 27" src="https://user-images.githubusercontent.com/106180362/170105545-ced84d50-1d30-41a5-b91a-52a487817ff2.png">

The correlation matrix confirms that even after removing any missing values, the variables Glucose and Insulin are highly correlated, as well as SkinThickness and BMI. What this could mean is that there is another factor that is causing these correlations, namely the presence of diabetes in this case.

**II. Data Pre-Processing**

Pre-processing aims at assessing and improving the quality of data to allow for reliable statistical analysis. After the exploratory analysis of the data, the only issues found were missing values for a few variables and outliers, which need to be addressed. The dataset has to go through several pre-processing steps before we can build our models, otherwise the missing values and outliers can introduce bias and skew our analysis and results. Other than this, the dataset is tidy and doesn’t require further cleaning up.
The first step was transforming all the 0 values from the variables Glucose, Blood Pressure, Skin Thickness, Insulin, BMI and Diabetes Pedigree Function into NA’s so that the dataset could be used for visualizations and imputed later on.

_Outliers_

Outliers were found in all variables, but Glucose, by using boxplots. However, such high measurements of Insulin and BloodPressure are most likely erroneous and because it was found that a classifier degrades in performance with the presence of noise, they were removed in Model 1 and Model 2 so that they do not skew the results. 
Various techniques have been proposed for dealing with outliers, one of them being oversampling. However, our dataset only has 0.06% outliers, which is not a significant number, thus I opted for removing the ones in Model 1 and Model 2 only for variables SkinThickness and Insulin which were implausible, as the model won’t be affected by the loss of instances.

_Partitioning the dataset_

The dataset was partitioned into training and testing, then both of them checked to see if their distributions were similar using visualizations.

_Missing data imputation_

The dataset doesn’t come with an extensive documentation that details how exactly the data was gathered. Thus, it is unclear to us how the missing data came to be. 

These are the three common reasons for missing data:
- Missing Completely at Random (MCAR): the missing value is unrelated to the value of other observed variables
- Missing at Random (MAR): the missing value is related to other observed values in the dataset but not to the variable itself
- Missing Not at Random (MNAR): the missing data depends on both missing and observed values

Little's MCAR test was used to check whether the missing data is MCAR. The test statistic is a chi-squared value that proposes a null hypothesis that the missing data is Missing Completely At Random. The p-value we got was 1.28 × 10^-9, less than 0.05, so we interpret it as being that the missing data is not MCAR.

The choice of imputation method should be influenced by the reason for the missing data.  In our case, values are missing for unidentifiable reasons, so we assume that they are missing because of random and unintended causes. This makes them recoverable using various imputation methods.

There are 652 missing values in the dataset, or 9.4% , so removing them is not a viable option,as they would leave us with a reduced dataset that would most likely not generate a lot of insights. Besides that, leaving them in may lead to a loss of predictive power and ability to detect statistically significant differences and it can be a source of bias, affecting the representativeness of the results. 

Single imputation replaces the missing observations with a single value, which disturbs the relations between variables and introduces bias. 
Therefore, I opted to use multiple imputation over single imputation in order to replace the missing observations, namely Amelia imputation and MissForest imputation, which was shown to be a highly accurate method in clinical predictive models.

_Feature Selection/Reduction_

In an attempt to try and increase accuracy, the model was tested on a subset of five features that ranked very highly in terms of relevance to make a diagnosis, namely Glucose, BMI, Age, Insulin and Skin Thickness. A further attempt at reducing the dataset was made to improve performance and for comparison purposes by implementing the second author’s way of only removing the features SkinThickness and Insulin, leaving me with 6 features.

 
**III. Building the Models** 
 
An Artificial Neural Network algorithm was used to produce a classification for the Pima Indians Diabetes dataset and six different models were created and compared.
The classification was done iteratively, the pre-processing was done in stages and each model was tested on the dataset at each of the stages. The stages can be seen in the following figure:

<img width="514" alt="Screenshot 2022-05-24 at 19 27 48" src="https://user-images.githubusercontent.com/106180362/170106515-30d35e74-014e-4072-a33a-2116949e254f.png">


**IV. Results**

_Data Analysis and Pre-Processing stage_

Visualization was an important tool for insight generation and discovering anomalies in the data and was successful in pointing me towards the areas that needed pre-processing, namely discovering missing observations disguised by zero values and boundary violations in the form of outliers.

Visualizing the percentage of missing data for every age group gave another valuable insight. We can see that for the variable Insulin, the percentage of missing values grows as the age gets higher, with over 60% of missing data for patients over 60. However, at closer inspection, it becomes apparent that this is because the number of observations significantly decreases as the patients get older. Removing the entries with missing values entirely will result in excluding observations for patients over 60 and the classification model will not generalize well for older patients, as it will likely introduce bias.

_Classification Stage_

The performance metrics used were Accuracy, Sensitivity, Specificity, Precision, F1-Score. The summary of models can be seen in Fig. 8. Before running each model the seed “1234” was set for reproducible results. 

In stage one and stage two, which tested the models with outliers from BloodPressure and Insulin removed and used Amelia and MissForest Imputation, Model 1, which underwent Amelia imputation, with a score of 83.06% Accuracy out-performed Model 2 that used MissForest imputation on all of the metrics, therefore that is the one that was carried forward to the feature reduction phase. So far, this suggested that Amelia imputation was more appropriate and better performing.

However, Stage two results suggest that removing outliers from all variables did not improve performance. In fact, it significantly decreased it, although Model 3 using Amelia imputation once again out-performed Model 4 using MissForest Imputation on four out of the five metrics and by 2.34% on Accuracy.

The best performing model out of the four tested so far was Model 1, so it was carried forward for further testing in the feature reduction stages. It surpassed all of the other models on all of the performance metrics.

At Stage three, Model 1 was tested on a dataset reduced to five features that were deemed the most influential in making a prediction about diabetes. Once again, further pre-processing did not improve performance when compared by the Accuracy score, however it didn’t degrade by a lot in the following: Sensitivity (86.72%), Precision (83.46%) and F1 (85.06%).

Since the models were declining in performance with every stage of pre-processing, in Stage four the second author’s method of removing SkinThickness and Insulin was tested on Model 1 in an attempt to improve performance. The model scored less than Model 5, with a significant decrease in Sensitivity (65.45%), Precision (60%) and F1 (62.61%).

Finally, the best performing model was Model 1, with an Accuracy of 83.06%, which underwent minimal pre-processing.

<img width="512" alt="Screenshot 2022-05-24 at 19 33 12" src="https://user-images.githubusercontent.com/106180362/170107431-834bc67c-6d11-4367-8e36-e13e141d5bbb.png">
