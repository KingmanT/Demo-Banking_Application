#!/bin/bash
  sudo apt install jq -y
  wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
  cd /opt/aws/amazon-cloudwatch-agent/bin
  sudo  echo '{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "metrics": {
        "append_dimensions": {
            "InstanceId": "${aws:InstanceId}",
            "InstanceType": "${aws:InstanceType}",
            "ImageID": "${aws:ImageId}"
        },
        "metrics_collected": {
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
                 },
            "disk": {
                "resources": [
                    "/",
                    "/tmp"
                ],
                "measurement": [
                    { "name": "free", "rename": "DISK_FREE", "unit": "Gigabytes" },
                    "total",
                    "used",
                    "used_percent"
                ],
                "ignore_file_system_types": [
                    "sysfs", "devtmpfs"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}' | jq . > config.json
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start

  sudo apt update
  sudo apt install -y software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt install -y python3.7
  sudo apt install -y python3.7-venv
  python3.7 -m venv test
  source ./test/bin/activate
  git clone https://github.com/KingmanT/Banking_Application.git
  cd ./Banking_Application
  pip install -r requirements.txt
  python database.py
  python load_data.py
  python app.py