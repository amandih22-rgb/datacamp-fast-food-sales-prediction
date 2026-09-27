# datacamp-fast-food-sales-prediction
DataCamp project using R to predict fast-food menu item sales using regression modelling.

# Predicting Fast-Food Menu Item Sales

## Project Overview

This project develops a machine-learning pipeline to predict daily sales quantities for fast-food menu items.

The project began as a DataCamp regression exercise and was extended into a more complete data-science workflow involving:

- exploratory data analysis
- feature engineering
- time-based validation
- regression modelling
- Random Forest
- XGBoost
- hyperparameter tuning
- rolling-window validation
- feature importance
- product-level error analysis
- forward sales forecasting

The objective is to investigate which factors are associated with sales and evaluate how well different machine-learning approaches can forecast future demand.

---

## Data

The dataset contains historical daily sales information for fast-food items.

Variables include:

- Restaurant
- Menu item
- Date
- Base price
- Discount percentage
- Sales quantity
- Weekend indicator
- Friday indicator
- Holiday indicator

The training data cover:

**1 November 2023 – 30 November 2023**

The test data cover:

**1 December 2023 – 10 December 2023**

The training dataset contains 120 observations across four restaurant-item combinations:

- R1 Burger
- R1 Salad
- R2 Burger
- R2 Salad

The final test set contains 10 observations for R1 Burger.

The original DataCamp data files are not included in this repository.

---

## Data Quality and Cleaning

The data were inspected for:

- missing values
- duplicate observations
- variable types
- date ranges
- restaurant and item combinations

There were seven missing discount values in the training data.

These values were initially retained as missing rather than automatically treating them as zero because zero discounts were explicitly recorded on other observations.

For the final December forecast, the single missing discount value in the test data was imputed using the median observed November discount for R1 Burger. The forecast dataset includes a flag identifying this imputed observation.

---

## Exploratory Data Analysis

The overall correlation between discount percentage and sales quantity was:

**0.645**

Correlation varied across restaurant-item combinations:

| Restaurant | Item | Correlation |
|------------|------|------------:|
| R1 | Salad | 0.889 |
| R1 | Burger | 0.847 |
| R2 | Salad | 0.845 |
| R2 | Burger | 0.630 |

These results indicate a positive association between discount percentage and sales quantity, although the strength of the relationship differs across products.

---

## Feature Engineering

Additional predictors were created to provide the machine-learning models with more informative representations of price and time.

### Calendar features

- Day of week
- Day of month
- Week of year
- Month

### Pricing features

- Discount amount in USD
- Selling price in USD

For example:

```text
Selling price = Base price − Discount amount
