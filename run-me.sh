#!/bin/bash

# run at most four jobs in parallel
function max4 {
  while [ `jobs | wc -l` -ge 4 ]; do
    sleep 5
  done
}

pip3 install -r requirements.txt

git clone https://github.com/mmore500/g-fyi -b data-joiner output

mkdir -p output/input

for input in input/*.pdf; do

  echo "processing ${input}..."

  max4; python3 extract-one.py "$input" &

done

wait

for output in output/input/*; do

  echo "patching ${output}..."

  python3 patch-one.py "$output"

done
