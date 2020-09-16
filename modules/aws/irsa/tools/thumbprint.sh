#!/bin/bash

THUMBPRINT=$(openssl s_client -connect s3-$1.amazonaws.com:443 -servername s3-$1.amazonaws.com -showcerts < /dev/null 2>/dev/null | openssl x509 -in /dev/stdin -sha1 -noout -fingerprint | cut -d '=' -f 2 | tr -d ':')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo $THUMBPRINT_JSON