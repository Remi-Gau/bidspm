#!/bin/bash

make boilerplate
make clean_default_options
make default_mapping

# needed to ignore svg badges
sed -i 's/<!-- .. only:: not latex -->/.. only:: not latex/g' ../README.md
sed -i 's/\[!\[/    \[!\[/g' ../README.md

python generate_doc.py

sphinx-build -M latexpdf source build

cp build/latex/bidspm.pdf bidspm-manual.pdf

sed -i 's/.. only:: not latex/<!-- .. only:: not latex -->/g' ../README.md
sed -i 's/    \[!\[/\[!\[/g' ../README.md
