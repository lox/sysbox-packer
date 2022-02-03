#!/bin/bash
set -euo pipefail

# Install the CloudWatch Agent which is now the recommended way of capturing logs

curl -Lfs -q "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb" \
  -o "amazon-cloudwatch-agent.deb"

dpkg -i -E ./amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

mv /tmp/conf/cloudwatch-agent/cloudwatch-agent.json /root/cloudwatch-agent.json
