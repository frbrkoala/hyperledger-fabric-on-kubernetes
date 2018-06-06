#!/bin/bash
if [ "${PWD##*/}" == "delete" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/delete' folder"
fi

echo "Deleting Hyperledger Explorer Pod and Service"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/explorer.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/explorer.yaml

sleep 15

echo "Deleting PostgreSQL Pod and Service"
echo "Running: kubectl delete -f ${KUBECONFIG_FOLDER}/postgresql.yaml"
kubectl delete -f ${KUBECONFIG_FOLDER}/postgresql.yaml
