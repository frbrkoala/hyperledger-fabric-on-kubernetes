#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

echo "Creating new PostgresSQL server"

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/postgresql.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/postgresql.yaml

echo "Checking if PostgresSQL is ready"

NUMPENDING=$(kubectl get deployments | grep postgresql | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments | grep postgresql | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 1
done

POSTGRESQL_POD=$(kubectl get pods | grep postgresql | awk '{print $1}')

echo "Initializing database"
kubectl exec ${POSTGRESQL_POD} -- psql -f /var/lib/postgresql/db-explorer/explorerpg.sql fabricexplorer hppoc
kubectl exec ${POSTGRESQL_POD} -- psql -f /var/lib/postgresql/db-explorer/updatepg.sql fabricexplorer hppoc

echo "Creating new Hyperledger Explorer server"

echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/explorer.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/explorer.yaml

echo "Checking if tHyperledger Explorer is ready"

NUMPENDING=$(kubectl get deployments | grep explorer | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
while [ "${NUMPENDING}" != "0" ]; do
    echo "Waiting on pending deployments. Deployments pending = ${NUMPENDING}"
    NUMPENDING=$(kubectl get deployments | grep explorer | awk '{print $5}' | grep 0 | wc -l | awk '{print $1}')
    sleep 1
done
