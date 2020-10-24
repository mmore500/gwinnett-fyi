#!/bin/bash

pip3 install -r requirements.txt

git clone https://github.com/mmore500/g-fyi -b app-builder output

python3 join-across-time.py input/*active-by-school*.csv

python3 join-across-time.py input/*new-by-school*.csv

# upload files to OSF
osf -u "$OSF_USERNAME" -p q2f36 upload output/active_cases.csv active_cases.csv
osf -u "$OSF_USERNAME" -p q2f36 upload output/new_cases.csv new_cases.csv
