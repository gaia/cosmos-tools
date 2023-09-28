#!/usr/bin/env python3

import requests
import json
from datetime import datetime, timedelta, timezone
import argparse
#import apprise

# Define the URL and the list of networks to include
url = "https://polkachu.com/api/v1/chain_upgrades"
networks_to_include = ["cosmos","regen","juno","osmosis","secretnetwork","sommelier","neutron","stride",
"quicksilver","terra","terra2","stargaze"]

# Create a parser to handle command-line arguments
parser = argparse.ArgumentParser(description='Check for upcoming upgrades to Cosmos chains. Usage ./check-upgrade.py 24 [--notify]')

# Add a positional argument for the number
parser.add_argument('number', type=int, help='An integer number of hours to raise an notification')

# Add an optional argument for the --notify flag
parser.add_argument('--notify', action='store_true', help='Enable notifications')

# Parse the command-line arguments
args = parser.parse_args()

# Access the values of the arguments

# Set the number of hours in advance you want to be notified
hrs_threshold = args.number

# Notifications require installation of Apprise
# See https://pypi.org/project/apprise/
notifications_on = args.notify

try:
    # Send the GET request
    response = requests.get(url, timeout=10)

    # Parse the JSON response
    json_response = response.json()

    # Get the current time in UTC
    now = datetime.now(timezone.utc)

    # Loop through each item in the response
    for item in json_response:
        # Check if an upgrade was found and the network is in the list of networks to include
        if item['network'] in networks_to_include:
            # Parse the estimated upgrade time as a datetime object
            estimated_upgrade_time = datetime.strptime(item['estimated_upgrade_time'], '%Y-%m-%dT%H:%M:%S.%fZ')
            estimated_upgrade_time = estimated_upgrade_time.replace(tzinfo=timezone.utc)  # Ensure the estimated_upgrade_time is aware of its timezone

            # Check if the estimated upgrade time is within the next the threshold number of hours
            if now <= estimated_upgrade_time <= now + timedelta(hours=hrs_threshold):
                # Print the details
                print(f"{item['network']}, {item['block']}, {item['node_version']}, {item['guide']}")
                if notifications_on:
                    # Enter your desired notification method 
                    # using Apprise's syntax
                    apobj = apprise.Apprise()
                    apobj.add("pagerduty://")
                    exit
            else:
                print(f"There are no scheduled upgrades within the next {hrs_threshold} hours for the networks you selected.")
    #print("Script completed successfully.")
except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")
except json.JSONDecodeError as e:
    print(f"Failed to parse JSON response: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
