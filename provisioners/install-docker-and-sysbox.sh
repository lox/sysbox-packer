#!/bin/bash
set -eu -o pipefail

# Install a specific version of docker for amd64
# See https://docs.docker.com/engine/install/ubuntu/

DOCKER_VERSION=5:20.10.7~3-0~ubuntu-focal

apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    build-essential \
    dkms \
    "linux-headers-$(uname -r)"

curl -fsSL -q https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] http://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker and friends
apt-get update -y
apt-get install -y --no-install-recommends \
  "docker-ce=$DOCKER_VERSION" \
  "docker-ce-cli=$DOCKER_VERSION" \
  containerd.io \
  amazon-ecr-credential-helper

echo "Kernel $(uname -r)"

# Install shiftfs kernel module
git clone -b k5.11 https://github.com/nestybox/shiftfs-dkms.git shiftfs-k511
cd shiftfs-k511
make -f Makefile.dkms
modinfo shiftfs
cd ..
rm -rf shiftfs-k511

modinfo configfs || true
modprobe configfs || true
modinfo shiftfs || true
modprobe shiftfs || true

# Install sysbox
curl -Lfs -q https://downloads.nestybox.com/sysbox/releases/v0.4.1/sysbox-ee_0.4.1-0.ubuntu-focal_amd64.deb \
    -o sysbox.deb
apt-get install -y ./sysbox.deb

# Install docker daemon config
cp /tmp/conf/docker/daemon.json /etc/docker/daemon.json
