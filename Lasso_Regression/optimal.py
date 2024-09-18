import datetime
import requests

headers = {
    "User-Agent": "My-Application/1.0 (adrian.michael.ross08@gmail.com)",
    "Account-Name": "DemonChild2290"
}

def get_join_date(username, headers):
    profile_url = f'https://api.chess.com/pub/player/{username}'
    response = requests.get(profile_url, headers=headers)
    
    if response.status_code == 200:
        return datetime.datetime.utcfromtimestamp(response.json().get('joined')).year
    return None  # Returning None instead of string to indicate an error

def fetch_rating_history(username):
    current_date = datetime.datetime.now()
    current_year, current_month = current_date.year, current_date.month

    start_year = get_join_date(username, headers)
    if start_year is None:
        return []  # If the user is not found, return an empty list

    ratings = []
    valid_time_controls = {'600', '900+10', '1800'}

    username_lower = username.lower()

    for year in range(start_year, current_year + 1):
        for month in range(1, 13):
            if year == current_year and month > current_month:
                break

            url = f'https://api.chess.com/pub/player/{username}/games/{year}/{month:02d}'
            response = requests.get(url, headers=headers)
            
            if response.status_code == 404:
                continue
            elif response.status_code != 200:
                continue

            try:
                games = response.json().get('games', [])
            except ValueError:
                continue

            for game in games:
                if game.get('time_control') not in valid_time_controls:
                    continue

                white_player = game['white']
                black_player = game['black']

                if white_player['username'].lower() == username_lower:
                    ratings.append({'rating': white_player.get('rating')})
                elif black_player['username'].lower() == username_lower:
                    ratings.append({'rating': black_player.get('rating')})
    
    if len(ratings) < 100:
        return(400)
    else:
        return ratings

#print(fetch_rating_history('demonchild2290'))