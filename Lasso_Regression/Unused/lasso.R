# Load the necessary library
library(glmnet)  # Package to fit ridge/lasso/elastic net models

# Load the data
data <- read.csv("ratings.csv")

# Assuming the ratings are in the second column of the CSV file
Y <- data[[2]]

# Create the predictor 'games', a sequence from 1 to the length of the ratings
X <- seq(1, length(Y))

# Reshape X to match the input format expected by glmnet (a matrix)
# Add a column of ones for the intercept
X_matrix <- cbind(1, matrix(X, ncol = 1))

# Split data into train (2/3) and test (1/3) sets
set.seed(42)  # Set seed for reproducibility
n <- length(Y)
train_rows <- sample(1:n, size = floor(0.66 * n))
X_train <- X_matrix[train_rows, , drop = FALSE]  # Ensuring it's a matrix
X_test <- X_matrix[-train_rows, , drop = FALSE]  # Ensuring it's a matrix
Y_train <- Y[train_rows]
Y_test <- Y[-train_rows]

# List to store the models
list_of_fits <- list()

# Fit models with different alpha values
for (i in 0:10) {
  alpha_value <- i / 10
  fit_name <- paste0("alpha", alpha_value)
  
  list_of_fits[[fit_name]] <- cv.glmnet(X_train, Y_train, type.measure = "mse", alpha = alpha_value, family = "gaussian")
}

# Data frame to store the results
results <- data.frame()

# Evaluate models on the test set
for (i in 0:10) {
  alpha_value <- i / 10
  fit_name <- paste0("alpha", alpha_value)
  
  predicted <- predict(list_of_fits[[fit_name]], s = list_of_fits[[fit_name]]$lambda.1se, newx = X_test)
  
  mse <- mean((Y_test - predicted)^2)
  
  temp <- data.frame(alpha = alpha_value, mse = mse, fit_name = fit_name)
  results <- rbind(results, temp)
}

# Print the results
print(results)
