###############################################################################
# Predict Future Sales of Fast-Food Menu Items
# 04 - Model evaluation 

# Load the data

test <- read.csv(
  "data/historicsales_fastfooditems_test.csv"
)

# Convert date to Date format
test$date <- as.Date(
  test$date,
  format = "%d-%b-%y"
)

# recreate the final model

train <- read.csv(
  "data/historicsales_fastfooditems_train.csv"
)

# Convert date
train$date <- as.Date(
  train$date,
  format = "%d-%b-%y"
)

# Final regression model
best_model <- lm(
  sales_quantity ~
    restaurant +
    item_name +
    baseprice_USD +
    discount_percent +
    is_weekend +
    is_friday +
    is_holiday,
  data = train
)

summary(best_model)

# check the test data
colSums(is.na(test))
test[is.na(test$discount_percent), ]

# Make predictions for the test data

predictions <- predict(
  best_model,
  newdata = test
)

head(predictions)

sum(is.na(predictions))

# Check predictions
prediction_results <- data.frame(
  actual = test$sales_quantity,
  predicted = predictions
)

head(prediction_results)

# Calculate the RMSE 
# It measures how far the predictions are from the actual sales values
rmse <- sqrt(
  mean(
    (prediction_results$actual -
       prediction_results$predicted)^2,
    na.rm = TRUE
  )
)

rmse

# save the predictions

prediction_results <- data.frame(
  actual = test$sales_quantity,
  predicted = predictions
)

write.csv(
  prediction_results,
  "results/test_predictions.csv",
  row.names = FALSE
)

# check model performance: 
model_performance <- data.frame(
  metric = c(
    "Overall correlation",
    "Highest group correlation",
    "Best adjusted R-squared",
    "Test RMSE"
  ),
  value = c(
    0.6451796,
    0.889,
    0.8515987,
    15.98273
  )
)

write.csv(
  model_performance,
  "results/model_performance.csv",
  row.names = FALSE
)

# Create a plot - actual vs predicted sales

library(ggplot2)

ggplot(
  prediction_results,
  aes(
    x = actual,
    y = predicted
  )
) +
  geom_point() +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "Actual vs Predicted Sales",
    x = "Actual Sales Quantity",
    y = "Predicted Sales Quantity"
  ) +
  theme_minimal()

# save
ggsave(
  "figures/actual_vs_predicted.png",
  width = 7,
  height = 5,
  dpi = 300
)

# check for additional modelling:
range(train$date)
range(test$date)

table(train$restaurant, train$item_name)
table(test$restaurant, test$item_name)
