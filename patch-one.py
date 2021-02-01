import yaml
from os.path import basename
import subprocess
import sys

# takes one argument: filename of csv file to patch
__, target_filename = sys.argv

# load known patches from file
with open('per-file-patches.yaml', 'r') as yaml_stream:
    patch_map = yaml.load(yaml_stream, Loader=yaml.SafeLoader)

# if a known patch applies to this file, use sed to apply it
if basename(target_filename) in patch_map:
    for patch in patch_map[basename(target_filename)]:
        subprocess.call([
            'sed',
            '-i',
            f's/{patch["find"]}/{patch["replace"]}/g',
            target_filename,
        ])

# Gwinnett School of Mathematics, Science, and Technology
# is messed up all over the place...
# minimal risk of patching something that shouldn't be with these patterns
# so just apply them to all files
subprocess.call([
    'sed',
    '-E',
    '-i',
    's/"Science, and Technology"|"Science,  and Technology"|"              ,        Technology"|"              ,  nd Technology"/"Gwinnett School of Mathematics, Science, and Technology"/g',
    target_filename,
])

subprocess.call([
    'sed',
    '-E',
    '-i',
    's/^Science and Technology,/"Gwinnett School of Mathematics, Science, and Technology",/g',
    target_filename,
])

subprocess.call([
    'sed',
    '-E',
    '-i',
    's/^Science(cid:853) and Technology,/"Gwinnett School of Mathematics, Science, and Technology",/g',
    target_filename,
])
