from names import form_CSV_files
from new_data_file import form_R_file
import pandas as pd
from user_games import user_export

form_CSV_files()

# Read the CSV file
df = pd.read_csv('chess_usernames.csv')

# Assuming the usernames are in a column named 'Username'
nx = df['Username'].tolist()

form_R_file(nx)

username = input('What is your username? ')
user_export(username)

