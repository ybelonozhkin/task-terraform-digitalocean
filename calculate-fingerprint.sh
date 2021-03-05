#!/bin/sh
# This script calculates fingerprint for Rebrain key
# Key comment in output is omitted
fingerprint=$(ssh-keygen -E md5 -lf rebrain.pub | awk '{print $2}' | cut -d":" -f 2-)
echo -n "{\"fingerprint\":\"${fingerprint}\"}"

