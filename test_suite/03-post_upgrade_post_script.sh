#!/bin/bash

NAMESPACE=jaskaran-dev
HZ_2_ID="Z09955881FQD8EN37IYBL"
HZ_2_ADDR="ext-dns-test-2.cloud-platform.service.justice.gov.uk"
HZ_3_ID="Z02298302AEG882NMV9ZK"
HZ_3_ADDR="ext-dns-test.cloud-platform.service.justice.gov.uk"

source ./0-lib.sh

echo "post upgrade Hosted zone 2 tests on EXISTING records starting..."
echo "Checking UPSERT by changing aws-weight annotation for APEX in Hosted Zone 2"
upsert_record ext-dns-ing-2 $HZ_2_ADDR $HZ_2_ID $NAMESPACE 93 true $HZ_2_ADDR

echo "Checking DELETE by deleting APEX ingress in hosted zone 2"
delete_record ext-dns-ing-2 $HZ_2_ADDR $HZ_2_ID $NAMESPACE true $HZ_2_ADDR

echo "Checking UPSERT by changing aws-weight annotation for SUBDOMAIN in Hosted Zone 2"
upsert_record ext-dns-ing-4 "sub2.$HZ_2_ADDR" $HZ_2_ID $NAMESPACE 98 true $HZ_2_ADDR

echo "Checking DELETE by deleting SUBDOMAIN ingress"
delete_record ext-dns-ing-4 "sub2.$HZ_2_ADDR" $HZ_2_ID $NAMESPACE true $HZ_2_ADDR

echo "Post upgrade tests on existing resources ✅"

echo "Running final 'CRUD' operations..."

echo "CREATE new Apex record..."
create_record fixtures/apex-post-ing-5.yaml $HZ_3_ADDR $HZ_3_ID $NAMESPACE true $HZ_3_ADDR

echo "CREATE new subdomain record..."
create_record fixtures/sub-post-ing-6.yaml $HZ_3_ADDR $HZ_3_ID $NAMESPACE true $HZ_3_ADDR

echo "Checking UPSERT by changing aws-weight annotation for APEX in Hosted Zone 3"
upsert_record ext-dns-ing-5 $HZ_3_ADDR $HZ_3_ID $NAMESPACE 97 true $HZ_3_ADDR

echo "Checking UPSERT by changing aws-weight annotation for SUBDOMAIN in Hosted Zone 3"
upsert_record ext-dns-ing-6 "sub3.$HZ_3_ADDR" $HZ_3_ID $NAMESPACE 98 true $HZ_3_ADDR

echo "Checking DELETE by deleting APEX ingress in hosted zone 3"
delete_record ext-dns-ing-5 $HZ_3_ADDR $HZ_3_ID $NAMESPACE true $HZ_3_ADDR

echo "Checking DELETE by deleting SUBDOMAIN ingress post upgrade in hosted zone 3"
delete_record ext-dns-ing-6 "sub3.$HZ_3_ADDR" $HZ_3_ID $NAMESPACE true $HZ_3_ADDR

echo "Post upgrade tests complete, please check wildcard domains manually."

exit 0

