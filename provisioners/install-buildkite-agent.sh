#!/bin/bash
set -eu -o pipefail

# Install buildkite-agent
# Via https://github.com/buildkite/elastic-ci-stack-for-aws/blob/master/packer/linux/scripts/install-buildkite-agent.sh

AGENT_VERSION=3.32.0
ARCH=amd64

# Setup user and group for buildkite-agent
useradd --base-dir /var/lib --uid 2000 buildkite-agent
usermod -a -G docker buildkite-agent

# Install the binary
curl -Lsf -q -o /usr/bin/buildkite-agent \
  "https://download.buildkite.com/agent/stable/${AGENT_VERSION}/buildkite-agent-linux-${ARCH}"
chmod +x /usr/bin/buildkite-agent

# Install systemd service for buildkite-agent
cp /tmp/conf/systemd/buildkite-agent.service /etc/systemd/system/buildkite-agent.service

# Install a systemd hook to terminate instance on boot failure
mkdir -p /etc/systemd/system/cloud-final.service.d/
cp /tmp/conf/systemd/cloud-final.service.d/10-power-off-on-failure.conf /etc/systemd/system/cloud-final.service.d/10-power-off-on-failure.conf

# Setup git mirrors directory
mkdir -p /var/lib/buildkite-agent/git-mirrors

# Setup builds directory
mkdir -p /var/lib/buildkite-agent/builds

# Fix permissions
chown -R buildkite-agent: /var/lib/buildkite-agent
