#!/bin/bash

########## IMPORTANT! MUST RUN THE COMMAND BELOW ##########
#                    $ source setup.sh                    #
###########################################################

######## IMPORTANT! MUST BE CONFIGURED BY THE USER ########
author="name"
email="name@example.com"
package_name="pack"
project_dir="project"
root_path="/home/user/"
###########################################################

################## Validate variables #####################
package_pattern="^[a-zA-Z]+$"
project_dir_pattern="^[a-zA-Z0-9_]+$"
author_pattern="^[a-zA-Z]+( [a-zA-Z]+)?$"
email_pattern="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"

if [[ ! $package_name =~ $package_pattern ]]; then
    echo "Error: Invalid package name $package_name, can only be characters a-z and A-Z, no spaces or special characters"
    return
fi

if [[ ! $project_dir =~ $project_dir_pattern ]]; then
    echo "Error: Invalid project_dir $project_dir, see regex in script"
    return
fi

if [[ ! $author =~ $author_pattern ]]; then
    echo "Error: Invalid author $author, see regex in script"
    return
fi

if [[ ! $email =~ $email_pattern ]]; then
    echo "Error: Invalid email $email, see regex in script"
    return
fi
###########################################################

################## Data used for files ####################
func="
def get_example() -> None:
    return \"example\"
"

test_func="
from $package_name.utils import example

def test_get_example():
    assert example.get_example() == \"example\"
"

pyproject="
[build-system]
requires = [\"hatchling\"]
build-backend = \"hatchling.build\"

[project]
name = \"$package_name\"
version = \"0.0.1\"
authors = [{ name = \"$author\", email = \"$email\" }]
description = \"Brief description here\"
readme = \"README.md\"
requires-python = \">=3.8\"
classifiers = [\"Programming Language :: Python :: 3\"]
"

gitignore="
**/cmdline.egg-info/
**/__pycache__/
.pytest_cache
.venv
"
###########################################################

################# Creating bunch'o files ##################
cd "$root_path" || { echo "Error: Unable to change directory to $root_path"; return; }

mkdir "$project_dir" || { echo "Error: Unable to make directory $project_dir"; return; }

cd "$project_dir" || { echo "Error: Unable to change directory to $project_dir"; return; }

mkdir "src" || { echo "Error: Unable to make directory src"; return; }

mkdir "src/$package_name" || { echo "Error: Unable to make directory src/$package_name"; return; }

touch "src/$package_name/__init__.py" || { echo "Error: Unable to make file src/$package_name/__init__.py"; return; }

mkdir "src/$package_name/utils" || { echo "Error: Unable to make directory src/$package_name/utils"; return; }

touch "src/$package_name/utils/__init__.py" || { echo "Error: Unable to make file src/$package_name/utils/__init__.py"; return; }

touch "src/$package_name/utils/example.py" || { echo "Error: Unable to make file src/$package_name/utils/example.py"; return; }

mkdir "tests" || { echo "Error: Unable to make directory tests"; exit 1; }

touch "tests/test_example.py" || { echo "Error: Unable to make file tests/test_example.py"; return; }

touch "README.md" || { echo "Error: Unable to make file README.md"; return; }

touch "pyproject.toml" || { echo "Error: Unable to make file pyproject.toml"; return; }
###########################################################

################### Generating examples ###################
printf "%s" "$test_func" > "tests/test_example.py"

printf "%s" "$func" > "src/$package_name/utils/example.py"

printf "%s" "$pyproject" > "pyproject.toml"
###########################################################

################# Setting up environment ##################
python3 -m venv .venv || { echo "Error: Unable to make virtual environment"; return; }

source .venv/bin/activate || { echo "Error: Unable to activate virtual environment"; return; }

pip install -U pytest || { echo "Error: Unable to install pytest"; return; }

pip install -e . || { echo "Error: Unable to make virtual environment editable"; return; }
###########################################################

###################### Running tests ######################
clear

pytest tests/ || { echo "Error: Unable to run tests"; return; }
###########################################################

####################### Cleaning up #######################
find . -type d -name "__pycache__" -exec rm -rf {} + || { echo "Error: Unable to clean up"; return; }

rm -rf src/cmdline.egg-info || { echo "Error: Unable to clean up"; return; }

rm -rf .pytest_cache || { echo "Error: Unable to clean up"; return; }
###########################################################

################### Create requirements ###################
pip freeze > requirements.txt
###########################################################

######################## Setup git ########################
touch ".gitignore" || { echo "Error: Unable to make file .gitignore"; return; }

printf "%s" "$gitignore" > ".gitignore"

git init

git add .

git commit -m "Initial commit for $package_name"
###########################################################
