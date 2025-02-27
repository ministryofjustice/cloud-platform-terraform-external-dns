#!/bin/bash

upsert_record() {
    ING_NAME=$1
    ADDR=$2
    ID=$3
    NAMESPACE=$4
    WEIGHT=$5
    IS_POST_UPGRADE=$6
    ZONE=$7
    LOGS=0

    kubectl annotate ingress $ING_NAME external-dns.alpha.kubernetes.io/aws-weight=$WEIGHT -n $NAMESPACE --overwrite

    sleep 60

    if [ "$IS_POST_UPGRADE" = true ]; then
        LOGS=$(kubectl get pods -n kube-system | grep external | awk '{ print $1 }' | xargs -I % kubectl logs % -n kube-system | grep "Desired change: UPSERT $ADDR A" | grep -c "profile=default zoneID=/hostedzone/$ID zoneName=$ZONE.")
    else
        LOGS=$(kubectl get pods -n kube-system | grep external | awk '{ print $1 }' | xargs -I % kubectl logs % -n kube-system | grep -c "Desired change: UPSERT $ADDR A \[Id: /hostedzone/$ID\]")
    fi

    if [ "$LOGS" -lt 1 ]; then
        echo "FAILED: No UPSERT log found in external dns for $ADDR record ❌ for $ID"
        exit 1
    fi

    echo "UPSERT log in external dns pod ✅"
    echo "Checking UPSERT by checking $ADDR record in Hosted Zone 2 is updated in Route 53"

    R53=$(aws route53 list-resource-record-sets --hosted-zone-id "/hostedzone/$ID" --query 'ResourceRecordSets[?Name ==`'$ADDR'.`]' | jq '.[] | select(.Name == "'$ADDR'." and .Type == "A") | .Weight')

    if [ "$R53" -ne $WEIGHT ]; then
        echo "FAILED: UPDATED weight not found in route53 for $ADDR record ❌ for $ID"
        exit 1
    fi
    echo "UPSERT'ed in route 53 ✅"

    echo "Resetting aws weight to 100"
    kubectl annotate ingress $ING_NAME external-dns.alpha.kubernetes.io/aws-weight=100 -n $NAMESPACE --overwrite
}

delete_record() {
    ING_NAME=$1
    ADDR=$2
    ID=$3
    NAMESPACE=$4
    IS_POST_UPGRADE=$5
    ZONE=$6
    LOGS=0

    kubectl delete ing $ING_NAME -n $NAMESPACE

    sleep 60

    if [ "$IS_POST_UPGRADE" = true ]; then
        LOGS=$(kubectl get pods -n kube-system | grep external | awk '{ print $1 }' | xargs -I % kubectl logs % -n kube-system | grep "Desired change: DELETE $ADDR A" | grep -c "profile=default zoneID=/hostedzone/$ID zoneName=$ZONE.")
    else
        LOGS=$(kubectl get pods -n kube-system | grep external | awk '{ print $1 }' | xargs -I % kubectl logs % -n kube-system | grep -c "Desired change: DELETE $ADDR A \[Id: /hostedzone/$ID\]")
    fi

    if [ "$LOGS" -lt 1 ]; then
        echo "FAILED: No DELETE log found in external dns for $ADDR record ❌ for $ID"
        exit 1
    fi

    echo "DELETE log in external dns pod ✅"
    echo "Checking DELETE by checking $ADDR record in Hosted Zone 2 is no longer in Route 53"

    R53=$(aws route53 list-resource-record-sets --hosted-zone-id "/hostedzone/$ID" --query 'ResourceRecordSets[?Name == `'$ADDR'.`]' | jq '.[] | select(.Type == "A")' | jq -s '. | length')

    if [ "$R53" -ne "0" ]; then
        echo "FAILED: Found record in route 53 for $ADDR record ❌ for $HZ_2_ID"
        exit 1
    fi
    echo "DELETE'd from route 53 ✅"
}

create_record() {
    ING_PATH=$1
    ADDR=$2
    ID=$3
    NAMESPACE=$4
    IS_POST_UPGRADE=$5
    ZONE=$6
    LOGS=0

    kubectl apply -f $ING_PATH -n $NAMESPACE

    sleep 60

    if [ "$IS_POST_UPGRADE" = true ]; then
        LOGS=$(kubectl get pods -n kube-system | grep external | awk '{ print $1 }' | xargs -I % kubectl logs % -n kube-system | grep "Desired change: CREATE $ADDR A" | grep -c "profile=default zoneID=/hostedzone/$ID zoneName=$ZONE.")
    else
        LOGS=$(kubectl get pods -n kube-system | grep external | awk '{ print $1 }' | xargs -I % kubectl logs % -n kube-system | grep -c "Desired change: CREATE $ADDR A \[Id: /hostedzone/$ID\]")
    fi

    if [ "$LOGS" -lt 1 ]; then
        echo "FAILED: No CREATE log found in external dns for $ADDR record ❌ for $ID"
        exit 1
    fi

    echo "CREATE log in external dns pod ✅"
    echo "Checking CREATE by checking $ADDR record in Hosted Zone 3"

    R53=$(aws route53 list-resource-record-sets --hosted-zone-id "/hostedzone/$ID" --query 'ResourceRecordSets[?Name ==`'$ADDR'.`]' | jq '.[] | select(.Name == "'$ADDR'." and .Type == "A")' | jq -s '. | length')

    if [ "$R53" -ne "1" ]; then
        echo "FAILED: Did not find record in route 53 for $ADDR record ❌ for $ID"
        exit 1
    fi
    echo "CREATE'd in route 53 ✅"
}
