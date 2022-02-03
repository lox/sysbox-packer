#!/bin/bash
set -euo pipefail

apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean
