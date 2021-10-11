#!/usr/bin/env bash

set -eu

cd $(dirname $0)

## <setup>

kubectl apply -f iperf3.yaml

until $(kubectl get pods -l app=iperf3-server -o jsonpath='{.items[0].status.containerStatuses[0].ready}'); do
    echo "Waiting for iperf3 server to start..."
    sleep 5
done

echo "Server is running"
echo

CLIENTS=$(kubectl get pods -l app=iperf3-client -o name | cut -d'/' -f2)

for POD in ${CLIENTS}; do
    until $(kubectl get pod "${POD}" -o jsonpath='{.status.containerStatuses[0].ready}'); do
        echo "Waiting for ${POD} to start..."
        sleep 5
    done
done

echo "All clients are running"
echo

kubectl get pod -o=custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,IP-NODE:.status.hostIP,IP-POD:status.podIP

echo

## </setup>
## <run>

CLIENTS=$(kubectl get pods -l app=iperf3-client -o name | cut -d'/' -f2)

arguments="$*"

timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"

for POD in ${CLIENTS}; do
    HOST=$(kubectl get pod "${POD}" -o jsonpath='{.status.hostIP}')
    if [[ "${arguments}" == *"-J"* ]]; then
        kubectl exec -it "${POD}" -- iperf3 -c iperf3-server -T "${HOST}" "$@" > "reports/${timestamp}-${HOST}-${POD}.json"
        echo "Report created: reports/${timestamp}-${HOST}-${POD}.json"
    else
        kubectl exec -it "${POD}" -- iperf3 -c iperf3-server -T "${HOST}" "$@"
    fi
    echo
done

## </run>
## <clean>

kubectl delete --cascade -f iperf3.yaml

## </clean>
