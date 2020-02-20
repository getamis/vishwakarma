#!/bin/bash

INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)

MAX_PODS_FILE="/etc/kubernetes/eni-max-pods.txt"
set +o pipefail
MAX_PODS=$(grep ^$INSTANCE_TYPE $MAX_PODS_FILE | awk '{print $2}')
set -o pipefail

[[ ! -n "$MAX_PODS" ]] && export MAX_PODS="110"
/usr/bin/systemctl set-environment MAX_PODS=$MAX_PODS
