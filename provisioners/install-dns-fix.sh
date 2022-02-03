#!/bin/bash
set -eu -o pipefail

cp /tmp/conf/systemd/fix-dns.service /etc/systemd/system/fix-dns.service
systemctl enable fix-dns
