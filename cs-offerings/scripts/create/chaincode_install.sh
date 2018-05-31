#!/bin/bash

if [ "${PWD##*/}" == "create" ]; then
    KUBECONFIG_FOLDER=${PWD}/../../kube-configs
elif [ "${PWD##*/}" == "scripts" ]; then
    KUBECONFIG_FOLDER=${PWD}/../kube-configs
else
    echo "Please run the script from 'scripts' or 'scripts/create' folder"
fi

# Default to peer 1's address if not defined
if [ -z "${PEER_ADDRESS}" ]; then
	echo "PEER_ADDRESS not defined. I will use \"blockchain-org1peer1:30110\"."
	echo "I will wait 5 seconds before continuing."
	sleep 5
fi
PEER_ADDRESS=${PEER_ADDRESS:-blockchain-org1peer1:30110}

# Default to "Org1MSP" if not defined
if [ -z ${PEER_MSPID} ]; then
	echo "PEER_MSPID not defined. I will use \"Org1MSP\"."
	echo "I will wait 5 seconds before continuing."
	sleep 5
fi
PEER_MSPID=${PEER_MSPID:-Org1MSP}

# Default to "admin for peer1" if not defined
if [ -z "${MSP_CONFIGPATH}" ]; then
	echo "MSP_CONFIGPATH not defined. I will use \"/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp\"."
	echo "I will wait 5 seconds before continuing."
	sleep 5
fi
MSP_CONFIGPATH=${MSP_CONFIGPATH:-/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp}

# Default to "mycc" if not defined
if [ -z ${CHAINCODE_NAME} ]; then
	echo "CHAINCODE_NAME not defined. I will use \"mycc\"."
	echo "I will wait 5 seconds before continuing."
	sleep 5
fi

CHAINCODE_NAME=${CHAINCODE_NAME:-mycc}

# Default to "1.0" if not defined
if [ -z ${CHAINCODE_VERSION} ]; then
	echo "CHAINCODE_VERSION not defined. I will use \"1.0\"."
	echo "I will wait 5 seconds before continuing."
	sleep 5
fi
CHAINCODE_VERSION=${CHAINCODE_VERSION:-1.0}

echo "Deleting old chaincodeinstall pods if exists"
echo "Running: ${KUBECONFIG_FOLDER}/../scripts/delete/delete_chaincode-install.sh"
${KUBECONFIG_FOLDER}/../scripts/delete/delete_chaincode-install.sh

echo "Preparing yaml for chaincodeinstall"
sed -e "s/%PEER_ADDRESS%/${PEER_ADDRESS}/g" -e "s/%PEER_MSPID%/${PEER_MSPID}/g" -e "s|%MSP_CONFIGPATH%|${MSP_CONFIGPATH}|g"  -e "s/%CHAINCODE_NAME%/${CHAINCODE_NAME}/g" -e "s/%CHAINCODE_VERSION%/${CHAINCODE_VERSION}/g" ${KUBECONFIG_FOLDER}/chaincode_install.yaml.base > ${KUBECONFIG_FOLDER}/chaincode_install.yaml

echo "Creating chaincodeinstall pod"
echo "Running: kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml"
kubectl create -f ${KUBECONFIG_FOLDER}/chaincode_install.yaml

while [ "$(kubectl get pod -a chaincodeinstall | grep chaincodeinstall | awk '{print $3}')" != "Completed" ]; do
    echo "Waiting for chaincodeinstall container to be Completed"
    sleep 1;
done

if [ "$(kubectl get pod -a chaincodeinstall | grep chaincodeinstall | awk '{print $3}')" == "Completed" ]; then
	echo "Install Chaincode Completed Successfully"
fi

if [ "$(kubectl get pod -a chaincodeinstall | grep chaincodeinstall | awk '{print $3}')" != "Completed" ]; then
	echo "Install Chaincode Failed"
fi
