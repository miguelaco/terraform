#!/bin/bash

command -v ssh-keygen > /dev/null 2>&1 || { echo >&2 "ssh-keygen required but not found"; return 1; }
command -v terraform > /dev/null 2>&1 || { echo >&2 "terraform required but not found (https://www.terraform.io/downloads.html)"; return 1; }
command -v az > /dev/null 2>&1 || { echo >&2 "azure-cli required but not found (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)"; return 1; }

bold=$(tput bold)
normal=$(tput sgr0)

DEFAULT_NUM_OF_MASTERS=3
DEFAULT_NUM_OF_GOSECS=3
DEFAULT_NUM_OF_PUBLIC_AGENTS=1
DEFAULT_NUM_OF_PRIVATE_AGENTS=5
DEFAULT_NUM_OF_HDFS=1

DEFAULT_BOOTSTRAP_INSTANCE_TYPE=Standard_D2s_v3
DEFAULT_MASTER_INSTANCE_TYPE=Standard_D4s_v3
DEFAULT_GOSEC_INSTANCE_TYPE=Standard_D4s_v3
DEFAULT_PUBLIC_AGENT_INSTANCE_TYPE=Standard_D2s_v3
DEFAULT_PRIVATE_AGENT_INSTANCE_TYPE=Standard_D4s_v3
DEFAULT_HDFS_INSTANCE_TYPE=Standard_D4s_v3

RESOURCE_GROUP_NAME=terraform
CONTAINER_NAME=tfstate

#while read -p 'Enter something: ' TEST && [[ -z "$TEST" ]] ; do
# echo "Provide y or n!"
#done

function setup_state_backend {

	if [ -f ./backend.tf ] && [ ! $RESET_BACKEND ]
	then
		echo "Backend already initialized, ${bold}backend.tf${normal} exists"
		return 0
	fi

	az group create --name $RESOURCE_GROUP_NAME --location westeurope > /dev/null || return 1
	echo "Resource group $RESOURCE_GROUP_NAME created"

	TENANT_ID=$(az account show --query tenantId -o tsv)
	STORAGE_ACCOUNT_NAME=$(echo $TENANT_ID | md5sum | cut -f1 -d " " | cut -c1-24)

	az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob > /dev/null || return 1
	echo "Storage account $STORAGE_ACCOUNT_NAME created"

	ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv) || return 1

	az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY > /dev/null || return 1
	echo "Container $CONTAINER_NAME created"

	cat <<-EOS > ./backend.tf
		terraform {
		  backend "azurerm" {
		    resource_group_name  = "$RESOURCE_GROUP_NAME"
		    storage_account_name = "$STORAGE_ACCOUNT_NAME"
		    container_name       = "$CONTAINER_NAME"
		    access_key           = "$ACCOUNT_KEY"
		  }
		}
	EOS

}

function setup_configuration {
	if [ -f ./terraform.tfvars ] && [ ! $RESET_CONFIG ]
	then
		echo "Configuration already initialized, ${bold}terraform.tfvars${normal} exists"
		CLUSTER_ID=$(grep cluster_id terraform.tfvars | cut -f2 -d "=" | tr -d "\" ")
		return 0
	fi

	read -p "Enter your ${bold}cluster name${normal}: " CLUSTER_ID

	read -p "Number of ${bold}masters${normal}? (default: $DEFAULT_NUM_OF_MASTERS): " NUM_OF_MASTERS
	NUM_OF_MASTERS=${NUM_OF_MASTERS:-$DEFAULT_NUM_OF_MASTERS}

	read -p "Number of ${bold}gosecs${normal}? (default: $DEFAULT_NUM_OF_GOSECS): " NUM_OF_GOSECS
	NUM_OF_GOSECS=${NUM_OF_GOSECS:-$DEFAULT_NUM_OF_GOSECS}

	read -p "Number of ${bold}public agents${normal}? (default: $DEFAULT_NUM_OF_PUBLIC_AGENTS): " NUM_OF_PUBLIC_AGENTS
	NUM_OF_PUBLIC_AGENTS=${NUM_OF_PUBLIC_AGENTS:-$DEFAULT_NUM_OF_PUBLIC_AGENTS}

	read -p "Number of ${bold}private agents${normal}? (default: $DEFAULT_NUM_OF_PRIVATE_AGENTS): " NUM_OF_PRIVATE_AGENTS
	NUM_OF_PRIVATE_AGENTS=${NUM_OF_PRIVATE_AGENTS:-$DEFAULT_NUM_OF_PRIVATE_AGENTS}

	read -p "Number of ${bold}hdfs${normal}? (default: $DEFAULT_NUM_OF_HDFS): " NUM_OF_HDFS
	NUM_OF_HDFS=${NUM_OF_HDFS:-$DEFAULT_NUM_OF_HDFS}

	read -p "Instance type for ${bold}bootstrap${normal}? (default: $DEFAULT_BOOTSTRAP_INSTANCE_TYPE): " BOOTSTRAP_INSTANCE_TYPE
	BOOTSTRAP_INSTANCE_TYPE=${BOOTSTRAP_INSTANCE_TYPE:-$DEFAULT_BOOTSTRAP_INSTANCE_TYPE}

	read -p "Instance type for ${bold}masters${normal}? (default: $DEFAULT_MASTER_INSTANCE_TYPE): " MASTER_INSTANCE_TYPE
	MASTER_INSTANCE_TYPE=${MASTER_INSTANCE_TYPE:-$DEFAULT_MASTER_INSTANCE_TYPE}

	[ $NUM_OF_GOSECS -gt 0 ] && read -p "Instance type for ${bold}gosec${normal}? (default: $DEFAULT_GOSEC_INSTANCE_TYPE): " GOSEC_INSTANCE_TYPE
	GOSEC_INSTANCE_TYPE=${GOSEC_INSTANCE_TYPE:-$DEFAULT_GOSEC_INSTANCE_TYPE}

	[ $NUM_OF_PUBLIC_AGENTS -gt 0 ] && read -p "Instance type for ${bold}public agents${normal}? (default: $DEFAULT_MASTER_INSTANCE_TYPE): " PUBLIC_AGENT_INSTANCE_TYPE
	PUBLIC_AGENT_INSTANCE_TYPE=${PUBLIC_AGENT_INSTANCE_TYPE:-$DEFAULT_PUBLIC_AGENT_INSTANCE_TYPE}

	read -p "Instance type for ${bold}private agents${normal}? (default: $DEFAULT_MASTER_INSTANCE_TYPE): " PRIVATE_AGENT_INSTANCE_TYPE
	PRIVATE_AGENT_INSTANCE_TYPE=${PRIVATE_AGENT_INSTANCE_TYPE:-$DEFAULT_PRIVATE_AGENT_INSTANCE_TYPE}

	[ $NUM_OF_HDFS -gt 0 ] && read -p "Instance type for ${bold}hdfs${normal}? (default: $DEFAULT_HDFS_INSTANCE_TYPE): " HDFS_INSTANCE_TYPE
	HDFS_INSTANCE_TYPE=${HDFS_INSTANCE_TYPE:-$DEFAULT_HDFS_INSTANCE_TYPE}

	echo "Creating $CLUSTER_ID.tfvars:"
	tee ./terraform.tfvars <<-EOF
		cluster_id = "$CLUSTER_ID"
		num_of_masters = "$NUM_OF_MASTERS"
		num_of_gosecs = "$NUM_OF_GOSECS"
		num_of_public_agents = "$NUM_OF_PUBLIC_AGENTS"
		num_of_private_agents = "$NUM_OF_PRIVATE_AGENTS"
		num_of_hdfs = "$NUM_OF_HDFS"
		bootstrap_instance_type = "$BOOTSTRAP_INSTANCE_TYPE"
		master_instance_type = "$MASTER_INSTANCE_TYPE"
		gosec_instance_type = "$GOSEC_INSTANCE_TYPE"
		public_agent_instance_type = "$PUBLIC_AGENT_INSTANCE_TYPE"
		private_agent_instance_type = "$PRIVATE_AGENT_INSTANCE_TYPE"
		hdfs_instance_type = "$HDFS_INSTANCE_TYPE"
		EOF
}

function generate_ssh_keypair {
	mkdir -p ./secrets
	ssh-keygen -q -f ./secrets/key -t rsa -N '' -C key
	return 0
}

echo "---------------------------------------------"
echo " Setup configuration"
echo "---------------------------------------------"
setup_configuration || exit 1

echo ""
echo "---------------------------------------------"
echo " Setup state backend"
echo "---------------------------------------------"
setup_state_backend || exit 1

echo ""
echo "---------------------------------------------"
echo " Generate SSH keypair"
echo "---------------------------------------------"
generate_ssh_keypair || exit 1

echo ""
echo "---------------------------------------------"
echo " Terraform init"
echo "---------------------------------------------"
terraform init -reconfigure -backend-config="key=$CLUSTER_ID" || exit 1

echo ""
echo "---------------------------------------------"
echo "Successfully initialized, you can further customize your infrastructure editing terraform.tfvars"
