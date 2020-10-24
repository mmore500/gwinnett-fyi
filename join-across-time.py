from iterpop import iterpop as ip
from keyname import keyname as kn
import pandas as pd
import sys
import yaml

# take source pdf filenames as arguments
source_filenames = sys.argv[1:]

# get the dataset name
dataset_name = ip.pophomogeneous(
    kn.unpack(filename)['name']
    for filename in source_filenames
)

# load school name -> cluster name map from file
with open('school_to_cluster_map.yaml', 'r') as yaml_stream:
    cluster_map = yaml.load(yaml_stream, Loader=yaml.SafeLoader)


dataframes = []
for filename in source_filenames:
    df = pd.read_csv( filename )

    # rename columns to match existing conventions
    df = df.rename(
        {
            'School' : 'school',
            'Close Contact' : 'close_contact',
            'Positive Case' : 'positive_case',
            'Suspected Case' : 'suspected_case',
            'Total' : 'total',
        },
        axis='columns',
    )

    unpack = kn.unpack(filename)
    df['date'] = f'{unpack["month"]}/{unpack["day"]}/{unpack["year"]}'


    df['cluster'] = df.apply(
        lambda row: cluster_map[ row['school'] ],
        axis='columns',
    )
    
    dataframes.append(df)


pd.concat( dataframes ).to_csv(
    'output/' + {
        'new-by-school' : 'new_cases.csv',
        'active-by-school' : 'active_cases.csv',
    }[
        dataset_name
    ],
    index=False,
)
