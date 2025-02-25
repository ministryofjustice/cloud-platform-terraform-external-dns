#!/bin/bash

set -e

HOSTED_ZONES=$(cat 100_ing_hz)

upsert_record() {
    TXT_OBJ=$(cat $1)

    echo $TXT_OBJ | jq '.'

    HOSTED_ZONE_ID=$(echo "$TXT_OBJ" | jq -r '.HostedZoneId')
    WEIGHT=$(echo "$TXT_OBJ" | jq '.Weight')



    SET_IDENTIFIER=$(echo "$TXT_OBJ" | jq '.SetIdentifier')

    RESOURCE_RECORD_VALUE=$(echo "$TXT_OBJ" | jq '.ResourceRecords[0].Value')


    if [ -n "${SET_IDENTIFIER}" ]; then
        # An error occurred (InvalidInput) when calling the ChangeResourceRecordSets operation: Invalid request: Expected exactly one of [Weight, Region, Failover, GeoLocation, MultiValueAnswer, GeoProximityLocation, or CidrRoutingConfig], but found none in Change with [Action=UPSERT, Name=_external_dns.cname.alertmanager.cp-2502-1521.cloud-platform.service.justice.gov.uk., Type=TXT, SetIdentifier=monitoring-alertmanager-proxy-oauth2-proxy-green]


        # An error occurred (InvalidChangeBatch) when calling the ChangeResourceRecordSets operation: [RRSet with DNS name _external_dns.cname.\052.apps.cp-2502-1521.cloud-platform.service.justice.gov.uk., type TXT, SetIdentifier ingress-controllers-nginx-ingress-default-controller-green, and Region Name=eu-west-2 cannot be created because a non-latency RRSet with the same name and type already exists.]
        ID=$(echo $RESOURCE_RECORD_VALUE | sed -r 's/.*resource=(ingress|service)\/(.*)\\\"\"/\2/' | sed 's/\//-/')
        SET_IDENTIFIER='"'"$ID-green"'"'
    fi

    echo "SET ID $SET_IDENTIFIER"

    NAME=$(echo "$TXT_OBJ" | jq '.Name')

    if echo $NAME | grep -vq "_external_dns.cname"; then
        UPDATED_NAME=$(echo "$NAME" | sed 's/_external_dns\./_external_dns.cname./g')


        if [ -n "${WEIGHT}" ]; then
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
                ,"ResourceRecords"  : [{
                            "Value"         : '$RESOURCE_RECORD_VALUE'
                        }]
                    }
            }]
          }
            '
        else
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
    fi

}

TXT_RECORDS=$(echo "$HOSTED_ZONES" | xargs -n 1 | xargs -I % bash -c 'aws route53 list-resource-record-sets --hosted-zone-id "'"/hostedzone/%"'" --query "'"ResourceRecordSets[?Type == \\\`TXT\\\`]"'" | jq "'".[]"'" | jq "'". + {HostedZoneId: \\\"%\\\"}"'"' )

echo "$TXT_RECORDS" | jq -rc '.' > compacted_txt_records

export -f upsert_record

parallel -a compacted_txt_records --recend '}\n' --line-buffer --delay 0.5 --pipe-part --will-cite --block 30 "upsert_record {}"

exit 0
