###############################################################################
# Step 1: Loading data into the workspace 
# Note: I have downloaded both datasets from datacamp and saved into my 'data' file

list.files("data")
#[1] "historicsales_fastfooditems_test.csv"  "historicsales_fastfooditems_train.csv"

# Load the datasets: 

# Load the training data
train <- read.csv("data/historicsales_fastfooditems_train.csv")

# Load the test data
test <- read.csv("data/historicsales_fastfooditems_test.csv")

#-------------------------------------------------------------------------------# 
# Initial data checks 

# Check the number of rows and columns
dim(train)
dim(test)

# View column names
names(train)
names(test)

# Check structure
str(train)

# View first six rows
head(train)

# Summary statistics
summary(train)

#-----------------------------------------------------------------------------#
# Check missing values 

# Training 
colSums(is.na(train))
# there are 7 missing in discount percent 

# test data
colSums(is.na(test))

# 1 missing in discount percent

#-----------------------------------------------------------------------------#
# Check for duplicated rows

sum(duplicated(train))
sum(duplicated(test))
# no duplicated rows

# check important variables

# Unique restaurants
unique(train$restaurant)

# Unique food items
unique(train$item_name)

# Range of discounts
range(train$discount_percent, na.rm = TRUE)

# Range of sales
range(train$sales_quantity, na.rm = TRUE)

# Range of base prices
range(train$baseprice_USD, na.rm = TRUE)


# check discount percent
train[is.na(train$discount_percent), ]

# check further
train[
  train$restaurant == "R1" &
    train$item_name %in% c("Burger", "Salad"),
  c(
    "restaurant",
    "item_name",
    "date",
    "baseprice_USD",
    "discount_percent",
    "sales_quantity"
  )
]
# Handle missing values
# Discount percentage has 7 missing values in training
# and 1 missing value in test.
#
# Missing discounts are retained because 0% is explicitly
# recorded elsewhere in the dataset, so NA should not
# automatically be interpreted as no discount.
#
# Models using discount_percent will handle these missing
# observations appropriately.

#-----------------------------------------------------------------------------#
# check data types
str(train)
str(test)

# we can see that date is a character but needs to be a date:
# Convert date from character to Date
train$date <- as.Date(train$date, format = "%d-%b-%y")
test$date <- as.Date(test$date, format = "%d-%b-%y")
