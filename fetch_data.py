#!/usr/bin/env python3
"""
Small script to extract data from the paris opendata velib API
and save it as CSV files
"""

import pandas as pd 
import requests

def get_stations():
    sapi="https://velib-metropole-opendata.smoove.pro/opendata/Velib_Metropole/station_information.json"
    stations_df = pd.DataFrame(requests.get(sapi).json()["data"]["stations"])
    stations_df.set_index("stationCode", inplace=True)
    stations_df.sort_index(inplace=True)
    stations_df['station_geo'] = ["{:.5f},{:.5f}".format(s.lat,s.lon) for s in stations_df.itertuples()]
    stations_df['credit_card'] = stations_df.rental_methods.str.contains('CREDITCARD', regex=False).fillna(False)
    stations_df['station_name'] = stations_df["name"]
    return stations_df[['station_name', 'capacity', 'station_geo', 'credit_card']]

def get_statuses():
    sapi = "https://velib-metropole-opendata.smoove.pro/opendata/Velib_Metropole/station_status.json"
    j = requests.get(sapi).json()["data"]["stations"]
    df = pd.DataFrame(j)
    df["last_reported"] = df["last_reported"]
    df = df.astype({'is_renting':bool, 'stationCode':str,'last_reported':'datetime64[s]'})
    df = df.join(df["num_bikes_available_types"].apply(lambda l: pd.Series({**l[0], **l[1]})))
    df = df[["stationCode", "mechanical", "ebike", "is_renting", "last_reported"]]
    df.rename({
        "mechanical": "available_mechanical",
        "ebike": "available_electrical",
        "is_renting": "operative",
        "last_reported": "time",
    }, axis='columns', inplace=True)
    df["time"] = pd.Timestamp("now", tz='UTC') # TODO: use last_reported ?
    df.set_index('time', inplace=True)
    # df.sort_index(inplace=True)
    return df

def main():
    stations_df = get_stations()
    status_df = get_statuses()
    print(status_df)
    df = status_df.merge(stations_df, left_on="stationCode", right_index=True)
    df = df[["capacity","available_mechanical","available_electrical","station_name","station_geo","operative"]]
    df.to_csv('historique_stations.csv', header=False, mode='a', date_format='%Y-%m-%dT%H:%MZ')

main()
