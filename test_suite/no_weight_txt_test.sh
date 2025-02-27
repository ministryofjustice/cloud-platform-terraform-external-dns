#!/bin/bash

set -e

HOSTED_ZONE_ID=Z03152102TIZIFG7VPZU3
UPDATED_NAME='"_external_dns.cname.multi-container-app-starter-pack-0.apps.cp-2602-0836.cloud-platform.service.justice.gov.uk"'

aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --change-batch '
{
"Comment": "Testing upserting a record set"
,"Changes": [{
  "Action"              : "UPSERT"
  ,"ResourceRecordSet"  : {
    "Name"              : '"$UPDATED_NAME"'
    ,"Type"             : "TXT"
    ,"TTL"              : 300
    ,"ResourceRecords"  : [{
                "Value"         : "\"heritage=external-dns,external-dns/owner=cp-2602-0836,external-dns/resource=ingress/starter-pack-0/multi-container-app\""
            }]
        }
}]
}
'
