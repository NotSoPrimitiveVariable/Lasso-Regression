library(ggplot2)
library(mgcv)

# Load and prepare the data (assuming data and games are already defined)
data <- read.csv("ratings_user.csv")
games <- seq(1, length(data[[1]]))

# Calculate the value of `x` based on the length of `games`
x <- length(games) / 4

# Function for spline regression
spline_regression <- function(extend_by) {
    # Fit the GAM using the second column of the data as the response
    model <- gam(data[[1]] ~ s(games), method = "REML")
    
    # Print the model summary
    print(summary(model))
    
    # Extend the games list
    max_game <- max(games)
    extended_games <- seq(1, max_game + extend_by)
    
    # Generate predictions from the model for both the original and extended range
    fitted_values <- predict(model, newdata = data.frame(games = extended_games))
    
    # Create a custom plot with ggplot2
    windows() # Open a new graphics window
    ggplot(data.frame(games = extended_games, ratings = c(data[[1]], rep(NA, extend_by))), aes(x = games, y = ratings)) +
        geom_point(data = data, aes(x = games, y = data[[1]]), color = "black") + # Plot the original data points
        geom_line(aes(y = fitted_values), color = "blue") + # Add the fitted spline curve
        labs(x = "Games", y = "Current Player Ratings") + # Customize axis labels
        ggtitle("Games vs Current Player Ratings with Extended Spline Fit") + # Customize plot title
        xlim(0, NA) +  # Setting x-axis limit (0 to max)
        ylim(0, NA)    # Setting y-axis limit (0 to max)
}

# Print a summary of the data
print(summary(data))

# Run the spline regression with the calculated `x` value
print(spline_regression(extend_by = x))

# Optionally, plot the original data again separately if needed
graphing()
