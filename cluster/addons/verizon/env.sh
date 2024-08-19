#!/bin/bash

python -m venv cluster/addons/verizon/python.env
source cluster/addons/verizon/python.env/bin/activate
python -m pip install -r cluster/addons/verizon/requirements.txt

brew install geckodriver