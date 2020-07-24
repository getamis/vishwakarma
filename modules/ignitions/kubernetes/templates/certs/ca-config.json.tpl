{
    "signing": {
        "default": {
            "expiry": "${expiry}"
        },
        "profiles": {
            "kubernetes": {
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ],
                "expiry": "${expiry}"
            }
        }
    }
}