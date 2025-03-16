#!/bin/bash

set -eu

NAMESPACE=jaskaran-dev
HZ_1_ID="Z02298302AEG882NMV9ZK"
HZ_1_ADDR="ext-dns-test.cloud-platform.service.justice.gov.uk"
HZ_2_ID="Z09955881FQD8EN37IYBL"
HZ_2_ADDR="ext-dns-test-2.cloud-platform.service.justice.gov.uk"

source ./0-lib.sh

echo "Checking DELETE by deleting APEX ingress in hosted zone 1"
delete_record ext-dns-ing-1 $HZ_1_ADDR $HZ_1_ID $NAMESPACE false $HZ_1_ADDR

echo "Checking DELETE by deleting SUBDOMAIN ingress"
delete_record ext-dns-ing-3 "sub1.$HZ_1_ADDR" $HZ_1_ID $NAMESPACE false $HZ_1_ADDR

echo "Hosted zone 1 tests complete ✅"
echo "Hosted zone 2 tests starting..."

echo "Checking UPSERT by changing aws-weight annotation for APEX in Hosted Zone 2"
upsert_record ext-dns-ing-2 $HZ_2_ADDR $HZ_2_ID $NAMESPACE 99 false $HZ_2_ADDR

echo "Checking UPSERT by changing aws-weight annotation for SUBDOMAIN in Hosted Zone 2"
upsert_record ext-dns-ing-4 "sub2.$HZ_2_ADDR" $HZ_2_ID $NAMESPACE 99 false $HZ_2_ADDR

echo "Hosted zone 2 tests complete ✅"

echo "Pre upgrade post migration tests complete, please upgrade external dns and run the post upgrade test script✅"

exit 0
