from matplotlib import pyplot as plt
import numpy as np
from Lasso_Regression.Unused.rating_hst import fetch_rating_history
from scipy.optimize import curve_fit
import statsmodels.api as sm
import statsmodels.formula.api as smf

def log_func(x, a, b):
    return a * np.log(x) + b

def log_regression(x_data, y_data):
    x_data = np.array(x_data)
    y_data = np.array(y_data)

    # Fit the logarithmic regression model
    model = sm.OLS(y_data, np.log(x_data)).fit()
    # Get R-squared value
    r_squared = model.rsquared
    print(f'{r_squared} = R^2')
    R = np.sqrt(r_squared)
    print(f'{R} = R')
    
    popt, pcov = curve_fit(log_func, x_data, y_data)
    #print(pcov)

    return popt

def plot_rating_history(username):
    # Fetch the rating history
    ratings = fetch_rating_history(username)
    
    if not ratings:
        print(f"No rating data found for {username}.")
        return

    # Extract ratings and game numbers
    ratings_values = [entry['rating'] for entry in ratings]
    games = np.arange(1, len(ratings) + 1)

    # Perform logarithmic regression
    a, b = log_regression(games, ratings_values)
    
    # Generate x-values for plotting the regression line
    extended_games = np.arange(1, len(ratings) + (len(ratings)/4))
    predicted_ratings = log_func(extended_games, a, b)
    
    # Plotting the regression line
    plt.plot(extended_games, predicted_ratings, color='r', linestyle='--', label='Predicted rating')
    
    # Plotting the actual ratings
    plt.plot(games, ratings_values, marker='.', linestyle='', color='b', label='Actual Ratings')
    
    # Set plot title and labels
    plt.title(f'Chess Rating History for {username}')
    plt.xlabel('Game Number')
    plt.ylabel('Rating')
    plt.grid(True)
    
    # Set axis limits
    plt.xlim(left=0)
    plt.ylim(bottom=0)
    
    # Show legend
    plt.legend()
    
    # Show the plot
    plt.show()

# Example usage
username = input('what is your username? ')
plot_rating_history(username)
