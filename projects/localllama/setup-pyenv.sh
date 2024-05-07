#!/bin/bash

python -m virtualenv projects/localllama/.env
source projects/localllama/.env/bin/activate
pip install -r projects/localllama/requirements.txt
