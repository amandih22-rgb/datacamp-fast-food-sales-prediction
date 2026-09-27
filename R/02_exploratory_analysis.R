###############################################################################
# Predict Future Sales of Fast-Food Menu Items
# 02 - Exploratory Data Analysis

# ---------------------------------------------------------
# 1. LOAD DATA
# ---------------------------------------------------------

train <- read.csv(
  "data/historicsales_fastfooditems_train.csv"
)

# Convert date to Date format
train$date <- as.Date(
  train$date,
  format = "%d-%b-%y"
)


# Question 1: What is the correlation between discount percentage and sales quantity across the full training dataset?

correlation <- cor(
  train$discount_percent,
  train$sales_quantity,
  use = "complete.obs"
)

correlation
# 0.6451796
# Close to one indicates a moderate to strong positive relationship 
# The upward slope indicates that larger discounts generally tend to have higher sales quantities 

# Visualisation of the correlation 
library(ggplot2)

ggplot(
  train,
  aes(
    x = discount_percent,
    y = sales_quantity
  )
) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(
    title = "Discount Percentage and Sales Quantity",
    x = "Discount (%)",
    y = "Sales Quantity"
  ) +
  theme_minimal()

# Question 2 - Which restaurant and item pair have the highest correlation between discount and sales quantity?

library(dplyr)

correlations <- train %>%
  group_by(restaurant, item_name) %>%
  summarise(
    correlation = cor(
      discount_percent,
      sales_quantity,
      use = "complete.obs"
    ),
    .groups = "drop"
  )

correlations

correlations %>%
  arrange(desc(correlation))

# Create the highest pair and highest correlation
highest_pair <- correlations %>%
  arrange(desc(correlation)) %>%
  slice(1)

highest_cor <- c(
  highest_pair$restaurant,
  highest_pair$item_name
)

highest_cor

# Save the results table
write.csv(
  correlations,
  "results/correlations_by_restaurant_item.csv",
  row.names = FALSE
)
