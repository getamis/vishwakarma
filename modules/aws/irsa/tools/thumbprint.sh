#!/bin/bash
if [ "$1" == "us-east-1" ] then
    OIDC_SERVERNAME="s3.amazonaws.com"
else
    OIDC_SERVERNAME="s3-$1.amazonaws.com"
fi
THUMBPRINT=$(openssl s_client -connect ${OIDC_SERVERNAME}:443 -servername ${OIDC_SERVERNAME} -showcerts < /dev/null 2>/dev/null | openssl x509 -in /dev/stdin -sha1 -noout -fingerprint | cut -d '=' -f 2 | tr -d ':')
THUMBPRINT_JSON="{\"thumbprint\": \"${THUMBPRINT}\"}"
echo $THUMBPRINT_JSON