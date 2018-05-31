#!/bin/bash
if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
    CONFIG_FOLDER=${PWD}/../../../sampleconfig
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
    CONFIG_FOLDER=${PWD}/../../sampleconfig
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

# Copy the required files(configtx.yaml, cruypto-config.yaml, sample chaincode etc.) into volume
echo -e "\nCreating Copy artifacts job."
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml

pod=$(kubectl get pods  --show-all --selector=job-name=copyartifacts --output=jsonpath={.items..metadata.name})

podSTATUS=$(kubectl get pods  --show-all --selector=job-name=copyartifacts --output=jsonpath={.items..phase})

while [ "${podSTATUS}" != "Running" ]; do
    echo "Wating for container of copy artifact pod to run. Current status of ${pod} is ${podSTATUS}"
    sleep 5;
    if [ "${podSTATUS}" == "Error" ]; then
        echo "There is an error in copyartifacts job. Please check logs."
        exit 1
    fi
    podSTATUS=$(kubectl get pods --show-all --selector=job-name=copyartifacts --output=jsonpath={.items..phase})
done

echo -e "${pod} is now ${podSTATUS}"
echo -e "\nStarting to copy artifacts in persistent volume."

#fix for this script to work on icp and ICS
kubectl cp ${CONFIG_FOLDER} $pod:/shared/

echo "Waiting for 10 more seconds for copying artifacts to avoid any network delay"
sleep 10


echo "Copy artifacts job completed"
kubectl delete -f ${KUBECONFIG_FOLDER}/copyArtifactsJob.yaml
echo "Copy artifacts container deleted"