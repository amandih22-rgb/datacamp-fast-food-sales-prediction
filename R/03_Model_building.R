###############################################################################
# Predict Future Sales of Fast-Food Menu Items
# 03 - Model building

# Load data
train <- read.csv(
  "data/historicsales_fastfooditems_train.csv"
)

# Convert date to Date format
train$date <- as.Date(
  train$date,
  format = "%d-%b-%y"
)

# build model 1 - Discount only

model_1 <- lm(
  sales_quantity ~ discount_percent,
  data = train
)

summary(model_1)

# Obtain R squared
summary(model_1)$adj.r.squared


# Build model 2 - Price, discount and calendar
model_2 <- lm(
  sales_quantity ~
    baseprice_USD +
    discount_percent +
    is_weekend +
    is_friday +
    is_holiday,
  data = train
)

summary(model_2)

# obtain R squared
summary(model_2)$adj.r.squared

# build model 3
# Here we introduce categorical variables 

model_3 <- lm(
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

summary(model_3)

# obtain R squared
summary(model_3)$adj.r.squared

# Compare the models 
model_results <- data.frame(
  model = c(
    "Model 1 - Discount only",
    "Model 2 - Numeric and calendar",
    "Model 3 - Full model"
  ),
  
  adjusted_r_squared = c(
    summary(model_1)$adj.r.squared,
    summary(model_2)$adj.r.squared,
    summary(model_3)$adj.r.squared
  )
)

model_results

# save the output:
write.csv(
  model_results,
  "results/model_results.csv",
  row.names = FALSE
)

# check how many observations each model uses
nobs(model_1) #113
nobs(model_2) #113
nobs(model_3) #113

# Select the model with the highest adjusted R-squared
best_model <- model_3

# Display the selected model
summary(best_model)
