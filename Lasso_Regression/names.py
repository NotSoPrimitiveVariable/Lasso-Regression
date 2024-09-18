import requests
import csv

headers = {
    "User-Agent": "My-Application/1.0 (adrian.michael.ross08@gmail.com)",
    "Account-Name": "DemonChild2290"
}


def fetch_usernames(country_code='JP', max_users=10000):
    url = f"https://api.chess.com/pub/country/{country_code}/players"
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        players = response.json()['players']
        # Return only up to `max_users` random players
        return players[:max_users]
    else:
        print('err no games found')
        return []

def form_CSV_files():
    # Fetch usernames (e.g., from the US, max 10 users)
    usernames = fetch_usernames()

    # Save the usernames to a CSV file
    with open('chess_usernames.csv', 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Username"])  # Write header
        for username in usernames:
            writer.writerow([username])

print(f"Usernames saved to 'chess_usernames.csv'")
