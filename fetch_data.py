#!/usr/bin/env python3
"""
Small script to extract data from the paris opendata velib API
and save it as CSV files
"""

import json
from pathlib import Path
from typing import List, Any
from urllib.request import urlopen
import logging

URL = "https://opendata.paris.fr/explore/dataset/" \
      "velib-disponibilite-en-temps-reel/download/?format=json"
KEYS = [
    'nbbike', 'nbdock', 'nbbikeoverflow', 'nbfreedock',
    'nbebike', 'nbedock', 'nbebikeoverflow', 'nbfreeedock',
    'station_state', 'kioskstate', 'maxbikeoverflow', 'creditcard',
    'station_type', 'overflowactivation', 'station_code', 'overflow',
    'duedate', 'densitylevel'
]
ROOT = Path("./stations")


def write_data(dataset: List[Any]) -> None:
    """Takes a velib dataset and writes it to CSV files"""

    for datapoint in dataset:
        timestamp = str(datapoint.get('record_timestamp', 'NaN'))
        station = datapoint.get('fields', {})
        station_name = station.get('station_name', 'unknown')
        logging.info("Handling station %s", station_name)
        path = ROOT / (station_name + '.csv')
        add_header = not path.exists()
        with path.open('a') as file:
            if add_header:
                logging.info("Creating new file: %s", path)
                headers = ['datetime'] + KEYS
                file.write(','.join(headers) + '\n')
            values = [timestamp] + [json.dumps(station.get(k)) for k in KEYS]
            file.write(','.join(values) + '\n')


def write_stations_list(dataset: List[Any]) -> None:
    """Write the list of stations to a text file"""
    stations = sorted(set(
        s.get('fields', {}).get('station_name', 'unknown')
        for s in dataset
    ))
    Path("stations_list.txt").write_text("\n".join(stations))


def fetch_dataset() -> List[Any]:
    """Fetches a velib dataset from the paris opendata API"""
    for _ in range(3):
        try:
            return list(json.load(urlopen(URL)))
        except Exception as e:
            logging.error(e)


def main() -> None:
    """Launch the data extraction"""
    logging.basicConfig(format='%(asctime)s %(levelname)-6s %(name)-12s %(message)s', level="INFO")
    logging.info("Fetching dataset...")
    fetched = fetch_dataset()
    logging.info("Fetched %d data points.", len(fetched))
    write_data(fetched)
    logging.info("Wrote to CSV files. Writing station summary...")
    write_stations_list(fetched)
    logging.info("Done.")


if __name__ == '__main__':
    main()
