#!/bin/bash

#az login

read -p "Enter your cluster name: " CLUSTER_ID
read -p "Number of masters?: " NUM_OF_MASTERS
read -p "Number of public agents?: " NUM_OF_PRIVATE_AGENTS
read -p "Number of private agents?: " NUM_OF_PRIVATE_AGENTS

echo "Creating terraform.tfvars"
cat << EOF > ./terraform.tfvars
cluster_id = "$CLUSTER_ID"
num_of_masters = "$NUM_OF_MASTERS"
num_of_private_agents = "$NUM_OF_PRIVATE_AGENTS"
num_of_public_agents = "$NUM_OF_PRIVATE_AGENTS"
EOF

echo "Generate new ssh key"
ssh-keygen -f ./secrets/$CLUSTER_ID -t rsa -N '' -C $CLUSTER_ID

terraform init

echo "Successfully initialized, you can further customize your infrastructure editing terraform.tfvars"