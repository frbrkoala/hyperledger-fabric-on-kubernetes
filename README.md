# Running Hyperledger Fabric 1.1 on Kubernetes

These scripts are based on those developed for [ibm-blockchain.github.io](https://ibm-blockchain.github.io) and upgraded to use Hypereldger Fabric 1.1 docker images.

It's tested with IBM Container Service's free plan. At the end of the install, you will be able to obtain a public URL to access your instance of Composer Playground (the UI for creating and deploying Business Networks to Fabric).

Steps to install:
1. Setup your Kubernetes environment. I.e. get yourself this one: [Containers in Kubernetes Clusters on IBM Cloud](https://console.bluemix.net/containers-kubernetes/catalog/cluster?bss_account=fe03a97a3c1f0c38ea3ab18788418ad0)

2. Setup your `kubectl` command line interface. I.e., if you are using the Containers in Kubernetes Clusters on IBM Cloud service, to get the instructions, click on you cluster's name and then choose "Access" in the left hand menu.

3. Clone this repo to your local machine:
```
git clone https://github.com/frbrkoala/hyperledger-fabric-on-kubernetes.git
```

4. Run the auto setup script:
```
cd hyperledger-fabric-on-kubernetes/cs-offerings/scripts && ./create_all.sh
```
Note: if using Paid version of Containers in Kubernetes Clusters on IBM Cloud, add `--paid` flag to your command.

5. If something goes wrong, use the following script to delete the network from your Kuberenetes cluster:
```
cd hyperledger-fabric-on-kubernetes/cs-offerings/scripts && ./delete_all.sh
```
Note: if using Paid version of Containers in Kubernetes Clusters on IBM Cloud, add `--paid` flag to your command.