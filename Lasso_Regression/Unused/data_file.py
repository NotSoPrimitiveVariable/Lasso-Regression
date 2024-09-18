import os
import pandas as pd
from optimal import fetch_rating_history

# Read the CSV file
df = pd.read_csv('chess_usernames.csv')

# Assuming the usernames are in a column named 'Username'
nx = df['Username'].tolist()

def form_R_file(nx):
    # Define the directory path
    directory = os.path.join(os.getcwd(), 'my csv files')

    # Create the directory if it doesn't exist
    if not os.path.exists(directory):
        os.makedirs(directory)

    ip = 0
    for item in nx:
        try:   
            data = fetch_rating_history(str(nx[ip]))
        except Exception as e:
            print(f'Error: Failed to retrieve data for {nx[ip]} - {e}')
            continue

        if data != 400:
            data_frame = pd.DataFrame(data)
            # Save the CSV file in the 'my csv files' directory
            file_path = os.path.join(directory, f'ratings_{nx[ip]}.csv')
            data_frame.to_csv(file_path, index=False)
        ip += 1
    
    return "completed"

# Example usage
form_R_file(nx)
