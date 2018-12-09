#!/bin/bash

DEFAULT_NUM_OF_MASTERS=3
DEFAULT_NUM_OF_PUBLIC_AGENTS=1
DEFAULT_NUM_OF_PRIVATE_AGENTS=5

DEFAULT_BOOTSTRAP_INSTANCE_TYPE=Standard_D2s_v3
DEFAULT_MASTER_INSTANCE_TYPE=Standard_D4s_v3
DEFAULT_GOSEC_INSTANCE_TYPE=Standard_D4s_v3
DEFAULT_PUBLIC_AGENT_INSTANCE_TYPE=Standard_D2s_v3
DEFAULT_PRIVATE_AGENT_INSTANCE_TYPE=Standard_D4s_v3

bold=$(tput bold)
normal=$(tput sgr0)

#while read -p 'Enter something: ' TEST && [[ -z "$TEST" ]] ; do
# echo "Provide y or n!"
#done

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

echo "---------------------------------------------"
echo "Creating $CLUSTER_ID.tfvars:"
tee ./$CLUSTER_ID.tfvars << EOF
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

echo "---------------------------------------------"
ssh-keygen -f ./secrets/$CLUSTER_ID -t rsa -N '' -C $CLUSTER_ID

echo "---------------------------------------------"
terraform init

echo "---------------------------------------------"
echo "Successfully initialized, you can further customize your infrastructure editing terraform.tfvars"