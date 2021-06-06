import os
import json
import time
import requests
import urllib.parse
import pandas as pd


def get_bearer_token():
    return '<< SECRET KEY >>'


def create_url(p_next_token):
    tweet_fields = "tweet.fields=created_at"
    # Tweet fields are adjustable.
    # Options include:
    # attachments, author_id, context_annotations,
    # conversation_id, created_at, entities, geo, id,
    # in_reply_to_user_id, lang, non_public_metrics, organic_metrics,
    # possibly_sensitive, promoted_metrics, public_metrics, referenced_tweets,
    # source, text, and withheld
    
    query_params = f"query={urllib.parse.quote('bookkeeping lang:en -is:retweet')}"
    if len(p_next_token) == 0:
        next_param = ""
    else:
        next_param = f"&next_token={p_next_token}"
    return f"https://api.twitter.com/2/tweets/search/recent?{query_params}&{tweet_fields}&max_results=100{next_param}"


def create_headers(bearer_token):
    return {"Authorization": "Bearer {}".format(bearer_token)}


def connect_to_endpoint(p_url, p_headers):
    response = requests.request("GET", p_url, headers=p_headers)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
        print("Error")
    return response.json()


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    next_token = ""
    data_df = None
    file_name = "../Bookkeeping_Tweets_2021-06-04.csv"

    while True:
        url = create_url(next_token)
        headers = create_headers(get_bearer_token())
        json_response = connect_to_endpoint(url, headers)
        
        if data_df is None:
            data_df = pd.DataFrame(json_response["data"])
        else:
            data_df = pd.concat([data_df, pd.DataFrame(json_response["data"])])
        
        print(f"Data retrieved: {len(data_df)}")
        
        if (len(data_df) >= 1000):
            break
        elif ("next_token" in json_response["meta"].keys()):
            next_token = json_response["meta"]["next_token"]
        else:
            break
        
    print(f"Finished! Total data retrieved: {len(data_df)}")

    if (os.path.exists(f"./{file_name}")):
        previous_df = pd.read_csv(file_name, index_col=0, dtype={"created_at":object, "id":object, "text":object})
        new_df = pd.concat([previous_df, data_df]).reset_index()[["created_at", "id", "text"]]
    else:
        new_df = data_df

    new_df.drop_duplicates(ignore_index=True, inplace=True)
    new_df.to_csv(file_name)

    print(f"\nFinal concat file: {len(new_df)}")
