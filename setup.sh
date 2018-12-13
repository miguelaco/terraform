#!/bin/bash

command -v ssh-keygen > /dev/null 2>&1 || { echo >&2 "ssh-keygen required but not found"; exit 1; }
command -v terraform > /dev/null 2>&1 || { echo >&2 "terraform required but not found (https://www.terraform.io/downloads.html)"; exit 1; }
command -v az > /dev/null 2>&1 || { echo >&2 "azure-cli required but not found (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)"; exit 1; }

bold=$(tput bold)
normal=$(tput sgr0)

#while read -p 'Enter something: ' TEST && [[ -z "$TEST" ]] ; do
# echo "Provide y or n!"
#done

function setup_state_backend {
	RESOURCE_GROUP_NAME=terraform
	STORAGE_ACCOUNT_NAME=stratio$RANDOM
	CONTAINER_NAME=tfstate

	# Create resource group
	az group create --name $RESOURCE_GROUP_NAME --location westeurope

	# Create storage account
	az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

	# Get storage account key
	ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

	# Create blob container
	az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY


	echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
	echo "container_name: $CONTAINER_NAME"
	echo "access_key: $ACCOUNT_KEY"
}

function setup_configuration {
	DEFAULT_NUM_OF_MASTERS=3
	DEFAULT_NUM_OF_PUBLIC_AGENTS=1
	DEFAULT_NUM_OF_PRIVATE_AGENTS=5

	DEFAULT_BOOTSTRAP_INSTANCE_TYPE=Standard_D2s_v3
	DEFAULT_MASTER_INSTANCE_TYPE=Standard_D4s_v3
	DEFAULT_GOSEC_INSTANCE_TYPE=Standard_D4s_v3
	DEFAULT_PUBLIC_AGENT_INSTANCE_TYPE=Standard_D2s_v3
	DEFAULT_PRIVATE_AGENT_INSTANCE_TYPE=Standard_D4s_v3

	read -p "Enter your ${bold}cluster name${normal}: " CLUSTER_ID

	read -p "Number of ${bold}masters${normal}? (default: $DEFAULT_NUM_OF_MASTERS): " NUM_OF_MASTERS
	NUM_OF_MASTERS=${NUM_OF_MASTERS:-$DEFAULT_NUM_OF_MASTERS}

	read -p "Number of ${bold}public agents${normal}? (default: 1): " NUM_OF_PUBLIC_AGENTS
	NUM_OF_PUBLIC_AGENTS=${NUM_OF_PUBLIC_AGENTS:-$DEFAULT_NUM_OF_PUBLIC_AGENTS}

	read -p "Number of ${bold}private agents${normal}? (default: 5): " NUM_OF_PRIVATE_AGENTS
	NUM_OF_PRIVATE_AGENTS=${NUM_OF_PRIVATE_AGENTS:-$DEFAULT_NUM_OF_PRIVATE_AGENTS}

	read -p "Instance type for ${bold}bootstrap${normal}? (default: $DEFAULT_BOOTSTRAP_INSTANCE_TYPE): " BOOTSTRAP_INSTANCE_TYPE
	BOOTSTRAP_INSTANCE_TYPE=${BOOTSTRAP_INSTANCE_TYPE:-$DEFAULT_BOOTSTRAP_INSTANCE_TYPE}

	read -p "Instance type for ${bold}masters${normal}? (default: $DEFAULT_MASTER_INSTANCE_TYPE): " MASTER_INSTANCE_TYPE
	MASTER_INSTANCE_TYPE=${MASTER_INSTANCE_TYPE:-$DEFAULT_MASTER_INSTANCE_TYPE}

	read -p "Instance type for ${bold}gosec${normal}? (default: $DEFAULT_GOSEC_INSTANCE_TYPE): " GOSEC_INSTANCE_TYPE
	GOSEC_INSTANCE_TYPE=${GOSEC_INSTANCE_TYPE:-$DEFAULT_GOSEC_INSTANCE_TYPE}

	read -p "Instance type for ${bold}public agents${normal}? (default: $DEFAULT_MASTER_INSTANCE_TYPE): " PUBLIC_AGENT_INSTANCE_TYPE
	PUBLIC_AGENT_INSTANCE_TYPE=${PUBLIC_AGENT_INSTANCE_TYPE:-$DEFAULT_PUBLIC_AGENT_INSTANCE_TYPE}

	read -p "Instance type for ${bold}private agents${normal}? (default: $DEFAULT_MASTER_INSTANCE_TYPE): " PRIVATE_AGENT_INSTANCE_TYPE
	PRIVATE_AGENT_INSTANCE_TYPE=${PRIVATE_AGENT_INSTANCE_TYPE:-$DEFAULT_PRIVATE_AGENT_INSTANCE_TYPE}

	echo "Creating $CLUSTER_ID.tfvars:"
	tee ./$CLUSTER_ID.tfvars <<-EOF
		cluster_id = "$CLUSTER_ID"
		num_of_masters = "$NUM_OF_MASTERS"
		num_of_public_agents = "$NUM_OF_PUBLIC_AGENTS"
		num_of_private_agents = "$NUM_OF_PRIVATE_AGENTS"
		bootstrap_instance_type = "$BOOTSTRAP_INSTANCE_TYPE"
		master_instance_type = "$MASTER_INSTANCE_TYPE"
		gosec_instance_type = "$GOSEC_INSTANCE_TYPE"
		public_agent_instance_type = "$PUBLIC_AGENT_INSTANCE_TYPE"
		private_agent_instance_type = "$PRIVATE_AGENT_INSTANCE_TYPE"
		EOF
}

function generate_ssh_keypair {
	echo "---------------------------------------------"
	mkdir ./secrets
	ssh-keygen -f ./secrets/$CLUSTER_ID -t rsa -N '' -C $CLUSTER_ID
}

echo "---------------------------------------------"
echo " Setup state backend"
echo "---------------------------------------------"
setup_state_backend

echo "---------------------------------------------"
echo " Setup configuration"
echo "---------------------------------------------"
setup_configuration

echo "---------------------------------------------"
echo " Generate SSH keypair"
echo "---------------------------------------------"
generate_ssh_keypair

echo "---------------------------------------------"
echo " Terraform init"
echo "---------------------------------------------"
terraform init

echo "---------------------------------------------"
echo "Successfully initialized, you can further customize your infrastructure editing terraform.tfvars"
