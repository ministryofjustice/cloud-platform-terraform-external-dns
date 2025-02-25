#!/bin/bash

set -e

HOSTED_ZONES=$(cat test_hosted_zones)

upsert_record() {
    TXT_OBJ=$(cat $1)

    echo $TXT_OBJ | jq '.'

    HOSTED_ZONE_ID=$(echo "$TXT_OBJ" | jq -r '.HostedZoneId')
    WEIGHT=$(echo "$TXT_OBJ" | jq '.Weight')
    SET_IDENTIFIER=$(echo "$TXT_OBJ" | jq '.SetIdentifier')
    RESOURCE_RECORD_VALUE=$(echo "$TXT_OBJ" | jq '.ResourceRecords[0].Value')


    NAME=$(echo "$TXT_OBJ" | jq '.Name')

    if echo $NAME | grep -vq "_external_dns.cname"; then
        UPDATED_NAME=$(echo "$NAME" | sed 's/_external_dns\./_external_dns.cname./g')

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
                ,"SetIdentifier"    : '"$SET_IDENTIFIER"'
                ,"Weight"           : '"$WEIGHT"'
                ,"ResourceRecords"  : [{
                            "Value"         : '$RESOURCE_RECORD_VALUE'
                        }]
                    }
            }]
          }
        '
    fi

}

TXT_RECORDS=$(echo "$HOSTED_ZONES" | xargs -n 1 | xargs -I % bash -c 'aws route53 list-resource-record-sets --hosted-zone-id "'"/hostedzone/%"'" --query "'"ResourceRecordSets[?Type == \\\`TXT\\\`]"'" | jq "'".[]"'" | jq "'". + {HostedZoneId: \\\"%\\\"}"'"' )

echo "$TXT_RECORDS" | jq -rc '.' > compacted_txt_records

export -f upsert_record

parallel -a compacted_txt_records --recend '}\n' --line-buffer --delay 0.5 --pipe-part --will-cite --block 30 "upsert_record {}"

exit 0
