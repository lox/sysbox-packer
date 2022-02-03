#!/bin/bash
set -eu -o pipefail

# Install session-manager-plugin
# See https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-debian

curl -Lfs -q "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
  -o "session-manager-plugin.deb"

dpkg -i session-manager-plugin.deb
rm session-manager-plugin.deb

