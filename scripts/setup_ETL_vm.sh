#!/usr/bin/env bash
#
# Copyright 2020, Institute for Systems Biology
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y	git

#
# For legacy scripts that require a Python 2 environment, we build a virtual environment.
# We will take the Python 2 approach to installing it:
#

sudo apt-get install -y python-pip

#
# We want venv.
#

sudo apt-get install -y python-virtualenv

cd ~
virtualenv pyVenvForTwo
source ./pyVenvForTwo/bin/activate

pip install pandas
pip install requests
pip install python-dateutil

deactivate

#
# Newer scripts are written in Python 3, so we will create a virtual environment for that stuff:
#
#
# Do not use pip3 to upgrade pip. Does not play well with Debian pip
#

sudo apt-get install -y python3-pip

#
# We want venv:
#

sudo apt-get install -y python3-venv

#
# Google packages get the infamous "Failed building wheel for ..." message. SO suggestions
# for this situation:
# https://stackoverflow.com/questions/53204916/what-is-the-meaning-of-failed-building-wheel-for-x-in-pip-install
#
# pip3 install wheel
# OR:
# pip install <package> --no-cache-dir.
#
# Using the first option
#

cd ~
python3 -m venv pyVenvForThree
source pyVenvForThree/bin/activate
python3 -m pip install wheel
python3 -m pip install google-api-python-client
python3 -m pip install google-cloud-storage
python3 -m pip install google-cloud-bigquery
python3 -m pip install pandas
python3 -m pip install PyYaml
python3 -m pip install gitpython
python3 -m pip install xlrd
deactivate

#
# Off to github to get the code!
#

cd ~
rm -rf ~/ETL
git clone https://github.com/ImagingDataCommons/ETL.git
cd ETL/scripts
chmod u+x *.sh

# Make a place for scratch files:

mkdir -p ~/scratch

# Make a place for external libraries:

mkdir -p ~/extlib

# Install the environment setting script (to be customiized!)

mv ~/ETL/scripts/setEnvVars.sh ~

echo "Be sure to now customize the ~/setEnvVars.sh file to your system!"
