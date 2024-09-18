import os
import pandas as pd
from optimal import fetch_rating_history


def grab_player(user):
    # Define the directory path
    directory = os.path.join(os.getcwd(), 'my_player')

    # Create the directory if it doesn't exist
    if not os.path.exists(directory):
        os.makedirs(directory)
 
    try:   
        data = fetch_rating_history(user)
    except:
        print(f'Error: Failed to retrieve data for {user}')

    if data != 400:
        data_frame = pd.DataFrame(data)
        # Save the CSV file in the 'my csv files' directory
        file_path = os.path.join(directory, f'ratings_user.csv')
        data_frame.to_csv(file_path, index=False)
    else:
        return"err"
    
    return "completed"


print(grab_player('Lewisrobinson123'))