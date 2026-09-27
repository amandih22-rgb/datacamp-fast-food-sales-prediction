Predicting Fast-Food Menu Item Sales

Project Overview

This project develops a machine-learning pipeline to predict daily sales quantities for fast-food menu items.

The project began as a DataCamp regression exercise and was extended into a more complete data-science workflow involving:

Exploratory data analysis

Feature engineering

Time-based validation

Regression modelling

Random Forest

XGBoost

Hyperparameter tuning

Rolling-window validation

Feature importance

Product-level error analysis

Forward sales forecasting

The objective is to investigate which factors are associated with sales and evaluate how well different machine-learning approaches can forecast future demand.

Data

The dataset contains historical daily sales information for fast-food items.

Variables include:

Restaurant

Menu item

Date

Base price

Discount percentage

Sales quantity

Weekend indicator

Friday indicator

Holiday indicator

Date ranges

Training data: 1 November 2023 – 30 November 2023

Test data: 1 December 2023 – 10 December 2023

The training dataset contains 120 observations across four restaurant-item combinations:

R1 Burger

R1 Salad

R2 Burger

R2 Salad

The final test set contains 10 observations for R1 Burger.

The original DataCamp data files are not included in this repository.

Data Quality and Cleaning

The data were inspected for:

Missing values

Duplicate observations

Variable types

Date ranges

Restaurant and item combinations

There were seven missing discount values in the training data.

These values were initially retained as missing rather than automatically treating them as zero because zero discounts were explicitly recorded on other observations.

For the final December forecast, the single missing discount value in the test data was imputed using the median observed November discount for R1 Burger.

The final forecast dataset includes a flag identifying this imputed observation.

Exploratory Data Analysis

The overall correlation between discount percentage and sales quantity was:

0.645

Correlation varied across restaurant-item combinations:

Restaurant

Item

Correlation

R1

Salad

0.889

R1

Burger

0.847

R2

Salad

0.845

R2

Burger

0.630

These results indicate a positive association between discount percentage and sales quantity, although the strength of the relationship differs across products.

Feature Engineering

Additional predictors were created to provide the machine-learning models with more informative representations of price and time.

Calendar features

Day of week

Day of month

Week of year

Month

Pricing features

Discount amount in USD

Selling price in USD

For example:

Selling price = Base price − Discount amount

These features provide the models with both the original pricing information and a direct representation of the effective selling price.

Modelling Strategy

Rather than randomly splitting the observations, chronological validation was used.

This was important because the objective is to predict future sales.

The primary validation split was:

Training:   1–23 November
Validation: 24–30 November

The final forecasting model was then trained using the available November data and used to predict sales for 1–10 December.

Model Comparison

Three modelling approaches were evaluated using the same time-based validation period.

Model

RMSE

MAE

Linear Regression

22.19

17.21

Random Forest

21.89

16.47

XGBoost

58.28

47.21

Random Forest produced slightly lower validation error than linear regression, while XGBoost performed substantially worse on this small dataset.

This demonstrates that increasing model complexity does not necessarily improve predictive performance.

Random Forest Tuning

Several Random Forest configurations were evaluated by varying:

mtry

nodesize

Number of trees

The best validation RMSE was obtained using:

mtry = 4
nodesize = 8
ntree = 500

The tuned model achieved:

Validation RMSE: 21.81

The improvement over the initial Random Forest was small, indicating that extensive tuning provides limited benefit with this small dataset.

Rolling Time-Based Validation

To assess whether model performance was consistent across different periods, expanding-window validation was also performed.

Validation period

RMSE

MAE

17–20 November

47.56

27.23

21–24 November

15.44

12.39

25–30 November

22.35

17.75

Average performance across the validation windows was:

Mean RMSE: 28.45

SD RMSE: 16.90

Mean MAE: 19.12

SD MAE: 7.52

The variation demonstrates that model performance was sensitive to changes in the sales pattern over time.

Feature Importance

Random Forest variable importance suggested that the most influential predictors included:

Restaurant

Base price

Discount amount

Selling price

Discount percentage

Day of week

Item name

This indicates that both product characteristics and pricing variables contribute to sales prediction.

The relatively low importance of month is expected because all observations occur during November.



Error Analysis

Prediction error was also examined separately for each restaurant-item combination.

Restaurant

Item

RMSE

MAE

R1

Burger

36.4

30.8

R1

Salad

14.0

11.9

R2

Burger

15.2

12.5

R2

Salad

12.9

10.7

R1 Burger showed substantially higher prediction error than the other products.

Inspection of daily sales patterns showed several large sales spikes for R1 Burger, suggesting that unusual demand events may not be fully explained by the available predictors.

Final December Forecast

The tuned Random Forest was trained using the available November observations and used to forecast R1 Burger sales for 1–10 December.

Date

Discount

Predicted Sales

1 Dec

0%

146

2 Dec

0%

160

3 Dec

0%*

158

4 Dec

0%

136

5 Dec

0%

140

6 Dec

50%

230

7 Dec

5%

147

8 Dec

0%

145

9 Dec

25%

170

10 Dec

0%

159

* The discount for 3 December was imputed using the November median discount for R1 Burger.



Key Findings

Discount percentage showed a positive association with sales.

Sales relationships differed between restaurant-item combinations.

Random Forest slightly outperformed linear regression on the primary time-based validation set.

XGBoost performed poorly on this small dataset.

Random Forest tuning produced only a modest improvement.

Rolling validation showed substantial variation in predictive performance over time.

R1 Burger had considerably higher prediction error than the other product groups.

Large sales spikes suggest that additional demand-related variables could improve future forecasting.

Limitations

The dataset is small, containing only 120 training observations.

The analysis is therefore vulnerable to:

Overfitting

Sensitivity to individual observations

Unstable validation performance

Limited ability to generalise to other periods or restaurants

The dataset also lacks potentially important demand drivers such as:

Weather

Local events

Marketing campaigns

Store traffic

Inventory availability

Delivery demand

Competitor activity

Consequently, the forecasts should be interpreted as a modelling exercise rather than production-ready demand forecasts.

Project Structure

datacamp-fast-food-sales-prediction/
│
├── data/
│   └── DataCamp datasets
│
├── figures/
│   ├── actual_vs_predicted.png
│   ├── random_forest_feature_importance.png
│   └── december_sales_forecast.png
│
├── R/
│   ├── 01_data_import.R
│   ├── 02_exploratory_analysis.R
│   ├── 03_feature_engineering.R
│   ├── 03_model_building.R
│   └── 04_model_evaluation.R
│
├── results/
│   ├── correlations_by_restaurant_item.csv
│   ├── model_results.csv
│   ├── december_sales_predictions.csv
│   └── ...
│
├── .gitignore
└── README.md

Tools and Technologies

R

RStudio

tidyverse

ggplot2

randomForest

xgboost

GitHub

GitHub Desktop

Skills Demonstrated

Data cleaning

Exploratory data analysis

Feature engineering

Regression modelling

Machine learning

Random Forest

XGBoost

Hyperparameter tuning

Time-based validation

Model evaluation

Error analysis

Data visualisation

Reproducible data-science workflows

Git/GitHub version control

Author

Amandi Hiyare
