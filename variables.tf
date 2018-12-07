variable "cluster_id" {
  description = "The cluster ID."
}

variable "ssh_pub_key" {
  description = "The Public SSH Key associated with your instances for login. Copy your own key from your machine when deploying to log into your instance."
}

variable "os_username" {
  description = "Username of the OS."
  default     = "operador"
}

variable "azure_region" {
  description = "Azure region to launch servers."
  default     = "West Europe"
}

variable "azure_master_instance_type" {
  description = "Azure DC/OS master instance type"
  default     = "Standard_D4s_v3"
}

variable "azure_gosec_instance_type" {
  description = "Azure DC/OS master instance type"
  default     = "Standard_D4s_v3"
}

variable "azure_private_agent_instance_type" {
  description = "Azure DC/OS Private Agent instance type"
  default     = "Standard_D4s_v3"
}

variable "azure_public_agent_instance_type" {
  description = "Azure DC/OS Public instance type"
  default     = "Standard_D2s_v3"
}

variable "azure_bootstrap_instance_type" {
  description = "Azure DC/OS Bootstrap instance type"
  default     = "Standard_D2s_v3"
}

variable "num_of_private_agents" {
  description = "DC/OS Private Agents Count"
  default     = 2
}

variable "num_of_public_agents" {
  description = "DC/OS Private Agents Count"
  default     = 1
}

variable "num_of_masters" {
  description = "DC/OS Master Nodes Count (Odd only)"
  default     = 3
}

variable "num_of_gosecs" {
  description = "Gosec Nodes Count"
  default     = 3
}

#variable "ip-detect" {
# description = "Used to determine the private IP address of instances"
# type = "map"
#
# default = {
#  aws   = "scripts/cloud/aws/ip-detect.aws.sh"
#  azure = "scripts/cloud/azure/ip-detect.azure.sh"
# }
#}

variable "instance_disk_size" {
  description = "Default size of the root disk (GB)"
  default     = "128"
}
