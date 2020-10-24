import camelot
from collections import defaultdict
from keyname import keyname as kn
from os.path import basename
import pandas as pd
import pikepdf
import re
import sys
import tempfile

# take source pdf filename as argument
__, source_filename = sys.argv


# use pikepdf to do pdf repairs required by camelot
# store repaired pdf as a temporary file
repaired_filename = tempfile.mktemp(suffix='.pdf')
with pikepdf.Pdf.open(source_filename) as pdf:
    pdf.save(repaired_filename, normalize_content=True)

# scrape tables out of the repaired pdf file
raw_tables = camelot.read_pdf( repaired_filename, pages='1-end')

# some cells have weird duplicated content like "Close Contact\nClose Contact"
# but \n to the end always has what we need
# so if \n is present, use regex to strip from beginning of string to \n
# also, strip leading and trailing whitespace out of cells
cleaned_tables = [
    table.df.replace(
        to_replace =r'.*\n',
        value = '',
        regex = True,
    )
    for table in raw_tables
]

# use first row as dataframe headers
dataframes = [
    table.rename(
        columns=table.iloc[0]
    ).drop(
        table.index[0]
    )
    for table in cleaned_tables
]

# datasets always have a "Total" row at the bottom
# for datasets split over pdf pages, this tells where one dataset ends
# and the next begins
grouped_by_dataset = defaultdict( list )
dataset_counter = 0
for df in dataframes:

    # column names for second and third tables are sometimes corrupted
    # overwrite them manually here
    if dataset_counter > 0:
        assert len( df.columns ) == 5
        df.columns = [
            'School',
            'Close Contact',
            'Positive Case',
            'Suspected Case',
            'Total',
        ]

    grouped_by_dataset[ dataset_counter ].append( df )

    # if the 0th column contains final 'Total' entry, next entry is new dataset
    dataset_counter += ( 'Total' in df.iloc[-1, 0] )

# concatenate dataframes belonging to the same dataset together
datasets = [
    pd.concat( dataframes )
    for dataframes in grouped_by_dataset.values()
]

# save each dataset to a csv file
for name, dataset in zip(
        ["district-new", "new-by-school", "active-by-school"],
        datasets
    ):

    # drop last line (Total) from dataset
    assert 'Total' in dataset[0:-1]
    dataset = dataset[:-1]

    # save to file
    sanitized_filename = re.sub("[^0-9a-zA-Z]+", "|", basename(source_filename))
    dataset.to_csv(
        "output/input/" + kn.pack({
            "name" : name,
            "month" : sanitized_filename.split('|')[0],
            "day" : sanitized_filename.split('|')[1],
            "year" : sanitized_filename.split('|')[2],
            "ext" : '.csv',
        }),
        index = False,
    )
