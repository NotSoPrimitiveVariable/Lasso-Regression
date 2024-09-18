import matplotlib.pyplot as plt
from scipy.interpolate import interp1d
import numpy as np
import datetime
from Lasso_Regression.Unused.rating_hst import fetch_rating_history


def plot_rating_history(username):
    # Fetch the rating history
    ratings = fetch_rating_history(username)
    
    if not ratings:
        print(f"No rating data found for {username}.")
        return
    
    # Extract dates and ratings
    dates = [entry['date'] for entry in ratings]
    ratings_values = [entry['rating'] for entry in ratings]
    
    # Convert string dates to datetime objects for plotting
    dates = [datetime.datetime.strptime(date, '%Y-%m-%d') for date in dates]
    
    # Create the plot
    plt.figure(figsize=(10, 5))
    plt.plot(dates, ratings_values, marker='o', linestyle='-', color='b')
    
    # Set plot title and labels
    plt.title(f'Chess Rating History for {username}')
    plt.xlabel('Date')
    plt.ylabel('Rating')
    plt.grid(True)
    
    # Format the date on the x-axis
    plt.gcf().autofmt_xdate()
    
    # Show the plot
    plt.show()

# Example usage
#plot_rating_history('anseltrinidad')