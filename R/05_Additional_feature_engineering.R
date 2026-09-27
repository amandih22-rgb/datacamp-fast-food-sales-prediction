###############################################################################
# Predict Future Sales of Fast-Food Menu Items
# 5 - Additional step feature engineering: 


# Load data
train <- read.csv("data/historicsales_fastfooditems_train.csv")
test <- read.csv("data/historicsales_fastfooditems_test.csv")

# Convert dates
train$date <- as.Date(train$date, format = "%d-%b-%y")
test$date <- as.Date(test$date, format = "%d-%b-%y")


# Create a reusable function for feature engineering 
create_features <- function(data) {
  data %>%
    mutate(
      # Calendar features
      day_of_week = weekdays(date),
      day_of_month = as.integer(format(date, "%d")),
      week_of_year = as.integer(format(date, "%V")),
      month = as.integer(format(date, "%m")),
      discount_amount_USD =
        baseprice_USD * discount_percent / 100,
      selling_price_USD =
        baseprice_USD - discount_amount_USD
    )
}

# apply function 
train_features <- create_features(train)
test_features <- create_features(test)

# Convert categorical variables to factors 
train_features <- train_features %>%
  mutate(
    restaurant = factor(restaurant),
    item_name = factor(item_name),
    day_of_week = factor(day_of_week)
  )

test_features <- test_features %>%
  mutate(
    restaurant = factor(
      restaurant,
      levels = levels(train_features$restaurant)
    ),
    
    item_name = factor(
      item_name,
      levels = levels(train_features$item_name)
    ),
    
    day_of_week = factor(
      day_of_week,
      levels = levels(train_features$day_of_week)
    )
  )


# check new variables
names(train_features)

head(train_features)

summary(train_features)


# save the engineered datasets
write.csv(
  train_features,
  "results/train_features.csv",
  row.names = FALSE
)

write.csv(
  test_features,
  "results/test_features.csv",
  row.names = FALSE
)

# create time based training and validation sets
model_train <- train_features %>%
  filter(date <= as.Date("2023-11-23"))

validation <- train_features %>%
  filter(date >= as.Date("2023-11-24"))


# Check the date ranges
range(model_train$date)
range(validation$date)

# Check number of observations
nrow(model_train)
nrow(validation)

# run random forest model:

library(randomForest)

# Remove rows with missing discount values
rf_train <- model_train %>%
  select(
    sales_quantity,
    restaurant,
    item_name,
    baseprice_USD,
    discount_percent,
    is_weekend,
    is_friday,
    is_holiday,
    day_of_week,
    day_of_month,
    week_of_year,
    month,
    discount_amount_USD,
    selling_price_USD
  ) %>%
  na.omit()


# Build Random Forest model
rf_model <- randomForest(
  sales_quantity ~
    restaurant +
    item_name +
    baseprice_USD +
    discount_percent +
    is_weekend +
    is_friday +
    is_holiday +
    day_of_week +
    day_of_month +
    week_of_year +
    month +
    discount_amount_USD +
    selling_price_USD,
  data = rf_train,
  ntree = 500,
  importance = TRUE
)


# View model
rf_model

# Evaluate random forest on validation data

rf_validation <- validation %>%
  mutate(
    predicted = predict(rf_model, newdata = validation)
  )


# Calculate RMSE
rf_rmse <- sqrt(
  mean(
    (rf_validation$sales_quantity -
       rf_validation$predicted)^2,
    na.rm = TRUE
  )
)

rf_rmse

# Calculate the MAE:
rf_mae <- mean(
  abs(
    rf_validation$sales_quantity -
      rf_validation$predicted
  ),
  na.rm = TRUE
)

rf_mae

# check again using the Logistic regression - but with the updated data:

lm_model <- lm(
  sales_quantity ~
    restaurant +
    item_name +
    baseprice_USD +
    discount_percent +
    is_weekend +
    is_friday +
    is_holiday +
    day_of_week +
    day_of_month +
    week_of_year +
    month +
    discount_amount_USD +
    selling_price_USD,
  data = rf_train
)

# Predict validation data
lm_validation <- validation %>%
  mutate(
    predicted = predict(lm_model, newdata = validation)
  )


# Calculate RMSE
lm_rmse <- sqrt(
  mean(
    (lm_validation$sales_quantity -
       lm_validation$predicted)^2,
    na.rm = TRUE
  )
)


# Calculate MAE
lm_mae <- mean(
  abs(
    lm_validation$sales_quantity -
      lm_validation$predicted
  ),
  na.rm = TRUE
)


# Display results
lm_rmse
lm_mae


# now try XGboost: 
library(xgboost)

# Create model matrix
x_train <- model.matrix(
  sales_quantity ~
    restaurant +
    item_name +
    baseprice_USD +
    discount_percent +
    is_weekend +
    is_friday +
    is_holiday +
    day_of_week +
    day_of_month +
    week_of_year +
    month +
    discount_amount_USD +
    selling_price_USD,
  data = rf_train
)[, -1]


# Outcome variable
y_train <- rf_train$sales_quantity


# Build XGBoost model
xgb_model <- xgboost(
  data = x_train,
  label = y_train,
  nrounds = 100,
  max_depth = 3,
  eta = 0.05,
  objective = "reg:squarederror",
  verbose = 0
)

# Predict validation data
x_validation <- model.matrix(
  ~
    restaurant +
    item_name +
    baseprice_USD +
    discount_percent +
    is_weekend +
    is_friday +
    is_holiday +
    day_of_week +
    day_of_month +
    week_of_year +
    month +
    discount_amount_USD +
    selling_price_USD,
  data = validation
)[, -1]


xgb_predictions <- predict(
  xgb_model,
  newdata = x_validation
)


# Calculate RMSE
xgb_rmse <- sqrt(
  mean(
    (validation$sales_quantity -
       xgb_predictions)^2,
    na.rm = TRUE
  )
)


# Calculate MAE
xgb_mae <- mean(
  abs(
    validation$sales_quantity -
      xgb_predictions
  ),
  na.rm = TRUE
)


xgb_rmse
xgb_mae

# Compare model performance: 

model_comparison <- data.frame(
  Model = c(
    "Linear Regression",
    "Random Forest",
    "XGBoost"
  ),
  RMSE = c(
    lm_rmse,
    rf_rmse,
    xgb_rmse
  ),
  
  MAE = c(
    lm_mae,
    rf_mae,
    xgb_mae
  )
)

model_comparison

# Check the feature importance from random forest
importance(rf_model)
varImpPlot(rf_model)

# Save feature importance plot

png(
  "figures/random_forest_feature_importance.png",
  width = 1000,
  height = 700
)

varImpPlot(rf_model)

dev.off()

# Additional question - Does the model perform equally well for every product, or are some products much harder to predict?

# Error analysis by resturant and item:

rf_validation <- rf_validation %>%
  mutate(
    error = sales_quantity - predicted,
    absolute_error = abs(error),
    squared_error = error^2
  )


# Overall validation performance
overall_error <- rf_validation %>%
  summarise(
    RMSE = sqrt(mean(squared_error, na.rm = TRUE)),
    MAE = mean(absolute_error, na.rm = TRUE)
  )

overall_error

# Performance by restaurant and item
error_by_group <- rf_validation %>%
  group_by(restaurant, item_name) %>%
  summarise(
    RMSE = sqrt(mean(squared_error, na.rm = TRUE)),
    MAE = mean(absolute_error, na.rm = TRUE),
    mean_actual = mean(sales_quantity, na.rm = TRUE),
    mean_predicted = mean(predicted, na.rm = TRUE),
    .groups = "drop"
  )

error_by_group

# Check the actual sales patterns by resturant and item:

ggplot(
  train_features,
  aes(
    x = date,
    y = sales_quantity,
    group = item_name
  )
) +
  geom_line() +
  geom_point() +
  facet_grid(
    restaurant ~ item_name,
    scales = "free_y"
  ) +
  labs(
    title = "Daily Sales by Restaurant and Item",
    x = "Date",
    y = "Sales Quantity"
  ) +
  theme_minimal()

# Check the discount and sales relationship by product:

ggplot(
  train_features,
  aes(
    x = discount_percent,
    y = sales_quantity
  )
) +
  geom_point() +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  facet_grid(
    restaurant ~ item_name
  ) +
  labs(
    title = "Relationship Between Discount and Sales",
    x = "Discount (%)",
    y = "Sales Quantity"
  ) +
  theme_minimal()

#############################################
# Random forest updated with hyperparameter tuning

rf_tuning_results <- data.frame()

# Values to test
mtry_values <- c(2, 4, 6, 8)
nodesize_values <- c(3, 5, 8)

# Try each combination
for (mtry_value in mtry_values) {
  
  for (nodesize_value in nodesize_values) {
    model <- randomForest(
      sales_quantity ~
        restaurant +
        item_name +
        baseprice_USD +
        discount_percent +
        is_weekend +
        is_friday +
        is_holiday +
        day_of_week +
        day_of_month +
        week_of_year +
        month +
        discount_amount_USD +
        selling_price_USD,
      data = rf_train,
      ntree = 500,
      mtry = mtry_value,
      nodesize = nodesize_value
    )
    
    # Validation predictions
    predictions <- predict(
      model,
      newdata = validation
    )
    
    # Calculate metrics
    rmse <- sqrt(
      mean(
        (validation$sales_quantity - predictions)^2,
        na.rm = TRUE
      )
    )
    mae <- mean(
      abs(
        validation$sales_quantity - predictions
      ),
      na.rm = TRUE
    )
    

    # Store results
    rf_tuning_results <- rbind(
      rf_tuning_results,
      data.frame(
        mtry = mtry_value,
        nodesize = nodesize_value,
        RMSE = rmse,
        MAE = mae
      )
    )
  }
}


# Sort by RMSE
rf_tuning_results <- rf_tuning_results %>%
  arrange(RMSE)


rf_tuning_results


# Rolling time based validation:

validation_windows <- list(
  
  list(
    train_end = as.Date("2023-11-16"),
    valid_start = as.Date("2023-11-17"),
    valid_end = as.Date("2023-11-20")
  ),
  
  list(
    train_end = as.Date("2023-11-20"),
    valid_start = as.Date("2023-11-21"),
    valid_end = as.Date("2023-11-24")
  ),
  
  list(
    train_end = as.Date("2023-11-24"),
    valid_start = as.Date("2023-11-25"),
    valid_end = as.Date("2023-11-30")
  )
)


rolling_results <- data.frame()


for (i in seq_along(validation_windows)) {
  
  # Create training data
  rolling_train <- train_features %>%
    filter(date <= validation_windows[[i]]$train_end) %>%
    select(
      sales_quantity,
      restaurant,
      item_name,
      baseprice_USD,
      discount_percent,
      is_weekend,
      is_friday,
      is_holiday,
      day_of_week,
      day_of_month,
      week_of_year,
      month,
      discount_amount_USD,
      selling_price_USD
    ) %>%
    na.omit()
  
  
  # Create validation data
  rolling_valid <- train_features %>%
    filter(
      date >= validation_windows[[i]]$valid_start &
        date <= validation_windows[[i]]$valid_end
    )
  
  
  # Fit Random Forest
  rolling_model <- randomForest(
    sales_quantity ~
      restaurant +
      item_name +
      baseprice_USD +
      discount_percent +
      is_weekend +
      is_friday +
      is_holiday +
      day_of_week +
      day_of_month +
      week_of_year +
      month +
      discount_amount_USD +
      selling_price_USD,
    data = rolling_train,
    ntree = 500,
    mtry = 4,
    nodesize = 8
  )
  
  
  # Predict
  rolling_predictions <- predict(
    rolling_model,
    newdata = rolling_valid
  )
  
  
  # Metrics
  rolling_rmse <- sqrt(
    mean(
      (rolling_valid$sales_quantity -
         rolling_predictions)^2,
      na.rm = TRUE
    )
  )
  
  
  rolling_mae <- mean(
    abs(
      rolling_valid$sales_quantity -
        rolling_predictions
    ),
    na.rm = TRUE
  )
  
  
  # Store results
  rolling_results <- rbind(
    rolling_results,
    data.frame(
      validation_window = i,
      train_end = validation_windows[[i]]$train_end,
      validation_start = validation_windows[[i]]$valid_start,
      validation_end = validation_windows[[i]]$valid_end,
      RMSE = rolling_rmse,
      MAE = rolling_mae
    )
  )
}


rolling_results

# summarise the rolling performance:

rolling_summary <- rolling_results %>%
  summarise(
    mean_RMSE = mean(RMSE),
    sd_RMSE = sd(RMSE),
    mean_MAE = mean(MAE),
    sd_MAE = sd(MAE)
  )

rolling_summary


# Final forescasting model:

# Prepare full November training data

final_train <- train_features %>%
  select(
    sales_quantity,
    restaurant,
    item_name,
    baseprice_USD,
    discount_percent,
    is_weekend,
    is_friday,
    is_holiday,
    day_of_week,
    day_of_month,
    week_of_year,
    month,
    discount_amount_USD,
    selling_price_USD
  ) %>%
  na.omit()


# Train final model using all available November data

final_rf_model <- randomForest(
  sales_quantity ~
    restaurant +
    item_name +
    baseprice_USD +
    discount_percent +
    is_weekend +
    is_friday +
    is_holiday +
    day_of_week +
    day_of_month +
    week_of_year +
    month +
    discount_amount_USD +
    selling_price_USD,
  data = final_train,
  ntree = 500,
  mtry = 4,
  nodesize = 8,
  importance = TRUE
)


# View final model

final_rf_model

# Prepare December test data for prediction:

# Find the median November discount for R1 Burger

r1_burger_median_discount <- median(
  train_features$discount_percent[
    train_features$restaurant == "R1" &
      train_features$item_name == "Burger"
  ],
  na.rm = TRUE
)

r1_burger_median_discount

# # Impute the missing December discount

test_features$discount_was_imputed <-
  is.na(test_features$discount_percent)

test_features$discount_percent[
  is.na(test_features$discount_percent)
] <- r1_burger_median_discount


# Recalculate price features

test_features <- test_features %>%
  mutate(
    discount_amount_USD =
      baseprice_USD * discount_percent / 100,
    
    selling_price_USD =
      baseprice_USD - discount_amount_USD
  )


# Check the December test data

test_features %>%
  select(
    date,
    restaurant,
    item_name,
    discount_percent,
    discount_was_imputed,
    discount_amount_USD,
    selling_price_USD
  )

# December predictions

prediction_features <- test_features %>%
  select(
    restaurant,
    item_name,
    baseprice_USD,
    discount_percent,
    is_weekend,
    is_friday,
    is_holiday,
    day_of_week,
    day_of_month,
    week_of_year,
    month,
    discount_amount_USD,
    selling_price_USD
  )


# Generate predictions

december_predictions <- predict(
  final_rf_model,
  newdata = prediction_features
)


# Create final prediction table

december_forecast <- test_features %>%
  select(
    date,
    restaurant,
    item_name,
    discount_percent,
    discount_was_imputed
  ) %>%
  mutate(
    predicted_sales = round(december_predictions, 0)
  )


# View predictions

december_forecast

# Save: 
write.csv(
  december_forecast,
  "results/december_sales_predictions.csv",
  row.names = FALSE
)

# December sales forecast:

ggplot(
  december_forecast,
  aes(
    x = date,
    y = predicted_sales
  )
) +
  geom_line() +
  geom_point(size = 3) +
  labs(
    title = "Forecasted R1 Burger Sales: December 1–10, 2023",
    subtitle = "Random Forest model trained on November sales",
    x = "Date",
    y = "Predicted Sales Quantity"
  ) +
  theme_minimal()

# save:
ggsave(
  "figures/december_sales_forecast.png",
  width = 10,
  height = 6,
  dpi = 300
)
