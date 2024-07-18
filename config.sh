#!/bin/bash

  sudo apt update
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt install -y python3.7
  sudo apt install -y python3.7-venv
  python3.7 -m venv test
  source ./test/bin/activate
  git clone https://github.com/KingmanT/Demo-Banking_Application.git
  cd ./Demo-Banking_Application
  pip install -r requirements.txt
  python database.py
  python load_data.py
  python app.py &
