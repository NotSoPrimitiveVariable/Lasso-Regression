import datetime
import requests

headers = {
    "User-Agent": "My-Application/1.0 (adrian.michael.ross08@gmail.com)",
    "Account-Name": "DemonChild2290"
}

def get_join_date(username, headers):
    profile_url = f'https://api.chess.com/pub/player/{username}'
    url_response = requests.get(profile_url, headers=headers)
    
    if url_response.status_code == 200:
        data = url_response.json()
        timestamp = data.get('joined')
        start_date = datetime.datetime.utcfromtimestamp(timestamp)
        start_year = start_date.year
        return start_year
    else:
        return f'{username} is not a real player'

#print(get_join_date('demonchild2290', headers))

def fetch_rating_history(username):
    current_year = datetime.datetime.now().year
    current_month = datetime.datetime.now().month
    
    ratings = []
    
    for year in range(get_join_date(username, headers), current_year + 1):
        for month in range(1, 13):
            
            if year == current_year and month > current_month:
                break

            url = f'https://api.chess.com/pub/player/{username}/games/{year}/{month:02d}'
            response = requests.get(url, headers=headers)
            
            if response.status_code == 404:
                print(f"Data not found for {year}-{month}. Skipping...")
                continue
            elif response.status_code != 200:
                print(f"Error: {response.status_code} for {year}-{month}")
                continue

            try:
                games = response.json().get('games', [])
            except ValueError:
                print("Failed to parse JSON response")
                continue

            for game in games:
                white_player = game['white']
                black_player = game['black']
                time_control = game['time_control']

                if time_control != '600' or '900+10' or "1800":
                   continue
            
                if white_player['username'].lower() == username.lower():
                    ratings.append({'rating': white_player['rating']})
                elif black_player['username'].lower() == username.lower():
                    ratings.append({'rating': black_player['rating']})
    return ratings

#print(fetch_rating_history('theotherguy500'))
print(fetch_rating_history('demonchild2290'))